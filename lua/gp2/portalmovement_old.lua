-- Portal Movement Old Module
-- Legacy portal movement system for compatibility

if not GP2 then GP2 = {} end

-- Legacy portal movement functions
GP2.PortalMovement = GP2.PortalMovement or {}

-- Stub functions for compatibility
function GP2.PortalMovement.InitializeOld()
    -- Legacy initialization code would go here
    print("[GP2] Legacy portal movement system initialized")
end

-- Initialize on server start
if SERVER then
    hook.Add("Initialize", "GP2::PortalMovementOld", GP2.PortalMovement.InitializeOld)
end

print("[GP2] Portal movement old module loaded")
