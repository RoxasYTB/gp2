-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Aperture Button (floor)
-- ----------------------------------------------------------------------------

AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

local DEFAULT_BUTTON_MODEL = "models/props/portal_button.mdl"
local TRIGGER_MINS = Vector(-20,-20,0)
local TRIGGER_MAXS = Vector(20,20,18)
local DEBUG_PRESSED_COLOR = Color(90,200,90,16)
local DEBUG_UNPRESSED_COLOR = Color(200,90,90,16)

local developer = GetConVar("developer")

if SERVER then
    ENT.Pressed = false
    ENT.ButtonTrigger = NULL

    function ENT:Initialize()
        if not self:GetModel() then
            self:SetModel(DEFAULT_BUTTON_MODEL)
        end

        self:SetMoveType(MOVETYPE_NONE)

        self:CreateBoneFollowers()
        self.SequenceDown = self:LookupSequence("down")
        self.SequenceUp = self:LookupSequence("up")        self.ButtonTrigger = ents.Create("prop_floor_button_trigger")
        self.ButtonTrigger:Spawn()
        self.ButtonTrigger:SetPos(self:GetPos())
        self.ButtonTrigger:SetParent(self)
        self.ButtonTrigger:SetButton(self)        -- Rayon de détection par défaut
        self.CheckRadius = 25
        
        -- Transmettre le rayon au trigger après sa création
        timer.Simple(0.1, function()
            if IsValid(self.ButtonTrigger) then
                self.ButtonTrigger.CheckRadius = self.CheckRadius
            end
        end)

        local pos = self:GetPos()
        local angles = self:GetAngles()
        local mins = pos  - (angles:Forward() * 20) - (angles:Right() * 20)
        local maxs = pos + (angles:Forward() * 20) + (angles:Right() * 20) + (angles:Up() * 18)

        self.ButtonTrigger:SetCollisionBounds(self:WorldToLocal(mins), self:WorldToLocal(maxs))
    end
      function ENT:KeyValue(k, v)
        if k == "skin" then
            self:SetSkin(tonumber(v))
        elseif k == "model" then
            self:SetModel(v)
        elseif k == "CheckRadius" then
            self.CheckRadius = tonumber(v) or 25
        end

        if k:StartsWith("On") then
            self:StoreOutput(k, v)
            -- Détection d'un output vers un prop_dynamic
            if string.find(v, "prop_dynamic", 1, true) then
                self.NoRetrigger = true
            end
        end
    end

    ENT.__input2func = {
        ["pressin"] = function(self, activator, caller, data)
            self:Press()
        end,
        ["pressout"] = function(self, activator, caller, data)
            self:PressOut()
        end
    }

    function ENT:AcceptInput(name, activator, caller, data)
        name = name:lower()
        local func = self.__input2func[name]
    
        if func and isfunction(func) then
            func(self, activator, caller, data)
        end
    end    -- Helper pour s'assurer de la compatibilité des outputs
    function ENT:TriggerPressedOutput()
        self:TriggerOutput("OnPressed")
        self:TriggerOutput("OnButtonPressed") -- Compatibilité alternative
    end

    function ENT:TriggerUnpressedOutput()
        self:TriggerOutput("OnUnPressed")
        self:TriggerOutput("OnButtonUnPressed") -- Compatibilité alternative
        self:TriggerOutput("OnReleased") -- Autre nom commun
    end    function ENT:Press()
        if self.Pressed then return end

        self.Pressed = true
        self:SetSkin(1)
        self:ResetSequence(self.SequenceDown)
        self:TriggerPressedOutput()
        
        -- Logging de l'activation du bouton au sol via le système centralisé
        if SERVER and GP2 and GP2.ButtonLogging then
            GP2.ButtonLogging.LogActivation("BOUTON AU SOL", self:GetName(), self:GetPos(), true)
        end
    end    function ENT:PressOut()
        if not self.Pressed then return end

        self.Pressed = false
        self:SetSkin(0)
        self:ResetSequence(self.SequenceUp)
        self:TriggerUnpressedOutput()
        
        -- Logging de la désactivation du bouton au sol via le système centralisé
        if SERVER and GP2 and GP2.ButtonLogging then
            GP2.ButtonLogging.LogActivation("BOUTON AU SOL", self:GetName(), self:GetPos(), false)
        end
    end

    function ENT:Think()
        self:UpdateBoneFollowers()

        if developer:GetBool() then
            local mins, maxs = self.ButtonTrigger:GetCollisionBounds()
            debugoverlay.Box(self:GetPos(), mins, maxs, 0.1, self.Pressed and DEBUG_PRESSED_COLOR or DEBUG_UNPRESSED_COLOR)
        end

        self:NextThink(CurTime())
        return true
    end

    function ENT:IsButton()
        return true
    end

    function ENT:OnRemove()
        self:DestroyBoneFollowers()

        if IsValid(self.ButtonTrigger) then
            self.ButtonTrigger:Remove()
        end
    end
end