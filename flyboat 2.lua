-- ============================================================
-- フライボート v2（Blox Fruits 用）
-- ・普通のフライと同じ操作感（カメラ連動・スティック移動）
-- ・ボートに座ったまま飛べる（座るとフライが消えない）
-- ・Space/Shift または ▲▼ボタンで上昇下降
-- ・GUIはドラッグで移動可能、ON/OFF切替可能
-- ============================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== 設定 =====
local SPEED = 300    -- 飛行速度
local ON = true      -- 初期ON/OFF
-- ==================

local guiUp = false
local guiDown = false

-- 自分が乗っているボートを取得
local function getMyBoat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    for _, boat in pairs(workspace.Boats:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat")
        if seat and seat.Occupant == hum then
            return boat, seat
        end
    end
    return nil
end

-- メインループ（座標を直接動かす方式＝いつものフライと同じ）
RunService.Heartbeat:Connect(function(dt)
    if not ON then return end
    local boat = getMyBoat()
    if not boat then return end -- ボートに乗ってないときは何もしない

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end

    -- 移動スティック / WASD（カメラ基準の方向が自動で入る）
    local dir = hum.MoveDirection

    -- 上昇 / 下降
    local vertical = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or guiUp then
        vertical = 1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or guiDown then
        vertical = -1
    end

    local move = dir + Vector3.new(0, vertical, 0)
    local pivot = boat:GetPivot()
    local rotation = pivot - pivot.Position

    if move.Magnitude > 0 then
        -- 入力がある → その方向に進む
        local newPos = pivot.Position + move.Unit * SPEED * dt
        boat:PivotTo(CFrame.new(newPos) * rotation)
    else
        -- 入力なし → その場で浮き続ける（重力で落ちないよう毎フレーム固定）
        boat:PivotTo(pivot)
    end

    -- 当たり判定OFF（島などをすり抜ける）
    for _, p in pairs(boat:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ================= GUI（ドラッグ移動対応） =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyBoatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 150, 0, 110)
Main.Position = UDim2.new(0, 20, 0.5, -55)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

-- ドラッグ用のタイトルバー
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = " FlyBoat（ここをドラッグ）"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- ドラッグ処理（スマホ・PC両対応）
do
    local dragging = false
    local dragStart, startPos
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ON/OFF ボタン
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -16, 0, 30)
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

-- ▲ 上昇ボタン（長押し）
local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0.5, -12, 0, 30)
UpBtn.Position = UDim2.new(0, 8, 0, 72)
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

-- ▼ 下降ボタン（長押し）
local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0.5, -12, 0, 30)
DownBtn.Position = UDim2.new(0.5, 4, 0, 72)
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
