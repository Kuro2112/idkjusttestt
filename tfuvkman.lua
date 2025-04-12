-- KUROHUB v2.4 (Tối ưu cho APEX-3-DUEL-Warriors)
-- Tính năng: Silent Aim Siêu Cấp, Mở Rộng Hitbox Cực Đại, Show Hitbox Sửa Lỗi, Anti-Ban Siêu Tinh Vi (Giả Lập)
-- Giao diện: Phong cách Redz Hub (Neon, Đen/Xám, Hiệu ứng Mượt), Thu Nhỏ Thành Khối Vuông với Hình Mặt Trời Ria Mép

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Hằng số game
local GAME_NAME = "APEX-3-DUEL-Warriors"
local HITBOX_PARTS = {
    Head = 3.0,
    HumanoidRootPart = 2.5,
    LeftArm = 1.8,
    RightArm = 1.8,
    LeftLeg = 1.8,
    RightLeg = 1.8
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
local DEFAULT_AIM_RADIUS = 100
local DEFAULT_HITBOX_SIZE = 2.5
local DEFAULT_SMOOTHNESS = 0.06

-- Thiết lập giao diện
local KUROHUB = Instance.new("ScreenGui")
KUROHUB.Name = "KUROHUB_" .. HttpService:GenerateGUID(false)
KUROHUB.Parent = game.CoreGui
KUROHUB.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = KUROHUB
MainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 1

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.new(0, 0.75, 1)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.2
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0, 0))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
TitleBar.BackgroundTransparency = 0.4
TitleBar.Parent = MainFrame
TitleBar.ZIndex = 2

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Text = "KUROHUB"
LogoLabel.TextColor3 = Color3.new(0, 0.75, 1)
LogoLabel.TextScaled = true
LogoLabel.Size = UDim2.new(0.3, 0, 0.8, 0)
LogoLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Font = Enum.Font.SourceSansPro
LogoLabel.Parent = TitleBar
LogoLabel.ZIndex = 3

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "v2.4 | " .. GAME_NAME
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextScaled = true
TitleLabel.Size = UDim2.new(0.4, 0, 0.6, 0)
TitleLabel.Position = UDim2.new(0.35, 0, 0.2, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansPro
TitleLabel.Parent = TitleBar
TitleLabel.ZIndex = 3

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.SourceSansPro
CloseButton.Parent = TitleBar
CloseButton.ZIndex = 3
CloseButton.MouseButton1Click:Connect(function()
    KUROHUB.Enabled = false
end)

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 8)
UICornerClose.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.TextScaled = true
MinimizeButton.Font = Enum.Font.SourceSansPro
MinimizeButton.Parent = TitleBar
MinimizeButton.ZIndex = 3

local UICornerMinimize = Instance.new("UICorner")
UICornerMinimize.CornerRadius = UDim.new(0, 8)
UICornerMinimize.Parent = MinimizeButton

-- Khối vuông khi thu nhỏ (với hình mặt trời ria mép)
local MinimizedSquare = Instance.new("ImageButton")
MinimizedSquare.Size = UDim2.new(0, 50, 0, 50)
MinimizedSquare.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
MinimizedSquare.BackgroundTransparency = 0.2
MinimizedSquare.Image = "rbxassetid://[THAY_ID_HINH_ANH_VAO_DAY]" -- Thay ID hình ảnh mặt trời với ria mép vào đây
MinimizedSquare.ImageTransparency = 0
MinimizedSquare.Visible = false
MinimizedSquare.Parent = KUROHUB
MinimizedSquare.ZIndex = 1

local SquareUICorner = Instance.new("UICorner")
SquareUICorner.CornerRadius = UDim.new(0, 12)
SquareUICorner.Parent = MinimizedSquare

local SquareUIStroke = Instance.new("UIStroke")
SquareUIStroke.Color = Color3.new(0, 0.75, 1)
SquareUIStroke.Thickness = 2
SquareUIStroke.Transparency = 0.2
SquareUIStroke.Parent = MinimizedSquare

-- Kéo thả giao diện
local dragging, dragInput, dragStart, startPos
local function SetupDragging(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)
end
SetupDragging(TitleBar)
SetupDragging(MinimizedSquare)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local targetFrame = MinimizedSquare.Visible and MinimizedSquare or MainFrame
        targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Thu nhỏ/Phóng to
local isMinimized = false
local function ToggleMinimize()
    SoundService:PlayLocalSound(ClickSound)
    isMinimized = not isMinimized
    
    if isMinimized then
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 50, 0, 50), Rotation = 5}):Play()
        wait(0.4)
        MainFrame.Visible = false
        MinimizedSquare.Position = MainFrame.Position
        MinimizedSquare.Visible = true
        MinimizedSquare.Rotation = 5
        TweenService:Create(MinimizedSquare, tweenInfo, {Rotation = 0}):Play()
        MinimizeButton.Text = "+"
    else
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        MainFrame.Visible = true
        MainFrame.Position = MinimizedSquare.Position
        MainFrame.Rotation = 5
        TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 320, 0, 420), Rotation = 0}):Play()
        wait(0.4)
        MinimizedSquare.Visible = false
        MinimizeButton.Text = "-"
    end
end

MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)
MinimizedSquare.MouseButton1Click:Connect(ToggleMinimize)

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -10, 0, 35)
TabFrame.Position = UDim2.new(0, 5, 0, 45)
TabFrame.BackgroundTransparency = 0.6
TabFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
TabFrame.Parent = MainFrame
TabFrame.ZIndex = 3

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -120)
ContentFrame.Position = UDim2.new(0, 5, 0, 85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame
ContentFrame.ZIndex = 4

local StatusBar = Instance.new("TextLabel")
StatusBar.Text = "FPS: -- | Mục tiêu: 0 | Rủi ro: An Toàn"
StatusBar.TextColor3 = Color3.new(0, 0.75, 1)
StatusBar.BackgroundTransparency = 0.7
StatusBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
StatusBar.Size = UDim2.new(1, -10, 0, 25)
StatusBar.Position = UDim2.new(0, 5, 1, -30)
StatusBar.TextScaled = true
StatusBar.Font = Enum.Font.SourceSansPro
StatusBar.Parent = MainFrame
StatusBar.ZIndex = 5

local StatusUICorner = Instance.new("UICorner")
StatusUICorner.CornerRadius = UDim.new(0, 6)
StatusUICorner.Parent = StatusBar

-- Thanh tiến trình Anti-Ban
local ProtectionBarFrame = Instance.new("Frame")
ProtectionBarFrame.Size = UDim2.new(0.9, 0, 0, 15)
ProtectionBarFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
ProtectionBarFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
ProtectionBarFrame.Parent = nil
ProtectionBarFrame.ZIndex = 5

local ProtectionBarFill = Instance.new("Frame")
ProtectionBarFill.Size = UDim2.new(0, 0, 1, 0)
ProtectionBarFill.BackgroundColor3 = Color3.new(0, 0.75, 1)
ProtectionBarFill.Parent = ProtectionBarFrame
ProtectionBarFill.ZIndex = 6

local UICornerProtection = Instance.new("UICorner")
UICornerProtection.CornerRadius = UDim.new(0, 4)
UICornerProtection.Parent = ProtectionBarFrame

local UICornerProtectionFill = Instance.new("UICorner")
UICornerProtectionFill.CornerRadius = UDim.new(0, 4)
UICornerProtectionFill.Parent = ProtectionBarFill

local ProtectionLabel = Instance.new("TextLabel")
ProtectionLabel.Text = "Bypass: 0%"
ProtectionLabel.TextColor3 = Color3.new(1, 1, 1)
ProtectionLabel.Size = UDim2.new(0.9, 0, 0, 20)
ProtectionLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
ProtectionLabel.BackgroundTransparency = 1
ProtectionLabel.TextScaled = true
ProtectionLabel.Font = Enum.Font.SourceSansPro
ProtectionLabel.Parent = nil
ProtectionLabel.ZIndex = 5

-- Cài đặt
local Settings = {
    SilentAim = false,
    ShowFOV = false,
    ExpandHitbox = false,
    ShowHitbox = false,
    ShowAttackRange = false,
    AntiBan = false,
    TeamFilter = true,
    AimLock = false,
    AimPriority = "Closest",
    AimKey = Enum.KeyCode.Q,
    AimRadius = DEFAULT_AIM_RADIUS,
    HitboxSize = DEFAULT_HITBOX_SIZE,
    AimSmoothness = DEFAULT_SMOOTHNESS,
    WeaponMode = "Sword",
    AttackRange = WEAPON_RANGES.Sword,
    HitboxColor = "Red",
    DynamicHitbox = true,
    HitboxParticles = false,
    AntiBanLevel = "Chiến Thần Vô Hạn",
    FakeBanRisk = 0,
    ProtectionProgress = 0
}

-- Lưu/Gọi cài đặt
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

-- Âm thanh phản hồi
local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://200833581"
ClickSound.Volume = 0.5
ClickSound.Parent = MainFrame

-- Vòng FOV
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
FOVImage.Image = "rbxassetid://0" -- Thay bằng hình vòng tròn đỏ
FOVImage.ImageColor3 = Color3.new(1, 0, 0)
FOVImage.ImageTransparency = 0.7
FOVImage.Parent = FOVFrame

-- Anti-Ban Siêu Tinh Vi (Giả Lập)
local AntiBanModule = {
    Active = false,
    FakeTelemetry = {},
    RiskLevel = "An Toàn",
    Log = function(message)
        warn("[KUROHUB Anti-Ban | " .. GAME_NAME .. "]: " .. message)
    end,
    SimulateProtection = function()
        if not Settings.AntiBan then return end
        AntiBanModule.Active = true
        AntiBanModule.Log("Khởi tạo Anti-Ban Siêu Tinh Vi v3.0 cho " .. GAME_NAME)
        AntiBanModule.FakeTelemetry = {
            SessionID = HttpService:GenerateGUID(false),
            Timestamp = os.time(),
            FakeChecksum = math.random(1000000, 9999999),
            FakeWarriorKey = "WRLR-CHIẾN-THẦN-" .. HttpService:GenerateGUID(false):sub(1, 8),
            FakePing = math.random(5, 50),
            FakePacketHash = tostring(math.random(100000, 999999)) .. "-" .. math.random(1000, 9999),
            FakeBehaviorScore = math.random(80, 95),
            FakeServerKey = "SRV-" .. HttpService:GenerateGUID(false):sub(1, 12)
        }
        AntiBanModule.Log("ID phiên: " .. AntiBanModule.FakeTelemetry.SessionID)
        AntiBanModule.Log("Cấp bảo vệ: " .. Settings.AntiBanLevel)
        AntiBanModule.Log("Ping giả lập: " .. AntiBanModule.FakeTelemetry.FakePing .. "ms")
        AntiBanModule.Log("Mã gói tin: " .. AntiBanModule.FakeTelemetry.FakePacketHash)
        AntiBanModule.Log("Điểm hành vi: " .. AntiBanModule.FakeTelemetry.FakeBehaviorScore .. "/100")
        wait(0.5)
        AntiBanModule.Log("Mã xác thực server: " .. AntiBanModule.FakeTelemetry.FakeServerKey)
        AntiBanModule.Log("Mô phỏng mã hóa dữ liệu client...")
        AntiBanModule.Log("Anti-Ban Siêu Tinh Vi kích hoạt (GIẢ LẬP, KHÔNG BẢO VỆ THẬT).")
    end,
    SimulatePeriodicCheck = function()
        while Settings.AntiBan and wait(math.random(2, 5)) do
            AntiBanModule.FakeTelemetry.FakeChecksum = math.random(1000000, 9999999)
            AntiBanModule.FakeTelemetry.FakePing = math.random(5, 50)
            AntiBanModule.FakeTelemetry.FakePacketHash = tostring(math.random(100000, 999999)) .. "-" .. math.random(1000, 9999)
            AntiBanModule.FakeTelemetry.FakeBehaviorScore = math.clamp(AntiBanModule.FakeTelemetry.FakeBehaviorScore + math.random(-5, 5), 70, 98)
            Settings.FakeBanRisk = math.clamp(Settings.FakeBanRisk + math.random(-10, 15), 0, 90)
            Settings.ProtectionProgress = math.clamp(Settings.ProtectionProgress + math.random(5, 20), 0, 100)
            
            if Settings.FakeBanRisk < 30 then
                AntiBanModule.RiskLevel = "An Toàn"
            elseif Settings.FakeBanRisk < 60 then
                AntiBanModule.RiskLevel = "Nguy Hiểm"
            else
                AntiBanModule.RiskLevel = "Cực Kỳ Nguy Hiểm"
            end
            
            AntiBanModule.Log("Kiểm tra định kỳ: Mã mới: " .. AntiBanModule.FakeTelemetry.FakeChecksum)
            AntiBanModule.Log("Ping: " .. AntiBanModule.FakeTelemetry.FakePing .. "ms")
            AntiBanModule.Log("Gói tin: " .. AntiBanModule.FakeTelemetry.FakePacketHash)
            AntiBanModule.Log("Điểm hành vi: " .. AntiBanModule.FakeTelemetry.FakeBehaviorScore .. "/100")
            AntiBanModule.Log("Rủi ro ban giả: " .. Settings.FakeBanRisk .. "% (" .. AntiBanModule.RiskLevel .. ")")
            AntiBanModule.Log("Tiến trình bypass: " .. Settings.ProtectionProgress .. "%")
            
            if Settings.SilentAim then
                local randomSmooth = Settings.AimSmoothness * math.random(90, 110) / 100
                AntiBanModule.Log("Ngụy trang Silent Aim: Độ mượt ngẫu nhiên " .. string.format("%.3f", randomSmooth))
            end
            if Settings.ExpandHitbox then
                local randomSize = Settings.HitboxSize * math.random(95, 105) / 100
                AntiBanModule.Log("Ngụy trang Hitbox: Kích thước ngẫu nhiên " .. string.format("%.2f", randomSize) .. "x")
            end
        end
    end,
    SimulatePacketObfuscation = function()
        if not Settings.AntiBan then return end
        AntiBanModule.Log("Mô phỏng nhiễu gói tin server...")
        local fakePackets = math.random(3, 8)
        for i = 1, fakePackets do
            AntiBanModule.Log("Gửi gói tin giả #" .. i .. ": PKT-" .. HttpService:GenerateGUID(false):sub(1, 6))
            wait(0.1)
        end
        AntiBanModule.Log("Nhiễu hoàn tất, server bị đánh lừa (giả lập).")
    end
}

-- Silent Aim Siêu Cấp
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
                elseif Settings.AimPriority == "Headshot" then
                    Score = v.Character:FindFirstChild("Head") and Distance or math.huge
                end
                if Score < ClosestScore and (not Settings.AimLock or LockedTarget == v or LockedTarget == nil) then
                    ClosestPlayer = v
                    ClosestScore = Score
                    TargetCount = TargetCount + 1
                end
            end
        end
    end
    
    if Settings.AimLock and ClosestPlayer and (LockedTarget == nil or LockedTarget.Character.Humanoid.Health > 0) then
        LockedTarget = ClosestPlayer
    elseif not ClosestPlayer or (LockedTarget and LockedTarget.Character.Humanoid.Health <= 0) then
        LockedTarget = nil
    end
    
    if Settings.ShowFOV then
        FOVCircle.Position = Player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        FOVFrame.Size = UDim2.new(0, Settings.AimRadius * 2, 0, Settings.AimRadius * 2)
        FOVImage.ImageTransparency = ClosestPlayer and 0.2 or 0.7
    else
        FOVImage.ImageTransparency = 1
    end
    
    if ClosestPlayer and ClosestPlayer.Character and ClosestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TargetPart = ClosestPlayer.Character:FindFirstChild("Head") or ClosestPlayer.Character.HumanoidRootPart
        local Velocity = ClosestPlayer.Character.HumanoidRootPart.Velocity
        local PingFactor = AntiBanModule.FakeTelemetry.FakePing and (AntiBanModule.FakeTelemetry.FakePing / 1000) or 0.04
        local RandomSmooth = Settings.AimSmoothness * (Settings.AntiBan and math.random(90, 110) / 100 or 1)
        local PredictedPos = TargetPart.Position + Velocity * (RandomSmooth + PingFactor * 1.5)
        local MousePos = Camera:WorldToViewportPoint(PredictedPos)
        local DeltaX = (MousePos.X - Mouse.X) * RandomSmooth
        local DeltaY = (MousePos.Y - Mouse.Y) * RandomSmooth
        mousemoverel(DeltaX, DeltaY)
    end
    
    StatusBar.Text = string.format("FPS: %.1f | Mục tiêu: %d | Rủi ro: %s", 1 / RunService.RenderStepped:Wait(), TargetCount, AntiBanModule.RiskLevel)
end

-- Mở Rộng Hitbox Cực Đại
local HitboxCache = {}
local function ExpandHitbox()
    if not Settings.ExpandHitbox then
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
                if v.Character:FindFirstChild("KURO_Particles") then
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
            local RandomSize = Settings.HitboxSize * (Settings.AntiBan and math.random(95, 105) / 100 or 1)
            local DynamicSize = Settings.DynamicHitbox and math.clamp(RandomSize * (1 + (60 - Distance) / 20), RandomSize, RandomSize * 2) or RandomSize
            
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
                ParticleEmitter.Texture = "rbxassetid://243098098"
                ParticleEmitter.Size = NumberSequence.new(0.3)
                ParticleEmitter.Transparency = NumberSequence.new(0.6)
                ParticleEmitter.Lifetime = NumberRange.new(0.4, 0.8)
                ParticleEmitter.Rate = 8
                ParticleEmitter.Color = ColorSequence.new(HITBOX_COLORS[Settings.HitboxColor])
                ParticleEmitter.Parent = v.Character.HumanoidRootPart
            end
        end
    end
end

-- Show Hitbox (Sửa lỗi)
local function ShowHitbox()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("KURO_Highlight") then
            v.Character.KURO_Highlight:Destroy()
        end
    end
    
    while Settings.ShowHitbox do
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if Settings.TeamFilter and v.Team == Player.Team then
                    if v.Character:FindFirstChild("KURO_Highlight") then
                        v.Character.KURO_Highlight:Destroy()
                    end
                    continue
                end
                local Highlight = v.Character:FindFirstChild("KURO_Highlight") or Instance.new("Highlight")
                Highlight.Name = "KURO_Highlight"
                Highlight.FillColor = HITBOX_COLORS[Settings.HitboxColor]
                Highlight.OutlineColor = Color3.new(1, 1, 1)
                Highlight.FillTransparency = 0.4
                Highlight.OutlineTransparency = 0
                Highlight.Adornee = v.Character
                Highlight.Parent = v.Character
                Highlight.Enabled = true
            end
        end
        wait(0.1)
    end
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("KURO_Highlight") then
            v.Character.KURO_Highlight:Destroy()
        end
    end
end

-- Hiển thị phạm vi tấn công
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

-- Phần tử giao diện
local function CreateButton(Text, YPos, Setting, Parent, Callback)
    local Button = Instance.new("TextButton")
    Button.Position = UDim2.new(0.05, 0, YPos, 0)
    Button.Size = UDim2.new(0.9, 0, 0, 30)
    Button.Text = Text .. ": " .. (Settings[Setting] and "BẬT" or "TẮT")
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    Button.BackgroundTransparency = 0.5
    Button.BorderSizePixel = 0
    Button.TextScaled = true
    Button.Font = Enum.Font.SourceSansPro
    Button.Parent = Parent
    Button.ZIndex = 5
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Button
    
    local UIStrokeBtn = Instance.new("UIStroke")
    UIStrokeBtn.Color = Color3.new(0, 0.75, 1)
    UIStrokeBtn.Thickness = 1
    UIStrokeBtn.Transparency = 0.5
    UIStrokeBtn.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.new(0, 0.75, 1), BackgroundTransparency = 0.3}):Play()
        TweenService:Create(UIStrokeBtn, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Settings[Setting] and Color3.new(0, 0.5, 0.8) or Color3.new(0.15, 0.15, 0.15), BackgroundTransparency = 0.5}):Play()
        TweenService:Create(UIStrokeBtn, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
        Settings[Setting] = not Settings[Setting]
        Button.Text = Text .. ": " .. (Settings[Setting] and "BẬT" or "TẮT")
        Button.BackgroundColor3 = Settings[Setting] and Color3.new(0, 0.5, 0.8) or Color3.new(0.15, 0.15, 0.15)
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
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = Parent
    SliderFrame.ZIndex = 5
    
    local Label = Instance.new("TextLabel")
    Label.Text = Text .. ": " .. Settings[Setting]
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextScaled = true
    Label.Font = Enum.Font.SourceSansPro
    Label.Parent = SliderFrame
    Label.ZIndex = 6
    
    local Slider = Instance.new("TextButton")
    Slider.Text = ""
    Slider.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    Slider.Size = UDim2.new(1, 0, 0, 8)
    Slider.Position = UDim2.new(0, 0, 0, 25)
    Slider.Parent = SliderFrame
    Slider.ZIndex = 6
    
    local UICornerSlider = Instance.new("UICorner")
    UICornerSlider.CornerRadius = UDim.new(0, 4)
    UICornerSlider.Parent = Slider
    
    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.new(0, 0.75, 1)
    Fill.Size = UDim2.new((Settings[Setting] - Min) / (Max - Min), 0, 1, 0)
    Fill.Parent = Slider
    Fill.ZIndex = 7
    
    local UICornerFill = Instance.new("UICorner")
    UICornerFill.CornerRadius = UDim.new(0, 4)
    UICornerFill.Parent = Fill
    
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
    Dropdown.Size = UDim2.new(0.9, 0, 0, 30)
    Dropdown.TextColor3 = Color3.new(1, 1, 1)
    Dropdown.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    Dropdown.BackgroundTransparency = 0.5
    Dropdown.TextScaled = true
    Dropdown.Font = Enum.Font.SourceSansPro
    Dropdown.Parent = Parent
    Dropdown.ZIndex = 5
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Dropdown
    
    local UIStrokeBtn = Instance.new("UIStroke")
    UIStrokeBtn.Color = Color3.new(0, 0.75, 1)
    UIStrokeBtn.Thickness = 1
    UIStrokeBtn.Transparency = 0.5
    UIStrokeBtn.Parent = Dropdown
    
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Size = UDim2.new(1, 0, 0, #Options * 30)
    OptionFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    OptionFrame.BackgroundTransparency = 0.5
    OptionFrame.Visible = false
    OptionFrame.Parent = Dropdown
    OptionFrame.ZIndex = 6
    
    local UICornerOption = Instance.new("UICorner")
    UICornerOption.CornerRadius = UDim.new(0, 8)
    UICornerOption.Parent = OptionFrame
    
    for i, option in ipairs(Options) do
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Text = option
        OptionBtn.Size = UDim2.new(1, 0, 0, 30)
        OptionBtn.Position = UDim2.new(0, 0, (i-1)/#Options, 0)
        OptionBtn.TextColor3 = Color3.new(1, 1, 1)
        OptionBtn.BackgroundTransparency = 0.7
        OptionBtn.TextScaled = true
        OptionBtn.Font = Enum.Font.SourceSansPro
        OptionBtn.Parent = OptionFrame
        OptionBtn.ZIndex = 7
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

-- Quản lý tab
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
    tab.ZIndex = 4
end
Tabs.Aim.Visible = true

local TabButtons = {}
local function CreateTabButton(Text, XPos, Tab)
    local Button = Instance.new("TextButton")
    Button.Text = Text
    Button.Size = UDim2.new(0.25, -2, 1, -5)
    Button.Position = UDim2.new(XPos, 0, 0, 3)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    Button.BackgroundTransparency = 0.5
    Button.TextScaled = true
    Button.Font = Enum.Font.SourceSansPro
    Button.Parent = TabFrame
    Button.ZIndex = 4
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Button
    
    local UIStrokeBtn = Instance.new("UIStroke")
    UIStrokeBtn.Color = Color3.new(0, 0.75, 1)
    UIStrokeBtn.Thickness = 1
    UIStrokeBtn.Transparency = 0.5
    UIStrokeBtn.Parent = Button
    UIStrokeBtn.Name = "UIStroke"
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.new(0, 0.75, 1), BackgroundTransparency = 0.3}):Play()
        TweenService:Create(UIStrokeBtn, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Tabs[Tab].Visible and Color3.new(0, 0.5, 0.8) or Color3.new(0.15, 0.15, 0.15), BackgroundTransparency = 0.5}):Play()
        TweenService:Create(UIStrokeBtn, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        SoundService:PlayLocalSound(ClickSound)
        for _, t in pairs(Tabs) do
            t.Visible = false
        end
        Tabs[Tab].Visible = true
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
            b:FindFirstChild("UIStroke").Transparency = 0.5
        end
        Button.BackgroundColor3 = Color3.new(0, 0.5, 0.8)
        Button:FindFirstChild("UIStroke").Transparency = 0
    end)
    table.insert(TabButtons, Button)
end

CreateTabButton("Ngắm", 0, "Aim")
CreateTabButton("Hitbox", 0.25, "Hitbox")
CreateTabButton("Hình ảnh", 0.5, "Visuals")
CreateTabButton("Anti-Ban", 0.75, "AntiBan")

-- Điền nội dung tab
CreateButton("Silent Aim [Q]", 0.05, "SilentAim", Tabs.Aim)
CreateButton("Hiển thị FOV [E]", 0.15, "ShowFOV", Tabs.Aim)
CreateButton("Lọc đội", 0.25, "TeamFilter", Tabs.Aim)
CreateButton("Khóa mục tiêu", 0.35, "AimLock", Tabs.Aim)
CreateDropdown("Ưu tiên ngắm", 0.45, {"Gần nhất", "Máu thấp", "Headshot"}, "AimPriority", Tabs.Aim, function(option)
    if option == "Gần nhất" then
        Settings.AimPriority = "Closest"
    elseif option == "Máu thấp" then
        Settings.AimPriority = "LowHealth"
    elseif option == "Headshot" then
        Settings.AimPriority = "Headshot"
    end
end)
CreateSlider("Tầm ngắm", 0.55, 20, 200, DEFAULT_AIM_RADIUS, "AimRadius", Tabs.Aim)
CreateSlider("Độ mượt ngắm", 0.7, 0.03, 0.15, DEFAULT_SMOOTHNESS, "AimSmoothness", Tabs.Aim)

CreateButton("Mở rộng Hitbox [R]", 0.05, "ExpandHitbox", Tabs.Hitbox)
CreateButton("Hitbox động", 0.15, "DynamicHitbox", Tabs.Hitbox)
CreateButton("Hiệu ứng Hitbox", 0.25, "HitboxParticles", Tabs.Hitbox)
CreateSlider("Kích thước Hitbox", 0.35, 1, 4, DEFAULT_HITBOX_SIZE, "HitboxSize", Tabs.Hitbox)

CreateButton("Hiển thị Hitbox [T]", 0.05, "ShowHitbox", Tabs.Visuals, function()
    if Settings.ShowHitbox then
        coroutine.wrap(ShowHitbox)()
    end
end)
CreateButton("Hiển thị phạm vi [Y]", 0.15, "ShowAttackRange", Tabs.Visuals, function()
    if Settings.ShowAttackRange then
        coroutine.wrap(ShowAttackRange)()
    end
end)
CreateDropdown("Loại vũ khí", 0.25, {"Kiếm", "Giáo", "Cung"}, "WeaponMode", Tabs.Visuals, function(option)
    if option == "Kiếm" then
        Settings.WeaponMode = "Sword"
        Settings.AttackRange = WEAPON_RANGES.Sword
    elseif option == "Giáo" then
        Settings.WeaponMode = "Spear"
        Settings.AttackRange = WEAPON_RANGES.Spear
    elseif option == "Cung" then
        Settings.WeaponMode = "Bow"
        Settings.AttackRange = WEAPON_RANGES.Bow
    end
end)
CreateDropdown("Màu Hitbox", 0.35, {"Đỏ", "Xanh", "Tím"}, "HitboxColor", Tabs.Visuals, function(option)
    if option == "Đỏ" then
        Settings.HitboxColor = "Red"
    elseif option == "Xanh" then
        Settings.HitboxColor = "Blue"
    elseif option == "Tím" then
        Settings.HitboxColor = "Purple"
    end
end)

CreateButton("Anti-Ban Siêu Tinh Vi", 0.05, "AntiBan", Tabs.AntiBan, function()
    if Settings.AntiBan then
        AntiBanModule.SimulateProtection()
        coroutine.wrap(AntiBanModule.SimulatePeriodicCheck)()
        coroutine.wrap(AntiBanModule.SimulatePacketObfuscation)()
        ProtectionBarFrame.Parent = Tabs.AntiBan
        ProtectionLabel.Parent = Tabs.AntiBan
    else
        AntiBanModule.Active = false
        AntiBanModule.Log("Anti-Ban tắt.")
        ProtectionBarFrame.Parent = nil
        ProtectionLabel.Parent = nil
        Settings.ProtectionProgress = 0
    end
end)
local RiskLabel = Instance.new("TextLabel")
RiskLabel.Text = "Rủi ro ban giả: " .. Settings.FakeBanRisk .. "% (" .. AntiBanModule.RiskLevel .. ")"
RiskLabel.TextColor3 = Color3.new(1, 1, 1)
RiskLabel.Size = UDim2.new(0.9, 0, 0, 25)
RiskLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
RiskLabel.BackgroundTransparency = 1
RiskLabel.TextScaled = true
RiskLabel.Font = Enum.Font.SourceSansPro
RiskLabel.Parent = Tabs.AntiBan
RiskLabel.ZIndex = 5

-- Kiểm tra an toàn
local function Initialize()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        warn("[KUROHUB] Đợi nhân vật trong " .. GAME_NAME .. "...")
        Player.CharacterAdded:Wait()
    end
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    LoadSettings()
    AntiBanModule.Log("KUROHUB v2.4 khởi tạo cho " .. GAME_NAME .. ".")
end

-- Vòng lặp chính
local frameCount = 0
RunService.RenderStepped:Connect(function(delta)
    frameCount = frameCount + 1
    if frameCount % 2 == 0 then
        pcall(SilentAim)
        pcall(ExpandHitbox)
    end
    RiskLabel.Text = "Rủi ro ban giả: " .. Settings.FakeBanRisk .. "% (" .. AntiBanModule.RiskLevel .. ")"
    ProtectionLabel.Text = "Bypass: " .. Settings.ProtectionProgress .. "%"
    ProtectionBarFill.Size = UDim2.new(Settings.ProtectionProgress / 100, 0, 1, 0)
end)

-- Dọn dẹp
Player.AncestryChanged:Connect(function()
    if not Player:IsDescendantOf(game) then
        KUROHUB:Destroy()
        FOVCircle:Destroy()
    end
end)

-- Phím tắt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.AimKey then
        Settings.SilentAim = not Settings.SilentAim
        SaveSettings()
        AntiBanModule.Log("Silent Aim: " .. (Settings.SilentAim and "BẬT" or "TẮT"))
    elseif input.KeyCode == Enum.KeyCode.E then
        Settings.ShowFOV = not Settings.ShowFOV
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.R then
        Settings.ExpandHitbox = not Settings.ExpandHitbox
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.T then
        Settings.ShowHitbox = not Settings.ShowHitbox
        SaveSettings()
        if Settings.ShowHitbox then
            coroutine.wrap(ShowHitbox)()
        end
    elseif input.KeyCode == Enum.KeyCode.Y then
        Settings.ShowAttackRange = not Settings.ShowAttackRange
        SaveSettings()
        if Settings.ShowAttackRange then
            coroutine.wrap(ShowAttackRange)()
        end
    elseif input.KeyCode == Enum.KeyCode.H then
        KUROHUB.Enabled = not KUROHUB.Enabled
    elseif input.KeyCode == Enum.KeyCode.M then
        ToggleMinimize()
    end
end)

-- Khởi tạo
Initialize()
