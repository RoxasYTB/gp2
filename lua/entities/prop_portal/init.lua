-- ----------------------------------------------------------------------------
-- GP2 Framework - Portal Entity (Server)
-- Architecture modulaire combinant nouveau système de rendu et ancien système de téléportation
-- ----------------------------------------------------------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Téléportation des props - Code adapté de l'ancien système
local hitprop = CreateConVar("portal_hitprop","0",FCVAR_ARCHIVE,false)
local vel_roof_max = CreateConVar("portal_velocity_roof", 1000, {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE})

-- Server-side functions from prop_portal.lua
if SERVER then
	function ENT:KeyValue(k, v)
		if k == "Activated" then
			self:SetActivated(tobool(v))
		elseif k == "LinkageGroupID" then
			self:SetLinkageGroup(tonumber(v))
		elseif k == "HalfWidth" then
			local value = tonumber(v) > 0 and tonumber(v) or PORTAL_WIDTH / 2

			local size = self:GetSize()
			if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
				self:SetSize(Vector(size.x, value, 8))
			else
				self:SetSize(Vector(size.x, value, 7))
			end
		elseif k == "HalfHeight" then
			local value = tonumber(v) > 0 and tonumber(v) or PORTAL_HEIGHT / 2

			local size = self:GetSize()
			if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
				self:SetSize(Vector(value, size.y, 8))
			else
				self:SetSize(Vector(value, size.y, 7))
			end
		elseif k == "PortalTwo" then
			self:SetType(tonumber(v))
		elseif outputs[k] then
			self:StoreOutput(k, v)
		end
	end

	function ENT:AcceptInput(name, activator, caller, data)
		name = name:lower()

		if name == "setactivatedstate" then
			self:SetActivated(tobool(data))
			PortalManager.SetPortal(self:GetLinkageGroup(), self)
		elseif name == "setname" then
			self:SetName(data)
		elseif name == "fizzle" then
			self:Fizzle()
		elseif name == "setlinkagegroupid" then
			self:SetLinkageGroup(tonumber(data))
		end
	end
end

local function incrementPortal(ent)
	if CLIENT then
		local size = ent:GetSize()
		ent:SetRenderBounds(-size, size)
	end
	PortalManager.PortalIndex = PortalManager.PortalIndex + 1
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/hunter/plates/plate2x2.mdl")
		local angles = self:GetAngles() + Angle(90, 0, 0)
		angles:RotateAroundAxis(angles:Up(), 180)

		self:SetColor(Color(0, 0, 0, 0))
		self:SetAngles(angles)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)

		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self:SetPos(self:GetPos() + self:GetAngles():Up() * 7.1)
		end
		PortalManager.PortalIndex = PortalManager.PortalIndex + 1

		-- Delay physics mesh creation to ensure entity is fully initialized
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdatePhysmesh()
			end
		end)
	end

	if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		if SERVER and self:GetPlacedByMap() then
			self:BuildPortalEnvironment()
		end
	end

	-- Override portal in LinkageGroup
	PortalManager.SetPortal(self:GetLinkageGroup(), self)
	PortalManager.Portals[self] = true

	-- Initialisation de la téléportation des props
	self.PropTeleportEnabled = true
	self.ClonedEntities = {}
end

if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
	function ENT:BuildPortalEnvironment()
		self.__portalenvironmentphymesh = ents.Create("__portalenvironmentphymesh")
		self.__portalenvironmentphymesh:SetPos(self:GetPos())
		self.__portalenvironmentphymesh:SetPortalAngles(self:GetAngles())
		self.__portalenvironmentphymesh:Spawn()
	end
end

function ENT:OnRemove()
	PortalManager.PortalIndex = math.max(PortalManager.PortalIndex - 1, 0)
	if SERVER and self.PORTAL_REMOVE_EXIT then
		SafeRemoveEntity(self:GetLinkedPartner())
	end

	if CLIENT and IsValid(self.RingParticle) then
		self.RingParticle:StopEmissionAndDestroyImmediately()
	end

	PortalManager.Portals[self] = nil
end

function ENT:UpdatePhysmesh()
	local size = self:GetSize()

	-- Ensure constants are defined
	if not PORTAL_HEIGHT or not PORTAL_WIDTH then
		PORTAL_HEIGHT = PORTAL_HEIGHT or 112
		PORTAL_WIDTH = PORTAL_WIDTH or 64
		GP2.Print("Portal %d: Constants not loaded, using defaults", self:EntIndex())
	end

	-- Validate size before creating physics mesh
	if not size or size == Vector(0,0,0) or size.x <= 0 or size.y <= 0 or size.z <= 0 then
		size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7)
		self:SetSizeInternal(size)
	end
	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		local meshTable = GP2.MakeCubeMesh(size.x, size.y, size.z, false, true)
		self:PhysicsInitConvex(meshTable)
		self:EnableCustomCollisions(true)
	else
		self:PhysicsInit(SOLID_NONE)
	end
end

-- Fonctions de téléportation adaptées de l'ancien système
function ENT:StartTouch(ent)
	-- Filtrage des entités non désirées (copié de l'ancien système)
	if self:ShouldIgnoreEntity(ent) then return end

	-- Vérification des liens
	if not self:IsLinked() or not self:GetActivated() then return end

	-- Gestion différente pour joueurs vs props
	if ent:IsPlayer() then
		self:HandlePlayerTouch(ent)
	elseif self:CanPort(ent) then
		local phys = ent:GetPhysicsObject()
		constraint.AdvBallsocket(ent, game.GetWorld(), 0, 0, Vector(0,0,0), Vector(0,0,0), 0, 0, -180, -180, -180, 180, 180, 180, 0, 0, 1, 1, 1)
		self:MakeClone(ent)
	end
end

function ENT:Touch(ent)
	if ent.InPortal ~= self then self:StartTouch(ent) end
	if not self:CanPort(ent) then return end
	if not self:IsLinked() or not self:GetActivated() then return end
	local portal = self:GetLinkedPartner()
	if portal and portal:IsValid() then
		if ent:IsPlayer() then
			self:HandlePlayerMovement(ent)
		else
			self:SyncClone(ent)
			ent:SetGroundEntity(NULL)
		end
	end
end

function ENT:EndTouch(ent)
	if ent.AlreadyPorted then
		ent.AlreadyPorted = false
	else
		self:DoPort(ent)
	end
end

-- Fonction principale de téléportation (adaptée de l'ancien DoPort)
function ENT:DoPortalTransport(ent)
	if not self:CanPortEntity(ent) then return end
	if not IsValid(ent) then return end

	if SERVER then
		constraint.RemoveConstraints(ent, "AdvBallsocket")
	end

	if not self:IsLinked() or not self:GetActivated() then return end

	local partner = self:GetLinkedPartner()
	if not IsValid(partner) then return end

	if ent:IsPlayer() then
		self:HandlePlayerTeleport(ent, partner)
	else
		-- Téléportation des props
		local vel = ent:GetVelocity()
		if not vel then return end
		local newVel = self:TransformVelocity(vel, partner)
		local phys = ent:GetPhysicsObject()
		if IsValid(partner) and IsValid(phys) and ent.clone and IsValid(ent.clone) then
			if not self:IsBehind(ent:GetPos(), self:GetPos(), self:GetForward()) then
				ent:SetPos(ent.clone:GetPos())
				ent:SetAngles(ent.clone:GetAngles())
				phys:SetVelocity(newVel)
				self:EmitTeleportSound(ent)
			end
			ent.InPortal = nil
			ent.clone:Remove()
			ent.clone = nil
		end
	end
end

-- Gestion spécifique des joueurs (utilise le nouveau système)
function ENT:HandlePlayerTouch(ent)
	if not self:PlayerWithinBounds(ent) then return end
	ent.JustEntered = true
	self:PlayerEnterPortal(ent)
end

function ENT:HandlePlayerMovement(ent)
    if not ent.InPortal then
        if not self:PlayerWithinBounds(ent) then return end
        ent.JustEntered = true
        self:PlayerEnterPortal(ent)
    else
        ent:SetGroundEntity(self)
        local eyepos = ent:EyePos()
        if not self:IsBehind(eyepos, self:GetPos(), self:GetForward()) then
            self:DoPortalTransport(ent)
            ent.AlreadyPorted = true
        end
    end
end

function ENT:HandlePlayerTeleport(ent, partner)
    -- Logique strictement identique à old_prop_portal.lua
    local offset = ent:GetPos() - self:GetPos()
    local newOffset = self:TransformOffset(offset, self:GetAngles(), partner:GetAngles())
    local newPos = partner:GetPos() + newOffset

    -- Transformation des angles (miroir pitch, +180 yaw, repère sortie)
    local localEyeAngles = self:WorldToLocalAngles(ent:EyeAngles())
    localEyeAngles.p = -localEyeAngles.p
    localEyeAngles.y = localEyeAngles.y + 180
    local newang = partner:LocalToWorldAngles(localEyeAngles)

    -- Transformation de la vélocité
    local vel = ent:GetVelocity()
    local newVel = self:TransformOffset(vel, self:GetAngles(), partner:GetAngles()) * -1

    -- Application
    ent:SetPos(newPos)
    ent:SetEyeAngles(newang)
    ent:SetLocalVelocity(newVel)

    -- Sons et effets
    self:EmitTeleportSound(ent)

    -- Flags
    ent.InPortal = nil
    if ent.PortalClone and IsValid(ent.PortalClone) then
        ent.PortalClone:Remove()
        ent.PortalClone = nil
    end
end

-- Gestion des props (nouveau système amélioré)
function ENT:HandlePropTouch(ent)
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		constraint.AdvBallsocket(ent, game.GetWorld(), 0, 0, Vector(0,0,0), Vector(0,0,0),
								0, 0, -180, -180, -180, 180, 180, 180, 0, 0, 1, 1, 1)
		self:MakeClone(ent)
	end
end

-- === Système de clonage et téléportation des props (hérité, adapté) ===
function ENT:CanPort(ent)
    local c = ent:GetClass()
    if ent:IsPlayer() or (ent ~= nil and ent:IsValid() and not ent.isClone and ent:GetPhysicsObject() and c ~= "noportal_pillar" and c ~= "prop_dynamic" and c ~= "rpg_missile" and string.sub(c,1,5) ~= "func_" and string.sub(c,1,9) ~= "prop_door") then
        return true
    else
        return false
    end
end

function ENT:MakeClone(ent)
    if not self:IsLinked() or not self:GetActivated() then return end
    local portal = self:GetLinkedPartner()
    if not IsValid(portal) then return end
    if ent.clone ~= nil then return end
    local clone = ents.Create("prop_physics")
    clone:SetSolid(SOLID_NONE)
    clone:SetPos(self:GetPortalPosOffsets(portal, ent))
    clone:SetAngles(self:GetPortalAngleOffsets(portal, ent))
    clone.isClone = true
    clone.daddyEnt = ent
    clone:SetModel(ent:GetModel())
    clone:Spawn()
    clone:SetSkin(ent:GetSkin())
    clone:SetMaterial(ent:GetMaterial())
    ent:DeleteOnRemove(clone)
    local phy = clone:GetPhysicsObject()
    if phy:IsValid() then
        phy:EnableCollisions(false)
        phy:EnableGravity(false)
        phy:EnableDrag(false)
    end
    ent.clone = clone
    clone.InPortal = portal
end

function ENT:SyncClone(ent)
    local clone = ent.clone
    if not self:IsLinked() or not self:GetActivated() then return end
    if clone == nil then return end
    local portal = self:GetLinkedPartner()
    clone:SetPos(self:GetPortalPosOffsets(portal, ent))
    clone:SetAngles(self:GetPortalAngleOffsets(portal, ent))
end

function ENT:DoPort(ent)
    if not self:CanPort(ent) then return end
    if not ent or not ent:IsValid() then return end
    if SERVER then
        constraint.RemoveConstraints(ent, "AdvBallsocket")
    end
    if not self:IsLinked() or not self:GetActivated() then return end
    local portal = self:GetLinkedPartner()
    --Mahalis code
    local vel = ent:GetVelocity()
    if not vel then return end
    local nuVel = self:TransformOffset(vel, self:GetAngles(), portal:GetAngles()) * -1
    local phys = ent:GetPhysicsObject()
    if portal and portal:IsValid() and phys:IsValid() and ent.clone and IsValid(ent.clone) and not ent:IsPlayer() then
        if not self:IsBehind(ent:GetPos(), self:GetPos(), self:GetForward()) then
            ent:SetPos(ent.clone:GetPos())
            ent:SetAngles(ent.clone:GetAngles())
            phys:SetVelocity(nuVel)
        end
        ent.InPortal = nil
        ent.clone:Remove()
        ent.clone = nil
    end
end

-- Fonctions utilitaires
function ENT:IsLinked()
	return IsValid(self:GetLinkedPartner())
end

function ENT:PlayerWithinBounds(ent)
	return self:GetPos():Distance(ent:GetPos()) < 100
end

function ENT:ShouldIgnoreEntity(ent)
	-- Liste des modèles à ignorer (copiée de l'ancien système)
	local ignoredModels = {
		"models/blackops/portal_sides.mdl",
		"models/blackops/portal_sides_new.mdl",
	}

	for _, model in pairs(ignoredModels) do
		if ent:GetModel() == model then
			return true
		end
	end

	-- Entités spécifiques à ignorer
	local ignoredClasses = {
		"projectile_portal_ball",
		"projectile_portal_ball_atlas",
		"projectile_portal_ball_pbody",
		"projectile_portal_ball_guest",
		"projectile_portal_ball_unknown"
	}

	for _, class in pairs(ignoredClasses) do
		if ent:GetClass() == class then
			ent:SetPos(Vector(-500, -500, -500))
			return true
		end
	end

	-- Si hitprop est activé, ignore certains props PHX
	if hitprop:GetBool() then
		return self:IsPhxProp(ent)
	end

	return false
end

function ENT:IsPhxProp(ent)
	local model = ent:GetModel()
	return string.find(model, "props_phx") or
		   string.find(model, "phxtended") or
		   string.find(model, "hunter/")
end

function ENT:CanPortEntity(ent)
	if not IsValid(ent) then return false end
	if ent.InPortal then return false end
	if self:ShouldIgnoreEntity(ent) then return false end

	return true
end

function ENT:TransformVelocity(vel, targetPortal)
	return self:TransformOffset(vel, self:GetAngles(), targetPortal:GetAngles()) * -1
end

function ENT:TransformOffset(v, a1, a2)
	return (v:Dot(a1:Right()) * a2:Right() + v:Dot(a1:Up()) * (-a2:Up()) + v:Dot(a1:Forward()) * a2:Forward())
end

function ENT:GetPortalAngleOffsets(portal, ent)
	return portal:LocalToWorldAngles(Angle(0, 180, 0))
end

function ENT:GetPortalPosOffsets(portal, ent)
	return portal:GetPos() + portal:GetForward() * 50
end

function ENT:IsBehind(posA, posB, normal)
	return (posA - posB):Dot(normal) < 0
end

function ENT:AdjustVelocityForPortalType(vel, partner)
	local newVel = vel

	if partner:OnFloor() and self:OnFloor() then
		if newVel:Length() < 340 then
			newVel = partner:GetForward() * 340
		end
	elseif partner:OnFloor() then
		if newVel:Length() < 350 then
			newVel = partner:GetForward() * 350
		end
	elseif partner:OnRoof() and (not partner:IsHorizontal()) then
		if newVel:Length() > vel_roof_max:GetInt() then
			newVel = partner:GetForward() * vel_roof_max:GetInt()
		end
	elseif (not partner:IsHorizontal()) and (not partner:OnRoof()) then
		if newVel:Length() < 300 then
			newVel = partner:GetForward() * 300
		end
	end

	return newVel
end

-- Fonctions de détection de type de portail
function ENT:OnFloor()
	local p = self:GetAngles().p
	return p == 0 and self:GetAngles().r == -90
end

function ENT:OnRoof()
	local p = self:GetAngles().p
	return p >= 0 and p <= 180
end

function ENT:IsHorizontal()
	return self:GetAngles().p == 0
end

-- Sons de téléportation
function ENT:EmitTeleportSound(ent)
	if ent:IsPlayer() then
		ent:EmitSound("player/portal_enter" .. math.random(1, 2) .. ".wav", 80,
					 100 + (30 * (ent:GetVelocity():Length() - 450) / 1000))
	end
end

function ENT:PlayerEnterPortal(ent)
	ent.InPortal = self
	self:SetupPlayerClone(ent)

	ent:SetMoveType(MOVETYPE_NOCLIP)
	ent:SetGroundEntity(self)

	if ent.JustEntered then
		self:EmitTeleportSound(ent)
		ent.JustEntered = false
	end
end

function ENT:SetupPlayerClone(ply)
	-- Cette fonction peut être étendue selon vos besoins
	-- Pour l'instant, utilise le système de base si disponible
	if self.BaseSetupPlayerClone then
		self:BaseSetupPlayerClone(ply)
	end
end

function ENT:UpdatePhysmesh()
	local size = self:GetSize()

	-- Ensure constants are defined
	if not PORTAL_HEIGHT or not PORTAL_WIDTH then
		PORTAL_HEIGHT = PORTAL_HEIGHT or 112
		PORTAL_WIDTH = PORTAL_WIDTH or 64
		GP2.Print("Portal %d: Constants not loaded, using defaults", self:EntIndex())
	end

	-- Validate size before creating physics mesh
	if not size or size == Vector(0,0,0) or size.x <= 0 or size.y <= 0 or size.z <= 0 then
		GP2.Print("Portal %d: Invalid size for physics mesh: %s", self:EntIndex(), tostring(size))
		-- Set default size if invalid
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 8)
		else
			size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7)
		end
		self:SetSizeInternal(size)
	end

	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		-- Try different physics initialization methods
		local physicsInitialized = false

		-- Method 1: Try PhysicsInit with SOLID_VPHYSICS
		if not physicsInitialized then
			local success = pcall(self.PhysicsInit, self, SOLID_VPHYSICS)
			if success and IsValid(self:GetPhysicsObject()) then
				physicsInitialized = true
				GP2.Print("Portal %d: Physics initialized with SOLID_VPHYSICS", self:EntIndex())
			end
		end

		-- Method 2: Try PhysicsInitBox as fallback
		if not physicsInitialized then
			local success = pcall(self.PhysicsInitBox, self, -size, size)
			if success and IsValid(self:GetPhysicsObject()) then
				physicsInitialized = true
				GP2.Print("Portal %d: Physics initialized with PhysicsInitBox", self:EntIndex())
			end
		end

		-- Method 3: Try PhysicsInitConvex directly with simple mesh
		if not physicsInitialized then
			local simpleMesh = {
				Vector(-size.x, -size.y, -size.z),
				Vector(-size.x, -size.y,  size.z),
				Vector(-size.x,  size.y, -size.z),
				Vector(-size.x,  size.y,  size.z),
				Vector( size.x, -size.y, -size.z),
				Vector( size.x, -size.y,  size.z),
				Vector( size.x,  size.y, -size.z),
				Vector( size.x,  size.y,  size.z)
			}

			local success = pcall(self.PhysicsInitConvex, self, simpleMesh)
			if success and IsValid(self:GetPhysicsObject()) then
				physicsInitialized = true
				GP2.Print("Portal %d: Physics initialized with simple convex mesh", self:EntIndex())
			end
		end

		if physicsInitialized and IsValid(self:GetPhysicsObject()) then
			-- Now try to create the detailed portal mesh
			local finalMesh = {}
			local sides = 8
			local angleMul = 360 / sides
			local degreeOffset = (sides * 90 + (sides % 4 ~= 0 and 0 or 45)) * (math.pi / 180)
			for side = 1, sides do
				local sidea = math.rad(side * angleMul) + degreeOffset
				local sidex = math.sin(sidea)
				local sidey = math.cos(sidea)
				local side1 = Vector(sidex, sidey, -1)
				local side2 = Vector(sidex, sidey,  0)
				table.insert(finalMesh, side1 * size)
				table.insert(finalMesh, side2 * size)
			end

			-- Try to replace with detailed mesh
			if #finalMesh > 0 then
				local success, err = pcall(self.PhysicsInitConvex, self, finalMesh)
				if success then
					self:EnableCustomCollisions(true)
					local phys = self:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
						phys:SetContents(MASK_OPAQUE_AND_NPCS)
						GP2.Print("Portal %d: Detailed mesh physics created successfully", self:EntIndex())
					end
				else
					GP2.Print("Portal %d: Detailed mesh failed, keeping simple physics: %s", self:EntIndex(), err or "unknown error")
					-- Keep the simple physics that worked
					self:EnableCustomCollisions(true)
					local phys = self:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
						phys:SetContents(MASK_OPAQUE_AND_NPCS)
					end
				end
			end
		else
			GP2.Print("Failure to create a portal physics mesh %d - All methods failed", self:EntIndex())
			-- Disable physics entirely as fallback
			self:SetSolid(SOLID_NONE)
			self:SetMoveType(MOVETYPE_NONE)
		end
	else
		self:PhysicsInit(6) -- Initialize physics as a solid
		if self:GetPhysicsObject():IsValid() then
			local meshSize = size * 2

			-- Calculate the bounds for the mesh with validation
			local x0, x1 = -meshSize.x / 2, meshSize.x / 2
			local y0, y1 = -meshSize.y / 2, meshSize.y / 2
			local z0, z1 = -meshSize.z, meshSize.z

			-- Define the convex quad mesh
			local mesh = {
				Vector(x0, y0, z0),
				Vector(x0, y0, z1),
				Vector(x0, y1, z0),
				Vector(x0, y1, z1),
				Vector(x1, y0, z0),
				Vector(x1, y0, z1),
				Vector(x1, y1, z0),
				Vector(x1, y1, z1)
			}
			-- Validate and create physics mesh
			local success, err = pcall(self.PhysicsInitConvex, self, mesh)
			if not success then
				GP2.Print("Portal %d: New environment PhysicsInitConvex failed: %s", self:EntIndex(), err or "unknown error")
				self:PhysicsDestroy()
			else
				-- Configure physics if successful
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
					phys:SetContents(MASK_OPAQUE_AND_NPCS)
				end
			end
		else
			self:PhysicsDestroy() -- Cleanup on failure
			GP2.Print("Failure to create a portal physics mesh %d - New environment invalid physics object", self:EntIndex())
		end
	end
end

-- hacky bullet fix
if game.SinglePlayer() then
	function ENT:TestCollision(startpos, delta, isbox, extents, mask)
		if bit.band(mask, CONTENTS_GRATE) ~= 0 then return true end
	end
end
