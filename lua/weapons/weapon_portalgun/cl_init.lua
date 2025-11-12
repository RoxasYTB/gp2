include("weapon_portalgun/shared.lua")

CreateClientConVar("gp2_portalgun_upgraded", "0", true, false, "Portal Gun upgraded state")
CreateClientConVar("gp2_portalgun_potato", "0", true, false, "Portal Gun potato mode state")
CreateClientConVar("gp2_portal_color1", "2 114 210", true, true, "Color for Portal 1")
CreateClientConVar("gp2_portal_color2", "210 114 2", true, true, "Color for Portal 2")

local vector_origin = Vector(0,0,0)
local glow1 = Material("particle/particle_glow_05")
local g_lateralBob, g_verticalBob = 0,0
local HL2_BOB_CYCLE_MIN,HL2_BOB_CYCLE_MAX,HL2_BOB,HL2_BOB_UP = 1,.45,.002,.5
local bobtime,lastbobtime = 0,0

concommand.Add("gp2_upgrade", function() RunConsoleCommand("upgrade_portalgun") chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Commande upgrade_portalgun envoyée!") end, nil, "Raccourci pour upgrade_portalgun")
concommand.Add("gp2_potato", function() RunConsoleCommand("upgrade_potatogun") chat.AddText(Color(255, 200, 100), "[GP2] ", Color(255, 255, 255), "Commande upgrade_potatogun envoyée!") end, nil, "Raccourci pour upgrade_potatogun")
concommand.Add("gp2_normal", function() RunConsoleCommand("downgrade_potatogun") chat.AddText(Color(100, 200, 255), "[GP2] ", Color(255, 255, 255), "Portal Gun restauré en mode normal!") end, nil, "Raccourci pour downgrade_potatogun")
concommand.Add("gp2_reset", function() RunConsoleCommand("reset_portalgun") chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Portal Gun réinitialisé!") end, nil, "Raccourci pour reset_portalgun")
concommand.Add("gp2_help", function()
	chat.AddText(Color(255, 255, 100), "=== COMMANDES PORTAL GUN GP2-SDK ===")
	chat.AddText(Color(100, 255, 100), "upgrade_portalgun", Color(255, 255, 255), " ou ", Color(100, 255, 100), "gp2_upgrade", Color(255, 255, 255), " - Obtenir le Portal Gun")
	chat.AddText(Color(255, 200, 100), "upgrade_potatogun", Color(255, 255, 255), " ou ", Color(255, 200, 100), "gp2_potato", Color(255, 255, 255), " - Mode Potato")
	chat.AddText(Color(100, 200, 255), "downgrade_potatogun", Color(255, 255, 255), " ou ", Color(100, 200, 255), "gp2_normal", Color(255, 255, 255), " - Mode Normal")
	chat.AddText(Color(255, 100, 100), "reset_portalgun", Color(255, 255, 255), " ou ", Color(255, 100, 100), "gp2_reset", Color(255, 255, 255), " - Réinitialiser")
	chat.AddText(Color(255, 255, 100), "gp2_help", Color(255, 255, 255), " - Cette aide")
	chat.AddText(Color(255, 255, 100), "=====================================")
end, nil, "Affiche l'aide des commandes Portal Gun")

hook.Add("InitPostEntity", "GP2_ForcePortalGunState", function()
	local no_portal_gun = {["sp_a1_intro1"] = true, ["sp_a1_intro2"] = true}
	local single_portal_gun = {["sp_a1_intro3"] = true, ["sp_a1_intro4"] = true, ["sp_a1_intro5"] = true, ["sp_a1_intro6"] = true, ["sp_a1_intro7"] = true, ["sp_a1_wakeup"] = true}
	local map = game.GetMap()
	if not string.StartWith(map, "sp_") or map == "sp_a2_intro" then return end
	if no_portal_gun[map] then RunConsoleCommand("remove_portalgun")
	elseif single_portal_gun[map] then RunConsoleCommand("reset_portalgun")
	else RunConsoleCommand("upgrade_portalgun") end
end)

hook.Add("PlayerGiveWeapon", "GP2_BlockPortalGunSpawn", function(ply, wepname)
	if wepname == "weapon_portalgun" then
		local no_portal_gun = {["sp_a1_intro1"] = true, ["sp_a1_intro2"] = true}
		local map = game.GetMap()
		if no_portal_gun[map] then return false end
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

local function SyncPortalGunState()
	net.Start("GP2.SyncPortalGunState")
	net.WriteBool(GetConVar("gp2_portalgun_upgraded"):GetBool())
	net.WriteBool(GetConVar("gp2_portalgun_potato"):GetBool())
	net.SendToServer()
end

cvars.AddChangeCallback("gp2_portalgun_upgraded", function() SyncPortalGunState() end, "gp2_portalgun_upgraded_sync")
cvars.AddChangeCallback("gp2_portalgun_potato", function() SyncPortalGunState() end, "gp2_portalgun_potato_sync")
hook.Add("InitPostEntity", "GP2_PortalGunStateSyncInit", function() timer.Simple(1, function() SyncPortalGunState() end) end)
hook.Add("WeaponEquipped", "GP2_PortalGunStateSync", function(weapon) if weapon:GetClass() == "weapon_portalgun" then timer.Simple(0.1, function() SyncPortalGunState() end) end end)

function SWEP:ViewModelDrawn(vm)
	local owner = vm:GetOwner()
	local vm0 = owner:GetViewModel(0)
	local vm1 = owner:GetViewModel(1)

	if not self.TopLightFirstPersonAttachment and IsValid(vm0) then self.TopLightFirstPersonAttachment = vm0:LookupAttachment("Body_light") end
	if not self.TopLightFirstPerson2Attachment and IsValid(vm1) then self.TopLightFirstPerson2Attachment = vm1:LookupAttachment("Body_light") end

	local lastPlacedPortal = self:GetLastPlacedPortal()
	local lightColor = vector_origin
	if IsValid(lastPlacedPortal) and lastPlacedPortal:GetClass() == "prop_portal" and lastPlacedPortal.GetColorVector then
		lightColor = lastPlacedPortal:GetColorVector() * 0.2
		lightColor.g = lightColor.g * 1.05
	end

	if IsValid(self.TopLightFirstPerson) then self.TopLightFirstPerson:SetControlPoint(1, lightColor) end
	if IsValid(self.TopLightFirstPerson2) then self.TopLightFirstPerson2:SetControlPoint(1, lightColor) end
	self.TopLightColor = lightColor

	if not self.TopLightColor then self.TopLightColor = Vector() end

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
	if IsValid(self.TopLightFirstPerson) and vm == vm0 then self.TopLightFirstPerson:Render() end

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
	if IsValid(self.TopLightFirstPerson2) and vm == vm1 then self.TopLightFirstPerson2:Render() end

	if not IsValid(vm0) or not IsValid(vm1) then return end
	if vm0:GetModel() != vm1:GetModel() then return end

	if vm == vm1 then
		if not self.FirstPersonMuzzleAttachment then self.FirstPersonMuzzleAttachment = vm1:LookupAttachment("muzzle") end
		if not self.FirstPersonMuzzleAttachment2 then self.FirstPersonMuzzleAttachment2 = vm1:LookupAttachment("muzzle") end

		local entityInUse = owner:GetEntityInUse()
		self.HoldingParticleFirstPersonDieTime = self.HoldingParticleFirstPersonDieTime or CurTime() + 0.5

		if not IsValid(self.HoldingParticleFirstPerson) then
			self.HoldingParticleFirstPerson = CreateParticleSystem(vm1, "portalgun_beam_holding_FP", PATTACH_POINT_FOLLOW, self.FirstPersonMuzzleAttachment2)
			if IsValid(self.HoldingParticleFirstPerson) then
				self.HoldingParticleFirstPerson:AddControlPoint(1, vm1, PATTACH_POINT_FOLLOW, "Arm1_attach3")
				self.HoldingParticleFirstPerson:AddControlPoint(2, vm1, PATTACH_POINT_FOLLOW, "Arm2_attach3")
				self.HoldingParticleFirstPerson:AddControlPoint(3, vm1, PATTACH_POINT_FOLLOW, "Arm3_attach3")
				self.HoldingParticleFirstPerson:AddControlPoint(4, owner, PATTACH_CUSTOMORIGIN)
				self.HoldingParticleFirstPerson:SetControlPointEntity(4, vm1)
				if IsValid(entityInUse) then self.HoldingParticleFirstPerson:AddControlPoint(5, entityInUse, PATTACH_ABSORIGIN_FOLLOW, 0)
				else self.HoldingParticleFirstPerson:AddControlPoint(5, vm1, PATTACH_POINT_FOLLOW, "muzzle") end
				self.HoldingParticleFirstPersonDieTime = CurTime() + 0.5
			end
		elseif CurTime() > self.HoldingParticleFirstPersonDieTime then
			if IsValid(self.HoldingParticleFirstPerson) then self.HoldingParticleFirstPerson:StopEmission(false, true) end
			self.HoldingParticleFirstPerson = NULL
		end
	else
		if IsValid(self.HoldingParticleFirstPerson) then self.HoldingParticleFirstPerson:StopEmission(false, true) self.HoldingParticleFirstPerson = NULL end
	end
end

function SWEP:DrawWorldModel(studio)
	local lastPlacedPortal = self:GetLastPlacedPortal()
	local lightColor = vector_origin
	if IsValid(lastPlacedPortal) and lastPlacedPortal:GetClass() == "prop_portal" and lastPlacedPortal.GetColorVector then
		lightColor = lastPlacedPortal:GetColorVector() * 0.2
		lightColor.g = lightColor.g * 1.05
	end

	if not self.TopLightThirdPersonAttachment then self.TopLightThirdPersonAttachment = self:LookupAttachment("Body_light") end
	if not self.TopLightColor then self.TopLightColor = Vector() end

	if not IsValid(self.TopLightThirdPerson) then
		self.TopLightThirdPerson = CreateParticleSystem(self, "portalgun_top_light_thirdperson", PATTACH_POINT_FOLLOW, self.TopLightThirdPersonAttachment)
		if IsValid(self.TopLightThirdPerson) then self.TopLightThirdPerson:AddControlPoint(4, self, PATTACH_POINT_FOLLOW, "Beam_point5") end
	else
		self.TopLightThirdPerson:Render()
		self.TopLightThirdPerson:SetControlPoint(1, lightColor)
		if self.TopLightColor ~= lightColor then self.TopLightColor = lightColor end
	end
	self:DrawModel(studio)
end

local function CalcViewmodelBob(self)
	local cycle = 0
	local plr = self:GetOwner():IsPlayer() && self:GetOwner()
	if !plr then return end
	local speed = plr:GetVelocity():Length()
	speed = math.Clamp(speed,-plr:GetMaxSpeed(), plr:GetMaxSpeed())
	local boboffset = math.Remap(speed,0, plr:GetMaxSpeed(), 0, 1)
	bobtime = bobtime + (CurTime()-lastbobtime)*boboffset
	lastbobtime = CurTime()
	cycle = bobtime - math.floor(bobtime/HL2_BOB_CYCLE_MAX)*HL2_BOB_CYCLE_MAX
	cycle = cycle / HL2_BOB_CYCLE_MAX
	if cycle < HL2_BOB_UP then cycle = math.pi * cycle / HL2_BOB_UP else cycle = math.pi+math.pi*(cycle-HL2_BOB_UP)/(1-HL2_BOB_UP) end
	g_verticalBob = speed*.005
	g_verticalBob = g_verticalBob*.3 + g_verticalBob*.7*math.sin(cycle)
	g_verticalBob = math.Clamp(g_verticalBob,-7,4)
	cycle = bobtime - math.floor(bobtime/HL2_BOB_CYCLE_MAX*2)*HL2_BOB_CYCLE_MAX*2
	cycle = cycle / (HL2_BOB_CYCLE_MAX*2)
	if cycle < HL2_BOB_UP then cycle = math.pi * cycle / HL2_BOB_UP else cycle = math.pi+math.pi*(cycle-HL2_BOB_UP)/(1-HL2_BOB_UP) end
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
	rotAxis = right
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
