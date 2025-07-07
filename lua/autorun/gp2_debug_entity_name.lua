-- Affiche le nom de l'entité pointée par le joueur dans la console
hook.Add("PlayerSay", "GP2_Debug_EntityName", function(ply, text)
    if string.Trim(text) == "!entname" then
        local tr = ply:GetEyeTrace()
        if IsValid(tr.Entity) then
            print("[GP2][DEBUG] Vous pointez : " .. tostring(tr.Entity) .. " (class: " .. tr.Entity:GetClass() .. ", name: " .. (tr.Entity:GetName() or "") .. ")")
            ply:ChatPrint("[GP2][DEBUG] Vous pointez : " .. tostring(tr.Entity) .. " (class: " .. tr.Entity:GetClass() .. ", name: " .. (tr.Entity:GetName() or "") .. ")")
        else
            print("[GP2][DEBUG] Aucun objet pointé.")
            ply:ChatPrint("[GP2][DEBUG] Aucun objet pointé.")
        end
        return ""
    end
end)
