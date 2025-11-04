include("shared.lua");
ENT = ENT or {};
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
local clamp = math.Clamp;
EnvPortalLaser = EnvPortalLaser or {};
EnvPortalLaser.RenderList = EnvPortalLaser.RenderList or {};
function EnvPortalLaser.AddToRenderList(laser)
	if IsValid(laser) then
		EnvPortalLaser.RenderList[laser] = true;
	end;
end;
function EnvPortalLaser.RemoveFromRenderList(laser)
	EnvPortalLaser.RenderList[laser] = nil;
end;
function EnvPortalLaser.RefreshRenderList()
	for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
		if IsValid(ent) and ent:GetState() then
			EnvPortalLaser.RenderList[ent] = true;
		end;
	end;
end;
function EnvPortalLaser.CreateSegmentsFromSimpleData(laser)
end;
function EnvPortalLaser.DrawAllSegments()
	for laser, _ in pairs(EnvPortalLaser.RenderList) do
		if IsValid(laser) and laser.GetState and laser:GetState() and laser.DrawLaserSegments then
			laser:DrawLaserSegments();
		end;
	end;
end;
net.Receive("LaserSegments", function()
	local laser = net.ReadEntity();
	if not IsValid(laser) then
		return;
	end;
	local numSegments = net.ReadUInt(8);
	laser.LaserSegments = {};
	for i = 1, numSegments do
		local startPos = net.ReadVector();
		local endPos = net.ReadVector();
		local hitsPortal = net.ReadBool();
		local canReachPortal = net.ReadBool();
		table.insert(laser.LaserSegments, {
			start = startPos,
			endpos = endPos,
			hitsPortal = hitsPortal,
			canReachPortal = canReachPortal
		});
	end;
	EnvPortalLaser.RenderList[laser] = true;
end);
function ENT:Initialize()
	if self:GetState() then
		self:StartParticles();
		self:StartLoopingSounds();
	end;
end;
function ENT:OnRemove()
	self:StopParticles();
	self:StopLoopingSounds();
	EnvPortalLaser.RemoveFromRenderList(self);
end;
function ENT:Think()
	EnvPortalLaser.AddToRenderList(self);
	EnvPortalLaser.CreateSegmentsFromSimpleData(self);
	if IsValid(self:GetParentLaser()) then
		self:SetNextClientThink(CurTime() + 0.001);
	else
		self:SetNextClientThink(CurTime() + 0.016);
	end;
	self:ChangeVolumeByDistanceToBeam();
	if self:GetShouldSpark() and self.LaserSegments and #self.LaserSegments > 0 then
		self:StartSparkParticle();
		local finalSegment = self.LaserSegments[#self.LaserSegments];
		if IsValid(self.SparksParticle) then
			self.SparksParticle:SetControlPointOrientation(0, (self:GetHitNormal()):Angle());
			self.SparksParticle:SetControlPoint(0, finalSegment.endpos);
		end;
		render.SetMaterial(Material("sprites/physbeam"));
		render.DrawBeam(finalSegment.start, finalSegment.endpos, 2, 0, 1, Color(255, 255, 255, 0));
	elseif IsValid(self.SparksParticle) then
		self.SparksParticle:StopEmission();
		self.SparksParticle = NULL;
	end;
	return true;
end;
function ENT:DrawLaserSegments()
	if not self.LaserSegments or #self.LaserSegments == 0 then
		return;
	end;
	local material = Material("sprites/physbeam");
	if material:IsError() then
		material = Material("cable/cable");
	end;
	local glowMaterial = Material("sprites/light_glow");
	if glowMaterial:IsError() then
		glowMaterial = material;
	end;
	for i, segment in ipairs(self.LaserSegments) do
		if not segment.start or (not segment.endpos) then
			continue;
		end;
		local start = segment.start;
		local endpos = segment.endpos;
		if #self.LaserSegments > 1 then
			local dir = (endpos - start):GetNormalized();
			if i == 1 then
				local extension = segment.hitsPortal and segment.canReachPortal ~= false and 20 or 12;
				endpos = endpos + dir * extension;
			end;
			if i > 1 and i < (#self.LaserSegments) then
				start = start - dir * 0;
				local extension = segment.hitsPortal and segment.canReachPortal ~= false and 16 or 8;
				endpos = endpos + dir * extension;
			end;
			if i == (#self.LaserSegments) then
				local extension = 12;
				if i > 1 and self.LaserSegments[i - 1].hitsPortal and self.LaserSegments[i - 1].canReachPortal ~= false then
					extension = 20;
				end;
				start = start - dir * 6.05;
			end;
		elseif segment.hitsPortal and segment.canReachPortal ~= false then
			local dir = (endpos - start):GetNormalized();
			endpos = endpos + dir * 15;
		end;
		local mainWidth = 8;
		local glowWidth = 18;
		local color = Color(104, 6, 6, 255);
		local glowColor = Color(255, 80, 80, 120);
		render.SetMaterial(glowMaterial);
		render.DrawBeam(start, endpos, glowWidth, 0, 1, glowColor);
		render.SetMaterial(material);
		render.DrawBeam(start, endpos, mainWidth, 0, 1, color);
		render.SetMaterial(material);
		render.DrawBeam(start, endpos, 2, 0, 1, Color(255, 255, 255, 255));
	end;
end;
function EnvPortalLaser.DrawAllSegments()
	EnvPortalLaser.RefreshRenderList();
	for laser, _ in pairs(EnvPortalLaser.RenderList) do
		if IsValid(laser) and laser.GetState and laser:GetState() and laser.DrawLaserSegments then
			laser:DrawLaserSegments();
		elseif not IsValid(laser) then
			EnvPortalLaser.RenderList[laser] = nil;
		end;
	end;
end;
hook.Add("PostDrawTranslucentRenderables", "EnvPortalLaser_Render", function()
	local success, err = pcall(function()
		EnvPortalLaser.RefreshRenderList();
		for laser, _ in pairs(EnvPortalLaser.RenderList) do
			if IsValid(laser) and laser.GetState and laser:GetState() then
				if laser.DrawLaserSegments then
					laser:DrawLaserSegments();
				end;
			else
				EnvPortalLaser.RenderList[laser] = nil;
			end;
		end;
		if EnvPortalLaser and EnvPortalLaser.Render then
			local originalRender = EnvPortalLaser.Render;
			EnvPortalLaser.Render = function()
			end;
			timer.Simple(0, function()
				EnvPortalLaser.Render = originalRender;
			end);
		end;
	end);
	if not success then
		print("[GP2] Erreur lors du rendu des lasers: " .. tostring(err));
	end;
end);
function ENT:StartSparkParticle()
	if not IsValid(self.SparksParticle) then
		local particleName = self:GetParticleNameOrFallback("discouragement_beam_sparks", "explosion_turret_break");
		if particleName then
			self.SparksParticle = CreateParticleSystem(self, particleName, PATTACH_CUSTOMORIGIN);
		end;
	end;
end;
function ENT:StartParticles()
	if IsValid(self:GetParentLaser()) then
		local particleName = self:GetParticleNameOrFallback("reflector_start_glow", "explosion_turret_break");
		if particleName then
			self.Particle = CreateParticleSystem(self, particleName, PATTACH_ABSORIGIN_FOLLOW);
		end;
	else
		local particleName = null;
		if particleName then
			self.Particle = CreateParticleSystem(self, particleName, PATTACH_POINT_FOLLOW, self:LookupAttachment("laser_attachment"));
		end;
	end;
	self:StartSparkParticle();
end;
function ENT:StopParticles()
	if IsValid(self.Particle) then
		self.Particle:StopEmission();
	end;
	if IsValid(self.SparksParticle) then
		self.SparksParticle:StopEmission();
	end;
end;
function ENT:StartLoopingSounds()
	if not self.BeamSound then
		self.BeamSound = CreateSound(self, "Laser.BeamLoop");
		self.BeamSound:SetSoundLevel(0);
		self.BeamSound:PlayEx(0, 100);
	end;
end;
function ENT:StopLoopingSounds()
	if self.BeamSound then
		self.BeamSound:Stop();
		self.BeamSound = nil;
	end;
end;
function ENT:ChangeVolumeByDistanceToBeam()
	local pos = EyePos();
	local nearest = CalcClosestPointOnLineSegment(pos, self:GetPos(), self:GetHitPos());
	local distance = (pos - nearest):Length();
	local maxDistance = 400;
	local minVolume = 0;
	local maxVolume = 0.25;
	local volume = clamp((maxDistance - distance) / maxDistance * (maxVolume - minVolume) + minVolume, minVolume, maxVolume);
	if self.BeamSound then
		if not self.BeamSound:IsPlaying() then
			self.BeamSound:PlayEx(volume, 100);
		else
			self.BeamSound:ChangeVolume(volume);
		end;
	end;
end;
function ENT:OnStateChange(name, old, new)
	if new then
		self:StartParticles();
		self:StartLoopingSounds();
	else
		self:StopParticles();
		self:StopLoopingSounds();
	end;
end;
local function RefreshAllPortalLasers()
	for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
		if IsValid(ent) then
			EnvPortalLaser.AddToRenderList(ent);
			EnvPortalLaser.CreateSegmentsFromSimpleData(ent);
			if ent.LaserSegments and #ent.LaserSegments > 0 then
			end;
		end;
	end;
end;
hook.Add("InitPostEntity", "GP2_RefreshPortalLasers", function()
	timer.Simple(0.5, RefreshAllPortalLasers);
end);
hook.Add("PostCleanupMap", "GP2_RefreshPortalLasers_Cleanup", function()
	timer.Simple(0.5, RefreshAllPortalLasers);
end);
hook.Add("OnEntityCreated", "GP2_DetectNewLasers", function(ent)
	if IsValid(ent) and ent:GetClass() == "env_portal_laser" then
		timer.Simple(0.1, function()
			if IsValid(ent) then
				EnvPortalLaser.AddToRenderList(ent);
				EnvPortalLaser.CreateSegmentsFromSimpleData(ent);
				print("[GP2] Nouveau laser détecté et ajouté au rendu: " .. tostring(ent));
			end;
		end);
	end;
end);
if not timer.Exists("GP2_ForceLaserRefresh") then
	timer.Create("GP2_ForceLaserRefresh", 0.033, 0, function()
		RefreshAllPortalLasers();
		for _, ent in ipairs(ents.FindByClass("env_portal_laser")) do
			if IsValid(ent) and ent:GetState() then
				EnvPortalLaser.AddToRenderList(ent);
				EnvPortalLaser.CreateSegmentsFromSimpleData(ent);
			end;
		end;
	end);
end;
if not ENT.GetHitPos then
	function ENT:GetHitPos()
		if self.TraceResult and self.TraceResult.HitPos then
			return self.TraceResult.HitPos;
		end;
		return self:GetPos();
	end;
end;
hook.Add("OnEntityCreated", "GP2_EnsureGetHitPosAndState", function(ent)
	if IsValid(ent) and ent:GetClass() == "env_portal_laser" then
		if not ent.GetHitPos then
			function ent:GetHitPos()
				if self.TraceResult and self.TraceResult.HitPos then
					print("[GP2] Warning: GetHitPos called on env_portal_laser without TraceResult");
					return self.TraceResult.HitPos;
				end;
				return self:GetPos();
			end;
		end;
		if not ent.GetState then
			function ent:GetState()
				return self.State or false;
			end;
		end;
	end;
end);
