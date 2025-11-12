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
	self.PlatformWidth = 500;
	self.PlatformLength = 48;
	self.PlatformThickness = self.PlatformThickness or 1;
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
		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM and self:GetPlacedByMap() then
			self:SetPos(self:GetPos() + (self:GetAngles()):Up() * 7.1);
		end;
	end;
	if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		if SERVER and self:GetPlacedByMap() then
			self:BuildPortalEnvironment();
		end;
	end;
	if SERVER and self:GetPlacedByMap() then
		self:BuildPortalFloor();
	end;
	PortalManager.SetPortal(self:GetLinkageGroup(), self);
	PortalManager.Portals[self] = true;
	self.PropTeleportEnabled = true;
	self.ClonedEntities = {};
	self.SpawnedCubes = {};
	if SERVER then
		timer.Simple(0.3, function()
			if not IsValid(self) then
				return;
			end;
			local ply = nil;
			for _, p in ipairs(player.GetAll()) do
				if IsValid(self) and IsValid(p) and (p:GetPos()):Distance(self:GetPos()) < 200 then
					ply = p;
					break;
				end;
			end;
			if not IsValid(self) then
				return;
			end;
			local pitch = (self:GetAngles()).p;
			local shouldCreate = false;
			if pitch <= (-89) and pitch >= (-91) then
				shouldCreate = true;
			end;
			if not ply then
				ply = (player.GetAll())[1];
			end;
			if IsValid(ply) and shouldCreate and IsValid(self) then
				local offsets = {
					Vector(0, 0, 0),
					Vector(40, 0, 0),
					Vector(-40, 0, 0),
					Vector(0, 40, 0),
					Vector(0, -40, 0),
					Vector(40, 40, 0),
					Vector(-40, -40, 0),
					Vector(40, -40, 0),
					Vector(-40, 40, 0)
				};
				self.GP2_PortalPlatforms = {};
				for i, vec in ipairs(offsets) do
					if IsValid(self) then
						local plat = self:CreatePortalPlatform(ply, vec.x, vec.y, vec.z);
						self.GP2_PortalPlatforms[i] = plat;
					end;
				end;
			end;
		end);
	end;
end;
function ENT:CreatePortalPlatform(ply, dx, dy, dz)
	dx = dx or 0;
	dy = dy or 0;
	dz = dz or 0;
	local portalPos = self:GetPos();
	local portalAng = self:GetAngles();
	local forward = portalAng:Forward();
	local offset = forward * 40 + Vector(dx, dy, dz);
	local platformPos = portalPos + offset;
	platformPos.z = (ply:GetPos()).z - 2;
	local platform = ents.Create("prop_physics");
	platform:SetModel("models/hunter/plates/plate1x1.mdl");
	platform:SetModelScale(1, 0);
	local w = self.PlatformWidth;
	local l = self.PlatformLength;
	local t = self.PlatformThickness;
	local mins = Vector((-w) / 2, (-l) / 2, (-t) / 2);
	local maxs = Vector(w / 2, l / 2, t / 2);
	platform:PhysicsInitBox(mins, maxs);
	platform:SetSolid(SOLID_VPHYSICS);
	platform:SetMoveType(MOVETYPE_NONE);
	local phys = platform:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
		phys:Wake();
	end;
	platform:SetPos(platformPos);
	platform:SetAngles(Angle(0, portalAng.y, 0));
	platform:Spawn();
	platform:SetColor(Color(255, 255, 0, 0));
	platform:SetRenderMode(RENDERMODE_TRANSALPHA);
	platform:SetCollisionGroup(COLLISION_GROUP_NONE);
	platform:SetOwner(ply);
	local phys = platform:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
		phys:Wake();
	end;
	platform.GP2_IsPortalPlatform = true;
	return platform;
end;
if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
	function ENT:BuildPortalEnvironment()
		self.__portalenvironmentphymesh = ents.Create("__portalenvironmentphymesh");
		self.__portalenvironmentphymesh:SetPos(self:GetPos());
		self.__portalenvironmentphymesh:SetPortalAngles(self:GetAngles());
		self.__portalenvironmentphymesh:Spawn();
	end;
end;
function ENT:BuildPortalFloor()
	if self:GetPlacedByMap() then
		local floorEnt = ents.Create("prop_physics");
		if IsValid(floorEnt) then
			local size = self:GetSize();
			local floorPos = self:GetPos() - self:GetUp() * (size.z + 5);
			floorEnt:SetPos(floorPos);
			floorEnt:SetAngles(self:GetAngles());
			floorEnt:SetModel("models/hunter/plates/plate1x1.mdl");
			floorEnt:PhysicsInit(SOLID_VPHYSICS);
			floorEnt:SetMoveType(MOVETYPE_NONE);
			floorEnt:SetCollisionGroup(COLLISION_GROUP_WORLD);
			floorEnt:SetNoDraw(true);
			floorEnt:DrawShadow(false);
			floorEnt:SetModelScale(size.x * 2 / 16);
			floorEnt:Spawn();
			floorEnt.IsPortalFloor = true;
			floorEnt.ParentPortal = self;
			self.PortalFloor = floorEnt;
		end;
	end;
end;
function ENT:OnRemove()
	PortalManager.PortalIndex = math.max(PortalManager.PortalIndex - 1, 0);
	self:CleanupAllClones();
	self:BootAllPlayers();
	if self.PortalFloor and IsValid(self.PortalFloor) then
		self.PortalFloor:Remove();
		self.PortalFloor = nil;
	end;
	if self.GP2_PortalPlatforms then
		for _, plat in ipairs(self.GP2_PortalPlatforms) do
			if IsValid(plat) then
				plat:Remove();
			end;
		end;
		self.GP2_PortalPlatforms = nil;
	end;
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
			print("Removing clone of entity ", ent, " due to portal removal.");
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
				print("Removing portal clone for player ", ply, " due to portal removal.");
				ply.PortalClone:Remove();
				ply.PortalClone = nil;
			end;
		end;
	end;
end;
function ENT:BootAllProps()
	for _, ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent.InPortal == self and (not ent:IsPlayer()) then
			ent.InPortal = nil;
			if ent.clone and IsValid(ent.clone) then
				print("Removing clone of entity ", ent, " due to portal removal.");
				ent.clone:Remove();
				ent.clone = nil;
			end;
			if ent.OriginalCollisionGroup then
				ent:SetCollisionGroup(ent.OriginalCollisionGroup);
				ent.OriginalCollisionGroup = nil;
			end;
		end;
	end;
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
		local pos = ent:GetPos();
		if not self:PlayerWithinBounds(ent) then
			return;
		end;
		ent.JustEntered = true;
	elseif self:CanPort(ent) then
		local phys = ent:GetPhysicsObject();
		if IsValid(phys) then
			constraint.AdvBallsocket(ent, game.GetWorld(), 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 0, 0, -180, -180, -180, 180, 180, 180, 0, 0, 1, 1, 1);
			if not ent.OriginalCollisionGroup then
				ent.OriginalCollisionGroup = ent:GetCollisionGroup();
			end;
			ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
			ent.InPortal = self;
			ent.LastPortalIntangibleTime = CurTime();
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
		else
			ent:SetGroundEntity(self);
			local eyepos = ent:EyePos();
			local function IsBehind(posA, posB, normal)
				local Vec1 = (posB - posA):GetNormalized();
				return normal:Dot(Vec1) < 0;
			end;
			if not IsBehind(eyepos, self:GetPos(), self:GetForward()) then
				ent.AlreadyPorted = true;
			end;
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
	local wasTouching = ent.InPortal == self;
	ent.InPortal = nil;
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
	local success = false;
	if wasTouching then
		success = self:TeleportEntityOptimized(ent, clone, phys, placementIn, placementOut, portalOut);
	end;
	if ent.clone and IsValid(ent.clone) then
		SafeRemoveEntity(ent.clone);
		ent.clone = nil;
	end;
	if success then
		self:CleanupEntity(ent);
	else
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
	local outVel = newVel:GetNormalized() * oldVel:Length() * 0.75;
	ent:SetPos(clone:GetPos());
	ent:SetAngles(clone:GetAngles());
	phys:SetVelocity(outVel);
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
		return Vector(vel.x, vel.y, vel.z);
	end;
	if transformKey == "WALL_ROOF" then
		return Vector(vel.x, vel.y, -vel.z);
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
	if ent.InPortal == self then
		ent.InPortal = nil;
	end;
	local touchingAnyPortal = false;
	for otherPortal, _ in pairs(PortalManager.Portals or {}) do
		if IsValid(otherPortal) then
			local portalMins, portalMaxs = otherPortal:OBBMins(), otherPortal:OBBMaxs();
			local props = ents.FindInBox(otherPortal:LocalToWorld(portalMins), otherPortal:LocalToWorld(portalMaxs));
			for _, checkEnt in ipairs(props) do
				if checkEnt == ent then
					touchingAnyPortal = true;
					break;
				end;
			end;
			if touchingAnyPortal then
				break;
			end;
		end;
	end;
	if not touchingAnyPortal and ent.OriginalCollisionGroup then
		local originalGroup = ent.OriginalCollisionGroup;
		timer.Simple(0.1, function()
			if IsValid(ent) and originalGroup then
				ent:SetCollisionGroup(originalGroup);
				ent.OriginalCollisionGroup = nil;
			end;
		end);
		ent.clone = nil;
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
	if ent.GP2_IsPortalPlatform then
		return false;
	end;
	if ent:IsPlayer() or ent ~= nil and ent:IsValid() and (not ent.isClone) and ent:GetPhysicsObject() and c ~= "noportal_pillar" and c ~= "prop_dynamic" and c ~= "rpg_missile" and string.sub(c, 1, 5) ~= "func_" and string.sub(c, 1, 9) ~= "prop_door" then
		return true;
	else
		return false;
	end;
end;
function ENT:MakeClone(ent)
	print(ent, ent:GetClass(), ent:GetModel(), ent:GetPos(), ent:GetAngles(), ent:GetSkin(), ent:GetMaterial(), ent:GetColor(), ent:GetOwner());
	if ent:GetModel() == "models/props_junk/popcan01a.mdl" then
		return;
	end;
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
	ent.GP2_HoldInfo = nil;
	for _, ply in ipairs(player.GetAll()) do
		local wep = ply:GetActiveWeapon();
		if IsValid(wep) then
			local wepClass = wep:GetClass();
			if wepClass == "weapon_portalgun" then
				local entityInUse = wep.GetEntityInUse and wep:GetEntityInUse();
				if IsValid(entityInUse) then
					local heldEnt = ent;
					if entityInUse:GetClass() == "player_pickup" and IsValid(entityInUse:GetPhysicsAttacker()) then
						heldEnt = entityInUse:GetPhysicsAttacker();
					end;
					if entityInUse == ent or heldEnt == ent then
						ent.GP2_HoldInfo = {
							holdingPlayer = ply,
							grabEnt = wep,
							wepClass = wepClass,
							portalgunOwner = ply
						};
						break;
					end;
				end;
			elseif wepClass == "weapon_physgun" or wepClass == "gmod_tool" then
				if wep.GrabEnt and wep.GrabEnt == ent then
					ent.GP2_HoldInfo = {
						holdingPlayer = ply,
						grabEnt = wep,
						wepClass = wepClass,
						portalgunOwner = ply
					};
					break;
				end;
			end;
		end;
		if ply.holding and ply.holding == ent then
			ent.GP2_HoldInfo = {
				holdingPlayer = ply,
				grabEnt = nil,
				wepClass = nil,
				portalgunOwner = ply
			};
			break;
		end;
	end;
	if not ent.GP2_HoldInfo then
		local owner = ent:GetOwner();
		if IsValid(owner) and owner:IsPlayer() then
			ent.GP2_HoldInfo = {
				holdingPlayer = owner,
				grabEnt = nil,
				wepClass = "owner",
				portalgunOwner = owner
			};
		end;
	end;
	if not ent.GP2_HoldInfo then
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
			angleMultiplier = Vector(1, 1, 1)
		};
		self.TransformCache[cacheKey] = transform;
	end;
	local offset = self:WorldToLocal(ent:GetPos());
	offset:Mul(transform.offsetMultiplier);
	local newPos = portal:LocalToWorld(offset);
	local inAngles = self:GetAngles();
	local outAngles = portal:GetAngles();
	local entAngles = ent:GetAngles();
	local relYaw = math.AngleDifference(entAngles.y, inAngles.y);
	local relPitch = math.AngleDifference(entAngles.p, inAngles.p);
	local relRoll = math.AngleDifference(entAngles.r, inAngles.r);
	local transformKey = self:GetPlacementType() .. "_" .. portal:GetPlacementType();
	local newYaw;
	if transformKey == "WALL_WALL" then
		newYaw = outAngles.y + relYaw;
		newPitch = entAngles.p;
		newRoll = entAngles.r;
	elseif transformKey == "FLOOR_FLOOR" then
		newYaw = outAngles.y - relYaw + 180;
		newPitch = entAngles.p;
		newRoll = entAngles.r;
	elseif transformKey == "WALL_FLOOR" then
		newYaw = entAngles.p;
		newPitch = outAngles.r + relYaw;
		newRoll = entAngles.y - relYaw;
	elseif transformKey == "FLOOR_WALL" then
		newYaw = entAngles.r + relPitch;
		newPitch = -entAngles.p;
		newRoll = entAngles.y;
	end;
	local newAngles = Angle(newPitch, newYaw, newRoll);
	if clone:GetPos() ~= newPos or clone:GetAngles() ~= newAngles then
		clone:SetPos(newPos);
		clone:SetAngles(newAngles);
	end;
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
function ENT:PromoteCloneToReal(ent, clone)
	print("Promoting clone to real entity...");
	if clone:GetModel() == "models/props_junk/popcan01a.mdl" or clone:GetModel() == "models/props/laser_emitter.mdl" then
		return;
	end;
	if not IsValid(clone) or (not IsValid(ent)) then
		return;
	end;
	local spawnPos = nil;
	local spawnAng = clone:GetAngles();
	local owner = owner_portalgun;
	if not IsValid(owner) and ent.GP2_HoldInfo and IsValid(ent.GP2_HoldInfo.portalgunOwner) then
		owner = ent.GP2_HoldInfo.portalgunOwner;
	end;
	if IsValid(owner) then
		spawnPos = owner:GetPos() + owner:GetForward() * 30;
	else
		spawnPos = clone:GetPos();
	end;
	local savedProps = {
		pos = spawnPos,
		angles = spawnAng,
		model = clone:GetModel(),
		originalModel = ent:GetModel(),
		skin = clone:GetSkin(),
		material = clone:GetMaterial(),
		color = clone:GetColor(),
		velocity = Vector(0, 0, 0),
		isHeld = false,
		holdingPlayer = nil,
		grabEnt = nil
	};
	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then
		savedProps.velocity = phys:GetVelocity();
	end;
	for _, ply in ipairs(player.GetAll()) do
		local wep = ply:GetActiveWeapon();
		if IsValid(wep) then
			local wepClass = wep:GetClass();
			if wepClass == "weapon_physgun" or wepClass == "gmod_tool" or wepClass == "weapon_portalgun" then
				if wep.GrabEnt and wep.GrabEnt == ent then
					savedProps.isHeld = true;
					savedProps.holdingPlayer = ply;
					savedProps.grabEnt = wep;
					break;
				end;
			end;
		end;
		if ply.holding and ply.holding == ent then
			savedProps.isHeld = true;
			savedProps.holdingPlayer = ply;
			break;
		end;
	end;
	local className = ent:GetClass();
	local newEnt;
	local savedModel = ent:GetModel();
	print("Saved model: " .. tostring(savedModel));
	if className == "prop_weighted_cube" then
		newEnt = ents.Create("prop_weighted_cube_reflective");
	else
		newEnt = ents.Create("prop_physics");
	end;
	if not IsValid(newEnt) then
		return;
	end;
	newEnt:SetPos(savedProps.pos);
	newEnt:SetAngles(savedProps.angles);
	newEnt:SetModel(savedProps.model);
	newEnt:PhysicsInit(SOLID_VPHYSICS);
	newEnt:Spawn();
	newEnt:SetSkin(savedProps.skin);
	newEnt:SetMaterial(savedProps.material);
	newEnt:SetColor(savedProps.color);
	newEnt:SetCollisionGroup(COLLISION_GROUP_NONE);
	if IsValid(owner_portalgun) then
		newEnt:SetOwner(owner_portalgun);
	elseif ent.GP2_HoldInfo and IsValid(ent.GP2_HoldInfo.portalgunOwner) then
		newEnt:SetOwner(ent.GP2_HoldInfo.portalgunOwner);
	else
		local owner = ent:GetOwner();
		if IsValid(owner) then
			newEnt:SetOwner(owner);
		end;
	end;
	local newPhys = newEnt:GetPhysicsObject();
	local origPhys = ent:GetPhysicsObject();
	if IsValid(newPhys) and IsValid(origPhys) then
		newPhys:SetMass(origPhys:GetMass());
		newPhys:Wake();
		newPhys:EnableMotion(true);
		newPhys:EnableGravity(true);
		newPhys:EnableCollisions(true);
		newPhys:SetVelocity(savedProps.velocity);
	end;
	if ent.GP2_HoldInfo and IsValid(ent.GP2_HoldInfo.holdingPlayer) then
		timer.Simple(0.001, function()
			if IsValid(ent.GP2_HoldInfo.holdingPlayer) and IsValid(newEnt) then
				if ent.GP2_HoldInfo.wepClass == "weapon_portalgun" then
					ent.GP2_HoldInfo.holdingPlayer:PickupObject(newEnt);
				elseif ent.GP2_HoldInfo.wepClass == "weapon_physgun" then
					if ent.GP2_HoldInfo.grabEnt and ent.GP2_HoldInfo.grabEnt.GrabEnt then
						ent.GP2_HoldInfo.grabEnt:GrabEnt(newEnt);
					end;
				else
					ent.GP2_HoldInfo.holdingPlayer:PickupObject(newEnt);
				end;
				newEnt:SetOwner(NULL);
			end;
		end);
	elseif IsValid(newEnt) then
		newEnt:SetOwner(NULL);
	end;
	newEnt:SetModel(savedModel);
	ent:Remove();
	if IsValid(clone) then
		print("Removing clone entity...");
		clone:Remove();
	end;
end;
local GP2_CloneCheckCache = {};
local GP2_LastCloneCheck = 0;
local GP2_CloneCheckInterval = 0.1;
function ENT:Think()
	self:NextThink(CurTime() + 0.1);
	if SERVER then
		if not self:GetPlacedByMap() then
			local linked = self:GetLinkedPartner();
			OrangeOrBlue = linked.GetType and linked:GetType() or nil;
			for _, ent in ipairs(ents.GetAll()) do
				if ent.isClone and ent.daddyEnt and IsValid(ent.daddyEnt) then
					local daddyEnt = ent.daddyEnt;
					local dist, dist2;
					if IsValid(linked) then
						dist = (daddyEnt:GetPos()):Distance(linked:GetPos());
					else
						dist = math.huge;
					end;
					dist2 = (daddyEnt:GetPos()):Distance(self:GetPos());
					if dist > 40 and dist2 > 40 then
						local holdeur = nil;
						for _, ply in ipairs(player.GetAll()) do
							local wep = ply:GetActiveWeapon();
							if IsValid(wep) then
								local wepClass = wep:GetClass();
								if wepClass == "weapon_portalgun" then
									local entityInUse = wep.GetEntityInUse and wep:GetEntityInUse();
									if IsValid(entityInUse) and entityInUse == daddyEnt then
										holdeur = ply;
										break;
									end;
								elseif wepClass == "weapon_physgun" or wepClass == "gmod_tool" then
									if wep.GrabEnt and wep.GrabEnt == daddyEnt then
										holdeur = ply;
										break;
									end;
								end;
							end;
							if ply.holding and ply.holding == daddyEnt then
								holdeur = ply;
								break;
							end;
							if IsValid(ent) then
								SafeRemoveEntity(ent);
							end;
						end;
						local owner_portalgun = nil;
						for _, ply in ipairs(player.GetAll()) do
							local wep = ply:GetActiveWeapon();
							if IsValid(wep) and wep:GetClass() == "weapon_portalgun" then
								owner_portalgun = ply;
								break;
							end;
						end;
						self:PromoteCloneToReal(daddyEnt, ent, owner_portalgun);
					elseif dist < 40 or dist2 < 40 then
						daddyEnt:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR);
					end;
				end;
				if ent.LastPortalIntangibleTime and (not ent.InPortal) then
					local timeSinceLast = CurTime() - ent.LastPortalIntangibleTime;
					if timeSinceLast > 5 and ent:GetCollisionGroup() ~= COLLISION_GROUP_PASSABLE_DOOR then
						ent.OriginalCollisionGroup = nil;
						ent.LastPortalIntangibleTime = nil;
					end;
				end;
			end;
			if IsValid(linked) then
				local portalMins, portalMaxs = linked:OBBMins(), linked:OBBMaxs();
				local props = ents.FindInBox(linked:LocalToWorld(portalMins), linked:LocalToWorld(portalMaxs));
				for _, ent in ipairs(props) do
					if IsValid(ent) and ent:GetClass() == "prop_physics" then
						local phys = ent:GetPhysicsObject();
						if IsValid(phys) and (phys:GetVelocity()):Length() < 5 then
							if linked:CanPort(ent) and linked:IsLinked() and linked:GetActivated() then
								if not ent.InPortal then
									linked:StartTouch(ent);
								end;
								phys:EnableMotion(true);
								phys:SetVelocity(linked:GetUp() * (-40));
							end;
						end;
					end;
				end;
			end;
			local currentTime = CurTime();
			if currentTime - GP2_LastCloneCheck >= GP2_CloneCheckInterval then
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
			end;
		end;
	end;
	self:NextThink(CurTime() + 0.1);
	return true;
end;
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
	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then
		local mass = phys:GetMass();
		if mass and mass < 50 then
			ent.CanBeHeld = true;
		else
			ent.CanBeHeld = false;
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
function ENT:IsHorizontal()
	return (self:GetAngles()).p == 0;
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
concommand.Add("getblueinfo", function(ply)
	for _, ent in ipairs(ents.FindByClass("prop_portal")) do
		local portalType = ent.GetType and ent:GetType() or ent.PortalType or nil;
		if portalType == 0 then
			local pos = ent:GetPos();
			local ang = ent:GetAngles();
			ply:ChatPrint("Blue Portal - Pos: " .. tostring(pos) .. " Ang: " .. tostring(ang));
		end;
	end;
end);
concommand.Add("getorangeinfo", function(ply)
	for _, ent in ipairs(ents.FindByClass("prop_portal")) do
		local portalType = ent.GetType and ent:GetType() or ent.PortalType or nil;
		if portalType == 1 then
			local pos = ent:GetPos();
			local ang = ent:GetAngles();
			ply:ChatPrint("Orange Portal - Pos: " .. tostring(pos) .. " Ang: " .. tostring(ang));
		end;
	end;
end);
concommand.Add("getmapname", function(ply)
	local mapName = game.GetMap();
	ply:ChatPrint("Map Name: " .. tostring(mapName));
end);
