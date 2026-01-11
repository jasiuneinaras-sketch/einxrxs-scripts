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
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// Basic ESP (toggleable, simple name tags for now - expand later)
local ESP_Connections = {}
local function toggleESP(enable)
    Settings.ESP_Enabled = enable
    
    if not enable then
        for _, conn in pairs(ESP_Connections) do conn:Disconnect() end
        ESP_Connections = {}
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
                -- Simple billboard for mobile (text above head)
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
end

--// ======================= NICE MOBILE GUI =======================
local gui = Instance.new("ScreenGui")
gui.Name = "EinxrxsExploit"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Main Frame (draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 320)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
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

-- Tab buttons
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1,0,0,35)
tabFrame.Position = UDim2.new(0,0,0,40)
tabFrame.BackgroundTransparency = 1

local tabs = {"Main", "Visuals", "Movement"}
local currentTab = 1
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
        currentTab = i
        -- Highlight active tab
        for _, b in pairs(tabFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b.Text == tabName and Color3.fromRGB(60,60,60)) or Color3.fromRGB(45,45,45)
            end
        end
    end)
end

-- Helper to create big touch button
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
    print("Fly: " .. tostring(Settings.FlyEnabled))
end)

createButton(mainTab, "Toggle Noclip", 70, function()
    Settings.Noclip = not Settings.Noclip
    print("Noclip: " .. tostring(Settings.Noclip))
end)

-- Visuals Tab
local visualsTab = tabContents["Visuals"]
createButton(visualsTab, "Toggle ESP", 10, function()
    toggleESP(not Settings.ESP_Enabled)
    print("ESP: " .. tostring(Settings.ESP_Enabled))
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
sliderFrame.Position = UDim2.new(0
