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

    -- Système de redéclenchement optimisé pour les boutons piliers souterrains
    if SERVER then
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            -- OPTIMISATION : Utiliser GP2_DelayedCall au lieu de timer.Simple
            self:GP2_DelayedCall(0.05, function()
                self.RetriggerState = "check_players"
                self.RetriggerTime = CurTime()
                self:SetNextThink(CurTime() + 0.05)
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

    -- OPTIMISATION : Système de redéclenchement optimisé avec GP2_DelayedCall
    if SERVER and self.DelayBeforeReset and self.DelayBeforeReset > 0 then
        local retrigger_enabled = GetConVar("gp2_floor_button_retrigger")
        if retrigger_enabled and retrigger_enabled:GetBool() then
            -- Utiliser le système optimisé au lieu de timer.Simple
            self:GP2_DelayedCall(0.05, function()
                if not IsValid(self) then return end

                -- Vérifier qu'aucun joueur n'est proche avec calcul optimisé
                local playerNearby = false
                local myPos = self:GetPos()
                local checkDistSqr = (self.CheckDistance or 100) ^ 2

                for _, ply in ipairs(player.GetAll()) do
                    if IsValid(ply) and ply:Alive() then
                        if myPos:DistToSqr(ply:GetPos()) <= checkDistSqr then
                            playerNearby = true
                            break
                        end
                    end
                end

                -- Si aucun joueur proche, effectuer le redéclenchement optimisé
                if not playerNearby then
                    self:SetIsPressed(true)
                    self:EmitSound(self.SoundDown)
                    self:ResetSequence(self.DownSequence)
                    self:TriggerPressedOutput()

                    if GP2 and GP2.ButtonLogging then
                        GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), true)
                    end

                    -- Désactiver immédiatement après avec système optimisé
                    self:GP2_DelayedCall(0.05, function()
                        if IsValid(self) and self:GetIsPressed() then
                            self:SetIsPressed(false)
                            self:EmitSound(self.SoundUp)
                            self:ResetSequence(self.UpSequence)
                            self:TriggerUnpressedOutput()

                            if GP2 and GP2.ButtonLogging then
                                GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), false)
                            end
                        end
                    end)
                end
            end)
        end
    end
end

-- Fonction Think optimisée pour remplacer les timers coûteux
function ENT:Think()
    -- OPTIMISATION : Vérification des états de retrigger côté serveur seulement
    if SERVER and self.RetriggerState then
        local curTime = CurTime()

        if self.RetriggerState == "check_players" and (not self.RetriggerTime or curTime >= self.RetriggerTime) then
            -- Cache optimisé des joueurs proches pour éviter les recalculs
            local playerNearby = false
            local myPos = self:GetPos()
            local checkDist = self.CheckDistance or 100
            local checkDistSqr = checkDist * checkDist -- Distance au carré pour éviter les sqrt()

            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() then
                    local distSqr = myPos:DistToSqr(ply:GetPos())
                    if distSqr <= checkDistSqr then
                        playerNearby = true
                        break
                    end
                end
            end

            if not playerNearby then
                -- Effectuer le redéclenchement immédiat sans timer
                self:SetIsPressed(true)
                self:EmitSound(self.SoundDown)
                self:ResetSequence(self.DownSequence)
                self:TriggerPressedOutput()

                if GP2 and GP2.ButtonLogging then
                    GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), true)
                end

                -- Programmer le relâchement dans le prochain Think
                self.RetriggerState = "release_button"
                self.RetriggerTime = curTime + 0.05
            else
                self.RetriggerState = nil -- Annuler le retrigger
            end

            self:SetNextThink(curTime + 0.05)
            return true

        elseif self.RetriggerState == "release_button" and curTime >= self.RetriggerTime then
            -- Relâcher le bouton
            if self:GetIsPressed() then
                self:SetIsPressed(false)
                self:EmitSound(self.SoundUp)
                self:ResetSequence(self.UpSequence)
                self:TriggerUnpressedOutput()

                if GP2 and GP2.ButtonLogging then
                    GP2.ButtonLogging.LogActivation("BOUTON PILIER SOUTERRAIN", self:GetName(), self:GetPos(), false)
                end
            end

            self.RetriggerState = nil
            return -- Pas de prochain Think programmé
        end

        -- Si dans un état de retrigger, continuer de vérifier
        if self.RetriggerState then
            self:SetNextThink(curTime + 0.05)
            return true
        end
    end

    -- Gestion du relâchement automatique temporisé (optimisé)
    if SERVER and self.NextReleaseTime and self.NextReleaseTime > 0 and CurTime() >= self.NextReleaseTime then
        self:Release()
        self.NextReleaseTime = 0
    end

    -- Appeler le Think de la classe de base si nécessaire
    return self.BaseClass.Think and self.BaseClass.Think(self) or false
end

function ENT:GetButtonModelName()
    return "models/props_underground/underground_testchamber_button.mdl"
end