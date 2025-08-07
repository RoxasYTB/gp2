-- Commande de test pour les portails GP2
-- Permet de spawner des portails rapidement pour tester le rendu

-- Debug command for portal rendering system
if CLIENT then
    concommand.Add("gp2_portal_render_test", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local pos = ply:GetPos()
        local ang = ply:GetAngles()

        print("[GP2-SDK] Creating test portals for seamless rendering...")

        -- Create two portals facing each other for testing view-through
        local portal1Pos = pos + ang:Forward() * 200 + Vector(0, 0, 50)
        local portal2Pos = pos + ang:Forward() * 600 + Vector(0, 0, 50)

        local portal1Ang = ang + Angle(0, 180, 0)
        local portal2Ang = ang

        -- Send commands to server to create portals
        RunConsoleCommand("gp2_spawn_portal", "1", "1") -- Blue portal
        timer.Simple(0.2, function()
            RunConsoleCommand("gp2_spawn_portal", "2", "1") -- Orange portal
            timer.Simple(0.2, function()
                print("[GP2-SDK] Test portals should be created. Use 'gp2_portal_debug' to check rendering status")
                print("[GP2-SDK] Walk close to the portals to test seamless view-through rendering")
            end)
        end)
    end, nil, "Create test portals specifically for seamless rendering testing")
end

if SERVER then
    -- Commande pour spawner un portail de test
    concommand.Add("gp2_spawn_portal", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not trace.Hit then return end

        local portalType = tonumber(args[1]) or TYPE_BLUE
        local linkageGroup = tonumber(args[2]) or 1

        -- Créer le portail
        local portal = ents.Create("prop_portal")
        if not IsValid(portal) then
            ply:ChatPrint("Erreur : Impossible de créer l'entité prop_portal")
            return
        end

        -- Position légèrement décalée de la surface
        local pos = trace.HitPos + trace.HitNormal * 2
        portal:SetPos(pos)

        -- Orienter le portail face au joueur
        local ang = trace.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), 90)
        portal:SetAngles(ang)

        -- Configurer le portail
        portal:SetType(portalType)
        portal:SetLinkageGroup(linkageGroup)
        portal:Spawn()
        portal:Activate()

        -- Activer le portail
        portal:SetActivated(true)
        portal:SetOpenTime(CurTime())

        ply:ChatPrint(string.format("Portail créé (Type: %d, Groupe: %d)", portalType, linkageGroup))
    end)

    -- Commande pour lier deux portails
    concommand.Add("gp2_link_portals", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local linkageGroup = tonumber(args[1]) or 1

        -- Trouver tous les portails du même groupe
        local portals = {}
        for _, ent in pairs(ents.FindByClass("prop_portal")) do
            if ent:GetLinkageGroup() == linkageGroup then
                table.insert(portals, ent)
            end
        end

        if #portals >= 2 then
            -- Lier les deux premiers portaux trouvés
            local portal1 = portals[1]
            local portal2 = portals[2]

            portal1:SetLinkedPartner(portal2)
            portal2:SetLinkedPartner(portal1)

            ply:ChatPrint(string.format("Portails liés dans le groupe %d", linkageGroup))
        else
            ply:ChatPrint(string.format("Pas assez de portails dans le groupe %d (%d trouvés)", linkageGroup, #portals))
        end
    end)

else
    -- CLIENT - Afficher les commandes disponibles
    hook.Add("Initialize", "GP2_ShowPortalCommands", function()
            print("[GP2-SDK] Test commands loaded")
    end)
end
