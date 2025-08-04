-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Patch to allow portal placement on tile/ surfaces
-- ----------------------------------------------------------------------------

AddCSLuaFile()

-- Hook to modify portal placement validation
local function InitTilesPortalFix()
    -- For the new portal gun system (if it exists)
    if PORTAL_PLACEMENT_BAD_SURFACE then
        -- Override the portal placement function to allow tile/ textures
        local original_setPortalPlacement = setPortalPlacementNew or setPortalPlacementOld

        if original_setPortalPlacement then
            local function patched_setPortalPlacement(owner, portal)
                local status, tr, pos, ang = original_setPortalPlacement(owner, portal)

                -- If placement failed due to bad surface, check if it's a TILE/ texture
                if status == PORTAL_PLACEMENT_BAD_SURFACE and tr and tr.HitTexture then
                    local texture = string.upper(tr.HitTexture)
                    if string.find(texture, "TILE/") == 1 then -- Starts with TILE/
                        -- Force allow placement on TILE/ surfaces
                        print("[GP2] Forcing portal placement on TILE/ texture: " .. tr.HitTexture)
                        return PORTAL_PLACEMENT_SUCCESFULL, tr, pos, ang
                    end
                end

                return status, tr, pos, ang
            end

            -- Replace the function
            if setPortalPlacementNew then
                setPortalPlacementNew = patched_setPortalPlacement
            end
            if setPortalPlacementOld then
                setPortalPlacementOld = patched_setPortalPlacement
            end
        end
    end

    print("[GP2] Tiles portal placement fix loaded")
end

-- Initialize when everything is loaded
if SERVER then
    hook.Add("InitPostEntity", "GP2_TilesPortalFix", function()
        timer.Simple(0.1, InitTilesPortalFix)
    end)
else
    hook.Add("InitPostEntity", "GP2_TilesPortalFix", function()
        timer.Simple(0.1, InitTilesPortalFix)
    end)
end

-- Alternative approach: Hook into the weapon system directly
hook.Add("InitPostEntity", "GP2_TilesPortalFix_Weapon", function()
    timer.Simple(0.5, function()
        local portalGunClass = weapons.Get("weapon_portalgun")
        if portalGunClass and portalGunClass.ValidSurface then
            local originalValidSurface = portalGunClass.ValidSurface

            portalGunClass.ValidSurface = function(self, tr)
                -- First check original validation
                local isValid = originalValidSurface(self, tr)

                -- If not valid, check if it's a TILE/ texture (force allow)
                if not isValid and tr and tr.HitTexture then
                    local texture = string.upper(tr.HitTexture)
                    if string.find(texture, "TILE/") == 1 then -- Starts with TILE/
                        print("[GP2] ValidSurface: Forcing TILE/ texture as valid: " .. tr.HitTexture)
                        return true
                    end
                end

                return isValid
            end

            print("[GP2] Portal gun ValidSurface function patched for tile/ support")
        end
    end)
end)

-- Patch for PortalManager if it has surface validation
hook.Add("InitPostEntity", "GP2_TilesPortalFix_Manager", function()
    timer.Simple(0.1, function()
        if PortalManager and PortalManager.IsValidSurface then
            local originalIsValidSurface = PortalManager.IsValidSurface

            PortalManager.IsValidSurface = function(tr)
                -- First check original validation
                local isValid = originalIsValidSurface(tr)

                -- If not valid, check if it's a TILE/ texture (force allow)
                if not isValid and tr and tr.HitTexture then
                    local texture = string.upper(tr.HitTexture)
                    if string.find(texture, "TILE/") == 1 then -- Starts with TILE/
                        print("[GP2] PortalManager: Forcing TILE/ texture as valid: " .. tr.HitTexture)
                        return true
                    end
                end

                return isValid
            end

            print("[GP2] PortalManager IsValidSurface function patched for tile/ support")
        end
    end)
end)

-- Debug function to display surface information
local function DebugSurfaceInfo(tr)
    if not tr then return end

    local info = {}
    table.insert(info, "=== SURFACE DEBUG INFO ===")
    table.insert(info, "HitTexture: " .. (tr.HitTexture or "nil"))
    table.insert(info, "MatType: " .. (tr.MatType or "nil"))
    table.insert(info, "SurfaceProps: " .. (tr.SurfaceProps or "nil"))

    if tr.Entity and IsValid(tr.Entity) then
        table.insert(info, "Entity: " .. tostring(tr.Entity))
        table.insert(info, "Entity Class: " .. tr.Entity:GetClass())
    else
        table.insert(info, "Entity: World")
    end

    if tr.HitPos then
        table.insert(info, "HitPos: " .. tostring(tr.HitPos))
    end

    if tr.HitNormal then
        table.insert(info, "HitNormal: " .. tostring(tr.HitNormal))
    end

    table.insert(info, "========================")

    -- print(table.concat(info, "\n"))
end

-- Hook into weapon fire to debug surfaces
hook.Add("EntityFireBullets", "GP2_SurfaceDebug", function(entity, data)
    if not IsValid(entity) or not entity:IsPlayer() then return end

    local weapon = entity:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() != "weapon_portalgun" then return end

    -- Perform a trace from the weapon
    local tr = util.TraceLine({
        start = data.Src or entity:GetShootPos(),
        endpos = (data.Src or entity:GetShootPos()) + (data.Dir or entity:GetAimVector()) * 32768,
        filter = entity
    })

    DebugSurfaceInfo(tr)
end)

-- Alternative hook for when player shoots
if CLIENT then
    local function OnPortalgunFire()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or weapon:GetClass() != "weapon_portalgun" then return end

        local tr = ply:GetEyeTrace()
        DebugSurfaceInfo(tr)
    end

    -- Hook into player input
    hook.Add("PlayerButtonDown", "GP2_SurfaceDebug_Client", function(ply, button)
        if button == MOUSE_LEFT or button == MOUSE_RIGHT then
            timer.Simple(0.01, OnPortalgunFire)
        end
    end)
end

-- Console command to manually debug surface at crosshair
concommand.Add("gp2_debug_surface", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    DebugSurfaceInfo(tr)
end)
