-- ═══════════════════════════════════════════════════════════════
-- BROOKHAVEN AD SYSTEM BYPASS v2.0
-- Baseado em engenharia reversa real dos remotes do Brookhaven
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    DEBUG_MODE = true,
    AUTO_EXPLOIT = true,
    SPOOF_AD_COMPLETE = true,
    FORCE_CLAIM_REWARD = true,
    BYPASS_PLUS_CHECK = true,
    GAMEPASS_IDS = {
        PLUS = 3578196,      -- Brookhaven Plus (ID aproximado)
        PREMIUM = 96651,     -- Premium Access
    }
}

-- ═══════════════════════════════════════════════════════════════
-- ESTADO E LOGS
-- ═══════════════════════════════════════════════════════════════

local State = {
    Remotes = {},
    Hooks = {},
    Logs = {},
    AdSystemBypassed = false,
    PlusActive = false,
    GamepassesGranted = {},
    FakeAdWatched = false
}

local function Log(level, message, data)
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] %s", timestamp, level, message)
    table.insert(State.Logs, {time = timestamp, level = level, message = message, data = data})
    
    if CONFIG.DEBUG_MODE then
        print(entry)
        if data then print("  DATA:", HttpService:JSONEncode(data)) end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- REFERÊNCIAS DIRETAS AOS REMOTES REAIS DO BROOKHAVEN
-- ═══════════════════════════════════════════════════════════════

local Remotes = {
    -- Sistema de Anúncios
    AdVideoRequest = ReplicatedStorage:WaitForChild("Advertisements:Video:Request", 5),
    AdVideoComplete = ReplicatedStorage:WaitForChild("Advertisements:Video:Complete", 5),
    AdVideoFake = ReplicatedStorage:WaitForChild("Advertisements:Video:Fake", 5),
    CanViewAd = ReplicatedStorage:WaitForChild("Advertisements:CanPlayerViewAdvertisement", 5),
    
    -- Sistema de Recompensas
    AttemptClaim = ReplicatedStorage:WaitForChild("AttemptToClaimReward", 5),
    ClaimPending = ReplicatedStorage:WaitForChild("ClaimPendingReward", 5),
    
    -- Sistema Plus/Gamepass
    SetPlus = ReplicatedStorage:WaitForChild("SetPlus", 5),
    PlusSuccess = ReplicatedStorage:WaitForChild("PlusSuccess", 5),
    PlusUpsell = ReplicatedStorage:WaitForChild("PlusUpsell", 5),
    ShowGamepass = ReplicatedStorage:WaitForChild("ShowGamepass", 5),
    PromptGamepass = ReplicatedStorage:WaitForChild("PromptGamepassPurchase", 5),
    
    -- Inventário Manager
    IM_GamepassAll = ReplicatedStorage:WaitForChild("IM_GamepassAll", 5),
    IM_GamepassClear = ReplicatedStorage:WaitForChild("IM_GamepassClear", 5),
    IM_UnlockableAdd = ReplicatedStorage:WaitForChild("IM_UnlockableAdd", 5),
    IM_EventSetTokens = ReplicatedStorage:WaitForChild("IM_EventSetTokens", 5),
    
    -- Outros
    PromptProduct = ReplicatedStorage:WaitForChild("PromptProduct", 5),
    PromptCountable = ReplicatedStorage:WaitForChild("PromptCountableProduct", 5),
    PromptRepeatable = ReplicatedStorage:WaitForChild("PromptRepeatableProduct", 5),
    
    -- Replica System (sincronização de dados)
    ReplicaSet = ReplicatedStorage:WaitForChild("ReplicaSet", 5),
    ReplicaWrite = ReplicatedStorage:WaitForChild("ReplicaWrite", 5),
    ReplicaSignal = ReplicatedStorage:WaitForChild("ReplicaSignal", 5),
}

-- Verificar quais foram encontrados
for name, remote in pairs(Remotes) do
    if remote then
        Log("FOUND", string.format("Remote localizado: %s (%s)", name, remote.ClassName))
        State.Remotes[name] = remote
    else
        Log("WARN", string.format("Remote NÃO encontrado: %s", name))
    end
end

-- ═══════════════════════════════════════════════════════════════
-- BYPASS DO SISTEMA DE ANÚNCIOS
-- ═══════════════════════════════════════════════════════════════

local function BypassAdSystem()
    Log("EXPLOIT", "Iniciando bypass do sistema de anúncios...")
    
    -- MÉTODO 1: Fingir que o vídeo foi completado
    if Remotes.AdVideoComplete and CONFIG.SPOOF_AD_COMPLETE then
        Log("EXPLOIT", "Disparando AdVideoComplete sem assistir anúncio...")
        
        -- Tentar várias assinaturas possíveis
        local attempts = {
            function() Remotes.AdVideoComplete:FireServer(true) end,
            function() Remotes.AdVideoComplete:FireServer(LocalPlayer.UserId, true) end,
            function() Remotes.AdVideoComplete:FireServer("completed", true) end,
            function() Remotes.AdVideoComplete:FireServer({completed = true, playerId = LocalPlayer.UserId}) end,
        }
        
        for i, attempt in ipairs(attempts) do
            local success, err = pcall(attempt)
            if success then
                Log("EXPLOIT", string.format("AdVideoComplete assinatura %d funcionou!", i))
                State.FakeAdWatched = true
                break
            else
                Log("DEBUG", string.format("Assinatura %d falhou: %s", i, tostring(err)))
            end
        end
    end
    
    -- MÉTODO 2: Usar o Fake Video remote (pode ser um bypass interno de teste)
    if Remotes.AdVideoFake and CONFIG.SPOOF_AD_COMPLETE then
        Log("EXPLOIT", "Disparando AdVideoFake...")
        pcall(function()
            Remotes.AdVideoFake:FireServer(true)
            Log("EXPLOIT", "AdVideoFake disparado com sucesso!")
        end)
    end
    
    -- MÉTODO 3: Forçar claim de recompensa diretamente
    if Remotes.AttemptClaim and CONFIG.FORCE_CLAIM_REWARD then
        Log("EXPLOIT", "Forçando AttemptToClaimReward...")
        
        local claimAttempts = {
            function() return Remotes.AttemptClaim:InvokeServer("ad_reward") end,
            function() return Remotes.AttemptClaim:InvokeServer("premium") end,
            function() return Remotes.AttemptClaim:InvokeServer("plus") end,
            function() return Remotes.AttemptClaim:InvokeServer(LocalPlayer.UserId, "premium") end,
            function() return Remotes.AttemptClaim:InvokeServer({type = "ad", reward = "premium"}) end,
        }
        
        for i, attempt in ipairs(claimAttempts) do
            local success, result = pcall(attempt)
            if success then
                Log("EXPLOIT", string.format("AttemptToClaim assinatura %d: %s", i, tostring(result)))
                if result == true or result == "success" then
                    State.AdSystemBypassed = true
                    break
                end
            end
        end
    end
    
    -- MÉTODO 4: ClaimPendingReward
    if Remotes.ClaimPending and CONFIG.FORCE_CLAIM_REWARD then
        Log("EXPLOIT", "Forçando ClaimPendingReward...")
        
        local pendingAttempts = {
            function() return Remotes.ClaimPending:InvokeServer() end,
            function() return Remotes.ClaimPending:InvokeServer("premium") end,
            function() return Remotes.ClaimPending:InvokeServer(LocalPlayer.UserId) end,
        }
        
        for i, attempt in ipairs(pendingAttempts) do
            local success, result = pcall(attempt)
            if success then
                Log("EXPLOIT", string.format("ClaimPending assinatura %d: %s", i, tostring(result)))
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- BYPASS DO SISTEMA PLUS/PREMIUM
-- ═══════════════════════════════════════════════════════════════

local function BypassPlusSystem()
    Log("EXPLOIT", "Iniciando bypass do sistema Plus/Premium...")
    
    -- MÉTODO 1: Forçar ativação do Plus via SetPlus
    if Remotes.SetPlus and CONFIG.BYPASS_PLUS_CHECK then
        Log("EXPLOIT", "Disparando SetPlus...")
        
        local plusAttempts = {
            function() Remotes.SetPlus:FireServer(true) end,
            function() Remotes.SetPlus:FireServer(LocalPlayer.UserId, true) end,
            function() Remotes.SetPlus:FireServer({enabled = true, duration = 999999}) end,
            function() Remotes.SetPlus:FireServer(1) end, -- 1 = ativo
        }
        
        for i, attempt in ipairs(plusAttempts) do
            local success = pcall(attempt)
            if success then
                Log("EXPLOIT", string.format("SetPlus assinatura %d disparada", i))
            end
        end
    end
    
    -- MÉTODO 2: Disparar PlusSuccess (simular evento de sucesso)
    if Remotes.PlusSuccess then
        Log("EXPLOIT", "Disparando PlusSuccess...")
        pcall(function()
            Remotes.PlusSuccess:FireServer(true)
            Remotes.PlusSuccess:FireServer(LocalPlayer.UserId, true)
        end)
    end
    
    -- MÉTODO 3: Usar IM_GamepassAll para conceder todos
    if Remotes.IM_GamepassAll then
        Log("EXPLOIT", "Disparando IM_GamepassAll...")
        pcall(function()
            -- Tentar conceder todos os gamepasses
            Remotes.IM_GamepassAll:FireServer()
            Remotes.IM_GamepassAll:FireServer(true)
            Remotes.IM_GamepassAll:FireServer(LocalPlayer.UserId)
        end)
    end
    
    -- MÉTODO 4: Adicionar unlockables específicos
    if Remotes.IM_UnlockableAdd then
        Log("EXPLOIT", "Adicionando unlockables via IM_UnlockableAdd...")
        
        local unlockables = {
            "plus", "premium", "vip", "admin", 
            "all_vehicles", "all_houses", "all_emotes"
        }
        
        for _, unlock in ipairs(unlockables) do
            pcall(function()
                Remotes.IM_UnlockableAdd:FireServer(unlock)
                Remotes.IM_UnlockableAdd:FireServer(LocalPlayer.UserId, unlock)
            end)
        end
    end
    
    -- MÉTODO 5: Spoof no ReplicaSystem (sincronização de dados)
    if Remotes.ReplicaSet then
        Log("EXPLOIT", "Tentando spoof via ReplicaSystem...")
        pcall(function()
            -- Tentar setar valores no sistema de replicação
            Remotes.ReplicaSet:FireServer("Plus", true)
            Remotes.ReplicaSet:FireServer("Premium", true)
            Remotes.ReplicaSet:FireServer("HasGamepass", true)
        end)
    end
    
    if Remotes.ReplicaWrite then
        pcall(function()
            Remotes.ReplicaWrite:FireServer("PlayerData", {
                Plus = true,
                Premium = true,
                PremiumExpires = tick() + 999999,
                AdRewards = {premium = true, plus = true}
            })
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- HOOK DE MARKETPLACESERVICE (BYPASS LOCAL)
-- ═══════════════════════════════════════════════════════════════

local function SetupMarketplaceBypass()
    Log("INFO", "Configurando bypass do MarketplaceService...")
    
    -- Hook UserOwnsGamePassAsync
    local oldUserOwns = MarketplaceService.UserOwnsGamePassAsync
    MarketplaceService.UserOwnsGamePassAsync = function(self, userId, gamePassId)
        Log("BYPASS", string.format("UserOwnsGamePassAsync chamado: User=%d, GamePass=%d", userId, gamePassId))
        
        if userId == LocalPlayer.UserId then
            Log("BYPASS", string.format("SPOOFING GamePass %d para TRUE", gamePassId))
            State.GamepassesGranted[gamePassId] = true
            return true
        end
        
        return oldUserOwns(self, userId, gamePassId)
    end
    
    -- Hook PlayerOwnsAsset
    local oldOwnsAsset = MarketplaceService.PlayerOwnsAsset
    MarketplaceService.PlayerOwnsAsset = function(self, player, assetId)
        if player == LocalPlayer then
            Log("BYPASS", string.format("SPOOFING Asset %d para TRUE", assetId))
            return true
        end
        return oldOwnsAsset(self, player, assetId)
    end
    
    -- Hook PromptGamePassPurchaseFinished
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        Log("BYPASS", string.format("Compra finalizada: GamePass=%d, Purchased=%s", gamePassId, tostring(wasPurchased)))
        
        if player == LocalPlayer and not wasPurchased then
            -- Spoof o evento dizendo que comprou
            Log("BYPASS", "Spoofando evento de compra...")
            -- Não podemos re-disparar o evento, mas podemos setar flags
        end
    end)
    
    -- Hook PromptProductPurchaseFinished
    MarketplaceService.PromptProductPurchaseFinished:Connect(function(playerReceiptInfo, wasPurchased)
        Log("BYPASS", string.format("Product purchase: Purchased=%s", tostring(wasPurchased)))
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- INJEÇÃO DE ESTADO NO PLAYER E GUI
-- ═══════════════════════════════════════════════════════════════

local function InjectPremiumState()
    Log("INFO", "Injetando estado Premium no Player...")
    
    -- Criar valores no Player
    local values = {
        {name = "HasBrookhavenPlus", type = "BoolValue", value = true},
        {name = "HasPremium", type = "BoolValue", value = true},
        {name = "HasVIP", type = "BoolValue", value = true},
        {name = "IsPlusMember", type = "BoolValue", value = true},
        {name = "PlusExpires", type = "NumberValue", value = tick() + 999999},
        {name = "PremiumExpires", type = "NumberValue", value = tick() + 999999},
        {name = "AdRewardActive", type = "BoolValue", value = true},
        {name = "AdRewardTimeRemaining", type = "NumberValue", value = 999999},
        {name = "FreePremiumTime", type = "NumberValue", value = 999999},
        {name = "GamepassPlus", type = "BoolValue", value = true},
        {name = "GamepassPremium", type = "BoolValue", value = true},
        {name = "CanUsePremiumFeatures", type = "BoolValue", value = true},
    }
    
    for _, v in ipairs(values) do
        pcall(function()
            local existing = LocalPlayer:FindFirstChild(v.name)
            if not existing then
                local newVal
                if v.type == "BoolValue" then
                    newVal = Instance.new("BoolValue")
                elseif v.type == "NumberValue" then
                    newVal = Instance.new("NumberValue")
                elseif v.type == "IntValue" then
                    newVal = Instance.new("IntValue")
                end
                
                if newVal then
                    newVal.Name = v.name
                    newVal.Value = v.value
                    newVal.Parent = LocalPlayer
                    Log("INJECT", string.format("Criado %s = %s", v.name, tostring(v.value)))
                end
            else
                existing.Value = v.value
                Log("INJECT", string.format("Modificado %s = %s", v.name, tostring(v.value)))
            end
        end)
    end
    
    -- Setar atributos também
    local attributes = {
        HasPlus = true,
        HasPremium = true,
        HasVIP = true,
        PlusActive = true,
        PremiumActive = true,
        AdReward = true,
        CanUsePremium = true,
        GamepassPlus = true,
        GamepassPremium = true,
    }
    
    for attr, val in pairs(attributes) do
        pcall(function()
            LocalPlayer:SetAttribute(attr, val)
            Log("INJECT", string.format("Atributo %s = %s", attr, tostring(val)))
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INTERCEPTAR E SPOOFAR EVENTOS DO JOGO
-- ═══════════════════════════════════════════════════════════════

local function InterceptGameEvents()
    Log("INFO", "Interceptando eventos do jogo...")
    
    -- Interceptar PlusUpsell (quando o jogo tenta vender Plus)
    if Remotes.PlusUpsell then
        Remotes.PlusUpsell.OnClientEvent:Connect(function(data)
            Log("INTERCEPT", "PlusUpsell recebido do servidor", data)
            -- Em vez de mostrar o upsell, ativar Plus diretamente
            BypassPlusSystem()
        end)
    end
    
    -- Interceptar ShowGamepass
    if Remotes.ShowGamepass then
        Remotes.ShowGamepass.OnClientEvent:Connect(function(gamepassId)
            Log("INTERCEPT", string.format("ShowGamepass recebido: %d", gamepassId))
            -- Spoof como já comprado
            State.GamepassesGranted[gamepassId] = true
        end)
    end
    
    -- Interceptar ReplicaCreate (novos dados replicados)
    if Remotes.ReplicaCreate then
        Remotes.ReplicaCreate.OnClientEvent:Connect(function(replicaId, data)
            Log("INTERCEPT", string.format("ReplicaCreate: %s", tostring(replicaId)), data)
            
            -- Se for dados do player, injetar premium
            if data and type(data) == "table" then
                if data.PlayerData or data.playerId == LocalPlayer.UserId then
                    -- Modificar dados para incluir premium
                    if data.PlayerData then
                        data.PlayerData.Plus = true
                        data.PlayerData.Premium = true
                        data.PlayerData.HasGamepass = true
                    end
                end
            end
        end)
    end
    
    -- Interceptar ReplicaSet
    if Remotes.ReplicaSet then
        Remotes.ReplicaSet.OnClientEvent:Connect(function(path, value)
            Log("INTERCEPT", string.format("ReplicaSet: %s = %s", tostring(path), tostring(value)))
            
            -- Se o servidor tentar desativar premium, reverter
            if path == "Plus" or path == "Premium" or path == "HasGamepass" then
                if value == false then
                    Log("INTERCEPT", "Servidor tentou desativar premium! Revertendo...")
                    task.delay(0.1, function()
                        pcall(function()
                            Remotes.ReplicaSet:FireServer(path, true)
                        end)
                    end)
                end
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO-EXECUÇÃO CONTÍNUA
-- ═══════════════════════════════════════════════════════════════

local function StartAutoBypass()
    Log("INFO", "Iniciando auto-bypass contínuo...")
    
    -- Executar imediatamente
    BypassAdSystem()
    task.wait(0.5)
    BypassPlusSystem()
    task.wait(0.5)
    InjectPremiumState()
    
    -- Loop contínuo
    task.spawn(function()
        while task.wait(3) do
            if not State.AdSystemBypassed then
                BypassAdSystem()
            end
            if not State.PlusActive then
                BypassPlusSystem()
            end
            InjectPremiumState()
        end
    end)
    
    -- Re-injetar quando character respawnar
    LocalPlayer.CharacterAdded:Connect(function()
        Log("INFO", "Character respawnado, re-injetando estado...")
        task.wait(1)
        InjectPremiumState()
        BypassPlusSystem()
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- INTERFACE DO SCRIPT
-- ═══════════════════════════════════════════════════════════════

local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BrookhavenBypass_v2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 420, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Gradiente sutil
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    })
    Gradient.Parent = MainFrame
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Title.Text = "🔓 Brookhaven Bypass v2.0"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Status
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 80)
    StatusFrame.Position = UDim2.new(0, 10, 0, 55)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -10, 1, -10)
    StatusText.Position = UDim2.new(0, 5, 0, 5)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "⏳ Inicializando..."
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 13
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextYAlignment = Enum.TextYAlignment.Top
    StatusText.TextWrapped = true
    StatusText.Parent = StatusFrame
    
    -- Botões
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -20, 0, 40)
    ButtonFrame.Position = UDim2.new(0, 10, 0, 145)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = MainFrame
    
    local function CreateButton(text, pos, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = ButtonFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        -- Efeito hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.2)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    CreateButton("🔄 Re-Bypass", UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 120, 200), function()
        Log("UI", "Re-Bypass manual acionado")
        BypassAdSystem()
        task.wait(0.3)
        BypassPlusSystem()
        task.wait(0.3)
        InjectPremiumState()
        UpdateStatus()
    end)
    
    CreateButton("📋 Copy Logs", UDim2.new(0, 130, 0, 0), Color3.fromRGB(80, 80, 90), function()
        local logText = ""
        for _, entry in ipairs(State.Logs) do
            logText = logText .. string.format("[%s] %s: %s\n", entry.time, entry.level, entry.message)
        end
        if setclipboard then
            setclipboard(logText)
            Log("UI", "Logs copiados!")
        end
    end)
    
    CreateButton("❌ Fechar", UDim2.new(0, 260, 0, 0), Color3.fromRGB(200, 50, 50), function()
        ScreenGui:Destroy()
    end)
    
    -- Log area
    local LogFrame = Instance.new("ScrollingFrame")
    LogFrame.Size = UDim2.new(1, -20, 0, 110)
    LogFrame.Position = UDim2.new(0, 10, 0, 195)
    LogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    LogFrame.BorderSizePixel = 0
    LogFrame.ScrollBarThickness = 3
    LogFrame.Parent = MainFrame
    
    local LogCorner = Instance.new("UICorner")
    LogCorner.CornerRadius = UDim.new(0, 8)
    LogCorner.Parent = LogFrame
    
    local LogList = Instance.new("UIListLayout")
    LogList.SortOrder = Enum.SortOrder.LayoutOrder
    LogList.Padding = UDim.new(0, 1)
    LogList.Parent = LogFrame
    
    -- Override Log para UI
    local oldLog = Log
    Log = function(level, message, data)
        oldLog(level, message, data)
        
        pcall(function()
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 18)
            label.BackgroundTransparency = 1
            
            local colors = {
                INFO = Color3.fromRGB(100, 200, 255),
                FOUND = Color3.fromRGB(100, 255, 100),
                EXPLOIT = Color3.fromRGB(255, 150, 50),
                BYPASS = Color3.fromRGB(255, 100, 200),
                INJECT = Color3.fromRGB(100, 255, 200),
                INTERCEPT = Color3.fromRGB(200, 200, 100),
                WARN = Color3.fromRGB(255, 200, 50),
                ERROR = Color3.fromRGB(255, 50, 50),
                UI = Color3.fromRGB(150, 150, 255)
            }
            
            label.TextColor3 = colors[level] or Color3.fromRGB(200, 200, 200)
            label.Text = string.format("[%s] %s", level, message)
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.Parent = LogFrame
            
            LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y + 10)
            LogFrame.CanvasPosition = Vector2.new(0, LogList.AbsoluteContentSize.Y)
        end)
    end
    
    -- Função de atualização de status
    function UpdateStatus()
        local status = "🔍 Status do Bypass:\n\n"
        
        status = status .. string.format("📡 Remotes Encontrados: %d\n", #State.Remotes)
        status = status .. string.format("🎬 Ad System Bypassed: %s\n", State.AdSystemBypassed and "✅ SIM" or "❌ Não")
        status = status .. string.format("⭐ Plus Ativo: %s\n", State.PlusActive and "✅ SIM" or "❌ Não")
        status = status .. string.format("🎮 Gamepasses Spoofed: %d\n", #State.GamepassesGranted)
        status = status .. string.format("🎭 Fake Ad Watched: %s\n", State.FakeAdWatched and "✅ SIM" or "❌ Não")
        
        StatusText.Text = status
    end
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Atualizar status periodicamente
    task.spawn(function()
        while task.wait(2) do
            if ScreenGui and ScreenGui.Parent then
                UpdateStatus()
            else
                break
            end
        end
    end)
    
    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════

local function Initialize()
    Log("INFO", "═══════════════════════════════════════")
    Log("INFO", "Brookhaven Bypass v2.0 Iniciado")
    Log("INFO", "═══════════════════════════════════════")
    
    -- Setup
    SetupMarketplaceBypass()
    InterceptGameEvents()
    
    -- UI
    local ui = CreateUI()
    
    -- Auto bypass
    StartAutoBypass()
    
    Log("INFO", "Inicialização completa!")
end

-- Proteção
local success, err = pcall(Initialize)
if not success then
    Log("ERROR", "Erro fatal: " .. tostring(err))
end
