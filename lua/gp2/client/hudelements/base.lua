AddCSLuaFile();
local PANEL = {};
local cl_drawhud = GetConVar("cl_drawhud");
function PANEL:Init()
	self:SetVisible(true);
end;
function PANEL:Think()
end;
function PANEL:ShouldDraw()
	if not cl_drawhud:GetBool() then
		return false;
	end;
	return true;
end;
function PANEL:OnCursorEntered()
	for _, ply in ipairs(player.GetAll()) do
		if ply ~= LocalPlayer() and ply.PlayerNameLabel then
			ply.PlayerNameLabel:SetVisible(false);
		end;
	end;
end;
function PANEL:OnCursorExited()
	for _, ply in ipairs(player.GetAll()) do
		if ply ~= LocalPlayer() and ply.PlayerNameLabel then
			ply.PlayerNameLabel:SetVisible(false);
		end;
	end;
end;
vgui.Register("GP2Panel", PANEL, "Panel");
