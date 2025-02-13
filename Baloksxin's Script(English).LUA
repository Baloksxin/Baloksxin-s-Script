-- Load DiscordLib library
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- Create window
local win = DiscordLib:Window("Baloksxin's Script")

-- Create server
local srv = win:Server("Main Server", "http://www.roblox.com/asset/?id=6031075938")

-- Create channel
local chnl = srv:Channel("Main Channel")

-- Get local player
local LocalPlayer = game.Players.LocalPlayer

-- Record initial speed and FOV
local initialWalkSpeed = 16 -- Initial speed
local initialFieldOfView = 75 -- Initial FOV
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- Add lock functionality
local isLocked = false

-- Apply locked values
local appliedWalkSpeed = initialWalkSpeed
local appliedFieldOfView = initialFieldOfView

-- Use RenderStepped to continuously monitor and reset speed and FOV
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

-- Add speed input box (speed limit changed to 240)
chnl:Textbox("Speed", "Enter speed (0-240)", false, function(text)
    pcall(function()
        if isLocked then return end -- Do not modify if locked
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value -- Update locked value instead of immediately changing player speed
            if not isLocked then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        else
            DiscordLib:Notification("Error", "Invalid speed value, please enter a number between 0 and 240!", "Okay")
        end
    end)
end)

-- Add FOV input box
chnl:Textbox("FOV", "Enter FOV (75-140)", false, function(text)
    pcall(function()
        if isLocked then return end -- Do not modify if locked
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value -- Update locked value instead of immediately changing player FOV
            if not isLocked then
                workspace.CurrentCamera.FieldOfView = value
            end
        else
            DiscordLib:Notification("Error", "Invalid FOV value, please enter a number between 75 and 140!", "Okay")
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
        DiscordLib:Notification("Notice", "Speed and FOV are locked and cannot be modified!", "Okay")
    else
        DiscordLib:Notification("Notice", "Speed and FOV are unlocked and can be modified!", "Okay")
    end
end)

-- Add button to load "stress script"
chnl:Button("Load Stress ESP Script", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- Add smooth FOV adjustment feature
local targetFieldOfView = initialFieldOfView

chnl:Button("Smooth FOV Adjustment", function()
    local start = workspace.CurrentCamera.FieldOfView
    local finish = targetFieldOfView
    local duration = 2 -- Adjustment duration (seconds)
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        local progress = (os.clock() - startTime) / duration
        local current = start + (finish - start) * progress
        workspace.CurrentCamera.FieldOfView = current
        wait()
    end
    workspace.CurrentCamera.FieldOfView = finish
end)

-- Add FOV limit breakthrough
chnl:Button("Break FOV Limit", function()
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
