local PORTAL_COLORS = {
	red = 0,
	orange = 1,
	yellow = 2,
	lime = 3,
	green = 4,
	cyan = 5,
	lightblue = 6,
	blue = 7,
	darkblue = 8,
	magenta = 9,
	pink = 10,
	black = 11,
	white = 12,
	gray = 13,
	darkgray = 14,
	rouge = 0,
	jaune = 2,
	vert = 4,
	bleu = 7,
	rose = 10,
	blanc = 12,
	gris = 13,
	noir = 11,
	grey = 13,
	lightblue = 6,
	darkblue = 8,
	darkgray = 14
};
local COLOR_NAMES = {
	[0] = "Red",
	[1] = "Orange",
	[2] = "Yellow",
	[3] = "Lime",
	[4] = "Green",
	[5] = "Cyan",
	[6] = "Light Blue",
	[7] = "Blue",
	[8] = "Dark Blue",
	[9] = "Magenta",
	[10] = "Pink",
	[11] = "Black",
	[12] = "White",
	[13] = "Gray",
	[14] = "Dark Gray"
};
local DISPLAY_COLORS = {
	[0] = Color(180, 40, 40),
	[1] = Color(210, 114, 2),
	[2] = Color(200, 200, 60),
	[3] = Color(90, 180, 30),
	[4] = Color(40, 180, 40),
	[5] = Color(40, 180, 180),
	[6] = Color(70, 120, 180),
	[7] = Color(2, 114, 210),
	[8] = Color(20, 50, 120),
	[9] = Color(180, 40, 180),
	[10] = Color(180, 80, 120),
	[11] = Color(30, 30, 30),
	[12] = Color(200, 200, 200),
	[13] = Color(90, 90, 90),
	[14] = Color(60, 60, 60)
};
local function ShowPortalColorsHelp(ply)
	if not IsValid(ply) then
		return;
	end;
	ply:PrintMessage(HUD_PRINTTALK, "=== COULEURS DES PORTAILS DISPONIBLES ===");
	ply:PrintMessage(HUD_PRINTTALK, "Utilisez: portal_color1 <couleur> ou portal_color2 <couleur>");
	ply:PrintMessage(HUD_PRINTTALK, "");
	for i = 0, 14 do
		local colorName = COLOR_NAMES[i];
		if colorName then
			local msg = string.format("[%d] %s", i, colorName);
			ply:PrintMessage(HUD_PRINTTALK, msg);
		end;
	end;
	ply:PrintMessage(HUD_PRINTTALK, "");
	ply:PrintMessage(HUD_PRINTTALK, "Exemples:");
	ply:PrintMessage(HUD_PRINTTALK, "  portal_color1 blue");
	ply:PrintMessage(HUD_PRINTTALK, "  portal_color2 orange");
	ply:PrintMessage(HUD_PRINTTALK, "  portal_color1 green");
end;
if CLIENT then
	if not ConVarExists("gp2_crosshair_color_1") then
		CreateClientConVar("gp2_crosshair_color_1", "0", true, false, "Couleur de la crosshair du portail 1 (numéro)");
	end;
	if not ConVarExists("gp2_crosshair_color_2") then
		CreateClientConVar("gp2_crosshair_color_2", "1", true, false, "Couleur de la crosshair du portail 2 (numéro)");
	end;
end;
local function ChangePortalColor1(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	if not args[1] or args[1] == "" or args[1] == "help" or args[1] == "aide" then
		ShowPortalColorsHelp(ply);
		return;
	end;
	local colorInput = string.lower(args[1]);
	local colorNumber = PORTAL_COLORS[colorInput];
	if colorNumber then
		local colorName = COLOR_NAMES[colorNumber];
		local col = DISPLAY_COLORS[colorNumber] or Color(255, 255, 255);
		if SERVER then
			local currentColors = GP2.GetPlayerPortalColors(ply);
			local darkCol = GP2_GetPortalDisplayColorDarkened(colorNumber);
			GP2.SetPlayerPortalColors(ply, darkCol.r, darkCol.g, darkCol.b, currentColors.r2, currentColors.g2, currentColors.b2);
		else
			RunConsoleCommand("gp2_crosshair_color_1", tostring(colorNumber));
			RunConsoleCommand("gp2_portal_color1", string.format("%d %d %d", col.r, col.g, col.b));
		end;
		ply:PrintMessage(HUD_PRINTTALK, string.format("Couleur du portail 1 changée en: %s (%d)", colorName, colorNumber));
	else
		ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Tapez 'portal_color1 help' pour voir les couleurs disponibles.");
	end;
end;
local function ChangePortalColor2(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	if not args[1] or args[1] == "" or args[1] == "help" or args[1] == "aide" then
		ShowPortalColorsHelp(ply);
		return;
	end;
	local colorInput = string.lower(args[1]);
	local colorNumber = PORTAL_COLORS[colorInput];
	if colorNumber then
		local colorName = COLOR_NAMES[colorNumber];
		local col = DISPLAY_COLORS[colorNumber] or Color(255, 255, 255);
		if SERVER then
			local currentColors = GP2.GetPlayerPortalColors(ply);
			local darkCol = GP2_GetPortalDisplayColorDarkened(colorNumber);
			GP2.SetPlayerPortalColors(ply, currentColors.r1, currentColors.g1, currentColors.b1, darkCol.r, darkCol.g, darkCol.b);
		else
			RunConsoleCommand("gp2_crosshair_color_2", tostring(colorNumber));
			RunConsoleCommand("gp2_portal_color2", string.format("%d %d %d", col.r, col.g, col.b));
		end;
		ply:PrintMessage(HUD_PRINTTALK, string.format("Couleur du portail 2 changée en: %s (%d)", colorName, colorNumber));
	else
		ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Tapez 'portal_color2 help' pour voir les couleurs disponibles.");
	end;
end;
local function ShowCurrentColors(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	local color1 = 0;
	local color2 = 1;
	if CLIENT and ply == LocalPlayer() then
		color1 = (GetConVar("gp2_crosshair_color_1")):GetInt();
		color2 = (GetConVar("gp2_crosshair_color_2")):GetInt();
	end;
	local name1 = COLOR_NAMES[color1] or "Inconnue";
	local name2 = COLOR_NAMES[color2] or "Inconnue";
	ply:PrintMessage(HUD_PRINTTALK, "=== COULEURS ACTUELLES DES PORTAILS ===");
	ply:PrintMessage(HUD_PRINTTALK, string.format("Portail 1: %s (%d)", name1, color1));
	ply:PrintMessage(HUD_PRINTTALK, string.format("Portail 2: %s (%d)", name2, color2));
end;
concommand.Add("portal_color1", ChangePortalColor1, nil, "Change la couleur du portail 1 (ex: portal_color1 blue)");
concommand.Add("portal_color2", ChangePortalColor2, nil, "Change la couleur du portail 2 (ex: portal_color2 orange)");
concommand.Add("portal_colors", ShowCurrentColors, nil, "Affiche les couleurs actuelles des portails");
concommand.Add("portal_colors_help", ShowPortalColorsHelp, nil, "Affiche l'aide des couleurs de portails");
local function ChangeLocalPortalColor1(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	if not args[1] or args[1] == "" or args[1] == "help" or args[1] == "aide" then
		ShowPortalColorsHelp(ply);
		return;
	end;
	local colorInput = string.lower(args[1]);
	if PORTAL_COLORS[colorInput] then
		GP2.SetPlayerPortalColors(ply, colorInput, (GP2.GetPlayerPortalColors(ply)).color2);
		ply:PrintMessage(HUD_PRINTTALK, string.format("Votre couleur de portail 1 changée en: %s", colorInput));
	else
		ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Tapez 'pc1 help' pour voir les couleurs disponibles.");
	end;
end;
local function ChangeLocalPortalColor2(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	if not args[1] or args[1] == "" or args[1] == "help" or args[1] == "aide" then
		ShowPortalColorsHelp(ply);
		return;
	end;
	local colorInput = string.lower(args[1]);
	local colorNumber = PORTAL_COLORS[colorInput];
	if colorNumber then
		local colorName = COLOR_NAMES[colorNumber];
		local col = DISPLAY_COLORS[colorNumber] or Color(255, 255, 255);
		if SERVER then
			local currentColors = GP2.GetPlayerPortalColors(ply);
			local darkCol = GP2_GetPortalDisplayColorDarkened(colorNumber);
			GP2.SetPlayerPortalColors(ply, currentColors.r1, currentColors.g1, currentColors.b1, darkCol.r, darkCol.g, darkCol.b);
			ply:PrintMessage(HUD_PRINTTALK, string.format("Votre couleur de portail 2 changée en: %s", colorName));
		end;
	else
		ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Tapez 'pc2 help' pour voir les couleurs disponibles.");
	end;
end;
local function ChangeGlobalPortalColor1(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	if not args[1] or (not args[2]) or args[1] == "help" then
		ply:PrintMessage(HUD_PRINTTALK, "Usage: global_pc1 <nom_joueur> <couleur>");
		ply:PrintMessage(HUD_PRINTTALK, "Exemple: global_pc1 Player1 red");
		return;
	end;
	if SERVER then
		local targetName = args[1];
		local colorInput = string.lower(args[2]);
		if not PORTAL_COLORS[colorInput] then
			ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Utilisez une couleur valide.");
			return;
		end;
		local targetPlayer = nil;
		for _, p in ipairs(player.GetAll()) do
			if string.find(string.lower(p:Nick()), string.lower(targetName)) then
				targetPlayer = p;
				break;
			end;
		end;
		if not IsValid(targetPlayer) then
			ply:PrintMessage(HUD_PRINTTALK, "Joueur '" .. targetName .. "' introuvable!");
			return;
		end;
		GP2.SetPlayerPortalColors(targetPlayer, colorInput, (GP2.GetPlayerPortalColors(targetPlayer)).color2);
	end;
end;
local function ChangeGlobalPortalColor2(ply, cmd, args)
	if not IsValid(ply) then
		return;
	end;
	if not args[1] or (not args[2]) or args[1] == "help" then
		ply:PrintMessage(HUD_PRINTTALK, "Usage: global_pc2 <nom_joueur> <couleur>");
		ply:PrintMessage(HUD_PRINTTALK, "Exemple: global_pc2 Player1 orange");
		return;
	end;
	if SERVER then
		local targetName = args[1];
		local colorInput = string.lower(args[2]);
		local colorNumber = PORTAL_COLORS[colorInput];
		if not colorNumber then
			ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Utilisez une couleur valide.");
			return;
		end;
		local targetPlayer = nil;
		for _, p in ipairs(player.GetAll()) do
			if string.find(string.lower(p:Nick()), string.lower(targetName)) then
				targetPlayer = p;
				break;
			end;
		end;
		if not IsValid(targetPlayer) then
			ply:PrintMessage(HUD_PRINTTALK, "Joueur '" .. targetName .. "' introuvable!");
			return;
		end;
		local colorName = COLOR_NAMES[colorNumber];
		local darkCol = GP2_GetPortalDisplayColorDarkened(colorNumber);
		local currentColors = GP2.GetPlayerPortalColors(targetPlayer);
		GP2.SetPlayerPortalColors(targetPlayer, currentColors.r1, currentColors.g1, currentColors.b1, darkCol.r, darkCol.g, darkCol.b);
		ply:PrintMessage(HUD_PRINTTALK, string.format("Couleur du portail 2 de %s changée en: %s", targetPlayer:Nick(), colorName));
		targetPlayer:PrintMessage(HUD_PRINTTALK, string.format("%s a changé votre couleur de portail 2 en: %s", ply:Nick(), colorName));
	end;
end;
concommand.Add("pc1", ChangeLocalPortalColor1);
concommand.Add("pc2", ChangeLocalPortalColor2);
concommand.Add("pcolors", ShowCurrentColors);
concommand.Add("global_pc1", ChangeGlobalPortalColor1);
