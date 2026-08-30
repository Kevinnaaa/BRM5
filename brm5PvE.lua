-- ============================================
-- BRM5 PvE v1 - NPC DETECTION + ADVANCED ESP
-- MODERN UI - Custom Teal Theme (#007F7C)
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer

-- ============================================
-- COLORS - TEAL THEME (#007F7C)
-- ============================================
local BACKGROUND = Color3.fromRGB(0, 127, 124)     -- #007F7C - Main teal
local TOPBAR = Color3.fromRGB(0, 145, 142)         -- Slightly lighter teal
local TABBG = Color3.fromRGB(0, 110, 107)          -- Darker teal for tabs
local ELEMBG = Color3.fromRGB(0, 135, 132)         -- Element background
local ELEMBGHOVER = Color3.fromRGB(20, 155, 152)   -- Element hover
local ACCENT = Color3.fromRGB(0, 200, 195)         -- Bright teal accent
local BORDER = Color3.fromRGB(0, 160, 157)         -- Border color
local TEXT = Color3.fromRGB(255, 255, 255)         -- White text
local TEXTDIM = Color3.fromRGB(190, 235, 233)      -- Dim text

-- ============================================
-- STATE
-- ============================================
local ScriptActive = true
local NoFogEnabled = false
local ESPEnabled = false
local SpeedBoostEnabled = true
local InfiniteHungerEnabled = false
local InfiniteThirstEnabled = false
local NPCESPEnabled = false

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local MAX_HUNGER = 100
local MAX_THIRST = 100
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()
local saniye, dakika, saat = 0, 0, 0
local isInGame = false
local isMinimized = false

-- ESP Configuration
local ESPConfig = {
    MaxDistance = 2000,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    HighlightEnabled = true,
    ShowHealth = true,
    ShowDistance = true,
    NPCMaxDistance = 1500,
    NPCColor = Color3.fromRGB(255, 0, 0),
}

local ESPObjects = {}
local NPCEntities = {}

-- ============================================
-- CORNER ROUNDING FUNCTION
-- ============================================
local function RoundCorners(frame, radius)
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, radius or 14)
end

-- ============================================
-- CHECK IF PLAYER IS IN GAME
-- ============================================
local function checkInGame()
    pcall(function()
        local char = player.Character
        if char and char.Parent == Workspace and char:FindFirstChild("Humanoid") then
            isInGame = true
        else
            isInGame = false
        end
    end)
    return isInGame
end

-- ============================================
-- GET TEAM COLOR
-- ============================================
local function getTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(0, 200, 195)
end

-- ============================================
-- DETECT IF ENTITY IS NPC
-- ============================================
local function isNPC(character)
    if not character or not character:IsA("Model") then return false end
    if not character:FindFirstChild("Humanoid") then return false end
    
    local owner = Players:GetPlayerFromCharacter(character)
    if owner then return false end
    
    -- Check name patterns
    local npcIndicators = {
        "NPC", "Zombie", "AI", "Enemy", "Bot", "Monster",
        "Walker", "Runner", "Boss", "Spawn", "Creep"
    }
    
    for _, indicator in ipairs(npcIndicators) do
        if character.Name:find(indicator) then
            return true
        end
    end
    
    -- Check tags
    local tags = character:GetDescendants()
    for _, tag in pairs(tags) do
        if tag:IsA("StringValue") or tag:IsA("ObjectValue") then
            local tagName = tag.Name:lower()
            if tagName:find("npc") or tagName:find("zombie") or tagName:find("enemy") or tagName:find("ai") then
                return true
            end
        end
    end
    
    -- Check attributes
    if character:GetAttribute("NPC") or 
       character:GetAttribute("Zombie") or 
       character:GetAttribute("Enemy") or
       character:GetAttribute("AI") then
        return true
    end
    
    return false
end

-- ============================================
-- CREATE UI
-- ============================================
local function createUI()
    -- MAIN FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = BACKGROUND
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -240)
    MainFrame.Size = UDim2.new(0, 640, 0, 480)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0
    MainFrame.ZIndex = 10
    MainFrame.Visible = true
    RoundCorners(MainFrame, 14)

    -- Border
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = MainFrame
    Stroke.Color = BORDER
    Stroke.Thickness = 1
    Stroke.Transparency = 0.3

    -- Shadow
    local Shadow = Instance.new("Frame")
    Shadow.Parent = MainFrame
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.6
    Shadow.BorderSizePixel = 0
    Shadow.Position = UDim2.new(0, 8, 0, 8)
    Shadow.Size = UDim2.new(1, -16, 1, -16)
    RoundCorners(Shadow, 14)

    -- ============================================
    -- MINIMIZED BAR
    -- ============================================
    local MinBar = Instance.new("Frame")
    MinBar.Name = "MinBar"
    MinBar.Parent = ScreenGui
    MinBar.BackgroundColor3 = BACKGROUND
    MinBar.BackgroundTransparency = 0
    MinBar.BorderSizePixel = 0
    MinBar.Position = UDim2.new(0.5, -150, 0.95, -20)
    MinBar.Size = UDim2.new(0, 300, 0, 40)
    MinBar.Visible = false
    MinBar.ZIndex = 20
    RoundCorners(MinBar, 14)
    local minStroke = Instance.new("UIStroke", MinBar)
    minStroke.Color = BORDER
    minStroke.Thickness = 1
    minStroke.Transparency = 0.3

    -- MinBar Shadow
    local MinShadow = Instance.new("Frame")
    MinShadow.Parent = MinBar
    MinShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MinShadow.BackgroundTransparency = 0.6
    MinShadow.BorderSizePixel = 0
    MinShadow.Position = UDim2.new(0, 4, 0, 4)
    MinShadow.Size = UDim2.new(1, -8, 1, -8)
    RoundCorners(MinShadow, 14)

    -- MinBar Status
    local MinIcon = Instance.new("TextLabel")
    MinIcon.Parent = MinBar
    MinIcon.BackgroundTransparency = 1
    MinIcon.Position = UDim2.new(0, 12, 0, 0)
    MinIcon.Size = UDim2.new(0, 25, 1, 0)
    MinIcon.Font = Enum.Font.GothamBold
    MinIcon.Text = "🎯"
    MinIcon.TextColor3 = ACCENT
    MinIcon.TextSize = 18

    local MinTitle = Instance.new("TextLabel")
    MinTitle.Parent = MinBar
    MinTitle.BackgroundTransparency = 1
    MinTitle.Position = UDim2.new(0, 42, 0, 0)
    MinTitle.Size = UDim2.new(0, 150, 1, 0)
    MinTitle.Font = Enum.Font.GothamBold
    MinTitle.Text = "BRM5 PvE v1"
    MinTitle.TextColor3 = TEXT
    MinTitle.TextSize = 14
    MinTitle.TextXAlignment = Enum.TextXAlignment.Left

    local MinStatus = Instance.new("TextLabel")
    MinStatus.Parent = MinBar
    MinStatus.BackgroundTransparency = 1
    MinStatus.Position = UDim2.new(0, 180, 0, 0)
    MinStatus.Size = UDim2.new(0, 80, 1, 0)
    MinStatus.Font = Enum.Font.Gotham
    MinStatus.Text = "● Running"
    MinStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
    MinStatus.TextSize = 11

    local MinExpandBtn = Instance.new("TextButton")
    MinExpandBtn.Parent = MinBar
    MinExpandBtn.BackgroundColor3 = ACCENT
    MinExpandBtn.BackgroundTransparency = 0.3
    MinExpandBtn.BorderSizePixel = 0
    MinExpandBtn.Position = UDim2.new(1, -45, 0.5, -15)
    MinExpandBtn.Size = UDim2.new(0, 30, 0, 30)
    MinExpandBtn.Font = Enum.Font.GothamBold
    MinExpandBtn.Text = "□"
    MinExpandBtn.TextColor3 = TEXT
    MinExpandBtn.TextSize = 16
    RoundCorners(MinExpandBtn, 15)

    MinExpandBtn.MouseEnter:Connect(function()
        TweenService:Create(MinExpandBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    MinExpandBtn.MouseLeave:Connect(function()
        TweenService:Create(MinExpandBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)

    -- ============================================
    -- TOP BAR
    -- ============================================
    local TopBar = Instance.new("Frame")
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = TOPBAR
    TopBar.BackgroundTransparency = 0
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    RoundCorners(TopBar, 14)

    local AccentLine = Instance.new("Frame")
    AccentLine.Parent = TopBar
    AccentLine.BackgroundColor3 = ACCENT
    AccentLine.BorderSizePixel = 0
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.Size = UDim2.new(1, 0, 0, 2)

    -- FPS Display
    local FPSDisplay = Instance.new("TextLabel")
    FPSDisplay.Parent = TopBar
    FPSDisplay.BackgroundTransparency = 1
    FPSDisplay.Position = UDim2.new(1, -220, 0, 8)
    FPSDisplay.Size = UDim2.new(0, 55, 0, 18)
    FPSDisplay.Font = Enum.Font.GothamBold
    FPSDisplay.Text = "FPS: --"
    FPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
    FPSDisplay.TextSize = 11
    FPSDisplay.TextXAlignment = Enum.TextXAlignment.Right

    local PingDisplay = Instance.new("TextLabel")
    PingDisplay.Parent = TopBar
    PingDisplay.BackgroundTransparency = 1
    PingDisplay.Position = UDim2.new(1, -165, 0, 8)
    PingDisplay.Size = UDim2.new(0, 65, 0, 18)
    PingDisplay.Font = Enum.Font.GothamBold
    PingDisplay.Text = "Ping: --"
    PingDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
    PingDisplay.TextSize = 11
    PingDisplay.TextXAlignment = Enum.TextXAlignment.Right

    local TimerDisplay = Instance.new("TextLabel")
    TimerDisplay.Parent = TopBar
    TimerDisplay.BackgroundTransparency = 1
    TimerDisplay.Position = UDim2.new(1, -100, 0, 8)
    TimerDisplay.Size = UDim2.new(0, 80, 0, 18)
    TimerDisplay.Font = Enum.Font.GothamBold
    TimerDisplay.Text = "0:0:0"
    TimerDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
    TimerDisplay.TextSize = 11
    TimerDisplay.TextXAlignment = Enum.TextXAlignment.Right

    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Parent = TopBar
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 15, 0, 0)
    Icon.Size = UDim2.new(0, 35, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = "🎯"
    Icon.TextColor3 = ACCENT
    Icon.TextSize = 22

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 55, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "BRM5 PvE v1"
    Title.TextColor3 = TEXT
    Title.TextSize = 19
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = TopBar
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 55, 0, 26)
    Subtitle.Size = UDim2.new(0, 200, 0, 20)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "by Maryyy | NPC Detection + Advanced ESP"
    Subtitle.TextColor3 = TEXTDIM
    Subtitle.TextSize = 11
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TopBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    MinBtn.BackgroundTransparency = 0.3
    MinBtn.BorderSizePixel = 0
    MinBtn.Position = UDim2.new(1, -45, 0.5, -15)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "─"
    MinBtn.TextColor3 = TEXT
    MinBtn.TextSize = 18
    RoundCorners(MinBtn, 15)

    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)

    -- ============================================
    -- TABS
    -- ============================================
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = TABBG
    TabContainer.BackgroundTransparency = 0
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 55)
    TabContainer.Size = UDim2.new(0, 160, 1, -55)

    local Content = Instance.new("ScrollingFrame")
    Content.Parent = MainFrame
    Content.BackgroundColor3 = BACKGROUND
    Content.BackgroundTransparency = 0
    Content.BorderSizePixel = 0
    Content.Position = UDim2.new(0, 160, 0, 55)
    Content.Size = UDim2.new(1, -160, 1, -55)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 157)

    local currentTab = nil
    local tabContents = {}

    -- ============================================
    -- UI ELEMENTS
    -- ============================================
    local function CreateTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Parent = TabContainer
        btn.BackgroundColor3 = TABBG
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0, 5, 0, #TabContainer:GetChildren() * 48 + 10)
        btn.Size = UDim2.new(1, -10, 0, 42)
        btn.Font = Enum.Font.Gotham
        btn.Text = "  " .. icon .. "  " .. name
        btn.TextColor3 = TEXTDIM
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        RoundCorners(btn, 8)
        
        local indicator = Instance.new("Frame")
        indicator.Parent = btn
        indicator.BackgroundColor3 = ACCENT
        indicator.BorderSizePixel = 0
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Visible = false
        RoundCorners(indicator, 2)
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = ELEMBGHOVER}):Play()
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= name then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = TABBG}):Play()
            end
        end)
        
        local tabContainer = Instance.new("Frame")
        tabContainer.Name = name .. "Content"
        tabContainer.Parent = Content
        tabContainer.BackgroundTransparency = 1
        tabContainer.Size = UDim2.new(1, 0, 0, 0)
        tabContainer.Visible = false
        tabContainer.ZIndex = 15
        
        tabContents[name] = {
            container = tabContainer,
            yPos = 15,
            btn = btn,
            indicator = indicator
        }
        
        local function select()
            if currentTab == name then return end
            currentTab = name
            
            for _, data in pairs(tabContents) do
                data.container.Visible = false
                data.btn.BackgroundColor3 = TABBG
                data.btn.TextColor3 = TEXTDIM
                data.indicator.Visible = false
            end
            
            local data = tabContents[name]
            if data then
                data.container.Visible = true
                data.btn.BackgroundColor3 = ELEMBGHOVER
                data.btn.TextColor3 = TEXT
                data.indicator.Visible = true
                
                task.wait(0.05)
                Content.CanvasSize = UDim2.new(0, 0, 0, data.yPos + 30)
            end
        end
        
        btn.MouseButton1Click:Connect(select)
        
        return {
            select = select,
            container = tabContainer,
            getY = function() return tabContents[name].yPos end,
            setY = function(val) tabContents[name].yPos = val end
        }
    end

    local function AddSection(text)
        local data = tabContents[currentTab]
        if not data then return end
        
        local container = data.container
        local y = data.yPos
        
        local frame = Instance.new("Frame")
        frame.Parent = container
        frame.BackgroundTransparency = 1
        frame.Position = UDim2.new(0, 15, 0, y)
        frame.Size = UDim2.new(1, -30, 0, 30)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = "▸ " .. text
        label.TextColor3 = TEXTDIM
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        data.yPos = data.yPos + 38
        return frame
    end

    local function AddDivider()
        local data = tabContents[currentTab]
        if not data then return end
        
        local container = data.container
        local y = data.yPos
        
        local frame = Instance.new("Frame")
        frame.Parent = container
        frame.BackgroundColor3 = BORDER
        frame.BackgroundTransparency = 0.5
        frame.BorderSizePixel = 0
        frame.Position = UDim2.new(0, 20, 0, y)
        frame.Size = UDim2.new(1, -40, 0, 1)
        
        data.yPos = data.yPos + 10
        return frame
    end

    local function AddLabel(text, color, size)
        local data = tabContents[currentTab]
        if not data then return end
        
        local container = data.container
        local y = data.yPos
        
        local frame = Instance.new("Frame")
        frame.Parent = container
        frame.BackgroundTransparency = 1
        frame.Position = UDim2.new(0, 15, 0, y)
        frame.Size = UDim2.new(1, -30, 0, 30)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = text
        label.TextColor3 = color or TEXT
        label.TextSize = size or 16
        label.TextXAlignment = Enum.TextXAlignment.Center
        
        data.yPos = data.yPos + 38
        return frame
    end

    local function AddSmallLabel(text, color)
        local data = tabContents[currentTab]
        if not data then return end
        
        local container = data.container
        local y = data.yPos
        
        local frame = Instance.new("Frame")
        frame.Parent = container
        frame.BackgroundTransparency = 1
        frame.Position = UDim2.new(0, 15, 0, y)
        frame.Size = UDim2.new(1, -30, 0, 25)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = color or TEXTDIM
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Center
        
        data.yPos = data.yPos + 30
        return frame
    end

    local function AddToggle(text, default, callback)
        local data = tabContents[currentTab]
        if not data then return end
        
        local container = data.container
        local y = data.yPos
        local state = default or false
        
        local frame = Instance.new("Frame")
        frame.Parent = container
        frame.BackgroundColor3 = ELEMBG
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Position = UDim2.new(0, 15, 0, y)
        frame.Size = UDim2.new(1, -30, 0, 45)
        RoundCorners(frame, 10)
        local frameStroke = Instance.new("UIStroke", frame)
        frameStroke.Color = BORDER
        frameStroke.Thickness = 1
        frameStroke.Transparency = 0.3
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Size = UDim2.new(0, 280, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = TEXT
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggle = Instance.new("Frame")
        toggle.Parent = frame
        toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        toggle.BackgroundTransparency = 0
        toggle.BorderSizePixel = 0
        toggle.Position = UDim2.new(1, -55, 0.5, -15)
        toggle.Size = UDim2.new(0, 40, 0, 30)
        RoundCorners(toggle, 15)
        
        local indicator = Instance.new("Frame")
        indicator.Parent = toggle
        indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
        indicator.BorderSizePixel = 0
        indicator.Position = UDim2.new(0, 3, 0.5, -12)
        indicator.Size = UDim2.new(0, 24, 0, 24)
        RoundCorners(indicator, 12)
        
        local function update(val)
            state = val
            if state then
                TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = ACCENT}):Play()
                TweenService:Create(indicator, TweenInfo.new(0.3), {Position = UDim2.new(1, -27, 0.5, -12)}):Play()
            else
                TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}):Play()
                TweenService:Create(indicator, TweenInfo.new(0.3), {Position = UDim2.new(0, 3, 0.5, -12)}):Play()
            end
            if callback then callback(state) end
        end
        
        toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                update(not state)
            end
        end)
        
        update(state)
        data.yPos = data.yPos + 53
        return frame
    end

    -- ============================================
    -- CREATE TABS
    -- ============================================
    local speedTab = CreateTab("Speed", "🏃")
    local survivalTab = CreateTab("Survival", "🍖")
    local visualsTab = CreateTab("Visuals", "👁️")
    local settingsTab = CreateTab("Settings", "⚙️")

    -- ============================================
    -- SPEED TAB
    -- ============================================
    speedTab.select()

    AddLabel("═══════════════════════════════════", ACCENT, 14)
    AddLabel("🏃 PERMANENT SPEED", ACCENT, 18)
    AddLabel("═══════════════════════════════════", ACCENT, 14)

    AddDivider()
    AddSmallLabel("⚡ Speed: " .. PERMANENT_SPEED .. " (Always On)", Color3.fromRGB(100, 255, 100))
    AddSmallLabel("📊 Default: " .. DEFAULT_SPEED, TEXTDIM)
    AddSmallLabel("✅ Speed auto-applies on respawn", Color3.fromRGB(100, 255, 100))

    -- ============================================
    -- SURVIVAL TAB (Zombies)
    -- ============================================
    survivalTab.select()

    AddLabel("═══════════════════════════════════", ACCENT, 14)
    AddLabel("🍖 SURVIVAL CHEATS", ACCENT, 18)
    AddLabel("═══════════════════════════════════", ACCENT, 14)

    AddDivider()
    AddSection("Hunger & Thirst")
    AddToggle("🍖 Infinite Hunger", false, function(s)
        InfiniteHungerEnabled = s
        if s then
            task.spawn(function()
                while InfiniteHungerEnabled and ScriptActive do
                    if isInGame then
                        pcall(function()
                            local char = player.Character
                            if char then
                                for _, child in pairs(char:GetDescendants()) do
                                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                                        local name = child.Name:lower()
                                        if name:find("hunger") or name:find("food") then
                                            child.Value = MAX_HUNGER
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
    end)
    AddSmallLabel("Keeps hunger at maximum (" .. MAX_HUNGER .. ")", Color3.fromRGB(255, 200, 100))

    AddToggle("💧 Infinite Thirst", false, function(s)
        InfiniteThirstEnabled = s
        if s then
            task.spawn(function()
                while InfiniteThirstEnabled and ScriptActive do
                    if isInGame then
                        pcall(function()
                            local char = player.Character
                            if char then
                                for _, child in pairs(char:GetDescendants()) do
                                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                                        local name = child.Name:lower()
                                        if name:find("thirst") or name:find("water") or name:find("drink") then
                                            child.Value = MAX_THIRST
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
    end)
    AddSmallLabel("Keeps thirst at maximum (" .. MAX_THIRST .. ")", Color3.fromRGB(100, 200, 255))

    -- ============================================
    -- VISUALS TAB
    -- ============================================
    visualsTab.select()

    AddLabel("═══════════════════════════════════", ACCENT, 14)
    AddLabel("👁️ VISUALS", ACCENT, 18)
    AddLabel("═══════════════════════════════════", ACCENT, 14)

    AddDivider()
    AddSection("Player ESP")
    AddToggle("Enable Player ESP", false, function(s)
        ESPEnabled = s
        if isInGame then
            for _, espData in pairs(ESPObjects) do
                if not espData.IsNPC then
                    if espData.Highlight then espData.Highlight.Enabled = s end
                    if espData.Billboard then espData.Billboard.Enabled = s end
                end
            end
        end
    end)

    AddDivider()
    AddSection("NPC ESP")
    AddToggle("Enable NPC ESP", false, function(s)
        NPCESPEnabled = s
        if s and isInGame then
            scanForNPCs()
        else
            for key, espData in pairs(ESPObjects) do
                if espData.IsNPC then
                    if espData.Billboard then espData.Billboard:Destroy() end
                    if espData.Highlight then espData.Highlight:Destroy() end
                    ESPObjects[key] = nil
                    NPCEntities[key] = nil
                end
            end
        end
    end)
    AddSmallLabel("🧟 Detects Zombies & NPCs", Color3.fromRGB(255, 100, 100))
    AddSmallLabel("🟢 Green = Close (<50 studs)", Color3.fromRGB(100, 255, 100))
    AddSmallLabel("🟡 Yellow = Medium (<150 studs)", Color3.fromRGB(255, 200, 100))
    AddSmallLabel("🔴 Red = Far (>150 studs)", Color3.fromRGB(255, 100, 100))

    AddDivider()
    AddSection("Environment")
    AddToggle("🌫️ No Fog", false, function(s)
        NoFogEnabled = s
        if s then
            pcall(function()
                Lighting.FogEnd = 99999
                Lighting.FogStart = 99999
                Lighting.Brightness = 2
                local at = Lighting:FindFirstChildOfClass("Atmosphere")
                if at then at:Destroy() end
            end)
        else
            pcall(function()
                Lighting.FogEnd = 1000
                Lighting.FogStart = 0
                Lighting.Brightness = 1
            end)
        end
    end)

    -- ============================================
    -- SETTINGS TAB
    -- ============================================
    settingsTab.select()

    AddLabel("═══════════════════════════════════", ACCENT, 14)
    AddLabel("⚙️ SETTINGS", ACCENT, 18)
    AddLabel("═══════════════════════════════════", ACCENT, 14)

    AddDivider()
    AddSection("Info")
    AddSmallLabel("🎯 " .. player.Name, TEXT)
    AddSmallLabel("Features: Speed + Hunger/Thirst + ESP + No Fog", TEXTDIM)
    AddSmallLabel("NPC Detection: Automatically finds zombies", Color3.fromRGB(255, 200, 100))

    AddDivider()
    AddSection("Terminate")
    local termBtn = Instance.new("Frame")
    termBtn.Parent = settingsTab.container
    termBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    termBtn.BackgroundTransparency = 0
    termBtn.BorderSizePixel = 0
    termBtn.Position = UDim2.new(0, 15, 0, settingsTab.getY())
    termBtn.Size = UDim2.new(1, -30, 0, 50)
    RoundCorners(termBtn, 10)

    local termLabel = Instance.new("TextLabel")
    termLabel.Parent = termBtn
    termLabel.BackgroundTransparency = 1
    termLabel.Size = UDim2.new(1, 0, 1, 0)
    termLabel.Font = Enum.Font.GothamBold
    termLabel.Text = "⚠️ TERMINATE SCRIPT"
    termLabel.TextColor3 = TEXT
    termLabel.TextSize = 16
    termLabel.TextXAlignment = Enum.TextXAlignment.Center

    termBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Confirm dialog
            local confirm = Instance.new("Frame")
            confirm.Parent = MainFrame
            confirm.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            confirm.BackgroundTransparency = 0.5
            confirm.BorderSizePixel = 0
            confirm.Position = UDim2.new(0, 0, 0, 0)
            confirm.Size = UDim2.new(1, 0, 1, 0)
            confirm.ZIndex = 999
            
            local box = Instance.new("Frame")
            box.Parent = confirm
            box.BackgroundColor3 = ELEMBG
            box.BackgroundTransparency = 0
            box.BorderSizePixel = 0
            box.Position = UDim2.new(0.5, -150, 0.5, -60)
            box.Size = UDim2.new(0, 300, 0, 120)
            RoundCorners(box, 12)
            box.ZIndex = 1000
            
            local warnLabel = Instance.new("TextLabel")
            warnLabel.Parent = box
            warnLabel.BackgroundTransparency = 1
            warnLabel.Position = UDim2.new(0, 0, 0, 10)
            warnLabel.Size = UDim2.new(1, 0, 0, 30)
            warnLabel.Font = Enum.Font.GothamBold
            warnLabel.Text = "⚠️ Terminate Script?"
            warnLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            warnLabel.TextSize = 18
            
            local descLabel = Instance.new("TextLabel")
            descLabel.Parent = box
            descLabel.BackgroundTransparency = 1
            descLabel.Position = UDim2.new(0, 10, 0, 45)
            descLabel.Size = UDim2.new(1, -20, 0, 20)
            descLabel.Font = Enum.Font.Gotham
            descLabel.Text = "This will stop all script execution."
            descLabel.TextColor3 = TEXTDIM
            descLabel.TextSize = 13
            
            local yesBtn = Instance.new("TextButton")
            yesBtn.Parent = box
            yesBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            yesBtn.BackgroundTransparency = 0
            yesBtn.BorderSizePixel = 0
            yesBtn.Position = UDim2.new(0.5, -110, 1, -45)
            yesBtn.Size = UDim2.new(0, 100, 0, 35)
            yesBtn.Font = Enum.Font.GothamBold
            yesBtn.Text = "Terminate"
            yesBtn.TextColor3 = TEXT
            yesBtn.TextSize = 14
            RoundCorners(yesBtn, 8)
            
            local noBtn = Instance.new("TextButton")
            noBtn.Parent = box
            noBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            noBtn.BackgroundTransparency = 0
            noBtn.BorderSizePixel = 0
            noBtn.Position = UDim2.new(0.5, 10, 1, -45)
            noBtn.Size = UDim2.new(0, 100, 0, 35)
            noBtn.Font = Enum.Font.GothamBold
            noBtn.Text = "Cancel"
            noBtn.TextColor3 = TEXT
            noBtn.TextSize = 14
            RoundCorners(noBtn, 8)
            
            yesBtn.MouseButton1Click:Connect(function()
                ScriptActive = false
                pcall(function()
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                            local hl = obj:FindFirstChildOfClass("Highlight")
                            if hl then hl:Destroy() end
                            local bg = obj:FindFirstChildOfClass("BillboardGui")
                            if bg then bg:Destroy() end
                        end
                    end
                end)
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = DEFAULT_SPEED
                    end
                end)
                pcall(function()
                    Lighting.FogEnd = 1000
                    Lighting.FogStart = 0
                    Lighting.Brightness = 1
                end)
                pcall(function() ScreenGui:Destroy() end)
                print("✅ Script terminated. All features disabled.")
            end)
            
            noBtn.MouseButton1Click:Connect(function()
                confirm:Destroy()
            end)
            
            confirm.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    confirm:Destroy()
                end
            end)
        end
    end)

    settingsTab.setY(settingsTab.getY() + 58)

    AddDivider()
    AddSmallLabel("Made with ❤️ by Maryyy", Color3.fromRGB(100, 200, 195))
    AddSmallLabel("Click '─' to minimize", TEXTDIM)

    -- ============================================
    -- SELECT DEFAULT TAB
    -- ============================================
    speedTab.select()

    -- ============================================
    -- WINDOW CONTROLS
    -- ============================================
    local function MinimizeUI()
        if isMinimized then return end
        isMinimized = true
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.2)
        MainFrame.Visible = false
        
        MinBar.Visible = true
        MinBar.Position = UDim2.new(0.5, -150, 0.95, 20)
        MinBar.Size = UDim2.new(0, 0, 0, 40)
        MinBar.BackgroundTransparency = 1
        
        TweenService:Create(MinBar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -150, 0.95, -20),
            Size = UDim2.new(0, 300, 0, 40),
            BackgroundTransparency = 0
        }):Play()
    end

    local function ExpandUI()
        if not isMinimized then return end
        isMinimized = false
        
        TweenService:Create(MinBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.2)
        MinBar.Visible = false
        
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        MainFrame.Position = UDim2.new(0.5, -320, 0.5, -240)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 640, 0, 480),
            BackgroundTransparency = 0
        }):Play()
    end

    MinBtn.MouseButton1Click:Connect(MinimizeUI)
    MinExpandBtn.MouseButton1Click:Connect(ExpandUI)

    -- ============================================
    -- DRAGGABLE WINDOW
    -- ============================================
    local dragging = false
    local dragInput, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    MinBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MinBar.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MinBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if isMinimized then
                MinBar.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            else
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    return MainFrame, MinBar, TopBar
end

-- ============================================
-- NPC ESP FUNCTIONS
-- ============================================
local function createNPCESP(character)
    if not character or character:GetName() == "" then return end
    if Players:GetPlayerFromCharacter(character) then return end
    if not isNPC(character) then return end
    
    local npcKey = tostring(character)
    
    if ESPObjects[npcKey] then
        pcall(function()
            if ESPObjects[npcKey].Billboard then ESPObjects[npcKey].Billboard:Destroy() end
            if ESPObjects[npcKey].Highlight then ESPObjects[npcKey].Highlight:Destroy() end
        end)
        ESPObjects[npcKey] = nil
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart then return end
    
    local npcColor = ESPConfig.NPCColor
    
    local highlight = nil
    if ESPConfig.HighlightEnabled then
        highlight = Instance.new("Highlight")
        highlight.FillColor = npcColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.35
        highlight.OutlineTransparency = 0
        highlight.Enabled = ESPEnabled and NPCESPEnabled
        highlight.Parent = character
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head or rootPart
    billboard.Size = UDim2.new(0, 200, 0, 80)
    billboard.StudsOffset = head and Vector3.new(0, 3, 0) or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ESPEnabled and NPCESPEnabled
    billboard.Parent = character
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.ResetOnSpawn = false
    
    local mainContainer = Instance.new("Frame", billboard)
    mainContainer.Size = UDim2.new(1, 0, 1, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.BorderSizePixel = 0
    
    local nameLabel = Instance.new("TextLabel", mainContainer)
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🧟 " .. character.Name
    nameLabel.TextColor3 = npcColor
    nameLabel.TextSize = ESPConfig.TextSize
    nameLabel.Font = ESPConfig.Font
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local healthBarBg = Instance.new("Frame", mainContainer)
    healthBarBg.Size = UDim2.new(0.9, 0, 0, 12)
    healthBarBg.Position = UDim2.new(0.05, 0, 0, 18)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBarBg.BorderSizePixel = 1
    healthBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    local healthBgCorner = Instance.new("UICorner", healthBarBg)
    healthBgCorner.CornerRadius = UDim.new(0, 2)
    
    local healthBarFill = Instance.new("Frame", healthBarBg)
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBarFill.BorderSizePixel = 0
    local healthFillCorner = Instance.new("UICorner", healthBarFill)
    healthFillCorner.CornerRadius = UDim.new(0, 2)
    
    local healthLabel = Instance.new("TextLabel", mainContainer)
    healthLabel.Size = UDim2.new(1, 0, 0, 12)
    healthLabel.Position = UDim2.new(0, 0, 0, 20)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "HP: 100/100"
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 10
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Visible = ESPConfig.ShowHealth
    
    local distanceLabel = Instance.new("TextLabel", mainContainer)
    distanceLabel.Size = UDim2.new(1, 0, 0, 14)
    distanceLabel.Position = UDim2.new(0, 0, 0, 62)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance: 0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    distanceLabel.TextSize = 11
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Visible = ESPConfig.ShowDistance
    
    local typeLabel = Instance.new("TextLabel", mainContainer)
    typeLabel.Size = UDim2.new(1, 0, 0, 12)
    typeLabel.Position = UDim2.new(0, 0, 0, 48)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = "NPC"
    typeLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    typeLabel.TextSize = 10
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.TextXAlignment = Enum.TextXAlignment.Center
    typeLabel.TextStrokeTransparency = 0.5
    typeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    ESPObjects[npcKey] = {
        Billboard = billboard,
        Highlight = highlight,
        NameLabel = nameLabel,
        HealthBarFill = healthBarFill,
        HealthLabel = healthLabel,
        DistanceLabel = distanceLabel,
        TypeLabel = typeLabel,
        Humanoid = humanoid,
        RootPart = rootPart,
        Head = head,
        Character = character,
        IsNPC = true
    }
    
    NPCEntities[npcKey] = character
end

local function createPlayerESP(player)
    if player == Players.LocalPlayer then return end
    
    if ESPObjects[player.Name] then
        pcall(function()
            if ESPObjects[player.Name].Billboard then ESPObjects[player.Name].Billboard:Destroy() end
            if ESPObjects[player.Name].Highlight then ESPObjects[player.Name].Highlight:Destroy() end
        end)
        ESPObjects[player.Name] = nil
    end
    
    local function addESP(character)
        if not character or not isInGame then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not rootPart or not head then return end
        
        local teamColor = getTeamColor(player)
        
        local highlight = nil
        if ESPConfig.HighlightEnabled then
            highlight = Instance.new("Highlight")
            highlight.FillColor = teamColor
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Enabled = ESPEnabled
            highlight.Parent = character
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = ESPEnabled
        billboard.Parent = character
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        billboard.ResetOnSpawn = false
        
        local mainContainer = Instance.new("Frame", billboard)
        mainContainer.Size = UDim2.new(1, 0, 1, 0)
        mainContainer.BackgroundTransparency = 1
        mainContainer.BorderSizePixel = 0
        
        local nameLabel = Instance.new("TextLabel", mainContainer)
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "👤 " .. player.Name
        nameLabel.TextColor3 = teamColor
        nameLabel.TextSize = ESPConfig.TextSize
        nameLabel.Font = ESPConfig.Font
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local healthBarBg = Instance.new("Frame", mainContainer)
        healthBarBg.Size = UDim2.new(0.9, 0, 0, 12)
        healthBarBg.Position = UDim2.new(0.05, 0, 0, 18)
        healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBarBg.BorderSizePixel = 1
        healthBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        local healthBgCorner = Instance.new("UICorner", healthBarBg)
        healthBgCorner.CornerRadius = UDim.new(0, 2)
        
        local healthBarFill = Instance.new("Frame", healthBarBg)
        healthBarFill.Size = UDim2.new(1, 0, 1, 0)
        healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBarFill.BorderSizePixel = 0
        local healthFillCorner = Instance.new("UICorner", healthBarFill)
        healthFillCorner.CornerRadius = UDim.new(0, 2)
        
        local healthLabel = Instance.new("TextLabel", mainContainer)
        healthLabel.Size = UDim2.new(1, 0, 0, 12)
        healthLabel.Position = UDim2.new(0, 0, 0, 20)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "HP: 100/100"
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextSize = 10
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextXAlignment = Enum.TextXAlignment.Center
        healthLabel.TextStrokeTransparency = 0.5
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.Visible = ESPConfig.ShowHealth
        
        local distanceLabel = Instance.new("TextLabel", mainContainer)
        distanceLabel.Size = UDim2.new(1, 0, 0, 14)
        distanceLabel.Position = UDim2.new(0, 0, 0, 62)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "Distance: 0m"
        distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        distanceLabel.TextSize = 11
        distanceLabel.Font = Enum.Font.GothamBold
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distanceLabel.Visible = ESPConfig.ShowDistance
        
        ESPObjects[player.Name] = {
            Billboard = billboard,
            Highlight = highlight,
            NameLabel = nameLabel,
            HealthBarFill = healthBarFill,
            HealthLabel = healthLabel,
            DistanceLabel = distanceLabel,
            Humanoid = humanoid,
            RootPart = rootPart,
            Head = head,
            Character = character,
            IsNPC = false
        }
    end
    
    if player.Character then
        addESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if isInGame then
            addESP(character)
        end
    end)
end

local function scanForNPCs()
    if not isInGame or not (ESPEnabled and NPCESPEnabled) then
        for key, espData in pairs(ESPObjects) do
            if espData.IsNPC then
                if espData.Billboard then espData.Billboard:Destroy() end
                if espData.Highlight then espData.Highlight:Destroy() end
                ESPObjects[key] = nil
                NPCEntities[key] = nil
            end
        end
        return
    end
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local player = Players:GetPlayerFromCharacter(obj)
            if not player and isNPC(obj) then
                local key = tostring(obj)
                if not ESPObjects[key] then
                    createNPCESP(obj)
                end
            end
        end
    end
    
    for key, npc in pairs(NPCEntities) do
        if not npc or not npc.Parent then
            if ESPObjects[key] then
                if ESPObjects[key].Billboard then ESPObjects[key].Billboard:Destroy() end
                if ESPObjects[key].Highlight then ESPObjects[key].Highlight:Destroy() end
                ESPObjects[key] = nil
            end
            NPCEntities[key] = nil
        end
    end
end

local function updateESP()
    if not isInGame or not ESPEnabled then
        for _, espData in pairs(ESPObjects) do
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
        end
        return
    end
    
    local localChar = Players.LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for key, espData in pairs(ESPObjects) do
        if not espData or not espData.Character then continue end
        
        local character = espData.Character
        if not character or character.Parent ~= Workspace then
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
            continue
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not rootPart or not humanoid then
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
            continue
        end
        
        espData.RootPart = rootPart
        espData.Humanoid = humanoid
        espData.Head = head
        
        local dist = (localRoot.Position - rootPart.Position).Magnitude
        local maxDist = espData.IsNPC and ESPConfig.NPCMaxDistance or ESPConfig.MaxDistance
        local isInRange = dist <= maxDist
        
        local showESP = isInRange and (espData.IsNPC and NPCESPEnabled or true)
        
        if showESP then
            if espData.Highlight then
                espData.Highlight.Enabled = true
                espData.Highlight.Parent = character
            end
            if espData.Billboard then
                espData.Billboard.Enabled = true
                espData.Billboard.Adornee = head or rootPart
            end
            
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            if espData.HealthBarFill then
                espData.HealthBarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                if healthPercent > 0.5 then
                    espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.25 then
                    espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            if espData.HealthLabel then
                espData.HealthLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            end
            
            if espData.DistanceLabel then
                local distance = math.floor(dist)
                espData.DistanceLabel.Text = "Distance: " .. distance .. "m"
                if distance < 50 then
                    espData.DistanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif distance < 150 then
                    espData.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    espData.DistanceLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
            
            if not espData.IsNPC then
                local player = Players:GetPlayerFromCharacter(character)
                if player then
                    local teamColor = getTeamColor(player)
                    if espData.Highlight then
                        espData.Highlight.FillColor = teamColor
                    end
                    if espData.NameLabel then
                        espData.NameLabel.TextColor3 = teamColor
                    end
                end
            end
        else
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
        end
    end
end

-- ============================================
-- SPEED SYSTEM
-- ============================================
local function applySpeed()
    if not isInGame then return end
    pcall(function()
        if not Workspace or not Players.LocalPlayer then return end
        local char = Players.LocalPlayer.Character
        if char and char.Parent == Workspace then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = PERMANENT_SPEED
            end
        end
    end)
end

-- ============================================
-- CREATE UI AND START SCRIPT
-- ============================================
local MainFrame, MinBar = createUI()

-- ============================================
-- INITIALIZE EVENTS
-- ============================================
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    checkInGame()
    applySpeed()
end)

task.spawn(function()
    while ScriptActive do
        if isInGame then
            applySpeed()
        end
        task.wait(0.3)
    end
end)

-- ============================================
-- INITIALIZE ESP
-- ============================================
local function initializeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            createPlayerESP(player)
        end
    end
    
    if NPCESPEnabled then
        scanForNPCs()
    end
end

task.wait(1)
initializeESP()

Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        task.wait(1)
        createPlayerESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player.Name] then
        pcall(function()
            if ESPObjects[player.Name].Billboard then ESPObjects[player.Name].Billboard:Destroy() end
            if ESPObjects[player.Name].Highlight then ESPObjects[player.Name].Highlight:Destroy() end
        end)
        ESPObjects[player.Name] = nil
    end
end)

-- ============================================
-- ESP UPDATE LOOPS
-- ============================================
task.spawn(function()
    while ScriptActive do
        checkInGame()
        if ESPEnabled and isInGame then
            if NPCESPEnabled then
                scanForNPCs()
            end
            updateESP()
        else
            for _, espData in pairs(ESPObjects) do
                if espData.Highlight then espData.Highlight.Enabled = false end
                if espData.Billboard then espData.Billboard.Enabled = false end
            end
        end
        task.wait(0.15)
    end
end)

-- ============================================
-- UPDATE LOOPS
-- ============================================
task.spawn(function()
    while ScriptActive do
        fpsCount = fpsCount + 1
        if tick() - lastFPSUpdate >= 0.5 then
            fps = math.floor(fpsCount / (tick() - lastFPSUpdate))
            fpsCount = 0
            lastFPSUpdate = tick()
            pcall(function()
                local fpsLabel = MainFrame:FindFirstChild("TopBar")
                if fpsLabel then
                    local fpsDisplay = fpsLabel:FindFirstChild("FPSDisplay")
                    if fpsDisplay then
                        fpsDisplay.Text = "FPS: " .. fps
                        fpsDisplay.TextColor3 = fps >= 50 and Color3.fromRGB(0,255,100) or (fps >= 25 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
                    end
                end
            end)
        end
        task.wait()
    end
end)

task.spawn(function()
    while ScriptActive do
        pcall(function()
            local p = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
            local topBar = MainFrame:FindFirstChild("TopBar")
            if topBar then
                local pingDisplay = topBar:FindFirstChild("PingDisplay")
                if pingDisplay then
                    pingDisplay.Text = "Ping: " .. p .. "ms"
                    pingDisplay.TextColor3 = p <= 80 and Color3.fromRGB(100,200,255) or (p <= 150 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,100,100))
                end
            end
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while ScriptActive do
        saniye = saniye + 1
        if saniye >= 60 then saniye = 0; dakika = dakika + 1 end
        if dakika >= 60 then dakika = 0; saat = saat + 1 end
        pcall(function()
            local topBar = MainFrame:FindFirstChild("TopBar")
            if topBar then
                local timerDisplay = topBar:FindFirstChild("TimerDisplay")
                if timerDisplay then
                    timerDisplay.Text = saat .. ":" .. dakika .. ":" .. saniye
                end
            end
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            pcall(function()
                Lighting.FogEnd = 99999
                Lighting.FogStart = 99999
                local at = Lighting:FindFirstChildOfClass("Atmosphere")
                if at then at:Destroy() end
            })
        end
        task.wait(5)
    end
end)

-- Initial game state check
checkInGame()

print("✅ BRM5 PvE v1 Loaded! (Teal Theme)")
print("   Speed: " .. PERMANENT_SPEED)
print("   🧟 Survival Tab: Infinite Hunger & Thirst")
print("   👁 Visuals Tab: Player ESP + NPC/Zombie ESP")
print("   🎨 Theme: Teal #007F7C")
print("   ✅ Fixed: No more black screen when going to main menu")
