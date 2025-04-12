--[[
    Script Hitbox, Mở Rộng Hitbox và Silent Aim với Anti-Ban nâng cao
    Phiên bản: Shadow 2.4 (Fake Legit)
--]]

local _G = _G
local table = table
local string = string
local math = math
local os = os
local pcall = pcall
local require = require
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local type = type
local next = next
local assert = assert
local error = error
local select = select
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local getmetatable = getmetatable
local collectgarbage = collectgarbage

-- Fake environment
local fakeEnv = {
    print = function(...) 
        local args = {...}
        for i=1, #args do
            args[i] = tostring(args[i])
        end
        _G.print(table.concat(args, "\t"))
    end,
    warn = function(...) 
        -- Fake warning function
    end,
    error = function(msg, level)
        -- Fake error function
    end
}

setfenv(1, setmetatable(fakeEnv, {__index = _G}))

-- Anti-tamper measures
local function generateRandomSeed()
    return tonumber(tostring(os.time()):reverse():sub(1,6)) * math.pi
end

local securityToken = "S3CR3T_"..tostring(generateRandomSeed()):sub(1,8)
local heartbeatInterval = math.random(30000, 60000)
local lastHeartbeat = os.clock()

-- Fake legit functions
local function fakeLegitFunction()
    -- Random legit-looking operations
    local x = math.random(1,100)
    local y = math.random(1,100)
    return x * y / math.random(1,10)
end

-- Anti-debug techniques
local function antiDebugCheck()
    -- Check for common debugger artifacts
    if debug or debugger then
        return true
    end
    
    -- Check for abnormal timing
    local start = os.clock()
    for i=1,1000000 do end
    local delta = os.clock() - start
    if delta > 0.1 then -- Normal execution should be much faster
        return true
    end
    
    return false
end

-- Memory obfuscation
local function memObfuscate(data)
    local result = {}
    for i=1, #data do
        result[i] = string.char(data:byte(i) ~ 0x55)
    end
    return table.concat(result)
end

-- Settings with obfuscation
local settings = memObfuscate([[
    hitboxVisualizer = true
    hitboxColor = {255, 0, 0, 100}
    hitboxScale = 1.0
    silentAim = false
    silentAimFOV = 30
    silentAimBone = "Head"
    silentAimKey = "CAPSLOCK"
    antiBanLevel = 3
]])

-- Dynamic code evaluation with sandboxing
local function safeEval(code)
    local chunk = loadstring("return "..code)
    if chunk then
        setfenv(chunk, fakeEnv)
        local success, result = pcall(chunk)
        if success then
            return result
        end
    end
    return nil
end

settings = safeEval(settings)

-- Heartbeat system
local function sendHeartbeat()
    -- Fake network activity
    fakeLegitFunction()
    lastHeartbeat = os.clock()
    
    -- Randomize next heartbeat
    heartbeatInterval = math.random(30000, 60000)
end

-- Advanced hitbox visualization with randomization
local function drawHitbox(entity, scale)
    if not entity or not entity.health or entity.health <= 0 then return end
    
    -- Randomize some parameters to avoid detection
    local rndScale = scale * (0.95 + math.random() * 0.1)
    local rndColor = {
        math.min(255, settings.hitboxColor[1] + math.random(-10,10)),
        math.min(255, settings.hitboxColor[2] + math.random(-10,10)),
        math.min(255, settings.hitboxColor[3] + math.random(-10,10)),
        settings.hitboxColor[4]
    }
    
    local model = entity.model
    local min, max = getModelDimensions(model)
    if not min or not max then return end
    
    -- Calculate hitbox with scale
    local center = (min + max) * 0.5
    local size = (max - min) * 0.5 * rndScale
    
    -- Draw hitbox with slight randomization
    drawBox(center - size, center + size, rndColor)
    
    -- Call legit function occasionally
    if math.random(1,100) > 95 then
        fakeLegitFunction()
    end
end

-- Silent aim with human-like imperfection
local function getBestTarget()
    if not settings.silentAim then return nil end
    
    local localPlayer = getLocalPlayer()
    if not localPlayer then return nil end
    
    local cameraPos = getCameraPosition()
    local cameraDir = getCameraDirection()
    local bestTarget = nil
    local bestAngle = settings.silentAimFOV
    
    -- Add small random delay to mimic human reaction
    if math.random(1,100) > 30 then
        wait(math.random(10,50))
    end
    
    for _, player in ipairs(getPlayers()) do
        if player ~= localPlayer and player.health > 0 then
            local bonePos = getBonePosition(player, settings.silentAimBone)
            if bonePos then
                -- Add slight imperfection
                bonePos = bonePos + Vector3.new(
                    math.random() * 0.05 - 0.025,
                    math.random() * 0.05 - 0.025,
                    math.random() * 0.05 - 0.025
                )
                
                local dirToTarget = (bonePos - cameraPos):normalized()
                local angle = math.deg(math.acos(cameraDir:Dot(dirToTarget)))
                
                if angle < bestAngle then
                    bestAngle = angle
                    bestTarget = player
                end
            end
        end
    end
    
    return bestTarget
end

-- Obfuscated silent aim hook
local silentAimHook = function(originalFunction, ...)
    if settings.silentAim and not antiDebugCheck() then
        local target = getBestTarget()
        if target then
            local bonePos = getBonePosition(target, settings.silentAimBone)
            if bonePos then
                -- Add human-like imperfection
                local imperfection = 0.95 + math.random() * 0.1
                local cameraPos = getCameraPosition()
                local newDirection = (bonePos - cameraPos):normalized() * imperfection
                
                -- Randomize timing
                if math.random(1,100) > 80 then
                    wait(math.random(1,3))
                end
                
                setCameraDirection(newDirection)
            end
        end
    end
    
    -- Call original function with random delay
    if math.random(1,100) > 90 then
        wait(math.random(1,5))
    end
    
    return originalFunction(...)
end

-- Memory cleaning
local function cleanMemory()
    collectgarbage("collect")
    for k,v in pairs(package.loaded) do
        if type(v) == "table" then
            for k2,v2 in pairs(v) do
                if type(v2) == "function" and not string.find(k2, "legit") then
                    v[k2] = nil
                end
            end
        end
    end
end

-- Main function with anti-ban
local function main()
    -- Randomize startup delay
    wait(math.random(1000, 5000))
    
    -- Hook functions with protection
    local success, err = pcall(function()
        hookFunction("fireBullet", silentAimHook)
    end)
    
    if not success then
        return -- Fail silently
    end
    
    -- Main loop with anti-ban measures
    while true do
        -- Process input with randomization
        if isKeyPressed(settings.silentAimKey) then
            settings.silentAim = not settings.silentAim
            wait(math.random(200, 500)) -- Randomized anti-spam
        end
        
        -- Draw hitboxes with randomization
        if settings.hitboxVisualizer and math.random(1,100) > 20 then
            for _, player in ipairs(getPlayers()) do
                drawHitbox(player, settings.hitboxScale)
            end
        end
        
        -- Send heartbeat occasionally
        if os.clock() - lastHeartbeat > heartbeatInterval then
            sendHeartbeat()
        end
        
        -- Clean memory randomly
        if math.random(1,100) > 95 then
            cleanMemory()
        end
        
        -- Call legit functions randomly
        if math.random(1,100) > 85 then
            fakeLegitFunction()
        end
        
        wait(math.random(0, 10)) -- Randomized delay
    end
end

-- Start with anti-detection
local function safeStart()
    -- Initial random delay
    wait(math.random(2000, 10000))
    
    -- Check environment
    if not antiDebugCheck() then
        -- Start in protected mode
        local success, err = pcall(main)
        if not success then
            -- Fail silently
        end
    end
end
-- Orion Library UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Shadow X | Private Cheat",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ShadowXConfig",
    IntroEnabled = true,
    IntroText = "Shadow X Private",
    IntroIcon = "rbxassetid://1234567890" -- Thay bằng icon ID của bạn
})

-- Tab chính
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://1234567890",
    PremiumOnly = false
})

-- Tab Visuals
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://1234567890",
    PremiumOnly = false
})

-- Tab Anti-Ban
local AntiBanTab = Window:MakeTab({
    Name = "Anti-Ban",
    Icon = "rbxassetid://1234567890",
    PremiumOnly = false
})

-- Tab Settings
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://1234567890",
    PremiumOnly = false
})

-- MAIN FEATURES
MainTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        settings.silentAim = Value
        OrionLib:MakeNotification({
            Name = "Silent Aim",
            Content = Value and "Enabled" or "Disabled",
            Image = "rbxassetid://1234567890",
            Time = 3
        })
    end    
})

MainTab:AddSlider({
    Name = "Silent Aim FOV",
    Min = 1,
    Max = 360,
    Default = 30,
    Color = Color3.fromRGB(255,0,0),
    Increment = 1,
    Callback = function(Value)
        settings.silentAimFOV = Value
    end
})

MainTab:AddDropdown({
    Name = "Aim Bone",
    Default = "Head",
    Options = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    Callback = function(Value)
        settings.silentAimBone = Value
    end    
})

-- VISUALS
VisualsTab:AddToggle({
    Name = "Hitbox Visualizer",
    Default = false,
    Callback = function(Value)
        settings.hitboxVisualizer = Value
    end    
})

VisualsTab:AddSlider({
    Name = "Hitbox Scale",
    Min = 0.1,
    Max = 3.0,
    Default = 1.0,
    Color = Color3.fromRGB(0,255,0),
    Increment = 0.1,
    Callback = function(Value)
        settings.hitboxScale = Value
    end
})

VisualsTab:AddColorpicker({
    Name = "Hitbox Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        settings.hitboxColor = {
            Value.R * 255,
            Value.G * 255,
            Value.B * 255,
            100
        }
    end    
})

-- ANTI-BAN
AntiBanTab:AddDropdown({
    Name = "Anti-Ban Level",
    Default = "Medium",
    Options = {"Low", "Medium", "High", "Extreme"},
    Callback = function(Value)
        local levels = {
            ["Low"] = 1,
            ["Medium"] = 2,
            ["High"] = 3,
            ["Extreme"] = 4
        }
        settings.antiBanLevel = levels[Value]
        updateAntiBanSettings()
    end    
})

AntiBanTab:AddToggle({
    Name = "Randomization",
    Default = true,
    Callback = function(Value)
        settings.randomizationEnabled = Value
    end    
})

AntiBanTab:AddToggle({
    Name = "Memory Cleaner",
    Default = true,
    Callback = function(Value)
        settings.memoryCleanerEnabled = Value
    end    
})

-- SETTINGS
SettingsTab:AddKeybind({
    Name = "Silent Aim Keybind",
    Default = Enum.KeyCode.CapsLock,
    Hold = false,
    Callback = function(Key)
        settings.silentAimKey = tostring(Key)
    end    
})

SettingsTab:AddButton({
    Name = "Save Settings",
    Callback = function()
        saveConfig()
        OrionLib:MakeNotification({
            Name = "Settings Saved",
            Content = "Your settings have been saved!",
            Image = "rbxassetid://1234567890",
            Time = 3
        })
    end    
})

SettingsTab:AddButton({
    Name = "Load Settings",
    Callback = function()
        loadConfig()
        OrionLib:MakeNotification({
            Name = "Settings Loaded",
            Content = "Your settings have been loaded!",
            Image = "rbxassetid://1234567890",
            Time = 3
        })
    end    
})

SettingsTab:AddButton({
    Name = "Unload Cheat",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Unloading...",
            Content = "Cheat will unload in 3 seconds",
            Image = "rbxassetid://1234567890",
            Time = 3
        })
        wait(3)
        OrionLib:Destroy()
    end    
})

-- Cập nhật cài đặt Anti-Ban
local function updateAntiBanSettings()
    if settings.antiBanLevel == 1 then -- Low
        settings.randomizationEnabled = false
        settings.memoryCleanerEnabled = false
    elseif settings.antiBanLevel == 2 then -- Medium
        settings.randomizationEnabled = true
        settings.memoryCleanerEnabled = false
    elseif settings.antiBanLevel == 3 then -- High
        settings.randomizationEnabled = true
        settings.memoryCleanerEnabled = true
    elseif settings.antiBanLevel == 4 then -- Extreme
        settings.randomizationEnabled = true
        settings.memoryCleanerEnabled = true
        -- Thêm các biện pháp bảo vệ nâng cao khác
    end
    
    -- Cập nhật UI
    AntiBanTab:UpdateOptions({
        ["Randomization"] = {Default = settings.randomizationEnabled},
        ["Memory Cleaner"] = {Default = settings.memoryCleanerEnabled}
    })
end

-- Lưu cấu hình
local function saveConfig()
    writefile("ShadowXConfig.json", game:GetService("HttpService"):JSONEncode(settings))
end

-- Tải cấu hình
local function loadConfig()
    if isfile("ShadowXConfig.json") then
        settings = game:GetService("HttpService"):JSONDecode(readfile("ShadowXConfig.json"))
        -- Cập nhật UI với các giá trị đã tải
        -- (Cần thêm logic cập nhật cho từng control)
    end
end
-- Khởi tạo
OrionLib:Init()
-- Obfuscated entry point
local entry = memObfuscate("safeStart()")
safeEval(entry)
