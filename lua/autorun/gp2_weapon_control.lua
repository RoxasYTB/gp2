-- ----------------------------------------------------------------------------
-- GP2 Framework - Contrôle des armes et suppression des bulles d'aide
-- Ce fichier permet de gérer quelles armes sont données et cache les bulles d'aide
-- ----------------------------------------------------------------------------

if SERVER then
    -- ConVars pour contrôler les armes
    CreateConVar("gp2_auto_give_portalgun", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Donne automatiquement le Portal Gun au spawn (0 = non, 1 = oui)")

    -- On conserve la convar pour compatibilité, mais elle ne fait plus rien
    CreateConVar("gp2_remove_default_weapons", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Retire les armes par défaut de Garry's Mod (0 = non, 1 = oui) [DÉSACTIVÉ]")

    CreateConVar("gp2_portal_gun_only", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY,
        "Mode Portal Gun uniquement - retire toutes les autres armes (0 = non, 1 = oui)")

    local GP2_StoredDefaultWeapons = GP2_StoredDefaultWeapons or {}
    local GP2_StoredWeapons = GP2_StoredWeapons or {}

    -- Suppression du hook qui retirait les armes par défaut
    --[[]
    -- HOOK SUPPRIMÉ : ne retire plus les armes par défaut
    --]]

    -- Hook pour maintenir le mode "Portal Gun Only"
    hook.Add("PlayerCanPickupWeapon", "GP2::PortalGunOnly", function(ply, weapon)
        if GetConVar("gp2_portal_gun_only"):GetBool() then
            local allowedWeapons = {
                ["weapon_portalgun"] = true,
                ["weapon_paintgun"] = true
            }
            if not allowedWeapons[weapon:GetClass()] then
                return false
            end
        end
    end)

    -- Hook pour nettoyer les armes non autorisées
    -- SUPPRIMÉ : ne retire plus aucune arme au spawn
    --[[]
    hook.Add("PlayerSpawn", "GP2::CleanupUnwantedWeapons", function(ply, transition)
        if GetConVar("gp2_portal_gun_only"):GetBool() then
            local allowedWeapons = {
                ["weapon_portalgun"] = true,
                ["weapon_paintgun"] = true
            }
            for _, weapon in ipairs(ply:GetWeapons()) do
                if not allowedWeapons[weapon:GetClass()] then
                    ply:StripWeapon(weapon:GetClass())
                end
            end
        end
    end)
    --]]

    -- Commandes console pour contrôler le système
    concommand.Add("gp2_give_portalgun_all", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                player:Give("weapon_portalgun")
                for _, weapon in ipairs(player:GetWeapons()) do
                    if weapon:GetClass() == "weapon_portalgun" then
                        weapon:UpdatePortalGun()
                    end
                end
            end
        end
        GP2.Print("Portal Gun donné à tous les joueurs par %s", ply:Nick())
    end, nil, "Donne le Portal Gun à tous les joueurs (Admin uniquement)")

    -- Commandes pour désactiver/activer le mode Portal Gun Only
    concommand.Add("gp2_portal_only_on", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        GetConVar("gp2_portal_gun_only"):SetBool(true)
        GetConVar("gp2_auto_give_portalgun"):SetBool(true)
        -- On ne retire plus les armes ici !
        GP2.Print("Mode Portal Gun uniquement activé par %s", ply:Nick())
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                GP2_StoredWeapons[player:SteamID()] = {}
                for _, weapon in ipairs(player:GetWeapons()) do
                    table.insert(GP2_StoredWeapons[player:SteamID()], weapon:GetClass())
                end
                -- Suppression du StripWeapons ici
                player:Give("weapon_portalgun")
                for _, weapon in ipairs(player:GetWeapons()) do
                    if weapon:GetClass() == "weapon_portalgun" then
                        weapon:UpdatePortalGun()
                    end
                end
            end
        end
    end, nil, "Active le mode Portal Gun uniquement (Admin uniquement)")

    concommand.Add("gp2_portal_only_off", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            return
        end
        GetConVar("gp2_portal_gun_only"):SetBool(false)
        GP2.Print("Mode Portal Gun uniquement désactivé par %s", ply:Nick())
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                -- Suppression du StripWeapons ici
                local stored = GP2_StoredWeapons[player:SteamID()]
                if stored then
                    for _, wep in ipairs(stored) do
                        player:Give(wep)
                    end
                end
            end
        end
    end, nil, "Désactive le mode Portal Gun uniquement (Admin uniquement)")

    -- Système de drop d'arme
    concommand.Add("gp2_drop_weapon", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local activeWeapon = ply:GetActiveWeapon()
        if not IsValid(activeWeapon) then
            return
        end

        local weaponClass = activeWeapon:GetClass()

        -- Vérifier si l'arme peut être jetée (ne pas permettre de jeter certaines armes essentielles)
        local nonDroppableWeapons = {
            ["weapon_hands"] = true,
            ["weapon_physcannon"] = true
        }

        if nonDroppableWeapons[weaponClass] then
            return
        end

        -- Si en mode Portal Gun Only, empêcher de jeter le Portal Gun
        if GetConVar("gp2_portal_gun_only"):GetBool() and weaponClass == "weapon_portalgun" then
            return
        end

        -- Table de correspondance pour les worldmodels des armes HL2 natives
        local hl2WorldModels = {
            weapon_357 = "models/weapons/w_357.mdl",
            weapon_pistol = "models/weapons/w_pistol.mdl",
            weapon_smg1 = "models/weapons/w_smg1.mdl",
            weapon_ar2 = "models/weapons/w_irifle.mdl",
            weapon_shotgun = "models/weapons/w_shotgun.mdl",
            weapon_crossbow = "models/weapons/w_crossbow.mdl",
            weapon_frag = "models/weapons/w_grenade.mdl",
            weapon_crowbar = "models/weapons/w_crowbar.mdl",
            weapon_stunstick = "models/weapons/w_stunbaton.mdl",
            weapon_rpg = "models/weapons/w_rocket_launcher.mdl",
            weapon_slam = "models/weapons/w_slam.mdl",
            weapon_bugbait = "models/weapons/w_bugbait.mdl",
            weapon_physgun = "models/weapons/w_Physics.mdl",
            weapon_tool = "models/weapons/w_toolgun.mdl",
            weapon_camera = "models/MaxOfS2D/camera.mdl"
        }

        -- Récupérer le worldmodel de l'arme (HL2, SWEP, weapons.Get, fallback)
        local worldModel = hl2WorldModels[weaponClass]
        if not worldModel then
            worldModel = activeWeapon.WorldModel
            if (not worldModel or worldModel == "") and weapons.Get then
                local wepData = weapons.Get(weaponClass)
                if wepData and wepData.WorldModel and wepData.WorldModel ~= "" then
                    worldModel = wepData.WorldModel
                end
            end
        end
        if not worldModel or worldModel == "" then
            -- fallback : modèle du toolgun si rien trouvé
            worldModel = "models/weapons/w_toolgun.mdl"
        end

        -- Correction Portal Gun : utiliser le modèle ramassable pour le prop_physics
        if weaponClass == "weapon_portalgun" then
            worldModel = "models/weapons/portalgun/w_portalgun.mdl"
        end

        -- Calculer la position et direction de drop
        local eyePos = ply:EyePos()
        local eyeAngles = ply:EyeAngles()
        local forward = eyeAngles:Forward()
        local right = eyeAngles:Right()


        -- Position devant le joueur pour éviter le pickup instantané
        local dropPos = eyePos
        dropPos.z = dropPos.z - 10 -- Légèrement au-dessus pour éviter le sol

        -- Drop d'arme vanilla si possible
        if hl2WorldModels[weaponClass] and scripted_ents.GetStored(weaponClass) == nil then
            -- Créer un prop_physics pour l'effet visuel
            local prop = ents.Create("prop_physics")
            if not IsValid(prop) then return end
            prop:SetModel(worldModel)
            prop:SetPos(dropPos)
            prop:SetAngles(Angle(0, eyeAngles.y, 0))
            prop:Spawn()
            prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            local up = eyeAngles:Up()
            local velocity = forward * 180 + right * 1 - up * -140
            local phys = prop:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(velocity)
                phys:AddAngleVelocity(Vector(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200)))
            end
            -- Sauvegarder les munitions AVANT de strip l'arme
            local clip1 = activeWeapon:Clip1() or -1
            local clip2 = activeWeapon:Clip2() or -1
            ply:StripWeapon(weaponClass)
            ply:EmitSound("physics/body/body_medium_impact_soft_" .. math.random(1, 7) .. ".wav", 70)
            -- Après 3 secondes, supprimer le prop et créer l'arme ramassable
            timer.Simple(1, function()
                if not IsValid(prop) then return end
                local dropped = ents.Create(weaponClass)
                if not IsValid(dropped) then prop:Remove() return end
                dropped:SetPos(prop:GetPos())
                dropped:SetAngles(prop:GetAngles())
                dropped:Spawn()
                dropped:SetClip1(clip1)
                dropped:SetClip2(clip2)
                dropped:SetNWFloat("GP2PickupTime", CurTime() + 2)
                prop:Remove()
            end)
            return
        end
        -- Sinon, fallback prop_physics (SWEP custom)
        local dropped = ents.Create("prop_physics")
        if not IsValid(dropped) then return end
        dropped:SetModel(worldModel)
        dropped:SetPos(dropPos)
        dropped:SetAngles(Angle(0, eyeAngles.y, 0))
        dropped:Spawn()
        dropped:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        local phys = dropped:GetPhysicsObject()
        if IsValid(phys) then
            local velocity = forward * 250 + Vector(0, 0, 80)
            phys:SetVelocity(velocity)
            phys:AddAngleVelocity(Vector(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200)))
        end
        ply:StripWeapon(weaponClass)
        ply:EmitSound("physics/body/body_medium_impact_soft_" .. math.random(1, 7) .. ".wav", 70)
        dropped.weaponclass = weaponClass
        dropped:SetUseType(SIMPLE_USE)
        function dropped:Think()
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() and ply:GetPos():DistToSqr(self:GetPos()) < 10000 then
                    if not ply:HasWeapon(self.weaponclass) then
                        ply:Give(self.weaponclass)
                        self:Remove()
                        return
                    end
                end
            end
            self:NextThink(CurTime() + 0.1)
            return true
        end
        dropped:NextThink(CurTime() + 0.1)
    end, nil, "Jette l'arme actuelle au sol avec modèle et vélocité réaliste")


end

if CLIENT then
    -- ConVar pour la touche de drop d'arme
    CreateClientConVar("gp2_weapon_drop_key", "G", true, false, "Touche pour jeter l'arme actuelle")

    -- Supprimer les notifications d'aide pour les armes
    local function SuppressWeaponHelpNotifications()
        -- Hook pour supprimer les notifications d'aide
        hook.Add("HUDShouldDraw", "GP2::SuppressWeaponHelp", function(name)
            -- Supprimer les éléments d'aide des armes (SANS CHudWeaponSelection pour garder le scroll d'armes)
            local suppressedElements = {
                -- ["CHudWeaponSelection"] = true, -- RETIRÉ : empêchait le scroll entre armes
                ["CHudHintDisplay"] = true,
            }

            if suppressedElements[name] then
                return false
            end
        end)    -- Hook pour gérer les inputs des touches
    local weaponDropKeyPressed = false
    hook.Add("Think", "GP2::WeaponDropKeyHandler", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        -- Ne rien faire si le joueur écrit dans le tchat ou une UI
        if gui.IsGameUIVisible and gui.IsGameUIVisible() then return end
        if ply.IsTyping and ply:IsTyping() then return end

        local dropKey = GetConVar("gp2_weapon_drop_key"):GetString():upper()
        local keyCode = _G["KEY_" .. dropKey]

        if keyCode and input.IsKeyDown(keyCode) then
            if not weaponDropKeyPressed then
                weaponDropKeyPressed = true
                -- Envoyer la commande au serveur
                RunConsoleCommand("gp2_drop_weapon")
            end
        else
            weaponDropKeyPressed = false
        end
    end)

        -- Hook plus spécifique pour les messages d'aide des armes
        local hintsDisabled = false
        hook.Add("Think", "GP2::SuppressWeaponHelpBubbles", function()
            local ply = LocalPlayer()
            if not IsValid(ply) or hintsDisabled then return end

            -- Désactiver les bulles d'aide de Garry's Mod une seule fois
            if ply:GetInfoNum("gmod_showhints", 1) == 1 then
                -- Utiliser pcall pour éviter les erreurs si la commande n'existe pas
                local success = pcall(function()
                    RunConsoleCommand("gmod_showhints", "0")
                end)
                hintsDisabled = true -- Marquer comme fait dans tous les cas
            end
        end)
    end

    -- Attendre que le jeu soit chargé
    hook.Add("InitPostEntity", "GP2::InitWeaponControl", function()
        timer.Simple(1, SuppressWeaponHelpNotifications)
    end)    -- Commande pour changer la touche de drop
    concommand.Add("gp2_set_drop_key", function(ply, cmd, args)
        if args[1] and string.len(args[1]) == 1 then
            local key = args[1]:upper()
            GetConVar("gp2_weapon_drop_key"):SetString(key)
            chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Touche de drop d'arme changée pour : ", Color(255, 255, 100), key)
        else
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Usage: gp2_set_drop_key <touche> (exemple: gp2_set_drop_key G)")
        end
    end, nil, "Change la touche pour jeter l'arme actuelle")

    -- Commande pour désactiver manuellement les bulles d'aide
    concommand.Add("gp2_hide_weapon_help", function()
        local success = pcall(function()
            RunConsoleCommand("gmod_showhints", "0")
        end)

        if success then
            chat.AddText(Color(100, 255, 100), "[GP2] ", Color(255, 255, 255), "Bulles d'aide des armes désactivées!")
        else
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Commande gmod_showhints non disponible")
        end
    end, nil, "Désactive les bulles d'aide des armes")

    -- Commande pour réactiver les bulles d'aide
    concommand.Add("gp2_show_weapon_help", function()
        local success = pcall(function()
            RunConsoleCommand("gmod_showhints", "1")
        end)

        if success then
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Bulles d'aide des armes réactivées!")
        else
            chat.AddText(Color(255, 100, 100), "[GP2] ", Color(255, 255, 255), "Commande gmod_showhints non disponible")
        end
    end, nil, "Réactive les bulles d'aide des armes")

    -- Message d'information au joueur
    hook.Add("PlayerInitialSpawn", "GP2::WeaponControlInfo", function()
        timer.Simple(3, function()
            chat.AddText(Color(100, 255, 255), "[GP2] ", Color(255, 255, 255), "Système de contrôle des armes actif")
            chat.AddText(Color(200, 200, 200), "Utilisez ", Color(100, 255, 100), "gp2_hide_weapon_help", Color(200, 200, 200), " pour cacher les bulles d'aide")
            chat.AddText(Color(200, 200, 200), "Touche pour jeter l'arme : ", Color(255, 255, 100), GetConVar("gp2_weapon_drop_key"):GetString(), Color(200, 200, 200), " (changez avec gp2_set_drop_key)")
        end)
    end)
end

-- DEBUG : Hook pour loguer tout strip d'armes sur un joueur
if SERVER then
    local plymeta = FindMetaTable("Player")
    local oldStripWeapon = plymeta.StripWeapon
    function plymeta:StripWeapon(class)
        -- Log désactivé
        return oldStripWeapon(self, class)
    end
    local oldStripWeapons = plymeta.StripWeapons
    function plymeta:StripWeapons()
        -- Log désactivé
        return oldStripWeapons(self)
    end
end

-- Message d'information sur la convar Portal Gun Only
print("[GP2] Le mode 'Portal Gun uniquement' est désactivé par défaut.")
print("[GP2] Pour l'activer : tapez 'gp2_portal_only_on' dans la console.")
print("[GP2] Pour le désactiver : tapez 'gp2_portal_only_off' dans la console.")

GP2.Print("Système de contrôle des armes GP2 chargé")

-- Commande pour afficher la classe de l'entité pointée
concommand.Add("gp2_what_is_this", function(ply)
    if not IsValid(ply) then return end
    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then
        ply:ChatPrint("[GP2] Rien de pointé.")
        return
    end
    local ent = tr.Entity
    local class = ent:GetClass()
    local model = ent.GetModel and ent:GetModel() or "(pas de modèle)"
    ply:ChatPrint("[GP2] Classe : " .. class .. " | Modèle : " .. model)
end, nil, "Affiche la classe et le modèle de l'entité que vous pointez.")

-- Pickup manuel du Portal Gun via USE sur le prop_physics
hook.Add("PlayerUse", "GP2::PickupPortalGunProp", function(ply, ent)
    if not IsValid(ent) or not IsValid(ply) then return end
    if ent:GetClass() == "prop_physics" and ent:GetModel() == "models/weapons/portalgun/w_portalgun.mdl" then
        if not ply:HasWeapon("weapon_portalgun") then
            ply:Give("weapon_portalgun")
            ply:EmitSound("items/ammo_pickup.wav", 70)
        end
        ent:Remove()
        return false -- Bloque l'usage normal du prop
    end
end)

-- Conversion automatique des props Portal Gun en weapon_portalgun au sol
if SERVER then
    timer.Create("GP2_AutoConvertPortalGunProp", 1, 0, function()
        for _, ent in ipairs(ents.FindByClass("prop_physics")) do
            if ent:GetModel() == "models/weapons/portalgun/w_portalgun.mdl" then
                -- Vérifie qu'il n'y a pas déjà une arme à cet endroit
                local pos = ent:GetPos()
                local found = false
                for _, wep in ipairs(ents.FindInSphere(pos, 8)) do
                    if wep:GetClass() == "weapon_portalgun" then
                        found = true break
                    end
                end
                if not found then
                    local ang = ent:GetAngles()
                    local dropped = ents.Create("weapon_portalgun")
                    if IsValid(dropped) then
                        dropped:SetPos(pos)
                        dropped:SetAngles(ang)
                        dropped:Spawn()
                        dropped:SetNWFloat("GP2PickupTime", CurTime() + 2)
                    end
                    ent:Remove()
                end
            end
        end
    end)
end
