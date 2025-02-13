-- 加载 DiscordLib 库
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
-- 创建窗口
local win = DiscordLib:Window("Baloksxin's script")

-- 创建服务器
local srv = win:Server("Main", "http://www.roblox.com/asset/?id=6031075938")

-- 创建频道
local chnl = srv:Channel("Main")

-- 获取本地玩家
local LocalPlayer = game.Players.LocalPlayer

-- 记录初始速度和 FOV
local initialWalkSpeed = 16 -- 初始速度
local initialFieldOfView = 75 -- 初始 FOV
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- 添加锁定功能
local isLocked = false

-- 应用锁定的值
local appliedWalkSpeed = initialWalkSpeed
local appliedFieldOfView = initialFieldOfView

-- 使用 RenderStepped 持续监听并重置速度和 FOV
game:GetService("RunService").RenderStepped:Connect(function()
    if isLocked then
        -- 强制重置速度
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = appliedWalkSpeed
        end
        -- 强制重置 FOV
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end
end)

-- 添加速度输入框（速度上限改为 240）
chnl:Textbox("Walkspeed", "请输入速度（0-240）", false, function(text)
    pcall(function()
        if isLocked then return end -- 如果锁定，不执行修改
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value -- 更新锁定值，而不是立即修改玩家速度
            if not isLocked then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        else
            DiscordLib:Notification("错误", "速度值无效，请输入 0 到 240 之间的数字！", "确定")
        end
    end)
end)

-- 添加 FOV 输入框
chnl:Textbox("FOV", "请输入 FOV（75-140）", false, function(text)
    pcall(function()
        if isLocked then return end -- 如果锁定，不执行修改
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value -- 更新锁定值，而不是立即修改玩家 FOV
            if not isLocked then
                workspace.CurrentCamera.FieldOfView = value
            end
        else
            DiscordLib:Notification("错误", "FOV 值无效，请输入 75 到 140 之间的数字！", "确定")
        end
    end)
end)

-- 添加重置按钮
chnl:Button("重置", function()
    pcall(function()
        appliedWalkSpeed = initialWalkSpeed
        appliedFieldOfView = initialFieldOfView
        if not isLocked then
            LocalPlayer.Character.Humanoid.WalkSpeed = initialWalkSpeed
            workspace.CurrentCamera.FieldOfView = initialFieldOfView
        end
    end)
end)

-- 添加夜视功能
local DefaultAmbient = game.Lighting.Ambient
local DefaultFogEnd = game.Lighting.FogEnd

chnl:Button("Night Vision", function()
    local isNightVisionActive = not game.Lighting.Ambient == Color3.new(1, 1, 1)
    if not isNightVisionActive then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.FogEnd = 10000
    else
        game.Lighting.Ambient = DefaultAmbient
        game.Lighting.FogEnd = DefaultFogEnd
    end
end)

-- 添加锁定速度/FOV 按钮
chnl:Button("锁定速度/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("提示", "速度和 FOV 已锁定，无法修改！", "确定")
    else
        DiscordLib:Notification("提示", "速度和 FOV 已解锁，可以修改！", "确定")
    end
end)

-- 添加按钮加载“压力脚本”
chnl:Button("载入压力ESP脚本", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)
