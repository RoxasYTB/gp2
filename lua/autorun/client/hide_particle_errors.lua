hook.Add("Think", "HideParticleSpam", function()
	if not ConVarExists("con_filter_enable") then
		return;
	end;
	RunConsoleCommand("con_filter_enable", "1");
	RunConsoleCommand("con_filter_text_out", "Cannot update control point");
	RunConsoleCommand("con_filter_text_out", "Attempting to create unknown particle system");
	RunConsoleCommand("developer", "2");
	hook.Remove("Think", "HideParticleSpam");
end);
