-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Masque uniquement la barre de vie du HUD (health bar)
-- ----------------------------------------------------------------------------

if CLIENT then
    hook.Add("HUDShouldDraw", "GP2_HideHealthBar", function(name)
        if name == "CHudHealth" then
            return false
        end
    end)
end
