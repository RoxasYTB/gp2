-- ----------------------------------------------------------------------------
-- GP2 Framework
-- env_portal_laser rendering
-- ----------------------------------------------------------------------------

EnvPortalLaser = EnvPortalLaser or {}

local print = GP2.Print
local table_sort = table.sort
local table_insert = table.insert
local util_TraceLine = util.TraceLine

local laserRenderList = {}
local laserLookups = {}
local laserAttachmentLookups = {}

local LASER_MATERIAL = Material("sprites/purplelaser1.vmt")
local LASER_MATERIAL_LETHAL = Material("sprites/laserbeam.vmt")
local LETHAL_COLOR = Color(100, 255, 100)
local NORMAL_COLOR = Color(255, 255, 255)

local RAY_EXTENTS = Vector(0.001, 0.001, 0.001)
local RAY_EXTENTS_NEG = -RAY_EXTENTS
local INVALID_HIT_POS = Vector(2 ^ 16, 2 ^ 16, 2 ^ 16)
local MAX_RAY_LENGTH = 2 ^ 16

function EnvPortalLaser.AddToRenderList(laser)
    if not laserLookups[laser] then
        table_insert(laserRenderList, laser)
        laserLookups[laser] = true
    end
end

-- Fonction pour découvrir automatiquement les lasers existants
function EnvPortalLaser.RefreshExistingLasers()
    for _, ent in ents.Iterator() do
        if IsValid(ent) and ent:GetClass() == "env_portal_laser" then
            EnvPortalLaser.AddToRenderList(ent)
        end
    end
end

-- Fonction pour scanner en continu les nouveaux lasers (lasers réfléchis)
function EnvPortalLaser.ScanForNewLasers()
    -- Scanner spécifiquement les lasers réfléchis qui peuvent être créés dynamiquement
    for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
        if IsValid(ent) and ent:GetState() and not laserLookups[ent] then
            -- Nouveau laser trouvé, l'ajouter
            EnvPortalLaser.AddToRenderList(ent)
            print("[GP2-SDK] Nouveau laser réfléchi détecté et ajouté au rendu: " .. tostring(ent))
        end
    end
end

-- Initialiser automatiquement les lasers existants au chargement
hook.Add("InitPostEntity", "GP2::RefreshExistingLasers", function()
    timer.Simple(0.1, function()
        EnvPortalLaser.RefreshExistingLasers()
        print("[GP2-SDK] Refreshed existing lasers for rendering")
    end)
end)

local function RecursionLaserThroughPortals(laser, linkedPortal, data)
    local tr = util_TraceLine(data)
    local inTrace = ents.FindAlongRay(tr.StartPos, tr.HitPos, -RAY_EXTENTS_NEG, RAY_EXTENTS)
    local candidates = {}

    local filter = {
        prop_weighted_cube = true,
        prop_portal = true
    }

    for e = 1, #inTrace do
        local tracedEntity = inTrace[e]

        if not filter[tracedEntity:GetClass()]
            or tracedEntity == laser
            or tracedEntity == laser:GetParent()
            or tracedEntity:IsNPC()
            or tracedEntity:IsNextBot()
            or tracedEntity == linkedPortal then
            continue
        end

        local mins, maxs = tracedEntity:GetCollisionBounds()

        local intersect = util.IntersectRayWithOBB(
            tr.StartPos,
            tr.Normal * MAX_RAY_LENGTH,
            tracedEntity:GetPos(),
            tracedEntity:GetAngles(),
            mins, maxs
        )

        if intersect then
            local distanceSqr = tr.StartPos:DistToSqr(intersect)
            table.insert(candidates, {
                Entity = tracedEntity,
                HitPos = intersect,
                DistanceSqr = distanceSqr
            })
        end
    end

    table.sort(candidates, function(a, b)
        return a.DistanceSqr < b.DistanceSqr
    end)

    local rayHit = nil
    for _, candidate in ipairs(candidates) do
        local tracedEntity = candidate.Entity
        local intersect = candidate.HitPos

        -- Use small traceline to check if ray actually hits cube :/
        -- ray is thick than traceline
        local preEndPos = intersect - tr.Normal * 16

        local preEndTrace = util_TraceLine({
            start = preEndPos,
            endpos = intersect + tr.Normal * 16,
            filter = { game.GetWorld() }
        })

        if not preEndTrace.Hit or not IsValid(preEndTrace.Entity) or not filter[preEndTrace.Entity:GetClass()] then
            continue
        end

        rayHit = {
            HitPos = intersect,
            Entity = tracedEntity,
            Distance = math.sqrt(candidate.DistanceSqr)
        }

        if tracedEntity:GetClass() == "prop_portal" then
            tr.HitPos = intersect + tr.Normal * tracedEntity:GetSize().z
        else
            tr.HitPos = intersect + tr.Normal
        end
        tr.Entity = tracedEntity

        break
    end    -- Dessiner le segment de laser avec le style Portal 2 (comme cl_init.lua)
    local start = data.start
    local endpos = tr.HitPos

    -- Matériau principal du laser
    local material = Material("sprites/physbeam")
    if material:IsError() then
        material = Material("cable/cable")
    end

    -- Matériau pour le glow
    local glowMaterial = Material("sprites/light_glow")
    if glowMaterial:IsError() then
        glowMaterial = material
    end

    -- Largeur du laser principal
    local mainWidth = 8
    -- Largeur du glow
    local glowWidth = 18

    -- Couleur principale (rouge Portal 2)
    local color = Color(104, 6, 6, 255)
    -- Couleur du glow (plus clair, alpha dégradé)
    local glowColor = Color(255, 80, 80, 120)

    -- Glow autour du beam
    render.SetMaterial(glowMaterial)
    render.DrawBeam(start, endpos, glowWidth, 0, 1, glowColor)

    -- Beam principal
    render.SetMaterial(material)
    render.DrawBeam(start, endpos, mainWidth, 0, 1, color)

    -- Ligne blanche intérieure pour le style Portal
    render.SetMaterial(material)
    render.DrawBeam(start, endpos, 2, 0, 1, Color(255, 255, 255, 255))

    if tr.Entity:IsValid() and tr.Entity:GetClass() == "prop_portal" and IsValid(tr.Entity:GetLinkedPartner()) then
        local hitPortal = tr.Entity
        local linkedPortal = hitPortal:GetLinkedPartner()

        -- Vérifier que le rayon frappe bien la face avant du portail
        if tr.HitNormal:Dot(hitPortal:GetUp()) > 0.9 then
            local newData = table.Copy(data)

            -- Utiliser PortalManager.TransformPortal pour transformer la position et direction
            local transformedStart = PortalManager.TransformPortal(hitPortal, linkedPortal, tr.HitPos - tr.Normal * linkedPortal:GetSize().z * 2)
            local transformedEnd = PortalManager.TransformPortal(hitPortal, linkedPortal, data.endpos)

            -- Application de l'offset selon l'orientation du portail de sortie (inspiré de projected_wall_entity)
            local exitPortalAng = linkedPortal:GetAngles()
            local exitPortalPitch = exitPortalAng.p
            local exitPortalYaw = exitPortalAng.y
            local exitPortalRoll = exitPortalAng.r

            -- Calculer l'offset basé sur la position originale du laser (pas du segment en cours)
            -- IMPORTANT: Utiliser la position originale du laser émetteur, comme dans projected_wall_entity.lua
            local originalLaserPos
            if laser and IsValid(laser) then
                -- Récupérer la position d'origine du laser émetteur
                if laser:GetNoModel() then
                    originalLaserPos = laser:GetPos()
                else
                    local attach = laser:GetAttachment(laser:LookupAttachment("laser_attachment") or 1)
                    originalLaserPos = attach and attach.Pos or laser:GetPos()
                end
            else
                -- Fallback si on n'a pas accès au laser émetteur
                originalLaserPos = data.start
            end

            local entryPortal = hitPortal
            local exitPortal = linkedPortal

            -- Calculer l'offset X (latéral) et Z (vertical) dans le repère du portail d'entrée
            local entryRight = entryPortal:GetRight()
            local entryUp = entryPortal:GetUp()
            local offsetVec = originalLaserPos - entryPortal:GetPos()
            local offsetX = offsetVec:Dot(entryRight)
            local offsetY = offsetVec:Dot(entryUp) -- offset vertical dans le repère local du portail d'entrée

            -- Appliquer des corrections de position spécifiques selon l'orientation du portail de sortie
            -- (inspiré de projected_wall_entity.lua lignes 190-210)
            -- ORIENTATIONS PORTAILS :
            -- Pitch 90° = Portail au PLAFOND qui pointe vers le sol
            -- Pitch 270° = Portail au SOL qui pointe vers le plafond
            -- Pitch 0° = Portail vertical (mur)
            if exitPortalPitch == 90 then
                print("EnvPortalLaser :: RecursionLaserThroughPortals - Portail au plafond détecté")
                -- Portail au plafond (pitch = 90°) : exactement comme projected_wall_entity.lua ligne 312
                local exitRight = exitPortal:GetRight()
                local exitForward = exitPortal:GetForward()
                -- Offset latéral sur Right (négatif)
                transformedStart = transformedStart +  exitRight * (-offsetX)
                -- Offset vertical sur Forward (positif) comme dans projected_wall_entity
                transformedStart = transformedStart + exitForward * (offsetY)
                -- Corrections spécifiques selon le yaw
                if exitPortalYaw == -90 then
                    transformedStart.z = transformedStart.z - 20
                elseif exitPortalYaw > 90 and exitPortalYaw < 180 then
                    print("EnvPortalLaser :: RecursionLaserThroughPortals - Correction Y pour portail au plafond")
                elseif exitPortalYaw > -1 and exitPortalYaw < 1 then
                    -- Pas de correction X
                elseif exitPortalYaw == -180 or exitPortalYaw == 180 then
                    transformedStart.x = transformedStart.x - 20
                end
            elseif math.abs(exitPortalPitch - 270) < 10 then
                -- Portail au sol (pitch = 270°) : exactement comme projected_wall_entity.lua ligne 314
                local exitRight = exitPortal:GetRight()
                local exitForward = exitPortal:GetForward()
                -- Offset latéral sur Right (négatif)
                transformedStart = transformedStart + exitRight * (-offsetX)
                -- Offset vertical sur Forward (négatif) comme dans projected_wall_entity
                transformedStart = transformedStart - exitForward * (offsetY)
                -- Corrections spécifiques selon le yaw
                if exitPortalYaw == -90 then
                    transformedStart.y = transformedStart.y - 20
                elseif exitPortalYaw > 90 and exitPortalYaw < 180 then
                    -- Pas de correction Y
                elseif exitPortalYaw > -1 and exitPortalYaw < 1 then
                    -- Pas de correction X
                elseif exitPortalYaw == -180 or exitPortalYaw == 180 then
                    transformedStart.x = transformedStart.x - 20
                end
            else
                -- Mur : application normale des offsets
                transformedStart.z = transformedStart.z - offsetY
                transformedStart = transformedStart + exitPortal:GetRight() * offsetX
            end
            -- Correction du gap : coller le laser exactement à la face du portail de sortie
            -- (comme dans projected_wall_entity ligne 217)
            local laserThickness = 1
            transformedStart = transformedStart + exitPortal:GetForward() * (laserThickness * -30)

            newData.start = transformedStart
            newData.endpos = transformedEnd

            if isentity(data.filter) and data.filter:GetClass() ~= "player" then
                newData.filter = { data.filter, linkedPortal }
            else
                if istable(data.filter) then
                    table.insert(newData.filter, linkedPortal)
                else
                    newData.filter = linkedPortal
                end
            end

            -- Continuer récursivement pour dessiner le segment après le portail
            return RecursionLaserThroughPortals(laser, linkedPortal, newData)
        end
    end

    return tr
end

function EnvPortalLaser.Render()
    -- Vérifier si le système unifié de rendu est actif
    if EnvPortalLaser.RenderList then
        -- Le rendu est maintenant géré par le hook PostDrawTranslucentRenderables dans cl_init.lua
        -- On ajoute juste les lasers à la liste de rendu mais on ne les rend pas ici

        -- Scanner en continu pour nouveaux lasers (notamment les lasers réfléchis)
        EnvPortalLaser.ScanForNewLasers()

        for i = #laserRenderList, 1, -1 do
            local laser = laserRenderList[i]

            if not IsValid(laser) then
                table.remove(laserRenderList, i)
                laserLookups[laser] = nil
                continue
            end

            -- Ajouter à la liste de rendu globale pour un rendu unifié
            if EnvPortalLaser.RenderList then
                EnvPortalLaser.RenderList[laser] = true
                -- S'assurer que le laser a des segments pour le rendu
                if EnvPortalLaser.CreateSegmentsFromSimpleData then
                    EnvPortalLaser.CreateSegmentsFromSimpleData(laser)
                end
            end
        end
        return
    end

    -- Code de rendu original (fallback si le système unifié n'est pas disponible)
    for i = #laserRenderList, 1, -1 do
        local laser = laserRenderList[i]

        if not IsValid(laser) then
            table.remove(laserRenderList, i)
            laserLookups[laser] = nil
            continue
        end

        if not laser:GetState() then
            continue
        end

        local noModel = laser:GetNoModel()
        local modelName = laser:GetModel()
        local hitPos = laser:GetHitPos()

        if hitPos == INVALID_HIT_POS then
            continue
        end

        local attachPos
        local attachAng
        local attachForward

        if not noModel and not laserAttachmentLookups[modelName] then
            laserAttachmentLookups[modelName] = laser:LookupAttachment("laser_attachment")

            if laserAttachmentLookups[modelName] == -1 then
                print("EnvPortalLaser :: Render - laser %q with %q model has no \"laser_attachment\"", laser, modelName)
                continue
            end
        end

        if laserAttachmentLookups[modelName] ~= -1 and not noModel then
            local attach = laser:GetAttachment(laserAttachmentLookups[modelName])
            attachPos = attach.Pos
            attachAng = attach.Ang
            attachForward = attachAng:Forward()
        else
            attachPos = laser:GetPos()
            attachAng = laser:GetAngles()
            attachForward = attachAng:Forward()        end

        -- Utiliser le même matériau que cl_init.lua
        local material = Material("sprites/physbeam")
        if material:IsError() then
            material = Material("cable/cable")
        end
        render.SetMaterial(material)

        -- Le rendu du laser est maintenant géré par RecursionLaserThroughPortals
        RecursionLaserThroughPortals(laser, NULL, {
            start = attachPos,
            endpos = attachPos + attachForward * MAX_RAY_LENGTH,
            filter = {
                laser:GetParent()
            },
            mask = MASK_OPAQUE_AND_NPCS
        })
    end
end
