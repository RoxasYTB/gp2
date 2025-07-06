-- ----------------------------------------------------------------------------
-- GP2 Framework - Pillar Button Retrigger Test
-- Test en temps réel du système de redéclenchement des boutons piliers
-- ----------------------------------------------------------------------------

if CLIENT then return end

-- Test automatique qui surveille les activations de boutons piliers
local function TestPillarButtonRetrigger()
    local pillarButtons = ents.FindByClass("prop_button")
    local underPillarButtons = ents.FindByClass("prop_under_button")
    
    if #pillarButtons == 0 and #underPillarButtons == 0 then
        print("[GP2 PILLAR RETRIGGER TEST] Aucun bouton pilier trouvé pour le test")
        return
    end
    
    print("[GP2 PILLAR RETRIGGER TEST] Surveillance des boutons piliers activée")
    print("[GP2 PILLAR RETRIGGER TEST] " .. (#pillarButtons + #underPillarButtons) .. " boutons surveillés")
    
    -- Hook pour surveiller les activations
    local originalPress = {}
    local originalRelease = {}
    local originalCancelPress = {}
    
    -- Surveiller les boutons normaux
    for _, btn in ipairs(pillarButtons) do
        if IsValid(btn) then
            -- Stocker les fonctions originales
            originalPress[btn] = btn.Press
            originalRelease[btn] = btn.Release
            originalCancelPress[btn] = btn.CancelPress
            
            -- Remplacer par notre version avec logging
            btn.Press = function(self)
                print("[GP2 PILLAR RETRIGGER TEST] ACTIVATION détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalPress[self](self)
            end
            
            btn.Release = function(self)
                print("[GP2 PILLAR RETRIGGER TEST] DÉSACTIVATION (Release) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalRelease[self](self)
            end
            
            btn.CancelPress = function(self)
                print("[GP2 PILLAR RETRIGGER TEST] DÉSACTIVATION (CancelPress) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalCancelPress[self](self)
            end
        end
    end
    
    -- Surveiller les boutons souterrains
    for _, btn in ipairs(underPillarButtons) do
        if IsValid(btn) then
            originalPress[btn] = btn.Press
            originalRelease[btn] = btn.Release
            originalCancelPress[btn] = btn.CancelPress
            
            btn.Press = function(self)
                print("[GP2 PILLAR RETRIGGER TEST] ACTIVATION (souterrain) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalPress[self](self)
            end
            
            btn.Release = function(self)
                print("[GP2 PILLAR RETRIGGER TEST] DÉSACTIVATION (souterrain Release) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalRelease[self](self)
            end
            
            btn.CancelPress = function(self)
                print("[GP2 PILLAR RETRIGGER TEST] DÉSACTIVATION (souterrain CancelPress) détectée sur: " .. (self:GetName() != "" and self:GetName() or "bouton sans nom"))
                return originalCancelPress[self](self)
            end
        end
    end
    
    print("[GP2 PILLAR RETRIGGER TEST] Test prêt - pressez E sur un bouton pilier pour tester")
end

-- Commande pour lancer le test
concommand.Add("gp2_start_pillar_retrigger_test", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        print("Commande réservée aux administrateurs")
        return
    end
    
    TestPillarButtonRetrigger()
end, nil, "Lance la surveillance des boutons piliers pour tester le redéclenchement (Admin uniquement)")

print("[GP2] Test de redéclenchement des boutons piliers chargé")
