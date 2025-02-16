-- Load DiscordLib Library
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

-- Create Window
local win = DiscordLib:Window("Baloksxin's Script")

-- Create Server
local srv = win:Server("Main Server", "http://www.roblox.com/asset/?id=6031075938")

-- Create Main Channel
local chnl = srv:Channel("Main Channel")

-- Create Pressure Channel
local pressureChannel = srv:Channel("Pressure")

-- Get Local Player
local LocalPlayer = game.Players.LocalPlayer

-- Record initial speed and FOV
local initialWalkSpeed = 16 -- Initial speed
local initialFieldOfView = 75 -- Initial FOV
LocalPlayer.CharacterAdded:Connect(function(character)
    initialWalkSpeed = character.Humanoid.WalkSpeed
    initialFieldOfView = workspace.CurrentCamera.FieldOfView
end)

-- Add Lock feature
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

-- Add Speed Input Box (Speed limit changed to 240)
chnl:Textbox("Speed", "Enter speed (0-240)", false, function(text)
    pcall(function()
        if isLocked then return end -- Don't execute changes if locked
        local value = tonumber(text)
        if value and value >= 0 and value <= 240 then
            appliedWalkSpeed = value -- Update locked value, instead of immediately changing player speed
            if not isLocked then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        else
            DiscordLib:Notification("Error", "Invalid speed value, please enter a number between 0 and 240!", "OK")
        end
    end)
end)

-- Add FOV Input Box
chnl:Textbox("Field of View (FOV)", "Enter FOV (75-140)", false, function(text)
    pcall(function()
        if isLocked then return end -- Don't execute changes if locked
        local value = tonumber(text)
        if value and value >= 75 and value <= 140 then
            appliedFieldOfView = value -- Update locked value, instead of immediately changing player FOV
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

-- Add Reset Button
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

-- Add Night Vision Feature
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

-- Toggle Night Vision Mode
chnl:Button("Night Vision Mode", function()
    if not nightVisionEnabled then
        nightVisionEnabled = true
    else
        nightVisionEnabled = false
        game.Lighting.Ambient = DefaultAmbient
        game.Lighting.FogEnd = DefaultFogEnd
    end
end)

-- Add Lock Speed/FOV Button
chnl:Button("Lock Speed/FOV", function()
    isLocked = not isLocked
    if isLocked then
        DiscordLib:Notification("Tip", "Speed and FOV are locked, cannot be modified!", "OK")
    else
        DiscordLib:Notification("Tip", "Speed and FOV are unlocked, can be modified!", "OK")
    end
end)

-- Move "Load Pressure ESP Script" button to "Pressure" channel
pressureChannel:Button("Load Pressure ESP Script", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/haa09YfF"))()
    end)
end)

-- Add Smooth FOV Adjustment
local targetFieldOfView = initialFieldOfView

chnl:Button("Smooth Adjust FOV", function()
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

-- Add FOV Limit Bypass
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

-- Add FOV Reset Mechanism
chnl:Button("Reset FOV", function()
    appliedFieldOfView = initialFieldOfView
    workspace.CurrentCamera.FieldOfView = initialFieldOfView
end)
