-- Load the DiscordLib library
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- Create window
local win = DiscordLib:Window("Baloksxin's Script")

-- Create server
local srv = win:Server("Main Server", "http://www.roblox.com/asset/?id=6031075938")

-- Create main channel
local chnl = srv:Channel("Main Channel")

-- Create Pressure channel
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

-- Monitor frame rendering to continuously apply settings
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
end)

-- Speed setting
chnl:Textbox("Speed", "Enter speed (0-240)", false, function(text)
    pcall(function()
        if isLocked then return end
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        else
            DiscordLib:Notification("Error", "Invalid speed value. Please enter a number between 0 and 240!", "OK")
        end
    end)
end)

-- Field of View (FOV) setting
chnl:Textbox("Field of View (FOV)", "Enter FOV (75-140)", false, function(text)
    pcall(function()
        if isLocked then return end
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value
            workspace.CurrentCamera.FieldOfView = value
        else
            DiscordLib:Notification("Error", "Invalid FOV value. Please enter a number between 75 and 140!", "OK")
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
chnl:Button("Night Vision Mode", function()
    nightVisionEnabled = not nightVisionEnabled
    if not nightVisionEnabled then
        game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5) -- Restore default ambient light
        game.Lighting.FogEnd = 1000 -- Restore default fog effect
    end
end)

-- Lock speed/FOV
chnl:Button("Lock Speed/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("Notice", "Speed and FOV are locked and cannot be modified!", "OK")
    else
        DiscordLib:Notification("Notice", "Speed and FOV are unlocked and can be modified!", "OK")
    end
end)

-- Pressure ESP script
pressureChannel:Button("Load Pressure ESP Script", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- Smoothly adjust FOV
chnl:Button("Smoothly Adjust FOV", function()
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

-- Exceed FOV limit
chnl:Button("Exceed FOV Limit", function()
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

-- Monitor player joining
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.WalkSpeed = appliedWalkSpeed
            workspace.CurrentCamera.FieldOfView = appliedFieldOfView
        end
    end)
end)

-- Noclip function
chnl:Button("Noclip", function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        DiscordLib:Notification("Notice", "Noclip mode is enabled!", "OK")
    else
        DiscordLib:Notification("Notice", "Noclip mode is disabled!", "OK")
    end
end)
