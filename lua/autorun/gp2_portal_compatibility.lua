-- GP2 Portal Compatibility Module
-- Ensures compatibility between different portal systems and versions

-- Make sure the global environment is properly initialized
if not GP2 then
    GP2 = {}
end

-- Portal compatibility functions
local function InitializePortalCompatibility()
    -- Ensure portal colors are properly configured
    if SERVER then
        -- Register portal color convars if not already present
        if not ConVarExists("gp2_portal_color1") then
            CreateConVar("gp2_portal_color1", "255 175 0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Portal 1 color (orange)")
        end
        if not ConVarExists("gp2_portal_color2") then
            CreateConVar("gp2_portal_color2", "0 175 255", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Portal 2 color (blue)")
        end
    end

    -- Initialize portal sound compatibility
    if CLIENT then
        -- Precache portal sounds
        util.PrecacheSound("weapons/portalgun/portal_ambient_loop1.wav")
        util.PrecacheSound("weapons/portalgun/portal2/portal_ambient_loop1.wav")
    end
end

-- Hook to initialize compatibility when needed
hook.Add("InitPostEntity", "GP2::PortalCompatibility", InitializePortalCompatibility)

print("[GP2] Portal compatibility module loaded")
