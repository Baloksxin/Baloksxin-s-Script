local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local win = DiscordLib:Window("Baloksxin's script") -- 创建窗口

local srv = win:Server("Main", "http://www.roblox.com/asset/?id=6031075938") -- 创建服务器
local chnl = srv:Channel("Main") -- 创建频道

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

-- 添加速度输入框（速度上限改为 240）
chnl:Textbox("Walkspeed", "请输入速度（0-240）", false, function(text)
    pcall(function()
        if isLocked then return end -- 如果锁定，不执行修改
        local value = tonumber(text)
        if value and value >=0 and value <=240 then -- 修改下限为0
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        else
            DiscordLib:Notification("错误", "速度值无效，请输入0到240之间的数字！", "确定")
        end
    end)
end)

-- 添加FOV输入框
chnl:Textbox("FOV", "请输入FOV（75-140）", false, function(text)
    pcall(function()
        if isLocked then return end -- 如果锁定，不执行修改
        local value = tonumber(text)
        if value and value >=75 and value <=140 then
            workspace.CurrentCamera.FieldOfView = value
        else
            DiscordLib:Notification("错误", "FOV值无效，请输入75到140之间的数字！", "确定")
        end
    end)
end)

-- 添加重置按钮
chnl:Button("重置", function()
    pcall(function()
        LocalPlayer.Character.Humanoid.WalkSpeed = initialWalkSpeed
        workspace.CurrentCamera.FieldOfView = initialFieldOfView
    end)
end)

-- 添加夜视功能
local isNightVisionActive = false
local DefaultAmbient = game.Lighting.Ambient
local DefaultFogEnd = game.Lighting.FogEnd

chnl:Button("Night Vision", function()
    if not isNightVisionActive then
        game.Lighting.Ambient = Color3.new(1,1,1)
        game.Lighting.FogEnd = 10000
        isNightVisionActive = true
    else
        game.Lighting.Ambient = DefaultAmbient
        game.Lighting.FogEnd = DefaultFogEnd
        isNightVisionActive = false
    end
end)

-- 添加锁定速度和 FOV 的按钮
chnl:Button("锁定速度/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("提示", "速度和 FOV 已锁定，无法修改！", "确定")
    else
        DiscordLib:Notification("提示", "速度和 FOV 已解锁，可以修改！", "确定")
    end
end)
