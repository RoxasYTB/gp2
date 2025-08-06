-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Optimisation des timer.Simple pour réduire la latence serveur
-- ----------------------------------------------------------------------------

if SERVER then
    local Entity = FindMetaTable("Entity")
    if not Entity or type(Entity) ~= "table" then
        Entity = debug.getregistry().Entity or {}
    end
    -- Cache global optimisé pour les entités avec des timers programmés
    GP2.ScheduledTimers = GP2.ScheduledTimers or {}
    local lastTimerCheck = 0
    local timerCheckInterval = 0.05 -- Vérifier toutes les 50ms

    -- Fonction optimisée pour remplacer timer.Simple dans les entités
    function Entity:GP2_DelayedCall(delay, func)
        if not IsValid(self) or not isfunction(func) then return end
        if not GP2.IsOptimizationEnabled("timers") then
            -- Fallback vers timer.Simple si optimisation désactivée
            timer.Simple(delay, func)
            return
        end

        local scheduledTime = CurTime() + delay
        self.GP2_ScheduledFunc = func
        self.GP2_ScheduledTime = scheduledTime

        -- Ajouter à la liste globale pour un traitement plus efficace
        GP2.ScheduledTimers[self] = scheduledTime
    end

    -- Hook Think optimisé avec fréquence contrôlée
    hook.Add("Think", "GP2_OptimizedTimers", function()
        if not GP2.IsOptimizationEnabled("timers") then return end

        local curTime = CurTime()

        -- Limiter la fréquence de vérification
        if curTime - lastTimerCheck < timerCheckInterval then return end
        lastTimerCheck = curTime

        -- Traiter seulement les entités avec des timers programmés
        for ent, scheduledTime in pairs(GP2.ScheduledTimers) do
            if not IsValid(ent) then
                GP2.ScheduledTimers[ent] = nil
            elseif ent.GP2_ScheduledFunc and curTime >= scheduledTime then
                -- Exécuter la fonction programmée
                local success, err = pcall(ent.GP2_ScheduledFunc)
                if not success and GP2.IsOptimizationEnabled("debug") then
                    GP2.Error("GP2_DelayedCall error: %s", err)
                end

                -- Nettoyer
                ent.GP2_ScheduledFunc = nil
                ent.GP2_ScheduledTime = nil
                GP2.ScheduledTimers[ent] = nil
            end
        end
    end)
end