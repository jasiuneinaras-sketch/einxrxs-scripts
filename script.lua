--// Basic Universal Exploit Base - Loadstring Ready 2026 edition
--// Most executors still love this lazy structure

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

--// Config & Toggles
local Settings = {
    FlySpeed = 50,
    WalkSpeed = 32,
    JumpPower = 50,
    ESP_Enabled = false,
    Noclip = false,
    InfiniteYieldMode = false
}

--// Services & shortcuts
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

--// Fly (very classic Synapse/VFly style)
local flying = false
local flyKeys = {W=false, S=false, A=false, D=false, Space=false, LeftCtrl=false}
local flyBodyVelocity, flyBodyGyro

local function startFly()
    local char = LocalPlayer.Character
    if not char or not getRoot(char) then return end
    
    flying = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVelocity.Velocity = Vector3.new()
    flyBodyVelocity.Parent = getRoot(char)
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.CFrame = getRoot(char).CFrame
    flyBodyGyro.Parent = getRoot(char)
    
    spawn(function()
        RunService.RenderStepped:Connect(function()
            if not flying then return end
            local root = getRoot(char)
            if not root then flying = false return end
            
            local moveDir = Vector3.new()
            if flyKeys.W then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
            if flyKeys.S then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
            if flyKeys.A then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
            if flyKeys.D then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
            
            flyBodyVelocity.Velocity = (moveDir * Settings.FlySpeed) + 
                (flyKeys.Space and Vector3.new(0, Settings.FlySpeed, 0) or Vector3.new()) +
                (flyKeys.LeftCtrl and Vector3.new(0, -Settings.FlySpeed, 0) or Vector3.new())
                
            flyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end)
    end)
end

local function stopFly()
    flying = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
end

--// Noclip
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// Basic ESP (boxes + tracers skeleton)
local function createESP(plr)
    if plr == LocalPlayer or not plr.Character then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 0, 0)
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 0, 0)
    tracer.Transparency = 1
    
    local function update()
        box.Visible = false
        tracer.Visible = false
        
        if not Settings.ESP_Enabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local root = plr.Character.HumanoidRootPart
        local head = plr.Character:FindFirstChild("Head")
        if not head then return end
        
        local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
        if onScreen then
            local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legPos = workspace.CurrentCamera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            
            local sizeY = math.clamp(math.abs(headPos.Y - legPos.Y) * 1.2, 20, 400)
            local sizeX = sizeY * 0.5
            
            box.Size = Vector2.new(sizeX, sizeY)
            box.Position = Vector2.new(rootPos.X - sizeX/2, rootPos.Y - sizeY/2)
            box.Visible = true
            
            tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            tracer.Visible = true
        end
    end
    
    RunService.RenderStepped:Connect(update)
end

--// Hook new players
for _, plr in
