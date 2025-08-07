-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Neurotoxin countdown display
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "point"

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "Enabled")
    self:NetworkVar("Int", "Width")
    self:NetworkVar("Int", "Height")
    self:NetworkVar("Float", "TimeUntil")
end

function ENT:Initialize()
    self.NextThinkTime = 0
end

function ENT:KeyValue(k, v)
    if k == "width" then
        self:SetWidth(tonumber(v))
    elseif k == "height" then
        self:SetHeight(tonumber(v))
    elseif k == "countdown" then
        self.Countdown = tonumber(v)
    end
end

function ENT:Think()
    if self.NextThinkFunction
    and isfunction(self.NextThinkFunction)
    and CurTime() > self.NextThinkTime then
        self:NextThinkFunction()
    end

    -- OPTIMISATION : Early return si déjà dans la render list côté client
    if CLIENT then
        if VguiNeurotoxinCountdown.IsAddedToRenderList(self) then
            self:SetNextThink(CurTime() + 1) -- Réduire la fréquence à 1 fois par seconde
            return true
        end
        VguiNeurotoxinCountdown.AddToRenderList(self)
        self:SetNextThink(CurTime() + 0.1) -- Vérifier de nouveau dans 0.1 seconde
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:SetNextThink(nextThink)
    self.NextThinkTime = nextThink
end

function ENT:SetThink(nextThinkFunc)
    if nextThinkFunc then
        self.NextThinkFunction = nextThinkFunc
    end
end

function ENT:Enable()
    if self:GetEnabled() then return end

    self:SetEnabled(true)

    self:SetTimeUntil(CurTime() + tonumber(self.Countdown or 0))
end

function ENT:Disable()
    self:SetEnabled(false)
end

function ENT:AcceptInput(name, activator, caller, data)
    name = name:lower()

    if name == "enable" then
        self:Enable()
    elseif name == "disable" then
        self:Disable()
    end
end