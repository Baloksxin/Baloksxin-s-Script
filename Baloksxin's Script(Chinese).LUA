-- 加载 DiscordLib 库
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- 创建窗口
local win = DiscordLib:Window("Baloksxin's Script")

-- 创建服务器
local srv = win:Server("主服务器", "http://www.roblox.com/asset/?id=6031075938")

-- 创建主频道
local chnl = srv:Channel("主频道")

-- 创建压力频道
local pressureChannel = srv:Channel("压力")

-- 创建 DOORS 频道
local doorsChannel = srv:Channel("DOORS")

-- 获取本地玩家
local LocalPlayer = game.Players.LocalPlayer

-- 记录初始速度和 FOV
local initialWalkSpeed = 16
local initialFieldOfView = 75
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- 变量存储状态
local isLocked = false
local appliedWalkSpeed = initialWalkSpeed
local appliedFieldOfView = initialFieldOfView
local noclipEnabled = false
local nightVisionEnabled = false
local espEnabled = false
local espBoxes = {} -- 用于存储 ESP 框

-- 监听帧渲染，持续应用设置
game:GetService("RunService").RenderStepped:Connect(function()
    if isLocked then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = appliedWalkSpeed
        end
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end

    -- 应用夜视
    if nightVisionEnabled then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.FogEnd = 10000
    end

    -- 应用穿墙
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end

    -- 更新 ESP 框
    if espEnabled then
        for player, box in pairs(espBoxes) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                box.Adornee = player.Character.HumanoidRootPart
            else
                box:Destroy()
                espBoxes[player] = nil
            end
        end
    end
end)

-- 创建 ESP 框
local function createESPBox(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(2, 4, 2)
    box.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.5
    box.Color3 = Color3.new(1, 0, 0) -- 红色框
    box.Parent = player.Character
    espBoxes[player] = box
end

-- 移除 ESP 框
local function removeESPBox(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

-- 启用/禁用 ESP
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createESPBox(player)
            end
        end
        game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                if espEnabled then
                    createESPBox(player)
                end
            end)
        end)
        game.Players.PlayerRemoving:Connect(function(player)
            removeESPBox(player)
        end)
        DiscordLib:Notification("提示", "ESP 已开启！", "确定")
    else
        for player, box in pairs(espBoxes) do
            removeESPBox(player)
        end
        DiscordLib:Notification("提示", "ESP 已关闭！", "确定")
    end
end

-- 透视互动对象（如门、按钮等）
local function highlightInteractables()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Door" or obj.Name == "Button") then
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Size = obj.Size
            highlight.Adornee = obj
            highlight.AlwaysOnTop = true
            highlight.ZIndex = 10
            highlight.Transparency = 0.5
            highlight.Color3 = Color3.new(0, 1, 0) -- 绿色框
            highlight.Parent = obj
        end
    end
end

-- 速度设置
chnl:Textbox("速度", "请输入速度（0-240）", false, function(text)
    pcall(function()
        if isLocked then return end
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        else
            DiscordLib:Notification("错误", "速度值无效，请输入 0 到 240 之间的数字！", "确定")
        end
    end)
end)

-- 视野（FOV）设置
chnl:Textbox("视野（FOV）", "请输入视野（75-140）", false, function(text)
    pcall(function()
        if isLocked then return end
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value
            workspace.CurrentCamera.FieldOfView = value
        else
            DiscordLib:Notification("错误", "视野值无效，请输入 75 到 140 之间的数字！", "确定")
        end
    end)
end)

-- 重置按钮
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

-- 夜视模式
chnl:Button("夜视模式", function()
    nightVisionEnabled = not nightVisionEnabled
    if not nightVisionEnabled then
        game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5) -- 恢复默认环境光
        game.Lighting.FogEnd = 1000 -- 恢复默认雾效
    end
end)

-- 锁定速度/FOV
chnl:Button("锁定速度/视野", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("提示", "速度和视野已锁定，无法修改！", "确定")
    else
        DiscordLib:Notification("提示", "速度和视野已解锁，可以修改！", "确定")
    end
end)

-- 压力 ESP 脚本
pressureChannel:Button("加载压力 ESP 脚本", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- 平滑调整视野
chnl:Button("平滑调整视野", function()
    local start = workspace.CurrentCamera.FieldOfView
    local finish = appliedFieldOfView
    local duration = 2
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        local progress = (os.clock() - startTime) / duration
        workspace.CurrentCamera.FieldOfView = start + (finish - start) * progress
        wait()
    end
    workspace.CurrentCamera.FieldOfView = finish
end)

-- 突破视野上限
chnl:Button("突破视野上限", function()
    game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.FieldOfView = math.clamp(appliedFieldOfView, 75, 140)
    end)
end)

-- 重置视野
chnl:Button("重置视野", function()
    appliedFieldOfView = initialFieldOfView
    workspace.CurrentCamera.FieldOfView = initialFieldOfView
end)

-- Sensation 按钮
doorsChannel:Button("Sensation", function()
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/730854e5b6499ee91deb1080e8e12ae3.lua"))()
    end)
end)

-- 穿墙功能
chnl:Button("穿墙", function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        DiscordLib:Notification("提示", "穿墙模式已开启！", "确定")
    else
        DiscordLib:Notification("提示", "穿墙模式已关闭！", "确定")
    end
end)

-- ESP 透视玩家
chnl:Button("玩家ESP", function()
    toggleESP()
end)

-- 透视互动对象
chnl:Button("互动ESP", function()
    highlightInteractables()
    DiscordLib:Notification("提示", "互动对象已高亮显示！", "确定")
end)
