local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Tabs = {}
local Keybinds = {}
local keybindListening = false
local functionKeybinds = {}

local theme = {
    bg = Color3.fromRGB(14, 14, 23),
    section = Color3.fromRGB(22, 22, 35),
    element = Color3.fromRGB(30, 30, 45),
    accent = Color3.fromRGB(88, 101, 242),
    accentHover = Color3.fromRGB(110, 122, 255),
    text = Color3.fromRGB(220, 220, 230),
    textDim = Color3.fromRGB(140, 140, 160),
    toggleOn = Color3.fromRGB(87, 184, 70),
    toggleOff = Color3.fromRGB(55, 55, 70),
    danger = Color3.fromRGB(237, 66, 69),
    border = Color3.fromRGB(35, 35, 50),
    black = Color3.fromRGB(0, 0, 0),
    font = Enum.Font.GothamSemibold,
    textSize = 13,
    radius = UDim.new(0, 6),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Mana"
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local guilibrary = {
    ScreenGui = ScreenGui,
    Toggled = false,
    GuiKeybind = "RightShift",
    ObjectsToSave = { Tabs = {}, Toggles = {} },
    APIs = {},
    ConfigLoaded = false,
    CanSaveConfig = true,
    Font = theme.font,
}

-- ██████  WINDOW  █████████████████████████████████████████████████████████████████

function guilibrary:CreateWindow(config)
    config = config or {}

    local menuWidth = 650
    local menuHeight = 520
    local sidebarWidth = 140
    local settingsWidth = 240

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Name = "Window"
    frame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    frame.Position = UDim2.new(0.5, -menuWidth / 2, 0.5, -menuHeight / 2)
    frame.BackgroundColor3 = theme.bg
    frame.BorderSizePixel = 0
    frame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.border
    stroke.Thickness = 1
    stroke.Parent = frame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = theme.section
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = corner.CornerRadius
    titleCorner.Parent = titleBar

    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 4)
    titleFix.Position = UDim2.new(0, 0, 1, -4)
    titleFix.BackgroundColor3 = theme.section
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Name or "Mana"
    titleLabel.TextColor3 = theme.text
    titleLabel.Font = theme.font
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundColor3 = theme.danger
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = theme.font
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        guilibrary:Toggle()
    end)

    -- Drag
    do
        local dragging, dragStart, frameStart
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                frameStart = frame.Position
            end
        end)
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging then
                local delta = UserInputService:GetMouseLocation() - dragStart
                frame.Position = UDim2.new(
                    frameStart.X.Scale, frameStart.X.Offset + delta.X,
                    frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, sidebarWidth, 1, -35)
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.BackgroundColor3 = theme.section
    sidebar.BorderSizePixel = 0
    sidebar.Parent = frame

    local sidebarStroke = Instance.new("UIStroke")
    sidebarStroke.Color = theme.border
    sidebarStroke.Thickness = 1
    sidebarStroke.Sides = { Enum.NormalId.Right }
    sidebarStroke.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingLeft = UDim.new(0, 8)
    sidebarPadding.PaddingRight = UDim.new(0, 8)
    sidebarPadding.PaddingTop = UDim.new(0, 12)
    sidebarPadding.Parent = sidebar

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -sidebarWidth, 1, -35)
    contentArea.Position = UDim2.new(0, sidebarWidth, 0, 35)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true
    contentArea.Parent = frame

    -- Settings panel (outside main frame, positioned to the right)
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.Size = UDim2.new(0, settingsWidth, 0, 0)
    settingsPanel.Position = UDim2.new(0, menuWidth + 6, 0, 0)
    settingsPanel.BackgroundColor3 = theme.section
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    settingsPanel.ZIndex = 10
    settingsPanel.Parent = frame

    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 8)
    settingsCorner.Parent = settingsPanel

    local settingsStroke = Instance.new("UIStroke")
    settingsStroke.Color = theme.border
    settingsStroke.Thickness = 1
    settingsStroke.Parent = settingsPanel

    -- Settings title
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, -20, 0, 32)
    settingsTitle.Position = UDim2.new(0, 10, 0, 8)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = ""
    settingsTitle.TextColor3 = theme.text
    settingsTitle.Font = theme.font
    settingsTitle.TextSize = 16
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.Parent = settingsPanel

    -- Settings close button
    local settingsClose = Instance.new("TextButton")
    settingsClose.Name = "SettingsClose"
    settingsClose.Size = UDim2.new(0, 22, 0, 22)
    settingsClose.Position = UDim2.new(1, -28, 0, 8)
    settingsClose.BackgroundColor3 = theme.danger
    settingsClose.Text = "X"
    settingsClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsClose.TextSize = 12
    settingsClose.Font = theme.font
    settingsClose.BorderSizePixel = 0
    settingsClose.AutoButtonColor = false
    settingsClose.ZIndex = 11
    settingsClose.Parent = settingsPanel

    local settingsCloseCorner = Instance.new("UICorner")
    settingsCloseCorner.CornerRadius = UDim.new(0, 4)
    settingsCloseCorner.Parent = settingsClose

    -- Settings keybind section
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "KeybindLabel"
    keybindLabel.Size = UDim2.new(1, -20, 0, 20)
    keybindLabel.Position = UDim2.new(0, 10, 0, 44)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "Keybind"
    keybindLabel.TextColor3 = theme.textDim
    keybindLabel.Font = theme.font
    keybindLabel.TextSize = 12
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = settingsPanel

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Name = "KeybindBtn"
    keybindBtn.Size = UDim2.new(1, -20, 0, 30)
    keybindBtn.Position = UDim2.new(0, 10, 0, 66)
    keybindBtn.BackgroundColor3 = theme.element
    keybindBtn.Text = "None"
    keybindBtn.TextColor3 = theme.text
    keybindBtn.Font = theme.font
    keybindBtn.TextSize = 13
    keybindBtn.BorderSizePixel = 0
    keybindBtn.AutoButtonColor = false
    keybindBtn.ZIndex = 11
    keybindBtn.Parent = settingsPanel

    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 4)
    keybindCorner.Parent = keybindBtn

    -- Settings options container (for child dropdowns/sliders/toggles)
    local settingsOptions = Instance.new("Frame")
    settingsOptions.Name = "SettingsOptions"
    settingsOptions.Size = UDim2.new(1, 0, 0, 0)
    settingsOptions.Position = UDim2.new(0, 0, 0, 104)
    settingsOptions.BackgroundTransparency = 1
    settingsOptions.ZIndex = 11
    settingsOptions.Parent = settingsPanel

    local settingsOptionsLayout = Instance.new("UIListLayout")
    settingsOptionsLayout.Padding = UDim.new(0, 6)
    settingsOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    settingsOptionsLayout.Parent = settingsOptions

    local settingsOptionsPadding = Instance.new("UIPadding")
    settingsOptionsPadding.PaddingLeft = UDim.new(0, 10)
    settingsOptionsPadding.PaddingRight = UDim.new(0, 10)
    settingsOptionsPadding.Parent = settingsOptions

    -- Divider between keybind and options
    local settingsDivider = Instance.new("Frame")
    settingsDivider.Name = "SettingsDivider"
    settingsDivider.Size = UDim2.new(1, -20, 0, 1)
    settingsDivider.Position = UDim2.new(0, 10, 0, 102)
    settingsDivider.BackgroundColor3 = theme.border
    settingsDivider.BorderSizePixel = 0
    settingsDivider.Parent = settingsPanel

    -- Track current toggle whose settings are shown
    local currentSettingsToggle = nil
    local currentOptionsContainer = nil

    local function closeSettings()
        settingsPanel.Visible = false
        if currentOptionsContainer then
            currentOptionsContainer.Parent = currentSettingsToggle._hiddenContainer
            currentOptionsContainer = nil
        end
        currentSettingsToggle = nil
    end

    settingsClose.MouseButton1Click:Connect(closeSettings)

    local function openSettings(toggleAPI)
        if currentSettingsToggle == toggleAPI then return end

        -- Close previous settings
        closeSettings()

        -- Set up new settings
        currentSettingsToggle = toggleAPI
        settingsTitle.Text = toggleAPI.Name

        -- Keybind
        local bindName = toggleAPI._keybind and toggleAPI._keybind.Name or "None"
        keybindBtn.Text = bindName
        keybindBtn._toggleAPI = toggleAPI

        -- Move option container into settings panel
        local container = toggleAPI._hiddenContainer
        if container then
            currentOptionsContainer = container
            container.Parent = settingsOptions
        end

        -- Update panel size
        local optionsHeight = settingsOptionsLayout.AbsoluteContentSize.Y
        local totalH = math.max(108 + optionsHeight + 12, 120)
        settingsPanel.Size = UDim2.new(0, settingsWidth, 0, totalH)

        -- Position settings panel relative to main frame
        local framePos = frame.Position
        local xOff = framePos.X.Offset + menuWidth + 6
        local yOff = framePos.Y.Offset
        settingsPanel.Position = UDim2.new(framePos.X.Scale, xOff, framePos.Y.Scale, yOff)

        settingsPanel.Visible = true
    end

    guilibrary._openSettings = openSettings

    -- Keybind button logic
    keybindBtn.MouseButton1Click:Connect(function()
        local toggleAPI = keybindBtn._toggleAPI
        if toggleAPI then
            if toggleAPI._keybind then
                functionKeybinds[toggleAPI] = nil
                toggleAPI._keybind = nil
                keybindBtn.Text = "None"
                guilibrary:CreateNotification("Keybind", toggleAPI.Name .. " keybind removed")
            else
                keybindBtn.Text = "..."
                keybindListening = true
            end
        end
    end)

    -- Position settings panel when frame moves
    RunService.RenderStepped:Connect(function()
        if settingsPanel.Visible and frame then
            local framePos = frame.Position
            settingsPanel.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + menuWidth + 6,
                framePos.Y.Scale, framePos.Y.Offset
            )
        end
    end)

    -- Pages tracking
    local pages = {}
    local currentPage = nil

    -- Auto-size settings panel when options change
    settingsOptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if settingsPanel.Visible then
            local optionsHeight = settingsOptionsLayout.AbsoluteContentSize.Y
            local totalH = math.max(108 + optionsHeight + 12, 120)
            settingsPanel.Size = UDim2.new(0, settingsWidth, 0, totalH)
        end
    end)

    -- ██████  CREATE TAB  ██████████████████████████████████████████████████████████

    function guilibrary:CreateTab(config)
        config = config or {}
        local name = config.Name or "Tab"

        -- Grid container inside content area
        local gridContainer = Instance.new("ScrollingFrame")
        gridContainer.Name = name
        gridContainer.Size = UDim2.new(1, -12, 1, -12)
        gridContainer.Position = UDim2.new(0, 6, 0, 6)
        gridContainer.BackgroundTransparency = 1
        gridContainer.BorderSizePixel = 0
        gridContainer.ScrollBarThickness = 4
        gridContainer.ScrollBarImageColor3 = theme.element
        gridContainer.Visible = false
        gridContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        gridContainer.Parent = contentArea

        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.FillDirection = Enum.FillDirection.Horizontal
        gridLayout.FillDirectionMaxCells = 3
        gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
        gridLayout.CellSize = UDim2.new(0, 180, 0, 80)
        gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        gridLayout.Parent = gridContainer

        local gridPadding = Instance.new("UIPadding")
        gridPadding.PaddingLeft = UDim.new(0, 4)
        gridPadding.PaddingRight = UDim.new(0, 4)
        gridPadding.PaddingTop = UDim.new(0, 4)
        gridPadding.PaddingBottom = UDim.new(0, 4)
        gridPadding.Parent = gridContainer

        -- Auto-fit cell size to content area width
        local function updateCellSize()
            local contentW = contentArea.AbsoluteSize.X - 12 - 8
            local cellW = math.floor((contentW - 8 * 2) / 3)
            if cellW < 140 then cellW = 140 end
            gridLayout.CellSize = UDim2.new(0, cellW, 0, 80)
        end
        contentArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCellSize)
        task.spawn(function() task.wait() updateCellSize() end)

        -- Auto-update canvas size
        gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local absSize = gridLayout.AbsoluteContentSize
            gridContainer.CanvasSize = UDim2.new(0, absSize.X, 0, absSize.Y + 8)
        end)

        -- Sidebar button
        local btn = Instance.new("TextButton")
        btn.Name = name .. "Btn"
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = theme.section
        btn.Text = name
        btn.TextColor3 = theme.textDim
        btn.Font = theme.font
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = #pages + 1
        btn.Parent = sidebar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        local tabAPI = {
            Name = name,
            Frame = gridContainer,
            Button = btn,
            Layout = gridLayout,
        }

        function tabAPI:CreateToggle(cfg)
            return guilibrary:_createToggle(gridContainer, cfg)
        end

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do
                p.Frame.Visible = false
                p.Button.BackgroundColor3 = theme.section
                p.Button.TextColor3 = theme.textDim
            end
            gridContainer.Visible = true
            btn.BackgroundColor3 = theme.accent
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentPage = name

            -- Close settings when switching tabs
            if settingsPanel.Visible then
                closeSettings()
            end
        end)

        table.insert(pages, tabAPI)
        Tabs[name] = tabAPI

        if not currentPage then
            gridContainer.Visible = true
            btn.BackgroundColor3 = theme.accent
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentPage = name
        end

        guilibrary.ObjectsToSave.Tabs[name] = {
            Name = name,
            API = { Container = gridContainer },
            Type = "Tab",
        }

        return tabAPI
    end

    -- ██████  KEYBIND HANDLER  ███████████████████████████████████████████████████

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if keybindListening and input.UserInputType == Enum.UserInputType.Keyboard then
            keybindListening = false
            local toggleAPI = keybindBtn._toggleAPI
            if toggleAPI then
                toggleAPI._keybind = input.KeyCode
                functionKeybinds[toggleAPI] = toggleAPI
                keybindBtn.Text = input.KeyCode.Name
                guilibrary:CreateNotification("Keybind", toggleAPI.Name .. " bound to " .. input.KeyCode.Name)
            end
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode[guilibrary.GuiKeybind] then
                guilibrary:Toggle()
            end
            for _, toggle in pairs(functionKeybinds) do
                if toggle._keybind and input.KeyCode == toggle._keybind then
                    toggle:Toggle(not toggle._enabled)
                end
            end
        end
    end)

    return guilibrary
end

-- ██████  FUNCTION CARD / TOGGLE  █████████████████████████████████████████████████

function guilibrary:_createToggle(container, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local hoverText = config.HoverText or ""
    local callback = config.Callback or config.Function or function() end
    local default = config.Default or false
    local enabled = default

    local frame = Instance.new("Frame")
    frame.Name = "Func_" .. name:gsub("[^%w_]", "")
    frame.BackgroundColor3 = theme.element
    frame.BorderSizePixel = 0
    frame.Parent = container

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame

    -- Border stroke (changes color based on toggle state)
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = enabled and theme.toggleOn or theme.border
    frameStroke.Thickness = 1.5
    frameStroke.Parent = frame

    -- Function name label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, -8)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.text
    label.Font = theme.font
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = frame

    -- Status indicator (ON/OFF)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -12, 0, 16)
    statusLabel.Position = UDim2.new(0, 6, 1, -20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = enabled and "ON" or "OFF"
    statusLabel.TextColor3 = enabled and theme.toggleOn or theme.textDim
    statusLabel.Font = theme.font
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    -- Hidden option container (for child elements - dropdowns/sliders)
    local hiddenContainer = Instance.new("Frame")
    hiddenContainer.Name = "Options"
    hiddenContainer.Size = UDim2.new(1, 0, 0, 0)
    hiddenContainer.BackgroundTransparency = 1
    hiddenContainer.Visible = false
    hiddenContainer.Parent = ScreenGui  -- keep off-screen

    local optionLayout = Instance.new("UIListLayout")
    optionLayout.Padding = UDim.new(0, 4)
    optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionLayout.Parent = hiddenContainer

    -- Click button
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.BorderSizePixel = 0
    button.Parent = frame

    local api = {
        Name = name,
        GameObject = frame,
        MainObject = frame,
        Container = hiddenContainer,
        _hiddenContainer = hiddenContainer,
        Enabled = enabled,
        _enabled = enabled,
        _keybind = nil,
        _listening = false,
        _options = {},
    }

    function api:Toggle(state, save)
        state = (state == nil) and not api._enabled or state
        api._enabled = state
        api.Enabled = state
        enabled = state

        frameStroke.Color = state and theme.toggleOn or theme.border
        statusLabel.Text = state and "ON" or "OFF"
        statusLabel.TextColor3 = state and theme.toggleOn or theme.textDim

        if state then
            frame.BackgroundColor3 = Color3.fromRGB(38, 38, 55)
        else
            frame.BackgroundColor3 = theme.element
        end
    end

    function api:ReToggle(state)
        api:Toggle(state, true)
        pcall(callback, state)
    end

    function api:SetKeybind(keyCode)
        api._keybind = keyCode
        functionKeybinds[api] = api
    end

    -- Left click: toggle
    button.MouseButton1Click:Connect(function()
        api:Toggle()
        pcall(callback, api._enabled)
    end)

    -- Right click: open settings
    button.MouseButton2Click:Connect(function()
        if guilibrary._openSettings then
            guilibrary._openSettings(api)
        end
    end)

    -- Tooltip on hover
    if hoverText and hoverText ~= "" then
        button.MouseEnter:Connect(function()
            tooltip.Visible = true
            tooltipLabel.Text = hoverText
            local textSize = TextService:GetTextSize(hoverText, 12, theme.font, Vector2.new(300, 200))
            tooltip.Size = UDim2.new(0, textSize.X + 20, 0, textSize.Y + 10)
        end)
        button.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
    end

    -- Hover effect
    button.MouseEnter:Connect(function()
        if not enabled then
            frame.BackgroundColor3 = Color3.fromRGB(38, 38, 55)
        end
    end)
    button.MouseLeave:Connect(function()
        if not enabled then
            frame.BackgroundColor3 = theme.element
        end
    end)

    table.insert(guilibrary.ObjectsToSave.Toggles, {
        Name = name,
        API = api,
        Options = {},
    })

    -- Sub-element creation
    function api:CreateDropdown(cfg)
        cfg.Parent = api
        return guilibrary:_createDropdown(hiddenContainer, cfg, api)
    end

    function api:CreateSlider(cfg)
        cfg.Parent = api
        return guilibrary:_createSlider(hiddenContainer, cfg, api)
    end

    function api:CreateToggle(cfg)
        cfg.Parent = api
        return guilibrary:_createToggle(hiddenContainer, cfg)
    end

    return api
end

-- ██████  TOOLTIP  ████████████████████████████████████████████████████████████████

local tooltip = Instance.new("Frame")
tooltip.Name = "Tooltip"
tooltip.Size = UDim2.new(0, 0, 0, 0)
tooltip.BackgroundColor3 = theme.section
tooltip.BorderSizePixel = 0
tooltip.Visible = false
tooltip.ZIndex = 1000
tooltip.Parent = ScreenGui

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 4)
tooltipCorner.Parent = tooltip

local tooltipStroke = Instance.new("UIStroke")
tooltipStroke.Color = theme.border
tooltipStroke.Parent = tooltip

local tooltipLabel = Instance.new("TextLabel")
tooltipLabel.Size = UDim2.new(1, -12, 1, -6)
tooltipLabel.Position = UDim2.new(0, 6, 0, 3)
tooltipLabel.BackgroundTransparency = 1
tooltipLabel.Text = ""
tooltipLabel.TextColor3 = theme.textDim
tooltipLabel.Font = theme.font
tooltipLabel.TextSize = 12
tooltipLabel.TextXAlignment = Enum.TextXAlignment.Left
tooltipLabel.Parent = tooltip

-- Tooltip follow mouse
RunService.RenderStepped:Connect(function()
    if tooltip.Visible then
        local mPos = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mPos.X + 16, 0, mPos.Y - 8)
    end
end)

-- ██████  DROPDOWN (child option)  ███████████████████████████████████████████████

function guilibrary:_createDropdown(container, config, parentToggle)
    config = config or {}
    local name = config.Name or "Dropdown"
    local list = config.List or {}
    local default = config.Default or list[1] or "None"
    local callback = config.Function or config.Callback or function() end
    local value = default
    local open = false

    local frame = Instance.new("Frame")
    frame.Name = "Dropdown_" .. name:gsub("[^%w_]", "")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = theme.element
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = container

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = theme.radius
    frameCorner.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = theme.section
    btn.Text = name .. " [" .. tostring(value) .. "]"
    btn.TextColor3 = theme.text
    btn.Font = theme.font
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = theme.radius
    btnCorner.Parent = btn

    local listFrame = Instance.new("Frame")
    listFrame.Name = "List"
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, 32)
    listFrame.BackgroundTransparency = 1
    listFrame.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listFrame

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.Parent = listFrame

    local items = {}
    for _, opt in ipairs(list) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.Name = "Opt_" .. tostring(opt):gsub("[^%w_]", "")
        itemBtn.Size = UDim2.new(1, 0, 0, 26)
        itemBtn.BackgroundColor3 = theme.element
        itemBtn.Text = tostring(opt)
        itemBtn.TextColor3 = theme.text
        itemBtn.Font = theme.font
        itemBtn.TextSize = 12
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
        itemBtn.BorderSizePixel = 0
        itemBtn.AutoButtonColor = false
        itemBtn.Visible = false
        itemBtn.Parent = listFrame

        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = itemBtn

        itemBtn.MouseButton1Click:Connect(function()
            value = opt
            btn.Text = name .. " [" .. tostring(opt) .. "]"
            pcall(callback, opt)
            -- Close dropdown after selection
            open = true
            btn.MouseButton1Click:Fire()
        end)

        table.insert(items, itemBtn)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        local listH = #items * 28 + 8
        local newH = open and (32 + listH) or 32
        frame:TweenSize(UDim2.new(1, 0, 0, newH), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        for _, item in ipairs(items) do item.Visible = open end
    end)

    local api = {
        Name = name,
        GameObject = frame,
        MainObject = frame,
        Value = value,
        Container = frame,
    }

    function api:Select(v)
        value = v
        btn.Text = name .. " [" .. tostring(v) .. "]"
        pcall(callback, v)
    end

    function api:Set(v)
        api:Select(v)
    end

    -- Store in parent toggle's options
    if parentToggle and parentToggle._options then
        table.insert(parentToggle._options, {
            type = "Dropdown",
            api = api,
            name = name,
        })
    end

    return api
end

-- ██████  SLIDER (child option)  ██████████████████████████████████████████████████

function guilibrary:_createSlider(container, config, parentToggle)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local round = config.Round or 0
    local callback = config.Function or config.Callback or function() end
    local value = default
    local dragging = false

    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. name:gsub("[^%w_]", "")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = theme.element
    frame.BorderSizePixel = 0
    frame.Parent = container

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = theme.radius
    frameCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = theme.text
    label.Font = theme.font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 50, 0, 18)
    valueLabel.Position = UDim2.new(1, -54, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = theme.accent
    valueLabel.Font = theme.font
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 29)
    track.BackgroundColor3 = theme.toggleOff
    track.BorderSizePixel = 0
    track.Parent = frame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = theme.accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local function update(inputPos)
        local absPos = track.AbsolutePosition
        local absSize = track.AbsoluteSize.X
        local relative = math.clamp((inputPos - absPos.X) / absSize, 0, 1)
        local newVal = min + (max - min) * relative
        if round > 0 then
            newVal = math.round(newVal * (10 ^ round)) / (10 ^ round)
        else
            newVal = math.round(newVal)
        end
        newVal = math.clamp(newVal, min, max)
        value = newVal
        fill.Size = UDim2.new(relative, 0, 1, 0)
        valueLabel.Text = tostring(value)
        pcall(callback, value)
    end

    local trackBtn = Instance.new("TextButton")
    trackBtn.Size = UDim2.new(1, 0, 1, 0)
    trackBtn.BackgroundTransparency = 1
    trackBtn.Text = ""
    trackBtn.BorderSizePixel = 0
    trackBtn.Parent = track

    trackBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    trackBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local inputChanged
    inputChanged = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)

    local api = {
        Name = name,
        GameObject = frame,
        MainObject = frame,
        Value = value,
        Container = frame,
    }

    function api:Set(v)
        v = math.clamp(v, min, max)
        value = v
        fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
        valueLabel.Text = tostring(v)
        pcall(callback, v)
    end

    -- Store in parent toggle's options
    if parentToggle and parentToggle._options then
        table.insert(parentToggle._options, {
            type = "Slider",
            api = api,
            name = name,
        })
    end

    return api
end

-- ██████  NOTIFICATIONS  ███████████████████████████████████████████████████████████

local notifHolder = Instance.new("Folder")
notifHolder.Name = "Notifications"
notifHolder.Parent = ScreenGui

function guilibrary:CreateNotification(title, text, duration)
    duration = duration or 3

    local frame = Instance.new("Frame")
    frame.Name = "Notif"
    frame.Size = UDim2.new(0, 280, 0, 0)
    frame.Position = UDim2.new(1, -300, 0, -100)
    frame.BackgroundColor3 = theme.section
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = notifHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = theme.radius
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.border
    stroke.Parent = frame

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = theme.accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -14, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = theme.text
    titleLabel.Font = theme.font
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -14, 0, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 26)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text or ""
    textLabel.TextColor3 = theme.textDim
    textLabel.Font = theme.font
    textLabel.TextSize = 11
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    local textSize = TextService:GetTextSize(text, 11, theme.font, Vector2.new(256, 1000))
    local totalH = math.max(textSize.Y + 36, 50)

    local y = -10
    for _, child in pairs(notifHolder:GetChildren()) do
        if child ~= frame and child:IsA("Frame") then
            y = y - child.AbsoluteSize.Y - 6
        end
    end
    frame.Position = UDim2.new(1, -300, 1, y)

    frame:TweenSize(UDim2.new(0, 280, 0, totalH), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)

    task.delay(duration, function()
        if frame then
            frame:TweenSize(UDim2.new(0, 280, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            task.delay(0.3, function() frame:Destroy() end)
        end
    end)
end

-- ██████  CONFIG  █████████████████████████████████████████████████████████████████

function guilibrary:SaveConfig()
    local data = { Toggles = {} }
    for _, entry in ipairs(guilibrary.ObjectsToSave.Toggles) do
        local api = entry.API
        if api._enabled ~= nil then
            data.Toggles[entry.Name] = {
                Enabled = api._enabled,
                Keybind = api._keybind and api._keybind.Name or nil,
            }
        end
    end
    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        writefile("Mana/Config/" .. game.PlaceId .. ".json", json)
    end
end

function guilibrary:LoadConfig()
    local path = "Mana/Config/" .. game.PlaceId .. ".json"
    local ok, content = pcall(readfile, path)
    if ok and content then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, content)
        if ok and data and data.Toggles then
            for name, state in pairs(data.Toggles) do
                for _, entry in ipairs(guilibrary.ObjectsToSave.Toggles) do
                    if entry.Name == name then
                        local api = entry.API
                        if state.Enabled ~= nil and api.Toggle then
                            api:Toggle(state.Enabled, true)
                        end
                        if state.Keybind then
                            api._keybind = Enum.KeyCode[state.Keybind]
                            if api._keybind then
                                functionKeybinds[api] = api
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    guilibrary.ConfigLoaded = true
end

-- ██████  TOGGLE  █████████████████████████████████████████████████████████████████

function guilibrary:Toggle()
    guilibrary.Toggled = not guilibrary.Toggled
    ScreenGui.Enabled = guilibrary.Toggled
end

-- ██████  INIT  ███████████████████████████████████████████████████████████████████

shared.Mana = shared.Mana or {}
local M = shared.Mana
M.Connections = M.Connections or {}
M.Friends = M.Friends or {}
M.Functions = M.Functions or {}
M.RunLoops = M.RunLoops or {}
M.Tabs = Tabs
M.GuiLibrary = guilibrary

local function createFolder(n)
    if isfolder and not isfolder(n) then makefolder(n) end
end
createFolder("Mana")
createFolder("Mana/Config")

-- Defer config loading to after Universal.lua creates toggles
task.spawn(function()
    while not guilibrary.ConfigLoaded do
        if #guilibrary.ObjectsToSave.Toggles > 0 then
            guilibrary:LoadConfig()
        end
        task.wait(0.5)
    end
end)

-- Auto-save loop
task.spawn(function()
    while true do
        task.wait(guilibrary.autoSaveDelay or 10)
        if shared.Mana and shared.Mana.Loaded and guilibrary.CanSaveConfig then
            guilibrary:SaveConfig()
        end
    end
end)

return guilibrary
