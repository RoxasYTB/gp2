-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Trigger for floor buttons
-- ----------------------------------------------------------------------------

ENT.Type = "brush"
ENT.Base = "base_entity"
ENT.TouchingEnts = {}
ENT.Button = NULL
ENT.IsPressed = false

local BUTTON_VALID_ENTS = {
    ["player"] = true,
    ["prop_weighted_cube"] = true,
    ["prop_monster_box"] = true,
}

-- ConVar pour les logs de débogage et le redéclenchement (seulement côté serveur)
local gp2_debug_buttons, gp2_floor_button_retrigger, gp2_floor_button_retrigger_delay
if SERVER then
    gp2_debug_buttons = CreateConVar("gp2_debug_buttons", "0", FCVAR_ARCHIVE, "Enable debug logs for floor buttons")
    gp2_floor_button_retrigger = CreateConVar("gp2_floor_button_retrigger", "1", FCVAR_ARCHIVE, "Enable forced retrigger for floor buttons when no entity is present")
    gp2_floor_button_retrigger_delay = CreateConVar("gp2_floor_button_retrigger_delay", "0.1", FCVAR_ARCHIVE, "Delay before forced retrigger (seconds)")
end

local function DebugPrint(msg)
    if SERVER and gp2_debug_buttons and gp2_debug_buttons:GetBool() then
        print(msg)
    end
end

function ENT:Initialize()
    self:SetSolid(SOLID_BBOX)
    self:SetTrigger(true)
    
    -- Paramètres de détection améliorés
    self.CheckRadius = 25 -- Rayon de vérification en unités
    self.LastValidEnts = {} -- Cache des entités détectées
    
    -- Variables pour le système de redéclenchement
    self.LastPressedState = false -- État précédent du bouton
    self.HasRetriggered = false -- Flag pour éviter les redéclenchements multiples
    self.RetriggerScheduled = false -- Flag pour éviter les programmations multiples
end

function ENT:SetButton(btn)
    self.Button = btn
    
    -- Utiliser le rayon personnalisé du bouton si disponible
    if IsValid(btn) and btn.CheckRadius then
        self.CheckRadius = btn.CheckRadius
    end
end

function ENT:Think()
    if not IsValid(self.Button) then
        return
    end
    
    -- Méthode alternative : détection par distance pour être plus fiable
    local nearbyEnts = {}
    local buttonPos = self:GetPos()
    
    -- Chercher les joueurs proches
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local distance = buttonPos:Distance(ply:GetPos())
            if distance <= self.CheckRadius then
                table.insert(nearbyEnts, ply)
            end
        end
    end
    
    -- Chercher les cubes et autres entités valides proches
    for entClass, _ in pairs(BUTTON_VALID_ENTS) do
        if entClass ~= "player" then
            for _, ent in ipairs(ents.FindByClass(entClass)) do
                if IsValid(ent) then
                    local distance = buttonPos:Distance(ent:GetPos())
                    if distance <= self.CheckRadius then
                        table.insert(nearbyEnts, ent)
                    end
                end
            end
        end
    end
    
    -- Nettoyer les entités invalides de TouchingEnts
    local originalCount = #self.TouchingEnts
    for i = #self.TouchingEnts, 1, -1 do
        local ent = self.TouchingEnts[i]
        if not IsValid(ent) then
            table.remove(self.TouchingEnts, i)
        end
    end
      if originalCount ~= #self.TouchingEnts then
        DebugPrint("[Floor Button] Cleaned invalid entities. Before: " .. originalCount .. ", After: " .. #self.TouchingEnts)
    end

    -- Utiliser la méthode la plus fiable (distance OU touch events)
    local shouldBePressed = false
    
    -- Vérifier d'abord par distance (plus fiable)
    if #nearbyEnts > 0 then
        shouldBePressed = true
        DebugPrint("[Floor Button] Entities detected by distance: " .. #nearbyEnts)
    else
        -- Fallback sur les événements Touch
        for _, ent in ipairs(self.TouchingEnts) do
            if IsValid(ent) and BUTTON_VALID_ENTS[ent:GetClass()] then
                shouldBePressed = true
                DebugPrint("[Floor Button] Entities detected by touch events: " .. #self.TouchingEnts)
                break
            end
        end
    end    -- Activer/désactiver le bouton selon l'état requis
    if shouldBePressed and not self.IsPressed then
        DebugPrint("[Floor Button] Pressing button")
        self.Button:Press()
        self.IsPressed = true
        
        -- Réinitialiser les flags de redéclenchement quand le bouton est activé par une entité réelle
        self.HasRetriggered = false
        self.RetriggerScheduled = false
        
    elseif not shouldBePressed and self.IsPressed then
        DebugPrint("[Floor Button] Releasing button")
        self.Button:PressOut()
        self.IsPressed = false
        
        -- Gestion du redéclenchement forcé après désactivation (une seule fois)
        if SERVER and gp2_floor_button_retrigger and gp2_floor_button_retrigger:GetBool() and 
           not self.HasRetriggered and not self.RetriggerScheduled then
            
            local retriggerDelay = gp2_floor_button_retrigger_delay and gp2_floor_button_retrigger_delay:GetFloat() or 0.1
            self.RetriggerScheduled = true -- Marquer comme programmé
            
            DebugPrint("[Floor Button] Scheduling ONE forced retrigger after release (delay: " .. retriggerDelay .. "s)")
            
            timer.Simple(retriggerDelay, function()
                if IsValid(self) and IsValid(self.Button) and not self.HasRetriggered then
                    -- Vérifier qu'aucune entité n'est encore présente
                    local stillEmpty = true
                    local buttonPos = self:GetPos()
                    
                    -- Vérifier les joueurs
                    for _, ply in ipairs(player.GetAll()) do
                        if IsValid(ply) and ply:Alive() then
                            local distance = buttonPos:Distance(ply:GetPos())
                            if distance <= self.CheckRadius then
                                stillEmpty = false
                                break
                            end
                        end
                    end
                    
                    -- Vérifier les autres entités si aucun joueur
                    if stillEmpty then
                        for entClass, _ in pairs(BUTTON_VALID_ENTS) do
                            if entClass ~= "player" then
                                for _, ent in ipairs(ents.FindByClass(entClass)) do
                                    if IsValid(ent) then
                                        local distance = buttonPos:Distance(ent:GetPos())
                                        if distance <= self.CheckRadius then
                                            stillEmpty = false
                                            break
                                        end
                                    end
                                end
                                if not stillEmpty then break end
                            end
                        end
                    end
                    
                    -- Si toujours vide, effectuer le redéclenchement UNIQUE
                    if stillEmpty then
                        self.HasRetriggered = true -- Marquer comme effectué
                        DebugPrint("[Floor Button] Forced retrigger: Press (UNIQUE)")
                        self.Button:Press()
                        self.IsPressed = true
                        
                        timer.Simple(0.05, function()
                            if IsValid(self) and IsValid(self.Button) then
                                DebugPrint("[Floor Button] Forced retrigger: Release (UNIQUE)")
                                self.Button:PressOut()
                                self.IsPressed = false
                            end
                        end)
                    else
                        DebugPrint("[Floor Button] Retrigger cancelled: entity detected")
                    end
                    
                    self.RetriggerScheduled = false -- Réinitialiser le flag de programmation
                end
            end)
        end
    end
    
    -- Sauvegarder l'état actuel pour la prochaine itération
    self.LastPressedState = self.IsPressed

    self:NextThink(CurTime() + 0.05) -- Vérifier plus souvent pour plus de réactivité
    return true
end

function ENT:StartTouch(ent)
    if not IsValid(ent) or not BUTTON_VALID_ENTS[ent:GetClass()] then
        return
    end

    if not IsValid(self.Button) or not isfunction(self.Button.IsButton) or not self.Button:IsButton() then
        return
    end

    -- Éviter les doublons
    for _, touchingEnt in ipairs(self.TouchingEnts) do
        if touchingEnt == ent then
            return
        end
    end    -- Ajouter l'entité à la liste
    table.insert(self.TouchingEnts, ent)
    DebugPrint("[Floor Button] StartTouch: " .. ent:GetClass() .. " (" .. tostring(ent) .. ") - Total: " .. #self.TouchingEnts)

    -- Activer l'entité si nécessaire
    if ent:GetClass() == "prop_weighted_cube" then
        ent:SetActivated(true)
    elseif ent:GetClass() == "prop_monster_box" then
        ent:BecomeBox()
    end

    -- Le bouton sera activé dans Think() si nécessaire
end

function ENT:EndTouch(ent)    -- Retirer l'entité de la liste
    local removed = table.RemoveByValue(self.TouchingEnts, ent)
    DebugPrint("[Floor Button] EndTouch: " .. (IsValid(ent) and ent:GetClass() or "INVALID") .. " (" .. tostring(ent) .. ") - Removed: " .. tostring(removed) .. " - Total: " .. #self.TouchingEnts)

    -- Désactiver l'entité si nécessaire
    if IsValid(ent) then
        if ent:GetClass() == "prop_weighted_cube" then
            ent:SetActivated(false)
        elseif ent:GetClass() == "prop_monster_box" then
            ent:BecomeMonster()
        end
    end

    -- Le bouton sera désactivé dans Think() si nécessaire
end