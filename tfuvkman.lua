local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexsoft/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "KUROHUB",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "KUROHUB_Config"
})

-- Settings
local Settings = {
    SilentAim = false,
    SilentAimFOV = 30,
    SilentAimBone = "Head",
    ExpandHitbox = false,
    HitboxScale = 1.5,
    ShowHitbox = true,
    ShowAttackRange = true,
    MaxAttackRange = 100,
    AntiBan = true
}

-- Silent Aim Functionality
local function FindBestTarget()
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local closestTarget = nil
    local closestAngle = Settings.SilentAimFOV

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(Settings.SilentAimBone) then
            local targetPart = player.Character[Settings.SilentAimBone]
            local targetPos = targetPart.Position
            local angle = math.deg(math.acos((camera.CFrame.LookVector):Dot((targetPos - camera.CFrame.Position).Unit)))

            if angle < closestAngle then
                closestAngle = angle
                closestTarget = player
            end
        end
    end

    return closestTarget
end

-- Expand Hitbox Functionality
local function ApplyHitboxExpansion(scale)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hitbox = player.Character.HumanoidRootPart
            hitbox.Size = Vector3.new(2, 2, 2) * scale
            hitbox.Transparency = 0.5
            hitbox.Color = Color3.fromRGB(255, 0, 0)
        end
    end
end

-- Show Attack Range
local function ShowRange()
    local localPlayer = game.Players.LocalPlayer
    local rangeCircle = Instance.new("Part")
    rangeCircle.Anchored = true
    rangeCircle.CanCollide = false
    rangeCircle.Shape = Enum.PartType.Cylinder
    rangeCircle.Size = Vector3.new(Settings.MaxAttackRange * 2, 0.1, Settings.MaxAttackRange * 2)
    rangeCircle.Color = Color3.fromRGB(0, 255, 255)
    rangeCircle.Transparency = 0.7
    rangeCircle.Parent = workspace

    game:GetService("RunService").Heartbeat:Connect(function()
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            rangeCircle.CFrame = CFrame.new(localPlayer.Character.HumanoidRootPart.Position) * CFrame.Angles(math.pi/2, 0, 0)
        end
    end)
end

-- Anti-Ban Functionality
local function AntiBan()
    while Settings.AntiBan do
        wait(30)
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player:GetRankInGroup(1) > 100 then -- Adjust GroupId if necessary
                warn("[ANTI-BAN] Admin detected! Disabling functionalities...")
                Settings.SilentAim = false
                Settings.ExpandHitbox = false
                Settings.ShowAttackRange = false
                return
            end
        end
    end
end

-- Orion Library Menu
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(state)
        Settings.SilentAim = state
        if state then
            spawn(function()
                while Settings.SilentAim do
                    local target = FindBestTarget()
                    if target and target.Character and target.Character:FindFirstChild(Settings.SilentAimBone) then
                        workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Character[Settings.SilentAimBone].Position)
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

MainTab:AddSlider({
    Name = "Silent Aim FOV",
    Min = 10,
    Max = 90,
    Default = 30,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    Callback = function(value)
        Settings.SilentAimFOV = value
    end
})

MainTab:AddDropdown({
    Name = "Silent Aim Bone",
    Options = {"Head", "Torso", "LeftLeg", "RightLeg"},
    Default = "Head",
    Callback = function(value)
        Settings.SilentAimBone = value
    end
})

MainTab:AddToggle({
    Name = "Expand Hitbox",
    Default = false,
    Callback = function(state)
        Settings.ExpandHitbox = state
        if state then
            ApplyHitboxExpansion(Settings.HitboxScale)
        end
    end
})

MainTab:AddSlider({
    Name = "Hitbox Scale",
    Min = 1,
    Max = 3,
    Default = 1.5,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 0.1,
    Callback = function(value)
        Settings.HitboxScale = value
    end
})

MainTab:AddToggle({
    Name = "Show Attack Range",
    Default = true,
    Callback = function(state)
        Settings.ShowAttackRange = state
        if state then
            spawn(ShowRange)
        end
    end
})

MainTab:AddSlider({
    Name = "Max Attack Range",
    Min = 50,
    Max = 200,
    Default = 100,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 10,
    Callback = function(value)
        Settings.MaxAttackRange = value
    end
})

-- Security Tab
local SecurityTab = Window:MakeTab({
    Name = "Security",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SecurityTab:AddToggle({
    Name = "Anti-Ban",
    Default = true,
    Callback = function(state)
        Settings.AntiBan = state
        if state then
            spawn(AntiBan)
        end
    end
})

-- Finalizing Menu
OrionLib:Init()
