-- BRM5 Rayfield GUI Script
-- LocalScript in StarterPlayerScripts
-- Backtick toggles GUI + unlocks mouse cursor
-- Real-time NPC distance ESP + Anti-AFK

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration
local ESPEnabled = true
local ShowDistance = true
local MaxDistance = 500
local ESPColor = Color3.fromRGB(255, 50, 50)
local scriptRunning = true
local AntiAFKEnabled = true

-- Fog state
local FogDisabled = false
local savedFog = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    FogColor = Lighting.FogColor,
}
local savedAtmospheres = {}
local savedColorCorrections = {}

-- Mouse / GUI state
local guiOpen = false
local originalMouseIconEnabled = UserInputService.MouseIconEnabled
local mouseOverrideConnection = nil

-- Connection tracking for clean termination
local connections = {}

local function addConnection(conn)
    table.insert(connections, conn)
end

local NPCFolders = {
    workspace:FindFirstChild("Enemies"),
    workspace:FindFirstChild("Hostiles"),
    workspace:FindFirstChild("NPCs"),
    workspace:FindFirstChild("EnemyNPCs"),
    workspace:FindFirstChild("Soldiers"),
    workspace:FindFirstChild("Guards"),
    workspace:FindFirstChild("AI"),
    workspace:FindFirstChild("AIs"),
    workspace:FindFirstChild("Mission"),
    workspace:FindFirstChild("Missions"),
}

local ESPObjects = {}

-- ============================================================
-- MOUSE / CURSOR HELPERS
-- ============================================================

local function unlockMouse()
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true

    if mouseOverrideConnection then
        mouseOverrideConnection:Disconnect()
        mouseOverrideConnection = nil
    end

    mouseOverrideConnection = RunService.RenderStepped:Connect(function()
        if guiOpen then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end
    end)
end

local function lockMouse()
    if mouseOverrideConnection then
        mouseOverrideConnection:Disconnect()
        mouseOverrideConnection = nil
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = originalMouseIconEnabled
end

-- ============================================================
-- RAYFIELD WINDOW
-- ============================================================

local Window = Rayfield:CreateWindow({
    Name = "BRM5 Script",
    LoadingTitle = "BRM5 Advanced GUI",
    LoadingSubtitle = "by Rayfield",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "BRM5_Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "BRM5 Key",
        Subtitle = "Key System",
        Note = "No key required",
        FileName = "BRM5Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"BRM5"}
    }
})

-- ============================================================
-- ESP TAB
-- ============================================================

local ESPTab = Window:CreateTab("ESP", nil)
local ESPSection = ESPTab:CreateSection("ESP Settings")

local ESPToggle = ESPTab:CreateToggle({
    Name = "ESP Enabled",
    CurrentValue = true,
    Flag = "ESPEnabled",
    Callback = function(Value)
        ESPEnabled = Value
    end,
})

local DistanceToggle = ESPTab:CreateToggle({
    Name = "Show Distance (Real-time)",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(Value)
        ShowDistance = Value
    end,
})

-- ============================================================
-- COMBAT TAB
-- ============================================================

local CombatTab = Window:CreateTab("Combat", nil)
local CombatSection = CombatTab:CreateSection("Combat Settings")

local function disableFog()
    if FogDisabled then return end
    savedFog.FogEnd = Lighting.FogEnd
    savedFog.FogStart = Lighting.FogStart
    savedFog.FogColor = Lighting.FogColor

    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)

    savedAtmospheres = {}
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") then
            table.insert(savedAtmospheres, v)
            v.Parent = nil
        end
    end

    savedColorCorrections = {}
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("ColorCorrection") then
            table.insert(savedColorCorrections, v)
            v.Parent = nil
        end
    end

    FogDisabled = true
end

local function restoreFog()
    if not FogDisabled then return end
    Lighting.FogEnd = savedFog.FogEnd
    Lighting.FogStart = savedFog.FogStart
    Lighting.FogColor = savedFog.FogColor

    for _, v in ipairs(savedAtmospheres) do
        if v and v.Parent == nil then
            v.Parent = Lighting
        end
    end
    savedAtmospheres = {}

    for _, v in ipairs(savedColorCorrections) do
        if v and v.Parent == nil then
            v.Parent = Lighting
        end
    end
    savedColorCorrections = {}

    FogDisabled = false
end

local FogToggle = CombatTab:CreateToggle({
    Name = "Disable Fog",
    CurrentValue = false,
    Flag = "FogDisabled",
    Callback = function(Value)
        if Value then
            disableFog()
        else
            restoreFog()
        end
    end,
})

-- ============================================================
-- SETTINGS TAB
-- ============================================================

local SettingsTab = Window:CreateTab("Settings", nil)
local SettingsSection = SettingsTab:CreateSection("Script")

local AntiAFKToggle = SettingsTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        AntiAFKEnabled = Value
    end,
})

-- ============================================================
-- CLEANUP / TERMINATION FUNCTION
-- ============================================================

local function terminateScript()
    -- Stop all loops
    scriptRunning = false

    -- 1. Restore environment
    restoreFog()
    lockMouse()

    -- 2. Destroy all ESPs
    for character, espData in pairs(ESPObjects) do
        if espData.Billboard then espData.Billboard:Destroy() end
        if espData.Beam then espData.Beam:Destroy() end
    end
    ESPObjects = {}

    -- 3. Disconnect all tracked events/loops
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}

    if mouseOverrideConnection then
        mouseOverrideConnection:Disconnect()
        mouseOverrideConnection = nil
    end

    -- 4. Destroy Rayfield
    Rayfield:Destroy()
end

local TerminateButton = SettingsTab:CreateButton({
    Name = "Terminate Script",
    Callback = terminateScript,
})

-- ============================================================
-- ANTI-AFK
-- ============================================================

addConnection(player.Idled:Connect(function()
    if not AntiAFKEnabled then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end))

-- ============================================================
-- NPC DETECTION / ESP
-- ============================================================

local function isNPC(model)
    if not model:IsA("Model") then return false end
    if not model:FindFirstChild("Humanoid") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if model.Name == player.Name then return false end
    if not model:FindFirstChild("HumanoidRootPart")
        and not model:FindFirstChild("Torso")
        and not model:FindFirstChild("Head") then
        return false
    end
    return true
end

local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("Head")
end

local function formatDistance(distance)
    if distance >= 1000 then
        return string.format("%.2f km", distance / 1000)
    elseif distance >= 100 then
        return string.format("%.0f m", distance)
    else
        return string.format("%.1f m", distance)
    end
end

local function createESP(character)
    if ESPObjects[character] then return end
    local rootPart = getRootPart(character)
    if not rootPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BRM5_ESP"
    billboard.Size = UDim2.new(0, 80, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = rootPart
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MaxDistance * 10
    billboard.Parent = character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = character.Name
    nameLabel.TextColor3 = ESPColor
    nameLabel.TextSize = 8
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextSize = 7
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Parent = billboard

    local beam = Instance.new("Beam")
    beam.Name = "ESP_Beam"
    beam.Color = ColorSequence.new(ESPColor)
    beam.Transparency = NumberSequence.new(0.7)
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.FaceCamera = true
    beam.Parent = character

    ESPObjects[character] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistanceLabel = distanceLabel,
        Beam = beam,
        RootPart = rootPart,
        LastDistance = -1
    }
end

local function updateESP(character)
    local espData = ESPObjects[character]
    if not espData then return end

    local rootPart = espData.RootPart
    if not rootPart or not rootPart.Parent then
        if espData.Billboard then espData.Billboard:Destroy() end
        if espData.Beam then espData.Beam:Destroy() end
        ESPObjects[character] = nil
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        if espData.Billboard then espData.Billboard:Destroy() end
        if espData.Beam then espData.Beam:Destroy() end
        ESPObjects[character] = nil
        return
    end

    local playerChar = player.Character
    if not playerChar then return end
    local playerRoot = getRootPart(playerChar)
    if not playerRoot then return end

    local distance = (rootPart.Position - playerRoot.Position).Magnitude
    espData.Billboard.Enabled = distance <= MaxDistance and ESPEnabled

    if ShowDistance and espData.Billboard.Enabled then
        local roundedDistance = math.floor(distance * 10) / 10
        if math.abs(roundedDistance - espData.LastDistance) >= 0.1 or espData.LastDistance == -1 then
            espData.DistanceLabel.Text = formatDistance(distance)
            espData.LastDistance = roundedDistance
        end
    end
end

local function scanForNPCs()
    for _, folder in ipairs(NPCFolders) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if isNPC(child) then createESP(child) end
            end
        end
    end
    for _, child in ipairs(workspace:GetChildren()) do
        if isNPC(child) then createESP(child) end
    end
end

addConnection(workspace.DescendantAdded:Connect(function(descendant)
    if not scriptRunning then return end
    if descendant:IsA("Model") and isNPC(descendant) then
        createESP(descendant)
    elseif descendant:IsA("Humanoid") then
        local character = descendant.Parent
        if character and isNPC(character) then
            createESP(character)
        end
    end
end))

scanForNPCs()

-- ============================================================
-- MAIN UPDATE LOOP (real-time ESP + NPC scan)
-- ============================================================

local scanAccumulator = 0

addConnection(RunService.RenderStepped:Connect(function(dt)
    if not scriptRunning then return end

    scanAccumulator = scanAccumulator + dt
    if scanAccumulator >= 0.1 then
        scanAccumulator = 0
        scanForNPCs()
    end

    for character, _ in pairs(ESPObjects) do
        updateESP(character)
    end
end))

-- ============================================================
-- BACKTICK = TOGGLE GUI + MOUSE
-- ============================================================

addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode ~= Enum.KeyCode.Backquote then return end

    guiOpen = not guiOpen

    if guiOpen then
        unlockMouse()
        Rayfield:Toggle(true)
    else
        Rayfield:Toggle(false)
        lockMouse()
    end
end))
