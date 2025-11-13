if SERVER then
	print("GP2 Network Optimization: Initializing network optimization for entities.");
	local Entity = FindMetaTable("Entity");
	if not Entity or type(Entity) ~= "table" then
		Entity = (debug.getregistry()).Entity or {};
	end;
	local networkVarCache = {};
	local function CacheNetworkVar(ent, varName, value)
		local entIndex = ent:EntIndex();
		local cacheKey = entIndex .. "_" .. varName;
		if networkVarCache[cacheKey] ~= value then
			networkVarCache[cacheKey] = value;
			return true;
		end;
		return false;
	end;
	local originalSetPos = Entity.SetPos;
	function Entity:SetPos(pos)
		return originalSetPos(self, pos);
	end;
	local originalSetAngles = Entity.SetAngles;
	function Entity:SetAngles(ang)
		return originalSetAngles(self, ang);
	end;
end;
