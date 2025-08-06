-- ----------------------------------------------------------------------------
-- GP2 Framework - Portal Entity (Server)
-- Architecture modulaire combinant nouveau système de rendu et ancien système de téléportation
--
-- AMÉLIORATIONS PORTAIL PROPS TÉLÉPORTATION:
-- - Système de clonage basé sur l'ancien système prop_portal
-- - Téléportation des props avec transformation de vélocité correcte (TransformOffset * -1)
-- - Contrainte AdvBallsocket pour empêcher les props de tomber/bouger anormalement
-- - Détection IsBehind pour vérifier le passage complet à travers le portail
-- - Synchronisation en temps réel du clone avec l'entité originale
-- - Sons et effets lors de la téléportation
-- - Compatible avec le système de rendu moderne
-- ----------------------------------------------------------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local outputs = outputs or {}

-- Téléportation des props - Code adapté de l'ancien système
local hitprop = CreateConVar("portal_hitprop", "0", FCVAR_ARCHIVE, "Activer la détection des props par le portail")
local vel_roof_max = CreateConVar("portal_velocity_roof", 1000, {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE})

-- Fonction IsBehind locale (adaptée de l'ancien système)
local function IsBehind(posA, posB, normal)
	local Vec1 = (posB - posA):GetNormalized()
	return (normal:Dot(Vec1) < 0)
end

-- Utilitaire pour obtenir la direction cardinal à partir du yaw
local function GetCardinalFromYaw(yaw)
    yaw = math.NormalizeAngle(yaw)
    if (yaw >= -45 and yaw < 45) then
        return "EAST"
    elseif (yaw >= 45 and yaw < 135) then
        return "NORTH"
    elseif (yaw >= -135 and yaw < -45) then
        return "SOUTH"
    else
        return "WEST"
    end
end

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

	hook.Remove("ShouldCollide", "GP2_DisablePortalPropPhysicsCollision")
	hook.Add("ShouldCollide", "GP2_DisablePortalPropPhysicsCollision", function(ent1, ent2)
		local c1, c2 = ent1:GetClass(), ent2:GetClass()
		if (c1 == "prop_portal" and c2 == "prop_physics") or (c2 == "prop_portal" and c1 == "prop_physics") then
			return false
		end
	end)
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

		-- Sauvegarder les angles d'origine AVANT transformation pour la détection d'orientation
		self.OriginalAngles = self:GetAngles()

		local angles = self:GetAngles() + Angle(90, 0, 0)
		angles:RotateAroundAxis(angles:Up(), 180)
		self:SetColor(Color(0, 0, 0, 200))
		self:SetAngles(angles)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetTrigger(true)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)
		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self:SetPos(self:GetPos() + self:GetAngles():Up() * 7.1)
		end
		PortalManager.PortalIndex = PortalManager.PortalIndex + 1

		-- Stocker position et orientation initiales après 0.3 secondes (inspiré de l'ancien système)
		timer.Simple(0.3, function()
			if IsValid(self) then
				self.StablePos = self:GetPos()
				self.StableAngles = self:GetAngles()

				-- Détermination du type de placement du portail
				local up = self:GetUp()
				if up:Dot(Vector(0,0,1)) > 0.9 then
					self.PlacementType = "FLOOR"
				elseif up:Dot(Vector(0,0,-1)) > 0.9 then
					self.PlacementType = "ROOF"
				else
					self.PlacementType = "WALL"
				end
			end
		end)

		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdatePhysmesh()
				self:SetSolid(SOLID_VPHYSICS)
				self:SetTrigger(true)
				self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
					phys:EnableCollisions(false)
					phys:SetContents(_G.CONTENTS_TRIGGER or 0)
				end
			end
		end)
	end

	if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		if SERVER and self:GetPlacedByMap() then
			self:BuildPortalEnvironment()
		end
	end

	PortalManager.SetPortal(self:GetLinkageGroup(), self)
	PortalManager.Portals[self] = true
	self.PropTeleportEnabled = true
	self.ClonedEntities = {}
	self.SpawnedCubes = {}
	-- Appel différé pour garantir la bonne position
	-- timer.Simple(0, function()
	-- 	if IsValid(self) then
	-- 		self:SpawnWoodenCratesBelow()
	-- 	end
	-- end)
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

	-- Nettoyer tous les clones d'entités associés à ce portail
	self:CleanupAllClones()

	-- Nettoyer les joueurs dans le portail
	self:BootAllPlayers()

	-- Suppression des caisses liées avec un délai pour éviter le bug OOB (wooden crate system)
	if self.SpawnedCubes then
		local cubesToRemove = {}
		for _, cube in ipairs(self.SpawnedCubes) do
			if IsValid(cube) then
				table.insert(cubesToRemove, cube)
			end
		end

		-- Supprimer les caisses après 5 secondes
		timer.Simple(1, function()
			for _, cube in ipairs(cubesToRemove) do
				if IsValid(cube) then
					cube:Remove() -- Commenté volontairement comme dans l'ancien système
				end
			end
		end)
	end

	if SERVER and self.PORTAL_REMOVE_EXIT then
		SafeRemoveEntity(self:GetLinkedPartner())
	end

	if CLIENT and IsValid(self.RingParticle) then
		self.RingParticle:StopEmissionAndDestroyImmediately()
	end

	PortalManager.Portals[self] = nil
end

function ENT:CleanupAllClones()
	-- Parcourir toutes les entités pour nettoyer les clones liés à ce portail
	for _, ent in pairs(ents.GetAll()) do
		if IsValid(ent) and ent.clone and IsValid(ent.clone) and ent.clone.InPortal == self then
			ent.clone:Remove()
			ent.clone = nil
			ent.InPortal = nil
		end
	end
end

function ENT:BootAllPlayers()
	-- Éjecter tous les joueurs du portail
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply.InPortal == self then
			ply.InPortal = nil
			ply:SetMoveType(MOVETYPE_WALK)
			ply:ResetHull()

			if ply.PortalClone and IsValid(ply.PortalClone) then
				ply.PortalClone:Remove()
				ply.PortalClone = nil
			end
		end
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
		size = Vector(PORTAL_HEIGHT / 2, PORTAL_WIDTH / 2, 7)
		self:SetSizeInternal(size)
	end

	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		local meshTable = GP2.MakeCubeMesh(size.x, size.y, size.z, false, true)
		self:PhysicsInitConvex(meshTable)
		self:EnableCustomCollisions(true)

		-- Configuration physique exacte comme l'ancien système
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
			-- Pas de SetContents - laisser par défaut pour que les triggers fonctionnent
		end

		-- S'assurer que le portail reste un trigger comme l'ancien système
		self:SetTrigger(true)
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	else
		self:PhysicsInit(SOLID_NONE)
	end

	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end

function ENT:StartTouch(ent)
	-- Ignorer les modèles de côtés de portail
	if ent:GetModel() == "models/blackops/portal_sides.mdl" then return end
	if ent:GetModel() == "models/blackops/portal_sides_new.mdl" then return end

	-- Système d'immunité temporaire après téléportation (1 seconde)
	if ent.GP2_PortalImmunity and ent.GP2_PortalImmunity > CurTime() then
		return
	end

	-- Détection clone touche portail sans original
	if ent.isClone and ent.daddyEnt and IsValid(ent.daddyEnt) and not ent.daddyEnt.InPortal then
		return
	end

	-- Système de filtrage PHX props (de l'ancien système)
	if hitprop:GetBool() then
		local path = ent:GetModel()
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
				"/hunter/misc/",
			}
			for _, pat in ipairs(ignore_patterns) do
				if string.find(path, pat, 1, true) then return end
			end
		end
	end

	-- Gérer les projectiles portal ball
	local projectileBalls = {
		"projectile_portal_ball",
		"projectile_portal_ball_atlas",
		"projectile_portal_ball_pbody",
		"projectile_portal_ball_guest",
		"projectile_portal_ball_unknown"
	}
	for _, ballClass in pairs(projectileBalls) do
		if ent:GetClass() == ballClass then
			ent:SetPos(Vector(-500,-500,-500))
			return
		end
	end

	-- Vérifier si le portail est lié et activé
	if not self:IsLinked() or not self:GetActivated() then return end

	-- Éviter les touches multiples
	if ent.InPortal then return end

	if ent:IsPlayer() then
		-- Cooldown d'entrée dans le portail pour les joueurs
		local pos
		if not (ent.GP2_PortalCooldown and ent.GP2_PortalCooldown > CurTime()) then
			ent.GP2_PortalCooldown = CurTime() + 1
			pos = ent:GetPos() + self:GetUp() * 20
		else
			pos = ent:GetPos()
		end
		ent:SetPos(pos)
		-- Garder le nouveau système pour les joueurs
		if not self:PlayerWithinBounds(ent) then return end
		ent.JustEntered = true
		self:PlayerEnterPortal(ent)
	elseif self:CanPort(ent) then
		-- Système props amélioré basé sur l'ancien système
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			-- print("[GP2][PORTAL] Prop entre dans le portail:", ent, "- Trigger activé, passage libre!")
			-- Contraindre le prop au monde pour éviter qu'il tombe
			constraint.AdvBallsocket(ent, game.GetWorld(), 0, 0, Vector(0,0,0), Vector(0,0,0),
								0, 0, -180, -180, -180, 180, 180, 180, 0, 0, 1, 1, 1)
			-- Changer temporairement le CollisionGroup pour permettre la traversée
			if ent:GetCollisionGroup() ~= COLLISION_GROUP_PASSABLE_DOOR then
				ent.OriginalCollisionGroup = ent:GetCollisionGroup()
				ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end
			-- Créer immédiatement le clone
			self:MakeClone(ent)
			if ent.clone and IsValid(ent.clone) then
				ent.clone.TouchingPortalsCount = (ent.clone.TouchingPortalsCount or 0) + 1
			end
		end
	end
end

function ENT:Touch(ent)
	-- Système d'immunité temporaire après téléportation (1 seconde)
	if ent.GP2_PortalImmunity and ent.GP2_PortalImmunity > CurTime() then
		return
	end

	-- Éviter les touches multiples sur le même portail
	if ent.InPortal ~= self then
		self:StartTouch(ent)
	end

	-- print("[GP2][PORTAL] Touch détectée pour l'entité:", ent)

	-- Vérifier si l'entité peut être téléportée
	if not self:CanPort(ent) then return end

	-- Vérifier si le portail est lié et activé
	if not self:IsLinked() or not self:GetActivated() then return end

	local portal = self:GetLinkedPartner()
	if not IsValid(portal) then return end

	if ent:IsPlayer() then
		-- Garder le nouveau système pour les joueurs
		if not ent.InPortal then
			if not self:PlayerWithinBounds(ent) then return end
			ent.JustEntered = true
			self:PlayerEnterPortal(ent)
		else
			ent:SetGroundEntity(self)
			-- On ignore la logique IsEntityPassingThrough pour les joueurs
			self:DoPort(ent)
			ent.AlreadyPorted = true
			self:SyncClone(ent)
		end
	else
		-- Système props - Synchroniser le clone en continu
		self:SyncClone(ent)
		ent:SetGroundEntity(NULL)
	end
end

-- Cache pour les transformations de vélocité
local VelocityTransformCache = {}

-- Table pré-calculée pour les transformations mur->mur (optimisation)
local WallToWallTransforms = {
    ["NORTH_NORTH"] = function(v) return Vector(-v.x, -v.y, v.z) end,
    ["NORTH_SOUTH"] = function(v) return Vector(v.x, v.y, v.z) end,
    ["NORTH_EAST"] = function(v) return Vector(-v.y, v.x, v.z) end,
    ["NORTH_WEST"] = function(v) return Vector(v.y, -v.x, v.z) end,
    ["SOUTH_NORTH"] = function(v) return Vector(v.x, v.y, v.z) end,
    ["SOUTH_SOUTH"] = function(v) return Vector(-v.x, -v.y, v.z) end,
    ["SOUTH_EAST"] = function(v) return Vector(v.y, -v.x, v.z) end,
    ["SOUTH_WEST"] = function(v) return Vector(-v.y, v.x, v.z) end,
    ["EAST_NORTH"] = function(v) return Vector(v.y, -v.x, v.z) end,
    ["EAST_SOUTH"] = function(v) return Vector(-v.y, v.x, v.z) end,
    ["EAST_EAST"] = function(v) return Vector(-v.x, -v.y, v.z) end,
    ["EAST_WEST"] = function(v) return Vector(v.x, v.y, v.z) end,
    ["WEST_NORTH"] = function(v) return Vector(-v.y, v.x, v.z) end,
    ["WEST_SOUTH"] = function(v) return Vector(v.y, -v.x, v.z) end,
    ["WEST_EAST"] = function(v) return Vector(v.x, v.y, v.z) end,
    ["WEST_WEST"] = function(v) return Vector(-v.x, -v.y, v.z) end,
}

-- Table pré-calculée pour les transformations sol->mur
local FloorToWallTransforms = {
    [0] = function(v) return Vector(v.z, v.y, 0) end,      -- EAST
    [90] = function(v) return Vector(-v.x, v.z, 0) end,    -- NORTH
    [180] = function(v) return Vector(-v.z, -v.y, 0) end,  -- WEST
    [270] = function(v) return Vector(v.x, -v.z, 0) end,   -- SOUTH
}

function ENT:EndTouch(ent)
    -- Optimisation : vérifications rapides en premier
    if not ent or not ent:IsValid() or ent:IsPlayer() or ent:IsPlayerHolding() then return end
    if not self:CanPort(ent) then return end

    local clone = ent.clone
    if not clone or not IsValid(clone) then
        self:CleanupEntity(ent)
        return
    end

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then
        self:CleanupEntity(ent)
        return
    end

    local portalOut = self:GetLinkedPartner()
    if not IsValid(portalOut) then
        self:CleanupEntity(ent)
        return
    end

    -- Cache des types de placement pour éviter les recalculs
    local placementIn = self.PlacementType or self:GetPlacementType()
    local placementOut = portalOut.PlacementType or portalOut:GetPlacementType()

    -- Téléportation optimisée avec transformation de vélocité
    local success = self:TeleportEntityOptimized(ent, clone, phys, placementIn, placementOut, portalOut)

    -- Nettoyage du clone si l'original ne touche plus le portail
    if ent.clone and IsValid(ent.clone) then
        SafeRemoveEntity(ent.clone)
        ent.clone = nil
    end

    if success then
        self:CleanupEntity(ent)
    end
end

-- Fonction optimisée de téléportation
function ENT:TeleportEntityOptimized(ent, clone, phys, placementIn, placementOut, portalOut)
    local oldVel = phys:GetVelocity()
    if not oldVel then return false end

    local newVel = self:TransformVelocityOptimized(oldVel, placementIn, placementOut, portalOut)
    if not newVel then return false end

    -- Téléportation atomique
    ent:SetPos(clone:GetPos())
    ent:SetAngles(clone:GetAngles())
    phys:SetVelocity(newVel)

    -- Immunité temporaire optimisée (plus courte pour de meilleures performances)
    ent.GP2_PortalImmunity = CurTime() + 0.5

    return true
end

-- Transformation de vélocité optimisée avec cache
function ENT:TransformVelocityOptimized(vel, placementIn, placementOut, portalOut)
    local transformKey = placementIn .. "_" .. placementOut

    -- Transformation sol->sol (simple)
    if transformKey == "FLOOR_FLOOR" then
        return Vector(vel.x, -vel.y, -vel.z)
    end

    -- Transformation mur->mur (utilisation de la table pré-calculée)
    if transformKey == "WALL_WALL" then
        local dirIn = self.CardinalDirection or self:GetCardinalDirection()
        local dirOut = portalOut.CardinalDirection or portalOut:GetCardinalDirection()
        local wallKey = dirIn .. "_" .. dirOut

        local transform = WallToWallTransforms[wallKey]
        return transform and transform(vel) or vel
    end

    -- Transformation mur->sol
    if transformKey == "WALL_FLOOR" then
        local yaw = math.Round((portalOut.StableAngles or portalOut:GetAngles()).y)
        local normalizedYaw = ((yaw % 360) + 360) % 360 -- Normaliser entre 0-359

        -- Mappage aux angles standards
        if normalizedYaw > 315 or normalizedYaw <= 45 then yaw = 0
        elseif normalizedYaw > 45 and normalizedYaw <= 135 then yaw = 90
        elseif normalizedYaw > 135 and normalizedYaw <= 225 then yaw = 180
        else yaw = 270 end

        -- Table de transformation mur->sol (similaire à FloorToWallTransforms mais inversée)
        local WallToFloorTransforms = {
            [0] = function(v) return Vector(-v.y, v.x, -v.y) end,      -- EAST
            [90] = function(v) return Vector(v.x, -v.y, -v.y) end,      -- NORTH
            [180] = function(v) return Vector(v.y, -v.x, -v.y) end,    -- WEST
            [270] = function(v) return Vector(-v.x, -v.y, -v.y) end,   -- SOUTH
        }
        local transform = WallToFloorTransforms[yaw]
        return transform and transform(vel) or Vector(-vel.y, -vel.x, 0)
    end

    -- Transformation sol->mur (utilisation de la table pré-calculée)
    if transformKey == "FLOOR_WALL" then
        local yaw = math.Round((portalOut.StableAngles or portalOut:GetAngles()).y)
        local normalizedYaw = ((yaw % 360) + 360) % 360 -- Normaliser entre 0-359

        -- Mappage aux angles standards
        if normalizedYaw > 315 or normalizedYaw <= 45 then yaw = 0
        elseif normalizedYaw > 45 and normalizedYaw <= 135 then yaw = 90
        elseif normalizedYaw > 135 and normalizedYaw <= 225 then yaw = 180
        else yaw = 270 end

        local transform = FloorToWallTransforms[yaw]
        return transform and transform(vel) or Vector(-vel.y, -vel.x, 0)
    end

    -- Transformation sol->plafond
    if transformKey == "FLOOR_ROOF" then
        return Vector(vel.x, -vel.y, vel.z)
    end

    -- Fallback
    return vel
end

-- Cache des directions cardinales
function ENT:GetCardinalDirection()
    if not self.CardinalDirection then
        local yaw = (self.StableAngles or self:GetAngles()).y
        self.CardinalDirection = GetCardinalFromYaw(yaw)
    end
    return self.CardinalDirection
end

-- Cache des types de placement
function ENT:GetPlacementType()
    if not self.PlacementType then
        local angles = self.OriginalAngles or self:GetAngles()
        if self:IsFloor(angles) then
            self.PlacementType = "FLOOR"
        elseif self:IsCeiling(angles) then
            self.PlacementType = "ROOF"
        else
            self.PlacementType = "WALL"
        end
    end
    return self.PlacementType
end

-- Nettoyage optimisé d'entité
function ENT:CleanupEntity(ent)
    if ent.clone and IsValid(ent.clone) then
        ent.clone.TouchingPortalsCount = (ent.clone.TouchingPortalsCount or 1) - 1
        if ent.clone.TouchingPortalsCount <= 0 then
            SafeRemoveEntity(ent.clone)
        end
    end

    ent.InPortal = nil
    ent.clone = nil

    -- Restaurer le groupe de collision original
    if ent.OriginalCollisionGroup then
        ent:SetCollisionGroup(ent.OriginalCollisionGroup)
        ent.OriginalCollisionGroup = nil
    end

    -- Nettoyage des contraintes en différé pour éviter les lags
    if SERVER then
        timer.Simple(0, function()
            if IsValid(ent) then
                constraint.RemoveConstraints(ent, "AdvBallsocket")
            end
        end)
    end
end

-- Fonction utilitaire pour nettoyer les entités de manière sécurisée
function SafeRemoveEntity(ent)
	if not ent or not IsValid(ent) then return end

	-- Nettoyer les références avant suppression
	if ent.clone then
		ent.clone = nil
	end
	if ent.daddyEnt then
		ent.daddyEnt = nil
	end
	if ent.InPortal then
		ent.InPortal = nil
	end

	-- Suppression différée pour éviter les erreurs
	timer.Simple(0, function()
		if IsValid(ent) then
			ent:Remove()
		end
	end)
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

	-- Éviter les clones multiples
	if ent.clone ~= nil then return end

	-- Créer le clone
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
	clone:SetColor(ent:GetColor())

	-- Lier le clone à l'entité parent
	ent:DeleteOnRemove(clone)

	-- Configuration physique du clone
	local phy = clone:GetPhysicsObject()
	if IsValid(phy) then
		phy:EnableCollisions(false)
		phy:EnableGravity(false)
		phy:EnableDrag(false)
		phy:EnableMotion(false)
	end

	-- Associer le clone
	ent.clone = clone
	clone.InPortal = portal

	-- Ajout d'un compteur de frames sans sync pour le clone
	clone.GP2_NoSyncFrames = 0
end

function ENT:SyncClone(ent)
	local clone = ent.clone

	-- Vérifications rapides d'abord
	if not clone or not IsValid(clone) then return end
	if not self:IsLinked() or not self:GetActivated() then return end

	local portal = self:GetLinkedPartner()
	if not IsValid(portal) then return end

	-- Cache de la transformation pour éviter les recalculs
	local cacheKey = self:EntIndex() .. "_" .. portal:EntIndex()
	if not self.TransformCache then self.TransformCache = {} end

	local transform = self.TransformCache[cacheKey]
	if not transform then
		-- Calculer une seule fois la transformation de coordonnées
		transform = {
			offsetMultiplier = Vector(1, -1, -1),
			angleMultiplier = Vector(1, 1, -1)
		}
		self.TransformCache[cacheKey] = transform
	end

	-- Transformation optimisée de position
	local offset = self:WorldToLocal(ent:GetPos())
	offset:Mul(transform.offsetMultiplier)
	local newPos = portal:LocalToWorld(offset)

	-- Transformation optimisée d'angles
	local newAngles = self:GetPortalAngleOffsets(portal, ent)
	newAngles.r = -newAngles.r

	-- Mise à jour atomique du clone
	clone:SetPos(newPos)
	clone:SetAngles(newAngles)

	-- Synchronisation de vélocité optimisée (seulement côté serveur)
	if SERVER then
		local origPhys = ent:GetPhysicsObject()
		local clonePhys = clone:GetPhysicsObject()
		if IsValid(origPhys) and IsValid(clonePhys) then
			local origVel = origPhys:GetVelocity()
			-- Utiliser la fonction optimisée de transformation de vélocité
			local transformedVel = self:TransformVelocityOptimized(
				origVel,
				self:GetPlacementType(),
				portal:GetPlacementType(),
				portal
			)
			clonePhys:SetVelocity(transformedVel)
		end
	end

	-- Synchronisation des propriétés visuelles (éviter les comparaisons coûteuses)
	clone.GP2_NoSyncFrames = 0

	-- Synchronisation différée des propriétés visuelles pour éviter les appels fréquents
	if not clone.GP2_LastVisualSync or CurTime() - clone.GP2_LastVisualSync > 0.1 then
		self:SyncCloneVisuals(ent, clone)
		clone.GP2_LastVisualSync = CurTime()
	end
end

-- Fonction séparée pour la synchronisation visuelle (appelée moins fréquemment)
function ENT:SyncCloneVisuals(ent, clone)
	local entSkin = ent:GetSkin()
	local entMaterial = ent:GetMaterial()
	local entColor = ent:GetColor()

	if clone:GetSkin() ~= entSkin then
		clone:SetSkin(entSkin)
	end
	if clone:GetMaterial() ~= entMaterial then
		clone:SetMaterial(entMaterial)
	end
	if clone:GetColor() ~= entColor then
		clone:SetColor(entColor)
	end
end

-- Supprimer l'ancienne fonction CheckCloneImmobile qui créait des plastic crates

-- Hook Think optimisé avec limitation de fréquence et cache d'entités
local GP2_CloneCheckCache = {}
local GP2_LastCloneCheck = 0
local GP2_CloneCheckInterval = 0.1 -- Vérifier seulement 10 fois par seconde

hook.Add("Think", "GP2_CloneSyncCheck", function()
	local currentTime = CurTime()

	-- Limiter la fréquence des vérifications pour améliorer les performances
	if currentTime - GP2_LastCloneCheck < GP2_CloneCheckInterval then
		return
	end
	GP2_LastCloneCheck = currentTime

	-- Nettoyer le cache périodiquement (réduire de 1% à 0.1% pour moins de lag spikes)
	if math.random(1, 1000) == 1 then
		GP2_CloneCheckCache = {}
	end

	-- Utiliser cache d'entités au lieu de ents.FindByClass() coûteux à chaque frame
	if not GP2_CloneCheckCache.entities or GP2_CloneCheckCache.lastUpdate < currentTime - 1 then
		GP2_CloneCheckCache.entities = {}
		-- Parcourir seulement les entités clones, pas toutes les prop_*
		for _, ent in ipairs(ents.GetAll()) do
			if ent.isClone then
				table.insert(GP2_CloneCheckCache.entities, ent)
			end
		end
		GP2_CloneCheckCache.lastUpdate = currentTime
	end

	-- Traiter les entités en cache
	for i = #GP2_CloneCheckCache.entities, 1, -1 do
		local ent = GP2_CloneCheckCache.entities[i]
		if IsValid(ent) and ent.GP2_NoSyncFrames ~= nil then
			ent.GP2_NoSyncFrames = ent.GP2_NoSyncFrames + 1

			-- Nettoyage automatique des clones orphelins (optimisation mémoire)
			if ent.GP2_NoSyncFrames > 600 then -- 60 secondes à 10 FPS
				if not ent.daddyEnt or not IsValid(ent.daddyEnt) then
					SafeRemoveEntity(ent)
					table.remove(GP2_CloneCheckCache.entities, i)
				end
			end
		else
			-- Nettoyer les entités invalides du cache
			table.remove(GP2_CloneCheckCache.entities, i)
		end
	end
end)

function ENT:DoPort(ent)
    if not self:CanPort(ent) then return end
    if not ent or not ent:IsValid() then return end

    if SERVER then
        constraint.RemoveConstraints(ent, "AdvBallsocket")
    end

    if not self:IsLinked() or not self:GetActivated() then return end

    local portal = self:GetLinkedPartner()
    if not IsValid(portal) then return end

    if ent:IsPlayer() then
        -- Système joueur (adapté avec logique de l'ancien système)
        local eyepos = ent:EyePos()

        -- Utiliser directement la position stable pour la détection IsBehind des joueurs
        local portalPos = self.StablePos or self:GetPos()
        local portalNormal = self.StableAngles and self.StableAngles:Forward() or self:GetForward()
        local isPlayerBehind = (eyepos - portalPos):Dot(portalNormal) < 0

      --   if not isPlayerBehind then
      --       print("[GP2][PORTAL] Joueur derrière le portail, téléportation!")
      --       -- Téléportation du joueur
      --       local newPos = self:GetPortalPosOffsets(portal, ent)
      --       ent:SetPos(newPos - Vector(0, 0, 64)) -- Ajuster pour la position des pieds

      --       -- Transformation des angles
      --       local newang = self:GetPortalAngleOffsets(portal, ent)
      --       ent:SetEyeAngles(newang)

      --       -- Transformation de la vélocité améliorée
      --       local vel = ent:GetVelocity()
      --       if vel then
      --           local nuVel = self:TransformVelocityBetweenPortals(vel, portal)
      --           ent:SetLocalVelocity(nuVel)
      --       end

      --       -- Appliquer l'immunité temporaire pour éviter les zigzags
      --       ent.GP2_PortalImmunity = CurTime() + 1.0 -- 1 seconde d'immunité
      --       print("[GP2][PORTAL] Immunité portail appliquée pendant 1 seconde pour le joueur:", ent)

      --       -- Gestion du mouvement
      --       ent:SetMoveType(MOVETYPE_FLY)
      --       timer.Create("Walk_" .. ent:EntIndex(), 0.05, 1, function()
      --           if IsValid(ent) then
      --               ent:SetMoveType(MOVETYPE_WALK)
      --               ent:ResetHull()
      --           end
      --       end)

      --       -- Sons de téléportation
      --       if SERVER then
      --           local snd_portal2 = GetConVar("portal_sound") or CreateConVar("portal_sound", "0", FCVAR_ARCHIVE)
      --           if not snd_portal2:GetBool() then
      --               ent:EmitSound("player/portal_exit" .. math.random(1,2) .. ".wav", 80,
	-- 							 100 + (30 * (vel:Length() - 450) / 1000))
      --           else
      --               ent:EmitSound("player/portal2/portal_exit" .. math.random(1,2) .. ".wav", 80,
	-- 							 100 + (30 * (vel:Length() - 450) / 1000))
      --           end
      --       end

      --       -- Flags et nettoyage
      --       ent.JustEntered = false
      --       ent.JustPorted = true
      --       portal:PlayerEnterPortal(ent)
      --   else
		if ent.InPortal == self then
            -- Sortie du portail sans téléportation
            ent.InPortal = nil
            ent:SetMoveType(MOVETYPE_FLY)

            timer.Create("Walk_" .. ent:EntIndex(), 0.05, 1, function()
                if IsValid(ent) then
                    ent:SetMoveType(MOVETYPE_WALK)
                    ent:ResetHull()
                end
            end)

            -- Nettoyer le clone joueur
            if ent.PortalClone and IsValid(ent.PortalClone) then
                ent.PortalClone:Remove()
                ent.PortalClone = nil
            end
        end
    else
        -- Système props avec vélocité améliorée
        local vel = ent:GetVelocity()
        if not vel then return end
        local nuVel = self:TransformVelocityBetweenPortals(vel, portal)
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) and ent.clone and IsValid(ent.clone) then
            if not self:IsBehind(ent:GetPos(), self:GetPos(), self:GetForward()) then
                -- Téléportation effective avec vélocité améliorée
                ent:SetPos(ent.clone:GetPos())
                ent:SetAngles(ent.clone:GetAngles())
                phys:SetVelocity(nuVel)

                -- Appliquer l'immunité temporaire pour éviter les zigzags
                ent.GP2_PortalImmunity = CurTime() + 1.0 -- 1 seconde d'immunité

                ent.InPortal = nil
                ent.clone:Remove()
                ent.clone = nil
            end
        end
    end
end

-- === Transformation de vélocité améliorée entre portails ===
function ENT:IsHorizontal(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles())
	local pitch = math.Round(math.NormalizeAngle(angles.p))
	return math.abs(pitch) < 15
end

-- === Détection précise du type de surface du portail (sol, plafond, mur) ===
function ENT:IsFloor(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles())
	local pitch = math.Round(math.NormalizeAngle(angles.p))
	local roll = math.Round(math.NormalizeAngle(angles.r))
	return math.abs(pitch) < 15 and math.abs(roll) < 15
end

function ENT:IsCeiling(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles())
	local pitch = math.Round(math.NormalizeAngle(angles.p))
	local roll = math.Round(math.NormalizeAngle(angles.r))
	return math.abs(pitch) < 15 and math.abs(math.abs(roll) - 180) < 15
end

function ENT:IsWall(angles)
	angles = angles or (self.OriginalAngles or self:GetAngles())
	local pitch = math.Round(math.NormalizeAngle(angles.p))
	return math.abs(pitch + 90) < 15
end

function ENT:TransformVelocityBetweenPortals(vel, targetPortal)
    local speed = vel:Length()
    local transformedVel = Vector(0, 0, 0)

    local sourceAngles = self.OriginalAngles or self:GetAngles()
    local targetAngles = targetPortal.OriginalAngles or targetPortal:GetAngles()

    local sourceIsFloor = self:IsFloor(sourceAngles)
    local sourceIsCeiling = self:IsCeiling(sourceAngles)
    local sourceIsWall = self:IsWall(sourceAngles)

    local targetIsFloor = targetPortal:IsFloor(targetAngles)
    local targetIsCeiling = targetPortal:IsCeiling(targetAngles)
    local targetIsWall = targetPortal:IsWall(targetAngles)

    if sourceIsFloor and targetIsFloor then
        -- Sol -> Sol
        if vel.z < -50 then
            transformedVel = Vector(vel.x, vel.y, -vel.z)
        else
            transformedVel = targetPortal:GetForward() * speed
        end
    elseif sourceIsFloor and targetIsWall then
        -- Sol -> Mur
        -- Prendre la vélocité horizontale du prop et la projeter sur le plan du mur
        local localVel = self:WorldToLocal(vel)
        -- On ignore la composante verticale (z) pour la sortie murale
        localVel.z = 0
        -- On projette la vélocité sur le plan du mur cible
        local wallVel = targetPortal:LocalToWorld(localVel)
        -- On ajoute une petite impulsion vers l'avant du mur pour éviter de rester collé
        local forward = targetPortal:GetForward()
        transformedVel = wallVel:GetNormalized() * speed + forward * 50
    elseif sourceIsWall and targetIsFloor then
        -- Mur -> Sol
        -- Prendre la vélocité du prop et la projeter sur le plan du sol
        local localVel = self:WorldToLocal(vel)
        -- On ignore la composante latérale (y) pour la sortie sol
        localVel.y = 0
        -- On projette la vélocité sur le plan du sol cible
        local floorVel = targetPortal:LocalToWorld(localVel)
        -- On ajoute une impulsion vers le haut
        local up = targetPortal:GetUp()
        transformedVel = floorVel:GetNormalized() * speed + up * 50
    elseif sourceIsCeiling and targetIsFloor then
        -- Plafond -> Sol
        transformedVel = Vector(vel.x, vel.y, math.abs(vel.z))
    elseif sourceIsCeiling and targetIsCeiling then
        -- Plafond -> Plafond
        transformedVel = targetPortal:GetForward() * speed
    elseif sourceIsCeiling and targetIsWall then
        -- Plafond -> Mur
        transformedVel = targetPortal:GetForward() * speed
    elseif sourceIsWall and targetIsCeiling then
        -- Mur -> Plafond
        transformedVel = targetPortal:GetForward() * speed
    elseif sourceIsWall and targetIsWall then
        -- Mur -> Mur
        transformedVel = targetPortal:GetForward() * speed
    else
        -- Cas par défaut (fallback)
        transformedVel = targetPortal:GetForward() * speed
    end

    if transformedVel:Length() < 100 then
        transformedVel = targetPortal:GetForward() * 250
    end

    return transformedVel
end

-- Fonctions de détection avec angles en paramètres (utilisées par TransformVelocityBetweenPortals)
function ENT:OnFloorWithAngles(angles)
	angles = angles or self:GetAngles()
	local up = angles:Up()
	local forward = angles:Forward()
	local isFloorUp = up.z > 0.7
	local isFloorForward = forward.z > 0.7
	local result = isFloorUp and isFloorForward
	return result
end

function ENT:OnRoofWithAngles(angles)
	angles = angles or self:GetAngles()
	local forward = angles:Forward()
	local result = forward.z < -0.7
	return result
end

-- Fonctions de détection de type de portail (utilisées ailleurs)
function ENT:OnFloor()
	local up = self:GetUp()
	local angles = self:GetAngles()
	-- Un portail au sol a son vecteur Up pointant vers le haut (Z positif)
	-- et sa direction Forward pointant vers le haut aussi
	local isFloorUp = up.z > 0.7 -- Le vecteur Up pointe vers le haut
	local isFloorForward = self:GetForward().z > 0.7 -- Le Forward pointe vers le haut
	local result = isFloorUp and isFloorForward
	return result
end

function ENT:OnRoof()
	local up = self:GetUp()
	local forward = self:GetForward()
	-- Un portail au plafond a son Forward pointant vers le bas
	local result = forward.z < -0.7
	return result
end

function ENT:IsHorizontal()
	return self:GetAngles().p == 0
end

-- Sons de téléportation
function ENT:EmitTeleportSound(ent)
	if ent:IsPlayer() then
		-- ent:EmitSound("player/portal_enter" .. math.random(1, 2) .. ".wav", 80,
		-- 			 100 + (30 * (ent:GetVelocity():Length() - 450) / 1000))
	end
end

function ENT:PlayerEnterPortal(ent)
	-- Marquer que le joueur est dans le portail
	ent.InPortal = self

	-- Configurer le clone du joueur si nécessaire
	self:SetupPlayerClone(ent)

	-- Configurer la physique du joueur pour le passage dans le portail
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableDrag(true)
	end

	-- Changer le type de mouvement
	ent:SetMoveType(MOVETYPE_NOCLIP)
	ent:SetGroundEntity(self)

	-- Gérer les sons et effets d'entrée
	if ent.JustEntered then
		if SERVER then
			local snd_portal2 = GetConVar("portal_sound") or CreateConVar("portal_sound", "0", FCVAR_ARCHIVE)
			local vel = ent:GetVelocity()
			local pitch = 100 + (30 * (vel:Length() - 450) / 1000)

			-- if not snd_portal2:GetBool() then
			-- 	ent:EmitSound("player/portal_enter" .. math.random(1, 2) .. ".wav", 80, pitch)
			-- else
			-- 	ent:EmitSound("player/portal2/portal_enter" .. math.random(1, 2) .. ".wav", 80, pitch)
			-- end
		end

		-- Ajuster la hitbox du joueur pour le passage
		ent:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 72))

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
						phys:SetContents((_G.CONTENTS_SOLID or 0) + (_G.CONTENTS_MOVEABLE or 0) + (_G.CONTENTS_BLOCKLOS or 0)) -- Pas de collisions solides
						GP2.Print("Portal %d: Detailed mesh physics created successfully", self:EntIndex())
					end
				else
					GP2.Print("Portal %d: Detailed mesh failed, keeping simple physics: %s", self:EntIndex(), err or "unknown error")
					-- Keep the simple physics that worked
					self:EnableCustomCollisions(true)
					local phys = self:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
						phys:SetContents((_G.CONTENTS_SOLID or 0) + (_G.CONTENTS_MOVEABLE or 0) + (_G.CONTENTS_BLOCKLOS or 0)) -- Pas de collisions solides
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
					phys:SetContents((_G.CONTENTS_SOLID or 0) + (_G.CONTENTS_MOVEABLE or 0) + (_G.CONTENTS_BLOCKLOS or 0)) -- Pas de collisions solides
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

-- ============================================================================
-- SYSTÈME WOODEN CRATE (Reproduit exactement de l'ancien système)
-- ============================================================================

function ENT:GetGroundZ()
	-- Calculer la position réelle du portail
	local realPortalPos = self:GetPos()

	-- Ajuster selon le système d'environnement utilisé
	if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		-- Compenser l'offset appliqué dans Initialize() avec l'axe réel
		realPortalPos = realPortalPos - self:GetUp() * 7.1
	end

	local tr = util.TraceLine({
		start = realPortalPos,
		endpos = realPortalPos - Vector(0,0,10000),
		filter = self
	})
	return tr.HitPos.z
end

function ENT:SpawnWoodenCratesBelow()
	-- Détection fiable de l'orientation du portail via self:GetUp()
	local up = self:GetUp()
	local isFloor = up:Dot(Vector(0,0,1)) > 0.9
	local isCeiling = up:Dot(Vector(0,0,-1)) > 0.9
	local isWall = not isFloor and not isCeiling

	-- Ne spawner les caisses que si le portail est mural
	if isWall then
		-- Calculer la position réelle du portail en tenant compte des transformations
		local realPortalPos = self:GetPos()

		-- Ajuster selon le système d'environnement utilisé
		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			-- Compenser l'offset appliqué dans Initialize() avec l'axe réel
			realPortalPos = realPortalPos - self:GetUp() * 7.1
		end

		-- Utiliser la position réelle pour le calcul du sol
		local groundZ = self:GetGroundZ()
		local portalPos = realPortalPos
		local basePos = Vector(portalPos.x, portalPos.y, groundZ - 15) -- 15 unités en dessous du sol
		local offsets = {
			Vector(0,0,0), -- centre
			Vector(40,0,0), Vector(-40,0,0), Vector(0,40,0), Vector(0,-40,0),
			Vector(40,40,0), Vector(-40,40,0), Vector(40,-40,0), Vector(-40,-40,0)
		}
		for _, offset in ipairs(offsets) do
			local cube = ents.Create("prop_physics")
			if IsValid(cube) then
				-- Créer une caisse en bois
				cube:SetModel("models/props_junk/wood_crate001a.mdl")
				cube:SetPos(basePos + offset)
				cube:Spawn()
				cube:SetOwner(self)
				cube.InPortalCube = true
				cube.GP2_IsPortalCrate = true

				-- Rendre la caisse complètement transparente
				cube:SetColor(Color(255, 255, 255, 255))
				cube:SetRenderMode(RENDERMODE_TRANSALPHA)

				-- Désactiver collision avec tous les joueurs en rendant la caisse non-solide
				cube:SetSolid(SOLID_NONE)
				cube:SetCollisionGroup(COLLISION_GROUP_WORLD)

				-- Alternative : physique pour les props mais pas pour les joueurs
				timer.Simple(0.1, function()
					if IsValid(cube) then
						cube:SetSolid(SOLID_VPHYSICS)
						cube:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
						-- Hook personnalisé pour cette caisse
						cube.StartTouch = function(self, ent)
							if ent:IsPlayer() then
								-- Ne rien faire, passer à travers
								return
							end
						end
					end
				end)

				local phys = cube:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
					phys:EnableGravity(false)
					phys:SetVelocity(Vector(0,0,0))
					phys:AddAngleVelocity(-phys:GetAngleVelocity())
					phys:SetAngleVelocity(Vector(0,0,0))
					phys:Sleep()
				end
				cube:SetMoveType(MOVETYPE_NONE)
				table.insert(self.SpawnedCubes, cube)
			end
		end
	end
end

function ENT:SpawnCratesBelow()
	-- Version alternative simplifiée (utilisée dans l'ancien fichier pour certains cas)
	local groundZ = self:GetGroundZ()
	local portalPos = self:GetPos()
	local spawnZ = groundZ + 1
	local centerPos = Vector(portalPos.x, portalPos.y, spawnZ)
	local crate = ents.Create("prop_physics")
	crate:SetModel("models/props/wood_crate001a.mdl")
	crate:SetPos(centerPos)
	crate:Spawn()
	crate.GP2_IsPortalCrate = true -- Marqueur pour identification

	-- Désactiver collision avec tous les joueurs existants
	for _, ply in ipairs(player.GetAll()) do
		constraint.NoCollide(crate, ply, 0, 0)
	end
end

if SERVER then
    util.AddNetworkString("GP2_ChatMessage")
    function GP2.SendChatMessage(ply, ...)
        local args = {...}
        net.Start("GP2_ChatMessage")
        net.WriteTable(args)
        if IsValid(ply) then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end
else
    net.Receive("GP2_ChatMessage", function()
        local args = net.ReadTable()
        chat.AddText(unpack(args))
    end)
end

function ENT:IsLinked()
    local partner = self.GetLinkedPartner and self:GetLinkedPartner() or nil
    return IsValid(partner) and partner.GetActivated and partner:GetActivated()
end

