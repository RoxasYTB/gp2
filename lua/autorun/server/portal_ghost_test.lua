-- Script de test du système de ghost pour portails
-- Utilise la console pour tester les différents types de portails

print("=== TEST SYSTÈME GHOST PORTAILS ===")
print("Commandes disponibles :")
print("  gp2_test_ghost_mur    - Crée un portail mural standard")
print("  gp2_test_ghost_sol    - Crée un portail au sol")
print("  gp2_test_ghost_plafond - Crée un portail au plafond")
print("  gp2_test_ghost_cube   - Spawn un cube près du dernier portail")
print("  gp2_test_ghost_clean  - Nettoie les entités de test")

-- Variables globales pour les tests
local testPortal1 = nil
local testPortal2 = nil
local testCube = nil

-- Fonction pour créer un portail mural
concommand.Add("gp2_test_ghost_mur", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local pos = ply:GetPos() + ply:GetForward() * 100
    local ang = ply:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)

    -- Créer portail d'entrée
    testPortal1 = ents.Create("prop_portal")
    if IsValid(testPortal1) then
        testPortal1:SetPos(pos)
        testPortal1:SetAngles(ang)
        testPortal1:SetType(PORTAL_TYPE_FIRST)
        testPortal1:SetLinkageGroup(99)
        testPortal1:Spawn()
        testPortal1:SetActivated(true)

        -- Créer portail de sortie
        testPortal2 = ents.Create("prop_portal")
        if IsValid(testPortal2) then
            testPortal2:SetPos(pos + Vector(0, 0, 200))
            testPortal2:SetAngles(ang)
            testPortal2:SetType(PORTAL_TYPE_SECOND)
            testPortal2:SetLinkageGroup(99)
            testPortal2:Spawn()
            testPortal2:SetActivated(true)

            -- Lier les portails
            testPortal1:SetLinkedPartner(testPortal2)
            testPortal2:SetLinkedPartner(testPortal1)
        end
    end

    print("Portails muraux créés !")
end)

-- Fonction pour créer un portail au sol
concommand.Add("gp2_test_ghost_sol", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local pos = ply:GetPos() + ply:GetForward() * 100
    pos.z = pos.z - 50 -- Au niveau du sol

    local ang = Angle(0, 0, 0) -- Orientation horizontale

    -- Créer portail d'entrée (au sol)
    testPortal1 = ents.Create("prop_portal")
    if IsValid(testPortal1) then
        testPortal1:SetPos(pos)
        testPortal1:SetAngles(ang)
        testPortal1:SetType(PORTAL_TYPE_FIRST)
        testPortal1:SetLinkageGroup(99)
        testPortal1:Spawn()
        testPortal1:SetActivated(true)

        -- Créer portail de sortie (mural)
        testPortal2 = ents.Create("prop_portal")
        if IsValid(testPortal2) then
            local pos2 = pos + Vector(300, 0, 100)
            local ang2 = Angle(0, 90, 0)
            testPortal2:SetPos(pos2)
            testPortal2:SetAngles(ang2)
            testPortal2:SetType(PORTAL_TYPE_SECOND)
            testPortal2:SetLinkageGroup(99)
            testPortal2:Spawn()
            testPortal2:SetActivated(true)

            -- Lier les portails
            testPortal1:SetLinkedPartner(testPortal2)
            testPortal2:SetLinkedPartner(testPortal1)
        end
    end

    print("Portail au sol créé !")
end)

-- Fonction pour créer un portail au plafond
concommand.Add("gp2_test_ghost_plafond", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local pos = ply:GetPos() + ply:GetForward() * 100
    pos.z = pos.z + 200 -- Au niveau du plafond

    local ang = Angle(0, 0, 180) -- Orientation plafond (inversée)

    -- Créer portail d'entrée (au plafond)
    testPortal1 = ents.Create("prop_portal")
    if IsValid(testPortal1) then
        testPortal1:SetPos(pos)
        testPortal1:SetAngles(ang)
        testPortal1:SetType(PORTAL_TYPE_FIRST)
        testPortal1:SetLinkageGroup(99)
        testPortal1:Spawn()
        testPortal1:SetActivated(true)

        -- Créer portail de sortie (mural)
        testPortal2 = ents.Create("prop_portal")
        if IsValid(testPortal2) then
            local pos2 = pos + Vector(300, 0, -100)
            local ang2 = Angle(0, 90, 0)
            testPortal2:SetPos(pos2)
            testPortal2:SetAngles(ang2)
            testPortal2:SetType(PORTAL_TYPE_SECOND)
            testPortal2:SetLinkageGroup(99)
            testPortal2:Spawn()
            testPortal2:SetActivated(true)

            -- Lier les portails
            testPortal1:SetLinkedPartner(testPortal2)
            testPortal2:SetLinkedPartner(testPortal1)
        end
    end

    print("Portail au plafond créé !")
end)

-- Fonction pour spawn un cube
concommand.Add("gp2_test_ghost_cube", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local pos = ply:GetPos() + ply:GetForward() * 150

    testCube = ents.Create("prop_weighted_cube")
    if IsValid(testCube) then
        testCube:SetPos(pos)
        testCube:Spawn()
        print("Cube créé à la position : " .. tostring(pos))
    end
end)

-- Fonction de nettoyage
concommand.Add("gp2_test_ghost_clean", function(ply, cmd, args)
    if IsValid(testPortal1) then
        testPortal1:Remove()
        testPortal1 = nil
    end
    if IsValid(testPortal2) then
        testPortal2:Remove()
        testPortal2 = nil
    end
    if IsValid(testCube) then
        testCube:Remove()
        testCube = nil
    end
    print("Entités de test nettoyées !")
end)

print("=== SCRIPT DE TEST CHARGÉ ===")
