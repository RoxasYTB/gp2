hook.Add("AcceptInput", "FixPortalLogic_FirstPressAlways", function(ent, input, activator, caller, value)
	print("Input received:", input, "for" .. tostring(ent:GetName()));
	if not IsValid(ent) then
		return;
	end;
	if input == "Skin" then
		if not GetConVar("gp2_last_portal_triggered") then
			CreateConVar("gp2_last_portal_triggered", ent:GetName(), FCVAR_NOTIFY);
		else
			(GetConVar("gp2_last_portal_triggered")):SetString(ent:GetName());
		end;
	end;
	if input ~= "Trigger" then
		return;
	end;
	local portals = {
		"portal_blue_1",
		"portal_blue_2",
		"portal_blue_3"
	};
	for _, name in ipairs(portals) do
		local old_pos, old_ang = nil, nil;
		for _, p in ipairs(ents.FindByName(name)) do
			if IsValid(p) then
				old_pos = p:GetPos();
				old_ang = p:GetAngles();
				p:Remove();
			end;
		end;
		local p = ents.Create("prop_portal");
		print("Creating portal entity with name:", name);
		if IsValid(p) then
			p:SetName(name);
			p:Spawn();
			p:Fire("SetActivatedState", "0", 0);
		end;
	end;
	if ent:GetName() ~= "portal_blue_1" and input == "SetActivatedState" then
		return;
	end;
	local relays = {
		"blue_1_portal_activate_rl",
		"blue_2_portal_deactivate_rl",
		"blue_3_portal_deactivate_rl",
		"logic_make_blue_1"
	};
	for _, name in ipairs(relays) do
		for _, e in ipairs(ents.FindByName(name)) do
			if IsValid(e) then
				print("Enabling relay:", e);
				e:Fire("EnableRefire", "", 0);
			end;
		end;
	end;
end);
