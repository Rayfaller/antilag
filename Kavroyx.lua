-- ═══════════════════════════════════════════════════════════════
--  CAFUXZ1 HUB v16.0 - PARTE 1/5
--  Sistema Base | UI Library (WindUI) | Configurações Globais
--  Baseado na arquitetura RedzLibV5
-- ═══════════════════════════════════════════════════════════════

if not game:IsLoaded() then game.Loaded:Wait() end

local CAFUXZ1 = {}
local CFX = (getgenv and getgenv()) or (getrenv and getrenv()) or getfenv()

-- ═══════════════════════════════════════════════════════════════
--  SERVIÇOS DO ROBLOX
-- ═══════════════════════════════════════════════════════════════

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    CoreGui = game:GetService("CoreGui"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    CollectionService = game:GetService("CollectionService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TeleportService = game:GetService("TeleportService"),
    StarterGui = game:GetService("StarterGui"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════
--  CONFIGURAÇÕES GLOBAIS (vu38 equivalente)
-- ═══════════════════════════════════════════════════════════════

CFX.Settings = CFX.CFX_Settings or {
    -- Farm/Kick Settings
    AutoFarm = false,
    FarmMode = "Up",
    FarmDistance = 15,
    FarmPos = Vector3.new(0, 15, 0),
    BringMobs = true,
    BringDistance = 250,
    
    -- GK Settings
    GK_Enabled = false,
    GK_Size = Vector3.new(6, 12, 6),
    GK_Transparency = 1,
    GK_BorderOnly = true,
    GK_Position = "Behind",
    
    -- Ball Settings
    Ball_Color = Color3.fromRGB(255, 255, 255),
    Ball_Glow = false,
    Ball_Trail = false,
    
    -- Curved Kick
    CurvedKick = true,
    CurveIntensity = 1.5,
    CurveRandomness = 0.3,
    
    -- Screen Stretch
    Stretch_Enabled = false,
    Stretch_Resolution = 0.5,
    RemoveTextures = true,
    OptimizeMaterials = true,
    
    -- Auto Catch
    AutoCatch = false,
    CatchRange = 15,
    
    -- Visual
    ESP_Enabled = false,
    ESP_Ball = true,
    ESP_Players = false,
    ESP_GK = true,
    
    -- Misc
    UIScale = "Large",
    MinimizeKey = Enum.KeyCode.RightShift,
    Theme = "Dark",
}

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE OPÇÕES ATIVAS (vu45 equivalente)
-- ═══════════════════════════════════════════════════════════════

CFX.Enabled = CFX.CFX_Enabled or setmetatable({}, {
    __newindex = function(_, key, value)
        rawset(CFX.Enabled_Raw or {}, key, value or nil)
        table.clear(CFX.KickFunctions or {})
        local funcs = CFX.Functions or {}
        for _, funcData in ipairs(funcs) do
            if rawget(CFX.Enabled_Raw or {}, funcData.Name) then
                table.insert(CFX.KickFunctions or {}, funcData)
            end
        end
    end,
    __index = CFX.Enabled_Raw or {}
})

CFX.Enabled_Raw = CFX.Enabled_Raw or {}
CFX.Functions = CFX.Functions or {}
CFX.KickFunctions = CFX.KickFunctions or {}

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE CONEXÕES (vu76 equivalente)
-- ═══════════════════════════════════════════════════════════════

CFX.Connections = CFX.CFX_Connections or {}
local Connections = CFX.Connections

local function ClearConnections()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
end

local function AddConnection(conn)
    table.insert(Connections, conn)
    return conn
end

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE HTTP / LOADSTRING (vu33/vu55 equivalente)
-- ═══════════════════════════════════════════════════════════════

local function GetExecutor()
    return identifyexecutor and identifyexecutor() or "Unknown"
end

local function CFX_Error(msg)
    CFX.CFX_OnFarm = false
    CFX.CFX_loadedFarm = nil
    local errorMsg = Instance.new("Message", Services.Workspace)
    errorMsg.Text = "[CAFUXZ1] ERROR: " .. msg
    CFX.CFX_ErrorMsg = errorMsg
    return error(msg, 2)
end

function CFX_HttpGet(url)
    local success, result = pcall(game.HttpGet, game, url)
    if success then
        return result, url
    else
        return CFX_Error(string.format("[HTTP] [%s] Falha ao carregar: %s\n{{ %s }}", GetExecutor(), url, result))
    end
end

function CFX_Loadstring(url, append, args)
    local source, srcUrl = CFX_HttpGet(url)
    local func, err = loadstring(source .. (append or ""))
    if type(func) ~= "function" then
        return CFX_Error(string.format("[LOADSTRING] [%s] Erro de sintaxe: %s\n{{ %s }}", GetExecutor(), srcUrl, err))
    end
    local success, result
    if args then
        success, result = pcall(func, unpack(args))
    else
        success, result = pcall(func)
    end
    if success then
        return result
    else
        CFX_Error(string.format("[EXECUTE] [%s] Erro: %s\n{{ %s }}", GetExecutor(), srcUrl, result))
    end
end

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE TWEEN CUSTOM (vu104 equivalente)
-- ═══════════════════════════════════════════════════════════════

local TweenSystem = {}
TweenSystem.__index = TweenSystem
local ActiveTweens = {}

function TweenSystem.new(obj, time, prop, value, easingStyle)
    local self = setmetatable({}, TweenSystem)
    easingStyle = easingStyle or Enum.EasingStyle.Linear
    self.tween = Services.TweenService:Create(obj, TweenInfo.new(time, easingStyle), { [prop] = value })
    self.tween:Play()
    self.value = value
    self.object = obj
    if ActiveTweens[obj] then
        ActiveTweens[obj]:destroy()
    end
    ActiveTweens[obj] = self
    return self
end

function TweenSystem:destroy()
    if self.tween then
        self.tween:Pause()
        self.tween:Destroy()
    end
    ActiveTweens[self.object] = nil
    setmetatable(self, nil)
end

function TweenSystem.stop(obj)
    if ActiveTweens[obj] then
        ActiveTweens[obj]:destroy()
    end
end

-- ═══════════════════════════════════════════════════════════════
--  WINDUI LIBRARY INTEGRATION (vu81 equivalente)
--  Carrega a UI library personalizada
-- ═══════════════════════════════════════════════════════════════

local WindUI = nil
local CFXModule = nil

-- URLs da library (pode ser substituído por loadstring local)
local CFX_Urls = {
    Owner = "https://raw.githubusercontent.com/Rayfaller/",
    Repository = "https://raw.githubusercontent.com/Rayfaller/antilag/refs/heads/main/",
    LibraryUrl = "https://raw.githubusercontent.com/Rayfaller/antilag/refs/heads/main/test.lua",
}

function CAFUXZ1.InitializeLibrary()
    -- Carrega a UI base (WindUI/RedzLibV5 adaptada)
    WindUI = CFX_Loadstring(CFX_Urls.LibraryUrl)
    
    -- Módulo de utilidades do CAFUXZ1
    CFXModule = {
        GameData = {
            Sea = 1,
            MaxLevel = 2550,
        },
        IsAlive = function(char)
            return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
        end,
        FireRemote = function(name, ...)
            local remote = Services.ReplicatedStorage:FindFirstChild(name, true)
            if remote then
                return remote:InvokeServer(...)
            end
        end,
        Inventory = {
            Count = {},
            Unlocked = {},
            Mastery = {},
        },
        Enemies = {
            IsSpawned = function(name) return true end,
        },
        RunFunctions = {
            FarmQueue = function(funcs)
                while CFX.CFX_OnFarm do
                    for _, funcData in ipairs(funcs) do
                        if CFX.Enabled[funcData.Name] then
                            local status, err = pcall(funcData.Function)
                            if not status then
                                warn("[CAFUXZ1] Farm error: " .. tostring(err))
                            end
                        end
                    end
                    task.wait()
                end
            end,
            LibraryToggle = function(enabledOptions, toggleRefs)
                return function(tab, config, optionKey)
                    local name = config[1]
                    local desc = config[2] or ""
                    local default = config[3] or false
                    
                    local toggle = tab:AddToggle({
                        Title = name,
                        Description = desc,
                        Default = CFX.Settings[optionKey] or default,
                        Callback = function(value)
                            CFX.Enabled[optionKey] = value
                            CFX.Settings[optionKey] = value
                        end
                    })
                    
                    toggleRefs[optionKey] = toggle
                    return toggle
                end
            end,
        },
    }
    
    CFX.WindUI = WindUI
    CFX.CFXModule = CFXModule
end

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE NOTIFICAÇÃO (vu101 equivalente)
-- ═══════════════════════════════════════════════════════════════

local NotifySystem = {
    Notifications = {},
    
    Send = function(title, text, duration, type)
        duration = duration or 3
        type = type or "Info"
        
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = title,
                Content = text,
                Duration = duration,
                Type = type
            })
        else
            -- Fallback
            local notif = Instance.new("ScreenGui")
            notif.Name = "CAFUXZ1_Notify"
            notif.Parent = Services.CoreGui
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 80)
            frame.Position = UDim2.new(1, -320, 0, 20 + (#NotifySystem.Notifications * 90))
            frame.BackgroundColor3 = type == "Error" and Color3.fromRGB(180, 50, 50) or 
                                      type == "Success" and Color3.fromRGB(50, 180, 80) or 
                                      Color3.fromRGB(40, 40, 60)
            frame.BorderSizePixel = 0
            frame.Parent = notif
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -20, 0, 25)
            titleLabel.Position = UDim2.new(0, 10, 0, 5)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = frame
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, -20, 0, 40)
            textLabel.Position = UDim2.new(0, 10, 0, 30)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = text
            textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            textLabel.Font = Enum.Font.Gotham
            textLabel.TextSize = 12
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.TextWrapped = true
            textLabel.Parent = frame
            
            table.insert(NotifySystem.Notifications, notif)
            
            task.delay(duration, function()
                pcall(function()
                    TweenSystem.new(frame, 0.5, "Position", UDim2.new(1, 0, frame.Position.Y.Scale, frame.Position.Y.Offset))
                    task.wait(0.5)
                    notif:Destroy()
                end)
                for i, n in ipairs(NotifySystem.Notifications) do
                    if n == notif then
                        table.remove(NotifySystem.Notifications, i)
                        break
                    end
                end
            end)
        end
    end,
}

-- ═══════════════════════════════════════════════════════════════
--  EXPORTAÇÃO GLOBAL
-- ═══════════════════════════════════════════════════════════════

CFX.CAFUXZ1 = CAFUXZ1
CFX.NotifySystem = NotifySystem
CFX.TweenSystem = TweenSystem
CFX.Services = Services
CFX.LocalPlayer = LocalPlayer
CFX.Camera = Camera
CFX.Mouse = Mouse

print("[CAFUXZ1] Parte 1/5 carregada com sucesso!")
print("[CAFUXZ1] Sistema Base + WindUI + Configurações inicializados.")

-- Retorna o controller para as próximas partes
return CAFUXZ1

-- ═══════════════════════════════════════════════════════════════
--  CAFUXZ1 HUB v16.0 - PARTE 2/5
--  Managers: CurvedKick | GK Reach | Ball System | Auto Catch
-- ═══════════════════════════════════════════════════════════════

local CFX = (getgenv and getgenv()) or (getrenv and getrenv()) or getfenv()
local CAFUXZ1 = CFX.CAFUXZ1
local Services = CFX.Services
local LocalPlayer = CFX.LocalPlayer
local TweenSystem = CFX.TweenSystem
local NotifySystem = CFX.NotifySystem

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: CURVED KICK SYSTEM (FarmManager equivalente)
-- ═══════════════════════════════════════════════════════════════

local CurvedKickManager = {}
local BallPhysics = {
    LastKickTime = 0,
    KickCooldown = 0.1,
    ActiveBalls = {},
}

function CurvedKickManager.Initialize()
    -- Detecta quando o jogador chuta a bola
    AddConnection = function(conn) 
        table.insert(CFX.Connections, conn)
        return conn
    end
    
    -- Hook no sistema de chute do jogo
    AddConnection(Services.RunService.Heartbeat:Connect(function()
        if not CFX.Settings.CurvedKick then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        -- Detecta bolas próximas
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
                if obj.Parent and obj.Parent.Name ~= LocalPlayer.Name then
                    local dist = (obj.Position - character:GetPivot().Position).Magnitude
                    if dist < 8 and tick() - BallPhysics.LastKickTime > BallPhysics.KickCooldown then
                        -- Aplica física curva
                        CurvedKickManager.ApplyCurve(obj, character)
                        BallPhysics.LastKickTime = tick()
                    end
                end
            end
        end
    end))
end

function CurvedKickManager.ApplyCurve(ball, character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local direction = rootPart.CFrame.LookVector
    local rightVector = rootPart.CFrame.RightVector
    local upVector = rootPart.CFrame.UpVector
    
    -- Intensidade da curva baseada nas configurações
    local intensity = CFX.Settings.CurveIntensity or 1.5
    local randomness = CFX.Settings.CurveRandomness or 0.3
    
    -- Vetor de curva lateral (efeito de "efeito" na bola)
    local curveSide = rightVector * (math.random(-100, 100) / 100 * intensity)
    local curveUp = upVector * (math.random(20, 80) / 100 * intensity)
    
    -- Aplica velocidade com curva
    local baseVelocity = direction * 80 + curveSide * 30 + curveUp * 20
    
    -- Usa BodyVelocity ou ajusta diretamente a velocidade
    local bodyVel = ball:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity")
    bodyVel.Velocity = baseVelocity
    bodyVel.MaxForce = Vector3.new(50000, 50000, 50000)
    bodyVel.Parent = ball
    
    -- Aplica rotação para efeito visual
    local bodyAngular = ball:FindFirstChildOfClass("BodyAngularVelocity") or Instance.new("BodyAngularVelocity")
    bodyAngular.AngularVelocity = Vector3.new(
        math.random(-50, 50),
        math.random(-50, 50),
        math.random(-50, 50)
    ) * intensity
    bodyAngular.MaxTorque = Vector3.new(50000, 50000, 50000)
    bodyAngular.Parent = ball
    
    -- Remove após um tempo
    task.delay(2, function()
        pcall(function()
            bodyVel:Destroy()
            bodyAngular:Destroy()
        end)
    end)
    
    -- Notificação opcional
    if CFX.Settings.NotifyOnKick then
        NotifySystem.Send("Curved Kick", "Efeito aplicado na bola!", 1, "Success")
    end
end

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: GK REACH SYSTEM (PlayerTeleport/ESP equivalente)
-- ═══════════════════════════════════════════════════════════════

local GKManager = {
    Cube = nil,
    SelectionBox = nil,
    IsVisible = false,
}

function GKManager.Initialize()
    GKManager.CreateCube()
    
    -- Atualiza posição do GK
    AddConnection(Services.RunService.RenderStepped:Connect(function()
        if not CFX.Settings.GK_Enabled then
            if GKManager.Cube then
                GKManager.Cube.Parent = nil
            end
            return
        end
        
        GKManager.UpdateCubePosition()
    end))
end

function GKManager.CreateCube()
    local cube = Instance.new("Part")
    cube.Name = "CAFUXZ1_GK_Reach"
    cube.Shape = Enum.PartType.Block
    cube.Size = CFX.Settings.GK_Size or Vector3.new(6, 12, 6)
    cube.Anchored = true
    cube.CanCollide = false
    cube.Transparency = CFX.Settings.GK_Transparency or 1
    cube.Material = Enum.Material.ForceField
    cube.Color = Color3.fromRGB(0, 150, 255)
    cube.CastShadow = false
    
    -- Cria SelectionBox para bordas visíveis
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Name = "GK_Border"
    selectionBox.Adornee = cube
    selectionBox.LineThickness = 0.05
    selectionBox.Color3 = Color3.fromRGB(0, 200, 255)
    selectionBox.SurfaceTransparency = 1
    selectionBox.Parent = cube
    
    GKManager.Cube = cube
    GKManager.SelectionBox = selectionBox
end

function GKManager.UpdateCubePosition()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if not GKManager.Cube then
        GKManager.CreateCube()
    end
    
    local cube = GKManager.Cube
    cube.Parent = Services.Workspace.CurrentCamera -- Ou Workspace
    
    -- Posiciona atrás do jogador (GK posição)
    local offset = CFX.Settings.GK_Position or "Behind"
    local posOffset = Vector3.new(0, 0, 0)
    
    if offset == "Behind" then
        posOffset = -rootPart.CFrame.LookVector * 3
    elseif offset == "Front" then
        posOffset = rootPart.CFrame.LookVector * 3
    elseif offset == "Center" then
        posOffset = Vector3.new(0, 0, 0)
    end
    
    local targetCFrame = rootPart.CFrame + posOffset
    targetCFrame = CFrame.new(targetCFrame.Position) * CFrame.Angles(0, math.atan2(
        rootPart.CFrame.LookVector.X, 
        rootPart.CFrame.LookVector.Z
    ), 0)
    
    -- Ajusta altura para cobrir o personagem (cabeça para cima)
    targetCFrame = targetCFrame + Vector3.new(0, 2, 0)
    
    cube.CFrame = targetCFrame
    cube.Size = CFX.Settings.GK_Size or Vector3.new(6, 12, 6)
    cube.Transparency = CFX.Settings.GK_Transparency or 1
    
    -- Atualiza visibilidade da borda
    if GKManager.SelectionBox then
        GKManager.SelectionBox.Visible = CFX.Settings.GK_BorderOnly ~= false
    end
end

function GKManager.Destroy()
    if GKManager.Cube then
        GKManager.Cube:Destroy()
        GKManager.Cube = nil
    end
end

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: BALL SYSTEM (FruitManager equivalente)
-- ═══════════════════════════════════════════════════════════════

local BallManager = {
    Balls = {},
    SnowActive = false,
    OriginalTerrain = nil,
}

function BallManager.Initialize()
    -- Detecta bolas no workspace
    AddConnection(Services.RunService.Heartbeat:Connect(function()
        BallManager.ScanBalls()
    end))
end

function BallManager.ScanBalls()
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
            if not BallManager.Balls[obj] then
                BallManager.Balls[obj] = true
                BallManager.ApplyBallStyle(obj)
            end
        end
    end
end

function BallManager.ApplyBallStyle(ball)
    if CFX.Settings.Ball_Glow then
        local pointLight = ball:FindFirstChild("BallGlow") or Instance.new("PointLight")
        pointLight.Name = "BallGlow"
        pointLight.Color = CFX.Settings.Ball_Color or Color3.fromRGB(255, 255, 255)
        pointLight.Brightness = 2
        pointLight.Range = 10
        pointLight.Parent = ball
    end
    
    if CFX.Settings.Ball_Trail then
        local trail = ball:FindFirstChild("BallTrail") or Instance.new("Trail")
        trail.Name = "BallTrail"
        trail.Color = ColorSequence.new(CFX.Settings.Ball_Color or Color3.fromRGB(255, 255, 255))
        trail.Lifetime = 0.5
        trail.WidthScale = NumberSequence.new(0.5)
        trail.Parent = ball
    end
    
    ball.Color = CFX.Settings.Ball_Color or Color3.fromRGB(255, 255, 255)
end

function BallManager.SetBallColor(color)
    CFX.Settings.Ball_Color = color
    for ball, _ in pairs(BallManager.Balls) do
        if ball and ball.Parent then
            ball.Color = color
            local glow = ball:FindFirstChild("BallGlow")
            if glow then
                glow.Color = color
            end
            local trail = ball:FindFirstChild("BallTrail")
            if trail then
                trail.Color = ColorSequence.new(color)
            end
        end
    end
end

function BallManager.ToggleSnow(enable)
    if enable == BallManager.SnowActive then return end
    BallManager.SnowActive = enable
    
    local terrain = Services.Workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end
    
    if enable then
        BallManager.OriginalTerrain = terrain.Material
        terrain.Material = Enum.Material.Snow
        -- Adiciona partículas de neve
        local snowParticles = terrain:FindFirstChild("CAFUXZ1_Snow") or Instance.new("ParticleEmitter")
        snowParticles.Name = "CAFUXZ1_Snow"
        snowParticles.Texture = "rbxassetid://241876428"
        snowParticles.Rate = 50
        snowParticles.Lifetime = NumberRange.new(3, 5)
        snowParticles.Speed = NumberRange.new(5, 10)
        snowParticles.VelocitySpread = 180
        snowParticles.Parent = terrain
    else
        if BallManager.OriginalTerrain then
            terrain.Material = BallManager.OriginalTerrain
        end
        local snow = terrain:FindFirstChild("CAFUXZ1_Snow")
        if snow then
            snow:Destroy()
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: AUTO CATCH SYSTEM (ItemsQuests equivalente)
-- ═══════════════════════════════════════════════════════════════

local AutoCatchManager = {
    IsCatching = false,
}

function AutoCatchManager.Initialize()
    AddConnection(Services.RunService.Heartbeat:Connect(function()
        if not CFX.Settings.AutoCatch then return end
        AutoCatchManager.TryCatch()
    end))
end

function AutoCatchManager.TryCatch()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local catchRange = CFX.Settings.CatchRange or 15
    
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
            local dist = (obj.Position - rootPart.Position).Magnitude
            if dist < catchRange then
                -- Teleporta a bola para as mãos do jogador
                local rightHand = character:FindFirstChild("RightHand") or 
                                  character:FindFirstChild("Right Arm")
                if rightHand then
                    obj.CFrame = rightHand.CFrame
                    obj.Velocity = Vector3.new(0, 0, 0)
                    
                    -- Efeito visual
                    local catchEffect = Instance.new("ParticleEmitter")
                    catchEffect.Texture = "rbxassetid://258128463"
                    catchEffect.Rate = 100
                    catchEffect.Lifetime = NumberRange.new(0.5)
                    catchEffect.Parent = rightHand
                    task.delay(0.5, function()
                        catchEffect:Destroy()
                    end)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: ESP SYSTEM (EspManager equivalente)
-- ═══════════════════════════════════════════════════════════════

local ESPManager = {
    ESPObjects = {},
}

function ESPManager.Initialize()
    AddConnection(Services.RunService.RenderStepped:Connect(function()
        ESPManager.UpdateESP()
    end))
end

function ESPManager.UpdateESP()
    -- ESP para bolas
    if CFX.Settings.ESP_Ball then
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
                ESPManager.EnsureESP(obj, "Ball", Color3.fromRGB(255, 255, 0))
            end
        end
    end
    
    -- ESP para jogadores
    if CFX.Settings.ESP_Players then
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    ESPManager.EnsureESP(rootPart, player.Name, Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end
end

function ESPManager.EnsureESP(part, labelText, color)
    local espName = "CAFUXZ1_ESP_" .. labelText
    local existing = part:FindFirstChild(espName)
    
    if existing then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = espName
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    
    -- Adiciona highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = espName .. "_HL"
    highlight.FillColor = color
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Parent = part
end

function ESPManager.Clear()
    for _, conn in ipairs(CFX.Connections) do
        if conn and type(conn) == "table" and conn.Disconnect then
            -- Limpa ESPs
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
--  REGISTRO DE MANAGERS (vu103 equivalente)
-- ═══════════════════════════════════════════════════════════════

CFX.Managers = {
    CurvedKick = CurvedKickManager,
    GK = GKManager,
    Ball = BallManager,
    AutoCatch = AutoCatchManager,
    ESP = ESPManager,
}

function CAFUXZ1.RunManagers()
    for name, manager in pairs(CFX.Managers) do
        local success, result = pcall(manager.Initialize)
        if success then
            print("[CAFUXZ1] Manager carregado: " .. name)
        else
            warn("[CAFUXZ1] Falha ao carregar Manager [" .. name .. "]: " .. tostring(result))
        end
    end
end

print("[CAFUXZ1] Parte 2/5 carregada com sucesso!")
print("[CAFUXZ1] Managers: CurvedKick, GK, Ball, AutoCatch, ESP")

return CAFUXZ1

-- ═══════════════════════════════════════════════════════════════
--  CAFUXZ1 HUB v16.0 - PARTE 3/5
--  Screen Stretch | Otimização de Performance | Misc | Teleporte
-- ═══════════════════════════════════════════════════════════════

local CFX = (getgenv and getgenv()) or (getrenv and getrenv()) or getfenv()
local CAFUXZ1 = CFX.CAFUXZ1
local Services = CFX.Services
local LocalPlayer = CFX.LocalPlayer
local NotifySystem = CFX.NotifySystem

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: SCREEN STRETCH SYSTEM (SeaManager/Visual equivalente)
-- ═══════════════════════════════════════════════════════════════

local ScreenStretchManager = {
    OriginalResolution = nil,
    OriginalTextures = {},
    IsOptimized = false,
}

function ScreenStretchManager.Initialize()
    -- Salva configurações originais
    ScreenStretchManager.OriginalResolution = Camera.ViewportSize
end

function ScreenStretchManager.ApplyStretch(scale)
    scale = scale or CFX.Settings.Stretch_Resolution or 0.5
    
    local cam = Services.Workspace.CurrentCamera
    local originalSize = cam.ViewportSize
    
    -- Reduz resolução de renderização
    cam.ViewportSize = Vector2.new(
        math.floor(originalSize.X * scale),
        math.floor(originalSize.Y * scale)
    )
    
    -- Ajusta FOV para compensar
    cam.FieldOfView = 70 + (1 - scale) * 30
    
    NotifySystem.Send("Screen Stretch", "Resolução reduzida para " .. math.floor(scale * 100) .. "%", 3, "Success")
end

function ScreenStretchManager.RemoveTextures()
    if not CFX.Settings.RemoveTextures then return end
    
    local removedCount = 0
    
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            if obj.TextureID and obj.TextureID ~= "" then
                ScreenStretchManager.OriginalTextures[obj] = obj.TextureID
                obj.TextureID = ""
                removedCount = removedCount + 1
            end
            
            -- Remove decals
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    child:Destroy()
                    removedCount = removedCount + 1
                end
            end
        end
        
        -- Remove SurfaceGuis desnecessários
        if obj:IsA("SurfaceGui") and not obj:FindFirstAncestorOfClass("Model") then
            obj:Destroy()
            removedCount = removedCount + 1
        end
    end
    
    -- Otimiza Lighting
    local lighting = Services.Lighting
    lighting.GlobalShadows = false
    lighting.Technology = Enum.Technology.Compatibility
    lighting.Brightness = 1
    lighting.FogEnd = 500
    
    -- Remove efeitos pesados
    for _, effect in ipairs(lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
            effect:Destroy()
            removedCount = removedCount + 1
        end
    end
    
    NotifySystem.Send("Otimização", tostring(removedCount) .. " texturas/efeitos removidos!", 3, "Success")
end

function ScreenStretchManager.OptimizeMaterials()
    if not CFX.Settings.OptimizeMaterials then return end
    
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            -- Converte materiais pesados para plástico
            if obj.Material == Enum.Material.DiamondPlate or 
               obj.Material == Enum.Material.Foil or
               obj.Material == Enum.Material.Glass or
               obj.Material == Enum.Material.Granite or
               obj.Material == Enum.Material.Marble or
               obj.Material == Enum.Material.Pebble then
                obj.Material = Enum.Material.Plastic
            end
            
            -- Reduz reflectância
            obj.Reflectance = 0
        end
    end
    
    NotifySystem.Send("Otimização", "Materiais otimizados para melhor FPS!", 2, "Success")
end

function ScreenStretchManager.Reset()
    local cam = Services.Workspace.CurrentCamera
    if ScreenStretchManager.OriginalResolution then
        cam.ViewportSize = ScreenStretchManager.OriginalResolution
    end
    cam.FieldOfView = 70
    
    -- Restaura texturas
    for obj, texture in pairs(ScreenStretchManager.OriginalTextures) do
        if obj and obj.Parent then
            obj.TextureID = texture
        end
    end
    
    ScreenStretchManager.OriginalTextures = {}
    NotifySystem.Send("Screen Stretch", "Configurações restauradas!", 2, "Info")
end

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: TELEPORTE & MOVIMENTAÇÃO (PlayerTeleport equivalente)
-- ═══════════════════════════════════════════════════════════════

local TeleportManager = {
    LastTP = 0,
    TPCooldown = 1,
    SavedPositions = {},
}

function TeleportManager.Initialize()
    -- Sistema de teleporte seguro
end

function TeleportManager.TeleportTo(position)
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    if tick() - TeleportManager.LastTP < TeleportManager.TPCooldown then
        return
    end
    
    TeleportManager.LastTP = tick()
    
    -- Usa Tween para teleporte suave
    local distance = (rootPart.Position - position).Magnitude
    local speed = CFX.Settings.TweenSpeed or 220
    local time = distance / speed
    
    if distance < 150 then
        rootPart.CFrame = CFrame.new(position)
    else
        CFX.TweenSystem.new(rootPart, math.min(time, 3), "CFrame", CFrame.new(position))
    end
end

function TeleportManager.TeleportToBall()
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
            TeleportManager.TeleportTo(obj.Position + Vector3.new(0, 5, 0))
            return
        end
    end
    NotifySystem.Send("Teleporte", "Nenhuma bola encontrada!", 2, "Error")
end

function TeleportManager.TeleportToGoal()
    -- Detecta gols automaticamente (partes com nomes típicos)
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if name:find("goal") or name:find("gol") or name:find("net") then
            TeleportManager.TeleportTo(obj.Position + Vector3.new(0, 5, 0))
            return
        end
    end
    NotifySystem.Send("Teleporte", "Nenhum gol encontrado!", 2, "Error")
end

function TeleportManager.SavePosition(name)
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    TeleportManager.SavedPositions[name] = rootPart.CFrame
    NotifySystem.Send("Posição Salva", "Local '" .. name .. "' salvo!", 2, "Success")
end

function TeleportManager.LoadPosition(name)
    local pos = TeleportManager.SavedPositions[name]
    if pos then
        TeleportManager.TeleportTo(pos.Position)
    else
        NotifySystem.Send("Erro", "Posição '" .. name .. "' não encontrada!", 2, "Error")
    end
end

-- ═══════════════════════════════════════════════════════════════
--  MANAGER: ANTI-AFK & UTILITÁRIOS (Misc equivalente)
-- ═══════════════════════════════════════════════════════════════

local MiscManager = {
    AntiAFK_Connection = nil,
}

function MiscManager.Initialize()
    -- Anti-AFK
    MiscManager.SetupAntiAFK()
end

function MiscManager.SetupAntiAFK()
    local vu = Services.VirtualUser
    
    CFX.Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
    end)
    
    table.insert(CFX.Connections, CFX.Connections.AntiAFK)
end

function MiscManager.FullBright()
    local lighting = Services.Lighting
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    NotifySystem.Send("Visual", "FullBright ativado!", 2, "Success")
end

function MiscManager.RejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId
    Services.TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
end

function MiscManager.ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    
    local success, result = pcall(function()
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = Services.HttpService:JSONDecode(req)
        return data
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            Services.TeleportService:TeleportToPlaceInstance(placeId, randomServer, LocalPlayer)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
--  REGISTRO DE MANAGERS ADICIONAIS
-- ═══════════════════════════════════════════════════════════════

CFX.Managers.ScreenStretch = ScreenStretchManager
CFX.Managers.Teleport = TeleportManager
CFX.Managers.Misc = MiscManager

print("[CAFUXZ1] Parte 3/5 carregada com sucesso!")
print("[CAFUXZ1] Managers: ScreenStretch, Teleport, Misc")

return CAFUXZ1

-- ═══════════════════════════════════════════════════════════════
--  CAFUXZ1 HUB v16.0 - PARTE 4/5
--  Interface WindUI - Todas as Tabs | Design Premium
-- ═══════════════════════════════════════════════════════════════

local CFX = (getgenv and getgenv()) or (getrenv and getrenv()) or getfenv()
local CAFUXZ1 = CFX.CAFUXZ1
local WindUI = CFX.WindUI
local Services = CFX.Services
local LocalPlayer = CFX.LocalPlayer
local NotifySystem = CFX.NotifySystem

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE TABS (LoadTabs equivalente)
-- ═══════════════════════════════════════════════════════════════

function CAFUXZ1.LoadTabs(window)
    return {
        Discord = window:MakeTab({
            Title = "Discord",
            Icon = "Info"
        }),
        Main = window:MakeTab({
            Title = "Principal",
            Icon = "Home"
        }),
        GK = window:MakeTab({
            Title = "GK Reach",
            Icon = "Shield"
        }),
        Ball = window:MakeTab({
            Title = "Bola",
            Icon = "Circle"
        }),
        Kicks = window:MakeTab({
            Title = "Chutes",
            Icon = "Zap"
        }),
        Visual = window:MakeTab({
            Title = "Visual",
            Icon = "Eye"
        }),
        Stretch = window:MakeTab({
            Title = "Tela",
            Icon = "Monitor"
        }),
        Teleport = window:MakeTab({
            Title = "Teleporte",
            Icon = "Locate"
        }),
        Misc = window:MakeTab({
            Title = "Extras",
            Icon = "Settings"
        }),
    }
end

-- ═══════════════════════════════════════════════════════════════
--  PLUGIN SYSTEM (InstallPlugin equivalente)
-- ═══════════════════════════════════════════════════════════════

function CAFUXZ1.InstallPlugin()
    return {
        Toggle = function(tab, config, optionKey)
            local name = config[1]
            local desc = config[2] or ""
            local default = config[3] or false
            
            return tab:AddToggle({
                Title = name,
                Description = desc,
                Default = CFX.Settings[optionKey] or default,
                Callback = function(value)
                    CFX.Enabled[optionKey] = value
                    CFX.Settings[optionKey] = value
                end
            })
        end,
        
        Slider = function(tab, config)
            return tab:AddSlider({
                Title = config[1],
                Min = config[2],
                Max = config[3],
                Increment = config[4],
                Default = config[5],
                Callback = config[6]
            })
        end,
        
        Dropdown = function(tab, config)
            return tab:AddDropdown({
                Title = config[1],
                Options = config[2],
                Default = config[3],
                Callback = config[4]
            })
        end,
    }
end

-- ═══════════════════════════════════════════════════════════════
--  CONSTRUÇÃO DA INTERFACE (LoadLibrary equivalente)
-- ═══════════════════════════════════════════════════════════════

function CAFUXZ1.BuildUI()
    -- Cria a janela principal
    local Window = WindUI:CreateWindow({
        Title = "CAFUXZ1 HUB",
        SubTitle = "v16.0 | by CAFUXZ1",
        Icon = "rbxassetid://15298567397",
        Size = UDim2.fromOffset(580, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        Theme = CFX.Settings.Theme or "Dark",
        Background = "rbxassetid://13511292247",
        User = {
            Title = LocalPlayer.DisplayName or LocalPlayer.Name,
            Icon = "rbxassetid://18854959415"
        },
        KeySystem = false,
    })
    
    CFX.Window = Window
    
    -- Botão de minimizar
    Window:AddMinimizeButton({
        Button = {
            Image = "rbxassetid://15298567397",
            BackgroundTransparency = 0,
            Corner = {
                CornerRadius = UDim.new(0, 6)
            }
        }
    })
    
    -- Carrega todas as tabs
    local Tabs = CAFUXZ1.LoadTabs(Window)
    local Plugin = CAFUXZ1.InstallPlugin()
    local Toggle = Plugin.Toggle
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: DISCORD
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Discord:AddDiscordInvite({
        Name = "CAFUXZ1 | Community",
        Description = "Entre no nosso Discord para novidades e suporte!",
        Logo = "rbxassetid://18854959415",
        Invite = "https://discord.gg/cafuxz1"
    })
    
    Tabs.Discord:AddSection("Informações")
    Tabs.Discord:AddParagraph({
        Title = "CAFUXZ1 Hub v16.0",
        Content = "Hub completo para futebol no Roblox.\nDesenvolvido com base na arquitetura RedzLibV5."
    })
    
    Tabs.Discord:AddParagraph({
        Title = "Créditos",
        Content = "Base: Redz Hub (real_redz)\nAdaptação: CAFUXZ1\nWindUI Library"
    })
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: PRINCIPAL (Main)
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Main:AddSection("Configurações Gerais")
    
    -- UI Scale
    local scaleOptions = {
        Small = 760,
        Medium = 620,
        Large = 450,
        Bigger = 380
    }
    
    Tabs.Main:AddDropdown({
        Title = "Escala da UI",
        Options = {"Small", "Medium", "Large", "Bigger"},
        Default = CFX.Settings.UIScale or "Large",
        Callback = function(value)
            CFX.Settings.UIScale = value
            pcall(function()
                WindUI:SetScale(scaleOptions[value] or 450)
            end)
        end
    })
    
    Tabs.Main:AddSection("Auto Farm")
    
    Toggle(Tabs.Main, {"Auto Farm Level", "Farm automático de nível", false}, "AutoFarm")
    Toggle(Tabs.Main, {"Auto Farm Nearest", "Farm no inimigo mais próximo", false}, "FarmNearest")
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: GK REACH
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.GK:AddSection("GK Reach System")
    
    Toggle(Tabs.GK, {"Ativar GK Reach", "Cubo transparente atrás do jogador", false}, "GK_Enabled")
    
    Tabs.GK:AddDropdown({
        Title = "Posição do GK",
        Options = {"Behind", "Front", "Center"},
        Default = "Behind",
        Callback = function(value)
            CFX.Settings.GK_Position = value
        end
    })
    
    Tabs.GK:AddSlider({
        Title = "Largura do Cubo",
        Min = 2,
        Max = 15,
        Increment = 0.5,
        Default = 6,
        Callback = function(value)
            CFX.Settings.GK_Size = Vector3.new(value, CFX.Settings.GK_Size.Y, CFX.Settings.GK_Size.Z)
        end
    })
    
    Tabs.GK:AddSlider({
        Title = "Altura do Cubo",
        Min = 5,
        Max = 25,
        Increment = 0.5,
        Default = 12,
        Callback = function(value)
            CFX.Settings.GK_Size = Vector3.new(CFX.Settings.GK_Size.X, value, CFX.Settings.GK_Size.Z)
        end
    })
    
    Tabs.GK:AddSlider({
        Title = "Profundidade do Cubo",
        Min = 2,
        Max = 15,
        Increment = 0.5,
        Default = 6,
        Callback = function(value)
            CFX.Settings.GK_Size = Vector3.new(CFX.Settings.GK_Size.X, CFX.Settings.GK_Size.Y, value)
        end
    })
    
    Toggle(Tabs.GK, {"Apenas Bordas", "Mostrar apenas as bordas do cubo", true}, "GK_BorderOnly")
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: BOLA
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Ball:AddSection("Cor da Bola")
    
    Tabs.Ball:AddColorpicker({
        Title = "Cor Personalizada",
        Default = CFX.Settings.Ball_Color or Color3.fromRGB(255, 255, 255),
        Callback = function(color)
            CFX.Managers.Ball.SetBallColor(color)
        end
    })
    
    Toggle(Tabs.Ball, {"Glow na Bola", "Efeito de luz na bola", false}, "Ball_Glow")
    Toggle(Tabs.Ball, {"Rastro na Bola", "Trail atrás da bola", false}, "Ball_Trail")
    
    Tabs.Ball:AddSection("Sistema de Neve")
    
    Tabs.Ball:AddButton({
        Title = "Ativar Neve",
        Callback = function()
            CFX.Managers.Ball.ToggleSnow(true)
        end
    })
    
    Tabs.Ball:AddButton({
        Title = "Desativar Neve",
        Callback = function()
            CFX.Managers.Ball.ToggleSnow(false)
        end
    })
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: CHUTES
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Kicks:AddSection("Curved Kick System")
    
    Toggle(Tabs.Kicks, {"Chutes Curvos", "Aplica efeito de curva em todos os chutes", true}, "CurvedKick")
    
    Tabs.Kicks:AddSlider({
        Title = "Intensidade da Curva",
        Min = 0.5,
        Max = 5,
        Increment = 0.1,
        Default = 1.5,
        Callback = function(value)
            CFX.Settings.CurveIntensity = value
        end
    })
    
    Tabs.Kicks:AddSlider({
        Title = "Aleatoriedade",
        Min = 0,
        Max = 1,
        Increment = 0.05,
        Default = 0.3,
        Callback = function(value)
            CFX.Settings.CurveRandomness = value
        end
    })
    
    Tabs.Kicks:AddSection("Auto Catch")
    
    Toggle(Tabs.Kicks, {"Auto Catch", "Pega a bola automaticamente", false}, "AutoCatch")
    
    Tabs.Kicks:AddSlider({
        Title = "Alcance do Catch",
        Min = 5,
        Max = 50,
        Increment = 1,
        Default = 15,
        Callback = function(value)
            CFX.Settings.CatchRange = value
        end
    })
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: VISUAL
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Visual:AddSection("ESP System")
    
    Toggle(Tabs.Visual, {"ESP Geral", "Ativar ESP", false}, "ESP_Enabled")
    Toggle(Tabs.Visual, {"ESP Bola", "Destacar bolas no mapa", true}, "ESP_Ball")
    Toggle(Tabs.Visual, {"ESP Jogadores", "Destacar jogadores", false}, "ESP_Players")
    Toggle(Tabs.Visual, {"ESP GK", "Mostrar alcance do GK", true}, "ESP_GK")
    
    Tabs.Visual:AddButton({
        Title = "FullBright",
        Callback = function()
            CFX.Managers.Misc.FullBright()
        end
    })
    
    Tabs.Visual:AddButton({
        Title = "Remover Fog",
        Callback = function()
            if Services.Lighting:FindFirstChild("LightingLayers") then
                Services.Lighting.LightingLayers:Destroy()
            end
            NotifySystem.Send("Visual", "Fog removido!", 2, "Success")
        end
    })
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: TELA (Screen Stretch)
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Stretch:AddSection("Otimização de Tela")
    
    Toggle(Tabs.Stretch, {"Screen Stretch", "Reduzir resolução para mais FPS", false}, "Stretch_Enabled")
    
    Tabs.Stretch:AddSlider({
        Title = "Escala de Resolução",
        Min = 0.1,
        Max = 1,
        Increment = 0.05,
        Default = 0.5,
        Callback = function(value)
            CFX.Settings.Stretch_Resolution = value
            if CFX.Settings.Stretch_Enabled then
                CFX.Managers.ScreenStretch.ApplyStretch(value)
            end
        end
    })
    
    Toggle(Tabs.Stretch, {"Remover Texturas", "Remove texturas para FPS boost", true}, "RemoveTextures")
    Toggle(Tabs.Stretch, {"Otimizar Materiais", "Converte materiais pesados", true}, "OptimizeMaterials")
    
    Tabs.Stretch:AddButton({
        Title = "Aplicar Otimização",
        Callback = function()
            CFX.Managers.ScreenStretch.RemoveTextures()
            CFX.Managers.ScreenStretch.OptimizeMaterials()
        end
    })
    
    Tabs.Stretch:AddButton({
        Title = "Resetar Tela",
        Callback = function()
            CFX.Managers.ScreenStretch.Reset()
        end
    })
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: TELEPORTE
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Teleport:AddSection("Teleporte Rápido")
    
    Tabs.Teleport:AddButton({
        Title = "Teleportar para Bola",
        Callback = function()
            CFX.Managers.Teleport.TeleportToBall()
        end
    })
    
    Tabs.Teleport:AddButton({
        Title = "Teleportar para Gol",
        Callback = function()
            CFX.Managers.Teleport.TeleportToGoal()
        end
    })
    
    Tabs.Teleport:AddSection("Posições Salvas")
    
    local posName = ""
    Tabs.Teleport:AddInput({
        Title = "Nome da Posição",
        Default = "",
        Placeholder = "Ex: Gol Norte",
        Callback = function(text)
            posName = text
        end
    })
    
    Tabs.Teleport:AddButton({
        Title = "Salvar Posição",
        Callback = function()
            if posName ~= "" then
                CFX.Managers.Teleport.SavePosition(posName)
            end
        end
    })
    
    Tabs.Teleport:AddButton({
        Title = "Carregar Posição",
        Callback = function()
            if posName ~= "" then
                CFX.Managers.Teleport.LoadPosition(posName)
            end
        end
    })
    
    -- ═══════════════════════════════════════════════════════════
    --  TAB: EXTRAS (Misc)
    -- ═══════════════════════════════════════════════════════════
    
    Tabs.Misc:AddSection("Anti-AFK")
    
    Toggle(Tabs.Misc, {"Anti-AFK", "Evita ser kickado por inatividade", true}, "AntiAFK")
    
    Tabs.Misc:AddSection("Servidor")
    
    Tabs.Misc:AddButton({
        Title = "Rejoin Server",
        Callback = function()
            CFX.Managers.Misc.RejoinServer()
        end
    })
    
    Tabs.Misc:AddButton({
        Title = "Server Hop",
        Callback = function()
            CFX.Managers.Misc.ServerHop()
        end
    })
    
    Tabs.Misc:AddSection("Hub")
    
    Tabs.Misc:AddButton({
        Title = "Destruir Hub",
        Callback = function()
            Window:Destroy()
            ClearConnections()
        end
    })
    
    -- Seleciona tab principal
    Window:SelectTab(Tabs.Main)
    
    NotifySystem.Send("CAFUXZ1 Hub", "Interface carregada com sucesso!", 3, "Success")
end

print("[CAFUXZ1] Parte 4/5 carregada com sucesso!")
print("[CAFUXZ1] Interface WindUI construída!")

return CAFUXZ1
-- ═══════════════════════════════════════════════════════════════
--  CAFUXZ1 HUB v16.0 - PARTE 5/5
--  Inicialização | Farm Queue | Start Functions | Finalização
-- ═══════════════════════════════════════════════════════════════

local CFX = (getgenv and getgenv()) or (getrenv and getrenv()) or getfenv()
local CAFUXZ1 = CFX.CAFUXZ1
local Services = CFX.Services
local LocalPlayer = CFX.LocalPlayer
local NotifySystem = CFX.NotifySystem

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE FUNÇÕES DE FARM (StartFunctions equivalente)
-- ═══════════════════════════════════════════════════════════════

local FarmFunctions = {}
local AllFunctions = {}

function CAFUXZ1.RegisterFunction(name, func, condition)
    condition = condition ~= false
    
    if not AllFunctions[name] then
        AllFunctions[name] = func
        table.insert(CFX.Functions, {
            Name = name,
            Function = func
        })
    else
        AllFunctions[name] = func
        for _, f in ipairs(CFX.Functions) do
            if f.Name == name then
                f.Function = func
            end
        end
    end
end

function CAFUXZ1.StartFunctions()
    table.clear(CFX.Functions)
    
    local GK = CFX.Managers.GK
    local Ball = CFX.Managers.Ball
    local CurvedKick = CFX.Managers.CurvedKick
    local AutoCatch = CFX.Managers.AutoCatch
    local ESP = CFX.Managers.ESP
    local ScreenStretch = CFX.Managers.ScreenStretch
    local Teleport = CFX.Managers.Teleport
    local Misc = CFX.Managers.Misc
    
    -- ═══════════════════════════════════════════════════════════
    --  REGISTRO DE FUNÇÕES DE FARM
    -- ═══════════════════════════════════════════════════════════
    
    -- Auto Farm Level (placeholder para jogo de futebol)
    CAFUXZ1.RegisterFunction("Level", function()
        -- Lógica de farm de nível específica do jogo
        task.wait(0.5)
        return "Farming Level..."
    end)
    
    -- Farm Nearest (chuta bola mais próxima)
    CAFUXZ1.RegisterFunction("Nearest", function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local nearestBall = nil
        local nearestDist = math.huge
        
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Shape == Enum.PartType.Ball then
                local dist = (obj.Position - rootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestBall = obj
                    nearestDist = dist
                end
            end
        end
        
        if nearestBall and nearestDist < 1500 then
            -- Teleporta e chuta
            Teleport.TeleportTo(nearestBall.Position + Vector3.new(0, 5, 0))
            task.wait(0.3)
            CurvedKick.ApplyCurve(nearestBall, character)
            return "Chutando bola mais próxima..."
        end
        
        task.wait(0.4)
    end)
    
    -- Curved Kick automático
    CAFUXZ1.RegisterFunction("CurvedKick", function()
        if not CFX.Settings.CurvedKick then return end
        -- O CurvedKickManager já roda via Heartbeat
        task.wait(0.1)
        return "Curved Kick ativo"
    end)
    
    -- Auto Catch
    CAFUXZ1.RegisterFunction("AutoCatch", function()
        if not CFX.Settings.AutoCatch then return end
        AutoCatch.TryCatch()
        task.wait(0.1)
        return "Auto Catch ativo"
    end)
    
    -- GK Atualização
    CAFUXZ1.RegisterFunction("GK", function()
        -- O GKManager já roda via RenderStepped
        task.wait(0.1)
        return "GK ativo"
    end)
    
    -- ESP Atualização
    CAFUXZ1.RegisterFunction("ESP", function()
        -- O ESPManager já roda via RenderStepped
        task.wait(0.1)
        return "ESP ativo"
    end)
    
    -- Screen Stretch
    CAFUXZ1.RegisterFunction("Stretch", function()
        if CFX.Settings.Stretch_Enabled then
            ScreenStretch.ApplyStretch()
        end
        task.wait(1)
        return "Screen Stretch ativo"
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  START FARM (StartFarm equivalente)
-- ═══════════════════════════════════════════════════════════════

function CAFUXZ1.StartFarm()
    if not CFX.CFX_loadedFarm then
        CFX.CFX_loadedFarm = true
        CFX.CFX_OnFarm = true
        
        -- Inicia a fila de farm em spawn separado
        task.spawn(function()
            while CFX.CFX_OnFarm do
                for _, funcData in ipairs(CFX.KickFunctions) do
                    if CFX.Enabled[funcData.Name] then
                        local status, result = pcall(funcData.Function)
                        if not status then
                            warn("[CAFUXZ1] Farm error in " .. funcData.Name .. ": " .. tostring(result))
                        end
                    end
                end
                task.wait()
            end
        end)
        
        NotifySystem.Send("Farm", "Sistema de farm iniciado!", 2, "Success")
    end
end

-- ═══════════════════════════════════════════════════════════════
--  INICIALIZAÇÃO COMPLETA (Initialize equivalente)
-- ═══════════════════════════════════════════════════════════════

function CAFUXZ1.Initialize()
    -- Limpa erros anteriores
    if CFX.CFX_ErrorMsg then
        pcall(function() CFX.CFX_ErrorMsg:Destroy() end)
    end
    
    -- Inicializa library
    CAFUXZ1.InitializeLibrary()
    
    -- Carrega managers
    CAFUXZ1.RunManagers()
    
    -- Registra funções
    CAFUXZ1.StartFunctions()
    
    -- Constrói UI
    CAFUXZ1.BuildUI()
    
    -- Inicia farm
    CAFUXZ1.StartFarm()
    
    print("[CAFUXZ1] Hub inicializado com sucesso!")
    print("[CAFUXZ1] Versão 16.0 | Todos os sistemas ativos")
end

-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE MINIMIZAR (Floating Icon)
-- ═══════════════════════════════════════════════════════════════

function CAFUXZ1.CreateMinimizeButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CAFUXZ1_Minimize"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Services.CoreGui
    
    local button = Instance.new("ImageButton")
    button.Name = "MinimizeButton"
    button.Size = UDim2.new(0, 45, 0, 45)
    button.Position = UDim2.new(0, 20, 0.5, -22)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.Image = "rbxassetid://15298567397"
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = button
    
    local isMinimized = false
    
    button.MouseButton1Click:Connect(function()
        if CFX.Window then
            isMinimized = not isMinimized
            if isMinimized then
                CFX.Window:Minimize()
                button.ImageColor3 = Color3.fromRGB(0, 255, 100)
            else
                CFX.Window:Restore()
                button.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end)
    
    -- Efeito hover
    button.MouseEnter:Connect(function()
        CFX.TweenSystem.new(button, 0.2, "Size", UDim2.new(0, 50, 0, 50))
    end)
    
    button.MouseLeave:Connect(function()
        CFX.TweenSystem.new(button, 0.2, "Size", UDim2.new(0, 45, 0, 45))
    end)
    
    CFX.MinimizeButton = button
end

-- ═══════════════════════════════════════════════════════════════
--  EXECUÇÃO FINAL
-- ═══════════════════════════════════════════════════════════════

local function ExecuteWithTiming(name, ...)
    local startTime = tick()
    CAFUXZ1[name](CAFUXZ1, ...)
    print(string.format("[CAFUXZ1] %s executado em %.3fs", name, tick() - startTime))
end

-- Limpa conexões antigas
for _, conn in ipairs(CFX.Connections or {}) do
    pcall(function() conn:Disconnect() end)
end
table.clear(CFX.Connections or {})

-- Executa na ordem correta
ExecuteWithTiming("Initialize")
task.spawn(ExecuteWithTiming, "CreateMinimizeButton")

-- Mensagem final
print("╔══════════════════════════════════════════════════════════════╗")
print("║                    CAFUXZ1 HUB v16.0                         ║")
print("║              Baseado na arquitetura RedzLibV5               ║")
print("║                                                              ║")
print("║  ✓ Curved Kick System                                        ║")
print("║  ✓ GK Reach (Transparente com Bordas)                       ║")
print("║  ✓ Ball Color Changer + Snow System                         ║")
print("║  ✓ Auto Catch                                               ║")
print("║  ✓ ESP System                                               ║")
print("║  ✓ Screen Stretch / Otimização                              ║")
print("║  ✓ Teleporte Rápido                                         ║")
print("║  ✓ Anti-AFK + Server Hop                                   ║")
print("║                                                              ║")
print("║  Pressione RightShift para minimizar/restaurar              ║")
print("╚══════════════════════════════════════════════════════════════╝")

NotifySystem.Send("CAFUXZ1 Hub v16.0", "Todos os sistemas carregados!", 5, "Success")

-- Retorna o Hub
return CAFUXZ1
