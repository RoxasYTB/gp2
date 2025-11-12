local HOLD_DISTANCE = 100;
local HOLD_CLASS_WHITELIST = {
	prop_physics = true,
	prop_physics_multiplayer = true,
	prop_weighted_cube = true
};
local offsetPlayerZ = 0;
local minimumAimPitch = 40;
if SERVER then
	hook.Add("PlayerUse", "InstantHold_PlayerUse", function(ply, ent)
		for _, e in ipairs(ents.GetAll()) do
			if IsValid(e) and e.HeldBy == ply then
				return;
			end;
		end;
		if IsValid(ent) and IsValid(ply) then
			local distance = (ply:GetPos()):Distance(ent:GetPos());
			local MIN_HOLD_OFFSET = 100;
			HOLD_DISTANCE = 100;
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
				ply:ConCommand("gp2_play_hold_animation");
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
		return true;
	end);
	hook.Add("KeyPress", "InstantHold_DetectUseKey", function(ply, key)
		if not IsValid(ply) or (not ply:IsPlayer()) then
			return;
		end;
		if key == IN_USE then
			local holding = false;
			for _, ent in ipairs(ents.GetAll()) do
				if IsValid(ent) and ent.HeldBy == ply then
					holding = true;
					break;
				end;
			end;
			if holding then
				timer.Simple(0.07, function()
					if IsValid(ply) then
						ply:ConCommand("gp2_dropheld");
					end;
				end);
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
				else
					local aim = ply:EyeAngles();
					if aim.p > minimumAimPitch then
						aim.p = minimumAimPitch;
					end;
					ent:SetOwner(ply);
					local MIN_HOLD_OFFSET = 100;
					local pos = ply:EyePos() + aim:Forward() * 100;
					print("Distance : " .. tostring((ply:GetPos()):Distance(ent:GetPos())));
					local ang = Angle(0, aim.y, 0) + (ent.HoldAngleOffset or Angle(0, 0, 0));
					local mins, maxs = ent:OBBMins(), ent:OBBMaxs();
					local ignoreTrace = false;
					for _, portal in ipairs(ents.FindByClass("prop_portal")) do
						if IsValid(portal) and (portal:GetPos()):Distance(pos) < 10 then
							ignoreTrace = true;
							break;
						end;
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
						if pos.z < (ply:GetPos()).z + offsetPlayerZ then
							pos.z = (ply:GetPos()).z + offsetPlayerZ;
						end;
						if trace.Hit and IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_portal" then
							ignoreTrace = true;
						end;
						if trace.Hit and (not ignoreTrace) then
							pos = trace.HitPos;
						end;
					end;
					ent:SetPos(pos);
					ent:SetAngles(ang);
				end;
			end;
		end;
	end);
	concommand.Add("gp2_dropheld", function(ply)
		ToApplyVelocity = ply:GetVelocity();
		if not IsValid(ply) or (not ply:IsPlayer()) then
			return;
		end;
		for _, ent in ipairs(ents.GetAll()) do
			if IsValid(ent) and ent.HeldBy == ply then
				ent.HeldBy = nil;
				ent:SetNWEntity("InstantHold_HeldBy", NULL);
				ent:SetOwner(nil);
				local phys = ent:GetPhysicsObject();
				if IsValid(phys) then
					phys:EnableMotion(true);
					phys:Wake();
					phys:SetVelocity(ToApplyVelocity);
					ent.HoldVelocity = nil;
				end;
			end;
		end;
	end);
end;
