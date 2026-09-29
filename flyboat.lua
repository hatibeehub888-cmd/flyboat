-- ============================================================
-- フライボート v3（Blox Fruits 用）
-- ・カメラ連動（視点移動で船も向きが変わる）
-- ・スムーズな上下操作（Space/Shift で確実に上昇下降）
-- ・Noclip 統合（船と自分が島をすり抜ける）
-- ・GUIはドラッグで移動可能、ON/OFF切替可能
-- ============================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===== 設定 =====
local SPEED = 300    -- 飛行速度
local ON = true      -- 初期ON/OFF
local NOCLIP_ON = true -- Noclip 自動有効
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

-- Noclip 処理（船と自分のすべての部位が島をすり抜ける）
local function applyNoclip(boat, char)
    if not NOCLIP_ON then return end
    
    -- 船のすべてのパーツを透過
    if boat then
        for _, p in pairs(boat:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
    
    -- プレイヤーのすべてのパーツを透過
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end

-- メインループ（カメラ連動・上下同期）
RunService.Heartbeat:Connect(function(dt)
    if not ON then return end
    
    local boat, seat = getMyBoat()
    if not boat then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    
    -- Noclip 適用
    applyNoclip(boat, char)
    
    -- WASD / スティック入力（カメラ基準）
    local dir = hum.MoveDirection
    
    -- 上昇 / 下降（Space/Shift または GUI ボタン）
    local vertical = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or guiUp then
        vertical = 1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or guiDown then
        vertical = -1
    end
    
    -- 移動ベクトル
    local move = dir + Vector3.new(0, vertical, 0)
    local pivot = boat:GetPivot()
    
    -- ==========================================
    -- カメラの向きに合わせて船を回転
    -- ==========================================
    local cameraDirection = (Camera.Focus.Position - Camera.CFrame.Position).Unit
    local cameraRightDir = Camera.CFrame.RightVector
    
    -- カメラ基準で前後左右を計算
    if move.Magnitude > 0 then
        move = move.Unit
    end
    
    -- カメラ視点に合わせた移動ベクトル計算
    local worldMove = Vector3.new(0, 0, 0)
    if move.Magnitude > 0 then
        -- カメラ右方向 * 左右入力 + カメラ前方向 * 前後入力
        worldMove = (cameraRightDir * move.X + cameraDirection * move.Z) * move.Magnitude
        -- 上下も追加
        worldMove = worldMove + Vector3.new(0, move.Y, 0)
    end
    
    -- 新しい座標
    local newPos = pivot.Position + worldMove * SPEED * dt
    
    -- 船をカメラ方向に回転させる（前方向をカメラ方向と一致させる）
    local lookDir = cameraDirection
    local upDir = Vector3.new(0, 1, 0)
    local newCFrame = CFrame.lookAt(newPos, newPos + lookDir, upDir)
    
    boat:PivotTo(newCFrame)
end)

-- ================= GUI（ドラッグ移動対応） =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyBoatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 160, 0, 180)
Main.Position = UDim2.new(0, 20, 0.5, -90)
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
Title.Text = " FlyBoat v3"
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

-- Noclip ボタン
local NoclipToggle = Instance.new("TextButton")
NoclipToggle.Size = UDim2.new(1, -16, 0, 30)
NoclipToggle.Position = UDim2.new(0, 8, 0, 72)
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

-- ▲ 上昇ボタン（長押し）
local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0.5, -12, 0, 30)
UpBtn.Position = UDim2.new(0, 8, 0, 108)
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
UpBtn.TouchEnded:Connect(function() guiUp = false end)

-- ▼ 下降ボタン（長押し）
local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0.5, -12, 0, 30)
DownBtn.Position = UDim2.new(0.5, 4, 0, 108)
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
DownBtn.TouchEnded:Connect(function() guiDown = false end)

-- ▲ 上昇ボタン（長押し）タッチ対応
UpBtn.TouchBegan:Connect(function()
    guiUp = true
end)

-- ▼ 下降ボタン（長押し）タッチ対応
DownBtn.TouchBegan:Connect(function()
    guiDown = true
end)
