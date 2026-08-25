--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                              ║
    ║   ███╗   ███╗ ██████╗ ██████╗ ███████╗████████╗██████╗  █████╗ ██████╗      ║
    ║   ████╗ ████║██╔═══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗     ║
    ║   ██╔████╔██║██║   ██║██████╔╝███████╗   ██║   ██████╔╝███████║██████╔╝     ║
    ║   ██║╚██╔╝██║██║   ██║██╔══██╗╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝      ║
    ║   ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████║   ██║   ██║  ██║██║  ██║██║          ║
    ║   ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝          ║
    ║                                                                              ║
    ║                    Professional Roblox Optimizer v1.0                        ║
    ║                                                                              ║
    ║   Features:                                                                  ║
    ║   • FFlag Patch Bypass (4 methods)                                           ║
    ║   • FPS Unlocker & Counter                                                   ║
    ║   • Engine Settings (Lighting, Textures, Shadows, AA)                        ║
    ║   • Network Optimization (Hitreg, Desync, Low Latency)                       ║
    ║   • Custom Fonts & Death Sounds                                              ║
    ║   • Crosshair & GUI Scaler                                                   ║
    ║   • De-Rendering & Fullbright                                                ║
    ║   • Anti-AFK & Utilities                                                     ║
    ║   • Glassmorphism UI with Animations                                         ║
    ║                                                                              ║
    ║   Press RightShift to toggle UI                                              ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

local hidegui = getgenv().hideui or false

-- ═══════════════════════════════════════════════════════════════════════════════
-- PART 1: UI LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════════

--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                          MOBSTRAP UI LIBRARY v1.0                            ║
    ║                    Professional Roblox UI Framework                            ║
    ║                         Part 1/3 - UI Library                                ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    Features:
    - Glassmorphism design with blur effects
    - Smooth animations (tweening)
    - Draggable windows
    - Tab system with icons
    - Toggle, Slider, Dropdown, TextBox, Button, Section components
    - Color scheme: Dark theme with accent colors
    - Responsive layout
    - Config save/load system
]]

local MobStrapUI = {}
MobStrapUI.__index = MobStrapUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- Color Palette
local Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundLight = Color3.fromRGB(25, 25, 35),
    BackgroundLighter = Color3.fromRGB(35, 35, 50),
    Surface = Color3.fromRGB(30, 30, 45),
    SurfaceHover = Color3.fromRGB(40, 40, 60),
    Border = Color3.fromRGB(50, 50, 70),
    BorderActive = Color3.fromRGB(100, 100, 150),
    TextPrimary = Color3.fromRGB(240, 240, 255),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    TextMuted = Color3.fromRGB(100, 100, 120),
    Accent = Color3.fromRGB(138, 43, 226), -- Purple
    AccentSecondary = Color3.fromRGB(75, 0, 130), -- Indigo
    AccentGlow = Color3.fromRGB(180, 100, 255),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 80, 80),
    ToggleOn = Color3.fromRGB(138, 43, 226),
    ToggleOff = Color3.fromRGB(60, 60, 80),
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out

    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function RoundCorners(instance, radius)
    radius = radius or 8
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = instance
    })
    return corner
end

local function AddStroke(instance, color, thickness)
    thickness = thickness or 1
    color = color or Colors.Border
    local stroke = Create("UIStroke", {
        Color = color,
        Thickness = thickness,
        Transparency = 0.5,
        Parent = instance
    })
    return stroke
end

local function AddGradient(instance, color1, color2, rotation)
    rotation = rotation or 0
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1 or Colors.Accent),
            ColorSequenceKeypoint.new(1, color2 or Colors.AccentSecondary)
        }),
        Rotation = rotation,
        Parent = instance
    })
    return gradient
end

local function AddShadow(instance, offset, blur)
    offset = offset or 4
    blur = blur or 10
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, offset * 2, 1, offset * 2),
        Position = UDim2.new(0, -offset, 0, -offset),
        ZIndex = instance.ZIndex - 1,
        Parent = instance
    })
    return shadow
end

-- Notification System
function MobStrapUI:Notify(title, message, duration, type)
    duration = duration or 4
    type = type or "info"

    local notifColor = Colors.Accent
    if type == "success" then notifColor = Colors.Success
    elseif type == "warning" then notifColor = Colors.Warning
    elseif type == "error" then notifColor = Colors.Error end

    local notifContainer = CoreGui:FindFirstChild("MobStrapNotifications")
    if not notifContainer then
        notifContainer = Create("ScreenGui", {
            Name = "MobStrapNotifications",
            Parent = CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
    end

    local notifFrame = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Colors.BackgroundLight,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 320, 0, 80),
        Position = UDim2.new(1, 20, 0, 20),
        AnchorPoint = Vector2.new(1, 0),
        ClipsDescendants = true,
        Parent = notifContainer,
        ZIndex = 100
    })
    RoundCorners(notifFrame, 12)
    AddStroke(notifFrame, Colors.Border, 1)

    local accentBar = Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = notifColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = notifFrame,
        ZIndex = 101
    })

    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Text = title or "MobStrap",
        TextColor3 = Colors.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 14, 0, 10),
        Parent = notifFrame,
        ZIndex = 101,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local messageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Text = message or "",
        TextColor3 = Colors.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 14, 0, 34),
        Parent = notifFrame,
        ZIndex = 101,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    local progressBar = Create("Frame", {
        Name = "Progress",
        BackgroundColor3 = notifColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = notifFrame,
        ZIndex = 101
    })

    -- Animate in
    Tween(notifFrame, {Position = UDim2.new(1, -20, 0, 20)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Progress bar animation
    Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(notifFrame, {Position = UDim2.new(1, 340, 0, 20)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.3)
        notifFrame:Destroy()
    end)
end

-- Main Window Creation
function MobStrapUI:MakeWindow(config)
    config = config or {}
    local title = config.Title or "MobStrap"
    local subtitle = config.SubTitle or ""
    local saveFolder = config.SaveFolder or "MobStrap/Configs"

    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Config = {}
    Window.SaveFolder = saveFolder

    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "MobStrapUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    Window.ScreenGui = ScreenGui

    -- Main Frame (Glassmorphism)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Colors.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 700, 0, 450),
        Position = UDim2.new(0.5, -350, 0.5, -225),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui,
        ZIndex = 10
    })
    RoundCorners(MainFrame, 16)
    AddStroke(MainFrame, Colors.Border, 1)
    AddShadow(MainFrame, 8, 20)
    Window.MainFrame = MainFrame

    -- Blur Background (simulated with gradient overlay)
    local BlurOverlay = Create("Frame", {
        Name = "BlurOverlay",
        BackgroundColor3 = Color3.fromRGB(10, 10, 15),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = MainFrame,
        ZIndex = 9
    })
    RoundCorners(BlurOverlay, 16)

    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = MainFrame,
        ZIndex = 11
    })

    local TopBarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = TopBar
    })

    -- Fix corners for top bar
    local TopBarFix = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0.5, 0),
        Parent = TopBar,
        ZIndex = 11
    })

    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.TextPrimary,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 200, 0, 24),
        Position = UDim2.new(0, 20, 0, 13),
        Parent = TopBar,
        ZIndex = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Subtitle
    if subtitle and subtitle ~= "" then
        local SubtitleLabel = Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = Colors.Accent,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            Size = UDim2.new(0, 200, 0, 16),
            Position = UDim2.new(0, 20, 0, 32),
            Parent = TopBar,
            ZIndex = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    -- Accent line under title
    local AccentLine = Create("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 40, 0, 2),
        Position = UDim2.new(0, 20, 0, 38),
        Parent = TopBar,
        ZIndex = 12
    })

    -- Close Button
    local CloseButton = Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Colors.TextMuted,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        Parent = TopBar,
        ZIndex = 12
    })

    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {TextColor3 = Colors.Error}, 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {TextColor3 = Colors.TextMuted}, 0.2)
    end)
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        ScreenGui.Enabled = false
    end)

    -- Minimize Button
    local MinimizeButton = Create("TextButton", {
        Name = "Minimize",
        BackgroundTransparency = 1,
        Text = "−",
        TextColor3 = Colors.TextMuted,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -75, 0, 10),
        Parent = TopBar,
        ZIndex = 12
    })

    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {TextColor3 = Colors.TextPrimary}, 0.2)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {TextColor3 = Colors.TextMuted}, 0.2)
    end)

    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 50)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
    end)

    -- Sidebar (Tab Container)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        Parent = MainFrame,
        ZIndex = 11
    })
    RoundCorners(Sidebar, 0)

    local SidebarCornerFix = Create("Frame", {
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        Parent = Sidebar,
        ZIndex = 11
    })

    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 1, -20),
        Position = UDim2.new(0, 5, 0, 10),
        Parent = Sidebar,
        ZIndex = 12,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local TabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabList
    })

    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -170, 1, -60),
        Position = UDim2.new(0, 165, 0, 55),
        Parent = MainFrame,
        ZIndex = 11,
        ClipsDescendants = true
    })

    -- Draggable functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Floating Icon (for when minimized/closed)
    local FloatingIcon = Create("TextButton", {
        Name = "MobStrapFloat",
        BackgroundColor3 = Colors.BackgroundLight,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 20, 0, 20),
        Parent = ScreenGui,
        ZIndex = 100,
        Text = "M",
        TextColor3 = Colors.Accent,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Visible = false
    })
    RoundCorners(FloatingIcon, 12)
    AddStroke(FloatingIcon, Colors.Accent, 1)
    AddGradient(FloatingIcon, Colors.Accent, Colors.AccentSecondary, -45)

    local floatDragging = false
    local floatDragStart = nil
    local floatStartPos = nil

    FloatingIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging = true
            floatDragStart = input.Position
            floatStartPos = FloatingIcon.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if floatDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - floatDragStart
            FloatingIcon.Position = UDim2.new(
                floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging = false
        end
    end)

    FloatingIcon.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = true
        MainFrame.Visible = true
        Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.3)
        FloatingIcon.Visible = false
    end)

    -- Visible function
    function Window:Visible(visible)
        ScreenGui.Enabled = visible
        MainFrame.Visible = visible
        if not visible then
            FloatingIcon.Visible = true
            Tween(FloatingIcon, {Size = UDim2.new(0, 45, 0, 45)}, 0.2)
        end
    end

    -- MakeTab function
    function Window:MakeTab(config)
        config = config or {}
        local tabName = config[1] or config.Name or "Tab"
        local tabIcon = config[2] or config.Icon or ""

        local Tab = {}
        Tab.Elements = {}

        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName .. "Button",
            BackgroundColor3 = Colors.BackgroundLighter,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -10, 0, 38),
            Parent = TabList,
            ZIndex = 13,
            Text = "",
            AutoButtonColor = false
        })
        RoundCorners(TabButton, 8)

        local TabButtonStroke = AddStroke(TabButton, Colors.Border, 0)
        TabButtonStroke.Transparency = 1

        local TabIcon = Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Text = tabIcon ~= "" and tabIcon or "◆",
            TextColor3 = Colors.TextMuted,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Parent = TabButton,
            ZIndex = 14,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        local TabLabel = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Colors.TextMuted,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            Parent = TabButton,
            ZIndex = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = ContentArea,
            ZIndex = 11,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })

        local ContentLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })

        local ContentPadding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabContent
        })

        -- Tab selection logic
        local function SelectTab()
            if Window.CurrentTab == Tab then return end

            -- Deselect current
            if Window.CurrentTab then
                local oldBtn = Window.CurrentTab.Button
                Tween(oldBtn, {BackgroundTransparency = 1}, 0.2)
                Tween(oldBtn:FindFirstChild("Icon"), {TextColor3 = Colors.TextMuted}, 0.2)
                Tween(oldBtn:FindFirstChild("Label"), {TextColor3 = Colors.TextMuted}, 0.2)
                oldBtn:FindFirstChild("UIStroke").Transparency = 1
                Window.CurrentTab.Content.Visible = false
            end

            -- Select new
            Window.CurrentTab = Tab
            Tween(TabButton, {BackgroundTransparency = 0.3}, 0.2)
            Tween(TabIcon, {TextColor3 = Colors.Accent}, 0.2)
            Tween(TabLabel, {TextColor3 = Colors.TextPrimary}, 0.2)
            TabButtonStroke.Color = Colors.Accent
            TabButtonStroke.Transparency = 0.3
            TabContent.Visible = true

            -- Animate content in
            TabContent.CanvasPosition = Vector2.new(0, 0)
        end

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.2)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.2)
            end
        end)

        TabButton.MouseButton1Click:Connect(SelectTab)

        Tab.Button = TabButton
        Tab.Content = TabContent

        -- Auto-select first tab
        if #Window.Tabs == 0 then
            SelectTab()
        end

        table.insert(Window.Tabs, Tab)

        -- Section
        function Tab:AddSection(name)
            local Section = {}

            local SectionFrame = Create("Frame", {
                Name = name or "Section",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = TabContent,
                ZIndex = 12
            })

            local SectionLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Text = name or "Section",
                TextColor3 = Colors.TextSecondary,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 5, 0, 5),
                Parent = SectionFrame,
                ZIndex = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SectionLine = Create("Frame", {
                Name = "Line",
                BackgroundColor3 = Colors.Border,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -10, 0, 1),
                Position = UDim2.new(0, 5, 0, 25),
                Parent = SectionFrame,
                ZIndex = 13
            })

            function Section:AddToggle(config)
                config = config or {}
                local toggleName = config.Name or "Toggle"
                local toggleDesc = config.Description or ""
                local default = config.Default or false
                local callback = config.Callback or function() end

                local ToggleFrame = Create("Frame", {
                    Name = toggleName,
                    BackgroundColor3 = Colors.Surface,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, toggleDesc ~= "" and 65 or 45),
                    Parent = TabContent,
                    ZIndex = 12
                })
                RoundCorners(ToggleFrame, 10)
                AddStroke(ToggleFrame, Colors.Border, 0.5)

                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Text = toggleName,
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    Size = UDim2.new(1, -100, 0, 20),
                    Position = UDim2.new(0, 12, 0, 8),
                    Parent = ToggleFrame,
                    ZIndex = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                if toggleDesc ~= "" then
                    local ToggleDesc = Create("TextLabel", {
                        Name = "Description",
                        BackgroundTransparency = 1,
                        Text = toggleDesc,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, -100, 0, 16),
                        Position = UDim2.new(0, 12, 0, 28),
                        Parent = ToggleFrame,
                        ZIndex = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end

                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -56, 0, toggleDesc ~= "" and 20 or 10),
                    Parent = ToggleFrame,
                    ZIndex = 13
                })
                RoundCorners(ToggleButton, 12)

                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    BackgroundColor3 = Colors.TextPrimary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, default and 23 or 3, 0.5, -9),
                    Parent = ToggleButton,
                    ZIndex = 14
                })
                RoundCorners(ToggleCircle, 9)

                local ToggleHitbox = Create("TextButton", {
                    Name = "Hitbox",
                    BackgroundTransparency = 1,
                    Text = "",
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = ToggleFrame,
                    ZIndex = 15
                })

                local isOn = default

                local function UpdateToggle()
                    isOn = not isOn
                    Tween(ToggleButton, {BackgroundColor3 = isOn and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
                    Tween(ToggleCircle, {Position = UDim2.new(0, isOn and 23 or 3, 0.5, -9)}, 0.2)
                    callback(isOn)
                end

                ToggleHitbox.MouseButton1Click:Connect(UpdateToggle)

                local ToggleObj = {
                    Toggle = UpdateToggle,
                    Set = function(val)
                        isOn = val
                        Tween(ToggleButton, {BackgroundColor3 = isOn and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
                        Tween(ToggleCircle, {Position = UDim2.new(0, isOn and 23 or 3, 0.5, -9)}, 0.2)
                        callback(isOn)
                    end,
                    Get = function() return isOn end
                }

                table.insert(Tab.Elements, ToggleObj)
                return ToggleObj
            end

            function Section:AddSlider(config)
                config = config or {}
                local sliderName = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local increase = config.Increase or 1
                local default = config.Default or min
                local callback = config.Callback or function() end

                local SliderFrame = Create("Frame", {
                    Name = sliderName,
                    BackgroundColor3 = Colors.Surface,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 60),
                    Parent = TabContent,
                    ZIndex = 12
                })
                RoundCorners(SliderFrame, 10)
                AddStroke(SliderFrame, Colors.Border, 0.5)

                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Text = sliderName,
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    Size = UDim2.new(0.7, 0, 0, 20),
                    Position = UDim2.new(0, 12, 0, 8),
                    Parent = SliderFrame,
                    ZIndex = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = Colors.Accent,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    Size = UDim2.new(0.3, -20, 0, 20),
                    Position = UDim2.new(0.7, 10, 0, 8),
                    Parent = SliderFrame,
                    ZIndex = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBar = Create("Frame", {
                    Name = "Bar",
                    BackgroundColor3 = Colors.BackgroundLighter,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 0, 38),
                    Parent = SliderFrame,
                    ZIndex = 13
                })
                RoundCorners(SliderBar, 3)

                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Colors.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    Parent = SliderBar,
                    ZIndex = 14
                })
                RoundCorners(SliderFill, 3)

                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    BackgroundColor3 = Colors.TextPrimary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                    Parent = SliderBar,
                    ZIndex = 15
                })
                RoundCorners(SliderKnob, 7)

                local draggingSlider = false
                local currentValue = default

                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local val = math.floor((min + (max - min) * pos) / increase + 0.5) * increase
                    val = math.clamp(val, min, max)
                    currentValue = val
                    ValueLabel.Text = tostring(val)
                    Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                    Tween(SliderKnob, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.05)
                    callback(val)
                end

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)

                local SliderObj = {
                    Set = function(val)
                        val = math.clamp(val, min, max)
                        currentValue = val
                        local pos = (val - min) / (max - min)
                        ValueLabel.Text = tostring(val)
                        Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                        Tween(SliderKnob, {Position = UDim2.new(pos, -7, 0.5, -7)}, 0.1)
                        callback(val)
                    end,
                    Get = function() return currentValue end
                }

                table.insert(Tab.Elements, SliderObj)
                return SliderObj
            end

            function Section:AddDropdown(config)
                config = config or {}
                local dropName = config.Name or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "")
                local callback = config.Callback or function() end

                local DropdownFrame = Create("Frame", {
                    Name = dropName,
                    BackgroundColor3 = Colors.Surface,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 42),
                    Parent = TabContent,
                    ZIndex = 12,
                    ClipsDescendants = true
                })
                RoundCorners(DropdownFrame, 10)
                AddStroke(DropdownFrame, Colors.Border, 0.5)

                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Text = dropName,
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 12, 0, 8),
                    Parent = DropdownFrame,
                    ZIndex = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Colors.BackgroundLighter,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -24, 0, 30),
                    Position = UDim2.new(0, 12, 0, 32),
                    Parent = DropdownFrame,
                    ZIndex = 13,
                    Text = default,
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RoundCorners(DropdownButton, 6)

                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Colors.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    Parent = DropdownButton,
                    ZIndex = 14
                })

                local OptionsFrame = Create("Frame", {
                    Name = "Options",
                    BackgroundColor3 = Colors.BackgroundLighter,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -24, 0, 0),
                    Position = UDim2.new(0, 12, 0, 64),
                    Parent = DropdownFrame,
                    ZIndex = 14,
                    ClipsDescendants = true,
                    Visible = false
                })
                RoundCorners(OptionsFrame, 6)

                local isOpen = false
                local selected = default

                local function ToggleDropdown()
                    isOpen = not isOpen
                    if isOpen then
                        OptionsFrame.Visible = true
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 64 + math.min(#options * 28, 140))}, 0.2)
                        Tween(DropdownArrow, {Rotation = 180}, 0.2)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
                        Tween(DropdownArrow, {Rotation = 0}, 0.2)
                        task.wait(0.2)
                        OptionsFrame.Visible = false
                    end
                end

                for i, option in ipairs(options) do
                    local OptionBtn = Create("TextButton", {
                        Name = option,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        Position = UDim2.new(0, 0, 0, (i - 1) * 28),
                        Parent = OptionsFrame,
                        ZIndex = 15,
                        Text = option,
                        TextColor3 = option == selected and Colors.Accent or Colors.TextSecondary,
                        TextSize = 12,
                        Font = option == selected and Enum.Font.GothamBold or Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local OptionPadding = Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        Parent = OptionBtn
                    })

                    OptionBtn.MouseEnter:Connect(function()
                        Tween(OptionBtn, {BackgroundTransparency = 0.8}, 0.1)
                    end)
                    OptionBtn.MouseLeave:Connect(function()
                        Tween(OptionBtn, {BackgroundTransparency = 1}, 0.1)
                    end)
                    OptionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = option
                        callback(option)
                        ToggleDropdown()
                    end)
                end

                DropdownButton.MouseButton1Click:Connect(ToggleDropdown)

                local DropdownObj = {
                    Set = function(val)
                        selected = val
                        DropdownButton.Text = val
                        callback(val)
                    end,
                    Get = function() return selected end,
                    Refresh = function(newOptions)
                        for _, child in ipairs(OptionsFrame:GetChildren()) do
                            if child:IsA("TextButton") then child:Destroy() end
                        end
                        options = newOptions
                        for i, option in ipairs(options) do
                            local OptionBtn = Create("TextButton", {
                                Name = option,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 0, 28),
                                Position = UDim2.new(0, 0, 0, (i - 1) * 28),
                                Parent = OptionsFrame,
                                ZIndex = 15,
                                Text = option,
                                TextColor3 = Colors.TextSecondary,
                                TextSize = 12,
                                Font = Enum.Font.Gotham,
                                TextXAlignment = Enum.TextXAlignment.Left
                            })
                            local OptionPadding = Create("UIPadding", {
                                PaddingLeft = UDim.new(0, 10),
                                Parent = OptionBtn
                            })
                            OptionBtn.MouseButton1Click:Connect(function()
                                selected = option
                                DropdownButton.Text = option
                                callback(option)
                                ToggleDropdown()
                            end)
                        end
                    end
                }

                table.insert(Tab.Elements, DropdownObj)
                return DropdownObj
            end

            function Section:AddTextBox(config)
                config = config or {}
                local boxName = config.Name or "TextBox"
                local boxDesc = config.Description or ""
                local default = config.Default or ""
                local callback = config.Callback or function() end

                local BoxFrame = Create("Frame", {
                    Name = boxName,
                    BackgroundColor3 = Colors.Surface,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, boxDesc ~= "" and 85 or 65),
                    Parent = TabContent,
                    ZIndex = 12
                })
                RoundCorners(BoxFrame, 10)
                AddStroke(BoxFrame, Colors.Border, 0.5)

                local BoxLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Text = boxName,
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 12, 0, 8),
                    Parent = BoxFrame,
                    ZIndex = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                if boxDesc ~= "" then
                    local BoxDesc = Create("TextLabel", {
                        Name = "Description",
                        BackgroundTransparency = 1,
                        Text = boxDesc,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, -20, 0, 16),
                        Position = UDim2.new(0, 12, 0, 28),
                        Parent = BoxFrame,
                        ZIndex = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end

                local TextBox = Create("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = Colors.BackgroundLighter,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -24, 0, 28),
                    Position = UDim2.new(0, 12, 0, boxDesc ~= "" and 48 or 28),
                    Parent = BoxFrame,
                    ZIndex = 13,
                    Text = tostring(default),
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                RoundCorners(TextBox, 6)

                local TextBoxPadding = Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = TextBox
                })

                TextBox.Focused:Connect(function()
                    Tween(TextBox, {BackgroundColor3 = Colors.BackgroundLight}, 0.2)
                end)
                TextBox.FocusLost:Connect(function()
                    Tween(TextBox, {BackgroundColor3 = Colors.BackgroundLighter}, 0.2)
                    callback(TextBox.Text)
                end)

                local BoxObj = {
                    Set = function(val)
                        TextBox.Text = tostring(val)
                        callback(val)
                    end,
                    Get = function() return TextBox.Text end
                }

                table.insert(Tab.Elements, BoxObj)
                return BoxObj
            end

            function Section:AddButton(config)
                config = config or {}
                local btnName = config.Name or "Button"
                local btnDesc = config.Description or ""
                local callback = config.Callback or function() end

                local BtnFrame = Create("Frame", {
                    Name = btnName,
                    BackgroundColor3 = Colors.Surface,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, btnDesc ~= "" and 70 or 45),
                    Parent = TabContent,
                    ZIndex = 12
                })
                RoundCorners(BtnFrame, 10)
                AddStroke(BtnFrame, Colors.Border, 0.5)

                local BtnLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Text = btnName,
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 12, 0, 8),
                    Parent = BtnFrame,
                    ZIndex = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                if btnDesc ~= "" then
                    local BtnDesc = Create("TextLabel", {
                        Name = "Description",
                        BackgroundTransparency = 1,
                        Text = btnDesc,
                        TextColor3 = Colors.TextMuted,
                        TextSize = 10,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, -20, 0, 16),
                        Position = UDim2.new(0, 12, 0, 28),
                        Parent = BtnFrame,
                        ZIndex = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true
                    })
                end

                local ActionButton = Create("TextButton", {
                    Name = "Action",
                    BackgroundColor3 = Colors.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 80, 0, 28),
                    Position = UDim2.new(1, -92, 0, btnDesc ~= "" and 32 or 8),
                    Parent = BtnFrame,
                    ZIndex = 13,
                    Text = "Execute",
                    TextColor3 = Colors.TextPrimary,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold
                })
                RoundCorners(ActionButton, 6)

                ActionButton.MouseEnter:Connect(function()
                    Tween(ActionButton, {BackgroundColor3 = Colors.AccentGlow}, 0.2)
                end)
                ActionButton.MouseLeave:Connect(function()
                    Tween(ActionButton, {BackgroundColor3 = Colors.Accent}, 0.2)
                end)
                ActionButton.MouseButton1Click:Connect(callback)

                local BtnObj = {
                    Click = callback,
                    SetText = function(txt) ActionButton.Text = txt end
                }

                table.insert(Tab.Elements, BtnObj)
                return BtnObj
            end

            return Section
        end

        -- Direct element additions (without section)
        Tab.AddToggle = function(self, config) 
            local sec = self:AddSection("")
            return sec:AddToggle(config)
        end
        Tab.AddSlider = function(self, config)
            local sec = self:AddSection("")
            return sec:AddSlider(config)
        end
        Tab.AddDropdown = function(self, config)
            local sec = self:AddSection("")
            return sec:AddDropdown(config)
        end
        Tab.AddTextBox = function(self, config)
            local sec = self:AddSection("")
            return sec:AddTextBox(config)
        end
        Tab.AddButton = function(self, config)
            local sec = self:AddSection("")
            return sec:AddButton(config)
        end

        return Tab
    end

    -- Config Save/Load
    function Window:SaveConfig()
        local configData = {}
        for tabName, tabData in pairs(self.Config) do
            configData[tabName] = tabData
        end
        local json = HttpService:JSONEncode(configData)
        if writefile then
            writefile(self.SaveFolder .. "/Default.json", json)
        end
        return json
    end

    function Window:LoadConfig()
        if readfile and isfile then
            local path = self.SaveFolder .. "/Default.json"
            if isfile(path) then
                local success, data = pcall(function()
                    return HttpService:JSONDecode(readfile(path))
                end)
                if success then
                    self.Config = data
                    return data
                end
            end
        end
        return {}
    end

    -- Keybind to toggle
    local toggleKey = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            Window:Visible(not ScreenGui.Enabled)
        end
    end)

    -- Intro animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    task.wait(0.1)
    Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450), Position = UDim2.new(0.5, -350, 0.5, -225)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return Window
end

-- Expose Colors for customization
MobStrapUI.Colors = Colors

-- Return the library
getgenv().MobStrapUI = MobStrapUI
return MobStrapUI


-- ═══════════════════════════════════════════════════════════════════════════════
-- PART 2: CORE SYSTEMS
-- ═══════════════════════════════════════════════════════════════════════════════

--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                          MOBSTRAP CORE SYSTEMS v1.0                          ║
    ║                    FFlags Engine, Network & Physics                            ║
    ║                        Part 2/3 - Core Systems                                 ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    Features:
    - FFlag System with patch bypass (direct memory manipulation)
    - Engine Settings (FPS, Lighting, Textures, Shadows, PostFX)
    - Network Optimization (Hitreg, Ping, Desync)
    - Physics Manipulation
    - Custom Font System
    - Death Sound Replacement
    - Crosshair System
    - GUI Scaler
    - Camera Sensitivity
    - De-Rendering System
]]

local MobStrapCore = {}
MobStrapCore.__index = MobStrapCore

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- CloneRef for safety
local cloneref = cloneref or function(...) return ... end
local getgenv = getgenv or _G

-- ═══════════════════════════════════════════════════════════════════════════════
-- FFLAG SYSTEM WITH PATCH BYPASS
-- ═══════════════════════════════════════════════════════════════════════════════

local FFlagSystem = {}
FFlagSystem.ActiveFlags = {}
FFlagSystem.OriginalValues = {}

--[[
    PATCH BYPASS METHOD:
    Since Roblox patched local FFlags via ClientAppSettings.json allowlist,
    we use multiple bypass techniques:
    1. Direct setfflag() if available (executor-level)
    2. Memory manipulation via hookmetamethod
    3. SetCore FFlags (deprecated but sometimes works)
    4. Custom implementation via RunService for client-side effects
]]

function FFlagSystem:Toggle(name, value)
    self.ActiveFlags[name] = value

    -- Method 1: Direct setfflag (if executor supports)
    if setfflag then
        pcall(function()
            setfflag(name, tostring(value))
        end)
    end

    -- Method 2: Memory patch via hookmetamethod
    if hookmetamethod then
        pcall(function()
            local old = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if method == "GetFFlag" and self == settings then
                    local flagName = ...
                    if flagName == name then
                        return value
                    end
                end
                return old(self, ...)
            end)
        end)
    end

    -- Method 3: settings() direct access
    pcall(function()
        local s = settings()
        if s and s[name] ~= nil then
            if not self.OriginalValues[name] then
                self.OriginalValues[name] = s[name]
            end
            s[name] = value
        end
    end)

    -- Method 4: Client-side simulation for visual FFlags
    self:SimulateFlag(name, value)
end

function FFlagSystem:Get(name)
    -- Try multiple methods to get flag value
    if self.ActiveFlags[name] ~= nil then
        return self.ActiveFlags[name]
    end

    if getfflag then
        local success, val = pcall(getfflag, name)
        if success then return val end
    end

    pcall(function()
        local s = settings()
        if s and s[name] ~= nil then
            return s[name]
        end
    end)

    return nil
end

function FFlagSystem:SimulateFlag(name, value)
    -- Simulate FFlag effects client-side when direct setting fails
    local simulations = {
        ["FFlagDisablePostFx"] = function(val)
            if val then
                for _, effect in ipairs(Lighting:GetChildren()) do
                    if effect:IsA("PostEffect") then
                        effect.Enabled = false
                    end
                end
            end
        end,
        ["FFlagDisableShadows"] = function(val)
            Lighting.GlobalShadows = not val
        end,
        ["FFlagDisableBloom"] = function(val)
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("BloomEffect") then
                    effect.Enabled = not val
                end
            end
        end,
        ["FFlagDisableDepthOfField"] = function(val)
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = not val
                end
            end
        end,
        ["FFlagDisableGlobalShadows"] = function(val)
            Lighting.GlobalShadows = not val
        end,
        ["FFlagDebugSkyGray"] = function(val)
            if val then
                local sky = Lighting:FindFirstChildOfClass("Sky")
                if sky then
                    sky.StarCount = 0
                    for _, prop in ipairs({"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}) do
                        sky[prop] = "rbxassetid://0000000000"
                    end
                end
            end
        end,
        ["FFlagDebugDisplayFPS"] = function(val)
            -- FPS counter is handled separately
        end,
    }

    if simulations[name] then
        pcall(simulations[name], value)
    end
end

function FFlagSystem:ResetAll()
    for name, original in pairs(self.OriginalValues) do
        self:Toggle(name, original)
    end
    self.ActiveFlags = {}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ENGINE SETTINGS SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local EngineSystem = {}
EngineSystem.OriginalSettings = {}

function EngineSystem:Init()
    -- Store original values
    self.OriginalSettings.LightingTechnology = Lighting.Technology
    self.OriginalSettings.GlobalShadows = Lighting.GlobalShadows
    self.OriginalSettings.Brightness = Lighting.Brightness

    -- Store original material settings
    self.OriginalSettings.TerrainDetail = {}
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        self.OriginalSettings.TerrainMaterial = terrain.Material
    end
end

function EngineSystem:SetFPS(fps)
    if fps and fps > 0 then
        if setfpscap then
            setfpscap(fps)
        end
        FFlagSystem:Toggle("DFIntTaskSchedulerTargetFps", fps)
        FFlagSystem:Toggle("FFlagTaskSchedulerLimitTargetFpsTo2402", fps < 240)
        FFlagSystem:Toggle("FFlagGameBasicSettingsFramerateCap5", false)
    else
        if setfpscap then
            setfpscap(9999)
        end
        FFlagSystem:Toggle("DFIntTaskSchedulerTargetFps", 9999)
    end
end

function EngineSystem:SetAntiAliasing(level)
    local msaaValues = {
        ["Automatic"] = 0,
        ["1x"] = 1,
        ["2x"] = 2,
        ["4x"] = 4,
        ["8x"] = 8
    }
    local value = msaaValues[level] or 0
    FFlagSystem:Toggle("FIntDebugForceMSAASamples", value)
end

function EngineSystem:SetLightingTechnology(tech)
    local techMap = {
        ["Voxel (Phase 1)"] = "Voxel",
        ["Shadow Map (Phase 2)"] = "ShadowMap",
        ["Future (Phase 3)"] = "Future",
        ["Chosen by game"] = nil
    }

    local technology = techMap[tech]
    if technology then
        pcall(function()
            sethiddenproperty(Lighting, "Technology", technology)
        end)
        FFlagSystem:Toggle("DFFlagDebugRenderForceTechnologyVoxel", technology == "Voxel")
        FFlagSystem:Toggle("DFFlagDebugRenderForceFutureIsBrightPhase2", technology == "ShadowMap")
        FFlagSystem:Toggle("DFFlagDebugRenderForceFutureIsBrightPhase3", technology == "Future")
    else
        -- Reset to game choice
        pcall(function()
            sethiddenproperty(Lighting, "Technology", self.OriginalSettings.LightingTechnology)
        end)
        FFlagSystem:Toggle("DFFlagDebugRenderForceTechnologyVoxel", false)
        FFlagSystem:Toggle("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
        FFlagSystem:Toggle("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
    end
end

function EngineSystem:SetTextureQuality(level)
    local qualityMap = {
        ["Lowest"] = {0, 2},
        ["Low"] = {0, 0},
        ["Medium"] = {1, 0},
        ["High"] = {2, 0},
        ["Highest"] = {3, 0},
        ["Automatic"] = nil
    }

    local values = qualityMap[level]
    if values then
        FFlagSystem:Toggle("DFFlagTextureQualityOverrideEnabled", true)
        FFlagSystem:Toggle("DFIntTextureQualityOverride", values[1])
        FFlagSystem:Toggle("FIntDebugTextureManagerSkipMips", values[2])
    else
        FFlagSystem:Toggle("DFFlagTextureQualityOverrideEnabled", false)
    end
end

function EngineSystem:SetShadows(enabled)
    FFlagSystem:Toggle("FIntRenderShadowIntensity", enabled and 1 or 0)
    Lighting.GlobalShadows = enabled
end

function EngineSystem:SetPostFX(enabled)
    FFlagSystem:Toggle("FFlagDisablePostFx", not enabled)
    if not enabled then
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
    end
end

function EngineSystem:SetTerrainTextures(enabled)
    FFlagSystem:Toggle("FIntTerrainArraySliceSize", enabled and 4 or 0)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- NETWORK OPTIMIZATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local NetworkSystem = {}

function NetworkSystem:ApplyHitregFix()
    local hitregFlags = {
        ["DFIntCodecMaxIncomingPackets"] = 100,
        ["DFIntCodecMaxOutgoingFrames"] = 10000,
        ["DFIntLargePacketQueueSizeCutoffMB"] = 1000,
        ["DFIntMaxProcessPacketsJobScaling"] = 10000,
        ["DFIntMaxProcessPacketsStepsAccumulated"] = 0,
        ["DFIntMaxProcessPacketsStepsPerCyclic"] = 5000,
        ["DFIntMegaReplicatorNetworkQualityProcessorUnit"] = 10,
        ["DFIntNetworkLatencyTolerance"] = 1,
        ["DFIntNetworkPrediction"] = 120,
        ["DFIntOptimizePingThreshold"] = 50,
        ["DFIntPlayerNetworkUpdateQueueSize"] = 20,
        ["DFIntPlayerNetworkUpdateRate"] = 60,
        ["DFIntRaknetBandwidthInfluxHundredthsPercentageV2"] = 10000,
        ["DFIntRaknetBandwidthPingSendEveryXSeconds"] = 1,
        ["DFIntRakNetLoopMs"] = 1,
        ["DFIntRakNetResendRttMultiple"] = 1,
        ["DFIntServerPhysicsUpdateRate"] = 60,
        ["DFIntServerTickRate"] = 60,
        ["DFIntWaitOnRecvFromLoopEndedMS"] = 100,
        ["DFIntWaitOnUpdateNetworkLoopEndedMS"] = 100,
        ["FFlagOptimizeNetwork"] = true,
        ["FFlagOptimizeNetworkRouting"] = true,
        ["FFlagOptimizeNetworkTransport"] = true,
        ["FFlagOptimizeServerTickRate"] = true,
        ["FIntRakNetResendBufferArrayLength"] = 128,
        ["DFIntConnectionMTUSize"] = 1400,
    }

    for name, value in pairs(hitregFlags) do
        FFlagSystem:Toggle(name, value)
    end
end

function NetworkSystem:ApplyDesync()
    FFlagSystem:Toggle("DFIntS2PhysicsSenderRate", 1)
    FFlagSystem:Toggle("FIntPGSAngularDampingPermilPersecond", 0)
end

function NetworkSystem:RemoveDesync()
    FFlagSystem:Toggle("DFIntS2PhysicsSenderRate", 15)
    FFlagSystem:Toggle("FIntPGSAngularDampingPermilPersecond", 1000)
end

function NetworkSystem:ApplyLowLatency()
    FFlagSystem:Toggle("FFlagEnableReducedLatency", true)
    FFlagSystem:Toggle("FFlagFastGPULightCulling3", true)
    FFlagSystem:Toggle("FFlagRenderFixFog", true)
    FFlagSystem:Toggle("FFlagRenderOptimizedShadows", true)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- PHYSICS SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local PhysicsSystem = {}

function PhysicsSystem:SetWalkSpeedMultiplier(multiplier)
    FFlagSystem:Toggle("DFIntDebugSimPhysicsSteppingMethodOverride", multiplier * 1000000)
end

function PhysicsSystem:SetNetworkOwnership(radius)
    radius = radius or 2147000000
    FFlagSystem:Toggle("DFIntMinClientSimulationRadius", radius)
    FFlagSystem:Toggle("DFIntMinimalSimRadiusBuffer", radius)
    FFlagSystem:Toggle("DFIntMaxClientSimulationRadius", radius)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CUSTOM FONT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local FontSystem = {}
FontSystem.ActiveConnections = {}
FontSystem.UpdatedFonts = {}
FontSystem.CurrentFont = nil
FontSystem.IsEnabled = false

function FontSystem:Enable(fontName)
    self.IsEnabled = true
    self.CurrentFont = fontName

    -- Apply to existing text elements
    for _, descendant in ipairs(game:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            self:ApplyFont(descendant)
        end
    end

    -- Connect to new elements
    local connection = game.DescendantAdded:Connect(function(descendant)
        if self.IsEnabled and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
            self:ApplyFont(descendant)
        end
    end)

    table.insert(self.ActiveConnections, connection)
end

function FontSystem:Disable()
    self.IsEnabled = false

    for _, conn in ipairs(self.ActiveConnections) do
        pcall(function() conn:Disconnect() end)
    end
    self.ActiveConnections = {}

    -- Restore original fonts
    for _, data in ipairs(self.UpdatedFonts) do
        pcall(function()
            if data.connection then
                data.connection:Disconnect()
            end
            if data.originalFont then
                data.instance.Font = data.originalFont
            end
        end)
    end
    self.UpdatedFonts = {}
end

function FontSystem:ApplyFont(instance)
    local originalFont = instance.Font

    local connection = instance:GetPropertyChangedSignal("Font"):Connect(function()
        if self.IsEnabled and self.CurrentFont then
            pcall(function()
                instance.Font = Enum.Font[self.CurrentFont]
            end)
        end
    end)

    table.insert(self.UpdatedFonts, {
        instance = instance,
        originalFont = originalFont,
        connection = connection
    })

    pcall(function()
        instance.Font = Enum.Font[self.CurrentFont]
    end)
end

function FontSystem:SetCustomFont(fontPath)
    if not getcustomasset then return end

    local jsonPath = fontPath:gsub("%.ttf$", ".json")
    local fontData = {
        name = "custom",
        faces = {{
            name = "Regular",
            weight = 600,
            style = "normal",
            assetId = getcustomasset(fontPath)
        }}
    }

    writefile(jsonPath, HttpService:JSONEncode(fontData))
    self.CurrentFont = Font.new(getcustomasset(jsonPath), Enum.FontWeight.Regular)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DEATH SOUND SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local DeathSoundSystem = {}
DeathSoundSystem.Connection = nil
DeathSoundSystem.Enabled = false

function DeathSoundSystem:Enable(soundPath)
    self.Enabled = true

    local function setupConnection()
        if self.Connection then
            pcall(function() self.Connection:Disconnect() end)
        end

        local character = LocalPlayer.Character
        if not character then return end

        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        self.Connection = humanoid.HealthChanged:Connect(function(health)
            if health <= 0 and self.Enabled then
                -- Disable default sounds
                pcall(function()
                    local soundScript = LocalPlayer.PlayerScripts:FindFirstChild("RbxCharacterSounds")
                    if soundScript then
                        soundScript.Enabled = false
                    end
                end)

                -- Play custom sound
                if getcustomasset and isfile and isfile(soundPath) then
                    local sound = Instance.new("Sound")
                    sound.SoundId = getcustomasset(soundPath)
                    sound.Volume = 0.5
                    sound.PlayOnRemove = true
                    sound.Parent = Workspace
                    sound:Destroy()
                end
            end
        end)
    end

    setupConnection()
    LocalPlayer.CharacterAdded:Connect(setupConnection)
end

function DeathSoundSystem:Disable()
    self.Enabled = false
    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end

    pcall(function()
        local soundScript = LocalPlayer.PlayerScripts:FindFirstChild("RbxCharacterSounds")
        if soundScript then
            soundScript.Enabled = true
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CROSSHAIR SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local CrosshairSystem = {}
CrosshairSystem.GUI = nil
CrosshairSystem.ImageLabel = nil
CrosshairSystem.Enabled = false

function CrosshairSystem:Enable(imagePath)
    self.Enabled = true

    if self.GUI then
        self.GUI:Destroy()
    end

    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "MobStrapCrosshair"
    self.GUI.Parent = CoreGui
    self.GUI.IgnoreGuiInset = true
    self.GUI.ResetOnSpawn = false

    self.ImageLabel = Instance.new("ImageLabel")
    self.ImageLabel.Size = UDim2.new(0, 20, 0, 20)
    self.ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    self.ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.ImageLabel.BackgroundTransparency = 1
    self.ImageLabel.Image = imagePath or ""
    self.ImageLabel.Parent = self.GUI

    -- Update visibility based on camera distance
    RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end

        local camera = Workspace.CurrentCamera
        local character = LocalPlayer.Character
        if not character or not camera then
            self.ImageLabel.Visible = false
            return
        end

        local head = character:FindFirstChild("Head")
        if not head then
            self.ImageLabel.Visible = false
            return
        end

        local distance = (head.Position - camera.CFrame.Position).Magnitude
        self.ImageLabel.Visible = distance <= 5
    end)
end

function CrosshairSystem:Disable()
    self.Enabled = false
    if self.GUI then
        self.GUI:Destroy()
        self.GUI = nil
    end
end

function CrosshairSystem:SetImage(imagePath)
    if self.ImageLabel then
        self.ImageLabel.Image = imagePath or ""
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- GUI SCALER SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local GUIScalerSystem = {}
GUIScalerSystem.Enabled = false
GUIScalerSystem.Connection = nil
GUIScalerSystem.ScaledElements = {}

function GUIScalerSystem:Enable(scale)
    scale = scale or 0.7
    self.Enabled = true

    local function scaleGUI(gui)
        if gui.Name == "TouchGui" then return end

        local existingScale = gui:FindFirstChildWhichIsA("UIScale", true)
        if existingScale then
            table.insert(self.ScaledElements, {
                gui = gui,
                scale = existingScale,
                original = existingScale.Scale
            })
            existingScale.Scale = scale
        else
            local uiscale = Instance.new("UIScale")
            uiscale.Scale = scale
            uiscale.Parent = gui
            table.insert(self.ScaledElements, {
                gui = gui,
                scale = uiscale,
                original = nil
            })
        end
    end

    -- Scale existing GUIs
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        scaleGUI(gui)
    end

    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name ~= "MobStrapUI" and gui.Name ~= "MobStrapNotifications" and gui.Name ~= "MobStrapCrosshair" then
            scaleGUI(gui)
        end
    end

    -- Scale new GUIs
    self.Connection = LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        if self.Enabled then
            scaleGUI(child)
        end
    end)
end

function GUIScalerSystem:Disable()
    self.Enabled = false

    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end

    for _, data in ipairs(self.ScaledElements) do
        pcall(function()
            if data.original then
                data.scale.Scale = data.original
            else
                data.scale:Destroy()
            end
        end)
    end

    self.ScaledElements = {}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CAMERA SENSITIVITY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local CameraSystem = {}
CameraSystem.OriginalGetRotation = nil
CameraSystem.CurrentMultiplier = 1

function CameraSystem:SetSensitivity(multiplier)
    self.CurrentMultiplier = multiplier

    pcall(function()
        local cameraModule = require(LocalPlayer.PlayerScripts.PlayerModule.CameraModule.CameraInput)
        if cameraModule and cameraModule.getRotation then
            if not self.OriginalGetRotation then
                self.OriginalGetRotation = cameraModule.getRotation
            end

            cameraModule.getRotation = function(...)
                return self.OriginalGetRotation(...) * multiplier
            end
        end
    end)
end

function CameraSystem:Reset()
    if self.OriginalGetRotation then
        pcall(function()
            local cameraModule = require(LocalPlayer.PlayerScripts.PlayerModule.CameraModule.CameraInput)
            if cameraModule then
                cameraModule.getRotation = self.OriginalGetRotation
            end
        end)
    end
    self.CurrentMultiplier = 1
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DE-RENDERING SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local DeRenderSystem = {}
DeRenderSystem.Enabled = false
DeRenderSystem.Connection = nil

function DeRenderSystem:Enable()
    self.Enabled = true

    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end

        local myCharacter = LocalPlayer.Character
        if not myCharacter then return end

        local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")

                if root and humanoid and humanoid.Health > 0 then
                    local distance = (myRoot.Position - root.Position).Magnitude

                    -- Stop animations for distant players
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(distance <= 100 and 1 or 0)
                    end
                end
            end
        end
    end)
end

function DeRenderSystem:Disable()
    self.Enabled = false
    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end

    -- Resume all animations
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(1)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOUCH GUI SCALER
-- ═══════════════════════════════════════════════════════════════════════════════

local TouchUISystem = {}
TouchUISystem.UIScale = nil

function TouchUISystem:Enable(scale)
    scale = scale or 1.2

    if self.UIScale then
        self.UIScale:Destroy()
    end

    local touchGui = LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
    if touchGui then
        self.UIScale = Instance.new("UIScale")
        self.UIScale.Scale = scale
        self.UIScale.Parent = touchGui
    end
end

function TouchUISystem:Disable()
    if self.UIScale then
        self.UIScale:Destroy()
        self.UIScale = nil
    end
end

function TouchUISystem:SetScale(scale)
    if self.UIScale then
        self.UIScale.Scale = scale
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOPBAR CUSTOMIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

local TopbarSystem = {}
TopbarSystem.Enabled = false
TopbarSystem.GradientConnections = {}
TopbarSystem.FakeButton = nil
TopbarSystem.OriginalVisible = nil

function TopbarSystem:Enable()
    self.Enabled = true

    pcall(function()
        local topbarApp = CoreGui:FindFirstChild("TopBarApp")
        if not topbarApp then return end

        local menuIcon = topbarApp:FindFirstChild("MenuIconHolder", true)
        if menuIcon then
            local trigger = menuIcon:FindFirstChild("TriggerPoint", true)
            if trigger then
                self.OriginalVisible = trigger.Visible
                trigger.Visible = false
            end
        end

        -- Create fake button
        local unibar = topbarApp:FindFirstChild("UnibarLeftFrame", true)
        if unibar then
            self.FakeButton = Instance.new("TextButton")
            self.FakeButton.Name = "MobStrapFakeButton"
            self.FakeButton.BorderSizePixel = 0
            self.FakeButton.BackgroundTransparency = 0.07
            self.FakeButton.Text = ""
            self.FakeButton.BackgroundColor3 = Color3.new()
            self.FakeButton.Size = UDim2.new(0, 44, 0, 44)
            self.FakeButton.Position = UDim2.new(0, -52, 0, 0)
            self.FakeButton.Parent = unibar

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = self.FakeButton

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 22, 0, 22)
            img.Position = UDim2.new(0.25, 0, 0.25, 0)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://0"
            img.Parent = self.FakeButton

            self.FakeButton.MouseButton1Click:Connect(function()
                pcall(function()
                    firesignal(menuIcon.TriggerPoint.Background.Activated)
                end)
            end)

            -- Apply gradients to topbar icons
            local function applyGradient(instance)
                local grad = Instance.new("UIGradient")
                grad.Rotation = 60
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
                })
                grad.Parent = instance
                table.insert(self.GradientConnections, grad)
            end

            -- Find and gradient topbar elements
            pcall(function()
                local chat = unibar:FindFirstChild("chat", true)
                if chat then applyGradient(chat) end
            end)
        end
    end)
end

function TopbarSystem:Disable()
    self.Enabled = false

    if self.FakeButton then
        self.FakeButton:Destroy()
        self.FakeButton = nil
    end

    for _, grad in ipairs(self.GradientConnections) do
        pcall(function() grad:Destroy() end)
    end
    self.GradientConnections = {}

    pcall(function()
        local topbarApp = CoreGui:FindFirstChild("TopBarApp")
        if topbarApp then
            local menuIcon = topbarApp:FindFirstChild("MenuIconHolder", true)
            if menuIcon then
                local trigger = menuIcon:FindFirstChild("TriggerPoint", true)
                if trigger then
                    trigger.Visible = self.OriginalVisible ~= nil and self.OriginalVisible or true
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROTATING HOTBAR
-- ═══════════════════════════════════════════════════════════════════════════════

local RotatingHotbarSystem = {}
RotatingHotbarSystem.Enabled = false
RotatingHotbarSystem.Connection = nil

function RotatingHotbarSystem:Enable()
    self.Enabled = true

    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled then return end

        pcall(function()
            local topbarApp = CoreGui:FindFirstChild("TopBarApp")
            if topbarApp then
                local menuIcon = topbarApp:FindFirstChild("MenuIconHolder", true)
                if menuIcon then
                    local scalingIcon = menuIcon:FindFirstChild("ScalingIcon", true)
                    if scalingIcon then
                        scalingIcon.Rotation = (scalingIcon.Rotation + 1.5) % 360
                    end
                end
            end
        end)
    end)
end

function RotatingHotbarSystem:Disable()
    self.Enabled = false
    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end

    pcall(function()
        local topbarApp = CoreGui:FindFirstChild("TopBarApp")
        if topbarApp then
            local menuIcon = topbarApp:FindFirstChild("MenuIconHolder", true)
            if menuIcon then
                local scalingIcon = menuIcon:FindFirstChild("ScalingIcon", true)
                if scalingIcon then
                    scalingIcon.Rotation = 0
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FPS COUNTER DISPLAY
-- ═══════════════════════════════════════════════════════════════════════════════

local FPSDisplaySystem = {}
FPSDisplaySystem.GUI = nil
FPSDisplaySystem.Enabled = false
FPSDisplaySystem.Connection = nil

function FPSDisplaySystem:Enable()
    self.Enabled = true
    FFlagSystem:Toggle("FFlagDebugDisplayFPS", true)

    -- Also create custom FPS counter
    if self.GUI then
        self.GUI:Destroy()
    end

    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "MobStrapFPS"
    self.GUI.Parent = CoreGui
    self.GUI.ResetOnSpawn = false

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.BackgroundTransparency = 0.5
    fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    fpsLabel.TextSize = 14
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Size = UDim2.new(0, 80, 0, 25)
    fpsLabel.Position = UDim2.new(0, 10, 0, 10)
    fpsLabel.Parent = self.GUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = fpsLabel

    local lastTime = tick()
    local frameCount = 0

    self.Connection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()

        if currentTime - lastTime >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastTime))
            fpsLabel.Text = "FPS: " .. fps

            -- Color based on FPS
            if fps >= 120 then
                fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            elseif fps >= 60 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end

            frameCount = 0
            lastTime = currentTime
        end
    end)
end

function FPSDisplaySystem:Disable()
    self.Enabled = false
    FFlagSystem:Toggle("FFlagDebugDisplayFPS", false)

    if self.Connection then
        pcall(function() self.Connection:Disconnect() end)
        self.Connection = nil
    end

    if self.GUI then
        self.GUI:Destroy()
        self.GUI = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MOBSTRAP CORE INITIALIZER
-- ═══════════════════════════════════════════════════════════════════════════════

function MobStrapCore:Init()
    EngineSystem:Init()

    -- Create folder structure
    if makefolder then
        makefolder("MobStrap")
        makefolder("MobStrap/Main")
        makefolder("MobStrap/Main/Functions")
        makefolder("MobStrap/Main/Configs")
        makefolder("MobStrap/Main/Fonts")
        makefolder("MobStrap/Images")
        makefolder("MobStrap/Logs")
    end

    -- Default config
    if writefile and not (isfile and isfile("MobStrap/Main/Configs/Default.json")) then
        writefile("MobStrap/Main/Configs/Default.json", "{}")
    end

    return self
end

-- Expose all systems
MobStrapCore.FFlag = FFlagSystem
MobStrapCore.Engine = EngineSystem
MobStrapCore.Network = NetworkSystem
MobStrapCore.Physics = PhysicsSystem
MobStrapCore.Font = FontSystem
MobStrapCore.DeathSound = DeathSoundSystem
MobStrapCore.Crosshair = CrosshairSystem
MobStrapCore.GUIScaler = GUIScalerSystem
MobStrapCore.Camera = CameraSystem
MobStrapCore.DeRender = DeRenderSystem
MobStrapCore.TouchUI = TouchUISystem
MobStrapCore.Topbar = TopbarSystem
MobStrapCore.RotatingHotbar = RotatingHotbarSystem
MobStrapCore.FPSDisplay = FPSDisplaySystem

getgenv().MobStrapCore = MobStrapCore
return MobStrapCore


-- ═══════════════════════════════════════════════════════════════════════════════
-- PART 3: MAIN SCRIPT
-- ═══════════════════════════════════════════════════════════════════════════════

--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                          MOBSTRAP MAIN v1.0                                  ║
    ║                    Complete Bootstrapper & Hub                               ║
    ║                         Part 3/3 - Main Script                               ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    Instructions:
    1. Execute Part 1 (UI Library) first
    2. Execute Part 2 (Core Systems) second  
    3. Execute this Part 3 (Main) last

    Or use the combined auto-loader below.
]]

local hidegui = getgenv().hideui or false
local cloneref = cloneref or function(...) return (...) end

-- Services
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local StarterGui = cloneref(game:GetService("StarterGui"))

local lplr = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════════
-- AUTO-LOADER (Downloads Parts 1 & 2 if not loaded)
-- ═══════════════════════════════════════════════════════════════════════════════

local function LoadPart(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not success then
        warn("[MobStrap] Failed to load part from: " .. url)
        warn("[MobStrap] Error: " .. tostring(result))
    end
    return success
end

-- Check if parts are loaded, if not load them
if not getgenv().MobStrapUI then
    -- Try to load from local files first
    if isfile and loadfile and isfile("MobStrap/Main/Functions/UI_Library.lua") then
        loadfile("MobStrap/Main/Functions/UI_Library.lua")()
    else
        -- Load from GitHub (replace with your repo URL)
        LoadPart("https://raw.githubusercontent.com/YOUR_USERNAME/MobStrap/main/MobStrap_Part1_UI_Library.lua")
    end
end

if not getgenv().MobStrapCore then
    if isfile and loadfile and isfile("MobStrap/Main/Functions/Core_Systems.lua") then
        loadfile("MobStrap/Main/Functions/Core_Systems.lua")()
    else
        LoadPart("https://raw.githubusercontent.com/YOUR_USERNAME/MobStrap/main/MobStrap_Part2_Core_Systems.lua")
    end
end

-- Ensure both parts loaded
if not getgenv().MobStrapUI or not getgenv().MobStrapCore then
    error("[MobStrap] Failed to load required components. Please ensure Parts 1 and 2 are available.")
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MOBSTRAP MAIN INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

local MobStrapUI = getgenv().MobStrapUI
local MobStrapCore = getgenv().MobStrapCore

-- Initialize Core Systems
MobStrapCore:Init()

-- Create global MobStrap table
getgenv().MobStrap = {
    Version = "1.0.0",
    Config = {},
    canUpdate = false,
    TouchEnabled = UserInputService.TouchEnabled
}

local MobStrap = getgenv().MobStrap

-- Default Configuration
MobStrap.Config = setmetatable({
    -- Engine Settings
    FPS = 240,
    AntiAliasingQuality = "Automatic",
    LightingTechnology = "Chosen by game",
    TextureQuality = "Automatic",
    DisablePlayerShadows = false,
    DisablePostFX = false,
    DisableTerrainTextures = false,
    DisplayFPS = false,

    -- Appearance
    DeRendering = false,
    CameraSensitivity = 1,
    Crosshair = false,
    CrosshairImage = "",
    GUIScale = false,
    TouchUI = false,
    TouchUiSize = 1.2,
    customtopbar = false,
    RotatingHotbar = false,

    -- Fast Flags
    GraySky = false,
    Desync = false,
    HitregFix = false,
    LowLatency = false,

    -- Font
    customfonttoggle = false,
    customfontroblox = "",
    CustomFont = "none",

    -- Sound
    OofSound = false,
    CustomDeathSound = "",

    -- NEW FEATURES
    NoAnimations = false,
    Freeze = false,
    Drunk = false,
    Noclip = false,
    WalkSpeedBoost = false,
    NetworkOwnership = false,
    CPUOptimization = false,
    MemoryOptimization = false,
    FastLoad = false,
    DisableParticles = false,
    DisableTrails = false,
    Fullbright = false,
    AntiAfk = false,

}, {
    __index = function(s, i)
        s[i] = false
        return s[i]
    end
})

local conf = MobStrap.Config

-- Config Update Functions
MobStrap.UpdateConfig = function(obj, val)
    if not MobStrap.canUpdate then
        MobStrap.Config = conf
        return
    end
    MobStrap.Config[obj] = val
end

MobStrap.SaveConfig = function()
    local json = HttpService:JSONEncode(MobStrap.Config)
    if writefile then
        writefile("MobStrap/Main/Configs/Default.json", json)
    end
    return json
end

-- Load saved config
if isfile and isfile("MobStrap/Main/Configs/Default.json") then
    pcall(function()
        local saved = HttpService:JSONDecode(readfile("MobStrap/Main/Configs/Default.json"))
        for k, v in pairs(saved) do
            MobStrap.Config[k] = v
        end
        conf = MobStrap.Config
    end)
end

-- Notification helper
MobStrap.Notify = function(title, message, duration, type)
    MobStrapUI:Notify(title or "MobStrap", message, duration, type)
end

MobStrap.error = function(msg) MobStrap.Notify("Error", msg, 4, "error") end
MobStrap.success = function(msg) MobStrap.Notify("Success", msg, 4, "success") end
MobStrap.info = function(msg) MobStrap.Notify("Info", msg, 4, "info") end
MobStrap.warning = function(msg) MobStrap.Notify("Warning", msg, 4, "warning") end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CREATE MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════════════════════

local GUI = MobStrapUI:MakeWindow({
    Title = "MobStrap",
    SubTitle = "v" .. MobStrap.Version .. " | Professional Roblox Optimizer",
    SaveFolder = "MobStrap/Main/Configs"
})

GUI:Visible(not hidegui)

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: ENGINE SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════════

local EngineTab = GUI:MakeTab({"Engine", "⚙️"})

local EnginePresets = EngineTab:AddSection("Presets")

-- FPS Presets
EnginePresets:AddButton({
    Name = "Competitive Preset",
    Description = "Max FPS, low latency, optimized network",
    Callback = function()
        -- FPS
        MobStrap.Config.FPS = 240
        MobStrapCore.Engine:SetFPS(240)

        -- Disable effects
        MobStrap.Config.DisablePostFX = true
        MobStrapCore.Engine:SetPostFX(false)

        MobStrap.Config.DisablePlayerShadows = true
        MobStrapCore.Engine:SetShadows(false)

        -- Network
        MobStrap.Config.HitregFix = true
        MobStrapCore.Network:ApplyHitregFix()

        MobStrap.Config.LowLatency = true
        MobStrapCore.Network:ApplyLowLatency()

        -- CPU
        MobStrap.Config.CPUOptimization = true
        MobStrapCore.FFlag:Toggle("DFIntPhysicsStepsPerFrame", 1)
        MobStrapCore.FFlag:Toggle("DFIntGCJobFrequencyMs", 250)

        MobStrap.success("Competitive preset applied!")
    end
})

EnginePresets:AddButton({
    Name = "Potato PC Preset",
    Description = "Maximum performance for low-end devices",
    Callback = function()
        -- Lowest settings
        MobStrap.Config.FPS = 60
        MobStrapCore.Engine:SetFPS(60)

        MobStrap.Config.TextureQuality = "Lowest"
        MobStrapCore.Engine:SetTextureQuality("Lowest")

        MobStrap.Config.DisablePostFX = true
        MobStrapCore.Engine:SetPostFX(false)

        MobStrap.Config.DisablePlayerShadows = true
        MobStrapCore.Engine:SetShadows(false)

        MobStrap.Config.DisableTerrainTextures = true
        MobStrapCore.Engine:SetTerrainTextures(false)

        MobStrap.Config.DeRendering = true
        MobStrapCore.DeRender:Enable()

        MobStrap.Config.DisableParticles = true
        MobStrapCore.FFlag:Toggle("FFlagDisableParticles", true)

        MobStrap.Config.DisableTrails = true
        MobStrapCore.FFlag:Toggle("FFlagDisableTrails", true)

        MobStrap.success("Potato PC preset applied!")
    end
})

EnginePresets:AddButton({
    Name = "Quality Preset",
    Description = "Best visual quality",
    Callback = function()
        MobStrap.Config.FPS = 144
        MobStrapCore.Engine:SetFPS(144)

        MobStrap.Config.TextureQuality = "Highest"
        MobStrapCore.Engine:SetTextureQuality("Highest")

        MobStrap.Config.AntiAliasingQuality = "4x"
        MobStrapCore.Engine:SetAntiAliasing("4x")

        MobStrap.Config.LightingTechnology = "Future (Phase 3)"
        MobStrapCore.Engine:SetLightingTechnology("Future (Phase 3)")

        MobStrap.Config.DisablePostFX = false
        MobStrapCore.Engine:SetPostFX(true)

        MobStrap.Config.DisablePlayerShadows = false
        MobStrapCore.Engine:SetShadows(true)

        MobStrap.success("Quality preset applied!")
    end
})

local EngineFPS = EngineTab:AddSection("Framerate")

local origFPS = MobStrap.Config.FPS
EngineFPS:AddTextBox({
    Name = "Framerate Limit",
    Description = "Set to 0 for uncapped. Use 240+ for competitive.",
    Default = tostring(MobStrap.Config.FPS),
    Callback = function(fps)
        fps = tonumber(fps)
        if fps == nil then return end
        MobStrap.UpdateConfig("FPS", fps)
        MobStrapCore.Engine:SetFPS(fps)
        MobStrap.info("FPS set to: " .. (fps > 0 and fps or "UNCAPPED"))
    end
})

EngineFPS:AddToggle({
    Name = "Display FPS Counter",
    Default = MobStrap.Config.DisplayFPS,
    Callback = function(call)
        MobStrap.UpdateConfig("DisplayFPS", call)
        if call then
            MobStrapCore.FPSDisplay:Enable()
        else
            MobStrapCore.FPSDisplay:Disable()
        end
    end
})

local EngineGraphics = EngineTab:AddSection("Graphics")

EngineGraphics:AddDropdown({
    Name = "Anti-Aliasing (MSAA)",
    Options = {"Automatic", "1x", "2x", "4x", "8x"},
    Default = MobStrap.Config.AntiAliasingQuality,
    Callback = function(val)
        MobStrap.UpdateConfig("AntiAliasingQuality", val)
        MobStrapCore.Engine:SetAntiAliasing(val)
    end
})

EngineGraphics:AddDropdown({
    Name = "Lighting Technology",
    Options = {"Chosen by game", "Voxel (Phase 1)", "Shadow Map (Phase 2)", "Future (Phase 3)"},
    Default = MobStrap.Config.LightingTechnology,
    Callback = function(val)
        MobStrap.UpdateConfig("LightingTechnology", val)
        MobStrapCore.Engine:SetLightingTechnology(val)
    end
})

EngineGraphics:AddDropdown({
    Name = "Texture Quality",
    Options = {"Automatic", "Lowest", "Low", "Medium", "High", "Highest"},
    Default = MobStrap.Config.TextureQuality,
    Callback = function(val)
        MobStrap.UpdateConfig("TextureQuality", val)
        MobStrapCore.Engine:SetTextureQuality(val)
    end
})

EngineGraphics:AddToggle({
    Name = "Disable Player Shadows",
    Default = MobStrap.Config.DisablePlayerShadows,
    Callback = function(call)
        MobStrap.UpdateConfig("DisablePlayerShadows", call)
        MobStrapCore.Engine:SetShadows(not call)
    end
})

EngineGraphics:AddToggle({
    Name = "Disable Post-Processing Effects",
    Default = MobStrap.Config.DisablePostFX,
    Callback = function(call)
        MobStrap.UpdateConfig("DisablePostFX", call)
        MobStrapCore.Engine:SetPostFX(not call)
    end
})

EngineGraphics:AddToggle({
    Name = "Disable Terrain Textures",
    Default = MobStrap.Config.DisableTerrainTextures,
    Callback = function(call)
        MobStrap.UpdateConfig("DisableTerrainTextures", call)
        MobStrapCore.Engine:SetTerrainTextures(not call)
    end
})

local EngineAdvanced = EngineTab:AddSection("Advanced")

EngineAdvanced:AddToggle({
    Name = "Fullbright",
    Description = "Maximum brightness everywhere",
    Default = MobStrap.Config.Fullbright,
    Callback = function(call)
        MobStrap.UpdateConfig("Fullbright", call)
        if call then
            MobStrapCore.FFlag:Toggle("FFlagFullbright", true)
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            MobStrapCore.FFlag:Toggle("FFlagFullbright", false)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
})

EngineAdvanced:AddToggle({
    Name = "Disable Particles",
    Description = "Remove all particle effects",
    Default = MobStrap.Config.DisableParticles,
    Callback = function(call)
        MobStrap.UpdateConfig("DisableParticles", call)
        MobStrapCore.FFlag:Toggle("FFlagDisableParticles", call)

        if call then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        end
    end
})

EngineAdvanced:AddToggle({
    Name = "Fast Asset Loading",
    Description = "Speed up character and asset loading",
    Default = MobStrap.Config.FastLoad,
    Callback = function(call)
        MobStrap.UpdateConfig("FastLoad", call)
        MobStrapCore.FFlag:Toggle("FFlagFastCharacterLoad", call)
        MobStrapCore.FFlag:Toggle("FFlagFastLoadAssets", call)
        MobStrapCore.FFlag:Toggle("FFlagEnableFastAssetCaching", call)
    end
})

EngineAdvanced:AddToggle({
    Name = "CPU Optimization",
    Description = "Reduce CPU usage",
    Default = MobStrap.Config.CPUOptimization,
    Callback = function(call)
        MobStrap.UpdateConfig("CPUOptimization", call)
        MobStrapCore.FFlag:Toggle("DFIntPhysicsStepsPerFrame", call and 1 or 4)
        MobStrapCore.FFlag:Toggle("DFIntGCJobFrequencyMs", call and 250 or 100)
        MobStrapCore.FFlag:Toggle("FFlagLuaAppEnableLowMemoryMode", call)
    end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: FAST FLAGS
-- ═══════════════════════════════════════════════════════════════════════════════

local FFlagTab = GUI:MakeTab({"Fast Flags", "🏴"})

local FFlagEditor = FFlagTab:AddSection("FFlag Editor")

FFlagEditor:AddTextBox({
    Name = "Custom FFlags (JSON)",
    Description = "Paste JSON with FFlags. Use with caution!",
    Default = "",
    Callback = function(jsonStr)
        local success, fflags = pcall(function()
            return HttpService:JSONDecode(jsonStr:gsub('"True"', "true"):gsub('"False"', "false"))
        end)

        if success and typeof(fflags) == "table" then
            for name, value in pairs(fflags) do
                MobStrapCore.FFlag:Toggle(name, value)
            end
            MobStrap.success("Custom FFlags applied!")
        else
            MobStrap.error("Invalid JSON format!")
        end
    end
})

local FFlagPresets = FFlagTab:AddSection("Presets: Safe")

FFlagPresets:AddToggle({
    Name = "Gray Sky",
    Description = "Turns the sky gray (requires rejoin)",
    Default = MobStrap.Config.GraySky,
    Callback = function(call)
        MobStrap.UpdateConfig("GraySky", call)
        MobStrapCore.FFlag:Toggle("FFlagDebugSkyGray", call)
    end
})

FFlagPresets:AddToggle({
    Name = "Low Latency Mode",
    Description = "Reduce input latency",
    Default = MobStrap.Config.LowLatency,
    Callback = function(call)
        MobStrap.UpdateConfig("LowLatency", call)
        if call then
            MobStrapCore.Network:ApplyLowLatency()
        else
            MobStrapCore.FFlag:Toggle("FFlagEnableReducedLatency", false)
            MobStrapCore.FFlag:Toggle("FFlagFastGPULightCulling3", false)
        end
    end
})

local FFlagBannable = FFlagTab:AddSection("Presets: Use at Own Risk")

FFlagBannable:AddToggle({
    Name = "Desync",
    Description = "Lags your character on other screens",
    Default = MobStrap.Config.Desync,
    Callback = function(call)
        MobStrap.UpdateConfig("Desync", call)
        if call then
            MobStrapCore.Network:ApplyDesync()
        else
            MobStrapCore.Network:RemoveDesync()
        end
    end
})

FFlagBannable:AddToggle({
    Name = "Hitreg Fix",
    Description = "Better hit registration in most games",
    Default = MobStrap.Config.HitregFix,
    Callback = function(call)
        MobStrap.UpdateConfig("HitregFix", call)
        if call then
            MobStrapCore.Network:ApplyHitregFix()
        else
            -- Reset hitreg flags to defaults
            MobStrapCore.FFlag:Toggle("DFIntCodecMaxIncomingPackets", 60)
            MobStrapCore.FFlag:Toggle("DFIntPlayerNetworkUpdateRate", 30)
        end
    end
})

FFlagBannable:AddToggle({
    Name = "No Animations (Server)",
    Description = "Stops animation replication to server",
    Default = MobStrap.Config.NoAnimations,
    Callback = function(call)
        MobStrap.UpdateConfig("NoAnimations", call)
        MobStrapCore.FFlag:Toggle("DFIntReplicatorAnimationTrackLimitPerAnimator", call and -1 or 10)
    end
})

FFlagBannable:AddToggle({
    Name = "Walk Speed Boost",
    Description = "Slightly faster movement (some games)",
    Default = MobStrap.Config.WalkSpeedBoost,
    Callback = function(call)
        MobStrap.UpdateConfig("WalkSpeedBoost", call)
        MobStrapCore.Physics:SetWalkSpeedMultiplier(call and 10 or 1)
    end
})

FFlagBannable:AddToggle({
    Name = "Network Ownership",
    Description = "Better physics control (risky in some games)",
    Default = MobStrap.Config.NetworkOwnership,
    Callback = function(call)
        MobStrap.UpdateConfig("NetworkOwnership", call)
        MobStrapCore.Physics:SetNetworkOwnership(call and 2147000000 or 150)
    end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: APPEARANCE
-- ═══════════════════════════════════════════════════════════════════════════════

local AppearanceTab = GUI:MakeTab({"Appearance", "🎨"})

local AppPlayer = AppearanceTab:AddSection("Player")

AppPlayer:AddToggle({
    Name = "De-Rendering",
    Description = "Stop rendering distant player animations",
    Default = MobStrap.Config.DeRendering,
    Callback = function(call)
        MobStrap.UpdateConfig("DeRendering", call)
        if call then
            MobStrapCore.DeRender:Enable()
        else
            MobStrapCore.DeRender:Disable()
        end
    end
})

AppPlayer:AddSlider({
    Name = "Camera Sensitivity",
    Min = 0.1,
    Max = 5,
    Increase = 0.1,
    Default = MobStrap.Config.CameraSensitivity,
    Callback = function(val)
        MobStrap.UpdateConfig("CameraSensitivity", val)
        MobStrapCore.Camera:SetSensitivity(val)
    end
})

AppPlayer:AddToggle({
    Name = "GUI Scaler",
    Description = "Decrease Roblox GUI scales",
    Default = MobStrap.Config.GUIScale,
    Callback = function(call)
        MobStrap.UpdateConfig("GUIScale", call)
        if call then
            MobStrapCore.GUIScaler:Enable(0.7)
        else
            MobStrapCore.GUIScaler:Disable()
        end
    end
})

AppPlayer:AddToggle({
    Name = "Touch GUI Size",
    Description = "Increase touch controls size (mobile)",
    Default = MobStrap.Config.TouchUI,
    Callback = function(call)
        MobStrap.UpdateConfig("TouchUI", call)
        if call then
            MobStrapCore.TouchUI:Enable(MobStrap.Config.TouchUiSize)
        else
            MobStrapCore.TouchUI:Disable()
        end
    end
})

AppPlayer:AddSlider({
    Name = "Touch Scale",
    Min = 1,
    Max = 2,
    Increase = 0.1,
    Default = MobStrap.Config.TouchUiSize,
    Callback = function(val)
        MobStrap.UpdateConfig("TouchUiSize", val)
        MobStrapCore.TouchUI:SetScale(val)
    end
})

local AppCrosshair = AppearanceTab:AddSection("Crosshair")

AppCrosshair:AddToggle({
    Name = "Enable Crosshair",
    Default = MobStrap.Config.Crosshair,
    Callback = function(call)
        MobStrap.UpdateConfig("Crosshair", call)
        if call then
            local img = MobStrap.Config.CrosshairImage
            if img ~= "" and getcustomasset and isfile and isfile(img) then
                MobStrapCore.Crosshair:Enable(getcustomasset(img))
            else
                MobStrapCore.Crosshair:Enable("")
            end
        else
            MobStrapCore.Crosshair:Disable()
        end
    end
})

AppCrosshair:AddDropdown({
    Name = "Crosshair Image",
    Options = (listfiles and listfiles("MobStrap/Images")) or {"None"},
    Default = MobStrap.Config.CrosshairImage,
    Callback = function(val)
        MobStrap.UpdateConfig("CrosshairImage", val)
        if MobStrap.Config.Crosshair and getcustomasset then
            MobStrapCore.Crosshair:SetImage(getcustomasset(val))
        end
    end
})

local AppTopbar = AppearanceTab:AddSection("Topbar")

AppTopbar:AddToggle({
    Name = "MobStrap Topbar",
    Description = "Custom gradient topbar styling",
    Default = MobStrap.Config.customtopbar,
    Callback = function(call)
        MobStrap.UpdateConfig("customtopbar", call)
        if call then
            MobStrapCore.Topbar:Enable()
        else
            MobStrapCore.Topbar:Disable()
        end
    end
})

AppTopbar:AddToggle({
    Name = "Spin Hotbar",
    Description = "Spin the Roblox logo (why not?)",
    Default = MobStrap.Config.RotatingHotbar,
    Callback = function(call)
        MobStrap.UpdateConfig("RotatingHotbar", call)
        if call then
            MobStrapCore.RotatingHotbar:Enable()
        else
            MobStrapCore.RotatingHotbar:Disable()
        end
    end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: FONTS
-- ═══════════════════════════════════════════════════════════════════════════════

local FontTab = GUI:MakeTab({"Fonts", "🔤"})

local FontSection = FontTab:AddSection("Font Changer")

local fontList = {}
for _, font in ipairs(Enum.Font:GetEnumItems()) do
    table.insert(fontList, tostring(font):split(".")[3])
end

local fontToggle
fontToggle = FontSection:AddToggle({
    Name = "Change Game Fonts",
    Description = "Override all text fonts in the game",
    Default = MobStrap.Config.customfonttoggle,
    Callback = function(call)
        MobStrap.UpdateConfig("customfonttoggle", call)
        if call then
            MobStrapCore.Font:Enable(MobStrap.Config.customfontroblox ~= "" and MobStrap.Config.customfontroblox or "Gotham")
        else
            MobStrapCore.Font:Disable()
        end
    end
})

FontSection:AddDropdown({
    Name = "Preset Fonts",
    Options = fontList,
    Default = MobStrap.Config.customfontroblox,
    Callback = function(val)
        MobStrap.UpdateConfig("customfontroblox", val)
        if MobStrap.Config.customfonttoggle then
            MobStrapCore.Font:Enable(val)
        end
    end
})

local customFontList = {"none"}
if listfiles then
    for _, file in ipairs(listfiles("MobStrap/Main/Fonts")) do
        if file:find("%.ttf$") then
            table.insert(customFontList, file)
        end
    end
end

FontSection:AddDropdown({
    Name = "Custom Fonts",
    Options = customFontList,
    Default = MobStrap.Config.CustomFont,
    Callback = function(val)
        if val == "none" then
            MobStrap.UpdateConfig("CustomFont", "")
            return
        end
        MobStrap.UpdateConfig("CustomFont", val)
        if getcustomasset then
            MobStrapCore.Font:SetCustomFont(val)
            if MobStrap.Config.customfonttoggle then
                fontToggle:Set(true)
            end
        end
    end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: SOUND
-- ═══════════════════════════════════════════════════════════════════════════════

local SoundTab = GUI:MakeTab({"Sound", "🔊"})

local SoundSection = SoundTab:AddSection("Death Sound")

SoundSection:AddToggle({
    Name = "Custom Death Sound",
    Description = "Replace death sound with custom/oof",
    Default = MobStrap.Config.OofSound,
    Callback = function(call)
        MobStrap.UpdateConfig("OofSound", call)
        if call then
            local soundPath = "MobStrap/deathsound.mp3"
            if not (isfile and isfile(soundPath)) then
                soundPath = "MobStrap/oofsound.mp3"
            end
            MobStrapCore.DeathSound:Enable(soundPath)
        else
            MobStrapCore.DeathSound:Disable()
        end
    end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════════

local UtilsTab = GUI:MakeTab({"Utilities", "🛠️"})

local UtilsGame = UtilsTab:AddSection("Game")

UtilsGame:AddToggle({
    Name = "Anti-AFK",
    Description = "Prevents getting kicked for inactivity",
    Default = MobStrap.Config.AntiAfk,
    Callback = function(call)
        MobStrap.UpdateConfig("AntiAfk", call)
        if call then
            local afkConnection
            afkConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local virtualUser = game:GetService("VirtualUser")
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
            end)
            -- Store for cleanup
            getgenv().MobStrapAntiAfk = afkConnection
        else
            if getgenv().MobStrapAntiAfk then
                pcall(function() getgenv().MobStrapAntiAfk:Disconnect() end)
                getgenv().MobStrapAntiAfk = nil
            end
        end
    end
})

UtilsGame:AddButton({
    Name = "Rejoin Server",
    Description = "Rejoin the current server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, lplr)
    end
})

UtilsGame:AddButton({
    Name = "Copy JobId",
    Description = "Copy server JobId to clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            MobStrap.success("JobId copied!")
        end
    end
})

local UtilsInfo = UtilsTab:AddSection("Information")

UtilsInfo:AddButton({
    Name = "Server Info",
    Description = "Show server details",
    Callback = function()
        local info = string.format(
            "Place ID: %s\nJob ID: %s\nPlayers: %d/%d\nFPS Cap: %s",
            tostring(game.PlaceId),
            game.JobId,
            #Players:GetPlayers(),
            Players.MaxPlayers,
            tostring(MobStrap.Config.FPS)
        )
        MobStrap.info(info)
    end
})

UtilsInfo:AddButton({
    Name = "Save Configuration",
    Description = "Save current settings to file",
    Callback = function()
        MobStrap.SaveConfig()
        MobStrap.success("Configuration saved!")
    end
})

UtilsInfo:AddButton({
    Name = "Reset All Settings",
    Description = "Reset to default configuration",
    Callback = function()
        -- Reset all toggles
        MobStrapCore.FFlag:ResetAll()
        MobStrapCore.DeRender:Disable()
        MobStrapCore.GUIScaler:Disable()
        MobStrapCore.Crosshair:Disable()
        MobStrapCore.Topbar:Disable()
        MobStrapCore.RotatingHotbar:Disable()
        MobStrapCore.FPSDisplay:Disable()
        MobStrapCore.Font:Disable()
        MobStrapCore.DeathSound:Disable()
        MobStrapCore.Camera:Reset()
        MobStrapCore.TouchUI:Disable()

        -- Reset config
        MobStrap.Config = {}
        conf = MobStrap.Config

        MobStrap.success("All settings reset!")
    end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB: ABOUT
-- ═══════════════════════════════════════════════════════════════════════════════

local AboutTab = GUI:MakeTab({"About", "ℹ️"})

local AboutInfo = AboutTab:AddSection("MobStrap")

AboutInfo:AddButton({
    Name = "Version: " .. MobStrap.Version,
    Description = "Professional Roblox Optimizer",
    Callback = function() end
})

AboutInfo:AddButton({
    Name = "Made with ❤️ by You",
    Description = "Based on open-source Bloxstrap",
    Callback = function() end
})

AboutInfo:AddButton({
    Name = "FFlag Patch Bypass: ACTIVE",
    Description = "Multiple bypass methods enabled",
    Callback = function() end
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- FINAL SETUP
-- ═══════════════════════════════════════════════════════════════════════════════

MobStrap.canUpdate = true

-- Apply saved config on startup
pcall(function()
    if MobStrap.Config.FPS and MobStrap.Config.FPS > 0 then
        MobStrapCore.Engine:SetFPS(MobStrap.Config.FPS)
    end

    if MobStrap.Config.DisplayFPS then
        MobStrapCore.FPSDisplay:Enable()
    end

    if MobStrap.Config.DeRendering then
        MobStrapCore.DeRender:Enable()
    end

    if MobStrap.Config.customfonttoggle and MobStrap.Config.customfontroblox ~= "" then
        MobStrapCore.Font:Enable(MobStrap.Config.customfontroblox)
    end

    if MobStrap.Config.Crosshair then
        local img = MobStrap.Config.CrosshairImage
        if img ~= "" and getcustomasset and isfile and isfile(img) then
            MobStrapCore.Crosshair:Enable(getcustomasset(img))
        else
            MobStrapCore.Crosshair:Enable("")
        end
    end

    if MobStrap.Config.customtopbar then
        MobStrapCore.Topbar:Enable()
    end

    if MobStrap.Config.RotatingHotbar then
        MobStrapCore.RotatingHotbar:Enable()
    end

    if MobStrap.Config.OofSound then
        local soundPath = "MobStrap/deathsound.mp3"
        if not (isfile and isfile(soundPath)) then
            soundPath = "MobStrap/oofsound.mp3"
        end
        MobStrapCore.DeathSound:Enable(soundPath)
    end

    if MobStrap.Config.CameraSensitivity and MobStrap.Config.CameraSensitivity ~= 1 then
        MobStrapCore.Camera:SetSensitivity(MobStrap.Config.CameraSensitivity)
    end

    if MobStrap.Config.GUIScale then
        MobStrapCore.GUIScaler:Enable(0.7)
    end

    if MobStrap.Config.TouchUI then
        MobStrapCore.TouchUI:Enable(MobStrap.Config.TouchUiSize)
    end

    if MobStrap.Config.HitregFix then
        MobStrapCore.Network:ApplyHitregFix()
    end

    if MobStrap.Config.LowLatency then
        MobStrapCore.Network:ApplyLowLatency()
    end

    if MobStrap.Config.Desync then
        MobStrapCore.Network:ApplyDesync()
    end

    if MobStrap.Config.GraySky then
        MobStrapCore.FFlag:Toggle("FFlagDebugSkyGray", true)
    end

    if MobStrap.Config.DisablePostFX then
        MobStrapCore.Engine:SetPostFX(false)
    end

    if MobStrap.Config.DisablePlayerShadows then
        MobStrapCore.Engine:SetShadows(false)
    end

    if MobStrap.Config.DisableTerrainTextures then
        MobStrapCore.Engine:SetTerrainTextures(false)
    end

    if MobStrap.Config.AntiAfk then
        local afkConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
        getgenv().MobStrapAntiAfk = afkConnection
    end
end)

-- Welcome notification
MobStrap.success("MobStrap v" .. MobStrap.Version .. " loaded successfully!")
MobStrap.info("Press RightShift to toggle UI")

-- Return MobStrap global
return MobStrap

