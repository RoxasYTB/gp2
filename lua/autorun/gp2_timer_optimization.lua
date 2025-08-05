-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Optimisation des timer.Simple pour réduire la latence serveur
-- ----------------------------------------------------------------------------

if SERVER then
    -- Cache global pour les entités avec des timers programmés
    GP2.ScheduledTimers = GP2.ScheduledTimers or {}

    -- Fonction optimisée pour remplacer timer.Simple dans les entités
    function Entity:GP2_DelayedCall(delay, func)
        if not IsValid(self) or not isfunction(func) then return end

        local scheduledTime = CurTime() + delay
        self.GP2_ScheduledFunc = func
        self.GP2_ScheduledTime = scheduledTime

        -- Programmer le prochain Think si ce n'est pas déjà fait
        if not self.GP2_HasScheduledThink then
            self:SetNextThink(scheduledTime)
            self.GP2_HasScheduledThink = true
        end
    end

    -- Hook Think optimisé pour les entités avec des timers programmés
    hook.Add("Think", "GP2_OptimizedTimers", function()
        local curTime = CurTime()

        -- Traiter toutes les entités avec des timers programmés
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent.GP2_ScheduledTime and
               ent.GP2_ScheduledFunc and curTime >= ent.GP2_ScheduledTime then

                -- Exécuter la fonction programmée
                local success, err = pcall(ent.GP2_ScheduledFunc)
                if not success then
                    GP2.Error("GP2_DelayedCall error: %s", err)
                end

                -- Nettoyer
                ent.GP2_ScheduledFunc = nil
                ent.GP2_ScheduledTime = nil
                ent.GP2_HasScheduledThink = nil
            end
        end
    end)
end
