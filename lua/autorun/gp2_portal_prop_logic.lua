function GP2_ApplyPortalBelowImpulse(ent, phys)
	if not IsValid(phys) or (not phys:IsMotionEnabled()) then
		return;
	end;
	local portals = ents.FindInSphere(ent:GetPos(), 40);
	local portalBelow = false;
	for _, portal in ipairs(portals) do
		if portal ~= ent and portal:GetClass() == "prop_portal" then
			print("Found portal below entity: " .. tostring((portal:GetPos()).z));
			print("Entity: " .. tostring((ent:GetPos()).z));
			portalBelow = true;
			break;
		end;
	end;
	if portalBelow then
		print("Applying downward impulse to entity above portal");
		local vel = phys:GetVelocity();
		if vel.x == 0 and vel.y == 0 and vel.z == 0 then
			local shake = Vector(0, 0, math.Rand(24, 50));
			phys:AddVelocity(shake);
		end;
	end;
end;
