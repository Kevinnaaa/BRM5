-- BRM5 Rayfield GUI Script
-- Optimized ESP version (Fixed)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration
local ESPEnabled = true
local ShowDistance = true
local MaxDistance = 200 
local ESPColor = Color3.fromRGB(255, 50, 50)
local scriptRunning = true
local AntiAFKEnabled = true

-- Fog state
local FogDisabled = false
local savedFog = { FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor }
local savedAtmospheres = {}
local savedColorCorrections = {}

-- Mouse / GUI state
local guiOpen = false
local originalMouseIconEnabled = UserInputService.MouseIconEnabled
local mouseOverrideConnection = nil
local connections = {}

local function addConnection(conn) table.insert(connections, conn) end

local NPCFolders = {
    workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Hostiles"),
    workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("EnemyNPCs"),
    workspace:FindFirstChild("Soldiers"), workspace:FindFirstChild("Guards"),
    workspace:FindFirstChild("AI"), workspace:FindFirstChild("AIs"),
    workspace:FindFirstChild("Mission"), workspace:FindFirstChild("Missions"),
}

local ESPObjects = {}
local lastESPUpdate = 0 -- Fixed: Kept separate from the table

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
    LoadingSubtitle = "Optimized ESP",
    ConfigurationSaving = { Enabled = true, FileName = "BRM5_Config" },
    Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
    KeySystem = false
})

local ESPTab = Window:CreateTab("ESP", nil)
local ESPSection = ESPTab:CreateSection("ESP Settings")

ESPTab:CreateToggle({
    Name = "ESP Enabled", CurrentValue = true, Flag = "ESPEnabled",
    Callback = function(Value) ESPEnabled = Value end,
})

ESPTab:CreateToggle({
    Name = "Show Distance", CurrentValue = true, Flag = "ShowDistance",
    Callback = function(Value) ShowDistance = Value end,
})

-- ============================================================
-- COMBAT / SETTINGS TABS
-- ============================================================

local CombatTab = Window:CreateTab("Combat", nil)
local SettingsTab = Window:CreateTab("Settings", nil)

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
        if v:IsA("Atmosphere") then table.insert(savedAtmospheres, v); v.Parent = nil end
    end
    savedColorCorrections = {}
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("ColorCorrection") then table.insert(savedColorCorrections, v); v.Parent = nil end
    end
    FogDisabled = true
end

local function restoreFog()
    if not FogDisabled then return end
    Lighting.FogEnd = savedFog.FogEnd
    Lighting.FogStart = savedFog.FogStart
    Lighting.FogColor = savedFog.FogColor

    for _, v in ipairs(savedAtmospheres) do if v and v.Parent == nil then v.Parent = Lighting end end
    savedAtmospheres = {}
    for _, v in ipairs(savedColorCorrections) do if v and v.Parent == nil then v.Parent = Lighting end end
    savedColorCorrections = {}
    FogDisabled = false
end

CombatTab:CreateToggle({
    Name = "Disable Fog", CurrentValue = false, Flag = "FogDisabled",
    Callback = function(Value) if Value then disableFog() else restoreFog() end end,
})

SettingsTab:CreateToggle({
    Name = "Anti-AFK", CurrentValue = true, Flag = "AntiAFK",
    Callback = function(Value) AntiAFKEnabled = Value end,
})

-- ============================================================
-- CLEANUP
-- ============================================================

local function terminateScript()
    scriptRunning = false
    restoreFog()
    lockMouse()

    for _, espData in pairs(ESPObjects) do
        if espData.Billboard then espData.Billboard:Destroy() end
        if espData.Beam then espData.Beam:Destroy() end
        if espData.DiedConnection then espData.DiedConnection:Disconnect() end
    end
    ESPObjects = {}

    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
    connections = {}

    if mouseOverrideConnection then
        mouseOverrideConnection:Disconnect()
        mouseOverrideConnection = nil
    end
    Rayfield:Destroy()
end

SettingsTab:CreateButton({ Name = "Terminate Script", Callback = terminateScript })

-- ============================================================
-- ANTI-AFK
-- ============================================================
addConnection(player.Idled:Connect(function()
    if not AntiAFKEnabled then return end
    pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
end))

-- ============================================================
-- NPC DETECTION & ESP
-- ============================================================

local function isNPC(model)
    if not model:IsA("Model") then return false end
    if not model:FindFirstChild("Humanoid") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if model.Name == player.Name then return false end
    local lowerName = string.lower(model.Name)
    if string.find(lowerName, "dead") or string.find(lowerName, "corpse") or string.find(lowerName, "ragdoll") then return false end
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
end

local function getRootPart(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("Head")
end

local function formatDistance(distance)
    if distance >= 1000 then return string.format("%.2f km", distance / 1000)
    elseif distance >= 100 then return string.format("%.0f m", distance)
    else return string.format("%.1f m", distance) end
end

local function removeESP(character)
    local espData = ESPObjects[character]
    if not espData then return end
    if espData.Billboard then espData.Billboard:Destroy() end
    if espData.Beam then espData.Beam:Destroy() end
    if espData.DiedConnection then espData.DiedConnection:Disconnect() end
    ESPObjects[character] = nil
end

local function createESP(character)
    if ESPObjects[character] then return end
    local rootPart = getRootPart(character)
    if not rootPart then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end 

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BRM5_ESP"
    billboard.Size = UDim2.new(0, 80, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = rootPart
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MaxDistance * 2 
    billboard.Enabled = false -- Wait for distance loop
    billboard.Parent = character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = character.Name
    nameLabel.TextColor3 = ESPColor
    nameLabel.TextSize = 9
    nameLabel.Font = Enum.Font.SourceSans 
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextSize = 8
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

    local diedConnection = humanoid.Died:Connect(function() removeESP(character) end)

    ESPObjects[character] = {
        Billboard = billboard,
        DistanceLabel = distanceLabel,
        Beam = beam,
        RootPart = rootPart,
        Humanoid = humanoid,
        DiedConnection = diedConnection,
        LastDistance = -1
    }
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
    end
end))

scanForNPCs()

-- ============================================================
-- OPTIMIZED ESP UPDATE LOOP (Runs 10x per second)
-- ============================================================

local scanAccumulator = 0

addConnection(RunService.Heartbeat:Connect(function(dt)
    if not scriptRunning then return end

    scanAccumulator = scanAccumulator + dt
    if scanAccumulator >= 1 then
        scanAccumulator = 0
        scanForNPCs()
    end

    if not ESPEnabled then return end

    -- Get player position ONCE
    local playerChar = player.Character
    if not playerChar then return end
    local playerRoot = getRootPart(playerChar)
    if not playerRoot then return end
    local pPos = playerRoot.Position

    -- Throttle to ~10 updates per second
    local currentTime = tick()
    if currentTime - lastESPUpdate < 0.1 then return end
    lastESPUpdate = currentTime

    for character, espData in pairs(ESPObjects) do
        local rootPart = espData.RootPart
        local humanoid = espData.Humanoid
        
        -- Safe check (in case model is being destroyed)
        if not rootPart or not rootPart.Parent or not humanoid or humanoid.Health <= 0 then
            removeESP(character)
        else
            local distance = (rootPart.Position - pPos).Magnitude
            
            if distance <= MaxDistance then
                espData.Billboard.Enabled = true
                
                if ShowDistance then
                    local roundedDist = math.floor(distance)
                    if roundedDist ~= espData.LastDistance then
                        espData.DistanceLabel.Text = formatDistance(distance)
                        espData.LastDistance = roundedDist
                    end
                end
            else
                espData.Billboard.Enabled = false
            end
        end
    end
end))

-- ============================================================
-- BACKTICK = TOGGLE GUI + MOUSE
-- ============================================================

addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode ~= Enum.KeyCode.Backquote then return end
    guiOpen = not guiOpen

    if guiOpen then
        Rayfield:Toggle(true)
        task.wait()
        unlockMouse()
    else
        Rayfield:Toggle(false)
        lockMouse()
    end
end))
