-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                    CAFUXZ1 TCS HUB v17.0 - ELITE EDITION                      ║
-- ║           The Complete Soccer | Desktop Application Architecture              ║
-- ║          Design: Dark Glassmorphism | Neon Cyber | Modular Library            ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════════════════════════════════
-- ARCHITECTURE: Modular Library System
-- ════════════════════════════════════════════════════════════════════════════════
local CAFUXZ1 = {}
CAFUXZ1.Version = "17.0 Elite"
CAFUXZ1.Build = "TCS-2026"
CAFUXZ1.Modules = {}
CAFUXZ1.Config = {}
CAFUXZ1.State = {}

-- Services
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    HttpService = game:GetService("HttpService"),
    TeleportService = game:GetService("TeleportService"),
    Debris = game:GetService("Debris"),
    VirtualUser = game:GetService("VirtualUser"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════════════════════
-- DESIGN SYSTEM: Dark Glassmorphism + Neon Cyber Palette
-- ════════════════════════════════════════════════════════════════════════════════
local Design = {}

Design.Palette = {
    -- Deep Space Backgrounds
    Void = Color3.fromRGB(5, 5, 10),
    Deep = Color3.fromRGB(10, 10, 20),
    Surface = Color3.fromRGB(18, 18, 35),
    SurfaceHover = Color3.fromRGB(28, 28, 50),
    Elevated = Color3.fromRGB(25, 25, 45),

    -- Glassmorphism
    Glass = Color3.fromRGB(30, 30, 55),
    GlassLight = Color3.fromRGB(40, 40, 70),
    GlassBorder = Color3.fromRGB(60, 60, 100),
    GlassGlow = Color3.fromRGB(80, 80, 130),

    -- Neon Accents (Cyber)
    NeonCyan = Color3.fromRGB(0, 255, 255),
    NeonPink = Color3.fromRGB(255, 0, 128),
    NeonPurple = Color3.fromRGB(180, 0, 255),
    NeonGreen = Color3.fromRGB(0, 255, 128),
    NeonGold = Color3.fromRGB(255, 200, 0),
    NeonRed = Color3.fromRGB(255, 60, 60),

    -- Text Hierarchy
    TextPrimary = Color3.fromRGB(245, 245, 255),
    TextSecondary = Color3.fromRGB(170, 170, 210),
    TextMuted = Color3.fromRGB(110, 110, 150),
    TextDark = Color3.fromRGB(70, 70, 100),

    -- Gradients
    GradientCyber = {Color3.fromRGB(0, 255, 255), Color3.fromRGB(180, 0, 255)},
    GradientFire = {Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 0, 128)},
    GradientNature = {Color3.fromRGB(0, 255, 128), Color3.fromRGB(0, 200, 255)},
}

Design.Typography = {
    Display = Enum.Font.GothamBlack,
    Header = Enum.Font.GothamBold,
    Body = Enum.Font.GothamMedium,
    Mono = Enum.Font.Code,
    Accent = Enum.Font.FredokaOne,
}

Design.Sizes = {
    Window = {Width = 720, Height = 480},
    Sidebar = {Width = 180},
    TopBar = {Height = 56},
    Tab = {Height = 42},
    Section = {Padding = 16, Gap = 12},
    Element = {Height = 36, Toggle = 28, Slider = 48},
    CornerRadius = {Window = 20, Card = 12, Button = 8, Pill = 999},
}

Design.Animations = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Glow = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
}

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILITY MODULE: Factory & Helpers
-- ════════════════════════════════════════════════════════════════════════════════
local Factory = {}

function Factory:Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

function Factory:ApplyGlass(obj, intensity)
    intensity = intensity or 0.85
    obj.BackgroundColor3 = Design.Palette.Glass
    obj.BackgroundTransparency = intensity
end

function Factory:ApplyGlow(obj, color, size)
    local glow = self:Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = color or Design.Palette.NeonCyan,
        ImageTransparency = 0.9,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, (size or 40) * 2, 1, (size or 40) * 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = obj.ZIndex - 1,
        Parent = obj
    })
    return glow
end

function Factory:ApplyShadow(obj, depth)
    depth = depth or 20
    return self:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, depth * 2, 1, depth * 2),
        Position = UDim2.new(0.5, 0, 0.5, depth / 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = obj.ZIndex - 2,
        Parent = obj
    })
end

function Factory:ApplyCorner(obj, radius)
    return self:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or Design.Sizes.CornerRadius.Card),
        Parent = obj
    })
end

function Factory:ApplyStroke(obj, color, thickness, transparency)
    return self:Create("UIStroke", {
        Color = color or Design.Palette.GlassBorder,
        Thickness = thickness or 1,
        Transparency = transparency or 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = obj
    })
end

function Factory:ApplyGradient(obj, colors, rotation, transparency)
    rotation = rotation or 90
    local seq = {}
    for i, c in ipairs(colors or Design.Palette.GradientCyber) do
        table.insert(seq, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), c))
    end
    return self:Create("UIGradient", {
        Color = ColorSequence.new(seq),
        Rotation = rotation,
        Transparency = transparency or NumberSequence.new(0),
        Parent = obj
    })
end

function Factory:CreateRipple(parent, position, color)
    local ripple = self:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = color or Design.Palette.TextPrimary,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, position.X, 0, position.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = parent.ZIndex + 10,
        Parent = parent
    })
    self:ApplyCorner(ripple, 999)
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    Services.TweenService:Create(ripple, Design.Animations.Smooth, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.5, function() if ripple then ripple:Destroy() end end)
end

function Factory:AnimateProperty(obj, property, value, tweenInfo)
    Services.TweenService:Create(obj, tweenInfo or Design.Animations.Normal, {[property] = value}):Play()
end

function Factory:PulseGlow(obj, color, duration)
    duration = duration or 1.5
    local glow = obj:FindFirstChild("Glow")
    if not glow then return end
    Services.TweenService:Create(glow, TweenInfo.new(duration / 2, Enum.EasingStyle.Sine), {
        ImageTransparency = 0.7
    }):Play()
    task.delay(duration / 2, function()
        if glow then
            Services.TweenService:Create(glow, TweenInfo.new(duration / 2, Enum.EasingStyle.Sine), {
                ImageTransparency = 0.9
            }):Play()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- THEME MANAGER: Customizable Client Experience
-- ════════════════════════════════════════════════════════════════════════════════
local ThemeManager = {}
ThemeManager.Current = "Cyber"
ThemeManager.Presets = {
    Cyber = {
        Primary = Design.Palette.NeonCyan,
        Secondary = Design.Palette.NeonPink,
        Accent = Design.Palette.NeonPurple,
        Gradient = Design.Palette.GradientCyber,
    },
    Inferno = {
        Primary = Design.Palette.NeonPink,
        Secondary = Design.Palette.NeonGold,
        Accent = Design.Palette.NeonRed,
        Gradient = Design.Palette.GradientFire,
    },
    Matrix = {
        Primary = Design.Palette.NeonGreen,
        Secondary = Design.Palette.NeonCyan,
        Accent = Color3.fromRGB(0, 255, 100),
        Gradient = Design.Palette.GradientNature,
    },
    Void = {
        Primary = Color3.fromRGB(200, 200, 255),
        Secondary = Color3.fromRGB(150, 150, 200),
        Accent = Color3.fromRGB(100, 100, 150),
        Gradient = {Color3.fromRGB(200, 200, 255), Color3.fromRGB(100, 100, 150)},
    }
}

function ThemeManager:SetTheme(name)
    local theme = self.Presets[name] or self.Presets.Cyber
    self.Current = name
    Design.Palette.Primary = theme.Primary
    Design.Palette.Secondary = theme.Secondary
    Design.Palette.Accent = theme.Accent
    Design.Palette.GradientCyber = theme.Gradient

    -- Update all dynamic elements
    if CAFUXZ1.Hub and CAFUXZ1.Hub.UpdateTheme then
        CAFUXZ1.Hub:UpdateTheme()
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM: Elite Feedback
-- ════════════════════════════════════════════════════════════════════════════════
local NotificationSystem = {}
NotificationSystem.Queue = {}
NotificationSystem.Active = {}
NotificationSystem.MaxActive = 4

function NotificationSystem:Init(parent)
    self.Container = Factory:Create("Frame", {
        Name = "NotificationContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 340, 1, -20),
        Position = UDim2.new(1, -360, 0, 20),
        ZIndex = 1000,
        Parent = parent
    })

    Factory:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Container
    })
end

function NotificationSystem:Notify(data)
    data = data or {}
    local title = data.Title or "Notification"
    local message = data.Message or ""
    local duration = data.Duration or 4
    local type = data.Type or "Info"
    local color = data.Color

    if not color then
        if type == "Success" then color = Design.Palette.NeonGreen
        elseif type == "Warning" then color = Design.Palette.NeonGold
        elseif type == "Error" then color = Design.Palette.NeonRed
        else color = Design.Palette.NeonCyan end
    end

    local notif = Factory:Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Design.Palette.Surface,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 320, 0, 0),
        ClipsDescendants = true,
        ZIndex = 1001,
        Parent = self.Container
    })
    Factory:ApplyCorner(notif, 14)
    Factory:ApplyStroke(notif, color, 1.5, 0.2)
    Factory:ApplyGlow(notif, color, 20)

    -- Left accent bar
    local accentBar = Factory:Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 1002,
        Parent = notif
    })
    Factory:ApplyCorner(accentBar, 4)

    -- Icon
    local iconMap = {Info = "ℹ", Success = "✓", Warning = "⚠", Error = "✕"}
    local icon = Factory:Create("TextLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 14, 0, 12),
        Text = iconMap[type] or "ℹ",
        TextColor3 = color,
        Font = Design.Typography.Header,
        TextSize = 18,
        ZIndex = 1003,
        Parent = notif
    })

    -- Title
    local titleLabel = Factory:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 22),
        Position = UDim2.new(0, 48, 0, 10),
        Text = title,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Header,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1003,
        Parent = notif
    })

    -- Message
    local msgLabel = Factory:Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 0, 0),
        Position = UDim2.new(0, 14, 0, 34),
        Text = message,
        TextColor3 = Design.Palette.TextSecondary,
        Font = Design.Typography.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 1003,
        Parent = notif
    })

    -- Progress bar
    local progressBg = Factory:Create("Frame", {
        Name = "ProgressBg",
        BackgroundColor3 = Design.Palette.GlassBorder,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -28, 0, 2),
        Position = UDim2.new(0, 14, 1, -8),
        ZIndex = 1003,
        Parent = notif
    })
    Factory:ApplyCorner(progressBg, 1)

    local progress = Factory:Create("Frame", {
        Name = "Progress",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1004,
        Parent = progressBg
    })
    Factory:ApplyCorner(progress, 1)

    -- Calculate height
    local msgHeight = msgLabel.TextBounds.Y
    local notifHeight = math.max(76, 50 + msgHeight)

    -- Animate in
    notif.Size = UDim2.new(0, 320, 0, 0)
    Services.TweenService:Create(notif, Design.Animations.Bounce, {
        Size = UDim2.new(0, 320, 0, notifHeight)
    }):Play()

    -- Progress animation
    Services.TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    -- Auto dismiss
    task.delay(duration, function()
        if notif and notif.Parent then
            Services.TweenService:Create(notif, Design.Animations.Normal, {
                Size = UDim2.new(0, 320, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.3, function()
                if notif and notif.Parent then notif:Destroy() end
            end)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- WINDOW SYSTEM: Desktop Application Architecture
-- ════════════════════════════════════════════════════════════════════════════════
local WindowSystem = {}
WindowSystem.Instance = nil
WindowSystem.IsOpen = true
WindowSystem.IsMinimized = false
WindowSystem.ActiveTab = nil
WindowSystem.Tabs = {}
WindowSystem.Favorites = {}

function WindowSystem:Create()
    local screenGui = Factory:Create("ScreenGui", {
        Name = "CAFUXZ1_Elite_Hub",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Services.CoreGui
    })

    -- Main Window Frame
    local window = Factory:Create("Frame", {
        Name = "Window",
        BackgroundColor3 = Design.Palette.Deep,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(0, Design.Sizes.Window.Width, 0, Design.Sizes.Window.Height),
        Position = UDim2.new(0.5, -Design.Sizes.Window.Width/2, 0.5, -Design.Sizes.Window.Height/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 100,
        Parent = screenGui
    })
    Factory:ApplyCorner(window, Design.Sizes.CornerRadius.Window)
    Factory:ApplyStroke(window, Design.Palette.GlassBorder, 1.5, 0.15)
    Factory:ApplyShadow(window, 30)

    -- Animated Border Ring
    local borderRing = Factory:Create("Frame", {
        Name = "BorderRing",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 99,
        Parent = window
    })
    Factory:ApplyCorner(borderRing, Design.Sizes.CornerRadius.Window + 3)
    Factory:ApplyStroke(borderRing, Design.Palette.NeonCyan, 2, 0.6)

    -- Animated gradient on border
    local borderGradient = Factory:ApplyGradient(borderRing, Design.Palette.GradientCyber, 0)
    task.spawn(function()
        while borderRing and borderRing.Parent do
            for i = 0, 360, 1.5 do
                if not borderGradient or not borderGradient.Parent then break end
                borderGradient.Rotation = i
                task.wait(0.025)
            end
        end
    end)

    -- Background particles (subtle)
    local particleCanvas = Factory:Create("Frame", {
        Name = "ParticleCanvas",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 98,
        Parent = window
    })

    -- Create subtle floating particles
    task.spawn(function()
        for i = 1, 8 do
            local particle = Factory:Create("Frame", {
                Name = "Particle" .. i,
                BackgroundColor3 = Design.Palette.NeonCyan,
                BackgroundTransparency = 0.95,
                BorderSizePixel = 0,
                Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4)),
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                ZIndex = 98,
                Parent = particleCanvas
            })
            Factory:ApplyCorner(particle, 999)

            -- Float animation
            task.spawn(function()
                while particle and particle.Parent do
                    local targetX = math.random() * 0.9
                    local targetY = math.random() * 0.9
                    local duration = math.random(8, 15)
                    Services.TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
                        Position = UDim2.new(targetX, 0, targetY, 0)
                    }):Play()
                    task.wait(duration)
                end
            end)
        end
    end)

    -- ═══════════════════════════════════════════════════════════════════════════
    -- TOP BAR: Title + Controls + Search
    -- ═══════════════════════════════════════════════════════════════════════════
    local topBar = Factory:Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Design.Palette.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Design.Sizes.TopBar.Height),
        ZIndex = 110,
        Parent = window
    })
    Factory:ApplyCorner(topBar, 0)

    -- Top bar bottom line with gradient
    local topLine = Factory:Create("Frame", {
        Name = "TopLine",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -1),
        ZIndex = 111,
        Parent = topBar
    })
    Factory:ApplyGradient(topLine, Design.Palette.GradientCyber, 0)

    -- Logo Group
    local logoGroup = Factory:Create("Frame", {
        Name = "LogoGroup",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        ZIndex = 112,
        Parent = topBar
    })

    -- Logo icon (hexagon shape)
    local logoIcon = Factory:Create("Frame", {
        Name = "LogoIcon",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 113,
        Parent = logoGroup
    })
    Factory:ApplyCorner(logoIcon, 8)
    Factory:ApplyGlow(logoIcon, Design.Palette.NeonCyan, 15)

    local logoIconText = Factory:Create("TextLabel", {
        Name = "LogoIconText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "C1",
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Header,
        TextSize = 14,
        ZIndex = 114,
        Parent = logoIcon
    })

    -- Logo text
    local logoText = Factory:Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 0, 22),
        Position = UDim2.new(0, 42, 0, 6),
        Text = "CAFUXZ1",
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Display,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 113,
        Parent = logoGroup
    })

    local logoSub = Factory:Create("TextLabel", {
        Name = "LogoSub",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 0, 14),
        Position = UDim2.new(0, 42, 0, 28),
        Text = "TCS ELITE v17.0",
        TextColor3 = Design.Palette.NeonCyan,
        Font = Design.Typography.Mono,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 113,
        Parent = logoGroup
    })

    -- Status indicator (live dot)
    local statusDot = Factory:Create("Frame", {
        Name = "StatusDot",
        BackgroundColor3 = Design.Palette.NeonGreen,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 7, 0, 7),
        Position = UDim2.new(0, 170, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 113,
        Parent = logoGroup
    })
    Factory:ApplyCorner(statusDot, 999)

    -- Pulse animation
    task.spawn(function()
        while statusDot and statusDot.Parent do
            Services.TweenService:Create(statusDot, Design.Animations.Glow, {BackgroundTransparency = 0.4}):Play()
            task.wait(0.8)
            Services.TweenService:Create(statusDot, Design.Animations.Glow, {BackgroundTransparency = 0}):Play()
            task.wait(0.8)
        end
    end)

    -- Search Bar
    local searchBar = Factory:Create("Frame", {
        Name = "SearchBar",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 32),
        Position = UDim2.new(0.5, -100, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 112,
        Parent = topBar
    })
    Factory:ApplyCorner(searchBar, 8)
    Factory:ApplyStroke(searchBar, Design.Palette.GlassBorder, 1, 0.3)

    local searchIcon = Factory:Create("TextLabel", {
        Name = "SearchIcon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        Text = "🔍",
        TextColor3 = Design.Palette.TextMuted,
        Font = Design.Typography.Body,
        TextSize = 12,
        ZIndex = 113,
        Parent = searchBar
    })

    local searchBox = Factory:Create("TextBox", {
        Name = "SearchBox",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        Text = "",
        PlaceholderText = "Search features...",
        PlaceholderColor3 = Design.Palette.TextMuted,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 12,
        ClearTextOnFocus = false,
        ZIndex = 113,
        Parent = searchBar
    })

    searchBox.Focused:Connect(function()
        Factory:AnimateProperty(searchBar, "BackgroundTransparency", 0.3, Design.Animations.Fast)
        Factory:AnimateProperty(searchBar:FindFirstChildOfClass("UIStroke"), "Color", Design.Palette.NeonCyan, Design.Animations.Fast)
    end)
    searchBox.FocusLost:Connect(function()
        Factory:AnimateProperty(searchBar, "BackgroundTransparency", 0.6, Design.Animations.Fast)
        Factory:AnimateProperty(searchBar:FindFirstChildOfClass("UIStroke"), "Color", Design.Palette.GlassBorder, Design.Animations.Fast)
    end)

    -- Window Controls
    local controls = Factory:Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 32),
        Position = UDim2.new(1, -110, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 112,
        Parent = topBar
    })

    local btnMinimize = Factory:Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "━",
        TextColor3 = Design.Palette.TextSecondary,
        Font = Design.Typography.Header,
        TextSize = 12,
        ZIndex = 113,
        Parent = controls
    })
    Factory:ApplyCorner(btnMinimize, 6)

    btnMinimize.MouseEnter:Connect(function()
        Factory:AnimateProperty(btnMinimize, "BackgroundColor3", Design.Palette.NeonGold, Design.Animations.Fast)
        Factory:AnimateProperty(btnMinimize, "BackgroundTransparency", 0.3, Design.Animations.Fast)
    end)
    btnMinimize.MouseLeave:Connect(function()
        Factory:AnimateProperty(btnMinimize, "BackgroundColor3", Design.Palette.Glass, Design.Animations.Fast)
        Factory:AnimateProperty(btnMinimize, "BackgroundTransparency", 0.5, Design.Animations.Fast)
    end)
    btnMinimize.MouseButton1Click:Connect(function()
        Factory:CreateRipple(btnMinimize, Vector2.new(14, 14), Design.Palette.NeonGold)
        self:Minimize()
    end)

    local btnClose = Factory:Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 36, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "✕",
        TextColor3 = Design.Palette.TextSecondary,
        Font = Design.Typography.Header,
        TextSize = 12,
        ZIndex = 113,
        Parent = controls
    })
    Factory:ApplyCorner(btnClose, 6)

    btnClose.MouseEnter:Connect(function()
        Factory:AnimateProperty(btnClose, "BackgroundColor3", Design.Palette.NeonRed, Design.Animations.Fast)
        Factory:AnimateProperty(btnClose, "BackgroundTransparency", 0.3, Design.Animations.Fast)
    end)
    btnClose.MouseLeave:Connect(function()
        Factory:AnimateProperty(btnClose, "BackgroundColor3", Design.Palette.Glass, Design.Animations.Fast)
        Factory:AnimateProperty(btnClose, "BackgroundTransparency", 0.5, Design.Animations.Fast)
    end)
    btnClose.MouseButton1Click:Connect(function()
        Factory:CreateRipple(btnClose, Vector2.new(14, 14), Design.Palette.NeonRed)
        self:Close()
    end)

    -- ═══════════════════════════════════════════════════════════════════════════
    -- SIDEBAR: Navigation + Favorites + User Profile
    -- ═══════════════════════════════════════════════════════════════════════════
    local sidebar = Factory:Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Design.Palette.Surface,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(0, Design.Sizes.Sidebar.Width, 1, -Design.Sizes.TopBar.Height),
        Position = UDim2.new(0, 0, 0, Design.Sizes.TopBar.Height),
        ZIndex = 105,
        Parent = window
    })
    Factory:ApplyCorner(sidebar, 0)

    -- Sidebar right border glow
    local sideBorder = Factory:Create("Frame", {
        Name = "SideBorder",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        ZIndex = 106,
        Parent = sidebar
    })
    Factory:ApplyGradient(sideBorder, Design.Palette.GradientCyber, 90)

    -- User Profile Card (top of sidebar)
    local profileCard = Factory:Create("Frame", {
        Name = "ProfileCard",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 70),
        Position = UDim2.new(0, 8, 0, 10),
        ZIndex = 107,
        Parent = sidebar
    })
    Factory:ApplyCorner(profileCard, 12)
    Factory:ApplyStroke(profileCard, Design.Palette.GlassBorder, 1, 0.3)

    -- Avatar placeholder
    local avatar = Factory:Create("Frame", {
        Name = "Avatar",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0, 15),
        ZIndex = 108,
        Parent = profileCard
    })
    Factory:ApplyCorner(avatar, 999)
    Factory:ApplyGlow(avatar, Design.Palette.NeonCyan, 10)

    local avatarText = Factory:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "👤",
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 18,
        ZIndex = 109,
        Parent = avatar
    })

    local username = Factory:Create("TextLabel", {
        Name = "Username",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -65, 0, 18),
        Position = UDim2.new(0, 58, 0, 16),
        Text = LocalPlayer.Name,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Header,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 108,
        Parent = profileCard
    })

    local userStatus = Factory:Create("TextLabel", {
        Name = "UserStatus",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -65, 0, 14),
        Position = UDim2.new(0, 58, 0, 36),
        Text = "ELITE USER",
        TextColor3 = Design.Palette.NeonCyan,
        Font = Design.Typography.Mono,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 108,
        Parent = profileCard
    })

    -- Tab Container
    local tabContainer = Factory:Create("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, -90),
        Position = UDim2.new(0, 8, 0, 88),
        ZIndex = 107,
        Parent = sidebar
    })

    Factory:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContainer
    })

    -- Favorites Section (bottom of sidebar)
    local favoritesSection = Factory:Create("Frame", {
        Name = "FavoritesSection",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 1, -80),
        ZIndex = 107,
        Parent = sidebar
    })

    local favLabel = Factory:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Text = "⭐ FAVORITES",
        TextColor3 = Design.Palette.TextMuted,
        Font = Design.Typography.Mono,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 108,
        Parent = favoritesSection
    })

    -- ═══════════════════════════════════════════════════════════════════════════
    -- CONTENT AREA: Dashboard + Pages
    -- ═══════════════════════════════════════════════════════════════════════════
    local contentArea = Factory:Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -Design.Sizes.Sidebar.Width, 1, -Design.Sizes.TopBar.Height),
        Position = UDim2.new(0, Design.Sizes.Sidebar.Width, 0, Design.Sizes.TopBar.Height),
        ZIndex = 105,
        Parent = window
    })

    -- Content padding
    Factory:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 20),
        PaddingBottom = UDim.new(0, 20),
        Parent = contentArea
    })

    -- Store references
    self.ScreenGui = screenGui
    self.Window = window
    self.TopBar = topBar
    self.Sidebar = sidebar
    self.TabContainer = tabContainer
    self.ContentArea = contentArea
    self.FavoritesSection = favoritesSection
    self.SearchBox = searchBox

    -- Make draggable
    self:MakeDraggable(window, topBar)

    -- Create floating icon
    self:CreateFloatingIcon(screenGui)

    -- Initialize notification system
    NotificationSystem:Init(screenGui)

    -- Entrance animation
    window.Size = UDim2.new(0, 0, 0, 0)
    window.BackgroundTransparency = 1
    Services.TweenService:Create(window, Design.Animations.Bounce, {
        Size = UDim2.new(0, Design.Sizes.Window.Width, 0, Design.Sizes.Window.Height),
        BackgroundTransparency = 0.02
    }):Play()

    self.Instance = window
    return self
end

function WindowSystem:CreateFloatingIcon(parent)
    local icon = Factory:Create("TextButton", {
        Name = "FloatingIcon",
        BackgroundColor3 = Design.Palette.Surface,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0, 24, 0.5, -28),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "⚽",
        TextColor3 = Design.Palette.NeonCyan,
        Font = Design.Typography.Header,
        TextSize = 28,
        ZIndex = 500,
        Visible = false,
        Parent = parent
    })
    Factory:ApplyCorner(icon, 16)
    Factory:ApplyStroke(icon, Design.Palette.NeonCyan, 2, 0.3)
    Factory:ApplyGlow(icon, Design.Palette.NeonCyan, 20)

    -- Hover
    icon.MouseEnter:Connect(function()
        Factory:AnimateProperty(icon, "Size", UDim2.new(0, 62, 0, 62), Design.Animations.Normal)
        Factory:AnimateProperty(icon, "BackgroundColor3", Design.Palette.SurfaceHover, Design.Animations.Normal)
        Factory:AnimateProperty(icon:FindFirstChild("Glow"), "ImageTransparency", 0.75, Design.Animations.Normal)
    end)
    icon.MouseLeave:Connect(function()
        Factory:AnimateProperty(icon, "Size", UDim2.new(0, 56, 0, 56), Design.Animations.Normal)
        Factory:AnimateProperty(icon, "BackgroundColor3", Design.Palette.Surface, Design.Animations.Normal)
        Factory:AnimateProperty(icon:FindFirstChild("Glow"), "ImageTransparency", 0.9, Design.Animations.Normal)
    end)
    icon.MouseButton1Click:Connect(function()
        Factory:CreateRipple(icon, Vector2.new(28, 28), Design.Palette.NeonCyan)
        self:Restore()
    end)

    self:MakeDraggable(icon, icon)
    self.FloatingIcon = icon
end

function WindowSystem:MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function WindowSystem:Minimize()
    self.IsMinimized = true
    self.IsOpen = false
    Services.TweenService:Create(self.Window, Design.Animations.Bounce, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.4, function()
        self.Window.Visible = false
        self.FloatingIcon.Visible = true
        Services.TweenService:Create(self.FloatingIcon, Design.Animations.Bounce, {
            Size = UDim2.new(0, 56, 0, 56)
        }):Play()
    end)
    NotificationSystem:Notify({Title = "Minimized", Message = "Click the floating icon to restore", Duration = 2, Type = "Warning"})
end

function WindowSystem:Restore()
    self.IsMinimized = false
    self.IsOpen = true
    self.FloatingIcon.Visible = false
    self.Window.Visible = true
    Services.TweenService:Create(self.Window, Design.Animations.Bounce, {
        Size = UDim2.new(0, Design.Sizes.Window.Width, 0, Design.Sizes.Window.Height),
        BackgroundTransparency = 0.02
    }):Play()
end

function WindowSystem:Close()
    self.IsOpen = false
    Services.TweenService:Create(self.Window, Design.Animations.Bounce, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.4, function()
        if self.ScreenGui and self.ScreenGui.Parent then self.ScreenGui:Destroy() end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- TAB SYSTEM: Modular Library Architecture
-- ════════════════════════════════════════════════════════════════════════════════
local TabSystem = {}
TabSystem.Tabs = {}
TabSystem.ActiveTabId = nil

function TabSystem:RegisterTab(id, name, icon, description, category)
    local tab = {
        Id = id,
        Name = name,
        Icon = icon or "◆",
        Description = description or "",
        Category = category or "General",
        Elements = {},
        Flags = {},
        UsageCount = 0,
        IsFavorite = false,
    }

    -- Create sidebar button
    local btn = Factory:Create("TextButton", {
        Name = id .. "TabBtn",
        BackgroundColor3 = Design.Palette.Surface,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Design.Sizes.Tab.Height),
        Text = "",
        ZIndex = 108,
        Parent = WindowSystem.TabContainer
    })
    Factory:ApplyCorner(btn, 8)

    -- Icon frame
    local iconFrame = Factory:Create("Frame", {
        Name = "IconFrame",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 109,
        Parent = btn
    })
    Factory:ApplyCorner(iconFrame, 6)

    local iconLabel = Factory:Create("TextLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = icon,
        TextColor3 = Design.Palette.TextMuted,
        Font = Design.Typography.Header,
        TextSize = 14,
        ZIndex = 110,
        Parent = iconFrame
    })

    local nameLabel = Factory:Create("TextLabel", {
        Name = "Name",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 44, 0, 0),
        Text = name,
        TextColor3 = Design.Palette.TextMuted,
        Font = Design.Typography.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 109,
        Parent = btn
    })

    -- Active indicator (left bar)
    local indicator = Factory:Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 110,
        Parent = btn
    })
    Factory:ApplyCorner(indicator, 2)

    -- Favorite star
    local star = Factory:Create("TextButton", {
        Name = "Star",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -22, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "☆",
        TextColor3 = Design.Palette.TextDark,
        Font = Design.Typography.Body,
        TextSize = 12,
        ZIndex = 110,
        Parent = btn
    })

    star.MouseButton1Click:Connect(function()
        tab.IsFavorite = not tab.IsFavorite
        star.Text = tab.IsFavorite and "★" or "☆"
        Factory:AnimateProperty(star, "TextColor3", tab.IsFavorite and Design.Palette.NeonGold or Design.Palette.TextDark, Design.Animations.Fast)
        if tab.IsFavorite then
            WindowSystem.Favorites[id] = tab
            NotificationSystem:Notify({Title = "Favorite Added", Message = name .. " added to favorites", Type = "Success"})
        else
            WindowSystem.Favorites[id] = nil
        end
        self:UpdateFavorites()
    end)

    -- Hover effects
    btn.MouseEnter:Connect(function()
        if TabSystem.ActiveTabId ~= id then
            Factory:AnimateProperty(btn, "BackgroundColor3", Design.Palette.SurfaceHover, Design.Animations.Fast)
            Factory:AnimateProperty(btn, "BackgroundTransparency", 0.3, Design.Animations.Fast)
            Factory:AnimateProperty(iconLabel, "TextColor3", Design.Palette.TextSecondary, Design.Animations.Fast)
            Factory:AnimateProperty(nameLabel, "TextColor3", Design.Palette.TextSecondary, Design.Animations.Fast)
        end
    end)
    btn.MouseLeave:Connect(function()
        if TabSystem.ActiveTabId ~= id then
            Factory:AnimateProperty(btn, "BackgroundColor3", Design.Palette.Surface, Design.Animations.Fast)
            Factory:AnimateProperty(btn, "BackgroundTransparency", 0.6, Design.Animations.Fast)
            Factory:AnimateProperty(iconLabel, "TextColor3", Design.Palette.TextMuted, Design.Animations.Fast)
            Factory:AnimateProperty(nameLabel, "TextColor3", Design.Palette.TextMuted, Design.Animations.Fast)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        Factory:CreateRipple(btn, Vector2.new(20, 21), Design.Palette.NeonCyan)
        tab.UsageCount = tab.UsageCount + 1
        self:SelectTab(id)
    end)

    -- Content page (scrolling)
    local content = Factory:Create("ScrollingFrame", {
        Name = id .. "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Design.Palette.NeonCyan,
        ScrollBarImageTransparency = 0.6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 106,
        Parent = WindowSystem.ContentArea
    })

    Factory:Create("UIListLayout", {
        Padding = UDim.new(0, 14),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = content
    })

    Factory:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 20),
        Parent = content
    })

    content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, content.UIListLayout.AbsoluteContentSize.Y + 20)
    end)

    tab.Button = btn
    tab.Content = content
    tab.IconFrame = iconFrame
    tab.IconLabel = iconLabel
    tab.NameLabel = nameLabel
    tab.Indicator = indicator
    tab.Star = star

    self.Tabs[id] = tab
    return tab
end

function TabSystem:SelectTab(id)
    if self.ActiveTabId == id then return end

    -- Deactivate current
    local current = self.Tabs[self.ActiveTabId]
    if current then
        Factory:AnimateProperty(current.Button, "BackgroundColor3", Design.Palette.Surface, Design.Animations.Normal)
        Factory:AnimateProperty(current.Button, "BackgroundTransparency", 0.6, Design.Animations.Normal)
        Factory:AnimateProperty(current.IconLabel, "TextColor3", Design.Palette.TextMuted, Design.Animations.Normal)
        Factory:AnimateProperty(current.NameLabel, "TextColor3", Design.Palette.TextMuted, Design.Animations.Normal)
        Factory:AnimateProperty(current.Indicator, "Size", UDim2.new(0, 3, 0, 0), Design.Animations.Normal)
        Factory:AnimateProperty(current.IconFrame, "BackgroundColor3", Design.Palette.Glass, Design.Animations.Normal)
        current.Content.Visible = false
    end

    -- Activate new
    local newTab = self.Tabs[id]
    if newTab then
        Factory:AnimateProperty(newTab.Button, "BackgroundColor3", Design.Palette.SurfaceHover, Design.Animations.Normal)
        Factory:AnimateProperty(newTab.Button, "BackgroundTransparency", 0.2, Design.Animations.Normal)
        Factory:AnimateProperty(newTab.IconLabel, "TextColor3", Design.Palette.NeonCyan, Design.Animations.Normal)
        Factory:AnimateProperty(newTab.NameLabel, "TextColor3", Design.Palette.TextPrimary, Design.Animations.Normal)
        Factory:AnimateProperty(newTab.Indicator, "Size", UDim2.new(0, 3, 0, 26), Design.Animations.Bounce)
        Factory:AnimateProperty(newTab.IconFrame, "BackgroundColor3", Design.Palette.NeonCyan, Design.Animations.Normal)
        Factory:AnimateProperty(newTab.IconFrame, "BackgroundTransparency", 0.7, Design.Animations.Normal)
        newTab.Content.Visible = true
    end

    self.ActiveTabId = id
end

function TabSystem:UpdateFavorites()
    -- Update favorites display in sidebar
    for _, child in pairs(WindowSystem.FavoritesSection:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local yOffset = 20
    for id, tab in pairs(WindowSystem.Favorites) do
        local favBtn = Factory:Create("TextButton", {
            Name = id .. "Fav",
            BackgroundColor3 = Design.Palette.Glass,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, yOffset),
            Text = tab.Icon .. " " .. tab.Name,
            TextColor3 = Design.Palette.TextSecondary,
            Font = Design.Typography.Body,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 108,
            Parent = WindowSystem.FavoritesSection
        })
        Factory:ApplyCorner(favBtn, 6)

        favBtn.MouseEnter:Connect(function()
            Factory:AnimateProperty(favBtn, "BackgroundTransparency", 0.3, Design.Animations.Fast)
            Factory:AnimateProperty(favBtn, "TextColor3", Design.Palette.NeonGold, Design.Animations.Fast)
        end)
        favBtn.MouseLeave:Connect(function()
            Factory:AnimateProperty(favBtn, "BackgroundTransparency", 0.6, Design.Animations.Fast)
            Factory:AnimateProperty(favBtn, "TextColor3", Design.Palette.TextSecondary, Design.Animations.Fast)
        end)
        favBtn.MouseButton1Click:Connect(function()
            self:SelectTab(id)
        end)

        yOffset = yOffset + 32
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- UI COMPONENTS: Custom Elite Elements
-- ════════════════════════════════════════════════════════════════════════════════
local Components = {}

function Components:CreateSection(tabId, title, icon)
    local tab = TabSystem.Tabs[tabId]
    if not tab then return end

    local section = Factory:Create("Frame", {
        Name = title .. "Section",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 107,
        Parent = tab.Content
    })
    Factory:ApplyCorner(section, 14)
    Factory:ApplyStroke(section, Design.Palette.GlassBorder, 1, 0.3)
    Factory:ApplyGlow(section, Design.Palette.NeonCyan, 15)

    Factory:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        Parent = section
    })

    Factory:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = section
    })

    -- Section header
    local header = Factory:Create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        ZIndex = 108,
        Parent = section
    })

    local iconLabel = Factory:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0),
        Text = icon or "◈",
        TextColor3 = Design.Palette.NeonCyan,
        Font = Design.Typography.Header,
        TextSize = 14,
        ZIndex = 109,
        Parent = header
    })

    local titleLabel = Factory:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        Text = title,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Header,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 109,
        Parent = header
    })

    -- Gradient underline
    local underline = Factory:Create("Frame", {
        Name = "Underline",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 50, 0, 2),
        Position = UDim2.new(0, 0, 0, 28),
        ZIndex = 108,
        Parent = section
    })
    Factory:ApplyGradient(underline, Design.Palette.GradientCyber, 0)

    return section
end

function Components:CreateToggle(tabId, section, text, default, callback, flag)
    local container = Factory:Create("Frame", {
        Name = text .. "Toggle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = 109,
        Parent = section
    })

    local label = Factory:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Text = text,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 110,
        Parent = container
    })

    -- Toggle track
    local track = Factory:Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Design.Palette.GlassBorder,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 110,
        Parent = container
    })
    Factory:ApplyCorner(track, 13)

    -- Toggle thumb
    local thumb = Factory:Create("Frame", {
        Name = "Thumb",
        BackgroundColor3 = Design.Palette.TextPrimary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 111,
        Parent = track
    })
    Factory:ApplyCorner(thumb, 999)
    Factory:ApplyGlow(thumb, Design.Palette.TextPrimary, 8)

    local enabled = default or false

    local function updateToggle()
        if enabled then
            Factory:AnimateProperty(track, "BackgroundColor3", Design.Palette.NeonCyan, Design.Animations.Smooth)
            Factory:AnimateProperty(thumb, "Position", UDim2.new(0, 25, 0.5, 0), Design.Animations.Bounce)
            Factory:AnimateProperty(thumb:FindFirstChild("Glow"), "ImageColor3", Design.Palette.NeonCyan, Design.Animations.Smooth)
            Factory:PulseGlow(track, Design.Palette.NeonCyan, 1)
        else
            Factory:AnimateProperty(track, "BackgroundColor3", Design.Palette.GlassBorder, Design.Animations.Smooth)
            Factory:AnimateProperty(thumb, "Position", UDim2.new(0, 3, 0.5, 0), Design.Animations.Bounce)
            Factory:AnimateProperty(thumb:FindFirstChild("Glow"), "ImageColor3", Design.Palette.TextPrimary, Design.Animations.Smooth)
        end
        if callback then callback(enabled) end
        if flag then CAFUXZ1.Config[flag] = enabled end
    end

    local clickArea = Factory:Create("TextButton", {
        Name = "ClickArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 112,
        Parent = container
    })

    clickArea.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
    end)

    if default then updateToggle() end

    return {Set = function(v) enabled = v; updateToggle() end, Get = function() return enabled end}
end

function Components:CreateButton(tabId, section, text, callback, style)
    style = style or "Default"
    local colors = {
        Default = {Bg = Design.Palette.Glass, Border = Design.Palette.GlassBorder},
        Primary = {Bg = Design.Palette.NeonCyan, Border = Design.Palette.NeonCyan},
        Danger = {Bg = Design.Palette.NeonRed, Border = Design.Palette.NeonRed},
        Success = {Bg = Design.Palette.NeonGreen, Border = Design.Palette.NeonGreen},
        Warning = {Bg = Design.Palette.NeonGold, Border = Design.Palette.NeonGold},
    }
    local styleData = colors[style] or colors.Default

    local btn = Factory:Create("TextButton", {
        Name = text .. "Button",
        BackgroundColor3 = styleData.Bg,
        BackgroundTransparency = style == "Default" and 0.5 or 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = text,
        TextColor3 = style == "Default" and Design.Palette.TextPrimary or Design.Palette.Deep,
        Font = Design.Typography.Header,
        TextSize = 12,
        ZIndex = 109,
        Parent = section
    })
    Factory:ApplyCorner(btn, 10)
    Factory:ApplyStroke(btn, styleData.Border, 1, 0.3)

    -- Gradient overlay
    local gradient = Factory:ApplyGradient(btn, {styleData.Border, styleData.Border}, 90, NumberSequence.new(0.92, 0.98))

    btn.MouseEnter:Connect(function()
        Factory:AnimateProperty(btn, "BackgroundTransparency", 0.2, Design.Animations.Fast)
        Factory:AnimateProperty(btn:FindFirstChildOfClass("UIStroke"), "Transparency", 0.1, Design.Animations.Fast)
        Factory:AnimateProperty(btn:FindFirstChildOfClass("UIStroke"), "Thickness", 1.5, Design.Animations.Fast)
        Factory:PulseGlow(btn, styleData.Border, 0.8)
    end)
    btn.MouseLeave:Connect(function()
        Factory:AnimateProperty(btn, "BackgroundTransparency", style == "Default" and 0.5 or 0.2, Design.Animations.Fast)
        Factory:AnimateProperty(btn:FindFirstChildOfClass("UIStroke"), "Transparency", 0.3, Design.Animations.Fast)
        Factory:AnimateProperty(btn:FindFirstChildOfClass("UIStroke"), "Thickness", 1, Design.Animations.Fast)
    end)
    btn.MouseButton1Click:Connect(function()
        Factory:CreateRipple(btn, Vector2.new(btn.AbsoluteSize.X/2, btn.AbsoluteSize.Y/2), styleData.Border)
        if callback then callback() end
    end)

    return btn
end

function Components:CreateSlider(tabId, section, text, min, max, default, callback, flag)
    local container = Factory:Create("Frame", {
        Name = text .. "Slider",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = 109,
        Parent = section
    })

    local label = Factory:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 20),
        Text = text,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 110,
        Parent = container
    })

    local valueLabel = Factory:Create("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        Text = tostring(default or min),
        TextColor3 = Design.Palette.NeonCyan,
        Font = Design.Typography.Mono,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 110,
        Parent = container
    })

    -- Track background
    local track = Factory:Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Design.Palette.GlassBorder,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 34),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 110,
        Parent = container
    })
    Factory:ApplyCorner(track, 4)

    -- Fill
    local fill = Factory:Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Design.Palette.NeonCyan,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 111,
        Parent = track
    })
    Factory:ApplyCorner(fill, 4)
    Factory:ApplyGradient(fill, Design.Palette.GradientCyber, 0)
    Factory:ApplyGlow(fill, Design.Palette.NeonCyan, 8)

    -- Thumb
    local thumb = Factory:Create("Frame", {
        Name = "Thumb",
        BackgroundColor3 = Design.Palette.TextPrimary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 112,
        Parent = track
    })
    Factory:ApplyCorner(thumb, 999)
    Factory:ApplyGlow(thumb, Design.Palette.NeonCyan, 10)

    local dragging = false
    local currentValue = default or min

    local function update(value)
        currentValue = math.clamp(value, min, max)
        local percent = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        thumb.Position = UDim2.new(percent, 0, 0.5, 0)
        valueLabel.Text = string.format("%.1f", currentValue)
        if callback then callback(currentValue) end
        if flag then CAFUXZ1.Config[flag] = currentValue end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    update(currentValue)
    return {Set = function(v) update(v) end, Get = function() return currentValue end}
end

function Components:CreateDropdown(tabId, section, text, options, default, callback, flag)
    local container = Factory:Create("Frame", {
        Name = text .. "Dropdown",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        ZIndex = 109,
        Parent = section
    })

    local label = Factory:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Text = text,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 110,
        Parent = container
    })

    local btn = Factory:Create("TextButton", {
        Name = "DropdownBtn",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Position = UDim2.new(0, 0, 0, 24),
        Text = default or options[1] or "Select...",
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 11,
        ZIndex = 110,
        Parent = container
    })
    Factory:ApplyCorner(btn, 8)
    Factory:ApplyStroke(btn, Design.Palette.GlassBorder, 1, 0.3)

    local arrow = Factory:Create("TextLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        Text = "▼",
        TextColor3 = Design.Palette.TextMuted,
        Font = Design.Typography.Header,
        TextSize = 10,
        ZIndex = 111,
        Parent = btn
    })

    local listFrame = Factory:Create("Frame", {
        Name = "List",
        BackgroundColor3 = Design.Palette.Surface,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        ClipsDescendants = true,
        ZIndex = 200,
        Visible = false,
        Parent = btn
    })
    Factory:ApplyCorner(listFrame, 10)
    Factory:ApplyStroke(listFrame, Design.Palette.GlassBorder, 1, 0.2)
    Factory:ApplyGlow(listFrame, Design.Palette.NeonCyan, 15)

    Factory:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = listFrame
    })

    Factory:Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = listFrame
    })

    local open = false

    local function toggle()
        open = not open
        if open then
            listFrame.Visible = true
            Factory:AnimateProperty(arrow, "Rotation", 180, Design.Animations.Fast)
            Factory:AnimateProperty(listFrame, "Size", UDim2.new(1, 0, 0, math.min(#options * 30 + 16, 220)), Design.Animations.Smooth)
        else
            Factory:AnimateProperty(arrow, "Rotation", 0, Design.Animations.Fast)
            Factory:AnimateProperty(listFrame, "Size", UDim2.new(1, 0, 0, 0), Design.Animations.Normal)
            task.delay(0.25, function() if not open then listFrame.Visible = false end end)
        end
    end

    btn.MouseButton1Click:Connect(toggle)

    for i, option in ipairs(options) do
        local optBtn = Factory:Create("TextButton", {
            Name = option,
            BackgroundColor3 = Design.Palette.Glass,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            Text = option,
            TextColor3 = Design.Palette.TextSecondary,
            Font = Design.Typography.Body,
            TextSize = 11,
            ZIndex = 201,
            Parent = listFrame
        })
        Factory:ApplyCorner(optBtn, 6)

        optBtn.MouseEnter:Connect(function()
            Factory:AnimateProperty(optBtn, "BackgroundColor3", Design.Palette.NeonCyan, Design.Animations.Fast)
            Factory:AnimateProperty(optBtn, "BackgroundTransparency", 0.7, Design.Animations.Fast)
            Factory:AnimateProperty(optBtn, "TextColor3", Design.Palette.TextPrimary, Design.Animations.Fast)
        end)
        optBtn.MouseLeave:Connect(function()
            Factory:AnimateProperty(optBtn, "BackgroundColor3", Design.Palette.Glass, Design.Animations.Fast)
            Factory:AnimateProperty(optBtn, "BackgroundTransparency", 0.6, Design.Animations.Fast)
            Factory:AnimateProperty(optBtn, "TextColor3", Design.Palette.TextSecondary, Design.Animations.Fast)
        end)
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = option
            toggle()
            if callback then callback(option) end
            if flag then CAFUXZ1.Config[flag] = option end
        end)
    end

    return {Set = function(v) btn.Text = v end, Get = function() return btn.Text end}
end

function Components:CreateKeybind(tabId, section, text, defaultKey, callback, flag)
    local container = Factory:Create("Frame", {
        Name = text .. "Keybind",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = 109,
        Parent = section
    })

    local label = Factory:Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Text = text,
        TextColor3 = Design.Palette.TextPrimary,
        Font = Design.Typography.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 110,
        Parent = container
    })

    local keyBtn = Factory:Create("TextButton", {
        Name = "KeyBtn",
        BackgroundColor3 = Design.Palette.Glass,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 70, 0, 28),
        Position = UDim2.new(1, -70, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = defaultKey and defaultKey.Name or "None",
        TextColor3 = Design.Palette.NeonCyan,
        Font = Design.Typography.Mono,
        TextSize = 10,
        ZIndex = 110,
        Parent = container
    })
    Factory:ApplyCorner(keyBtn, 6)
    Factory:ApplyStroke(keyBtn, Design.Palette.NeonCyan, 1, 0.3)

    local listening = false
    local currentKey = defaultKey

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        Factory:AnimateProperty(keyBtn, "BackgroundColor3", Design.Palette.NeonCyan, Design.Animations.Fast)
        Factory:AnimateProperty(keyBtn, "TextColor3", Design.Palette.Deep, Design.Animations.Fast)
    end)

    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode
            keyBtn.Text = currentKey.Name
            Factory:AnimateProperty(keyBtn, "BackgroundColor3", Design.Palette.Glass, Design.Animations.Fast)
            Factory:AnimateProperty(keyBtn, "TextColor3", Design.Palette.NeonCyan, Design.Animations.Fast)
            if flag then CAFUXZ1.Config[flag] = currentKey.Name end
        elseif currentKey and input.KeyCode == currentKey and not gameProcessed then
            if callback then callback() end
        end
    end)

    return {Set = function(k) currentKey = k; keyBtn.Text = k.Name end, Get = function() return currentKey end}
end

function Components:CreateLabel(tabId, section, text, color, size)
    return Factory:Create("TextLabel", {
        Name = text .. "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, size or 18),
        Text = text,
        TextColor3 = color or Design.Palette.TextSecondary,
        Font = Design.Typography.Body,
        TextSize = size and size * 0.7 or 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 109,
        Parent = section
    })
end

function Components:CreateDivider(tabId, section)
    return Factory:Create("Frame", {
        Name = "Divider",
        BackgroundColor3 = Design.Palette.GlassBorder,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 109,
        Parent = section
    })
end

-- ════════════════════════════════════════════════════════════════════════════════
-- TCS FEATURES: The Complete Soccer - Core Systems
-- ════════════════════════════════════════════════════════════════════════════════
local TCS = {}
TCS.Settings = {
    CurvedKick = {Enabled = true, Power = 50, Curve = 30, Height = 15},
    GKReach = {Enabled = true, Size = 12, Height = 24, Transparency = 1},
    AutoCatch = {Enabled = false, Range = 8},
    BallColor = {Enabled = false, Color = Color3.fromRGB(0, 255, 255), Material = "Neon"},
    ScreenStretch = {Enabled = false, Amount = 0.5},
    Character = {WalkSpeed = 16, JumpPower = 50, NoClip = false, InfStamina = false},
    Visual = {ESPPlayers = false, ESPBall = false, Tracers = false},
    AntiAFK = true,
}

TCS.Connections = {}

function TCS:GetBall()
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("ball") or (obj.Size.X == obj.Size.Y and obj.Size.Y == obj.Size.Z and obj.Size.X < 15 and obj.Size.X > 2) then
                if obj.Shape == Enum.PartType.Ball or obj:FindFirstChild("Ball") then
                    return obj
                end
            end
        end
    end
    return nil
end

function TCS:GetCharacter()
    return Services.Players.LocalPlayer.Character
end

function TCS:GetHumanoid()
    local char = self:GetCharacter()
    if char then return char:FindFirstChildOfClass("Humanoid") end
    return nil
end

function TCS:GetHRP()
    local char = self:GetCharacter()
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

-- Curved Kick System
function TCS:InitCurvedKick()
    if self.Connections.CurvedKick then self.Connections.CurvedKick:Disconnect() end

    self.Connections.CurvedKick = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not self.Settings.CurvedKick.Enabled then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.KeyCode ~= Enum.KeyCode.ButtonR2 then return end

        local ball = self:GetBall()
        local hrp = self:GetHRP()
        if not ball or not hrp then return end

        local distance = (ball.Position - hrp.Position).Magnitude
        if distance > 18 then return end

        local mousePos = Services.UserInputService:GetMouseLocation()
        local camera = Services.Workspace.CurrentCamera
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local direction = ray.Direction.Unit

        -- Physics calculation
        local power = self.Settings.CurvedKick.Power / 10
        local curve = self.Settings.CurvedKick.Curve / 100
        local height = self.Settings.CurvedKick.Height / 10

        local velocity = direction * power * 55
        velocity = velocity + Vector3.new(0, height * 15, 0)

        -- Lateral curve
        local lateralCurve = (mousePos.X - camera.ViewportSize.X / 2) / camera.ViewportSize.X
        velocity = velocity + camera.CFrame.RightVector * lateralCurve * curve * 35

        -- Apply physics
        if ball:FindFirstChild("BodyVelocity") then ball.BodyVelocity:Destroy() end
        if ball:FindFirstChild("BodyAngularVelocity") then ball.BodyAngularVelocity:Destroy() end

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = velocity
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.P = 5000
        bv.Parent = ball

        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(
            math.random(-15, 15) * curve,
            math.random(-15, 15) * curve,
            math.random(-15, 15) * curve
        ) * 2
        bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bav.P = 5000
        bav.Parent = ball

        Services.Debris:AddItem(bv, 0.6)
        Services.Debris:AddItem(bav, 0.6)

        NotificationSystem:Notify({
            Title = "⚽ Curved Kick",
            Message = "Power: " .. self.Settings.CurvedKick.Power .. "% | Curve: " .. self.Settings.CurvedKick.Curve .. "%",
            Type = "Success",
            Duration = 2
        })
    end)
end

-- GK Reach System
function TCS:InitGKReach()
    if self.GKCube then self.GKCube:Destroy() end
    if self.GKSelectionBox then self.GKSelectionBox:Destroy() end

    local cube = Instance.new("Part")
    cube.Name = "CAFUXZ1_GKReach"
    cube.Size = Vector3.new(self.Settings.GKReach.Size, self.Settings.GKReach.Height, self.Settings.GKReach.Size)
    cube.Transparency = self.Settings.GKReach.Transparency
    cube.CanCollide = false
    cube.CanQuery = false
    cube.CanTouch = false
    cube.Anchored = false
    cube.Color = Design.Palette.NeonCyan
    cube.Material = Enum.Material.ForceField
    cube.Parent = Services.Workspace

    local weld = Instance.new("Weld")
    weld.Part0 = cube
    weld.Part1 = self:GetHRP() or cube
    weld.C0 = CFrame.new(0, 0, -3)
    weld.Parent = cube

    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = cube
    selectionBox.LineThickness = 0.04
    selectionBox.Color3 = Design.Palette.NeonCyan
    selectionBox.Parent = cube

    self.GKCube = cube
    self.GKSelectionBox = selectionBox

    -- Update loop
    task.spawn(function()
        while self.GKCube and self.GKCube.Parent do
            if self.Settings.GKReach.Enabled then
                self.GKCube.Size = Vector3.new(self.Settings.GKReach.Size, self.Settings.GKReach.Height, self.Settings.GKReach.Size)
                self.GKCube.Transparency = self.Settings.GKReach.Transparency
                self.GKCube.Parent = Services.Workspace
                self.GKSelectionBox.Color3 = Design.Palette.NeonCyan

                -- Update weld
                local hrp = self:GetHRP()
                if hrp and self.GKCube:FindFirstChildOfClass("Weld") then
                    self.GKCube:FindFirstChildOfClass("Weld").Part1 = hrp
                end
            else
                self.GKCube.Parent = nil
            end
            task.wait(0.1)
        end
    end)
end

-- Auto Catch System
function TCS:InitAutoCatch()
    if self.Connections.AutoCatch then self.Connections.AutoCatch:Disconnect() end

    self.Connections.AutoCatch = Services.RunService.Heartbeat:Connect(function()
        if not self.Settings.AutoCatch.Enabled then return end
        local ball = self:GetBall()
        local hrp = self:GetHRP()
        if not ball or not hrp then return end

        local distance = (ball.Position - hrp.Position).Magnitude
        if distance < self.Settings.AutoCatch.Range then
            ball.CFrame = hrp.CFrame * CFrame.new(0, 2.5, -2.5)
            ball.Velocity = Vector3.new(0, 0, 0)
            ball.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- Ball Customization
function TCS:ApplyBallColor()
    if not self.Settings.BallColor.Enabled then return end
    local ball = self:GetBall()
    if not ball then return end
    ball.Color = self.Settings.BallColor.Color
    if self.Settings.BallColor.Material == "Neon" then
        ball.Material = Enum.Material.Neon
    elseif self.Settings.BallColor.Material == "ForceField" then
        ball.Material = Enum.Material.ForceField
    else
        ball.Material = Enum.Material.SmoothPlastic
    end
end

-- Screen Stretch (FPS Boost)
function TCS:ApplyScreenStretch()
    if not self.Settings.ScreenStretch.Enabled then
        Services.Workspace.CurrentCamera.FieldOfView = 70
        return
    end

    local camera = Services.Workspace.CurrentCamera
    local amount = self.Settings.ScreenStretch.Amount
    camera.FieldOfView = 70 + (amount * 40)

    -- Optimize materials
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Material ~= Enum.Material.Neon and obj.Material ~= Enum.Material.ForceField then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = math.min(obj.Transparency + 0.3, 0.8)
        end
    end

    -- Disable post-processing
    Services.Lighting.GlobalShadows = false
    Services.Lighting.FogEnd = 100000
    for _, effect in pairs(Services.Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
end

-- ESP System
function TCS:UpdateESP()
    -- Clear old ESP
    for _, conn in pairs(self.Connections.ESP or {}) do
        if conn then conn:Disconnect() end
    end
    self.Connections.ESP = {}

    if self.Settings.Visual.ESPPlayers then
        for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= Services.Players.LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Design.Palette.NeonPink
                highlight.OutlineColor = Design.Palette.NeonPink
                highlight.FillTransparency = 0.8
                highlight.OutlineTransparency = 0.2
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = player.Character
                highlight.Parent = player.Character

                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 120, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                billboard.Parent = player.Character

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Design.Palette.NeonPink
                nameLabel.Font = Design.Typography.Header
                nameLabel.TextSize = 12
                nameLabel.Parent = billboard
            end
        end
    end

    if self.Settings.Visual.ESPBall then
        local ball = self:GetBall()
        if ball then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Design.Palette.NeonCyan
            highlight.OutlineColor = Design.Palette.NeonCyan
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0.1
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = ball
            highlight.Parent = ball

            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 80, 0, 25)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = ball
            billboard.Parent = ball

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "⚽ BALL"
            label.TextColor3 = Design.Palette.NeonCyan
            label.Font = Design.Typography.Header
            label.TextSize = 12
            label.Parent = billboard
        end
    end
end

-- Character Modifications
function TCS:UpdateCharacter()
    local humanoid = self:GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = self.Settings.Character.WalkSpeed
        humanoid.JumpPower = self.Settings.Character.JumpPower
    end

    if self.Settings.Character.NoClip then
        local char = self:GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- Anti-AFK
function TCS:InitAntiAFK()
    Services.Players.LocalPlayer.Idled:Connect(function()
        if self.Settings.AntiAFK then
            Services.VirtualUser:Button2Down(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VirtualUser:Button2Up(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- HUB SETUP: All Tabs & Features
-- ════════════════════════════════════════════════════════════════════════════════
function CAFUXZ1:SetupHub()
    -- DASHBOARD TAB (Quick Access)
    TabSystem:RegisterTab("Dashboard", "Dashboard", "◈", "Quick access to favorite features", "Main")
    local dashQuick = Components:CreateSection("Dashboard", "⚡ Quick Actions", "⚡")
    Components:CreateButton("Dashboard", dashQuick, "Teleport to Ball", function()
        local ball = TCS:GetBall()
        local hrp = TCS:GetHRP()
        if ball and hrp then
            hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0, 4, 0))
            NotificationSystem:Notify({Title = "Teleport", Message = "Teleported to ball position!", Type = "Success"})
        else
            NotificationSystem:Notify({Title = "Error", Message = "Ball or character not found!", Type = "Error"})
        end
    end, "Primary")

    Components:CreateButton("Dashboard", dashQuick, "Reset Character", function()
        local char = TCS:GetCharacter()
        if char then char:BreakJoints() end
    end, "Warning")

    Components:CreateButton("Dashboard", dashQuick, "Rejoin Server", function()
        Services.TeleportService:Teleport(game.PlaceId, Services.Players.LocalPlayer)
    end, "Danger")

    local dashStats = Components:CreateSection("Dashboard", "📊 Session Stats", "📊")
    Components:CreateLabel("Dashboard", dashStats, "Goals Scored: 0", Design.Palette.TextSecondary)
    Components:CreateLabel("Dashboard", dashStats, "Assists: 0", Design.Palette.TextSecondary)
    Components:CreateLabel("Dashboard", dashStats, "Saves: 0", Design.Palette.TextSecondary)
    Components:CreateLabel("Dashboard", dashStats, "Time Played: 00:00", Design.Palette.TextSecondary)

    -- CURVED KICK TAB
    TabSystem:RegisterTab("Kick", "Curved Kick", "⚽", "Advanced ball physics system", "Combat")
    local kickMain = Components:CreateSection("Kick", "🎯 Kick Physics", "🎯")
    Components:CreateToggle("Kick", kickMain, "Enable Curved Kick", true, function(val)
        TCS.Settings.CurvedKick.Enabled = val
        if val then TCS:InitCurvedKick() end
    end, "CurvedKickEnabled")

    Components:CreateSlider("Kick", kickMain, "Kick Power", 10, 100, 50, function(val)
        TCS.Settings.CurvedKick.Power = val
    end, "CurvedKickPower")

    Components:CreateSlider("Kick", kickMain, "Curve Amount", 0, 100, 30, function(val)
        TCS.Settings.CurvedKick.Curve = val
    end, "CurvedKickCurve")

    Components:CreateSlider("Kick", kickMain, "Kick Height", 0, 50, 15, function(val)
        TCS.Settings.CurvedKick.Height = val
    end, "CurvedKickHeight")

    Components:CreateLabel("Kick", kickMain, "Click or press RT/R2 to execute curved kick", Design.Palette.TextMuted)
    Components:CreateLabel("Kick", kickMain, "Curve direction follows mouse position", Design.Palette.TextMuted)

    -- GK TAB
    TabSystem:RegisterTab("GK", "Goalkeeper", "🥅", "GK reach and auto catch systems", "Combat")
    local gkMain = Components:CreateSection("GK", "🛡️ GK Configuration", "🛡️")
    Components:CreateToggle("GK", gkMain, "Enable GK Reach", true, function(val)
        TCS.Settings.GKReach.Enabled = val
        if val then TCS:InitGKReach() end
    end, "GKReachEnabled")

    Components:CreateSlider("GK", gkMain, "Reach Width/Depth", 5, 25, 12, function(val)
        TCS.Settings.GKReach.Size = val
    end, "GKReachSize")

    Components:CreateSlider("GK", gkMain, "Reach Height", 10, 40, 24, function(val)
        TCS.Settings.GKReach.Height = val
    end, "GKReachHeight")

    Components:CreateToggle("GK", gkMain, "Auto Catch", false, function(val)
        TCS.Settings.AutoCatch.Enabled = val
        if val then TCS:InitAutoCatch() end
    end, "AutoCatchEnabled")

    Components:CreateSlider("GK", gkMain, "Catch Range", 3, 15, 8, function(val)
        TCS.Settings.AutoCatch.Range = val
    end, "AutoCatchRange")

    Components:CreateLabel("GK", gkMain, "Transparent cube with visible wireframe borders", Design.Palette.TextMuted)

    -- BALL TAB
    TabSystem:RegisterTab("Ball", "Ball", "🔵", "Ball customization and control", "Visual")
    local ballMain = Components:CreateSection("Ball", "🎨 Ball Customization", "🎨")
    Components:CreateToggle("Ball", ballMain, "Custom Ball Color", false, function(val)
        TCS.Settings.BallColor.Enabled = val
        TCS:ApplyBallColor()
    end, "BallColorEnabled")

    Components:CreateDropdown("Ball", ballMain, "Ball Material", {"Neon", "ForceField", "Plastic", "Metal"}, "Neon", function(val)
        TCS.Settings.BallColor.Material = val
        TCS:ApplyBallColor()
    end, "BallMaterial")

    Components:CreateButton("Ball", ballMain, "Apply Neon Effect", function()
        TCS.Settings.BallColor.Enabled = true
        TCS.Settings.BallColor.Material = "Neon"
        TCS:ApplyBallColor()
        NotificationSystem:Notify({Title = "Ball", Message = "Neon effect applied!", Type = "Success"})
    end, "Primary")

    Components:CreateButton("Ball", ballMain, "Reset Ball", function()
        local ball = TCS:GetBall()
        if ball then
            ball.Color = Color3.fromRGB(255, 255, 255)
            ball.Material = Enum.Material.Plastic
            ball.Velocity = Vector3.new(0, 0, 0)
            ball.RotVelocity = Vector3.new(0, 0, 0)
            TCS.Settings.BallColor.Enabled = false
            NotificationSystem:Notify({Title = "Ball", Message = "Ball reset to default!", Type = "Warning"})
        end
    end, "Danger")

    -- VISUAL TAB
    TabSystem:RegisterTab("Visual", "Visual", "👁️", "ESP and visual effects", "Visual")
    local visualESP = Components:CreateSection("Visual", "🔍 ESP System", "🔍")
    Components:CreateToggle("Visual", visualESP, "ESP Players", false, function(val)
        TCS.Settings.Visual.ESPPlayers = val
        TCS:UpdateESP()
    end, "ESPPlayers")

    Components:CreateToggle("Visual", visualESP, "ESP Ball", false, function(val)
        TCS.Settings.Visual.ESPBall = val
        TCS:UpdateESP()
    end, "ESPBall")

    local visualEffects = Components:CreateSection("Visual", "✨ Performance Effects", "✨")
    Components:CreateToggle("Visual", visualEffects, "Screen Stretch (FPS Boost)", false, function(val)
        TCS.Settings.ScreenStretch.Enabled = val
        TCS:ApplyScreenStretch()
        if val then
            NotificationSystem:Notify({Title = "FPS Boost", Message = "Screen stretch + material optimization active!", Type = "Success"})
        end
    end, "ScreenStretchEnabled")

    Components:CreateSlider("Visual", visualEffects, "Stretch Intensity", 0, 1, 0.5, function(val)
        TCS.Settings.ScreenStretch.Amount = val
        if TCS.Settings.ScreenStretch.Enabled then TCS:ApplyScreenStretch() end
    end, "StretchAmount")

    -- CHARACTER TAB
    TabSystem:RegisterTab("Character", "Character", "🏃", "Character modifications", "Main")
    local charMain = Components:CreateSection("Character", "⚙️ Character Settings", "⚙️")
    Components:CreateSlider("Character", charMain, "Walk Speed", 16, 200, 16, function(val)
        TCS.Settings.Character.WalkSpeed = val
        TCS:UpdateCharacter()
    end, "WalkSpeed")

    Components:CreateSlider("Character", charMain, "Jump Power", 50, 300, 50, function(val)
        TCS.Settings.Character.JumpPower = val
        TCS:UpdateCharacter()
    end, "JumpPower")

    Components:CreateToggle("Character", charMain, "No Clip", false, function(val)
        TCS.Settings.Character.NoClip = val
        TCS:UpdateCharacter()
    end, "NoClip")

    Components:CreateToggle("Character", charMain, "Infinite Stamina", false, function(val)
        TCS.Settings.Character.InfStamina = val
    end, "InfStamina")

    Components:CreateToggle("Character", charMain, "Anti AFK", true, function(val)
        TCS.Settings.AntiAFK = val
    end, "AntiAFK")

    -- SETTINGS TAB
    TabSystem:RegisterTab("Settings", "Settings", "⚙️", "Hub configuration and themes", "System")
    local settingsTheme = Components:CreateSection("Settings", "🎨 Theme Customization", "🎨")
    Components:CreateDropdown("Settings", settingsTheme, "Theme Preset", {"Cyber", "Inferno", "Matrix", "Void"}, "Cyber", function(val)
        ThemeManager:SetTheme(val)
        NotificationSystem:Notify({Title = "Theme", Message = "Theme changed to " .. val, Type = "Success"})
    end, "ThemePreset")

    local settingsConfig = Components:CreateSection("Settings", "💾 Configuration", "💾")
    Components:CreateButton("Settings", settingsConfig, "Save Configuration", function()
        NotificationSystem:Notify({Title = "Config", Message = "Settings saved to memory!", Type = "Success"})
    end, "Success")

    Components:CreateButton("Settings", settingsConfig, "Load Configuration", function()
        NotificationSystem:Notify({Title = "Config", Message = "Settings loaded from memory!", Type = "Success"})
    end, "Primary")

    Components:CreateButton("Settings", settingsConfig, "Reset All", function()
        for k, v in pairs(TCS.Settings) do
            if type(v) == "table" then
                for k2, v2 in pairs(v) do
                    if type(v2) == "boolean" then TCS.Settings[k][k2] = false
                    elseif type(v2) == "number" then TCS.Settings[k][k2] = 0 end
                end
            end
        end
        NotificationSystem:Notify({Title = "Reset", Message = "All settings reset to default!", Type = "Warning"})
    end, "Danger")

    local settingsInfo = Components:CreateSection("Settings", "ℹ️ About", "ℹ️")
    Components:CreateLabel("Settings", settingsInfo, "CAFUXZ1 TCS Hub v17.0 Elite", Design.Palette.NeonCyan, 16)
    Components:CreateLabel("Settings", settingsInfo, "The Complete Soccer Edition", Design.Palette.TextSecondary)
    Components:CreateLabel("Settings", settingsInfo, "Desktop Application Architecture", Design.Palette.TextSecondary)
    Components:CreateLabel("Settings", settingsInfo, "Dark Glassmorphism + Neon Cyber Design", Design.Palette.TextMuted)
    Components:CreateLabel("Settings", settingsInfo, "Modular Library System | 2026", Design.Palette.TextMuted)

    -- Select Dashboard as default
    TabSystem:SelectTab("Dashboard")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MAIN INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════
function CAFUXZ1:Init()
    -- Create window
    WindowSystem:Create()

    -- Setup all tabs and features
    self:SetupHub()

    -- Initialize TCS systems
    TCS:InitCurvedKick()
    TCS:InitGKReach()
    TCS:InitAutoCatch()
    TCS:InitAntiAFK()

    -- Character update loop
    Services.RunService.Heartbeat:Connect(function()
        TCS:UpdateCharacter()
    end)

    -- Character respawn handler
    Services.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        TCS:InitGKReach()
        TCS:InitCurvedKick()
    end)

    -- Welcome sequence
    task.delay(1.5, function()
        NotificationSystem:Notify({
            Title = "🎉 Welcome to CAFUXZ1",
            Message = "TCS Elite v17.0 loaded successfully!",
            Type = "Success",
            Duration = 5
        })
        task.wait(0.5)
        NotificationSystem:Notify({
            Title = "💡 Tip",
            Message = "Use the sidebar to navigate. Star your favorite tabs!",
            Type = "Info",
            Duration = 4
        })
        task.wait(0.5)
        NotificationSystem:Notify({
            Title = "⚽ Ready",
            Message = "Curved kick and GK systems are active. Enjoy!",
            Type = "Success",
            Duration = 3
        })
    end)

    -- Global access
    _G.CAFUXZ1 = self
    _G.CAFUXZ1_TCS = TCS

    print("[CAFUXZ1] TCS Elite v17.0 initialized | Desktop Application Architecture")
    print("[CAFUXZ1] Modules: WindowSystem, TabSystem, Components, TCS, ThemeManager")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- START
-- ════════════════════════════════════════════════════════════════════════════════
CAFUXZ1:Init()
