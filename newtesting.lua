-- Kuro07Hub - APEX 3 DUEL Warriors Script
-- Phiên bản: 1.0.0
-- Cập nhật: 12/04/2025

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Cài đặt
local Settings = {
    AutoFarm = false,
    AutoDodge = true,
    AutoSkills = true,
    ShowHitbox = true,
    ShowRange = true,
    SafeMode = true,
    HumanLikeDelay = true,
    MaxTargetDistance = 50,
    HealthThreshold = 0.3,
    PrioritySkill = "Skill1"
}

local DualWarriorSkills = {"Skill1", "Skill2", "Skill3", "Ultimate"}

-- Anti-ban system
local function AntiBanCheck()
    while Settings.SafeMode do
        wait(math.random(10, 30))
        
        -- Kiểm tra admin trong server
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player:GetRankInGroup(1) > 100 then -- GroupId của Roblox
                warn("[ANTI-BAN] Phát hiện admin, tự động tắt script")
                Settings.AutoFarm = false
                Settings.AutoSkills = false
                return
            end
        end
        
        -- Hành vi ngẫu nhiên
        if Settings.HumanLikeDelay then
            wait(math.random(1, 3))
            if math.random(1, 10) > 7 then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end
    end
end

-- Tự động né
local function AutoDodge()
    while Settings.AutoDodge do
        wait(0.1)
        if Humanoid.Health/Humanoid.MaxHealth < Settings.HealthThreshold then
            -- Nhấn phím né (giả sử là phím Q)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Q, false, game)
            wait(0.2)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            
            -- Di chuyển ngẫu nhiên
            local moveDir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
            Humanoid:MoveTo(HumanoidRootPart.Position + moveDir * 10)
            wait(1)
        end
    end
end

-- Tự động aim skill
local function FindBestTarget()
    local closest = nil
    local dist = Settings.MaxTargetDistance
    
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local distance = (HumanoidRootPart.Position - targetHRP.Position).Magnitude
            
            if distance < dist then
                closest = targetHRP
                dist = distance
            end
        end
    end
    
    return closest
end

local function UseSkill(skillName)
    if not Settings.AutoSkills then return end
    
    local target = FindBestTarget()
    if target then
        -- Aim vào mục tiêu
        HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, target.Position)
        
        -- Kích hoạt skill (giả sử các skill được kích hoạt bằng phím 1-4)
        local keyCode
        if skillName == "Skill1" then
            keyCode = Enum.KeyCode.One
        elseif skillName == "Skill2" then
            keyCode = Enum.KeyCode.Two
        elseif skillName == "Skill3" then
            keyCode = Enum.KeyCode.Three
        elseif skillName == "Ultimate" then
            keyCode = Enum.KeyCode.Four
        end
        
        if keyCode then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, keyCode, false, game)
            wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, keyCode, false, game)
        end
    end
end

-- Hiển thị tầm đánh và hitbox
local function CreateVisuals()
    -- Tầm đánh
    local rangeCircle = Instance.new("Part")
    rangeCircle.Name = "RangeVisual"
    rangeCircle.Anchored = true
    rangeCircle.CanCollide = false
    rangeCircle.Transparency = 0.7
    rangeCircle.Color = Color3.fromRGB(0, 255, 255)
    rangeCircle.Size = Vector3.new(1, 0.1, 1)
    rangeCircle.Shape = Enum.PartType.Cylinder
    rangeCircle.TopSurface = Enum.SurfaceType.Smooth
    rangeCircle.BottomSurface = Enum.SurfaceType.Smooth
    rangeCircle.Parent = workspace
    
    local rangeMesh = Instance.new("SpecialMesh", rangeCircle)
    rangeMesh.MeshType = Enum.MeshType.Cylinder
    rangeMesh.Scale = Vector3.new(Settings.MaxTargetDistance * 2, 0.1, Settings.MaxTargetDistance * 2)
    
    -- Hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "HitboxVisual"
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Transparency = 0.8
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.Size = Vector3.new(5, 5, 5)
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Parent = workspace
    
    -- Cập nhật vị trí
    game:GetService("RunService").Heartbeat:Connect(function()
        if Character and HumanoidRootPart then
            rangeCircle.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(math.pi/2, 0, 0)
            
            local target = FindBestTarget()
            if target then
                hitbox.CFrame = CFrame.new(target.Position)
                hitbox.Transparency = 0.5
            else
                hitbox.Transparency = 0.8
            end
        end
    end)
end

-- Core combat loop
local function CoreCombatLoop()
    while Settings.AutoFarm do
        if Settings.PrioritySkill then
            UseSkill(Settings.PrioritySkill)
        end
        
        -- Sử dụng các skill khác ngẫu nhiên
        if math.random(1, 10) > 7 then
            UseSkill(DualWarriorSkills[math.random(1, #DualWarriorSkills)])
        end
        
        -- Delay ngẫu nhiên để tránh bị phát hiện
        local delay = Settings.HumanLikeDelay and math.random(0.5, 1.5) or 0.1
        wait(delay)
    end
end

-- Giao diện
local function CreateGUI()
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.CreateLib("Kuro07Hub - APEX 3 DUEL", "Sentinel")
    
    -- Tab chính
    local MainTab = Window:NewTab("Auto Farm")
    local CombatSection = MainTab:NewSection("Combat Settings")
    local SkillSection = MainTab:NewSection("Skill Settings")
    local VisualSection = MainTab:NewSection("Visual Settings")
    
    -- Tab bảo mật
    local SecurityTab = Window:NewTab("Security")
    local AntiBanSection = SecurityTab:NewSection("Anti-Ban System")
    local SafetySection = SecurityTab:NewSection("Safety Features")
    
    -- Tab thông tin
    local InfoTab = Window:NewTab("Info")
    local CreditsSection = InfoTab:NewSection("Credits")
    
    -- Combat
    CombatSection:NewToggle("Auto Farm", "Tự động tấn công", function(state)
        Settings.AutoFarm = state
        if state then
            spawn(CoreCombatLoop)
        end
    end)
    
    CombatSection:NewSlider("Khoảng cách mục tiêu", "MaxDistance", 100, 10, function(value)
        Settings.MaxTargetDistance = value
        if workspace:FindFirstChild("RangeVisual") then
            workspace.RangeVisual.Mesh.Scale = Vector3.new(value * 2, 0.1, value * 2)
        end
    end)
    
    -- Skill
    SkillSection:NewToggle("Tự động dùng skill", "Kích hoạt combo skill", function(state)
        Settings.AutoSkills = state
    end)
    
    SkillSection:NewDropdown("Ưu tiên skill", "Chọn skill chính", DualWarriorSkills, function(selected)
        Settings.PrioritySkill = selected
    end)
    
    -- Visual
    VisualSection:NewToggle("Hiện tầm đánh", "Hiển thị phạm vi tấn công", function(state)
        Settings.ShowRange = state
        if workspace:FindFirstChild("RangeVisual") then
            workspace.RangeVisual.Transparency = state and 0.7 or 1
        end
    end)
    
    VisualSection:NewToggle("Hiện hitbox", "Hiển thị hitbox mục tiêu", function(state)
        Settings.ShowHitbox = state
        if workspace:FindFirstChild("HitboxVisual") then
            workspace.HitboxVisual.Transparency = state and 0.8 or 1
        end
    end)
    
    -- Bảo mật
    AntiBanSection:NewToggle("Chế độ an toàn", "Tự động tắt khi có admin", function(state)
        Settings.SafeMode = state
        if state then
            spawn(AntiBanCheck)
        end
    end)
    
    AntiBanSection:NewToggle("Giả lập hành vi", "Hành động ngẫu nhiên", function(state)
        Settings.HumanLikeDelay = state
    end)
    
    SafetySection:NewToggle("Tự động né", "Khi máu thấp", function(state)
        Settings.AutoDodge = state
        if state then
            spawn(AutoDodge)
        end
    end)
    
    SafetySection:NewSlider("Ngưỡng máu", "Health%", 100, 10, function(value)
        Settings.HealthThreshold = value/100
    end)
    
    -- Thông tin
    CreditsSection:NewLabel("Phiên bản: 1.0.0")
    CreditsSection:NewLabel("Cập nhật: 12/04/2025")
    CreditsSection:NewLabel("Tác giả: Kuro07Hub")
end

-- Khởi động
local function Initialize()
    warn("Kuro07Hub - APEX 3 DUEL Warriors Script initialized")
    
    Player.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = newChar:WaitForChild("Humanoid")
        HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    end)
    
    CreateGUI()
    CreateVisuals()
    spawn(AntiBanCheck)
    spawn(AutoDodge)
    spawn(CoreCombatLoop)
end
local redzhubMenu = {
    title = "KUROHUB",
    sections = {
        {name = "Auto Farm", description = "Tự động thu thập vật phẩm và tài nguyên"},
        {name = "Auto Dodge", description = "Tự động né tránh các đòn đánh"},
        {name = "Skill Aim Bot", description = "Hỗ trợ ngắm chính xác kỹ năng"},
        {name = "Hitbox & Range Visuals", description = "Hiển thị phạm vi và khung tấn công"},
        {name = "Anti-Ban & Humanizer", description = "Bảo vệ chống bị khóa tài khoản và tự nhiên hóa hành động"},
    }
}

function renderMenu(menu)
    print(menu.title)
    for _, section in ipairs(menu.sections) do
        print("✅ " .. section.name)
        print("   " .. section.description)
    end
end

renderMenu(redzhubMenu)

-- Chạy script
Initialize()
