-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Configuration pour le système de spawn unifié
-- ----------------------------------------------------------------------------

-- ConVars pour contrôler le système de spawn unifié
if SERVER then
    -- Activer/désactiver le système de spawn unifié
    CreateConVar("gp2_unified_spawn_enabled", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Active le système de spawn unifié (0 = désactivé, 1 = activé)")

    -- Distance de séparation entre les joueurs
    CreateConVar("gp2_unified_spawn_separation", "32", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Distance de séparation entre les joueurs en unités Hammer (défaut: 32)")

    -- Direction de la séparation (0 = X, 1 = Y, 2 = Z)
    CreateConVar("gp2_unified_spawn_separation_axis", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Axe de séparation des joueurs (0 = X, 1 = Y, 2 = Z, défaut: 1 pour Y)")

    -- Délai avant téléportation (en secondes)
    CreateConVar("gp2_unified_spawn_delay", "0.1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Délai avant téléportation en secondes (défaut: 0.1)")

    -- Mode de debug
    CreateConVar("gp2_unified_spawn_debug", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Affiche des messages de debug pour le système de spawn (0 = désactivé, 1 = activé)")

    -- Vérifier que GP2.Print existe avant de l'utiliser
    if GP2 and GP2.Print then
        GP2.Print("Configuration du système de spawn unifié chargée")
        GP2.Print("Utilisez 'gp2_unified_spawn_enabled 0' pour désactiver le système")
        GP2.Print("Utilisez 'gp2_unified_spawn_separation X' pour changer la distance de séparation")
        GP2.Print("Utilisez 'gp2_show_spawn_position' pour voir la position de spawn actuelle")
    else
        print("[GP2] Configuration du système de spawn unifié chargée (GP2.Print non disponible)")
    end
end
