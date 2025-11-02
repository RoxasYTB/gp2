GP2 = GP2 or {};
function GP2.Error(msg, ...)
	MsgC(Color(255, 0, 0), "[GP2] ", string.format(tostring(msg), ...) .. "\n");
end;
