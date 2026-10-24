-- ============================================
-- BRM5 PvE v1 - NO ESP + NO RECOIL + AUTO ANTI-AFK
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
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- ============================================
-- COLORS - TEAL THEME (#007F7C)
-- ============================================
local BACKGROUND = Color3.fromRGB(0, 127, 124)
local TOPBAR = Color3.fromRGB(0, 145, 142)
local TABBG = Color3.fromRGB(0, 110, 107)
local ELEMBG = Color3.fromRGB(0, 135, 132)
local ELEMBGHOVER = Color3.fromRGB(20, 155, 152)
local ACCENT = Color3.fromRGB(0, 200, 195)
local BORDER = Color3.fromRGB(0, 160, 157)
local TEXT = Color3.fromRGB(255, 255, 255)
local TEXTDIM = Color3.fromRGB(190, 235, 233)

-- ============================================
-- STATE
-- ============================================
local ScriptActive = true
local NoFogEnabled = false
local NoRecoilEnabled = false
local SpeedBoostEnabled = true
local InfiniteHungerEnabled = false
local InfiniteThirstEnabled = false

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local MAX_HUNGER = 100
local MAX_THIRST = 100
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()
local saniye, dakika, saat = 0, 0, 0
local isInGame = false
local isMinimized = false

-- No Recoil settings
local RECOIL_STRENGTH = 15

-- ============================================
-- AUTO ANTI-AFK (ALWAYS ON)
-- ============================================
player.Idled:Connect(function()
    if ScriptActive then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ============================================
-- AGGRESSIVE FOG REMOVAL
-- ============================================
local function RemoveFog()
    pcall(function()
        Lighting.FogEnd = 999999
        Lighting.FogStart = 999999
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere:Destroy() end
        
        local blur = Lighting:FindFirstChildOfClass("BlurEffect")
        if blur then blur:Destroy() end
        
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                local childName = string.lower(child.Name)
                if string.find(childName, "fog") or string.find(childName, "weather") then
                    child:Destroy()
                end
            end
        end
        
        local terrain = Workspace:FindFirstChild("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
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
    end)
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
-- CORNER ROUNDING
-- ============================================
local function RoundCorners(frame, radius)
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, radius or 14)
end

-- ============================================
-- MAIN FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = BACKGROUND
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -240)
MainFrame.Size = UDim2.new(0, 640, 0, 480)
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 10
RoundCorners(MainFrame, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Parent = MainFrame
Stroke.Color = BORDER
Stroke.Thickness = 1
Stroke.Transparency = 0.3

-- ============================================
-- MINIMIZED BAR
-- ============================================
local MinBar = Instance.new("Frame")
MinBar.Name = "MinBar"
MinBar.Parent = ScreenGui
MinBar.BackgroundColor3 = BACKGROUND
MinBar.BorderSizePixel = 0
MinBar.Position = UDim2.new(0.5, -150, 0.95, -20)
MinBar.Size = UDim2.new(0, 300, 0, 40)
MinBar.Visible = false
MinBar.ZIndex = 20
RoundCorners(MinBar, 14)
Instance.new("UIStroke", MinBar).Color = BORDER

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

-- ============================================
-- TOP BAR
-- ============================================
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = TOPBAR
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 55)
RoundCorners(TopBar, 14)

local AccentLine = Instance.new("Frame")
AccentLine.Parent = TopBar
AccentLine.BackgroundColor3 = ACCENT
AccentLine.BorderSizePixel = 0
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.Size = UDim2.new(1, 0, 0, 2)

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

local Icon = Instance.new("TextLabel")
Icon.Parent = TopBar
Icon.BackgroundTransparency = 1
Icon.Position = UDim2.new(0, 15, 0, 0)
Icon.Size = UDim2.new(0, 35, 1, 0)
Icon.Font = Enum.Font.GothamBold
Icon.Text = "🎯"
Icon.TextColor3 = ACCENT
Icon.TextSize = 22

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
Subtitle.Text = "No Recoil + No Fog + Auto Anti-AFK + Speed"
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

-- ============================================
-- TABS
-- ============================================
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = TABBG
TabContainer.BorderSizePixel = 0
TabContainer.Position = UDim2.new(0, 0, 0, 55)
TabContainer.Size = UDim2.new(0, 160, 1, -55)

local Content = Instance.new("ScrollingFrame")
Content.Parent = MainFrame
Content.BackgroundColor3 = BACKGROUND
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 160, 0, 55)
Content.Size = UDim2.new(1, -160, 1, -55)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = BORDER

local currentTab = nil
local tabContents = {}

-- ============================================
-- UI HELPERS
-- ============================================
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.BackgroundColor3 = TABBG
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
    
    local frame = Instance.new("Frame")
    frame.Parent = data.container
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0, 15, 0, data.yPos)
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
    
    local frame = Instance.new("Frame")
    frame.Parent = data.container
    frame.BackgroundColor3 = BORDER
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 20, 0, data.yPos)
    frame.Size = UDim2.new(1, -40, 0, 1)
    
    data.yPos = data.yPos + 10
    return frame
end

local function AddLabel(text, color, size)
    local data = tabContents[currentTab]
    if not data then return end
    
    local frame = Instance.new("Frame")
    frame.Parent = data.container
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0, 15, 0, data.yPos)
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
    
    local frame = Instance.new("Frame")
    frame.Parent = data.container
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0, 15, 0, data.yPos)
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
    
    local state = default or false
    
    local frame = Instance.new("Frame")
    frame.Parent = data.container
    frame.BackgroundColor3 = ELEMBG
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 15, 0, data.yPos)
    frame.Size = UDim2.new(1, -30, 0, 45)
    RoundCorners(frame, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = BORDER
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    
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
local combatTab = CreateTab("Combat", "🔫")
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
AddSmallLabel("✅ Auto-applies on respawn", Color3.fromRGB(100, 255, 100))

-- ============================================
-- COMBAT TAB (No Recoil)
-- ============================================
combatTab.select()
AddLabel("═══════════════════════════════════", ACCENT, 14)
AddLabel("🔫 WEAPON MODS", ACCENT, 18)
AddLabel("═══════════════════════════════════", ACCENT, 14)
AddDivider()
AddSection("Recoil Control")
AddToggle("🔫 No Recoil", false, function(s)
    NoRecoilEnabled = s
end)
AddSmallLabel("Compensates weapon kick while firing", Color3.fromRGB(100, 255, 200))
AddSmallLabel("Toggle ON, then fire your weapon normally", TEXTDIM)

-- ============================================
-- SURVIVAL TAB
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
AddSmallLabel("Keeps hunger at maximum", Color3.fromRGB(255, 200, 100))

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
                                    if name:find("thirst") or name:find("water") then
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
AddSmallLabel("Keeps thirst at maximum", Color3.fromRGB(100, 200, 255))

-- ============================================
-- VISUALS TAB (No ESP)
-- ============================================
visualsTab.select()
AddLabel("═══════════════════════════════════", ACCENT, 14)
AddLabel("👁️ VISUALS", ACCENT, 18)
AddLabel("═══════════════════════════════════", ACCENT, 14)
AddDivider()
AddSection("Environment")
AddToggle("🌫️ No Fog (Aggressive)", false, function(s)
    NoFogEnabled = s
    if s then
        RemoveFog()
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
AddSmallLabel("Removes ALL fog including atmosphere", Color3.fromRGB(100, 255, 200))
AddSmallLabel("Increases brightness and visibility", Color3.fromRGB(160, 180, 200))

-- ============================================
-- SETTINGS TAB (No Anti-AFK toggle)
-- ============================================
settingsTab.select()
AddLabel("═══════════════════════════════════", ACCENT, 14)
AddLabel("⚙️ SETTINGS", ACCENT, 18)
AddLabel("═══════════════════════════════════", ACCENT, 14)
AddDivider()
AddSection("Status")
AddSmallLabel("🤖 Anti-AFK: ACTIVE (default)", Color3.fromRGB(100, 255, 200))
AddSmallLabel("Prevents idle kick automatically", TEXTDIM)

AddDivider()
AddSection("Info")
AddSmallLabel("🎯 " .. player.Name, TEXT)
AddSmallLabel("Features: Speed + No Recoil + No Fog + Auto Anti-AFK", TEXTDIM)

AddDivider()
AddSection("Terminate")
local termBtn = Instance.new("Frame")
termBtn.Parent = settingsTab.container
termBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
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
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = DEFAULT_SPEED
                end
            end)
            pcall(RestoreFog)
            pcall(function() ScreenGui:Destroy() end)
            print("✅ Script terminated.")
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
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    MainFrame.Visible = false
    MinBar.Visible = true
    TweenService:Create(MinBar, TweenInfo.new(0.4), {Size = UDim2.new(0, 300, 0, 40)}):Play()
end

local function ExpandUI()
    if not isMinimized then return end
    isMinimized = false
    TweenService:Create(MinBar, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 40)}):Play()
    task.wait(0.2)
    MinBar.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 640, 0, 480)}):Play()
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
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- SPEED SYSTEM
-- ============================================
local function applySpeed()
    if not isInGame then return end
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
    checkInGame()
    applySpeed()
    if NoFogEnabled then RemoveFog() end
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
-- NO RECOIL SYSTEM
-- ============================================
task.spawn(function()
    while ScriptActive do
        if NoRecoilEnabled and isInGame then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                pcall(function()
                    local mousemoverel = mousemoverel or (Input and Input.MouseMoveRel) or mouse_moverel
                    if mousemoverel then
                        mousemoverel(0, RECOIL_STRENGTH)
                    end
                end)
            end
            task.wait(0.01)
        else
            task.wait(0.1)
        end
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
                FPSDisplay.Text = "FPS: " .. fps
                FPSDisplay.TextColor3 = fps >= 50 and Color3.fromRGB(0,255,100) or (fps >= 25 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
            end)
        end
        task.wait()
    end
end)

task.spawn(function()
    while ScriptActive do
        pcall(function()
            local p = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
            PingDisplay.Text = "Ping: " .. p .. "ms"
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
            TimerDisplay.Text = saat .. ":" .. dakika .. ":" .. saniye
        end)
        task.wait(1)
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
checkInGame()

print("✅ BRM5 PvE v1 Loaded! (No ESP + No Recoil + Auto Anti-AFK)")
print("   Speed: " .. PERMANENT_SPEED)
print("   🤖 Anti-AFK: ACTIVE (always on)")
print("   🔫 Combat Tab: No Recoil")
print("   🌫️ No Fog: Aggressive removal")
print("   🍖 Survival: Infinite Hunger & Thirst")
