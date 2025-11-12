AddCSLuaFile("weapon_portalgun/cl_init.lua")
AddCSLuaFile("weapon_portalgun/shared.lua")
include("weapon_portalgun/shared.lua")

local gp2_portal_debug_points = true
local vector_origin = Vector(0,0,0)
local rayHull = Vector(0.01, 0.01, 0.01)
local gp2_portal_placement_never_fail = GetConVar("gp2_portal_placement_never_fail")

local gtCheck = {["player"]=true, ["prop_portal"]=true, ["prop_weighted_cube"]=true, ["grenade_helicopter"]=true, ["npc_portal_turret_floor"]=true, ["prop_monster_box"]=true, ["npc_*"]=true}
local cleanserCheck = {["trigger_portal_cleanser"]=true}

CreateConVar("gp2_portal_placement_never_fail", "0", FCVAR_CHEAT + FCVAR_NOTIFY, "Can portal be placed on every surface?")
CreateConVar("gp2_save_portalgun_state", "1", FCVAR_ARCHIVE, "Save Portal Gun state (normal/upgraded/potato) when picking up the weapon")

util.AddNetworkString("GP2.SyncPortalGunState")
GP2_PortalGunStates = GP2_PortalGunStates or {}

concommand.Add("gp2_portal_debug_points", function() gp2_portal_debug_points = not gp2_portal_debug_points end, nil, "Active/désactive le debug visuel des points de validation du portail.")

local function debugDrawPoint(pos, valid, color)
	color = color or (valid and Color(0,255,0) or Color(255,0,0))
	debugoverlay.Cross(pos, 5, 1, color, true)
end

local function ForcePortalGunStateForPlayer(ply)
	local map = game.GetMap()
	local no_portal_gun = {["sp_a1_intro1"]=true, ["sp_a1_intro2"]=true}
	local single_portal_gun = {["sp_a1_intro3"]=true, ["sp_a1_intro4"]=true, ["sp_a1_intro5"]=true, ["sp_a1_intro6"]=true, ["sp_a1_wakeup"]=true}
	if not string.StartWith(map, "sp_") then return end
	if no_portal_gun[map] then
		ply:StripWeapon("weapon_portalgun")
		ply:ConCommand("gp2_portalgun_upgraded 0")
		ply:ConCommand("gp2_portalgun_potato 0")
		if ply.PrintMessage then ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun interdit sur cette map.") end
		return true
	elseif single_portal_gun[map] then
		for _, weapon in ipairs(ply:GetWeapons()) do
			if weapon:GetClass() == "weapon_portalgun" then weapon:UpdatePotatoGun(false) weapon:SetCanFirePortal2(false) end
		end
		ply:ConCommand("gp2_portalgun_upgraded 0")
		ply:ConCommand("gp2_portalgun_potato 0")
		if ply.PrintMessage then ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun limité sur cette map.") end
		return true
	end
	return false
end

concommand.Add("gp2_change_linkage_group_id", function(ply, cmd, args) local wep = ply:GetActiveWeapon() if IsValid(wep) and wep:GetClass() == "weapon_portalgun" then wep:SetLinkageGroup(tonumber(args[1]) or 0) end end)
concommand.Add("upgrade_portalgun", function(ply, cmd, args) if not IsValid(ply) or ForcePortalGunStateForPlayer(ply) then return end ply:Give("weapon_portalgun") local upgraded = false for _, weapon in ipairs(ply:GetWeapons()) do if weapon:GetClass() == "weapon_portalgun" then weapon:UpdatePortalGun() upgraded = true end end if upgraded then ply:ConCommand("gp2_portalgun_upgraded 1") ply:ConCommand("gp2_portalgun_potato 0") if ply.PrintMessage then ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Vous pouvez maintenant tirer les deux types de portails!") end end end, nil, "Améliore votre Portal Gun pour tirer les deux types de portails")
concommand.Add("upgrade_potatogun", function(ply, cmd, args) if not IsValid(ply) or ForcePortalGunStateForPlayer(ply) then return end local upgraded = false for _, weapon in ipairs(ply:GetWeapons()) do if weapon:GetClass() == "weapon_portalgun" then weapon:UpdatePotatoGun(true) upgraded = true end end if upgraded then ply:ConCommand("gp2_portalgun_potato 1") ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Mode Potato Gun activé - GLaDOS vous surveille...") else ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Vous devez d'abord avoir un Portal Gun! Utilisez 'upgrade_portalgun'") end end, nil, "Active le mode Potato sur votre Portal Gun")
concommand.Add("downgrade_potatogun", function(ply, cmd, args) if not IsValid(ply) or ForcePortalGunStateForPlayer(ply) then return end local downgraded = false for _, weapon in ipairs(ply:GetWeapons()) do if weapon:GetClass() == "weapon_portalgun" then weapon:UpdatePotatoGun(false) downgraded = true end end if downgraded then ply:ConCommand("gp2_portalgun_potato 0") ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Mode Potato désactivé!") ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun restauré en mode normal") else ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Aucun Portal Gun trouvé!") end end, nil, "Désactive le mode Potato de votre Portal Gun")
concommand.Add("portalgun_help", function(ply, cmd, args) if not IsValid(ply) then return end ply:PrintMessage(HUD_PRINTCONSOLE, "=== COMMANDES PORTAL GUN GP2-SDK ===") ply:PrintMessage(HUD_PRINTCONSOLE, "upgrade_portalgun - Obtenir/améliorer votre Portal Gun") ply:PrintMessage(HUD_PRINTCONSOLE, "upgrade_potatogun - Activer le mode Potato") ply:PrintMessage(HUD_PRINTCONSOLE, "downgrade_potatogun - Désactiver le mode Potato") ply:PrintMessage(HUD_PRINTCONSOLE, "reset_portalgun - Réinitialiser l'état du Portal Gun") ply:PrintMessage(HUD_PRINTCONSOLE, "portalgun_help - Afficher cette aide") ply:PrintMessage(HUD_PRINTCONSOLE, "===================================") ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Commandes Portal Gun affichées dans la console!") end, nil, "Affiche l'aide des commandes Portal Gun")
concommand.Add("reset_portalgun", function(ply, cmd, args) if not IsValid(ply) or ForcePortalGunStateForPlayer(ply) then return end local reset = false for _, weapon in ipairs(ply:GetWeapons()) do if weapon:GetClass() == "weapon_portalgun" then weapon:UpdatePotatoGun(false) weapon:SetCanFirePortal2(false) reset = true end end if reset then ply:ConCommand("gp2_portalgun_upgraded 0") ply:ConCommand("gp2_portalgun_potato 0") ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun réinitialisé en mode normal!") end end, nil, "Réinitialise le Portal Gun en mode normal")
concommand.Add("remove_portalgun", function(ply, cmd, args) if not IsValid(ply) then return end ForcePortalGunStateForPlayer(ply) end, nil, "Retire le Portal Gun de votre inventaire")
concommand.Add("gp2_portalgun_entityinuse", function(ply, cmd, args) if not IsValid(ply) then return end local wep = ply:GetActiveWeapon() if not IsValid(wep) or wep:GetClass() ~= "weapon_portalgun" then ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Vous n'avez pas de Portal Gun équipé.") return end local ent = wep:GetEntityInUse() local isHoldingSomething = IsValid(ent) if isHoldingSomething then local info = "[GP2] EntityInUse : " .. tostring(ent) .. " (Class: " .. ent:GetClass() .. ")" if ent:GetClass() == "player_pickup" and ent.GetParent and IsValid(ent:GetParent()) then local parent = ent:GetParent() info = info .. " | Pickup cible : " .. tostring(parent) .. " (Class: " .. parent:GetClass() .. ")" end ply:PrintMessage(HUD_PRINTCONSOLE, info) else ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Aucun EntityInUse détecté sur votre Portal Gun.") end ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] isHoldingSomething : " .. tostring(isHoldingSomething)) end, nil, "Affiche l'entité actuellement portée par le Portal Gun et si quelque chose est tenu.")

hook.Add("Think", "GP2_EnforceNoPortalGunMaps", function()
	local no_portal_gun = {["sp_a1_intro1"]=true, ["sp_a1_intro2"]=true}
	local map = game.GetMap()
	if no_portal_gun[map] then for _, ply in ipairs(player.GetAll()) do if IsValid(ply) and ply:HasWeapon("weapon_portalgun") then ply:StripWeapon("weapon_portalgun") end end end
end)

net.Receive("GP2.SyncPortalGunState", function(len, ply)
	local upgraded = net.ReadBool()
	local potato = net.ReadBool()
	local steamid = ply:SteamID()
	GP2_PortalGunStates[steamid] = {upgraded = upgraded, potato = potato}
end)

local function getSurfaceAngle(owner, norm)
	local fwd = owner:GetAimVector()
	local rgh = fwd:Cross(norm)
	fwd:Set(norm:Cross(rgh))
	return fwd:AngleEx(norm)
end

local function gtCheckFunc(e) if not IsValid(e) then return end return ! gtCheck[e:GetClass()] end

local function portalsOverlap(pos, ang, size, ignore)
	if not pos or not isvector(pos) or not size or not isvector(size) then return false, nil end
	local portals = ents.FindByClass("prop_portal")
	local closest, closestDist = nil, math.huge
	for _, p in ipairs(portals) do
		if p ~= ignore and p:GetActivated() then
			local dist = p:GetPos():Distance(pos)
			local minDist = (p:GetSize():Length() + size:Length()) * 0.5 * 0.85
			if dist < minDist and dist < closestDist then closest = p closestDist = dist end
		end
	end
	if closest then return true, closest end
	return false, nil
end

local function setPortalPlacement(owner, portal)
	local ang = Angle()
	local siz = portal:GetSize()
	local pos = owner:GetShootPos()
	local aim = owner:GetAimVector()
	local mul = siz[3] * 2.5

	local tr = PortalManager.TraceLine({start=pos, endpos=pos+aim*99999, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
	local alongRay = ents.FindAlongRay(tr.StartPos, tr.HitPos, -rayHull, rayHull)
	local trSurface = owner:GetEyeTrace()
	if not trSurface or not trSurface.Hit then owner:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Aucun objet pointé.") return end
	local texNameSurface = trSurface.HitTexture or "inconnu"
	owner:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Texture pointée : " .. tostring(texNameSurface))

	local nonPortalableTextures = {["METAL"]=true, ["CONCRETE"]=true, ["displacement"]=true, ["nodraw"]=true, ["ELEVATOR"]=true, ["TOOLS"]=true}
	for k in pairs(nonPortalableTextures) do
		if string.find(texNameSurface, k, 1, true) then owner:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Surface non portalable détectée") return PORTAL_PLACEMENT_BAD_SURFACE, tr end
	end

	for i = 1, #alongRay do
		local ent = alongRay[i]
		if portalsOverlap(pos, ang, siz, portal) then return PORTAL_PLACEMENT_BAD_SURFACE, tr end
		if cleanserCheck[ent:GetClass()] then
			if not (ent.GetEnabled and ent:GetEnabled()) then continue end
			local rayDirection = pos + aim * 99999
			local boundsMin, boundsMax = ent:GetCollisionBounds()
			local hitPos = util.IntersectRayWithOBB(pos, rayDirection, ent:GetPos(), ent:GetAngles(), boundsMin, boundsMax)
			if hitPos then tr.HitPos = hitPos end
			return PORTAL_PLACEMENT_FIZZLER_HIT, tr
		end
	end

	if tr.HitSky then return PORTAL_PLACEMENT_UNKNOWN_SURFACE, tr end

	if math.abs(tr.HitNormal:Dot(ang:Up())) < 0.71 then
		ang:Set(tr.HitNormal:Angle())
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 180)
	else
		ang:Set(getSurfaceAngle(owner, tr.HitNormal))
	end

	local portalHeightHalf = siz[2] * 0.5
	local portalWidthHalf = siz[1] * 0.5
	local portalWidthComplete = siz[1]
	local portalHeightComplete = siz[2]
	local betterPos = Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z)

	local function MakePortalTrace(startPos, offset, normAng)
		local trace = PortalManager.TraceLine({start=startPos, endpos=startPos+offset, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
		if not trace.Hit then
			local newpos = startPos + offset
			local trace2 = PortalManager.TraceLine({start=newpos, endpos=newpos+normAng:Forward()*-2, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
			if not trace2.Hit then
				local trace3 = PortalManager.TraceLine({start=startPos+offset+normAng:Forward()*-2, endpos=startPos+normAng:Forward()*-2, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
				if trace3.Hit then trace.Hit = true trace.Fraction = 1 - trace3.Fraction trace.HitPos = trace3.HitPos trace.HitNormal = trace3.HitNormal end
			else
				trace.Hit = true trace.Fraction = 1 trace.HitPos = trace2.HitPos trace.HitNormal = trace2.HitNormal
			end
		end
		return trace
	end

	local traceRight = MakePortalTrace(tr.HitPos + ang:Right() * portalWidthHalf, -ang:Forward() * 8, ang)
	local validRight = traceRight.Hit and not traceRight.HitSky and traceRight.Entity == nil
	debugDrawPoint(tr.HitPos + ang:Right() * portalWidthHalf, validRight)

	local traceLeft = MakePortalTrace(tr.HitPos - ang:Right() * portalWidthHalf, -ang:Forward() * 8, ang)
	local validLeft = traceLeft.Hit and not traceLeft.HitSky and traceLeft.Entity == nil
	debugDrawPoint(tr.HitPos - ang:Right() * portalWidthHalf, validLeft)

	local traceUp = MakePortalTrace(tr.HitPos + ang:Forward() * portalWidthComplete, -ang:Forward() * 8, ang)
	local validUp = traceUp.Hit and not traceUp.HitSky and traceUp.Entity == nil
	debugDrawPoint(tr.HitPos + ang:Forward() * portalWidthComplete, validUp)

	local traceDown = MakePortalTrace(tr.HitPos - ang:Forward() * portalWidthComplete, -ang:Forward() * 8, ang)
	local validDown = traceDown.Hit and not traceDown.HitSky and traceDown.Entity == nil
	debugDrawPoint(tr.HitPos - ang:Forward() * portalWidthComplete, validDown)

	local downVec = -ang:Up() * 1000
	local function isZeroDist(val) return val == nil or math.abs(val) < 0.0001 end

	local startPosRight = tr.HitPos + ang:Right() * portalWidthHalf
	local traceDownRight = PortalManager.TraceLine({start=startPosRight, endpos=startPosRight+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
	local distRight = traceDownRight.Hit and (startPosRight - traceDownRight.HitPos):Length() or nil

	local startPosLeft = tr.HitPos - ang:Right() * portalWidthHalf
	local traceDownLeft = PortalManager.TraceLine({start=startPosLeft, endpos=startPosLeft+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
	local distLeft = traceDownLeft.Hit and (startPosLeft - traceDownLeft.HitPos):Length() or nil

	local startPosUp = tr.HitPos + ang:Forward() * portalHeightHalf
	local traceDownUp = PortalManager.TraceLine({start=startPosUp, endpos=startPosUp+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
	local distUp = traceDownUp.Hit and (startPosUp - traceDownUp.HitPos):Length() or nil

	local startPosDown = tr.HitPos - ang:Forward() * portalHeightHalf
	local traceDownDown = PortalManager.TraceLine({start=startPosDown, endpos=startPosDown+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
	local distDown = traceDownDown.Hit and (startPosDown - traceDownDown.HitPos):Length() or nil

	local maxTries, tries, step = 20, 0, 15
	while (not isZeroDist(distLeft) or not isZeroDist(distRight)) and tries < maxTries do
		if isZeroDist(distLeft) and not isZeroDist(distRight) then betterPos = betterPos - ang:Right() * step
		elseif isZeroDist(distRight) and not isZeroDist(distLeft) then betterPos = betterPos + ang:Right() * step
		else break end
		startPosRight = betterPos + ang:Right() * portalWidthHalf
		traceDownRight = PortalManager.TraceLine({start=startPosRight, endpos=startPosRight+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
		distRight = traceDownRight.Hit and (startPosRight - traceDownRight.HitPos):Length() or nil
		startPosLeft = betterPos - ang:Right() * portalWidthHalf
		traceDownLeft = PortalManager.TraceLine({start=startPosLeft, endpos=startPosLeft+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
		distLeft = traceDownLeft.Hit and (startPosLeft - traceDownLeft.HitPos):Length() or nil
		tries = tries + 1
	end

	local maxTries, tries, step = 100 ,0, 50
	while (not isZeroDist(distUp) or not isZeroDist(distDown)) and tries < maxTries do
		if isZeroDist(distUp) and not isZeroDist(distDown) then betterPos = betterPos + ang:Forward() * step
		elseif isZeroDist(distDown) and not isZeroDist(distUp) then betterPos = betterPos - ang:Forward() * step
		else break end
		startPosUp = betterPos + ang:Forward() * portalHeightHalf
		traceDownUp = PortalManager.TraceLine({start=startPosUp, endpos=startPosUp+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
		distUp = traceDownUp.Hit and (startPosUp - traceDownUp.HitPos):Length() or nil
		startPosDown = betterPos - ang:Forward() * portalHeightHalf
		traceDownDown = PortalManager.TraceLine({start=startPosDown, endpos=startPosDown+downVec, filter=gtCheckFunc, mask=MASK_SHOT_PORTAL})
		distDown = traceDownDown.Hit and (startPosDown - traceDownDown.HitPos):Length() or nil
		tries = tries + 1
	end

	tr.HitPos = betterPos
	pos:Set(tr.HitNormal)
	pos:Mul(mul)
	pos:Add(betterPos + tr.HitNormal * 0.5)

	local overlap, closest = portalsOverlap(pos, ang, siz, portal)
	if overlap and IsValid(closest) and closest:GetType() ~= portal:GetType() then
		local dir = (pos - closest:GetPos()):Dot(ang:Right())
		local offset = ang:Right() * ((closest:GetSize():Length() + siz:Length()) * 0.47 )
		if dir >= 0 then pos = closest:GetPos() + offset else pos = closest:GetPos() - offset end
	end
	return PORTAL_PLACEMENT_SUCCESFULL, tr, pos, ang
end

function SWEP:Deploy()
	if CLIENT then if SyncPortalGunState then SyncPortalGunState() end return end

	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then
		local saveState = GetConVar("gp2_save_portalgun_state")
		if saveState and saveState:GetBool() then
			local tries = 0
			local function TryApplyState()
				if not IsValid(self) or not IsValid(owner) then return end
				local isUpgraded, isPotato = self:GetSyncedPortalGunState()
				if isUpgraded or isPotato or tries > 10 then
					if isPotato then self:UpdatePotatoGun(true)
					elseif isUpgraded then if not self:GetCanFirePortal2() then self:UpdatePortalGun() end end
				else tries = tries + 1 timer.Simple(0.1, TryApplyState) end
			end
			TryApplyState()
		end
	end

	if not self.GotCustomLinkageGroup then self:SetLinkageGroup(self:GetOwner():EntIndex() - 1) end
	if self:GetIsPotatoGun() then self:SendWeaponAnim(ACT_VM_DEPLOY) self:GetOwner():GetViewModel(0):SetBodygroup(1, 1) self:SetBodygroup(1, 1) end
	local vm0 = owner:GetViewModel(0)
	local vm1 = owner:GetViewModel(1)
	if not IsValid(self.HoldSound) then local filter = RecipientFilter() filter:AddPlayer(owner) self.HoldSound = CreateSound(self, "PortalPlayer.ObjectUse", filter) end
	local seq = vm1:SelectWeightedSequence(ACT_VM_RELEASE)
	if IsValid(vm1) then vm1:SetWeaponModel(self:GetWeaponViewModel(), NULL) if self:GetIsPotatoGun() then vm1:SetBodygroup(1, 1) end end
	if self.GotEntityInUse then self:StopSound("PortalPlayer.ObjectUse") self:EmitSound("PortalPlayer.ObjectUseStop", 0) self:SetEntityInUse(NULL) self.GotEntityInUse = false timer.Simple(0, function() vm0:SendViewModelMatchingSequence(12) end) end
	return true
end

function SWEP:Holster(arguments)
	if SERVER then
		local owner = self:GetOwner()
		local vm1 = owner:GetViewModel(1)
		if not IsValid(owner) then return end
		if IsValid(self.HoldProxy) then self.HoldProxy:Remove() end
		self.HoldProxy = nil
		self.HeldRealObject = nil
		if IsValid(vm1) then vm1:SetWeaponModel(self:GetWeaponViewModel(), self) end
		timer.Simple(0, function()
			if !IsValid(self) then return end
			if IsValid(vm1) and IsValid(owner:GetEntityInUse()) then
				vm1:SendViewModelMatchingSequence(self:SelectWeightedSequence(ACT_VM_PICKUP))
				self.GotEntityInUse = true
				self:EmitSound("PortalPlayer.ObjectUse", 0)
				self:SetEntityInUse(owner:GetEntityInUse())
			else
				vm1:SetWeaponModel(self:GetWeaponViewModel(), NULL)
				if self:GetIsPotatoGun() then vm1:SetBodygroup(1, 1) end
			end
		end)
	end
	return true
end

function SWEP:PlacePortal(type, owner)
	local r, g, b
	if SERVER and IsValid(owner) then
		local colors = GP2.GetPlayerPortalColors(owner)
		if type == PORTAL_TYPE_FIRST then r, g, b = colors.r1, colors.g1, colors.b1 else r, g, b = colors.r2, colors.g2, colors.b2 end
	elseif CLIENT then
		local colors = GP2.GetClientPlayerPortalColors(LocalPlayer())
		if type == PORTAL_TYPE_FIRST then r, g, b = colors.r1, colors.g1, colors.b1 else r, g, b = colors.r2, colors.g2, colors.b2 end
	else
		if type == PORTAL_TYPE_FIRST then r, g, b = 2, 114, 210 else r, g, b = 210, 114, 2 end
	end

	local portal = ents.Create("prop_portal")
	if not IsValid(portal) then return end
	portal:SetPlacedByMap(false)
	portal:SetPortalColor(r, g, b)
	portal:SetType(type or 0)
	portal:SetLinkageGroup(self:GetLinkageGroup())
	if IsValid(owner) then portal:SetOwner(owner) end
	local placementStatus, traceResult, pos, ang
	placementStatus, traceResult, pos, ang = setPortalPlacement(self:GetOwner(), portal)

	if placementStatus == PORTAL_PLACEMENT_BAD_SURFACE or placementStatus == PORTAL_PLACEMENT_FIZZLER_HIT then
		net.Start(GP2.Net.SendPortalPlacementNotPortalable)
		net.WriteVector(traceResult.HitPos)
		net.WriteAngle(traceResult.HitNormal:Angle())
		if IsValid(portal) and portal.GetColorVector then net.WriteVector(portal:GetColorVector() * 0.5) else net.WriteVector(Vector(255, 255, 255) * 0.5) end
		net.Broadcast()
		EmitSound("Portal.fizzle_invalid_surface", traceResult.HitPos, self:EntIndex(), CHAN_AUTO, 1, 60)
		return
	elseif placementStatus == PORTAL_PLACEMENT_UNKNOWN_SURFACE then
		return
	end

	portal:Spawn()
	if CLIENT then local mulRatio = 1.1 / 2.5 local adjustedPos = pos - (pos - traceResult.HitPos) * (1 - mulRatio) portal:SetPos(adjustedPos) else portal:SetPos(pos) end
	portal:SetAngles(ang)
	portal:SetPlacedByMap(true)
	portal:SetActivated(true)
	if SERVER then PortalManager.SetPortal(self:GetLinkageGroup(), portal) end
	self:SetLastPlacedPortal(portal)
	net.Start(GP2.Net.SendPortalPlacementSuccess)
	net.WriteVector(portal:GetPos())
	net.WriteAngle(portal:GetAngles())
	if IsValid(portal) and portal.GetColorVector then net.WriteVector(portal:GetColorVector() * 0.5) else net.WriteVector(Vector(255, 255, 255) * 0.5) end
	net.Broadcast()
end

function SWEP:Think()
	if SERVER then
		local owner = self:GetOwner()
		if not IsValid(owner) then return true end

		local heldEntity = owner:GetEntityInUse()
		if IsValid(heldEntity) and not self.HoldProxy then
			local proxy = ents.Create("prop_physics")
			if IsValid(proxy) then
				proxy:SetModel("models/hunter/plates/plate025x025.mdl")
				proxy:SetPos(heldEntity:GetPos())
				proxy:SetAngles(heldEntity:GetAngles())
				proxy:Spawn()
				proxy:SetNoDraw(true)
				proxy:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				proxy:DrawShadow(false)
				local phys = proxy:GetPhysicsObject()
				if IsValid(phys) then phys:SetMass(1) phys:EnableMotion(false) end
				self.HoldProxy = proxy
				self.HeldRealObject = heldEntity
				owner:DropObject()
				timer.Simple(0.05, function() if IsValid(proxy) and IsValid(owner) then owner:PickupObject(proxy) end end)
			end
		end

		if IsValid(self.HoldProxy) and IsValid(self.HeldRealObject) then
			local proxy = self.HoldProxy
			local realObj = self.HeldRealObject
			if owner:GetEntityInUse() ~= proxy then
				if IsValid(proxy) then proxy:Remove() end
				self.HoldProxy = nil
				self.HeldRealObject = nil
			else
				local phys = realObj:GetPhysicsObject()
				if IsValid(phys) then
					local proxyPos = proxy:GetPos()
					local objPos = realObj:GetPos()
					local dir = proxyPos - objPos
					local dist = dir:Length()
					local strength = math.min(dist * 100, 5000)
					phys:ApplyForceCenter(dir:GetNormalized() * strength)
					local vel = phys:GetVelocity()
					phys:AddVelocity(vel * -0.3)
					if dist < 50 then realObj:SetAngles(proxy:GetAngles()) end
				else
					if IsValid(proxy) then proxy:Remove() end
					self.HoldProxy = nil
					self.HeldRealObject = nil
				end
			end
		end

		if not IsValid(self.HoldProxy) or not IsValid(self.HeldRealObject) then
			if IsValid(self.HoldProxy) then self.HoldProxy:Remove() end
			self.HoldProxy = nil
			self.HeldRealObject = nil
		end

		if CurTime() > self.NextIdleTime and self:GetActivity() ~= ACT_VM_IDLE then self:SendWeaponAnim(ACT_VM_IDLE) end
		if self:GetEntityInUse() ~= owner:GetEntityInUse() then self:SetEntityInUse(owner:GetEntityInUse()) end

		local saveState = GetConVar("gp2_save_portalgun_state")
		if saveState and saveState:GetBool() then
			if not self.NextStateCheck or CurTime() > self.NextStateCheck then
				self.NextStateCheck = CurTime() + 0.5
				local isUpgraded, isPotato = self:GetSyncedPortalGunState()
				if isPotato and not self:GetIsPotatoGun() then self:UpdatePotatoGun(true)
				elseif not isPotato and self:GetIsPotatoGun() then self:UpdatePotatoGun(false)
				elseif isUpgraded and not self:GetCanFirePortal2() and not self:GetIsPotatoGun() then self:UpdatePortalGun()
				elseif not isUpgraded and not isPotato and self:GetCanFirePortal2() then self:SetCanFirePortal2(false) end
			end
		end
	else
		if LocalPlayer():InVehicle() then self.ViewModelFOV = 35 end
	end
	self:NextThink(CurTime())
	return true
end

function SWEP:UpdatePortalGun()
	self:SetCanFirePortal1(true)
	self:SetCanFirePortal2(true)
end

function SWEP:UpdatePotatoGun(into)
	self:SetCanFirePortal1(true)
	self:SetCanFirePortal2(true)
	self:SendWeaponAnim(ACT_VM_HOLSTER)
	self:SetIsPotatoGun(into)
	self:SetNextPrimaryFire(CurTime() + 3.5)
	self:SetNextSecondaryFire(CurTime() + 3.5)
	timer.Simple(2, function()
		self:SendWeaponAnim(ACT_VM_DRAW)
		if into then self:GetOwner():GetViewModel(0):SetBodygroup(1, 1) self:SetBodygroup(1, 1)
		else self:GetOwner():GetViewModel(0):SetBodygroup(1, 0) self:SetBodygroup(1, 0) end
	end)
	self.NextIdleTime = CurTime() + 5
end

function SWEP:OnRemove()
	if SERVER and IsValid(self.HoldProxy) then self.HoldProxy:Remove() end
	self.HoldProxy = nil
	self.HeldRealObject = nil
	self:ClearPortals()
end
