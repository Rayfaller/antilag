-- ═══════════════════════════════════════════════════
--  KAVROYX HUB V11 — Reach & Ball Touch System
--  Estilo: Junkie Key System (Dark Theme)
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
--  CONFIGURAÇÕES DE ESTILO (Junkie Style)
-- ═══════════════════════════════════════════════════
local STYLE = {
    -- Cores principais (estilo Junkie)
    bgColor = Color3.fromRGB(20, 30, 50),
    topColor = Color3.fromRGB(30, 60, 100),
    inputBg = Color3.fromRGB(15, 35, 65),
    btnColor = Color3.fromRGB(30, 80, 150),
    btnHover = Color3.fromRGB(40, 100, 180),
    accentColor = Color3.fromRGB(90, 170, 255),
    textColor = Color3.fromRGB(200, 230, 255),
    subTextColor = Color3.fromRGB(150, 170, 200),

    -- Bordas e cantos
    cornerRadius = UDim.new(0, 10),
    btnCornerRadius = UDim.new(0, 8),
    inputCornerRadius = UDim.new(0, 6),

    -- Logo e imagens
    logoId = "rbxassetid://88380080222477",
    closeIcon = "rbxassetid://122931434733842",

    -- Fontes
    titleFont = Enum.Font.GothamBold,
    textFont = Enum.Font.Gotham,
    codeFont = Enum.Font.Code,
}

-- ═══════════════════════════════════════════════════
--  CONFIGURAÇÕES DO SISTEMA
-- ═══════════════════════════════════════════════════
local CONFIG = {
    reach = 10,
    magnetStrength = 0,
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 1.5,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS", "SSS", "AIFA", "RBZ" },
    guiKey = Enum.KeyCode.K,
    debounceTime = 0.2,
    sphereTransparency = 0.85,
    sphereColor = Color3.fromRGB(90, 170, 255),
}

-- ═══════════════════════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════════════════════
local State = {
    balls = {},
    lastRefresh = 0,
    reachSphere = nil,
    gui = nil,
    reachLabel = nil,
    menuVisible = true,
    debounces = {},
    connections = {},
    notifActive = {},
    notifGui = nil,
}

-- BALL NAME SET (O(1) lookup)
local BALL_NAME_SET = {}
for _, name in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[name] = true
end

-- ═══════════════════════════════════════════════════
--  FUNÇÕES UTILITÁRIAS
-- ═══════════════════════════════════════════════════

local function canRun(key, cooldown)
    local now = tick()
    if not State.debounces[key] or (now - State.debounces[key]) >= (cooldown or CONFIG.debounceTime) then
        State.debounces[key] = now
        return true
    end
    return false
end

local function tween(obj, props, duration, easing, direction)
    local info = TweenInfo.new(
        duration or 0.3,
        easing or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- ═══════════════════════════════════════════════════
--  SISTEMA DE NOTIFICAÇÕES (Estilo Junkie)
-- ═══════════════════════════════════════════════════

local function createNotification(title, content, length, iconId)
    local screen = Instance.new("ScreenGui")
    screen.Name = "KavroyxNotif_" .. tostring(math.floor(tick() * 1000))
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 2147483647
    screen.Parent = CoreGui

    local scale = math.clamp(math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y) / 1366, 0.6, 1.6)
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
    bar.BackgroundColor3 = STYLE.accentColor
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = true
    bar.Parent = main

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 2)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = STYLE.accentColor
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, h, 1, 0)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or STYLE.logoId
    icon.ImageColor3 = STYLE.accentColor
    icon.ScaleType = Enum.ScaleType.Stretch
    icon.Parent = main

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.new(1, -h - 8, 0.4, 0)
    txt.Position = UDim2.new(0, h + 8, 0, 0)
    txt.Font = STYLE.codeFont
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
    sub.Font = STYLE.codeFont
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
--  SCAN DE BOLAS
-- ═══════════════════════════════════════════════════

local function refreshBalls(force)
    if not force and (tick() - State.lastRefresh) < CONFIG.scanCooldown then
        return
    end
    State.lastRefresh = tick()
    table.clear(State.balls)

    local descendants = Workspace:GetDescendants()
    for i = 1, #descendants do
        local obj = descendants[i]
        if obj:IsA("BasePart") and BALL_NAME_SET[obj.Name] then
            table.insert(State.balls, obj)
        end
    end
end

-- ═══════════════════════════════════════════════════
--  PARTES DO CORPO
-- ═══════════════════════════════════════════════════

local function getValidParts(character)
    local parts = {}
    if not character then return parts end

    local children = character:GetChildren()
    for i = 1, #children do
        local child = children[i]
        if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            table.insert(parts, child)
        end
    end
    return parts
end

-- ═══════════════════════════════════════════════════
--  REACH SPHERE
-- ═══════════════════════════════════════════════════

local function destroyReachSphere()
    if State.reachSphere and State.reachSphere.Parent then
        pcall(function()
            State.reachSphere:Destroy()
        end)
    end
    State.reachSphere = nil
end

local function createReachSphere()
    destroyReachSphere()

    if not CONFIG.showReachSphere then
        return
    end

    local sphere = Instance.new("Part")
    sphere.Name = "KavroyxReachSphere"
    sphere.Shape = Enum.PartType.Ball
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.CanQuery = false
    sphere.CanTouch = false
    sphere.Transparency = CONFIG.sphereTransparency
    sphere.Material = Enum.Material.ForceField
    sphere.Color = CONFIG.sphereColor
    sphere.CastShadow = false
    sphere.Parent = Workspace

    State.reachSphere = sphere

    local conn = RunService.RenderStepped:Connect(function()
        if not State.reachSphere or not State.reachSphere.Parent then
            return
        end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            State.reachSphere.Position = hrp.Position
        end
    end)
    table.insert(State.connections, conn)
end

local function updateReachSphereSize()
    if State.reachSphere and State.reachSphere.Parent then
        local size = CONFIG.reach * 2
        State.reachSphere.Size = Vector3.new(size, size, size)
    end
end

local function updateReachSphere()
    if not CONFIG.showReachSphere then
        destroyReachSphere()
        return
    end

    if not State.reachSphere or not State.reachSphere.Parent then
        createReachSphere()
    end
    updateReachSphereSize()
end

-- ═══════════════════════════════════════════════════
--  GUI PRINCIPAL (Estilo Junkie)
-- ═══════════════════════════════════════════════════

local function buildGUI()
    if State.gui then
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KavroyxHubGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    State.gui = gui

    -- Frame principal (estilo Junkie)
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 370, 0, 320)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = STYLE.bgColor
    main.BackgroundTransparency = 0
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = STYLE.cornerRadius
    mainCorner.Parent = main

    -- Barra superior (estilo Junkie)
    local top = Instance.new("Frame")
    top.Name = "Top"
    top.Size = UDim2.new(1, 0, 0, 35)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BackgroundColor3 = STYLE.topColor
    top.BorderSizePixel = 0
    top.Parent = main

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = STYLE.cornerRadius
    topCorner.Parent = top

    local topCover = Instance.new("Frame")
    topCover.Name = "TopCover"
    topCover.Size = UDim2.new(1, 0, 0, 20)
    topCover.Position = UDim2.new(0, 0, 1, -20)
    topCover.BackgroundColor3 = STYLE.topColor
    topCover.BorderSizePixel = 0
    topCover.Parent = top

    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(25, 50, 90)
    line.BorderSizePixel = 0
    line.Parent = top

    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 10, 0, 7)
    logo.BackgroundTransparency = 1
    logo.Image = STYLE.logoId
    logo.ImageColor3 = STYLE.accentColor
    logo.Parent = top

    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 200, 0, 35)
    title.Position = UDim2.new(0, 35, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KAVROYX HUB"
    title.TextColor3 = STYLE.textColor
    title.TextSize = 18
    title.Font = STYLE.titleFont
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    -- Botão fechar
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = STYLE.closeIcon
    closeBtn.ImageColor3 = STYLE.textColor
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = top

    -- Área de conteúdo
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -55)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Logo grande
    local bigLogo = Instance.new("ImageLabel")
    bigLogo.Name = "BigLogo"
    bigLogo.Size = UDim2.new(0, 60, 0, 60)
    bigLogo.Position = UDim2.new(0.5, -30, 0, 5)
    bigLogo.BackgroundTransparency = 1
    bigLogo.Image = STYLE.logoId
    bigLogo.ImageColor3 = STYLE.accentColor
    bigLogo.Parent = content

    -- Título RGB animado
    local rgbTitle = Instance.new("TextLabel")
    rgbTitle.Name = "RGBTitle"
    rgbTitle.Size = UDim2.new(1, 0, 0, 28)
    rgbTitle.Position = UDim2.new(0, 0, 0, 70)
    rgbTitle.BackgroundTransparency = 1
    rgbTitle.Text = "REACH SYSTEM"
    rgbTitle.TextSize = 20
    rgbTitle.Font = STYLE.titleFont
    rgbTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
    rgbTitle.TextXAlignment = Enum.TextXAlignment.Center
    rgbTitle.Parent = content

    -- Animação RGB
    local hue = 0
    local rgbConn = RunService.RenderStepped:Connect(function()
        hue = (hue + 0.015) % 1
        rgbTitle.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end)
    table.insert(State.connections, rgbConn)

    -- Label Reach (estilo input Junkie)
    local reachFrame = Instance.new("Frame")
    reachFrame.Name = "ReachFrame"
    reachFrame.Size = UDim2.new(0.9, 0, 0, 35)
    reachFrame.Position = UDim2.new(0.5, 0, 0, 105)
    reachFrame.AnchorPoint = Vector2.new(0.5, 0)
    reachFrame.BackgroundColor3 = STYLE.inputBg
    reachFrame.BackgroundTransparency = 0.3
    reachFrame.BorderSizePixel = 0
    reachFrame.Parent = content

    local reachStroke = Instance.new("UIStroke")
    reachStroke.Color = STYLE.accentColor
    reachStroke.Thickness = 1
    reachStroke.Transparency = 0.5
    reachStroke.Parent = reachFrame

    local reachCorner = Instance.new("UICorner")
    reachCorner.CornerRadius = STYLE.inputCornerRadius
    reachCorner.Parent = reachFrame

    local reachLabel = Instance.new("TextLabel")
    reachLabel.Name = "ReachLabel"
    reachLabel.Size = UDim2.new(1, 0, 1, 0)
    reachLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    reachLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "Reach: " .. CONFIG.reach
    reachLabel.TextColor3 = STYLE.textColor
    reachLabel.TextSize = 14
    reachLabel.Font = STYLE.textFont
    reachLabel.TextXAlignment = Enum.TextXAlignment.Center
    reachLabel.Parent = reachFrame
    State.reachLabel = reachLabel

    -- Botões de controle (estilo Junkie)
    local btnContainer = Instance.new("Frame")
    btnContainer.Name = "BtnContainer"
    btnContainer.Size = UDim2.new(0.9, 0, 0, 35)
    btnContainer.Position = UDim2.new(0.5, 0, 0, 150)
    btnContainer.AnchorPoint = Vector2.new(0.5, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = content

    -- Botão -
    local minusBtn = Instance.new("TextButton")
    minusBtn.Name = "Minus"
    minusBtn.Size = UDim2.new(0.3, -4, 1, 0)
    minusBtn.Position = UDim2.new(0.17, 0, 0, 0)
    minusBtn.AnchorPoint = Vector2.new(0.5, 0)
    minusBtn.BackgroundColor3 = STYLE.btnColor
    minusBtn.BorderSizePixel = 0
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.TextSize = 18
    minusBtn.Font = STYLE.titleFont
    minusBtn.AutoButtonColor = false
    minusBtn.Parent = btnContainer

    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = STYLE.btnCornerRadius
    minusCorner.Parent = minusBtn

    -- Botão +
    local plusBtn = Instance.new("TextButton")
    plusBtn.Name = "Plus"
    plusBtn.Size = UDim2.new(0.3, -4, 1, 0)
    plusBtn.Position = UDim2.new(0.5, 0, 0, 0)
    plusBtn.AnchorPoint = Vector2.new(0.5, 0)
    plusBtn.BackgroundColor3 = STYLE.btnColor
    plusBtn.BorderSizePixel = 0
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.TextSize = 18
    plusBtn.Font = STYLE.titleFont
    plusBtn.AutoButtonColor = false
    plusBtn.Parent = btnContainer

    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = STYLE.btnCornerRadius
    plusCorner.Parent = plusBtn

    -- Botão Toggle Sphere
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleSphere"
    toggleBtn.Size = UDim2.new(0.3, -4, 1, 0)
    toggleBtn.Position = UDim2.new(0.83, 0, 0, 0)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 0)
    toggleBtn.BackgroundColor3 = STYLE.btnColor
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "👁"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextSize = 16
    toggleBtn.Font = STYLE.titleFont
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = btnContainer

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = STYLE.btnCornerRadius
    toggleCorner.Parent = toggleBtn

    -- Botão SHOW/HIDE (estilo Junkie)
    local showBtn = Instance.new("TextButton")
    showBtn.Name = "ShowBtn"
    showBtn.Size = UDim2.new(0.9, 0, 0, 35)
    showBtn.Position = UDim2.new(0.5, 0, 0, 195)
    showBtn.AnchorPoint = Vector2.new(0.5, 0)
    showBtn.BackgroundColor3 = STYLE.btnColor
    showBtn.BorderSizePixel = 0
    showBtn.Text = "SHOW / HIDE MENU"
    showBtn.TextColor3 = Color3.new(1, 1, 1)
    showBtn.TextSize = 12
    showBtn.Font = STYLE.titleFont
    showBtn.AutoButtonColor = false
    showBtn.Parent = content

    local showCorner = Instance.new("UICorner")
    showCorner.CornerRadius = STYLE.btnCornerRadius
    showCorner.Parent = showBtn

    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 240)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: ONLINE | Press K to toggle"
    statusLabel.TextColor3 = STYLE.subTextColor
    statusLabel.TextSize = 11
    statusLabel.Font = STYLE.codeFont
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = content

    -- ═══════════════════════════════════════════════════
    --  EVENTOS DOS BOTÕES
    -- ═══════════════════════════════════════════════════

    local function pulse(btn)
        local orig = btn.BackgroundColor3
        local pop = Color3.new(math.min(orig.R * 1.3, 1), math.min(orig.G * 1.3, 1), math.min(orig.B * 1.3, 1))
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = pop}):Play()
        task.wait(0.15)
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundColor3 = orig}):Play()
    end

    minusBtn.MouseButton1Click:Connect(function()
        if not canRun("minus") then return end
        pulse(minusBtn)
        CONFIG.reach = math.max(1, CONFIG.reach - 1)
        reachLabel.Text = "Reach: " .. CONFIG.reach
        updateReachSphere()
        createNotification("Reach Updated", "Reach: " .. CONFIG.reach, 2, STYLE.logoId)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        if not canRun("plus") then return end
        pulse(plusBtn)
        CONFIG.reach += 1
        reachLabel.Text = "Reach: " .. CONFIG.reach
        updateReachSphere()
        createNotification("Reach Updated", "Reach: " .. CONFIG.reach, 2, STYLE.logoId)
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        if not canRun("toggle") then return end
        pulse(toggleBtn)
        CONFIG.showReachSphere = not CONFIG.showReachSphere
        updateReachSphere()
        if CONFIG.showReachSphere then
            createNotification("Sphere", "Reach sphere: ENABLED", 2, STYLE.logoId)
        else
            createNotification("Sphere", "Reach sphere: DISABLED", 2, STYLE.logoId)
        end
    end)

    showBtn.MouseButton1Click:Connect(function()
        if not canRun("show") then return end
        pulse(showBtn)
        State.menuVisible = false
        main.Visible = false
        createNotification("Menu Hidden", "Press K to show menu", 2, STYLE.logoId)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        createNotification("Closing...", "See you next time!", 2, STYLE.closeIcon)
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, -0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        gui:Destroy()
        State.gui = nil
    end)

    -- Hover effects (estilo Junkie)
    for _, btn in ipairs({minusBtn, plusBtn, toggleBtn, showBtn}) do
        btn.MouseEnter:Connect(function()
            local orig = btn.BackgroundColor3
            local bright = Color3.new(math.min(orig.R * 1.15, 1), math.min(orig.G * 1.15, 1), math.min(orig.B * 1.15, 1))
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bright}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = STYLE.btnColor}):Play()
        end)
    end

    -- Drag system
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

    local main = State.gui:FindFirstChild("Main")
    if not main then return end

    State.menuVisible = not State.menuVisible
    main.Visible = State.menuVisible

    if State.menuVisible then
        createNotification("Menu", "Menu: VISIBLE", 1.5, STYLE.logoId)
    else
        createNotification("Menu", "Menu: HIDDEN | Press K", 1.5, STYLE.logoId)
    end
end

-- ═══════════════════════════════════════════════════
--  AUTO TOUCH / REACH
-- ═══════════════════════════════════════════════════

local function processTouch()
    if not CONFIG.autoSecondTouch then
        return
    end

    local char = player.Character
    if not char then return end

    local parts = getValidParts(char)
    if #parts == 0 then return end

    local balls = State.balls
    if #balls == 0 then return end

    for p = 1, #parts do
        local part = parts[p]
        if not part or not part.Parent then continue end

        for b = 1, #balls do
            local ball = balls[b]
            if not ball or not ball.Parent then continue end

            local dist = (ball.Position - part.Position).Magnitude
            if dist <= CONFIG.reach then
                pcall(function()
                    firetouchinterest(ball, part, 0)
                    firetouchinterest(ball, part, 1)
                end)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════
--  INPUT HANDLER
-- ═══════════════════════════════════════════════════

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == CONFIG.guiKey then
        toggleMenu()
    end
end

-- ═══════════════════════════════════════════════════
--  CHARACTER HANDLER
-- ═══════════════════════════════════════════════════

local function onCharacterAdded(char)
    task.delay(0.5, function()
        updateReachSphere()
    end)
end

-- ═══════════════════════════════════════════════════
--  LOOPS
-- ═══════════════════════════════════════════════════

local touchConn = RunService.RenderStepped:Connect(function()
    processTouch()
end)
table.insert(State.connections, touchConn)

local scanConn = RunService.Heartbeat:Connect(function()
    refreshBalls(false)
end)
table.insert(State.connections, scanConn)

local inputConn = UserInputService.InputBegan:Connect(onInputBegan)
table.insert(State.connections, inputConn)

local charConn = player.CharacterAdded:Connect(onCharacterAdded)
table.insert(State.connections, charConn)

-- ═══════════════════════════════════════════════════
--  INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════

buildGUI()
updateReachSphere()
refreshBalls(true)

createNotification("✅ Kavroyx Hub V11", "Reach system online! Press K to toggle", 3, STYLE.logoId)
print("[Kavroyx] Hub V11 inicializado com sucesso.")
 
