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

-- Record initial walk speed and FOV
local initialWalkSpeed = 16 -- Initial walk speed
local initialFieldOfView = 75 -- Initial FOV
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- Add lock feature
local isLocked = false

-- Apply locked values
local appliedWalkSpeed = initialWalkSpeed
local appliedFieldOfView = initialFieldOfView

-- Continuously listen and force reset walk speed and FOV
game:GetService("RunService").RenderStepped:Connect(function()
    if isLocked then
        -- Force reset speed
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = appliedWalkSpeed
        end
        -- Force reset FOV
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end
    if not isLocked then
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end
end)

-- Add speed input box (speed limit set to 240)
chnl:Textbox("Speed", "Enter speed (0-240)", false, function(text)
    pcall(function()
        if isLocked then return end -- If locked, don't execute modification
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value -- Update locked value, not immediately modify player speed
            if not isLocked then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        else
            DiscordLib:Notification("Error", "Invalid speed value, please enter a number between 0 and 240!", "OK")
        end
    end)
end)

-- Add FOV input box
chnl:Textbox("Field of View (FOV)", "Enter FOV (75-140)", false, function(text)
    pcall(function()
        if isLocked then return end -- If locked, don't execute modification
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value -- Update locked value, not immediately modify player FOV
            if not isLocked then
                -- Attempt to modify LocalPlayer's FieldOfView
                game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                workspace.CurrentCamera.FieldOfView = value
                -- Force update FOV in some cases
                local camera = workspace.CurrentCamera
                local startFov = camera.FieldOfView
                local targetFov = value
                local step = (targetFov - startFov) / 10  -- Incremental adjustment
                for i = 1, 10 do
                    camera.FieldOfView = startFov + step * i
                    wait(0.1)
                end
            end
        else
            DiscordLib:Notification("Error", "Invalid FOV value, please enter a number between 75 and 140!", "OK")
        end
    end)
end)

-- Add reset button
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

-- Add night vision feature
local DefaultAmbient = game.Lighting.Ambient
local DefaultFogEnd = game.Lighting.FogEnd
local nightVisionEnabled = false -- Track night vision state

-- Continuously apply night vision mode
game:GetService("RunService").RenderStepped:Connect(function()
    if nightVisionEnabled then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.FogEnd = 10000
    end
end)

-- Toggle night vision mode
chnl:Button("Night Vision Mode", function()
    if not nightVisionEnabled then
        nightVisionEnabled = true
    else
        nightVisionEnabled = false
        game.Lighting.Ambient = DefaultAmbient
        game.Lighting.FogEnd = DefaultFogEnd
    end
end)

-- Add lock speed/FOV button
chnl:Button("Lock Speed/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("Notice", "Speed and FOV are locked and cannot be modified!", "OK")
    else
        DiscordLib:Notification("Notice", "Speed and FOV are unlocked and can be modified!", "OK")
    end
end)

-- Move "Load Pressure ESP Script" button to "Pressure" channel
pressureChannel:Button("Load Pressure ESP Script", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- Add FOV smooth adjustment feature
local targetFieldOfView = initialFieldOfView

chnl:Button("Smooth Adjust FOV", function()
    local start = workspace.CurrentCamera.FieldOfView
    local finish = targetFieldOfView
    local duration = 2 -- Adjustment time (seconds)
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        local progress = (os.clock() - startTime) / duration
        local current = start + (finish - start) * progress
        workspace.CurrentCamera.FieldOfView = current
        wait()
    end
    workspace.CurrentCamera.FieldOfView = finish
end)

-- Add FOV cap bypass
chnl:Button("Bypass FOV Cap", function()
    local function setFOV()
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = math.clamp(appliedFieldOfView, 75, 140)
        end
    end

    -- Use RenderStepped to continuously update FOV
    game:GetService("RunService").RenderStepped:Connect(function()
        setFOV()
    end)
end)

-- Add FOV reset button
chnl:Button("Reset FOV", function()
    appliedFieldOfView = initialFieldOfView
    workspace.CurrentCamera.FieldOfView = initialFieldOfView
end)

-- Add SENSATION button to DOORS channel
doorsChannel:Button("Sensation", function()
    pcall(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/730854e5b6499ee91deb1080e8e12ae3.lua"))()
    end)
end)

-- Listen for player join and apply speed settings
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if character:FindFirstChildOfClass("Humanoid") then
            -- Apply speed settings when a player joins
            character.Humanoid.WalkSpeed = appliedWalkSpeed
            workspace.CurrentCamera.FieldOfView = appliedFieldOfView
        end
    end)
end)
