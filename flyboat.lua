-- ============================================================
-- フライボート v4（Blox Fruits 用）
-- ・カメラ連動（視点方向に確実に進む）
-- ・確実な上下操作
-- ・Noclip 統合
-- ・スマホ完全対応
-- ============================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SPEED = 300
local ON = true
local NOCLIP_ON = true

local guiUp = false
local guiDown = false

local function getMyBoat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    if not workspace:FindFirstChild("Boats") then return nil end
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == hum then
            return boat, seat
        end
    end
    return nil
end

local function applyNoclip(boat, char)
    if not NOCLIP_ON then return end
    if boat then
        for _, p in pairs(boat:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not ON then return end
    local boat = getMyBoat()
    if not boat then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    
    applyNoclip(boat, char)
    
    local moveDir = hum.MoveDirection
    local vertical = 0
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or guiUp then
        vertical = 1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or guiDown then
        vertical = -1
    end
    
    local pivot = boat:GetPivot()
    local boatPos = pivot.Position
    
    local cameraLookDir = Camera.CFrame.LookVector
    local cameraRightDir = Camera.CFrame.RightVector
    
    local worldMoveDir = Vector3.new(0, 0, 0)
    
    -- Z は前後（LookVector方向）
    if moveDir.Z ~= 0 then
        worldMoveDir = worldMoveDir + cameraLookDir * moveDir.Z
    end
    
    -- X は左右（RightVector方向）
    if moveDir.X ~= 0 then
        worldMoveDir = worldMoveDir + cameraRightDir * moveDir.X
    end
    
    -- Y は上下
    if vertical ~= 0 then
        worldMoveDir = worldMoveDir + Vector3.new(0, vertical, 0)
    end
    
    if worldMoveDir.Magnitude > 0 then
        worldMoveDir = worldMoveDir.Unit
        local newPos = boatPos + worldMoveDir * SPEED * dt
        local newCFrame = CFrame.lookAt(newPos, newPos + cameraLookDir)
        boat:PivotTo(newCFrame)
    else
        local newCFrame = CFrame.lookAt(boatPos, boatPos + cameraLookDir)
        boat:PivotTo(newCFrame)
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyBoatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 160, 0, 220)
Main.Position = UDim2.new(0.02, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = " FlyBoat v4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- ドラッグ
do
    local dragging = false
    local dragStart, startPos
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -16, 0, 32)
Toggle.Position = UDim2.new(0, 8, 0, 36)
Toggle.BackgroundColor3 = ON and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(140, 40, 40)
Toggle.Text = ON and "飛行: ON" or "飛行: OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.Parent = Main
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    ON = not ON
    Toggle.Text = ON and "飛行: ON" or "飛行: OFF"
    Toggle.BackgroundColor3 = ON and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(140, 40, 40)
end)

local NoclipToggle = Instance.new("TextButton")
NoclipToggle.Size = UDim2.new(1, -16, 0, 32)
NoclipToggle.Position = UDim2.new(0, 8, 0, 74)
NoclipToggle.BackgroundColor3 = NOCLIP_ON and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(100, 40, 40)
NoclipToggle.Text = NOCLIP_ON and "Noclip: ON" or "Noclip: OFF"
NoclipToggle.TextColor3 = Color3.new(1, 1, 1)
NoclipToggle.Font = Enum.Font.GothamBold
NoclipToggle.TextSize = 14
NoclipToggle.Parent = Main
local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 6)
NoclipCorner.Parent = NoclipToggle

NoclipToggle.MouseButton1Click:Connect(function()
    NOCLIP_ON = not NOCLIP_ON
    NoclipToggle.Text = NOCLIP_ON and "Noclip: ON" or "Noclip: OFF"
    NoclipToggle.BackgroundColor3 = NOCLIP_ON and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(100, 40, 40)
end)

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0.48, 0, 0, 32)
UpBtn.Position = UDim2.new(0.04, 0, 0.5, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
UpBtn.Text = "▲ 上昇"
UpBtn.TextColor3 = Color3.new(1, 1, 1)
UpBtn.Font = Enum.Font.GothamBold
UpBtn.TextSize = 12
UpBtn.Parent = Main
local UpCorner = Instance.new("UICorner")
UpCorner.CornerRadius = UDim.new(0, 6)
UpCorner.Parent = UpBtn

UpBtn.MouseButton1Down:Connect(function() guiUp = true end)
UpBtn.MouseButton1Up:Connect(function() guiUp = false end)
UpBtn.TouchBegan:Connect(function() guiUp = true end)
UpBtn.TouchEnded:Connect(function() guiUp = false end)

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0.48, 0, 0, 32)
DownBtn.Position = UDim2.new(0.52, 0, 0.5, 0)
DownBtn.BackgroundColor3 = Color3.fromRGB(180, 90, 0)
DownBtn.Text = "▼ 下降"
DownBtn.TextColor3 = Color3.new(1, 1, 1)
DownBtn.Font = Enum.Font.GothamBold
DownBtn.TextSize = 12
DownBtn.Parent = Main
local DownCorner = Instance.new("UICorner")
DownCorner.CornerRadius = UDim.new(0, 6)
DownCorner.Parent = DownBtn

DownBtn.MouseButton1Down:Connect(function() guiDown = true end)
DownBtn.MouseButton1Up:Connect(function() guiDown = false end)
DownBtn.TouchBegan:Connect(function() guiDown = true end)
DownBtn.TouchEnded:Connect(function() guiDown = false end)

print("[FlyBoat v4] Ready!")
