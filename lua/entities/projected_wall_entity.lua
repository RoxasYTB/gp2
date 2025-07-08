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
end

function ENT:Initialize()
    if SERVER then
        self.TraceFraction = 0
        self:SetModel("models/props_junk/PopCan01a.mdl")
        -- Stocke la hauteur d'origine uniquement sur l'entité principale
        if not self.IsPortalClone then
            self.OriginalWallZ = self:GetPos().z
        end
        self.LastLoggedOffsetZ = nil -- Ajout pour limiter le flood
    end
    self:AddEffects(EF_NODRAW)
end

function ENT:Think()
    if self.IsPortalClone then
        -- Un clone ne doit pas faire de trace ni de clonage
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
    local bestExitPortalZ = nil
    local bestPortalClonePos, bestPortalCloneAng, bestPortalCloneLinked = nil, nil, nil
    local finalOffsetZ = nil
    local firstExitPortalZ = nil
    local lastOffsetReceivedZ = self:GetFinalOffsetZ() or 0


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
            local exitPortalZ = exitPortal:GetPos().z
            local entryDiff = math.abs(portalZ - originalWallZ)
            local offsetZ = portalZ - originalWallZ
            -- On garde l'offset du portail dont entryPortalZ est le plus proche de originalWallZ
            if (offsetZ ~= 0) and (bestEntryPortalZDiff == nil or entryDiff < bestEntryPortalZDiff) then
                bestEntryPortalZDiff = entryDiff
                bestOffsetZ = offsetZ
                -- IMPORTANT : ne jamais setter self:SetFinalOffsetZ côté serveur ailleurs que dans le net.Receive ci-dessous !
                if SERVER then
                    net.Receive("ProjectedWall_SetOffset", function(len, ply)
                        local ent    = net.ReadEntity()
                        local offset = net.ReadFloat()
                        if IsValid(ent) then
                            ent:SetFinalOffsetZ(offset)
                            print("[GP2][DEBUG][SERVER] Offset reçu du client : ", offset, " (GetFinalOffsetZ()=", ent:GetFinalOffsetZ(), ")")
                            lastOffsetReceivedZ = offset
                        end
                    end)
                end
                print ("[GP2][DEBUG] lastOffsetReceivedZ : " .. tostring(lastOffsetReceivedZ))
                print("[GP2][DEBUG] Meilleur offset trouvé : " .. lastOffsetReceivedZ .. " isServeur=" .. tostring(SERVER))
                bestExitPortalZ = exitPortalZ
                if firstExitPortalZ == nil then
                    firstExitPortalZ = exitPortalZ
                end
                -- On stocke aussi la position/angle/parent pour ce portail
               if SERVER then
                    -- On utilise TransformPortal pour obtenir la position et l'angle corrects
                    local newPos, newAng = PortalManager.TransformPortal(entryPortal, exitPortal, hitPos, currentAng)
                    bestPortalClonePos = newPos
                    bestPortalClonePos.z = bestPortalClonePos.z - lastOffsetReceivedZ  -- Force Z à la valeur du portail de sortie
                    bestPortalCloneAng = newAng
                    bestPortalCloneLinked = exitPortal
                end

            end
            currentPos, currentAng = PortalManager.TransformPortal(entryPortal, exitPortal, hitPos, currentAng)
            lastEntity = exitPortal

            break -- Ajout : on sort de la boucle après le premier passage portail

        end
    end

    -- Après avoir parcouru tous les portails, on fixe l’offset final
    if bestOffsetZ then
        if CLIENT then
            -- Envoi la valeur calculée au serveur
            net.Start("ProjectedWall_SetOffset")
                net.WriteEntity(self)
                net.WriteFloat(bestOffsetZ)
            net.SendToServer()
            if self.SetFinalOffsetZ then
                self:SetFinalOffsetZ(bestOffsetZ)
            end
        end
        self.LastFinalOffsetZ = bestOffsetZ
        if self.LastLoggedOffsetZ ~= bestOffsetZ then
            self.LastLoggedOffsetZ = bestOffsetZ
            print("[GP2][DEBUG] finalOffsetZ mis à jour : " .. bestOffsetZ)
        end
    end

    -- Correction : s'assurer que tr est toujours défini
    if not tr then
        tr = { Fraction = 1, HitPos = currentPos + currentAng:Forward() * MAX_RAY_LENGTH, Entity = NULL }
    end

    -- création du clone (même logique client et serveur pour LastFinalOffsetZ)
    if SERVER then
        -- Utiliser uniquement la valeur synchronisée par le client, ne jamais setter ici !
        local finalZ = self:GetFinalOffsetZ()
        local foundPortalEntIndex = self.LastFoundPortalEntity and self.LastFoundPortalEntity:IsValid() and self.LastFoundPortalEntity:EntIndex() or "nil"
        print(string.format(
            "[GP2][DEBUG] SERVER Think — foundPortal=%s, finalZ=%s, pos=%s, foundPortalEntIndex=%s",
            tostring(foundPortal),
            tostring(finalZ),
            tostring(bestPortalClonePos),
            tostring(foundPortalEntIndex)
        ))
        if foundPortal and bestPortalClonePos and bestPortalCloneAng and bestPortalCloneLinked then
            -- On force Z à la valeur du portail de sortie
            bestPortalClonePos.z = bestPortalClonePos.z
            -- Création / mise à jour unique du clone
            if not self.PortalClone or not IsValid(self.PortalClone) then
                print("[GP2][DEBUG] Aucun clone existant, on en crée un nouveau.")
                local clone = ents.Create("projected_wall_entity")
                if IsValid(clone) then
                    print("[GP2][DEBUG] Spawn clone at " .. tostring(bestPortalClonePos))
                    clone:SetPos(bestPortalClonePos)
                    clone:SetAngles(bestPortalCloneAng)
                    clone:Spawn()
                    clone:CreateWall() -- Ajout : génère la collision du clone
                    clone:SetParent(bestPortalCloneLinked)
                    clone.IsPortalClone = true
                    clone.OriginalWallZ = self.OriginalWallZ
                    self.PortalClone = clone
                    self.PortalCloneLinked = bestPortalCloneLinked
                    print("[GP2][DEBUG] Clone créé, parent=" .. tostring(bestPortalCloneLinked))
                    print("[GP2][DEBUG] Hauteur du clone du projected wall : " .. tostring(clone:GetPos().z))
                end
            else
                print("[GP2][DEBUG] Clone existant, on met à jour sa position.")
                self.PortalClone:SetPos(bestPortalClonePos)
                self.PortalClone:SetAngles(bestPortalCloneAng)
                print("[GP2][DEBUG] Hauteur du clone du projected wall (update) : " .. tostring(self.PortalClone:GetPos().z))
            end
        else
            -- Pas de portail valide : suppression du clone s’il existe
            if self.PortalClone and IsValid(self.PortalClone) then
                print("[GP2][DEBUG] Aucun portail valide, suppression du clone existant.")
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
        print("[GP2][DEBUG] projected_wall_entity " .. tostring(self) .. " : OnRemove, suppression du clone.")
        self.PortalClone:Remove()
        self.PortalClone = nil
        self.PortalCloneLinked = nil
    end
    if self.IsPortalClone then
        print("[GP2][DEBUG] projected_wall_entity " .. tostring(self) .. " : OnRemove appelé sur un clone.")
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