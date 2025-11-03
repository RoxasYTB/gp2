if SERVER then
	util.AddNetworkString("gp2_first_door_pos")
end

if CLIENT then
    local playerPos = Vector(0,0,0)
    local doorPos = nil
    net.Receive("gp2_first_door_pos", function()
        doorPos = net.ReadVector()
    end)
    local function UpdatePositions()
        local ply = LocalPlayer()
        if IsValid(ply) then
            playerPos = ply:GetPos()
        end
    end
    timer.Create("gp2_hud_update_pos", 0.3, 0, UpdatePositions)
    hook.Add("HUDPaint", "gp2_hud_show_pos", function()
        draw.SimpleText("Player: " .. tostring(playerPos), "DermaDefault", 20, 20, Color(255,255,255), 0, 0)
        if doorPos then
            draw.SimpleText("First Door: " .. tostring(doorPos), "DermaDefault", 20, 40, Color(200,200,255), 0, 0)
        else
            draw.SimpleText("First Door: (non détectée)", "DermaDefault", 20, 40, Color(200,200,255), 0, 0)
        end
    end)
end
local function SpawnDoorTriggers()
	if not firstDoorEntIndex then return end;
	local door = Entity(firstDoorEntIndex);
	if not IsValid(door) then return end;
	local pos = firstDoorPos or door:GetPos();
	local ang = door:GetAngles();
	local forward = ang:Forward();
	local entFront = ents.Create("prop_door_trigger");
	if IsValid(entFront) then
		entFront:SetPos(pos + forward * 48);
		entFront:SetAngles(ang);
		entFront.DoorTriggerType = "open";
		entFront:Spawn();
	end;
	local entBack = ents.Create("prop_door_trigger");
	if IsValid(entBack) then
		entBack:SetPos(pos - forward * 48);
		entBack:SetAngles(ang);
		entBack.DoorTriggerType = "close";
		entBack:Spawn();
	end;
end;

hook.Add("Initialize", "InitFirstDoorAndTriggers", function()
	timer.Simple(0, function()
		RunConsoleCommand("close_first_door")
		timer.Simple(0.1, function()
			SpawnDoorTriggers()
		end)
	end)
end)
// hook.Add("AcceptInput", "CleanupOnCloseRelay", function(ent, input)
// 	if ent:GetClass() == "logic_relay" and ent:GetName() == "door_0-door_close_relay" and input == "Trigger" then
// 		RunConsoleCommand("close_first_door");
// 	end;
// end);
// hook.Add("AcceptInput", "CleanupOnOpenRelay", function(ent, input)
// 	if ent:GetClass() == "logic_relay" and ent:GetName() == "door_0-door_open_relay" and input == "Trigger" then
// 		RunConsoleCommand("open_first_door");
// 	end;
// end);
local firstDoorEntIndex = nil;
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
		relay:Fire("EnableRefire");
		relay:Fire("Trigger");
	end;
	local trigger = (ents.FindByName("door_0-player_in_door_trigger"))[1];
	if IsValid(trigger) then
		trigger:Fire("Enable");
	end;
	local doors = ents.FindByClass("prop_testchamber_door");
	local door = doors[1];
	if IsValid(door) then
		firstDoorEntIndex = door:EntIndex()
		firstDoorPos = door:GetPos()
		if SERVER then
			net.Start("gp2_first_door_pos")
			net.WriteVector(firstDoorPos)
			net.Broadcast()
		end
	end
	ResetDoorEntities();
end;
local triggersSpawned = false
local function SpawnDoorTriggers()
	if triggersSpawned then return end;
	if not firstDoorEntIndex then return end;
	local door = Entity(firstDoorEntIndex);
	if not IsValid(door) then return end;
	local pos = door:GetPos();
	local ang = door:GetAngles();
	local forward = ang:Forward();
	local entFront = ents.Create("prop_door_trigger");
	if IsValid(entFront) then
		entFront:SetPos(pos + forward * 48);
		entFront:SetAngles(ang);
		entFront.DoorTriggerType = "open";
		entFront:Spawn();
	end;
	local entBack = ents.Create("prop_door_trigger");
	if IsValid(entBack) then
		entBack:SetPos(pos - forward * 48);
		entBack:SetAngles(ang);
		entBack.DoorTriggerType = "close";
		entBack:Spawn();
	end;
	triggersSpawned = true
end;

concommand.Add("open_first_door", function()
	OpenFirstDoor();
	SpawnDoorTriggers();
end);
concommand.Add("close_first_door", function()
	CloseFirstDoor();
end);
hook.Add("AcceptInput", "OpenFirstDoorOnTriggerMultiple", function(ent, input)
	if (ent:GetClass() == "trigger_multiple" or ent:GetClass() == "trigger_once") and input == "Trigger" and ent:GetName() == "door_0-player_in_door_trigger" then
		OpenFirstDoor();
	end;
end);
