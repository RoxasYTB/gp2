AddCSLuaFile();
ENT.Type = "anim";
ENT.PrintName = "#env_portal_laser_short";
ENT.Category = "Portal 2";
ENT.Spawnable = true;
ENT.Editable = true;
if SERVER then
	util.AddNetworkString("LaserSegments");
end;
util.PrecacheSound("Flesh.BulletImpact");
local particlesToPrecache = {
	"reflector_start_glow",
	"laser_start_glow",
	"laser_relay_powered",
	"discouragement_beam_sparks"
};
local function ParticleSystemExists(name)
	local success = pcall(PrecacheParticleSystem, name);
	return success;
end;
for _, particleName in ipairs(particlesToPrecache) do
	if ParticleSystemExists(particleName) then
	else
		print("[GP2] Avertissement: Système de particules '" .. particleName .. "' non trouvé");
	end;
end;
function ENT:GetParticleNameOrFallback(particleName, fallback)
	local function ParticleExists(name)
		local success = pcall(PrecacheParticleSystem, name);
		return success;
	end;
	if ParticleExists(particleName) then
		return particleName;
	elseif fallback and ParticleExists(fallback) then
		return fallback;
	else
		return nil;
	end;
end;
function ENT:SetupDataTables()
	self:NetworkVar("Bool", "State", {
		KeyName = "state",
		Edit = {
			type = "Bool",
			order = 1
		}
	});
	self:NetworkVar("Bool", "LethalDamage");
	self:NetworkVar("Bool", "AutoAim");
	self:NetworkVar("Bool", "ShouldSpark");
	self:NetworkVar("Bool", "NoModel");
	self:NetworkVar("Vector", "HitPos");
	self:NetworkVar("Vector", "HitNormal");
	self:NetworkVar("Entity", "ParentLaser");
	self:NetworkVar("Entity", "ChildLaser");
	self:NetworkVar("Entity", "Reflector");
	self:NetworkVarNotify("State", self.OnStateChange);
	if SERVER then
		self:SetShouldSpark(true);
		self:SetState(true);
		self:SetHitPos(Vector(2 ^ 16, 2 ^ 16, 2 ^ 16));
	end;
end;
