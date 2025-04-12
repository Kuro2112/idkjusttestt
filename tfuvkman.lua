-- KUROHUB v1.8 (Optimized for APEX-3-DUEL-Warriors)
-- Features: Ultra Silent Aim (Prediction, Priority), Extreme Hitbox Expansion (Dynamic, Visuals), Weapon Range, Anti-Ban (Placebo)
-- GUI: Polished Black/Red Menu with Tabs, Animations, Draggable Frame

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Game-Specific Constants
local GAME_NAME = "APEX-3-DUEL-Warriors"
local HITBOX_PARTS = {
    Head = 2.5, -- Higher multiplier for headshots
    HumanoidRootPart = 2.0,
    LeftArm = 1.5,
    RightArm = 1.5,
    LeftLeg = 1.5,
    RightLeg = 1.5
}
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
local DEFAULT_AIM_RADIUS = 80 -- Increased for wider coverage
local DEFAULT_HITBOX_SIZE = 2.0 -- Base for stronger effect
local DEFAULT_SMOOTHNESS = 0.08 -- Snappier aim

-- GUI Setup
local KUROHUB = Instance.new("ScreenGui")
KUROHUB.Name = "KUROHUB_" .. HttpService:GenerateGUID(false)
KUROHUB.Parent = game.CoreGui
KUROHUB.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = KUROHUB
MainFrame.BackgroundColor3 = Color3.new(0.05, 0, 0)
MainFrame.BackgroundTransparency = 0.4
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.new(0.3, 0, 0))
}
UIGradient.Transparency = NumberSequence.new(0.3)
UIGradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.new(0, 0, 0)
TitleBar.BackgroundTransparency = 0.5
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "KUROHUB v1.8 | " .. GAME_NAME
TitleLabel.TextColor3 = Color3.new(1, 0, 0)
TitleLabel.TextScaled = true
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 0, 0)
CloseButton.BackgroundColor3 = Color3.new(0.2, 0, 0)
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.TextScaled = true
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    KUROHUB.Enabled = false
end)

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 8)
UICornerClose.Parent = CloseButton

-- Draggable Frame
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.BackgroundTransparency = 0.6
TabFrame.BackgroundColor3 = Color3.new(0, 0, 0)
TabFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -120)
ContentFrame.Position = UDim2.new(0, 0, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local StatusBar = Instance.new("TextLabel")
StatusBar.Text = "FPS: -- | Targets: 0 | Ban Risk: 0%"
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
    AimLock = false, -- New: Lock onto one target
    AimPriority = "Closest", -- Closest, LowHealth
    AimKey = Enum.KeyCode.Q,
    AimRadius = DEFAULT_AIM_RADIUS,
    HitboxSize = DEFAULT_HITBOX_SIZE,
    AimSmoothness = DEFAULT_SMOOTHNESS,
    WeaponMode = "Sword",
    AttackRange = WEAPON_RANGES.Sword,
    HitboxColor = "Red",
    DynamicHitbox = true,
    HitboxParticles = false, -- New: Visual feedback
    AntiBanLevel = "Warrior Elite",
    FakeBanRisk = 0
}

-- Save/Load Settings
local function SaveSettings()
    local data = HttpService:JSONEncode(Settings)
    pcall(function()
        writefile("KUROHUB_" .. GAME_NAME .. ".json", data)
    end)
end

local function LoadSettings()
    pcall(function()
        if isfile("KUROHUB_" .. GAME_NAME .. ".json") then
            local data = readfile("KUROHUB_" .. GAME_NAME .. ".json")
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                Settings[k] = v
            end
        end
    end)
end

-- Sound Feedback
local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://200833581"
ClickSound.Volume = 0.5
ClickSound.Parent = MainFrame

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
        AntiBanModule.Log("Initializing Anti-Ban v2.5 for " .. GAME_NAME)
        AntiBanModule.FakeTelemetry = {
            SessionID = HttpService:GenerateGUID(false),
            Timestamp = os.time(),
            FakeChecksum = math.random(1000000, 9999999),
            FakeWarriorKey = "WRLR-ELITE-" .. math.random(10000, 99999),
            FakePing = math.random(15, 80)
        }
        AntiBanModule.Log("Elite Session ID: " .. AntiBanModule.FakeTelemetry.SessionID)
        AntiBanModule.Log("Protection Level: " .. Settings.AntiBanLevel)
        AntiBanModule.Log("Server ping: " .. AntiBanModule.FakeTelemetry.FakePing .. "ms")
        wait(0.4)
        AntiBanModule.Log("Checksum validated: " .. AntiBanModule.FakeTelemetry.FakeChecksum)
        AntiBanModule.Log("Warrior Key: " .. AntiBanModule.FakeTelemetry.FakeWarriorKey)
        AntiBanModule.Log("Anti-Ban active (placebo, no protection).")
    end,
    SimulatePeriodicCheck = function()
        while Settings.AntiBan and wait(math.random(3, 7)) do
            AntiBanModule.Log("Simulating " .. GAME_NAME .. " anti-cheat evasion...")
            AntiBanModule.FakeTelemetry.FakeChecksum = math.random(1000000, 9999999)
            AntiBanModule.FakeTelemetry.FakePing = math.random(15, 80)
            Settings.FakeBanRisk = math.clamp(Settings.FakeBanRisk + math.random(-10, 15), 0, 100)
            AntiBanModule.Log("Checksum: " .. AntiBanModule.FakeTelemetry.FakeChecksum)
            AntiBanModule.Log("Ping: " .. AntiBanModule.FakeTelemetry.FakePing .. "ms")
            AntiBanModule.Log("Fake ban risk: " .. Settings.FakeBanRisk .. "%")
        end
    end
}

-- Ultra Silent Aim
local LockedTarget = nil
local function SilentAim()
    if not Settings.SilentAim or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        LockedTarget = nil
        return
    end
    
    local ClosestPlayer, ClosestScore = nil, math.huge
    local TargetCount = 0
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if Settings.TeamFilter and v.Team == Player.Team then continue end
            local Distance = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if Distance <= Settings.AimRadius and OnScreen then
                local Score
                if Settings.AimPriority == "Closest" then
                    Score = Distance
                elseif Settings.AimPriority == "LowHealth" then
                    Score = v.Character.Humanoid.Health
                end
                if Score < ClosestScore and (not Settings.AimLock or LockedTarget == v or LockedTarget == nil) then
                    ClosestPlayer = v
                    ClosestScore = Score
                    TargetCount = TargetCount + 1
                end
            end
        end
    end
    
    if Settings.AimLock and ClosestPlayer then
        LockedTarget = ClosestPlayer
    elseif not Settings.AimLock then
        LockedTarget = nil
    end
    
    if Settings.ShowFOV then
        FOVCircle.Position = Player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        FOVFrame.Size = UDim2.new(0, Settings.AimRadius * 2, 0, Settings.AimRadius * 2)
        FOVImage.ImageTransparency = ClosestPlayer and 0.3 or 0.7
    else
        FOVImage.ImageTransparency = 1
    end
    
    if ClosestPlayer and ClosestPlayer.Character and ClosestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TargetPart = ClosestPlayer.Character:FindFirstChild("Head") or ClosestPlayer.Character.HumanoidRootPart
        local Velocity = ClosestPlayer.Character.HumanoidRootPart.Velocity
        local PingFactor = AntiBanModule.FakeTelemetry.FakePing and (AntiBanModule.FakeTelemetry.FakePing / 1000) or 0.05
        local PredictedPos = TargetPart.Position + Velocity * (Settings.AimSmoothness + PingFactor)
        local MousePos = Camera:WorldToViewportPoint(PredictedPos)
        local DeltaX = (MousePos.X - Mouse.X) * Settings.AimSmoothness
        local DeltaY = (MousePos.Y - Mouse.Y) * Settings.AimSmoothness
        mousemoverel(DeltaX, DeltaY)
    end
    
    StatusBar.Text = string.format("FPS: %.1f | Targets: %d | Ban Risk: %d%%", 1 / RunService.RenderStepped:Wait(), TargetCount, Settings.FakeBanRisk)
end

-- Extreme Hitbox Expansion
local HitboxCache = {}
local function ExpandHitbox()
    if not Settings.ExpandHitbox then
        -- Revert hitboxes
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character then
                for partName, _ in pairs(HITBOX_PARTS) do
                    local part = v.Character:FindFirstChild(partName)
                    if part and part:FindFirstChild("KURO_SizeTag") then
                        local OriginalSize = part:FindFirstChild("KURO_OriginalSize")
                        if OriginalSize then
                            part.Size = OriginalSize.Value
                            OriginalSize:Destroy()
                            part:FindFirstChild("KURO_SizeTag"):Destroy()
                        end
                    end
                end
                if Settings.HitboxParticles and v.Character:FindFirstChild("KURO_Particles") then
                    v.Character.KURO_Particles:Destroy()
                end
            end
        end
        HitboxCache = {}
        return
    end
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamFilter and v.Team == Player.Team then continue end
            local Distance = (v.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            local DynamicSize = Settings.DynamicHitbox and math.clamp(Settings.HitboxSize * (1 + (50 - Distance) / 25), Settings.HitboxSize, Settings.HitboxSize * 1.5) or Settings.HitboxSize
            
            for partName, Multiplier in pairs(HITBOX_PARTS) do
                local part = v.Character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    if not HitboxCache[v.UserId .. partName] then
                        local OriginalSize = Instance.new("Vector3Value")
                        OriginalSize.Name = "KURO_OriginalSize"
                        OriginalSize.Value = part.Size
                        OriginalSize.Parent = part
                        local SizeTag = Instance.new("BoolValue")
                        SizeTag.Name = "KURO_SizeTag"
                        SizeTag.Parent = part
                        HitboxCache[v.UserId .. partName] = true
                    end
                    part.Size = part:FindFirstChild("KURO_OriginalSize").Value * DynamicSize * Multiplier
                end
            end
            
            if Settings.HitboxParticles and not v.Character:FindFirstChild("KURO_Particles") then
                local ParticleEmitter = Instance.new("ParticleEmitter")
                ParticleEmitter.Name = "KURO_Particles"
                ParticleEmitter.Texture = "rbxassetid://243098098" -- Sparkle effect
                ParticleEmitter.Size = NumberSequence.new(0.2)
                ParticleEmitter.Transparency = NumberSequence.new(0.5)
                ParticleEmitter.Lifetime = NumberRange.new(0.5, 1)
                ParticleEmitter.Rate = 10
                ParticleEmitter.Color = ColorSequence.new(HITBOX_COLORS[Settings.HitboxColor])
                ParticleEmitter.Parent = v.Character.HumanoidRootPart
            end
        end
    end
end

-- Show Hitbox
local function ShowHitbox()
    while Settings.ShowHitbox and wait(0.08) do
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character then
                if Settings.TeamFilter and v.Team == Player.Team then continue end
                local Highlight = v.Character:FindFirstChild("KURO_Highlight") or Instance.new("Highlight")
                Highlight.Name = "KURO_Highlight"
                Highlight.FillColor = HITBOX_COLORS[Settings.HitboxColor]
                Highlight.OutlineColor = Color3.new(0, 0, 0)
                Highlight.FillTransparency = 0.3
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
local function CreateButton(Text, YPos, Setting, Parent, Callback)
    local Button = Instance.new("TextButton")
    Button.Position = UDim2.new(0.05, 0, YPos, 0)
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.Text = Text .. ": " .. (Settings[Setting] and "ON" or "OFF")
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.BackgroundColor3 = Color3.new(0.2, 0, 0)
    Button.BackgroundTransparency = 0.5
    Button.BorderSizePixel = 0
    Button.TextScaled = true
    Button.Parent = Parent
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 10)
    UICornerBtn.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(0.4, 0, 0)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Settings[Setting] and Color3.new(0.6, 0, 0) or Color3.new(0.2, 0, 0)}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
        Settings[Setting] = not Settings[Setting]
        Button.Text = Text .. ": " .. (Settings[Setting] and "ON" or "OFF")
        Button.BackgroundColor3 = Settings[Setting] and Color3.new(0.6, 0, 0) or Color3.new(0.2, 0, 0)
        SaveSettings()
        if Callback then
            Callback()
        end
    end)
    return Button
end

local function CreateSlider(Text, YPos, Min, Max, Default, Setting, Parent)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Position = UDim2.new(0.05, 0, YPos, 0)
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Text = Text .. ": " .. Settings[Setting]
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
    Fill.Size = UDim2.new((Settings[Setting] - Min) / (Max - Min), 0, 1, 0)
    Fill.Parent = Slider
    
    Slider.MouseButton1Down:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
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
            SaveSettings()
        end)
    end)
end

local function CreateDropdown(Text, YPos, Options, Setting, Parent, Callback)
    local Dropdown = Instance.new("TextButton")
    Dropdown.Text = Text .. ": " .. Settings[Setting]
    Dropdown.Position = UDim2.new(0.05, 0, YPos, 0)
    Dropdown.Size = UDim2.new(0.9, 0, 0, 35)
    Dropdown.TextColor3 = Color3.new(1, 1, 1)
    Dropdown.BackgroundColor3 = Color3.new(0.2, 0, 0)
    Dropdown.BackgroundTransparency = 0.5
    Dropdown.TextScaled = true
    Dropdown.Parent = Parent
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 10)
    UICornerBtn.Parent = Dropdown
    
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Size = UDim2.new(1, 0, 0, #Options * 35)
    OptionFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionFrame.BackgroundColor3 = Color3.new(0.1, 0, 0)
    OptionFrame.BackgroundTransparency = 0.5
    OptionFrame.Visible = false
    OptionFrame.Parent = Dropdown
    
    for i, option in ipairs(Options) do
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Text = option
        OptionBtn.Size = UDim2.new(1, 0, 0, 35)
        OptionBtn.Position = UDim2.new(0, 0, (i-1)/#Options, 0)
        OptionBtn.TextColor3 = Color3.new(1, 1, 1)
        OptionBtn.BackgroundTransparency = 0.7
        OptionBtn.TextScaled = true
        OptionBtn.Parent = OptionFrame
        OptionBtn.MouseButton1Click:Connect(function()
            SoundService:PlayLocalSound(ClickSound)
            Settings[Setting] = option
            Dropdown.Text = Text .. ": " .. option
            OptionFrame.Visible = false
            SaveSettings()
            if Callback then
                Callback(option)
            end
        end)
    end
    
    Dropdown.MouseButton1Click:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
        OptionFrame.Visible = not OptionFrame.Visible
    end)
end

-- Tab Management
local Tabs = {
    Aim = Instance.new("Frame"),
    Hitbox = Instance.new("Frame"),
    Visuals = Instance.new("Frame"),
    AntiBan = Instance.new("Frame")
}

for _, tab in pairs(Tabs) do
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.Parent = ContentFrame
end
Tabs.Aim.Visible = true

local TabButtons = {}
local function CreateTabButton(Text, XPos, Tab)
    local Button = Instance.new("TextButton")
    Button.Text = Text
    Button.Size = UDim2.new(0.25, -5, 1, -5)
    Button.Position = UDim2.new(XPos, 0, 0, 5)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.BackgroundColor3 = Color3.new(0.2, 0, 0)
    Button.BackgroundTransparency = 0.5
    Button.TextScaled = true
    Button.Parent = TabFrame
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(0.4, 0, 0)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Tabs[Tab].Visible and Color3.new(0.6, 0, 0) or Color3.new(0.2, 0, 0)}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
        for _, t in pairs(Tabs) do
            t.Visible = false
        end
        Tabs[Tab].Visible = true
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.new(0.2, 0, 0)
        end
        Button.BackgroundColor3 = Color3.new(0.6, 0, 0)
    end)
    table.insert(TabButtons, Button)
end

CreateTabButton("Aim", 0, "Aim")
CreateTabButton("Hitbox", 0.25, "Hitbox")
CreateTabButton("Visuals", 0.5, "Visuals")
CreateTabButton("Anti-Ban", 0.75, "AntiBan")

-- Populate Tabs
CreateButton("Silent Aim [Q]", 0.05, "SilentAim", Tabs.Aim)
CreateButton("Show FOV [E]", 0.15, "ShowFOV", Tabs.Aim)
CreateButton("Team Filter", 0.25, "TeamFilter", Tabs.Aim)
CreateButton("Aim Lock", 0.35, "AimLock", Tabs.Aim)
CreateDropdown("Aim Priority", 0.45, {"Closest", "LowHealth"}, "AimPriority", Tabs.Aim)
CreateSlider("Aim Radius", 0.55, 20, 150, DEFAULT_AIM_RADIUS, "AimRadius", Tabs.Aim)
CreateSlider("Aim Smoothness", 0.7, 0.05, 0.2, DEFAULT_SMOOTHNESS, "AimSmoothness", Tabs.Aim)

CreateButton("Expand Hitbox [R]", 0.05, "ExpandHitbox", Tabs.Hitbox)
CreateButton("Dynamic Hitbox", 0.15, "DynamicHitbox", Tabs.Hitbox)
CreateButton("Hitbox Particles", 0.25, "HitboxParticles", Tabs.Hitbox)
CreateSlider("Hitbox Size", 0.35, 1, 3, DEFAULT_HITBOX_SIZE, "HitboxSize", Tabs.Hitbox)

CreateButton("Show Hitbox [T]", 0.05, "ShowHitbox", Tabs.Visuals, function() if Settings.ShowHitbox then coroutine.wrap(ShowHitbox)() end end)
CreateButton("Show Attack Range [Y]", 0.15, "ShowAttackRange", Tabs.Visuals, function() if Settings.ShowAttackRange then coroutine.wrap(ShowAttackRange)() end end)
CreateDropdown("Weapon Mode", 0.25, {"Sword", "Spear", "Bow"}, "WeaponMode", Tabs.Visuals, function(option)
    Settings.AttackRange = WEAPON_RANGES[option]
end)
CreateDropdown("Hitbox Color", 0.35, {"Red", "Blue", "Purple"}, "HitboxColor", Tabs.Visuals)

CreateButton("Anti-Ban", 0.05, "AntiBan", Tabs.AntiBan, function()
    if Settings.AntiBan then
        AntiBanModule.SimulateProtection()
        coroutine.wrap(AntiBanModule.SimulatePeriodicCheck)()
    else
        AntiBanModule.Active = false
        AntiBanModule.Log("Anti-Ban disabled.")
    end
end)
local RiskLabel = Instance.new("TextLabel")
RiskLabel.Text = "Fake Ban Risk: " .. Settings.FakeBanRisk .. "%"
RiskLabel.TextColor3 = Color3.new(1, 0, 0)
RiskLabel.Size = UDim2.new(0.9, 0, 0, 30)
RiskLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
RiskLabel.BackgroundTransparency = 1
RiskLabel.TextScaled = true
RiskLabel.Parent = Tabs.AntiBan

-- Warning Label
local WarnLabel = Instance.new("TextLabel")
WarnLabel.Text = "USE AT OWN RISK! ANTI-BAN IS PLACEBO!"
WarnLabel.TextColor3 = Color3.new(1, 0, 0)
WarnLabel.Position = UDim2.new(0.05, 0, 1, -60)
WarnLabel.Size = UDim2.new(0.9, 0, 0, 30)
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
    LoadSettings()
    AntiBanModule.Log("KUROHUB v1.8 initialized for " .. GAME_NAME .. ".")
end

-- Main Loop
local frameCount = 0
RunService.RenderStepped:Connect(function(delta)
    frameCount = frameCount + 1
    if frameCount % 2 == 0 then
        pcall(SilentAim)
        pcall(ExpandHitbox)
    end
    RiskLabel.Text = "Fake Ban Risk: " .. Settings.FakeBanRisk .. "%"
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
        SaveSettings()
        AntiBanModule.Log("Silent Aim toggled: " .. (Settings.SilentAim and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.E then
        Settings.ShowFOV = not Settings.ShowFOV
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.R then
        Settings.ExpandHitbox = not Settings.ExpandHitbox
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.T then
        Settings.ShowHitbox = not Settings.ShowHitbox
        SaveSettings()
        if Settings.ShowHitbox then coroutine.wrap(ShowHitbox)() end
    elseif input.KeyCode == Enum.KeyCode.Y then
        Settings.ShowAttackRange = not Settings.ShowAttackRange
        SaveSettings()
        if Settings.ShowAttackRange then coroutine.wrap(ShowAttackRange)() end
    elseif input.KeyCode == Enum.KeyCode.H then
        KUROHUB.Enabled = not KUROHUB.Enabled
    end
end)

-- Initialize
Initialize()
