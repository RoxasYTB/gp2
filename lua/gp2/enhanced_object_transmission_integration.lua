-- Enhanced Object Transmission - GP2 Integration Utilities
-- Provides integration hooks for other GP2 systems

local EOT_Integration = _G.EOT_Integration or {}
_G.EOT_Integration = EOT_Integration

-- Integration with Portal 2 Gels
function EOT_Integration.SetupGelIntegration()
    if not SERVER then return end
    
    -- Hook into gel application to track gel-affected objects
    hook.Add("PlayerSprayPaint", "EOT_GelTracking", function(ply, tr)
        if not IsValid(tr.Entity) then return end
        
        local ent = tr.Entity
        if not ent.EOT_GelProperties then
            ent.EOT_GelProperties = {}
        end
        
        -- Track gel type and application time
        local gel_type = "unknown"
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if weapon:GetClass() == "weapon_paintgun" then
                gel_type = weapon:GetPaintType() or "unknown"
            end
        end
        
        ent.EOT_GelProperties[gel_type] = CurTime()
        
        -- Adjust transmission parameters based on gel
        if gel_type == "speed" then
            ent.EOT_VelocityMultiplier = 2.0
        elseif gel_type == "bounce" then
            ent.EOT_BounceEnabled = true
        elseif gel_type == "stick" then
            ent.EOT_StickEnabled = true
        end
    end)
end

-- Integration with Turrets
function EOT_Integration.SetupTurretIntegration()
    if not SERVER then return end
    
    -- Special handling for turrets during transmission
    hook.Add("EOT_PreTransmission", "EOT_TurretHandler", function(ent, portal)
        if not IsValid(ent) or ent:GetClass() ~= "npc_turret_floor" then return end
        
        -- Store turret state
        ent.EOT_TurretState = {
            enabled = ent:GetKeyValue("spawnflags") ~= "32", -- Not disabled
            target = ent:GetEnemy(),
            last_think = CurTime()
        }
        
        -- Temporarily disable turret AI during transmission
        ent:SetKeyValue("spawnflags", "32") -- Disable
    end)
    
    hook.Add("EOT_PostTransmission", "EOT_TurretHandler", function(ent, portal)
        if not IsValid(ent) or ent:GetClass() ~= "npc_turret_floor" then return end
        
        -- Restore turret state
        if ent.EOT_TurretState then
            if ent.EOT_TurretState.enabled then
                ent:SetKeyValue("spawnflags", "0") -- Enable
            end
            
            -- Clear target to prevent confusion
            ent:SetEnemy(NULL)
            ent.EOT_TurretState = nil
        end
    end)
end

-- Integration with Energy Balls
function EOT_Integration.SetupEnergyBallIntegration()
    if not SERVER then return end
    
    -- Special physics handling for energy balls
    hook.Add("EOT_PreTransmission", "EOT_EnergyBallHandler", function(ent, portal)
        if not IsValid(ent) or ent:GetClass() ~= "prop_energy_ball" then return end
          -- Store energy ball properties
        ent.EOT_EnergyBallState = {
            speed = ent:GetVelocity():Length(),
            bounces = (ent.GetBounceCount and ent:GetBounceCount()) or 0,
            lifetime = (ent.GetLifeTime and ent:GetLifeTime()) or 10
        }
    end)
    
    hook.Add("EOT_PostTransmission", "EOT_EnergyBallHandler", function(ent, portal)
        if not IsValid(ent) or ent:GetClass() ~= "prop_energy_ball" then return end
        
        -- Restore energy ball state and adjust for portal transformation
        if ent.EOT_EnergyBallState then
            -- Maintain speed through portal
            local vel = ent:GetVelocity()
            if vel:Length() < ent.EOT_EnergyBallState.speed then
                vel:Normalize()
                vel = vel * ent.EOT_EnergyBallState.speed
                ent:SetVelocity(vel)
            end
            
            ent.EOT_EnergyBallState = nil
        end
    end)
end

-- Integration with Cube Dropper
function EOT_Integration.SetupCubeDropperIntegration()
    if not SERVER then return end
    
    -- Track cubes created by droppers
    hook.Add("OnEntityCreated", "EOT_CubeDropperTracking", function(ent)
        if not IsValid(ent) then return end
        
        timer.Simple(0.1, function()
            if not IsValid(ent) then return end
            
            -- Check if it's a cube from a dropper
            local class = ent:GetClass()
            if class == "prop_weighted_cube" or class == "prop_monster_box" then
                local dropper = ent:GetCreator()
                if IsValid(dropper) and dropper:GetClass() == "prop_cube_dropper" then
                    -- Mark cube as dropper-created
                    ent.EOT_FromDropper = true
                    ent.EOT_DropperEntity = dropper
                    
                    -- Special transmission handling
                    ent.EOT_TransmissionPriority = 1.5 -- Higher priority
                end
            end
        end)
    end)
end

-- Integration with Button System
function EOT_Integration.SetupButtonIntegration()
    if not SERVER then return end
    
    -- Handle button state during object transmission
    hook.Add("EOT_PreTransmission", "EOT_ButtonHandler", function(ent, portal)
        if not IsValid(ent) then return end
        
        -- Find buttons this entity might be pressing
        local buttons = {}
        for _, button in ipairs(ents.FindByClass("func_button")) do
            if IsValid(button) and button:GetTouching(ent) then
                table.insert(buttons, button)
                -- Release button
                button:Fire("Unlock")
            end
        end
        
        -- Store for post-transmission
        ent.EOT_PressedButtons = buttons
    end)
    
    hook.Add("EOT_PostTransmission", "EOT_ButtonHandler", function(ent, portal)
        if not IsValid(ent) or not ent.EOT_PressedButtons then return end
        
        -- Check if entity is now pressing any buttons
        timer.Simple(0.1, function()
            if not IsValid(ent) then return end
            
            -- Clear stored buttons
            ent.EOT_PressedButtons = nil
        end)
    end)
end

-- Integration with Fizzler
function EOT_Integration.SetupFizzlerIntegration()
    if not SERVER then return end
    
    -- Prevent transmission through fizzlers
    hook.Add("EOT_ShouldTransmit", "EOT_FizzlerBlocker", function(ent, portal)
        if not IsValid(ent) or not IsValid(portal) then return end
        
        -- Check for fizzlers between entity and portal
        local tr = util.TraceLine({
            start = ent:GetPos(),
            endpos = portal:GetPos(),
            filter = {ent, portal}
        })
        
        if tr.Hit and IsValid(tr.Entity) then
            local hit_class = tr.Entity:GetClass()
            if hit_class == "trigger_portal_cleanser" or 
               hit_class == "func_portal_cleanser" then
                -- Block transmission
                return false
            end
        end
    end)
end

if not EOT_Integration.Initialize then
    function EOT_Integration.Initialize()
        if not SERVER then return end
        print("[Enhanced Object Transmission] Initializing GP2 integrations...")
        EOT_Integration.SetupGelIntegration()
        EOT_Integration.SetupTurretIntegration()
        EOT_Integration.SetupEnergyBallIntegration()
        EOT_Integration.SetupCubeDropperIntegration()
        EOT_Integration.SetupButtonIntegration()
        EOT_Integration.SetupFizzlerIntegration()
        print("[Enhanced Object Transmission] GP2 integrations initialized")
    end
end

-- Hook management for enabling/disabling integrations
function EOT_Integration.EnableIntegration(name)
    -- Re-add specific hooks if needed
    if name == "gels" then
        EOT_Integration.SetupGelIntegration()
    elseif name == "turrets" then
        EOT_Integration.SetupTurretIntegration()
    elseif name == "energy_balls" then
        EOT_Integration.SetupEnergyBallIntegration()
    elseif name == "cube_dropper" then
        EOT_Integration.SetupCubeDropperIntegration()
    elseif name == "buttons" then
        EOT_Integration.SetupButtonIntegration()
    elseif name == "fizzler" then
        EOT_Integration.SetupFizzlerIntegration()
    end
end

function EOT_Integration.DisableIntegration(name)
    -- Remove specific hooks
    if name == "gels" then
        hook.Remove("PlayerSprayPaint", "EOT_GelTracking")
    elseif name == "turrets" then
        hook.Remove("EOT_PreTransmission", "EOT_TurretHandler")
        hook.Remove("EOT_PostTransmission", "EOT_TurretHandler")
    elseif name == "energy_balls" then
        hook.Remove("EOT_PreTransmission", "EOT_EnergyBallHandler")
        hook.Remove("EOT_PostTransmission", "EOT_EnergyBallHandler")
    elseif name == "cube_dropper" then
        hook.Remove("OnEntityCreated", "EOT_CubeDropperTracking")
    elseif name == "buttons" then
        hook.Remove("EOT_PreTransmission", "EOT_ButtonHandler")
        hook.Remove("EOT_PostTransmission", "EOT_ButtonHandler")
    elseif name == "fizzler" then
        hook.Remove("EOT_ShouldTransmit", "EOT_FizzlerBlocker")
    end
end

-- Console commands for integration management
concommand.Add("eot_integration_enable", function(ply, cmd, args)
    if not SERVER then return end
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end
    
    local integration = args[1]
    if not integration then
        local msg = "[Enhanced Object Transmission] Usage: eot_integration_enable <integration>\n" ..
                   "Available: gels, turrets, energy_balls, cube_dropper, buttons, fizzler"
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    EOT_Integration.EnableIntegration(integration)
    local msg = "[Enhanced Object Transmission] Integration '" .. integration .. "' enabled"
    if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
end)

concommand.Add("eot_integration_disable", function(ply, cmd, args)
    if not SERVER then return end
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Object Transmission] Access denied - requires superadmin")
        return
    end
    
    local integration = args[1]
    if not integration then
        local msg = "[Enhanced Object Transmission] Usage: eot_integration_disable <integration>\n" ..
                   "Available: gels, turrets, energy_balls, cube_dropper, buttons, fizzler"
        if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
        return
    end
    
    EOT_Integration.DisableIntegration(integration)
    local msg = "[Enhanced Object Transmission] Integration '" .. integration .. "' disabled"
    if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
end)

-- Auto-initialize
if SERVER then
    hook.Add("Initialize", "EOT_IntegrationInit", function()
        EOT_Integration.Initialize()
    end)
end

return EOT_Integration
