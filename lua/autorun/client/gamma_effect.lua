hook.Add("RenderScreenspaceEffects", "GammaSim", function()
	local gamma = 0.9;
	local tab = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = gamma / 10,
		["$pp_colour_contrast"] = gamma,
		["$pp_colour_colour"] = 1,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	};
	DrawColorModify(tab);
end);
