local function ResetDoorEntities()
	local relay = (ents.FindByName("door_0-door_open_relay"))[1];
	if IsValid(relay) then
		relay:Fire("Enable");
		relay:Fire("EnableRefire");
	end;
	local trigger = (ents.FindByName("door_0-player_in_door_trigger"))[1];
	if IsValid(trigger) then
		trigger:Fire("Enable");
	end;
end;
local function OpenFirstDoor()
	local relay = (ents.FindByName("door_0-door_open_relay"))[1];
	if IsValid(relay) then
		relay:Fire("EnableRefire");
		relay:Fire("Trigger");
	end;
	ResetDoorEntities();
end;
local function CloseFirstDoor()
	local relay = (ents.FindByName("door_0-door_close_relay"))[1];
	if IsValid(relay) then
		print("Désactivation du trigger pour la porte 0");
		relay:Fire("EnableRefire");
		relay:Fire("Trigger");
	end;
	local trigger = (ents.FindByName("door_0-player_in_door_trigger"))[1];
	if IsValid(trigger) then
		print("Désactivation du trigger pour la porte 0");
		trigger:Fire("Enable");
	end;
	ResetDoorEntities();
end;
concommand.Add("open_first_door", function()
	print("Commande open_first_door appelée");
	OpenFirstDoor();
end);
concommand.Add("close_first_door", function()
	CloseFirstDoor();
end);
hook.Add("AcceptInput", "OpenFirstDoorOnTriggerMultiple", function(ent, input)
	if (ent:GetClass() == "trigger_multiple" or ent:GetClass() == "trigger_once") and input == "Trigger" and ent:GetName() == "door_0-player_in_door_trigger" then
		print("Trigger activé, ouverture de la première porte");
		OpenFirstDoor();
	end;
end);
