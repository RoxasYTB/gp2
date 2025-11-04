if type(ENT) ~= "table" then
	return;
end;
if SERVER and AddCSLuaFile then
	AddCSLuaFile("prop_portal/cl_init.lua");
	AddCSLuaFile("prop_portal/shared.lua");
end;
if SERVER then
	include("prop_portal/init.lua");
	include("exception_to_load_by_level.lua");
elseif CLIENT then
	include("prop_portal/cl_init.lua");
else
	include("prop_portal/shared.lua");
end;
