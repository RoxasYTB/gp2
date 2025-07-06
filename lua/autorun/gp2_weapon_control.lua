-- ----------------------------------------------------------------------------
-- GP2 Framework - Contrôle des armes et suppression des bulles d'aide
-- Ce fichier permet de gérer quelles armes sont données et cache les bulles d'aide
-- ----------------------------------------------------------------------------

if SERVER then
    -- ConVars pour contrôler les armes
    CreateConVar("gp2_auto_give_portalgun", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, 
        "Donne automatiquement le Portal Gun au spawn (0 = non, 1 = oui)")
    
    CreateConVar("gp2_remove_default_weapons", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Retire les armes par défaut de Garry's Mod (0 = non, 1 = oui)")
    
    CreateConVar("gp2_portal_gun_only", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Mode Portal Gun uniquement - retire toutes les autres armes (0 = non, 1 = oui)")

    -- Hook pour contrôler les armes au spawn
    hook.Add("PlayerLoadout", "GP2::ControlWeaponLoadout", function(ply)
        -- Empêcher le loadout par défaut de Garry's Mod
        if GetConVar("gp2_remove_default_weapons"):GetBool() then
            -- Ne donne aucune arme par défaut
            ply:StripWeapons()
            
            -- Donner seulement le Portal Gun si activé
            if GetConVar("gp2_auto_give_portalgun"):GetBool() then
                timer.Simple(0.1, function()
                    if IsValid(ply) then
                        ply:Give("weapon_portalgun")
                        
                        -- Upgrader automatiquement le Portal Gun
                        for _, weapon in ipairs(ply:GetWeapons()) do
                            if weapon:GetClass() == "weapon_portalgun" then
                                weapon:UpdatePortalGun()
                            end
                        end
                        
                        -- Sélectionner automatiquement le Portal Gun
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
            
            return true -- Empêche le loadout par défaut
        end
    end)
    
    -- Hook pour maintenir le mode "Portal Gun Only"
    hook.Add("PlayerCanPickupWeapon", "GP2::PortalGunOnly", function(ply, weapon)
        if GetConVar("gp2_portal_gun_only"):GetBool() then
            -- Autoriser seulement le Portal Gun et les armes GP2
            local allowedWeapons = {
                ["weapon_portalgun"] = true,
                ["weapon_paintgun"] = true
            }
            
            if not allowedWeapons[weapon:GetClass()] then
                return false -- Empêche de ramasser d'autres armes
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
        GetConVar("gp2_remove_default_weapons"):SetBool(true)
        
        GP2.Print("Mode Portal Gun uniquement activé par %s", ply:Nick())
        
        -- Nettoyer toutes les armes des joueurs
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
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
        GetConVar("gp2_remove_default_weapons"):SetBool(false)
        
        GP2.Print("Mode Portal Gun uniquement désactivé par %s", ply:Nick())
    end, nil, "Désactive le mode Portal Gun uniquement (Admin uniquement)")
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
        end)
        
        -- Hook plus spécifique pour les messages d'aide des armes
        hook.Add("Think", "GP2::SuppressWeaponHelpBubbles", function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return end
            
            -- Désactiver les bulles d'aide de Garry's Mod
            if ply:GetInfoNum("gmod_showhints", 1) == 1 then
                RunConsoleCommand("gmod_showhints", "0")
            end
        end)
    end
    
    -- Attendre que le jeu soit chargé
    hook.Add("InitPostEntity", "GP2::InitWeaponControl", function()
        timer.Simple(1, SuppressWeaponHelpNotifications)
    end)
    
    -- Commande pour désactiver manuellement les bulles d'aide
    concommand.Add("gp2_hide_weapon_help", function()
        RunConsoleCommand("gmod_showhints", "0")
        chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Bulles d'aide des armes désactivées!")
    end, nil, "Désactive les bulles d'aide des armes")
    
    -- Commande pour réactiver les bulles d'aide
    concommand.Add("gp2_show_weapon_help", function()
        RunConsoleCommand("gmod_showhints", "1")
        chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Bulles d'aide des armes réactivées!")
    end, nil, "Réactive les bulles d'aide des armes")
    
    -- Message d'information au joueur
    hook.Add("PlayerInitialSpawn", "GP2::WeaponControlInfo", function()
        timer.Simple(3, function()
            chat.AddText(Color(100, 255, 255), "[GP2] ", Color(255, 255, 255), "Système de contrôle des armes actif")
            chat.AddText(Color(200, 200, 200), "Utilisez ", Color(100, 255, 100), "gp2_hide_weapon_help", Color(200, 200, 200), " pour cacher les bulles d'aide")
        end)
    end)
end

GP2.Print("Système de contrôle des armes GP2 chargé")
