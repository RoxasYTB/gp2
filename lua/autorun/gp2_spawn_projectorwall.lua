if SERVER then
	util.AddNetworkString("gp2_spawn_projectorwall");
	concommand.Add("gp2_spawn_projectorwall", function(ply, cmd, args)
		if not IsValid(ply) then
			return;
		end;
		local pos = ply:GetPos() + ply:GetForward() * 64 + Vector(0, 0, 32);
		local ang = ply:EyeAngles();
		local snap = {
			0,
			90,
			180,
			270
		};
		local closest = snap[1];
		local minDiff = math.abs(ang.p - snap[1]);
		for i = 2, #snap do
			local diff = math.abs(ang.p - snap[i]);
			if diff < minDiff then
				minDiff = diff;
				closest = snap[i];
			end;
		end;
		ang.p = closest;
		local ent = ents.Create("prop_wall_projector");
		if not IsValid(ent) then
			return;
		end;
		ent:SetPos(pos);
		ent:SetAngles(ang);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(ply);
		ply:ChatPrint("Projector wall spawné !");
	end);
end;
