-- Einxrxs-scripts! Universal (PC+Mobile) FIXED - Steal a BRAINROT (Jan 2026)
-- FIXED: Instant Steal (TP close + fire), Safe TP/Fly (CFrame RenderStepped, no glitch/rubberband),
-- Speed/Fly smooth, Finds REAL BASES (workspace[player.Name]), Top-Right Toggle, AC Bypass Hook
-- Toggles ON/OFF, visual green/red

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local conns = {}
local toggleStates = {}

local function getRoot() return Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return Character:FindFirstChild("Humanoid") end

-- SIMPLE AC BYPASS (hooks kick remotes X-15/X-16)
local hookeds = {}
for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local old = remote.FireServer
        hookeds[remote] = old
        remote.FireServer = function(self, ...)
            local args = {...}
            if args[1] and (string.lower(tostring(args[1])):find("x%-15") or string.lower(tostring(args[1])):find("x%-16")) then
                return -- Block kick
            end
            return old(self, ...)
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Einxrxs-scripts!"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ======================================================
-- UI (Top-Right Toggle Button)
-- ======================================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, isMobile and 70 or 60, 0, isMobile and 70 or 60)
ToggleBtn.Position = UDim2.new(1, -80, 0, 20)  -- TOP RIGHT!
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

-- Main Frame (same as before, slightly larger)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, isMobile and 340 or 380, 0, isMobile and 500 or 540)
MainFrame.Position = UDim2.new(0.5, -(isMobile and 170 or 190), 0.5, -(isMobile and 250 or 270))
MainFrame.BackgroundColor3 = Color3.fromRGB(22,22,32)
MainFrame.BackgroundTransparency = 0.08
MainFrame.Visible = false
