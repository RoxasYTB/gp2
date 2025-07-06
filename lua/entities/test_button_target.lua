-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Test entity pour vérifier le bon fonctionnement des boutons
-- ----------------------------------------------------------------------------

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Test Button Target"
ENT.Spawnable = true
ENT.Category = "GP2 Test"

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props/portal_button.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        
        self:SetColor(Color(255, 0, 0)) -- Rouge par défaut (inactif)
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "Activated")
end

if SERVER then
    ENT.__input2func = {
        ["turnon"] = function(self, activator, caller, data)
            self:Activate()
        end,
        ["turnoff"] = function(self, activator, caller, data)
            self:Deactivate()
        end,
        ["toggle"] = function(self, activator, caller, data)
            if self:GetActivated() then
                self:Deactivate()
            else
                self:Activate()
            end
        end,
    }

    function ENT:AcceptInput(name, activator, caller, data)
        name = name:lower()
        local func = self.__input2func[name]

        if func and isfunction(func) then
            func(self, activator, caller, data)
            return true
        end
        
        return false
    end

    function ENT:Activate()
        if self:GetActivated() then return end
        
        self:SetActivated(true)
        self:SetColor(Color(0, 255, 0)) -- Vert (actif)
        self:EmitSound("buttons/button9.wav")
        print("[Test Button Target] Activé par " .. tostring(activator))
    end

    function ENT:Deactivate()
        if not self:GetActivated() then return end
        
        self:SetActivated(false)
        self:SetColor(Color(255, 0, 0)) -- Rouge (inactif)
        self:EmitSound("buttons/button10.wav")
        print("[Test Button Target] Désactivé")
    end
    
    function ENT:KeyValue(k, v)
        if k:StartsWith("On") then
            self:StoreOutput(k, v)
        end
    end
end
