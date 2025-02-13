-- Load the DiscordLib library
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- Create the window
local win = DiscordLib:Window("Baloksxin's Script")

-- Create the server
local srv = win:Server("Main Server", "http://www.roblox.com/asset/?id=6031075938")

-- Create the channel
local chnl = srv:Channel("Main Channel")

-- Get the local player
local LocalPlayer = game.Players.LocalPlayer

-- Record the initial walk speed and FOV
local initialWalkSpeed = 16 -- Initial walk speed
local initialFieldOfView = 75 -- Initial FOV
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- Add lock functionality
local isLocked = false

-- Apply the locked values
local appliedWalkSpeed = initialWalkSpeed
local appliedFieldOfView = initialFieldOfView

-- Use RenderStepped to continuously monitor and reset speed and FOV
game:GetService("RunService").RenderStepped:Connect(function()
    if isLocked then
        -- Force reset the speed
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = appliedWalkSpeed
        end
        -- Force reset the FOV
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end
    if not isLocked then
        workspace.CurrentCamera.FieldOfView = appliedFieldOfView
    end
end)

-- Add a speed input box (Speed limit changed to 240)
chnl:Textbox("Speed", "Enter speed (0-240)", false, function(text)
    pcall(function()
        if isLocked then return end -- Do not execute if locked
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value -- Update the locked value, rather than modifying the player's speed immediately
            if not isLocked then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        else
            DiscordLib:Notification("Error", "Invalid speed value, please enter a number between 0 and 240!", "OK")
        end
    end)
end)

-- Add an FOV input box
chnl:Textbox("Field of View (FOV)", "Enter FOV (75-140)", false, function(text)
    pcall(function()
        if isLocked then return end -- Do not execute if locked
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value -- Update the locked value, rather than modifying the player's FOV immediately
            if not isLocked then
                -- Attempt to modify LocalPlayer's FieldOfView
                game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                workspace.CurrentCamera.FieldOfView = value
                -- In some cases, force update the FOV
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

-- Add night vision functionality
local DefaultAmbient = game.Lighting.Ambient
local DefaultFogEnd = game.Lighting.FogEnd

chnl:Button("Night Vision Mode", function()
    local isNightVisionActive = not game.Lighting.Ambient == Color3.new(1, 1, 1)
    if not isNightVisionActive then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.FogEnd = 10000
    else
        game.Lighting.Ambient = DefaultAmbient
        game.Lighting.FogEnd = DefaultFogEnd
    end
end)

-- Add lock speed/FOV button
chnl:Button("Lock Speed/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("Notice", "Speed and FOV are locked, cannot be modified!", "OK")
    else
        DiscordLib:Notification("Notice", "Speed and FOV are unlocked, you can modify them!", "OK")
    end
end)

-- Add a button to load the "Pressure ESP script"
chnl:Button("Load Pressure ESP Script", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- Add smooth FOV adjustment functionality
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

-- Add FOV limit bypass
chnl:Button("Bypass FOV Limit", function()
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

-- Add FOV reset mechanism
chnl:Button("Reset FOV", function()
    appliedFieldOfView = initialFieldOfView
    workspace.CurrentCamera.FieldOfView = initialFieldOfView
end)
