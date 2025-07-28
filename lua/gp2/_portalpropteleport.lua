-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Portal teleport for props
-- Original code: Mee
-- ----------------------------------------------------------------------------

local allEnts, lastEntsUpdate
local ENTS_UPDATE_INTERVAL = 0.5 -- Passe de 0.25s à 0.5s pour réduire la charge

timer.Create("portals_ent_update", ENTS_UPDATE_INTERVAL, 0, function()
    if not PortalManager or PortalManager.PortalIndex < 1 then return end
    local portals = ents.FindByClass("prop_portal")
    allEnts = {}
    for _, ent in ipairs(ents.GetAll()) do
        -- Filtrage plus strict dès le départ
        if not ent:IsValid() then goto continue end
        if not ent.GetPhysicsObject or not ent:GetPhysicsObject():IsValid() then goto continue end
        if ent:GetVelocity():IsZero() then goto continue end
        local class = ent:GetClass()
        if class == "player" or class == "prop_portal" then goto continue end
        table.insert(allEnts, ent)
        ::continue::
    end
    lastEntsUpdate = CurTime()
end)

-- stolen from infinite map
local function unfucked_setpos(constrainedProp, editedPos, editedPropAng, editedVel)
    -- source engine cancels velocity for some reason
    local phys = constrainedProp:GetPhysicsObject()
    if phys:IsValid() then
        phys:SetPos(editedPos, true)
        phys:SetAngles(editedPropAng)
        phys:SetVelocity(editedVel)
    end

    -- ragdoll moment
    if constrainedProp:IsRagdoll() then
        constrainedProp:SetAngles(editedPropAng)
        constrainedProp:SetPos(editedPos)
        for i = 0, constrainedProp:GetPhysicsObjectCount() - 1 do
            local phys = constrainedProp:GetPhysicsObjectNum(i)
            phys:SetPos(editedPos, true)
            phys:SetVelocityInstantaneous(editedVel)
        end
    end
end

-- Hash lookup is way faster than sting compare
local seamless_table = {["prop_portal"] = true}
local seamless_check = function(e) return seamless_table[e:GetClass()] end    -- for traces

-- Dans le hook Tick, on évite de traiter si la liste n'est pas à jour
hook.Add("Tick", "seamless_portal_teleport", function()
    if not PortalManager or PortalManager.PortalIndex < 1 or not allEnts then return end
    -- Early return si la liste n'a pas été mise à jour récemment
    if not lastEntsUpdate or CurTime() - lastEntsUpdate > ENTS_UPDATE_INTERVAL * 2 then return end
    for _, prop in ipairs(allEnts) do
        if not prop or not prop:IsValid() then goto continue end
        if prop:IsPlayerHolding() then goto continue end
        local realPos = prop:GetPos()
        local obbVel = prop:GetVelocity(); obbVel:Mul(0.02)
        local obbMin = prop:OBBMins()
        local obbMax = prop:OBBMax()
        local tr = util.TraceHull({
            start       = realPos - obbVel,
            endpos      = realPos + obbVel,
            mins        = obbMin,
            maxs        = obbMax,
            filter      = seamless_check,
            ignoreworld = true,
        })
        if not tr.Hit then goto continue end
        local hitPortal = tr.Entity
        if hitPortal:GetClass() ~= "prop_portal" then goto continue end
        local hitPortalExit = tr.Entity:GetLinkedPartner()
        if hitPortalExit and hitPortalExit:IsValid() and obbMax[1] < hitPortal:GetSize()[1] * 2 and obbMax[2] < hitPortal:GetSize()[2] * 2 and prop:GetVelocity():Dot(hitPortal:GetUp()) < -0.5 then
            local constrained = constraint.GetAllConstrainedEntities(prop)
            for k, constrainedProp in pairs(constrained) do
                local editedPos, editedPropAng = PortalManager.TransformPortal(hitPortal, hitPortalExit, constrainedProp:GetPos(), constrainedProp:GetAngles())
                local _, editedVel = PortalManager.TransformPortal(hitPortal, hitPortalExit, nil, constrainedProp:GetVelocity():Angle())
                local max = math.Max(constrainedProp:GetVelocity():Length(), hitPortalExit:GetUp():Dot(-physenv.GetGravity() / 3))
                constrainedProp:ForcePlayerDrop()
                unfucked_setpos(constrainedProp, editedPos, editedPropAng, editedVel:Forward() * max)
            end
        end
        ::continue::
    end
end)