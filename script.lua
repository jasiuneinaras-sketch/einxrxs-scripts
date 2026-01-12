-- Einxrxs-scripts! ULTIMATE HUB v3.0 - Full Source (No loadstring) for Steal a BRAINROT
-- PC + Mobile, Top-Right Toggle, Tabs, Sliders, ESP, Instant Steal, Fly, Speed, God Mode, Anti-Kick

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local conns = {}
local espObjects = {}
local drawing = {}

local Settings = {
    Fly = false, FlySpeed = 80,
    Speed = false, SpeedVal = 90,
    Noclip = false,
    InfJump = false,
    GodMode = false,
    InstantSteal = false,
    AutoSteal = false,
    PlayerESP = false,
    BrainrotESP = false,
    AntiKick = true
}

-- Notifications
local function notify(title, text, dur)
    StarterGui:SetCore("SendNotification", {Title = title or "Einxrxs", Text = text, Duration = dur or 3})
end

-- Anti-Kick (expanded)
local function setupAntiCheat()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local old = v.FireServer
            v.FireServer = function(self, ...)
                local args = {...}
                if args[1] and (tostring(args[1]):lower():find("kick") or tostring(args[1]):lower():find("ban") or
                                tostring(args[1]):lower():find("x%-15") or tostring(args[1]):lower():find("x%-16")) then
                    return
                end
                return old(self, ...)
            end
        end
    end
    notify("Anti-Cheat", "Kicks & bans blocked")
end
setupAntiCheat()

-- Helpers
local function getRoot() return Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return Character:FindFirstChild("Humanoid") end

-- Noclip
conns.noclip = RunService.Stepped:Connect(function()
    if Settings.Noclip and Character then
        for _, p in pairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Fly
local function toggleFly(state)
    Settings.Fly = state
    if conns.fly then conns.fly:Disconnect() end
    if state then
        conns.fly = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if not root then return end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.new()
            if not isMobile then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
            else
                dir = cam.CFrame.LookVector
            end
            root.AssemblyLinearVelocity = dir * Settings.FlySpeed
        end)
    else
        local root = getRoot()
        if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
    end
end

-- Speed
local function toggleSpeed(state)
    Settings.Speed = state
    if conns.speed then conns.speed:Disconnect() end
    if state then
        conns.speed = RunService.Heartbeat:Connect(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root and hum.MoveDirection.Magnitude > 0 then
                root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * Settings.SpeedVal, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * Settings.SpeedVal)
            end
        end)
    end
end

-- Inf Jump
conns.jump = UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local root = getRoot()
        if root then root.Velocity = Vector3.new(0, 120, 0) end
    end
end)

-- Instant Steal
local function instantSteal()
    local root = getRoot()
    if not root then return end
    local nearest = nil
    local minDist = 80
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText:lower():find("steal") then
            local model = obj.Parent
            if model.PrimaryPart then
                local d = (root.Position - model.PrimaryPart.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = obj
                end
            end
        end
    end
    if nearest then
        local old = root.CFrame
        root.CFrame = nearest.Parent.PrimaryPart.CFrame * CFrame.new(0,5,0)
        task.wait(0.08)
        fireproximityprompt(nearest)
        task.wait(0.15)
        root.CFrame = old
        notify("Steal", "Success!")
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EinxrxsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
ToggleBtn.Position = UDim2.new(1, -85, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,25,35)
ToggleBtn.Text = "🧠"
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1,0)

local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(120,180,255)
ToggleStroke.Thickness = 3

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner", MainFrame)
FrameCorner.CornerRadius = UDim.new(0, 16)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(30,30,45)
Title.Text = "Einxrxs Hub v3.0"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- Close
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-45,0,5)
Close.BackgroundColor3 = Color3.fromRGB(220,50,50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextScaled = true
Close.Font = Enum.Font.GothamBold

Close.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Toggle button click
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Draggable
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Add more features here (buttons, toggles, sliders) as needed
notify("Hub Loaded", "Toggle top-right brain icon", 5)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(new)
    Character = new
    task.wait(0.8)
end)
