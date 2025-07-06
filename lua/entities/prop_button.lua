-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Pillar style button
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

if SERVER then
    ENT.NextReleaseTime = 0
    ENT.NextTickSoundTime = 0
end

util.PrecacheSound("Portal.button_down")
util.PrecacheSound("Portal.button_up")
util.PrecacheSound("Portal.button_locked")
util.PrecacheSound("Portal.room1_TickTock")

ENT.__input2func = {
    ["press"] = function(self, activator, caller, data)
        self:Press()
    end,
    ["release"] = function(self, activator, caller, data)
        self:Release()
    end,
    ["lock"] = function(self, activator, caller, data)
        self:Lock()
    end,   
    ["unlock"] = function(self, activator, caller, data)
        self:Unlock()
    end,
    ["cancelpress"] = function(self, activator, caller, data)
        self:CancelPress()
    end,    
}

function ENT:Initialize()
    self:SetModel(self:GetButtonModelName())
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    
    if SERVER then
        self:SetUseType(SIMPLE_USE)
        self.PlayerNearby = false
        self.CheckDistance = 100 -- Distance de vérification en unités
        
        -- Variables pour le système de redéclenchement
        self.HasRetriggered = false -- Flag pour éviter les redéclenchements multiples
        self.RetriggerScheduled = false -- Flag pour éviter les programmations multiples
    end

    self.UpSequence = self:LookupSequence( "up" )
    self.DownSequence = self:LookupSequence( "down" )

    self.SoundDown = "Portal.button_down"
    self.SoundUp = "Portal.button_up"
end

function ENT:GetButtonModelName()
    return "models/props/switch001.mdl"
end

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", "IsPressed" )
    self:NetworkVar( "Bool", "IsLocked" )
end

function ENT:AcceptInput(name, activator, caller, data)
    name = name:lower()
    local func = self.__input2func[name]

    if func and isfunction(func) then
        func(self, activator, caller, data)
    end
end

function ENT:KeyValue(k, v)
    if k == "Delay" then
        self.DelayBeforeReset = tonumber(v)
    elseif k == "preventfastreset" then
        self.PreventFastReset = tobool(v) -- unused idk
    elseif k == "istimer" then
        self.HasTimer = tobool(v)
    elseif k == "CheckDistance" then
        self.CheckDistance = tonumber(v) or 100
    end

    if k:StartsWith("On") then
        self:StoreOutput(k, v)
    end
end

function ENT:Use(activator, caller, useType, value)
    if useType == USE_ON then
        self:Press()
    elseif useType == USE_OFF then
        self:Release()
    else
        -- Basculer l'état pour USE_TOGGLE ou USE_SET
        if self:GetIsPressed() then
            self:Release()
        else
            self:Press()
        end
    end
end

-- Helper pour s'assurer de la compatibilité des outputs
function ENT:TriggerPressedOutput()
    self:TriggerOutput("OnPressed")
    self:TriggerOutput("OnButtonPressed") -- Compatibilité alternative
end

function ENT:TriggerUnpressedOutput()
    self:TriggerOutput("OnUnPressed")
    self:TriggerOutput("OnButtonUnPressed") -- Compatibilité alternative
    self:TriggerOutput("OnReleased") -- Autre nom commun
end

-- Helper pour s'assurer de la compatibilité des outputs
function ENT:TriggerPressedOutput()
    self:TriggerOutput("OnPressed")
    self:TriggerOutput("OnButtonPressed") -- Compatibilité alternative
end

function ENT:TriggerUnpressedOutput()
    self:TriggerOutput("OnUnPressed")
    self:TriggerOutput("OnButtonUnPressed") -- Compatibilité alternative
    self:TriggerOutput("OnReleased") -- Autre nom commun
end

function ENT:Press()
    if self:GetIsLocked() then return end
    if self:GetIsPressed() then return end

    self:SetIsPressed(true)
    self:EmitSound(self.SoundDown)
    self:ResetSequence(self.DownSequence)
    self:TriggerPressedOutput()
    
    -- Logging de l'activation du bouton pilier via le système centralisé
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), true)
    end
    
    -- Réinitialiser les flags de redéclenchement quand le bouton est activé par une action réelle
    if SERVER then
        self.HasRetriggered = false
        self.RetriggerScheduled = false
    end
    
    -- Ne définir le délai que si c'est un bouton temporisé
    if self.DelayBeforeReset and self.DelayBeforeReset > 0 then
        self.NextReleaseTime = CurTime() + self.DelayBeforeReset
    else
        self.NextReleaseTime = 0 -- Pas de relâchement automatique
    end
end

function ENT:Release()
    if not self:GetIsPressed() then return end
    
    self:SetIsPressed(false)
    self:EmitSound(self.SoundUp)
    self:ResetSequence(self.UpSequence)
    self:TriggerUnpressedOutput()
    
    -- Logging de la désactivation du bouton pilier via le système centralisé
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false)
    end
      -- Système de redéclenchement pour les boutons piliers (quand relâchés par proximité)
    if SERVER and not self.HasRetriggered and not self.RetriggerScheduled then
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            self.RetriggerScheduled = true -- Marquer comme programmé
            
            -- Redéclenchement immédiat pour les boutons piliers (pas de délai)
            timer.Simple(0.05, function()
                if IsValid(self) and not self.HasRetriggered then
                    -- Vérifier qu'aucun joueur n'est proche
                    local playerNearby = false
                    for _, ply in ipairs(player.GetAll()) do
                        if IsValid(ply) and ply:Alive() then
                            local distance = self:GetPos():Distance(ply:GetPos())
                            if distance <= self.CheckDistance then
                                playerNearby = true
                                break
                            end
                        end
                    end
                    
                    -- Si aucun joueur proche, effectuer le redéclenchement UNIQUE
                    if not playerNearby then
                        self.HasRetriggered = true -- Marquer comme effectué
                        
                        self:SetIsPressed(true)
                        self:EmitSound(self.SoundDown)
                        self:ResetSequence(self.DownSequence)
                        self:TriggerPressedOutput()
                        
                        if SERVER and GP2 and GP2.ButtonLogging then
                            GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), true)
                        end
                        
                        -- Désactiver immédiatement après
                        timer.Simple(0.05, function()
                            if IsValid(self) and self:GetIsPressed() then
                                self:SetIsPressed(false)
                                self:EmitSound(self.SoundUp)
                                self:ResetSequence(self.UpSequence)
                                self:TriggerUnpressedOutput()
                                
                                if SERVER and GP2 and GP2.ButtonLogging then
                                    GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false)
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end
end

function ENT:CancelPress()
    if not self:GetIsPressed() then return end
    
    self:SetIsPressed(false)
    self:EmitSound(self.SoundUp)
    self:ResetSequence(self.UpSequence)
    self:TriggerOutput("OnButtonReset")
    
    -- Logging de la désactivation du bouton pilier (même pour CancelPress)
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false)
    end
      -- Système de redéclenchement pour les boutons piliers temporisés
    if SERVER and self.DelayBeforeReset and self.DelayBeforeReset > 0 and 
       not self.HasRetriggered and not self.RetriggerScheduled then
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            self.RetriggerScheduled = true -- Marquer comme programmé
            
            -- Redéclenchement immédiat pour les boutons piliers (pas de délai)
            timer.Simple(0.05, function()
                if IsValid(self) and not self.HasRetriggered then                    -- Vérifier qu'aucun joueur n'est proche
                    local playerNearby = false
                    for _, ply in ipairs(player.GetAll()) do
                        if IsValid(ply) and ply:Alive() then
                            local distance = self:GetPos():Distance(ply:GetPos())
                            if distance <= self.CheckDistance then
                                playerNearby = true
                                break
                            end
                        end
                    end
                    
                    -- Si aucun joueur proche, effectuer le redéclenchement UNIQUE
                    if not playerNearby then
                        self.HasRetriggered = true -- Marquer comme effectué
                        
                        self:SetIsPressed(true)
                        self:EmitSound(self.SoundDown)
                        self:ResetSequence(self.DownSequence)
                        self:TriggerPressedOutput()
                        
                        if SERVER and GP2 and GP2.ButtonLogging then
                            GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), true)
                        end
                        
                        -- Désactiver immédiatement après
                        timer.Simple(0.05, function()
                            if IsValid(self) and self:GetIsPressed() then
                                self:SetIsPressed(false)
                                self:EmitSound(self.SoundUp)
                                self:ResetSequence(self.UpSequence)
                                self:TriggerUnpressedOutput()
                                
                                if SERVER and GP2 and GP2.ButtonLogging then
                                    GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false)
                                end
                            end
                        end)
                    end
                    
                    self.RetriggerScheduled = false -- Réinitialiser le flag de programmation
                end
            end)
        end
    end
end

function ENT:Lock()
    self:SetIsLocked(true)
end

function ENT:Unlock()
    self:SetIsLocked(false)
end

function ENT:Think()
    if SERVER then
        -- Vérifier la proximité du joueur pour le relâchement automatique
        local playerNearby = false
        local players = player.GetAll()
        
        for _, ply in ipairs(players) do
            if IsValid(ply) and ply:Alive() then
                local distance = self:GetPos():Distance(ply:GetPos())
                if distance <= self.CheckDistance then
                    playerNearby = true
                    break
                end
            end
        end
        
        -- Si le bouton est pressé et qu'aucun joueur n'est proche
        if self:GetIsPressed() and not playerNearby and self.PlayerNearby then
            -- Seulement relâcher si ce n'est pas un bouton avec délai temporisé
            if not self.DelayBeforeReset or self.DelayBeforeReset <= 0 then
                self:Release()
            end
        end
        
        self.PlayerNearby = playerNearby
        
        if self:GetIsPressed() then
            -- Seulement pour les boutons avec délai (temporisés)
            if self.NextReleaseTime and self.NextReleaseTime > 0 and CurTime() > self.NextReleaseTime then
                self:CancelPress()
            elseif self.HasTimer and CurTime() > self.NextTickSoundTime then
                self:EmitSound("Portal.room1_TickTock")
                self.NextTickSoundTime = CurTime() + 1
            end
        end
    end

    self:NextThink(CurTime() + 0.1) -- Optimisé pour vérifier moins souvent
    return true    
end