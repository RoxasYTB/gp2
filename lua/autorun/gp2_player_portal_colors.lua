if SERVER then
	AddCSLuaFile();
	GP2.PlayerPortalColors = GP2.PlayerPortalColors or {};
	util.AddNetworkString("GP2_UpdatePlayerPortalColors");
	util.AddNetworkString("GP2_RequestPlayerPortalColors");
	local AVAILABLE_COLORS = {
		"red",
		"orange",
		"yellow",
		"lime",
		"green",
		"cyan",
		"lightblue",
		"blue",
		"darkblue",
		"magenta",
		"pink",
		"black",
		"white",
		"gray",
		"darkgray"
	};
	local function GetDefaultColorNames(ply)
		local players = player.GetAll();
		table.sort(players, function(a, b)
			return a:EntIndex() < b:EntIndex();
		end);
		for i, p in ipairs(players) do
			if p == ply then
				if i == 1 then
					return "blue", "orange";
				else
					local idx1 = (i - 2) % ((#AVAILABLE_COLORS) - 1) + 2;
					local idx2 = (i - 1) % ((#AVAILABLE_COLORS) - 1) + 1;
					return AVAILABLE_COLORS[idx1], AVAILABLE_COLORS[idx2];
				end;
			end;
		end;
		return "blue", "orange";
	end;
	function GP2.GetPlayerPortalColors(ply)
		if not IsValid(ply) then
			return {
				color1 = "blue",
				color2 = "orange"
			};
		end;
		if not GP2.PlayerPortalColors[ply:SteamID()] then
			local c1, c2 = GetDefaultColorNames(ply);
			GP2.PlayerPortalColors[ply:SteamID()] = {
				color1 = c1,
				color2 = c2
			};
		end;
		return GP2.PlayerPortalColors[ply:SteamID()];
	end;
	function GP2.SetPlayerPortalColors(ply, color1, color2)
		if not IsValid(ply) then
			return;
		end;
		GP2.PlayerPortalColors[ply:SteamID()] = {
			color1 = color1 or "blue",
			color2 = color2 or "orange"
		};
		net.Start("GP2_UpdatePlayerPortalColors");
		net.WriteString(ply:SteamID());
		net.WriteString(GP2.PlayerPortalColors[ply:SteamID()].color1);
		net.WriteString(GP2.PlayerPortalColors[ply:SteamID()].color2);
		net.Broadcast();
	end;
	hook.Add("PlayerInitialSpawn", "GP2_InitPlayerColors", function(ply)
		timer.Simple(1, function()
            if IsValid(ply) then
                local c1, c2 = GetDefaultColorNames(ply)
                ply:ConCommand("global_pc1 " .. ply:Nick() .. " " .. c1)
                ply:ConCommand("global_pc2 " .. ply:Nick() .. " " .. c2)
			end;
		end);
	end);
	net.Receive("GP2_RequestPlayerPortalColors", function(len, ply)
		local colors = GP2.GetPlayerPortalColors(ply);
		net.Start("GP2_UpdatePlayerPortalColors");
		net.WriteString(ply:SteamID());
		net.WriteString(colors.color1);
		net.WriteString(colors.color2);
		net.Send(ply);
	end);
else
	GP2.ClientPlayerPortalColors = GP2.ClientPlayerPortalColors or {};
	function GP2.GetClientPlayerPortalColors(ply)
		if not IsValid(ply) then
			return {
				color1 = "blue",
				color2 = "orange"
			};
		end;
		local steamid = ply:SteamID();
		if GP2.ClientPlayerPortalColors[steamid] then
			return GP2.ClientPlayerPortalColors[steamid];
		end;
		if ply == LocalPlayer() then
			net.Start("GP2_RequestPlayerPortalColors");
			net.SendToServer();
		end;
		return {
			color1 = "blue",
			color2 = "orange"
		};
	end;
	net.Receive("GP2_UpdatePlayerPortalColors", function()
		local steamid = net.ReadString();
		local color1 = net.ReadString();
		local color2 = net.ReadString();
		GP2.ClientPlayerPortalColors[steamid] = {
			color1 = color1,
			color2 = color2
		};
	end);
end;
