-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Hard light surface
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "anim"

local MAX_RAY_LENGTH = 8192
local PROJECTED_WALL_WIDTH = 72

ENT.PhysicsSolidMask = CONTENTS_SOLID+CONTENTS_MOVEABLE+CONTENTS_BLOCKLOS

PrecacheParticleSystem("projected_wall_impact")

if SERVER then
    util.AddNetworkString("ProjectedWall_SetOffset")
end

function ENT:SetupDataTables()
    self:NetworkVar( "Bool", "Updated" )
    self:NetworkVar( "Bool", "GotInitialPosition" )
    self:NetworkVar( "Vector", "InitialPosition" )
    self:NetworkVar( "Float", "DistanceToHit" )
    self:NetworkVar( "Float", "FinalOffsetZ" ) -- Pour synchronisation client/serveur
    self:NetworkVar( "Float", "FinalOffsetX" ) -- Pour synchronisation client/serveur (gauche/droite)
end

function ENT:Initialize()
    if SERVER then
        self.TraceFraction = 0
        self:SetModel("models/props_junk/PopCan01a.mdl")
        -- Stocke la hauteur d'origine uniquement sur l'entité principale
        if not self.IsPortalClone then
            self.OriginalWallZ = self:GetPos().z
            self.OriginalWallX = self:GetPos().x
        end
        self.LastLoggedOffsetZ = nil -- Ajout pour limiter le flood
    end
    self:AddEffects(EF_NODRAW)
end

function ENT:Think()
    if self.IsPortalClone then
        -- Un clone ne doit pas faire de trace ni de clonage
        -- Décoinceur de joueurs coincés dans le mur projeté (appliqué aussi au clone)
        if SERVER then
            local physMins, physMaxs = self:GetCollisionBounds()
            local wallPos = self:GetPos()
            local wallAng = self:GetAngles()
            -- Calculer la bounding box en coordonnées monde
            local minsWorld = wallPos + wallAng:Forward() * physMins.x + wallAng:Right() * physMins.y + wallAng:Up() * physMins.z
            local maxsWorld = wallPos + wallAng:Forward() * physMaxs.x + wallAng:Right() * physMaxs.y + wallAng:Up() * physMaxs.z
            local expand = 0
            local boxMins = Vector(math.min(minsWorld.x, maxsWorld.x) - expand, math.min(minsWorld.y, maxsWorld.y) - expand, math.min(minsWorld.z, maxsWorld.z))
            local boxMaxs = Vector(math.max(minsWorld.x, maxsWorld.x) + expand, math.max(minsWorld.y, maxsWorld.y) + expand, math.min(minsWorld.z, maxsWorld.z))
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
        self:CreateWall()
    end

    if CLIENT then
        self:SetNextClientThink(CurTime())
        if ProjectedWallEntity and not ProjectedWallEntity.IsAdded(self) then
            self:CreateWall()
        end
    end

    local startPos = self:GetPos()
    -- Utilise la hauteur d'origine stockée, sinon fallback sur la position actuelle
    local originalWallZ = self.OriginalWallZ or startPos.z
    local originalWallX = self.OriginalWallX or startPos.x
    local angles = self:GetAngles()
    local fwd = angles:Forward()
    local totalDistance = 0
    local maxBounces = 1
    local currentPos = startPos
    local currentAng = angles
    local lastEntity = self
    local foundPortal = false
    local tr
    local bestEntryPortalZDiff = nil
    local bestOffsetZ = nil
    local bestOffsetX = nil
    local bestExitPortalZ = nil
    local bestExitPortalX = nil
    local bestPortalClonePos, bestPortalCloneAng, bestPortalCloneLinked = nil, nil, nil
    local finalOffsetZ = nil
    local firstExitPortalZ = nil
    local lastOffsetReceivedZ = self:GetFinalOffsetZ() or 0
    local lastOffsetReceivedX = self:GetFinalOffsetX() or 0


    for bounce = 1, maxBounces do
        -- Utilisation de ents.FindAlongRay pour une détection plus fiable comme le laser
        local rayStart = currentPos
        local rayEnd = currentPos + currentAng:Forward() * MAX_RAY_LENGTH
        local extents = Vector(10, 10, 10)
        local found = false
        local foundPortalEntity = nil
        local foundPortalTr = nil
        local rayHits = ents.FindAlongRay(rayStart, rayEnd, -extents, extents)
        for _, ent in ipairs(rayHits) do
            if IsValid(ent) then
                if ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
                    found = true
                    foundPortalEntity = ent
                    break
                end
            end
        end
        if found and foundPortalEntity then
            -- Passage à travers le portail
            foundPortal = true
            -- Correction : stocker le portail de sortie (exitPortal) pour le bloc serveur
            local exitPortal = foundPortalEntity:GetLinkedPartner()
            self.LastFoundPortalEntity = exitPortal
            local entryPortal = exitPortal:GetLinkedPartner()
            -- Calcul du point d'impact réel sur le portail d'entrée
            local mins, maxs = entryPortal:GetCollisionBounds()
            local hitPos = util.IntersectRayWithOBB(
                rayStart,
                (rayEnd - rayStart):GetNormalized(),
                entryPortal:GetPos(),
                entryPortal:GetAngles(),
                mins, maxs
            )
            if not hitPos then
                hitPos = entryPortal:GetPos()
            end
            local portalZ = entryPortal:GetPos().z
            local portalX = entryPortal:GetPos().x
            local exitPortalZ = exitPortal:GetPos().z
            local exitPortalX = exitPortal:GetPos().x
            local entryDiffZ = math.abs(portalZ - originalWallZ)
            -- Décalage local gauche/droite (Right) dans le repère du portail d'entrée
            local entryRight = entryPortal:GetRight() -- axe local X du portail
            local offsetVec = startPos - entryPortal:GetPos()
            local offsetXLocal = offsetVec:Dot(entryRight) -- décalage sur l'axe Right du portail
            local offsetZ = portalZ - originalWallZ
            -- On garde l'offset du portail dont entryPortalZ est le plus proche de originalWallZ
            if (offsetZ ~= 0 or math.abs(offsetXLocal) > 0.001) and (bestEntryPortalZDiff == nil or entryDiffZ < bestEntryPortalZDiff) then
                bestEntryPortalZDiff = entryDiffZ
                bestOffsetZ = offsetZ
                bestOffsetX = offsetXLocal
                -- IMPORTANT : ne jamais setter self:SetFinalOffsetZ/X côté serveur ailleurs que dans le net.Receive ci-dessous !
                if SERVER then
                    net.Receive("ProjectedWall_SetOffset", function(len, ply)
                        local ent    = net.ReadEntity()
                        local offsetZ = net.ReadFloat()
                        local offsetX = net.ReadFloat()
                        if IsValid(ent) then
                            ent:SetFinalOffsetZ(offsetZ)
                            ent:SetFinalOffsetX(offsetX)
                            lastOffsetReceivedZ = offsetZ
                            lastOffsetReceivedX = offsetX
                        end
                    end)
                end
               bestExitPortalZ = exitPortalZ
                bestExitPortalX = exitPortalX
                if firstExitPortalZ == nil then
                    firstExitPortalZ = exitPortalZ
                end
                -- On stocke aussi la position/angle/parent pour ce portail
                if SERVER then
                    local newPos, newAng = PortalManager.TransformPortal(entryPortal, exitPortal, hitPos, currentAng)
                    -- Correction de l'angle pour faire face à la direction du portail au lieu d'être dos au portail
                    newAng = Angle(newAng.p, newAng.y + 180, newAng.r)

                    -- Correction spécifique pour les portails au plafond ou au sol
                    local exitPortalPitch = exitPortal:GetAngles().p
                    if math.abs(exitPortalPitch - 90) < 10 then
                        -- Portail au sol (pitch ~90) : inverser pour aller vers le haut
                        newAng = Angle(-newAng.p, newAng.y, newAng.r)
                    elseif math.abs(exitPortalPitch + 90) < 10 then
                        -- Portail au plafond (pitch ~-90) : inverser pour aller vers le bas
                        newAng = Angle(-newAng.p, newAng.y, newAng.r)
                    end
                   bestPortalClonePos = newPos
                    bestPortalClonePos.z = bestPortalClonePos.z    -- Force Z à la valeur du portail de sortie
                    -- Appliquer un décalage sur Y en fonction de l'orientation du portail de sortie
                    local exitRight = exitPortal:GetRight()
                    -- Si l'axe Right pointe vers le haut (z > 0), on ajoute 20, sinon on soustrait 20
                    local exitAngY = exitPortal:GetAngles().y
                    if exitAngY == -90 then
                        bestPortalClonePos.y = bestPortalClonePos.y - 20
                    end
                    if exitAngY > 90 and exitAngY < 180 then
                        bestPortalClonePos.y = bestPortalClonePos.y + 20
                    end
                    if exitAngY > -1 and exitAngY < 1 then
                        bestPortalClonePos.x = bestPortalClonePos.x + 20
                    end
                    if exitAngY == -180 then
                        bestPortalClonePos.x = bestPortalClonePos.x - 20
                    end
                    -- Appliquer l'offset X local sur l'axe Right du portail de sortie
                    bestPortalClonePos = bestPortalClonePos + exitPortal:GetRight() * (-(lastOffsetReceivedX or 0))
                    -- Correction du gap : coller le mur exactement à la face du portail de sortie
                    local wallThickness = 1 -- épaisseur du mur projeté (voir PhysicsInitConvex)
                    bestPortalClonePos = bestPortalClonePos - exitPortal:GetForward() * (wallThickness * 0.51) -- 0.51 pour éviter le z-fighting
                    bestPortalCloneAng = newAng
                    bestPortalCloneLinked = exitPortal
                end
            end
            currentPos, currentAng = PortalManager.TransformPortal(entryPortal, exitPortal, hitPos, currentAng)
            -- Correction de l'angle pour que le projected wall continue dans la direction du portail
            currentAng = Angle(currentAng.p, currentAng.y + 180, currentAng.r)

            -- Correction spécifique pour les portails au plafond ou au sol
            local exitPortalPitch = exitPortal:GetAngles().p
            if math.abs(exitPortalPitch - 90) < 10 then
                -- Portail au sol (pitch ~90) : inverser pour aller vers le haut
                currentAng = Angle(-currentAng.p, currentAng.y, currentAng.r)
            elseif math.abs(exitPortalPitch + 90) < 10 then
                -- Portail au plafond (pitch ~-90) : inverser pour aller vers le bas
                currentAng = Angle(-currentAng.p, currentAng.y, currentAng.r)
            end

            lastEntity = exitPortal

            break -- Ajout : on sort de la boucle après le premier passage portail

        end
    end

    -- Après avoir parcouru tous les portails, on fixe l’offset final
    if bestOffsetZ or bestOffsetX then
        if CLIENT then
            -- Envoi la valeur calculée au serveur
            net.Start("ProjectedWall_SetOffset")
                net.WriteEntity(self)
                net.WriteFloat(bestOffsetZ or 0)
                net.WriteFloat(bestOffsetX or 0)
            net.SendToServer()
            if self.SetFinalOffsetZ then
                self:SetFinalOffsetZ(bestOffsetZ or 0)
            end
            if self.SetFinalOffsetX then
                self:SetFinalOffsetX(bestOffsetX or 0)
            end
        end
        self.LastFinalOffsetZ = bestOffsetZ
        self.LastFinalOffsetX = bestOffsetX
        if self.LastLoggedOffsetZ ~= bestOffsetZ or self.LastLoggedOffsetX ~= bestOffsetX then
            self.LastLoggedOffsetZ = bestOffsetZ
            self.LastLoggedOffsetX = bestOffsetX
        end
    end

    -- Correction : s'assurer que tr est toujours défini
    if not tr then
        tr = { Fraction = 1, HitPos = currentPos + currentAng:Forward() * MAX_RAY_LENGTH, Entity = NULL }
    end

    -- Décoinceur de joueurs coincés dans le mur projeté
    if SERVER then
        local physMins, physMaxs = self:GetCollisionBounds()
        local wallPos = self:GetPos()
        local wallAng = self:GetAngles()
        -- Calculer la bounding box en coordonnées monde
        local minsWorld = wallPos + wallAng:Forward() * physMins.x + wallAng:Right() * physMins.y + wallAng:Up() * physMins.z
        local maxsWorld = wallPos + wallAng:Forward() * physMaxs.x + wallAng:Right() * physMaxs.y + wallAng:Up() * physMaxs.z
        -- On élargit un peu la box pour être sûr
        local expand = 0
        local boxMins = Vector(math.min(minsWorld.x, maxsWorld.x) - expand, math.min(minsWorld.y, maxsWorld.y) - expand, math.min(minsWorld.z, maxsWorld.z) - expand)
        local boxMaxs = Vector(math.max(minsWorld.x, maxsWorld.x) + expand, math.min(minsWorld.y, maxsWorld.y) + expand, math.max(minsWorld.z, maxsWorld.z) - expand)
        for _, ply in ipairs(ents.FindInBox(boxMins, boxMaxs)) do
            if ply:IsPlayer() and ply:Alive() and not ply:IsFlagSet(FL_GODMODE) then
                local plyPos = ply:GetPos()
                -- On vérifie si le joueur est vraiment dans le mur (optionnel, sinon on le monte toujours)
                -- On le remonte de 1 unité
                ply:SetPos(plyPos + Vector(0, 0, 1))
                ply:SetVelocity(Vector(0, 0, 0))
            end
        end
    end

    -- création du clone (même logique client et serveur pour LastFinalOffsetZ/X)
    if SERVER then
        -- Utiliser uniquement la valeur synchronisée par le client, ne jamais setter ici !
        local finalZ = self:GetFinalOffsetZ()
        local finalX = self:GetFinalOffsetX()
        local foundPortalEntIndex = self.LastFoundPortalEntity and self.LastFoundPortalEntity:IsValid() and self.LastFoundPortalEntity:EntIndex() or "nil"
        if foundPortal and bestPortalClonePos and bestPortalCloneAng and bestPortalCloneLinked then
            -- On force Z à la valeur du portail de sortie
            bestPortalClonePos.z = bestPortalClonePos.z
            if finalZ then bestPortalClonePos.z = bestPortalClonePos.z - finalZ end
            -- L'offset X est déjà appliqué via l'axe Right du portail de sortie plus haut
            -- Création / mise à jour unique du clone
            if not self.PortalClone or not IsValid(self.PortalClone) then
                local clone = ents.Create("projected_wall_entity")
                if IsValid(clone) then
                    clone:SetPos(bestPortalClonePos)
                    clone:SetAngles(bestPortalCloneAng)
                    clone:Spawn()
                    clone:CreateWall() -- Ajout : génère la collision du clone
                    clone:SetParent(bestPortalCloneLinked)
                    clone.IsPortalClone = true
                    clone.OriginalWallZ = self.OriginalWallZ
                    clone.OriginalWallX = self.OriginalWallX
                    self.PortalClone = clone
                    self.PortalCloneLinked = bestPortalCloneLinked
                end
            else
                self.PortalClone:SetPos(bestPortalClonePos)
                self.PortalClone:SetAngles(bestPortalCloneAng)
            end
        else
            -- Pas de portail valide : suppression du clone s’il existe
            if self.PortalClone and IsValid(self.PortalClone) then
                self.PortalClone:Remove()
                self.PortalClone = nil
                self.PortalCloneLinked = nil
            end
        end
    end

    if self.TraceFraction ~= tr.Fraction then
        self:SetUpdated(false)
        self.TraceFraction = tr.Fraction
    end

    self:NextThink(CurTime())
    return true
end



function ENT:Draw()
end

function ENT:OnRemove(fd)
    if self.WallImpact then
        self.WallImpact:StopEmissionAndDestroyImmediately()
    end
    if SERVER and self.PortalClone and IsValid(self.PortalClone) then
        self.PortalClone:Remove()
        self.PortalClone = nil
        self.PortalCloneLinked = nil
    end
    if self.IsPortalClone then
    end
end

function ENT:CreateWall()
    local startPos = self:GetPos()
    local angles = self:GetAngles()
    local fwd = angles:Forward()
    local right = angles:Right()

    local tr = util.TraceLine({
        start = startPos,
        endpos = startPos + fwd * MAX_RAY_LENGTH,
        mask = MASK_SOLID_BRUSHONLY,
    })

    local hitPos = tr.HitPos
    local distance = hitPos:Distance(startPos)
    local v = -distance / 192

    self:SetDistanceToHit(distance)

    local fullLength = (tr.HitPos - startPos):Length()
    local halfLength = fullLength / 2
    local halfWidth = PROJECTED_WALL_WIDTH / 2

    local verts_col = {
        Vector(-halfLength, -halfWidth, -1),
        Vector(-halfLength, -halfWidth, 0),
        Vector(-halfLength, halfWidth, -1),
        Vector(-halfLength, halfWidth, 0),
        Vector(fullLength, -halfWidth, -1),
        Vector(fullLength, -halfWidth, 0),
        Vector(fullLength, halfWidth, -1),
        Vector(fullLength, halfWidth, 0)
    }

    if CLIENT then
        local verts = {
            { pos = startPos - right * halfWidth, u = 1, v = 0 },
            { pos = startPos - right * halfWidth + fwd * distance, u = 1, v = v },
            { pos = startPos - right * halfWidth + fwd * distance + right * PROJECTED_WALL_WIDTH, u = 0, v = v },
            { pos = startPos + right * halfWidth + fwd * distance, u = 0, v = v },
            { pos = startPos + right * halfWidth, u = 0, v = 0 },
            { pos = startPos - right * halfWidth, u = 1, v = 0 },
        }

        if self.Mesh and self.Mesh:IsValid() then
            self.Mesh:Destroy()
        end        self.Mesh = Mesh()
        self.Mesh:BuildFromTriangles(verts)
        if ProjectedWallEntity then
            ProjectedWallEntity.AddToRenderList(self, self.Mesh)
        end
    end

    if SERVER then
        -- It don't work without it
        self:PhysicsInitStatic(6)
        self:SetUpdated(true)
    else
        if not IsValid(self.WallImpact) then
            local wallImpactAng = tr.HitNormal:Angle()

            self.WallImpact = CreateParticleSystemNoEntity("projected_wall_impact", tr.HitPos - fwd * 4, wallImpactAng)

            --idk how to work with this particle, maybe converter fucked it up
            --self.WallImpact:SetControlPoint(1, Vector(1,1,1))
        end

        if not self:GetUpdated() and IsValid(self.WallImpact) then
            self.WallImpact:StopEmissionAndDestroyImmediately()
            self.WallImpact = nil
        end
    end

    self:EnableCustomCollisions(true)
    self:PhysicsInitConvex(verts_col, "hard_light_bridge")
    self:GetPhysicsObject():EnableMotion(false)
    self:GetPhysicsObject():SetContents(CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_BLOCKLOS)
end

if SERVER then
    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end
end