AddCSLuaFile();
ENT.Type = "brush";
ENT.Base = "base_trigger";
function ENT:Initialize()
	self:SetColor(Color(255, 255, 255, 0));
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:SetMaterial("models/debug/debugwhite");
	self:DrawShadow(false);
	self:SetNoDraw(false);
	self:SetTrigger(true);
	self:UseTriggerBounds(true, 16);
	if not self.DoorTriggerType then
		self:Remove();
	end;
end;
function ENT:StartTouch(ent)
	if not ent:IsPlayer() then
		return;
	end;
	if self.DoorTriggerType == "open" then
		RunConsoleCommand("open_first_door");
	elseif self.DoorTriggerType == "close" then
		RunConsoleCommand("close_first_door");
	end;
end;
