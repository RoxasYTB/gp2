-- Prop Portal Entity Standalone File
-- This file is required for AddCSLuaFile compatibility

-- Include the actual portal entity files
if SERVER then
    AddCSLuaFile("prop_portal/shared.lua")
    AddCSLuaFile("prop_portal/cl_init.lua")
    include("prop_portal/shared.lua")
    include("prop_portal/init.lua")
else
    include("prop_portal/shared.lua")
    include("prop_portal/cl_init.lua")
end
