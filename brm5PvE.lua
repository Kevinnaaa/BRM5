-- ============================================
-- BRM5 PvE v1 - OVERLAY GUI (FIXED NO FOG)
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ============================================
-- CREATE OVERLAY GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BRM5_Overlay"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- MAIN OVERLAY FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.7
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -180)
MainFrame.Size = UDim2.new(0, 360, 0, 360)
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10

local Corner = Instance.new("UICorner")
Corner.Parent = MainFrame
Corner.CornerRadius = UDim.new(0, 12)

-- Border glow
local Border = Instance.new("Frame")
Border.Parent = MainFrame
Border.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
Border.BackgroundTransparency = 0
Border.BorderSizePixel = 0
Border.Size = UDim2.new(1, 0, 0, 2)
Border.Position = UDim2.new(0, 0, 0, 0)

local Border2 = Instance.new("Frame")
Border2.Parent = MainFrame
Border2.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
Border2.BackgroundTransparency = 0
Border2.BorderSizePixel = 0
Border2.Size = UDim2.new(1, 0, 0, 2)
Border2.Position = UDim2.new(0, 0, 1, -2)

-- ============================================
-- TOP BAR
-- ============================================
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
TopBar.BackgroundTransparency = 0.15
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 45)

local TopCorner = Instance.new("UICorner")
TopCorner.Parent = TopBar
TopCorner.CornerRadius = UDim.new(0, 12)

local Icon = Instance.new("TextLabel")
Icon.Parent = TopBar
Icon.BackgroundTransparency = 1
Icon.Position = UDim2.new(0, 12, 0, 0)
Icon.Size = UDim2.new(0, 30, 1, 0)
Icon.Font = Enum.Font.GothamBold
Icon.Text = "🎯"
Icon.TextColor3 = Color3.fromRGB(0, 255, 255)
Icon.TextSize = 20

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 45, 0, 0)
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "BRM5 PvE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local StatusDot = Instance.new("Frame")
StatusDot.Parent = TopBar
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.BackgroundTransparency = 0
StatusDot.BorderSizePixel = 0
StatusDot.Position = UDim2.new(1, -50, 0.5, -4)
StatusDot.Size = UDim2.new(0, 8, 0, 8)
local DotCorner = Instance.new("UICorner")
DotCorner.Parent = StatusDot
DotCorner.CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel")
StatusText.Parent = TopBar
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(1, -40, 0, 0)
StatusText.Size = UDim2.new(0, 35, 1, 0)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "ON"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusText.TextSize = 11
StatusText.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.9
MinBtn.BorderSizePixel = 0
MinBtn.Position = UDim2.new(1, -80, 0.5, -10)
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 16
local MinCorner = Instance.new("UICorner")
MinCorner.Parent = MinBtn
MinCorner.CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 0.9
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -35, 0.5, -10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
local CloseCorner = Instance.new("UICorner")
CloseCorner.Parent = CloseBtn
CloseCorner.CornerRadius = UDim.new(0, 4)

-- ============================================
-- CONTENT AREA
-- ============================================
local Content = Instance.new("ScrollingFrame")
Content.Parent = MainFrame
Content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Content.BackgroundTransparency = 0.5
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 0, 0, 45)
Content.Size = UDim2.new(1, 0, 1, -45)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 180)
Content.ScrollBarImageTransparency = 0.5

local ContentCorner = Instance.new("UICorner")
ContentCorner.Parent = Content
ContentCorner.CornerRadius = UDim.new(0, 12)

-- ============================================
-- STATE
-- ============================================
local ScriptActive = true
local ESPEnabled = false
local NPCESPEnabled = false
local SpeedEnabled = true
local NoFogEnabled = false
local InfiniteHunger = false
local InfiniteThirst = false
local ShowMenu = true

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local isInGame = false
local isMinimized = false
local yPos = 10

-- ============================================
-- FOG REMOVAL FUNCTIONS (FIXED)
-- ============================================
local function RemoveFog()
    pcall(function()
        -- Method 1: Direct Lighting properties
        Lighting.FogEnd = 999999
        Lighting.FogStart = 999999
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        -- Method 2: Remove all fog-related objects
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") or child:IsA("BlurEffect") or child:IsA("SunRaysEffect") then
                child:Destroy()
            end
            if child:IsA("ColorCorrectionEffect") then
                child:Destroy()
            end
        end
        
        -- Method 3: Check for fog in Workspace
        for _, child in pairs(Workspace:GetChildren()) do
            if child:IsA("Atmosphere") or child.Name:lower():find("fog") then
                child:Destroy()
            end
        end
        
        -- Method 4: Terrain fog
        local terrain = Workspace:FindFirstChild("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end
        
        -- Method 5: Check for special fog scripts
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                if child.Name:lower():find("fog") or child.Name:lower():find("weather") then
                    child:Destroy()
                end
            end
        end
    end)
end

local function RestoreFog()
    pcall(function()
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        
        -- Restore terrain
        local terrain = Workspace:FindFirstChild("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0.5
            terrain.WaterWaveSpeed = 0.3
            terrain.WaterReflectance = 0.2
            terrain.WaterTransparency = 0.6
        end
    end)
end

-- ============================================
-- UI HELPERS
-- ============================================
local function AddSection(text)
    local section = Instance.new("TextLabel")
    section.Parent = Content
    section.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
    section.BackgroundTransparency = 0.15
    section.BorderSizePixel = 0
    section.Position = UDim2.new(0, 10, 0, yPos)
    section.Size = UDim2.new(1, -20, 0, 28)
    section.Font = Enum.Font.GothamBold
    section.Text = "▸ " .. text
    section.TextColor3 = Color3.fromRGB(0, 255, 255)
    section.TextSize = 13
    section.TextXAlignment = Enum.TextXAlignment.Left
    
    local SecCorner = Instance.new("UICorner")
    SecCorner.Parent = section
    SecCorner.CornerRadius = UDim.new(0, 4)
    
    yPos = yPos + 32
    return section
end

local function AddOverlayToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = Content
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.Size = UDim2.new(1, -20, 0, 32)
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.Parent = frame
    FrameCorner.CornerRadius = UDim.new(0, 4)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Parent = frame
    iconLabel.BackgroundTransparency = 1
    iconLabel.Position = UDim2.new(0, 8, 0, 0)
    iconLabel.Size = UDim2.new(0, 20, 1, 0)
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.Text = "◆"
    iconLabel.TextColor3 = Color3.fromRGB(0, 200, 200)
    iconLabel.TextSize = 10
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 30, 0, 0)
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local state = default or false
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(50, 50, 70)
    toggleBtn.BackgroundTransparency = 0
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBtn.Size = UDim2.new(0, 30, 0, 20)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = state and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.Parent = toggleBtn
    ToggleCorner.CornerRadius = UDim.new(0, 3)
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(50, 50, 70)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    
    yPos = yPos + 36
    return frame
end

local function AddOverlayLabel(text, color, size)
    local label = Instance.new("TextLabel")
    label.Parent = Content
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.Size = UDim2.new(1, -30, 0, 18)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(160, 160, 180)
    label.TextSize = size or 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    yPos = yPos + 20
    return label
end

local function AddOverlayDivider()
    local divider = Instance.new("Frame")
    divider.Parent = Content
    divider.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
    divider.BackgroundTransparency = 0.8
    divider.BorderSizePixel = 0
    divider.Position = UDim2.new(0, 15, 0, yPos)
    divider.Size = UDim2.new(1, -30, 0, 1)
    yPos = yPos + 10
    return divider
end

-- ============================================
-- BUILD UI
-- ============================================
AddSection("⚡ SPEED")
AddOverlayToggle("Speed Boost", true, function(s)
    SpeedEnabled = s
    if s then applySpeed() end
end)
AddOverlayLabel("Speed: " .. PERMANENT_SPEED .. " (Auto-applies)", Color3.fromRGB(150, 255, 150))

AddOverlayDivider()
AddSection("👁️ ESP")
AddOverlayToggle("Player ESP", false, function(s)
    ESPEnabled = s
    updateESPVisibility()
end)
AddOverlayToggle("NPC/Zombie ESP", false, function(s)
    NPCESPEnabled = s
    if s then scanForNPCs() end
    updateESPVisibility()
end)
AddOverlayLabel("Shows players & zombies through walls", Color3.fromRGB(160, 160, 180))

AddOverlayDivider()
AddSection("🌍 ENVIRONMENT")
AddOverlayToggle("🌫️ Remove Fog", false, function(s)
    NoFogEnabled = s
    if s then
        RemoveFog()
        -- Keep removing fog every few seconds to counter game resets
        task.spawn(function()
            while NoFogEnabled and ScriptActive do
                RemoveFog()
                task.wait(0.5)
            end
        end)
    else
        RestoreFog()
    end
end)
AddOverlayLabel("Removes ALL fog from the game", Color3.fromRGB(100, 255, 200))
AddOverlayLabel("Also increases brightness", Color3.fromRGB(160, 160, 180))

AddOverlayDivider()
AddSection("🍖 SURVIVAL")
AddOverlayToggle("Infinite Hunger", false, function(s)
    InfiniteHunger = s
    if s then startHungerLoop() end
end)
AddOverlayToggle("Infinite Thirst", false, function(s)
    InfiniteThirst = s
    if s then startThirstLoop() end
end)

AddOverlayDivider()
AddOverlayLabel("✦ Made by Maryyy", Color3.fromRGB(0, 200, 200), 12)

Content.CanvasSize = UDim2.new(0, 0, 0, yPos + 30)

-- ============================================
-- TOGGLE MENU BUTTON
-- ============================================
local MenuToggleBtn = Instance.new("TextButton")
MenuToggleBtn.Parent = ScreenGui
MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
MenuToggleBtn.BackgroundTransparency = 0.3
MenuToggleBtn.BorderSizePixel = 0
MenuToggleBtn.Position = UDim2.new(0.01, 0, 0.5, 0)
MenuToggleBtn.Size = UDim2.new(0, 40, 0, 40)
MenuToggleBtn.Font = Enum.Font.GothamBold
MenuToggleBtn.Text = "🎯"
MenuToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleBtn.TextSize = 22
MenuToggleBtn.ZIndex = 20
local MenuCorner = Instance.new("UICorner")
MenuCorner.Parent = MenuToggleBtn
MenuCorner.CornerRadius = UDim.new(1, 0)

MenuToggleBtn.MouseEnter:Connect(function()
    TweenService:Create(MenuToggleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
end)
MenuToggleBtn.MouseLeave:Connect(function()
    TweenService:Create(MenuToggleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
end)

MenuToggleBtn.MouseButton1Click:Connect(function()
    ShowMenu = not ShowMenu
    if ShowMenu then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -180, 0.5, -180),
            BackgroundTransparency = 0.7
        }):Play()
        MainFrame.Visible = true
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -180, 0.5, -180),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        MainFrame.Visible = false
    end
end)

-- ============================================
-- DRAGGING
-- ============================================
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.X > 50 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

-- ============================================
-- MINIMIZE / CLOSE
-- ============================================
local function ToggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 360, 0, 45),
            BackgroundTransparency = 0.5
        }):Play()
        Content.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 360, 0, 360),
            BackgroundTransparency = 0.7
        }):Play()
        task.wait(0.3)
        Content.Visible = true
    end
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    pcall(function()
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("Highlight") or child:IsA("BillboardGui") then
                        child:Destroy()
                    end
                end
            end
        end
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = DEFAULT_SPEED end
        end
        RestoreFog()
    end)
    ScreenGui:Destroy()
    print("✅ Script terminated")
end)

-- ============================================
-- ESP FUNCTIONS
-- ============================================
local ESPObjects = {}
local NPCEntities = {}

local function isNPC(character)
    if not character or not character:IsA("Model") then return false end
    if not character:FindFirstChild("Humanoid") then return false end
    if Players:GetPlayerFromCharacter(character) then return false end
    
    local npcNames = {"NPC", "Zombie", "Enemy", "Bot", "Monster", "Walker", "Runner", "Creep"}
    for _, name in ipairs(npcNames) do
        if string.find(string.lower(character.Name), string.lower(name)) then
            return true
        end
    end
    return false
end

local function createESP(character, isNPC)
    if not character then return end
    
    local key = tostring(character)
    if ESPObjects[key] then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart then return end
    
    local color = isNPC and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 200, 255)
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0.2
    highlight.Enabled = ESPEnabled
    highlight.Parent = character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head or rootPart
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = head and Vector3.new(0, 2.5, 0) or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ESPEnabled
    billboard.Parent = character
    
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = (isNPC and "🧟 " or "👤 ") .. character.Name
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local healthBar = Instance.new("Frame", billboard)
    healthBar.Size = UDim2.new(0.8, 0, 0, 6)
    healthBar.Position = UDim2.new(0.1, 0, 0, 18)
    healthBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBar.BorderSizePixel = 0
    
    local healthFill = Instance.new("Frame", healthBar)
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    
    ESPObjects[key] = {
        Highlight = highlight,
        Billboard = billboard,
        HealthFill = healthFill,
        Character = character,
        Humanoid = humanoid,
        RootPart = rootPart,
        IsNPC = isNPC
    }
    
    if isNPC then
        NPCEntities[key] = character
    end
end

local function scanForNPCs()
    if not NPCESPEnabled then return end
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            if isNPC(obj) then
                local key = tostring(obj)
                if not ESPObjects[key] then
                    createESP(obj, true)
                end
            end
        end
    end
end

local function updateESPVisibility()
    local enabled = ESPEnabled
    for _, espData in pairs(ESPObjects) do
        if espData.Highlight then
            espData.Highlight.Enabled = enabled and (not espData.IsNPC or NPCESPEnabled)
        end
        if espData.Billboard then
            espData.Billboard.Enabled = enabled and (not espData.IsNPC or NPCESPEnabled)
        end
    end
end

local function updateESP()
    if not ESPEnabled then
        updateESPVisibility()
        return
    end
    
    local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for key, espData in pairs(ESPObjects) do
        if not espData or not espData.Character then continue end
        
        local char = espData.Character
        if not char or char.Parent ~= Workspace then
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
            continue
        end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        local humanoid = char:FindFirstChild("Humanoid")
        
        if not rootPart or not humanoid then continue end
        
        local dist = (localRoot.Position - rootPart.Position).Magnitude
        local inRange = dist <= (espData.IsNPC and 1500 or 2000)
        
        if espData.Highlight then
            espData.Highlight.Enabled = inRange
        end
        if espData.Billboard then
            espData.Billboard.Enabled = inRange
        end
        
        if espData.HealthFill and humanoid then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            espData.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
            if healthPercent > 0.5 then
                espData.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.25 then
                espData.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            else
                espData.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

-- ============================================
-- PLAYER TRACKING
-- ============================================
local function trackPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local key = tostring(char)
                if not ESPObjects[key] and not isNPC(char) then
                    createESP(char, false)
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if char and not isNPC(char) then
                createESP(char, false)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    for key, espData in pairs(ESPObjects) do
        if espData.Character and espData.Character:FindFirstChild("Humanoid") then
            local owner = Players:GetPlayerFromCharacter(espData.Character)
            if owner == plr then
                if espData.Highlight then espData.Highlight:Destroy() end
                if espData.Billboard then espData.Billboard:Destroy() end
                ESPObjects[key] = nil
            end
        end
    end
end)

-- ============================================
-- SPEED SYSTEM
-- ============================================
local function applySpeed()
    if not SpeedEnabled or not isInGame then return end
    pcall(function()
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = PERMANENT_SPEED
            end
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    isInGame = true
    applySpeed()
    trackPlayers()
    if NoFogEnabled then RemoveFog() end
end)

-- ============================================
-- HUNGER / THIRST LOOPS
-- ============================================
local function startHungerLoop()
    task.spawn(function()
        while InfiniteHunger and ScriptActive do
            if isInGame then
                pcall(function()
                    local char = player.Character
                    if char then
                        for _, child in pairs(char:GetDescendants()) do
                            if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                                local name = string.lower(child.Name)
                                if string.find(name, "hunger") or string.find(name, "food") then
                                    child.Value = 100
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        end
    end)
end

local function startThirstLoop()
    task.spawn(function()
        while InfiniteThirst and ScriptActive do
            if isInGame then
                pcall(function()
                    local char = player.Character
                    if char then
                        for _, child in pairs(char:GetDescendants()) do
                            if (child:IsA("NumberValue") or child:IsA("IntValue")) then
                                local name = string.lower(child.Name)
                                if string.find(name, "thirst") or string.find(name, "water") then
                                    child.Value = 100
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(1)
        end
    end)
end

-- ============================================
-- MAIN LOOPS
-- ============================================
-- Game state check
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local char = player.Character
            if char and char.Parent == Workspace and char:FindFirstChild("Humanoid") then
                isInGame = true
            else
                isInGame = false
            end
        end)
        task.wait(1)
    end
end)

-- Speed loop
task.spawn(function()
    while ScriptActive do
        if isInGame and SpeedEnabled then
            applySpeed()
        end
        task.wait(0.3)
    end
end)

-- NPC scan loop
task.spawn(function()
    while ScriptActive do
        if NPCESPEnabled and isInGame then
            scanForNPCs()
        end
        task.wait(2)
    end
end)

-- ESP update loop
task.spawn(function()
    while ScriptActive do
        if ESPEnabled and isInGame then
            updateESP()
        end
        task.wait(0.15)
    end
end)

-- Player tracking loop
task.spawn(function()
    while ScriptActive do
        if isInGame then
            trackPlayers()
        end
        task.wait(3)
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
task.wait(1)
isInGame = true
applySpeed()
trackPlayers()
RemoveFog() -- Remove fog by default

print("✅ BRM5 PvE Overlay Loaded!")
print("   Click 🎯 icon to toggle menu")
print("   🌫️ Fog is removed by default")
print("   Features: Speed | ESP | No Fog | Survival")
