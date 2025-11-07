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
	local exitSegments, _ = self:CalculatePortalExitSegments(tr.HitPos, attachForward);
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
	local parentLaser = self:GetParentLaser();
	local parent = self:GetParent();
	if IsValid(parentLaser) or IsValid(parent) then
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
		local hitClass = hitEntity:GetClass();
		if PROP_WEIGHTED_CUBE_CLASS[hitClass] and PROP_WEIGHTED_CUBE_TYPE[hitEntity:GetCubeType()] then
			self:ReflectLaserForEntity(hitEntity);
			local childLaser = hitEntity:GetChildLaser();
		end;
		if TURRET_CLASS[hitClass] and (not hitEntity:IsOnFire()) then
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
			   -- Raycast pour le laser cloné
			   local startPos = reflector:GetPos();
			   local dir = reflector:GetAngles():Forward();
			   local tr = util.TraceLine({
				   start = startPos,
				   endpos = startPos + dir * 3,
				   filter = {reflector, laser},
				   mask = MASK_OPAQUE_AND_NPCS
			   });
			   laser:SetHitPos(tr.HitPos);
			   laser:SetHitNormal(tr.HitNormal);
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
	local sv_collide = sv_player_collide_with_laser:GetBool();
	for i = 1, #rayInfo do
		local target = rayInfo[i];
		if not IsValid(target) then
			continue;
		end;
		local isPlayer = target:IsPlayer();
		if isPlayer and (not sv_collide) then
			continue;
		end;
		local targetClass = target:GetClass();
		if not (isPlayer or target:IsNPC() or target:IsNextBot() or DAMAGABLE_ENTS[targetClass]) then
			continue;
		end;
		if DAMAGABLE_ENTS[targetClass] then
			self:SetShouldSpark(false);
		end;
		if NOT_DAMAGABLE_ENTS[targetClass] then
			continue;
		end;
		if isPlayer and (not target:Alive()) then
			continue;
		end;
		if isPlayer and target:GetMoveType() == MOVETYPE_NOCLIP then
			continue;
		end;
		if isPlayer and (not target:IsOnGround()) then
			continue;
		end;
		if target.PORTAL_TELEPORTING then
			continue;
		end;
		local damageInfo = DamageInfo();
		damageInfo:SetAttacker(self);
		if LASER_TARGET_CLASS[targetClass] then
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
	if recursionDepth >= 3 then
		return {}, nil;
	end;
	local exitSegments = {};
	startPos = startPos or self:GetPos();
	local rayEnd = startPos + direction * MAX_RAY_LENGTH;
	local extents = Vector(10, 10, 10);
	local rayHits = ents.FindAlongRay(startPos, rayEnd, -extents, extents);
	local laserOrigin = self:GetPos();
	if not self:GetNoModel() and self.LaserAttachment ~= (-1) then
		local attach = self:GetAttachment(self.LaserAttachment);
		if attach then
			laserOrigin = attach.Pos;
		end;
	end;
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
			if collisionPos and entryPortal:GetPos() then
				local distToPortal = (collisionPos - entryPortal:GetPos()):Length();
				if distToPortal > 50 then
					break;
				end;
			end;
			local entryPos = entryPortal:GetPos();
			local exitPos = exitPortal:GetPos();
			local exitAng = exitPortal:GetAngles();
			local entryAng = entryPortal:GetAngles();
			diffAngleP = exitAng.p - entryAng.p;
			diffAngleY = exitAng.y - entryAng.y;
			diffAngleR = exitAng.r - entryAng.r;
			// print("Différence d'angle Y:", diffAngleY);
			// print("Différence d'angle P:", diffAngleP);
			// print("Différence d'angle R:", diffAngleR);
			local portalNormal = exitPortal:GetForward();
			local laserToEntry = laserOrigin - entryPortal:GetPos();
			local mirroredOffset = laserToEntry - 2 * laserToEntry:Dot(portalNormal) * portalNormal;
			local deltaPos = entryPos - laserOrigin;
			local deltaAng = direction:Angle();
			local deltaX, deltaY, deltaZ = deltaPos.x, deltaPos.y, deltaPos.z;
			local deltaY2, deltaP, deltaR = deltaAng.y, deltaAng.p, deltaAng.r;
			for i = 1, 100 do
				print(" ");
			end;
			print("Delta X:", deltaX);
			print("Delta Y:", deltaY);
			print("Delta Z:", deltaZ);
			print("Delta Yaw:", deltaY2);
			print("Delta Pitch:", deltaP);
			print("Delta Roll:", deltaR);
			local newAng = Angle(deltaP, deltaY2 + 180, deltaR);
			newAng:RotateAroundAxis(Vector(0, 0, 1), diffAngleY);
			local forward = newAng:Forward() * 0;
			local right = newAng:Right() * 0;
			local up = newAng:Up() * 0;
			local sphereRadius = 70;
			local newPos = exitPos + Vector(deltaX, deltaY, deltaZ) + forward + right + up;
			local distanceToExitPortal = (newPos - exitPos):Length();
			if distanceToExitPortal >= sphereRadius and diffAngleP == 0 then
				local absDiffY = math.abs(diffAngleY);
				if absDiffY < 2 then
					newPos = exitPos + Vector(deltaX, deltaY, (-deltaZ)) + newAng:Forward() * (distanceToExitPortal - 20);
				elseif math.abs(diffAngleY - 180) < 2 then
					newPos = exitPos + Vector((-deltaX), (-deltaY), (-deltaZ)) - newAng:Forward() * (distanceToExitPortal + 30);
				elseif math.abs(diffAngleY - 90) < 2 then
					newPos = exitPos + Vector((-deltaY), deltaX, (-deltaZ)) + newAng:Forward() * (distanceToExitPortal - 20);
				elseif math.abs(diffAngleY + 90) < 2 then
					newPos = exitPos + Vector(deltaY, (-deltaX), (-deltaZ)) + newAng:Forward() * (distanceToExitPortal - 20);
				end;
			end;
			if diffAngleP ~= 0 then

				local entryToOrigin = laserOrigin - entryPos
				local localOffset = Vector(entryToOrigin:Dot(entryPortal:GetRight()), entryToOrigin:Dot(entryPortal:GetUp()), entryToOrigin:Dot(entryPortal:GetForward()))
				local targetPos = exitPos - localOffset.x * exitPortal:GetRight() - localOffset.y * exitPortal:GetUp() + localOffset.z * exitPortal:GetForward()
				local localAng = entryPortal:WorldToLocalAngles(direction:Angle())
				local targetAng = exitPortal:LocalToWorldAngles(-localAng)
				newPos = targetPos
				newAng = targetAng
				newPos = newPos + newAng:Forward() * (distanceToExitPortal - 20)
			end;
			local origAng = self:GetAngles();
			local mirroredDir = direction - 2 * direction:Dot(portalNormal) * portalNormal;
			mirroredDir = -mirroredDir;
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
	return exitSegments;
end;
local lasers = ents.FindByClass("env_portal_laser");
local count = #lasers;
print("Nombre de lasers sur la map :", count);
