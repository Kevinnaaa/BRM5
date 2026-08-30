-- ============================================
-- BRM5 PvE v1 - KAVO UI VERSION
-- NPC DETECTION + ADVANCED ESP
-- Modern Dark Theme
-- ============================================

-- Load Kavo UI Library
local KavoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kaveen-LK/UI-Libraries/main/Kavo%20UI%20Library.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")

local player = Players.LocalPlayer

-- ============================================
-- STATE
-- ============================================
local ScriptActive = true
local NoFogEnabled = false
local ESPEnabled = false
local SpeedEnabled = true
local InfiniteHungerEnabled = false
local InfiniteThirstEnabled = false
local NPCESPEnabled = false

local PERMANENT_SPEED = 50
local DEFAULT_SPEED = 16
local MAX_HUNGER = 100
local MAX_THIRST = 100
local isInGame = false

-- ESP Configuration
local ESPConfig = {
    MaxDistance = 2000,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    HighlightEnabled = true,
    ShowHealth = true,
    ShowDistance = true,
    NPCMaxDistance = 1500,
    NPCColor = Color3.fromRGB(255, 0, 0),
}

local ESPObjects = {}
local NPCEntities = {}

-- ============================================
-- AGGRESSIVE FOG REMOVAL
-- ============================================
local function RemoveFog()
    pcall(function()
        -- Lighting properties
        Lighting.FogEnd = 999999
        Lighting.FogStart = 999999
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        -- Remove atmosphere
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then atmosphere:Destroy() end
        
        -- Remove blur effects
        local blur = Lighting:FindFirstChildOfClass("BlurEffect")
        if blur then blur:Destroy() end
        
        -- Remove fog scripts
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                local name = string.lower(child.Name)
                if string.find(name, "fog") or string.find(name, "weather") then
                    child:Destroy()
                end
            end
        end
        
        -- Terrain fog
        local terrain = Workspace:FindFirstChild("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end
    end)
end

local function RestoreFog()
    pcall(function()
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end)
end

-- ============================================
-- CHECK IF PLAYER IS IN GAME
-- ============================================
local function checkInGame()
    pcall(function()
        local char = player.Character
        if char and char.Parent == Workspace and char:FindFirstChild("Humanoid") then
            isInGame = true
        else
            isInGame = false
        end
    end)
    return isInGame
end

-- ============================================
-- GET TEAM COLOR
-- ============================================
local function getTeamColor(player)
    if player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(0, 200, 195)
end

-- ============================================
-- DETECT IF ENTITY IS NPC
-- ============================================
local function isNPC(character)
    if not character or not character:IsA("Model") then return false end
    if not character:FindFirstChild("Humanoid") then return false end
    
    local owner = Players:GetPlayerFromCharacter(character)
    if owner then return false end
    
    local npcIndicators = {
        "NPC", "Zombie", "AI", "Enemy", "Bot", "Monster",
        "Walker", "Runner", "Boss", "Spawn", "Creep"
    }
    
    for _, indicator in ipairs(npcIndicators) do
        if string.find(character.Name, indicator) then
            return true
        end
    end
    
    -- Check attributes
    if character:GetAttribute("NPC") or 
       character:GetAttribute("Zombie") or 
       character:GetAttribute("Enemy") then
        return true
    end
    
    return false
end

-- ============================================
-- SPEED SYSTEM
-- ============================================
local function applySpeed()
    if not SpeedEnabled or not isInGame then return end
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

-- ============================================
-- HUNGER / THIRST LOOPS
-- ============================================
local function startHungerLoop()
    task.spawn(function()
        while InfiniteHungerEnabled and ScriptActive do
            if isInGame then
                pcall(function()
                    local char = player.Character
                    if char then
                        for _, child in pairs(char:GetDescendants()) do
                            if child:IsA("NumberValue") or child:IsA("IntValue") then
                                local name = string.lower(child.Name)
                                if string.find(name, "hunger") or string.find(name, "food") then
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

local function startThirstLoop()
    task.spawn(function()
        while InfiniteThirstEnabled and ScriptActive do
            if isInGame then
                pcall(function()
                    local char = player.Character
                    if char then
                        for _, child in pairs(char:GetDescendants()) do
                            if child:IsA("NumberValue") or child:IsA("IntValue") then
                                local name = string.lower(child.Name)
                                if string.find(name, "thirst") or string.find(name, "water") then
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

-- ============================================
-- ESP FUNCTIONS
-- ============================================
local function createNPCESP(character)
    if not character or character:GetName() == "" then return end
    if Players:GetPlayerFromCharacter(character) then return end
    if not isNPC(character) then return end
    
    local npcKey = tostring(character)
    
    if ESPObjects[npcKey] then
        pcall(function()
            if ESPObjects[npcKey].Billboard then ESPObjects[npcKey].Billboard:Destroy() end
            if ESPObjects[npcKey].Highlight then ESPObjects[npcKey].Highlight:Destroy() end
        end)
        ESPObjects[npcKey] = nil
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart then return end
    
    local npcColor = ESPConfig.NPCColor
    
    local highlight = nil
    if ESPConfig.HighlightEnabled then
        highlight = Instance.new("Highlight")
        highlight.FillColor = npcColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.35
        highlight.OutlineTransparency = 0
        highlight.Enabled = ESPEnabled and NPCESPEnabled
        highlight.Parent = character
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head or rootPart
    billboard.Size = UDim2.new(0, 200, 0, 80)
    billboard.StudsOffset = head and Vector3.new(0, 3, 0) or Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ESPEnabled and NPCESPEnabled
    billboard.Parent = character
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.ResetOnSpawn = false
    
    local mainContainer = Instance.new("Frame", billboard)
    mainContainer.Size = UDim2.new(1, 0, 1, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.BorderSizePixel = 0
    
    local nameLabel = Instance.new("TextLabel", mainContainer)
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🧟 " .. character.Name
    nameLabel.TextColor3 = npcColor
    nameLabel.TextSize = ESPConfig.TextSize
    nameLabel.Font = ESPConfig.Font
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local healthBarBg = Instance.new("Frame", mainContainer)
    healthBarBg.Size = UDim2.new(0.9, 0, 0, 12)
    healthBarBg.Position = UDim2.new(0.05, 0, 0, 18)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBarBg.BorderSizePixel = 1
    healthBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    local healthBgCorner = Instance.new("UICorner", healthBarBg)
    healthBgCorner.CornerRadius = UDim.new(0, 2)
    
    local healthBarFill = Instance.new("Frame", healthBarBg)
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBarFill.BorderSizePixel = 0
    local healthFillCorner = Instance.new("UICorner", healthBarFill)
    healthFillCorner.CornerRadius = UDim.new(0, 2)
    
    local healthLabel = Instance.new("TextLabel", mainContainer)
    healthLabel.Size = UDim2.new(1, 0, 0, 12)
    healthLabel.Position = UDim2.new(0, 0, 0, 20)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "HP: 100/100"
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 10
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Visible = ESPConfig.ShowHealth
    
    local distanceLabel = Instance.new("TextLabel", mainContainer)
    distanceLabel.Size = UDim2.new(1, 0, 0, 14)
    distanceLabel.Position = UDim2.new(0, 0, 0, 62)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance: 0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    distanceLabel.TextSize = 11
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Visible = ESPConfig.ShowDistance
    
    local typeLabel = Instance.new("TextLabel", mainContainer)
    typeLabel.Size = UDim2.new(1, 0, 0, 12)
    typeLabel.Position = UDim2.new(0, 0, 0, 48)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = "NPC"
    typeLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    typeLabel.TextSize = 10
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.TextXAlignment = Enum.TextXAlignment.Center
    typeLabel.TextStrokeTransparency = 0.5
    typeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    ESPObjects[npcKey] = {
        Billboard = billboard,
        Highlight = highlight,
        HealthBarFill = healthBarFill,
        HealthLabel = healthLabel,
        DistanceLabel = distanceLabel,
        Humanoid = humanoid,
        RootPart = rootPart,
        Character = character,
        IsNPC = true
    }
    
    NPCEntities[npcKey] = character
end

local function createPlayerESP(player)
    if player == Players.LocalPlayer then return end
    
    if ESPObjects[player.Name] then
        pcall(function()
            if ESPObjects[player.Name].Billboard then ESPObjects[player.Name].Billboard:Destroy() end
            if ESPObjects[player.Name].Highlight then ESPObjects[player.Name].Highlight:Destroy() end
        end)
        ESPObjects[player.Name] = nil
    end
    
    local function addESP(character)
        if not character or not isInGame then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not rootPart or not head then return end
        
        local teamColor = getTeamColor(player)
        
        local highlight = nil
        if ESPConfig.HighlightEnabled then
            highlight = Instance.new("Highlight")
            highlight.FillColor = teamColor
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Enabled = ESPEnabled
            highlight.Parent = character
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = ESPEnabled
        billboard.Parent = character
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        billboard.ResetOnSpawn = false
        
        local mainContainer = Instance.new("Frame", billboard)
        mainContainer.Size = UDim2.new(1, 0, 1, 0)
        mainContainer.BackgroundTransparency = 1
        mainContainer.BorderSizePixel = 0
        
        local nameLabel = Instance.new("TextLabel", mainContainer)
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "👤 " .. player.Name
        nameLabel.TextColor3 = teamColor
        nameLabel.TextSize = ESPConfig.TextSize
        nameLabel.Font = ESPConfig.Font
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local healthBarBg = Instance.new("Frame", mainContainer)
        healthBarBg.Size = UDim2.new(0.9, 0, 0, 12)
        healthBarBg.Position = UDim2.new(0.05, 0, 0, 18)
        healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBarBg.BorderSizePixel = 1
        healthBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        local healthBgCorner = Instance.new("UICorner", healthBarBg)
        healthBgCorner.CornerRadius = UDim.new(0, 2)
        
        local healthBarFill = Instance.new("Frame", healthBarBg)
        healthBarFill.Size = UDim2.new(1, 0, 1, 0)
        healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBarFill.BorderSizePixel = 0
        local healthFillCorner = Instance.new("UICorner", healthBarFill)
        healthFillCorner.CornerRadius = UDim.new(0, 2)
        
        local healthLabel = Instance.new("TextLabel", mainContainer)
        healthLabel.Size = UDim2.new(1, 0, 0, 12)
        healthLabel.Position = UDim2.new(0, 0, 0, 20)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "HP: 100/100"
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextSize = 10
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextXAlignment = Enum.TextXAlignment.Center
        healthLabel.TextStrokeTransparency = 0.5
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.Visible = ESPConfig.ShowHealth
        
        local distanceLabel = Instance.new("TextLabel", mainContainer)
        distanceLabel.Size = UDim2.new(1, 0, 0, 14)
        distanceLabel.Position = UDim2.new(0, 0, 0, 62)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "Distance: 0m"
        distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        distanceLabel.TextSize = 11
        distanceLabel.Font = Enum.Font.GothamBold
        distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distanceLabel.Visible = ESPConfig.ShowDistance
        
        ESPObjects[player.Name] = {
            Billboard = billboard,
            Highlight = highlight,
            HealthBarFill = healthBarFill,
            HealthLabel = healthLabel,
            DistanceLabel = distanceLabel,
            Humanoid = humanoid,
            RootPart = rootPart,
            Character = character,
            IsNPC = false
        }
    end
    
    if player.Character then
        addESP(player.Character)
    end
    
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if isInGame then
            addESP(character)
        end
    end)
end

local function scanForNPCs()
    if not isInGame or not (ESPEnabled and NPCESPEnabled) then
        for key, espData in pairs(ESPObjects) do
            if espData.IsNPC then
                if espData.Billboard then espData.Billboard:Destroy() end
                if espData.Highlight then espData.Highlight:Destroy() end
                ESPObjects[key] = nil
                NPCEntities[key] = nil
            end
        end
        return
    end
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local player = Players:GetPlayerFromCharacter(obj)
            if not player and isNPC(obj) then
                local key = tostring(obj)
                if not ESPObjects[key] then
                    createNPCESP(obj)
                end
            end
        end
    end
    
    for key, npc in pairs(NPCEntities) do
        if not npc or not npc.Parent then
            if ESPObjects[key] then
                if ESPObjects[key].Billboard then ESPObjects[key].Billboard:Destroy() end
                if ESPObjects[key].Highlight then ESPObjects[key].Highlight:Destroy() end
                ESPObjects[key] = nil
            end
            NPCEntities[key] = nil
        end
    end
end

local function updateESP()
    if not isInGame or not ESPEnabled then
        for _, espData in pairs(ESPObjects) do
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
        end
        return
    end
    
    local localChar = Players.LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for key, espData in pairs(ESPObjects) do
        if not espData or not espData.Character then continue end
        
        local character = espData.Character
        if not character or character.Parent ~= Workspace then
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
            continue
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")
        
        if not rootPart or not humanoid then
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
            continue
        end
        
        local dist = (localRoot.Position - rootPart.Position).Magnitude
        local maxDist = espData.IsNPC and ESPConfig.NPCMaxDistance or ESPConfig.MaxDistance
        local isInRange = dist <= maxDist
        
        local showESP = isInRange and (espData.IsNPC and NPCESPEnabled or true)
        
        if showESP then
            if espData.Highlight then
                espData.Highlight.Enabled = true
                espData.Highlight.Parent = character
            end
            if espData.Billboard then
                espData.Billboard.Enabled = true
                espData.Billboard.Adornee = head or rootPart
            end
            
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            if espData.HealthBarFill then
                espData.HealthBarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                if healthPercent > 0.5 then
                    espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.25 then
                    espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    espData.HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            if espData.HealthLabel then
                espData.HealthLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            end
            
            if espData.DistanceLabel then
                local distance = math.floor(dist)
                espData.DistanceLabel.Text = "Distance: " .. distance .. "m"
                if distance < 50 then
                    espData.DistanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif distance < 150 then
                    espData.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    espData.DistanceLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
            
            if not espData.IsNPC then
                local player = Players:GetPlayerFromCharacter(character)
                if player then
                    local teamColor = getTeamColor(player)
                    if espData.Highlight then
                        espData.Highlight.FillColor = teamColor
                    end
                    if espData.NameLabel then
                        espData.NameLabel.TextColor3 = teamColor
                    end
                end
            end
        else
            if espData.Highlight then espData.Highlight.Enabled = false end
            if espData.Billboard then espData.Billboard.Enabled = false end
        end
    end
end

-- ============================================
-- CREATE KAVO UI
-- ============================================
local Window = KavoUI:CreateWindow({
    Name = "BRM5 PvE v1",
    Icon = "🏹",
    LoadingTitle = "Loading BRM5 PvE...",
    LoadingSubtitle = "by Maryyy",
    Theme = KavoUI.Themes.Dark,
    Configuration = {
        {
            Name = "Speed Tab",
            Callback = function()
                -- Auto-select speed tab
            end
        }
    }
})

-- ============================================
-- SPEED TAB
-- ============================================
local SpeedTab = Window:CreateTab({
    Name = "Speed",
    Icon = "🏃"
})

local SpeedSection = SpeedTab:CreateSection({
    Name = "Speed Settings"
})

SpeedSection:CreateToggle({
    Name = "⚡ Speed Boost",
    CurrentValue = true,
    Callback = function(Value)
        SpeedEnabled = Value
        if not Value then
            pcall(function()
                if player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then humanoid.WalkSpeed = DEFAULT_SPEED end
                end
            end)
        end
    end
})

SpeedSection:CreateLabel({
    Name = "Speed: " .. PERMANENT_SPEED .. " (Always On)"
})

SpeedSection:CreateLabel({
    Name = "Default: " .. DEFAULT_SPEED
})

SpeedSection:CreateLabel({
    Name = "✅ Auto-applies on respawn"
})

-- ============================================
-- SURVIVAL TAB
-- ============================================
local SurvivalTab = Window:CreateTab({
    Name = "Survival",
    Icon = "🍖"
})

local SurvivalSection = SurvivalTab:CreateSection({
    Name = "Hunger & Thirst"
})

SurvivalSection:CreateToggle({
    Name = "🍖 Infinite Hunger",
    CurrentValue = false,
    Callback = function(Value)
        InfiniteHungerEnabled = Value
        if Value then startHungerLoop() end
    end
})

SurvivalSection:CreateLabel({
    Name = "Keeps hunger at maximum (" .. MAX_HUNGER .. ")"
})

SurvivalSection:CreateToggle({
    Name = "💧 Infinite Thirst",
    CurrentValue = false,
    Callback = function(Value)
        InfiniteThirstEnabled = Value
        if Value then startThirstLoop() end
    end
})

SurvivalSection:CreateLabel({
    Name = "Keeps thirst at maximum (" .. MAX_THIRST .. ")"
})

-- ============================================
-- VISUALS TAB
-- ============================================
local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "👁️"
})

local VisualsSection = VisualsTab:CreateSection({
    Name = "ESP Settings"
})

VisualsSection:CreateToggle({
    Name = "👤 Player ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if isInGame then
            for _, espData in pairs(ESPObjects) do
                if not espData.IsNPC then
                    if espData.Highlight then espData.Highlight.Enabled = Value end
                    if espData.Billboard then espData.Billboard.Enabled = Value end
                end
            end
        end
    end
})

VisualsSection:CreateToggle({
    Name = "🧟 NPC/Zombie ESP",
    CurrentValue = false,
    Callback = function(Value)
        NPCESPEnabled = Value
        if Value and isInGame then
            scanForNPCs()
        else
            for key, espData in pairs(ESPObjects) do
                if espData.IsNPC then
                    if espData.Billboard then espData.Billboard:Destroy() end
                    if espData.Highlight then espData.Highlight:Destroy() end
                    ESPObjects[key] = nil
                    NPCEntities[key] = nil
                end
            end
        end
    end
})

VisualsSection:CreateLabel({
    Name = "🟢 Green = Close (<50 studs)"
})

VisualsSection:CreateLabel({
    Name = "🟡 Yellow = Medium (<150 studs)"
})

VisualsSection:CreateLabel({
    Name = "🔴 Red = Far (>150 studs)"
})

local EnvironmentSection = VisualsTab:CreateSection({
    Name = "Environment"
})

EnvironmentSection:CreateToggle({
    Name = "🌫️ Remove Fog",
    CurrentValue = false,
    Callback = function(Value)
        NoFogEnabled = Value
        if Value then
            RemoveFog()
            task.spawn(function()
                while NoFogEnabled and ScriptActive do
                    RemoveFog()
                    task.wait(0.5)
                end
            end)
        else
            RestoreFog()
        end
    end
})

EnvironmentSection:CreateLabel({
    Name = "Removes ALL fog from the game"
})

EnvironmentSection:CreateLabel({
    Name = "Also increases brightness"
})

-- ============================================
-- SETTINGS TAB
-- ============================================
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙️"
})

local InfoSection = SettingsTab:CreateSection({
    Name = "Info"
})

InfoSection:CreateLabel({
    Name = "👤 Player: " .. player.Name
})

InfoSection:CreateLabel({
    Name = "Features: Speed + ESP + No Fog"
})

InfoSection:CreateLabel({
    Name = "NPC Detection: Auto-finds zombies"
})

local ControlSection = SettingsTab:CreateSection({
    Name = "Controls"
})

ControlSection:CreateButton({
    Name = "⚠️ Terminate Script",
    Callback = function()
        ScriptActive = false
        pcall(function()
            -- Clean up ESP
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") then
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("Highlight") or child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end
            -- Reset speed
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then humanoid.WalkSpeed = DEFAULT_SPEED end
            end
            -- Reset fog
            RestoreFog()
        end)
        KavoUI:Destroy()
        print("✅ Script terminated.")
    end
})

ControlSection:CreateButton({
    Name = "📋 Copy Player Info",
    Callback = function()
        setclipboard("Player: " .. player.Name .. " | ID: " .. player.UserId)
    end
})

-- ============================================
-- PLAYER TRACKING
-- ============================================
local function trackPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local key = tostring(char)
                if not ESPObjects[key] and not isNPC(char) then
                    createPlayerESP(plr)
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if char and not isNPC(char) then
                createPlayerESP(plr)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    for key, espData in pairs(ESPObjects) do
        if espData.Character and espData.Character:FindFirstChild("Humanoid") then
            local owner = Players:GetPlayerFromCharacter(espData.Character)
            if owner == plr then
                if espData.Highlight then espData.Highlight:Destroy() end
                if espData.Billboard then espData.Billboard:Destroy() end
                ESPObjects[key] = nil
            end
        end
    end
end)

-- ============================================
-- MAIN LOOPS
-- ============================================
-- Game state check
task.spawn(function()
    while ScriptActive do
        checkInGame()
        task.wait(1)
    end
end)

-- Speed loop
task.spawn(function()
    while ScriptActive do
        if isInGame and SpeedEnabled then
            applySpeed()
        end
        task.wait(0.3)
    end
end)

-- NPC scan loop
task.spawn(function()
    while ScriptActive do
        if NPCESPEnabled and isInGame then
            scanForNPCs()
        end
        task.wait(2)
    end
end)

-- ESP update loop
task.spawn(function()
    while ScriptActive do
        if ESPEnabled and isInGame then
            updateESP()
        end
        task.wait(0.15)
    end
end)

-- Player tracking loop
task.spawn(function()
    while ScriptActive do
        if isInGame then
            trackPlayers()
        end
        task.wait(3)
    end
end)

-- Character added
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    isInGame = true
    applySpeed()
    trackPlayers()
    if NoFogEnabled then RemoveFog() end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
task.wait(1)
checkInGame()
applySpeed()
trackPlayers()

print("✅ BRM5 PvE v1 Loaded! (Kavo UI)")
print("   Speed: " .. PERMANENT_SPEED)
print("   🧟 Survival: Infinite Hunger & Thirst")
print("   👁️ Visuals: Player ESP + NPC ESP")
print("   🌫️ No Fog: Aggressive removal")
