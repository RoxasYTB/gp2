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
				print("[GP2][PORTAL][DEBUG] Position portail:", self.StablePos)
				print("[GP2][PORTAL][DEBUG] Angles portail:", self.StableAngles)
				print("[GP2][PORTAL][DEBUG] Pitch:", self.StableAngles.p, "Yaw:", self.StableAngles.y, "Roll:", self.StableAngles.r)
			end
		end)

		timer.Simple(0.1, function()
			if IsValid(self) then
				self:UpdatePhysmesh()
				self:SetSolid(SOLID_VPHYSICS)
				self:SetTrigger(true)
				self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
				print("COLLISION_GROUP_PASSABLE_DOOR appliqué au portail:", self)
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
	print("[GP2][PORTAL] Portail initialisé avec ID de groupe de liaison:", self:GetLinkageGroup())
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

	-- Système d'immunité temporaire après téléportation (1 seconde)
	if ent.GP2_PortalImmunity and ent.GP2_PortalImmunity > CurTime() then
		return
	end

	-- Détection clone touche portail sans original
	if ent.isClone and ent.daddyEnt and IsValid(ent.daddyEnt) and not ent.daddyEnt.InPortal then
		print("KAWABUNGA")
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

function ENT:EndTouch(ent)
    if not self:CanPort(ent) then return end
    if not ent or not ent:IsValid() then return end
    -- Ignorer les joueurs pour la logique EndTouch
    if ent:IsPlayer() then return end
    -- Ne pas swap si l'entité est tenue par un joueur (physgun ou gravity gun)
    if ent:IsPlayerHolding() then return end
    print("[GP2][PORTAL] EndTouch pour l'entité:", ent)
    -- Ajout : détection si l'objet est en dessous du portail
    if ent:GetPos().z < self:GetPos().z then
        print("[GP2][PORTAL] téléportation maximal")
        if ent.clone and IsValid(ent.clone) then
            -- Swap original <-> clone avec immunité temporaire
            local clone = ent.clone
            local phys = ent:GetPhysicsObject()
            local oldVel = phys and phys:IsValid() and phys:GetVelocity() or nil
            print("oldVel:", oldVel)
            oldVel.z = -oldVel.z
		oldVel.y = -oldVel.y
            print("oldVel:", oldVel)
            ent:SetPos(clone:GetPos())
            ent:SetAngles(clone:GetAngles())
            phys:SetVelocity(oldVel)

            -- Appliquer l'immunité temporaire pour éviter les zigzags
            ent.GP2_PortalImmunity = CurTime() + 0 -- 1 seconde d'immunité

            clone:Remove()
            ent.clone = nil
            print("[GP2][PORTAL] Swap original/clone effectué (téléportation maximal) avec immunité")
        end
    end
    -- Nettoyer les contraintes AdvBallsocket pour éviter l'accumulation
    if SERVER then
        constraint.RemoveConstraints(ent, "AdvBallsocket")
    end
    if ent.clone and IsValid(ent.clone) then
        ent.clone.TouchingPortalsCount = (ent.clone.TouchingPortalsCount or 1) - 1
        if ent.clone.TouchingPortalsCount <= 0 then
            local clone = ent.clone
            -- Si le prop d'origine doit être remplacé par un nouveau prop (logique de téléportation)
            if ent.GP2_ShouldRespawnAfterPortal then
                -- Le clone devient le nouvel original
                if IsValid(clone) then
                    -- Transférer les propriétés importantes
                    clone:SetPos(ent:GetPos())
                    clone:SetAngles(ent:GetAngles())
                    local phys = clone:GetPhysicsObject()
                    if IsValid(phys) then
                        local origPhys = ent:GetPhysicsObject()
                        if IsValid(origPhys) then
                            phys:SetVelocity(origPhys:GetVelocity())
                        end
                        phys:EnableCollisions(true)
                        phys:EnableGravity(true)
                        phys:EnableMotion(true)
                    end
                    clone.isClone = nil
                    clone.daddyEnt = nil
                    clone.InPortal = nil
                    clone:SetSolid(SOLID_VPHYSICS)
                    clone:SetCollisionGroup(COLLISION_GROUP_NONE)
                    -- Nettoyer la référence clone
                    ent.clone = nil
                    -- Supprimer l'original
                    if ent:IsValid() then ent:Remove() end
                end
            else
                -- Sinon, juste supprimer le clone
                if IsValid(clone) then clone:Remove() end
                ent.clone = nil
            end
        end
    end
    ent.InPortal = nil
    if ent.OriginalCollisionGroup then
        GP2.SendChatMessage(nil, Color(200, 200, 200), "COLLISION_GROUP_PASSABLE_DOOR retiré du portail: ", tostring(self))
        ent:SetCollisionGroup(ent.OriginalCollisionGroup)
        GP2.SendChatMessage(nil, Color(200, 200, 200), "[GP2][PORTAL] CollisionGroup restauré pour l'entité: ", tostring(ent), " à ", tostring(ent.OriginalCollisionGroup))
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

	-- Ajout d'un compteur de frames sans sync pour le clone
	clone.GP2_NoSyncFrames = 0
end

function ENT:SyncClone(ent)
	local clone = ent.clone
	if not self:IsLinked() or not self:GetActivated() then return end
	if not IsValid(clone) then return end

	local portal = self:GetLinkedPartner()
	if not IsValid(portal) then return end

	-- Correction : inverser l'offset latéral pour la symétrie gauche/droite
	local offset = self:WorldToLocal(ent:GetPos())
	offset.x = offset.x
	offset.y = -offset.y
	offset.z = -offset.z
	local newPos = portal:LocalToWorld(offset)
	local newAngles = self:GetPortalAngleOffsets(portal, ent)

	clone:SetPos(newPos)
	print("Yaw:", newAngles.y, "Pitch:", newAngles.p, "Roll:", newAngles.r)
	newAngles.y =  newAngles.y
	newAngles.p =  newAngles.p
	newAngles.r = -newAngles.r
	print("[GP2][PORTAL] Synchronisation du clone:", clone, "avec la position:", newPos, "et les angles:", newAngles)
	clone:SetAngles(newAngles)

	-- Appliquer la vélocité de l'original au clone, transformée selon l'orientation des portails
	if SERVER then
		local origPhys = ent:GetPhysicsObject()
		local clonePhys = clone:GetPhysicsObject()
		if IsValid(origPhys) and IsValid(clonePhys) then
			local origVel = origPhys:GetVelocity()
			local transformedVel = self:TransformVelocityBetweenPortals(origVel, portal)
			clonePhys:SetVelocity(transformedVel)
		end
	end

	clone.GP2_NoSyncFrames = 0

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

-- Supprimer l'ancienne fonction CheckCloneImmobile qui créait des plastic crates

-- Ajout d'un hook Think pour incrémenter le compteur de frames sans sync
hook.Add("Think", "GP2_CloneSyncCheck", function()
	for _, ent in ipairs(ents.GetAll()) do
		if ent.isClone and ent.GP2_NoSyncFrames ~= nil then
			ent.GP2_NoSyncFrames = ent.GP2_NoSyncFrames + 1
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
                print("[GP2][PORTAL] Immunité portail appliquée pendant 1 seconde pour:", ent)

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

	local targetIsFloor = self:IsFloor(targetAngles)
	local targetIsCeiling = self:IsCeiling(targetAngles)
	local targetIsWall = self:IsWall(targetAngles)

	print("[GP2][PORTAL][DEBUG] Pitch source:", sourceAngles.p, "Roll:", sourceAngles.r, "target:", targetAngles.p, "Roll:", targetAngles.r)
	print("[GP2][PORTAL][DEBUG] IsFloor source:", sourceIsFloor, "IsCeiling:", sourceIsCeiling, "IsWall:", sourceIsWall, "| target IsFloor:", targetIsFloor, "IsCeiling:", targetIsCeiling, "IsWall:", targetIsWall)

	if sourceIsFloor and targetIsFloor then
		-- Sol -> Sol
		if vel.z < -50 then
			transformedVel = Vector(vel.x, vel.y, -vel.z)
			print("[GP2][PORTAL] Sol->Sol: Chute inversée, vel:", transformedVel)
		else
			transformedVel = targetPortal:GetForward() * speed
		end
	elseif sourceIsFloor and targetIsCeiling then
		-- Sol -> Plafond
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Sol->Plafond: Sortie selon Forward, vel:", transformedVel)
	elseif sourceIsFloor and targetIsWall then
		-- Sol -> Mur
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Sol->Mur: Sortie selon Forward, vel:", transformedVel)
	elseif sourceIsCeiling and targetIsFloor then
		-- Plafond -> Sol
		transformedVel = Vector(vel.x, vel.y, math.abs(vel.z))
		print("[GP2][PORTAL] Plafond->Sol: Sortie vers le haut, vel:", transformedVel)
	elseif sourceIsCeiling and targetIsCeiling then
		-- Plafond -> Plafond
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Plafond->Plafond: Sortie selon Forward, vel:", transformedVel)
	elseif sourceIsCeiling and targetIsWall then
		-- Plafond -> Mur
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Plafond->Mur: Sortie selon Forward, vel:", transformedVel)
	elseif sourceIsWall and targetIsFloor then
		-- Mur -> Sol
		transformedVel = Vector(vel.x, vel.y, math.abs(vel.z))
		print("[GP2][PORTAL] Mur->Sol: Sortie vers le haut, vel:", transformedVel)
	elseif sourceIsWall and targetIsCeiling then
		-- Mur -> Plafond
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Mur->Plafond: Sortie selon Forward, vel:", transformedVel)
	elseif sourceIsWall and targetIsWall then
		-- Mur -> Mur
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Mur->Mur: Sortie selon Forward, vel:", transformedVel)
	else
		-- Cas par défaut (fallback)
		transformedVel = targetPortal:GetForward() * speed
		print("[GP2][PORTAL] Cas par défaut: Sortie selon Forward, vel:", transformedVel)
	end

	if transformedVel:Length() < 100 then
		transformedVel = targetPortal:GetForward() * 250
		print("[GP2][PORTAL] Application vitesse minimale de sécurité:", transformedVel)
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
	print("[GP2][PORTAL] OnFloorWithAngles check: Up=", up, "Forward=", forward, "Result=", result)
	return result
end

function ENT:OnRoofWithAngles(angles)
	angles = angles or self:GetAngles()
	local forward = angles:Forward()
	local result = forward.z < -0.7
	print("[GP2][PORTAL] OnRoofWithAngles check: Forward=", forward, "Result=", result)
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
	print("[GP2][PORTAL] OnFloor check: Up=", up, "Forward=", self:GetForward(), "Result=", result)
	return result
end

function ENT:OnRoof()
	local up = self:GetUp()
	local forward = self:GetForward()
	-- Un portail au plafond a son Forward pointant vers le bas
	local result = forward.z < -0.7
	print("[GP2][PORTAL] OnRoof check: Forward=", forward, "Result=", result)
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
	print("[GP2][PORTAL] SpawnWoodenCratesBelow - isFloor:", isFloor, "isCeiling:", isCeiling, "isWall:", isWall)

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
		print("[GP2][PORTAL] SpawnWoodenCratesBelow - Position réelle du portail:", portalPos, "GroundZ:", groundZ)
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
				print("[GP2][PORTAL] SpawnWoodenCratesBelow - Création de la caisse en bois à l'offset:", offset)
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

