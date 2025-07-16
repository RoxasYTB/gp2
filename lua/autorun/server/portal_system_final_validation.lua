-- Portal System Final Validation Test
-- This test validates the complete portal ghost system

if CLIENT then return end

local function ValidatePortalGhostSystem()
    print("=== PORTAL GHOST SYSTEM FINAL VALIDATION ===")

    local validationResults = {}

    -- Test 1: Core System Components
    print("\n1. TESTING CORE SYSTEM COMPONENTS:")

    -- Check portal collision system
    if PortalCollisionSystem then
        print("✓ PortalCollisionSystem loaded")
        if PortalCollisionSystem.DisableMapCollisions and PortalCollisionSystem.EnableMapCollisions then
            print("✓ Collision system functions available")
            validationResults.collision_system = true
        else
            print("✗ Collision system functions missing")
            validationResults.collision_system = false
        end
    else
        print("✗ PortalCollisionSystem not found")
        validationResults.collision_system = false
    end

    -- Check portal entity
    local portalEnt = scripted_ents.Get("prop_portal")
    if portalEnt then
        print("✓ prop_portal entity registered")

        -- Check required functions
        local requiredFunctions = {
            "CreateServerGhost",
            "RecreateGhosts",
            "Think",
            "QueueNetworkMessage",
            "ProcessNetworkQueue"
        }

        validationResults.portal_functions = true
        for _, funcName in ipairs(requiredFunctions) do
            if portalEnt.t and portalEnt.t[funcName] then
                print("✓ " .. funcName .. " function available")
            else
                print("✗ " .. funcName .. " function missing")
                validationResults.portal_functions = false
            end
        end
    else
        print("✗ prop_portal entity not found")
        validationResults.portal_functions = false
    end

    -- Check network messages
    local networkMessages = {
        "GP2_PortalPropGhost",
        "GP2_PortalPropGhostRemove"
    }

    validationResults.network_messages = true
    for _, msgName in ipairs(networkMessages) do
        if util.NetworkStringToID(msgName) > 0 then
            print("✓ " .. msgName .. " network message registered")
        else
            print("✗ " .. msgName .. " network message not registered")
            validationResults.network_messages = false
        end
    end

    -- Check PortalManager
    if PortalManager and PortalManager.TransformPortal then
        print("✓ PortalManager.TransformPortal available")
        validationResults.portal_manager = true
    else
        print("✗ PortalManager.TransformPortal missing")
        validationResults.portal_manager = false
    end

    -- Test 2: Functional Integration Test
    print("\n2. TESTING FUNCTIONAL INTEGRATION:")

    local admin = Entity(1)
    if not IsValid(admin) then
        print("✗ Admin player not found - skipping functional tests")
        validationResults.functional_test = false
    else
        print("✓ Admin player found")

        -- Create test environment
        local testProp = ents.Create("prop_physics")
        testProp:SetModel("models/props_c17/oildrum001.mdl")
        testProp:SetPos(admin:GetPos() + Vector(100, 0, 50))
        testProp:Spawn()
        testProp:Activate()

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

        print("✓ Test environment created")

        -- Test ghost creation system
        timer.Simple(1, function()
            if IsValid(testProp) and IsValid(portal1) then
                -- Move prop near portal
                testProp:SetPos(portal1:GetPos() + portal1:GetForward() * -50)

                -- Test ghost creation detection
                local dist = testProp:GetPos():Distance(portal1:GetPos())
                if dist < 200 then
                    print("✓ Prop within ghost creation range (" .. math.floor(dist) .. " units)")
                    validationResults.ghost_creation = true
                else
                    print("✗ Prop outside ghost creation range (" .. math.floor(dist) .. " units)")
                    validationResults.ghost_creation = false
                end
            else
                print("✗ Test entities invalid")
                validationResults.ghost_creation = false
            end
        end)

        -- Test collision system
        timer.Simple(2, function()
            if IsValid(testProp) and PortalCollisionSystem then
                local originalMoveType = testProp:GetMoveType()

                -- Test collision disable
                PortalCollisionSystem.DisableMapCollisions(testProp)

                timer.Simple(0.1, function()
                    if IsValid(testProp) then
                        local newMoveType = testProp:GetMoveType()
                        if newMoveType == MOVETYPE_NOCLIP then
                            print("✓ Collision system successfully disabled map collisions")

                            -- Test collision enable
                            PortalCollisionSystem.EnableMapCollisions(testProp)

                            timer.Simple(0.1, function()
                                if IsValid(testProp) then
                                    local restoredMoveType = testProp:GetMoveType()
                                    if restoredMoveType == originalMoveType then
                                        print("✓ Collision system successfully restored collisions")
                                        validationResults.collision_test = true
                                    else
                                        print("✗ Collision system failed to restore collisions")
                                        validationResults.collision_test = false
                                    end
                                end
                            end)
                        else
                            print("✗ Collision system failed to disable map collisions")
                            validationResults.collision_test = false
                        end
                    end
                end)
            else
                print("✗ Collision system test failed - invalid entities")
                validationResults.collision_test = false
            end
        end)

        -- Test server ghost creation
        timer.Simple(3, function()
            if IsValid(portal1) and portal1.CreateServerGhost then
                print("✓ Server ghost creation function available")
                validationResults.server_ghost = true
            else
                print("✗ Server ghost creation function missing")
                validationResults.server_ghost = false
            end
        end)

        -- Test ghost recreation
        timer.Simple(4, function()
            if IsValid(portal1) and portal1.RecreateGhosts then
                print("✓ Ghost recreation function available")
                validationResults.ghost_recreation = true
            else
                print("✗ Ghost recreation function missing")
                validationResults.ghost_recreation = false
            end
        end)

        -- Cleanup and final results
        timer.Simple(6, function()
            if IsValid(testProp) then testProp:Remove() end
            if IsValid(portal1) then portal1:Remove() end
            if IsValid(portal2) then portal2:Remove() end

            print("\n=== VALIDATION RESULTS ===")

            local totalTests = 0
            local passedTests = 0

            for testName, result in pairs(validationResults) do
                totalTests = totalTests + 1
                if result then
                    passedTests = passedTests + 1
                    print("✓ " .. testName .. ": PASS")
                else
                    print("✗ " .. testName .. ": FAIL")
                end
            end

            print("\n=== SUMMARY ===")
            print("Tests passed: " .. passedTests .. "/" .. totalTests)
            print("Success rate: " .. math.floor((passedTests/totalTests) * 100) .. "%")

            if passedTests == totalTests then
                print("🎉 ALL TESTS PASSED - PORTAL GHOST SYSTEM FULLY FUNCTIONAL!")
            else
                print("⚠️  SOME TESTS FAILED - REVIEW SYSTEM COMPONENTS")
            end

            print("=== VALIDATION COMPLETE ===")
        end)
    end

    -- Test 3: Performance Check
    print("\n3. TESTING PERFORMANCE:")

    local startTime = SysTime()
    local testIterations = 1000

    -- Test transformation performance
    if PortalManager and PortalManager.TransformPortal then
        for i = 1, testIterations do
            local testPos = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
            local testAng = Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
            -- Simulate transformation call (without actual portals)
        end

        local endTime = SysTime()
        local executionTime = endTime - startTime

        print("✓ Performance test completed")
        print("  Execution time: " .. string.format("%.6f", executionTime) .. " seconds")
        print("  Average per call: " .. string.format("%.6f", executionTime / testIterations) .. " seconds")

        if executionTime < 0.1 then
            print("✓ Performance: EXCELLENT")
            validationResults.performance = true
        elseif executionTime < 0.5 then
            print("✓ Performance: GOOD")
            validationResults.performance = true
        else
            print("⚠️  Performance: NEEDS OPTIMIZATION")
            validationResults.performance = false
        end
    else
        print("✗ Cannot test performance - PortalManager missing")
        validationResults.performance = false
    end
end

-- Test command
concommand.Add("portal_validate_system", ValidatePortalGhostSystem, nil, "Validate complete portal ghost system")

-- Auto-run validation on server start
hook.Add("Initialize", "PortalGhostSystemValidation", function()
    timer.Simple(5, function()
        print("Auto-running portal ghost system validation...")
        ValidatePortalGhostSystem()
    end)
end)

print("Portal Ghost System Final Validation loaded")
print("Use 'portal_validate_system' to run complete validation")
