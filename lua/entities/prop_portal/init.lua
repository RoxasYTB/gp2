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

-- Téléportation des props - Code adapté de l'ancien système
local hitprop = CreateConVar("portal_hitprop", "0", FCVAR_ARCHIVE, "Activer la détection des props par le portail")
local vel_roof_max = CreateConVar("portal_velocity_roof", 1000, {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE})

-- Fonction IsBehind locale (adaptée de l'ancien système)
local function IsBehind(posA, posB, normal)
	local Vec1 = (posB - posA):GetNormalized()
	return (normal:Dot(Vec1) < 0)
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
			print("[GP2][PORTAL] ShouldCollide: désactive collision entre", c1, "et", c2)
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
		local angles = self:GetAngles() + Angle(90, 0, 0)
		angles:RotateAroundAxis(angles:Up(), 180)

		self:SetColor(Color(0, 0, 0, 200))
		self:SetAngles(angles)

		-- Configuration similaire à l'ancien système pour permettre le passage des props
		self:PhysicsInit(SOLID_VPHYSICS) -- Utiliser SOLID_VPHYSICS comme l'ancien
		self:SetSolid(SOLID_VPHYSICS)
		self:SetTrigger(true) -- CRUCIAL : Permet aux props de passer à travers !
		self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) -- Groupe de collision passable
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)

		if not PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self:SetPos(self:GetPos() + self:GetAngles():Up() * 7.1)
		end
		PortalManager.PortalIndex = PortalManager.PortalIndex + 1

		-- Delay physics mesh creation to ensure entity is fully initialized
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdatePhysmesh()
				-- Configurer le portail comme trigger pour permettre le passage
				self:SetSolid(SOLID_VPHYSICS)
				self:SetTrigger(true)
				self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				print("COLLISION_GROUP_PASSABLE_DOOR appliqué au portail:", self)

				-- Configurer la physique pour être passable mais détecter les triggers
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
					phys:EnableCollisions(false) -- Pas de collisions physiques solides
					phys:SetContents(CONTENTS_TRIGGER) -- Contenu trigger uniquement
				end
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

	-- Nettoyer tous les clones d'entités associés à ce portail
	self:CleanupAllClones()

	-- Nettoyer les joueurs dans le portail
	self:BootAllPlayers()

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

		print("[GP2][PORTAL] Portail configuré comme trigger - Props peuvent passer à travers!")
	else
		self:PhysicsInit(SOLID_NONE)
	end

	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end

function ENT:StartTouch(ent)
	-- Ignorer les modèles de côtés de portail
	if ent:GetModel() == "models/blackops/portal_sides.mdl" then return end
	if ent:GetModel() == "models/blackops/portal_sides_new.mdl" then return end

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
		-- Garder le nouveau système pour les joueurs
		if not self:PlayerWithinBounds(ent) then return end
		ent.JustEntered = true
		self:PlayerEnterPortal(ent)
	elseif self:CanPort(ent) then
		-- Système props amélioré basé sur l'ancien système
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			print("[GP2][PORTAL] Prop entre dans le portail:", ent, "- Trigger activé, passage libre!")
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
		end
	end
end

function ENT:Touch(ent)
	-- Éviter les touches multiples sur le même portail
	if ent.InPortal ~= self then
		self:StartTouch(ent)
	end

	print("[GP2][PORTAL] Touch détectée pour l'entité:", ent)

	-- Vérifier si l'entité peut être téléportée
	if not self:CanPort(ent) then return end

	-- Vérifier si le portail est lié et activé
	if not self:IsLinked() or not self:GetActivated() then return end

	local portal = self:GetLinkedPartner()
	if not IsValid(portal) then return end

	if ent:IsPlayer() then
		-- Système joueur (nouveau système gardé)
		if not ent.InPortal then
			if not self:PlayerWithinBounds(ent) then return end
			ent.JustEntered = true
			self:PlayerEnterPortal(ent)
		else
			ent:SetGroundEntity(self)
			local eyepos = ent:EyePos()
			-- Utiliser la fonction IsBehind locale
			if not IsBehind(eyepos, self:GetPos(), self:GetForward()) then
				self:DoPort(ent)
				ent.AlreadyPorted = true
			end
		end
	else
		-- Système props - Synchroniser le clone en continu
		self:SyncClone(ent)
		ent:SetGroundEntity(NULL)
	end
end

function ENT:EndTouch(ent)
	-- Gérer la logique de fin de contact comme dans l'ancien système
	if not self:CanPort(ent) then return end
	if not ent or not ent:IsValid() then return end

	-- Vérifier si le prop a traversé le plan du portail avant de téléporter
	if ent.clone and IsValid(ent.clone) then
		if not self:IsBehind(ent:GetPos(), self:GetPos(), self:GetForward()) then
			self:DoPort(ent)
			print("[GP2][PORTAL] Prop téléporté via EndTouch:", ent)
		end
		-- Nettoyer le clone après la téléportation ou la sortie
		if ent.clone and IsValid(ent.clone) then
			ent.clone:Remove()
			ent.clone = nil
		end
	end
	-- Reset le flag InPortal
	ent.InPortal = nil
	-- Restaurer le CollisionGroup d'origine si besoin
	if ent.OriginalCollisionGroup then
		print("COLLISION_GROUP_PASSABLE_DOOR retiré du portail:", self)
		-- Remettre le CollisionGroup original
		ent:SetCollisionGroup(ent.OriginalCollisionGroup)
		print("[GP2][PORTAL] CollisionGroup restauré pour l'entité:", ent, "à", ent.OriginalCollisionGroup)
		ent.OriginalCollisionGroup = nil
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

	-- Envoyer un message réseau pour le rendu côté client (si nécessaire)
	if SERVER then
		-- Vous pouvez ajouter ici une notification réseau si le côté client en a besoin
		-- umsg.Start("Portal:ObjectInPortal")
		-- umsg.Entity(portal)
		-- umsg.Entity(clone)
		-- umsg.End()
	end
end

function ENT:SyncClone(ent)
	local clone = ent.clone
	if not self:IsLinked() or not self:GetActivated() then return end
	if not IsValid(clone) then return end

	local portal = self:GetLinkedPartner()
	if not IsValid(portal) then return end

	-- Mettre à jour la position et les angles du clone en temps réel
	local newPos = self:GetPortalPosOffsets(portal, ent)
	local newAngles = self:GetPortalAngleOffsets(portal, ent)

	clone:SetPos(newPos)
	clone:SetAngles(newAngles)

	-- Synchroniser les propriétés visuelles si elles ont changé
	if clone:GetSkin() ~= ent:GetSkin() then
		clone:SetSkin(ent:GetSkin())
	end
	if clone:GetMaterial() ~= ent:GetMaterial() then
		clone:SetMaterial(ent:GetMaterial())
	end
	if clone:GetColor() ~= ent:GetColor() then
		clone:SetColor(ent:GetColor())
	end
end

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

		if not self:IsBehind(eyepos, self:GetPos(), self:GetForward()) then
			-- Téléportation du joueur
			local newPos = self:GetPortalPosOffsets(portal, ent)
			ent:SetPos(newPos - Vector(0, 0, 64)) -- Ajuster pour la position des pieds

			-- Transformation des angles
			local newang = self:GetPortalAngleOffsets(portal, ent)
			ent:SetEyeAngles(newang)

			-- Transformation de la vélocité
			local vel = ent:GetVelocity()
			if vel then
				local nuVel = self:TransformOffset(vel, self:GetAngles(), portal:GetAngles()) * -1
				ent:SetLocalVelocity(nuVel)
			end

			-- Gestion du mouvement
			ent:SetMoveType(MOVETYPE_FLY)
			timer.Create("Walk_" .. ent:EntIndex(), 0.05, 1, function()
				if IsValid(ent) then
					ent:SetMoveType(MOVETYPE_WALK)
					ent:ResetHull()
				end
			end)

			-- Sons de téléportation
			if SERVER then
				local snd_portal2 = GetConVar("portal_sound") or CreateConVar("portal_sound", "0", FCVAR_ARCHIVE)
				if not snd_portal2:GetBool() then
					ent:EmitSound("player/portal_exit" .. math.random(1,2) .. ".wav", 80,
								 100 + (30 * (vel:Length() - 450) / 1000))
				else
					ent:EmitSound("player/portal2/portal_exit" .. math.random(1,2) .. ".wav", 80,
								 100 + (30 * (vel:Length() - 450) / 1000))
				end
			end

			-- Flags et nettoyage
			ent.JustEntered = false
			ent.JustPorted = true
			portal:PlayerEnterPortal(ent)
		elseif ent.InPortal == self then
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
		-- Système props (logique exacte de l'ancien système)
		local vel = ent:GetVelocity()
		if not vel then return end

		-- Transformation de vélocité exacte de l'ancien système
		local nuVel = self:TransformOffset(vel, self:GetAngles(), portal:GetAngles()) * -1
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) and ent.clone and IsValid(ent.clone) then
			-- Vérifier si le prop a traversé le portail (utilise fonction locale IsBehind)
			if not self:IsBehind(ent:GetPos(), self:GetPos(), self:GetForward()) then
				-- Téléportation effective
				ent:SetPos(ent.clone:GetPos())
				ent:SetAngles(ent.clone:GetAngles())

				-- Ajuster la vélocité selon l'orientation du portail
				local adjustedVel = self:AdjustVelocityForPortalType(nuVel, portal)
				phys:SetVelocity(adjustedVel)

				print("[GP2][PORTAL] Prop téléporté:", ent, "vers", ent.clone:GetPos(), "avec vélocité:", adjustedVel)

				-- Restaurer immédiatement la collision solide avec le monde
				if ent.OriginalCollisionGroup then
					ent:SetCollisionGroup(ent.OriginalCollisionGroup)
					print("[GP2][PORTAL] Collision restaurée pour prop:", ent, "à", ent.OriginalCollisionGroup)
				else
					-- Par défaut, collision normale avec le monde (solide)
					ent:SetCollisionGroup(COLLISION_GROUP_NONE)
					print("[GP2][PORTAL] Collision normale restaurée pour prop:", ent)
				end
				ent.OriginalCollisionGroup = nil
			end

			-- Nettoyer après téléportation
			ent.InPortal = nil
			ent.clone:Remove()
			ent.clone = nil
		end
	end
end

-- === Fonctions utilitaires héritées de l'ancien système ===
function ENT:TransformOffset(v, a1, a2)
	return (v:Dot(a1:Right()) * a2:Right() + v:Dot(a1:Up()) * (-a2:Up()) + v:Dot(a1:Forward()) * a2:Forward())
end

function ENT:GetPortalAngleOffsets(portal, ent)
	local angles = ent:GetAngles()

	local normal = self:GetForward()
	local forward = angles:Forward()
	local up = angles:Up()

	-- reflect forward
	local dot = forward:DotProduct(normal)
	forward = forward + (-2 * dot) * normal

	-- reflect up
	local dot = up:DotProduct(normal)
	up = up + (-2 * dot) * normal

	-- convert to angles
	angles = math.VectorAngles(forward, up)

	local LocalAngles = self:WorldToLocalAngles(angles)

	-- repair
	LocalAngles.y = -LocalAngles.y
	LocalAngles.r = -LocalAngles.r

	return portal:LocalToWorldAngles(LocalAngles)
end

function ENT:GetPortalPosOffsets(portal, ent)
	local pos
	if ent:IsPlayer() then
		pos = ent:EyePos() -- Utiliser EyePos pour les joueurs
	else
		pos = ent:GetPos()
	end

	local offset = self:WorldToLocal(pos)

	if ent:IsPlayer() then
		offset.x = -offset.x
		offset.y = -offset.y
	else
		offset.x = -offset.x
		offset.y = -offset.y
	end

	local output = portal:LocalToWorld(offset)

	-- Ajustement pour les joueurs si nécessaire
	if ent:IsPlayer() and SERVER then
		-- Ajouter un offset de sol si nécessaire (simplifié)
		return output
	else
		return output
	end
end

function ENT:IsBehind(posA, posB, normal)
	local Vec1 = (posB - posA):GetNormalized()
	return (normal:Dot(Vec1) < 0)
end

-- Crée un tunnel invisible sous le portail pour désactiver les collisions du sol
function ENT:CreateTunnelBelowPortal()
    -- Fonction simplifiée - pas besoin de créer d'entité physique
    -- Le système de ballsocket gère déjà les collisions
end

function ENT:RemoveTunnelBelowPortal()
    -- Fonction simplifiée - nettoie juste le flag
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

function ENT:GetPortalPosOffsets(portal, ent)
	-- Calculer l'offset de l'entité par rapport à ce portail
	local offset = ent:GetPos() - self:GetPos()

	-- Appliquer une symétrie miroir sur l'axe latéral (Right)
	local localOffset = self:WorldToLocal(ent:GetPos())
	localOffset.x = localOffset.x -- effet miroir sur l'axe latéral
	localOffset.y = -localOffset.y -- effet miroir sur l'axe latéral
	localOffset.z = -localOffset.z -- garder la hauteur inchangée
	local mirroredWorldOffset = portal:LocalToWorld(localOffset)

	-- Position finale du clone = position portail de sortie + offset miroir
	local finalPos = mirroredWorldOffset

	-- Ajuster légèrement la position pour éviter les intersections
	finalPos = finalPos

	return finalPos
end

function ENT:GetPortalAngleOffsets(portal, ent)
	-- Calculer les angles relatifs de l'entité par rapport à ce portail
	local localAngles = self:WorldToLocalAngles(ent:GetAngles())

	-- Appliquer une symétrie miroir sur l'axe Yaw (effet miroir)
	localAngles.y = -localAngles.y + 180
	localAngles.r = -localAngles.r + 180

	-- Convertir vers les angles mondiaux du portail de sortie
	local finalAngles = portal:LocalToWorldAngles(localAngles)

	return finalAngles
end

function ENT:IsBehind(posA, posB, normal)
	return (posA - posB):Dot(normal) < 0
end

function ENT:AdjustVelocityForPortalType(vel, partner)
	local newVel = vel
	local speed = vel:Length()

	-- Vitesse minimale pour maintenir le momentum
	local minSpeed = 200
	local maxSpeed = vel_roof_max:GetInt()

	-- Ajustements selon l'orientation des portails
	if partner:OnFloor() and self:OnFloor() then
		-- Portail au sol vers portail au sol : garder momentum horizontal
		if speed < 340 then
			newVel = partner:GetForward() * math.max(340, speed)
		end
	elseif partner:OnFloor() and not self:OnFloor() then
		-- Portail mural vers portail au sol : convertir momentum vertical en horizontal
		if speed < 350 then
			newVel = partner:GetForward() * math.max(350, speed)
		end
	elseif not partner:OnFloor() and self:OnFloor() then
		-- Portail au sol vers portail mural : convertir momentum horizontal en vertical
		if speed < minSpeed then
			newVel = partner:GetForward() * math.max(minSpeed, speed)
		end
	elseif partner:OnRoof() and (not partner:IsHorizontal()) then
		-- Portail plafond : limiter la vitesse pour éviter les bugs
		if speed > maxSpeed then
			newVel = partner:GetForward() * maxSpeed
		elseif speed < minSpeed then
			newVel = partner:GetForward() * minSpeed
		end
	elseif (not partner:IsHorizontal()) and (not partner:OnRoof()) then
		-- Portail mural standard : vitesse minimale
		if speed < 300 then
			newVel = partner:GetForward() * math.max(300, speed)
		end
	else
		-- Cas par défaut : maintenir une vitesse minimale
		if speed < minSpeed then
			newVel = partner:GetForward() * minSpeed
		end
	end

	print("[GP2][PORTAL] Vélocité ajustée de", speed, "à", newVel:Length(), "pour orientation:",
		  self:OnFloor() and "sol" or (self:OnRoof() and "plafond" or "mur"), "vers",
		  partner:OnFloor() and "sol" or (partner:OnRoof() and "plafond" or "mur"))

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
	ent:SetMoveType(MOVETYPE_WALK)
	ent:SetGroundEntity(self)

	-- Gérer les sons et effets d'entrée
	if ent.JustEntered then
		if SERVER then
			local snd_portal2 = GetConVar("portal_sound") or CreateConVar("portal_sound", "0", FCVAR_ARCHIVE)
			local vel = ent:GetVelocity()
			local pitch = 100 + (30 * (vel:Length() - 450) / 1000)

			if not snd_portal2:GetBool() then
				ent:EmitSound("player/portal_enter" .. math.random(1,2) .. ".wav", 80, pitch)
			else
				ent:EmitSound("player/portal2/portal_enter" .. math.random(1,2) .. ".wav", 80, pitch)
			end
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
						phys:SetContents(CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_BLOCKLOS) -- Pas de collisions solides
						GP2.Print("Portal %d: Detailed mesh physics created successfully", self:EntIndex())
					end
				else
					GP2.Print("Portal %d: Detailed mesh failed, keeping simple physics: %s", self:EntIndex(), err or "unknown error")
					-- Keep the simple physics that worked
					self:EnableCustomCollisions(true)
					local phys = self:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
						phys:SetContents(CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_BLOCKLOS) -- Pas de collisions solides
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
					phys:SetContents(CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_BLOCKLOS) -- Pas de collisions solides
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

