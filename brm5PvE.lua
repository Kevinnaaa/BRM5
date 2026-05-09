--[[
    BRM5 PvE Script - Movement Speed, Aimbot, Silent Aim, No Fog, Enemy ESP
    Open World PvE Only | Presentable UI
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local ScriptActive = true
local SpeedEnabled = false
local AimbotEnabled = false
local SilentAimEnabled = false
local NoFogEnabled = false
local ESPEnabled = false
local Minimized = false
local WalkSpeed = 70
local DefaultWalkSpeed = 45

-- Silent Aim variables
local SilentTarget = nil

-- ESP Storage
local ESPObjects = {}

-- =============================================
-- ESP FUNCTIONS
-- =============================================
local function createESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthFill = Drawing.new("Square"),
        HeadDot = Drawing.new("Circle")
    }
    
    esp.Box.Color = Color3.fromRGB(255, 50, 50)
    esp.Box.Thickness = 1
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Visible = false
    
    esp.HealthBar.Color = Color3.fromRGB(50, 50, 50)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false
    
    esp.HealthFill.Color = Color3.fromRGB(50, 255, 50)
    esp.HealthFill.Thickness = 1
    esp.HealthFill.Filled = true
    esp.HealthFill.Visible = false
    
    esp.HeadDot.Color = Color3.fromRGB(255, 0, 0)
    esp.HeadDot.Filled = true
    esp.HeadDot.NumSides = 30
    esp.HeadDot.Radius = 5
    esp.HeadDot.Visible = false
    
    ESPObjects[player] = esp
    return esp
end

local function updateESP()
    for player, esp in pairs(ESPObjects) do
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("Humanoid") then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthFill.Visible = false
                esp.HeadDot.Visible = false
                return
            end
            
            local humanoid = player.Character.Humanoid
            if humanoid.Health <= 0 then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthFill.Visible = false
                esp.HeadDot.Visible = false
                return
            end
            
            -- Team check (don't ESP teammates)
            if player.Team == LocalPlayer.Team and player ~= LocalPlayer then
                esp.Box.Visible = false
                return
            end
            
            local char = player.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if not head or not root then return end
            
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
            
            if rootOnScreen then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                
                -- Box
                local boxHeight = (headPos.Y - rootPos.Y) * 1.2
                local boxWidth = boxHeight * 0.5
                local boxX = rootPos.X - boxWidth / 2
                local boxY = rootPos.Y - boxHeight * 0.1
                
                esp.Box.Visible = true
                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box.Position = Vector2.new(boxX, boxY)
                esp.Box.Color = Color3.fromRGB(255, 50, 50)
                
                -- Name
                esp.Name.Visible = true
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(rootPos.X, boxY - 16)
                
                -- Distance
                esp.Distance.Visible = true
                esp.Distance.Text = math.floor(distance) .. "s"
                esp.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 2)
                
                -- Health bar
                local health = humanoid.Health / humanoid.MaxHealth
                esp.HealthBar.Visible = true
                esp.HealthBar.Size = Vector2.new(2, boxHeight)
                esp.HealthBar.Position = Vector2.new(boxX - 5, boxY)
                
                esp.HealthFill.Visible = true
                esp.HealthFill.Size = Vector2.new(2, boxHeight * health)
                esp.HealthFill.Position = Vector2.new(boxX - 5, boxY + boxHeight * (1 - health))
                esp.HealthFill.Color = health > 0.5 and Color3.fromRGB(50, 255, 50) or (health > 0.25 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
                
                -- Head dot
                esp.HeadDot.Visible = true
                esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthFill.Visible = false
                esp.HeadDot.Visible = false
            end
        end)
    end
end

local function removeESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        ESPObjects[player].Name:Remove()
        ESPObjects[player].Distance:Remove()
        ESPObjects[player].HealthBar:Remove()
        ESPObjects[player].HealthFill:Remove()
        ESPObjects[player].HeadDot:Remove()
        ESPObjects[player] = nil
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

-- Handle players joining/leaving
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)
Players.PlayerRemoving:Connect(removeESP)

-- =============================================
-- GUI
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BRM5PvE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 45, 0, 45)
MinBtn.Position = UDim2.new(0, 10, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinBtn.BorderSizePixel = 0
MinBtn.TextColor3 = Color3.fromRGB(180, 200, 255)
MinBtn.Text = "🪖"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 20
MinBtn.Draggable = true
MinBtn.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 295)
MainFrame.Position = UDim2.new(0, 60, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderText = Instance.new("TextLabel")
HeaderText.Size = UDim2.new(0.6, 0, 1, 0)
HeaderText.Position = UDim2.new(0, 12, 0, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.TextColor3 = Color3.fromRGB(180, 200, 255)
HeaderText.Text = "🪖 BRM5 PvE by Maryyy"
HeaderText.TextXAlignment = Enum.TextXAlignment.Left
HeaderText.Font = Enum.Font.SourceSansBold
HeaderText.TextSize = 14
HeaderText.Parent = Header

local DashBtn = Instance.new("TextButton")
DashBtn.Size = UDim2.new(0, 26, 0, 26)
DashBtn.Position = UDim2.new(1, -30, 0, 3)
DashBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DashBtn.BorderSizePixel = 0
DashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DashBtn.Text = "—"
DashBtn.Font = Enum.Font.SourceSansBold
DashBtn.TextSize = 14
DashBtn.Parent = Header

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 37)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Text = "● Ready"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

-- Divider
local Div1 = Instance.new("Frame")
Div1.Size = UDim2.new(1, 0, 0, 1)
Div1.Position = UDim2.new(0, 0, 0, 58)
Div1.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Div1.BorderSizePixel = 0
Div1.Parent = MainFrame

-- Section Label
local SectionLabel = Instance.new("TextLabel")
SectionLabel.Size = UDim2.new(1, -20, 0, 14)
SectionLabel.Position = UDim2.new(0, 10, 0, 63)
SectionLabel.BackgroundTransparency = 1
SectionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
SectionLabel.Text = "FEATURES"
SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
SectionLabel.Font = Enum.Font.SourceSansBold
SectionLabel.TextSize = 9
SectionLabel.Parent = MainFrame

-- Speed Button
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -20, 0, 32)
SpeedBtn.Position = UDim2.new(0, 10, 0, 80)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBtn.BorderSizePixel = 0
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Text = "🏃  Movement Speed: OFF"
SpeedBtn.Font = Enum.Font.SourceSans
SpeedBtn.TextSize = 12
SpeedBtn.Parent = MainFrame

-- Aimbot Button
local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(1, -20, 0, 32)
AimBtn.Position = UDim2.new(0, 10, 0, 116)
AimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimBtn.BorderSizePixel = 0
AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBtn.Text = "🎯  Aimbot: OFF"
AimBtn.Font = Enum.Font.SourceSans
AimBtn.TextSize = 12
AimBtn.Parent = MainFrame

-- Silent Aim Button
local SilentBtn = Instance.new("TextButton")
SilentBtn.Size = UDim2.new(1, -20, 0, 32)
SilentBtn.Position = UDim2.new(0, 10, 0, 152)
SilentBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SilentBtn.BorderSizePixel = 0
SilentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentBtn.Text = "🤫  Silent Aim: OFF"
SilentBtn.Font = Enum.Font.SourceSans
SilentBtn.TextSize = 12
SilentBtn.Parent = MainFrame

-- ESP Button
local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(1, -20, 0, 32)
ESPBtn.Position = UDim2.new(0, 10, 0, 188)
ESPBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ESPBtn.BorderSizePixel = 0
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.Text = "👁️  Enemy ESP: OFF"
ESPBtn.Font = Enum.Font.SourceSans
ESPBtn.TextSize = 12
ESPBtn.Parent = MainFrame

-- No Fog Button
local FogBtn = Instance.new("TextButton")
FogBtn.Size = UDim2.new(1, -20, 0, 32)
FogBtn.Position = UDim2.new(0, 10, 0, 224)
FogBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FogBtn.BorderSizePixel = 0
FogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FogBtn.Text = "🌫️  No Fog: OFF"
FogBtn.Font = Enum.Font.SourceSans
FogBtn.TextSize = 12
FogBtn.Parent = MainFrame

-- Divider
local Div2 = Instance.new("Frame")
Div2.Size = UDim2.new(1, 0, 0, 1)
Div2.Position = UDim2.new(0, 0, 0, 260)
Div2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Div2.BorderSizePixel = 0
Div2.Parent = MainFrame

-- Terminate Button
local TermBtn = Instance.new("TextButton")
TermBtn.Size = UDim2.new(1, -20, 0, 24)
TermBtn.Position = UDim2.new(0, 10, 0, 266)
TermBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
TermBtn.BorderSizePixel = 0
TermBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
TermBtn.Text = "⏏  TERMINATE"
TermBtn.Font = Enum.Font.SourceSansBold
TermBtn.TextSize = 11
TermBtn.Parent = MainFrame

-- Update MainFrame size
MainFrame.Size = UDim2.new(0, 240, 0, 298)

-- =============================================
-- FUNCTIONS
-- =============================================

-- Minimize
local function toggleMinimize()
    Minimized = not Minimized
    MainFrame.Visible = not Minimized
    MinBtn.BackgroundColor3 = Minimized and Color3.fromRGB(30, 100, 150) or Color3.fromRGB(25, 25, 25)
end
MinBtn.MouseButton1Click:Connect(toggleMinimize)
DashBtn.MouseButton1Click:Connect(toggleMinimize)

-- Speed Toggle
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedBtn.Text = "🏃  Movement Speed: ON [" .. WalkSpeed .. "]"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
    else
        SpeedBtn.Text = "🏃  Movement Speed: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = DefaultWalkSpeed
        end
    end
end)

-- Aimbot Toggle
AimBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        AimBtn.Text = "🎯  Aimbot: ON"
        AimBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        SilentAimEnabled = false
        SilentBtn.Text = "🤫  Silent Aim: OFF"
        SilentBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        AimBtn.Text = "🎯  Aimbot: OFF"
        AimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

-- Silent Aim Toggle
SilentBtn.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    if SilentAimEnabled then
        SilentBtn.Text = "🤫  Silent Aim: ON"
        SilentBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        AimbotEnabled = false
        AimBtn.Text = "🎯  Aimbot: OFF"
        AimBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    else
        SilentBtn.Text = "🤫  Silent Aim: OFF"
        SilentBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        SilentTarget = nil
    end
end)

-- ESP Toggle
ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        ESPBtn.Text = "👁️  Enemy ESP: ON"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
    else
        ESPBtn.Text = "👁️  Enemy ESP: OFF"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        -- Hide all ESP
        for _, esp in pairs(ESPObjects) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthFill.Visible = false
            esp.HeadDot.Visible = false
        end
    end
end)

-- No Fog Toggle
FogBtn.MouseButton1Click:Connect(function()
    NoFogEnabled = not NoFogEnabled
    if NoFogEnabled then
        FogBtn.Text = "🌫️  No Fog: ON"
        FogBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        pcall(function()
            Lighting.FogEnd = 99999
            Lighting.FogStart = 99999
            Lighting.Brightness = 2
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then atmosphere:Destroy() end
        end)
    else
        FogBtn.Text = "🌫️  No Fog: OFF"
        FogBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        pcall(function()
            Lighting.FogEnd = 1000
            Lighting.FogStart = 0
            Lighting.Brightness = 1
        end)
    end
end)

-- Terminate
TermBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    SilentTarget = nil
    -- Clean up ESP
    for player, esp in pairs(ESPObjects) do
        removeESP(player)
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = DefaultWalkSpeed
    end
    pcall(function()
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.Brightness = 1
    end)
    ScreenGui:Destroy()
end)

-- =============================================
-- SILENT AIM
-- =============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if SilentAimEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        pcall(function()
            local closest = nil
            local closestDist = 500
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local _, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (head.Position - Camera.CFrame.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = head
                            end
                        end
                    end
                end
            end
            if closest then
                local oldCFrame = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
                SilentTarget = {old = oldCFrame, target = closest}
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if SilentAimEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if SilentTarget then
            pcall(function() Camera.CFrame = SilentTarget.old end)
            SilentTarget = nil
        end
    end
end)

-- =============================================
-- LOOPS
-- =============================================

-- Speed Loop
task.spawn(function()
    while ScriptActive do
        if SpeedEnabled then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if SpeedEnabled and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = WalkSpeed
    end
end)

-- Aimbot Loop
task.spawn(function()
    while ScriptActive do
        if AimbotEnabled then
            pcall(function()
                local target = nil
                local closestDist = 200
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    target = screenPos
                                end
                            end
                        end
                    end
                end
                if target then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    mousemoverel((target.X - center.X) * 0.3, (target.Y - center.Y) * 0.3)
                end
            end)
        end
        task.wait()
    end
end)

-- ESP Update Loop
task.spawn(function()
    while ScriptActive do
        if ESPEnabled then
            updateESP()
        end
        task.wait()
    end
end)

-- No Fog persistent
task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            pcall(function()
                Lighting.FogEnd = 99999
                Lighting.FogStart = 99999
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then atmosphere:Destroy() end
            end)
        end
        task.wait(5)
    end
end)

print("BRM5 PvE Ready! Speed:" .. WalkSpeed .. " | Aimbot | Silent Aim | ESP | No Fog")
