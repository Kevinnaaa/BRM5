--[[
    BRM5 PvE Script - Movement Speed, Aimbot, Silent Aim, No Fog
    Open World PvE Only | Close with TERMINATE button
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
local WalkSpeed = 30
local DefaultWalkSpeed = 16

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BRM5PvE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 230)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "🪖 BRM5 PvE"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = Header

-- Divider
local Div1 = Instance.new("Frame")
Div1.Size = UDim2.new(1, 0, 0, 1)
Div1.Position = UDim2.new(0, 0, 0, 30)
Div1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Div1.BorderSizePixel = 0
Div1.Parent = MainFrame

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Text = "● Ready"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

-- Divider
local Div2 = Instance.new("Frame")
Div2.Size = UDim2.new(1, 0, 0, 1)
Div2.Position = UDim2.new(0, 0, 0, 58)
Div2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Div2.BorderSizePixel = 0
Div2.Parent = MainFrame

-- Features Label
local FeatLabel = Instance.new("TextLabel")
FeatLabel.Size = UDim2.new(1, -20, 0, 16)
FeatLabel.Position = UDim2.new(0, 10, 0, 63)
FeatLabel.BackgroundTransparency = 1
FeatLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
FeatLabel.Text = "PvE FEATURES"
FeatLabel.TextXAlignment = Enum.TextXAlignment.Left
FeatLabel.Font = Enum.Font.SourceSansBold
FeatLabel.TextSize = 9
FeatLabel.Parent = MainFrame

-- Movement Speed Button
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -20, 0, 30)
SpeedBtn.Position = UDim2.new(0, 10, 0, 82)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Text = "🏃 Speed " .. WalkSpeed .. ": OFF"
SpeedBtn.Font = Enum.Font.SourceSans
SpeedBtn.TextSize = 12
SpeedBtn.Parent = MainFrame

-- Aimbot Button
local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(1, -20, 0, 30)
AimBtn.Position = UDim2.new(0, 10, 0, 116)
AimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimBtn.Text = "🎯 Aimbot: OFF"
AimBtn.Font = Enum.Font.SourceSans
AimBtn.TextSize = 12
AimBtn.Parent = MainFrame

-- Silent Aim Button
local SilentBtn = Instance.new("TextButton")
SilentBtn.Size = UDim2.new(1, -20, 0, 30)
SilentBtn.Position = UDim2.new(0, 10, 0, 150)
SilentBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SilentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentBtn.Text = "🤫 Silent Aim: OFF"
SilentBtn.Font = Enum.Font.SourceSans
SilentBtn.TextSize = 12
SilentBtn.Parent = MainFrame

-- No Fog Button
local FogBtn = Instance.new("TextButton")
FogBtn.Size = UDim2.new(1, -20, 0, 30)
FogBtn.Position = UDim2.new(0, 10, 0, 184)
FogBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FogBtn.Text = "🌫️ No Fog: OFF"
FogBtn.Font = Enum.Font.SourceSans
FogBtn.TextSize = 12
FogBtn.Parent = MainFrame

-- Terminate Button
local TermBtn = Instance.new("TextButton")
TermBtn.Size = UDim2.new(1, -20, 0, 25)
TermBtn.Position = UDim2.new(0, 10, 0, 218)
TermBtn.BackgroundColor3 = Color3.fromRGB(120, 25, 25)
TermBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
TermBtn.Text = "⏏ TERMINATE"
TermBtn.Font = Enum.Font.SourceSansBold
TermBtn.TextSize = 11
TermBtn.Parent = MainFrame

-- =============================================
-- BUTTON FUNCTIONS
-- =============================================

-- Movement Speed
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedBtn.Text = "🏃 Speed " .. WalkSpeed .. ": ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
    else
        SpeedBtn.Text = "🏃 Speed " .. WalkSpeed .. ": OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        -- Reset speed
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = DefaultWalkSpeed
        end
    end
end)

-- Aimbot
AimBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    if AimbotEnabled then
        AimBtn.Text = "🎯 Aimbot: ON"
        AimBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        SilentAimEnabled = false
        SilentBtn.Text = "🤫 Silent Aim: OFF"
        SilentBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        AimBtn.Text = "🎯 Aimbot: OFF"
        AimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Silent Aim
SilentBtn.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    if SilentAimEnabled then
        SilentBtn.Text = "🤫 Silent Aim: ON"
        SilentBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        AimbotEnabled = false
        AimBtn.Text = "🎯 Aimbot: OFF"
        AimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        SilentBtn.Text = "🤫 Silent Aim: OFF"
        SilentBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- No Fog
FogBtn.MouseButton1Click:Connect(function()
    NoFogEnabled = not NoFogEnabled
    if NoFogEnabled then
        FogBtn.Text = "🌫️ No Fog: ON"
        FogBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        -- Remove fog
        pcall(function()
            Lighting.FogEnd = 99999
            Lighting.FogStart = 99999
            Lighting.Brightness = 2
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then
                atmosphere:Destroy()
            end
        end)
    else
        FogBtn.Text = "🌫️ No Fog: OFF"
        FogBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        -- Reset fog
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
    -- Reset everything
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
-- LOOPS
-- =============================================

-- Movement Speed Loop
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

-- Character respawn detection
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if SpeedEnabled then
        pcall(function()
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = WalkSpeed
            end
        end)
    end
end)

-- Aimbot Loop
task.spawn(function()
    while ScriptActive do
        if AimbotEnabled then
            pcall(function()
                local target = nil
                local closestDist = 200 -- pixels
                
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

-- Silent Aim Loop
task.spawn(function()
    while ScriptActive do
        if SilentAimEnabled then
            pcall(function()
                local target = nil
                local closestDist = 300
                
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
                                    target = head
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- No Fog persistent check
task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            pcall(function()
                Lighting.FogEnd = 99999
                Lighting.FogStart = 99999
                local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                if atmosphere then
                    atmosphere:Destroy()
                end
            end)
        end
        task.wait(5)
    end
end)

print("BRM5 PvE Script Ready!")
print("Features: Speed " .. WalkSpeed .. " | Aimbot | Silent Aim | No Fog")
