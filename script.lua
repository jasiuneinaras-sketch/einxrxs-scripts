--// Einxrxs Mobile-Friendly Exploit Base 2026 - Enhanced Touch GUI
--// Features: Draggable GUI with Tabs, Fly (joystick + up/down), Noclip, ESP Toggle, Speed Slider

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// Settings
local Settings = {
    FlySpeed = 50,
    ESP_Enabled = false,
    Noclip = false,
    FlyEnabled = false
}

--// Root
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

--// Fly system
local flyBV, flyBG

local function updateFly()
    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root or not Settings.FlyEnabled then return end
    
    local cam = workspace.CurrentCamera
    local moveDir = Vector3.new()
    
    if not isMobile then
        -- PC keys
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
    else
        -- Mobile joystick direction boosted by camera
        moveDir = cam.CFrame.LookVector * LocalPlayer.Character.Humanoid.MoveDirection.Magnitude
    end
    
    flyBV.Velocity = moveDir * Settings.FlySpeed
    flyBG.CFrame = cam.CFrame
end

local function startFly()
    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root then return end
    
    Settings.FlyEnabled = true
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.new()
    flyBV.Parent = root
    
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root
    
    RunService:BindToRenderStep("FlyUpdate", Enum.RenderPriority.Input.Value, updateFly)
end

local function stopFly()
    Settings.FlyEnabled = false
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    RunService:UnbindFromRenderStep("FlyUpdate")
end

--// Noclip
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if
