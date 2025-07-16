-- GP2 Portal Prop Ghosts (client)
-- Gère l'affichage des ghosts de props traversant les portails

local ghosts = {}

net.Receive("GP2_PortalPropGhost", function()
    local portal = net.ReadEntity()
    local prop = net.ReadEntity()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local model = net.ReadString()
    if not IsValid(portal) or not IsValid(prop) then return end
    if ghosts[prop] and IsValid(ghosts[prop]) then return end    local ghost = ClientsideModel(model, RENDERGROUP_OPAQUE)
    if not IsValid(ghost) then return end
    ghost:SetPos(pos)
    ghost:SetAngles(ang)
    ghost:SetParent(nil)
    ghost:SetNoDraw(false)
    ghost:SetRenderMode(RENDERMODE_NORMAL)
    ghost:SetColor(Color(255,255,255,255))
    -- Améliorer l'éclairage du ghost
    ghost:SetSkin(0)
    ghost:SetMaterial("")
    ghost:SetModelScale(prop:GetModelScale() or 1, 0)
    ghosts[prop] = ghost
    ghost._portal = portal
    ghost._prop = prop
end)

net.Receive("GP2_PortalPropGhostRemove", function()
    local portal = net.ReadEntity()
    local prop = net.ReadEntity()
    if ghosts[prop] and IsValid(ghosts[prop]) then
        ghosts[prop]:Remove()
        ghosts[prop] = nil
    end
end)

hook.Add("Think", "GP2_PortalPropGhostThink", function()
    for prop, ghost in pairs(ghosts) do
        if not IsValid(prop) or not IsValid(ghost) or not IsValid(ghost._portal) then
            if IsValid(ghost) then ghost:Remove() end
            ghosts[prop] = nil
        else            -- Met à jour la position du ghost en temps réel
            local portal = ghost._portal
            -- Transformation entrée → sortie (corrigé avec symétrie axiale)
            local exit = portal:GetLinkedPartner()
            if IsValid(exit) then
                -- Utilise la transformation axiale correcte au lieu de la transformation simple
                local newPos, newAng = PortalManager.TransformPortal(portal, exit, prop:GetPos(), prop:GetAngles())
                ghost:SetPos(newPos)
                ghost:SetAngles(newAng)
            end
        end
    end
end)

-- Cleanup auto
timer.Create("GP2_PortalPropGhostCleanup", 10, 0, function()
    for prop, ghost in pairs(ghosts) do
        if not IsValid(prop) or not IsValid(ghost) then
            if IsValid(ghost) then ghost:Remove() end
            ghosts[prop] = nil
        end
    end
end)
