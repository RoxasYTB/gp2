-- ----------------------------------------------------------------------------
-- GP2 Framework
-- Start point for whole framework
-- ----------------------------------------------------------------------------



local developer = GetConVar("developer")

local fmt = string.format

GP2_PROJECT_COLOR_THEME = Color(180, 155, 255)
if SERVER then
    GP2_PROJECT_COLOR_THEME_LIGHT = Color(238, 232, 255)
else
    GP2_PROJECT_COLOR_THEME_LIGHT = Color(255, 254, 197)
end

GP2_PROJECT_COLOR_THEME_ERROR = Color(255, 90, 90)
GP2_PROJECT_COLOR_THEME_ERROR_LIGHT = Color(255, 155, 155)
GP2_PROJECT_NAME = '[GP2] '

GP2 = GP2 or {
    --- Print message to console
    --- @param msg string Message
    --- @vararg any Optional params from format string
    Print = function(msg, ...)
        MsgC(GP2_PROJECT_COLOR_THEME, GP2_PROJECT_NAME)
        MsgC(GP2_PROJECT_COLOR_THEME_LIGHT, fmt(msg, ...))
        print()
    end,

    --- Print error message to console (color differs depending on realm)
    --- @param msg string Message
    --- @vararg any Optional params from format string
    Error = function(msg, ...)
        MsgC(GP2_PROJECT_COLOR_THEME, GP2_PROJECT_NAME)
        MsgC(GP2_PROJECT_COLOR_THEME_ERROR_LIGHT, fmt(msg, ...))
        print()
    end,
}

-- Blue (first) portal
PORTAL_TYPE_FIRST = 0
-- Orange (second) portal
PORTAL_TYPE_SECOND = 1

--- Default open duration (size)
PORTAL_OPEN_DURATION = 0.5
--- Default static duration (fill effect)
PORTAL_STATIC_DURATION = 1

--- Default color for first portal
--- @return number, number, number: red, green, blue
PORTAL1_DEFAULT_COLOR = {0, 115, 210}

--- Default color for second portal
--- @return number, number, number: red, green, blue
PORTAL2_DEFAULT_COLOR = {210, 115, 0}

--- Default width for portal
PORTAL_WIDTH = 64

--- Default height for portal
PORTAL_HEIGHT = 112

-- Use unfinished implementation for better portal movement
-- internally tries to build local copy of world mesh for physics
-- with hole
--
-- currently unfinished
-- has noticable lag
PORTAL_USE_NEW_ENVIRONMENT_SYSTEM = false

if PORTAL_USE_NEW_ENVIRONMENT_SYSTEM then
    require("niknaks")
end

include("gp2/globals.lua")
include("gp2/utils.lua")
include("gp2/netmessages.lua")
include("gp2/soundmanager.lua")
include("gp2/particles.lua")
include("gp2/entityextensions.lua")
include("gp2/portalmanager.lua")
include("gp2/portaldetours.lua")
-- Inclure le système de mouvement en fonction de la version
local movementFile = "gp2/portalmovement" .. (PORTAL_USE_NEW_ENVIRONMENT_SYSTEM and "_new" or "_old") .. ".lua"
if file.Exists(movementFile, "LUA") then
    include(movementFile)
else
    print("[GP2] Avertissement: " .. movementFile .. " non trouvé")
end

-- Ajouter les fichiers client
local movementFileCS = "gp2/portalmovement" .. (PORTAL_USE_NEW_ENVIRONMENT_SYSTEM and "_new" or "_old") .. ".lua"
if file.Exists(movementFileCS, "LUA") then
    AddCSLuaFile(movementFileCS)
end
AddCSLuaFile("gp2/globals.lua")
AddCSLuaFile("gp2/utils.lua")
AddCSLuaFile("gp2/netmessages.lua")
AddCSLuaFile("gp2/soundmanager.lua")
AddCSLuaFile("gp2/particles.lua")
AddCSLuaFile("gp2/entityextensions.lua")
AddCSLuaFile("gp2/portalmanager.lua")
AddCSLuaFile("gp2/portaldetours.lua")
AddCSLuaFile("gp2/paint.lua")
AddCSLuaFile("gp2/client/hud.lua")
-- Additional client files for multiplayer
AddCSLuaFile("gp2/client/vgui.lua")
AddCSLuaFile("gp2/client/render.lua")
AddCSLuaFile("gp2/client/portalrendering.lua")
AddCSLuaFile("gp2/gamemovement.lua")
AddCSLuaFile("gp2/version.lua")

-- Add entity files for proper networked loading
-- Note: Entity files are automatically handled by GMod - don't force AddCSLuaFile
AddCSLuaFile("gp2/client/render/env_portal_laser.lua")

-- Ensure critical entity files are properly networked
if SERVER then
    -- Load base_brush entity first to fix derivation errors
    include("entities/base_brush.lua")

    -- Register all entity files for client download
    local entityFiles = file.Find("entities/*.lua", "LUA")
    for _, entFile in ipairs(entityFiles) do
        if string.StartWith(entFile, "prop_") or string.StartWith(entFile, "env_") or string.StartWith(entFile, "npc_") or entFile == "base_brush.lua" then
            AddCSLuaFile("entities/" .. entFile)
        end
    end

    -- Ensure critical entities are specifically registered
    if file.Exists("entities/prop_portal.lua", "LUA") then
        AddCSLuaFile("entities/prop_portal.lua")
    end
    if file.Exists("entities/base_brush.lua", "LUA") then
        AddCSLuaFile("entities/base_brush.lua")
    end

    -- Register HUD element files to fix the empty file errors
    AddCSLuaFile("gp2/client/hudelements/base.lua")
    AddCSLuaFile("gp2/client/hudelements/hud_message.lua")
    AddCSLuaFile("gp2/client/hudelements/hud_quickinfo_portal.lua")
end

local versionFile = "gp2/version.lua"
local success, result = pcall(include, versionFile)
if success and result then
    GP2_VERSION = result
    GP2.Print("Loaded version: %s", GP2_VERSION)
else
    GP2_VERSION = "GP2-SDK v1.0"
    GP2.Print("Using default version string (file: %s)", versionFile)
end

list.Set("ContentCategoryIcons", "Portal 2", "games/16/portal2.png")

-- Fix for entity registration issues in multiplayer
if SERVER then
    -- Delayed entity registration fix for multiplayer
    timer.Simple(1, function()
        -- Force reload critical entities if they failed to register
        if not scripted_ents.Get("prop_portal") then
            GP2.Print("prop_portal not registered, attempting manual registration...")

            -- Try to force reload the entity file
            local entPath = "entities/prop_portal.lua"
            if file.Exists(entPath, "LUA") then
                local entContent = file.Read(entPath, "LUA")
                if entContent and #entContent > 0 then
                    -- Create a sandbox environment for the entity
                    local env = setmetatable({
                        ENT = {},
                        SERVER = SERVER,
                        CLIENT = CLIENT,
                        AddCSLuaFile = AddCSLuaFile,
                        include = include,
                        file = file,
                        timer = timer,
                        -- Add other necessary globals
                        Vector = Vector,
                        Angle = Angle,
                        Color = Color,
                        Material = Material,
                        print = print,
                        GP2 = GP2,
                        MASK_OPAQUE_AND_NPCS = MASK_OPAQUE_AND_NPCS,
                        PropPortal = PropPortal or {},
                        PortalRendering = PortalRendering or {},
                        PORTAL_HEIGHT = PORTAL_HEIGHT,
                        PORTAL_WIDTH = PORTAL_WIDTH,
                        PORTAL_USE_NEW_ENVIRONMENT_SYSTEM = PORTAL_USE_NEW_ENVIRONMENT_SYSTEM,
                        PORTAL_OPEN_DURATION = PORTAL_OPEN_DURATION,
                        PORTAL_STATIC_DURATION = PORTAL_STATIC_DURATION,
                        PORTAL1_DEFAULT_COLOR = PORTAL1_DEFAULT_COLOR,
                        PORTAL2_DEFAULT_COLOR = PORTAL2_DEFAULT_COLOR,
                        PORTAL_TYPE_FIRST = PORTAL_TYPE_FIRST,
                        PORTAL_TYPE_SECOND = PORTAL_TYPE_SECOND
                    }, {__index = _G})

                    local compiled = CompileString(entContent, entPath)
                    if compiled then
                        setfenv(compiled, env)
                        local success, err = pcall(compiled)
                        if success and env.ENT then
                            -- Manually register the entity
                            scripted_ents.Register(env.ENT, "prop_portal")
                            GP2.Print("Successfully registered prop_portal entity")
                        else
                            GP2.Error("Failed to execute prop_portal.lua: %s", err or "unknown error")
                        end
                    else
                        GP2.Error("Failed to compile prop_portal.lua")
                    end
                else
                    GP2.Error("prop_portal.lua is empty or corrupted")
                end
            else
                GP2.Error("prop_portal.lua not found")
            end
        else
            GP2.Print("prop_portal entity already registered")
        end
    end)

    -- Hook pour actualiser les lasers quand les joueurs se connectent
    hook.Add("PlayerInitialSpawn", "GP2::RefreshLasersForNewPlayer", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                -- Forcer l'actualisation de tous les lasers pour le nouveau joueur
                for _, ent in ents.Iterator() do
                    if IsValid(ent) and ent:GetClass() == "env_portal_laser" then
                        -- Forcer la mise à jour de l'état du laser
                        ent:SetState(ent:GetState())
                    end
                end
                GP2.Print("Refreshed lasers for player %s", ply:Nick())
            end
        end)
    end)

    concommand.Add("gp2_print_collision_entity", function(ply)
        if not IsValid(ply) then
            print("Commande à utiliser en tant que joueur.")
            return
        end
        local trace = util.TraceHull({
            start = ply:GetPos(),
            endpos = ply:GetPos() - Vector(0,0,5),
            mins = ply:OBBMins(),
            maxs = ply:OBBMaxs(),
            filter = ply
        })
        if trace.Hit and IsValid(trace.Entity) then
            ply:ChatPrint("[GP2] Collision avec : " .. trace.Entity:GetClass() .. " (" .. tostring(trace.Entity) .. ")")
        else
            ply:ChatPrint("[GP2] Aucune collision détectée sous le joueur.")
        end
    end, nil, "Affiche l'entité en collision sous le joueur.")
    concommand.Add("gp2_print_object_height", function(ply)
        if not IsValid(ply) then
            print("Commande à utiliser en tant que joueur.")
            return
        end
        local trace = ply:GetEyeTrace()
        if trace.Hit and IsValid(trace.Entity) then
            local pos = trace.Entity:GetPos()
            local entName = trace.Entity:GetName() or "(aucun nom)"
            -- Trace vers le bas depuis la position de l'objet
            local tr = util.TraceLine({
                start = pos,
                endpos = pos - Vector(0,0,10000),
                filter = trace.Entity
            })
            local solZ = tr.HitPos.z
            local diff = math.Round(pos.z - solZ, 2)
            local playerZ = math.Round(ply:GetPos().z, 2)
            local diffPlayer = math.Round(pos.z - playerZ, 2)
            ply:ChatPrint("[GP2] Hauteur (Z) de l'objet: " .. math.Round(pos.z, 2) .. " | Nom: " .. entName ..
                "\n[GP2] Hauteur du sol sous l'objet: " .. math.Round(solZ, 2) .. " | Différence: " .. diff ..
                "\n[GP2] Hauteur (Z) du joueur: " .. playerZ .. " | Différence objet-joueur: " .. diffPlayer)
        else
            ply:ChatPrint("[GP2] Aucun objet trouvé devant vous.")
        end
    end, nil, "Affiche la hauteur (Z) de l'objet visé par le joueur et celle du joueur.")
end

-- Cubes
list.Set("SpawnableEntities", "prop_weighted_cube_clean", {
    PrintName = "Cube",
    ClassName = "prop_weighted_cube",
    Category = "Portal 2"
})

list.Set("SpawnableEntities", "prop_weighted_cube_companion", {
    PrintName = "Cube (Companion)",
    ClassName = "prop_weighted_cube",
    Category = "Portal 2",
    KeyValues = { NewSkins = 1, CubeType = 1 }
})

list.Set("SpawnableEntities", "prop_weighted_cube_reflective", {
    PrintName = "Cube (Reflective)",
    ClassName = "prop_weighted_cube",
    Category = "Portal 2",
    KeyValues = { NewSkins = 1, CubeType = 2 }
})

list.Set("SpawnableEntities", "prop_weighted_cube_sphere", {
    PrintName = "Cube (Sphere)",
    ClassName = "prop_weighted_cube",
    Category = "Portal 2",
    KeyValues = { NewSkins = 1, CubeType = 3 }
})

list.Set("SpawnableEntities", "prop_weighted_cube_antique", {
    PrintName = "Cube (Antique)",
    ClassName = "prop_weighted_cube",
    Category = "Portal 2",    KeyValues = { NewSkins = 1, CubeType = 4 }
})

-- Note: prop_portal entity is loaded automatically by Garry's Mod from entities/ folder
-- Don't force include it here as it breaks ENT context

if SERVER then
    -- AcceptInput hooks
    include("gp2/inputsmanager.lua")
    -- EntityKeyValue hooks
    include("gp2/keyvalues.lua")
    -- Vscripts (serverside only)
    include("gp2/vscriptmanager.lua")
    include("gp2/vgui.lua")
    include("gp2/mouthmanager.lua")
    include("gp2/gamemovement.lua")
    include("gp2/portalpvs.lua")
    -- Inclure portalpropteleport seulement s'il existe
    if file.Exists("gp2/portalpropteleport.lua", "LUA") then
        include("gp2/portalpropteleport.lua")
    else
        print("[GP2] Avertissement: gp2/portalpropteleport.lua non trouvé")
    end
    include("gp2/paint.lua")
    include("gp2/client/hud.lua")

    hook.Add("Initialize", "GP2::Initialize", function()
        SoundManager.Initialize()
        MouthManager.Initialize()
    end)

    hook.Add("PlayerSpawn", "GP2::PlayerSpawn", function(ply, transition)
        -- Try to call OnPostPlayerSpawn on all Vscripted entities
        -- and siltently fail if there's no OnPostPlayerSpawn function in script
        -- pass player to scripts to handle logic per player

        GP2.VScriptMgr.CallHookFunction("OnPostPlayerSpawn", true, ply)
    end)

    hook.Add("PlayerInitialSpawn", "GP2::PlayerInitialSpawn", function(ply, transition)
    end)

    local function fixTonemaps()
        timer.Simple(0, function()
            local tonemapCtrls = ents.FindByClass("env_tonemap_controller")

            if #tonemapCtrls == 0 then
                local ctrl = ents.Create("env_tonemap_controller")
                ctrl:Spawn()
                ctrl:Activate()
                table.insert(tonemapCtrls, ctrl)
            end

            for _, ent in ipairs(tonemapCtrls) do
                -- Set to 1, triggers reroute in inputsmanager.lua
                ent:Input("setbloomscale", NULL, NULL, 1)
            end
        end)
    end

    function fixPortalColors()
        timer.Simple(2, function()
            for _, portal in ipairs(ents.FindByClass("prop_portal")) do
                -- Vérifier si la méthode existe avant de l'appeler
                local isMapPortal = false
                if portal.GetPlacedByMap and isfunction(portal.GetPlacedByMap) then
                    isMapPortal = portal:GetPlacedByMap()
                end

                if isMapPortal then
                    local firstPlayer = Entity(1)
                    if IsValid(firstPlayer) then
                        local portalType = (portal.GetType and portal:GetType()) or 1
                        local info = firstPlayer:GetInfo("gp2_portal_color" .. (portalType + 1))
                        local colorString = info or "255 255 255"
                        local colorTable = string.Split(colorString, " ")
                        local r, g, b = tonumber(colorTable[1]) or 255, tonumber(colorTable[2]) or 255, tonumber(colorTable[3]) or 255

                        if portal.SetPortalColor and isfunction(portal.SetPortalColor) then
                            portal:SetPortalColor(r, g, b)
                        end
                    end
                end
            end
        end)
    end

    hook.Add("PostCleanupMap", "GP2::PostCleanupMap", function()
        GP2.VScriptMgr.InitializeScriptForEntity(game.GetWorld(), "mapspawn")
        GP2.VScriptMgr.CallHookFunction("OnPostSpawn", true)

        PaintManager.Initialize()

        fixTonemaps()
        fixPortalColors()
    end)

    hook.Add("InitPostEntity", "GP2::InitPostEntity", function()
        GP2.VScriptMgr.InitializeScriptForEntity(game.GetWorld(), "mapspawn")
        GP2.VScriptMgr.CallHookFunction("OnPostSpawn", true)

        PaintManager.Initialize()

        fixTonemaps()
        fixPortalColors()
    end)

    hook.Add("Think", "GP2::Think", function()
        GP2.VScriptMgr.Think()
        -- SoundManager.Think()
        MouthManager.Think()
    end)

    hook.Add("PlayerTick", "GP2::PlayerTick", function(ply, mv)
        if not ply:Alive() then return end

        if IsValid(ply:GetViewEntity()) and ply:GetViewEntity():GetClass() == "point_viewcontrol" then
            ply:SetMoveType(MOVETYPE_NONE)
            ply:AddEffects(EF_NODRAW)
            ply.FrozenByCamera = true
        elseif ply.FrozenByCamera then
            ply:SetMoveType(MOVETYPE_WALK)
            ply:RemoveEffects(EF_NODRAW)
            ply.FrozenByCamera = nil
        end
    end)

    hook.Add("OnPlayerJump", "GP2::OnPlayerJump", function(ply, speed)
        for _, proxy in ipairs(ents.FindByClass("logic_playerproxy")) do
            proxy:TriggerOutput("OnJump", ply)
        end
    end)

    hook.Add("PhysgunPickup", "GP2::PhysgunPickup", function(ply, ent)
        if ent.OnPhysgunPickup and isfunction(ent.OnPhysgunPickup) then
            return ent:OnPhysgunPickup(ply)
        end
    end)

    hook.Add("PhysgunDrop", "GP2::PhysgunDrop", function(ply, ent)
        if ent.OnPhysgunDrop and isfunction(ent.OnPhysGunDrop) then
            ent:OnPhysGunDrop(ply)
        end
    end)

    hook.Add("OnPlayerPhysicsPickup", "GP2::OnPlayerPhysicsPickup", function(ply, ent)
        if ent.OnPlayerPickup and isfunction(ent.OnPlayerPickup) then
            ent:OnPlayerPickup(ply)
        end
    end)

    hook.Add("OnPlayerPhysicsDrop", "GP2::OnPlayerPhysicsDrop", function(ply, ent, thrown)
        if ent.OnPlayerDrop and isfunction(ent.OnPlayerDrop) then
            ent:OnPlayerDrop(ply, thrown)
        end
    end)

    hook.Add("GravGunOnPickedUp", "GP2::GravGunOnPickedUp", function(ply, ent)
        if ent.OnGravGunPickup and isfunction(ent.OnGravGunPickup) then
            ent:OnGravGunPickup(ply)
        end
    end)

    hook.Add("GravGunOnDropped", "GP2::GravGunOnDropped", function(ply, ent)
        if ent.OnGravGunDrop and isfunction(ent.OnGravGunDrop) then
            ent:OnGravGunDrop(ply)
        end
    end)

    hook.Add("GravGunPunt", "GP2::GravGunPunt", function(ply, ent)
        if ent.OnGravGunPunt and isfunction(ent.OnGravGunPunt) then
            return ent:OnGravGunPunt(ply)
        end
    end)

    hook.Add("PlayerFootstep", "GP2::PlayerFootsteps", function(ply, pos, foot, sound, volume, rf)
        if ply:GetGroundEntity() ~= NULL then
            ply._PreviousGroundEnt = ply:GetGroundEntity()
        end

        if ply._PreviousGroundEnt and IsValid(ply._PreviousGroundEnt) and ply._PreviousGroundEnt:GetClass() == "projected_wall_entity" then
            ply:EmitSound("Lightbridge.Step" .. (foot and "Right" or "Left"))
            return true
        end
    end)

    hook.Add("EntityEmitSound", "GP2::EntityEmitSound", function(data)
        local name = data.OriginalSoundName
        local file_path = data.SoundName
        local level = data.SoundLevel
        local ent = data.Entity
        local pos = data.Pos
        local duration = SoundDuration(data.SoundName)

        SoundManager.EntityEmitSound(name, ent, level, pos, duration)
        MouthManager.EmitSound(ent, file_path)
    end)

    net.Receive(GP2.Net.SendLoadedToServer, function(len, ply)
        local whom = net.ReadEntity()
        --GP2.Print("Player " .. tostring(whom) .. " loaded on server!")

        if whom == Entity(1) then
            GP2.VScriptMgr.CallHookFunction("OnPostSpawn", true)
        end
    end)
else
    if CLIENT then
        -- Initialize global tables early to prevent nil index errors in entities
        -- These tables are normally defined in client render/vgui files but entities may load first
        ProjectedWallEntity = ProjectedWallEntity or {}
        PropTractorBeam = PropTractorBeam or {}
        VguiMovieDisplay = VguiMovieDisplay or {}
        VguiSPProgressSign = VguiSPProgressSign or {}

        -- Basic stub functions to prevent immediate errors
        ProjectedWallEntity.IsAdded = ProjectedWallEntity.IsAdded or function() return false end
        ProjectedWallEntity.AddToRenderList = ProjectedWallEntity.AddToRenderList or function() end

        PropTractorBeam.IsAdded = PropTractorBeam.IsAdded or function() return false end
        PropTractorBeam.AddToRenderList = PropTractorBeam.AddToRenderList or function() end

        VguiMovieDisplay.IsAddedDisplay = VguiMovieDisplay.IsAddedDisplay or function() return false end
        VguiMovieDisplay.AddDisplay = VguiMovieDisplay.AddDisplay or function() end

        VguiSPProgressSign.IsAddedSign = VguiSPProgressSign.IsAddedSign or function() return false end
        VguiSPProgressSign.AddSign = VguiSPProgressSign.AddSign or function() end
    end

    hook.Add("Initialize", "GP2::Initialize", function()
        SoundManager.Initialize()
    end)      -- Protected includes for client-side files with pcall
    local clientFiles = {
        "gp2/client/render.lua",  -- Load render system first
        "gp2/client/hud.lua",    -- Load HUD (includes fonts) before VGUI
        "gp2/client/vgui.lua",
        "gp2/client/portalrendering.lua",
        "gp2/gamemovement.lua"
    }

    -- Add a small delay to ensure networking is ready
    timer.Simple(0.1, function()
        for _, filePath in ipairs(clientFiles) do
            if file.Exists(filePath, "LUA") then
                local success, err = pcall(include, filePath)
                if not success then
                    GP2.Print("Could not load client file %s: %s", filePath, err or "unknown error")
                else
                    GP2.Print("Successfully loaded client file: %s", filePath)
                end
            else
                GP2.Print("Client file not found: %s", filePath)
            end
        end    end)    hook.Add("Think", "GP2::Think", function()
        SoundManager.Think()
    end)

    -- Hook pour s'assurer que les tractor beams sont correctement initialisés
    hook.Add("InitPostEntity", "GP2::InitTractorBeams", function()
        timer.Simple(1, function() -- Délai pour s'assurer que tout est chargé
            for _, ent in ipairs(ents.FindByClass("projected_tractor_beam_entity")) do
                if IsValid(ent) then
                    ent:SetUpdated(false) -- Force la mise à jour du beam
                end
            end
        end)
    end)

    -- Hook pour gérer l'intégration des portails avec PortalManager
    hook.Add("OnEntityCreated", "GP2::Portal::OnEntityCreated", function(ent)
        if IsValid(ent) and ent:GetClass() == "prop_portal" then
            -- Petit délai pour laisser l'entité s'initialiser complètement
            timer.Simple(0.1, function()
                if IsValid(ent) and ent.GetType and ent.GetActivated then
                    -- S'assurer que le portail est intégré au PortalManager
                    if ent:GetActivated() then
                        -- Utiliser linkage group 0 par défaut pour la compatibilité
                        PortalManager.SetPortal(0, ent)
                        GP2.Print("Portal integrated with PortalManager: %s (type %s)", tostring(ent), tostring(ent:GetType()))
                    end
                end
            end)
        end
    end)

    -- Fonction pour recharger les scripts clients critiques
    local function ReloadClientScripts()
        local clientFiles = {
            "entities/env_portal_laser/cl_init.lua",
            -- Ajouter ici d'autres fichiers à recharger si besoin
        }
        for _, file in ipairs(clientFiles) do
            pcall(include, file)
        end
    end

    -- Commande console pour forcer le reload
    concommand.Add("gp2_reload_client_scripts", function()
        ReloadClientScripts()
    end, nil, "Recharge les scripts clients GP2 (visuel laser, etc.)")

    -- Hook pour recharger automatiquement après le chargement des entités
    hook.Add("InitPostEntity", "GP2_ReloadClientScripts", function()
        timer.Simple(0.5, ReloadClientScripts)
    end)
    -- Hook pour recharger après nettoyage map
    hook.Add("PostCleanupMap", "GP2_ReloadClientScripts_Cleanup", function()
        timer.Simple(0.5, ReloadClientScripts)
    end)
end
