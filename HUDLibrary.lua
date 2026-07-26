local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local library = {
    watermark = nil,
    targetHud = nil,
    ambience = nil,
}

-- ██████  WATERMARK HUD  █████████████████████████████████████████████████████████████

local function createDrag(gui)
    local dragging = false
    local dragStart
    local frameStart
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            frameStart = gui.Position
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local delta = UserInputService:GetMouseLocation() - dragStart
            gui.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
end

function library:createWatermark(screenGui)
    if self.watermark then return self.watermark end

    local theme = {
        bg = Color3.fromRGB(20, 20, 30),
        text = Color3.fromRGB(220, 220, 230),
        accent = Color3.fromRGB(88, 101, 242),
        border = Color3.fromRGB(40, 40, 55),
    }

    local frame = Instance.new("Frame")
    frame.Name = "HUD_Watermark"
    frame.Size = UDim2.new(0, 240, 0, 28)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = theme.bg
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.border
    stroke.Thickness = 1
    stroke.Parent = frame

    local brand = Instance.new("TextLabel")
    brand.Size = UDim2.new(0, 70, 1, 0)
    brand.Position = UDim2.new(0, 8, 0, 0)
    brand.BackgroundTransparency = 1
    brand.Text = "expa"
    brand.TextColor3 = theme.accent
    brand.Font = Enum.Font.GothamBlack
    brand.TextSize = 13
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Parent = frame

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "Ping"
    pingLabel.Size = UDim2.new(0, 55, 1, 0)
    pingLabel.Position = UDim2.new(0, 82, 0, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "0 ms"
    pingLabel.TextColor3 = theme.text
    pingLabel.Font = Enum.Font.GothamSemibold
    pingLabel.TextSize = 11
    pingLabel.Parent = frame

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPS"
    fpsLabel.Size = UDim2.new(0, 55, 1, 0)
    fpsLabel.Position = UDim2.new(0, 137, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "60 fps"
    fpsLabel.TextColor3 = theme.text
    fpsLabel.Font = Enum.Font.GothamSemibold
    fpsLabel.TextSize = 11
    fpsLabel.Parent = frame

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 1, 0, 16)
    divider.Position = UDim2.new(0, 78, 0.5, -8)
    divider.BackgroundColor3 = theme.border
    divider.BorderSizePixel = 0
    divider.Parent = frame

    local divider2 = divider:Clone()
    divider2.Position = UDim2.new(0, 133, 0.5, -8)
    divider2.Parent = frame

    createDrag(frame)

    -- Update ping & fps
    local netStats = game:GetService("Stats")
    local lastTime = tick()
    local frameCount = 0

    local connection
    connection = RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = tostring(math.floor(frameCount / (now - lastTime))) .. " fps"
            frameCount = 0
            lastTime = now
        end
        pingLabel.Text = tostring(math.floor(netStats:GetItem("Network.ServerStats._ping"):GetValue())) .. " ms"
    end)

    self.watermark = {
        frame = frame,
        connection = connection,
        setVisible = function(v) frame.Visible = v end,
        destroy = function()
            connection:Disconnect()
            frame:Destroy()
            self.watermark = nil
        end
    }

    return self.watermark
end

-- ██████  TARGET HUD  ███████████████████████████████████████████████████████████████

function library:createTargetHud(screenGui)
    if self.targetHud then return self.targetHud end

    local theme = {
        bg = Color3.fromRGB(15, 15, 25),
        text = Color3.fromRGB(220, 220, 230),
        accent = Color3.fromRGB(88, 101, 242),
        hpGreen = Color3.fromRGB(87, 184, 70),
        hpRed = Color3.fromRGB(237, 66, 69),
        border = Color3.fromRGB(35, 35, 50),
    }

    local frame = Instance.new("Frame")
    frame.Name = "HUD_TargetHud"
    frame.Size = UDim2.new(0, 220, 0, 50)
    frame.Position = UDim2.new(1, -240, 0.5, -25)
    frame.BackgroundColor3 = theme.bg
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.border
    stroke.Thickness = 1
    stroke.Parent = frame

    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 36, 0, 36)
    avatar.Position = UDim2.new(0, 7, 0.5, -18)
    avatar.BackgroundColor3 = theme.border
    avatar.BackgroundTransparency = 0.5
    avatar.BorderSizePixel = 0
    avatar.Parent = frame

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 6)
    avatarCorner.Parent = avatar

    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(1, -52, 0, 18)
    nameLabel.Position = UDim2.new(0, 50, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "None"
    nameLabel.TextColor3 = theme.text
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame

    -- Health bar background
    local hpBg = Instance.new("Frame")
    hpBg.Name = "HPBarBg"
    hpBg.Size = UDim2.new(0, 155, 0, 6)
    hpBg.Position = UDim2.new(0, 50, 0, 28)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = frame

    local hpBgCorner = Instance.new("UICorner")
    hpBgCorner.CornerRadius = UDim.new(1, 0)
    hpBgCorner.Parent = hpBg

    -- Health bar fill
    local hpFill = Instance.new("Frame")
    hpFill.Name = "HPBarFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = theme.hpGreen
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg

    local hpFillCorner = Instance.new("UICorner")
    hpFillCorner.CornerRadius = UDim.new(1, 0)
    hpFillCorner.Parent = hpFill

    -- Health text
    local hpText = Instance.new("TextLabel")
    hpText.Name = "HPText"
    hpText.Size = UDim2.new(0, 40, 0, 14)
    hpText.Position = UDim2.new(1, -44, 0, 28)
    hpText.BackgroundTransparency = 1
    hpText.Text = "100"
    hpText.TextColor3 = theme.text
    hpText.Font = Enum.Font.GothamSemibold
    hpText.TextSize = 10
    hpText.TextXAlignment = Enum.TextXAlignment.Right
    hpText.Parent = frame

    -- Distance
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "Distance"
    distLabel.Size = UDim2.new(1, -52, 0, 14)
    distLabel.Position = UDim2.new(0, 50, 0, 34)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
    distLabel.Font = Enum.Font.GothamSemibold
    distLabel.TextSize = 10
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = frame

    createDrag(frame)

    -- Update target info
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local closestPlayer = nil
        local closestDist = math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = plr
                end
            end
        end

        if closestPlayer and closestPlayer.Character then
            local humanoid = closestPlayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp then
                nameLabel.Text = closestPlayer.Name
                local health = math.ceil(humanoid.Health)
                local maxHealth = math.ceil(humanoid.MaxHealth)
                local percent = health / maxHealth
                hpFill.Size = UDim2.new(percent, 0, 1, 0)
                hpFill.BackgroundColor3 = Color3.fromRGB(
                    math.floor(255 * (1 - percent)),
                    math.floor(255 * percent),
                    0
                )
                hpText.Text = tostring(health)
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                distLabel.Text = tostring(math.floor(dist)) .. " studs"
                avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. closestPlayer.UserId .. "&w=48&h=48"
                frame.Visible = self.targetHud and self.targetHud.visible
            else
                nameLabel.Text = "None"
                hpFill.Size = UDim2.new(1, 0, 1, 0)
                hpText.Text = "0"
                distLabel.Text = ""
                frame.Visible = false
            end
        else
            nameLabel.Text = "None"
            hpFill.Size = UDim2.new(1, 0, 1, 0)
            hpText.Text = "0"
            distLabel.Text = ""
            if self.targetHud then
                frame.Visible = self.targetHud.visible
            else
                frame.Visible = false
            end
        end
    end)

    self.targetHud = {
        frame = frame,
        connection = connection,
        visible = true,
        setVisible = function(v)
            self.targetHud.visible = v
            frame.Visible = v
        end,
        destroy = function()
            connection:Disconnect()
            frame:Destroy()
            self.targetHud = nil
        end
    }

    return self.targetHud
end

-- ██████  AMBIENCE (full-screen color overlay)  ███████████████████████████████████

function library:createAmbience(screenGui)
    if self.ambience then return self.ambience end

    local frame = Instance.new("Frame")
    frame.Name = "HUD_Ambience"
    frame.Size = UDim2.new(2, 0, 2, 0)
    frame.Position = UDim2.new(-0.5, 0, -0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.55
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = -1
    frame.Parent = screenGui

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local r = math.sin(tick() * 0.5) * 0.5 + 0.5
        local g = math.sin(tick() * 0.5 + 2.094) * 0.5 + 0.5
        local b = math.sin(tick() * 0.5 + 4.188) * 0.5 + 0.5
        frame.BackgroundColor3 = Color3.fromRGB(r * 255, g * 255, b * 255)
    end)

    self.ambience = {
        frame = frame,
        connection = connection,
        setVisible = function(v) frame.Visible = v end,
        destroy = function()
            connection:Disconnect()
            frame:Destroy()
            self.ambience = nil
        end
    }

    return self.ambience
end

function library:destroyAll()
    if self.watermark then self.watermark.destroy() end
    if self.targetHud then self.targetHud.destroy() end
    if self.ambience then self.ambience.destroy() end
end

-- Register in shared.Mana
local shared = shared or _G.shared
if shared then
    shared.Mana = shared.Mana or {}
    shared.Mana.HUDLibrary = library
end

return library
