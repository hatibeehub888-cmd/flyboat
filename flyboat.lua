-- ============================================================
-- フライボート（Blox Fruits 自立型）
-- ・カメラの向きに同期して動く
-- ・移動スティック / WASD の方向に進む
-- ・Space or ▲ボタンで上昇 / Shift or ▼ボタンで下降
-- ============================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== 設定 =====
local SPEED = 300    -- 飛行速度（大きいほど速い）
local ON = true      -- 初期状態（GUIボタンでも切り替え可）
-- ==================

local bv = nil        -- BodyVelocity
local seatRef = nil
local oldMaxSpeed = nil

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

-- 飛行のON/OFF切り替え
local function setFly(on)
    ON = on
    local boat, seat = getMyBoat()
    if on and boat then
        seatRef = seat
        oldMaxSpeed = oldMaxSpeed or seat.MaxSpeed
        seat.MaxSpeed = 0 -- ボート本来の移動を止める
        -- BodyVelocityを作って速度を完全に握る
        if not bv or not bv.Parent then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = boat.PrimaryPart or seat
        end
        -- 当たり判定OFF（地形すり抜け）
        for _, p in pairs(boat:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    else
        -- 元の物理に戻す
        if bv then bv:Destroy() bv = nil end
        if seatRef and seatRef.Parent then
            seatRef.MaxSpeed = oldMaxSpeed or 35
        end
        seatRef = nil
    end
end

-- メインループ
RunService.Heartbeat:Connect(function()
    if not ON then return end
    local boat, seat = getMyBoat()
    if not boat then
        -- ボートから降りたら飛行解除
        if bv then bv:Destroy() bv = nil end
        return
    end
    if not bv or not bv.Parent then
        setFly(true) -- 乗った瞬間に初期化
        return
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end

    -- 移動スティック / WASD（Robloxがカメラ基準の方向に変換してくれる）
    local dir = hum.MoveDirection

    -- 上昇・下降
    local vertical = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or guiUp then
        vertical = SPEED
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or guiDown then
        vertical = -SPEED
    end

    bv.Velocity = dir * SPEED + Vector3.new(0, vertical, 0)
end)

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyBoatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- ON/OFFボタン
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 120, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0.5, -60)
Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
Toggle.Text = "飛行: ON"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.Parent = ScreenGui
Toggle.Active = true
Toggle.Draggable = true

-- ▲ 上昇ボタン（スマホ用）
local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 50, 0, 50)
UpBtn.Position = UDim2.new(0, 145, 0.5, -60)
UpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
UpBtn.TextColor3 = Color3.white
UpBtn.Text = "▲"
UpBtn.Font = Enum.Font.GothamBold
UpBtn.TextSize = 20
UpBtn.Parent = ScreenGui
UpBtn.Active = true

-- ▼ 下降ボタン（スマホ用）
local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 50, 0, 50)
DownBtn.Position = UDim2.new(0, 145, 0.5, 0)
DownBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
DownBtn.TextColor3 = Color3.white
DownBtn.Text = "▼"
DownBtn.Font = Enum.Font.GothamBold
DownBtn.TextSize = 20
DownBtn.Parent = ScreenGui
DownBtn.Active = true

Toggle.MouseButton1Click:Connect(function()
    setFly(not ON)
    Toggle.Text = ON and "飛行: ON" or "飛行: OFF"
    Toggle.TextColor3 = ON and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
end)

UpBtn.MouseButton1Down:Connect(function() guiUp = true end)
UpBtn.MouseButton1Up:Connect(function() guiUp = false end)
DownBtn.MouseButton1Down:Connect(function() guiDown = true end)
DownBtn.MouseButton1Up:Connect(function() guiDown = false end)
