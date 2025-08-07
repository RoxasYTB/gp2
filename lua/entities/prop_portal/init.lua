AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
local outputs = outputs or {};
local hitprop = CreateConVar("portal_hitprop", "0", FCVAR_ARCHIVE, "Activer la détection des props par le portail");
local vel_roof_max = CreateConVar("portal_velocity_roof", 1000, {
	FCVAR_ARCHIVE,
	FCVAR_REPLICATED,
	FCVAR_SERVER_CAN_EXECUTE
});
local function IsBehind(posA, posB, normal)
	local Vec1 = (posB - posA):GetNormalized();
	return normal:Dot(Vec1) < 0;
end;
local function GetCardinalFromYaw(yaw)
	yaw = math.NormalizeAngle(yaw);
	if yaw >= (-45) and yaw < 45 then
		return "EAST";
	elseif yaw >= 45 and yaw < 135 then
		return "NORTH";
	elseif yaw >= (-135) and yaw < (-45) then
		return "SOUTH";
	else
		return "WEST";
	end;
end;
if SERVER then
	function ENT:KeyValue(k, v)
		if k == "Activated" then
			self:SetActivated(tobool(v));
		elseif k == "LinkageGroupID" then
			self:SetLinkageGroup(tonumber(v));
		elseif k == "HalfWidth" then
			local value = tonumber(v) > 0 and tonumber(v) or PORTAL_WIDTH / 2;
			local size = self:GetSize();
			if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
				self:SetSize(Vector(size.x, value, 8));
			else
				self:SetSize(Vector(size.x, value, 7));
			end;
		elseif k == "HalfHeight" then
			local value = tonumber(v) > 0 and tonumber(v) or PORTAL_HEIGHT / 2;
			local size = self:GetSize();
			if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
				self:SetSize(Vector(value, size.y, 8));
			else
				self:SetSize(Vector(value, size.y, 7));
			end;
		elseif k == "PortalTwo" then
			self:SetType(tonumber(v));
		elseif outputs[k] then
			self:StoreOutput(k, v);
		end;
	end;
	function ENT:AcceptInput(name, activator, caller, data)
		name = name:lower();
		if name == "setactivatedstate" then
			self:SetActivated(tobool(data));
			PortalManager.SetPortal(self:GetLinkageGroup(), self);
		elseif name == "setname" then
			self:SetName(data);
		elseif name == "fizzle" then
			self:Fizzle();
		elseif name == "setlinkagegroupid" then
			self:SetLinkageGroup(tonumber(data));
		end;
	end;
	hook.Remove("ShouldCollide", "GP2_DisablePortalPropPhysicsCollision");
	hook.Add("ShouldCollide", "GP2_DisablePortalPropPhysicsCollision", function(ent1, ent2)
		local c1, c2 = ent1:GetClass(), ent2:GetClass();
		if c1 == "prop_portal" and c2 == "prop_physics" or c2 == "prop_portal" and c1 == "prop_physics" then
			return false;
		end;
	end);
end;
local function incrementPortal(ent)
	if CLIENT then
		local size = ent:GetSize();
		ent:SetRenderBounds(-size, size);
	end;
	PortalManager.PortalIndex = PortalManager.PortalIndex + 1;
end;
function ENT:Initialize()
	if SERVER then
		self:SetModel("models/hunter/plates/plate2x2.mdl");
		self.OriginalAngles = self:GetAngles();
		local angles = self:GetAngles() + Angle(90, 0, 0);
		angles:RotateAroundAxis(angles:Up(), 180);
		self:SetColor(Color(0, 0, 0, 200));
		self:SetAngles(angles);
		self:PhysicsInit(SOLID_VPHYSICS);
		self:SetSolid(SOLID_VPHYSICS);
		self:SetTrigger(true);
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
		self:SetMoveType(MOVETYPE_NONE);
		self:DrawShadow(false);
		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self:SetPos(self:GetPos() + (self:GetAngles()):Up() * 7.1);
		end;
		PortalManager.PortalIndex = PortalManager.PortalIndex + 1;
		timer.Simple(0.3, function()
			if IsValid(self) then
				self.StablePos = self:GetPos();
				self.StableAngles = self:GetAngles();
				local up = self:GetUp();
				if up:Dot(Vector(0, 0, 1)) > 0.9 then
					self.PlacementType = "FLOOR";
				elseif up:Dot(Vector(0, 0, -1)) > 0.9 then
					self.PlacementType = "ROOF";
				else
					self.PlacementType = "WALL";
				end;
			end;
		end);
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdatePhysmesh();
				self:SetSolid(SOLID_VPHYSICS);
				self:SetTrigger(true);
				self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
				local phys = self:GetPhysicsObject();
				if IsValid(phys) then
					phys:EnableMotion(false);
					phys:EnableCollisions(false);
					phys:SetContents(_G.CONTENTS_TRIGGER or 0);
				end;
			end;
		end);
	end;
	if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		if SERVER and self:GetPlacedByMap() then
			self:BuildPortalEnvironment();
		end;
	end;
	PortalManager.SetPortal(self:GetLinkageGroup(), self);
	PortalManager.Portals[self] = true;
	self.PropTeleportEnabled = true;
	self.ClonedEntities = {};
	self.SpawnedCubes = {};
end;
if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
	function ENT:BuildPortalEnvironment()
		self.__portalenvironmentphymesh = ents.Create("__portalenvironmentphymesh");
		self.__portalenvironmentphymesh:SetPos(self:GetPos());
		self.__portalenvironmentphymesh:SetPortalAngles(self:GetAngles());
		self.__portalenvironmentphymesh:Spawn();
	end;
end;
function ENT:OnRemove()
	PortalManager.PortalIndex = math.max(PortalManager.PortalIndex - 1, 0);
	self:CleanupAllClones();
	self:BootAllPlayers();
	if self.SpawnedCubes then
		local cubesToRemove = {};
		for _, cube in ipairs(self.SpawnedCubes) do
			if IsValid(cube) then
				table.insert(cubesToRemove, cube);
			end;
		end;
		timer.Simple(1, function()
			for _, cube in ipairs(cubesToRemove) do
				if IsValid(cube) then
					cube:Remove();
				end;
			end;
		end);
	end;
	if SERVER and self.PORTAL_REMOVE_EXIT then
		SafeRemoveEntity(self:GetLinkedPartner());
	end;
	if CLIENT and IsValid(self.RingParticle) then
		self.RingParticle:StopEmissionAndDestroyImmediately();
	end;
	PortalManager.Portals[self] = nil;
end;
function ENT:CleanupAllClones()
	for _, ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent.clone and IsValid(ent.clone) and ent.clone.InPortal == self then
			ent.clone:Remove();
			ent.clone = nil;
			ent.InPortal = nil;
		end;
	end;
end;
function ENT:BootAllPlayers()
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply.InPortal == self then
			ply.InPortal = nil;
			ply:SetMoveType(MOVETYPE_WALK);
			ply:ResetHull();
			if ply.OriginalCollisionGroup then
				ply:SetCollisionGroup(ply.OriginalCollisionGroup);
				ply.OriginalCollisionGroup = nil;
			end;
			if ply.PortalClone and IsValid(ply.PortalClone) then
				ply.PortalClone:Remove();
				ply.PortalClone = nil;
			end;
		end;
	end;
end;
function ENT:UpdatePhysmesh()
	local size = self:GetSize();
	if not PORTAL_HEIGHT or (not PORTAL_WIDTH) then
		PORTAL_HEIGHT = PORTAL_HEIGHT or 112;
		PORTAL_WIDTH = PORTAL_WIDTH or 64;
		GP2.Print("Portal %d: Constants not loaded, using defaults", self:EntIndex());
	end;
	if not size or size == Vector(0, 0, 0) or size.x <= 0 or size.y <= 0 or size.z <= 0 then
		size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7);
		self:SetSizeInternal(size);
	end;
	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		local meshTable = GP2.MakeCubeMesh(size.x, size.y, size.z, false, true);
		self:PhysicsInitConvex(meshTable);
		self:EnableCustomCollisions(true);
		local phys = self:GetPhysicsObject();
		if IsValid(phys) then
			phys:EnableMotion(false);
		end;
		self:SetTrigger(true);
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
	else
		self:PhysicsInit(SOLID_NONE);
	end;
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
end;
function ENT:StartTouch(ent)
	if ent:GetModel() == "models/blackops/portal_sides.mdl" then
		return;
	end;
	if ent:GetModel() == "models/blackops/portal_sides_new.mdl" then
		return;
	end;
	if ent.GP2_PortalImmunity and ent.GP2_PortalImmunity > CurTime() then
		return;
	end;
	if ent.isClone and ent.daddyEnt and IsValid(ent.daddyEnt) and (not ent.daddyEnt.InPortal) then
		return;
	end;
	if hitprop:GetBool() then
		local path = ent:GetModel();
		if path then
			local ignore_patterns = {
				"/props_phx/construct/",
				"/phxtended/",
				"/hunter/",
				"/props_phx/construct/glass/",
				"/props_phx/construct/windows/",
				"/props_phx/construct/wood/",
				"/props_phx/construct/plastic/",
				"/hunter/blocks/",
				"/hunter/plates/",
				"/hunter/triangles/",
				"/hunter/tubes/",
				"/hunter/geometric/",
				"/hunter/misc/"
			};
			for _, pat in ipairs(ignore_patterns) do
				if string.find(path, pat, 1, true) then
					return;
				end;
			end;
		end;
	end;
	local projectileBalls = {
		"projectile_portal_ball",
		"projectile_portal_ball_atlas",
		"projectile_portal_ball_pbody",
		"projectile_portal_ball_guest",
		"projectile_portal_ball_unknown"
	};
	for _, ballClass in pairs(projectileBalls) do
		if ent:GetClass() == ballClass then
			ent:SetPos(Vector(-500, -500, -500));
			return;
		end;
	end;
	if not self:IsLinked() or (not self:GetActivated()) then
		return;
	end;
	if ent.InPortal then
		return;
	end;
	if ent:IsPlayer() then
		local pos;
		if not (ent.GP2_PortalCooldown and ent.GP2_PortalCooldown > CurTime()) then
			ent.GP2_PortalCooldown = CurTime() + 1;
			pos = ent:GetPos() + self:GetUp() * 20;
		else
			pos = ent:GetPos();
		end;
		ent:SetPos(pos);
		if not self:PlayerWithinBounds(ent) then
			return;
		end;
		ent.JustEntered = true;
		self:PlayerEnterPortal(ent);
	elseif self:CanPort(ent) then
		local phys = ent:GetPhysicsObject();
		if IsValid(phys) then
			constraint.AdvBallsocket(ent, game.GetWorld(), 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 0, 0, -180, -180, -180, 180, 180, 180, 0, 0, 1, 1, 1);
			if ent:GetCollisionGroup() ~= COLLISION_GROUP_PASSABLE_DOOR then
				ent.OriginalCollisionGroup = ent:GetCollisionGroup();
				ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
			end;
			self:MakeClone(ent);
			if ent.clone and IsValid(ent.clone) then
				ent.clone.TouchingPortalsCount = (ent.clone.TouchingPortalsCount or 0) + 1;
			end;
		end;
	end;
end;
function ENT:Touch(ent)
	if ent.GP2_PortalImmunity and ent.GP2_PortalImmunity > CurTime() then
		return;
	end;
	if ent.InPortal ~= self then
		self:StartTouch(ent);
	end;
	if not self:CanPort(ent) then
		return;
	end;
	if not self:IsLinked() or (not self:GetActivated()) then
		return;
	end;
	local portal = self:GetLinkedPartner();
	if not IsValid(portal) then
		return;
	end;
	if ent:IsPlayer() then
		if not ent.InPortal then
			if not self:PlayerWithinBounds(ent) then
				return;
			end;
			ent.JustEntered = true;
			self:PlayerEnterPortal(ent);
		else
			ent:SetGroundEntity(self);
			self:DoPort(ent);
			ent.AlreadyPorted = true;
			self:SyncClone(ent);
		end;
	else
		self:SyncClone(ent);
		ent:SetGroundEntity(NULL);
	end;
end;
local VelocityTransformCache = {};
local WallToWallTransforms = {
	NORTH_NORTH = function(v)
		return Vector(-v.x, -v.y, v.z);
	end,
	NORTH_SOUTH = function(v)
		return Vector(v.x, v.y, v.z);
	end,
	NORTH_EAST = function(v)
		return Vector(-v.y, v.x, v.z);
	end,
	NORTH_WEST = function(v)
		return Vector(v.y, -v.x, v.z);
	end,
	SOUTH_NORTH = function(v)
		return Vector(v.x, v.y, v.z);
	end,
	SOUTH_SOUTH = function(v)
		return Vector(-v.x, -v.y, v.z);
	end,
	SOUTH_EAST = function(v)
		return Vector(v.y, -v.x, v.z);
	end,
	SOUTH_WEST = function(v)
		return Vector(-v.y, v.x, v.z);
	end,
	EAST_NORTH = function(v)
		return Vector(v.y, -v.x, v.z);
	end,
	EAST_SOUTH = function(v)
		return Vector(-v.y, v.x, v.z);
	end,
	EAST_EAST = function(v)
		return Vector(-v.x, -v.y, v.z);
	end,
	EAST_WEST = function(v)
		return Vector(v.x, v.y, v.z);
	end,
	WEST_NORTH = function(v)
		return Vector(-v.y, v.x, v.z);
	end,
	WEST_SOUTH = function(v)
		return Vector(v.y, -v.x, v.z);
	end,
	WEST_EAST = function(v)
		return Vector(v.x, v.y, v.z);
	end,
	WEST_WEST = function(v)
		return Vector(-v.x, -v.y, v.z);
	end
};
local FloorToWallTransforms = {
	[0] = function(v)
		return Vector(v.z, v.y, 0);
	end,
	[90] = function(v)
		return Vector(-v.x, v.z, 0);
	end,
	[180] = function(v)
		return Vector(-v.z, -v.y, 0);
	end,
	[270] = function(v)
		return Vector(v.x, -v.z, 0);
	end
};
function ENT:EndTouch(ent)
	if not ent or (not ent:IsValid()) or ent:IsPlayer() or ent:IsPlayerHolding() then
		return;
	end;
	if not self:CanPort(ent) then
		return;
	end;
	local clone = ent.clone;
	if not clone or (not IsValid(clone)) then
		self:CleanupEntity(ent);
		return;
	end;
	local phys = ent:GetPhysicsObject();
	if not IsValid(phys) then
		self:CleanupEntity(ent);
		return;
	end;
	local portalOut = self:GetLinkedPartner();
	if not IsValid(portalOut) then
		self:CleanupEntity(ent);
		return;
	end;
	local placementIn = self.PlacementType or self:GetPlacementType();
	local placementOut = portalOut.PlacementType or portalOut:GetPlacementType();
	local success = self:TeleportEntityOptimized(ent, clone, phys, placementIn, placementOut, portalOut);
	if ent.clone and IsValid(ent.clone) then
		SafeRemoveEntity(ent.clone);
		ent.clone = nil;
	end;
	if success then
		self:CleanupEntity(ent);
	end;
end;
function ENT:TeleportEntityOptimized(ent, clone, phys, placementIn, placementOut, portalOut)
	local oldVel = phys:GetVelocity();
	if not oldVel then
		return false;
	end;
	local newVel = self:TransformVelocityOptimized(oldVel, placementIn, placementOut, portalOut);
	if not newVel then
		return false;
	end;
	ent:SetPos(clone:GetPos());
	ent:SetAngles(clone:GetAngles());
	phys:SetVelocity(newVel);
	ent.GP2_PortalImmunity = CurTime() + 0.5;
	return true;
end;
function ENT:TransformVelocityOptimized(vel, placementIn, placementOut, portalOut)
	local transformKey = placementIn .. "_" .. placementOut;
	if transformKey == "FLOOR_FLOOR" then
		return Vector(vel.x, -vel.y, -vel.z);
	end;
	if transformKey == "WALL_WALL" then
		local dirIn = self.CardinalDirection or self:GetCardinalDirection();
		local dirOut = portalOut.CardinalDirection or portalOut:GetCardinalDirection();
		local wallKey = dirIn .. "_" .. dirOut;
		local transform = WallToWallTransforms[wallKey];
		return transform and transform(vel) or vel;
	end;
	if transformKey == "WALL_FLOOR" then
		local yaw = math.Round((portalOut.StableAngles or portalOut:GetAngles()).y);
		local normalizedYaw = (yaw % 360 + 360) % 360;
		if normalizedYaw > 315 or normalizedYaw <= 45 then
			yaw = 0;
		elseif normalizedYaw > 45 and normalizedYaw <= 135 then
			yaw = 90;
		elseif normalizedYaw > 135 and normalizedYaw <= 225 then
			yaw = 180;
		else
			yaw = 270;
		end;
		local WallToFloorTransforms = {
			[0] = function(v)
				return Vector(-v.y, v.x, -v.y);
			end,
			[90] = function(v)
				return Vector(v.x, -v.y, -v.y);
			end,
			[180] = function(v)
				return Vector(v.y, -v.x, -v.y);
			end,
			[270] = function(v)
				return Vector(-v.x, -v.y, -v.y);
			end
		};
		local transform = WallToFloorTransforms[yaw];
		return transform and transform(vel) or Vector((-vel.y), (-vel.x), 0);
	end;
	if transformKey == "FLOOR_WALL" then
		local yaw = math.Round((portalOut.StableAngles or portalOut:GetAngles()).y);
		local normalizedYaw = (yaw % 360 + 360) % 360;
		if normalizedYaw > 315 or normalizedYaw <= 45 then
			yaw = 0;
		elseif normalizedYaw > 45 and normalizedYaw <= 135 then
			yaw = 90;
		elseif normalizedYaw > 135 and normalizedYaw <= 225 then
			yaw = 180;
		else
			yaw = 270;
		end;
		local transform = FloorToWallTransforms[yaw];
		return transform and transform(vel) or Vector((-vel.y), (-vel.x), 0);
	end;
	if transformKey == "FLOOR_ROOF" then
		return Vector(vel.x, -vel.y, vel.z);
	end;
	return vel;
end;
function ENT:GetCardinalDirection()
	if not self.CardinalDirection then
		local yaw = (self.StableAngles or self:GetAngles()).y;
		self.CardinalDirection = GetCardinalFromYaw(yaw);
	end;
	return self.CardinalDirection;
end;
function ENT:GetPlacementType()
	if not self.PlacementType then
		local angles = self.OriginalAngles or self:GetAngles();
		if self:IsFloor(angles) then
			self.PlacementType = "FLOOR";
		elseif self:IsCeiling(angles) then
			self.PlacementType = "ROOF";
		else
			self.PlacementType = "WALL";
		end;
	end;
	return self.PlacementType;
end;
function ENT:CleanupEntity(ent)
	if ent.clone and IsValid(ent.clone) then
		ent.clone.TouchingPortalsCount = (ent.clone.TouchingPortalsCount or 1) - 1;
		if ent.clone.TouchingPortalsCount <= 0 then
			SafeRemoveEntity(ent.clone);
		end;
	end;
	ent.InPortal = nil;
	ent.clone = nil;
	if ent.OriginalCollisionGroup then
		ent:SetCollisionGroup(ent.OriginalCollisionGroup);
		ent.OriginalCollisionGroup = nil;
	end;
	if SERVER then
		timer.Simple(0, function()
			if IsValid(ent) then
				constraint.RemoveConstraints(ent, "AdvBallsocket");
			end;
		end);
	end;
end;
function SafeRemoveEntity(ent)
	if not ent or (not IsValid(ent)) then
		return;
	end;
	if ent.clone then
		ent.clone = nil;
	end;
	if ent.daddyEnt then
		ent.daddyEnt = nil;
	end;
	if ent.InPortal then
		ent.InPortal = nil;
	end;
	timer.Simple(0, function()
		if IsValid(ent) then
			ent:Remove();
		end;
	end);
end;
function ENT:CanPort(ent)
	local c = ent:GetClass();
	if ent:IsPlayer() or ent ~= nil and ent:IsValid() and (not ent.isClone) and ent:GetPhysicsObject() and c ~= "noportal_pillar" and c ~= "prop_dynamic" and c ~= "rpg_missile" and string.sub(c, 1, 5) ~= "func_" and string.sub(c, 1, 9) ~= "prop_door" then
		return true;
	else
		return false;
	end;
end;
function ENT:MakeClone(ent)
	if not self:IsLinked() or (not self:GetActivated()) then
		return;
	end;
	local portal = self:GetLinkedPartner();
	if not IsValid(portal) then
		return;
	end;
	if ent.clone ~= nil then
		return;
	end;
	local clone = ents.Create("prop_physics");
	clone:SetSolid(SOLID_NONE);
	clone:SetPos(self:GetPortalPosOffsets(portal, ent));
	clone:SetAngles(self:GetPortalAngleOffsets(portal, ent));
	clone.isClone = true;
	clone.daddyEnt = ent;
	clone:SetModel(ent:GetModel());
	clone:Spawn();
	clone:SetSkin(ent:GetSkin());
	clone:SetMaterial(ent:GetMaterial());
	clone:SetColor(ent:GetColor());
	ent:DeleteOnRemove(clone);
	local phy = clone:GetPhysicsObject();
	if IsValid(phy) then
		phy:EnableCollisions(false);
		phy:EnableGravity(false);
		phy:EnableDrag(false);
		phy:EnableMotion(false);
	end;
	ent.clone = clone;
	clone.InPortal = portal;
	clone.GP2_NoSyncFrames = 0;
end;
function ENT:SyncClone(ent)
	local clone = ent.clone;
	if not clone or (not IsValid(clone)) then
		return;
	end;
	if not self:IsLinked() or (not self:GetActivated()) then
		return;
	end;
	local portal = self:GetLinkedPartner();
	if not IsValid(portal) then
		return;
	end;
	local cacheKey = self:EntIndex() .. "_" .. portal:EntIndex();
	if not self.TransformCache then
		self.TransformCache = {};
	end;
	local transform = self.TransformCache[cacheKey];
	if not transform then
		transform = {
			offsetMultiplier = Vector(1, -1, -1),
			angleMultiplier = Vector(1, 1, -1)
		};
		self.TransformCache[cacheKey] = transform;
	end;
	local offset = self:WorldToLocal(ent:GetPos());
	offset:Mul(transform.offsetMultiplier);
	local newPos = portal:LocalToWorld(offset);
	local newAngles = self:GetPortalAngleOffsets(portal, ent);
	newAngles.r = -newAngles.r;
	clone:SetPos(newPos);
	clone:SetAngles(newAngles);
	if SERVER then
		local origPhys = ent:GetPhysicsObject();
		local clonePhys = clone:GetPhysicsObject();
		if IsValid(origPhys) and IsValid(clonePhys) then
			local origVel = origPhys:GetVelocity();
			local transformedVel = self:TransformVelocityOptimized(origVel, self:GetPlacementType(), portal:GetPlacementType(), portal);
			clonePhys:SetVelocity(transformedVel);
		end;
	end;
	clone.GP2_NoSyncFrames = 0;
	if not clone.GP2_LastVisualSync or CurTime() - clone.GP2_LastVisualSync > 0.1 then
		self:SyncCloneVisuals(ent, clone);
		clone.GP2_LastVisualSync = CurTime();
	end;
end;
function ENT:SyncCloneVisuals(ent, clone)
	local entSkin = ent:GetSkin();
	local entMaterial = ent:GetMaterial();
	local entColor = ent:GetColor();
	if clone:GetSkin() ~= entSkin then
		clone:SetSkin(entSkin);
	end;
	if clone:GetMaterial() ~= entMaterial then
		clone:SetMaterial(entMaterial);
	end;
	if clone:GetColor() ~= entColor then
		clone:SetColor(entColor);
	end;
end;
local GP2_CloneCheckCache = {};
local GP2_LastCloneCheck = 0;
local GP2_CloneCheckInterval = 0.1;
hook.Add("Think", "GP2_CloneSyncCheck", function()
	local currentTime = CurTime();
	if currentTime - GP2_LastCloneCheck < GP2_CloneCheckInterval then
		return;
	end;
	GP2_LastCloneCheck = currentTime;
	if math.random(1, 1000) == 1 then
		GP2_CloneCheckCache = {};
	end;
	if not GP2_CloneCheckCache.entities or GP2_CloneCheckCache.lastUpdate < currentTime - 1 then
		GP2_CloneCheckCache.entities = {};
		for _, ent in ipairs(ents.GetAll()) do
			if ent.isClone then
				table.insert(GP2_CloneCheckCache.entities, ent);
			end;
		end;
		GP2_CloneCheckCache.lastUpdate = currentTime;
	end;
	for i = #GP2_CloneCheckCache.entities, 1, -1 do
		local ent = GP2_CloneCheckCache.entities[i];
		if IsValid(ent) and ent.GP2_NoSyncFrames ~= nil then
			ent.GP2_NoSyncFrames = ent.GP2_NoSyncFrames + 1;
			if ent.GP2_NoSyncFrames > 600 then
				if not ent.daddyEnt or (not IsValid(ent.daddyEnt)) then
					SafeRemoveEntity(ent);
					table.remove(GP2_CloneCheckCache.entities, i);
				end;
			end;
		else
			table.remove(GP2_CloneCheckCache.entities, i);
		end;
	end;
end);
function ENT:DoPort(ent)
	if not self:CanPort(ent) then
		return;
	end;
	if not ent or (not ent:IsValid()) then
		return;
	end;
	if SERVER then
		constraint.RemoveConstraints(ent, "AdvBallsocket");
	end;
	if not self:IsLinked() or (not self:GetActivated()) then
		return;
	end;
	local portal = self:GetLinkedPartner();
	if not IsValid(portal) then
		return;
	end;
	if ent:IsPlayer() then
		local eyepos = ent:EyePos();
		local portalPos = self.StablePos or self:GetPos();
		local portalNormal = self.StableAngles and self.StableAngles:Forward() or self:GetForward();
		local isPlayerBehind = true;
		if ent.InPortal == self then
			ent.InPortal = nil;
			ent:SetMoveType(MOVETYPE_NOCLIP);
			if ent.GP2_SavedEyeAngles then
				ent:SetEyeAngles(ent.GP2_SavedEyeAngles);
				ent.GP2_SavedEyeAngles = nil;
			end;
			local ang = ent:EyeAngles();
			if ang.p > 30 then
				ang.p = 90;
				ent:SetEyeAngles(ang);
			end;
			timer.Create("Walk_" .. ent:EntIndex(), 0.05, 1, function()
				if IsValid(ent) then
					ent:SetMoveType(MOVETYPE_WALK);
					ent:ResetHull();
				end;
			end);
			if ent.PortalClone and IsValid(ent.PortalClone) then
				ent.PortalClone:Remove();
				ent.PortalClone = nil;
			end;
		end;
	else
		local vel = ent:GetVelocity();
		if not vel then
			return;
		end;
		local nuVel = self:TransformVelocityBetweenPortals(vel, portal);
		local phys = ent:GetPhysicsObject();
		if IsValid(phys) and ent.clone and IsValid(ent.clone) then
			if not self:IsBehind(ent:GetPos(), self:GetPos(), self:GetForward()) then
				ent:SetPos(ent.clone:GetPos());
				ent:SetAngles(ent.clone:GetAngles());
				phys:SetVelocity(nuVel);
				ent.GP2_PortalImmunity = CurTime() + 1;
				ent.InPortal = nil;
				ent.clone:Remove();
				ent.clone = nil;
			end;
		end;
	end;
end;
function ENT:IsHorizontal(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles());
	local pitch = math.Round(math.NormalizeAngle(angles.p));
	return math.abs(pitch) < 15;
end;
function ENT:IsFloor(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles());
	local pitch = math.Round(math.NormalizeAngle(angles.p));
	local roll = math.Round(math.NormalizeAngle(angles.r));
	return math.abs(pitch) < 15 and math.abs(roll) < 15;
end;
function ENT:IsCeiling(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles());
	local pitch = math.Round(math.NormalizeAngle(angles.p));
	local roll = math.Round(math.NormalizeAngle(angles.r));
	return math.abs(pitch) < 15 and math.abs(math.abs(roll) - 180) < 15;
end;
function ENT:IsWall(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles());
	local pitch = math.Round(math.NormalizeAngle(angles.p));
	return math.abs(pitch + 90) < 15;
end;
function ENT:TransformVelocityBetweenPortals(vel, targetPortal)
	local speed = vel:Length();
	local transformedVel = Vector(0, 0, 0);
	local sourceAngles = self.OriginalAngles or self:GetAngles();
	local targetAngles = targetPortal.OriginalAngles or targetPortal:GetAngles();
	local sourceIsFloor = self:IsFloor(sourceAngles);
	local sourceIsCeiling = self:IsCeiling(sourceAngles);
	local sourceIsWall = self:IsWall(sourceAngles);
	local targetIsFloor = targetPortal:IsFloor(targetAngles);
	local targetIsCeiling = targetPortal:IsCeiling(targetAngles);
	local targetIsWall = targetPortal:IsWall(targetAngles);
	if sourceIsFloor and targetIsFloor then
		if vel.z < (-50) then
			transformedVel = Vector(vel.x, vel.y, -vel.z);
		else
			transformedVel = targetPortal:GetForward() * speed;
		end;
	elseif sourceIsFloor and targetIsWall then
		local localVel = self:WorldToLocal(vel);
		localVel.z = 0;
		local wallVel = targetPortal:LocalToWorld(localVel);
		local forward = targetPortal:GetForward();
		transformedVel = wallVel:GetNormalized() * speed + forward * 50;
	elseif sourceIsWall and targetIsFloor then
		local localVel = self:WorldToLocal(vel);
		localVel.y = 0;
		local floorVel = targetPortal:LocalToWorld(localVel);
		local up = targetPortal:GetUp();
		transformedVel = floorVel:GetNormalized() * speed + up * 50;
	elseif sourceIsCeiling and targetIsFloor then
		transformedVel = Vector(vel.x, vel.y, math.abs(vel.z));
	elseif sourceIsCeiling and targetIsCeiling then
		transformedVel = targetPortal:GetForward() * speed;
	elseif sourceIsCeiling and targetIsWall then
		transformedVel = targetPortal:GetForward() * speed;
	elseif sourceIsWall and targetIsCeiling then
		transformedVel = targetPortal:GetForward() * speed;
	elseif sourceIsWall and targetIsWall then
		transformedVel = targetPortal:GetForward() * speed;
	else
		transformedVel = targetPortal:GetForward() * speed;
	end;
	if transformedVel:Length() < 100 then
		transformedVel = targetPortal:GetForward() * 250;
	end;
	return transformedVel;
end;
function ENT:OnFloorWithAngles(angles)
	angles = angles or self:GetAngles();
	local up = angles:Up();
	local forward = angles:Forward();
	local isFloorUp = up.z > 0.7;
	local isFloorForward = forward.z > 0.7;
	local result = isFloorUp and isFloorForward;
	return result;
end;
function ENT:OnRoofWithAngles(angles)
	angles = angles or self:GetAngles();
	local forward = angles:Forward();
	local result = forward.z < (-0.7);
	return result;
end;
function ENT:OnFloor()
	local up = self:GetUp();
	local angles = self:GetAngles();
	local isFloorUp = up.z > 0.7;
	local isFloorForward = (self:GetForward()).z > 0.7;
	local result = isFloorUp and isFloorForward;
	return result;
end;
function ENT:OnRoof()
	local up = self:GetUp();
	local forward = self:GetForward();
	local result = forward.z < (-0.7);
	return result;
end;
function ENT:IsHorizontal()
	return (self:GetAngles()).p == 0;
end;
function ENT:EmitTeleportSound(ent)
	if ent:IsPlayer() then
	end;
end;
function ENT:PlayerEnterPortal(ent)
	ent.InPortal = self;
	self:SetupPlayerClone(ent);
	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableDrag(true);
	end;
	ent:SetMoveType(MOVETYPE_FLY);
	ent:SetGroundEntity(self);
	local placement = self.PlacementType or self:GetPlacementType();
	if placement == "WALL" then
		ent:SetHullDuck(Vector(-32, -32, -32), Vector(32, 32, 72));
		ent.GP2_SavedEyeAngles = ent:EyeAngles();
		local portalForward = self:GetForward();
		local newAngles = portalForward:Angle();
		newAngles.p = 0;
		ent:SetEyeAngles(newAngles);
		local push = (Vector(portalForward.x, portalForward.y, 0)):GetNormalized() * 100;
		ent:SetVelocity(push);
	elseif placement == "ROOF" then
		ent:SetHullDuck(Vector(-32, -32, 0), Vector(32, 32, 72));
	else
		ent:SetHullDuck(Vector(-32, -32, 0), Vector(32, 32, 72));
	end;
	ent.OriginalCollisionGroup = ent:GetCollisionGroup();
	ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
	if ent.JustEntered then
		if SERVER then
			local snd_portal2 = GetConVar("portal_sound") or CreateConVar("portal_sound", "0", FCVAR_ARCHIVE);
			local vel = ent:GetVelocity();
			local pitch = 100 + 30 * (vel:Length() - 450) / 1000;
		end;
		ent.JustEntered = false;
	end;
end;
function ENT:SetupPlayerClone(ply)
	if self.BaseSetupPlayerClone then
		self:BaseSetupPlayerClone(ply);
	end;
end;
function ENT:UpdatePhysmesh()
	local size = self:GetSize();
	if not PORTAL_HEIGHT or (not PORTAL_WIDTH) then
		PORTAL_HEIGHT = PORTAL_HEIGHT or 112;
		PORTAL_WIDTH = PORTAL_WIDTH or 64;
		GP2.Print("Portal %d: Constants not loaded, using defaults", self:EntIndex());
	end;
	if not size or size == Vector(0, 0, 0) or size.x <= 0 or size.y <= 0 or size.z <= 0 then
		GP2.Print("Portal %d: Invalid size for physics mesh: %s", self:EntIndex(), tostring(size));
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 8);
		else
			size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7);
		end;
		self:SetSizeInternal(size);
	end;
	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		local physicsInitialized = false;
		if not physicsInitialized then
			local success = pcall(self.PhysicsInit, self, SOLID_VPHYSICS);
			if success and IsValid(self:GetPhysicsObject()) then
				physicsInitialized = true;
				GP2.Print("Portal %d: Physics initialized with SOLID_VPHYSICS", self:EntIndex());
			end;
		end;
		if not physicsInitialized then
			local success = pcall(self.PhysicsInitBox, self, -size, size);
			if success and IsValid(self:GetPhysicsObject()) then
				physicsInitialized = true;
				GP2.Print("Portal %d: Physics initialized with PhysicsInitBox", self:EntIndex());
			end;
		end;
		if not physicsInitialized then
			local simpleMesh = {
				Vector(-size.x, -size.y, -size.z),
				Vector(-size.x, -size.y, size.z),
				Vector(-size.x, size.y, -size.z),
				Vector(-size.x, size.y, size.z),
				Vector(size.x, -size.y, -size.z),
				Vector(size.x, -size.y, size.z),
				Vector(size.x, size.y, -size.z),
				Vector(size.x, size.y, size.z)
			};
			local success = pcall(self.PhysicsInitConvex, self, simpleMesh);
			if success and IsValid(self:GetPhysicsObject()) then
				physicsInitialized = true;
				GP2.Print("Portal %d: Physics initialized with simple convex mesh", self:EntIndex());
			end;
		end;
		if physicsInitialized and IsValid(self:GetPhysicsObject()) then
			local finalMesh = {};
			local sides = 8;
			local angleMul = 360 / sides;
			local degreeOffset = (sides * 90 + (sides % 4 ~= 0 and 0 or 45)) * (math.pi / 180);
			for side = 1, sides do
				local sidea = math.rad(side * angleMul) + degreeOffset;
				local sidex = math.sin(sidea);
				local sidey = math.cos(sidea);
				local side1 = Vector(sidex, sidey, -1);
				local side2 = Vector(sidex, sidey, 0);
				table.insert(finalMesh, side1 * size);
				table.insert(finalMesh, side2 * size);
			end;
			if #finalMesh > 0 then
				local success, err = pcall(self.PhysicsInitConvex, self, finalMesh);
				if success then
					self:EnableCustomCollisions(true);
					local phys = self:GetPhysicsObject();
					if IsValid(phys) then
						phys:EnableMotion(false);
						phys:SetContents((_G.CONTENTS_SOLID or 0) + (_G.CONTENTS_MOVEABLE or 0) + (_G.CONTENTS_BLOCKLOS or 0));
						GP2.Print("Portal %d: Detailed mesh physics created successfully", self:EntIndex());
					end;
				else
					GP2.Print("Portal %d: Detailed mesh failed, keeping simple physics: %s", self:EntIndex(), err or "unknown error");
					self:EnableCustomCollisions(true);
					local phys = self:GetPhysicsObject();
					if IsValid(phys) then
						phys:EnableMotion(false);
						phys:SetContents((_G.CONTENTS_SOLID or 0) + (_G.CONTENTS_MOVEABLE or 0) + (_G.CONTENTS_BLOCKLOS or 0));
					end;
				end;
			else
				GP2.Print("Portal %d: No mesh generated for physics", self:EntIndex());
			end;
		else
			GP2.Print("Failure to create a portal physics mesh %d - All methods failed", self:EntIndex());
			self:SetSolid(SOLID_NONE);
			self:SetMoveType(MOVETYPE_NONE);
		end;
	else
		self:PhysicsInit(6);
		if (self:GetPhysicsObject()):IsValid() then
			local meshSize = size * 2;
			local x0, x1 = (-meshSize.x) / 2, meshSize.x / 2;
			local y0, y1 = (-meshSize.y) / 2, meshSize.y / 2;
			local z0, z1 = -meshSize.z, meshSize.z;
			local mesh = {
				Vector(x0, y0, z0),
				Vector(x0, y0, z1),
				Vector(x0, y1, z0),
				Vector(x0, y1, z1),
				Vector(x1, y0, z0),
				Vector(x1, y0, z1),
				Vector(x1, y1, z0),
				Vector(x1, y1, z1)
			};
			local success, err = pcall(self.PhysicsInitConvex, self, mesh);
			if not success then
				GP2.Print("Portal %d: New environment PhysicsInitConvex failed: %s", self:EntIndex(), err or "unknown error");
				self:PhysicsDestroy();
			else
				local phys = self:GetPhysicsObject();
				if IsValid(phys) then
					phys:EnableMotion(false);
					phys:SetContents((_G.CONTENTS_SOLID or 0) + (_G.CONTENTS_MOVEABLE or 0) + (_G.CONTENTS_BLOCKLOS or 0));
				end;
			end;
		else
			self:PhysicsDestroy();
			GP2.Print("Failure to create a portal physics mesh %d - New environment invalid physics object", self:EntIndex());
		end;
	end;
end;
if game.SinglePlayer() then
	function ENT:TestCollision(startpos, delta, isbox, extents, mask)
		if bit.band(mask, CONTENTS_GRATE) ~= 0 then
			return true;
		end;
	end;
end;
function ENT:GetGroundZ()
	local realPortalPos = self:GetPos();
	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		realPortalPos = realPortalPos - self:GetUp() * 7.1;
	end;
	local tr = util.TraceLine({
		start = realPortalPos,
		endpos = realPortalPos - Vector(0, 0, 10000),
		filter = self
	});
	return tr.HitPos.z;
end;
function ENT:SpawnWoodenCratesBelow()
	local up = self:GetUp();
	local isFloor = up:Dot(Vector(0, 0, 1)) > 0.9;
	local isCeiling = up:Dot(Vector(0, 0, -1)) > 0.9;
	local isWall = not isFloor and (not isCeiling);
	if isWall then
		local realPortalPos = self:GetPos();
		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			realPortalPos = realPortalPos - self:GetUp() * 7.1;
		end;
		local groundZ = self:GetGroundZ();
		local portalPos = realPortalPos;
		local basePos = Vector(portalPos.x, portalPos.y, groundZ - 15);
		local offsets = {
			Vector(0, 0, 0),
			Vector(40, 0, 0),
			Vector(-40, 0, 0),
			Vector(0, 40, 0),
			Vector(0, -40, 0),
			Vector(40, 40, 0),
			Vector(-40, 40, 0),
			Vector(40, -40, 0),
			Vector(-40, -40, 0)
		};
		for _, offset in ipairs(offsets) do
			local cube = ents.Create("prop_physics");
			if IsValid(cube) then
				cube:SetModel("models/props_junk/wood_crate001a.mdl");
				cube:SetPos(basePos + offset);
				cube:Spawn();
				cube:SetOwner(self);
				cube.InPortalCube = true;
				cube.GP2_IsPortalCrate = true;
				cube:SetColor(Color(255, 255, 255, 255));
				cube:SetRenderMode(RENDERMODE_TRANSALPHA);
				cube:SetSolid(SOLID_NONE);
				cube:SetCollisionGroup(COLLISION_GROUP_WORLD);
				timer.Simple(0.1, function()
					if IsValid(cube) then
						cube:SetSolid(SOLID_VPHYSICS);
						cube:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER);
						cube.StartTouch = function(self, ent)
							if ent:IsPlayer() then
								return;
							end;
						end;
					end;
				end);
				local phys = cube:GetPhysicsObject();
				if IsValid(phys) then
					phys:EnableMotion(false);
					phys:EnableGravity(false);
					phys:SetVelocity(Vector(0, 0, 0));
					phys:AddAngleVelocity(-phys:GetAngleVelocity());
					phys:SetAngleVelocity(Vector(0, 0, 0));
					phys:Sleep();
				end;
				cube:SetMoveType(MOVETYPE_NONE);
				table.insert(self.SpawnedCubes, cube);
			end;
		end;
	end;
end;
function ENT:SpawnCratesBelow()
	local groundZ = self:GetGroundZ();
	local portalPos = self:GetPos();
	local spawnZ = groundZ + 1;
	local centerPos = Vector(portalPos.x, portalPos.y, spawnZ);
	local crate = ents.Create("prop_physics");
	crate:SetModel("models/props/wood_crate001a.mdl");
	crate:SetPos(centerPos);
	crate:Spawn();
	crate.GP2_IsPortalCrate = true;
	for _, ply in ipairs(player.GetAll()) do
		constraint.NoCollide(crate, ply, 0, 0);
	end;
end;
if SERVER then
	util.AddNetworkString("GP2_ChatMessage");
	function GP2.SendChatMessage(ply, ...)
		local args = {
			...
		};
		net.Start("GP2_ChatMessage");
		net.WriteTable(args);
		if IsValid(ply) then
			net.Send(ply);
		else
			net.Broadcast();
		end;
	end;
else
	net.Receive("GP2_ChatMessage", function()
		local args = net.ReadTable();
		chat.AddText(unpack(args));
	end);
end;
function ENT:IsLinked()
	local partner = self.GetLinkedPartner and self:GetLinkedPartner() or nil;
	return IsValid(partner) and partner.GetActivated and partner:GetActivated();
end;
