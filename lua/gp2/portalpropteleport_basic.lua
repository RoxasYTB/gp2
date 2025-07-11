-- GP2 Framework - Original Portal Prop Teleport (Minimal Working Version)
-- Restored to ensure basic functionality while EOT is being fixed

local allEnts, lastEntsUpdate = {}, 0
local ENTS_UPDATE_INTERVAL = 0.1

-- Basic entity collection
timer.Create("portals_ent_update", ENTS_UPDATE_INTERVAL, 0, function()
    if not PortalManager or PortalManager.PortalIndex < 1 then return end
    
    allEnts = {}
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetPhysicsObject() and IsValid(ent:GetPhysicsObject()) then
            local class = ent:GetClass()
            if class == "prop_physics" or class == "prop_weighted_cube" or 
               class == "simple_physics_prop" or class == "prop_ragdoll" then
                table.insert(allEnts, ent)
            end
        end
    end
    lastEntsUpdate = CurTime()
end)

-- Basic teleport function
local function teleportEntity(ent, hitPortal, linkedPortal)
    if not IsValid(ent) or not IsValid(hitPortal) or not IsValid(linkedPortal) then return end
    
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local transformedPos, transformedAng = PortalManager.TransformPortal(
        hitPortal, linkedPortal, ent:GetPos(), ent:GetAngles()
    )
    
    local _, transformedVelAngle = PortalManager.TransformPortal(
        hitPortal, linkedPortal, nil, ent:GetVelocity():Angle()
    )
    
    local velMagnitude = ent:GetVelocity():Length()
    local finalVelocity = transformedVelAngle:Forward() * math.max(velMagnitude, 50)
    
    -- Force drop from players
    ent:ForcePlayerDrop()
    
    -- Apply transformation
    phys:SetPos(transformedPos, true)
    phys:SetAngles(transformedAng)
    phys:SetVelocity(finalVelocity)
    phys:Wake()
    
    ent:SetPos(transformedPos)
    ent:SetAngles(transformedAng)
end

-- Main teleport hook
local seamless_check = function(e) return e:GetClass() == "prop_portal" end

hook.Add("Tick", "gp2_basic_portal_teleport", function()
    if not PortalManager or PortalManager.PortalIndex < 1 or not allEnts then return end
    
    for _, prop in ipairs(allEnts) do
        if not IsValid(prop) or prop:IsPlayerHolding() then continue end
        
        local propPos = prop:GetPos()
        local propVel = prop:GetVelocity()
        
        if propVel:Length() < 25 then continue end
        
        local tr = util.TraceHull({
            start = propPos - propVel * 0.05,
            endpos = propPos + propVel * 0.05,
            mins = prop:OBBMins(),
            maxs = prop:OBBMaxs(),
            filter = seamless_check,
            ignoreworld = true,
        })
        
        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_portal" then
            local hitPortal = tr.Entity
            local linkedPortal = hitPortal:GetLinkedPartner()
            
            if IsValid(linkedPortal) and hitPortal:GetActivated() then
                -- Check direction
                if propVel:Dot(hitPortal:GetUp()) < -0.5 then
                    teleportEntity(prop, hitPortal, linkedPortal)
                end
            end
        end
    end
end)

print("[GP2] Basic portal prop teleport system loaded as fallback")
