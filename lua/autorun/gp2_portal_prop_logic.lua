function GP2_ApplyPortalBelowImpulse(ent, phys)
	if not IsValid(phys) or (not phys:IsMotionEnabled()) then
		return;
	end;
	local portals = ents.FindInSphere(ent:GetPos(), 80);
	local portalBelow = false;
	for _, portal in ipairs(portals) do
		if portal ~= ent and portal:GetClass() == "prop_portal" then
			if (portal:GetPos()).z < (ent:GetPos()).z then
				portalBelow = true;
				break;
			end;
		end;
	end;
	if portalBelow then
		local vel = phys:GetVelocity();
		if vel.x == 0 and vel.y == 0 and vel.z == 0 then
			phys:SetVelocityInstantaneous(Vector(0, 0, -100));
		end;
	end;
end;
