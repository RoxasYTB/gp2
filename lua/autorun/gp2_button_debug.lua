-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Debug commands for buttons
-- ----------------------------------------------------------------------------

if SERVER then
    -- Commande pour activer/désactiver les logs de débogage des boutons
    concommand.Add("gp2_toggle_debug_buttons", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        
        local debugConVar = GetConVar("gp2_debug_buttons")
        if not debugConVar then
            ply:ChatPrint("[GP2] Erreur: ConVar gp2_debug_buttons non trouvé!")
            return
        end
        
        local newValue = args[1] and tobool(args[1]) or not debugConVar:GetBool()
        debugConVar:SetBool(newValue)
        
        ply:ChatPrint("[GP2] Debug des boutons: " .. (newValue and "ACTIVÉ" or "DÉSACTIVÉ"))
    end, nil, "Active/désactive les logs de débogage des boutons (Admin uniquement)")
    
    -- Commande pour lister tous les boutons actifs
    concommand.Add("gp2_list_buttons", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        
        local buttons = {}
        
        -- Boutons piliers
        for _, ent in ipairs(ents.FindByClass("prop_button")) do
            if IsValid(ent) then
                table.insert(buttons, {
                    type = "Pilier",
                    pos = ent:GetPos(),
                    pressed = ent:GetIsPressed(),
                    class = ent:GetClass()
                })
            end
        end
        
        -- Boutons au sol
        for _, ent in ipairs(ents.FindByClass("prop_floor_button")) do
            if IsValid(ent) then
                table.insert(buttons, {
                    type = "Sol",
                    pos = ent:GetPos(),
                    pressed = ent.Pressed or false,
                    class = ent:GetClass()
                })
            end
        end
        
        ply:ChatPrint("[GP2] Boutons trouvés: " .. #buttons)
        for i, btn in ipairs(buttons) do
            ply:ChatPrint(string.format("  %d. %s (%s) - Pos: %s - Pressé: %s", 
                i, btn.type, btn.class, tostring(btn.pos), btn.pressed and "OUI" or "NON"))
        end
    end, nil, "Liste tous les boutons actifs (Admin uniquement)")
    
    -- Commande pour forcer le relâchement de tous les boutons
    concommand.Add("gp2_release_all_buttons", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        
        local count = 0
        
        -- Boutons piliers
        for _, ent in ipairs(ents.FindByClass("prop_button")) do
            if IsValid(ent) and ent:GetIsPressed() then
                ent:Release()
                count = count + 1
            end
        end
        
        -- Boutons au sol
        for _, ent in ipairs(ents.FindByClass("prop_floor_button")) do
            if IsValid(ent) and ent.Pressed then
                ent:PressOut()
                count = count + 1
            end
        end
        
        ply:ChatPrint("[GP2] " .. count .. " boutons relâchés")
    end, nil, "Force le relâchement de tous les boutons pressés (Admin uniquement)")
      GP2.Print("Commandes de débogage des boutons chargées:")
    GP2.Print("  - gp2_toggle_debug_buttons [0/1] : Active/désactive les logs")
    GP2.Print("  - gp2_list_buttons : Liste tous les boutons")
    GP2.Print("  - gp2_release_all_buttons : Relâche tous les boutons")
end
