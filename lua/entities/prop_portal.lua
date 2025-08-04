-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Portals - Dispatcher File
-- ----------------------------------------------------------------------------

-- Entity context protection - only run if we're in proper entity context
if type(ENT) ~= "table" then
    -- Not in entity context, exit gracefully
    return
end

-- Only call AddCSLuaFile if on server and function exists
if SERVER and AddCSLuaFile then
    AddCSLuaFile("prop_portal/cl_init.lua")
    AddCSLuaFile("prop_portal/shared.lua")
end

-- Include the modular files
if SERVER then
    include("prop_portal/init.lua")
elseif CLIENT then
    include("prop_portal/cl_init.lua")
else
    include("prop_portal/shared.lua")
end