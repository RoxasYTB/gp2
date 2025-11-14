if game.GetMap() == "sp_a1_intro2" then
	hook.Add("AcceptInput", "FixPortalLogic_FirstPressAlways", function(ent, input, activator, caller, value)
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
		local triggered = GetConVar("gp2_last_portal_triggered") and (GetConVar("gp2_last_portal_triggered")):GetString() or "";
		if input ~= "Trigger" then
			return;
		end;
		local portals = {
			"portal_blue_1",
			"portal_blue_2",
			"portal_blue_3"
		};
		if triggered ~= "" and string.find(triggered, "emit") then
			for _, name in ipairs(portals) do
				for _, p in ipairs(ents.FindByName(name)) do
					if IsValid(p) then
						p:Remove();
					end;
				end;
				local p = ents.Create("prop_portal");
				if IsValid(p) then
					p:SetName(name);
					p:Spawn();
					p:Fire("SetActivatedState", "1", 0);
				end;
			end;
		end;
		local relays = {
			"blue_1_portal_activate_rl",
			"blue_2_portal_deactivate_rl",
			"blue_3_portal_deactivate_rl",
			"logic_make_blue_1",
			"logic_make_blue_2",
			"logic_make_blue_3"
		};
		for _, name in ipairs(relays) do
			for _, e in ipairs(ents.FindByName(name)) do
				if IsValid(e) then
					e:Fire("EnableRefire", "", 0);
				end;
			end;
		end;
	end);
end;
