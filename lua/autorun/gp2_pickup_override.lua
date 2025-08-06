-- GP2: Autorise le pickup universel avec le Portal Gun
-- Place ce fichier dans lua/autorun/

if SERVER then
    hook.Add("AllowPlayerPickup", "GP2_AllowAllPickupWithPortalgun", function(ply, ent)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_portalgun" then
            return true -- Autorise le pickup de tout objet
        end
    end)

    hook.Add("PhysgunPickup", "GP2_AllowAllPhysgunPickupWithPortalgun", function(ply, ent)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_portalgun" then
            return true -- Autorise le pickup avec le physgun aussi
        end
    end)
end
