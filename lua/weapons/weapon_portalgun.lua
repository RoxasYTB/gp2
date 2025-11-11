local gp2_portal_debug_points = true
concommand.Add("gp2_portal_debug_points", function(ply, cmd, args)
	 gp2_portal_debug_points = not gp2_portal_debug_points
end, nil, "Active/désactive le debug visuel des points de validation du portail.")

local function debugDrawPoint(pos, valid)
	if not gp2_portal_debug_points then return end
	local color = valid and Color(0,255,0) or Color(255,0,0)
	debugoverlay.Cross(pos, 5, 1, color, true)
end
-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Portal gun
-- ----------------------------------------------------------------------------

AddCSLuaFile()
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Spawnable = true

SWEP.BobScale = 0 // Required for custom viewbob

SWEP.ViewModel = "models/weapons/v_portalgun.mdl"
SWEP.WorldModel = "models/weapons/portalgun/w_portalgun.mdl"
SWEP.ViewModelFOV = 50
SWEP.Automatic = true

SWEP.Primary.Ammo = "None"
SWEP.Primary.Automatic = true
SWEP.Secondary.Ammo = "None"
SWEP.Secondary.Automatic = true

SWEP.AutoSwitchFrom = true
SWEP.AutoSwitchTo = true

SWEP.PrintName = "Portal Gun"
SWEP.Category = "Portal 2"

PrecacheParticleSystem("portal_projectile_stream")
PrecacheParticleSystem("portal_badsurface")
PrecacheParticleSystem("portal_success")

local glow1 = Material("particle/particle_glow_05")

PORTAL_PLACEMENT_FAILED = 0
PORTAL_PLACEMENT_SUCCESFULL = 1
PORTAL_PLACEMENT_BAD_SURFACE = 2
PORTAL_PLACEMENT_INVALID_SURFACE = 2 -- Alias for BAD_SURFACE
PORTAL_PLACEMENT_UNKNOWN_SURFACE = 3
PORTAL_PLACEMENT_FIZZLER_HIT = 4

local vector_origin = Vector(0,0,0)

if SERVER then

local function ForcePortalGunStateForPlayer(ply)
	local map = game.GetMap()
	local no_portal_gun = {
		["sp_a1_intro1"] = true,
		["sp_a1_intro2"] = true
	}
	local single_portal_gun = {
		["sp_a1_intro3"] = true,
		["sp_a1_intro4"] = true,
		["sp_a1_intro5"] = true,
		["sp_a1_intro6"] = true,
		["sp_a1_wakeup"] = true
	}
	if not string.StartWith(map, "sp_") then return end
	if no_portal_gun[map] then
		ply:StripWeapon("weapon_portalgun")
		ply:ConCommand("gp2_portalgun_upgraded 0")
		ply:ConCommand("gp2_portalgun_potato 0")
		if ply.PrintMessage then ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun interdit sur cette map.") end
		return true
	elseif single_portal_gun[map] then
		for _, weapon in ipairs(ply:GetWeapons()) do
			if weapon:GetClass() == "weapon_portalgun" then
				weapon:UpdatePotatoGun(false)
				weapon:SetCanFirePortal2(false)
			end
		end
		ply:ConCommand("gp2_portalgun_upgraded 0")
		ply:ConCommand("gp2_portalgun_potato 0")
		if ply.PrintMessage then ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun limité sur cette map.") end
		return true
	end
	return false
end
HUD_PRINTCONSOLE = HUD_PRINTCONSOLE or 2
HUD_PRINTCONSOLE = HUD_PRINTCONSOLE or 3

CreateConVar("gp2_portal_placement_never_fail", "0", FCVAR_CHEAT + FCVAR_NOTIFY,
	"Can portal be placed on every surface?")

-- ConVars pour sauvegarder l'état du Portal Gun par joueur
CreateConVar("gp2_save_portalgun_state", "1", FCVAR_ARCHIVE,
	"Save Portal Gun state (normal/upgraded/potato) when picking up the weapon")

concommand.Add("gp2_change_linkage_group_id", function(ply, cmd, args)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) then
		if wep:GetClass() == "weapon_portalgun" then
			wep:SetLinkageGroup(tonumber(args[1]) or 0)
		end
	end
end)
	-- Commande pour upgrader le portal gun (disponible pour tous)
	concommand.Add("upgrade_portalgun", function(ply, cmd, args)
		if not IsValid(ply) then return end
		if ForcePortalGunStateForPlayer(ply) then return end
		ply:Give("weapon_portalgun")
		local upgraded = false
		for _, weapon in ipairs(ply:GetWeapons()) do
			if weapon:GetClass() == "weapon_portalgun" then
				weapon:UpdatePortalGun()
				upgraded = true
			end
		end
		if upgraded then
			ply:ConCommand("gp2_portalgun_upgraded 1")
			ply:ConCommand("gp2_portalgun_potato 0")
		end
		if upgraded then
			if ply.PrintMessage then
				ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Vous pouvez maintenant tirer les deux types de portails!")
			end
		end
	end, nil, "Améliore votre Portal Gun pour tirer les deux types de portails")

	-- Commande pour activer le mode potato (disponible pour tous)
	concommand.Add("upgrade_potatogun", function(ply, cmd, args)
		if not IsValid(ply) then return end
		if ForcePortalGunStateForPlayer(ply) then return end
		local upgraded = false
		for _, weapon in ipairs(ply:GetWeapons()) do
			if weapon:GetClass() == "weapon_portalgun" then
				weapon:UpdatePotatoGun(true)
				upgraded = true
			end
		end
		if upgraded then
			ply:ConCommand("gp2_portalgun_potato 1")
		end
		if upgraded then
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Mode Potato Gun activé - GLaDOS vous surveille...")
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Vous devez d'abord avoir un Portal Gun! Utilisez 'upgrade_portalgun'")
		end
	end, nil, "Active le mode Potato sur votre Portal Gun")

	-- Commande pour désactiver le mode potato
	concommand.Add("downgrade_potatogun", function(ply, cmd, args)
		if not IsValid(ply) then return end
		if ForcePortalGunStateForPlayer(ply) then return end
		local downgraded = false
		for _, weapon in ipairs(ply:GetWeapons()) do
			if weapon:GetClass() == "weapon_portalgun" then
				weapon:UpdatePotatoGun(false)
				downgraded = true
			end
		end
		if downgraded then
			ply:ConCommand("gp2_portalgun_potato 0")
		end
		if downgraded then
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Mode Potato désactivé!")
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun restauré en mode normal")
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Aucun Portal Gun trouvé!")
		end
	end, nil, "Désactive le mode Potato de votre Portal Gun")

	-- Commande d'aide pour les Portal Gun
	concommand.Add("portalgun_help", function(ply, cmd, args)
		if not IsValid(ply) then
						return
		end

		ply:PrintMessage(HUD_PRINTCONSOLE, "=== COMMANDES PORTAL GUN GP2-SDK ===")
		ply:PrintMessage(HUD_PRINTCONSOLE, "upgrade_portalgun - Obtenir/améliorer votre Portal Gun")
		ply:PrintMessage(HUD_PRINTCONSOLE, "upgrade_potatogun - Activer le mode Potato")
		ply:PrintMessage(HUD_PRINTCONSOLE, "downgrade_potatogun - Désactiver le mode Potato")
		ply:PrintMessage(HUD_PRINTCONSOLE, "reset_portalgun - Réinitialiser l'état du Portal Gun")
		ply:PrintMessage(HUD_PRINTCONSOLE, "portalgun_help - Afficher cette aide")
		ply:PrintMessage(HUD_PRINTCONSOLE, "===================================")
		ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Commandes Portal Gun affichées dans la console!")
	end, nil, "Affiche l'aide des commandes Portal Gun")

	-- Commande pour réinitialiser l'état du Portal Gun
	concommand.Add("reset_portalgun", function(ply, cmd, args)
		if not IsValid(ply) then return end
		if ForcePortalGunStateForPlayer(ply) then return end
		local reset = false
		for _, weapon in ipairs(ply:GetWeapons()) do
			if weapon:GetClass() == "weapon_portalgun" then
				weapon:UpdatePotatoGun(false)
				weapon:SetCanFirePortal2(false)
				reset = true
			end
		end
		if reset then
			ply:ConCommand("gp2_portalgun_upgraded 0")
			ply:ConCommand("gp2_portalgun_potato 0")
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Portal Gun réinitialisé en mode normal!")
		end
	end, nil, "Réinitialise le Portal Gun en mode normal")

	concommand.Add("remove_portalgun", function(ply, cmd, args)
		if not IsValid(ply) then return end
		ForcePortalGunStateForPlayer(ply)
	end, nil, "Retire le Portal Gun de votre inventaire")

	hook.Add("Think", "GP2_EnforceNoPortalGunMaps", function()
		local no_portal_gun = {
			["sp_a1_intro1"] = true,
			["sp_a1_intro2"] = true
		}
		local map = game.GetMap()
		if no_portal_gun[map] then
			for _, ply in ipairs(player.GetAll()) do
				if IsValid(ply) and ply:HasWeapon("weapon_portalgun") then
					ply:StripWeapon("weapon_portalgun")
				end
			end
		end
	end)
end

concommand.Add("gp2_portalgun_entityinuse", function(ply, cmd, args)
	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or wep:GetClass() ~= "weapon_portalgun" then
		ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Vous n'avez pas de Portal Gun équipé.")
		return
	end
	local ent = wep:GetEntityInUse()
	local isHoldingSomething = IsValid(ent)
	if isHoldingSomething then
		local info = "[GP2] EntityInUse : " .. tostring(ent) .. " (Class: " .. ent:GetClass() .. ")"
		if ent:GetClass() == "player_pickup" and ent.GetParent and IsValid(ent:GetParent()) then
			local parent = ent:GetParent()
			info = info .. " | Pickup cible : " .. tostring(parent) .. " (Class: " .. parent:GetClass() .. ")"
		end
		ply:PrintMessage(HUD_PRINTCONSOLE, info)
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Aucun EntityInUse détecté sur votre Portal Gun.")
	end
	ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] isHoldingSomething : " .. tostring(isHoldingSomething))
end, nil, "Affiche l'entité actuellement portée par le Portal Gun et si quelque chose est tenu.")

local gp2_portal_placement_never_fail = GetConVar("gp2_portal_placement_never_fail")

if CLIENT then
	CreateClientConVar("gp2_portalgun_upgraded", "0", true, false, "Portal Gun upgraded state")
	CreateClientConVar("gp2_portalgun_potato", "0", true, false, "Portal Gun potato mode state")
	CreateClientConVar("gp2_portal_color1", "2 114 210", true, true, "Color for Portal 1")
	CreateClientConVar("gp2_portal_color2", "210 114 2", true, true, "Color for Portal 2")

	-- Commandes côté client pour faciliter l'accès (exécutent les commandes serveur)
	concommand.Add("gp2_upgrade", function(ply, cmd, args)
		RunConsoleCommand("upgrade_portalgun")
		chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Commande upgrade_portalgun envoyée!")
	end, nil, "Raccourci pour upgrade_portalgun")

	concommand.Add("gp2_potato", function(ply, cmd, args)
		RunConsoleCommand("upgrade_potatogun")
		chat.AddText(Color(255, 200, 100), "[GP2] ", Color(255, 255, 255), "Commande upgrade_potatogun envoyée!")
	end, nil, "Raccourci pour upgrade_potatogun")

	concommand.Add("gp2_normal", function(ply, cmd, args)
		RunConsoleCommand("downgrade_potatogun")
		chat.AddText(Color(100, 200, 255), "[GP2] ", Color(255, 255, 255), "Portal Gun restauré en mode normal!")
	end, nil, "Raccourci pour downgrade_potatogun")

	concommand.Add("gp2_reset", function(ply, cmd, args)
		RunConsoleCommand("reset_portalgun")
		chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Portal Gun réinitialisé!")
	end, nil, "Raccourci pour reset_portalgun")

	concommand.Add("gp2_help", function(ply, cmd, args)
		chat.AddText(Color(255, 255, 100), "=== COMMANDES PORTAL GUN GP2-SDK ===")
		chat.AddText(Color(100, 255, 100), "upgrade_portalgun", Color(255, 255, 255), " ou ", Color(100, 255, 100), "gp2_upgrade", Color(255, 255, 255), " - Obtenir le Portal Gun")
		chat.AddText(Color(255, 200, 100), "upgrade_potatogun", Color(255, 255, 255), " ou ", Color(255, 200, 100), "gp2_potato", Color(255, 255, 255), " - Mode Potato")
		chat.AddText(Color(100, 200, 255), "downgrade_potatogun", Color(255, 255, 255), " ou ", Color(100, 200, 255), "gp2_normal", Color(255, 255, 255), " - Mode Normal")
		chat.AddText(Color(255, 100, 100), "reset_portalgun", Color(255, 255, 255), " ou ", Color(255, 100, 100), "gp2_reset", Color(255, 255, 255), " - Réinitialiser")
		chat.AddText(Color(255, 255, 100), "gp2_help", Color(255, 255, 255), " - Cette aide")
		chat.AddText(Color(255, 255, 100), "=====================================")
	end, nil, "Affiche l'aide des commandes Portal Gun")

	hook.Add("InitPostEntity", "GP2_ForcePortalGunState", function()
		local no_portal_gun = {
			["sp_a1_intro1"] = true,
			["sp_a1_intro2"] = true
		}
		local single_portal_gun = {
			["sp_a1_intro3"] = true,
			["sp_a1_intro4"] = true,
			["sp_a1_intro5"] = true,
			["sp_a1_intro6"] = true,
			["sp_a1_intro7"] = true,
			["sp_a1_wakeup"] = true
		}
		local map = game.GetMap()
		if not string.StartWith(map, "sp_") or map == "sp_a2_intro" then return end
		if no_portal_gun[map] then
			RunConsoleCommand("remove_portalgun")
		elseif single_portal_gun[map] then
			RunConsoleCommand("reset_portalgun")
		else
			RunConsoleCommand("upgrade_portalgun")
		end
	end)

	hook.Add("PlayerGiveWeapon", "GP2_BlockPortalGunSpawn", function(ply, wepname)
		if wepname == "weapon_portalgun" then
			local no_portal_gun = {
				["sp_a1_intro1"] = true,
				["sp_a1_intro2"] = true
			}
			local map = game.GetMap()
			if no_portal_gun[map] then
				return false
			end
		end
	end)

	net.Receive(GP2.Net.SendPortalPlacementNotPortalable, function()
		local hitPos = net.ReadVector()
		local hitAngle = net.ReadAngle()
		local color = net.ReadVector()

		local forward, right, up = hitAngle:Forward(), hitAngle:Right(), hitAngle:Up()

		local particle = CreateParticleSystemNoEntity("portal_badsurface", hitPos, hitAngle)
		if IsValid(particle) then
			particle:SetControlPoint(0, hitPos)
			particle:SetControlPointOrientation(0, up, right, forward)
			particle:SetControlPoint(2, color)
		end
	end)

	net.Receive(GP2.Net.SendPortalPlacementSuccess, function()
		local hitPos = net.ReadVector()
		local hitAngle = net.ReadAngle()
		local color = net.ReadVector()

		local forward, right, up = hitAngle:Forward(), hitAngle:Right(), hitAngle:Up()

		local particle = CreateParticleSystemNoEntity("portal_success", hitPos, hitAngle)
		if IsValid(particle) then
			particle:SetControlPoint(0, hitPos - hitAngle:Up() * 15)
			particle:SetControlPointOrientation(0, right, forward, up)
			particle:SetControlPoint(2, color)
		end
	end)
end

local function getSurfaceAngle(owner, norm)
	local fwd = owner:GetAimVector()
	local rgh = fwd:Cross(norm)
	fwd:Set(norm:Cross(rgh))
	return fwd:AngleEx(norm)
end

local gtCheck =
{
	["player"]                  = true,
	["prop_portal"]             = true,
	["prop_weighted_cube"]      = true,
	["grenade_helicopter"]      = true,
	["npc_portal_turret_floor"] = true,
	["prop_monster_box"]        = true,
	["npc_*"]                   = true,
}

local function gtCheckFunc(e)
	if not IsValid(e) then return end
	return ! gtCheck[e:GetClass()]
end

local cleanserCheck = {
	["trigger_portal_cleanser"] = true
}

local rayHull = Vector(0.01, 0.01, 0.01)

local function portalsOverlap(pos, ang, size, ignore)
		if not pos or not isvector(pos) or not size or not isvector(size) then
			return false, nil
		end
		local portals = ents.FindByClass("prop_portal")
		local closest, closestDist = nil, math.huge
		for _, p in ipairs(portals) do
			if p ~= ignore and p:GetActivated() then
				local dist = p:GetPos():Distance(pos)
				local minDist = (p:GetSize():Length() + size:Length()) * 0.5 * 0.85
				if dist < minDist and dist < closestDist then
					closest = p
					closestDist = dist
				end
			end
		end
		if closest then
			return true, closest
		end
		return false, nil
end


local function setPortalPlacementOld(owner, portal)
	local ang = Angle() -- The portal angle
	local siz = portal:GetSize()
	local pos = owner:GetShootPos()
	local aim = owner:GetAimVector()
	local mul = siz[3] * 2.5

	local tr = PortalManager.TraceLine({
		start  = pos,
		endpos = pos + aim * 99999,
		filter = gtCheckFunc,
		mask   = MASK_SHOT_PORTAL
	})

	local alongRay = ents.FindAlongRay(tr.StartPos, tr.HitPos, -rayHull, rayHull)


	for i = 1, #alongRay do
		local ent = alongRay[i]
			-- Vérification du chevauchement avec d'autres portails
			if portalsOverlap(pos, ang, siz, portal) then
				return PORTAL_PLACEMENT_BAD_SURFACE, tr
			end

		-- Check if the entity is in the 'cleanserCheck' table
		if cleanserCheck[ent:GetClass()] then
		if not (ent.GetEnabled and ent:GetEnabled()) then continue end

			local rayDirection = pos + aim * 99999

			-- Intersect ray with collision bounds
			local boundsMin, boundsMax = ent:GetCollisionBounds()
			local hitPos = util.IntersectRayWithOBB(pos, rayDirection, ent:GetPos(), ent:GetAngles(), boundsMin,
				boundsMax)

			if hitPos then
				tr.HitPos = hitPos

			end

			return PORTAL_PLACEMENT_FIZZLER_HIT, tr
		end
	end

	if
		not gp2_portal_placement_never_fail:GetBool() and
		(
			not tr.Hit
			or IsValid(tr.Entity)
			or tr.HitTexture == "**studio**"
			--or bit.band(tr.DispFlags, DISPSURF_WALKABLE) ~= 0
			or bit.band(tr.SurfaceFlags, SURF_NOPORTAL) ~= 0
			or bit.band(tr.SurfaceFlags, SURF_TRANS) ~= 0
		)
	then
		return PORTAL_PLACEMENT_BAD_SURFACE, tr
	end

	if tr.HitSky then
		return PORTAL_PLACEMENT_UNKNOWN_SURFACE, tr
	end

	-- Align portals on 45 degree surfaces
	if math.abs(tr.HitNormal:Dot(ang:Up())) < 0.71 then
		ang:Set(tr.HitNormal:Angle())
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 180)
	else -- Place portals on any surface and angle
		ang:Set(getSurfaceAngle(owner, tr.HitNormal))
	end

	-- Extrude portal from the ground
	local af, au = ang:Forward(), ang:Right()
	local angTab = {
		af * siz[1],
		-af * siz[1],
		au * siz[2],
		-au * siz[2]
	}




	for i = 1, 4 do
		local extr = PortalManager.TraceLine({
			start  = tr.HitPos + tr.HitNormal,
			endpos = tr.HitPos + tr.HitNormal - angTab[i],
			filter = ents.GetAll(),
		})

		if extr.Hit then
			tr.HitPos = tr.HitPos + angTab[i] * (1 - extr.Fraction)
		end
	end

	pos:Set(tr.HitNormal)
	pos:Mul(mul)
	pos:Add(tr.HitPos + tr.HitNormal * 0.5)

	local trBehind = PortalManager.TraceLine({
		start  = tr.HitPos + tr.HitNormal,
		endpos = tr.HitPos + tr.HitNormal * 1000,
		filter = gtCheckFunc,
		mask   = MASK_SHOT_PORTAL
	})

	if trBehind.Hit and trBehind.HitNormal and tr.HitNormal:Dot(trBehind.HitNormal) > -0.5 then

		return PORTAL_PLACEMENT_BAD_SURFACE, tr
	end

	local portalValid = true
	local numTests = 6
	local adjustedHitPos = tr.HitPos
	local adjustedPos = pos


		pos:Set(tr.HitNormal)
		pos:Mul(mul)
		pos:Add(tr.HitPos + tr.HitNormal * 0.5)


	local overlap, closest = portalsOverlap(pos, ang, siz, portal)
	if overlap and IsValid(closest) and closest:GetType() ~= portal:GetType() then
		local dir = (pos - closest:GetPos()):Dot(ang:Right())
		local offset = ang:Right() * ((closest:GetSize():Length() + siz:Length()) * 0.47 )
		if dir >= 0 then
			pos = closest:GetPos() + offset
		else
			pos = closest:GetPos() - offset
		end
	end
	return PORTAL_PLACEMENT_SUCCESFULL, tr, pos, ang
end

function SWEP:Initialize()
	self:SetDeploySpeed(1)
	self:SetHoldType("shotgun")

	if SERVER then
		self.NextIdleTime = 0
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "IsPotatoGun")
	self:NetworkVar("Bool", "CanFirePortal1")
	self:NetworkVar("Bool", "CanFirePortal2")
	self:NetworkVar("Int", "LinkageGroup")
	self:NetworkVar("Entity", "LastPlacedPortal")
	self:NetworkVar("Entity", "EntityInUse")

	if SERVER then
		self:SetCanFirePortal1(true) -- default only portal 1
	end
end

function SWEP:Deploy()
	if CLIENT then
		if SyncPortalGunState then SyncPortalGunState() end
		return end

	-- Restaurer l'état sauvegardé du Portal Gun
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsPlayer() then
		local saveState = GetConVar("gp2_save_portalgun_state")
		if saveState and saveState:GetBool() then
			local tries = 0
			local function TryApplyState()
				if not IsValid(self) or not IsValid(owner) then return end
				local isUpgraded, isPotato = self:GetSyncedPortalGunState()
								if isUpgraded or isPotato or tries > 10 then
					if isPotato then
						self:UpdatePotatoGun(true)
											elseif isUpgraded then
						if not self:GetCanFirePortal2() then
							self:UpdatePortalGun()
						end
					end
				else
					tries = tries + 1
					timer.Simple(0.1, TryApplyState)
				end
			end
			TryApplyState()
		end
	end

	if not self.GotCustomLinkageGroup then
		self:SetLinkageGroup(self:GetOwner():EntIndex() - 1)
	end
	if self:GetIsPotatoGun() then
		self:SendWeaponAnim(ACT_VM_DEPLOY)
		self:GetOwner():GetViewModel(0):SetBodygroup(1, 1)
		self:SetBodygroup(1, 1)
	end
	local owner = self:GetOwner()
	local vm0 = owner:GetViewModel(0)
	local vm1 = owner:GetViewModel(1)
	if not IsValid(self.HoldSound) then
		local filter = RecipientFilter()
		filter:AddPlayer(owner)
	-- Vérification du chevauchement avec d'autres portails
	if portalsOverlap(pos, ang, siz, portal) then
		return PORTAL_PLACEMENT_BAD_SURFACE, tr
	end
		self.HoldSound = CreateSound(self, "PortalPlayer.ObjectUse", filter)
	end
	local seq = vm1:SelectWeightedSequence(ACT_VM_RELEASE)
	if IsValid(vm1) then
		vm1:SetWeaponModel(self:GetWeaponViewModel(), NULL)
		if self:GetIsPotatoGun() then
			vm1:SetBodygroup(1, 1)
		end
	end
	if self.GotEntityInUse then
		self:StopSound("PortalPlayer.ObjectUse")
		self:EmitSound("PortalPlayer.ObjectUseStop", 0)
		self:SetEntityInUse(NULL)
		self.GotEntityInUse = false
		timer.Simple(0, function()
			vm0:SendViewModelMatchingSequence(12)
		end)
	end
	return true
end

function SWEP:Holster(arguments)
	if SERVER then
		local owner = self:GetOwner()
		local vm1 = owner:GetViewModel(1)

		if not IsValid(owner) then
			return
		end

		-- Nettoyer le système de proxy si on range l'arme
		if IsValid(self.HoldProxy) then
			self.HoldProxy:Remove()
		end
		self.HoldProxy = nil
		self.HeldRealObject = nil

		if IsValid(vm1) then
			vm1:SetWeaponModel(self:GetWeaponViewModel(), self)
		end
		timer.Simple(0, function()
			if !IsValid(self) then return end // Stop erroring on death!

			if IsValid(vm1) and IsValid(owner:GetEntityInUse()) then

				vm1:SendViewModelMatchingSequence(self:SelectWeightedSequence(ACT_VM_PICKUP))
				self.GotEntityInUse = true
				self:EmitSound("PortalPlayer.ObjectUse", 0)
				self:SetEntityInUse(owner:GetEntityInUse())



			else
				vm1:SetWeaponModel(self:GetWeaponViewModel(), NULL)
				if self:GetIsPotatoGun() then
					vm1:SetBodygroup(1, 1)
				end
			end
		end)
	end

	return true
end

function SWEP:PrimaryAttack()
	if not SERVER then return end
	if not self:GetCanFirePortal1() then return end

	if not self:CanPrimaryAttack() then return end
	self:GetOwner():EmitSound("Weapon_Portalgun.fire_blue")

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	self.NextIdleTime = CurTime() + 0.5

	if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
		self:GetOwner():ViewPunch(Angle(math.Rand(-1, -0.5), math.Rand(-1, 1), 0))
	end

	self:PlacePortal(PORTAL_TYPE_FIRST, self:GetOwner())

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
	if not SERVER then return end
	if not self:GetCanFirePortal2() then return end

	if not self:CanPrimaryAttack() then return end
	self:GetOwner():EmitSound("Weapon_Portalgun.fire_red")

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	self.NextIdleTime = CurTime() + 0.5

	if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
		self:GetOwner():ViewPunch(Angle(math.Rand(-1, -0.5), math.Rand(-1, 1), 0))
	end

	self:PlacePortal(PORTAL_TYPE_SECOND, self:GetOwner())

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)
end



function SWEP:ClearSpawn()
end

function SWEP:PlacePortal(type, owner)
    local r, g, b

    if SERVER and IsValid(owner) then
        -- Utiliser le nouveau système par joueur côté serveur
        local colors = GP2.GetPlayerPortalColors(owner)
        if type == PORTAL_TYPE_FIRST then
            r, g, b = colors.r1, colors.g1, colors.b1
        else
            r, g, b = colors.r2, colors.g2, colors.b2
        end
    elseif CLIENT then
        -- Côté client, utiliser les couleurs du joueur local
        local colors = GP2.GetClientPlayerPortalColors(LocalPlayer())
        if type == PORTAL_TYPE_FIRST then
            r, g, b = colors.r1, colors.g1, colors.b1
        else
            r, g, b = colors.r2, colors.g2, colors.b2
        end
    else
        -- Fallback aux couleurs par défaut
        if type == PORTAL_TYPE_FIRST then
            r, g, b = 2, 114, 210  -- Bleu
        else
            r, g, b = 210, 114, 2  -- Orange
        end
    end


    local portal = ents.Create("prop_portal")
    if not IsValid(portal) then return end
    portal:SetPlacedByMap(false)
    portal:SetPortalColor(r, g, b)
    portal:SetType(type or 0)
    portal:SetLinkageGroup(self:GetLinkageGroup())

    -- Définir le propriétaire du portail pour les couleurs par joueur
    if IsValid(owner) then
        portal:SetOwner(owner)
    end
    local placementStatus, traceResult, pos, ang



    placementStatus, traceResult, pos, ang = setPortalPlacementOld(self:GetOwner(), portal)


    --local effectData = EffectData()
    --effectData:SetNormal(Vector(r, g, b)) -- color
    --effectData:SetOrigin(traceResult.StartPos)
    --effectData:SetStart(traceResult.HitPos)
    --effectData:SetEntity(owner)

    --util.Effect("portal_blast", effectData)
	if placementStatus == PORTAL_PLACEMENT_BAD_SURFACE
		or placementStatus == PORTAL_PLACEMENT_FIZZLER_HIT then
		net.Start(GP2.Net.SendPortalPlacementNotPortalable)
		net.WriteVector(traceResult.HitPos)
		net.WriteAngle(traceResult.HitNormal:Angle())
		-- Protected GetColorVector call
		if IsValid(portal) and portal.GetColorVector then
			net.WriteVector(portal:GetColorVector() * 0.5)
		else
			net.WriteVector(Vector(255, 255, 255) * 0.5) -- Default white color
		end
		net.Broadcast()

		EmitSound("Portal.fizzle_invalid_surface", traceResult.HitPos, self:EntIndex(), CHAN_AUTO, 1, 60)
		return
	elseif placementStatus == PORTAL_PLACEMENT_UNKNOWN_SURFACE then
		return
	end

    portal:Spawn()
    if CLIENT then
        local mulRatio = 1.1 / 2.5
        local adjustedPos = pos - (pos - traceResult.HitPos) * (1 - mulRatio)
        portal:SetPos(adjustedPos)
    else
        portal:SetPos(pos)
    end
    portal:SetAngles(ang)
    portal:SetPlacedByMap(false)
    if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
        portal:BuildPortalEnvironment()
    end

    portal:SetActivated(true)

    -- Correction : forcer la mise à jour du linkage group après activation
    if SERVER then
        PortalManager.SetPortal(self:GetLinkageGroup(), portal)
    end    --- @type Player
    local player = owner

    self:SetLastPlacedPortal(portal)
    net.Start(GP2.Net.SendPortalPlacementSuccess)
    net.WriteVector(portal:GetPos())
    net.WriteAngle(portal:GetAngles())
    -- Protected GetColorVector call
    if IsValid(portal) and portal.GetColorVector then
        net.WriteVector(portal:GetColorVector() * 0.5)
    else
        net.WriteVector(Vector(255, 255, 255) * 0.5) -- Default white color
    end
    net.Broadcast()
end

function SWEP:Think()
	if SERVER then
		local owner = self:GetOwner()
		if not IsValid(owner) then return true end

		-- Gestion du système de proxy pour le pickup à distance
		local heldEntity = owner:GetEntityInUse()

		-- Si on tient un objet réel et pas encore de proxy, créer le système
		if IsValid(heldEntity) and not self.HoldProxy then
			-- Créer le proxy invisible
			local proxy = ents.Create("prop_physics")
			if IsValid(proxy) then
				proxy:SetModel("models/hunter/plates/plate025x025.mdl") -- Petit modèle
				proxy:SetPos(heldEntity:GetPos())
				proxy:SetAngles(heldEntity:GetAngles())
				proxy:Spawn()
				proxy:SetNoDraw(true)
				proxy:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				proxy:DrawShadow(false)

				local phys = proxy:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetMass(1)
					phys:EnableMotion(false) -- Proxy statique
				end

				self.HoldProxy = proxy
				self.HeldRealObject = heldEntity

				-- Faire lâcher l'objet réel et prendre le proxy à la place
				owner:DropObject()
				timer.Simple(0.05, function()
					if IsValid(proxy) and IsValid(owner) then
						owner:PickupObject(proxy)
					end
				end)
			end
		end

		-- Si on a un système proxy actif
		if IsValid(self.HoldProxy) and IsValid(self.HeldRealObject) then
			local proxy = self.HoldProxy
			local realObj = self.HeldRealObject

			-- Vérifier que le proxy est toujours tenu
			if owner:GetEntityInUse() ~= proxy then
				-- Le proxy a été lâché, nettoyer
				if IsValid(proxy) then proxy:Remove() end
				self.HoldProxy = nil
				self.HeldRealObject = nil
			else
				-- Attirer l'objet réel vers le proxy
				local phys = realObj:GetPhysicsObject()
				if IsValid(phys) then
					local proxyPos = proxy:GetPos()
					local objPos = realObj:GetPos()
					local dir = proxyPos - objPos
					local dist = dir:Length()

					-- Force d'attraction proportionnelle à la distance
					local strength = math.min(dist * 100, 5000) -- Force maximale de 5000
					phys:ApplyForceCenter(dir:GetNormalized() * strength)

					-- Damping pour éviter les oscillations
					local vel = phys:GetVelocity()
					phys:AddVelocity(vel * -0.3)

					-- Synchroniser l'angle du proxy à l'objet réel pour un meilleur visuel
					if dist < 50 then
						realObj:SetAngles(proxy:GetAngles())
					end
				else
					-- L'objet réel n'a plus de physique, nettoyer
					if IsValid(proxy) then proxy:Remove() end
					self.HoldProxy = nil
					self.HeldRealObject = nil
				end
			end
		end

		-- Nettoyer si les entités sont invalides
		if not IsValid(self.HoldProxy) or not IsValid(self.HeldRealObject) then
			if IsValid(self.HoldProxy) then self.HoldProxy:Remove() end
			self.HoldProxy = nil
			self.HeldRealObject = nil
		end

		-- Animation idle
		if CurTime() > self.NextIdleTime and self:GetActivity() ~= ACT_VM_IDLE then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end

		-- Synchronisation EntityInUse
		if self:GetEntityInUse() ~= owner:GetEntityInUse() then
			self:SetEntityInUse(owner:GetEntityInUse())
		end

		-- Vérification constante de l'état du Portal Gun
		local saveState = GetConVar("gp2_save_portalgun_state")
		if saveState and saveState:GetBool() then
			if not self.NextStateCheck or CurTime() > self.NextStateCheck then
				self.NextStateCheck = CurTime() + 0.5
				local isUpgraded, isPotato = self:GetSyncedPortalGunState()
				if isPotato and not self:GetIsPotatoGun() then
					self:UpdatePotatoGun(true)
				elseif not isPotato and self:GetIsPotatoGun() then
					self:UpdatePotatoGun(false)
				elseif isUpgraded and not self:GetCanFirePortal2() and not self:GetIsPotatoGun() then
					self:UpdatePortalGun()
				elseif not isUpgraded and not isPotato and self:GetCanFirePortal2() then
					self:SetCanFirePortal2(false)
				end
			end
		end
	else
		if LocalPlayer():InVehicle() then
			self.ViewModelFOV = 35
		end
	end

	self:NextThink(CurTime())
	return true
end

if SERVER then
	function SWEP:UpdatePortalGun()
		self:SetCanFirePortal1(true)
		self:SetCanFirePortal2(true)
	end

	function SWEP:UpdatePotatoGun(into)
		self:SetCanFirePortal1(true)
		self:SetCanFirePortal2(true)

		self:SendWeaponAnim(ACT_VM_HOLSTER)
		self:SetIsPotatoGun(into)

		self:SetNextPrimaryFire(CurTime() + 3.5)
		self:SetNextSecondaryFire(CurTime() + 3.5)

		timer.Simple(2, function()
			self:SendWeaponAnim(ACT_VM_DRAW)
			if into then
				self:GetOwner():GetViewModel(0):SetBodygroup(1, 1)
				self:SetBodygroup(1, 1)
			else
				self:GetOwner():GetViewModel(0):SetBodygroup(1, 0)
				self:SetBodygroup(1, 0)
			end
		end)

		self.NextIdleTime = CurTime() + 5
	end
end

function SWEP:OnRemove()
	-- Nettoyer le proxy quand l'arme est supprimée
	if SERVER and IsValid(self.HoldProxy) then
		self.HoldProxy:Remove()
	end
	self.HoldProxy = nil
	self.HeldRealObject = nil

	self:ClearPortals()
end

function SWEP:ClearPortals()
	local portal1 = PortalManager.GetLinkageGroup(self:GetLinkageGroup())[PORTAL_TYPE_FIRST]
	local portal2 = PortalManager.GetLinkageGroup(self:GetLinkageGroup())[PORTAL_TYPE_SECOND]

	if SERVER then
		if IsValid(portal1) and self:GetCanFirePortal1() then
			portal1:Fizzle()
		end

		if IsValid(portal2) and self:GetCanFirePortal2() then
			portal2:Fizzle()
		end
	end

	self:SetLastPlacedPortal(NULL)
end

function SWEP:ViewModelDrawn(vm)
	local owner = vm:GetOwner()
	local vm0 = owner:GetViewModel(0)
	local vm1 = owner:GetViewModel(1)

    if not self.TopLightFirstPersonAttachment and IsValid(vm0) then
        self.TopLightFirstPersonAttachment = vm0:LookupAttachment("Body_light")
    end

    if not self.TopLightFirstPerson2Attachment and IsValid(vm1) then
        self.TopLightFirstPerson2Attachment = vm1:LookupAttachment("Body_light")
    end
	local lastPlacedPortal = self:GetLastPlacedPortal()
	local lightColor

	if not IsValid(lastPlacedPortal) then
		lightColor = vector_origin
	else
		-- Verify this is actually a portal entity with GetColorVector method
		if IsValid(lastPlacedPortal) and lastPlacedPortal:GetClass() == "prop_portal" and lastPlacedPortal.GetColorVector then
			lightColor = lastPlacedPortal:GetColorVector() * 0.2
			lightColor.g = lightColor.g * 1.05
		else
			-- Fallback to default color if entity is invalid or not a portal
			lightColor = vector_origin
		end
	end


		-- Set color to current portal placed
		if IsValid(self.TopLightFirstPerson) then
			self.TopLightFirstPerson:SetControlPoint(1, lightColor)
		end

		if IsValid(self.TopLightFirstPerson2) then
			self.TopLightFirstPerson2:SetControlPoint(1, lightColor)
		end

		self.TopLightColor = lightColor


	if not self.TopLightColor then
		self.TopLightColor = Vector()
	end

	-- Top light particle (and beam) for first viewmodel
	if not IsValid(self.TopLightFirstPerson) and IsValid(vm0) then
		self.TopLightFirstPerson = CreateParticleSystem(vm0, "portalgun_top_light_firstperson", PATTACH_POINT_FOLLOW, self.TopLightFirstPersonAttachment or 0)
		if IsValid(self.TopLightFirstPerson) then
			self.TopLightFirstPerson:SetIsViewModelEffect(true)
			self.TopLightFirstPerson:SetShouldDraw(false)
			self.TopLightFirstPerson:AddControlPoint(2, owner, PATTACH_CUSTOMORIGIN)
			self.TopLightFirstPerson:AddControlPoint(3, vm0, PATTACH_POINT_FOLLOW, "Beam_point1")
			self.TopLightFirstPerson:AddControlPoint(4, vm0, PATTACH_POINT_FOLLOW, "Beam_point5")
		end
	end
	if IsValid(self.TopLightFirstPerson) and vm == vm0 then
		self.TopLightFirstPerson:Render()
	end

	-- Top light particle (and beam) for second viewmodel (copie du premier)
	if not IsValid(self.TopLightFirstPerson2) and IsValid(vm1) then
		self.TopLightFirstPerson2 = CreateParticleSystem(vm1, "portalgun_top_light_firstperson", PATTACH_POINT_FOLLOW, self.TopLightFirstPerson2Attachment or 0)
		if IsValid(self.TopLightFirstPerson2) then
			self.TopLightFirstPerson2:SetIsViewModelEffect(true)
			self.TopLightFirstPerson2:SetShouldDraw(false)
			self.TopLightFirstPerson2:AddControlPoint(2, owner, PATTACH_CUSTOMORIGIN)
			self.TopLightFirstPerson2:AddControlPoint(3, vm1, PATTACH_POINT_FOLLOW, "Beam_point1")
			self.TopLightFirstPerson2:AddControlPoint(4, vm1, PATTACH_POINT_FOLLOW, "Beam_point5")
		end
	end
	if IsValid(self.TopLightFirstPerson2) and vm == vm1 then
		self.TopLightFirstPerson2:Render()
	end

	if not IsValid(vm0) or not IsValid(vm1) then return end
	if vm0:GetModel() != vm1:GetModel() then return end // Fix stupid holding particle bug

	-- Holding particle for second vm
	if vm == vm1 then
		if not self.FirstPersonMuzzleAttachment then
			self.FirstPersonMuzzleAttachment = vm1:LookupAttachment("muzzle")
		end

		if not self.FirstPersonMuzzleAttachment2 then
			self.FirstPersonMuzzleAttachment2 = vm1:LookupAttachment("muzzle")
		end

		local entityInUse = owner:GetEntityInUse()



		self.HoldingParticleFirstPersonDieTime = self.HoldingParticleFirstPersonDieTime or CurTime() + 0.5

		if not IsValid(self.HoldingParticleFirstPerson) then
			self.HoldingParticleFirstPerson = CreateParticleSystem(vm1, "portalgun_beam_holding_FP", PATTACH_POINT_FOLLOW,
				self.FirstPersonMuzzleAttachment2)

			if IsValid(self.HoldingParticleFirstPerson) then
				self.HoldingParticleFirstPerson:AddControlPoint(1, vm1, PATTACH_POINT_FOLLOW, "Arm1_attach3")
				self.HoldingParticleFirstPerson:AddControlPoint(2, vm1, PATTACH_POINT_FOLLOW, "Arm2_attach3")
				self.HoldingParticleFirstPerson:AddControlPoint(3, vm1, PATTACH_POINT_FOLLOW, "Arm3_attach3")
				self.HoldingParticleFirstPerson:AddControlPoint(4, owner, PATTACH_CUSTOMORIGIN)
				self.HoldingParticleFirstPerson:SetControlPointEntity(4, vm1)
				if IsValid(entityInUse) then
					self.HoldingParticleFirstPerson:AddControlPoint(5, entityInUse, PATTACH_ABSORIGIN_FOLLOW, 0)
				else
					self.HoldingParticleFirstPerson:AddControlPoint(5, vm1, PATTACH_POINT_FOLLOW, "muzzle")
				end
				self.HoldingParticleFirstPersonDieTime = CurTime() + 0.5
			end
		elseif CurTime() > self.HoldingParticleFirstPersonDieTime then
			if IsValid(self.HoldingParticleFirstPerson) then
				self.HoldingParticleFirstPerson:StopEmission(false, true)
			end
			self.HoldingParticleFirstPerson = NULL
		end

	else
		if IsValid(self.HoldingParticleFirstPerson) then
			self.HoldingParticleFirstPerson:StopEmission(false, true)
			self.HoldingParticleFirstPerson = NULL
		end
	end
end

function SWEP:DrawWorldModel(studio)
    local lastPlacedPortal = self:GetLastPlacedPortal()
    local lightColor

    if not IsValid(lastPlacedPortal) then
        lightColor = vector_origin
    else
        -- Verify this is actually a portal entity with GetColorVector method
        if IsValid(lastPlacedPortal) and lastPlacedPortal:GetClass() == "prop_portal" and lastPlacedPortal.GetColorVector then
            lightColor = lastPlacedPortal:GetColorVector() * 0.2
            lightColor.g = lightColor.g * 1.05
        else
            -- Fallback to default color if entity is invalid or not a portal
            lightColor = vector_origin
        end
    end

    if not self.TopLightThirdPersonAttachment then
        self.TopLightThirdPersonAttachment = self:LookupAttachment("Body_light")
    end

    if not self.TopLightColor then
        self.TopLightColor = Vector()
    end

    -- Top light particle (and beam) - world model
    if not IsValid(self.TopLightThirdPerson) then
        self.TopLightThirdPerson = CreateParticleSystem(self, "portalgun_top_light_thirdperson", PATTACH_POINT_FOLLOW,
            self.TopLightThirdPersonAttachment)
        if IsValid(self.TopLightThirdPerson) then
            self.TopLightThirdPerson:AddControlPoint(4, self, PATTACH_POINT_FOLLOW, "Beam_point5")
        end
    else
        self.TopLightThirdPerson:Render()
        -- On ne met à jour que le control point 1 (couleur)
        self.TopLightThirdPerson:SetControlPoint(1, lightColor)
        if self.TopLightColor ~= lightColor then
            self.TopLightColor = lightColor
        end
    end

    self:DrawModel(studio)
end

function SWEP:Reload()
	if CLIENT then return end

	local portal1 = PortalManager.GetLinkageGroup(self:GetLinkageGroup())[PORTAL_TYPE_FIRST]
	local portal2 = PortalManager.GetLinkageGroup(self:GetLinkageGroup())[PORTAL_TYPE_SECOND]

	if not (IsValid(portal1) or IsValid(portal2)) then
		return
	end

	self:ClearPortals()

	self:SendWeaponAnim(ACT_VM_FIZZLE)
	self.NextIdleTime = CurTime() + 0.5
end

-- Viewbob Code, because why not? (Ported from P2ASW)
local g_lateralBob, g_verticalBob = 0,0
local HL2_BOB_CYCLE_MIN,HL2_BOB_CYCLE_MAX,HL2_BOB,HL2_BOB_UP = 1,.45,.002,.5
local bobtime,lastbobtime = 0,0

local function CalcViewmodelBob(self)
	local cycle = 0

	local plr = self:GetOwner():IsPlayer() && self:GetOwner()
	if !plr then return end

	local speed = plr:GetVelocity():Length()
	speed = math.Clamp(speed,-plr:GetMaxSpeed(), plr:GetMaxSpeed())
	local boboffset = math.Remap(speed,0, plr:GetMaxSpeed(), 0, 1)

	bobtime = bobtime + (CurTime()-lastbobtime)*boboffset
	lastbobtime = CurTime()

    // Vertical Bob
    cycle = bobtime - math.floor(bobtime/HL2_BOB_CYCLE_MAX)*HL2_BOB_CYCLE_MAX
	cycle = cycle / HL2_BOB_CYCLE_MAX

	if cycle < HL2_BOB_UP then
		cycle = math.pi * cycle / HL2_BOB_UP
	else
		cycle = math.pi+math.pi*(cycle-HL2_BOB_UP)/(1-HL2_BOB_UP)
	end

	g_verticalBob = speed*.005
	g_verticalBob = g_verticalBob*.3 + g_verticalBob*.7*math.sin(cycle)

	g_verticalBob = math.Clamp(g_verticalBob,-7,4)

    // Lateral Bob

	cycle = bobtime - math.floor(bobtime/HL2_BOB_CYCLE_MAX*2)*HL2_BOB_CYCLE_MAX*2
	cycle = cycle / (HL2_BOB_CYCLE_MAX*2)

	if cycle < HL2_BOB_UP then
		cycle = math.pi * cycle / HL2_BOB_UP
	else
		cycle = math.pi+math.pi*(cycle-HL2_BOB_UP)/(1-HL2_BOB_UP)
	end

	g_lateralBob = speed*.005
	g_lateralBob = g_lateralBob*.3 + g_lateralBob*.7*math.sin(cycle)
	g_lateralBob = math.Clamp(g_lateralBob,-7,4)
end

local function VectorMA(start,scale,dir,dest)
	dest.x = start.x + scale * dir.x
	dest.y = start.y + scale * dir.y
	dest.z = start.z + scale * dir.z
end

function SWEP:AddViewmodelBob(vm,origin,ang)
	local forward,right,up = ang:Forward(),ang:Right(),ang:Up()

	CalcViewmodelBob(self)

	/*local plr = self:GetOwner():IsPlayer() && self:GetOwner()
	if !plr then return end*/

	VectorMA(origin,g_verticalBob*.1,forward,origin)

	origin = origin + (g_verticalBob*.1*forward)

	VectorMA(origin,g_lateralBob*.8,right,origin)

	local rollAngle = g_verticalBob*.5
	local rotAxis = right:Cross(up):GetNormalized()
	local rotMatrix = ang
	rotMatrix:RotateAroundAxis(rotAxis,rollAngle)
	up = rotMatrix:Up()
	forward = rotMatrix:Forward()
	right = rotMatrix:Right()

	local pitchAngle = -g_verticalBob*.4
	rotAxis = right;
	rotMatrix:RotateAroundAxis(rotAxis,pitchAngle)
	up = rotMatrix:Up()
	forward = rotMatrix:Forward()

	local yawAngle = -g_lateralBob*.3
	rotAxis = up
	rotMatrix:RotateAroundAxis(rotAxis,yawAngle)
	forward = rotMatrix:Forward()

	ang = forward:AngleEx(up)

	return origin,ang
end

function SWEP:CalcViewModelView(vm,_,_,pos,ang)
	pos,ang = self:AddViewmodelBob(vm, pos, ang)

	return pos,ang
end

if SERVER then
    util.AddNetworkString("GP2.SyncPortalGunState")
    GP2_PortalGunStates = GP2_PortalGunStates or {}

    net.Receive("GP2.SyncPortalGunState", function(len, ply)
        local upgraded = net.ReadBool()
        local potato = net.ReadBool()
        local steamid = ply:SteamID()
        GP2_PortalGunStates[steamid] = {
            upgraded = upgraded,
            potato = potato
        }
            end)
end

if CLIENT then
    local function SyncPortalGunState()
        net.Start("GP2.SyncPortalGunState")
        net.WriteBool(GetConVar("gp2_portalgun_upgraded"):GetBool())
        net.WriteBool(GetConVar("gp2_portalgun_potato"):GetBool())
        net.SendToServer()
    end
    -- Synchroniser à chaque changement de convar
    cvars.AddChangeCallback("gp2_portalgun_upgraded", function() SyncPortalGunState() end, "gp2_portalgun_upgraded_sync")
    cvars.AddChangeCallback("gp2_portalgun_potato", function() SyncPortalGunState() end, "gp2_portalgun_potato_sync")
    -- Synchroniser à la connexion
    hook.Add("InitPostEntity", "GP2_PortalGunStateSyncInit", function()
        timer.Simple(1, function() SyncPortalGunState() end)
    end)
    -- Synchroniser quand on équipe l'arme
    hook.Add("WeaponEquipped", "GP2_PortalGunStateSync", function(weapon)
        if weapon:GetClass() == "weapon_portalgun" then
            timer.Simple(0.1, function() SyncPortalGunState() end)
        end
    end)
end

function SWEP:GetSyncedPortalGunState()
    if SERVER then
        local owner = self:GetOwner()
        if not IsValid(owner) or not owner:IsPlayer() then
                        return false, false
        end
        local steamid = owner:SteamID()
        local state = GP2_PortalGunStates and GP2_PortalGunStates[steamid]

	  if not state then
				return GetConVar("gp2_portalgun_upgraded"):GetBool(), GetConVar("gp2_portalgun_potato"):GetBool()
	  end
	          if state then
                        return (state.upgraded == true), (state.potato == true)
        else
                        return false, false
        end
    else
        return GetConVar("gp2_portalgun_upgraded"):GetBool(), GetConVar("gp2_portalgun_potato"):GetBool()
    end
end