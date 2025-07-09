-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Tractor Beam
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "anim"

local MAX_RAY_LENGTH = 8192
local PROJECTED_BEAM_RADIUS = 54
local PROJECTED_BEAM_SIDES = 32

local debugNormalColor = Color(64,160,255,2)
local debugReversedColor = Color(255,160,64,2)

local developer = GetConVar("developer")

ENT.PhysicsSolidMask = CONTENTS_SOLID+CONTENTS_MOVEABLE+CONTENTS_BLOCKLOS

PrecacheParticleSystem("projected_wall_impact")

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", "Updated" )
    self:NetworkVar( "Bool", "GotInitialPosition" )
    self:NetworkVar( "Vector", "InitialPosition" )
    self:NetworkVar( "Float", "DistanceToHit" )
    self:NetworkVar( "Float", "Radius" )
    self:NetworkVar( "Float", "_LinearForce" )

    if SERVER then
        self:SetRadius(PROJECTED_BEAM_RADIUS)
    end
end

function ENT:Initialize()
    if SERVER then
        self.TraceFraction = 0
        self:SetModel("models/props_junk/PopCan01a.mdl")
        -- mémoriser la hauteur d’origine pour le calcul d’offset Z
        self.OrigZ = self:GetPos().z
    else
        -- Force update on client spawn
        self:SetUpdated(false)
    end
    self:AddEffects(EF_NODRAW)
end

function ENT:Think()
    -- Sécurise l'initialisation de self.OrigZ si jamais il est nil (cas rare ou clone mal initialisé)
    if not self.OrigZ then self.OrigZ = self:GetPos().z end

    if self.IsPortalClone then
        -- Un clone ne doit pas faire de trace, ni de trigger, ni de clonage
        if SERVER then
            -- Décoinceur minimal (optionnel, à adapter si besoin)
            local physMins, physMaxs = self:GetCollisionBounds()
            local beamPos = self:GetPos()
            local beamAng = self:GetAngles()
            local minsWorld = beamPos + beamAng:Forward() * physMins.x + beamAng:Right() * physMins.y + beamAng:Up() * physMins.z
            local maxsWorld = beamPos + beamAng:Forward() * physMaxs.x + beamAng:Right() * physMaxs.y + beamAng:Up() * physMaxs.z
            local expand = 0
            local boxMins = Vector(math.min(minsWorld.x, maxsWorld.x) - expand, math.min(minsWorld.y, maxsWorld.y) - expand, math.min(minsWorld.z, maxsWorld.z) - expand)
            local boxMaxs = Vector(math.max(minsWorld.x, maxsWorld.x) + expand, math.max(minsWorld.y, maxsWorld.y) + expand, math.max(minsWorld.z, maxsWorld.z) + expand)
            for _, ply in ipairs(ents.FindInBox(boxMins, boxMaxs)) do
                if ply:IsPlayer() and ply:Alive() and not ply:IsFlagSet(FL_GODMODE) then
                    local plyPos = ply:GetPos()
                    ply:SetPos(plyPos + Vector(0, 0, 1))
                    ply:SetVelocity(Vector(0, 0, 0))
                end
            end
        end
        return
    end

    if not self:GetUpdated() then
        self:CreateBeam()
        self:SetUpdated(true)
    end
    
    if CLIENT then
        self:SetNextClientThink(CurTime())
        if ProjectedTractorBeamEntity and ProjectedTractorBeamEntity.IsAdded and ProjectedTractorBeamEntity.AddToRenderList then
            if not ProjectedTractorBeamEntity.IsAdded(self) then
                ProjectedTractorBeamEntity.AddToRenderList(self)
            end
        end
    end

    -- Nouvelle logique : détection du premier portail avec FindAlongRay
    local rayStart = self:GetPos()
    local rayEnd   = rayStart + self:GetAngles():Forward() * MAX_RAY_LENGTH
    local extents  = Vector(10,10,10)
    local hits     = ents.FindAlongRay(rayStart, rayEnd, -extents, extents)
    local foundPortal, bestPortalClonePos, bestPortalCloneAng, bestPortalCloneLinked, distanceRestante = false
    for _, ent in ipairs(hits) do
        if ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
            local entry, exit = ent, ent:GetLinkedPartner()
            -- Point d'impact exact
            local mins, maxs = entry:GetCollisionBounds()
            local hitPos = util.IntersectRayWithOBB(
                rayStart, (rayEnd-rayStart):GetNormalized(),
                entry:GetPos(), entry:GetAngles(),
                mins, maxs
            ) or entry:GetPos()
            -- Calcul des offsets locaux de l’impact dans l’espace du portail d’entrée
            local localHit = entry:WorldToLocal(hitPos)
            -- Transformation à travers le portail
            local newPos, newAng = PortalManager.TransformPortal(entry, exit, hitPos, self:GetAngles())
            -- Récupérer les axes du portail de sortie
            local eAng    = exit:GetAngles()
            local eRight  = eAng:Right()
            local eUp     = eAng:Up()
            local eForward= eAng:Forward()
            -- Appliquer les mêmes offsets relatifs
            newPos = newPos
                + eRight   * localHit.y      -- droite/gauche
                + eUp      * localHit.z      -- haut/bas
                - eForward * 1               -- coller au mur
            -- Calcul distance restante
            local distDone = (hitPos - self:GetPos()):Length()
            distanceRestante = MAX_RAY_LENGTH - distDone
            bestPortalClonePos = newPos
            bestPortalCloneAng = newAng
            bestPortalCloneLinked = exit
            foundPortal = true
            break
        end
    end

    -- Création/mise à jour du clone
    if SERVER then
        if foundPortal and bestPortalClonePos and bestPortalCloneAng and bestPortalCloneLinked then
            if not self.PortalClone or not IsValid(self.PortalClone) or self.PortalCloneLinked ~= bestPortalCloneLinked then
                if self.PortalClone and IsValid(self.PortalClone) then
                    self.PortalClone:Remove()
                end
                local clone = ents.Create("projected_tractor_beam_entity")
                if IsValid(clone) then
                    clone.IsPortalClone = true
                    clone.OrigZ = self.OrigZ -- Copie la hauteur d'origine pour le calcul d'offset Z
                    clone:SetPos(bestPortalClonePos)
                    clone:SetAngles(bestPortalCloneAng)
                    clone:SetRadius(self:GetRadius())
                    clone:SetLinearForce(self:Get_LinearForce())
                    clone:Spawn()
                    clone:SetParent(bestPortalCloneLinked)
                    clone:CreateBeam(distanceRestante)
                    self.PortalClone = clone
                    self.PortalCloneLinked = bestPortalCloneLinked
                end
            else
                self.PortalClone:SetPos(bestPortalClonePos)
                self.PortalClone:SetAngles(bestPortalCloneAng)
                self.PortalClone:SetRadius(self:GetRadius())
                self.PortalClone:SetLinearForce(self:Get_LinearForce())
                self.PortalClone:CreateBeam(distanceRestante)
            end
        else
            if self.PortalClone and IsValid(self.PortalClone) then
                self.PortalClone:Remove()
                self.PortalClone = nil
                self.PortalCloneLinked = nil
            end
        end
    end

    -- Mise à jour du beam principal (pour le rendu, debug, etc)
    local fwd = self:GetAngles():Forward()
    local tr = util.TraceLine({
        start = rayStart,
        endpos = rayStart + fwd * MAX_RAY_LENGTH,
        mask = MASK_SOLID_BRUSHONLY,
    })
    if self.TraceFraction ~= tr.Fraction then
        self:SetUpdated(false)
        self.TraceFraction = tr.Fraction
        if developer:GetBool() then
            debugoverlay.Cross(tr.HitPos, 16, 0.1, nil, true)
        end
    end
    self:NextThink(CurTime())
    return true
end

function ENT:Draw()
end

function ENT:OnRemove()
    if CLIENT then
        if self.Mesh and self.Mesh:IsValid() then
            self.Mesh:Destroy()
        end
        -- Remove from render list
        if ProjectedTractorBeamEntity and ProjectedTractorBeamEntity.Beams then
            ProjectedTractorBeamEntity.Beams[self] = nil
        end
    end

    if SERVER then
        if self.Trigger and IsValid(self.Trigger) then
            self.Trigger:Remove()
        end
        if self.PortalClone and IsValid(self.PortalClone) then
            self.PortalClone:Remove()
            self.PortalClone = nil
            self.PortalCloneLinked = nil
        end
    end
end

function ENT:CreateBeam(distance)
    distance = distance or 0

    local startPos = self:GetPos()
    local angles = self:GetAngles()
    local fwd = angles:Forward()
    local right = angles:Right()
    local up = angles:Up()

    local tr = util.TraceLine({
        start = startPos,
        endpos = startPos + fwd * MAX_RAY_LENGTH,
        mask = MASK_SOLID_BRUSHONLY,
    })

    if CLIENT then
        self.HitData = { HitPos = tr.HitPos, Angles = self:GetAngles(), Radius = self:GetRadius(), Sides = PROJECTED_BEAM_SIDES }
    end

    local hitPos = tr.HitPos
    local distance = hitPos:Distance(startPos)
    local v = -distance / 256
    self:SetDistanceToHit(distance)

    if SERVER and not self.IsPortalClone then
        -- Création d'une collision physique pour permettre la détection par trace (!entname)
        -- On génère un tube/cylindre simple pour PhysicsInitConvex
        local sides = PROJECTED_BEAM_SIDES
        local radius = self:GetRadius()
        local length = distance
        if length < 1 then length = MAX_RAY_LENGTH end -- fallback si distance n'est pas encore calculée

        local startLocal = Vector(0, 0, 0)
        local endLocal = Vector(0, 0, length)
        local convex = {}

        for i = 0, sides - 1 do
            local angle = (2 * math.pi) * (i / sides)
            local x = math.cos(angle) * radius
            local y = math.sin(angle) * radius
            table.insert(convex, startLocal + Vector(x, y, 0))
        end
        for i = 0, sides - 1 do
            local angle = (2 * math.pi) * (i / sides)
            local x = math.cos(angle) * radius
            local y = math.sin(angle) * radius
            table.insert(convex, endLocal + Vector(x, y, 0))
        end

        self:PhysicsInitConvex(convex)
        self:SetSolid(SOLID_VPHYSICS)
        self:EnableCustomCollisions(true)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:SetMass(1)
        end
    end

    if CLIENT then
        local verts = {}
        local angleStep = (2 * math.pi) / PROJECTED_BEAM_SIDES
        for i = 0, PROJECTED_BEAM_SIDES - 1 do
            local angle = i * angleStep
            local nextAngle = (i + 1) % PROJECTED_BEAM_SIDES * angleStep

            local radius = self:GetRadius()

            local xOffset = math.cos(angle) * radius
            local yOffset = math.sin(angle) * radius
            local xNextOffset = math.cos(nextAngle) * radius
            local yNextOffset = math.sin(nextAngle) * radius

            local v1 = startPos + right * xOffset + up * yOffset
            local v2 = startPos + right * xNextOffset + up * yNextOffset
            local v3 = hitPos + right * xNextOffset + up * yNextOffset
            local v4 = hitPos + right * xOffset + up * yOffset

            local u1 = i / PROJECTED_BEAM_SIDES
            local u2 = (i + 1) / PROJECTED_BEAM_SIDES
            local uv1 = {0, u1}
            local uv2 = {0, u2}
            local uv3 = {v, u2}
            local uv4 = {v, u1}            
            GP2.Utils.AddFace(verts, v1, v2, v3, v4, uv1, uv2, uv3, uv4)
        end

        if self.Mesh and self.Mesh:IsValid() then
            self.Mesh:Destroy()
        end

        self.Mesh = Mesh()
        self.Mesh:BuildFromTriangles(verts)
        
        -- Assurez-vous que ProjectedTractorBeamEntity est initialisé
        if ProjectedTractorBeamEntity and ProjectedTractorBeamEntity.AddToRenderList then
            ProjectedTractorBeamEntity.AddToRenderList(self, self.Mesh)
        end
    end

    local radius =  self:GetRadius()    if SERVER then
        if self.Trigger and IsValid(self.Trigger) then
            local pos = self:GetPos()
            local ang = self:GetAngles()

            local fwd = angles:Forward()
            local right = angles:Right()
            local up = angles:Up()

            local mins = pos - right * radius - up * radius
            local maxs = pos + right * radius + up * radius + fwd * distance

            self.Trigger:SetCollisionBoundsWS(mins, maxs)
            self.Trigger:SetAngles(self:GetAngles())
            self.Trigger.LinearForce = self:Get_LinearForce()

            if developer:GetBool() then
                debugoverlay.BoxAngles(pos, self:WorldToLocal(mins), self:WorldToLocal(maxs), ang, 0.1, self:Get_LinearForce() < 0 and debugReversedColor or debugNormalColor) 
            end
        else
            self.Trigger = ents.Create("trigger_tractorbeam")
            self.Trigger:Spawn()
            self.Trigger:SetPos(self:GetPos())
            self.Trigger:SetParent(self)
            self.Trigger:SetTractorBeam(self)
            self.Trigger.LinearForce = self:Get_LinearForce()

            local pos = self:GetPos()
            local ang = self:GetAngles()

            local fwd = angles:Forward()
            local right = angles:Right()
            local up = angles:Up()

            local mins = pos - right * radius - up * radius
            local maxs = pos + right * radius + up * radius + fwd * distance
           
            self.Trigger:SetCollisionBoundsWS(mins, maxs)
            self.Trigger:SetAngles(self:GetAngles())

            if developer:GetBool() then
                debugoverlay.BoxAngles(pos, self:WorldToLocal(mins), self:WorldToLocal(maxs), ang, 0.1, self:Get_LinearForce() < 0 and debugReversedColor or debugNormalColor) 
            end
        end
    end
end

if SERVER then
    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end

    function ENT:SetLinearForce(force)
        self:Set_LinearForce(force)
        self:SetUpdated(false)
    end
end