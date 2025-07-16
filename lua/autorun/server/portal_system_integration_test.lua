-- Portal System Integration Test
-- Tests all components of the portal prop ghosting system

if CLIENT then return end

local function TestPortalGhostIntegration()
    print("=== Portal Ghost Integration Test ===")

    -- Test 1: Verify portal collision system is loaded
    if PortalCollisionSystem then
        print("✓ Portal collision system loaded")

        -- Test collision system functions
        if PortalCollisionSystem.DisableMapCollisions and PortalCollisionSystem.EnableMapCollisions then
            print("✓ Collision system functions available")
        else
            print("✗ Collision system functions missing")
        end
    else
        print("✗ Portal collision system not loaded")
    end

    -- Test 2: Check if prop_portal entity exists
    local portalEnt = scripted_ents.Get("prop_portal")
    if portalEnt then
        print("✓ prop_portal entity registered")

        -- Test if portal has required functions
        if portalEnt.t and portalEnt.t.CreateServerGhost then
            print("✓ CreateServerGhost function available")
        else
            print("✗ CreateServerGhost function missing")
        end

        if portalEnt.t and portalEnt.t.RecreateGhosts then
            print("✓ RecreateGhosts function available")
        else
            print("✗ RecreateGhosts function missing")
        end
    else
        print("✗ prop_portal entity not found")
    end

    -- Test 3: Check network message registration
    if util.NetworkStringToID("portal_create_ghost") > 0 then
        print("✓ portal_create_ghost network message registered")
    else
        print("✗ portal_create_ghost network message not registered")
    end

    if util.NetworkStringToID("portal_remove_ghost") > 0 then
        print("✓ portal_remove_ghost network message registered")
    else
        print("✗ portal_remove_ghost network message not registered")
    end

    -- Test 4: Check portal manager functions
    if PortalManager and PortalManager.TransformPortal then
        print("✓ PortalManager.TransformPortal available")
    else
        print("✗ PortalManager.TransformPortal missing")
    end

    print("=== Integration Test Complete ===")
end

-- Test command
concommand.Add("portal_test_integration", TestPortalGhostIntegration, nil, "Test portal ghost system integration")

-- Detailed functional test
local function TestPortalGhostFunctionality()
    print("=== Portal Ghost Functionality Test ===")

    local admin = Entity(1)
    if not IsValid(admin) then
        print("✗ Admin player not found")
        return
    end

    -- Create test prop
    local prop = ents.Create("prop_physics")
    prop:SetModel("models/props_c17/oildrum001.mdl")
    prop:SetPos(admin:GetPos() + Vector(100, 0, 50))
    prop:Spawn()
    prop:Activate()

    print("✓ Test prop created: " .. tostring(prop))

    -- Create test portals
    local portal1 = ents.Create("prop_portal")
    portal1:SetPos(admin:GetPos() + Vector(200, 0, 0))
    portal1:SetAngles(Angle(0, 180, 0))
    portal1:Spawn()
    portal1:Activate()

    local portal2 = ents.Create("prop_portal")
    portal2:SetPos(admin:GetPos() + Vector(200, 200, 0))
    portal2:SetAngles(Angle(0, 0, 0))
    portal2:Spawn()
    portal2:Activate()

    -- Link portals
    portal1:SetExit(portal2)
    portal2:SetExit(portal1)

    print("✓ Test portals created and linked")

    -- Test ghost creation
    timer.Simple(1, function()
        if IsValid(prop) and IsValid(portal1) then
            -- Move prop near portal
            prop:SetPos(portal1:GetPos() + portal1:GetForward() * -50)

            -- Test if ghost would be created
            local dist = prop:GetPos():Distance(portal1:GetPos())
            if dist < 200 then
                print("✓ Prop is within ghost creation range (" .. math.floor(dist) .. " units)")
            else
                print("✗ Prop is outside ghost creation range (" .. math.floor(dist) .. " units)")
            end
        end
    end)

    -- Test collision system
    timer.Simple(2, function()
        if IsValid(prop) and PortalCollisionSystem then
            print("Testing collision system...")

            local originalMoveType = prop:GetMoveType()
            local originalCollisionGroup = prop:GetCollisionGroup()

            -- Test disabling collisions
            PortalCollisionSystem.DisableMapCollisions(prop)

            timer.Simple(0.1, function()
                if IsValid(prop) then
                    local newMoveType = prop:GetMoveType()
                    local newCollisionGroup = prop:GetCollisionGroup()

                    if newMoveType == MOVETYPE_NOCLIP then
                        print("✓ Collision system changed movetype to NOCLIP")
                    else
                        print("✗ Collision system failed to change movetype")
                    end

                    -- Test re-enabling collisions
                    PortalCollisionSystem.EnableMapCollisions(prop)

                    timer.Simple(0.1, function()
                        if IsValid(prop) then
                            local restoredMoveType = prop:GetMoveType()
                            if restoredMoveType == originalMoveType then
                                print("✓ Collision system restored original movetype")
                            else
                                print("✗ Collision system failed to restore movetype")
                            end
                        end
                    end)
                end
            end)
        end
    end)

    -- Cleanup
    timer.Simple(5, function()
        if IsValid(prop) then prop:Remove() end
        if IsValid(portal1) then portal1:Remove() end
        if IsValid(portal2) then portal2:Remove() end
        print("✓ Test entities cleaned up")
    end)

    print("=== Functionality Test Started ===")
end

-- Functional test command
concommand.Add("portal_test_functionality", TestPortalGhostFunctionality, nil, "Test portal ghost functionality")

-- Performance test
local function TestPortalGhostPerformance()
    print("=== Portal Ghost Performance Test ===")

    local admin = Entity(1)
    if not IsValid(admin) then
        print("✗ Admin player not found")
        return
    end

    local props = {}
    local portals = {}

    -- Create multiple props and portals
    for i = 1, 10 do
        local prop = ents.Create("prop_physics")
        prop:SetModel("models/props_c17/oildrum001.mdl")
        prop:SetPos(admin:GetPos() + Vector(i * 50, 0, 50))
        prop:Spawn()
        prop:Activate()
        table.insert(props, prop)
    end

    for i = 1, 4 do
        local portal = ents.Create("prop_portal")
        portal:SetPos(admin:GetPos() + Vector(i * 100, 200, 0))
        portal:SetAngles(Angle(0, 180, 0))
        portal:Spawn()
        portal:Activate()
        table.insert(portals, portal)
    end

    print("✓ Created " .. #props .. " props and " .. #portals .. " portals")

    -- Test performance over time
    local startTime = SysTime()
    local testDuration = 10 -- seconds

    timer.Create("portal_performance_test", 1, testDuration, function()
        local elapsed = SysTime() - startTime
        local fps = 1 / RealFrameTime()

        print("Performance test " .. math.floor(elapsed) .. "s - FPS: " .. math.floor(fps))

        if elapsed >= testDuration then
            -- Cleanup
            for _, prop in ipairs(props) do
                if IsValid(prop) then prop:Remove() end
            end
            for _, portal in ipairs(portals) do
                if IsValid(portal) then portal:Remove() end
            end
            print("✓ Performance test complete - entities cleaned up")
        end
    end)

    print("=== Performance Test Started (10 seconds) ===")
end

-- Performance test command
concommand.Add("portal_test_performance", TestPortalGhostPerformance, nil, "Test portal ghost performance")

-- Run integration test on server start
hook.Add("Initialize", "PortalGhostIntegrationTest", function()
    timer.Simple(2, TestPortalGhostIntegration)
end)

print("Portal system integration test loaded")
print("Commands available:")
print("  portal_test_integration - Test system integration")
print("  portal_test_functionality - Test ghost functionality")
print("  portal_test_performance - Test performance with multiple entities")
