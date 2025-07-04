-- Base entity for brush-based entities (GP2-SDK)
-- This provides a fallback for entities that derive from base_brush

AddCSLuaFile()

-- Ensure ENT table exists
ENT = ENT or {}

ENT.Type = "brush"
ENT.Base = "brush"  -- Use standard GMod brush base
ENT.Spawnable = false
ENT.AdminOnly = false

-- If base_brush doesn't exist in GMod, create a minimal implementation
if not scripted_ents.Get("base_brush") then
    -- Create a minimal base_brush entity
    local BASE_BRUSH = {}
    BASE_BRUSH.Type = "brush"
    BASE_BRUSH.Base = "base_entity"
    BASE_BRUSH.Spawnable = false
    
    function BASE_BRUSH:Initialize()
        if SERVER then
            self:SetSolid(SOLID_BSP)
            self:SetMoveType(MOVETYPE_PUSH)
            self:DrawShadow(false)
        end
    end
    
    function BASE_BRUSH:KeyValue(key, value)
        -- Handle brush entity key values
        if key == "model" then
            self:SetModel(value)
        elseif key == "origin" then
            local pos = string.Explode(" ", value)
            if #pos >= 3 then
                self:SetPos(Vector(tonumber(pos[1]) or 0, tonumber(pos[2]) or 0, tonumber(pos[3]) or 0))
            end
        elseif key == "angles" then
            local ang = string.Explode(" ", value)
            if #ang >= 3 then
                self:SetAngles(Angle(tonumber(ang[1]) or 0, tonumber(ang[2]) or 0, tonumber(ang[3]) or 0))
            end
        end
    end
    
    function BASE_BRUSH:AcceptInput(inputName, activator, caller, data)
        -- Handle input/output system
        return false
    end
    
    function BASE_BRUSH:Touch(entity)
        -- Handle touch events
    end
    
    function BASE_BRUSH:StartTouch(entity)
        -- Handle start touch events
    end
    
    function BASE_BRUSH:EndTouch(entity)
        -- Handle end touch events
    end
    
    -- Register the base_brush entity
    scripted_ents.Register(BASE_BRUSH, "base_brush")
    print("[GP2-SDK] Registered fallback base_brush entity")
end
