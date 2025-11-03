ENT.Type = "anim";
ENT.Base = "base_anim";
ENT.Spawnable = true;
ENT.AdminOnly = false;
ENT.Category = "Portal 2";
ENT.PrintName = "Portal";
ENT.Author = "GP2 Framework";
ENT.Information = "Portal entity from Portal 2";
ENT.Contact = "";
ENT.Contents = MASK_OPAQUE_AND_NPCS;
ENT.ClassName = "prop_portal";
ENT.Folder = "entities";
function ENT:SetupDataTables()
	self:NetworkVar("Bool", "Activated");
	self:NetworkVar("Bool", "PlacedByMap");
	self:NetworkVar("Entity", "LinkedPartnerInternal");
	self:NetworkVar("Vector", "SizeInternal");
	self:NetworkVar("Int", "SidesInternal");
	self:NetworkVar("Int", "Type");
	self:NetworkVar("Int", "LinkageGroup");
	self:NetworkVar("Float", "OpenTime");
	self:NetworkVar("Float", "StaticTime");
	self:NetworkVar("Vector", "ColorVectorInternal");
	self:NetworkVar("Vector", "ColorVector01Internal");
	if SERVER then
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self:SetSize(Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 8));
		else
			self:SetSize(Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7));
		end;
		self:SetColorVectorInternal(Vector(255, 255, 255));
		print("Portal " .. tostring(self) .. " initialized with size " .. tostring(self:GetSize()));
		self:SetPlacedByMap(true);
	end;
	self:NetworkVarNotify("Activated", self.OnActivated);
end;
function ENT:SetSize(n)
	if not n or n == Vector(0, 0, 0) or n.x <= 0 or n.y <= 0 or n.z <= 0 then
		GP2.Print("Portal %d: Invalid size provided: %s", self:EntIndex(), tostring(n));
		return;
	end;
	self:SetSizeInternal(n);
	if SERVER and self:GetClass() == "prop_portal" then
		self:UpdatePhysmesh();
	end;
end;
function ENT:SetRemoveExit(bool)
	self.PORTAL_REMOVE_EXIT = bool;
end;
function ENT:GetRemoveExit(bool)
	return self.PORTAL_REMOVE_EXIT;
end;
function ENT:GetSize()
	local size = self:GetSizeInternal();
	if not size or size == Vector(0, 0, 0) or size.x <= 0 or size.y <= 0 or size.z <= 0 then
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			return Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 8);
		else
			return Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7);
		end;
	end;
	return size;
end;
local outputs = {
	OnEntityTeleportFromMe = true,
	OnEntityTeleportToMe = true,
	OnPlayerTeleportFromMe = true,
	OnPlayerTeleportToMe = true
};
function ENT:GetOpenAmount()
	local currentTime = CurTime();
	local elapsedTime = currentTime - self:GetOpenTime();
	elapsedTime = math.min(elapsedTime, PORTAL_OPEN_DURATION);
	local progress = elapsedTime / PORTAL_OPEN_DURATION;
	return progress;
end;
function ENT:GetStaticAmount()
	local currentTime = CurTime();
	local elapsedTime = currentTime - self:GetStaticTime();
	elapsedTime = math.min(elapsedTime, PORTAL_STATIC_DURATION);
	local progress = elapsedTime / PORTAL_STATIC_DURATION;
	return 1 - progress;
end;
function ENT:SetLinkedPartner(partner)
	if partner:GetClass() ~= self:GetClass() then
		return;
	end;
	if not partner:GetActivated() then
		return;
	end;
	partner:SetStaticTime(CurTime());
	self:SetStaticTime(CurTime());
	self:SetLinkedPartnerInternal(partner);
	partner:SetLinkedPartnerInternal(self);
	GP2.Print("Setting partner for " .. tostring(partner) .. " on portal " .. tostring(self));
end;
function ENT:GetLinkedPartner()
	if self.GetLinkedPartnerInternal then
		return self:GetLinkedPartnerInternal();
	end;
	return nil;
end;
function ENT:GetOther()
	return self:GetLinkedPartner();
end;
function ENT:GetColorVector()
	return self:GetColorVectorInternal();
end;
function ENT:SetPortalColor(r, g, b)
	r = tonumber(r) or 255;
	g = tonumber(g) or 255;
	b = tonumber(b) or 255;
	self:SetColorVectorInternal(Vector(r, g, b));
	self:SetColorVector01Internal(Vector(r * 0.5 / 255, g * 0.5 / 255, b * 0.5 / 255));
end;
function ENT:Fizzle()
	net.Start(GP2.Net.SendPortalClose);
	net.WriteVector(self:GetPos());
	net.WriteAngle(self:GetAngles());
	net.WriteVector(self:GetColorVector() * 0.1);
	net.Broadcast();
	EmitSound(self:GetType() == PORTAL_TYPE_SECOND and "Portal.close_red" or "Portal.close_blue", self:GetPos());
	self:Remove();
end;
function ENT:OnActivated(name, old, new)
	if SERVER then
		self:SetOpenTime(CurTime());
		if new then
			self:EmitSound(self:GetType() == PORTAL_TYPE_SECOND and "Portal.open_red" or "Portal.open_blue");
		end;
	end;
	PortalManager.SetPortal(self:GetLinkageGroup(), self);
end;
function ENT:OnPhysgunPickup(ply, ent)
	return false;
end;
function ENT:OnPhysgunDrop(ply, ent)
	return false;
end;
function ENT:IsHorizontal()
	local p = (self:GetAngles()).p;
	return p == 0;
end;
function ENT:OnFloor()
	local p = (self:GetAngles()).p;
	local r = (self:GetAngles()).r;
	return p == 0 and r == (-90);
end;
function ENT:OnRoof()
	local p = (self:GetAngles()).p;
	return p >= 0 and p <= 180;
end;
function ENT:TransformOffset(v, a1, a2)
	return v:Dot(a1:Right()) * a2:Right() + v:Dot(a1:Up()) * (-a2:Up()) + v:Dot(a1:Forward()) * a2:Forward();
end;
function ENT:GetPortalAngleOffsets(portal, ent)
	local localEyeAngles = self:WorldToLocalAngles(ent:EyeAngles());
	localEyeAngles.p = -localEyeAngles.p;
	localEyeAngles.y = localEyeAngles.y + 180;
	return portal:LocalToWorldAngles(localEyeAngles);
end;
function ENT:GetPortalPosOffsets(portal, ent)
	local offset = ent:GetPos() - self:GetPos();
	local newOffset = self:TransformOffset(offset, self:GetAngles(), portal:GetAngles());
	return portal:GetPos() + newOffset;
end;
function ENT:PlayerWithinBounds(ent, predicting)
	if not IsValid(ent) or (not ent:IsPlayer()) then
		return false;
	end;
	local portalPos = self:GetPos();
	local playerPos = ent:GetPos();
	local distance = portalPos:Distance(playerPos);
	return distance < 100;
end;
function ENT:SetUpEffects(int)
	if not SERVER then
		return;
	end;
	local edgeEnt = ents.Create("info_particle_system");
	if IsValid(edgeEnt) then
		edgeEnt:SetPos(self:GetPos());
		edgeEnt:SetAngles(self:GetAngles());
		edgeEnt:SetParent(self);
		local effectName = self:GetEdgeEffectName(int);
		edgeEnt:SetKeyValue("effect_name", effectName);
		edgeEnt:Spawn();
		edgeEnt:Activate();
		self.EdgeEffect = edgeEnt;
	end;
	local vacuumEnt = ents.Create("info_particle_system");
	if IsValid(vacuumEnt) then
		vacuumEnt:SetPos(self:GetPos());
		vacuumEnt:SetAngles(self:GetAngles());
		vacuumEnt:SetParent(self);
		local vacuumEffect = self:GetVacuumEffectName(int);
		vacuumEnt:SetKeyValue("effect_name", vacuumEffect);
		vacuumEnt:Spawn();
		vacuumEnt:Activate();
		self.VacuumEffect = vacuumEnt;
	end;
end;
function ENT:GetEdgeEffectName(portalType)
	if portalType == TYPE_BLUE then
		return "portal_1_edge";
	elseif portalType == TYPE_ORANGE then
		return "portal_2_edge";
	end;
	return "portal_1_edge";
end;
function ENT:GetVacuumEffectName(portalType)
	if portalType == TYPE_BLUE then
		return "portal_1_vacuum";
	elseif portalType == TYPE_ORANGE then
		return "portal_2_vacuum";
	end;
	return "portal_1_vacuum";
end;
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;
function ENT:Fizzle()
	if CLIENT then
		return;
	end;
	local pos = self:GetPos();
	local ang = self:GetAngles();
	local effectName = self:GetType() == TYPE_ORANGE and "portal_2_close" or "portal_1_close";
	ParticleEffect(effectName, pos, ang, self);
	local soundName = self:GetType() == TYPE_ORANGE and "Portal.close_red" or "Portal.close_blue";
	EmitSound(soundName, pos);
	self:Remove();
end;
local function PlayerPickup(ply, ent)
	if ent:GetClass() == "prop_portal" then
		return false;
	end;
end;
hook.Add("PhysgunPickup", "NoPickupPortalsModular", PlayerPickup);
hook.Add("GravGunPunt", "NoPickupPortalsModular", PlayerPickup);
local PlayerMeta = FindMetaTable("Player");
if not PlayerMeta.SetHeadPos then
	function PlayerMeta:SetHeadPos(pos)
		self:SetPos(pos);
	end;
end;
if not PlayerMeta.GetHeadPos then
	function PlayerMeta:GetHeadPos()
		return self:EyePos();
	end;
end;
local function IsBehind(posA, posB, normal)
	return (posA - posB):Dot(normal) < 0;
end;
if GetConVar("developer") and (GetConVar("developer")):GetInt() > 0 then
	function ENT:DebugInfo()
		print(string.format("Portal %d: Type=%d, Linked=%s, Activated=%s", self:EntIndex(), self:GetType(), tostring(self:IsLinked()), tostring(self:GetActivated())));
	end;
end;
