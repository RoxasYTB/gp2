-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Thermal Discouragement Beam
-- ----------------------------------------------------------------------------

include "shared.lua"

local CalcClosestPointOnLineSegment = GP2.Utils.CalcClosestPointOnLineSegment
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

    local material = Material("sprites/physbeam")
    local whiteMaterial = Material("sprites/physbeam")
    local debugMaterial = Material("sprites/bluelaser1")

    for i, segment in ipairs(self.LaserSegments) do
        -- Couleur rouge pour le faisceau principal
        local color = Color(104, 6, 6)
        -- Couleur bleue pour les segments de debug (invisibles normalement)
        local debugColor = color

        -- Faisceau principal
        render.SetMaterial(material)
        render.DrawBeam(segment.start, segment.endpos, 8, 0, 1, color)

        -- Ligne blanche intérieure
        render.SetMaterial(whiteMaterial)
        render.DrawBeam(segment.start, segment.endpos, 1, 0, 1, Color(255, 255, 255, 255))
        render.DrawBeam(segment.start, segment.endpos, 1, 0, 1, Color(234, 0, 255))


    end
end

-- Hook pour le rendu global des lasers
hook.Add("PostDrawOpaqueRenderables", "EnvPortalLaser_Render", function()
    for laser, _ in pairs(EnvPortalLaser.RenderList) do
        if IsValid(laser) and laser:GetState() then
            laser:DrawLaserSegments()
        else
            EnvPortalLaser.RenderList[laser] = nil
        end
    end
end)

function ENT:StartSparkParticle()
    if not IsValid(self.SparksParticle) then
        self.SparksParticle = CreateParticleSystem(self, "discouragement_beam_sparks", PATTACH_CUSTOMORIGIN)
    end
end

function ENT:StartParticles()
    if IsValid(self:GetParentLaser()) then
        self.Particle = CreateParticleSystem(self, "reflector_start_glow", PATTACH_ABSORIGIN_FOLLOW)
    else
        self.Particle = CreateParticleSystem(self, "laser_start_glow", PATTACH_POINT_FOLLOW,
            self:LookupAttachment("laser_attachment"))
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
