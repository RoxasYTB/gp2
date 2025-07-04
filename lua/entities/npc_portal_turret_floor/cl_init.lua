-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Sentry turret with 3 legs and fancy laser
-- ----------------------------------------------------------------------------

include "shared.lua"

function ENT:Initialize()
    -- Protection contre les erreurs si NpcPortalTurretFloor n'est pas défini
    if NpcPortalTurretFloor and NpcPortalTurretFloor.AddToRenderList then
        NpcPortalTurretFloor.AddToRenderList(self)
    else
        -- Fallback silencieux si le système de rendu n'est pas disponible
        print("[GP2-SDK] NpcPortalTurretFloor render system not available, using fallback")
    end
end