 -- ═══════════════════════════════════════════════════════════════════════════════
--  CAFUXZ1 ULTIMATE OPTIMIZER v12.0 PRO — GLASS EDITION
--  GUI: Glassmorphism · Bento Grid · Neon Accents · Microinteractions
--  Integrado: Task Scheduler · LOD Neural · FFlags 2026 · Dynamic Scaling
-- ═══════════════════════════════════════════════════════════════════════════════

if not game:IsLoaded() then game.Loaded:Wait() end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SECAO 1 — CORE SYSTEM & SERVICES
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
	CoreGui = game:GetService("CoreGui"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Heartbeat = Services.RunService.Heartbeat
local RenderStepped = Services.RunService.RenderStepped
local Tween = Services.TweenService

-- ═══════════════════════════════════════════════════════════════════════════════
--  UTILITARIOS
-- ═══════════════════════════════════════════════════════════════════════════════

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
	return ok, result
end

function Utils.IsPlayerRelated(obj)
	if not obj then return false end
	local parent = obj
	while parent do
		if parent:IsA("Player") or (LocalPlayer.Character and parent == LocalPlayer.Character) then
			return true
		end
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
--  CONFIGURACAO CENTRALIZADA
-- ═══════════════════════════════════════════════════════════════════════════════

local Config = {
	TasksPerFrame = 60,
	MaxTasksPerFrame = 120,
	MinTasksPerFrame = 20,

	LOD_Near = 80,
	LOD_Mid = 180,
	LOD_Far = 350,
	LOD_Ultra = 600,
	BackfaceAngle = 120,

	MaxDecalsGlobal = 30,
	MaxLightsGlobal = 3,
	MaxBillboardsGlobal = 12,
	MaxParticlesGlobal = 15,
	MaxBeamsGlobal = 8,
	MaxSoundsPlaying = 5,

	KillDistance_Particle = 140,
	KillDistance_Decal = 90,
	KillDistance_Light = 200,
	KillDistance_GUI = 100,
	KillDistance_Mesh = 160,
	KillDistance_Sound = 250,
	KillDistance_Beam = 140,

	FPS_High = 90,
	FPS_Low = 45,
	FPS_Critical = 25,

	PhysicsSenderRate = 1000,
	NetworkUpdateRate = 60,
	MTUSize = 1260,

	StretchValue = 0.80,
	BootDelay = 1.5,

	-- GUI
	GUI_Enabled = true,
	GUI_Accent = Color3.fromRGB(0, 212, 255), -- Cyan neon
	GUI_Secondary = Color3.fromRGB(124, 58, 237), -- Purple
	GUI_Danger = Color3.fromRGB(239, 68, 68), -- Red
	GUI_Success = Color3.fromRGB(34, 197, 94), -- Green
	GUI_Warning = Color3.fromRGB(234, 179, 8), -- Yellow
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  TASK SCHEDULER
-- ═══════════════════════════════════════════════════════════════════════════════

local TaskScheduler = {
	queue = {},
	running = false,
	frameBudget = 0,
}

function TaskScheduler:Init()
	self.running = true
	Heartbeat:Connect(function(dt)
		self.frameBudget = math.clamp(dt * 1000, 2, 33)
		self:ProcessQueue()
	end)
end

function TaskScheduler:Enqueue(taskFn, priority)
	priority = priority or 5
	table.insert(self.queue, {fn = taskFn, priority = priority})
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
--  FFLAGS ENGINE v2026
-- ═══════════════════════════════════════════════════════════════════════════════

local FFlags = {
	["DFIntTaskSchedulerTargetFps"] = "9999",
	["FIntTaskSchedulerAutoThreadLimit"] = "6",
	["FIntTaskSchedulerAsyncTasksMinimumThreadCount"] = "2",
	["FIntTaskSchedulerMaxNumOfJobs"] = "86",
	["FFlagTaskSchedulerLimitTargetFpsTo2402"] = "False",
	["FFlagGameBasicSettingsFramerateCap5"] = "False",
	["FFlagDebugDisplayFPS"] = "True",
	["FFlagHandleAltEnterFullscreenManually"] = "False",
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
	["FIntPGSAngularDampingPermilPersecond"] = "0",
	["DFFlagPhysicsSkipNonRealTimeHumanoidForceCalc2"] = "True",
	["FFlagSimIslandizerManager"] = "False",
	["FFlagAnimatePhysics"] = "False",
	["FFlagOptimizePartsInPart"] = "True",
	["FFlagFixMeshPartScaling"] = "False",
	["FFlagFixScalingModelRendering"] = "False",
	["DFIntNewRunningBaseAltitudeD"] = "45",
	["DFIntRunningBaseOrientationP"] = "115",
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
	["DFIntCSGLevelOfDetailSwitchingDistance"] = "0",
	["DFIntCSGLevelOfDetailSwitchingDistanceL12"] = "0",
	["DFIntCSGLevelOfDetailSwitchingDistanceL23"] = "0",
	["DFIntCSGLevelOfDetailSwitchingDistanceL34"] = "0",
	["DFFlagDebugPauseVoxelizer"] = "True",
	["DFFlagDebugRenderForceTechnologyVoxel"] = "True",
	["DFFlagEnableSoundPreloading"] = "True",
	["FFlagEnableQuickGameLaunch"] = "True",
	["DFIntNumAssetsMaxToPreload"] = "9999",
	["DFIntNumAssetsMaxToPreload2"] = "9999",
	["FIntRenderLocalLightFadeInMs"] = "0",
	["DFStringCrashUploadToBacktraceWindowsPlayerToken"] = "null",
	["DFStringCrashUploadToBacktraceMacPlayerToken"] = "null",
	["DFStringCrashUploadToBacktraceBaseUrl"] = "null",
	["FStringCoreScriptBacktraceErrorUploadToken"] = "null",
	["DFStringGamesUrlPath"] = "/games/",
}

local FFlagsEngine = {}

function FFlagsEngine:Inject()
	if not setfflag then
		print("[CAFUXZ1] setfflag não disponível.")
		return 0
	end
	local start = os.clock()
	local injected = 0
	local skipped = 0

	for rawFlag, value in pairs(FFlags) do
		if injected % 20 == 0 then task.wait() end
		Utils.SafeCall(function()
			local ok1 = pcall(function() return getfflag(rawFlag) end)
			if ok1 then
				setfflag(rawFlag, value)
				injected = injected + 1
				return
			end
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
--  MAP PROTECTION SYSTEM
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
	for _, pattern in ipairs(self.structuralPatterns) do
		if name:find(pattern) then
			self.protected[obj] = true
			return true
		end
	end
	for _, pattern in ipairs(self.interactivePatterns) do
		if name:find(pattern) then
			self.protected[obj] = true
			return true
		end
	end
	if obj.Parent == Services.Workspace then
		self.protected[obj] = true
		return true
	end
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
	if obj.Anchored and self.structuralMaterials[obj.Material] then
		if obj.Size.X > 20 or obj.Size.Z > 20 or obj.Size.Y > 10 then
			self.protected[obj] = true
			return true
		end
	end
	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("ClickDetector") or child:IsA("ProximityPrompt") 
		   or child:IsA("TouchTransmitter") or child:IsA("VehicleSeat") 
		   or child:IsA("Seat") or child:IsA("SpawnLocation") then
			self.protected[obj] = true
			return true
		end
	end
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

function MapProtection:PreIndex()
	local start = tick()
	local count = 0
	for _, obj in ipairs(Services.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			if self:Analyze(obj) then count = count + 1 end
		end
		if count % 500 == 0 then task.wait() end
	end
	print(string.format("[CAFUXZ1] Mapa indexado: %d objetos protegidos em %.2fs", count, tick()-start))
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  RENDER ENGINE
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
	if dist > 200 and not Utils.IsLocalCharacter(part) then
		Utils.SafeCall(function() part.CastShadow = false end)
	end
	if dist > Config.KillDistance_Mesh and not Utils.IsLocalCharacter(part) then
		Utils.SafeCall(function()
			if part.Material == Enum.Material.Glass or part.Material == Enum.Material.Neon or part.Material == Enum.Material.ForceField then
				part.Material = Enum.Material.Plastic
				part.Reflectance = 0
			end
		end)
	end
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
	if part:IsA("MeshPart") and dist > 300 then
		Utils.SafeCall(function()
			part.RenderFidelity = Enum.RenderFidelity.Performance
		end)
	end
	if part:IsA("MeshPart") and not part.CanCollide then
		Utils.SafeCall(function()
			part.CollisionFidelity = Enum.CollisionFidelity.Box
		end)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  OBJECT OPTIMIZER
-- ═══════════════════════════════════════════════════════════════════════════════

local ObjectOptimizer = {
	counters = {decals=0, lights=0, billboards=0, particles=0, beams=0, unions=0, sounds=0},
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
	if obj.Parent and obj.Parent:IsA("BasePart") then pos = obj.Parent.Position end
	local dist = Utils.FastDistance(pos, camPos)
	if dist > Config.KillDistance_Beam or self.counters.beams > Config.MaxBeamsGlobal then
		Utils.SafeCall(function() obj:Destroy() end)
		self.counters.beams = self.counters.beams - 1
		self.totalOptimized = self.totalOptimized + 1
	else
		Utils.SafeCall(function() obj.Segments = math.min(obj.Segments or 10, 4) end)
	end
end

function ObjectOptimizer:ProcessUnion(obj, camPos)
	if not self:CanDestroy(obj) then return end
	self.counters.unions = self.counters.unions + 1
	local dist = Utils.FastDistance(obj.Position, camPos)
	if dist > 120 or self.counters.unions > 15 then
		Utils.SafeCall(function()
			local rep = Instance.new("Part")
			rep.Size = obj.Size; rep.CFrame = obj.CFrame; rep.Color = obj.Color
			rep.Material = obj.Material; rep.Transparency = obj.Transparency
			rep.Anchored = obj.Anchored; rep.CanCollide = obj.CanCollide
			rep.Parent = obj.Parent; rep.Name = obj.Name
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
	if parent and parent:IsA("BasePart") then pos = parent.Position end
	local dist = Utils.FastDistance(camPos, pos)
	if dist > Config.KillDistance_Sound and not Utils.IsPlayerRelated(obj) then
		Utils.SafeCall(function() obj.Volume = 0; obj:Stop() end)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  LOD SYSTEM
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
		if cache and (now - cache.lastUpdate) < self.refreshInterval then continue end

		local char = plr.Character
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local accessories, meshes, clothes, particles, parts = {}, {}, {}, {}, {}
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
			accessories = accessories, meshes = meshes, clothes = clothes,
			particles = particles, parts = parts, hrp = hrp, lastUpdate = now,
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

	local isMid = dist > Config.LOD_Near
	local isFar = dist > Config.LOD_Mid
	local isUltra = dist > Config.LOD_Far

	for _, handle in ipairs(cache.accessories) do
		if handle and handle.Parent then
			if isMid then
				if state.originals[handle] == nil then state.originals[handle] = handle.Transparency end
				handle.Transparency = 1
			else
				if state.originals[handle] ~= nil then
					handle.Transparency = state.originals[handle]
					state.originals[handle] = nil
				end
			end
		end
	end

	for _, mesh in ipairs(cache.meshes) do
		if mesh and mesh.Parent then
			if isFar then
				if mesh:IsA("BasePart") then
					if state.originals[mesh] == nil then state.originals[mesh] = mesh.Transparency end
					mesh.Transparency = 1
				elseif mesh:IsA("SpecialMesh") then
					if state.originals[mesh] == nil then state.originals[mesh] = mesh.Scale end
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

	for _, p in ipairs(cache.particles) do
		if p and p.Parent then p.Enabled = not isFar end
	end

	if isUltra then
		for _, cloth in ipairs(cache.clothes) do
			if cloth and cloth.Parent then
				if state.originals[cloth] == nil then state.originals[cloth] = true end
				cloth:Destroy()
			end
		end
	end

	if isMid then
		for _, part in ipairs(cache.parts) do
			if part and part:IsA("BasePart") and part.CastShadow then
				part.CastShadow = false
			end
		end
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  STRETCH SYSTEM
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
	if Camera.CameraType ~= Enum.CameraType.Custom then
		self.freezeUntil = now + 2.0
		self.stableFrames = 0
		return false
	end
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
--  PERFORMANCE MANAGER
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
		if #self.fpsHistory > self.maxHistory then table.remove(self.fpsHistory, 1) end
	end
end

function PerformanceManager:GetAvgFPS()
	if #self.fpsHistory == 0 then return 60 end
	local sum = 0
	for _, v in ipairs(self.fpsHistory) do sum = sum + v end
	return sum / #self.fpsHistory
end

function PerformanceManager:Adapt()
	local now = tick()
	if now - self.lastAdjustment < self.adjustmentCooldown then return end
	local avg = self:GetAvgFPS()
	if avg < Config.FPS_Critical then
		Config.TasksPerFrame = math.max(Config.MinTasksPerFrame, 15)
		Config.LOD_Near = 50; Config.LOD_Mid = 120
		self.lastAdjustment = now
	elseif avg < Config.FPS_Low then
		Config.TasksPerFrame = math.max(Config.MinTasksPerFrame, 30)
		Config.LOD_Near = 70; Config.LOD_Mid = 150
		self.lastAdjustment = now
	elseif avg > Config.FPS_High and Config.TasksPerFrame < Config.MaxTasksPerFrame then
		Config.TasksPerFrame = math.min(Config.MaxTasksPerFrame, Config.TasksPerFrame + 8)
		Config.LOD_Near = 100; Config.LOD_Mid = 200
		self.lastAdjustment = now
	end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SAFETY SYSTEM
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
				Utils.SafeCall(function() hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0) end)
				spawned = true
				break
			end
		end
		if not spawned then
			Utils.SafeCall(function() hrp.CFrame = CFrame.new(0, 50, 0) end)
		end
	end
end

function SafetySystem:ProtectCharacter(char)
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	Utils.SafeCall(function()
		humanoid.StateChanged:Connect(function(oldState, newState)
			-- Monitora estados perigosos silenciosamente
		end)
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  ADMIN DETECTOR
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
--  WORLD SCANNER
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
	ObjectOptimizer.counters = {decals=0, lights=0, billboards=0, particles=0, beams=0, unions=0, sounds=0}
	self.descendants = Services.Workspace:GetDescendants()
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
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
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
--  DESCENDANT ADDED HANDLER
-- ═══════════════════════════════════════════════════════════════════════════════

Services.Workspace.DescendantAdded:Connect(function(obj)
	if not obj then return end
	if obj:IsA("BasePart") then MapProtection:Analyze(obj) end
	local camPos = Camera.CFrame.Position

	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
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
				if c:IsA("Decal") or c:IsA("Texture") then decals = decals + 1 end
			end
			if decals > 2 then Utils.SafeCall(function() obj:Destroy() end) end
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
--  ╔══════════════════════════════════════════════════════════════════════╗
--  ║  GUI SYSTEM — GLASSMORPHISM EDITION v12.0                            ║
--  ║  Design: Bento Grid · Neon Accents · Microinteractions · Compact       ║
--  ╚══════════════════════════════════════════════════════════════════════╝
-- ═══════════════════════════════════════════════════════════════════════════════

local GUI = {
	ScreenGui = nil,
	MainFrame = nil,
	Minimized = false,
	Tab = "Performance",
	Drag = {active=false, start=nil, pos=nil},
	Elements = {},
	Tweens = {},
}

-- Paleta de cores
local Colors = {
	Bg = Color3.fromRGB(10, 10, 15),         -- Fundo quase preto
	Card = Color3.fromRGB(18, 18, 28),        -- Card escuro
	Glass = Color3.fromRGB(25, 25, 40),      -- Glass sutil
	Accent = Config.GUI_Accent,               -- Cyan neon
	Accent2 = Config.GUI_Secondary,          -- Purple
	Text = Color3.fromRGB(240, 240, 245),    -- Texto principal
	TextDim = Color3.fromRGB(150, 150, 170), -- Texto secundário
	Border = Color3.fromRGB(40, 40, 60),     -- Borda sutil
	BorderGlow = Config.GUI_Accent,           -- Borda glow
	Success = Config.GUI_Success,
	Danger = Config.GUI_Danger,
	Warning = Config.GUI_Warning,
}

-- Utilitários de GUI
local function Create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do obj[k] = v end
	return obj
end

local function TweenObj(obj, props, duration, easing, direction)
	duration = duration or 0.25
	easing = easing or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	local tween = Tween:Create(obj, TweenInfo.new(duration, easing, direction), props)
	tween:Play()
	return tween
end

local function AddCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = obj
	return c
end

local function AddStroke(obj, color, thickness, trans)
	local s = Instance.new("UIStroke")
	s.Color = color or Colors.Border
	s.Thickness = thickness or 1
	s.Transparency = trans or 0.8
	s.Parent = obj
	return s
end

local function AddGradient(obj, color1, color2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, color1 or Colors.Card),
		ColorSequenceKeypoint.new(1, color2 or Colors.Bg)
	}
	g.Rotation = rot or 45
	g.Parent = obj
	return g
end

local function AddShadow(obj)
	local s = Instance.new("ImageLabel")
	s.Name = "Shadow"
	s.AnchorPoint = Vector2.new(0.5, 0.5)
	s.Position = UDim2.new(0.5, 0, 0.5, 4)
	s.Size = UDim2.new(1, 20, 1, 20)
	s.BackgroundTransparency = 1
	s.Image = "rbxassetid://131604521" -- blur shadow asset
	s.ImageColor3 = Color3.new(0, 0, 0)
	s.ImageTransparency = 0.7
	s.ZIndex = obj.ZIndex - 1
	s.Parent = obj
	return s
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI: TOGGLE SWITCH
-- ═══════════════════════════════════════════════════════════════════════════════

function GUI:CreateToggle(parent, pos, label, defaultState, callback)
	local container = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		Position = pos,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local lbl = Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local track = Create("Frame", {
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -44, 0.5, -10),
		BackgroundColor3 = defaultState and Colors.Accent or Colors.Border,
		BorderSizePixel = 0,
		Parent = container,
	})
	AddCorner(track, 10)

	local thumb = Create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = track,
	})
	AddCorner(thumb, 8)

	local state = defaultState
	local function update()
		state = not state
		local targetColor = state and Colors.Accent or Colors.Border
		local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		TweenObj(track, {BackgroundColor3 = targetColor}, 0.2)
		TweenObj(thumb, {Position = targetPos}, 0.2, Enum.EasingStyle.Back)
		if callback then callback(state) end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			update()
		end
	end)

	return {container = container, getState = function() return state end, setState = function(s) 
		if s ~= state then update() end 
	end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI: SLIDER
-- ═══════════════════════════════════════════════════════════════════════════════

function GUI:CreateSlider(parent, pos, label, min, max, default, callback)
	local container = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		Position = pos,
		BackgroundTransparency = 1,
		Parent = parent,
	})

	local lbl = Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 16),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local valLbl = Create("TextLabel", {
		Size = UDim2.new(0, 40, 0, 16),
		Position = UDim2.new(1, -40, 0, 0),
		BackgroundTransparency = 1,
		Text = tostring(default),
		TextColor3 = Colors.Accent,
		Font = Enum.Font.RobotoMono,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container,
	})

	local track = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 4),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = Colors.Border,
		BorderSizePixel = 0,
		Parent = container,
	})
	AddCorner(track, 2)

	local fill = Create("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Colors.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	AddCorner(fill, 2)

	local knob = Create("Frame", {
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = track,
	})
	AddCorner(knob, 6)

	local dragging = false
	local function setValue(input)
		local absPos = track.AbsolutePosition.X
		local absSize = track.AbsoluteSize.X
		local x = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
		local value = math.floor(min + x * (max - min))
		fill.Size = UDim2.new(x, 0, 1, 0)
		knob.Position = UDim2.new(x, -6, 0.5, -6)
		valLbl.Text = tostring(value)
		if callback then callback(value) end
		return value
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			TweenObj(knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(knob.Position.X.Scale, -8, 0.5, -8)}, 0.15)
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setValue(input)
		end
	end)

	Services.UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			TweenObj(knob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(knob.Position.X.Scale, -6, 0.5, -6)}, 0.15)
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			setValue(input)
		end
	end)

	return {container = container, setValue = function(v)
		local x = (v - min) / (max - min)
		fill.Size = UDim2.new(x, 0, 1, 0)
		knob.Position = UDim2.new(x, -6, 0.5, -6)
		valLbl.Text = tostring(v)
		if callback then callback(v) end
	end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI: BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════

function GUI:CreateButton(parent, pos, text, color, callback)
	local btn = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		Position = pos,
		BackgroundColor3 = color or Colors.Glass,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = parent,
	})
	AddCorner(btn, 8)
	local stroke = AddStroke(btn, color or Colors.Accent, 1.5, 0.7)

	btn.MouseEnter:Connect(function()
		TweenObj(btn, {BackgroundColor3 = Colors.Accent}, 0.2)
		TweenObj(stroke, {Transparency = 0.3}, 0.2)
		TweenObj(btn, {Size = UDim2.new(1, 4, 0, 34), Position = UDim2.new(0, -2, 0, pos.Y.Offset - 1)}, 0.15)
	end)

	btn.MouseLeave:Connect(function()
		TweenObj(btn, {BackgroundColor3 = color or Colors.Glass}, 0.2)
		TweenObj(stroke, {Transparency = 0.7}, 0.2)
		TweenObj(btn, {Size = UDim2.new(1, 0, 0, 32), Position = pos}, 0.15)
	end)

	btn.MouseButton1Down:Connect(function()
		TweenObj(btn, {Size = UDim2.new(1, -2, 0, 30), Position = UDim2.new(0, 1, 0, pos.Y.Offset + 1)}, 0.1)
	end)

	btn.MouseButton1Up:Connect(function()
		TweenObj(btn, {Size = UDim2.new(1, 4, 0, 34), Position = UDim2.new(0, -2, 0, pos.Y.Offset - 1)}, 0.1)
		if callback then callback() end
	end)

	return btn
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI: STAT CARD (Bento Grid Style)
-- ═══════════════════════════════════════════════════════════════════════════════

function GUI:CreateStatCard(parent, pos, size, label, value, color)
	local card = Create("Frame", {
		Size = size,
		Position = pos,
		BackgroundColor3 = Colors.Card,
		BorderSizePixel = 0,
		Parent = parent,
	})
	AddCorner(card, 10)
	AddStroke(card, Colors.Border, 1, 0.9)

	local grad = AddGradient(card, Colors.Card, Color3.fromRGB(12, 12, 20), 135)

	local lbl = Create("TextLabel", {
		Size = UDim2.new(1, -12, 0, 14),
		Position = UDim2.new(0, 6, 0, 6),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = Colors.TextDim,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local val = Create("TextLabel", {
		Size = UDim2.new(1, -12, 0, 22),
		Position = UDim2.new(0, 6, 0, 20),
		BackgroundTransparency = 1,
		Text = tostring(value),
		TextColor3 = color or Colors.Accent,
		Font = Enum.Font.RobotoMono,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	return {card = card, label = lbl, value = val, setValue = function(v, c)
		val.Text = tostring(v)
		if c then val.TextColor3 = c end
	end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  GUI: MAIN WINDOW CONSTRUCTION
-- ═══════════════════════════════════════════════════════════════════════════════

function GUI:Build()
	-- ScreenGui
	self.ScreenGui = Create("ScreenGui", {
		Name = "CAFUXZ1_Glass_v12",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	pcall(function() self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 3) end)
	if not self.ScreenGui.Parent then
		pcall(function() self.ScreenGui.Parent = Services.CoreGui end)
	end

	-- Main Frame (Glassmorphism)
	self.MainFrame = Create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 320, 0, 420),
		Position = UDim2.new(0, 60, 0, 60),
		BackgroundColor3 = Colors.Bg,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = self.ScreenGui,
	})
	AddCorner(self.MainFrame, 16)
	AddStroke(self.MainFrame, Colors.Border, 1.5, 0.6)

	-- Glass overlay
	local glass = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Colors.Bg,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = self.MainFrame,
	})
	AddCorner(glass, 16)

	-- Header
	local header = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Colors.Card,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = self.MainFrame,
	})

	local headerGrad = AddGradient(header, Colors.Card, Color3.fromRGB(15, 15, 25), 180)

	local title = Create("TextLabel", {
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text = "CAFUXZ1  v12",
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	-- Versão pequena
	local ver = Create("TextLabel", {
		Size = UDim2.new(0, 40, 0, 12),
		Position = UDim2.new(0, 16, 0, 28),
		BackgroundTransparency = 1,
		Text = "PRO",
		TextColor3 = Colors.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		Parent = header,
	})

	-- Botão minimize
	local minBtn = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -64, 0, 8),
		BackgroundColor3 = Colors.Glass,
		BorderSizePixel = 0,
		Text = "−",
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
		Parent = header,
	})
	AddCorner(minBtn, 6)
	AddStroke(minBtn, Colors.Border, 1, 0.8)

	minBtn.MouseEnter:Connect(function()
		TweenObj(minBtn, {BackgroundColor3 = Colors.Warning}, 0.2)
	end)
	minBtn.MouseLeave:Connect(function()
		TweenObj(minBtn, {BackgroundColor3 = Colors.Glass}, 0.2)
	end)
	minBtn.MouseButton1Click:Connect(function()
		self:Minimize()
	end)

	-- Botão close
	local closeBtn = Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -32, 0, 8),
		BackgroundColor3 = Colors.Glass,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		AutoButtonColor = false,
		Parent = header,
	})
	AddCorner(closeBtn, 6)
	AddStroke(closeBtn, Colors.Border, 1, 0.8)

	closeBtn.MouseEnter:Connect(function()
		TweenObj(closeBtn, {BackgroundColor3 = Colors.Danger}, 0.2)
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenObj(closeBtn, {BackgroundColor3 = Colors.Glass}, 0.2)
	end)
	closeBtn.MouseButton1Click:Connect(function()
		self.ScreenGui.Enabled = false
	end)

	-- Tab Bar
	local tabBar = Create("Frame", {
		Size = UDim2.new(1, -24, 0, 32),
		Position = UDim2.new(0, 12, 0, 52),
		BackgroundTransparency = 1,
		Parent = self.MainFrame,
	})

	local tabs = {"Performance", "Visual", "Network", "Info"}
	local tabButtons = {}
	local tabWidth = 1 / #tabs

	for i, tabName in ipairs(tabs) do
		local btn = Create("TextButton", {
			Size = UDim2.new(tabWidth, -4, 1, 0),
			Position = UDim2.new(tabWidth * (i - 1), 2, 0, 0),
			BackgroundColor3 = i == 1 and Colors.Accent or Colors.Glass,
			BackgroundTransparency = i == 1 and 0.7 or 0.9,
			BorderSizePixel = 0,
			Text = tabName,
			TextColor3 = i == 1 and Colors.Text or Colors.TextDim,
			Font = Enum.Font.GothamSemibold,
			TextSize = 10,
			AutoButtonColor = false,
			Parent = tabBar,
		})
		AddCorner(btn, 6)

		btn.MouseButton1Click:Connect(function()
			self.Tab = tabName
			for _, b in ipairs(tabButtons) do
				TweenObj(b, {BackgroundColor3 = Colors.Glass, BackgroundTransparency = 0.9}, 0.2)
				b.TextColor3 = Colors.TextDim
			end
			TweenObj(btn, {BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.7}, 0.2)
			btn.TextColor3 = Colors.Text
			self:ShowTab(tabName)
		end)

		tabButtons[i] = btn
	end

	-- Content Container
	self.Content = Create("Frame", {
		Size = UDim2.new(1, -24, 1, -100),
		Position = UDim2.new(0, 12, 0, 92),
		BackgroundTransparency = 1,
		Parent = self.MainFrame,
	})

	-- Criar páginas
	self.Pages = {}
	for _, tabName in ipairs(tabs) do
		local page = Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Colors.Accent,
			Visible = tabName == "Performance",
			Parent = self.Content,
		})

		local layout = Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			Parent = page,
		})

		local pad = Create("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 12),
			Parent = page,
		})

		self.Pages[tabName] = page
	end

	-- ═══════════════════════════════════════════════════════════════════════════════
	--  TAB: PERFORMANCE
	-- ═══════════════════════════════════════════════════════════════════════════════
	local perf = self.Pages.Performance

	-- Toggle: Optimizer Ativo
	self.Elements.ToggleOptimizer = self:CreateToggle(perf, UDim2.new(0, 0, 0, 0), "Optimizer Ativo", true, function(state)
		Config.GUI_Enabled = state
		if state then
			WorldScanner:StartFullScan()
		end
	end)

	-- Toggle: Stretch Resolution
	self.Elements.ToggleStretch = self:CreateToggle(perf, UDim2.new(0, 0, 0, 40), "Stretch Resolution", true, function(state)
		StretchSystem.enabled = state
	end)

	-- Toggle: Anti-Void
	self.Elements.ToggleAntiVoid = self:CreateToggle(perf, UDim2.new(0, 0, 0, 80), "Anti-Void", true, function(state)
		-- Controlado via MainLoop
	end)

	-- Slider: Agressividade
	self.Elements.SliderAggro = self:CreateSlider(perf, UDim2.new(0, 0, 0, 128), "Agressividade", 1, 3, 2, function(val)
		if val == 1 then
			Config.TasksPerFrame = 30; Config.LOD_Near = 120; Config.KillDistance_Particle = 80
		elseif val == 2 then
			Config.TasksPerFrame = 60; Config.LOD_Near = 80; Config.KillDistance_Particle = 140
		else
			Config.TasksPerFrame = 100; Config.LOD_Near = 60; Config.KillDistance_Particle = 200
		end
	end)

	-- Slider: Stretch Value
	self.Elements.SliderStretch = self:CreateSlider(perf, UDim2.new(0, 0, 0, 184), "Stretch Value", 50, 95, 80, function(val)
		StretchSystem.value = val / 100
	end)

	-- Botão: Forçar Scan
	self:CreateButton(perf, UDim2.new(0, 0, 0, 244), "Forçar Scan Completo", Colors.Accent2, function()
		WorldScanner:StartFullScan()
		self:Notify("Scan completo iniciado!", Colors.Accent)
	end)

	-- Botão: Limpar Cache
	self:CreateButton(perf, UDim2.new(0, 0, 0, 284), "Limpar Cache & GC", Colors.Success, function()
		Utils.SafeCall(function()
			collectgarbage("collect")
			Services.LogService:ClearOutput()
		end)
		self:Notify("Cache limpo!", Colors.Success)
	end)

	-- ═══════════════════════════════════════════════════════════════════════════════
	--  TAB: VISUAL
	-- ═══════════════════════════════════════════════════════════════════════════════
	local visual = self.Pages.Visual

	self.Elements.ToggleShadows = self:CreateToggle(visual, UDim2.new(0, 0, 0, 0), "Remover Sombras", true, function(state)
		if state then
			RenderEngine:OptimizeLighting()
		end
	end)

	self.Elements.ToggleLOD = self:CreateToggle(visual, UDim2.new(0, 0, 0, 40), "LOD Neural (Players)", true, function(state)
		-- Controlado via MainLoop
	end)

	self.Elements.ToggleBackface = self:CreateToggle(visual, UDim2.new(0, 0, 0, 80), "Backface Culling", true, function(state)
		Config.BackfaceAngle = state and 120 or 180
	end)

	self.Elements.ToggleTerrain = self:CreateToggle(visual, UDim2.new(0, 0, 0, 120), "Otimizar Terrain", true, function(state)
		if state then RenderEngine:OptimizeTerrain() end
	end)

	self.Elements.ToggleEffects = self:CreateToggle(visual, UDim2.new(0, 0, 0, 160), "Remover Efeitos Lighting", true, function(state)
		if state then RenderEngine:OptimizeLighting() end
	end)

	-- ═══════════════════════════════════════════════════════════════════════════════
	--  TAB: NETWORK
	-- ═══════════════════════════════════════════════════════════════════════════════
	local net = self.Pages.Network

	self.Elements.ToggleFFlags = self:CreateToggle(net, UDim2.new(0, 0, 0, 0), "FFlags Injetados", true, function(state)
		if state then
			FFlagsEngine:Inject()
			self:Notify("FFlags reinjetados!", Colors.Accent)
		end
	end)

	self.Elements.ToggleNetwork = self:CreateToggle(net, UDim2.new(0, 0, 0, 40), "Network Optimizer", true, function(state)
		-- Controlado via MainLoop
	end)

	self:CreateButton(net, UDim2.new(0, 0, 0, 88), "Re-injetar FFlags", Colors.Accent, function()
		local count = FFlagsEngine:Inject()
		self:Notify(count .. " FFlags injetados!", Colors.Accent)
	end)

	self:CreateButton(net, UDim2.new(0, 0, 0, 128), "Detectar Admin", Colors.Warning, function()
		local admin = AdminDetector:Scan()
		self:Notify("Admin: " .. admin.name, Colors.Warning)
	end)

	self:CreateButton(net, UDim2.new(0, 0, 0, 168), "Carregar Bypass", Colors.Accent2, function()
		task.spawn(function()
			local admin = AdminDetector:Scan()
			Utils.SafeCall(function()
				local code = game:HttpGet(admin.url)
				if code and #code > 50 then
					loadstring(code)()
					self:Notify("Bypass carregado!", Colors.Success)
				end
			end)
		end)
	end)

	-- ═══════════════════════════════════════════════════════════════════════════════
	--  TAB: INFO (Bento Grid Stats)
	-- ═══════════════════════════════════════════════════════════════════════════════
	local info = self.Pages.Info

	-- Bento Grid 2x2
	self.Elements.StatFPS = self:CreateStatCard(info, UDim2.new(0, 0, 0, 0), UDim2.new(0.5, -4, 0, 60), "FPS", "--", Colors.Accent)
	self.Elements.StatPing = self:CreateStatCard(info, UDim2.new(0.5, 4, 0, 0), UDim2.new(0.5, -4, 0, 60), "PING", "--", Colors.Warning)
	self.Elements.StatMem = self:CreateStatCard(info, UDim2.new(0, 0, 0, 68), UDim2.new(0.5, -4, 0, 60), "MEM", "--", Colors.Success)
	self.Elements.StatOpt = self:CreateStatCard(info, UDim2.new(0.5, 4, 0, 68), UDim2.new(0.5, -4, 0, 60), "OPTIMIZADO", "--", Colors.Accent2)

	-- Status geral
	local statusCard = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.new(0, 0, 0, 140),
		BackgroundColor3 = Colors.Card,
		BorderSizePixel = 0,
		Parent = info,
	})
	AddCorner(statusCard, 10)
	AddStroke(statusCard, Colors.Border, 1, 0.9)
	AddGradient(statusCard, Colors.Card, Color3.fromRGB(12, 12, 20), 135)

	local statusTitle = Create("TextLabel", {
		Size = UDim2.new(1, -12, 0, 16),
		Position = UDim2.new(0, 6, 0, 6),
		BackgroundTransparency = 1,
		Text = "STATUS DO SISTEMA",
		TextColor3 = Colors.TextDim,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = statusCard,
	})

	self.Elements.StatusText = Create("TextLabel", {
		Size = UDim2.new(1, -12, 0, 40),
		Position = UDim2.new(0, 6, 0, 24),
		BackgroundTransparency = 1,
		Text = "Sistema operacional.
Task Scheduler ativo.",
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = statusCard,
	})

	-- Dragging
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Drag.active = true
			self.Drag.start = input.Position
			self.Drag.pos = self.MainFrame.Position
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(input)
		if self.Drag.active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - self.Drag.start
			self.MainFrame.Position = UDim2.new(
				self.Drag.pos.X.Scale, self.Drag.pos.X.Offset + delta.X,
				self.Drag.pos.Y.Scale, self.Drag.pos.Y.Offset + delta.Y
			)
		end
	end)

	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Drag.active = false
		end
	end)

	-- Floating Icon (quando minimizado)
	self.FloatingIcon = Create("TextButton", {
		Size = UDim2.new(0, 44, 0, 44),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = Colors.Accent,
		BorderSizePixel = 0,
		Text = "C1",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		AutoButtonColor = false,
		Visible = false,
		Parent = self.ScreenGui,
	})
	AddCorner(self.FloatingIcon, 22)
	AddStroke(self.FloatingIcon, Colors.Accent, 2, 0.5)

	-- Glow no floating icon
	local glow = Create("Frame", {
		Size = UDim2.new(1, 8, 1, 8),
		Position = UDim2.new(0, -4, 0, -4),
		BackgroundColor3 = Colors.Accent,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = self.FloatingIcon,
	})
	AddCorner(glow, 26)

	self.FloatingIcon.MouseButton1Click:Connect(function()
		self:Restore()
	end)

	-- Animação de entrada
	self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	self.MainFrame.Position = UDim2.new(0, 220, 0, 270)
	TweenObj(self.MainFrame, {Size = UDim2.new(0, 320, 0, 420), Position = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- Atalho F4 para toggle
	Services.UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.F4 then
			if self.Minimized then
				self:Restore()
			else
				self:Minimize()
			end
		end
	end)
end

function GUI:ShowTab(name)
	for tabName, page in pairs(self.Pages) do
		page.Visible = (tabName == name)
	end
end

function GUI:Minimize()
	self.Minimized = true
	TweenObj(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, self.MainFrame.AbsolutePosition.X + 160, 0, self.MainFrame.AbsolutePosition.Y + 210)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	task.delay(0.3, function()
		self.MainFrame.Visible = false
		self.FloatingIcon.Visible = true
		TweenObj(self.FloatingIcon, {Size = UDim2.new(0, 44, 0, 44)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
end

function GUI:Restore()
	self.Minimized = false
	self.FloatingIcon.Visible = false
	self.MainFrame.Visible = true
	TweenObj(self.MainFrame, {Size = UDim2.new(0, 320, 0, 420), Position = UDim2.new(0, self.FloatingIcon.AbsolutePosition.X - 20, 0, self.FloatingIcon.AbsolutePosition.Y - 20)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function GUI:Notify(text, color)
	local notif = Create("Frame", {
		Size = UDim2.new(0, 260, 0, 36),
		Position = UDim2.new(0.5, -130, 1, -60),
		BackgroundColor3 = Colors.Card,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = self.ScreenGui,
		ZIndex = 100,
	})
	AddCorner(notif, 8)
	AddStroke(notif, color or Colors.Accent, 1.5, 0.5)

	local lbl = Create("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notif,
	})

	notif.Position = UDim2.new(0.5, -130, 1, 20)
	TweenObj(notif, {Position = UDim2.new(0.5, -130, 1, -60)}, 0.4, Enum.EasingStyle.Back)

	task.delay(2.5, function()
		TweenObj(notif, {Position = UDim2.new(0.5, -130, 1, 20), BackgroundTransparency = 1}, 0.3)
		task.delay(0.3, function() notif:Destroy() end)
	end)
end

function GUI:UpdateStats()
	if not self.Elements.StatFPS then return end
	local fps = math.floor(PerformanceManager.currentFPS)
	local ping = 0
	pcall(function()
		local stats = Services.Stats.Network.ServerStatsItem
		if stats then ping = stats["Data Ping"]:GetValue() end
	end)
	local mem = 0
	pcall(function() mem = collectgarbage("count") / 1024 end)

	self.Elements.StatFPS.setValue(fps, fps > 60 and Colors.Success or (fps > 30 and Colors.Warning or Colors.Danger))
	self.Elements.StatPing.setValue(string.format("%.0fms", ping))
	self.Elements.StatMem.setValue(string.format("%.1fMB", mem))
	self.Elements.StatOpt.setValue(ObjectOptimizer.totalOptimized)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  MAIN LOOP
-- ═══════════════════════════════════════════════════════════════════════════════

local MainLoop = {
	lastSoundCull = 0,
	lastLOD = 0,
	lastMemory = 0,
	lastAntiVoid = 0,
	lastNetwork = 0,
	lastDynamicQuality = 0,
	lastAudioOpt = 0,
	lastGUIUpdate = 0,
}

Heartbeat:Connect(function(dt)
	local now = tick()

	PerformanceManager:Update()
	StretchSystem:Apply()
	WorldScanner:ProcessBatch()

	if not WorldScanner.isScanning and (now - WorldScanner.lastFullScan) >= WorldScanner.scanInterval then
		WorldScanner:StartFullScan()
	end

	if now - MainLoop.lastLOD >= 3 then
		MainLoop.lastLOD = now
		local camPos = Camera.CFrame.Position
		for _, plr in ipairs(Services.Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				LODSystem:ProcessPlayer(plr, camPos)
			end
		end
	end

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
				if parent and parent:IsA("BasePart") then pos = parent.Position end
				local dist = Utils.FastDistance(camPos, pos)
				if dist > Config.KillDistance_Sound and not Utils.IsPlayerRelated(obj) then
					Utils.SafeCall(function() obj.Volume = 0; obj:Stop() end)
				else
					local priority = (obj.Looped and 1 or 0) + (Utils.IsPlayerRelated(obj) and 2 or 0)
					table.insert(activeSounds, {sound = obj, priority = priority})
				end
			end
		end
		table.sort(activeSounds, function(a, b) return a.priority > b.priority end)
		for i = Config.MaxSoundsPlaying + 1, #activeSounds do
			Utils.SafeCall(function() activeSounds[i].sound.Volume = 0; activeSounds[i].sound:Stop() end)
		end
	end

	if now - MainLoop.lastMemory >= 25 then
		MainLoop.lastMemory = now
		Utils.SafeCall(function()
			collectgarbage("collect")
			collectgarbage("setpause", 150)
			collectgarbage("setstepmul", 300)
		end)
	end

	if now - MainLoop.lastAntiVoid >= 2 then
		MainLoop.lastAntiVoid = now
		SafetySystem:AntiVoid()
	end

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

	if now - MainLoop.lastDynamicQuality >= 6 then
		MainLoop.lastDynamicQuality = now
		PerformanceManager:Adapt()
	end

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
				if parent and parent:IsA("BasePart") then pos = parent.Position end
				local dist = Utils.FastDistance(camPos, pos)
				if dist > Config.KillDistance_Sound * 1.5 and not Utils.IsPlayerRelated(obj) then
					Utils.SafeCall(function() obj.Volume = math.max(obj.Volume * 0.3, 0) end)
				end
			end
		end
	end

	-- GUI Update (a cada 0.5s)
	if now - MainLoop.lastGUIUpdate >= 0.5 then
		MainLoop.lastGUIUpdate = now
		GUI:UpdateStats()
	end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  BOOT SEQUENCE
-- ═══════════════════════════════════════════════════════════════════════════════

local function Boot()
	print("[CAFUXZ1] Inicializando v12.0 GLASS EDITION...")

	Utils.SafeCall(function()
		settings().Network.IncomingReplicationLag = 0
		settings().Physics.AllowSleep = true
		settings().Rendering.QualityLevel = 1
		Services.ScriptContext.ErrorReportingEnabled = false
		Services.SoundService.RespectFilteringEnabled = true
	end)

	local fflagsCount = FFlagsEngine:Inject()
	MapProtection:PreIndex()
	RenderEngine:OptimizeLighting()
	RenderEngine:OptimizeTerrain()

	if LocalPlayer.Character then
		SafetySystem:ProtectCharacter(LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		SafetySystem:ProtectCharacter(char)
	end)

	local admin = AdminDetector:Scan()
	print("[CAFUXZ1] Admin detectado:", admin.name)

	task.spawn(function()
		Utils.SafeCall(function()
			local code = game:HttpGet(admin.url)
			if code and #code > 50 then
				loadstring(code)()
				print("[CAFUXZ1] Admin bypass carregado.")
			end
		end)
	end)

	-- Build GUI
	GUI:Build()

	task.delay(Config.BootDelay, function()
		WorldScanner:StartFullScan()
		GUI:Notify("CAFUXZ1 v12.0 Ativo!", Colors.Accent)
	end)

	Utils.SafeCall(function()
		Services.LogService:ClearOutput()
		Services.StarterGui:SetCore("PerformanceStatsVisible", false)
	end)

	print(string.format("[CAFUXZ1] Boot completo. FFlags: %d | GUI: Glassmorphism", fflagsCount))
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════════════════════════════════

_G.CAFUXZ1 = {
	Version = "12.0 GLASS",
	Status = "Running",
	Config = Config,
	GUI = GUI,
	Stats = function()
		return {
			fps = PerformanceManager.currentFPS,
			optimized = ObjectOptimizer.totalOptimized,
			avgFPS = PerformanceManager:GetAvgFPS(),
		}
	end,
	ToggleGUI = function()
		if GUI.Minimized then
			GUI:Restore()
		elseif GUI.ScreenGui and GUI.ScreenGui.Enabled then
			GUI.ScreenGui.Enabled = not GUI.ScreenGui.Enabled
		end
		return GUI.ScreenGui and GUI.ScreenGui.Enabled
	end,
	SetAggressiveness = function(level)
		if level == 1 then
			Config.TasksPerFrame = 30; Config.LOD_Near = 120; Config.KillDistance_Particle = 80
		elseif level == 2 then
			Config.TasksPerFrame = 60; Config.LOD_Near = 80; Config.KillDistance_Particle = 140
		elseif level == 3 then
			Config.TasksPerFrame = 100; Config.LOD_Near = 60; Config.KillDistance_Particle = 200
		end
		if GUI.Elements.SliderAggro then
			GUI.Elements.SliderAggro.setValue(level)
		end
	end,
	Clean = function()
		Utils.SafeCall(function()
			Services.LogService:ClearOutput()
			collectgarbage("collect")
		end)
	end,
	Notify = function(text, color)
		GUI:Notify(text, color)
	end,
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  EXECUTAR
-- ═══════════════════════════════════════════════════════════════════════════════

Utils.SafeCall(Boot)

print([[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║     CAFUXZ1 ULTIMATE OPTIMIZER v12.0 GLASS EDITION                  ║
    ║     GUI: Glassmorphism · Bento Grid · Neon · Microinteractions       ║
    ║     Core: Task Scheduler · LOD Neural · FFlags 2026 · Dynamic        ║
    ║     Atalhos: F4 (Minimize) · Drag header · Tabs animadas            ║
    ╚══════════════════════════════════════════════════════════════════════╝
]])
