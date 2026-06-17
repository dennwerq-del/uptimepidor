-- ==========================================
-- MAIN CONFIGURATION & HITBOX VARIABLES
-- ==========================================
local size = 7
local defaultSize = 7
local coll = {}
local iter = {
    [1] = "LeftUpperArm",
    [2] = "RightLowerLeg",
    [3] = "LowerTorso",
    [4] = "RightUpperLeg",
    [5] = "RightUpperArm",
    [6] = "RightLowerArm",
}

local isMenuOpen = false

-- ==========================================
-- UI INITIALIZATION (DRAWING API)
-- ==========================================

-- Main Background Window
local menu_bg = Drawing.new("Square")
menu_bg.Filled = true
menu_bg.Color = Color3.fromRGB(25, 25, 25)
menu_bg.Position = Vector2.new(150, 150)
menu_bg.Size = Vector2.new(360, 200)
menu_bg.Transparency = 0.95
menu_bg.Visible = false

-- Window Title (Bold Font)
local title_text = Drawing.new("Text")
title_text.Text = "Matcha Hitbox Controller"
title_text.Color = Color3.fromRGB(255, 165, 0)
title_text.Size = 18
title_text.Font = Drawing.Fonts.SystemBold
title_text.Visible = false

-- Size Status Display
local size_status_text = Drawing.new("Text")
size_status_text.Text = "Current Size: " .. tostring(size)
size_status_text.Color = Color3.fromRGB(255, 255, 255)
size_status_text.Size = 16
size_status_text.Font = Drawing.Fonts.SystemBold
size_status_text.Visible = false

-- Plus Button Background
local plus_bg = Drawing.new("Square")
plus_bg.Filled = true
plus_bg.Color = Color3.fromRGB(50, 50, 50)
plus_bg.Size = Vector2.new(40, 30)
plus_bg.Visible = false

-- Plus Button Text
local plus_text = Drawing.new("Text")
plus_text.Text = "+"
plus_text.Color = Color3.fromRGB(255, 255, 255)
plus_text.Size = 16
plus_text.Font = Drawing.Fonts.SystemBold
plus_text.Visible = false

-- Minus Button Background
local minus_bg = Drawing.new("Square")
minus_bg.Filled = true
minus_bg.Color = Color3.fromRGB(50, 50, 50)
minus_bg.Size = Vector2.new(40, 30)
minus_bg.Visible = false

-- Minus Button Text
local minus_text = Drawing.new("Text")
minus_text.Text = "-"
minus_text.Color = Color3.fromRGB(255, 255, 255)
minus_text.Size = 16
minus_text.Font = Drawing.Fonts.SystemBold
minus_text.Visible = false

-- Reset Button Background
local reset_bg = Drawing.new("Square")
reset_bg.Filled = true
reset_bg.Color = Color3.fromRGB(180, 50, 50)
reset_bg.Size = Vector2.new(80, 30)
reset_bg.Visible = false

-- Reset Button Text
local reset_text = Drawing.new("Text")
reset_text.Text = "Reset"
reset_text.Color = Color3.fromRGB(255, 255, 255)
reset_text.Size = 14
reset_text.Font = Drawing.Fonts.SystemBold
reset_text.Visible = false

-- Info Controls Text (Monospace Font)
local controls_text = Drawing.new("Text")
controls_text.Text = "Keybinds:\n[L] Toggle UI  |  [Arrows / + -] Change Size\n[R] Reset Size  |  Drag top bar to move\nTeam Protection: ACTIVE"
controls_text.Color = Color3.fromRGB(160, 160, 160)
controls_text.Size = 13
controls_text.Font = Drawing.Fonts.Monospace
controls_text.Visible = false

-- ==========================================
-- DYNAMIC POSITIONING & VISIBILITY FUNCTIONS
-- ==========================================

local function updateElementPositions()
    local base = menu_bg.Position
    
    title_text.Position = base + Vector2.new(15, 12)
    size_status_text.Position = base + Vector2.new(15, 50)
    
    plus_bg.Position = base + Vector2.new(15, 85)
    plus_text.Position = plus_bg.Position + Vector2.new(14, 5)
    
    minus_bg.Position = base + Vector2.new(65, 85)
    minus_text.Position = minus_bg.Position + Vector2.new(16, 5)
    
    reset_bg.Position = base + Vector2.new(120, 85)
    reset_text.Position = reset_bg.Position + Vector2.new(20, 6)
    
    controls_text.Position = base + Vector2.new(15, 130)
end

local function updateMenuUI()
    size_status_text.Text = "Current Size: " .. tostring(size)
    
    menu_bg.Visible = isMenuOpen
    title_text.Visible = isMenuOpen
    size_status_text.Visible = isMenuOpen
    plus_bg.Visible = isMenuOpen
    plus_text.Visible = isMenuOpen
    minus_bg.Visible = isMenuOpen
    minus_text.Visible = isMenuOpen
    reset_bg.Visible = isMenuOpen
    reset_text.Visible = isMenuOpen
    controls_text.Visible = isMenuOpen
    
    if isMenuOpen then
        updateElementPositions()
    end
end

-- Initialize positions at start
updateElementPositions()

-- ==========================================
-- INSTANT HITBOX UPDATE FORCE FUNCTION
-- ==========================================

local function triggerInstantHitboxUpdate()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    local allPlayers = game.Players:GetPlayers()
    for i = 1, #allPlayers do
        local player = allPlayers[i]
        
        -- Пропуск себя
        if player.Address == localPlayer.Address then continue end
        
        -- Двойная проверка команды (по адресу и по имени для стабильности плагина)
        local myTeam = localPlayer.Team
        local enemyTeam = player.Team
        if myTeam and enemyTeam then
            if myTeam.Address == enemyTeam.Address or myTeam.Name == enemyTeam.Name then 
                continue 
            end
        end
        
        local character = player.Character
        if character then
            -- Единоразовый принудительный удар по памяти новым размером (мгновенный апдейт)
            for j = 1, #iter do
                local partName = iter[j]
                local hitbox = character:FindFirstChild(partName)
                if hitbox then
                    hitbox.Size = Vector3.new(size, size, size)
                    hitbox.CanCollide = false
                end
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

-- Helper function to check if mouse coordinates are inside an element bounding box
local function isMouseInArea(pos, sizeElement)
    local mx, my = playerMouse.X, playerMouse.Y
    return mx >= pos.X and mx <= pos.X + sizeElement.X and my >= pos.Y and my <= pos.Y + sizeElement.Y
end

-- Heartbeat loop to handle frame-by-frame drag and click calculations
RunService.Heartbeat:Connect(function()
    if not isMenuOpen then return end
    
    local mouse1Down = ismouse1pressed()
    local mx, my = playerMouse.X, playerMouse.Y
    
    -- Drag Logic (Top Title Bar Area: 40px height)
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
    
    -- Click Actions Logic (Triggers once per click down)
    if mouse1Down and not wasMousePressed and not isDragging then
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
        end
    end
    
    wasMousePressed = mouse1Down
end)

-- ==========================================
-- KEYBOARD INPUT (KEYBINDS GLOBAL)
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Фильтр gameProcessed полностью убран для кнопок изменения размера, 
    -- чтобы они прожимались прямо во время бега и стрельбы
    
    -- [L] Открытие/Закрытие меню
    if input.KeyCode == Enum.KeyCode.L then
        isMenuOpen = not isMenuOpen
        updateMenuUI()
    end
    
    -- Глобальные хоткеи (работают ВСЕГДА и обновляют размер в ту же милисекунду)
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
    end
end)

-- ==========================================
-- CORE HITBOX MODIFICATION LOOP
-- ==========================================

while true do
    local localPlayer = game.Players.LocalPlayer
    if localPlayer then
        local allPlayers = game.Players:GetPlayers()
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            
            -- Пропуск себя по адресу памяти
            if player.Address == localPlayer.Address then continue end
            
            -- Стабильная защита команды по двум параметрам (Адрес + Имя)
            local myTeam = localPlayer.Team
            local enemyTeam = player.Team
            if myTeam and enemyTeam then
                if myTeam.Address == enemyTeam.Address or myTeam.Name == enemyTeam.Name then 
                    continue 
                end
            end
            
            local character = player.Character
            if character then
                for j = 1, #iter do
                    local partName = iter[j]
                    local hitbox = character:FindFirstChild(partName)
                    if hitbox then
                        -- Умная проверка: пишем в память ТОЛЬКО если размер отличается.
                        -- Это спасает буфер плагина от перегрузки очереди и убирает задержки!
                        if math.abs(hitbox.Size.X - size) > 0.1 then
                            hitbox.Size = Vector3.new(size, size, size)
                            hitbox.CanCollide = false
                        end
                    end
                end
            end
        end
    end
    
    -- Оптимальный интервал для проверки респавнов без засорения шины данных плагина
    wait(0.1)
end
