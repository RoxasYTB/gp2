ENT.Type = "anim";
ENT.Base = "base_entity";
if SERVER then
	hook.Add("InitPostEntity", "GP2_DisableFuncBrushCollision_sp_a1_intro6", function()
		if game.GetMap() ~= "sp_a1_intro6" then
			return;
		end;
		for _, ent in ipairs(ents.FindByClass("func_brush")) do
			if ent:EntIndex() == 72 then
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
			end;
		end;
	end);
end;
if SERVER then
	concommand.Add("gp2_portalgun_entityinuse", function(ply)
		local holding = false;
		if IsValid(ply) and ply:IsHolding() then
			holding = true;
		end;
		if holding then
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Le joueur tient un objet avec la fonction isHoldingSomething.");
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, "[GP2] Aucun objet tenu avec la fonction isHoldingSomething.");
		end;
	end);
end;
timer.Create("GP2_RemovePlateEntities", 0.5, 0, function()
	for _, ent in ipairs(ents.FindByClass("prop_physics")) do
		if ent:GetModel() == "models/hunter/plates/plate1x1.mdl" and (ent:GetColor()).a == 255 then
			ent:Remove();
		end;
	end;
end);
hook.Add("OnEntityCreated", "GP2_AdjustPortalOnce", function(ent)
	if ent:GetClass() == "prop_portal" then
		timer.Simple(0.1, function()
			if not IsValid(ent) then
				return;
			end;
			local ang = ent:GetAngles();
			if ang.p > (-70) and ang.p < (-50) then
				local up = ang:Up();
				ent:SetPos(ent:GetPos() + up * 10);
			end;
		end);
	end;
end);
if game.GetMap() == "sp_a2_laser_intro" then
	hook.Add("OnEntityCreated", "GP2_AdjustPortalOnce", function(ent)
		if ent:GetClass() == "prop_portal" then
			timer.Simple(0.1, function()
				if not IsValid(ent) then
					return;
				end;
				local ang = ent:GetAngles();
				local up = ang:Up();
				ent:SetPos(ent:GetPos() + up * 2);
				ent:SetAngles(Angle(ang.p + 2, ang.y, ang.r));
			end);
		end;
	end);
end;
if game.GetMap() == "sp_a1_intro2" then
	hook.Add("Think", "GP2_AdjustPortalAlways", function()
		for _, ent in ipairs(ents.FindByClass("prop_portal")) do
			for _, ent in ipairs(ents.FindByClass("prop_weighted_cube")) do
			if ent:EntIndex() == 43 and ent:GetModel() == "models/props/metal_box.mdl" then
				local pos = ent:GetPos()
				if math.abs(pos.x - (-60)) < 1 and math.abs(pos.y - 128) < 1 and math.abs(pos.z - (-8)) < 1 then

				local pos = ent:GetPos()
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(Vector(0, 0, -50))
				end
				end
			end
		end
			local portalType = ent.GetType and ent:GetType() or ent.PortalType or nil;
			local triggered = GetConVar("gp2_last_portal_triggered") and GetConVar("gp2_last_portal_triggered"):GetString() or ""
			if triggered == "emitter_blue_1" and portalType == 0 then
				print("Adjusting portal_blue_1 position and angle");
				ent:SetPos(Vector(-684.900024, 96.000000, 4.000003))
				ent:SetAngles(Angle(-90, 180, 0))
			elseif triggered == "emitter_blue_2" and portalType == 0 then
				print("Adjusting portal_blue_2 position and angle");
				ent:SetPos(Vector(-430.899994, 512.000000, -4.139997))
				ent:SetAngles(Angle(-90, 180, 0))
			elseif triggered == "emitter_blue_3" and portalType == 0 then
				print("Adjusting portal_blue_3 position and angle");
				ent:SetPos(Vector(-31.999996, 397.899994, -3.999997))
				ent:SetAngles(Angle(-90, 90, 0))
			end
		end

	end)
end
if SERVER then
	hook.Add("Think", "GP2_CheckFuncBrushPitch_sp_a1_intro5", function()
		if game.GetMap() ~= "sp_a1_intro5" then
			return;
		end;
		for _, ent in ipairs(ents.FindByClass("func_brush")) do
			if ent:EntIndex() >= 429 and ent:EntIndex() <= 433 then
				local pitch = (ent:GetAngles()).p;
				if pitch > (-2) then
					ent:SetSolid(SOLID_NONE);
				else
					ent:SetSolid(SOLID_VPHYSICS);
				end;
			end;
		end;
	end);
end;
if SERVER then
	CreateConVar("shouldHold", "0", FCVAR_ARCHIVE, "Force pickup on sp_a1_wakeup");
	if game.GetMap() == "sp_a1_wakeup" or game.GetMap() == "sp_a1_intro7" then
		if game.GetMap() == "sp_a1_wakeup" then
			(GetConVar("shouldHold")):SetBool(true);
		end;
		timer.Create("GP2_WaitForPlayerAndForcePickup", 0.1, 0, function()
			if (GetConVar("shouldHold")):GetBool() then
				local ply = (player.GetAll())[1];
				if not IsValid(ply) then
					return;
				end;
				local function IsHoldingSomething(ply)
					if not IsValid(ply) then
						return false;
					end;
					local wep = ply:GetActiveWeapon();
					if not IsValid(wep) or wep:GetClass() ~= "weapon_portalgun" then
						return false;
					end;
					local ent = wep.GetEntityInUse and wep:GetEntityInUse() or nil;
					return IsValid(ent);
				end;
				local triggered = not IsHoldingSomething(ply);
				if triggered then
					for _, ent in ipairs(ents.FindByClass("npc_personality_core")) do
						if IsValid(ent) then
							ent:SetSolid(SOLID_BBOX);
							ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
							ply:PickupObject(ent);
							CreateSound(ent, "PortalPlayer.ObjectUse", filter);
							ent:EmitSound("PortalPlayer.ObjectUse", 0);
							ent.GP2ForcePickup = true;
						end;
					end;
				end;
			end;
		end);
	else
		(GetConVar("shouldHold")):SetBool(false);
	end;
	hook.Add("AllowPlayerPickup", "GP2_BlockDropCore_sp_a1_wakeup", function(ply, ent)
		if game.GetMap() == "sp_a1_wakeup" and ent.GP2ForcePickup then
			return true;
		end;
	end);
	hook.Add("PlayerDropObject", "GP2_BlockDropCore_sp_a1_wakeup", function(ply, ent)
		if game.GetMap() == "sp_a1_wakeup" and ent.GP2ForcePickup then
			return false;
		end;
	end);
end;
if SERVER then
	local function FixPortalPosition()
		if game.GetMap() ~= "sp_a1_intro7" then
			return;
		end;
		for _, ent in ipairs(ents.FindByClass("prop_portal")) do
			local portalType = ent.GetType and ent:GetType() or ent.PortalType or nil;
			if portalType == 1 then
				local pos = ent:GetPos();
				local ang = ent:GetAngles();
				local posStr = string.format("%.6f %.6f %.6f", pos.x, pos.y, pos.z);
				local angStr = string.format("%.3f %.3f %.3f", ang.p, ang.y, ang.r);
				if posStr == "-478.159180 -231.220947 1258.355347" and angStr == "-14.533 -158.825 -6.802" then
					ent:SetAngles(Angle(-14.436, -151.951, -1.724));
					local getRight = ent:GetRight();
					ent:SetPos(ent:GetPos() + getRight * 3.5);
				end;
			end;
		end;
	end;
	timer.Create("GP2_FixPortalPosition", 0.2, 0, FixPortalPosition);
end;
if SERVER then
	if game.GetMap() == "sp_a2_intro" then
		timer.Create("GP2_UpgradePortalgunForAllPlayers", 0.5, 0, function()
			for _, ply in ipairs(player.GetAll()) do
				ply:ConCommand("gp2_portalgun_upgraded 1");
			end;
		end);
	end;
	if game.GetMap() == "sp_a1_intro3" then
		timer.Create("GP2_UpgradePortalgunForAllPlayers", 0.5, 0, function()
			for _, ply in ipairs(player.GetAll()) do
				ply:ConCommand("gp2_portalgun_upgraded 0");
			end;
		end);
	end;
end;
if SERVER then
	if game.GetMap() == "sp_a2_bts1" then
		timer.Create("GP2_MoveCube_sp_a2_bts1", 3, 0, function()
			for _, ent in ipairs(ents.FindByClass("prop_weighted_cube")) do
				local pos = ent:GetPos();
				if pos.x == (-9728) and pos.y == (-1888) and pos.z == 1168 then
					ent:SetPos(Vector(pos.x, pos.y, pos.z - 400));
				end;
			end;
		end);
	end;
end;
if notification then
	notification.AddLegacy = function(msg, type, len)
		return;
	end;
end;
// RunConsoleCommand("gmod_admin_cleanup");
if SERVER then
	if game.GetMap() == "sp_a2_bts4" then
		game.ConsoleCommand("sv_gravity 500\n");
	end;
end;



concommand.Add("glados_claw_pickup", function()
	game.ConsoleCommand('ent_fire @glados RunScriptCode "sp_a1_wakeup_WheatleyGettingGrabbed()" 1.2\n')
	game.ConsoleCommand('ent_fire glados_cables_hip_03 DisableDraw "" 1.2\n')
	game.ConsoleCommand('ent_fire claw_clang_sound PlaySound "" 2.2\n')
	game.ConsoleCommand('ent_fire camera_1 Enable "" 2.2\n')
	game.ConsoleCommand('ent_fire camera_1 Disable "" 3.4\n')
	game.ConsoleCommand('ent_fire camera_ghostAnim_2 Enable "" 3.4\n')
	game.ConsoleCommand('ent_fire @sphere SetParent ghostAnim 3.4\n')
	game.ConsoleCommand('ent_fire @sphere SetParentAttachment attach_2 3.5\n')
	game.ConsoleCommand('ent_fire gun_shooter Shoot "" 6\n')
	game.ConsoleCommand('ent_fire relay_incinerator_open Trigger "" 30.6\n')
	game.ConsoleCommand('ent_fire achievement_wakeup_glados FireEvent "" 37.45\n')
end)