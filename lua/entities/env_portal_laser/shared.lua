-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Thermal Discouragement Beam
-- ----------------------------------------------------------------------------

AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "#env_portal_laser_short"
ENT.Category = "Portal 2"
ENT.Spawnable = true
ENT.Editable = true

-- Network string pour les segments de laser
if SERVER then
    util.AddNetworkString("LaserSegments")
end

util.PrecacheSound("Flesh.BulletImpact")
-- Précacher les particules seulement si elles existent
local particlesToPrecache = {
    "reflector_start_glow",
    "laser_start_glow",
    "laser_relay_powered",
    "discouragement_beam_sparks"
}

-- Fonction helper pour vérifier l'existence d'un système de particules
local function ParticleSystemExists(name)
    -- On essaie de précacher et on capture les erreurs
    local success = pcall(PrecacheParticleSystem, name)
    return success
end

for _, particleName in ipairs(particlesToPrecache) do
    if ParticleSystemExists(particleName) then
        -- Déjà précaché dans la vérification
    else
        print("[GP2] Avertissement: Système de particules '" .. particleName .. "' non trouvé")
    end
end

-- Fonction pour vérifier et utiliser les particules de fallback
function ENT:GetParticleNameOrFallback(particleName, fallback)
    -- Fonction helper pour vérifier l'existence d'un système de particules
    local function ParticleExists(name)
        local success = pcall(PrecacheParticleSystem, name)
        return success
    end

    if ParticleExists(particleName) then
        return particleName
    elseif fallback and ParticleExists(fallback) then
        return fallback
    else
        return nil
    end
end

function ENT:SetupDataTables()
    self:NetworkVar(
        "Bool",
        "State",
        {
            KeyName = "state",
            Edit = {
                type = "Bool",
                order = 1
            }
        }
    )
    self:NetworkVar("Bool", "LethalDamage")
    self:NetworkVar("Bool", "AutoAim")
    self:NetworkVar("Bool", "ShouldSpark")
    self:NetworkVar("Bool", "NoModel")
    self:NetworkVar("Vector", "HitPos")
    self:NetworkVar("Vector", "HitNormal")
    self:NetworkVar("Entity", "ParentLaser")
    self:NetworkVar("Entity", "ChildLaser")
    self:NetworkVar("Entity", "Reflector")

    self:NetworkVarNotify("State", self.OnStateChange)

    if SERVER then
        self:SetShouldSpark(true)
        self:SetState(true)
        self:SetHitPos(Vector(2 ^ 16, 2 ^ 16, 2 ^ 16))
    end
end
