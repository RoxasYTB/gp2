local function applyMotionBlur()
	local ply = LocalPlayer();
	if not IsValid(ply) then
		return;
	end;
	local velocity = (ply:GetVelocity()):Length();
	local blur = math.Clamp(velocity / 800, 0, 1);
	if blur > 0.05 then
		DrawMotionBlur(0.1, blur / 5, 0.01);
	end;
end;
hook.Add("RenderScreenspaceEffects", "GP2_MotionBlur", applyMotionBlur);
local WHOOSH_SOUND = "flyby.wav";
local SPEED_THRESHOLD = 200;
local MIN_VOLUME = 0;
local MAX_VOLUME = 0.3;
local MAX_SPEED = 1500;
local whooshSound;
hook.Add("Think", "GP2_WhooshEffect", function()
	local ply = LocalPlayer();
	if not IsValid(ply) then
		return;
	end;
	local velocity = (ply:GetVelocity()):Length();
	if velocity < SPEED_THRESHOLD then
		if whooshSound and whooshSound:IsPlaying() then
			whooshSound:Stop();
		end;
		return;
	end;
	if not whooshSound then
		whooshSound = CreateSound(ply, WHOOSH_SOUND);
	end;
	if not whooshSound:IsPlaying() then
		whooshSound:PlayEx(MIN_VOLUME, 100);
	end;
	local volume = math.Clamp(velocity / MAX_SPEED - 0.2, MIN_VOLUME, MAX_VOLUME);
	whooshSound:ChangeVolume(volume, 0);
end);
hook.Add("ShutDown", "GP2_StopWhoosh", function()
	if whooshSound then
		whooshSound:Stop();
	end;
end);
