-- Load DiscordLib library
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- Create window
local win = DiscordLib:Window("Baloksxin's Script")

-- Create server
local srv = win:Server("Main Server", "http://www.roblox.com/asset/?id=6031075938")

-- Create main channel
local chnl = srv:Channel("Main Channel")

-- Create pressure channel
local pressureChannel = srv:Channel("Pressure")

-- Create DOORS channel
local doorsChannel = srv:Channel("DOORS")

-- Get local player
local LocalPlayer = game.Players.LocalPlayer

-- Record initial speed and FOV
local initialWalkSpeed = 16
local initialFieldOfView = 75
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- Variables to store states
local isLocked = false
local appliedWalkSpeed = initialWalkSpeed
local appliedFieldOfView = initialFieldOfView
local noclipEnabled = false
local nightVisionEnabled = false
local espEnabled = false
local espBoxes = {} -- To store ESP boxes

-- Listen to frame rendering to continuously apply settings
game:GetService("RunService").RenderStepped:Connect(function()
    if isLocked then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = appliedWalkSpeed
        end
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end

    -- Apply night vision
    if nightVisionEnabled then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.FogEnd = 10000
    end

    -- Apply noclip
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end

    -- Update ESP boxes
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

-- Create ESP box
local function createESPBox(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(2, 4, 2)
    box.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.5
    box.Color3 = Color3.new(1, 0, 0) -- Red box
    box.Parent = player.Character
    espBoxes[player] = box
end

-- Remove ESP box
local function removeESPBox(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end

-- Toggle ESP
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
        DiscordLib:Notification("Notification", "ESP enabled!", "OK")
    else
        for player, box in pairs(espBoxes) do
            removeESPBox(player)
        end
        DiscordLib:Notification("Notification", "ESP disabled!", "OK")
    end
end

-- Highlight interactables (e.g., doors, buttons)
local function highlightInteractables()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Door" or obj.Name == "Button") then
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Size = obj.Size
            highlight.Adornee = obj
            highlight.AlwaysOnTop = true
            highlight.ZIndex = 10
            highlight.Transparency = 0.5
            highlight.Color3 = Color3.new(0, 1, 0) -- Green box
            highlight.Parent = obj
        end
    end
end

-- Speed setting
chnl:Textbox("Speed", "Enter speed (0-240)", false, function(text)
    pcall(function()
        if isLocked then return end
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        else
            DiscordLib:Notification("Error", "Invalid speed value, please enter a number between 0 and 240!", "OK")
        end
    end)
end)

-- FOV setting
chnl:Textbox("FOV", "Enter FOV (75-140)", false, function(text)
    pcall(function()
        if isLocked then return end
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value
            workspace.CurrentCamera.FieldOfView = value
        else
            DiscordLib:Notification("Error", "Invalid FOV value, please enter a number between 75 and 140!", "OK")
        end
    end)
end)

-- Reset button
chnl:Button("Reset", function()
    pcall(function()
        appliedWalkSpeed = initialWalkSpeed
        appliedFieldOfView = initialFieldOfView
        if not isLocked then
            LocalPlayer.Character.Humanoid.WalkSpeed = initialWalkSpeed
            workspace.CurrentCamera.FieldOfView = initialFieldOfView
        end
    end)
end)

-- Night vision mode
chnl:Button("Night Vision", function()
    nightVisionEnabled = not nightVisionEnabled
    if not nightVisionEnabled then
        game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5) -- Restore default ambient light
        game.Lighting.FogEnd = 1000 -- Restore default fog
    end
end)

-- Lock speed/FOV
chnl:Button("Lock Speed/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("Notification", "Speed and FOV locked!", "OK")
    else
        DiscordLib:Notification("Notification", "Speed and FOV unlocked!", "OK")
    end
end)

-- Pressure ESP script
pressureChannel:Button("Load Pressure ESP Script", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- Smooth FOV adjustment
chnl:Button("Smooth FOV Adjustment", function()
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

-- Break FOV limit
chnl:Button("Break FOV Limit", function()
    game:GetService("RunService").RenderStepped:Connect(function()
        workspace.CurrentCamera.FieldOfView = math.clamp(appliedFieldOfView, 75, 140)
    end)
end)

-- Reset FOV
chnl:Button("Reset FOV", function()
    appliedFieldOfView = initialFieldOfView
    workspace.CurrentCamera.FieldOfView = initialFieldOfView
end)

-- Sensation button
doorsChannel:Button("Sensation", function()
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/730854e5b6499ee91deb1080e8e12ae3.lua"))()
    end)
end)

-- Noclip function
chnl:Button("Noclip", function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        DiscordLib:Notification("Notification", "Noclip enabled!", "OK")
    else
        DiscordLib:Notification("Notification", "Noclip disabled!", "OK")
    end
end)

-- ESP for players
chnl:Button("Player ESP", function()
    toggleESP()
end)

-- Highlight interactables
chnl:Button("Interactable ESP", function()
    highlightInteractables()
    DiscordLib:Notification("Notification", "Interactables highlighted!", "OK")
end)
