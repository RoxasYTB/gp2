hook.Add("EntityTakeDamage", "NoPhysicsDamage", function(target, dmginfo)
	if dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_PHYSGUN) then
		dmginfo:SetDamage(0);
		return true;
	end;
end);
