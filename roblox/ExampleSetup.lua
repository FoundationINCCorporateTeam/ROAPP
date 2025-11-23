--[[
    Application Center - Example Setup Script
    
    Place this script in ServerScriptService to create an example
    application system in your Roblox game.
    
    SETUP:
    1. Place AppCenterClient.lua as a ModuleScript in ServerScriptService
    2. Update APP_ID and SERVER_URL below
    3. Create a Part in Workspace named "ApplicationPart"
    4. This script will add a ProximityPrompt to the part
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- CONFIGURATION - UPDATE THESE VALUES
local APP_ID = "example_staff_app"  -- Your application ID from the builder
local SERVER_URL = "https://bulletproof.astroyds.com"  -- Your server URL

-- Require the AppCenterClient module
local AppCenter = require(ServerScriptService.AppCenterClient)

-- Create the application instance
local staffApp = AppCenter.new({
    AppId = APP_ID,
    ServerUrl = SERVER_URL
})

-- Find or create the application part
local appPart = Workspace:FindFirstChild("ApplicationPart")

if not appPart then
    -- Create a new part if it doesn't exist
    appPart = Instance.new("Part")
    appPart.Name = "ApplicationPart"
    appPart.Size = Vector3.new(6, 8, 1)
    appPart.Position = Vector3.new(0, 4, 0)
    appPart.Anchored = true
    appPart.BrickColor = BrickColor.new("Bright red")
    appPart.Material = Enum.Material.Neon
    appPart.Parent = Workspace
    
    -- Add a SurfaceGui with text
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.Parent = appPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "📋 STAFF APPLICATION"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 48
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
    textLabel.Parent = surfaceGui
    
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Size = UDim2.new(1, 0, 0.3, 0)
    textLabel2.Position = UDim2.new(0, 0, 0.7, 0)
    textLabel2.BackgroundTransparency = 1
    textLabel2.Text = "Click to Apply"
    textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel2.TextSize = 24
    textLabel2.Font = Enum.Font.Gotham
    textLabel2.Parent = surfaceGui
end

-- Create ProximityPrompt
local prompt = appPart:FindFirstChild("ApplicationPrompt")

if not prompt then
    prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ApplicationPrompt"
    prompt.ActionText = "Apply for Staff"
    prompt.ObjectText = "Staff Application"
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = appPart
end

-- Handle prompt triggering
prompt.Triggered:Connect(function(player)
    print(player.Name .. " is opening the application")
    
    -- Show the application to the player
    staffApp:ShowToPlayer(player)
end)

print("Application Center setup complete!")
print("- Application ID:", APP_ID)
print("- Server URL:", SERVER_URL)
print("- Touch the red part to open the application")
