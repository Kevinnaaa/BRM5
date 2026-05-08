--[[
    BRM5 PvE Script - Movement Speed, Aimbot, Silent Aim, No Fog
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
local Minimized = false
local WalkSpeed = 50
local DefaultWalkSpeed = 35

-- Silent Aim variables
local SilentTarget = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BRM5PvE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0, 10, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MinBtn.BorderSizePixel = 0
MinBtn.TextColor3 = Color3.fromRGB(180, 200, 255)
MinBtn.Text = "🪖"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 15
MinBtn.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 262)
MainFrame.Position = UDim2.new(0, 45, 0, 10)
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
HeaderText.Text = "🪖 BRM5 PvE"
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

-- No Fog Button
local FogBtn = Instance.new("TextButton")
FogBtn.Size = UDim2.new(1, -20, 0, 32)
FogBtn.Position = UDim2.new(0, 10, 0, 188)
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
Div2.Position = UDim2.new(0, 0, 0, 225)
Div2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Div2.BorderSizePixel = 0
Div2.Parent = MainFrame

-- Terminate Button
local TermBtn = Instance.new("TextButton")
TermBtn.Size = UDim2.new(1, -20, 0, 24)
TermBtn.Position = UDim2.new(0, 10, 0, 230)
TermBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
TermBtn.BorderSizePixel = 0
TermBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
TermBtn.Text = "⏏  TERMINATE"
TermBtn.Font = Enum.Font.SourceSansBold
TermBtn.TextSize = 11
TermBtn.Parent = MainFrame

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
-- SILENT AIM - Snaps on click, restores after
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
            pcall(function()
                Camera.CFrame = SilentTarget.old
            end)
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

print("BRM5 PvE Ready! Speed:" .. WalkSpeed .. " | Aimbot | Silent Aim | No Fog")
