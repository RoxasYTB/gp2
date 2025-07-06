-- ----------------------------------------------------------------------------
-- GP2 Framework - Floor Button Retrigger Test
-- Test en temps réel du système de redéclenchement des boutons au sol
-- ----------------------------------------------------------------------------

if CLIENT then return end

-- Test automatique qui surveille les activations de boutons au sol
local function TestFloorButtonRetrigger()
    local floorButtons = ents.FindByClass("prop_floor_button")
    local underFloorButtons = ents.FindByClass("prop_under_floor_button")
    
    if #floorButtons == 0 and #underFloorButtons == 0 then
        print("[GP2 RETRIGGER TEST] Aucun bouton au sol trouvé pour le test")
        return
    end
    
    print("[GP2 RETRIGGER TEST] Surveillance des boutons au sol activée")
    print("[GP2 RETRIGGER TEST] " .. (#floorButtons + #underFloorButtons) .. " boutons surveillés")
    
    -- Hook pour surveiller les activations
    local originalPress = {}
    local originalPressOut = {}
    
    -- Surveiller les boutons normaux
    for _, btn in ipairs(floorButtons) do
        if IsValid(btn) then
            -- Stocker la fonction originale
            originalPress[btn] = btn.Press
            originalPressOut[btn] = btn.PressOut
            
            -- Remplacer par notre version avec logging
            btn.Press = function(self)
                print("[GP2 RETRIGGER TEST] ACTIVATION détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalPress[self](self)
            end
            
            btn.PressOut = function(self)
                print("[GP2 RETRIGGER TEST] DÉSACTIVATION détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalPressOut[self](self)
            end
        end
    end
    
    -- Surveiller les boutons souterrains
    for _, btn in ipairs(underFloorButtons) do
        if IsValid(btn) then
            originalPress[btn] = btn.Press
            originalPressOut[btn] = btn.PressOut
            
            btn.Press = function(self)
                print("[GP2 RETRIGGER TEST] ACTIVATION (souterrain) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalPress[self](self)
            end
            
            btn.PressOut = function(self)
                print("[GP2 RETRIGGER TEST] DÉSACTIVATION (souterrain) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalPressOut[self](self)
            end
        end
    end
    
    print("[GP2 RETRIGGER TEST] Test prêt - marchez sur un bouton au sol pour tester")
end

-- Commande pour lancer le test
concommand.Add("gp2_start_retrigger_test", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    TestFloorButtonRetrigger()
end, nil, "Lance la surveillance des boutons au sol pour tester le redéclenchement (Admin uniquement)")

-- Test automatique au démarrage de la carte
hook.Add("InitPostEntity", "GP2_RetriggerTestInit", function()
    timer.Simple(3, function()
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            print("[GP2] Système de redéclenchement des boutons au sol: ACTIVÉ")
        else
            print("[GP2] Système de redéclenchement des boutons au sol: DÉSACTIVÉ")
        end
    end)
end)

print("[GP2] Test de redéclenchement des boutons au sol chargé")
