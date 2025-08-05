-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Trigger Tractor beams
-- ----------------------------------------------------------------------------

ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.TouchingEnts = {}
ENT.TractorBeam = NULL
ENT.PortalImmunity = ENT.PortalImmunity or {}

local TRACTOR_BEAM_VALID_ENTS = {
    --["player"] = true, -- player movement handled by Move hook
    ["prop_physics"] = true,
    ["func_physbox"] = true,
    ["prop_monster_box"] = true,
    ["prop_weighted_cube"] = true,
    ["npc_personality_core"] = true,
    ["npc_portal_turret_floor"] = true,
    ["prop_ragdoll"] = true,
    ["prop_exploding_futbol"] = true,
    ["npc_grenade_frag"] = true,
    ["npc_manhack"] = true,
    ["npc_cscanner"] = true,
    ["npc_clawscanner"] = true,
    ["npc_rollermine"] = true,
}

local COLLISION_GROUP_BEAM = COLLISION_GROUP_WORLD -- collision group utilisé pour ignorer les collisions dans la beam
ENT.OriginalCollisionGroups = {}

function ENT:Initialize()
    self:SetSolid(SOLID_BBOX)
    self:SetTrigger(true)
    self.passedPortal = false
end

function ENT:SetTractorBeam(tbeam)
    self.TractorBeam = tbeam
end

function ENT:Think()
    if not self.TractorBeam or not IsValid(self.TractorBeam) then
        self:Remove()
        return
    end

    local mins, maxs = self:GetCollisionBounds()

    local fwd = self:GetAngles():Forward()
    local right = self:GetAngles():Right()
    self.DistanceToHit = math.abs((maxs - mins):Dot(right))

    for i = #self.TouchingEnts, 1, -1 do
        local ent = self.TouchingEnts[i]

        if not IsValid(ent) then
            table.remove(self.TouchingEnts, i)

            if ent:IsPlayer() then
                GP2.GameMovement.PlayerExitedFromTractorBeam(ent, self)
            end
        else
            self:ProcessEntity(ent)
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:StartTouch(ent)
    if IsValid(self.TractorBeam) then
        if (TRACTOR_BEAM_VALID_ENTS[ent:GetClass()]) then
            table.insert(self.TouchingEnts, ent)
            -- Désactive les collisions pour les entités non-joueurs
            if not ent:IsPlayer() then
                self.OriginalCollisionGroups[ent] = ent:GetCollisionGroup()
                ent:SetCollisionGroup(COLLISION_GROUP_BEAM)
            end
        elseif ent:IsPlayer() then
            GP2.GameMovement.PlayerEnteredToTractorBeam(ent, self)

            if self.sndPlayerInBeam then
                self.sndPlayerInBeam:Stop()
            end

            local filter = RecipientFilter(true)
            filter:AddPlayer(ent)

            self.sndPlayerInBeam = CreateSound(ent, "VFX.PlayerEnterTbeam", filter)
            self.sndPlayerInBeam:Play()
        elseif ent:IsNPC() or ent:IsNextBot() or ent:IsVehicle() then
            table.insert(self.TouchingEnts, ent)
            -- Désactive les collisions pour les entités non-joueurs
            if not ent:IsPlayer() then
                self.OriginalCollisionGroups[ent] = ent:GetCollisionGroup()
                ent:SetCollisionGroup(COLLISION_GROUP_BEAM)
            end
        end
    end
end

function ENT:ProcessEntity(ent)
    -- Détection du contact avec un prop_portal (distance)
    local entPos = ent:GetPos()
    local immunityEnd = self.PortalImmunity[ent]
    local now = CurTime()
    local isNearPortal = false

    for _, portal in ipairs(ents.FindInSphere(entPos, 64)) do
        if IsValid(portal) and portal:GetClass() == "prop_portal" then
            local portalPos = portal:GetPos()
            local dist = entPos:Distance(portalPos)
            if dist > 50 then
                self.passedPortal = false
            end
            if dist < 48 then
                isNearPortal = true

                if dist > 2 and (not immunityEnd or now > immunityEnd) and self.passedPortal == false then

                         -- Déplacement progressif (1 unité max par tick)
                    local direction = (portalPos - entPos):GetNormalized()
                    local step = math.min(1, dist)
                    local newPos = entPos + direction * step
                    ent:SetPos(newPos)
                end
                if dist < 2 and (not immunityEnd or now > immunityEnd) then
                    -- Immunité temporaire (ex: 1 seconde) après passage dans le portail
                    self.PortalImmunity[ent] = now + 5
                    self.passedPortal = true
                end
                break
            end
        end
    end
    -- Si l'entité n'est plus proche d'un portail, on retire l'immunité (pour éviter fuite mémoire)
    if immunityEnd and not isNearPortal then
        self.PortalImmunity[ent] = nil
    end

    -- Le beam applique toujours ses forces, même si l'entité est immunisée au rapprochement portail
    local phys = ent:GetPhysicsObject()

    local entPos = ent:WorldSpaceCenter()
    local centerPos = self:WorldSpaceCenter()
    local angles = self:GetAngles()

    local toCenter = centerPos - entPos
    local sidewayForce = angles:Right() * toCenter:Dot(angles:Right()) + angles:Up() * toCenter:Dot(angles:Up())
    local baseForce = (self.LinearForce or 0) * 0.5
    local forwardForce = angles:Forward() * baseForce

    local totalForce

    if (TRACTOR_BEAM_VALID_ENTS[ent:GetClass()] or ent:IsVehicle()) and IsValid(phys) then
        local normalizedForwardForce = forwardForce:GetNormalized()

        local mins, maxs = ent:GetCollisionBounds()
        local boxSize = (maxs - mins):Length()

        local trMovementFrontFace = entPos + normalizedForwardForce * (boxSize / 2)

        local tr = util.QuickTrace(trMovementFrontFace, normalizedForwardForce * boxSize, {self, ent})

        if tr.Fraction < 0.1 then
            totalForce = sidewayForce
        else
            totalForce = (forwardForce + sidewayForce) * tr.Fraction
            phys:AddAngleVelocity((forwardForce + sidewayForce) * tr.Fraction / phys:GetMass())
        end

        phys:Wake()
        phys:SetVelocity(totalForce)
        phys:SetAngleVelocity(totalForce)
    else
        totalForce = forwardForce + sidewayForce
        ent:SetLocalVelocity(totalForce)
    end

    ent:SetGroundEntity(NULL)
end

function ENT:EndTouch(ent)
    table.RemoveByValue(self.TouchingEnts, ent)
    -- Ne retire plus l'immunité ici, elle est gérée dans ProcessEntity selon la distance au portail
    -- Restaure le groupe de collision d'origine si ce n'est pas un joueur
    if not ent:IsPlayer() and self.OriginalCollisionGroups[ent] then
        ent:SetCollisionGroup(self.OriginalCollisionGroups[ent])
        self.OriginalCollisionGroups[ent] = nil
    end
    if ent:IsPlayer() then
        GP2.GameMovement.PlayerExitedFromTractorBeam(ent, self)

        if self.sndPlayerInBeam then
            self.sndPlayerInBeam:FadeOut(5)
        end
    end
end

function ENT:OnRemove()
    if self.sndPlayerInBeam then
        self.sndPlayerInBeam:Stop()
    end
end