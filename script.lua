--// Einxrxs Mobile-Friendly Exploit Base 2026 - Enhanced Touch GUI + Brainrot Vibes 🧠💀
--// Features: Draggable GUI, Fly, Noclip, ESP, Speed Sliders, Instant/Auto Steal, Infinite Jump, God Mode, Invis, Dupe + Brainrot Mode toggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

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
    BrainrotMode = false  -- New: chaotic brainrot aesthetic
}

--// Brainrot Mode Colors (purple/pink chaos)
local function applyBrainrotTheme(enable)
    Settings.BrainrotMode = enable
    local bgColor = enable and Color3.fromRGB(147, 0, 255) or Color3.fromRGB(25, 25, 25)   -- purple or dark
    local titleColor = enable and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(35,35,35) -- hot pink or dark
    
    mainFrame.BackgroundColor3 = bgColor
    title.BackgroundColor3 = titleColor
    
    -- Quick skull spam for max brainrot
    if enable then
        for i = 1, 5 do
            print("💀💀 BRAINROT ACTIVATED 💀💀")
            task.wait(0.3)
        end
    end
end

-- (Rest of your core functions remain the same: getRoot, fly system, noclip, ESP, instantSteal, autoSteal, dupeTool, infiniteJump, godMode, invisible, etc.)
-- ... [Paste all previous function definitions here: flyBV/updateFly/startFly/stopFly, noclip connect, ESP toggle, instantSteal, toggleAutoSteal, dupeTool, toggleInfiniteJump, toggleGodMode, toggleInvisible, CharacterAdded connects] ...

--// ======================= NICE MOBILE GUI + BRAIN EMOJI BUTTON =======================
local gui = Instance.new("ScreenGui")
gui.Name = "EinxrxsExploit"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 400)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title with Brain Emoji Button
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.75, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "Einxrxs Exploit 🧠"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Brain Emoji Button (big 🧠 that toggles Brainrot Mode)
local brainBtn = Instance.new("TextButton")
brainBtn.Size = UDim2.new(0, 50, 0, 40)
brainBtn.Position = UDim2.new(0.8, 0, 0, 0)
brainBtn.BackgroundColor3 = Color3.fromRGB(147, 0, 255)  -- purple brainrot
brainBtn.Text = "🧠"
brainBtn.TextColor3 = Color3.new(1,1,1)
brainBtn.Font = Enum.Font.GothamBlack
brainBtn.TextSize = 28
brainBtn.Parent = mainFrame

local brainCorner = Instance.new("UICorner")
brainCorner.CornerRadius = UDim.new(0, 12)
brainCorner.Parent = brainBtn

brainBtn.MouseButton1Click:Connect(function()
    applyBrainrotTheme(not Settings.BrainrotMode)
    brainBtn.BackgroundColor3 = Settings.BrainrotMode and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(147, 0, 255)  -- toggle pink/purple
end)

-- Tab frame and tabs (unchanged)
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

-- (Your createButton function remains the same)
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

-- (All your tab buttons: Fly, Noclip, Instant Steal, Infinite Jump, Invis, Auto Steal, Dupe, ESP, God Mode, sliders for fly/walk/jump)

-- Close button (unchanged)
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

print("Einxrxs Exploit Loaded! Tap the big 🧠 for max brainrot mode 💀💀💀")

-- PC fallback (unchanged)
if not isMobile then
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.G then
            if Settings.FlyEnabled then stopFly() else startFly() end
        end
    end)
end
