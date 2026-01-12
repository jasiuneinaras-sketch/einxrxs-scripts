--// Einxrxs Mobile-Friendly Exploit Base 2026 - Enhanced Touch GUI
--// Features: Draggable GUI with Tabs, Fly (joystick + up/down), Noclip, ESP Toggle, Speed Slider, Auto Steal, Instant Proximity Prompts, Anti Ragdoll, Low Gravity, Auto Collect

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
    FlyEnabled = false,
    AutoSteal = false,
    InstantPrompts = false,
    AntiRagdoll = false,
    LowGravity = false,
    AutoCollect = false
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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
    else
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
local noclipConnection
local function toggleNoclip(enable)
    Settings.Noclip = enable
    if enable then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    end
end

--// Basic ESP (name tags above heads - visible on mobile)
local ESP_Connections = {}
local function toggleESP(enable)
    Settings.ESP_Enabled = enable
    
    if not enable then
        for _, conn in pairs(ESP_Connections) do conn:Disconnect() end
        ESP_Connections = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local tag = plr.Character.Head:FindFirstChild("ESPName")
                if tag then tag:Destroy() end
            end
        end
        return
    end
    
    local function addESP(plr)
        if plr == LocalPlayer then return end
        
        local conn = RunService.RenderStepped:Connect(function()
            local char = plr.Character
            if not char or not char:FindFirstChild("Head") then return end
            
            local head = char.Head
            local _, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            if onScreen then
                local tag = head:FindFirstChild("ESPName") or Instance.new("BillboardGui")
                tag.Name = "ESPName"
                tag.Adornee = head
                tag.Size = UDim2.new(0, 200, 0, 50)
                tag.StudsOffset = Vector3.new(0, 3, 0)
                tag.AlwaysOnTop = true
                tag.Parent = head
                
                local label = tag:FindFirstChild("Label") or Instance.new("TextLabel", tag)
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.new(1,0,0)
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.Name = "Label"
            end
        end)
        table.insert(ESP_Connections, conn)
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then addESP(plr) end
        plr.CharacterAdded:Connect(function() addESP(plr) end)
    end
    Players.PlayerAdded:Connect(function(plr)
        addESP(plr)
        plr.CharacterAdded:Connect(function() addESP(plr) end)
    end)
end

--// Instant Steal (general tools and accessories)
local function instantSteal()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local backpack = plr:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool.Parent = LocalPlayer.Backpack
                    end
                end
            end
            for _, item in pairs(plr.Character:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Accessory") then
                    item.Parent = LocalPlayer.Backpack or LocalPlayer.Character
                end
            end
        end
    end
    print("Instant Steal executed!")
end

--// Auto Steal (repeat instant steal)
local autoStealConnection
local function toggleAutoSteal(enable)
    Settings.AutoSteal = enable
    if enable then
        autoStealConnection = RunService.Heartbeat:Connect(function()
            instantSteal()
            task.wait(1)
        end)
    else
        if autoStealConnection then autoStealConnection:Disconnect() autoStealConnection = nil end
    end
end

--// Auto Collect (touch all collectibles)
local autoCollectConnection
local function toggleAutoCollect(enable)
    Settings.AutoCollect = enable
    if enable then
        autoCollectConnection = RunService.Heartbeat:Connect(function()
            local root = getRoot(LocalPlayer.Character)
            if root then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("BasePart") and v:FindFirstChildWhichIsA("TouchInterest") then
                        firetouchinterest(root, v, 0)
                        task.wait(0.1)
                        firetouchinterest(root, v, 1)
                    end
                end
            end
        end)
    else
        if autoCollectConnection then autoCollectConnection:Disconnect() autoCollectConnection = nil end
    end
end

--// Instant Proximity Prompts
local promptConnections = {}
local function toggleInstantPrompts(enable)
    Settings.InstantPrompts = enable
    if enable then
        for _, desc in pairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
                local conn = desc:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                    desc.HoldDuration = 0
                end)
                table.insert(promptConnections, conn)
            end
        end
        local addedConn = workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0
                local conn = desc:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                    desc.HoldDuration = 0
                end)
                table.insert(promptConnections, conn)
            end
        end)
        table.insert(promptConnections, addedConn)
    else
        for _, conn in pairs(promptConnections) do conn:Disconnect() end
        promptConnections = {}
    end
end

--// Anti Ragdoll
local antiRagdollConnection
local function toggleAntiRagdoll(enable)
    Settings.AntiRagdoll = enable
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if enable then
            antiRagdollConnection = hum.StateChanged:Connect(function(_, new)
                if new == Enum.HumanoidStateType.Ragdoll then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        else
            if antiRagdollConnection then antiRagdollConnection:Disconnect() antiRagdollConnection = nil end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if Settings.AntiRagdoll then
        toggleAntiRagdoll(true)
    end
    if Settings.Noclip then
        toggleNoclip(true)
    end
end)

--// Low Gravity
local function toggleLowGravity(enable)
    Settings.LowGravity = enable
    workspace.Gravity = enable and 50 or 196.2
end

--// ======================= NICE MOBILE GUI =======================
local gui = Instance.new("ScreenGui")
gui.Name = "EinxrxsExploit"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 400) -- Increased height to fit all buttons
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "Einxrxs Exploit - Mobile"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1,0,0,35)
tabFrame.Position = UDim2.new(0,0,0,40)
tabFrame.BackgroundTransparency = 1

local tabs = {"Main", "Visuals", "Movement"}
local tabContents = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -4, 1, -4)
    btn.Position = UDim2.new((i-1)/#tabs, 2, 0, 2)
    btn.BackgroundColor3 = (i==1 and Color3.fromRGB(60,60,60)) or Color3.fromRGB(45,45,45)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = tabFrame
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,0,1,-75)
    content.Position = UDim2.new(0,0,0,75)
    content.BackgroundTransparency = 1
    content.Visible = (i==1)
    content.Parent = mainFrame
    tabContents[tabName] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, c in pairs(tabContents) do c.Visible = false end
        tabContents[tabName].Visible = true
        for _, b in pairs(tabFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b.Text == tabName and Color3.fromRGB(60,60,60)) or Color3.fromRGB(45,45,45)
            end
        end
    end)
end

local function createButton(parent, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,50)
    btn.Position = UDim2.new(0.05,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 18
    btn.TextWrapped = true
    btn.Parent = parent
    
    local uic = Instance.new("UICorner", btn)
    uic.CornerRadius = UDim.new(0,8)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Main Tab
local mainTab = tabContents["Main"]
createButton(mainTab, "Toggle Fly", 10, function()
    if Settings.FlyEnabled then stopFly() else startFly() end
end)

createButton(mainTab, "Toggle Noclip", 70, function()
    toggleNoclip(not Settings.Noclip)
end)

createButton(mainTab, "Toggle Auto Steal", 130, function()
    toggleAutoSteal(not Settings.AutoSteal)
end)

createButton(mainTab, "Toggle Instant Prompts", 190, function()
    toggleInstantPrompts(not Settings.InstantPrompts)
end)

createButton(mainTab, "Toggle Anti Ragdoll", 250, function()
    toggleAntiRagdoll(not Settings.AntiRagdoll)
end)

createButton(mainTab, "Toggle Auto Collect", 310, function()
    toggleAutoCollect(not Settings.AutoCollect)
end)

-- Visuals Tab
local visualsTab = tabContents["Visuals"]
createButton(visualsTab, "Toggle ESP", 10, function()
    toggleESP(not Settings.ESP_Enabled)
end)

-- Movement Tab (Speed slider)
local moveTab = tabContents["Movement"]
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9,0,0,30)
speedLabel.Position = UDim2.new(0.05,0,0,10)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Speed: " .. Settings.FlySpeed
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 16
speedLabel.Parent = moveTab

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0.9,0,0,40)
sliderFrame.Position = UDim2.new(0.05,0,0,50)
sliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
sliderFrame.Parent = moveTab

local fill = Instance.new("Frame", sliderFrame)
fill.Size = UDim2.new(0.5,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(100,100,255)
fill.BorderSizePixel = 0

local uicSlider = Instance.new("UICorner", sliderFrame)
uicSlider.CornerRadius = UDim.new(0,8)

local dragging = false
sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

sliderFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = input.Position.X
        local relX = math.clamp((pos - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        Settings.FlySpeed = math.floor(relX * 200) + 10
        speedLabel.Text = "Fly Speed: " .. Settings.FlySpeed
    end
end)

createButton(moveTab, "Toggle Low Gravity", 100, function()
    toggleLowGravity(not Settings.LowGravity)
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0,8)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("Einxrxs Exploit Loaded! Mobile GUI ready - use joystick for fly direction")

-- PC fallback keybinds
if not isMobile then
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.G then
            if Settings.FlyEnabled then stopFly() else startFly() end
        end
    end)
end
