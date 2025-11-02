include("shared.lua");
local LASER_MODEL = "models/props/laser_emitter.mdl";
local MAX_RAY_LENGTH = 2 ^ 16;
local portal_laser_perf_debug = CreateConVar("gp2_portal_laser_perf_debug", "0", FCVAR_CHEAT, "Debug perf timings for portal laser", 0, 1);
local portal_laser_normal_update = CreateConVar("gp2_portal_laser_normal_update", "0.05", FCVAR_REPLICATED);
local portal_laser_high_precision_update = CreateConVar("gp2_portal_laser_high_precision_update", "0.001", FCVAR_REPLICATED);
local sv_player_collide_with_laser = CreateConVar("gp2_sv_player_collide_with_laser", "1", FCVAR_NOTIFY + FCVAR_CHEAT);
local clamp = math.Clamp;
local util_TraceLine = util.TraceLine;
local ents_FindAlongRay = ents.FindAlongRay;
local CalcClosestPointOnLineSegment = function(pos, start, endpos)
	if GP2 and GP2.Utils and GP2.Utils.CalcClosestPointOnLineSegment then
		return GP2.Utils.CalcClosestPointOnLineSegment(pos, start, endpos);
	else
		local dir = (endpos - start):GetNormalized();
		local projection = (pos - start):Dot(dir);
		projection = math.max(0, math.min(projection, start:Distance(endpos)));
		return start + dir * projection;
	end;
end;
local EmitSoundAtClosestPoint = function(...)
	if GP2 and GP2.Utils and GP2.Utils.EmitSoundAtClosestPoint then
		return GP2.Utils.EmitSoundAtClosestPoint(...);
	else
		return false;
	end;
end;
local PROP_WEIGHTED_CUBE_CLASS = {
	prop_weighted_cube = true
};
local PROP_WEIGHTED_CUBE_TYPE = {
	[2] = true
};
local LASER_TARGET_CLASS = {
	point_laser_target = true
};
local RAY_EXTENTS = Vector(10, 10, 10);
local RAY_EXTENTS_NEG = -RAY_EXTENTS;
local DAMAGABLE_ENTS = {
	point_laser_target = true
};
local NOT_DAMAGABLE_ENTS = {
	npc_security_camera = true
};
local TURRET_CLASS = {
	npc_portal_turret_floor = true
};
function ENT:KeyValue(k, v)
	if k == "StartState" then
		self:SetState(not tobool(v));
	elseif k == "LethalDamage" then
		self:SetLethalDamage(tobool(v));
	elseif k == "AutoAimEnabled" then
		self:SetAutoAim(tobool(v));
	elseif k == "model" then
		self.ModelName = v;
	elseif k == "skin" then
		self:SetSkin(tonumber(v));
	end;
	if k:StartsWith("On") then
		self:StoreOutput(k, v);
	end;
end;
function ENT:AcceptInput(name, activator, caller, value)
	name = name:lower();
	if name == "turnon" then
		self:SetState(true);
	elseif name == "turnoff" then
		self:SetState(false);
	elseif name == "toggle" then
		self:SetState(not self:GetState());
	end;
end;
function ENT:Initialize()
	if not self:GetNoModel() then
		self:SetModel(self.ModelName or LASER_MODEL);
		self.LaserAttachment = self.LaserAttachment or self:LookupAttachment("laser_attachment");
		self:PhysicsInitStatic(MOVETYPE_VPHYSICS);
	end;
	self:NextThink(CurTime());
end;
ENT.LastLaserUpdate = 0;
ENT.LaserUpdateInterval = 0.1;
ENT.CachedLaserData = nil;
function ENT:Think()
	local curTime = CurTime();
	if curTime - self.LastLaserUpdate < self.LaserUpdateInterval then
		self:NextThink(curTime + self.LaserUpdateInterval);
		return true;
	end;
	local time = os.clock();
	if not self.CachedLaserData or curTime - self.LastLaserUpdate > 0.5 then
		self:FireLaser();
		self.LastLaserUpdate = curTime;
	end;
	if portal_laser_perf_debug:GetBool() then
		GP2.Print("EnvPortalLaser :: Think - execution time: %.6f seconds", os.clock() - time);
	end;
	local interval = IsValid(self:GetParentLaser()) and 0.05 or 0.1;
	self:NextThink(curTime + interval);
	return true;
end;
function ENT:RecursionLaserThroughPortals(data, recursionDepth, visitedPortals, laserSegments)
	recursionDepth = recursionDepth or 0;
	visitedPortals = visitedPortals or {};
	laserSegments = laserSegments or {};
	if recursionDepth >= 10 then
		return {
			HitPos = data.endpos,
			Entity = NULL,
			Fraction = 1
		}, laserSegments;
	end;
	local rayStart = data.start;
	local rayEnd = data.endpos;
	local foundPortalEntity = nil;
	local portalHitPos = nil;
	local rayHits = ents.FindAlongRay(rayStart, rayEnd, RAY_EXTENTS_NEG, RAY_EXTENTS);
	if PortalManager and PortalManager.Portals then
		for portal in pairs(PortalManager.Portals) do
			if IsValid(portal) and portal:GetActivated() then
				local portalPos = portal:GetPos();
				local rayDir = (rayEnd - rayStart):GetNormalized();
				local toPortal = portalPos - rayStart;
				local projDist = toPortal:Dot(rayDir);
				if projDist > 0 and projDist < (rayEnd - rayStart):Length() then
					local projPoint = rayStart + rayDir * projDist;
					local distToRay = (portalPos - projPoint):Length();
					if distToRay < 32 then
						foundPortalEntity = portal;
						portalHitPos = projPoint;
						break;
					end;
				end;
			end;
		end;
	end;
	for _, ent in ipairs(rayHits) do
		if IsValid(ent) and ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
			local portalId = ent:EntIndex();
			if not visitedPortals[portalId] then
				foundPortalEntity = ent;
				visitedPortals[portalId] = true;
				local mins, maxs = ent:GetCollisionBounds();
				if not mins or (not maxs) then
					mins, maxs = Vector(-34, -34, -1), Vector(34, 34, 1);
				end;
				portalHitPos = util.IntersectRayWithOBB(rayStart, (rayEnd - rayStart):GetNormalized(), ent:GetPos(), ent:GetAngles(), mins, maxs);
				if not portalHitPos then
					local tr = util.TraceLine({
						start = rayStart,
						endpos = rayEnd,
						filter = {
							self,
							ent
						},
						mask = MASK_OPAQUE_AND_NPCS
					});
					if tr.Hit and tr.Entity == ent then
						portalHitPos = tr.HitPos;
					else
						break;
					end;
				end;
				break;
			end;
		end;
	end;
	local tr = util_TraceLine(data);
	local actualEndPos = tr.HitPos;
	local hitPortal = nil;
	if IsValid(tr.Entity) and tr.Entity:GetClass() ~= "prop_portal" then
		local segmentData = {
			start = data.start,
			endpos = actualEndPos,
			hitsPortal = false,
			canReachPortal = false
		};
		table.insert(laserSegments, segmentData);
		return tr, laserSegments;
	end;
	if foundPortalEntity and portalHitPos then
		local distanceToPortal = (portalHitPos - rayStart):Length();
		local distanceToHit = (tr.HitPos - rayStart):Length();
		local canReachPortal = true;
		local traceToPortal = util.TraceLine({
			start = rayStart,
			endpos = portalHitPos,
			filter = data.filter or self,
			mask = MASK_OPAQUE_AND_NPCS
		});
		if traceToPortal.Hit and traceToPortal.Entity ~= foundPortalEntity then
			canReachPortal = false;
			if portal_laser_perf_debug:GetBool() then
				GP2.Print("Laser bloqué vers portail par: %s à distance %f", tostring(traceToPortal.Entity), traceToPortal.Fraction * distanceToPortal);
			end;
		end;
		if canReachPortal and distanceToPortal < distanceToHit and distanceToPortal > 50 then
			actualEndPos = portalHitPos;
			hitPortal = foundPortalEntity;
		end;
	end;
	local segmentData = {
		start = data.start,
		endpos = actualEndPos
	};
	if hitPortal then
		segmentData.hitsPortal = true;
		segmentData.canReachPortal = true;
	else
		segmentData.hitsPortal = false;
		segmentData.canReachPortal = false;
	end;
	table.insert(laserSegments, segmentData);
	if not hitPortal then
		return tr, laserSegments;
	end;
	local linkedPortal = hitPortal:GetLinkedPartner();
	local newData = table.Copy(data);
	local rayDirection = (rayEnd - rayStart):GetNormalized();
	local newPos, newAng = self:TransformPortal(hitPortal, linkedPortal, actualEndPos, rayDirection:Angle());
	newAng = Angle(newAng.p, newAng.y + 180, newAng.r);
	local exitPortalPitch = (linkedPortal:GetAngles()).p;
	if math.abs(exitPortalPitch - 90) < 10 then
		newAng = Angle(-newAng.p, newAng.y, newAng.r);
	elseif math.abs(exitPortalPitch - 270) < 10 then
		newAng = Angle(-newAng.p, newAng.y, newAng.r);
	end;
	local rayLength = (rayEnd - rayStart):Length();
	local usedLength = (actualEndPos - rayStart):Length();
	local remainingLength = math.max(rayLength - usedLength, 100);
	newPos = newPos + newAng:Forward() * 0;
	table.insert(laserSegments, {
		start = linkedPortal:GetPos(),
		endpos = newPos,
		hitsPortal = false,
		canReachPortal = false
	});
	newData.start = newPos;
	newData.endpos = newPos + newAng:Forward() * remainingLength;
	if istable(data.filter) then
		local newFilter = table.Copy(data.filter);
		table.insert(newFilter, linkedPortal);
		table.insert(newFilter, hitPortal);
		newData.filter = newFilter;
	else
		newData.filter = {
			data.filter,
			linkedPortal,
			hitPortal
		};
	end;
	return self:RecursionLaserThroughPortals(newData, recursionDepth + 1, visitedPortals, laserSegments);
end;
local function GetPortalCardinalDirection(portal)
	if not IsValid(portal) then
		return "unknown";
	end;
	local yaw = (portal:GetAngles()).y;
	local roll = (portal:GetAngles()).r;
	while yaw < 0 do
		yaw = yaw + 360;
	end;
	while yaw >= 360 do
		yaw = yaw - 360;
	end;
	if roll == 180 then
		return "floor";
	elseif yaw >= 350 or yaw <= 10 then
		return "north";
	elseif yaw >= 80 and yaw <= 100 then
		return "east";
	elseif yaw >= 170 and yaw <= 190 then
		return "south";
	elseif yaw >= 260 and yaw <= 280 then
		return "west";
	else
		return "ceiling";
	end;
end;
local PORTAL_TRANSITION_OFFSETS = {
	north_to_floor = {
		pos = Vector(0, -40, 0),
		ang = Angle(90, 0, 0)
	},
	north_to_ceiling = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	south_to_floor = {
		pos = Vector(0, 40, 0),
		ang = Angle(90, 0, 0)
	},
	south_to_ceiling = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	east_to_floor = {
		pos = Vector(-40, 0, 0),
		ang = Angle(90, 0, 0)
	},
	east_to_ceiling = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	west_to_floor = {
		pos = Vector(40, 0, 0),
		ang = Angle(90, 0, 0)
	},
	west_to_ceiling = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	ceiling_to_ceiling = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	ceiling_to_floor = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	ceiling_to_north = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	ceiling_to_south = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	ceiling_to_east = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	ceiling_to_west = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 0)
	},
	floor_to_ceiling = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	floor_to_floor = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	north_to_south = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 180, 0)
	},
	north_to_east = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 0, 180)
	},
	north_to_west = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, -90, 0)
	},
	north_to_north = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	east_to_west = {
		pos = Vector(-3, 0, 0),
		ang = Angle(90, 180, 0)
	},
	east_to_south = {
		pos = Vector(-5, 0, 0),
		ang = Angle(0, 90, 0)
	},
	east_to_north = {
		pos = Vector(-3, 0, 0),
		ang = Angle(0, -90, 0)
	},
	east_to_east = {
		pos = Vector(-3, 0, 0),
		ang = Angle(90, 0, 0)
	},
	south_to_north = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 180, 0)
	},
	south_to_west = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, 90, 0)
	},
	south_to_east = {
		pos = Vector(0, 0, 0),
		ang = Angle(90, -90, 0)
	},
	south_to_south = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	west_to_east = {
		pos = Vector(3, 0, 0),
		ang = Angle(90, 180, 0)
	},
	west_to_north = {
		pos = Vector(3, -5, 0),
		ang = Angle(0, 90, 0)
	},
	west_to_south = {
		pos = Vector(3, -5, 0),
		ang = Angle(0, -90, 0)
	},
	west_to_west = {
		pos = Vector(3, 0, 0),
		ang = Angle(90, 0, 0)
	},
	default = {
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	}
};
local function GetPortalTransitionOffsets(entryDir, exitDir)
	local transitionKey = entryDir .. "_to_" .. exitDir;
	return PORTAL_TRANSITION_OFFSETS[transitionKey] or PORTAL_TRANSITION_OFFSETS.default;
end;
function ENT:TransformPortal(entryPortal, exitPortal, hitPos, hitAng)
	if not IsValid(entryPortal) or (not IsValid(exitPortal)) then
		return hitPos, hitAng;
	end;
	local entryDir = GetPortalCardinalDirection(entryPortal);
	local exitDir = GetPortalCardinalDirection(exitPortal);
	local transitionOffsets = GetPortalTransitionOffsets(entryDir, exitDir);
	print("entryPortal direction: ", entryDir, "exitPortal direction: ", exitDir);
	print("Transition offsetss - pos:", transitionOffsets.pos, "ang:", transitionOffsets.ang);
	local hitOffset = hitPos - entryPortal:GetPos();
	local localOffset = Vector(hitOffset:Dot(entryPortal:GetRight()), hitOffset:Dot(entryPortal:GetUp()), hitOffset:Dot(entryPortal:GetForward()));
	localOffset.x = -localOffset.x;
	local newPos = exitPortal:GetPos() + localOffset.x * exitPortal:GetRight() + localOffset.y * exitPortal:GetUp() + localOffset.z * exitPortal:GetForward();
	newPos = newPos + transitionOffsets.pos.x * exitPortal:GetRight() + transitionOffsets.pos.y * exitPortal:GetUp() + transitionOffsets.pos.z * exitPortal:GetForward();
	local localAng = entryPortal:WorldToLocalAngles(hitAng);
	localAng.y = -localAng.y;
	localAng.r = -localAng.r;
	local newAng = exitPortal:LocalToWorldAngles(localAng);
	newAng = newAng + transitionOffsets.ang;
	return newPos, newAng;
end;
function ENT:FireLaser()
	if not self:GetState() then
		return;
	end;
	if not self:GetNoModel() and self.LaserAttachment == (-1) then
		GP2.Error("EnvPortalLaser :: FireLaser - env_portal_laser[%i] with model %q don't have \"laser_attachment\"", self:EntIndex(), self:GetModel());
		return;
	end;
	local attachPos;
	local attachAng;
	local attachForward;
	if self:GetNoModel() then
		attachPos = self:GetPos();
		attachAng = self:GetAngles();
	else
		local attach = self:GetAttachment(self.LaserAttachment);
		attachPos = attach.Pos;
		attachAng = attach.Ang;
	end;
	attachForward = attachAng:Forward();
	local tr, laserSegments = self:RecursionLaserThroughPortals({
		start = attachPos,
		endpos = attachPos + attachForward * MAX_RAY_LENGTH,
		filter = {
			self,
			"projected_wall_entity",
			"player",
			"point_laser_target",
			"prop_laser_catcher",
			"prop_laser_relay",
			"prop_portal",
			self:GetParent()
		},
		mask = MASK_OPAQUE_AND_NPCS
	});
	self.LaserSegments = laserSegments or {};
	local exitSegments, entryHitWithOffset = self:CalculatePortalExitSegments(tr.HitPos, attachForward);
	local allSegments = {};
	if #self.LaserSegments > 0 then
		local mainSegment = self.LaserSegments[1];
		table.insert(allSegments, mainSegment);
	else
		table.insert(allSegments, {
			start = attachPos,
			endpos = tr.HitPos,
			hitsPortal = false,
			canReachPortal = false
		});
	end;
	for _, segment in ipairs(exitSegments) do
		table.insert(allSegments, segment);
	end;
	local function SendSegments()
		if not IsValid(self) then
			return;
		end;
		net.Start("LaserSegments");
		net.WriteEntity(self);
		net.WriteUInt(#allSegments, 8);
		for _, segment in ipairs(allSegments) do
			net.WriteVector(segment.start);
			net.WriteVector(segment.endpos);
			net.WriteBool(segment.hitsPortal or false);
			net.WriteBool(segment.canReachPortal or false);
		end;
		net.Broadcast();
	end;
	if IsValid(self:GetParentLaser()) or IsValid(self:GetParent()) then
		timer.Simple(0.05, SendSegments);
	else
		SendSegments();
	end;
	for _, segment in ipairs(allSegments) do
		self:DamageEntsAlongTheRay(segment.start, segment.endpos);
	end;
	local hitEntity = tr.Entity;
	self:SetReflector(hitEntity);
	self:SetHitPos(tr.HitPos);
	self:SetHitNormal(tr.HitNormal);
	if IsValid(hitEntity) then
		if PROP_WEIGHTED_CUBE_CLASS[hitEntity:GetClass()] and PROP_WEIGHTED_CUBE_TYPE[hitEntity:GetCubeType()] then
			self:ReflectLaserForEntity(hitEntity);
			local childLaser = hitEntity:GetChildLaser();
			if IsValid(childLaser) and childLaser.CanReflect then
				childLaser:FireLaser();
			end;
		elseif TURRET_CLASS[hitEntity:GetClass()] and (not hitEntity:IsOnFire()) then
			hitEntity:Ignite(5);
		end;
		self:SetShouldSpark(false);
	else
		self:SetShouldSpark(true);
	end;
	if SERVER then
		if self.PortalType then
			RemoveNonPlayerPortalsOfType(self.PortalType);
		end;
	end;
end;
function ENT:ReflectLaserForEntity(reflector)
	if not IsValid(reflector:GetChildLaser()) then
		local laser = ents.Create(self:GetClass());
		if IsValid(laser) then
			laser:SetNoModel(true);
			laser:SetPos(reflector:GetPos());
			laser:SetAngles(reflector:GetAngles());
			laser:SetParent(reflector);
			laser:Spawn();
			laser:AddEffects(EF_NODRAW + EF_NOSHADOW);
			reflector:SetChildLaser(laser);
			laser:SetParentLaser(self);
			self:SetChildLaser(laser);
			laser:SetTransmitWithParent(true);
			laser:SetState(self:GetState());
		end;
	else
		local childLaser = reflector:GetChildLaser();
		if IsValid(childLaser) then
			childLaser:SetState(self:GetState());
		end;
	end;
	local childLaser = reflector:GetChildLaser();
	if IsValid(childLaser) then
		childLaser:FireLaser();
	end;
end;
local function PushPlayerAwayFromLine(player, player, endPos, baseForce)
	if not sv_player_collide_with_laser:GetBool() then
		return;
	end;
	if not IsValid(player) or (not player:IsPlayer()) or player:GetMoveType() == MOVETYPE_NOCLIP then
		return;
	end;
	if not player:IsOnGround() then
		return;
	end;
	if player.PORTAL_TELEPORTING then
		return;
	end;
	local playerPos = player:GetPos();
	local nearestPoint = CalcClosestPointOnLineSegment(playerPos, startPos, endPos);
	local pushDirection = (playerPos - nearestPoint):GetNormalized();
	pushDirection.z = 0;
	local playerVelocity = (player:GetVelocity()):Length();
	if not player:Crouching() then
		baseForce = baseForce * (playerVelocity / 100);
	end;
	local clampedForce = clamp(baseForce, 400, 1000);
	if player:Crouching() then
		clampedForce = clampedForce * 2;
	end;
	local pushVelocity = pushDirection * clampedForce;
	player:SetGroundEntity(NULL);
	player:SetVelocity(pushVelocity);
end;
function ENT:DamageEntsAlongTheRay(startPos, endPos)
	local rayInfo = ents_FindAlongRay(startPos, endPos, RAY_EXTENTS_NEG, RAY_EXTENTS);
	for i = 1, #rayInfo do
		local target = rayInfo[i];
		if target:IsPlayer() and (not sv_player_collide_with_laser:GetBool()) then
			continue;
		end;
		if not IsValid(target) then
			continue;
		end;
		if not (target:IsPlayer() or target:IsNPC() or target:IsNextBot() or DAMAGABLE_ENTS[target:GetClass()]) then
			continue;
		end;
		if DAMAGABLE_ENTS[target:GetClass()] then
			self:SetShouldSpark(false);
		end;
		if NOT_DAMAGABLE_ENTS[target:GetClass()] then
			continue;
		end;
		if target:IsPlayer() and (not target:Alive()) then
			continue;
		end;
		if target:IsPlayer() and target:GetMoveType() == MOVETYPE_NOCLIP then
			continue;
		end;
		if target:IsPlayer() and (not target:IsOnGround()) then
			continue;
		end;
		if target.PORTAL_TELEPORTING then
			continue;
		end;
		local damageInfo = DamageInfo();
		damageInfo:SetAttacker(self);
		if LASER_TARGET_CLASS[target:GetClass()] then
			damageInfo:SetDamage(1);
		else
			damageInfo:SetDamage(8);
		end;
		target:TakeDamageInfo(damageInfo);
		PushPlayerAwayFromLine(target, startPos, endPos, 400);
		EmitSoundAtClosestPoint(target, startPos, endPos, "Flesh.BulletImpact");
		EmitSoundAtClosestPoint(target, startPos, endPos, "Player.FallDamage");
	end;
end;
function ENT:OnStateChange(name, old, new)
	local child = self:GetChildLaser();
	if IsValid(child) then
		child:SetState(new);
	end;
end;
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;
function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then
		return;
	end;
	local SpawnPos = tr.HitPos + tr.HitNormal * 10;
	local SpawnAng = ply:EyeAngles();
	SpawnAng.p = 0;
	local ent = ents.Create(ClassName);
	ent:SetPos(SpawnPos);
	ent:SetAngles(SpawnAng);
	ent:Spawn();
	ent:Activate();
	return ent;
end;
function ENT:CalculatePortalExitSegments(startPos, direction, collisionPos, recursionDepth, visitedPortals)
	recursionDepth = recursionDepth or 0;
	visitedPortals = visitedPortals or {};
	if recursionDepth >= 10 then
		return {}, nil;
	end;
	local exitSegments = {};
	local entryHitPosWithOffset = nil;
	startPos = startPos or self:GetPos();
	local rayEnd = startPos + direction * MAX_RAY_LENGTH;
	local extents = Vector(10, 10, 10);
	local rayHits = ents.FindAlongRay(startPos, rayEnd, -extents, extents);
	for _, ent in ipairs(rayHits) do
		if IsValid(ent) and ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
			local portalId = ent:EntIndex();
			if visitedPortals[portalId] then
				continue;
			end;
			visitedPortals[portalId] = true;
			local entryPortal = ent;
			local exitPortal = entryPortal:GetLinkedPartner();
			local mins, maxs = entryPortal:GetCollisionBounds();
			if not mins or (not maxs) then
				mins, maxs = Vector(-34, -34, -1), Vector(34, 34, 1);
			end;
			local hitPos = util.IntersectRayWithOBB(startPos, direction, entryPortal:GetPos(), entryPortal:GetAngles(), mins, maxs);
			if not hitPos then
				hitPos = entryPortal:GetPos();
			end;
			local portalZ = (entryPortal:GetPos()).z;
			local offsetZ = portalZ - startPos.z;
			local entryRight = entryPortal:GetRight();
			local offsetVec = startPos - entryPortal:GetPos();
			local offsetXLocal = offsetVec:Dot(entryRight);
			if collisionPos and entryPortal:GetPos() then
				local distToPortal = (collisionPos - entryPortal:GetPos()):Length();
				if distToPortal > 50 then
					break;
				end;
			end;
			local modifiedHitPos = Vector(hitPos.x - 6, hitPos.y - 0.1, hitPos.z - 0.1);
			local newPos, newAng = self:TransformPortal(entryPortal, exitPortal, modifiedHitPos, direction:Angle());
			if portal_laser_perf_debug:GetBool() then
				print(string.format("Laser Position Debug: newPos avant offsets = (%.2f, %.2f, %.2f)", newPos.x, newPos.y, newPos.z));
			end;
			newAng = Angle(newAng.p + 180, -newAng.y, newAng.r);
			local exitPortalPitch = (exitPortal:GetAngles()).p;
			if math.abs(exitPortalPitch - 90) < 10 then
				newAng = Angle(-newAng.p, newAng.y, newAng.r);
			elseif math.abs(exitPortalPitch - 270) < 10 then
				newAng = Angle(-newAng.p, newAng.y, newAng.r);
			end;
			local entryDir = GetPortalCardinalDirection(entryPortal);
			local exitDir = GetPortalCardinalDirection(exitPortal);
			local transitionOffsets = GetPortalTransitionOffsets(entryDir, exitDir);
			local exitPortalPitch = (exitPortal:GetAngles()).p;
			newPos = newPos + transitionOffsets.pos.x * exitPortal:GetRight() + transitionOffsets.pos.y * exitPortal:GetUp() + transitionOffsets.pos.z * exitPortal:GetForward();
			newAng = newAng + transitionOffsets.ang;
			newPos = newPos + exitPortal:GetRight() * (-offsetXLocal);
			entryDir = GetPortalCardinalDirection(entryPortal);
			exitDir = GetPortalCardinalDirection(exitPortal);
			print("Entry Direction: " .. entryDir .. ", Exit Direction: " .. exitDir);
			if exitDir == "ceiling" or exitDir == "floor" then
				newPos = newPos + exitPortal:GetForward() * (-offsetZ);
			end;
			if math.abs(exitPortalPitch - 90) < 10 then
				print("Applying ceiling portal offset Z");
				newPos = newPos - exitPortal:GetForward() * offsetZ;
			elseif math.abs(exitPortalPitch - 270) < 10 or math.abs(exitPortalPitch - 270) < 10 then
				print("Applying floor portal offset Z");
				newPos = newPos - exitPortal:GetUp() * offsetZ;
			else
				newPos.z = newPos.z - offsetZ;
			end;
			newAng = Angle(-newAng.p, newAng.y, newAng.r);
			if newAng.r > 80 and newAng.r < 100 then
				newPos = newPos - newAng:Forward() * 30;
				newPos = newPos - newAng:Forward() * offsetZ;
			end;
			if newAng.r < (-80) and newAng.r > (-100) then
				newPos = newPos - newAng:Forward() * 30;
				newPos = newPos - newAng:Up() * offsetZ;
			end;
			local entryHitWithOffset = Vector(hitPos.x, hitPos.y, hitPos.z);
			local entryPortalPitch = (entryPortal:GetAngles()).p;
			local entryTransitionOffsets = GetPortalTransitionOffsets(exitDir, entryDir);
			entryHitWithOffset = entryHitWithOffset + entryTransitionOffsets.pos.x * entryPortal:GetRight() + entryTransitionOffsets.pos.y * entryPortal:GetUp() + entryTransitionOffsets.pos.z * entryPortal:GetForward();
			entryHitWithOffset = entryHitWithOffset + entryPortal:GetRight() * (-offsetXLocal);
			if math.abs(entryPortalPitch - 90) < 10 then
				entryHitWithOffset = entryHitWithOffset + entryPortal:GetForward() * offsetZ;
			elseif math.abs(entryPortalPitch - 270) < 10 or math.abs(entryPortalPitch - 270) < 10 then
				entryHitWithOffset = entryHitWithOffset - entryPortal:GetForward() * offsetZ;
			else
				entryHitWithOffset.z = entryHitWithOffset.z - offsetZ;
			end;
			entryHitPosWithOffset = entryHitWithOffset;
			local exitTr = util.TraceLine({
				start = newPos,
				endpos = newPos + newAng:Forward() * MAX_RAY_LENGTH,
				filter = {
					self,
					exitPortal,
					entryPortal,
					"projected_wall_entity",
					"player",
					"point_laser_target",
					"prop_laser_catcher",
					"prop_laser_relay",
					self:GetParent()
				},
				mask = MASK_OPAQUE_AND_NPCS
			});
			table.insert(exitSegments, {
				start = newPos,
				endpos = exitTr.HitPos,
				hitsPortal = false,
				canReachPortal = false
			});
			local nextSegments, _ = self:CalculatePortalExitSegments(exitTr.HitPos, newAng:Forward(), exitTr.HitPos, recursionDepth + 1, visitedPortals);
			for _, segment in ipairs(nextSegments) do
				table.insert(exitSegments, segment);
			end;
			break;
		end;
	end;
	return exitSegments, entryHitPosWithOffset;
end;
