--// Einxrxs Mobile-Friendly Exploit Base 2026 - Enhanced Touch GUI + Brainrot Vibes 🧠💀
--// Features: Draggable GUI with Tabs, Fly (joystick + up/down), Noclip, ESP Toggle, Speed/Walk/Jump Sliders, Instant/Auto Steal, Infinite Jump, God Mode, Invis, Dupe Tool, Brainrot Mode (chaotic colors + console spam)
--// Improved 10x: Smoother animations, scrolling frames for tabs, more brainrot emojis, better mobile touch handling, added teleport to player, full-screen toggle, anti-kick, performance optimizations

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// Settings
local Settings = {
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    ESP_Enabled = false,
    Noclip = false,
    FlyEnabled = false,
    InfiniteJump = false,
    GodMode = false,
    Invisible = false,
    AutoSteal = false,
    BrainrotMode = false,
    AntiKick = false,
    FullScreen = false
}

--// Root
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

--// Fly system (optimized for mobile with smoother joystick control)
local flyBV, flyBG
local flyConnection

local function updateFly()
    local char = LocalPlayer.Character
    local root = getRoot(char)
    if not root or not Settings.FlyEnabled then return end
    
    local cam = Workspace.CurrentCamera
    local moveDir = Vector3.new()
    
    if not isMobile then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
    else
        -- Improved mobile: use Humanoid.MoveDirection for joystick
        moveDir = cam.CFrame.LookVector * LocalPlayer.Character.Humanoid.MoveDirection.Magnitude
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) * Settings.FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) * Settings.FlySpeed end
    end
    
    if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
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
    
    flyConnection = RunService:BindToRenderStep("FlyUpdate", Enum.RenderPriority.Input.Value, updateFly)
end

local function stopFly()
    Settings.FlyEnabled = false
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if flyConnection then RunService:UnbindFromRenderStep("FlyUpdate") flyConnection = nil end
end

--// Noclip (optimized loop)
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

--// WalkSpeed and JumpPower (applied in Heartbeat for smoothness)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.WalkSpeed
        hum.JumpPower = Settings.JumpPower
    end
end)

--// ESP (improved with distance and health, always on top)
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
            if not char or not char:FindFirstChild("Head") or not char:FindFirstChildOfClass("Humanoid") then return end
            
            local head = char.Head
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = getRoot(LocalPlayer.Character)
            local dist = root and (root.Position - head.Position).Magnitude or 0
            
            local _, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
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
                label.Text = plr.Name .. "\nHealth: " .. math.floor(hum.Health) .. "\nDist: " .. math.floor(dist)
                label.TextColor3 = Color3.new(1,0,0)
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.Name = "Label"
            else
                local tag = head:FindFirstChild("ESPName")
                if tag then tag:Destroy() end
            end
        end)
        table.insert(ESP_Connections, conn)
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        addESP(plr)
        plr.CharacterAdded:Connect(function() addESP(plr) end)
    end
    Players.PlayerAdded:Connect(function(plr)
        addESP(plr)
        plr.CharacterAdded:Connect(function() addESP(plr) end)
    end)
end

--// Instant Steal (steals tools + hats/accessories)
local function instantSteal()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            -- Steal tools from backpack and character
            if plr:FindFirstChild("Backpack") then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool.Parent = LocalPlayer.Backpack
                    end
                end
            end
            for _, tool in pairs(plr.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = LocalPlayer.Backpack
                end
            end
            -- Steal accessories (hats, etc.)
            for _, acc in pairs(plr.Character:GetChildren()) do
                if acc:IsA("Accessory") then
                    acc.Parent = LocalPlayer.Character
                end
            end
        end
    end
    print("💀 Instant Steal executed! Tools + accessories stolen 💀")
end

--// Auto Steal (every 5s, configurable)
local autoStealConn
local function toggleAutoSteal(enable)
    Settings.AutoSteal = enable
    if enable then
        autoStealConn = RunService.Heartbeat:Connect(function()
            instantSteal()
            task.wait(5) -- Reduced spam
        end)
    else
        if autoStealConn then autoStealConn:Disconnect() autoStealConn = nil end
    end
end

--// Dupe Tool (dupe equipped or all in backpack)
local function dupeTool()
    local backpack = LocalPlayer.Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local clone = tool:Clone()
            clone.Parent = backpack
        end
    end
    local char = LocalPlayer.Character
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        local clone = equipped:Clone()
        clone.Parent = backpack
    end
    print("🧠 Tools duped! 🧠")
end

--// Infinite Jump
local infiniteJumpConn
local function toggleInfiniteJump(enable)
    Settings.InfiniteJump = enable
    if enable then
        infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infiniteJumpConn then infiniteJumpConn:Disconnect() infiniteJumpConn = nil end
    end
end

--// God Mode (inf health + no death)
local godConn
local function toggleGodMode(enable)
    Settings.GodMode = enable
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if enable then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            godConn = hum.HealthChanged:Connect(function()
                hum.Health = math.huge
            end)
        else
            if godConn then godConn:Disconnect() godConn = nil end
            hum.MaxHealth = 100
            hum.Health = 100
        end
    end
end

--// Invisibility (transparency + name hide)
local function toggleInvisible(enable)
    Settings.Invisible = enable
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = enable and 1 or 0
            elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                part.Enabled = not enable
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            local face = head:FindFirstChild("face")
            if face then face.Transparency = enable and 1 or 0 end
        end
    end
end

--// Anti-Kick (hook kick functions)
local function toggleAntiKick(enable)
    Settings.AntiKick = enable
    if enable then
        local oldNamecall = getrawmetatable(game).__namecall
        setreadonly(getrawmetatable(game), false)
        getrawmetatable(game).__namecall = function(self, ...)
            local args = {...}
            if getnamecallmethod() == "Kick" then
                print("💀 Kick attempt blocked! 💀")
                return
            end
            return oldNamecall(self, ...)
        end
    end
end

--// Teleport to Player (dropdown in GUI)
local function teleportToPlayer(plrName)
    local target = Players:FindFirstChild(plrName)
    if target and target.Character then
        local root = getRoot(LocalPlayer.Character)
        if root then
            root.CFrame = getRoot(target.Character).CFrame + Vector3.new(0, 5, 0)
        end
    end
end

--// Brainrot Mode (chaotic colors, emojis, console spam)
local function applyBrainrotTheme(enable)
    Settings.BrainrotMode = enable
    local bgColor = enable and Color3.fromRGB(147, 0, 255) or Color3.fromRGB(25, 25, 25)
    local titleColor = enable and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(35,35,35)
    local btnColor = enable and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(55,55,55)
    
    mainFrame.BackgroundColor3 = bgColor
    title.BackgroundColor3 = titleColor
    for _, btn in pairs(mainFrame:GetDescendants()) do
        if btn:IsA("TextButton") and btn.Name ~= "BrainBtn" and btn.Name ~= "CloseBtn" then
            btn.BackgroundColor3 = btnColor
        end
    end
    
    if enable then
        for i = 1, 10 do  -- 10x spam for 10x better
            print("🧠💀 BRAINROT ACTIVATED 💀🧠 " .. i)
            task.wait(0.1)
        end
    else
        print("Brainrot deactivated... back to normal 😔")
    end
end

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    if Settings.Invisible then toggleInvisible(true) end
    if Settings.GodMode then toggleGodMode(true) end
    if Settings.Noclip then toggleNoclip(true) end
end)

--// ======================= IMPROVED MOBILE GUI (10x better: scrolling, animations, full-screen, dropdowns) =======================
local gui = Instance.new("ScreenGui")
gui.Name = "EinxrxsExploit"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true  -- For full-screen support

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 500)  -- Larger for more content
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = U
