-- ----------------------------------------------------------------------------
-- GP2 Framework - Button Logging Test
-- Fichier de test pour valider le système de logging des boutons
-- ----------------------------------------------------------------------------

if CLIENT then return end

-- Test automatique du système de logging au démarrage de la carte
hook.Add("InitPostEntity", "GP2_ButtonLoggingTest", function()
    timer.Simple(5, function()
        if not GP2 or not GP2.ButtonLogging then
            print("[GP2 WARNING] Système de logging des boutons non initialisé")
            return
        end
        
        print("[GP2] Système de logging des boutons opérationnel")
        
        -- Compte le nombre de boutons sur la carte
        local pillarButtons = #ents.FindByClass("prop_button")
        local floorButtons = #ents.FindByClass("prop_floor_button")
        local underPillarButtons = #ents.FindByClass("prop_under_button")
        local underFloorButtons = #ents.FindByClass("prop_under_floor_button")
        local total = pillarButtons + floorButtons + underPillarButtons + underFloorButtons
        
        if total > 0 then
            print(string.format("[GP2] %d boutons détectés sur la carte (%d piliers, %d sols, %d piliers souterrains, %d sols souterrains)", 
                total, pillarButtons, floorButtons, underPillarButtons, underFloorButtons))
            print("[GP2] Le logging des activations sera effectué automatiquement")
        else
            print("[GP2] Aucun bouton détecté sur la carte")
        end
    end)
end)

print("[GP2] Test de logging des boutons chargé")
