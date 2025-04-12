-- KUROHUB v1.6 (Optimized for APEX-3-DUEL-Warriors)
-- Features: Silent Aim (Team Filter, Prediction), Dynamic Hitbox (Custom Colors), Weapon-Specific Range, Anti-Ban (Placebo), FOV Circle
-- GUI: Black/Red Theme with Collapsible Settings, Status Bar, Hotkeys

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Game-Specific Constants
local GAME_NAME = "APEX-3-DUEL-Warriors"
local HITBOX_PARTS = {"Head", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
local WEAPON_RANGES = {
    Sword = 10,
    Spear = 14,
    Bow = 25
}
local HITBOX_COLORS = {
    Red = Color3.new(1, 0, 0),
    Blue = Color3.new(0, 0, 1),
    Purple = Color3.new(0.5, 0, 1)
}
local DEFAULT_AIM_RADIUS = 60
local DEFAULT_HITBOX_SIZE = 1.4
local DEFAULT_SMOOTHNESS = 0.1

-- GUI Setup
local KUROHUB = Instance.new("ScreenGui")
KUROHUB.Name = "KUROHUB_" .. HttpService:GenerateGUID(false)
KUROHUB.Parent = game.CoreGui
KUROHUB.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = KUROHUB
MainFrame.BackgroundColor3 = Color3.new(0.1, 0, 0)
MainFrame.BackgroundTransparency = 0.5
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 400)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.new(0.2, 0, 0))
}
UIGradient.Transparency = NumberSequence.new(0.2)
UIGradient.Parent = MainFrame

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
SettingsFrame.Position = UDim2.new(0, 0, 0, 40)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.ClipsDescendants = true
SettingsFrame.Parent = MainFrame

local StatusBar = Instance.new("TextLabel")
StatusBar.Text = "KUROHUB v1.6 | FPS: -- | Targets: 0"
StatusBar.TextColor3 = Color3.new(1, 1, 1)
StatusBar.BackgroundTransparency = 0.7
StatusBar.BackgroundColor3 = Color3.new(0, 0, 0)
StatusBar.Size = UDim2.new(1, 0, 0, 30)
StatusBar.Position = UDim2.new(0, 0, 1, -30)
StatusBar.TextScaled = true
StatusBar.Parent = MainFrame

-- Settings
local Settings = {
    SilentAim = false,
    ShowFOV = false,
    ExpandHitbox = false,
    ShowHitbox = false,
    ShowAttackRange = false,
    AntiBan = false,
    TeamFilter = true,
    AimKey = Enum.KeyCode.Q,
    AimRadius = DEFAULT_AIM_RADIUS,
    HitboxSize = DEFAULT_HITBOX_SIZE,
    AimSmoothness = DEFAULT_SMOOTHNESS,
    WeaponMode = "Sword",
    AttackRange = WEAPON_RANGES.Sword,
    HitboxColor = "Red",
    DynamicHitbox = true,
    AntiBanLevel = "Warrior Elite",
    FakeBanRisk = 0 -- Placebo risk meter
}

-- FOV Circle
local FOVCircle = Instance.new("Part")
FOVCircle.Shape = Enum.PartType.Ball
FOVCircle.Size = Vector3.new(0.1, 0.1, 0.1)
FOVCircle.Anchored = true
FOVCircle.CanCollide = false
FOVCircle.Transparency = 1
FOVCircle.Parent = workspace

local FOVSurface = Instance.new("SurfaceGui")
FOVSurface.Adornee = FOVCircle
FOVSurface.Face = Enum.NormalId.Front
FOVSurface.Parent = FOVCircle

local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(0, Settings.AimRadius * 2, 0, Settings.AimRadius * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Parent = FOVSurface

local FOVImage = Instance.new("ImageLabel")
FOVImage.Size = UDim2.new(1, 0, 1, 0)
FOVImage.BackgroundTransparency = 1
FOVImage.Image = "rbxassetid://0" -- Replace with red circle asset
FOVImage.ImageColor3 = Color3.new(1, 0, 0)
FOVImage.ImageTransparency = 0.7
FOVImage.Parent = FOVFrame

-- Anti-Ban Simulation (Placebo)
local AntiBanModule = {
    Active = false,
    FakeTelemetry = {},
    Log = function(message)
        warn("[KUROHUB Anti-Ban | " .. GAME_NAME .. "]: " .. message)
    end,
    SimulateProtection = function()
        if not Settings.AntiBan then return end
        AntiBanModule.Active = true
        AntiBanModule.Log("Initializing Anti-Ban v2.3 for " .. GAME_NAME)
        AntiBanModule.FakeTelemetry = {
            SessionID = HttpService:GenerateGUID(false),
            Timestamp = os.time(),
            FakeChecksum = math.random(1000000, 9999999),
            FakeWarriorKey = "WRLR-ELITE-" .. math.random(10000, 99999),
            FakePing = math.random(15, 90),
            FakeServerLoad = math.random(10, 50)
        }
        AntiBanModule.Log("Elite Session ID: " .. AntiBanModule.FakeTelemetry.SessionID)
        AntiBanModule.Log("Protection Level: " .. Settings.AntiBanLevel)
        AntiBanModule.Log("Server ping: " .. AntiBanModule.FakeTelemetry.FakePing .. "ms | Load: " .. AntiBanModule.FakeTelemetry.FakeServerLoad .. "%")
        wait(0.5)
        AntiBanModule.Log("Checksum validated: " .. AntiBanModule.FakeTelemetry.FakeChecksum)
        AntiBanModule.Log("Warrior Key: " .. AntiBanModule.FakeTelemetry.FakeWarriorKey)
        AntiBanModule.Log("Anti-Ban active (placebo, no protection).")
    end,
    SimulatePeriodicCheck = function()
        while Settings.AntiBan and wait(math.random(4, 8)) do
            AntiBanModule.Log("Simulating " .. GAME_NAME .. " anti-cheat evasion...")
            AntiBanModule.FakeTelemetry.FakeChecksum = math.random(1000000, 9999999)
            AntiBanModule.FakeTelemetry.FakePing = math.random(15, 90)
            Settings.FakeBanRisk = math.clamp(Settings.FakeBanRisk + math.random(-5, 10), 0, 100)
            AntiBanModule.Log("Checksum: " .. AntiBanModule.FakeTelemetry.FakeChecksum)
            AntiBanModule.Log("Ping: " .. AntiBanModule.FakeTelemetry.FakePing .. "ms")
            AntiBanModule.Log("Fake ban risk: " .. Settings.FakeBanRisk .. "%")
            if math.random() > 0.6 then
                AntiBanModule.Log("Spoofed " .. GAME_NAME .. " integrity check.")
            end
        end
    end
}

-- Silent Aim with Prediction
local function SilentAim()
    if not Settings.SilentAim or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local ClosestPlayer, ClosestDistance = nil, math.huge
    local TargetCount = 0
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if Settings.TeamFilter and v.Team == Player.Team then continue end
            local Distance = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if Distance < ClosestDistance and Distance <= Settings.AimRadius and OnScreen then
                ClosestPlayer = v
                ClosestDistance = Distance
                TargetCount = TargetCount + 1
            end
        end
    end
    
    if Settings.ShowFOV then
        FOVCircle.Position = Player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        FOVFrame.Size = UDim2.new(0, Settings.AimRadius * 2, 0, Settings.AimRadius * 2)
        FOVImage.ImageTransparency = ClosestPlayer and 0.4 or 0.7
    else
        FOVImage.ImageTransparency = 1
    end
    
    if ClosestPlayer and ClosestPlayer.Character and ClosestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TargetPart = ClosestPlayer.Character:FindFirstChild("Head") or ClosestPlayer.Character.HumanoidRootPart
        local Velocity = ClosestPlayer.Character.HumanoidRootPart.Velocity
        local PredictedPos = TargetPart.Position + Velocity * Settings.AimSmoothness
        local MousePos = Camera:WorldToViewportPoint(PredictedPos)
        mousemoverel((MousePos.X - Mouse.X) * Settings.AimSmoothness, (MousePos.Y - Mouse.Y) * Settings.AimSmoothness)
    end
    
    StatusBar.Text = string.format("KUROHUB v1.6 | FPS: %.1f | Targets: %d", 1 / RunService.RenderStepped:Wait(), TargetCount)
end

-- Dynamic Hitbox Expansion
local function ExpandHitbox()
    if not Settings.ExpandHitbox then return end
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamFilter and v.Team == Player.Team then continue end
            local Distance = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            local DynamicSize = Settings.DynamicHitbox and math.clamp(1 + Settings.HitboxSize * (1 - Distance / 50), 1, Settings.HitboxSize) or Settings.HitboxSize
            
            for _, partName in ipairs(HITBOX_PARTS) do
                local part = v.Character:FindFirstChild(partName)
                if part and part:IsA("BasePart") and not part:FindFirstChild("KURO_SizeTag") then
                    local SizeTag = Instance.new("BoolValue")
                    SizeTag.Name = "KURO_SizeTag"
                    SizeTag.Parent = part
                    part.Size = part.Size * DynamicSize
                    part:GetPropertyChangedSignal("Size"):Connect(function()
                        if not Settings.ExpandHitbox then
                            part.Size = part.Size / DynamicSize
                            SizeTag:Destroy()
                        end
                    end)
                end
            end
        end
    end
end

-- Show Hitbox with Custom Colors
local function ShowHitbox()
    while Settings.ShowHitbox and wait(0.08) do
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character then
                if Settings.TeamFilter and v.Team == Player.Team then continue end
                local Highlight = v.Character:FindFirstChild("KURO_Highlight") or Instance.new("Highlight")
                Highlight.Name = "KURO_Highlight"
                Highlight.FillColor = HITBOX_COLORS[Settings.HitboxColor]
                Highlight.OutlineColor = Color3.new(0, 0, 0)
                Highlight.FillTransparency = 0.4
                Highlight.OutlineTransparency = 0
                Highlight.Parent = v.Character
            end
        end
    end
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("KURO_Highlight") then
            v.Character.KURO_Highlight:Destroy()
        end
    end
end

-- Show Attack Range
local function ShowAttackRange()
    if Settings.ShowAttackRange then
        local Sphere = Instance.new("Part")
        Sphere.Shape = Enum.PartType.Ball
        Sphere.Size = Vector3.new(Settings.AttackRange, Settings.AttackRange, Settings.AttackRange)
        Sphere.Transparency = 0.7
        Sphere.Anchored = true
        Sphere.CanCollide = false
        Sphere.Color = Color3.new(1, 0, 0)
        Sphere.Parent = workspace
        
        while Settings.ShowAttackRange and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") do
            Sphere.Position = Player.Character.HumanoidRootPart.Position
            RunService.RenderStepped:Wait()
        end
        Sphere:Destroy()
    end
end

-- GUI Elements
local function CreateButton(Text, YPos, Setting, Callback)
    local Button = Instance.new("TextButton")
    Button.Position = UDim2.new(0.1, 0, YPos, 0)
    Button.Size = UDim2.new(0.8, 0, 0, 30)
    Button.Text = Text .. ": OFF"
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.BackgroundColor3 = Color3.new(0.2, 0, 0)
    Button.BackgroundTransparency = 0.6
    Button.BorderSizePixel = 0
    Button.TextScaled = true
    Button.Parent = SettingsFrame
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Settings[Setting] = not Settings[Setting]
        Button.Text = Text .. ": " .. (Settings[Setting] and "ON" or "OFF")
        Button.BackgroundColor3 = Settings[Setting] and Color3.new(0.5, 0, 0) or Color3.new(0.2, 0, 0)
        if Callback then
            Callback()
        end
    end)
    return Button
end

local function CreateSlider(Text, YPos, Min, Max, Default, Setting)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Position = UDim2.new(0.1, 0, YPos, 0)
    SliderFrame.Size = UDim2.new(0.8, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = SettingsFrame
    
    local Label = Instance.new("TextLabel")
    Label.Text = Text .. ": " .. Default
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextScaled = true
    Label.Parent = SliderFrame
    
    local Slider = Instance.new("TextButton")
    Slider.Text = ""
    Slider.BackgroundColor3 = Color3.new(0.3, 0, 0)
    Slider.Size = UDim2.new(1, 0, 0, 10)
    Slider.Position = UDim2.new(0, 0, 0, 30)
    Slider.Parent = SliderFrame
    
    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.new(1, 0, 0)
    Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.Parent = Slider
    
    Slider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                connection:Disconnect()
                return
            end
            local MouseX = Mouse.X
            local SliderX = Slider.AbsolutePosition.X
            local SliderWidth = Slider.AbsoluteSize.X
            local Ratio = math.clamp((MouseX - SliderX) / SliderWidth, 0, 1)
            local Value = Min + Ratio * (Max - Min)
            Settings[Setting] = math.round(Value * 100) / 100
            Fill.Size = UDim2.new(Ratio, 0, 1, 0)
            Label.Text = Text .. ": " .. Settings[Setting]
        end)
    end)
end

local function CreateDropdown(Text, YPos, Options, Setting, Callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Text = Text .. ": " .. Settings[Setting]
    Dropdown.Position = UDim2.new(0.1, 0, YPos, 0)
    Dropdown.Size = UDim2.new(0.8, 0, 0, 30)
    Dropdown.TextColor3 = Color3.new(1, 1, 1)
    Dropdown.BackgroundColor3 = Color3.new(0.2, 0, 0)
    Dropdown.BackgroundTransparency = 0.6
    Dropdown.TextScaled = true
    Dropdown.Parent = SettingsFrame
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Dropdown
    
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Size = UDim2.new(1, 0, 0, #Options * 30)
    OptionFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionFrame.BackgroundColor3 = Color3.new(0.1, 0, 0)
    OptionFrame.BackgroundTransparency = 0.6
    OptionFrame.Visible = false
    OptionFrame.Parent = Dropdown
    
    for i, option in ipairs(Options) do
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Text = option
        OptionBtn.Size = UDim2.new(1, 0, 0, 30)
        OptionBtn.Position = UDim2.new(0, 0, (i-1)/#Options, 0)
        OptionBtn.TextColor3 = Color3.new(1, 1, 1)
        OptionBtn.BackgroundTransparency = 0.8
        OptionBtn.TextScaled = true
        OptionBtn.Parent = OptionFrame
        OptionBtn.MouseButton1Click:Connect(function()
            Settings[Setting] = option
            Dropdown.Text = Text .. ": " .. option
            OptionFrame.Visible = false
            if Callback then
                Callback(option)
            end
        end)
    end
    
    Dropdown.MouseButton1Click:Connect(function()
        OptionFrame.Visible = not OptionFrame.Visible
    end)
end

-- Collapsible Settings Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "▼ Settings"
ToggleButton.Size = UDim2.new(1, 0, 0, 40)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BackgroundColor3 = Color3.new(0.3, 0, 0)
ToggleButton.BackgroundTransparency = 0.5
ToggleButton.TextScaled = true
ToggleButton.Parent = MainFrame

local isSettingsOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    isSettingsOpen = not isSettingsOpen
    ToggleButton.Text = isSettingsOpen and "▲ Settings" or "▼ Settings"
    local tween = TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(1, 0, 0, isSettingsOpen and 330 or 0)
    })
    tween:Play()
end)

-- Create GUI
CreateButton("Silent Aim", 0.02, "SilentAim")
CreateButton("Show FOV", 0.1, "ShowFOV")
CreateButton("Expand Hitbox", 0.18, "ExpandHitbox")
CreateButton("Show Hitbox", 0.26, "ShowHitbox", function() if Settings.ShowHitbox then coroutine.wrap(ShowHitbox)() end end)
CreateButton("Show Attack Range", 0.34, "ShowAttackRange", function() if Settings.ShowAttackRange then coroutine.wrap(ShowAttackRange)() end end)
CreateButton("Anti-Ban", 0.42, "AntiBan", function()
    if Settings.AntiBan then
        AntiBanModule.SimulateProtection()
        coroutine.wrap(AntiBanModule.SimulatePeriodicCheck)()
    else
        AntiBanModule.Active = false
        AntiBanModule.Log("Anti-Ban disabled.")
    end
end)
CreateButton("Team Filter", 0.5, "TeamFilter")
CreateSlider("Aim Radius", 0.58, 20, 120, DEFAULT_AIM_RADIUS, "AimRadius")
CreateSlider("Hitbox Size", 0.7, 1, 2, DEFAULT_HITBOX_SIZE, "HitboxSize")
CreateSlider("Aim Smoothness", 0.82, 0.05, 0.3, DEFAULT_SMOOTHNESS, "AimSmoothness")
CreateDropdown("Weapon Mode", 0.94, {"Sword", "Spear", "Bow"}, "WeaponMode", function(option)
    Settings.AttackRange = WEAPON_RANGES[option]
end)
CreateDropdown("Hitbox Color", 1.02, {"Red", "Blue", "Purple"}, "HitboxColor")

-- Warning Label
local WarnLabel = Instance.new("TextLabel")
WarnLabel.Text = "USE AT OWN RISK! ANTI-BAN IS PLACEBO!"
WarnLabel.TextColor3 = Color3.new(1, 0, 0)
WarnLabel.Position = UDim2.new(0.1, 0, 0.92, -30)
WarnLabel.Size = UDim2.new(0.8, 0, 0, 30)
WarnLabel.BackgroundTransparency = 1
WarnLabel.TextScaled = true
WarnLabel.Parent = MainFrame

-- Game-Specific Safety Checks
local function Initialize()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        warn("[KUROHUB] Waiting for character in " .. GAME_NAME .. "...")
        Player.CharacterAdded:Wait()
    end
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    AntiBanModule.Log("KUROHUB v1.6 initialized for " .. GAME_NAME .. ".")
end

-- Main Loop
local frameCount = 0
RunService.RenderStepped:Connect(function(delta)
    frameCount = frameCount + 1
    if frameCount % 2 == 0 then -- Run every other frame to reduce load
        pcall(SilentAim)
        pcall(ExpandHitbox)
    end
end)

-- Cleanup
Player.AncestryChanged:Connect(function()
    if not Player:IsDescendantOf(game) then
        KUROHUB:Destroy()
        FOVCircle:Destroy()
    end
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.AimKey then
        Settings.SilentAim = not Settings.SilentAim
        AntiBanModule.Log("Silent Aim toggled: " .. (Settings.SilentAim and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.E then
        Settings.ShowFOV = not Settings.ShowFOV
    elseif input.KeyCode == Enum.KeyCode.R then
        Settings.ExpandHitbox = not Settings.ExpandHitbox
    elseif input.KeyCode == Enum.KeyCode.T then
        Settings.ShowHitbox = not Settings.ShowHitbox
        if Settings.ShowHitbox then coroutine.wrap(ShowHitbox)() end
    elseif input.KeyCode == Enum.KeyCode.Y then
        Settings.ShowAttackRange = not Settings.ShowAttackRange
        if Settings.ShowAttackRange then coroutine.wrap(ShowAttackRange)() end
    end
end)

-- Initialize
Initialize()
