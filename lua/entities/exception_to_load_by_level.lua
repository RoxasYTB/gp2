if SERVER then
	hook.Add("InitPostEntity", "GP2_DisableFuncBrushCollision_sp_a1_intro6", function()
		if game.GetMap() ~= "sp_a1_intro6" then
			return;
		end;
		for _, ent in ipairs(ents.FindByClass("func_brush")) do
			if ent:EntIndex() == 72 then
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
			end;
		end;
	end);
end;

if SERVER then
	local function FixPortalPosition()
		if game.GetMap() ~= "sp_a1_intro7" then
			return;
		end;
		for _, ent in ipairs(ents.FindByClass("prop_portal")) do
			local portalType = ent.GetType and ent:GetType() or ent.PortalType or nil;
			if portalType == 1 then
				local pos = ent:GetPos();
				local ang = ent:GetAngles();
				local posStr = string.format("%.6f %.6f %.6f", pos.x, pos.y, pos.z);
				local angStr = string.format("%.3f %.3f %.3f", ang.p, ang.y, ang.r);
				if posStr == "-478.159180 -231.220947 1258.355347" and angStr == "-14.533 -158.825 -6.802" then
					ent:SetAngles(Angle(-14.436, -151.951, -1.724));
					local getRight = ent:GetRight();
					ent:SetPos(ent:GetPos() + getRight * 3.5);
				end;
			end;
		end;
	end;
	timer.Create("GP2_FixPortalPosition", 0.2, 0, FixPortalPosition);
end;