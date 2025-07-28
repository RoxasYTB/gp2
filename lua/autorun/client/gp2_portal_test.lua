-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Portal System Test
-- Script de test pour vérifier le bon fonctionnement du système de portails
-- avec les lasers, tractor beams et projected walls
-- ----------------------------------------------------------------------------

if not CLIENT then return end

-- Fonction de test pour vérifier la compatibilité
local function TestPortalCompatibility()
    GP2.Print("=== Test de compatibilité du système de portails ===")

    -- Chercher des portails existants
    local portals = ents.FindByClass("prop_portal")
    if #portals > 0 then
        GP2.Print("Portails trouvés: %d", #portals)
        for i, portal in ipairs(portals) do
            if IsValid(portal) then
                GP2.Print("  - Portail %d: Type %s, Activé: %s, Lié: %s",
                    i,
                    tostring(portal:GetType()),
                    tostring(portal:GetActivated()),
                    tostring(IsValid(portal:GetLinkedPartner()))
                )
            end
        end
    else
        GP2.Print("Aucun portail trouvé")
    end

    -- Chercher des lasers
    local lasers = ents.FindByClass("env_portal_laser")
    if #lasers > 0 then
        GP2.Print("Lasers trouvés: %d", #lasers)
    end

    -- Chercher des tractor beams
    local tractorBeams = ents.FindByClass("projected_tractor_beam_entity")
    if #tractorBeams > 0 then
        GP2.Print("Tractor beams trouvés: %d", #tractorBeams)
    end

    -- Chercher des projected walls
    local projectedWalls = ents.FindByClass("projected_wall_entity")
    if #projectedWalls > 0 then
        GP2.Print("Projected walls trouvés: %d", #projectedWalls)
    end

    GP2.Print("=== Test terminé ===")
end

-- Commande de test
concommand.Add("gp2_test_portals", TestPortalCompatibility, nil, "Teste la compatibilité du système de portails avec les éléments GP2")

-- Test automatique au chargement
hook.Add("InitPostEntity", "GP2::PortalTest", function()
    timer.Simple(2, function() -- Attendre que tout soit chargé
        TestPortalCompatibility()
    end)
end)
