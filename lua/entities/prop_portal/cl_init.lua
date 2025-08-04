-- ----------------------------------------------------------------------------
-- GP2 Framework - Portal Entity (Client)
-- Architecture modulaire combinant nouveau système de rendu et ancien système de téléportation
-- ----------------------------------------------------------------------------

include("shared.lua")

-- Initialize global tables on CLIENT to prevent nil value errors in multiplayer
if CLIENT then
	-- Ensure PortalRendering is loaded before trying to use it
	if not PortalRendering then
		-- Try to include portalrendering.lua if it hasn't been loaded
		local success, err = pcall(include, "gp2/client/portalrendering.lua")
		if not success then
			GP2.Print("Failed to load portalrendering.lua: %s", err or "unknown error")
		end
	end

	PropPortal = PropPortal or {}
	PropPortal.Portals = PropPortal.Portals or {}

	-- Initialize PropPortal functions if not already present
	if not PropPortal.AddToRenderList then
		PropPortal.AddToRenderList = function(portal)
			PropPortal.Portals[portal] = true
		end
	end

	PortalRendering = PortalRendering or {}
	PortalRendering.PortalMeshes = PortalRendering.PortalMeshes or {}
	PortalRendering.PortalMaterials = PortalRendering.PortalMaterials or {}
	PortalRendering.Rendering = PortalRendering.Rendering or false

	-- Initialize PortalRendering functions if not already present
	if not PortalRendering.ValidateAndSetRingRT then
		PortalRendering.ValidateAndSetRingRT = function(portal)
			-- Return a fallback material if the full system isn't loaded
			return Material("models/portals/portal_stencil_hole")
		end
	end

	if not PortalRendering.GetDrawDistance then
		PortalRendering.GetDrawDistance = function()
			return 250 -- Default draw distance
		end
	end

	if not PortalRendering.GetShowGhosting then
		PortalRendering.GetShowGhosting = function()
			return true -- Default ghosting enabled
		end
	end
end

local stencilHole = Material("models/portals/portal_stencil_hole")
local ghostTexture = CreateMaterial("portal-ghosting", "UnlitGeneric", {
	["$basetexture"] = "models/portals/dummy-gray",
	["$nocull"] = 1,
	["$model"] = 1,
	["$alpha"] = 1,
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
})

net.Receive(GP2.Net.SendPortalClose, function()
	local pos = net.ReadVector()
	local angle = net.ReadAngle()
	local color = net.ReadVector()

	local forward, right, up = angle:Forward(), angle:Right(), angle:Up()

	local particle = CreateParticleSystemNoEntity("portal_close", pos, angle)
	if IsValid(particle) then
		particle:SetControlPoint(2, color)
	end
end)

local function getRenderMesh()
	-- Ensure PortalRendering is initialized
	if not PortalRendering or not PortalRendering.PortalMeshes then
		return Mesh(), Mesh()
	end

	if not PortalRendering.PortalMeshes[4] then
		PortalRendering.PortalMeshes[4] = { Mesh(), Mesh() }

		local invMeshTable = {}
		local meshTable = {}

		local corners = {
			Vector(-1, -1, -1),
			Vector(1, -1, -1),
			Vector(1, 1, -1),
			Vector(-1, 1, -1)
		}

		local uv = {
			Vector(0, 1),
			Vector(1, 1),
			Vector(1, 0),
			Vector(0, 0)
		}

		for i = 1, 4 do
			table.insert(meshTable, { pos = corners[i % 4 + 1], u = uv[i % 4 + 1].y, v = 1 - uv[i % 4 + 1].x })
			table.insert(meshTable, { pos = Vector(0, 0, -1), u = 0.5, v = 0.5 })
			table.insert(meshTable, { pos = corners[i], u = uv[i].y, v = 1 - uv[i].x })
		end

		for i = 1, 4 do
			table.insert(invMeshTable, { pos = corners[i], u = uv[i].y, v = 1 - uv[i].x })
			table.insert(invMeshTable, { pos = Vector(0, 0, -1), u = 0.5, v = 0.5 })
			table.insert(invMeshTable, { pos = corners[i % 4 + 1], u = uv[i % 4 + 1].y, v = 1 - uv[i % 4 + 1].x })
		end

		PortalRendering.PortalMeshes[4][1]:BuildFromTriangles(meshTable)
		PortalRendering.PortalMeshes[4][2]:BuildFromTriangles(invMeshTable)
	end

	return PortalRendering.PortalMeshes[4][2], PortalRendering.PortalMeshes[4][1]
end

function ENT:Draw()
	if not self:GetActivated() then return end

	if not self.RENDER_MATRIX then
		self.RENDER_MATRIX = Matrix()
	end

	debugoverlay.Text(self:GetPos(), self:GetLinkageGroup(), 0.1)

	if halo.RenderedEntity() == self then return end
	local render = render
	local cam = cam
	local size = self:GetSize()
	local renderMesh = getRenderMesh()

	if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
		if self.RENDER_MATRIX:GetTranslation() ~= self:GetPos() or (self.RENDER_MATRIX:GetScale().x ~= size.x and self.RENDER_MATRIX:GetScale().y ~= size.y) then
			self.RENDER_MATRIX:Identity()
			self.RENDER_MATRIX:SetTranslation(self:GetPos() + self:GetAngles():Up() * 8)
			self.RENDER_MATRIX:SetAngles(self:GetAngles())
			self.RENDER_MATRIX:SetScale(size * 0.999)
			size.z = -0.5
			self:SetRenderBounds(-size, size)
			size[3] = 0
		end
	else
		if self.RENDER_MATRIX:GetTranslation() ~= self:GetPos() or self.RENDER_MATRIX:GetScale() != size then
			self.RENDER_MATRIX:Identity()
			self.RENDER_MATRIX:SetTranslation(self:GetPos())
			self.RENDER_MATRIX:SetAngles(self:GetAngles())
			self.RENDER_MATRIX:SetScale(size * 0.999)
			self:SetRenderBounds(-size, size)
			size[3] = 0
		end
	end

	-- Try to build gradient texture for current color
	-- to override color - without shaders :(
	local portalOverlay = PortalRendering and PortalRendering.ValidateAndSetRingRT and PortalRendering.ValidateAndSetRingRT(self)

	if not portalOverlay or not portalOverlay.SetFloat then
		-- PortalRendering not fully loaded yet, skip rendering this frame
		return
	end

	-- No PortalOpenAmount proxy
	-- because it uses mesh rather entity's model
	stencilHole:SetFloat("$portalopenamount", self:GetOpenAmount())
	portalOverlay:SetFloat("$portalopenamount", self:GetOpenAmount())
	portalOverlay:SetFloat("$time", CurTime())

	if PortalRendering and not PortalRendering.Rendering and IsValid(self:GetLinkedPartner()) then
		portalOverlay:SetFloat("$portalstatic", self:GetStaticAmount())
	else
		portalOverlay:SetFloat("$portalstatic", 1)
	end

	--
	-- Render portal view:
	--	- only when it's not inside portal view
	--	- there's linked partner
	--	- should render (in FOV, distance is less than threshold)
	--
	if PortalRendering and not (PortalRendering.Rendering or not IsValid(self:GetLinkedPartner()) or not PortalManager.ShouldRender(self, EyePos(), EyeAngles(), PortalRendering.GetDrawDistance())) then
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(1)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)

		if stencilHole and not stencilHole:IsError() then
			render.SetMaterial(stencilHole)
			-- draw inside of portal
			cam.PushModelMatrix(self.RENDER_MATRIX)
				renderMesh:Draw()
			cam.PopModelMatrix()
		end

		-- draw the actual portal texture
		local portalmat = PortalRendering.PortalMaterials
		if portalmat and portalmat[self.PORTAL_RT_NUMBER or 1] then
			local material = portalmat[self.PORTAL_RT_NUMBER or 1]
			if material and not material:IsError() then
				render.SetMaterial(material)
				render.SetStencilCompareFunction(STENCIL_EQUAL)
				render.DrawScreenQuadEx(0, 0, ScrW(), ScrH())
				render.SetStencilEnable(false)
			end
		end
	end

	--
	-- Render border material
	-- previously I set open/static values for it
	-- Each material is local to entity
	--
	if portalOverlay and not portalOverlay:IsError() then
		render.SetMaterial(portalOverlay)
		cam.PushModelMatrix(self.RENDER_MATRIX)
			renderMesh:Draw()
		cam.PopModelMatrix()
	end

	--
	-- Render the ring particle only not in portal view
	-- after everything
	--
	if PortalRendering and not PortalRendering.Rendering and IsValid(self.RingParticle) then
		self.RingParticle:Render()
	end
end

function ENT:DrawGhost()
	local renderMesh, renderMesh2 = getRenderMesh()
	local portalType = self:GetType()

	--
	-- Render portal ghosting
	-- Uses stencils too
	-- rendered from render.lua in PostDrawOpaqueRenderables
	--
	if PortalRendering and not PortalRendering.Rendering and PortalRendering.GetShowGhosting and PortalRendering.GetShowGhosting() then
		render.SetStencilWriteMask( 255 )
		render.SetStencilTestMask( 255 )
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.ClearStencil()

		render.SetStencilEnable( true )

		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilZFailOperation( STENCIL_REPLACE )

		render.SetColorMaterial()
		render.OverrideColorWriteEnable(true, false)
		cam.PushModelMatrix(self.RENDER_MATRIX)
			renderMesh:Draw()
			renderMesh2:Draw()
		cam.PopModelMatrix()
		render.OverrideColorWriteEnable(false, false)

		render.SetStencilCompareFunction(STENCIL_EQUAL)
		ghostTexture:SetVector("$color", self:GetColorVector01Internal())

		if ghostTexture and not ghostTexture:IsError() then
			render.SetMaterial(ghostTexture)
			cam.IgnoreZ(true)
			cam.PushModelMatrix(self.RENDER_MATRIX)
				renderMesh:Draw()
				renderMesh2:Draw()
			cam.PopModelMatrix()
			cam.IgnoreZ(false)
		end
		render.SetBlend(1)
		render.SetStencilEnable(false)
	end
end

function ENT:Think()
	if not self:GetActivated() then return end

	-- Ensure PropPortal is initialized
	if PropPortal and PropPortal.AddToRenderList then
		PropPortal.AddToRenderList(self)
	end

	if not IsValid(self.RingParticle) then
		-- Create ring particle
		local ringEffect = self:GetType() == PORTAL_TYPE_SECOND and "portal_2_edge" or "portal_1_edge"
		-- Création du ring avec les angles fixes
		local ringAngles = Angle(RING_PITCH, RING_YAW, RING_ROLL)
		self.RingParticle = CreateParticleSystem(self, ringEffect, PATTACH_CUSTOMORIGIN)
		if IsValid(self.RingParticle) then
			self.RingParticle:SetControlPoint(0, self:GetPos())
			self.RingParticle:SetControlPointOrientation(0, ringAngles:Forward(), ringAngles:Right(), ringAngles:Up())
		end
	end

	if IsValid(self.RingParticle) then
		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self.RingParticle:SetControlPoint(0, self:GetPos())
		else
			self.RingParticle:SetControlPoint(0, self:GetPos() - self:GetAngles():Up() * 7)
		end

		-- Si RingParticle existe et est en customorigin, on met à jour sa position et son orientation à chaque frame
		local ringAngles = Angle(RING_PITCH, RING_YAW, RING_ROLL)
		self.RingParticle:SetControlPoint(0, self:GetPos())
		self.RingParticle:SetControlPointOrientation(0, ringAngles:Forward(), ringAngles:Right(), ringAngles:Up())

		-- Application correcte de la rotation personnalisée du ring
		local pitch = 180
		local yaw = 180
		local roll = 180
		local baseAngles = self:GetAngles()
		local ringAngles = Angle(pitch, yaw, roll)
		local mat = Matrix()
		mat:SetAngles(baseAngles)
		mat:Rotate(ringAngles)
		local fwd = mat:GetForward()
		local right = mat:GetRight()
		local up = mat:GetUp()
		self.RingParticle:SetControlPointOrientation(0, right, fwd, up)

		if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
			self.RingParticle:SetControlPoint(7, self:GetColorVector())
		else
			self.RingParticle:SetControlPoint(7, self:GetColorVector() * 0.4)
		end
	end

	-- Gestion dynamique de la recréation du ring si les angles changent
	self._lastRingPitch = self._lastRingPitch or 0
	self._lastRingYaw = self._lastRingYaw or 0
	self._lastRingRoll = self._lastRingRoll or 0
	local pitch = 180
	local yaw = 180
	local roll = 180
	if pitch ~= self._lastRingPitch or yaw ~= self._lastRingYaw or roll ~= self._lastRingRoll then
		if IsValid(self.RingParticle) then
			self.RingParticle:StopEmissionAndDestroyImmediately()
			self.RingParticle = nil
		end
		self._lastRingPitch = pitch
		self._lastRingYaw = yaw
		self._lastRingRoll = roll
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:SetMaterial("glass")
		phys:SetPos(self:GetPos())
		phys:SetAngles(self:GetAngles())
	end

	self:NextThink(CurTime())
	return true
end

local function incrementPortal(ent)
	if CLIENT then
		local size = ent:GetSize()
		ent:SetRenderBounds(-size, size)
	end
	PortalManager.PortalIndex = PortalManager.PortalIndex + 1
end

hook.Add("NetworkEntityCreated", "seamless_portal_init", function(ent)
	if IsValid(ent) and ent:GetClass() == "prop_portal" then
		ent.RENDER_MATRIX = Matrix()
		timer.Simple(0, function()
			if IsValid(ent) then
				incrementPortal(ent)
				ent:Think()
			end
		end)
	end
end)

-- hacky bullet fix
if game.SinglePlayer() then
	function ENT:TestCollision(startpos, delta, isbox, extents, mask)
		if bit.band(mask, CONTENTS_GRATE) ~= 0 then return true end
	end
end
