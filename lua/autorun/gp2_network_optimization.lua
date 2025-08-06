-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Optimisation des NetworkVar pour réduire le trafic réseau
-- ----------------------------------------------------------------------------

if SERVER then
    local Entity = FindMetaTable("Entity")
    if not Entity or type(Entity) ~= "table" then
        Entity = debug.getregistry().Entity or {}
    end

    -- Cache pour les NetworkVar pour éviter les mises à jour inutiles
    local networkVarCache = {}

    local function CacheNetworkVar(ent, varName, value)
        local entIndex = ent:EntIndex()
        local cacheKey = entIndex .. "_" .. varName

        if networkVarCache[cacheKey] ~= value then
            networkVarCache[cacheKey] = value
            return true -- Valeur changée, autoriser la mise à jour
        end
        return false -- Valeur identique, bloquer la mise à jour
    end

    -- Hook pour optimiser les SetPos répétitifs
    local originalSetPos = Entity.SetPos
    function Entity:SetPos(pos)
        if self.GP2_LastPos and self.GP2_LastPos:DistToSqr(pos) < 1 then
            return -- Position trop similaire, ignorer
        end
        self.GP2_LastPos = pos
        return originalSetPos(self, pos)
    end

    -- Hook pour optimiser les SetAngles répétitifs
    local originalSetAngles = Entity.SetAngles
    function Entity:SetAngles(ang)
        if self.GP2_LastAng and
           math.abs(self.GP2_LastAng.p - ang.p) < 1 and
           math.abs(self.GP2_LastAng.y - ang.y) < 1 and
           math.abs(self.GP2_LastAng.r - ang.r) < 1 then
            return -- Angle trop similaire, ignorer
        end
        self.GP2_LastAng = ang
        return originalSetAngles(self, ang)
    end
end
