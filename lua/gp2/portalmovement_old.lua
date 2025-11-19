-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Controls player movement through portals (shared due prediction)
-- Original code: Mee
-- ----------------------------------------------------------------------------

AddCSLuaFile()

local function updateScale(ply, scale)
    ply:SetModelScale(scale)
    ply:SetViewOffset(Vector(0, 0, 64 * scale))
    ply:SetViewOffsetDucked(Vector(0, 0, 64 * scale / 2))

    if scale < 0.11 then
        ply:SetCrouchedWalkSpeed(0.83)
    else
        ply:SetCrouchedWalkSpeed(0.3)
    end
end

local freezePly = false
local function updateCalcViews(finalPos, finalVel)
	timer.Remove("portals_eye_fix_delay")	--just in case you enter the portal while the timer is running

	finalPos = finalPos - finalVel * FrameTime()	-- why does this work? idk but it feels nice, could be a source prediction thing
	hook.Add("CalcView", "GP2::PortalFix", function(ply, origin, angle, fov)
		if ply:EyePos():DistToSqr(origin) > 10000 then return end
		-- Removed roll scaling here to avoid double roll correction

		-- position ping compensation
		if freezePly and ply:Ping() > 5 then
			finalPos = finalPos + finalVel * FrameTime()
            PortalRendering.DrawPlayerInView = true
		else
			finalPos = ply:EyePos()
			PortalRendering.DrawPlayerInView = false
		end

		local wep = ply:GetActiveWeapon()
		if wep:IsValid() and isfunction(wep.CalcView) then
			local origin, angles, fov = wep:CalcView(ply, Vector(finalPos), Angle(angle), fov)
			finalPos = origin
			angle = angles
		end

		return {origin = finalPos, angles = angle}
	end)

    -- weapons sometimes glitch out a bit when you teleport, since the weapon angle is wrong
	hook.Add("CalcViewModelView", "GP2::PortalFix", function(wep, vm, oldPos, oldAng, pos, ang)
		if wep:IsValid() and isfunction(wep.CalcViewModelView) then
			local _pos, _ang = wep:CalcViewModelView(vm, Vector(oldPos), Angle(oldAng), Vector(pos), Angle(ang))
			finalPos = _pos
			ang = _ang
		end
		-- Removed roll scaling here to avoid double roll correction
		return finalPos, ang
	end)

    -- finish eyeangle lerp and ensure angles are properly set
	timer.Create("portals_eye_fix_delay", 0.3, 1, function()
		if IsValid(LocalPlayer()) then
			-- Remove the roll compensation and let the server angles take over
			hook.Remove("CalcView", "GP2::PortalFix")
			hook.Remove("CalcViewModelView", "GP2::PortalFix")
		end
	end)
end

-- this indicates wheather the player is 'teleporting' and waiting for the server to give the OK that the client position is valid
-- (only a problem with users that have higher ping)
if SERVER then
    util.AddNetworkString("PORTALS_FREEZE")
else
    net.Receive("PORTALS_FREEZE", function()
		if game.SinglePlayer() then
			updateCalcViews(Vector(), Vector())
			if net.ReadBool() then
				--PortalRendering.ToggleMirror(!PortalRendering.ToggleMirror())
			end
		end 	--singleplayer fixes (cuz stupid move hook isnt clientside in singleplayer)
        freezePly = false
    end)
end

-- Hash lookup is way faster than sting compare
local seamless_table = {["prop_portal"] = true, ["player"] = true}
local function seamless_check(e)
	return not (seamless_table[e:GetClass()] or e:GetCollisionGroup() == COLLISION_GROUP_WORLD)
end -- for traces

-- 'no collide' the player with the wall by shrinking the player's collision box
local traceTable = {}
local function editPlayerCollision(mv, ply, t)
	if ply.PORTAL_STUCK_OFFSET != 0 then
		traceTable.start = ply:GetPos() + ply:GetVelocity() * 0.02
	else
		traceTable.start = ply:GetPos()
	end
	traceTable.endpos = traceTable.start
	traceTable.mins = Vector(-16, -16, 0)
	traceTable.maxs = Vector( 16,  16, 72 - (ply:Crouching() and 1 or 0) * 36)
	traceTable.filter = ply

	if !ply.PORTAL_STUCK_OFFSET then
		traceTable.ignoreworld = true
	else
		-- extrusion in case the player enables non-ground collision and manages to clip outside of the portal while they are falling (rare case)
		if ply.PORTAL_STUCK_OFFSET != 0 then
			local tr = PortalManager.TraceLine({start = ply:EyePos(), endpos = ply:EyePos() - Vector(0, 0, 64), filter = ply})
			if tr.Hit and tr.Entity:GetClass() != "prop_portal" then
				ply.PORTAL_STUCK_OFFSET = nil
				mv:SetOrigin(tr.HitPos)
				ply:ResetHull()
				return
			end
		end
	end

	local tr = util.TraceHull(traceTable)

	-- getting this to work on the ground was a FUCKING headache
	if !ply.PORTAL_STUCK_OFFSET and tr.Hit and
	   tr.Entity:GetClass() == "prop_portal" and
	   tr.Entity.GetLinkedPartner and IsValid(tr.Entity:GetLinkedPartner())
	then
		local dotUp = tr.Entity:GetUp():Dot(Vector(0, 0, 1))
		local secondaryOffset = 0
		if dotUp > 0.5 then		-- the portal is on the ground
			traceTable.mins = Vector(0, 0, 0)
			traceTable.maxs = Vector(0, 0, 72)

			local tr = util.TraceHull(traceTable)
			if !tr.Hit or tr.Entity:GetClass() != "prop_portal" then
				return -- we accomplished nothing :DDDD
			end

			if dotUp > 0.999 then
				ply.PORTAL_STUCK_OFFSET = 72
			else
				ply.PORTAL_STUCK_OFFSET = 72
				secondaryOffset = 36
			end
		elseif dotUp < -0.9 then
			return 						-- the portal is on the ceiling
		else
			ply.PORTAL_STUCK_OFFSET = 0		-- the portal is not on the ground
		end

		ply:SetHull(Vector(-4, -4, 0 + ply.PORTAL_STUCK_OFFSET), Vector(4, 4, 72 + secondaryOffset))
		ply:SetHullDuck(Vector(-4, -4, 0 + ply.PORTAL_STUCK_OFFSET), Vector(4, 4, 36 + secondaryOffset))

	elseif ply.PORTAL_STUCK_OFFSET and !tr.Hit then
		ply:ResetHull()
		ply.PORTAL_STUCK_OFFSET = nil
	end

	traceTable.ignoreworld = false
end

-- teleport players
local seamless_check2 = function(e) return e:GetClass() == "prop_portal" end
hook.Add("Move", "seamless_portal_teleport", function(ply, mv)
    if !PortalManager or PortalManager.PortalIndex < 1 then
		if ply.PORTAL_STUCK_OFFSET then
			ply:ResetHull()
			ply.PORTAL_STUCK_OFFSET = nil
		end
		return
	end

	editPlayerCollision(mv, ply)

	local plyVel = mv:GetVelocity()
	local plyPos = ply:EyePos()



	-- Attirer le joueur vers le centre des portails horizontaux s'il tombe
	if plyVel.z < 0 then
		local closestPortal
		local closestDist2D = math.huge
		for _, portal in ipairs(ents.FindByClass("prop_portal")) do
			if IsValid(portal) and portal:GetActivated() and portal.GetLinkedPartner and IsValid(portal:GetLinkedPartner()) then
				local portalAng = portal:GetAngles()
			end
		end
		if closestPortal then
			local portalCenter = closestPortal:GetPos()
			local toCenter = Vector(portalCenter.x - plyPos.x, portalCenter.y - plyPos.y, 0)
			local distance = toCenter:Length()
			if distance > 0 then
				if distance < 20 then
					plyVel.x = 0
					plyVel.y = 0
					mv:SetVelocity(plyVel)
				else
					toCenter:Normalize()
					local timeToImpact = math.abs((plyPos.z - portalCenter.z) / plyVel.z)
					local requiredVel = distance / math.max(timeToImpact, 0.01)
					local newVel = plyVel + toCenter * (requiredVel - plyVel:Dot(toCenter))
					mv:SetVelocity(newVel)
					plyVel = newVel
				end
			end
		end
	end
	traceTable.start = plyPos - plyVel * 0.02
	traceTable.endpos = plyPos + plyVel * 0.02
	traceTable.filter = seamless_check2
	local tr = PortalManager.TraceLine(traceTable)
	if !tr.Hit then return end
	local hitPortal = tr.Entity
	if hitPortal:GetClass() == "prop_portal" and hitPortal.GetLinkedPartner and
	   IsValid(hitPortal:GetLinkedPartner()) and plyVel:Dot(hitPortal:GetUp()) < 0 and hitPortal:GetActivated()
	then
		if ply.PORTAL_TELEPORTING then return end
		freezePly = true

		-- wow look at all of this code just to teleport the player
		local linkedPartner = hitPortal:GetLinkedPartner()
		local editedPos, editedAng = PortalManager.TransformPortal(hitPortal, linkedPartner, tr.HitPos, ply:EyeAngles(), true)
		local _, editedVelocity = PortalManager.TransformPortal(hitPortal, linkedPartner, nil, plyVel:Angle())
		local max = math.Max(plyVel:Length(), linkedPartner:GetUp():Dot(-physenv.GetGravity() / 3))

		--ground can fluxuate depending on how the user places the portals, so we need to make sure we're not going to teleport into the ground
		local eyeHeight = (ply:EyePos() - ply:GetPos())
		local finalPos = editedPos - eyeHeight

		-- dont do extrusion if the player is noclipping
		local offset = Vector()
		if ply:GetMoveType() != MOVETYPE_NOCLIP then
			traceTable.start = editedPos
			traceTable.endpos = finalPos - Vector(0, 0, 0.01)
			traceTable.filter = seamless_check
			local tr = PortalManager.TraceLine(traceTable)
			offset = tr.HitPos - finalPos
		end

		local exitSize = (linkedPartner:GetSize()[1] / hitPortal:GetSize()[1])
		if ply.SCALE_MULTIPLIER then
			if ply.SCALE_MULTIPLIER * exitSize != ply.SCALE_MULTIPLIER then
				ply.SCALE_MULTIPLIER = math.Clamp(ply.SCALE_MULTIPLIER * exitSize, 0.01, 10)
				finalPos = finalPos + (eyeHeight - eyeHeight * exitSize)
				updateScale(ply, ply.SCALE_MULTIPLIER)
			end
		end

		-- Correction sortie plafond : si le portail de sortie est au plafond, placer le joueur sous le portail
		local outUp = linkedPartner:GetUp()
		local isCeiling = outUp:Dot(Vector(0,0,-1)) > 0.9
		local verticalOffset = 0.1
		if isCeiling then
			verticalOffset = -(eyeHeight.z + 2)
		end
		finalPos = finalPos + offset * exitSize + Vector(0, 0, verticalOffset)



		-- apply final velocity
		mv:SetVelocity(editedVelocity:Forward() * max * exitSize)

		-- send the client that the new position is valid
		if SERVER then
			-- Apply transformed angles to the player on server
			ply:SetEyeAngles(editedAng)

			-- lerp fix for singleplayer
			if game.SinglePlayer() then
				ply:SetPos(finalPos)
			end

			// infinite map support
			if InfMap then
				local final_pos_offset, chunk_offset = InfMap.localize_vector(finalPos)
				finalPos = final_pos_offset

		-- Correction GP2 : Si un projected_wall_entity est présent juste derrière le portail de sortie, relever le joueur
		if SERVER then
			local checkRadius = 32 -- rayon de détection autour de la sortie
			local nearbyWalls = ents.FindInSphere(finalPos, checkRadius)
			for _, ent in ipairs(nearbyWalls) do
				if IsValid(ent) and ent:GetClass() == "projected_wall_entity" then
					-- On relève le joueur de 8 unités pour éviter le blocage
					finalPos = finalPos + Vector(0, 0, 8)
					break
				end
			end
		end
				InfMap.prop_update_chunk(ply, chunk_offset)
			end

			mv:SetOrigin(finalPos)

			net.Start("PORTALS_FREEZE")
			net.WriteBool(hitPortal == linkedPartner)
			net.Send(ply)

			hitPortal:TriggerOutput("OnPlayerTeleportFromMe", ply)
			linkedPartner:TriggerOutput("OnPlayerTeleportToMe", ply)

			local filter = RecipientFilter()
			filter:AddPlayer(ply)

			ply:EmitSound("PortalPlayer.ExitPortal", nil, nil, nil, nil, nil, nil, filter)
		else
			updateCalcViews(finalPos + eyeHeight, editedVelocity:Forward() * max * exitSize, (ply.SCALE_MULTIPLIER or 1) * exitSize)	--fix viewmodel lerping for a tiny bit
			ply:SetEyeAngles(editedAng)
			ply:SetPos(finalPos)
		end
		ply.PORTAL_TELEPORTING = true
		ply.PORTAL_STUCK_OFFSET = 72
		ply:SetHull(Vector(0, 0, ply.PORTAL_STUCK_OFFSET), Vector(0, 0, 72 + ply.PORTAL_STUCK_OFFSET * 0.5))
		ply:SetHullDuck(Vector(0, 0, ply.PORTAL_STUCK_OFFSET), Vector(0, 0, 36 + ply.PORTAL_STUCK_OFFSET * 0.5))

		timer.Simple(0.03, function()
			ply.PORTAL_TELEPORTING = false
		end)

		-- Correction du roll et du pitch pour éviter une vision penchée ou trop inclinée
		-- editedAng.r = 0 -- removed to avoid double roll correction; handled in client Think hook
		editedAng.p = math.Clamp(editedAng.p, -89, 89)

		return true
	end
end)

if CLIENT then
    local lastRoll = 0
    hook.Add("Think", "GP2_PrintEyeAngles", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        local ang = ply:EyeAngles()
      --   print(string.format("Yaw: %.2f | Pitch: %.2f | Roll: %.2f", ang.y, ang.p, ang.r))
        -- Correction linéaire du roll (temps ajustable via la cvar gp2_roll_return_time)
        local rollReturnTime = 0.50
        if math.abs(ang.r) > 0.01 then
            if math.abs(lastRoll) < 0.01 or math.abs(ang.r) > math.abs(lastRoll) then
                lastRoll = ang.r -- nouvelle correction, on mémorise la valeur de départ
            end
            local sign = ang.r > 0 and 1 or -1
            local step = (math.abs(lastRoll) * FrameTime()) / rollReturnTime
            if math.abs(ang.r) <= step then
                ang.r = 0
            else
                ang.r = ang.r - sign * step
            end
            ply:SetEyeAngles(ang)
        else
            lastRoll = 0
        end
    end)
end
