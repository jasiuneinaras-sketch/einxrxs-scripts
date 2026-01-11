-- Einxrxs-scripts! Universal Exploit for Steal a BRAINROT (PC + Mobile) - January 2026
-- Now longer & more feature-rich! Added: Player ESP (BillboardGui + Tracers using Drawing), Brainrot Finder ESP
-- Top-Right Toggle Button, Smooth UI, Anticheat Bypass (velocity + safe CFrame updates)
-- Features: Noclip, Speed Boost, Fly (PC WASD + Mouse / Mobile Camera), Super Jump, Instant Steal (TP close + fire), Safe Fly to Base, Player ESP, Brainrot ESP

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local conns = {}
local toggleStates = {}
local espObjects = {}  -- For cleaning up ESP

local function getRoot() return Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return Character:FindFirstChild("Humanoid") end

-- Simple anticheat hook (block common kick remotes if detected)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        local oldFire = obj.FireServer
        obj.FireServer = function(self, ...)
            local args = {...}
            if args[1] and (tostring(args[1]):lower():find("kick") or tostring(args[1]):lower():find("ban")) then
                return -- Block kick attempt
            end
            return oldFire(self, ...)
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Einxrxs-scripts!"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- TOP-RIGHT Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, isMobile and 70 or 60, 0, isMobile and 70 or 60)
ToggleBtn.Position = UDim2.new(1, -80, 0, 20)  -- Top right
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "🧠"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui

local tc = Instance.new("UICorner", ToggleBtn) tc.CornerRadius = UDim.new(1,0)
local ts = Instance.new("UIStroke", ToggleBtn) ts.Color = Color3.fromRGB(100,200,255) ts.Thickness = 2.5
local tg = Instance.new("UIGradient", ToggleBtn)
tg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(50,50,70)), ColorSequenceKeypoint.new(1,Color3.fromRGB(20,20,40))}
tg.Rotation = 45

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, isMobile and 340 or 400, 0, isMobile and 520 or 580)
MainFrame.Position = UDim2.new(0.5, -(isMobile and 170 or 200), 0.5, -(isMobile and 260 or 290))
MainFrame.BackgroundColor3 = Color3.fromRGB(22,22,32)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local fc = Instance.new("UICorner", MainFrame) fc.CornerRadius = UDim.new(0,20)
local fs = Instance.new("UIStroke", MainFrame) fs.Color = Color3.fromRGB(90,140,255) fs.Thickness = 2.5
local fg = Instance.new("UIGradient", MainFrame)
fg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(40,40,60)), ColorSequenceKeypoint.new(0.5,Color3.fromRGB(25,25,45)), ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,32))}
fg.Rotation = 135

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,60)
TitleBar.BackgroundColor3 = Color3.fromRGB(32,32,48)
local tlc = Instance.new("UICorner", TitleBar) tlc.CornerRadius = UDim.new(0,20)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1,-80,1,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Einxrxs-scripts! 🧠"
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBlack

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,50,0,50)
CloseBtn.Position = UDim2.new(1,-60,0.5,-25)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210,40,40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
local clc = Instance.new("UICorner", CloseBtn) clc.CornerRadius = UDim.new(1,0)

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1,-20,1,-80)
Scroll.Position = UDim2.new(0,10,0,70)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = isMobile and 6 or 10
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100,160,255)

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0,12)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Draggable
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Toggle / Close Animations
local openTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

ToggleBtn.Activated:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, closeTweenInfo, {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.25)
        MainFrame.Visible = false
    else
        MainFrame.Visible = true
        TweenService:Create(MainFrame, openTweenInfo, {Size = UDim2.new(0, isMobile and 340 or 400, 0, isMobile and 520 or 580)}):Play()
    end
end)

CloseBtn.Activated:Connect(function()
    TweenService:Create(MainFrame, closeTweenInfo, {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.25)
    MainFrame.Visible = false
end)

local function updateCanvasSize()
    Scroll.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 40)
end
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

-- Toggle Button Creator
local function createToggle(name, emoji, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.92,0,0,65)
    Btn.BackgroundColor3 = Color3.fromRGB(45,50,70)
    Btn.Text = emoji .. " " .. name .. "  [OFF]"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = Scroll

    local corner = Instance.new("UICorner", Btn) corner.CornerRadius = UDim.new(0,16)
    local stroke = Instance.new("UIStroke", Btn) stroke.Color = Color3.fromRGB(110,160,255) stroke.Thickness = 2

    local state = false
    toggleStates[name] = {btn = Btn, state = state}

    Btn.Activated:Connect(function()
        state = not state
        if state then
            Btn.Text = emoji .. " " .. name .. "  [ON]"
            Btn.BackgroundColor3 = Color3.fromRGB(40,180,60)
        else
            Btn.Text = emoji .. " " .. name .. "  [OFF]"
            Btn.BackgroundColor3 = Color3.fromRGB(45,50,70)
        end
        callback(state)
        -- Press effect
        local pressTween = TweenService:Create(Btn, TweenInfo.new(0.12), {Size = UDim2.new(0.88,0,0,58)})
        pressTween:Play()
        pressTween.Completed:Wait()
        TweenService:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0.92,0,0,65)}):Play()
    end)

    updateCanvasSize()
end

-- Action Button
local function createAction(name, emoji, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.92,0,0,65)
    Btn.BackgroundColor3 = Color3.fromRGB(55,60,90)
    Btn.Text = emoji .. " " .. name
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = Scroll

    local corner = Instance.new("UICorner", Btn) corner.CornerRadius = UDim.new(0,16)
    local stroke = Instance.new("UIStroke", Btn) stroke.Color = Color3.fromRGB(130,180,255) stroke.Thickness = 2

    Btn.Activated:Connect(function()
        local press = TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.3})
        press:Play()
        callback()
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    end)

    updateCanvasSize()
end

-- ================================================
-- FEATURES
-- ================================================

-- Noclip
createToggle("Noclip", "🛡️", function(enabled)
    if conns.noclip then conns.noclip:Disconnect() end
    if enabled then
        conns.noclip = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

-- Speed Boost
local speed = 90
createToggle("Speed Boost", "⚡", function(enabled)
    if conns.speed then conns.speed:Disconnect() end
    if enabled then
        conns.speed = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            local hum = getHum()
            if root and hum and hum.MoveDirection.Magnitude > 0 then
                root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * speed, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * speed)
            end
        end)
    end
end)

-- Fly
local flySpeed = 95
createToggle("Fly", "✈️", function(enabled)
    if conns.fly then conns.fly:Disconnect() end
    if enabled then
        conns.fly = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if root then
                local cam = workspace.CurrentCamera
                local move = Vector3.new(0,0,0)

                if not isMobile then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
                else
                    move = cam.CFrame.LookVector
                end

                if move.Magnitude > 0 then
                    root.AssemblyLinearVelocity = move.Unit * flySpeed
                else
                    root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                end
            end
        end)
    else
        local root = getRoot()
        if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
    end
end)

-- Super Jump
createToggle("Super Jump", "🦘", function(enabled)
    if conns.jump then conns.jump:Disconnect() end
    if enabled then
        conns.jump = UserInputService.JumpRequest:Connect(function()
            local root = getRoot()
            if root then root.Velocity = Vector3.new(0, 140, 0) end
        end)
    end
end)

-- Instant Steal (Fixed: Teleport close first to avoid distance check, then fire prompt)
createAction("Instant Steal Nearest", "🚀", function()
    local root = getRoot()
    if not root then return end

    local nearestPrompt, minDist = nil, 80
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText and string.find(obj.ActionText:lower(), "steal") then
            local model = obj.Parent
            if model and model.PrimaryPart and model ~= Character then
                local dist = (root.Position - model.PrimaryPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestPrompt = obj
                end
            end
        end
    end

    if nearestPrompt then
        -- Safe close TP
        local targetPos = nearestPrompt.Parent.PrimaryPart.Position + Vector3.new(0, 5, 0)
        local oldCFrame = root.CFrame
        root.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
        fireproximityprompt(nearestPrompt)
        task.wait(0.15)
        root.CFrame = oldCFrame  -- Return to avoid detection
        StarterGui:SetCore("SendNotification", {Title="Einxrxs!", Text="Stole nearest Brainrot!", Duration=2})
    else
        StarterGui:SetCore("SendNotification", {Title="Einxrxs!", Text="No stealable nearby!", Duration=2})
    end
end)

-- Safe Fly to Nearest Base (CFrame lerp to avoid instant detection)
local function safeFlyTo(pos)
    local root = getRoot()
    if not root then return end
    local start = root.Position
    local dist = (pos - start).Magnitude
    local steps = math.ceil(dist / 50)
    for i = 1, steps do
        local progress = i / steps
        root.CFrame = CFrame.new(start:Lerp(pos, progress) + Vector3.new(0, 8, 0))
        task.wait(0.03)
    end
end

createAction("Fly to Nearest Base", "✨", function()
    local root = getRoot()
    if not root then return end

    local target, minDist = nil, 8000
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local base = workspace:FindFirstChild(plr.Name) or workspace:FindFirstChild(plr.Name .. "_Base")
            if base and base:IsA("Model") and base.PrimaryPart then
                local d = (root.Position - base.PrimaryPart.Position).Magnitude
                if d < minDist then minDist = d target = base.PrimaryPart.Position end
            end
        end
    end

    if target then
        safeFlyTo(target + Vector3.new(math.random(-12,12), 12, math.random(-12,12)))
        StarterGui:SetCore("SendNotification", {Title="Einxrxs!", Text="Flying to nearest base!", Duration=3})
    else
        StarterGui:SetCore("SendNotification", {Title="Einxrxs!", Text="No bases found!", Duration=2})
    end
end)

-- ================================================
-- ESP FEATURES (Player & Brainrot)
-- ================================================

-- Player ESP (Name + Health + Tracers using Drawing)
local drawingTracers = {}
local function createPlayerESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local function addESP(char)
                if not char then return end
                local head = char:FindFirstChild("Head")
                if not head then return end

                -- BillboardGui for name/health
                local bg = Instance.new("BillboardGui")
                bg.Name = "EinxrxsESP"
                bg.Adornee = head
                bg.Size = UDim2.new(0, 200, 0, 60)
                bg.StudsOffset = Vector3.new(0, 3, 0)
                bg.AlwaysOnTop = true
                bg.Parent = head

                local text = Instance.new("TextLabel", bg)
                text.Size = UDim2.new(1,0,1,0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.new(1,1,0)
                text.TextScaled = true
                text.Text = plr.Name .. "\n[Health: ?]"

                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum:GetPropertyChangedSignal("Health"):Connect(function()
                        text.Text = plr.Name .. "\n[Health: " .. math.floor(hum.Health) .. "]"
                    end)
                    text.Text = plr.Name .. "\n[Health: " .. math.floor(hum.Health) .. "]"
                end

                espObjects[#espObjects+1] = bg

                -- Tracer (Drawing line)
                local tracer = Drawing.new("Line")
                tracer.Visible = true
                tracer.Color = Color3.new(1,0,0)
                tracer.Thickness = 2
                tracer.Transparency = 1
                drawingTracers[char] = tracer
            end

            if plr.Character then addESP(plr.Character) end
            plr.CharacterAdded:Connect(addESP)
        end
    end
end

-- Brainrot ESP (highlight models named "Brainrot" or similar)
local function createBrainrotESP()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():find("brainrot") and obj.PrimaryPart then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.new(0,1,1)
            highlight.OutlineColor = Color3.new(1,1,0)
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 0
            highlight.Adornee = obj
            highlight.Parent = obj
            espObjects[#espObjects+1] = highlight
        end
    end
end

createToggle("Player ESP", "👀", function(enabled)
    if enabled then
        createPlayerESP()
        -- Update tracers every frame
        conns.espTracer = RunService.RenderStepped:Connect(function()
            for char, tracer in pairs(drawingTracers) do
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                    tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    tracer.Visible = onScreen
                else
                    tracer.Visible = false
                end
            end
        end)
    else
        if conns.espTracer then conns.espTracer:Disconnect() end
        for _, obj in pairs(espObjects) do if obj then obj:Destroy() end end
        for _, tracer in pairs(drawingTracers) do tracer:Remove() end
        espObjects = {}
        drawingTracers = {}
    end
end)

createToggle("Brainrot ESP", "🧠", function(enabled)
    if enabled then
        createBrainrotESP()
    else
        for _, obj in pairs(espObjects) do if obj and obj:IsA("Highlight") then obj:Destroy() end end
    end
end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(0.5)
end)

StarterGui:SetCore("SendNotification", {
    Title = "Einxrxs-scripts! Loaded",
    Text = "ESP + All Features ready! Toggle top-right 🧠",
    Duration = 5
})

print("Einxrxs-scripts! Full version with ESP - Enjoy stealing Brainrots!")
