-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Optimisation des sons pour réduire la latence réseau
-- ----------------------------------------------------------------------------

if SERVER then
    -- Cache pour limiter les émissions de sons trop fréquentes
    local soundThrottleCache = {}
    local SOUND_THROTTLE_TIME = 0.1 -- Minimum 100ms entre les mêmes sons

    local originalEmitSound = Entity.EmitSound

    function Entity:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
        local entIndex = self:EntIndex()
        local currentTime = CurTime()
        local cacheKey = entIndex .. "_" .. soundName

        -- Throttle des sons identiques pour éviter le spam
        if soundThrottleCache[cacheKey] and
           currentTime - soundThrottleCache[cacheKey] < SOUND_THROTTLE_TIME then
            return -- Ignorer les sons trop fréquents
        end

        soundThrottleCache[cacheKey] = currentTime

        -- Nettoyer le cache périodiquement
        if math.random(1, 1000) == 1 then
            for key, time in pairs(soundThrottleCache) do
                if currentTime - time > 5 then -- Enlever les entrées anciennes
                    soundThrottleCache[key] = nil
                end
            end
        end

        return originalEmitSound(self, soundName, soundLevel, pitchPercent, volume, channel)
    end
end
