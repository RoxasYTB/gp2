-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Monitoring des performances et statistiques d'optimisation
-- ----------------------------------------------------------------------------

GP2.PerfMonitor = GP2.PerfMonitor or {
    Stats = {
        TimersSaved = 0,
        SoundsThrottled = 0,
        NetworkCallsOptimized = 0,
        LaserUpdatesSkipped = 0,
        PortalCacheHits = 0
    },
    LastStatsReset = CurTime()
}

-- Fonction pour logger les optimisations
function GP2.PerfMonitor.LogOptimization(optimizationType)
    if not GP2.IsOptimizationEnabled("debug") then return end

    local stat = optimizationType:gsub("^%l", string.upper) .. "sOptimized"
    if GP2.PerfMonitor.Stats[stat] then
        GP2.PerfMonitor.Stats[stat] = GP2.PerfMonitor.Stats[stat] + 1
    end
end

-- Commande pour afficher les statistiques de performance
concommand.Add("gp2_perf_stats", function(ply, cmd, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then return end

    local stats = GP2.PerfMonitor.Stats
    local timeSinceReset = CurTime() - GP2.PerfMonitor.LastStatsReset

    GP2.Print("=== GP2 Performance Statistics ===")
    GP2.Print("Time since reset: %.1f seconds", timeSinceReset)
    GP2.Print("Timers optimized: %d", stats.TimersSaved or 0)
    GP2.Print("Sounds throttled: %d", stats.SoundsThrottled or 0)
    GP2.Print("Network calls optimized: %d", stats.NetworkCallsOptimized or 0)
    GP2.Print("Laser updates skipped: %d", stats.LaserUpdatesSkipped or 0)
    GP2.Print("Portal cache hits: %d", stats.PortalCacheHits or 0)

    if SERVER then
        local entityCount = #ents.GetAll()
        local playerCount = #player.GetAll()
        GP2.Print("Current entities: %d", entityCount)
        GP2.Print("Current players: %d", playerCount)
    end
end)

-- Commande pour réinitialiser les statistiques
concommand.Add("gp2_perf_reset", function(ply, cmd, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then return end

    for k, _ in pairs(GP2.PerfMonitor.Stats) do
        GP2.PerfMonitor.Stats[k] = 0
    end
    GP2.PerfMonitor.LastStatsReset = CurTime()

    GP2.Print("Performance statistics reset!")
end)

-- Auto-affichage des stats toutes les 5 minutes si debug activé
if SERVER then
    timer.Create("GP2_PerfAutoStats", 300, 0, function()
        if GP2.IsOptimizationEnabled("debug") then
            RunConsoleCommand("gp2_perf_stats")
        end
    end)
end

-- Hook pour surveiller les performances globales
hook.Add("Think", "GP2_PerformanceMonitor", function()
    if not GP2.IsOptimizationEnabled("debug") then return end

    -- Surveiller les performances toutes les 10 secondes
    if not GP2.PerfMonitor.LastPerfCheck then
        GP2.PerfMonitor.LastPerfCheck = CurTime()
        return
    end

    if CurTime() - GP2.PerfMonitor.LastPerfCheck > 10 then
        GP2.PerfMonitor.LastPerfCheck = CurTime()

        if SERVER then
            local fps = 1 / engine.TickInterval()
            if fps < 50 then
                GP2.Print("WARNING: Low server FPS detected: %.1f", fps)
            end
        end
    end
end)
