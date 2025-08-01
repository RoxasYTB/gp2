-- cl_init.lua (Optimized Portals)
include("shared.lua")

-- ConVars
local dlightenabled     = CreateClientConVar("portal_dynamic_light","0",true)
local bordersenabled    = CreateClientConVar("portal_borders","1",true)
local renderportals_cvar= CreateClientConVar("portal_render",1,true)
local texFSBportals     = CreateClientConVar("portal_texFSB",0,true)

local portal_1_color = CreateClientConVar("portal_color_1", 7, true)
local portal_1_contraste = CreateClientConVar("portal_color_contraste_1", 1, true)
local portal_1_saturation = CreateClientConVar("portal_color_saturation_1", 0, true)

local portal_2_color = CreateClientConVar("portal_color_2", 1, true)
local portal_2_contraste = CreateClientConVar("portal_color_contraste_2", 1, true)
local portal_2_saturation = CreateClientConVar("portal_color_saturation_2", 0, true)

local texFSB = render.GetSuperFPTex()
local texFSB2 = render.GetSuperFPTex2()

-- Color definitions (index 0-14 to match gp2_portal_colors.lua)
local colors = {"red","orange","yellow","green1","green","green2","blue_light","blue","blue_dark","purple","pink","pink2","gray1","gray","gray2"}
local variants = {"","_light","_dark","_saturation","_saturation_light","_saturation_dark","_saturation_low","_saturation_low_light","_saturation_low_dark"}

-- Generate materials and textures
local function buildSets(prefix, path)
    for _, color in ipairs(colors) do
        for _, var in ipairs(variants) do
            local name = color .. var
            local matPath = path .. "portalstaticoverlay_" .. color

            -- Handle variant paths
            if var == "_light" then
                matPath = path .. "light/portalstaticoverlay_" .. color
            elseif var == "_dark" then
                matPath = path .. "dark/portalstaticoverlay_" .. color
            elseif var == "_saturation" then
                matPath = path .. "saturation/portalstaticoverlay_" .. color
            elseif var == "_saturation_light" then
                matPath = path .. "saturation_light/portalstaticoverlay_" .. color
            elseif var == "_saturation_dark" then
                matPath = path .. "saturation_dark/portalstaticoverlay_" .. color
            elseif var == "_saturation_low" then
                matPath = path .. "saturation_low/portalstaticoverlay_" .. color
            elseif var == "_saturation_low_light" then
                matPath = path .. "saturation_low_light/portalstaticoverlay_" .. color
            elseif var == "_saturation_low_dark" then
                matPath = path .. "saturation_low_dark/portalstaticoverlay_" .. color
            end

            _G[prefix .. name] = Material(matPath, "PortalRefract")
            _G[prefix .. name .. "_tex"] = surface.GetTextureID(matPath)
        end
    end
end

buildSets("color_", "models/portals/color/")       -- Single-color overlays
buildSets("two_color_","models/portals/color_(2)/")   -- Two-color overlays

-- Optimized function to set PortalStatic on all materials
local function setPortalStatic(value)
	for _, color in ipairs(colors) do
		for _, var in ipairs(variants) do
			local name = color .. var
			local colorMat = _G["color_" .. name]
			local twoColorMat = _G["two_color_" .. name]

			if colorMat then
				colorMat:SetFloat("$PortalStatic", value)
			end
			if twoColorMat then
				twoColorMat:SetFloat("$PortalStatic", value)
			end
		end
	end
end

-- Utility to pick overlay key with correct indexing
local function pickOverlay(cidx, cont, sat)
    -- Adjust index since Lua arrays are 1-based but ConVar uses 0-based indexing
    local adjustedIdx = cidx + 1
    local base = colors[adjustedIdx] or "red"
    local light = ""
    local satv = ""

    -- Handle contrast (brightness)
    if cont >= 2 then
        light = "_light"
    elseif cont < 1 then
        light = "_dark"
    end

    -- Handle saturation
    if sat >= 2 then
        satv = "_saturation_low"
    elseif sat >= 1 then
        satv = "_saturation"
    end

    return base .. satv .. light
end

-- Make our own material to use, so we aren't messing with other effects.
local PortalMaterial = CreateMaterial(
                "PortalMaterial",
                "UnlitGeneric",
                {
                        [ '$basetexture' ] = texFSB,
                        [ '$model' ] = "1",
                        [ '$alphatest' ] = "0",
						[ '$PortalMaskTexture' ] = "models/portals/portal-mask-dx8",
                        [ '$additive' ] = "0",
                        [ '$translucent' ] = "0",
                        [ '$ignorez' ] = "0"
                }
        )

if CLIENT then
	game.AddParticles("particles/portal_projectile.pcf")
	game.AddParticles("particles/portals.pcf")
	game.AddParticles("particles/portals_reverse.pcf")
	game.AddParticles("particles/portal_projectile_atlas.pcf")
	game.AddParticles("particles/portals_atlas.pcf")
	game.AddParticles("particles/portals_atlas_reverse.pcf")
	game.AddParticles("particles/portal_projectile_pbody.pcf")
	game.AddParticles("particles/portals_pbody.pcf")
	game.AddParticles("particles/portals_pbody_reverse.pcf")
	game.AddParticles("particles/portal_projectile_pink_green.pcf")
	game.AddParticles("particles/portals_pink_green.pcf")
	game.AddParticles("particles/portals_pink_green_reverse.pcf")
end

// rendergroup
ENT.RenderGroup = RENDERGROUP_BOTH

/*------------------------------------
        Initialize()
------------------------------------*/
function ENT:Initialize()
	self:SetRenderBounds(self:OBBMins()*20, self:OBBMaxs()*20)
	self.openpercent = 0
	self.openpercent_bordermat = 0.8
	self.openpercent_material = 0
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	if self:OnFloor() then
		self:SetRenderOrigin(self:GetPos() - Vector(0,0,20))
	else
		self:SetRenderOrigin(self:GetPos())
	end
end

-- Reset on movement
usermessage.Hook("Portal:Moved", function(umsg)
	local ent = umsg:ReadEntity()
	local pos = umsg:ReadVector()
	local ang = umsg:ReadAngle()

	if ent and ent:IsValid() then
		if ent.openpercent_bordermat then
			ent.openpercent_bordermat = 0.8
		end
		if ent.openpercent then
			ent.openpercent = 0
		end
		if ent.openpercent_material then
			ent.openpercent_material = 0
		end

		ent:SetAngles(ang)
		if ent:OnFloor() then
			ent:SetRenderOrigin(pos - Vector(0,0,20))
		else
			ent:SetRenderOrigin(pos)
		end
	end
end)

--I think this is from sassilization..
local function IsInFront(posA, posB, normal)
	local Vec1 = (posB - posA):GetNormalized()
	return (normal:Dot(Vec1) < 0)
end

-- Think: animate and dynamic light
function ENT:Think()
	if not self:GetNWBool("Potal:Activated", false) then return end

	local ft = FrameTime()
	self.openpercent = math.Approach(self.openpercent,1,ft*3.4*(0.75+self.openpercent-0.49))
	self.openpercent_bordermat = math.Approach(self.openpercent_bordermat,0,ft*1.5)
	self.openpercent_material = math.Approach(self.openpercent_material,1,ft*0.75)

	if not dlightenabled:GetBool() then return end

	local portaltype = self:GetNWInt("Potal:PortalType", TYPE_BLUE)
	local cvar = portaltype==TYPE_BLUE and "portal_color_1" or "portal_color_2"
	local cont = GetConVarNumber((portaltype==TYPE_BLUE and "portal_color_contraste_1") or "portal_color_contraste_2")
	local sat  = GetConVarNumber((portaltype==TYPE_BLUE and "portal_color_saturation_1") or "portal_color_saturation_2")
	local idx  = GetConVarNumber(cvar)
	local key  = pickOverlay(idx,cont,sat)
	local mat  = _G[(portaltype==TYPE_BLUE and "color_" or "two_color_")..key]

	if not mat then return end

	local col = mat:GetVector("$tint") or Vector(1,1,1)
	local brightness = cont>=2 and 7 or cont>=1 and 5 or 3

	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = self:GetRenderOrigin() + self:GetAngles():Forward()
		dlight.r, dlight.g, dlight.b = col.x*255, col.y*255, col.z*255
		dlight.Brightness = brightness
		dlight.Decay = 9999
		dlight.Size = 50
		dlight.DieTime = CurTime()+0.9
		dlight.Style = 5
	end
end

-- Draw model transparent
function ENT:Draw()
	self:SetModelScale(self.openpercent,0)
	self:DrawModel()
	self:SetColor(Color(255,255,255,0))
end

-- Draw overlay frame
local function drawOverlay(self, portaltype)
	if not bordersenabled:GetBool() then return end
	if self:GetNWBool("Potal:Activated",false) then
		local cvar = portaltype==TYPE_BLUE and "portal_color_1" or "portal_color_2"
		local cont = GetConVarNumber((portaltype==TYPE_BLUE and "portal_color_contraste_1") or "portal_color_contraste_2")
		local sat  = GetConVarNumber((portaltype==TYPE_BLUE and "portal_color_saturation_1") or "portal_color_saturation_2")
		local idx  = GetConVarNumber(cvar)
		local key  = pickOverlay(idx,cont,sat)
		local mat  = _G[(portaltype==TYPE_BLUE and "color_" or "two_color_") .. key]

		if mat then
			render.SetMaterial(mat)
			render.DrawScreenQuad()
		end
	end
end

-- Draw portal effects + overlay (optimized)
function ENT:DrawPortalEffects(portaltype)
	-- Set $PortalOpenAmount for all materials first
	local openAmount = 1 - math.min(self.openpercent_bordermat)

	for _, color in ipairs(colors) do
		for _, var in ipairs(variants) do
			local name = color .. var
			local colorMat = _G["color_" .. name]
			local twoColorMat = _G["two_color_" .. name]

			if colorMat then
				colorMat:SetFloat("$PortalOpenAmount", openAmount)
			end
			if twoColorMat then
				twoColorMat:SetFloat("$PortalOpenAmount", openAmount)
			end
		end
	end

	-- Check if portal should show static texture (unlinked or rendering portal)
	if (RENDERING_PORTAL or not self:GetNWBool("Potal:Linked", false) or not self:GetNWBool("Potal:Activated", false)) then
		-- Use optimized function to set $PortalStatic for all materials to show static texture
		setPortalStatic(1)
	else
		local other = self:GetNWEntity("Potal:Other")
		if other and other:IsValid() and other.openpercent_material then
			-- Use optimized function to set $PortalStatic for all materials
			setPortalStatic(1-math.min(other.openpercent_material))
		end
	end

	-- Draw the colored overlay in its own 3D2D context
	if bordersenabled:GetBool() and self:GetNWBool("Potal:Activated", false) then
		local ang = self:GetAngles()
		local res = 0.1
		local percentopen = 1
		local width = percentopen * 65
		local height = percentopen * 112

		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), 90)

		local origin = self:GetRenderOrigin() + (self:GetForward() * 0.1) - (self:GetUp() * height / -2) - (self:GetRight() * width / -2)

		cam.Start3D2D(origin, ang, res)

		surface.SetDrawColor(255, 255, 255, 255)

		-- Get the correct material for this portal
		local cvar = portaltype==TYPE_BLUE and "portal_color_1" or "portal_color_2"
		local cont = GetConVarNumber((portaltype==TYPE_BLUE and "portal_color_contraste_1") or "portal_color_contraste_2")
		local sat = GetConVarNumber((portaltype==TYPE_BLUE and "portal_color_saturation_1") or "portal_color_saturation_2")
		local idx = GetConVarNumber(cvar)
		local key = pickOverlay(idx, cont, sat)
		local tex = _G[(portaltype==TYPE_BLUE and "color_" or "two_color_") .. key .. "_tex"]

		if tex then
			surface.SetTexture(tex)
			surface.DrawTexturedRect(0, 0, width / res, height / res)
		end

		cam.End3D2D()
	end
end-- Complete DrawPortal function
function ENT:DrawPortal()
	if not renderportals_cvar:GetBool() then return end

	local viewent = GetViewEntity()
	local pos = (IsValid(viewent) and viewent != LocalPlayer()) and GetViewEntity():GetPos() or EyePos()

	if IsInFront(pos, self:GetRenderOrigin(), self:GetForward()) and self:GetNWBool("Potal:Activated",false) then
		render.ClearStencil()
		render.SetStencilEnable(true)

		cam.Start3D2D(self:GetRenderOrigin(), self:GetAngles(), 1)

		render.SetStencilWriteMask(3)
		render.SetStencilTestMask(3)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilReferenceValue(1)

		local percentopen = self.openpercent
		self:SetModelScale(percentopen, 0)
		self:DrawModel()

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

		-- Draw portal
		local portaltype = self:GetNWInt("Potal:PortalType", TYPE_BLUE)
		if renderportals_cvar:GetBool() then
			local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2
			local no_RT = Material("effects/tvscreen_noise002a")

			if GetConVarNumber("portal_texFSB") >= 2 then
				PortalMaterial:SetTexture("$basetexture", ToRT)
				render.SetMaterial(no_RT)
				render.DrawScreenQuad()
			elseif GetConVarNumber("portal_texFSB") >= 1 then
				PortalMaterial:SetTexture("$basetexture", ToRT)
				render.SetMaterial(no_RT)
				render.DrawScreenQuad()
			else
				PortalMaterial:SetTexture("$basetexture", ToRT)
				render.SetMaterial(PortalMaterial)
				render.DrawScreenQuad()
			end
		end

		-- Draw borders if enabled
		-- Note: Border overlay is now handled in DrawPortalEffects

		cam.End3D2D()
		render.SetStencilEnable(false)

		self:DrawPortalEffects(portaltype)
	end
end

-- Main portal rendering hook
hook.Add("PostDrawOpaqueRenderables","DrawPortals", function()
	for _,v in ipairs(ents.FindByClass("prop_portal")) do
		if IsValid(v) then
			v:DrawPortal()
		end
	end
end)

-- Portal rendering function
function ENT:RenderPortal(origin, angles)
	if renderportals_cvar:GetBool() then
		local portal = self:GetNWEntity("Potal:Other", nil)
		if IsValid(portal) and self:GetNWBool("Potal:Linked", false) and self:GetNWBool("Potal:Activated", false) then
			local portaltype = self:GetNWInt("Potal:PortalType", TYPE_BLUE)
			local normal = self:GetForward()
			local distance = normal:Dot(self:GetRenderOrigin())

			othernormal = portal:GetForward()
			otherdistance = othernormal:Dot(portal:GetRenderOrigin())

			-- Reflect origin and angles
			local forward = angles:Forward()
			local up = angles:Up()

			local dot = origin:DotProduct(normal) - distance
			origin = origin + (-2 * dot) * normal

			dot = forward:DotProduct(normal)
			forward = forward + (-2 * dot) * normal

			dot = up:DotProduct(normal)
			up = up + (-2 * dot) * normal

			angles = math.VectorAngles(forward, up)

			local LocalOrigin = self:WorldToLocal(origin)
			local LocalAngles = self:WorldToLocalAngles(angles)

			if self:OnFloor() and not portal:OnFloor() then
				LocalOrigin.x = LocalOrigin.x + 20
			end

			if portal:OnFloor() and self:IsHorizontal() then
				LocalOrigin.x = LocalOrigin.x - 20
			end

			LocalOrigin.y = -LocalOrigin.y
			LocalAngles.y = -LocalAngles.y
			LocalAngles.r = -LocalAngles.r

			view = {}
			view.x = 0
			view.y = 0
			view.w = ScrW()
			view.h = ScrH()
			view.origin = portal:LocalToWorld(LocalOrigin)
			view.angles = portal:LocalToWorldAngles(LocalAngles)
			view.drawhud = false
			view.drawviewmodel = false

			local oldrt = render.GetRenderTarget()
			local ToRT = portaltype == TYPE_BLUE and texFSB or texFSB2

			render.SetRenderTarget(ToRT)
			render.PushCustomClipPlane(othernormal, otherdistance)
			local b = render.EnableClipping(true)

			render.Clear(0, 0, 0, 255)
			render.ClearDepth()
			render.ClearStencil()

			portal:SetNoDraw(true)
			RENDERING_PORTAL = self
			render.RenderView(view)
			render.UpdateScreenEffectTexture()
			RENDERING_PORTAL = false
			portal:SetNoDraw(false)

			render.PopCustomClipPlane()
			render.EnableClipping(b)
			render.SetRenderTarget(oldrt)
		end
	end
end

-- ShouldDrawLocalPlayer hook
hook.Add("ShouldDrawLocalPlayer", "Portal.ShouldDrawLocalPlayer", function()
	local ply = LocalPlayer()
	local portal = ply.InPortal
	if RENDERING_PORTAL then
		return true
	end
end)

-- PostDrawEffects hook
hook.Add('PostDrawEffects', 'PortalSimulation_PlayerRenderFix', function()
	cam.Start3D(EyePos(), EyeAngles())
	cam.End3D()
end)

-- RenderScene hook
hook.Add("RenderScene", "Portal.RenderScene", function(Origin, Angles)
	if GetConVarNumber("portal_texFSB") >= 2 then
		for k, v in ipairs(ents.FindByClass("prop_portal_pbody")) do
			local viewent = GetViewEntity()
			local pos = (IsValid(viewent) and viewent != LocalPlayer()) and GetViewEntity():GetPos() or Origin
			if IsInFront(Origin, v:GetRenderOrigin(), v:GetForward()) then
				v:RenderPortal(Origin, Angles)
			end
		end
	elseif GetConVarNumber("portal_texFSB") >= 1 then
		for k, v in ipairs(ents.FindByClass("prop_portal_atlas")) do
			local viewent = GetViewEntity()
			local pos = (IsValid(viewent) and viewent != LocalPlayer()) and GetViewEntity():GetPos() or Origin
			if IsInFront(Origin, v:GetRenderOrigin(), v:GetForward()) then
				v:RenderPortal(Origin, Angles)
			end
		end
	else
		for k, v in ipairs(ents.FindByClass("prop_portal")) do
			local viewent = GetViewEntity()
			local pos = (IsValid(viewent) and viewent != LocalPlayer()) and GetViewEntity():GetPos() or Origin
			if IsInFront(Origin, v:GetRenderOrigin(), v:GetForward()) then
				v:RenderPortal(Origin, Angles)
			end
		end
	end
end)

-- Debug monitor
CreateClientConVar("portal_debugmonitor", 0, false, false)
hook.Add("HUDPaint", "Portal.BlueMonitor", function(w, h)
	if GetConVarNumber("portal_debugmonitor") == 1 and GetConVarNumber("sv_cheats") == 1 then
		for k, v in ipairs(ents.FindByClass("prop_portal")) do
			if view and v:GetNWInt("Potal:PortalType", TYPE_BLUE) == TYPE_BLUE then
				surface.DrawLine(ScrW()/2-10, ScrH()/2, ScrW()/2+10, ScrH()/2)
				surface.DrawLine(ScrW()/2, ScrH()/2-10, ScrW()/2, ScrH()/2+10)

				local b = render.EnableClipping(true)
				render.PushCustomClipPlane(othernormal, otherdistance)
				view.w = 500
				view.h = 280
				RENDERING_PORTAL = true
				render.RenderView(view)
				RENDERING_PORTAL = false
				render.PopCustomClipPlane()
				render.EnableClipping(b)
			end
		end
	end
end)

-- Motion blur and post-processing hooks
hook.Add("GetMotionBlurValues", "Portal.GetMotionBlurValues", function(x, y, fwd, spin)
	if RENDERING_PORTAL then
		return 0, 0, 0, 0
	end
end)

hook.Add("PostProcessPermitted", "Portal.PostProcessPermitted", function(element)
	if element == "bloom" and RENDERING_PORTAL then
		return false
	end
end)

-- Portal object tracking
usermessage.Hook("Portal:ObjectInPortal", function(umsg)
	local portal = umsg:ReadEntity()
	local ent = umsg:ReadEntity()
	if IsValid(ent) and IsValid(portal) then
		ent.InPortal = portal
		ent:SetRenderClipPlaneEnabled(true)
		ent:SetGroundEntity(portal)
	end
end)

usermessage.Hook("Portal:ObjectLeftPortal", function(umsg)
	local ent = umsg:ReadEntity()
	if IsValid(ent) then
		ent.InPortal = false
		ent:SetRenderClipPlaneEnabled(false)
	end
end)

-- Render clipping
hook.Add("RenderScreenspaceEffects", "Portal.RenderScreenspaceEffects", function()
	for k, v in pairs(ents.GetAll()) do
		if IsValid(v.InPortal) then
			local normal = v.InPortal:GetForward()
			local distance = normal:Dot(v.InPortal:GetRenderOrigin())

			v:SetRenderClipPlaneEnabled(true)
			v:SetRenderClipPlane(normal, distance)
		end
	end
end)

-- VectorAngles function
function math.VectorAngles(forward, up)
	local angles = Angle(0, 0, 0)
	local left = up:Cross(forward)
	left:Normalize()
	local xydist = math.sqrt(forward.x * forward.x + forward.y * forward.y)

	if xydist > 0.001 then
		angles.y = math.deg(math.atan2(forward.y, forward.x))
		angles.p = math.deg(math.atan2(-forward.z, xydist))
		angles.r = math.deg(math.atan2(left.z, (left.y * forward.x) - (left.x * forward.y)))
	else
		angles.y = math.deg(math.atan2(-left.x, left.y))
		angles.p = math.deg(math.atan2(-forward.z, xydist))
		angles.r = 0
	end

	return angles
end

-- Debug overlays
usermessage.Hook("DebugOverlay_LineTrace", function(umsg)
	local p1, p2, b = umsg:ReadVector(), umsg:ReadVector(), umsg:ReadBool()
	local col = b and Color(255, 0, 0, 255) or Color(0, 0, 255, 255)
	debugoverlay.Line(p1, p2, 5, col)
end)

usermessage.Hook("DebugOverlay_Cross", function(umsg)
	local point = umsg:ReadVector()
	local b = umsg:ReadBool()
	local col = b and Color(0, 255, 0) or Color(255, 0, 0)
	debugoverlay.Cross(point, 5, 5, col, true)
end)

hook.Add("Think", "Reset Camera Roll", function()
	if not LocalPlayer():InVehicle() then
		local a = LocalPlayer():EyeAngles()
		if a.r != 0 then
			a.r = math.ApproachAngle(a.r, 0, FrameTime()*160)
			LocalPlayer():SetEyeAngles(a)
		end
	end
end)
