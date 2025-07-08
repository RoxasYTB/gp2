-- gp2_getz.lua
-- Permet d'obtenir la hauteur Z du props regardé via la commande chat !getz

if SERVER then
    util.AddNetworkString("gp2_getz_result")

    hook.Add("PlayerSay", "GP2_GetZCommand", function(ply, text)
        if string.lower(text) == "!getz" then
            local tr = ply:GetEyeTrace()
            if IsValid(tr.Entity) then
                local z = tr.Entity:GetPos().z
                net.Start("gp2_getz_result")
                net.WriteEntity(tr.Entity)
                net.WriteFloat(z)
                net.Send(ply)
                ply:ChatPrint("[GP2] Hauteur Z du props: " .. math.Round(z, 2))
            else
                ply:ChatPrint("[GP2] Aucun props valide sous le regard.")
            end
            return ""
        end
    end)
else
    net.Receive("gp2_getz_result", function()
        local ent = net.ReadEntity()
        local z = net.ReadFloat()
        chat.AddText(Color(0,200,255), "[GP2] Hauteur Z du props ", tostring(ent), ": ", Color(255,255,0), math.Round(z,2))
    end)
end
