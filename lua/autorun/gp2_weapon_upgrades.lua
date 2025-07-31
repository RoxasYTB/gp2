-- GP2 Weapon Upgrades: Portalgun & PotatOS

if SERVER then
    util.AddNetworkString("GP2_UpgradePortalGun")
    util.AddNetworkString("GP2_UpgradePotatoGun")

    concommand.Add("upgrade_portalgun", function(ply)
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep:GetClass() == "weapon_portalgun" then
                if wep.UpdatePotatoGun then
                    wep:UpdatePotatoGun(false)
                    wep:SetIsPotatoGun(false)
                end
                ply:ChatPrint("Portal Gun standard activé.")
            end
        end
    end)

    concommand.Add("upgrade_potatogun", function(ply)
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep:GetClass() == "weapon_portalgun" then
                if wep.UpdatePotatoGun then
                    wep:UpdatePotatoGun(true)
                    wep:SetIsPotatoGun(true)
                end
                ply:ChatPrint("Portal Gun avec PotatOS activé !")
            end
        end
    end)
end

if CLIENT then
    -- Optionnel : feedback visuel/sonore
end
