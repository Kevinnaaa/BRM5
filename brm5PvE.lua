--[[
    BRM5 PvE Script - RAYFIELD STYLE (FIXED SPEED + AIMBOT + SILENT AIM + ESP)
    Permanent Speed 50 + Aimbot + Silent Aim + No Fog + Enemy ESP
    Open World PvE Only | FPS/Ping/Time Display | Minimize to Icon
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local ScriptActive = true
local AimbotEnabled = false
local SilentAimEnabled = false
local NoFogEnabled = false
local Minimized = false
local ESPEnabled = false
local SilentTarget = nil
local SpeedBoostEnabled = true

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 35
local ESPCache = {}
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()
local saniye, dakika, saat = 0, 0, 0

-- Clean up
if getgenv().BRM5Loaded then
    getgenv().BRM5Loaded = false
    if game.CoreGui:FindFirstChild("BRM5GUI") then game.CoreGui.BRM5GUI:Destroy() end
    if game.CoreGui:FindFirstChild("BRM5Icon") then game.CoreGui.BRM5Icon:Destroy() end
    for _, esp in pairs(ESPCache) do
        pcall(function() esp.box:Remove() end)
        pcall(function() esp.distText:Remove() end)
    end
end
getgenv().BRM5Loaded = true

-- =============================================
-- SPEED
-- =============================================
local function setSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = PERMANENT_SPEED end
        end
    end)
end
setSpeed()
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.WalkSpeed = PERMANENT_SPEED end
    end)
end)
task.spawn(function()
    while ScriptActive and SpeedBoostEnabled do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.WalkSpeed ~= PERMANENT_SPEED then hum.WalkSpeed = PERMANENT_SPEED end
            end
        end)
        task.wait(0.5)
    end
end)

-- =============================================
-- ESP
-- =============================================
local function createESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Color3.fromRGB(255, 50, 50)
    box.Thickness = 2; box.Filled = false; box.Transparency = 1
    local distText = Drawing.new("Text")
    distText.Visible = false; distText.Color = Color3.fromRGB(255, 255, 255)
    distText.Size = 14; distText.Center = true; distText.Outline = true
    distText.OutlineColor = Color3.fromRGB(0, 0, 0)
    ESPCache[player] = {box = box, distText = distText}
end
local function removeESP(player)
    if ESPCache[player] then
        pcall(function() ESPCache[player].box:Remove() end)
        pcall(function() ESPCache[player].distText:Remove() end)
        ESPCache[player] = nil
    end
end
local function updateESP()
    for player, esp in pairs(ESPCache) do
        pcall(function()
            if player and player.Character and player.Character:FindFirstChild("Humanoid") 
            and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") 
            and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local scale = 1000 / (Camera.CFrame.Position - root.Position).Magnitude
                    local boxSize = Vector2.new(2 * scale, 3 * scale)
                    esp.box.Visible = ESPEnabled
                    esp.box.Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y)
                    esp.box.Size = boxSize
                    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                    esp.distText.Visible = ESPEnabled
                    esp.distText.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y - 15)
                    esp.distText.Text = player.Name .. " [" .. dist .. "m]"
                    if dist < 50 then esp.box.Color = Color3.fromRGB(255, 50, 50)
                    elseif dist < 150 then esp.box.Color = Color3.fromRGB(255, 200, 0)
                    else esp.box.Color = Color3.fromRGB(100, 255, 100) end
                else esp.box.Visible = false; esp.distText.Visible = false end
            else esp.box.Visible = false; esp.distText.Visible = false end
        end)
    end
end
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end
Players.PlayerAdded:Connect(function(p) task.wait(1); createESP(p) end)
Players.PlayerRemoving:Connect(removeESP)
task.spawn(function() while ScriptActive do if ESPEnabled then updateESP() end task.wait() end end)

-- =============================================
-- GUI
-- =============================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "BRM5GUI"; GUI.ResetOnSpawn = false; GUI.Parent = game.CoreGui; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 300); Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.BorderSizePixel = 0; Main.ClipsDescendants = true; Main.Parent = GUI
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Minimize Icon
local MinimizeIcon = Instance.new("TextButton")
MinimizeIcon.Size = UDim2.new(0, 45, 0, 45); MinimizeIcon.Position = UDim2.new(0, 10, 0, 80)
MinimizeIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MinimizeIcon.TextColor3 = Color3.fromRGB(180, 200, 255)
MinimizeIcon.Text = "🔫"; MinimizeIcon.Font = Enum.Font.GothamBold; MinimizeIcon.TextSize = 20
MinimizeIcon.AutoButtonColor = false; MinimizeIcon.Visible = false; MinimizeIcon.Parent = GUI
Instance.new("UICorner", MinimizeIcon).CornerRadius = UDim.new(0, 8)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32); TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TitleBar.Parent = Main

local FPSDisplay = Instance.new("TextLabel")
FPSDisplay.Size = UDim2.new(0, 50, 1, 0); FPSDisplay.Position = UDim2.new(0, 10, 0, 0)
FPSDisplay.BackgroundTransparency = 1; FPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 100)
FPSDisplay.Text = "FPS: --"; FPSDisplay.Font = Enum.Font.GothamBold; FPSDisplay.TextSize = 10; FPSDisplay.Parent = TitleBar

local PingDisplay = Instance.new("TextLabel")
PingDisplay.Size = UDim2.new(0, 65, 1, 0); PingDisplay.Position = UDim2.new(0, 62, 0, 0)
PingDisplay.BackgroundTransparency = 1; PingDisplay.TextColor3 = Color3.fromRGB(100, 200, 255)
PingDisplay.Text = "Ping: --"; PingDisplay.Font = Enum.Font.GothamBold; PingDisplay.TextSize = 10; PingDisplay.Parent = TitleBar

local TimerDisplay = Instance.new("TextLabel")
TimerDisplay.Size = UDim2.new(0, 70, 1, 0); TimerDisplay.Position = UDim2.new(0, 130, 0, 0)
TimerDisplay.BackgroundTransparency = 1; TimerDisplay.TextColor3 = Color3.fromRGB(255, 200, 0)
TimerDisplay.Text = "0:0:0"; TimerDisplay.Font = Enum.Font.GothamBold; TimerDisplay.TextSize = 10; TimerDisplay.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -290, 1, 0); TitleText.Position = UDim2.new(0, 205, 0, 0)
TitleText.BackgroundTransparency = 1; TitleText.TextColor3 = Color3.fromRGB(180, 200, 255)
TitleText.Text = "brm5 pve"; TitleText.Font = Enum.Font.GothamBold; TitleText.TextSize = 11; TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28); MinBtn.Position = UDim2.new(1, -33, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "—"; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false; MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -32); ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1; ContentContainer.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(23, 23, 23); Sidebar.Parent = ContentContainer
Instance.new("Frame", Sidebar).Size = UDim2.new(0, 1, 1, 0); -- (border simplified)

local SidebarLogo = Instance.new("Frame")
SidebarLogo.Size = UDim2.new(1, 0, 0, 45); SidebarLogo.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SidebarLogo.Parent = Sidebar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -20, 0, 20); LogoText.Position = UDim2.new(0, 10, 0, 5)
LogoText.BackgroundTransparency = 1; LogoText.TextColor3 = Color3.fromRGB(180, 200, 255)
LogoText.Text = "🔫 BRM5 PvE"; LogoText.Font = Enum.Font.GothamBold; LogoText.TextSize = 10; LogoText.Parent = SidebarLogo

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -20, 0, 14); LogoSub.Position = UDim2.new(0, 10, 0, 24)
LogoSub.BackgroundTransparency = 1; LogoSub.TextColor3 = Color3.fromRGB(120, 120, 120)
LogoSub.Text = "by Maryyy"; LogoSub.Font = Enum.Font.Gotham; LogoSub.TextSize = 9; LogoSub.Parent = SidebarLogo

-- Tab System
local TabButtons, TabPages = {}, {}
local function CreateTab(name, icon, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32); btn.Position = UDim2.new(0, 10, 0, 52 + (index-1)*36)
    btn.BackgroundColor3 = index == 1 and Color3.fromRGB(40,40,40) or Color3.fromRGB(23,23,23)
    btn.TextColor3 = index == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
    btn.Text = "  " .. icon .. "  " .. name; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.AutoButtonColor = false; btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -140, 1, 0); page.Position = UDim2.new(0, 140, 0, 0)
    page.BackgroundTransparency = 1; page.Visible = (index == 1); page.Parent = ContentContainer
    btn.MouseButton1Click:Connect(function()
        for i = 1, #TabButtons do
            TabButtons[i].BackgroundColor3 = Color3.fromRGB(23,23,23)
            TabButtons[i].TextColor3 = Color3.fromRGB(150,150,150)
            TabPages[i].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40); btn.TextColor3 = Color3.fromRGB(255,255,255); page.Visible = true
    end)
    table.insert(TabButtons, btn); table.insert(TabPages, page); return page
end

-- UI Helpers
local function CreateSection(parent, title, yPos)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, -30, 0, 20); s.Position = UDim2.new(0, 15, 0, yPos); s.BackgroundTransparency = 1; s.Parent = parent
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1); line.BackgroundColor3 = Color3.fromRGB(40,40,40); line.Parent = s
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 16); text.Position = UDim2.new(0, 0, 0, 3)
    text.BackgroundTransparency = 1; text.TextColor3 = Color3.fromRGB(120,120,120)
    text.Text = title; text.Font = Enum.Font.GothamBold; text.TextSize = 9; text.Parent = s
    return s
end

local function CreateToggle(parent, title, default, yPos, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 30); bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(25,25,25); bg.Parent = parent
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, -10, 1, 0); label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Text = title; label.Font = Enum.Font.Gotham; label.TextSize = 11; label.Parent = bg
    local state = default
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 18); switch.Position = UDim2.new(1, -46, 0.5, -9)
    switch.BackgroundColor3 = state and Color3.fromRGB(60,160,60) or Color3.fromRGB(50,50,50)
    switch.Text = ""; switch.AutoButtonColor = false; switch.Parent = bg
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255); dot.Parent = switch
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
    btn.Size = UDim2.new(1, -30, 0, 32); btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = accent or Color3.fromRGB(30,30,30); btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = title; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.AutoButtonColor = false; btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = accent and Color3.fromRGB(120,30,30) or Color3.fromRGB(40,40,40) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = accent or Color3.fromRGB(30,30,30) end)
    return btn
end

local function CreateInfoLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -30, 0, 18); lbl.Position = UDim2.new(0, 15, 0, yPos)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = color or Color3.fromRGB(200,200,200)
    lbl.Text = text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.Parent = parent
    return lbl
end

-- Create Tabs
local CombatPage = CreateTab("Combat", "🎯", 1)
local VisualsPage = CreateTab("Visuals", "👁", 2)
local SettingsPage = CreateTab("Settings", "⚙️", 3)

-- Combat Tab
CreateSection(CombatPage, "AIM ASSIST", 10)
CreateToggle(CombatPage, "Aimbot", false, 34, function(s) AimbotEnabled = s; if s then SilentAimEnabled = false end end)
CreateToggle(CombatPage, "Silent Aim (RMB)", false, 68, function(s) SilentAimEnabled = s; if s then AimbotEnabled = false else SilentTarget = nil end end)
CreateSection(CombatPage, "PERMANENT STATS", 110)
CreateInfoLabel(CombatPage, "🏃 Speed: 50 (Always On)", 134, Color3.fromRGB(100,255,100))
CreateInfoLabel(CombatPage, "Default: 35", 154, Color3.fromRGB(150,150,150))

-- Visuals Tab
CreateSection(VisualsPage, "ESP", 10)
CreateToggle(VisualsPage, "Enemy ESP", false, 34, function(s) ESPEnabled = s end)
CreateSection(VisualsPage, "ENVIRONMENT", 76)
CreateToggle(VisualsPage, "No Fog", false, 100, function(s)
    NoFogEnabled = s
    if s then
        pcall(function() Lighting.FogEnd = 99999; Lighting.FogStart = 99999; Lighting.Brightness = 2
            local at = Lighting:FindFirstChildOfClass("Atmosphere"); if at then at:Destroy() end end)
    else
        pcall(function() Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1 end)
    end
end)

-- Settings Tab
CreateSection(SettingsPage, "INFO", 10)
local SettingsName = Instance.new("TextLabel")
SettingsName.Size = UDim2.new(1, -30, 0, 20); SettingsName.Position = UDim2.new(0, 15, 0, 34)
SettingsName.BackgroundTransparency = 1; SettingsName.TextColor3 = Color3.fromRGB(255,255,255)
SettingsName.Text = "🔫 " .. LocalPlayer.Name; SettingsName.Font = Enum.Font.GothamBold; SettingsName.TextSize = 12; SettingsName.Parent = SettingsPage
CreateSection(SettingsPage, "TERMINATE", 66)
CreateButton(SettingsPage, "⚠️ TERMINATE SCRIPT", 90, function()
    ScriptActive = false; SpeedBoostEnabled = false; SilentTarget = nil
    for _, esp in pairs(ESPCache) do pcall(function() esp.box:Remove() end); pcall(function() esp.distText:Remove() end) end
    ESPCache = {}
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = DEFAULT_SPEED end
    pcall(function() Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1 end)
    GUI:Destroy()
end, Color3.fromRGB(100, 20, 20))

-- Minimize
local function showMain() Main.Visible = true; MinimizeIcon.Visible = false; Minimized = false end
local function showIcon() Main.Visible = false; MinimizeIcon.Visible = true; Minimized = true end
MinBtn.MouseButton1Click:Connect(showIcon); MinimizeIcon.MouseButton1Click:Connect(showMain)

local idragging, idragStart, istartPos = false, nil, nil
MinimizeIcon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then idragging = true; idragStart = i.Position; istartPos = MinimizeIcon.Position end
end)
MinimizeIcon.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        if idragging and (i.Position - idragStart).Magnitude < 5 then showMain() end; idragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if idragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - idragStart
        MinimizeIcon.Position = UDim2.new(istartPos.X.Scale, istartPos.X.Offset + d.X, istartPos.Y.Scale, istartPos.Y.Offset + d.Y)
    end
end)

local dActive, dInput, dStart, sPos = false, nil, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dActive = true; dStart = i.Position; sPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dActive = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dInput = i end end)
RunService.RenderStepped:Connect(function()
    if dActive and dInput then
        local d = dInput.Position - dStart
        Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)

-- Silent Aim
UserInputService.InputBegan:Connect(function(input, gp)
    if SilentAimEnabled and not gp and input.UserInputType == Enum.UserInputType.MouseButton2 then
        pcall(function()
            local closest, cd = nil, 500
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local h = p.Character.Head; local _, os = Camera:WorldToViewportPoint(h.Position)
                    if os then local dist = (h.Position - Camera.CFrame.Position).Magnitude
                        if dist < cd then cd = dist; closest = h end
                    end
                end
            end
            if closest then
                local old = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                Camera.CFrame = old
            end
        end)
    end
end)

-- Aimbot
task.spawn(function()
    while ScriptActive do
        if AimbotEnabled then
            pcall(function()
                local closest, cd = nil, 300
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local sp, os = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        if os then
                            local c = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            local dist = (Vector2.new(sp.X, sp.Y) - c).Magnitude
                            if dist < cd then cd = dist; closest = sp end
                        end
                    end
                end
                if closest then
                    local c = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    mousemoverel((closest.X - c.X) * 0.5, (closest.Y - c.Y) * 0.5)
                end
            end)
        end
        task.wait()
    end
end)

-- Update Loops
task.spawn(function()
    while ScriptActive do
        fpsCount += 1
        if tick() - lastFPSUpdate >= 0.5 then
            fps = math.floor(fpsCount / (tick() - lastFPSUpdate)); fpsCount = 0; lastFPSUpdate = tick()
            FPSDisplay.Text = "FPS: " .. fps
            FPSDisplay.TextColor3 = fps >= 50 and Color3.fromRGB(0,255,100) or (fps >= 25 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
        end; task.wait()
    end
end)
task.spawn(function()
    while ScriptActive do
        pcall(function()
            local p = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            PingDisplay.Text = "Ping: " .. p .. "ms"
            PingDisplay.TextColor3 = p <= 80 and Color3.fromRGB(100,200,255) or (p <= 150 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,100,100))
        end); task.wait(1)
    end
end)
task.spawn(function()
    while ScriptActive do
        saniye += 1; if saniye >= 60 then saniye = 0; dakika += 1 end
        if dakika >= 60 then dakika = 0; saat += 1 end
        TimerDisplay.Text = saat .. ":" .. dakika .. ":" .. saniye; task.wait(1)
    end
end)
task.spawn(function()
    while ScriptActive do
        if NoFogEnabled then
            pcall(function() Lighting.FogEnd = 99999; Lighting.FogStart = 99999
                local at = Lighting:FindFirstChildOfClass("Atmosphere"); if at then at:Destroy() end end)
        end; task.wait(5)
    end
end)

print("✅ BRM5 PvE Loaded! | Speed:50 | Aimbot | Silent Aim | ESP | No Fog")
