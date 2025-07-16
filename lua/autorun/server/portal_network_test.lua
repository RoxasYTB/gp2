-- Test script pour vérifier la correction des conflits de messages réseau
-- Utiliser: portal_network_test dans la console pour tester

if SERVER then
    concommand.Add("portal_network_test", function(ply, cmd, args)
        print("[GP2] Test de conflit de messages réseau...")

        -- Créer deux portails
        local portal1 = ents.Create("prop_portal")
        local portal2 = ents.Create("prop_portal")

        if IsValid(portal1) and IsValid(portal2) then
            -- Positionner les portails
            portal1:SetPos(ply:GetPos() + ply:GetForward() * 100)
            portal1:SetAngles(ply:GetAngles())
            portal1:SetType(PORTAL_TYPE_FIRST)
            portal1:Spawn()
            portal1:SetActivated(true)

            portal2:SetPos(ply:GetPos() + ply:GetForward() * 200)
            portal2:SetAngles(ply:GetAngles() + Angle(0, 180, 0))
            portal2:SetType(PORTAL_TYPE_SECOND)
            portal2:Spawn()
            portal2:SetActivated(true)

            -- Lier les portails
            portal1:SetLinkedPartner(portal2)

            -- Créer une prop pour tester les ghosts
            local prop = ents.Create("prop_physics")
            prop:SetModel("models/props_lab/workspace003.mdl")
            prop:SetPos(ply:GetPos() + ply:GetForward() * 150)
            prop:Spawn()

            print("[GP2] Portails créés, test du fizzle rapide...")

            -- Test de fizzle rapide (ce qui causait le conflit)
            timer.Simple(0.1, function()
                if IsValid(portal1) then
                    portal1:Fizzle()
                end
            end)

            timer.Simple(0.2, function()
                if IsValid(portal2) then
                    portal2:Fizzle()
                end
            end)

            -- Nettoyage après test
            timer.Simple(5, function()
                if IsValid(prop) then prop:Remove() end
            end)

            print("[GP2] Test terminé - vérifiez la console pour les erreurs de réseau")
        else
            print("[GP2] Erreur: impossible de créer les portails de test")
        end
    end)

    concommand.Add("portal_network_stress", function(ply, cmd, args)
        print("[GP2] Test de stress des messages réseau...")

        -- Créer des portails et forcer de multiples messages réseau
        local portal1 = ents.Create("prop_portal")
        local portal2 = ents.Create("prop_portal")

        if IsValid(portal1) and IsValid(portal2) then
            portal1:SetPos(ply:GetPos() + ply:GetForward() * 100)
            portal1:SetAngles(ply:GetAngles())
            portal1:SetType(PORTAL_TYPE_FIRST)
            portal1:Spawn()
            portal1:SetActivated(true)

            portal2:SetPos(ply:GetPos() + ply:GetForward() * 200)
            portal2:SetAngles(ply:GetAngles() + Angle(0, 180, 0))
            portal2:SetType(PORTAL_TYPE_SECOND)
            portal2:Spawn()
            portal2:SetActivated(true)

            portal1:SetLinkedPartner(portal2)

            -- Créer plusieurs props rapidement
            for i = 1, 10 do
                local prop = ents.Create("prop_physics")
                prop:SetModel("models/props_lab/workspace003.mdl")
                prop:SetPos(ply:GetPos() + ply:GetForward() * (120 + i * 5))
                prop:Spawn()

                -- Forcer un fizzle rapide pendant que les ghosts sont créés
                timer.Simple(0.05 * i, function()
                    if IsValid(portal1) and i == 5 then
                        portal1:Fizzle()
                    end
                end)

                timer.Simple(5, function()
                    if IsValid(prop) then prop:Remove() end
                end)
            end

            timer.Simple(1, function()
                if IsValid(portal2) then portal2:Remove() end
            end)

            print("[GP2] Test de stress terminé - vérifiez la console pour les erreurs")
        end
    end)
end
