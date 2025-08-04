-- ----------------------------------------------------------------------------
-- GP2 Framework - Portal Entity (Shared)
-- Architecture modulaire combinant nouveau système de rendu et ancien système de téléportation
-- ----------------------------------------------------------------------------

-- Entity registration with proper Garry's Mod entity structure
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "Portal 2"
ENT.PrintName = "Portal"
ENT.Author = "GP2 Framework"
ENT.Information = "Portal entity from Portal 2"
ENT.Contact = ""
ENT.Contents = MASK_OPAQUE_AND_NPCS

-- Ensure entity is properly registered
ENT.ClassName = "prop_portal"
ENT.Folder = "entities"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", "Activated")
	self:NetworkVar("Bool", "PlacedByMap")
	self:NetworkVar("Entity", "LinkedPartnerInternal")
	self:NetworkVar("Vector", "SizeInternal")
	self:NetworkVar("Int", "SidesInternal")
	self:NetworkVar("Int", "Type")
	self:NetworkVar("Int", "LinkageGroup")
	self:NetworkVar("Float", "OpenTime")
	self:NetworkVar("Float", "StaticTime")
	self:NetworkVar("Vector", "ColorVectorInternal")
	self:NetworkVar("Vector", "ColorVector01Internal")

	if SERVER then
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self:SetSize(Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 8))
		else
			self:SetSize(Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7))
		end
		self:SetColorVectorInternal(Vector(255,255,255))
		self:SetPlacedByMap(true)
	end

	self:NetworkVarNotify("Activated", self.OnActivated)
end

-- custom size for portal
function ENT:SetSize(n)
	-- Validate input
	if not n or n == Vector(0,0,0) or n.x <= 0 or n.y <= 0 or n.z <= 0 then
		GP2.Print("Portal %d: Invalid size provided: %s", self:EntIndex(), tostring(n))
		return
	end

	self:SetSizeInternal(n)
	-- Only update physics mesh if we're on the server and entity is initialized
	if SERVER and self:GetClass() == "prop_portal" then
		self:UpdatePhysmesh()
	end
end

function ENT:SetRemoveExit(bool)
	self.PORTAL_REMOVE_EXIT = bool
end

function ENT:GetRemoveExit(bool)
	return self.PORTAL_REMOVE_EXIT
end

function ENT:GetSize()
	local size = self:GetSizeInternal()

	-- Return default size if not set or invalid
	if not size or size == Vector(0,0,0) or size.x <= 0 or size.y <= 0 or size.z <= 0 then
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			return Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 8)
		else
			return Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7)
		end
	end

	return size
end

local outputs = {
	["OnEntityTeleportFromMe"] = true,
	["OnEntityTeleportToMe"] = true,
	["OnPlayerTeleportFromMe"] = true,
	["OnPlayerTeleportToMe"] = true,
}

function ENT:GetOpenAmount()
	local currentTime = CurTime()
	local elapsedTime = currentTime - self:GetOpenTime()
	elapsedTime = math.min(elapsedTime, PORTAL_OPEN_DURATION)
	local progress = elapsedTime / PORTAL_OPEN_DURATION
	return progress
end

function ENT:GetStaticAmount()
	local currentTime = CurTime()
	local elapsedTime = currentTime - self:GetStaticTime()
	elapsedTime = math.min(elapsedTime, PORTAL_STATIC_DURATION)
	local progress = elapsedTime / PORTAL_STATIC_DURATION
	return 1 - progress
end

function ENT:SetLinkedPartner(partner)
	if partner:GetClass() ~= self:GetClass() then
		return
	end

	if not partner:GetActivated() then
		return
	end

	partner:SetStaticTime(CurTime())
	self:SetStaticTime(CurTime())
	self:SetLinkedPartnerInternal(partner)
	partner:SetLinkedPartnerInternal(self)

	GP2.Print("Setting partner for " .. tostring(partner) .. " on portal " .. tostring(self))
end

function ENT:GetLinkedPartner()
	return self:GetLinkedPartnerInternal()
end

function ENT:GetColorVector()
	return self:GetColorVectorInternal()
end

--- Sets portal color (vector and color version)
---@param r number: red component
---@param g number: green component
---@param b number: blue component
function ENT:SetPortalColor(r, g, b)
	r = tonumber(r) or 255
	g = tonumber(g) or 255
	b = tonumber(b) or 255
	self:SetColorVectorInternal(Vector(r, g, b))
	self:SetColorVector01Internal(Vector(r * 0.5 / 255, g * 0.5 / 255, b * 0.5 / 255))
end

function ENT:Fizzle()
	net.Start(GP2.Net.SendPortalClose)
		net.WriteVector(self:GetPos())
		net.WriteAngle(self:GetAngles())
		net.WriteVector(self:GetColorVector() * 0.1)
	net.Broadcast()

	EmitSound(self:GetType() == PORTAL_TYPE_SECOND and "Portal.close_red" or "Portal.close_blue", self:GetPos())

	self:Remove()
end

function ENT:OnActivated(name, old, new)
	if SERVER then
		self:SetOpenTime(CurTime())

		if new then
			self:EmitSound(self:GetType() == PORTAL_TYPE_SECOND and "Portal.open_red" or "Portal.open_blue")
		end
	end

	-- Override portal in LinkageGroup after activation change
	PortalManager.SetPortal(self:GetLinkageGroup(), self)
end

function ENT:OnPhysgunPickup(ply, ent)
    return false
end

function ENT:OnPhysgunDrop(ply, ent)
    return false
end

-- Fonctions géométriques (de l'ancien système)
function ENT:IsHorizontal()
    local p = self:GetAngles().p
    return p == 0
end

function ENT:OnFloor()
    local p = self:GetAngles().p
    local r = self:GetAngles().r
    return p == 0 and r == -90
end

function ENT:OnRoof()
    local p = self:GetAngles().p
    return p >= 0 and p <= 180
end

-- Fonctions de transformation (de l'ancien système - Mahalis code)
function ENT:TransformOffset(v, a1, a2)
    return (v:Dot(a1:Right()) * a2:Right() + v:Dot(a1:Up()) * (-a2:Up()) + v:Dot(a1:Forward()) * a2:Forward())
end

function ENT:GetPortalAngleOffsets(portal, ent)
    -- Ancienne logique : miroir sur le pitch, +180° sur le yaw, repère du portail de sortie
    local localEyeAngles = self:WorldToLocalAngles(ent:EyeAngles())
    localEyeAngles.p = -localEyeAngles.p
    localEyeAngles.y = localEyeAngles.y + 180
    return portal:LocalToWorldAngles(localEyeAngles)
end

function ENT:GetPortalPosOffsets(portal, ent)
    local offset = ent:GetPos() - self:GetPos()
    local newOffset = self:TransformOffset(offset, self:GetAngles(), portal:GetAngles())
    return portal:GetPos() + newOffset
end

-- Fonctions de bounds checking (simplifiées)
function ENT:PlayerWithinBounds(ent, predicting)
    if not IsValid(ent) or not ent:IsPlayer() then return false end

    local portalPos = self:GetPos()
    local playerPos = ent:GetPos()
    local distance = portalPos:Distance(playerPos)

    return distance < 100 -- Distance simple pour la compatibilité
end

-- Fonctions d'effets (compatibilité avec l'ancien système)
function ENT:SetUpEffects(int)
    if not SERVER then return end

    -- Création des effets de bord
    local edgeEnt = ents.Create("info_particle_system")
    if IsValid(edgeEnt) then
        edgeEnt:SetPos(self:GetPos())
        edgeEnt:SetAngles(self:GetAngles())
        edgeEnt:SetParent(self)

        -- Sélection de l'effet selon le type
        local effectName = self:GetEdgeEffectName(int)
        edgeEnt:SetKeyValue("effect_name", effectName)
        edgeEnt:Spawn()
        edgeEnt:Activate()

        self.EdgeEffect = edgeEnt
    end

    -- Création des effets de vacuum
    local vacuumEnt = ents.Create("info_particle_system")
    if IsValid(vacuumEnt) then
        vacuumEnt:SetPos(self:GetPos())
        vacuumEnt:SetAngles(self:GetAngles())
        vacuumEnt:SetParent(self)

        local vacuumEffect = self:GetVacuumEffectName(int)
        vacuumEnt:SetKeyValue("effect_name", vacuumEffect)
        vacuumEnt:Spawn()
        vacuumEnt:Activate()

        self.VacuumEffect = vacuumEnt
    end
end

function ENT:GetEdgeEffectName(portalType)
    -- Mappage simplifié des effets de bord
    if portalType == TYPE_BLUE then
        return "portal_1_edge"
    elseif portalType == TYPE_ORANGE then
        return "portal_2_edge"
    end
    return "portal_1_edge"
end

function ENT:GetVacuumEffectName(portalType)
    -- Mappage simplifié des effets de vacuum
    if portalType == TYPE_BLUE then
        return "portal_1_vacuum"
    elseif portalType == TYPE_ORANGE then
        return "portal_2_vacuum"
    end
    return "portal_1_vacuum"
end

-- Fonctions de mise à jour (du nouveau système)
function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

-- Fonction de fermeture avec effets
function ENT:Fizzle()
    if CLIENT then return end

    local pos = self:GetPos()
    local ang = self:GetAngles()

    -- Effet de particules de fermeture
    local effectName = self:GetType() == TYPE_ORANGE and "portal_2_close" or "portal_1_close"
    ParticleEffect(effectName, pos, ang, self)

    -- Son de fermeture
    local soundName = self:GetType() == TYPE_ORANGE and "Portal.close_red" or "Portal.close_blue"
    EmitSound(soundName, pos)

    self:Remove()
end

-- Protection contre le pickup (de l'ancien système)
local function PlayerPickup(ply, ent)
    if ent:GetClass() == "prop_portal" then
        return false
    end
end

hook.Add("PhysgunPickup", "NoPickupPortalsModular", PlayerPickup)
hook.Add("GravGunPunt", "NoPickupPortalsModular", PlayerPickup)

-- Métafunctions pour le joueur (compatibilité avec l'ancien système)
local PlayerMeta = FindMetaTable("Player")

if not PlayerMeta.SetHeadPos then
    function PlayerMeta:SetHeadPos(pos)
        self:SetPos(pos)
    end
end

if not PlayerMeta.GetHeadPos then
    function PlayerMeta:GetHeadPos()
        return self:EyePos()
    end
end

-- Fonction utilitaire pour vérifier si une position est derrière
local function IsBehind(posA, posB, normal)
    return (posA - posB):Dot(normal) < 0
end

-- Fonctions de debug (optionnelles)
if GetConVar("developer") and GetConVar("developer"):GetInt() > 0 then
    function ENT:DebugInfo()
        print(string.format("Portal %d: Type=%d, Linked=%s, Activated=%s",
              self:EntIndex(),
              self:GetType(),
              tostring(self:IsLinked()),
              tostring(self:GetActivated())))
    end
end
 