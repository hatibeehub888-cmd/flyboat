-- ============================================================
-- FlyBoat v6（FlyGuiV3 ベース + 船対応 + 視点同期 + GUI 修正版）
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SPEED = 1
local flyEnabled = false
local noclipEnabled = true
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
            return boat
        end
    end

    return nil
end

local function applyNoclipPart(obj)
    if obj and obj:IsA("BasePart") then
        obj.CanCollide = false
    end
end

local function applyNoclip(boat, char)
    if not noclipEnabled then return end

    if boat then
        for _, p in pairs(boat:GetDescendants()) do
            applyNoclipPart(p)
        end
    end

    if char then
        for _, p in pairs(char:GetDescendants()) do
            applyNoclipPart(p)
        end
    end
end

local function clampSpeed(value)
    return math.max(1, math.min(20, value))
end

local function setFlyState(state)
    flyEnabled = state
    if onof then
        onof.Text = state and "ON" or "OFF"
        onof.BackgroundColor3 = state and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(150, 40, 40)
    end
end

local function updateSpeedText()
    if speedLabel then
        speedLabel.Text = tostring(SPEED)
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not flyEnabled then return end

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

    local cameraLook = Camera.CFrame.LookVector
    local cameraRight = Camera.CFrame.RightVector
    local move = Vector3.new(0, 0, 0)

    if moveDir.Z ~= 0 then
        move = move + cameraLook * moveDir.Z
    end

    if moveDir.X ~= 0 then
        move = move + cameraRight * moveDir.X
    end

    if vertical ~= 0 then
        move = move + Vector3.new(0, vertical, 0)
    end

    local boatPos = boat:GetPivot().Position

    if move.Magnitude > 0 then
        move = move.Unit
        local targetPos = boatPos + move * SPEED * 28 * dt
        local targetCFrame = CFrame.lookAt(targetPos, targetPos + cameraLook)
        boat:PivotTo(targetCFrame)
    else
        local targetCFrame = CFrame.lookAt(boatPos, boatPos + cameraLook)
        boat:PivotTo(targetCFrame)
    end
end)

-- ============================================
-- GUI
-- ============================================

local main = Instance.new("ScreenGui")
main.Name = "FlyBoatGui"
main.Parent = LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.05, 0, 0.45, 0)
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Active = true
Frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
title.Text = " FlyBoat"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = Frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local closebutton = Instance.new("TextButton")
closebutton.Name = "Close"
closebutton.Size = UDim2.new(0, 28, 0, 24)
closebutton.Position = UDim2.new(1, -32, 0, 2)
closebutton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closebutton.Text = "X"
closebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
closebutton.Font = Enum.Font.GothamBold
closebutton.TextSize = 14
closebutton.BorderSizePixel = 0
closebutton.Parent = title

local mini = Instance.new("TextButton")
mini.Name = "Minimize"
mini.Size = UDim2.new(0, 28, 0, 24)
mini.Position = UDim2.new(1, -64, 0, 2)
mini.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
mini.Text = "_"
mini.TextColor3 = Color3.fromRGB(255, 255, 255)
mini.Font = Enum.Font.GothamBold
mini.TextSize = 14
mini.BorderSizePixel = 0
mini.Parent = title

local mini2 = Instance.new("TextButton")
mini2.Name = "Expand"
mini2.Size = UDim2.new(0, 28, 0, 24)
mini2.Position = UDim2.new(1, -64, 0, 2)
mini2.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
mini2.Text = "+"
mini2.TextColor3 = Color3.fromRGB(255, 255, 255)
mini2.Font = Enum.Font.GothamBold
mini2.TextSize = 14
mini2.BorderSizePixel = 0
mini2.Visible = false
mini2.Parent = title

local up = Instance.new("TextButton")
up.Name = "Up"
up.Size = UDim2.new(0.28, 0, 0, 30)
up.Position = UDim2.new(0.05, 0, 0.42, 0)
up.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(255, 255, 255)
up.Font = Enum.Font.GothamBold
up.TextSize = 14
up.BorderSizePixel = 0
up.Parent = Frame

local down = Instance.new("TextButton")
down.Name = "Down"
down.Size = UDim2.new(0.28, 0, 0, 30)
down.Position = UDim2.new(0.38, 0, 0.42, 0)
down.BackgroundColor3 = Color3.fromRGB(220, 140, 30)
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(255, 255, 255)
down.Font = Enum.Font.GothamBold
down.TextSize = 14
down.BorderSizePixel = 0
down.Parent = Frame

local onof = Instance.new("TextButton")
onof.Name = "OnOff"
onof.Size = UDim2.new(0.22, 0, 0, 30)
onof.Position = UDim2.new(0.72, 0, 0.42, 0)
onof.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
onof.Text = "OFF"
onof.TextColor3 = Color3.fromRGB(255, 255, 255)
onof.Font = Enum.Font.GothamBold
onof.TextSize = 14
onof.BorderSizePixel = 0
onof.Parent = Frame

local plus = Instance.new("TextButton")
plus.Name = "Plus"
plus.Size = UDim2.new(0, 34, 0, 28)
plus.Position = UDim2.new(0.53, 0, 0.75, 0)
plus.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.Font = Enum.Font.GothamBold
plus.TextSize = 18
plus.BorderSizePixel = 0
plus.Parent = Frame

local mine = Instance.new("TextButton")
mine.Name = "Minus"
mine.Size = UDim2.new(0, 34, 0, 28)
mine.Position = UDim2.new(0.68, 0, 0.75, 0)
mine.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(255, 255, 255)
mine.Font = Enum.Font.GothamBold
mine.TextSize = 18
mine.BorderSizePixel = 0
mine.Parent = Frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "Speed"
speedLabel.Size = UDim2.new(0, 38, 0, 28)
speedLabel.Position = UDim2.new(0.23, 0, 0.75, 0)
speedLabel.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
speedLabel.Text = tostring(SPEED)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 16
speedLabel.TextXAlignment = Enum.TextXAlignment.Center
speedLabel.TextYAlignment = Enum.TextYAlignment.Center
speedLabel.BorderSizePixel = 0
speedLabel.Parent = Frame

local function updateSpeedText()
    speedLabel.Text = tostring(SPEED)
end

closebutton.MouseButton1Click:Connect(function()
    main.Enabled = false
end)

mini.MouseButton1Click:Connect(function()
    Frame.Size = UDim2.new(0, 220, 0, 40)
    up.Visible = false
    down.Visible = false
    onof.Visible = false
    plus.Visible = false
    mine.Visible = false
    speedLabel.Visible = false
    mini.Visible = false
    mini2.Visible = true
end)

mini2.MouseButton1Click:Connect(function()
    Frame.Size = UDim2.new(0, 220, 0, 120)
    up.Visible = true
    down.Visible = true
    onof.Visible = true
    plus.Visible = true
    mine.Visible = true
    speedLabel.Visible = true
    mini.Visible = true
    mini2.Visible = false
end)

up.MouseButton1Down:Connect(function()
    guiUp = true
end)
up.MouseButton1Up:Connect(function()
    guiUp = false
end)
up.TouchBegan:Connect(function()
    guiUp = true
end)
up.TouchEnded:Connect(function()
    guiUp = false
end)

down.MouseButton1Down:Connect(function()
    guiDown = true
end)
down.MouseButton1Up:Connect(function()
    guiDown = false
end)
down.TouchBegan:Connect(function()
    guiDown = true
end)
down.TouchEnded:Connect(function()
    guiDown = false
end)

onof.MouseButton1Click:Connect(function()
    setFlyState(not flyEnabled)
end)

plus.MouseButton1Click:Connect(function()
    SPEED = clampSpeed(SPEED + 1)
    updateSpeedText()
end)

mine.MouseButton1Click:Connect(function()
    SPEED = clampSpeed(SPEED - 1)
    updateSpeedText()
end)

setFlyState(false)
updateSpeedText()

print("[FlyBoat v6] loaded")
