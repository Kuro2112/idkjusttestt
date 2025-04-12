local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexsoft/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "APEX 3 DUEL Warriors Hub", HidePremium = true, SaveConfig = true, ConfigFolder = "APEX3Hub"})

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

local Skills = {"Skill1", "Skill2", "Skill3", "Ultimate"}

-- Tab chính
local MainTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        Settings.AutoFarm = state
        if state then
            spawn(function()
                while Settings.AutoFarm do
                    -- Logic Auto Farm
                    wait(1)
                end
            end)
        end
    end
})

MainTab:AddToggle({
    Name = "Auto Dodge",
    Default = true,
    Callback = function(state)
        Settings.AutoDodge = state
        if state then
            spawn(function()
                while Settings.AutoDodge do
                    wait(0.1)
                    if Settings.HealthThreshold and Humanoid.Health / Humanoid.MaxHealth < Settings.HealthThreshold then
                        -- Né tránh
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                        wait(0.2)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    end
                end
            end)
        end
    end
})

MainTab:AddDropdown({
    Name = "Ưu tiên skill",
    Options = Skills,
    Default = "Skill1",
    Callback = function(selected)
        Settings.PrioritySkill = selected
    end
})

MainTab:AddSlider({
    Name = "Khoảng cách mục tiêu",
    Min = 10,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    Callback = function(value)
        Settings.MaxTargetDistance = value
    end
})

-- Tab bảo mật
local SecurityTab = Window:MakeTab({
    Name = "Security",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SecurityTab:AddToggle({
    Name = "Chế độ an toàn",
    Default = true,
    Callback = function(state)
        Settings.SafeMode = state
        if state then
            spawn(function()
                while Settings.SafeMode do
                    wait(math.random(10, 30))
                    -- Kiểm tra admin
                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player:GetRankInGroup(1) > 100 then
                            warn("[ANTI-BAN] Phát hiện admin, tự động tắt script")
                            Settings.AutoFarm = false
                            Settings.AutoSkills = false
                            return
                        end
                    end
                end
            end)
        end
    end
})

-- Tab thông tin
local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddLabel("Phiên bản: 1.0.0")
InfoTab:AddLabel("Cập nhật: 12/04/2025")
InfoTab:AddLabel("Tác giả: Kuro07Hub")

-- Kích hoạt GUI
OrionLib:Init()
