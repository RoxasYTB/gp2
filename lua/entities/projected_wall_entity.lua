AddCSLuaFile();
ENT.Type = "anim";
local MAX_RAY_LENGTH = 8192;
local PROJECTED_WALL_WIDTH = 72;
ENT.PhysicsSolidMask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_BLOCKLOS;
PrecacheParticleSystem("projected_wall_impact");
if SERVER then
	util.AddNetworkString("ProjectedWall_SetOffset");
	net.Receive("ProjectedWall_SetOffset", function(len, ply)
		local ent = net.ReadEntity();
		local offsetZ = net.ReadFloat();
		local offsetX = net.ReadFloat();
		if IsValid(ent) then
			ent:SetFinalOffsetZ(offsetZ);
			ent:SetFinalOffsetX(offsetX);
		end;
	end);
end;
function ENT:SetupDataTables()
	self:NetworkVar("Bool", "Updated");
	self:NetworkVar("Bool", "GotInitialPosition");
	self:NetworkVar("Vector", "InitialPosition");
	self:NetworkVar("Float", "DistanceToHit");
	self:NetworkVar("Float", "FinalOffsetZ");
	self:NetworkVar("Float", "FinalOffsetX");
	self:NetworkVar("Bool", "IsProjectorCloned");
	self:NetworkVar("Float", "ManualOffsetZ");
	self:NetworkVar("Float", "ManualOffsetX");
	self:NetworkVar("Angle", "ManualAngle");
end;
function ENT:SetManualOffsetZ(val)
	self:SetManualOffsetZ(val);
end;
function ENT:SetManualOffsetX(val)
	self:SetManualOffsetX(val);
end;
function ENT:SetManualAngle(ang)
	self:SetManualAngle(ang);
end;
function ENT:Initialize()
	if SERVER then
		self.TraceFraction = 0;
		self:SetModel("models/props_junk/PopCan01a.mdl");
		self.LastLoggedOffsetZ = nil;
		if not PortalManager then
			timer.Simple(0.1, function()
				if not PortalManager and IsValid(self) then
					if file.Exists("lua/gp2/portalmanager.lua", "GAME") then
						include("gp2/portalmanager.lua");
					end;
				end;
			end);
		end;
	end;
	self:AddEffects(EF_NODRAW);
end;
function ENT:Think()
	if SERVER then
		local parent = self:GetParent();
		if IsValid(parent) and parent:GetClass() == "prop_wall_projector" then
			local newPos = parent:GetPos() + (parent:GetAngles()):Forward() * 8;
			local newAng = parent:GetAngles();
			if not self._lastSyncPos or (not self._lastSyncAng) or self._lastSyncPos ~= newPos or self._lastSyncAng ~= newAng then
				self:SetPos(newPos);
				self:SetAngles(newAng);
				self:SetUpdated(false);
				self:CreateWall();
				self._lastSyncPos = newPos;
				self._lastSyncAng = newAng;
			end;
		end;
		if self._originalCollisionData then
			if self:GetSolid() ~= self._originalCollisionData.Solid then
				self:SetSolid(self._originalCollisionData.Solid);
			end;
			if self:GetCollisionGroup() ~= self._originalCollisionData.CollisionGroup then
				self:SetCollisionGroup(self._originalCollisionData.CollisionGroup);
			end;
		end;
	end;
	if SERVER and (not self.IsPortalClone) and (not self:GetIsProjectorCloned()) then
		if not self._originalCollisionData then
			local phys = self:GetPhysicsObject();
			if IsValid(phys) then
				self._originalCollisionData = {
					Solid = self:GetSolid(),
					CollisionGroup = self:GetCollisionGroup()
				};
			end;
		end;
	end;
	if SERVER and (not self.IsPortalClone) and (not self:GetIsProjectorCloned()) and (not self.OriginalWallZ) then
		self.OriginalWallZ = (self:GetPos()).z;
		self.OriginalWallX = (self:GetPos()).x;
	end;
	if self:GetIsProjectorCloned() then
		if not self:GetUpdated() and (not self._finalWallCreated) then
			self:CreateWall();
			self._finalWallCreated = true;
		end;
		self:NextThink(CurTime() + 1);
		return true;
	end;
	if self.IsPortalClone then
		if SERVER then
			local physMins, physMaxs = self:GetCollisionBounds();
			local wallPos = self:GetPos();
			local wallAng = self:GetAngles();
			local minsWorld = wallPos + wallAng:Forward() * physMins.x + wallAng:Right() * physMins.y + wallAng:Up() * physMins.z;
			local maxsWorld = wallPos + wallAng:Forward() * physMaxs.x + wallAng:Right() * physMaxs.y + wallAng:Up() * physMaxs.z;
			local expand = 0;
			local boxMins = Vector(math.min(minsWorld.x, maxsWorld.x) - expand, math.min(minsWorld.y, maxsWorld.y) - expand, math.min(minsWorld.z, maxsWorld.z));
			local boxMaxs = Vector(math.max(minsWorld.x, maxsWorld.x) + expand, math.max(minsWorld.y, maxsWorld.y) + expand, math.min(minsWorld.z, maxsWorld.z));
			for _, ply in ipairs(ents.FindInBox(boxMins, boxMaxs)) do
				if ply:IsPlayer() and ply:Alive() and (not ply:IsFlagSet(FL_GODMODE)) then
					local plyPos = ply:GetPos();
					ply:SetPos(plyPos + Vector(0, 0, 1));
					ply:SetVelocity(Vector(0, 0, 0));
				end;
			end;
		end;
		self:NextThink(CurTime() + 0.5);
		return true;
	end;
	if not self:GetUpdated() then
		self:CreateWall();
		if self._originalCollisionData then
			self:SetSolid(self._originalCollisionData.Solid);
			self:SetCollisionGroup(self._originalCollisionData.CollisionGroup);
		end;
	end;
	if CLIENT then
		local now = CurTime();
		self._lastClientUpdate = self._lastClientUpdate or 0;
		if now - self._lastClientUpdate > 0.5 then
			self._lastClientUpdate = now;
			if ProjectedWallEntity and (not ProjectedWallEntity.IsAdded(self)) then
				self:CreateWall();
			end;
		end;
		self:SetNextClientThink(now + 0.5);
	end;
	self._lastFullUpdate = self._lastFullUpdate or 0;
	local currentTime = CurTime();
	if currentTime - self._lastFullUpdate < 0.2 then
		self:NextThink(CurTime() + 0.2);
		return true;
	end;
	self._lastFullUpdate = currentTime;
	local startPos = self:GetPos();
	local angles = self:GetAngles();
	local fwd = angles:Forward();
	local maxBounces = 1;
	local currentPos = startPos;
	local currentAng = angles;
	local lastEntity = self;
	local foundPortal = false;
	local tr;
	local bestPortalClonePos, bestPortalCloneAng, bestPortalCloneLinked = nil, nil, nil;
	local entryPortal = nil;
	for bounce = 1, maxBounces do
		local rayStart = currentPos;
		local rayEnd = currentPos + currentAng:Forward() * MAX_RAY_LENGTH;
		local extents = Vector(10, 10, 10);
		local found = false;
		local foundPortalEntity = nil;
		local foundPortalTr = nil;
		local rayHits = ents.FindAlongRay(rayStart, rayEnd, -extents, extents);
		for _, ent in ipairs(rayHits) do
			if IsValid(ent) then
				if ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
					found = true;
					foundPortalEntity = ent;
					entryPortal = ent;
					break;
				end;
			end;
		end;
		if not found then
			local tr_portal = util.TraceLine({
				start = rayStart,
				endpos = rayEnd,
				mask = MASK_SOLID
			});
			if IsValid(tr_portal.Entity) and tr_portal.Entity:GetClass() == "prop_portal" and IsValid(tr_portal.Entity:GetLinkedPartner()) then
				found = true;
				foundPortalEntity = tr_portal.Entity;
				entryPortal = tr_portal.Entity;
			end;
		end;
		if not found then
			local nearbyPortals = ents.FindInSphere(currentPos, 500);
			for _, ent in ipairs(nearbyPortals) do
				if IsValid(ent) and ent:GetClass() == "prop_portal" and IsValid(ent:GetLinkedPartner()) then
					local dirToPortal = (ent:GetPos() - currentPos):GetNormalized();
					local rayDir = currentAng:Forward();
					if dirToPortal:Dot(rayDir) > 0.8 then
						found = true;
						foundPortalEntity = ent;
						entryPortal = ent;
						break;
					end;
				end;
			end;
		end;
		if found and foundPortalEntity then
			foundPortal = true;
			local exitPortal = foundPortalEntity:GetLinkedPartner();
			self.LastFoundPortalEntity = exitPortal;
			if SERVER then
				local hitPos = entryPortal:GetPos();
				if not PortalManager then
					if file.Exists("lua/gp2/portalmanager.lua", "GAME") then
						include("gp2/portalmanager.lua");
					end;
				end;
				if PortalManager and PortalManager.TransformPortal then
					local newPos, newAng = PortalManager.TransformPortal(entryPortal, exitPortal, hitPos, currentAng);
					newAng = Angle(newAng.p, newAng.y + 180, newAng.r);
					local exitPortalPitch = (exitPortal:GetAngles()).p;
					if math.abs(exitPortalPitch - 90) < 10 then
						newAng = Angle(-newAng.p, newAng.y, newAng.r);
					elseif math.abs(exitPortalPitch - (-90)) < 10 then
						newAng = Angle(-newAng.p, newAng.y, newAng.r);
					end;
					bestPortalClonePos = newPos;
					bestPortalCloneAng = newAng;
					bestPortalCloneLinked = exitPortal;
				else
					local entryPos = entryPortal:GetPos();
					local entryAng = entryPortal:GetAngles();
					local exitPos = exitPortal:GetPos();
					local exitAng = exitPortal:GetAngles();
					local newPos = exitPos + exitAng:Forward() * 50;
					local newAng = Angle(exitAng.p, exitAng.y + 180, exitAng.r);
					bestPortalClonePos = newPos;
					bestPortalCloneAng = newAng;
					bestPortalCloneLinked = exitPortal;
				end;
			end;
			if PortalManager and PortalManager.TransformPortal then
				currentPos, currentAng = PortalManager.TransformPortal(foundPortalEntity, exitPortal, hitPos, currentAng);
				currentAng = Angle(currentAng.p, currentAng.y + 180, currentAng.r);
				local exitPortalPitch = (exitPortal:GetAngles()).p;
				if math.abs(exitPortalPitch - 90) < 10 then
					currentAng = Angle(-currentAng.p, currentAng.y, currentAng.r);
				elseif exitPortalPitch == (-90) then
					currentAng = Angle(-currentAng.p, currentAng.y, currentAng.r);
				end;
			end;
			lastEntity = exitPortal;
			break;
		end;
	end;
	if not tr then
		tr = {
			Fraction = 1,
			HitPos = currentPos + currentAng:Forward() * MAX_RAY_LENGTH,
			Entity = NULL
		};
	end;
	if SERVER then
		local physMins, physMaxs = self:GetCollisionBounds();
		local wallPos = self:GetPos();
		local wallAng = self:GetAngles();
		local minsWorld = wallPos + wallAng:Forward() * physMins.x + wallAng:Right() * physMins.y + wallAng:Up() * physMins.z;
		local maxsWorld = wallPos + wallAng:Forward() * physMaxs.x + wallAng:Right() * physMaxs.y + wallAng:Up() * physMaxs.z;
		local expand = 0;
		local boxMins = Vector(math.min(minsWorld.x, maxsWorld.x) - expand, math.min(minsWorld.y, maxsWorld.y) - expand, math.min(minsWorld.z, maxsWorld.z) - expand);
		local boxMaxs = Vector(math.max(minsWorld.x, maxsWorld.x) + expand, math.min(minsWorld.y, maxsWorld.y) + expand, math.max(minsWorld.z, maxsWorld.z) - expand);
		for _, ply in ipairs(ents.FindInBox(boxMins, boxMaxs)) do
			if ply:IsPlayer() and ply:Alive() and (not ply:IsFlagSet(FL_GODMODE)) then
				local plyPos = ply:GetPos();
				ply:SetPos(plyPos + Vector(0, 0, 1));
				ply:SetVelocity(Vector(0, 0, 0));
			end;
		end;
	end;
	if SERVER then
		self._lastCloneUpdate = self._lastCloneUpdate or 0;
		local currentTime = CurTime();
		if currentTime - self._lastCloneUpdate < 0.2 then
			self:NextThink(CurTime() + 0.2);
			return true;
		end;
		if foundPortal and bestPortalClonePos and bestPortalCloneAng and bestPortalCloneLinked then
			local function vectorsEqual(a, b, tolerance)
				tolerance = tolerance or 0.1;
				return math.abs(a.x - b.x) < tolerance and math.abs(a.y - b.y) < tolerance and math.abs(a.z - b.z) < tolerance;
			end;
			local function anglesEqual(a, b, tolerance)
				tolerance = tolerance or 1;
				return math.abs(a.p - b.p) < tolerance and math.abs(a.y - b.y) < tolerance and math.abs(a.r - b.r) < tolerance;
			end;
			self._lastPortalClonePos = self._lastPortalClonePos or Vector(0, 0, 0);
			self._lastPortalCloneAng = self._lastPortalCloneAng or Angle(0, 0, 0);
			local portalMoved = not vectorsEqual(self._lastPortalClonePos, bestPortalCloneLinked:GetPos()) or (not anglesEqual(self._lastPortalCloneAng, bestPortalCloneLinked:GetAngles()));
			local forceCreate = not self.PortalClone or (not IsValid(self.PortalClone));
			self._lastPortalClonePos = bestPortalCloneLinked:GetPos();
			self._lastPortalCloneAng = bestPortalCloneLinked:GetAngles();
			if portalMoved or forceCreate then
				self._lastCloneUpdate = currentTime;
				if self.PortalClone and IsValid(self.PortalClone) then
					self.PortalClone:Remove();
					self.PortalClone = nil;
					self.PortalCloneLinked = nil;
				end;
				if self.EntryPortalClone and IsValid(self.EntryPortalClone) then
					self.EntryPortalClone:Remove();
					self.EntryPortalClone = nil;
				end;
				local entryCloneWall = ents.Create("projected_wall_entity");
				if IsValid(entryCloneWall) then
					local entryPortalAng = entryPortal:GetAngles();
					local entryCloneAngle = Angle(entryPortalAng.p - 90, entryPortalAng.y, entryPortalAng.r);
					local entryPortalPitch = entryPortalAng.p;
					local entryPortalZ = entryPortal and (entryPortal:GetPos()).z or 0;
					local entryPortalX = entryPortal and (entryPortal:GetPos()).x or 0;
					local entryPortalY = entryPortal and (entryPortal:GetPos()).y or 0;
					local originProjectorZ = (self:GetPos()).z;
					local originProjectorX = (self:GetPos()).x;
					local originProjectorY = (self:GetPos()).y;
					local offsetZ = entryPortalZ - originProjectorZ;
					local offsetX = entryPortalX - originProjectorX;
					local offsetY = entryPortalY - originProjectorY;
					print("[GP2] prop_wall_projector: Création du clone miroir pour le portail d'entrée");
					print("[GP2] prop_wall_projector: Position du portail d'entrée: " .. tostring(entryPortal:GetPos()));
					print("[GP2] prop_wall_projector: Position du projecteur d'origine: " .. tostring(self:GetPos()));
					print("[GP2] prop_wall_projector: Position du portail de sortie: " .. tostring(bestPortalCloneLinked:GetPos()));
					print("[GP2] prop_wall_projector: Position du projecteur cloné: " .. tostring(bestPortalClonePos));
					print("[GP2] prop_wall_projector: Offset Z: " .. tostring(offsetZ));
					print("[GP2] prop_wall_projector: Offset X: " .. tostring(offsetX));
					print("[GP2] prop_wall_projector: Offset Y: " .. tostring(offsetY));
					print("------------------------------------------------------------------------");
					local yaw = entryPortalAng.y % 360;
					if yaw >= 45 and yaw < 135 then
						offsetX = entryPortalY - originProjectorY;
						offsetX = -offsetX;
						offsetY = 0;
					elseif yaw >= 135 and yaw < 225 then
						offsetX = 0;
						offsetY = -offsetY;
					elseif yaw >= 225 and yaw < 315 then
						offsetX = -(entryPortalY - originProjectorY);
						offsetX = -offsetX;
						offsetY = 0;
					else
						offsetX = 0;
					end;
					if math.abs(entryPortalPitch - 90) < 10 then
						entryCloneAngle = Angle(-entryCloneAngle.p, entryCloneAngle.y, entryCloneAngle.r);
					elseif math.abs(entryPortalPitch - (-90)) < 10 then
						entryCloneAngle = Angle(-entryCloneAngle.p, entryCloneAngle.y, entryCloneAngle.r);
					end;
					while entryCloneAngle.y >= 360 do
						entryCloneAngle.y = entryCloneAngle.y - 360;
					end;
					while entryCloneAngle.y < 0 do
						entryCloneAngle.y = entryCloneAngle.y + 360;
					end;
					local parent = self:GetParent();
					if IsValid(parent) then
						local entryClonePos = self:GetPos();
						local entryCloneAng = self:GetAngles();
						if self.GetManualOffsetZ then
							entryCloneWall:SetManualOffsetZ(self:GetManualOffsetZ());
						end;
						if self.GetManualOffsetX then
							entryCloneWall:SetManualOffsetX(self:GetManualOffsetX());
						end;
						if self.GetManualAngle then
							entryCloneWall:SetManualAngle(self:GetManualAngle());
						end;
						entryCloneWall:SetPos(entryClonePos);
						entryCloneWall:SetAngles(entryCloneAng);
						entryCloneWall:SetParent(entryPortal);
						entryCloneWall.IsPortalClone = true;
						entryCloneWall.InvisibleClone = true;
						entryCloneWall:Spawn();
						entryCloneWall:Activate();
						entryCloneWall:AddEffects(EF_NODRAW);
						if self._originalCollisionData then
							entryCloneWall:SetSolid(self._originalCollisionData.Solid);
							entryCloneWall:SetCollisionGroup(self._originalCollisionData.CollisionGroup);
						end;
						entryCloneWall:CreateWall();
						self.EntryPortalClone = entryCloneWall;
						print("[GP2] Clone miroir créé au portail d'entrée avec angles: " .. tostring(entryCloneAngle));
						print("[GP2] Position du clone miroir: " .. tostring(entryClonePos));
					end;
				end;
				local cloneProjector = ents.Create("prop_wall_projector");
				if IsValid(cloneProjector) then
					local entryPortalZ = entryPortal and (entryPortal:GetPos()).z or 0;
					local entryPortalX = entryPortal and (entryPortal:GetPos()).x or 0;
					local entryPortalY = entryPortal and (entryPortal:GetPos()).y or 0;
					local originProjectorZ = (self:GetPos()).z;
					local originProjectorX = (self:GetPos()).x;
					local originProjectorY = (self:GetPos()).y;
					local offsetZ = entryPortalZ - originProjectorZ;
					local offsetX = entryPortalX - originProjectorX;
					local offsetY = entryPortalY - originProjectorY;
					print("[GP2] prop_wall_projector: Création du clone du projecteur de mur");
					print("[GP2] prop_wall_projector: Position du portail d'entrée: " .. tostring(entryPortal:GetPos()));
					print("[GP2] prop_wall_projector: Position du projecteur d'origine: " .. tostring(self:GetPos()));
					print("[GP2] prop_wall_projector: Position du portail de sortie: " .. tostring(bestPortalCloneLinked:GetPos()));
					print("[GP2] prop_wall_projector: Position du projecteur cloné: " .. tostring(bestPortalClonePos));
					print("[GP2] prop_wall_projector: Offset Z: " .. tostring(offsetZ));
					print("[GP2] prop_wall_projector: Offset X: " .. tostring(offsetX));
					print("[GP2] prop_wall_projector: Offset Y: " .. tostring(offsetY));
					local exitAng = bestPortalCloneLinked:GetAngles();
					local yaw = exitAng.y % 360;
					if yaw >= 45 and yaw < 135 then
						offsetX = entryPortalY - originProjectorY;
						offsetX = -offsetX;
						offsetY = 0;
						print("[GP2] Correction de l'offset X pour le portail à l'est");
					elseif yaw >= 135 and yaw < 225 then
						offsetX = 0;
						offsetY = -offsetY;
						print("[GP2] Correction de l'offset X pour le portail au sud");
					elseif yaw >= 225 and yaw < 315 then
						offsetX = -(entryPortalY - originProjectorY);
						offsetX = -offsetX;
						offsetY = 0;
						print("[GP2] Correction de l'offset X pour le portail à l'ouest");
					else
						offsetX = 0;
						print("[GP2] Correction de l'offset X pour le portail au nord");
					end;
					local finalAngle = bestPortalCloneAng;
					if bestPortalCloneAng.p == 90 or bestPortalCloneAng.p == (-90) then
						finalAngle = Angle(bestPortalCloneAng.p, bestPortalCloneAng.y + 180, bestPortalCloneAng.r);
						if bestPortalCloneAng.p == 90 then
							bestPortalClonePos = bestPortalClonePos - bestPortalCloneAng:Forward() * 20;
						else
							bestPortalClonePos = bestPortalClonePos + bestPortalCloneAng:Forward() * (-8);
						end;
						bestPortalClonePos = bestPortalClonePos - bestPortalCloneAng:Up() * (-offsetZ);
						bestPortalClonePos = bestPortalClonePos + bestPortalCloneAng:Right() * (-offsetX);
					else
						finalAngle = Angle(bestPortalCloneAng.p, bestPortalCloneAng.y + 180, bestPortalCloneAng.r);
						bestPortalClonePos = bestPortalClonePos - bestPortalCloneAng:Forward() * (-8);
						bestPortalClonePos.z = bestPortalClonePos.z - offsetZ;
						bestPortalClonePos.x = bestPortalClonePos.x + offsetX;
						bestPortalClonePos.y = bestPortalClonePos.y + offsetY;
					end;
					while finalAngle.y >= 360 do
						finalAngle.y = finalAngle.y - 360;
					end;
					while finalAngle.y < 0 do
						finalAngle.y = finalAngle.y + 360;
					end;
					if cloneProjector.SetIsProjectorCloned then
						cloneProjector:SetIsProjectorCloned(true);
					end;
					cloneProjector:SetPos(bestPortalClonePos);
					cloneProjector:SetAngles(finalAngle);
					cloneProjector:Spawn();
					cloneProjector:Activate();
					cloneProjector:SetParent(bestPortalCloneLinked);
					if cloneProjector.ProjectedWall and IsValid(cloneProjector.ProjectedWall) then
						cloneProjector.ProjectedWall:SetManualAngle(finalAngle);
					end;
					timer.Simple(0.1, function()
						if IsValid(cloneProjector) and cloneProjector.ProjectedWall and IsValid(cloneProjector.ProjectedWall) then
							cloneProjector.ProjectedWall:SetIsProjectorCloned(true);
							cloneProjector.ProjectedWall:SetAngles(cloneProjector:GetAngles());
							if IsValid(cloneProjector.ProjectedWall:GetPhysicsObject()) then
								(cloneProjector.ProjectedWall:GetPhysicsObject()):Remove();
							end;
							cloneProjector.ProjectedWall:SetUpdated(false);
							cloneProjector.ProjectedWall._finalWallCreated = false;
							cloneProjector.ProjectedWall:CreateWall();
							cloneProjector.ProjectedWall._finalWallCreated = true;
							timer.Simple(0.2, function()
								if IsValid(cloneProjector.ProjectedWall) then
									local phys = cloneProjector.ProjectedWall:GetPhysicsObject();
									if IsValid(phys) then
										phys:EnableMotion(false);
										phys:SetMaterial("gmod_silent");
									end;
								end;
							end);
						end;
					end);
					self.PortalClone = cloneProjector;
					self.PortalCloneLinked = bestPortalCloneLinked;
				end;
			end;
		elseif self.PortalClone and IsValid(self.PortalClone) then
			self.PortalClone:Remove();
			self.PortalClone = nil;
			self.PortalCloneLinked = nil;
			if self.EntryPortalClone and IsValid(self.EntryPortalClone) then
				self.EntryPortalClone:Remove();
				self.EntryPortalClone = nil;
			end;
		elseif not foundPortal then
		elseif not bestPortalClonePos then
		elseif not bestPortalCloneAng then
		elseif not bestPortalCloneLinked then
		end;
	end;
	if tr and tr.Fraction then
		if self.TraceFraction == nil then
			self.TraceFraction = tr.Fraction;
			self:SetUpdated(false);
		elseif math.abs(self.TraceFraction - tr.Fraction) > 0.05 then
			self.TraceFraction = tr.Fraction;
			self:SetUpdated(false);
		end;
	end;
	self:NextThink(CurTime() + 0.2);
	return true;
end;
function ENT:Draw()
end;
function ENT:OnRemove(fd)
	if self.WallImpact then
		self.WallImpact:StopEmissionAndDestroyImmediately();
	end;
	if SERVER and self.PortalClone and IsValid(self.PortalClone) then
		self.PortalClone:Remove();
		self.PortalClone = nil;
		self.PortalCloneLinked = nil;
	end;
	if SERVER and self.EntryPortalClone and IsValid(self.EntryPortalClone) then
		self.EntryPortalClone:Remove();
		self.EntryPortalClone = nil;
	end;
	if self.IsPortalClone then
	end;
end;
function ENT:CreateWall()
	if self:GetIsProjectorCloned() and self._finalWallCreated then
		return;
	end;
	local startPos = self:GetPos();
	local angles = self:GetAngles();
	local fwd = angles:Forward();
	local right = angles:Right();
	local up = angles:Up();
	if self:GetManualAngle() and self:GetManualAngle() ~= Angle(0, 0, 0) then
		angles = self:GetManualAngle();
		fwd = angles:Forward();
		right = angles:Right();
		up = angles:Up();
	end;
	local tr = util.TraceLine({
		start = startPos,
		endpos = startPos + fwd * MAX_RAY_LENGTH,
		mask = MASK_SOLID_BRUSHONLY
	});
	local hitPos = tr.HitPos;
	local distance = hitPos:Distance(startPos);
	local v = (-distance) / 192;
	self:SetDistanceToHit(distance);
	local offsetZ = self:GetIsProjectorCloned() and 0 or (self:GetManualOffsetZ() or 0);
	local offsetX = self:GetIsProjectorCloned() and 0 or (self:GetManualOffsetX() or 0);
	local adjustedStartPos = startPos + up * offsetZ + right * offsetX;
	local fullLength = (tr.HitPos - adjustedStartPos):Length();
	local halfWidth = PROJECTED_WALL_WIDTH / 2;
	local verts_col = {
		Vector(0, -halfWidth, -2),
		Vector(0, -halfWidth, 2),
		Vector(0, halfWidth, -2),
		Vector(0, halfWidth, 2),
		Vector(fullLength, -halfWidth, -2),
		Vector(fullLength, -halfWidth, 2),
		Vector(fullLength, halfWidth, -2),
		Vector(fullLength, halfWidth, 2)
	};
	if CLIENT then
		if not self.InvisibleClone then
			self._meshPool = self._meshPool or {};
			local mesh = self.Mesh;
			if not mesh or (not mesh:IsValid()) then
				mesh = Mesh();
				self.Mesh = mesh;
				table.insert(self._meshPool, mesh);
			end;
			local verts = {
				{
					pos = adjustedStartPos - right * halfWidth,
					u = 1,
					v = 0
				},
				{
					pos = adjustedStartPos - right * halfWidth + fwd * distance,
					u = 1,
					v = v
				},
				{
					pos = adjustedStartPos - right * halfWidth + fwd * distance + right * PROJECTED_WALL_WIDTH,
					u = 0,
					v = v
				},
				{
					pos = adjustedStartPos + right * halfWidth + fwd * distance,
					u = 0,
					v = v
				},
				{
					pos = adjustedStartPos + right * halfWidth,
					u = 0,
					v = 0
				},
				{
					pos = adjustedStartPos - right * halfWidth,
					u = 1,
					v = 0
				}
			};
			if self.IsPortalClone and self.InitialCloneAngle then
				local pitch = self.InitialCloneAngle.p;
				if math.abs(pitch - 90) < 10 or math.abs(pitch - (-90)) < 10 then
					for k, vert in ipairs(verts) do
						vert.pos = vert.pos + up * 0;
					end;
				end;
			end;
			mesh:BuildFromTriangles(verts);
			if ProjectedWallEntity then
				ProjectedWallEntity.AddToRenderList(self, mesh);
			end;
		end;
	end;
	if SERVER then
		self:SetPos(adjustedStartPos);
		self:SetAngles(angles);
		self:PhysicsInitStatic(6);
		self:SetUpdated(true);
	else
		if not IsValid(self.WallImpact) then
			local wallImpactAng = tr.HitNormal:Angle();
			self.WallImpact = CreateParticleSystemNoEntity("projected_wall_impact", tr.HitPos - fwd * 4, wallImpactAng);
		end;
		if not self:GetUpdated() and IsValid(self.WallImpact) then
			self.WallImpact:StopEmissionAndDestroyImmediately();
			self.WallImpact = nil;
		end;
	end;
	self:EnableCustomCollisions(true);
	self:PhysicsInitConvex(verts_col, "hard_light_bridge");
	local phys = self:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
		phys:SetContents(CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_BLOCKLOS);
		if self:GetIsProjectorCloned() then
			phys:SetMaterial("gmod_silent");
			phys:Wake();
			timer.Simple(0.1, function()
				if IsValid(self) and IsValid(phys) then
					phys:Sleep();
				end;
			end);
		end;
	elseif self:GetIsProjectorCloned() then
	end;
end;
if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS;
	end;
end;
