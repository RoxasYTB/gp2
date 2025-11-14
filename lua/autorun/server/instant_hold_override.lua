local HOLD_DISTANCE = 50;
local HOLD_CLASS_WHITELIST = {
	prop_physics = true,
	prop_physics_multiplayer = true,
	prop_weighted_cube = true
};
local offsetPlayerZ = 0;
local minimumAimPitch = 40;
local isHoldingThing = CreateConVar("isHoldingThing", "0", FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED, "", 0, 1);
if SERVER then
	hook.Add("InitPostEntity", "GP2_CreateHoldPropsOnMapInit", function()
		print("Creating hold props for existing portal guns...");
		for _, ply in ipairs(player.GetAll()) do
			local wep = ply:GetActiveWeapon();
			if IsValid(wep) and wep:GetClass() == "weapon_portalgun" then
				if not IsValid(wep.HoldProp) then
					local prop = ents.Create("prop_physics");
					if IsValid(prop) then
						prop:SetModel("models/props_junk/PopCan01a.mdl");
						prop:SetNoDraw(true);
						prop:SetCollisionGroup(COLLISION_GROUP_NONE);
						prop:SetSolid(SOLID_NONE);
						prop:SetOwner(ply);
						prop:Spawn();
						wep.HoldProp = prop;
						GP2_HoldProps[wep] = prop;
					end;
				end;
			end;
		end;
	end);
	local instantHoldFirstKeyPressDone = false;
	local lastDropTime = {};
	hook.Add("InitPostEntity", "InstantHold_CleanupOnMapStart", function()
		for _, ent in ipairs(ents.GetAll()) do
			if IsValid(ent) then
				ent.HeldBy = nil;
				ent:SetNWEntity("InstantHold_HeldBy", NULL);
			end;
		end;
	end);
	hook.Add("PlayerUse", "InstantHold_PlayerUse", function(ply, ent)
		for _, e in ipairs(ents.GetAll()) do
			if IsValid(e) and e.HeldBy == ply then
				return;
			end;
		end;
		if IsValid(ent) and IsValid(ply) then
			local distance = (ply:GetPos()):Distance(ent:GetPos());
			local MIN_HOLD_OFFSET = 100;
			HOLD_DISTANCE = 50 + MIN_HOLD_OFFSET;
			offsetPlayerZ = (ply:GetPos()).z - (ent:GetPos()).z;
		end;
		if not IsValid(ply) or (not ply:IsPlayer()) then
			return;
		end;
		if not IsValid(ent) then
			return;
		end;
		if not HOLD_CLASS_WHITELIST[ent:GetClass()] then
			return;
		end;
		for _, e in ipairs(ents.GetAll()) do
			if IsValid(e) and e.HeldBy == ply then
				return;
			end;
		end;
		local angles = ply:EyeAngles();
		local phys = ent:GetPhysicsObject();
		ent.HeldBy = ply;
		ent:SetNWEntity("InstantHold_HeldBy", ply);
		local aim = ply:EyeAngles();
		ent.HoldAngleOffset = ent:GetAngles() - Angle(0, aim.y, 0);
		if IsValid(phys) then
			phys:EnableMotion(false);
			phys:Wake();
		end;
		local MIN_HOLD_OFFSET = 20;
		local pos = ply:EyePos() + aim:Forward() * 100;
		local ang = Angle(0, aim.y, 0) + (ent.HoldAngleOffset or Angle(0, 0, 0));
		local mins, maxs = ent:OBBMins(), ent:OBBMaxs();
		local trace = util.TraceHull({
			start = ply:EyePos(),
			endpos = pos,
			mins = mins,
			maxs = maxs,
			filter = {
				ply,
				ent
			}
		});
		if trace.Hit then
			pos = trace.HitPos;
		end;
		ent:SetPos(pos);
		ent:SetAngles(ang);
		isHoldingThing:SetInt(1);
		return true;
	end);
	hook.Add("KeyPress", "InstantHold_DetectUseKey", function(ply, key)
		if not instantHoldFirstKeyPressDone then
			for _, ent in ipairs(ents.GetAll()) do
				if IsValid(ent) then
					ent.HeldBy = nil;
					ent:SetNWEntity("InstantHold_HeldBy", NULL);
				end;
			end;
			instantHoldFirstKeyPressDone = true;
		end;
		if not IsValid(ply) or (not ply:IsPlayer()) then
			return;
		end;
		if key == IN_USE then
			local now = CurTime();
			if lastDropTime[ply] and now - lastDropTime[ply] < 0.5 then
				return;
			end;
			local holding = false;
			local heldEnt = nil;
			for _, ent in ipairs(ents.GetAll()) do
				if IsValid(ent) and ent.HeldBy == ply then
					holding = true;
					heldEnt = ent;
					break;
				end;
			end;
			if not holding then
				for _, ent in ipairs(ents.GetAll()) do
					if IsValid(ent) and ent:GetNWEntity("InstantHold_HeldBy") == ply then
						holding = true;
						heldEnt = ent;
						break;
					end;
				end;
			end;
			if holding and IsValid(heldEnt) then
				print("Player is holding an entity, dropping it now.");
				lastDropTime[ply] = now;
				if IsValid(ply) then
					isHoldingThing:SetInt(0);
					timer.Simple(0.3, function()
						if IsValid(ply) then
							ply:ConCommand("gp2_dropheld");
							ply:ConCommand("gp2_stop_hold_animation");
							heldEnt.HeldBy = nil;
							heldEnt:SetNWEntity("InstantHold_HeldBy", NULL);
							heldEnt:SetOwner(nil);
							local phys = heldEnt:GetPhysicsObject();
							if IsValid(phys) then
								phys:EnableMotion(true);
								phys:Wake();
								phys:EnableGravity(true);
							end;
						end;
					end);
				end;
			else
				print("Player is not holding any entity");
				if holding and IsValid(heldEnt) then
					ply:ConCommand("gp2_play_hold_animation ");
				end;
			end;
		end;
	end);
	hook.Add("Think", "InstantHold_TrackPosition", function()
		for _, ent in ipairs(ents.GetAll()) do
			if IsValid(ent) and IsValid(ent.HeldBy) then
				local ply = ent.HeldBy;
				if not ply:Alive() then
					ent.HeldBy = nil;
					local phys = ent:GetPhysicsObject();
					if IsValid(phys) then
						phys:EnableMotion(true);
						phys:Wake();
					end;
					ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
					isHoldingThing:SetInt(0);
				else
					local aim = ply:EyeAngles();
					if aim.p > minimumAimPitch then
						aim.p = minimumAimPitch;
					end;
					ent:SetOwner(ply);
					local MIN_HOLD_OFFSET = 100;
					local pos = ply:EyePos() + aim:Forward() * 75;
					local ang = Angle(0, aim.y, 0) + (ent.HoldAngleOffset or Angle(0, 0, 0));
					local mins, maxs = ent:OBBMins(), ent:OBBMaxs();
					local ignoreTrace = false;
					for _, portal in ipairs(ents.FindByClass("prop_portal")) do
						if IsValid(portal) and (portal:GetPos()):Distance(pos) < 10 then
							ignoreTrace = true;
							break;
						end;
					end;
					if pos.z < (ply:GetPos()).z + 18 then
						pos.z = (ply:GetPos()).z + 18;
					end;
					if not ignoreTrace then
						local trace = util.TraceHull({
							start = ply:EyePos(),
							endpos = pos,
							mins = mins,
							maxs = maxs,
							filter = {
								ply,
								ent
							}
						});
						ignoreTrace = false;
						if trace.Hit and IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_portal" then
							ignoreTrace = true;
						end;
						if trace.Hit and (not ignoreTrace) then
							pos = trace.HitPos;
						end;
					end;
					ent:SetPos(pos);
					ent:SetAngles(Angle(0, (ply:EyeAngles()).y, 0));
					if ent:GetClass() == "npc_personality_core" then
						ent:SetMoveType(MOVETYPE_VPHYSICS);
					end;
				end;
			end;
		end;
	end);
	concommand.Add("gp2_dropheld", function(ply)
		local ToApplyVelocity = ply:GetVelocity();
		if not IsValid(ply) or (not ply:IsPlayer()) then
			return;
		end;
		for _, ent in ipairs(ents.GetAll()) do
			if IsValid(ent) and ent.HeldBy == ply then
				ent.HeldBy = nil;
				ent:SetNWEntity("InstantHold_HeldBy", NULL);
				ent:SetOwner(nil);
				ent:SetCollisionGroup(COLLISION_GROUP_NONE);
				ent:SetMoveType(MOVETYPE_VPHYSICS);
				ent:SetSolid(SOLID_VPHYSICS);
				local phys = ent:GetPhysicsObject();
				if IsValid(phys) then
					phys:EnableMotion(true);
					phys:Wake();
					phys:SetVelocity(ToApplyVelocity);
					ent.HoldVelocity = nil;
				end;
				isHoldingThing:SetInt(0);
			end;
		end;
	end);
end;
