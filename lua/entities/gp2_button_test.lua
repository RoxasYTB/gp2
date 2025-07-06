-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Test entity for button functionality
-- ----------------------------------------------------------------------------

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "GP2 Button Test Entity"
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
        
        self:SetColor(Color(100, 100, 255)) -- Bleu par défaut (test)
        self.TestState = false
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "TestActivated")
end

if SERVER then
    function ENT:AcceptInput(name, activator, caller, data)
        name = name:lower()
        
        if name == "turnon" or name == "activate" then
            self:Activate(activator)
        elseif name == "turnoff" or name == "deactivate" then
            self:Deactivate()
        elseif name == "toggle" then
            if self:GetTestActivated() then
                self:Deactivate()
            else
                self:Activate(activator)
            end
        end
        
        return true
    end

    function ENT:Activate(activator)
        if self:GetTestActivated() then return end
        
        self:SetTestActivated(true)
        self:SetColor(Color(0, 255, 0)) -- Vert (actif)
        self:EmitSound("buttons/button9.wav")
        
        local activatorName = IsValid(activator) and activator:IsPlayer() and activator:Nick() or "Unknown"
        print("[GP2 Button Test] Activé par: " .. activatorName)
        
        -- Message visible pour le joueur
        if IsValid(activator) and activator:IsPlayer() then
            activator:ChatPrint("[GP2 Test] Bouton ACTIVÉ ✓")
        end
    end

    function ENT:Deactivate()
        if not self:GetTestActivated() then return end
        
        self:SetTestActivated(false)
        self:SetColor(Color(255, 100, 100)) -- Rouge (inactif)
        self:EmitSound("buttons/button10.wav")
        
        print("[GP2 Button Test] Désactivé")
        
        -- Message visible pour tous les joueurs proches
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetPos():Distance(self:GetPos()) < 500 then
                ply:ChatPrint("[GP2 Test] Bouton DÉSACTIVÉ ✗")
            end
        end
    end
    
    function ENT:KeyValue(k, v)
        -- Compatibilité avec les outputs des boutons
        if k:StartsWith("On") then
            self:StoreOutput(k, v)
        end
    end
    
    function ENT:Use(activator, caller, useType, value)
        -- Test manuel avec E
        if self:GetTestActivated() then
            self:Deactivate()
        else
            self:Activate(activator)
        end
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        
        -- Afficher un texte au-dessus de l'entité
        local pos = self:GetPos() + Vector(0, 0, 20)
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        cam.Start3D2D(pos, ang, 0.1)
            local state = self:GetTestActivated()
            draw.SimpleText(
                state and "ACTIF" or "INACTIF", 
                "DermaLarge", 
                0, 0, 
                state and Color(0, 255, 0) or Color(255, 0, 0), 
                TEXT_ALIGN_CENTER, 
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "Entité de test GP2", 
                "DermaDefault", 
                0, -30, 
                Color(255, 255, 255), 
                TEXT_ALIGN_CENTER, 
                TEXT_ALIGN_CENTER
            )
        cam.End3D2D()
    end
end
