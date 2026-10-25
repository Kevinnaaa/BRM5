--[[
    BRM5 PvE v1 - MAIN MENU SAFE VERSION
    Completely fixed - no more blank main menu
    All features automatically disable when in menu
    UI toggled with ` (backtick) key
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local ScriptActive = true
local NoFogEnabled = false
local ESPEnabled = false
local InfiniteHungerEnabled = false
local InfiniteThirstEnabled = false
local UIVisible = true

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local MAX_HUNGER = 100
local MAX_THIRST = 100
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()
local saniye, dakika, saat = 0, 0, 0

-- =============================================
-- MAIN MENU DETECTION
-- =============================================
local function isInGame()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char.Parent == Workspace and char:FindFirstChild("Humanoid") then
            local camera = workspace.CurrentCamera
            if camera and camera.Parent == Workspace then
                return true
            end
        end
        return false
    end)
    return false
end

-- =============================================
-- CLEAN UP PREVIOUS INSTANCES
-- =============================================
if getgenv().BRM5Loaded then
    getgenv().BRM5Loaded = false
    pcall(function()
        if CoreGui:FindFirstChild("BRM5GUI") then
            CoreGui.BRM5GUI:Destroy()
        end
    end)

    pcall(function()
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local hl = obj:FindFirstChildOfClass("Highlight")
                if hl then hl:Destroy() end
            end
        end
    end)

    pcall(function()
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end)
end
getgenv().BRM5Loaded = true

-- =============================================
-- SAFE SPEED
-- =============================================
local function applySpeed()
    if not isInGame() then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char and char.Parent == Workspace then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.WalkSpeed then
                humanoid.WalkSpeed = PERMANENT_SPEED
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if isInGame() then
        applySpeed()
    end
end)

task.spawn(function()
    while ScriptActive do
        if isInGame() then
            applySpeed()
        end
        task.wait(0.5)
    end
end)

-- =============================================
-- SAFE HUNGER/THIRST
-- =============================================
local function findHungerThirstValues()
    if not isInGame() then return nil, nil end

    local hungerValue, thirstValue = nil, nil

    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end

        for _, child in pairs(char:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local name = child.Name:lower()
                if name:find("hunger") or name:find("food") then
                    hungerValue = child
                elseif name:find("thirst") or name:find("water") or name:find("drink") then
                    thirstValue = child
                end
            end
        end

        if not hungerValue or not thirstValue then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, child in pairs(playerGui:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local name = child.Name:lower()
                        if (name:find("hunger") or name:find("food")) and not hungerValue then
                            hungerValue = child
                        elseif (name:find("thirst") or name:find("water")) and not thirstValue then
                            thirstValue = child
                        end
                    end
                end
            end
        end
    end)

    return hungerValue, thirstValue
end

local function setInfiniteHunger(enabled)
    InfiniteHungerEnabled = enabled
    if enabled then
        task.spawn(function()
            while InfiniteHungerEnabled and ScriptActive do
                if isInGame() then
                    pcall(function()
                        local hungerValue = findHungerThirstValues()
                        if hungerValue then
                            hungerValue.Value = MAX_HUNGER
                        end
                    end)
                end
                task.wait(1)
            end
        end)
    end
end

local function setInfiniteThirst(enabled)
    InfiniteThirstEnabled = enabled
    if enabled then
        task.spawn(function()
            while InfiniteThirstEnabled and ScriptActive do
                if isInGame() then
                    pcall(function()
                        local _, thirstValue = findHungerThirstValues()
                        if thirstValue then
                            thirstValue.Value = MAX_THIRST
                        end
                    end)
                end
                task.wait(1)
            end
        end)
    end
end

local function maxAllHungerThirst()
    if not isInGame() then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local targets = {char, LocalPlayer:FindFirstChild("PlayerGui"), LocalPlayer:FindFirstChild("leaderstats")}
        for _, target in pairs(targets) do
            if target then
                for _, child in pairs(target:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local name = child.Name:lower()
                        if name:find("hunger") or name:find("food") or name:find("thirst") or name:find("water") or name:find("drink") then
                            child.Value = MAX_HUNGER
                        end
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    while ScriptActive do
        if (InfiniteHungerEnabled or InfiniteThirstEnabled) and isInGame() then
            maxAllHungerThirst()
        end
        task.wait(2)
    end
end)

-- =============================================
-- SAFE ESP
-- =============================================
local function addHighlight(player)
    if not isInGame() then return end
    if player == LocalPlayer then return end
    pcall(function()
        if player.Character and player.Character.Parent == Workspace and player.Character:FindFirstChild("Humanoid") then
            local oldHL = player.Character:FindFirstChildOfClass("Highlight")
            if oldHL then oldHL:Destroy() end
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = player.Character
            highlight.Parent = player.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.85
            highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineTransparency = 0.3
            highlight.Enabled = ESPEnabled
        end
    end)
end

local function removeHighlight(player)
    pcall(function()
        if player and player.Character then
            local hl = player.Character:FindFirstChildOfClass("Highlight")
            if hl then hl:Destroy() end
        end
    end)
end

local function removeAllHighlights()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                removeHighlight(player)
            end
        end
    end)
end

local function updateAllHighlights()
    if not isInGame() then
        removeAllHighlights()
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                if player.Character and player.Character.Parent == Workspace then
                    local hl = player.Character:FindFirstChildOfClass("Highlight")
                    if hl then
                        hl.Enabled = ESPEnabled
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 50 then
                                hl.FillColor = Color3.fromRGB(255, 0, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                            elseif dist < 150 then
                                hl.FillColor = Color3.fromRGB(255, 200, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 180, 0)
                            else
                                hl.FillColor = Color3.fromRGB(0, 255, 0)
                                hl.OutlineColor = Color3.fromRGB(50, 255, 50)
                            end
                        end
                    else
                        addHighlight(player)
                    end
                else
                    removeHighlight(player)
                end
            end)
        end
    end
end

task.spawn(function()
    while ScriptActive do
        if ESPEnabled and isInGame() then
            updateAllHighlights()
        elseif not isInGame() then
            removeAllHighlights()
        end
        task.wait(0.5)
    end
end)

-- =============================================
-- SAFE NO FOG
-- =============================================
local originalFogEnd = 1000
local originalFogStart = 0
local originalBrightness = 1

local function applyNoFog(enabled)
    if not isInGame() then
        pcall(function()
            Lighting.FogEnd = originalFogEnd
            Lighting.FogStart = originalFogStart
            Lighting.Brightness = originalBrightness
        end)
        return
    end

    if enabled then
        pcall(function()
            Lighting.FogEnd = 99999
            Lighting.FogStart = 99999
            Lighting.Brightness = 2
            local at = Lighting:FindFirstChildOfClass("Atmosphere")
            if at then at:Destroy() end
        end)
    else
        pcall(function()
            Lighting.FogEnd = originalFogEnd
            Lighting.FogStart = originalFogStart
            Lighting.Brightness = originalBrightness
        end)
    end
end

task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            applyNoFog(true)
        end
        task.wait(2)
    end
end)

task.spawn(function()
    local wasInGame = false
    while ScriptActive do
        local nowInGame = isInGame()
        if wasInGame and not nowInGame then
            pcall(function()
                Lighting.FogEnd = originalFogEnd
                Lighting.FogStart = originalFogStart
                Lighting.Brightness = originalBrightness
                removeAllHighlights()
            end)
        end
        wasInGame = nowInGame
        task.wait(1)
    end
end)

-- =============================================
-- GUI
-- =============================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "BRM5GUI"
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 300)
Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Parent = Main

local FPSDisplay = Instance.new("TextLabel")
FPSDisplay.Size = UDim2.new(0, 50, 1, 0)
FPSDisplay.Position = UDim2.new(0, 10, 0, 0)
FPSDisplay.BackgroundTransparency = 1
FPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSDisplay.Text = "FPS: --"
FPSDisplay.Font = Enum.Font.GothamBold
FPSDisplay.TextSize = 10
FPSDisplay.Parent = TitleBar

local PingDisplay = Instance.new("TextLabel")
PingDisplay.Size = UDim2.new(0, 65, 1, 0)
PingDisplay.Position = UDim2.new(0, 62, 0, 0)
PingDisplay.BackgroundTransparency = 1
PingDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
PingDisplay.Text = "Ping: --"
PingDisplay.Font = Enum.Font.GothamBold
PingDisplay.TextSize = 10
PingDisplay.Parent = TitleBar

local TimerDisplay = Instance.new("TextLabel")
TimerDisplay.Size = UDim2.new(0, 70, 1, 0)
TimerDisplay.Position = UDim2.new(0, 130, 0, 0)
TimerDisplay.BackgroundTransparency = 1
TimerDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
TimerDisplay.Text = "0:0:0"
TimerDisplay.Font = Enum.Font.GothamBold
TimerDisplay.TextSize = 10
TimerDisplay.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -290, 1, 0)
TitleText.Position = UDim2.new(0, 205, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(180, 200, 255)
TitleText.Text = "brm5 pve | ` to toggle"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 11
TitleText.Parent = TitleBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
Sidebar.Parent = ContentContainer

local SidebarLogo = Instance.new("Frame")
SidebarLogo.Size = UDim2.new(1, 0, 0, 45)
SidebarLogo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SidebarLogo.Parent = Sidebar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -20, 0, 20)
LogoText.Position = UDim2.new(0, 10, 0, 5)
LogoText.BackgroundTransparency = 1
LogoText.TextColor3 = Color3.fromRGB(180, 200, 255)
LogoText.Text = "BRM5 PvE v1"
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 10
LogoText.Parent = SidebarLogo

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -20, 0, 14)
LogoSub.Position = UDim2.new(0, 10, 0, 24)
LogoSub.BackgroundTransparency = 1
LogoSub.TextColor3 = Color3.fromRGB(120, 120, 120)
LogoSub.Text = "by Maryyy"
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextSize = 9
LogoSub.Parent = SidebarLogo

-- Tab System
local TabButtons, TabPages = {}, {}
local function CreateTab(name, icon, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, 52 + (index-1)*36)
    btn.BackgroundColor3 = index == 1 and Color3.fromRGB(40,40,40) or Color3.fromRGB(23,23,23)
    btn.TextColor3 = index == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
    btn.Text = "  " .. icon .. "  " .. name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -140, 1, 0)
    page.Position = UDim2.new(0, 140, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = ContentContainer

    btn.MouseButton1Click:Connect(function()
        for i = 1, #TabButtons do
            TabButtons[i].BackgroundColor3 = Color3.fromRGB(23,23,23)
            TabButtons[i].TextColor3 = Color3.fromRGB(150,150,150)
            TabPages[i].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        page.Visible = true
    end)

    table.insert(TabButtons, btn)
    table.insert(TabPages, page)
    return page
end

-- UI Helpers
local function CreateSection(parent, title, yPos)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, -30, 0, 20)
    s.Position = UDim2.new(0, 15, 0, yPos)
    s.BackgroundTransparency = 1
    s.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = Color3.fromRGB(40,40,40)
    line.Parent = s

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 16)
    text.Position = UDim2.new(0, 0, 0, 3)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(120,120,120)
    text.Text = title
    text.Font = Enum.Font.GothamBold
    text.TextSize = 9
    text.Parent = s
    return s
end

local function CreateToggle(parent, title, default, yPos, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 30)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(25,25,25)
    bg.Parent = parent
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Text = title
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = bg

    local state = default
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -46, 0.5, -9)
    switch.BackgroundColor3 = state and Color3.fromRGB(60,160,60) or Color3.fromRGB(50,50,50)
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = bg
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.Parent = switch
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(60,160,60) or Color3.fromRGB(50,50,50)
        local tp = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        TweenService:Create(dot, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = tp}):Play()
        callback(state)
    end)
    return bg
end

local function CreateButton(parent, title, yPos, callback, accent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 32)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = accent or Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = title
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = accent and Color3.fromRGB(120,30,30) or Color3.fromRGB(40,40,40) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = accent or Color3.fromRGB(30,30,30) end)
    return btn
end

local function CreateInfoLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 0, 18)
    lbl.Position = UDim2.new(0, 15, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(200,200,200)
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.Parent = parent
    return lbl
end

-- Create Tabs
local SpeedPage = CreateTab("Speed", "🏃", 1)
local ZombiesPage = CreateTab("Zombies", "🧟", 2)
local VisualsPage = CreateTab("Visuals", "👁", 3)
local SettingsPage = CreateTab("Settings", "⚙️", 4)

-- Speed Tab
CreateSection(SpeedPage, "PERMANENT SPEED", 10)
CreateInfoLabel(SpeedPage, "🏃 Speed: " .. PERMANENT_SPEED .. " (Always On)", 34, Color3.fromRGB(100,255,100))
CreateInfoLabel(SpeedPage, "Default: " .. DEFAULT_SPEED, 54, Color3.fromRGB(150,150,150))
CreateInfoLabel(SpeedPage, "✅ Speed auto-applies on respawn", 74, Color3.fromRGB(100,255,100))

-- Zombies Tab
CreateSection(ZombiesPage, "SURVIVAL CHEATS", 10)
CreateToggle(ZombiesPage, "🍖 Infinite Hunger", false, 34, function(s)
    setInfiniteHunger(s)
end)
CreateInfoLabel(ZombiesPage, "Keeps hunger at maximum ("..MAX_HUNGER..")", 68, Color3.fromRGB(255,200,100))

CreateToggle(ZombiesPage, "💧 Infinite Thirst", false, 94, function(s)
    setInfiniteThirst(s)
end)
CreateInfoLabel(ZombiesPage, "Keeps thirst at maximum ("..MAX_THIRST..")", 128, Color3.fromRGB(100,200,255))

-- Visuals Tab
CreateSection(VisualsPage, "HIGHLIGHTS", 10)
CreateToggle(VisualsPage, "Enemy Highlights", false, 34, function(s)
    ESPEnabled = s
    if isInGame() then
        updateAllHighlights()
    else
        removeAllHighlights()
    end
end)
CreateInfoLabel(VisualsPage, "🔴 Red = Close (<50 studs)", 68, Color3.fromRGB(255,100,100))
CreateInfoLabel(VisualsPage, "🟡 Yellow = Medium (<150 studs)", 86, Color3.fromRGB(255,200,100))
CreateInfoLabel(VisualsPage, "🟢 Green = Far (>150 studs)", 104, Color3.fromRGB(100,255,100))

CreateSection(VisualsPage, "ENVIRONMENT", 132)
CreateToggle(VisualsPage, "No Fog", false, 156, function(s)
    NoFogEnabled = s
    applyNoFog(s)
end)

-- Settings Tab
CreateSection(SettingsPage, "INFO", 10)
local SettingsName = Instance.new("TextLabel")
SettingsName.Size = UDim2.new(1, -30, 0, 20)
SettingsName.Position = UDim2.new(0, 15, 0, 34)
SettingsName.BackgroundTransparency = 1
SettingsName.TextColor3 = Color3.fromRGB(255,255,255)
SettingsName.Text = "🎯 " .. LocalPlayer.Name
SettingsName.Font = Enum.Font.GothamBold
SettingsName.TextSize = 12
SettingsName.Parent = SettingsPage

CreateInfoLabel(SettingsPage, "Features: Speed + Hunger/Thirst + ESP + No Fog", 60, Color3.fromRGB(180,200,255))
CreateInfoLabel(SettingsPage, "Press ` (backtick) to toggle UI", 80, Color3.fromRGB(255,200,100))

CreateSection(SettingsPage, "TERMINATE", 110)
CreateButton(SettingsPage, "⚠️ TERMINATE SCRIPT", 134, function()
    ScriptActive = false
    pcall(function()
        removeAllHighlights()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = DEFAULT_SPEED
        end
        Lighting.FogEnd = originalFogEnd
        Lighting.FogStart = originalFogStart
        Lighting.Brightness = originalBrightness
        GUI:Destroy()
    end)
    print("✅ Script terminated. All features disabled.")
end, Color3.fromRGB(100, 20, 20))

-- =============================================
-- UI TOGGLE WITH ` (BACKTICK) KEY
-- =============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Backquote then
        UIVisible = not UIVisible
        if UIVisible then
            Main.Visible = true
            Main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 500, 0, 300)
            }):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.2)
            Main.Visible = false
        end
    end
end)

-- Drag functionality (Title Bar only)
local dActive, dInput, dStart, sPos = false, nil, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dActive = true
        dStart = i.Position
        sPos = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                dActive = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then
        dInput = i
    end
end)

RunService.RenderStepped:Connect(function()
    if dActive and dInput then
        local d = dInput.Position - dStart
        Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)

-- =============================================
-- UPDATE LOOPS
-- =============================================
task.spawn(function()
    while ScriptActive do
        fpsCount += 1
        if tick() - lastFPSUpdate >= 0.5 then
            fps = math.floor(fpsCount / (tick() - lastFPSUpdate))
            fpsCount = 0
            lastFPSUpdate = tick()
            pcall(function()
                if FPSDisplay and FPSDisplay.Parent then
                    FPSDisplay.Text = "FPS: " .. fps
                    FPSDisplay.TextColor3 = fps >= 50 and Color3.fromRGB(0,255,100) or (fps >= 25 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
                end
            end)
        end
        task.wait()
    end
end)

task.spawn(function()
    while ScriptActive do
        pcall(function()
            if PingDisplay and PingDisplay.Parent then
                local p = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                PingDisplay.Text = "Ping: " .. p .. "ms"
                PingDisplay.TextColor3 = p <= 80 and Color3.fromRGB(100,200,255) or (p <= 150 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,100,100))
            end
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while ScriptActive do
        saniye += 1
        if saniye >= 60 then saniye = 0; dakika += 1 end
        if dakika >= 60 then dakika = 0; saat += 1 end
        pcall(function()
            if TimerDisplay and TimerDisplay.Parent then
                TimerDisplay.Text = saat .. ":" .. dakika .. ":" .. saniye
            end
        end)
        task.wait(1)
    end
end)

print("✅ BRM5 PvE v1 Loaded! (Main Menu Safe Version)")
print("   - All features auto-disable in main menu")
print("   - No more blank/black menu screens")
print("   - Lighting resets when leaving game")
print("   - UI toggled with ` (backtick) key")
print("   🏃 Speed: " .. PERMANENT_SPEED)
