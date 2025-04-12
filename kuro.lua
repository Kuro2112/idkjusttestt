--[[
    Dual Warrior Script với hệ thống Anti-Ban nâng cao
    Tính năng chính:
    - AutoFarm thông minh với AI thay đổi mục tiêu ngẫu nhiên
    - Hệ thống chống phát hiện đa lớp
    - Tự động né tránh khi máu thấp
    - Hành vi người chơi mô phỏng thực tế
    - Tự động bật các kỹ năng Dual Warrior
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Cấu hình
local Settings = {
    AutoFarm = true,
    AutoDodge = true,
    AutoSkills = true,
    HealthThreshold = 0.3, -- Tự động né khi máu dưới 30%
    HumanLikeDelay = true, -- Thêm độ trễ giống người thật
    RandomMovement = true, -- Di chuyển ngẫu nhiên khi không combat
    MaxTargetDistance = 100, -- Khoảng cách tối đa để chọn mục tiêu
    SafeMode = true -- Giảm tốc độ khi phát hiện admin
}

-- Hệ thống Anti-Ban
local AntiBan = {
    DetectionCount = 0,
    LastDetection = 0,
    SafeActions = {
        "RandomEmote",
        "RandomJump",
        "PauseCombat",
        "ChangeTarget"
    },
    BlacklistedPlayers = {}, -- Danh sách admin/sysop
    LastPosition = nil,
    PositionCheckInterval = 30 -- Kiểm tra vị trí mỗi 30s
}

-- Kỹ năng Dual Warrior
local DualWarriorSkills = {
    "SwordSlash",
    "DualStrike",
    "Whirlwind",
    "CounterAttack"
}

-- Hàm mô phỏng hành vi người chơi
local function HumanLikeAction()
    if Settings.HumanLikeDelay then
        wait(math.random(0.1, 0.8))
    end
    
    -- Thỉnh thoảng thực hiện hành động ngẫu nhiên
    if math.random(1, 100) <= 5 then
        local action = AntiBan.SafeActions[math.random(1, #AntiBan.SafeActions)]
        if action == "RandomEmote" then
            game:GetService("VirtualUser"):SetKeyEvent(true, "E", false, game)
        elseif action == "RandomJump" then
            game:GetService("VirtualUser"):SetKeyEvent(true, "Space", false, game)
        end
    end
end

-- Hệ thống phát hiện admin
local function CheckForAdmins()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            -- Kiểm tra tên admin hoặc badge đặc biệt
            if table.find(AntiBan.BlacklistedPlayers, player.Name) then
                return true
            end
        end
    end
    return false
end

-- Hệ thống né tránh khi gặp nguy hiểm
local function EmergencyDodge()
    if Settings.AutoDodge and (Humanoid.Health/Humanoid.MaxHealth) < Settings.HealthThreshold then
        -- Dịch chuyển đến vị trí an toàn gần nhất
        local safeSpot = FindNearestSafeSpot()
        if safeSpot then
            HumanoidRootPart.CFrame = safeSpot
            wait(2)
            return true
        end
    end
    return false
end

-- Hàm tìm mục tiêu thông minh
local function FindOptimalTarget()
    local optimalTarget = nil
    local minDistance = Settings.MaxTargetDistance
    
    for _, enemy in ipairs(game:GetService("Workspace").Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                optimalTarget = enemy
                minDistance = distance
            end
        end
    end
    
    return optimalTarget
end

-- Hàm sử dụng kỹ năng Dual Warrior
local function UseSkill(skillName)
    if not Settings.AutoSkills then return end
    
    -- Mô phỏng thời gian cast skill
    HumanLikeAction()
    
    -- Gọi remote sử dụng skill (thay bằng remote thực tế trong game)
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CombatRemote:FireServer(
            "UseSkill",
            skillName,
            HumanoidRootPart.CFrame
        )
    end)
    
    if not success then
        warn("Skill error: "..err)
    end
end

-- Hệ thống AutoFarm chính
local function CoreCombatLoop()
    while Settings.AutoFarm do
        HumanLikeAction()
        
        -- Kiểm tra trạng thái an toàn
        if CheckForAdmins() and Settings.SafeMode then
            warn("[ANTI-BAN] Admin detected! Pausing operations...")
            wait(10)
            continue
        end
        
        -- Tự động né tránh khi nguy hiểm
        if EmergencyDodge() then
            continue
        end
        
        -- Tìm mục tiêu tối ưu
        local target = FindOptimalTarget()
        if target then
            -- Di chuyển đến mục tiêu
            HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            
            -- Sử dụng kỹ năng ngẫu nhiên
            UseSkill(DualWarriorSkills[math.random(1, #DualWarriorSkills)])
            
            -- Tấn công cơ bản
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
        elseif Settings.RandomMovement then
            -- Di chuyển ngẫu nhiên nếu không có mục tiêu
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
        end
        
        wait()
    end
end

-- Khởi chạy hệ thống
local function Initialize()
    warn("Dual Warrior Script initialized with advanced Anti-Ban system")
    
    -- Thiết lập kết nối bảo vệ
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        Character = Player.Character
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end)
    
    -- Bắt đầu vòng lặp chính
    spawn(CoreCombatLoop)
    
    -- Hệ thống kiểm tra vị trí chống teleport detection
    spawn(function()
        while wait(AntiBan.PositionCheckInterval) do
            if AntiBan.LastPosition and (HumanoidRootPart.Position - AntiBan.LastPosition).Magnitude > 500 then
                warn("[ANTI-BAN] Large position jump detected! Adding random delay...")
                wait(math.random(5, 15))
            end
            AntiBan.LastPosition = HumanoidRootPart.Position
        end
    end)
end
-- Thêm phần này vào trước hàm Initialize()
local function CreateGUI()
    -- Library UI
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.CreateLib("Dual Warrior Pro", "Sentinel")
    
    -- Tab chính
    local MainTab = Window:NewTab("Auto Farm")
    local CombatSection = MainTab:NewSection("Combat Settings")
    local SkillSection = MainTab:NewSection("Skill Settings")
    
    -- Tab bảo mật
    local SecurityTab = Window:NewTab("Security")
    local AntiBanSection = SecurityTab:NewSection("Anti-Ban System")
    local SafetySection = SecurityTab:NewSection("Safety Features")
    
    -- Tab thông tin
    local InfoTab = Window:NewTab("Info")
    local CreditsSection = InfoTab:NewSection("Credits")
    
    -- ===== CÁC CHỨC NĂNG CHÍNH =====
    -- Auto Farm
    CombatSection:NewToggle("Auto Farm", "Tự động tấn công quái", function(state)
        Settings.AutoFarm = state
        if state then
            spawn(CoreCombatLoop)
        end
    end)
    
    CombatSection:NewSlider("Khoảng cách mục tiêu", "MaxDistance", 500, 20, function(value)
        Settings.MaxTargetDistance = value
    end)
    
    -- Kỹ năng
    SkillSection:NewToggle("Tự động dùng skill", "Kích hoạt combo skill", function(state)
        Settings.AutoSkills = state
    end)
    
    SkillSection:NewDropdown("Ưu tiên skill", "Chọn skill chính", DualWarriorSkills, function(selected)
        _G.PrioritySkill = selected
    end)
    
    -- Bảo mật
    AntiBanSection:NewToggle("Chế độ an toàn", "Tự động tắt khi có admin", function(state)
        Settings.SafeMode = state
    end)
    
    AntiBanSection:NewToggle("Giả lập hành vi", "Hành động ngẫu nhiên", function(state)
        Settings.HumanLikeDelay = state
    end)
    
    SafetySection:NewToggle("Tự động né", "Khi máu thấp", function(state)
        Settings.AutoDodge = state
    end)
    
    SafetySection:NewSlider("Ngưỡng máu", "Health%", 100, 10, function(value)
        Settings.HealthThreshold = value/100
    end)
    
    -- Thông tin
    CreditsSection:NewLabel("Phiên bản: 1.0.3")
    CreditsSection:NewLabel("Cập nhật: 15/07/2024")
    CreditsSection:NewLabel("Tác giả: Kuro2112")
end

-- Sửa hàm Initialize() thành:
local function Initialize()
    warn("Dual Warrior Script initialized")
    CreateGUI() -- Tạo giao diện
    
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        Character = Player.Character
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end)
    
    spawn(CoreCombatLoop)
    spawn(PositionCheckThread)
end
-- Kích hoạt script
Initialize()
-- VER: 1.0.3 | Last Updated: 2024-07-15
-- This file is part of game optimization suite
