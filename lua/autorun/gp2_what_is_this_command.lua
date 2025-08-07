-- Commande console pour identifier l'entité pointée par le joueur
-- Utilisation: gp2_what_is_this dans la console

if CLIENT then
    -- Fonction pour obtenir les informations détaillées de l'entité
    local function GetEntityInfo(ent)
        if not IsValid(ent) then
            return "Aucune entité valide"
        end

        local info = {}

        -- Classe de l'entité
        table.insert(info, "Classe: " .. ent:GetClass())

        -- Nom de l'entité (si défini)
        local name = ent:GetName()
        if name and name ~= "" then
            table.insert(info, "Nom: " .. name)
        end

        -- Modèle (pour les props)
        if ent:GetModel() and ent:GetModel() ~= "" then
            local model = ent:GetModel()
            -- Extraire juste le nom du fichier du modèle
            local modelName = string.GetFileFromFilename(model)
            table.insert(info, "Modèle: " .. modelName)
        end

        -- Position
        local pos = ent:GetPos()
        table.insert(info, string.format("Position: %.1f, %.1f, %.1f", pos.x, pos.y, pos.z))

        -- Distance du joueur
        local ply = LocalPlayer()
        if IsValid(ply) then
            local dist = ply:GetPos():Distance(pos)
            table.insert(info, string.format("Distance: %.1f unités", dist))
        end

        -- Type spécifique pour certaines entités
        if ent:IsPlayer() then
            table.insert(info, "Type: Joueur (" .. ent:Name() .. ")")
        elseif ent:IsNPC() then
            table.insert(info, "Type: NPC")
        elseif ent:IsVehicle() then
            table.insert(info, "Type: Véhicule")
        elseif ent:IsWeapon() then
            table.insert(info, "Type: Arme")
        elseif ent:GetClass():find("prop_") then
            table.insert(info, "Type: Prop")
        end

        return table.concat(info, " | ")
    end

    -- Commande console
    concommand.Add("gp2_what_is_this", function(ply, cmd, args)
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        -- Effectuer un trace depuis les yeux du joueur
        local tr = ply:GetEyeTrace()

        if IsValid(tr.Entity) then
            local info = GetEntityInfo(tr.Entity)
            print("[GP2] Entité pointée: " .. info)

            -- Afficher aussi dans le chat pour plus de visibilité
            chat.AddText(Color(100, 200, 255), "[GP2] ", Color(255, 255, 255), "Entité pointée: " .. info)
        else
            print("[GP2] Aucune entité pointée ou entité trop éloignée")
            chat.AddText(Color(100, 200, 255), "[GP2] ", Color(255, 255, 255), "Aucune entité pointée ou entité trop éloignée")
        end
    end, nil, "Affiche les informations de l'entité que vous pointez du regard")

    -- Raccourci alternatif plus court
    concommand.Add("gp2_whatisthis", function(ply, cmd, args)
        RunConsoleCommand("gp2_what_is_this")
    end, nil, "Raccourci pour gp2_what_is_this")

    -- Version encore plus courte
    concommand.Add("whatisthis", function(ply, cmd, args)
        RunConsoleCommand("gp2_what_is_this")
    end, nil, "Raccourci pour gp2_what_is_this")
end

