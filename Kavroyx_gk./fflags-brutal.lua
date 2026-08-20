--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║  CAFUXZ1 FFlag Overhaul Loader v4.0 — Ultimate Edition                       ║
    ║  1,072 FFlags Merged & Optimized                                             ║
    ║  Graphics | Network | Scheduler | Input | Physics | Audio | UI | Telemetry   ║
    ║  Auto-Conflict Resolution | Live Stats | Category Filtering | Export System  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    Changelog v4.0:
    • Merged 2 external FFlag databases (193 + 906 = 1,072 unique flags)
    • Auto-conflict resolution engine (27 overlaps resolved)
    • Live injection statistics dashboard
    • Category-based filtering & progress tracking
    • Export applied flags to clipboard
    • Smart retry system with exponential backoff
    • Dark/Light theme toggle
    • Minimize to floating button
    • Performance impact estimation
]]

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local CoreGui      = game:GetService("CoreGui")
local TextService  = game:GetService("TextService")

local player = Players.LocalPlayer

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                     GUI PARENT & PROTECTION                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local guiParent
pcall(function()
    if gethui then
        guiParent = gethui()
    elseif cloneref then
        guiParent = cloneref(CoreGui)
    else
        guiParent = player:WaitForChild("PlayerGui")
    end
end)

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "CAFUXZ1_FFlagOverhaul_v4_" .. HttpService:GenerateGUID(false):sub(1, 6)
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.IgnoreGuiInset = true
pcall(function() mainGui.Parent = guiParent end)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                      THEME SYSTEM                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local Themes = {
    Dark = {
        PRIMARY     = Color3.fromRGB(0, 255, 170),
        ACCENT      = Color3.fromRGB(255, 50, 100),
        BG_CARD     = Color3.fromRGB(25, 25, 32),
        BG_DARKER   = Color3.fromRGB(18, 18, 24),
        BG_PANEL    = Color3.fromRGB(30, 30, 40),
        TEXT_MAIN   = Color3.fromRGB(255, 255, 255),
        TEXT_DIM    = Color3.fromRGB(160, 170, 180),
        SUCCESS     = Color3.fromRGB(0, 255, 150),
        WARNING     = Color3.fromRGB(255, 200, 50),
        ERROR       = Color3.fromRGB(255, 70, 70),
        INFO        = Color3.fromRGB(80, 170, 255),
        BORDER      = Color3.fromRGB(40, 45, 55),
        BORDER_HOVER= Color3.fromRGB(60, 70, 85),
        PROGRESS_BG = Color3.fromRGB(40, 40, 50),
    },
    Light = {
        PRIMARY     = Color3.fromRGB(0, 180, 120),
        ACCENT      = Color3.fromRGB(220, 40, 80),
        BG_CARD     = Color3.fromRGB(245, 245, 250),
        BG_DARKER   = Color3.fromRGB(230, 230, 240),
        BG_PANEL    = Color3.fromRGB(250, 250, 255),
        TEXT_MAIN   = Color3.fromRGB(30, 30, 40),
        TEXT_DIM    = Color3.fromRGB(100, 105, 115),
        SUCCESS     = Color3.fromRGB(0, 200, 100),
        WARNING     = Color3.fromRGB(220, 170, 30),
        ERROR       = Color3.fromRGB(220, 50, 50),
        INFO        = Color3.fromRGB(50, 130, 220),
        BORDER      = Color3.fromRGB(200, 205, 215),
        BORDER_HOVER= Color3.fromRGB(160, 170, 185),
        PROGRESS_BG = Color3.fromRGB(210, 210, 220),
    }
}

local currentTheme = "Dark"
local THEME = Themes[currentTheme]

local function ApplyTheme(themeName)
    currentTheme = themeName
    THEME = Themes[themeName]
    -- Theme application is handled dynamically in UI creation
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              NOTIFICATION SYSTEM v2.0                                        ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local activeNotifications = {}
local CONSTANTS = {
    NOTIF_WIDTH  = 320,
    NOTIF_HEIGHT = 100,
    PADDING      = 16,
    ANIM_SPEED   = 0.4,
    MAX_NOTIFS   = 6,
}

local function UpdateNotificationPositions()
    for index, data in ipairs(activeNotifications) do
        if index > CONSTANTS.MAX_NOTIFS then
            data.CloseFunc()
            continue
        end
        local targetY = -CONSTANTS.PADDING - ((index - 1) * (CONSTANTS.NOTIF_HEIGHT + CONSTANTS.PADDING))
        TweenService:Create(data.Container, TweenInfo.new(CONSTANTS.ANIM_SPEED, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -CONSTANTS.PADDING, 1, targetY)
        }):Play()
    end
end

local function ShowNotification(titleText, messageText, notifType, duration)
    duration = duration or 5
    notifType = notifType or "info"

    local typeColors = {
        info    = THEME.INFO,
        success = THEME.SUCCESS,
        warning = THEME.WARNING,
        error   = THEME.ERROR,
    }
    local accentColor = typeColors[notifType] or THEME.PRIMARY
    local iconMap = {
        info    = "◆",
        success = "✓",
        warning = "!",
        error   = "✕",
    }

    local container = Instance.new("Frame")
    container.Name = "NotifContainer"
    container.Size = UDim2.new(0, CONSTANTS.NOTIF_WIDTH, 0, CONSTANTS.NOTIF_HEIGHT)
    container.Position = UDim2.new(1, 400, 1, -CONSTANTS.PADDING)
    container.AnchorPoint = Vector2.new(1, 1)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = mainGui

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = THEME.BG_CARD
    card.BorderSizePixel = 0
    card.Parent = container

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.BORDER
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = card

    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 5)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = card

    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(1, 0, 0, 3)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    grad.Rotation = 90
    grad.Parent = accentBar

    -- Glow
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 0, 0, 24)
    glow.BackgroundColor3 = accentColor
    glow.BackgroundTransparency = 0.92
    glow.BorderSizePixel = 0
    glow.Parent = card

    local glowGrad = Instance.new("UIGradient")
    glowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 1)
    })
    glowGrad.Parent = glow

    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 14, 0, 14)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = iconMap[notifType]
    iconLabel.TextColor3 = accentColor
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 18
    iconLabel.Parent = card

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 0, 24)
    titleLabel.Position = UDim2.new(0, 44, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText
    titleLabel.TextColor3 = THEME.TEXT_MAIN
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = card

    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -30, 0, 40)
    messageLabel.Position = UDim2.new(0, 14, 0, 42)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = messageText
    messageLabel.TextColor3 = THEME.TEXT_DIM
    messageLabel.Font = Enum.Font.GothamMedium
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = card

    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -28, 0, 3)
    progressBg.Position = UDim2.new(0, 14, 1, -10)
    progressBg.AnchorPoint = Vector2.new(0, 1)
    progressBg.BackgroundColor3 = THEME.PROGRESS_BG
    progressBg.BorderSizePixel = 0
    progressBg.Parent = card
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 2)

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = accentColor
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 2)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -12, 0, 12)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.BackgroundColor3 = THEME.BG_DARKER
    closeBtn.Text = "×"
    closeBtn.TextColor3 = THEME.TEXT_DIM
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = card
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.ERROR,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.BG_DARKER,
            TextColor3 = THEME.TEXT_DIM
        }):Play()
    end)

    -- Animate in
    TweenService:Create(container, TweenInfo.new(CONSTANTS.ANIM_SPEED, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -CONSTANTS.PADDING, 1, -CONSTANTS.PADDING)
    }):Play()

    TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    local closed = false
    local notifData = {Container = container}

    local function CloseNotification()
        if closed then return end
        closed = true
        local targetIndex = table.find(activeNotifications, notifData)
        if targetIndex then
            table.remove(activeNotifications, targetIndex)
            UpdateNotificationPositions()
        end
        TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(container, TweenInfo.new(CONSTANTS.ANIM_SPEED, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 400, container.Position.Y.Scale, container.Position.Y.Offset)
        }):Play()
        task.delay(CONSTANTS.ANIM_SPEED + 0.1, function()
            pcall(function() container:Destroy() end)
        end)
    end

    notifData.CloseFunc = CloseNotification
    table.insert(activeNotifications, 1, notifData)
    UpdateNotificationPositions()

    closeBtn.MouseButton1Click:Connect(CloseNotification)
    task.delay(duration, CloseNotification)
end

local FlagDatabase = {
    ["DFFlagAdsPreloadInteractivityAssets"] = "True",
    ["DFFlagAggCpuMemRCC"] = "True",
    ["DFFlagAnimationThrottlingInertialization"] = "True",
    ["DFFlagAnimatorFixReplicationASANError"] = "True",
    ["DFFlagAnimatorPostProcessIK"] = "True",
    ["DFFlagAudioDeviceTelemetry"] = "False",
    ["DFFlagAudioEnableVolumetricPanningForMeshes"] = "True",
    ["DFFlagAudioEnableVolumetricPanningForPolys"] = "True",
    ["DFFlagAudioUseVolumetricPanning"] = "True",
    ["DFFlagAvatarChatServiceTelemetryIncludeServerFeatures"] = "False",
    ["DFFlagAvatarChatTelemetryAddTrackingTimeToSessionTracking"] = "False",
    ["DFFlagAvatarChatTelemetryAddTrackingTimeToSessionTracking2"] = "False",
    ["DFFlagBatchAssetApiNoFallbackOnFail"] = "False",
    ["DFFlagBrowserTrackerIdTelemetryEnabled"] = "False",
    ["DFFlagClampIncomingReplicationLag"] = "True",
    ["DFFlagCleanupMoodDampingIxpExperimentation"] = "True",
    ["DFFlagClientBaseNetworkMetrics"] = "False",
    ["DFFlagClientLightingTechnologyChangedTelemetryTrackTimeSpent"] = "False",
    ["DFFlagClientRolloutPhaseTelemetry"] = "False",
    ["DFFlagCorrectCachePolicySkipRedirectCache"] = "True",
    ["DFFlagCorrectServerReplicatorStatsIP"] = "True",
    ["DFFlagCreateMeshPartAtRuntime"] = "False",
    ["DFFlagDebugAssertTelemetry"] = "False",
    ["DFFlagDebugDisableTimeoutDisconnect"] = "True",
    ["DFFlagDebugEnableRomarkMicroprofilerTelemetry"] = "False",
    ["DFFlagDebugEnableRomarkService"] = "False",
    ["DFFlagDebugLargeReplicatorDisableCompression"] = "True",
    ["DFFlagDebugOverrideDPIScale"] = "False",
    ["DFFlagDebugPerfMode"] = "True",
    ["DFFlagDebugRenderForceTechnologyVoxel"] = "True",
    ["DFFlagDebugRenderForceTechnologyVoxel_PlaceFilter"] = "True;893973440",
    ["DFFlagDebugVisualizationImprovements"] = "True",
    ["DFFlagDebugVisualizeAllPropertyChanges"] = "True",
    ["DFFlagDebugVisualizerTrackRotationPredictions"] = "True",
    ["DFFlagDisableDPIScale"] = "False",
    ["DFFlagEnableArbiterTimeTelemetry"] = "False",
    ["DFFlagEnableDynamicHeadByDefault"] = "False",
    ["DFFlagEnableExperienceNotificationOptInPrompt"] = "False",
    ["DFFlagEnableExtraUnreachableTelemetry"] = "False",
    ["DFFlagEnableFmodErrorsTelemetry"] = "False",
    ["DFFlagEnableGlobalFeatureTrackingInTelemetryEvent"] = "False",
    ["DFFlagEnableHardwareTelemetry"] = "False",
    ["DFFlagEnableLightstepReporting2"] = "False",
    ["DFFlagEnableMeshPreloading2"] = "True",
    ["DFFlagEnableParallelFrustumQueries3"] = "True",
    ["DFFlagEnablePercentileTelemetry"] = "False",
    ["DFFlagEnablePerfDataGatherTelemetry2"] = "False",
    ["DFFlagEnablePerfDataMainThread"] = "True",
    ["DFFlagEnablePerfRenderStatsCollection2"] = "false",
    ["DFFlagEnableRemoteSaveValidatorTelemetry"] = "False",
    ["DFFlagEnableRequestAsyncCompression"] = "False",
    ["DFFlagEnableRobloxTelemetryV2POC"] = "False",
    ["DFFlagEnableSoundPreloading"] = "True",
    ["DFFlagEnableTelemetryV2FRMStats"] = "False",
    ["DFFlagEnableTexturePreloading"] = "True",
    ["DFFlagFFlagRolloutDuplicateRobloxTelemetryCountersEnabled"] = "False",
    ["DFFlagFaceAnimatorServiceTelemetryIncludeTrackerMode"] = "False",
    ["DFFlagFileMeshDataTelemetry"] = "False",
    ["DFFlagFixHumanoidStateTypeNameNullTelemetryCrash"] = "False",
    ["DFFlagFixSkyBoxTextureBlurrines"] = "False",
    ["DFFlagFrameTimeStdDev"] = "False",
    ["DFFlagGameNetFixReplicationSkipBug"] = "True",
    ["DFFlagGpuVsCpuBoundTelemetry"] = "False",
    ["DFFlagGraphicsOptimizationModeMVPExposureEnrollment3"] = "False",
    ["DFFlagGraphicsOptimizationModeMVPExposureEnrollment4"] = "False",
    ["DFFlagGraphicsQualityUsageTelemetry"] = "False",
    ["DFFlagHasRuppHeaderFromServerTelemetry"] = "False",
    ["DFFlagHttpApplyDecompressionMultiplier"] = "False",
    ["DFFlagHttpPointsReporterUseCompression"] = "False",
    ["DFFlagImprovedGuiFilter"] = "True",
    ["DFFlagLoadCharacterLayeredClothingProperty2"] = "False",
    ["DFFlagLuauCodeGenIssueTelemetry"] = "False",
    ["DFFlagNetworkFlushThrottle"] = "False",
    ["DFFlagNetworkSchemaImprovements"] = "True",
    ["DFFlagNetworkUseZstdWrapper"] = "False",
    ["DFFlagNextGenRepRollbackOverbudgetPackets"] = "True",
    ["DFFlagNoRuppHeaderFromServerTelemetry"] = "False",
    ["DFFlagOpenCloudV1CreateUserNotificationAsync"] = "False",
    ["DFFlagOptimizeInstanceQueries"] = "True",
    ["DFFlagOptimizeIsA"] = "True",
    ["DFFlagOptimizeNoCollisionPrimitiveInMidphaseCrash"] = "True",
    ["DFFlagPerformanceControlEnableMemoryProbing3"] = "True",
    ["DFFlagPerformanceControlIXPAllowCustomTelemetryThrottles"] = "False",
    ["DFFlagPhysicsMechanismCacheOptimizeAlloc"] = "True",
    ["DFFlagPhysicsSkipNonRealTimeHumanoidForceCalc2"] = "False",
    ["DFFlagRakNetCalculateApplicationFeedback2"] = "False",
    ["DFFlagRakNetDecoupleRecvAndUpdateLoopShutdown"] = "True",
    ["DFFlagRakNetDetectNetUnreachable"] = "True",
    ["DFFlagRakNetDetectRecvThreadOverload"] = "True",
    ["DFFlagRakNetEnablePoll"] = "True",
    ["DFFlagRakNetFixBwCollapse"] = "False",
    ["DFFlagRakNetUnblockSelectOnShutdownByWritingToSocket"] = "True",
    ["DFFlagRakNetUseSlidingWindow4"] = "True",
    ["DFFlagReplicateCreateToPlayer"] = "True",
    ["DFFlagReportOutputDeviceWithRobloxTelemetry"] = "False",
    ["DFFlagReportTokenWithTelemetry"] = "False",
    ["DFFlagRobloxTelemetryLogStringListField"] = "False",
    ["DFFlagSampleAndRefreshRakPing"] = "True",
    ["DFFlagSessionTelemetryUnify"] = "False",
    ["DFFlagSessionTrackingRecordHasLocation"] = "False",
    ["DFFlagSimDcdRecompUseClosedVoxel4"] = "True",
    ["DFFlagSimReportCPUInfo"] = "False",
    ["DFFlagSimSimulationRadiusTelemetryV2Migration"] = "False",
    ["DFFlagSimSkipVoxelCDECMerge"] = "True",
    ["DFFlagSimSolverOptimizeGeometricStiffness4"] = "True",
    ["DFFlagSimSolverSendBasePartDensityMinBoundClampingEvent"] = "True",
    ["DFFlagSimSolverTelemetryV2Migration"] = "False",
    ["DFFlagSkipSomeProperties"] = "True",
    ["DFFlagSkipSomePropertiesSkip"] = "True",
    ["DFFlagTeleportClientAssetPreloadingDoingExperiment"] = "True",
    ["DFFlagTeleportClientAssetPreloadingEnabled9"] = "True",
    ["DFFlagTeleportClientAssetPreloadingEnabledIXP"] = "True",
    ["DFFlagTeleportMenuOpenTelemetry2"] = "False",
    ["DFFlagTextureQualityOverrideEnabled"] = "True",
    ["DFFlagTrackerPerfTelemetryIncludePerfData"] = "False",
    ["DFFlagUnifyLegacyJointGeometry"] = "True",
    ["DFFlagUseVisBugChecks"] = "True",
    ["DFFlagVisBugFixPartUpdatedLock"] = "True",
    ["DFFlagVisBugFixUnloadReadyMesh"] = "True",
    ["DFFlagVoiceChatTurnOnMuteUnmuteNotificationHack"] = "False",
    ["DFFlagVoxelizerDisableTerrainSIMD"] = "False",
    ["DFIntAMPVerifiedTelemetryHundredthsPercentage"] = "0",
    ["DFIntAdPortalRotationIntervalMS"] = "300000",
    ["DFIntAirControllerTurningResponsiveness"] = "2147483647",
    ["DFIntAnimationLodFacsDistanceMax"] = "0",
    ["DFIntAnimationLodFacsDistanceMin"] = "0",
    ["DFIntAnimatorTelemetryCollectionRate"] = "0",
    ["DFIntAnimatorThrottleMaxFramesToSkip"] = "1",
    ["DFIntAssetPermissionsApiGetAssetsPermissionsTelemetryHundredthsPercent"] = "0",
    ["DFIntAssetPermissionsApiPatchAssetsPermissions0TelemetryHundredthsPercent"] = "0",
    ["DFIntAssetPermissionsApiPostUniversesPermissionscopyIntoTelemetryHundredthsPercent"] = "0",
    ["DFIntAssetPreloading"] = "2147483647",
    ["DFIntAvatarFacechatLODCameraDisableTelemetryThrottleHundrethsPercent"] = "10000",
    ["DFIntAvatarFacechatPipelinePerformanceTelemetryThrottleHundrethsPercent"] = "0",
    ["DFIntAvatarFacechatReplOverRCCTelemetryEventRateSec"] = "0",
    ["DFIntBasePartDensityMinBoundClampingEventHundredthsPercentage"] = "0",
    ["DFIntBatchPostExpirationTimeSeconds"] = "10",
    ["DFIntBatchPostLimit"] = "128",
    ["DFIntBatchPostMaxRequests"] = "3",
    ["DFIntBatchPostMaxRetries"] = "3",
    ["DFIntBatchPostMaxWaitMs"] = "3",
    ["DFIntBatchPostMinWaitMs"] = "1",
    ["DFIntBatchThumbnailExperiationTimeSeconds"] = "10",
    ["DFIntBatchThumbnailExponentialInitialWaitMs"] = "20",
    ["DFIntBatchThumbnailMaxExponentialRetries"] = "2",
    ["DFIntBatchThumbnailMinWaitMs"] = "1",
    ["DFIntBgUpdateRedirectsHttpErrInfluxHundredthsPercentage"] = "70",
    ["DFIntBgUpdateRedirectsRejectInfluxHundredthsPercentage"] = "70",
    ["DFIntBrowserTrackerApiDeviceInitializeRolloutPercentage"] = "0",
    ["DFIntBrowserTrackerIdTelemetryThrottleHundredthsPercent"] = "0",
    ["DFIntBufferCompressionLevel"] = "0",
    ["DFIntCLI46794SendInputTelemetryHundredthsPercentage"] = "0",
    ["DFIntCLI61964inKB"] = "2147483647",
    ["DFIntCSGLevelOfDetailSwitchingDistanceL12"] = "0",
    ["DFIntCSGLevelOfDetailSwitchingDistanceL23"] = "0",
    ["DFIntCSGv2LodMinTriangleCount"] = "0",
    ["DFIntCSGv2LodsToGenerate"] = "0",
    ["DFIntCallsBetweenUnreliablePing"] = "0",
    ["DFIntCanHideGuiGroupId"] = "32380007",
    ["DFIntClientLightingEnvmapPlacementTelemetryHundredthsPercent"] = "100",
    ["DFIntClientLightingTechnologyChangedTelemetryHundredthsPercent"] = "0",
    ["DFIntClientNetworkInfluxHundredthsPercentage"] = "0",
    ["DFIntClientPacketHealthyAllocationPercent"] = "20",
    ["DFIntClusterCompressionLevel"] = "0",
    ["DFIntClusterEstimatedCompressionRatioHundredths"] = "0",
    ["DFIntClusterSenderMaxJoinBandwidthBps"] = "2100000000",
    ["DFIntClusterSenderMaxUpdateBandwidthBps"] = "2100000000",
    ["DFIntCodecMaxIncomingPackets"] = "100",
    ["DFIntCodecMaxOutgoingFrames"] = "10000",
    ["DFIntConnectionLostDisconnectReasonInfluxHundredthsPercentage"] = "0",
    ["DFIntContentProviderPreloadHangTelemetryHundredthsPercentage"] = "0",
    ["DFIntCoreScriptsAnalyticsHundredthsPercentage"] = "0",
    ["DFIntCullFactorPixelThresholdMainViewHighQuality"] = "10000",
    ["DFIntCullFactorPixelThresholdMainViewLowQuality"] = "10000",
    ["DFIntCullFactorPixelThresholdShadowMapLowQuality"] = "2147483647",
    ["DFIntCurveMarkerCheckerTelemetryEventsThrottleHundrethsPercent"] = "0",
    ["DFIntDataSenderRate"] = "4",
    ["DFIntDebugAdditionalNumberOfMipsToSkipForNonAlbedoTextures"] = "0",
    ["DFIntDebugFRMQualityLevelOverride"] = "1",
    ["DFIntDebugForceMeshLodLevel"] = "0",
    ["DFIntDebugLimitMinTextureResolutionWhenSkipMips"] = "0",
    ["DFIntDebugSimPrimalLineSearch"] = "21",
    ["DFIntDebugSimPrimalNewtonIts"] = "1",
    ["DFIntDebugSimPrimalPreconditionerMinExp"] = "69",
    ["DFIntDebugSimPrimalWarmstartForce"] = "-885",
    ["DFIntDebugSimPrimalWarmstartVelocity"] = "-350",
    ["DFIntDefaultTimeoutTimeMs"] = "10000",
    ["DFIntEnableVisBugChecksHundredthPercent"] = "1000",
    ["DFIntErrorEstimationArbiterC3"] = "41227",
    ["DFIntErrorEstimationArbiterC5"] = "-15343",
    ["DFIntErrorEstimationArbiterC6"] = "-16297",
    ["DFIntFFlagRolloutDuplicateRobloxTelemetryCountersThrottleHundredthsPercent"] = "0",
    ["DFIntFFlagRolloutDuplicateTelemetryCountersThrottleHundredthsPercent"] = "0",
    ["DFIntGameNetLocalSpaceMaxSendIndex"] = "100000",
    ["DFIntGoogleAnalyticsLoadPlayerHundredth"] = "0",
    ["DFIntGraphicsOptimizationModePerformanceScalePercent"] = "10000000",
    ["DFIntHttpBatchApi_maxWaitMs"] = "3",
    ["DFIntHttpBatchApi_minWaitMs"] = "1",
    ["DFIntHttpCurlConnectionCacheSize"] = "134217728",
    ["DFIntHttpParallelLimit_RequestExperienceNotificationService"] = "0",
    ["DFIntHttpRbxApiMaxRetryCount"] = "30",
    ["DFIntHttpRbxApiMaxThrottledQueueSize"] = "100",
    ["DFIntHttpRbxApiRequestsPerMinutePerPlayerInServerLimit"] = "150",
    ["DFIntHttpRbxApiSyncRetryWaitTimeMSec"] = "5",
    ["DFIntIkControlTelemetryEventsThrottleHundrethsPercent"] = "0",
    ["DFIntInitialAccelerationLatencyMultTenths"] = "1",
    ["DFIntInterpolationDtLimitForLod"] = "10",
    ["DFIntInterpolationMinAssemblyCount"] = "1",
    ["DFIntInterpolationNumMechanismsBatchSize"] = "1",
    ["DFIntInterpolationNumMechanismsPerTask"] = "1",
    ["DFIntInterpolationNumParallelTasks"] = "4",
    ["DFIntJoinDataCompressionLevel"] = "0",
    ["DFIntJoinDataItemEstimatedCompressionRatioHundreths"] = "0",
    ["DFIntKeyRingUsingDynamicConfigTelemetryInfluxHundredths"] = "0",
    ["DFIntLargePacketQueueSizeCutoffMB"] = "1000",
    ["DFIntLightstepHTTPTransportHundredthsPercent2"] = "0",
    ["DFIntLmsPingExpBackoffMaxElapsedTimeSeconds"] = "3600",
    ["DFIntLoadStreamAnimationFailureTelemetryHundredthsPercentage"] = "0",
    ["DFIntLogChunkSize"] = "1",
    ["DFIntLongAvatarAssetTelemetryThrottleHundredthsPercent"] = "0",
    ["DFIntLuauCodeGenIssueTelemetryHundrethsPercentage"] = "0",
    ["DFIntLuauRefinementTelemetryInfluxHundredthsPercentage"] = "0",
    ["DFIntLuauRefinementTelemetryInfluxPriorityHundredthsPercentage"] = "0",
    ["DFIntMaxInterpolationRecursionsBeforeCheck"] = "1",
    ["DFIntMaxProcessPacketsJobScaling"] = "10000",
    ["DFIntMaxProcessPacketsStepsAccumulated"] = "0",
    ["DFIntMegaReplicatorNetworkQualityProcessorUnit"] = "10",
    ["DFIntMeshPartDetailLevel"] = "0",
    ["DFIntMeshPartLODFactor"] = "0",
    ["DFIntMicroProfilerDpiScaleOverride"] = "100",
    ["DFIntMinimalNetworkPrediction"] = "1",
    ["DFIntNetworkCluster"] = "0",
    ["DFIntNetworkClusterPacketCacheNumParallelTasks"] = "4",
    ["DFIntNetworkLatencyTolerance"] = "1",
    ["DFIntNetworkPrediction"] = "120",
    ["DFIntNetworkQualityResponderMaxWaitTime"] = "5",
    ["DFIntNetworkQualityResponderUnit"] = "10",
    ["DFIntNewCameraControls_TelemetryPerFrameThrottle"] = "0",
    ["DFIntNewRunningBaseGravityReductionFactorHundredth"] = "1500",
    ["DFIntNumAssetsMaxToPreload"] = "2147483647",
    ["DFIntOAuth2RefreshTokenStorageTelemetryHundredthsPercent"] = "0",
    ["DFIntOAuth2TokenHttpRequestTelemetryHundredthsPercent"] = "0",
    ["DFIntPercentApiRequestsRecordGoogleAnalytics"] = "0",
    ["DFIntPercentileTelemetryHundredPercent"] = "0",
    ["DFIntPerformanceControlEventBasedTelemetryEffectPredictionEventRatePoints"] = "0",
    ["DFIntPerformanceControlEventBasedTelemetryTunableChangeEventNumReportsPerSecond"] = "0",
    ["DFIntPerformanceControlEventBasedTelemetryTunableChangeEventRateEventIngest"] = "0",
    ["DFIntPerformanceControlFrameTimeMax"] = "1",
    ["DFIntPerformanceControlMemoryCategoriesTelemetryEnabledHundrethPercentage"] = "0",
    ["DFIntPerformanceControlTextureQualityBestUtility"] = "-1",
    ["DFIntPerformanceControlTextureQualityExponentTenThousandths"] = "0",
    ["DFIntPhysicsAnalyticsHighFrequencyIntervalSec"] = "20",
    ["DFIntPhysicsDecompForceUpgradeVersion"] = "4",
    ["DFIntPhysicsMemoryTelemetryHundredthsPercentage"] = "0",
    ["DFIntPhysicsReceiveNumParallelTasks"] = "4",
    ["DFIntPhysicsSolverNumericalExplosionTelemetryHundrethsPercentage"] = "0",
    ["DFIntProductUpdateTelemetryEventRate"] = "0",
    ["DFIntQueryPerformanceTelemetryConfigMaxRequests"] = "0",
    ["DFIntRCCServiceGetMachineStatesTelemetryHundredthsPercent"] = "0",
    ["DFIntRCCServiceGetMachineStates_IncludeDataModelTelemetryHundredthsPercent"] = "0",
    ["DFIntRCCServiceGetMachineStates_IncludeGlobalStateTelemetryHundredthsPercent"] = "0",
    ["DFIntRCCServiceUpdateMachineStatesTelemetryHundredthsPercent"] = "0",
    ["DFIntRagdollSlowEnoughToNotTenth"] = "1",
    ["DFIntRakNetApplicationFeedbackMaxSpeedBPS"] = "0",
    ["DFIntRakNetApplicationFeedbackScaleUpFactorHundredthPercent"] = "0",
    ["DFIntRakNetApplicationFeedbackScaleUpThresholdPercent"] = "0",
    ["DFIntRakNetClockDriftAdjustmentPerPingMillisecond"] = "50",
    ["DFIntRakNetMtuValue1InBytes"] = "1440",
    ["DFIntRakNetMtuValue2InBytes"] = "1400",
    ["DFIntRakNetMtuValue3InBytes"] = "1100",
    ["DFIntRakNetNakResendDelayMsMax"] = "100",
    ["DFIntRakNetResendRttMultiple"] = "1",
    ["DFIntRakNetUseSlidingWindow2_minSpeed"] = "512",
    ["DFIntRakNetUseSlidingWindow2_rangeCount"] = "20",
    ["DFIntRaknetBandwidthInfluxHundredthsPercentageV2"] = "10000",
    ["DFIntRaknetBandwidthPingSendEveryXSeconds"] = "1",
    ["DFIntRccServerMetricsFilterTelemetryInfluxPercent"] = "0",
    ["DFIntRccWorkerConsoleOutputTelemetryHundredthsPercent"] = "0",
    ["DFIntRenderingThrottleDelayInMS"] = "1",
    ["DFIntReplicationDataCacheNumParallelTasks"] = "4",
    ["DFIntReplicatorDataPingReportHundredthPercentage"] = "5",
    ["DFIntReplicatorDataPingReportThrottleSeconds"] = "5",
    ["DFIntReplicatorJdiReportThrottlePercent"] = "0",
    ["DFIntReportOutputDeviceInfoRateHundredthsPercentage"] = "0",
    ["DFIntReportRecordingDeviceInfoRateHundredthsPercentage"] = "0",
    ["DFIntReportServerConnectionLostHundredthsPercent"] = "0",
    ["DFIntRobloxTelemetryBatchSizeThreshold"] = "0",
    ["DFIntRunningBaseOrientationP"] = "115",
    ["DFIntS2PhysicsSendRate"] = "38000",
    ["DFIntSendGameServerDataMaxLen"] = "2147483647",
    ["DFIntSendItemLimit"] = "5",
    ["DFIntSendRakNetStatsInterval"] = "2147483647",
    ["DFIntServerBandwidthPlayerSampleRate"] = "2147483647",
    ["DFIntServerBandwidthPlayerSampleRateFacsOverride"] = "2147483647",
    ["DFIntServerFramesBetweenJoins"] = "1",
    ["DFIntServerPhysicsUpdateRate"] = "60",
    ["DFIntServerRakNetBandwidthPlayerSampleRate"] = "2147483647",
    ["DFIntServerTickRate"] = "60",
    ["DFIntSignalRCore"] = "1",
    ["DFIntSignalRCoreHandshakeTimeoutMs"] = "1000",
    ["DFIntSignalRCoreHubBaseRetryMs"] = "50",
    ["DFIntSignalRCoreHubMaxBackoffMs"] = "500",
    ["DFIntSignalRCoreHubMaxElapsedMs"] = "5000",
    ["DFIntSignalRCoreNetworkHandler"] = "1",
    ["DFIntSignalRCoreRpcQueueSize"] = "4096",
    ["DFIntSignalRCoreServerTimeoutMs"] = "5000",
    ["DFIntSignalRHubConnectionBaseRetryTimeMs"] = "50",
    ["DFIntSignalRHubConnectionHeartbeatTimerRateMs"] = "1000",
    ["DFIntSimAnimationConstraintResponsiveness"] = "2147483647",
    ["DFIntSimCSG3DCDRecomputeThreashold"] = "150",
    ["DFIntSimConstraintDataCollectionRate3"] = "36420",
    ["DFIntTaskSchedulerTargetFps"] = "9999",
    ["DFIntTeleportClientAssetPreloadingHundredthsPercentage2"] = "100000",
    ["DFIntTextureCompositorActiveJobs"] = "0",
    ["DFIntTextureQualityOverride"] = "0",
    ["DFIntThrottlingPredictionAccelerationHoldThousandth"] = "2",
    ["DFIntTimeBetweenSendConnectionAttemptsMS"] = "200",
    ["DFIntTouchSenderMaxBandwidthBpsScaling"] = "2",
    ["DFIntUseFmodTelemetryPercent"] = "0",
    ["DFIntUserIdPlayerNameCacheSize"] = "33554432",
    ["DFIntUserIdPlayerNameLifetimeSeconds"] = "86400",
    ["DFIntVideoMaxNumberOfVideosPlaying"] = "0",
    ["DFIntVisibilityCheckRayCastLimitPerFrame"] = "10",
    ["DFIntVoiceChatRollOffMaxDistance"] = "80",
    ["DFIntVoiceChatRollOffMinDistance"] = "80",
    ["DFIntVoicePublishConnectionStateTelemetryFixReportRate"] = "0",
    ["DFIntWaitOnRecvFromLoopEndedMS"] = "100",
    ["DFIntWaitOnUpdateNetworkLoopEndedMS"] = "100",
    ["DFIntWindowsWebViewTelemetryThrottleHundredthsPercent"] = "0",
    ["DFIntplacesAddPlaceToUniverseTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesCreatePlaceApiKeyTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesCreatePlaceUserAuthTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesCreatePlaceVersionApiKeyTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesCreateUniverseTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesGetUniverseContainingPlaceTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesGetUniverseSecurityTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesGetUniverseSecurityV2TelemetryHundredthsPercent"] = "0",
    ["DFIntplacesPatchRootPlaceTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesPatchUniverseConfigurationTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesPatchUniverseSecurityTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesSetJoinRestrictionsTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesSetUniverseRootPlaceTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesSetUniverseSecurityTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesSetUniverseSecurityV2TelemetryHundredthsPercent"] = "0",
    ["DFIntplacesUpdatePlaceTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesUpdatePlaceVersionTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesUpdateUniverseConfigurationTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesUpdateUniverseRootPlaceTelemetryHundredthsPercent"] = "0",
    ["DFIntplacesUpdateUniverseSecurityTelemetryHundredthsPercent"] = "0",
    ["DFStringAltHttpPointsReporterUrl"] = "null",
    ["DFStringAltTelegrafHTTPTransportUrl"] = "null",
    ["DFStringCrashUploadToBacktraceMacPlayerToken"] = "null",
    ["DFStringHttpPointsReporterUrl"] = "null",
    ["DFStringLightstepHTTPTransportUrlHost"] = "null",
    ["DFStringLightstepToken"] = "null",
    ["DFStringNewFlagRolloutFlagsWhitelist"] = "DFFlagAdditionalPrePauseStats;DFFlagAnalyticsSetUsableHttpBandwith;DFFlagClientNoStreamJob;DFFlagDebugCrashOnShutdown1;DFFlagFixPositiveRuleNotFound;DFFlagFlagRolloutTestDynamicBool0;DFFlagFlagRolloutTestDynamicBool1;DFFlagFlagRolloutTestDynamicBool10;DFFlagFlagRolloutTestDynamicBool11;DFFlagFlagRolloutTestDynamicBool12;DFFlagFlagRolloutTestDynamicBool13;DFFlagFlagRolloutTestDynamicBool14;DFFlagFlagRolloutTestDynamicBool15;DFFlagFlagRolloutTestDynamicBool16;DFFlagFlagRolloutTestDynamicBool17;DFFlagFlagRolloutTestDynamicBool18;DFFlagFlagRolloutTestDynamicBool19;DFFlagFlagRolloutTestDynamicBool2;DFFlagFlagRolloutTestDynamicBool20;DFFlagFlagRolloutTestDynamicBool21;DFFlagFlagRolloutTestDynamicBool22;DFFlagFlagRolloutTestDynamicBool23;DFFlagFlagRolloutTestDynamicBool24;DFFlagFlagRolloutTestDynamicBool25;DFFlagFlagRolloutTestDynamicBool26;DFFlagFlagRolloutTestDynamicBool27;DFFlagFlagRolloutTestDynamicBool28;DFFlagFlagRolloutTestDynamicBool29;DFFlagFlagRolloutTestDynamicBool3;DFFlagFlagRolloutTestDynamicBool30;DFFlagFlagRolloutTestDynamicBool31;DFFlagFlagRolloutTestDynamicBool32;DFFlagFlagRolloutTestDynamicBool33;DFFlagFlagRolloutTestDynamicBool34;DFFlagFlagRolloutTestDynamicBool35;DFFlagFlagRolloutTestDynamicBool36;DFFlagFlagRolloutTestDynamicBool37;DFFlagFlagRolloutTestDynamicBool38;DFFlagFlagRolloutTestDynamicBool39;DFFlagFlagRolloutTestDynamicBool4;DFFlagFlagRolloutTestDynamicBool40;DFFlagFlagRolloutTestDynamicBool41;DFFlagFlagRolloutTestDynamicBool42;DFFlagFlagRolloutTestDynamicBool43;DFFlagFlagRolloutTestDynamicBool44;DFFlagFlagRolloutTestDynamicBool45;DFFlagFlagRolloutTestDynamicBool46;DFFlagFlagRolloutTestDynamicBool47;DFFlagFlagRolloutTestDynamicBool48;DFFlagFlagRolloutTestDynamicBool49;DFFlagFlagRolloutTestDynamicBool5;DFFlagFlagRolloutTestDynamicBool6;DFFlagFlagRolloutTestDynamicBool7;DFFlagFlagRolloutTestDynamicBool8;DFFlagFlagRolloutTestDynamicBool9;DFFlagRemoveCallbackModeFromPerformanceControl;DFFlagSimulateNewDynamicFlagRolloutCheck;DFIntAdditionalPrePauseStatsHundredthsPercentage;DFIntAdditionalPrePauseStatsSamplePeriod;DFIntFlagRolloutTestDynamicInt0;DFIntFlagRolloutTestDynamicInt1;DFIntFlagRolloutTestDynamicInt2;DFIntFlagRolloutTestDynamicInt3;DFIntFlagRolloutTestDynamicInt4;DFIntFlagRolloutTestDynamicInt5;DFIntFlagRolloutTestDynamicInt6;DFIntFlagRolloutTestDynamicInt7;DFIntFlagRolloutTestDynamicInt8;DFIntFlagRolloutTestDynamicInt9;DFStringFlagRolloutTestDynamicString0;DFStringFlagRolloutTestDynamicString1;DFStringFlagRolloutTestDynamicString2;DFStringFlagRolloutTestDynamicString3;DFStringFlagRolloutTestDynamicString4;DFStringFlagRolloutTestDynamicString5;DFStringFlagRolloutTestDynamicString6;DFStringFlagRolloutTestDynamicString7;DFStringFlagRolloutTestDynamicString8;DFStringFlagRolloutTestDynamicString9;DFStringFlagRolloutTestStaticString0;DFStringFlagRolloutTestStaticString1;DFStringFlagRolloutTestStaticString2;DFStringFlagRolloutTestStaticString3;DFStringFlagRolloutTestStaticString4;DFStringFlagRolloutTestStaticString5;DFStringFlagRolloutTestStaticString6;DFStringFlagRolloutTestStaticString7;DFStringFlagRolloutTestStaticString8;DFStringFlagRolloutTestStaticString9;FFlagEnableRobloxTypeAliases;FFlagEnableSimulationStep;FFlagFixOutdatedTimeScaleParticles;FFlagFixValidationCLI96189;FFlagFlagRolloutTestStaticBool0;FFlagFlagRolloutTestStaticBool1;FFlagFlagRolloutTestStaticBool10;FFlagFlagRolloutTestStaticBool11;FFlagFlagRolloutTestStaticBool12;FFlagFlagRolloutTestStaticBool13;FFlagFlagRolloutTestStaticBool14;FFlagFlagRolloutTestStaticBool15;FFlagFlagRolloutTestStaticBool16;FFlagFlagRolloutTestStaticBool17;FFlagFlagRolloutTestStaticBool18;FFlagFlagRolloutTestStaticBool19;FFlagFlagRolloutTestStaticBool2;FFlagFlagRolloutTestStaticBool20;FFlagFlagRolloutTestStaticBool21;FFlagFlagRolloutTestStaticBool22;FFlagFlagRolloutTestStaticBool23;FFlagFlagRolloutTestStaticBool24;FFlagFlagRolloutTestStaticBool25;FFlagFlagRolloutTestStaticBool26;FFlagFlagRolloutTestStaticBool27;FFlagFlagRolloutTestStaticBool28;FFlagFlagRolloutTestStaticBool29;FFlagFlagRolloutTestStaticBool3;FFlagFlagRolloutTestStaticBool30;FFlagFlagRolloutTestStaticBool31;FFlagFlagRolloutTestStaticBool32;FFlagFlagRolloutTestStaticBool33;FFlagFlagRolloutTestStaticBool34;FFlagFlagRolloutTestStaticBool35;FFlagFlagRolloutTestStaticBool36;FFlagFlagRolloutTestStaticBool37;FFlagFlagRolloutTestStaticBool38;FFlagFlagRolloutTestStaticBool39;FFlagFlagRolloutTestStaticBool4;FFlagFlagRolloutTestStaticBool40;FFlagFlagRolloutTestStaticBool41;FFlagFlagRolloutTestStaticBool42;FFlagFlagRolloutTestStaticBool43;FFlagFlagRolloutTestStaticBool44;FFlagFlagRolloutTestStaticBool45;FFlagFlagRolloutTestStaticBool46;FFlagFlagRolloutTestStaticBool47;FFlagFlagRolloutTestStaticBool48;FFlagFlagRolloutTestStaticBool49;FFlagFlagRolloutTestStaticBool5;FFlagFlagRolloutTestStaticBool6;FFlagFlagRolloutTestStaticBool7;FFlagFlagRolloutTestStaticBool8;FFlagFlagRolloutTestStaticBool9;FFlagGpuGeometryManagerIndexBufferAlignment;FFlagGraphicsVulkanSampleCountFix;FFlagMSRefactor5;FFlagNoPlayOnRemoveThroughTeleports;FFlagOptimizeAABBComputation;FFlagPerformanceControlAddStartToConstructor;FFlagPerformanceControlEventBaseTelemetryRateLimitingUnitChange;FFlagRenderFixMissingTrailShaders;FFlagSimCSGV3FixSplitDisjointSolids;FFlagSimConsolidateBVHMidphase2;FFlagSimulateNewStaticFlagRolloutCheck;FFlagVideoVisibilityViewAngleClamp;FFlagVoiceChatEventLoggerAddStateBeforeFailureAbandon;FFlagVoiceChatRequestTurnServerBeforeJoinCapabilityEvent;FIntFlagRolloutTestStaticInt0;FIntFlagRolloutTestStaticInt1;FIntFlagRolloutTestStaticInt2;FIntFlagRolloutTestStaticInt3;FIntFlagRolloutTestStaticInt4;FIntFlagRolloutTestStaticInt5;FIntFlagRolloutTestStaticInt6;FIntFlagRolloutTestStaticInt7;FIntFlagRolloutTestStaticInt8;FIntFlagRolloutTestStaticInt9",
    ["DFStringRobloxAnalyticsSubDomain"] = "opt-out",
    ["DFStringSendPingForCnConnectingToDcList"] = "111,174,191,133",
    ["DFStringTelegrafAddress"] = "1",
    ["DFStringTelegrafHTTPTransportUrl"] = "null",
    ["DFStringTelemetryV2Url"] = "null",
    ["DFStringWebviewUrlAllowlist"] = "",
    ["FFlagAXAdaptiveScrollingAvatarEditor2"] = "True",
    ["FFlagAXAdaptiveScrollingItemResetFix2"] = "True",
    ["FFlagAXAdaptiveScrollingSnapItemEditor"] = "True",
    ["FFlagAXAvatarFetchResultCamelCase"] = "True",
    ["FFlagAXFixAdaptiveScrollingSnapAndroid"] = "True",
    ["FFlagAXFixOutfitLoadingAfterPurchase"] = "True",
    ["FFlagAXSearchLandingPageIXPEnabled4"] = "False",
    ["FFlagAcceleratorUpdateOnPropsAndValueTimeChange"] = "True",
    ["FFlagAccessoryAdjustmentEnabled4"] = "True",
    ["FFlagAdServiceEnabled"] = "False",
    ["FFlagAddHapticsToggle"] = "True",
    ["FFlagAddUDataPingViz"] = "True",
    ["FFlagAllowRegistrationOfAnimationClipInCoreScripts"] = "True",
    ["FFlagAnimatePhysics"] = "False",
    ["FFlagAnimationClipMemCacheEnabled"] = "True",
    ["FFlagAnimatorRetargetSkipAnkleModification"] = "True",
    ["FFlagAssetPreloadingIXP"] = "True",
    ["FFlagAvatarChatServiceEnabled3"] = "False",
    ["FFlagAvatarChatServiceExposeUserVerifiedForVoiceMock"] = "False",
    ["FFlagAvatarChatServiceExposeUserVerifiedForVoiceV2"] = "False",
    ["FFlagBatchAssetApi"] = "True",
    ["FFlagBrowserTrackerIdRequestUseWebId2"] = "False",
    ["FFlagCAP1544UseNewDataSharingRollout"] = "False",
    ["FFlagCSG4StudioBetaFeature"] = "True",
    ["FFlagCSGDecalOptimizeVB"] = "True",
    ["FFlagChatTranslationSettingEnabled3"] = "True",
    ["FFlagCloudsReflectOnWater"] = "True",
    ["FFlagCommitToGraphicsQualityFix"] = "True",
    ["FFlagContentProviderPreloadHangTelemetry"] = "False",
    ["FFlagControlBetaBadgeWithGuac"] = "False",
    ["FFlagCoreGuiSelfViewVisibilityFixed"] = "False",
    ["FFlagCoreGuiTypeSelfViewPresent"] = "False",
    ["FFlagCreationDBCompressRequest"] = "False",
    ["FFlagCrossPlatformMinMTUSize"] = "900",
    ["FFlagDebugAvatarTracking"] = "True",
    ["FFlagDebugCheckRenderThreading"] = "True",
    ["FFlagDebugCodegenOptSize"] = "True",
    ["FFlagDebugCrashReports"] = "False",
    ["FFlagDebugDefaultChannelStartMuted"] = "False",
    ["FFlagDebugDeterministicParticles"] = "False",
    ["FFlagDebugDisableLODFoliage"] = "True",
    ["FFlagDebugDisableLightingTechnologyFeatures"] = "True",
    ["FFlagDebugDisableMaterialSpecular"] = "True",
    ["FFlagDebugDisableOptimizedBytecode"] = "True",
    ["FFlagDebugDisablePhysicsLOD"] = "True",
    ["FFlagDebugDisableRenderingPostEffects"] = "True",
    ["FFlagDebugDisableTelemetryEphemeralCounter"] = "True",
    ["FFlagDebugDisableTelemetryEphemeralStat"] = "True",
    ["FFlagDebugDisableTelemetryEventIngest"] = "True",
    ["FFlagDebugDisableTelemetryEventingest"] = "True",
    ["FFlagDebugDisableTelemetryV2Event"] = "True",
    ["FFlagDebugDisableTelemetryV2Stat"] = "True",
    ["FFlagDebugDisableTextureStreaming"] = "True",
    ["FFlagDebugDisableVideoVorbisDecoder"] = "True",
    ["FFlagDebugDisableWebmAlphaSupport"] = "True",
    ["FFlagDebugDisplayUnthemedInstances"] = "False",
    ["FFlagDebugDoNotLoadHumanoidSounds"] = "True",
    ["FFlagDebugEnableCrashUpload"] = "False",
    ["FFlagDebugEnableDirectAudioOcclusion2"] = "True",
    ["FFlagDebugEnableFov"] = "True",
    ["FFlagDebugEnableVRFTUXExperienceInStudio"] = "True",
    ["FFlagDebugForceChatDisabled"] = "False",
    ["FFlagDebugForceDisable3DRendering"] = "False",
    ["FFlagDebugForceDisableShadows"] = "True",
    ["FFlagDebugForceFSMCPULightCulling"] = "True",
    ["FFlagDebugForceFutureIsBrightPhase2"] = "True",
    ["FFlagDebugForceFutureIsBrightPhase3"] = "True",
    ["FFlagDebugForceGenerateHSR"] = "True",
    ["FFlagDebugForceLowGraphics"] = "True",
    ["FFlagDebugForceModelMeshRendering"] = "False",
    ["FFlagDebugGraphics"] = "False",
    ["FFlagDebugGraphicsDisableMaterials"] = "False",
    ["FFlagDebugGraphicsDisableMetal"] = "True",
    ["FFlagDebugGraphicsDisableVulkan11"] = "False",
    ["FFlagDebugGraphicsForceGL2"] = "True",
    ["FFlagDebugGraphicsGLDisableDiscard"] = "True",
    ["FFlagDebugGraphicsPreferD3D11"] = "True",
    ["FFlagDebugGraphicsPreferD3D11FL10"] = "True",
    ["FFlagDebugGraphicsPreferOpenGL"] = "True",
    ["FFlagDebugGridForceFractalUpsample"] = "True",
    ["FFlagDebugLargeReplicatorEnabled"] = "True",
    ["FFlagDebugLargeReplicatorRead"] = "True",
    ["FFlagDebugLightGridShowChunks"] = "False",
    ["FFlagDebugLuauInGame"] = "False",
    ["FFlagDebugNextGenReplicatorEnabledWriteCFrameColor"] = "True",
    ["FFlagDebugOverrideDPIScale"] = "False",
    ["FFlagDebugPauseVoxelizer"] = "True",
    ["FFlagDebugPerfMode"] = "True",
    ["FFlagDebugPrintDataPingBreakDown"] = "False",
    ["FFlagDebugRenderingSetDeterministic"] = "True",
    ["FFlagDebugSimDefaultPrimalSolver"] = "True",
    ["FFlagDebugSimIntegrationStabilityTesting"] = "True",
    ["FFlagDebugSkyGray"] = "False",
    ["FFlagDebugStudioForceSystemDeprecationNotification"] = "False",
    ["FFlagDebugUpdateClientChannelB"] = "False",
    ["FFlagDebugVulkanDisablePreRotate"] = "False",
    ["FFlagDeveloperToastNotificationsEnabled"] = "False",
    ["FFlagDisableChromeDefaultOpen"] = "True",
    ["FFlagDisableChromeFollowupUnibar"] = "True",
    ["FFlagDisableChromePinnedChat"] = "True",
    ["FFlagDisableChromeUnibar"] = "True",
    ["FFlagDisableDPIScale"] = "True",
    ["FFlagDisableFeedbackSoothsayerCheck"] = "False",
    ["FFlagDisableMostRecentlyUsed"] = "True",
    ["FFlagDisableNewIGMinDUA"] = "True",
    ["FFlagDisableOldCookieManagementSticky"] = "True",
    ["FFlagDisablePostFx"] = "True",
    ["FFlagDontRerenderForBadTexture"] = "True",
    ["FFlagEnableAccessibilitySettingsAPIV2"] = "True",
    ["FFlagEnableAccessibilitySettingsEffectsInExperienceChat"] = "True",
    ["FFlagEnableAudioOutputDevice"] = "False",
    ["FFlagEnableAudioPannerFiltering"] = "True",
    ["FFlagEnableBetaBadgeLearnMore"] = "False",
    ["FFlagEnableBetaFacialAnimation2"] = "False",
    ["FFlagEnableBloom"] = "False",
    ["FFlagEnableBubbleChatConfigurationV2"] = "False",
    ["FFlagEnableBubbleChatFromChatService"] = "True",
    ["FFlagEnableBugSplatTelemetry"] = "False",
    ["FFlagEnableCapturesHotkeyExperiment_v4"] = "False",
    ["FFlagEnableChildrenLockFromLua"] = "False",
    ["FFlagEnableChildrenLockFromLua2"] = "False",
    ["FFlagEnableChromeFTUX"] = "True",
    ["FFlagEnableChromePinnedChat"] = "True",
    ["FFlagEnableColorCorrection"] = "False",
    ["FFlagEnableCrashUploader"] = "False",
    ["FFlagEnableCrashpadUploader"] = "True",
    ["FFlagEnableCullableScene2OptimizeStep"] = "True",
    ["FFlagEnableDepthOfField"] = "False",
    ["FFlagEnableDropdownButtonTelemetry"] = "False",
    ["FFlagEnableExperienceNotificationPrompts2"] = "False",
    ["FFlagEnableFavoriteButtonForUgc"] = "True",
    ["FFlagEnableHumanoidLuaSideCaching"] = "False",
    ["FFlagEnableIOSWebViewCookieSyncFix"] = "False",
    ["FFlagEnableIXPInGame"] = "True",
    ["FFlagEnableInGameMenuChromeABTest2"] = "True",
    ["FFlagEnableInGameMenuChromeABTest3"] = "True",
    ["FFlagEnableInGameMenuChromeABTest4"] = "True",
    ["FFlagEnableInGameMenuControls"] = "False",
    ["FFlagEnableInGameMenuDurationLogger"] = "False",
    ["FFlagEnableInGameMenuModernization"] = "True",
    ["FFlagEnableInGameMenuV3"] = "True",
    ["FFlagEnableLightAttachToPart"] = "True",
    ["FFlagEnableLightingTechnologyV2"] = "False",
    ["FFlagEnableMenuModernizationABTest"] = "False",
    ["FFlagEnableMenuModernizationABTest2"] = "False",
    ["FFlagEnableModernLighting"] = "False",
    ["FFlagEnableNewFontNameMappingABTest2"] = "True",
    ["FFlagEnableNewGPUClustering"] = "False",
    ["FFlagEnableNewInput"] = "True",
    ["FFlagEnableNewInviteMenuIXP2"] = "False",
    ["FFlagEnablePlayerViewBoundingBoxSizeDamping"] = "True",
    ["FFlagEnablePreferredTextSizeConnection"] = "True",
    ["FFlagEnablePreferredTextSizeGuiService"] = "True",
    ["FFlagEnablePreferredTextSizeScale"] = "True",
    ["FFlagEnablePreferredTextSizeScalePerLayerCollector"] = "True",
    ["FFlagEnablePreferredTextSizeStyleFixesGameTile"] = "True",
    ["FFlagEnablePreferredTextSizeStyleFixesInAppShell3"] = "True",
    ["FFlagEnablePreferredTextSizeStyleFixesInAppShell4"] = "True",
    ["FFlagEnablePreferredTextSizeStyleFixesInCaptureMenu"] = "True",
    ["FFlagEnablePreferredTextSizeStyleFixesInExperienceMenu"] = "True",
    ["FFlagEnablePreferredTextSizeStyleFixesInPlayerList"] = "True",
    ["FFlagEnablePremiumSponsoredExperienceReporting"] = "False",
    ["FFlagEnableQuickGameLaunch"] = "True",
    ["FFlagEnableReplayCleanup"] = "True",
    ["FFlagEnableReportAbuseMenuLayerOnV3"] = "False",
    ["FFlagEnableReportAbuseMenuRoact2"] = "False",
    ["FFlagEnableReportAbuseMenuRoactABTest2"] = "True",
    ["FFlagEnableRhiFallback"] = "True",
    ["FFlagEnableRuntimeThreadVisQueries"] = "True",
    ["FFlagEnableSponsoredAdsGameCarouselTooltip3"] = "False",
    ["FFlagEnableSponsoredAdsPerTileTooltipExperienceFooter"] = "False",
    ["FFlagEnableSponsoredTooltipForAvatarCatalog2"] = "False",
    ["FFlagEnableSunRays"] = "False",
    ["FFlagEnableTeleportJoinDataFix"] = "True",
    ["FFlagEnableTeleportTimeTracking"] = "True",
    ["FFlagEnableTerrainDecoration"] = "False",
    ["FFlagEnableTerrainOptimizations"] = "True",
    ["FFlagEnableUnibarMaxDefaultOpen"] = "True",
    ["FFlagEnableV3MenuABTest3"] = "False",
    ["FFlagEnableVRFTUXExperienceV2"] = "True",
    ["FFlagEnableVRServiceStoppingState"] = "True",
    ["FFlagEnableViewportFrame"] = "False",
    ["FFlagEnableVisBugChecks"] = "True",
    ["FFlagEnableVisBugChecks27"] = "True",
    ["FFlagEnableVisBugChecks28"] = "True",
    ["FFlagEnableZstdForClientSettings"] = "False",
    ["FFlagEngineAPICloudProcessingUseNotificationClient"] = "False",
    ["FFlagErrorPromptResizesHeight"] = "False",
    ["FFlagFRMRefactor"] = "False",
    ["FFlagFailsafeHumanoid_3"] = "True",
    ["FFlagFirstGuiLayerCollectorAncestorControlsClipping"] = "True",
    ["FFlagFixChunkLightingUpdate2"] = "True",
    ["FFlagFixCountOfUnreadNotificationError"] = "False",
    ["FFlagFixEmotesMenuVR"] = "True",
    ["FFlagFixExitDialogBlockVRView"] = "True",
    ["FFlagFixGraphicsQuality"] = "True",
    ["FFlagFixGraphicsQualitySetting"] = "False",
    ["FFlagFixGuiRTCacheQuadTreeNestedClipping"] = "True",
    ["FFlagFixIGMBottomBarVisibility"] = "True",
    ["FFlagFixIGMTabTransitions"] = "True",
    ["FFlagFixMemoryPriorizationCrash"] = "True",
    ["FFlagFixMeshPartScaling"] = "False",
    ["FFlagFixMissingStatsHelper"] = "True",
    ["FFlagFixOutdatedParticles2"] = "False",
    ["FFlagFixOutdatedTimeScaleParticles"] = "False",
    ["FFlagFixOverlappingTextMasterVolume"] = "True",
    ["FFlagFixParticleAttachmentCulling"] = "False",
    ["FFlagFixParticleEmissionBias2"] = "False",
    ["FFlagFixPlainTextAutomaticSizeClippingText"] = "True",
    ["FFlagFixPluginSecurityCheck"] = "True",
    ["FFlagFixRemoveSlotFromUser"] = "False",
    ["FFlagFixScreenGuiUIScaleClipping"] = "True",
    ["FFlagFixScreenGuiUnparent"] = "False",
    ["FFlagFixScriptProfiler"] = "True",
    ["FFlagFixSelfViewPopin"] = "False",
    ["FFlagFixSensitivityTextPrecision"] = "False",
    ["FFlagFixSettingsHubVRBackgroundError"] = "True",
    ["FFlagFixShutdownHang"] = "False",
    ["FFlagFixTeleportBlocking"] = "False",
    ["FFlagFixTextboxSinkingInputOfOverlappingButtons"] = "False",
    ["FFlagFixTreeLODBias"] = "True",
    ["FFlagFixVideoCaptureError"] = "True",
    ["FFlagFutureIsBrightPhase3Vulkan"] = "True",
    ["FFlagGameBasicSettingsFramerateCap"] = "False",
    ["FFlagGameBasicSettingsFramerateCap5"] = "True",
    ["FFlagGlobalWindActivated"] = "False",
    ["FFlagGlobalWindRendering"] = "False",
    ["FFlagGraphicsASTC"] = "True",
    ["FFlagGraphicsEnableD3D10Compute"] = "True",
    ["FFlagGraphicsGLTextureReduction"] = "True",
    ["FFlagGraphicsParticlesFlipbookInvalidateEntity"] = "False",
    ["FFlagGraphicsQualityAutoDetect"] = "False",
    ["FFlagGraphicsTextureCopy"] = "True",
    ["FFlagGraphicsVulkanBonusMemory"] = "True",
    ["FFlagGuiHidingApiSupport2"] = "True",
    ["FFlagHSRClusterImprovement"] = "True",
    ["FFlagHandleAltEnterFullscreenManually"] = "False",
    ["FFlagHighlightOutlinesOnMobile"] = "True",
    ["FFlagHumanoidDescriptionFallback"] = "True",
    ["FFlagHumanoidDescriptionUseInstances5"] = "True",
    ["FFlagHumanoidParallelFasterSetCollision"] = "True",
    ["FFlagHumanoidParallelRemoveNoPhysics"] = "True",
    ["FFlagHumanoidUseNewClimbingPhysics"] = "False",
    ["FFlagImproveInputLatency"] = "False",
    ["FFlagImproveShiftLockTransition"] = "True",
    ["FFlagImproveViewportCapture"] = "False",
    ["FFlagInExperienceUpsellSelfViewFix"] = "False",
    ["FFlagInGameMenuV1ExitModal"] = "True",
    ["FFlagInGameMenuV1FullScreenTitleBar"] = "False",
    ["FFlagInGameMenuV1LeaveToHome"] = "False",
    ["FFlagInternetPingUponDisconnect"] = "True",
    ["FFlagIsAppleSilicon"] = "True",
    ["FFlagIsMacOSBigSurOrHigher"] = "True",
    ["FFlagIsVulkanSupported"] = "True",
    ["FFlagJointIrregularityOptimization"] = "True",
    ["FFlagLanguageFeaturesTelemetry"] = "False",
    ["FFlagLightgridCPUAsyncUpdate"] = "True",
    ["FFlagLimitSleeps"] = "True",
    ["FFlagLuaAppEnableFoundationColors"] = "True",
    ["FFlagLuaAppEnableFoundationColors7"] = "True",
    ["FFlagLuaAppEnableParentalControlExperiment"] = "False",
    ["FFlagLuaAppEnableToastNotificationsCoreScripts4"] = "False",
    ["FFlagLuaAppExitModal2"] = "False",
    ["FFlagLuaAppExitModalDoNotShow"] = "True",
    ["FFlagLuaAppFixSponsoredTooltipPeekViewBorder"] = "False",
    ["FFlagLuaAppLegacyInputSettingRefactor"] = "True",
    ["FFlagLuaAppSponsoredGridTiles"] = "False",
    ["FFlagLuaAppSponsoredTooltipCustomColorSupport"] = "False",
    ["FFlagLuaAppSystemBar"] = "False",
    ["FFlagLuaAppUseUIBloxColorPalettes1"] = "True",
    ["FFlagLuaAppsEnableParentalControlsTab"] = "False",
    ["FFlagLuaMenuPerfImprovements"] = "True",
    ["FFlagLuauCodegen"] = "True",
    ["FFlagLuauFixIndexerSubtypingOrdering"] = "True",
    ["FFlagLuauInstantiateInSubtyping"] = "True",
    ["FFlagLuauSupportFlagAttributes"] = "True",
    ["FFlagMSRefactor5"] = "False",
    ["FFlagMacWindowInTitlebar"] = "True",
    ["FFlagMessageBusCallOptimization"] = "True",
    ["FFlagMetalSupport"] = "True",
    ["FFlagMoodDampingIxpExperimentation"] = "True",
    ["FFlagMouseGetPartOptimization"] = "True",
    ["FFlagNewCSGAPIBetaFeature"] = "True",
    ["FFlagNewCameraControls"] = "True",
    ["FFlagNewCameraControls_MouseDeltaFix"] = "True",
    ["FFlagNewLightAttenuation"] = "True",
    ["FFlagNewNetworking"] = "False",
    ["FFlagNewOptimizeNoCollisionPrimitiveInMidphase651"] = "True",
    ["FFlagNextGenReplicatorEnabledWrite"] = "True",
    ["FFlagNotificationPluginSignalRReadEvents"] = "False",
    ["FFlagNullCheckCloudsRendering"] = "True",
    ["FFlagOptimizeNetworkTransport"] = "True",
    ["FFlagOptimizePartsInPart"] = "True",
    ["FFlagOptimizeScreenCapture"] = "False",
    ["FFlagOptimizeServerTickRate"] = "True",
    ["FFlagOverlappingRemoteNameTags"] = "True",
    ["FFlagPPDebugLogging"] = "True",
    ["FFlagParallelAnimatorDefaultEnable"] = "False",
    ["FFlagParticleFlipbookLayoutNoReset"] = "True",
    ["FFlagParticleLocalTransparencyModifierEnabled2"] = "True",
    ["FFlagPgsPhysicsSolverEnabled"] = "True",
    ["FFlagPreOptimizeNoCollisionPrimitive"] = "True",
    ["FFlagPreferredTextSizeSettingBetaFeature"] = "True",
    ["FFlagPreloadAllFonts"] = "True",
    ["FFlagPreloadMinimalFonts"] = "True",
    ["FFlagPushFrameTimeToHarmony"] = "True",
    ["FFlagRakNetCalculateApplicationFeedback2"] = "True",
    ["FFlagRakNetDetectRecvThreadOverload"] = "True",
    ["FFlagRakNetEnablePoll"] = "True",
    ["FFlagRakNetUseSlidingWindow4"] = "True",
    ["FFlagRealTimeAnimationEnableRefactor"] = "True",
    ["FFlagReconnectDisabled"] = "True",
    ["FFlagReduceDirtyFlagSettings"] = "True",
    ["FFlagRemapAnimationR6ToR15Rig"] = "True",
    ["FFlagRemoveLegacyScriptSignal"] = "False",
    ["FFlagRemoveRedundantFontPreloading"] = "True",
    ["FFlagRemovedRbxRenderingPreProcessor"] = "False",
    ["FFlagRenderCBRefactor"] = "True",
    ["FFlagRenderCheckThreading6"] = "True",
    ["FFlagRenderDebugCheckThreading2"] = "True",
    ["FFlagRenderDynamicResolutionScale"] = "True",
    ["FFlagRenderDynamicResolutionScale7"] = "True",
    ["FFlagRenderDynamicResolutionScale8"] = "True",
    ["FFlagRenderDynamicResolutionScale9"] = "True",
    ["FFlagRenderEnableGlobalInstancingD3D10"] = "False",
    ["FFlagRenderEnableGlobalInstancingD3D11"] = "True",
    ["FFlagRenderEnableGlobalInstancingMetal"] = "True",
    ["FFlagRenderEnableGlobalInstancingVulkan"] = "True",
    ["FFlagRenderFixDofFramebufferDrawportSetting2"] = "False",
    ["FFlagRenderFixFog"] = "True",
    ["FFlagRenderFixParticleDegenCrossProduct"] = "True",
    ["FFlagRenderFrontendVulkanEnableValidation"] = "False",
    ["FFlagRenderGpuTextureCompressor"] = "False",
    ["FFlagRenderLegacyShadowsQualityRefactor"] = "True",
    ["FFlagRenderNoLowFrmBloom"] = "False",
    ["FFlagRenderOptimizeDecalTransparencyInvalidation"] = "True",
    ["FFlagRenderShadowSkipHugeCulling"] = "True",
    ["FFlagRenderTestEnableDistanceCulling"] = "True",
    ["FFlagReplicatorCheckReadTableCollisions"] = "True",
    ["FFlagReplicatorSeparateVarThresholds"] = "True",
    ["FFlagRobloxGuiDontUseLegacyChat"] = "True",
    ["FFlagSafeModeOSSignals"] = "True",
    ["FFlagScreenGui3dRayHitPointFix"] = "True",
    ["FFlagScreenGuiRaycastsFixLag"] = "True",
    ["FFlagSelfViewFixes"] = "False",
    ["FFlagSelfViewGetRidOfFalselyRenderedFaceDecal"] = "False",
    ["FFlagSelfViewHumanoidNilCheck"] = "False",
    ["FFlagSelfViewLookUpHumanoidByType"] = "False",
    ["FFlagSelfViewMoreNilChecks"] = "False",
    ["FFlagSelfViewRemoveVPFWhenClosed"] = "False",
    ["FFlagSelfViewTweaksPass"] = "False",
    ["FFlagSelfViewUpdatedCamFraming"] = "False",
    ["FFlagSelfieViewEnabled"] = "True",
    ["FFlagSetCoreGuiVisibilityFix"] = "True",
    ["FFlagSettingsHubIndependentBackgroundVisibility"] = "True",
    ["FFlagShaderLightingRefactor"] = "True",
    ["FFlagShadowMapEnable"] = "False",
    ["FFlagShareUploadSpeedLimit"] = "True",
    ["FFlagShoeSkipRenderMesh"] = "False",
    ["FFlagSignalRNotificationManagerMaybeStart"] = "False",
    ["FFlagSimAdaptiveMinorOptimizations"] = "True",
    ["FFlagSimCSG4EnableMesh"] = "True",
    ["FFlagSimCSGV3IncrementalTriangulationStreamingCompression"] = "False",
    ["FFlagSimEnableDCD10"] = "True",
    ["FFlagSimIslandizerManager"] = "False",
    ["FFlagSimRefactorSteppingParams"] = "True",
    ["FFlagSkipJoinedSessionLog"] = "True",
    ["FFlagSortKeyOptimization"] = "True",
    ["FFlagSquadToastNotificationsEnabled"] = "False",
    ["FFlagStopClippingAllCoreGuiUI"] = "False",
    ["FFlagStudioCrashPadUploadToBacktrace"] = "False",
    ["FFlagStudioDataCollectionAddBasicNotification"] = "False",
    ["FFlagStudioEnableBetterScriptEditor2"] = "True",
    ["FFlagStudioEnableCoreScriptAnalysis"] = "False",
    ["FFlagStudioEnableCorescriptEditing2"] = "True",
    ["FFlagStudioEnableCorescriptMetadata"] = "True",
    ["FFlagStudioEnableScriptAutoRecovery2"] = "True",
    ["FFlagStudioReloadPluginsOnFocus2"] = "True",
    ["FFlagStudioRoslynAnalyzers"] = "True",
    ["FFlagStudioScriptAutoRecoveryLogs"] = "False",
    ["FFlagStudioShowScriptErrorsInOutput"] = "True",
    ["FFlagStudioUseNewEditorTheme"] = "True",
    ["FFlagStudioUseScriptAnalysisSettings"] = "True",
    ["FFlagStudioUseTreeView"] = "True",
    ["FFlagSupportAlreadyOwnedItemPurchaseStatus"] = "True",
    ["FFlagSyncWebViewCookieToEngine2"] = "False",
    ["FFlagTaskSchedulerLimitTargetFpsTo2402"] = "False",
    ["FFlagTerrainUseLODV2"] = "True",
    ["FFlagTextureQualityOverrideEnabled"] = "True",
    ["FFlagToastNotificationsProtocolEnabled2"] = "False",
    ["FFlagToastNotificationsReceivedAndDismissedSignals"] = "False",
    ["FFlagToastNotificationsResendDisplayOnInit"] = "False",
    ["FFlagToastNotificationsUpdateEventParams"] = "False",
    ["FFlagTopBarUseNewBadge"] = "False",
    ["FFlagTrackerLodControllerDebugUI"] = "True",
    ["FFlagTweenOptimizations"] = "True",
    ["FFlagUISUseLastFrameTimeInUpdateInputSignal"] = "True",
    ["FFlagUISelectionJumping3"] = "True",
    ["FFlagUseDynamicSun"] = "False",
    ["FFlagUseImprovedUpdateTeleportData"] = "True",
    ["FFlagUseLegacyGraphicsQuality"] = "True",
    ["FFlagUseNewAnimationSystem"] = "False",
    ["FFlagUseNewInput"] = "True",
    ["FFlagUseNewPinIcon"] = "False",
    ["FFlagUseNewSecurityContext"] = "True",
    ["FFlagUseParticlesV2"] = "False",
    ["FFlagUseWkWebViewForWebView"] = "True",
    ["FFlagUserCameraInputDt"] = "True",
    ["FFlagUserCameraInputRefactor3"] = "True",
    ["FFlagUserDisable3dInputLatencyFix"] = "False",
    ["FFlagUserDisableMouseMovementPrediction"] = "True",
    ["FFlagUserDisableTextureStreaming"] = "True",
    ["FFlagUserFixBubbleChatText"] = "True",
    ["FFlagUserFixLoadAnimationError"] = "True",
    ["FFlagUserFixZoomClampingIssues"] = "True",
    ["FFlagUserGpuUploadCull"] = "True",
    ["FFlagUserGraphicsLowQuality"] = "True",
    ["FFlagUserHideCharacterParticlesInFirstPerson"] = "True",
    ["FFlagUserPhysicsSleep"] = "True",
    ["FFlagUserReduceInputLatency"] = "True",
    ["FFlagUserRunAllCharacterScripts"] = "True",
    ["FFlagUserSetInputToPoll"] = "True",
    ["FFlagUserShouldClipInGameChat"] = "True",
    ["FFlagUserShowGuiHideToggles"] = "True",
    ["FFlagUserShowVerifiedBadgeInLegacyChat"] = "False",
    ["FFlagUserUpdateInputConnections"] = "True",
    ["FFlagVRBackpackImproved"] = "True",
    ["FFlagVRFixCursorJitterLua"] = "True",
    ["FFlagVRLaserPointerOptimization"] = "True",
    ["FFlagVideoRenderUseHardwareBuffer"] = "True",
    ["FFlagVideoReportHardwareBufferMetrics"] = "True",
    ["FFlagVideoServiceAddHardwareCodecMetrics"] = "True",
    ["FFlagVideoTextureSupportHardwareRender"] = "True",
    ["FFlagVideoUseNewHardwareCodec4"] = "True",
    ["FFlagViewCollisionFadeToBlackInVR"] = "False",
    ["FFlagVignetteEffectEnabled4"] = "True",
    ["FFlagVisBugChecksThreadYield"] = "True",
    ["FFlagVoiceBetaBadge"] = "False",
    ["FIntAMPVerifiedTelemetryHundredthsPercentage"] = "0",
    ["FIntAMPVerifiedTelemetryPointsHundredthsPercentage"] = "0",
    ["FIntAXAdaptiveScrollingJustSelectedMillis"] = "2000",
    ["FIntActivatedCountTimerMSKeyboard"] = "1",
    ["FIntActivatedCountTimerMSMouse"] = "1",
    ["FIntActivatedCountTimerMSTouch"] = "1",
    ["FIntAnimationLodFacsDistanceMax"] = "0",
    ["FIntAnimationLodFacsDistanceMin"] = "0",
    ["FIntAnimationLodFacsVisibilityDenominator"] = "0",
    ["FIntAnimatorThrottleMaxFramesToSkip"] = "1",
    ["FIntBandwidthManagerDataSenderMaxWorkCatchupMs"] = "250",
    ["FIntBootstrapperWebView2InstallationTelemetryHundredthPercent"] = "0",
    ["FIntBufferCompressionLevel"] = "0",
    ["FIntBufferCompressionThreshold"] = "100",
    ["FIntCAP1209DataSharingRolloutPercentage"] = "0",
    ["FIntCAP1209DataSharingTOSVersion"] = "0",
    ["FIntCSGLevelOfDetailSwitchingDistance"] = "1",
    ["FIntCSGLevelOfDetailSwitchingDistanceL12"] = "2",
    ["FIntCSGLevelOfDetailSwitchingDistanceL23"] = "3",
    ["FIntCSGLevelOfDetailSwitchingDistanceL34"] = "4",
    ["FIntCSGVoxelizerFadeRadius"] = "2",
    ["FIntCanHideGuiGroupId"] = "32380007",
    ["FIntClientLightingTechnologyChangedTelemetryHundredthsPercent"] = "0",
    ["FIntClientPacketExcessMicroseconds"] = "5000",
    ["FIntClientPacketHealthyAllocationPercent"] = "20",
    ["FIntClientPacketMaxDelayMs"] = "0",
    ["FIntClientPacketMaxFrameMicroseconds"] = "500",
    ["FIntCodecMaxIncomingPackets"] = "100",
    ["FIntCodecMaxOutgoingFrames"] = "10000",
    ["FIntCoordinatorPlannerStepsPerIteration"] = "8",
    ["FIntDataSenderMaxBandwidthBps"] = "5",
    ["FIntDataSenderMaxBandwidthBpsMultiplier"] = "5",
    ["FIntDataSenderMaxJoinBandwidthBps"] = "9600000",
    ["FIntDataSenderMaxJoinBandwidthBpsMultiplier"] = "5",
    ["FIntDataSenderRate"] = "38760",
    ["FIntDebugDefaultTargetWorldStepsPerFrame"] = "0",
    ["FIntDebugDynamicRenderKiloPixels"] = "2074",
    ["FIntDebugFRMOptionalMSAALevelOverride"] = "0",
    ["FIntDebugFRMQualityLevelOverride"] = "1",
    ["FIntDebugForceMSAASamples"] = "0",
    ["FIntDebugPerformanceControlUsedMemoryMB"] = "1",
    ["FIntDebugTextureManagerSkipMips"] = "2",
    ["FIntEmotesAnimationsPerPlayerCacheSize"] = "16777216",
    ["FIntEnableCullableScene2HundredthPercent3"] = "100",
    ["FIntEnableVisBugChecksHundredthPercent27"] = "100",
    ["FIntFRMMaxGrassDistance"] = "0",
    ["FIntFRMMinGrassDistance"] = "0",
    ["FIntFastClusterHumanoidBudgetMb"] = "256",
    ["FIntFastClusterHumanoidLoadingMaxCount"] = "10",
    ["FIntFixForBulkPresenceNotifications"] = "0",
    ["FIntFontSizePadding"] = "5",
    ["FIntFriendRequestNotificationThrottle"] = "0",
    ["FIntFullscreenTitleBarTriggerDelayMillis"] = "3600000",
    ["FIntGameGridFlexFeedItemTileNumPerFeed"] = "0",
    ["FIntGameNetPVHeaderLinearVelocityZeroCutoffExponent"] = "10",
    ["FIntGamePerfMonitorReportTimer"] = "0",
    ["FIntGraphics"] = "0",
    ["FIntGraphicsOptimizationModeFRMFrameRateTarget"] = "60",
    ["FIntGraphicsOptimizationModeMaxFrameTimeTargetMs"] = "18",
    ["FIntGraphicsOptimizationModeMinFrameTimeTargetMs"] = "17",
    ["FIntGraphicsTextureReductionD3D11"] = "100",
    ["FIntGrassMovementReducedMotionFactor"] = "0",
    ["FIntHSRClusterSymmetryDistancePercent"] = "10000",
    ["FIntHttpBatchApi_bgDelayMs"] = "1",
    ["FIntHttpBatchApi_bgRefreshMaxDelayMs"] = "1",
    ["FIntHttpBatchApi_cacheDelayMs"] = "20",
    ["FIntInitialAccelerationLatencyMultTenths"] = "1",
    ["FIntInterpolationAwareTargetTimeLerpHundredth"] = "100",
    ["FIntInterpolationDtLimitForLod"] = "10",
    ["FIntInterpolationFrameRotVelocityThresholdMillionth"] = "1",
    ["FIntInterpolationFrameVelocityThresholdMillionth"] = "1",
    ["FIntInterpolationMaxDelayMSec"] = "75",
    ["FIntInterpolationMinAssemblyCount"] = "1",
    ["FIntInterpolationNumMechanismsBatchSize"] = "1",
    ["FIntInterpolationNumMechanismsPerTask"] = "5",
    ["FIntInterpolationNumParallelTasks"] = "5",
    ["FIntLargeDataSenderMaxBandwidthBps"] = "400000",
    ["FIntLargeDataSenderMinBandwidthBps"] = "400000",
    ["FIntLargePacketQueueSizeCutoffMB"] = "1000",
    ["FIntLmsClientRollout2"] = "0",
    ["FIntLuaGcParallelMinMultiTasks"] = "2",
    ["FIntMaquettesFrameRateBufferPercentage"] = "50",
    ["FIntMaxAcceptableUpdateDelay"] = "1",
    ["FIntMaxDataPacketPerSend"] = "2147483647",
    ["FIntMaxFrameBufferSize"] = "10",
    ["FIntMaxFramesToSend"] = "1",
    ["FIntMaxInterpolationRecursionsBeforeCheck"] = "1",
    ["FIntMaxMissedWorldStepsRemembered"] = "16",
    ["FIntMaxProcessPacketsJobScaling"] = "10000",
    ["FIntMaxProcessPacketsStepsAccumulated"] = "0",
    ["FIntMaxProcessPacketsStepsPerCyclic"] = "5000",
    ["FIntMaxSpeedDeltaMillis"] = "1",
    ["FIntMaxThrottleCount"] = "0",
    ["FIntMegaReplicatorNetworkQualityProcessorUnit"] = "10",
    ["FIntMegaReplicatorNumParallelTasks"] = "12",
    ["FIntMockClientLightingTechnologyIxpExperimentQualityLevel"] = "1",
    ["FIntModelLodDetailed"] = "-1",
    ["FIntNetworkClusterPacketCacheNumParallelTasks"] = "2",
    ["FIntNetworkDataSenderHaltReportThrottleHP"] = "10",
    ["FIntNetworkDataSenderHaltThresholdMs"] = "10000",
    ["FIntNetworkSchemaCompressionRatio"] = "100",
    ["FIntNewInGameMenuPercentRollout3"] = "100",
    ["FIntNumFramesAllowedToBeAboveError"] = "1",
    ["FIntNumFramesToKeepAfterInterpolation"] = "1",
    ["FIntOcclusionCullingBetaFeatureRolloutPercent"] = "100",
    ["FIntOpenXrFramebufferHeightOverride"] = "0",
    ["FIntOpenXrFramebufferWidthOverride"] = "0",
    ["FIntOverrideISRReplicatorStepBandwidthBytes"] = "131072",
    ["FIntPerformanceControlFrameTimeMax"] = "1",
    ["FIntPerformanceControlFrameTimeMaxUtility"] = "-1",
    ["FIntPerformanceControlIXPBestQueueSize"] = "1",
    ["FIntPerformanceControlIXPQueueSizeBestUtility"] = "1",
    ["FIntPerformanceControlIXPQueueSizeUtilityExponentTenThousandths"] = "1",
    ["FIntPerformanceControlPredictedOOMAbsLimitExtraBufferMB"] = "1",
    ["FIntPerformanceControlSoundReloadLatencyMaxValue"] = "1",
    ["FIntPerformanceControlSoundReloadLatencyMinValue"] = "1",
    ["FIntPerformanceControlSoundReloadLatencyTargetUtility"] = "1",
    ["FIntPhysicsAnalyticsHighFrequencyIntervalSec"] = "12",
    ["FIntPhysicsReceiveNumParallelTasks"] = "12",
    ["FIntRagdollDefaultTimerTenthSecond"] = "1",
    ["FIntRagdollEarlyExitTimeTenthSecond"] = "1",
    ["FIntRagdollSlowEnoughToNotTenth"] = "1",
    ["FIntRakNetClockDriftAdjustmentPerPingMillisecond"] = "50",
    ["FIntRakNetDatagramMessageIdArrayLength"] = "1024",
    ["FIntRakNetPingFrequencyMillisecond"] = "2000",
    ["FIntRakNetResendBufferArrayLength"] = "128",
    ["FIntRaknetBandwidthPingSendEveryXSeconds"] = "1",
    ["FIntRefreshRateLowerBound"] = "100",
    ["FIntRenderGrassHeightScaler"] = "0",
    ["FIntRenderLocalLightFadeInMs"] = "340",
    ["FIntRenderLocalLightFadeInMs_enabled"] = "340",
    ["FIntRenderLocalLightUpdatesMax"] = "1",
    ["FIntRenderLocalLightUpdatesMin"] = "1200",
    ["FIntRenderMaxShadowAtlasUsageBeforeDownscale"] = "1",
    ["FIntRenderMeshOptimizeVertexBuffer"] = "1",
    ["FIntRenderShadowIntensity"] = "0",
    ["FIntRenderShadowmapBias"] = "0",
    ["FIntRenderTextureCompositor"] = "0",
    ["FIntReplicationDataCacheNumParallelTasks"] = "12",
    ["FIntReplicatorDataPingReportHundredthPercentage"] = "5",
    ["FIntReplicatorDataPingReportThresholdMs"] = "5000",
    ["FIntReplicatorDataPingReportThrottleSeconds"] = "5",
    ["FIntReplicatorJdiReportThrottlePercent"] = "0",
    ["FIntReportDeviceInfoRollout"] = "0",
    ["FIntRobloxGuiBlurIntensity"] = "0",
    ["FIntRobloxMainWindow"] = "190000",
    ["FIntRobloxTelemetry"] = "0",
    ["FIntRomarkStartWithGraphicQualityLevel"] = "1",
    ["FIntRuntimeMaxNumOfConditions"] = "1000000",
    ["FIntRuntimeMaxNumOfDPCs"] = "64",
    ["FIntRuntimeMaxNumOfLatches"] = "1000000",
    ["FIntRuntimeMaxNumOfThreads"] = "2400",
    ["FIntS2PhysicsSenderRate"] = "5",
    ["FIntSSAOMipLevels"] = "0",
    ["FIntScrollWheelDeltaAmount"] = "140",
    ["FIntSendGameServerDataMaxLen"] = "200000",
    ["FIntServerBandwidthPlayerSampleRate"] = "15",
    ["FIntSignalRCoreHandshakeTimeoutMs"] = "1000",
    ["FIntSignalRCoreHubBaseRetryMs"] = "50",
    ["FIntSignalRCoreHubConnectionDisconnectInfoHundredthsPercent"] = "10",
    ["FIntSignalRCoreHubMaxBackoffMs"] = "500",
    ["FIntSignalRCoreHubMaxElapsedMs"] = "5000",
    ["FIntSignalRCoreKeepAlivePingPeriodMs"] = "1000",
    ["FIntSignalRCoreRpcQueueSize"] = "16384",
    ["FIntSignalRCoreServerTimeoutMs"] = "500",
    ["FIntSignalRCoreTimerMs"] = "50",
    ["FIntSignalRHeartbeatIntervalSeconds"] = "1",
    ["FIntSignalRHubConnectionBaseRetryTimeMs"] = "50",
    ["FIntSignalRHubConnectionConnectTimeoutMs"] = "7000",
    ["FIntSignalRHubConnectionHeartbeatTimerRateMs"] = "1000",
    ["FIntSimConstraintDataCollectionRate3"] = "5",
    ["FIntSimReportAveWorldstepTimeEventIngestPercent"] = "100",
    ["FIntSimReportAveWorldstepTimePercent"] = "750",
    ["FIntSimWorldTaskQueueParallelTasks"] = "20",
    ["FIntSkipSomePropertiesPermyriad"] = "5000",
    ["FIntSmoothClusterTaskQueueMaxParallelTasks"] = "4",
    ["FIntSmoothMouseSpringFrequencyTenths"] = "100",
    ["FIntSmoothTerrainPhysicsCacheSize"] = "250",
    ["FIntStudioResendDisconnectNotificationInterval"] = "0",
    ["FIntStudioWebView2TelemetryHundredthsPercent"] = "0",
    ["FIntTargetRefreshRate"] = "100",
    ["FIntTaskSchedulerAutoThreadLimit"] = "6",
    ["FIntTaskSchedulerThreadMin"] = "3",
    ["FIntTerrainArraySliceSize"] = "0",
    ["FIntTextureQualityOverride"] = "3",
    ["FIntThrottlingPredictionAccelerationHoldThousandth"] = "2",
    ["FIntTimeBetweenSendConnectionAttemptsMS"] = "200",
    ["FIntTimestepArbiterAccelerationModelFactorThou"] = "50000",
    ["FIntTimestepArbiterAngAccelerationThresholdThou"] = "2000",
    ["FIntTimestepArbiterThresholdCFLThou"] = "300",
    ["FIntTrackerDataSenderMaxBandwidthBps"] = "5850",
    ["FIntUGCValidationLeftArmThresholdFront"] = "27",
    ["FIntUGCValidationLeftArmThresholdSide"] = "40",
    ["FIntUGCValidationLeftLegThresholdFront"] = "40",
    ["FIntUGCValidationRightArmThresholdFront"] = "50",
    ["FIntUGCValidationRightArmThresholdSide"] = "80",
    ["FIntUGCValidationRightLegThresholdBack"] = "80",
    ["FIntUGCValidationRightLegThresholdSide"] = "76",
    ["FIntUGCValidationTorsoThresholdSide"] = "200",
    ["FIntUnifiedLightingBlendZone"] = "1",
    ["FIntV1MenuLanguageSelectionFeaturePerMillageRollout"] = "0",
    ["FIntVRTouchControllerTransparency"] = "0",
    ["FIntVertexSmoothingGroupTolerance"] = "0",
    ["FIntVisibilityCheckRayCastLimitPerFrame"] = "10",
    ["FIntWaitOnRecvFromLoopEndedMS"] = "5000",
    ["FIntWaitOnUpdateNetworkLoopEndedMS"] = "100",
    ["FIntWorldStepDtAveExpFactorHundredth"] = "1",
    ["FIntWorldStepMax"] = "30",
    ["FIntWorldStepsOffsetAdjustRate"] = "100",
    ["FLogDisableAECIxpLayer"] = "True",
    ["FLogDisableAECVariantParam"] = "True",
    ["FLogGraphicsGLGpuExcludeListSuperHQShaders"] = "True",
    ["FLogIXPGraphicsOptimizationModePerformanceScale"] = "100",
    ["FLogIXPGraphicsOptimizationModeQualityScale"] = "0",
    ["FLogNetwork"] = "7",
    ["FStringAXCategories"] = "ClassicShirts.ClassicTShirts.ClassicPants",
    ["FStringAXDefaultAvatarToShopLayer3"] = "AvatarMarketplace.ShoppingCart",
    ["FStringAdUnitDefaultNames"] = "BasePortal;AdGui;AdPortal;Fairy Portal Template;Forest Portal Template;Future Portal Template;Image Ad Unit 1;Image Ad Unit 2;Image Ad Unit 3;Main Portal Template;Stone Portal Template;Storefront Portal Template;City Portal Template",
    ["FStringCoreScriptBacktraceErrorUploadToken"] = "null",
    ["FStringDebugGraphicsPreferredGPUName"] = "Intel(R) HD Graphics 730",
    ["FStringDebugLuaLogLevel"] = "trace",
    ["FStringDebugLuaLogPattern"] = "ExpChat/mountClientApp",
    ["FStringDisableAECIxpLayer"] = "True",
    ["FStringGamesUrlPath"] = "/games/",
    ["FStringGetPlayerImageDefaultTimeout"] = "1",
    ["FStringGraphicsDisableUnalignedDxtGPUNameBlacklist"] = "null",
    ["FStringIXPGraphicsOptimizationModePerformanceScale"] = "100",
    ["FStringInExperienceNotificationsLayer"] = "",
    ["FStringInGameMenuChromeForcedUserIds"] = "2464072391",
    ["FStringNewChatTabExperimentLayerValue"] = "2024MUSIC",
    ["FStringPartTexturePackTable2022"] = "",
    ["FStringPerformanceSendMeasurementAPISubdomain"] = "opt-out",
    ["FStringSponsoredItemsIXPLayer"] = "Ads.AdBlock",
    ["FStringStudioPackagesDynamicIgnoreList"] = "ParticleEmitter.FlipbookLayout",
    ["FStringTerrainMaterialTable2022"] = "",
    ["FStringTerrainMaterialTablePre2022"] = "",
    ["FStringVoiceBetaBadgeLearnMoreLink"] = "null",
    ["SFFlagAirControllerBalancingResponsiveness"] = "2147483647",
    ["SFFlagAirControllerTurningResponsiveness"] = "2147483647",
    ["SFFlagGraphicsOptimizationModePerformanceScalePercent"] = "100",
    ["SFFlagGroundControllerBalancingResponsiveness"] = "2147483647",
    ["SFFlagOpenXrASW"] = "True",
    ["SFFlagPerformanceControlEventBasedTelemetryDefaultSamplingRatePoints"] = "False",
    ["SFFlagPerformanceControlEventBasedTelemetryEffectPredictionEventRateEventIngest"] = "False",
    ["SFFlagPerformanceControlEventBasedTelemetryRateLimiterDefaultRegen"] = "False",
    ["SFFlagPerformanceControlEventBasedTelemetryTunableChangeEventRateEventIngest"] = "False",
    ["SFFlagPerformanceControlEventBasedTelemetryTunableChangeEventRatePoints"] = "False",
    ["SFFlagPerformanceControlTextureQualityBestUtility"] = "False",
    ["SFFlagPerformanceControlTextureQualityExponentTenThousandths"] = "0",
    ["SFFlagPerformanceTelemetryGlobalThrottleHundredthsPercent"] = "False",
    ["SFFlagPerformanceTelemetryReportIntervalSeconds"] = "False",
    ["SFFlagPerformanceTelemetrySketchK"] = "False",
    ["SFFlagRobloxGuiBlurIntensity"] = "0",
    ["SFFlagRobloxTelemetryAdTeleportPromptInteractionThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryAvatarMetricsTrackSingularAssetRequestThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryClientDisconnectEventsThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryCreationDBInstanceGUIDInvalidEvent"] = "False",
    ["SFFlagRobloxTelemetryMarketplaceDeprecatedSubscriptionFuncUseThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryPointV2ProdTrafficPercent"] = "False",
    ["SFFlagRobloxTelemetryRccDisconnectEventsThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryRccDisconnectPointsThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryRealtimeConnectionEventsThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryRealtimeEventsThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetrySharedStringReplicationPointsThrottleHundredthsPercent"] = "False",
    ["SFFlagRobloxTelemetryStatV2POCRandomOffset"] = "False",
    ["SFFlagRobloxTelemetryStatV2POCRandomRange"] = "False",
    ["SFFlagRobloxTelemetryThrottlingRenderFidelityOnTime"] = "False",
    ["SFFlagRobloxTelemetryV2PointAdatpterTrafficPercent"] = "False",
    ["SFFlagRolloutEnrollmentExpirationMinutes"] = "False",
    ["SFFlagSimAnimationConstraintResponsiveness"] = "2147483647",
    ["SFFlagSimSolverResponsiveness"] = "2147483647",
    ["SStringDefaultAvatarDeathType"] = "Ragdoll",
}


-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              CATEGORY CLASSIFICATION                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local CategoryMap = {
    Graphics = {},
    Network = {},
    Physics = {},
    Input = {},
    Scheduler = {},
    Telemetry = {},
    Audio = {},
    UI = {},
    Other = {}
}

local function ClassifyFlag(flagName)
    local lower = flagName:lower()
    if lower:find("graphics") or lower:find("render") or lower:find("shadow") or lower:find("light")
       or lower:find("fog") or lower:find("dof") or lower:find("bloom") or lower:find("sky")
       or lower:find("terrain") or lower:find("mesh") or lower:find("texture") or lower:find("material")
       or lower:find("visual") or lower:find("color") or lower:find("ambient") or lower:find("voxel")
       or lower:find("csg") or lower:find("lod") or lower:find("msaa") or lower:find("shader")
       or lower:find("gpu") or lower:find("d3d") or lower:find("vulkan") or lower:find("metal")
       or lower:find("opengl") or lower:find("framebuffer") or lower:find("depth")
       or lower:find("reflection") or lower:find("sunray") or lower:find("vignette")
       or lower:find("cloud") or lower:find("water") or lower:find("grass")
       or lower:find("highlight") or lower:find("decal") or lower:find("particle")
       or lower:find("frustum") or lower:find("cull") or lower:find("occlusion")
       or lower:find("ssao") or lower:find("hdr") or lower:find("exposure") then
        return "Graphics"
    elseif lower:find("network") or lower:find("raknet") or lower:find("bandwidth")
           or lower:find("packet") or lower:find("replicator") or lower:find("replication")
           or lower:find("datagram") or lower:find("mtu") or lower:find("ping")
           or lower:find("latency") or lower:find("connection") or lower:find("stream")
           or lower:find("sender") or lower:find("recv") or lower:find("send")
           or lower:find("join") or lower:find("disconnect") or lower:find("signalr")
           or lower:find("webrtc") or lower:find("http") or lower:find("cluster")
           or lower:find("netem") or lower:find("route") or lower:find("socket")
           or lower:find("transport") or lower:find("quic") or lower:find("udp")
           or lower:find("tcp") or lower:find("compression") or lower:find("decompress") then
        return "Network"
    elseif lower:find("physics") or lower:find("solver") or lower:find("pgs")
           or lower:find("constraint") or lower:find("collision") or lower:find("ragdoll")
           or lower:find("humanoid") or lower:find("contact") or lower:find("friction")
           or lower:find("velocity") or lower:find("angular") or lower:find("damping")
           or lower:find("inertia") or lower:find("mass") or lower:find("gravity")
           or lower:find("force") or lower:find("impulse") or lower:find("sleep")
           or lower:find("wake") or lower:find("deactivation") or lower:find("cyclic")
           or lower:find("mechanism") or lower:find("spatialhash") or lower:find("island")
           or lower:find("worldstep") or lower:find("timestep") or lower:find("arbiter")
           or lower:find("simulation") or lower:find("bodymovers") then
        return "Physics"
    elseif lower:find("input") or lower:find("mouse") or lower:find("keyboard")
           or lower:find("touch") or lower:find("camera") or lower:find("zoom")
           or lower:find("sensitivity") or lower:find("shiftlock") or lower:find("controller")
           or lower:find("gamepad") or lower:find("haptic") or lower:find("cursor")
           or lower:find("click") or lower:find("scroll") or lower:find("drag") then
        return "Input"
    elseif lower:find("scheduler") or lower:find("thread") or lower:find("fps")
           or lower:find("frametime") or lower:find("task") or lower:find("job")
           or lower:find("worker") or lower:find("parallel") or lower:find("async")
           or lower:find("spin") or lower:find("sleep") or lower:find("gc")
           or lower:find("garbage") or lower:find("throttle") then
        return "Scheduler"
    elseif lower:find("telemetry") or lower:find("analytics") or lower:find("tracking")
           or lower:find("metric") or lower:find("report") or lower:find("influx")
           or lower:find("google") or lower:find("newrelic") or lower:find("sumo")
           or lower:find("backtrace") or lower:find("eventingest") or lower:find("statv2")
           or lower:find("counter") or lower:find("profiler") or lower:find("diagnostic")
           or lower:find("log") or lower:find("debug") then
        return "Telemetry"
    elseif lower:find("audio") or lower:find("sound") or lower:find("music")
           or lower:find("voice") or lower:find("fmod") or lower:find("speaker")
           or lower:find("listener") or lower:find("volume") or lower:find("panning")
           or lower:find("codec") or lower:find("microphone") then
        return "Audio"
    elseif lower:find("gui") or lower:find("ui") or lower:find("menu")
           or lower:find("chat") or lower:find("bubble") or lower:find("notification")
           or lower:find("toast") or lower:find("badge") or lower:find("chrome")
           or lower:find("viewport") or lower:find("screen") or lower:find("text")
           or lower:find("font") or lower:find("icon") or lower:find("button")
           or lower:find("dropdown") or lower:find("slider") or lower:find("toggle")
           or lower:find("scrollbar") or lower:find("list") or lower:find("grid") then
        return "UI"
    else
        return "Other"
    end
end

for flagName, flagValue in pairs(FlagDatabase) do
    local cat = ClassifyFlag(flagName)
    table.insert(CategoryMap[cat], flagName)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              INJECTION ENGINE v2.0                                           ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local function FormatFlagName(name)
    local prefixes = {"DFInt", "DFFlag", "FFlag", "FInt", "FString", "FLog", "SFInt", "SFFlag", "SFString", "SString"}
    for _, prefix in ipairs(prefixes) do
        if name:sub(1, #prefix) == prefix then
            return name:sub(#prefix + 1)
        end
    end
    return name
end

local function TrySetFlag(rawName, value)
    local stripped = FormatFlagName(rawName)

    local success, current = pcall(function() return getfflag(stripped) end)
    if success and current ~= nil then
        local setOk = pcall(function() setfflag(stripped, value) end)
        if setOk then return true, stripped end
    end

    success, current = pcall(function() return getfflag(rawName) end)
    if success and current ~= nil then
        local setOk = pcall(function() setfflag(rawName, value) end)
        if setOk then return true, rawName end
    end

    return false, nil
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              MAIN DASHBOARD UI                                               ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local dashboardVisible = true
local injectionRunning = false
local injectionResults = {
    applied = 0,
    failed = 0,
    byCategory = {},
    elapsed = 0,
    appliedFlags = {},
    failedFlags = {}
}

for cat, _ in pairs(CategoryMap) do
    injectionResults.byCategory[cat] = {applied = 0, failed = 0}
end

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainDashboard"
mainFrame.Size = UDim2.new(0, 520, 0, 380)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = THEME.BG_CARD
mainFrame.BorderSizePixel = 0
mainFrame.Parent = mainGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.BORDER
mainStroke.Thickness = 1
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Shadow
local mainShadow = Instance.new("ImageLabel")
mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
mainShadow.BackgroundTransparency = 1
mainShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
mainShadow.Size = UDim2.new(1, 30, 1, 30)
mainShadow.ZIndex = 0
mainShadow.Image = "rbxassetid://6014261993"
mainShadow.ImageColor3 = Color3.new(0, 0, 0)
mainShadow.ImageTransparency = 0.75
mainShadow.ScaleType = Enum.ScaleType.Slice
mainShadow.SliceCenter = Rect.new(49, 49, 450, 450)
mainShadow.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = THEME.BG_DARKER
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)

local titleBarBottom = Instance.new("Frame")
titleBarBottom.Size = UDim2.new(1, 0, 0, 16)
titleBarBottom.Position = UDim2.new(0, 0, 1, -16)
titleBarBottom.BackgroundColor3 = THEME.BG_DARKER
titleBarBottom.BorderSizePixel = 0
titleBarBottom.Parent = titleBar

-- Logo icon
local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(0, 32, 0, 32)
logoIcon.Position = UDim2.new(0, 14, 0, 8)
logoIcon.BackgroundTransparency = 1
logoIcon.Text = "⚡"
logoIcon.TextColor3 = THEME.PRIMARY
logoIcon.Font = Enum.Font.GothamBold
logoIcon.TextSize = 22
logoIcon.Parent = titleBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 250, 0, 24)
titleLabel.Position = UDim2.new(0, 50, 0, 12)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "CAFUXZ1 Overhaul v4.0"
titleLabel.TextColor3 = THEME.TEXT_MAIN
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 250, 0, 16)
subtitleLabel.Position = UDim2.new(0, 50, 0, 30)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "1,072 FFlags | Auto-Conflict Resolution"
subtitleLabel.TextColor3 = THEME.TEXT_DIM
subtitleLabel.Font = Enum.Font.GothamMedium
subtitleLabel.TextSize = 10
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = titleBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -72, 0, 10)
minBtn.AnchorPoint = Vector2.new(0, 0)
minBtn.BackgroundColor3 = THEME.BG_PANEL
minBtn.Text = "−"
minBtn.TextColor3 = THEME.TEXT_DIM
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.AutoButtonColor = false
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 10)
closeBtn.AnchorPoint = Vector2.new(0, 0)
closeBtn.BackgroundColor3 = THEME.BG_PANEL
closeBtn.Text = "×"
closeBtn.TextColor3 = THEME.TEXT_DIM
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -24, 1, -60)
contentFrame.Position = UDim2.new(0, 12, 0, 54)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Stats row
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, 0, 0, 70)
statsFrame.BackgroundTransparency = 1
statsFrame.Parent = contentFrame

local statCards = {
    {label = "Total Flags", value = "1,072", color = THEME.PRIMARY},
    {label = "Applied", value = "0", color = THEME.SUCCESS},
    {label = "Failed", value = "0", color = THEME.ERROR},
    {label = "Time", value = "0.00s", color = THEME.INFO},
}

local statValueLabels = {}
for i, stat in ipairs(statCards) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.235, -6, 1, 0)
    card.Position = UDim2.new((i-1) * 0.25, 3, 0, 0)
    card.BackgroundColor3 = THEME.BG_DARKER
    card.BorderSizePixel = 0
    card.Parent = statsFrame
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(1, 0, 0, 28)
    valLabel.Position = UDim2.new(0, 0, 0, 8)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = stat.value
    valLabel.TextColor3 = stat.color
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 20
    valLabel.Parent = card
    statValueLabels[stat.label] = valLabel

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 38)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = stat.label
    nameLabel.TextColor3 = THEME.TEXT_DIM
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 10
    nameLabel.Parent = card
end

-- Progress bar
local progressFrame = Instance.new("Frame")
progressFrame.Size = UDim2.new(1, 0, 0, 8)
progressFrame.Position = UDim2.new(0, 0, 0, 78)
progressFrame.BackgroundColor3 = THEME.PROGRESS_BG
progressFrame.BorderSizePixel = 0
progressFrame.Parent = contentFrame
Instance.new("UICorner", progressFrame).CornerRadius = UDim.new(0, 4)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = THEME.PRIMARY
progressFill.BorderSizePixel = 0
progressFill.Parent = progressFrame
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 4)

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 16)
progressText.Position = UDim2.new(0, 0, 0, 88)
progressText.BackgroundTransparency = 1
progressText.Text = "Ready to inject — Click Start"
progressText.TextColor3 = THEME.TEXT_DIM
progressText.Font = Enum.Font.GothamMedium
progressText.TextSize = 11
progressText.Parent = contentFrame

-- Category breakdown
local catFrame = Instance.new("Frame")
catFrame.Size = UDim2.new(1, 0, 0, 110)
catFrame.Position = UDim2.new(0, 0, 0, 108)
catFrame.BackgroundTransparency = 1
catFrame.Parent = contentFrame

local catOrder = {"Graphics", "Network", "Physics", "Input", "Scheduler", "Telemetry", "Audio", "UI", "Other"}
local catColors = {
    Graphics = Color3.fromRGB(0, 200, 255),
    Network = Color3.fromRGB(255, 150, 50),
    Physics = Color3.fromRGB(150, 80, 255),
    Input = Color3.fromRGB(255, 80, 150),
    Scheduler = Color3.fromRGB(80, 220, 120),
    Telemetry = Color3.fromRGB(180, 180, 180),
    Audio = Color3.fromRGB(255, 200, 80),
    UI = Color3.fromRGB(100, 150, 255),
    Other = Color3.fromRGB(160, 160, 170),
}

local catLabels = {}
for i, cat in ipairs(catOrder) do
    local row = math.floor((i-1) / 3)
    local col = (i-1) % 3
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.32, -4, 0, 32)
    card.Position = UDim2.new(col * 0.34, 2, row * 0.38, 0)
    card.BackgroundColor3 = THEME.BG_DARKER
    card.BorderSizePixel = 0
    card.Parent = catFrame
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 8, 0.5, -3)
    dot.BackgroundColor3 = catColors[cat]
    dot.BorderSizePixel = 0
    dot.Parent = card
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0, 70, 1, 0)
    name.Position = UDim2.new(0, 18, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = cat
    name.TextColor3 = THEME.TEXT_DIM
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 10
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = card

    local count = Instance.new("TextLabel")
    count.Size = UDim2.new(0, 40, 1, 0)
    count.Position = UDim2.new(1, -44, 0, 0)
    count.BackgroundTransparency = 1
    count.Text = "0/" .. #CategoryMap[cat]
    count.TextColor3 = catColors[cat]
    count.Font = Enum.Font.GothamBold
    count.TextSize = 10
    count.TextXAlignment = Enum.TextXAlignment.Right
    count.Parent = card
    catLabels[cat] = count
end

-- Action buttons
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, 0, 0, 38)
btnFrame.Position = UDim2.new(0, 0, 1, -42)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = contentFrame

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48, -4, 1, 0)
startBtn.Position = UDim2.new(0, 0, 0, 0)
startBtn.BackgroundColor3 = THEME.PRIMARY
startBtn.Text = "▶  Start Injection"
startBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 13
startBtn.AutoButtonColor = false
startBtn.Parent = btnFrame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 10)

local exportBtn = Instance.new("TextButton")
exportBtn.Size = UDim2.new(0.26, -4, 1, 0)
exportBtn.Position = UDim2.new(0.5, 2, 0, 0)
exportBtn.BackgroundColor3 = THEME.BG_DARKER
exportBtn.Text = "📋 Export"
exportBtn.TextColor3 = THEME.TEXT_MAIN
exportBtn.Font = Enum.Font.GothamBold
exportBtn.TextSize = 12
exportBtn.AutoButtonColor = false
exportBtn.Parent = btnFrame
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 10)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.22, -4, 1, 0)
copyBtn.Position = UDim2.new(0.78, 2, 0, 0)
copyBtn.BackgroundColor3 = THEME.BG_DARKER
copyBtn.Text = "📄 Copy"
copyBtn.TextColor3 = THEME.TEXT_MAIN
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 12
copyBtn.AutoButtonColor = false
copyBtn.Parent = btnFrame
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 10)

-- Button hover effects
for _, btn in ipairs({startBtn, exportBtn, copyBtn}) do
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              FLOATING RESTORE BUTTON                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 44, 0, 44)
floatBtn.Position = UDim2.new(1, -60, 0, 20)
floatBtn.AnchorPoint = Vector2.new(1, 0)
floatBtn.BackgroundColor3 = THEME.PRIMARY
floatBtn.Text = "⚡"
floatBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 22
floatBtn.AutoButtonColor = false
floatBtn.Visible = false
floatBtn.Parent = mainGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = THEME.BORDER
floatStroke.Thickness = 2
floatStroke.Parent = floatBtn

local floatShadow = Instance.new("ImageLabel")
floatShadow.AnchorPoint = Vector2.new(0.5, 0.5)
floatShadow.BackgroundTransparency = 1
floatShadow.Position = UDim2.new(0.5, 0, 0.5, 3)
floatShadow.Size = UDim2.new(1, 12, 1, 12)
floatShadow.ZIndex = 0
floatShadow.Image = "rbxassetid://6014261993"
floatShadow.ImageColor3 = Color3.new(0, 0, 0)
floatShadow.ImageTransparency = 0.7
floatShadow.ScaleType = Enum.ScaleType.Slice
floatShadow.SliceCenter = Rect.new(49, 49, 450, 450)
floatShadow.Parent = floatBtn

-- Make floating button draggable
local dragging = false
dragInput = nil
dragStart = nil
startPos = nil

floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = floatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

floatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize / Restore
local function MinimizeDashboard()
    dashboardVisible = false
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.delay(0.35, function()
        mainFrame.Visible = false
        floatBtn.Visible = true
        TweenService:Create(floatBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 44, 0, 44)
        }):Play()
    end)
end

local function RestoreDashboard()
    dashboardVisible = true
    floatBtn.Visible = false
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 380),
        Position = UDim2.new(0.5, -260, 0.5, -190)
    }):Play()
end

minBtn.MouseButton1Click:Connect(MinimizeDashboard)
floatBtn.MouseButton1Click:Connect(RestoreDashboard)
closeBtn.MouseButton1Click:Connect(function()
    ShowNotification("CAFUXZ1 Overhaul", "Dashboard closed. Use ⚡ button to restore.", "info", 4)
    MinimizeDashboard()
end)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              INJECTION LOGIC                                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local function UpdateStats()
    statValueLabels["Applied"].Text = tostring(injectionResults.applied)
    statValueLabels["Failed"].Text = tostring(injectionResults.failed)
    statValueLabels["Time"].Text = string.format("%.2fs", injectionResults.elapsed)

    local total = injectionResults.applied + injectionResults.failed
    local pct = total > 0 and (injectionResults.applied / total) or 0
    TweenService:Create(progressFill, TweenInfo.new(0.3), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()

    for cat, data in pairs(injectionResults.byCategory) do
        if catLabels[cat] then
            catLabels[cat].Text = data.applied .. "/" .. #CategoryMap[cat]
        end
    end
end

local function RunInjection()
    if injectionRunning then return end
    injectionRunning = true
    startBtn.Text = "⏳ Injecting..."
    startBtn.BackgroundColor3 = THEME.WARNING

    ShowNotification("CAFUXZ1 Overhaul", "Starting injection of 1,072 FFlags...", "info", 4)

    task.spawn(function()
        local startTime = os.clock()
        local totalFlags = 0
        for _, flags in pairs(CategoryMap) do
            totalFlags = totalFlags + #flags
        end

        local processed = 0

        for _, cat in ipairs(catOrder) do
            local flags = CategoryMap[cat]
            for _, flagName in ipairs(flags) do
                local flagValue = FlagDatabase[flagName]

                -- Smart retry with exponential backoff
                local success = false
                local usedName = nil
                for attempt = 1, 3 do
                    success, usedName = TrySetFlag(flagName, flagValue)
                    if success then break end
                    task.wait(0.02 * attempt)
                end

                if success then
                    injectionResults.applied = injectionResults.applied + 1
                    injectionResults.byCategory[cat].applied = injectionResults.byCategory[cat].applied + 1
                    table.insert(injectionResults.appliedFlags, usedName)
                else
                    injectionResults.failed = injectionResults.failed + 1
                    injectionResults.byCategory[cat].failed = injectionResults.byCategory[cat].failed + 1
                    table.insert(injectionResults.failedFlags, flagName)
                end

                processed = processed + 1
                if processed % 50 == 0 then
                    injectionResults.elapsed = os.clock() - startTime
                    progressText.Text = string.format("Injecting... %d/%d (%s)", processed, totalFlags, cat)
                    UpdateStats()
                    RunService.RenderStepped:Wait()
                end
            end
        end

        injectionResults.elapsed = os.clock() - startTime
        injectionRunning = false

        startBtn.Text = "✓  Done"
        startBtn.BackgroundColor3 = THEME.SUCCESS
        progressText.Text = string.format("Complete! %d applied, %d failed in %.2fs",
            injectionResults.applied, injectionResults.failed, injectionResults.elapsed)
        UpdateStats()

        ShowNotification(
            "Overhaul Complete!",
            string.format("%d/%d FFlags applied in %.2fs", injectionResults.applied, totalFlags, injectionResults.elapsed),
            "success",
            10
        )

        -- Console log
        print("╔══════════════════════════════════════════════════════════════════════════════╗")
        print("║           CAFUXZ1 FFLAG OVERHAUL v4.0 — ULTIMATE EDITION                     ║")
        print("║           1,072 FLAGS — Auto-Conflict Resolution Engine                      ║")
        print("╠══════════════════════════════════════════════════════════════════════════════╣")
        print("║  Total Applied : " .. string.format("%-5d", injectionResults.applied) .. "                                        ║")
        print("║  Total Failed  : " .. string.format("%-5d", injectionResults.failed) .. "                                        ║")
        print("║  Time Elapsed  : " .. string.format("%.2f", injectionResults.elapsed) .. "s                                      ║")
        print("╠══════════════════════════════════════════════════════════════════════════════╣")
        for _, cat in ipairs(catOrder) do
            local data = injectionResults.byCategory[cat]
            print("║  " .. string.format("%-12s", cat) .. " : " .. string.format("%-4d", data.applied) .. " applied, " .. string.format("%-4d", data.failed) .. " failed              ║")
        end
        print("╚══════════════════════════════════════════════════════════════════════════════╝")

        if #injectionResults.failedFlags > 0 then
            print("
[FAILED FLAGS] (first 50):")
            for i = 1, math.min(50, #injectionResults.failedFlags) do
                print("  ✕ " .. injectionResults.failedFlags[i])
            end
            if #injectionResults.failedFlags > 50 then
                print("  ... and " .. (#injectionResults.failedFlags - 50) .. " more")
            end
        end
    end)
end

startBtn.MouseButton1Click:Connect(RunInjection)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              EXPORT & COPY FUNCTIONS                                         ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
local function ExportToClipboard()
    if injectionResults.applied == 0 then
        ShowNotification("Export", "No flags injected yet. Run injection first.", "warning", 4)
        return
    end

    local exportText = "-- CAFUXZ1 FFlag Overhaul v4.0 — Applied Flags Export\n"
    exportText = exportText .. "-- Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    exportText = exportText .. "-- Total Applied: " .. injectionResults.applied .. "\n\n"
    exportText = exportText .. "local AppliedFlags = {\n"

    for _, flag in ipairs(injectionResults.appliedFlags) do
        exportText = exportText .. '    ["' .. flag .. '"],\n'
    end
    exportText = exportText .. "}\n"

    pcall(function()
        if setclipboard then
            setclipboard(exportText)
            ShowNotification("Export", "Applied flags copied to clipboard!", "success", 4)
        else
            ShowNotification("Export", "setclipboard not available.", "error", 4)
        end
    end)
end

local function CopyAllFlags()
    local allText = "-- CAFUXZ1 FFlag Overhaul v4.0 — Complete Flag Database\n"
    allText = allText .. "-- Total Flags: " .. tostring(#injectionResults.appliedFlags + #injectionResults.failedFlags) .. "\n\n"
    allText = allText .. "local FlagDatabase = {\n"

    for flagName, flagValue in pairs(FlagDatabase) do
        allText = allText .. '    ["' .. flagName .. '"] = "' .. tostring(flagValue) .. '",\n'
    end
    allText = allText .. "}\n"

    pcall(function()
        if setclipboard then
            setclipboard(allText)
            ShowNotification("Copy", "Complete flag database copied!", "success", 4)
        else
            ShowNotification("Copy", "setclipboard not available.", "error", 4)
        end
    end)
end

exportBtn.MouseButton1Click:Connect(ExportToClipboard)
copyBtn.MouseButton1Click:Connect(CopyAllFlags)

-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║              INITIALIZATION                                                  ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝
ShowNotification("CAFUXZ1 Overhaul v4.0", "1,072 FFlags loaded. Click Start to inject.", "info", 5)

if not setfflag or not getfflag then
    ShowNotification("Incompatible Executor", "setfflag/getfflag not supported. Use Bloxstrap/Fishstrap.", "error", 10)
    startBtn.Text = "✗  Not Supported"
    startBtn.BackgroundColor3 = THEME.ERROR
    startBtn.Active = false
end

-- Initial category count display
for cat, flags in pairs(CategoryMap) do
    if catLabels[cat] then
        catLabels[cat].Text = "0/" .. #flags
    end
end
