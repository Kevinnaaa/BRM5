-- ============================================
-- BRM5 PvE v1 - NO ESP + NO RECOIL + AUTO ANTI-AFK + NPC DETECTOR
-- MODERN UI - Custom Teal Theme (#007F7C)
-- UI toggled with ` (backtick) key
-- MinBar shows "BRM5 by Maryyy" (loading indicator)
-- No Fog: main-menu safe (auto-resets when leaving game)
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
local UIVisible = true

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local MAX_HUNGER = 100
local MAX_THIRST = 100
local fpsCount, fps, lastFPSUpdate = 0, 0, tick()
local saniye, dakika, saat = 0, 0, 0
local inGameState = false
local fogConnection = nil

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
-- IN-GAME DETECTION (main-menu safe)
-- ============================================
local function checkInGame()
    local ok, result = pcall(function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local cam = Workspace.CurrentCamera
        return hum ~= nil and hum.Health > 0 and char:IsDescendantOf(Workspace) and cam ~= nil
    end)
    inGameState = ok and result == true
    return inGameState
end

-- ============================================
-- SAFE NO FOG (main-menu protected)
-- ============================================
local fogApplied = false
local originalFogEnd = Lighting.FogEnd
local originalFogStart = Lighting.FogStart
local originalProps = {}      -- [instance] = {prop = originalValue}
local fogHooks = {}
local fogConnection2 = nil

local FOG_NAMES = {"fog", "mist", "haze", "smog"}

local function looksLikeFog(name)
    name = name:lower()
    for _, p in ipairs(FOG_NAMES) do
        if name:find(p, 1, true) then return true end
    end
    return false
end

local function setProp(inst, prop, value)
    local ok, current = pcall(function() return inst[prop] end)
    if not ok or current == value then return end
    local saved = originalProps[inst]
    if not saved then
        saved = {}
        originalProps[inst] = saved
    end
    if saved[prop] == nil then saved[prop] = current end
    pcall(function() inst[prop] = value end)
end

-- Neutralise one instance if it is a weather/fog source
local function killFogInstance(inst)
    if inst:IsA("Atmosphere") then
        setProp(inst, "Density", 0)
        setProp(inst, "Haze", 0)
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
        if looksLikeFog(inst.Name) or (inst.Parent and looksLikeFog(inst.Parent.Name)) then
            setProp(inst, "Enabled", false)
        end
    elseif inst:IsA("ColorCorrectionEffect") or inst:IsA("BlurEffect") or inst:IsA("BloomEffect") or inst:IsA("SunRaysEffect") then
        if looksLikeFog(inst.Name) then
            setProp(inst, "Enabled", false)
        end
    elseif inst:IsA("BasePart") then
        local char = player.Character
        if looksLikeFog(inst.Name) and not (char and inst:IsDescendantOf(char)) then
            setProp(inst, "Transparency", 1)
        end
    end
end

local function fastAtmosphereKill()
    -- Cheap per-frame pass over the places weather systems normally touch
    local cam = Workspace.CurrentCamera
    local roots = {Lighting, Workspace.Terrain, cam}
    for _, root in ipairs(roots) do
        if root then
            for _, v in ipairs(root:GetChildren()) do
                if v:IsA("Atmosphere") then
                    if v.Density ~= 0 then setProp(v, "Density", 0) end
                    if v.Haze ~= 0 then setProp(v, "Haze", 0) end
                end
            end
        end
    end
end

local function startFogHooks()
    -- Catch new fog/weather objects the moment the game spawns them
    table.insert(fogHooks, Lighting.DescendantAdded:Connect(function(d)
        task.defer(function() pcall(killFogInstance, d) end)
    end))
    table.insert(fogHooks, Workspace.DescendantAdded:Connect(function(d)
        task.defer(function() pcall(killFogInstance, d) end)
    end))

    -- Full one-time scan of existing objects (chunked so it doesn't freeze)
    task.spawn(function()
        for _, root in ipairs({Lighting, Workspace}) do
            local n = 0
            for _, d in ipairs(root:GetDescendants()) do
                pcall(killFogInstance, d)
                n = n + 1
                if n % 1500 == 0 then task.wait() end
            end
        end
    end)
end

local function stopFogHooks()
    for _, c in ipairs(fogHooks) do c:Disconnect() end
    fogHooks = {}
end

local function restoreFog()
    if not fogApplied then return end
    stopFogHooks()
    pcall(function()
        Lighting.FogEnd = originalFogEnd
        Lighting.FogStart = originalFogStart
    end)
    for inst, props in pairs(originalProps) do
        if inst.Parent then
            for prop, value in pairs(props) do
                pcall(function() inst[prop] = value end)
            end
        end
    end
    originalProps = {}
    fogApplied = false
end

local function applyNoFog(enabled)
    if not enabled or not checkInGame() then
        restoreFog()
        return
    end
    pcall(function()
        if not fogApplied then
            originalFogEnd = Lighting.FogEnd
            originalFogStart = Lighting.FogStart
            fogApplied = true
            startFogHooks()
        end

        Lighting.FogStart = 1e6
        Lighting.FogEnd = 1e6
        fastAtmosphereKill()
    end)
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
-- NPC DETECTOR
-- ============================================
local NPCDetectorEnabled = false
local NPC_RANGE = 500          -- studs
local NPC_DANGER_RANGE = 50    -- HUD turns red inside this
local npcCache = {}            -- [model] = humanoid
local npcConnections = {}

local function isNPCModel(model)
    if not model or not model:IsA("Model") then return false end
    if model == player.Character then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    return root ~= nil
end

local function registerNPC(hum)
    local model = hum.Parent
    if isNPCModel(model) then
        npcCache[model] = hum
    end
end

task.spawn(function()
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Humanoid") then registerNPC(d) end
    end
end)

table.insert(npcConnections, Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then
        task.defer(registerNPC, d)
    end
end))

table.insert(npcConnections, Workspace.DescendantRemoving:Connect(function(d)
    if d:IsA("Humanoid") then
        npcCache[d.Parent] = nil
    end
end))

-- HUD
local NPCHud = Instance.new("Frame")
NPCHud.Name = "NPCHud"
NPCHud.Parent = ScreenGui
NPCHud.BackgroundColor3 = BACKGROUND
NPCHud.BackgroundTransparency = 0.15
NPCHud.BorderSizePixel = 0
NPCHud.Position = UDim2.new(0.5, -130, 0, 12)
NPCHud.Size = UDim2.new(0, 260, 0, 46)
NPCHud.Visible = false
NPCHud.ZIndex = 30
RoundCorners(NPCHud, 10)
do
    local s = Instance.new("UIStroke", NPCHud)
    s.Color = BORDER
    s.Thickness = 1
end

local NPCCountLabel = Instance.new("TextLabel")
NPCCountLabel.Parent = NPCHud
NPCCountLabel.BackgroundTransparency = 1
NPCCountLabel.Position = UDim2.new(0, 0, 0, 3)
NPCCountLabel.Size = UDim2.new(1, 0, 0, 20)
NPCCountLabel.Font = Enum.Font.GothamBold
NPCCountLabel.Text = "NPCs in range: 0"
NPCCountLabel.TextColor3 = TEXT
NPCCountLabel.TextSize = 14
NPCCountLabel.ZIndex = 31

local NPCNearestLabel = Instance.new("TextLabel")
NPCNearestLabel.Parent = NPCHud
NPCNearestLabel.BackgroundTransparency = 1
NPCNearestLabel.Position = UDim2.new(0, 0, 0, 24)
NPCNearestLabel.Size = UDim2.new(1, 0, 0, 18)
NPCNearestLabel.Font = Enum.Font.Gotham
NPCNearestLabel.Text = "Nearest: none"
NPCNearestLabel.TextColor3 = TEXTDIM
NPCNearestLabel.TextSize = 12
NPCNearestLabel.ZIndex = 31

local function clockDirection(worldPos)
    local cam = Workspace.CurrentCamera
    if not cam then return "?" end
    local rel = cam.CFrame:PointToObjectSpace(worldPos)
    local angle = math.deg(math.atan2(rel.X, -rel.Z)) % 360
    local hour = math.floor(angle / 30 + 0.5) % 12
    if hour == 0 then hour = 12 end
    return hour .. " o'clock"
end

local function updateNPCDetector()
    local myChar = player.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
    if not myRoot then
        NPCCountLabel.Text = "NPCs in range: --"
        NPCNearestLabel.Text = "Nearest: none"
        return
    end

    local count, nearestDist, nearestPos = 0, math.huge, nil

    for model, hum in pairs(npcCache) do
        if not model.Parent or hum.Health <= 0 then
            npcCache[model] = nil
        else
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            if root then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist <= NPC_RANGE then
                    count = count + 1
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPos = root.Position
                    end
                end
            end
        end
    end

    NPCCountLabel.Text = "NPCs in range: " .. count
    if nearestPos then
        NPCNearestLabel.Text = string.format("Nearest: %dm  •  %s", math.floor(nearestDist), clockDirection(nearestPos))
        local danger = nearestDist <= NPC_DANGER_RANGE
        NPCNearestLabel.TextColor3 = danger and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(255, 220, 100)
        NPCCountLabel.TextColor3 = danger and Color3.fromRGB(255, 90, 90) or TEXT
    else
        NPCNearestLabel.Text = "Nearest: none"
        NPCNearestLabel.TextColor3 = TEXTDIM
        NPCCountLabel.TextColor3 = TEXT
    end
end

task.spawn(function()
    while ScriptActive do
        if NPCDetectorEnabled then
            pcall(updateNPCDetector)
            task.wait(0.25)
        else
            task.wait(0.5)
        end
    end
end)

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
-- MINI BAR (Loading Indicator — NOT clickable)
-- ============================================
local MinBar = Instance.new("Frame")
MinBar.Name = "MinBar"
MinBar.Parent = ScreenGui
MinBar.BackgroundColor3 = BACKGROUND
MinBar.BorderSizePixel = 0
MinBar.Position = UDim2.new(0.5, -150, 0.95, -20)
MinBar.Size = UDim2.new(0, 300, 0, 40)
MinBar.Visible = true
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
MinTitle.Size = UDim2.new(0, 200, 1, 0)
MinTitle.Font = Enum.Font.GothamBold
MinTitle.Text = "BRM5 by Maryyy"
MinTitle.TextColor3 = TEXT
MinTitle.TextSize = 14
MinTitle.TextXAlignment = Enum.TextXAlignment.Left

local MinStatus = Instance.new("TextLabel")
MinStatus.Parent = MinBar
MinStatus.BackgroundTransparency = 1
MinStatus.Position = UDim2.new(1, -70, 0, 0)
MinStatus.Size = UDim2.new(0, 60, 1, 0)
MinStatus.Font = Enum.Font.Gotham
MinStatus.Text = "● Loaded"
MinStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
MinStatus.TextSize = 11
MinStatus.TextXAlignment = Enum.TextXAlignment.Right

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
                if inGameState then
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
                if inGameState then
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
AddToggle("🌫️ No Fog", false, function(s)
    NoFogEnabled = s
    applyNoFog(s)
end)
AddSmallLabel("Auto-resets in main menu (no blank screen)", Color3.fromRGB(100, 255, 200))
AddSmallLabel("Removes fog, haze, mist & weather fog (restores on off)", Color3.fromRGB(160, 180, 200))

AddDivider()
AddSection("Detection")
AddToggle("📡 NPC Detector", false, function(s)
    NPCDetectorEnabled = s
    NPCHud.Visible = s
end)
AddSmallLabel("Shows NPC count, nearest distance and direction", Color3.fromRGB(100, 255, 200))
AddSmallLabel("Range: " .. NPC_RANGE .. " studs (red alert under " .. NPC_DANGER_RANGE .. ")", TEXTDIM)

-- ============================================
-- SETTINGS TAB
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
AddSection("Controls")
AddSmallLabel("Press ` (backtick) to toggle UI", Color3.fromRGB(255, 200, 100))
AddSmallLabel("Mini bar shows 'BRM5 by Maryyy' when hidden", TEXTDIM)

AddDivider()
AddSection("Info")
AddSmallLabel("🎯 " .. player.Name, TEXT)
AddSmallLabel("Features: Speed + No Recoil + No Fog + NPC Detector + Anti-AFK", TEXTDIM)

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
            NoFogEnabled = false
            NPCDetectorEnabled = false
            for _, c in ipairs(npcConnections) do c:Disconnect() end
            npcConnections = {}
            if fogConnection then fogConnection:Disconnect() fogConnection = nil end
            if fogConnection2 then fogConnection2:Disconnect() fogConnection2 = nil end
            pcall(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = DEFAULT_SPEED
                end
            end)
            -- Restore original fog
            restoreFog()
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
AddSmallLabel("Press ` to toggle UI", TEXTDIM)

-- ============================================
-- SELECT DEFAULT TAB
-- ============================================
speedTab.select()

-- ============================================
-- UI TOGGLE WITH ` KEY
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Backquote then
        UIVisible = not UIVisible

        if UIVisible then
            -- Show full UI
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.BackgroundTransparency = 1
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 640, 0, 480),
                BackgroundTransparency = 0
            }):Play()
            MinBar.Visible = false
        else
            -- Hide full UI, show mini bar
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.2)
            MainFrame.Visible = false
            MinBar.Visible = true
        end
    end
end)

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
    if not checkInGame() then return end
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
    if NoFogEnabled then applyNoFog(true) end
end)

task.spawn(function()
    while ScriptActive do
        if checkInGame() then
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
        if NoRecoilEnabled and checkInGame() then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                pcall(function()
                    local moveRel = mousemoverel or (Input and Input.MouseMoveRel) or mouse_moverel
                    if moveRel then
                        moveRel(0, RECOIL_STRENGTH)
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
-- FOG ENFORCER (runs every frame while enabled)
-- ============================================
local function fogTick()
    if ScriptActive and NoFogEnabled then
        applyNoFog(true)
    end
end
-- Run both before rendering and after physics so the game's own weather
-- updates can never leave a frame with fog visible
fogConnection = RunService.RenderStepped:Connect(fogTick)
fogConnection2 = RunService.Heartbeat:Connect(fogTick)

-- ============================================
-- GAME STATE MONITOR (reset fog when leaving game)
-- ============================================
task.spawn(function()
    local wasInGame = false
    while ScriptActive do
        local nowInGame = checkInGame()
        if wasInGame and not nowInGame then
            -- Just left game to menu — restore lighting
            restoreFog()
        end
        wasInGame = nowInGame
        task.wait(1)
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

-- Show mini bar initially (loading confirmation)
MinBar.Visible = true

print("✅ BRM5 PvE v1 Loaded! (No ESP + No Recoil + Auto Anti-AFK + NPC Detector)")
print("   Speed: " .. PERMANENT_SPEED)
print("   🤖 Anti-AFK: ACTIVE (always on)")
print("   ⌨️  Press ` (Backquote) to toggle UI on/off")
print("   🔫 Combat Tab: No Recoil")
print("   🌫️ No Fog: Main-menu safe (auto-resets)")
print("   📡 Visuals Tab: NPC Detector")
print("   🍖 Survival: Infinite Hunger & Thirst")
