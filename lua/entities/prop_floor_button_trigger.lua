ENT.Type = "brush";
ENT.Base = "base_entity";
ENT.TouchingEnts = {};
ENT.Button = NULL;
ENT.IsPressed = false;
local BUTTON_VALID_ENTS = {
	player = true,
	prop_weighted_cube = true,
	prop_monster_box = true
};
local gp2_debug_buttons, gp2_floor_button_retrigger, gp2_floor_button_retrigger_delay;
if SERVER then
	timer.Simple(0, function()
		gp2_debug_buttons = GetConVar("gp2_debug_buttons");
	end);
	gp2_floor_button_retrigger = CreateConVar("gp2_floor_button_retrigger", "1", FCVAR_ARCHIVE, "Enable forced retrigger for floor buttons when no entity is present");
	gp2_floor_button_retrigger_delay = CreateConVar("gp2_floor_button_retrigger_delay", "0.1", FCVAR_ARCHIVE, "Delay before forced retrigger (seconds)");
end;
local function DebugPrint(msg)
	if SERVER then
		if not gp2_debug_buttons then
			gp2_debug_buttons = GetConVar("gp2_debug_buttons");
		end;
		if gp2_debug_buttons and gp2_debug_buttons:GetBool() then
			print(msg);
		end;
	end;
end;
function ENT:Initialize()
	self:SetSolid(SOLID_BBOX);
	self:SetTrigger(true);
	self.CheckRadius = 25;
	self.LastValidEnts = {};
	self.LastPressedState = false;
	self.HasRetriggered = false;
	self.RetriggerScheduled = false;
end;
function ENT:SetButton(btn)
	self.Button = btn;
	if IsValid(btn) and btn.CheckRadius then
		self.CheckRadius = btn.CheckRadius;
	end;
end;
function ENT:Think()
	if not IsValid(self.Button) then
		return;
	end;
	if SERVER then
		local phys = self:GetPhysicsObject();
		if IsValid(phys) and phys:IsMotionEnabled() and GP2_ApplyPortalBelowImpulse then
			GP2_ApplyPortalBelowImpulse(self, phys);
		end;
	end;
	local nearbyEnts = {};
	local buttonPos = self:GetPos();
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() then
			local distance = buttonPos:Distance(ply:GetPos());
			if distance <= self.CheckRadius then
				table.insert(nearbyEnts, ply);
			end;
		end;
	end;
	for entClass, _ in pairs(BUTTON_VALID_ENTS) do
		if entClass ~= "player" then
			for _, ent in ipairs(ents.FindByClass(entClass)) do
				if IsValid(ent) then
					local distance = buttonPos:Distance(ent:GetPos());
					if distance <= self.CheckRadius then
						table.insert(nearbyEnts, ent);
					end;
				end;
			end;
		end;
	end;
	local originalCount = #self.TouchingEnts;
	for i = #self.TouchingEnts, 1, -1 do
		local ent = self.TouchingEnts[i];
		if not IsValid(ent) then
			table.remove(self.TouchingEnts, i);
		end;
	end;
	if originalCount ~= (#self.TouchingEnts) then
		DebugPrint("[Floor Button] Cleaned invalid entities. Before: " .. originalCount .. ", After: " .. (#self.TouchingEnts));
	end;
	local shouldBePressed = false;
	if #nearbyEnts > 0 then
		shouldBePressed = true;
		DebugPrint("[Floor Button] Entities detected by distance: " .. (#nearbyEnts));
	else
		for _, ent in ipairs(self.TouchingEnts) do
			if IsValid(ent) and BUTTON_VALID_ENTS[ent:GetClass()] then
				shouldBePressed = true;
				DebugPrint("[Floor Button] Entities detected by touch events: " .. (#self.TouchingEnts));
				break;
			end;
		end;
	end;
	if shouldBePressed and (not self.IsPressed) then
		DebugPrint("[Floor Button] Pressing button");
		self.Button:Press();
		self.IsPressed = true;
		self.HasRetriggered = false;
		self.RetriggerScheduled = false;
	elseif not shouldBePressed and self.IsPressed then
		DebugPrint("[Floor Button] Releasing button");
		self.Button:PressOut();
		self.IsPressed = false;
		if SERVER and gp2_floor_button_retrigger and gp2_floor_button_retrigger:GetBool() and (not self.HasRetriggered) and (not self.RetriggerScheduled) then
			if IsValid(self.Button) and self.Button.NoRetrigger then
				DebugPrint("[Floor Button] Retrigger désactivé (NoRetrigger sur le bouton)");
				return;
			end;
			local retriggerDelay = gp2_floor_button_retrigger_delay and gp2_floor_button_retrigger_delay:GetFloat() or 0.1;
			self.RetriggerScheduled = true;
			DebugPrint("[Floor Button] Scheduling ONE forced retrigger after release (delay: " .. retriggerDelay .. "s)");
			timer.Simple(retriggerDelay, function()
				if IsValid(self) and IsValid(self.Button) and (not self.HasRetriggered) then
					local stillEmpty = true;
					local buttonPos = self:GetPos();
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) and ply:Alive() then
							local distance = buttonPos:Distance(ply:GetPos());
							if distance <= self.CheckRadius then
								stillEmpty = false;
								break;
							end;
						end;
					end;
					if stillEmpty then
						for entClass, _ in pairs(BUTTON_VALID_ENTS) do
							if entClass ~= "player" then
								for _, ent in ipairs(ents.FindByClass(entClass)) do
									if IsValid(ent) then
										local distance = buttonPos:Distance(ent:GetPos());
										if distance <= self.CheckRadius then
											stillEmpty = false;
											break;
										end;
									end;
								end;
								if not stillEmpty then
									break;
								end;
							end;
						end;
					end;
					if stillEmpty then
						self.HasRetriggered = true;
						DebugPrint("[Floor Button] Forced retrigger: Press (UNIQUE)");
						self.Button:Press();
						self.IsPressed = true;
						timer.Simple(0.05, function()
							if IsValid(self) and IsValid(self.Button) then
								DebugPrint("[Floor Button] Forced retrigger: Release (UNIQUE)");
								self.Button:PressOut();
								self.IsPressed = false;
							end;
						end);
					else
						DebugPrint("[Floor Button] Retrigger cancelled: entity detected");
					end;
					self.RetriggerScheduled = false;
				end;
			end);
		end;
	end;
	self.LastPressedState = self.IsPressed;
	self:NextThink(CurTime() + 0.05);
	return true;
end;
function ENT:StartTouch(ent)
	if not IsValid(ent) or (not BUTTON_VALID_ENTS[ent:GetClass()]) then
		return;
	end;
	if not IsValid(self.Button) or (not isfunction(self.Button.IsButton)) or (not self.Button:IsButton()) then
		return;
	end;
	for _, touchingEnt in ipairs(self.TouchingEnts) do
		if touchingEnt == ent then
			return;
		end;
	end;
	table.insert(self.TouchingEnts, ent);
	DebugPrint("[Floor Button] StartTouch: " .. ent:GetClass() .. " (" .. tostring(ent) .. ") - Total: " .. (#self.TouchingEnts));
	if ent:GetClass() == "prop_weighted_cube" then
		ent:SetActivated(true);
	elseif ent:GetClass() == "prop_monster_box" then
		ent:BecomeBox();
	end;
end;
function ENT:EndTouch(ent)
	local removed = table.RemoveByValue(self.TouchingEnts, ent);
	DebugPrint("[Floor Button] EndTouch: " .. (IsValid(ent) and ent:GetClass() or "INVALID") .. " (" .. tostring(ent) .. ") - Removed: " .. tostring(removed) .. " - Total: " .. (#self.TouchingEnts));
	if IsValid(ent) then
		if ent:GetClass() == "prop_weighted_cube" then
			ent:SetActivated(false);
		elseif ent:GetClass() == "prop_monster_box" then
			ent:BecomeMonster();
		end;
	end;
end;
