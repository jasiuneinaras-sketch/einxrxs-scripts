-- Einxrxs-scripts! Mobile-Only Exploit for Steal a BRAINROT
-- Features: Instant Steal Nearest (fires ProximityPrompts), Base Tween (to nearest player), Noclip, Speed, Inf Jump
-- Smooth, clean, draggable GUI with animations - 10x better!

if not game:GetService("UserInputService").TouchEnabled then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Einxrxs-scripts!";
        Text = "Mobile only! Exiting.";
        Duration = 3
    })
    return
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Einxrxs-scripts!"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle Button (small floating)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(1, -70, 1, -70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = "🧠"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(100, 200, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn
local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
}
ToggleGradient.Rotation = 45
ToggleGradient.Parent = ToggleBtn

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 16)
FrameCorner.Parent = MainFrame
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(100, 150, 255)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame
local FrameGradient = Instance.new("UIGradient")
FrameGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
}
FrameGradient.Rotation = 135
FrameGradient.Parent = MainFrame

-- Title Bar (draggable)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 70, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 45, 70))
}
TitleGradient.Parent = TitleBar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Einxrxs-scripts!"
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- ScrollingFrame for buttons
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
ScrollFrame.Parent = MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- Draggable
local dragging = false
local dragStart = nil
local startPos = nil
local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- Toggle MainFrame
local openTween = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local closeTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
ToggleBtn.Activated:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, closeTween, {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.2)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 350, 0, 400)
    else
        MainFrame.Visible = true
        TweenService:Create(MainFrame, openTween, {Size = UDim2.new(0, 350, 0, 400)}):Play()
    end
end)
CloseBtn.Activated:Connect(function()
    TweenService:Create(MainFrame, closeTween, {Size = UDim2.new(0, 0, 0, 0)}):Play()
    wait(0.2)
    MainFrame.Visible = false
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
end)

-- States
local noclip = false
local speedEnabled = false
local infJump = false

-- Update CanvasSize
local function updateCanvas()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- Create Button Function
local function createButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 55)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.TextScaled = true
    Btn.Font = Enum.Font.Gotham
    Btn.LayoutOrder = UIListLayout.AbsoluteContentSize.Y / 60
    Btn.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(120, 170, 255)
    BtnStroke.Thickness = 1.5
    BtnStroke.Parent = Btn
    
    local BtnGradient = Instance.new("UIGradient")
    BtnGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 75, 105)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 50, 70))
    }
    BtnGradient.Parent = Btn
    
    -- Press Animation
    local pressInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
    local releaseInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back)
    Btn.Activated:Connect(function()
        local press = TweenService:Create(Btn, pressInfo, {Size = UDim2.new(0.85, 0, 0, 48)})
        press:Play()
        press.Completed:Wait()
        local release = TweenService:Create(Btn, releaseInfo, {Size = Btn.Size})
        release:Play()
        callback()
    end)
    
    updateCanvas()
    return Btn
end

-- Functions
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local function getRoot()
    return Character:FindFirstChild("HumanoidRootPart")
end

local noclipConn
createButton("🛡️ Toggle Noclip", function()
    noclip = not noclip
    if noclipConn then noclipConn:Disconnect() end
    if noclip then
        noclipConn = RunService.Stepped:Connect(function()
            if Character then
                for _, part in Character:GetDescendants() do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

local speedConn
createButton("⚡ Toggle Speed (80)", function()
    speedEnabled = not speedEnabled
    local humanoid = Character:FindFirstChild("Humanoid")
    if speedEnabled then
        speedConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            humanoid.WalkSpeed = 80
        end)
        humanoid.WalkSpeed = 80
    else
        if speedConn then speedConn:Disconnect() end
        humanoid.WalkSpeed = 16
    end
end)

local jumpConn
createButton("🦘 Infinite Jump", function()
    infJump = not infJump
    if infJump then
        jumpConn = UserInputService.JumpRequest:Connect(function()
            local humanoid = Character:FindFirstChild("Humanoid")
            if humanoid then humanoid:ChangeState("Jumping") end
        end)
    else
        if jumpConn then jumpConn:Disconnect() end
    end
end)

-- Instant Steal
createButton("🚀 Instant Steal Nearest", function()
    local root = getRoot()
    if not root then return end
    local nearestPrompt, minDist = nil, math.huge
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("ProximityPrompt") and obj.ActionText:lower():find("steal") then
            local model = obj.Parent
            if model ~= Character and model.PrimaryPart then
                local dist = (root.Position - model.PrimaryPart.Position).Magnitude
                if dist < minDist and dist < 100 then
                    minDist = dist
                    nearestPrompt = obj
                end
            end
        end
    end
    if nearestPrompt then
        fireproximityprompt(nearestPrompt)
        game.StarterGui:SetCore("SendNotification", {Title="Einxrxs-scripts!", Text="Stole nearest Brainrot!", Duration=2})
    else
        game.StarterGui:SetCore("SendNotification", {Title="Einxrxs-scripts!", Text="No stealable Brainrot nearby!", Duration=2})
    end
end)

-- Base Tween
createButton("✨ Tween to Nearest Base", function()
    local root = getRoot()
    if not root then return end
    local targetRoot, minDist = nil, math.huge
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                local dist = (root.Position - pRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    targetRoot = pRoot
                end
            end
        end
    end
    if targetRoot then
        local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = targetRoot.CFrame + Vector3.new(math.random(-5,5), 10, math.random(-5,5))})
        tween:Play()
        game.StarterGui:SetCore("SendNotification", {Title="Einxrxs-scripts!", Text="Tweened to nearest base!", Duration=2})
    else
        game.StarterGui:SetCore("SendNotification", {Title="Einxrxs-scripts!", Text="No nearby bases!", Duration=2})
    end
end)

-- Handle respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    wait(1)
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Einxrxs-scripts! Loaded ✅";
    Text = "Mobile GUI ready! Toggle bottom-right.";
    Duration = 4
})
print("Einxrxs-scripts! Loaded - Enjoy stealing Brainrots! 🧠")
