-- ----------------------------------------------------------------------------
-- GP2 Framework - Button Logging System
-- Système de logging centralisé pour tous les boutons
-- ----------------------------------------------------------------------------

if CLIENT then return end -- Côté serveur uniquement

-- ConVar pour activer/désactiver les logs de boutons
local gp2_log_buttons = CreateConVar("gp2_log_buttons", "1", FCVAR_ARCHIVE, "Enable button activation/deactivation logging")
local gp2_log_buttons_detailed = CreateConVar("gp2_log_buttons_detailed", "0", FCVAR_ARCHIVE, "Enable detailed button logging with position")

-- Fonction utilitaire pour logger les activations de boutons
GP2 = GP2 or {}
GP2.ButtonLogging = GP2.ButtonLogging or {}

function GP2.ButtonLogging.LogActivation(buttonType, buttonName, pos, activated)
    if not gp2_log_buttons:GetBool() then return end
    
    local action = activated and "ACTIVÉ" or "DÉSACTIVÉ"
    local name = buttonName ~= "" and buttonName or "sans nom"
    
    if gp2_log_buttons_detailed:GetBool() then
        print(string.format("[GP2 BUTTON LOG] %s %s - Nom: %s - Position: %.0f %.0f %.0f", 
            buttonType, action, name, pos.x, pos.y, pos.z))
    else
        print(string.format("[GP2 BUTTON LOG] %s %s - Nom: %s", 
            buttonType, action, name))
    end
end

-- Commandes console pour gérer les logs
concommand.Add("gp2_toggle_button_logs", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    local newValue = gp2_log_buttons:GetBool() and "0" or "1"
    gp2_log_buttons:SetString(newValue)
    
    local status = gp2_log_buttons:GetBool() and "activés" or "désactivés"
    print("Logs des boutons " .. status)
end, nil, "Active/désactive les logs des boutons (Admin uniquement)")

concommand.Add("gp2_toggle_detailed_button_logs", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    local newValue = gp2_log_buttons_detailed:GetBool() and "0" or "1"
    gp2_log_buttons_detailed:SetString(newValue)
    
    local status = gp2_log_buttons_detailed:GetBool() and "activés" or "désactivés"
    print("Logs détaillés des boutons " .. status)
end, nil, "Active/désactive les logs détaillés des boutons avec position (Admin uniquement)")

concommand.Add("gp2_test_button_logging", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    print("=== TEST DU SYSTÈME DE LOGGING DES BOUTONS ===")
    print("Status des logs: " .. (gp2_log_buttons:GetBool() and "ACTIVÉS" or "DÉSACTIVÉS"))
    print("Logs détaillés: " .. (gp2_log_buttons_detailed:GetBool() and "ACTIVÉS" or "DÉSACTIVÉS"))
    
    -- Simuler des logs de test
    local testPos = Vector(0, 0, 0)
    GP2.ButtonLogging.LogActivation("BOUTON PILIER", "test_pillar", testPos, true)
    GP2.ButtonLogging.LogActivation("BOUTON AU SOL", "test_floor", testPos, true)
    GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", "test_under_pillar", testPos, true)
    GP2.ButtonLogging.LogActivation("BOUTON AU SOL SOUTERRAIN", "test_under_floor", testPos, true)
    
    timer.Simple(1, function()
        GP2.ButtonLogging.LogActivation("BOUTON PILIER", "test_pillar", testPos, false)
        GP2.ButtonLogging.LogActivation("BOUTON AU SOL", "test_floor", testPos, false)
        GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", "test_under_pillar", testPos, false)
        GP2.ButtonLogging.LogActivation("BOUTON AU SOL SOUTERRAIN", "test_under_floor", testPos, false)
    end)
    
    print("Test terminé. Utilisez 'gp2_toggle_button_logs' pour changer l'état des logs.")
end, nil, "Teste le système de logging des boutons (Admin uniquement)")

concommand.Add("gp2_toggle_floor_button_retrigger", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    RunConsoleCommand("gp2_floor_button_retrigger", GetConVar("gp2_floor_button_retrigger"):GetBool() and "0" or "1")
    
    local status = GetConVar("gp2_floor_button_retrigger"):GetBool() and "activé" or "désactivé"
    print("Redéclenchement forcé des boutons au sol " .. status)
end, nil, "Active/désactive le redéclenchement forcé des boutons au sol (Admin uniquement)")

concommand.Add("gp2_set_floor_button_retrigger_delay", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    local delay = tonumber(args[1])
    if not delay or delay < 0.01 or delay > 5.0 then
        print("Usage: gp2_set_floor_button_retrigger_delay <délai en secondes> (0.01 à 5.0)")
        print("Délai actuel: " .. GetConVar("gp2_floor_button_retrigger_delay"):GetFloat() .. "s")
        return
    end
    
    RunConsoleCommand("gp2_floor_button_retrigger_delay", tostring(delay))
    print("Délai de redéclenchement défini à " .. delay .. " secondes")
end, nil, "Définit le délai de redéclenchement des boutons au sol (Admin uniquement)")

concommand.Add("gp2_test_pillar_button_retrigger", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    print("=== TEST DU SYSTÈME DE REDÉCLENCHEMENT DES BOUTONS PILIERS ===")
    
    -- Vérifier les ConVars
    local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
    if retrigger_enabled then
        print("Redéclenchement: " .. (retrigger_enabled:GetBool() and "ACTIVÉ" or "DÉSACTIVÉ"))
    else
        print("ConVar gp2_floor_button_retrigger non trouvée!")
    end
    
    -- Compter les boutons piliers
    local pillarButtons = ents.FindByClass("prop_button")
    local underPillarButtons = ents.FindByClass("prop_under_button")
    local total = #pillarButtons + #underPillarButtons
    
    print("Boutons piliers détectés: " .. total .. " (" .. #pillarButtons .. " normaux, " .. #underPillarButtons .. " souterrains)")
    
    if total > 0 then
        print("Activez le debug avec 'gp2_debug_buttons 1' puis testez en pressant E sur un bouton pilier.")
        print("Les boutons piliers se redéclenchent immédiatement après désactivation (pas de délai).")
        print("Vous devriez voir la séquence ACTIVÉ -> DÉSACTIVÉ -> ACTIVÉ -> DÉSACTIVÉ dans les logs.")
    end
end, nil, "Teste le système de redéclenchement des boutons piliers (Admin uniquement)")

concommand.Add("gp2_reset_floor_button_retrigger", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    print("=== RÉINITIALISATION DES FLAGS DE REDÉCLENCHEMENT ===")
    
    local floorButtons = ents.FindByClass("prop_floor_button")
    local underFloorButtons = ents.FindByClass("prop_under_floor_button")
    local pillarButtons = ents.FindByClass("prop_button")
    local underPillarButtons = ents.FindByClass("prop_under_button")
    local resetCount = 0
    
    -- Réinitialiser les flags pour tous les boutons au sol
    for _, btn in ipairs(floorButtons) do
        if IsValid(btn) and IsValid(btn.ButtonTrigger) then
            btn.ButtonTrigger.HasRetriggered = false
            btn.ButtonTrigger.RetriggerScheduled = false
            resetCount = resetCount + 1
        end
    end
    
    for _, btn in ipairs(underFloorButtons) do
        if IsValid(btn) and IsValid(btn.ButtonTrigger) then
            btn.ButtonTrigger.HasRetriggered = false
            btn.ButtonTrigger.RetriggerScheduled = false
            resetCount = resetCount + 1
        end
    end
    
    -- Réinitialiser les flags pour tous les boutons piliers
    for _, btn in ipairs(pillarButtons) do
        if IsValid(btn) then
            btn.HasRetriggered = false
            btn.RetriggerScheduled = false
            resetCount = resetCount + 1
        end
    end
    
    for _, btn in ipairs(underPillarButtons) do
        if IsValid(btn) then
            btn.HasRetriggered = false
            btn.RetriggerScheduled = false
            resetCount = resetCount + 1
        end
    end
    
    print("Flags de redéclenchement réinitialisés pour " .. resetCount .. " boutons")
    print("Les boutons pourront maintenant se redéclencher une fois après la prochaine désactivation")
end, nil, "Réinitialise les flags de redéclenchement de TOUS les boutons (Admin uniquement)")

concommand.Add("gp2_test_floor_button_retrigger", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    print("=== TEST DU SYSTÈME DE REDÉCLENCHEMENT DES BOUTONS AU SOL ===")
    
    -- Vérifier les ConVars
    local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
    local retrigger_delay = GetConVar("gp2_floor_button_retrigger_delay")
    
    if retrigger_enabled then
        print("Redéclenchement: " .. (retrigger_enabled:GetBool() and "ACTIVÉ" or "DÉSACTIVÉ"))
    else
        print("ConVar gp2_floor_button_retrigger non trouvée!")
    end
    
    if retrigger_delay then
        print("Délai de redéclenchement: " .. retrigger_delay:GetFloat() .. "s")
    else
        print("ConVar gp2_floor_button_retrigger_delay non trouvée!")
    end
    
    -- Compter les boutons au sol
    local floorButtons = ents.FindByClass("prop_floor_button")
    local underFloorButtons = ents.FindByClass("prop_under_floor_button")
    local total = #floorButtons + #underFloorButtons
    
    print("Boutons au sol détectés: " .. total .. " (" .. #floorButtons .. " normaux, " .. #underFloorButtons .. " souterrains)")
    
    if total > 0 then
        print("Activez le debug avec 'gp2_debug_buttons 1' puis testez en marchant sur un bouton au sol.")
        print("Vous devriez voir 'Forced retrigger: Press (UNIQUE)' dans les logs après avoir quitté le bouton.")
        print("Le redéclenchement ne se fera qu'UNE SEULE FOIS par cycle d'activation.")
        print("Utilisez 'gp2_reset_floor_button_retrigger' pour réinitialiser les flags si nécessaire.")
    end
end, nil, "Teste le système de redéclenchement des boutons au sol (Admin uniquement)")

print("[GP2] Système de logging des boutons chargé")
