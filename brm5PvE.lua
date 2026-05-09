--[[
    BRM5 PvE Script - Fixed ESP + Silent Aim for NPCs
    Works on AI enemies in Open World
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ScriptActive = true
local SpeedEnabled = false
local AimbotEnabled = false
local SilentAimEnabled = false
local NoFogEnabled = false
local ESPEnabled = false
local Minimized = false
local WalkSpeed = 50
local DefaultWalkSpeed = 35
local SilentTarget = nil

-- ESP Storage
local ESPObjects = {}

-- =============================================
-- FIXED ESP - Works on Players AND NPCs
-- =============================================
local function isEnemy(obj)
    if not obj:IsA("Model") then return false end
    if obj == LocalPlayer.Character then return false end
    
    -- Check if it's a player
    local player = Players:GetPlayerFromCharacter(obj)
    if player then
        if player == LocalPlayer then return false end
        if player.Team == LocalPlayer.Team then return false end
        return true
    end
    
    -- Check if it's an NPC (has Humanoid + Health > 0)
    local humanoid = obj:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        return true
    end
    
    return false
end

local function getTargetPart(obj)
    return obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
end

local function updateESP()
    -- Clear old ESP
    for _, esp in pairs(ESPObjects) do
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.HealthBar.Visible = false
        esp.HealthFill.Visible = false
        esp.HeadDot.Visible = false
    end
    
    if not ESPEnabled then return end
    if not LocalPlayer.Character then return end
    
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local index = 1
    
    -- Search all models in workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isEnemy(obj) then
            local targetPart = getTargetPart(obj)
            local head = obj:FindFirstChild("Head")
            
            if targetPart and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                
                if onScreen then
                    local distance = (myRoot.Position - targetPart.Position).Magnitude
                    local humanoid = obj:FindFirstChild("Humanoid")
                    local name = obj.Name
                    
                    -- Get or create ESP for this index
                    if not ESPObjects[index] then
                        ESPObjects[index] = {
                            Box = Drawing.new("Square"),
                            Name = Drawing.new("Text"),
                            Distance = Drawing.new("Text"),
                            HealthFill = Drawing.new("Square"),
                            HeadDot = Drawing.new("Circle")
                        }
                    end
                    
                    local esp = ESPObjects[index]
                    
                    -- Box
                    local boxHeight = (headPos.Y - screenPos.Y) * 0.8
                    local boxWidth = boxHeight * 0.5
                    local boxX = screenPos.X - boxWidth / 2
                    local boxY = screenPos.Y
                    
                    esp.Box.Visible = true
                    esp.Box.Color = Color3.fromRGB(255, 50, 50)
                    esp.Box.Thickness = 1
                    esp.Box.Filled = false
                    esp.Box.Size = Vector2.new(math.max(boxWidth, 10), math.max(boxHeight, 10))
                    esp.Box.Position = Vector2.new(boxX, boxY)
                    
                    -- Name
                    esp.Name.Visible = true
                    esp.Name.Text = name
                    esp.Name.Color = Color3.fromRGB(255, 255, 255)
                    esp.Name.Size = 13
                    esp.Name.Center = true
                    esp.Name.Outline = true
                    esp.Name.Position = Vector2.new(screenPos.X, boxY - 15)
                    
                    -- Distance
                    esp.Distance.Visible = true
                    esp.Distance.Text = math.floor(distance) .. "s"
                    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
                    esp.Distance.Size = 12
                    esp.Distance.Center = true
                    esp.Distance.Outline = true
                    esp.Distance.Position = Vector2.new(screenPos.X, boxY + boxHeight + 5)
                    
                    -- Health bar
                    if humanoid then
                        local health = humanoid.Health / humanoid.MaxHealth
                        esp.HealthFill.Visible = true
                        esp.HealthFill.Color = health > 0.5 and Color3.fromRGB(50, 255, 50) or (health > 0.25 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
                        esp.HealthFill.Filled = true
                        esp.HealthFill.Size = Vector2.new(2, boxHeight * health)
                        esp.HealthFill.Position = Vector2.new(boxX - 4, boxY + boxHeight * (1 - health))
                    end
                    
                    -- Head dot
                    esp.HeadDot.Visible = true
                    esp.HeadDot.Color = Color3.fromRGB(255, 0, 0)
                    esp.HeadDot.Filled = true
                    esp.HeadDot.NumSides = 30
                    esp.HeadDot.Radius = 4
                    esp.HeadDot.Position = Vector2.new(screenPos.X, headPos.Y)
                    
                    index = index + 1
                end
            end
        end
    end
end

local function clearESP()
    for _, esp in pairs(ESPObjects) do
        pcall(function() esp.Box:Remove() end)
        pcall(function() esp.Name:Remove() end)
        pcall(function() esp.Distance:Remove() end)
        pcall(function() esp.HealthFill:Remove() end)
        pcall(function() esp.HeadDot:Remove() end)
    end
    ESPObjects = {}
end

-- =============================================
-- FIXED SILENT AIM - Works on NPCs too
-- =============================================
local function findBestTarget()
    local best = nil
    local bestDist = 1000
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isEnemy(obj) then
            local head = obj:FindFirstChild("Head")
            if head then
                local _, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (head.Position - Camera.CFrame.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = head
                    end
                end
            end
        end
    end
    
    return best
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if SilentAimEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        pcall(function()
            local target = findBestTarget()
            if target then
                local oldCFrame = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                SilentTarget = {old = oldCFrame}
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
-- GUI (same as before but with fixed features)
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BRM5PvE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

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

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 298)
MainFrame.Position = UDim2.new(0, 60, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

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

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 37)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Text = "● Ready | PvE Mode"
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

-- Buttons
local function makeBtn(y, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 12
    btn.Parent = MainFrame
    return btn
end

local SpeedBtn = makeBtn(80, "🏃  Movement Speed: OFF")
local AimBtn = makeBtn(116, "🎯  Aimbot: OFF")
local SilentBtn = makeBtn(152, "🤫  Silent Aim: OFF")
local ESPBtn = makeBtn(188, "👁️  Enemy ESP: OFF")
local FogBtn = makeBtn(224, "🌫️  No Fog: OFF")

local Div2 = Instance.new("Frame")
Div2.Size = UDim2.new(1, 0, 0, 1)
Div2.Position = UDim2.new(0, 0, 0, 260)
Div2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Div2.BorderSizePixel = 0
Div2.Parent = MainFrame

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

-- =============================================
-- BUTTON FUNCTIONS
-- =============================================
local function toggleMinimize()
    Minimized = not Minimized
    MainFrame.Visible = not Minimized
    MinBtn.BackgroundColor3 = Minimized and Color3.fromRGB(30, 100, 150) or Color3.fromRGB(25, 25, 25)
end
MinBtn.MouseButton1Click:Connect(toggleMinimize)
DashBtn.MouseButton1Click:Connect(toggleMinimize)

SpeedBtn.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    SpeedBtn.Text = SpeedEnabled and "🏃  Speed: ON ["..WalkSpeed.."]" or "🏃  Movement Speed: OFF"
    SpeedBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(45, 45, 45)
end)

AimBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimBtn.Text = "🎯  Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    AimBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(45, 45, 45)
end)

SilentBtn.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    SilentBtn.Text = "🤫  Silent Aim: " .. (SilentAimEnabled and "ON" or "OFF")
    SilentBtn.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(45, 45, 45)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPBtn.Text = "👁️  Enemy ESP: " .. (ESPEnabled and "ON" or "OFF")
    ESPBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(45, 45, 45)
end)

FogBtn.MouseButton1Click:Connect(function()
    NoFogEnabled = not NoFogEnabled
    FogBtn.Text = "🌫️  No Fog: " .. (NoFogEnabled and "ON" or "OFF")
    FogBtn.BackgroundColor3 = NoFogEnabled and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(45, 45, 45)
    if NoFogEnabled then
        Lighting.FogEnd = 99999
        Lighting.FogStart = 99999
    else
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
    end
end)

TermBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    clearESP()
    ScreenGui:Destroy()
end)

-- =============================================
-- LOOPS
-- =============================================

-- Speed
task.spawn(function()
    while ScriptActive do
        if SpeedEnabled and LocalPlayer.Character then
            pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed end)
        end
        task.wait(0.5)
    end
end)

-- ESP
task.spawn(function()
    while ScriptActive do
        updateESP()
        task.wait()
    end
end)

-- No Fog
task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            pcall(function() Lighting.FogEnd = 99999 end)
        end
        task.wait(5)
    end
end)

print("BRM5 PvE Ready! ESP + Silent Aim now works on NPCs!")
