-- ==========================================
-- MAIN CONFIGURATION & HITBOX VARIABLES
-- ==========================================
local size = 7
local defaultSize = 1 -- Стандартный размер равен 1
local isHitboxEnabled = true -- Состояние работы хитбоксов (Вкл/Выкл)
local isTrailsEnabled = true -- Состояние эффекта дождя под ногами (Вкл/Выкл)
local currentTab = "HitBox" -- Активная вкладка по умолчанию ("HitBox", "GunModule", "Visuals")

-- НАСТРОЙКИ ОРУЖИЯ (Ты можешь менять эти числа здесь, а тумблеры в меню будут их применять)
local isAmmoEnabled = false      -- Бесконечные патроны (Вкл/Выкл по умолчанию)
local customAmmoValue = 999       -- Патроны в обойме
local customStoredAmmoValue = 300 -- Патроны в запасе

local isRecoilEnabled = false    -- Отдача и разброс (Вкл/Выкл по умолчанию)
local customMaxSpreadValue = 0    -- Значение максимального разброса
local customRecoilControlValue = 0 -- Значение контроля отдачи

local isFireRateEnabled = false  -- Скорострельность (Вкл/Выкл по умолчанию)
local customFireRateValue = 0     -- Задержка между выстрелами
local customReloadTimeValue = 0   -- Время перезарядки
local customAutoValue = true      -- Автоматический режим стрельбы

-- Целью хитбокса является исключительно UpperTorso
local iter = {
    [1] = "UpperTorso"
}

local isMenuOpen = false
local activeTrails = {} -- Массив для хранения активных эффектов капель дождя
local lastPlayerTrailTime = {} -- Ограничитель частоты создания следов для оптимизации памяти

-- ==========================================
-- UI INITIALIZATION (SKECH INSPIRED DARK STYLE)
-- ==========================================

-- Main Background Window (Главное окно чита)
local menu_bg = Drawing.new("Square")
menu_bg.Filled = true
menu_bg.Color = Color3.fromRGB(20, 20, 20)
menu_bg.Position = Vector2.new(150, 150)
menu_bg.Size = Vector2.new(500, 320)
menu_bg.Transparency = 0.98
menu_bg.Visible = false

-- Left Sidebar Background (Левое меню категорий)
local sidebar_bg = Drawing.new("Square")
sidebar_bg.Filled = true
sidebar_bg.Color = Color3.fromRGB(15, 15, 15)
sidebar_bg.Size = Vector2.new(140, 320)
sidebar_bg.Visible = false

-- Sidebar Accent Line (Вертикальная красная полоска активной вкладки)
local sidebar_accent = Drawing.new("Square")
sidebar_accent.Filled = true
sidebar_accent.Color = Color3.fromRGB(255, 35, 35)
sidebar_accent.Size = Vector2.new(3, 22)
sidebar_accent.Visible = false

-- SKECH Logo Label (Логотип в верхнем левом углу)
local logo_text = Drawing.new("Text")
logo_text.Text = "MATCHA"
logo_text.Color = Color3.fromRGB(255, 35, 35)
logo_text.Size = 20
logo_text.Font = Drawing.Fonts.SystemBold
logo_text.Visible = false

-- Sidebar Category Items (Тексты категорий слева)
local cat_player = Drawing.new("Text")
cat_player.Text = "Player"
cat_player.Color = Color3.fromRGB(120, 120, 120)
cat_player.Size = 14
cat_player.Font = Drawing.Fonts.SystemBold
cat_player.Visible = false

-- Вкладка HitBox
local cat_hitbox = Drawing.new("Text")
cat_hitbox.Text = "  HitBox"
cat_hitbox.Color = Color3.fromRGB(255, 255, 255)
cat_hitbox.Size = 14
cat_hitbox.Font = Drawing.Fonts.System
cat_hitbox.Visible = false

-- Вкладка GunModule
local cat_gunmodule = Drawing.new("Text")
cat_gunmodule.Text = "  GunModule"
cat_gunmodule.Color = Color3.fromRGB(120, 120, 120)
cat_gunmodule.Size = 14
cat_gunmodule.Font = Drawing.Fonts.System
cat_gunmodule.Visible = false

-- Вкладка визуалов
local cat_visuals = Drawing.new("Text")
cat_visuals.Text = "  Visuals"
cat_visuals.Color = Color3.fromRGB(120, 120, 120)
cat_visuals.Size = 14
cat_visuals.Font = Drawing.Fonts.System
cat_visuals.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: HITBOX (ХИТБОКСЫ)
-- ------------------------------------------

-- Right Content Card 1: Hitbox Settings Box
local card1_bg = Drawing.new("Square")
card1_bg.Filled = true
card1_bg.Color = Color3.fromRGB(28, 28, 28)
card1_bg.Size = Vector2.new(330, 130)
card1_bg.Visible = false

local card1_title = Drawing.new("Text")
card1_title.Text = "Hitbox Configuration"
card1_title.Color = Color3.fromRGB(255, 35, 35)
card1_title.Size = 15
card1_title.Font = Drawing.Fonts.SystemBold
card1_title.Visible = false

-- Size Status Display
local size_status_text = Drawing.new("Text")
size_status_text.Text = "Target Size: " .. tostring(size)
size_status_text.Color = Color3.fromRGB(230, 230, 230)
size_status_text.Size = 14
size_status_text.Font = Drawing.Fonts.System
size_status_text.Visible = false

-- Plus Button Controls
local plus_bg = Drawing.new("Square")
plus_bg.Filled = true
plus_bg.Color = Color3.fromRGB(45, 45, 45)
plus_bg.Size = Vector2.new(40, 28)
plus_bg.Visible = false

local plus_text = Drawing.new("Text")
plus_text.Text = "+"
plus_text.Color = Color3.fromRGB(255, 255, 255)
plus_text.Size = 16
plus_text.Font = Drawing.Fonts.SystemBold
plus_text.Visible = false

-- Minus Button Controls
local minus_bg = Drawing.new("Square")
minus_bg.Filled = true
minus_bg.Color = Color3.fromRGB(45, 45, 45)
minus_bg.Size = Vector2.new(40, 28)
minus_bg.Visible = false

local minus_text = Drawing.new("Text")
minus_text.Text = "-"
minus_text.Color = Color3.fromRGB(255, 255, 255)
minus_text.Size = 16
minus_text.Font = Drawing.Fonts.SystemBold
minus_text.Visible = false

-- Reset Button Controls
local reset_bg = Drawing.new("Square")
reset_bg.Filled = true
reset_bg.Color = Color3.fromRGB(255, 35, 35)
reset_bg.Size = Vector2.new(70, 28)
reset_bg.Visible = false

local reset_text = Drawing.new("Text")
reset_text.Text = "Reset"
reset_text.Color = Color3.fromRGB(255, 255, 255)
reset_text.Size = 13
reset_text.Font = Drawing.Fonts.SystemBold
reset_text.Visible = false

-- Right Content Card 2: Status & Toggles Box
local card2_bg = Drawing.new("Square")
card2_bg.Filled = true
card2_bg.Color = Color3.fromRGB(28, 28, 28)
card2_bg.Size = Vector2.new(330, 130)
card2_bg.Visible = false

local card2_title = Drawing.new("Text")
card2_title.Text = "Main Functions"
card2_title.Color = Color3.fromRGB(255, 35, 35)
card2_title.Size = 15
card2_title.Font = Drawing.Fonts.SystemBold
card2_title.Visible = false

-- Toggle Master Switch Background
local toggle_bg = Drawing.new("Square")
toggle_bg.Filled = true
toggle_bg.Color = Color3.fromRGB(255, 35, 35)
toggle_bg.Size = Vector2.new(130, 28)
toggle_bg.Visible = false

local toggle_text = Drawing.new("Text")
toggle_text.Text = "Hitbox: ENABLED"
toggle_text.Color = Color3.fromRGB(255, 255, 255)
toggle_text.Size = 13
toggle_text.Font = Drawing.Fonts.SystemBold
toggle_text.Visible = false

-- Info Keybinds Text Display
local controls_text = Drawing.new("Text")
controls_text.Text = "Binds:  [L] Hide UI  |  [Arrows / + -] Size  |  [T] Toggle Hitbox\nTeammates Invisibility: Active\nTarget Component: UpperTorso Only"
controls_text.Color = Color3.fromRGB(130, 130, 130)
controls_text.Size = 12
controls_text.Font = Drawing.Fonts.Monospace
controls_text.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: GUNMODULE (ОРУЖИЕ)
-- ------------------------------------------

-- Главная карточка модификаций оружия
local gun_card_bg = Drawing.new("Square")
gun_card_bg.Filled = true
gun_card_bg.Color = Color3.fromRGB(28, 28, 28)
gun_card_bg.Size = Vector2.new(330, 275)
gun_card_bg.Visible = false

local gun_card_title = Drawing.new("Text")
gun_card_title.Text = "Weapon Memory Overrides"
gun_card_title.Color = Color3.fromRGB(255, 35, 35)
gun_card_title.Size = 15
gun_card_title.Font = Drawing.Fonts.SystemBold
gun_card_title.Visible = false

-- Компоненты интерактивных тумблеров GunModule
-- 1. Переключатель патронов
local weapon_ammo_bg = Drawing.new("Square")
weapon_ammo_bg.Filled = true
weapon_ammo_bg.Size = Vector2.new(160, 28)
weapon_ammo_bg.Visible = false

local weapon_ammo_text = Drawing.new("Text")
weapon_ammo_text.Text = "Infinite Ammo"
weapon_ammo_text.Color = Color3.fromRGB(255, 255, 255)
weapon_ammo_text.Size = 13
weapon_ammo_text.Font = Drawing.Fonts.SystemBold
weapon_ammo_text.Visible = false

-- 2. Переключатель отдачи и разброса
local weapon_recoil_bg = Drawing.new("Square")
weapon_recoil_bg.Filled = true
weapon_recoil_bg.Size = Vector2.new(160, 28)
weapon_recoil_bg.Visible = false

local weapon_recoil_text = Drawing.new("Text")
weapon_recoil_text.Text = "No Recoil & Spread"
weapon_recoil_text.Color = Color3.fromRGB(255, 255, 255)
weapon_recoil_text.Size = 13
weapon_recoil_text.Font = Drawing.Fonts.SystemBold
weapon_recoil_text.Visible = false

-- 3. Переключатель скорострельности и автоматического режима
local weapon_fire_bg = Drawing.new("Square")
weapon_fire_bg.Filled = true
weapon_fire_bg.Size = Vector2.new(160, 28)
weapon_fire_bg.Visible = false

local weapon_fire_text = Drawing.new("Text")
weapon_fire_text.Text = "Rapid Fire & Auto"
weapon_fire_text.Color = Color3.fromRGB(255, 255, 255)
weapon_fire_text.Size = 13
weapon_fire_text.Font = Drawing.Fonts.SystemBold
weapon_fire_text.Visible = false

local gun_status_footer = Drawing.new("Text")
gun_status_footer.Text = "Target Structure: ReplicatedStorage.Weapons\nContinuous Memory Injections: ACTIVE via Matcha LuaVM"
gun_status_footer.Color = Color3.fromRGB(110, 110, 110)
gun_status_footer.Size = 11
gun_status_footer.Font = Drawing.Fonts.Monospace
gun_status_footer.Visible = false

-- ------------------------------------------
-- TAB ELEMENTS: VISUALS (ЭФФЕКТЫ ДОЖДЯ)
-- ------------------------------------------

-- Карточка для вкладки визуалов
local visuals_card_bg = Drawing.new("Square")
visuals_card_bg.Filled = true
visuals_card_bg.Color = Color3.fromRGB(28, 28, 28)
visuals_card_bg.Size = Vector2.new(330, 130)
visuals_card_bg.Visible = false

local visuals_card_title = Drawing.new("Text")
visuals_card_title.Text = "Environment Visuals"
visuals_card_title.Color = Color3.fromRGB(255, 35, 35)
visuals_card_title.Size = 15
visuals_card_title.Font = Drawing.Fonts.SystemBold
visuals_card_title.Visible = false

-- Перенесенная кнопка следов дождя на страницу визуалов
local trails_toggle_bg = Drawing.new("Square")
trails_toggle_bg.Filled = true
trails_toggle_bg.Color = Color3.fromRGB(255, 35, 35)
trails_toggle_bg.Size = Vector2.new(155, 28)
trails_toggle_bg.Visible = false

local trails_toggle_text = Drawing.new("Text")
trails_toggle_text.Text = "Rain Trails: ENABLED"
trails_toggle_text.Color = Color3.fromRGB(255, 255, 255)
trails_toggle_text.Size = 13
trails_toggle_text.Font = Drawing.Fonts.SystemBold
trails_toggle_text.Visible = false

local visuals_info_text = Drawing.new("Text")
visuals_info_text.Text = "Renders custom expanding ripple rings under enemy feet\nwhen they move. Dynamically calculated via screen-space.\nEffect performance optimized for Matcha LuaVM."
visuals_info_text.Color = Color3.fromRGB(130, 130, 130)
visuals_info_text.Size = 12
visuals_info_text.Font = Drawing.Fonts.Monospace
visuals_info_text.Visible = false

-- ==========================================
-- DYNAMIC POSITIONING & VISIBILITY FUNCTIONS
-- ==========================================

local function updateElementPositions()
    local base = menu_bg.Position
    
    -- Левый сайдбар под SKECH
    sidebar_bg.Position = base
    logo_text.Position = base + Vector2.new(20, 18)
    
    cat_player.Position = base + Vector2.new(20, 60)
    cat_hitbox.Position = base + Vector2.new(20, 88)
    cat_gunmodule.Position = base + Vector2.new(20, 120)
    cat_visuals.Position = base + Vector2.new(20, 152)
    
    -- Позиционирование красного индикатора вкладок
    if currentTab == "HitBox" then
        sidebar_accent.Position = base + Vector2.new(0, 85)
    elseif currentTab == "GunModule" then
        sidebar_accent.Position = base + Vector2.new(0, 117)
    elseif currentTab == "Visuals" then
        sidebar_accent.Position = base + Vector2.new(0, 149)
    end
    
    -- Позиционирование вкладки хитбоксов (HitBox)
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
    toggle_bg.Position = card2_bg.Position + Vector2.new(15, 42)
    toggle_text.Position = toggle_bg.Position + Vector2.new(14, 5)
    controls_text.Position = card2_bg.Position + Vector2.new(15, 85)
    
    -- Позиционирование новой вкладки GunModule
    gun_card_bg.Position = base + Vector2.new(155, 15)
    gun_card_title.Position = gun_card_bg.Position + Vector2.new(15, 12)
    
    weapon_ammo_bg.Position = gun_card_bg.Position + Vector2.new(15, 45)
    weapon_ammo_text.Position = weapon_ammo_bg.Position + Vector2.new(36, 5)
    
    weapon_recoil_bg.Position = gun_card_bg.Position + Vector2.new(15, 85)
    weapon_recoil_text.Position = weapon_recoil_bg.Position + Vector2.new(18, 5)
    
    weapon_fire_bg.Position = gun_card_bg.Position + Vector2.new(15, 125)
    weapon_fire_text.Position = weapon_fire_bg.Position + Vector2.new(24, 5)
    
    gun_status_footer.Position = gun_card_bg.Position + Vector2.new(15, 235)
    
    -- Позиционирование вкладки визуалов
    visuals_card_bg.Position = base + Vector2.new(155, 15)
    visuals_card_title.Position = visuals_card_bg.Position + Vector2.new(15, 12)
    trails_toggle_bg.Position = visuals_card_bg.Position + Vector2.new(15, 45)
    trails_toggle_text.Position = trails_toggle_bg.Position + Vector2.new(14, 5)
    visuals_info_text.Position = visuals_card_bg.Position + Vector2.new(15, 85)
end

local function updateMenuUI()
    size_status_text.Text = "Target Size: " .. tostring(size)
    
    -- Синхронизация визуального стиля кнопок-тумблеров
    if isHitboxEnabled then
        toggle_bg.Color = Color3.fromRGB(255, 35, 35)
        toggle_text.Text = "Hitbox: ENABLED"
    else
        toggle_bg.Color = Color3.fromRGB(55, 55, 55)
        toggle_text.Text = "Hitbox: DISABLED"
    end

    if isTrailsEnabled then
        trails_toggle_bg.Color = Color3.fromRGB(255, 35, 35)
        trails_toggle_text.Text = "Rain Trails: ENABLED"
    else
        trails_toggle_bg.Color = Color3.fromRGB(55, 55, 55)
        trails_toggle_text.Text = "Rain Trails: DISABLED"
    end

    -- Цвета тумблеров вкладки GunModule
    if isAmmoEnabled then
        weapon_ammo_bg.Color = Color3.fromRGB(255, 35, 35)
    else
        weapon_ammo_bg.Color = Color3.fromRGB(55, 55, 55)
    end

    if isRecoilEnabled then
        weapon_recoil_bg.Color = Color3.fromRGB(255, 35, 35)
    else
        weapon_recoil_bg.Color = Color3.fromRGB(55, 55, 55)
    end

    if isFireRateEnabled then
        weapon_fire_bg.Color = Color3.fromRGB(255, 35, 35)
    else
        weapon_fire_bg.Color = Color3.fromRGB(55, 55, 55)
    end
    
    -- Динамическое изменение цвета текста категорий в сайдбаре
    if currentTab == "HitBox" then
        cat_hitbox.Color = Color3.fromRGB(255, 255, 255)
        cat_gunmodule.Color = Color3.fromRGB(120, 120, 120)
        cat_visuals.Color = Color3.fromRGB(120, 120, 120)
    elseif currentTab == "GunModule" then
        cat_hitbox.Color = Color3.fromRGB(120, 120, 120)
        cat_gunmodule.Color = Color3.fromRGB(255, 255, 255)
        cat_visuals.Color = Color3.fromRGB(120, 120, 120)
    elseif currentTab == "Visuals" then
        cat_hitbox.Color = Color3.fromRGB(120, 120, 120)
        cat_gunmodule.Color = Color3.fromRGB(120, 120, 120)
        cat_visuals.Color = Color3.fromRGB(255, 255, 255)
    end
    
    -- Основная рамка меню
    menu_bg.Visible = isMenuOpen
    sidebar_bg.Visible = isMenuOpen
    sidebar_accent.Visible = isMenuOpen
    logo_text.Visible = isMenuOpen
    cat_player.Visible = isMenuOpen
    cat_hitbox.Visible = isMenuOpen
    cat_gunmodule.Visible = isMenuOpen
    cat_visuals.Visible = isMenuOpen
    
    -- Видимость вкладки хитбоксов (HitBox)
    local isHitBoxTab = (isMenuOpen and currentTab == "HitBox")
    card1_bg.Visible = isHitBoxTab
    card1_title.Visible = isHitBoxTab
    size_status_text.Visible = isHitBoxTab
    plus_bg.Visible = isHitBoxTab
    plus_text.Visible = isHitBoxTab
    minus_bg.Visible = isHitBoxTab
    minus_text.Visible = isHitBoxTab
    reset_bg.Visible = isHitBoxTab
    reset_text.Visible = isHitBoxTab
    card2_bg.Visible = isHitBoxTab
    card2_title.Visible = isHitBoxTab
    toggle_bg.Visible = isHitBoxTab
    toggle_text.Visible = isHitBoxTab
    controls_text.Visible = isHitBoxTab
    
    -- Видимость новой вкладки GunModule
    local isGunModuleTab = (isMenuOpen and currentTab == "GunModule")
    gun_card_bg.Visible = isGunModuleTab
    gun_card_title.Visible = isGunModuleTab
    weapon_ammo_bg.Visible = isGunModuleTab
    weapon_ammo_text.Visible = isGunModuleTab
    weapon_recoil_bg.Visible = isGunModuleTab
    weapon_recoil_text.Visible = isGunModuleTab
    weapon_fire_bg.Visible = isGunModuleTab
    weapon_fire_text.Visible = isGunModuleTab
    gun_status_footer.Visible = isGunModuleTab

    -- Управление видимостью вкладки визуалов
    local isVisualsTab = (isMenuOpen and currentTab == "Visuals")
    visuals_card_bg.Visible = isVisualsTab
    visuals_card_title.Visible = isVisualsTab
    trails_toggle_bg.Visible = isVisualsTab
    trails_toggle_text.Visible = isVisualsTab
    visuals_info_text.Visible = isVisualsTab
    
    if isMenuOpen then
        updateElementPositions()
    end
end

-- Инициализация координат
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
    
    table.insert(activeTrails, {
        obj = circle,
        pos = position,
        spawnTime = tick(),
        maxLife = 1.2
    })
end

-- ==========================================
-- INSTANT HITBOX UPDATE FORCE FUNCTION
-- ==========================================

local function triggerInstantHitboxUpdate()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    local myTeamName = nil
    local myTeamAddress = nil
    pcall(function()
        local t = localPlayer.Team
        if t then
            myTeamName = t.Name
            myTeamAddress = t.Address
        end
    end)

    local currentTargetSize = isHitboxEnabled and size or 1

    local allPlayers = game.Players:GetPlayers()
    for i = 1, #allPlayers do
        local player = allPlayers[i]
        if player.Address == localPlayer.Address then continue end
        
        local isTeammate = false
        pcall(function()
            local enemyTeam = player.Team
            if enemyTeam then
                if (myTeamAddress and enemyTeam.Address == myTeamAddress) or (myTeamName and enemyTeam.Name == myTeamName) then 
                    isTeammate = true 
                end
            end
        end)
        
        local character = player.Character
        if character then
            if isTeammate then
                local hitbox = character:FindFirstChild(iter[1])
                if hitbox then
                    hitbox.Size = Vector3.new(1, 1, 1)
                end

                pcall(function()
                    local children = character:GetChildren()
                    for k = 1, #children do
                        local child = children[k]
                        if child:IsA("BasePart") and child.Transparency ~= 1 then
                            child.Transparency = 1
                        end
                    end
                end)
                continue
            end
            
            local hitbox = character:FindFirstChild(iter[1])
            if hitbox then
                hitbox.Size = Vector3.new(currentTargetSize, currentTargetSize, currentTargetSize)
                hitbox.CanCollide = false
            end
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

RunService.Heartbeat:Connect(function()
    -- Отрендерить и обновить все существующие капли дождя покадрово
    local currentTime = tick()
    for i = #activeTrails, 1, -1 do
        local trail = activeTrails[i]
        local age = currentTime - trail.spawnTime
        
        if age >= trail.maxLife then
            trail.obj:Remove()
            table.remove(activeTrails, i)
        else
            if isTrailsEnabled then
                local screenPos, onScreen = WorldToScreen(trail.pos)
                if onScreen then
                    trail.obj.Position = screenPos
                    trail.obj.Radius = 3 + (age * 15)
                    trail.obj.Transparency = 1 - (age / trail.maxLife)
                    trail.obj.Visible = true
                else
                    trail.obj.Visible = false
                end
            else
                trail.obj.Visible = false
            end
        end
    end

    if not isMenuOpen then return end
    
    local mouse1Down = ismouse1pressed()
    local mx, my = playerMouse.X, playerMouse.Y
    
    -- Перетаскивание меню (Клик по верхней панели главного окна высотой 40px)
    if mouse1Down then
        if not isDragging and not wasMousePressed then
            if isMouseInArea(menu_bg.Position, Vector2.new(menu_bg.Size.X, 40)) then
                isDragging = true
                dragOffset = Vector2.new(mx - menu_bg.Position.X, my - menu_bg.Position.Y)
            end
        end
    else
        isDragging = false
    end
    
    if isDragging then
        menu_bg.Position = Vector2.new(mx - dragOffset.X, my - dragOffset.Y)
        updateElementPositions()
    end
    
    -- Обработка кликов по элементам интерфейса
    if mouse1Down and not wasMousePressed and not isDragging then
        local menuPos = menu_bg.Position
        
        -- Логика переключения между тремя вкладками в левом сайдбаре
        if isMouseInArea(menuPos + Vector2.new(0, 80), Vector2.new(140, 30)) then
            currentTab = "HitBox"
            updateMenuUI()
        elseif isMouseInArea(menuPos + Vector2.new(0, 112), Vector2.new(140, 30)) then
            currentTab = "GunModule"
            updateMenuUI()
        elseif isMouseInArea(menuPos + Vector2.new(0, 145), Vector2.new(140, 30)) then
            currentTab = "Visuals"
            updateMenuUI()
        end
        
        -- Клики внутри вкладки хитбоксов (HitBox)
        if currentTab == "HitBox" then
            if isMouseInArea(plus_bg.Position, plus_bg.Size) then
                size = size + 1
                updateMenuUI()
                triggerInstantHitboxUpdate()
            elseif isMouseInArea(minus_bg.Position, minus_bg.Size) then
                if size > 1 then
                    size = size - 1
                    updateMenuUI()
                    triggerInstantHitboxUpdate()
                end
            elseif isMouseInArea(reset_bg.Position, reset_bg.Size) then
                size = defaultSize
                updateMenuUI()
                triggerInstantHitboxUpdate()
            elseif isMouseInArea(toggle_bg.Position, toggle_bg.Size) then
                isHitboxEnabled = not isHitboxEnabled
                updateMenuUI()
                triggerInstantHitboxUpdate()
            end
        
        -- Клики внутри новой вкладки GunModule (Оружие)
        elseif currentTab == "GunModule" then
            if isMouseInArea(weapon_ammo_bg.Position, weapon_ammo_bg.Size) then
                isAmmoEnabled = not isAmmoEnabled
                updateMenuUI()
            elseif isMouseInArea(weapon_recoil_bg.Position, weapon_recoil_bg.Size) then
                isRecoilEnabled = not isRecoilEnabled
                updateMenuUI()
            elseif isMouseInArea(weapon_fire_bg.Position, weapon_fire_bg.Size) then
                isFireRateEnabled = not isFireRateEnabled
                updateMenuUI()
            end

        -- Клики внутри вкладки визуалов
        elseif currentTab == "Visuals" then
            if isMouseInArea(trails_toggle_bg.Position, trails_toggle_bg.Size) then
                isTrailsEnabled = not isTrailsEnabled
                updateMenuUI()
            end
        end
    end
    
    wasMousePressed = mouse1Down
end)

-- ==========================================
-- KEYBOARD INPUT (KEYBINDS GLOBAL)
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- [L] Открыть/закрыть меню
    if input.KeyCode == Enum.KeyCode.L then
        isMenuOpen = not isMenuOpen
        updateMenuUI()
    end
    
    -- Горячие клавиши изменения размера хитбоксов: работают ВСЕГДА
    if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus or input.KeyCode == Enum.KeyCode.KeypadPlus then
        size = size + 1
        updateMenuUI()
        triggerInstantHitboxUpdate()
        
    elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
        if size > 1 then
            size = size - 1
            updateMenuUI()
            triggerInstantHitboxUpdate()
        end
        
    elseif input.KeyCode == Enum.KeyCode.R then
        size = defaultSize
        updateMenuUI()
        triggerInstantHitboxUpdate()
        
    elseif input.KeyCode == Enum.KeyCode.T then -- [T] Включение/Выключение сайза на ходу
        isHitboxEnabled = not isHitboxEnabled
        updateMenuUI()
        triggerInstantHitboxUpdate()
    end
end)

-- ==========================================
-- CORE HITBOX & WEAPON MODIFICATION LOOP
-- ==========================================

while true do
    -- 1. НАДЕЖНЫЙ ОБХОД И МОДИФИКАЦИЯ ОРУЖИЯ (ReplicatedStorage.Weapons)
    pcall(function()
        local weaponsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
        if weaponsFolder then
            local allWeapons = weaponsFolder:GetChildren()
            for wIndex = 1, #allWeapons do
                local weapon = allWeapons[wIndex]
                
                -- Если включен тумблер патронов — непрерывно инжектим заданные переменные
                if isAmmoEnabled then
                    local ammo = weapon:FindFirstChild("Ammo")
                    local storedAmmo = weapon:FindFirstChild("StoredAmmo")
                    if ammo then ammo.Value = customAmmoValue end
                    if storedAmmo then storedAmmo.Value = customStoredAmmoValue end
                end
                
                -- Если включен тумблер отдачи — перезаписываем разброс и отдачу
                if isRecoilEnabled then
                    local maxSpread = weapon:FindFirstChild("MaxSpread")
                    local recoilControl = weapon:FindFirstChild("RecoilControl")
                    if maxSpread then maxSpread.Value = customMaxSpreadValue end
                    if recoilControl then recoilControl.Value = customRecoilControlValue end
                end
                
                -- Если включен тумблер скорострельности — убираем задержки и включаем зажим
                if isFireRateEnabled then
                    local fireRate = weapon:FindFirstChild("FireRate")
                    local reloadTime = weapon:FindFirstChild("ReloadTime")
                    local autoMode = weapon:FindFirstChild("Auto")
                    if fireRate then fireRate.Value = customFireRateValue end
                    if reloadTime then reloadTime.Value = customReloadTimeValue end
                    if autoMode then autoMode.Value = customAutoValue end
                end
            end
        end
    end)

    -- 2. ОБРАБОТКА ХИТБОКСОВ И ВИЗУАЛОВ ИГРОКОВ
    local localPlayer = game.Players.LocalPlayer
    if localPlayer then
        local myTeamName = nil
        local myTeamAddress = nil
        pcall(function()
            local t = localPlayer.Team
            if t then
                myTeamName = t.Name
                myTeamAddress = t.Address
            end
        end)

        local currentTargetSize = isHitboxEnabled and size or 1
        local currentTime = tick()

        local allPlayers = game.Players:GetPlayers()
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            if player.Address == localPlayer.Address then continue end
            
            -- Проверка на команду
            local isTeammate = false
            pcall(function()
                local enemyTeam = player.Team
                if enemyTeam then
                    if (myTeamAddress and enemyTeam.Address == myTeamAddress) or (myTeamName and enemyTeam.Name == myTeamName) then 
                        isTeammate = true 
                    end
                end
            end)
            
            local character = player.Character
            if character then
                if isTeammate then
                    -- Жесткое удержание хитбокса тимейтов на размере 1
                    local hitbox = character:FindFirstChild(iter[1])
                    if hitbox then
                        if hitbox.Size.X ~= 1 then
                            hitbox.Size = Vector3.new(1, 1, 1)
                        end
                    end

                    -- Поддержание полной невидимости союзной команды
                    pcall(function()
                        local children = character:GetChildren()
                        for k = 1, #children do
                            local child = children[k]
                            if child:IsA("BasePart") and child.Transparency ~= 1 then
                                child.Transparency = 1
                            end
                        end
                    end)
                    continue
                end
                
                -- Проверка размера UpperTorso у врагов в памяти игры
                local hitbox = character:FindFirstChild(iter[1])
                if hitbox then
                    if math.abs(hitbox.Size.X - currentTargetSize) > 0.01 then
                        hitbox.Size = Vector3.new(currentTargetSize, currentTargetSize, currentTargetSize)
                        hitbox.CanCollide = false
                    end
                    
                    -- Генерация следов дождя под ступнями движущихся врагов
                    if isTrailsEnabled then
                        local isMoving = false
                        pcall(function()
                            if hitbox.Velocity.Magnitude > 1.5 then
                                isMoving = true
                            end
                        end)
                        
                        if isMoving then
                            local pName = player.Name
                            lastPlayerTrailTime[pName] = lastPlayerTrailTime[pName] or 0
                            
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
    end
    
    wait(0.1)
end
