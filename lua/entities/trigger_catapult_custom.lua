ENT.Type = "brush";
local mats = {};
local sv_gravity = GetConVar("sv_gravity");
local SF_TRIGGER_ALLOW_CLIENTS = 1;
local SF_TRIGGER_ALLOW_NPCS = 2;
local SF_TRIGGER_ALLOW_PUSHABLES = 4;
local SF_TRIGGER_ALLOW_PHYSICS = 8;
local SF_TRIGGER_ONLY_PLAYER_ALLY_NPCS = 16;
local SF_TRIGGER_ONLY_CLIENTS_IN_VEHICLES = 32;
local SF_TRIGGER_ALLOW_ALL = 64;
local SF_TRIGGER_ONLY_CLIENTS_OUT_OF_VEHICLES = 512;
local SF_TRIGGER_ONLY_NPCS_IN_VEHICLES = 2048;
local SF_TRIGGER_DISALLOW_BOTS = 4096;
local pushable = {
	func_pushable = true
};
function ENT:KeyValue(k, v)
	if k == "playerSpeed" then
		self:SetPlayerSpeed(tonumber(v));
	elseif k == "physicsSpeed" then
		self:SetPhysicsSpeed(tonumber(v));
	elseif k == "useThresholdCheck" then
		self:SetUseThresholdCheck(tobool(v));
	elseif k == "entryAngleTolerance" then
		self:SetEntryAngleTolerance(tonumber(v));
	elseif k == "useExactVelocity" then
		self:SetUseExactVelocity(tobool(v));
	elseif k == "exactVelocityChoiceType" then
		self:SetUseExactVelocityMethod(tonumber(v));
	elseif k == "lowerThreshold" then
		self:SetLowerThreshold(tonumber(v));
	elseif k == "upperThreshold" then
		self:SetUpperThreshold(tonumber(v));
	elseif k == "launchDirection" then
		self:SetLaunchDirection(Angle(v));
	elseif k == "launchTarget" then
		self:SetLaunchTargetName(v);
	elseif k == "onlyVelocityCheck" then
		self:SetOnlyVelocityCheck(tobool(v));
	elseif k == "applyAngularImpulse" then
		self:SetApplyAngularImpulse(tobool(v));
	elseif k == "AirCtrlSupressionTime" then
		self:SetAirCtrlSupressionTime(tonumber(v));
	elseif k == "StartDisabled" then
		self:SetEnabled(not tobool(v));
	elseif k == "filtername" then
		self:SetFilterName(v);
	end;
	if k:StartsWith("On") then
		self:StoreOutput(k, v);
	end;
end;
function ENT:SetupDataTables()
	self:NetworkVar("Float", "PlayerSpeed");
	self:NetworkVar("Float", "PhysicsSpeed");
	self:NetworkVar("Float", "LowerThreshold");
	self:NetworkVar("Float", "UpperThreshold");
	self:NetworkVar("Float", "EntryAngleTolerance");
	self:NetworkVar("Float", "AirCtrlSupressionTime");
	self:NetworkVar("Angle", "LaunchDirection");
	self:NetworkVar("String", "LaunchTargetName");
	self:NetworkVar("String", "FilterName");
	self:NetworkVar("Entity", "LaunchTarget");
	self:NetworkVar("Bool", "UseThresholdCheck");
	self:NetworkVar("Bool", "UseExactVelocity");
	self:NetworkVar("Bool", "UseExactVelocityMethod");
	self:NetworkVar("Bool", "OnlyVelocityCheck");
	self:NetworkVar("Bool", "ApplyAngularImpulse");
	self:NetworkVar("Bool", "DirectionSuppressAirControl");
	self:NetworkVar("Bool", "Enabled");
	if SERVER then
		self:SetApplyAngularImpulse(true);
		self:SetAirCtrlSupressionTime(-1);
		self:SetLowerThreshold(0.15);
		self:SetLowerThreshold(0.3);
		self:SetPlayerSpeed(450);
		self:SetPhysicsSpeed(450);
		self:SetEnabled(true);
	end;
end;
function ENT:Initialize()
	self:SetTrigger(true);
	self.RefireDelay = {};
	self.AbortedLaunchees = {};
	self.Thinking = false;
	self:SetLaunchTarget((ents.FindByName(self:GetLaunchTargetName()))[1] or NULL);
	for i = 1, player.GetCount() + 1 do
		self.RefireDelay[i] = 0;
	end;
	self.LaunchedProps = {};
end;
function ENT:AcceptInput(name, activator, caller, data)
	name = name:lower();
	if name == "enable" then
		self:SetEnabled(true);
	elseif name == "disable" then
		self:SetEnabled(false);
	end;
end;
function ENT:PassesTriggerFilters(ent)
	if not self:GetEnabled() then
		return;
	end;
	if self:HasSpawnFlags(SF_TRIGGER_ALLOW_ALL) or self:HasSpawnFlags(SF_TRIGGER_ALLOW_CLIENTS) and ent:IsPlayer() or self:HasSpawnFlags(SF_TRIGGER_ALLOW_NPCS) and ent:IsNPC() or self:HasSpawnFlags(SF_TRIGGER_ALLOW_PUSHABLES) and ent:GetClass() == "func_pushable" or self:HasSpawnFlags(SF_TRIGGER_ALLOW_PHYSICS) and ent:GetMoveType() == MOVETYPE_VPHYSICS then
		if ent:IsNPC() then
			if self:HasSpawnFlags(SF_TRIGGER_ONLY_PLAYER_ALLY_NPCS) and IsFriendEntityName(ent:GetClass()) == false then
				return false;
			end;
		end;
		if self:HasSpawnFlags(SF_TRIGGER_ONLY_CLIENTS_IN_VEHICLES) and ent:IsPlayer() then
			if ent:InVehicle() == false then
				return false;
			end;
		end;
		if self:HasSpawnFlags(SF_TRIGGER_ONLY_CLIENTS_OUT_OF_VEHICLES) and ent:IsPlayer() then
			if not ent:InVehicle() == true then
				return false;
			end;
		end;
		local filterName = self:GetFilterName();
		if filterName ~= nil and filterName ~= "" then
			local filter = (ents.FindByName(filterName))[1];
			if IsValid(filter) and filter.PassesFilter then
				local res = self:PassesFilter(filter, self, ent);
				return res;
			end;
		end;
		return true;
	end;
	return false;
end;
function ENT:StartTouch(other)
	if not self.RefireDelay then
		return;
	end;
	if not IsValid(other) then
		return;
	end;
	if not self:PassesTriggerFilters(other) then
		return;
	end;
	local refireIndex = other:IsPlayer() and other:EntIndex() or 1;
	if refireIndex >= game.MaxPlayers() + 1 then
		print("Catapult: refire index hors range", nRefireIndex);
		refireIndex = 1;
	end;
	if self.RefireDelay[refireIndex] > CurTime() then
		return;
	end;
	if other:GetPhysicsObject() and other:IsPlayerHolding() then
		if not self.AbortedLaunchees[other] then
			self.AbortedLaunchees[other] = true;
		end;
		self.Thinking = true;
		self:NextThink(CurTime() + 0.05);
		return;
	elseif other:IsPlayer() then
		if not self.AbortedLaunchees[other] then
			self.AbortedLaunchees[other] = true;
		end;
		self.Thinking = true;
		self:NextThink(CurTime() + 0.05);
	end;
	local target = self:GetLaunchTarget();
	if IsValid(target) then
		if self:GetUseThresholdCheck() then
			local vecVictim;
			if other:IsPlayer() then
				vecVictim = other:GetVelocity();
			elseif IsValid(other:GetPhysicsObject()) then
				vecVictim = (other:GetPhysicsObject()):GetVelocity();
			else
				print("Catapult: fail, objet n'est pas un joueur et n'a pas de physobj");
				vecVictim = Vector(0, 0, 0);
			end;
			local flVictimSpeed = vecVictim:Length();
			local vecVelocity;
			if self:GetUseExactVelocity() then
				vecVelocity = self:CalculateLaunchVectorPreserve(vecVictim, other, target);
			else
				vecVelocity = self:CalculateLaunchVector(other, target);
			end;
			local flLaunchSpeed = vecVelocity:Length();
			local vecDirection = target:GetPos() - other:GetPos();
			local necNormalizedVictim = vecVictim:GetNormalized();
			local vecNormalizedDirection = vecDirection:GetNormalized();
			local flDot = necNormalizedVictim:Dot(vecNormalizedDirection);
			if flDot >= self:GetEntryAngleTolerance() then
				if flLaunchSpeed - flLaunchSpeed * self:GetLowerThreshold() < flVictimSpeed and flLaunchSpeed + flLaunchSpeed * self:GetUpperThreshold() > flVictimSpeed then
					if self:GetOnlyVelocityCheck() then
						self:OnLaunchedVictim(other);
					else
						self:LaunchByTarget(other, target);
						print("Catapult: adjusting velocity for ", self:GetName(), other:GetClass(), flVictimSpeed, flLaunchSpeed - flLaunchSpeed * self:GetLowerThreshold(), flLaunchSpeed + flLaunchSpeed * self:GetUpperThreshold());
					end;
				else
					print("Catapult: ignoring object ", self:GetName(), other:GetClass(), flVictimSpeed, flLaunchSpeed - flLaunchSpeed * self:GetLowerThreshold(), flLaunchSpeed + flLaunchSpeed * self:GetUpperThreshold());
					self.RefireDelay[refireIndex] = CurTime() + 0.1;
				end;
			else
				self.RefireDelay[refireIndex] = CurTime() + 0.1;
			end;
		else
			self:LaunchByTarget(other, target);
		end;
	else
		local shouldLaunch = true;
		if self:GetUseThresholdCheck() then
			local vecVictim;
			if other:IsPlayer() then
				vecVictim = other:GetVelocity();
			elseif IsValid(other:GetPhysicsObject()) then
				vecVictim = (other:GetPhysicsObject()):GetVelocity();
			else
				print("Catapult: fail, objet n'est pas un joueur et n'a pas de physobj");
				vecVictim = Vector(0, 0, 0);
			end;
			local vecForward = (self:GetLaunchDirection()):Forward();
			local flDot = vecForward:Dot(vecVictim);
			local flLower = self:GetPlayerSpeed() - self:GetPlayerSpeed() * self:GetLowerThreshold();
			local flUpper = self:GetPlayerSpeed() + self:GetPlayerSpeed() * self:GetUpperThreshold();
			if flDot < flLower or flDot > flUpper then
				shouldLaunch = false;
			end;
		end;
		if shouldLaunch then
			if self:GetOnlyVelocityCheck() then
				self:OnLaunchedVictim(other);
			else
				self:LaunchByDirection(other);
			end;
		end;
	end;
end;
function ENT:EndTouch(other)
	if not other:IsPlayer() and self.AbortedLaunchees[other] then
		self.AbortedLaunchees[other] = nil;
	end;
end;
function ENT:CalculateLaunchVector(victim, target)
	local vecSourcePos = victim:GetPos();
	local vecTargetPos = target:GetPos();
	if victim:IsPlayer() then
		vecTargetPos.z = vecTargetPos.z - 64;
	end;
	local speed = victim:IsPlayer() and self:GetPlayerSpeed() or self:GetPhysicsSpeed();
	local gravity = sv_gravity:GetFloat();
	local vecVelocity = vecTargetPos - vecSourcePos;
	local time = vecVelocity:Length() / speed;
	local velocityMultiplier = 1;
	vecVelocity = vecVelocity * (velocityMultiplier / time);
	vecVelocity.z = vecVelocity.z + gravity * time * 0.5;
	return vecVelocity;
end;
function ENT:CalculateLaunchVectorPreserve(vecInitialVelocity, victim, target, forcePlayer)
	local vecSourcePos = victim:GetPos();
	local vecTargetPos = target:GetPos();
	if victim:IsPlayer() or forcePlayer then
		vecTargetPos.z = vecTargetPos.z - 64;
	end;
	local vecDiff = vecTargetPos - vecSourcePos;
	local flHeight = vecDiff.z;
	local flDist = vecDiff:Length2D();
	local flVelocity = (victim:IsPlayer() or forcePlayer) and self:GetPlayerSpeed() or self:GetPhysicsSpeed();
	local flGravity = (-1) * sv_gravity:GetFloat();
	if flDist == 0 then
		print("Catapult: fail, objet n'est pas un joueur et n'a pas de physobj");
		return CalculateLaunchVector(victim, target);
	end;
	local flRadical = flVelocity * flVelocity * flVelocity * flVelocity - flGravity * (flGravity * flDist * flDist - 2 * flHeight * flVelocity * flVelocity);
	if flRadical <= 0 then
		print("Catapult: can't hit target, add more speed!");
		return CalculateLaunchVector(victim, target);
	end;
	flRadical = math.sqrt(flRadical);
	local flTestAngle1 = flVelocity * flVelocity;
	local flTestAngle2 = flTestAngle1;
	flTestAngle1 = -math.atan(((flTestAngle1 + flRadical) / (flGravity * flDist)));
	flTestAngle2 = -math.atan(((flTestAngle2 - flRadical) / (flGravity * flDist)));
	local vecTestVelocity1 = vecDiff;
	vecTestVelocity1.z = 0;
	vecTestVelocity1:Normalize();
	local vecTestVelocity2 = vecTestVelocity1;
	vecTestVelocity1 = vecTestVelocity1 * (flVelocity * math.cos(flTestAngle1));
	vecTestVelocity1.z = flVelocity * math.sin(flTestAngle1);
	vecTestVelocity2 = vecTestVelocity2 * math.cos(flTestAngle2);
	vecTestVelocity2.z = flVelocity * math.sin(flTestAngle2);
	vecInitialVelocity:Normalize();
	if self:GetUseExactVelocityMethod() == 1 then
		return vecTestVelocity1;
	elseif self:GetUseExactVelocityMethod() == 2 then
		return vecTestVelocity2;
	end;
	if vecInitialVelocity:Dot(vecTestVelocity1) > vecInitialVelocity:Dot(vecTestVelocity2) then
		return vecTestVelocity1;
	end;
	return vecTestVelocity2;
end;
function ENT:LaunchByDirection(victim)
	local vecForward = (self:GetLaunchDirection()):Forward();
	if victim:IsPlayer() then
		local vecPush = vecForward * self:GetPlayerSpeed();
		if math.abs(vecPush.x) < 0.001 and math.abs(vecPush.y) < 0.001 then
			vecPush.z = self:GetPlayerSpeed() * 1.5;
		end;
		if victim:IsOnGround() then
			victim:SetGroundEntity(NULL);
		end;
		hook.Add("Move", "GP2::test_setupmove_removespeed" .. victim:EntIndex(), function(ply, mv, cmd)
			if victim == ply then
				mv:SetVelocity(vecPush);
			end;
		end);
		self:OnLaunchedVictim(victim);
		if self:GetDirectionSuppressAirControl() then
			local flSupressionTimeInSeconds = 0.25;
			if self:GetAirControlSupressionTime() > 0 then
				flSupressionTimeInSeconds = self:GetAirControlSupressionTime();
			end;
		end;
	elseif victim:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = victim:GetPhysicsObject();
		if IsValid(phys) then
			local vecVelocity = vecForward * self:GetPhysicsSpeed();
			vecVelocity.z = self:GetPhysicsSpeed();
			local angImpulse = math.random(-50, 50);
			phys:SetVelocity(vecVelocity);
			self:SetLocalAngularVelocity(Angle(angImpulse, angImpulse, angImpulse));
			local flNull = 0;
			phys:SetDragCoefficient(flNull, flNull);
			phys:SetDamping(flNull, flNull);
			self.LaunchedProps[victim] = {
				velocity = vecVelocity,
				time = CurTime() + 0.3,
				phys = phys
			};
			self:TriggerOutput("OnPhysGunDrop");
		end;
	end;
	self:OnLaunchedVictim(victim);
end;
function ENT:OnLaunchedVictim(victim)
	self:TriggerOutput("OnCatapulted");
	if victim:IsPlayer() then
		local nRefireIndex = victim:EntIndex();
		self.RefireDelay[nRefireIndex] = CurTime() + 0.1;
	else
		local nRefireIndex = victim:EntIndex();
		self.RefireDelay[1] = CurTime() + 0.1;
	end;
end;
function ENT:LaunchByTarget(victim, target)
	local vecVictim;
	if IsValid(victim:GetPhysicsObject()) then
		vecVictim = (victim:GetPhysicsObject()):GetVelocity();
	else
		vecVictim = victim:GetVelocity();
	end;
	local vecVelocity = self:GetUseExactVelocity() and self:CalculateLaunchVectorPreserve(vecVictim, victim, target) or self:CalculateLaunchVector(victim, target);
	if victim:IsPlayer() then
		if victim:IsOnGround() then
			victim:SetGroundEntity(NULL);
		end;
		hook.Add("Move", "GP2::test_setupmove_removespeed" .. victim:EntIndex(), function(ply, mv, cmd)
			if victim == ply then
				mv:SetVelocity(vecVelocity);
			end;
		end);
		self:OnLaunchedVictim(victim);
	elseif victim:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = victim:GetPhysicsObject();
		if IsValid(phys) then
			local angImpulse = math.random(-50, 50);
			phys:SetVelocity(vecVelocity);
			victim:SetLocalAngularVelocity(Angle(angImpulse, angImpulse, angImpulse));
			local flNull = 0;
			phys:SetDragCoefficient(flNull, flNull);
			phys:SetDamping(flNull, flNull);
			self:TriggerOutput("OnPhysGunDrop");
		end;
	end;
	self:OnLaunchedVictim(victim);
end;
function ENT:Think()
	if self.Thinking then
		for other in pairs(self.AbortedLaunchees) do
			local bShouldRemove = true;
			if IsValid(other) then
				if other:IsPlayer() then
					bShouldRemove = self;
					self:StartTouch(other);
					hook.Remove("Move", "GP2::test_setupmove_removespeed" .. other:EntIndex());
				elseif IsValid(other:GetPhysicsObject()) then
					if other:IsPlayerHolding() then
						bShouldRemove = false;
					else
						self:StartTouch(other);
					end;
				end;
			else
				self.AbortedLaunchees[other] = nil;
			end;
			if bShouldRemove then
				self.AbortedLaunchees[other] = nil;
			end;
		end;
	end;
	local count = 0;
	for other in pairs(self.AbortedLaunchees) do
		count = count + 1;
	end;
	if count == 0 then
		self.Thinking = false;
		return true;
	end;
	self:NextThink(CurTime() + 0.05);
	return true;
end;
function ENT:Think()
	if self.Thinking then
		for other in pairs(self.AbortedLaunchees) do
			local bShouldRemove = true;
			if IsValid(other) then
				if other:IsPlayer() then
					bShouldRemove = self;
					self:StartTouch(other);
					hook.Remove("Move", "GP2::test_setupmove_removespeed" .. other:EntIndex());
				elseif IsValid(other:GetPhysicsObject()) then
					if other:IsPlayerHolding() then
						bShouldRemove = false;
					else
						self:StartTouch(other);
					end;
				end;
			else
				self.AbortedLaunchees[other] = nil;
			end;
			if bShouldRemove then
				self.AbortedLaunchees[other] = nil;
			end;
		end;
	end;
	local count = 0;
	for other in pairs(self.AbortedLaunchees) do
		count = count + 1;
	end;
	if count == 0 then
		self.Thinking = false;
		return true;
	end;
	self:NextThink(CurTime() + 0.05);
	return true;
end;
function ENT:Think()
	for ent, data in pairs(self.LaunchedProps) do
		if IsValid(ent) and IsValid(data.phys) then
			if CurTime() < data.time then
				data.phys:SetVelocity(data.velocity);
			else
				self.LaunchedProps[ent] = nil;
			end;
		else
			self.LaunchedProps[ent] = nil;
		end;
	end;
	self:NextThink(CurTime() + 0.05);
	return true;
end;
