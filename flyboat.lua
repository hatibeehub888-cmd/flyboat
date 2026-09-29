-- ============================================================
-- FlyBoat Final（視点同期完璧版 + FlyGuiV3 GUI + タッチ対応）
-- ============================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===== 設定 =====
local SPEED = 1
local flyEnabled = false
local noclipEnabled = true
local guiUp = false
local guiDown = false
-- ==================

local function clampSpeed(value)
    return math.max(1, math.min(20, value))
end

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

-- ============================================================
-- 視点同期完璧版の飛行ロジック（そのまま使用）
-- ============================================================
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

    local cameraLookDir = Camera.CFrame.LookVector
    local cameraRightDir = Camera.CFrame.RightVector
    local worldMoveDir = Vector3.new(0, 0, 0)

    if moveDir.Z ~= 0 then
        worldMoveDir = worldMoveDir + cameraLookDir * moveDir.Z
    end
    if moveDir.X ~= 0 then
        worldMoveDir = worldMoveDir + cameraRightDir * moveDir.X
    end
    if vertical ~= 0 then
        worldMoveDir = worldMoveDir + Vector3.new(0, vertical, 0)
    end

    local boatPos = boat:GetPivot().Position
    if worldMoveDir.Magnitude > 0 then
        worldMoveDir = worldMoveDir.Unit
        local newPos = boatPos + worldMoveDir * SPEED * 28 * dt
        local newCFrame = CFrame.lookAt(newPos, newPos + cameraLookDir)
        boat:PivotTo(newCFrame)
    else
        local newCFrame = CFrame.lookAt(boatPos, boatPos + cameraLookDir)
        boat:PivotTo(newCFrame)
    end
end)

-- ============================================================
-- GUI（FlyGuiV3風 + タッチ対応）
-- ============================================================
local main = Instance.new("ScreenGui")
main.Name = "main"
main.Parent = LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)
Frame.Active = true
Frame.Draggable = true

local up = Instance.new("TextButton")
up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14

local down = Instance.new("TextButton")
down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14

local onof = Instance.new("TextButton")
onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "fly"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14

local titleText = Instance.new("TextLabel")
titleText.Parent = Frame
titleText.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
titleText.Position = UDim2.new(0.469327301, 0, 0, 0)
titleText.Size = UDim2.new(0, 100, 0, 28)
titleText.Font = Enum.Font.SourceSans
titleText.Text = "FLY GUI V3"
titleText.TextColor3 = Color3.fromRGB(0, 0, 0)
titleText.TextScaled = true
titleText.TextSize = 14
titleText.TextWrapped = true

local plus = Instance.new("TextButton")
plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14
plus.TextWrapped = true

local speedText = Instance.new("TextLabel")
speedText.Name = "speed"
speedText.Parent = Frame
speedText.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speedText.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speedText.Size = UDim2.new(0, 44, 0, 28)
speedText.Font = Enum.Font.SourceSans
speedText.Text = tostring(SPEED)
speedText.TextColor3 = Color3.fromRGB(0, 0, 0)
speedText.TextScaled = true
speedText.TextSize = 14
speedText.TextWrapped = true

local mine = Instance.new("TextButton")
mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14
mine.TextWrapped = true

local closebutton = Instance.new("TextButton")
closebutton.Name = "Close"
closebutton.Parent = main
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = Enum.Font.SourceSans
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position = UDim2.new(0, 0, -1, 27)

local mini = Instance.new("TextButton")
mini.Name = "minimize"
mini.Parent = main
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = Enum.Font.SourceSans
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -1, 27)

local mini2 = Instance.new("TextButton")
mini2.Name = "minimize2"
mini2.Parent = main
mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini2.Font = Enum.Font.SourceSans
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 40
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false

local function updateSpeed()
    speedText.Text = tostring(SPEED)
end

local function setFlyState(state)
    flyEnabled = state
    onof.Text = state and "ON" or "OFF"
    onof.BackgroundColor3 = state and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(180, 50, 50)
end

local function bindHold(button, downFunc, upFunc)
    button.MouseButton1Down:Connect(downFunc)
    button.MouseButton1Up:Connect(upFunc)

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            downFunc()
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            upFunc()
        end
    end)
end

bindHold(up, function() guiUp = true end, function() guiUp = false end)
bindHold(down, function() guiDown = true end, function() guiDown = false end)

onof.MouseButton1Click:Connect(function()
    setFlyState(not flyEnabled)
end)

plus.MouseButton1Down:Connect(function()
    SPEED = clampSpeed(SPEED + 1)
    updateSpeed()
end)

mine.MouseButton1Down:Connect(function()
    SPEED = clampSpeed(SPEED - 1)
    updateSpeed()
end)

closebutton.MouseButton1Click:Connect(function()
    main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
    up.Visible = false
    down.Visible = false
    onof.Visible = false
    plus.Visible = false
    speedText.Visible = false
    mine.Visible = false
    mini.Visible = false
    mini2.Visible = true
    Frame.BackgroundTransparency = 1
end)

mini2.MouseButton1Click:Connect(function()
    up.Visible = true
    down.Visible = true
    onof.Visible = true
    plus.Visible = true
    speedText.Visible = true
    mine.Visible = true
    mini.Visible = true
    mini2.Visible = false
    Frame.BackgroundTransparency = 0
end)

setFlyState(false)
updateSpeed()
print("[FlyBoat Final] loaded")
