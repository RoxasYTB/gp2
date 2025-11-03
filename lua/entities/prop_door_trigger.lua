AddCSLuaFile();
ENT.Type = "anim";
ENT.Base = "base_anim";
function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate1x2.mdl");
	self:SetColor(Color(255, 255, 255, 0));
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:SetMaterial("models/debug/debugwhite");
	self:SetSolid(SOLID_BBOX);
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE);
	self:DrawShadow(false);
	self:SetNoDraw(false);
	if self.DoorTriggerType == nil then
		self:Remove();
		return;
	end;
end;
function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		if self.DoorTriggerType == "open" then
			RunConsoleCommand("open_first_door");
		elseif self.DoorTriggerType == "close" then
			RunConsoleCommand("close_first_door");
		end;
	end;
end;
