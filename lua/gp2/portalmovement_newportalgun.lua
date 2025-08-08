if SERVER then
	AddCSLuaFile();
end;
local snd_portal2 = CreateClientConVar("portal_sound", "0", true, false);
local portal_prototype = CreateClientConVar("portal_prototype", "1", true, false);
local lastfootstep = 1;
local lastfoot = 0;
local nextFootStepTime = CurTime();
local function PlayFootstep(ply, level, pitch, volume)
	local sound = math.random(1, 4);
	while sound == lastfootstep do
		sound = math.random(1, 4);
	end;
	lastfoot = lastfoot == 0 and 1 or 0;
	local filter = SERVER and (RecipientFilter()):AddPVS(ply:GetPos()) or nil;
	if GAMEMODE:PlayerFootstep(ply, ply:GetPos(), lastfoot, "player/footsteps/concrete" .. sound .. ".wav", 0.6, filter) then
		return;
	end;
	ply:EmitSound("player/footsteps/concrete" .. sound .. ".wav", level, pitch, volume, CHAN_BODY);
end;
if CLIENT then
	local function CreateMove(cmd)
		local pl = LocalPlayer();
		if IsValid(pl) then
			if pl.InPortal and IsValid(pl.InPortal) and pl:GetMoveType() == MOVETYPE_NOCLIP then
				local right = 0;
				local forward = 0;
				local maxspeed = pl:GetMaxSpeed();
				if pl:Crouching() then
					maxspeed = pl:GetCrouchedWalkSpeed() * 180;
				end;
				if cmd:KeyDown(IN_FORWARD) then
					forward = forward + maxspeed;
				end;
				if cmd:KeyDown(IN_BACK) then
					forward = forward - maxspeed;
				end;
				if cmd:KeyDown(IN_MOVERIGHT) then
					right = right + maxspeed;
				end;
				if cmd:KeyDown(IN_MOVELEFT) then
					right = right - maxspeed;
				end;
				if cmd:KeyDown(IN_JUMP) then
					if pl.m_bSpacebarReleased and pl.InPortal:IsHorizontal() then
						pl.m_bSpacebarReleased = false;
						if (pl.InPortal:WorldToLocal(pl:GetPos())).z <= (-54) then
							GAMEMODE:DoAnimationEvent(LocalPlayer(), PLAYERANIMEVENT_JUMP);
						end;
					end;
				else
					pl.m_bSpacebarReleased = true;
				end;
				if cmd:KeyDown(IN_DUCK) then
					pl:SetViewOffset(Vector(0, 0, 0));
				end;
				cmd:SetForwardMove(forward);
				cmd:SetSideMove(right);
			end;
		end;
	end;
	hook.Add("CreateMove", "GP2_NewPortalGun_CreateMove", CreateMove);
end;
local function SubAxis(v, x)
	return v - v:Dot(x) * x;
end;
local function IsInFront(posA, posB, normal)
	local Vec1 = (posB - posA):GetNormalized();
	return normal:Dot(Vec1) < 0;
end;
function GP2_ipMove(ply, mv)
	local portal = ply.InPortal;
	if IsValid(portal) and ply:GetMoveType() == MOVETYPE_NOCLIP then
		local deltaTime = FrameTime();
		local curTime = CurTime();
		local noclipSpeed = 1.75;
		local noclipAccelerate = 5;
		local pos = mv:GetOrigin();
		local pOrg = portal:GetPos();
		if portal:OnFloor() then
			pOrg = pOrg - Vector(0, 0, 20);
		end;
		local pAng = portal:GetAngles();
		local ang = mv:GetMoveAngles();
		local acceleration = ang:Right() * mv:GetSideSpeed();
		local forward = (ang + Angle(0, 90, 0)):Right();
		acceleration = acceleration + forward * mv:GetForwardSpeed();
		local accelSpeed = math.min(acceleration:Length2D(), ply:GetMaxSpeed());
		local accelDir = acceleration:GetNormalized();
		acceleration = accelDir * accelSpeed * noclipSpeed;
		if accelSpeed > 0 and pos.z <= pOrg.z - 55 then
			if curTime > nextFootStepTime then
				nextFootStepTime = curTime + 0.4;
				PlayFootstep(ply, 50, 100, 0.4);
			end;
		end;
		local gravity = Vector(0, 0, 0);
		local g = GetConVarNumber("sv_gravity");
		if portal:IsHorizontal() then
			if pos.z > pOrg.z - 54 then
				gravity.z = -g;
			end;
		else
			gravity.z = -g;
		end;
		local getvel = mv:GetVelocity();
		local newVelocity = getvel + acceleration * deltaTime * noclipAccelerate;
		newVelocity = newVelocity + gravity * deltaTime;
		newVelocity.z = math.max(newVelocity.z, -3000);
		newVelocity.z = newVelocity.z * 0.9999;
		newVelocity.x = newVelocity.x * (0.98 - deltaTime * 5);
		newVelocity.y = newVelocity.y * (0.98 - deltaTime * 5);
		if mv:KeyDown(IN_JUMP) then
			if ply.m_bSpacebarReleased and portal:IsHorizontal() then
				ply.m_bSpacebarReleased = false;
				if (portal:WorldToLocal(pos)).z <= (-54) then
					newVelocity.z = ply:GetJumpPower();
					GAMEMODE:DoAnimationEvent(ply, PLAYERANIMEVENT_JUMP);
					PlayFootstep(ply, 40, 100, 0.6);
				end;
			end;
		else
			ply.m_bSpacebarReleased = true;
		end;
		local frontDist;
		if portal:IsHorizontal() then
			local OBBPos = util.ClosestPointInOBB(pOrg, ply:OBBMins(), ply:OBBMaxs(), ply:GetPos(), false);
			frontDist = OBBPos:PlaneDistance(pOrg, pAng:Forward());
		else
			frontDist = math.min(pos:PlaneDistance(pOrg, pAng:Forward()), (ply:GetHeadPos()):PlaneDistance(pOrg, pAng:Forward()));
		end;
		local localOrigin = portal:WorldToLocal(pos + newVelocity * deltaTime);
		local minY, maxY, minZ, maxZ;
		if portal:IsHorizontal() then
			minY = -20;
			maxY = 20;
			minZ = -55;
			maxZ = -14;
		else
			minY = -20;
			maxY = 20;
			minZ = -50;
			maxZ = 44;
		end;
		local frontNum = portal_prototype:GetBool() and 32 or 16;
		if frontDist < frontNum then
			localOrigin.z = math.Clamp(localOrigin.z, minZ, maxZ);
			localOrigin.y = math.Clamp(localOrigin.y, minY, maxY);
		else
			ply.PortalClone = nil;
			ply.InPortal = nil;
			ply:SetGroundEntity(NULL);
			ply:SetMoveType(MOVETYPE_WALK);
			for _, v in pairs(player.GetAll()) do
				v:ResetHull();
			end;
			if not snd_portal2:GetBool() then
				ply:EmitSound("PortalPlayer.ExitPortal", 80, 100 + 30 * (newVelocity:Length() - 450) / 1000);
			else
				ply:EmitSound("PortalPlayer.ExitPortal", 80, 100 + 30 * (newVelocity:Length() - 450) / 1000);
			end;
		end;
		local newOrigin = portal:LocalToWorld(localOrigin);
		mv:SetVelocity(newVelocity);
		mv:SetOrigin(newOrigin);
		return true;
	end;
end;
hook.Add("Move", "GP2_NewPortalGun_Movement", GP2_ipMove);
local vec = FindMetaTable("Vector");
if not vec.PlaneDistance then
	function vec:PlaneDistance(plane, normal)
		return normal:Dot(self - plane);
	end;
end;
if not math.YawBetweenPoints then
	function math.YawBetweenPoints(a, b)
		local xDiff = a.x - b.x;
		local yDiff = a.y - b.y;
		return math.atan2(yDiff, xDiff) * (180 / math.pi);
	end;
end;
if not util.ClosestPointInOBB then
	function util.ClosestPointInOBB(point, mins, maxs, center, Debug)
		local Debug = Debug or false;
		local yaw = math.rad(math.YawBetweenPoints(point, center));
		local radius;
		local abs_cos_angle = math.abs(math.cos(yaw));
		local abs_sin_angle = math.abs(math.sin(yaw));
		if 16 * abs_sin_angle <= 16 * abs_cos_angle then
			radius = 16 / abs_cos_angle;
		else
			radius = 16 / abs_sin_angle;
		end;
		radius = math.min(radius, math.Distance(center.x, center.y, point.x, point.y));
		local x, y = math.cos(yaw) * radius, math.sin(yaw) * radius;
		if Debug then
			if not CLIENT then
			else
				debugoverlay.Box(center, mins, maxs, FrameTime() + 0.01, Color(200, 30, 30, 0));
				debugoverlay.Line(center + Vector(0, 0, 0), center + Vector(x, y, 0), FrameTime() + 0.01, Color(200, 30, 30, 255));
				debugoverlay.Cross(center + Vector(x, y, 0), 2, 1, Color(300, 200, 30, 255));
				debugoverlay.Cross(point, 5, 1, Color(30, 200, 30, 255));
			end;
		end;
		return Vector(x, y, 0) + center;
	end;
end;
if SERVER then
	hook.Add("PreCleanupMap", "GP2_NewPortalGun_RemovePortals", function()
		for k, v in pairs(ents.FindByClass("prop_portal")) do
			if v.Fizzle then
				v:Fizzle();
			end;
		end;
	end);
	hook.Add("DoPlayerDeath", "GP2_NewPortalGun_RemovePortalsOnDeath", function(victim)
		local linkageGroup = victim:EntIndex() - 1;
		local portals = PortalManager.GetLinkageGroup(linkageGroup);
		if portals then
			for _, portal in pairs(portals) do
				if IsValid(portal) and portal.Fizzle then
					portal:Fizzle();
				end;
			end;
		end;
	end);
end;
GP2.Print("NewPortalGun movement system loaded successfully");
