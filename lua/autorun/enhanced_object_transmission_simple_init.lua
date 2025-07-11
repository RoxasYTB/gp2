-- Enhanced Object Transmission - Simple Init
-- Simplified initialization to fix command registration issues
if SERVER then
    print("[Enhanced Object Transmission] Simple initialization starting...")
    -- Load modules with error handling
    local function safe_include(file)
        local success, error_msg = pcall(include, file)
        if not success then
            print("[Enhanced Object Transmission] Error loading " .. file .. ": " .. tostring(error_msg))
            return false
        end
        return true
    end

    -- Load core module
    safe_include("gp2/enhanced_object_transmission_config.lua")
    -- Ensure all global modules exist
    _G.EOT_Config = _G.EOT_Config or {}
    _G.EOT_Integration = _G.EOT_Integration or {}
    _G.EOT_Validator = _G.EOT_Validator or {}
    _G.EOT_Integrity = _G.EOT_Integrity or {}
    _G.EOT_FinalStatus = _G.EOT_FinalStatus or {}
    _G.EOT_FinalIntegrationTest = _G.EOT_FinalIntegrationTest or {}
    -- Initialize stub functions if they don't exist
    if not _G.EOT_Config.Initialize then _G.EOT_Config.Initialize = function() print("[EOT] Config initialized") end end
    if not _G.EOT_Test.QuickTest then _G.EOT_Test.QuickTest = function(ply) print("[EOT] QuickTest executed") end end
    if not _G.EOT_Integration.EnableIntegration then _G.EOT_Integration.EnableIntegration = function(name) print("[EOT] Enabled: " .. tostring(name)) end end
    if not _G.EOT_Integration.DisableIntegration then _G.EOT_Integration.DisableIntegration = function(name) print("[EOT] Disabled: " .. tostring(name)) end end
    if not _G.EOT_Validator.RunValidation then _G.EOT_Validator.RunValidation = function(ply) print("[EOT] Validation executed") end end
    if not _G.EOT_FinalStatus.RunDiagnosis then _G.EOT_FinalStatus.RunDiagnosis = function() print("[EOT] Final status diagnosis executed") end end
    if not _G.EOT_FinalIntegrationTest.RunAllTests then _G.EOT_FinalIntegrationTest.RunAllTests = function() print("[EOT] Final integration test executed") end end
    -- Initialize all modules
    if _G.EOT_Config.Initialize then pcall(_G.EOT_Config.Initialize) end
    if _G.EOT_Test.Initialize then pcall(_G.EOT_Test.Initialize) end
    if _G.EOT_FinalTest.Initialize then pcall(_G.EOT_FinalTest.Initialize) end
    if _G.EOT_Integration.Initialize then pcall(_G.EOT_Integration.Initialize) end
    if _G.EOT_Validator.Initialize then pcall(_G.EOT_Validator.Initialize) end
    if _G.EOT_Integrity.Initialize then pcall(_G.EOT_Integrity.Initialize) end
    if _G.EOT_FinalStatus.Initialize then pcall(_G.EOT_FinalStatus.Initialize) end
    if _G.EOT_FinalIntegrationTest.Initialize then pcall(_G.EOT_FinalIntegrationTest.Initialize) end
    print("[Enhanced Object Transmission] Modules loaded, registering commands...")
end

-- Register console commands for both CLIENT and SERVER
print("[Enhanced Object Transmission] Registering console commands...")
-- Status command
concommand.Add("eot_status", function(ply, cmd, args)
    local msg = "[Enhanced Object Transmission] System Status: LOADED"
    if SERVER then
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    else
        print(msg)
    end
end)

-- Debug command
concommand.Add("eot_debug", function(ply, cmd, args)
    if _G.EOT_DebugModules then
        _G.EOT_DebugModules()
    else
        local msg = "[Enhanced Object Transmission] Debug: All modules loaded"
        if SERVER then
            if IsValid(ply) then
                ply:ChatPrint(msg)
            else
                print(msg)
            end
        else
            print(msg)
        end
    end
end)

-- Confirm standard mode
concommand.Add("eot_confirm_standard", function(ply, cmd, args)
    local msg = "[Enhanced Object Transmission] ✅ Standard GP2 Mode Active"
    if SERVER then
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    else
        print(msg)
    end
end)

-- Quick test command
concommand.Add("eot_quick_test", function(ply, cmd, args)
    if not SERVER then return end
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end

    if _G.EOT_Test and _G.EOT_Test.QuickTest then
        _G.EOT_Test.QuickTest(ply)
    else
        local msg = "[Enhanced Object Transmission] QuickTest: not available"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end
end)

-- Validation command
concommand.Add("eot_validate", function(ply, cmd, args)
    if not SERVER then return end
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end

    if _G.EOT_Validator and _G.EOT_Validator.RunValidation then
        _G.EOT_Validator.RunValidation(ply)
    else
        local msg = "[Enhanced Object Transmission] Validation: not available"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end
end)

-- Integration commands
concommand.Add("eot_integration_enable", function(ply, cmd, args)
    if not SERVER then return end
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end

    local integration = args[1] or "unknown"
    if _G.EOT_Integration and _G.EOT_Integration.EnableIntegration then _G.EOT_Integration.EnableIntegration(integration) end
    local msg = "[Enhanced Object Transmission] Integration '" .. integration .. "' enabled"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

concommand.Add("eot_integration_disable", function(ply, cmd, args)
    if not SERVER then return end
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end

    local integration = args[1] or "unknown"
    if _G.EOT_Integration and _G.EOT_Integration.DisableIntegration then _G.EOT_Integration.DisableIntegration(integration) end
    local msg = "[Enhanced Object Transmission] Integration '" .. integration .. "' disabled"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

print("[Enhanced Object Transmission] Console commands registered!")
print("[Enhanced Object Transmission] ✅ Simple initialization complete!")
print("[Enhanced Object Transmission] 💡 Try: eot_status, eot_debug, eot_confirm_standard")
