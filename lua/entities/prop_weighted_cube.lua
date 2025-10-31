AddCSLuaFile();
ENT.Type = "anim";
local CUBE_MODEL = "models/props/metal_box.mdl";
local CUBE_REFLECT_MODEL = "models/props/reflection_cube.mdl";
local CUBE_SHPERE_MODEL = "models/props_gameplay/mp_ball.mdl";
local CUBE_ANTIQUE_MODEL = "models/props_underground/underground_weighted_cube.mdl";
local SF_PHYSPROP_ENABLE_ON_PHYSCANNON = 64;
local CUBE_STANDARD_CLEAN_SKIN = 0;
local CUBE_STANDARD_CLEAN_ACTIVATED_SKIN = 2;
local CUBE_STANDARD_RUSTED_SKIN = 3;
local CUBE_STANDARD_RUSTED_ACTIVATED_SKIN = 5;
local CUBE_STANDARD_BOUNCE_SKIN = 6;
local CUBE_STANDARD_BOUNCE_ACTIVATED_SKIN = 10;
local CUBE_STANDARD_SPEED_SKIN = 7;
local CUBE_STANDARD_SPEED_ACTIVATED_SKIN = 11;
local CUBE_COMPANION_CLEAN_SKIN = 1;
local CUBE_COMPANION_CLEAN_ACTIVATED_SKIN = 4;
local CUBE_COMPANION_BOUNCE_SKIN = 8;
local CUBE_COMPANION_BOUNCE_ACTIVATED_SKIN = 8;
local CUBE_COMPANION_SPEED_SKIN = 9;
local CUBE_COMPANION_SPEED_ACTIVATED_SKIN = 9;
local CUBE_REFLECTIVE_CLEAN_SKIN = 0;
local CUBE_REFLECTIVE_RUSTED_SKIN = 1;
local CUBE_REFLECTIVE_BOUNCE_SKIN = 2;
local CUBE_REFLECTIVE_SPEED_SKIN = 3;
local CUBE_SPHERE_CLEAN_SKIN = 0;
local CUBE_SPHERE_CLEAN_ACTIVATED_SKIN = 1;
local CUBE_SPHERE_BOUNCE_SKIN = 2;
local CUBE_SPHERE_BOUNCE_ACTIVATED_SKIN = 2;
local CUBE_SPHERE_SPEED_SKIN = 3;
local CUBE_SPHERE_SPEED_ACTIVATED_SKIN = 3;
local CUBE_ANTIQUE_CLEAN_SKIN = 0;
local CUBE_ANTIQUE_BOUNCE_SKIN = 1;
local CUBE_ANTIQUE_SPEED_SKIN = 2;
local CUBE_STANDARD = 0;
local CUBE_COMPANION = 1;
local CUBE_REFLECTIVE = 2;
local CUBE_SPHERE = 3;
local CUBE_ANTIQUE = 4;
CUBE_TYPE_TO_INFO = {
	[CUBE_STANDARD] = {
		model = CUBE_MODEL
	},
	[CUBE_COMPANION] = {
		model = CUBE_MODEL
	},
	[CUBE_REFLECTIVE] = {
		model = CUBE_REFLECT_MODEL,
		spawnflags = SF_PHYSPROP_ENABLE_ON_PHYSCANNON
	},
	[CUBE_SPHERE] = {
		model = CUBE_SHPERE_MODEL
	},
	[CUBE_ANTIQUE] = {
		model = CUBE_ANTIQUE_MODEL
	}
};
function ENT:SetupDataTables()
	self:NetworkVar("Int", "CubeType");
	self:NetworkVar("Int", "PaintPower");
	self:NetworkVar("Entity", "ChildLaser");
	self:NetworkVar("Entity", "ParentLaser");
end;
function ENT:SetCubeSkin()
	if self:GetCubeType() == CUBE_STANDARD then
		if self.Rusted then
			self:SetSkin(self.Activated and CUBE_STANDARD_RUSTED_ACTIVATED_SKIN or CUBE_STANDARD_RUSTED_SKIN);
		elseif self:GetPaintPower() == BOUNCE_POWER then
			self:SetSkin(self.Activated and CUBE_STANDARD_BOUNCE_ACTIVATED_SKIN or CUBE_STANDARD_BOUNCE_SKIN);
		elseif self:GetPaintPower() == SPEED_POWER then
			self:SetSkin(self.Activated and CUBE_STANDARD_SPEED_ACTIVATED_SKIN or CUBE_STANDARD_SPEED_SKIN);
		elseif self:GetPaintPower() == NO_PAINT_POWER then
			self:SetSkin(self.Activated and CUBE_STANDARD_CLEAN_ACTIVATED_SKIN or CUBE_STANDARD_CLEAN_SKIN);
		end;
	elseif self:GetCubeType() == CUBE_COMPANION then
		if self:GetPaintPower() == BOUNCE_POWER then
			self:SetSkin(self.Activated and CUBE_COMPANION_BOUNCE_ACTIVATED_SKIN or CUBE_COMPANION_BOUNCE_SKIN);
		elseif self:GetPaintPower() == SPEED_POWER then
			self:SetSkin(self.Activated and CUBE_COMPANION_SPEED_ACTIVATED_SKIN or CUBE_COMPANION_SPEED_SKIN);
		elseif self:GetPaintPower() == NO_PAINT_POWER then
			self:SetSkin(self.Activated and CUBE_COMPANION_CLEAN_ACTIVATED_SKIN or CUBE_COMPANION_CLEAN_SKIN);
		end;
	elseif self:GetCubeType() == CUBE_REFLECTIVE then
		if self:GetPaintPower() == BOUNCE_POWER then
			self:SetSkin(CUBE_REFLECTIVE_BOUNCE_SKIN);
		elseif self:GetPaintPower() == SPEED_POWER then
			self:SetSkin(CUBE_REFLECTIVE_SPEED_SKIN);
		elseif self:GetPaintPower() == NO_PAINT_POWER then
			self:SetSkin(CUBE_REFLECTIVE_CLEAN_SKIN);
		end;
		self:SetRenderMode(RENDERMODE_NORMAL);
	elseif self:GetCubeType() == CUBE_SPHERE then
		if self:GetPaintPower() == BOUNCE_POWER then
			self:SetSkin(self.Activated and CUBE_SPHERE_BOUNCE_ACTIVATED_SKIN or CUBE_SPHERE_BOUNCE_SKIN);
		elseif self:GetPaintPower() == SPEED_POWER then
			self:SetSkin(self.Activated and CUBE_SPHERE_SPEED_ACTIVATED_SKIN or CUBE_SPHERE_SPEED_SKIN);
		elseif self:GetPaintPower() == NO_PAINT_POWER then
			self:SetSkin(self.Activated and CUBE_SPHERE_CLEAN_ACTIVATED_SKIN or CUBE_SPHERE_CLEAN_SKIN);
		end;
	elseif self:GetCubeType() == CUBE_ANTIQUE then
		if self:GetPaintPower() == BOUNCE_POWER then
			self:SetSkin(CUBE_ANTIQUE_BOUNCE_SKIN);
		elseif self:GetPaintPower() == SPEED_POWER then
			self:SetSkin(CUBE_ANTIQUE_SPEED_SKIN);
		elseif self:GetPaintPower() == NO_PAINT_POWER then
			self:SetSkin(CUBE_ANTIQUE_CLEAN_SKIN);
		end;
	end;
end;
function ENT:Initialize()
	if SERVER then
		self:ConvertOldSkins();
		self:SetUseType(SIMPLE_USE);
		self:SetModel(CUBE_TYPE_TO_INFO[self:GetCubeType()].model);
		self:SetCubeSkin();
		self:SetParent(NULL);
		self:SetSolid(SOLID_NONE);
		self._spawnPos = self:GetPos();
		self._spawnAng = self:GetAngles();
		self._shakeEndTime = CurTime() + 5;
		self:PhysicsInit(SOLID_VPHYSICS);
		print("Prop Weighted Cube: Initialisation avec le modèle %s", self:GetModel());
	end;
end;
function ENT:Think()
	if SERVER then
		self._nextImpulse = self._nextImpulse or 0;
		if CurTime() > self._nextImpulse then
			local phys = self:GetPhysicsObject();
			if IsValid(phys) and phys:IsMotionEnabled() then
				local touchingPortal = false;
				for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 5)) do
					if ent ~= self and ent:GetClass() == "prop_portal" then
						touchingPortal = true;
						break;
					end;
				end;
				if not touchingPortal then
					local tr = util.TraceLine({
						start = self:GetPos(),
						endpos = self:GetPos() - Vector(0, 0, 5),
						filter = self
					});
					if tr.Hit then
						local randVel = Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(60, 90));
						phys:AddVelocity(randVel);
					end;
				end;
			end;
			self._nextImpulse = CurTime() + math.Rand(0.3, 0.5);
		end;
		local shakeActive = false;
		for _, ent in ipairs(ents.FindByClass("prop_dynamic")) do
			if IsValid(ent) and (ent:GetPos()):Distance(self:GetPos()) < 32 then
				shakeActive = true;
				break;
			end;
		end;
		if shakeActive then
			local phys = self:GetPhysicsObject();
			if IsValid(phys) then
				local shake = Vector(math.Rand(-28, 28), math.Rand(-28, 28), math.Rand(24, 38));
				phys:AddVelocity(shake);
				phys:AddAngleVelocity(VectorRand((-1.5), 1.5) * math.Rand(6, 16));
			end;
		end;
		local phys = self:GetPhysicsObject();
		if IsValid(phys) and phys:IsMotionEnabled() then
			if GP2_ApplyPortalBelowImpulse then
				GP2_ApplyPortalBelowImpulse(self, phys);
			end;
		end;
		if self._visualOrigin and self._visualAngles then
			self:SetRenderOrigin(self._visualOrigin);
			self:SetRenderAngles(self._visualAngles);
		end;
		local childLaser = self:GetChildLaser();
		if IsValid(childLaser) then
			local childParentLaser = childLaser:GetParentLaser();
			if not (IsValid(childParentLaser) and childParentLaser:GetReflector() == self) then
				childLaser:Remove();
			end;
			self:NextThink(CurTime() + 0.01);
			return true;
		end;
	end;
	self:NextThink(CurTime() + 0.1);
	return true;
end;
if SERVER then
	ENT.UseNewSkins = false;
	ENT.Rusted = false;
	ENT.Activated = false;
	ENT.PaintPower = NO_PAINT_POWER;
	ENT.AllowFunnel = true;
	ENT.__input2func = {
		dissolve = function(self, activator, caller, data)
			self:Dissolve(ENTITY_DISSOLVE_NORMAL);
			self:TriggerOutput("OnFizzled");
		end,
		silentdissolve = function(self, activator, caller, data)
			self:Remove();
			self:TriggerOutput("OnFizzled");
		end
	};
	function ENT:AcceptInput(name, activator, caller, data)
		name = name:lower();
		local func = self.__input2func[name];
		if func and isfunction(func) then
			func(self, activator, caller, data);
		end;
	end;
	function ENT:KeyValue(k, v)
		if k == "CubeType" then
			self:SetCubeType(tonumber(v));
		elseif k == "SkinType" then
			self.Rusted = tobool(v);
		elseif k == "NewSkins" then
			self.UseNewSkins = tobool(v);
		elseif k == "skin" then
			self:SetSkin(tonumber(v));
		elseif k == "allowfunnel" then
			self.AllowFunnel = tobool(v);
		end;
		if k:StartsWith("On") then
			self:StoreOutput(k, v);
		end;
	end;
	function ENT:ConvertOldSkins()
		if not self.UseNewSkins then
			if self:GetSkin() > 1 then
				self:SetSkin(self:GetSkin() - 1);
			end;
			self:SetCubeType(self:GetSkin());
			self.UseNewSkins = true;
		end;
	end;
	function ENT:SetActivated(activate)
		self.Activated = activate;
		self:SetCubeSkin();
	end;
	function ENT:SetLaserOnce(laser)
		if not IsValid(self:GetLaser()) then
			self:SetLaser(laser);
		end;
	end;
	function ENT:Use(activator, caller, useType, value)
		if activator:IsPlayer() and (not activator:IsPlayerHolding()) then
			activator:PickupObject(self);
		end;
	end;
	function ENT:GetPreferredCarryAngles(ply)
		if self:GetCubeType() == CUBE_REFLECTIVE then
			local angles = ply:EyeAngles();
			local selfAngles = self:GetAngles();
			return Angle(0 - angles.x, 0, 0);
		end;
	end;
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS;
	end;
	function ENT:OnPhysgunPickup(ply, ent)
		self:TriggerOutput("OnPhysGunPickup");
		return true;
	end;
	function ENT:OnPhysgunDrop(ply, ent)
		self:TriggerOutput("OnPhysGunDrop");
	end;
	function ENT:OnPlayerPickup(ply, ent)
		self:TriggerOutput("OnPlayerPickup");
	end;
	function ENT:OnPlayerDrop(ply, ent, thrown)
		self:TriggerOutput("OnPlayerDrop");
		self:TriggerOutput("OnPhysGunDrop");
	end;
	function ENT:OnGravGunPickup(ply)
		self:TriggerOutput("OnPhysGunPickup");
	end;
	function ENT:OnGravGunDrop(ply, ent, thrown)
		self:TriggerOutput("OnPhysGunDrop");
	end;
end;
if CLIENT then
	function ENT:Initialize()
		self:DrawShadow(false);
	end;
	function ENT:Draw()
		local pos = self._spawnPos or self:GetPos();
		local ang = self._spawnAng or self:GetAngles();
		self:SetRenderOrigin(pos);
		self:SetRenderAngles(ang);
		self:DrawModel();
		self:SetRenderOrigin();
		self:SetRenderAngles();
	end;
end;
function ENT:HasLaser()
	return IsValid(self:GetLaser());
end;
