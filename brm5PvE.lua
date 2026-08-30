-- ============================================
-- BRM5 PvE v1 - SIMPLE GUI
-- Clean & Minimal Design
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ============================================
-- CREATE GUI (Simple & Safe)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BRM5_GUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")  -- Use PlayerGui instead of CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- MAIN FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10

-- Corner rounding
local Corner = Instance.new("UICorner")
Corner.Parent = MainFrame
Corner.CornerRadius = UDim.new(0, 10)

-- Shadow
local Shadow = Instance.new("Frame")
Shadow.Parent = MainFrame
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0, 5, 0, 5)
Shadow.Size = UDim2.new(1, -10, 1, -10)
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.Parent = Shadow
ShadowCorner.CornerRadius = UDim.new(0, 10)

-- ============================================
-- TITLE BAR (Draggable)
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
TitleBar.BackgroundTransparency = 0
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)

local TitleCorner = Instance.new("UICorner")
TitleCorner.Parent = TitleBar
TitleCorner.CornerRadius = UDim.new(0, 10)

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "🎯 BRM5 PvE"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TitleBar
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.BackgroundTransparency = 0
MinBtn.BorderSizePixel = 0
MinBtn.Position = UDim2.new(1, -35, 0.5, -12)
MinBtn.Size = UDim2.new(0, 25, 0, 24)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18

local MinCorner = Instance.new("UICorner")
MinCorner.Parent = MinBtn
MinCorner.CornerRadius = UDim.new(0, 5)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BackgroundTransparency = 0
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -65, 0.5, -12)
CloseBtn.Size = UDim2.new(0, 25, 0, 24)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.Parent = CloseBtn
CloseCorner.CornerRadius = UDim.new(0, 5)

-- ============================================
-- CONTENT FRAME
-- ============================================
local Content = Instance.new("ScrollingFrame")
Content.Parent = MainFrame
Content.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Content.BackgroundTransparency = 0
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 0, 0, 40)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 150)

local ContentCorner = Instance.new("UICorner")
ContentCorner.Parent = Content
ContentCorner.CornerRadius = UDim.new(0, 10)

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

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local isInGame = false
local isMinimized = false

-- ============================================
-- UI HELPERS
-- ============================================
local yPos = 10

local function AddLabel(text, color, size)
    local label = Instance.new("TextLabel")
    label.Parent = Content
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextSize = size or 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    yPos = yPos + 30
    return label
end

local function AddToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = Content
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.Size = UDim2.new(1, -20, 0, 35)
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.Parent = frame
    FrameCorner.CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 250, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local state = default or false
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(60, 60, 80)
    toggleBtn.BackgroundTransparency = 0
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -12)
    toggleBtn.Size = UDim2.new(0, 35, 0, 24)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = state and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.Parent = toggleBtn
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    
    yPos = yPos + 42
    return frame
end

local function AddSmallLabel(text, color)
    local label = Instance.new("TextLabel")
    label.Parent = Content
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 20, 0, yPos)
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(180, 180, 200)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    yPos = yPos + 22
    return label
end

local function AddDivider()
    local divider = Instance.new("Frame")
    divider.Parent = Content
    divider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Position = UDim2.new(0, 10, 0, yPos)
    divider.Size = UDim2.new(1, -20, 0, 1)
    yPos = yPos + 12
    return divider
end

-- ============================================
-- BUILD UI
-- ============================================
AddLabel("═══════ FEATURES ═══════", Color3.fromRGB(0, 200, 200), 14)

AddDivider()
AddLabel("⚡ Speed", Color3.fromRGB(100, 255, 100))
AddToggle("Enable Speed Boost", true, function(s)
    SpeedEnabled = s
    if s then
        applySpeed()
    else
        pcall(function()
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then humanoid.WalkSpeed = DEFAULT_SPEED end
            end
        end)
    end
end)
AddSmallLabel("Speed: " .. PERMANENT_SPEED .. " (Auto-applies)", Color3.fromRGB(150, 255, 150))

AddDivider()
AddLabel("👁️ ESP", Color3.fromRGB(100, 200, 255))
AddToggle("Player ESP", false, function(s)
    ESPEnabled = s
    updateESPVisibility()
end)
AddToggle("NPC/Zombie ESP", false, function(s)
    NPCESPEnabled = s
    if s then scanForNPCs() end
    updateESPVisibility()
end)
AddSmallLabel("Shows players and zombies through walls", Color3.fromRGB(180, 180, 200))

AddDivider()
AddLabel("🌍 Environment", Color3.fromRGB(255, 200, 100))
AddToggle("No Fog", false, function(s)
    NoFogEnabled = s
    if s then
        pcall(function()
            Lighting.FogEnd = 99999
            Lighting.FogStart = 99999
        end)
    else
        pcall(function()
            Lighting.FogEnd = 1000
            Lighting.FogStart = 0
        end)
    end
end)

AddDivider()
AddLabel("🍖 Survival", Color3.fromRGB(255, 150, 150))
AddToggle("Infinite Hunger", false, function(s)
    InfiniteHunger = s
    if s then startHungerLoop() end
end)
AddToggle("Infinite Thirst", false, function(s)
    InfiniteThirst = s
    if s then startThirstLoop() end
end)

AddDivider()
AddLabel("Made by Maryyy ❤️", Color3.fromRGB(0, 200, 200), 12)

-- Update canvas size
Content.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)

-- ============================================
-- DRAGGING
-- ============================================
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
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
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 40), "Out", "Quad", 0.3, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 400, 0, 300), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        TitleText.Text = "🎯 BRM5 PvE"
    end
end

MinBtn.MouseButton1Click:Connect(ToggleMinimize)

CloseBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    pcall(function()
        -- Clean up ESP
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("Highlight") or child:IsA("BillboardGui") then
                        child:Destroy()
                    end
                end
            end
        end
        -- Reset speed
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = DEFAULT_SPEED end
        end
        -- Reset fog
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
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
    
    local npcNames = {"NPC", "Zombie", "Enemy", "Bot", "Monster", "Walker", "Runner"}
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
    
    local color = isNPC and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 200, 255)
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
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

print("✅ BRM5 PvE Simple GUI Loaded!")
print("   Features: Speed | ESP | No Fog | Survival")
print("   Click '─' to minimize | '✕' to close")
