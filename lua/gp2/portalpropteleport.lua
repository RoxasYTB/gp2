-- Portal Prop Teleport Module
-- Handles teleportation of props through portals

if not GP2 then GP2 = {} end

-- Portal prop teleport system
GP2.PropTeleport = GP2.PropTeleport or {}

-- Initialize prop teleport system
function GP2.PropTeleport.Initialize()
    print("[GP2] Portal prop teleport system initialized")
end

-- Teleport a prop through a portal
function GP2.PropTeleport.TeleportProp(prop, fromPortal, toPortal)
    if not IsValid(prop) or not IsValid(fromPortal) or not IsValid(toPortal) then
        return false
    end

    -- Basic teleportation logic
    local newPos = (toPortal.GetPortalPosOffsets and type(toPortal.GetPortalPosOffsets) == "function") and toPortal:GetPortalPosOffsets(fromPortal, prop) or toPortal:GetPos()
    local newAngles = (toPortal.GetPortalAngleOffsets and type(toPortal.GetPortalAngleOffsets) == "function") and toPortal:GetPortalAngleOffsets(fromPortal, prop) or toPortal:GetAngles()

    prop:SetPos(newPos)
    prop:SetAngles(newAngles)

    return true
end

-- Initialize on server start
if SERVER then
    hook.Add("Initialize", "GP2::PropTeleport", GP2.PropTeleport.Initialize)
end

print("[GP2] Portal prop teleport module loaded")
