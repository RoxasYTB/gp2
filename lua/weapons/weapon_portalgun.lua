AddCSLuaFile("weapon_portalgun/cl_init.lua");
AddCSLuaFile("weapon_portalgun/init.lua");
include("weapon_portalgun/shared.lua");
if SERVER then
	include("weapon_portalgun/init.lua");
end;
