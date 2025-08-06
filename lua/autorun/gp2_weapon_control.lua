-- ----------------------------------------------------------------------------
-- GP2 Framework - Contrôle des armes et suppression des bulles d'aide
-- Ce fichier permet de gérer quelles armes sont données et cache les bulles d'aide
-- ----------------------------------------------------------------------------

if SERVER then
    -- ConVars pour contrôler les armes
    CreateConVar("gp2_auto_give_portalgun", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Donne automatiquement le Portal Gun au spawn (0 = non, 1 = oui)")

    -- On conserve la convar pour compatibilité, mais elle ne fait plus rien
    CreateConVar("gp2_remove_default_weapons", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Retire les armes par défaut de Garry's Mod (0 = non, 1 = oui) [DÉSACTIVÉ]")

    CreateConVar("gp2_portal_gun_only", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Mode Portal Gun uniquement - retire toutes les autres armes (0 = non, 1 = oui)")

    local GP2_StoredDefaultWeapons = GP2_StoredDefaultWeapons or {}
    local GP2_StoredWeapons = GP2_StoredWeapons or {}

    -- Suppression du hook qui retirait les armes par défaut
    --[[]
    hook.Add("PlayerLoadout", "GP2::ControlWeaponLoadout", function(ply)
        if GetConVar("gp2_remove_default_weapons"):GetBool() then
            GP2_StoredDefaultWeapons[ply:SteamID()] = {}
            for _, weapon in ipairs(ply:GetWeapons()) do
                table.insert(GP2_StoredDefaultWeapons[ply:SteamID()], weapon:GetClass())
            end
            ply:StripWeapons()
            if GetConVar("gp2_auto_give_portalgun"):GetBool() then
                timer.Simple(0.1, function()
                    if IsValid(ply) then
                        ply:Give("weapon_portalgun")
                        for _, weapon in ipairs(ply:GetWeapons()) do
                            if weapon:GetClass() == "weapon_portalgun" then
                                weapon:UpdatePortalGun()
                            end
                        end
                        timer.Simple(0.2, function()
                            if IsValid(ply) then
                                local portalgun = ply:GetWeapon("weapon_portalgun")
                                if IsValid(portalgun) then
                                    ply:SelectWeapon("weapon_portalgun")
                                end
                            end
                        end)
                    end
                end)
            end
            return true
        end
    end)
    --]]

    -- Hook pour maintenir le mode "Portal Gun Only"
    hook.Add("PlayerCanPickupWeapon", "GP2::PortalGunOnly", function(ply, weapon)
        if GetConVar("gp2_portal_gun_only"):GetBool() then
            local allowedWeapons = {
                ["weapon_portalgun"] = true,
                ["weapon_paintgun"] = true
            }
            if not allowedWeapons[weapon:GetClass()] then
                return false
            end
        end
    end)

    -- Hook pour nettoyer les armes non autorisées
    hook.Add("PlayerSpawn", "GP2::CleanupUnwantedWeapons", function(ply, transition)
        if GetConVar("gp2_portal_gun_only"):GetBool() then
            timer.Simple(0.3, function()
                if IsValid(ply) then
                    local allowedWeapons = {
                        ["weapon_portalgun"] = true,
                        ["weapon_paintgun"] = true
                    }
                    for _, weapon in ipairs(ply:GetWeapons()) do
                        if not allowedWeapons[weapon:GetClass()] then
                            ply:StripWeapon(weapon:GetClass())
                        end
                    end
                end
            end)
        end
    end)

    -- Commandes console pour contrôler le système
    concommand.Add("gp2_give_portalgun_all", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                player:Give("weapon_portalgun")
                for _, weapon in ipairs(player:GetWeapons()) do
                    if weapon:GetClass() == "weapon_portalgun" then
                        weapon:UpdatePortalGun()
                    end
                end
            end
        end
        GP2.Print("Portal Gun donné à tous les joueurs par %s", ply:Nick())
    end, nil, "Donne le Portal Gun à tous les joueurs (Admin uniquement)")

    -- Commandes pour désactiver/activer le mode Portal Gun Only
    concommand.Add("gp2_portal_only_on", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        GetConVar("gp2_portal_gun_only"):SetBool(true)
        GetConVar("gp2_auto_give_portalgun"):SetBool(true)
        -- On ne touche plus à gp2_remove_default_weapons
        GP2.Print("Mode Portal Gun uniquement activé par %s", ply:Nick())
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                GP2_StoredWeapons[player:SteamID()] = {}
                for _, weapon in ipairs(player:GetWeapons()) do
                    table.insert(GP2_StoredWeapons[player:SteamID()], weapon:GetClass())
                end
                player:StripWeapons()
                player:Give("weapon_portalgun")
                for _, weapon in ipairs(player:GetWeapons()) do
                    if weapon:GetClass() == "weapon_portalgun" then
                        weapon:UpdatePortalGun()
                    end
                end
            end
        end
    end, nil, "Active le mode Portal Gun uniquement (Admin uniquement)")

    concommand.Add("gp2_portal_only_off", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        GetConVar("gp2_portal_gun_only"):SetBool(false)
        -- On ne touche plus à gp2_remove_default_weapons
        GP2.Print("Mode Portal Gun uniquement désactivé par %s", ply:Nick())
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                player:StripWeapons()
                local stored = GP2_StoredWeapons[player:SteamID()]
                if stored then
                    for _, wep in ipairs(stored) do
                        player:Give(wep)
                    end
                end
            end
        end
    end, nil, "Désactive le mode Portal Gun uniquement (Admin uniquement)")

    -- Commande pour restaurer les armes par défaut à tous les joueurs (inutile si on ne les retire plus)
    --[[]
    concommand.Add("gp2_restore_default_weapons", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                local stored = GP2_StoredDefaultWeapons[player:SteamID()]
                if stored then
                    for _, wep in ipairs(stored) do
                        player:Give(wep)
                    end
                end
            end
        end
        GP2.Print("Armes par défaut restaurées pour tous les joueurs par %s", ply:Nick())
    end, nil, "Restaure les armes par défaut à tous les joueurs (Admin)")
    --]]

    -- Callback inutile si on ne retire plus les armes
    --[[]
    cvars.AddChangeCallback("gp2_remove_default_weapons", function(name, old, new)
        if new == "0" then
            for _, player in ipairs(player.GetAll()) do
                if IsValid(player) then
                    local stored = GP2_StoredDefaultWeapons[player:SteamID()]
                    if stored then
                        for _, wep in ipairs(stored) do
                            player:Give(wep)
                        end
                    end
                end
            end
            GP2.Print("Armes par défaut restaurées automatiquement (gp2_remove_default_weapons désactivé)")
        end
    end, "GP2_RestoreDefaultWeaponsOnDisable")
    --]]
end

if CLIENT then
    -- Supprimer les notifications d'aide pour les armes
    local function SuppressWeaponHelpNotifications()
        -- Hook pour supprimer les notifications d'aide
        hook.Add("HUDShouldDraw", "GP2::SuppressWeaponHelp", function(name)
            -- Supprimer les éléments d'aide des armes
            local suppressedElements = {
                ["CHudWeaponSelection"] = true,
                ["CHudHintDisplay"] = true,
            }

            if suppressedElements[name] then
                return false
            end
        end)        -- Hook plus spécifique pour les messages d'aide des armes
        local hintsDisabled = false
        hook.Add("Think", "GP2::SuppressWeaponHelpBubbles", function()
            local ply = LocalPlayer()
            if not IsValid(ply) or hintsDisabled then return end

            -- Désactiver les bulles d'aide de Garry's Mod une seule fois
            if ply:GetInfoNum("gmod_showhints", 1) == 1 then
                -- Utiliser pcall pour éviter les erreurs si la commande n'existe pas
                local success = pcall(function()
                    RunConsoleCommand("gmod_showhints", "0")
                end)
                hintsDisabled = true -- Marquer comme fait dans tous les cas
            end
        end)
    end

    -- Attendre que le jeu soit chargé
    hook.Add("InitPostEntity", "GP2::InitWeaponControl", function()
        timer.Simple(1, SuppressWeaponHelpNotifications)
    end)    -- Commande pour désactiver manuellement les bulles d'aide
    concommand.Add("gp2_hide_weapon_help", function()
        local success = pcall(function()
            RunConsoleCommand("gmod_showhints", "0")
        end)

        if success then
            chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Bulles d'aide des armes désactivées!")
        else
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Commande gmod_showhints non disponible")
        end
    end, nil, "Désactive les bulles d'aide des armes")

    -- Commande pour réactiver les bulles d'aide
    concommand.Add("gp2_show_weapon_help", function()
        local success = pcall(function()
            RunConsoleCommand("gmod_showhints", "1")
        end)

        if success then
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Bulles d'aide des armes réactivées!")
        else
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Commande gmod_showhints non disponible")
        end
    end, nil, "Réactive les bulles d'aide des armes")

    -- Message d'information au joueur
    hook.Add("PlayerInitialSpawn", "GP2::WeaponControlInfo", function()
        timer.Simple(3, function()
            chat.AddText(Color(100, 255, 255), "[GP2] ", Color(255, 255, 255), "Système de contrôle des armes actif")
            chat.AddText(Color(200, 200, 200), "Utilisez ", Color(100, 255, 100), "gp2_hide_weapon_help", Color(200, 200, 200), " pour cacher les bulles d'aide")
        end)
    end)
end

-- Message d'information sur la convar Portal Gun Only
print("[GP2] Le mode 'Portal Gun uniquement' est désactivé par défaut.")
print("[GP2] Pour l'activer : tapez 'gp2_portal_only_on' dans la console.")
print("[GP2] Pour le désactiver : tapez 'gp2_portal_only_off' dans la console.")

GP2.Print("Système de contrôle des armes GP2 chargé")
