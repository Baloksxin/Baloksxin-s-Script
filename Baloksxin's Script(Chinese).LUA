-- 加载 DiscordLib 库
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- 创建窗口
local win = DiscordLib:Window("Baloksxin's Script")

-- 创建服务器
local srv = win:Server("主服务器", "http://www.roblox.com/asset/?id=6031075938")

-- 创建频道
local chnl = srv:Channel("主频道")

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
    if not isLocked then
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end
end)

-- 添加速度输入框（速度上限改为 240）
chnl:Textbox("速度", "请输入速度（0-240）", false, function(text)
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
chnl:Textbox("视野（FOV）", "请输入视野（75-140）", false, function(text)
    pcall(function()
        if isLocked then return end -- 如果锁定，不执行修改
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value -- 更新锁定值，而不是立即修改玩家 FOV
            if not isLocked then
                -- 尝试修改 LocalPlayer 的 FieldOfView
                game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                workspace.CurrentCamera.FieldOfView = value
                -- 在某些情况下强制更新 FOV
                local camera = workspace.CurrentCamera
                local startFov = camera.FieldOfView
                local targetFov = value
                local step = (targetFov - startFov) / 10  -- 增量调整
                for i = 1, 10 do
                    camera.FieldOfView = startFov + step * i
                    wait(0.1)
                end
            end
        else
            DiscordLib:Notification("错误", "视野值无效，请输入 75 到 140 之间的数字！", "确定")
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

chnl:Button("夜视模式", function()
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
chnl:Button("锁定速度/视野", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("提示", "速度和视野已锁定，无法修改！", "确定")
    else
        DiscordLib:Notification("提示", "速度和视野已解锁，可以修改！", "确定")
    end
end)

-- 添加按钮加载“压力脚本”
chnl:Button("加载压力ESP脚本", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- 添加 FOV 平滑调整功能
local targetFieldOfView = initialFieldOfView

chnl:Button("平滑调整视野", function()
    local start = workspace.CurrentCamera.FieldOfView
    local finish = targetFieldOfView
    local duration = 2 -- 调整时间（秒）
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        local progress = (os.clock() - startTime) / duration
        local current = start + (finish - start) * progress
        workspace.CurrentCamera.FieldOfView = current
        wait()
    end
    workspace.CurrentCamera.FieldOfView = finish
end)

-- 添加 FOV 上限突破
chnl:Button("突破视野上限", function()
    local function setFOV()
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = math.clamp(appliedFieldOfView, 75, 140)
        end
    end

    -- 使用 RenderStepped 持续更新 FOV
    game:GetService("RunService").RenderStepped:Connect(function()
        setFOV()
    end)
end)

-- 添加 FOV 重置机制
chnl:Button("重置视野", function()
    appliedFieldOfView = initialFieldOfView
    workspace.CurrentCamera.FieldOfView = initialFieldOfView
end)
