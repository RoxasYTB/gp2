-- Enhanced Object Transmission - Compatibility Bridge
-- Ensures GP2 original functionality while adding Portal enhancements

local EOT_Compat = {}

-- Store original GP2 functions
local originalGP2Functions = {}

-- Flag to enable/disable our enhancements without breaking original
local enhancementsEnabled = GetConVar("gp2_object_transmission_enabled") and GetConVar("gp2_object_transmission_enabled"):GetBool() or false

-- Hook into GP2's original transmission system
function EOT_Compat.InitializeCompatibility()
    if not SERVER then return end
    
    -- Ensure GP2 original transmission still works
    if GP2 and GP2.TransmitObject then
        originalGP2Functions.TransmitObject = GP2.TransmitObject
        
        -- Wrap original function with our enhancements
        GP2.TransmitObject = function(ent, portal, ...)
            -- Call our pre-transmission hooks if enhancements are enabled
            if enhancementsEnabled then
                local shouldTransmit = hook.Call("EOT_PreTransmission", nil, ent, portal)
                if shouldTransmit == false then return false end
            end
            
            -- Call original GP2 function
            local result = originalGP2Functions.TransmitObject(ent, portal, ...)
            
            -- Call our post-transmission hooks if enhancements are enabled
            if enhancementsEnabled and result then
                hook.Call("EOT_PostTransmission", nil, ent, portal)
            end
            
            return result
        end
    end
    
    -- Ensure portal creation works
    hook.Add("OnEntityCreated", "EOT_CompatPortalCreation", function(ent)
        if IsValid(ent) and ent:GetClass() == "prop_portal" then
            timer.Simple(0.1, function()
                if IsValid(ent) then
                    -- Mark as enhanced only if our system is enabled
                    ent.EnhancedObjectTransmission = enhancementsEnabled
                    
                    -- Ensure original GP2 portal functionality is preserved
                    if ent.Initialize and not ent.EOT_OriginalInitialized then
                        ent.EOT_OriginalInitialized = true
                        -- Let GP2 handle its own initialization
                    end
                end
            end)
        end
    end)
    
    print("[Enhanced Object Transmission] Compatibility bridge initialized")
end

-- Function to toggle enhancements without breaking GP2
function EOT_Compat.ToggleEnhancements(enabled)
    enhancementsEnabled = enabled
    
    -- Update all existing portals
    for _, ent in ipairs(ents.FindByClass("prop_portal")) do
        if IsValid(ent) then
            ent.EnhancedObjectTransmission = enabled
        end
    end
    
    print("[Enhanced Object Transmission] Enhancements " .. (enabled and "enabled" or "disabled"))
end

-- Restore original GP2 functionality if needed
function EOT_Compat.RestoreOriginal()
    if originalGP2Functions.TransmitObject and GP2 then
        GP2.TransmitObject = originalGP2Functions.TransmitObject
        print("[Enhanced Object Transmission] Original GP2 functionality restored")
    end
end

-- Console command to toggle compatibility mode
concommand.Add("eot_toggle_enhancements", function(ply, cmd, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end
    
    local enable = args[1] == "1" or args[1] == "true"
    EOT_Compat.ToggleEnhancements(enable)
    
    local msg = "[Enhanced Object Transmission] Enhancements " .. (enable and "enabled" or "disabled")
    if SERVER then
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
    else
        print(msg)
    end
end)

-- Console command to restore original GP2
concommand.Add("eot_restore_original", function(ply, cmd, args)
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end
    
    EOT_Compat.RestoreOriginal()
    
    local msg = "[Enhanced Object Transmission] Original GP2 functionality restored"
    if SERVER then
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
    else
        print(msg)
    end
end)

_G.EOT_Compat = EOT_Compat

return EOT_Compat
