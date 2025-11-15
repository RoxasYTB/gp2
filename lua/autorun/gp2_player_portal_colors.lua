-- GP2 Player-Specific Portal Colors System
-- Système de couleurs des portails par joueur indépendant

if SERVER then
    AddCSLuaFile()

    -- Table pour stocker les couleurs par joueur
    GP2.PlayerPortalColors = GP2.PlayerPortalColors or {}

    -- Messages réseau
    util.AddNetworkString("GP2_UpdatePlayerPortalColors")
    util.AddNetworkString("GP2_RequestPlayerPortalColors")

    -- Couleurs par défaut
    local function GetDefaultPlayerColors(ply)
        if not IsValid(ply) then return {r1=2, g1=114, b1=210, r2=210, g2=114, b2=2} end

        local colorSets = {
            {r1=0, g1=84, b1=180, r2=180, g2=84, b2=0},     -- Bleu/Orange (défaut)
            {r1=10, g1=150, b1=10, r2=150, g2=50, b2=90},     -- Vert/Rose
            {r1=150, g1=10, b1=10, r2=170, g2=170, b2=0},    -- Rouge/Jaune
            {r1=10, g1=150, b1=150, r2=150, g2=10, b2=150},   -- Cyan/Magenta
            {r1=40, g1=90, b1=150, r2=60, g2=150, b2=0},      -- Bleu clair/Lime
            {r1=170, g1=170, b1=170, r2=0, g2=0, b2=0},       -- Blanc/Noir
        }

        -- SOLO : toujours bleu/orange
        if #player.GetAll() == 1 then
            return colorSets[1]
        end

        -- MULTI : premier joueur bleu/orange, les autres couleurs différentes
        -- On trie les joueurs par EntIndex pour garantir l'ordre
        local players = player.GetAll()
        table.sort(players, function(a, b) return a:EntIndex() < b:EntIndex() end)
        for i, p in ipairs(players) do
            if p == ply then
                if i == 1 then
                    return colorSets[1]
                else
                    -- Décale l'index pour éviter bleu/orange pour les suivants
                    local setIndex = ((i-2) % (#colorSets-1)) + 2
                    return colorSets[setIndex]
                end
            end
        end
        -- fallback
        return colorSets[1]
    end

    -- Récupérer les couleurs d'un joueur
    function GP2.GetPlayerPortalColors(ply)
        if not IsValid(ply) then return GetDefaultPlayerColors(ply) end

        if not GP2.PlayerPortalColors[ply:SteamID()] then
            GP2.PlayerPortalColors[ply:SteamID()] = GetDefaultPlayerColors(ply)
        end

        return GP2.PlayerPortalColors[ply:SteamID()]
    end

    -- Définir les couleurs d'un joueur
    function GP2.SetPlayerPortalColors(ply, r1, g1, b1, r2, g2, b2)
        if not IsValid(ply) then return end

        GP2.PlayerPortalColors[ply:SteamID()] = {
            r1 = tonumber(r1) or 2,
            g1 = tonumber(g1) or 114,
            b1 = tonumber(b1) or 210,
            r2 = tonumber(r2) or 210,
            g2 = tonumber(g2) or 114,
            b2 = tonumber(b2) or 20
        }

        -- Synchroniser avec le client
        net.Start("GP2_UpdatePlayerPortalColors")
        net.WriteString(ply:SteamID())
        net.WriteUInt(GP2.PlayerPortalColors[ply:SteamID()].r1, 8)
        net.WriteUInt(GP2.PlayerPortalColors[ply:SteamID()].g1, 8)
        net.WriteUInt(GP2.PlayerPortalColors[ply:SteamID()].b1, 8)
        net.WriteUInt(GP2.PlayerPortalColors[ply:SteamID()].r2, 8)
        net.WriteUInt(GP2.PlayerPortalColors[ply:SteamID()].g2, 8)
        net.WriteUInt(GP2.PlayerPortalColors[ply:SteamID()].b2, 8)
        net.Broadcast()
    end

    -- Hook quand un joueur se connecte
    hook.Add("PlayerInitialSpawn", "GP2_InitPlayerColors", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                -- Initialiser les couleurs par défaut
                local colors = GP2.GetPlayerPortalColors(ply)
                GP2.SetPlayerPortalColors(ply, colors.r1, colors.g1, colors.b1, colors.r2, colors.g2, colors.b2)
            end
        end)
    end)

    -- Quand un client demande les couleurs
    net.Receive("GP2_RequestPlayerPortalColors", function(len, ply)
        local colors = GP2.GetPlayerPortalColors(ply)
        net.Start("GP2_UpdatePlayerPortalColors")
        net.WriteString(ply:SteamID())
        net.WriteUInt(colors.r1, 8)
        net.WriteUInt(colors.g1, 8)
        net.WriteUInt(colors.b1, 8)
        net.WriteUInt(colors.r2, 8)
        net.WriteUInt(colors.g2, 8)
        net.WriteUInt(colors.b2, 8)
        net.Send(ply)
    end)

else -- CLIENT

    -- Table pour stocker les couleurs des joueurs côté client
    GP2.ClientPlayerPortalColors = GP2.ClientPlayerPortalColors or {}

    -- Récupérer les couleurs d'un joueur côté client
    function GP2.GetClientPlayerPortalColors(ply)
        if not IsValid(ply) then return {r1=2, g1=114, b1=210, r2=210, g2=114, b2=2} end

        local steamid = ply:SteamID()
        if GP2.ClientPlayerPortalColors[steamid] then
            return GP2.ClientPlayerPortalColors[steamid]
        end

        -- Si on n'a pas les couleurs, les demander au serveur
        if ply == LocalPlayer() then
            net.Start("GP2_RequestPlayerPortalColors")
            net.SendToServer()
        end

        -- Retourner des couleurs par défaut en attendant
        return {r1=2, g1=114, b1=210, r2=210, g2=114, b2=2}
    end

    -- Recevoir les mises à jour de couleurs du serveur
    net.Receive("GP2_UpdatePlayerPortalColors", function()
        local steamid = net.ReadString()
        local r1 = net.ReadUInt(8)
        local g1 = net.ReadUInt(8)
        local b1 = net.ReadUInt(8)
        local r2 = net.ReadUInt(8)
        local g2 = net.ReadUInt(8)
        local b2 = net.ReadUInt(8)

        GP2.ClientPlayerPortalColors[steamid] = {
            r1 = r1, g1 = g1, b1 = b1,
            r2 = r2, g2 = g2, b2 = b2
        }
    end)

end
