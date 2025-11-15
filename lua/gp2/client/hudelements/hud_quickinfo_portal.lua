AddCSLuaFile();
local surface_SetDrawColor = surface.SetDrawColor;
local surface_SetMaterial = surface.SetMaterial;
local surface_DrawRect = surface.DrawRect;
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV;
local PANEL = {};
PANEL.BaseClass = baseclass.Get("GP2Panel");
local VALID_CLASSES = {
	weapon_portalgun = true
};
local crosshairParts = {
	{
		width = 47,
		height = 64,
		xOffset = 0
	},
	{
		width = 46,
		height = 64,
		xOffset = 49
	},
	{
		width = 46,
		height = 64,
		xOffset = 97
	},
	{
		width = 46,
		height = 64,
		xOffset = 145
	},
	{
		width = 30,
		height = 64,
		xOffset = 185
	}
};
local crosshairMaterial = Material("hud/portal_crosshairs.png");
local ref = Material("hud/ref1.png");
local alpha = 1;
local function drawCrosshairPart(id, x, y, r, g, b, a)
	local part = crosshairParts[id];
	if not part then
		GP2.Print("Invalid crosshair part ID:", id);
		return;
	end;
	surface_SetDrawColor(r, g, b, a);
	surface_SetMaterial(crosshairMaterial);
	local textureWidth = crosshairMaterial:Width();
	local u0 = part.xOffset / textureWidth;
	local v0 = 0;
	local u1 = (part.xOffset + part.width) / textureWidth;
	local v1 = 1;
	surface_DrawTexturedRectUV(x, y, part.width, part.height, u0, v0, u1, v1);
end;
local function desaturateAndBrighten(r, g, b)
	local gray = 0.3 * r + 0.59 * g + 0.11 * b;
	local desaturationFactor = 0.5;
	local brightnessFactor = 1.6;
	r = r * (1 - desaturationFactor) + gray * desaturationFactor;
	g = g * (1 - desaturationFactor) + gray * desaturationFactor;
	b = b * (1 - desaturationFactor) + gray * desaturationFactor;
	r = r * brightnessFactor;
	g = g * brightnessFactor;
	b = b * brightnessFactor;
	r = math.min(255, math.max(0, r));
	g = math.min(255, math.max(0, g));
	b = math.min(255, math.max(0, b));
	return r, g, b;
end;
local portalCache = {};
local lastPortalCacheUpdate = 0;
local cacheUpdateInterval = 0.2;
local function findPlayerPortals(weapon)
	local curTime = CurTime();
	if curTime - lastPortalCacheUpdate > cacheUpdateInterval then
		portalCache = {};
		for _, portal in ipairs(ents.FindByClass("prop_portal")) do
			if IsValid(portal) and portal:GetActivated() then
				local lg = portal:GetLinkageGroup();
				if not portalCache[lg] then
					portalCache[lg] = {};
				end;
				portalCache[lg][portal:GetType()] = portal;
			end;
		end;
		lastPortalCacheUpdate = curTime;
	end;
	local myLinkageGroup = weapon:GetLinkageGroup();
	local group = portalCache[myLinkageGroup];
	if group then
		return group[PORTAL_TYPE_FIRST], group[PORTAL_TYPE_SECOND];
	end;
	return nil, nil;
end;
function PANEL:Init()
	self:SetWidth(ScrW());
	self:SetTall(ScrH());
	self:SetParent(GetHUDPanel());
end;
function PANEL:Paint(w, h)
	local backupAlpha = surface.GetAlphaMultiplier();
	surface.SetAlphaMultiplier(alpha);
	self.ply = self.ply or LocalPlayer();
	local ply = self.ply;
	local weapon = ply:GetActiveWeapon();
	if ply:InVehicle() and (not ply:GetAllowWeaponsInVehicle()) or ply:GetViewEntity() ~= ply then
		alpha = math.Approach(alpha, 0, FrameTime() * 10);
	else
		alpha = math.Approach(alpha, 1, FrameTime() * 10);
	end;
	if not (IsValid(weapon) and VALID_CLASSES[weapon:GetClass()]) then
		return;
	end;
	surface_SetMaterial(crosshairMaterial);
	local can1 = weapon.GetCanFirePortal1 and weapon:GetCanFirePortal1() or false;
	local can2 = weapon.GetCanFirePortal2 and weapon:GetCanFirePortal2() or false;
	if not (can1 or can2) then
		return;
	end;
	local placed1, placed2 = findPlayerPortals(weapon);
	local colors = GP2.GetClientPlayerPortalColors(LocalPlayer());
	local col1 = GP2_GetPortalDisplayColorByName(colors.color1 or "blue");
	local col2 = GP2_GetPortalDisplayColorByName(colors.color2 or "orange");
	local r1, g1, b1 = col1.r, col1.g, col1.b;
	local r2, g2, b2 = col2.r, col2.g, col2.b;
	if not can2 then
		r2, g2, b2 = r1, g1, b1;
	end;
	if can1 and IsValid(placed1) then
		drawCrosshairPart(3, w / 2 - 29, h / 2 - 44, r1, g1, b1, 255);
	else
		drawCrosshairPart(1, w / 2 - 31, h / 2 - 44, r1, g1, b1, 196);
	end;
	if can2 then
		if IsValid(placed2) then
			drawCrosshairPart(4, w / 2 - 17, h / 2 - 22, r2, g2, b2, 255);
		else
			drawCrosshairPart(2, w / 2 - 18, h / 2 - 22, r2, g2, b2, 196);
		end;
	elseif IsValid(placed1) then
		drawCrosshairPart(4, w / 2 - 17, h / 2 - 22, r1, g1, b1, 255);
	else
		drawCrosshairPart(2, w / 2 - 18, h / 2 - 22, r1, g1, b1, 196);
	end;
	surface_SetDrawColor(255, 255, 255, 255);
	surface_DrawRect(w / 2 - 1, h / 2, 1, 1);
	surface_DrawRect(w / 2 - 1, h / 2 + 11, 1, 1);
	surface_DrawRect(w / 2 - 1, h / 2 - 11, 1, 1);
	surface_DrawRect(w / 2 - 11, h / 2, 1, 1);
	surface_DrawRect(w / 2 + 9, h / 2, 1, 1);
	surface.SetAlphaMultiplier(backupAlpha);
end;
function PANEL:ShouldDraw()
	if not self.BaseClass.ShouldDraw() then
		return false;
	end;
	return true;
end;
vgui.Register("GP2HudQuickinfoPortal", PANEL, "GP2Panel");
