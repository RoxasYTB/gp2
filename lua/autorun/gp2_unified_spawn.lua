-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Unified Spawn System - Force tous les joueurs à spawn au même endroit qu'en solo
-- ----------------------------------------------------------------------------

if SERVER then
    -- Variables pour stocker la position de spawn du premier joueur (solo)
    local soloSpawnPos = nil
    local soloSpawnAngles = nil
    
    -- Récupérer les ConVars (ils seront créés par le fichier de config)
    local function getConVars()
        return {
            enabled = GetConVar("gp2_unified_spawn_enabled"),
            separation = GetConVar("gp2_unified_spawn_separation"),
            axis = GetConVar("gp2_unified_spawn_separation_axis"),
            delay = GetConVar("gp2_unified_spawn_delay"),
            debug = GetConVar("gp2_unified_spawn_debug")
        }
    end
    
    -- Fonction de debug
    local function debugPrint(message, ...)
        local cvars = getConVars()
        if cvars.debug and cvars.debug:GetBool() then
            GP2.Print(message, ...)
        end
    end
    
    -- Hook pour capturer la position de spawn du premier joueur
    hook.Add("PlayerSpawn", "GP2::UnifiedSpawn::CaptureFirstSpawn", function(ply, transition)
        local cvars = getConVars()
        
        -- Vérifier si le système est activé
        if not cvars.enabled or not cvars.enabled:GetBool() then
            return
        end
        
        -- Si c'est le premier joueur et qu'on n'a pas encore de position de référence
        if ply:EntIndex() == 1 and not soloSpawnPos then
            local delay = cvars.delay and cvars.delay:GetFloat() or 0.1
            -- Attendre un frame pour être sûr que la position est bien définie
            timer.Simple(delay, function()
                if IsValid(ply) then
                    soloSpawnPos = ply:GetPos()
                    soloSpawnAngles = ply:GetAngles()
                    debugPrint("Position de spawn solo capturée: %s, Angles: %s", tostring(soloSpawnPos), tostring(soloSpawnAngles))
                end
            end)
        elseif soloSpawnPos then
            local delay = cvars.delay and cvars.delay:GetFloat() or 0.1
            -- Pour tous les autres joueurs, les téléporter à la position du spawn solo
            timer.Simple(delay, function()
                if IsValid(ply) then
                    local separation = cvars.separation and cvars.separation:GetFloat() or 32
                    local axis = cvars.axis and cvars.axis:GetInt() or 1
                    
                    -- Calculer un petit décalage pour éviter que les joueurs se chevauchent
                    local playerIndex = ply:EntIndex() - 1 -- -1 car le premier joueur est à l'index 1
                    local offset = Vector(0, 0, 0)
                    
                    -- Définir l'axe de séparation
                    if axis == 0 then
                        offset.x = separation * playerIndex
                    elseif axis == 1 then
                        offset.y = separation * playerIndex
                    elseif axis == 2 then
                        offset.z = separation * playerIndex
                    end
                    
                    -- Faire tourner le décalage selon les angles du spawn solo
                    if soloSpawnAngles then
                        offset:Rotate(soloSpawnAngles)
                    end
                    
                    local finalPos = soloSpawnPos + offset
                    local finalAngles = soloSpawnAngles or ply:GetAngles()
                    
                    ply:SetPos(finalPos)
                    ply:SetAngles(finalAngles)
                    
                    debugPrint("Joueur %s téléporté à la position de spawn solo: %s", ply:Nick(), tostring(finalPos))
                end
            end)
        end
    end)
      -- Hook pour réinitialiser la position de spawn lors du changement de carte
    hook.Add("PostCleanupMap", "GP2::UnifiedSpawn::Reset", function()
        soloSpawnPos = nil
        soloSpawnAngles = nil
        debugPrint("Position de spawn solo réinitialisée pour la nouvelle carte")
    end)
    
    -- Hook pour réinitialiser la position de spawn lors de l'initialisation
    hook.Add("InitPostEntity", "GP2::UnifiedSpawn::Reset", function()
        soloSpawnPos = nil
        soloSpawnAngles = nil
    end)
    
    -- Commande pour forcer la réinitialisation du spawn (pour les admins)
    concommand.Add("gp2_reset_spawn_position", function(ply, cmd, args)
        if not IsValid(ply) or ply:IsAdmin() or ply:IsSuperAdmin() then
            soloSpawnPos = nil
            soloSpawnAngles = nil
            debugPrint("Position de spawn solo réinitialisée manuellement")
            if IsValid(ply) then
                ply:PrintMessage(HUD_PRINTCONSOLE, "Position de spawn solo réinitialisée")
            end
        else
            ply:PrintMessage(HUD_PRINTCONSOLE, "Vous devez être administrateur pour utiliser cette commande")
        end
    end)
    
    -- Commande pour définir manuellement la position de spawn (pour les admins)
    concommand.Add("gp2_set_spawn_position", function(ply, cmd, args)
        if not IsValid(ply) or ply:IsAdmin() or ply:IsSuperAdmin() then
            if IsValid(ply) then
                soloSpawnPos = ply:GetPos()
                soloSpawnAngles = ply:GetAngles()
                debugPrint("Position de spawn solo définie manuellement à: %s", tostring(soloSpawnPos))
                ply:PrintMessage(HUD_PRINTCONSOLE, "Position de spawn définie à votre position actuelle")
            end
        else
            ply:PrintMessage(HUD_PRINTCONSOLE, "Vous devez être administrateur pour utiliser cette commande")
        end
    end)
    
    -- Commande pour afficher la position de spawn actuelle
    concommand.Add("gp2_show_spawn_position", function(ply, cmd, args)
        if soloSpawnPos then
            local message = string.format("Position de spawn solo: %s, Angles: %s", tostring(soloSpawnPos), tostring(soloSpawnAngles or "Non définis"))
            if IsValid(ply) then
                ply:PrintMessage(HUD_PRINTCONSOLE, message)
            else
                print(message)
            end
        else
            local message = "Aucune position de spawn solo définie"
            if IsValid(ply) then
                ply:PrintMessage(HUD_PRINTCONSOLE, message)
            else
                print(message)
            end
        end
    end)
end
