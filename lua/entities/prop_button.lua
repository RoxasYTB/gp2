AddCSLuaFile();
ENT.Type = "anim";
ENT.AutomaticFrameAdvance = true;
if SERVER then
	ENT.NextReleaseTime = 0;
	ENT.NextTickSoundTime = 0;
end;
util.PrecacheSound("Portal.button_down");
util.PrecacheSound("Portal.button_up");
util.PrecacheSound("Portal.button_locked");
util.PrecacheSound("Portal.room1_TickTock");
ENT.__input2func = {
	press = function(self, activator, caller, data)
		self:Press();
	end,
	release = function(self, activator, caller, data)
		self:Release();
	end,
	lock = function(self, activator, caller, data)
		self:Lock();
	end,
	unlock = function(self, activator, caller, data)
		self:Unlock();
	end,
	cancelpress = function(self, activator, caller, data)
		self:CancelPress();
	end
};
function ENT:Initialize()
	self:SetModel(self:GetButtonModelName());
	self:PhysicsInitStatic(SOLID_VPHYSICS);
	if SERVER then
		self:SetUseType(SIMPLE_USE);
		self.PlayerNearby = false;
		self.CheckDistance = 100;
		self.HasRetriggered = false;
		self.RetriggerScheduled = false;
	end;
	self.UpSequence = self:LookupSequence("up");
	self.DownSequence = self:LookupSequence("down");
	self.SoundDown = "Portal.button_down";
	self.SoundUp = "Portal.button_up";
end;
function ENT:GetButtonModelName()
	return "models/props/switch001.mdl";
end;
function ENT:SetupDataTables()
	self:NetworkVar("Bool", "IsPressed");
	self:NetworkVar("Bool", "IsLocked");
end;
function ENT:AcceptInput(name, activator, caller, data)
	name = name:lower();
	local func = self.__input2func[name];
	if func and isfunction(func) then
		func(self, activator, caller, data);
	end;
end;
function ENT:KeyValue(k, v)
	if k == "Delay" then
		self.DelayBeforeReset = tonumber(v);
	elseif k == "preventfastreset" then
		self.PreventFastReset = tobool(v);
	elseif k == "istimer" then
		self.HasTimer = tobool(v);
	elseif k == "CheckDistance" then
		self.CheckDistance = tonumber(v) or 100;
	end;
	if k:StartsWith("On") then
		self:StoreOutput(k, v);
		if string.find(v, "prop_dynamic", 1, true) then
			self.NoRetrigger = true;
		end;
	end;
end;
function ENT:Use(activator, caller, useType, value)
	if useType == USE_ON then
		self:Press();
	elseif useType == USE_OFF then
		self:Release();
	elseif self:GetIsPressed() then
		self:Release();
	else
		self:Press();
	end;
end;
function ENT:TriggerPressedOutput()
	self:TriggerOutput("OnPressed");
	self:TriggerOutput("OnButtonPressed");
end;
function ENT:TriggerUnpressedOutput()
	self:TriggerOutput("OnUnPressed");
	self:TriggerOutput("OnButtonUnPressed");
	self:TriggerOutput("OnReleased");
end;
function ENT:TriggerPressedOutput()
	self:TriggerOutput("OnPressed");
	self:TriggerOutput("OnButtonPressed");
end;
function ENT:TriggerUnpressedOutput()
	self:TriggerOutput("OnUnPressed");
	self:TriggerOutput("OnButtonUnPressed");
	self:TriggerOutput("OnReleased");
end;
function ENT:Press()
	if self:GetIsLocked() then
		return;
	end;
	if self:GetIsPressed() then
		return;
	end;
	self:SetIsPressed(true);
	self:EmitSound(self.SoundDown);
	self:ResetSequence(self.DownSequence);
	self:TriggerPressedOutput();
	if SERVER and GP2 and GP2.ButtonLogging then
		GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), true);
	end;
	if SERVER then
		self.HasRetriggered = false;
		self.RetriggerScheduled = false;
	end;
	if self.DelayBeforeReset and self.DelayBeforeReset > 0 then
		self.NextReleaseTime = CurTime() + self.DelayBeforeReset;
	else
		self.NextReleaseTime = 0;
	end;
end;
function ENT:Release()
	if not self:GetIsPressed() then
		return;
	end;
	self:SetIsPressed(false);
	self:EmitSound(self.SoundUp);
	self:ResetSequence(self.UpSequence);
	self:TriggerUnpressedOutput();
	if SERVER and GP2 and GP2.ButtonLogging then
		GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false);
	end;
	if SERVER and (not self.HasRetriggered) and (not self.RetriggerScheduled) and (not self.NoRetrigger) then
		local retrigger_enabled = GetConVar("gp2_floor_button_retrigger");
		if retrigger_enabled and retrigger_enabled:GetBool() then
			self.RetriggerScheduled = true;
			timer.Simple(0.05, function()
				if IsValid(self) and (not self.HasRetriggered) then
					local playerNearby = false;
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) and ply:Alive() then
							local distance = (self:GetPos()):Distance(ply:GetPos());
							if distance <= self.CheckDistance then
								playerNearby = true;
								break;
							end;
						end;
					end;
					if not playerNearby then
						self.HasRetriggered = true;
						self:SetIsPressed(true);
						self:EmitSound(self.SoundDown);
						self:ResetSequence(self.DownSequence);
						self:TriggerPressedOutput();
						if SERVER and GP2 and GP2.ButtonLogging then
							GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), true);
						end;
						timer.Simple(0.05, function()
							if IsValid(self) and self:GetIsPressed() then
								self:SetIsPressed(false);
								self:EmitSound(self.SoundUp);
								self:ResetSequence(self.UpSequence);
								self:TriggerUnpressedOutput();
								if SERVER and GP2 and GP2.ButtonLogging then
									GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false);
								end;
							end;
						end);
					end;
				end;
			end);
		end;
	end;
end;
function ENT:CancelPress()
	if not self:GetIsPressed() then
		return;
	end;
	self:SetIsPressed(false);
	self:EmitSound(self.SoundUp);
	self:ResetSequence(self.UpSequence);
	self:TriggerOutput("OnButtonReset");
	if SERVER and GP2 and GP2.ButtonLogging then
		GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false);
	end;
	if SERVER and self.DelayBeforeReset and self.DelayBeforeReset > 0 and (not self.HasRetriggered) and (not self.RetriggerScheduled) and (not self.NoRetrigger) then
		local retrigger_enabled = GetConVar("gp2_floor_button_retrigger");
		if retrigger_enabled and retrigger_enabled:GetBool() then
			self.RetriggerScheduled = true;
			timer.Simple(0.05, function()
				if IsValid(self) and (not self.HasRetriggered) then
					local playerNearby = false;
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) and ply:Alive() then
							local distance = (self:GetPos()):Distance(ply:GetPos());
							if distance <= self.CheckDistance then
								playerNearby = true;
								break;
							end;
						end;
					end;
					if not playerNearby then
						self.HasRetriggered = true;
						self:SetIsPressed(true);
						self:EmitSound(self.SoundDown);
						self:ResetSequence(self.DownSequence);
						self:TriggerPressedOutput();
						if SERVER and GP2 and GP2.ButtonLogging then
							GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), true);
						end;
						timer.Simple(0.05, function()
							if IsValid(self) and self:GetIsPressed() then
								self:SetIsPressed(false);
								self:EmitSound(self.SoundUp);
								self:ResetSequence(self.UpSequence);
								self:TriggerUnpressedOutput();
								if SERVER and GP2 and GP2.ButtonLogging then
									GP2.ButtonLogging.LogActivation("BOUTON PILIER", self:GetName(), self:GetPos(), false);
								end;
							end;
						end);
					end;
					self.RetriggerScheduled = false;
				end;
			end);
		end;
	end;
end;
function ENT:Lock()
	self:SetIsLocked(true);
end;
function ENT:Unlock()
	self:SetIsLocked(false);
end;
function ENT:Think()
	if SERVER then
		local playerNearby = false;
		local players = player.GetAll();
		for _, ply in ipairs(players) do
			if IsValid(ply) and ply:Alive() then
				local distance = (self:GetPos()):Distance(ply:GetPos());
				if distance <= self.CheckDistance then
					playerNearby = true;
					break;
				end;
			end;
		end;
		if self:GetIsPressed() and (not playerNearby) and self.PlayerNearby then
			if not self.DelayBeforeReset or self.DelayBeforeReset <= 0 then
				self:Release();
			end;
		end;
		self.PlayerNearby = playerNearby;
		if self:GetIsPressed() then
			if self.NextReleaseTime and self.NextReleaseTime > 0 and CurTime() > self.NextReleaseTime then
				self:CancelPress();
			elseif self.HasTimer and CurTime() > self.NextTickSoundTime then
				self:EmitSound("Portal.room1_TickTock");
				self.NextTickSoundTime = CurTime() + 1;
			end;
		end;
	end;
	self:NextThink(CurTime() + 0.1);
	return true;
end;
