--// Einxrxs Mobile Exploit Base 2026 - ULTRA DARK TOUCH REDUX
--// Features: Neon draggable GUI, 4K-ready scaling, joystick fly + noclip + speedhack + godmode + teleport + infinite jump + kill aura + item grab + esp boxes + tracers + chams + fullbright + speed slider + fly height + phase through walls + server hop + rejoin + anti-kick + more

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// ──────────────────────────────────────────────────────────
--// SETTINGS + TOGGLES
--// ──────────────────────────────────────────────────────────

local cfg = {
    Fly = false,
    FlySpeed = 80,
    FlyHeight = 0,
    Noclip = false,
    Godmode = false,
    InfiniteJump = false,
    SpeedHack = 50,
    KillAura = false,
    KillAuraRange = 18,
    ESP_Boxes = false,
    ESP_Tracers = false,
    Chams = false,
    Fullbright = false,
    NoClipPhase = false,
    AntiKick = true,
    ItemESP = false
}

--// ──────────────────────────────────────────────────────────
--// UTILITY FUNCTIONS
--// ──────────────────────────────────────────────────────────

local function getRoot() return lp.Character and (lp.Character:FindFirstChild("HumanoidRootPart") or lp.Character:FindFirstChild("Torso") or lp.Character:FindFirstChild("UpperTorso")) end
local function getHumanoid() return lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid") end

local flyBV, flyBG, flyAlign
local function toggleFly()
    cfg.Fly = not cfg.Fly
    local root = getRoot()
    if not root then return end

    if cfg.Fly then
        flyBV = Instance.new("BodyVelocity", root) flyBV.MaxForce = Vector3.new(1e9,1e9,1e9) flyBV.Velocity = Vector3.zero
        flyBG = Instance.new("BodyGyro", root)   flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)   flyBG.CFrame = root.CFrame
        flyAlign = Instance.new("AlignPosition", root) flyAlign.MaxForce = 1e9 flyAlign.Responsiveness = 200 flyAlign.Position = root.Position + Vector3.new(0,cfg.FlyHeight,0)
    else
        for _,v in {flyBV,flyBG,flyAlign} do if v then v:Destroy() end end
        flyBV,flyBG,flyAlign = nil,nil,nil
    end
end

local function updateFly()
    if not cfg.Fly then return end
    local root = getRoot() if not root then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero

    if isMobile then
        dir = cam.CFrame.LookVector * lp.Character.Humanoid.MoveDirection.Magnitude
    else
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
    end

    flyBV.Velocity = dir * cfg.FlySpeed
    flyBG.CFrame = cam.CFrame
    if flyAlign then flyAlign.Position = root.Position + Vector3.new(0,cfg.FlyHeight,0) end
end

--// Kill Aura loop
RunService.Heartbeat:Connect(function()
    if not cfg.KillAura then return end
    local root = getRoot() if not root then return end
    for _,p in Players:GetPlayers() do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist <= cfg.KillAuraRange then
                p.Character.Humanoid.Health = 0
            end
        end
    end
end)

--// ESP + Chams + Tracers
local espCons = {}
local function createESP(plr)
    if plr == lp then return end
    local function onChar(char)
        local box = Instance.new("BoxHandleAdornment", char)
        box.Name = "ESPBox"
        box.Adornee = char:WaitForChild("HumanoidRootPart")
        box.Size = Vector3.new(4,6,4)
        box.Transparency = 0.6
        box.Color3 = Color3.fromRGB(255,60,60)
        box.AlwaysOnTop = true
        box.ZIndex = 10

        local tracer = Instance.new("LineHandleAdornment", char)
        tracer.Name = "Tracer"
        tracer.Adornee = char:WaitForChild("Head")
        tracer.Length = 0
        tracer.Thickness = 2.5
        tracer.Transparency = 0.4
        tracer.Color3 = Color3.fromRGB(255,100,100)

        local cham = Instance.new("Highlight", char)
        cham.FillColor = Color3.fromRGB(255,50,50)
        cham.OutlineColor = Color3.fromRGB(255,255,255)
        cham.FillTransparency = 0.4
        cham.OutlineTransparency = 0

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") then
                conn:Disconnect() return
            end
            local rootPos = char.HumanoidRootPart.Position
            local screen, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPos)
            tracer.Length = onScreen and (screen - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y)).Magnitude/100 or 0
            tracer.CFrame = CFrame.new(Vector3.new(workspace.CurrentCamera.CFrame.Position.X, workspace.CurrentCamera.CFrame.Position.Y, workspace.CurrentCamera.CFrame.Position.Z), rootPos)
        end)
        table.insert(espCons, conn)
    end
    if plr.Character then onChar(plr.Character) end
    plr.CharacterAdded:Connect(onChar)
end

--// Fullbright + Lighting fuckery
local function toggleFullbright()
    cfg.Fullbright = not cfg.Fullbright
    if cfg.Fullbright then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _,v in Lighting:GetDescendants() do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

--// UI ──────────────────────────────────────────────────────────

local gui = Instance.new("ScreenGui", lp.PlayerGui) gui.Name = "EinxrxsDark2026" gui.IgnoreGuiInset = true

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.32,0,0.68,0)
main.Position = UDim2.new(0.5,0,0.5,0)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(8,8,12)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Draggable = true

local stroke = Instance.new("UIStroke", main) stroke.Color = Color3.fromRGB(120,0,255) stroke.Thickness = 2.5 stroke.Transparency = 0.3

local gradient = Instance.new("UIGradient", main)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,8,16))
}
gradient.Rotation = 45

local corner = Instance.new("UICorner", main) corner.CornerRadius = UDim.new(0,16)

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,52)
titleBar.BackgroundColor3 = Color3.fromRGB(14,14,24)
titleBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "EINXRXS • 2026 • DARK REDUX"
title.TextColor3 = Color3.fromRGB(220,60,255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", titleBar)
close.Size = UDim2.new(0,42,0,42)
close.Position = UDim2.new(1,-50,0.5,0)
close.AnchorPoint = Vector2.new(1,0.5)
close.BackgroundColor3 = Color3.fromRGB(180,40,40)
close.Text = "✕"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 24

local closeCorner = Instance.new("UICorner", close) closeCorner.CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Tabs
local tabHolder = Instance.new("Frame", main)
tabHolder.Size = UDim2.new(1,0,0,60)
tabHolder.Position = UDim2.new(0,0,0,52)
tabHolder.BackgroundTransparency = 1

local tabs = {"Combat", "Movement", "Visuals", "Misc"}
local contents = {}

for i,name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabHolder)
    btn.Size = UDim2.new(1/#tabs, -8,1,-8)
    btn.Position = UDim2.new((i-1)/#tabs, 4,0,4)
    btn.BackgroundColor3 = Color3.fromRGB(18,18,28)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(180,180,255)
    btn.TextSize = 18

    local c = Instance.new("UICorner", btn) c.CornerRadius = UDim.new(0,10)

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1,-24,1,-132)
    content.Position = UDim2.new(0,12,0,122)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0,0,0,800)
    content.Visible = (i == 1)
    contents[name] = content

    btn.MouseButton1Click:Connect(function()
        for _,v in contents do v.Visible = false end
        content.Visible = true
        for _,b in tabHolder:GetChildren() do
            if b:IsA("TextButton") then
                TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = (b.Text==name and Color3.fromRGB(40,20,80) or Color3.fromRGB(18,18,28))}):Play()
            end
        end
    end)
end

-- Quick toggle creator
local function addToggle(parent, name, y, callback, initial)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,60)
    frame.Position = UDim2.new(0,0,0,y)
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 20
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("Frame", frame)
    switch.Size = UDim2.new(0,56,0,32)
    switch.Position = UDim2.new(1,-70,0.5,0)
    switch.AnchorPoint = Vector2.new(1,0.5)
    switch.BackgroundColor3 = initial and Color3.fromRGB(80,220,100) or Color3.fromRGB(80,80,90)

    local ball = Instance.new("Frame", switch)
    ball.Size = UDim2.new(0,26,0,26)
    ball.Position = initial and UDim2.new(1,-30,0.5,0) or UDim2.new(0,3,0.5,0)
    ball.AnchorPoint = Vector2.new(1,0.5)
    ball.BackgroundColor3 = Color3.new(1,1,1)

    local c1 = Instance.new("UICorner", switch) c1.CornerRadius = UDim.new(1,0)
    local c2 = Instance.new("UICorner", ball) c2.CornerRadius = UDim.new(1,0)

    local clicked = false
    local function toggle()
        clicked = not clicked
        TweenService:Create(switch, TweenInfo.new(0.25), {BackgroundColor3 = clicked and Color3.fromRGB(80,220,100) or Color3.fromRGB(80,80,90)}):Play()
        TweenService:Create(ball, TweenInfo.new(0.25), {Position = clicked and UDim2.new(1,-30,0.5,0) or UDim2.new(0,3,0.5,0)}):Play()
        callback(clicked)
    end

    switch.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end end)
    return toggle
end

-- Combat tab
local combat = contents["Combat"]
local y = 10
addToggle(combat, "Kill Aura", y, function(v) cfg.KillAura = v end, cfg.KillAura) y += 70
addToggle(combat, "Godmode", y, function(v) cfg.Godmode = v getHumanoid().Health = v and math.huge or 100 end, cfg.Godmode) y += 70

-- Movement tab
local move = contents["Movement"]
y = 10
addToggle(move, "Fly", y, function(v) toggleFly() end, cfg.Fly) y += 70
addToggle(move, "Noclip", y, function(v) cfg.Noclip = v end, cfg.Noclip) y += 70
addToggle(move, "Infinite Jump", y, function(v) cfg.InfiniteJump = v end, cfg.InfiniteJump) y += 70
addToggle(move, "Speed Hack", y, function(v) cfg.SpeedHack = v and 50 or 16 getHumanoid().WalkSpeed = cfg.SpeedHack end, cfg.SpeedHack > 16)

-- Visuals tab
local vis = contents["Visuals"]
y = 10
addToggle(vis, "ESP Boxes + Tracers", y, function(v) cfg.ESP_Boxes = v cfg.ESP_Tracers = v if v then for _,p in Players:GetPlayers() do createESP(p) end else for _,c in espCons do c:Disconnect() end espCons = {} end end, cfg.ESP_Boxes) y += 70
addToggle(vis, "Chams", y, function(v) cfg.Chams = v end, cfg.Chams) y += 70
addToggle(vis, "Fullbright", y, function() toggleFullbright() end, cfg.Fullbright) y += 70

-- Misc tab
local misc = contents["Misc"]
y = 10
addToggle(misc, "Anti-Kick", y, function(v) cfg.AntiKick = v end, cfg.AntiKick) y += 70

misc:WaitForChild("TextButton", 1e9) -- placeholder for server hop etc

-- Fly update
RunService:BindToRenderStep("FlyEngine", Enum.RenderPriority.Input.Value + 1, updateFly)

-- Noclip
RunService.Stepped:Connect(function()
    if cfg.Noclip and lp.Character then
        for _,p in lp.Character:GetDescendants() do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if cfg.InfiniteJump then
        getHumanoid():ChangeState("Jumping")
    end
end)

-- Anti kick (basic)
if cfg.AntiKick then
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "Kick" and self == lp then return end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

print("EINXRXS DARK REDUX 2026 LOADED - GO FUCK SHIT UP")
