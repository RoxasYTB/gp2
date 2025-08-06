-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Thermal Discouragement Beam
-- ----------------------------------------------------------------------------

include "shared.lua"

local LASER_MODEL = "models/props/laser_emitter.mdl"
local MAX_RAY_LENGTH = 2 ^ 16

local portal_laser_perf_debug = CreateConVar("gp2_portal_laser_perf_debug", "0", FCVAR_CHEAT,
    "Debug perf timings for portal laser", 0, 1)
local portal_laser_normal_update = CreateConVar("gp2_portal_laser_normal_update", "0.05", FCVAR_REPLICATED)
local portal_laser_high_precision_update = CreateConVar("gp2_portal_laser_high_precision_update", "0.001",
    FCVAR_REPLICATED)


local sv_player_collide_with_laser = CreateConVar("gp2_sv_player_collide_with_laser", "1", FCVAR_NOTIFY + FCVAR_CHEAT)

local clamp = math.Clamp
local util_TraceLine = util.TraceLine
local ents_FindAlongRay = ents.FindAlongRay

-- Protection contre les erreurs de chargement
local CalcClosestPointOnLineSegment = function(pos, start, endpos)
    if GP2 and GP2.Utils and GP2.Utils.CalcClosestPointOnLineSegment then
        return GP2.Utils.CalcClosestPointOnLineSegment(pos, start, endpos)
    else
        -- Fallback simple si GP2.Utils n'est pas disponible
        local dir = (endpos - start):GetNormalized()
        local projection = (pos - start):Dot(dir)
        projection = math.max(0, math.min(projection, start:Distance(endpos)))
        return start + dir * projection
    end
end

local EmitSoundAtClosestPoint = function(...)
    if GP2 and GP2.Utils and GP2.Utils.EmitSoundAtClosestPoint then
        return GP2.Utils.EmitSoundAtClosestPoint(...)
    else
        -- Fallback basique
        return false
    end
end

local PROP_WEIGHTED_CUBE_CLASS = {
    ["prop_weighted_cube"] = true
}

local PROP_WEIGHTED_CUBE_TYPE = {
    [2] = true
}

local LASER_TARGET_CLASS = {
    ["point_laser_target"] = true
}

local RAY_EXTENTS = Vector(10, 10, 10)
local RAY_EXTENTS_NEG = -RAY_EXTENTS

local DAMAGABLE_ENTS = {
    ["point_laser_target"] = true
}

local NOT_DAMAGABLE_ENTS = {
    ["npc_security_camera"] = true
}

local TURRET_CLASS = {
    ["npc_portal_turret_floor"] = true
}


function ENT:KeyValue(k, v)
    if k == "StartState" then
        self:SetState(not tobool(v))
    elseif k == "LethalDamage" then
        self:SetLethalDamage(tobool(v))
    elseif k == "AutoAimEnabled" then
        self:SetAutoAim(tobool(v))
    elseif k == "model" then
        self.ModelName = v
    elseif k == "skin" then
        self:SetSkin(tonumber(v))
    end

    if k:StartsWith("On") then
        self:StoreOutput(k, v)
    end
end

function ENT:AcceptInput(name, activator, caller, value)
    name = name:lower()

    if name == "turnon" then
        self:SetState(true)
    elseif name == "turnoff" then
        self:SetState(false)
    elseif name == "toggle" then
        self:SetState(not self:GetState())
    end
end

function ENT:Initialize()
    if not self:GetNoModel() then
        self:SetModel(self.ModelName or LASER_MODEL)
        self.LaserAttachment = self.LaserAttachment or self:LookupAttachment("laser_attachment")
        self:PhysicsInitStatic(MOVETYPE_VPHYSICS)
    end

    self:NextThink(CurTime())
end

-- Cache pour éviter les recalculs inutiles
ENT.LastLaserUpdate = 0
ENT.LaserUpdateInterval = 0.1 -- 100ms au lieu de chaque tick
ENT.CachedLaserData = nil

function ENT:Think()
    -- Optimisation majeure : éviter les recalculs si rien n'a changé
    local curTime = CurTime()
    if curTime - self.LastLaserUpdate < self.LaserUpdateInterval then
        self:NextThink(curTime + self.LaserUpdateInterval)
        return true
    end

    local time = os.clock()

    -- Cache pour optimiser les calculs répétitifs
    if not self.CachedLaserData or curTime - self.LastLaserUpdate > 0.5 then
        self:FireLaser()
        self.LastLaserUpdate = curTime
    end

    if portal_laser_perf_debug:GetBool() then
        GP2.Print("EnvPortalLaser :: Think - execution time: %.6f seconds", os.clock() - time)
    end

    -- Intervalles optimisés : réduire la fréquence
    local interval = IsValid(self:GetParentLaser()) and 0.05 or 0.1
    self:NextThink(curTime + interval)

    return true
end

function ENT:RecursionLaserThroughPortals(data, recursionDepth, visitedPortals, laserSegments)
    -- Protection contre la récursion infinie
    recursionDepth = recursionDepth or 0
    visitedPortals = visitedPortals or {}
    laserSegments = laserSegments or {}

    if recursionDepth >= 5 then  -- Limite maximale de rebonds
        return { HitPos = data.endpos, Entity = NULL, Fraction = 1 }, laserSegments
    end

    -- OPTIMISATION: Utiliser le cache global des portails au lieu de ents.FindAlongRay()
    local rayStart = data.start
    local rayEnd = data.endpos
    local foundPortalEntity = nil
    local portalHitPos = nil

    -- Ajout : initialisation de rayHits pour éviter l'erreur nil
    local rayHits = ents.FindAlongRay(rayStart, rayEnd, RAY_EXTENTS_NEG, RAY_EXTENTS)

    -- Cache optimisé : utiliser le gestionnaire de portails global
    if PortalManager and PortalManager.Portals then
        for portal in pairs(PortalManager.Portals) do
            if IsValid(portal) and portal:GetActivated() then
                local portalPos = portal:GetPos()
                local rayDir = (rayEnd - rayStart):GetNormalized()
                local toPortal = portalPos - rayStart
                local projDist = toPortal:Dot(rayDir)

                -- Vérification rapide de distance avant calculs coûteux
                if projDist > 0 and projDist < (rayEnd - rayStart):Length() then
                    local projPoint = rayStart + rayDir * projDist
                    local distToRay = (portalPos - projPoint):Length()

                    if distToRay < 32 then -- Tolérance pour la détection de portail
                        foundPortalEntity = portal
                        portalHitPos = projPoint
                        break
                    end
                end
            end
        end
    end
    for _, ent in ipairs(rayHits) do
        if IsValid(ent) and ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
            -- Vérifier si on a déjà visité ce portail
            local portalId = ent:EntIndex()
            if not visitedPortals[portalId] then
                foundPortalEntity = ent
                visitedPortals[portalId] = true

                -- Calculer le point d'impact sur ce portail
                local mins, maxs = ent:GetCollisionBounds()
                if not mins or not maxs then
                    mins, maxs = Vector(-34, -34, -1), Vector(34, 34, 1)
                end

                portalHitPos = util.IntersectRayWithOBB(
                    rayStart,
                    (rayEnd - rayStart):GetNormalized(),
                    ent:GetPos(),
                    ent:GetAngles(),
                    mins, maxs
                )
                -- Correction : si l'intersection échoue, utiliser le point d'impact du trace line
                if not portalHitPos then
                    local tr = util.TraceLine({
                        start = rayStart,
                        endpos = rayEnd,
                        filter = { self, ent },
                        mask = MASK_OPAQUE_AND_NPCS
                    })
                    if tr.Hit and tr.Entity == ent then
                        portalHitPos = tr.HitPos
                    else
                        break -- On ne traverse pas le portail si on n'a pas de point d'impact fiable
                    end
                end
                break
            end
        end
    end

    -- Maintenant faire le trace line normal (qui ignore les portails grâce au filtre)
    local tr = util_TraceLine(data)

    -- Déterminer quel point d'impact utiliser
    local actualEndPos = tr.HitPos
    local hitPortal = nil

    if foundPortalEntity and portalHitPos then
        local distanceToPortal = (portalHitPos - rayStart):Length()
        local distanceToHit = (tr.HitPos - rayStart):Length()

        -- Si le portail est plus proche que l'obstacle, l'utiliser
        if distanceToPortal < distanceToHit and distanceToPortal > 50 then  -- Protection contre les rebonds immédiats
            actualEndPos = portalHitPos
            hitPortal = foundPortalEntity
        end
    end

    -- Ajouter ce segment à la liste des segments de laser (jusqu'au portail d'entrée)
    table.insert(laserSegments, { start = data.start, endpos = actualEndPos })

    -- Si on n'a pas de portail à traverser, s'arrêter ici
    if not hitPortal then
        return tr, laserSegments
    end

    -- Continuer avec la logique de téléportation de portail
    local linkedPortal = hitPortal:GetLinkedPartner()

    -- Transformation similaire à projected_wall_entity
    local newData = table.Copy(data)

    -- Calcul de la transformation de position et d'angle
    local rayDirection = (rayEnd - rayStart):GetNormalized()
    local newPos, newAng = self:TransformPortal(hitPortal, linkedPortal, actualEndPos, rayDirection:Angle())

    -- Correction de l'angle pour continuer dans la bonne direction
    newAng = Angle(newAng.p, newAng.y + 180, newAng.r)

    -- Correction spécifique pour les portails au plafond ou au sol
    local exitPortalPitch = linkedPortal:GetAngles().p
    if math.abs(exitPortalPitch - 90) < 10 then
        -- Portail au plafond (pitch = 90°) : inverser pour aller vers le haut
        newAng = Angle(-newAng.p, newAng.y, newAng.r)
    elseif math.abs(exitPortalPitch - 270) < 10 then
        -- Portail au sol (pitch = -90°) : inverser pour aller vers le haut
        newAng = Angle(-newAng.p, newAng.y, newAng.r)
    end

    -- Calculer la longueur restante du rayon
    local rayLength = (rayEnd - rayStart):Length()
    local usedLength = (actualEndPos - rayStart):Length()
    local remainingLength = math.max(rayLength - usedLength, 100)  -- Au moins 100 unités

    -- Décaler légèrement la position de départ pour éviter de retoucher le portail de sortie
    newPos = newPos + newAng:Forward() * 0

    -- IMPORTANT: Ajouter un segment qui part du portail de sortie
    table.insert(laserSegments, { start = linkedPortal:GetPos(), endpos = newPos })

    newData.start = newPos
    newData.endpos = newPos + newAng:Forward() * remainingLength

    -- Ajouter les portails au filtre pour éviter de les retoucher immédiatement
    if istable(data.filter) then
        local newFilter = table.Copy(data.filter)
        table.insert(newFilter, linkedPortal)
        table.insert(newFilter, hitPortal)
        newData.filter = newFilter
    else
        newData.filter = { data.filter, linkedPortal, hitPortal }
    end

    return self:RecursionLaserThroughPortals(newData, recursionDepth + 1, visitedPortals, laserSegments)
end

-- Fonction de transformation inspirée de projected_wall_entity
function ENT:TransformPortal(entryPortal, exitPortal, hitPos, hitAng)
    -- Protection contre les portails invalides
    if not IsValid(entryPortal) or not IsValid(exitPortal) then
        return hitPos, hitAng -- Retourne la position/angle d'origine si portail invalide
    end

    -- Calcul de l'offset local dans le repère du portail d'entrée
    local hitOffset = hitPos - entryPortal:GetPos()
    local localOffset = Vector(
        hitOffset:Dot(entryPortal:GetRight()),
        hitOffset:Dot(entryPortal:GetUp()),
        hitOffset:Dot(entryPortal:GetForward())
    )

    -- Miroir sur l'axe X (left becomes right)
    localOffset.x = -localOffset.x

    -- Transformation de la position vers le portail de sortie
    local newPos = exitPortal:GetPos() +
        localOffset.x * exitPortal:GetRight() +
        localOffset.y * exitPortal:GetUp() +
        localOffset.z * exitPortal:GetForward()

    -- Transformation de l'angle
    local localAng = entryPortal:WorldToLocalAngles(hitAng)
    localAng.y = -localAng.y  -- Miroir sur Y
    localAng.r = -localAng.r  -- Miroir sur Roll

    local newAng = exitPortal:LocalToWorldAngles(localAng)

    return newPos, newAng
end

--- Fire laser every tick (depending on if laser is reflected or base there should be
--- diferrent delay)
function ENT:FireLaser()
    if not self:GetState() then
        return
    end

    if not self:GetNoModel() and self.LaserAttachment == -1 then
        GP2.Error("EnvPortalLaser :: FireLaser - env_portal_laser[%i] with model %q don't have \"laser_attachment\"",
            self:EntIndex(), self:GetModel())
        return
    end

    local attachPos
    local attachAng
    local attachForward

    if self:GetNoModel() then
        attachPos = self:GetPos()
        attachAng = self:GetAngles()
    else
        local attach = self:GetAttachment(self.LaserAttachment)
        attachPos = attach.Pos
        attachAng = attach.Ang
    end

    attachForward = attachAng:Forward()

    local tr, laserSegments = self:RecursionLaserThroughPortals({
        start = attachPos,
        endpos = attachPos + attachForward * MAX_RAY_LENGTH,
        filter = {
            self,
            "projected_wall_entity",
            "player",
            "point_laser_target",
            "prop_laser_catcher",
            "prop_laser_relay",
            "prop_portal",
            self:GetParent() },
        mask = MASK_OPAQUE_AND_NPCS
    })

    -- Stocker les segments pour le client
    self.LaserSegments = laserSegments or {}

    -- Créer un segment de sortie de portail (la fonction détecte elle-même s'il y a des portails)
    local exitSegments, entryHitWithOffset = self:CalculatePortalExitSegments(attachPos, attachForward)    -- Combiner le segment principal et les segments de sortie de portail
    local allSegments = {}

    -- Ajouter le segment principal (jusqu'au premier portail ou jusqu'à l'impact)
    if #self.LaserSegments > 0 then
        local mainSegment = self.LaserSegments[1]
        -- Le segment principal garde toujours sa position réelle, pas d'offset appliqué
        table.insert(allSegments, mainSegment)
    else
        -- Pas de portail, segment normal
        table.insert(allSegments, { start = attachPos, endpos = tr.HitPos })
    end

    -- Ajouter les segments de sortie de portail
    for _, segment in ipairs(exitSegments) do
        table.insert(allSegments, segment)
    end

    -- Toujours envoyer les segments au client (pour tous les lasers maintenant)
    net.Start("LaserSegments")
    net.WriteEntity(self)
    net.WriteUInt(#allSegments, 8)
    for _, segment in ipairs(allSegments) do
        net.WriteVector(segment.start)
        net.WriteVector(segment.endpos)
    end
    net.Broadcast()

    -- Gérer les collisions uniquement pour les segments finaux (ceux envoyés au client)
    for _, segment in ipairs(allSegments) do
        self:DamageEntsAlongTheRay(segment.start, segment.endpos)
    end    local hitEntity = tr.Entity
    self:SetReflector(hitEntity)

    -- Set hit pos for client
    -- MASK_OPAQUE_AND_NPCS uses CONTENTS_WINDOW, so on client laser goes through cubes and
    -- transparent objects/surfaces
    self:SetHitPos(tr.HitPos)
    self:SetHitNormal(tr.HitNormal)

    -- If we hit reflective cube add laser into
    if IsValid(hitEntity) then
        if PROP_WEIGHTED_CUBE_CLASS[hitEntity:GetClass()] and PROP_WEIGHTED_CUBE_TYPE[hitEntity:GetCubeType()] then
            self:ReflectLaserForEntity(hitEntity)
        elseif TURRET_CLASS[hitEntity:GetClass()] and not hitEntity:IsOnFire() then
            hitEntity:Ignite(5)
        end

        self:SetShouldSpark(false)
    else
        self:SetShouldSpark(true)
    end

    -- Suppression des portails non-joueur du même type lors de l’activation du laser
    if SERVER then
        -- TYPE_BLUE = 1, TYPE_ORANGE = 2
        if self.PortalType then
            RemoveNonPlayerPortalsOfType(self.PortalType)
        end
    end
end

--- Reflect laser on this entity (reflective cube)
function ENT:ReflectLaserForEntity(reflector)
    -- If there's no laser reflected via this cube
    -- create it
    if not IsValid(reflector:GetChildLaser()) then
        local laser = ents.Create(self:GetClass())

        if IsValid(laser) then
            laser:SetNoModel(true)
            laser:SetPos(reflector:GetPos())
            laser:SetAngles(reflector:GetAngles())
            laser:SetParent(reflector)
            laser:Spawn()
            laser:AddEffects(EF_NODRAW + EF_NOSHADOW)

            reflector:SetChildLaser(laser)
            laser:SetParentLaser(self)
            self:SetChildLaser(laser)

            -- Forcer la transmission réseau pour les lasers réfléchis
            laser:SetTransmitWithParent(true)

            -- Activer immédiatement le laser réfléchi
            laser:SetState(self:GetState())

            print("[GP2] Laser réfléchi créé: " .. tostring(laser) .. " pour cube: " .. tostring(reflector))
        end
    else
        -- Si le laser réfléchi existe déjà, s'assurer qu'il est synchronisé
        local childLaser = reflector:GetChildLaser()
        if IsValid(childLaser) then
            childLaser:SetState(self:GetState())
        end
    end
end

--- Pushes player from line
--- @param player Player Who should be pushed?
--- @param startPos Vector Where laser starts
--- @param endPod Vector Where laser ends
--- @param force number Force of push (for example: 300)
local function PushPlayerAwayFromLine(player, startPos, endPos, baseForce)
    if not sv_player_collide_with_laser:GetBool() then return end

    -- Ensure the player is valid and capable of being moved
    if not IsValid(player) or not player:IsPlayer() or player:GetMoveType() == MOVETYPE_NOCLIP then
        return
    end

    -- Check if the player is on the ground
    if not player:IsOnGround() then return end

    -- Check if player portal teleporting right now
    if player.PORTAL_TELEPORTING then return end

    -- Calculate the nearest point on the line segment to the player
    local playerPos = player:GetPos()
    local nearestPoint = CalcClosestPointOnLineSegment(playerPos, startPos, endPos)

    -- Calculate the direction from the line segment to the player
    local pushDirection = (playerPos - nearestPoint):GetNormalized()
    pushDirection.z = 0 -- Keep the push direction horizontal

    -- Get the player's current velocity magnitude
    local playerVelocity = player:GetVelocity():Length()

    -- Adjust the force based on player's movement speed (but not when crouching)
    if not player:Crouching() then
        baseForce = baseForce * (playerVelocity / 100)
    end

    -- Clamp the force to a maximum of [400, 1000]
    local clampedForce = clamp(baseForce, 400, 1000)

    -- If the player is crouching, double the force
    if player:Crouching() then
        clampedForce = clampedForce * 2
    end

    -- Calculate the push velocity vector
    local pushVelocity = pushDirection * clampedForce

    -- Apply the calculated push velocity to the player
    player:SetGroundEntity(NULL)
    player:SetVelocity(pushVelocity)
end

--- Damage ents along ray (players/npcs/laser receivers)
--- @param startPos Vector Position to emit ray from
--- @param endPos Vector Ray end pos
function ENT:DamageEntsAlongTheRay(startPos, endPos)
    local rayInfo = ents_FindAlongRay(startPos, endPos, RAY_EXTENTS_NEG, RAY_EXTENTS)

    for i = 1, #rayInfo do
        local target = rayInfo[i]

        if target:IsPlayer() and not sv_player_collide_with_laser:GetBool() then continue end

        -- If target is not valid somehow, skip it
        if not IsValid(target) then continue end

        -- If target is not player, npc, nexbot or damageable ent, skip it
        if not (target:IsPlayer() or target:IsNPC() or target:IsNextBot() or DAMAGABLE_ENTS[target:GetClass()]) then
            continue
        end

        -- Don't spark
        if DAMAGABLE_ENTS[target:GetClass()] then
            self:SetShouldSpark(false)
        end

        -- Don't damage some ents
        if NOT_DAMAGABLE_ENTS[target:GetClass()] then continue end

        -- If player is not alive don't damage it
        if target:IsPlayer() and not target:Alive() then continue end

        -- Ensure the player is valid and capable of being moved
        if target:IsPlayer() and target:GetMoveType() == MOVETYPE_NOCLIP then
            continue
        end

        -- Check if the player is on the ground
        if target:IsPlayer() and not target:IsOnGround() then continue end

        -- Check if player portal teleporting right now
        if target.PORTAL_TELEPORTING then continue end

        -- Damage it now
        local damageInfo = DamageInfo()
        damageInfo:SetAttacker(self)

        if LASER_TARGET_CLASS[target:GetClass()] then
            damageInfo:SetDamage(1)
        else
            damageInfo:SetDamage(8)
        end        target:TakeDamageInfo(damageInfo)

        -- Push it
        PushPlayerAwayFromLine(target, startPos, endPos, 400)
        EmitSoundAtClosestPoint(target, startPos, endPos, "Flesh.BulletImpact")
        EmitSoundAtClosestPoint(target, startPos, endPos, "Player.FallDamage")
    end
end

function ENT:OnStateChange(name, old, new)
    local child = self:GetChildLaser()

    if IsValid(child) then
        child:SetState(new)
    end
end

-- S'assurer que l'entité laser est transmise en multijoueur
function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 10
    local SpawnAng = ply:EyeAngles()
    SpawnAng.p = 0

    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos)
    ent:SetAngles(SpawnAng)
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Fonction pour calculer les segments de sortie de portail (inspirée de projected_wall_entity)
function ENT:CalculatePortalExitSegments(startPos, direction)
    local exitSegments = {}
    local entryHitPosWithOffset = nil -- Position d'impact sur le portail d'entrée avec offsets

    -- Trouver les portails le long du rayon principal
    local rayEnd = startPos + direction * MAX_RAY_LENGTH
    local extents = Vector(10, 10, 10)
    local rayHits = ents.FindAlongRay(startPos, rayEnd, -extents, extents)

    for _, ent in ipairs(rayHits) do
        if IsValid(ent) and ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
            local entryPortal = ent
            local exitPortal = entryPortal:GetLinkedPartner()

            -- Calcul du point d'impact sur le portail d'entrée
            local mins, maxs = entryPortal:GetCollisionBounds()
            if not mins or not maxs then
                mins, maxs = Vector(-34, -34, -1), Vector(34, 34, 1)
            end

            local hitPos = util.IntersectRayWithOBB(
                startPos,
                direction,
                entryPortal:GetPos(),
                entryPortal:GetAngles(),
                mins, maxs
            )
            if not hitPos then
                hitPos = entryPortal:GetPos()
            end

            -- Calcul des offsets comme dans projected_wall_entity
            -- L'offset Z doit être calculé par rapport à la position de l'émetteur laser (comme originalWallZ)
            local portalZ = entryPortal:GetPos().z
            local offsetZ = portalZ - startPos.z

            -- Offset local gauche/droite (Right) dans le repère du portail d'entrée
            local entryRight = entryPortal:GetRight()
            local offsetVec = startPos - entryPortal:GetPos()
            local offsetXLocal = offsetVec:Dot(entryRight)

            -- Debug: afficher les offsets calculés
            if portal_laser_perf_debug:GetBool() then
                print(string.format("Laser Offset Debug: startPos.z=%.2f, portalZ=%.2f, offsetZ=%.2f, offsetXLocal=%.2f",
                    startPos.z, portalZ, offsetZ, offsetXLocal))
            end

            -- Créer une position d'entrée modifiée avec les offsets pour la transformation
            local modifiedHitPos = Vector(hitPos.x, hitPos.y, hitPos.z)

            -- Transformation de position à travers le portail avec la position modifiée
            local newPos, newAng = self:TransformPortal(entryPortal, exitPortal, modifiedHitPos, direction:Angle())

            -- Debug: position avant application des offsets
            if portal_laser_perf_debug:GetBool() then
                print(string.format("Laser Position Debug: newPos avant offsets = (%.2f, %.2f, %.2f)",
                    newPos.x, newPos.y, newPos.z))
            end

            -- Correction de l'angle pour continuer dans la bonne direction
            newAng = Angle(newAng.p, newAng.y + 180, newAng.r)

            -- Correction spécifique pour les portails au plafond ou au sol
            local exitPortalPitch = exitPortal:GetAngles().p
            if math.abs(exitPortalPitch - 90) < 10 then
                -- Portail au plafond (pitch = 90°) : inverser pour aller vers le haut
                newAng = Angle(-newAng.p, newAng.y, newAng.r)
            elseif math.abs(exitPortalPitch - 270) < 10 then
                -- Portail au sol (pitch = 270°) : inverser pour aller vers le haut
                newAng = Angle(-newAng.p, newAng.y, newAng.r)
            end

            -- Application des offsets exactement comme dans projected_wall_entity
            local exitPortalPitch = exitPortal:GetAngles().p
            local exitPortalYaw = exitPortal:GetAngles().y

            -- Appliquer les corrections de position selon l'orientation (comme projected_wall_entity)
            if exitPortalYaw == -90 then
                newPos.y = newPos.y - 20
            end
            if exitPortalYaw > 90 and exitPortalYaw < 180 then
                -- newPos.y = newPos.y (pas de changement)
            end
            if exitPortalYaw > -1 and exitPortalYaw < 1 then
                -- newPos.x = newPos.x (pas de changement)
            end
            if exitPortalYaw == -180 then
                newPos.x = newPos.x - 20
            end

            -- Appliquer l'offset X local sur l'axe Right du portail de sortie (négatif comme dans projected_wall_entity)
            newPos = newPos + exitPortal:GetRight() * (-offsetXLocal)

            -- Application de l'offset Z selon l'orientation du portail (exactement comme projected_wall_entity)
            if math.abs(exitPortalPitch - 90) < 10 then
                -- Portail au plafond (pitch = 90°) : l'offset Z devient un offset sur l'axe Forward du portail
                newPos = newPos - exitPortal:GetUp() * offsetZ
            elseif math.abs(exitPortalPitch - 270) < 10 or math.abs(exitPortalPitch - 270) < 10 then
                -- Portail au sol (pitch = 270°) : l'offset Z devient un offset sur l'axe Forward du portail (inversé)
                newPos = newPos - exitPortal:GetUp() * offsetZ
            else
                -- Mur : application normale de l'offset Z (soustraction comme dans projected_wall_entity)
                newPos.z = newPos.z - offsetZ
            end

            -- Debug: position après application des offsets
            if portal_laser_perf_debug:GetBool() then
                print(string.format("Laser Position Debug: newPos après offsets = (%.2f, %.2f, %.2f)",
                    newPos.x, newPos.y, newPos.z))
            end

              newAng = Angle(-newAng.p, newAng.y, newAng.r)


            print(string.format("Laser Exit Debug: newPos = (%.2f, %.2f, %.2f), newAng = (%.2f, %.2f, %.2f)",
                newPos.x, newPos.y, newPos.z, newAng.p, newAng.y, newAng.r))

            -- Décaler légèrement pour éviter de retoucher le portail

            print(newAng.p, newAng.y, newAng.r)
            if newAng.p > 80 and newAng.p < 100 then
                -- Si le portail est horizontal, on applique un offset Z
        newPos = newPos - newAng:Forward() * 30
                newPos = newPos - newAng:Up() * offsetZ
            end

            if newAng.p < -80 and newAng.p > -100 then
                -- Si le portail est horizontal, on applique un offset Z
        newPos = newPos - newAng:Forward() * 30
                newPos = newPos - newAng:Up() * offsetZ
            end

            -- Inverser la direction du laser si le portail de sortie est au plafond ou au sol

            -- Calculer la position d'impact sur le portail d'entrée avec les mêmes offsets
            -- pour que les segments se connectent correctement
            local entryHitWithOffset = Vector(hitPos.x, hitPos.y, hitPos.z)
            local entryPortalPitch = entryPortal:GetAngles().p
            local entryPortalYaw = entryPortal:GetAngles().y

            -- Appliquer les corrections de position selon l'orientation du portail d'entrée
            if entryPortalYaw == -90 then
                entryHitWithOffset.y = entryHitWithOffset.y - 20
            end
            if entryPortalYaw > 90 and entryPortalYaw < 180 then
                -- entryHitWithOffset.y = entryHitWithOffset.y (pas de changement)
            end
            if entryPortalYaw > -1 and entryPortalYaw < 1 then
                -- entryHitWithOffset.x = entryHitWithOffset.x (pas de changement)
            end
            if entryPortalYaw == -180 then
                entryHitWithOffset.x = entryHitWithOffset.x - 20
            end

            -- Appliquer l'offset X local sur l'axe Right du portail d'entrée
            entryHitWithOffset = entryHitWithOffset + entryPortal:GetRight() * (-offsetXLocal)

            -- Appliquer les mêmes offsets Z que pour newPos mais au point d'entrée
            if math.abs(entryPortalPitch - 90) < 10 then
                -- Portail au plafond (pitch = 90°)
                entryHitWithOffset = entryHitWithOffset + entryPortal:GetForward() * offsetZ
            elseif math.abs(entryPortalPitch - 270) < 10 or math.abs(entryPortalPitch - 270) < 10 then
                -- Portail au sol (pitch = 270°)
                entryHitWithOffset = entryHitWithOffset - entryPortal:GetForward() * offsetZ
            else
                -- Mur
                entryHitWithOffset.z = entryHitWithOffset.z - offsetZ
            end

            -- Stocker pour retourner avec les segments
            entryHitPosWithOffset = entryHitWithOffset

            -- Tracer le rayon depuis le portail de sortie
            local exitTr = util.TraceLine({
                start = newPos,
                endpos = newPos + newAng:Forward() * MAX_RAY_LENGTH,
                filter = {
                    self,
                    exitPortal,
                    entryPortal,
                    "projected_wall_entity",
                    "player",
                    "point_laser_target",
                    "prop_laser_catcher",
                    "prop_laser_relay",
                    self:GetParent()
                },
                mask = MASK_OPAQUE_AND_NPCS
            })

            -- Ajouter le segment de sortie
            table.insert(exitSegments, {
                start = newPos,
                endpos = exitTr.HitPos
            })

            -- Collision supprimée ici - sera gérée uniquement pour les segments finaux

            break -- Prendre seulement le premier portail trouvé
        end
    end

    return exitSegments, entryHitPosWithOffset
end
