if CLIENT then
	local oldPrint = MsgC;
	MsgC = function(...)
		local msg = "";
		for _, v in ipairs({
			...
		}) do
			msg = msg .. tostring(v);
		end;
		if msg:find("Cannot update control point", 1, true) then
			return;
		end;
		if msg:find("Attempting to create unknown particle system", 1, true) then
			return;
		end;
		return oldPrint(...);
	end;
end;
