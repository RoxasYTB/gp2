local HOLD_DISTANCE = 100;
local HOLD_CLASS_WHITELIST = {
	prop_physics = true,
	prop_physics_multiplayer = true,
	prop_weighted_cube = true
};
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
			HOLD_DISTANCE = math.max(distance, MIN_HOLD_OFFSET);
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
		ent:SetParent(nil);
		ent:SetCollisionGroup(0);
		if ent.SetSolid then
			ent:SetSolid(6);
		end;
		if ent.SetMoveType then
			ent:SetMoveType(6);
		end;
		local MIN_HOLD_OFFSET = 20;
		local pos = ply:EyePos() + aim:Forward() * math.max(HOLD_DISTANCE, MIN_HOLD_OFFSET);
		local ang = Angle(0, aim.y, 0) + (ent.HoldAngleOffset or Angle(0, 0, 0));
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
				timer.Simple(0.05, function()
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
					ent:SetCollisionGroup(COLLISION_GROUP_NONE);
				else
					local aim = ply:EyeAngles();
					print("Yaw:", aim.y, "Pitch:", aim.p, "Raw:", aim);
					if aim.p > 60 then
						aim.p = 60;
					end;
					local MIN_HOLD_OFFSET = 20;
					local pos = ply:EyePos() + aim:Forward() * math.max(HOLD_DISTANCE, MIN_HOLD_OFFSET);
					local ang = Angle(0, aim.y, 0) + (ent.HoldAngleOffset or Angle(0, 0, 0));
					offsetPlayerZ = 26;
					if pos.z < (ply:GetPos()).z + offsetPlayerZ then
						pos.z = (ply:GetPos()).z + offsetPlayerZ;
					end;
					ent:SetPos(pos);
					ent:SetAngles(ang);
					ent:SetCollisionGroup(0);
					if ent.SetSolid then
						ent:SetSolid(6);
					end;
					if ent.SetMoveType then
						ent:SetMoveType(6);
					end;
					local phys = ent:GetPhysicsObject();
				end;
			end;
		end;
	end);
	concommand.Add("gp2_dropheld", function(ply)
		if not IsValid(ply) or (not ply:IsPlayer()) then
			return;
		end;
		for _, ent in ipairs(ents.GetAll()) do
			if IsValid(ent) and ent.HeldBy == ply then
				ent.HeldBy = nil;
				ent:SetNWEntity("InstantHold_HeldBy", NULL);
				local phys = ent:GetPhysicsObject();
				if IsValid(phys) then
					phys:EnableMotion(true);
					phys:Wake();
					if ent.HoldVelocity then
						phys:SetVelocity(ply.HoldVelocity);
						ent.HoldVelocity = nil;
					end;
				end;
				print("Dropping held prop via command.");
				ent:SetCollisionGroup(COLLISION_GROUP_NONE);
			end;
		end;
	end);
end;
