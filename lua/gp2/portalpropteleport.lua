-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Enhanced Portal teleport for props
-- Original code: Mee
-- Enhanced with Portal source code concepts
-- ----------------------------------------------------------------------------
local allEnts, lastEntsUpdate
local ENTS_UPDATE_INTERVAL = 0.1 -- Reduced for better responsiveness
local TRACE_AHEAD_MULTIPLIER = 0.05 -- How far ahead to trace
local MIN_VELOCITY_THRESHOLD = 25 -- Minimum velocity for transmission consideration
local MAX_OBJECTS_PER_FRAME = 8 -- Maximum objects to process per frame
-- Enhanced entity classification system inspired by Portal's trace filters
local TRANSMISSIBLE_CLASSES = {
    ["prop_physics"] = true,
    ["prop_weighted_cube"] = true,
    ["simple_physics_prop"] = true,
    ["prop_ragdoll"] = true,
    ["npc_portal_turret_floor"] = true,
    ["prop_energy_ball"] = true,
    ["simple_physics_brush"] = true,
    ["prop_monster_box"] = true
}

-- Objects that should never be transmitted
local BLOCKED_CLASSES = {
    ["player"] = true,
    ["prop_portal"] = true,
    ["projected_wall_entity"] = true,
    ["projected_tractor_beam_entity"] = true,
    ["env_portal_laser"] = true
}

-- Enhanced entity collection with Portal-style filtering
timer.Create("portals_ent_update", ENTS_UPDATE_INTERVAL, 0, function()
    if not PortalManager or PortalManager.PortalIndex < 1 then return end
    allEnts = {}
    local processedCount = 0
    for _, ent in ipairs(ents.GetAll()) do
        -- Skip invalid entities
        if IsValid(ent) then
            -- Class filtering based on Portal's entity classification
            local className = ent:GetClass()
            if not BLOCKED_CLASSES[className] and TRANSMISSIBLE_CLASSES[className] then
                -- Physics validation
                if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then -- Velocity threshold check (Portal entities must be moving)
                    local velocity = ent:GetVelocity()
                    if velocity:Length() >= MIN_VELOCITY_THRESHOLD then
                        -- Skip entities being held by players
                        if not ent:IsPlayerHolding() then
                            local shouldAdd = true
                            -- Additional checks for specific entity types
                            if className == "prop_weighted_cube" and ent:GetCubeType() then
                                -- Special handling for different cube types if needed
                            elseif className == "npc_portal_turret_floor" then
                                -- Only teleport active turrets
                                if not ent:GetEnabled() then shouldAdd = false end
                            end

                            if shouldAdd then
                                table.insert(allEnts, ent)
                                processedCount = processedCount + 1
                                -- Limit entities per frame to prevent performance issues
                                if processedCount >= MAX_OBJECTS_PER_FRAME * 4 then break end
                            end
                        end
                    end
                end
            end
        end
    end

    lastEntsUpdate = CurTime()
end)

-- Enhanced position setting function inspired by Portal's transformation system
local function portal_transform_entity(constrainedProp, editedPos, editedPropAng, editedVel)
    -- Validate entity and physics
    if not IsValid(constrainedProp) then return end
    local phys = constrainedProp:GetPhysicsObject()
    if not IsValid(phys) then return end
    -- Force player to drop the entity (prevents teleporting held objects)
    constrainedProp:ForcePlayerDrop()
    -- Handle different entity types with specific logic
    local className = constrainedProp:GetClass()
    if constrainedProp:IsRagdoll() then
        -- Special ragdoll handling (similar to Portal's ragdoll transformation)
        constrainedProp:SetAngles(editedPropAng)
        constrainedProp:SetPos(editedPos)
        for i = 0, constrainedProp:GetPhysicsObjectCount() - 1 do
            local ragdollPhys = constrainedProp:GetPhysicsObjectNum(i)
            if IsValid(ragdollPhys) then
                ragdollPhys:SetPos(editedPos, true)
                ragdollPhys:SetVelocityInstantaneous(editedVel)
                ragdollPhys:Wake() -- Ensure physics object stays active
            end
        end
    elseif className == "npc_portal_turret_floor" then
        -- Special turret handling
        phys:SetPos(editedPos, true)
        phys:SetAngles(editedPropAng)
        phys:SetVelocity(editedVel)
        phys:Wake()
        -- Reset turret state if needed
        if constrainedProp.ResetSequence then constrainedProp:ResetSequence() end
    else
        -- Standard physics object transformation
        phys:SetPos(editedPos, true)
        phys:SetAngles(editedPropAng)
        phys:SetVelocity(editedVel)
        phys:Wake()
        -- Ensure entity position is synchronized
        constrainedProp:SetPos(editedPos)
        constrainedProp:SetAngles(editedPropAng)
    end

    -- Handle portal-specific effects
    if className == "prop_energy_ball" then
        -- Energy balls might need special velocity handling
        if constrainedProp.SetBallVelocity then constrainedProp:SetBallVelocity(editedVel) end
    elseif className == "prop_weighted_cube" then
        -- Reset cube physics state to prevent sticking
        timer.Simple(0.1, function() if IsValid(constrainedProp) and IsValid(phys) then phys:Wake() end end)
    end
end

-- Portal-style ray intersection testing
local function intersect_ray_with_portal(rayStart, rayEnd, portal)
    if not IsValid(portal) then return false, Vector(), 0 end
    local portalPos = portal:GetPos()
    local portalUp = portal:GetUp()
    local portalSize = portal:GetSize()
    -- Calculate ray direction and distance
    local rayDir = (rayEnd - rayStart):GetNormalized()
    local rayLength = rayStart:Distance(rayEnd)
    -- Check if ray intersects portal plane
    local planeDot = rayDir:Dot(portalUp)
    if math.abs(planeDot) < 0.001 then -- Ray parallel to portal
        return false, Vector(), 0
    end

    -- Calculate intersection distance along ray
    local distToPlane = (portalPos - rayStart):Dot(portalUp) / planeDot
    if distToPlane < 0 or distToPlane > rayLength then return false, Vector(), 0 end
    -- Calculate intersection point
    local intersectionPoint = rayStart + rayDir * distToPlane
    -- Check if intersection point is within portal bounds
    local localPoint = portal:WorldToLocal(intersectionPoint)
    if math.abs(localPoint.x) > portalSize.x or math.abs(localPoint.y) > portalSize.y then return false, Vector(), 0 end
    return true, intersectionPoint, distToPlane / rayLength
end

-- Enhanced portal detection using Portal's ray casting approach
local function find_portal_along_ray(rayStart, rayEnd, excludePortal)
    local bestPortal = nil
    local bestFraction = 1.0
    local bestIntersection = Vector()
    for _, portal in ipairs(ents.FindByClass("prop_portal")) do
        if IsValid(portal) and portal ~= excludePortal then
            if portal:GetActivated() and IsValid(portal:GetLinkedPartner()) then
                local intersects, intersection, fraction = intersect_ray_with_portal(rayStart, rayEnd, portal)
                if intersects and fraction < bestFraction then
                    -- Check if ray is going into the front of the portal
                    local rayDir = (rayEnd - rayStart):GetNormalized()
                    local portalForward = portal:GetUp()
                    if rayDir:Dot(portalForward) < -0.1 then -- Going into portal
                        bestPortal = portal
                        bestFraction = fraction
                        bestIntersection = intersection
                    end
                end
            end
        end
    end
    return bestPortal, bestIntersection, bestFraction
end

-- Hash lookup for portal entities (faster than string comparison)
local seamless_table = {
    ["prop_portal"] = true
}

local seamless_check = function(e) return seamless_table[e:GetClass()] end
-- Enhanced main transmission logic inspired by Portal's UTIL_Portal_TraceRay
hook.Add("Tick", "enhanced_portal_teleport", function()
    if not PortalManager or PortalManager.PortalIndex < 1 or not allEnts then return end
    -- Early return if entity list is outdated
    if not lastEntsUpdate or CurTime() - lastEntsUpdate > ENTS_UPDATE_INTERVAL * 2 then return end
    local processedThisFrame = 0
    for _, prop in ipairs(allEnts) do
        if IsValid(prop) and not prop:IsPlayerHolding() then
            -- Limit processing per frame for performance
            if processedThisFrame >= MAX_OBJECTS_PER_FRAME then break end
            local propPos = prop:GetPos()
            local propVel = prop:GetVelocity()
            local propOBBMin = prop:OBBMins()
            local propOBBMax = prop:OBBMaxs()
            -- Calculate trace ahead distance based on velocity and frame time
            local traceAheadDist = propVel * TRACE_AHEAD_MULTIPLIER
            -- Enhanced trace using Portal's approach
            local traceStart = propPos - traceAheadDist
            local traceEnd = propPos + traceAheadDist
            -- First, do a hull trace to detect portal collision
            local tr = util.TraceHull({
                start = traceStart,
                endpos = traceEnd,
                mins = propOBBMin,
                maxs = propOBBMax,
                filter = seamless_check,
                ignoreworld = true,
            })

            if tr.Hit then
                local hitPortal = tr.Entity
                if IsValid(hitPortal) and hitPortal:GetClass() == "prop_portal" then
                    local linkedPortal = hitPortal:GetLinkedPartner()
                    if IsValid(linkedPortal) then
                        -- Enhanced size and velocity checks
                        local portalSize = hitPortal:GetSize()
                        local maxOBBDimension = math.max(propOBBMax.x - propOBBMin.x, propOBBMax.y - propOBBMin.y)
                        local maxPortalDimension = math.min(portalSize.x * 2, portalSize.y * 2)
                        -- Object must fit through portal
                        if maxOBBDimension <= maxPortalDimension then
                            -- Check velocity direction (must be moving toward portal)
                            local velocityDotNormal = propVel:Dot(hitPortal:GetUp())
                            if velocityDotNormal < -0.5 then
                                -- Process all constrained entities (ropes, welds, etc.)
                                local constrainedEntities = constraint.GetAllConstrainedEntities(prop)
                                for _, constrainedProp in pairs(constrainedEntities) do
                                    if IsValid(constrainedProp) then
                                        -- Transform position and angles through portal
                                        local transformedPos, transformedAng = PortalManager.TransformPortal(hitPortal, linkedPortal, constrainedProp:GetPos(), constrainedProp:GetAngles())
                                        -- Transform velocity through portal
                                        local _, transformedVelAngle = PortalManager.TransformPortal(hitPortal, linkedPortal, nil, constrainedProp:GetVelocity():Angle())
                                        -- Calculate final velocity with proper magnitude preservation
                                        local originalVelMagnitude = constrainedProp:GetVelocity():Length()
                                        local gravityComponent = linkedPortal:GetUp():Dot(-physenv.GetGravity() / 3)
                                        local finalVelMagnitude = math.max(originalVelMagnitude, gravityComponent)
                                        local finalVelocity = transformedVelAngle:Forward() * finalVelMagnitude
                                        -- Apply the transformation
                                        portal_transform_entity(constrainedProp, transformedPos, transformedAng, finalVelocity)
                                        -- Trigger portal events if the entity supports them
                                        if hitPortal.TriggerOutput then hitPortal:TriggerOutput("OnEntityTeleportFromMe", constrainedProp) end
                                        if linkedPortal.TriggerOutput then linkedPortal:TriggerOutput("OnEntityTeleportToMe", constrainedProp) end
                                    end
                                    -- end if IsValid(constrainedProp)
                                end

                                processedThisFrame = processedThisFrame + 1
                            end
                        end
                    end
                end
            end
        end
    end
end)
