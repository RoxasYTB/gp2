-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Floor button (underground), just uses prop_floor_button as base
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true -- Enable automatic frame advancement

DEFINE_BASECLASS( "prop_floor_button" )

local DEFAULT_BUTTON_MODEL = "models/props_underground/underground_floor_button.mdl"

function ENT:Initialize()
    self.BaseClass.Initialize(self)

    if SERVER then
        self:SetModel(DEFAULT_BUTTON_MODEL)
        self:CreateBoneFollowers()
        self.SequenceDown = self:LookupSequence("press")
        self.SequenceUp = self:LookupSequence("unpress")
    end
end

function ENT:Press()
    if self.Pressed then return end

    self.Pressed = true
    self:SetSkin(1)
    self:ResetSequence(self.SequenceDown)
    self:TriggerPressedOutput()
    
    -- Logging de l'activation du bouton au sol souterrain via le système centralisé
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON AU SOL SOUTERRAIN", self:GetName(), self:GetPos(), true)
    end
end

function ENT:PressOut()
    if not self.Pressed then return end

    self.Pressed = false
    self:SetSkin(0)
    self:ResetSequence(self.SequenceUp)
    self:TriggerUnpressedOutput()
    
    -- Logging de la désactivation du bouton au sol souterrain via le système centralisé
    if SERVER and GP2 and GP2.ButtonLogging then
        GP2.ButtonLogging.LogActivation("BOUTON AU SOL SOUTERRAIN", self:GetName(), self:GetPos(), false)
    end
end