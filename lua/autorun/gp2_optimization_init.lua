-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Initialisation automatique des optimisations de performance
-- ----------------------------------------------------------------------------

-- Ce fichier se charge en premier pour s'assurer que les optimisations sont prêtes

if SERVER then
    -- Message de démarrage
    local function InitializeOptimizations()
        GP2.Print("Initialisation des optimisations GP2...")

        -- Vérifier que tous les systèmes d'optimisation sont chargés
        local optimizations = {
            "sounds", "network", "timers", "lasers", "portals"
        }

        local loaded = 0
        for _, opt in ipairs(optimizations) do
            if GP2.IsOptimizationEnabled and GP2.IsOptimizationEnabled(opt) then
                loaded = loaded + 1
            end
        end

        GP2.Print("Optimisations chargées : %d/%d", loaded, #optimizations)

        -- Afficher le statut des optimisations
        timer.Simple(2, function()
            if GetConVar("gp2_perf_debug"):GetBool() then
                RunConsoleCommand("gp2_perf_stats")
            end
        end)

        -- Nettoyage automatique du cache toutes les 5 minutes
        timer.Create("GP2_CacheCleanup", 300, 0, function()
            -- Nettoyer les caches des optimisations
            if GP2.ScheduledTimers then
                for ent, _ in pairs(GP2.ScheduledTimers) do
                    if not IsValid(ent) then
                        GP2.ScheduledTimers[ent] = nil
                    end
                end
            end

            if GetConVar("gp2_perf_debug"):GetBool() then
                GP2.Print("Cache optimization cleanup completed")
            end
        end)
    end

    -- Attendre que GP2 soit complètement chargé
    timer.Simple(1, InitializeOptimizations)

else
    -- Côté client
    timer.Simple(1, function()
        GP2.Print("Optimisations côté client GP2 initialisées")
    end)
end

-- Hook pour vérifier les performances au démarrage
hook.Add("InitPostEntity", "GP2_OptimizationInit", function()
    timer.Simple(5, function()
        if SERVER then
            local entityCount = #ents.GetAll()
            local playerCount = #player.GetAll()

            GP2.Print("Serveur initialisé avec %d entités et %d joueurs", entityCount, playerCount)

            if entityCount > 2000 then
                GP2.Print("ATTENTION: Nombre élevé d'entités détecté. Les optimisations sont recommandées.")
            end
        end
    end)
end)
