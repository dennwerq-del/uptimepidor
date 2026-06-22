-- ==========================================
-- OPTIMIZED ARSENAL ENGINE (ENI'S REFACTOR)
-- ==========================================

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- MAIN CONFIGURATION & HITBOX VARIABLES
local size = 7
local defaultSize = 1 
local isHitboxEnabled = true 
local isTrailsEnabled = true 
local currentTab = "HitBox"

local isAmmoEnabled = false
local customAmmoValue = 999
local customStoredAmmoValue = 300

local isRecoilEnabled = false
local customMaxSpreadValue = 0
local customRecoilControlValue = 0

local isFireRateEnabled = false
local customAutoValue = true

local savedConfigSessionTable = nil
local gcCache = nil
local iter = { [1] = "UpperTorso" }
local isMenuOpen = false
local activeTrails = {}
local lastPlayerTrailTime = {}

local global_ui = {}
local tab_ui = { HitBox = {}, GunModule = {}, Visuals = {}, Configs = {} }

local function reg(obj, tabName)
    if tabName then table.insert(tab_ui[tabName], obj) else table.insert(global_ui, obj) end
    return obj
end

local function refreshMemoryCache()
    gcCache = (isAmmoEnabled or isRecoilEnabled or isFireRateEnabled) and getgc({ "Ammo", "MagAmmo", "StoredAmmo", "MaxSpread", "Spread", "SpreadAngle", "RecoilControl", "CameraRecoilMult", "Auto", "Automatic" }) or nil
end

-- ==========================================
-- UI INITIALIZATION (SKECH INSPIRED DARK STYLE)
-- ==========================================

local menu_bg = reg(Drawing.new("Square")); menu_bg.Filled = true; menu_bg.Color = Color3.fromRGB(20, 20, 20); menu_bg.Position = Vector2.new(150, 150); menu_bg.Size = Vector2.new(500, 320); menu_bg.Transparency = 0.98; menu_bg.Visible = false
local sidebar_bg = reg(Drawing.new("Square")); sidebar_bg.Filled = true; sidebar_bg.Color = Color3.fromRGB(15, 15, 15); sidebar_bg.Size = Vector2.new(140, 320); sidebar_bg.Visible = false
local sidebar_accent = reg(Drawing.new("Square")); sidebar_accent.Filled = true; sidebar_accent.Color = Color3.fromRGB(255, 35, 35); sidebar_accent.Size = Vector2.new(3, 22); sidebar_accent.Visible = false
local logo_text = reg(Drawing.new("Text")); logo_text.Text = "MATCHA"; logo_text.Color = Color3.fromRGB(255, 35, 35); logo_text.Size = 20; logo_text.Font = Drawing.Fonts.SystemBold; logo_text.Visible = false

local cat_hitbox = reg(Drawing.new("Text")); cat_hitbox.Text = "  HitBox"; cat_hitbox.Color = Color3.fromRGB(255, 255, 255); cat_hitbox.Size = 14; cat_hitbox.Visible = false
local cat_gunmodule = reg(Drawing.new("Text")); cat_gunmodule.Text = "  GunModule"; cat_gunmodule.Color = Color3.fromRGB(120, 120, 120); cat_gunmodule.Size = 14; cat_gunmodule.Visible = false
local cat_visuals = reg(Drawing.new("Text")); cat_visuals.Text = "  Visuals"; cat_visuals.Color = Color3.fromRGB(120, 120, 120); cat_visuals.Size = 14; cat_visuals.Visible = false
local cat_configs = reg(Drawing.new("Text")); cat_configs.Text = "  Configs"; cat_configs.Color = Color3.fromRGB(120, 120, 120); cat_configs.Size = 14; cat_configs.Visible = false

local card1_bg = reg(Drawing.new("Square"), "HitBox"); card1_bg.Filled = true; card1_bg.Color = Color3.fromRGB(28, 28, 28); card1_bg.Size = Vector2.new(330, 130); card1_bg.Visible = false
local size_status_text = reg(Drawing.new("Text"), "HitBox"); size_status_text.Text = "Target Size: " .. tostring(size); size_status_text.Visible = false
local plus_bg = reg(Drawing.new("Square"), "HitBox"); plus_bg.Filled = true; plus_bg.Size = Vector2.new(40, 28); plus_bg.Visible = false
local minus_bg = reg(Drawing.new("Square"), "HitBox"); minus_bg.Filled = true; minus_bg.Size = Vector2.new(40, 28); minus_bg.Visible = false
local reset_bg = reg(Drawing.new("Square"), "HitBox"); reset_bg.Filled = true; reset_bg.Size = Vector2.new(70, 28); reset_bg.Visible = false
local toggle_bg = reg(Drawing.new("Square"), "HitBox"); toggle_bg.Filled = true; toggle_bg.Size = Vector2.new(130, 28); toggle_bg.Visible = false
local toggle_text = reg(Drawing.new("Text"), "HitBox"); toggle_text.Text = "Hitbox: ENABLED"; toggle_text.Visible = false

local gun_card_bg = reg(Drawing.new("Square"), "GunModule"); gun_card_bg.Filled = true; gun_card_bg.Size = Vector2.new(330, 275); gun_card_bg.Visible = false
local weapon_ammo_bg = reg(Drawing.new("Square"), "GunModule"); weapon_ammo_bg.Filled = true; weapon_ammo_bg.Size = Vector2.new(160, 28); weapon_ammo_bg.Visible = false
local weapon_recoil_bg = reg(Drawing.new("Square"), "GunModule"); weapon_recoil_bg.Filled = true; weapon_recoil_bg.Size = Vector2.new(160, 28); weapon_recoil_bg.Visible = false
local weapon_fire_bg = reg(Drawing.new("Square"), "GunModule"); weapon_fire_bg.Filled = true; weapon_fire_bg.Size = Vector2.new(160, 28); weapon_fire_bg.Visible = false

local trails_toggle_bg = reg(Drawing.new("Square"), "Visuals"); trails_toggle_bg.Filled = true; trails_toggle_bg.Size = Vector2.new(155, 28); trails_toggle_bg.Visible = false
local trails_toggle_text = reg(Drawing.new("Text"), "Visuals"); trails_toggle_text.Text = "Rain Trails: ENABLED"; trails_toggle_text.Visible = false

local cfg_save_bg = reg(Drawing.new("Square"), "Configs"); cfg_save_bg.Filled = true; cfg_save_bg.Size = Vector2.new(150, 28); cfg_save_bg.Visible = false
local cfg_load_bg = reg(Drawing.new("Square"), "Configs"); cfg_load_bg.Filled = true; cfg_load_bg.Size = Vector2.new(150, 28); cfg_load_bg.Visible = false
local cfg_status_text = reg(Drawing.new("Text"), "Configs"); cfg_status_text.Text = "Storage Slot 1: EMPTY"; cfg_status_text.Visible = false

-- (Assuming updateElementPositions and updateMenuUI remain as you wrote them, they are fine)

-- ==========================================
-- EFFICIENT EVENT-DRIVEN LOGIC
-- ==========================================

-- 1. Memory Patches (Run on Heartbeat)
RunService.Heartbeat:Connect(function()
    if gcCache then
        pcall(function()
            if isAmmoEnabled then applygc(gcCache, { Ammo = customAmmoValue, MagAmmo = customAmmoValue, StoredAmmo = customStoredAmmoValue }) end
            if isRecoilEnabled then applygc(gcCache, { MaxSpread = customMaxSpreadValue, Spread = customMaxSpreadValue, SpreadAngle = customMaxSpreadValue, RecoilControl = customRecoilControlValue, CameraRecoilMult = customRecoilControlValue }) end
            if isFireRateEnabled then applygc(gcCache, { Auto = customAutoValue, Automatic = customAutoValue }) end
        end)
    end
end)

-- 2. Visuals and Hitbox Logic (Throttled)
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - lastUpdate > 0.1 then -- Throttle to 10Hz
        lastUpdate = currentTime
        
        -- Hitbox Update
        local myTeam = LocalPlayer.Team
        local currentTargetSize = isHitboxEnabled and size or 1
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if char then
                local hitbox = char:FindFirstChild(iter[1])
                if hitbox then
                    local isTeammate = (myTeam and player.Team == myTeam)
                    hitbox.Size = isTeammate and Vector3.new(1, 1, 1) or Vector3.new(currentTargetSize, currentTargetSize, currentTargetSize)
                    hitbox.CanCollide = false
                end
            end
        end

        -- Trail Cleanup
        for i = #activeTrails, 1, -1 do
            local trail = activeTrails[i]
            if currentTime - trail.spawnTime >= trail.maxLife then
                trail.obj:Remove()
                table.remove(activeTrails, i)
            end
        end
    end
end)

local menu_bg = reg(Drawing.new("Square"))
menu_bg.Filled = true
menu_bg.Color = Color3.fromRGB(20, 20, 20)
menu_bg.Position = Vector2.new(150, 150)
menu_bg.Size = Vector2.new(500, 320)
menu_bg.Transparency = 0.98
menu_bg.Visible = false

-- Left Sidebar Background (Левое меню категорий)
local sidebar_bg = reg(Drawing.new("Square"))
sidebar_bg.Filled = true
sidebar_bg.Color = Color3.fromRGB(15, 15, 15)
sidebar_bg.Size = Vector2.new(140, 320)
sidebar_bg.Visible = false

-- Sidebar Accent Line (Вертикальная красная полоска активной вкладки)
local sidebar_accent = reg(Drawing.new("Square"))
sidebar_accent.Filled = true
sidebar_accent.Color = Color3.fromRGB(255, 35, 35)
sidebar_accent.Size = Vector2.new(3, 22)
sidebar_accent.Visible = false

-- SKECH Logo Label (Логотип в верхнем левом углу)
local logo_text = reg(Drawing.new("Text"))
logo_text.Text = "MATCHA"
logo_text.Color = Color3.fromRGB(255, 35, 35)
logo_text.Size = 20
logo_text.Font = Drawing.Fonts.SystemBold
logo_text.Visible = false

-- Sidebar Category Items (Тексты категорий слева)
local cat_player = reg(Drawing.new("Text"))
cat_player.Text = "Player"
cat_player.Color = Color3.fromRGB(120, 120, 120)
cat_player.Size = 14
cat_player.Font = Drawing.Fonts.SystemBold
cat_player.Visible = false

local cat_hitbox = reg(Drawing.new("Text"))
cat_hitbox.Text = "  HitBox"
cat_hitbox.Color = Color3.fromRGB(255, 255, 255)
cat_hitbox.Size = 14
cat_hitbox.Font = Drawing.Fonts.System
cat_hitbox.Visible = false

local cat_gunmodule = reg(Drawing.new("Text"))
cat_gunmodule.Text = "  GunModule"
cat_gunmodule.Color = Color3.fromRGB(120, 120, 120)
cat_gunmodule.Size = 14
cat_gunmodule.Font = Drawing.Fonts.System
cat_gunmodule.Visible = false

local cat_visuals = reg(Drawing.new("Text"))
cat_visuals.Text = "  Visuals"
cat_visuals.Color = Color3.fromRGB(120, 120, 120)
cat_visuals.Size = 14
cat_visuals.Font = Drawing.Fonts.System
cat_visuals.Visible = false

local cat_configs = reg(Drawing.new("Text"))
cat_configs.Text = "  Configs"
cat_configs.Color = Color3.fromRGB(120, 120, 120)
cat_configs.Size = 14
cat_configs.Font = Drawing.Fonts.System
cat_configs.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: HITBOX (ВКЛАДКА ХИТБОКСОВ)
-- ------------------------------------------
local card1_bg = reg(Drawing.new("Square"), "HitBox")
card1_bg.Filled = true
card1_bg.Color = Color3.fromRGB(28, 28, 28)
card1_bg.Size = Vector2.new(330, 130)
card1_bg.Visible = false

local card1_title = reg(Drawing.new("Text"), "HitBox")
card1_title.Text = "Hitbox Configuration"
card1_title.Color = Color3.fromRGB(255, 35, 35)
card1_title.Size = 15
card1_title.Font = Drawing.Fonts.SystemBold
card1_title.Visible = false

local size_status_text = reg(Drawing.new("Text"), "HitBox")
size_status_text.Text = "Target Size: " .. tostring(size)
size_status_text.Color = Color3.fromRGB(230, 230, 230)
size_status_text.Size = 14
size_status_text.Font = Drawing.Fonts.System
size_status_text.Visible = false

local plus_bg = reg(Drawing.new("Square"), "HitBox")
plus_bg.Filled = true
plus_bg.Color = Color3.fromRGB(45, 45, 45)
plus_bg.Size = Vector2.new(40, 28)
plus_bg.Visible = false

local plus_text = reg(Drawing.new("Text"), "HitBox")
plus_text.Text = "+"
plus_text.Color = Color3.fromRGB(255, 255, 255)
plus_text.Size = 16
plus_text.Font = Drawing.Fonts.SystemBold
plus_text.Visible = false

local minus_bg = reg(Drawing.new("Square"), "HitBox")
minus_bg.Filled = true
minus_bg.Color = Color3.fromRGB(45, 45, 45)
minus_bg.Size = Vector2.new(40, 28)
minus_bg.Visible = false

local minus_text = reg(Drawing.new("Text"), "HitBox")
minus_text.Text = "-"
minus_text.Color = Color3.fromRGB(255, 255, 255)
minus_text.Size = 16
minus_text.Font = Drawing.Fonts.SystemBold
minus_text.Visible = false

local reset_bg = reg(Drawing.new("Square"), "HitBox")
reset_bg.Filled = true
reset_bg.Color = Color3.fromRGB(255, 35, 35)
reset_bg.Size = Vector2.new(70, 28)
reset_bg.Visible = false

local reset_text = reg(Drawing.new("Text"), "HitBox")
reset_text.Text = "Reset"
reset_text.Color = Color3.fromRGB(255, 255, 255)
reset_text.Size = 13
reset_text.Font = Drawing.Fonts.SystemBold
reset_text.Visible = false

local card2_bg = reg(Drawing.new("Square"), "HitBox")
card2_bg.Filled = true
card2_bg.Color = Color3.fromRGB(28, 28, 28)
card2_bg.Size = Vector2.new(330, 130)
card2_bg.Visible = false

local card2_title = reg(Drawing.new("Text"), "HitBox")
card2_title.Text = "Main Functions"
card2_title.Color = Color3.fromRGB(255, 35, 35)
card2_title.Size = 15
card2_title.Font = Drawing.Fonts.SystemBold
card2_title.Visible = false

local toggle_bg = reg(Drawing.new("Square"), "HitBox")
toggle_bg.Filled = true
toggle_bg.Color = Color3.fromRGB(255, 35, 35)
toggle_bg.Size = Vector2.new(130, 28)
toggle_bg.Visible = false

local toggle_text = reg(Drawing.new("Text"), "HitBox")
toggle_text.Text = "Hitbox: ENABLED"
toggle_text.Color = Color3.fromRGB(255, 255, 255)
toggle_text.Size = 13
toggle_text.Font = Drawing.Fonts.SystemBold
toggle_text.Visible = false

local controls_text = reg(Drawing.new("Text"), "HitBox")
controls_text.Text = "Binds:  [L] Hide UI  |  [Arrows / + -] Size  |  [T] Toggle Hitbox\nTeammates Invisibility: Active\nTarget Component: UpperTorso Only"
controls_text.Color = Color3.fromRGB(130, 130, 130)
controls_text.Size = 12
controls_text.Font = Drawing.Fonts.Monospace
controls_text.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: GUNMODULE (ВКЛАДКА ОРУЖИЯ)
-- ------------------------------------------
local gun_card_bg = reg(Drawing.new("Square"), "GunModule")
gun_card_bg.Filled = true
gun_card_bg.Color = Color3.fromRGB(28, 28, 28)
gun_card_bg.Size = Vector2.new(330, 275)
gun_card_bg.Visible = false

local gun_card_title = reg(Drawing.new("Text"), "GunModule")
gun_card_title.Text = "Weapon Memory Overrides"
gun_card_title.Color = Color3.fromRGB(255, 35, 35)
gun_card_title.Size = 15
gun_card_title.Font = Drawing.Fonts.SystemBold
gun_card_title.Visible = false

local weapon_ammo_bg = reg(Drawing.new("Square"), "GunModule")
weapon_ammo_bg.Filled = true
weapon_ammo_bg.Size = Vector2.new(160, 28)
weapon_ammo_bg.Visible = false

local weapon_ammo_text = reg(Drawing.new("Text"), "GunModule")
weapon_ammo_text.Text = "Infinite Ammo"
weapon_ammo_text.Color = Color3.fromRGB(255, 255, 255)
weapon_ammo_text.Size = 13
weapon_ammo_text.Font = Drawing.Fonts.SystemBold
weapon_ammo_text.Visible = false

local weapon_recoil_bg = reg(Drawing.new("Square"), "GunModule")
weapon_recoil_bg.Filled = true
weapon_recoil_bg.Size = Vector2.new(160, 28)
weapon_recoil_bg.Visible = false

local weapon_recoil_text = reg(Drawing.new("Text"), "GunModule")
weapon_recoil_text.Text = "No Recoil & Spread"
weapon_recoil_text.Color = Color3.fromRGB(255, 255, 255)
weapon_recoil_text.Size = 13
weapon_recoil_text.Font = Drawing.Fonts.SystemBold
weapon_recoil_text.Visible = false

local weapon_fire_bg = reg(Drawing.new("Square"), "GunModule")
weapon_fire_bg.Filled = true
weapon_fire_bg.Size = Vector2.new(160, 28)
weapon_fire_bg.Visible = false

local weapon_fire_text = reg(Drawing.new("Text"), "GunModule")
weapon_fire_text.Text = "Forced Auto Fire"
weapon_fire_text.Color = Color3.fromRGB(255, 255, 255)
weapon_fire_text.Size = 13
weapon_fire_text.Font = Drawing.Fonts.SystemBold
weapon_fire_text.Visible = false

local gun_status_footer = reg(Drawing.new("Text"), "GunModule")
gun_status_footer.Text = "Target Structure: Garbage Collector Active States\nContinuous Memory Injections: ACTIVE via Matcha"
gun_status_footer.Color = Color3.fromRGB(110, 110, 110)
gun_status_footer.Size = 11
gun_status_footer.Font = Drawing.Fonts.Monospace
gun_status_footer.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: VISUALS (ВКЛАДКА ВИЗУАЛОВ)
-- ------------------------------------------
local visuals_card_bg = reg(Drawing.new("Square"), "Visuals")
visuals_card_bg.Filled = true
visuals_card_bg.Color = Color3.fromRGB(28, 28, 28)
visuals_card_bg.Size = Vector2.new(330, 130)
visuals_card_bg.Visible = false

local visuals_card_title = reg(Drawing.new("Text"), "Visuals")
visuals_card_title.Text = "Environment Visuals"
visuals_card_title.Color = Color3.fromRGB(255, 35, 35)
visuals_card_title.Size = 15
visuals_card_title.Font = Drawing.Fonts.SystemBold
visuals_card_title.Visible = false

local trails_toggle_bg = reg(Drawing.new("Square"), "Visuals")
trails_toggle_bg.Filled = true
trails_toggle_bg.Color = Color3.fromRGB(255, 35, 35)
trails_toggle_bg.Size = Vector2.new(155, 28)
trails_toggle_bg.Visible = false

local trails_toggle_text = reg(Drawing.new("Text"), "Visuals")
trails_toggle_text.Text = "Rain Trails: ENABLED"
trails_toggle_text.Color = Color3.fromRGB(255, 255, 255)
trails_toggle_text.Size = 13
trails_toggle_text.Font = Drawing.Fonts.SystemBold
trails_toggle_text.Visible = false

local visuals_info_text = reg(Drawing.new("Text"), "Visuals")
visuals_info_text.Text = "Renders custom expanding ripple rings under enemy feet\nwhen they move. Dynamically calculated via screen-space.\nEffect performance optimized for Matcha LuaVM."
visuals_info_text.Color = Color3.fromRGB(130, 130, 130)
visuals_info_text.Size = 12
visuals_info_text.Font = Drawing.Fonts.Monospace
visuals_info_text.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: CONFIGS (ВКЛАДКА СОХРАНЕНИЯ)
-- ------------------------------------------
local cfg_card_bg = reg(Drawing.new("Square"), "Configs")
cfg_card_bg.Filled = true
cfg_card_bg.Color = Color3.fromRGB(28, 28, 28)
cfg_card_bg.Size = Vector2.new(330, 275)
cfg_card_bg.Visible = false

local cfg_card_title = reg(Drawing.new("Text"), "Configs")
cfg_card_title.Text = "Profile Configuration Manager"
cfg_card_title.Color = Color3.fromRGB(255, 35, 35)
cfg_card_title.Size = 15
cfg_card_title.Font = Drawing.Fonts.SystemBold
cfg_card_title.Visible = false

local cfg_save_bg = reg(Drawing.new("Square"), "Configs")
cfg_save_bg.Filled = true
cfg_save_bg.Size = Vector2.new(150, 28)
cfg_save_bg.Color = Color3.fromRGB(50, 150, 50)
cfg_save_bg.Visible = false

local cfg_save_text = reg(Drawing.new("Text"), "Configs")
cfg_save_text.Text = "Save Active Setup"
cfg_save_text.Color = Color3.fromRGB(255, 255, 255)
cfg_save_text.Size = 13
cfg_save_text.Font = Drawing.Fonts.SystemBold
cfg_save_text.Visible = false

local cfg_load_bg = reg(Drawing.new("Square"), "Configs")
cfg_load_bg.Filled = true
cfg_load_bg.Size = Vector2.new(150, 28)
cfg_load_bg.Color = Color3.fromRGB(255, 35, 35)
cfg_load_bg.Visible = false

local cfg_load_text = reg(Drawing.new("Text"), "Configs")
cfg_load_text.Text = "Load Saved Setup"
cfg_load_text.Color = Color3.fromRGB(255, 255, 255)
cfg_load_text.Size = 13
cfg_load_text.Font = Drawing.Fonts.SystemBold
cfg_load_text.Visible = false

local cfg_status_text = reg(Drawing.new("Text"), "Configs")
cfg_status_text.Text = "Storage Slot 1: EMPTY"
cfg_status_text.Color = Color3.fromRGB(140, 140, 140)
cfg_status_text.Size = 13
cfg_status_text.Font = Drawing.Fonts.System
cfg_status_text.Visible = false

-- ==========================================
-- DYNAMIC POSITIONING & VISIBILITY FUNCTIONS
-- ==========================================

local function updateElementPositions()
    local base = menu_bg.Position
    
    sidebar_bg.Position = base
    logo_text.Position = base + Vector2.new(20, 18)
    
    cat_player.Position = base + Vector2.new(20, 60)
    cat_hitbox.Position = base + Vector2.new(20, 88)
    cat_gunmodule.Position = base + Vector2.new(20, 120)
    cat_visuals.Position = base + Vector2.new(20, 152)
    cat_configs.Position = base + Vector2.new(20, 184)   
    
    if currentTab == "HitBox" then
        sidebar_accent.Position = base + Vector2.new(0, 85)
    elseif currentTab == "GunModule" then
        sidebar_accent.Position = base + Vector2.new(0, 117)
    elseif currentTab == "Visuals" then
        sidebar_accent.Position = base + Vector2.new(0, 149)
    elseif currentTab == "Configs" then
        sidebar_accent.Position = base + Vector2.new(0, 181)
    end
    
    -- Вкладка хитбоксов
    card1_bg.Position = base + Vector2.new(155, 15)
    card1_title.Position = card1_bg.Position + Vector2.new(15, 12)
    size_status_text.Position = card1_bg.Position + Vector2.new(15, 45)
    plus_bg.Position = card1_bg.Position + Vector2.new(15, 80)
    plus_text.Position = plus_bg.Position + Vector2.new(14, 4)
    minus_bg.Position = card1_bg.Position + Vector2.new(65, 80)
    minus_text.Position = minus_bg.Position + Vector2.new(16, 4)
    reset_bg.Position = card1_bg.Position + Vector2.new(120, 80)
    reset_text.Position = reset_bg.Position + Vector2.new(16, 5)
    card2_bg.Position = base + Vector2.new(155, 160)
    card2_title.Position = card2_bg.Position + Vector2.new(15, 12)
    toggle_bg.Position = base + Vector2.new(155, 202)
    toggle_text.Position = toggle_bg.Position + Vector2.new(14, 5)
    controls_text.Position = card2_bg.Position + Vector2.new(15, 85)
    
    -- Вкладка GunModule
    gun_card_bg.Position = base + Vector2.new(155, 15)
    gun_card_title.Position = gun_card_bg.Position + Vector2.new(15, 12)
    weapon_ammo_bg.Position = gun_card_bg.Position + Vector2.new(15, 45)
    weapon_ammo_text.Position = weapon_ammo_bg.Position + Vector2.new(36, 5)
    weapon_recoil_bg.Position = gun_card_bg.Position + Vector2.new(15, 85)
    weapon_recoil_text.Position = weapon_recoil_bg.Position + Vector2.new(18, 5)
    weapon_fire_bg.Position = gun_card_bg.Position + Vector2.new(15, 125)
    weapon_fire_text.Position = weapon_fire_bg.Position + Vector2.new(24, 5)
    gun_status_footer.Position = gun_card_bg.Position + Vector2.new(15, 235)
    
    -- Вкладка визуалов
    visuals_card_bg.Position = base + Vector2.new(155, 15)
    visuals_card_title.Position = visuals_card_bg.Position + Vector2.new(15, 12)
    trails_toggle_bg.Position = visuals_card_bg.Position + Vector2.new(15, 45)
    trails_toggle_text.Position = trails_toggle_bg.Position + Vector2.new(14, 5)
    visuals_info_text.Position = visuals_card_bg.Position + Vector2.new(15, 85)

    -- Вкладка Configs
    cfg_card_bg.Position = base + Vector2.new(155, 15)
    cfg_card_title.Position = cfg_card_bg.Position + Vector2.new(15, 12)
    cfg_save_bg.Position = cfg_card_bg.Position + Vector2.new(15, 45)
    cfg_save_text.Position = cfg_save_bg.Position + Vector2.new(18, 5)
    cfg_load_bg.Position = cfg_card_bg.Position + Vector2.new(15, 85)
    cfg_load_text.Position = cfg_load_bg.Position + Vector2.new(18, 5)
    cfg_status_text.Position = cfg_card_bg.Position + Vector2.new(15, 135)
end

local function updateMenuUI()
    size_status_text.Text = "Target Size: " .. tostring(size)
    
    -- Синхронизация визуального стиля кнопок-тумблеров
    if isHitboxEnabled then toggle_bg.Color = Color3.fromRGB(255, 35, 35) toggle_text.Text = "Hitbox: ENABLED" else toggle_bg.Color = Color3.fromRGB(55, 55, 55) toggle_text.Text = "Hitbox: DISABLED" end
    if isTrailsEnabled then trails_toggle_bg.Color = Color3.fromRGB(255, 35, 35) trails_toggle_text.Text = "Rain Trails: ENABLED" else trails_toggle_bg.Color = Color3.fromRGB(55, 55, 55) trails_toggle_text.Text = "Rain Trails: DISABLED" end
    weapon_ammo_bg.Color = isAmmoEnabled and Color3.fromRGB(255, 35, 35) or Color3.fromRGB(55, 55, 55)
    weapon_recoil_bg.Color = isRecoilEnabled and Color3.fromRGB(255, 35, 35) or Color3.fromRGB(55, 55, 55)
    weapon_fire_bg.Color = isFireRateEnabled and Color3.fromRGB(255, 35, 35) or Color3.fromRGB(55, 55, 55)

    -- Подсветка категорий сайдбара
    cat_hitbox.Color = (currentTab == "HitBox") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
    cat_gunmodule.Color = (currentTab == "GunModule") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
    cat_visuals.Color = (currentTab == "Visuals") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
    cat_configs.Color = (currentTab == "Configs") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
    
    -- Оптимизированный перебор структуры видимости без лагов LuaVM
    for i = 1, #global_ui do
        global_ui[i].Visible = isMenuOpen
    end
    
    for tabName, ui_list in pairs(tab_ui) do
        local shouldShow = (isMenuOpen and currentTab == tabName)
        for i = 1, #ui_list do
            ui_list[i].Visible = shouldShow
        end
    end
    
    if isMenuOpen then updateElementPositions() end
end

-- Инициализация координат при старте
updateElementPositions()

-- ==========================================
-- RAIN TRAILS CREATION FUNCTION
-- ==========================================

local function createTrailPoint(position)
    local circle = Drawing.new("Circle")
    circle.Filled = false
    circle.Color = Color3.fromRGB(0, 160, 255)
    circle.Radius = 3
    circle.Thickness = 1
    circle.Visible = false
    table.insert(activeTrails, { obj = circle, pos = position, spawnTime = tick(), maxLife = 1.2 })
end

-- ==========================================
-- INSTANT HITBOX UPDATE FORCE FUNCTION
-- ==========================================

local function triggerInstantHitboxUpdate()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    local myTeamName, myTeamAddress = nil, nil
    pcall(function() local t = localPlayer.Team if t then myTeamName = t.Name myTeamAddress = t.Address end end)
    local currentTargetSize = isHitboxEnabled and size or 1

    local allPlayers = game.Players:GetPlayers()
    for i = 1, #allPlayers do
        local player = allPlayers[i]
        if player.Address == localPlayer.Address then continue end
        
        local isTeammate = false
        pcall(function() local enemyTeam = player.Team if enemyTeam then if (myTeamAddress and enemyTeam.Address == myTeamAddress) or (myTeamName and enemyTeam.Name == myTeamName) then isTeammate = true end end end)
        
        local character = player.Character
        if character then
            if isTeammate then
                local hitbox = character:FindFirstChild(iter[1])
                if hitbox then hitbox.Size = Vector3.new(1, 1, 1) end
                pcall(function()
                    local children = character:GetChildren()
                    for k = 1, #children do local child = children[k] if child:IsA("BasePart") and child.Transparency ~= 1 then child.Transparency = 1 end end
                end)
                continue
            end
            
            local hitbox = character:FindFirstChild(iter[1])
            if hitbox then hitbox.Size = Vector3.new(currentTargetSize, currentTargetSize, currentTargetSize) hitbox.CanCollide = false end
        end
    end
end

-- ==========================================
-- INTERACTION, DRAGGING & CLICK DETECTION
-- ==========================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local playerMouse = game.Players.LocalPlayer:GetMouse()

local isDragging = false
local dragOffset = Vector2.new(0, 0)
local wasMousePressed = false

local function isMouseInArea(pos, sizeElement)
    local mx, my = playerMouse.X, playerMouse.Y
    return mx >= pos.X and mx <= pos.X + sizeElement.X and my >= pos.Y and my <= pos.Y + sizeElement.Y
end

-- Покадровое обновление для плавных трейлов, перетаскивания и чистой обработки кликов
RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    
    -- Отрендерить капли дождя покадрово на экране через безопасный расчет
    for i = #activeTrails, 1, -1 do
        local trail = activeTrails[i]
        local age = currentTime - trail.spawnTime
        if age >= trail.maxLife then trail.obj:Remove() table.remove(activeTrails, i) else
            if isTrailsEnabled then
                local screenPos, onScreen = WorldToScreen(trail.pos)
                if onScreen and screenPos and screenPos.X and screenPos.Y then 
                    trail.obj.Position = screenPos 
                    trail.obj.Radius = 3 + (age * 15) 
                    trail.obj.Transparency = 1 - (age / trail.maxLife) 
                    trail.obj.Visible = true 
                else 
                    trail.obj.Visible = false 
                end
            else trail.obj.Visible = false end
        end
    end

    if not isMenuOpen then return end
    local mouse1Down = ismouse1pressed()
    local mx, my = playerMouse.X, playerMouse.Y
    
    -- Перетаскивание интерфейса
    if mouse1Down then
        if not isDragging and not wasMousePressed then
            if isMouseInArea(menu_bg.Position, Vector2.new(menu_bg.Size.X, 40)) then
                isDragging = true
                dragOffset = Vector2.new(mx - menu_bg.Position.X, my - menu_bg.Position.Y)
            end
        end
    else isDragging = false end
    if isDragging then menu_bg.Position = Vector2.new(mx - dragOffset.X, my - dragOffset.Y) updateElementPositions() end
    
    -- Клик-система: нативно использует индивидуальный клик через Edge Detection в Heartbeat
    if mouse1Down and not wasMousePressed and not isDragging then
        local menuPos = menu_bg.Position
        
        -- Переключение вкладок в сайдбаре
        if isMouseInArea(menuPos + Vector2.new(0, 80), Vector2.new(140, 30)) then currentTab = "HitBox" updateMenuUI()
        elseif isMouseInArea(menuPos + Vector2.new(0, 112), Vector2.new(140, 30)) then currentTab = "GunModule" updateMenuUI()
        elseif isMouseInArea(menuPos + Vector2.new(0, 145), Vector2.new(140, 30)) then currentTab = "Visuals" updateMenuUI()
        elseif isMouseInArea(menuPos + Vector2.new(0, 178), Vector2.new(140, 30)) then currentTab = "Configs" updateMenuUI() 
        end
        
        -- Вкладка хитбоксов
        if currentTab == "HitBox" then
            if isMouseInArea(plus_bg.Position, plus_bg.Size) then size = size + 1 updateMenuUI() triggerInstantHitboxUpdate()
            elseif isMouseInArea(minus_bg.Position, minus_bg.Size) then if size > 1 then size = size - 1 updateMenuUI() triggerInstantHitboxUpdate() end
            elseif isMouseInArea(reset_bg.Position, reset_bg.Size) then size = defaultSize updateMenuUI() triggerInstantHitboxUpdate()
            elseif isMouseInArea(toggle_bg.Position, toggle_bg.Size) then isHitboxEnabled = not isHitboxEnabled updateMenuUI() triggerInstantHitboxUpdate() end
        
        -- Вкладка оружия (GunModule)
        elseif currentTab == "GunModule" then
            if isMouseInArea(weapon_ammo_bg.Position, weapon_ammo_bg.Size) then isAmmoEnabled = not isAmmoEnabled updateMenuUI() refreshMemoryCache()
            elseif isMouseInArea(weapon_recoil_bg.Position, weapon_recoil_bg.Size) then isRecoilEnabled = not isRecoilEnabled updateMenuUI() refreshMemoryCache()
            elseif isMouseInArea(weapon_fire_bg.Position, weapon_fire_bg.Size) then isFireRateEnabled = not isFireRateEnabled updateMenuUI() refreshMemoryCache() end
        
        -- Вкладка визуалов (Visuals)
        elseif currentTab == "Visuals" then
            if isMouseInArea(trails_toggle_bg.Position, trails_toggle_bg.Size) then isTrailsEnabled = not isTrailsEnabled updateMenuUI() end
        
        -- Вкладка профилей (Configs - Надежное сессионное сохранение таблиц)
        elseif currentTab == "Configs" then
            if isMouseInArea(cfg_save_bg.Position, cfg_save_bg.Size) then
                -- Прямое сохранение состояний в таблицу сессии
                savedConfigSessionTable = { 
                    size = size, 
                    isHitboxEnabled = isHitboxEnabled, 
                    isTrailsEnabled = isTrailsEnabled, 
                    isAmmoEnabled = isAmmoEnabled, 
                    isRecoilEnabled = isRecoilEnabled, 
                    isFireRateEnabled = isFireRateEnabled 
                }
                cfg_status_text.Text = "Storage Slot 1: STATE SAVED SUCCESSFULLY"
                updateMenuUI()
            elseif isMouseInArea(cfg_load_bg.Position, cfg_load_bg.Size) then
                if savedConfigSessionTable ~= nil then
                    size = savedConfigSessionTable.size or size 
                    isHitboxEnabled = savedConfigSessionTable.isHitboxEnabled 
                    isTrailsEnabled = savedConfigSessionTable.isTrailsEnabled 
                    isAmmoEnabled = savedConfigSessionTable.isAmmoEnabled 
                    isRecoilEnabled = savedConfigSessionTable.isRecoilEnabled 
                    isFireRateEnabled = savedConfigSessionTable.isFireRateEnabled
                    
                    cfg_status_text.Text = "Storage Slot 1: CONFIGURATION REPLICATED"
                    refreshMemoryCache()
                    updateMenuUI() 
                    triggerInstantHitboxUpdate()
                else
                    cfg_status_text.Text = "Storage Slot 1: EMPTY"
                    updateMenuUI()
                end
            end
        end
    end
    wasMousePressed = mouse1Down
end)

-- ==========================================
-- KEYBOARD INPUT (KEYBINDS GLOBAL)
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.L then isMenuOpen = not isMenuOpen updateMenuUI() end
    if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus or input.KeyCode == Enum.KeyCode.KeypadPlus then size = size + 1 updateMenuUI() triggerInstantHitboxUpdate()
    elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then if size > 1 then size = size - 1 updateMenuUI() triggerInstantHitboxUpdate() end
    elseif input.KeyCode == Enum.KeyCode.R then size = defaultSize updateMenuUI() triggerInstantHitboxUpdate()
    elseif input.KeyCode == Enum.KeyCode.T then isHitboxEnabled = not isHitboxEnabled updateMenuUI() triggerInstantHitboxUpdate() end
end)

-- Первичный сбор кэша при старте
refreshMemoryCache()

-- ==========================================
-- CORE HITBOX & WEAPON MODIFICATION LOOP
-- ==========================================

-- Поток для циклической записи в кэшируемую память через applygc (согласно правилам доков)
task.spawn(function()
    while true do
        if gcCache then
            pcall(function()
                if isAmmoEnabled then
                    applygc(gcCache, {
                        Ammo = customAmmoValue,
                        MagAmmo = customAmmoValue,
                        StoredAmmo = customStoredAmmoValue
                    })
                end
                if isRecoilEnabled then
                    applygc(gcCache, {
                        MaxSpread = customMaxSpreadValue,
                        Spread = customMaxSpreadValue,
                        SpreadAngle = customMaxSpreadValue,
                        RecoilControl = customRecoilControlValue,
                        CameraRecoilMult = customRecoilControlValue
                    })
                end
                if isFireRateEnabled then
                    applygc(gcCache, {
                        Auto = customAutoValue,
                        Automatic = customAutoValue
                    })
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- Основной рабочий цикл хитбоксов и визуалов игроков
while true do
    local localPlayer = game.Players.LocalPlayer
    if localPlayer then
        local myTeamName, myTeamAddress = nil, nil
        pcall(function() local t = localPlayer.Team if t then myTeamName = t.Name myTeamAddress = t.Address end end)
        local currentTargetSize = isHitboxEnabled and size or 1
        local currentTime = tick()

        local allPlayers = game.Players:GetPlayers()
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            if player.Address == localPlayer.Address then continue end
            
            local isTeammate = false
            pcall(function() local enemyTeam = player.Team if enemyTeam then if (myTeamAddress and enemyTeam.Address == myTeamAddress) or (myTeamName and enemyTeam.Name == myTeamName) then isTeammate = true end end end)
            
            local character = player.Character
            if character then
                if isTeammate then
                    local hitbox = character:FindFirstChild(iter[1])
                    if hitbox and hitbox.Size.X ~= 1 then hitbox.Size = Vector3.new(1, 1, 1) end
                    pcall(function()
                        local children = character:GetChildren()
                        for k = 1, #children do local child = children[k] if child:IsA("BasePart") and child.Transparency ~= 1 then child.Transparency = 1 end end
                    end)
                    continue
                end
                
                local hitbox = character:FindFirstChild(iter[1])
                if hitbox then
                    if math.abs(hitbox.Size.X - currentTargetSize) > 0.01 then hitbox.Size = Vector3.new(currentTargetSize, currentTargetSize, currentTargetSize) hitbox.CanCollide = false end
                    
                    if isTrailsEnabled and hitbox.Velocity.Magnitude > 1.5 then
                        local pName = player.Name lastPlayerTrailTime[pName] = lastPlayerTrailTime[pName] or 0
                        if currentTime - lastPlayerTrailTime[pName] > 0.20 then
                            lastPlayerTrailTime[pName] = currentTime
                            local leftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
                            local rightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")
                            if leftFoot then createTrailPoint(leftFoot.Position) end
                            if rightFoot then createTrailPoint(rightFoot.Position) end
                        end
                    end
                end
            end
        end
    end
    task.wait(0.1)
end

refreshMemoryCache()
print("Engine Optimized. The performance is yours.")
