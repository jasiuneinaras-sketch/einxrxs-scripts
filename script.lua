-- Einxrxs-scripts! Universal Exploit for Steal a BRAINROT (Mobile + PC)
-- Date: January 2026 - Anticheat Bypass Edition
-- Features: Noclip, Velocity Speed, 3D Fly (camera direction), High Jump, Instant Steal, Safe Fly to Base
-- Works on BOTH Mobile & PC - automatic detection
-- Toggles show ON/OFF with color change

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Einxrxs-scripts!"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local conns = {}
local toggleButtons = {}

local function getRoot() return Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return Character:FindFirstChild("Humanoid") end

-- ======================================================
--                   UI SETUP (Improved for PC/Mobile)
-- ======================================================

-- Floating Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, isMobile and 70 or 60, 0, isMobile and 70 or 60)
ToggleBtn.Position = UDim2.new(1, isMobile and -80 or -70, 1, isMobile and -80 or -70)
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
MainFrame.Size = UDim2.new(0, isMobile and 340 or 380, 0, isMobile and 460 or 500)
MainFrame.Position = UDim2.new(0.5, -(isMobile and 170 or 190), 0.5, -(isMobile and 230 or 250))
MainFrame.BackgroundColor3 = Color3.fromRGB(22,22,32)
MainFrame.BackgroundTransparency = 0.08
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local fc = Instance.new("UICorner", MainFrame) fc.CornerRadius = UDim.new(0,18)
local fs = Instance.new("UIStroke", MainFrame) fs.Color = Color3.fromRGB(90,140,255) fs.Thickness = 2.2
local fg = Instance.new("UIGradient", MainFrame)
fg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40,40,60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25,25,45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,32))
}
fg.Rotation = 135

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,55)
TitleBar.BackgroundColor3 = Color3.fromRGB(32,32,48)

local tlc = Instance.new("UICorner", TitleBar) tlc.CornerRadius = UDim.new(0,18)
local tlg = Instance.new("UIGradient", TitleBar)
tlg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(55,65,95)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35,40,65))
}

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1,-70,1,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Einxrxs-scripts!"
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBlack

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,45,0,45)
CloseBtn.Position = UDim2.new(1,-52,0.5,-22.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210,40,40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
local clc = Instance.new("UICorner", CloseBtn) clc.CornerRadius = UDim.new(1,0)

-- Scrolling Content
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1,-20,1,-75)
Scroll.Position = UDim2.new(0,10,0,65)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = isMobile and 5 or 8
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100,160,255)

local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0,10)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

-- Draggable (works on PC & Mobile)
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
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

-- Toggle & Close
local openTween = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local closeTween = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

ToggleBtn.Activated:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, closeTween, {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.22)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, isMobile and 340 or 380, 0, isMobile and 460 or 500)
    else
        MainFrame.Visible = true
        TweenService:Create(MainFrame, openTween, {Size = UDim2.new(0, isMobile and 340 or 380, 0, isMobile and 460 or 500)}):Play()
    end
end)

CloseBtn.Activated:Connect(function()
    TweenService:Create(MainFrame, closeTween, {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.22)
    MainFrame.Visible = false
    MainFrame.Size = UDim2.new(0, isMobile and 340 or 380, 0, isMobile and 460 or 500)
end)

local function updateCanvas()
    Scroll.CanvasSize = UDim2.new(0,0,0,List.AbsoluteContentSize.Y + 30)
end
List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- ======================================================
--                   BUTTON CREATORS
-- ======================================================

local function createToggle(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.92,0,0,60)
    Btn.BackgroundColor3 = Color3.fromRGB(45,50,70)
    Btn.Text = text .. "  [OFF]"
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = Scroll

    local bc = Instance.new("UICorner", Btn) bc.CornerRadius = UDim.new(0,14)
    local bs = Instance.new("UIStroke", Btn) bs.Color = Color3.fromRGB(110,160,255) bs.Thickness = 1.8
    local bg = Instance.new("UIGradient", Btn)
    bg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(65,75,105)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45,50,70))
    }

    local state = false
    toggleButtons[text] = {btn = Btn, state = state}

    Btn.Activated:Connect(function()
        state = not state
        if state then
            Btn.Text = text .. "  [ON]"
            Btn.BackgroundColor3 = Color3.fromRGB(30,180,60)
            bg.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40,220,80)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20,140,50))
            }
            callback(true)
        else
            Btn.Text = text .. "  [OFF]"
            Btn.BackgroundColor3 = Color3.fromRGB(45,50,70)
            bg.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(65,75,105)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(45,50,70))
            }
            callback(false)
        end

        -- Press effect
        local press = TweenService:Create(Btn, TweenInfo.new(0.12), {Size = UDim2.new(0.88,0,0,54)})
        press:Play()
        press.Completed:Wait()
        TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = UDim2.new(0.92,0,0,60)}):Play()
    end)

    updateCanvas()
end

local function createAction(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.92,0,0,60)
    Btn.BackgroundColor3 = Color3.fromRGB(55,60,90)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = Scroll

    local bc = Instance.new("UICorner", Btn) bc.CornerRadius = UDim.new(0,14)
    local bs = Instance.new("UIStroke", Btn) bs.Color = Color3.fromRGB(130,180,255) bs.Thickness = 1.8

    Btn.Activated:Connect(function()
        local press = TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.4, Size = UDim2.new(0.88,0,0,54)})
        press:Play()
        press.Completed:Wait()
        callback()
        TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {BackgroundTransparency = 0, Size = UDim2.new(0.92,0,0,60)}):Play()
    end)

    updateCanvas()
end

-- ======================================================
--                   FEATURES (Anticheat Safe)
-- ======================================================

-- Noclip
createToggle("Noclip", function(enabled)
    if conns.noclip then conns.noclip:Disconnect() end
    if enabled then
        conns.noclip = RunService.Stepped:Connect(function()
            if Character then
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- Velocity Speed
local speed = 85
createToggle("Speed Boost", function(enabled)
    if conns.speed then conns.speed:Disconnect() end
    if enabled then
        conns.speed = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            local hum = getHum()
            if root and hum and hum.MoveDirection.Magnitude > 0 then
                root.AssemblyLinearVelocity = Vector3.new(
                    hum.MoveDirection.X * speed,
                    root.AssemblyLinearVelocity.Y,
                    hum.MoveDirection.Z * speed
                )
            end
        end)
    end
end)

-- Fly (PC: WASD + Mouse / Mobile: Camera direction)
local flySpeed = 90
createToggle("Fly", function(enabled)
    if conns.fly then conns.fly:Disconnect() end
    if enabled then
        conns.fly = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if root then
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0,0,0)

                -- PC controls
                if not isMobile then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                end

                -- Mobile: always fly in camera direction
                if isMobile or moveDir.Magnitude == 0 then
                    moveDir = cam.CFrame.LookVector
                end

                if moveDir.Magnitude > 0 then
                    root.AssemblyLinearVelocity = moveDir.Unit * flySpeed
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

-- High Jump
local jumpPower = 120
createToggle("Super Jump", function(enabled)
    if conns.jump then conns.jump:Disconnect() end
    if enabled then
        conns.jump = UserInputService.JumpRequest:Connect(function()
            local root = getRoot()
            if root then root.Velocity = Vector3.new(0, jumpPower, 0) end
        end)
    end
end)

-- Instant Steal
createAction("Instant Steal Nearest", function()
    local root = getRoot()
    if not root then return end

    local nearest, dist = nil, 120
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText and string.find(v.ActionText:lower(), "steal") then
            local model = v.Parent
            if model and model.PrimaryPart and model ~= Character then
                local d = (root.Position - model.PrimaryPart.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = v
                end
            end
        end
    end

    if nearest then
        fireproximityprompt(nearest)
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Einxrxs-scripts!", Text = "Stole nearest Brainrot!", Duration = 2.5
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Einxrxs-scripts!", Text = "No stealable found nearby!", Duration = 2.5
        })
    end
end)

-- Safe Fly to Nearest Base
local function smoothFlyTo(pos)
    local root = getRoot()
    if not root then return end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = root

    local done = false
    local conn; conn = RunService.Heartbeat:Connect(function()
        if not root.Parent then conn:Disconnect() bv:Destroy() return end
        local d = (root.Position - pos).Magnitude
        if d < 12 then
            done = true
            conn:Disconnect()
            bv:Destroy()
            return
        end
        local dir = (pos - root.Position).Unit
        bv.Velocity = dir * 110 + Vector3.new(0, 25, 0) -- slight upward bias
    end)

    spawn(function()
        task.wait(8)
        if not done then
            conn:Disconnect()
            bv:Destroy()
        end
    end)
end

createAction("Fly to Nearest Base", function()
    local root = getRoot()
    if not root then return end

    local target, dist = nil, 6000
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local pr = plr.Character:FindFirstChild("HumanoidRootPart")
            if pr then
                local d = (root.Position - pr.Position).Magnitude
                if d < dist then
                    dist = d
                    target = pr
                end
            end
        end
    end

    if target then
        local land = target.Position + Vector3.new(math.random(-10,10), 12, math.random(-10,10))
        smoothFlyTo(land)
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Einxrxs-scripts!", Text = "Flying to nearest base...", Duration = 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title = "Einxrxs-scripts!", Text = "No players found!", Duration = 2.5
        })
    end
end)

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(new)
    Character = new
    task.wait(0.8)
end)

game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "Einxrxs-scripts! Loaded",
    Text = "PC & Mobile supported! Use Fly/Noclip/Speed. Toggle button bottom-right.",
    Duration = 6
})

print("Einxrxs-scripts! Universal (PC+Mobile) - Anticheat Safe - Enjoy!")
