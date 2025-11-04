ENT.Type = "brush";
ENT.Base = "base_brush";
local math_min = math.min;
local mats = {};
local ENTS_TO_DISSOLVE = {
	prop_physics = true,
	prop_weighted_cube = true,
	prop_monster_box = true,
	npc_portal_turret_floor = true,
	npc_turret_floor = true
};
local DURATION_SLEEP = 1;
local DURATION_WAKE = 1;
function ENT:KeyValue(k, v)
	if k == "StartDisabled" then
		self:SetEnabled(not tobool(v));
	elseif k == "Visible" then
		self:SetVisible(tobool(v));
	elseif k == "UseScanline" then
		self:SetUseScanline(tobool(v));
	end;
	if k:StartsWith("On") then
		self:StoreOutput(k, v);
	end;
end;
function ENT:SetupDataTables()
	self:NetworkVar("Bool", "Enabled");
	self:NetworkVar("Bool", "Visible");
	self:NetworkVar("Bool", "UseScanline");
	self:NetworkVar("Float", "LastEnableTime");
	if SERVER then
		self:SetEnabled(true);
	end;
end;
function ENT:Initialize()
	self:SetTrigger(true);
	if self:GetVisible() then
		self:RemoveEffects(EF_NODRAW);
	end;
end;
function ENT:StartTouch(ent)
	if not self:GetEnabled() then
		return;
	end;
	if not IsValid(ent) then
		return;
	end;
	if ent:IsPlayer() then
		local weapons = ent:GetWeapons();
		for i = 1, #weapons do
			local weapon = weapons[i];
			if IsValid(weapon) and weapon:GetClass() == "weapon_portalgun" and weapon.CleanPortals then
				weapon:CleanPortals();
			end;
		end;
	end;
	if not ENTS_TO_DISSOLVE[ent:GetClass()] then
		return;
	end;
	ent:Dissolve(0);
end;

function ENT:Initialize()
	-- ParticleEffectAttach("portal_cleanser",PATTACH_ABSORIGIN,self,1)

	self:SetTrigger(true)
end

function ENT:Touch( ent )



	if ent:IsPlayer() and ent:Alive() then
		local plyweap = ent:GetActiveWeapon();
		if IsValid(plyweap) and plyweap:GetClass() == "weapon_portalgun" then
			plyweap:Reload();
		end;

	elseif ent and ent:IsValid() then
		if ent:GetClass()=="projectile_portal_ball" or ent:GetClass()=="projectile_portal_ball_atlas" or ent:GetClass()=="projectile_portal_ball_pbody" or ent:GetClass()=="projectile_portal_ball_guest" or ent:GetClass()=="projectile_portal_unknown" then
			//portal ball projectile.
			local ang = ent:GetAngles()
			ang:RotateAroundAxis(ent:GetForward(),90)
			ang.y = self:GetAngles().y+90
			ent:Remove()
		elseif ent:GetClass() == "prop_physics" and ent.GP2_IsPortalPlatform then
			return
		else
			if ent:GetName() != "dissolveme" then
				local vel = ent:GetVelocity()
				local fakebox = ents.Create("prop_physics")
				fakebox:SetModel(ent:GetModel())
				fakebox:SetPos(ent:GetPos())
				fakebox:SetAngles(ent:GetAngles())
				fakebox:Spawn()
				fakebox:Activate()
				fakebox:SetSkin(ent:GetSkin())
				fakebox:SetName("dissolveme")
				local phys = fakebox:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableGravity(false)
					phys:Wake()
					phys:SetVelocity(vel/10)
				end
				ent:Remove()
				local dissolver = ents.Create("env_entity_dissolver")
				dissolver:SetKeyValue("dissolvetype", 0)
				dissolver:SetKeyValue("magnitude", 0)
				dissolver:Spawn()
				dissolver:Activate()
				dissolver:Fire("Dissolve", "dissolveme", 0)
				dissolver:Fire("kill", "", 0.1)
			end
		end
	end
end

function ENT:EndTouch( ent )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS;
end;
function ENT:Think()
	local surfaces = self:GetBrushSurfaces();
	local curtime = CurTime();
	local minBounds, maxBounds = self:GetCollisionBounds();
	local radius = (maxBounds - minBounds):Length() / 2;
	local pos = self:GetPos();
	local targetPowerup = self:GetEnabled() and 1 or 0;
	local duration = self:GetEnabled() and DURATION_WAKE or DURATION_SLEEP;
	local powerupValue = self.FullPowerup or 0;
	powerupValue = math.Approach(powerupValue, targetPowerup, FrameTime() / duration);
	self.FullPowerup = powerupValue;
	for _, surface in ipairs(surfaces) do
		(surface:GetMaterial()):SetFloat("$powerup", powerupValue);
	end;
	local entsInSphere = ents.FindInSphere(pos, radius);
	local vortexEnts = 0;
	for _, ent in ipairs(entsInSphere) do
		if not ENTS_TO_DISSOLVE[ent:GetClass()] then
			continue;
		end;
		if ent == self or (not IsValid(ent)) or ent:IsPlayer() and (not ent:Alive()) then
			continue;
		end;
		vortexEnts = vortexEnts + 1;
		if vortexEnts > 2 then
			break;
		end;
		for _, surface in ipairs(surfaces) do
			(surface:GetMaterial()):SetInt("$FLOW_VORTEX" .. vortexEnts, 1);
			(surface:GetMaterial()):SetVector("$FLOW_VORTEX_POS" .. vortexEnts, ent:GetPos());
		end;
	end;
	for i = vortexEnts + 1, 2 do
		for _, surface in ipairs(surfaces) do
			(surface:GetMaterial()):SetInt("$FLOW_VORTEX" .. i, 0);
		end;
	end;
	self:NextThink(CurTime());
	return true;
end;
function ENT:AcceptInput(name, activator, caller, value)
	name = name:lower();
	if name == "enable" then
		self:Enable();
	elseif name == "disable" then
		self:Disable();
	end;
end;
function ENT:Enable()
	if self:GetEnabled() then
		return;
	end;
	self:SetLastEnableTime(CurTime());
	self:SetEnabled(true);
	self:EmitSound("VFX.FizzlerStart");
	self:StopSound("VFX.FizzlerDestroy");
end;
function ENT:Disable()
	if not self:GetEnabled() then
		return;
	end;
	self:SetLastEnableTime(CurTime());
	self:SetEnabled(false);
	self:EmitSound("VFX.FizzlerDestroy");
	self:StopSound("VFX.FizzlerStart");
end;
