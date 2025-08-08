if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Portal" );
	self:NetworkVar( "Entity", 1, "Ent" );

end

function ENT:Initialize(  )
	if CLIENT then
		self:SetRenderClipPlaneEnabled(true)
	end

	self:AddEffects( bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES) )

end

-- function ENT:BuildBonePositions(numbones,numphys)
	-- for i=0, numbones-1 do
		-- self:SetBonePosition(i,self.ent:GetBonePosition(i))
	-- end
-- end

function ENT:Think( )
	self.ent = self:GetEnt()
	self.Portal = self:GetPortal()
	if CLIENT then return end
	local portal = self.Portal
	if not self.ent or not IsValid(self.ent) then self:Remove() return end
	if not self.ent.InPortal then self:Remove() return end
	if not IsValid(self.ent.InPortal) then self:Remove() return end
	if self.ent.InPortal ~= portal then self:Remove() return end
	local other = IsValid(portal) and portal.GetOther and portal:GetOther() or nil
	if not IsValid(other) then return end
	--Adjust Pos
	local origin = portal:GetPortalPosOffsets(other, self.ent)
	local angs = portal:GetPortalAngleOffsets(other, self.ent)
	origin.z = origin.z - 64
	angs.p = 180
	angs.r = 0
	self:SetPos(origin)
	self:SetAngles(angs)
end

function ENT:Draw()
	if not self:IsValid() then return false end
	if not self.Portal or not IsValid(self.Portal) then return false end
	local other = self.Portal.GetOther and self.Portal:GetOther() or nil
	if not IsValid(other) then return false end
	if !RENDERING_PORTAL then
		local portal = self.Portal
		if self:GetBoneCount() ~= self.ent:GetBoneCount() then return false end
		self:SetupBones()
		for i=0,self:GetBoneCount()-1 do
			if self:GetBoneName(i) == "__INVALIDBONE__" then continue end
			local bpos,bang = self.ent:GetBonePosition(i)
			local normal = portal:GetForward()
			local forward = bang:Forward()
			local up = bang:Up()
			local dot = forward:DotProduct(normal)
			forward = forward + (-2 * dot) * normal
			dot = up:DotProduct(normal)
			up = up + (-2 * dot) * normal
			bang = VectorAngles(forward, up)
			local LocalAngles = portal:WorldToLocalAngles(bang)
			LocalAngles.y = -LocalAngles.y
			LocalAngles.r = -LocalAngles.r
			bang = other:LocalToWorldAngles(LocalAngles)
			bpos = portal:WorldToLocal(bpos)
			bpos.x = -bpos.x; bpos.y = -bpos.y
			bpos = other:LocalToWorld(bpos)
			self:SetBonePosition(i,bpos,bang)
		end
		local normal = portal:GetForward()
		local distance = normal:Dot(portal:GetPos())
		self:SetRenderClipPlane(normal,distance)
		self:DrawModel()
	end
end

-- Fonction utilitaire globale pour VectorAngles (toujours disponible)
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

function VectorAngles(forward, up)
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
