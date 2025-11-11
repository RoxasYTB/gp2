include("gp2/error.lua");
include("gp2/error.lua");
local vscriptinstance = {};
local entswithvscripts = {};
local thinkqueues = {};
local fmt = string.format;
local MetaEntity = FindMetaTable("Entity");
local function relativeInclude(baseDir, fileName)
	local actualPath = string.format("%s/%s.lua", baseDir, fileName:gsub("%.[^%.]+$", ""));
	if not file.Exists(actualPath, "LUA") then
		error("Included script not found: " .. actualPath);
	end;
	return CompileFile(actualPath);
end;
function MetaEntity:GetOrCreateVScriptScope()
	vscriptinstance[self] = vscriptinstance[self] or include("gp2/vscriptsandbox.lua");
	return vscriptinstance[self];
end;
GP2.VScriptMgr = {
	Initialize = function()
		GP2.Print("Initializing the VScript system");
	end,
	InitializeScriptForEntity = function(ent, v)
		entswithvscripts[ent] = true;
		GP2.VScriptMgr.RunScriptFile(ent, v);
		timer.Simple(0, function()
			GP2.VScriptMgr.CallScriptFunction(ent, "Precache", true, NULL);
		end);
	end,
	InitializeScriptThinkFuncForEntity = function(ent, v)
		thinkqueues[ent] = v;
	end,
	ClearScriptScope = function(ent)
		vscriptinstance[ent] = {};
	end,
	RunScriptFile = function(ent, fl)
		fl = fl:gsub("%.[^%.]+$", "");
		local actualPath = "vscripts/" .. fl .. ".lua";
		if not file.Exists(actualPath, "LUA") then
			GP2.Error("Script not found (lua/%s)", actualPath);
			return;
		end;
		GP2.Print("Running script '%s' on entity '%s'", fl, ent:GetName() ~= "" and ent:GetName() or ent:GetClass());
		local scope = ent:GetOrCreateVScriptScope();
		scope.self = ent;
		scope.include = function(fileName)
			local baseDir = string.match(actualPath, "^(.-)[^/]+$");
			local chunk, err = relativeInclude(baseDir, fileName);
			if not chunk then
				error(err, 2);
			end;
			(setfenv(chunk, scope))();
		end;
		local chunk, err = CompileFile(actualPath);
		if not chunk then
			GP2.Error(err);
			return;
		end;
		setfenv(chunk, scope);
		local success, runtimeErr = pcall(chunk);
		if not success then
			GP2.Error(runtimeErr);
		end;
	end,
	RunScriptFileHandless = function(fl)
		fl = fl:gsub("%.[^%.]+$", "");
		local actualPath = "vscripts/" .. fl .. ".lua";
		if not file.Exists(actualPath, "LUA") then
			GP2.VScriptMgr.Error("Script not found (lua/%s)", actualPath);
			return;
		end;
		GP2.Print("Running script '%s'", fl);
		local scope = include("gp2/vscriptsandbox.lua");
		scope.include = function(fileName)
			local baseDir = string.match(actualPath, "^(.-)[^/]+$");
			local chunk, err = relativeInclude(baseDir, fileName);
			if not chunk then
				error(err, 2);
			end;
			(setfenv(chunk, scope))();
		end;
		local chunk, err = CompileFile(actualPath);
		if not chunk then
			GP2.VScriptMgr.Error(err);
			return;
		end;
		setfenv(chunk, scope);
		local success, runtimeErr = pcall(chunk);
		if not success then
			GP2.VScriptMgr.Error(runtimeErr);
		end;
	end,
	RunScriptCode = function(ent, code)
		local scope = ent:GetOrCreateVScriptScope();
		scope.self = ent;
		scope.include = function(fileName)
			GP2.VScriptMgr.Error("Include function is not supported in RunScriptCode.");
		end;
		local chunk, err = CompileString(code);
		if not chunk and err then
			GP2.Error(err:gsub("CompileString:(%d)+", ""));
			return;
		end;
		setfenv(chunk, scope);
		local success, runtimeErr = pcall(chunk);
		if not success and runtimeErr then
			GP2.Error(runtimeErr:gsub("CompileString%:%d+: ", "RunScriptCode: ( '" .. (ent:GetName() ~= "" and ent:GetName() or ent:GetClass()) .. "' )"));
		end;
		GP2.Print("Calling the %q on %q", code, tostring(ent));
	end,
	CallScriptFunction = function(ent, funcname, failesilent, caller)
		failesilent = failesilent or false;
		local scope = ent:GetOrCreateVScriptScope();
		scope.self = ent;
		scope.owninginstance = caller;
		local func = scope[funcname];
		if func and func then
			func();
		elseif not failesilent then
			GP2.Error("Attempt to call script function with name '%s' (not found)");
		end;
	end,
	CallScriptFunctionWithArgs = function(ent, funcname, failesilent, ...)
		failesilent = failesilent or false;
		local scope = ent:GetOrCreateVScriptScope();
		local func = scope[funcname];
		if func and func then
			func(...);
		elseif not failesilent then
			GP2.Error("Attempt to call script function with name '%s' (not found)", funcname);
		end;
	end,
	CallHookFunction = function(hookname, failesilent, ...)
		for ent in pairs(entswithvscripts) do
			if IsValid(ent) or ent:IsWorld() then
				GP2.VScriptMgr.CallScriptFunctionWithArgs(ent, hookname, failesilent, ...);
			end;
		end;
	end,
	Think = function()
		for ent, thinkfunc in pairs(thinkqueues) do
			GP2.VScriptMgr.CallScriptFunction(ent, thinkfunc, true);
		end;
	end
};
GP2.InputsHandler.AddCallback("runscriptcode", function(ent, activator, caller, value)
	GP2.VScriptMgr.RunScriptCode(ent, value);
end);
GP2.InputsHandler.AddCallback("runscriptfile", function(ent, activator, caller, value)
	GP2.VScriptMgr.RunScriptFile(ent, value);
end);
GP2.InputsHandler.AddCallback("callscriptfunction", function(ent, activator, caller, value)
	GP2.VScriptMgr.CallScriptFunction(ent, value, false, caller);
end);
GP2.KeyValueHandler.Add("vscripts", GP2.VScriptMgr.InitializeScriptForEntity);
GP2.KeyValueHandler.Add("thinkfunction", GP2.VScriptMgr.InitializeScriptThinkFuncForEntity);
