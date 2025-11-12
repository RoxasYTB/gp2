SWEP.Slot = 0;
SWEP.SlotPos = 2;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = false;
SWEP.Spawnable = true;
SWEP.BobScale = 0;
SWEP.ViewModel = "models/weapons/v_portalgun.mdl";
SWEP.WorldModel = "models/weapons/portalgun/w_portalgun.mdl";
SWEP.ViewModelFOV = 50;
SWEP.Automatic = true;
SWEP.Primary.Ammo = "None";
SWEP.Primary.Automatic = true;
SWEP.Secondary.Ammo = "None";
SWEP.Secondary.Automatic = true;
SWEP.AutoSwitchFrom = true;
SWEP.AutoSwitchTo = true;
SWEP.PrintName = "Portal Gun";
SWEP.Category = "Portal 2";
PrecacheParticleSystem("portal_projectile_stream");
PrecacheParticleSystem("portal_badsurface");
PrecacheParticleSystem("portal_success");
PORTAL_PLACEMENT_FAILED = 0;
PORTAL_PLACEMENT_SUCCESFULL = 1;
PORTAL_PLACEMENT_BAD_SURFACE = 2;
PORTAL_PLACEMENT_INVALID_SURFACE = 2;
PORTAL_PLACEMENT_UNKNOWN_SURFACE = 3;
PORTAL_PLACEMENT_FIZZLER_HIT = 4;
function SWEP:Initialize()
	self:SetDeploySpeed(1);
	self:SetHoldType("shotgun");
	if SERVER then
		self.NextIdleTime = 0;
	end;
end;
function SWEP:SetupDataTables()
	self:NetworkVar("Bool", "IsPotatoGun");
	self:NetworkVar("Bool", "CanFirePortal1");
	self:NetworkVar("Bool", "CanFirePortal2");
	self:NetworkVar("Int", "LinkageGroup");
	self:NetworkVar("Entity", "LastPlacedPortal");
	self:NetworkVar("Entity", "EntityInUse");
	if SERVER then
		self:SetCanFirePortal1(true);
	end;
end;
function SWEP:PrimaryAttack()
	if not SERVER or (not self:GetCanFirePortal1()) or (not self:CanPrimaryAttack()) then
		return;
	end;
	(self:GetOwner()):EmitSound("Weapon_Portalgun.fire_blue");
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	(self:GetOwner()):SetAnimation(PLAYER_ATTACK1);
	self.NextIdleTime = CurTime() + 0.5;
	if (self:GetOwner()):IsPlayer() then
		(self:GetOwner()):ViewPunch(Angle(math.Rand(-1, -0.5), math.Rand(-1, 1), 0));
	end;
	if SERVER then
		self:PlacePortal(PORTAL_TYPE_FIRST, self:GetOwner());
	end;
	self:SetNextPrimaryFire(CurTime() + 0.5);
	self:SetNextSecondaryFire(CurTime() + 0.5);
end;
function SWEP:SecondaryAttack()
	if not SERVER or (not self:GetCanFirePortal2()) or (not self:CanPrimaryAttack()) then
		return;
	end;
	(self:GetOwner()):EmitSound("Weapon_Portalgun.fire_red");
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	(self:GetOwner()):SetAnimation(PLAYER_ATTACK1);
	self.NextIdleTime = CurTime() + 0.5;
	if (self:GetOwner()):IsPlayer() then
		(self:GetOwner()):ViewPunch(Angle(math.Rand(-1, -0.5), math.Rand(-1, 1), 0));
	end;
	if SERVER then
		self:PlacePortal(PORTAL_TYPE_SECOND, self:GetOwner());
	end;
	self:SetNextPrimaryFire(CurTime() + 0.5);
	self:SetNextSecondaryFire(CurTime() + 0.5);
end;
function SWEP:Reload()
	if CLIENT then
		return;
	end;
	local portal1 = (PortalManager.GetLinkageGroup(self:GetLinkageGroup()))[PORTAL_TYPE_FIRST];
	local portal2 = (PortalManager.GetLinkageGroup(self:GetLinkageGroup()))[PORTAL_TYPE_SECOND];
	if not (IsValid(portal1) or IsValid(portal2)) then
		return;
	end;
	self:ClearPortals();
	self:SendWeaponAnim(ACT_VM_FIZZLE);
	self.NextIdleTime = CurTime() + 0.5;
end;
function SWEP:ClearPortals()
	local portal1 = (PortalManager.GetLinkageGroup(self:GetLinkageGroup()))[PORTAL_TYPE_FIRST];
	local portal2 = (PortalManager.GetLinkageGroup(self:GetLinkageGroup()))[PORTAL_TYPE_SECOND];
	if SERVER then
		if IsValid(portal1) and self:GetCanFirePortal1() then
			portal1:Fizzle();
		end;
		if IsValid(portal2) and self:GetCanFirePortal2() then
			portal2:Fizzle();
		end;
	end;
	self:SetLastPlacedPortal(NULL);
end;
function SWEP:ClearSpawn()
end;
function SWEP:GetSyncedPortalGunState()
	if SERVER then
		local owner = self:GetOwner();
		if not IsValid(owner) or (not owner:IsPlayer()) then
			return false, false;
		end;
		local steamid = owner:SteamID();
		local state = GP2_PortalGunStates and GP2_PortalGunStates[steamid];
		if not state then
			return (GetConVar("gp2_portalgun_upgraded")):GetBool(), (GetConVar("gp2_portalgun_potato")):GetBool();
		end;
		return state.upgraded == true, state.potato == true;
	else
		return (GetConVar("gp2_portalgun_upgraded")):GetBool(), (GetConVar("gp2_portalgun_potato")):GetBool();
	end;
end;
