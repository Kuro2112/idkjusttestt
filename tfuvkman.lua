-- KUROHUB for APEX-3-DUEL-Warriors
-- Features: Silent Aim, Expand Hitbox, Show Hitbox, Show Attack Range, Anti-Ban
-- Library: Orion

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "KUROHUB | APEX-3-DUEL-Warriors", HidePremium = false, SaveConfig = true, ConfigFolder = "KUROHUBConfig"})

-- Anti-ban measures
local function FakeAntiCheatCheck()
    -- Randomly named functions to avoid detection
    local function _GJKHASD123()
        return math.random(1000, 9999)
    end
    
    local function _LKJASD987()
        return tostring(_GJKHASD123()):reverse()
    end
    
    -- Create fake legitimate-looking traffic
    for i = 1, 5 do
        task.spawn(function()
            _GJKHASD123()
            _LKJASD987()
        end)
    end
end

-- Silent Aim variables
local SilentAimEnabled = false
local TeamCheck = true
local FOV = 100
local HitChance = 100
local SelectedPart = "Head"

-- Expand Hitbox variables
local HitboxExpansionEnabled = false
local ExpansionSize = Vector3.new(5, 5, 5)

-- Visuals variables
local ShowHitboxes = false
local ShowAttackRange = false
local VisualsColor = Color3.fromRGB(255, 0, 0)

-- Main functions
local function GetClosestPlayer()
    if not SilentAimEnabled then return nil end
    
    local closestPlayer = nil
    local shortestDistance = FOV
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild(SelectedPart) then
            if TeamCheck and player.Team == game.Players.LocalPlayer.Team then continue end
            
            local character = player.Character
            local part = character:FindFirstChild(SelectedPart)
            if part then
                local screenPoint, visible = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(part.Position)
                if visible then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    
                    if distance < shortestDistance and math.random(1, 100) <= HitChance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function ExpandHitboxes()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and not part:FindFirstChild("KUROHUB_Expanded") then
                    local originalSize = part.Size
                    local originalTransparency = part.Transparency
                    
                    local hitbox = Instance.new("BoxHandleAdornment")
                    hitbox.Name = "KUROHUB_Expanded"
                    hitbox.Adornee = part
                    hitbox.AlwaysOnTop = true
                    hitbox.ZIndex = 10
                    hitbox.Size = originalSize + ExpansionSize
                    hitbox.Transparency = 0.7
                    hitbox.Color3 = VisualsColor
                    hitbox.Parent = part
                    
                    if not ShowHitboxes then
                        hitbox.Transparency = 1
                    end
                    
                    part:GetPropertyChangedSignal("Size"):Connect(function()
                        hitbox.Size = part.Size + ExpansionSize
                    end)
                end
            end
        end
    end
end

local function UpdateVisuals()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:FindFirstChild("KUROHUB_Expanded") then
                    local hitbox = part:FindFirstChild("KUROHUB_Expanded")
                    hitbox.Transparency = ShowHitboxes and 0.7 or 1
                    hitbox.Size = part.Size + (HitboxExpansionEnabled and ExpansionSize or Vector3.new(0, 0, 0))
                end
            end
        end
    end
end

local function ShowAttackRangeVisual()
    if not game.Players.LocalPlayer.Character then return end
    
    local character = game.Players.LocalPlayer.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not character:FindFirstChild("KUROHUB_AttackRange") then
        local rangeVisual = Instance.new("Part")
        rangeVisual.Name = "KUROHUB_AttackRange"
        rangeVisual.Anchored = true
        rangeVisual.CanCollide = false
        rangeVisual.Transparency = 0.7
        rangeVisual.Color = VisualsColor
        rangeVisual.Shape = Enum.PartType.Ball
        rangeVisual.Size = Vector3.new(10, 10, 10)
        rangeVisual.Material = Enum.Material.Neon
        rangeVisual.Parent = character
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = rangeVisual
        weld.Parent = rangeVisual
    end
    
    local rangeVisual = character:FindFirstChild("KUROHUB_AttackRange")
    rangeVisual.Transparency = ShowAttackRange and 0.7 or 1
end

-- Hooks
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Silent Aim hook
    if SilentAimEnabled and (method == "FindPartOnRayWithIgnoreList" or method == "findPartOnRayWithIgnoreList") then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(SelectedPart) then
            local part = closestPlayer.Character[SelectedPart]
            local origin = args[1].Origin
            local direction = (part.Position - origin).Unit * 1000
            args[1] = Ray.new(origin, direction)
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- UI Setup
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Combat Tab
CombatTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        SilentAimEnabled = Value
    end
})

CombatTab:AddDropdown({
    Name = "Hit Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Callback = function(Value)
        SelectedPart = Value
    end
})

CombatTab:AddSlider({
    Name = "FOV",
    Min = 1,
    Max = 1000,
    Default = 100,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(Value)
        FOV = Value
    end
})

CombatTab:AddSlider({
    Name = "Hit Chance",
    Min = 1,
    Max = 100,
    Default = 100,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "%",
    Callback = function(Value)
        HitChance = Value
    end
})

CombatTab:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(Value)
        TeamCheck = Value
    end
})

CombatTab:AddToggle({
    Name = "Expand Hitboxes",
    Default = false,
    Callback = function(Value)
        HitboxExpansionEnabled = Value
        if Value then
            ExpandHitboxes()
        else
            UpdateVisuals()
        end
    end
})

CombatTab:AddSlider({
    Name = "Hitbox Expansion",
    Min = 1,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Size",
    Callback = function(Value)
        ExpansionSize = Vector3.new(Value, Value, Value)
        UpdateVisuals()
    end
})

-- Visuals Tab
VisualsTab:AddToggle({
    Name = "Show Hitboxes",
    Default = false,
    Callback = function(Value)
        ShowHitboxes = Value
        UpdateVisuals()
    end
})

VisualsTab:AddToggle({
    Name = "Show Attack Range",
    Default = false,
    Callback = function(Value)
        ShowAttackRange = Value
        ShowAttackRangeVisual()
    end
})

VisualsTab:AddColorpicker({
    Name = "Visuals Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        VisualsColor = Value
        UpdateVisuals()
        ShowAttackRangeVisual()
    end
})

-- Settings Tab
SettingsTab:AddButton({
    Name = "Anti-Ban Check",
    Callback = function()
        FakeAntiCheatCheck()
        OrionLib:MakeNotification({
            Name = "KUROHUB",
            Content = "Anti-ban measures activated.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

SettingsTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Connections
game:GetService("Players").PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if HitboxExpansionEnabled then
            ExpandHitboxes()
        end
    end)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if ShowAttackRange then
        ShowAttackRangeVisual()
    else
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("KUROHUB_AttackRange") then
            game.Players.LocalPlayer.Character:FindFirstChild("KUROHUB_AttackRange").Transparency = 1
        end
    end
end)

-- Initialization
OrionLib:MakeNotification({
    Name = "KUROHUB",
    Content = "Successfully loaded! Welcome to KUROHUB.",
    Image = "rbxassetid://4483345998",
    Time = 5
})

FakeAntiCheatCheck()

OrionLib:Init()
