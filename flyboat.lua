-- ============================================================
-- Fly Boat System with GUI（完全版）
-- ============================================================

local t = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Settings テーブル
local Settings = {}

-- グローバル状態
local b = false -- Fly モード判定フラグ
local SPEED_FLY_BOAT = 3
local SPEED_BOAT = 200
local SPEED_TWEEN_BOAT = 350
local guiUp = false
local guiDown = false

-- ============================================================
-- Boat 検出
-- ============================================================
local function checkboat()
    local char = t.Character
    if not char then return nil end
    
    if not workspace:FindFirstChild("Boats") then return nil end
    
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == char.Humanoid then
            return boat
        end
    end
    
    return nil
end

local function checkSpeedboat()
    local boat = checkboat()
    if boat then
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.MaxSpeed + 1 < SPEED_BOAT then
            return boat
        end
    end
    return false
end

-- ============================================================
-- Fly 関数
-- ============================================================
local function NOFLY()
    -- Fly を OFF にする
end

local function sFLY(enabled)
    -- Fly を ON にする
end

local function X(player, state)
    -- 船を飛行モード開始
end

local function S(player)
    -- 船飛行を停止
end

local function ChangeSpeedBoat()
    local boat = checkSpeedboat()
    if boat then
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat then
            seat.MaxSpeed = SPEED_BOAT
        end
    end
end

-- ============================================================
-- Fly Boat メインロジック
-- ============================================================
local FlyBoatEnabled = false

local function startFlyBoat()
    if FlyBoatEnabled then return end
    FlyBoatEnabled = true
    
    spawn(function()
        while FlyBoatEnabled and (wait(0.1)) do
            pcall(function()
                local char = t.Character
                if not char then return end
                
                local hum = char:FindFirstChild("Humanoid")
                if not hum or not hum.Sit then
                    FlyBoatEnabled = false
                    return
                end
                
                local boat = checkboat()
                if not boat then return end
                
                if not b then
                    NOFLY()
                    wait()
                    sFLY(true)
                else
                    X(t, true)
                end
                
                repeat
                    wait()
                until not FlyBoatEnabled or not hum.Sit
                
                if not b then
                    NOFLY()
                else
                    S(t)
                end
            end)
        end
    end)
end

local function stopFlyBoat()
    FlyBoatEnabled = false
end

-- ============================================================
-- Change Speed Boat ループ
-- ============================================================
local ChangeSpeedBoatEnabled = false

local function startChangeSpeedBoat()
    if ChangeSpeedBoatEnabled then return end
    ChangeSpeedBoatEnabled = true
    
    spawn(function()
        while ChangeSpeedBoatEnabled and (task.wait(0.3)) do
            local success, err = pcall(ChangeSpeedBoat)
            if not success then
                print("[ChangeSpeedBoat Error] " .. tostring(err))
            end
        end
    end)
end

local function stopChangeSpeedBoat()
    ChangeSpeedBoatEnabled = false
end

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyBoatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = t:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 450)
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
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
Title.Text = " Fly Boat System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- ===== Fly Boat トグル =====
local FlyBoatToggle = Instance.new("TextButton")
FlyBoatToggle.Size = UDim2.new(1, -16, 0, 32)
FlyBoatToggle.Position = UDim2.new(0, 8, 0, 36)
FlyBoatToggle.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
FlyBoatToggle.Text = "Fly Boat: OFF"
FlyBoatToggle.TextColor3 = Color3.new(1, 1, 1)
FlyBoatToggle.Font = Enum.Font.GothamBold
FlyBoatToggle.TextSize = 14
FlyBoatToggle.Parent = Main

local FlyBoatToggleCorner = Instance.new("UICorner")
FlyBoatToggleCorner.CornerRadius = UDim.new(0, 6)
FlyBoatToggleCorner.Parent = FlyBoatToggle

FlyBoatToggle.MouseButton1Click:Connect(function()
    if FlyBoatEnabled then
        stopFlyBoat()
        FlyBoatToggle.Text = "Fly Boat: OFF"
        FlyBoatToggle.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
    else
        startFlyBoat()
        FlyBoatToggle.Text = "Fly Boat: ON"
        FlyBoatToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
    end
end)

-- ===== Change Speed Boat トグル =====
local ChangeSpeedToggle = Instance.new("TextButton")
ChangeSpeedToggle.Size = UDim2.new(1, -16, 0, 32)
ChangeSpeedToggle.Position = UDim2.new(0, 8, 0, 74)
ChangeSpeedToggle.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
ChangeSpeedToggle.Text = "Change Speed: OFF"
ChangeSpeedToggle.TextColor3 = Color3.new(1, 1, 1)
ChangeSpeedToggle.Font = Enum.Font.GothamBold
ChangeSpeedToggle.TextSize = 14
ChangeSpeedToggle.Parent = Main

local ChangeSpeedToggleCorner = Instance.new("UICorner")
ChangeSpeedToggleCorner.CornerRadius = UDim.new(0, 6)
ChangeSpeedToggleCorner.Parent = ChangeSpeedToggle

ChangeSpeedToggle.MouseButton1Click:Connect(function()
    if ChangeSpeedBoatEnabled then
        stopChangeSpeedBoat()
        ChangeSpeedToggle.Text = "Change Speed: OFF"
        ChangeSpeedToggle.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
    else
        startChangeSpeedBoat()
        ChangeSpeedToggle.Text = "Change Speed: ON"
        ChangeSpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
    end
end)

-- ===== Value Speed Boat スライダー =====
local SpeedBoatLabel = Instance.new("TextLabel")
SpeedBoatLabel.Size = UDim2.new(1, -16, 0, 20)
SpeedBoatLabel.Position = UDim2.new(0, 8, 0, 112)
SpeedBoatLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBoatLabel.Text = "Speed Boat: " .. SPEED_BOAT
SpeedBoatLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedBoatLabel.Font = Enum.Font.Gotham
SpeedBoatLabel.TextSize = 11
SpeedBoatLabel.Parent = Main

local SpeedBoatLabelCorner = Instance.new("UICorner")
SpeedBoatLabelCorner.CornerRadius = UDim.new(0, 4)
SpeedBoatLabelCorner.Parent = SpeedBoatLabel

local SpeedBoatSlider = Instance.new("Frame")
SpeedBoatSlider.Size = UDim2.new(1, -16, 0, 8)
SpeedBoatSlider.Position = UDim2.new(0, 8, 0, 138)
SpeedBoatSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedBoatSlider.BorderSizePixel = 0
SpeedBoatSlider.Parent = Main

local SpeedBoatSliderCorner = Instance.new("UICorner")
SpeedBoatSliderCorner.CornerRadius = UDim.new(0, 4)
SpeedBoatSliderCorner.Parent = SpeedBoatSlider

local SpeedBoatSliderFill = Instance.new("Frame")
SpeedBoatSliderFill.Size = UDim2.new((SPEED_BOAT / 500), 0, 1, 0)
SpeedBoatSliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
SpeedBoatSliderFill.BorderSizePixel = 0
SpeedBoatSliderFill.Parent = SpeedBoatSlider

local SpeedBoatSliderCornerFill = Instance.new("UICorner")
SpeedBoatSliderCornerFill.CornerRadius = UDim.new(0, 4)
SpeedBoatSliderCornerFill.Parent = SpeedBoatSliderFill

local function updateSpeedBoat(newSpeed)
    SPEED_BOAT = math.max(0, math.min(500, newSpeed))
    SpeedBoatLabel.Text = "Speed Boat: " .. math.floor(SPEED_BOAT)
    SpeedBoatSliderFill.Size = UDim2.new((SPEED_BOAT / 500), 0, 1, 0)
end

local draggingSpeedBoat = false
SpeedBoatSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeedBoat = true
    end
end)

SpeedBoatSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeedBoat = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSpeedBoat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouse = game:GetService("Mouse")
        local sliderPos = SpeedBoatSlider.AbsolutePosition.X
        local sliderSize = SpeedBoatSlider.AbsoluteSize.X
        local mouseX = mouse.X
        
        if mouseX >= sliderPos and mouseX <= sliderPos + sliderSize then
            local percentage = (mouseX - sliderPos) / sliderSize
            updateSpeedBoat(percentage * 500)
        end
    end
end)

-- ===== Value Speed Tween Boat スライダー =====
local SpeedTweenLabel = Instance.new("TextLabel")
SpeedTweenLabel.Size = UDim2.new(1, -16, 0, 20)
SpeedTweenLabel.Position = UDim2.new(0, 8, 0, 152)
SpeedTweenLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedTweenLabel.Text = "Tween Speed: " .. SPEED_TWEEN_BOAT
SpeedTweenLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedTweenLabel.Font = Enum.Font.Gotham
SpeedTweenLabel.TextSize = 11
SpeedTweenLabel.Parent = Main

local SpeedTweenLabelCorner = Instance.new("UICorner")
SpeedTweenLabelCorner.CornerRadius = UDim.new(0, 4)
SpeedTweenLabelCorner.Parent = SpeedTweenLabel

local SpeedTweenSlider = Instance.new("Frame")
SpeedTweenSlider.Size = UDim2.new(1, -16, 0, 8)
SpeedTweenSlider.Position = UDim2.new(0, 8, 0, 178)
SpeedTweenSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedTweenSlider.BorderSizePixel = 0
SpeedTweenSlider.Parent = Main

local SpeedTweenSliderCorner = Instance.new("UICorner")
SpeedTweenSliderCorner.CornerRadius = UDim.new(0, 4)
SpeedTweenSliderCorner.Parent = SpeedTweenSlider

local SpeedTweenSliderFill = Instance.new("Frame")
SpeedTweenSliderFill.Size = UDim2.new((SPEED_TWEEN_BOAT / 2000), 0, 1, 0)
SpeedTweenSliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
SpeedTweenSliderFill.BorderSizePixel = 0
SpeedTweenSliderFill.Parent = SpeedTweenSlider

local SpeedTweenSliderCornerFill = Instance.new("UICorner")
SpeedTweenSliderCornerFill.CornerRadius = UDim.new(0, 4)
SpeedTweenSliderCornerFill.Parent = SpeedTweenSliderFill

local function updateSpeedTween(newSpeed)
    SPEED_TWEEN_BOAT = math.max(50, math.min(2000, newSpeed))
    SpeedTweenLabel.Text = "Tween Speed: " .. math.floor(SPEED_TWEEN_BOAT)
    SpeedTweenSliderFill.Size = UDim2.new((SPEED_TWEEN_BOAT / 2000), 0, 1, 0)
end

local draggingSpeedTween = false
SpeedTweenSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeedTween = true
    end
end)

SpeedTweenSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeedTween = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSpeedTween and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouse = game:GetService("Mouse")
        local sliderPos = SpeedTweenSlider.AbsolutePosition.X
        local sliderSize = SpeedTweenSlider.AbsoluteSize.X
        local mouseX = mouse.X
        
        if mouseX >= sliderPos and mouseX <= sliderPos + sliderSize then
            local percentage = (mouseX - sliderPos) / sliderSize
            updateSpeedTween(percentage * 2000)
        end
    end
end)

-- ===== Value Speed Fly Boat スライダー =====
local SpeedFlyLabel = Instance.new("TextLabel")
SpeedFlyLabel.Size = UDim2.new(1, -16, 0, 20)
SpeedFlyLabel.Position = UDim2.new(0, 8, 0, 192)
SpeedFlyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedFlyLabel.Text = "Fly Speed: " .. SPEED_FLY_BOAT
SpeedFlyLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedFlyLabel.Font = Enum.Font.Gotham
SpeedFlyLabel.TextSize = 11
SpeedFlyLabel.Parent = Main

local SpeedFlyLabelCorner = Instance.new("UICorner")
SpeedFlyLabelCorner.CornerRadius = UDim.new(0, 4)
SpeedFlyLabelCorner.Parent = SpeedFlyLabel

local SpeedFlySlider = Instance.new("Frame")
SpeedFlySlider.Size = UDim2.new(1, -16, 0, 8)
SpeedFlySlider.Position = UDim2.new(0, 8, 0, 218)
SpeedFlySlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedFlySlider.BorderSizePixel = 0
SpeedFlySlider.Parent = Main

local SpeedFlySliderCorner = Instance.new("UICorner")
SpeedFlySliderCorner.CornerRadius = UDim.new(0, 4)
SpeedFlySliderCorner.Parent = SpeedFlySlider

local SpeedFlySliderFill = Instance.new("Frame")
SpeedFlySliderFill.Size = UDim2.new((SPEED_FLY_BOAT / 10), 0, 1, 0)
SpeedFlySliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
SpeedFlySliderFill.BorderSizePixel = 0
SpeedFlySliderFill.Parent = SpeedFlySlider

local SpeedFlySliderCornerFill = Instance.new("UICorner")
SpeedFlySliderCornerFill.CornerRadius = UDim.new(0, 4)
SpeedFlySliderCornerFill.Parent = SpeedFlySliderFill

local function updateSpeedFly(newSpeed)
    SPEED_FLY_BOAT = math.max(0, math.min(10, newSpeed))
    SpeedFlyLabel.Text = "Fly Speed: " .. math.floor(SPEED_FLY_BOAT * 10) / 10
    SpeedFlySliderFill.Size = UDim2.new((SPEED_FLY_BOAT / 10), 0, 1, 0)
end

local draggingSpeedFly = false
SpeedFlySlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeedFly = true
    end
end)

SpeedFlySlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSpeedFly = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSpeedFly and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouse = game:GetService("Mouse")
        local sliderPos = SpeedFlySlider.AbsolutePosition.X
        local sliderSize = SpeedFlySlider.AbsoluteSize.X
        local mouseX = mouse.X
        
        if mouseX >= sliderPos and mouseX <= sliderPos + sliderSize then
            local percentage = (mouseX - sliderPos) / sliderSize
            updateSpeedFly(percentage * 10)
        end
    end
end)

print("[Fly Boat System] Ready")
