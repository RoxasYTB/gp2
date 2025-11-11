hook.Add("Think", "HideParticleSpam", function()
	if not ConVarExists("con_filter_enable") then
		return;
	end;
	RunConsoleCommand("con_filter_enable", "1");
	hook.Remove("Think", "HideParticleSpam");
end);
