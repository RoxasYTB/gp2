-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Thermal Discouragement Beam
-- ----------------------------------------------------------------------------

include "shared.lua"

ENT = ENT or {}

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
local clamp = math.Clamp

-- Table globale pour stocker les lasers qui doivent être rendus
EnvPortalLaser = EnvPortalLaser or {}
EnvPortalLaser.RenderList = EnvPortalLaser.RenderList or {}

function EnvPortalLaser.AddToRenderList(laser)
    if IsValid(laser) then
        EnvPortalLaser.RenderList[laser] = true
    end
end

function EnvPortalLaser.RemoveFromRenderList(laser)
    EnvPortalLaser.RenderList[laser] = nil
end

-- Fonction pour actualiser la liste de rendu avec tous les lasers actifs
function EnvPortalLaser.RefreshRenderList()
    -- Scanner tous les lasers existants à chaque frame pour capturer les lasers réfléchis
    for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
        if IsValid(ent) and ent:GetState() then
            EnvPortalLaser.RenderList[ent] = true
            -- S'assurer que tous les lasers ont des segments compatibles
            EnvPortalLaser.CreateSegmentsFromSimpleData(ent)
        end
    end
end

-- Fonction pour créer des segments de laser depuis les données simples (pour compatibilité avec env_portal_laser.lua)
function EnvPortalLaser.CreateSegmentsFromSimpleData(laser)
    if not IsValid(laser) then return end

    -- Si le laser a déjà des segments du serveur, les utiliser
    if laser.LaserSegments and #laser.LaserSegments > 0 then
        return
    end

    -- Sinon, créer un segment simple basé sur les données de base
    local startPos = laser:GetPos()
    local hitPos = laser:GetHitPos()

    -- Vérifier si les données sont valides
    local INVALID_HIT_POS = Vector(2 ^ 16, 2 ^ 16, 2 ^ 16)
    if hitPos == INVALID_HIT_POS then
        return
    end

    -- Vérifier si ce segment termine sur un portail ET peut l'atteindre
    local hitsPortal = false
    local canReachPortal = true
    local entsAtEnd = ents.FindInSphere(hitPos, 15)

    for _, ent in ipairs(entsAtEnd) do
        if IsValid(ent) and ent:GetClass() == "prop_portal" then
            hitsPortal = true

            -- Vérifier si le laser peut réellement atteindre ce portail
            local traceToPortal = util.TraceLine({
                start = startPos,
                endpos = hitPos,
                filter = function(checkEnt)
                    return checkEnt ~= laser and checkEnt:GetClass() ~= "env_portal_laser"
                end,
                mask = MASK_OPAQUE_AND_NPCS
            })

            -- Si quelque chose bloque le chemin
            if traceToPortal.Hit and traceToPortal.Entity ~= ent then
                canReachPortal = false
            end
            break
        end
    end

    -- Créer un segment simple avec les informations de portail
    laser.LaserSegments = {
        {
            start = startPos,
            endpos = hitPos,
            hitsPortal = hitsPortal,
            canReachPortal = canReachPortal
        }
    }
end

-- Recevoir les segments de laser du serveur
net.Receive("LaserSegments", function()
    local laser = net.ReadEntity()
    if not IsValid(laser) then return end

    local numSegments = net.ReadUInt(8)
    laser.LaserSegments = {}

    for i = 1, numSegments do
        local startPos = net.ReadVector()
        local endPos = net.ReadVector()
        local hitsPortal = net.ReadBool()
        local canReachPortal = net.ReadBool()

        table.insert(laser.LaserSegments, {
            start = startPos,
            endpos = endPos,
            hitsPortal = hitsPortal,
            canReachPortal = canReachPortal
        })
    end
end)

function ENT:Initialize()
    if self:GetState() then
        self:StartParticles()
        self:StartLoopingSounds()
    end
end

function ENT:OnRemove()
    self:StopParticles()
    self:StopLoopingSounds()
    -- Retirer de la liste de rendu
    EnvPortalLaser.RemoveFromRenderList(self)
end

function ENT:Think()
    -- Ajouter ce laser à la liste de rendu
    EnvPortalLaser.AddToRenderList(self)

    -- S'assurer que le laser a des segments pour le rendu
    EnvPortalLaser.CreateSegmentsFromSimpleData(self)

    -- Si c'est un laser réfléchi (avec un parent), forcer la mise à jour plus fréquente
    if IsValid(self:GetParentLaser()) then
        -- Forcer l'actualisation des segments depuis le serveur plus souvent
        self:SetNextClientThink(CurTime() + 0.001) -- 1ms pour les lasers réfléchis
    else
        self:SetNextClientThink(CurTime() + 0.016) -- ~60 FPS pour les lasers principaux
    end

    self:ChangeVolumeByDistanceToBeam()

    if self:GetShouldSpark() and self.LaserSegments and #self.LaserSegments > 0 then
        self:StartSparkParticle()
        local finalSegment = self.LaserSegments[#self.LaserSegments]
        if IsValid(self.SparksParticle) then
            self.SparksParticle:SetControlPointOrientation(0, self:GetHitNormal():Angle())
            self.SparksParticle:SetControlPoint(0, finalSegment.endpos)
        end
        -- Dessiner la ligne invisible entre le portail de sortie et le sparkle
        render.SetMaterial(Material("sprites/physbeam"))
        render.DrawBeam(finalSegment.start, finalSegment.endpos, 2, 0, 1, Color(255,255,255,0))
    else
        if IsValid(self.SparksParticle) then
            self.SparksParticle:StopEmission()
            self.SparksParticle = NULL
        end
    end

    return true
end

-- Fonction de rendu des segments de laser
function ENT:DrawLaserSegments()
    if not self.LaserSegments or #self.LaserSegments == 0 then return end

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

    for i, segment in ipairs(self.LaserSegments) do
        if not segment.start or not segment.endpos then continue end

        local start = segment.start
        local endpos = segment.endpos

        -- Correction micro-coupure du halo : traitement spécial pour les collisions avec portails
        if #self.LaserSegments > 1 then
            local dir = (endpos - start):GetNormalized()

            -- Premier segment : si il termine sur un portail ET qu'il peut l'atteindre, étendre davantage
            if i == 1 then
                local extension = (segment.hitsPortal and segment.canReachPortal ~= false) and 20 or 12
                endpos = endpos + dir * extension
            end

            -- Segments intermédiaires : étendre dans les deux directions
            if i > 1 and i < #self.LaserSegments then
                start = start - dir * 0
                local extension = (segment.hitsPortal and segment.canReachPortal ~= false) and 16 or 8
                endpos = endpos + dir * extension
            end

            -- Dernier segment : si il part d'un portail, étendre vers l'arrière
            if i == #self.LaserSegments then
                local extension = 12
                -- Si le segment précédent terminait sur un portail ET qu'il pouvait l'atteindre, étendre davantage
                if i > 1 and self.LaserSegments[i-1].hitsPortal and self.LaserSegments[i-1].canReachPortal ~= false then
                    extension = 20
                end
                start = start - dir * 6.05
            end
        elseif segment.hitsPortal and segment.canReachPortal ~= false then
            -- Segment unique qui termine sur un portail ET peut l'atteindre
            local dir = (endpos - start):GetNormalized()
            endpos = endpos + dir * 15
        end

        -- Largeur du laser principal
        local mainWidth = 8
        -- Largeur du glow
        local glowWidth = 18

        -- Couleur principale (rouge Portal 2)
        local color = Color(104, 6, 6, 255)
        -- Couleur du glow (plus clair, alpha dégradé)
        local glowColor = Color(255, 80, 80, 120)

        -- Glow autour du beam (pour tous les segments)
        render.SetMaterial(glowMaterial)
        render.DrawBeam(start, endpos, glowWidth, 0, 1, glowColor)

        -- Beam principal (pour tous les segments)
        render.SetMaterial(material)
        render.DrawBeam(start, endpos, mainWidth, 0, 1, color)

        -- Ligne blanche intérieure pour le style Portal
        render.SetMaterial(material)
        render.DrawBeam(start, endpos, 2, 0, 1, Color(255, 255, 255, 255))
    end
end

-- Hook pour le rendu global des lasers
hook.Add("PostDrawTranslucentRenderables", "EnvPortalLaser_Render", function()
    -- Protection contre les erreurs de rendu
    local success, err = pcall(function()
        -- Actualiser la liste de rendu à chaque frame pour capturer tous les lasers
        EnvPortalLaser.RefreshRenderList()

        -- Rendu des lasers de la RenderList du système d'entité
        for laser, _ in pairs(EnvPortalLaser.RenderList) do
            if IsValid(laser) and laser.GetState and laser:GetState() then
                if laser.DrawLaserSegments then
                    laser:DrawLaserSegments()
                end
            else
                EnvPortalLaser.RenderList[laser] = nil
            end
        end

        -- Rendu des lasers du système env_portal_laser.lua (lasers clonés)
        if EnvPortalLaser and EnvPortalLaser.Render then
            -- Désactiver temporairement le rendu de base pour éviter la duplication
            local originalRender = EnvPortalLaser.Render
            EnvPortalLaser.Render = function() end

            -- Restaurer après ce frame
            timer.Simple(0, function()
                EnvPortalLaser.Render = originalRender
            end)
        end
    end)

    if not success then
        print("[GP2] Erreur lors du rendu des lasers: " .. tostring(err))
    end
end)

function ENT:StartSparkParticle()
    if not IsValid(self.SparksParticle) then
        -- Utiliser le système de fallback pour les particules
        local particleName = self:GetParticleNameOrFallback("discouragement_beam_sparks", "explosion_turret_break")
        if particleName then
            self.SparksParticle = CreateParticleSystem(self, particleName, PATTACH_CUSTOMORIGIN)
        end
    end
end

function ENT:StartParticles()
    -- Vérifier que les particules existent avant de les créer
    if IsValid(self:GetParentLaser()) then
        local particleName = self:GetParticleNameOrFallback("reflector_start_glow", "explosion_turret_break")
        if particleName then
            self.Particle = CreateParticleSystem(self, particleName, PATTACH_ABSORIGIN_FOLLOW)
        end
    else
        local particleName = self:GetParticleNameOrFallback("laser_start_glow", "explosion_turret_break")
        if particleName then
            self.Particle = CreateParticleSystem(self, particleName, PATTACH_POINT_FOLLOW,
                self:LookupAttachment("laser_attachment"))
        end
    end

    self:StartSparkParticle()
end

function ENT:StopParticles()
    if IsValid(self.Particle) then
        self.Particle:StopEmission()
    end

    if IsValid(self.SparksParticle) then
        self.SparksParticle:StopEmission()
    end
end

function ENT:StartLoopingSounds()
    if not self.BeamSound then
        self.BeamSound = CreateSound(self, "Laser.BeamLoop")
        self.BeamSound:SetSoundLevel(0)
        self.BeamSound:PlayEx(0, 100)
    end
end

function ENT:StopLoopingSounds()
    if self.BeamSound then
        self.BeamSound:Stop()
        self.BeamSound = nil
    end
end

function ENT:ChangeVolumeByDistanceToBeam()
    local pos = EyePos()
    local nearest = CalcClosestPointOnLineSegment(pos, self:GetPos(), self:GetHitPos())
    local distance = (pos - nearest):Length()

    local maxDistance = 400
    local minVolume = 0
    local maxVolume = 0.25

    -- Volume based on the distance
    local volume = clamp((maxDistance - distance) / maxDistance * (maxVolume - minVolume) + minVolume, minVolume, maxVolume)

    if self.BeamSound then
        if not self.BeamSound:IsPlaying() then
            self.BeamSound:PlayEx(volume, 100)
        else
            self.BeamSound:ChangeVolume(volume)
        end
    end
end

function ENT:OnStateChange(name, old, new)
    if new then
        self:StartParticles()
        self:StartLoopingSounds()
    else
        self:StopParticles()
        self:StopLoopingSounds()
    end
end

-- Actualisation forcée des lasers après chargement et nettoyage
local function RefreshAllPortalLasers()
    for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
        if IsValid(ent) then
            EnvPortalLaser.AddToRenderList(ent)
            -- S'assurer que tous les lasers ont des segments compatibles
            EnvPortalLaser.CreateSegmentsFromSimpleData(ent)
            if ent.LaserSegments and #ent.LaserSegments > 0 then
                -- Le rendu sera géré par le hook PostDrawTranslucentRenderables
            end
        end
    end
end

-- Hook après le chargement des entités
hook.Add("InitPostEntity", "GP2_RefreshPortalLasers", function()
    timer.Simple(0.5, RefreshAllPortalLasers)
end)

-- Hook après le nettoyage de la map
hook.Add("PostCleanupMap", "GP2_RefreshPortalLasers_Cleanup", function()
    timer.Simple(0.5, RefreshAllPortalLasers)
end)

-- Hook pour détecter immédiatement la création de nouveaux lasers (notamment réfléchis)
hook.Add("OnEntityCreated", "GP2_DetectNewLasers", function(ent)
    if IsValid(ent) and ent:GetClass() == "env_portal_laser" then
        -- Attendre que l'entité soit complètement initialisée
        timer.Simple(0.1, function()
            if IsValid(ent) then
                EnvPortalLaser.AddToRenderList(ent)
                EnvPortalLaser.CreateSegmentsFromSimpleData(ent)
                print("[GP2] Nouveau laser détecté et ajouté au rendu: " .. tostring(ent))
            end
        end)
    end
end)

-- Timer pour forcer l'actualisation régulière et détecter les nouveaux lasers
if not timer.Exists("GP2_ForceLaserRefresh") then
    timer.Create("GP2_ForceLaserRefresh", 0.033, 0, function() -- ~30 FPS pour les scans
        RefreshAllPortalLasers()
        -- Scanner spécifiquement les lasers réfléchis qui peuvent apparaître dynamiquement
        for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
            if IsValid(ent) and ent:GetState() then
                EnvPortalLaser.AddToRenderList(ent)
                EnvPortalLaser.CreateSegmentsFromSimpleData(ent)
            end
        end
    end)
end

if not ENT.GetHitPos then
    function ENT:GetHitPos()
        -- Si le trace n'est pas défini, retourne la position de l'entité
        if self.TraceResult and self.TraceResult.HitPos then
            return self.TraceResult.HitPos
        end
        return self:GetPos() -- fallback
    end
end

-- Patch global pour les entités env_portal_laser créées dynamiquement
hook.Add("OnEntityCreated", "GP2_EnsureGetHitPosAndState", function(ent)
    if IsValid(ent) and ent:GetClass() == "env_portal_laser" then
        if not ent.GetHitPos then
            function ent:GetHitPos()
                if self.TraceResult and self.TraceResult.HitPos then
                    print("[GP2] Warning: GetHitPos called on env_portal_laser without TraceResult")
                    return self.TraceResult.HitPos

                end
                return self:GetPos()
            end
        end
        if not ent.GetState then
            function ent:GetState()
                return self.State or false
            end
        end
    end
end)
