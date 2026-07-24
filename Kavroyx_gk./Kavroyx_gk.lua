-- ═══════════════════════════════════════════════════
--  KAVROYX GK HUB V3 — Goalkeeper Reach
--  Cubo transparente com bordas visíveis
--  Cor inicial: Amarelo | Input RGB custom
-- ═══════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════
--  CONFIGURAÇÕES
-- ═══════════════════════════════════════════════════
local CONFIG = {
    reach = 10,
    showReachCube = true,
    autoTouch = true,
    guiKey = Enum.KeyCode.K,
    cubeTransparency = 1,           -- Cubo totalmente invisível
    borderTransparency = 0,         -- Bordas sempre visíveis
    cubeColor = Color3.fromRGB(255, 255, 0), -- Amarelo inicial
    guiKey = Enum.KeyCode.K,
}

-- ═══════════════════════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════════════════════
local State = {
    reachCube = nil,
    selectionBox = nil,
    gui = nil,
    reachLabel = nil,
    colorBox = nil,
    menuVisible = true,
    debounces = {},
    connections = {},
    notifActive = {},
}

-- ═══════════════════════════════════════════════════
--  UTILITÁRIOS
-- ═══════════════════════════════════════════════════
local function canRun(key, cooldown)
    local now = tick()
    cooldown = cooldown or 0.2
    if not State.debounces[key] or (now - State.debounces[key]) >= cooldown then
        State.debounces[key] = now
        return true
    end
    return false
end

local STYLE = {
    accent = Color3.fromRGB(90, 170, 255),
    bg = Color3.fromRGB(20, 30, 50),
    top = Color3.fromRGB(30, 60, 100),
    input = Color3.fromRGB(15, 35, 65),
    btn = Color3.fromRGB(30, 80, 150),
    text = Color3.fromRGB(200, 230, 255),
    sub = Color3.fromRGB(150, 170, 200),
    logo = "rbxassetid://88380080222477",
    closeIcon = "rbxassetid://122931434733842",
}

-- ═══════════════════════════════════════════════════
--  NOTIFICAÇÕES (Junkie Style)
-- ═══════════════════════════════════════════════════
local function notify(title, content, length, iconId)
    local screen = Instance.new("ScreenGui")
    screen.Name = "GKNotif_" .. tostring(math.floor(tick() * 1000))
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 2147483647
    screen.Parent = CoreGui

    local cam = workspace.CurrentCamera
    local scale = math.clamp(math.min(cam.ViewportSize.X, cam.ViewportSize.Y) / 1366, 0.6, 1.6)
    local w = math.clamp(320 * scale, 200, 520)
    local h = math.clamp(72 * scale, 54, 140)

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, w, 0, h)
    main.Position = UDim2.new(1, -12, 1, -12 - h - 16)
    main.AnchorPoint = Vector2.new(1, 1)
    main.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
    main.BorderSizePixel = 0
    main.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 1, -4)
    bar.BackgroundColor3 = STYLE.accent
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = true
    bar.Parent = main

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = STYLE.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, h, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or STYLE.logo
    icon.ImageColor3 = STYLE.accent
    icon.ScaleType = Enum.ScaleType.Stretch
    icon.Parent = main

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1, -h - 8, 0.4, 0)
    txt.Position = UDim2.new(0, h + 8, 0, 0)
    txt.Font = Enum.Font.Code
    txt.TextSize = math.clamp(14 * scale, 12, 20)
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Text = title
    txt.Parent = main

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -h - 8, 0.5, 0)
    sub.Position = UDim2.new(0, h + 8, 0.4, 0)
    sub.Font = Enum.Font.Code
    sub.TextSize = math.clamp(12 * scale, 10, 16)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextYAlignment = Enum.TextYAlignment.Top
    sub.TextColor3 = Color3.fromRGB(200, 200, 200)
    sub.Text = content
    sub.TextWrapped = true
    sub.Parent = main

    local id = tostring(math.floor(tick() * 1000)) .. "-" .. HttpService:GenerateGUID(false)
    table.insert(State.notifActive, {id = id, frame = main, sizeY = h})

    local function restack()
        local spacing = 8 * scale
        local yoff = 0
        for i = #State.notifActive, 1, -1 do
            local node = State.notifActive[i]
            if node and node.frame and node.frame.Parent then
                local target = -12 - yoff - node.sizeY
                TweenService:Create(node.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -12, 1, target)
                }):Play()
                yoff = yoff + node.sizeY + spacing
            end
        end
    end

    restack()

    local function destroy()
        for i = 1, #State.notifActive do
            if State.notifActive[i].id == id then
                table.remove(State.notifActive, i)
                break
            end
        end
        TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 16, main.Position.Y.Scale, main.Position.Y.Offset),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(txt, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
        TweenService:Create(sub, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
        TweenService:Create(icon, TweenInfo.new(0.35), {ImageTransparency = 1}):Play()
        task.wait(0.35)
        pcall(function() main:Destroy() end)
        pcall(function() screen:Destroy() end)
        restack()
    end

    if length and length > 0 then
        TweenService:Create(fill, TweenInfo.new(length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()
        task.delay(length, destroy)
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 10
    btn.Parent = main
    btn.MouseButton1Click:Connect(destroy)

    return {Close = destroy}
end

-- ═══════════════════════════════════════════════════
--  CUBO GK (só bordas visíveis)
-- ═══════════════════════════════════════════════════
local function destroyCube()
    if State.reachCube then
        pcall(function() State.reachCube:Destroy() end)
    end
    if State.selectionBox then
        pcall(function() State.selectionBox:Destroy() end)
    end
    State.reachCube = nil
    State.selectionBox = nil
end

local function createCube()
    destroyCube()
    if not CONFIG.showReachCube then return end

    local cube = Instance.new("Part")
    cube.Name = "GK_ReachCube"
    cube.Shape = Enum.PartType.Block
    cube.Anchored = true
    cube.CanCollide = false
    cube.CanQuery = false
    cube.CanTouch = false
    cube.Transparency = CONFIG.cubeTransparency  -- 1 = invisível
    cube.Material = Enum.Material.Neon
    cube.Color = CONFIG.cubeColor
    cube.CastShadow = false
    cube.Parent = Workspace
    State.reachCube = cube

    -- Bordas visíveis (SelectionBox)
    local box = Instance.new("SelectionBox")
    box.Name = "GK_Outline"
    box.Adornee = cube
    box.Color3 = CONFIG.cubeColor
    box.LineThickness = 0.04
    box.Transparency = CONFIG.borderTransparency  -- 0 = visível
    box.Parent = cube
    State.selectionBox = box

    -- Atualiza posição
    local conn = RunService.RenderStepped:Connect(function()
        if not State.reachCube or not State.reachCube.Parent then return end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            State.reachCube.CFrame = hrp.CFrame
        end
    end)
    table.insert(State.connections, conn)
end

local function updateCubeSize()
    if State.reachCube and State.reachCube.Parent then
        local size = CONFIG.reach * 2
        State.reachCube.Size = Vector3.new(size, size, size)
    end
end

local function updateCubeColor()
    if State.reachCube and State.reachCube.Parent then
        State.reachCube.Color = CONFIG.cubeColor
    end
    if State.selectionBox and State.selectionBox.Parent then
        State.selectionBox.Color3 = CONFIG.cubeColor
    end
end

local function updateCube()
    if not CONFIG.showReachCube then
        destroyCube()
        return
    end
    if not State.reachCube or not State.reachCube.Parent then
        createCube()
    end
    updateCubeSize()
    updateCubeColor()
end

-- ═══════════════════════════════════════════════════
--  AUTO TOUCH (GK Logic)
-- ═══════════════════════════════════════════════════
local function processTouch()
    if not CONFIG.autoTouch then return end
    if not State.reachCube or not State.reachCube.Parent then return end

    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = {char, State.reachCube}
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.MaxParts = 100

    local parts = Workspace:GetPartBoundsInBox(State.reachCube.CFrame, State.reachCube.Size, overlap)

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and not part.Anchored then
            local model = part:FindFirstAncestorOfClass("Model")
            if model and model ~= char then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum or part.Name:lower():match("ball") or part.Name:lower():match("soccer") then
                    pcall(function()
                        firetouchinterest(part, root, 0)
                        firetouchinterest(part, root, 1)
                    end)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════
--  GUI PRINCIPAL (Junkie Style)
-- ═══════════════════════════════════════════════════
local function buildGUI()
    if State.gui then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KavroyxGK_Hub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    State.gui = gui

    -- Main
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 370, 0, 370)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = STYLE.bg
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = main

    -- Top Bar
    local top = Instance.new("Frame")
    top.Name = "Top"
    top.Size = UDim2.new(1, 0, 0, 35)
    top.BackgroundColor3 = STYLE.top
    top.BorderSizePixel = 0
    top.Parent = main

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 10)
    topCorner.Parent = top

    local topCover = Instance.new("Frame")
    topCover.Size = UDim2.new(1, 0, 0, 20)
    topCover.Position = UDim2.new(0, 0, 1, -20)
    topCover.BackgroundColor3 = STYLE.top
    topCover.BorderSizePixel = 0
    topCover.Parent = top

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
    line.BorderSizePixel = 0
    line.Parent = top

    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 10, 0, 7)
    logo.BackgroundTransparency = 1
    logo.Image = STYLE.logo
    logo.ImageColor3 = STYLE.accent
    logo.Parent = top

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 35)
    title.Position = UDim2.new(0, 35, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KAVROYX GK HUB"
    title.TextColor3 = STYLE.text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    -- Close
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = STYLE.closeIcon
    closeBtn.ImageColor3 = STYLE.text
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = top

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -55)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Big Logo
    local bigLogo = Instance.new("ImageLabel")
    bigLogo.Size = UDim2.new(0, 50, 0, 50)
    bigLogo.Position = UDim2.new(0.5, -25, 0, 5)
    bigLogo.BackgroundTransparency = 1
    bigLogo.Image = STYLE.logo
    bigLogo.ImageColor3 = STYLE.accent
    bigLogo.Parent = content

    -- RGB Title
    local rgbTitle = Instance.new("TextLabel")
    rgbTitle.Size = UDim2.new(1, 0, 0, 28)
    rgbTitle.Position = UDim2.new(0, 0, 0, 58)
    rgbTitle.BackgroundTransparency = 1
    rgbTitle.Text = "GK REACH SYSTEM"
    rgbTitle.TextSize = 20
    rgbTitle.Font = Enum.Font.GothamBold
    rgbTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
    rgbTitle.TextXAlignment = Enum.TextXAlignment.Center
    rgbTitle.Parent = content

    -- RGB Animation
    local hue = 0
    local rgbConn = RunService.RenderStepped:Connect(function()
        hue = (hue + 0.015) % 1
        rgbTitle.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end)
    table.insert(State.connections, rgbConn)

    -- Reach Label (Junkie input style)
    local reachFrame = Instance.new("Frame")
    reachFrame.Size = UDim2.new(0.9, 0, 0, 35)
    reachFrame.Position = UDim2.new(0.5, 0, 0, 95)
    reachFrame.AnchorPoint = Vector2.new(0.5, 0)
    reachFrame.BackgroundColor3 = STYLE.input
    reachFrame.BackgroundTransparency = 0.3
    reachFrame.BorderSizePixel = 0
    reachFrame.Parent = content

    local reachStroke = Instance.new("UIStroke")
    reachStroke.Color = STYLE.accent
    reachStroke.Thickness = 1
    reachStroke.Transparency = 0.5
    reachStroke.Parent = reachFrame

    local reachCorner = Instance.new("UICorner")
    reachCorner.CornerRadius = UDim.new(0, 6)
    reachCorner.Parent = reachFrame

    local reachLabel = Instance.new("TextLabel")
    reachLabel.Size = UDim2.new(1, 0, 1, 0)
    reachLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    reachLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "Reach: " .. CONFIG.reach
    reachLabel.TextColor3 = STYLE.text
    reachLabel.TextSize = 14
    reachLabel.Font = Enum.Font.Gotham
    reachLabel.TextXAlignment = Enum.TextXAlignment.Center
    reachLabel.Parent = reachFrame
    State.reachLabel = reachLabel

    -- Buttons Container
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0.9, 0, 0, 35)
    btnContainer.Position = UDim2.new(0.5, 0, 0, 138)
    btnContainer.AnchorPoint = Vector2.new(0.5, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = content

    -- Minus
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0.3, -4, 1, 0)
    minusBtn.Position = UDim2.new(0.17, 0, 0, 0)
    minusBtn.AnchorPoint = Vector2.new(0.5, 0)
    minusBtn.BackgroundColor3 = STYLE.btn
    minusBtn.BorderSizePixel = 0
    minusBtn.Text = "−"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.TextSize = 18
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.AutoButtonColor = false
    minusBtn.Parent = btnContainer
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 8)
    mc.Parent = minusBtn

    -- Plus
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0.3, -4, 1, 0)
    plusBtn.Position = UDim2.new(0.5, 0, 0, 0)
    plusBtn.AnchorPoint = Vector2.new(0.5, 0)
    plusBtn.BackgroundColor3 = STYLE.btn
    plusBtn.BorderSizePixel = 0
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.TextSize = 18
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.AutoButtonColor = false
    plusBtn.Parent = btnContainer
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 8)
    pc.Parent = plusBtn

    -- Toggle Cube
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.3, -4, 1, 0)
    toggleBtn.Position = UDim2.new(0.83, 0, 0, 0)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0)
    toggleBtn.BackgroundColor3 = STYLE.btn
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = btnContainer
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 8)
    tc.Parent = toggleBtn

    -- ═══════════════════════════════════════════════════
    --  INPUT DE COR RGB
    -- ═══════════════════════════════════════════════════
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(1, 0, 0, 18)
    colorLabel.Position = UDim2.new(0, 0, 0, 182)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "🎨 BORDER COLOR (R, G, B)"
    colorLabel.TextColor3 = STYLE.sub
    colorLabel.TextSize = 11
    colorLabel.Font = Enum.Font.GothamBold
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = content

    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0.9, 0, 0, 32)
    colorFrame.Position = UDim2.new(0.5, 0, 0, 202)
    colorFrame.AnchorPoint = Vector2.new(0.5, 0)
    colorFrame.BackgroundColor3 = STYLE.input
    colorFrame.BackgroundTransparency = 0.3
    colorFrame.BorderSizePixel = 0
    colorFrame.Parent = content

    local colorStroke = Instance.new("UIStroke")
    colorStroke.Color = STYLE.accent
    colorStroke.Thickness = 1
    colorStroke.Transparency = 0.5
    colorStroke.Parent = colorFrame

    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 6)
    colorCorner.Parent = colorFrame

    local colorBox = Instance.new("TextBox")
    colorBox.Size = UDim2.new(1, -10, 1, 0)
    colorBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    colorBox.AnchorPoint = Vector2.new(0.5, 0.5)
    colorBox.BackgroundTransparency = 1
    colorBox.Text = "255, 255, 0"
    colorBox.PlaceholderText = "255, 255, 0"
    colorBox.PlaceholderColor3 = Color3.fromRGB(100, 120, 150)
    colorBox.TextColor3 = STYLE.text
    colorBox.TextSize = 13
    colorBox.Font = Enum.Font.Code
    colorBox.ClearTextOnFocus = false
    colorBox.Parent = colorFrame
    State.colorBox = colorBox

    -- Preview da cor
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 28, 0, 28)
    colorPreview.Position = UDim2.new(1, -34, 0.5, -14)
    colorPreview.AnchorPoint = Vector2.new(0, 0)
    colorPreview.BackgroundColor3 = CONFIG.cubeColor
    colorPreview.BorderSizePixel = 0
    colorPreview.Parent = colorFrame
    local cpCorner = Instance.new("UICorner")
    cpCorner.CornerRadius = UDim.new(0, 4)
    cpCorner.Parent = colorPreview

    -- Botão Apply
    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(0.9, 0, 0, 30)
    applyBtn.Position = UDim2.new(0.5, 0, 0, 242)
    applyBtn.AnchorPoint = Vector2.new(0.5, 0)
    applyBtn.BackgroundColor3 = STYLE.btn
    applyBtn.BorderSizePixel = 0
    applyBtn.Text = "APPLY COLOR"
    applyBtn.TextColor3 = Color3.new(1, 1, 1)
    applyBtn.TextSize = 12
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.AutoButtonColor = false
    applyBtn.Parent = content
    local abc = Instance.new("UICorner")
    abc.CornerRadius = UDim.new(0, 8)
    abc.Parent = applyBtn

    -- Show/Hide
    local showBtn = Instance.new("TextButton")
    showBtn.Size = UDim2.new(0.9, 0, 0, 35)
    showBtn.Position = UDim2.new(0.5, 0, 0, 280)
    showBtn.AnchorPoint = Vector2.new(0.5, 0)
    showBtn.BackgroundColor3 = STYLE.btn
    showBtn.BorderSizePixel = 0
    showBtn.Text = "SHOW / HIDE MENU"
    showBtn.TextColor3 = Color3.new(1, 1, 1)
    showBtn.TextSize = 12
    showBtn.Font = Enum.Font.GothamBold
    showBtn.AutoButtonColor = false
    showBtn.Parent = content
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 8)
    sc.Parent = showBtn

    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 322)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: ONLINE | Press K to toggle"
    statusLabel.TextColor3 = STYLE.sub
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = content

    -- ═══════════════════════════════════════════════════
    --  EVENTOS
    -- ═══════════════════════════════════════════════════

    local function pulse(btn)
        local orig = btn.BackgroundColor3
        local pop = Color3.new(math.min(orig.R * 1.3, 1), math.min(orig.G * 1.3, 1), math.min(orig.B * 1.3, 1))
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = pop}):Play()
        task.wait(0.15)
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = orig}):Play()
    end

    -- Parse cor RGB
    local function parseColor(text)
        local r, g, b = text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then
            return Color3.fromRGB(
                math.clamp(tonumber(r), 0, 255),
                math.clamp(tonumber(g), 0, 255),
                math.clamp(tonumber(b), 0, 255)
            )
        end
        return nil
    end

    local function applyColor()
        local color = parseColor(colorBox.Text)
        if color then
            CONFIG.cubeColor = color
            updateCubeColor()
            colorPreview.BackgroundColor3 = color
            notify("Color Applied", string.format("R:%d G:%d B:%d", color.R * 255, color.G * 255, color.B * 255), 2, STYLE.logo)
        else
            notify("Invalid Color", "Use format: 255, 255, 0", 2, STYLE.closeIcon)
        end
    end

    minusBtn.MouseButton1Click:Connect(function()
        if not canRun("minus") then return end
        pulse(minusBtn)
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        reachLabel.Text = "Reach: " .. CONFIG.reach
        updateCube()
        notify("Reach Updated", "Reach: " .. CONFIG.reach, 2, STYLE.logo)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        if not canRun("plus") then return end
        pulse(plusBtn)
        CONFIG.reach += 1
        reachLabel.Text = "Reach: " .. CONFIG.reach
        updateCube()
        notify("Reach Updated", "Reach: " .. CONFIG.reach, 2, STYLE.logo)
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        if not canRun("toggle") then return end
        pulse(toggleBtn)
        CONFIG.showReachCube = not CONFIG.showReachCube
        updateCube()
        if CONFIG.showReachCube then
            notify("Cube", "GK Borders: ENABLED", 2, STYLE.logo)
        else
            notify("Cube", "GK Borders: DISABLED", 2, STYLE.logo)
        end
    end)

    applyBtn.MouseButton1Click:Connect(function()
        if not canRun("apply") then return end
        pulse(applyBtn)
        applyColor()
    end)

    colorBox.FocusLost:Connect(function(enter)
        if enter then
            applyColor()
        end
    end)

    showBtn.MouseButton1Click:Connect(function()
        if not canRun("show") then return end
        pulse(showBtn)
        State.menuVisible = false
        main.Visible = false
        notify("Menu Hidden", "Press K to show menu", 2, STYLE.logo)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        notify("Closing...", "See you next time!", 2, STYLE.closeIcon)
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, -0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        gui:Destroy()
        State.gui = nil
    end)

    -- Hover
    for _, btn in ipairs({minusBtn, plusBtn, toggleBtn, applyBtn, showBtn}) do
        btn.MouseEnter:Connect(function()
            local orig = btn.BackgroundColor3
            local bright = Color3.new(math.min(orig.R * 1.15, 1), math.min(orig.G * 1.15, 1), math.min(orig.B * 1.15, 1))
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bright}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = STYLE.btn}):Play()
        end)
    end

    -- Drag
    local dragInput, dragStart, startPos
    top.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragInput = inp
            dragStart = inp.Position
            startPos = main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════
--  TOGGLE MENU
-- ═══════════════════════════════════════════════════
local function toggleMenu()
    if not State.gui then
        buildGUI()
        return
    end
    local frame = State.gui:FindFirstChild("Main")
    if not frame then return end
    State.menuVisible = not State.menuVisible
    frame.Visible = State.menuVisible
    notify(State.menuVisible and "Menu: VISIBLE" or "Menu: HIDDEN | Press K", 1.5, STYLE.logo)
end

-- ═══════════════════════════════════════════════════
--  INPUT
-- ═══════════════════════════════════════════════════
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.guiKey then
        toggleMenu()
    end
end

-- ═══════════════════════════════════════════════════
--  CHARACTER
-- ═══════════════════════════════════════════════════
local function onCharacterAdded(char)
    task.delay(0.5, function()
        updateCube()
    end)
end

-- ═══════════════════════════════════════════════════
--  LOOPS
-- ═══════════════════════════════════════════════════
local touchConn = RunService.RenderStepped:Connect(function()
    processTouch()
end)
table.insert(State.connections, touchConn)

local inputConn = UserInputService.InputBegan:Connect(onInputBegan)
table.insert(State.connections, inputConn)

local charConn = player.CharacterAdded:Connect(onCharacterAdded)
table.insert(State.connections, charConn)

-- ═══════════════════════════════════════════════════
--  INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════
buildGUI()
updateCube()

notify("✅ Kavroyx GK Hub V3", "Yellow borders! Type RGB to change color.", 3, STYLE.logo)
print("[Kavroyx GK] Hub V3 inicializado com sucesso.")
