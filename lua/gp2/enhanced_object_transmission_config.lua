-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Enhanced Object Transmission Configuration
-- Portal source code-inspired object transmission settings
-- ----------------------------------------------------------------------------

-- Safe print function that works even if GP2 isn't loaded yet
local function SafePrint(...)
    if _G.GP2 and _G.GP2.Print then
        _G.GP2.Print(...)
    else
        print("[Enhanced Object Transmission]", ...)
    end
end

-- Ensure global EOT_Config table exists
_G.EOT_Config = _G.EOT_Config or {}
local EOT_Config = _G.EOT_Config

if not EOT_Config.Initialize then
    function EOT_Config.Initialize()
        print("[Enhanced Object Transmission] Configuration system initialized")
        
        -- Initialize any configuration-specific setup here
        if SERVER then
            -- Validate all ConVars are created
            local requiredCvars = {
                "gp2_object_transmission_enabled",
                "gp2_object_transmission_max_per_frame",
                "gp2_object_transmission_velocity_threshold"
            }
            
            for _, cvarName in ipairs(requiredCvars) do
                local cvar = GetConVar(cvarName)
                if not cvar then
                    print("[Enhanced Object Transmission] Warning: ConVar " .. cvarName .. " not found")
                end
            end
        end
    end
end

-- Create configuration convars for the enhanced object transmission system
if SERVER then
    -- Core transmission settings
    CreateConVar("gp2_object_transmission_enabled", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, 
                 "Enable enhanced object transmission through portals")
                 
    CreateConVar("gp2_object_transmission_max_per_frame", "8", FCVAR_ARCHIVE, 
                 "Maximum objects to process for transmission per frame")
                 
    CreateConVar("gp2_object_transmission_velocity_threshold", "25", FCVAR_ARCHIVE,
                 "Minimum velocity required for object transmission consideration")
                 
    CreateConVar("gp2_object_transmission_size_multiplier", "2.0", FCVAR_ARCHIVE,
                 "Size multiplier for portal transmission (higher = larger objects can pass)")
                 
    CreateConVar("gp2_object_transmission_distance_threshold", "128", FCVAR_ARCHIVE,
                 "Maximum distance from portal plane for transmission consideration")
                 
    CreateConVar("gp2_object_transmission_update_interval", "0.02", FCVAR_ARCHIVE,
                 "Update interval for object transmission processing (seconds)")
    
    -- Advanced physics settings
    CreateConVar("gp2_object_transmission_preserve_constraints", "1", FCVAR_ARCHIVE,
                 "Preserve constraint relationships during object transmission")
                 
    CreateConVar("gp2_object_transmission_velocity_boost", "1.0", FCVAR_ARCHIVE,
                 "Velocity multiplier applied to transmitted objects")
                 
    CreateConVar("gp2_object_transmission_gravity_compensation", "1", FCVAR_ARCHIVE,
                 "Apply gravity compensation to transmitted objects")
    
    -- Entity type filters
    CreateConVar("gp2_object_transmission_allow_physics", "1", FCVAR_ARCHIVE,
                 "Allow prop_physics entities to be transmitted")
                 
    CreateConVar("gp2_object_transmission_allow_cubes", "1", FCVAR_ARCHIVE,
                 "Allow prop_weighted_cube entities to be transmitted")
                 
    CreateConVar("gp2_object_transmission_allow_ragdolls", "1", FCVAR_ARCHIVE,
                 "Allow prop_ragdoll entities to be transmitted")
                 
    CreateConVar("gp2_object_transmission_allow_turrets", "1", FCVAR_ARCHIVE,
                 "Allow npc_portal_turret_floor entities to be transmitted")
                 
    CreateConVar("gp2_object_transmission_allow_energy_balls", "1", FCVAR_ARCHIVE,
                 "Allow prop_energy_ball entities to be transmitted")
    
    -- Debug and performance settings
    CreateConVar("gp2_object_transmission_debug", "0", FCVAR_CHEAT,
                 "Enable debug output for object transmission")
                 
    CreateConVar("gp2_object_transmission_debug_visual", "0", FCVAR_CHEAT,
                 "Enable visual debugging for object transmission")
                 
    CreateConVar("gp2_object_transmission_performance_monitoring", "0", FCVAR_ARCHIVE,
                 "Enable performance monitoring for transmission system")
    
    -- Portal-specific settings inspired by Portal source code
    CreateConVar("gp2_portal_trace_vs_world", "1", FCVAR_ARCHIVE,
                 "Use traces against portal environment world geometry")
                 
    CreateConVar("gp2_portal_trace_vs_objects", "1", FCVAR_ARCHIVE,
                 "Use traces against portal environment objects")
                 
    CreateConVar("gp2_use_transformed_collideables", "1", FCVAR_ARCHIVE,
                 "Use transformed collideable system for portal object detection")
end

-- Client-side visual and audio settings
if CLIENT then
    CreateClientConVar("gp2_object_transmission_show_effects", "1", true, false,
                       "Show visual effects during object transmission")
                       
    CreateClientConVar("gp2_object_transmission_show_debug_overlay", "0", true, false,
                       "Show debug overlay for object transmission areas")
                       
    CreateClientConVar("gp2_object_transmission_sound_enabled", "1", true, false,
                       "Play sound effects during object transmission")
                       
    CreateClientConVar("gp2_object_transmission_prediction", "1", true, false,
                       "Enable client-side transmission prediction")
end

-- Configuration utility functions - safe initialization
if _G.GP2 then
    _G.GP2.ObjectTransmission = _G.GP2.ObjectTransmission or {}
    -- Global EOT_Config table for validation
    _G.EOT_Config = _G.GP2.ObjectTransmission
else
    -- Fallback if GP2 isn't loaded yet
    _G.EOT_Config = _G.EOT_Config or {}
end

-- Définir les fonctions de configuration de manière sécurisée
local EOT_Config = _G.EOT_Config

function EOT_Config.GetConfig(setting)
    local cvar = GetConVar("gp2_object_transmission_" .. setting)
    if cvar then
        return cvar:GetBool(), cvar:GetFloat(), cvar:GetString()
    end
    return false, 0, ""
end

function EOT_Config.IsEnabled()
    if SERVER then
        return GetConVar("gp2_object_transmission_enabled"):GetBool()
    end
    return true -- Client always enabled if server supports it
end

function EOT_Config.GetEntityTypeAllowed(entityType)
    local cvarName = "gp2_object_transmission_allow_" .. entityType
    local cvar = GetConVar(cvarName)
    return cvar and cvar:GetBool() or false
end

function GP2.ObjectTransmission.GetTransmissionSettings()
    return {
        MaxObjectsPerFrame = GetConVar("gp2_object_transmission_max_per_frame"):GetInt(),
        VelocityThreshold = GetConVar("gp2_object_transmission_velocity_threshold"):GetFloat(),
        SizeMultiplier = GetConVar("gp2_object_transmission_size_multiplier"):GetFloat(),
        DistanceThreshold = GetConVar("gp2_object_transmission_distance_threshold"):GetFloat(),
        UpdateInterval = GetConVar("gp2_object_transmission_update_interval"):GetFloat(),
        PreserveConstraints = GetConVar("gp2_object_transmission_preserve_constraints"):GetBool(),
        VelocityBoost = GetConVar("gp2_object_transmission_velocity_boost"):GetFloat(),
        GravityCompensation = GetConVar("gp2_object_transmission_gravity_compensation"):GetBool()
    }
end

-- Configuration validation
local function validateConfiguration()
    local settings = GP2.ObjectTransmission.GetTransmissionSettings()
    
    -- Validate numeric ranges
    if settings.MaxObjectsPerFrame < 1 or settings.MaxObjectsPerFrame > 50 then
        SafePrint("gp2_object_transmission_max_per_frame should be between 1 and 50")
    end
    
    if settings.VelocityThreshold < 0 or settings.VelocityThreshold > 1000 then
        SafePrint("gp2_object_transmission_velocity_threshold should be between 0 and 1000")
    end
    
    if settings.SizeMultiplier < 0.1 or settings.SizeMultiplier > 10.0 then
        SafePrint("gp2_object_transmission_size_multiplier should be between 0.1 and 10.0")
    end
    
    if settings.UpdateInterval < 0.001 or settings.UpdateInterval > 1.0 then
        SafePrint("gp2_object_transmission_update_interval should be between 0.001 and 1.0")
    end
end

-- Apply configuration changes
hook.Add("PostGamemodeLoaded", "GP2_ValidateTransmissionConfig", validateConfiguration)

-- Console command to show current configuration
concommand.Add("gp2_object_transmission_config", function(ply, cmd, args)
    local function printConfig(text)
        if IsValid(ply) then
            ply:ChatPrint(text)
        else
            print(text)
        end
    end
    
    printConfig("=== GP2 Object Transmission Configuration ===")
    
    if SERVER then
        local settings = GP2.ObjectTransmission.GetTransmissionSettings()
        
        printConfig("Core Settings:")
        printConfig(string.format("  Enabled: %s", GP2.ObjectTransmission.IsEnabled() and "Yes" or "No"))
        printConfig(string.format("  Max Objects Per Frame: %d", settings.MaxObjectsPerFrame))
        printConfig(string.format("  Velocity Threshold: %.1f", settings.VelocityThreshold))
        printConfig(string.format("  Size Multiplier: %.2f", settings.SizeMultiplier))
        printConfig(string.format("  Distance Threshold: %.1f", settings.DistanceThreshold))
        printConfig(string.format("  Update Interval: %.3f", settings.UpdateInterval))
        
        printConfig("Physics Settings:")
        printConfig(string.format("  Preserve Constraints: %s", settings.PreserveConstraints and "Yes" or "No"))
        printConfig(string.format("  Velocity Boost: %.2f", settings.VelocityBoost))
        printConfig(string.format("  Gravity Compensation: %s", settings.GravityCompensation and "Yes" or "No"))
        
        printConfig("Entity Types:")
        printConfig(string.format("  Physics Props: %s", GP2.ObjectTransmission.GetEntityTypeAllowed("physics") and "Yes" or "No"))
        printConfig(string.format("  Cubes: %s", GP2.ObjectTransmission.GetEntityTypeAllowed("cubes") and "Yes" or "No"))
        printConfig(string.format("  Ragdolls: %s", GP2.ObjectTransmission.GetEntityTypeAllowed("ragdolls") and "Yes" or "No"))
        printConfig(string.format("  Turrets: %s", GP2.ObjectTransmission.GetEntityTypeAllowed("turrets") and "Yes" or "No"))
        printConfig(string.format("  Energy Balls: %s", GP2.ObjectTransmission.GetEntityTypeAllowed("energy_balls") and "Yes" or "No"))
    else
        printConfig("Client Settings:")
        printConfig(string.format("  Show Effects: %s", GetConVar("gp2_object_transmission_show_effects"):GetBool() and "Yes" or "No"))
        printConfig(string.format("  Debug Overlay: %s", GetConVar("gp2_object_transmission_show_debug_overlay"):GetBool() and "Yes" or "No"))
        printConfig(string.format("  Sound Enabled: %s", GetConVar("gp2_object_transmission_sound_enabled"):GetBool() and "Yes" or "No"))
        printConfig(string.format("  Prediction: %s", GetConVar("gp2_object_transmission_prediction"):GetBool() and "Yes" or "No"))
    end
end)

-- Auto-update portal settings when convars change
if SERVER then    cvars.AddChangeCallback("gp2_object_transmission_enabled", function(cvar, oldVal, newVal)
        SafePrint("Object transmission system " .. (tobool(newVal) and "enabled" or "disabled"))
    end)
    
    cvars.AddChangeCallback("gp2_object_transmission_max_per_frame", function(cvar, oldVal, newVal)
        local newValue = tonumber(newVal)
        if newValue and (newValue < 1 or newValue > 50) then
            SafePrint("WARNING: Max objects per frame value out of recommended range (1-50)")
        end
    end)
end

SafePrint("Enhanced Object Transmission Configuration loaded")
