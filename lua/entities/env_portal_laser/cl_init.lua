-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Thermal Discouragement Beam
-- ----------------------------------------------------------------------------

include "shared.lua"

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

-- Recevoir les segments de laser du serveur
net.Receive("LaserSegments", function()
    local laser = net.ReadEntity()
    if not IsValid(laser) then return end

    local numSegments = net.ReadUInt(8)
    laser.LaserSegments = {}

    for i = 1, numSegments do
        local startPos = net.ReadVector()
        local endPos = net.ReadVector()
        table.insert(laser.LaserSegments, {
            start = startPos,
            endpos = endPos
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

        -- Largeur du laser principal
        local mainWidth = 8
        -- Largeur du glow
        local glowWidth = 18

        -- Couleur principale (rouge Portal 2)
        local color = Color(104, 6, 6, 255)
        -- Couleur du glow (plus clair, alpha dégradé)
        local glowColor = Color(255, 80, 80, 120)

        -- Si c'est le segment de continuité (généralement le dernier)
        if i == #self.LaserSegments then
            -- Glow autour du beam
            render.SetMaterial(glowMaterial)
            render.DrawBeam(segment.start, segment.endpos, glowWidth, 0, 1, glowColor)
            -- Beam principal
            render.SetMaterial(material)
            render.DrawBeam(segment.start, segment.endpos, mainWidth, 0, 1, color)
        else
            -- Segments normaux
            render.SetMaterial(material)
            render.DrawBeam(segment.start, segment.endpos, mainWidth, 0, 1, color)
        end

        -- Ligne blanche intérieure pour le style Portal
        render.SetMaterial(material)
        render.DrawBeam(segment.start, segment.endpos, 2, 0, 1, Color(255, 255, 255, 180))
    end
end

-- Hook pour le rendu global des lasers
hook.Add("PostDrawOpaqueRenderables", "EnvPortalLaser_Render", function()
    -- Protection contre les erreurs de rendu
    local success, err = pcall(function()
        for laser, _ in pairs(EnvPortalLaser.RenderList) do
            if IsValid(laser) and laser:GetState() and laser.DrawLaserSegments then
                laser:DrawLaserSegments()
            else
                EnvPortalLaser.RenderList[laser] = nil
            end
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
            if ent.LaserSegments and #ent.LaserSegments > 0 then
                ent:DrawLaserSegments()
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

-- Timer pour forcer l'actualisation régulière
if not timer.Exists("GP2_ForceLaserRefresh") then
    timer.Create("GP2_ForceLaserRefresh", 1, 0, RefreshAllPortalLasers)
end
