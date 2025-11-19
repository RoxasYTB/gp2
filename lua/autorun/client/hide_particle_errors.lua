// hook.Add("Think", "HideParticleSpam", function()
// 	if not ConVarExists("con_filter_enable") then
// 		return;
// 	end;
// 	(LocalPlayer()):ConCommand("con_filter_text_out "Cannot update control point"");
// 	(LocalPlayer()):ConCommand("con_filter_enable 1");
// 	hook.Remove("Think", "HideParticleSpam");
// end);
