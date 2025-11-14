local function applyMotionBlur()
	local ply = LocalPlayer();
	if not IsValid(ply) then
		return;
	end;
	local velocity = (ply:GetVelocity()):Length();
	local blur = math.Clamp(velocity / 800, 0, 1);
	if blur > 0.05 then
		print("Applying motion blur with intensity: " .. tostring(blur));
		DrawMotionBlur(0.1, blur / 5, 0.01);
	end;
end;
hook.Add("RenderScreenspaceEffects", "GP2_MotionBlur", applyMotionBlur);
print("GP2 Motion Blur script loaded.");
