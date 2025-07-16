-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Portal Collision System - Enhanced Map Wall Collision Management
-- Inspired by newPortalGun's collision techniques
-- ----------------------------------------------------------------------------

if CLIENT then return end

-- Table pour suivre les joueurs en transition portail
local playersInPortalTransition = {}

-- Fonction pour désactiver les collisions avec les murs pendant le passage
local function DisableMapCollisionsDuringPortalTransition(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    playersInPortalTransition[ply] = {
        startTime = CurTime(),
        originalMoveType = ply:GetMoveType(),
        portalTransitioning = true
    }

    -- Passer en noclip temporairement pour éviter les collisions avec les murs
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply.PORTAL_COLLISION_DISABLED = true

    print("[GP2] Disabled map collisions for player during portal transition")
end

-- Fonction pour réactiver les collisions avec les murs après le passage
local function RestoreMapCollisionsAfterPortalTransition(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local transitionData = playersInPortalTransition[ply]
    if not transitionData then return end

    -- Restaurer le type de mouvement original
    ply:SetMoveType(transitionData.originalMoveType or MOVETYPE_WALK)
    ply.PORTAL_COLLISION_DISABLED = false

    -- Nettoyer les données de transition
    playersInPortalTransition[ply] = nil

    print("[GP2] Restored map collisions for player after portal transition")
end

-- Hook pour gérer les téléportations de portails
hook.Add("GP2_PlayerTeleportedThroughPortal", "GP2_CollisionSystem", function(ply, fromPortal, toPortal)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    -- Désactiver les collisions pendant la transition
    DisableMapCollisionsDuringPortalTransition(ply)

    -- Restaurer après un court délai
    timer.Simple(0.1, function()
        if IsValid(ply) then
            RestoreMapCollisionsAfterPortalTransition(ply)
        end
    end)
end)

-- Modifier le système de trace pour ignorer les murs quand nécessaire
local originalTraceLine = util.TraceLine

function util.TraceLine(traceData)
    -- Si c'est un trace pour un joueur en transition portail
    if traceData.filter and IsValid(traceData.filter) and traceData.filter:IsPlayer() then
        local ply = traceData.filter
        if ply.PORTAL_COLLISION_DISABLED then
            -- Créer une copie modifiée du trace qui ignore les murs
            local modifiedTrace = table.Copy(traceData)
            modifiedTrace.ignoreworld = true
            return originalTraceLine(modifiedTrace)
        end
    end

    return originalTraceLine(traceData)
end

-- Nettoyage au cas où un joueur quitte pendant la transition
hook.Add("PlayerDisconnected", "GP2_CollisionSystem_Cleanup", function(ply)
    if playersInPortalTransition[ply] then
        playersInPortalTransition[ply] = nil
    end
end)

-- Nettoyage au changement de carte
hook.Add("ShutDown", "GP2_CollisionSystem_Cleanup", function()
    playersInPortalTransition = {}
end)

-- Fonction pour forcer la restauration des collisions (sécurité)
local function ForceRestoreCollisions()
    for ply, data in pairs(playersInPortalTransition) do
        if IsValid(ply) then
            -- Si la transition dure trop longtemps, forcer la restauration
            if CurTime() - data.startTime > 1 then
                RestoreMapCollisionsAfterPortalTransition(ply)
                print("[GP2] Force restored collisions for player after timeout")
            end
        else
            -- Nettoyer les joueurs invalides
            playersInPortalTransition[ply] = nil
        end
    end
end

-- Timer de sécurité pour éviter les collisions bloquées
timer.Create("GP2_CollisionSystem_Safety", 0.5, 0, ForceRestoreCollisions)

print("[GP2] Portal Collision System loaded - Enhanced map wall collision management")
