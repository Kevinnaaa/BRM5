--[[
    BRM5 PvE Script - RAYFIELD STYLE
    Permanent Speed 50 + Aimbot + Silent Aim + No Fog
    Open World PvE Only | FPS/Ping/Time Display | Minimize to Icon
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ScriptActive = true
local AimbotEnabled = false
local SilentAimEnabled = false
local NoFogEnabled = false
local Minimized = false
local SilentTarget = nil

-- Speed values (no applySpeed function, just set directly)
local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 35

-- FPS Tracking
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()

-- Timer
local saniye, dakika, saat = 0, 0, 0

-- Clean up
if getgenv().BRM5Loaded then
    getgenv().BRM5Loaded = false
    if game.CoreGui:FindFirstChild("BRM5GUI") then
        game.CoreGui.BRM5GUI:Destroy()
    end
    if game.CoreGui:FindFirstChild("BRM5Icon") then
        game.CoreGui.BRM5Icon:Destroy()
    end
end
getgenv().BRM5Loaded = true

-- =============================================
-- SET SPEED IMMEDIATELY (no loop, just set it)
-- =============================================
pcall(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = PERMANENT_SPEED
    end
end)

-- Keep speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = PERMANENT_SPEED
end)

-- =============================================
-- GUI CREATION
-- =============================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "BRM5GUI"
GUI.ResetOnSpawn = false
GUI.Parent = game.CoreGui
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Container
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 500, 0, 300)
Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = GUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Main

-- Minimize Icon
local MinimizeIcon = Instance.new("TextButton")
MinimizeIcon.Name = "BRM5Icon"
MinimizeIcon.Size = UDim2.new(0, 45, 0, 45)
MinimizeIcon.Position = UDim2.new(0, 10, 0, 80)
MinimizeIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinimizeIcon.BorderSizePixel = 0
MinimizeIcon.TextColor3 = Color3.fromRGB(180, 200, 255)
MinimizeIcon.Text = "🔫"
MinimizeIcon.Font = Enum.Font.GothamBold
MinimizeIcon.TextSize = 20
MinimizeIcon.AutoButtonColor = false
MinimizeIcon.Visible = false
MinimizeIcon.Parent = GUI

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = MinimizeIcon

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

-- FPS
local FPSDisplay = Instance.new("TextLabel")
FPSDisplay.Size = UDim2.new(0, 50, 1, 0)
FPSDisplay.Position = UDim2.new(0, 10, 0, 0)
FPSDisplay.BackgroundTransparency = 1
FPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSDisplay.Text = "FPS: --"
FPSDisplay.TextXAlignment = Enum.TextXAlignment.Left
FPSDisplay.Font = Enum.Font.GothamBold
FPSDisplay.TextSize = 10
FPSDisplay.Parent = TitleBar

-- Ping
local PingDisplay = Instance.new("TextLabel")
PingDisplay.Size = UDim2.new(0, 65, 1, 0)
PingDisplay.Position = UDim2.new(0, 62, 0, 0)
PingDisplay.BackgroundTransparency = 1
PingDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
PingDisplay.Text = "Ping: --"
PingDisplay.TextXAlignment = Enum.TextXAlignment.Left
PingDisplay.Font = Enum.Font.GothamBold
PingDisplay.TextSize = 10
PingDisplay.Parent = TitleBar

-- Time
local TimerDisplay = Instance.new("TextLabel")
TimerDisplay.Size = UDim2.new(0, 70, 1, 0)
TimerDisplay.Position = UDim2.new(0, 130, 0, 0)
TimerDisplay.BackgroundTransparency = 1
TimerDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
TimerDisplay.Text = "0:0:0"
TimerDisplay.TextXAlignment = Enum.TextXAlignment.Left
TimerDisplay.Font = Enum.Font.GothamBold
TimerDisplay.TextSize = 10
TimerDisplay.Parent = TitleBar

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -290, 1, 0)
TitleText.Position = UDim2.new(0, 205, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(180, 200, 255)
TitleText.Text = "brm5 pve"
TitleText.TextXAlignment = Enum.TextXAlignment.Right
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 11
TitleText.Parent = TitleBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -33, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.BorderSizePixel = 0
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Main

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentContainer

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

-- Sidebar Logo
local SidebarLogo = Instance.new("Frame")
SidebarLogo.Size = UDim2.new(1, 0, 0, 45)
SidebarLogo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SidebarLogo.BorderSizePixel = 0
SidebarLogo.Parent = Sidebar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -20, 0, 20)
LogoText.Position = UDim2.new(0, 10, 0, 5)
LogoText.BackgroundTransparency = 1
LogoText.TextColor3 = Color3.fromRGB(180, 200, 255)
LogoText.Text = "🔫 BRM5 PvE"
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 10
LogoText.Parent = SidebarLogo

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -20, 0, 14)
LogoSub.Position = UDim2.new(0, 10, 0, 24)
LogoSub.BackgroundTransparency = 1
LogoSub.TextColor3 = Color3.fromRGB(120, 120, 120)
LogoSub.Text = "by Maryyy"
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextSize = 9
LogoSub.Parent = SidebarLogo

-- Tab System
local TabButtons = {}
local TabPages = {}

local function CreateTab(name, icon, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, 52 + (index - 1) * 36)
    btn.BackgroundColor3 = index == 1 and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(23, 23, 23)
    btn.BorderSizePixel = 0
    btn.TextColor3 = index == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -140, 1, 0)
    page.Position = UDim2.new(0, 140, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = ContentContainer
    
    btn.MouseButton1Click:Connect(function()
        for i = 1, #TabButtons do
            TabButtons[i].BackgroundColor3 = Color3.fromRGB(23, 23, 23)
            TabButtons[i].TextColor3 = Color3.fromRGB(150, 150, 150)
            TabPages[i].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)
    
    table.insert(TabButtons, btn)
    table.insert(TabPages, page)
    return page
end

-- =============================================
-- UI HELPERS
-- =============================================
local function CreateSection(parent, title, yPos)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -30, 0, 20)
    section.Position = UDim2.new(0, 15, 0, yPos)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 0)
    line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    line.BorderSizePixel = 0
    line.Parent = section
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 16)
    text.Position = UDim2.new(0, 0, 0, 3)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(120, 120, 120)
    text.Text = title
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.GothamBold
    text.TextSize = 9
    text.Parent = section
    
    return section
end

local function CreateToggle(parent, title, default, yPos, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 30)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bg.BorderSizePixel = 0
    bg.Parent = parent
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = title
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = bg
    
    local state = default
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -46, 0.5, -9)
    switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = bg
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.BackgroundColor3 = state and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(50, 50, 50)
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(dot, tweenInfo, {Position = targetPos})
        tween:Play()
        callback(state)
    end)
    
    return bg, label
end

local function CreateButton(parent, title, yPos, callback, accentColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 32)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = accentColor or Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = title
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = accentColor and Color3.fromRGB(120, 30, 30) or Color3.fromRGB(40, 40, 40)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = accentColor or Color3.fromRGB(30, 30, 30)
    end)
    
    return btn
end

local function CreateInfoLabel(parent, text, yPos, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 18)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.Parent = parent
    return label
end

-- =============================================
-- CREATE TABS
-- =============================================
local CombatPage = CreateTab("Combat", "🎯", 1)
local SettingsPage = CreateTab("Settings", "⚙️", 2)

-- =============================================
-- COMBAT TAB
-- =============================================
CreateSection(CombatPage, "AIM ASSIST", 10)

CreateToggle(CombatPage, "Aimbot", false, 34, function(state)
    AimbotEnabled = state
    if state then SilentAimEnabled = false end
end)

CreateToggle(CombatPage, "Silent Aim", false, 68, function(state)
    SilentAimEnabled = state
    if state then AimbotEnabled = false else SilentTarget = nil end
end)

CreateSection(CombatPage, "VISUALS", 110)

CreateToggle(CombatPage, "No Fog", false, 134, function(state)
    NoFogEnabled = state
    if state then
        pcall(function()
            Lighting.FogEnd = 99999; Lighting.FogStart = 99999; Lighting.Brightness = 2
            local at = Lighting:FindFirstChildOfClass("Atmosphere")
            if at then at:Destroy() end
        end)
    else
        pcall(function()
            Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1
        end)
    end
end)

CreateSection(CombatPage, "PERMANENT STATS", 176)

CreateInfoLabel(CombatPage, "🏃 Speed: 50 (Active)", 200, Color3.fromRGB(100, 255, 100))
CreateInfoLabel(CombatPage, "Default: 35", 220, Color3.fromRGB(150, 150, 150))

-- =============================================
-- SETTINGS TAB
-- =============================================
CreateSection(SettingsPage, "INFO", 10)

local SettingsName = Instance.new("TextLabel")
SettingsName.Size = UDim2.new(1, -30, 0, 20)
SettingsName.Position = UDim2.new(0, 15, 0, 34)
SettingsName.BackgroundTransparency = 1
SettingsName.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsName.Text = "🔫 " .. LocalPlayer.Name
SettingsName.TextXAlignment = Enum.TextXAlignment.Left
SettingsName.Font = Enum.Font.GothamBold
SettingsName.TextSize = 12
SettingsName.Parent = SettingsPage

local InfoBox = Instance.new("Frame")
InfoBox.Size = UDim2.new(1, -30, 0, 50)
InfoBox.Position = UDim2.new(0, 15, 0, 60)
InfoBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InfoBox.BorderSizePixel = 0
InfoBox.Parent = SettingsPage

local InfoBoxCorner = Instance.new("UICorner")
InfoBoxCorner.CornerRadius = UDim.new(0, 4)
InfoBoxCorner.Parent = InfoBox

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, -20, 1, -10)
InfoText.Position = UDim2.new(0, 10, 0, 5)
InfoText.BackgroundTransparency = 1
InfoText.TextColor3 = Color3.fromRGB(180, 200, 255)
InfoText.Text = "PvE Only\nSpeed: 50 (Permanent)\nFPS/Ping/Time: Active"
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 10
InfoText.TextWrapped = true
InfoText.Parent = InfoBox

CreateSection(SettingsPage, "TERMINATE", 130)

CreateButton(SettingsPage, "⚠️ TERMINATE SCRIPT", 154, function()
    ScriptActive = false
    SilentTarget = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = DEFAULT_SPEED
    end
    pcall(function()
        Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1
    end)
    GUI:Destroy()
end, Color3.fromRGB(100, 20, 20))

-- =============================================
-- MINIMIZE TO ICON
-- =============================================
local function showMain()
    Main.Visible = true; MinimizeIcon.Visible = false; Minimized = false
end
local function showIcon()
    Main.Visible = false; MinimizeIcon.Visible = true; Minimized = true
end

MinBtn.MouseButton1Click:Connect(showIcon)
MinimizeIcon.MouseButton1Click:Connect(showMain)

local iconDragging, iconDragStart, iconStartPos = false, nil, nil
MinimizeIcon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = true; iconDragStart = i.Position; iconStartPos = MinimizeIcon.Position
    end
end)
MinimizeIcon.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        if iconDragging and (i.Position - iconDragStart).Magnitude < 5 then showMain() end
        iconDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if iconDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - iconDragStart
        MinimizeIcon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + d.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + d.Y)
    end
end)

-- Main window draggable
local dragActive, dragInput, dragStart, startPos = false, nil, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true; dragStart = i.Position; startPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragActive = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
end)
RunService.RenderStepped:Connect(function()
    if dragActive and dragInput then
        local d = dragInput.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- =============================================
-- SILENT AIM
-- =============================================
UserInputService.InputBegan:Connect(function(i, gp)
    if SilentAimEnabled and i.UserInputType == Enum.UserInputType.MouseButton1 then
        pcall(function()
            local closest, closestDist = nil, 500
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("Head")
                    if h then
                        local _, os = Camera:WorldToViewportPoint(h.Position)
                        if os then
                            local dist = (h.Position - Camera.CFrame.Position).Magnitude
                            if dist < closestDist then closestDist = dist; closest = h end
                        end
                    end
                end
            end
            if closest then
                local old = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
                SilentTarget = {old = old, target = closest}
            end
        end)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if SilentAimEnabled and i.UserInputType == Enum.UserInputType.MouseButton1 then
        if SilentTarget then
            pcall(function() Camera.CFrame = SilentTarget.old end)
            SilentTarget = nil
        end
    end
end)

-- =============================================
-- UPDATE LOOPS
-- =============================================

-- FPS
task.spawn(function()
    while ScriptActive do
        fpsCount += 1
        if tick() - lastFPSUpdate >= 0.5 then
            fps = math.floor(fpsCount / (tick() - lastFPSUpdate))
            fpsCount = 0; lastFPSUpdate = tick()
            FPSDisplay.Text = "FPS: " .. fps
            FPSDisplay.TextColor3 = fps >= 50 and Color3.fromRGB(0,255,100) or (fps >= 25 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
        end
        task.wait()
    end
end)

-- Ping
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local p = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            PingDisplay.Text = "Ping: " .. p .. "ms"
            PingDisplay.TextColor3 = p <= 80 and Color3.fromRGB(100,200,255) or (p <= 150 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,100,100))
        end)
        task.wait(1)
    end
end)

-- Timer
task.spawn(function()
    while ScriptActive do
        saniye += 1
        if saniye >= 60 then saniye = 0; dakika += 1 end
        if dakika >= 60 then dakika = 0; saat += 1 end
        TimerDisplay.Text = saat .. ":" .. dakika .. ":" .. saniye
        task.wait(1)
    end
end)

-- Aimbot Loop
task.spawn(function()
    while ScriptActive do
        if AimbotEnabled then
            pcall(function()
                local target, closestDist = nil, 200
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local h = p.Character:FindFirstChild("Head")
                        if h then
                            local sp, os = Camera:WorldToViewportPoint(h.Position)
                            if os then
                                local c = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                                local d = (Vector2.new(sp.X, sp.Y) - c).Magnitude
                                if d < closestDist then closestDist = d; target = sp end
                            end
                        end
                    end
                end
                if target then
                    local c = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    mousemoverel((target.X - c.X) * 0.3, (target.Y - c.Y) * 0.3)
                end
            end)
        end
        task.wait()
    end
end)

-- No Fog persistent
task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            pcall(function()
                Lighting.FogEnd = 99999; Lighting.FogStart = 99999
                local at = Lighting:FindFirstChildOfClass("Atmosphere")
                if at then at:Destroy() end
            end)
        end
        task.wait(5)
    end
end)

print("✅ BRM5 PvE Loaded! | Speed:50 Permanent | Aimbot | Silent Aim | No Fog")
