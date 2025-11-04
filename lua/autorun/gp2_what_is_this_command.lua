if CLIENT then
	local function GetEntityInfo(ent)
		if not IsValid(ent) then
			return "Aucune entité valide";
		end;
		local info = {};
		print("========== INFORMATIONS DÉTAILLÉES DE L'ENTITÉ ==========");
		print("Classe: " .. ent:GetClass());
		print("Index: " .. ent:EntIndex());
		if ent.GetName then
			local name = ent:GetName();
			if name and name ~= "" then
				print("Nom: " .. name);
			end;
		end;
		if ent.GetModel then
			local mdl = ent:GetModel();
			if mdl and mdl ~= "" then
				print("Modèle: " .. mdl);
			end;
		end;
		if ent.GetPos then
			local pos = ent:GetPos();
			if pos then
				print(string.format("Position: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z));
			end;
		end;
		if ent.GetAngles then
			local ang = ent:GetAngles();
			if ang then
				print(string.format("Angles: Pitch=%.2f, Yaw=%.2f, Roll=%.2f", ang.p, ang.y, ang.r));
			end;
		end;
		local ply = LocalPlayer();
		if IsValid(ply) and ent.GetPos then
			local pos = ent:GetPos();
			if pos then
				local dist = (ply:GetPos()):Distance(pos);
				print(string.format("Distance du joueur: %.2f unités", dist));
			end;
		end;
		if ent.IsPlayer and ent:IsPlayer() then
			if ent.Name then
				print("Type: Joueur (" .. ent:Name() .. ")");
			else
				print("Type: Joueur");
			end;
		elseif ent.IsNPC and ent:IsNPC() then
			print("Type: NPC");
		elseif ent.IsVehicle and ent:IsVehicle() then
			print("Type: Véhicule");
		elseif ent.IsWeapon and ent:IsWeapon() then
			print("Type: Arme");
		elseif ent.GetClass and (ent:GetClass()):find("prop_") then
			print("Type: Prop");
		end;
		if ent.GetOwner then
			local owner = ent:GetOwner();
			if IsValid(owner) then
				if owner.GetClass then
					print("Owner: " .. owner:GetClass() .. " [" .. owner:EntIndex() .. "]");
				end;
				if owner.IsPlayer and owner:IsPlayer() and owner.Nick then
					print("Owner (joueur): " .. owner:Nick());
				end;
			else
				print("Owner: Aucun");
			end;
		end;
		if ent.GetParent then
			local parent = ent:GetParent();
			if IsValid(parent) and parent.GetClass then
				print("Parent: " .. parent:GetClass() .. " [" .. parent:EntIndex() .. "]");
			else
				print("Parent: Aucun");
			end;
		end;
		if ent.GetPhysicsObject then
			local phys = ent:GetPhysicsObject();
			if IsValid(phys) then
				print("=== PROPRIÉTÉS PHYSIQUES ===");
				if phys.GetMass then
					print("Masse: " .. phys:GetMass() .. " kg");
				end;
				if phys.GetVelocity then
					local vel = phys:GetVelocity();
					if vel then
						print(string.format("Vélocité: %.2f, %.2f, %.2f (Magnitude: %.2f)", vel.x, vel.y, vel.z, vel:Length()));
					end;
				end;
				if phys.IsMotionEnabled then
					print("Motion Enabled: " .. tostring(phys:IsMotionEnabled()));
				end;
				if phys.IsGravityEnabled then
					print("Gravity Enabled: " .. tostring(phys:IsGravityEnabled()));
				end;
				if phys.IsCollisionEnabled then
					print("Collisions Enabled: " .. tostring(phys:IsCollisionEnabled()));
				end;
				if phys.IsAsleep then
					print("Asleep: " .. tostring(phys:IsAsleep()));
				end;
			else
				print("Objet physique: Aucun");
			end;
		end;
		if ent.GetCollisionGroup then
			print("Collision Group: " .. ent:GetCollisionGroup());
		end;
		if ent.GetSolid then
			print("Solid Type: " .. ent:GetSolid());
		end;
		if ent.GetMoveType then
			print("Move Type: " .. ent:GetMoveType());
		end;
		if ent.GetMaterial then
			local mat = ent:GetMaterial();
			if mat and mat ~= "" then
				print("Material Override: " .. mat);
			end;
		end;
		if ent.GetColor then
			local col = ent:GetColor();
			if col then
				print(string.format("Couleur: R=%d, G=%d, B=%d, A=%d", col.r, col.g, col.b, col.a));
			end;
		end;
		if ent.GetSkin then
			local skin = ent:GetSkin();
			if skin and skin > 0 then
				print("Skin: " .. skin);
			end;
		end;
		if ent.GetRenderMode then
			print("Render Mode: " .. ent:GetRenderMode());
		end;
		if ent.GetNoDraw then
			print("NoDraw: " .. tostring(ent:GetNoDraw()));
		end;
		if ent.InPortal ~= nil then
			print("InPortal: " .. tostring(ent.InPortal));
		end;
		if ent.isClone then
			print("isClone: true");
			if ent.daddyEnt and IsValid(ent.daddyEnt) and ent.daddyEnt.GetClass then
				print("daddyEnt: " .. ent.daddyEnt:GetClass() .. " [" .. ent.daddyEnt:EntIndex() .. "]");
			end;
		end;
		if ent.clone and IsValid(ent.clone) and ent.clone.GetClass then
			print("clone: " .. ent.clone:GetClass() .. " [" .. ent.clone:EntIndex() .. "]");
		end;
		if ent.GP2_PortalImmunity ~= nil then
			print("GP2_PortalImmunity: " .. tostring(ent.GP2_PortalImmunity));
		end;
		if ent.OriginalCollisionGroup ~= nil then
			print("OriginalCollisionGroup: " .. tostring(ent.OriginalCollisionGroup));
		end;
		local pos = ent:GetPos();
		print(string.format("Position: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z));
		local ang = ent:GetAngles();
		print(string.format("Angles: Pitch=%.2f, Yaw=%.2f, Roll=%.2f", ang.p, ang.y, ang.r));
		local ply = LocalPlayer();
		if IsValid(ply) then
			local dist = (ply:GetPos()):Distance(pos);
			print(string.format("Distance du joueur: %.2f unités", dist));
		end;
		if ent:IsPlayer() then
			print("Type: Joueur (" .. ent:Name() .. ")");
		elseif ent:IsNPC() then
			print("Type: NPC");
		elseif ent:IsVehicle() then
			print("Type: Véhicule");
		elseif ent:IsWeapon() then
			print("Type: Arme");
		elseif (ent:GetClass()):find("prop_") then
			print("Type: Prop");
		end;
		local owner = ent:GetOwner();
		if IsValid(owner) then
			print("Owner: " .. owner:GetClass() .. " [" .. owner:EntIndex() .. "]");
			if owner:IsPlayer() then
				print("Owner (joueur): " .. owner:Nick());
			end;
		else
			print("Owner: Aucun");
		end;
		local parent = ent:GetParent();
		if IsValid(parent) then
			print("Parent: " .. parent:GetClass() .. " [" .. parent:EntIndex() .. "]");
		else
			print("Parent: Aucun");
		end;
		local phys = ent:GetPhysicsObject();
		if IsValid(phys) then
			print("=== PROPRIÉTÉS PHYSIQUES ===");
			print("Masse: " .. phys:GetMass() .. " kg");
			local vel = phys:GetVelocity();
			print(string.format("Vélocité: %.2f, %.2f, %.2f (Magnitude: %.2f)", vel.x, vel.y, vel.z, vel:Length()));
			print("Motion Enabled: " .. tostring(phys:IsMotionEnabled()));
			print("Gravity Enabled: " .. tostring(phys:IsGravityEnabled()));
			print("Collisions Enabled: " .. tostring(phys:IsCollisionEnabled()));
			print("Asleep: " .. tostring(phys:IsAsleep()));
		else
			print("Objet physique: Aucun");
		end;
		print("Collision Group: " .. ent:GetCollisionGroup());
		print("Solid Type: " .. ent:GetSolid());
		print("Move Type: " .. ent:GetMoveType());
		local mat = ent:GetMaterial();
		if mat and mat ~= "" then
			print("Material Override: " .. mat);
		end;
		local col = ent:GetColor();
		print(string.format("Couleur: R=%d, G=%d, B=%d, A=%d", col.r, col.g, col.b, col.a));
		local skin = ent:GetSkin();
		if skin and skin > 0 then
			print("Skin: " .. skin);
		end;
		print("Render Mode: " .. ent:GetRenderMode());
		print("NoDraw: " .. tostring(ent:GetNoDraw()));
		if ent.InPortal then
			print("InPortal: " .. tostring(ent.InPortal));
		end;
		if ent.isClone then
			print("isClone: true");
			if IsValid(ent.daddyEnt) then
				print("daddyEnt: " .. ent.daddyEnt:GetClass() .. " [" .. ent.daddyEnt:EntIndex() .. "]");
			end;
		end;
		if ent.clone and IsValid(ent.clone) then
			print("clone: " .. ent.clone:GetClass() .. " [" .. ent.clone:EntIndex() .. "]");
		end;
		if ent.GP2_PortalImmunity then
			print("GP2_PortalImmunity: " .. ent.GP2_PortalImmunity);
		end;
		if ent.OriginalCollisionGroup then
			print("OriginalCollisionGroup: " .. ent.OriginalCollisionGroup);
		end;
		print("=========================================================");
		table.insert(info, "Classe: " .. ent:GetClass());
		table.insert(info, "Index: " .. ent:EntIndex());
		if ent.GetModel and ent:GetModel() and ent:GetModel() ~= "" then
			table.insert(info, "Modèle: " .. ent:GetModel());
		end;
		table.insert(info, string.format("Position: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z));
		table.insert(info, string.format("Angles: Pitch=%.2f, Yaw=%.2f, Roll=%.2f", ang.p, ang.y, ang.r));
		if IsValid(phys) then
			table.insert(info, "Masse: " .. phys:GetMass() .. "kg");
			local vel = phys:GetVelocity();
			table.insert(info, string.format("Vélocité: %.2f, %.2f, %.2f (%.2f)", vel.x, vel.y, vel.z, vel:Length()));
			table.insert(info, "Motion: " .. tostring(phys:IsMotionEnabled()));
			table.insert(info, "Gravity: " .. tostring(phys:IsGravityEnabled()));
			table.insert(info, "Collisions: " .. tostring(phys:IsCollisionEnabled()));
			table.insert(info, "Asleep: " .. tostring(phys:IsAsleep()));
		end;
		table.insert(info, "CollisionGroup: " .. ent:GetCollisionGroup());
		table.insert(info, "SolidType: " .. ent:GetSolid());
		table.insert(info, "MoveType: " .. ent:GetMoveType());
		if mat and mat ~= "" then
			table.insert(info, "Material: " .. mat);
		end;
		table.insert(info, string.format("Couleur: R=%d, G=%d, B=%d, A=%d", col.r, col.g, col.b, col.a));
		if skin and skin > 0 then
			table.insert(info, "Skin: " .. skin);
		end;
		table.insert(info, "RenderMode: " .. ent:GetRenderMode());
		table.insert(info, "NoDraw: " .. tostring(ent:GetNoDraw()));
		if IsValid(owner) then
			table.insert(info, "Owner: " .. owner:GetClass() .. " [" .. owner:EntIndex() .. "]");
			if owner:IsPlayer() then
				table.insert(info, "OwnerNick: " .. owner:Nick());
			end;
		end;
		if IsValid(parent) then
			table.insert(info, "Parent: " .. parent:GetClass() .. " [" .. parent:EntIndex() .. "]");
		end;
		if ent.InPortal then
			table.insert(info, "InPortal: " .. tostring(ent.InPortal));
		end;
		if ent.isClone then
			table.insert(info, "isClone: true");
			if IsValid(ent.daddyEnt) then
				table.insert(info, "daddyEnt: " .. ent.daddyEnt:GetClass() .. " [" .. ent.daddyEnt:EntIndex() .. "]");
			end;
		end;
		if ent.clone and IsValid(ent.clone) then
			table.insert(info, "clone: " .. ent.clone:GetClass() .. " [" .. ent.clone:EntIndex() .. "]");
		end;
		if ent.GP2_PortalImmunity then
			table.insert(info, "GP2_PortalImmunity: " .. ent.GP2_PortalImmunity);
		end;
		if ent.OriginalCollisionGroup then
			table.insert(info, "OriginalCollisionGroup: " .. ent.OriginalCollisionGroup);
		end;
		return table.concat(info, " | ");
	end;
	concommand.Add("gp2_what_is_this", function(ply, cmd, args)
		local ply = LocalPlayer();
		if not IsValid(ply) then
			return;
		end;
		local tr = ply:GetEyeTrace();
		if IsValid(tr.Entity) then
			local info = GetEntityInfo(tr.Entity);
			print("[GP2] Entité pointée:");
			for str in string.gmatch(info, "[^|]+") do
				print(str:Trim());
			end;
		else
			print("[GP2] Aucune entité pointée ou entité trop éloignée");
		end;
	end, nil, "Affiche les informations de l'entité que vous pointez du regard");
	concommand.Add("gp2_whatisthis", function(ply, cmd, args)
		RunConsoleCommand("gp2_what_is_this");
	end, nil, "Raccourci pour gp2_what_is_this");
	concommand.Add("whatisthis", function(ply, cmd, args)
		RunConsoleCommand("gp2_what_is_this");
	end, nil, "Raccourci pour gp2_what_is_this");
end;
