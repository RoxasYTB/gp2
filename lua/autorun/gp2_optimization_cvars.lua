-- ----------------------------------------------------------------------------
-- GP2 Framework
-- ConVars pour contrôler les optimisations de performance
-- ----------------------------------------------------------------------------

-- ConVars pour activer/désactiver les optimisations
CreateConVar("gp2_optimize_lasers", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Activer l'optimisation des lasers (1=activé, 0=désactivé)")
CreateConVar("gp2_optimize_portals", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Activer l'optimisation des portails (1=activé, 0=désactivé)")
CreateConVar("gp2_optimize_sounds", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Activer l'optimisation des sons (1=activé, 0=désactivé)")
CreateConVar("gp2_optimize_network", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Activer l'optimisation réseau (1=activé, 0=désactivé)")
CreateConVar("gp2_optimize_timers", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Activer l'optimisation des timers (1=activé, 0=désactivé)")

-- ConVars pour ajuster les intervalles d'optimisation
CreateConVar("gp2_laser_update_interval", "0.1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Intervalle de mise à jour des lasers (en secondes)")
CreateConVar("gp2_think_update_interval", "0.1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Intervalle de mise à jour des hooks Think (en secondes)")
CreateConVar("gp2_portal_cache_interval", "0.2", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Intervalle de mise à jour du cache des portails (en secondes)")

-- ConVar pour le debug des performances
CreateConVar("gp2_perf_debug", "0", {FCVAR_ARCHIVE}, "Afficher les informations de debug des performances (1=activé, 0=désactivé)")

if SERVER then
    GP2.Print("Optimisations GP2 activées ! Utilisez les ConVars gp2_optimize_* pour les contrôler.")
    GP2.Print("gp2_perf_debug 1 pour voir les performances en temps réel.")
else
    GP2.Print("Optimisations GP2 côté client activées !")
end

-- Fonction utilitaire pour vérifier si une optimisation est activée
function GP2.IsOptimizationEnabled(optimizationType)
    local cvar = GetConVar("gp2_optimize_" .. optimizationType)
    return cvar and cvar:GetBool() or false
end
