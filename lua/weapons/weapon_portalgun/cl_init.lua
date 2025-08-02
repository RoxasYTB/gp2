include("shared.lua")

-- ConVars
local reticle = CreateClientConVar("portal_crosshair","1",true,false)
local system = CreateClientConVar("portal_crosshair_system","1",true,false)
local portalonly = CreateClientConVar("portal_portalonly","0",true,false)
local allsurfaces = CreateClientConVar("portal_allsurfaces","0",true,false)
local snd_portal2 = CreateClientConVar("portal_sound","0",true,false)
local CarryAnim_P1 = CreateClientConVar("portal_carryanim_p1","0",true,false)
local drawArm = CreateClientConVar("portal_arm","0",true,false)

-- Optimized Color System
local PORTAL_COLORS = {
	-- Index by portal type (1 = TYPE_BLUE, 2 = TYPE_ORANGE)
	[1] = { -- TYPE_BLUE colors
		[14] = {{25,25,25}}, -- Gray2
		[13] = {{75,75,75}}, -- Gray
		[12] = {{255,255,255}}, -- White
		[11] = { -- Pink2
			[2] = {{250,220,242},{255,154,230},{255,22,198}}, -- Contraste Light
			[1] = {{243,173,213},{255,116,186},{255,65,142}}, -- Normal
			[0] = {{140,70,91},{175,35,78},{209,0,62}} -- Dark
		},
		[10] = { -- Pink
			[2] = {{250,220,249},{255,154,255},{255,22,255}},
			[1] = {{243,173,242},{255,116,255},{252,65,255}},
			[0] = {{139,70,140},{174,35,175},{205,0,205}}
		},
		[9] = { -- Purple
			[2] = {{244,220,250},{238,154,255},{216,22,255}},
			[1] = {{217,173,243},{194,116,255},{150,65,255}},
			[0] = {{95,70,140},{84,35,175},{73,0,209}}
		},
		[8] = { -- Blue Dark
			[2] = {{220,225,250},{153,172,255},{20,63,255}},
			[1] = {{173,183,243},{116,133,255},{64,83,255}},
			[0] = {{70,70,140},{35,35,175},{0,0,209}}
		},
		[7] = { -- Blue
			[2] = {{220,246,250},{153,243,255},{20,229,255}},
			[1] = {{173,222,243},{116,202,255},{64,160,255}},
			[0] = {{70,98,140},{35,91,175},{0,86,209}}
		},
		[6] = { -- Blue Light
			[2] = {{220,249,250},{153,255,255},{20,255,255}},
			[1] = {{173,242,243},{116,255,255},{64,255,255}},
			[0] = {{70,139,140},{35,174,175},{0,209,209}}
		},
		[5] = { -- Green2
			[2] = {{220,250,244},{156,255,239},{26,255,219}},
			[1] = {{173,243,237},{116,255,231},{64,255,188}},
			[0] = {{70,140,111},{35,175,117},{0,209,122}}
		},
		[4] = { -- Green
			[2] = {{225,249,217},{174,255,145},{68,255,0}},
			[1] = {{169,238,142},{128,255,79},{85,255,33}},
			[0] = {{70,140,70},{35,175,35},{0,209,0}}
		},
		[3] = { -- Green1
			[2] = {{246,249,217},{244,255,145},{230,255,0}},
			[1] = {{228,238,142},{233,255,79},{199,255,33}},
			[0] = {{116,140,70},{127,175,35},{136,209,0}}
		},
		[2] = { -- Yellow
			[2] = {{249,249,217},{255,255,145},{255,255,0}},
			[1] = {{237,238,142},{255,255,79},{255,247,33}},
			[0] = {{140,136,70},{175,167,35},{209,199,0}}
		},
		[1] = { -- Orange
			[2] = {{249,247,217},{255,248,145},{255,239,0}},
			[1] = {{238,205,142},{255,195,79},{255,160,32}},
			[0] = {{140,98,70},{175,91,35},{209,86,0}}
		},
		[0] = { -- Red
			[2] = {{249,217,217},{255,145,145},{255,0,0}},
			[1] = {{238,148,142},{255,89,79},{255,44,33}},
			[0] = {{140,70,70},{175,35,35},{209,0,0}}
		}
	},
	[2] = { -- TYPE_ORANGE colors (same structure)
		[14] = {{25,25,25}},
		[13] = {{75,75,75}},
		[12] = {{255,255,255}},
		[11] = {
			[2] = {{250,220,242},{255,154,230},{255,22,198}},
			[1] = {{243,173,213},{255,116,186},{255,65,142}},
			[0] = {{140,70,91},{175,35,78},{209,0,62}}
		},
		[10] = {
			[2] = {{250,220,249},{255,154,255},{255,22,255}},
			[1] = {{243,173,242},{255,116,255},{252,65,255}},
			[0] = {{139,70,140},{174,35,175},{205,0,205}}
		},
		[9] = {
			[2] = {{244,220,250},{238,154,255},{216,22,255}},
			[1] = {{217,173,243},{194,116,255},{150,65,255}},
			[0] = {{95,70,140},{84,35,175},{73,0,209}}
		},
		[8] = {
			[2] = {{220,225,250},{153,172,255},{20,63,255}},
			[1] = {{173,183,243},{116,133,255},{64,83,255}},
			[0] = {{70,70,140},{35,35,175},{0,0,209}}
		},
		[7] = {
			[2] = {{220,246,250},{153,243,255},{20,229,255}},
			[1] = {{173,222,243},{116,202,255},{64,160,255}},
			[0] = {{70,98,140},{35,91,175},{0,86,209}}
		},
		[6] = {
			[2] = {{220,249,250},{153,255,255},{20,255,255}},
			[1] = {{173,242,243},{116,255,255},{64,255,255}},
			[0] = {{70,139,140},{35,174,175},{0,209,209}}
		},
		[5] = {
			[2] = {{220,250,244},{156,255,239},{26,255,219}},
			[1] = {{173,243,237},{116,255,231},{64,255,188}},
			[0] = {{70,140,111},{35,175,117},{0,209,122}}
		},
		[4] = {
			[2] = {{225,249,217},{174,255,145},{68,255,0}},
			[1] = {{169,238,142},{128,255,79},{85,255,33}},
			[0] = {{70,140,70},{35,175,35},{0,209,0}}
		},
		[3] = {
			[2] = {{246,249,217},{244,255,145},{230,255,0}},
			[1] = {{228,238,142},{233,255,79},{199,255,33}},
			[0] = {{116,140,70},{127,175,35},{136,209,0}}
		},
		[2] = {
			[2] = {{249,249,217},{255,255,145},{255,255,0}},
			[1] = {{237,238,142},{255,255,79},{255,247,33}},
			[0] = {{140,136,70},{175,167,35},{209,199,0}}
		},
		[1] = {
			[2] = {{249,247,217},{255,248,145},{255,239,0}},
			[1] = {{238,205,142},{255,195,79},{255,160,32}},
			[0] = {{140,98,70},{175,91,35},{209,86,0}}
		},
		[0] = {
			[2] = {{249,217,217},{255,145,145},{255,0,0}},
			[1] = {{238,148,142},{255,89,79},{255,44,33}},
			[0] = {{140,70,70},{175,35,35},{209,0,0}}
		}
	}
}

-- Optimized function to get portal color
local function GetPortalColor(portalType, isValid, weapon)
	-- Check if any portals are actually placed
	if weapon and IsValid(weapon.Owner) then
		local p1 = weapon.Owner:GetNWEntity("Portal:Blue")
		local p2 = weapon.Owner:GetNWEntity("Portal:Orange")
		local hasPortals = IsValid(p1) or IsValid(p2)

		-- If no portals are placed, return red color
		if not hasPortals then
			return Color(0, 0, 0, 1)
		end
	end

	local colorIdx = GetConVarNumber(portalType == TYPE_BLUE and "portal_color_1" or "portal_color_2")
	local contraste = GetConVarNumber(portalType == TYPE_BLUE and "portal_color_contraste_1" or "portal_color_contraste_2")
	local saturation = GetConVarNumber(portalType == TYPE_BLUE and "portal_color_saturation_1" or "portal_color_saturation_2")

	local portalTypeIdx = portalType == TYPE_BLUE and 1 or 2

	-- Iterate from highest to lowest color index
	for i = 14, 0, -1 do
		if colorIdx >= i then
			local colorData = PORTAL_COLORS[portalTypeIdx][i]
			if not colorData then break end

			-- Simple colors (no contraste/saturation variants)
			if type(colorData[1][1]) == "number" then
				return Color(colorData[1][1], colorData[1][2], colorData[1][3], 255)
			end

			-- Complex colors with contraste/saturation
			local contrasteIdx = contraste >= 2 and 2 or (contraste >= 1 and 1 or 0)
			local saturationIdx = saturation >= 2 and 1 or (saturation >= 1 and 2 or 3)

			local rgb = colorData[contrasteIdx][saturationIdx]
			if rgb then
				return Color(rgb[1], rgb[2], rgb[3], 255)
			end
			break
		end
	end

	-- Default fallback
	return Color(255, 255, 255, 255)
end

-- Elements tables
local VElements = {
	["BodyLight"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Base", rel = "", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.0165, y = 0.0165 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BodyLight1"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Base", rel = "", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.0165, y = 0.0165 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BodyLight2"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Base", rel = "", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.0165, y = 0.0165 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BodyLight3"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Base", rel = "", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.0165, y = 0.0165 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BodyLight4"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Base", rel = "", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.0165, y = 0.0165 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BodyLight5"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Base", rel = "", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.0165, y = 0.0165 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint1"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Front_Cover", rel = "", pos = Vector(-0.101, -2.401, -3.1), size = { x = 0.035, y = 0.035 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint2"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Front_Cover", rel = "", pos = Vector(-0.01, -2.391, -3.401), size = { x = 0.035, y = 0.035 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint3"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Front_Cover", rel = "", pos = Vector(-0.03, -2.381, -3.701), size = { x = 0.035, y = 0.035 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint4"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Front_Cover", rel = "", pos = Vector(-0.04, -2.36, -4), size = { x = 0.035, y = 0.035 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint5"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Front_Cover", rel = "", pos = Vector(-0.051, -2.35, -4.301), size = { x = 0.035, y = 0.035 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["InsideEffects"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Front_Cover", rel = "", pos = Vector(0, -2.201, 0), size = { x = 0.035, y = 0.035 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
}

local WElements = {
	["BodyLight"] = { type = "Sprite", sprite = "sprites/portalgun_light", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7, 1.40, -4.801), size = { x = 0.03, y = 0.03 }, color = Color(255, 255, 255, 255), nocull = false, additive = false, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint1"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.647, 1.32, -2.596), size = { x = 0.04, y = 0.04 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint2"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(11.744, 1.32, -2.754), size = { x = 0.04, y = 0.04 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint3"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(12.845, 1.32, -2.915), size = { x = 0.04, y = 0.04 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["BeamPoint4"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(20.034, 1.161, -3.934), size = { x = 0.04, y = 0.04 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["InsideEffects"] = { type = "Sprite", sprite = "sprites/portalgun_effects", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(14.048, 1.32, -2.997), size = { x = 0.04, y = 0.04 }, color = Color(255, 255, 255, 255), nocull = false, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
}

local ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(0.0001, 0.0001, 0.0001), pos = Vector(-30, 0, 0), angle = Angle(0, 0, 0) }
}

-- Variables
local BobTime = 0
local BobTimeLast = CurTime()
local SwayAng = nil
local SwayOldAng = Angle()
local SwayDelta = Angle()

SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false

-- Fonts
local tblFonts = {
	["WeaponIcons_lua"] = {
		font = "HalfLife2",
		size = ScreenScale(50),
		weight = 550,
		symbol = false,
		antialias = true,
		additive = true
	},
	["WeaponIconsSelected_lua"] = {
		font = "HalfLife2",
		size = ScreenScale(50),
		weight = 550,
		blursize = 7,
		scanlines = 3,
		symbol = false,
		antialias = true,
		additive = true
	}
}

for k,v in SortedPairs(tblFonts) do
	surface.CreateFont(k, v)
end

/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/

function SWEP:Initialize()
	self.Weapon:SetNetworkedInt("LastPortal",0,true)
	self:SetWeaponHoldType(self.HoldType)

	// Create a new table for every weapon instance
	self.VElements = table.FullCopy(VElements)
	self.WElements = table.FullCopy(WElements)
	self.ViewModelBoneMods = table.FullCopy(ViewModelBoneMods)

	// init view model bone build function
	if IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)

			// Init viewmodel visibility
			if (self.ShowViewModel == nil or self.ShowViewModel) then
				vm:SetColor(Color(255,255,255,255))
			else
				// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
				vm:SetColor(Color(255,255,255,1))
				// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
				// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
				vm:SetMaterial("Debug/hsv")
			end
		end
	end
end

net.Receive('PORTALGUN_PICKUP_PROP', function()
	local self = net.ReadEntity()
	local ent = net.ReadEntity()

	if !IsValid(ent) then
		--Drop it.
		if self.PickupSound then
			self.PickupSound:Stop()
			self.PickupSound2:Stop()
			self.PickupSoundStop = CreateSound(self, 'weapons/physcannon/portal2/hold_loop_stop.wav')
			if snd_portal2:GetBool() then
				self.PickupSoundStop:Play()
			end
			self.PickupSound = nil
		end
		if self.ViewModelOverride then
			self.ViewModelOverride:Remove()
		end
	else
		--Pick it up.
		if !self.PickupSound and CLIENT then
			self.PickupSound = CreateSound(self, 'weapons/physcannon/hold_loop.wav')
			self.PickupSound2 = CreateSound(self, 'weapons/physcannon/portal2/hold_loop.wav')
			if !snd_portal2:GetBool() then
				self.PickupSound:Play()
			else
				self.PickupSound2:Play()
			end
			self.PickupSound:ChangeVolume(0.25, 0)
			self.PickupSound2:ChangeVolume(100, 0)
		end

		self.ViewModelOverride = ClientsideModel(self.ViewModel,RENDERGROUP_OPAQUE)
		self.ViewModelOverride:SetPos(EyePos()-LocalPlayer():GetForward()*(self.ViewModelFOV/5))
		self.ViewModelOverride:SetAngles(EyeAngles())
		self.ViewModelOverride.AutomaticFrameAdvance = true
		self.ViewModelOverride.startCarry = false

		function self.ViewModelOverride.PreDraw(vm)
			vm:SetColor(Color(255,255,255))
			local oldorigin = EyePos()
			local pos, ang = self:CalcViewModelView(vm,oldorigin,EyeAngles(),vm:GetPos(),vm:GetAngles())
			return pos, ang
		end
	end

	self.HoldenProp = ent
end)

local GravityLight,GravityBeam = Material("sprites/grav_flare"),Material("sprites/grav_beam","unlitgeneric")
local GravitySprites = {
	{bone = "ValveBiped.Arm1_C", pos = Vector(-1.25 ,-0.10, 1.06), size = { x = 0.02, y = 0.02 }},
	{bone = "ValveBiped.Arm2_C", pos = Vector(0.10, 1.25, 1.00), size = { x = 0.02, y = 0.02 }},
	{bone = "ValveBiped.Arm3_C", pos = Vector(0.10, 1.25, 1.05), size = { x = 0.02, y = 0.02 }}
}

function SWEP:DrawPickupEffects(ent)
	//Draw the lights
	local lightOrigins = {}
	for k,v in pairs(GravitySprites) do
		local bone = ent:LookupBone(v.bone)
		if (!bone) then return end

		local pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if (IsValid(self.Owner) and self.Owner:IsPlayer() and
			ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r // Fixes mirrored models
		end

		if (!pos) then continue end

		local col = Color(255, 255, 255, math.Rand(96,128))
		local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

		lightOrigins[k] = drawpos

		render.SetMaterial(GravityLight)
		for i=0, 1, .2 do --visible in daylight.
			render.DrawSprite(drawpos, v.size.x*256, v.size.y*256, col)
		end
	end

	if !lightOrigins[1] or !lightOrigins[2] or !lightOrigins[3] then return end

	local endpos = self.HoldenProp:GetPos()

	local dir = (endpos - lightOrigins[1])
	local dir2 = (endpos - lightOrigins[2])
	local dir3 = (endpos - lightOrigins[3])
	local increment = dir:Length() / 2
	local increment2 = dir2:Length() / 2
	local increment3 = dir2:Length() / 2
	dir:Normalize()
	dir2:Normalize()
	dir3:Normalize()

	render.SetMaterial(GravityBeam)

	-- 1 Beam
	render.StartBeam(3)
	render.AddBeam(lightOrigins[1], 0.5, CurTime() + (1/10), Color(255, 255, 255, 255))

	for i = 1, 20 do
		local point = (lightOrigins[1] + dir * (i * increment)) + VectorRand() * math.random(0.1, 1)
		local tcoord = CurTime() + (20/50) * i
		render.AddBeam(point, 2, tcoord, Color(255, 255, 255, 255))
	end

	render.AddBeam(endpos, 0, CurTime() + (1/10), Color(255, 255, 255, 255))
	render.EndBeam()

	-- 2 Beam
	render.StartBeam(3)
	render.AddBeam(lightOrigins[2], 0.5, CurTime() + (1/10), Color(255, 255, 255, 255))

	for i = 1, 20 do
		local point = (lightOrigins[2] + dir2 * (i * increment2)) + VectorRand() * math.random(0.1, 1)
		local tcoord = CurTime() + (20/50) * i
		render.AddBeam(point, 2, tcoord, Color(255, 255, 255, 255))
	end

	render.AddBeam(endpos, 0, CurTime() + (1/10), Color(255, 255, 255, 255))
	render.EndBeam()
end

function SWEP:DoPickupAnimations(vm)
	if CarryAnim_P1:GetBool() then
		vm:SetSequence(vm:LookupSequence("primary_extended"))
	else
		vm:SetSequence(vm:LookupSequence("carry"))
	end
end

hook.Add("HUDPaint", "View model pickup override", function(vm)
	if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) then
		local wep = LocalPlayer():GetActiveWeapon()
		if wep:GetClass() == "weapon_portalgun" then
			if wep.ViewModelOverride then
				if IsValid(wep.HoldenProp) then
					wep:DoPickupAnimations(wep.ViewModelOverride)
				else
					if wep.ViewModelOverride then
						wep.ViewModelOverride:Remove()
						wep.ViewModelOverride = nil
					end
				end
			end
		end
	end
end)

local VGravityLight = Material("sprites/glow04_noz")
local VGravitySprites = {
	{bone = "ValveBiped.Arm1_A", pos = Vector(0, 0, 0), size = { x = 0.018, y = 0.018 }},
	{bone = "ValveBiped.Arm2_A", pos = Vector(0, 0, 0), size = { x = 0.018, y = 0.018 }},
	{bone = "ValveBiped.Arm3_A", pos = Vector(0, 0, 0.30), size = { x = 0.018, y = 0.018 }},
	{bone = "ValveBiped.Arm1_B", pos = Vector(0, 0, 0), size = { x = 0.018, y = 0.018 }},
	{bone = "ValveBiped.Arm2_B", pos = Vector(0, 0.20, -0.10), size = { x = 0.018, y = 0.018 }},
	{bone = "ValveBiped.Arm3_B", pos = Vector(-0.10, 0.30, -0.10), size = { x = 0.018, y = 0.018 }}
}

local VWhiteLight = Material("sprites/glow04_noz")
local VWhiteSprites = {
	{bone = "ValveBiped.Base", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.003, y = 0.003 }},
	{bone = "ValveBiped.Base", pos = Vector(0.25, -5.45, 10.5), size = { x = 0.003, y = 0.003 }}
}

function SWEP:ViewModelDrawn(vm)
	// Draw the gravity lights (orange effect)
	local lightOrigins = {}
	for k,v in pairs(VGravitySprites) do
		local bone = vm:LookupBone(v.bone)
		if (!bone) then return end

		local pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = vm:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if (IsValid(self.Owner) and self.Owner:IsPlayer() and
			vm == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r // Fixes mirrored models
		end

		if (!pos) then continue end

		local col = Color(255, 128, 0, 0)
		local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		local _sin = math.abs(math.sin(CurTime() * (0.1) * math.Rand(0.0075,0.05)))

		render.SetMaterial(VGravityLight)
		render.DrawSprite(drawpos, v.size.x*128+_sin, v.size.y*128+_sin, col)
	end

	// Draw the white portal lights with optimized color system
	for k,v in pairs(VWhiteSprites) do
		local bone = vm:LookupBone(v.bone)
		if (!bone) then return end

		local pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = vm:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if (IsValid(self.Owner) and self.Owner:IsPlayer() and
			vm == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r // Fixes mirrored models
		end

		if (!pos) then continue end

		local last = self:GetNetworkedInt("LastPortal",0)
		local col = GetPortalColor(last, true, self) -- Pass weapon instance to check portal status
		local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z

		render.SetMaterial(VWhiteLight)
		render.DrawSprite(drawpos, v.size.x*128, v.size.y*128, col)
	end

	if (!self.VElements) then return end
	self:UpdateBonePositions(vm)

	for k, name in pairs(self.VElements) do
		local v = name
		if (!v) then break end
		if (v.hide) then continue end

		local sprite = Material(v.sprite)

		if (!v.bone) then continue end

		local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)

		if (!pos) then continue end

		if (v.type == "Sprite" and sprite) then
			local last = self:GetNetworkedInt("LastPortal",0)
			local col = GetPortalColor(last, true, self) -- Pass weapon instance to check portal status

			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			local _sin = math.abs(math.sin(CurTime() * 1)) * .3
			col.a = math.sin(CurTime()*math.pi)*((128-96)/2)+112

			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x*128.0, v.size.y*128.0, col)

		elseif (v.type == "Quad" and v.draw_func) then
			v.draw_func(self)
		elseif (v.type == "Model" and IsValid(model) and model.RenderOverride) then
			model.RenderOverride = nil
			model.RenderOverride = function()
				render.Model({
					model = model:GetModel(),
					pos = pos,
					angle = ang
				})
			end
		end
	end

	if IsValid(self.HoldenProp) then
		self:DrawPickupEffects(vm)
	end
end

SWEP.wRenderOrder = nil
function SWEP:DrawWorldModel()
	if (self.ShowWorldModel == nil or self.ShowWorldModel) then
		self:DrawModel()
	end

	if (!self.WElements) then return end

	if (!self.wRenderOrder) then
		self.wRenderOrder = {}
		for k, v in pairs(self.WElements) do
			if (v.type == "Model") then
				table.insert(self.wRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end
	end

	local bone_ent
	if (IsValid(self.Owner)) then
		bone_ent = self.Owner
	else
		// when the weapon is dropped
		bone_ent = self
	end

	for k, name in pairs(self.wRenderOrder) do
		local v = self.WElements[name]
		if (!v) then self.wRenderOrder = nil break end
		if (v.hide) then continue end

		local pos, ang
		if (v.bone) then
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
		else
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
		end

		if (!pos) then continue end

		local model = v.modelEnt
		local sprite = Material(v.sprite)

		if (v.type == "Model" and IsValid(model)) then
			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)

			if (v.material == "") then
				model:SetMaterial("")
			elseif (IsValid(v.material)) then
				model:SetMaterial(v.material)
			end

			if (v.skin and v.skin ~= model:GetSkin()) then
				model:SetSkin(v.skin)
			end

			if (v.bodygroup) then
				for k, v in pairs(v.bodygroup) do
					if (model:GetBodygroup(k) ~= v) then
						model:SetBodygroup(k, v)
					end
				end
			end

			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end

		elseif (v.type == "Sprite" and sprite) then
			local last = self:GetNetworkedInt("LastPortal",0)
			local col = GetPortalColor(last, true, self) -- Pass weapon instance to check portal status

			render.SetMaterial(sprite)
			for i=0, 1, .2 do --visible in daylight.
				render.DrawSprite(pos, v.size.x*128, v.size.y*128, col)
			end

		elseif (v.type == "Quad" and v.draw_func) then
			v.draw_func(self)
		end
	end
end

function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
	local bone, pos, ang
	if (tab.rel and tab.rel ~= "") then
		local v = basetab[tab.rel]
		if (!v) then return end
		// Technically, if there exists an element with the same name as a bone
		// you can get in an infinite loop. Let's just hope nobody's that stupid.
		pos, ang = self:GetBoneOrientation(basetab, v, ent)
		if (!pos) then return end
		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)
	else
		bone = ent:LookupBone(bone_override or tab.bone)
		if (!bone) then return end
		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end
		if (IsValid(self.Owner) and self.Owner:IsPlayer() and
			ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r // Fixes mirrored models
		end
	end
	return pos, ang
end

local allbones
local hasGarryFixedBoneScalingYet = false

function SWEP:UpdateBonePositions(vm)
	if self.ViewModelBoneMods then
		if (!vm:GetBoneCount()) then return end

		// !! WORKAROUND !! //
		// We need to check all model names :/
		local loopthrough = self.ViewModelBoneMods
		if (!hasGarryFixedBoneScalingYet) then
			allbones = {}
			for i=0, vm:GetBoneCount() do
				local bonename = vm:GetBoneName(i)
				if (self.ViewModelBoneMods[bonename]) then
					allbones[bonename] = self.ViewModelBoneMods[bonename]
				else
					allbones[bonename] = {
						scale = Vector(1,1,1),
						pos = Vector(0,0,0),
						angle = Angle(0,0,0)
					}
				end
			end

			hasGarryFixedBoneScalingYet = true
			loopthrough = allbones
		end
		// !! ----------- !! //

		for k, v in pairs(loopthrough) do
			local bone = vm:LookupBone(k)
			if (!bone) then continue end

			// !! WORKAROUND !! //
			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local ms = Vector(1,1,1)
			if (!hasGarryFixedBoneScalingYet) then
				local cur = vm:GetBoneParent(bone)
				while(cur >= 0) do
					local pscale = loopthrough[vm:GetBoneName(cur)].scale
					ms = ms * pscale
					cur = vm:GetBoneParent(cur)
				end
			end

			s = s * ms
			// !! ----------- !! //

			if vm:GetManipulateBoneScale(bone) ~= s then
				vm:ManipulateBoneScale(bone, s)
			end
			if vm:GetManipulateBoneAngles(bone) ~= v.angle then
				vm:ManipulateBoneAngles(bone, v.angle)
			end
			if vm:GetManipulateBonePosition(bone) ~= p then
				vm:ManipulateBonePosition(bone, p)
			end
		end
	else
		self:ResetBonePositions(vm)
	end
end

function SWEP:ResetBonePositions(vm)
	if (!vm:GetBoneCount()) then return end
	for i=0, vm:GetBoneCount() do
		vm:ManipulateBoneScale(i, Vector(1, 1, 1))
		vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		vm:ManipulateBonePosition(i, Vector(0, 0, 0))
	end
end

function table.FullCopy(tab)
	if (!tab) then return nil end
	local res = {}
	for k, v in pairs(tab) do
		if (type(v) == "table") then
			res[k] = table.FullCopy(v) // recursion ho!
		elseif (type(v) == "Vector") then
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end
	return res
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

/*---------------------------------------------------------
   Desc: Overwrites the default GMod v_model system.
---------------------------------------------------------*/

local sin, abs, pi, clamp, min = math.sin, math.abs, math.pi, math.Clamp, math.min

function SWEP:CalcViewModelView(ViewModel, oldPos, oldAng, pos, ang)
	BobTime = BobTime + FrameTime() * 1.7 * LocalPlayer():GetVelocity():Length() / 320
	SwayOldAng = SwayOldAng or ang

	local vel = LocalPlayer():GetVelocity():Length()
	local speed = clamp(vel / 320, 0.01, 1) * 1.7

	if SwayAng == nil then SwayAng = ang end

	SwayAng.p = clamp(SwayAng.p + (ang.p - SwayAng.p) * speed, ang.p - 90, ang.p + 90)
	SwayAng.y = clamp(SwayAng.y + (ang.y - SwayAng.y) * speed, ang.y - 90, ang.y + 90)
	SwayAng.r = clamp(SwayAng.r + (ang.r - SwayAng.r) * speed, ang.r - 90, ang.r + 90)

	SwayDelta = SwayAng - SwayOldAng
	SwayOldAng = Angle(SwayAng.p, SwayAng.y, SwayAng.r)

	local lengthScale = speed * 0.5
	local bobScale = speed * 0.5
	local rollScale = speed * 0.5

	if self.Owner:IsOnGround() then
		bobScale = bobScale * 0.5
	end

	return oldPos + oldAng:Up() * SwayDelta.p + oldAng:Right() * SwayDelta.y + oldAng:Up() * oldAng.p / 90 * 2, oldAng
end

function SWEP:GetTracerOrigin()
	local ViewModel = self.Owner:GetViewModel()
	local obj = ViewModel:GetAttachment(ViewModel:LookupAttachment("muzzle"))
	if obj and obj.Pos then
		return obj.Pos
	end
	return self:GetPos()
end

-- HUD Drawing positions and sizes
local leftpos = {x=-2,y=-4}
local rightpos = {x=10,y=18}
local sizeLarge = {w=46,h=64}
local sizeSmall = {w=30,h=64}

-- HUD Color presets (compact)
local c_Gray2 = Color(25,25,25,255)
local c_Gray = Color(75,75,75,255)
local c_Gray1 = Color(255,255,255,255)

surface.CreateFont("xhair", {
	font = "HalfLife2",
	size = ScreenScale(30),
	weight = 100,
	shadow = false
})

function SWEP:DrawHUD()
	local w = ScrW()
	local h = ScrH()
	local cX = (w / 2)-29
	local cY = (h / 2)-38

	-- Portal validity checks using the correct networked entities
	local p1 = self.Owner:GetNWEntity("Portal:Blue")
	local p2 = self.Owner:GetNWEntity("Portal:Orange")
	local p1valid, p2valid = IsValid(p1), IsValid(p2)

	if !allsurfaces:GetBool() then
		local tr = util.TraceLine({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 4096,
			filter = {self.Owner}
		})

		if tr.Hit and tr.HitNormal then
			local normal = tr.HitNormal
			if math.abs(normal.z) > 0.7 or normal:Dot(Vector(0,0,1)) < 0 then
				p1valid, p2valid = false, false
			end
		end
	end

	if GetConVarNumber("portal_crosshair") >= 1 then
		local portalOnly = GetConVarNumber("portal_portalonly")
		local useSystem = system:GetBool()

		-- Determine what to show based on portal_portalonly setting
		local showLeft, showRight = true, true
		if portalOnly >= 2 then
			showLeft, showRight = p1valid, p2valid
		elseif portalOnly >= 1 then
			showLeft = p1valid
		end

		-- Draw left portal indicator (Blue portal)
		local material
		if showLeft and p1valid then
			material = useSystem and "vgui/portalgun/leftFull.png" or "vgui/portalgun/leftFull_1.png"
		else
			material = useSystem and "vgui/portalgun/leftEmpty.png" or "vgui/portalgun/leftEmpty_1.png"
		end
		surface.SetMaterial(Material(material))
		local leftColor = GetPortalColor(TYPE_BLUE, showLeft and p1valid)
		-- Only draw if not completely transparent
		if leftColor.a > 0 then
			surface.SetDrawColor(leftColor.r, leftColor.g, leftColor.b, leftColor.a)
			surface.DrawTexturedRect(cX+leftpos.x, cY+leftpos.y, sizeLarge.w, sizeLarge.h)
		end

		-- Draw right portal indicator (Orange portal)
		if showRight and p2valid then
			material = useSystem and "vgui/portalgun/rightFull.png" or "vgui/portalgun/rightFull_1.png"
		else
			material = useSystem and "vgui/portalgun/rightEmpty.png" or "vgui/portalgun/rightEmpty_1.png"
		end
		surface.SetMaterial(Material(material))
		local rightColor = GetPortalColor(TYPE_ORANGE, showRight and p2valid)
		-- Only draw if not completely transparent
		if rightColor.a > 0 then
			surface.SetDrawColor(rightColor.r, rightColor.g, rightColor.b, rightColor.a)
			surface.DrawTexturedRect(cX+rightpos.x, cY+rightpos.y, sizeLarge.w, sizeLarge.h)
		end

		-- Draw center crosshair
		if !system:GetBool() then
			local lastPort = self:GetNetworkedInt("LastPortal",0)
			surface.SetFont("xhair")
			surface.SetTextColor(255, 255, 255, 200)
			local text = lastPort == TYPE_BLUE and ")" or "("
			local textW, textH = surface.GetTextSize(text)
			surface.SetTextPos(cX - textW/2, cY - textH/2)
			surface.DrawText(text)
		end
	end
end

killicon.Add("prop_portal", "hud/killicon_portals", Color(255, 48, 0, 255))

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	// try to fool them into thinking they're playing a Tony Hawks game
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetTexture(surface.GetTextureID("weapons/swep"))

	y = y + 10
	x = x + 10
	wide = wide - 20

	surface.DrawTexturedRect(x, y, wide, (wide / 2))
end
