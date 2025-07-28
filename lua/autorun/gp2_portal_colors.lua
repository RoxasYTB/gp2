-- GP2 Portal Colors System
-- Système de couleurs des portails avec noms intuitifs

-- Table de correspondance couleurs -> numéros
local PORTAL_COLORS = {
    -- Couleurs principales
    ["red"] = 0,
    ["orange"] = 1,
    ["yellow"] = 2,
    ["lime"] = 3,
    ["green"] = 4,
    ["cyan"] = 5,
    ["lightblue"] = 6,
    ["blue"] = 7,
    ["darkblue"] = 8,
    ["magenta"] = 9,
    ["pink"] = 10,
    ["black"] = 11,
    ["white"] = 12,
    ["gray"] = 13,
    ["darkgray"] = 14,

    -- Alias supplémentaires
    ["rouge"] = 0,
    ["jaune"] = 2,
    ["vert"] = 4,
    ["bleu"] = 7,
    ["rose"] = 10,
    ["blanc"] = 12,
    ["gris"] = 13,
    ["noir"] = 11,
    ["grey"] = 13, -- alias pour gray
    ["lightblue"] = 6,
    ["darkblue"] = 8,
    ["darkgray"] = 14,
}

-- Table inverse pour obtenir le nom à partir du numéro
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
    [14] = "Dark Gray",
}

-- Couleurs d'affichage pour le menu d'aide
local DISPLAY_COLORS = {
    [0] = Color(255, 100, 100),   -- Red
    [1] = Color(255, 150, 50),    -- Orange
    [2] = Color(255, 255, 100),   -- Yellow
    [3] = Color(150, 255, 50),    -- Lime
    [4] = Color(100, 255, 100),   -- Green
    [5] = Color(100, 255, 255),   -- Cyan
    [6] = Color(150, 200, 255),   -- Light Blue
    [7] = Color(100, 150, 255),   -- Blue
    [8] = Color(50, 100, 200),    -- Dark Blue
    [9] = Color(255, 100, 255),   -- Magenta
    [10] = Color(255, 150, 200),  -- Pink
    [11] = Color(50, 50, 50),     -- Black
    [12] = Color(255, 255, 255),  -- White
    [13] = Color(150, 150, 150),  -- Gray
    [14] = Color(100, 100, 100),  -- Dark Gray
}

-- Fonction pour afficher le menu d'aide
local function ShowPortalColorsHelp(ply)
    if not IsValid(ply) then return end

    -- En-tête
    ply:PrintMessage(HUD_PRINTTALK, "=== COULEURS DES PORTAILS DISPONIBLES ===")
    ply:PrintMessage(HUD_PRINTTALK, "Utilisez: portal_color1 <couleur> ou portal_color2 <couleur>")
    ply:PrintMessage(HUD_PRINTTALK, "")

    -- Liste des couleurs avec aperçu
    for i = 0, 14 do
        local colorName = COLOR_NAMES[i]
        if colorName then
            local msg = string.format("[%d] %s", i, colorName)
            ply:PrintMessage(HUD_PRINTTALK, msg)
        end
    end

    ply:PrintMessage(HUD_PRINTTALK, "")
    ply:PrintMessage(HUD_PRINTTALK, "Exemples:")
    ply:PrintMessage(HUD_PRINTTALK, "  portal_color1 blue")
    ply:PrintMessage(HUD_PRINTTALK, "  portal_color2 orange")
    ply:PrintMessage(HUD_PRINTTALK, "  portal_color1 green")
end

-- Fonction pour changer la couleur du portail 1
local function ChangePortalColor1(ply, cmd, args)
    if not IsValid(ply) then return end

    if not args[1] or args[1] == "" or args[1] == "help" or args[1] == "aide" then
        ShowPortalColorsHelp(ply)
        return
    end

    local colorInput = string.lower(args[1])
    local colorNumber = PORTAL_COLORS[colorInput]

    if colorNumber then
        RunConsoleCommand("portal_color_1", tostring(colorNumber))
        local colorName = COLOR_NAMES[colorNumber]
        ply:PrintMessage(HUD_PRINTTALK, string.format("Couleur du portail 1 changée en: %s (%d)", colorName, colorNumber))
    else
        ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Tapez 'portal_color1 help' pour voir les couleurs disponibles.")
    end
end

-- Fonction pour changer la couleur du portail 2
local function ChangePortalColor2(ply, cmd, args)
    if not IsValid(ply) then return end

    if not args[1] or args[1] == "" or args[1] == "help" or args[1] == "aide" then
        ShowPortalColorsHelp(ply)
        return
    end

    local colorInput = string.lower(args[1])
    local colorNumber = PORTAL_COLORS[colorInput]

    if colorNumber then
        RunConsoleCommand("portal_color_2", tostring(colorNumber))
        local colorName = COLOR_NAMES[colorNumber]
        ply:PrintMessage(HUD_PRINTTALK, string.format("Couleur du portail 2 changée en: %s (%d)", colorName, colorNumber))
    else
        ply:PrintMessage(HUD_PRINTTALK, "Couleur invalide! Tapez 'portal_color2 help' pour voir les couleurs disponibles.")
    end
end

-- Fonction pour afficher les couleurs actuelles
local function ShowCurrentColors(ply, cmd, args)
    if not IsValid(ply) then return end

    local color1 = GetConVarNumber("portal_color_1") or 0
    local color2 = GetConVarNumber("portal_color_2") or 1

    local name1 = COLOR_NAMES[color1] or "Inconnue"
    local name2 = COLOR_NAMES[color2] or "Inconnue"

    ply:PrintMessage(HUD_PRINTTALK, "=== COULEURS ACTUELLES DES PORTAILS ===")
    ply:PrintMessage(HUD_PRINTTALK, string.format("Portail 1: %s (%d)", name1, color1))
    ply:PrintMessage(HUD_PRINTTALK, string.format("Portail 2: %s (%d)", name2, color2))
end

-- Enregistrement des commandes
concommand.Add("portal_color1", ChangePortalColor1, nil, "Change la couleur du portail 1 (ex: portal_color1 blue)")
concommand.Add("portal_color2", ChangePortalColor2, nil, "Change la couleur du portail 2 (ex: portal_color2 orange)")
concommand.Add("portal_colors", ShowCurrentColors, nil, "Affiche les couleurs actuelles des portails")
concommand.Add("portal_colors_help", ShowPortalColorsHelp, nil, "Affiche l'aide des couleurs de portails")

-- Aliases pour faciliter l'utilisation
concommand.Add("pc1", ChangePortalColor1)
concommand.Add("pc2", ChangePortalColor2)
concommand.Add("pcolors", ShowCurrentColors)

-- Fonction utilitaire pour obtenir le nom d'une couleur
function GP2_GetPortalColorName(colorNumber)
    return COLOR_NAMES[colorNumber] or "Inconnue"
end

-- Fonction utilitaire pour obtenir le numéro d'une couleur
function GP2_GetPortalColorNumber(colorName)
    return PORTAL_COLORS[string.lower(colorName)]
end

-- Fonction utilitaire pour obtenir la couleur d'affichage
function GP2_GetPortalDisplayColor(colorNumber)
    return DISPLAY_COLORS[colorNumber] or Color(255, 255, 255)
end

-- Menu d'aide au démarrage si demandé
if CLIENT then
    -- Affichage avec couleurs dans le chat
    local function ShowColoredHelp()
        if not LocalPlayer() or not LocalPlayer():IsValid() then return end

        chat.AddText(Color(255, 255, 100), "=== COULEURS DES PORTAILS DISPONIBLES ===")
        chat.AddText(Color(200, 200, 200), "Utilisez: portal_color1 <couleur> ou portal_color2 <couleur>")
        chat.AddText(Color(200, 200, 200), "")

        -- Affichage des couleurs avec leur couleur respective
        for i = 0, 14 do
            local colorName = COLOR_NAMES[i]
            if colorName then
                local displayColor = DISPLAY_COLORS[i]
                chat.AddText(Color(150, 150, 150), "[" .. i .. "] ", displayColor, colorName)
            end
        end

        chat.AddText(Color(200, 200, 200), "")
        chat.AddText(Color(100, 255, 100), "Exemples:")
        chat.AddText(Color(150, 150, 150), "  portal_color1 blue")
        chat.AddText(Color(150, 150, 150), "  portal_color2 orange")
        chat.AddText(Color(150, 150, 150), "  portal_color1 green")
    end

    -- Commande pour afficher l'aide colorée
    concommand.Add("portal_colors_help_colored", function()
        ShowColoredHelp()
    end, nil, "Affiche l'aide des couleurs avec aperçu coloré")

    -- Alias
    concommand.Add("phelp", function()
        ShowColoredHelp()
    end)

    -- Hook pour afficher un message d'accueil
    hook.Add("InitPostEntity", "GP2_PortalColorsWelcome", function()
        timer.Simple(2, function()
            if LocalPlayer() and LocalPlayer():IsValid() then
                chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Tapez 'phelp' pour voir les couleurs de portails disponibles!")
            end
        end)
    end)
end

-- Message de confirmation de chargement
if SERVER then
    print("[GP2] Système de couleurs des portails chargé avec succès!")
else
    print("[GP2] Interface couleurs des portails chargée côté client!")
end
