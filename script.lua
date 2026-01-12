-- Einxrxs-scripts! ULTIMATE HUB v2.1 for Steal a BRAINROT (PC + Mobile, Keyless, Jan 2026)
-- FULL SOURCE - Paste directly into executor (no loadstring needed!)
-- Features Copied from Lemon Hub / Top Scripts: Instant/Invisible Steal, Anti Hit, Turret Destroyer, Desync, TP to Best Brainrot,
-- Auto Buy/Collect/Farm, Full ESP (Tracers/Boxes/Names/Health/Rarity), Aimbot, God Mode, Anti-Kick/Ragdoll, Inf Jump, Fly to Base,
-- Sliders (Fly/Speed), Tabs (Main/Movement/Visuals/Misc), Smooth Animations, Notifications, Error Handling!
-- Anticheat Bypass: Velocity Movement, Remote Hooks, Safe Lerp TP

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
local esp = {players = {}, brainrots = {}}
local drawingObjects = {}
local toggles = {}
local sliders = {}

-- Expanded Settings
local Settings = {
    -- Main Tab
    InstantSteal = false,
    AutoSteal = false,
    TPBestBrainrot = false,
    DestroyTurrets = false,
    AutoBuy = false,
    AutoCollect = false,
    AutoFarm = false,
    -- Movement Tab
    Fly = false, FlySpeed = 85,
    Speed = false, SpeedVal = 90,
    InfJump = false,
    FlyToBase = false,
    Desync = false,
    Noclip = false,
    -- Visuals Tab
    PlayerESP = false,
    BrainrotESP = false,
    Tracers = true,
    Boxes = true,
    Names = true,
    HealthBars = true,
    -- Misc Tab
    GodMode = false,
    AntiHit = false,
    AntiRagdoll = false,
    AntiKick = true,
    Aimbot = false
}

-- Notification Function
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Einxrxs Hub",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

-- Anticheat Bypass (Hook Remotes)
local function initAnticheat()
    if Settings.AntiKick then
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local oldName = remote.Name
                local oldFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    local args = {...}
                    local argStr = tostring(args[1] or "")
                    if argStr:lower():match("kick") or argStr:lower():match("ban") or argStr:lower():match("cheat") or argStr:lower():match("detect") or argStr:lower():match("exploit") then
                        warn("[Einxrxs] Blocked AC remote: " .. oldName)
                        return
                    end
                    return oldFire(self, ...)
                end
            end
        end
        notify("Anti-Cheat", "All kicks/bans blocked!", 4)
    end
end

initAnticheat()

-- Get Root/Humanoid
local function getRoot()
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    return Character and Character:FindFirstChild("Humanoid")
end

-- Noclip Toggle
conns.noclipLoop = RunService.Stepped:Connect(function()
    if Settings.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly Toggle (Velocity Safe)
local function toggleFly(enabled)
    Settings.Fly = enabled
    if conns.fly then conns.fly:Disconnect() end
    if enabled then
        conns.fly = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if not root then return end
            local cam = Workspace.CurrentCamera
            local moveVector = Vector3.new(0, 0, 0)
            if not isMobile then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
            else
                local hum = getHum()
                if hum then moveVector = cam.CFrame.LookVector * hum.MoveDirection.Magnitude end
            end
            root.AssemblyLinearVelocity = moveVector.Unit * Settings.FlySpeed
        end)
    else
        local root = getRoot()
        if root then root.AssemblyLinearVelocity = Vector3.new(0, 50, 0) end
    end
end

-- Speed Toggle (Velocity)
local function toggleSpeed(enabled)
    Settings.Speed = enabled
    if conns.speed then conns.speed:Disconnect() end
    if enabled then
        conns.speed = RunService.Heartbeat:Connect(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root and hum.MoveDirection.Magnitude > 0 then
                root.AssemblyLinearVelocity = Vector3.new(
                    hum.MoveDirection.X * Settings.SpeedVal,
                    root.AssemblyLinearVelocity.Y,
                    hum.MoveDirection.Z * Settings.SpeedVal
                )
            end
        end)
    end
end

-- Infinite Jump
conns.infJump = UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and getRoot() then
        getRoot().Velocity = Vector3.new(0, 120, 0)
    end
end)

-- Instant Steal (Safe TP + Fire Prompt)
local function doInstantSteal()
    local root = getRoot()
    if not root then return end
    local nearestPrompt, minDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText:lower():find("steal") then
            local model = obj.Parent
            if model.PrimaryPart and model ~= Character then
                local dist = (root.Position - model.PrimaryPart.Position).Magnitude
                if dist < minDist and dist < 100 then
                    minDist = dist
                    nearestPrompt = obj
                end
            end
        end
    end
    if nearestPrompt then
        local oldCFrame = root.CFrame
        root.CFrame = nearestPrompt.Parent.PrimaryPart.CFrame * CFrame.new(0, 3, -3)
        task.wait(0.1)
        fireproximityprompt(nearestPrompt)
        task.wait(0.2)
        root.CFrame = oldCFrame
        notify("Steal", "Instant steal successful!", 2)
    else
        notify("Steal", "No nearby Brainrot found!", 2)
    end
end

-- Auto Steal Loop
conns.autoSteal = RunService.Heartbeat:Connect(function()
    if Settings.AutoSteal then
        doInstantSteal()
    end
end)

-- TP to Best Brainrot (by value/ rarity attribute)
local function tpToBestBrainrot()
    local bestModel, bestValue = nil, 0
    for _, model in pairs(Workspace:GetChildren()) do
        if model.Name:lower():find("brainrot") and model.PrimaryPart then
            local value = model:GetAttribute("Value") or model:GetAttribute("Rarity") or 1
            if value > bestValue then
                bestValue = value
                bestModel = model
            end
        end
    end
    if bestModel then
        local root = getRoot()
        if root then
            root.CFrame = bestModel.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
            notify("TP", "Teleported to best Brainrot (Value: " .. bestValue .. ")!", 3)
        end
    end
end

-- Destroy Turrets
local function destroyTurrets()
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("turret") and obj.Parent == Workspace then
            obj:Destroy()
            count = count + 1
        end
    end
    notify("Turrets", "Destroyed " .. count .. " turrets!", 3)
end

-- God Mode
conns.godMode = RunService.Heartbeat:Connect(function()
    if Settings.GodMode then
        local hum = getHum()
        if hum then hum.Health = 100 end
    end
end)

-- Anti Ragdoll
conns.antiRagdoll = RunService.Heartbeat:Connect(function()
    if Settings.AntiRagdoll then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
    end
end)

-- Desync (Position Jitter)
conns.desync = RunService.RenderStepped:Connect(function()
    if Settings.Desync then
        local root = getRoot()
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-5,5)), 0)
        end
    end
end)

-- Fly to Nearest Base (Safe Lerp)
local function flyToNearestBase()
    local root = getRoot()
    if not root then return end
    local targetPos, minDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local baseModel = Workspace:FindFirstChild(player.Name) or Workspace:FindFirstChild(player.Name .. "_Base")
            if baseModel and baseModel.PrimaryPart then
                local dist = (root.Position - baseModel.PrimaryPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    targetPos = baseModel.PrimaryPart.Position
                end
            end
        end
    end
    if targetPos then
        local startPos = root.Position
        for i = 0, 1, 0.05 do
            root.CFrame = CFrame.new(startPos:lerp(targetPos, i) + Vector3.new(0, 10, 0))
            task.wait(0.03)
        end
        notify("Fly", "Arrived at nearest base!", 2)
    else
        notify("Fly", "No bases found!", 2)
    end
end

-- ESP System (Full: Boxes, Tracers, Names, Health)
local function togglePlayerESP(enabled)
    Settings.PlayerESP = enabled
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Box
                    local box = Drawing.new("Square")
                    box.Thickness = 3
                    box.Color = Color3.fromRGB(255, 0, 0)
                    box.Filled = false
                    box.Transparency = 1
                    -- Tracer
                    local tracer = Drawing.new("Line")
                    tracer.Thickness = 2
                    tracer.Color = Color3.fromRGB(255, 0, 0)
                    tracer.Transparency = 1
                    esp.players[player] = {box = box, tracer = tracer}
                end
            end
        end
    else
        for player, data in pairs(esp.players) do
            if data.box then data.box:Remove() end
            if data.tracer then data.tracer:Remove() end
        end
        esp.players = {}
    end
end

conns.espUpdate = RunService.RenderStepped:Connect(function()
    if not Settings.PlayerESP then return end
    local cam = Workspace.CurrentCamera
    for player, data in pairs(esp.players) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = cam:WorldToViewportPoint(char.HumanoidRootPart.Position)
            local headPos = cam:WorldToViewportPoint(char.Head.Position)
            local legPos = cam:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 5, 0))
            if onScreen then
                -- Box
                local height = math.abs(rootPos.Y - legPos.Y)
                local width = height * 0.5
                data.box.Size = Vector2.new(width, height)
                data.box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                data.box.Visible = true
                -- Tracer
                data.tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2 + 50)
                data.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                data.tracer.Visible = true
            else
                data.box.Visible = false
                data.tracer.Visible = false
            end
        end
    end
end)

-- Brainrot ESP (Highlights)
local function toggleBrainrotESP(enabled)
    Settings.BrainrotESP = enabled
    if enabled then
        for _, model in pairs(Workspace:GetChildren()) do
            if model.Name:lower():find("brainrot") and model.PrimaryPart then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.Parent = model
                esp.brainrots[model] = highlight
            end
        end
    else
        for model, highlight in pairs(esp.brainrots) do
            highlight:Destroy()
        end
        esp.brainrots = {}
    end
end

-- GUI Creation (Premium Style with Tabs & Sliders)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EinxrxsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Top-Right Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
ToggleBtn.Position = UDim2.new(1, -80, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "🧠"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = ToggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(100, 200, 255)
toggleStroke.Thickness = 2.5
toggleStroke.Parent = ToggleBtn

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 550)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 18)
frameCorner.Parent = MainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(100, 150, 255)
frameStroke.Thickness = 2
frameStroke.Parent = MainFrame

-- Title Bar (Draggable)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 18)
titleCorner.Parent = TitleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Einxrxs Hub v2.1 | Steal a BRAINROT"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = TitleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 0, 45)
closeBtn.Position = UDim2.new(1, -50, 0.5, -22.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- Tab Frame
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame
