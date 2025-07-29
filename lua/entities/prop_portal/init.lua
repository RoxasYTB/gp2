AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "cl_init.lua" );
include( "shared.lua" );

ENT.Linked = nil
ENT.PortalType = TYPE_BLUE
ENT.Activated = false
ENT.KeyValues = {}

local upsidedown = CreateClientConVar("portal_upside_down","1",true,false)
local snd_portal2 = CreateClientConVar("portal_sound","0",true,false)
local sides_fix = CreateClientConVar("portal_sides_fix","0",true,false)
local portal_prototype = CreateClientConVar("portal_prototype","1",true,false)
local vel_roof_max = CreateConVar("portal_velocity_roof", 1000, {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE})

sound.Add({
	name = "portal_loop",
	channel = CHAN_STATIC,
	volume = .8,
	level = 64,
	pitch = {100},
	sound = "weapons/portalgun/portal_ambient_loop1.wav"
})

sound.Add({
	name = "portal_loop2",
	channel = CHAN_STATIC,
	volume = .8,
	level = 64,
	pitch = {100},
	sound = "weapons/portalgun/portal2/portal_ambient_loop1.wav"
})

local hitprop = CreateClientConVar("portal_hitprop","0",true,false)

function ENT:SpawnFunction( ply, tr ) --unused.
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( "prop_portal" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

--I think this is from sassilization..
local function IsBehind( posA, posB, normal )

	local Vec1 = ( posB - posA ):GetNormalized()

	return ( normal:Dot( Vec1 ) < 0 )

end

function ENT:Initialize( )
if !portal_prototype:GetBool() then
		self:SetModel( "models/blackops/portal_fix.mdl" )
		else
		self:SetModel( "models/blackops/portal_prototype_fix.mdl" )
end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetMoveType( MOVETYPE_NONE )
	self:PhysWake()
	self:DrawShadow(false)
	self:SetTrigger(true)
	self:SetNWBool("Potal:Activated",false)
	self:SetNWBool("Potal:Linked",false)
	self:SetNWInt("Potal:PortalType",self.PortalType)

	self.Sides = ents.Create( "prop_physics" )
if !sides_fix:GetBool() then
	self.Sides:SetModel( "models/blackops/portal_sides.mdl" )
		else
	self.Sides:SetModel( "models/blackops/portal_sides_new.mdl" )
end
	self.Sides:SetPos( self:GetPos() + self:GetForward()*-0.1 )
	self.Sides:SetAngles( self:GetAngles() )
	self.Sides:Spawn()
	self.Sides:Activate()
	self.Sides:SetRenderMode( RENDERMODE_NONE )
	self.Sides:PhysicsInit(SOLID_VPHYSICS)
	self.Sides:SetSolid(SOLID_VPHYSICS)
	self.Sides:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	--self.Sides:SetMoveType( MOVETYPE_NONE ) --causes some weird shit to happen..
	self.Sides:DrawShadow(false)

	local phys = self.Sides:GetPhysicsObject()

	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	self:DeleteOnRemove(self.Sides)

	if self:OnFloor() then
		self:SetPos( self:GetPos() + Vector(0,0,20) )
	end

	if self:OnRoof() and (not self:IsHorizontal()) then

if upsidedown:GetBool() then

self:SetAngles( self:GetAngles() + Angle(0,0,180) )

		else

self:SetAngles( self:GetAngles() + Angle(0,0,0) )

end

	end

self.portal_loop = CreateSound(self,"portal_loop")
self.portal_loop2 = CreateSound(self,"portal_loop2")

if !snd_portal2:GetBool() then
	self.portal_loop:Play()
		else
	self.portal_loop2:Play()
end

	for k,v in pairs(ents.FindInSphere(self:GetPos(),100))do
		if v == self then continue end
		if v == self.Sides then continue end
		if v:GetClass() != "prop_physics" and v:GetClass() != "npc_grenade_frag" then continue end
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			-- print(v)
			phys:Wake()
			phys:ApplyForceCenter(Vector(0,0,10))
		end
	end

    -- Génération des caisses sous le portail
    self.SpawnedCubes = {}
    local groundZ = self:GetGroundZ()
    local portalPos = self:GetPos()
    local basePos = Vector(portalPos.x, portalPos.y, groundZ - 22) -- 30 unités en dessous du sol
    local offsets = {
        Vector(0,0,0), -- centre
        Vector(40,0,0), Vector(-40,0,0), Vector(0,40,0), Vector(0,-40,0),
        Vector(40,40,0), Vector(-40,40,0), Vector(40,-40,0), Vector(-40,-40,0)
    }
    for _, offset in ipairs(offsets) do
        local cube = ents.Create("prop_physics")
        if IsValid(cube) then
            cube:SetModel("models/props_junk/wood_crate001a.mdl")
            cube:SetPos(basePos + offset)
            cube:Spawn()
            cube:SetOwner(self)
            cube.InPortalCube = true
            cube.GP2_IsPortalCrate = true

            -- Rendre la caisse complètement transparente
            cube:SetColor(Color(255, 255, 255, 0))
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


function ENT:BootPlayer()
	--Kick players out of this portal.
	for k,p in pairs(player.GetAll()) do
		if p.InPortal and (p.InPortal:EntIndex() == self:EntIndex()) then

			p:SetPos(self:GetPos() + self:GetForward()*25 + self:GetUp()*-40)

			p.InPortal = false
			p.PortalClone:Remove()
			p.PortalClone = nil
			p:SetMoveType(MOVETYPE_WALK)
for _, v in pairs( player.GetAll() ) do
   v:ResetHull()
end
			umsg.Start( "Portal:ObjectLeftPortal" )
			umsg.Entity( p )
			umsg.End()
		end
	end
end

function ENT:CleanMeUp()

	self.portal_loop:Stop("portal_loop")
	self.portal_loop2:Stop("portal_loop2")

	self:BootPlayer()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)


	local pos = self:GetPos()
	if self:OnFloor() then
		pos = pos-Vector(0,0,20)
	end

	if self.PortalType == TYPE_BLUE then
if GetConVarNumber("portal_color_1") >=14 then
	ParticleEffect("portal_gray_close",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=13 then
	ParticleEffect("portal_gray_close",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=12 then
	ParticleEffect("portal_gray_close",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=11 then
	ParticleEffect("portal_2_close_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=10 then
	ParticleEffect("portal_2_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=9 then
	ParticleEffect("portal_2_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=8 then
	ParticleEffect("portal_2_close_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=7 then
	ParticleEffect("portal_1_close",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=6 then
	ParticleEffect("portal_1_close_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=5 then
	ParticleEffect("portal_1_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=4 then
	ParticleEffect("portal_1_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=3 then
	ParticleEffect("portal_1_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=2 then
	ParticleEffect("portal_1_close_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=1 then
	ParticleEffect("portal_2_close",pos,ang,self)
else
	ParticleEffect("portal_2_close_pbody",pos,ang,self)
end
		elseif self.PortalType == TYPE_ORANGE then
if GetConVarNumber("portal_color_2") >=14 then
	ParticleEffect("portal_gray_close",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=13 then
	ParticleEffect("portal_gray_close",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=12 then
	ParticleEffect("portal_gray_close",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=11 then
	ParticleEffect("portal_2_close_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=10 then
	ParticleEffect("portal_2_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=9 then
	ParticleEffect("portal_2_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=8 then
	ParticleEffect("portal_2_close_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=7 then
	ParticleEffect("portal_1_close",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=6 then
	ParticleEffect("portal_1_close_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=5 then
	ParticleEffect("portal_1_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=4 then
	ParticleEffect("portal_1_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=3 then
	ParticleEffect("portal_1_close_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=2 then
	ParticleEffect("portal_1_close_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=1 then
	ParticleEffect("portal_2_close",pos,ang,self)
else
	ParticleEffect("portal_2_close_pbody",pos,ang,self)
end
	end

if !snd_portal2:GetBool() then
			self:EmitSound("weapons/portalgun/portal_close"..math.random(1,2)..".wav",70)
		else
			self:EmitSound("weapons/portalgun/portal2/portal_close"..math.random(1,2)..".wav",70)
end
	-- timer.Simple(5,function()
		-- if ent and ent:IsValid() then
			-- ent:Remove()
		-- end
	-- end)
	self:Remove()
end

function ENT:MoveToNewPos(pos,newang) --Called by the swep, used if a player already has a portal out.

	self:BootPlayer()
	if IsValid(self:GetOther()) then
		self:GetOther():BootPlayer()
	end

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	self:SetAngles(newang)

	local effectpos = self:GetPos()
	if self:OnFloor() then
		effectpos = effectpos-Vector(0,0,20)
	end
	self.VacuumEffect:SetPos(effectpos)
	self.EdgeEffect:SetPos(effectpos)

	if self.PortalType == TYPE_BLUE then
if GetConVarNumber("portal_color_1") >=14 then
	ParticleEffect("portal_gray_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=13 then
	ParticleEffect("portal_gray_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=12 then
	ParticleEffect("portal_gray_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=11 then
	ParticleEffect("portal_2_close_pbody",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=10 then
	ParticleEffect("portal_2_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=9 then
	ParticleEffect("portal_2_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=8 then
	ParticleEffect("portal_2_close_atlas",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=7 then
	ParticleEffect("portal_1_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=6 then
	ParticleEffect("portal_1_close_atlas",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=5 then
	ParticleEffect("portal_1_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=4 then
	ParticleEffect("portal_1_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=3 then
	ParticleEffect("portal_1_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=2 then
	ParticleEffect("portal_1_close_pbody",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_1") >=1 then
	ParticleEffect("portal_2_close",effectpos,ang,nil)
else
	ParticleEffect("portal_2_close_pbody",effectpos,ang,nil)
end
if !snd_portal2:GetBool() then
			self:EmitSound("weapons/portalgun/portal_close"..math.random(1,2)..".wav",70)
		else
			self:EmitSound("weapons/portalgun/portal2/portal_close"..math.random(1,2)..".wav",70)
end
	elseif self.PortalType == TYPE_ORANGE then
if GetConVarNumber("portal_color_2") >=14 then
	ParticleEffect("portal_gray_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=13 then
	ParticleEffect("portal_gray_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=12 then
	ParticleEffect("portal_gray_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=11 then
	ParticleEffect("portal_2_close_pbody",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=10 then
	ParticleEffect("portal_2_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=9 then
	ParticleEffect("portal_2_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=8 then
	ParticleEffect("portal_2_close_atlas",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=7 then
	ParticleEffect("portal_1_close",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=6 then
	ParticleEffect("portal_1_close_atlas",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=5 then
	ParticleEffect("portal_1_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=4 then
	ParticleEffect("portal_1_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=3 then
	ParticleEffect("portal_1_close_pink_green",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=2 then
	ParticleEffect("portal_1_close_pbody",effectpos,ang,nil)
elseif GetConVarNumber("portal_color_2") >=1 then
	ParticleEffect("portal_2_close",effectpos,ang,nil)
else
	ParticleEffect("portal_2_close_pbody",effectpos,ang,nil)
end
end

	self:SetPos( pos )

	if IsValid( self.Sides ) then
		self.Sides:SetPos(pos)
		self.Sides:SetAngles(newang)
	end

	if self:OnFloor() then
		pos.z = pos.z + 20
		self:SetPos( pos )
	end

	if self:OnRoof() and (not self:IsHorizontal()) then

if upsidedown:GetBool() then

		newang.z = newang.z + 180

		else

		newang.z = newang.z + 0

end

		self:SetAngles( newang )
	end



	umsg.Start("Portal:Moved" )
	umsg.Entity( self )
	umsg.Vector(pos)
	umsg.Angle(newang)
	umsg.End()

end


function ENT:SuccessEffect()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(),-90)
	ang:RotateAroundAxis(ang:Forward(),0)
	ang:RotateAroundAxis(ang:Up(),90)

	local pos = self:GetPos()
	if self:OnFloor() then
		pos = pos-Vector(0,0,20)
	end

	if self.PortalType == TYPE_BLUE then
if GetConVarNumber("portal_color_1") >=14 then
	ParticleEffect("portal_gray_success",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=13 then
	ParticleEffect("portal_gray_success",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=12 then
	ParticleEffect("portal_gray_success",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=11 then
	ParticleEffect("portal_2_success_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=10 then
	ParticleEffect("portal_2_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=9 then
	ParticleEffect("portal_2_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=8 then
	ParticleEffect("portal_2_success_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=7 then
	ParticleEffect("portal_1_success",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=6 then
	ParticleEffect("portal_1_success_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=5 then
	ParticleEffect("portal_1_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=4 then
	ParticleEffect("portal_1_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=3 then
	ParticleEffect("portal_1_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=2 then
	ParticleEffect("portal_1_success_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_1") >=1 then
	ParticleEffect("portal_2_success",pos,ang,self)
else
	ParticleEffect("portal_2_success_pbody",pos,ang,self)
end
		elseif self.PortalType == TYPE_ORANGE then
if GetConVarNumber("portal_color_2") >=14 then
	ParticleEffect("portal_gray_success",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=13 then
	ParticleEffect("portal_gray_success",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=12 then
	ParticleEffect("portal_gray_success",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=11 then
	ParticleEffect("portal_2_success_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=10 then
	ParticleEffect("portal_2_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=9 then
	ParticleEffect("portal_2_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=8 then
	ParticleEffect("portal_2_success_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=7 then
	ParticleEffect("portal_1_success",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=6 then
	ParticleEffect("portal_1_success_atlas",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=5 then
	ParticleEffect("portal_1_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=4 then
	ParticleEffect("portal_1_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=3 then
	ParticleEffect("portal_1_success_pink_green",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=2 then
	ParticleEffect("portal_1_success_pbody",pos,ang,self)
elseif GetConVarNumber("portal_color_2") >=1 then
	ParticleEffect("portal_2_success",pos,ang,self)
else
	ParticleEffect("portal_2_success_pbody",pos,ang,self)
end
	end

	local int = math.random(1,2)

	if self.PortalType == TYPE_BLUE then
if !snd_portal2:GetBool() then
			self:EmitSound("weapons/portalgun/portal_open1.wav",100 )
		else
			self:EmitSound("weapons/portalgun/portal2/portal_open1.wav",100 )
end
		elseif self.PortalType == TYPE_ORANGE then

if !snd_portal2:GetBool() then
	if int==1 then int = 3 end
	self:EmitSound("weapons/portalgun/portal_open"..int..".wav",100 )
		else
	if int==1 then int = 3 end
	self:EmitSound("weapons/portalgun/portal2/portal_open"..int..".wav",100 )
	self:EmitSound("weapons/portalgun/portal2/portal_open_rock"..math.random(1,2)..".wav",75 )
end

	end

end


function ENT:LinkPortals( ent )
	self:SetNWBool("Potal:Linked",true)
	self:SetNWEntity("Potal:Other",ent)
	ent:SetNWBool("Potal:Linked",true)
	ent:SetNWEntity("Potal:Other",self)
end

function ENT:OnTakeDamage(dmginfo)
end

--Mahalis code
function ENT:CanPort(ent)
	local c = ent:GetClass()
	if ent:IsPlayer() or (ent != nil && ent:IsValid() && !ent.isClone && ent:GetPhysicsObject() && c != "noportal_pillar" && c != "prop_dynamic" && c != "rpg_missile" && string.sub(c,1,5) != "func_" && string.sub(c,1,9) != "prop_door") then
		return true
	else
		return false
	end
end

function ENT:MakeClone(ent)

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	--if ent:GetClass() != "prop_physics" then return end

	local portal = self:GetNWEntity("Potal:Other")


	if ent.clone != nil then return end
	local clone = ents.Create("prop_physics")
	clone:SetSolid(SOLID_NONE)
	clone:SetPos(self:GetPortalPosOffsets(portal,ent))
	clone:SetAngles(self:GetPortalAngleOffsets(portal,ent))
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

	umsg.Start("Portal:ObjectInPortal" )
		umsg.Entity( portal )
		umsg.Entity( clone )
	umsg.End()
	clone.InPortal = portal
end


function ENT:SyncClone(ent)
	local clone = ent.clone

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end
	if clone == nil then return end

	local portal = self:GetNWEntity("Potal:Other")

	clone:SetPos(self:GetPortalPosOffsets(portal,ent))
	clone:SetAngles(self:GetPortalAngleOffsets(portal,ent))
end

function ENT:StartTouch(ent)
	--if ent:IsPlayer() then return end
	if ent:GetModel() == "models/blackops/portal_sides.mdl" then return end
	if ent:GetModel() == "models/blackops/portal_sides_new.mdl" then return end

if hitprop:GetBool() then
	local model = ent:GetModel()
	-- Optimisation : vérification par préfixes plutôt que modèles individuels
	if string.StartWith(model, "models/props_phx/") or
	   string.StartWith(model, "models/phxtended/") or
	   string.StartWith(model, "models/hunter/") then
		return
	end
end

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end

    -- Nettoyage : suppression des vérifications redondantes sur les modèles
    -- Les modèles hunter, props_phx et phxtended sont déjà filtrés plus haut avec string.StartWith()

	if ent:GetClass() == "projectile_portal_ball" then ent:SetPos(Vector(-500,-500,-500)) return end
	if ent:GetClass() == "projectile_portal_ball_atlas" then ent:SetPos(Vector(-500,-500,-500)) return end
	if ent:GetClass() == "projectile_portal_ball_pbody" then ent:SetPos(Vector(-500,-500,-500)) return end
	if ent:GetClass() == "projectile_portal_ball_guest" then ent:SetPos(Vector(-500,-500,-500)) return end
	if ent:GetClass() == "projectile_portal_ball_unknown" then ent:SetPos(Vector(-500,-500,-500)) return end


	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end

	--ent:SetNWEntity("ImInPortal",self)

	if ent.InPortal then return end


	if ent:IsPlayer() then

		if not self:PlayerWithinBounds(ent) then return end

		ent.JustEntered = true
		self:PlayerEnterPortal(ent)


	elseif self:CanPort(ent) then

	local phys = ent:GetPhysicsObject()

		constraint.AdvBallsocket( ent, game.GetWorld(), 0, 0, Vector(0,0,0), Vector(0,0,0), 0, 0,  -180, -180, -180, 180, 180, 180,  0, 0, 1, 1, 1 )
		self:MakeClone(ent)
	end
end

function ENT:Touch( ent )
	if ent.InPortal != self then self:StartTouch(ent) end
	--if ent:IsPlayer() then return end
	if !self:CanPort(ent) then return end

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end

	local portal = self:GetNWEntity("Potal:Other")

	if portal and portal:IsValid() then

		if ent:IsPlayer() then
			-- if ent.JustPorted then ent.InPortal = self return end
			--If the player isn't actually in the portal
			if not ent.InPortal then
				if not self:PlayerWithinBounds(ent) then return end
				ent.JustEntered = true
				self:PlayerEnterPortal(ent)

			else
				ent:SetGroundEntity( self )
				local eyepos = ent:EyePos()
				if !IsBehind( eyepos, self:GetPos(), self:GetForward() ) then --if the players eyes are behind the portal, we do the end touch shit we need anyway
					self:DoPort(ent) --end the touch
					ent.AlreadyPorted = true
				end
			end
		else
			self:SyncClone(ent)
			ent:SetGroundEntity( NULL )
		end

	end
end

function ENT:PlayerEnterPortal(ent)
	umsg.Start( "Portal:ObjectInPortal" )
		umsg.Entity( self )
		umsg.Entity( ent )
	umsg.End()
	ent.InPortal = self

	self:SetupPlayerClone(ent)

	ent:GetPhysicsObject():EnableDrag(true)

	local vel = ent:GetVelocity()
	ent:SetMoveType(MOVETYPE_NOCLIP)
	ent:SetGroundEntity( self )
	-- print("noclipping")

	if ent.JustEntered then
if !snd_portal2:GetBool() then
			ent:EmitSound("player/portal_enter"..math.random(1,2)..".wav",80,100 + (30 * (ent:GetVelocity():Length() - 450)/1000))
		else
			ent:EmitSound("player/portal2/portal_enter"..math.random(1,2)..".wav",80,100 + (30 * (ent:GetVelocity():Length() - 450)/1000))
end
		ent.JustEntered = false

for _, v in pairs( player.GetAll() ) do
   v:SetHullDuck( Vector( -16, -16, 0 ), Vector( 16, 16, 72 ) )
end
	end
end

function ENT:SetupPlayerClone(ply)
	if not ply.PortalClone then
		local ed = ents.Create("PortalPlayerClone")
		ed:SetEnt(ply)
		ed:SetPortal(self)
		ed:SetModel(ply:GetModel())
		ed:Spawn()
		ply.PortalClone = ed
	else
		ply.PortalClone:SetPortal(self)
	end

end

function ENT:EndTouch(ent)
	if ent.AlreadyPorted then
		ent.AlreadyPorted = false
	else
		self:DoPort(ent)
	end

end

function ENT:DoPort(ent) --Shared so we can predict it.

	if !self:CanPort(ent) then return end
	if !ent or !ent:IsValid() then return end
	if SERVER then
		constraint.RemoveConstraints(ent, "AdvBallsocket")
	end

	if self:GetNWBool("Potal:Linked",false) == false or self:GetNWBool("Potal:Activated",false) == false then return end

	if SERVER then
		umsg.Start( "Portal:ObjectLeftPortal" )
		umsg.Entity( ent )
		umsg.End()
	end

	local portal = self:GetNWEntity("Potal:Other")

	--Mahalis code
	local vel = ent:GetVelocity()
	if !vel then return end
	-- vel = vel - 2*vel:Dot(self:GetAngles():Up())*self:GetAngles():Up()
	local nuVel = self:TransformOffset(vel,self:GetAngles(),portal:GetAngles()) * -1

	local phys = ent:GetPhysicsObject()

	if portal and portal:IsValid() and phys:IsValid() and ent.clone and ent.clone:IsValid() and !ent:IsPlayer() then
		if !IsBehind( ent:GetPos(), self:GetPos(), self:GetForward() ) then
			ent:SetPos(ent.clone:GetPos())
			ent:SetAngles(ent.clone:GetAngles())
			phys:SetVelocity(nuVel)
		end


		ent.InPortal = nil

		ent.clone:Remove()
		ent.clone = nil
	elseif ent:IsPlayer() then
		local eyepos = ent:EyePos()

		if !IsBehind( eyepos, self:GetPos(), self:GetForward() ) then
			local newPos = self:GetPortalPosOffsets(portal,ent)

			ent:SetHeadPos(newPos)

			if portal:OnFloor() and self:OnFloor() then --pop players out of floor portals.
				if nuVel:Length() < 340 then
					nuVel = portal:GetForward() * 340
				end
			elseif portal:OnFloor() then
				if nuVel:Length() < 350 then
					nuVel = portal:GetForward() * 350
				end
			elseif portal:OnRoof() and (not portal:IsHorizontal()) then -- fixed velocity length of roofs portals
				if nuVel:Length() > vel_roof_max:GetInt() then
					nuVel = portal:GetForward() * vel_roof_max:GetInt()
				end
			elseif (not portal:IsHorizontal()) and (not portal:OnRoof()) then --pop harder for diagonals.
				if nuVel:Length() < 300 then
					nuVel = portal:GetForward() * 300
				end
			end

			-- print("Velocity Length:", nuVel:Length())
			-- print("Old Velocity:", ent:GetVelocity())
			-- print("New Velocity:", nuVel)
			ent:SetLocalVelocity(nuVel)

			--local newang = math.VectorAngles(ent:GetForward(), ent:GetUp()) + Angle(0,180,0) + (portal:GetAngles() - self:GetAngles())
			local newang = self:GetPortalAngleOffsets(portal,ent)
			ent:SetEyeAngles(newang)


			ent.JustEntered = false
			ent.JustPorted = true
			portal:PlayerEnterPortal(ent)
		elseif ent.InPortal == self then
			ent.InPortal = nil

-- Fixed Portals Roofs

			ent:SetMoveType(MOVETYPE_FLY)
-- print("MOVETYPE_FLY")

timer.Create( "Walk", 0.05, 1, function()
ent:SetMoveType(MOVETYPE_WALK)
for _, v in pairs( player.GetAll() ) do
   v:ResetHull()
end
-- print("MOVETYPE_WALK")
end)


			if SERVER then
if !snd_portal2:GetBool() then
			ent:EmitSound("player/portal_exit"..math.random(1,2)..".wav",80,100 + (30 * (nuVel:Length() - 450)/1000))
		else
			ent:EmitSound("player/portal2/portal_exit"..math.random(1,2)..".wav",80,100 + (30 * (nuVel:Length() - 450)/1000))
end
			end

			ent.PortalClone:Remove()
			ent.PortalClone = nil
			--print("Walking")
		end
	end
end

local function BulletHook(ent,bullet)
	if ent.FiredBullet then return end
	--Test if the bullet hits the portal.
	for k,inport in pairs(ents.FindByClass("prop_portal")) do --fix fake portal positions.
		if inport:OnFloor() then
			inport:SetPos(inport:GetPos()-Vector(0,0,20))
		end
	end

	for i=1, bullet.Num do
		local tr = util.QuickTrace(bullet.Src, bullet.Dir*10000, ent)

		if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_portal" then
			local inport = tr.Entity

			if inport:GetNWBool("Potal:Linked",false) == false or inport:GetNWBool("Potal:Activated",false) == false then return end

			local outport = inport:GetNWEntity("Potal:Other")
			if !IsValid(outport) then return end

			--Create our new bullet and get the hit pos of the inportal.
			local newbullet = table.Copy(bullet)

			if inport:OnFloor() and outport:OnFloor() then
				outport:SetPos(outport:GetPos() + Vector(0,0,20))
			end

			local offset = inport:WorldToLocal(tr.HitPos + bullet.Dir*20)

			offset.x = -offset.x;
			offset.y = -offset.y;

			--Correct bullet angles.
			local ang = bullet.Dir
			ang = inport:TransformOffset(ang,inport:GetAngles(),outport:GetAngles()) * -1
			newbullet.Dir = ang

			--Transfer to new portal.
			newbullet.Src = outport:LocalToWorld( offset ) + ang*10


			 umsg.Start("DebugOverlay_LineTrace")
				 umsg.Vector(bullet.Src)
				 umsg.Vector(tr.HitPos)
				 umsg.Bool(true)
			 umsg.End()
			 local p1 = util.QuickTrace(newbullet.Src,ang*10000,{outport,inport})
			 umsg.Start("DebugOverlay_LineTrace")
				 umsg.Vector(newbullet.Src)
				 umsg.Vector(p1.HitPos)
				 umsg.Bool(false)
			 umsg.End()

			newbullet.Attacker = ent
			outport.FiredBullet = true --prevent infinite loop.
			outport:FireBullets(newbullet)
			outport.FiredBullet = false

			if inport:OnFloor() and outport:OnFloor() then
				outport:SetPos(outport:GetPos() - Vector(0,0,20))
			end

		end
	end
	for k,inport in pairs(ents.FindByClass("prop_portal")) do
		if inport:OnFloor() then
			inport:SetPos(inport:GetPos()+Vector(0,0,20))
		end
	end
end
hook.Add("EntityFireBullets", "BulletPorting", BulletHook)

function ENT:SetActivatedState(bool)
	self.Activated = bool
	self:SetNWBool("Potal:Activated",bool)

	local other = self:FindOpenPair()
	if other and other:IsValid() then
		self:LinkPortals(other)
	end
end

function ENT:FindOpenPair() --This is for singeplayer, it finds a portal that is of the same type.
	local portals = ents.FindByClass( "prop_portal" );
	local mycolor = self:GetNWInt("Potal:PortalType",nil)
	local othercolor
	for k, v in pairs( portals ) do
		othercolor = v:GetNWInt("Potal:PortalType",nil)
		if v:GetNWBool("Potal:Activated",false) == true and v != self and othercolor and mycolor and othercolor != mycolor then
			return v
		end
	end
	return nil
end

function ENT:AcceptInput(name) --Map inputs (Seems to work..)

	if (name == "Fizzle") then
		self.Activated = false
		self:SetNWBool("Potal:Activated",false)
		self:CleanMeUp()
	end

	if (name == "SetActivatedState") then
		self:SetActivatedState(true)
	end

end

function ENT:KeyValue( key, value ) --Map keyvalues

	self.KeyValues[key] = value

	if key == "LinkageGroupID" then --I don't think this does jack shit, but it was on the valve wiki..
		self:SetNWInt("Potal:LinkageGroupID",value)
	end

	if key == "Activated" then --Set if it should start activated or not..
		self.Activated = tobool(value)
		self:SetNWBool("Potal:Activated",tobool(value))
	end

	if key == "PortalTwo" then --Sets the portal type
		self:SetType( value+1 )
	end

end

--Jintos code..
function math.VectorAngles( forward, up )

	local angles = Angle( 0, 0, 0 );

	local left = up:Cross( forward );
	left:Normalize();

	local xydist = math.sqrt( forward.x * forward.x + forward.y * forward.y );

	// enough here to get angles?
	if( xydist > 0.001 ) then

		angles.y = math.deg( math.atan2( forward.y, forward.x ) );
		angles.p = math.deg( math.atan2( -forward.z, xydist ) );
		angles.r = math.deg( math.atan2( left.z, ( left.y * forward.x ) - ( left.x * forward.y ) ) );

	else

		angles.y = math.deg( math.atan2( -left.x, left.y ) );
		angles.p = math.deg( math.atan2( -forward.z, xydist ) );
		angles.r = 0;

	end

	return angles;

end

hook.Add("SetupPlayerVisibility", "Add portalPVS", function(ply,ve)
	for k,self in pairs(ents.FindByClass("prop_portal"))do
		if not IsValid(self) then continue end
		local other = self:GetNWEntity("Potal:Other")
		if (not other) or (not IsValid(other)) then continue end
		local origin = ply:EyePos()
		local angles = ply:EyeAngles()

		local normal = self:GetForward()
		local distance = normal:Dot( self:GetPos() )

		// quick access
		local forward = angles:Forward()
		local up = angles:Up()

		// reflect origin
		local dot = origin:DotProduct( normal ) - distance
		origin = origin + ( -2 * dot ) * normal

		// reflect forward
		local dot = forward:DotProduct( normal )
		forward = forward + ( -2 * dot ) * normal

		// reflect up
		local dot = up:DotProduct( normal )
		up = up + ( -2 * dot ) * normal

		local ViewOrigin = self:WorldToLocal( origin )

		// repair
		ViewOrigin.y = -ViewOrigin.y

		ViewOrigin = other:LocalToWorld( ViewOrigin )
		-- if self:GetNWInt("Potal:PortalType") == TYPE_ORANGE then
			-- umsg.Start("DebugOverlay_Cross")
				-- umsg.Vector(ViewOrigin)
				-- umsg.Bool(true)
			-- umsg.End()
		-- end
		-- AddOriginToPVS(ViewOrigin)

		AddOriginToPVS(self:GetPos()+self:GetForward()*20)
	end
end)

concommand.Add("CreateParticles", function(p,c,a)
	local name = a[1]
	local ang = p:GetAngles()
	ang:RotateAroundAxis(p:GetRight(),90)
	ang:RotateAroundAxis(p:GetForward(),90)
	ParticleEffect(name,p:EyePos()+p:GetForward()*100,ang, (a[2] == 1 and self or nil))
end)

function ENT:OnRemove()
    -- Suppression des caisses liées
    if self.SpawnedCubes then
        for _, cube in ipairs(self.SpawnedCubes) do
            if IsValid(cube) then
                cube:Remove()
            end
        end
    end
	for k,v in pairs(ents.GetAll())do
		if v.InPortal == self then
			umsg.Start( "Portal:ObjectLeftPortal" )
			umsg.Entity( ent )
			umsg.End()
			v.InPortal = false
		end
	end
end

function ENT:GetGroundZ()
    local startPos = self:GetPos()
    local tr = util.TraceLine({
        start = startPos,
        endpos = startPos - Vector(0,0,10000),
        filter = self
    })
    return tr.HitPos.z
end

function ENT:SpawnCratesBelow()
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

    -- ... répéter pour les autres caisses autour ...
end

