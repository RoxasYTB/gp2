-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Pillar button (underground), just uses prop_button as base
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true -- Enable automatic frame advancement

DEFINE_BASECLASS( "prop_button" )

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self.UpSequence = self:LookupSequence( "unpress" )
    self.DownSequence = self:LookupSequence( "press" )

    self.SoundDown = ''
    self.SoundUp = ''
end

function ENT:Press()
    if self:GetIsLocked() then return end
    if self:GetIsPressed() then return end

    self:SetIsPressed(true)
    self:EmitSound(self.SoundDown)
    self:ResetSequence(self.DownSequence)
    self:TriggerPressedOutput()
    
    -- Logging de l'activation du bouton pilier souterrain via le système centralisé
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), true)
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
    
    -- Logging de la désactivation du bouton pilier souterrain via le système centralisé
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), false)
    end
    
    -- Système de redéclenchement pour les boutons piliers souterrains
    if SERVER then
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            -- Redéclenchement immédiat pour les boutons piliers souterrains (pas de délai)
            timer.Simple(0.05, function()
                if IsValid(self) then
                    -- Vérifier qu'aucun joueur n'est proche
                    local playerNearby = false
                    for _, ply in ipairs(player.GetAll()) do
                        if IsValid(ply) and ply:Alive() then
                            local distance = self:GetPos():Distance(ply:GetPos())
                            if distance <= (self.CheckDistance or 100) then
                                playerNearby = true
                                break
                            end
                        end
                    end
                    
                    -- Si aucun joueur proche, effectuer le redéclenchement
                    if not playerNearby then
                        self:SetIsPressed(true)
                        self:EmitSound(self.SoundDown)
                        self:ResetSequence(self.DownSequence)
                        self:TriggerPressedOutput()
                        
                        if SERVER and GP2 and GP2.ButtonLogging then
                            GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), true)
                        end
                        
                        -- Désactiver immédiatement après
                        timer.Simple(0.05, function()
                            if IsValid(self) and self:GetIsPressed() then
                                self:SetIsPressed(false)
                                self:EmitSound(self.SoundUp)
                                self:ResetSequence(self.UpSequence)
                                self:TriggerUnpressedOutput()
                                
                                if SERVER and GP2 and GP2.ButtonLogging then
                                    GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), false)
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
    
    -- Logging de la désactivation du bouton pilier souterrain (même pour CancelPress)
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), false)
    end
    
    -- Système de redéclenchement pour les boutons piliers souterrains temporisés
    if SERVER and self.DelayBeforeReset and self.DelayBeforeReset > 0 then
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            -- Redéclenchement immédiat pour les boutons piliers souterrains (pas de délai)
            timer.Simple(0.05, function()
                if IsValid(self) then
                    -- Vérifier qu'aucun joueur n'est proche
                    local playerNearby = false
                    for _, ply in ipairs(player.GetAll()) do
                        if IsValid(ply) and ply:Alive() then
                            local distance = self:GetPos():Distance(ply:GetPos())
                            if distance <= (self.CheckDistance or 100) then
                                playerNearby = true
                                break
                            end
                        end
                    end
                    
                    -- Si aucun joueur proche, effectuer le redéclenchement
                    if not playerNearby then
                        self:SetIsPressed(true)
                        self:EmitSound(self.SoundDown)
                        self:ResetSequence(self.DownSequence)
                        self:TriggerPressedOutput()
                        
                        if SERVER and GP2 and GP2.ButtonLogging then
                            GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), true)
                        end
                        
                        -- Désactiver immédiatement après
                        timer.Simple(0.05, function()
                            if IsValid(self) and self:GetIsPressed() then
                                self:SetIsPressed(false)
                                self:EmitSound(self.SoundUp)
                                self:ResetSequence(self.UpSequence)
                                self:TriggerUnpressedOutput()
                                
                                if SERVER and GP2 and GP2.ButtonLogging then
                                    GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), false)
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end
end

function ENT:GetButtonModelName()
    return "models/props_underground/underground_testchamber_button.mdl"
end