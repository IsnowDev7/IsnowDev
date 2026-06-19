--==================================================
-- HOLY
-- Game: https://www.roblox.com/games/97598239454123/Grow-a-Garden-2
--==================================================

--==================================================
-- [0] SERVICES
--==================================================

local Players =
    game:GetService("Players")

local TeleportService =
    game:GetService("TeleportService")

local HttpService =
    game:GetService("HttpService")

local ReplicatedStorage =
    game:GetService("ReplicatedStorage")

local CoreGui =
    game:GetService("CoreGui")

GAG2_USER_INPUT_SERVICE =
    game:GetService("UserInputService")

GAG2_PROXIMITY_PROMPT_SERVICE =
    game:GetService("ProximityPromptService")

local VirtualUser =
    nil

pcall(function()

    VirtualUser =
        game:GetService("VirtualUser")
end)

local VirtualInputManager =
    nil

pcall(function()

    VirtualInputManager =
        game:GetService("VirtualInputManager")
end)

--==================================================
-- [0.1] EXECUTOR COMPATIBILITY
-- Safe environment, HTTP and remote chunk loading.
--==================================================

GAG2_EXECUTOR_ENV =
    _G

do

    local environmentOk, environment =
        pcall(function()

            if type(getgenv) == "function" then

                local resolved =
                    getgenv()

                if type(resolved) == "table" then
                    return resolved
                end
            end

            if type(shared) == "table" then
                return shared
            end

            return _G
        end)

    if environmentOk == true
    and type(environment) == "table" then

        GAG2_EXECUTOR_ENV =
            environment
    end
end

local getgenv =
    type(getgenv) == "function"
    and getgenv
    or function()

        return GAG2_EXECUTOR_ENV
    end

function GAG2ExecutorGetRequestFunction()

    local environment =
        GAG2_EXECUTOR_ENV

    local requestFunction =
        nil

    if type(syn) == "table"
    and type(syn.request) == "function" then

        requestFunction =
            syn.request
    end

    if type(requestFunction) ~= "function"
    and type(http_request) == "function" then

        requestFunction =
            http_request
    end

    if type(requestFunction) ~= "function"
    and type(request) == "function" then

        requestFunction =
            request
    end

    if type(requestFunction) ~= "function"
    and type(fluxus) == "table"
    and type(fluxus.request) == "function" then

        requestFunction =
            fluxus.request
    end

    if type(requestFunction) ~= "function"
    and type(environment) == "table" then

        if type(environment.request) == "function" then

            requestFunction =
                environment.request

        elseif type(environment.http_request) == "function" then

            requestFunction =
                environment.http_request
        end
    end

    return requestFunction
end

function GAG2ExecutorValidateLuaSource(body)

    if type(body) ~= "string"
    or body == "" then

        return nil,
            "empty response"
    end

    if body:sub(1, 3) == "\239\187\191" then

        body =
            body:sub(4)
    end

    local firstByte, secondByte =
        string.byte(
            body,
            1,
            2
        )

    if firstByte == 27 then

        return nil,
            "response starts with a Lua bytecode signature"
    end

    if firstByte == 31
    and secondByte == 139 then

        return nil,
            "response is still gzip-compressed"
    end

    if body:find(
        "\0",
        1,
        true
    ) then

        return nil,
            "response contains binary null bytes"
    end

    local preview =
        body:sub(
            1,
            240
        ):lower()

    if preview:find(
        "<!doctype html",
        1,
        true
    )
    or preview:find(
        "<html",
        1,
        true
    )
    or preview:find(
        "rate limit exceeded",
        1,
        true
    ) then

        return nil,
            "response is HTML or a rate-limit page"
    end

    return body,
        nil
end

function GAG2ExecutorHttpGet(url)

    url =
        tostring(url or "")

    if url == "" then

        return nil,
            "empty URL"
    end

    local cleanUrl =
        url

    local failures =
        {}

    local function acceptBody(label, body)

        local validated, validationError =
            GAG2ExecutorValidateLuaSource(
                body
            )

        if validated then

            return validated
        end

        failures[#failures + 1] =
            tostring(label)
            .. ": "
            .. tostring(validationError)

        return nil
    end

    local httpGetOk, httpGetResult =
        pcall(function()

            return game:HttpGet(
                cleanUrl,
                true
            )
        end)

    if httpGetOk == true then

        local validated =
            acceptBody(
                "game:HttpGet clean URL",
                httpGetResult
            )

        if validated then

            return validated,
                nil
        end

    else

        failures[#failures + 1] =
            "game:HttpGet clean URL failed: "
            .. tostring(httpGetResult)
    end

    local secondHttpOk, secondHttpResult =
        pcall(function()

            return game:HttpGet(
                cleanUrl
            )
        end)

    if secondHttpOk == true then

        local validated =
            acceptBody(
                "game:HttpGet one argument",
                secondHttpResult
            )

        if validated then

            return validated,
                nil
        end

    else

        failures[#failures + 1] =
            "game:HttpGet one argument failed: "
            .. tostring(secondHttpResult)
    end

    local requestFunction =
        GAG2ExecutorGetRequestFunction()

    if type(requestFunction) == "function" then

        local requestOk, response =
            pcall(function()

                return requestFunction({
                    Url = cleanUrl,
                    Method = "GET",

                    Headers = {
                        ["Accept"] = "text/plain",
                        ["Accept-Encoding"] = "identity",
                        ["Cache-Control"] = "no-cache",
                    },
                })
            end)

        if requestOk == true then

            local responseBody =
                nil

            if type(response) == "string" then

                responseBody =
                    response

            elseif type(response) == "table" then

                responseBody =
                    response.Body
                    or response.body
                    or response.ResponseBody
                    or response.responseBody
            end

            local validated =
                acceptBody(
                    "request API",
                    responseBody
                )

            if validated then

                return validated,
                    nil
            end

        else

            failures[#failures + 1] =
                "request API failed: "
                .. tostring(response)
        end
    end

    local getAsyncOk, getAsyncResult =
        pcall(function()

            return game:GetService(
                "HttpService"
            ):GetAsync(
                cleanUrl,
                true
            )
        end)

    if getAsyncOk == true then

        local validated =
            acceptBody(
                "HttpService:GetAsync",
                getAsyncResult
            )

        if validated then

            return validated,
                nil
        end

    else

        failures[#failures + 1] =
            "HttpService:GetAsync failed: "
            .. tostring(getAsyncResult)
    end

    return nil,
        table.concat(
            failures,
            " | "
        )
end

function GAG2ExecutorGetCompiler()

    local environment =
        GAG2_EXECUTOR_ENV

    if type(loadstring) == "function" then
        return loadstring
    end

    if type(load) == "function" then
        return load
    end

    if type(environment) == "table" then

        if type(environment.loadstring) == "function" then
            return environment.loadstring
        end

        if type(environment.load) == "function" then
            return environment.load
        end
    end

    return nil
end

function GAG2ExecutorBuildTrace(errorValue)

    local errorText =
        tostring(errorValue or "unknown error")

    if type(debug) == "table"
    and type(debug.traceback) == "function" then

        local traceOk, trace =
            pcall(
                debug.traceback,
                errorText,
                2
            )

        if traceOk == true
        and type(trace) == "string"
        and trace ~= "" then

            return trace
        end
    end

    return errorText
end

function GAG2LoadRemoteModule(url, moduleName)

    moduleName =
        tostring(
            moduleName
            or "remote module"
        )

    local source, downloadError =
        GAG2ExecutorHttpGet(
            url
        )

    if type(source) ~= "string"
    or source == "" then

        error(
            "[HOLY] Failed to download "
            .. moduleName
            .. ":\n"
            .. tostring(downloadError),
            0
        )
    end

    if moduleName == "librarygag2.lua" then

        local hasLibraryStart =
            source:find(
                "local cloneref",
                1,
                true
            ) ~= nil

        local hasLibraryReturn =
            source:find(
                "return Library",
                1,
                true
            ) ~= nil

        if hasLibraryStart ~= true
        or hasLibraryReturn ~= true then

            error(
                "[HOLY] librarygag2.lua download is stale or invalid."
                .. "\nSource size: "
                .. tostring(#source)
                .. " bytes"
                .. "\nPreview: "
                .. source:sub(1, 120),
                0
            )
        end
    end

    local compiler =
        GAG2ExecutorGetCompiler()

    if type(compiler) ~= "function" then

        error(
            "[HOLY] Unsupported executor: "
            .. "loadstring/load is missing while loading "
            .. moduleName
            .. ".",
            0
        )
    end

    local compileOk, chunk, compileError =
        pcall(
            compiler,
            source
        )

    if compileOk ~= true then

        error(
            "[HOLY] "
            .. moduleName
            .. " compiler call failed:\n"
            .. tostring(chunk),
            0
        )
    end

    if type(chunk) ~= "function" then

        error(
            "[HOLY] "
            .. moduleName
            .. " did not compile:\n"
            .. tostring(
                compileError
                or chunk
                or "compiler returned nil"
            ),
            0
        )
    end

    local runOk, result =
        xpcall(
            chunk,
            GAG2ExecutorBuildTrace
        )

    if runOk ~= true then

        error(
            "[HOLY] "
            .. moduleName
            .. " runtime failed:\n"
            .. tostring(result),
            0
        )
    end

    return result
end

--==================================================
-- [1] CONSTANTS
--==================================================

local LOCAL_PLAYER =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local GROW_A_GARDEN_2_PLACE_ID =
    97598239454123

local GROW_A_GARDEN_2_KNOWN_PLACE_IDS = {
    [77085202503540] = true,
    [97598239454123] = true,
    [133438856880402] = true,
}

local function IsGAG2KnownPlace(placeId)

    return GROW_A_GARDEN_2_KNOWN_PLACE_IDS[
        tonumber(placeId)
    ] == true
end

local function GAG2BuildJoinCode(placeId, jobId)

    local resolvedPlaceId =
        tonumber(placeId)
        or tonumber(game.PlaceId)
        or GROW_A_GARDEN_2_PLACE_ID

    local resolvedJobId =
        tostring(
            jobId
            or game.JobId
            or ""
        )
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    return tostring(resolvedPlaceId)
        .. ":"
        .. tostring(resolvedJobId)
end

local function GAG2KnownPlaceIdsText()

    local ids =
        {}

    for placeId in pairs(GROW_A_GARDEN_2_KNOWN_PLACE_IDS) do

        table.insert(
            ids,
            tostring(placeId)
        )
    end

    table.sort(
        ids
    )

    return table.concat(
        ids,
        ", "
    )
end

local REPO_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local REMOTE_SOURCE_VERSION =
    "compat-20260616-2"

local LIBRARY_URL =
    REPO_URL
    .. "librarygag2.lua?v="
    .. REMOTE_SOURCE_VERSION

local THEME_MANAGER_URL =
    REPO_URL
    .. "addons/ThemeManager.lua?v="
    .. REMOTE_SOURCE_VERSION

local SAVE_MANAGER_URL =
    REPO_URL
    .. "addons/SaveManager.lua?v="
    .. REMOTE_SOURCE_VERSION

local UI_SETTINGS_FOLDER =
    "HolyGAG2"

local UI_SETTINGS_FILE =
    UI_SETTINGS_FOLDER
    .. "/UISettings.json"

GAG2_GROUPBOX_ORDER_FILE =
    UI_SETTINGS_FOLDER
    .. "/GroupboxOrder.json"

local HOLY_GAG2_DEVELOPER_USER_IDS = {
    [78428093] = true,
}

GAG2_RARE_PET_WEBHOOK_URL =
    "https://discord.com/api/webhooks/1515303541718253599/9YlEfcONg8Kkn4om9gZKL8HYYGYVeOeLKyaJJbQGd-grIqxme_2PH5QkmmKZZBI8ESjc"

GAG2_RARE_PET_WEBHOOK_ROLE_ID =
    "1515584233811345499"

GAG2_RARE_PET_WEBHOOK_TARGETS = {
    raccoon = true,
    goldendragonfly = true,
    unicorn = true,

}

GAG2_RARE_PET_WEBHOOK_IMAGES = {
    raccoon =
        "https://static.wikia.nocookie.net/growagarden27847/images/7/7c/Raccoon.png/revision/latest?cb=20260612232005",

    unicorn =
        "https://static.wikia.nocookie.net/growagarden27847/images/7/7e/Unicorn.png/revision/latest?cb=20260612212539",

    goldendragonfly =
        "https://static.wikia.nocookie.net/growagarden27847/images/e/ee/GoldenDragonfly.png/revision/latest?cb=20260612231815",

    monkey =
        "https://static.wikia.nocookie.net/growagarden27847/images/2/27/Monkey.png/revision/latest?cb=20260612231816",

    iceserpent =
        "https://static.wikia.nocookie.net/growagarden27847/images/5/51/IceSerpent.png/revision/latest?cb=20260612231814",
}

GAG2_RARE_PET_WEBHOOK_SENT =
    {}

--==================================================
-- HARD-CODED WEATHER EVENT RELAY
--==================================================

GAG2_WEATHER_WEBHOOK_ENABLED =
    true

GAG2_WEATHER_RELAY_URL =
    "https://script.google.com/macros/s/AKfycbzZIEPH7vNA6YN-y6GLZQi22leT5GYc6imXUA9zGp3zA3vWMhQQtV1SvawHdWynbuqETA/exec"

GAG2_WEATHER_RELAY_SECRET =
    "HOLY_WEATHER_2026_ben_9x72qP"

-- Compatibility name. Old functions can still read this.
GAG2_WEATHER_WEBHOOK_URL =
    GAG2_WEATHER_RELAY_URL

GAG2_WEATHER_WEBHOOK_USERNAME =
    "GAG 2 Stocks"

GAG2_WEATHER_WEBHOOK_AVATAR_URL =
    ""

-- Empty = every alt can report.
-- Google Apps Script lock + eventKey dedupe prevents spam.
GAG2_WEATHER_WEBHOOK_SENDER_USER_IDS =
    {}

-- Roles are handled inside Google Apps Script now.
GAG2_WEATHER_WEBHOOK_ROLE_IDS =
    {}

GAG2_WEATHER_WEBHOOK_EVENTS = {
    Rain = true,
    Lightning = true,
    Rainbow = true,
    Snowfall = true,
    Starfall = true,

    Moon = true,
    Goldmoon = true,
    ["Rainbow Moon"] = true,
    Bloodmoon = true,

    Day = false,
    Sunset = false,
}

GAG2_WEATHER_WEBHOOK_SENT =
    {}

GAG2_WEATHER_WEBHOOK_STATE = {
    Armed = false,
    LastKey = "",
    LastScanAt = 0,
    MinScanDelay = 1,
}
GAG2_SERVER_HOP_RETRYING =
    false

GAG2_SERVER_HOP_ATTEMPT =
    0

GAG2_EXACT_JOIN_TARGET_FILE =
    UI_SETTINGS_FOLDER
    .. "/ExactJoinTarget.json"

--==================================================
-- HARD-CODED WILD PET NETWORK
--==================================================

GAG2_WILD_PET_NETWORK_ENDPOINT =
    "https://script.google.com/macros/s/AKfycbzG5g4bUWmvmCeYH3btJLKYht8jmrE17er0xNFk5kSNZCIl1kvyAbohbJMgpvcbekmu8w/exec"

GAG2_WILD_PET_NETWORK_API_KEY =
    "HOLY_WILDPETS_2026_8f4c92d1e7a63b50"

if type(GAG2_WILD_PET_NETWORK_STATE) == "table"
and type(GAG2_WILD_PET_NETWORK_STATE.Destroy) == "function" then

    pcall(function()

        GAG2_WILD_PET_NETWORK_STATE.Destroy()
    end)
end

GAG2_WILD_PET_NETWORK_HUD_TOGGLE =
    nil

GAG2_WILD_PET_NETWORK_STATE = {
    Enabled = false,
    Running = false,
    Refreshing = false,

    RefreshSeconds = 8,
    MaxRenderedRows = 80,

    LoopToken = 0,
    CountdownRunning = false,
    CountdownToken = 0,
    TimerRows = {},

    Gui = nil,
    Frame = nil,
    SummaryLabel = nil,
    StatusLabel = nil,
    Scroll = nil,

    LastData = nil,
    LastRefreshAt = 0,
    LastServerCount = 0,
    LastPetCount = 0,
    LastStatus = "Disabled.",
}

pcall(function()

    local env =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if type(env) == "table" then

        env.GAG2_WILD_PET_NETWORK_STATE =
            GAG2_WILD_PET_NETWORK_STATE

        env.GAG2_WILD_PET_NETWORK_ENDPOINT =
            GAG2_WILD_PET_NETWORK_ENDPOINT

        env.GAG2_WILD_PET_NETWORK_API_KEY =
            GAG2_WILD_PET_NETWORK_API_KEY
    end

    if type(GAG2_EXECUTOR_ENV) == "table" then

        GAG2_EXECUTOR_ENV.GAG2_WILD_PET_NETWORK_STATE =
            GAG2_WILD_PET_NETWORK_STATE

        GAG2_EXECUTOR_ENV.GAG2_WILD_PET_NETWORK_ENDPOINT =
            GAG2_WILD_PET_NETWORK_ENDPOINT

        GAG2_EXECUTOR_ENV.GAG2_WILD_PET_NETWORK_API_KEY =
            GAG2_WILD_PET_NETWORK_API_KEY
    end
end)

GAG2_EXACT_JOIN_STATE = {
    Retrying = false,
    MaxAttempts = 3,
    Target = nil,
}

GAG2_SNIPER_TOGGLE_CONTROL =
    nil

GAG2_SNIPER_KEYBIND_CONTROL =
    nil

GAG2_SNIPER_STOPPING =
    false

GAG2_MANUAL_JOIN_STATE = {
    HudEnabled = false,
    TargetText = "",
    LastTargetText = "",
    StatusText = "Paste full placeId:JobId.",
    PreviewText = "Paste full placeId:JobId.",
    Refreshing = false,
}

GAG2_MANUAL_JOIN_INPUT_CONTROL =
    nil

GAG2_MANUAL_JOIN_HUD_TOGGLE =
    nil

GAG2_MANUAL_JOIN_HUD_GUI =
    nil

GAG2_MANUAL_JOIN_HUD_INPUT =
    nil

GAG2_MANUAL_JOIN_HUD_STATUS =
    nil

GAG2_PANIC_HUD_GUI =
    nil

GAG2_PANIC_HUD_STATUS =
    nil

GAG2_PANIC_HUD_TOGGLE_CONTROL =
    nil

GAG2_PANIC_HUD_ENABLED =
    true

GAG2_PANIC_HUD_CREATED =
    false

GAG2_MOON_PREDICTOR_LABEL =
    nil

GAG2_MOON_PREDICTOR_STATE = {
    CycleInfo = nil,
    PickWeather = nil,
    LastBuildAt = 0,
    LastText = "Loading moon data...",
}

GAG2_FARM_DETAILS_LABEL =
    nil

GAG2_FARM_DETAILS_PANEL =
    nil

GAG2_FARM_DETAILS_STATE = {
    LastRefreshAt = 0,
    RefreshSeconds = 3,
    LastText = "Loading farm data...",

    BaseWeights = {},

    ShowAll = false,
    TopRows = 6,
    AllVisibleRows = 15,

    PanelHeight = 246,
    TopPanelHeight = 246,
    AllPanelHeight = 455,

    SummaryHeight = 74,
    HeaderHeight = 22,
    RowHeight = 24,

    SearchText = "",

    PanelRoot = nil,
    SummaryLabel = nil,
    HeaderLabel = nil,
    ToggleButton = nil,
    SearchBox = nil,
    ColumnHeader = nil,
    RowScroll = nil,
    RowLayout = nil,
}

GAG2_LOADING_GUI_CLEANER_RUNNING =
    false

GAG2_AUTO_PLAY_STATE = {
    Started = false,
    Finished = false,
    LastClick = 0,
    Attempts = 0,
}

GAG2_AUTO_TP_MIDDLE_FARM_STATE = {
    Running = false,
    CharacterConnection = nil,

    LastTeleportAt = 0,
    LastResult = "not started",
    LastTarget = nil,
    LastTargetReason = "not resolved",

    LoadingStartedAt = 0,
    LoadingFinished = false,
    LoadingFinishedAt = 0,
    LoadingFinishReason = "waiting",
    SawLoadingSignal = false,
    FinishCandidateAt = 0,

    SkipStarted = false,
    SkipSucceeded = false,
    SkipAttempts = 0,
    SkipSuccessReason = "",

    HoldingSkip = false,
    HoldStartAt = 0,
    HoldMaxSeconds = 3.75,
    HoldX = 0,
    HoldY = 0,

    MovementMode = "Teleport",
    Moving = false,
    MovedOnce = false,
    MiddleReady = false,
    LastMiddleReadyAt = 0,
    LastSniperMiddleStartAt = 0,
    SniperWaitActive = false,

    EarlyKeepDistance = 8,
    PostLoadRepairDistance = 12,

    LoadingStableSeconds = 0.75,
    LateAttachStableSeconds = 2.50,

    TargetRefreshInterval = 2.00,
    TargetResolveRetryInterval = 0.35,
    WorkerInterval = 0.20,

    MaxSkipAttempts = 2,
    SkipRetryDelay = 0.25,

    PostLoadWatchSeconds = 10,
    PostLoadRepairRetryInterval = 0.50,
    PostLoadFinalSettleSeconds = 1.25,
    PostLoadMaxRepairTries = 12,

    MaxRunSeconds = 120,
}

--==================================================
-- [2] BASIC HELPERS
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function CleanText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function IsHolyGAG2Developer()

    return LOCAL_PLAYER
        and HOLY_GAG2_DEVELOPER_USER_IDS[LOCAL_PLAYER.UserId] == true
end

local function IsGAG2World()

    return IsGAG2KnownPlace(
        game.PlaceId
    )
end

local function BoolText(value)

    return value == true
        and "YES"
        or "NO"
end

local function PathOf(instance)

    if typeof(instance) ~= "Instance" then
        return tostring(instance)
    end

    local ok, result =
        pcall(function()
            return instance:GetFullName()
        end)

    if ok == true then
        return tostring(result)
    end

    return tostring(instance)
end

local function CopyText(text)

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            clipboard(
                tostring(text or "")
            )
        end)

    return ok == true
end

--==================================================
-- [2.1] MOBILE / CLOUDPHONE PROMPT COMPATIBILITY
-- Avoids the broken custom ProximityPromptController UI
-- on Android, iOS, touch clients, and cloudphones.
-- Prompt interaction behavior is preserved.
--==================================================

pcall(function()

    if type(GAG2_MOBILE_PROMPT_COMPAT_STATE) ~= "table" then
        return
    end

    if GAG2_MOBILE_PROMPT_COMPAT_STATE.DescendantAddedConnection then

        GAG2_MOBILE_PROMPT_COMPAT_STATE.DescendantAddedConnection:Disconnect()
    end

    if GAG2_MOBILE_PROMPT_COMPAT_STATE.PromptShownConnection then

        GAG2_MOBILE_PROMPT_COMPAT_STATE.PromptShownConnection:Disconnect()
    end
end)

GAG2_MOBILE_PROMPT_COMPAT_STATE = {
    Enabled = false,
    Started = false,

    DescendantAddedConnection = nil,
    PromptShownConnection = nil,

    AppliedCount = 0,
}

function GAG2IsMobilePromptEnvironment()

    local touchEnabled =
        false

    local platform =
        nil

    pcall(function()

        touchEnabled =
            GAG2_USER_INPUT_SERVICE.TouchEnabled == true
    end)

    pcall(function()

        platform =
            GAG2_USER_INPUT_SERVICE:GetPlatform()
    end)

    return touchEnabled == true
        or platform == Enum.Platform.Android
        or platform == Enum.Platform.IOS
end

function GAG2ApplyMobilePromptCompatibility(prompt)

    local state =
        GAG2_MOBILE_PROMPT_COMPAT_STATE

    if state.Enabled ~= true then
        return false
    end

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then

        return false
    end

    if prompt.Parent == nil then
        return false
    end

    local changed =
        false

    local ok =
        pcall(function()

            if prompt.Style ~= Enum.ProximityPromptStyle.Default then

                prompt.Style =
                    Enum.ProximityPromptStyle.Default

                changed =
                    true
            end
        end)

    if ok ~= true then
        return false
    end

    if changed == true then

        state.AppliedCount =
            tonumber(state.AppliedCount)
            or 0

        state.AppliedCount = state.AppliedCount + 1
    end

    return true
end

function GAG2ApplyMobilePromptCompatibilityToRoot(root, yieldEvery)

    if typeof(root) ~= "Instance" then
        return 0
    end

    local applied =
        0

    if root:IsA("ProximityPrompt") then

        if GAG2ApplyMobilePromptCompatibility(root) == true then

            applied = applied + 1
        end
    end

    local descendants =
        root:GetDescendants()

    for index, descendant in ipairs(descendants) do

        if descendant:IsA("ProximityPrompt") then

            if GAG2ApplyMobilePromptCompatibility(descendant) == true then

                applied = applied + 1
            end
        end

        local yieldAmount =
            tonumber(yieldEvery)
            or 0

        if yieldAmount > 0
        and index % yieldAmount == 0 then

            task.wait()
        end
    end

    return applied
end

function GAG2StartMobilePromptCompatibility()

    local state =
        GAG2_MOBILE_PROMPT_COMPAT_STATE

    state.Enabled =
        GAG2IsMobilePromptEnvironment()

    if state.Enabled ~= true then
        return false
    end

    if state.Started == true then
        return true
    end

    state.Started =
        true

    state.DescendantAddedConnection =
        workspace.DescendantAdded:Connect(function(descendant)

            if descendant:IsA("ProximityPrompt") ~= true then
                return
            end

            GAG2ApplyMobilePromptCompatibility(
                descendant
            )

            task.defer(function()

                if descendant.Parent then

                    GAG2ApplyMobilePromptCompatibility(
                        descendant
                    )
                end
            end)

            task.delay(0.15, function()

                if descendant.Parent then

                    GAG2ApplyMobilePromptCompatibility(
                        descendant
                    )
                end
            end)
        end)

    if GAG2_PROXIMITY_PROMPT_SERVICE then

        state.PromptShownConnection =
            GAG2_PROXIMITY_PROMPT_SERVICE.PromptShown:Connect(function(prompt)

                GAG2ApplyMobilePromptCompatibility(
                    prompt
                )
            end)
    end

    -- Avoid startup freezes on cloud/mobile.
    -- PromptShown + DescendantAdded handle prompts without scanning giant roots.
    -- Do not full-scan workspace.Map or workspace.NPCS on load.

    task.defer(function()

        task.wait(
            2
        )

        GAG2ApplyMobilePromptCompatibilityToRoot(
            workspace:FindFirstChild("DroppedItems"),
            250
        )
    end)

    return true
end

GAG2StartMobilePromptCompatibility()

local UIState = {
    ShowUIOnLoad = true,
    DPIScale = 100,
}

local ConfigState = {
    AutosaveName = "autosave",
    Dirty = false,
    Loading = true,
}

local function CanUseUISettingsFile()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function EnsureUISettingsFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder(UI_SETTINGS_FOLDER) then
                makefolder(UI_SETTINGS_FOLDER)
            end
        end)

    return ok == true
end

local function SaveUISettingsNow()

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local payload = {
        ShowUIOnLoad =
            UIState.ShowUIOnLoad == true,

        AutoCloseUI =
            UIState.ShowUIOnLoad ~= true,

        DPIScale =
            tonumber(UIState.DPIScale)
            or 100,
    }

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                UI_SETTINGS_FILE,
                encoded
            )
        end)

    return writeOk == true
end

local function LoadUISettingsEarly()

    if CanUseUISettingsFile() ~= true then
        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(UI_SETTINGS_FILE)
        end)

    if existsOk ~= true
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(UI_SETTINGS_FILE)
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then
        return false
    end

    if type(payload.AutoCloseUI) == "boolean" then

        UIState.ShowUIOnLoad =
            payload.AutoCloseUI ~= true

    elseif type(payload.ShowUIOnLoad) == "boolean" then

        UIState.ShowUIOnLoad =
            payload.ShowUIOnLoad
    end

    local scale =
        tonumber(payload.DPIScale)

    if scale then

        UIState.DPIScale =
            math.clamp(
                math.floor(scale + 0.5),
                30,
                110
            )
    end

    return true
end

local function MarkConfigDirty()

    if ConfigState.Loading == true then
        return
    end

    ConfigState.Dirty =
        true
end

local function FormatDPIScale(value)

    local scale =
        math.clamp(
            math.floor(
                tonumber(value)
                or 100
            ),
            30,
            110
        )

    return tostring(scale) .. "%"
end

local function ParseDPIScale(value)

    local rawValue =
        tostring(value or "100%")

    local cleanedValue =
        rawValue:gsub("%%", "")

    local scale =
        tonumber(cleanedValue)

    if not scale then
        scale =
            100
    end

    return math.clamp(
        math.floor(scale + 0.5),
        30,
        110
    )
end

LoadUISettingsEarly()

--==================================================
-- [3] LIBRARY LOAD
--==================================================

local Library =
    GAG2LoadRemoteModule(
        LIBRARY_URL,
        "librarygag2.lua"
    )

if type(Library) ~= "table" then

    error(
        "[HOLY] librarygag2.lua returned "
        .. typeof(Library)
        .. " instead of a table.",
        0
    )
end

local ThemeManager =
    GAG2LoadRemoteModule(
        THEME_MANAGER_URL,
        "ThemeManager.lua"
    )

if type(ThemeManager) ~= "table" then

    error(
        "[HOLY] ThemeManager.lua returned "
        .. typeof(ThemeManager)
        .. " instead of a table.",
        0
    )
end

local SaveManager =
    GAG2LoadRemoteModule(
        SAVE_MANAGER_URL,
        "SaveManager.lua"
    )

if type(SaveManager) ~= "table" then

    error(
        "[HOLY] SaveManager.lua returned "
        .. typeof(SaveManager)
        .. " instead of a table.",
        0
    )
end

local Options =
    Library.Options

local Toggles =
    Library.Toggles

if type(Options) ~= "table"
or type(Toggles) ~= "table" then

    error(
        "[HOLY] UI library loaded without valid Options/Toggles tables.",
        0
    )
end

Library.ForceCheckbox =
    false

Library.ShowToggleFrameInKeybinds =
    true

GAG2_EXECUTOR_ENV.HOLY_GAG2_LIBRARY =
    Library

function GAG2LoadGroupboxOrders()

    if CanUseUISettingsFile() ~= true then
        return {}
    end

    local exists =
        false

    local existsOk =
        pcall(function()

            exists =
                isfile(
                    GAG2_GROUPBOX_ORDER_FILE
                )
        end)

    if existsOk ~= true
    or exists ~= true then
        return {}
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_GROUPBOX_ORDER_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return {}
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk == true
    and type(payload) == "table" then
        return payload
    end

    return {}
end

function GAG2SaveGroupboxOrders(orderTable)

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local encodeOk, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                type(orderTable) == "table"
                and orderTable
                or {}
            )
        end)

    if encodeOk ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_GROUPBOX_ORDER_FILE,
                encoded
            )
        end)

    return writeOk == true
end

Library.GroupboxDragEnabled =
    true

Library.GroupboxOrders =
    GAG2LoadGroupboxOrders()

Library.GroupboxOrderChanged =
    function(orderTable)

        GAG2SaveGroupboxOrders(
            orderTable
        )
    end

local function Notify(title, description, duration)

    if Library
    and type(Library.Notify) == "function" then

        Library:Notify({
            Title = tostring(title or "HOLY"),
            Description = tostring(description or ""),
            Time = tonumber(duration) or 4,
        })

        return
    end

    print(
        "[HOLY]",
        tostring(title),
        tostring(description)
    )
end

--==================================================
-- [4] LOGIC HELPERS
--==================================================

local function SetStatus(text)

    if Options.HolyGAG2Status then

        Options.HolyGAG2Status:SetText(
            '<font color="rgb(196,181,253)"><b>Status:</b></font> '
            .. tostring(text or "Ready")
        )
    end
end

local function BuildServerInfoText()

    local lines = {
        "Players: "
            .. tostring(#Players:GetPlayers())
            .. " | Code ready",
    }

    if type(GAG2VersionHopBuildHomeText) == "function" then

        table.insert(
            lines,
            GAG2VersionHopBuildHomeText()
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function RefreshServerInfo()

    if Options.HolyGAG2ServerInfo then

        Options.HolyGAG2ServerInfo:SetText(
            BuildServerInfoText()
        )
    end
end

--==================================================
-- [4.1] EXACT SERVER JOIN GUARD
--==================================================

function GAG2ClearExactJoinTarget(reason)

    GAG2_EXACT_JOIN_STATE.Target =
        nil

    if type(isfile) == "function"
    and type(delfile) == "function" then

        pcall(function()

            if isfile(GAG2_EXACT_JOIN_TARGET_FILE) then

                delfile(
                    GAG2_EXACT_JOIN_TARGET_FILE
                )
            end
        end)
    end

    if reason then

        print(
            "[HOLY EXACT JOIN]",
            "cleared target:",
            tostring(reason)
        )
    end
end

function GAG2SaveExactJoinTarget(placeId, jobId, attempts, reason)

    local payload = {
        PlaceId =
            tonumber(placeId),

        JobId =
            CleanText(jobId),

        Attempts =
            math.max(
                0,
                math.floor(
                    tonumber(attempts)
                    or 0
                )
            ),

        CreatedAt =
            os.time(),

        Reason =
            tostring(reason or "manual"),
    }

    if not payload.PlaceId
    or payload.PlaceId <= 0
    or payload.JobId == "" then

        return false
    end

    GAG2_EXACT_JOIN_STATE.Target =
        payload

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_EXACT_JOIN_TARGET_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function GAG2ReadExactJoinTarget()

    if type(GAG2_EXACT_JOIN_STATE) == "table"
    and type(GAG2_EXACT_JOIN_STATE.Target) == "table" then

        return GAG2_EXACT_JOIN_STATE.Target
    end

    if CanUseUISettingsFile() ~= true then
        return nil
    end

    local exists =
        false

    local existsOk =
        pcall(function()

            exists =
                isfile(
                    GAG2_EXACT_JOIN_TARGET_FILE
                )
        end)

    if existsOk ~= true
    or exists ~= true then
        return nil
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_EXACT_JOIN_TARGET_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return nil
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then

        GAG2ClearExactJoinTarget(
            "bad json"
        )

        return nil
    end

    payload.PlaceId =
        tonumber(payload.PlaceId)

    payload.JobId =
        CleanText(payload.JobId)

    payload.Attempts =
        math.max(
            0,
            math.floor(
                tonumber(payload.Attempts)
                or 0
            )
        )

    payload.CreatedAt =
        tonumber(payload.CreatedAt)
        or os.time()

    if not payload.PlaceId
    or payload.PlaceId <= 0
    or payload.JobId == "" then

        GAG2ClearExactJoinTarget(
            "bad target"
        )

        return nil
    end

    if os.time() - payload.CreatedAt > 180 then

        GAG2ClearExactJoinTarget(
            "expired"
        )

        return nil
    end

    GAG2_EXACT_JOIN_STATE.Target =
        payload

    return payload
end

function GAG2ExactJoinMatchesCurrent(target)

    if type(target) ~= "table" then
        return false
    end

    return tonumber(target.PlaceId) == tonumber(game.PlaceId)
        and tostring(target.JobId) == tostring(game.JobId)
end

function GAG2QueueExactJoin(placeId, jobId, reason)

    placeId =
        tonumber(placeId)

    jobId =
        CleanText(jobId)

    if not placeId
    or placeId <= 0
    or jobId == "" then
        return false, "bad exact join target"
    end

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    SetStatus(
        "Exact joining: "
        .. tostring(placeId)
        .. ":"
        .. tostring(jobId)
    )

    print(
        "[HOLY EXACT JOIN]",
        "TeleportToPlaceInstance",
        "| place:",
        tostring(placeId),
        "| job:",
        tostring(jobId),
        "| reason:",
        tostring(reason or "manual")
    )

    local ok, err =
        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                placeId,
                jobId,
                LOCAL_PLAYER
            )
        end)

    if ok ~= true then

        SetStatus(
            "Exact join failed: "
            .. tostring(err)
        )

        warn(
            "[HOLY EXACT JOIN]",
            "call failed:",
            tostring(err)
        )

        return false,
            tostring(err)
    end

    return true,
        "queued"
end

function GAG2WildPetNetworkGetScoutUserId(rowData)

    if type(rowData) ~= "table" then
        return 0
    end

    local candidates = {
        rowData.scoutUserId,
        rowData.ScoutUserId,
        rowData.scoutId,
        rowData.ScoutId,
        rowData.reporterUserId,
        rowData.ReporterUserId,
        rowData.playerUserId,
        rowData.PlayerUserId,
        rowData.userId,
        rowData.UserId,
    }

    if type(rowData.scout) == "table" then

        table.insert(
            candidates,
            rowData.scout.userId
            or rowData.scout.UserId
            or rowData.scout.id
            or rowData.scout.Id
        )
    end

    if type(rowData.reporter) == "table" then

        table.insert(
            candidates,
            rowData.reporter.userId
            or rowData.reporter.UserId
            or rowData.reporter.id
            or rowData.reporter.Id
        )
    end

    for _, value in ipairs(candidates) do

        local userId =
            tonumber(value)

        if userId
        and userId > 0 then

            return math.floor(
                userId
            )
        end
    end

    return 0
end

function GAG2WildPetNetworkGetScoutName(rowData)

    if type(rowData) ~= "table" then
        return ""
    end

    local candidates = {
        rowData.scoutName,
        rowData.ScoutName,
        rowData.reporterName,
        rowData.ReporterName,
        rowData.playerName,
        rowData.PlayerName,
        rowData.username,
        rowData.Username,
        rowData.name,
        rowData.Name,
    }

    if type(rowData.scout) == "table" then

        table.insert(
            candidates,
            rowData.scout.name
            or rowData.scout.Name
            or rowData.scout.username
            or rowData.scout.Username
        )
    end

    if type(rowData.reporter) == "table" then

        table.insert(
            candidates,
            rowData.reporter.name
            or rowData.reporter.Name
            or rowData.reporter.username
            or rowData.reporter.Username
        )
    end

    for _, value in ipairs(candidates) do

        local text =
            CleanText(value)

        if text ~= "" then
            return text
        end
    end

    return ""
end

function GAG2QueuePlayerIdJoin(
    scoutUserId,
    fallbackPlaceId,
    fallbackJobId,
    reason
)

    scoutUserId =
        math.floor(
            tonumber(scoutUserId)
            or 0
        )

    fallbackPlaceId =
        tonumber(fallbackPlaceId)

    fallbackJobId =
        CleanText(fallbackJobId)

    reason =
        tostring(reason or "player id join")

    if scoutUserId <= 0 then

        warn(
            "[HOLY PLAYER JOIN]",
            "missing scoutUserId, using fallback exact JobId"
        )

        if fallbackPlaceId
        and fallbackPlaceId > 0
        and fallbackJobId ~= "" then

            GAG2SaveExactJoinTarget(
                fallbackPlaceId,
                fallbackJobId,
                0,
                reason .. " fallback no scoutUserId"
            )

            return GAG2QueueExactJoin(
                fallbackPlaceId,
                fallbackJobId,
                reason .. " fallback no scoutUserId"
            )
        end

        return false,
            "missing scoutUserId and fallback JobId"
    end

    if LOCAL_PLAYER
    and scoutUserId == LOCAL_PLAYER.UserId then

        if fallbackPlaceId == tonumber(game.PlaceId)
        and fallbackJobId == tostring(game.JobId) then

            SetStatus(
                "Scout is you. Already in this server."
            )

            if type(GAG2WildPetNetworkSetStatus) == "function" then

                GAG2WildPetNetworkSetStatus(
                    "Already in scout server."
                )
            end

            return false,
                "already in scout server"
        end
    end

    SetStatus(
        "Resolving scout user "
        .. tostring(scoutUserId)
        .. "..."
    )

    if type(GAG2WildPetNetworkSetStatus) == "function" then

        GAG2WildPetNetworkSetStatus(
            "Resolving scout "
            .. tostring(scoutUserId)
            .. "..."
        )
    end

    print(
        "[HOLY PLAYER JOIN]",
        "GetPlayerPlaceInstanceAsync",
        "| userId:",
        tostring(scoutUserId),
        "| fallback:",
        tostring(fallbackPlaceId)
        .. ":"
        .. tostring(fallbackJobId),
        "| reason:",
        reason
    )

    local lookupOk,
        currentInstance,
        lookupError,
        resolvedPlaceId,
        resolvedJobId =
        pcall(function()

            return TeleportService:GetPlayerPlaceInstanceAsync(
                scoutUserId
            )
        end)

    if lookupOk ~= true then

        warn(
            "[HOLY PLAYER JOIN]",
            "user lookup failed:",
            tostring(currentInstance)
        )

        if type(GAG2WildPetNetworkSetStatus) == "function" then

            GAG2WildPetNetworkSetStatus(
                "Player lookup failed. Fallback exact join..."
            )
        end

        if fallbackPlaceId
        and fallbackPlaceId > 0
        and fallbackJobId ~= "" then

            GAG2SaveExactJoinTarget(
                fallbackPlaceId,
                fallbackJobId,
                0,
                reason .. " fallback lookup failed"
            )

            return GAG2QueueExactJoin(
                fallbackPlaceId,
                fallbackJobId,
                reason .. " fallback lookup failed"
            )
        end

        return false,
            tostring(currentInstance)
    end

    resolvedPlaceId =
        tonumber(resolvedPlaceId)

    resolvedJobId =
        CleanText(resolvedJobId)

    print(
        "[HOLY PLAYER JOIN]",
        "lookup returned",
        "| currentInstance:",
        tostring(currentInstance),
        "| lookupError:",
        tostring(lookupError),
        "| placeId:",
        tostring(resolvedPlaceId),
        "| jobId:",
        tostring(resolvedJobId)
    )

    if currentInstance == true then

        SetStatus(
            "Scout is already in this server."
        )

        if type(GAG2WildPetNetworkSetStatus) == "function" then

            GAG2WildPetNetworkSetStatus(
                "Scout is already in this server."
            )
        end

        return false,
            "scout is current instance"
    end

    if not resolvedPlaceId
    or resolvedPlaceId <= 0
    or resolvedJobId == "" then

        warn(
            "[HOLY PLAYER JOIN]",
            "lookup returned no usable JobId:",
            tostring(lookupError)
        )

        if fallbackPlaceId
        and fallbackPlaceId > 0
        and fallbackJobId ~= "" then

            if type(GAG2WildPetNetworkSetStatus) == "function" then

                GAG2WildPetNetworkSetStatus(
                    "Player lookup empty. Fallback exact join..."
                )
            end

            GAG2SaveExactJoinTarget(
                fallbackPlaceId,
                fallbackJobId,
                0,
                reason .. " fallback lookup empty"
            )

            return GAG2QueueExactJoin(
                fallbackPlaceId,
                fallbackJobId,
                reason .. " fallback lookup empty"
            )
        end

        return false,
            tostring(lookupError or "lookup returned no JobId")
    end

    if resolvedPlaceId == tonumber(game.PlaceId)
    and resolvedJobId == tostring(game.JobId) then

        SetStatus(
            "Already in resolved scout server."
        )

        if type(GAG2WildPetNetworkSetStatus) == "function" then

            GAG2WildPetNetworkSetStatus(
                "Already in resolved scout server."
            )
        end

        return false,
            "already in resolved scout server"
    end

    GAG2ClearExactJoinTarget(
        "new player-id resolved join"
    )

    GAG2_EXACT_JOIN_STATE.Retrying =
        false

    GAG2SaveExactJoinTarget(
        resolvedPlaceId,
        resolvedJobId,
        0,
        reason .. " resolved from scoutUserId"
    )

    if type(GAG2WildPetNetworkSetStatus) == "function" then

        GAG2WildPetNetworkSetStatus(
            "Joining scout server "
            .. tostring(resolvedJobId:sub(1, 8))
            .. "..."
        )
    end

    SetStatus(
        "Joining resolved scout server..."
    )

    return GAG2QueueExactJoin(
        resolvedPlaceId,
        resolvedJobId,
        reason .. " resolved from scoutUserId"
    )
end

function GAG2WildPetNetworkGetScoutUserId(rowData)

    if type(rowData) ~= "table" then
        return 0
    end

    local candidates =
        {}

    local function add(value)

        if value ~= nil then

            table.insert(
                candidates,
                value
            )
        end
    end

    add(rowData.scoutUserId)
    add(rowData.ScoutUserId)
    add(rowData.bestScoutUserId)
    add(rowData.BestScoutUserId)
    add(rowData.reporterUserId)
    add(rowData.ReporterUserId)
    add(rowData.playerUserId)
    add(rowData.PlayerUserId)
    add(rowData.userId)
    add(rowData.UserId)

    if type(rowData.scout) == "table" then

        add(rowData.scout.userId)
        add(rowData.scout.UserId)
        add(rowData.scout.id)
        add(rowData.scout.Id)
    end

    if type(rowData.reporter) == "table" then

        add(rowData.reporter.userId)
        add(rowData.reporter.UserId)
        add(rowData.reporter.id)
        add(rowData.reporter.Id)
    end

    if type(rowData.scouts) == "table" then

        for _, scout in ipairs(rowData.scouts) do

            if type(scout) == "table" then

                add(scout.userId)
                add(scout.UserId)
                add(scout.id)
                add(scout.Id)

            else

                add(scout)
            end
        end
    end

    for _, value in ipairs(candidates) do

        local userId =
            tonumber(value)

        if userId
        and userId > 0 then

            return math.floor(userId)
        end
    end

    return 0
end

function GAG2WildPetNetworkGetScoutName(rowData)

    if type(rowData) ~= "table" then
        return ""
    end

    local candidates =
        {}

    local function add(value)

        value =
            CleanText(value)

        if value ~= "" then

            table.insert(
                candidates,
                value
            )
        end
    end

    add(rowData.scoutName)
    add(rowData.ScoutName)
    add(rowData.bestScoutName)
    add(rowData.BestScoutName)
    add(rowData.reporterName)
    add(rowData.ReporterName)
    add(rowData.playerName)
    add(rowData.PlayerName)
    add(rowData.username)
    add(rowData.Username)
    add(rowData.name)
    add(rowData.Name)

    if type(rowData.scout) == "table" then

        add(rowData.scout.name)
        add(rowData.scout.Name)
        add(rowData.scout.username)
        add(rowData.scout.Username)
    end

    if type(rowData.reporter) == "table" then

        add(rowData.reporter.name)
        add(rowData.reporter.Name)
        add(rowData.reporter.username)
        add(rowData.reporter.Username)
    end

    if type(rowData.scouts) == "table" then

        for _, scout in ipairs(rowData.scouts) do

            if type(scout) == "table" then

                add(scout.name)
                add(scout.Name)
                add(scout.username)
                add(scout.Username)
            end
        end
    end

    return candidates[1]
        or ""
end

function GAG2QueuePlayerIdJoin(
    scoutUserId,
    fallbackPlaceId,
    fallbackJobId,
    reason
)

    scoutUserId =
        math.floor(
            tonumber(scoutUserId)
            or 0
        )

    fallbackPlaceId =
        tonumber(fallbackPlaceId)

    fallbackJobId =
        CleanText(fallbackJobId)

    reason =
        tostring(reason or "player-id join")

    if scoutUserId <= 0 then

        warn(
            "[HOLY PLAYER JOIN]",
            "missing scoutUserId; fallback exact join"
        )

        if fallbackPlaceId
        and fallbackPlaceId > 0
        and fallbackJobId ~= "" then

            GAG2SaveExactJoinTarget(
                fallbackPlaceId,
                fallbackJobId,
                0,
                reason .. " fallback missing scoutUserId"
            )

            return GAG2QueueExactJoin(
                fallbackPlaceId,
                fallbackJobId,
                reason .. " fallback missing scoutUserId"
            )
        end

        return false,
            "missing scoutUserId"
    end

    print(
        "[HOLY PLAYER JOIN]",
        "trying scout lookup",
        "| userId:",
        tostring(scoutUserId),
        "| fallback:",
        tostring(fallbackPlaceId)
        .. ":"
        .. tostring(fallbackJobId),
        "| reason:",
        reason
    )

    SetStatus(
        "Resolving scout user "
        .. tostring(scoutUserId)
        .. "..."
    )

    if type(GAG2WildPetNetworkSetStatus) == "function" then

        GAG2WildPetNetworkSetStatus(
            "Resolving scout user "
            .. tostring(scoutUserId)
            .. "..."
        )
    end

    local lookupOk,
        currentInstance,
        lookupError,
        resolvedPlaceId,
        resolvedJobId =
        pcall(function()

            return TeleportService:GetPlayerPlaceInstanceAsync(
                scoutUserId
            )
        end)

    if lookupOk ~= true then

        warn(
            "[HOLY PLAYER JOIN]",
            "scout lookup failed:",
            tostring(currentInstance)
        )

        if fallbackPlaceId
        and fallbackPlaceId > 0
        and fallbackJobId ~= "" then

            if type(GAG2WildPetNetworkSetStatus) == "function" then

                GAG2WildPetNetworkSetStatus(
                    "Scout lookup failed. Fallback exact join..."
                )
            end

            GAG2SaveExactJoinTarget(
                fallbackPlaceId,
                fallbackJobId,
                0,
                reason .. " fallback lookup failed"
            )

            return GAG2QueueExactJoin(
                fallbackPlaceId,
                fallbackJobId,
                reason .. " fallback lookup failed"
            )
        end

        return false,
            tostring(currentInstance)
    end

    resolvedPlaceId =
        tonumber(resolvedPlaceId)

    resolvedJobId =
        CleanText(resolvedJobId)

    print(
        "[HOLY PLAYER JOIN]",
        "lookup returned",
        "| currentInstance:",
        tostring(currentInstance),
        "| lookupError:",
        tostring(lookupError),
        "| placeId:",
        tostring(resolvedPlaceId),
        "| jobId:",
        tostring(resolvedJobId)
    )

    if currentInstance == true then

        SetStatus(
            "Scout is already in this server."
        )

        if type(GAG2WildPetNetworkSetStatus) == "function" then

            GAG2WildPetNetworkSetStatus(
                "Scout is already in this server."
            )
        end

        return false,
            "scout is already in this server"
    end

    if not resolvedPlaceId
    or resolvedPlaceId <= 0
    or resolvedJobId == "" then

        warn(
            "[HOLY PLAYER JOIN]",
            "lookup returned no usable JobId:",
            tostring(lookupError)
        )

        if fallbackPlaceId
        and fallbackPlaceId > 0
        and fallbackJobId ~= "" then

            if type(GAG2WildPetNetworkSetStatus) == "function" then

                GAG2WildPetNetworkSetStatus(
                    "Scout lookup empty. Fallback exact join..."
                )
            end

            GAG2SaveExactJoinTarget(
                fallbackPlaceId,
                fallbackJobId,
                0,
                reason .. " fallback lookup empty"
            )

            return GAG2QueueExactJoin(
                fallbackPlaceId,
                fallbackJobId,
                reason .. " fallback lookup empty"
            )
        end

        return false,
            tostring(lookupError or "scout lookup returned no JobId")
    end

    if resolvedPlaceId == tonumber(game.PlaceId)
    and resolvedJobId == tostring(game.JobId) then

        SetStatus(
            "Already in resolved scout server."
        )

        if type(GAG2WildPetNetworkSetStatus) == "function" then

            GAG2WildPetNetworkSetStatus(
                "Already in resolved scout server."
            )
        end

        return false,
            "already in resolved scout server"
    end

    GAG2ClearExactJoinTarget(
        "new scout user-id resolved join"
    )

    GAG2_EXACT_JOIN_STATE.Retrying =
        false

    GAG2SaveExactJoinTarget(
        resolvedPlaceId,
        resolvedJobId,
        0,
        reason .. " resolved from scoutUserId"
    )

    SetStatus(
        "Joining resolved scout server..."
    )

    if type(GAG2WildPetNetworkSetStatus) == "function" then

        GAG2WildPetNetworkSetStatus(
            "Joining scout server "
            .. tostring(resolvedJobId:sub(1, 8))
            .. "..."
        )
    end

    return GAG2QueueExactJoin(
        resolvedPlaceId,
        resolvedJobId,
        reason .. " resolved from scoutUserId"
    )
end

function GAG2RetryExactJoinTarget(target, reason)

    if type(target) ~= "table" then
        return false
    end

    if GAG2_EXACT_JOIN_STATE.Retrying == true then
        return true
    end

    local attempts =
        math.max(
            0,
            math.floor(
                tonumber(target.Attempts)
                or 0
            )
        )

    local maxAttempts =
        math.max(
            1,
            math.floor(
                tonumber(GAG2_EXACT_JOIN_STATE.MaxAttempts)
                or 3
            )
        )

    if attempts >= maxAttempts then

        local wanted =
            tostring(target.PlaceId)
            .. ":"
            .. tostring(target.JobId)

        local current =
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)

        GAG2ClearExactJoinTarget(
            "max attempts"
        )

        SetStatus(
            "Exact join failed. Target closed/full?"
        )

        GAG2SetManualJoinStatus(
            "Exact failed. Wanted "
            .. wanted
            .. " got "
            .. current
        )

        warn(
            "[HOLY EXACT JOIN]",
            "max attempts reached",
            "| wanted:",
            wanted,
            "| current:",
            current
        )

        return false
    end

    attempts = attempts + 1

    target.Attempts =
        attempts

    GAG2SaveExactJoinTarget(
        target.PlaceId,
        target.JobId,
        attempts,
        reason or "retry"
    )

    GAG2_EXACT_JOIN_STATE.Retrying =
        true

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    SetStatus(
        "Wrong server. Retrying exact "
        .. tostring(attempts)
        .. "/"
        .. tostring(maxAttempts)
    )

    GAG2SetManualJoinStatus(
        "Retrying exact "
        .. tostring(attempts)
        .. "/"
        .. tostring(maxAttempts)
        .. ": "
        .. tostring(target.PlaceId)
        .. ":"
        .. tostring(target.JobId)
    )

    task.delay(0.35, function()

        GAG2QueueExactJoin(
            target.PlaceId,
            target.JobId,
            reason or "exact retry"
        )

        task.delay(2, function()

            GAG2_EXACT_JOIN_STATE.Retrying =
                false
        end)
    end)

    return true
end

function GAG2HandlePendingExactJoinOnLoad()

    local target =
        GAG2ReadExactJoinTarget()

    if not target then
        return false
    end

    if GAG2ExactJoinMatchesCurrent(target) == true then

        GAG2ClearExactJoinTarget(
            "verified"
        )

        SetStatus(
            "Exact server verified."
        )

        GAG2SetManualJoinStatus(
            "Exact server verified."
        )

        print(
            "[HOLY EXACT JOIN]",
            "verified exact server:",
            tostring(game.PlaceId),
            tostring(game.JobId)
        )

        return false
    end

    local wanted =
        tostring(target.PlaceId)
        .. ":"
        .. tostring(target.JobId)

    local current =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    warn(
        "[HOLY EXACT JOIN]",
        "landed in wrong server",
        "| wanted:",
        wanted,
        "| current:",
        current
    )

    return GAG2RetryExactJoinTarget(
        target,
        "arrival mismatch"
    )
end

local function RejoinServer()

    SetStatus("Rejoining...")

    local ok, err =
        pcall(function()

            TeleportService:Teleport(
                game.PlaceId,
                LOCAL_PLAYER
            )
        end)

    if ok ~= true then

        SetStatus(
            "Rejoin failed: "
            .. tostring(err)
        )

        Notify(
            "Rejoin Failed",
            tostring(err),
            5
        )
    end
end

function GAG2ParseManualJoinTarget(text)

    text =
        tostring(text or "")
            :gsub("`", "")
            :gsub("\n", " ")
            :gsub("\r", " ")
            :gsub("−", "-")
            :gsub("–", "-")
            :gsub("—", "-")

    text =
        CleanText(
            text
        )

    if text == "" then
        return nil, "Paste full placeId:JobId."
    end

    local placeId =
        nil

    local jobId =
        nil

    local placeFromPair, jobFromPair =
        text:match("(%d+)%s*[:|,]%s*([%w%-]+)")

    if placeFromPair
    and jobFromPair then

        placeId =
            tonumber(placeFromPair)

        jobId =
            jobFromPair
    end

    if not placeId then

        placeId =
            tonumber(
                text:match("[Pp]lace[Ii][Dd][%s:=]+(%d+)")
            )
            or tonumber(
                text:match("[Pp]lace%s*[Ii][Dd][%s:=]+(%d+)")
            )
            or tonumber(
                text:match("placeId=(%d+)")
            )
            or tonumber(
                text:match("PlaceId=(%d+)")
            )
    end

    if not jobId
    or jobId == "" then

        jobId =
            text:match("[Gg]ame[Ii]nstance[Ii][Dd][%s=:/]+([%w%-]+)")
            or text:match("gameInstanceId=([%w%-]+)")
            or text:match("GameInstanceId=([%w%-]+)")
            or text:match("[Jj]ob[Ii][Dd][%s=:/]+([%w%-]+)")
            or text:match("jobId=([%w%-]+)")
            or text:match("JobId=([%w%-]+)")
            or text:match("([%w]+%-%w+%-%w+%-%w+%-%w+)")
            or ""
    end

    jobId =
        CleanText(jobId)
            :gsub("[^%w%-]", "")

    if not placeId
    or placeId <= 0 then

        return nil,
            "JobId-only blocked. Paste full placeId:JobId from Discord."
    end

    if jobId == ""
    or #jobId < 10 then
        return nil, "Invalid JobId."
    end

    return {
        PlaceId = placeId,
        JobId = jobId,
        JoinCode =
            GAG2BuildJoinCode(
                placeId,
                jobId
            ),
        PlaceWasInferred =
            false,
        KnownPlace =
            IsGAG2KnownPlace(
                placeId
            ),
    },
    nil
end

function GAG2SetManualJoinStatus(text)

    GAG2_MANUAL_JOIN_STATE.StatusText =
        tostring(text or "Ready.")

    GAG2RefreshManualJoinVisuals()
end

function GAG2SetManualJoinTargetText(text)

    GAG2_MANUAL_JOIN_STATE.TargetText =
        tostring(text or "")

    local parsed, errorText =
        GAG2ParseManualJoinTarget(
            GAG2_MANUAL_JOIN_STATE.TargetText
        )

    if parsed then

        local previewText =
            "Ready: "
            .. tostring(parsed.JoinCode)

        if parsed.PlaceWasInferred == true then

            previewText =
                previewText
                .. " (current place inferred)"
        end

        if parsed.KnownPlace ~= true then

            previewText =
                previewText
                .. " (unknown place)"
        end

        GAG2_MANUAL_JOIN_STATE.PreviewText =
            previewText

        GAG2_MANUAL_JOIN_STATE.StatusText =
            previewText

    else

        GAG2_MANUAL_JOIN_STATE.PreviewText =
            tostring(errorText or "Invalid input.")

        if CleanText(GAG2_MANUAL_JOIN_STATE.TargetText) == "" then

            GAG2_MANUAL_JOIN_STATE.StatusText =
                "Paste full placeId:JobId."

        else

            GAG2_MANUAL_JOIN_STATE.StatusText =
                tostring(errorText or "Invalid input.")
        end
    end

    GAG2RefreshManualJoinVisuals()
end

function GAG2CopyCurrentJoinCode()

    local payload =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    if CopyText(payload) == true then

        GAG2_MANUAL_JOIN_STATE.LastTargetText =
            payload

        GAG2SetManualJoinStatus(
            "Copied current server code."
        )

        Notify(
            "Copied",
            "Current server code copied.",
            3
        )

        return true
    end

    GAG2SetManualJoinStatus(
        "Clipboard unsupported."
    )

    Notify(
        "Clipboard",
        "Clipboard unsupported.",
        4
    )

    return false
end

function GAG2ManualJoinServer()

    local parsed, errorText =
        GAG2ParseManualJoinTarget(
            GAG2_MANUAL_JOIN_STATE.TargetText
        )

    if not parsed then

        GAG2SetManualJoinStatus(
            tostring(errorText or "Invalid input.")
        )

        Notify(
            "Join Server",
            tostring(errorText or "Invalid input."),
            4
        )

        return false
    end

    if parsed.KnownPlace ~= true then

        GAG2SetManualJoinStatus(
            "Unknown PlaceId: "
            .. tostring(parsed.PlaceId)
        )

        Notify(
            "Join Server",
            "Unknown GAG2 PlaceId. Add it to known places first.",
            5
        )

        return false
    end

    if tonumber(parsed.PlaceId) == tonumber(game.PlaceId)
    and tostring(parsed.JobId) == tostring(game.JobId) then

        GAG2SetManualJoinStatus(
            "Already in this server."
        )

        Notify(
            "Join Server",
            "Already in this server.",
            3
        )

        return false
    end

    if type(GAG2CancelServerHop) == "function" then

        GAG2CancelServerHop(
            nil
        )

    else

        GAG2_SERVER_HOP_RETRYING =
            false

        GAG2_SERVER_HOP_ATTEMPT =
            0
    end

    GAG2_MANUAL_JOIN_STATE.LastTargetText =
        parsed.JoinCode

    GAG2SaveExactJoinTarget(
        parsed.PlaceId,
        parsed.JobId,
        0,
        "manual join"
    )

    GAG2SetManualJoinStatus(
        "Exact joining: "
        .. tostring(parsed.JoinCode)
    )

    SetStatus(
        "Exact joining: "
        .. tostring(parsed.JoinCode)
    )

    local ok, err =
        GAG2QueueExactJoin(
            parsed.PlaceId,
            parsed.JobId,
            "manual join"
        )

    if ok ~= true then

        GAG2ClearExactJoinTarget(
            "manual join call failed"
        )

        GAG2SetManualJoinStatus(
            "Exact join failed."
        )

        SetStatus(
            "Exact join failed: "
            .. tostring(err)
        )

        Notify(
            "Join Failed",
            tostring(err),
            5
        )

        return false
    end

    return true
end

function GAG2GetManualJoinHudParent()

    local ok =
        pcall(function()

            if CoreGui then
                return CoreGui.Name
            end
        end)

    if ok == true
    and CoreGui then
        return CoreGui
    end

    return LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
        or nil
end

function GAG2DestroyManualJoinHud()

    if GAG2_MANUAL_JOIN_HUD_GUI then

        pcall(function()

            GAG2_MANUAL_JOIN_HUD_GUI:Destroy()
        end)
    end

    GAG2_MANUAL_JOIN_HUD_GUI =
        nil

    GAG2_MANUAL_JOIN_HUD_INPUT =
        nil

    GAG2_MANUAL_JOIN_HUD_STATUS =
        nil
end

function GAG2StyleManualJoinButton(button)

    if typeof(button) ~= "Instance" then
        return
    end

    button.BackgroundColor3 =
        Color3.fromRGB(24, 18, 38)

    button.BorderSizePixel =
        0

    button.Font =
        Enum.Font.Code

    button.TextSize =
        12

    button.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 5)

    corner.Parent =
        button
end

function GAG2CreateManualJoinHud()

    if GAG2_MANUAL_JOIN_HUD_GUI then
        return GAG2_MANUAL_JOIN_HUD_GUI
    end

    local parent =
        GAG2GetManualJoinHudParent()

    if not parent then

        GAG2SetManualJoinStatus(
            "HUD parent missing."
        )

        return nil
    end

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "HolyGAG2ManualJoinHud"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    gui.Parent =
        parent

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Frame"

    frame.Position =
        UDim2.new(
            1,
            -318,
            0,
            130
        )

    frame.Size =
        UDim2.fromOffset(
            300,
            130
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(9, 7, 15)

    frame.BorderSizePixel =
        0

    frame.Active =
        true

    frame.Draggable =
        true

    frame.Parent =
        gui

    local frameCorner =
        Instance.new("UICorner")

    frameCorner.CornerRadius =
        UDim.new(0, 8)

    frameCorner.Parent =
        frame

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(88, 64, 145)

    stroke.Thickness =
        1

    stroke.Transparency =
        0.15

    stroke.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(
            10,
            5
        )

    title.Size =
        UDim2.fromOffset(
            245,
            22
        )

    title.Font =
        Enum.Font.Code

    title.TextSize =
        14

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    title.Text =
        "Server Joiner"

    title.Parent =
        frame

    local close =
        Instance.new("TextButton")

    close.Name =
        "Close"

    close.BackgroundTransparency =
        1

    close.Position =
        UDim2.fromOffset(
            265,
            4
        )

    close.Size =
        UDim2.fromOffset(
            28,
            22
        )

    close.Font =
        Enum.Font.Code

    close.TextSize =
        16

    close.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    close.Text =
        "×"

    close.Parent =
        frame

    close.MouseButton1Click:Connect(function()

        GAG2_MANUAL_JOIN_STATE.HudEnabled =
            false

        if GAG2_MANUAL_JOIN_HUD_TOGGLE
        and type(GAG2_MANUAL_JOIN_HUD_TOGGLE.SetValue) == "function" then

            pcall(function()

                GAG2_MANUAL_JOIN_HUD_TOGGLE:SetValue(
                    false
                )
            end)
        end

        GAG2DestroyManualJoinHud()

        MarkConfigDirty()
    end)

    local input =
        Instance.new("TextBox")

    input.Name =
        "Target"

    input.Position =
        UDim2.fromOffset(
            10,
            32
        )

    input.Size =
        UDim2.fromOffset(
            280,
            26
        )

    input.BackgroundColor3 =
        Color3.fromRGB(15, 12, 24)

    input.BorderSizePixel =
        0

    input.ClearTextOnFocus =
        false

    input.Font =
        Enum.Font.Code

    input.TextSize =
        12

    input.TextXAlignment =
        Enum.TextXAlignment.Left

    input.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    input.PlaceholderColor3 =
        Color3.fromRGB(125, 116, 145)

    input.PlaceholderText =
        "required: placeId:JobId..."

    input.Text =
        GAG2_MANUAL_JOIN_STATE.TargetText

    input.Parent =
        frame

    local inputCorner =
        Instance.new("UICorner")

    inputCorner.CornerRadius =
        UDim.new(0, 5)

    inputCorner.Parent =
        input

    input.FocusLost:Connect(function()

        GAG2SetManualJoinTargetText(
            input.Text
        )
    end)

    local status =
        Instance.new("TextLabel")

    status.Name =
        "Status"

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(
            10,
            62
        )

    status.Size =
        UDim2.fromOffset(
            280,
            18
        )

    status.Font =
        Enum.Font.Code

    status.TextSize =
        12

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    status.Text =
        GAG2_MANUAL_JOIN_STATE.StatusText

    status.Parent =
        frame

    local join =
        Instance.new("TextButton")

    join.Name =
        "Join"

    join.Position =
        UDim2.fromOffset(
            10,
            88
        )

    join.Size =
        UDim2.fromOffset(
            82,
            24
        )

    join.Text =
        "Join"

    join.Parent =
        frame

    GAG2StyleManualJoinButton(
        join
    )

    join.MouseButton1Click:Connect(function()

        GAG2SetManualJoinTargetText(
            input.Text
        )

        GAG2ManualJoinServer()
    end)

    local copy =
        Instance.new("TextButton")

    copy.Name =
        "CopyCurrent"

    copy.Position =
        UDim2.fromOffset(
            101,
            88
        )

    copy.Size =
        UDim2.fromOffset(
            88,
            24
        )

    copy.Text =
        "Current"

    copy.Parent =
        frame

    GAG2StyleManualJoinButton(
        copy
    )

    copy.MouseButton1Click:Connect(function()

        GAG2CopyCurrentJoinCode()
    end)

    local rejoin =
        Instance.new("TextButton")

    rejoin.Name =
        "Rejoin"

    rejoin.Position =
        UDim2.fromOffset(
            198,
            88
        )

    rejoin.Size =
        UDim2.fromOffset(
            92,
            24
        )

    rejoin.Text =
        "Rejoin"

    rejoin.Parent =
        frame

    GAG2StyleManualJoinButton(
        rejoin
    )

    rejoin.MouseButton1Click:Connect(function()

        GAG2SetManualJoinTargetText(
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)
        )

        GAG2ManualJoinServer()
    end)

    GAG2_MANUAL_JOIN_HUD_GUI =
        gui

    GAG2_MANUAL_JOIN_HUD_INPUT =
        input

    GAG2_MANUAL_JOIN_HUD_STATUS =
        status

    GAG2RefreshManualJoinVisuals()

    return gui
end

function GAG2SetManualJoinHudEnabled(value)

    GAG2_MANUAL_JOIN_STATE.HudEnabled =
        value == true

    if GAG2_MANUAL_JOIN_STATE.HudEnabled == true then

        GAG2CreateManualJoinHud()

    else

        GAG2DestroyManualJoinHud()
    end

    MarkConfigDirty()
end

function GAG2RefreshManualJoinVisuals()

    if type(GAG2_MANUAL_JOIN_STATE) ~= "table" then
        return
    end

    if GAG2_MANUAL_JOIN_STATE.Refreshing == true then
        return
    end

    GAG2_MANUAL_JOIN_STATE.Refreshing =
        true

    if GAG2_MANUAL_JOIN_INPUT_CONTROL
    and type(GAG2_MANUAL_JOIN_INPUT_CONTROL.SetValue) == "function" then

        pcall(function()

            GAG2_MANUAL_JOIN_INPUT_CONTROL:SetValue(
                GAG2_MANUAL_JOIN_STATE.TargetText
            )
        end)
    end

    if GAG2_MANUAL_JOIN_HUD_INPUT
    and GAG2_MANUAL_JOIN_HUD_INPUT.Text ~= GAG2_MANUAL_JOIN_STATE.TargetText then

        pcall(function()

            GAG2_MANUAL_JOIN_HUD_INPUT.Text =
                GAG2_MANUAL_JOIN_STATE.TargetText
        end)
    end

    if GAG2_MANUAL_JOIN_HUD_STATUS then

        pcall(function()

            GAG2_MANUAL_JOIN_HUD_STATUS.Text =
                GAG2_MANUAL_JOIN_STATE.StatusText
                or GAG2_MANUAL_JOIN_STATE.PreviewText
                or "Ready."
        end)
    end

    GAG2_MANUAL_JOIN_STATE.Refreshing =
        false
end

local function GetHttp(url)

    local ok, body =
        pcall(function()

            return game:HttpGet(
                tostring(url or "")
            )
        end)

    if ok == true
    and type(body) == "string"
    and body ~= "" then
        return body
    end

    local requestFunction =
        (syn and syn.request)
        or http_request
        or request
        or (fluxus and fluxus.request)

    if type(requestFunction) ~= "function" then
        return nil
    end

    local requestOk, response =
        pcall(function()

            return requestFunction({
                Url = tostring(url or ""),
                Method = "GET",
            })
        end)

    if requestOk == true
    and type(response) == "table" then
        return response.Body
    end

    return nil
end

--==================================================
-- [4.12] SERVER SELECTION MODE
-- Used by manual hop, version hopper, and sniper auto-hop.
--==================================================

GAG2_SERVER_SELECTION_MODES =
    GAG2_SERVER_SELECTION_MODES
    or {
        "Most Empty",
        "Random",
        "Most Full",
        "Balanced",
    }

GAG2_SERVER_SELECTION_STATE =
    GAG2_SERVER_SELECTION_STATE
    or {
        Mode = "Most Empty",
        LastStatus = "Ready.",
        LastTarget = "",
    }

function GAG2ServerSelectionClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2ServerSelectionModeValid(mode)

    mode =
        GAG2ServerSelectionClean(mode)

    return table.find(
        GAG2_SERVER_SELECTION_MODES,
        mode
    ) ~= nil
end

function GAG2ServerSelectionGetMode()

    local state =
        GAG2_SERVER_SELECTION_STATE

    local mode =
        GAG2ServerSelectionClean(
            state.Mode
        )

    if GAG2ServerSelectionModeValid(mode) ~= true then
        mode =
            "Most Empty"
    end

    state.Mode =
        mode

    return mode
end

function GAG2ServerSelectionBuildStatus()

    local state =
        GAG2_SERVER_SELECTION_STATE

    return '<font color="rgb(196,181,253)"><b>Server Selection</b></font>'
        .. '\nMode: '
        .. tostring(GAG2ServerSelectionGetMode())
        .. '\nLast: '
        .. tostring(state.LastStatus or "Ready.")
        .. '\nTarget: '
        .. tostring(state.LastTarget or "None")
end

function GAG2ServerSelectionRefreshStatus()

    if Options.HolyGAG2ServerSelectionStatus then

        Options.HolyGAG2ServerSelectionStatus:SetText(
            GAG2ServerSelectionBuildStatus()
        )
    end
end

function GAG2ServerSelectionSetStatus(text)

    GAG2_SERVER_SELECTION_STATE.LastStatus =
        tostring(text or "Ready.")

    GAG2ServerSelectionRefreshStatus()
end

function GAG2ServerSelectionSetMode(value)

    local mode =
        GAG2ServerSelectionClean(value)

    if GAG2ServerSelectionModeValid(mode) ~= true then
        mode =
            "Most Empty"
    end

    GAG2_SERVER_SELECTION_STATE.Mode =
        mode

    GAG2ServerSelectionSetStatus(
        "Mode set to "
        .. tostring(mode)
        .. "."
    )

    MarkConfigDirty()
end

function GAG2ServerSelectionGetOccupancy(server)

    local playing =
        tonumber(server and server.playing)
        or 0

    local maxPlayers =
        tonumber(server and server.maxPlayers)
        or 0

    if maxPlayers <= 0 then
        return 0
    end

    return playing / maxPlayers
end

function GAG2ServerSelectionPickFromTop(servers, limit)

    limit =
        math.min(
            #servers,
            math.max(
                1,
                math.floor(
                    tonumber(limit)
                    or 10
                )
            )
        )

    return servers[
        math.random(
            1,
            limit
        )
    ]
end

function GAG2ServerSelectionPickTarget(servers)

    if type(servers) ~= "table"
    or #servers <= 0 then
        return nil
    end

    local mode =
        GAG2ServerSelectionGetMode()

    if mode == "Random" then

        return servers[
            math.random(
                1,
                #servers
            )
        ]
    end

    if mode == "Most Full" then

        table.sort(servers, function(a, b)

            return tonumber(a.playing or 0)
                > tonumber(b.playing or 0)
        end)

        return GAG2ServerSelectionPickFromTop(
            servers,
            10
        )
    end

    if mode == "Balanced" then

        local balanced =
            {}

        for _, server in ipairs(servers) do

            local occupancy =
                GAG2ServerSelectionGetOccupancy(
                    server
                )

            if occupancy >= 0.25
            and occupancy <= 0.85 then

                table.insert(
                    balanced,
                    server
                )
            end
        end

        if #balanced <= 0 then
            balanced = servers
        end

        table.sort(balanced, function(a, b)

            local aDistance =
                math.abs(
                    GAG2ServerSelectionGetOccupancy(a) - 0.50
                )

            local bDistance =
                math.abs(
                    GAG2ServerSelectionGetOccupancy(b) - 0.50
                )

            return aDistance < bDistance
        end)

        return GAG2ServerSelectionPickFromTop(
            balanced,
            10
        )
    end

    -- Default / old behavior: Most Empty.
    table.sort(servers, function(a, b)

        return tonumber(a.FreeSlots or 0)
            > tonumber(b.FreeSlots or 0)
    end)

    return GAG2ServerSelectionPickFromTop(
        servers,
        10
    )
end

function GAG2ServerSelectionRememberTarget(target)

    if type(target) ~= "table" then
        return
    end

    GAG2_SERVER_SELECTION_STATE.LastTarget =
        tostring(target.playing)
        .. "/"
        .. tostring(target.maxPlayers)
        .. " | "
        .. tostring(target.id or "?")

    GAG2ServerSelectionRefreshStatus()
end

function GAG2RestoreServerSelectionState()

    task.defer(function()

        if Options.HolyGAG2ServerSelectionMode then

            GAG2_SERVER_SELECTION_STATE.Mode =
                GAG2ServerSelectionClean(
                    Options.HolyGAG2ServerSelectionMode.Value
                )
        end

        if GAG2ServerSelectionModeValid(
            GAG2_SERVER_SELECTION_STATE.Mode
        ) ~= true then

            GAG2_SERVER_SELECTION_STATE.Mode =
                "Most Empty"
        end

        GAG2ServerSelectionSetStatus(
            "Ready."
        )
    end)
end

function HopServerOnce()

    if GAG2_SERVER_HOP_RETRYING == true then

        SetStatus(
            "Server hop already retrying..."
        )

        return false
    end

    GAG2_SERVER_HOP_RETRYING =
        true

    task.spawn(function()

        while GAG2_SERVER_HOP_RETRYING == true do

            GAG2_SERVER_HOP_ATTEMPT =
                tonumber(GAG2_SERVER_HOP_ATTEMPT)
                or 0

            GAG2_SERVER_HOP_ATTEMPT =
                GAG2_SERVER_HOP_ATTEMPT
                + 1

            SetStatus(
                "Finding server..."
                .. " attempt "
                .. tostring(GAG2_SERVER_HOP_ATTEMPT)
            )

            local url =
                "https://games.roblox.com/v1/games/"
                .. tostring(game.PlaceId)
                .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"

            local body =
                GetHttp(url)

            if type(body) ~= "string"
            or body == "" then

                SetStatus(
                    "Server list failed. Retrying..."
                )

                task.wait(
                    2
                )

                continue
            end

            local decodeOk, data =
                pcall(function()

                    return HttpService:JSONDecode(
                        body
                    )
                end)

            if decodeOk ~= true
            or type(data) ~= "table" then

                SetStatus(
                    "Server decode failed. Retrying..."
                )

                task.wait(
                    2
                )

                continue
            end

            local servers =
                {}

            for _, server in ipairs(data.data or {}) do

                local serverId =
                    CleanText(server.id)

                local playing =
                    tonumber(server.playing)
                    or 0

                local maxPlayers =
                    tonumber(server.maxPlayers)
                    or 0

                if serverId ~= ""
                and serverId ~= game.JobId
                and maxPlayers > 0
                and playing < maxPlayers then

                    server.FreeSlots =
                        maxPlayers - playing

                    table.insert(
                        servers,
                        server
                    )
                end
            end

            if #servers <= 0 then

                SetStatus(
                    "No valid server. Retrying..."
                )

                task.wait(
                    2
                )

                continue
            end

            if GAG2_SERVER_HOP_RETRYING ~= true then
                return
            end

            local target =
                GAG2ServerSelectionPickTarget(
                    servers
                )

            if not target then

                SetStatus(
                    "No server target selected. Retrying..."
                )

                GAG2ServerSelectionSetStatus(
                    "No target selected."
                )

                task.wait(
                    2
                )

                continue
            end

            GAG2ServerSelectionRememberTarget(
                target
            )

            SetStatus(
                "Hopping "
                .. tostring(GAG2ServerSelectionGetMode())
                .. " to "
                .. tostring(target.playing)
                .. "/"
                .. tostring(target.maxPlayers)
                .. " server..."
            )

            GAG2ServerSelectionSetStatus(
                "Teleporting using "
                .. tostring(GAG2ServerSelectionGetMode())
                .. "."
            )

                        if GAG2_SERVER_HOP_RETRYING ~= true then
                return
            end

            local ok, err =
                pcall(function()

                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        target.id,
                        LOCAL_PLAYER
                    )
                end)

            if ok == true then

                SetStatus(
                    "Teleport queued."
                )

                return
            end

            SetStatus(
                "Hop failed. Retrying..."
            )

            warn(
                "[HOLY]",
                "server hop failed",
                tostring(err)
            )

            task.wait(
                1.5
            )
        end
    end)

    return true
end

--==================================================
-- [4.125] LIVE WILD PET NETWORK HUD
--
-- Reads GetLiveWildPets from the hard-coded endpoint.
-- Displays a draggable clickable HUD.
-- Clicking a row uses HOLY's exact server join system.
--==================================================

function GAG2WildPetNetworkCleanDisplay(value)

    return tostring(value or "")
        :gsub("<", "")
        :gsub(">", "")
        :gsub("\r", " ")
        :gsub("\n", " ")
end

function GAG2WildPetNetworkGetParent()

    if type(GAG2GetManualJoinHudParent) == "function" then

        local parent =
            GAG2GetManualJoinHudParent()

        if parent then
            return parent
        end
    end

    if CoreGui then
        return CoreGui
    end

    return LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
        or nil
end

function GAG2WildPetNetworkGetResponseBody(response)

    if type(response) == "string" then
        return response
    end

    if type(response) ~= "table" then
        return ""
    end

    return tostring(
        response.Body
        or response.body
        or response.ResponseBody
        or response.responseBody
        or ""
    )
end

function GAG2WildPetNetworkRequest(payload)

    if type(payload) ~= "table" then

        return nil,
            "bad network payload"
    end

    local endpoint =
        CleanText(
            GAG2_WILD_PET_NETWORK_ENDPOINT
        )

    local apiKey =
        CleanText(
            GAG2_WILD_PET_NETWORK_API_KEY
        )

    if endpoint == "" then

        return nil,
            "network endpoint missing"
    end

    if apiKey == ""
    or apiKey == "PASTE_CONFIG_B2_KEY_HERE" then

        return nil,
            "paste the Config B2 API key into the script"
    end

    local requestFunction =
        GAG2ExecutorGetRequestFunction()

    local bodyTable =
        {}

    for key, value in pairs(payload) do

        bodyTable[key] =
            value
    end

    bodyTable.apiKey =
        apiKey

    local function encodeQueryValue(value)

        local text =
            tostring(value or "")

        local ok, encoded =
            pcall(function()

                return HttpService:UrlEncode(
                    text
                )
            end)

        if ok == true
        and type(encoded) == "string" then

            return encoded
        end

        return text
            :gsub("%%", "%%25")
            :gsub(" ", "%%20")
            :gsub("\n", "%%0A")
            :gsub("\r", "%%0D")
            :gsub("&", "%%26")
            :gsub("=", "%%3D")
            :gsub("?", "%%3F")
    end

    local function buildGetUrl()

        local parts =
            {}

        for key, value in pairs(bodyTable) do

            if type(value) ~= "table"
            and type(value) ~= "function"
            and type(value) ~= "thread"
            and type(value) ~= "userdata" then

                parts[#parts + 1] =
                    encodeQueryValue(key)
                    .. "="
                    .. encodeQueryValue(value)
            end
        end

        table.sort(
            parts
        )

        local separator =
            endpoint:find(
                "?",
                1,
                true
            )
            and "&"
            or "?"

        return endpoint
            .. separator
            .. table.concat(
                parts,
                "&"
            )
    end

    local function previewBody(body)

        local text =
            tostring(body or "")
                :gsub("\r", " ")
                :gsub("\n", " ")
                :gsub("%s+", " ")

        if #text > 220 then

            text =
                text:sub(
                    1,
                    220
                )
                .. "..."
        end

        if text == "" then
            text =
                "empty"
        end

        return text
    end

    local function decodeBody(body, label)

        body =
            tostring(body or "")

        if body:sub(1, 3) == "\239\187\191" then

            body =
                body:sub(4)
        end

        local decodeOk, decoded =
            pcall(function()

                return HttpService:JSONDecode(
                    body
                )
            end)

        if decodeOk == true
        and type(decoded) == "table" then

            if decoded.ok ~= true then

                return nil,
                    tostring(
                        decoded.message
                        or decoded.error
                        or "endpoint rejected request"
                    )
            end

            return decoded,
                nil
        end

        local firstBrace =
            body:find(
                "{",
                1,
                true
            )

        local lastBrace =
            body:match("^.*()}")

        if firstBrace
        and lastBrace
        and lastBrace >= firstBrace then

            local sliced =
                body:sub(
                    firstBrace,
                    lastBrace
                )

            local slicedOk, slicedDecoded =
                pcall(function()

                    return HttpService:JSONDecode(
                        sliced
                    )
                end)

            if slicedOk == true
            and type(slicedDecoded) == "table" then

                if slicedDecoded.ok ~= true then

                    return nil,
                        tostring(
                            slicedDecoded.message
                            or slicedDecoded.error
                            or "endpoint rejected request"
                        )
                end

                return slicedDecoded,
                    nil
            end
        end

        local lower =
            body:sub(
                1,
                400
            ):lower()

        if lower:find("<!doctype html", 1, true)
        or lower:find("<html", 1, true) then

            return nil,
                tostring(label or "request")
                .. " returned HTML/redirect page. Preview: "
                .. previewBody(body)
        end

        return nil,
            tostring(label or "request")
            .. " invalid JSON. Preview: "
            .. previewBody(body)
    end

    local function getHeader(response, headerName)

        if type(response) ~= "table" then
            return nil
        end

        local headers =
            response.Headers
            or response.headers

        if type(headers) ~= "table" then
            return nil
        end

        return headers[headerName]
            or headers[headerName:lower()]
            or headers[headerName:upper()]
    end

    local function getResponseBody(response)

        if type(response) == "string" then

            return response
        end

        if type(response) ~= "table" then
            return ""
        end

        return tostring(
            response.Body
            or response.body
            or response.ResponseBody
            or response.responseBody
            or ""
        )
    end

    local function tryRequest(method, url, encodedBody, label)

        if type(requestFunction) ~= "function" then

            return nil,
                "executor request function unavailable"
        end

        local options = {
            Url =
                tostring(url),

            Method =
                tostring(method or "GET"),

            Headers = {
                ["Accept"] =
                    "application/json",

                ["Cache-Control"] =
                    "no-cache",
            },

            Redirect =
                true,
        }

        if encodedBody ~= nil then

            options.Headers["Content-Type"] =
                "application/json"

            options.Body =
                encodedBody
        end

        local ok, response =
            pcall(
                requestFunction,
                options
            )

        if ok ~= true then

            return nil,
                tostring(response)
        end

        local body =
            getResponseBody(
                response
            )

        local decoded, decodeError =
            decodeBody(
                body,
                label
            )

        if decoded then

            return decoded,
                nil
        end

        local location =
            getHeader(
                response,
                "Location"
            )

        if type(location) == "string"
        and location ~= ""
        and location ~= url then

            local followOk, followResponse =
                pcall(
                    requestFunction,
                    {
                        Url = location,
                        Method = "GET",

                        Headers = {
                            ["Accept"] =
                                "application/json",

                            ["Cache-Control"] =
                                "no-cache",
                        },

                        Redirect =
                            true,
                    }
                )

            if followOk == true then

                local followBody =
                    getResponseBody(
                        followResponse
                    )

                local followDecoded, followError =
                    decodeBody(
                        followBody,
                        tostring(label)
                        .. " redirected"
                    )

                if followDecoded then

                    return followDecoded,
                        nil
                end

                return nil,
                    tostring(followError)
            end
        end

        return nil,
            tostring(decodeError)
    end

    local action =
        tostring(
            bodyTable.action
            or bodyTable.Action
            or ""
        )

    local errors =
        {}

    -- Reader actions are safer as GET on Apps Script.
    -- Some executors receive HTML on POST because Google redirects the /exec URL.

    if action == "GetLiveWildPets"
    or action == "ping" then

        local getUrl =
            buildGetUrl()

        if type(GetHttp) == "function" then

            local body =
                GetHttp(
                    getUrl
                )

            if type(body) == "string"
            and body ~= "" then

                local decoded, decodeError =
                    decodeBody(
                        body,
                        "GET HttpGet"
                    )

                if decoded then

                    return decoded,
                        nil
                end

                errors[#errors + 1] =
                    tostring(decodeError)
            else

                errors[#errors + 1] =
                    "GET HttpGet returned no body"
            end
        end

        local decoded, requestError =
            tryRequest(
                "GET",
                getUrl,
                nil,
                "GET request"
            )

        if decoded then

            return decoded,
                nil
        end

        errors[#errors + 1] =
            tostring(requestError)
    end

    local encodeOk, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                bodyTable
            )
        end)

    if encodeOk ~= true
    or type(encoded) ~= "string" then

        return nil,
            "failed to encode network request"
    end

    local decoded, postError =
        tryRequest(
            "POST",
            endpoint,
            encoded,
            "POST request"
        )

    if decoded then

        return decoded,
            nil
    end

    errors[#errors + 1] =
        tostring(postError)

    return nil,
        table.concat(
            errors,
            " | "
        )
end

function GAG2WildPetNetworkGetRarityRank(rarity)

    local ranks = {
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Mythic = 6,
        Mythical = 6,
        Super = 7,
        Divine = 8,
        Prismatic = 9,
    }

    return ranks[
        CleanText(rarity)
    ]
        or 0
end

function GAG2WildPetNetworkGetRarityColor(rarity)

    local colors = {
        Common = "rgb(203,213,225)",
        Uncommon = "rgb(74,222,128)",
        Rare = "rgb(96,165,250)",
        Epic = "rgb(192,132,252)",
        Legendary = "rgb(250,204,21)",
        Mythic = "rgb(248,113,113)",
        Mythical = "rgb(248,113,113)",
        Super = "rgb(34,211,238)",
        Divine = "rgb(251,146,60)",
        Prismatic = "rgb(244,114,182)",
    }

    return colors[
        CleanText(rarity)
    ]
        or "rgb(203,213,225)"
end

function GAG2WildPetNetworkFormatSeconds(value)

    local seconds =
        math.max(
            0,
            math.floor(
                tonumber(value)
                or 0
            )
        )

    if seconds >= 60 then

        local minutes =
            math.floor(seconds / 60)

        local remaining =
            seconds % 60

        return tostring(minutes)
            .. "m "
            .. tostring(remaining)
            .. "s"
    end

    return tostring(seconds)
        .. "s"
end

function GAG2WildPetNetworkBuildStatusText()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    local refreshText =
        "Never"

    if tonumber(state.LastRefreshAt or 0) > 0 then

        refreshText =
            tostring(
                math.max(
                    0,
                    os.time()
                    - tonumber(state.LastRefreshAt)
                )
            )
            .. "s ago"
    end

    return '<font color="rgb(196,181,253)"><b>Live Wild Pet Network</b></font>'
        .. '\nEnabled: '
        .. (
            state.Enabled == true
            and "YES"
            or "NO"
        )
        .. ' | Refresh: '
        .. refreshText
        .. '\nServers: '
        .. tostring(state.LastServerCount or 0)
        .. ' | Pets: '
        .. tostring(state.LastPetCount or 0)
        .. '\nStatus: '
        .. tostring(state.LastStatus or "Idle.")
end

function GAG2WildPetNetworkRefreshStatus()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    if state.StatusLabel then

        pcall(function()

            state.StatusLabel.Text =
                tostring(
                    state.LastStatus
                    or "Idle."
                )
        end)
    end

    if Options.HolyGAG2WildPetNetworkStatus then

        Options.HolyGAG2WildPetNetworkStatus:SetText(
            GAG2WildPetNetworkBuildStatusText()
        )
    end
end

function GAG2WildPetNetworkSetStatus(text)

    GAG2_WILD_PET_NETWORK_STATE.LastStatus =
        tostring(text or "Idle.")

    GAG2WildPetNetworkRefreshStatus()
end

function GAG2WildPetNetworkAddCorner(parent, radius)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(
            0,
            tonumber(radius)
            or 6
        )

    corner.Parent =
        parent

    return corner
end

function GAG2WildPetNetworkCreateLabel(
    parent,
    name,
    text,
    height,
    textSize,
    richText
)

    local label =
        Instance.new("TextLabel")

    label.Name =
        tostring(name or "Label")

    label.Size =
        UDim2.new(
            1,
            -8,
            0,
            tonumber(height)
            or 24
        )

    label.BackgroundTransparency =
        1

    label.Font =
        Enum.Font.GothamMedium

    label.Text =
        tostring(text or "")

    label.TextSize =
        tonumber(textSize)
        or 13

    label.TextColor3 =
        Color3.fromRGB(
            226,
            232,
            240
        )

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.TextYAlignment =
        Enum.TextYAlignment.Center

    label.TextWrapped =
        true

    label.RichText =
        richText == true

    label.Parent =
        parent

    return label
end

function GAG2WildPetNetworkGetRarityColor3(rarity)

    local colors = {
        Common = Color3.fromRGB(203, 213, 225),
        Uncommon = Color3.fromRGB(74, 222, 128),
        Rare = Color3.fromRGB(96, 165, 250),
        Epic = Color3.fromRGB(192, 132, 252),
        Legendary = Color3.fromRGB(250, 204, 21),
        Mythic = Color3.fromRGB(248, 113, 113),
        Mythical = Color3.fromRGB(248, 113, 113),
        Super = Color3.fromRGB(34, 211, 238),
        Divine = Color3.fromRGB(251, 146, 60),
        Prismatic = Color3.fromRGB(244, 114, 182),
    }

    return colors[
        CleanText(rarity)
    ]
        or Color3.fromRGB(
            203,
            213,
            225
        )
end

function GAG2WildPetNetworkGetRowExpiresAt(rowData)

    if type(rowData) ~= "table" then
        return 0
    end

    local expiresAt =
        tonumber(
            rowData.bestExpiresAt
            or rowData.expiresAt
            or rowData.ExpiresAt
            or rowData.endTime
            or rowData.EndTime
        )

    if expiresAt
    and expiresAt > 0 then

        return expiresAt
    end

    local spawnedAt =
        tonumber(
            rowData.bestSpawnedAt
            or rowData.spawnedAt
            or rowData.SpawnedAt
        )

    local lifetime =
        tonumber(
            rowData.bestLifetime
            or rowData.lifetime
            or rowData.Lifetime
        )

    if spawnedAt
    and lifetime
    and spawnedAt > 0
    and lifetime > 0 then

        return spawnedAt + lifetime
    end

    local remaining =
        tonumber(
            rowData.bestRemaining
            or rowData.remaining
            or rowData.Remaining
            or rowData.timeLeft
            or rowData.TimeLeft
            or rowData.timer
            or rowData.Timer
        )

    if remaining
    and remaining > 0 then

        return os.time() + remaining
    end

    return 0
end

function GAG2WildPetNetworkGetRowTimerSeconds(rowData)

    local expiresAt =
        GAG2WildPetNetworkGetRowExpiresAt(
            rowData
        )

    if not expiresAt
    or expiresAt <= 0 then
        return 0
    end

    return math.max(
        0,
        math.floor(
            expiresAt - os.time()
        )
    )
end

function GAG2WildPetNetworkRegisterTimerRow(timerLabel, rowFrame, rowData)

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    state.TimerRows =
        type(state.TimerRows) == "table"
        and state.TimerRows
        or {}

    if typeof(timerLabel) ~= "Instance"
    or typeof(rowFrame) ~= "Instance" then

        return false
    end

    local expiresAt =
        GAG2WildPetNetworkGetRowExpiresAt(
            rowData
        )

    if not expiresAt
    or expiresAt <= 0 then
        return false
    end

    state.TimerRows[timerLabel] = {
        Label = timerLabel,
        Row = rowFrame,
        ExpiresAt = expiresAt,
    }

    return true
end

function GAG2WildPetNetworkUpdateLocalTimers()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    state.TimerRows =
        type(state.TimerRows) == "table"
        and state.TimerRows
        or {}

    local now =
        os.time()

    for timerLabel, record in pairs(state.TimerRows) do

        local labelAlive =
            typeof(timerLabel) == "Instance"
            and timerLabel.Parent ~= nil

        local row =
            type(record) == "table"
            and record.Row
            or nil

        local rowAlive =
            typeof(row) == "Instance"
            and row.Parent ~= nil

        if labelAlive ~= true
        or rowAlive ~= true then

            state.TimerRows[timerLabel] =
                nil

            continue
        end

        local expiresAt =
            tonumber(record.ExpiresAt)
            or 0

        local remaining =
            math.max(
                0,
                math.floor(
                    expiresAt - now
                )
            )

        pcall(function()

            timerLabel.Text =
                GAG2WildPetNetworkFormatSeconds(
                    remaining
                )
        end)

        if remaining <= 0 then

            state.TimerRows[timerLabel] =
                nil

            pcall(function()

                row:Destroy()
            end)
        end
    end
end

function GAG2WildPetNetworkStartCountdownLoop(token)

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    token =
        tonumber(token)
        or tonumber(state.LoopToken)
        or 0

    if state.CountdownRunning == true
    and tonumber(state.CountdownToken) == token then

        return true
    end

    state.CountdownRunning =
        true

    state.CountdownToken =
        token

    task.spawn(function()

        while state.Enabled == true
        and state.Running == true
        and tonumber(state.LoopToken) == token do

            GAG2WildPetNetworkUpdateLocalTimers()

            task.wait(
                1
            )
        end

        if tonumber(state.CountdownToken) == token then

            state.CountdownRunning =
                false
        end
    end)

    return true
end


function GAG2WildPetNetworkCreateServerRow(
    parent,
    rowData
)

    if type(rowData) ~= "table" then
        return nil
    end

    local jobId =
        CleanText(
            rowData.jobId
            or rowData.JobId
        )

    local placeId =
        tonumber(
            rowData.placeId
            or rowData.PlaceId
        )

    if jobId == ""
    or not placeId
    or placeId <= 0 then
        return nil
    end

    local players =
        math.max(
            0,
            math.floor(
                tonumber(rowData.players)
                or 0
            )
        )

    local maxPlayers =
        math.max(
            0,
            math.floor(
                tonumber(rowData.maxPlayers)
                or 0
            )
        )

    local timerSeconds =
        GAG2WildPetNetworkGetRowTimerSeconds(
            rowData
        )

    local count =
        math.max(
            1,
            math.floor(
                tonumber(rowData.count)
                or 1
            )
        )

    local row =
        Instance.new("Frame")

    row.Name =
        "ServerRow"

    row.Size =
        UDim2.new(
            1,
            0,
            0,
            27
        )

    row.BackgroundColor3 =
        Color3.fromRGB(
            12,
            20,
            31
        )

    row.BackgroundTransparency =
        0.18

    row.BorderSizePixel =
        0

    row.Parent =
        parent

    GAG2WildPetNetworkAddCorner(
        row,
        6
    )

    local rowStroke =
        Instance.new("UIStroke")

    rowStroke.Color =
        Color3.fromRGB(
            35,
            50,
            72
        )

    rowStroke.Thickness =
        1

    rowStroke.Transparency =
        0.58

    rowStroke.Parent =
        row

    local idLabel =
        Instance.new("TextLabel")

    idLabel.Name =
        "JobId"

    idLabel.Position =
        UDim2.fromOffset(
            10,
            0
        )

    idLabel.Size =
        UDim2.new(
            0,
            88,
            1,
            0
        )

    idLabel.BackgroundTransparency =
        1

    idLabel.Font =
        Enum.Font.Code

    idLabel.Text =
        jobId:sub(1, 8)

    idLabel.TextSize =
        11

    idLabel.TextColor3 =
        Color3.fromRGB(
            203,
            213,
            225
        )

    idLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    idLabel.Parent =
        row

    local playersLabel =
        Instance.new("TextLabel")

    playersLabel.Name =
        "Players"

    playersLabel.Position =
        UDim2.fromOffset(
            110,
            0
        )

    playersLabel.Size =
        UDim2.new(
            0,
            46,
            1,
            0
        )

    playersLabel.BackgroundTransparency =
        1

    playersLabel.Font =
        Enum.Font.Code

    playersLabel.Text =
        tostring(players)
        .. "/"
        .. tostring(maxPlayers)

    playersLabel.TextSize =
        11

    playersLabel.TextColor3 =
        Color3.fromRGB(
            148,
            163,
            184
        )

    playersLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    playersLabel.Parent =
        row

    local timerLabel =
        Instance.new("TextLabel")

    timerLabel.Name =
        "Timer"

    timerLabel.Position =
        UDim2.fromOffset(
            166,
            0
        )

    timerLabel.Size =
        UDim2.new(
            0,
            68,
            1,
            0
        )

    timerLabel.BackgroundTransparency =
        1

    timerLabel.Font =
        Enum.Font.Code

    timerLabel.Text =
        GAG2WildPetNetworkFormatSeconds(
            timerSeconds
        )

    timerLabel.TextSize =
        11

    timerLabel.TextColor3 =
        Color3.fromRGB(
            203,
            213,
            225
        )

    timerLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    timerLabel.Parent =
        row

    GAG2WildPetNetworkRegisterTimerRow(
        timerLabel,
        row,
        rowData
    )

    local countLabel =
        Instance.new("TextLabel")

    countLabel.Name =
        "Count"

    countLabel.Position =
        UDim2.fromOffset(
            244,
            0
        )

    countLabel.Size =
        UDim2.new(
            0,
            34,
            1,
            0
        )

    countLabel.BackgroundTransparency =
        1

    countLabel.Font =
        Enum.Font.Code

    countLabel.Text =
        "x"
        .. tostring(count)

    countLabel.TextSize =
        11

    countLabel.TextColor3 =
        Color3.fromRGB(
            148,
            163,
            184
        )

    countLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    countLabel.Parent =
        row

    local joinButton =
        Instance.new("TextButton")

    joinButton.Name =
        "Join"

    joinButton.AnchorPoint =
        Vector2.new(
            1,
            0.5
        )

    joinButton.Position =
        UDim2.new(
            1,
            -8,
            0.5,
            0
        )

    joinButton.Size =
        UDim2.fromOffset(
            55,
            20
        )

    joinButton.BackgroundColor3 =
        Color3.fromRGB(
            8,
            53,
            28
        )

    joinButton.BackgroundTransparency =
        0.06

    joinButton.BorderSizePixel =
        0

    joinButton.AutoButtonColor =
        true

    joinButton.Font =
        Enum.Font.GothamBold

    joinButton.Text =
        "Join"

    joinButton.TextSize =
        11

    joinButton.TextColor3 =
        Color3.fromRGB(
            74,
            222,
            128
        )

    joinButton.Parent =
        row

    GAG2WildPetNetworkAddCorner(
        joinButton,
        6
    )

    local joinStroke =
        Instance.new("UIStroke")

    joinStroke.Color =
        Color3.fromRGB(
            34,
            197,
            94
        )

    joinStroke.Thickness =
        1

    joinStroke.Transparency =
        0.25

    joinStroke.Parent =
        joinButton

    joinButton.MouseButton1Click:Connect(function()

        local joinPayload =
            {}

        if type(rowData) == "table" then

            for key, value in pairs(rowData) do

                joinPayload[key] =
                    value
            end
        end

        joinPayload.placeId =
            placeId

        joinPayload.jobId =
            jobId

        joinPayload.petName =
            CleanText(
                rowData.petName
                or rowData.PetName
            )

        joinPayload.rarity =
            CleanText(
                rowData.rarity
                or rowData.Rarity
            )

        joinPayload.scoutUserId =
            GAG2WildPetNetworkGetScoutUserId(
                rowData
            )

        joinPayload.scoutName =
            GAG2WildPetNetworkGetScoutName(
                rowData
            )

        GAG2WildPetNetworkJoinServer(
            joinPayload
        )
    end)

    return row
end

function GAG2WildPetNetworkCreatePetSection(
    parent,
    petName,
    rarity,
    rows
)

    rows =
        type(rows) == "table"
        and rows
        or {}

    local section =
        Instance.new("Frame")

    section.Name =
        "PetSection"

    section.Size =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    section.AutomaticSize =
        Enum.AutomaticSize.Y

    section.BackgroundTransparency =
        1

    section.Parent =
        parent

    local sectionLayout =
        Instance.new("UIListLayout")

    sectionLayout.FillDirection =
        Enum.FillDirection.Vertical

    sectionLayout.HorizontalAlignment =
        Enum.HorizontalAlignment.Left

    sectionLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    sectionLayout.Padding =
        UDim.new(
            0,
            3
        )

    sectionLayout.Parent =
        section

    local header =
        Instance.new("Frame")

    header.Name =
        "Header"

    header.Size =
        UDim2.new(
            1,
            0,
            0,
            23
        )

    header.BackgroundTransparency =
        1

    header.Parent =
        section

    local accent =
        Instance.new("Frame")

    accent.Name =
        "Accent"

    accent.Position =
        UDim2.fromOffset(
            0,
            5
        )

    accent.Size =
        UDim2.new(
            0,
            3,
            0,
            13
        )

    accent.BackgroundColor3 =
        GAG2WildPetNetworkGetRarityColor3(
            rarity
        )

    accent.BorderSizePixel =
        0

    accent.Parent =
        header

    GAG2WildPetNetworkAddCorner(
        accent,
        3
    )

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.Position =
        UDim2.fromOffset(
            10,
            0
        )

    title.Size =
        UDim2.new(
            1,
            -90,
            1,
            0
        )

    title.BackgroundTransparency =
        1

    title.Font =
        Enum.Font.GothamBold

    title.RichText =
        true

    title.Text =
        '<b>'
        .. GAG2WildPetNetworkCleanDisplay(
            petName
        )
        .. '</b>  <font color="'
        .. GAG2WildPetNetworkGetRarityColor(
            rarity
        )
        .. '">['
        .. GAG2WildPetNetworkCleanDisplay(
            rarity
        )
        .. ']</font>'

    title.TextSize =
        12

    title.TextColor3 =
        Color3.fromRGB(
            241,
            245,
            249
        )

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextYAlignment =
        Enum.TextYAlignment.Center

    title.Parent =
        header

    local resultCount =
        Instance.new("TextLabel")

    resultCount.Name =
        "ResultCount"

    resultCount.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    resultCount.Position =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    resultCount.Size =
        UDim2.new(
            0,
            80,
            1,
            0
        )

    resultCount.BackgroundTransparency =
        1

    resultCount.Font =
        Enum.Font.Code

    resultCount.Text =
        tostring(#rows)
        .. " "
        .. (
            #rows == 1
            and "server"
            or "servers"
        )

    resultCount.TextSize =
        11

    resultCount.TextColor3 =
        Color3.fromRGB(
            96,
            165,
            250
        )

    resultCount.TextXAlignment =
        Enum.TextXAlignment.Right

    resultCount.TextYAlignment =
        Enum.TextYAlignment.Center

    resultCount.Parent =
        header

    if #rows <= 0 then

        local empty =
            Instance.new("TextLabel")

        empty.Name =
            "Empty"

        empty.Size =
            UDim2.new(
                1,
                0,
                0,
                20
            )

        empty.BackgroundTransparency =
            1

        empty.Font =
            Enum.Font.Code

        empty.Text =
            "(no server found)"

        empty.TextSize =
            11

        empty.TextColor3 =
            Color3.fromRGB(
                148,
                163,
                184
            )

        empty.TextXAlignment =
            Enum.TextXAlignment.Left

        empty.Parent =
            section

        return section
    end

    for _, rowData in ipairs(rows) do

        GAG2WildPetNetworkCreateServerRow(
            section,
            rowData
        )
    end

    return section
end

function GAG2WildPetNetworkClearRows()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    state.TimerRows =
        {}

    local scroll =
        state.Scroll

    if not scroll then
        return
    end

    for _, child in ipairs(
        scroll:GetChildren()
    ) do

        child:Destroy()
    end

    local layout =
        Instance.new("UIListLayout")

    layout.Name =
        "Layout"

    layout.Padding =
        UDim.new(
            0,
            5
        )

    layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    layout.Parent =
        scroll

    local padding =
        Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(
            0,
            0
        )

    padding.PaddingRight =
        UDim.new(
            0,
            0
        )

    padding.PaddingTop =
        UDim.new(
            0,
            2
        )

    padding.PaddingBottom =
        UDim.new(
            0,
            6
        )

    padding.Parent =
        scroll
end

function GAG2WildPetNetworkJoinServer(rowData)

    if type(rowData) ~= "table" then

        GAG2WildPetNetworkSetStatus(
            "Invalid server row."
        )

        return false
    end

    local placeId =
        tonumber(
            rowData.placeId
            or rowData.PlaceId
        )

    local jobId =
        CleanText(
            rowData.jobId
            or rowData.JobId
        )

    local scoutUserId =
        GAG2WildPetNetworkGetScoutUserId(
            rowData
        )

    local scoutName =
        GAG2WildPetNetworkGetScoutName(
            rowData
        )

    if not placeId
    or placeId <= 0
    or jobId == "" then

        GAG2WildPetNetworkSetStatus(
            "Server row has invalid join data."
        )

        return false
    end

    if placeId == tonumber(game.PlaceId)
    and jobId == tostring(game.JobId) then

        GAG2WildPetNetworkSetStatus(
            "Already in this server."
        )

        Notify(
            "Live Wild Pets",
            "You are already in this server.",
            3
        )

        return false
    end

    if type(GAG2CancelServerHop) == "function" then

        GAG2CancelServerHop()
    end

    GAG2ClearExactJoinTarget(
        "new live wild pet HUD join"
    )

    GAG2_EXACT_JOIN_STATE.Retrying =
        false

    print(
        "[HOLY WILD PET JOIN]",
        "clicked row",
        "| place:",
        tostring(placeId),
        "| job:",
        tostring(jobId),
        "| scoutUserId:",
        tostring(scoutUserId),
        "| scoutName:",
        tostring(scoutName ~= "" and scoutName or "unknown")
    )

    if scoutUserId > 0 then

        GAG2WildPetNetworkSetStatus(
            "Trying player-id join via scout "
            .. tostring(
                scoutName ~= ""
                and scoutName
                or scoutUserId
            )
            .. "..."
        )

        local ok, errorText =
            GAG2QueuePlayerIdJoin(
                scoutUserId,
                placeId,
                jobId,
                "live wild pet HUD scout lookup"
            )

        if ok ~= true then

            GAG2WildPetNetworkSetStatus(
                "Player-id join failed: "
                .. tostring(errorText)
            )

            Notify(
                "Join Failed",
                tostring(errorText),
                5
            )

            return false
        end

        return true
    end

    GAG2WildPetNetworkSetStatus(
        "No scoutUserId. Exact joining "
        .. tostring(jobId:sub(1, 8))
        .. "..."
    )

    GAG2SaveExactJoinTarget(
        placeId,
        jobId,
        0,
        "live wild pet HUD no scoutUserId"
    )

    SetStatus(
        "Joining live wild pet server..."
    )

    local ok, errorText =
        GAG2QueueExactJoin(
            placeId,
            jobId,
            "live wild pet HUD no scoutUserId"
        )

    if ok ~= true then

        GAG2ClearExactJoinTarget(
            "wild pet HUD join failed"
        )

        GAG2WildPetNetworkSetStatus(
            "Join failed: "
            .. tostring(errorText)
        )

        Notify(
            "Join Failed",
            tostring(errorText),
            5
        )

        return false
    end

    return true
end

function GAG2WildPetNetworkRender(data)

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    local scroll =
        state.Scroll

    if not scroll then
        return false
    end

    GAG2WildPetNetworkClearRows()

    local grouped =
        type(data) == "table"
        and data.grouped
        or nil

    if type(grouped) ~= "table" then

        GAG2WildPetNetworkCreateLabel(
            scroll,
            "NoData",
            "No live network data.",
            30,
            13,
            false
        )

        return false
    end

    local petGroups =
        {}

    local totalResults =
        0

    for petName, servers in pairs(grouped) do

        if type(servers) == "table" then

            local validRows =
                {}

            local rarity =
                "Unknown"

            for _, row in ipairs(servers) do

                if type(row) == "table" then

                    local jobId =
                        CleanText(
                            row.jobId
                            or row.JobId
                        )

                    local placeId =
                        tonumber(
                            row.placeId
                            or row.PlaceId
                        )

                    if jobId ~= ""
                    and placeId
                    and placeId > 0 then

                        if CleanText(
                            row.rarity
                            or row.Rarity
                        ) ~= "" then

                            rarity =
                                tostring(
                                    row.rarity
                                    or row.Rarity
                                )
                        end

                        row.petName =
                            tostring(petName)

                        row.rarity =
                            tostring(rarity)

                        table.insert(
                            validRows,
                            row
                        )
                    end
                end
            end

            if #validRows > 0 then

                totalResults =
                    totalResults + #validRows

                table.insert(petGroups, {
                    PetName =
                        tostring(petName),

                    Rarity =
                        tostring(rarity),

                    Rows =
                        validRows,
                })
            end
        end
    end

    table.sort(petGroups, function(a, b)

        local aRank =
            GAG2WildPetNetworkGetRarityRank(
                a.Rarity
            )

        local bRank =
            GAG2WildPetNetworkGetRarityRank(
                b.Rarity
            )

        if aRank ~= bRank then
            return aRank > bRank
        end

        return tostring(a.PetName)
            < tostring(b.PetName)
    end)

    if state.SummaryLabel then

        pcall(function()

            state.SummaryLabel.Text =
                tostring(
                    state.LastServerCount
                    or 0
                )
                .. " live server(s)  •  "
                .. tostring(#petGroups)
                .. " pet(s)  •  "
                .. tostring(totalResults)
                .. " results"
        end)
    end

    if #petGroups <= 0 then

        GAG2WildPetNetworkCreateLabel(
            scroll,
            "NoServers",
            "No live wild pets reported.",
            32,
            13,
            false
        )

        return true
    end

    local renderedRows =
        0

    local maxRows =
        math.max(
            10,
            math.floor(
                tonumber(state.MaxRenderedRows)
                or 80
            )
        )

    for _, group in ipairs(petGroups) do

        if renderedRows >= maxRows then
            break
        end

        local limitedRows =
            {}

        for _, row in ipairs(group.Rows) do

            if renderedRows >= maxRows then
                break
            end

            table.insert(
                limitedRows,
                row
            )

            renderedRows =
                renderedRows + 1
        end

        GAG2WildPetNetworkCreatePetSection(
            scroll,
            group.PetName,
            group.Rarity,
            limitedRows
        )
    end

    if totalResults > renderedRows then

        GAG2WildPetNetworkCreateLabel(
            scroll,
            "RowLimit",
            "Showing first "
            .. tostring(renderedRows)
            .. " rows.",
            24,
            11,
            false
        )
    end

    return true
end

function GAG2WildPetNetworkRefresh(reason)

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    if state.Enabled ~= true then
        return false
    end

    if state.Refreshing == true then
        return false
    end

    state.Refreshing =
        true

    if tostring(reason or "") ~= "automatic" then

        GAG2WildPetNetworkSetStatus(
            "Refreshing..."
        )
    end

    task.spawn(function()

        local data, errorText =
            GAG2WildPetNetworkRequest({
                action =
                    "GetLiveWildPets",

                placeId =
                    tostring(
                        GROW_A_GARDEN_2_PLACE_ID
                    ),

                minimumRemaining =
                    1,
            })

        state.Refreshing =
            false

        if state.Enabled ~= true then
            return
        end

        if not data then

            GAG2WildPetNetworkSetStatus(
                "Refresh failed: "
                .. tostring(errorText)
            )

            return
        end

        state.LastData =
            data

        state.LastRefreshAt =
            os.time()

        state.LastServerCount =
            math.max(
                0,
                math.floor(
                    tonumber(data.serverCount)
                    or 0
                )
            )

        state.LastPetCount =
            math.max(
                0,
                math.floor(
                    tonumber(data.petCount)
                    or 0
                )
            )

        if state.SummaryLabel then

            pcall(function()

                state.SummaryLabel.Text =
                    tostring(state.LastServerCount)
                    .. " live server(s)  •  "
                    .. tostring(state.LastPetCount)
                    .. " pet(s)"
            end)
        end

        local renderOk, renderError =
            pcall(function()

                GAG2WildPetNetworkRender(
                    data
                )
            end)

        if renderOk ~= true then

            GAG2WildPetNetworkSetStatus(
                "Render failed: "
                .. tostring(renderError)
            )

            return
        end

        GAG2WildPetNetworkSetStatus(
            "Updated"
            .. (
                reason
                and " | " .. tostring(reason)
                or ""
            )
        )
    end)

    return true
end

function GAG2WildPetNetworkDestroyHudOnly()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    if state.Gui then

        pcall(function()

            state.Gui:Destroy()
        end)
    end

    state.Gui =
        nil

    state.Frame =
        nil

    state.SummaryLabel =
        nil

    state.StatusLabel =
        nil

    state.Scroll =
        nil
end

function GAG2WildPetNetworkGetHudSize(mode)

    mode =
        CleanText(mode)

    if mode == "Medium" then

        return 520,
            390
    end

    if mode == "Large" then

        return 680,
            500
    end

    return 430,
        315
end

function GAG2WildPetNetworkApplyHudLayout()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    local frame =
        state.Frame

    if not frame then
        return
    end

    if CleanText(state.HudMode) ~= "Medium"
    and CleanText(state.HudMode) ~= "Large" then

        state.HudMode =
            "Small"
    end

    local width, height =
        GAG2WildPetNetworkGetHudSize(
            state.HudMode
        )

    if state.HudMinimized == true then

        frame.Size =
            UDim2.fromOffset(
                280,
                44
            )

    else

        frame.Size =
            UDim2.fromOffset(
                width,
                height
            )
    end

    local visible =
        state.HudMinimized ~= true

    local objects = {
        state.SummaryLabel,
        state.Scroll,
        state.StatusLabel,
        state.TopLine,
        state.StatusLine,
    }

    for _, object in ipairs(objects) do

        if object then

            pcall(function()

                object.Visible =
                    visible
            end)
        end
    end

    if state.MinimizeButton then

        state.MinimizeButton.Text =
            state.HudMinimized == true
            and "+"
            or "−"
    end

    if state.SizeButton then

        state.SizeButton.Visible =
            visible

        state.SizeButton.Text =
            state.HudMode == "Large"
            and "L"
            or (
                state.HudMode == "Medium"
                and "M"
                or "S"
            )
    end

    if state.RefreshButton then

        state.RefreshButton.Visible =
            visible
    end
end

function GAG2WildPetNetworkCycleHudSize()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    if state.HudMode == "Small" then

        state.HudMode =
            "Medium"

    elseif state.HudMode == "Medium" then

        state.HudMode =
            "Large"

    else

        state.HudMode =
            "Small"
    end

    state.HudMinimized =
        false

    GAG2WildPetNetworkApplyHudLayout()
end

function GAG2WildPetNetworkToggleMinimized()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    state.HudMinimized =
        state.HudMinimized ~= true

    GAG2WildPetNetworkApplyHudLayout()
end

function GAG2WildPetNetworkCreateHud()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    if state.Gui
    and state.Gui.Parent then

        return state.Gui
    end

    local parent =
        GAG2WildPetNetworkGetParent()

    if not parent then

        GAG2WildPetNetworkSetStatus(
            "HUD parent unavailable."
        )

        return nil
    end

    local old =
        parent:FindFirstChild(
            "HolyGAG2LiveWildPetNetwork"
        )

    if old then

        pcall(function()

            old:Destroy()
        end)
    end

    state.HudMode =
        CleanText(state.HudMode) ~= ""
        and state.HudMode
        or "Small"

    state.HudMinimized =
        state.HudMinimized == true

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "HolyGAG2LiveWildPetNetwork"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    gui.Parent =
        parent

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Main"

    frame.Position =
        UDim2.new(
            0,
            18,
            0,
            92
        )

    frame.Size =
        UDim2.fromOffset(
            430,
            315
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(
            7,
            13,
            22
        )

    frame.BackgroundTransparency =
        0.24

    frame.BorderSizePixel =
        0

    frame.Active =
        true

    frame.Draggable =
        true

    frame.Parent =
        gui

    GAG2WildPetNetworkAddCorner(
        frame,
        10
    )

    local frameStroke =
        Instance.new("UIStroke")

    frameStroke.Color =
        Color3.fromRGB(
            59,
            130,
            246
        )

    frameStroke.Thickness =
        1

    frameStroke.Transparency =
        0.45

    frameStroke.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.Position =
        UDim2.fromOffset(
            14,
            7
        )

    title.Size =
        UDim2.new(
            1,
            -125,
            0,
            24
        )

    title.BackgroundTransparency =
        1

    title.Font =
        Enum.Font.GothamBold

    title.Text =
        "HOLY • LIVE WILD PETS"

    title.TextSize =
        13

    title.TextColor3 =
        Color3.fromRGB(
            241,
            245,
            249
        )

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.Parent =
        frame

    local sizeButton =
        Instance.new("TextButton")

    sizeButton.Name =
        "Size"

    sizeButton.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    sizeButton.Position =
        UDim2.new(
            1,
            -91,
            0,
            8
        )

    sizeButton.Size =
        UDim2.fromOffset(
            24,
            22
        )

    sizeButton.BackgroundColor3 =
        Color3.fromRGB(
            12,
            22,
            35
        )

    sizeButton.BackgroundTransparency =
        0.08

    sizeButton.BorderSizePixel =
        0

    sizeButton.Font =
        Enum.Font.GothamBold

    sizeButton.Text =
        "S"

    sizeButton.TextSize =
        11

    sizeButton.TextColor3 =
        Color3.fromRGB(
            96,
            165,
            250
        )

    sizeButton.Parent =
        frame

    GAG2WildPetNetworkAddCorner(
        sizeButton,
        6
    )

    sizeButton.MouseButton1Click:Connect(function()

        GAG2WildPetNetworkCycleHudSize()
    end)

    local refreshButton =
        Instance.new("TextButton")

    refreshButton.Name =
        "Refresh"

    refreshButton.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    refreshButton.Position =
        UDim2.new(
            1,
            -62,
            0,
            8
        )

    refreshButton.Size =
        UDim2.fromOffset(
            24,
            22
        )

    refreshButton.BackgroundColor3 =
        Color3.fromRGB(
            12,
            22,
            35
        )

    refreshButton.BackgroundTransparency =
        0.08

    refreshButton.BorderSizePixel =
        0

    refreshButton.Font =
        Enum.Font.GothamBold

    refreshButton.Text =
        "↻"

    refreshButton.TextSize =
        13

    refreshButton.TextColor3 =
        Color3.fromRGB(
            96,
            165,
            250
        )

    refreshButton.Parent =
        frame

    GAG2WildPetNetworkAddCorner(
        refreshButton,
        6
    )

    refreshButton.MouseButton1Click:Connect(function()

        GAG2WildPetNetworkRefresh(
            "manual"
        )
    end)

    local minimizeButton =
        Instance.new("TextButton")

    minimizeButton.Name =
        "Minimize"

    minimizeButton.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    minimizeButton.Position =
        UDim2.new(
            1,
            -33,
            0,
            8
        )

    minimizeButton.Size =
        UDim2.fromOffset(
            24,
            22
        )

    minimizeButton.BackgroundTransparency =
        1

    minimizeButton.Font =
        Enum.Font.GothamBold

    minimizeButton.Text =
        "−"

    minimizeButton.TextSize =
        16

    minimizeButton.TextColor3 =
        Color3.fromRGB(
            148,
            163,
            184
        )

    minimizeButton.Parent =
        frame

    minimizeButton.MouseButton1Click:Connect(function()

        GAG2WildPetNetworkToggleMinimized()
    end)

    local closeButton =
        Instance.new("TextButton")

    closeButton.Name =
        "Close"

    closeButton.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    closeButton.Position =
        UDim2.new(
            1,
            -8,
            0,
            8
        )

    closeButton.Size =
        UDim2.fromOffset(
            24,
            22
        )

    closeButton.BackgroundTransparency =
        1

    closeButton.Font =
        Enum.Font.GothamBold

    closeButton.Text =
        "×"

    closeButton.TextSize =
        16

    closeButton.TextColor3 =
        Color3.fromRGB(
            148,
            163,
            184
        )

    closeButton.Parent =
        frame

    closeButton.MouseButton1Click:Connect(function()

        if GAG2_WILD_PET_NETWORK_HUD_TOGGLE
        and type(GAG2_WILD_PET_NETWORK_HUD_TOGGLE.SetValue) == "function" then

            GAG2_WILD_PET_NETWORK_HUD_TOGGLE:SetValue(
                false
            )

        else

            GAG2WildPetNetworkSetEnabled(
                false
            )
        end
    end)

    local summary =
        Instance.new("TextLabel")

    summary.Name =
        "Summary"

    summary.Position =
        UDim2.fromOffset(
            14,
            32
        )

    summary.Size =
        UDim2.new(
            1,
            -28,
            0,
            20
        )

    summary.BackgroundTransparency =
        1

    summary.Font =
        Enum.Font.Code

    summary.Text =
        "Loading live servers..."

    summary.TextSize =
        11

    summary.TextColor3 =
        Color3.fromRGB(
            148,
            163,
            184
        )

    summary.TextXAlignment =
        Enum.TextXAlignment.Left

    summary.Parent =
        frame

    local topLine =
        Instance.new("Frame")

    topLine.Name =
        "TopLine"

    topLine.Position =
        UDim2.new(
            0,
            12,
            0,
            57
        )

    topLine.Size =
        UDim2.new(
            1,
            -24,
            0,
            1
        )

    topLine.BackgroundColor3 =
        Color3.fromRGB(
            30,
            41,
            59
        )

    topLine.BackgroundTransparency =
        0.38

    topLine.BorderSizePixel =
        0

    topLine.Parent =
        frame

    local scroll =
        Instance.new("ScrollingFrame")

    scroll.Name =
        "ServerList"

    scroll.Position =
        UDim2.fromOffset(
            14,
            64
        )

    scroll.Size =
        UDim2.new(
            1,
            -28,
            1,
            -103
        )

    scroll.BackgroundTransparency =
        1

    scroll.BorderSizePixel =
        0

    scroll.ScrollBarThickness =
        3

    scroll.ScrollBarImageColor3 =
        Color3.fromRGB(
            59,
            130,
            246
        )

    scroll.CanvasSize =
        UDim2.new()

    scroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    scroll.Parent =
        frame

    local statusLine =
        Instance.new("Frame")

    statusLine.Name =
        "StatusLine"

    statusLine.Position =
        UDim2.new(
            0,
            12,
            1,
            -34
        )

    statusLine.Size =
        UDim2.new(
            1,
            -24,
            0,
            1
        )

    statusLine.BackgroundColor3 =
        Color3.fromRGB(
            30,
            41,
            59
        )

    statusLine.BackgroundTransparency =
        0.42

    statusLine.BorderSizePixel =
        0

    statusLine.Parent =
        frame

    local status =
        Instance.new("TextLabel")

    status.Name =
        "Status"

    status.Position =
        UDim2.new(
            0,
            14,
            1,
            -28
        )

    status.Size =
        UDim2.new(
            1,
            -28,
            0,
            18
        )

    status.BackgroundTransparency =
        1

    status.Font =
        Enum.Font.Code

    status.Text =
        tostring(state.LastStatus or "Starting...")

    status.TextSize =
        10

    status.TextColor3 =
        Color3.fromRGB(
            96,
            165,
            250
        )

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.Parent =
        frame

    state.Gui =
        gui

    state.Frame =
        frame

    state.SummaryLabel =
        summary

    state.StatusLabel =
        status

    state.Scroll =
        scroll

    state.TopLine =
        topLine

    state.StatusLine =
        statusLine

    state.SizeButton =
        sizeButton

    state.RefreshButton =
        refreshButton

    state.MinimizeButton =
        minimizeButton

    state.CloseButton =
        closeButton

    if type(state.LastData) == "table" then

        GAG2WildPetNetworkRender(
            state.LastData
        )

    else

        GAG2WildPetNetworkClearRows()

        GAG2WildPetNetworkCreateLabel(
            scroll,
            "Loading",
            "Loading network reports...",
            28,
            12,
            false
        )
    end

    GAG2WildPetNetworkApplyHudLayout()
    GAG2WildPetNetworkRefreshStatus()

    return gui
end

function GAG2WildPetNetworkStart()

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    if CleanText(GAG2_WILD_PET_NETWORK_API_KEY) == ""
    or CleanText(GAG2_WILD_PET_NETWORK_API_KEY) == "PASTE_CONFIG_B2_KEY_HERE" then

        state.Enabled =
            false

        state.Running =
            false

        GAG2WildPetNetworkSetStatus(
            "Hard-coded API key is missing."
        )

        Notify(
            "Live Wild Pets",
            "Paste Config B2 into GAG2_WILD_PET_NETWORK_API_KEY.",
            6
        )

        return false
    end

    state.Enabled =
        true

    GAG2WildPetNetworkCreateHud()

    if state.Running == true then

        GAG2WildPetNetworkRefresh(
            "reopened"
        )

        return true
    end

    state.Running =
        true

    state.LoopToken =
        tonumber(state.LoopToken)
        or 0

    state.LoopToken =
        state.LoopToken + 1

    local token =
        state.LoopToken

    state.RefreshSeconds =
        math.clamp(
            tonumber(state.RefreshSeconds)
            or 8,
            5,
            30
        )

    GAG2WildPetNetworkSetStatus(
        "Starting..."
    )

    GAG2WildPetNetworkRefresh(
        "startup"
    )

    GAG2WildPetNetworkStartCountdownLoop(
        token
    )

    task.spawn(function()

        while state.Enabled == true
        and state.Running == true
        and state.LoopToken == token do

            task.wait(
                math.clamp(
                    tonumber(state.RefreshSeconds)
                    or 8,
                    5,
                    30
                )
            )

            if state.Enabled == true
            and state.Running == true
            and state.LoopToken == token then

                GAG2WildPetNetworkRefresh(
                    "automatic"
                )
            end
        end
    end)

    return true
end

function GAG2WildPetNetworkStop(skipDirty)

    local state =
        GAG2_WILD_PET_NETWORK_STATE

    state.Enabled =
        false

    state.Running =
        false

    state.Refreshing =
        false

    state.CountdownRunning =
        false

    state.CountdownToken =
        0

    state.TimerRows =
        {}

    state.LoopToken =
        tonumber(state.LoopToken)
        or 0

    state.LoopToken =
        state.LoopToken + 1

    state.LastStatus =
        "Disabled."

    GAG2WildPetNetworkDestroyHudOnly()
    GAG2WildPetNetworkRefreshStatus()

    if skipDirty ~= true then

        MarkConfigDirty()
    end
end

function GAG2WildPetNetworkSetEnabled(value)

    local enabled =
        value == true

    GAG2_WILD_PET_NETWORK_STATE.Enabled =
        enabled

    if ConfigState.Loading == true then
        return
    end

    if enabled == true then

        GAG2WildPetNetworkStart()

    else

        GAG2WildPetNetworkStop(
            true
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreWildPetNetworkState()

    task.defer(function()

        local enabled =
            false

        if Toggles.HolyGAG2WildPetNetworkHud then

            enabled =
                Toggles.HolyGAG2WildPetNetworkHud.Value == true
        end

        GAG2_WILD_PET_NETWORK_STATE.Enabled =
            enabled

        if enabled == true then

            GAG2WildPetNetworkStart()

        else

            GAG2WildPetNetworkRefreshStatus()
        end
    end)
end

GAG2_WILD_PET_NETWORK_STATE.Destroy =
    function()

        GAG2WildPetNetworkStop(
            true
        )
    end

--==================================================
-- [4.126] LIVE WILD PET NETWORK CONTRIBUTOR
--
-- Reports the current server's WildPetRef data.
-- This is what makes normal users/scout alts feed the HUD.
--==================================================

GAG2_WILD_PET_NETWORK_CONTRIBUTE_TOGGLE =
    GAG2_WILD_PET_NETWORK_CONTRIBUTE_TOGGLE
    or nil

GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE =
    GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE
    or {
        Enabled = false,
        Running = false,
        Sending = false,
        Pending = false,

        LoopToken = 0,
        HeartbeatSeconds = 1,
        ClaimRefreshSeconds = 5,

        LastReportAt = 0,
        LastClaimAt = 0,
        LastPetCount = 0,
        LastPetSummary = "none",
        LastStatus = "Disabled.",
        LastClaimStatus = "not claimed",

        Connections = {},
        RefConnections = {},
    }

function GAG2WildPetNetworkContributorSetStatus(text)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2WildPetNetworkContributorStatus then

        Options.HolyGAG2WildPetNetworkContributorStatus:SetText(
            GAG2WildPetNetworkContributorBuildStatusText()
        )
    end
end

function GAG2WildPetNetworkContributorBuildStatusText()

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    local reportAge =
        "Never"

    if tonumber(state.LastReportAt or 0) > 0 then

        reportAge =
            tostring(
                math.max(
                    0,
                    os.time()
                    - tonumber(state.LastReportAt)
                )
            )
            .. "s ago"
    end

    return '<font color="rgb(196,181,253)"><b>Network Contributor</b></font>'
        .. '\nEnabled: '
        .. (
            state.Enabled == true
            and "YES"
            or "NO"
        )
        .. ' | Last report: '
        .. reportAge
        .. '\nCurrent pets: '
        .. tostring(state.LastPetCount or 0)
        .. ' | '
        .. tostring(state.LastPetSummary or "none")
        .. '\nClaim: '
        .. tostring(state.LastClaimStatus or "not claimed")
        .. '\nStatus: '
        .. tostring(state.LastStatus or "Idle.")
end

function GAG2WildPetNetworkDisconnect(connection)

    if connection then

        pcall(function()

            connection:Disconnect()
        end)
    end
end

function GAG2WildPetNetworkGetWildPetRefFolder()

    local map =
        workspace:FindFirstChild(
            "Map"
        )

    if not map then
        return nil
    end

    return map:FindFirstChild(
        "WildPetRef"
    )
end

function GAG2WildPetNetworkReadRefPet(ref)

    if typeof(ref) ~= "Instance" then
        return nil
    end

    local petName =
        CleanText(
            ref:GetAttribute("PetName")
        )

    if petName == "" then
        return nil
    end

    local state =
        CleanText(
            ref:GetAttribute("State")
        ):lower()

    local ownerUserId =
        tonumber(
            ref:GetAttribute("OwnerUserId")
        )
        or 0

    local spawnedAt =
        tonumber(
            ref:GetAttribute("SpawnedAt")
        )
        or 0

    local lifetime =
        tonumber(
            ref:GetAttribute("Lifetime")
        )
        or 0

    local expiresAt =
        spawnedAt + lifetime

    local remaining =
        expiresAt - os.time()

    if state ~= "wandering" then
        return nil
    end

    if ownerUserId ~= 0 then
        return nil
    end

    if spawnedAt > 0
    and lifetime > 0
    and remaining <= 0 then

        return nil
    end

    return {
        id =
            tostring(ref.Name),

        petName =
            petName,

        rarity =
            CleanText(
                ref:GetAttribute("Rarity")
            ),

        price =
            tonumber(
                ref:GetAttribute("Price")
            )
            or 0,

        state =
            state,

        ownerUserId =
            ownerUserId,

        ownerName =
            CleanText(
                ref:GetAttribute("OwnerName")
            ),

        spawnedAt =
            spawnedAt,

        lifetime =
            lifetime,

        expiresAt =
            expiresAt,

        remaining =
            math.max(
                0,
                remaining
            ),
    }
end

function GAG2WildPetNetworkBuildPetSnapshot()

    local folder =
        GAG2WildPetNetworkGetWildPetRefFolder()

    local pets =
        {}

    if not folder then
        return pets
    end

    for _, ref in ipairs(folder:GetChildren()) do

        local pet =
            GAG2WildPetNetworkReadRefPet(
                ref
            )

        if pet then

            pets[#pets + 1] =
                pet
        end
    end

    table.sort(pets, function(a, b)

        if tostring(a.petName) ~= tostring(b.petName) then

            return tostring(a.petName)
                < tostring(b.petName)
        end

        return tostring(a.id)
            < tostring(b.id)
    end)

    return pets
end

function GAG2WildPetNetworkBuildPetSummary(pets)

    local counts =
        {}

    for _, pet in ipairs(pets or {}) do

        local petName =
            tostring(pet.petName or "")

        if petName ~= "" then

            counts[petName] =
                (
                    counts[petName]
                    or 0
                )
                + 1
        end
    end

    local names =
        {}

    for petName in pairs(counts) do

        names[#names + 1] =
            petName
    end

    table.sort(
        names
    )

    local rows =
        {}

    for _, petName in ipairs(names) do

        rows[#rows + 1] =
            petName
            .. " x"
            .. tostring(counts[petName])
    end

    if #rows <= 0 then
        return "none"
    end

    return table.concat(
        rows,
        ", "
    )
end

function GAG2WildPetNetworkClaimCurrentServer(force)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    if state.Enabled ~= true then
        return false
    end

    local now =
        os.time()

    if force ~= true
    and now - tonumber(state.LastClaimAt or 0) < tonumber(state.ClaimRefreshSeconds or 20) then

        return false
    end

    local data, errorText =
        GAG2WildPetNetworkRequest({
            action =
                "ClaimScoutServer",

            placeId =
                tostring(game.PlaceId),

            jobId =
                tostring(game.JobId),

            scoutUserId =
                LOCAL_PLAYER
                and LOCAL_PLAYER.UserId
                or 0,

            scoutName =
                LOCAL_PLAYER
                and LOCAL_PLAYER.Name
                or "Unknown",

            players =
                #Players:GetPlayers(),

            maxPlayers =
                Players.MaxPlayers,
        })

    if data then

        state.LastClaimAt =
            now

        state.LastClaimStatus =
            "claimed"

        return true
    end

    state.LastClaimStatus =
        "claim failed: "
        .. tostring(errorText)

    return false
end

function GAG2WildPetNetworkReportCurrentServer(reason)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    if state.Enabled ~= true then
        return false
    end

    if state.Sending == true then

        state.Pending =
            true

        state.PendingReason =
            tostring(reason or "pending")

        return false
    end

    state.Sending =
        true

    GAG2WildPetNetworkClaimCurrentServer(
        false
    )

    local pets =
        GAG2WildPetNetworkBuildPetSnapshot()

    local data, errorText =
        GAG2WildPetNetworkRequest({
            action =
                "ReportWildPets",

            placeId =
                tostring(game.PlaceId),

            jobId =
                tostring(game.JobId),

            scoutUserId =
                LOCAL_PLAYER
                and LOCAL_PLAYER.UserId
                or 0,

            scoutName =
                LOCAL_PLAYER
                and LOCAL_PLAYER.Name
                or "Unknown",

            players =
                #Players:GetPlayers(),

            maxPlayers =
                Players.MaxPlayers,

            pets =
                pets,
        })

    state.Sending =
        false

    if data then

        state.LastReportAt =
            os.time()

        state.LastPetCount =
            #pets

        state.LastPetSummary =
            GAG2WildPetNetworkBuildPetSummary(
                pets
            )

        GAG2WildPetNetworkContributorSetStatus(
            "Reported "
            .. tostring(#pets)
            .. " pet(s). "
            .. tostring(reason or "")
        )

    else

        GAG2WildPetNetworkContributorSetStatus(
            "Report failed: "
            .. tostring(errorText)
        )
    end

    if state.Pending == true
    and state.Enabled == true then

        state.Pending =
            false

        local pendingReason =
            tostring(
                state.PendingReason
                or "pending"
            )

        task.delay(0.75, function()

            GAG2WildPetNetworkReportCurrentServer(
                pendingReason
            )
        end)
    end

    return data ~= nil
end

function GAG2WildPetNetworkQueueCurrentReport(reason)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    if state.Enabled ~= true then
        return
    end

    state.PendingReason =
        tostring(reason or "change")

    if state.Pending == true then
        return
    end

    state.Pending =
        true

    task.delay(0.75, function()

        if state.Enabled ~= true then
            return
        end

        state.Pending =
            false

        GAG2WildPetNetworkReportCurrentServer(
            state.PendingReason
            or "change"
        )
    end)
end

function GAG2WildPetNetworkClearRefWatch(ref)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    local connections =
        state.RefConnections[ref]

    if type(connections) ~= "table" then
        return
    end

    for _, connection in ipairs(connections) do

        GAG2WildPetNetworkDisconnect(
            connection
        )
    end

    state.RefConnections[ref] =
        nil
end

function GAG2WildPetNetworkWatchRef(ref)

    if typeof(ref) ~= "Instance" then
        return
    end

    GAG2WildPetNetworkClearRefWatch(
        ref
    )

    local watchedAttributes = {
        "PetName",
        "Rarity",
        "Price",
        "State",
        "OwnerUserId",
        "OwnerName",
        "SpawnedAt",
        "Lifetime",
    }

    local connections =
        {}

    for _, attributeName in ipairs(watchedAttributes) do

        connections[#connections + 1] =
            ref:GetAttributeChangedSignal(
                attributeName
            ):Connect(function()

                GAG2WildPetNetworkQueueCurrentReport(
                    "attribute:"
                    .. tostring(attributeName)
                )
            end)
    end

    GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE.RefConnections[ref] =
        connections
end

function GAG2WildPetNetworkAttachRefFolder(folder)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    for _, ref in ipairs(folder:GetChildren()) do

        GAG2WildPetNetworkWatchRef(
            ref
        )
    end

    state.Connections[#state.Connections + 1] =
        folder.ChildAdded:Connect(function(ref)

            GAG2WildPetNetworkWatchRef(
                ref
            )

            GAG2WildPetNetworkQueueCurrentReport(
                "pet-added"
            )
        end)

    state.Connections[#state.Connections + 1] =
        folder.ChildRemoved:Connect(function(ref)

            GAG2WildPetNetworkClearRefWatch(
                ref
            )

            GAG2WildPetNetworkQueueCurrentReport(
                "pet-removed"
            )
        end)
end

function GAG2WildPetNetworkContributorStop(skipDirty)

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    state.Enabled =
        false

    state.Running =
        false

    state.Sending =
        false

    state.Pending =
        false

    state.LoopToken =
        tonumber(state.LoopToken)
        or 0

    state.LoopToken =
        state.LoopToken + 1

    for _, connection in ipairs(state.Connections) do

        GAG2WildPetNetworkDisconnect(
            connection
        )
    end

    state.Connections =
        {}

    for ref in pairs(state.RefConnections) do

        GAG2WildPetNetworkClearRefWatch(
            ref
        )
    end

    state.RefConnections =
        {}

    state.LastStatus =
        "Disabled."

    if Options.HolyGAG2WildPetNetworkContributorStatus then

        Options.HolyGAG2WildPetNetworkContributorStatus:SetText(
            GAG2WildPetNetworkContributorBuildStatusText()
        )
    end

    if skipDirty ~= true then

        MarkConfigDirty()
    end
end

function GAG2WildPetNetworkContributorStart()

    local state =
        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE

    if CleanText(GAG2_WILD_PET_NETWORK_API_KEY) == ""
    or CleanText(GAG2_WILD_PET_NETWORK_API_KEY) == "PASTE_CONFIG_B2_KEY_HERE" then

        state.Enabled =
            false

        GAG2WildPetNetworkContributorSetStatus(
            "Hard-coded API key missing."
        )

        return false
    end

    if state.Running == true then

        GAG2WildPetNetworkQueueCurrentReport(
            "already running"
        )

        return true
    end

    state.Enabled =
        true

    state.Running =
        true

    state.LoopToken =
        tonumber(state.LoopToken)
        or 0

    state.LoopToken =
        state.LoopToken + 1

    local token =
        state.LoopToken

    GAG2WildPetNetworkContributorSetStatus(
        "Starting..."
    )

    task.spawn(function()

        local map =
            workspace:WaitForChild(
                "Map",
                30
            )

        if state.Enabled ~= true
        or state.LoopToken ~= token then
            return
        end

        if not map then

            GAG2WildPetNetworkContributorSetStatus(
                "workspace.Map missing."
            )

            return
        end

        local folder =
            map:WaitForChild(
                "WildPetRef",
                30
            )

        if state.Enabled ~= true
        or state.LoopToken ~= token then
            return
        end

        if not folder then

            GAG2WildPetNetworkContributorSetStatus(
                "WildPetRef missing."
            )

            return
        end

        GAG2WildPetNetworkAttachRefFolder(
            folder
        )

        task.wait(
            1
        )

        GAG2WildPetNetworkClaimCurrentServer(
            true
        )

        GAG2WildPetNetworkReportCurrentServer(
            "startup"
        )

        while state.Enabled == true
        and state.Running == true
        and state.LoopToken == token do

            task.wait(
                math.clamp(
                    tonumber(state.HeartbeatSeconds)
                    or 1,
                    1,
                    60
                )
            )

            if state.Enabled == true
            and state.Running == true
            and state.LoopToken == token then

                GAG2WildPetNetworkReportCurrentServer(
                    "heartbeat"
                )
            end
        end
    end)

    return true
end

function GAG2WildPetNetworkContributorSetEnabled(value)

    local enabled =
        value == true

    GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE.Enabled =
        enabled

    if ConfigState.Loading == true then
        return
    end

    if enabled == true then

        GAG2WildPetNetworkContributorStart()

    else

        GAG2WildPetNetworkContributorStop(
            true
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreWildPetNetworkContributorState()

    task.defer(function()

        local enabled =
            true

        if Toggles.HolyGAG2WildPetNetworkContribute then

            enabled =
                Toggles.HolyGAG2WildPetNetworkContribute.Value ~= false
        end

        GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE.Enabled =
            enabled

        if enabled == true then

            GAG2WildPetNetworkContributorStart()

        else

            if Options.HolyGAG2WildPetNetworkContributorStatus then

                Options.HolyGAG2WildPetNetworkContributorStatus:SetText(
                    GAG2WildPetNetworkContributorBuildStatusText()
                )
            end
        end
    end)
end

local function BuildSnapshot()

    local map =
        workspace:FindFirstChild("Map")

    local wildPetSpawns =
        map
        and map:FindFirstChild("WildPetSpawns")

    local wildPetRef =
        map
        and map:FindFirstChild("WildPetRef")

    local stockValues =
        ReplicatedStorage:FindFirstChild("StockValues")

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local packetFolder =
        sharedModules
        and sharedModules:FindFirstChild("Packet")

    local packetRemote =
        packetFolder
        and packetFolder:FindFirstChild("RemoteEvent")

    local lines = {
        "========== HOLY SNAPSHOT ==========",
        "Player: " .. tostring(LOCAL_PLAYER.Name),
        "PlaceId: " .. tostring(game.PlaceId),
        "JobId: " .. tostring(game.JobId),
        "GAG2 Place: " .. BoolText(IsGAG2World()),
        "",
        "---- ROOTS ----",
        "workspace.Map: " .. BoolText(map ~= nil),
        "WildPetSpawns: " .. BoolText(wildPetSpawns ~= nil) .. " | count: " .. tostring(wildPetSpawns and #wildPetSpawns:GetChildren() or 0),
        "WildPetRef: " .. BoolText(wildPetRef ~= nil) .. " | count: " .. tostring(wildPetRef and #wildPetRef:GetChildren() or 0),
        "StockValues: " .. BoolText(stockValues ~= nil) .. " | count: " .. tostring(stockValues and #stockValues:GetChildren() or 0),
        "RemoteEvents.ReplicaSet: " .. BoolText(replicaSet ~= nil),
        "SharedModules.Packet.RemoteEvent: " .. BoolText(packetRemote ~= nil),
        "",
        "---- ACTIVE WILD PET SPAWNS ----",
    }

    if wildPetSpawns then

        local children =
            wildPetSpawns:GetChildren()

        table.sort(children, function(a, b)
            return tostring(a.Name) < tostring(b.Name)
        end)

        if #children <= 0 then

            table.insert(
                lines,
                "none"
            )

        else

            for index, child in ipairs(children) do

                if index > 25 then

                    table.insert(
                        lines,
                        "... +" .. tostring(#children - 25) .. " more"
                    )

                    break
                end

                table.insert(
                    lines,
                    tostring(index)
                    .. ". "
                    .. tostring(child.Name)
                    .. " | "
                    .. tostring(child.ClassName)
                    .. " | "
                    .. PathOf(child)
                )
            end
        end

    else

        table.insert(
            lines,
            "missing workspace.Map.WildPetSpawns"
        )
    end

    table.insert(lines, "")
    table.insert(lines, "---- STOCK VALUES ----")

    if stockValues then

        local children =
            stockValues:GetChildren()

        table.sort(children, function(a, b)
            return tostring(a.Name) < tostring(b.Name)
        end)

        if #children <= 0 then

            table.insert(
                lines,
                "none"
            )

        else

            for _, child in ipairs(children) do

                table.insert(
                    lines,
                    tostring(child.Name)
                    .. " | "
                    .. tostring(child.ClassName)
                    .. " | "
                    .. PathOf(child)
                )
            end
        end

    else

        table.insert(
            lines,
            "missing ReplicatedStorage.StockValues"
        )
    end

    table.insert(
        lines,
        "========================================="
    )

    return table.concat(
        lines,
        "\n"
    )
end

local function PrintSnapshot(copyToClipboard)

    local snapshot =
        BuildSnapshot()

    print(snapshot)

    if Options.HolyGAG2SnapshotStatus then

        Options.HolyGAG2SnapshotStatus:SetText(
            copyToClipboard == true
            and "Snapshot copied."
            or "Snapshot printed."
        )
    end

    if copyToClipboard == true then

        if CopyText(snapshot) == true then

            Notify(
                "Snapshot",
                "Copied to clipboard.",
                3
            )

        else

            Notify(
                "Snapshot",
                "Printed, but clipboard is unsupported.",
                4
            )
        end
    end
end

local function LoadDevTool(url, label)

    if IsHolyGAG2Developer() ~= true then

        Notify(
            "Dev",
            "Developer access required.",
            4
        )

        return
    end

    task.spawn(function()

        local ok, err =
            pcall(function()

                loadstring(
                    game:HttpGet(url)
                )()
            end)

        if ok == true then

            Notify(
                "Dev",
                tostring(label) .. " loaded.",
                3
            )

        else

            Notify(
                "Dev Error",
                tostring(err),
                5
            )
        end
    end)
end

--==================================================
-- [4.5] SNIPER HELPERS
-- Scanner + target matcher only. No buy/tame remotes yet.
--==================================================

SniperTargetDropdown =
    nil

SniperDropdownRefreshing =
    false

SniperPriorityDropdowns =
    {}

SniperPriorityRefreshing =
    false

local SniperState = {
    Enabled = false,
    Running = false,

    Targets = {},
    PriorityPets = {
        "",
        "",
        "",
        "",
        "",
    },
    KnownPetNames = {},
    SizeClass = "Any Size",
    SizeBaselines = {},
    AutoHop = false,
    InstantFirstHop = false,
    FirstHopUsed = false,
    EnabledAt = 0,
    InstantHopGrace = 0,
    ReturnAfterTame = false,
    ReturnMovementMode = "Walk",
    FollowPet = false,
    FollowMaxSeconds = 3.4,
    FollowRefreshDelay = 0.12,
    MovementMode = "Teleport",
    BuyMode = "Instant",

    Taming = false,
    LastTameAt = 0,
    RecentTameAttempts = {},
    HandledWildPets = {},
    PendingWildPets = {},

    ConfirmingBuy = false,
    ConfirmingBuyKey = "",

    BuyValidationHoldDelay = 0.25,
    RequireShecklesDrop = true,
    StartupBuyDelay = 8,
    StartedAt = os.clock(),

    LastPlayScreenPressAt = 0,
    PlayScreenClickAttempts = 0,
    PlayScreenMaxClickAttempts = 80,
    AutoPlayClickInterval = 0.09,
    AutoPlayTimeout = 45,
    PlayScreenClearAt = 0,
    PlayScreenClearGrace = 0.35,
    LoadingGuiClearAt = 0,
    LoadingGuiForceClear = true,

    WaitingForClaim = false,
    WaitingForClaimKey = "",
    ClaimWaitTimeout = 90,
    ClaimDisappearConfirmTime = 1.25,
    HandledPetCooldown = 120,

    PacketTable = nil,
    PacketSource = "not loaded",

    BuyPacket = nil,
    BuyPacketSource = "not loaded",

    ScanDelay = 0.25,
    HopDelay = 20,

    LastHopAt = 0,
    LastScanAt = 0,

    LastStatus = "Ready",
    LastMatchText = "No scan yet.",
    LastMatchCount = 0,
}

function SetSniperStatus(text)

    SniperState.LastStatus =
        tostring(text or "Ready")

    if Options.HolyGAG2SniperStatus then

        Options.HolyGAG2SniperStatus:SetText(
            SniperState.LastStatus
        )
    end
end

function RefreshSniperLabels()

    if Options.HolyGAG2SniperMatches then

        Options.HolyGAG2SniperMatches:SetText(
            SniperState.LastMatchText
        )
    end
end

function SniperNormalizeName(value)

    return CleanText(value)
        :lower()
        :gsub("%s+", " ")
end

function SniperNormalizeList(value)

    local result =
        {}

    local function add(item)

        item =
            CleanText(item)

        if item == "" then
            return
        end

        if table.find(result, item) ~= nil then
            return
        end

        table.insert(
            result,
            item
        )
    end

    if type(value) == "table" then

        for _, item in ipairs(value) do
            add(item)
        end

        for item, enabled in pairs(value) do

            if enabled == true then
                add(item)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    table.sort(result)

    return result
end

function SniperSetTargets(value)

    SniperState.Targets =
        SniperNormalizeList(value)

    MarkConfigDirty()
end

function SniperTargetsText()

    if type(SniperState.Targets) ~= "table"
    or #SniperState.Targets <= 0 then
        return "None"
    end

    return table.concat(
        SniperState.Targets,
        ", "
    )
end

function SniperRememberPetName(name)

    name =
        CleanText(name)

    if name == ""
    or name == "Unknown" then
        return
    end

    SniperState.KnownPetNames =
        SniperState.KnownPetNames
        or {}

    if table.find(SniperState.KnownPetNames, name) ~= nil then
        return
    end

    table.insert(
        SniperState.KnownPetNames,
        name
    )

    table.sort(
        SniperState.KnownPetNames
    )
end

local SniperPetRegistryBlacklist = {
    Behaviors = true,
    Breathe = true,
    DefendGarden = true,
    FireBreath = true,
    Fly = true,
    FlyIdle = true,
    GroundIdle = true,
    Idle = true,
    Land = true,
    PickFruit = true,
    StealFruit = true,
    TurnHopCountWeights = true,
    Walk = true,

    BlackDragonDefend = true,
    IceSerpentDefend = true,
}

function SniperIsValidRegistryPetName(name)

    name =
        CleanText(name)

    if name == "" then
        return false
    end

    if SniperPetRegistryBlacklist[name] == true then
        return false
    end

    if name:find("Defend", 1, true) then
        return false
    end

    if name:find("Behavior", 1, true) then
        return false
    end

    if name:match("^%d+$") then
        return false
    end

    return true
end

function GAG2CancelServerHop(reason)

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    if reason ~= nil
    and tostring(reason) ~= "" then

        SetStatus(
            tostring(reason)
        )
    end
end

function SniperGetPetModulesRoot()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    return sharedModules
        and sharedModules:FindFirstChild("PetModules")
        or nil
end

function SniperAddRegistryName(names, name)

    name =
        CleanText(name)

    if SniperIsValidRegistryPetName(name) ~= true then
        return
    end

    if table.find(names, name) ~= nil then
        return
    end

    table.insert(
        names,
        name
    )
end

function SniperCollectRegistryTableNames(value, names, depth, seen)

    if type(value) ~= "table" then
        return
    end

    if depth > 3 then
        return
    end

    if seen[value] == true then
        return
    end

    seen[value] =
        true

    for key, child in pairs(value) do

        if type(key) == "string"
        and type(child) == "table" then

            SniperAddRegistryName(
                names,
                key
            )
        end

        if type(key) == "string"
        and (
            key == "Name"
            or key == "DisplayName"
            or key == "PetName"
        )
        and type(child) == "string" then

            SniperAddRegistryName(
                names,
                child
            )
        end

        if type(child) == "table" then

            SniperCollectRegistryTableNames(
                child,
                names,
                depth + 1,
                seen
            )
        end
    end
end

function SniperGetRegistryPetNames()

    local names =
        {}

    local root =
        SniperGetPetModulesRoot()

    if root then

        for _, child in ipairs(root:GetChildren()) do

            if child:IsA("ModuleScript") then

                SniperAddRegistryName(
                    names,
                    child.Name
                )
            end
        end

        if root:IsA("ModuleScript") then

            local ok, result =
                pcall(function()

                    return require(
                        root
                    )
                end)

            if ok == true
            and type(result) == "table" then

                SniperCollectRegistryTableNames(
                    result,
                    names,
                    0,
                    {}
                )
            end
        end
    end

    table.sort(
        names
    )

    return names
end

function SniperBuildTargets()

    local targets =
        {}

    local ordered =
        SniperNormalizeList(
            SniperState.Targets
        )

    for _, targetName in ipairs(ordered) do

        local key =
            SniperNormalizeName(targetName)

        if key ~= "" then
            targets[key] = true
        end
    end

    return targets, ordered
end

function SniperGetSpawnsFolder()

    local map =
        workspace:FindFirstChild("Map")

    return map
        and map:FindFirstChild("WildPetSpawns")
end

function SniperGetRefFolder()

    local map =
        workspace:FindFirstChild("Map")

    return map
        and map:FindFirstChild("WildPetRef")
end

function SniperGetUuid(instanceName)

    instanceName =
        CleanText(instanceName)

    return instanceName:match("_WildPet_([%w%-]+)$")
        or instanceName:match("WildPet_([%w%-]+)$")
        or ""
end

function SniperGetPetName(spawn)

    if typeof(spawn) ~= "Instance" then
        return "Unknown"
    end

    local attrNames = {
        "PetName",
        "WildPetName",
        "AnimalName",
        "DisplayName",
        "Name",
    }

    for _, attrName in ipairs(attrNames) do

        local ok, value =
            pcall(function()

                return spawn:GetAttribute(
                    attrName
                )
            end)

        local cleaned =
            ok == true
            and CleanText(value)
            or ""

        if cleaned ~= "" then
            return cleaned
        end
    end

    local fromName =
        CleanText(spawn.Name):match("^WildPet_(.-)_WildPet_")

    if fromName
    and fromName ~= "" then

        return CleanText(
            fromName:gsub("_", " ")
        )
    end

    return CleanText(
        tostring(spawn.Name):gsub("_", " ")
    )
end

function SniperGetPosition(instance)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    if instance:IsA("BasePart") then
        return instance.Position
    end

    if instance:IsA("Model") then

        if instance.PrimaryPart then
            return instance.PrimaryPart.Position
        end

        local ok, cf =
            pcall(function()

                return instance:GetBoundingBox()
            end)

        if ok == true
        and typeof(cf) == "CFrame" then
            return cf.Position
        end
    end

    for _, descendant in ipairs(instance:GetDescendants()) do

        if descendant:IsA("BasePart") then
            return descendant.Position
        end
    end

    return nil
end

function SniperDistanceText(position)

    if typeof(position) ~= "Vector3" then
        return "? studs"
    end

    local character =
        LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return "? studs"
    end

    return tostring(
        math.floor(
            (root.Position - position).Magnitude + 0.5
        )
    )
    .. " studs"
end

function SniperFindRef(uuid)

    uuid =
        CleanText(uuid)

    if uuid == "" then
        return nil
    end

    local refFolder =
        SniperGetRefFolder()

    return refFolder
        and refFolder:FindFirstChild("WildPet_" .. uuid)
        or nil
end

function SniperCleanRichText(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function SniperGetTextRows(root)

    local rows =
        {}

    if typeof(root) ~= "Instance" then
        return rows
    end

    local scanned =
        0

    for _, descendant in ipairs(root:GetDescendants()) do

        scanned =
            scanned + 1

        if scanned > 180 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, text =
                pcall(function()

                    return descendant.Text
                end)

            text =
                ok == true
                and SniperCleanRichText(text)
                or ""

            if text ~= "" then

                table.insert(rows, {
                    Text = text,
                    Path = PathOf(descendant),
                })
            end
        end
    end

    return rows
end

function SniperBuildTextRows(spawn, ref)

    local rows =
        {}

    if typeof(spawn) == "Instance" then

        for _, row in ipairs(SniperGetTextRows(spawn)) do

            table.insert(
                rows,
                row
            )
        end
    end

    if typeof(ref) == "Instance" then

        for _, row in ipairs(SniperGetTextRows(ref)) do

            table.insert(
                rows,
                row
            )
        end
    end

    return rows
end

function SniperReadAttributeAny(instance, attrNames)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    for _, attrName in ipairs(attrNames or {}) do

        local ok, value =
            pcall(function()

                return instance:GetAttribute(
                    attrName
                )
            end)

        if ok == true
        and value ~= nil
        and tostring(value) ~= "" then
            return value
        end
    end

    return nil
end

function SniperFormatSeconds(seconds)

    seconds =
        math.max(
            0,
            math.floor(
                tonumber(seconds)
                or 0
            )
        )

    local minutes =
        math.floor(seconds / 60)

    local remain =
        seconds % 60

    if minutes > 0 then

        return tostring(minutes)
            .. "m "
            .. tostring(remain)
            .. "s"
    end

    return tostring(remain)
        .. "s"
end

function SniperFormatMoney(value)

    local number =
        tonumber(value)

    if not number then

        local text =
            SniperCleanRichText(value)

        if text == "" then
            return "?"
        end

        return text
    end

    local text =
        tostring(
            math.floor(number + 0.5)
        )

    text =
        text:reverse()
            :gsub("(%d%d%d)", "%1,")
            :reverse()
            :gsub("^,", "")

    return "¢" .. text
end

function SniperExtractTimer(textRows)

    for _, row in ipairs(textRows or {}) do

        local text =
            tostring(row.Text or "")

        local timer =
            text:match("(%d+%s*m%s*%d+%s*s)")
            or text:match("(%d+%s*:%s*%d+)")
            or text:match("(%d+%s*s)")

        if timer then

            return SniperCleanRichText(
                timer:gsub("%s+", " ")
            )
        end
    end

    return "?"
end

function SniperExtractPrice(textRows)

    for _, row in ipairs(textRows or {}) do

        local text =
            tostring(row.Text or "")

        if text:find("¢", 1, true)
        or text:find("$", 1, true)
        or text:lower():find("sheckle", 1, true) then

            return SniperCleanRichText(
                text:match("¢%s*[%d,%.]+")
                or text:match("%$%s*[%d,%.]+")
                or text:match("[%d,%.]+%s*[Ss]heckles?")
                or text
            )
        end
    end

    return "?"
end

function SniperGetEntryTimer(spawn, ref, textRows)

    local value =
        SniperReadAttributeAny(
            spawn,
            {
                "TimeLeft",
                "Timer",
                "Remaining",
                "RemainingTime",
                "DespawnTime",
                "ExpiresAt",
                "EndTime",
                "Duration",
            }
        )

    if value == nil
    and typeof(ref) == "Instance" then

        value =
            SniperReadAttributeAny(
                ref,
                {
                    "TimeLeft",
                    "Timer",
                    "Remaining",
                    "RemainingTime",
                    "DespawnTime",
                    "ExpiresAt",
                    "EndTime",
                    "Duration",
                }
            )
    end

    if typeof(value) == "number"
    or tonumber(value) ~= nil then

        local number =
            tonumber(value)

        if number > os.time() then

            return SniperFormatSeconds(
                number - os.time()
            )
        end

        return SniperFormatSeconds(
            number
        )
    end

    if value ~= nil
    and tostring(value) ~= "" then

        return SniperCleanRichText(
            value
        )
    end

    return SniperExtractTimer(
        textRows
    )
end

function SniperGetEntryPrice(spawn, ref, textRows)

    local value =
        SniperReadAttributeAny(
            spawn,
            {
                "Price",
                "Cost",
                "Sheckles",
                "BuyPrice",
                "PurchasePrice",
                "TamePrice",
            }
        )

    if value == nil
    and typeof(ref) == "Instance" then

        value =
            SniperReadAttributeAny(
                ref,
                {
                    "Price",
                    "Cost",
                    "Sheckles",
                    "BuyPrice",
                    "PurchasePrice",
                    "TamePrice",
                }
            )
    end

    if value ~= nil
    and tostring(value) ~= "" then

        return SniperFormatMoney(
            value
        )
    end

    return SniperExtractPrice(
        textRows
    )
end

function SniperSafePairsSnapshot(value)

    if type(value) ~= "table" then
        return {}
    end

    local ok, result =
        pcall(function()

            local rows =
                {}

            for key, child in pairs(value) do

                table.insert(rows, {
                    Key = key,
                    Value = child,
                })
            end

            return rows
        end)

    if ok == true
    and type(result) == "table" then
        return result
    end

    return {}
end

function SniperSafeRawGet(value, key)

    if type(value) ~= "table" then
        return nil
    end

    local ok, result =
        pcall(function()

            return rawget(
                value,
                key
            )
        end)

    if ok == true then
        return result
    end

    return nil
end

function SniperIsPacketObject(value)

    if type(value) ~= "table" then
        return false
    end

    return type(SniperSafeRawGet(value, "Name")) == "string"
        and SniperSafeRawGet(value, "Id") ~= nil
        and type(SniperSafeRawGet(value, "Writes")) == "table"
end

function SniperWildPacketScore(packetName, path)

    local text =
        (
            tostring(packetName or "")
            .. " "
            .. tostring(path or "")
        ):lower()

    if text:find("wild", 1, true) == nil then
        return 0
    end

    local score =
        0

    if text:find("wildpet", 1, true) then
        score = score + 400
    end

    if text:find("wild_pet", 1, true) then
        score = score + 400
    end

    if text:find("wild", 1, true) then
        score = score + 250
    end

    if text:find("pet", 1, true) then
        score = score + 80
    end

    if text:find("buy", 1, true) then
        score = score + 120
    end

    if text:find("purchase", 1, true) then
        score = score + 120
    end

    if text:find("tame", 1, true) then
        score = score + 160
    end

    if text:find("adopt", 1, true) then
        score = score + 100
    end

    if text:find("claim", 1, true) then
        score = score + 30
    end

    if text:find("seed", 1, true) then
        score = score - 500
    end

    if text:find("gear", 1, true) then
        score = score - 500
    end

    if text:find("crate", 1, true) then
        score = score - 500
    end

    if text:find("sell", 1, true) then
        score = score - 500
    end

    if text:find("trade", 1, true) then
        score = score - 500
    end

    if text:find("plant", 1, true) then
        score = score - 500
    end

    if text:find("inventory", 1, true) then
        score = score - 250
    end

    if text:find("equip", 1, true) then
        score = score - 250
    end

    return score
end

function SniperSearchWildPackets(candidate, seen, depth, path, results)

    if type(candidate) ~= "table" then
        return
    end

    if depth > 9 then
        return
    end

    if seen[candidate] == true then
        return
    end

    seen[candidate] =
        true

    if SniperIsPacketObject(candidate) == true then

        local packetName =
            tostring(
                SniperSafeRawGet(candidate, "Name")
                or ""
            )

        local score =
            SniperWildPacketScore(
                packetName,
                path
            )

        if score >= 300 then

            table.insert(results, {
                Packet = candidate,
                Name = packetName,
                Path = path,
                Score = score,
            })
        end
    end

    for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            SniperSearchWildPackets(
                row.Value,
                seen,
                depth + 1,
                path .. "." .. tostring(row.Key),
                results
            )
        end
    end
end

function SniperHasShopPacketTable(candidate)

    if type(candidate) ~= "table" then
        return false
    end

    local seedShop =
        SniperSafeRawGet(candidate, "SeedShop")

    local gearShop =
        SniperSafeRawGet(candidate, "GearShop")

    local crateShop =
        SniperSafeRawGet(candidate, "CrateShop")

    if type(seedShop) ~= "table"
    or type(gearShop) ~= "table"
    or type(crateShop) ~= "table" then
        return false
    end

    return SniperIsPacketObject(
        SniperSafeRawGet(seedShop, "PurchaseSeed")
    )
    and SniperIsPacketObject(
        SniperSafeRawGet(gearShop, "PurchaseGear")
    )
    and SniperIsPacketObject(
        SniperSafeRawGet(crateShop, "PurchaseCrate")
    )
end

function SniperPacketTableHasWildPacket(candidate)

    if type(candidate) ~= "table" then
        return false
    end

    local results =
        {}

    SniperSearchWildPackets(
        candidate,
        {},
        0,
        "Packets",
        results
    )

    return #results > 0
end

function SniperSearchPacketTable(candidate, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 6 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    if SniperHasShopPacketTable(candidate) == true then
        return candidate
    end

    if SniperPacketTableHasWildPacket(candidate) == true then
        return candidate
    end

    for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            local found =
                SniperSearchPacketTable(
                    row.Value,
                    seen,
                    depth + 1
                )

            if found then
                return found
            end
        end
    end

    return nil
end

function SniperFindPacketTable()

    if type(SniperState.PacketTable) == "table"
    and (
        SniperHasShopPacketTable(SniperState.PacketTable) == true
        or SniperPacketTableHasWildPacket(SniperState.PacketTable) == true
    ) then

        return SniperState.PacketTable
    end

    if type(getloadedmodules) ~= "function" then

        SniperState.PacketSource =
            "getloadedmodules unsupported"

        return nil
    end

    local okModules, modules =
        pcall(getloadedmodules)

    if okModules ~= true
    or type(modules) ~= "table" then

        SniperState.PacketSource =
            "getloadedmodules failed"

        return nil
    end

    for _, module in ipairs(modules) do

        if typeof(module) == "Instance"
        and module:IsA("ModuleScript") then

            local okRequire, result =
                pcall(function()

                    return require(
                        module
                    )
                end)

            if okRequire == true then

                local found =
                    SniperSearchPacketTable(
                        result,
                        {},
                        0
                    )

                if found then

                    SniperState.PacketTable =
                        found

                    SniperState.PacketSource =
                        "require: "
                        .. module:GetFullName()

                    return found
                end

                if type(result) == "table"
                and type(debug) == "table"
                and type(debug.getupvalues) == "function" then

                    for _, row in ipairs(SniperSafePairsSnapshot(result)) do

                        if type(row.Value) == "function" then

                            local okUpvalues, upvalues =
                                pcall(function()

                                    return debug.getupvalues(
                                        row.Value
                                    )
                                end)

                            if okUpvalues == true
                            and type(upvalues) == "table" then

                                for upKey, upValue in pairs(upvalues) do

                                    found =
                                        SniperSearchPacketTable(
                                            upValue,
                                            {},
                                            0
                                        )

                                    if found then

                                        SniperState.PacketTable =
                                            found

                                        SniperState.PacketSource =
                                            "upvalue: "
                                            .. module:GetFullName()
                                            .. "."
                                            .. tostring(row.Key)
                                            .. " -> "
                                            .. tostring(upKey)

                                        return found
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    SniperState.PacketSource =
        "packet table not found"

    return nil
end

--==================================================
-- [4.52] SHOP AUTO BUY
--==================================================

local GAG2_SHOP_CATEGORIES = {
    Seeds = {
        ShopName = "SeedShop",
        ItemsFolderName = "Items",
        PacketShop = "SeedShop",
        PacketName = "PurchaseSeed",
        DisplayName = "Seeds",
    },

    Gear = {
        ShopName = "GearShop",
        ItemsFolderName = "Items",
        PacketShop = "GearShop",
        PacketName = "PurchaseGear",
        DisplayName = "Gear",
    },

    Crates = {
        ShopName = "CrateShop",
        ItemsFolderName = "Items",
        PacketShop = "CrateShop",
        PacketName = "PurchaseCrate",
        DisplayName = "Crates",
    },
}

local GAG2_SHOP_STATE = {
    Started = false,
    UiLoopRunning = false,
    WorkerRunning = false,

    Enabled = {
        Seeds = false,
        Gear = false,
        Crates = false,
    },

    Selected = {
        Seeds = {},
        Gear = {},
        Crates = {},
    },

    BurstAttempts = {
        Seeds = {},
        Gear = {},
        Crates = {},
    },

    Queue = {},
    QueuedKeys = {},

    Connections = {},
    ItemConnections = {},

    PacketCache = {},
    LastPacketResolveAt = {},

    HiddenBurstDelay = 0,
    HiddenMaxBurstFires = 120,

    LastStockText = "Loading stock...",
}

local GAG2_SHOP_DROPDOWNS = {
    Seeds = nil,
    Gear = nil,
    Crates = nil,
}

local function GAG2ShopGetStockRoot()

    return ReplicatedStorage:FindFirstChild("StockValues")
end

local function GAG2ShopGetShopFolder(category)

    local info =
        GAG2_SHOP_CATEGORIES[category]

    if not info then
        return nil
    end

    local root =
        GAG2ShopGetStockRoot()

    return root
        and root:FindFirstChild(info.ShopName)
        or nil
end

local function GAG2ShopGetItemsFolder(category)

    local info =
        GAG2_SHOP_CATEGORIES[category]

    local shop =
        GAG2ShopGetShopFolder(category)

    if not info
    or not shop then
        return nil
    end

    return shop:FindFirstChild(
        info.ItemsFolderName
    )
end

local function GAG2ShopCleanItemName(itemName)

    itemName =
        CleanText(itemName)

    if itemName == ""
    or itemName == "---" then
        return ""
    end

    local beforePipe =
        itemName:match("^(.-)%s+|%s+")

    if beforePipe
    and CleanText(beforePipe) ~= "" then

        itemName =
            CleanText(beforePipe)
    end

    return itemName
end

local function GAG2ShopGetStockValueObject(category, itemName)

    local items =
        GAG2ShopGetItemsFolder(category)

    if not items then
        return nil
    end

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return nil
    end

    return items:FindFirstChild(itemName)
end

local function GAG2ShopReadStock(category, itemName)

    local object =
        GAG2ShopGetStockValueObject(
            category,
            itemName
        )

    if not object
    or object:IsA("ValueBase") ~= true then

        return nil
    end

    return tonumber(object.Value)
end

local function GAG2ShopGetRestockKey(category)

    local shop =
        GAG2ShopGetShopFolder(category)

    if not shop then
        return "0"
    end

    local nextRestock =
        shop:FindFirstChild("UnixNextRestock")

    local lastRestock =
        shop:FindFirstChild("UnixLastRestock")

    if nextRestock
    and nextRestock:IsA("ValueBase") then

        return tostring(nextRestock.Value)
    end

    if lastRestock
    and lastRestock:IsA("ValueBase") then

        return tostring(lastRestock.Value)
    end

    return "0"
end

local function GAG2ShopGetNextRestockTime()

    local best =
        nil

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        local shop =
            GAG2ShopGetShopFolder(category)

        local nextRestock =
            shop
            and shop:FindFirstChild("UnixNextRestock")

        if nextRestock
        and nextRestock:IsA("ValueBase") then

            local value =
                tonumber(nextRestock.Value)

            if value
            and value > 0
            and (
                best == nil
                or value < best
            ) then

                best =
                    value
            end
        end
    end

    return best
end

local function GAG2ShopFormatRestockTime()

    local nextRestock =
        GAG2ShopGetNextRestockTime()

    if not nextRestock then
        return "?"
    end

    return SniperFormatSeconds(
        math.max(
            0,
            nextRestock - os.time()
        )
    )
end

local function GAG2ShopNormalizeSelection(value)

    local selected =
        {}

    local function add(itemName)

        itemName =
            GAG2ShopCleanItemName(itemName)

        if itemName == "" then
            return
        end

        selected[itemName] =
            true
    end

    if type(value) == "table" then

        for _, itemName in ipairs(value) do
            add(itemName)
        end

        for itemName, enabled in pairs(value) do

            if enabled == true then
                add(itemName)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    return selected
end

local GAG2_SHOP_PRICE_CACHE = {
    Built = false,
    LastGuiScanAt = 0,
    Prices = {
        Seeds = {},
        Gear = {},
        Crates = {},
    },
}

local GAG2ShopReadPrice =
    nil

local function GAG2ShopGetSortScore(category, itemName)

    if type(GAG2ShopReadPrice) ~= "function" then
        return nil, false
    end

    local price =
        GAG2ShopReadPrice(
            category,
            itemName
        )

    if price then

        return tonumber(price),
            true
    end

    return nil,
        false
end

local function GAG2ShopParsePriceNumber(value)

    local text =
        CleanText(
            tostring(value or "")
                :gsub("<[^>]->", "")
                :gsub("<.->", "")
        )

    if text == "" then
        return nil
    end

    local lowerText =
        text:lower()

    if lowerText:find("robux", 1, true)
    or lowerText:find("r$", 1, true) then
        return nil
    end

    if not text:find("¢", 1, true)
    and not lowerText:find("sheck", 1, true)
    and not lowerText:find("cost", 1, true) then

        return nil
    end

    local numberText =
        text:match("([%d,%.]+)%s*¢")
        or text:match("¢%s*([%d,%.]+)")
        or text:match("([%d,%.]+)%s*[Ss]heckles?")
        or text:match("[Cc]ost[%s:]+([%d,%.]+)")

    if not numberText then
        return nil
    end

    numberText =
        tostring(numberText)
            :gsub(",", "")
            :gsub("%s+", "")

    return tonumber(numberText)
end

local function GAG2ShopBuildNameToCategoryMap()

    local map =
        {}

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        local items =
            GAG2ShopGetItemsFolder(category)

        if items then

            for _, child in ipairs(items:GetChildren()) do

                if child:IsA("ValueBase") then

                    map[child.Name] =
                        category
                end
            end
        end
    end

    return map
end

local function GAG2ShopCachePrice(category, itemName, price)

    category =
        CleanText(category)

    itemName =
        GAG2ShopCleanItemName(itemName)

    price =
        tonumber(price)

    if not GAG2_SHOP_CATEGORIES[category]
    or itemName == ""
    or not price
    or price <= 0 then
        return
    end

    GAG2_SHOP_PRICE_CACHE.Prices[category] =
        GAG2_SHOP_PRICE_CACHE.Prices[category]
        or {}

    GAG2_SHOP_PRICE_CACHE.Prices[category][itemName] =
        price
end

local function GAG2ShopSafePairs(value)

    if type(value) ~= "table" then
        return {}
    end

    local ok, rows =
        pcall(function()

            local result =
                {}

            for key, child in pairs(value) do

                table.insert(result, {
                    Key = key,
                    Value = child,
                })
            end

            return result
        end)

    if ok == true
    and type(rows) == "table" then
        return rows
    end

    return {}
end

local function GAG2ShopLooksLikePriceKey(key)

    local lowerKey =
        tostring(key or ""):lower()

    if lowerKey:find("robux", 1, true) then
        return false
    end

    return lowerKey == "cost"
        or lowerKey == "price"
        or lowerKey == "sheckles"
        or lowerKey == "buyprice"
        or lowerKey == "purchaseprice"
        or lowerKey:find("cost", 1, true) ~= nil
        or lowerKey:find("price", 1, true) ~= nil
end

local function GAG2ShopFindModulePrices(value, nameToCategory, depth, seen)

    if type(value) ~= "table" then
        return
    end

    if depth > 7 then
        return
    end

    if seen[value] == true then
        return
    end

    seen[value] =
        true

    local possibleName =
        nil

    for _, row in ipairs(GAG2ShopSafePairs(value)) do

        if type(row.Key) == "string"
        and (
            row.Key == "Name"
            or row.Key == "DisplayName"
            or row.Key == "ItemName"
            or row.Key == "SeedName"
            or row.Key == "GearName"
            or row.Key == "CrateName"
            or row.Key == "PlantName"
        )
        and type(row.Value) == "string" then

            possibleName =
                CleanText(row.Value)
        end
    end

    if possibleName
    and nameToCategory[possibleName] then

        for _, row in ipairs(GAG2ShopSafePairs(value)) do

            if GAG2ShopLooksLikePriceKey(row.Key)
            and tonumber(row.Value) then

                GAG2ShopCachePrice(
                    nameToCategory[possibleName],
                    possibleName,
                    row.Value
                )
            end
        end
    end

    for _, row in ipairs(GAG2ShopSafePairs(value)) do

        if type(row.Key) == "string"
        and nameToCategory[row.Key]
        and type(row.Value) == "table" then

            for _, childRow in ipairs(GAG2ShopSafePairs(row.Value)) do

                if GAG2ShopLooksLikePriceKey(childRow.Key)
                and tonumber(childRow.Value) then

                    GAG2ShopCachePrice(
                        nameToCategory[row.Key],
                        row.Key,
                        childRow.Value
                    )
                end
            end
        end

        if type(row.Value) == "table" then

            GAG2ShopFindModulePrices(
                row.Value,
                nameToCategory,
                depth + 1,
                seen
            )
        end
    end
end

local function GAG2ShopBuildModulePriceCache()

    if GAG2_SHOP_PRICE_CACHE.Built == true then
        return
    end

    GAG2_SHOP_PRICE_CACHE.Built =
        true

    local nameToCategory =
        GAG2ShopBuildNameToCategoryMap()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    if not sharedModules then
        return
    end

    local preferredModules = {
        "CrateData",
        "GearShopData",
        "SeedShopData",
        "SeedData",
        "SeedsData",
        "PlantData",
        "CropData",
        "ShopData",
        "ItemData",
        "EconomyData",
        "ProductData",
        "StoreData",
    }

    local scanned =
        {}

    for _, moduleName in ipairs(preferredModules) do

        local module =
            sharedModules:FindFirstChild(
                moduleName,
                true
            )

        if module
        and module:IsA("ModuleScript")
        and scanned[module] ~= true then

            scanned[module] =
                true

            local ok, result =
                pcall(function()

                    return require(module)
                end)

            if ok == true
            and type(result) == "table" then

                GAG2ShopFindModulePrices(
                    result,
                    nameToCategory,
                    0,
                    {}
                )
            end
        end
    end
end

local function GAG2ShopScanGuiPrices()

    -- Disabled for performance.
    -- Scanning PlayerGui descendants for prices causes client stutter on low-end/cloud devices.
    -- Prices now come from replicated module data, attributes, or cached values only.

    return
end

GAG2ShopReadPrice = function(category, itemName)

    category =
        CleanText(category)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return nil
    end

    local cachedBucket =
        GAG2_SHOP_PRICE_CACHE.Prices[category]

    if cachedBucket
    and tonumber(cachedBucket[itemName]) then

        return tonumber(
            cachedBucket[itemName]
        )
    end

    local object =
        GAG2ShopGetStockValueObject(
            category,
            itemName
        )

    if object then

        local attrNames = {
            "Price",
            "Cost",
            "Sheckles",
            "BuyPrice",
            "PurchasePrice",
        }

        for _, attrName in ipairs(attrNames) do

            local ok, value =
                pcall(function()

                    return object:GetAttribute(attrName)
                end)

            if ok == true
            and tonumber(value) then

                GAG2ShopCachePrice(
                    category,
                    itemName,
                    value
                )

                return tonumber(value)
            end
        end

        for _, child in ipairs(object:GetChildren()) do

            local childName =
                tostring(child.Name):lower()

            if child:IsA("ValueBase")
            and not childName:find("robux", 1, true)
            and (
                childName:find("price", 1, true)
                or childName:find("cost", 1, true)
                or childName:find("sheckle", 1, true)
            )
            and tonumber(child.Value) then

                GAG2ShopCachePrice(
                    category,
                    itemName,
                    child.Value
                )

                return tonumber(child.Value)
            end
        end
    end

    GAG2ShopBuildModulePriceCache()

    cachedBucket =
        GAG2_SHOP_PRICE_CACHE.Prices[category]

    return cachedBucket
        and tonumber(cachedBucket[itemName])
        or nil
end

local function GAG2ShopFormatPrice(category, itemName)

    local price =
        GAG2ShopReadPrice(
            category,
            itemName
        )

    if not price then
        return "¢?"
    end

    return SniperFormatMoney(
        price
    )
end

local function GAG2ShopGetSortedItemRows(category)

    local rows =
        {}

    local items =
        GAG2ShopGetItemsFolder(category)

    if not items then
        return rows
    end

    for _, child in ipairs(items:GetChildren()) do

        if child:IsA("ValueBase") then

            local price =
                GAG2ShopReadPrice(
                    category,
                    child.Name
                )

            table.insert(rows, {
                Name = child.Name,
                Price = price,
            })
        end
    end

    table.sort(rows, function(a, b)

        local aPrice =
            tonumber(a.Price)

        local bPrice =
            tonumber(b.Price)

        if aPrice
        and bPrice
        and aPrice ~= bPrice then

            return aPrice > bPrice
        end

        if aPrice
        and not bPrice then
            return true
        end

        if bPrice
        and not aPrice then
            return false
        end

        return tostring(a.Name)
            < tostring(b.Name)
    end)

    return rows
end

local function GAG2ShopMakeDropdownDisplayName(category, itemName)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return ""
    end

    return itemName
        .. " | "
        .. GAG2ShopFormatPrice(
            category,
            itemName
        )
end

local function GAG2ShopGetItemNames(category)

    local values =
        {}

    for _, row in ipairs(GAG2ShopGetSortedItemRows(category)) do

        local displayName =
            GAG2ShopMakeDropdownDisplayName(
                category,
                row.Name
            )

        if displayName ~= "" then

            table.insert(
                values,
                displayName
            )
        end
    end

    return values
end

local function GAG2ShopBuildCurrentStockText()

    local lines = {
        '<font color="rgb(196,181,253)"><b>Current Stock</b></font>',
        "Restock in: " .. GAG2ShopFormatRestockTime(),
    }

    for _, category in ipairs({
        "Seeds",
        "Gear",
        "Crates",
    }) do

        local info =
            GAG2_SHOP_CATEGORIES[category]

        table.insert(lines, "")
        table.insert(
            lines,
            '<font color="rgb(196,181,253)"><b>'
            .. tostring(info.DisplayName)
            .. '</b></font>'
        )

        local rows =
            {}

        local items =
            GAG2ShopGetItemsFolder(category)

        if items then

            for _, child in ipairs(items:GetChildren()) do

                if child:IsA("ValueBase") then

                    local stock =
                        tonumber(child.Value)
                        or 0

                    if stock > 0 then

                        table.insert(rows, {
                            Name = child.Name,
                            Stock = stock,
                            Price =
                                GAG2ShopReadPrice(
                                    category,
                                    child.Name
                                ),
                        })
                    end
                end
            end
        end

        table.sort(rows, function(a, b)

            local aPrice =
                tonumber(a.Price)

            local bPrice =
                tonumber(b.Price)

            if aPrice
            and bPrice
            and aPrice ~= bPrice then

                return aPrice > bPrice
            end

            if aPrice
            and not bPrice then
                return true
            end

            if bPrice
            and not aPrice then
                return false
            end

            return tostring(a.Name)
                < tostring(b.Name)
        end)

        if #rows <= 0 then

            table.insert(
                lines,
                "None"
            )

        else

            for index, row in ipairs(rows) do

                if index > 14 then

                    table.insert(
                        lines,
                        "+ "
                        .. tostring(#rows - 14)
                        .. " more"
                    )

                    break
                end

                table.insert(
                    lines,
                    tostring(row.Name)
                    .. " x"
                    .. tostring(row.Stock)
                    .. " | "
                    .. (
                        row.Price
                        and SniperFormatMoney(
                            row.Price
                        )
                        or "¢?"
                    )
                )
            end
        end
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function GAG2ShopRefreshStockLabel()

    GAG2_SHOP_STATE.LastStockText =
        GAG2ShopBuildCurrentStockText()

    if Options.HolyGAG2ShopCurrentStock then

        Options.HolyGAG2ShopCurrentStock:SetText(
            GAG2_SHOP_STATE.LastStockText
        )
    end
end

local function GAG2ShopRefreshDropdown(category)

    local dropdown =
        GAG2_SHOP_DROPDOWNS[category]

    if not dropdown then
        return
    end

    local values =
        GAG2ShopGetItemNames(category)

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

local function GAG2ShopRefreshAllDropdowns()

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        GAG2ShopRefreshDropdown(
            category
        )
    end
end

local function GAG2ShopResolvePacket(category)

    local cached =
        GAG2_SHOP_STATE.PacketCache[category]

    if cached ~= nil then
        return cached
    end

    local lastResolve =
        tonumber(
            GAG2_SHOP_STATE.LastPacketResolveAt[category]
        )
        or 0

    if os.clock() - lastResolve < 10 then
        return nil
    end

    GAG2_SHOP_STATE.LastPacketResolveAt[category] =
        os.clock()

    local info =
        GAG2_SHOP_CATEGORIES[category]

    if not info then
        return nil
    end

    local packets =
        SniperFindPacketTable()

    if type(packets) ~= "table" then
        return nil
    end

    local shopTable =
        SniperSafeRawGet(
            packets,
            info.PacketShop
        )

    if type(shopTable) ~= "table" then
        return nil
    end

    local packet =
        SniperSafeRawGet(
            shopTable,
            info.PacketName
        )

    local ok, fireFunction =
        pcall(function()

            return packet.Fire
        end)

    if ok == true
    and type(fireFunction) == "function" then

        GAG2_SHOP_STATE.PacketCache[category] =
            packet

        return packet
    end

    return nil
end

local function GAG2ShopFirePurchase(category, itemName)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return false
    end

    local packet =
        GAG2ShopResolvePacket(
            category
        )

    if not packet then
        return false
    end

    local ok =
        pcall(function()

            packet:Fire(
                itemName
            )
        end)

    if ok ~= true then

        ok =
            pcall(function()

                packet.Fire(
                    packet,
                    itemName
                )
            end)
    end

    return ok == true
end

local function GAG2ShopGetBurstBucket(category)

    GAG2_SHOP_STATE.BurstAttempts =
        type(GAG2_SHOP_STATE.BurstAttempts) == "table"
        and GAG2_SHOP_STATE.BurstAttempts
        or {}

    GAG2_SHOP_STATE.BurstAttempts[category] =
        type(GAG2_SHOP_STATE.BurstAttempts[category]) == "table"
        and GAG2_SHOP_STATE.BurstAttempts[category]
        or {}

    return GAG2_SHOP_STATE.BurstAttempts[category]
end

local function GAG2ShopGetBurstKey(category, itemName, stock)

    return tostring(category)
        .. ":"
        .. CleanText(itemName)
        .. ":"
        .. tostring(GAG2ShopGetRestockKey(category))
        .. ":stock:"
        .. tostring(math.floor(tonumber(stock) or 0))
end

local function GAG2ShopBurstAlreadyAttempted(category, itemName, stock)

    local bucket =
        GAG2ShopGetBurstBucket(
            category
        )

    local burstKey =
        GAG2ShopGetBurstKey(
            category,
            itemName,
            stock
        )

    return bucket[itemName] == burstKey
end

local function GAG2ShopMarkBurstAttempt(category, itemName, stock)

    local bucket =
        GAG2ShopGetBurstBucket(
            category
        )

    bucket[itemName] =
        GAG2ShopGetBurstKey(
            category,
            itemName,
            stock
        )
end

local function GAG2ShopClearBurstAttempt(category, itemName)

    local bucket =
        GAG2ShopGetBurstBucket(
            category
        )

    if itemName then

        bucket[itemName] =
            nil

    else

        GAG2_SHOP_STATE.BurstAttempts[category] =
            {}
    end
end

local function GAG2ShopCanBuy(category, itemName)

    if GAG2_SHOP_STATE.Enabled[category] ~= true then
        return false
    end

    if type(GAG2_SHOP_STATE.Selected[category]) ~= "table"
    or GAG2_SHOP_STATE.Selected[category][itemName] ~= true then
        return false
    end

    local stock =
        GAG2ShopReadStock(
            category,
            itemName
        )

    if stock == nil
    or stock <= 0 then
        return false
    end

    if GAG2ShopBurstAlreadyAttempted(
        category,
        itemName,
        stock
    ) == true then

        return false
    end

    return true
end

local function GAG2ShopEnqueue(category, itemName)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return
    end

    if GAG2ShopCanBuy(category, itemName) ~= true then
        return
    end

    local key =
        tostring(category)
        .. ":"
        .. itemName

    if GAG2_SHOP_STATE.QueuedKeys[key] == true then
        return
    end

    GAG2_SHOP_STATE.QueuedKeys[key] =
        true

    table.insert(GAG2_SHOP_STATE.Queue, {
        Category = category,
        ItemName = itemName,
        Key = key,
    })

    GAG2ShopStartWorker()
end

function GAG2ShopStartWorker()

    if GAG2_SHOP_STATE.WorkerRunning == true then
        return
    end

    GAG2_SHOP_STATE.WorkerRunning =
        true

    task.spawn(function()

        while #GAG2_SHOP_STATE.Queue > 0 do

            local job =
                table.remove(
                    GAG2_SHOP_STATE.Queue,
                    1
                )

            if job
            and job.Key then

                GAG2_SHOP_STATE.QueuedKeys[job.Key] =
                    nil
            end

            if job
            and GAG2ShopCanBuy(
                job.Category,
                job.ItemName
            ) == true then

                local stock =
                    GAG2ShopReadStock(
                        job.Category,
                        job.ItemName
                    )

                stock =
                    math.max(
                        0,
                        math.floor(
                            tonumber(stock)
                            or 0
                        )
                    )

                if stock > 0 then

                    GAG2ShopMarkBurstAttempt(
                        job.Category,
                        job.ItemName,
                        stock
                    )

                    local fireCount =
                        math.min(
                            stock,
                            math.floor(
                                tonumber(GAG2_SHOP_STATE.HiddenMaxBurstFires)
                                or 120
                            )
                        )

                    for fireIndex = 1, fireCount do

                        if GAG2_SHOP_STATE.Enabled[job.Category] ~= true then
                            break
                        end

                        if type(GAG2_SHOP_STATE.Selected[job.Category]) ~= "table"
                        or GAG2_SHOP_STATE.Selected[job.Category][job.ItemName] ~= true then
                            break
                        end

                        GAG2ShopFirePurchase(
                            job.Category,
                            job.ItemName
                        )

                        local burstDelay =
                            tonumber(GAG2_SHOP_STATE.HiddenBurstDelay)
                            or 0

                        if burstDelay > 0 then

                            task.wait(
                                burstDelay
                            )

                        elseif fireIndex % 24 == 0 then

                            task.wait()
                        end
                    end

                    GAG2ShopRefreshStockLabel()
                end
            end

            task.wait(
                0.01
            )
        end

        GAG2_SHOP_STATE.WorkerRunning =
            false
    end)
end

local function GAG2ShopEnqueueSelectedInStock(category)

    local selected =
        GAG2_SHOP_STATE.Selected[category]

    if type(selected) ~= "table" then
        return
    end

    for itemName, enabled in pairs(selected) do

        if enabled == true then

            GAG2ShopEnqueue(
                category,
                itemName
            )
        end
    end
end

local function GAG2ShopEnqueueAllSelectedInStock()

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        GAG2ShopEnqueueSelectedInStock(
            category
        )
    end
end

local function GAG2ShopClearRestockBuys(category)

    if category then

        GAG2_SHOP_STATE.BurstAttempts[category] =
            {}

        return
    end

    for key in pairs(GAG2_SHOP_CATEGORIES) do

        GAG2_SHOP_STATE.BurstAttempts[key] =
            {}
    end
end

local function GAG2ShopTrackItem(category, itemObject)

    if typeof(itemObject) ~= "Instance"
    or itemObject:IsA("ValueBase") ~= true then
        return
    end

    local itemKey =
        tostring(category)
        .. ":"
        .. tostring(itemObject.Name)

    if GAG2_SHOP_STATE.ItemConnections[itemKey] then
        return
    end

    GAG2_SHOP_STATE.ItemConnections[itemKey] =
        itemObject.Changed:Connect(function()

            local itemName =
                itemObject.Name

            local currentStock =
                tonumber(itemObject.Value)
                or 0

            GAG2ShopClearBurstAttempt(
                category,
                itemName
            )

            GAG2ShopRefreshStockLabel()

            if currentStock > 0 then

                GAG2ShopEnqueue(
                    category,
                    itemName
                )
            end
        end)
end

local function GAG2ShopTrackCategory(category)

    local shop =
        GAG2ShopGetShopFolder(category)

    local items =
        GAG2ShopGetItemsFolder(category)

    if not shop
    or not items then
        return
    end

    for _, child in ipairs(items:GetChildren()) do

        GAG2ShopTrackItem(
            category,
            child
        )
    end

    table.insert(
        GAG2_SHOP_STATE.Connections,
        items.ChildAdded:Connect(function(child)

            task.wait(
                0.05
            )

            GAG2ShopTrackItem(
                category,
                child
            )

            GAG2ShopRefreshDropdown(
                category
            )

            GAG2ShopRefreshStockLabel()

            GAG2ShopEnqueue(
                category,
                child.Name
            )
        end)
    )

    table.insert(
        GAG2_SHOP_STATE.Connections,
        items.ChildRemoved:Connect(function()

            GAG2ShopRefreshDropdown(
                category
            )

            GAG2ShopRefreshStockLabel()
        end)
    )

    local lastRestock =
        shop:FindFirstChild("UnixLastRestock")

    if lastRestock
    and lastRestock:IsA("ValueBase") then

        table.insert(
            GAG2_SHOP_STATE.Connections,
            lastRestock.Changed:Connect(function()

                GAG2ShopClearRestockBuys(
                    category
                )

                task.wait(
                    0.15
                )

                GAG2ShopRefreshStockLabel()

                GAG2ShopEnqueueSelectedInStock(
                    category
                )
            end)
        )
    end

    local nextRestock =
        shop:FindFirstChild("UnixNextRestock")

    if nextRestock
    and nextRestock:IsA("ValueBase") then

        table.insert(
            GAG2_SHOP_STATE.Connections,
            nextRestock.Changed:Connect(function()

                GAG2ShopClearRestockBuys(
                    category
                )

                task.wait(
                    0.15
                )

                GAG2ShopRefreshStockLabel()

                GAG2ShopEnqueueSelectedInStock(
                    category
                )
            end)
        )
    end
end

function GAG2ShopStartUiLoop()

    if GAG2_SHOP_STATE.UiLoopRunning == true then
        return
    end

    GAG2_SHOP_STATE.UiLoopRunning =
        true

    task.spawn(function()

        local lastBackupScan =
            0

        while GAG2_SHOP_STATE.UiLoopRunning == true do

            GAG2ShopRefreshStockLabel()

            if os.clock() - lastBackupScan >= 45 then

                lastBackupScan =
                    os.clock()

                GAG2ShopRefreshAllDropdowns()
                GAG2ShopEnqueueAllSelectedInStock()
            end

            task.wait(
                1
            )
        end
    end)
end

function GAG2ShopStart()

    if GAG2_SHOP_STATE.Started == true then

        GAG2ShopRefreshStockLabel()

        return
    end

    GAG2_SHOP_STATE.Started =
        true

    task.spawn(function()

        local started =
            os.clock()

        while os.clock() - started < 12 do

            local root =
                GAG2ShopGetStockRoot()

            if root then
                break
            end

            task.wait(
                0.25
            )
        end

        for category in pairs(GAG2_SHOP_CATEGORIES) do

            GAG2ShopTrackCategory(
                category
            )
        end

        GAG2ShopRefreshAllDropdowns()
        GAG2ShopRefreshStockLabel()
        GAG2ShopEnqueueAllSelectedInStock()
        GAG2ShopStartUiLoop()
    end)
end

function GAG2ShopSetSelected(category, value)

    GAG2_SHOP_STATE.Selected[category] =
        GAG2ShopNormalizeSelection(
            value
        )

    GAG2ShopEnqueueSelectedInStock(
        category
    )

    MarkConfigDirty()
end

function GAG2ShopSetEnabled(category, value)

    GAG2_SHOP_STATE.Enabled[category] =
        value == true

    GAG2ShopStart()

    if value == true then

        GAG2ShopClearRestockBuys(
            category
        )

        GAG2ShopEnqueueSelectedInStock(
            category
        )
    end

    MarkConfigDirty()
end

GAG2_AUTO_COLLECT_SEEDS_STATE =
    GAG2_AUTO_COLLECT_SEEDS_STATE
    or {
        Enabled = false,
        Running = false,
        SeedType = "Gold",
        MovementMode = "Teleport",
        CollectMode = "Instant",
        HoldDuration = 3.2,
        LastStatus = "Idle.",
        Recent = {},

        ClaimRangePadding = 1.75,
        SafeClaimDistance = 7.25,
        WalkTimeout = 12,
        WalkRefreshDelay = 0.55,
        TeleportClaimWait = 1.25,

        StaleRecentSeconds = 8,
        MissingRecentSeconds = 12,

        ClaimRangePadding = 1.75,
        SafeClaimDistance = 7.25,
        WalkTimeout = 12,
        WalkRefreshDelay = 0.55,
        TeleportClaimWait = 1.25,
    }

GAG2_AUTO_COLLECT_SEEDS_STATE.ClaimRangePadding =
    tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.ClaimRangePadding)
    or 1.75

GAG2_AUTO_COLLECT_SEEDS_STATE.SafeClaimDistance =
    tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.SafeClaimDistance)
    or 7.25

GAG2_AUTO_COLLECT_SEEDS_STATE.WalkTimeout =
    tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.WalkTimeout)
    or 12

GAG2_AUTO_COLLECT_SEEDS_STATE.WalkRefreshDelay =
    tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.WalkRefreshDelay)
    or 0.55

GAG2_AUTO_COLLECT_SEEDS_STATE.TeleportClaimWait =
    tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.TeleportClaimWait)
    or 1.25

function GAG2SeedCollectSetStatus(text)

    GAG2_AUTO_COLLECT_SEEDS_STATE.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2SeedCollectStatus then

        Options.HolyGAG2SeedCollectStatus:SetText(
            GAG2_AUTO_COLLECT_SEEDS_STATE.LastStatus
        )
    end
end

function GAG2SeedCollectGetFolder()

    local map =
        workspace:FindFirstChild("Map")

    return map
        and map:FindFirstChild("SeedPackSpawnServerLocations")
        or nil
end

function GAG2SeedCollectGetCharacterRoot()

    local character =
        LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    if not character
    or not root
    or not humanoid then

        return nil,
            nil,
            nil
    end

    return character,
        root,
        humanoid
end

function GAG2SeedCollectReadType(part)

    if typeof(part) ~= "Instance" then
        return ""
    end

    if part:GetAttribute("GoldSeed") == true then
        return "Gold"
    end

    if part:GetAttribute("RainbowSeed") == true then
        return "Rainbow"
    end

    local prompt =
        part:FindFirstChildWhichIsA(
            "ProximityPrompt",
            true
        )

    if prompt then

        local text =
            CleanText(
                tostring(prompt.ObjectText)
            ):lower()

        if text:find("gold", 1, true) then
            return "Gold"
        end

        if text:find("rainbow", 1, true) then
            return "Rainbow"
        end
    end

    return ""
end

function GAG2SeedCollectTypeAllowed(seedType)

    local selected =
        CleanText(
            GAG2_AUTO_COLLECT_SEEDS_STATE.SeedType
        )

    if selected == "Gold + Rainbow" then
        return seedType == "Gold"
            or seedType == "Rainbow"
    end

    return seedType == selected
end

function GAG2SeedCollectGetToolCount(seedType)

    local count =
        0

    local backpack =
        LOCAL_PLAYER:FindFirstChildOfClass("Backpack")

    local character =
        LOCAL_PLAYER.Character

    local function scan(root)

        if not root then
            return
        end

        for _, child in ipairs(root:GetChildren()) do

            if child:IsA("Tool")
            and CleanText(child.Name) == seedType then

                local stack =
                    tonumber(child:GetAttribute("Count"))

                if stack
                and stack > 0 then

                    count =
                        count + stack

                else

                    count =
                        count + 1
                end
            end
        end
    end

    scan(backpack)
    scan(character)

    return count
end

function GAG2SeedCollectFindNearest()

    local folder =
        GAG2SeedCollectGetFolder()

    local character, root =
        GAG2SeedCollectGetCharacterRoot()

    if not folder
    or not root then

        return nil,
            "missing folder/root"
    end

    local best =
        nil

    local bestDistance =
        math.huge

    for _, child in ipairs(folder:GetChildren()) do

        if child:IsA("BasePart") then

            local prompt =
                child:FindFirstChildWhichIsA(
                    "ProximityPrompt",
                    true
                )

            local seedType =
                GAG2SeedCollectReadType(
                    child
                )

            if prompt
            and prompt.Enabled == true
            and GAG2SeedCollectTypeAllowed(seedType) == true then

                local key =
                    tostring(child)

                local recent =
                    tonumber(
                        GAG2_AUTO_COLLECT_SEEDS_STATE.Recent[key]
                    )
                    or 0

                if os.clock() - recent >= 1.5 then

                    local distance =
                        (root.Position - child.Position).Magnitude

                    if distance < bestDistance then

                        bestDistance =
                            distance

                        best = {
                            Part = child,
                            Prompt = prompt,
                            SeedType = seedType,
                            Distance = distance,
                            Key = key,
                        }
                    end
                end
            end
        end
    end

    if not best then

        return nil,
            "no matching seed"
    end

    return best,
        "ok"
end

function GAG2SeedCollectGetPromptPosition(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local prompt =
        entry.Prompt

    if typeof(prompt) == "Instance" then

        local parent =
            prompt.Parent

        if typeof(parent) == "Instance" then

            if parent:IsA("BasePart") then
                return parent.Position
            end

            if parent:IsA("Attachment") then
                return parent.WorldPosition
            end
        end
    end

    if typeof(entry.Part) == "Instance"
    and entry.Part:IsA("BasePart") then

        return entry.Part.Position
    end

    return nil
end

function GAG2SeedCollectGetPromptDistance(entry, root)

    if type(entry) ~= "table"
    or typeof(root) ~= "Instance" then

        return math.huge
    end

    local position =
        GAG2SeedCollectGetPromptPosition(
            entry
        )

    if typeof(position) ~= "Vector3" then
        return math.huge
    end

    return (root.Position - position).Magnitude
end

function GAG2SeedCollectGetClaimDistance(prompt)

    local maxDistance =
        10

    if typeof(prompt) == "Instance"
    and prompt:IsA("ProximityPrompt") then

        maxDistance =
            tonumber(prompt.MaxActivationDistance)
            or maxDistance
    end

    local state =
        GAG2_AUTO_COLLECT_SEEDS_STATE

    local padding =
        tonumber(state.ClaimRangePadding)
        or 1.75

    local safeDistance =
        maxDistance - padding

    safeDistance =
        math.min(
            safeDistance,
            tonumber(state.SafeClaimDistance)
            or 7.25
        )

    return math.clamp(
        safeDistance,
        3,
        maxDistance
    )
end

function GAG2SeedCollectIsPromptClaimable(entry, root)

    if type(entry) ~= "table"
    or typeof(root) ~= "Instance" then

        return false,
            "missing entry/root"
    end

    local prompt =
        entry.Prompt

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then

        return false,
            "missing prompt"
    end

    if prompt.Parent == nil then

        return false,
            "prompt removed"
    end

    if prompt.Enabled ~= true then

        return false,
            "prompt disabled"
    end

    if typeof(entry.Part) ~= "Instance"
    or entry.Part.Parent == nil then

        return false,
            "seed removed"
    end

    local distance =
        GAG2SeedCollectGetPromptDistance(
            entry,
            root
        )

    local claimDistance =
        GAG2SeedCollectGetClaimDistance(
            prompt
        )

    if distance <= claimDistance then

        return true,
            "in range"
    end

    return false,
        "too far: "
        .. tostring(math.floor(distance + 0.5))
        .. "/"
        .. tostring(math.floor(claimDistance + 0.5))
end

function GAG2SeedCollectWaitClaimable(entry, timeout)

    local _, root =
        GAG2SeedCollectGetCharacterRoot()

    if not root then
        return false,
            "missing root"
    end

    local started =
        os.clock()

    timeout =
        tonumber(timeout)
        or 2

    while GAG2_AUTO_COLLECT_SEEDS_STATE.Enabled == true
    and os.clock() - started < timeout do

        local ok, reason =
            GAG2SeedCollectIsPromptClaimable(
                entry,
                root
            )

        if ok == true then

            return true,
                reason
        end

        if reason == "seed removed"
        or reason == "prompt removed" then

            return false,
                reason
        end

        task.wait(
            0.05
        )
    end

    local _, reason =
        GAG2SeedCollectIsPromptClaimable(
            entry,
            root
        )

    return false,
        reason or "not claimable"
end

function GAG2SeedCollectGetPromptPosition(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local prompt =
        entry.Prompt

    if typeof(prompt) == "Instance" then

        local parent =
            prompt.Parent

        if typeof(parent) == "Instance" then

            if parent:IsA("BasePart") then
                return parent.Position
            end

            if parent:IsA("Attachment") then
                return parent.WorldPosition
            end
        end
    end

    if typeof(entry.Part) == "Instance"
    and entry.Part:IsA("BasePart") then

        return entry.Part.Position
    end

    return nil
end

function GAG2SeedCollectGetPromptDistance(entry, root)

    if type(entry) ~= "table"
    or typeof(root) ~= "Instance" then

        return math.huge
    end

    local position =
        GAG2SeedCollectGetPromptPosition(
            entry
        )

    if typeof(position) ~= "Vector3" then
        return math.huge
    end

    return (root.Position - position).Magnitude
end

function GAG2SeedCollectGetClaimDistance(prompt)

    local maxDistance =
        10

    if typeof(prompt) == "Instance"
    and prompt:IsA("ProximityPrompt") then

        maxDistance =
            tonumber(prompt.MaxActivationDistance)
            or maxDistance
    end

    local state =
        GAG2_AUTO_COLLECT_SEEDS_STATE

    local padding =
        tonumber(state.ClaimRangePadding)
        or 1.75

    local safeDistance =
        maxDistance - padding

    safeDistance =
        math.min(
            safeDistance,
            tonumber(state.SafeClaimDistance)
            or 7.25
        )

    return math.clamp(
        safeDistance,
        3,
        maxDistance
    )
end

function GAG2SeedCollectHasClaimedFlag(instance)

    if typeof(instance) ~= "Instance" then
        return false,
            ""
    end

    local attributeNames = {
        "Claimed",
        "Collected",
        "PickedUp",
        "Picked",
        "Taken",
        "Disabled",
        "Used",
    }

    for _, attributeName in ipairs(attributeNames) do

        local ok, value =
            pcall(function()

                return instance:GetAttribute(
                    attributeName
                )
            end)

        if ok == true
        and value ~= nil then

            if value == true then

                return true,
                    tostring(attributeName)
                    .. "=true"
            end

            local text =
                CleanText(value):lower()

            if text == "true"
            or text == "claimed"
            or text == "collected"
            or text == "picked"
            or text == "taken"
            or text == "used"
            or text == "disabled" then

                return true,
                    tostring(attributeName)
                    .. "="
                    .. tostring(value)
            end
        end
    end

    return false,
        ""
end

function GAG2SeedCollectEntryHasClaimedFlag(entry)

    if type(entry) ~= "table" then
        return false,
            ""
    end

    local objects = {
        entry.Part,
        entry.Prompt,
        typeof(entry.Part) == "Instance" and entry.Part.Parent or nil,
        typeof(entry.Prompt) == "Instance" and entry.Prompt.Parent or nil,
    }

    local checked =
        {}

    for _, object in ipairs(objects) do

        if typeof(object) == "Instance"
        and checked[object] ~= true then

            checked[object] =
                true

            local claimed, reason =
                GAG2SeedCollectHasClaimedFlag(
                    object
                )

            if claimed == true then

                return true,
                    reason
            end
        end
    end

    return false,
        ""
end

function GAG2SeedCollectGetSeedRoot(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local candidates = {
        entry.Part,

        typeof(entry.Prompt) == "Instance"
        and entry.Prompt.Parent
        or nil,
    }

    for _, candidate in ipairs(candidates) do

        if typeof(candidate) == "Instance" then

            local current =
                candidate

            for _ = 1, 8 do

                if not current
                or current == workspace
                or current.Parent == nil then
                    break
                end

                local currentName =
                    CleanText(current.Name):lower()

                local parentName =
                    current.Parent
                    and CleanText(current.Parent.Name):lower()
                    or ""

                if current:IsA("Model")
                or current:IsA("Folder") then

                    if currentName:find("seed", 1, true)
                    or currentName:find("gold", 1, true)
                    or currentName:find("rainbow", 1, true)
                    or parentName:find("seed", 1, true)
                    or parentName:find("spawn", 1, true) then

                        return current
                    end
                end

                if parentName:find("seedpackspawn", 1, true)
                or parentName:find("seedpack", 1, true)
                or parentName:find("seed", 1, true) then

                    return current
                end

                current =
                    current.Parent
            end
        end
    end

    if typeof(entry.Part) == "Instance" then
        return entry.Part
    end

    return nil
end

function GAG2SeedCollectIsVisibleSeedPart(part, promptParent)

    if typeof(part) ~= "Instance"
    or part:IsA("BasePart") ~= true then

        return false
    end

    if part.Parent == nil then
        return false
    end

    if part:IsDescendantOf(workspace) ~= true then
        return false
    end

    local size =
        part.Size

    if size.Magnitude <= 0.05 then
        return false
    end

    local transparency =
        tonumber(part.Transparency)
        or 0

    if transparency >= 0.96 then
        return false
    end

    local name =
        CleanText(part.Name):lower()

    local looksLikePromptOnly =
        name:find("prompt", 1, true)
        or name:find("trigger", 1, true)
        or name:find("hitbox", 1, true)
        or name:find("interaction", 1, true)
        or name:find("claim", 1, true)

    if looksLikePromptOnly
    and part == promptParent then

        return false
    end

    return true
end

function GAG2SeedCollectEntryHasLiveSeedVisual(entry)

    if type(entry) ~= "table" then

        return false,
            "bad entry"
    end

    local root =
        GAG2SeedCollectGetSeedRoot(
            entry
        )

    if typeof(root) ~= "Instance" then

        return false,
            "missing seed root"
    end

    if root.Parent == nil then

        return false,
            "seed root removed"
    end

    if root:IsDescendantOf(workspace) ~= true then

        return false,
            "seed root not in workspace"
    end

    local promptParent =
        typeof(entry.Prompt) == "Instance"
        and entry.Prompt.Parent
        or nil

    if GAG2SeedCollectIsVisibleSeedPart(root, promptParent) == true then

        return true,
            "visible root"
    end

    local checked =
        0

    for _, descendant in ipairs(root:GetDescendants()) do

        checked =
            checked + 1

        if checked > 120 then
            break
        end

        if GAG2SeedCollectIsVisibleSeedPart(descendant, promptParent) == true then

            return true,
                "visible descendant"
        end
    end

    return false,
        "seed visual gone"
end

function GAG2SeedCollectIsEntryAlive(entry)

    if type(entry) ~= "table" then

        return false,
            "bad entry"
    end

    local part =
        entry.Part

    local prompt =
        entry.Prompt

    if typeof(part) ~= "Instance" then

        return false,
            "missing seed part"
    end

    if part.Parent == nil then

        return false,
            "seed removed"
    end

    if part:IsDescendantOf(workspace) ~= true then

        return false,
            "seed no longer in workspace"
    end

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then

        return false,
            "missing prompt"
    end

    if prompt.Parent == nil then

        return false,
            "prompt removed"
    end

    if prompt:IsDescendantOf(workspace) ~= true then

        return false,
            "prompt no longer in workspace"
    end

    local claimed, claimReason =
        GAG2SeedCollectEntryHasClaimedFlag(
            entry
        )

    if claimed == true then

        return false,
            "claimed: "
            .. tostring(claimReason)
    end

    local visualAlive, visualReason =
        GAG2SeedCollectEntryHasLiveSeedVisual(
            entry
        )

    if visualAlive ~= true then

        return false,
            tostring(visualReason)
    end

    if prompt.Enabled ~= true then

        return false,
            "prompt disabled"
    end

    local position =
        GAG2SeedCollectGetPromptPosition(
            entry
        )

    if typeof(position) ~= "Vector3" then

        return false,
            "missing prompt position"
    end

    return true,
        "alive"
end

function GAG2SeedCollectMarkEntryStale(entry, reason, seconds)

    local state =
        GAG2_AUTO_COLLECT_SEEDS_STATE

    if type(state.Recent) ~= "table" then

        state.Recent =
            {}
    end

    local key =
        type(entry) == "table"
        and CleanText(entry.Key)
        or ""

    if key == "" then
        return
    end

    seconds =
        math.max(
            1,
            tonumber(seconds)
            or tonumber(state.StaleRecentSeconds)
            or 8
        )

    state.Recent[key] =
        os.clock()
        + seconds
end

function GAG2SeedCollectIsPromptClaimable(entry, root)

    local alive, aliveReason =
        GAG2SeedCollectIsEntryAlive(
            entry
        )

    if alive ~= true then

        return false,
            aliveReason
    end

    if typeof(root) ~= "Instance" then

        return false,
            "missing root"
    end

    local prompt =
        entry.Prompt

    local distance =
        GAG2SeedCollectGetPromptDistance(
            entry,
            root
        )

    local claimDistance =
        GAG2SeedCollectGetClaimDistance(
            prompt
        )

    if distance <= claimDistance then

        return true,
            "in range"
    end

    return false,
        "too far: "
        .. tostring(math.floor(distance + 0.5))
        .. "/"
        .. tostring(math.floor(claimDistance + 0.5))
end

function GAG2SeedCollectWaitClaimable(entry, timeout)

    local _, root =
        GAG2SeedCollectGetCharacterRoot()

    if not root then
        return false,
            "missing root"
    end

    local started =
        os.clock()

    timeout =
        tonumber(timeout)
        or 2

    while GAG2_AUTO_COLLECT_SEEDS_STATE.Enabled == true
    and os.clock() - started < timeout do

        local ok, reason =
            GAG2SeedCollectIsPromptClaimable(
                entry,
                root
            )

        if ok == true then

            return true,
                reason
        end

        if reason == "seed removed"
        or reason == "prompt removed"
        or reason == "prompt disabled"
        or reason == "seed visual gone"
        or reason == "seed root removed"
        or reason == "seed root not in workspace"
        or tostring(reason):find("claimed", 1, true) then

            GAG2SeedCollectMarkEntryStale(
                entry,
                reason,
                GAG2_AUTO_COLLECT_SEEDS_STATE.MissingRecentSeconds
            )

            return false,
                reason
        end

        task.wait(
            0.05
        )
    end

    local _, reason =
        GAG2SeedCollectIsPromptClaimable(
            entry,
            root
        )

    return false,
        reason or "not claimable"
end

function GAG2SeedCollectMoveTo(entry)

    local character, root, humanoid =
        GAG2SeedCollectGetCharacterRoot()

    if not root
    or not humanoid
    or type(entry) ~= "table"
    or typeof(entry.Part) ~= "Instance" then

        return false,
            "missing move data"
    end

    local alive, aliveReason =
        GAG2SeedCollectIsEntryAlive(
            entry
        )

    if alive ~= true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            aliveReason,
            GAG2_AUTO_COLLECT_SEEDS_STATE.MissingRecentSeconds
        )

        return false,
            aliveReason
    end

    local targetPosition =
        GAG2SeedCollectGetPromptPosition(
            entry
        )

    if typeof(targetPosition) ~= "Vector3" then

        GAG2SeedCollectMarkEntryStale(
            entry,
            "missing target position",
            GAG2_AUTO_COLLECT_SEEDS_STATE.MissingRecentSeconds
        )

        return false,
            "missing target position"
    end

    local direction =
        root.Position - targetPosition

    direction =
        Vector3.new(
            direction.X,
            0,
            direction.Z
        )

    if direction.Magnitude < 1 then

        direction =
            Vector3.new(
                1,
                0,
                0
            )
    end

    direction =
        direction.Unit

    local claimDistance =
        GAG2SeedCollectGetClaimDistance(
            entry.Prompt
        )

    local standDistance =
        math.clamp(
            claimDistance * 0.55,
            2.75,
            4.25
        )

    local standPosition =
        targetPosition
        + direction * standDistance

    local walkPosition =
        Vector3.new(
            standPosition.X,
            root.Position.Y,
            standPosition.Z
        )

    if GAG2_AUTO_COLLECT_SEEDS_STATE.MovementMode == "Walk" then

        local started =
            os.clock()

        local lastMoveAt =
            0

        local timeout =
            math.max(
                4,
                tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.WalkTimeout)
                or 12
            )

        local refreshDelay =
            math.clamp(
                tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.WalkRefreshDelay)
                or 0.55,
                0.20,
                1.50
            )

        while GAG2_AUTO_COLLECT_SEEDS_STATE.Enabled == true
        and os.clock() - started < timeout do

            alive, aliveReason =
                GAG2SeedCollectIsEntryAlive(
                    entry
                )

            if alive ~= true then

                GAG2SeedCollectMarkEntryStale(
                    entry,
                    aliveReason,
                    GAG2_AUTO_COLLECT_SEEDS_STATE.MissingRecentSeconds
                )

                return false,
                    aliveReason
            end

            local claimable, claimReason =
                GAG2SeedCollectIsPromptClaimable(
                    entry,
                    root
                )

            if claimable == true then

                return true,
                    "walk in range"
            end

            if claimReason == "seed removed"
            or claimReason == "prompt removed"
            or claimReason == "prompt disabled"
            or claimReason == "seed visual gone"
            or claimReason == "seed root removed"
            or claimReason == "seed root not in workspace"
            or tostring(claimReason):find("claimed", 1, true) then

                GAG2SeedCollectMarkEntryStale(
                    entry,
                    claimReason,
                    GAG2_AUTO_COLLECT_SEEDS_STATE.MissingRecentSeconds
                )

                return false,
                    claimReason
            end

            if os.clock() - lastMoveAt >= refreshDelay then

                lastMoveAt =
                    os.clock()

                humanoid:MoveTo(
                    walkPosition
                )
            end

            task.wait(
                0.08
            )
        end

        local claimable, reason =
            GAG2SeedCollectIsPromptClaimable(
                entry,
                root
            )

        if claimable == true then

            return true,
                "walk in range"
        end

        GAG2SeedCollectMarkEntryStale(
            entry,
            reason,
            GAG2_AUTO_COLLECT_SEEDS_STATE.StaleRecentSeconds
        )

        return false,
            reason or "walk timeout"
    end

    root.CFrame =
        CFrame.lookAt(
            standPosition + Vector3.new(0, 3, 0),
            targetPosition
        )

    local claimable, reason =
        GAG2SeedCollectWaitClaimable(
            entry,
            tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.TeleportClaimWait)
            or 1.25
        )

    if claimable ~= true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            reason,
            GAG2_AUTO_COLLECT_SEEDS_STATE.StaleRecentSeconds
        )

        return false,
            reason or "not claimable after teleport"
    end

    return true,
        "teleport in range"
end

function GAG2SeedCollectFirePrompt(prompt)

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then

        return false,
            "bad prompt"
    end

    if type(fireproximityprompt) ~= "function" then

        return false,
            "fireproximityprompt unsupported"
    end

    local mode =
        CleanText(
            GAG2_AUTO_COLLECT_SEEDS_STATE.CollectMode
        )

    if mode == "Hold" then

        local duration =
            math.clamp(
                tonumber(GAG2_AUTO_COLLECT_SEEDS_STATE.HoldDuration)
                or 3.2,
                3,
                15
            )

        local ok =
            pcall(function()

                fireproximityprompt(
                    prompt,
                    duration
                )
            end)

        if ok == true then
            return true, "hold"
        end
    end

    local ok, err =
        pcall(function()

            fireproximityprompt(
                prompt
            )
        end)

    if ok ~= true then

        return false,
            tostring(err)
    end

    return true,
        "instant"
end

function GAG2SeedCollectWaitConfirm(entry, beforeCount)

    local started =
        os.clock()

    while GAG2_AUTO_COLLECT_SEEDS_STATE.Enabled == true
    and os.clock() - started < 5 do

        if type(entry) == "table"
        and typeof(entry.Part) == "Instance"
        and entry.Part.Parent == nil then

            return true,
                "seed removed"
        end

        local nowCount =
            GAG2SeedCollectGetToolCount(
                entry.SeedType
            )

        if nowCount > beforeCount then

            return true,
                "backpack confirmed"
        end

        task.wait(0.1)
    end

    return false,
        "confirmation timeout"
end

function GAG2SeedCollectCycle()

    local state =
        GAG2_AUTO_COLLECT_SEEDS_STATE

    local entry, reason =
        GAG2SeedCollectFindNearest()

    if not entry then

        GAG2SeedCollectSetStatus(
            "Waiting: "
            .. tostring(reason)
        )

        return
    end

    local alive, aliveReason =
        GAG2SeedCollectIsEntryAlive(
            entry
        )

    if alive ~= true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            aliveReason,
            state.MissingRecentSeconds
        )

        GAG2SeedCollectSetStatus(
            "Skipped stale seed: "
            .. tostring(aliveReason)
        )

        return
    end

    state.Recent[entry.Key] =
        os.clock()

    GAG2SeedCollectSetStatus(
        "Collecting "
        .. tostring(entry.SeedType)
        .. " Seed | "
        .. tostring(math.floor(entry.Distance + 0.5))
        .. " studs"
    )

    local beforeCount =
        GAG2SeedCollectGetToolCount(
            entry.SeedType
        )

    local moved, moveInfo =
        GAG2SeedCollectMoveTo(
            entry
        )

    if moved ~= true then

        GAG2SeedCollectSetStatus(
            "Move failed: "
            .. tostring(moveInfo)
        )

        return
    end

    alive, aliveReason =
        GAG2SeedCollectIsEntryAlive(
            entry
        )

    if alive ~= true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            aliveReason,
            state.MissingRecentSeconds
        )

        GAG2SeedCollectSetStatus(
            "Seed disappeared: "
            .. tostring(aliveReason)
        )

        return
    end

    local claimable, claimInfo =
        GAG2SeedCollectWaitClaimable(
            entry,
            1.5
        )

    if claimable ~= true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            claimInfo,
            state.StaleRecentSeconds
        )

        GAG2SeedCollectSetStatus(
            "Not claimable: "
            .. tostring(claimInfo)
        )

        return
    end

    local fired, fireInfo =
        GAG2SeedCollectFirePrompt(
            entry.Prompt
        )

    if fired ~= true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            fireInfo,
            state.StaleRecentSeconds
        )

        GAG2SeedCollectSetStatus(
            "Collect failed: "
            .. tostring(fireInfo)
        )

        return
    end

    local confirmed, confirmInfo =
        GAG2SeedCollectWaitConfirm(
            entry,
            beforeCount
        )

    if confirmed == true then

        GAG2SeedCollectMarkEntryStale(
            entry,
            "confirmed",
            state.MissingRecentSeconds
        )

        GAG2SeedCollectSetStatus(
            "Collected "
            .. tostring(entry.SeedType)
            .. " Seed | "
            .. tostring(confirmInfo)
        )

    else

        GAG2SeedCollectMarkEntryStale(
            entry,
            confirmInfo,
            state.StaleRecentSeconds
        )

        GAG2SeedCollectSetStatus(
            "Not confirmed: "
            .. tostring(confirmInfo)
        )
    end
end

function GAG2SeedCollectStart()

    local state =
        GAG2_AUTO_COLLECT_SEEDS_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        while state.Enabled == true do

            GAG2SeedCollectCycle()

            task.wait(0.2)
        end

        state.Running =
            false

        GAG2SeedCollectSetStatus(
            "Disabled."
        )
    end)
end

function GAG2SeedCollectSetEnabled(value)

    local state =
        GAG2_AUTO_COLLECT_SEEDS_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        GAG2SeedCollectStart()

    else

        GAG2SeedCollectSetStatus(
            "Disabled."
        )
    end

    MarkConfigDirty()
end

function GAG2SeedCollectSetSeedType(value)

    GAG2_AUTO_COLLECT_SEEDS_STATE.SeedType =
        CleanText(value)

    MarkConfigDirty()
end

function GAG2SeedCollectSetMovementMode(value)

    GAG2_AUTO_COLLECT_SEEDS_STATE.MovementMode =
        CleanText(value)

    MarkConfigDirty()
end

function GAG2SeedCollectSetCollectMode(value)

    GAG2_AUTO_COLLECT_SEEDS_STATE.CollectMode =
        CleanText(value)

    MarkConfigDirty()
end

function GAG2SeedCollectSetHoldDuration(value)

    GAG2_AUTO_COLLECT_SEEDS_STATE.HoldDuration =
        math.clamp(
            tonumber(value)
            or 3.2,
            3,
            15
        )

    MarkConfigDirty()
end

function GAG2RestoreSeedCollectState()

    task.defer(function()

        local state =
            GAG2_AUTO_COLLECT_SEEDS_STATE

        if Toggles.HolyGAG2AutoCollectSeeds then

            state.Enabled =
                Toggles.HolyGAG2AutoCollectSeeds.Value == true
        end

        if Options.HolyGAG2SeedCollectType then

            state.SeedType =
                CleanText(
                    Options.HolyGAG2SeedCollectType.Value
                )
        end

        if Options.HolyGAG2SeedCollectMovement then

            state.MovementMode =
                CleanText(
                    Options.HolyGAG2SeedCollectMovement.Value
                )
        end

        if Options.HolyGAG2SeedCollectMode then

            state.CollectMode =
                CleanText(
                    Options.HolyGAG2SeedCollectMode.Value
                )
        end

        if Options.HolyGAG2SeedCollectHoldDuration then

            state.HoldDuration =
                tonumber(
                    Options.HolyGAG2SeedCollectHoldDuration.Value
                )
                or state.HoldDuration
        end

        if state.Enabled == true then

            GAG2SeedCollectStart()

        else

            GAG2SeedCollectSetStatus(
                "Ready."
            )
        end
    end)
end

function GAG2RestoreShopAutosaveState()

    task.defer(function()

        for category in pairs(GAG2_SHOP_CATEGORIES) do

            local toggleName =
                "HolyGAG2AutoBuy"
                .. tostring(category)

            local dropdownName =
                "HolyGAG2Shop"
                .. tostring(category)

            if Toggles[toggleName] then

                GAG2_SHOP_STATE.Enabled[category] =
                    Toggles[toggleName].Value == true
            end

            if Options[dropdownName] then

                GAG2_SHOP_STATE.Selected[category] =
                    GAG2ShopNormalizeSelection(
                        Options[dropdownName].Value
                    )
            end
        end

        GAG2ShopStart()

        task.wait(
            0.5
        )

        GAG2ShopEnqueueAllSelectedInStock()
    end)
end

local function SniperFindWildBuyPacket()

    if SniperState.BuyPacket then

        local ok, fireFunction =
            pcall(function()

                return SniperState.BuyPacket.Fire
            end)

        if ok == true
        and type(fireFunction) == "function" then
            return SniperState.BuyPacket
        end
    end

    local packets =
        SniperFindPacketTable()

    if not packets then

        SniperState.BuyPacket =
            nil

        SniperState.BuyPacketSource =
            tostring(SniperState.PacketSource)

        return nil
    end

    local results =
        {}

    SniperSearchWildPackets(
        packets,
        {},
        0,
        "Packets",
        results
    )

    table.sort(results, function(a, b)

        return tonumber(a.Score or 0)
            > tonumber(b.Score or 0)
    end)

    if #results <= 0 then

        SniperState.BuyPacket =
            nil

        SniperState.BuyPacketSource =
            "wild pet packet not found"

        return nil
    end

    local best =
        results[1]

    SniperState.BuyPacket =
        best.Packet

    SniperState.BuyPacketSource =
        tostring(best.Name)
        .. " @ "
        .. tostring(best.Path)
        .. " | "
        .. tostring(SniperState.PacketSource)

    return SniperState.BuyPacket
end

local function SniperGetCharacterRoot()

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not character
    or not root
    or root:IsA("BasePart") ~= true then
        return nil, nil
    end

    return character, root
end

function GAG2GuiObjectVisible(instance)

    if typeof(instance) ~= "Instance" then
        return false
    end

    local current =
        instance

    while current
    and current ~= game do

        if current:IsA("ScreenGui") then

            local enabled =
                true

            local ok =
                pcall(function()

                    enabled =
                        current.Enabled == true
                end)

            if ok == true
            and enabled ~= true then
                return false
            end
        end

        if current:IsA("GuiObject") then

            local visible =
                true

            local ok =
                pcall(function()

                    visible =
                        current.Visible == true
                end)

            if ok == true
            and visible ~= true then
                return false
            end
        end

        current =
            current.Parent
    end

    return true
end

local function GAG2FindVisibleTextObjectByKeywords(keywords, maxScan)

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil, "", ""
    end

    local scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned = scanned + 1

        if scanned > (
            tonumber(maxScan)
            or 9000
        ) then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, rawText =
                pcall(function()

                    return descendant.Text
                end)

            local text =
                ok == true
                and CleanText(rawText)
                or ""

            local lowerText =
                text:lower()

            if text ~= ""
            and GAG2GuiObjectVisible(descendant) == true then

                for _, keyword in ipairs(keywords or {}) do

                    local lowerKeyword =
                        tostring(keyword or ""):lower()

                    if lowerKeyword ~= ""
                    and lowerText:find(lowerKeyword, 1, true) then

                        return descendant,
                            text,
                            lowerText
                    end
                end
            end
        end
    end

    return nil, "", ""
end

local function GAG2IsFullyLoadedTextVisible()

    local object, text =
        GAG2FindVisibleTextObjectByKeywords(
            {
                "fully loaded",
            },
            9000
        )

    return object ~= nil,
        text,
        object
end

function GAG2GetPlayScreenTextObject()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil, ""
    end

    local bestObject =
        nil

    local bestText =
        ""

    local scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 12000 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, rawText =
                pcall(function()

                    return descendant.Text
                end)

            local textValue =
                ok == true
                and CleanText(
                    tostring(rawText or "")
                        :gsub("<[^>]->", "")
                        :gsub("<.->", "")
                )
                or ""

            local lowerText =
                textValue:lower()

            if textValue ~= "" then

                local isLoadingText =
                    lowerText:find("press any key", 1, true)
                    or lowerText:find("key to play", 1, true)
                    or lowerText:find("click to skip", 1, true)
                    or lowerText:find("click to skip!", 1, true)
                    or lowerText:find("fully loaded", 1, true)
                    or lowerText:find("loading player data", 1, true)
                    or (
                        lowerText:find("press", 1, true)
                        and lowerText:find("play", 1, true)
                    )

                if isLoadingText then

                    bestObject =
                        descendant

                    bestText =
                        textValue

                    if GAG2GuiObjectVisible(descendant) == true then

                        return descendant,
                            textValue
                    end
                end
            end
        end
    end

    return bestObject,
        bestText
end

function GAG2IsPlayScreenBlocking()

    local object, text =
        GAG2GetPlayScreenTextObject()

    if object then
        return true, text, object
    end

    return false, "", nil
end

function GAG2GetPlayScreenClickPoint(object)

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(
            1280,
            720
        )

    local x =
        math.floor(viewport.X / 2)

    local y =
        math.floor(viewport.Y / 2)

    if typeof(object) == "Instance"
    and object:IsA("GuiObject") then

        local ok =
            pcall(function()

                local position =
                    object.AbsolutePosition

                local size =
                    object.AbsoluteSize

                if typeof(position) == "Vector2"
                and typeof(size) == "Vector2"
                and size.X > 0
                and size.Y > 0 then

                    x =
                        math.floor(
                            position.X + (size.X / 2)
                        )

                    y =
                        math.floor(
                            position.Y + (size.Y / 2)
                        )
                end
            end)

        if ok ~= true then

            x =
                math.floor(viewport.X / 2)

            y =
                math.floor(viewport.Y * 0.70)
        end
    end

    return x,
        y
end

function GAG2PressPlayScreen()

    -- Disabled on purpose.
    -- Physical key/mouse input is unsafe during GAG2 loading because it can hit
    -- normal UI after the overlay changes.

    if type(GAG2FireFinishLoadingRemoteSafe) == "function" then

        return GAG2FireFinishLoadingRemoteSafe()
    end

    return false
end

function GAG2GetLoadingGui()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil
    end

    return playerGui:FindFirstChild("LoadingGui")
end

function GAG2ReadLoadingAttributes()

    -- Loading-screen logic removed.
    -- Never block sniper/shop/farm systems based on loading attributes.

    return false,
        true
end

function GAG2IsLoadingPlayScreenVisible()

    -- Loading-screen logic removed.
    -- Do not scan PlayerGui and do not block sniper buying.

    return false
end

local function GAG2GetClickableGuiAncestor(object)

    local current =
        object

    while typeof(current) == "Instance"
    and current ~= game do

        if current:IsA("TextButton")
        or current:IsA("ImageButton") then

            return current
        end

        current =
            current.Parent
    end

    return nil
end

local function GAG2ActivateLoadingGuiObject(object)

    local button =
        GAG2GetClickableGuiAncestor(
            object
        )

    if not button then
        return false
    end

    local activated =
        false

    pcall(function()

        button:Activate()

        activated =
            true
    end)

    if type(firesignal) == "function" then

        pcall(function()

            firesignal(
                button.MouseButton1Click
            )

            activated =
                true
        end)

        pcall(function()

            firesignal(
                button.Activated
            )

            activated =
                true
        end)
    end

    return activated
end

function GAG2FindLoadingSkipBindable()

    local candidateRoots = {
        ReplicatedStorage,
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
        or nil,
    }

    for _, root in ipairs(candidateRoots) do

        if typeof(root) == "Instance" then

            local scanned =
                0

            for _, descendant in ipairs(root:GetDescendants()) do

                scanned = scanned + 1

                if scanned > 6000 then
                    break
                end

                if descendant:IsA("BindableEvent") then

                    local name =
                        tostring(descendant.Name or ""):lower()

                    local path =
                        PathOf(descendant):lower()

                    local looksLikeSkip =
                        (
                            name:find("skip", 1, true)
                            or path:find("skip", 1, true)
                            or name:find("finish", 1, true)
                            or path:find("finish", 1, true)
                        )
                        and (
                            name:find("loading", 1, true)
                            or path:find("loading", 1, true)
                            or name:find("load", 1, true)
                            or path:find("load", 1, true)
                        )

                    if looksLikeSkip then

                        return descendant
                    end
                end
            end
        end
    end

    return nil
end

function GAG2FireLoadingSkipBindable(reason)

    local bindable =
        GAG2FindLoadingSkipBindable()

    if not bindable then
        return false,
            "no loading skip bindable"
    end

    local ok, err =
        pcall(function()

            bindable:Fire(
                tostring(reason or "HOLY_AUTO_SKIP")
            )
        end)

    if ok == true then

        return true,
            "bindable: "
            .. PathOf(bindable)
    end

    return false,
        tostring(err)
end

function GAG2FindLoadingSkipGuiObject()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil,
            "PlayerGui missing"
    end

    local preferredRoots =
        {}

    local loadingGui =
        playerGui:FindFirstChild("LoadingGui")

    if loadingGui then

        table.insert(
            preferredRoots,
            loadingGui
        )
    end

    table.insert(
        preferredRoots,
        playerGui
    )

    local keywords = {
        "skip",
        "click to skip",
        "click to skip!",
        "fully loaded",
        "press any key",
        "key to play",
        "play",
        "start",
        "continue",
    }

    for _, root in ipairs(preferredRoots) do

        if typeof(root) == "Instance" then

            local scanned =
                0

            for _, descendant in ipairs(root:GetDescendants()) do

                scanned = scanned + 1

                if scanned > 10000 then
                    break
                end

                if descendant:IsA("TextButton")
                or descendant:IsA("ImageButton")
                or descendant:IsA("TextLabel")
                or descendant:IsA("TextBox") then

                    local rawText =
                        ""

                    pcall(function()

                        rawText =
                            tostring(descendant.Text or "")
                    end)

                    local text =
                        CleanText(
                            rawText
                                :gsub("<[^>]->", "")
                                :gsub("<.->", "")
                        )

                    local lowerText =
                        text:lower()

                    if GAG2GuiObjectVisible(descendant) == true then

                        for _, keyword in ipairs(keywords) do

                            if lowerText:find(
                                tostring(keyword):lower(),
                                1,
                                true
                            ) then

                                return descendant,
                                    "text: "
                                    .. tostring(text)
                                    .. " | "
                                    .. PathOf(descendant)
                            end
                        end

                        local lowerPath =
                            PathOf(descendant):lower()

                        if lowerPath:find("loading", 1, true)
                        and (
                            lowerPath:find("skip", 1, true)
                            or lowerPath:find("play", 1, true)
                            or lowerPath:find("continue", 1, true)
                            or lowerPath:find("button", 1, true)
                        ) then

                            return descendant,
                                "path: "
                                .. PathOf(descendant)
                        end
                    end
                end
            end
        end
    end

    return nil,
        "no visible loading skip gui object"
end

function GAG2SendLoadingScreenClick()

    local bindableOk, bindableInfo =
        GAG2FireLoadingSkipBindable(
            "HOLY_AUTO_SKIP"
        )

    if bindableOk == true then

        return true,
            tostring(bindableInfo)
    end

    local object, objectInfo =
        GAG2FindLoadingSkipGuiObject()

    if not object then

        return false,
            tostring(objectInfo)
    end

    local ok =
        GAG2ActivateLoadingGuiObject(
            object
        )

    if ok == true then

        return true,
            "direct gui: "
            .. tostring(objectInfo)
    end

    return false,
        "direct gui activation failed: "
        .. tostring(objectInfo)
end

function GAG2FireFinishLoadingRemoteSafe()

    -- Forced loading completion is intentionally disabled.
    -- HOLY now waits for genuine game/client readiness.

    return false,
        "forced loading finish disabled"
end

function GAG2RestoreCameraSoft()

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    if not character then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local camera =
        workspace.CurrentCamera

    if not camera
    or not humanoid then
        return false
    end

    pcall(function()

        camera.CameraType =
            Enum.CameraType.Custom

        camera.CameraSubject =
            humanoid
    end)

    return true
end

function GAG2CleanupLoadingGuiVisualOnly()

    -- Loading-screen cleanup removed.
    -- Do not disable LoadingGui because it can desync camera/game state.

    return false
end

function GAG2ForceClearLoadingGui()

    -- Loading-screen cleanup removed.

    return false
end

function GAG2HardFinishLoading(reason)

    -- Never spoof loading attributes.
    -- Never disable the game's LoadingGui.
    -- Never force the camera to Custom as loading proof.

    if type(GAG2_AUTO_TP_MIDDLE_FARM_STATE) == "table" then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            "forced loading finish blocked"
    end

    return false,
        "forced loading finish disabled"
end

function GAG2AutoPlayLoadingStep()

    -- Loading-screen automation removed.
    -- This function is kept only so old calls do not error.

    GAG2_AUTO_PLAY_STATE =
        type(GAG2_AUTO_PLAY_STATE) == "table"
        and GAG2_AUTO_PLAY_STATE
        or {}

    GAG2_AUTO_PLAY_STATE.Finished =
        true

    if type(SniperState) == "table" then

        SniperState.PlayScreenClearAt =
            os.clock()
    end

    return true
end

function GAG2ClientReadyForBuy()

    local loadingActive =
        false

    local loadingDone =
        false

    pcall(function()

        loadingActive =
            LOCAL_PLAYER:GetAttribute("LoadingScreenActive") == true

        loadingDone =
            LOCAL_PLAYER:GetAttribute("LoadingScreenDone") == true
    end)

    local camera =
        workspace.CurrentCamera

    local cameraCustom =
        camera
        and camera.CameraType == Enum.CameraType.Custom

    local cameraScriptable =
        camera
        and camera.CameraType == Enum.CameraType.Scriptable

    local loadingCleared =
        loadingActive ~= true
        and (
            loadingDone == true
            or cameraCustom == true
        )

    if loadingCleared ~= true then

        if type(SniperState) == "table" then

            SniperState.PlayScreenClearAt =
                0
        end

        return false,
            "Waiting for loading..."
            .. " active="
            .. tostring(loadingActive)
            .. " done="
            .. tostring(loadingDone)
            .. " camera="
            .. (
                cameraScriptable == true
                and "Scriptable"
                or cameraCustom == true
                and "Custom"
                or "Other"
            )
    end

    if type(SniperState) == "table"
    and tonumber(SniperState.PlayScreenClearAt or 0) <= 0 then

        SniperState.PlayScreenClearAt =
            os.clock()

        return false,
            "Loading done. Settling..."
    end

    local grace =
        tonumber(
            SniperState
            and SniperState.PlayScreenClearGrace
            or 0.35
        )
        or 0.35

    if os.clock() - tonumber(SniperState.PlayScreenClearAt or 0) < grace then

        return false,
            "Loading done. Settling..."
    end

    return true,
        "Ready."
end

function GAG2ReadyForFarmTeleport()

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then

        return false,
            "missing character"
    end

    return true,
        "character ready"
end

function GAG2StartLoadingGuiCleaner()

    -- Loading-screen cleaner removed.
    -- Do not run background loops, camera restores, GUI cleanup, or finish remotes.

    GAG2_LOADING_GUI_CLEANER_RUNNING =
        false

    return false
end

local function SniperReadyToHop()

    if not SniperGetSpawnsFolder()
    or not SniperGetRefFolder() then

        return false,
            "Waiting for pets..."
    end

    return true,
        "Ready."
end

local function SniperReadyToBuy()

    local elapsed =
        os.clock()
        - (
            tonumber(SniperState.StartedAt)
            or os.clock()
        )

    local startupDelay =
        tonumber(SniperState.StartupBuyDelay)
        or 8

    if elapsed < startupDelay then

        return false,
            "Starting..."
    end

    local _, root =
        SniperGetCharacterRoot()

    if not root then

        return false,
            "Waiting for character..."
    end

    if not SniperGetSpawnsFolder()
    or not SniperGetRefFolder() then

        return false,
            "Waiting for pets..."
    end

    return true,
        "Ready."
end

local function SniperGetEntryTamePosition(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local ref =
        entry.Ref

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        local uuid =
            CleanText(entry.UUID)

        if uuid ~= "" then

            ref =
                SniperFindRef(
                    uuid
                )
        end
    end

    local refPosition =
        SniperGetPosition(
            ref
        )

    if typeof(refPosition) == "Vector3" then
        return refPosition
    end

    if typeof(entry.Position) == "Vector3" then
        return entry.Position
    end

    local spawn =
        entry.Spawn

    if typeof(spawn) == "Instance" then

        local spawnPosition =
            SniperGetPosition(
                spawn
            )

        if typeof(spawnPosition) == "Vector3" then
            return spawnPosition
        end
    end

    return SniperGetPosition(
        entry.Instance
    )
end

function SniperGetSafeTameCFrame(targetPosition)

    if typeof(targetPosition) ~= "Vector3" then
        return nil
    end

    local character, root =
        SniperGetCharacterRoot()

    local ignoreList =
        {}

    if character then

        table.insert(
            ignoreList,
            character
        )
    end

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances =
        ignoreList

    rayParams.IgnoreWater =
        true

    local offsets = {
        Vector3.new(6, 0, 0),
        Vector3.new(-6, 0, 0),
        Vector3.new(0, 0, 6),
        Vector3.new(0, 0, -6),
        Vector3.new(4, 0, 4),
        Vector3.new(-4, 0, 4),
        Vector3.new(4, 0, -4),
        Vector3.new(-4, 0, -4),
        Vector3.new(0, 0, 0),
    }

    local bestPosition =
        nil

    for _, offset in ipairs(offsets) do

        local rayOrigin =
            targetPosition
            + offset
            + Vector3.new(
                0,
                35,
                0
            )

        local result =
            workspace:Raycast(
                rayOrigin,
                Vector3.new(
                    0,
                    -90,
                    0
                ),
                rayParams
            )

        if result
        and typeof(result.Position) == "Vector3" then

            local verticalDifference =
                math.abs(
                    result.Position.Y - targetPosition.Y
                )

            if verticalDifference <= 18 then

                bestPosition =
                    result.Position
                    + Vector3.new(
                        0,
                        3.25,
                        0
                    )

                break
            end
        end
    end

    if typeof(bestPosition) ~= "Vector3" then

        return nil
    end

    local lookTarget =
        Vector3.new(
            targetPosition.X,
            bestPosition.Y,
            targetPosition.Z
        )

    if (bestPosition - lookTarget).Magnitude < 0.1 then

        lookTarget =
            bestPosition
            + Vector3.new(
                0,
                0,
                -1
            )
    end

    return CFrame.new(
        bestPosition,
        lookTarget
    ),
    bestPosition
end

function SniperAimAtPetPosition(targetPosition)

    if typeof(targetPosition) ~= "Vector3" then
        return false
    end

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return false
    end

    local lookTarget =
        Vector3.new(
            targetPosition.X,
            root.Position.Y,
            targetPosition.Z
        )

    if (root.Position - lookTarget).Magnitude <= 0.1 then
        return false
    end

    local ok =
        pcall(function()

            character:PivotTo(
                CFrame.new(
                    root.Position,
                    lookTarget
                )
            )
        end)

    local camera =
        workspace.CurrentCamera

    if camera then

        pcall(function()

            camera.CFrame =
                CFrame.new(
                    camera.CFrame.Position,
                    targetPosition + Vector3.new(0, 1.75, 0)
                )
        end)
    end

    return ok == true
end


local function SniperStopCharacterMotion(root)

    if typeof(root) ~= "Instance" then
        return
    end

    pcall(function()

        root.AssemblyLinearVelocity =
            Vector3.zero

        root.AssemblyAngularVelocity =
            Vector3.zero
    end)
end



--==================================================
-- [4.55] AUTO SKIP LOADING + AUTO TP MIDDLE FARM
-- Settings-tab controlled. No GUI scanning. No remote spoofing.
--==================================================

function GAG2FarmStripRichText(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2FarmVecText(position)

    if typeof(position) ~= "Vector3" then
        return "nil"
    end

    return string.format(
        "%.1f, %.1f, %.1f",
        position.X,
        position.Y,
        position.Z
    )
end

function GAG2ResolveOwnFarmPlot()

    local gardens =
        workspace:FindFirstChild("Gardens")

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not gardens then
        return nil, "workspace.Gardens missing"
    end

    if not playerGui then
        return nil, "PlayerGui missing"
    end

    for _, gui in ipairs(playerGui:GetChildren()) do

        if gui:IsA("BillboardGui")
        and tostring(gui.Name):match("^Plot%d+$") then

            for _, descendant in ipairs(gui:GetDescendants()) do

                if descendant:IsA("TextLabel")
                or descendant:IsA("TextButton") then

                    local text =
                        GAG2FarmStripRichText(
                            descendant.Text
                        ):lower()

                    if text:find("your garden", 1, true) then

                        local plot =
                            gardens:FindFirstChild(
                                gui.Name
                            )

                        if plot then

                            return plot,
                                "billboard "
                                .. tostring(gui.Name)
                        end
                    end
                end
            end
        end
    end

    return nil, "own garden billboard not found"
end

function GAG2IsMiddleFarmPart(part)

    if typeof(part) ~= "Instance"
    or part:IsA("BasePart") ~= true then
        return false
    end

    local path =
        PathOf(part)

    if path:find("GardenZonePart", 1, true) then
        return false
    end

    if path:find(".Plants.", 1, true) then
        return false
    end

    if path:find("PlantAreaColumn", 1, true) then
        return true
    end

    if path:find("PlantArea", 1, true) then
        return true
    end

    if path:find("BedSection", 1, true) then
        return true
    end

    return false
end

function GAG2MiddleFarmGetStandOffset(root, humanoid)

    local rootHalf =
        1.0

    if root
    and root:IsA("BasePart") then

        rootHalf =
            math.max(
                0.75,
                root.Size.Y / 2
            )
    end

    local hipHeight =
        humanoid
        and tonumber(humanoid.HipHeight)
        or 0

    return math.clamp(
        rootHalf + math.max(hipHeight, 0) + 1.15,
        2.35,
        3.10
    )
end

function GAG2GetOwnFarmMiddlePosition()

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then
        return nil, plotReason
    end

    local character, root =
        SniperGetCharacterRoot()

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    local standOffset =
        GAG2MiddleFarmGetStandOffset(
            root,
            humanoid
        )

    local points =
        {}

    for _, descendant in ipairs(ownPlot:GetDescendants()) do

        if GAG2IsMiddleFarmPart(descendant) == true then

            table.insert(
                points,
                descendant.Position
            )
        end
    end

    local center =
        nil

    if #points > 0 then

        local total =
            Vector3.zero

        for _, point in ipairs(points) do

            total = total + point
        end

        center =
            total / #points

    else

        local ok, cf =
            pcall(function()

                return ownPlot:GetBoundingBox()
            end)

        if ok == true
        and typeof(cf) == "CFrame" then

            center =
                cf.Position

        else

            return nil, "farm middle failed"
        end
    end

    local excludeList =
        {}

    if character then

        table.insert(
            excludeList,
            character
        )
    end

    local plants =
        ownPlot:FindFirstChild("Plants")

    if plants then

        table.insert(
            excludeList,
            plants
        )
    end

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances =
        excludeList

    rayParams.IgnoreWater =
        true

    local rayResult =
        workspace:Raycast(
            center + Vector3.new(0, 90, 0),
            Vector3.new(0, -220, 0),
            rayParams
        )

    if rayResult
    and rayResult.Position
    and typeof(rayResult.Instance) == "Instance"
    and rayResult.Instance:IsDescendantOf(ownPlot) then

        local hitPath =
            PathOf(rayResult.Instance)

        if not hitPath:find(".Plants.", 1, true)
        and not hitPath:find("GardenZonePart", 1, true) then

            return rayResult.Position
                + Vector3.new(0, standOffset, 0),
                "ground | "
                .. tostring(plotReason)
                .. " | hit "
                .. hitPath
        end
    end

    return center + Vector3.new(0, standOffset, 0),
        "fallback | "
        .. tostring(plotReason)
end

function GAG2MiddleFarmLoadingSnapshot(requirePlot)

    local active =
        false

    local done =
        false

    pcall(function()

        active =
            LOCAL_PLAYER:GetAttribute("LoadingScreenActive") == true

        done =
            LOCAL_PLAYER:GetAttribute("LoadingScreenDone") == true
    end)

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    local characterReady =
        character ~= nil
        and humanoid ~= nil
        and humanoid.Health > 0
        and root ~= nil
        and root:IsA("BasePart")

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    local loadingGui =
        playerGui
        and playerGui:FindFirstChild("LoadingGui")

    local loadingGuiBlocking =
        false

    if loadingGui then

        if loadingGui:IsA("ScreenGui") then

            pcall(function()

                loadingGuiBlocking =
                    loadingGui.Enabled == true
            end)

        elseif loadingGui:IsA("GuiObject") then

            pcall(function()

                loadingGuiBlocking =
                    loadingGui.Visible == true
            end)

        else

            loadingGuiBlocking =
                true
        end
    end

    local camera =
        workspace.CurrentCamera

    local cameraType =
        camera
        and tostring(camera.CameraType)
        or "nil"

    local cameraScriptable =
        camera
        and camera.CameraType == Enum.CameraType.Scriptable

    local cameraCustom =
        camera
        and camera.CameraType == Enum.CameraType.Custom

    local cameraSubject =
        camera
        and camera.CameraSubject

    local cameraSubjectReady =
        cameraCustom == true
        and (
            cameraSubject == humanoid
            or cameraSubject == root
            or cameraSubject == character
        )

    local plotReady =
        requirePlot ~= true
        or typeof(
            GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTarget
        ) == "Vector3"

    local loadingSignal =
        active == true
        or cameraScriptable == true
        or (
            loadingGuiBlocking == true
            and done ~= true
        )

    local guiCleared =
        loadingGuiBlocking ~= true
        or done == true

    local ready =
        active ~= true
        and guiCleared == true
        and cameraCustom == true
        and cameraSubjectReady == true
        and characterReady == true
        and plotReady == true

    return {
        Active = active,
        Done = done,

        LoadingGui = loadingGui,
        LoadingGuiBlocking = loadingGuiBlocking,

        CameraType = cameraType,
        CameraScriptable = cameraScriptable,
        CameraCustom = cameraCustom,
        CameraSubjectReady = cameraSubjectReady,

        CharacterReady = characterReady,
        PlotReady = plotReady,

        LoadingSignal = loadingSignal,
        Ready = ready,
    }
end

function GAG2AutoSkipLoadingEnabled()

    if Toggles.HolyGAG2AutoSkipLoading then

        return Toggles.HolyGAG2AutoSkipLoading.Value == true
    end

    -- Default ON before SaveManager/controls fully settle.
    return true
end

function GAG2AutoTpMiddleFarmEnabled()

    return Toggles.HolyGAG2AutoTpMiddleFarm
        and Toggles.HolyGAG2AutoTpMiddleFarm.Value == true
end

function GAG2MiddleFarmWorkerShouldContinue(forceTp)

    if forceTp == true then
        return true
    end

    return GAG2AutoSkipLoadingEnabled() == true
        or GAG2AutoTpMiddleFarmEnabled() == true
end

function GAG2MiddleFarmPivotTo(position)

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return false, "missing character/root"
    end

    if typeof(position) ~= "Vector3" then
        return false, "bad target"
    end

    local lookVector =
        root.CFrame.LookVector

    if typeof(lookVector) ~= "Vector3"
    or lookVector.Magnitude <= 0 then

        lookVector =
            Vector3.new(0, 0, -1)
    end

    local targetCFrame =
        CFrame.new(
            position,
            position + lookVector
        )

    local ok, err =
        pcall(function()

            character:PivotTo(
                targetCFrame
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                root.CFrame =
                    targetCFrame
            end)
    end

    if ok ~= true then
        return false, tostring(err)
    end

    SniperStopCharacterMotion(
        root
    )

    return true, "teleported"
end

function GAG2MiddleFarmGetMovementMode()

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    local mode =
        CleanText(
            state.MovementMode
        )

    if Options.HolyGAG2AutoMiddleFarmMode
    and Options.HolyGAG2AutoMiddleFarmMode.Value ~= nil then

        mode =
            CleanText(
                Options.HolyGAG2AutoMiddleFarmMode.Value
            )
    end

    if mode == "Walk" then

        state.MovementMode =
            "Walk"

        return "Walk"
    end

    state.MovementMode =
        "Teleport"

    return "Teleport"
end

function GAG2MiddleFarmWalkTo(position)

    if typeof(position) ~= "Vector3" then
        return false, "bad target"
    end

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return false, "missing character/root"
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return false, "missing humanoid"
    end

    local started =
        os.clock()

    local lastMoveTo =
        0

    while os.clock() - started < 12 do

        character, root =
            SniperGetCharacterRoot()

        if not character
        or not root then
            return false, "lost character/root"
        end

        humanoid =
            character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            return false, "lost humanoid"
        end

        local distance =
            (root.Position - position).Magnitude

        if distance <= 7 then
            break
        end

        if os.clock() - lastMoveTo >= 0.35 then

            lastMoveTo =
                os.clock()

            humanoid:MoveTo(
                position
            )
        end

        task.wait(
            0.12
        )
    end

    local _, finalRoot =
        SniperGetCharacterRoot()

    if finalRoot then

        SniperStopCharacterMotion(
            finalRoot
        )

        if (finalRoot.Position - position).Magnitude <= 10 then
            return true, "walked"
        end
    end

    return false, "walk timeout"
end

function GAG2MiddleFarmMoveTo(position)

    if GAG2MiddleFarmGetMovementMode() == "Walk" then

        return GAG2MiddleFarmWalkTo(
            position
        )
    end

    return GAG2MiddleFarmPivotTo(
        position
    )
end

function GAG2MiddleFarmGetHoldPoint()

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(1280, 720)

    local x =
        math.floor(viewport.X * 0.52)

    local y =
        math.floor(viewport.Y * 0.58)

    return x,
        y,
        viewport
end

function GAG2MiddleFarmReleaseSkipHold(reason)

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if state.HoldingSkip ~= true then
        return
    end

    state.HoldingSkip =
        false

    if VirtualInputManager then

        pcall(function()

            VirtualInputManager:SendMouseButtonEvent(
                tonumber(state.HoldX) or 0,
                tonumber(state.HoldY) or 0,
                0,
                false,
                game,
                1
            )
        end)
    end
end

function GAG2MiddleFarmPressSkipHold()

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if state.HoldingSkip == true then

        return true,
            "already holding"
    end

    if not VirtualInputManager then

        state.LastResult =
            "VirtualInputManager missing"

        return false,
            "VirtualInputManager missing"
    end

    local x, y =
        GAG2MiddleFarmGetHoldPoint()

    local ok, err =
        pcall(function()

            VirtualInputManager:SendMouseButtonEvent(
                x,
                y,
                0,
                true,
                game,
                1
            )
        end)

    if ok ~= true then

        state.LastResult =
            "loading hold failed: "
            .. tostring(err)

        return false,
            tostring(err)
    end

    state.HoldingSkip =
        true

    state.HoldStartAt =
        os.clock()

    state.HoldX =
        x

    state.HoldY =
        y

    state.LastResult =
        "loading hold active"

    return true,
        "mouse hold"
end

function GAG2TeleportToMiddleFarmOnce(reason)

    local started =
        os.clock()

    local position =
        nil

    local positionReason =
        "not resolved"

    while os.clock() - started < 12 do

        local character, root =
            SniperGetCharacterRoot()

        local resolvedPosition, resolvedReason =
            GAG2GetOwnFarmMiddlePosition()

        if character
        and root
        and typeof(resolvedPosition) == "Vector3" then

            position =
                resolvedPosition

            positionReason =
                tostring(resolvedReason)

            break
        end

        positionReason =
            tostring(resolvedReason)

        task.wait(
            0.08
        )
    end

    if typeof(position) ~= "Vector3" then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            tostring(positionReason)

        return false,
            tostring(positionReason)
    end

    local mode =
        GAG2MiddleFarmGetMovementMode()

    local ok, err =
        GAG2MiddleFarmMoveTo(
            position
        )

    if ok ~= true then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            "middle move failed: "
            .. tostring(err)

        return false,
            tostring(err)
    end

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTeleportAt =
        os.clock()

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTarget =
        position

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTargetReason =
        positionReason

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
        "moved by "
        .. tostring(mode)
        .. ": "
        .. tostring(positionReason)

    print(
        "[HOLY]",
        "Auto Middle Farm",
        "| mode:",
        tostring(mode),
        "| reason:",
        tostring(reason or "manual"),
        "| target:",
        GAG2FarmVecText(position),
        "|",
        tostring(positionReason)
    )

    return true,
        positionReason
end

function GAG2StartMiddleFarmLoadingWorker(reason, forceTp)

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if state.Running == true then
        return false
    end

    if GAG2MiddleFarmWorkerShouldContinue(forceTp) ~= true then
        return false
    end

    state.Running =
        true

    task.spawn(function()

        local started =
            os.clock()

        local targetPosition =
            nil

        local targetReason =
            "not resolved"

        local lastTargetRefresh =
            0

        local earlyTeleportDone =
            false

        local loadingFinished =
            false

        local finishCandidateAt =
            0

        local postLoadWatchUntil =
            0

        local postLoadRepairUsed =
            false

        local postLoadRepairTries =
            0

        local lastPostLoadRepairAt =
            0

        local lastHoldReleasedAt =
            0

        local lastCharacter =
            LOCAL_PLAYER
            and LOCAL_PLAYER.Character

        state.LoadingStartedAt =
            started

        state.LoadingFinished =
            false

        state.LoadingFinishedAt =
            0

        state.LoadingFinishReason =
            "waiting"

        state.SawLoadingSignal =
            false

        state.FinishCandidateAt =
            0

        state.SkipStarted =
            false

        state.SkipSucceeded =
            false

        state.SkipAttempts =
            0

        state.SkipSuccessReason =
            ""

        state.HoldingSkip =
            false

        state.HoldStartAt =
            0

        state.LastResult =
            "loading worker active"

        local function autoTpNeeded()

            return forceTp == true
        end

        local function resolveTarget(forceRefresh)

            if autoTpNeeded() ~= true then
                return
            end

            local now =
                os.clock()

            local refreshInterval =
                typeof(targetPosition) == "Vector3"
                and tonumber(state.TargetRefreshInterval or 2)
                or tonumber(state.TargetResolveRetryInterval or 0.35)

            if forceRefresh ~= true
            and now - lastTargetRefresh < refreshInterval then
                return
            end

            lastTargetRefresh =
                now

            local resolvedPosition, resolvedReason =
                GAG2GetOwnFarmMiddlePosition()

            if typeof(resolvedPosition) == "Vector3" then

                targetPosition =
                    resolvedPosition

                targetReason =
                    tostring(resolvedReason or "resolved")

                state.LastTarget =
                    targetPosition

                state.LastTargetReason =
                    targetReason

            else

                targetPosition =
                    nil

                targetReason =
                    tostring(resolvedReason or "own farm unresolved")

                state.LastTarget =
                    nil

                state.LastTargetReason =
                    targetReason
            end
        end

        local function keepMiddle(now, afterLoading)

            if autoTpNeeded() ~= true then
                return
            end

            resolveTarget(
                false
            )

            local _, root =
                SniperGetCharacterRoot()

            if not root
            or typeof(targetPosition) ~= "Vector3" then
                return
            end

            local distance =
                (root.Position - targetPosition).Magnitude

            local threshold =
                afterLoading == true
                and tonumber(state.PostLoadRepairDistance or 12)
                or tonumber(state.EarlyKeepDistance or 8)

            local shouldTeleport =
                earlyTeleportDone ~= true
                or distance > threshold

            if shouldTeleport ~= true then
                return
            end

            if afterLoading == true
            and now - lastPostLoadRepairAt < tonumber(state.PostLoadRepairRetryInterval or 0.50) then

                return
            end

            local ok, err =
                GAG2MiddleFarmPivotTo(
                    targetPosition
                )

            if ok == true then

                earlyTeleportDone =
                    true

                state.LastTeleportAt =
                    now

                state.LastResult =
                    afterLoading == true
                    and "post-load middle repair"
                    or "holding middle during loading"

                if afterLoading == true then

                    lastPostLoadRepairAt =
                        now

                    postLoadRepairUsed =
                        true

                    postLoadRepairTries =
                        postLoadRepairTries + 1
                end

            else

                state.LastResult =
                    "middle teleport failed: "
                    .. tostring(err)
            end
        end

        local function loadingHoldStep(now, snapshot)

            if GAG2AutoSkipLoadingEnabled() ~= true then
                return
            end

            if loadingFinished == true then
                return
            end

            if snapshot.LoadingSignal ~= true then
                return
            end

            if state.HoldingSkip == true then

                local heldFor =
                    now - tonumber(state.HoldStartAt or now)

                if heldFor >= tonumber(state.HoldMaxSeconds or 3.75) then

                    GAG2MiddleFarmReleaseSkipHold(
                        "hold cycle complete"
                    )

                    lastHoldReleasedAt =
                        now
                end

                return
            end

            if state.SkipAttempts >= tonumber(state.MaxSkipAttempts or 2) then
                return
            end

            if now - lastHoldReleasedAt < tonumber(state.SkipRetryDelay or 0.25) then
                return
            end

            state.SkipStarted =
                true

            state.SkipAttempts =
                tonumber(state.SkipAttempts)
                or 0

            state.SkipAttempts =
                state.SkipAttempts + 1

            local ok, holdInfo =
                GAG2MiddleFarmPressSkipHold()

            if ok ~= true then

                lastHoldReleasedAt =
                    now

                state.LastResult =
                    "loading hold failed: "
                    .. tostring(holdInfo)
            end
        end

        while os.clock() - started < tonumber(state.MaxRunSeconds or 120) do

            if GAG2MiddleFarmWorkerShouldContinue(forceTp) ~= true then

                GAG2MiddleFarmReleaseSkipHold(
                    "disabled"
                )

                state.LastResult =
                    "stopped: disabled"

                state.Running =
                    false

                return
            end

            local now =
                os.clock()

            if LOCAL_PLAYER
            and LOCAL_PLAYER.Character ~= lastCharacter then

                lastCharacter =
                    LOCAL_PLAYER.Character

                earlyTeleportDone =
                    false

                resolveTarget(
                    true
                )
            end

            resolveTarget(
                false
            )

            local needsFarm =
                autoTpNeeded()

            local snapshot =
                GAG2MiddleFarmLoadingSnapshot(
                    needsFarm
                )

            if snapshot.LoadingSignal == true then

                state.SawLoadingSignal =
                    true
            end

            if loadingFinished ~= true then

                keepMiddle(
                    now,
                    false
                )

                loadingHoldStep(
                    now,
                    snapshot
                )

                if snapshot.Ready == true then

                    if finishCandidateAt <= 0 then

                        finishCandidateAt =
                            now

                        state.FinishCandidateAt =
                            now
                    end

                    local requiredStable =
                        state.SawLoadingSignal == true
                        and tonumber(state.LoadingStableSeconds or 0.75)
                        or tonumber(state.LateAttachStableSeconds or 2.50)

                    if now - finishCandidateAt >= requiredStable then

                        loadingFinished =
                            true

                        state.LoadingFinished =
                            true

                        state.LoadingFinishedAt =
                            now

                        state.SkipSucceeded =
                            true

                        state.LoadingFinishReason =
                            state.SawLoadingSignal == true
                            and "loading signals cleared and client stable"
                            or "client already stable"

                        state.SkipSuccessReason =
                            state.LoadingFinishReason

                        state.LastResult =
                            "loading finished"

                        GAG2MiddleFarmReleaseSkipHold(
                            "loading finished"
                        )

                        print(
                            "[HOLY LOADING]",
                            "Loading finished | "
                            .. string.format(
                                "%.2fs",
                                now - started
                            )
                        )

                        if needsFarm == true then

                            resolveTarget(
                                true
                            )

                            postLoadWatchUntil =
                                now
                                + tonumber(state.PostLoadWatchSeconds or 10)

                        else

                            state.Running =
                                false

                            return
                        end
                    end

                else

                    finishCandidateAt =
                        0

                    state.FinishCandidateAt =
                        0
                end

            else

                keepMiddle(
                    now,
                    true
                )

                if postLoadRepairTries >= tonumber(state.PostLoadMaxRepairTries or 12) then

                    state.LastResult =
                        "post-load repair max tries"

                    warn(
                        "[HOLY MIDDLE]",
                        "Final repair failed."
                    )

                    state.Running =
                        false

                    return
                end

                if now >= postLoadWatchUntil then

                    resolveTarget(
                        true
                    )

                    local _, root =
                        SniperGetCharacterRoot()

                    if root
                    and typeof(targetPosition) == "Vector3" then

                        local distance =
                            (root.Position - targetPosition).Magnitude

                        if distance > tonumber(state.PostLoadRepairDistance or 12) then

                            keepMiddle(
                                now,
                                true
                            )

                            postLoadWatchUntil =
                                now
                                + tonumber(state.PostLoadFinalSettleSeconds or 1.25)

                        else

                            state.LastResult =
                                "done"

                            if postLoadRepairUsed == true then

                                print(
                                    "[HOLY MIDDLE]",
                                    "Final position secured."
                                )
                            end

                            state.Running =
                                false

                            return
                        end

                    else

                        postLoadWatchUntil =
                            now
                            + tonumber(state.PostLoadFinalSettleSeconds or 1.25)
                    end
                end
            end

            task.wait(
                tonumber(state.WorkerInterval)
                or 0.20
            )
        end

        GAG2MiddleFarmReleaseSkipHold(
            "timeout"
        )

        if loadingFinished == true then

            warn(
                "[HOLY MIDDLE]",
                "Final repair timed out."
            )

            state.LastResult =
                "post-load repair timeout"

        else

            warn(
                "[HOLY LOADING]",
                "Loading detection timed out."
            )

            state.LastResult =
                "loading detection timeout"
        end

        state.Running =
            false
    end)

    return true
end

function GAG2StartAutoTpMiddleFarm(reason)

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if state.Moving == true then
        return false
    end

    if state.MovedOnce == true then

        state.MiddleReady =
            true

        state.LastResult =
            "already moved once"

        return false
    end

    state.Moving =
        true

    state.MiddleReady =
        false

    task.spawn(function()

        local ok =
            false

        local info =
            "not started"

        ok, info =
            GAG2TeleportToMiddleFarmOnce(
                reason or "auto middle"
            )

        if ok == true then

            state.MovedOnce =
                true

            state.MiddleReady =
                true

            state.LastMiddleReadyAt =
                os.clock()

            state.SniperWaitActive =
                false

        else

            state.MiddleReady =
                false
        end

        state.Moving =
            false
    end)

    return true
end

function GAG2StartAutoSkipLoading(reason)

    return GAG2StartMiddleFarmLoadingWorker(
        reason or "auto skip",
        false
    )
end

function GAG2SetAutoTpMiddleFarmEnabled(value)

    if ConfigState.Loading == true then
        return
    end

    local enabled =
        value == true

    if enabled == true then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovedOnce =
            false

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.Moving =
            false

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.MiddleReady =
            false

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastMiddleReadyAt =
            0

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastSniperMiddleStartAt =
            0

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.SniperWaitActive =
            false

        if type(GAG2StartAutoTpMiddleFarm) == "function" then

            GAG2StartAutoTpMiddleFarm(
                "toggle"
            )
        end
    end

    if enabled ~= true
    and type(GAG2AutoSkipLoadingEnabled) == "function"
    and GAG2AutoSkipLoadingEnabled() ~= true then

        if type(GAG2MiddleFarmReleaseSkipHold) == "function" then

            GAG2MiddleFarmReleaseSkipHold(
                "auto tp off"
            )
        end
    end

    MarkConfigDirty()

    task.defer(function()

        if ConfigState.Loading == true then
            return
        end

        if SaveManager
        and type(SaveManager.Save) == "function" then

            pcall(function()

                SaveManager:Save(
                    ConfigState.AutosaveName
                )
            end)
        end
    end)
end

function GAG2SetAutoSkipLoadingEnabled(value)

    if ConfigState.Loading == true then
        return
    end

    local enabled =
        value == true

    if enabled == true then

        if type(GAG2StartAutoSkipLoading) == "function" then

            GAG2StartAutoSkipLoading(
                "toggle"
            )
        end

    elseif type(GAG2AutoTpMiddleFarmEnabled) == "function"
    and GAG2AutoTpMiddleFarmEnabled() ~= true then

        if type(GAG2MiddleFarmReleaseSkipHold) == "function" then

            GAG2MiddleFarmReleaseSkipHold(
                "auto skip off"
            )
        end
    end

    MarkConfigDirty()
end

function GAG2RestoreAutoTpMiddleFarmState()

    if GAG2_AUTO_TP_MIDDLE_FARM_STATE.CharacterConnection == nil then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.CharacterConnection =
            LOCAL_PLAYER.CharacterAdded:Connect(function()

                task.wait(
                    0.15
                )

                GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovedOnce =
                    false

                GAG2_AUTO_TP_MIDDLE_FARM_STATE.Moving =
                    false

                if GAG2AutoSkipLoadingEnabled() == true then

                    GAG2StartMiddleFarmLoadingWorker(
                        "respawn",
                        false
                    )
                end

                if GAG2AutoTpMiddleFarmEnabled() == true then

                    GAG2StartAutoTpMiddleFarm(
                        "respawn"
                    )
                end
            end)
    end

    task.defer(function()

        if Options.HolyGAG2AutoMiddleFarmMode
        and Options.HolyGAG2AutoMiddleFarmMode.Value ~= nil then

            GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovementMode =
                CleanText(Options.HolyGAG2AutoMiddleFarmMode.Value) == "Walk"
                and "Walk"
                or "Teleport"
        end

        if GAG2AutoSkipLoadingEnabled() == true then

            GAG2StartMiddleFarmLoadingWorker(
                "autosave",
                false
            )
        end

        if GAG2AutoTpMiddleFarmEnabled() == true then

            GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovedOnce =
                false

            GAG2_AUTO_TP_MIDDLE_FARM_STATE.Moving =
                false

            GAG2StartAutoTpMiddleFarm(
                "autosave"
            )
        end
    end)
end

--==================================================
-- [4.555] PERFORMANCE / HIDE OTHER GARDENS
-- Client-side render reduction. Never hides own garden.
--==================================================

if type(GAG2_PERFORMANCE_STATE) == "table" then

    if type(GAG2_PERFORMANCE_STATE.Connections) == "table" then

        for key, connection in pairs(GAG2_PERFORMANCE_STATE.Connections) do

            if connection then

                pcall(function()

                    connection:Disconnect()
                end)
            end

            GAG2_PERFORMANCE_STATE.Connections[key] =
                nil
        end
    end

    if GAG2_PERFORMANCE_STATE.OwnGardenVisualConnection then

        pcall(function()

            GAG2_PERFORMANCE_STATE.OwnGardenVisualConnection:Disconnect()
        end)

        GAG2_PERFORMANCE_STATE.OwnGardenVisualConnection =
            nil
    end
end

GAG2_PERFORMANCE_STATE =
    GAG2_PERFORMANCE_STATE
    or {
        HideOtherGardens = false,
        HideOwnGarden = false,
        HideMapClutter = false,

        MapClutterApplying = false,
        MapClutterApplied = false,
        LastMapClutterApplyAt = 0,

        HiddenGardens = {},
        HiddenOwnGardenVisuals = {},
        HiddenMapClutter = {},
        OwnGardenVisualConnection = nil,
        Connections = {},
        LastStatus = "Idle.",
    }

function GAG2PerformanceSetStatus(text)

    local state =
        GAG2_PERFORMANCE_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    print(
        "[HOLY PERFORMANCE]",
        state.LastStatus
    )
end

function GAG2PerformanceGetGardensRoot()

    return workspace:FindFirstChild(
        "Gardens"
    )
end

function GAG2PerformanceGetMapClutterTargets()

    local targets =
        {}

    local map =
        workspace:FindFirstChild(
            "Map"
        )

    if map then

        local middle =
            map:FindFirstChild(
                "Middle"
            )

        if middle then

            table.insert(
                targets,
                middle
            )
        end

        local stands =
            map:FindFirstChild(
                "Stands"
            )

        if stands then

            table.insert(
                targets,
                stands
            )
        end
    end

    local npcs =
        workspace:FindFirstChild(
            "NPCS"
        )

    if npcs then

        table.insert(
            targets,
            npcs
        )
    end

    return targets
end

function GAG2PerformanceHideMapClutterTarget(target)

    local state =
        GAG2_PERFORMANCE_STATE

    if typeof(target) ~= "Instance" then
        return false
    end

    if state.HiddenMapClutter[target] ~= nil then
        return false
    end

    local parent =
        target.Parent

    if typeof(parent) ~= "Instance" then
        return false
    end

    state.HiddenMapClutter[target] =
        parent

    local ok =
        pcall(function()

            target.Parent =
                nil
        end)

    if ok ~= true then

        state.HiddenMapClutter[target] =
            nil

        return false
    end

    return true
end

function GAG2PerformanceRestoreMapClutter(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HiddenMapClutter =
        type(state.HiddenMapClutter) == "table"
        and state.HiddenMapClutter
        or {}

    local restored =
        0

    for target, originalParent in pairs(state.HiddenMapClutter) do

        if typeof(target) == "Instance"
        and target.Parent == nil
        and typeof(originalParent) == "Instance" then

            local ok =
                pcall(function()

                    target.Parent =
                        originalParent
                end)

            if ok == true then

                restored =
                    restored + 1
            end
        end

        state.HiddenMapClutter[target] =
            nil
    end

    return restored
end

function GAG2PerformanceApplyHideMapClutter(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HiddenMapClutter =
        type(state.HiddenMapClutter) == "table"
        and state.HiddenMapClutter
        or {}

    if state.HideMapClutter ~= true then

        local restored =
            GAG2PerformanceRestoreMapClutter(
                reason or "map clutter off"
            )

        state.MapClutterApplying =
            false

        state.MapClutterApplied =
            false

        GAG2PerformanceSetStatus(
            "Map clutter restored: "
            .. tostring(restored)
        )

        return true
    end

    local map =
        workspace:FindFirstChild(
            "Map"
        )

    if map
    and state.Connections.MapChildAdded == nil then

        state.Connections.MapChildAdded =
            map.ChildAdded:Connect(function(child)

                if GAG2_PERFORMANCE_STATE.HideMapClutter ~= true then
                    return
                end

                if child.Name ~= "Middle"
                and child.Name ~= "Stands" then
                    return
                end

                task.wait(
                    0.35
                )

                GAG2PerformanceApplyHideMapClutter(
                    "map child added"
                )
            end)
    end

    if state.Connections.WorkspaceNpcAdded == nil then

        state.Connections.WorkspaceNpcAdded =
            workspace.ChildAdded:Connect(function(child)

                if GAG2_PERFORMANCE_STATE.HideMapClutter ~= true then
                    return
                end

                if child.Name ~= "NPCS" then
                    return
                end

                task.wait(
                    0.35
                )

                GAG2PerformanceApplyHideMapClutter(
                    "npcs added"
                )
            end)
    end

    local targets =
        GAG2PerformanceGetMapClutterTargets()

    if #targets <= 0 then

        state.MapClutterApplied =
            true

        return true
    end

    if state.MapClutterApplying == true then
        return true
    end

    state.MapClutterApplying =
        true

    state.LastMapClutterApplyAt =
        os.clock()

    task.spawn(function()

        local hidden =
            0

        for _, target in ipairs(targets) do

            if GAG2_PERFORMANCE_STATE.HideMapClutter ~= true then
                break
            end

            if GAG2PerformanceHideMapClutterTarget(
                target
            ) == true then

                hidden =
                    hidden + 1
            end

            task.wait(
                0.15
            )
        end

        state.MapClutterApplying =
            false

        state.MapClutterApplied =
            true

        GAG2PerformanceSetStatus(
            "Map clutter hidden: "
            .. tostring(hidden)
            .. (
                reason
                and " | " .. tostring(reason)
                or ""
            )
        )
    end)

    return true
end

function GAG2PerformanceSetHideMapClutterEnabled(value)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HideMapClutter =
        value == true

    if state.HideMapClutter == true then

        GAG2PerformanceApplyHideMapClutter(
            "toggle"
        )

    else

        state.MapClutterApplying =
            false

        state.MapClutterApplied =
            false

        GAG2PerformanceRestoreMapClutter(
            "toggle off"
        )

        for _, key in ipairs({
            "MapChildAdded",
            "WorkspaceNpcAdded",
        }) do

            local connection =
                state.Connections
                and state.Connections[key]

            if connection then

                pcall(function()

                    connection:Disconnect()
                end)

                state.Connections[key] =
                    nil
            end
        end

        GAG2PerformanceSetStatus(
            "Map clutter restored."
        )
    end

    MarkConfigDirty()
end

function GAG2PerformanceIsGardenPlot(instance)

    if typeof(instance) ~= "Instance" then
        return false
    end

    if instance:IsA("Model") ~= true
    and instance:IsA("Folder") ~= true then
        return false
    end

    if tostring(instance.Name):match("^Plot%d+$") then
        return true
    end

    return false
end

function GAG2PerformanceResolveOwnGarden()

    if type(GAG2ResolveOwnFarmPlot) == "function" then

        local ok, plot, reason =
            pcall(
                GAG2ResolveOwnFarmPlot
            )

        if ok == true
        and typeof(plot) == "Instance" then

            return plot,
                tostring(reason or "resolved")
        end

        return nil,
            tostring(plot or reason or "own garden unresolved")
    end

    return nil,
        "GAG2ResolveOwnFarmPlot missing"
end

function GAG2PerformanceRestoreHiddenGardens(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    local restored =
        0

    for garden, originalParent in pairs(state.HiddenGardens) do

        if typeof(garden) == "Instance"
        and garden.Parent == nil
        and typeof(originalParent) == "Instance" then

            local ok =
                pcall(function()

                    garden.Parent =
                        originalParent
                end)

            if ok == true then
                restored = restored + 1
            end
        end

        state.HiddenGardens[garden] =
            nil
    end

    local visualRestored =
        GAG2PerformanceRestoreOwnGardenVisuals(
            reason
        )

    local clutterRestored =
        GAG2PerformanceRestoreMapClutter(
            reason
        )

    GAG2PerformanceSetStatus(
        "Restored "
        .. tostring(restored)
        .. " hidden garden(s)."
        .. " Visuals: "
        .. tostring(visualRestored)
        .. " Clutter: "
        .. tostring(clutterRestored)
        .. (
            reason
            and " Reason: " .. tostring(reason)
            or ""
        )
    )

    return restored
end
function GAG2PerformanceRememberVisual(object, propertyName)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HiddenOwnGardenVisuals =
        type(state.HiddenOwnGardenVisuals) == "table"
        and state.HiddenOwnGardenVisuals
        or {}

    if typeof(object) ~= "Instance" then
        return
    end

    local bucket =
        state.HiddenOwnGardenVisuals[object]

    if type(bucket) ~= "table" then

        bucket =
            {}

        state.HiddenOwnGardenVisuals[object] =
            bucket
    end

    if bucket[propertyName] ~= nil then
        return
    end

    local ok, value =
        pcall(function()

            return object[propertyName]
        end)

    if ok == true then

        bucket[propertyName] =
            value
    end
end

function GAG2PerformanceHideOwnGardenObject(object)

    if typeof(object) ~= "Instance" then
        return false
    end

    if object:IsA("BasePart") then

        GAG2PerformanceRememberVisual(
            object,
            "LocalTransparencyModifier"
        )

        GAG2PerformanceRememberVisual(
            object,
            "CanCollide"
        )

        GAG2PerformanceRememberVisual(
            object,
            "CastShadow"
        )

        pcall(function()

            object.LocalTransparencyModifier =
                1

            object.CanCollide =
                false

            object.CastShadow =
                false
        end)

        return true
    end

    if object:IsA("Decal")
    or object:IsA("Texture") then

        GAG2PerformanceRememberVisual(
            object,
            "Transparency"
        )

        pcall(function()

            object.Transparency =
                1
        end)

        return true
    end

    if object:IsA("ParticleEmitter")
    or object:IsA("Trail")
    or object:IsA("Beam")
    or object:IsA("BillboardGui")
    or object:IsA("SurfaceGui") then

        GAG2PerformanceRememberVisual(
            object,
            "Enabled"
        )

        pcall(function()

            object.Enabled =
                false
        end)

        return true
    end

    return false
end

function GAG2PerformanceHideOwnGardenVisuals(garden)

    local state =
        GAG2_PERFORMANCE_STATE

    if typeof(garden) ~= "Instance" then
        return 0
    end

    local hidden =
        0

    if GAG2PerformanceHideOwnGardenObject(
        garden
    ) == true then

        hidden =
            hidden + 1
    end

    for _, descendant in ipairs(garden:GetDescendants()) do

        if GAG2PerformanceHideOwnGardenObject(
            descendant
        ) == true then

            hidden =
                hidden + 1
        end
    end

    if state.OwnGardenVisualConnection == nil then

        state.OwnGardenVisualConnection =
            garden.DescendantAdded:Connect(function(descendant)

                if GAG2_PERFORMANCE_STATE.HideOwnGarden ~= true then
                    return
                end

                task.defer(function()

                    GAG2PerformanceHideOwnGardenObject(
                        descendant
                    )
                end)
            end)
    end

    return hidden
end

function GAG2PerformanceRestoreOwnGardenVisuals(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    local restored =
        0

    if type(state.HiddenOwnGardenVisuals) == "table" then

        for object, properties in pairs(state.HiddenOwnGardenVisuals) do

            if typeof(object) == "Instance"
            and type(properties) == "table" then

                for propertyName, value in pairs(properties) do

                    local ok =
                        pcall(function()

                            object[propertyName] =
                                value
                        end)

                    if ok == true then

                        restored =
                            restored + 1
                    end
                end
            end

            state.HiddenOwnGardenVisuals[object] =
                nil
        end
    end

    if state.OwnGardenVisualConnection then

        pcall(function()

            state.OwnGardenVisualConnection:Disconnect()
        end)

        state.OwnGardenVisualConnection =
            nil
    end

    return restored
end


function GAG2PerformanceHideGarden(garden, ownGarden, gardensRoot)

    local state =
        GAG2_PERFORMANCE_STATE

    if typeof(garden) ~= "Instance" then
        return false
    end

    if typeof(gardensRoot) ~= "Instance" then
        return false
    end

    if GAG2PerformanceIsGardenPlot(garden) ~= true then
        return false
    end

    local isOwnGarden =
        false

    if typeof(ownGarden) == "Instance" then

        if garden == ownGarden then

            isOwnGarden =
                true

        elseif tostring(garden.Name) == tostring(ownGarden.Name) then

            isOwnGarden =
                true
        end
    end

    if isOwnGarden == true then

        if state.HideOwnGarden ~= true then
            return false
        end

        GAG2PerformanceHideOwnGardenVisuals(
            garden
        )

        return true
    end

    if state.HideOtherGardens ~= true then
        return false
    end

    if state.HiddenGardens[garden] ~= nil then
        return false
    end

    state.HiddenGardens[garden] =
        garden.Parent

    local ok =
        pcall(function()

            garden.Parent =
                nil
        end)

    if ok ~= true then

        state.HiddenGardens[garden] =
            nil

        return false
    end

    return true
end

function GAG2PerformanceApplyHideOtherGardens(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    if state.HideOtherGardens ~= true
    and state.HideOwnGarden ~= true then

        GAG2PerformanceRestoreHiddenGardens(
            reason or "all garden hiding off"
        )

        return true
    end

    local gardensRoot =
        GAG2PerformanceGetGardensRoot()

    if not gardensRoot then

        GAG2PerformanceSetStatus(
            "Workspace.Gardens missing."
        )

        return false
    end

    local ownGarden, ownReason =
        GAG2PerformanceResolveOwnGarden()

    if not ownGarden then

        GAG2PerformanceSetStatus(
            "Cannot hide gardens yet: "
            .. tostring(ownReason)
        )

        return false
    end

    local hidden =
        0

    for _, garden in ipairs(gardensRoot:GetChildren()) do

        if GAG2PerformanceHideGarden(
            garden,
            ownGarden,
            gardensRoot
        ) == true then

            hidden = hidden + 1
        end
    end

    if state.Connections.GardensChildAdded == nil then

        state.Connections.GardensChildAdded =
            gardensRoot.ChildAdded:Connect(function(child)

                if GAG2_PERFORMANCE_STATE.HideOtherGardens ~= true
                and GAG2_PERFORMANCE_STATE.HideOwnGarden ~= true then

                    return
                end

                task.wait(
                    0.25
                )

                GAG2PerformanceApplyHideOtherGardens(
                    "garden added"
                )
            end)
    end

    GAG2PerformanceSetStatus(
        "Garden hiding applied. Hidden now: "
        .. tostring(hidden)
        .. " | Other: "
        .. tostring(state.HideOtherGardens == true)
        .. " | Own: "
        .. tostring(state.HideOwnGarden == true)
        .. " | OwnPlot: "
        .. tostring(ownGarden.Name)
        .. (
            reason
            and " | " .. tostring(reason)
            or ""
        )
    )

    return true
end

function GAG2PerformanceSetHideOtherGardensEnabled(value)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HideOtherGardens =
        value == true

    GAG2PerformanceRestoreHiddenGardens(
        "refresh other gardens toggle"
    )

    if state.HideOtherGardens == true
    or state.HideOwnGarden == true then

        GAG2PerformanceApplyHideOtherGardens(
            "toggle"
        )
    end

    MarkConfigDirty()
end

function GAG2PerformanceSetHideOwnGardenEnabled(value)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HideOwnGarden =
        value == true

    GAG2PerformanceRestoreHiddenGardens(
        "refresh own garden toggle"
    )

    if state.HideOtherGardens == true
    or state.HideOwnGarden == true then

        GAG2PerformanceApplyHideOtherGardens(
            "toggle"
        )
    end

    MarkConfigDirty()
end

function GAG2RestorePerformanceState()

    task.defer(function()

        if Toggles.HolyGAG2HideOtherGardens then

            GAG2_PERFORMANCE_STATE.HideOtherGardens =
                Toggles.HolyGAG2HideOtherGardens.Value == true
        end

        if Toggles.HolyGAG2HideOwnGarden then

            GAG2_PERFORMANCE_STATE.HideOwnGarden =
                Toggles.HolyGAG2HideOwnGarden.Value == true
        end

        if Toggles.HolyGAG2HideMapClutter then

            GAG2_PERFORMANCE_STATE.HideMapClutter =
                Toggles.HolyGAG2HideMapClutter.Value == true
        end

        if GAG2_PERFORMANCE_STATE.HideOtherGardens == true
        or GAG2_PERFORMANCE_STATE.HideOwnGarden == true then

            task.wait(
                0.75
            )

            GAG2PerformanceApplyHideOtherGardens(
                "autosave"
            )
        end

        if GAG2_PERFORMANCE_STATE.HideMapClutter == true then

            task.wait(
                0.25
            )

            GAG2PerformanceApplyHideMapClutter(
                "autosave"
            )
        end
    end)
end

--==================================================
-- [4.559] ANTI AFK
-- Prevents GAG2 custom inactivity server-hop.
-- Silent Idled responder + proactive low-rate activity pulse.
-- No remotes. No console output.
--==================================================

if type(GAG2_ANTI_AFK_STATE) == "table" then

    GAG2_ANTI_AFK_STATE.Enabled =
        false

    GAG2_ANTI_AFK_STATE.LoopToken =
        tonumber(GAG2_ANTI_AFK_STATE.LoopToken)
        or 0

    GAG2_ANTI_AFK_STATE.LoopToken = GAG2_ANTI_AFK_STATE.LoopToken + 1

    if GAG2_ANTI_AFK_STATE.Connection then

        pcall(function()

            GAG2_ANTI_AFK_STATE.Connection:Disconnect()
        end)
    end
end

GAG2_ANTI_AFK_STATE = {
    Enabled = true,
    Connection = nil,

    LoopRunning = false,
    LoopToken = 0,

    PulseInterval = 35,
    MicroMoveInterval = 70,

    LastActionAt = 0,
    LastMicroMoveAt = 0,
    LastIdleSeconds = 0,

    PulseCount = 0,
    MicroMoveFlip = false,

    LastMethod = "none",
    LastError = "",
}

function GAG2AntiAfkDisconnect()

    local state =
        GAG2_ANTI_AFK_STATE

    if state.Connection then

        pcall(function()

            state.Connection:Disconnect()
        end)
    end

    state.Connection =
        nil

    state.LoopToken =
        tonumber(state.LoopToken)
        or 0

    state.LoopToken = state.LoopToken + 1

    state.LoopRunning =
        false
end

function GAG2AntiAfkTryVirtualUser()

    if VirtualUser == nil then
        return false,
            "VirtualUser missing"
    end

    local ok, err =
        pcall(function()

            VirtualUser:CaptureController()

            VirtualUser:ClickButton2(
                Vector2.new(
                    0,
                    0
                )
            )
        end)

    if ok == true then
        return true,
            "VirtualUser"
    end

    return false,
        tostring(err)
end

function GAG2AntiAfkTryVirtualInput()

    if VirtualInputManager == nil then
        return false,
            "VirtualInputManager missing"
    end

    local anyOk =
        false

    local firstError =
        ""

    local keyCode =
        Enum.KeyCode.RightControl

    local keyOk, keyErr =
        pcall(function()

            VirtualInputManager:SendKeyEvent(
                true,
                keyCode,
                false,
                game
            )
        end)

    if keyOk == true then

        anyOk =
            true

        task.delay(0.04, function()

            pcall(function()

                VirtualInputManager:SendKeyEvent(
                    false,
                    keyCode,
                    false,
                    game
                )
            end)
        end)

    else

        firstError =
            tostring(keyErr)
    end

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(
            1280,
            720
        )

    local mouseOk, mouseErr =
        pcall(function()

            VirtualInputManager:SendMouseMoveEvent(
                math.floor(viewport.X / 2) + 1,
                math.floor(viewport.Y / 2),
                game
            )
        end)

    if mouseOk == true then

        anyOk =
            true

    elseif firstError == "" then

        firstError =
            tostring(mouseErr)
    end

    if anyOk == true then
        return true,
            "VirtualInputManager"
    end

    return false,
        firstError ~= ""
        and firstError
        or "VirtualInputManager failed"
end

function GAG2AntiAfkTryMicroMove()

    local state =
        GAG2_ANTI_AFK_STATE

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid
    or humanoid.Health <= 0 then
        return false,
            "humanoid missing"
    end

    if humanoid.Sit == true then
        return false,
            "humanoid seated"
    end

    state.MicroMoveFlip =
        state.MicroMoveFlip ~= true

    local direction =
        state.MicroMoveFlip == true
        and 1
        or -1

    local ok, err =
        pcall(function()

            humanoid:Move(
                Vector3.new(
                    0.02 * direction,
                    0,
                    0
                ),
                false
            )
        end)

    if ok ~= true then
        return false,
            tostring(err)
    end

    task.delay(0.06, function()

        pcall(function()

            local currentCharacter =
                LOCAL_PLAYER
                and LOCAL_PLAYER.Character

            local currentHumanoid =
                currentCharacter
                and currentCharacter:FindFirstChildOfClass("Humanoid")

            if currentHumanoid then

                currentHumanoid:Move(
                    Vector3.zero,
                    false
                )
            end
        end)
    end)

    state.LastMicroMoveAt =
        os.clock()

    return true,
        "MicroMove"
end

function GAG2AntiAfkPulse(idleSeconds, reason)

    local state =
        GAG2_ANTI_AFK_STATE

    if state.Enabled ~= true then
        return false
    end

    local now =
        os.clock()

    if now - tonumber(state.LastActionAt or 0) < 8 then
        return false
    end

    state.LastActionAt =
        now

    state.LastIdleSeconds =
        tonumber(idleSeconds)
        or 0

    local methods =
        {}

    local errors =
        {}

    local vuOk, vuInfo =
        GAG2AntiAfkTryVirtualUser()

    if vuOk == true then

        table.insert(
            methods,
            vuInfo
        )

    else

        table.insert(
            errors,
            vuInfo
        )
    end

    local viOk, viInfo =
        GAG2AntiAfkTryVirtualInput()

    if viOk == true then

        table.insert(
            methods,
            viInfo
        )

    else

        table.insert(
            errors,
            viInfo
        )
    end

    local microInterval =
        math.clamp(
            tonumber(state.MicroMoveInterval)
            or 70,
            45,
            240
        )

    if now - tonumber(state.LastMicroMoveAt or 0) >= microInterval then

        local moveOk, moveInfo =
            GAG2AntiAfkTryMicroMove()

        if moveOk == true then

            table.insert(
                methods,
                moveInfo
            )

        else

            table.insert(
                errors,
                moveInfo
            )
        end
    end

    if #methods > 0 then

        state.PulseCount =
            tonumber(state.PulseCount)
            or 0

        state.PulseCount = state.PulseCount + 1

        state.LastMethod =
            table.concat(
                methods,
                " + "
            )

        state.LastError =
            ""

        return true
    end

    state.LastMethod =
        "none"

    state.LastError =
        table.concat(
            errors,
            " | "
        )

    return false
end

function GAG2AntiAfkConnect()

    local state =
        GAG2_ANTI_AFK_STATE

    if state.Connection then
        return
    end

    if not LOCAL_PLAYER
    or not LOCAL_PLAYER.Idled then

        state.LastError =
            "LocalPlayer.Idled missing"

        return
    end

    local ok, connection =
        pcall(function()

            return LOCAL_PLAYER.Idled:Connect(function(idleSeconds)

                GAG2AntiAfkPulse(
                    idleSeconds,
                    "idled"
                )
            end)
        end)

    if ok == true
    and connection then

        state.Connection =
            connection

        state.LastError =
            ""

    else

        state.LastError =
            tostring(connection)
    end
end

function GAG2AntiAfkStartLoop()

    local state =
        GAG2_ANTI_AFK_STATE

    if state.LoopRunning == true then
        return
    end

    state.LoopToken =
        tonumber(state.LoopToken)
        or 0

    state.LoopToken = state.LoopToken + 1

    local token =
        state.LoopToken

    state.LoopRunning =
        true

    task.spawn(function()

        task.wait(
            6
        )

        while GAG2_ANTI_AFK_STATE.Enabled == true
        and GAG2_ANTI_AFK_STATE.LoopToken == token do

            local interval =
                math.clamp(
                    tonumber(GAG2_ANTI_AFK_STATE.PulseInterval)
                    or 35,
                    20,
                    120
                )

            if os.clock() - tonumber(GAG2_ANTI_AFK_STATE.LastActionAt or 0) >= interval then

                GAG2AntiAfkPulse(
                    0,
                    "proactive"
                )
            end

            task.wait(
                5
            )
        end

        if GAG2_ANTI_AFK_STATE.LoopToken == token then

            GAG2_ANTI_AFK_STATE.LoopRunning =
                false
        end
    end)
end

function GAG2AntiAfkSetEnabled(value, skipDirty)

    local state =
        GAG2_ANTI_AFK_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        GAG2AntiAfkConnect()
        GAG2AntiAfkStartLoop()

    else

        GAG2AntiAfkDisconnect()
    end

    if skipDirty ~= true then

        MarkConfigDirty()
    end
end

function GAG2RestoreAntiAfkState()

    task.defer(function()

        local enabled =
            true

        if Toggles.HolyGAG2AntiAfk then

            enabled =
                Toggles.HolyGAG2AntiAfk.Value ~= false
        end

        GAG2AntiAfkSetEnabled(
            enabled,
            true
        )
    end)
end

--==================================================
-- [4.56] AUTO COLLECT FRUITS
-- Priority harvest queue using ready HarvestPrompt fruits.
-- Weight uses the game fruit weight formula, not raw SizeMulti ranking.
--==================================================

GAG2_AUTO_COLLECT_FRUIT_STATE =
    GAG2_AUTO_COLLECT_FRUIT_STATE
    or {
        Enabled = false,
        Running = false,

        StopIfFull = true,
        Delay = 0,
        BurstAmount = 8,
        CollectionSpeed = "Normal",

        PauseDuringWeather = false,
        PauseWeatherMode = "Any Weather",
        PauseWeathers = {
            Rain = true,
            Lightning = true,
            Rainbow = true,
            Snowfall = true,
            Starfall = true,
        },
        ActiveWeather = "Day",
        ActivePhase = "Day",
        WeatherWatcherStarted = false,
        WeatherConnections = {},

        CollectMode = "All",

        SelectedFruits = {},
        SelectedRarities = {},
        SelectedMutations = {},

        ExcludeFruits = {},
        ExcludeRarities = {},
        ExcludeMutations = {},

        ExcludeSizeMode = "Off",
        ExcludeSizeThreshold = 0,

        Priority1 = "Rarity",
        Priority2 = "Weight",
        Priority3 = "Mutation",

        Recent = {},
        Modules = {},
        SeedMap = {},
        FruitNames = {},
        RarityNames = {},
        MutationNames = {},

        LastStatus = "Idle.",
        LastReadyCount = 0,
        LastMatchingCount = 0,
        LastExcludedCount = 0,
        LastFiredCount = 0,
        LastNextText = "None",
        LastRefreshAt = 0,
    }

GAG2_AUTO_COLLECT_FRUIT_CONTROLS =
    GAG2_AUTO_COLLECT_FRUIT_CONTROLS
    or {}

GAG2_ACF_PRIORITY_VALUES = {
    "None",
    "Rarity",
    "Weight",
    "Mutation",
    "Sell Worth",
    "Fruit",
}

GAG2_ACF_COLLECT_MODES = {
    "All",
    "Only Selected",
}

GAG2_ACF_SPEED_VALUES = {
    "Normal",
    "Fast",
    "Ultra",
}

GAG2_ACF_SPEED_PRESETS = {
    Normal = {
        Name = "Normal",
        MinBurst = 1,
        MaxBurst = 40,
        RecentCooldown = 1.25,
        PromptDelayOverride = nil,
        YieldEvery = 6,
        LoopWaitAfterFire = 0.03,
        LoopWaitIdle = 0.35,
    },

    Fast = {
        Name = "Fast",
        MinBurst = 24,
        MaxBurst = 90,
        RecentCooldown = 0.25,
        PromptDelayOverride = 0,
        YieldEvery = 24,
        LoopWaitAfterFire = 0.005,
        LoopWaitIdle = 0.12,
    },

    Ultra = {
        Name = "Ultra",
        MinBurst = 60,
        MaxBurst = 160,
        RecentCooldown = 0.04,
        PromptDelayOverride = 0,
        YieldEvery = 60,
        LoopWaitAfterFire = 0,
        LoopWaitIdle = 0.025,
    },
}

GAG2_ACF_SIZE_MODES = {
    "Off",
    "Above",
    "Below",
}

GAG2_ACF_WEATHER_MODE_VALUES = {
    "Any Weather",
    "Selected",
}

GAG2_ACF_WEATHER_VALUES = {
    "Rain",
    "Lightning",
    "Rainbow",
    "Snowfall",
    "Starfall",
}

GAG2_ACF_REAL_WEATHER_SET = {
    Rain = true,
    Lightning = true,
    Rainbow = true,
    Snowfall = true,
    Starfall = true,
}

GAG2_ACF_NORMAL_WEATHER_SET = {
    Day = true,
    Night = true,
    Dawn = true,
    Dusk = true,
    Morning = true,
    Evening = true,
}

GAG2_ACF_DEFAULT_RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Mythical",
    "Super",
    "Divine",
    "Prismatic",
}

GAG2_ACF_DEFAULT_MUTATIONS = {
    "None",
    "Gold",
    "Rainbow",
    "Bloodlit",
    "Starstruck",
    "Electric",
    "Frozen",
    "Chained",
    "Solarflare",
    "Pizza",
}

GAG2_ACF_RARITY_SCORE = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Mythical = 6,
    Super = 7,
    Divine = 8,
    Prismatic = 9,
}

function GAG2ACFSetStatus(text)

    local statusText =
        tostring(text or "Idle.")

    GAG2_AUTO_COLLECT_FRUIT_STATE.LastStatus =
        statusText

    if Options.HolyGAG2FarmStatus then

        Options.HolyGAG2FarmStatus:SetText(
            statusText
        )
    end
end

function GAG2ACFFormatNumber(value)

    local number =
        tonumber(value)

    if not number then
        return "?"
    end

    local text =
        tostring(
            math.floor(number + 0.5)
        )

    text =
        text:reverse()
            :gsub("(%d%d%d)", "%1,")
            :reverse()
            :gsub("^,", "")

    return text
end

function GAG2ACFFormatSize(value)

    local number =
        tonumber(value)
        or 0

    return string.format(
        "%.2fx",
        number
    )
end

function GAG2ACFClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2ACFTableCount(map)

    if type(map) ~= "table" then
        return 0
    end

    local count =
        0

    for _, enabled in pairs(map) do

        if enabled == true then
            count = count + 1
        end
    end

    return count
end

function GAG2ACFNormalizeSelection(value)

    local result =
        {}

    local function add(item)

        item =
            GAG2ACFClean(item)

        if item == ""
        or item == "Select Options" then
            return
        end

        result[item] =
            true
    end

    if type(value) == "table" then

        for _, item in ipairs(value) do
            add(item)
        end

        for item, enabled in pairs(value) do

            if enabled == true then
                add(item)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    return result
end

function GAG2ACFSelectionHas(map, value)

    value =
        GAG2ACFClean(value)

    if value == "" then
        value =
            "None"
    end

    return type(map) == "table"
        and map[value] == true
end

function GAG2ACFGetActiveWeather()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local weather =
        GAG2ACFClean(
            workspace:GetAttribute("ActiveWeather")
        )

    local phase =
        GAG2ACFClean(
            workspace:GetAttribute("ActivePhase")
        )

    if weather == "" then
        weather =
            "Day"
    end

    if phase == "" then
        phase =
            weather
    end

    state.ActiveWeather =
        weather

    state.ActivePhase =
        phase

    return weather,
        phase
end

function GAG2ACFIsRealWeatherName(weather)

    weather =
        GAG2ACFClean(weather)

    return GAG2_ACF_REAL_WEATHER_SET[weather] == true
end

function GAG2ACFShouldPauseForWeather()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local weather =
        GAG2ACFGetActiveWeather()

    if state.PauseDuringWeather ~= true then
        return false,
            weather
    end

    if GAG2ACFIsRealWeatherName(weather) ~= true then
        return false,
            weather
    end

    if state.PauseWeatherMode == "Selected" then

        return type(state.PauseWeathers) == "table"
            and state.PauseWeathers[weather] == true,
            weather
    end

    return true,
        weather
end

function GAG2ACFWeatherStatusText()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local weather, phase =
        GAG2ACFGetActiveWeather()

    local paused =
        GAG2ACFShouldPauseForWeather()

    local text =
        tostring(weather)

    if phase ~= ""
    and phase ~= weather then

        text =
            text
            .. " / "
            .. tostring(phase)
    end

    if state.PauseDuringWeather == true then

        text =
            text
            .. (
                paused == true
                and " | PAUSED"
                or " | watching"
            )

    else

        text =
            text
            .. " | ignore"
    end

    return text
end

function GAG2ACFStartWeatherWatcher()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.WeatherWatcherStarted == true then
        return
    end

    state.WeatherWatcherStarted =
        true

    state.WeatherConnections =
        type(state.WeatherConnections) == "table"
        and state.WeatherConnections
        or {}

    GAG2ACFGetActiveWeather()

    local function connectAttribute(attributeName)

        local ok, connection =
            pcall(function()

                return workspace:GetAttributeChangedSignal(attributeName):Connect(function()

                    local weather =
                        GAG2ACFGetActiveWeather()

                    local paused =
                        GAG2ACFShouldPauseForWeather()

                    if GAG2_AUTO_COLLECT_FRUIT_STATE.Enabled == true then

                        if paused == true then

                            GAG2ACFSetStatus(
                                GAG2ACFBuildStatusText(
                                    {},
                                    GAG2_AUTO_COLLECT_FRUIT_STATE.LastReadyCount or 0,
                                    GAG2_AUTO_COLLECT_FRUIT_STATE.LastExcludedCount or 0,
                                    "Paused for weather: "
                                    .. tostring(weather)
                                )
                            )

                        else

                            GAG2ACFSetStatus(
                                "Weather changed: "
                                .. tostring(weather)
                                .. ". Auto Collect can run."
                            )
                        end
                    end
                end)
            end)

        if ok == true
        and connection then

            table.insert(
                state.WeatherConnections,
                connection
            )
        end
    end

    connectAttribute(
        "ActiveWeather"
    )

    connectAttribute(
        "ActivePhase"
    )
end

function GAG2ACFSafeRequire(moduleName)

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local module =
        sharedModules
        and sharedModules:FindFirstChild(
            moduleName,
            true
        )

    if not module
    or module:IsA("ModuleScript") ~= true then
        return nil
    end

    local ok, result =
        pcall(function()

            return require(
                module
            )
        end)

    if ok == true then
        return result
    end

    return nil
end

function GAG2ACFRememberChoice(bucketName, value)

    value =
        GAG2ACFClean(value)

    if value == "" then
        return
    end

    local bucket =
        GAG2_AUTO_COLLECT_FRUIT_STATE[bucketName]

    if type(bucket) ~= "table" then

        bucket = {}

        GAG2_AUTO_COLLECT_FRUIT_STATE[bucketName] =
            bucket
    end

    if table.find(bucket, value) ~= nil then
        return
    end

    table.insert(
        bucket,
        value
    )

    table.sort(
        bucket
    )
end

function GAG2ACFEnsureModules()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local now =
        os.clock()

    if tonumber(state.LastModuleRefreshAt)
    and now - state.LastModuleRefreshAt < 5 then
        return state.Modules
    end

    state.LastModuleRefreshAt =
        now

    state.Modules =
        state.Modules
        or {}

    state.Modules.SeedData =
        state.Modules.SeedData
        or GAG2ACFSafeRequire("SeedData")

    state.Modules.SellValueData =
        state.Modules.SellValueData
        or GAG2ACFSafeRequire("SellValueData")

    state.Modules.MutationData =
        state.Modules.MutationData
        or GAG2ACFSafeRequire("MutationData")

    state.Modules.FruitValueCalc =
        state.Modules.FruitValueCalc
        or GAG2ACFSafeRequire("FruitValueCalc")

    state.SeedMap =
        {}

    if type(state.Modules.SeedData) == "table" then

        for _, row in pairs(state.Modules.SeedData) do

            if type(row) == "table"
            and type(row.SeedName) == "string" then

                state.SeedMap[row.SeedName] =
                    row

                GAG2ACFRememberChoice(
                    "FruitNames",
                    row.SeedName
                )

                if row.Rarity then

                    GAG2ACFRememberChoice(
                        "RarityNames",
                        tostring(row.Rarity)
                    )
                end
            end
        end
    end

    for _, rarity in ipairs(GAG2_ACF_DEFAULT_RARITIES) do

        GAG2ACFRememberChoice(
            "RarityNames",
            rarity
        )
    end

    for _, mutation in ipairs(GAG2_ACF_DEFAULT_MUTATIONS) do

        GAG2ACFRememberChoice(
            "MutationNames",
            mutation
        )
    end

    return state.Modules
end

function GAG2ACFGetFruitVisualizerController()

    local modules =
        GAG2ACFEnsureModules()

    if not modules then
        return nil
    end

    if modules.FruitVisualizerController ~= nil then
        return modules.FruitVisualizerController
    end

    if modules.FruitVisualizerControllerAttempted == true then
        return nil
    end

    modules.FruitVisualizerControllerAttempted =
        true

    local playerScripts =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("PlayerScripts")

    local controllers =
        playerScripts
        and playerScripts:FindFirstChild("Controllers")

    local module =
        controllers
        and controllers:FindFirstChild("FruitVisualizerController")

    if not module
    or module:IsA("ModuleScript") ~= true then
        return nil
    end

    local ok, controller =
        pcall(function()

            return require(
                module
            )
        end)

    if ok == true
    and type(controller) == "table" then

        modules.FruitVisualizerController =
            controller

        return controller
    end

    return nil
end

function GAG2ACFGetFruitBaseWeight(fruitName)

    fruitName =
        GAG2ACFClean(fruitName)

    if fruitName == "" then
        return nil
    end

    local modules =
        GAG2ACFEnsureModules()

    if not modules then
        return nil
    end

    modules.FruitBaseWeights =
        type(modules.FruitBaseWeights) == "table"
        and modules.FruitBaseWeights
        or {}

    if modules.FruitBaseWeights[fruitName] ~= nil then

        if modules.FruitBaseWeights[fruitName] == false then
            return nil
        end

        return modules.FruitBaseWeights[fruitName]
    end

    local plantGeneration =
        ReplicatedStorage:FindFirstChild("PlantGenerationModules")

    local fruitsFolder =
        plantGeneration
        and plantGeneration:FindFirstChild("Fruits")

    local module =
        fruitsFolder
        and fruitsFolder:FindFirstChild(fruitName)

    if not module
    or module:IsA("ModuleScript") ~= true then

        modules.FruitBaseWeights[fruitName] =
            false

        return nil
    end

    local ok, data =
        pcall(function()

            return require(
                module
            )
        end)

    if ok ~= true
    or type(data) ~= "table" then

        modules.FruitBaseWeights[fruitName] =
            false

        return nil
    end

    local baseWeight =
        data.GrowData
        and tonumber(data.GrowData.BaseWeight)

    if not baseWeight
    or baseWeight <= 0 then

        modules.FruitBaseWeights[fruitName] =
            false

        return nil
    end

    modules.FruitBaseWeights[fruitName] =
        baseWeight

    return baseWeight
end

function GAG2ACFCalculateFruitWeightKg(fruit, fruitName)

    if typeof(fruit) ~= "Instance" then
        return nil, "missing fruit"
    end

    local controller =
        GAG2ACFGetFruitVisualizerController()

    if controller
    and type(controller.CalculateFruitWeight) == "function" then

        local ok, result =
            pcall(function()

                return controller:CalculateFruitWeight(
                    fruit
                )
            end)

        if ok == true
        and tonumber(result)
        and tonumber(result) > 0 then

            return tonumber(result),
                "FruitVisualizerController"
        end
    end

    fruitName =
        GAG2ACFClean(
            fruitName
            or fruit:GetAttribute("CorePartName")
            or fruit:GetAttribute("SeedName")
        )

    local baseWeight =
        GAG2ACFGetFruitBaseWeight(
            fruitName
        )

    if not baseWeight then
        return nil, "missing BaseWeight"
    end

    local sizeMulti =
        tonumber(
            fruit:GetAttribute("SizeMulti")
        )

    if not sizeMulti
    or sizeMulti <= 0 then
        return nil, "missing SizeMulti"
    end

    local overtimeGrowth =
        tonumber(
            fruit:GetAttribute("OvertimeGrowth")
        )
        or 1

    if overtimeGrowth <= 0 then

        overtimeGrowth =
            1
    end

    return baseWeight
        * sizeMulti
        * overtimeGrowth,
        "BaseWeight formula"
end

function GAG2ACFFormatWeightKg(value)

    local weight =
        tonumber(value)

    if not weight then
        return "?kg"
    end

    return string.format(
        "%.2fkg",
        weight
    )
end

function GAG2ACFGetOwnGarden()

    if type(GAG2ResolveOwnFarmPlot) == "function" then

        local plot =
            nil

        pcall(function()

            plot =
                GAG2ResolveOwnFarmPlot()
        end)

        if typeof(plot) == "Instance" then
            return plot
        end
    end

    local gardens =
        workspace:FindFirstChild("Gardens")

    if not gardens then
        return nil
    end

    local playerName =
        tostring(LOCAL_PLAYER and LOCAL_PLAYER.Name or "")

    local userId =
        tostring(LOCAL_PLAYER and LOCAL_PLAYER.UserId or "")

    for _, garden in ipairs(gardens:GetChildren()) do

        local attrs =
            garden:GetAttributes()

        if tostring(attrs.Owner or "") == playerName
        or tostring(attrs.OwnerUserId or "") == userId then
            return garden
        end
    end

    return nil
end

function GAG2ACFGetHarvestPrompt(fruit)

    if typeof(fruit) ~= "Instance" then
        return nil
    end

    local harvestPart =
        fruit:FindFirstChild("HarvestPart")

    local prompt =
        harvestPart
        and harvestPart:FindFirstChild("HarvestPrompt")

    if prompt
    and prompt:IsA("ProximityPrompt")
    and prompt.Enabled == true then

        return prompt
    end

    local scanned =
        0

    for _, descendant in ipairs(fruit:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 350 then
            break
        end

        if descendant:IsA("ProximityPrompt")
        and descendant.Enabled == true then

            local promptName =
                tostring(descendant.Name or ""):lower()

            local parentName =
                descendant.Parent
                and tostring(descendant.Parent.Name or ""):lower()
                or ""

            if promptName == "harvestprompt"
            or promptName:find("harvest", 1, true)
            or parentName:find("harvest", 1, true) then

                return descendant
            end
        end
    end

    return nil
end

function GAG2ACFReadFruitName(fruit, plant)

    local name =
        ""

    if typeof(fruit) == "Instance" then

        name =
            GAG2ACFClean(
                fruit:GetAttribute("CorePartName")
            )
    end

    if name == ""
    and typeof(plant) == "Instance" then

        name =
            GAG2ACFClean(
                plant:GetAttribute("SeedName")
            )
    end

    if name == ""
    and typeof(fruit) == "Instance" then

        name =
            GAG2ACFClean(
                fruit.Name
            )
    end

    return name
end

function GAG2ACFReadMutation(fruit, plant)

    local mutation =
        ""

    if typeof(fruit) == "Instance" then

        mutation =
            GAG2ACFClean(
                fruit:GetAttribute("Mutation")
            )
    end

    -- Important:
    -- Do NOT fall back to plant:GetAttribute("Mutation").
    -- A Rainbow/Gold/etc plant can still grow normal fruits.
    -- Exclude Mutations should only block the fruit's own mutation.

    return mutation
end

function GAG2ACFGetMutationScore(mutation)

    mutation =
        GAG2ACFClean(mutation)

    if mutation == ""
    or mutation == "None" then
        return 1
    end

    local modules =
        GAG2ACFEnsureModules()

    local mutationData =
        modules
        and modules.MutationData

    if type(mutationData) == "table"
    and type(mutationData.ReturnPriceMultiplier) == "function" then

        local ok, result =
            pcall(
                mutationData.ReturnPriceMultiplier,
                mutation
            )

        if ok == true
        and tonumber(result) then

            return tonumber(result)
        end
    end

    return 1
end

function GAG2ACFGetSellWorth(name, weightKg, mutation, fruit)

    local modules =
        GAG2ACFEnsureModules()

    local fruitValueCalc =
        modules
        and modules.FruitValueCalc

    if type(fruitValueCalc) == "function" then

        local ok, result =
            pcall(
                fruitValueCalc,
                name,
                weightKg,
                mutation,
                fruit
            )

        if ok == true
        and tonumber(result) then

            return tonumber(result)
        end
    end

    local base =
        modules
        and type(modules.SellValueData) == "table"
        and tonumber(modules.SellValueData[name])
        or 0

    local mutationScore =
        GAG2ACFGetMutationScore(
            mutation
        )

    local weightMultiplier =
        tonumber(weightKg)

    if not weightMultiplier
    or weightMultiplier <= 0 then
        return 0
    end

    return math.floor(
        base
        * weightMultiplier
        * math.max(1, mutationScore)
    )
end

function GAG2ACFBuildEntry(plant, fruit)

    local prompt =
        GAG2ACFGetHarvestPrompt(
            fruit
        )

    if not prompt then
        return nil
    end

    local name =
        GAG2ACFReadFruitName(
            fruit,
            plant
        )

    if name == "" then
        return nil
    end

    local mutation =
        GAG2ACFReadMutation(
            fruit,
            plant
        )

    local weightKg, weightSource =
        GAG2ACFCalculateFruitWeightKg(
            fruit,
            GAG2ACFReadFruitName(
                fruit,
                plant
            )
        )

    if not weightKg then
        return nil
    end

    local rawSizeMulti =
        tonumber(
            fruit:GetAttribute("SizeMulti")
        )

    local modules =
        GAG2ACFEnsureModules()

    local seedRow =
        GAG2_AUTO_COLLECT_FRUIT_STATE.SeedMap[name]

    local rarity =
        seedRow
        and GAG2ACFClean(seedRow.Rarity)
        or "?"

    local rarityScore =
        GAG2_ACF_RARITY_SCORE[rarity]
        or 0

    local mutationScore =
        GAG2ACFGetMutationScore(
            mutation
        )

    local sellWorth =
        GAG2ACFGetSellWorth(
            name,
            weightKg,
            mutation,
            fruit
        )

    local fruitId =
        GAG2ACFClean(
            fruit:GetAttribute("FruitId")
        )

    local key =
        fruitId ~= ""
        and fruitId
        or PathOf(fruit)

    GAG2ACFRememberChoice(
        "FruitNames",
        name
    )

    if rarity ~= "?" then

        GAG2ACFRememberChoice(
            "RarityNames",
            rarity
        )
    end

    if mutation ~= "" then

        GAG2ACFRememberChoice(
            "MutationNames",
            mutation
        )
    end

    return {
        Plant = plant,
        Fruit = fruit,
        Prompt = prompt,
        Key = key,
        FruitId = fruitId,

        Name = name,
        Rarity = rarity,
        RarityScore = rarityScore,

        Mutation = mutation,
        MutationLabel =
            mutation ~= ""
            and mutation
            or "None",

        MutationScore = mutationScore,

        WeightKg = weightKg,
        WeightSource = weightSource,
        RawSizeMulti = rawSizeMulti,

        SellWorth = sellWorth,
    }
end

function GAG2ACFPassesCollectRules(entry)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.CollectMode == "Only Selected"
    and GAG2ACFTableCount(state.SelectedFruits) > 0
    and GAG2ACFSelectionHas(state.SelectedFruits, entry.Name) ~= true then

        return false
    end

    if state.CollectMode == "Only Selected"
    and GAG2ACFTableCount(state.SelectedFruits) <= 0 then

        return false
    end

    if GAG2ACFTableCount(state.SelectedRarities) > 0
    and GAG2ACFSelectionHas(state.SelectedRarities, entry.Rarity) ~= true then

        return false
    end

    if GAG2ACFTableCount(state.SelectedMutations) > 0
    and GAG2ACFSelectionHas(state.SelectedMutations, entry.MutationLabel) ~= true then

        return false
    end

    return true
end

function GAG2ACFPassesExclusions(entry)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if GAG2ACFSelectionHas(state.ExcludeFruits, entry.Name) == true then
        return false
    end

    if GAG2ACFSelectionHas(state.ExcludeRarities, entry.Rarity) == true then
        return false
    end

    if GAG2ACFSelectionHas(state.ExcludeMutations, entry.MutationLabel) == true then
        return false
    end

    local threshold =
        tonumber(state.ExcludeSizeThreshold)
        or 0

    if threshold > 0
    and state.ExcludeSizeMode ~= "Off" then

        local weightKg =
            tonumber(entry.WeightKg)

        if not weightKg then
            return false
        end

        if state.ExcludeSizeMode == "Above"
        and weightKg > threshold then
            return false
        end

        if state.ExcludeSizeMode == "Below"
        and weightKg < threshold then
            return false
        end
    end

    return true
end

function GAG2ACFEntryAllowed(entry)

    if type(entry) ~= "table" then
        return false
    end

    if GAG2ACFPassesCollectRules(entry) ~= true then
        return false
    end

    if GAG2ACFPassesExclusions(entry) ~= true then
        return false
    end

    return true
end

function GAG2ACFPriorityValue(entry, priorityName)

    priorityName =
        GAG2ACFClean(priorityName)

    if priorityName == "Rarity" then
        return tonumber(entry.RarityScore) or 0
    end

    if priorityName == "Weight" then
        return tonumber(entry.WeightKg)
    end

    if priorityName == "Mutation" then
        return tonumber(entry.MutationScore) or 1
    end

    if priorityName == "Sell Worth" then
        return tonumber(entry.SellWorth) or 0
    end

    if priorityName == "Fruit" then
        return tostring(entry.Name or "")
    end

    return nil
end

function GAG2ACFComparePriority(a, b, priorityName)

    priorityName =
        GAG2ACFClean(priorityName)

    if priorityName == ""
    or priorityName == "None" then
        return nil
    end

    local aValue =
        GAG2ACFPriorityValue(
            a,
            priorityName
        )

    local bValue =
        GAG2ACFPriorityValue(
            b,
            priorityName
        )

    if aValue == nil
    or bValue == nil
    or aValue == bValue then
        return nil
    end

    if priorityName == "Fruit" then
        return tostring(aValue) < tostring(bValue)
    end

    return tonumber(aValue or 0) > tonumber(bValue or 0)
end

function GAG2ACFSortQueue(queue)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    table.sort(queue, function(a, b)

        local result =
            GAG2ACFComparePriority(
                a,
                b,
                state.Priority1
            )

        if result ~= nil then
            return result
        end

        result =
            GAG2ACFComparePriority(
                a,
                b,
                state.Priority2
            )

        if result ~= nil then
            return result
        end

        result =
            GAG2ACFComparePriority(
                a,
                b,
                state.Priority3
            )

        if result ~= nil then
            return result
        end

        if tonumber(a.SellWorth or 0) ~= tonumber(b.SellWorth or 0) then

            return tonumber(a.SellWorth or 0)
                > tonumber(b.SellWorth or 0)
        end

        if tonumber(a.WeightKg or 0) ~= tonumber(b.WeightKg or 0) then

            return tonumber(a.WeightKg or 0)
                > tonumber(b.WeightKg or 0)
        end

        return tostring(a.Name or "")
            < tostring(b.Name or "")
    end)
end

function GAG2ACFScanQueue()

    GAG2ACFEnsureModules()

    local garden =
        GAG2ACFGetOwnGarden()

    local queue =
        {}

    local readyCount =
        0

    local excludedCount =
        0

    if not garden then

        return queue,
            0,
            0,
            "own garden missing"
    end

    local plants =
        garden:FindFirstChild("Plants")

    if not plants then

        return queue,
            0,
            0,
            "plants folder missing"
    end

    local seenPrompts =
        {}

    local function resolveFruitFromPrompt(plant, prompt)

        if typeof(plant) ~= "Instance"
        or typeof(prompt) ~= "Instance" then

            return nil
        end

        local current =
            prompt.Parent

        while typeof(current) == "Instance"
        and current ~= plants
        and current ~= garden
        and current ~= game do

            if current:IsA("Model") then

                return current
            end

            if current == plant then
                break
            end

            current =
                current.Parent
        end

        if plant:IsA("Model") then

            return plant
        end

        return nil
    end

    local function addPromptEntry(plant, prompt)

        if typeof(prompt) ~= "Instance"
        or prompt:IsA("ProximityPrompt") ~= true then

            return
        end

        if prompt.Enabled ~= true then
            return
        end

        if seenPrompts[prompt] == true then
            return
        end

        seenPrompts[prompt] =
            true

        local fruit =
            resolveFruitFromPrompt(
                plant,
                prompt
            )

        if typeof(fruit) ~= "Instance" then
            return
        end

        local entry =
            GAG2ACFBuildEntry(
                plant,
                fruit
            )

        if not entry then
            return
        end

        entry.Prompt =
            prompt

        if entry.FruitId == "" then

            entry.Key =
                PathOf(prompt)
        end

        readyCount = readyCount + 1

        if GAG2ACFEntryAllowed(entry) == true then

            table.insert(
                queue,
                entry
            )

        else

            excludedCount = excludedCount + 1
        end
    end

    for _, plant in ipairs(plants:GetChildren()) do

        if plant:IsA("Model")
        or plant:IsA("Folder") then

            -- Old structure:
            -- Plant -> Fruits -> FruitModel -> HarvestPart -> HarvestPrompt
            local fruits =
                plant:FindFirstChild("Fruits")

            if fruits then

                for _, fruit in ipairs(fruits:GetChildren()) do

                    if fruit:IsA("Model") then

                        local prompt =
                            GAG2ACFGetHarvestPrompt(
                                fruit
                            )

                        if prompt then

                            addPromptEntry(
                                plant,
                                prompt
                            )
                        end
                    end
                end
            end

            -- New/fallback structure:
            -- Plant can expose HarvestPrompt directly, or under a different descendant path.
            local scanned =
                0

            for _, descendant in ipairs(plant:GetDescendants()) do

                scanned = scanned + 1

                if scanned > 1800 then
                    break
                end

                if descendant:IsA("ProximityPrompt")
                and descendant.Enabled == true then

                    local promptName =
                        tostring(descendant.Name or ""):lower()

                    local parentName =
                        descendant.Parent
                        and tostring(descendant.Parent.Name or ""):lower()
                        or ""

                    if promptName == "harvestprompt"
                    or promptName:find("harvest", 1, true)
                    or parentName:find("harvest", 1, true) then

                        addPromptEntry(
                            plant,
                            descendant
                        )
                    end
                end
            end
        end
    end

    GAG2ACFSortQueue(
        queue
    )

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local now =
        os.clock()

    if now - tonumber(state.LastRefreshAt or 0) >= 5 then

        state.LastRefreshAt =
            now

        task.defer(function()

            if type(GAG2ACFRefreshDropdownValues) == "function" then

                GAG2ACFRefreshDropdownValues()
            end
        end)
    end

    return queue,
        readyCount,
        excludedCount,
        "ok"
end

function GAG2ACFBuildStatusText(queue, readyCount, excludedCount, note)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local matching =
        #queue

    local nextText =
        "None"

    if queue[1] then

        nextText =
            tostring(queue[1].Name)
            .. " | "
            .. tostring(queue[1].Rarity)
            .. " | "
            .. tostring(queue[1].MutationLabel)
            .. " | size "
            .. GAG2ACFFormatSize(queue[1].SizeMulti)
            .. " | worth "
            .. GAG2ACFFormatNumber(queue[1].SellWorth)
    end

    state.LastReadyCount =
        readyCount

    state.LastMatchingCount =
        matching

    state.LastExcludedCount =
        excludedCount

    state.LastNextText =
        nextText

    return '<font color="rgb(196,181,253)"><b>Auto Collect Fruits</b></font>'
        .. '\nState: '
        .. (
            state.Enabled == true
            and "ON"
            or "OFF"
        )
        .. '\nReady: '
        .. tostring(readyCount)
        .. ' | Matching: '
        .. tostring(matching)
        .. ' | Excluded: '
        .. tostring(excludedCount)
        .. '\nNext: '
        .. tostring(nextText)
        .. '\nPriority: '
        .. tostring(state.Priority1)
        .. ' > '
        .. tostring(state.Priority2)
        .. ' > '
        .. tostring(state.Priority3)
        .. '\nSpeed: '
        .. tostring(state.CollectionSpeed or "Normal")
        .. ' | Burst: '
        .. tostring(
            type(GAG2ACFGetEffectiveBurstAmount) == "function"
            and GAG2ACFGetEffectiveBurstAmount()
            or state.BurstAmount
        )
        .. ' | Cooldown: '
        .. tostring(
            type(GAG2ACFGetEffectiveRecentCooldown) == "function"
            and GAG2ACFGetEffectiveRecentCooldown()
            or 1.25
        )
        .. 's'
        .. '\nWeather: '
        .. GAG2ACFWeatherStatusText()
        .. '\nNote: '
        .. tostring(note or "Weight uses SizeMulti until exact KG is found.")
end

function GAG2ACFBackpackLooksFull()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.StopIfFull ~= true then
        return false
    end

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    local backpackGui =
        playerGui
        and playerGui:FindFirstChild("BackpackGui")

    if not backpackGui then
        return false
    end

    local scanned =
        0

    for _, descendant in ipairs(backpackGui:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 2500 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local text =
                GAG2ACFClean(
                    descendant.Text
                ):lower()

            if text:find("backpack", 1, true)
            and (
                text:find("full", 1, true)
                or text:find("max", 1, true)
            ) then

                return true
            end
        end
    end

    return false
end

function GAG2ACFFirePrompt(prompt)

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then
        return false, "bad prompt"
    end

    if prompt.Enabled ~= true then
        return false, "prompt disabled"
    end

    if type(fireproximityprompt) ~= "function" then
        return false, "fireproximityprompt unsupported"
    end

    local ok, err =
        pcall(
            fireproximityprompt,
            prompt
        )

    if ok ~= true then
        return false, tostring(err)
    end

    return true, "fired"
end

function GAG2ACFCollectBatch()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local pausedForWeather, weather =
        GAG2ACFShouldPauseForWeather()

    if pausedForWeather == true then

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                {},
                state.LastReadyCount or 0,
                state.LastExcludedCount or 0,
                "Paused for weather: "
                .. tostring(weather)
            )
        )

        return -1
    end

    local queue, readyCount, excludedCount, reason =
        GAG2ACFScanQueue()

    if reason ~= "ok" then

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                {},
                readyCount,
                excludedCount,
                reason
            )
        )

        return 0
    end

    if #queue <= 0 then

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                queue,
                readyCount,
                excludedCount,
                "No matching fruit."
            )
        )

        return 0
    end

    local burstAmount =
        GAG2ACFGetEffectiveBurstAmount()

    local recentCooldown =
        GAG2ACFGetEffectiveRecentCooldown()

    local promptDelay =
        GAG2ACFGetEffectivePromptDelay()

    local yieldEvery =
        GAG2ACFGetEffectiveYieldEvery()

    local fired =
        0

    for _, entry in ipairs(queue) do

        if fired >= burstAmount then
            break
        end

        if state.Enabled ~= true then
            break
        end

        local recentAt =
            tonumber(
                state.Recent[entry.Key]
            )
            or 0

        if os.clock() - recentAt >= recentCooldown then

            local ok =
                GAG2ACFFirePrompt(
                    entry.Prompt
                )

            state.Recent[entry.Key] =
                os.clock()

            if ok == true then

                fired = fired + 1

                state.LastFiredCount =
                    fired

                if type(GAG2AutoSellHandleCollectedFruit) == "function" then

                    GAG2AutoSellHandleCollectedFruit(
                        entry
                    )
                end
            end

            if promptDelay > 0 then

                task.wait(
                    promptDelay
                )

            elseif yieldEvery > 0
            and fired % yieldEvery == 0 then

                task.wait()
            end
        end
    end

    GAG2ACFSetStatus(
        GAG2ACFBuildStatusText(
            queue,
            readyCount,
            excludedCount,
            fired > 0
            and (
                "Collected "
                .. tostring(fired)
                .. " this batch."
            )
            or "No prompt fired."
        )
    )

    return fired
end

function GAG2ACFStartLoop()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        while state.Enabled == true do

            if GAG2ACFBackpackLooksFull() == true then

                if type(GAG2AutoSellIsEnabled) == "function"
                and GAG2AutoSellIsEnabled() == true then

                    if type(GAG2AutoSellScanExistingFruitTools) == "function" then

                        GAG2AutoSellScanExistingFruitTools(
                            "backpack full"
                        )
                    end

                    if type(GAG2AutoSellScheduleSellAll) == "function"
                    and GAG2_AUTO_SELL_FRUIT_STATE
                    and GAG2_AUTO_SELL_FRUIT_STATE.Method == "SellAll" then

                        GAG2AutoSellScheduleSellAll(
                            "backpack full"
                        )
                    end

                    GAG2ACFSetStatus(
                        '<font color="rgb(196,181,253)"><b>Auto Collect:</b></font>'
                        .. '\nBackpack full/max detected.'
                        .. '\nAuto Sell is ON, selling and continuing.'
                    )

                    task.wait(
                        0.15
                    )

                else

                    state.Enabled =
                        false

                    if Toggles.HolyGAG2AutoCollectFruits
                    and type(Toggles.HolyGAG2AutoCollectFruits.SetValue) == "function" then

                        pcall(function()

                            Toggles.HolyGAG2AutoCollectFruits:SetValue(
                                false
                            )
                        end)
                    end

                    GAG2ACFSetStatus(
                        '<font color="rgb(248,113,113)"><b>Auto Collect stopped:</b></font>'
                        .. '\nBackpack looks full/max.'
                    )

                    break
                end
            end

            local fired =
                GAG2ACFCollectBatch()

            if fired == -1 then

                task.wait(
                    0.75
                )

            elseif fired > 0 then

                local fireWait =
                    GAG2ACFGetLoopWaitAfterFire()

                if fireWait > 0 then

                    task.wait(
                        fireWait
                    )

                else

                    task.wait()
                end

            else

                task.wait(
                    GAG2ACFGetLoopWaitIdle()
                )
            end
        end

        state.Running =
            false

        if state.Enabled ~= true then

            GAG2ACFSetStatus(
                GAG2ACFBuildStatusText(
                    {},
                    state.LastReadyCount or 0,
                    state.LastExcludedCount or 0,
                    "Stopped."
                )
            )
        end
    end)
end

function GAG2ACFSetEnabled(value)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local enabled =
        value == true

    if enabled
    and GAG2_AUTO_SHOVEL_FRUIT_STATE
    and GAG2_AUTO_SHOVEL_FRUIT_STATE.Enabled == true then

        GAG2AutoShovelFruitSetEnabled(
            false
        )

        GAG2AutoShovelFruitSetToggleOff()
    end

    state.Enabled =
        enabled

    if state.Enabled == true then

        GAG2ACFSetStatus(
            "Auto Collect Fruits starting..."
        )

        if ConfigState.Loading ~= true then

            GAG2ACFStartLoop()
        end

    else

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                {},
                state.LastReadyCount or 0,
                state.LastExcludedCount or 0,
                "Stopped."
            )
        )
    end

    MarkConfigDirty()
end

function GAG2ACFSetStopIfFull(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.StopIfFull =
        value == true

    MarkConfigDirty()
end

function GAG2ACFGetSpeedPreset()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local speed =
        GAG2ACFClean(
            state.CollectionSpeed
        )

    local preset =
        GAG2_ACF_SPEED_PRESETS[speed]
        or GAG2_ACF_SPEED_PRESETS.Normal

    state.CollectionSpeed =
        preset.Name

    return preset
end

function GAG2ACFSetCollectionSpeed(value)

    value =
        GAG2ACFClean(value)

    if GAG2_ACF_SPEED_PRESETS[value] == nil then
        value =
            "Normal"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.CollectionSpeed =
        value

    MarkConfigDirty()
end

function GAG2ACFGetEffectiveBurstAmount()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local preset =
        GAG2ACFGetSpeedPreset()

    local inputBurst =
        math.clamp(
            math.floor(
                tonumber(state.BurstAmount)
                or 8
            ),
            1,
            160
        )

    return math.clamp(
        math.max(
            inputBurst,
            tonumber(preset.MinBurst) or inputBurst
        ),
        1,
        tonumber(preset.MaxBurst) or 160
    )
end

function GAG2ACFGetEffectiveRecentCooldown()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.clamp(
        tonumber(preset.RecentCooldown)
        or 1.25,
        0,
        2
    )
end

function GAG2ACFGetEffectivePromptDelay()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local preset =
        GAG2ACFGetSpeedPreset()

    if preset.PromptDelayOverride ~= nil then

        return math.clamp(
            tonumber(preset.PromptDelayOverride)
            or 0,
            0,
            2
        )
    end

    return math.clamp(
        tonumber(state.Delay)
        or 0,
        0,
        2
    )
end

function GAG2ACFGetEffectiveYieldEvery()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.max(
        1,
        math.floor(
            tonumber(preset.YieldEvery)
            or 6
        )
    )
end

function GAG2ACFGetLoopWaitAfterFire()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.clamp(
        tonumber(preset.LoopWaitAfterFire)
        or 0.03,
        0,
        1
    )
end

function GAG2ACFGetLoopWaitIdle()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.clamp(
        tonumber(preset.LoopWaitIdle)
        or 0.35,
        0.02,
        2
    )
end

function GAG2ACFSetPauseDuringWeather(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.PauseDuringWeather =
        value == true

    GAG2ACFStartWeatherWatcher()

    MarkConfigDirty()
end

function GAG2ACFSetPauseWeatherMode(value)

    value =
        GAG2ACFClean(value)

    if value ~= "Selected" then
        value =
            "Any Weather"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.PauseWeatherMode =
        value

    GAG2ACFStartWeatherWatcher()

    MarkConfigDirty()
end

function GAG2ACFSetPauseWeathers(value)

    local selected =
        GAG2ACFNormalizeSelection(
            value
        )

    GAG2_AUTO_COLLECT_FRUIT_STATE.PauseWeathers =
        selected

    GAG2ACFStartWeatherWatcher()

    MarkConfigDirty()
end

function GAG2ACFSetDelay(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.Delay =
        math.clamp(
            tonumber(value)
            or 0,
            0,
            2
        )

    MarkConfigDirty()
end

function GAG2ACFSetBurst(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.BurstAmount =
        math.clamp(
            math.floor(
                tonumber(value)
                or 8
            ),
            1,
            160
        )

    MarkConfigDirty()
end

function GAG2ACFSetCollectMode(value)

    value =
        GAG2ACFClean(value)

    if value ~= "Only Selected" then
        value =
            "All"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.CollectMode =
        value

    MarkConfigDirty()
end

function GAG2ACFSetDropdownMap(key, value)

    GAG2_AUTO_COLLECT_FRUIT_STATE[key] =
        GAG2ACFNormalizeSelection(
            value
        )

    MarkConfigDirty()
end

function GAG2ACFSetExcludeSizeMode(value)

    value =
        GAG2ACFClean(value)

    if value ~= "Above"
    and value ~= "Below" then
        value =
            "Off"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.ExcludeSizeMode =
        value

    MarkConfigDirty()
end

function GAG2ACFSetExcludeSizeThreshold(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.ExcludeSizeThreshold =
        math.max(
            0,
            tonumber(value)
            or 0
        )

    MarkConfigDirty()
end

function GAG2ACFSetPriority(slot, value)

    slot =
        tonumber(slot)

    if not slot
    or slot < 1
    or slot > 3 then
        return
    end

    value =
        GAG2ACFClean(value)

    if table.find(GAG2_ACF_PRIORITY_VALUES, value) == nil then
        value =
            "None"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE[
        "Priority"
        .. tostring(slot)
    ] =
        value

    MarkConfigDirty()
end

function GAG2ACFGetFruitDropdownValues()

    GAG2ACFEnsureModules()

    local names =
        {}

    local function add(name)

        name =
            GAG2ACFClean(name)

        if name == "" then
            return
        end

        if table.find(names, name) ~= nil then
            return
        end

        table.insert(
            names,
            name
        )
    end

    for _, name in ipairs(GAG2_AUTO_COLLECT_FRUIT_STATE.FruitNames or {}) do
        add(name)
    end

    local garden =
        GAG2ACFGetOwnGarden()

    local plants =
        garden
        and garden:FindFirstChild("Plants")

    if plants then

        for _, plant in ipairs(plants:GetChildren()) do

            add(
                plant:GetAttribute("SeedName")
            )

            local fruits =
                plant:FindFirstChild("Fruits")

            if fruits then

                for _, fruit in ipairs(fruits:GetChildren()) do

                    add(
                        fruit:GetAttribute("CorePartName")
                    )
                end
            end
        end
    end

    table.sort(
        names
    )

    return names
end

function GAG2ACFGetRarityDropdownValues()

    GAG2ACFEnsureModules()

    local values =
        {}

    local function add(value)

        value =
            GAG2ACFClean(value)

        if value == "" then
            return
        end

        if table.find(values, value) ~= nil then
            return
        end

        table.insert(
            values,
            value
        )
    end

    for _, rarity in ipairs(GAG2_AUTO_COLLECT_FRUIT_STATE.RarityNames or {}) do
        add(rarity)
    end

    table.sort(values, function(a, b)

        return (GAG2_ACF_RARITY_SCORE[a] or 0)
            > (GAG2_ACF_RARITY_SCORE[b] or 0)
    end)

    return values
end

function GAG2ACFGetMutationDropdownValues()

    GAG2ACFEnsureModules()

    local values =
        {}

    local function add(value)

        value =
            GAG2ACFClean(value)

        if value == "" then
            value =
                "None"
        end

        if table.find(values, value) ~= nil then
            return
        end

        table.insert(
            values,
            value
        )
    end

    for _, mutation in ipairs(GAG2_AUTO_COLLECT_FRUIT_STATE.MutationNames or {}) do
        add(mutation)
    end

    table.sort(values, function(a, b)

        if a == "None" then
            return true
        end

        if b == "None" then
            return false
        end

        return tostring(a) < tostring(b)
    end)

    return values
end

function GAG2ACFRefreshOneDropdown(dropdown, values)

    if not dropdown then
        return
    end

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

function GAG2ACFRefreshDropdownValues()

    local controls =
        GAG2_AUTO_COLLECT_FRUIT_CONTROLS

    GAG2ACFRefreshOneDropdown(
        controls.SelectedFruits,
        GAG2ACFGetFruitDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.ExcludeFruits,
        GAG2ACFGetFruitDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.SelectedRarities,
        GAG2ACFGetRarityDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.ExcludeRarities,
        GAG2ACFGetRarityDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.SelectedMutations,
        GAG2ACFGetMutationDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.ExcludeMutations,
        GAG2ACFGetMutationDropdownValues()
    )
end

function GAG2RestoreAutoCollectFruitState()

    task.defer(function()

        local state =
            GAG2_AUTO_COLLECT_FRUIT_STATE

        if Toggles.HolyGAG2AutoCollectFruits then

            state.Enabled =
                Toggles.HolyGAG2AutoCollectFruits.Value == true
        end

        GAG2ACFStartWeatherWatcher()

        if Toggles.HolyGAG2ACFStopIfFull then

            state.StopIfFull =
                Toggles.HolyGAG2ACFStopIfFull.Value == true
        end

        if Toggles.HolyGAG2ACFPauseDuringWeather then

            state.PauseDuringWeather =
                Toggles.HolyGAG2ACFPauseDuringWeather.Value == true
        end

        if Options.HolyGAG2ACFPauseWeatherMode then

            GAG2ACFSetPauseWeatherMode(
                Options.HolyGAG2ACFPauseWeatherMode.Value
            )
        end

        if Options.HolyGAG2ACFPauseWeathers then

            GAG2ACFSetPauseWeathers(
                Options.HolyGAG2ACFPauseWeathers.Value
            )
        end

        if Options.HolyGAG2ACFCollectionSpeed then

            GAG2ACFSetCollectionSpeed(
                Options.HolyGAG2ACFCollectionSpeed.Value
            )
        end

        if Options.HolyGAG2ACFDelay then

            GAG2ACFSetDelay(
                Options.HolyGAG2ACFDelay.Value
            )
        end

        if Options.HolyGAG2ACFBurst then

            GAG2ACFSetBurst(
                Options.HolyGAG2ACFBurst.Value
            )
        end

        if Options.HolyGAG2ACFCollectMode then

            GAG2ACFSetCollectMode(
                Options.HolyGAG2ACFCollectMode.Value
            )
        end

        if Options.HolyGAG2ACFSelectedFruits then

            GAG2ACFSetDropdownMap(
                "SelectedFruits",
                Options.HolyGAG2ACFSelectedFruits.Value
            )
        end

        if Options.HolyGAG2ACFSelectedRarities then

            GAG2ACFSetDropdownMap(
                "SelectedRarities",
                Options.HolyGAG2ACFSelectedRarities.Value
            )
        end

        if Options.HolyGAG2ACFSelectedMutations then

            GAG2ACFSetDropdownMap(
                "SelectedMutations",
                Options.HolyGAG2ACFSelectedMutations.Value
            )
        end

        if Options.HolyGAG2ACFExcludeFruits then

            GAG2ACFSetDropdownMap(
                "ExcludeFruits",
                Options.HolyGAG2ACFExcludeFruits.Value
            )
        end

        if Options.HolyGAG2ACFExcludeRarities then

            GAG2ACFSetDropdownMap(
                "ExcludeRarities",
                Options.HolyGAG2ACFExcludeRarities.Value
            )
        end

        if Options.HolyGAG2ACFExcludeMutations then

            GAG2ACFSetDropdownMap(
                "ExcludeMutations",
                Options.HolyGAG2ACFExcludeMutations.Value
            )
        end

        if Options.HolyGAG2ACFExcludeSizeMode then

            GAG2ACFSetExcludeSizeMode(
                Options.HolyGAG2ACFExcludeSizeMode.Value
            )
        end

        if Options.HolyGAG2ACFExcludeSizeThreshold then

            GAG2ACFSetExcludeSizeThreshold(
                Options.HolyGAG2ACFExcludeSizeThreshold.Value
            )
        end

        for slot = 1, 3 do

            local option =
                Options[
                    "HolyGAG2ACFPriority"
                    .. tostring(slot)
                ]

            if option then

                GAG2ACFSetPriority(
                    slot,
                    option.Value
                )
            end
        end

        GAG2ACFRefreshDropdownValues()

        if state.Enabled == true then

            GAG2ACFStartLoop()

        else

            local queue, readyCount, excludedCount =
                GAG2ACFScanQueue()

            GAG2ACFSetStatus(
                GAG2ACFBuildStatusText(
                    queue,
                    readyCount,
                    excludedCount,
                    "Ready."
                )
            )
        end
    end)
end

--==================================================
-- [4.57] AUTO SELL FRUITS
-- Event-based instant fruit selling.
-- Packets confirmed:
-- NPCS.SellAll:Fire()
-- NPCS.SellFruit:Fire(fruitId)
--==================================================

GAG2_AUTO_SELL_FRUIT_STATE =
    GAG2_AUTO_SELL_FRUIT_STATE
    or {
        Enabled = false,
        Started = false,
        Running = false,

        Method = "SellAll",
        Speed = "Fast",
        RepeatCount = 1,

        Queue = {},
        QueueMap = {},
        RecentFruitIds = {},

        SellAllPending = false,
        LastSellAllAt = 0,
        LastSellFruitAt = 0,
        LastTriggerAt = 0,

        Packets = {},
        Connections = {},

        LastStatus = "Idle.",
        LastMethod = "None",
        LastFruitId = "",
        LastFruitName = "",
    }

GAG2_AUTO_SELL_METHOD_VALUES = {
    "SellAll",
    "SellFruit",
}

GAG2_AUTO_SELL_SPEED_VALUES = {
    "Normal",
    "Fast",
    "Ultra",
}

GAG2_AUTO_SELL_SPEED_PRESETS = {
    Normal = {
        SellAllDebounce = 0.18,
        SellFruitBurst = 8,
        SellFruitCycleWait = 0.04,
        YieldEvery = 8,
    },

    Fast = {
        SellAllDebounce = 0.07,
        SellFruitBurst = 25,
        SellFruitCycleWait = 0.015,
        YieldEvery = 18,
    },

    Ultra = {
        SellAllDebounce = 0.03,
        SellFruitBurst = 60,
        SellFruitCycleWait = 0,
        YieldEvery = 45,
    },
}

function GAG2AutoSellSetStatus(text)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2SellStatus then

        Options.HolyGAG2SellStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Auto Sell</b></font>'
            .. '\n'
            .. state.LastStatus
            .. '\nMethod: '
            .. tostring(state.Method or "SellAll")
            .. ' | Speed: '
            .. tostring(state.Speed or "Fast")
            .. ' | Repeat: '
            .. tostring(state.RepeatCount or 1)
        )
    end
end

function GAG2AutoSellClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2AutoSellGetPreset()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local speed =
        GAG2AutoSellClean(
            state.Speed
        )

    local preset =
        GAG2_AUTO_SELL_SPEED_PRESETS[speed]
        or GAG2_AUTO_SELL_SPEED_PRESETS.Fast

    state.Speed =
        speed ~= ""
        and GAG2_AUTO_SELL_SPEED_PRESETS[speed] ~= nil
        and speed
        or "Fast"

    return preset
end

function GAG2AutoSellGetRepeatCount()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local count =
        math.floor(
            tonumber(state.RepeatCount)
            or 1
        )

    return math.clamp(
        count,
        1,
        500
    )
end

function GAG2AutoSellSetRepeatCount(value)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.RepeatCount =
        math.clamp(
            math.floor(
                tonumber(value)
                or 1
            ),
            1,
            500
        )

    GAG2AutoSellSetStatus(
        "Repeat Count set: "
        .. tostring(state.RepeatCount)
    )

    MarkConfigDirty()
end

function GAG2AutoSellGetNPCSRoot()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local networking =
        sharedModules
        and sharedModules:FindFirstChild("Networking")

    local npcs =
        networking
        and networking:FindFirstChild("NPCS")

    return npcs
end

function GAG2AutoSellResolvePacket(packetName)

    packetName =
        GAG2AutoSellClean(packetName)

    if packetName == "" then
        return nil,
            "missing packet name"
    end

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.Packets =
        type(state.Packets) == "table"
        and state.Packets
        or {}

    if state.Packets[packetName] then
        return state.Packets[packetName],
            "cached"
    end

    -- Primary path:
    -- Use the already-working packet table scanner from the shop/sniper systems.
    local packets =
        nil

    if type(SniperFindPacketTable) == "function" then

        packets =
            SniperFindPacketTable()
    end

    if type(packets) == "table"
    and type(SniperSafeRawGet) == "function" then

        local npcs =
            SniperSafeRawGet(
                packets,
                "NPCS"
            )

        if type(npcs) == "table" then

            local packet =
                SniperSafeRawGet(
                    npcs,
                    packetName
                )

            local okFire, fireFunction =
                pcall(function()

                    return packet.Fire
                end)

            if okFire == true
            and type(fireFunction) == "function" then

                state.Packets[packetName] =
                    packet

                return packet,
                    "packet table NPCS."
                    .. tostring(packetName)
            end
        end
    end

    -- Backup path:
    -- Some sessions expose the module directly as a descendant, not direct NPCS child.
    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local module =
        nil

    if sharedModules then

        for _, descendant in ipairs(sharedModules:GetDescendants()) do

            if descendant:IsA("ModuleScript")
            and descendant.Name == packetName
            and PathOf(descendant):find("NPCS", 1, true) then

                module =
                    descendant

                break
            end
        end
    end

    if not module then

        return nil,
            "NPCS packet not found: "
            .. tostring(packetName)
            .. " | source: "
            .. tostring(
                SniperState
                and SniperState.PacketSource
                or "no packet source"
            )
    end

    local okRequire, packet =
        pcall(function()

            return require(
                module
            )
        end)

    if okRequire ~= true
    or type(packet) ~= "table" then

        return nil,
            "packet require failed: "
            .. PathOf(module)
    end

    local okFire, fireFunction =
        pcall(function()

            return packet.Fire
        end)

    if okFire ~= true
    or type(fireFunction) ~= "function" then

        return nil,
            "packet Fire missing: "
            .. PathOf(module)
    end

    state.Packets[packetName] =
        packet

    return packet,
        "module descendant: "
        .. PathOf(module)
end

function GAG2AutoSellFirePacket(packetName, ...)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local packet, reason =
        GAG2AutoSellResolvePacket(
            packetName
        )

    if not packet then

        GAG2AutoSellSetStatus(
            "Sell packet missing: "
            .. tostring(reason)
        )

        warn(
            "[HOLY AUTO SELL]",
            "packet missing",
            tostring(packetName),
            tostring(reason)
        )

        return false,
            reason
    end

    local args =
        {
            ...
        }

    local repeatCount =
        GAG2AutoSellGetRepeatCount()

    local fired =
        0

    local lastError =
        nil

    for index = 1, repeatCount do

        local ok, err =
            pcall(function()

                packet:Fire(
                    table.unpack(args)
                )
            end)

        if ok ~= true then

            ok, err =
                pcall(function()

                    packet.Fire(
                        packet,
                        table.unpack(args)
                    )
                end)
        end

        if ok == true then

            fired = fired + 1

        else

            lastError =
                err
        end
    end

    if fired <= 0 then

        GAG2AutoSellSetStatus(
            "Sell failed: "
            .. tostring(lastError)
        )

        warn(
            "[HOLY AUTO SELL]",
            "fire failed",
            tostring(packetName),
            tostring(lastError)
        )

        return false,
            tostring(lastError)
    end

    local now =
        os.clock()

    if packetName == "SellAll" then

        state.LastSellAllAt =
            now

    elseif packetName == "SellFruit" then

        state.LastSellFruitAt =
            now
    end

    state.LastMethod =
        tostring(packetName)
        .. " x"
        .. tostring(fired)

    GAG2AutoSellSetStatus(
        "Fired "
        .. tostring(packetName)
        .. " x"
        .. tostring(fired)
        .. " | "
        .. tostring(reason)
    )

    return true,
        "fired x"
        .. tostring(fired)
end

function GAG2AutoSellIsFruitTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then
        return false,
            "",
            ""
    end

    local harvested =
        tool:GetAttribute("HarvestedFruit")

    local fruitId =
        GAG2AutoSellClean(
            tool:GetAttribute("Id")
        )

    local fruitName =
        GAG2AutoSellClean(
            tool:GetAttribute("FruitName")
            or tool:GetAttribute("Fruit")
        )

    if harvested == true
    and fruitId ~= "" then

        return true,
            fruitId,
            fruitName
    end

    return false,
        "",
        fruitName
end

function GAG2AutoSellScheduleSellAll(reason)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Enabled ~= true then
        return
    end

    if state.Method ~= "SellAll" then
        return
    end

    if state.SellAllPending == true then
        return
    end

    state.SellAllPending =
        true

    local preset =
        GAG2AutoSellGetPreset()

    local debounce =
        math.clamp(
            tonumber(preset.SellAllDebounce)
            or 0.07,
            0.01,
            1
        )

    task.delay(debounce, function()

        state.SellAllPending =
            false

        if state.Enabled ~= true then
            return
        end

        if state.Method ~= "SellAll" then
            return
        end

        GAG2AutoSellFirePacket(
            "SellAll"
        )
    end)

    GAG2AutoSellSetStatus(
        "SellAll queued: "
        .. tostring(reason or "fruit")
    )
end

function GAG2AutoSellQueueFruitId(fruitId, fruitName)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    fruitId =
        GAG2AutoSellClean(fruitId)

    fruitName =
        GAG2AutoSellClean(fruitName)

    if fruitId == "" then
        return
    end

    state.Queue =
        type(state.Queue) == "table"
        and state.Queue
        or {}

    state.QueueMap =
        type(state.QueueMap) == "table"
        and state.QueueMap
        or {}

    if state.QueueMap[fruitId] == true then
        return
    end

    state.QueueMap[fruitId] =
        true

    table.insert(state.Queue, {
        Id = fruitId,
        Name = fruitName,
    })

    state.LastFruitId =
        fruitId

    state.LastFruitName =
        fruitName

    GAG2AutoSellStartWorker()
end

function GAG2AutoSellStartWorker()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        while state.Enabled == true
        and state.Method == "SellFruit"
        and type(state.Queue) == "table"
        and #state.Queue > 0 do

            local preset =
                GAG2AutoSellGetPreset()

            local burst =
                math.clamp(
                    math.floor(
                        tonumber(preset.SellFruitBurst)
                        or 25
                    ),
                    1,
                    100
                )

            local yieldEvery =
                math.max(
                    1,
                    math.floor(
                        tonumber(preset.YieldEvery)
                        or 18
                    )
                )

            local fired =
                0

            while fired < burst
            and #state.Queue > 0
            and state.Enabled == true
            and state.Method == "SellFruit" do

                local item =
                    table.remove(
                        state.Queue,
                        1
                    )

                if item
                and item.Id then

                    state.QueueMap[item.Id] =
                        nil

                    GAG2AutoSellFirePacket(
                        "SellFruit",
                        item.Id
                    )

                    state.LastFruitId =
                        item.Id

                    state.LastFruitName =
                        tostring(item.Name or "")

                    fired = fired + 1

                    if fired % yieldEvery == 0 then
                        task.wait()
                    end
                end
            end

            local waitTime =
                math.clamp(
                    tonumber(preset.SellFruitCycleWait)
                    or 0.015,
                    0,
                    1
                )

            if waitTime > 0 then

                task.wait(
                    waitTime
                )

            else

                task.wait()
            end
        end

        state.Running =
            false
    end)
end

function GAG2AutoSellHandleFruitTool(tool, reason)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Enabled ~= true then
        return false
    end

    local isFruit, fruitId, fruitName =
        GAG2AutoSellIsFruitTool(
            tool
        )

    if isFruit ~= true then
        return false
    end

    local now =
        os.clock()

    local recent =
        tonumber(
            state.RecentFruitIds[fruitId]
        )
        or 0

    if now - recent < 0.18 then
        return false
    end

    state.RecentFruitIds[fruitId] =
        now

    state.LastTriggerAt =
        now

    state.LastFruitId =
        fruitId

    state.LastFruitName =
        fruitName

    if state.Method == "SellFruit" then

        GAG2AutoSellQueueFruitId(
            fruitId,
            fruitName
        )

    else

        GAG2AutoSellScheduleSellAll(
            reason or fruitName or "fruit"
        )
    end

    return true
end

function GAG2AutoSellScanExistingFruitTools(reason)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Enabled ~= true then
        return 0
    end

    local found =
        0

    local function scanContainer(container)

        if typeof(container) ~= "Instance" then
            return
        end

        for _, child in ipairs(container:GetChildren()) do

            if child:IsA("Tool") then

                if GAG2AutoSellHandleFruitTool(
                    child,
                    reason or "scan"
                ) == true then

                    found = found + 1
                end
            end
        end
    end

    local backpack =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("Backpack")

    scanContainer(
        backpack
    )

    scanContainer(
        LOCAL_PLAYER and LOCAL_PLAYER.Character
    )

    if found > 0 then

        GAG2AutoSellSetStatus(
            "Detected "
            .. tostring(found)
            .. " fruit tool(s)."
        )
    end

    return found
end

function GAG2AutoSellHookCharacter(character)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if typeof(character) ~= "Instance" then
        return
    end

    local connection =
        character.ChildAdded:Connect(function(child)

            if state.Enabled ~= true then
                return
            end

            if child:IsA("Tool") then

                task.defer(function()

                    GAG2AutoSellHandleFruitTool(
                        child,
                        "character"
                    )
                end)
            end
        end)

    table.insert(
        state.Connections,
        connection
    )
end

function GAG2AutoSellStartWatcher()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Started == true then
        return
    end

    state.Started =
        true

    state.Connections =
        type(state.Connections) == "table"
        and state.Connections
        or {}

    local backpack =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("Backpack")
        or LOCAL_PLAYER
        and LOCAL_PLAYER:WaitForChild("Backpack", 10)

    if backpack then

        table.insert(
            state.Connections,
            backpack.ChildAdded:Connect(function(child)

                if state.Enabled ~= true then
                    return
                end

                if child:IsA("Tool") then

                    task.defer(function()

                        GAG2AutoSellHandleFruitTool(
                            child,
                            "backpack"
                        )
                    end)
                end
            end)
        )
    end

    GAG2AutoSellHookCharacter(
        LOCAL_PLAYER.Character
    )

    table.insert(
        state.Connections,
        LOCAL_PLAYER.CharacterAdded:Connect(function(character)

            task.wait(
                0.35
            )

            GAG2AutoSellHookCharacter(
                character
            )

            if state.Enabled == true then

                GAG2AutoSellScanExistingFruitTools(
                    "respawn"
                )
            end
        end)
    )
end

function GAG2AutoSellSetEnabled(value)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.Enabled =
        value == true

    GAG2AutoSellStartWatcher()

    if state.Enabled == true then

        GAG2AutoSellSetStatus(
            "Auto Sell enabled."
        )

        task.defer(function()

            GAG2AutoSellScanExistingFruitTools(
                "enable"
            )
        end)

    else

        GAG2AutoSellSetStatus(
            "Auto Sell disabled."
        )
    end

    MarkConfigDirty()
end

function GAG2AutoSellSetMethod(value)

    value =
        GAG2AutoSellClean(value)

    if table.find(GAG2_AUTO_SELL_METHOD_VALUES, value) == nil then
        value =
            "SellAll"
    end

    GAG2_AUTO_SELL_FRUIT_STATE.Method =
        value

    GAG2_AUTO_SELL_FRUIT_STATE.Queue =
        {}

    GAG2_AUTO_SELL_FRUIT_STATE.QueueMap =
        {}

    if GAG2_AUTO_SELL_FRUIT_STATE.Enabled == true then

        task.defer(function()

            GAG2AutoSellScanExistingFruitTools(
                "method changed"
            )
        end)
    end

    GAG2AutoSellSetStatus(
        "Method set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2AutoSellSetSpeed(value)

    value =
        GAG2AutoSellClean(value)

    if GAG2_AUTO_SELL_SPEED_PRESETS[value] == nil then
        value =
            "Fast"
    end

    GAG2_AUTO_SELL_FRUIT_STATE.Speed =
        value

    GAG2AutoSellSetStatus(
        "Speed set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2AutoSellStop()

    GAG2_AUTO_SELL_FRUIT_STATE.Enabled =
        false

    GAG2_AUTO_SELL_FRUIT_STATE.Queue =
        {}

    GAG2_AUTO_SELL_FRUIT_STATE.QueueMap =
        {}

    if Toggles.HolyGAG2AutoSellFruits
    and type(Toggles.HolyGAG2AutoSellFruits.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2AutoSellFruits:SetValue(
                false
            )
        end)
    end

    GAG2AutoSellSetStatus(
        "Auto Sell stopped."
    )

    MarkConfigDirty()
end

function GAG2AutoSellIsEnabled()

    return type(GAG2_AUTO_SELL_FRUIT_STATE) == "table"
        and GAG2_AUTO_SELL_FRUIT_STATE.Enabled == true
end

function GAG2AutoSellHandleCollectedFruit(entry)

    if type(entry) ~= "table" then
        return false
    end

    if type(GAG2AutoSellIsEnabled) ~= "function"
    or GAG2AutoSellIsEnabled() ~= true then
        return false
    end

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local method =
        tostring(state.Method or "SellAll")

    if method == "SellFruit" then

        local fruitId =
            GAG2AutoSellClean(
                entry.FruitId
                or entry.Key
            )

        if fruitId == ""
        or fruitId:find("%.") then
            return false
        end

        task.delay(0.05, function()

            if GAG2AutoSellIsEnabled() == true
            and GAG2_AUTO_SELL_FRUIT_STATE.Method == "SellFruit" then

                GAG2AutoSellQueueFruitId(
                    fruitId,
                    tostring(entry.Name or "")
                )
            end
        end)

        return true
    end

    if method == "SellAll" then

        GAG2AutoSellScheduleSellAll(
            "collected "
            .. tostring(entry.Name or "fruit")
        )

        return true
    end

    return false
end

function GAG2AutoSellExposeDebug()

    getgenv().HOLY_GAG2_AUTO_SELL_STATE =
        GAG2_AUTO_SELL_FRUIT_STATE

    getgenv().HOLY_GAG2_AUTO_SELL_FIRE_ALL =
        function()

            return GAG2AutoSellFirePacket(
                "SellAll"
            )
        end

    getgenv().HOLY_GAG2_AUTO_SELL_FIRE_FRUIT =
        function(fruitId)

            return GAG2AutoSellFirePacket(
                "SellFruit",
                fruitId
            )
        end

    getgenv().HOLY_GAG2_AUTO_SELL_ENABLE =
        function(value)

            return GAG2AutoSellSetEnabled(
                value ~= false
            )
        end

    getgenv().HOLY_GAG2_AUTO_SELL_RESOLVE =
        function(packetName)

            return GAG2AutoSellResolvePacket(
                packetName or "SellAll"
            )
        end
end

function GAG2RestoreAutoSellState()

    task.defer(function()

        local state =
            GAG2_AUTO_SELL_FRUIT_STATE

        GAG2AutoSellExposeDebug()

        GAG2AutoSellStartWatcher()

        if Options.HolyGAG2AutoSellMethod then

            GAG2AutoSellSetMethod(
                Options.HolyGAG2AutoSellMethod.Value
            )
        end

        if Options.HolyGAG2AutoSellSpeed then

            GAG2AutoSellSetSpeed(
                Options.HolyGAG2AutoSellSpeed.Value
            )
        end

        if Options.HolyGAG2AutoSellRepeatCount then

            GAG2AutoSellSetRepeatCount(
                Options.HolyGAG2AutoSellRepeatCount.Value
            )
        end

        if Toggles.HolyGAG2AutoSellFruits then

            state.Enabled =
                Toggles.HolyGAG2AutoSellFruits.Value == true
        end

        if state.Enabled == true then

            GAG2AutoSellSetStatus(
                "Auto Sell restored."
            )

            GAG2AutoSellScanExistingFruitTools(
                "restore"
            )

        else

            GAG2AutoSellSetStatus(
                "Idle."
            )
        end
    end)
end

--==================================================
-- [4.57] AUTO SHOVEL PLANTS
-- Own-plot-only ordered plant deletion queue.
--==================================================

GAG2_AUTO_SHOVEL_COLLECTION_SERVICE =
    game:GetService("CollectionService")

if type(GAG2_AUTO_SHOVEL_STATE) == "table" then

    GAG2_AUTO_SHOVEL_STATE.Enabled = false
    GAG2_AUTO_SHOVEL_STATE.WorkerGeneration =
        (tonumber(GAG2_AUTO_SHOVEL_STATE.WorkerGeneration) or 0) + 1

    GAG2_AUTO_SHOVEL_STATE.MonitorGeneration =
        (tonumber(GAG2_AUTO_SHOVEL_STATE.MonitorGeneration) or 0) + 1
end

GAG2_AUTO_SHOVEL_STATE = {
    Enabled = false,
    Running = false,
    WorkerGeneration = 0,
    MonitorGeneration = 0,

    Queue = {},
    SelectedPlant = "",
    SelectedQueueIndex = 0,

    Delay = 0.70,
    ProtectedMutations = {
        Gold = true,
        Rainbow = true,
    },

    UseShovelPacket = nil,
    PacketSource = "not resolved",

    OwnPlot = nil,
    PlantsFolder = nil,
    Summary = {},
    TotalPlants = 0,
    PlantTypes = 0,

    PlantChoiceMap = {},
    QueueChoiceMap = {},

    RemovedThisRun = 0,
    FailedThisRun = 0,
    ProtectedSkipped = 0,

    CurrentQueueIndex = 0,
    CurrentQueueTotal = 0,
    CurrentPlant = "",

    LastSentAt = 0,
    LastStatus = "Idle.",

    UpdatingUI = false,
    SavingQueueText = false,
    RefreshScheduled = false,
}

GAG2_AUTO_SHOVEL_CONTROLS =
    GAG2_AUTO_SHOVEL_CONTROLS or {}

function GAG2AutoShovelClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2AutoShovelClampLimit(value)

    local number = tonumber(value) or 0

    if number ~= number
    or number == math.huge
    or number == -math.huge then
        number = 0
    end

    return math.clamp(math.floor(number), 0, 100000)
end

function GAG2AutoShovelSetDelay(value)

    local number = tonumber(value) or 0.70

    if number ~= number
    or number == math.huge
    or number == -math.huge then
        number = 0.70
    end

    GAG2_AUTO_SHOVEL_STATE.Delay =
        math.clamp(number, 0, 60)

    MarkConfigDirty()
    GAG2AutoShovelScheduleRefresh()
end

function GAG2AutoShovelGetEffectiveDelay()

    return math.max(
        tonumber(GAG2_AUTO_SHOVEL_STATE.Delay) or 0.70,
        0.65
    )
end

function GAG2AutoShovelSetDropdownValues(dropdown, values)

    if not dropdown then
        return
    end

    pcall(function()

        if type(dropdown.SetValues) == "function" then
            dropdown:SetValues(values)
        elseif type(dropdown.SetItems) == "function" then
            dropdown:SetItems(values)
        end
    end)
end

function GAG2AutoShovelSetDropdownValue(dropdown, value)

    if dropdown
    and type(dropdown.SetValue) == "function" then
        pcall(dropdown.SetValue, dropdown, value)
    end
end

function GAG2AutoShovelSetStatusLabel(text)

    local label =
        GAG2_AUTO_SHOVEL_CONTROLS.StatusLabel

    if not label then
        return
    end

    pcall(function()

        if type(label.SetText) == "function" then
            label:SetText(tostring(text or ""))
        else
            label.Text = tostring(text or "")
        end
    end)
end

function GAG2AutoShovelSetStatus(text)

    GAG2_AUTO_SHOVEL_STATE.LastStatus =
        tostring(text or "Idle.")

    GAG2AutoShovelScheduleRefresh()
end

function GAG2AutoShovelGetOwnPlantsFolder()

    if type(GAG2ResolveOwnFarmPlot) ~= "function" then
        return nil, nil, "GAG2ResolveOwnFarmPlot missing"
    end

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then
        return nil, nil, tostring(plotReason)
    end

    local plantsFolder =
        ownPlot:FindFirstChild("Plants")

    if not plantsFolder then
        return ownPlot, nil, "Plants folder missing"
    end

    return ownPlot, plantsFolder, tostring(plotReason or "own plot")
end

function GAG2AutoShovelGetPlantSeedName(plant)

    local seedName =
        GAG2AutoShovelClean(
            plant:GetAttribute("SeedName")
        )

    if seedName ~= "" then
        return seedName
    end

    local fruitsFolder =
        plant:FindFirstChild("Fruits")

    if fruitsFolder then

        for _, fruit in ipairs(fruitsFolder:GetChildren()) do

            seedName =
                GAG2AutoShovelClean(
                    fruit:GetAttribute("CorePartName")
                )

            if seedName ~= "" then
                return seedName
            end
        end
    end

    return "Unknown"
end

GAG2_AUTO_SHOVEL_MUTATION_VALUES_CACHE =
    GAG2_AUTO_SHOVEL_MUTATION_VALUES_CACHE or nil

GAG2_AUTO_SHOVEL_MUTATION_CANONICAL_CACHE =
    GAG2_AUTO_SHOVEL_MUTATION_CANONICAL_CACHE or nil

function GAG2AutoShovelGetMutationValues()

    if type(GAG2_AUTO_SHOVEL_MUTATION_VALUES_CACHE) == "table" then

        return table.clone(
            GAG2_AUTO_SHOVEL_MUTATION_VALUES_CACHE
        )
    end

    local values = {}
    local seen = {}

    local function remember(value)

        local mutation =
            GAG2AutoShovelClean(value)

        if mutation == "" then
            return
        end

        local key = mutation:lower()

        if seen[key] then
            return
        end

        seen[key] = true
        table.insert(values, mutation)
    end

    if type(GAG2ACFGetMutationDropdownValues) == "function" then

        local ok, result =
            pcall(
                GAG2ACFGetMutationDropdownValues
            )

        if ok == true
        and type(result) == "table" then

            for _, mutation in ipairs(result) do
                remember(mutation)
            end
        end
    end

    for _, mutation in ipairs({
        "None",
        "Gold",
        "Rainbow",
        "Bloodlit",
        "Starstruck",
        "Electric",
        "Frozen",
        "Chained",
        "Solarflare",
        "Pizza",
    }) do
        remember(mutation)
    end

    table.sort(values, function(a, b)

        if a == "None" then
            return true
        end

        if b == "None" then
            return false
        end

        return a:lower() < b:lower()
    end)

    GAG2_AUTO_SHOVEL_MUTATION_VALUES_CACHE =
        table.clone(values)

    GAG2_AUTO_SHOVEL_MUTATION_CANONICAL_CACHE =
        {}

    for _, mutation in ipairs(values) do

        GAG2_AUTO_SHOVEL_MUTATION_CANONICAL_CACHE[mutation:lower()] =
            mutation
    end

    return table.clone(values)
end

function GAG2AutoShovelCanonicalMutation(value, allowUnknown)

    local cleaned =
        GAG2AutoShovelClean(value)

    if cleaned == "" then
        return "None"
    end

    if type(GAG2_AUTO_SHOVEL_MUTATION_CANONICAL_CACHE) ~= "table" then
        GAG2AutoShovelGetMutationValues()
    end

    local canonical =
        GAG2_AUTO_SHOVEL_MUTATION_CANONICAL_CACHE[cleaned:lower()]

    if canonical then
        return canonical
    end

    if allowUnknown == true then
        return cleaned
    end

    return nil
end

function GAG2AutoShovelNormalizeSelection(value)

    local selected = {}

    if type(value) ~= "table" then
        return selected
    end

    for key, child in pairs(value) do

        local mutation = nil
        local enabled = false

        if type(key) == "number" then

            mutation = child
            enabled = child ~= nil

        else

            mutation = key
            enabled = child == true
                or child == 1
                or tostring(child):lower() == "true"
        end

        mutation =
            GAG2AutoShovelCanonicalMutation(
                mutation,
                true
            )

        if enabled == true
        and mutation ~= "" then

            selected[mutation] = true
        end
    end

    return selected
end

function GAG2AutoShovelSetProtectedMutations(value)

    GAG2_AUTO_SHOVEL_STATE.ProtectedMutations =
        GAG2AutoShovelNormalizeSelection(
            value
        )

    MarkConfigDirty()
    GAG2AutoShovelScheduleRefresh()
end

function GAG2AutoShovelSortedSelectionText(selection, emptyText)

    local names = {}

    for name, enabled in pairs(selection or {}) do

        if enabled == true then
            table.insert(names, tostring(name))
        end
    end

    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)

    if #names == 0 then
        return tostring(emptyText or "None")
    end

    return table.concat(names, ", ")
end

function GAG2AutoShovelGetPlantMutationSet(plant)

    local mutations = {}

    if typeof(plant) ~= "Instance" then
        mutations.None = true
        return mutations
    end

    local function remember(value, allowUnknown)

        local cleaned =
            GAG2AutoShovelClean(value)

        if cleaned == "" then
            return
        end

        local canonical =
            GAG2AutoShovelCanonicalMutation(
                cleaned,
                allowUnknown == true
            )

        if canonical
        and canonical ~= ""
        and canonical ~= "None" then

            mutations[canonical] = true
        end
    end

    remember(
        plant:GetAttribute("Mutation"),
        true
    )

    pcall(function()

        for _, tag in ipairs(
            GAG2_AUTO_SHOVEL_COLLECTION_SERVICE:GetTags(plant)
        ) do

            remember(tag, false)
        end
    end)

    local fruitsFolder =
        plant:FindFirstChild("Fruits")

    for _, descendant in ipairs(plant:GetDescendants()) do

        if fruitsFolder
        and descendant:IsDescendantOf(fruitsFolder) then
            continue
        end

        remember(
            descendant:GetAttribute("Mutation"),
            true
        )

        local descendantName =
            GAG2AutoShovelClean(descendant.Name)

        local vfxMutation =
            descendantName:match("^(.-)[Vv][Ff][Xx]$")

        if vfxMutation then
            remember(vfxMutation, false)
        end

        pcall(function()

            for _, tag in ipairs(
                GAG2_AUTO_SHOVEL_COLLECTION_SERVICE:GetTags(descendant)
            ) do

                remember(tag, false)
            end
        end)
    end

    if next(mutations) == nil then
        mutations.None = true
    end

    return mutations
end

function GAG2AutoShovelClassifyPlant(plant, _deepScan)

    return GAG2AutoShovelGetPlantMutationSet(
        plant
    )
end

function GAG2AutoShovelIsProtected(plant, _deepScan)

    local mutations =
        GAG2AutoShovelGetPlantMutationSet(
            plant
        )

    local protectedMutations =
        GAG2_AUTO_SHOVEL_STATE.ProtectedMutations
        or {}

    for mutation in pairs(mutations) do

        if protectedMutations[mutation] == true then
            return true, mutations, mutation
        end
    end

    return false, mutations, nil
end

function GAG2AutoShovelScanPlants()

    local state =
        GAG2_AUTO_SHOVEL_STATE

    local ownPlot, plantsFolder, reason =
        GAG2AutoShovelGetOwnPlantsFolder()

    state.OwnPlot = ownPlot
    state.PlantsFolder = plantsFolder

    local summary = {}
    local totalPlants = 0

    if plantsFolder then

        for _, plant in ipairs(plantsFolder:GetChildren()) do

            if plant:IsA("Model") then

                local seedName =
                    GAG2AutoShovelGetPlantSeedName(
                        plant
                    )

                local protected, mutations =
                    GAG2AutoShovelIsProtected(
                        plant,
                        false
                    )

                local row = summary[seedName]

                if not row then

                    row = {
                        Name = seedName,
                        Count = 0,
                        Eligible = 0,
                        Protected = 0,
                        MutationCounts = {},
                        Models = {},
                    }

                    summary[seedName] = row
                end

                totalPlants =
                    totalPlants + 1

                row.Count =
                    row.Count + 1

                if protected == true then

                    row.Protected =
                        row.Protected + 1

                else

                    row.Eligible =
                        row.Eligible + 1
                end

                for mutation in pairs(mutations) do

                    row.MutationCounts[mutation] =
                        (tonumber(row.MutationCounts[mutation]) or 0)
                        + 1
                end

                table.insert(
                    row.Models,
                    plant
                )
            end
        end
    end

    local plantTypes = 0

    for _, row in pairs(summary) do

        plantTypes = plantTypes + 1

        table.sort(row.Models, function(a, b)
            return tostring(a.Name) < tostring(b.Name)
        end)
    end

    state.Summary = summary
    state.TotalPlants = totalPlants
    state.PlantTypes = plantTypes

    return summary, ownPlot, plantsFolder, reason
end

function GAG2AutoShovelFindQueueIndexByPlant(plantName)

    for index, entry in ipairs(GAG2_AUTO_SHOVEL_STATE.Queue) do

        if entry.Plant == plantName then
            return index
        end
    end

    return nil
end

function GAG2AutoShovelBuildPlantChoices()

    local state = GAG2_AUTO_SHOVEL_STATE
    local rows = {}
    local values = {}
    local choiceMap = {}

    for _, row in pairs(state.Summary) do
        table.insert(rows, row)
    end

    table.sort(rows, function(a, b)

        if a.Count ~= b.Count then
            return a.Count > b.Count
        end

        return tostring(a.Name):lower() < tostring(b.Name):lower()
    end)

    for _, row in ipairs(rows) do

        local display =
            row.Name
            .. " x"
            .. tostring(row.Count)
            .. " | "
            .. tostring(row.Eligible)
            .. " shovelable"

        table.insert(values, display)
        choiceMap[display] = row.Name
    end

    if #values == 0 then
        values = {"No planted plants"}
    end

    state.PlantChoiceMap = choiceMap

    if state.SelectedPlant == ""
    or not state.Summary[state.SelectedPlant] then
        state.SelectedPlant = rows[1] and rows[1].Name or ""
    end

    return values
end

function GAG2AutoShovelBuildQueueChoices()

    local state = GAG2_AUTO_SHOVEL_STATE
    local values = {}
    local choiceMap = {}

    for index, entry in ipairs(state.Queue) do

        local row = state.Summary[entry.Plant]
        local eligible = row and row.Eligible or 0
        local amountText = entry.Limit <= 0 and "All" or tostring(entry.Limit)

        local planted =
            row and row.Count or 0

        local display =
            tostring(index)
            .. ". "
            .. entry.Plant
            .. " x"
            .. tostring(planted)
            .. " — "
            .. amountText
            .. " / "
            .. tostring(eligible)
            .. " shovelable"

        table.insert(values, display)
        choiceMap[display] = index
    end

    if #values == 0 then

        values = {"Queue empty"}
        state.SelectedQueueIndex = 0

    else

        state.SelectedQueueIndex =
            math.clamp(
                tonumber(state.SelectedQueueIndex) or 1,
                1,
                #state.Queue
            )
    end

    state.QueueChoiceMap = choiceMap

    return values
end

function GAG2AutoShovelBuildStatusText()

    local state = GAG2_AUTO_SHOVEL_STATE
    local row = state.Summary[state.SelectedPlant]

    local planted = row and row.Count or 0
    local eligible = row and row.Eligible or 0
    local protected = row and row.Protected or 0

    local mutationRows = {}

    if row
    and type(row.MutationCounts) == "table" then

        for mutation, count in pairs(row.MutationCounts) do

            table.insert(
                mutationRows,
                tostring(mutation)
                    .. " "
                    .. tostring(count)
            )
        end
    end

    table.sort(mutationRows, function(a, b)
        return a:lower() < b:lower()
    end)

    local mutationText =
        #mutationRows > 0
        and table.concat(mutationRows, " | ")
        or "None"

    local queuedText = "Not queued"
    local expectedDelete = 0
    local queueIndex =
        GAG2AutoShovelFindQueueIndexByPlant(state.SelectedPlant)

    if queueIndex then

        local entry = state.Queue[queueIndex]

        expectedDelete =
            entry.Limit <= 0
            and eligible
            or math.min(entry.Limit, eligible)

        queuedText =
            entry.Limit <= 0
            and "All"
            or tostring(entry.Limit)
    end

    return
        '<font color="rgb(196,181,253)"><b>Planted Plants / Auto Shovel</b></font>'
        .. "\nPlot: "
        .. (state.OwnPlot and state.OwnPlot.Name or "not resolved")
        .. " | Total: "
        .. tostring(state.TotalPlants)
        .. " | Types: "
        .. tostring(state.PlantTypes)
        .. "\nSelected: "
        .. (state.SelectedPlant ~= "" and state.SelectedPlant or "none")
        .. "\nPlanted: "
        .. tostring(planted)
        .. " | Shovelable: "
        .. tostring(eligible)
        .. " | Protected: "
        .. tostring(protected)
        .. " | Queued: "
        .. queuedText
        .. "\nRoot mutations: "
        .. mutationText
        .. "\nProtecting root mutations: "
        .. GAG2AutoShovelSortedSelectionText(
            state.ProtectedMutations,
            "Nothing"
        )
        .. "\nFruit mutations are ignored by Auto Shovel Plants."
        .. "\nExpected Remaining: "
        .. tostring(math.max(planted - expectedDelete, 0))
        .. "\nState: "
        .. (state.Enabled and "ON" or "OFF")
        .. " | Running: "
        .. tostring(state.Running)
        .. " | Queue: "
        .. tostring(state.CurrentQueueIndex)
        .. "/"
        .. tostring(state.CurrentQueueTotal)
        .. "\nCurrent: "
        .. (state.CurrentPlant ~= "" and state.CurrentPlant or "none")
        .. " | Delay: "
        .. string.format("%.2fs", GAG2AutoShovelGetEffectiveDelay())
        .. "\nRemoved: "
        .. tostring(state.RemovedThisRun)
        .. " | Failed: "
        .. tostring(state.FailedThisRun)
        .. " | Protected skips: "
        .. tostring(state.ProtectedSkipped)
        .. "\nLast: "
        .. tostring(state.LastStatus)
end

function GAG2AutoShovelRefreshUI()

    local state = GAG2_AUTO_SHOVEL_STATE

    if state.UpdatingUI then
        return
    end

    state.UpdatingUI = true

    local ok, err = pcall(function()

        GAG2AutoShovelScanPlants()

        local plantValues =
            GAG2AutoShovelBuildPlantChoices()

        GAG2AutoShovelSetDropdownValues(
            GAG2_AUTO_SHOVEL_CONTROLS.Plant,
            plantValues
        )

        for display, plantName in pairs(state.PlantChoiceMap) do

            if plantName == state.SelectedPlant then

                GAG2AutoShovelSetDropdownValue(
                    GAG2_AUTO_SHOVEL_CONTROLS.Plant,
                    display
                )

                break
            end
        end

        local queueValues =
            GAG2AutoShovelBuildQueueChoices()

        GAG2AutoShovelSetDropdownValues(
            GAG2_AUTO_SHOVEL_CONTROLS.Queue,
            queueValues
        )

        for display, queueIndex in pairs(state.QueueChoiceMap) do

            if queueIndex == state.SelectedQueueIndex then

                GAG2AutoShovelSetDropdownValue(
                    GAG2_AUTO_SHOVEL_CONTROLS.Queue,
                    display
                )

                break
            end
        end

        GAG2AutoShovelSetStatusLabel(
            GAG2AutoShovelBuildStatusText()
        )
    end)

    state.UpdatingUI = false

    if not ok then
        state.LastStatus = "UI refresh failed: " .. tostring(err)
    end
end

function GAG2AutoShovelScheduleRefresh()

    local state = GAG2_AUTO_SHOVEL_STATE

    if state.RefreshScheduled then
        return
    end

    state.RefreshScheduled = true

    task.delay(0.15, function()

        if GAG2_AUTO_SHOVEL_STATE ~= state then
            return
        end

        state.RefreshScheduled = false
        GAG2AutoShovelRefreshUI()
    end)
end

function GAG2AutoShovelEncodeQueue()

    local queue = {}

    for _, entry in ipairs(GAG2_AUTO_SHOVEL_STATE.Queue) do

        table.insert(queue, {
            Plant = tostring(entry.Plant),
            Limit = GAG2AutoShovelClampLimit(entry.Limit),
        })
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(queue)
    end)

    return ok and encoded or "[]"
end

function GAG2AutoShovelLoadQueueFromText(text)

    local decoded = nil
    local ok = pcall(function()
        decoded = HttpService:JSONDecode(tostring(text or "[]"))
    end)

    if not ok
    or type(decoded) ~= "table" then
        return false
    end

    local queue = {}
    local seen = {}

    for _, entry in ipairs(decoded) do

        if type(entry) == "table" then

            local plantName =
                GAG2AutoShovelClean(entry.Plant)

            if plantName ~= ""
            and not seen[plantName] then

                seen[plantName] = true

                table.insert(queue, {
                    Plant = plantName,
                    Limit = GAG2AutoShovelClampLimit(entry.Limit),
                })
            end
        end
    end

    local state = GAG2_AUTO_SHOVEL_STATE

    state.Queue = queue
    state.SelectedQueueIndex = #queue > 0 and 1 or 0

    GAG2AutoShovelScheduleRefresh()

    return true
end

function GAG2AutoShovelSaveQueue()

    local state = GAG2_AUTO_SHOVEL_STATE
    local control = GAG2_AUTO_SHOVEL_CONTROLS.QueueData

    if control
    and type(control.SetValue) == "function" then

        state.SavingQueueText = true

        pcall(function()
            control:SetValue(GAG2AutoShovelEncodeQueue())
        end)

        state.SavingQueueText = false
    end

    MarkConfigDirty()
    GAG2AutoShovelScheduleRefresh()
end

function GAG2AutoShovelAddOrUpdateQueue(plantName, limit)

    plantName = GAG2AutoShovelClean(plantName)

    if plantName == ""
    or plantName == "No planted plants" then
        return false
    end

    limit = GAG2AutoShovelClampLimit(limit)

    local state = GAG2_AUTO_SHOVEL_STATE
    local index = GAG2AutoShovelFindQueueIndexByPlant(plantName)

    if index then

        state.Queue[index].Limit = limit
        state.SelectedQueueIndex = index

    else

        table.insert(state.Queue, {
            Plant = plantName,
            Limit = limit,
        })

        state.SelectedQueueIndex = #state.Queue
    end

    GAG2AutoShovelSaveQueue()

    return true
end

function GAG2AutoShovelRemoveSelectedQueue()

    local state = GAG2_AUTO_SHOVEL_STATE
    local index = tonumber(state.SelectedQueueIndex) or 0

    if index < 1
    or index > #state.Queue then
        return false
    end

    table.remove(state.Queue, index)

    state.SelectedQueueIndex =
        #state.Queue > 0
        and math.clamp(index, 1, #state.Queue)
        or 0

    GAG2AutoShovelSaveQueue()

    return true
end

function GAG2AutoShovelMoveSelectedQueue(direction)

    local state = GAG2_AUTO_SHOVEL_STATE
    local index = tonumber(state.SelectedQueueIndex) or 0
    local targetIndex = index + (tonumber(direction) or 0)

    if index < 1
    or index > #state.Queue
    or targetIndex < 1
    or targetIndex > #state.Queue then
        return false
    end

    state.Queue[index], state.Queue[targetIndex] =
        state.Queue[targetIndex], state.Queue[index]

    state.SelectedQueueIndex = targetIndex

    GAG2AutoShovelSaveQueue()

    return true
end

function GAG2AutoShovelClearQueue()

    GAG2_AUTO_SHOVEL_STATE.Queue = {}
    GAG2_AUTO_SHOVEL_STATE.SelectedQueueIndex = 0

    GAG2AutoShovelSaveQueue()
end

function GAG2AutoShovelResolvePacket()

    local state = GAG2_AUTO_SHOVEL_STATE

    if type(state.UseShovelPacket) == "table"
    and type(state.UseShovelPacket.Fire) == "function" then
        return state.UseShovelPacket, state.PacketSource
    end

    local packets =
        type(SniperFindPacketTable) == "function"
        and SniperFindPacketTable()
        or nil

    if type(packets) ~= "table" then
        return nil, "packet table unavailable"
    end

    local safeRawGet =
        type(SniperSafeRawGet) == "function"
        and SniperSafeRawGet
        or function(container, key)
            return type(container) == "table" and rawget(container, key) or nil
        end

    local shovelPackets = safeRawGet(packets, "Shovel")
    local packet =
        type(shovelPackets) == "table"
        and safeRawGet(shovelPackets, "UseShovel")
        or nil

    if type(packet) ~= "table"
    or type(packet.Fire) ~= "function" then
        return nil, "Shovel.UseShovel packet unavailable"
    end

    state.UseShovelPacket = packet
    state.PacketSource = "packet table Shovel.UseShovel"

    return packet, state.PacketSource
end

function GAG2AutoShovelFindRealShovel()

    local character = LOCAL_PLAYER.Character
    local backpack = LOCAL_PLAYER:FindFirstChildOfClass("Backpack")

    local function findIn(container)

        if not container then
            return nil
        end

        for _, child in ipairs(container:GetChildren()) do

            if child:IsA("Tool")
            and child:GetAttribute("Shovel") ~= nil then
                return child, tostring(child:GetAttribute("Shovel"))
            end
        end

        return nil
    end

    local tool, shovelValue = findIn(character)

    if tool then
        return tool, shovelValue
    end

    tool, shovelValue = findIn(backpack)

    if not tool then
        return nil, nil, "real Shovel tool missing"
    end

    local humanoid =
        character and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return nil, nil, "Humanoid missing"
    end

    pcall(humanoid.EquipTool, humanoid, tool)
    task.wait(0.15)

    if tool.Parent ~= character then
        return nil, nil, "Shovel could not equip"
    end

    return tool, shovelValue
end

function GAG2AutoShovelWorkerActive(generation)

    local state = GAG2_AUTO_SHOVEL_STATE

    return state.Enabled
        and state.WorkerGeneration == generation
end

function GAG2AutoShovelWaitUntil(targetTime, generation)

    while GAG2AutoShovelWorkerActive(generation) do

        local remaining = targetTime - os.clock()

        if remaining <= 0 then
            return true
        end

        task.wait(math.min(remaining, 0.05))
    end

    return false
end

function GAG2AutoShovelTryDeletePlant(plant, plantsFolder, generation)

    local state = GAG2_AUTO_SHOVEL_STATE

    if typeof(plant) ~= "Instance"
    or typeof(plantsFolder) ~= "Instance" then
        return false, "target missing", "failed"
    end

    if plant.Parent ~= plantsFolder then
        return true, "already removed", "removed"
    end

    local isProtected, _, protectedMutation =
        GAG2AutoShovelIsProtected(
            plant,
            true
        )

    if isProtected then

        return false,
            "protected "
                .. tostring(protectedMutation or "selected")
                .. " plant mutation",
            "protected"
    end

    local packet, packetReason = GAG2AutoShovelResolvePacket()

    if not packet then
        return false, packetReason, "runtime"
    end

    local shovelTool, shovelValue, shovelReason =
        GAG2AutoShovelFindRealShovel()

    if not shovelTool
    or GAG2AutoShovelClean(shovelValue) == "" then
        return false, shovelReason or "Shovel attribute missing", "runtime"
    end

    local effectiveDelay =
        GAG2AutoShovelGetEffectiveDelay()

    local sharedLastSentAt =
        tonumber(
            GAG2_AUTO_SHOVEL_SHARED_LAST_SENT_AT
        )
        or 0

    local fireAt =
        math.max(
            os.clock(),
            state.LastSentAt + effectiveDelay,
            sharedLastSentAt + effectiveDelay
        )

    if not GAG2AutoShovelWaitUntil(fireAt, generation) then
        return false, "stopped", "stopped"
    end

    if plant.Parent ~= plantsFolder then
        return true, "removed before send", "removed"
    end

    isProtected, _, protectedMutation =
        GAG2AutoShovelIsProtected(
            plant,
            true
        )

    if isProtected then

        return false,
            "became protected before send: "
                .. tostring(protectedMutation or "selected mutation"),
            "protected"
    end

    local plantName = tostring(plant.Name)
    local removed = false

    local connection = plantsFolder.ChildRemoved:Connect(function(child)

        if child == plant
        or tostring(child.Name) == plantName then
            removed = true
        end
    end)

    local okFire, fireError = pcall(function()

        packet:Fire(
            plantName,
            "",
            tostring(shovelValue),
            shovelTool
        )
    end)

    if not okFire then

        okFire, fireError = pcall(function()

            packet.Fire(
                packet,
                plantName,
                "",
                tostring(shovelValue),
                shovelTool
            )
        end)
    end

    if not okFire then

        connection:Disconnect()
        return false, tostring(fireError), "failed"
    end

    state.LastSentAt =
        os.clock()

    GAG2_AUTO_SHOVEL_SHARED_LAST_SENT_AT =
        state.LastSentAt

    local deadline =
        os.clock() + 2.5

    while GAG2AutoShovelWorkerActive(generation)
    and os.clock() < deadline do

        if removed
        or plant.Parent ~= plantsFolder
        or plantsFolder:FindFirstChild(plantName) ~= plant then

            removed = true
            break
        end

        task.wait(0.05)
    end

    connection:Disconnect()

    if removed then
        return true, "plant model removed", "removed"
    end

    return false, "confirmation timeout", "failed"
end

function GAG2AutoShovelBuildCandidateNames(plantName)

    GAG2AutoShovelScanPlants()

    local row =
        GAG2_AUTO_SHOVEL_STATE.Summary[plantName]

    local names = {}

    if not row then
        return names
    end

    for _, plant in ipairs(row.Models) do

        if not GAG2AutoShovelIsProtected(plant, false) then
            table.insert(names, tostring(plant.Name))
        end
    end

    table.sort(names)

    return names
end

function GAG2AutoShovelSetToggleOff()

    local toggle =
        Toggles and Toggles.HolyGAG2AutoShovelPlants

    if toggle
    and type(toggle.SetValue) == "function" then
        pcall(toggle.SetValue, toggle, false)
    end
end

function GAG2AutoShovelStartWorker()

    local state = GAG2_AUTO_SHOVEL_STATE

    if state.Running then
        return
    end

    if #state.Queue == 0 then

        state.Enabled = false
        state.LastStatus = "Queue is empty."
        GAG2AutoShovelSetToggleOff()

        Notify(
            "Auto Shovel",
            "Add at least one crop to the queue.",
            4
        )

        return
    end

    state.Running = true
    state.RemovedThisRun = 0
    state.FailedThisRun = 0
    state.ProtectedSkipped = 0
    state.WorkerGeneration = state.WorkerGeneration + 1

    local generation = state.WorkerGeneration
    local runQueue = {}

    for _, entry in ipairs(state.Queue) do

        table.insert(runQueue, {
            Plant = entry.Plant,
            Limit = entry.Limit,
        })
    end

    state.CurrentQueueIndex = 0
    state.CurrentQueueTotal = #runQueue

    task.spawn(function()

        for queueIndex, entry in ipairs(runQueue) do

            if not GAG2AutoShovelWorkerActive(generation) then
                break
            end

            state.CurrentQueueIndex = queueIndex
            state.CurrentPlant = entry.Plant
            state.LastStatus = "Snapshotting " .. entry.Plant .. "."
            GAG2AutoShovelScheduleRefresh()

            local candidateNames =
                GAG2AutoShovelBuildCandidateNames(entry.Plant)

            local removedForEntry = 0

            for _, plantName in ipairs(candidateNames) do

                if not GAG2AutoShovelWorkerActive(generation) then
                    break
                end

                if entry.Limit > 0
                and removedForEntry >= entry.Limit then
                    break
                end

                local ownPlot, plantsFolder =
                    GAG2AutoShovelGetOwnPlantsFolder()

                while not plantsFolder
                and GAG2AutoShovelWorkerActive(generation) do

                    state.LastStatus = "Waiting for own Plants folder."
                    GAG2AutoShovelScheduleRefresh()
                    task.wait(1)

                    ownPlot, plantsFolder =
                        GAG2AutoShovelGetOwnPlantsFolder()
                end

                if not GAG2AutoShovelWorkerActive(generation) then
                    break
                end

                state.OwnPlot = ownPlot
                state.PlantsFolder = plantsFolder

                local plant = plantsFolder:FindFirstChild(plantName)

                if not plant then
                    continue
                end

                local attempts = 0
                local finishedTarget = false

                while attempts < 3
                and not finishedTarget
                and GAG2AutoShovelWorkerActive(generation) do

                    state.LastStatus =
                        "Shoveling "
                        .. entry.Plant
                        .. " | "
                        .. tostring(removedForEntry + 1)
                        .. (entry.Limit > 0 and "/" .. tostring(entry.Limit) or "/All")

                    GAG2AutoShovelScheduleRefresh()

                    local success, reason, resultType =
                        GAG2AutoShovelTryDeletePlant(
                            plant,
                            plantsFolder,
                            generation
                        )

                    if success then

                        removedForEntry = removedForEntry + 1
                        state.RemovedThisRun = state.RemovedThisRun + 1
                        state.LastStatus = entry.Plant .. " removed and confirmed."
                        finishedTarget = true

                    elseif resultType == "protected" then

                        state.ProtectedSkipped = state.ProtectedSkipped + 1
                        state.LastStatus = entry.Plant .. " skipped: " .. tostring(reason)
                        finishedTarget = true

                    elseif resultType == "runtime" then

                        state.LastStatus = "Waiting: " .. tostring(reason)
                        GAG2AutoShovelScheduleRefresh()
                        task.wait(1)

                    elseif resultType == "stopped" then

                        finishedTarget = true

                    else

                        attempts = attempts + 1

                        if attempts >= 3 then

                            state.FailedThisRun = state.FailedThisRun + 1
                            state.LastStatus =
                                entry.Plant
                                .. " failed after 3 tries: "
                                .. tostring(reason)

                            finishedTarget = true

                        else

                            state.LastStatus =
                                entry.Plant
                                .. " retry "
                                .. tostring(attempts + 1)
                                .. "/3: "
                                .. tostring(reason)

                            task.wait(0.10)
                        end
                    end
                end

                GAG2AutoShovelScheduleRefresh()
            end
        end

        local completed =
            GAG2AutoShovelWorkerActive(generation)

        state.Running = false
        state.CurrentPlant = ""

        if completed then

            state.Enabled = false
            state.LastStatus = "Queue complete."
            GAG2AutoShovelSetToggleOff()

        elseif not state.Enabled then

            state.LastStatus = "Stopped."
        end

        GAG2AutoShovelScheduleRefresh()
    end)
end

function GAG2AutoShovelSetEnabled(value)

    local state = GAG2_AUTO_SHOVEL_STATE
    local enabled = value == true

    if enabled == state.Enabled
    and (not enabled or state.Running) then
        return
    end

    if enabled then

        if GAG2_AUTO_SHOVEL_FRUIT_STATE
        and GAG2_AUTO_SHOVEL_FRUIT_STATE.Enabled == true
        and type(GAG2AutoShovelFruitSetEnabled) == "function" then

            GAG2AutoShovelFruitSetEnabled(
                false
            )

            if type(GAG2AutoShovelFruitSetToggleOff) == "function" then
                GAG2AutoShovelFruitSetToggleOff()
            end
        end
    end

    state.Enabled = enabled

    if enabled then

        if #state.Queue == 0 then

            state.Enabled = false
            state.LastStatus = "Queue is empty."
            GAG2AutoShovelSetToggleOff()

            Notify(
                "Auto Shovel",
                "Add at least one crop to the queue.",
                4
            )

        elseif not ConfigState.Loading then

            state.LastStatus = "Starting queue."
            GAG2AutoShovelStartWorker()
        end

    else

        state.WorkerGeneration = state.WorkerGeneration + 1
        state.LastStatus = "Disabled."
    end

    MarkConfigDirty()
    GAG2AutoShovelScheduleRefresh()
end

function GAG2AutoShovelStartMonitor()

    local state = GAG2_AUTO_SHOVEL_STATE

    state.MonitorGeneration = state.MonitorGeneration + 1

    local generation = state.MonitorGeneration

    task.spawn(function()

        while GAG2_AUTO_SHOVEL_STATE == state
        and state.MonitorGeneration == generation do

            GAG2AutoShovelScheduleRefresh()
            task.wait(3)
        end
    end)
end

--==================================================
-- [4.575] AUTO SHOVEL FRUITS
-- Own-plot-only continuous fruit deletion.
-- Uses fruit-only mutation protection.
--==================================================

if type(GAG2_AUTO_SHOVEL_FRUIT_STATE) == "table" then

    GAG2_AUTO_SHOVEL_FRUIT_STATE.Enabled = false
    GAG2_AUTO_SHOVEL_FRUIT_STATE.WorkerGeneration =
        (tonumber(GAG2_AUTO_SHOVEL_FRUIT_STATE.WorkerGeneration) or 0) + 1

    GAG2_AUTO_SHOVEL_FRUIT_STATE.MonitorGeneration =
        (tonumber(GAG2_AUTO_SHOVEL_FRUIT_STATE.MonitorGeneration) or 0) + 1
end

GAG2_AUTO_SHOVEL_FRUIT_STATE = {
    Enabled = false,
    Running = false,
    WorkerGeneration = 0,
    MonitorGeneration = 0,

    SelectedFruits = {},
    ProtectedMutations = {
        Gold = true,
        Rainbow = true,
    },

    Delay = 0.70,
    LastSentAt = 0,

    OwnPlot = nil,
    PlantsFolder = nil,
    Summary = {},
    TotalFruits = 0,
    EligibleFruits = 0,
    ProtectedFruits = 0,

    RemovedThisRun = 0,
    FailedThisRun = 0,
    ProtectedSkipped = 0,
    CurrentFruit = "",
    LastStatus = "Idle.",

    UpdatingUI = false,
    RefreshScheduled = false,
    FailureCooldowns = {},
}

GAG2_AUTO_SHOVEL_FRUIT_CONTROLS =
    GAG2_AUTO_SHOVEL_FRUIT_CONTROLS or {}

GAG2_AUTO_SHOVEL_SHARED_LAST_SENT_AT =
    tonumber(GAG2_AUTO_SHOVEL_SHARED_LAST_SENT_AT)
    or 0

function GAG2AutoShovelFruitSetDelay(value)

    local number = tonumber(value) or 0.70

    if number ~= number
    or number == math.huge
    or number == -math.huge then
        number = 0.70
    end

    GAG2_AUTO_SHOVEL_FRUIT_STATE.Delay =
        math.clamp(number, 0, 60)

    MarkConfigDirty()
    GAG2AutoShovelFruitScheduleRefresh()
end

function GAG2AutoShovelFruitGetEffectiveDelay()

    return math.max(
        tonumber(GAG2_AUTO_SHOVEL_FRUIT_STATE.Delay) or 0.70,
        0.65
    )
end

function GAG2AutoShovelFruitNormalizeSelection(value)

    local selected = {}

    local function remember(name)

        name =
            GAG2AutoShovelClean(
                name
            )

        if name == ""
        or name == "No fruits found" then
            return
        end

        selected[name] =
            true
    end

    if type(value) == "table" then

        for key, child in pairs(value) do

            if type(key) == "number" then

                remember(
                    child
                )

            elseif child == true
            or child == 1
            or tostring(child):lower() == "true" then

                remember(
                    key
                )
            end
        end

    elseif type(value) == "string" then

        remember(
            value
        )
    end

    return selected
end

function GAG2AutoShovelFruitSetSelectedFruits(value)

    GAG2_AUTO_SHOVEL_FRUIT_STATE.SelectedFruits =
        GAG2AutoShovelFruitNormalizeSelection(
            value
        )

    MarkConfigDirty()
    GAG2AutoShovelFruitScheduleRefresh()
end

function GAG2AutoShovelFruitSetProtectedMutations(value)

    GAG2_AUTO_SHOVEL_FRUIT_STATE.ProtectedMutations =
        GAG2AutoShovelNormalizeSelection(
            value
        )

    MarkConfigDirty()
    GAG2AutoShovelFruitScheduleRefresh()
end

function GAG2AutoShovelFruitReadName(fruit, plant)

    local name = ""

    if typeof(fruit) == "Instance" then

        name =
            GAG2AutoShovelClean(
                fruit:GetAttribute("CorePartName")
            )
    end

    if name == ""
    and typeof(plant) == "Instance" then

        name =
            GAG2AutoShovelGetPlantSeedName(
                plant
            )
    end

    if name == ""
    and typeof(fruit) == "Instance" then

        name =
            GAG2AutoShovelClean(
                fruit.Name
            )
    end

    return name ~= ""
        and name
        or "Unknown"
end

function GAG2AutoShovelFruitReadMutation(fruit)

    if typeof(fruit) ~= "Instance" then
        return "None"
    end

    local mutation =
        GAG2AutoShovelClean(
            fruit:GetAttribute("Mutation")
        )

    if mutation == "" then
        return "None"
    end

    return GAG2AutoShovelCanonicalMutation(
        mutation,
        true
    )
end

function GAG2AutoShovelFruitIsSelected(fruitName)

    local selected =
        GAG2_AUTO_SHOVEL_FRUIT_STATE.SelectedFruits
        or {}

    if next(selected) == nil then
        return true
    end

    return selected[fruitName] == true
end

function GAG2AutoShovelFruitIsProtected(fruit)

    local mutation =
        GAG2AutoShovelFruitReadMutation(
            fruit
        )

    local protected =
        GAG2_AUTO_SHOVEL_FRUIT_STATE.ProtectedMutations
        or {}

    return protected[mutation] == true,
        mutation
end

function GAG2AutoShovelFruitScan()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    local ownPlot, plantsFolder, reason =
        GAG2AutoShovelGetOwnPlantsFolder()

    state.OwnPlot =
        ownPlot

    state.PlantsFolder =
        plantsFolder

    local summary = {}
    local total = 0
    local eligible = 0
    local protectedCount = 0

    if plantsFolder then

        for _, plant in ipairs(
            plantsFolder:GetChildren()
        ) do

            if plant:IsA("Model") then

                local fruitsFolder =
                    plant:FindFirstChild(
                        "Fruits"
                    )

                if fruitsFolder then

                    for _, fruit in ipairs(
                        fruitsFolder:GetChildren()
                    ) do

                        if fruit:IsA("Model") then

                            local fruitName =
                                GAG2AutoShovelFruitReadName(
                                    fruit,
                                    plant
                                )

                            local isProtected, mutation =
                                GAG2AutoShovelFruitIsProtected(
                                    fruit
                                )

                            local isSelected =
                                GAG2AutoShovelFruitIsSelected(
                                    fruitName
                                )

                            local row =
                                summary[fruitName]

                            if not row then

                                row = {
                                    Name = fruitName,
                                    Count = 0,
                                    Eligible = 0,
                                    Protected = 0,
                                    MutationCounts = {},
                                    Items = {},
                                }

                                summary[fruitName] =
                                    row
                            end

                            total = total + 1
                            row.Count = row.Count + 1

                            row.MutationCounts[mutation] =
                                (tonumber(row.MutationCounts[mutation]) or 0)
                                + 1

                            if isProtected then

                                protectedCount = protectedCount + 1
                                row.Protected = row.Protected + 1

                            elseif isSelected then

                                eligible = eligible + 1
                                row.Eligible = row.Eligible + 1
                            end

                            table.insert(
                                row.Items,
                                {
                                    Plant = plant,
                                    FruitsFolder = fruitsFolder,
                                    Fruit = fruit,
                                    FruitName = fruitName,
                                    Mutation = mutation,
                                }
                            )
                        end
                    end
                end
            end
        end
    end

    state.Summary =
        summary

    state.TotalFruits =
        total

    state.EligibleFruits =
        eligible

    state.ProtectedFruits =
        protectedCount

    return summary,
        ownPlot,
        plantsFolder,
        reason
end

function GAG2AutoShovelFruitGetDropdownValues()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    local rows = {}

    for _, row in pairs(state.Summary) do

        table.insert(
            rows,
            row
        )
    end

    table.sort(rows, function(left, right)

        if left.Count ~= right.Count then

            return left.Count
                > right.Count
        end

        return tostring(left.Name):lower()
            < tostring(right.Name):lower()
    end)

    local values = {}
    local included = {}

    for _, row in ipairs(rows) do

        local fruitName =
            tostring(row.Name)

        table.insert(
            values,
            fruitName
        )

        included[fruitName] =
            true
    end

    local missingSelected = {}

    for fruitName, enabled in pairs(
        state.SelectedFruits
        or {}
    ) do

        if enabled == true
        and included[fruitName] ~= true then

            table.insert(
                missingSelected,
                tostring(fruitName)
            )
        end
    end

    table.sort(missingSelected, function(left, right)

        return left:lower()
            < right:lower()
    end)

    for _, fruitName in ipairs(missingSelected) do

        table.insert(
            values,
            fruitName
        )
    end

    if #values == 0 then

        values = {
            "No fruits found",
        }
    end

    return values
end

function GAG2AutoShovelFruitBuildStatusText()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    return
        '<font color="rgb(196,181,253)"><b>Auto Shovel Fruits</b></font>'
        .. "\nPlot: "
        .. (
            state.OwnPlot
            and state.OwnPlot.Name
            or "not resolved"
        )
        .. "\nState: "
        .. (
            state.Enabled
            and "ON"
            or "OFF"
        )
        .. " | Running: "
        .. tostring(state.Running)
        .. " | Delay: "
        .. string.format(
            "%.2fs",
            GAG2AutoShovelFruitGetEffectiveDelay()
        )
        .. "\nFruit Types: "
        .. GAG2AutoShovelSortedSelectionText(
            state.SelectedFruits,
            "All"
        )
        .. "\nProtecting Fruit Mutations: "
        .. GAG2AutoShovelSortedSelectionText(
            state.ProtectedMutations,
            "Nothing"
        )
        .. "\nTotal: "
        .. tostring(state.TotalFruits)
        .. " | Shovelable: "
        .. tostring(state.EligibleFruits)
        .. " | Protected: "
        .. tostring(state.ProtectedFruits)
        .. "\nRemoved: "
        .. tostring(state.RemovedThisRun)
        .. " | Failed: "
        .. tostring(state.FailedThisRun)
        .. " | Protected Skips: "
        .. tostring(state.ProtectedSkipped)
        .. "\nCurrent: "
        .. (
            state.CurrentFruit ~= ""
            and state.CurrentFruit
            or "none"
        )
        .. "\nLast: "
        .. tostring(state.LastStatus)
end

function GAG2AutoShovelFruitRefreshUI()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    if state.UpdatingUI == true then
        return
    end

    state.UpdatingUI =
        true

    local ok, err =
        pcall(function()

            GAG2AutoShovelFruitScan()

            GAG2AutoShovelSetDropdownValues(
                GAG2_AUTO_SHOVEL_FRUIT_CONTROLS.Fruits,
                GAG2AutoShovelFruitGetDropdownValues()
            )

            local statusLabel =
                GAG2_AUTO_SHOVEL_FRUIT_CONTROLS.StatusLabel

            if statusLabel
            and type(statusLabel.SetText) == "function" then

                statusLabel:SetText(
                    GAG2AutoShovelFruitBuildStatusText()
                )
            end
        end)

    state.UpdatingUI =
        false

    if ok ~= true then

        state.LastStatus =
            "UI refresh failed: "
            .. tostring(err)
    end
end

function GAG2AutoShovelFruitScheduleRefresh()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    if state.RefreshScheduled == true then
        return
    end

    state.RefreshScheduled =
        true

    task.delay(0.15, function()

        if GAG2_AUTO_SHOVEL_FRUIT_STATE ~= state then
            return
        end

        state.RefreshScheduled =
            false

        GAG2AutoShovelFruitRefreshUI()
    end)
end

function GAG2AutoShovelFruitWorkerActive(generation)

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    return state.Enabled == true
        and state.WorkerGeneration == generation
end

function GAG2AutoShovelFruitWaitUntil(targetTime, generation)

    while GAG2AutoShovelFruitWorkerActive(generation) do

        local remaining =
            targetTime - os.clock()

        if remaining <= 0 then
            return true
        end

        task.wait(
            math.min(
                remaining,
                0.05
            )
        )
    end

    return false
end

function GAG2AutoShovelFruitTryDelete(item, generation)

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    local plant =
        item
        and item.Plant

    local fruit =
        item
        and item.Fruit

    local fruitsFolder =
        item
        and item.FruitsFolder

    if typeof(plant) ~= "Instance"
    or typeof(fruit) ~= "Instance"
    or typeof(fruitsFolder) ~= "Instance" then

        return false,
            "target missing",
            "failed"
    end

    if fruit.Parent ~= fruitsFolder then

        return true,
            "already removed",
            "removed"
    end

    local isProtected, mutation =
        GAG2AutoShovelFruitIsProtected(
            fruit
        )

    if isProtected then

        return false,
            "protected "
                .. tostring(mutation)
                .. " fruit",
            "protected"
    end

    local packet, packetReason =
        GAG2AutoShovelResolvePacket()

    if not packet then

        return false,
            packetReason,
            "runtime"
    end

    local shovelTool, shovelValue, shovelReason =
        GAG2AutoShovelFindRealShovel()

    if not shovelTool
    or GAG2AutoShovelClean(shovelValue) == "" then

        return false,
            shovelReason
                or "Shovel attribute missing",
            "runtime"
    end

    local effectiveDelay =
        GAG2AutoShovelFruitGetEffectiveDelay()

    local sharedLastSentAt =
        tonumber(
            GAG2_AUTO_SHOVEL_SHARED_LAST_SENT_AT
        )
        or 0

    local fireAt =
        math.max(
            os.clock(),
            state.LastSentAt + effectiveDelay,
            sharedLastSentAt + effectiveDelay
        )

    if not GAG2AutoShovelFruitWaitUntil(
        fireAt,
        generation
    ) then

        return false,
            "stopped",
            "stopped"
    end

    if fruit.Parent ~= fruitsFolder then

        return true,
            "removed before send",
            "removed"
    end

    isProtected, mutation =
        GAG2AutoShovelFruitIsProtected(
            fruit
        )

    if isProtected then

        return false,
            "became protected before send: "
                .. tostring(mutation),
            "protected"
    end

    local plantId =
        tostring(plant.Name)

    local fruitId =
        tostring(fruit.Name)

    local removed =
        false

    local connection =
        fruitsFolder.ChildRemoved:Connect(function(child)

            if child == fruit
            or tostring(child.Name) == fruitId then

                removed =
                    true
            end
        end)

    local okFire, fireError =
        pcall(function()

            packet:Fire(
                plantId,
                fruitId,
                tostring(shovelValue),
                shovelTool
            )
        end)

    if okFire ~= true then

        okFire, fireError =
            pcall(function()

                packet.Fire(
                    packet,
                    plantId,
                    fruitId,
                    tostring(shovelValue),
                    shovelTool
                )
            end)
    end

    if okFire ~= true then

        connection:Disconnect()

        return false,
            tostring(fireError),
            "failed"
    end

    state.LastSentAt =
        os.clock()

    GAG2_AUTO_SHOVEL_SHARED_LAST_SENT_AT =
        state.LastSentAt

    local deadline =
        os.clock() + 2.5

    while GAG2AutoShovelFruitWorkerActive(generation)
    and os.clock() < deadline do

        if removed
        or fruit.Parent ~= fruitsFolder
        or fruitsFolder:FindFirstChild(fruitId) ~= fruit then

            removed =
                true

            break
        end

        task.wait(
            0.05
        )
    end

    connection:Disconnect()

    if removed then

        return true,
            "fruit model removed",
            "removed"
    end

    return false,
        "confirmation timeout",
        "failed"
end

function GAG2AutoShovelFruitBuildCandidates()

    GAG2AutoShovelFruitScan()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    local candidates = {}
    local now = os.clock()

    for fruitName, row in pairs(state.Summary) do

        if GAG2AutoShovelFruitIsSelected(
            fruitName
        ) then

            for _, item in ipairs(row.Items) do

                local isProtected =
                    GAG2AutoShovelFruitIsProtected(
                        item.Fruit
                    )

                local key =
                    tostring(item.Plant.Name)
                    .. "/"
                    .. tostring(item.Fruit.Name)

                local blockedUntil =
                    tonumber(
                        state.FailureCooldowns[key]
                    )
                    or 0

                if isProtected ~= true
                and now >= blockedUntil then

                    item.Key =
                        key

                    table.insert(
                        candidates,
                        item
                    )
                end
            end
        end
    end

    table.sort(candidates, function(left, right)

        local leftKey =
            tostring(left.Plant.Name)
            .. "/"
            .. tostring(left.Fruit.Name)

        local rightKey =
            tostring(right.Plant.Name)
            .. "/"
            .. tostring(right.Fruit.Name)

        return leftKey
            < rightKey
    end)

    return candidates
end

function GAG2AutoShovelFruitSetToggleOff()

    local toggle =
        Toggles
        and Toggles.HolyGAG2AutoShovelFruits

    if toggle
    and type(toggle.SetValue) == "function" then

        pcall(
            toggle.SetValue,
            toggle,
            false
        )
    end
end

function GAG2AutoShovelFruitStartWorker()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    state.RemovedThisRun =
        0

    state.FailedThisRun =
        0

    state.ProtectedSkipped =
        0

    state.WorkerGeneration = state.WorkerGeneration + 1

    local generation =
        state.WorkerGeneration

    task.spawn(function()

        while GAG2AutoShovelFruitWorkerActive(generation) do

            local candidates =
                GAG2AutoShovelFruitBuildCandidates()

            if #candidates == 0 then

                state.CurrentFruit =
                    ""

                state.LastStatus =
                    "Waiting for shovelable fruits."

                GAG2AutoShovelFruitScheduleRefresh()

                task.wait(
                    0.75
                )

            else

                for _, item in ipairs(candidates) do

                    if not GAG2AutoShovelFruitWorkerActive(generation) then
                        break
                    end

                    state.CurrentFruit =
                        tostring(item.FruitName)
                        .. " ["
                        .. tostring(item.Mutation)
                        .. "]"

                    state.LastStatus =
                        "Shoveling "
                        .. tostring(state.CurrentFruit)

                    GAG2AutoShovelFruitScheduleRefresh()

                    local success, reason, resultType =
                        GAG2AutoShovelFruitTryDelete(
                            item,
                            generation
                        )

                    if success then

                        state.RemovedThisRun = state.RemovedThisRun + 1

                        state.LastStatus =
                            tostring(item.FruitName)
                            .. " removed and confirmed."

                    elseif resultType == "protected" then

                        state.ProtectedSkipped = state.ProtectedSkipped + 1

                        state.LastStatus =
                            tostring(reason)

                    elseif resultType == "runtime" then

                        state.LastStatus =
                            "Waiting: "
                            .. tostring(reason)

                        GAG2AutoShovelFruitScheduleRefresh()

                        task.wait(
                            1
                        )

                    elseif resultType == "stopped" then

                        break

                    else

                        state.FailedThisRun = state.FailedThisRun + 1

                        state.LastStatus =
                            tostring(item.FruitName)
                            .. " failed: "
                            .. tostring(reason)

                        state.FailureCooldowns[item.Key] =
                            os.clock() + 3
                    end

                    GAG2AutoShovelFruitScheduleRefresh()
                end
            end
        end

        if GAG2_AUTO_SHOVEL_FRUIT_STATE == state
        and state.WorkerGeneration == generation then

            state.Running =
                false

            state.CurrentFruit =
                ""

            if state.Enabled ~= true then

                state.LastStatus =
                    "Disabled."
            end

            GAG2AutoShovelFruitScheduleRefresh()
        end
    end)
end

function GAG2AutoShovelFruitSetEnabled(value)

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    local enabled =
        value == true

    if enabled == state.Enabled
    and (
        enabled ~= true
        or state.Running == true
    ) then
        return
    end

    if enabled then

        if GAG2_AUTO_SHOVEL_STATE
        and GAG2_AUTO_SHOVEL_STATE.Enabled == true then

            GAG2AutoShovelSetEnabled(
                false
            )

            GAG2AutoShovelSetToggleOff()
        end

        if GAG2_AUTO_COLLECT_FRUIT_STATE
        and GAG2_AUTO_COLLECT_FRUIT_STATE.Enabled == true then

            GAG2ACFSetEnabled(
                false
            )

            local collectToggle =
                Toggles
                and Toggles.HolyGAG2AutoCollectFruits

            if collectToggle
            and type(collectToggle.SetValue) == "function" then

                pcall(
                    collectToggle.SetValue,
                    collectToggle,
                    false
                )
            end
        end
    end

    state.Enabled =
        enabled

    if enabled then

        state.LastStatus =
            "Starting fruit shovel."

        if ConfigState.Loading ~= true then

            GAG2AutoShovelFruitStartWorker()
        end

    else

        state.WorkerGeneration = state.WorkerGeneration + 1

        state.Running =
            false

        state.CurrentFruit =
            ""

        state.LastStatus =
            "Disabled."
    end

    MarkConfigDirty()
    GAG2AutoShovelFruitScheduleRefresh()
end

function GAG2AutoShovelFruitStartMonitor()

    local state =
        GAG2_AUTO_SHOVEL_FRUIT_STATE

    state.MonitorGeneration = state.MonitorGeneration + 1

    local generation =
        state.MonitorGeneration

    task.spawn(function()

        while GAG2_AUTO_SHOVEL_FRUIT_STATE == state
        and state.MonitorGeneration == generation do

            GAG2AutoShovelFruitScheduleRefresh()

            task.wait(
                2
            )
        end
    end)
end


--==================================================
-- [4.58] SEED PLANTING
-- Continuous stack/grid seed planting.
--==================================================

GAG2_SEED_PLANTING_STATE =
    GAG2_SEED_PLANTING_STATE
    or {
        Enabled = false,
        Running = false,

        SelectedSeeds = {},

        Layout = "Stack",
        Direction = "Down",

        Amount = 20,
        LayerSpacing = 0.35,
        PlantDelay = 0.1,

        GridWidth = 5,
        GridDepth = 4,
        GridLayers = 1,
        GridSpacing = 1.25,

        CycleDelay = 0.1,

        PlantLocalOffset = nil,
        PointLoaded = false,

        PlantSeedPacket = nil,
        PacketSource = "not loaded",

        LastStatus = "Idle.",
        LastFired = 0,
        LastSeed = "",
        LastFailure = "",
    }

GAG2_SEED_PLANTING_CONTROLS =
    GAG2_SEED_PLANTING_CONTROLS
    or {}

GAG2_SEED_PLANTING_POINT_FILE =
    UI_SETTINGS_FOLDER
    .. "/SeedPlantPoint_"
    .. tostring(LOCAL_PLAYER.UserId)
    .. ".json"

GAG2_SEED_PLANTING_LAYOUT_VALUES = {
    "Stack",
    "Grid",
}

GAG2_SEED_PLANTING_DIRECTION_VALUES = {
    "Up",
    "Down",
    "Both",
}

function GAG2SeedPlantClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2SeedPlantGetSeedData()

    if type(GAG2ACFSafeRequire) == "function" then

        local seedData =
            GAG2ACFSafeRequire(
                "SeedData"
            )

        if type(seedData) == "table" then
            return seedData
        end
    end

    local sharedModules =
        ReplicatedStorage:FindFirstChild(
            "SharedModules"
        )

    local seedModule =
        sharedModules
        and sharedModules:FindFirstChild(
            "SeedData",
            true
        )

    if not seedModule
    or seedModule:IsA("ModuleScript") ~= true then

        return nil
    end

    local ok, result =
        pcall(function()

            return require(
                seedModule
            )
        end)

    if ok == true
    and type(result) == "table" then

        return result
    end

    return nil
end

function GAG2SeedPlantBuildValidSeedMap()

    local seedMap =
        {}

    local lowerMap =
        {}

    local ordered =
        {}

    local seedData =
        GAG2SeedPlantGetSeedData()

    if type(seedData) ~= "table" then

        return seedMap,
            ordered,
            lowerMap
    end

    for _, row in pairs(seedData) do

        if type(row) == "table"
        and type(row.SeedName) == "string" then

            local seedName =
                GAG2SeedPlantClean(
                    row.SeedName
                )

            if seedName ~= ""
            and seedMap[seedName] ~= true then

                seedMap[seedName] =
                    true

                lowerMap[seedName:lower()] =
                    seedName

                table.insert(
                    ordered,
                    seedName
                )
            end
        end
    end

    table.sort(
        ordered,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return seedMap,
        ordered,
        lowerMap
end

function GAG2SeedPlantResolveValidSeedName(seedName)

    seedName =
        GAG2ShopCleanItemName(
            seedName
        )

    seedName =
        GAG2SeedPlantClean(
            seedName
        )

    if seedName == "" then
        return ""
    end

    local seedMap, _, lowerMap =
        GAG2SeedPlantBuildValidSeedMap()

    if seedMap[seedName] == true then
        return seedName
    end

    local resolved =
        lowerMap[
            seedName:lower()
        ]

    if resolved then
        return resolved
    end

    return ""
end

function GAG2SeedPlantIsValidSeedName(seedName)

    return GAG2SeedPlantResolveValidSeedName(
        seedName
    ) ~= ""
end

function GAG2SeedPlantReadRealSeedNameFromTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local mainCategory =
        GAG2SeedPlantClean(
            tool:GetAttribute("MainCategory")
        )

    if mainCategory:lower() ~= "seed" then
        return ""
    end

    local seedTool =
        GAG2SeedPlantClean(
            tool:GetAttribute("SeedTool")
        )

    if seedTool == "" then
        return ""
    end

    return GAG2SeedPlantResolveValidSeedName(
        seedTool
    )
end

function GAG2SeedPlantIsRealSeedTool(tool, seedName)

    local wantedSeed =
        GAG2SeedPlantResolveValidSeedName(
            seedName
        )

    if wantedSeed == "" then
        return false
    end

    local toolSeed =
        GAG2SeedPlantReadRealSeedNameFromTool(
            tool
        )

    return toolSeed == wantedSeed
end

function GAG2SeedPlantClampInt(value, defaultValue, minValue, maxValue)

    local number =
        math.floor(
            tonumber(value)
            or tonumber(defaultValue)
            or 0
        )

    return math.clamp(
        number,
        tonumber(minValue) or number,
        tonumber(maxValue) or number
    )
end

function GAG2SeedPlantClampNumber(value, defaultValue, minValue, maxValue)

    local number =
        tonumber(value)
        or tonumber(defaultValue)
        or 0

    return math.clamp(
        number,
        tonumber(minValue) or number,
        tonumber(maxValue) or number
    )
end

function GAG2SeedPlantSetStatus(text)

    local state =
        GAG2_SEED_PLANTING_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    local statusText =
        '<font color="rgb(196,181,253)"><b>Status:</b></font> '
        .. state.LastStatus
        .. '\n'
        .. '<font color="rgb(148,163,184)">'
        .. tostring(state.Layout or "Stack")
        .. ' / '
        .. tostring(state.Direction or "Down")
        .. ' | Amount: '
        .. tostring(state.Amount or 20)
        .. ' | Delay: '
        .. tostring(state.PlantDelay or 0.1)
        .. 's'
        .. '</font>'

    if GAG2_SEED_PLANTING_CONTROLS
    and GAG2_SEED_PLANTING_CONTROLS.Status
    and type(GAG2_SEED_PLANTING_CONTROLS.Status.SetText) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.Status:SetText(
            statusText
        )

        return
    end

    if Options.HolyGAG2FarmStatus then

        Options.HolyGAG2FarmStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Seed Planting</b></font>'
            .. '\n'
            .. state.LastStatus
            .. '\nLayout: '
            .. tostring(state.Layout)
            .. ' | Direction: '
            .. tostring(state.Direction)
            .. ' | Amount/Cycle: '
            .. tostring(state.Amount)
            .. ' | Delay: '
            .. tostring(state.PlantDelay or 0.1)
            .. 's'
            .. '\nPacket: '
            .. tostring(state.PacketSource or "not loaded")
        )
    end
end

function GAG2SeedPlantBuildValidSeedMap()

    local seedMap =
        {}

    local ordered =
        {}

    local function add(seedName)

        seedName =
            GAG2SeedPlantClean(
                seedName
            )

        if seedName == "" then
            return
        end

        if seedMap[seedName] == true then
            return
        end

        seedMap[seedName] =
            true

        table.insert(
            ordered,
            seedName
        )
    end

    local seedData =
        GAG2ACFSafeRequire
        and GAG2ACFSafeRequire("SeedData")
        or nil

    if type(seedData) == "table" then

        for _, row in pairs(seedData) do

            if type(row) == "table"
            and type(row.SeedName) == "string" then

                add(
                    row.SeedName
                )
            end
        end
    end

    -- Safe fallback only. These are real seeds, not gear.
    add("Carrot")
    add("Strawberry")
    add("Blueberry")
    add("Tulip")
    add("Tomato")
    add("Apple")
    add("Bamboo")
    add("Corn")
    add("Cactus")
    add("Pineapple")
    add("Mushroom")
    add("Green Bean")
    add("Banana")
    add("Grape")
    add("Coconut")
    add("Mango")
    add("Dragon Fruit")
    add("Acorn")
    add("Cherry")
    add("Sunflower")
    add("Venus Fly Trap")
    add("Pomegranate")
    add("Poison Apple")
    add("Moon Bloom")
    add("Dragon's Breath")
    add("Ghost Pepper")
    add("Poison Ivy")
    add("Baby Cactus")
    add("Glow Mushroom")
    add("Romanesco")
    add("Horned Melon")
    add("Gold")
    add("Rainbow")

    table.sort(
        ordered,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return seedMap,
        ordered
end

function GAG2SeedPlantIsValidSeedName(seedName)

    seedName =
        GAG2SeedPlantClean(
            seedName
        )

    if seedName == "" then
        return false
    end

    local seedMap =
        GAG2SeedPlantBuildValidSeedMap()

    return seedMap[seedName] == true
end

function GAG2SeedPlantReadRealSeedNameFromTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local mainCategory =
        GAG2SeedPlantClean(
            tool:GetAttribute("MainCategory")
        )

    local seedTool =
        GAG2SeedPlantClean(
            tool:GetAttribute("SeedTool")
        )

    -- Strict rule:
    -- Real plantable seed tools must expose MainCategory = Seed and SeedTool.
    -- This blocks Supersize Mushroom, Speed Mushroom, Gnome, Sprinklers, Trowel, etc.
    if mainCategory:lower() ~= "seed" then
        return ""
    end

    if seedTool == "" then
        return ""
    end

    if GAG2SeedPlantIsValidSeedName(seedTool) ~= true then
        return ""
    end

    return seedTool
end

function GAG2SeedPlantIsRealSeedTool(tool, seedName)

    seedName =
        GAG2SeedPlantClean(
            seedName
        )

    if seedName == "" then
        return false
    end

    return GAG2SeedPlantReadRealSeedNameFromTool(tool) == seedName
end

function GAG2SeedPlantNormalizeSelection(value)

    local result =
        {}

    local function add(itemName)

        local seedName =
            GAG2SeedPlantResolveValidSeedName(
                itemName
            )

        if seedName == "" then
            return
        end

        if table.find(result, seedName) ~= nil then
            return
        end

        table.insert(
            result,
            seedName
        )
    end

    if type(value) == "table" then

        for _, itemName in ipairs(value) do
            add(itemName)
        end

        for itemName, enabled in pairs(value) do

            if enabled == true then
                add(itemName)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    table.sort(
        result
    )

    return result
end

function GAG2SeedPlantGetSeedValues()

    local seedMap, orderedSeeds =
        GAG2SeedPlantBuildValidSeedMap()

    local values =
        {}

    local seen =
        {}

    local function addValue(seedName, displayName)

        seedName =
            GAG2SeedPlantResolveValidSeedName(
                seedName
            )

        if seedName == "" then
            return
        end

        if seedMap[seedName] ~= true then
            return
        end

        if seen[seedName] == true then
            return
        end

        seen[seedName] =
            true

        table.insert(
            values,
            tostring(displayName or seedName)
        )
    end

    local shopSeedValues =
        GAG2ShopGetItemNames(
            "Seeds"
        )

    if type(shopSeedValues) == "table" then

        for _, displayName in ipairs(shopSeedValues) do

            local seedName =
                GAG2ShopCleanItemName(
                    displayName
                )

            addValue(
                seedName,
                displayName
            )
        end
    end

    for _, seedName in ipairs(orderedSeeds or {}) do

        addValue(
            seedName,
            seedName
        )
    end

    table.sort(
        values,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return values
end

function GAG2SeedPlantGetSelectedSeeds()

    local state =
        GAG2_SEED_PLANTING_STATE

    local selected =
        GAG2SeedPlantNormalizeSelection(
            state.SelectedSeeds
        )

    if #selected > 0 then
        return selected
    end

    local shopSelected =
        GAG2_SHOP_STATE
        and GAG2_SHOP_STATE.Selected
        and GAG2_SHOP_STATE.Selected.Seeds

    if type(shopSelected) == "table" then

        selected =
            GAG2SeedPlantNormalizeSelection(
                shopSelected
            )

        if #selected > 0 then
            return selected
        end
    end

    return {}
end

function GAG2SeedPlantSetSelectedSeeds(value)

    GAG2_SEED_PLANTING_STATE.SelectedSeeds =
        GAG2SeedPlantNormalizeSelection(
            value
        )

    GAG2SeedPlantSetStatus(
        "Selected seeds: "
        .. (
            #GAG2_SEED_PLANTING_STATE.SelectedSeeds > 0
            and table.concat(
                GAG2_SEED_PLANTING_STATE.SelectedSeeds,
                ", "
            )
            or "None"
        )
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetLayout(value)

    value =
        GAG2SeedPlantClean(
            value
        )

    if table.find(GAG2_SEED_PLANTING_LAYOUT_VALUES, value) == nil then
        value = "Stack"
    end

    GAG2_SEED_PLANTING_STATE.Layout =
        value

    GAG2SeedPlantSetStatus(
        "Layout set: "
        .. value
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetDirection(value)

    value =
        GAG2SeedPlantClean(
            value
        )

    if table.find(GAG2_SEED_PLANTING_DIRECTION_VALUES, value) == nil then
        value = "Down"
    end

    GAG2_SEED_PLANTING_STATE.Direction =
        value

    GAG2SeedPlantSetStatus(
        "Direction set: "
        .. value
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetAmount(value)

    GAG2_SEED_PLANTING_STATE.Amount =
        GAG2SeedPlantClampInt(
            value,
            20,
            1,
            500
        )

    GAG2SeedPlantSetStatus(
        "Plant amount per cycle: "
        .. tostring(GAG2_SEED_PLANTING_STATE.Amount)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetLayerSpacing(value)

    GAG2_SEED_PLANTING_STATE.LayerSpacing =
        GAG2SeedPlantClampNumber(
            value,
            0.35,
            0.01,
            10
        )

    GAG2SeedPlantSetStatus(
        "Layer spacing: "
        .. tostring(GAG2_SEED_PLANTING_STATE.LayerSpacing)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetPlantDelay(value)

    GAG2_SEED_PLANTING_STATE.PlantDelay =
        GAG2SeedPlantClampNumber(
            value,
            0.1,
            0,
            5
        )

    GAG2SeedPlantSetStatus(
        "Plant delay: "
        .. tostring(GAG2_SEED_PLANTING_STATE.PlantDelay)
        .. "s"
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridWidth(value)

    GAG2_SEED_PLANTING_STATE.GridWidth =
        GAG2SeedPlantClampInt(
            value,
            5,
            1,
            50
        )

    GAG2SeedPlantSetStatus(
        "Grid width: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridWidth)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridDepth(value)

    GAG2_SEED_PLANTING_STATE.GridDepth =
        GAG2SeedPlantClampInt(
            value,
            4,
            1,
            50
        )

    GAG2SeedPlantSetStatus(
        "Grid depth: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridDepth)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridLayers(value)

    GAG2_SEED_PLANTING_STATE.GridLayers =
        GAG2SeedPlantClampInt(
            value,
            1,
            1,
            100
        )

    GAG2SeedPlantSetStatus(
        "Grid layers: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridLayers)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridSpacing(value)

    GAG2_SEED_PLANTING_STATE.GridSpacing =
        GAG2SeedPlantClampNumber(
            value,
            1.25,
            0.1,
            30
        )

    GAG2SeedPlantSetStatus(
        "Grid spacing: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridSpacing)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantVectorToPayload(vector)

    if typeof(vector) ~= "Vector3" then
        return nil
    end

    return {
        X = vector.X,
        Y = vector.Y,
        Z = vector.Z,
    }
end

function GAG2SeedPlantVectorFromPayload(payload)

    if type(payload) ~= "table" then
        return nil
    end

    local x =
        tonumber(payload.X)
        or tonumber(payload.x)
        or tonumber(payload[1])

    local y =
        tonumber(payload.Y)
        or tonumber(payload.y)
        or tonumber(payload[2])

    local z =
        tonumber(payload.Z)
        or tonumber(payload.z)
        or tonumber(payload[3])

    if x
    and y
    and z then

        return Vector3.new(
            x,
            y,
            z
        )
    end

    return nil
end

function GAG2SeedPlantSavePoint(localOffset)

    if typeof(localOffset) ~= "Vector3" then
        return false
    end

    GAG2_SEED_PLANTING_STATE.PlantLocalOffset =
        localOffset

    GAG2_SEED_PLANTING_STATE.PointLoaded =
        true

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local payload = {
        LocalOffset =
            GAG2SeedPlantVectorToPayload(
                localOffset
            ),

        SavedAt =
            os.time(),
    }

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_SEED_PLANTING_POINT_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function GAG2SeedPlantLoadPoint()

    local state =
        GAG2_SEED_PLANTING_STATE

    if state.PointLoaded == true then
        return typeof(state.PlantLocalOffset) == "Vector3"
    end

    state.PointLoaded =
        true

    if CanUseUISettingsFile() ~= true then
        return false
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                GAG2_SEED_PLANTING_POINT_FILE
            )
    end)

    if exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_SEED_PLANTING_POINT_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then
        return false
    end

    local localOffset =
        GAG2SeedPlantVectorFromPayload(
            payload.LocalOffset
        )

    if typeof(localOffset) ~= "Vector3" then
        return false
    end

    state.PlantLocalOffset =
        localOffset

    return true
end

function GAG2SeedPlantGetPlotFrame(plot)

    if typeof(plot) ~= "Instance" then
        return nil
    end

    local okPivot, pivot =
        pcall(function()

            return plot:GetPivot()
        end)

    if okPivot == true
    and typeof(pivot) == "CFrame" then
        return pivot
    end

    local okBox, cframe =
        pcall(function()

            return plot:GetBoundingBox()
        end)

    if okBox == true
    and typeof(cframe) == "CFrame" then
        return cframe
    end

    return nil
end

function GAG2SeedPlantBuildRaycastParams(ownPlot)

    local filter =
        {}

    if LOCAL_PLAYER
    and LOCAL_PLAYER.Character then

        table.insert(
            filter,
            LOCAL_PLAYER.Character
        )
    end

    local plantsFolder =
        ownPlot
        and ownPlot:FindFirstChild("Plants")

    if plantsFolder then

        table.insert(
            filter,
            plantsFolder
        )
    end

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances =
        filter

    params.IgnoreWater =
        true

    return params
end

function GAG2SeedPlantIsValidPlotHit(result, ownPlot)

    if typeof(result) ~= "RaycastResult" then
        return false,
            "no raycast result"
    end

    if typeof(ownPlot) ~= "Instance" then
        return false,
            "own plot missing"
    end

    local hit =
        result.Instance

    if typeof(hit) ~= "Instance" then
        return false,
            "hit missing"
    end

    if hit:IsDescendantOf(ownPlot) ~= true then

        return false,
            "outside own plot: "
            .. PathOf(hit)
    end

    local path =
        PathOf(hit)

    if path:find("%.Plants%.") then

        return false,
            "hit plant: "
            .. path
    end

    if hit.Name == "GardenZonePart" then
        return false,
            "GardenZonePart"
    end

    return true,
        path
end

function GAG2SeedPlantRaycastGround(roughPosition, ownPlot)

    if typeof(roughPosition) ~= "Vector3" then
        return nil,
            "missing rough position"
    end

    local result =
        workspace:Raycast(
            roughPosition + Vector3.new(0, 18, 0),
            Vector3.new(0, -120, 0),
            GAG2SeedPlantBuildRaycastParams(
                ownPlot
            )
        )

    local valid, reason =
        GAG2SeedPlantIsValidPlotHit(
            result,
            ownPlot
        )

    if valid ~= true then
        return nil,
            reason
    end

    return result.Position,
        reason
end

function GAG2SeedPlantSetPointFromCurrentPosition()

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then

        GAG2SeedPlantSetStatus(
            "Could not resolve own garden: "
            .. tostring(plotReason)
        )

        Notify(
            "Seed Planting",
            "Could not resolve your garden.",
            4
        )

        return false
    end

    local plotFrame =
        GAG2SeedPlantGetPlotFrame(
            ownPlot
        )

    if typeof(plotFrame) ~= "CFrame" then

        GAG2SeedPlantSetStatus(
            "Could not resolve plot frame."
        )

        Notify(
            "Seed Planting",
            "Could not resolve plot frame.",
            4
        )

        return false
    end

    local _, root =
        SniperGetCharacterRoot()

    if not root then

        GAG2SeedPlantSetStatus(
            "Character root missing."
        )

        Notify(
            "Seed Planting",
            "Character root missing.",
            4
        )

        return false
    end

    local groundPosition, groundReason =
        GAG2SeedPlantRaycastGround(
            root.Position,
            ownPlot
        )

    if typeof(groundPosition) ~= "Vector3" then

        GAG2SeedPlantSetStatus(
            "Invalid plant point: "
            .. tostring(groundReason)
        )

        Notify(
            "Seed Planting",
            "Stand inside your garden before setting point.",
            4
        )

        return false
    end

    local localOffset =
        plotFrame:PointToObjectSpace(
            groundPosition
        )

    GAG2SeedPlantSavePoint(
        localOffset
    )

    GAG2SeedPlantSetStatus(
        "Plant point saved: "
        .. tostring(groundReason)
    )

    Notify(
        "Seed Planting",
        "Plant point saved.",
        3
    )

    return true
end

function GAG2SeedPlantGetBasePosition()

    GAG2SeedPlantLoadPoint()

    local localOffset =
        GAG2_SEED_PLANTING_STATE.PlantLocalOffset

    if typeof(localOffset) ~= "Vector3" then
        return nil,
            nil,
            "Set Plant Point first."
    end

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then
        return nil,
            nil,
            tostring(plotReason)
    end

    local plotFrame =
        GAG2SeedPlantGetPlotFrame(
            ownPlot
        )

    if typeof(plotFrame) ~= "CFrame" then
        return nil,
            nil,
            "plot frame missing"
    end

    return plotFrame:PointToWorldSpace(
        localOffset
    ),
    ownPlot,
    "ok"
end

function GAG2SeedPlantSearchPacket(candidate, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 9 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    local packetName =
        tostring(
            SniperSafeRawGet(candidate, "Name")
            or ""
        )

    local okFire, fireFunction =
        pcall(function()

            return candidate.Fire
        end)

    if packetName == "PlantSeed"
    and okFire == true
    and type(fireFunction) == "function" then

        return candidate
    end

    for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            local found =
                GAG2SeedPlantSearchPacket(
                    row.Value,
                    seen,
                    depth + 1
                )

            if found then
                return found
            end
        end
    end

    return nil
end

function GAG2SeedPlantResolvePacketFromController()

    local playerScripts =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("PlayerScripts")

    local controller =
        playerScripts
        and playerScripts:FindFirstChild("Controllers")
        and playerScripts.Controllers:FindFirstChild("PlantController")

    if not controller then
        return nil,
            "PlantController missing"
    end

    local okRequire, plantController =
        pcall(function()

            return require(
                controller
            )
        end)

    if okRequire ~= true
    or type(plantController) ~= "table" then

        return nil,
            "PlantController require failed"
    end

    local tryPlant =
        plantController.TryPlantWithRay

    if type(tryPlant) ~= "function" then
        return nil,
            "TryPlantWithRay missing"
    end

    if type(debug) ~= "table"
    or type(debug.getupvalues) ~= "function" then

        return nil,
            "debug.getupvalues unsupported"
    end

    local okUpvalues, upvalues =
        pcall(function()

            return debug.getupvalues(
                tryPlant
            )
        end)

    if okUpvalues ~= true
    or type(upvalues) ~= "table" then

        return nil,
            "getupvalues failed"
    end

    for index, value in pairs(upvalues) do

        if type(value) == "table" then

            local plantGroup =
                SniperSafeRawGet(
                    value,
                    "Plant"
                )

            local plantSeed =
                plantGroup
                and SniperSafeRawGet(
                    plantGroup,
                    "PlantSeed"
                )

            local okFire, fireFunction =
                pcall(function()

                    return plantSeed.Fire
                end)

            if type(plantSeed) == "table"
            and SniperSafeRawGet(plantSeed, "Name") == "PlantSeed"
            and okFire == true
            and type(fireFunction) == "function" then

                return plantSeed,
                    "PlantController.TryPlantWithRay upvalue #"
                    .. tostring(index)
            end
        end
    end

    return nil,
        "PlantSeed packet not found in controller"
end

function GAG2SeedPlantFindPacket()

    local state =
        GAG2_SEED_PLANTING_STATE

    if type(state.PlantSeedPacket) == "table" then

        local okFire, fireFunction =
            pcall(function()

                return state.PlantSeedPacket.Fire
            end)

        if okFire == true
        and type(fireFunction) == "function" then

            return state.PlantSeedPacket
        end
    end

    local packets =
        SniperFindPacketTable()

    if type(packets) == "table" then

        local plantGroup =
            SniperSafeRawGet(
                packets,
                "Plant"
            )

        local plantSeed =
            plantGroup
            and SniperSafeRawGet(
                plantGroup,
                "PlantSeed"
            )

        local okFire, fireFunction =
            pcall(function()

                return plantSeed.Fire
            end)

        if type(plantSeed) == "table"
        and SniperSafeRawGet(plantSeed, "Name") == "PlantSeed"
        and okFire == true
        and type(fireFunction) == "function" then

            state.PlantSeedPacket =
                plantSeed

            state.PacketSource =
                "packet table Plant.PlantSeed"

            return plantSeed
        end

        local found =
            GAG2SeedPlantSearchPacket(
                packets,
                {},
                0
            )

        if found then

            state.PlantSeedPacket =
                found

            state.PacketSource =
                "packet table recursive PlantSeed"

            return found
        end
    end

    local controllerPacket, controllerSource =
        GAG2SeedPlantResolvePacketFromController()

    if controllerPacket then

        state.PlantSeedPacket =
            controllerPacket

        state.PacketSource =
            tostring(controllerSource)

        return controllerPacket
    end

    state.PacketSource =
        tostring(controllerSource or "PlantSeed packet missing")

    return nil
end

function GAG2SeedPlantFire(seedName, worldPosition)

    local packet =
        GAG2SeedPlantFindPacket()

    if not packet then
        return false,
            GAG2_SEED_PLANTING_STATE.PacketSource
    end

    seedName =
        GAG2SeedPlantResolveValidSeedName(
            seedName
        )

    if seedName == "" then
        return false,
            "blocked non-seed or missing SeedData entry"
    end

    if typeof(worldPosition) ~= "Vector3" then
        return false,
            "missing world position"
    end

    local ok, err =
        pcall(function()

            packet:Fire(
                worldPosition,
                seedName,
                Enum.NormalId.Top.Value
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                packet.Fire(
                    packet,
                    worldPosition,
                    seedName,
                    Enum.NormalId.Top.Value
                )
            end)
    end

    if ok ~= true then
        return false,
            tostring(err)
    end

    return true,
        "fired"
end

function GAG2SeedPlantFindSeedTool(seedName)

    seedName =
        GAG2SeedPlantResolveValidSeedName(
            seedName
        )

    if seedName == "" then
        return nil
    end

    local containers = {
        LOCAL_PLAYER and LOCAL_PLAYER.Character,
        LOCAL_PLAYER and LOCAL_PLAYER:FindFirstChildOfClass("Backpack"),
    }

    for _, container in ipairs(containers) do

        if typeof(container) == "Instance" then

            for _, child in ipairs(container:GetChildren()) do

                if GAG2SeedPlantIsRealSeedTool(
                    child,
                    seedName
                ) == true then

                    return child
                end
            end
        end
    end

    return nil
end

function GAG2SeedPlantReadSeedCount(seedName)

    local tool =
        GAG2SeedPlantFindSeedTool(
            seedName
        )

    if not tool then
        return 0,
            "tool missing"
    end

    local attrNames = {
        "Count",
        "Quantity",
        "Amount",
        "Stock",
    }

    for _, attrName in ipairs(attrNames) do

        local value =
            tonumber(
                tool:GetAttribute(attrName)
            )

        if value then
            return math.max(
                0,
                math.floor(value)
            ),
            PathOf(tool)
        end
    end

    return 1,
        PathOf(tool)
end

function GAG2SeedPlantEquip(seedName)

    local tool =
        GAG2SeedPlantFindSeedTool(
            seedName
        )

    if not tool then
        return false,
            "seed tool missing"
    end

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return false,
            "humanoid missing"
    end

    local ok, err =
        pcall(function()

            humanoid:EquipTool(
                tool
            )
        end)

    if ok ~= true then
        return false,
            tostring(err)
    end

    task.wait(
        0.05
    )

    return true,
        PathOf(tool)
end

function GAG2SeedPlantBuildLayerOffsets(count, spacing, direction)

    count =
        GAG2SeedPlantClampInt(
            count,
            1,
            1,
            500
        )

    spacing =
        GAG2SeedPlantClampNumber(
            spacing,
            0.35,
            0.01,
            10
        )

    direction =
        GAG2SeedPlantClean(
            direction
        )

    if table.find(GAG2_SEED_PLANTING_DIRECTION_VALUES, direction) == nil then
        direction = "Down"
    end

    local offsets = {
        0,
    }

    if count <= 1 then
        return offsets
    end

    if direction == "Both" then

        local step =
            1

        while #offsets < count do

            table.insert(
                offsets,
                spacing * step
            )

            if #offsets >= count then
                break
            end

            table.insert(
                offsets,
                -spacing * step
            )

            step = step + 1
        end

        return offsets
    end

    local sign =
        direction == "Up"
        and 1
        or -1

    for index = 1, count - 1 do

        table.insert(
            offsets,
            spacing * index * sign
        )
    end

    return offsets
end

function GAG2SeedPlantBuildStackPositions(basePosition)

    local state =
        GAG2_SEED_PLANTING_STATE

    local amount =
        GAG2SeedPlantClampInt(
            state.Amount,
            20,
            1,
            500
        )

    local offsets =
        GAG2SeedPlantBuildLayerOffsets(
            amount,
            state.LayerSpacing,
            state.Direction
        )

    local positions =
        {}

    for _, yOffset in ipairs(offsets) do

        table.insert(
            positions,
            basePosition
            + Vector3.new(
                0,
                yOffset,
                0
            )
        )

        if #positions >= amount then
            break
        end
    end

    return positions
end

function GAG2SeedPlantBuildGridPositions(basePosition, ownPlot)

    local state =
        GAG2_SEED_PLANTING_STATE

    local amount =
        GAG2SeedPlantClampInt(
            state.Amount,
            20,
            1,
            500
        )

    local width =
        GAG2SeedPlantClampInt(
            state.GridWidth,
            5,
            1,
            50
        )

    local depth =
        GAG2SeedPlantClampInt(
            state.GridDepth,
            4,
            1,
            50
        )

    local layers =
        GAG2SeedPlantClampInt(
            state.GridLayers,
            1,
            1,
            100
        )

    local gridSpacing =
        GAG2SeedPlantClampNumber(
            state.GridSpacing,
            1.25,
            0.1,
            30
        )

    local layerOffsets =
        GAG2SeedPlantBuildLayerOffsets(
            layers,
            state.LayerSpacing,
            state.Direction
        )

    local positions =
        {}

    local xStart =
        -((width - 1) * gridSpacing) / 2

    local zStart =
        -((depth - 1) * gridSpacing) / 2

    for _, layerOffset in ipairs(layerOffsets) do

        for zIndex = 1, depth do

            for xIndex = 1, width do

                if #positions >= amount then
                    return positions
                end

                local roughPosition =
                    basePosition
                    + Vector3.new(
                        xStart + ((xIndex - 1) * gridSpacing),
                        0,
                        zStart + ((zIndex - 1) * gridSpacing)
                    )

                local groundPosition =
                    GAG2SeedPlantRaycastGround(
                        roughPosition,
                        ownPlot
                    )

                if typeof(groundPosition) == "Vector3" then

                    table.insert(
                        positions,
                        groundPosition
                        + Vector3.new(
                            0,
                            layerOffset,
                            0
                        )
                    )
                end
            end
        end
    end

    return positions
end

function GAG2SeedPlantBuildPositions()

    local state =
        GAG2_SEED_PLANTING_STATE

    GAG2SeedPlantLoadPoint()

    local localOffset =
        state.PlantLocalOffset

    local cacheKey =
        tostring(state.Layout)
        .. "|"
        .. tostring(state.Direction)
        .. "|"
        .. tostring(state.Amount)
        .. "|"
        .. tostring(state.LayerSpacing)
        .. "|"
        .. tostring(state.GridWidth)
        .. "|"
        .. tostring(state.GridDepth)
        .. "|"
        .. tostring(state.GridLayers)
        .. "|"
        .. tostring(state.GridSpacing)
        .. "|"
        .. (
            typeof(localOffset) == "Vector3"
            and string.format(
                "%.3f,%.3f,%.3f",
                localOffset.X,
                localOffset.Y,
                localOffset.Z
            )
            or "no-point"
        )

    local now =
        os.clock()

    local cached =
        state.PositionCache

    if type(cached) == "table"
    and cached.Key == cacheKey
    and type(cached.Positions) == "table"
    and now - tonumber(cached.At or 0) <= 1.25 then

        local copied =
            {}

        for index, position in ipairs(cached.Positions) do

            copied[index] =
                position
        end

        return copied,
            tostring(cached.Reason or "cached")
    end

    local basePosition, ownPlot, reason =
        GAG2SeedPlantGetBasePosition()

    if typeof(basePosition) ~= "Vector3" then

        state.PositionCache =
            nil

        return {},
            tostring(reason)
    end

    local positions =
        {}

    local positionReason =
        "stack"

    if state.Layout == "Grid" then

        positions =
            GAG2SeedPlantBuildGridPositions(
                basePosition,
                ownPlot
            )

        positionReason =
            "grid"

        if #positions <= 0 then

            state.PositionCache =
                nil

            return {},
                "no valid grid positions"
        end

    else

        positions =
            GAG2SeedPlantBuildStackPositions(
                basePosition
            )

        positionReason =
            "stack"
    end

    state.PositionCache = {
        Key = cacheKey,
        At = now,
        Positions = positions,
        Reason = positionReason,
    }

    local copied =
        {}

    for index, position in ipairs(positions) do

        copied[index] =
            position
    end

    return copied,
        positionReason
end

function GAG2SeedPlantFireCycle()

    local state =
        GAG2_SEED_PLANTING_STATE

    local selectedSeeds =
        GAG2SeedPlantGetSelectedSeeds()

    if #selectedSeeds <= 0 then

        GAG2SeedPlantSetStatus(
            "Select seeds to plant, or select Auto Buy seed items."
        )

        return 0
    end

    local positions, positionReason =
        GAG2SeedPlantBuildPositions()

    if #positions <= 0 then

        GAG2SeedPlantSetStatus(
            "No valid positions: "
            .. tostring(positionReason)
        )

        return 0
    end

    local amount =
        GAG2SeedPlantClampInt(
            state.Amount,
            20,
            1,
            500
        )

    local fired =
        0

    local waitingSeed =
        ""

    for _, seedName in ipairs(selectedSeeds) do

        if state.Enabled ~= true then
            break
        end

        if fired >= amount then
            break
        end

        seedName =
            GAG2SeedPlantClean(
                seedName
            )

        if seedName ~= "" then

            local count =
                GAG2SeedPlantReadSeedCount(
                    seedName
                )

            if count <= 0 then

                if waitingSeed == "" then
                    waitingSeed = seedName
                end

            else

                local equipOk, equipInfo =
                    GAG2SeedPlantEquip(
                        seedName
                    )

                if equipOk ~= true then

                    state.LastFailure =
                        tostring(equipInfo)

                    GAG2SeedPlantSetStatus(
                        "Equip failed for "
                        .. seedName
                        .. ": "
                        .. tostring(equipInfo)
                    )

                else

                    for _, worldPosition in ipairs(positions) do

                        if state.Enabled ~= true then
                            break
                        end

                        if fired >= amount then
                            break
                        end

                        local liveCount =
                            GAG2SeedPlantReadSeedCount(
                                seedName
                            )

                        if liveCount <= 0 then
                            break
                        end

                        local okPlant, plantInfo =
                            GAG2SeedPlantFire(
                                seedName,
                                worldPosition
                            )

                        if okPlant == true then

                            fired = fired + 1

                            state.LastSeed =
                                seedName

                            state.LastFired =
                                fired

                            local plantDelay =
                                GAG2SeedPlantClampNumber(
                                    state.PlantDelay,
                                    0.1,
                                    0,
                                    5
                                )

                            if plantDelay > 0 then

                                task.wait(
                                    plantDelay
                                )

                            elseif fired % 12 == 0 then

                                task.wait()
                            end

                        else

                            state.LastFailure =
                                tostring(plantInfo)

                            GAG2SeedPlantSetStatus(
                                "Plant failed for "
                                .. seedName
                                .. ": "
                                .. tostring(plantInfo)
                            )

                            task.wait(
                                0.15
                            )
                        end
                    end
                end
            end
        end
    end

    if fired > 0 then

        GAG2SeedPlantSetStatus(
            "Fired "
            .. tostring(fired)
            .. " plant packet(s). Waiting next cycle."
        )

    elseif waitingSeed ~= "" then

        GAG2SeedPlantSetStatus(
            "Waiting for "
            .. waitingSeed
            .. " seeds from Backpack / Auto Buy..."
        )

    else

        GAG2SeedPlantSetStatus(
            "No selected seed tools available."
        )
    end

    return fired
end

function GAG2SeedPlantStartLoop()

    local state =
        GAG2_SEED_PLANTING_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        GAG2SeedPlantSetStatus(
            "Loop started. Plant Amount is per cycle."
        )

        while state.Enabled == true do

            local fired =
                GAG2SeedPlantFireCycle()

            if fired > 0 then

                task.wait(
                    GAG2SeedPlantClampNumber(
                        state.CycleDelay,
                        0.1,
                        0.03,
                        5
                    )
                )

            else

                task.wait(
                    0.75
                )
            end
        end

        state.Running =
            false

        if state.Enabled ~= true then

            GAG2SeedPlantSetStatus(
                "Stopped."
            )
        end
    end)
end

function GAG2SeedPlantSetEnabled(value)

    local state =
        GAG2_SEED_PLANTING_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        if Toggles
        and Toggles.HolyGAG2AutoPlant
        and type(Toggles.HolyGAG2AutoPlant.SetValue) == "function"
        and Toggles.HolyGAG2AutoPlant.Value == true then

            pcall(function()

                Toggles.HolyGAG2AutoPlant:SetValue(
                    false
                )
            end)
        end

        GAG2SeedPlantSetStatus(
            "Enabled. Plant Amount is per cycle."
        )

        if ConfigState.Loading ~= true then

            GAG2SeedPlantStartLoop()
        end

    else

        GAG2SeedPlantSetStatus(
            "Disabled."
        )
    end

    MarkConfigDirty()
end

function GAG2SeedPlantRefreshDropdown()

    local dropdown =
        GAG2_SEED_PLANTING_CONTROLS.Seeds

    if not dropdown then
        return
    end

    local values =
        GAG2SeedPlantGetSeedValues()

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

function GAG2RestoreSeedPlantingState()

    task.defer(function()

        local state =
            GAG2_SEED_PLANTING_STATE

        GAG2SeedPlantLoadPoint()

        if Options.HolyGAG2SeedPlantSeeds then

            GAG2SeedPlantSetSelectedSeeds(
                Options.HolyGAG2SeedPlantSeeds.Value
            )
        end

        if Options.HolyGAG2SeedPlantLayout then

            GAG2SeedPlantSetLayout(
                Options.HolyGAG2SeedPlantLayout.Value
            )
        end

        if Options.HolyGAG2SeedPlantDirection then

            GAG2SeedPlantSetDirection(
                Options.HolyGAG2SeedPlantDirection.Value
            )
        end

        if Options.HolyGAG2SeedPlantAmount then

            GAG2SeedPlantSetAmount(
                Options.HolyGAG2SeedPlantAmount.Value
            )
        end

        if Options.HolyGAG2SeedPlantDelay then

            GAG2SeedPlantSetPlantDelay(
                Options.HolyGAG2SeedPlantDelay.Value
            )
        end

        if Options.HolyGAG2SeedPlantLayerSpacing then

            GAG2SeedPlantSetLayerSpacing(
                Options.HolyGAG2SeedPlantLayerSpacing.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridWidth then

            GAG2SeedPlantSetGridWidth(
                Options.HolyGAG2SeedPlantGridWidth.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridDepth then

            GAG2SeedPlantSetGridDepth(
                Options.HolyGAG2SeedPlantGridDepth.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridLayers then

            GAG2SeedPlantSetGridLayers(
                Options.HolyGAG2SeedPlantGridLayers.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridSpacing then

            GAG2SeedPlantSetGridSpacing(
                Options.HolyGAG2SeedPlantGridSpacing.Value
            )
        end

        if Toggles.HolyGAG2SeedPlanting then

            state.Enabled =
                Toggles.HolyGAG2SeedPlanting.Value == true
        end

        GAG2SeedPlantRefreshDropdown()

        if state.Enabled == true then

            GAG2SeedPlantSetEnabled(
                true
            )

        else

            GAG2SeedPlantSetStatus(
                "Ready."
            )
        end
    end)
end

function SniperGetMovementMode()

    local mode =
        CleanText(
            SniperState.MovementMode
        )

    if mode == "Walk" then
        return "Walk"
    end

    return "Teleport"
end

function SniperGetBuyMode()

    local mode =
        CleanText(
            SniperState.BuyMode
        )

    if mode == "Hold" then
        return "Hold"
    end

    return "Instant"
end

function SniperGetReturnMovementMode()

    local mode =
        CleanText(
            SniperState.ReturnMovementMode
        )

    if mode == "Teleport" then
        return "Teleport"
    end

    return "Walk"
end

function SniperWalkToSavedCFrame(savedCFrame)

    if typeof(savedCFrame) ~= "CFrame" then
        return false,
            "bad saved position"
    end

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return false,
            "missing character"
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return false,
            "missing humanoid"
    end

    local targetPosition =
        savedCFrame.Position

    local started =
        os.clock()

    local lastMoveTo =
        0

    while os.clock() - started < 8 do

        character, root =
            SniperGetCharacterRoot()

        if not character
        or not root then
            return false,
                "lost character"
        end

        humanoid =
            character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            return false,
                "lost humanoid"
        end

        local distance =
            (root.Position - targetPosition).Magnitude

        if distance <= 5 then
            break
        end

        if os.clock() - lastMoveTo >= 0.35 then

            lastMoveTo =
                os.clock()

            humanoid:MoveTo(
                targetPosition
            )
        end

        task.wait(
            0.12
        )
    end

    local _, finalRoot =
        SniperGetCharacterRoot()

    if finalRoot then

        SniperStopCharacterMotion(
            finalRoot
        )

        return (finalRoot.Position - targetPosition).Magnitude <= 8,
            "walked"
    end

    return false,
        "missing final root"
end

function SniperWalkCloseForTame(entry)

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return nil, "missing character"
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return nil, "missing humanoid"
    end

    local oldCFrame =
        root.CFrame

    local started =
        os.clock()

    local closePosition =
        nil

    local targetPosition =
        nil

    while os.clock() - started < 7 do

        targetPosition =
            SniperGetEntryTamePosition(
                entry
            )

        if typeof(targetPosition) ~= "Vector3" then
            return nil, "missing pet position"
        end

        local _, safePosition =
            SniperGetSafeTameCFrame(
                targetPosition
            )

        if typeof(safePosition) == "Vector3" then

            closePosition =
                safePosition

                humanoid:MoveTo(
                    closePosition
                )

            if (root.Position - closePosition).Magnitude <= 7 then
                break
            end
        end

        task.wait(
            0.12
        )
    end

    SniperStopCharacterMotion(
        root
    )

    if typeof(targetPosition) == "Vector3" then

        SniperAimAtPetPosition(
            targetPosition
        )

        task.wait(
            0.15
        )
    end

    return {
        Character = character,
        OldCFrame = oldCFrame,
        ClosePosition = root.Position,
        TargetPosition = targetPosition,
        Moved = true,
        MovementMode = "Walk",
    },
    "walked"
end

function SniperMoveToBuyPosition(entry)

    if SniperGetMovementMode() == "Walk" then

        return SniperWalkCloseForTame(
            entry
        )
    end

    local moveState, moveInfo =
        SniperMoveCloseForTame(
            entry
        )

    if type(moveState) == "table" then
        moveState.MovementMode = "Teleport"
    end

    return moveState,
        moveInfo
end

function SniperFindEntryBuyPrompt(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local roots =
        {}

    local function addRoot(root)

        if typeof(root) == "Instance"
        and root.Parent ~= nil
        and table.find(roots, root) == nil then

            table.insert(
                roots,
                root
            )
        end
    end

    addRoot(entry.Spawn)
    addRoot(entry.Instance)
    addRoot(entry.Ref)

    if CleanText(entry.UUID) ~= "" then

        addRoot(
            SniperFindSpawnByUuid(
                entry.UUID
            )
        )

        addRoot(
            SniperFindRef(
                entry.UUID
            )
        )
    end

    for _, root in ipairs(roots) do

        if root:IsA("ProximityPrompt") then
            return root
        end

        for _, descendant in ipairs(root:GetDescendants()) do

            if descendant:IsA("ProximityPrompt") then

                local text =
                    (
                        tostring(descendant.Name)
                        .. " "
                        .. tostring(descendant.ActionText)
                        .. " "
                        .. tostring(descendant.ObjectText)
                    ):lower()

                if text:find("buy", 1, true)
                or text:find("tame", 1, true)
                or text:find("adopt", 1, true) then

                    return descendant
                end
            end
        end
    end

    return nil
end

function SniperHoldBuyPromptForEntry(entry)

    local prompt =
        SniperFindEntryBuyPrompt(
            entry
        )

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then

        return false,
            "BuyPrompt missing"
    end

    local targetPosition =
        SniperGetEntryTamePosition(
            entry
        )

    if typeof(targetPosition) == "Vector3" then

        SniperAimAtEntry(
            entry,
            targetPosition
        )
    end

    local holdTime =
        math.clamp(
            tonumber(prompt.HoldDuration)
            or 1,
            0.25,
            8
        )
        + 0.20

    local fired =
        false

    if type(fireproximityprompt) == "function" then

        local ok =
            pcall(function()

                fireproximityprompt(
                    prompt,
                    holdTime
                )
            end)

        if ok == true then
            fired = true
        end
    end

    if fired ~= true then

        pcall(function()

            prompt:InputHoldBegin()
        end)

        task.wait(
            holdTime
        )

        pcall(function()

            prompt:InputHoldEnd()
        end)

        fired =
            true
    end

    return fired,
        "held"
end

function SniperMoveCloseForTame(entry)

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return nil, "missing character"
    end

    local targetPosition =
        SniperGetEntryTamePosition(
            entry
        )

    if typeof(targetPosition) ~= "Vector3" then
        return nil, "missing pet position"
    end

    local oldCFrame =
        root.CFrame

    local distance =
        (root.Position - targetPosition).Magnitude

    if distance <= 8 then

        SniperAimAtPetPosition(
            targetPosition
        )

        SniperStopCharacterMotion(
            root
        )

        return {
            Character = character,
            OldCFrame = oldCFrame,
            ClosePosition = root.Position,
            TargetPosition = targetPosition,
            Moved = false,
        },
        "already close"
    end

    local closeCFrame, closePosition =
        SniperGetSafeTameCFrame(
            targetPosition
        )

    if typeof(closeCFrame) ~= "CFrame"
    or typeof(closePosition) ~= "Vector3" then
        return nil, "safe ground position failed"
    end

    local ok, err =
        pcall(function()

            character:PivotTo(
                closeCFrame
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                root.CFrame =
                    closeCFrame
            end)
    end

    if ok ~= true then
        return nil, tostring(err)
    end

    task.wait(
        0.05
    )

    local freshTargetPosition =
        SniperGetEntryTamePosition(
            entry
        )

    if typeof(freshTargetPosition) == "Vector3" then

        targetPosition =
            freshTargetPosition

        SniperAimAtPetPosition(
            targetPosition
        )
    end

    local _, newRoot =
        SniperGetCharacterRoot()

    if newRoot then

        SniperStopCharacterMotion(
            newRoot
        )
    end

    task.wait(
        0.08
    )

    return {
        Character = character,
        OldCFrame = oldCFrame,
        ClosePosition = closePosition,
        TargetPosition = targetPosition,
        Moved = true,
    },
    "moved"
end


local function SniperRestoreAfterTame(moveState)

    if SniperState.ReturnAfterTame ~= true then
        return
    end

    if type(moveState) ~= "table" then
        return
    end

    if moveState.Moved ~= true then
        return
    end

    local oldCFrame =
        moveState.OldCFrame

    local closePosition =
        moveState.ClosePosition

    if typeof(oldCFrame) ~= "CFrame" then
        return
    end

    local currentCharacter, currentRoot =
        SniperGetCharacterRoot()

    if not currentCharacter
    or not currentRoot then
        return
    end

    if typeof(closePosition) == "Vector3" then

        local movedAwayDistance =
            (currentRoot.Position - closePosition).Magnitude

        if movedAwayDistance > 18 then
            return
        end
    end

    if SniperGetReturnMovementMode() == "Walk" then

        SetSniperStatus(
            "Returning by walk..."
        )

        SniperWalkToSavedCFrame(
            oldCFrame
        )

        return
    end

    SetSniperStatus(
        "Returning by teleport..."
    )

    pcall(function()

        currentCharacter:PivotTo(
            oldCFrame
        )
    end)
end

local function SniperGetEntryKey(entry)

    if type(entry) ~= "table" then
        return ""
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid ~= "" then
        return uuid
    end

    return CleanText(entry.Name)
end

function SniperHasPendingBuy()

    if type(SniperState.PendingWildPets) ~= "table" then
        return false
    end

    for _, value in pairs(SniperState.PendingWildPets) do

        if value == true then
            return true
        end

        if type(value) == "table"
        and value.Confirmed ~= true then

            return true
        end
    end

    return false
end

function SniperHasUnacceptedPendingBuy()

    if type(SniperState.PendingWildPets) ~= "table" then
        return false
    end

    for _, record in pairs(SniperState.PendingWildPets) do

        if record == true then
            return true
        end

        if type(record) == "table"
        and record.Confirmed ~= true
        and record.Accepted ~= true then

            return true
        end
    end

    return false
end

local function SniperIsEntryHandled(entry)

    local key =
        SniperGetEntryKey(entry)

    if key == "" then
        return false
    end

    local untilTime =
        tonumber(
            SniperState.HandledWildPets[key]
        )
        or 0

    if untilTime <= 0 then
        return false
    end

    if os.clock() >= untilTime then

        SniperState.HandledWildPets[key] =
            nil

        return false
    end

    return true
end

local function SniperMarkEntryHandled(entry, seconds)

    local key =
        SniperGetEntryKey(entry)

    if key == "" then
        return
    end

    SniperState.HandledWildPets[key] =
        os.clock()
        + (
            tonumber(seconds)
            or SniperState.HandledPetCooldown
            or 60
        )
end

local function SniperFindSpawnByUuid(uuid)

    uuid =
        CleanText(uuid)

    if uuid == "" then
        return nil
    end

    local folder =
        SniperGetSpawnsFolder()

    if not folder then
        return nil
    end

    for _, child in ipairs(folder:GetChildren()) do

        local childUuid =
            SniperGetUuid(
                child.Name
            )

        if childUuid == uuid then
            return child
        end
    end

    return nil
end

local function SniperEntryStillActive(entry)

    if type(entry) ~= "table" then
        return false
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid ~= "" then

        local ref =
            SniperFindRef(
                uuid
            )

        local spawn =
            SniperFindSpawnByUuid(
                uuid
            )

        if typeof(ref) == "Instance"
        and ref.Parent ~= nil then
            return true
        end

        if typeof(spawn) == "Instance"
        and spawn.Parent ~= nil then
            return true
        end

        return false
    end

    local instance =
        entry.Instance

    if typeof(instance) == "Instance"
    and instance.Parent ~= nil then
        return true
    end

    return false
end

function SniperGetLeaderstatsSheckles()

    local function parseNumber(value)

        if type(value) == "number" then
            return value
        end

        local text =
            CleanText(value)

        if text == "" then
            return nil
        end

        text =
            text:gsub(",", "")
                :gsub("¢", "")
                :gsub("%$", "")
                :gsub("%s+", "")

        local multiplier =
            1

        local suffix =
            text:sub(-1):lower()

        if suffix == "k" then

            multiplier =
                1000

            text =
                text:sub(1, -2)

        elseif suffix == "m" then

            multiplier =
                1000000

            text =
                text:sub(1, -2)

        elseif suffix == "b" then

            multiplier =
                1000000000

            text =
                text:sub(1, -2)
        end

        local number =
            tonumber(text)

        if not number then
            return nil
        end

        return number * multiplier
    end

    local names = {
        "Sheckles",
        "Sheckle",
        "Money",
        "Cash",
        "Coins",
        "Currency",
    }

    local leaderstats =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("leaderstats")

    if leaderstats then

        for _, name in ipairs(names) do

            local valueObject =
                leaderstats:FindFirstChild(name)

            if valueObject
            and valueObject:IsA("ValueBase") then

                local number =
                    parseNumber(valueObject.Value)

                if number ~= nil then
                    return number
                end
            end
        end
    end

    if LOCAL_PLAYER then

        for _, name in ipairs(names) do

            local number =
                parseNumber(
                    LOCAL_PLAYER:GetAttribute(name)
                )

            if number ~= nil then
                return number
            end
        end
    end

    return nil
end

function SniperGetLeaderstatsShecklesObject()

    local names = {
        "Sheckles",
        "Sheckle",
        "Money",
        "Cash",
        "Coins",
        "Currency",
    }

    local leaderstats =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("leaderstats")

    if not leaderstats then
        return nil
    end

    for _, name in ipairs(names) do

        local valueObject =
            leaderstats:FindFirstChild(name)

        if valueObject
        and valueObject:IsA("ValueBase") then

            return valueObject
        end
    end

    return nil
end

function SniperClearPendingBuyKey(key)

    key =
        CleanText(key)

    if key == "" then
        return
    end

    local record =
        type(SniperState.PendingWildPets) == "table"
        and SniperState.PendingWildPets[key]
        or nil

    if type(record) == "table"
    and type(record.RefConnections) == "table" then

        for _, connection in ipairs(record.RefConnections) do

            if connection then

                pcall(function()

                    connection:Disconnect()
                end)
            end
        end

        record.RefConnections =
            {}
    end

    if type(record) == "table"
    and record.ShecklesConnection then

        pcall(function()

            record.ShecklesConnection:Disconnect()
        end)

        record.ShecklesConnection =
            nil
    end

    if type(SniperState.PendingWildPets) == "table" then

        SniperState.PendingWildPets[key] =
            nil
    end

    if SniperHasPendingBuy() == true then

        SniperState.ConfirmingBuy =
            true

        SniperState.ConfirmingBuyKey =
            ""

    else

        SniperState.ConfirmingBuy =
            false

        SniperState.ConfirmingBuyKey =
            ""
    end
end

function SniperConfirmPendingBuyRecord(record, reason, petId)

    if type(record) ~= "table" then
        return false
    end

    if record.Confirmed == true then
        return false
    end

    petId =
        CleanText(petId)

    if petId ~= "" then

        SniperState.ConfirmedPetIds =
            type(SniperState.ConfirmedPetIds) == "table"
            and SniperState.ConfirmedPetIds
            or {}

        if SniperState.ConfirmedPetIds[petId] == true then

            print(
                "[HOLY SNIPER]",
                "ignored duplicate petId confirm",
                "| pet:",
                tostring(record.PetName),
                "| uuid:",
                tostring(record.UUID),
                "| petId:",
                tostring(petId),
                "| reason:",
                tostring(reason)
            )

            return false
        end

        SniperState.ConfirmedPetIds[petId] =
            true
    end

    record.Accepted =
        true

    record.Confirmed =
        true

    record.ConfirmReason =
        tostring(reason or "confirmed")

    record.PetId =
        petId

    local key =
        CleanText(record.Key)

    if key ~= "" then

        SniperState.HandledWildPets[key] =
            os.clock()
            + (
                tonumber(SniperState.HandledPetCooldown)
                or 120
            )
    end

    SetSniperStatus(
        "Confirmed: "
        .. tostring(record.PetName)
    )

    Notify(
        "Snipe",
        "Confirmed "
        .. tostring(record.PetName)
        .. ".",
        3
    )

    print(
        "[HOLY SNIPER]",
        "buy confirmed",
        "| pet:",
        tostring(record.PetName),
        "| uuid:",
        tostring(record.UUID),
        "| petId:",
        tostring(record.PetId),
        "| reason:",
        tostring(record.ConfirmReason)
    )

    SniperClearPendingBuyKey(
        key
    )

    return true
end

function SniperConfirmPendingBuyByPetName(petName, reason, petId)

    petName =
        CleanText(petName)

    if petName == ""
    or type(SniperState.PendingWildPets) ~= "table" then

        return false
    end

    local wanted =
        SniperNormalizeName(
            petName
        )

    local bestRecord =
        nil

    for _, record in pairs(SniperState.PendingWildPets) do

        if type(record) == "table"
        and record.Confirmed ~= true
        and SniperNormalizeName(record.PetName) == wanted then

            if bestRecord == nil
            or tonumber(record.StartedAt or 0) < tonumber(bestRecord.StartedAt or 0) then

                bestRecord =
                    record
            end
        end
    end

    if bestRecord then

        if bestRecord.Accepted == true then

            return SniperConfirmPendingBuyRecord(
                bestRecord,
                reason,
                petId
            )
        end

        bestRecord.InventorySeen =
            true

        bestRecord.InventoryReason =
            tostring(reason or "inventory seen")

        bestRecord.InventoryPetId =
            CleanText(petId)

        print(
            "[HOLY SNIPER]",
            "inventory seen, waiting for fast accept",
            "| pet:",
            tostring(petName),
            "| petId:",
            tostring(petId),
            "| reason:",
            tostring(reason)
        )

        return false
    end

    print(
        "[HOLY SNIPER]",
        "ignored confirm without pending buy",
        "| pet:",
        tostring(petName),
        "| petId:",
        tostring(petId),
        "| reason:",
        tostring(reason)
    )

    return false
end


function SniperTryAcceptPendingBuyRecord(record, reason)

    if type(record) ~= "table" then
        return false
    end

    if record.Confirmed == true
    or record.Accepted == true then
        return false
    end

    local hasShecklesDrop =
        record.ShecklesDropSeen == true
        or SniperState.RequireShecklesDrop ~= true

    local hasRefAccept =
        record.RefAcceptedSeen == true

    if hasShecklesDrop ~= true
    or hasRefAccept ~= true then

        return false
    end

    record.Accepted =
        true

    record.AcceptReason =
        tostring(reason or record.RefAcceptReason or record.ShecklesReason or "fast accepted")

    local key =
        CleanText(record.Key)

    if key ~= "" then

        SniperState.HandledWildPets[key] =
            os.clock()
            + (
                tonumber(SniperState.HandledPetCooldown)
                or 120
            )
    end

    SetSniperStatus(
        "Accepted: "
        .. tostring(record.PetName)
    )

    print(
        "[HOLY SNIPER]",
        "buy fast accepted",
        "| pet:",
        tostring(record.PetName),
        "| uuid:",
        tostring(record.UUID),
        "| reason:",
        tostring(record.AcceptReason),
        "| ref:",
        tostring(record.RefAcceptReason),
        "| sheckles:",
        tostring(record.StartedSheckles),
        "->",
        tostring(record.LowestShecklesSeen)
    )

    if record.InventorySeen == true then

        SniperConfirmPendingBuyRecord(
            record,
            record.InventoryReason or "inventory after fast accept",
            record.InventoryPetId
        )
    end

    return true
end

function SniperMarkPendingShecklesDropByKey(key, currentSheckles, reason)

    key =
        CleanText(key)

    if key == ""
    or type(SniperState.PendingWildPets) ~= "table" then

        return false
    end

    local record =
        SniperState.PendingWildPets[key]

    if type(record) ~= "table"
    or record.Confirmed == true then

        return false
    end

    currentSheckles =
        tonumber(currentSheckles)
        or SniperGetLeaderstatsSheckles()

    if not tonumber(record.StartedSheckles)
    or not tonumber(currentSheckles) then

        return false
    end

    record.LowestShecklesSeen =
        math.min(
            tonumber(record.LowestShecklesSeen)
            or record.StartedSheckles,
            currentSheckles
        )

    if currentSheckles >= record.StartedSheckles then
        return false
    end

    record.ShecklesDropSeen =
        true

    record.ShecklesReason =
        tostring(reason or "sheckles decreased")

    return SniperTryAcceptPendingBuyRecord(
        record,
        "sheckles + ref"
    )
end

function SniperMarkPendingAcceptedByKey(key, reason)

    key =
        CleanText(key)

    if key == ""
    or type(SniperState.PendingWildPets) ~= "table" then

        return false
    end

    local record =
        SniperState.PendingWildPets[key]

    if type(record) ~= "table"
    or record.Confirmed == true then

        return false
    end

    record.RefAcceptedSeen =
        true

    record.RefAcceptReason =
        tostring(reason or "wildpetref accepted")

    return SniperTryAcceptPendingBuyRecord(
        record,
        "ref + sheckles"
    )
end

function SniperWatchRefForBuyConfirm(key, ref)

    key =
        CleanText(key)

    if key == ""
    or typeof(ref) ~= "Instance"
    or ref.Parent == nil
    or type(SniperState.PendingWildPets) ~= "table" then

        return false
    end

    local record =
        SniperState.PendingWildPets[key]

    if type(record) ~= "table" then
        return false
    end

    record.RefConnections =
        type(record.RefConnections) == "table"
        and record.RefConnections
        or {}

    local function checkOwner()

        if typeof(ref) ~= "Instance"
        or ref.Parent == nil then
            return
        end

        local ownerUserId =
            tonumber(
                ref:GetAttribute("OwnerUserId")
            )
            or 0

        local ownerName =
            CleanText(
                ref:GetAttribute("OwnerName")
            )

        local state =
            CleanText(
                ref:GetAttribute("State")
            ):lower()

        if LOCAL_PLAYER
        and ownerUserId == LOCAL_PLAYER.UserId then

            SniperMarkPendingAcceptedByKey(
                key,
                "wildpetref ownerUserId"
            )

            return
        end

        if LOCAL_PLAYER
        and ownerName ~= ""
        and ownerName == LOCAL_PLAYER.Name then

            SniperMarkPendingAcceptedByKey(
                key,
                "wildpetref ownerName"
            )

            return
        end

        if state == "walking_to_garden"
        and LOCAL_PLAYER
        and ownerName ~= ""
        and ownerName == LOCAL_PLAYER.Name then

            SniperMarkPendingAcceptedByKey(
                key,
                "wildpetref walking_to_garden"
            )
        end
    end

    checkOwner()

    for _, attrName in ipairs({
        "OwnerUserId",
        "OwnerName",
        "State",
    }) do

        local ok, connection =
            pcall(function()

                return ref:GetAttributeChangedSignal(attrName):Connect(function()

                    checkOwner()
                end)
            end)

        if ok == true
        and connection then

            table.insert(
                record.RefConnections,
                connection
            )
        end
    end

    return true
end

function SniperGetToolPetName(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local attrNames = {
        "Pet",
        "PetName",
        "Name",
        "DisplayName",
    }

    for _, attrName in ipairs(attrNames) do

        local value =
            CleanText(
                tool:GetAttribute(attrName)
            )

        if value ~= "" then
            return value
        end
    end

    return CleanText(
        tool.Name
    )
end

function SniperAttachBuyConfirmToolContainer(container)

    if typeof(container) ~= "Instance" then
        return false
    end

    SniperState.BuyToolContainers =
        type(SniperState.BuyToolContainers) == "table"
        and SniperState.BuyToolContainers
        or {}

    if SniperState.BuyToolContainers[container] == true then
        return true
    end

    SniperState.BuyToolContainers[container] =
        true

    container.ChildAdded:Connect(function(child)

        if child:IsA("Tool") ~= true then
            return
        end

        local petName =
            SniperGetToolPetName(
                child
            )

        if petName == "" then
            return
        end

        SniperConfirmPendingBuyByPetName(
            petName,
            "tool added",
            CleanText(
                child:GetAttribute("PetId")
            )
        )
    end)

    return true
end

function SniperHandleReplicaSetForBuyConfirm(...)

    local args = {
        ...
    }

    for index, value in ipairs(args) do

        local path =
            nil

        local payload =
            nil

        if type(value) == "table" then

            if tostring(value[1]) == "Inventory"
            and tostring(value[2]) == "Pets" then

                path =
                    value

                payload =
                    args[index + 1]
            end
        end

        if path then

            local petName =
                ""

            if type(payload) == "table" then

                petName =
                    CleanText(
                        payload.Name
                        or payload.PetName
                        or payload.DisplayName
                    )
            end

            if petName ~= "" then

                SniperConfirmPendingBuyByPetName(
                    petName,
                    "replica inventory pet",
                    CleanText(
                        type(payload) == "table"
                        and (
                            payload.Id
                            or payload.ID
                            or path[3]
                        )
                        or path[3]
                    )
                )
            end
        end
    end
end

function SniperEnsureBuyConfirmationHooks()

    SniperState.BuyConfirmationHooksStarted =
        SniperState.BuyConfirmationHooksStarted == true

    if SniperState.BuyConfirmationHooksStarted ~= true then

        SniperState.BuyConfirmationHooksStarted =
            true

        local remoteEvents =
            ReplicatedStorage:FindFirstChild("RemoteEvents")

        local replicaSet =
            remoteEvents
            and remoteEvents:FindFirstChild("ReplicaSet")

        if replicaSet
        and replicaSet:IsA("RemoteEvent") then

            replicaSet.OnClientEvent:Connect(function(...)

                SniperHandleReplicaSetForBuyConfirm(
                    ...
                )
            end)
        end

        if LOCAL_PLAYER then

            LOCAL_PLAYER.CharacterAdded:Connect(function(character)

                SniperAttachBuyConfirmToolContainer(
                    character
                )
            end)

            LOCAL_PLAYER.ChildAdded:Connect(function(child)

                if child:IsA("Backpack") then

                    SniperAttachBuyConfirmToolContainer(
                        child
                    )
                end
            end)
        end
    end

    local backpack =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("Backpack")

    if backpack then

        SniperAttachBuyConfirmToolContainer(
            backpack
        )
    end

    if LOCAL_PLAYER
    and LOCAL_PLAYER.Character then

        SniperAttachBuyConfirmToolContainer(
            LOCAL_PLAYER.Character
        )
    end
end

local function SniperHoldCloseForServerValidation(moveState)

    local waitTime =
        math.clamp(
            tonumber(SniperState.BuyValidationHoldDelay)
            or 0.85,
            0.25,
            2
        )

    local started =
        os.clock()

    while os.clock() - started < waitTime do

        local _, root =
            SniperGetCharacterRoot()

        if root
        and typeof(moveState) == "table"
        and typeof(moveState.ClosePosition) == "Vector3" then

            local distanceFromBuyPoint =
                (root.Position - moveState.ClosePosition).Magnitude

            if distanceFromBuyPoint > 22 then
                break
            end
        end

        task.wait(
            0.05
        )
    end
end

function SniperGetPendingBuyRecordForEntry(entry)

    local key =
        SniperGetEntryKey(
            entry
        )

    if key == ""
    or type(SniperState.PendingWildPets) ~= "table" then
        return nil, key
    end

    local record =
        SniperState.PendingWildPets[key]

    if type(record) ~= "table" then
        return nil, key
    end

    return record,
        key
end

function SniperEntryAcceptedByLocal(entry)

    local record =
        SniperGetPendingBuyRecordForEntry(
            entry
        )

    if type(record) == "table"
    and (
        record.Accepted == true
        or record.Confirmed == true
    ) then

        return true
    end

    return false
end

function SniperFindEntryBuyPrompt(entry)

    local roots =
        {}

    local function addRoot(root)

        if typeof(root) == "Instance" then

            table.insert(
                roots,
                root
            )
        end
    end

    addRoot(
        entry
        and entry.Spawn
        or nil
    )

    addRoot(
        entry
        and entry.Instance
        or nil
    )

    if entry
    and CleanText(entry.UUID) ~= "" then

        addRoot(
            SniperFindSpawnByUuid(
                entry.UUID
            )
        )

        addRoot(
            SniperFindRef(
                entry.UUID
            )
        )
    end

    addRoot(
        entry
        and entry.Ref
        or nil
    )

    for _, root in ipairs(roots) do

        if root:IsA("ProximityPrompt") then
            return root
        end

        local scanned =
            0

        for _, descendant in ipairs(root:GetDescendants()) do

            scanned =
                scanned + 1

            if scanned > 400 then
                break
            end

            if descendant:IsA("ProximityPrompt") then

                local promptName =
                    CleanText(descendant.Name):lower()

                local actionText =
                    ""

                local objectText =
                    ""

                pcall(function()

                    actionText =
                        CleanText(descendant.ActionText):lower()

                    objectText =
                        CleanText(descendant.ObjectText):lower()
                end)

                if promptName:find("buy", 1, true)
                or actionText:find("buy", 1, true)
                or objectText:find("buy", 1, true) then

                    return descendant
                end
            end
        end
    end

    return nil
end

function SniperFollowCloseForBuy(entry, moveState, seconds)

    local started =
        os.clock()

    local limit =
        math.clamp(
            tonumber(seconds)
            or 1.25,
            0.15,
            8
        )

    local refreshDelay =
        math.clamp(
            tonumber(SniperState.FollowRefreshDelay)
            or 0.12,
            0.08,
            0.50
        )

    while os.clock() - started < limit do

        if SniperEntryAcceptedByLocal(entry) == true then
            return true
        end

        local targetPosition =
            SniperGetEntryTamePosition(
                entry
            )

        if typeof(targetPosition) ~= "Vector3" then

            task.wait(
                refreshDelay
            )

            continue
        end

        if SniperState.FollowPet == true then

            local _, closePosition =
                SniperGetSafeTameCFrame(
                    targetPosition
                )

            local character, root =
                SniperGetCharacterRoot()

            local humanoid =
                character
                and character:FindFirstChildOfClass("Humanoid")

            if typeof(closePosition) == "Vector3"
            and root
            and humanoid then

                local distanceToPet =
                    (root.Position - targetPosition).Magnitude

                local distanceToStand =
                    (root.Position - closePosition).Magnitude

                if distanceToPet > 9
                and distanceToStand > 5 then

                    humanoid:MoveTo(
                        closePosition
                    )

                else

                    SniperStopCharacterMotion(
                        root
                    )
                end

                if type(moveState) == "table" then

                    moveState.ClosePosition =
                        root.Position

                    moveState.TargetPosition =
                        targetPosition
                end
            end
        end

        SniperAimAtPetPosition(
            targetPosition
        )

        task.wait(
            refreshDelay
        )
    end

    if SniperState.FollowPet == true then

        local _, root =
            SniperGetCharacterRoot()

        if root then

            SniperStopCharacterMotion(
                root
            )
        end
    end

    return SniperEntryAcceptedByLocal(
        entry
    )
end


function SniperHoldEntryBuyPrompt(entry, moveState)

    local prompt =
        SniperFindEntryBuyPrompt(
            entry
        )

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then

        return false,
            "BuyPrompt missing"
    end

    local enabled =
        false

    pcall(function()

        enabled =
            prompt.Enabled == true
    end)

    if enabled ~= true then

        return false,
            "BuyPrompt disabled"
    end

    local holdTime =
        1.15

    pcall(function()

        holdTime =
            math.max(
                tonumber(prompt.HoldDuration)
                or 0,
                1
            )
            + 0.15
    end)

    SniperFollowCloseForBuy(
        entry,
        moveState,
        0.20
    )

    local beginOk =
        pcall(function()

            prompt:InputHoldBegin()
        end)

    if beginOk == true then

        local accepted =
            SniperFollowCloseForBuy(
                entry,
                moveState,
                holdTime
            )

        pcall(function()

            prompt:InputHoldEnd()
        end)

        return true,
            accepted == true
            and "held BuyPrompt accepted"
            or "held BuyPrompt"
    end

    local firePrompt =
        fireproximityprompt
        or (
            type(GAG2_EXECUTOR_ENV) == "table"
            and GAG2_EXECUTOR_ENV.fireproximityprompt
        )

    if type(firePrompt) == "function" then

        local fireOk, fireErr =
            pcall(function()

                firePrompt(
                    prompt,
                    holdTime
                )
            end)

        if fireOk ~= true then

            fireOk, fireErr =
                pcall(function()

                    firePrompt(
                        prompt
                    )
                end)
        end

        if fireOk == true then

            SniperFollowCloseForBuy(
                entry,
                moveState,
                0.35
            )

            return true,
                "fireproximityprompt BuyPrompt"
        end

        return false,
            tostring(fireErr)
    end

    return false,
        "prompt hold unsupported"
end

function SniperWaitForBuyAccepted(entry, seconds)

    local started =
        os.clock()

    local limit =
        math.clamp(
            tonumber(seconds)
            or 3.5,
            0.1,
            10
        )

    while os.clock() - started < limit do

        if SniperEntryAcceptedByLocal(entry) == true then
            return true
        end

        task.wait(
            0.08
        )
    end

    return SniperEntryAcceptedByLocal(
        entry
    )
end

function SniperWatchShecklesForBuyConfirm(key)

    key =
        CleanText(key)

    if key == ""
    or type(SniperState.PendingWildPets) ~= "table" then

        return false
    end

    local record =
        SniperState.PendingWildPets[key]

    if type(record) ~= "table" then
        return false
    end

    local valueObject =
        SniperGetLeaderstatsShecklesObject()

    if not valueObject then
        return false
    end

    local ok, connection =
        pcall(function()

            return valueObject:GetPropertyChangedSignal("Value"):Connect(function()

                SniperMarkPendingShecklesDropByKey(
                    key,
                    SniperGetLeaderstatsSheckles(),
                    "sheckles value changed"
                )
            end)
        end)

    if ok == true
    and connection then

        record.ShecklesConnection =
            connection

        SniperMarkPendingShecklesDropByKey(
            key,
            SniperGetLeaderstatsSheckles(),
            "sheckles initial check"
        )

        return true
    end

    return false
end


function SniperStartBuyConfirmation(entry)

    local key =
        SniperGetEntryKey(
            entry
        )

    if key == "" then
        return
    end

    SniperEnsureBuyConfirmationHooks()

    SniperState.PendingWildPets =
        type(SniperState.PendingWildPets) == "table"
        and SniperState.PendingWildPets
        or {}

    if type(SniperState.PendingWildPets[key]) == "table"
    and SniperState.PendingWildPets[key].Confirmed ~= true then

        return
    end

    local ref =
        entry
        and entry.Ref
        or nil

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        ref =
            SniperFindRef(
                entry
                and entry.UUID
                or ""
            )
    end

    local record = {
        Key =
            key,

        UUID =
            CleanText(
                entry
                and entry.UUID
                or ""
            ),

        PetName =
            CleanText(
                entry
                and entry.Name
                or "Unknown"
            ),

        StartedAt =
            os.clock(),

        StartedSheckles =
            tonumber(
                entry
                and entry._HolySniperStartedSheckles
            )
            or SniperGetLeaderstatsSheckles(),

        LowestShecklesSeen =
            tonumber(
                entry
                and entry._HolySniperStartedSheckles
            )
            or SniperGetLeaderstatsSheckles(),

        ShecklesDropSeen =
            false,

        ShecklesReason =
            "",

        RefAcceptedSeen =
            false,

        RefAcceptReason =
            "",

        Accepted =
            false,

        Confirmed =
            false,

        RefConnections =
            {},
    }

    SniperState.PendingWildPets[key] =
        record

    SniperState.ConfirmingBuy =
        true

    SniperState.ConfirmingBuyKey =
        key

    GAG2CancelServerHop(
        nil
    )

    SniperWatchRefForBuyConfirm(
        key,
        ref
    )

    SniperWatchShecklesForBuyConfirm(
        key
    )

    task.spawn(function()

        local timeout =
            math.clamp(
                tonumber(SniperState.ClaimWaitTimeout)
                or 90,
                20,
                180
            )

        local lastAcceptedStatusAt =
            0

        while os.clock() - record.StartedAt < timeout do

            if record.Confirmed == true then
                return
            end

            if record.Accepted ~= true then

                SniperMarkPendingShecklesDropByKey(
                    key,
                    SniperGetLeaderstatsSheckles(),
                    "sheckles backup poll"
                )
            end

            if record.Accepted == true
            and os.clock() - lastAcceptedStatusAt > 3 then

                lastAcceptedStatusAt =
                    os.clock()

                SetSniperStatus(
                    "Accepted, waiting inventory: "
                    .. tostring(record.PetName)
                )
            end

            task.wait(
                os.clock() - record.StartedAt < 2
                and 0.10
                or 0.25
            )
        end

        if record.Confirmed == true then
            return
        end

        SniperClearPendingBuyKey(
            key
        )

        SniperState.HandledWildPets[key] =
            nil

        if record.Accepted == true then

            SetSniperStatus(
                "Accepted but inventory not confirmed."
            )

        else

            SetSniperStatus(
                "Buy not accepted."
            )
        end

        warn(
            "[HOLY SNIPER]",
            "buy was not confirmed as owned",
            "| pet:",
            tostring(record.PetName),
            "| uuid:",
            tostring(record.UUID),
            "| accepted:",
            tostring(record.Accepted),
            "| reason:",
            tostring(record.AcceptReason or "none")
        )
    end)
end

function SniperFireWildBuyPacket(entry)

    if type(entry) ~= "table" then
        return false, "missing entry"
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid == "" then
        return false, "missing pet id"
    end

    local ref =
        entry.Ref

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        ref =
            SniperFindRef(
                uuid
            )
    end

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        return false,
            "missing pet ref"
    end

    local packet =
        SniperFindWildBuyPacket()

    if not packet then
        return false, SniperState.BuyPacketSource
    end

    local sourceText =
        tostring(SniperState.BuyPacketSource or ""):lower()

    if sourceText:find("wild", 1, true) == nil then

        SniperState.BuyPacket =
            nil

        return false,
            "blocked packet"
    end

    local okFire, err =
        pcall(function()

            packet:Fire(
                ref
            )
        end)

    if okFire ~= true then

        okFire, err =
            pcall(function()

                packet.Fire(
                    packet,
                    ref
                )
            end)
    end

    if okFire ~= true then

        warn(
            "[HOLY SNIPER]",
            "buy fire failed",
            "| pet:",
            tostring(entry.Name),
            "| uuid:",
            tostring(uuid),
            "| ref:",
            PathOf(ref),
            "| packet:",
            tostring(SniperState.BuyPacketSource),
            "| err:",
            tostring(err)
        )

        return false, tostring(err)
    end

    print(
        "[HOLY SNIPER]",
        "buy fired",
        "| pet:",
        tostring(entry.Name),
        "| uuid:",
        tostring(uuid),
        "| ref:",
        PathOf(ref),
        "| packet:",
        tostring(SniperState.BuyPacketSource)
    )

    return true, "fired"
end

function SniperAttemptBuyEntry(entry)

    if type(entry) ~= "table" then
        return false
    end

    local readyToBuy, readyText =
        SniperReadyToBuy()

    if readyToBuy ~= true then

        SetSniperStatus(
            readyText
        )

        return false
    end

    local attemptKey =
        ""

    if type(SniperGetEntryKey) == "function" then

        attemptKey =
            SniperGetEntryKey(
                entry
            )
    end

    if attemptKey == "" then

        attemptKey =
            CleanText(entry.UUID)

        if attemptKey == "" then

            attemptKey =
                tostring(entry.Name or "unknown")
        end
    end

    if type(SniperState.PendingWildPets) == "table" then

        local pending =
            SniperState.PendingWildPets[attemptKey]

        if type(pending) == "table"
        and pending.Confirmed ~= true then

            SetSniperStatus(
                "Already pending: "
                .. tostring(entry.Name)
            )

            return false
        end

        if pending == true then

            SetSniperStatus(
                "Already pending: "
                .. tostring(entry.Name)
            )

            return false
        end
    end

    if SniperIsEntryHandled(entry) == true then
        return false
    end

    local lastAttempt =
        tonumber(
            SniperState.RecentTameAttempts[attemptKey]
        )
        or 0

    if os.clock() - lastAttempt < 1.25 then
        return false
    end

    SniperState.LastTameAt =
        os.clock()

    SniperState.RecentTameAttempts[attemptKey] =
        os.clock()

    SetSniperStatus(
        "Buying "
        .. tostring(entry.Name)
        .. " | "
        .. SniperGetMovementMode()
        .. " + "
        .. SniperGetBuyMode()
    )

    task.spawn(function()

        local okTask, taskError =
            xpcall(
                function()

                    SniperState.Taming =
                        true

                    local moveState, moveInfo =
                        SniperMoveToBuyPosition(
                            entry
                        )

                    if not moveState then

                        SetSniperStatus(
                            "Move failed."
                        )

                        warn(
                            "[HOLY SNIPER]",
                            "move failed",
                            "| pet:",
                            tostring(entry.Name),
                            "| info:",
                            tostring(moveInfo)
                        )

                        return
                    end

                    local targetPosition =
                        SniperGetEntryTamePosition(
                            entry
                        )

                    if typeof(targetPosition) == "Vector3" then

                        SniperAimAtPetPosition(
                            targetPosition
                        )
                    end

                    task.wait(
                        0.08
                    )

                    local startedSheckles =
                        SniperGetLeaderstatsSheckles()

                    entry._HolySniperStartedSheckles =
                        startedSheckles

                    local okBuy =
                        false

                    local info =
                        "not fired"

                    if SniperGetBuyMode() == "Hold" then

                        okBuy, info =
                            SniperHoldEntryBuyPrompt(
                                entry,
                                moveState
                            )

                    else

                        okBuy, info =
                            SniperFireWildBuyPacket(
                                entry
                            )
                    end

                    if okBuy == true then

                        SetSniperStatus(
                            "Buy request sent. Verifying Sheckles: "
                            .. tostring(entry.Name)
                        )

                        SniperStartBuyConfirmation(
                            entry
                        )

                        SniperHoldCloseForServerValidation(
                            moveState
                        )

                        SniperRestoreAfterTame(
                            moveState
                        )

                    else

                        SniperRestoreAfterTame(
                            moveState
                        )

                        SetSniperStatus(
                            "Buy failed."
                        )

                        warn(
                            "[HOLY SNIPER]",
                            "buy failed",
                            "| pet:",
                            tostring(entry.Name),
                            "| info:",
                            tostring(info),
                            "| move:",
                            tostring(moveInfo)
                        )
                    end
                end,

                function(errorValue)

                    local errorText =
                        tostring(errorValue or "unknown error")

                    if type(debug) == "table"
                    and type(debug.traceback) == "function" then

                        local traceOk, trace =
                            pcall(
                                debug.traceback,
                                errorText,
                                2
                            )

                        if traceOk == true
                        and type(trace) == "string"
                        and trace ~= "" then

                            return trace
                        end
                    end

                    return errorText
                end
            )

        SniperState.Taming =
            false

        if okTask ~= true then

            SetSniperStatus(
                "Buy task error. Check console."
            )

            warn(
                "[HOLY SNIPER]",
                "buy task error",
                tostring(taskError)
            )
        end
    end)

    return true
end
local function SniperGetDropdownPetNames()

    local names =
        {}

    local function add(name)

        name =
            CleanText(name)

        if name == "" then
            return
        end

        if table.find(names, name) ~= nil then
            return
        end

        table.insert(
            names,
            name
        )
    end

    for _, selectedName in ipairs(SniperState.Targets or {}) do
        add(selectedName)
    end

    for _, registryName in ipairs(SniperGetRegistryPetNames()) do
        add(registryName)
    end

    if #names <= 0 then

        for _, knownName in ipairs(SniperState.KnownPetNames or {}) do
            add(knownName)
        end

        local folder =
            SniperGetSpawnsFolder()

        if folder then

            for _, child in ipairs(folder:GetChildren()) do

                if child.Name:find("WildPet", 1, true) then

                    add(
                        SniperGetPetName(child)
                    )
                end
            end
        end
    end

    table.sort(
        names
    )

    return names
end

local function SniperRefreshTargetDropdown()

    if not SniperTargetDropdown then
        return
    end

    if SniperDropdownRefreshing == true then
        return
    end

    SniperDropdownRefreshing =
        true

    local values =
        SniperGetDropdownPetNames()

    pcall(function()

        if type(SniperTargetDropdown.SetValues) == "function" then

            SniperTargetDropdown:SetValues(
                values
            )

        elseif type(SniperTargetDropdown.SetItems) == "function" then

            SniperTargetDropdown:SetItems(
                values
            )
        end
    end)

    SniperDropdownRefreshing =
        false
end

function SniperPriorityCleanValue(value)

    value =
        CleanText(value)

    if value == ""
    or value == "None"
    or value == "-" then
        return ""
    end

    return value
end

function SniperGetPriorityDropdownValues()

    local values = {
        "None",
    }

    local function add(name)

        name =
            SniperPriorityCleanValue(
                name
            )

        if name == "" then
            return
        end

        if table.find(values, name) ~= nil then
            return
        end

        table.insert(
            values,
            name
        )
    end

    for _, selectedName in ipairs(SniperState.Targets or {}) do

        add(
            selectedName
        )
    end

    for _, registryName in ipairs(SniperGetRegistryPetNames()) do

        add(
            registryName
        )
    end

    table.sort(values, function(a, b)

        if a == "None" then
            return true
        end

        if b == "None" then
            return false
        end

        return tostring(a) < tostring(b)
    end)

    return values
end

function SniperSetPriorityPet(slot, value)

    slot =
        tonumber(slot)

    if not slot
    or slot < 1
    or slot > 5 then
        return
    end

    SniperState.PriorityPets =
        SniperState.PriorityPets
        or {
            "",
            "",
            "",
            "",
            "",
        }

    SniperState.PriorityPets[slot] =
        SniperPriorityCleanValue(
            value
        )

    MarkConfigDirty()
end

function SniperGetPriorityRank(petName)

    local petKey =
        SniperNormalizeName(
            petName
        )

    if petKey == "" then
        return 999
    end

    for index = 1, 5 do

        local priorityName =
            SniperState.PriorityPets
            and SniperState.PriorityPets[index]
            or ""

        local priorityKey =
            SniperNormalizeName(
                priorityName
            )

        if priorityKey ~= ""
        and petKey == priorityKey then
            return index
        end
    end

    return 999
end

function SniperGetEntryDistanceValue(entry)

    if type(entry) ~= "table" then
        return math.huge
    end

    local position =
        entry.Position

    if typeof(position) ~= "Vector3" then
        return math.huge
    end

    local character =
        LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return math.huge
    end

    return (root.Position - position).Magnitude
end

GAG2_SNIPER_SIZE_CLASS_VALUES = {
    "Any Size",
    "Big+",
    "Huge Only",
}

function SniperSizeClassValues()

    return {
        "Any Size",
        "Big+",
        "Huge Only",
    }
end

function SniperCleanSizeClass(value)

    value =
        CleanText(value)

    if value == "Big+" then
        return "Big+"
    end

    if value == "Huge Only"
    or value == "Huge" then
        return "Huge Only"
    end

    return "Any Size"
end

function SniperSetSizeClass(value)

    SniperState.SizeClass =
        SniperCleanSizeClass(
            value
        )

    MarkConfigDirty()
end

function SniperSizeClassText()

    return SniperCleanSizeClass(
        SniperState.SizeClass
    )
end

function SniperReadSizeMetric(instance)

    if typeof(instance) ~= "Instance" then
        return 0
    end

    if instance:IsA("Model") then

        local ok, size =
            pcall(function()

                return instance:GetExtentsSize()
            end)

        if ok == true
        and typeof(size) == "Vector3"
        and size.Magnitude > 0 then

            return size.Magnitude
        end
    end

    if instance:IsA("BasePart") then

        return instance.Size.Magnitude
    end

    local rootPart =
        instance:FindFirstChild("RootPart", true)
        or instance:FindFirstChildWhichIsA("BasePart", true)

    if rootPart
    and rootPart:IsA("BasePart") then

        return rootPart.Size.Magnitude
    end

    return 0
end

function SniperSizeBaselineKey(petName)

    return SniperNormalizeName(
        petName
    )
end

function SniperRefreshSizeBaselines(entries)

    SniperState.SizeBaselines =
        type(SniperState.SizeBaselines) == "table"
        and SniperState.SizeBaselines
        or {}

    for _, entry in ipairs(entries or {}) do

        local key =
            SniperSizeBaselineKey(
                entry and entry.Name
            )

        local metric =
            tonumber(
                entry and entry.SizeMetric
            )
            or 0

        if key ~= ""
        and metric > 0 then

            local current =
                tonumber(
                    SniperState.SizeBaselines[key]
                )

            if not current
            or current <= 0
            or metric < current then

                SniperState.SizeBaselines[key] =
                    metric
            end
        end
    end
end

function SniperApplyEntrySizeClass(entry)

    if type(entry) ~= "table" then
        return "Any Size", 1
    end

    local key =
        SniperSizeBaselineKey(
            entry.Name
        )

    local metric =
        tonumber(entry.SizeMetric)
        or 0

    local baseline =
        key ~= ""
        and tonumber(
            SniperState.SizeBaselines
            and SniperState.SizeBaselines[key]
        )
        or nil

    local ratio =
        1

    if metric > 0
    and baseline
    and baseline > 0 then

        ratio =
            metric / baseline
    end

    local label =
        "Any Size"

    local score =
        1

    if ratio >= 1.55 then

        label =
            "Huge"

        score =
            3

    elseif ratio >= 1.25 then

        label =
            "Big+"

        score =
            2
    end

    entry.SizeClass =
        label

    entry.SizeScore =
        score

    return label,
        score
end

function SniperEntryMatchesSizeClass(entry)

    local wanted =
        SniperSizeClassText()

    if wanted == "Any Size" then
        return true
    end

    if type(entry) ~= "table" then
        return false
    end

    if entry.SizeClass == nil
    or entry.SizeScore == nil then

        SniperApplyEntrySizeClass(
            entry
        )
    end

    local score =
        tonumber(entry.SizeScore)
        or 1

    if wanted == "Big+" then
        return score >= 2
    end

    if wanted == "Huge Only" then
        return score >= 3
    end

    return true
end

function SniperEntryDisplayName(entry)

    if type(entry) ~= "table" then
        return "Unknown"
    end

    local name =
        CleanText(entry.Name)

    if name == "" then
        name =
            "Unknown"
    end

    local score =
        tonumber(entry.SizeScore)
        or 1

    if score >= 3 then

        return "Huge "
            .. name
    end

    if score >= 2 then

        return "Big "
            .. name
    end

    return name
end

function SniperEntrySizeText(entry)

    if type(entry) ~= "table" then
        return "Any Size"
    end

    if entry.SizeClass == nil then

        SniperApplyEntrySizeClass(
            entry
        )
    end

    return CleanText(entry.SizeClass) ~= ""
        and CleanText(entry.SizeClass)
        or "Any Size"
end

function SniperSortMatches(matches)

    if type(matches) ~= "table" then
        return
    end

    table.sort(matches, function(a, b)

        local aRank =
            SniperGetPriorityRank(
                a and a.Name
            )

        local bRank =
            SniperGetPriorityRank(
                b and b.Name
            )

        if aRank ~= bRank then
            return aRank < bRank
        end

        local aDistance =
            SniperGetEntryDistanceValue(
                a
            )

        local bDistance =
            SniperGetEntryDistanceValue(
                b
            )

        if aDistance ~= bDistance then
            return aDistance < bDistance
        end

        return tostring(a and a.Name or "")
            < tostring(b and b.Name or "")
    end)
end

function SniperPriorityText()

    local rows =
        {}

    for index = 1, 5 do

        local value =
            SniperPriorityCleanValue(
                SniperState.PriorityPets
                and SniperState.PriorityPets[index]
                or ""
            )

        if value ~= "" then

            table.insert(
                rows,
                tostring(index)
                .. ". "
                .. value
            )
        end
    end

    if #rows <= 0 then
        return "None"
    end

    return table.concat(
        rows,
        " > "
    )
end

function SniperRefreshPriorityDropdowns()

    if SniperPriorityRefreshing == true then
        return
    end

    SniperPriorityRefreshing =
        true

    local values =
        SniperGetPriorityDropdownValues()

    for index = 1, 5 do

        local dropdown =
            SniperPriorityDropdowns
            and SniperPriorityDropdowns[index]

        if dropdown then

            pcall(function()

                if type(dropdown.SetValues) == "function" then

                    dropdown:SetValues(
                        values
                    )

                elseif type(dropdown.SetItems) == "function" then

                    dropdown:SetItems(
                        values
                    )
                end
            end)
        end
    end

    SniperPriorityRefreshing =
        false
end

local function SniperGetActiveEntries()

    local spawnFolder =
        SniperGetSpawnsFolder()

    local refFolder =
        SniperGetRefFolder()

    local entries =
        {}

    local usedKeys =
        {}

    local function addEntry(spawn, ref, fallbackUuid)

        local uuid =
            CleanText(fallbackUuid)

        if uuid == ""
        and typeof(spawn) == "Instance" then

            uuid =
                SniperGetUuid(
                    spawn.Name
                )
        end

        if uuid == ""
        and typeof(ref) == "Instance" then

            uuid =
                SniperGetUuid(
                    ref.Name
                )
        end

        local key =
            uuid

        if key == "" then

            key =
                typeof(spawn) == "Instance"
                and PathOf(spawn)
                or PathOf(ref)
        end

        if key == ""
        or usedKeys[key] == true then
            return
        end

        local petName =
            "Unknown"

        if typeof(spawn) == "Instance" then

            petName =
                SniperGetPetName(
                    spawn
                )
        end

        if (
            petName == ""
            or petName == "Unknown"
            or petName:match("^WildPet[%s_]")
        )
        and typeof(ref) == "Instance" then

            local refName =
                SniperGetPetName(
                    ref
                )

            if refName ~= ""
            and refName ~= "Unknown"
            and not refName:match("^WildPet[%s_]") then

                petName =
                    refName
            end
        end

        if petName == ""
        or petName == "Unknown" then
            return
        end

        local position =
            nil

        if typeof(spawn) == "Instance" then

            position =
                SniperGetPosition(
                    spawn
                )
        end

        if typeof(position) ~= "Vector3"
        and typeof(ref) == "Instance" then

            position =
                SniperGetPosition(
                    ref
                )
        end

        usedKeys[key] =
            true

        local textRows =
            SniperBuildTextRows(
                spawn,
                ref
            )

        local timerText =
            SniperGetEntryTimer(
                spawn,
                ref,
                textRows
            )

        local priceText =
            SniperGetEntryPrice(
                spawn,
                ref,
                textRows
            )

        SniperRememberPetName(
            petName
        )

        local sizeMetric =
            SniperReadSizeMetric(
                spawn or ref
            )

        table.insert(entries, {
            Instance = spawn or ref,
            Spawn = spawn,
            Name = petName,
            Key = SniperNormalizeName(petName),
            UUID = uuid,
            Ref = ref,
            Position = position,
            Distance = SniperDistanceText(position),
            Timer = timerText,
            Price = priceText,
            SizeMetric = sizeMetric,
            SizeClass = "Any Size",
            SizeScore = 1,
            Path = PathOf(spawn or ref),
        })
    end

    if spawnFolder then

        for _, child in ipairs(spawnFolder:GetChildren()) do

            if child.Name:find("WildPet", 1, true) then

                local uuid =
                    SniperGetUuid(
                        child.Name
                    )

                local ref =
                    uuid ~= ""
                    and SniperFindRef(
                        uuid
                    )
                    or nil

                addEntry(
                    child,
                    ref,
                    uuid
                )
            end
        end
    end

    if refFolder then

        for _, ref in ipairs(refFolder:GetChildren()) do

            if ref.Name:find("WildPet", 1, true) then

                local uuid =
                    SniperGetUuid(
                        ref.Name
                    )

                local spawn =
                    uuid ~= ""
                    and SniperFindSpawnByUuid(
                        uuid
                    )
                    or nil

                addEntry(
                    spawn,
                    ref,
                    uuid
                )
            end
        end
    end

    SniperRefreshSizeBaselines(
        entries
    )

    for _, entry in ipairs(entries) do

        SniperApplyEntrySizeClass(
            entry
        )
    end

    table.sort(entries, function(a, b)

        local aPosition =
            a.Position

        local bPosition =
            b.Position

        local character =
            LOCAL_PLAYER.Character

        local root =
            character
            and character:FindFirstChild("HumanoidRootPart")

        if root
        and typeof(aPosition) == "Vector3"
        and typeof(bPosition) == "Vector3" then

            return (root.Position - aPosition).Magnitude
                < (root.Position - bPosition).Magnitude
        end

        if typeof(aPosition) == "Vector3"
        and typeof(bPosition) ~= "Vector3" then
            return true
        end

        if typeof(aPosition) ~= "Vector3"
        and typeof(bPosition) == "Vector3" then
            return false
        end

        return tostring(a.Name) < tostring(b.Name)
    end)

    if not spawnFolder
    and not refFolder then
        return entries, "missing wild pet data"
    end

    return entries, "ok"
end

local function SniperEntryMatchesTargets(entry, targets)

    if type(entry) ~= "table"
    or type(targets) ~= "table" then
        return false
    end

    local petKey =
        SniperNormalizeName(entry.Name)

    if petKey == "" then
        return false
    end

    for targetKey in pairs(targets) do

        if targetKey ~= ""
        and (
            petKey == targetKey
            or petKey:find(targetKey, 1, true) ~= nil
            or targetKey:find(petKey, 1, true) ~= nil
        ) then

            return true
        end
    end

    return false
end

function SniperBuildMatchText(entries, matches, orderedTargets, reason)

    local lines = {
        '<font color="rgb(196,181,253)"><b>Selected Targets</b></font>',
        SniperTargetsText(),
        "",
        '<font color="rgb(196,181,253)"><b>Size Class</b></font>',
        SniperSizeClassText(),
        "",
        '<font color="rgb(196,181,253)"><b>Priority</b></font>',
        SniperPriorityText(),
        "",
        '<font color="rgb(196,181,253)"><b>Result</b></font>',
    }

    if reason ~= "ok" then

        table.insert(
            lines,
            "Waiting for pets..."
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    if #orderedTargets <= 0 then

        table.insert(
            lines,
            "Select target pets first."
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    if #matches <= 0 then

        table.insert(
            lines,
            "No target found."
        )

        table.insert(
            lines,
            "Active pets: " .. tostring(#entries)
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    table.insert(
        lines,
        "Target found."
    )

    for index, entry in ipairs(matches) do

        if index > 6 then

            table.insert(
                lines,
                "+" .. tostring(#matches - 6) .. " more"
            )

            break
        end

        table.insert(
            lines,
            tostring(index)
            .. ". "
            .. SniperEntryDisplayName(entry)
            .. " | "
            .. SniperEntrySizeText(entry)
            .. " | Time: "
            .. tostring(entry.Timer or "?")
            .. " | Price: "
            .. tostring(entry.Price or "?")
            .. " | "
            .. tostring(entry.Distance)
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

function SniperShouldWaitForMiddleFarm()

    local middleState =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if type(middleState) ~= "table" then
        return false
    end

    local autoMiddleEnabled =
        false

    if Toggles.HolyGAG2AutoTpMiddleFarm then

        autoMiddleEnabled =
            Toggles.HolyGAG2AutoTpMiddleFarm.Value == true
    end

    if autoMiddleEnabled ~= true then

        middleState.SniperWaitActive =
            false

        return false
    end

    local mode =
        "Teleport"

    if type(GAG2MiddleFarmGetMovementMode) == "function" then

        mode =
            GAG2MiddleFarmGetMovementMode()

    else

        mode =
            CleanText(
                middleState.MovementMode
            )
    end

    if mode ~= "Walk" then

        middleState.SniperWaitActive =
            false

        return false
    end

    if middleState.MovedOnce == true
    or middleState.MiddleReady == true then

        middleState.MiddleReady =
            true

        middleState.SniperWaitActive =
            false

        return false
    end

    if middleState.Moving ~= true then

        local now =
            os.clock()

        if now - tonumber(middleState.LastSniperMiddleStartAt or 0) >= 2 then

            middleState.LastSniperMiddleStartAt =
                now

            if type(GAG2StartAutoTpMiddleFarm) == "function" then

                GAG2StartAutoTpMiddleFarm(
                    "sniper wait"
                )
            end
        end
    end

    SniperState.LastHopAt =
        os.clock()

    middleState.SniperWaitActive =
        true

    SetSniperStatus(
        "Waiting for Auto Middle Farm walk..."
    )

    GAG2SetPanicHudStatus(
        "MIDDLE FARM"
    )

    return true
end


function SniperScan(allowAutoHop)

    SniperState.LastScanAt =
        os.clock()

    if SniperShouldWaitForMiddleFarm() == true then

        return {}
    end

    local targets, orderedTargets =
        SniperBuildTargets()

    local entries, reason =
        SniperGetActiveEntries()

    local matches =
        {}

    for _, entry in ipairs(entries) do

        if SniperIsEntryHandled(entry) ~= true
        and SniperEntryMatchesTargets(entry, targets) == true
        and SniperEntryMatchesSizeClass(entry) == true then

            table.insert(
                matches,
                entry
            )
        end
    end

        SniperSortMatches(
        matches
    )

    SniperState.LastMatchCount =
        #matches

    SniperState.LastMatchText =
        SniperBuildMatchText(
            entries,
            matches,
            orderedTargets,
            reason
        )

    RefreshSniperLabels()

    if reason ~= "ok" then

        SetSniperStatus(
            "Waiting for pets..."
        )

        return matches
    end

    if #orderedTargets <= 0 then

        SetSniperStatus(
            "Select target pets."
        )

        return matches
    end

    if SniperState.WaitingForClaim == true then

        SniperState.WaitingForClaim =
            false

        SniperState.WaitingForClaimKey =
            ""
    end

    if SniperHasPendingBuy() == true then

        GAG2CancelServerHop(
            nil
        )
    end

    if #matches > 0 then

        GAG2CancelServerHop(
            nil
        )

        SetSniperStatus(
            "Found: "
            .. SniperEntryDisplayName(
                matches[1]
            )
        )

        if allowAutoHop == true
        and SniperState.Enabled == true then

            local readyToBuy, readyText =
                SniperReadyToBuy()

            if readyToBuy == true then

                if SniperState.Taming == true then

                    SetSniperStatus(
                        "Buying in progress..."
                    )

                elseif type(SniperHasUnacceptedPendingBuy) == "function"
                and SniperHasUnacceptedPendingBuy() == true then

                    SetSniperStatus(
                        "Waiting for buy acceptance..."
                    )

                else

                    SniperAttemptBuyEntry(
                        matches[1]
                    )
                end

            else

                SetSniperStatus(
                    readyText
                )
            end
        end

        return matches
    end

    SetSniperStatus(
        "No target found."
    )

    local hasHandledActiveTarget =
        false

    for _, entry in ipairs(entries) do

        if SniperIsEntryHandled(entry) == true
        and SniperEntryMatchesTargets(entry, targets) == true then

            hasHandledActiveTarget =
                true

            break
        end
    end

    if allowAutoHop == true
    and SniperState.AutoHop == true
    and SniperState.Enabled == true
    and SniperState.Taming ~= true
    and SniperHasPendingBuy() ~= true
    and hasHandledActiveTarget ~= true
    and SniperReadyToHop() == true then

        local hopDelay =
            math.clamp(
                tonumber(SniperState.HopDelay)
                or 20,
                5,
                120
            )

        local sinceHop =
            os.clock() - tonumber(SniperState.LastHopAt or 0)

        if sinceHop < hopDelay then

            local remaining =
                math.max(
                    1,
                    math.ceil(
                        hopDelay - sinceHop
                    )
                )

            SetSniperStatus(
                "No target found. Hop in "
                .. tostring(remaining)
                .. "s"
            )

            GAG2SetPanicHudStatus(
                "STOP? "
                .. tostring(remaining)
                .. "s"
            )

            return matches
        end

        SniperState.LastHopAt =
            os.clock()

        SetSniperStatus(
            "No target found. Hopping..."
        )

        GAG2SetPanicHudStatus(
            "STOP / HOPPING"
        )

        HopServerOnce()
    end

    return matches
end

function SniperStartLoop()

    if SniperState.Running == true then
        return
    end

    SniperState.Running =
        true

    task.spawn(function()

        SetSniperStatus(
            "Sniper scanner started."
        )

        while SniperState.Enabled == true do

            SniperScan(
                true
            )

            task.wait(
                math.clamp(
                    tonumber(SniperState.ScanDelay)
                    or 0.5,
                    0.2,
                    3
                )
            )
        end

        SniperState.Running =
            false

        SetSniperStatus(
            "Sniper scanner stopped."
        )
    end)
end

function SniperSetEnabled(value)

    SniperState.Enabled =
        value == true

    if SniperState.Enabled == true then

        SniperState.EnabledAt =
            os.clock()

        SniperState.InstantFirstHop =
            false

        SniperState.FirstHopUsed =
            true

        SniperState.LastHopAt =
            os.clock()

        if SniperState.AutoHop == true then

            GAG2SetPanicHudStatus(
                "STOP READY"
            )

        else

            GAG2SetPanicHudStatus(
                "Sniper ON"
            )
        end

        GAG2_SERVER_HOP_RETRYING =
            false

        GAG2_SERVER_HOP_ATTEMPT =
            0

        SniperState.FirstHopUsed =
            false

        SniperScan(
            false
        )

        MarkConfigDirty()

        SniperStartLoop()

    else

        GAG2_SERVER_HOP_RETRYING =
            false

        GAG2_SERVER_HOP_ATTEMPT =
            0

        SniperState.FirstHopUsed =
            false

        SniperState.EnabledAt =
            0

        GAG2SetPanicHudStatus(
            "Sniper OFF"
        )

        SetSniperStatus(
            "Sniper disabled."
        )

        MarkConfigDirty()
    end
end

function GAG2SetSniperToggleValue(value)

    if GAG2_SNIPER_TOGGLE_CONTROL
    and type(GAG2_SNIPER_TOGGLE_CONTROL.SetValue) == "function" then

        pcall(function()

            GAG2_SNIPER_TOGGLE_CONTROL:SetValue(
                value == true
            )
        end)

        return
    end

    if Toggles.HolyGAG2SniperEnabled
    and type(Toggles.HolyGAG2SniperEnabled.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2SniperEnabled:SetValue(
                value == true
            )
        end)

        return
    end

    SniperSetEnabled(
        value == true
    )
end

function StopGAG2SniperNow(reason)

    if GAG2_SNIPER_STOPPING == true then
        return
    end

    GAG2_SNIPER_STOPPING =
        true

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    SniperState.Enabled =
        false

    SniperState.Running =
        false

    SniperState.FirstHopUsed =
        false

    SetSniperStatus(
        tostring(reason or "Sniper stopped.")
    )

    GAG2SetSniperToggleValue(
        false
    )

    MarkConfigDirty()

    GAG2_SNIPER_STOPPING =
        false
end

getgenv().HOLY_GAG2_STOP_SNIPER =
    StopGAG2SniperNow

function GAG2DestroyPanicHud()

    if GAG2_PANIC_HUD_GUI then

        pcall(function()

            GAG2_PANIC_HUD_GUI:Destroy()
        end)
    end

    GAG2_PANIC_HUD_GUI =
        nil

    GAG2_PANIC_HUD_STATUS =
        nil

    GAG2_PANIC_HUD_CREATED =
        false
end

function GAG2SetPanicHudEnabled(value)

    GAG2_PANIC_HUD_ENABLED =
        value == true

    if GAG2_PANIC_HUD_ENABLED == true then

        if type(GAG2CreatePanicHud) == "function" then

            GAG2CreatePanicHud()
        end

        GAG2SetPanicHudStatus(
            "Ready."
        )

    else

        GAG2DestroyPanicHud()
    end

    MarkConfigDirty()
end

function GAG2SetPanicHudStatus(text)

    if GAG2_PANIC_HUD_ENABLED ~= true then
        return
    end

    if (
        GAG2_PANIC_HUD_GUI == nil
        or GAG2_PANIC_HUD_STATUS == nil
    )
    and type(GAG2CreatePanicHud) == "function" then

        GAG2CreatePanicHud()
    end

    if GAG2_PANIC_HUD_STATUS then

        pcall(function()

            GAG2_PANIC_HUD_STATUS.Text =
                tostring(text or "Ready.")
        end)
    end
end

function GAG2PanicStopNow(reason)

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    if type(SniperState) == "table" then

        SniperState.Enabled =
            false

        SniperState.Running =
            false

        SniperState.AutoHop =
            false

        SniperState.InstantFirstHop =
            false

        SniperState.FirstHopUsed =
            false

        SniperState.EnabledAt =
            0

        SniperState.Taming =
            false

        SniperState.ConfirmingBuy =
            false

        SniperState.ConfirmingBuyKey =
            ""
    end

    if GAG2_SNIPER_TOGGLE_CONTROL
    and type(GAG2_SNIPER_TOGGLE_CONTROL.SetValue) == "function" then

        pcall(function()

            GAG2_SNIPER_TOGGLE_CONTROL:SetValue(
                false
            )
        end)
    end

    if Toggles.HolyGAG2SniperAutoHop
    and type(Toggles.HolyGAG2SniperAutoHop.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2SniperAutoHop:SetValue(
                false
            )
        end)
    end

    if Toggles.HolyGAG2SniperInstantFirstHop
    and type(Toggles.HolyGAG2SniperInstantFirstHop.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2SniperInstantFirstHop:SetValue(
                false
            )
        end)
    end

    SetSniperStatus(
        tostring(reason or "Emergency stopped.")
    )

    SetStatus(
        "Emergency stopped."
    )

    GAG2SetPanicHudStatus(
        "STOPPED"
    )

    MarkConfigDirty()

    pcall(function()

        SaveManager:Save(
            ConfigState.AutosaveName
        )
    end)
end

getgenv().HOLY_GAG2_PANIC_STOP =
    GAG2PanicStopNow

function GAG2CreatePanicHud()

    if GAG2_PANIC_HUD_ENABLED ~= true then
        return nil
    end

    if GAG2_PANIC_HUD_GUI then
        return GAG2_PANIC_HUD_GUI
    end

    local parent =
        CoreGui

    if not parent then

        parent =
            LOCAL_PLAYER
            and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
            or nil
    end

    if not parent then
        return nil
    end

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "HolyGAG2PanicHud"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    gui.Parent =
        parent

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Frame"

    frame.Position =
        UDim2.fromOffset(
            14,
            155
        )

    frame.Size =
        UDim2.fromOffset(
            174,
            92
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(9, 7, 15)

    frame.BorderSizePixel =
        0

    frame.Active =
        true

    frame.Draggable =
        true

    frame.Parent =
        gui

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 8)

    corner.Parent =
        frame

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(248, 113, 113)

    stroke.Thickness =
        1

    stroke.Transparency =
        0.05

    stroke.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(
            8,
            4
        )

    title.Size =
        UDim2.fromOffset(
            158,
            18
        )

    title.Font =
        Enum.Font.Code

    title.TextSize =
        12

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    title.Text =
        "Sniper"

    title.Parent =
        frame

    local stop =
        Instance.new("TextButton")

    stop.Name =
        "Stop"

    stop.Position =
        UDim2.fromOffset(
            8,
            26
        )

    stop.Size =
        UDim2.fromOffset(
            158,
            32
        )

    stop.BackgroundColor3 =
        Color3.fromRGB(127, 29, 29)

    stop.BorderSizePixel =
        0

    stop.Font =
        Enum.Font.Code

    stop.TextSize =
        18

    stop.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    stop.Text =
        "STOP"

    stop.Parent =
        frame

    local stopCorner =
        Instance.new("UICorner")

    stopCorner.CornerRadius =
        UDim.new(0, 6)

    stopCorner.Parent =
        stop

    stop.MouseButton1Click:Connect(function()

        GAG2PanicStopNow(
            "Emergency stopped."
        )

        Notify(
            "Safety",
            "Sniper and auto-hop stopped.",
            3
        )
    end)

    local status =
        Instance.new("TextLabel")

    status.Name =
        "Status"

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(
            8,
            62
        )

    status.Size =
        UDim2.fromOffset(
            158,
            20
        )

    status.Font =
        Enum.Font.Code

    status.TextSize =
        11

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    status.Text =
        "Ready."

    status.Parent =
        frame

    GAG2_PANIC_HUD_GUI =
        gui

    GAG2_PANIC_HUD_STATUS =
        status

    GAG2_PANIC_HUD_CREATED =
        true

    return gui
end

if GAG2_PANIC_HUD_ENABLED == true then

    GAG2CreatePanicHud()
end

function StartGAG2SniperHotkey()
    return
end

function RestoreSniperAutosaveState()

    task.defer(function()

        local enabled =
            Toggles.HolyGAG2SniperEnabled
            and Toggles.HolyGAG2SniperEnabled.Value == true

        local autoHop =
            Toggles.HolyGAG2SniperAutoHop
            and Toggles.HolyGAG2SniperAutoHop.Value == true

        local returnAfterTame =
            Toggles.HolyGAG2SniperReturnAfterTame

        local followPet =
            Toggles.HolyGAG2SniperFollowPet

        local returnMovementMode =
            Options.HolyGAG2SniperReturnMode

        local instantFirstHop =
            nil

        local panicHudToggle =
            Toggles.HolyGAG2SniperPanicHud

        SniperState.AutoHop =
            autoHop == true

        if instantFirstHop then

            SniperState.InstantFirstHop =
                instantFirstHop.Value == true

        else

            SniperState.InstantFirstHop =
                false
        end

        if returnAfterTame then

            SniperState.ReturnAfterTame =
                returnAfterTame.Value == true

        else

            SniperState.ReturnAfterTame =
                false
        end

        if followPet then

            SniperState.FollowPet =
                followPet.Value == true

        else

            SniperState.FollowPet =
                false
        end

        if returnMovementMode
        and returnMovementMode.Value ~= nil then

            SniperState.ReturnMovementMode =
                CleanText(returnMovementMode.Value) == "Teleport"
                and "Teleport"
                or "Walk"

        else

            SniperState.ReturnMovementMode =
                "Walk"
        end

        if panicHudToggle then

            GAG2_PANIC_HUD_ENABLED =
                panicHudToggle.Value == true

        else

            GAG2_PANIC_HUD_ENABLED =
                true
        end

        if GAG2_PANIC_HUD_ENABLED == true then

            GAG2CreatePanicHud()

        else

            GAG2DestroyPanicHud()
        end

        if Options.HolyGAG2SniperTargetsList
        and Options.HolyGAG2SniperTargetsList.Value ~= nil then

            SniperState.Targets =
                SniperNormalizeList(
                    Options.HolyGAG2SniperTargetsList.Value
                )
        end

        if Options.HolyGAG2SniperHopDelay
        and Options.HolyGAG2SniperHopDelay.Value ~= nil then

            SniperState.HopDelay =
                math.clamp(
                    tonumber(Options.HolyGAG2SniperHopDelay.Value)
                    or SniperState.HopDelay
                    or 20,
                    5,
                    120
                )
        end

        for priorityIndex = 1, 5 do

            local option =
                Options[
                    "HolyGAG2SniperPriority"
                    .. tostring(priorityIndex)
                ]

            if option
            and option.Value ~= nil then

                SniperSetPriorityPet(
                    priorityIndex,
                    option.Value
                )
            end
        end

        SniperRefreshTargetDropdown()
        SniperRefreshPriorityDropdowns()

        if enabled == true then

            SniperSetEnabled(
                true
            )

        else

            SetSniperStatus(
                "Ready."
            )

            SniperScan(
                false
            )
        end
    end)
end

--// [GAG2 VISUALS] Active Wild Pet HUD Helpers
local ActiveWildPetHudEnabled = false
local ActiveWildPetHudLabel = nil
local ActiveWildPetHudLoopRunning = false
local ActiveWildPetHudLastDebug = 0

local function ActiveWildPetHudDebug(message)
    if tick() - ActiveWildPetHudLastDebug < 3 then
        return
    end

    ActiveWildPetHudLastDebug = tick()
    print("[HOLY][Active Wild Pets] " .. tostring(message))
end

local function ActiveWildPetHudGetRoot()
    local map = workspace:FindFirstChild("Map")
    if not map then
        return nil
    end

    return map:FindFirstChild("WildPetSpawns")
end

local function ActiveWildPetHudGetDistanceText(spawnObject)
    local player = game:GetService("Players").LocalPlayer
    local character = player and player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return "?"
    end

    local spawnPosition = nil

    if spawnObject:IsA("BasePart") then
        spawnPosition = spawnObject.Position
    elseif spawnObject:IsA("Model") then
        local ok, pivot = pcall(function()
            return spawnObject:GetPivot()
        end)

        if ok and pivot then
            spawnPosition = pivot.Position
        end
    else
        local part = spawnObject:FindFirstChildWhichIsA("BasePart", true)
        if part then
            spawnPosition = part.Position
        end
    end

    if not spawnPosition then
        return "?"
    end

    local distance = (hrp.Position - spawnPosition).Magnitude
    return tostring(math.floor(distance + 0.5)) .. "m"
end

local function ActiveWildPetHudCleanPetName(spawnObject)
    local attrNames = {
        "PetName",
        "Name",
        "DisplayName",
        "WildPetName",
        "AnimalName",
    }

    for _, attrName in ipairs(attrNames) do
        local value = spawnObject:GetAttribute(attrName)
        if value ~= nil and tostring(value) ~= "" then
            return tostring(value)
        end
    end

    local rawName = tostring(spawnObject.Name or "Unknown")

    local fromPattern = rawName:match("^WildPet_(.-)_WildPet")
    if fromPattern and fromPattern ~= "" then
        return fromPattern:gsub("_", " ")
    end

    rawName = rawName:gsub("^WildPet_", "")
    rawName = rawName:gsub("_WildPet.*$", "")
    rawName = rawName:gsub("_", " ")

    if rawName == "" then
        return "Unknown"
    end

    return rawName
end

local function ActiveWildPetHudReadAttributeByKeywords(root, keywords)
    for _, keyword in ipairs(keywords) do
        local direct = root:GetAttribute(keyword)
        if direct ~= nil and tostring(direct) ~= "" then
            return tostring(direct)
        end
    end

    for attrName, attrValue in pairs(root:GetAttributes()) do
        local lowerName = string.lower(tostring(attrName))

        for _, keyword in ipairs(keywords) do
            if string.find(lowerName, string.lower(keyword), 1, true) and attrValue ~= nil and tostring(attrValue) ~= "" then
                return tostring(attrValue)
            end
        end
    end

    return nil
end

local function ActiveWildPetHudReadDescendantValueByKeywords(root, keywords)
    for _, descendant in ipairs(root:GetDescendants()) do
        local lowerName = string.lower(tostring(descendant.Name))

        for _, keyword in ipairs(keywords) do
            if string.find(lowerName, string.lower(keyword), 1, true) then
                if descendant:IsA("StringValue") or descendant:IsA("NumberValue") or descendant:IsA("IntValue") then
                    if descendant.Value ~= nil and tostring(descendant.Value) ~= "" then
                        return tostring(descendant.Value)
                    end
                elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    if descendant.Text ~= nil and tostring(descendant.Text) ~= "" then
                        return tostring(descendant.Text)
                    end
                end
            end
        end
    end

    return nil
end

local function ActiveWildPetHudReadTextPattern(root, pattern)
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            local text = tostring(descendant.Text or "")
            if text ~= "" and text:match(pattern) then
                return text
            end
        end
    end

    return nil
end

local function ActiveWildPetHudReadTimer(root)
    local value =
        ActiveWildPetHudReadAttributeByKeywords(root, { "Timer", "Time", "Expire", "Expires", "Duration", "Remaining" })
        or ActiveWildPetHudReadDescendantValueByKeywords(root, { "Timer", "Time", "Expire", "Expires", "Duration", "Remaining" })
        or ActiveWildPetHudReadTextPattern(root, "%d+:%d+")
        or ActiveWildPetHudReadTextPattern(root, "%d+%s*[sSmMhH]")

    if value == nil or tostring(value) == "" then
        ActiveWildPetHudDebug("Timer unreadable for " .. tostring(root:GetFullName()))
        return "?"
    end

    return tostring(value)
end

local function ActiveWildPetHudReadPrice(root)
    local value =
        ActiveWildPetHudReadAttributeByKeywords(root, { "Price", "Cost", "Coins", "Money", "Token", "Tokens" })
        or ActiveWildPetHudReadDescendantValueByKeywords(root, { "Price", "Cost", "Coins", "Money", "Token", "Tokens" })
        or ActiveWildPetHudReadTextPattern(root, "%$%s*[%d,]+")
        or ActiveWildPetHudReadTextPattern(root, "[%d,]+%s*[¢cC]")

    if value == nil or tostring(value) == "" then
        ActiveWildPetHudDebug("Price unreadable for " .. tostring(root:GetFullName()))
        return "?"
    end

    return tostring(value)
end

local function ActiveWildPetHudIsActiveSpawn(spawnObject)
    if not spawnObject then
        return false
    end

    if not spawnObject.Parent then
        return false
    end

    if not tostring(spawnObject.Name):find("WildPet") then
        return false
    end

    if spawnObject:IsA("Model") or spawnObject:IsA("Folder") or spawnObject:IsA("BasePart") then
        return true
    end

    return false
end

local function ActiveWildPetHudBuildText()
    local root = ActiveWildPetHudGetRoot()

    if not root then
        ActiveWildPetHudDebug("workspace.Map.WildPetSpawns was not found.")
        return "Active wild pets:\nWildPetSpawns not found."
    end

    local rows = {}

    for _, spawnObject in ipairs(root:GetChildren()) do
        if ActiveWildPetHudIsActiveSpawn(spawnObject) then
            local petName = ActiveWildPetHudCleanPetName(spawnObject)
            local timerText = ActiveWildPetHudReadTimer(spawnObject)
            local priceText = ActiveWildPetHudReadPrice(spawnObject)
            local distanceText = ActiveWildPetHudGetDistanceText(spawnObject)

            table.insert(rows, {
                Pet = petName,
                Timer = timerText,
                Price = priceText,
                Distance = distanceText,
            })
        end
    end

    table.sort(rows, function(a, b)
        return tostring(a.Pet) < tostring(b.Pet)
    end)

    if #rows <= 0 then
        return "Active wild pets:\nNone found."
    end

    local lines = {
        "Active wild pets: " .. tostring(#rows),
    }

    for index, row in ipairs(rows) do
        if index > 8 then
            table.insert(lines, "... +" .. tostring(#rows - 8) .. " more")
            break
        end

        table.insert(
            lines,
            tostring(index)
                .. ". "
                .. tostring(row.Pet)
                .. " | Time: "
                .. tostring(row.Timer)
                .. " | Price: "
                .. tostring(row.Price)
                .. " | Dist: "
                .. tostring(row.Distance)
        )
    end

    return table.concat(lines, "\n")
end

local function ActiveWildPetHudRefresh(forceDebug)
    local text = ActiveWildPetHudBuildText()

    if ActiveWildPetHudLabel and ActiveWildPetHudLabel.SetText then
        ActiveWildPetHudLabel:SetText(text)
    end

    if forceDebug then
        print("[HOLY][Active Wild Pets] Manual scan result:")
        print(text)
    end
end

local function ActiveWildPetHudStartLoop()
    if ActiveWildPetHudLoopRunning then
        return
    end

    ActiveWildPetHudLoopRunning = true

    task.spawn(function()
        while ActiveWildPetHudEnabled do
            ActiveWildPetHudRefresh(false)
            task.wait(1)
        end

        ActiveWildPetHudLoopRunning = false

        if ActiveWildPetHudLabel and ActiveWildPetHudLabel.SetText then
            ActiveWildPetHudLabel:SetText("Active wild pets:\nOFF")
        end
    end)
end

HomeLivePetsSummaryLabel =
    nil

HomeActivePetsLoopRunning =
    false

HomeLivePetButtons =
    {}

HomeLivePetButtonEntries =
    {}

HomeLivePetsList =
    nil

HomeLivePetMaxButtons =
    8

RefreshHomeActivePets =
    nil

function GAG2HomeCompactDistanceText(value)

    return tostring(value or "?")
        :gsub("%s*studs", "")
        :gsub("%s+$", "")
end

function GAG2HomeBuildPetButtonText(index, entry)

    if type(entry) ~= "table" then
        return "---"
    end

    local suffix =
        ""

    if SniperIsEntryHandled(entry) == true then
        suffix = " | Sent"
    end

    return tostring(index)
        .. ". "
        .. tostring(entry.Name or "?")
        .. " | "
        .. tostring(entry.Timer or "?")
        .. " | "
        .. tostring(entry.Price or "?")
        .. " | "
        .. GAG2HomeCompactDistanceText(
            entry.Distance
        )
        .. suffix
end

function GAG2HomeSetPetButtonText(button, text)

    text =
        tostring(text or "---")

    if not button then
        return
    end

    pcall(function()

        if type(button.SetText) == "function" then

            button:SetText(
                text
            )

            return
        end

        if type(button.SetTitle) == "function" then

            button:SetTitle(
                text
            )

            return
        end

        if typeof(button) == "Instance"
        and button:IsA("TextButton") then

            button.Text =
                text

            return
        end

        if type(button) == "table" then

            if typeof(button.Button) == "Instance"
            and button.Button:IsA("TextButton") then

                button.Button.Text =
                    text

                return
            end

            if typeof(button.Main) == "Instance" then

                local textButton =
                    button.Main:FindFirstChildWhichIsA(
                        "TextButton",
                        true
                    )

                if textButton then

                    textButton.Text =
                        text
                    return
                end

                local textLabel =
                    button.Main:FindFirstChildWhichIsA(
                        "TextLabel",
                        true
                    )

                if textLabel then

                    textLabel.Text =
                        text
                    return
                end
            end
        end
    end)
end

function GAG2HomeFindFreshEntry(cachedEntry)

    if type(cachedEntry) ~= "table" then
        return nil
    end

    local wantedKey =
        SniperGetEntryKey(
            cachedEntry
        )

    if wantedKey == "" then
        return cachedEntry
    end

    local entries, reason =
        SniperGetActiveEntries()

    if reason ~= "ok" then
        return cachedEntry
    end

    for _, entry in ipairs(entries) do

        if SniperGetEntryKey(entry) == wantedKey then
            return entry
        end
    end

    return nil
end

function GAG2HomeManualBuyPetIndex(index)

    index =
        tonumber(index)

    if not index then
        return false
    end

    local cachedEntry =
        HomeLivePetButtonEntries[index]

    if type(cachedEntry) ~= "table" then

        Notify(
            "Live Pets",
            "No pet on this row.",
            3
        )

        return false
    end

    local entry =
        GAG2HomeFindFreshEntry(
            cachedEntry
        )

    if type(entry) ~= "table"
    or SniperEntryStillActive(entry) ~= true then

        Notify(
            "Live Pets",
            "That pet is no longer active.",
            3
        )

        if type(RefreshHomeActivePets) == "function" then

            RefreshHomeActivePets()
        end

        return false
    end

    if SniperState.Taming == true then

        local activeFor =
            os.clock()
            - (
                tonumber(SniperState.LastTameAt)
                or 0
            )

        if activeFor < 2 then

            Notify(
                "Live Pets",
                "Buying packet is still active.",
                2
            )

            return false
        end

        SniperState.Taming =
            false
    end

    if HomeLivePetsList
    and type(HomeLivePetsList.SetState) == "function" then

        HomeLivePetsList:SetState(
            index,
            "buying"
        )
    end

    local started =
        SniperAttemptBuyEntry(
            entry
        )

    if started == true then

        SetSniperStatus(
            "Manual buy: "
            .. tostring(entry.Name)
        )

        Notify(
            "Live Pets",
            "Buying "
            .. tostring(entry.Name)
            .. ".",
            3
        )

        if type(RefreshHomeActivePets) == "function" then

            RefreshHomeActivePets()
        end

        return true
    end

    if HomeLivePetsList
    and type(HomeLivePetsList.SetState) == "function" then

        HomeLivePetsList:SetState(
            index,
            "ready"
        )
    end

    Notify(
        "Live Pets",
        "Could not start buy. It may already be handled.",
        3
    )

    RefreshHomeActivePets()

    return false
end

function BuildHomeActivePetsText()

    local entries, reason =
        SniperGetActiveEntries()

    if reason ~= "ok" then

        return '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
            .. '\nLoading pet data...'
    end

    if #entries <= 0 then

        return '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
            .. '\nPlayers: '
            .. tostring(#Players:GetPlayers())
            .. ' | Pets: 0'
            .. '\nNo active pets.'
    end

    return '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
        .. '\nPlayers: '
        .. tostring(#Players:GetPlayers())
        .. ' | Pets: '
        .. tostring(#entries)
        .. '\nClick a row to buy.'
end

RefreshHomeActivePets = function()

    local entries, reason =
        SniperGetActiveEntries()

    for key in pairs(HomeLivePetButtonEntries) do

        HomeLivePetButtonEntries[key] =
            nil
    end

    if not HomeLivePetsList
    or type(HomeLivePetsList.SetRows) ~= "function" then
        return
    end

    if reason ~= "ok" then

        HomeLivePetsList:SetSummary(
            '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
            .. '\nLoading pet data...'
        )

        HomeLivePetsList:SetRows({})

        return
    end

    local rows =
        {}

    local maxRows =
        tonumber(HomeLivePetMaxButtons)
        or 8

    for index, entry in ipairs(entries) do

        if index > maxRows then
            break
        end

        HomeLivePetButtonEntries[index] =
            entry

        local state =
            "ready"

        if SniperIsEntryHandled(entry) == true then
            state =
                "sent"
        end

        table.insert(rows, {
            Pet =
                tostring(entry.Name or "?"),

            Timer =
                tostring(entry.Timer or "?"),

            Price =
                tostring(entry.Price or "?"),

            Distance =
                GAG2HomeCompactDistanceText(
                    entry.Distance
                ),

            State =
                state,
        })
    end

    HomeLivePetsList:SetSummary(
        '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
        .. '\n'
        .. tostring(#Players:GetPlayers())
        .. ' players · '
        .. tostring(#entries)
        .. ' pets found'
    )

    HomeLivePetsList:SetRows(
        rows
    )
end

function GAG2MoonPredictorFormatSeconds(seconds)

    seconds =
        math.max(
            0,
            math.floor(
                tonumber(seconds)
                or 0
            )
        )

    local days =
        math.floor(seconds / 86400)

    local hours =
        math.floor((seconds % 86400) / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    local remain =
        seconds % 60

    if days > 0 then

        return tostring(days)
            .. "d "
            .. tostring(hours)
            .. "h "
            .. tostring(minutes)
            .. "m"
    end

    if hours > 0 then

        return tostring(hours)
            .. "h "
            .. tostring(minutes)
            .. "m"
    end

    if minutes > 0 then

        return tostring(minutes)
            .. "m "
            .. tostring(remain)
            .. "s"
    end

    return tostring(remain)
        .. "s"
end

function GAG2MoonPredictorGetNow()

    local ok, value =
        pcall(function()

            return workspace:GetServerTimeNow()
        end)

    if ok == true
    and tonumber(value) then

        return math.floor(
            tonumber(value)
        )
    end

    return os.time()
end

function GAG2MoonPredictorGetColor(name)

    name =
        tostring(name or "")

    if name == "Rainbow Moon" then
        return "rgb(255,64,255)"
    end

    if name == "Goldmoon" then
        return "rgb(250,204,21)"
    end

    if name == "Bloodmoon" then
        return "rgb(248,64,64)"
    end

    if name == "Moon" then
        return "rgb(147,197,253)"
    end

    if name == "Day" then
        return "rgb(147,197,253)"
    end

    if name == "Sunset" then
        return "rgb(251,191,36)"
    end

    return "rgb(196,181,253)"
end

function GAG2MoonPredictorIsRare(name)

    return name == "Goldmoon"
        or name == "Rainbow Moon"
        or name == "Bloodmoon"
end

function GAG2MoonPredictorBuildCycleInfo()

    local data =
        nil

    local ok, result =
        pcall(function()

            local sharedModules =
                ReplicatedStorage:FindFirstChild("SharedModules")

            local module =
                sharedModules
                and sharedModules:FindFirstChild("TimeCycleData")

            if module
            and module:IsA("ModuleScript") then

                return require(
                    module
                )
            end

            return nil
        end)

    if ok == true
    and type(result) == "table"
    and type(result.Data) == "table" then

        data =
            result
    end

    if type(data) ~= "table"
    or type(data.Data) ~= "table" then

        data = {
            Data = {
                Day = {
                    Lasts = 450,
                    StartOrder = 1,
                    Weathers = {
                        Day = {
                            Chance = 100,
                        },
                    },
                },

                Sunset = {
                    Lasts = 30,
                    StartOrder = 2,
                    Weathers = {
                        Sunset = {
                            Chance = 100,
                        },
                    },
                },

                Night = {
                    Lasts = 120,
                    StartOrder = 3,
                    Weathers = {
                        Moon = {
                            Chance = 79,
                        },

                        Bloodmoon = {
                            Chance = 2,
                        },

                        Goldmoon = {
                            Chance = 13,
                        },

                        ["Rainbow Moon"] = {
                            Chance = 6,
                        },
                    },
                },
            },
        }
    end

    local phases =
        {}

    for phaseName, phaseData in pairs(data.Data) do

        if type(phaseData) == "table" then

            table.insert(phases, {
                Name = tostring(phaseName),
                Weathers = type(phaseData.Weathers) == "table"
                    and phaseData.Weathers
                    or {},
                Duration = tonumber(phaseData.Lasts) or 0,
                Order = tonumber(phaseData.StartOrder) or 999,
                Raw = phaseData,
            })
        end
    end

    table.sort(phases, function(a, b)

        return a.Order < b.Order
    end)

    local fullCycle =
        0

    local secondsBeforeNight =
        0

    local nightIndex =
        nil

    local nightRecord =
        nil

    for index, phase in ipairs(phases) do

        if phase.Name == "Night" then

            nightIndex =
                index

            nightRecord =
                phase

            break
        end

        secondsBeforeNight =
            secondsBeforeNight
            + phase.Duration
    end

    for _, phase in ipairs(phases) do

        fullCycle =
            fullCycle
            + phase.Duration
    end

    if not nightIndex
    or not nightRecord then

        nightIndex =
            3

        nightRecord = {
            Name = "Night",
            Duration = 120,
            Weathers = {
                Moon = {
                    Chance = 79,
                },

                Bloodmoon = {
                    Chance = 2,
                },

                Goldmoon = {
                    Chance = 13,
                },

                ["Rainbow Moon"] = {
                    Chance = 6,
                },
            },
        }

        fullCycle =
            600

        secondsBeforeNight =
            480
    end

    if fullCycle <= 0 then

        fullCycle =
            600
    end

    if secondsBeforeNight <= 0 then

        secondsBeforeNight =
            480
    end

    return {
        Phases = phases,
        FullCycle = fullCycle,
        SecondsBeforeNight = secondsBeforeNight,
        NightIndex = nightIndex,
        NightRecord = nightRecord,
        NightDuration = tonumber(nightRecord.Duration) or 120,
    }
end

function GAG2MoonPredictorExtractPickWeather(cycleInfo)

    if type(cycleInfo) ~= "table" then
        return nil
    end

    if type(debug) ~= "table"
    or type(debug.getupvalues) ~= "function" then

        return nil
    end

    local playerScripts =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("PlayerScripts")

    local controllers =
        playerScripts
        and playerScripts:FindFirstChild("Controllers")

    local module =
        controllers
        and controllers:FindFirstChild("TimeCycleController")

    if not module then
        return nil
    end

    local requireOk, controller =
        pcall(function()

            return require(module)
        end)

    if requireOk ~= true
    or type(controller) ~= "table"
    or type(controller.Start) ~= "function" then

        return nil
    end

    local upvalueOk, upvalues =
        pcall(function()

            return debug.getupvalues(
                controller.Start
            )
        end)

    if upvalueOk ~= true
    or type(upvalues) ~= "table" then

        return nil
    end

    local function testPickWeather(fn)

        if type(fn) ~= "function" then
            return false
        end

        local callOk, moonName =
            pcall(function()

                return fn(
                    cycleInfo.NightRecord,
                    Random.new(123456)
                )
            end)

        return callOk == true
            and type(moonName) == "string"
            and type(cycleInfo.NightRecord.Weathers) == "table"
            and cycleInfo.NightRecord.Weathers[moonName] ~= nil
    end

    if testPickWeather(upvalues[2]) == true then
        return upvalues[2]
    end

    for _, value in pairs(upvalues) do

        if testPickWeather(value) == true then
            return value
        end
    end

    return nil
end

function GAG2MoonPredictorFallbackPickWeather(phaseRecord, rng)

    if type(phaseRecord) ~= "table"
    or type(phaseRecord.Weathers) ~= "table" then

        return "?"
    end

    local rows =
        {}

    for weatherName, weatherData in pairs(phaseRecord.Weathers) do

        table.insert(rows, {
            Name = tostring(weatherName),
            Chance =
                tonumber(
                    weatherData.Chance
                )
                or 0,
        })
    end

    table.sort(rows, function(a, b)

        return tostring(a.Name) < tostring(b.Name)
    end)

    local total =
        0

    for _, row in ipairs(rows) do

        total =
            total
            + row.Chance
    end

    if total <= 0 then
        return rows[1] and rows[1].Name or "?"
    end

    local roll =
        rng:NextNumber()
        * total

    local cumulative =
        0

    for _, row in ipairs(rows) do

        cumulative =
            cumulative
            + row.Chance

        if roll <= cumulative then
            return row.Name
        end
    end

    return rows[#rows]
        and rows[#rows].Name
        or "?"
end

function GAG2MoonPredictorEnsureReady()

    local state =
        GAG2_MOON_PREDICTOR_STATE

    if type(state.CycleInfo) ~= "table" then

        state.CycleInfo =
            GAG2MoonPredictorBuildCycleInfo()
    end

    if type(state.PickWeather) ~= "function"
    and type(state.CycleInfo) == "table" then

        state.PickWeather =
            GAG2MoonPredictorExtractPickWeather(
                state.CycleInfo
            )
    end

    return type(state.CycleInfo) == "table"
end

function GAG2MoonPredictorPredictMoon(cycleIndex)

    local state =
        GAG2_MOON_PREDICTOR_STATE

    if GAG2MoonPredictorEnsureReady() ~= true then
        return "?"
    end

    cycleIndex =
        math.floor(
            tonumber(cycleIndex)
            or 0
        )

    local seed =
        cycleIndex
        * 1000
        + tonumber(state.CycleInfo.NightIndex)

    if type(state.PickWeather) == "function" then

        local ok, moonName =
            pcall(function()

                return state.PickWeather(
                    state.CycleInfo.NightRecord,
                    Random.new(seed)
                )
            end)

        if ok == true
        and type(moonName) == "string" then

            return moonName
        end
    end

    return GAG2MoonPredictorFallbackPickWeather(
        state.CycleInfo.NightRecord,
        Random.new(seed)
    )
end

function GAG2MoonPredictorGetUpcomingRareRows(limit)

    limit =
        math.max(
            1,
            math.floor(
                tonumber(limit)
                or 7
            )
        )

    if GAG2MoonPredictorEnsureReady() ~= true then
        return {}
    end

    local state =
        GAG2_MOON_PREDICTOR_STATE

    local now =
        GAG2MoonPredictorGetNow()

    local currentCycle =
        math.floor(
            now / state.CycleInfo.FullCycle
        )

    local rows =
        {}

    for offset = 0, 600 do

        local cycleIndex =
            currentCycle
            + offset

        local nightStart =
            cycleIndex
            * state.CycleInfo.FullCycle
            + state.CycleInfo.SecondsBeforeNight

        if nightStart >= now then

            local moonName =
                GAG2MoonPredictorPredictMoon(
                    cycleIndex
                )

            if GAG2MoonPredictorIsRare(moonName) == true then

                table.insert(rows, {
                    Moon = moonName,
                    InSeconds = nightStart - now,
                    NightStart = nightStart,
                })

                if #rows >= limit then
                    break
                end
            end
        end
    end

    return rows
end

function GAG2MoonPredictorBuildText()

    if GAG2MoonPredictorEnsureReady() ~= true then

        return '<font color="rgb(196,181,253)"><b>Current:</b></font> '
            .. '<font color="rgb(148,163,184)">Loading...</font>'
            .. '\n<font color="rgb(148,163,184)">Upcoming rare moons:</font>'
            .. '\n<font color="rgb(148,163,184)">Loading moon data...</font>'
    end

    local now =
        GAG2MoonPredictorGetNow()

    local activeWeather =
        CleanText(
            workspace:GetAttribute("ActiveWeather")
        )

    if activeWeather == "" then
        activeWeather =
            "?"
    end

    local phaseEnd =
        tonumber(
            workspace:GetAttribute("PhaseDuration")
        )
        or now

    local remaining =
        math.max(
            0,
            math.floor(
                phaseEnd - now
            )
        )

    local lines =
        {}

    table.insert(
        lines,
        '<font color="rgb(226,232,240)"><b>Current:</b></font> '
        .. '<font color="'
        .. GAG2MoonPredictorGetColor(activeWeather)
        .. '"><b>'
        .. activeWeather
        .. '</b></font> '
        .. '<font color="rgb(148,163,184)">('
        .. GAG2MoonPredictorFormatSeconds(remaining)
        .. ' left)</font>'
    )

    table.insert(
        lines,
        '<font color="rgb(148,163,184)">Upcoming rare moons:</font>'
    )

    local rows =
        GAG2MoonPredictorGetUpcomingRareRows(
            7
        )

    if #rows <= 0 then

        table.insert(
            lines,
            '<font color="rgb(148,163,184)">No rare moons found soon.</font>'
        )

    else

        for _, row in ipairs(rows) do

            table.insert(
                lines,
                '<font color="'
                .. GAG2MoonPredictorGetColor(row.Moon)
                .. '"><b>'
                .. tostring(row.Moon)
                .. '</b></font> '
                .. '<font color="rgb(124,252,0)">in '
                .. GAG2MoonPredictorFormatSeconds(row.InSeconds)
                .. '</font>'
            )
        end
    end

    return table.concat(
        lines,
        "\n"
    )
end

function GAG2MoonPredictorRefresh()

    local ok, text =
        pcall(function()

            return GAG2MoonPredictorBuildText()
        end)

    if ok ~= true
    or type(text) ~= "string"
    or text == "" then

        text =
            '<font color="rgb(226,232,240)"><b>Current:</b></font> '
            .. '<font color="rgb(248,113,113)">Error</font>'
            .. '\n<font color="rgb(148,163,184)">Upcoming rare moons:</font>'
            .. '\n<font color="rgb(248,113,113)">Moon predictor failed.</font>'
    end

    GAG2_MOON_PREDICTOR_STATE.LastText =
        text

    if GAG2_MOON_PREDICTOR_LABEL
    and type(GAG2_MOON_PREDICTOR_LABEL.SetText) == "function" then

        pcall(function()

            GAG2_MOON_PREDICTOR_LABEL:SetText(
                text
            )
        end)
    end

    if Options.HolyGAG2MoonPredictor
    and type(Options.HolyGAG2MoonPredictor.SetText) == "function" then

        pcall(function()

            Options.HolyGAG2MoonPredictor:SetText(
                text
            )
        end)
    end
end

function GAG2FarmDetailsEscape(value)

    return tostring(value or "")
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
end

function GAG2FarmDetailsFormatKg(value)

    local number =
        tonumber(value)

    if not number then
        return "?kg"
    end

    return string.format(
        "%.2fkg",
        number
    )
end

function GAG2FarmDetailsPadRight(value, width)

    local text =
        tostring(value or "")

    width =
        math.max(
            1,
            math.floor(
                tonumber(width)
                or 1
            )
        )

    if #text >= width then
        return text
    end

    return text
        .. string.rep(
            " ",
            width - #text
        )
end

function GAG2FarmDetailsColorMutation(mutation)

    mutation =
        CleanText(mutation)

    if mutation == "Rainbow" then
        return "rgb(255,64,255)"
    end

    if mutation == "Gold" then
        return "rgb(250,204,21)"
    end

    return "rgb(226,232,240)"
end

function GAG2FarmDetailsVariantText(goldCount, rainbowCount)

    goldCount =
        math.max(
            0,
            math.floor(
                tonumber(goldCount)
                or 0
            )
        )

    rainbowCount =
        math.max(
            0,
            math.floor(
                tonumber(rainbowCount)
                or 0
            )
        )

    local parts =
        {}

    if goldCount > 0 then

        table.insert(
            parts,
            '<font color="rgb(250,204,21)">G'
            .. tostring(goldCount)
            .. '</font>'
        )
    end

    if rainbowCount > 0 then

        table.insert(
            parts,
            '<font color="rgb(255,64,255)">R'
            .. tostring(rainbowCount)
            .. '</font>'
        )
    end

    if #parts <= 0 then
        return '<font color="rgb(148,163,184)">—</font>'
    end

    return table.concat(
        parts,
        " "
    )
end

function GAG2FarmDetailsFindOwnPlot()

    local gardens =
        workspace:FindFirstChild("Gardens")

    if not gardens then
        return nil
    end

    local userId =
        LOCAL_PLAYER
        and tostring(LOCAL_PLAYER.UserId)
        or ""

    local playerName =
        LOCAL_PLAYER
        and tostring(LOCAL_PLAYER.Name):lower()
        or ""

    for _, plot in ipairs(gardens:GetChildren()) do

        local attrs =
            {}

        pcall(function()

            attrs =
                plot:GetAttributes()
        end)

        for key, value in pairs(attrs) do

            local text =
                tostring(key)
                .. "="
                .. tostring(value)

            if userId ~= ""
            and text:find(userId, 1, true) then

                return plot
            end

            if playerName ~= ""
            and text:lower():find(playerName, 1, true) then

                return plot
            end
        end
    end

    return gardens:FindFirstChild("Plot2")
        or gardens:GetChildren()[1]
end

function GAG2FarmDetailsGetPlantsFolder()

    local plot =
        GAG2FarmDetailsFindOwnPlot()

    if not plot then
        return nil, nil
    end

    local plants =
        plot:FindFirstChild("Plants")
        or plot:FindFirstChild("plants")

    return plot,
        plants
end

function GAG2FarmDetailsFindHarvestPrompt(root)

    if typeof(root) ~= "Instance" then
        return nil
    end

    for _, descendant in ipairs(root:GetDescendants()) do

        if descendant:IsA("ProximityPrompt") then

            local name =
                CleanText(descendant.Name):lower()

            local action =
                CleanText(descendant.ActionText):lower()

            local objectText =
                CleanText(descendant.ObjectText):lower()

            if name:find("harvest", 1, true)
            or action:find("harvest", 1, true)
            or action:find("collect", 1, true)
            or objectText:find("harvest", 1, true) then

                return descendant
            end
        end
    end

    return nil
end

function GAG2FarmDetailsIsFruitReady(fruit)

    if typeof(fruit) ~= "Instance" then
        return false
    end

    local age =
        tonumber(
            fruit:GetAttribute("Age")
        )

    local maxAge =
        tonumber(
            fruit:GetAttribute("MaxAge")
        )

    if age ~= nil
    and maxAge ~= nil
    and age >= maxAge then

        return true
    end

    return GAG2FarmDetailsFindHarvestPrompt(fruit) ~= nil
end

function GAG2FarmDetailsCalculateKg(fruit, fruitName)

    if typeof(fruit) ~= "Instance" then
        return nil
    end

    if type(GAG2ACFCalculateFruitWeightKg) ~= "function" then
        return nil
    end

    local ok, weightKg =
        pcall(function()

            return GAG2ACFCalculateFruitWeightKg(
                fruit,
                fruitName
            )
        end)

    if ok == true
    and tonumber(weightKg)
    and tonumber(weightKg) > 0 then

        return tonumber(weightKg)
    end

    return nil
end

function GAG2FarmDetailsMutationLabel(rootMutation, fruitMutation)

    rootMutation =
        CleanText(rootMutation)

    fruitMutation =
        CleanText(fruitMutation)

    if fruitMutation ~= "" then
        return fruitMutation
    end

    if rootMutation ~= "" then
        return rootMutation
    end

    return "Normal"
end

function GAG2FarmDetailsBuildSnapshot()

    local plot, plantsFolder =
        GAG2FarmDetailsGetPlantsFolder()

    local snapshot = {
        PlotName = plot and plot.Name or "?",
        TotalPlants = 0,
        TotalFruits = 0,
        ReadyFruits = 0,
        GoldPlants = 0,
        RainbowPlants = 0,
        Best = nil,
        Rows = {},
    }

    if not plantsFolder then
        return snapshot
    end

    local byPlant =
        {}

    for _, plant in ipairs(plantsFolder:GetChildren()) do

        if plant:IsA("Model")
        or plant:IsA("Folder") then

            snapshot.TotalPlants =
                snapshot.TotalPlants + 1

            local seedName =
                CleanText(
                    plant:GetAttribute("SeedName")
                    or plant:GetAttribute("CorePartName")
                    or plant.Name
                )

            if seedName == "" then
                seedName =
                    "Unknown"
            end

            local rootMutation =
                CleanText(
                    plant:GetAttribute("Mutation")
                )

            if rootMutation == "Gold" then

                snapshot.GoldPlants =
                    snapshot.GoldPlants + 1

            elseif rootMutation == "Rainbow" then

                snapshot.RainbowPlants =
                    snapshot.RainbowPlants + 1
            end

            local record =
                byPlant[seedName]

            if not record then

                record = {
                    Name = seedName,
                    Plants = 0,
                    Fruits = 0,
                    Ready = 0,
                    Gold = 0,
                    Rainbow = 0,
                    BestKg = nil,
                    BestMutation = "Normal",
                }

                byPlant[seedName] =
                    record
            end

            record.Plants =
                record.Plants + 1

            if rootMutation == "Gold" then

                record.Gold =
                    record.Gold + 1

            elseif rootMutation == "Rainbow" then

                record.Rainbow =
                    record.Rainbow + 1
            end

            local fruits =
                plant:FindFirstChild("Fruits")
                or plant:FindFirstChild("fruits")

            if fruits then

                for _, fruit in ipairs(fruits:GetChildren()) do

                    local fruitName =
                        CleanText(
                            fruit:GetAttribute("CorePartName")
                            or fruit:GetAttribute("FruitName")
                            or seedName
                        )

                    if fruitName == "" then
                        fruitName =
                            seedName
                    end

                    local fruitMutation =
                        CleanText(
                            fruit:GetAttribute("Mutation")
                        )

                    snapshot.TotalFruits =
                        snapshot.TotalFruits + 1

                    record.Fruits =
                        record.Fruits + 1

                    if GAG2FarmDetailsIsFruitReady(fruit) == true then

                        snapshot.ReadyFruits =
                            snapshot.ReadyFruits + 1

                        record.Ready =
                            record.Ready + 1
                    end

                    local kg =
                        GAG2FarmDetailsCalculateKg(
                            fruit,
                            fruitName
                        )

                    if kg
                    and (
                        record.BestKg == nil
                        or kg > record.BestKg
                    ) then

                        record.BestKg =
                            kg

                        record.BestMutation =
                            GAG2FarmDetailsMutationLabel(
                                rootMutation,
                                fruitMutation
                            )
                    end

                    if kg
                    and (
                        snapshot.Best == nil
                        or kg > snapshot.Best.Kg
                    ) then

                        snapshot.Best = {
                            Name = fruitName,

                            Mutation =
                                GAG2FarmDetailsMutationLabel(
                                    rootMutation,
                                    fruitMutation
                                ),

                            Kg = kg,
                        }
                    end
                end
            end
        end
    end

    for _, record in pairs(byPlant) do

        table.insert(
            snapshot.Rows,
            record
        )
    end

    table.sort(snapshot.Rows, function(a, b)

        local aKg =
            tonumber(a.BestKg)
            or 0

        local bKg =
            tonumber(b.BestKg)
            or 0

        if aKg ~= bKg then
            return aKg > bKg
        end

        if tonumber(a.Ready or 0) ~= tonumber(b.Ready or 0) then
            return tonumber(a.Ready or 0) > tonumber(b.Ready or 0)
        end

        if tonumber(a.Fruits or 0) ~= tonumber(b.Fruits or 0) then
            return tonumber(a.Fruits or 0) > tonumber(b.Fruits or 0)
        end

        return tostring(a.Name) < tostring(b.Name)
    end)

    return snapshot
end

function GAG2FarmDetailsShortText(value, maxLength)

    local text =
        tostring(value or "")

    maxLength =
        math.max(
            4,
            math.floor(
                tonumber(maxLength)
                or 18
            )
        )

    if #text <= maxLength then
        return text
    end

    return text:sub(
        1,
        maxLength - 1
    )
    .. "…"
end

function GAG2FarmDetailsBuildSummaryText(snapshot)

    snapshot =
        type(snapshot) == "table"
        and snapshot
        or GAG2FarmDetailsBuildSnapshot()

    local lines =
        {}

    table.insert(
        lines,
        '<font color="rgb(196,181,253)"><b>Farm:</b></font> '
        .. '<font color="rgb(226,232,240)">'
        .. GAG2FarmDetailsEscape(snapshot.PlotName)
        .. '</font>'
    )

    table.insert(
        lines,
        '<font color="rgb(196,181,253)">Plants:</font> '
        .. '<font color="rgb(226,232,240)">'
        .. tostring(snapshot.TotalPlants)
        .. '</font>'
        .. ' <font color="rgb(148,163,184)">|</font> '
        .. '<font color="rgb(196,181,253)">Fruits:</font> '
        .. '<font color="rgb(226,232,240)">'
        .. tostring(snapshot.TotalFruits)
        .. '</font>'
        .. ' <font color="rgb(148,163,184)">|</font> '
        .. '<font color="rgb(124,252,0)">Ready: '
        .. tostring(snapshot.ReadyFruits)
        .. '</font>'
    )

    table.insert(
        lines,
        '<font color="rgb(250,204,21)">Gold x'
        .. tostring(snapshot.GoldPlants)
        .. '</font>'
        .. ' <font color="rgb(148,163,184)">|</font> '
        .. '<font color="rgb(255,64,255)">Rainbow x'
        .. tostring(snapshot.RainbowPlants)
        .. '</font>'
    )

    if snapshot.Best then

        table.insert(
            lines,
            '<font color="rgb(196,181,253)"><b>Best:</b></font> '
            .. '<font color="'
            .. GAG2FarmDetailsColorMutation(snapshot.Best.Mutation)
            .. '"><b>'
            .. GAG2FarmDetailsEscape(snapshot.Best.Mutation)
            .. " "
            .. GAG2FarmDetailsEscape(snapshot.Best.Name)
            .. '</b></font> '
            .. '<font color="rgb(124,252,0)">'
            .. GAG2FarmDetailsFormatKg(snapshot.Best.Kg)
            .. '</font>'
        )

    else

        table.insert(
            lines,
            '<font color="rgb(196,181,253)"><b>Best:</b></font> '
            .. '<font color="rgb(148,163,184)">No fruit weight data yet.</font>'
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

function GAG2FarmDetailsBuildRowData(row)

    row =
        type(row) == "table"
        and row
        or {}

    local plantText =
        GAG2FarmDetailsShortText(
            tostring(row.Name or "?")
            .. " x"
            .. tostring(row.Plants or 0),
            19
        )

    local variantParts =
        {}

    local gold =
        math.max(
            0,
            math.floor(
                tonumber(row.Gold)
                or 0
            )
        )

    local rainbow =
        math.max(
            0,
            math.floor(
                tonumber(row.Rainbow)
                or 0
            )
        )

    if gold > 0 then

        table.insert(
            variantParts,
            '<font color="rgb(250,204,21)">G'
            .. tostring(gold)
            .. '</font>'
        )
    end

    if rainbow > 0 then

        table.insert(
            variantParts,
            '<font color="rgb(255,64,255)">R'
            .. tostring(rainbow)
            .. '</font>'
        )
    end

    local variantText =
        #variantParts > 0
        and table.concat(
            variantParts,
            " "
        )
        or '<font color="rgb(148,163,184)">—</font>'

    return {
        Plant =
            plantText,

        Variant =
            variantText,

        Fruits =
            tostring(row.Fruits or 0),

        Best =
            GAG2FarmDetailsFormatKg(
                row.BestKg
            ),

        BestKg =
            tonumber(row.BestKg),

        RawName =
            tostring(row.Name or ""),
    }
end

function GAG2FarmDetailsBuildRowText(row)

    local data =
        GAG2FarmDetailsBuildRowData(
            row
        )

    return '<font color="rgb(226,232,240)">'
        .. GAG2FarmDetailsEscape(data.Plant)
        .. '</font> '
        .. data.Variant
        .. ' <font color="rgb(148,163,184)">|</font> '
        .. '<font color="rgb(226,232,240)">'
        .. GAG2FarmDetailsEscape(data.Fruits)
        .. '</font>'
        .. ' <font color="rgb(148,163,184)">|</font> '
        .. '<font color="rgb(124,252,0)">'
        .. GAG2FarmDetailsEscape(data.Best)
        .. '</font>'
end

function GAG2FarmDetailsGetPanelChromeHeight()

    local state =
        GAG2_FARM_DETAILS_STATE

    return (tonumber(state.SummaryHeight) or 74)
        + 26
        + (tonumber(state.HeaderHeight) or 22)
        + 4
end

function GAG2FarmDetailsGetWantedPanelHeight(snapshot)

    local state =
        GAG2_FARM_DETAILS_STATE

    if state.ShowAll ~= true then

        return tonumber(state.TopPanelHeight)
            or tonumber(state.PanelHeight)
            or 246
    end

    snapshot =
        type(snapshot) == "table"
        and snapshot
        or {}

    local rows =
        type(snapshot.Rows) == "table"
        and #snapshot.Rows
        or 0

    local visibleRows =
        math.min(
            math.max(
                rows,
                1
            ),
            math.max(
                1,
                math.floor(
                    tonumber(state.AllVisibleRows)
                    or 15
                )
            )
        )

    local rowHeight =
        tonumber(state.RowHeight)
        or 24

    local chromeHeight =
        GAG2FarmDetailsGetPanelChromeHeight()

    local wantedHeight =
        chromeHeight
        + (
            visibleRows
            * (rowHeight + 3)
        )
        + 10

    local minHeight =
        tonumber(state.TopPanelHeight)
        or 246

    local maxHeight =
        tonumber(state.AllPanelHeight)
        or 455

    return math.clamp(
        wantedHeight,
        minHeight,
        maxHeight
    )
end

function GAG2FarmDetailsApplyPanelHeight(snapshot)

    local state =
        GAG2_FARM_DETAILS_STATE

    local wantedHeight =
        GAG2FarmDetailsGetWantedPanelHeight(
            snapshot
        )

    state.PanelHeight =
        wantedHeight

    if GAG2_FARM_DETAILS_PANEL
    and type(GAG2_FARM_DETAILS_PANEL.SetHeight) == "function" then

        pcall(function()

            GAG2_FARM_DETAILS_PANEL:SetHeight(
                wantedHeight
            )
        end)
    end

    if state.PanelRoot then

        pcall(function()

            state.PanelRoot.Size =
                UDim2.fromScale(
                    1,
                    1
                )
        end)
    end

    return wantedHeight
end

function GAG2FarmDetailsClearScroll()

    local state =
        GAG2_FARM_DETAILS_STATE

    local scroll =
        state.RowScroll

    if typeof(scroll) ~= "Instance" then
        return
    end

    for _, child in ipairs(scroll:GetChildren()) do

        if child:IsA("UIListLayout") ~= true
        and child:IsA("UIPadding") ~= true then

            child:Destroy()
        end
    end
end

function GAG2FarmDetailsCreateColumnLabel(parent, name, position, size, text, textSize, color, align)

    local label =
        Instance.new("TextLabel")

    label.Name =
        tostring(name or "Label")

    label.BackgroundTransparency =
        1

    label.Position =
        position

    label.Size =
        size

    label.Font =
        Enum.Font.Code

    label.RichText =
        true

    label.Text =
        tostring(text or "")

    label.TextSize =
        tonumber(textSize)
        or 12

    label.TextColor3 =
        color
        or Color3.fromRGB(
            226,
            232,
            240
        )

    label.TextXAlignment =
        align
        or Enum.TextXAlignment.Left

    label.TextYAlignment =
        Enum.TextYAlignment.Center

    label.TextTruncate =
        Enum.TextTruncate.AtEnd

    label.Parent =
        parent

    return label
end

function GAG2FarmDetailsCreateRow(parent, rowData, muted)

    if typeof(parent) ~= "Instance" then
        return nil
    end

    local rowHeight =
        tonumber(GAG2_FARM_DETAILS_STATE.RowHeight)
        or 24

    local row =
        Instance.new("Frame")

    row.Name =
        "FarmRow"

    row.BorderSizePixel =
        0

    row.Size =
        UDim2.new(
            1,
            -2,
            0,
            rowHeight
        )

    row.Parent =
        parent

    if muted == true then

        row.BackgroundTransparency =
            1

        GAG2FarmDetailsCreateColumnLabel(
            row,
            "MutedText",
            UDim2.fromOffset(
                6,
                0
            ),
            UDim2.new(
                1,
                -12,
                1,
                0
            ),
            tostring(rowData or ""),
            11,
            Color3.fromRGB(
                148,
                163,
                184
            ),
            Enum.TextXAlignment.Left
        )

        return row
    end

    local index =
        tonumber(
            type(rowData) == "table"
            and rowData.Index
        )
        or 1

    row.BackgroundColor3 =
        Color3.fromRGB(
            15,
            13,
            24
        )

    row.BackgroundTransparency =
        index % 2 == 0
        and 0.34
        or 0.48

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(
            0,
            5
        )

    corner.Parent =
        row

    local data =
        type(rowData) == "table"
        and rowData
        or {}

    GAG2FarmDetailsCreateColumnLabel(
        row,
        "Plant",
        UDim2.fromOffset(
            7,
            0
        ),
        UDim2.new(
            0.46,
            -7,
            1,
            0
        ),
        GAG2FarmDetailsEscape(
            data.Plant
            or "?"
        ),
        12,
        Color3.fromRGB(
            226,
            232,
            240
        ),
        Enum.TextXAlignment.Left
    )

    GAG2FarmDetailsCreateColumnLabel(
        row,
        "Variant",
        UDim2.new(
            0.46,
            2,
            0,
            0
        ),
        UDim2.new(
            0.19,
            -2,
            1,
            0
        ),
        data.Variant
        or '<font color="rgb(148,163,184)">—</font>',
        12,
        Color3.fromRGB(
            226,
            232,
            240
        ),
        Enum.TextXAlignment.Left
    )

    GAG2FarmDetailsCreateColumnLabel(
        row,
        "Fruits",
        UDim2.new(
            0.65,
            2,
            0,
            0
        ),
        UDim2.new(
            0.13,
            -2,
            1,
            0
        ),
        GAG2FarmDetailsEscape(
            data.Fruits
            or "0F"
        ),
        12,
        Color3.fromRGB(
            226,
            232,
            240
        ),
        Enum.TextXAlignment.Left
    )

    GAG2FarmDetailsCreateColumnLabel(
        row,
        "Best",
        UDim2.new(
            0.78,
            0,
            0,
            0
        ),
        UDim2.new(
            0.22,
            -8,
            1,
            0
        ),
        GAG2FarmDetailsEscape(
            data.Best
            or "?kg"
        ),
        12,
        Color3.fromRGB(
            124,
            252,
            0
        ),
        Enum.TextXAlignment.Right
    )

    return row
end

function GAG2FarmDetailsSetShowAll(value)

    GAG2_FARM_DETAILS_STATE.ShowAll =
        value == true

    GAG2FarmDetailsRefresh(
        true
    )
end

function GAG2FarmDetailsSetSearchText(value)

    local state =
        GAG2_FARM_DETAILS_STATE

    local text =
        CleanText(value)

    if state.SearchText == text then
        return
    end

    state.SearchText =
        text

    GAG2FarmDetailsRefresh(
        true
    )
end

function GAG2FarmDetailsRowMatchesSearch(row)

    local state =
        GAG2_FARM_DETAILS_STATE

    local searchText =
        CleanText(
            state.SearchText
        ):lower()

    if searchText == "" then
        return true
    end

    if type(row) ~= "table" then
        return false
    end

    local name =
        tostring(row.Name or ""):lower()

    if name:find(searchText, 1, true) then
        return true
    end

    local plantText =
        tostring(row.Plant or ""):lower()

    if plantText:find(searchText, 1, true) then
        return true
    end

    return false
end

function GAG2FarmDetailsGetFilteredRows(snapshot)

    local rows =
        {}

    if type(snapshot) ~= "table"
    or type(snapshot.Rows) ~= "table" then

        return rows
    end

    for _, row in ipairs(snapshot.Rows) do

        if GAG2FarmDetailsRowMatchesSearch(row) == true then

            table.insert(
                rows,
                row
            )
        end
    end

    return rows
end

function GAG2FarmDetailsCreatePanel()

    local state =
        GAG2_FARM_DETAILS_STATE

    if state.PanelRoot
    and state.PanelRoot.Parent then

        return state.PanelRoot
    end

    local root =
        Instance.new("Frame")

    root.Name =
        "HolyGAG2FarmDetailsPanel"

    root.BackgroundTransparency =
        1

    root.BorderSizePixel =
        0

    root.Size =
        UDim2.fromScale(
            1,
            1
        )

    local summaryHeight =
        tonumber(state.SummaryHeight)
        or 74

    local headerHeight =
        tonumber(state.HeaderHeight)
        or 22

    local summary =
        Instance.new("TextLabel")

    summary.Name =
        "Summary"

    summary.BackgroundTransparency =
        1

    summary.Position =
        UDim2.fromOffset(
            0,
            0
        )

    summary.Size =
        UDim2.new(
            1,
            0,
            0,
            summaryHeight
        )

    summary.Font =
        Enum.Font.Code

    summary.RichText =
        true

    summary.Text =
        '<font color="rgb(196,181,253)"><b>Farm:</b></font> '
        .. '<font color="rgb(148,163,184)">Loading...</font>'

    summary.TextSize =
        12

    summary.TextColor3 =
        Color3.fromRGB(
            226,
            232,
            240
        )

    summary.TextXAlignment =
        Enum.TextXAlignment.Left

    summary.TextYAlignment =
        Enum.TextYAlignment.Top

    summary.Parent =
        root

    local line =
        Instance.new("Frame")

    line.Name =
        "Line"

    line.BackgroundColor3 =
        Color3.fromRGB(
            43,
            35,
            68
        )

    line.BackgroundTransparency =
        0.28

    line.BorderSizePixel =
        0

    line.Position =
        UDim2.new(
            0,
            0,
            0,
            summaryHeight
        )

    line.Size =
        UDim2.new(
            1,
            0,
            0,
            1
        )

    line.Parent =
        root

    local plantedHeader =
        Instance.new("TextLabel")

    plantedHeader.Name =
        "PlantedHeader"

    plantedHeader.BackgroundTransparency =
        1

    plantedHeader.Position =
        UDim2.new(
            0,
            0,
            0,
            summaryHeight + 4
        )

    plantedHeader.Size =
        UDim2.new(
            0,
            70,
            0,
            18
        )

    plantedHeader.Font =
        Enum.Font.Code

    plantedHeader.RichText =
        true

    plantedHeader.Text =
        '<font color="rgb(196,181,253)"><b>Planted:</b></font>'

    plantedHeader.TextSize =
        12

    plantedHeader.TextXAlignment =
        Enum.TextXAlignment.Left

    plantedHeader.TextColor3 =
        Color3.fromRGB(
            226,
            232,
            240
        )

    plantedHeader.Parent =
        root

    local searchBox =
        Instance.new("TextBox")

    searchBox.Name =
        "Search"

    searchBox.BackgroundColor3 =
        Color3.fromRGB(
            18,
            14,
            30
        )

    searchBox.BackgroundTransparency =
        0.04

    searchBox.BorderSizePixel =
        0

    searchBox.ClearTextOnFocus =
        false

    searchBox.Position =
        UDim2.new(
            0,
            74,
            0,
            summaryHeight + 2
        )

    searchBox.Size =
        UDim2.new(
            1,
            -144,
            0,
            20
        )

    searchBox.Font =
        Enum.Font.Code

    searchBox.PlaceholderText =
        "Search plant..."

    searchBox.PlaceholderColor3 =
        Color3.fromRGB(
            105,
            96,
            130
        )

    searchBox.Text =
        tostring(state.SearchText or "")

    searchBox.TextSize =
        11

    searchBox.TextColor3 =
        Color3.fromRGB(
            226,
            232,
            240
        )

    searchBox.TextXAlignment =
        Enum.TextXAlignment.Left

    searchBox.Parent =
        root

    local searchPadding =
        Instance.new("UIPadding")

    searchPadding.PaddingLeft =
        UDim.new(
            0,
            7
        )

    searchPadding.PaddingRight =
        UDim.new(
            0,
            7
        )

    searchPadding.Parent =
        searchBox

    local searchCorner =
        Instance.new("UICorner")

    searchCorner.CornerRadius =
        UDim.new(
            0,
            5
        )

    searchCorner.Parent =
        searchBox

    local searchStroke =
        Instance.new("UIStroke")

    searchStroke.Color =
        Color3.fromRGB(
            43,
            35,
            68
        )

    searchStroke.Transparency =
        0.10

    searchStroke.Parent =
        searchBox

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()

        GAG2FarmDetailsSetSearchText(
            searchBox.Text
        )
    end)

    local toggleButton =
        Instance.new("TextButton")

    toggleButton.Name =
        "ToggleRows"

    toggleButton.AnchorPoint =
        Vector2.new(
            1,
            0
        )

    toggleButton.BackgroundColor3 =
        Color3.fromRGB(
            18,
            14,
            30
        )

    toggleButton.BackgroundTransparency =
        0.06

    toggleButton.BorderSizePixel =
        0

    toggleButton.Position =
        UDim2.new(
            1,
            0,
            0,
            summaryHeight + 2
        )

    toggleButton.Size =
        UDim2.fromOffset(
            64,
            20
        )

    toggleButton.Font =
        Enum.Font.Code

    toggleButton.Text =
        state.ShowAll == true
        and "TOP"
        or "ALL"

    toggleButton.TextSize =
        12

    toggleButton.TextColor3 =
        Color3.fromRGB(
            196,
            181,
            253
        )

    toggleButton.Parent =
        root

    local toggleCorner =
        Instance.new("UICorner")

    toggleCorner.CornerRadius =
        UDim.new(
            0,
            5
        )

    toggleCorner.Parent =
        toggleButton

    local toggleStroke =
        Instance.new("UIStroke")

    toggleStroke.Color =
        Color3.fromRGB(
            43,
            35,
            68
        )

    toggleStroke.Transparency =
        0.10

    toggleStroke.Parent =
        toggleButton

    toggleButton.MouseButton1Click:Connect(function()

        GAG2FarmDetailsSetShowAll(
            GAG2_FARM_DETAILS_STATE.ShowAll ~= true
        )
    end)

    local columnHeader =
        Instance.new("Frame")

    columnHeader.Name =
        "ColumnHeader"

    columnHeader.BackgroundColor3 =
        Color3.fromRGB(
            15,
            13,
            24
        )

    columnHeader.BackgroundTransparency =
        0.32

    columnHeader.BorderSizePixel =
        0

    columnHeader.Position =
        UDim2.new(
            0,
            0,
            0,
            summaryHeight + 26
        )

    columnHeader.Size =
        UDim2.new(
            1,
            0,
            0,
            headerHeight
        )

    columnHeader.Parent =
        root

    local headerCorner =
        Instance.new("UICorner")

    headerCorner.CornerRadius =
        UDim.new(
            0,
            5
        )

    headerCorner.Parent =
        columnHeader

    GAG2FarmDetailsCreateColumnLabel(
        columnHeader,
        "PlantHeader",
        UDim2.fromOffset(
            7,
            0
        ),
        UDim2.new(
            0.46,
            -7,
            1,
            0
        ),
        '<font color="rgb(148,163,184)">Plant</font>',
        11,
        Color3.fromRGB(
            148,
            163,
            184
        ),
        Enum.TextXAlignment.Left
    )

    GAG2FarmDetailsCreateColumnLabel(
        columnHeader,
        "VariantHeader",
        UDim2.new(
            0.46,
            2,
            0,
            0
        ),
        UDim2.new(
            0.19,
            -2,
            1,
            0
        ),
        '<font color="rgb(148,163,184)">Variant</font>',
        11,
        Color3.fromRGB(
            148,
            163,
            184
        ),
        Enum.TextXAlignment.Left
    )

    GAG2FarmDetailsCreateColumnLabel(
        columnHeader,
        "FruitsHeader",
        UDim2.new(
            0.65,
            2,
            0,
            0
        ),
        UDim2.new(
            0.13,
            -2,
            1,
            0
        ),
        '<font color="rgb(148,163,184)">Fruits</font>',
        11,
        Color3.fromRGB(
            148,
            163,
            184
        ),
        Enum.TextXAlignment.Left
    )

    GAG2FarmDetailsCreateColumnLabel(
        columnHeader,
        "BestHeader",
        UDim2.new(
            0.78,
            0,
            0,
            0
        ),
        UDim2.new(
            0.22,
            -8,
            1,
            0
        ),
        '<font color="rgb(148,163,184)">Best</font>',
        11,
        Color3.fromRGB(
            148,
            163,
            184
        ),
        Enum.TextXAlignment.Right
    )

    local scrollY =
        summaryHeight
        + 26
        + headerHeight
        + 4

    local scroll =
        Instance.new("ScrollingFrame")

    scroll.Name =
        "Rows"

    scroll.BackgroundTransparency =
        1

    scroll.BorderSizePixel =
        0

    scroll.Position =
        UDim2.new(
            0,
            0,
            0,
            scrollY
        )

    scroll.Size =
        UDim2.new(
            1,
            0,
            1,
            -scrollY
        )

    scroll.ScrollBarThickness =
        3

    scroll.ScrollBarImageColor3 =
        Color3.fromRGB(
            150,
            95,
            255
        )

    scroll.CanvasSize =
        UDim2.new()

    scroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    scroll.Parent =
        root

    local layout =
        Instance.new("UIListLayout")

    layout.Name =
        "Layout"

    layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    layout.Padding =
        UDim.new(
            0,
            3
        )

    layout.Parent =
        scroll

    local padding =
        Instance.new("UIPadding")

    padding.PaddingTop =
        UDim.new(
            0,
            1
        )

    padding.PaddingBottom =
        UDim.new(
            0,
            6
        )

    padding.Parent =
        scroll

    state.PanelRoot =
        root

    state.SummaryLabel =
        summary

    state.HeaderLabel =
        plantedHeader

    state.ToggleButton =
        toggleButton

    state.SearchBox =
        searchBox

    state.ColumnHeader =
        columnHeader

    state.RowScroll =
        scroll

    state.RowLayout =
        layout

    return root
end

function GAG2FarmDetailsRenderPanel(snapshot)

    snapshot =
        type(snapshot) == "table"
        and snapshot
        or GAG2FarmDetailsBuildSnapshot()

    local state =
        GAG2_FARM_DETAILS_STATE

    if not state.PanelRoot
    or not state.PanelRoot.Parent then

        GAG2FarmDetailsCreatePanel()
    end

    local filteredRows =
        GAG2FarmDetailsGetFilteredRows(
            snapshot
        )

    local heightSnapshot = {
        Rows =
            filteredRows,
    }

    GAG2FarmDetailsApplyPanelHeight(
        heightSnapshot
    )

    if state.SummaryLabel then

        state.SummaryLabel.Text =
            GAG2FarmDetailsBuildSummaryText(
                snapshot
            )
    end

    if state.SearchBox
    and state.SearchBox.Text ~= tostring(state.SearchText or "") then

        state.SearchBox.Text =
            tostring(state.SearchText or "")
    end

    if state.ToggleButton then

        state.ToggleButton.Text =
            state.ShowAll == true
            and "TOP"
            or "ALL"
    end

    GAG2FarmDetailsClearScroll()

    local scroll =
        state.RowScroll

    if typeof(scroll) ~= "Instance" then
        return
    end

    if #filteredRows <= 0 then

        local searchText =
            CleanText(
                state.SearchText
            )

        local emptyText =
            searchText ~= ""
            and (
                '<font color="rgb(148,163,184)">No plants matching "'
                .. GAG2FarmDetailsEscape(searchText)
                .. '".</font>'
            )
            or '<font color="rgb(148,163,184)">No planted crops found.</font>'

        GAG2FarmDetailsCreateRow(
            scroll,
            emptyText,
            true
        )

        return
    end

    local topRows =
        math.max(
            1,
            math.floor(
                tonumber(state.TopRows)
                or 6
            )
        )

    local limit =
        state.ShowAll == true
        and #filteredRows
        or math.min(
            topRows,
            #filteredRows
        )

    for index = 1, limit do

        local row =
            filteredRows[index]

        local rowData =
            GAG2FarmDetailsBuildRowData(
                row
            )

        rowData.Index =
            index

        GAG2FarmDetailsCreateRow(
            scroll,
            rowData,
            false
        )
    end

    if state.ShowAll ~= true
    and #filteredRows > limit then

        GAG2FarmDetailsCreateRow(
            scroll,
            '<font color="rgb(148,163,184)">+'
            .. tostring(#filteredRows - limit)
            .. ' more  •  click ALL</font>',
            true
        )
    end
end

function GAG2FarmDetailsBuildText()

    local snapshot =
        GAG2FarmDetailsBuildSnapshot()

    local lines = {
        GAG2FarmDetailsBuildSummaryText(
            snapshot
        ),
        '<font color="rgb(196,181,253)"><b>Planted:</b></font>',
    }

    local topRows =
        math.max(
            1,
            math.floor(
                tonumber(GAG2_FARM_DETAILS_STATE.TopRows)
                or 6
            )
        )

    local limit =
        math.min(
            topRows,
            #snapshot.Rows
        )

    for index = 1, limit do

        table.insert(
            lines,
            GAG2FarmDetailsBuildRowText(
                snapshot.Rows[index]
            )
        )
    end

    if #snapshot.Rows > limit then

        table.insert(
            lines,
            '<font color="rgb(148,163,184)">+'
            .. tostring(#snapshot.Rows - limit)
            .. ' more</font>'
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

function GAG2FarmDetailsRefresh(force)

    local state =
        GAG2_FARM_DETAILS_STATE

    local now =
        os.clock()

    if force ~= true
    and now - tonumber(state.LastRefreshAt or 0) < tonumber(state.RefreshSeconds or 3) then
        return
    end

    state.LastRefreshAt =
        now

    local ok, snapshot =
        pcall(function()

            return GAG2FarmDetailsBuildSnapshot()
        end)

    if ok ~= true
    or type(snapshot) ~= "table" then

        local text =
            '<font color="rgb(196,181,253)"><b>Farm:</b></font> '
            .. '<font color="rgb(248,113,113)">Error</font>'
            .. '\n<font color="rgb(248,113,113)">Farm details failed.</font>'

        state.LastText =
            text

        if state.SummaryLabel then
            state.SummaryLabel.Text =
                text
        end

        if GAG2_FARM_DETAILS_LABEL
        and type(GAG2_FARM_DETAILS_LABEL.SetText) == "function" then

            pcall(function()

                GAG2_FARM_DETAILS_LABEL:SetText(
                    text
                )
            end)
        end

        return
    end

    local text =
        GAG2FarmDetailsBuildText()

    state.LastText =
        text

    if state.PanelRoot then

        pcall(function()

            GAG2FarmDetailsRenderPanel(
                snapshot
            )
        end)
    end

    if GAG2_FARM_DETAILS_LABEL
    and type(GAG2_FARM_DETAILS_LABEL.SetText) == "function" then

        pcall(function()

            GAG2_FARM_DETAILS_LABEL:SetText(
                text
            )
        end)
    end

    if Options.HolyGAG2FarmDetails
    and type(Options.HolyGAG2FarmDetails.SetText) == "function" then

        pcall(function()

            Options.HolyGAG2FarmDetails:SetText(
                text
            )
        end)
    end
end

function GAG2WeatherWebhookCanSend()

    if GAG2_WEATHER_WEBHOOK_ENABLED ~= true then
        return false
    end

    if type(GAG2_WEATHER_WEBHOOK_SENDER_USER_IDS) == "table"
    and next(GAG2_WEATHER_WEBHOOK_SENDER_USER_IDS) ~= nil then

        local userId =
            LOCAL_PLAYER
            and tonumber(LOCAL_PLAYER.UserId)
            or 0

        if GAG2_WEATHER_WEBHOOK_SENDER_USER_IDS[userId] ~= true then
            return false
        end
    end

    local relayUrl =
        CleanText(
            GAG2_WEATHER_RELAY_URL
            or GAG2_WEATHER_WEBHOOK_URL
        )

    if relayUrl == ""
    or relayUrl == "PASTE_YOUR_GOOGLE_WEB_APP_EXEC_URL_HERE"
    or relayUrl == "PUT_WEATHER_WEBHOOK_URL_HERE" then
        return false
    end

    local relaySecret =
        CleanText(
            GAG2_WEATHER_RELAY_SECRET
        )

    if relaySecret == ""
    or relaySecret == "PUT_WEATHER_RELAY_SECRET_HERE" then
        return false
    end

    return true
end

function GAG2WeatherWebhookGetRequestFunction()

    if type(GAG2ExecutorGetRequestFunction) == "function" then

        local requestFunction =
            GAG2ExecutorGetRequestFunction()

        if type(requestFunction) == "function" then
            return requestFunction
        end
    end

    return request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )
        or (
            fluxus
            and fluxus.request
        )
end

function GAG2WeatherWebhookGetNow()

    local ok, value =
        pcall(function()

            return workspace:GetServerTimeNow()
        end)

    if ok == true
    and tonumber(value) then

        return math.floor(
            tonumber(value)
        )
    end

    return os.time()
end

function GAG2WeatherWebhookFormatSeconds(seconds)

    seconds =
        math.max(
            0,
            math.floor(
                tonumber(seconds)
                or 0
            )
        )

    local hours =
        math.floor(seconds / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    local remain =
        seconds % 60

    if hours > 0 then

        return tostring(hours)
            .. "h "
            .. tostring(minutes)
            .. "m"
    end

    if minutes > 0 then

        return tostring(minutes)
            .. "m "
            .. tostring(remain)
            .. "s"
    end

    return tostring(remain)
        .. "s"
end

function GAG2WeatherWebhookEmoji(weatherName)

    weatherName =
        CleanText(weatherName)

    if weatherName == "Rain" then
        return "🌧️"
    end

    if weatherName == "Lightning" then
        return "⚡"
    end

    if weatherName == "Rainbow" then
        return "🌈"
    end

    if weatherName == "Snowfall" then
        return "❄️"
    end

    if weatherName == "Starfall" then
        return "🌠"
    end

    if weatherName == "Moon" then
        return "🌙"
    end

    if weatherName == "Goldmoon" then
        return "🌕"
    end

    if weatherName == "Rainbow Moon" then
        return "🌈🌙"
    end

    if weatherName == "Bloodmoon" then
        return "🩸🌙"
    end

    return "🌤️"
end

function GAG2WeatherWebhookColor(weatherName)

    weatherName =
        CleanText(weatherName)

    if weatherName == "Rain" then
        return 0x60A5FA
    end

    if weatherName == "Lightning" then
        return 0xFACC15
    end

    if weatherName == "Rainbow"
    or weatherName == "Rainbow Moon" then
        return 0xE879F9
    end

    if weatherName == "Snowfall" then
        return 0xBAE6FD
    end

    if weatherName == "Starfall" then
        return 0xC084FC
    end

    if weatherName == "Goldmoon" then
        return 0xFACC15
    end

    if weatherName == "Bloodmoon" then
        return 0xEF4444
    end

    if weatherName == "Moon" then
        return 0x93C5FD
    end

    return 0xC4B5FD
end

function GAG2WeatherWebhookRoleId(weatherName)

    if type(GAG2_WEATHER_WEBHOOK_ROLE_IDS) ~= "table" then
        return ""
    end

    local roleId =
        CleanText(
            GAG2_WEATHER_WEBHOOK_ROLE_IDS[
                CleanText(weatherName)
            ]
        ):gsub("%D", "")

    if roleId == ""
    or roleId:find("PUT", 1, true) then
        return ""
    end

    return roleId
end

function GAG2WeatherWebhookIsEnabledEvent(weatherName)

    weatherName =
        CleanText(weatherName)

    if weatherName == "" then
        return false
    end

    if type(GAG2_WEATHER_WEBHOOK_EVENTS) ~= "table" then
        return true
    end

    return GAG2_WEATHER_WEBHOOK_EVENTS[weatherName] == true
end

function GAG2WeatherWebhookGetCurrentEvent()

    local weatherName =
        CleanText(
            workspace:GetAttribute("ActiveWeather")
        )

    if weatherName == "" then
        return nil,
            "missing ActiveWeather"
    end

    if GAG2WeatherWebhookIsEnabledEvent(weatherName) ~= true then

        return nil,
            "event disabled: "
            .. weatherName
    end

    local phaseName =
        CleanText(
            workspace:GetAttribute("ActivePhase")
        )

    local now =
        GAG2WeatherWebhookGetNow()

    local rawPhaseDuration =
        tonumber(
            workspace:GetAttribute("PhaseDuration")
        )
        or 0

    local phaseEnd =
        0

    local remaining =
        0

    if rawPhaseDuration > 1000000000 then

        phaseEnd =
            rawPhaseDuration

        remaining =
            math.max(
                0,
                math.floor(
                    phaseEnd - now
                )
            )

    elseif rawPhaseDuration > 0 then

        phaseEnd =
            now + rawPhaseDuration

        remaining =
            math.max(
                0,
                math.floor(
                    rawPhaseDuration
                )
            )
    end

    local phaseEndBucket =
        "noend"

    if phaseEnd > 0 then

        phaseEndBucket =
            tostring(
                math.floor(
                    phaseEnd / 30
                )
            )
    end

    -- Important:
    -- Do not include phaseName in the key.
    -- ActiveWeather / ActivePhase / PhaseDuration can update separately,
    -- and including phaseName can cause 2-3 Discord sends for one event.
    local key =
        tostring(game.PlaceId)
        .. ":"
        .. weatherName
        .. ":"
        .. tostring(phaseEndBucket)

    return {
        Name = weatherName,
        Phase = phaseName,
        Now = now,
        PhaseEnd = phaseEnd,
        Remaining = remaining,
        Key = key,
    }
end

function GAG2WeatherWebhookAlreadySent(key)

    key =
        CleanText(key)

    if key == "" then
        return true
    end

    local sentAt =
        tonumber(
            GAG2_WEATHER_WEBHOOK_SENT[key]
        )

    if not sentAt then
        return false
    end

    if os.clock() - sentAt > 7200 then

        GAG2_WEATHER_WEBHOOK_SENT[key] =
            nil

        return false
    end

    return true
end

function GAG2WeatherWebhookMarkSent(key)

    key =
        CleanText(key)

    if key == "" then
        return
    end

    GAG2_WEATHER_WEBHOOK_SENT[key] =
        os.clock()
end

function GAG2WeatherWebhookBuildPayload(event)

    local weatherName =
        CleanText(
            event.Name
        )

    local emoji =
        GAG2WeatherWebhookEmoji(
            weatherName
        )

    local roleId =
        GAG2WeatherWebhookRoleId(
            weatherName
        )

    local content =
        roleId ~= ""
        and (
            "<@&"
            .. roleId
            .. ">"
        )
        or ""

    local description =
        "• "
        .. emoji
        .. " **"
        .. weatherName
        .. "**"

    local fields = {
        {
            name = "Weather",
            value =
                emoji
                .. " "
                .. weatherName,
            inline = true,
        },

        {
            name = "Phase",
            value =
                CleanText(event.Phase) ~= ""
                and CleanText(event.Phase)
                or "?",
            inline = true,
        },

        {
            name = "Ends In",
            value =
                GAG2WeatherWebhookFormatSeconds(
                    event.Remaining
                ),
            inline = true,
        },
    }

    local embed = {
        title = "Weather Events",
        description = description,
        color =
            GAG2WeatherWebhookColor(
                weatherName
            ),

        fields = fields,

        footer = {
            text = "HOLY",
        },

        timestamp =
            DateTime.now():ToIsoDate(),
    }

    local payload = {
        username =
            CleanText(GAG2_WEATHER_WEBHOOK_USERNAME) ~= ""
            and CleanText(GAG2_WEATHER_WEBHOOK_USERNAME)
            or "GAG 2 Stocks",

        content =
            content,

        allowed_mentions =
            roleId ~= ""
            and {
                parse = {},
                roles = {
                    roleId,
                },
            }
            or {
                parse = {},
            },

        embeds = {
            embed,
        },
    }

    local avatarUrl =
        CleanText(
            GAG2_WEATHER_WEBHOOK_AVATAR_URL
        )

    if avatarUrl ~= "" then
        payload.avatar_url =
            avatarUrl
    end

    return payload
end

function GAG2WeatherWebhookSend(event)

    if type(event) ~= "table" then
        return false,
            "bad event"
    end

    if GAG2WeatherWebhookCanSend() ~= true then
        return false,
            "disabled or missing relay"
    end

    local relayUrl =
        CleanText(
            GAG2_WEATHER_RELAY_URL
            or GAG2_WEATHER_WEBHOOK_URL
        )

    local relaySecret =
        CleanText(
            GAG2_WEATHER_RELAY_SECRET
        )

    local weatherName =
        CleanText(
            event.Name
        )

    local phaseName =
        CleanText(
            event.Phase
        )

    local remaining =
        math.max(
            0,
            math.floor(
                tonumber(event.Remaining)
                or 0
            )
        )

    local phaseEnd =
        tonumber(event.PhaseEnd)
        or 0

    if phaseEnd <= 0
    and remaining > 0 then

        phaseEnd =
            os.time() + remaining
    end

    local eventKey =
        CleanText(
            event.Key
        )

    if eventKey == "" then

        local phaseEndBucket =
            phaseEnd > 0
            and tostring(
                math.floor(
                    phaseEnd / 30
                )
            )
            or "noend"

        eventKey =
            tostring(game.PlaceId)
            .. ":"
            .. weatherName
            .. ":"
            .. tostring(phaseEndBucket)
    end

    local payload = {
        secret =
            relaySecret,

        placeId =
            tostring(game.PlaceId),

        jobId =
            tostring(game.JobId),

        weatherName =
            weatherName,

        phase =
            phaseName ~= ""
            and phaseName
            or "Active",

        remaining =
            tostring(remaining),

        phaseEnd =
            tostring(
                math.floor(
                    phaseEnd
                )
            ),

        eventKey =
            eventKey,
    }

    local function encodeQueryValue(value)

        local text =
            tostring(value or "")

        local ok, encoded =
            pcall(function()

                return HttpService:UrlEncode(
                    text
                )
            end)

        if ok == true
        and type(encoded) == "string" then

            return encoded
        end

        return text
            :gsub("%%", "%%25")
            :gsub(" ", "%%20")
            :gsub("\n", "%%0A")
            :gsub("\r", "%%0D")
            :gsub("&", "%%26")
            :gsub("=", "%%3D")
            :gsub("?", "%%3F")
            :gsub("#", "%%23")
    end

    local function buildGetUrl()

        local parts =
            {}

        for key, value in pairs(payload) do

            parts[#parts + 1] =
                encodeQueryValue(key)
                .. "="
                .. encodeQueryValue(value)
        end

        table.sort(
            parts
        )

        local separator =
            relayUrl:find(
                "?",
                1,
                true
            )
            and "&"
            or "?"

        return relayUrl
            .. separator
            .. table.concat(
                parts,
                "&"
            )
    end

    local function previewBody(body)

        local text =
            tostring(body or "")
                :gsub("\r", " ")
                :gsub("\n", " ")
                :gsub("%s+", " ")

        if #text > 220 then

            text =
                text:sub(
                    1,
                    220
                )
                .. "..."
        end

        if text == "" then
            text =
                "empty"
        end

        return text
    end

    local function parseRelayBody(body, label)

        body =
            tostring(body or "")

        if body:sub(1, 3) == "\239\187\191" then

            body =
                body:sub(4)
        end

        local decodeOk, decoded =
            pcall(function()

                return HttpService:JSONDecode(
                    body
                )
            end)

        if decodeOk == true
        and type(decoded) == "table" then

            if decoded.ok == true then

                if decoded.deduped == true then
                    return true,
                        "deduped"
                end

                if decoded.sent == true then
                    return true,
                        "sent"
                end

                if decoded.skipped == true then
                    return true,
                        "skipped"
                end

                return true,
                    "ok"
            end

            return false,
                tostring(
                    decoded.error
                    or decoded.message
                    or "relay rejected request"
                )
        end

        local lower =
            body:sub(
                1,
                400
            ):lower()

        if lower:find("<!doctype html", 1, true)
        or lower:find("<html", 1, true) then

            return false,
                tostring(label or "GET")
                .. " returned HTML: "
                .. previewBody(body)
        end

        return false,
            tostring(label or "GET")
            .. " invalid JSON: "
            .. previewBody(body)
    end

    local function getResponseBody(response)

        if type(response) == "string" then
            return response
        end

        if type(response) ~= "table" then
            return ""
        end

        return tostring(
            response.Body
            or response.body
            or response.ResponseBody
            or response.responseBody
            or ""
        )
    end

    local function getResponseCode(response)

        if type(response) ~= "table" then
            return 0
        end

        local raw =
            response.StatusCode
            or response.statusCode
            or response.Status
            or response.status
            or 0

        return tonumber(raw)
            or tonumber(
                tostring(raw):match("(%d+)")
            )
            or 0
    end

    local function parseRelayResponse(response, label)

        local body =
            getResponseBody(
                response
            )

        local ok, info =
            parseRelayBody(
                body,
                label
            )

        if ok == true then
            return true,
                info
        end

        local code =
            getResponseCode(
                response
            )

        if code >= 200
        and code < 300
        and body == "" then

            return true,
                "sent"
        end

        if code > 0 then

            return false,
                "HTTP "
                .. tostring(code)
                .. " | "
                .. tostring(info)
        end

        return false,
            info
    end

    local getUrl =
        buildGetUrl()

    local firstError =
        nil

    local httpGetOk, httpGetBody =
        pcall(function()

            return game:HttpGet(
                getUrl,
                true
            )
        end)

    if httpGetOk == true
    and type(httpGetBody) == "string"
    and httpGetBody ~= "" then

        local accepted, info =
            parseRelayBody(
                httpGetBody,
                "game:HttpGet"
            )

        if accepted == true then
            return true,
                info
        end

        firstError =
            info

    elseif httpGetOk ~= true then

        firstError =
            tostring(httpGetBody)
    end

    local requestFunction =
        GAG2WeatherWebhookGetRequestFunction()

    if type(requestFunction) ~= "function" then

        return false,
            tostring(
                firstError
                or "request unsupported"
            )
    end

    local requestOk, response =
        pcall(function()

            return requestFunction({
                Url =
                    getUrl,

                Method =
                    "GET",

                Headers = {
                    ["Accept"] =
                        "application/json",

                    ["Cache-Control"] =
                        "no-cache",
                },

                Redirect =
                    true,
            })
        end)

    if requestOk ~= true then

        return false,
            tostring(response)
    end

    local accepted, info =
        parseRelayResponse(
            response,
            "GET request"
        )

    if accepted == true then
        return true,
            info
    end

    return false,
        tostring(
            info
            or firstError
            or "GET relay failed"
        )
end

function GAG2WeatherWebhookScan(force)

    local state =
        GAG2_WEATHER_WEBHOOK_STATE

    local now =
        os.clock()

    if force ~= true
    and now - tonumber(state.LastScanAt or 0) < tonumber(state.MinScanDelay or 1) then
        return
    end

    state.LastScanAt =
        now

    local event, reason =
        GAG2WeatherWebhookGetCurrentEvent()

    if not event then
        return false,
            reason
    end

    if GAG2WeatherWebhookAlreadySent(event.Key) == true then
        return false,
            "already sent"
    end

    local sent, sendInfo =
        GAG2WeatherWebhookSend(
            event
        )

    if sent == true then

        GAG2WeatherWebhookMarkSent(
            event.Key
        )

        state.LastKey =
            event.Key
    end

    return sent,
        sendInfo
end

function GAG2WeatherWebhookArm()

    local state =
        GAG2_WEATHER_WEBHOOK_STATE

    if state.Armed == true then
        return
    end

    state.Armed =
        true

    local function trigger()

        task.defer(function()

            task.wait(
                0.15
            )

            GAG2WeatherWebhookScan(
                true
            )
        end)
    end

    pcall(function()

        workspace:GetAttributeChangedSignal("ActiveWeather"):Connect(
            trigger
        )
    end)

    pcall(function()

        workspace:GetAttributeChangedSignal("ActivePhase"):Connect(
            trigger
        )
    end)

    pcall(function()

        workspace:GetAttributeChangedSignal("PhaseDuration"):Connect(
            trigger
        )
    end)

    task.defer(function()

        task.wait(
            2
        )

        GAG2WeatherWebhookScan(
            true
        )
    end)
end

GAG2WeatherWebhookArm()

function HOLYTestWeatherRelay()

    if type(GAG2WeatherWebhookSend) ~= "function" then

        warn(
            "[HOLY WEATHER TEST]",
            "GAG2WeatherWebhookSend is missing. Main script did not finish loading."
        )

        return false,
            "GAG2WeatherWebhookSend missing"
    end

    local eventKey =
        "manual-test-rain-"
        .. tostring(os.time())
        .. "-"
        .. tostring(math.random(1000, 9999))

    local ok, info =
        GAG2WeatherWebhookSend({
            Name =
                "Rain",

            Phase =
                "Manual Test",

            Remaining =
                180,

            PhaseEnd =
                os.time() + 180,

            Key =
                eventKey,
        })

    print(
        "[HOLY WEATHER TEST]",
        tostring(ok),
        tostring(info)
    )

    return ok,
        info
end

pcall(function()

    local environment =
        _G

    if type(getgenv) == "function" then

        local resolved =
            getgenv()

        if type(resolved) == "table" then

            environment =
                resolved
        end
    end

    environment.HOLYTestWeatherRelay =
        HOLYTestWeatherRelay

    environment.GAG2WeatherWebhookSend =
        GAG2WeatherWebhookSend

    environment.GAG2WeatherWebhookScan =
        GAG2WeatherWebhookScan

    environment.GAG2WeatherWebhookGetCurrentEvent =
        GAG2WeatherWebhookGetCurrentEvent
end)

function StartHomeActivePetsLoop()

    if HomeActivePetsLoopRunning == true then
        return
    end

    HomeActivePetsLoopRunning =
        true

    task.spawn(function()

        while HomeActivePetsLoopRunning == true do

            if type(RefreshHomeActivePets) == "function" then

                RefreshHomeActivePets()
            end

            if type(GAG2MoonPredictorRefresh) == "function" then

                GAG2MoonPredictorRefresh()
            end

            if type(GAG2FarmDetailsRefresh) == "function" then

                GAG2FarmDetailsRefresh()
            end

            if type(GAG2WeatherWebhookScan) == "function" then

                GAG2WeatherWebhookScan()
            end

            GAG2RareWebhookScan()

            task.wait(
                1
            )
        end
    end)
end

function GAG2RareWebhookPetKey(name)

    return CleanText(name)
        :lower()
        :gsub("[_%s]+", "")
        :gsub("[^%w]", "")
end

function GAG2RareWebhookIsTarget(entry)

    if type(entry) ~= "table" then
        return false
    end

    local key =
        GAG2RareWebhookPetKey(
            entry.Name
        )

    return GAG2_RARE_PET_WEBHOOK_TARGETS[key] == true
end

function GAG2RareWebhookGetEntryKey(entry)

    if type(entry) ~= "table" then
        return ""
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid ~= "" then
        return uuid
    end

    return GAG2RareWebhookPetKey(
        entry.Name
    )
end

function GAG2RareWebhookGetImageUrl(entry)

    if type(entry) ~= "table" then
        return ""
    end

    local petKey =
        GAG2RareWebhookPetKey(
            entry.Name
        )

    return CleanText(
        GAG2_RARE_PET_WEBHOOK_IMAGES[petKey]
    )
end

function GAG2RareWebhookGetRequestFunction()

    return request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )
        or (
            fluxus
            and fluxus.request
        )
end

function GAG2RareWebhookSend(entry)

    if type(entry) ~= "table" then
        return false
    end

    local webhookUrl =
        CleanText(
            GAG2_RARE_PET_WEBHOOK_URL
        )

    if webhookUrl == "" then
        return false
    end

    local requestFunction =
        GAG2RareWebhookGetRequestFunction()

    if type(requestFunction) ~= "function" then

        warn(
            "[HOLY WEBHOOK]",
            "request function unsupported"
        )

        return false
    end

    local petName =
        CleanText(entry.Name)

    local priceText =
        CleanText(entry.Price)

    if priceText == "" then
        priceText = "?"
    end

    local timerText =
        CleanText(entry.Timer)

    if timerText == "" then
        timerText = "?"
    end

    local distanceText =
        CleanText(entry.Distance)

    if distanceText == "" then
        distanceText = "?"
    end

    local imageUrl =
        GAG2RareWebhookGetImageUrl(
            entry
        )

    local joinCode =
        GAG2BuildJoinCode(
            game.PlaceId,
            game.JobId
        )

    local embed = {

        title =
            "🌟 Rare Pet Found • "
            .. petName,

        color =
            0xC4B5FD,

        fields = {

            {
                name = "Pet",
                value = petName,
                inline = true,
            },

            {
                name = "Price",
                value = priceText,
                inline = true,
            },

            {
                name = "Timer",
                value = timerText,
                inline = true,
            },

            {
                name = "Distance",
                value = distanceText,
                inline = true,
            },

            {
                name = "Players",
                value =
                    tostring(#Players:GetPlayers()),
                inline = true,
            },

            {
                name = "PlaceId",
                value =
                    tostring(game.PlaceId),
                inline = true,
            },

            {
                name = "Join Code",
                value =
                    "```"
                    .. tostring(joinCode)
                    .. "```",
                inline = false,
            },

            {
                name = "JobId",
                value =
                    "```"
                    .. tostring(game.JobId)
                    .. "```",
                inline = false,
            },
        },

        footer = {
            text = "HOLY",
        },

        timestamp =
            DateTime.now():ToIsoDate(),
    }

    if imageUrl ~= "" then

        embed.image = {
            url = imageUrl,
        }
    end

    local roleId =
        CleanText(
            GAG2_RARE_PET_WEBHOOK_ROLE_ID
        ):gsub("%D", "")

    local pingContent =
        roleId ~= ""
        and (
            "<@&"
            .. roleId
            .. "> 🌟 Rare pet found: **"
            .. petName
            .. "**"
            .. "\n`"
            .. tostring(joinCode)
            .. "`"
        )
        or (
            "🌟 Rare pet found: **"
            .. petName
            .. "**"
            .. "\n`"
            .. tostring(joinCode)
            .. "`"
        )

    local payload = {
        username =
            "HOLY",

        content =
            pingContent,

        allowed_mentions =
            roleId ~= ""
            and {
                parse = {
                    "roles",
                },
            }
            or {
                parse = {},
            },

        embeds = {
            embed,
        },
    }

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body =
                    (function()

                        print(
                            "[HOLY WEBHOOK]",
                            "payload content:",
                            tostring(payload.content)
                        )

                        return HttpService:JSONEncode(
                            payload
                        )
                    end)(),
            })
        end)

    if ok ~= true then

        warn(
            "[HOLY WEBHOOK]",
            "send failed",
            tostring(response)
        )

        return false
    end

    local statusCode =
        response
        and (
            response.StatusCode
            or response.statusCode
            or response.Status
            or response.status
        )

    if statusCode
    and (
        tonumber(statusCode) < 200
        or tonumber(statusCode) >= 300
    ) then

        warn(
            "[HOLY WEBHOOK]",
            "bad status",
            tostring(statusCode),
            tostring(
                response.Body
                or response.body
                or ""
            )
        )

        return false
    end

    print(
        "[HOLY WEBHOOK]",
        "sent rare pet alert:",
        petName
    )

    return true
end

function GAG2RareWebhookScan()

    local entries, reason =
        SniperGetActiveEntries()

    if reason ~= "ok" then
        return
    end

    for _, entry in ipairs(entries) do

        if GAG2RareWebhookIsTarget(entry) == true then

            local key =
                GAG2RareWebhookGetEntryKey(
                    entry
                )

            if key ~= ""
            and GAG2_RARE_PET_WEBHOOK_SENT[key] ~= true then

                GAG2_RARE_PET_WEBHOOK_SENT[key] =
                    true

                task.spawn(function()

                    local sent =
                        GAG2RareWebhookSend(
                            entry
                        )

                    if sent ~= true then

                        GAG2_RARE_PET_WEBHOOK_SENT[key] =
                            nil
                    end
                end)
            end
        end
    end
end

--==================================================
-- [4.58] MAILBOX
-- Sends pet batches through Mailbox.SendBatch.
-- Confirmed packet:
-- MailboxSendBatch(targetUserId, {{ItemKey = petId, Count = amount, Category = "Pets"}}, message)
--==================================================

GAG2_MAILBOX_STATE =
    GAG2_MAILBOX_STATE
    or {
        TargetText = "",
        PetId = "",
        PetChoice = "None",
        Amount = 500,
        Message = "",

        PetChoices = {
            "None",
        },

        ChoiceToPetId = {},
        PetCache = {},
        InventoryPets = {},

        Packets = {},
        LastStatus = "Idle.",
        LastTargetUserId = nil,
        LastPetId = "",
        LastAmount = 0,
    }


function GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    state.SelectedCategory =
        state.SelectedCategory
        or "All"

    state.ItemChoice =
        state.ItemChoice
        or "None"

    state.CategoryChoices =
        type(state.CategoryChoices) == "table"
        and state.CategoryChoices
        or {
            "All",
        }

    state.ItemChoices =
        type(state.ItemChoices) == "table"
        and state.ItemChoices
        or {
            "None",
        }

    state.ChoiceToSendable =
        type(state.ChoiceToSendable) == "table"
        and state.ChoiceToSendable
        or {}

    state.Sendables =
        type(state.Sendables) == "table"
        and state.Sendables
        or {}

    state.LastCategory =
        state.LastCategory
        or ""

    state.LastItemKey =
        state.LastItemKey
        or ""

    state.LastSendCount =
        tonumber(state.LastSendCount)
        or 0

    state.LastBatchRows =
        tonumber(state.LastBatchRows)
        or 0

    state.MaxRowsPerMail =
        math.clamp(
            math.floor(
                tonumber(state.MaxRowsPerMail)
                or 20
            ),
            1,
            20
        )

    state.Auto =
        type(state.Auto) == "table"
        and state.Auto
        or {}

    local auto =
        state.Auto

    auto.Enabled =
        auto.Enabled == true

    auto.Running =
        auto.Running == true

    auto.Rules =
        type(auto.Rules) == "table"
        and auto.Rules
        or {}

    auto.Receipts =
        type(auto.Receipts) == "table"
        and auto.Receipts
        or {}

    auto.TargetCache =
        type(auto.TargetCache) == "table"
        and auto.TargetCache
        or {}

    auto.RuleChoiceMap =
        type(auto.RuleChoiceMap) == "table"
        and auto.RuleChoiceMap
        or {}

    auto.ReceiptChoiceMap =
        type(auto.ReceiptChoiceMap) == "table"
        and auto.ReceiptChoiceMap
        or {}

    auto.PetSnapshot =
        type(auto.PetSnapshot) == "table"
        and auto.PetSnapshot
        or {}

    auto.RecipientText =
        tostring(
            auto.RecipientText
            or ""
        )

    auto.Category =
        tostring(
            auto.Category
            or "None"
        )

    auto.ItemChoice =
        tostring(
            auto.ItemChoice
            or "None"
        )

    auto.TriggerMode =
        tostring(
            auto.TriggerMode
            or "At Least"
        )

    auto.TriggerAmount =
        math.max(
            1,
            math.floor(
                tonumber(auto.TriggerAmount)
                or 5
            )
        )

    auto.SendMode =
        tostring(
            auto.SendMode
            or "Fixed Amount"
        )

    auto.SendAmount =
        math.max(
            1,
            math.floor(
                tonumber(auto.SendAmount)
                or 5
            )
        )

    auto.KeepAmount =
        math.max(
            0,
            math.floor(
                tonumber(auto.KeepAmount)
                or 0
            )
        )

    auto.PetVariant =
        tostring(
            auto.PetVariant
            or "Any Variant"
        )

    auto.PetSize =
        tostring(
            auto.PetSize
            or "Any Size"
        )

    auto.Message =
        tostring(
            auto.Message
            or ""
        )

    auto.CheckInterval =
        math.clamp(
            tonumber(auto.CheckInterval)
            or 3,
            1,
            30
        )

    auto.MailCooldown =
        math.clamp(
            tonumber(auto.MailCooldown)
            or 3,
            1,
            30
        )

    if auto.StopAfterFailedSends == nil then

        auto.StopAfterFailedSends =
            true

    else

        auto.StopAfterFailedSends =
            auto.StopAfterFailedSends == true
    end

    auto.ConsecutiveFailures =
        tonumber(auto.ConsecutiveFailures)
        or 0

    auto.SessionMails =
        tonumber(auto.SessionMails)
        or 0

    auto.SessionItems =
        tonumber(auto.SessionItems)
        or 0

    auto.LastCheckAt =
        tonumber(auto.LastCheckAt)
        or 0

    auto.LastPetRefreshAt =
        tonumber(auto.LastPetRefreshAt)
        or 0

    auto.NextAllowedAt =
        tonumber(auto.NextAllowedAt)
        or 0

    auto.LoopToken =
        tonumber(auto.LoopToken)
        or 0

    auto.LastAction =
        tostring(
            auto.LastAction
            or "Idle."
        )

    auto.LastRuleText =
        tostring(
            auto.LastRuleText
            or "None"
        )

    auto.SelectedRuleChoice =
        tostring(
            auto.SelectedRuleChoice
            or "None"
        )

    auto.SelectedReceiptChoice =
        tostring(
            auto.SelectedReceiptChoice
            or "None"
        )

    auto.RefreshingControls =
        auto.RefreshingControls == true

    auto.RulesLoaded =
        auto.RulesLoaded == true
end

GAG2MailboxEnsureUniversalState()

GAG2_MAILBOX_CONTROLS =
    GAG2_MAILBOX_CONTROLS
    or {}

function GAG2MailboxClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2MailboxSetStatus(text)

    GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    local auto =
        state.Auto

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2MailboxStatus then

        Options.HolyGAG2MailboxStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Mailbox</b></font>'
            .. '\n'
            .. tostring(state.LastStatus)
            .. '\n\n'
            .. '<font color="rgb(148,163,184)"><b>Manual Send</b></font>'
            .. '\nTarget: '
            .. tostring(state.TargetText or "")
            .. '\nCategory: '
            .. tostring(state.SelectedCategory or "All")
            .. '\nItem: '
            .. tostring(state.ItemChoice or "None")
            .. '\nAmount: '
            .. tostring(state.Amount or 1)
            .. ' | Max rows: '
            .. tostring(state.MaxRowsPerMail or 20)
            .. '\n\n'
            .. '<font color="rgb(148,163,184)"><b>Automatic Send</b></font>'
            .. '\nState: '
            .. (
                auto.Enabled == true
                and (
                    auto.Running == true
                    and "Running"
                    or "Starting"
                )
                or "Stopped"
            )
            .. '\nRules: '
            .. tostring(#auto.Rules)
            .. ' | Failures: '
            .. tostring(auto.ConsecutiveFailures)
            .. '\nCurrent: '
            .. tostring(auto.LastRuleText or "None")
            .. '\nLast: '
            .. tostring(auto.LastAction or "Idle.")
            .. '\nSession: '
            .. tostring(auto.SessionMails)
            .. ' mail(s) | '
            .. tostring(auto.SessionItems)
            .. ' item(s)'
        )
    end
end

function GAG2MailboxGetAmount()

    local state =
        GAG2_MAILBOX_STATE

    local amount =
        math.floor(
            tonumber(state.Amount)
            or 1
        )

    return math.clamp(
        amount,
        1,
        999999
    )
end

function GAG2MailboxSetTarget(value)

    GAG2_MAILBOX_STATE.TargetText =
        GAG2MailboxClean(value)

    MarkConfigDirty()
end

function GAG2MailboxSetPetId(value)

    GAG2_MAILBOX_STATE.PetId =
        GAG2MailboxClean(value)

    MarkConfigDirty()
end

function GAG2MailboxSetAmount(value)

    GAG2_MAILBOX_STATE.Amount =
        math.clamp(
            math.floor(
                tonumber(value)
                or 1
            ),
            1,
            999999
        )

    GAG2MailboxSetStatus(
        "Send Amount set: "
        .. tostring(GAG2_MAILBOX_STATE.Amount)
    )

    MarkConfigDirty()
end

function GAG2MailboxSetMessage(value)

    GAG2_MAILBOX_STATE.Message =
        tostring(value or "")

    MarkConfigDirty()
end

function GAG2MailboxSafeRawGet(tbl, key)

    if type(tbl) ~= "table" then
        return nil
    end

    local ok, result =
        pcall(function()

            return rawget(
                tbl,
                key
            )
        end)

    if ok == true then
        return result
    end

    return nil
end

function GAG2MailboxSafePairs(tbl)

    if type(tbl) ~= "table" then
        return {}
    end

    local ok, rows =
        pcall(function()

            local result =
                {}

            for key, value in pairs(tbl) do

                table.insert(result, {
                    Key = key,
                    Value = value,
                })
            end

            return result
        end)

    if ok == true
    and type(rows) == "table" then

        return rows
    end

    return {}
end

function GAG2MailboxIsUuid(value)

    value =
        GAG2MailboxClean(value):lower()

    return value:match(
        "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
    ) ~= nil
end

function GAG2MailboxShortUuid(value)

    value =
        GAG2MailboxClean(value)

    if #value <= 8 then
        return value
    end

    return value:sub(
        1,
        8
    )
end

function GAG2MailboxReadPetName(petData, fallback)

    fallback =
        GAG2MailboxClean(fallback)

    if type(petData) == "table" then

        local keys = {
            "Name",
            "PetName",
            "PetType",
            "Type",
            "f",
        }

        for _, key in ipairs(keys) do

            local value =
                GAG2MailboxClean(
                    GAG2MailboxSafeRawGet(
                        petData,
                        key
                    )
                )

            if value ~= "" then
                return value
            end
        end
    end

    if fallback ~= "" then
        return fallback
    end

    return "Unknown Pet"
end

function GAG2MailboxReadPetExtra(petData)

    if type(petData) ~= "table" then
        return ""
    end

    local parts =
        {}

    local mutation =
        GAG2MailboxClean(
            GAG2MailboxSafeRawGet(
                petData,
                "Mutation"
            )
        )

    local level =
        GAG2MailboxClean(
            GAG2MailboxSafeRawGet(
                petData,
                "Level"
            )
            or GAG2MailboxSafeRawGet(
                petData,
                "Age"
            )
        )

    local equipped =
        GAG2MailboxSafeRawGet(
            petData,
            "Equipped"
        )

    if mutation ~= ""
    and mutation ~= "None"
    and mutation ~= "Normal" then

        table.insert(
            parts,
            mutation
        )
    end

    if level ~= "" then

        table.insert(
            parts,
            "Age "
            .. tostring(level)
        )
    end

    if equipped == true then

        table.insert(
            parts,
            "Equipped"
        )
    end

    return table.concat(
        parts,
        " · "
    )
end

function GAG2MailboxAddPetEntry(target, seen, uuid, petData, source)

    uuid =
        GAG2MailboxClean(uuid)

    if GAG2MailboxIsUuid(uuid) ~= true then
        return false
    end

    if seen[uuid] == true then
        return false
    end

    seen[uuid] =
        true

    local name =
        GAG2MailboxReadPetName(
            petData,
            "Unknown Pet"
        )

    local extra =
        GAG2MailboxReadPetExtra(
            petData
        )

    table.insert(target, {
        Id = uuid,
        Name = name,
        Extra = extra,
        Source = tostring(source or "unknown"),
        Raw = petData,
    })

    return true
end

function GAG2MailboxScanPetTable(petsTable, target, seen, source)

    if type(petsTable) ~= "table" then
        return 0
    end

    local added =
        0

    local scanned =
        0

    for _, row in ipairs(GAG2MailboxSafePairs(petsTable)) do

        scanned = scanned + 1

        if scanned > 3000 then
            break
        end

        local key =
            GAG2MailboxClean(row.Key)

        local value =
            row.Value

        local uuid =
            ""

        if GAG2MailboxIsUuid(key) == true then

            uuid =
                key

        elseif type(value) == "table" then

            uuid =
                GAG2MailboxClean(
                    GAG2MailboxSafeRawGet(value, "Id")
                    or GAG2MailboxSafeRawGet(value, "UUID")
                    or GAG2MailboxSafeRawGet(value, "Uuid")
                    or GAG2MailboxSafeRawGet(value, "ItemKey")
                )
        end

        if GAG2MailboxAddPetEntry(
            target,
            seen,
            uuid,
            value,
            source
        ) == true then

            added = added + 1
        end
    end

    return added
end

function GAG2MailboxScanGcInventoryPets(target, seen)

    if type(getgc) ~= "function" then
        return 0
    end

    local ok, gc =
        pcall(function()

            return getgc(true)
        end)

    if ok ~= true
    or type(gc) ~= "table" then

        return 0
    end

    local added =
        0

    local scanned =
        0

    for _, candidate in ipairs(gc) do

        scanned = scanned + 1

        if scanned > 30000 then
            break
        end

        if type(candidate) == "table" then

            local inventory =
                GAG2MailboxSafeRawGet(
                    candidate,
                    "Inventory"
                )

            if type(inventory) == "table" then

                local pets =
                    GAG2MailboxSafeRawGet(
                        inventory,
                        "Pets"
                    )

                added = added + GAG2MailboxScanPetTable(
                        pets,
                        target,
                        seen,
                        "Inventory.Pets"
                    )
            end

            local directPets =
                GAG2MailboxSafeRawGet(
                    candidate,
                    "Pets"
                )

            added = added + GAG2MailboxScanPetTable(
                    directPets,
                    target,
                    seen,
                    "Pets"
                )
        end
    end

    return added
end

function GAG2MailboxScanToolPets(target, seen)

    local localPlayer =
        LOCAL_PLAYER
        or Players.LocalPlayer

    if not localPlayer then
        return 0
    end

    local containers = {
        localPlayer:FindFirstChildOfClass("Backpack"),
        localPlayer.Character,
    }

    local added =
        0

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                if child:IsA("Tool") then

                    local uuid =
                        GAG2MailboxClean(
                            child:GetAttribute("Id")
                            or child:GetAttribute("UUID")
                            or child:GetAttribute("Uuid")
                            or child:GetAttribute("PetId")
                            or child:GetAttribute("ItemKey")
                        )

                    local petName =
                        GAG2MailboxClean(
                            child:GetAttribute("Name")
                            or child:GetAttribute("PetName")
                            or child:GetAttribute("PetType")
                            or child:GetAttribute("f")
                            or child.Name
                        )

                    if GAG2MailboxAddPetEntry(
                        target,
                        seen,
                        uuid,
                        {
                            Name = petName,
                        },
                        "Tool"
                    ) == true then

                        added = added + 1
                    end
                end
            end
        end
    end

    return added
end

function GAG2MailboxBuildInventoryPets()

    local state =
        GAG2_MAILBOX_STATE

    local pets =
        {}

    local seen =
        {}

    if type(state.PetCache) == "table" then

        for uuid, petData in pairs(state.PetCache) do

            GAG2MailboxAddPetEntry(
                pets,
                seen,
                uuid,
                petData,
                "ReplicaSet cache"
            )
        end
    end

    GAG2MailboxScanGcInventoryPets(
        pets,
        seen
    )

    GAG2MailboxScanToolPets(
        pets,
        seen
    )

    table.sort(pets, function(a, b)

        local aName =
            tostring(a.Name or "")

        local bName =
            tostring(b.Name or "")

        if aName == bName then

            return tostring(a.Id or "")
                < tostring(b.Id or "")
        end

        return aName < bName
    end)

    state.InventoryPets =
        pets

    return pets
end

function GAG2MailboxBuildPetChoice(pet)

    local name =
        GAG2MailboxClean(
            pet
            and pet.Name
            or "Unknown Pet"
        )

    local uuid =
        GAG2MailboxClean(
            pet
            and pet.Id
            or ""
        )

    local extra =
        GAG2MailboxClean(
            pet
            and pet.Extra
            or ""
        )

    local text =
        name
        .. " · #"
        .. GAG2MailboxShortUuid(uuid)

    if extra ~= "" then

        text =
            text
            .. " · "
            .. extra
    end

    return text
end

function GAG2MailboxSetPetChoice(value)

    local state =
        GAG2_MAILBOX_STATE

    local choice =
        GAG2MailboxClean(value)

    if choice == "" then
        choice = "None"
    end

    state.PetChoice =
        choice

    local petId =
        state.ChoiceToPetId
        and state.ChoiceToPetId[choice]
        or ""

    state.PetId =
        GAG2MailboxClean(petId)

    if state.PetId ~= "" then

        GAG2MailboxSetStatus(
            "Selected pet: "
            .. tostring(choice)
        )

    else

        GAG2MailboxSetStatus(
            "No pet selected."
        )
    end

    MarkConfigDirty()
end

function GAG2MailboxRefreshPetDropdown()

    local state =
        GAG2_MAILBOX_STATE

    local dropdown =
        GAG2_MAILBOX_CONTROLS
        and GAG2_MAILBOX_CONTROLS.Pet

    local pets =
        GAG2MailboxBuildInventoryPets()

    local values = {
        "None",
    }

    local choiceToPetId =
        {}

    local usedChoices =
        {
            None = true,
        }

    local function addChoice(choice, uuid)

        choice =
            GAG2MailboxClean(choice)

        uuid =
            GAG2MailboxClean(uuid)

        if choice == ""
        or uuid == "" then
            return
        end

        local baseChoice =
            choice

        local suffix =
            2

        while usedChoices[choice] == true do

            choice =
                baseChoice
                .. " · "
                .. tostring(suffix)

            suffix = suffix + 1
        end

        usedChoices[choice] =
            true

        choiceToPetId[choice] =
            uuid

        table.insert(
            values,
            choice
        )
    end

    for _, pet in ipairs(pets) do

        addChoice(
            GAG2MailboxBuildPetChoice(pet),
            pet.Id
        )
    end

    local savedPetId =
        GAG2MailboxClean(
            state.PetId
        )

    if savedPetId ~= ""
    and GAG2MailboxIsUuid(savedPetId) == true then

        local alreadyVisible =
            false

        for _, uuid in pairs(choiceToPetId) do

            if uuid == savedPetId then
                alreadyVisible =
                    true
                break
            end
        end

        if alreadyVisible ~= true then

            addChoice(
                "Saved Pet"
                .. " · #"
                .. GAG2MailboxShortUuid(savedPetId),
                savedPetId
            )
        end
    end

    state.PetChoices =
        values

    state.ChoiceToPetId =
        choiceToPetId

    if dropdown then

        pcall(function()

            if type(dropdown.SetValues) == "function" then

                dropdown:SetValues(
                    values
                )

            elseif type(dropdown.SetItems) == "function" then

                dropdown:SetItems(
                    values
                )
            end
        end)

        local selected =
            GAG2MailboxClean(
                state.PetChoice
            )

        if selected == ""
        or selected == "None"
        or choiceToPetId[selected] == nil then

            selected =
                "None"
        end

        pcall(function()

            if type(dropdown.SetValue) == "function" then

                dropdown:SetValue(
                    selected
                )
            end
        end)
    end

    GAG2MailboxSetStatus(
        "Pets refreshed: "
        .. tostring(#pets)
    )

    return pets
end

function GAG2MailboxGetPlayerGui()

    return LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
        or nil
end

function GAG2MailboxFindInventoryFrame()

    local playerGui =
        GAG2MailboxGetPlayerGui()

    local mailbox =
        playerGui
        and playerGui:FindFirstChild("MailboxUI")

    if not mailbox then
        return nil
    end

    local direct =
        mailbox:FindFirstChild("InventoryFrame", true)

    if direct
    and direct:IsA("GuiObject") then

        local path =
            PathOf(direct)

        if path:find("SendingFrame", 1, true)
        and path:find("ItemSendFrame", 1, true) then

            return direct
        end
    end

    for _, descendant in ipairs(mailbox:GetDescendants()) do

        if descendant.Name == "InventoryFrame"
        and descendant:IsA("GuiObject") then

            local path =
                PathOf(descendant)

            if path:find("SendingFrame", 1, true)
            and path:find("ItemSendFrame", 1, true) then

                return descendant
            end
        end
    end

    return nil
end

function GAG2MailboxReadSendableAmount(itemFrame, category)

    category =
        GAG2MailboxClean(category)

    if category == "Pets" then
        return 1
    end

    if typeof(itemFrame) ~= "Instance" then
        return 0
    end

    local best =
        0

    local scanned =
        0

    for _, descendant in ipairs(itemFrame:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 350 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local text =
                ""

            pcall(function()

                text =
                    GAG2MailboxClean(
                        descendant.Text
                    )
            end)

            if text ~= "" then

                local amountText =
                    text:match("[xX]%s*([%d,]+)")
                    or text:match("([%d,]+)%s*[xX]")

                if amountText then

                    amountText =
                        tostring(amountText)
                            :gsub(",", "")

                    local amount =
                        tonumber(amountText)

                    if amount
                    and amount > best then

                        best =
                            amount
                    end
                end
            end
        end
    end

    return math.max(
        0,
        math.floor(best)
    )
end

function GAG2MailboxShortItemKey(value)

    value =
        GAG2MailboxClean(value)

    if #value <= 48 then
        return value
    end

    return value:sub(1, 45)
        .. "..."
end

function GAG2MailboxFindInventoryPetById(uuid)

    GAG2MailboxEnsureUniversalState()

    uuid =
        GAG2MailboxClean(
            uuid
        )

    if uuid == "" then
        return nil
    end

    local state =
        GAG2_MAILBOX_STATE

    local function findInList(pets)

        if type(pets) ~= "table" then
            return nil
        end

        for _, pet in ipairs(pets) do

            if type(pet) == "table"
            and GAG2MailboxClean(pet.Id) == uuid then

                return pet
            end
        end

        return nil
    end

    local pet =
        findInList(
            state.InventoryPets
        )

    if pet then
        return pet
    end

    local auto =
        state.Auto

    pet =
        findInList(
            type(auto) == "table"
            and auto.PetSnapshot
            or nil
        )

    if pet then
        return pet
    end

    local cachedPet =
        type(state.PetCache) == "table"
        and state.PetCache[uuid]
        or nil

    if type(cachedPet) == "table" then

        return {
            Id =
                uuid,

            Name =
                GAG2MailboxReadPetName(
                    cachedPet,
                    "Unknown Pet"
                ),

            Extra =
                GAG2MailboxReadPetExtra(
                    cachedPet
                ),

            Raw =
                cachedPet,

            Source =
                "PetCache",
        }
    end

    return nil
end

function GAG2MailboxBuildSendableDisplay(sendable)

    if type(sendable) ~= "table" then
        return "None"
    end

    local category =
        GAG2MailboxClean(
            sendable.Category
        )

    local itemKey =
        GAG2MailboxClean(
            sendable.ItemKey
        )

    if category == "Pets" then

        local pet =
            GAG2MailboxFindInventoryPetById(
                itemKey
            )

        if pet then

            local petName =
                GAG2MailboxClean(
                    pet.Name
                )

            local petExtra =
                GAG2MailboxClean(
                    pet.Extra
                )

            if petName == ""
            or petName == "Unknown Pet"
            or GAG2MailboxIsUuid(petName) == true then

                petName =
                    "Unknown Pet"
            end

            local display =
                petName

            if petExtra ~= "" then

                display =
                    display
                    .. " · "
                    .. petExtra
            end

            return display
        end

        return "Unknown Pet"
            .. " · #"
            .. GAG2MailboxShortUuid(
                itemKey
            )
    end

    local amount =
        tonumber(sendable.Amount)
        or 0

    local amountText =
        amount > 0
        and (
            "x"
            .. tostring(amount)
        )
        or "x?"

    return tostring(category)
        .. " | "
        .. GAG2MailboxShortItemKey(
            itemKey
        )
        .. " | "
        .. amountText
end

function GAG2MailboxReadSendableFromFrame(itemFrame)

    if typeof(itemFrame) ~= "Instance" then
        return nil
    end

    local name =
        tostring(itemFrame.Name or "")

    local category, itemKey =
        name:match("^Inv_([^:]+):(.+)$")

    category =
        GAG2MailboxClean(category)

    itemKey =
        GAG2MailboxClean(itemKey)

    if category == ""
    or itemKey == "" then
        return nil
    end

    local amount =
        GAG2MailboxReadSendableAmount(
            itemFrame,
            category
        )

    if category == "Pets" then
        amount =
            1
    end

    local sendable = {
        Category =
            category,

        ItemKey =
            itemKey,

        Amount =
            amount,

        IsStackable =
            category ~= "Pets",

        Path =
            PathOf(itemFrame),
    }

    sendable.Display =
        GAG2MailboxBuildSendableDisplay(
            sendable
        )

    return sendable
end

function GAG2MailboxBuildSendables()

    GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    local inventoryFrame =
        GAG2MailboxFindInventoryFrame()

    local sendables =
        {}

    local seen =
        {}

    if inventoryFrame then

        for _, child in ipairs(inventoryFrame:GetChildren()) do

            local sendable =
                GAG2MailboxReadSendableFromFrame(
                    child
                )

            if sendable then

                local key =
                    tostring(sendable.Category)
                    .. ":"
                    .. tostring(sendable.ItemKey)

                if seen[key] ~= true then

                    seen[key] =
                        true

                    table.insert(
                        sendables,
                        sendable
                    )
                end
            end
        end
    end

    table.sort(sendables, function(a, b)

        local categoryA =
            tostring(a.Category or "")

        local categoryB =
            tostring(b.Category or "")

        if categoryA ~= categoryB then
            return categoryA < categoryB
        end

        return tostring(a.ItemKey or "")
            < tostring(b.ItemKey or "")
    end)

    state.Sendables =
        sendables

    return sendables
end

function GAG2MailboxBuildCategoryChoices(sendables)

    local categories = {
        "All",
    }

    local seen = {
        All = true,
    }

    for _, sendable in ipairs(sendables or {}) do

        local category =
            GAG2MailboxClean(
                sendable.Category
            )

        if category ~= ""
        and seen[category] ~= true then

            seen[category] =
                true

            table.insert(
                categories,
                category
            )
        end
    end

    table.sort(categories, function(a, b)

        if a == "All" then
            return true
        end

        if b == "All" then
            return false
        end

        return tostring(a) < tostring(b)
    end)

    return categories
end

function GAG2MailboxSetDropdownValues(dropdown, values)

    if not dropdown then
        return
    end

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

function GAG2MailboxSetDropdownValue(dropdown, value)

    if not dropdown then
        return
    end

    pcall(function()

        if type(dropdown.SetValue) == "function" then

            dropdown:SetValue(
                value
            )
        end
    end)
end

function GAG2MailboxRefreshCategoryDropdown()

    GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    local sendables =
        state.Sendables

    if type(sendables) ~= "table" then
        sendables =
            {}
    end

    local values =
        GAG2MailboxBuildCategoryChoices(
            sendables
        )

    state.CategoryChoices =
        values

    local selected =
        GAG2MailboxClean(
            state.SelectedCategory
        )

    if selected == ""
    or table.find(values, selected) == nil then

        selected =
            "All"
    end

    state.SelectedCategory =
        selected

    GAG2MailboxSetDropdownValues(
        GAG2_MAILBOX_CONTROLS.Category,
        values
    )

    GAG2MailboxSetDropdownValue(
        GAG2_MAILBOX_CONTROLS.Category,
        selected
    )
end

function GAG2MailboxRefreshItemDropdown()

    GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    local selectedCategory =
        GAG2MailboxClean(
            state.SelectedCategory
        )

    if selectedCategory == "" then
        selectedCategory =
            "All"
    end

    local values = {
        "None",
    }

    local choiceToSendable =
        {}

    local usedChoices = {
        None = true,
    }

    for _, sendable in ipairs(state.Sendables or {}) do

        if selectedCategory == "All"
        or sendable.Category == selectedCategory then

            local choice =
                GAG2MailboxBuildSendableDisplay(
                    sendable
                )

            local baseChoice =
                choice

            local suffix =
                2

            while usedChoices[choice] == true do

                choice =
                    baseChoice
                    .. " · "
                    .. tostring(suffix)

                suffix = suffix + 1
            end

            usedChoices[choice] =
                true

            choiceToSendable[choice] =
                sendable

            table.insert(
                values,
                choice
            )
        end
    end

    state.ItemChoices =
        values

    state.ChoiceToSendable =
        choiceToSendable

    local selected =
        GAG2MailboxClean(
            state.ItemChoice
        )

    if selected == ""
    or selected == "None"
    or choiceToSendable[selected] == nil then

        selected =
            "None"
    end

    state.ItemChoice =
        selected

    GAG2MailboxSetDropdownValues(
        GAG2_MAILBOX_CONTROLS.Item,
        values
    )

    GAG2MailboxSetDropdownValue(
        GAG2_MAILBOX_CONTROLS.Item,
        selected
    )
end

function GAG2MailboxRefreshSendableDropdown()

    -- Resolve pet UUIDs into real inventory pet names
    -- before creating the visible mailbox item choices.

    GAG2MailboxBuildInventoryPets()

    local sendables =
        GAG2MailboxBuildSendables()

    GAG2MailboxRefreshCategoryDropdown()
    GAG2MailboxRefreshItemDropdown()

    if type(GAG2MailboxAutoRefreshDropdowns) == "function" then

        GAG2MailboxAutoRefreshDropdowns(
            false
        )
    end

    if type(GAG2MailboxAutoRefreshQueueVisuals) == "function" then

        GAG2MailboxAutoRefreshQueueVisuals()
    end

    GAG2MailboxSetStatus(
        "Items refreshed: "
        .. tostring(#sendables)
        .. ". Open mailbox Send tab if stackable items are missing."
    )

    return sendables
end

function GAG2MailboxSetCategoryChoice(value)

    GAG2MailboxEnsureUniversalState()

    local category =
        GAG2MailboxClean(value)

    if category == "" then
        category =
            "All"
    end

    GAG2_MAILBOX_STATE.SelectedCategory =
        category

    GAG2_MAILBOX_STATE.ItemChoice =
        "None"

    GAG2MailboxRefreshItemDropdown()

    GAG2MailboxSetStatus(
        "Category set: "
        .. tostring(category)
    )

    MarkConfigDirty()
end

function GAG2MailboxSetItemChoice(value)

    GAG2MailboxEnsureUniversalState()

    local choice =
        GAG2MailboxClean(value)

    if choice == "" then
        choice =
            "None"
    end

    GAG2_MAILBOX_STATE.ItemChoice =
        choice

    GAG2MailboxSetStatus(
        choice ~= "None"
        and (
            "Selected item: "
            .. tostring(choice)
        )
        or "No item selected."
    )

    MarkConfigDirty()
end

function GAG2MailboxSetMaxRowsPerMail(value)

    GAG2MailboxEnsureUniversalState()

    GAG2_MAILBOX_STATE.MaxRowsPerMail =
        math.clamp(
            math.floor(
                tonumber(value)
                or 20
            ),
            1,
            20
        )

    GAG2MailboxSetStatus(
        "Max rows per mail set: "
        .. tostring(GAG2_MAILBOX_STATE.MaxRowsPerMail)
    )

    MarkConfigDirty()
end

function GAG2MailboxGetSelectedSendable()

    GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    local choice =
        GAG2MailboxClean(
            state.ItemChoice
        )

    if choice == ""
    or choice == "None" then
        return nil
    end

    local sendable =
        state.ChoiceToSendable
        and state.ChoiceToSendable[choice]

    if type(sendable) == "table" then
        return sendable
    end

    return nil
end

function GAG2MailboxGetSendCountForSendable(sendable)

    GAG2MailboxEnsureUniversalState()

    local amount =
        GAG2MailboxGetAmount()

    if type(sendable) ~= "table" then
        return 0
    end

    local ownedAmount =
        math.max(
            0,
            math.floor(
                tonumber(sendable.Amount)
                or 0
            )
        )

    if sendable.Category == "Pets" then

        return ownedAmount > 0
            and 1
            or 0
    end

    if ownedAmount <= 0 then
        return 0
    end

    return math.max(
        0,
        math.min(
            math.floor(amount),
            ownedAmount
        )
    )
end

function GAG2MailboxBuildBatchForSendable(sendable)

    if type(sendable) ~= "table" then

        return nil,
            "missing item"
    end

    local category =
        GAG2MailboxClean(
            sendable.Category
        )

    local itemKey =
        GAG2MailboxClean(
            sendable.ItemKey
        )

    if category == ""
    or itemKey == "" then

        return nil,
            "bad item"
    end

    local count =
        GAG2MailboxGetSendCountForSendable(
            sendable
        )

    if count <= 0 then

        return nil,
            "owned amount is zero or unavailable"
    end

    local batch = {
        {
            Category =
                category,

            ItemKey =
                itemKey,

            Count =
                count,
        },
    }

    return batch,
        nil,
        count
end

function GAG2MailboxStartReplicaWatcher()

    local state =
        GAG2_MAILBOX_STATE

    if state.ReplicaWatching == true then
        return
    end

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    if not replicaSet then

        GAG2MailboxSetStatus(
            "ReplicaSet missing for pet cache."
        )

        return
    end

    state.ReplicaWatching =
        true

    replicaSet.OnClientEvent:Connect(function(_, path, value)

        if type(path) ~= "table" then
            return
        end

        if tostring(path[1]) ~= "Inventory" then
            return
        end

        if tostring(path[2]) ~= "Pets" then
            return
        end

        local uuid =
            GAG2MailboxClean(
                path[3]
            )

        if GAG2MailboxIsUuid(uuid) ~= true then
            return
        end

        state.PetCache =
            type(state.PetCache) == "table"
            and state.PetCache
            or {}

        if type(value) == "table" then

            state.PetCache[uuid] =
                value

        else

            state.PetCache[uuid] =
                nil
        end

        task.defer(function()

            GAG2MailboxRefreshPetDropdown()
        end)
    end)
end

function GAG2MailboxResolveTargetUserId(targetText)

    targetText =
        GAG2MailboxClean(targetText)

    if targetText == "" then
        return nil,
            "missing target"
    end

    local asNumber =
        tonumber(targetText)

    if asNumber
    and asNumber > 0 then

        return math.floor(asNumber),
            "user id"
    end

    targetText =
        targetText:gsub("^@", "")

    local localPlayerMatch =
        Players:FindFirstChild(targetText)

    if localPlayerMatch then

        return localPlayerMatch.UserId,
            "server player"
    end

    local ok, userId =
        pcall(function()

            return Players:GetUserIdFromNameAsync(
                targetText
            )
        end)

    if ok == true
    and tonumber(userId) then

        return tonumber(userId),
            "username lookup"
    end

    return nil,
        "target lookup failed"
end

function GAG2MailboxPacketHasFire(packet)

    if type(packet) ~= "table" then
        return false
    end

    local ok, fireFunction =
        pcall(function()

            return packet.Fire
        end)

    return ok == true
        and type(fireFunction) == "function"
end

function GAG2MailboxSearchPacketByName(candidate, packetName, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 8 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    if type(SniperSafeRawGet) == "function" then

        local name =
            SniperSafeRawGet(
                candidate,
                "Name"
            )

        if tostring(name) == tostring(packetName)
        and GAG2MailboxPacketHasFire(candidate) == true then

            return candidate
        end
    end

    if type(SniperSafePairsSnapshot) == "function" then

        for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

            if type(row.Value) == "table" then

                local found =
                    GAG2MailboxSearchPacketByName(
                        row.Value,
                        packetName,
                        seen,
                        depth + 1
                    )

                if found then
                    return found
                end
            end
        end

    else

        for _, child in pairs(candidate) do

            if type(child) == "table" then

                local found =
                    GAG2MailboxSearchPacketByName(
                        child,
                        packetName,
                        seen,
                        depth + 1
                    )

                if found then
                    return found
                end
            end
        end
    end

    return nil
end

function GAG2MailboxResolvePacket(keyName, packetName)

    keyName =
        GAG2MailboxClean(keyName)

    packetName =
        GAG2MailboxClean(packetName)

    if keyName == ""
    or packetName == "" then

        return nil,
            "bad mailbox packet request"
    end

    local state =
        GAG2_MAILBOX_STATE

    state.Packets =
        type(state.Packets) == "table"
        and state.Packets
        or {}

    if state.Packets[keyName] then
        return state.Packets[keyName],
            "cached"
    end

    local packets =
        nil

    if type(SniperFindPacketTable) == "function" then

        packets =
            SniperFindPacketTable()
    end

    if type(packets) == "table"
    and type(SniperSafeRawGet) == "function" then

        local mailbox =
            SniperSafeRawGet(
                packets,
                "Mailbox"
            )

        if type(mailbox) == "table" then

            local packet =
                SniperSafeRawGet(
                    mailbox,
                    keyName
                )

            if GAG2MailboxPacketHasFire(packet) == true then

                state.Packets[keyName] =
                    packet

                return packet,
                    "Mailbox."
                    .. tostring(keyName)
            end
        end

        local found =
            GAG2MailboxSearchPacketByName(
                packets,
                packetName,
                {},
                0
            )

        if found then

            state.Packets[keyName] =
                found

            return found,
                "search:"
                .. tostring(packetName)
        end
    end

    return nil,
        "packet not found: "
        .. tostring(packetName)
        .. " | source: "
        .. tostring(
            SniperState
            and SniperState.PacketSource
            or "no packet source"
        )
end

function GAG2MailboxFirePacket(keyName, packetName, ...)

    local packet, source =
        GAG2MailboxResolvePacket(
            keyName,
            packetName
        )

    if not packet then

        GAG2MailboxSetStatus(
            "Packet missing: "
            .. tostring(source)
        )

        warn(
            "[HOLY MAILBOX]",
            "packet missing",
            tostring(keyName),
            tostring(packetName),
            tostring(source)
        )

        return false,
            source
    end

    local args =
        {
            ...
        }

    local ok, err =
        pcall(function()

            packet:Fire(
                table.unpack(args)
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                packet.Fire(
                    packet,
                    table.unpack(args)
                )
            end)
    end

    if ok ~= true then

        GAG2MailboxSetStatus(
            "Fire failed: "
            .. tostring(err)
        )

        warn(
            "[HOLY MAILBOX]",
            "fire failed",
            tostring(packetName),
            tostring(err)
        )

        return false,
            tostring(err)
    end

    return true,
        source
end

function GAG2MailboxOpenInbox()

    local ok, source =
        GAG2MailboxFirePacket(
            "OpenInbox",
            "MailboxOpenInbox"
        )

    if ok == true then

        GAG2MailboxSetStatus(
            "Opened inbox | "
            .. tostring(source)
        )
    end

    return ok,
        source
end

function GAG2MailboxSendSelectedBatchNow()

    GAG2MailboxEnsureUniversalState()

    local state =
        GAG2_MAILBOX_STATE

    local targetUserId, targetReason =
        GAG2MailboxResolveTargetUserId(
            state.TargetText
        )

    if not targetUserId then

        GAG2MailboxSetStatus(
            "Bad target: "
            .. tostring(targetReason)
        )

        return false,
            targetReason
    end

    local sendable =
        GAG2MailboxGetSelectedSendable()

    if not sendable then

        GAG2MailboxSetStatus(
            "No item selected. Open mailbox Send tab, then press Refresh Items."
        )

        return false,
            "missing item"
    end

    local batch, buildError, count =
        GAG2MailboxBuildBatchForSendable(
            sendable
        )

    if not batch then

        GAG2MailboxSetStatus(
            "Bad batch: "
            .. tostring(buildError)
        )

        return false,
            tostring(buildError)
    end

    local message =
        tostring(state.Message or "")

    local ok, source =
        GAG2MailboxFirePacket(
            "SendBatch",
            "MailboxSendBatch",
            targetUserId,
            batch,
            message
        )

    if ok == true then

        state.LastTargetUserId =
            targetUserId

        state.LastCategory =
            sendable.Category

        state.LastItemKey =
            sendable.ItemKey

        state.LastSendCount =
            count

        state.LastBatchRows =
            #batch

        state.LastPetId =
            sendable.Category == "Pets"
            and sendable.ItemKey
            or ""

        state.LastAmount =
            count

        GAG2MailboxSetStatus(
            "Sent mailbox batch."
            .. "\nUserId: "
            .. tostring(targetUserId)
            .. " ("
            .. tostring(targetReason)
            .. ")"
            .. "\nCategory: "
            .. tostring(sendable.Category)
            .. "\nItemKey: "
            .. tostring(sendable.ItemKey)
            .. "\nCount: "
            .. tostring(count)
            .. "\nRows: "
            .. tostring(#batch)
            .. "\nSource: "
            .. tostring(source)
        )

        print(
            "[HOLY MAILBOX]",
            "MailboxSendBatch fired",
            "| userId:",
            tostring(targetUserId),
            "| category:",
            tostring(sendable.Category),
            "| itemKey:",
            tostring(sendable.ItemKey),
            "| count:",
            tostring(count),
            "| rows:",
            tostring(#batch),
            "| source:",
            tostring(source)
        )

        task.delay(0.35, function()

            if type(GAG2MailboxRefreshSendableDropdown) == "function" then

                GAG2MailboxRefreshSendableDropdown()
            end
        end)

        return true,
            source
    end

    return false,
        source
end

function GAG2MailboxSendPetBatchNow()

    return GAG2MailboxSendSelectedBatchNow()
end

--==================================================
-- [4.581] AUTOMATIC MAILBOX
-- Persistent rule queue, trigger checks, receipts,
-- inventory clamping, and controlled send cooldown.
--==================================================

GAG2_MAILBOX_AUTO_FILE =
    UI_SETTINGS_FOLDER
    .. "/MailboxAutoRules.json"

GAG2_MAILBOX_AUTO_CONTROLS =
    GAG2_MAILBOX_AUTO_CONTROLS
    or {}

function GAG2MailboxAutoGetState()

    GAG2MailboxEnsureUniversalState()

    return GAG2_MAILBOX_STATE.Auto
end

function GAG2MailboxAutoNormalizeKey(value)

    return GAG2MailboxClean(value)
        :lower()
        :gsub("%s+", " ")
end

function GAG2MailboxAutoSetStatus(text)

    local auto =
        GAG2MailboxAutoGetState()

    auto.LastAction =
        tostring(text or "Idle.")

    GAG2MailboxSetStatus(
        auto.LastAction
    )
end

function GAG2MailboxAutoSetDraft(key, value)

    local auto =
        GAG2MailboxAutoGetState()

    auto[key] =
        value

    MarkConfigDirty()
end

function GAG2MailboxAutoSetNumber(key, value, minimum, maximum, fallback)

    local auto =
        GAG2MailboxAutoGetState()

    auto[key] =
        math.clamp(
            tonumber(value)
            or tonumber(fallback)
            or minimum,
            minimum,
            maximum
        )

    MarkConfigDirty()
end

function GAG2MailboxAutoSaveRules()

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local auto =
        GAG2MailboxAutoGetState()

    local payload = {
        Rules =
            auto.Rules,
    }

    local encodeOk, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if encodeOk ~= true
    or type(encoded) ~= "string" then

        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_MAILBOX_AUTO_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function GAG2MailboxAutoLoadRules()

    local auto =
        GAG2MailboxAutoGetState()

    if auto.RulesLoaded == true then
        return auto.Rules
    end

    auto.RulesLoaded =
        true

    if CanUseUISettingsFile() ~= true then
        return auto.Rules
    end

    local exists =
        false

    local existsOk =
        pcall(function()

            exists =
                isfile(
                    GAG2_MAILBOX_AUTO_FILE
                )
        end)

    if existsOk ~= true
    or exists ~= true then

        return auto.Rules
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_MAILBOX_AUTO_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then

        return auto.Rules
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table"
    or type(payload.Rules) ~= "table" then

        return auto.Rules
    end

    local validRules =
        {}

    for _, rule in ipairs(payload.Rules) do

        if type(rule) == "table" then

            local targetText =
                GAG2MailboxClean(
                    rule.TargetText
                )

            local category =
                GAG2MailboxClean(
                    rule.Category
                )

            local itemChoice =
                GAG2MailboxClean(
                    rule.ItemChoice
                )

            if targetText ~= ""
            and category ~= ""
            and category ~= "None"
            and itemChoice ~= ""
            and itemChoice ~= "None" then

                rule.Id =
                    GAG2MailboxClean(rule.Id) ~= ""
                    and GAG2MailboxClean(rule.Id)
                    or HttpService:GenerateGUID(false)

                rule.Enabled =
                    rule.Enabled ~= false

                rule.TriggerMode =
                    rule.TriggerMode == "Above"
                    and "Above"
                    or "At Least"

                rule.TriggerAmount =
                    math.max(
                        1,
                        math.floor(
                            tonumber(rule.TriggerAmount)
                            or 1
                        )
                    )

                if rule.SendMode ~= "Send Excess"
                and rule.SendMode ~= "Send All Available" then

                    rule.SendMode =
                        "Fixed Amount"
                end

                rule.SendAmount =
                    math.max(
                        1,
                        math.floor(
                            tonumber(rule.SendAmount)
                            or 1
                        )
                    )

                rule.KeepAmount =
                    math.max(
                        0,
                        math.floor(
                            tonumber(rule.KeepAmount)
                            or 0
                        )
                    )

                rule.PetVariant =
                    tostring(
                        rule.PetVariant
                        or "Any Variant"
                    )

                rule.PetSize =
                    tostring(
                        rule.PetSize
                        or "Any Size"
                    )

                rule.Message =
                    tostring(
                        rule.Message
                        or ""
                    )

                table.insert(
                    validRules,
                    rule
                )
            end
        end
    end

    auto.Rules =
        validRules

    return auto.Rules
end

function GAG2MailboxAutoGetPets(forceRefresh)

    local auto =
        GAG2MailboxAutoGetState()

    local now =
        os.clock()

    local shouldRefresh =
        forceRefresh == true
        or type(auto.PetSnapshot) ~= "table"
        or #auto.PetSnapshot <= 0
        or now - tonumber(auto.LastPetRefreshAt or 0) >= 5

    if shouldRefresh == true then

        local ok, pets =
            pcall(function()

                return GAG2MailboxBuildInventoryPets()
            end)

        if ok == true
        and type(pets) == "table" then

            auto.PetSnapshot =
                pets

            auto.LastPetRefreshAt =
                now
        end
    end

    return auto.PetSnapshot
end

function GAG2MailboxAutoBasePetName(value)

    local name =
        GAG2MailboxClean(value)

    local lowerName =
        name:lower()

    local prefixes = {
        "huge ",
        "giant ",
        "large ",
        "big ",
    }

    for _, prefix in ipairs(prefixes) do

        if lowerName:sub(1, #prefix) == prefix then

            return GAG2MailboxClean(
                name:sub(
                    #prefix + 1
                )
            )
        end
    end

    return name
end

function GAG2MailboxAutoReadPetVariant(pet)

    local raw =
        type(pet) == "table"
        and pet.Raw
        or nil

    local mutation =
        type(raw) == "table"
        and GAG2MailboxClean(
            GAG2MailboxSafeRawGet(
                raw,
                "Mutation"
            )
        )
        or ""

    if mutation == ""
    or mutation == "None"
    or mutation == "Normal" then

        return "Normal"
    end

    return mutation
end

function GAG2MailboxAutoReadPetSize(pet)

    if type(pet) ~= "table" then
        return "Normal"
    end

    local raw =
        pet.Raw

    local pieces = {
        tostring(pet.Name or ""),
        tostring(pet.Extra or ""),
    }

    if type(raw) == "table" then

        local keys = {
            "SizeClass",
            "PetSize",
            "Size",
            "SizeVariant",
            "GrowthSize",
            "Variant",
        }

        for _, key in ipairs(keys) do

            local value =
                GAG2MailboxSafeRawGet(
                    raw,
                    key
                )

            if value ~= nil then

                table.insert(
                    pieces,
                    tostring(value)
                )
            end
        end
    end

    local text =
        table.concat(
            pieces,
            " "
        ):lower()

    if text:find("huge", 1, true) then
        return "Huge"
    end

    if text:find("big", 1, true)
    or text:find("giant", 1, true)
    or text:find("large", 1, true) then

        return "Big"
    end

    return "Normal"
end

function GAG2MailboxAutoPetMatchesRule(pet, rule)

    if type(pet) ~= "table"
    or type(rule) ~= "table" then

        return false
    end

    local wantedName =
        GAG2MailboxAutoNormalizeKey(
            rule.ItemChoice
        )

    local petName =
        GAG2MailboxAutoNormalizeKey(
            GAG2MailboxAutoBasePetName(
                pet.Name
            )
        )

    if wantedName == ""
    or petName ~= wantedName then
        return false
    end

    local wantedVariant =
        GAG2MailboxClean(
            rule.PetVariant
        )

    local petVariant =
        GAG2MailboxAutoReadPetVariant(
            pet
        )

    if wantedVariant ~= ""
    and wantedVariant ~= "Any Variant"
    and wantedVariant ~= petVariant then

        return false
    end

    local wantedSize =
        GAG2MailboxClean(
            rule.PetSize
        )

    local petSize =
        GAG2MailboxAutoReadPetSize(
            pet
        )

    if wantedSize == "Big+"
    and petSize ~= "Big"
    and petSize ~= "Huge" then

        return false
    end

    if wantedSize == "Huge Only"
    and petSize ~= "Huge" then

        return false
    end

    return true
end

function GAG2MailboxAutoGetCategoryChoices()

    local state =
        GAG2_MAILBOX_STATE

    local values = {
        "None",
    }

    local seen = {
        None = true,
    }

    local function add(category)

        category =
            GAG2MailboxClean(category)

        if category == ""
        or category == "All"
        or category == "None"
        or seen[category] == true then

            return
        end

        seen[category] =
            true

        table.insert(
            values,
            category
        )
    end

    for _, sendable in ipairs(state.Sendables or {}) do

        add(
            sendable.Category
        )
    end

    local pets =
        GAG2MailboxAutoGetPets(
            false
        )

    if type(pets) == "table"
    and #pets > 0 then

        add(
            "Pets"
        )
    end

    table.sort(
        values,
        function(a, b)

            if a == "None" then
                return true
            end

            if b == "None" then
                return false
            end

            return tostring(a)
                < tostring(b)
        end
    )

    return values
end

function GAG2MailboxAutoGetItemChoices(category)

    category =
        GAG2MailboxClean(category)

    local values = {
        "None",
    }

    local seen = {
        None = true,
    }

    local function add(itemName)

        itemName =
            GAG2MailboxClean(itemName)

        if itemName == ""
        or itemName == "None"
        or seen[itemName] == true then

            return
        end

        seen[itemName] =
            true

        table.insert(
            values,
            itemName
        )
    end

    if category == "Pets" then

        for _, pet in ipairs(
            GAG2MailboxAutoGetPets(
                false
            )
        ) do

            add(
                GAG2MailboxAutoBasePetName(
                    pet.Name
                )
            )
        end

    else

        for _, sendable in ipairs(
            GAG2_MAILBOX_STATE.Sendables
            or {}
        ) do

            if GAG2MailboxClean(sendable.Category) == category then

                add(
                    sendable.ItemKey
                )
            end
        end
    end

    table.sort(
        values,
        function(a, b)

            if a == "None" then
                return true
            end

            if b == "None" then
                return false
            end

            return tostring(a)
                < tostring(b)
        end
    )

    return values
end

function GAG2MailboxAutoRefreshDropdowns(forcePetRefresh)

    local auto =
        GAG2MailboxAutoGetState()

    if forcePetRefresh == true then

        auto.LastPetRefreshAt =
            0

        GAG2MailboxAutoGetPets(
            true
        )
    end

    auto.RefreshingControls =
        true

    local categoryValues =
        GAG2MailboxAutoGetCategoryChoices()

    if table.find(
        categoryValues,
        auto.Category
    ) == nil then

        auto.Category =
            "None"
    end

    GAG2MailboxSetDropdownValues(
        GAG2_MAILBOX_AUTO_CONTROLS.Category,
        categoryValues
    )

    GAG2MailboxSetDropdownValue(
        GAG2_MAILBOX_AUTO_CONTROLS.Category,
        auto.Category
    )

    local itemValues =
        GAG2MailboxAutoGetItemChoices(
            auto.Category
        )

    if table.find(
        itemValues,
        auto.ItemChoice
    ) == nil then

        auto.ItemChoice =
            "None"
    end

    GAG2MailboxSetDropdownValues(
        GAG2_MAILBOX_AUTO_CONTROLS.Item,
        itemValues
    )

    GAG2MailboxSetDropdownValue(
        GAG2_MAILBOX_AUTO_CONTROLS.Item,
        auto.ItemChoice
    )

    auto.RefreshingControls =
        false
end

function GAG2MailboxAutoBuildRuleDisplay(rule, index)

    local sendText =
        ""

    if rule.SendMode == "Send Excess" then

        sendText =
            "Send excess"

    elseif rule.SendMode == "Send All Available" then

        sendText =
            "Send all"

    else

        sendText =
            "Send "
            .. tostring(rule.SendAmount)
    end

    local keepText =
        ""

    if rule.SendMode ~= "Send All Available"
    and tonumber(rule.KeepAmount or 0) > 0 then

        keepText =
            " | Keep "
            .. tostring(rule.KeepAmount)
    end

    local filterText =
        ""

    if rule.Category == "Pets" then

        if rule.PetVariant ~= "Any Variant" then

            filterText =
                filterText
                .. " | "
                .. tostring(rule.PetVariant)
        end

        if rule.PetSize ~= "Any Size" then

            filterText =
                filterText
                .. " | "
                .. tostring(rule.PetSize)
        end
    end

    return tostring(index)
        .. ". "
        .. tostring(rule.ItemChoice)
        .. " | "
        .. tostring(rule.TriggerMode)
        .. " "
        .. tostring(rule.TriggerAmount)
        .. " -> "
        .. sendText
        .. keepText
        .. filterText
end

function GAG2MailboxAutoRefreshQueueVisuals()

    local auto =
        GAG2MailboxAutoGetState()

    local values = {
        "None",
    }

    local map =
        {}

    local lines = {
        '<font color="rgb(196,181,253)"><b>Order Queue</b></font>',
    }

    if #auto.Rules <= 0 then

        table.insert(
            lines,
            "No automatic rules saved."
        )

    else

        for index, rule in ipairs(auto.Rules) do

            local display =
                GAG2MailboxAutoBuildRuleDisplay(
                    rule,
                    index
                )

            values[#values + 1] =
                display

            map[display] =
                index

            if index <= 12 then

                table.insert(
                    lines,
                    display
                )
            end
        end

        if #auto.Rules > 12 then

            table.insert(
                lines,
                "+"
                .. tostring(#auto.Rules - 12)
                .. " more"
            )
        end
    end

    auto.RuleChoiceMap =
        map

    if map[auto.SelectedRuleChoice] == nil then

        auto.SelectedRuleChoice =
            values[2]
            or "None"
    end

    auto.RefreshingControls =
        true

    GAG2MailboxSetDropdownValues(
        GAG2_MAILBOX_AUTO_CONTROLS.Rule,
        values
    )

    GAG2MailboxSetDropdownValue(
        GAG2_MAILBOX_AUTO_CONTROLS.Rule,
        auto.SelectedRuleChoice
    )

    auto.RefreshingControls =
        false

    if Options.HolyGAG2MailboxAutoQueueStatus then

        Options.HolyGAG2MailboxAutoQueueStatus:SetText(
            table.concat(
                lines,
                "\n"
            )
        )
    end
end

function GAG2MailboxAutoReceiptDisplay(receipt, index)

    return tostring(index)
        .. ". "
        .. tostring(receipt.TimeText or "?")
        .. " | "
        .. tostring(receipt.Item or "?")
        .. " x"
        .. tostring(receipt.Count or 0)
        .. " | "
        .. tostring(receipt.Result or "?")
end

function GAG2MailboxAutoReceiptText(receipt)

    if type(receipt) ~= "table" then
        return "Receipt unavailable."
    end

    return "HOLY MAILBOX RECEIPT"
        .. "\nTime: "
        .. tostring(receipt.TimeText or "?")
        .. "\nRecipient: "
        .. tostring(receipt.TargetText or "?")
        .. "\nUserId: "
        .. tostring(receipt.TargetUserId or "?")
        .. "\nCategory: "
        .. tostring(receipt.Category or "?")
        .. "\nItem: "
        .. tostring(receipt.Item or "?")
        .. "\nRequested: "
        .. tostring(receipt.Requested or 0)
        .. "\nActual Sent: "
        .. tostring(receipt.Count or 0)
        .. "\nRows: "
        .. tostring(receipt.Rows or 0)
        .. "\nResult: "
        .. tostring(receipt.Result or "?")
        .. "\nDetails: "
        .. tostring(receipt.Details or "")
end

function GAG2MailboxAutoRefreshReceiptVisuals()

    local auto =
        GAG2MailboxAutoGetState()

    local values = {
        "None",
    }

    local map =
        {}

    local lines = {
        '<font color="rgb(196,181,253)"><b>Receipts</b></font>',
    }

    if #auto.Receipts <= 0 then

        table.insert(
            lines,
            "No receipts saved."
        )

    else

        for index, receipt in ipairs(auto.Receipts) do

            local display =
                GAG2MailboxAutoReceiptDisplay(
                    receipt,
                    index
                )

            values[#values + 1] =
                display

            map[display] =
                index

            if index <= 6 then

                table.insert(
                    lines,
                    display
                )
            end
        end
    end

    auto.ReceiptChoiceMap =
        map

    if map[auto.SelectedReceiptChoice] == nil then

        auto.SelectedReceiptChoice =
            values[2]
            or "None"
    end

    auto.RefreshingControls =
        true

    GAG2MailboxSetDropdownValues(
        GAG2_MAILBOX_AUTO_CONTROLS.Receipt,
        values
    )

    GAG2MailboxSetDropdownValue(
        GAG2_MAILBOX_AUTO_CONTROLS.Receipt,
        auto.SelectedReceiptChoice
    )

    auto.RefreshingControls =
        false

    if Options.HolyGAG2MailboxAutoReceiptStatus then

        Options.HolyGAG2MailboxAutoReceiptStatus:SetText(
            table.concat(
                lines,
                "\n"
            )
        )
    end
end

function GAG2MailboxAutoAddReceipt(receipt)

    local auto =
        GAG2MailboxAutoGetState()

    receipt =
        type(receipt) == "table"
        and receipt
        or {}

    local timeText =
        "?"

    pcall(function()

        timeText =
            os.date(
                "%H:%M:%S"
            )
    end)

    receipt.Time =
        os.time()

    receipt.TimeText =
        timeText

    table.insert(
        auto.Receipts,
        1,
        receipt
    )

    while #auto.Receipts > 50 do

        table.remove(
            auto.Receipts,
            #auto.Receipts
        )
    end

    GAG2MailboxAutoRefreshReceiptVisuals()
end

function GAG2MailboxAutoAddRule()

    local auto =
        GAG2MailboxAutoGetState()

    local targetText =
        GAG2MailboxClean(
            auto.RecipientText
        )

    local category =
        GAG2MailboxClean(
            auto.Category
        )

    local itemChoice =
        GAG2MailboxClean(
            auto.ItemChoice
        )

    if targetText == "" then

        GAG2MailboxAutoSetStatus(
            "Automatic rule needs a recipient."
        )

        return false
    end

    if category == ""
    or category == "None" then

        GAG2MailboxAutoSetStatus(
            "Automatic rule needs a category."
        )

        return false
    end

    if itemChoice == ""
    or itemChoice == "None" then

        GAG2MailboxAutoSetStatus(
            "Automatic rule needs an item."
        )

        return false
    end

    local rule = {
        Id =
            HttpService:GenerateGUID(false),

        Enabled =
            true,

        TargetText =
            targetText,

        Category =
            category,

        ItemChoice =
            itemChoice,

        TriggerMode =
            auto.TriggerMode == "Above"
            and "Above"
            or "At Least",

        TriggerAmount =
            math.max(
                1,
                math.floor(
                    tonumber(auto.TriggerAmount)
                    or 1
                )
            ),

        SendMode =
            auto.SendMode,

        SendAmount =
            math.max(
                1,
                math.floor(
                    tonumber(auto.SendAmount)
                    or 1
                )
            ),

        KeepAmount =
            math.max(
                0,
                math.floor(
                    tonumber(auto.KeepAmount)
                    or 0
                )
            ),

        PetVariant =
            tostring(
                auto.PetVariant
                or "Any Variant"
            ),

        PetSize =
            tostring(
                auto.PetSize
                or "Any Size"
            ),

        Message =
            tostring(
                auto.Message
                or ""
            ),
    }

    table.insert(
        auto.Rules,
        rule
    )

    GAG2MailboxAutoSaveRules()
    GAG2MailboxAutoRefreshQueueVisuals()

    GAG2MailboxAutoSetStatus(
        "Added automatic rule: "
        .. tostring(itemChoice)
    )

    return true
end

function GAG2MailboxAutoRemoveSelectedRule()

    local auto =
        GAG2MailboxAutoGetState()

    local index =
        auto.RuleChoiceMap[
            auto.SelectedRuleChoice
        ]

    if not index
    or not auto.Rules[index] then

        GAG2MailboxAutoSetStatus(
            "Select a rule to remove."
        )

        return false
    end

    local removed =
        table.remove(
            auto.Rules,
            index
        )

    auto.SelectedRuleChoice =
        "None"

    GAG2MailboxAutoSaveRules()
    GAG2MailboxAutoRefreshQueueVisuals()

    GAG2MailboxAutoSetStatus(
        "Removed rule: "
        .. tostring(
            removed
            and removed.ItemChoice
            or "unknown"
        )
    )

    return true
end

function GAG2MailboxAutoClearRules()

    local auto =
        GAG2MailboxAutoGetState()

    auto.Rules =
        {}

    auto.SelectedRuleChoice =
        "None"

    GAG2MailboxAutoSaveRules()
    GAG2MailboxAutoRefreshQueueVisuals()

    GAG2MailboxAutoSetStatus(
        "Automatic rules cleared."
    )
end

function GAG2MailboxAutoCopySelectedReceipt()

    local auto =
        GAG2MailboxAutoGetState()

    local index =
        auto.ReceiptChoiceMap[
            auto.SelectedReceiptChoice
        ]

    local receipt =
        index
        and auto.Receipts[index]
        or nil

    if not receipt then

        GAG2MailboxAutoSetStatus(
            "Select a receipt first."
        )

        return false
    end

    local text =
        GAG2MailboxAutoReceiptText(
            receipt
        )

    local copied =
        CopyText(
            text
        )

    GAG2MailboxAutoSetStatus(
        copied == true
        and "Receipt copied."
        or "Clipboard unavailable."
    )

    return copied
end

function GAG2MailboxAutoClearReceipts()

    local auto =
        GAG2MailboxAutoGetState()

    auto.Receipts =
        {}

    auto.SelectedReceiptChoice =
        "None"

    GAG2MailboxAutoRefreshReceiptVisuals()

    GAG2MailboxAutoSetStatus(
        "Receipts cleared."
    )
end

function GAG2MailboxAutoTriggerPassed(ownedAmount, rule)

    ownedAmount =
        math.max(
            0,
            math.floor(
                tonumber(ownedAmount)
                or 0
            )
        )

    local triggerAmount =
        math.max(
            1,
            math.floor(
                tonumber(rule.TriggerAmount)
                or 1
            )
        )

    if rule.TriggerMode == "Above" then

        return ownedAmount
            > triggerAmount
    end

    return ownedAmount
        >= triggerAmount
end

function GAG2MailboxAutoComputeSendCount(ownedAmount, rule)

    ownedAmount =
        math.max(
            0,
            math.floor(
                tonumber(ownedAmount)
                or 0
            )
        )

    local keepAmount =
        math.max(
            0,
            math.floor(
                tonumber(rule.KeepAmount)
                or 0
            )
        )

    if rule.SendMode == "Send All Available" then

        return ownedAmount
    end

    local availableAfterKeep =
        math.max(
            0,
            ownedAmount - keepAmount
        )

    if rule.SendMode == "Send Excess" then

        return availableAfterKeep
    end

    local sendAmount =
        math.max(
            1,
            math.floor(
                tonumber(rule.SendAmount)
                or 1
            )
        )

    return math.min(
        sendAmount,
        availableAfterKeep
    )
end

function GAG2MailboxAutoBuildPetMatches(rule)

    local matches =
        {}

    for _, pet in ipairs(
        GAG2MailboxAutoGetPets(
            false
        )
    ) do

        if GAG2MailboxAutoPetMatchesRule(
            pet,
            rule
        ) == true then

            table.insert(
                matches,
                pet
            )
        end
    end

    table.sort(
        matches,
        function(a, b)

            return tostring(a.Id or "")
                < tostring(b.Id or "")
        end
    )

    return matches
end

function GAG2MailboxAutoFindStackable(rule)

    local wantedCategory =
        GAG2MailboxAutoNormalizeKey(
            rule.Category
        )

    local wantedItem =
        GAG2MailboxAutoNormalizeKey(
            rule.ItemChoice
        )

    for _, sendable in ipairs(
        GAG2_MAILBOX_STATE.Sendables
        or {}
    ) do

        if GAG2MailboxAutoNormalizeKey(sendable.Category) == wantedCategory
        and GAG2MailboxAutoNormalizeKey(sendable.ItemKey) == wantedItem then

            return sendable
        end
    end

    return nil
end

function GAG2MailboxAutoBuildBatch(rule)

    if type(rule) ~= "table" then

        return nil,
            "bad rule"
    end

    if rule.Category == "Pets" then

        local matches =
            GAG2MailboxAutoBuildPetMatches(
                rule
            )

        local ownedAmount =
            #matches

        if GAG2MailboxAutoTriggerPassed(
            ownedAmount,
            rule
        ) ~= true then

            return nil,
                tostring(rule.ItemChoice)
                .. ": "
                .. tostring(ownedAmount)
                .. "/"
                .. tostring(rule.TriggerAmount)
        end

        local sendCount =
            GAG2MailboxAutoComputeSendCount(
                ownedAmount,
                rule
            )

        sendCount =
            math.min(
                sendCount,
                ownedAmount,
                math.clamp(
                    math.floor(
                        tonumber(
                            GAG2_MAILBOX_STATE.MaxRowsPerMail
                        )
                        or 20
                    ),
                    1,
                    20
                )
            )

        if sendCount <= 0 then

            return nil,
                tostring(rule.ItemChoice)
                .. ": keep amount leaves nothing to send"
        end

        local batch =
            {}

        for index = 1, sendCount do

            local pet =
                matches[index]

            if pet
            and GAG2MailboxClean(pet.Id) ~= "" then

                table.insert(
                    batch,
                    {
                        Category =
                            "Pets",

                        ItemKey =
                            pet.Id,

                        Count =
                            1,
                    }
                )
            end
        end

        if #batch <= 0 then

            return nil,
                "no valid matching pet UUIDs"
        end

        return batch,
            {
                Owned =
                    ownedAmount,

                Count =
                    #batch,

                Requested =
                    sendCount,

                Item =
                    rule.ItemChoice,

                Category =
                    "Pets",
            }
    end

    local sendable =
        GAG2MailboxAutoFindStackable(
            rule
        )

    if not sendable then

        return nil,
            tostring(rule.ItemChoice)
            .. ": item unavailable"
    end

    local ownedAmount =
        math.max(
            0,
            math.floor(
                tonumber(sendable.Amount)
                or 0
            )
        )

    if GAG2MailboxAutoTriggerPassed(
        ownedAmount,
        rule
    ) ~= true then

        return nil,
            tostring(rule.ItemChoice)
            .. ": "
            .. tostring(ownedAmount)
            .. "/"
            .. tostring(rule.TriggerAmount)
    end

    local sendCount =
        GAG2MailboxAutoComputeSendCount(
            ownedAmount,
            rule
        )

    sendCount =
        math.min(
            sendCount,
            ownedAmount
        )

    if sendCount <= 0 then

        return nil,
            tostring(rule.ItemChoice)
            .. ": keep amount leaves nothing to send"
    end

    local batch = {
        {
            Category =
                sendable.Category,

            ItemKey =
                sendable.ItemKey,

            Count =
                sendCount,
        },
    }

    return batch,
        {
            Owned =
                ownedAmount,

            Count =
                sendCount,

            Requested =
                sendCount,

            Item =
                rule.ItemChoice,

            Category =
                sendable.Category,
        }
end

function GAG2MailboxAutoResolveTarget(targetText)

    local auto =
        GAG2MailboxAutoGetState()

    local cacheKey =
        GAG2MailboxAutoNormalizeKey(
            targetText
        )

    local cached =
        auto.TargetCache[cacheKey]

    if type(cached) == "table"
    and tonumber(cached.UserId)
    and os.clock() - tonumber(cached.At or 0) < 600 then

        return tonumber(cached.UserId),
            "cached"
    end

    local userId, reason =
        GAG2MailboxResolveTargetUserId(
            targetText
        )

    if userId then

        auto.TargetCache[cacheKey] = {
            UserId =
                userId,

            At =
                os.clock(),
        }
    end

    return userId,
        reason
end

function GAG2MailboxAutoProcessRule(rule, ruleIndex)

    local auto =
        GAG2MailboxAutoGetState()

    auto.LastRuleText =
        GAG2MailboxAutoBuildRuleDisplay(
            rule,
            ruleIndex
        )

    local batch, info =
        GAG2MailboxAutoBuildBatch(
            rule
        )

    if not batch then

        return false,
            tostring(info),
            false
    end

    local targetUserId, targetReason =
        GAG2MailboxAutoResolveTarget(
            rule.TargetText
        )

    if not targetUserId then

        return false,
            "Bad recipient: "
            .. tostring(targetReason),
            true
    end

    local ok, source =
        GAG2MailboxFirePacket(
            "SendBatch",
            "MailboxSendBatch",
            targetUserId,
            batch,
            tostring(rule.Message or "")
        )

    if ok ~= true then

        GAG2MailboxAutoAddReceipt({
            TargetText =
                rule.TargetText,

            TargetUserId =
                targetUserId,

            Category =
                info.Category,

            Item =
                info.Item,

            Requested =
                info.Requested,

            Count =
                0,

            Rows =
                #batch,

            Result =
                "Failed",

            Details =
                tostring(source),
        })

        return false,
            "Send failed: "
            .. tostring(source),
            true
    end

    auto.ConsecutiveFailures =
        0

    auto.SessionMails = auto.SessionMails + 1

    auto.SessionItems = auto.SessionItems + tonumber(info.Count)
        or 0

    auto.NextAllowedAt =
        os.clock()
        + math.clamp(
            tonumber(auto.MailCooldown)
            or 3,
            1,
            30
        )

    GAG2_MAILBOX_STATE.LastTargetUserId =
        targetUserId

    GAG2_MAILBOX_STATE.LastCategory =
        info.Category

    GAG2_MAILBOX_STATE.LastItemKey =
        info.Item

    GAG2_MAILBOX_STATE.LastSendCount =
        info.Count

    GAG2_MAILBOX_STATE.LastBatchRows =
        #batch

    GAG2MailboxAutoAddReceipt({
        TargetText =
            rule.TargetText,

        TargetUserId =
            targetUserId,

        Category =
            info.Category,

        Item =
            info.Item,

        Requested =
            info.Requested,

        Count =
            info.Count,

        Rows =
            #batch,

        Result =
            "Success",

        Details =
            tostring(source)
            .. " | "
            .. tostring(targetReason),
    })

    auto.LastPetRefreshAt =
        0

    task.delay(0.45, function()

        pcall(
            GAG2MailboxBuildSendables
        )

        GAG2MailboxAutoRefreshDropdowns(
            true
        )
    end)

    return true,
        "Sent "
        .. tostring(info.Item)
        .. " x"
        .. tostring(info.Count)
        .. " to "
        .. tostring(rule.TargetText),
        false
end

function GAG2MailboxAutoStopWorker(reason)

    local auto =
        GAG2MailboxAutoGetState()

    auto.LoopToken = auto.LoopToken + 1

    auto.Running =
        false

    if reason then

        auto.LastAction =
            tostring(reason)
    end
end

function GAG2MailboxAutoStartWorker()

    local auto =
        GAG2MailboxAutoGetState()

    if auto.Enabled ~= true then
        return false
    end

    if auto.Running == true then
        return true
    end

    auto.LoopToken = auto.LoopToken + 1

    local token =
        auto.LoopToken

    auto.Running =
        true

    task.spawn(function()

        while auto.Enabled == true
        and auto.LoopToken == token do

            auto.LastCheckAt =
                os.clock()

            if #auto.Rules <= 0 then

                GAG2MailboxAutoSetStatus(
                    "Automatic Send is waiting for a rule."
                )

            elseif os.clock() < tonumber(auto.NextAllowedAt or 0) then

                local remaining =
                    math.max(
                        0,
                        math.ceil(
                            tonumber(auto.NextAllowedAt)
                            - os.clock()
                        )
                    )

                GAG2MailboxAutoSetStatus(
                    "Waiting "
                    .. tostring(remaining)
                    .. "s before the next mail."
                )

            else

                pcall(
                    GAG2MailboxBuildSendables
                )

                local sent =
                    false

                local lastWaitReason =
                    "Waiting for a rule trigger."

                for index, rule in ipairs(auto.Rules) do

                    if auto.Enabled ~= true
                    or auto.LoopToken ~= token then

                        break
                    end

                    if rule.Enabled ~= false then

                        local didSend, reason, hardFailure =
                            GAG2MailboxAutoProcessRule(
                                rule,
                                index
                            )

                        if didSend == true then

                            sent =
                                true

                            GAG2MailboxAutoSetStatus(
                                reason
                            )

                            break
                        end

                        lastWaitReason =
                            tostring(reason)

                        if hardFailure == true then

                            auto.ConsecutiveFailures = auto.ConsecutiveFailures + 1

                            GAG2MailboxAutoSetStatus(
                                reason
                                .. " | Failure "
                                .. tostring(auto.ConsecutiveFailures)
                                .. "/3"
                            )

                            if auto.StopAfterFailedSends == true
                            and auto.ConsecutiveFailures >= 3 then

                                auto.Enabled =
                                    false

                                auto.LastAction =
                                    "Stopped after three failed sends."

                                if GAG2_MAILBOX_AUTO_CONTROLS.Enabled
                                and type(
                                    GAG2_MAILBOX_AUTO_CONTROLS.Enabled.SetValue
                                ) == "function" then

                                    pcall(function()

                                        GAG2_MAILBOX_AUTO_CONTROLS.Enabled:SetValue(
                                            false
                                        )
                                    end)
                                end
                            end

                            break
                        end
                    end
                end

                if sent ~= true
                and auto.Enabled == true
                and auto.ConsecutiveFailures < 3 then

                    GAG2MailboxAutoSetStatus(
                        lastWaitReason
                    )
                end
            end

            GAG2MailboxAutoRefreshQueueVisuals()

            task.wait(
                math.clamp(
                    tonumber(auto.CheckInterval)
                    or 3,
                    1,
                    30
                )
            )
        end

        if auto.LoopToken == token then

            auto.Running =
                false
        end

        GAG2MailboxSetStatus(
            auto.LastAction
            or "Automatic Send stopped."
        )
    end)

    return true
end

function GAG2MailboxAutoSetEnabled(value)

    local auto =
        GAG2MailboxAutoGetState()

    auto.Enabled =
        value == true

    if auto.Enabled == true then

        auto.ConsecutiveFailures =
            0

        GAG2MailboxAutoStartWorker()

    else

        GAG2MailboxAutoStopWorker(
            "Automatic Send stopped."
        )
    end

    MarkConfigDirty()

    GAG2MailboxSetStatus(
        auto.Enabled == true
        and "Automatic Send started."
        or "Automatic Send stopped."
    )
end

function GAG2MailboxAutoStartFromButton()

    local control =
        GAG2_MAILBOX_AUTO_CONTROLS.Enabled

    if control
    and type(control.SetValue) == "function" then

        control:SetValue(
            true
        )

        return
    end

    GAG2MailboxAutoSetEnabled(
        true
    )
end

function GAG2MailboxAutoStopFromButton()

    local control =
        GAG2_MAILBOX_AUTO_CONTROLS.Enabled

    if control
    and type(control.SetValue) == "function" then

        control:SetValue(
            false
        )

        return
    end

    GAG2MailboxAutoSetEnabled(
        false
    )
end

getgenv().HOLY_GAG2_MAILBOX_AUTO_START =
    GAG2MailboxAutoStartFromButton

getgenv().HOLY_GAG2_MAILBOX_AUTO_STOP =
    GAG2MailboxAutoStopFromButton


function GAG2MailboxExposeDebug()

    getgenv().HOLY_GAG2_MAILBOX_STATE =
        GAG2_MAILBOX_STATE

    getgenv().HOLY_GAG2_MAILBOX_REFRESH =
        function()

            return GAG2MailboxRefreshSendableDropdown()
        end

    getgenv().HOLY_GAG2_MAILBOX_GET_SENDABLES =
        function()

            GAG2MailboxRefreshSendableDropdown()

            return GAG2_MAILBOX_STATE.Sendables
        end

    getgenv().HOLY_GAG2_MAILBOX_SEND_SELECTED =
        function()

            return GAG2MailboxSendSelectedBatchNow()
        end

    getgenv().HOLY_GAG2_MAILBOX_SEND_PET_BATCH =
        function(targetUserId, petId, amount, message)

            GAG2_MAILBOX_STATE.TargetText =
                tostring(targetUserId or "")

            GAG2_MAILBOX_STATE.SelectedCategory =
                "Pets"

            GAG2_MAILBOX_STATE.ItemChoice =
                "Direct Pet UUID"

            GAG2_MAILBOX_STATE.ChoiceToSendable =
                {
                    ["Direct Pet UUID"] = {
                        Category = "Pets",
                        ItemKey = tostring(petId or ""),
                        Amount = 1,
                        IsStackable = false,
                        Display = "Pets | "
                            .. tostring(petId or "")
                            .. " | x1",
                    },
                }

            GAG2_MAILBOX_STATE.Amount =
                math.clamp(
                    math.floor(
                        tonumber(amount)
                        or 1
                    ),
                    1,
                    999999
                )

            GAG2_MAILBOX_STATE.Message =
                tostring(message or "")

            return GAG2MailboxSendSelectedBatchNow()
        end

    getgenv().HOLY_GAG2_MAILBOX_SEND_ITEM =
        function(targetUserId, category, itemKey, amount, message)

            GAG2_MAILBOX_STATE.TargetText =
                tostring(targetUserId or "")

            GAG2_MAILBOX_STATE.SelectedCategory =
                tostring(category or "All")

            GAG2_MAILBOX_STATE.ItemChoice =
                "Direct Item"

            GAG2_MAILBOX_STATE.ChoiceToSendable =
                {
                    ["Direct Item"] = {
                        Category = tostring(category or ""),
                        ItemKey = tostring(itemKey or ""),
                        Amount = tonumber(amount) or 1,
                        IsStackable = tostring(category or "") ~= "Pets",
                        Display = tostring(category or "")
                            .. " | "
                            .. tostring(itemKey or "")
                            .. " | x"
                            .. tostring(amount or 1),
                    },
                }

            GAG2_MAILBOX_STATE.Amount =
                math.clamp(
                    math.floor(
                        tonumber(amount)
                        or 1
                    ),
                    1,
                    999999
                )

            GAG2_MAILBOX_STATE.Message =
                tostring(message or "")

            return GAG2MailboxSendSelectedBatchNow()
        end

    getgenv().HOLY_GAG2_MAILBOX_OPEN_INBOX =
        function()

            return GAG2MailboxOpenInbox()
        end
end

function GAG2RestoreMailboxState()

    task.defer(function()

        GAG2MailboxEnsureUniversalState()
        GAG2MailboxExposeDebug()
        GAG2MailboxStartReplicaWatcher()
        GAG2MailboxAutoLoadRules()

        local auto =
            GAG2MailboxAutoGetState()

        if Options.HolyGAG2MailboxTarget then

            GAG2MailboxSetTarget(
                Options.HolyGAG2MailboxTarget.Value
            )
        end

        if Options.HolyGAG2MailboxCategoryChoice then

            GAG2_MAILBOX_STATE.SelectedCategory =
                GAG2MailboxClean(
                    Options.HolyGAG2MailboxCategoryChoice.Value
                )

            if GAG2_MAILBOX_STATE.SelectedCategory == "" then

                GAG2_MAILBOX_STATE.SelectedCategory =
                    "All"
            end
        end

        if Options.HolyGAG2MailboxItemChoice then

            GAG2_MAILBOX_STATE.ItemChoice =
                GAG2MailboxClean(
                    Options.HolyGAG2MailboxItemChoice.Value
                )

            if GAG2_MAILBOX_STATE.ItemChoice == "" then

                GAG2_MAILBOX_STATE.ItemChoice =
                    "None"
            end
        end

        if Options.HolyGAG2MailboxAmount then

            GAG2MailboxSetAmount(
                Options.HolyGAG2MailboxAmount.Value
            )
        end

        if Options.HolyGAG2MailboxMaxRowsPerMail then

            GAG2MailboxSetMaxRowsPerMail(
                Options.HolyGAG2MailboxMaxRowsPerMail.Value
            )
        end

        if Options.HolyGAG2MailboxMessage then

            GAG2MailboxSetMessage(
                Options.HolyGAG2MailboxMessage.Value
            )
        end

        if Options.HolyGAG2MailboxAutoRecipient then

            auto.RecipientText =
                tostring(
                    Options.HolyGAG2MailboxAutoRecipient.Value
                    or ""
                )
        end

        if Options.HolyGAG2MailboxAutoCategory then

            auto.Category =
                GAG2MailboxClean(
                    Options.HolyGAG2MailboxAutoCategory.Value
                )
        end

        if Options.HolyGAG2MailboxAutoItem then

            auto.ItemChoice =
                GAG2MailboxClean(
                    Options.HolyGAG2MailboxAutoItem.Value
                )
        end

        if Options.HolyGAG2MailboxAutoTriggerMode then

            auto.TriggerMode =
                tostring(
                    Options.HolyGAG2MailboxAutoTriggerMode.Value
                    or "At Least"
                )
        end

        if Options.HolyGAG2MailboxAutoTriggerAmount then

            auto.TriggerAmount =
                math.max(
                    1,
                    math.floor(
                        tonumber(
                            Options.HolyGAG2MailboxAutoTriggerAmount.Value
                        )
                        or 5
                    )
                )
        end

        if Options.HolyGAG2MailboxAutoSendMode then

            auto.SendMode =
                tostring(
                    Options.HolyGAG2MailboxAutoSendMode.Value
                    or "Fixed Amount"
                )
        end

        if Options.HolyGAG2MailboxAutoSendAmount then

            auto.SendAmount =
                math.max(
                    1,
                    math.floor(
                        tonumber(
                            Options.HolyGAG2MailboxAutoSendAmount.Value
                        )
                        or 5
                    )
                )
        end

        if Options.HolyGAG2MailboxAutoKeepAmount then

            auto.KeepAmount =
                math.max(
                    0,
                    math.floor(
                        tonumber(
                            Options.HolyGAG2MailboxAutoKeepAmount.Value
                        )
                        or 0
                    )
                )
        end

        if Options.HolyGAG2MailboxAutoPetVariant then

            auto.PetVariant =
                tostring(
                    Options.HolyGAG2MailboxAutoPetVariant.Value
                    or "Any Variant"
                )
        end

        if Options.HolyGAG2MailboxAutoPetSize then

            auto.PetSize =
                tostring(
                    Options.HolyGAG2MailboxAutoPetSize.Value
                    or "Any Size"
                )
        end

        if Options.HolyGAG2MailboxAutoMessage then

            auto.Message =
                tostring(
                    Options.HolyGAG2MailboxAutoMessage.Value
                    or ""
                )
        end

        if Options.HolyGAG2MailboxAutoCheckInterval then

            auto.CheckInterval =
                math.clamp(
                    tonumber(
                        Options.HolyGAG2MailboxAutoCheckInterval.Value
                    )
                    or 3,
                    1,
                    30
                )
        end

        if Options.HolyGAG2MailboxAutoCooldown then

            auto.MailCooldown =
                math.clamp(
                    tonumber(
                        Options.HolyGAG2MailboxAutoCooldown.Value
                    )
                    or 3,
                    1,
                    30
                )
        end

        if Toggles.HolyGAG2MailboxAutoStopOnFailures then

            auto.StopAfterFailedSends =
                Toggles.HolyGAG2MailboxAutoStopOnFailures.Value ~= false
        end

        if Toggles.HolyGAG2MailboxAutoEnabled then

            auto.Enabled =
                Toggles.HolyGAG2MailboxAutoEnabled.Value == true
        end

        GAG2MailboxRefreshSendableDropdown()
        GAG2MailboxAutoRefreshDropdowns(true)
        GAG2MailboxAutoRefreshQueueVisuals()
        GAG2MailboxAutoRefreshReceiptVisuals()

        if auto.Enabled == true then

            GAG2MailboxAutoStartWorker()
        end

        GAG2MailboxSetStatus(
            auto.Enabled == true
            and "Automatic Send restored."
            or "Ready. Open mailbox Send tab, then Refresh Items."
        )
    end)
end

--==================================================
-- [4.59] EXPERIMENT AUTO DROP SEED
-- Real seed drop packet path.
-- Confirmed sequence:
-- 1. Equip seed tool
-- 2. 14 01 Seeds.<Seed>
-- 3. Shovel:Shovel + Seed:<Seed>
-- 4. 08 01 <uuid1> <uuid2> <position>
--==================================================

GAG2_AUTO_DROP_SEED_STATE =
    GAG2_AUTO_DROP_SEED_STATE
    or {
        Enabled = false,
        Running = false,

        Seed = "Rainbow",
        Amount = 1,
        Delay = 0.35,
        Burst = 1,

        Dropped = 0,
        LastStatus = "Idle.",
        LastError = "",
        LastSeed = "",
        LastPosition = nil,

        SeedSlots = {
            Rainbow = 2,
            Gold = 3,
        },
    }

function GAG2SeedDropClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2SeedDropSetStatus(text)

    local state =
        GAG2_AUTO_DROP_SEED_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2ExperimentStatus then

        Options.HolyGAG2ExperimentStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Auto Drop Seed</b></font>'
            .. '\nState: '
            .. (
                state.Enabled == true
                and "ON"
                or "OFF"
            )
            .. ' | Running: '
            .. tostring(state.Running == true)
            .. '\nSeed: '
            .. tostring(state.Seed or "Rainbow")
            .. ' | Dropped: '
            .. tostring(state.Dropped or 0)
            .. '/'
            .. tostring(state.Amount or 1)
            .. '\nBurst: '
            .. tostring(state.Burst or 1)
            .. ' | Delay: '
            .. tostring(state.Delay or 0.35)
            .. 's'
            .. '\n'
            .. tostring(state.LastStatus)
        )
    end
end

function GAG2SeedDropWriteAscii(packet, offset, text)

    text =
        tostring(text or "")

    for index = 1, #text do

        buffer.writeu8(
            packet,
            offset + index - 1,
            string.byte(text, index)
        )
    end
end

function GAG2SeedDropBufferToHex(packet)

    local length =
        buffer.len(packet)

    local output =
        table.create(length)

    for index = 0, length - 1 do

        output[#output + 1] =
            string.format(
                "%02X",
                buffer.readu8(packet, index)
            )
    end

    return table.concat(
        output
    )
end

function GAG2SeedDropGetRemote()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local packetFolder =
        sharedModules
        and sharedModules:FindFirstChild("Packet")

    local remote =
        packetFolder
        and packetFolder:FindFirstChild("RemoteEvent")

    if remote
    and remote:IsA("RemoteEvent") then

        return remote
    end

    return nil
end

function GAG2SeedDropBuildSelectPacket(seedName)

    seedName =
        tostring(seedName or "Rainbow")

    local prefix =
        "Seeds"

    local packet =
        buffer.create(
            3
            + #prefix
            + 1
            + #seedName
        )

    local offset =
        0

    buffer.writeu8(packet, offset, 0x14)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x01)
    offset = offset + 1

    buffer.writeu8(packet, offset, #prefix)
    offset = offset + 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        prefix
    )

    offset = offset + #prefix

    buffer.writeu8(packet, offset, #seedName)
    offset = offset + 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        seedName
    )

    return packet
end

function GAG2SeedDropBuildStatePacket(seedName, slotIndex)

    seedName =
        tostring(seedName or "Rainbow")

    slotIndex =
        tonumber(slotIndex)
        or 2

    local shovelText =
        "Shovel:Shovel"

    local seedText =
        "Seed:" .. seedName

    local packet =
        buffer.create(
            7
            + #shovelText
            + 4
            + #seedText
            + 1
        )

    local offset =
        0

    buffer.writeu8(packet, offset, 0x60)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x00)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x1C)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x05)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x01)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x0B)
    offset = offset + 1

    buffer.writeu8(packet, offset, #shovelText)
    offset = offset + 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        shovelText
    )

    offset = offset + #shovelText

    buffer.writeu8(packet, offset, 0x05)
    offset = offset + 1

    buffer.writeu8(packet, offset, slotIndex)
    offset = offset + 1

    buffer.writeu8(packet, offset, 0x0B)
    offset = offset + 1

    buffer.writeu8(packet, offset, #seedText)
    offset = offset + 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        seedText
    )

    offset = offset + #seedText

    buffer.writeu8(packet, offset, 0x00)

    return packet
end

function GAG2SeedDropBuildRealDropPacket(position)

    if typeof(position) ~= "Vector3" then

        position =
            Vector3.zero
    end

    local uuid1 =
        HttpService:GenerateGUID(false):lower()

    local uuid2 =
        HttpService:GenerateGUID(false):lower()

    local packet =
        buffer.create(88)

    buffer.writeu8(packet, 0, 0x08)
    buffer.writeu8(packet, 1, 0x01)

    buffer.writeu8(packet, 2, 0x24)

    GAG2SeedDropWriteAscii(
        packet,
        3,
        uuid1
    )

    buffer.writeu8(packet, 39, 0x24)

    GAG2SeedDropWriteAscii(
        packet,
        40,
        uuid2
    )

    buffer.writef32(packet, 76, position.X)
    buffer.writef32(packet, 80, position.Y)
    buffer.writef32(packet, 84, position.Z)

    return packet,
        uuid1,
        uuid2
end

function GAG2SeedDropGetCharacter()

    return LOCAL_PLAYER.Character
        or LOCAL_PLAYER.CharacterAdded:Wait()
end

function GAG2SeedDropGetBackpack()

    return LOCAL_PLAYER:FindFirstChildOfClass("Backpack")
        or LOCAL_PLAYER:WaitForChild("Backpack")
end

function GAG2SeedDropIsRealSeedTool(tool, seedName)

    if typeof(tool) ~= "Instance"
    or not tool:IsA("Tool") then

        return false
    end

    seedName =
        GAG2SeedDropClean(seedName):lower()

    if seedName == "" then

        return false
    end

    local toolName =
        tostring(tool.Name or ""):lower()

    local seedTool =
        tostring(tool:GetAttribute("SeedTool") or ""):lower()

    local mainCategory =
        tostring(tool:GetAttribute("MainCategory") or ""):lower()

    -- Real confirmed seed tools look like:
    -- Name = Rainbow / Gold
    -- SeedTool = Rainbow / Gold
    -- MainCategory = Seed
    if seedTool ~= "" then

        return seedTool == seedName
            and mainCategory == "seed"
    end

    -- Fallback for seed tools that only expose MainCategory.
    if mainCategory == "seed"
    and toolName == seedName then

        return true
    end

    return false
end

function GAG2SeedDropFindTool(seedName)

    seedName =
        GAG2SeedDropClean(seedName)

    local character =
        GAG2SeedDropGetCharacter()

    local backpack =
        GAG2SeedDropGetBackpack()

    for _, item in ipairs(character:GetChildren()) do

        if GAG2SeedDropIsRealSeedTool(
            item,
            seedName
        ) then

            return item
        end
    end

    for _, item in ipairs(backpack:GetChildren()) do

        if GAG2SeedDropIsRealSeedTool(
            item,
            seedName
        ) then

            return item
        end
    end

    return nil
end

function GAG2SeedDropCleanSeedName(value)

    value =
        GAG2SeedDropClean(value)

    local beforePipe =
        value:match("^(.-)%s+|%s+")

    if beforePipe
    and GAG2SeedDropClean(beforePipe) ~= "" then

        value =
            GAG2SeedDropClean(beforePipe)
    end

    return value
end

function GAG2SeedDropAddSeedValue(values, seen, seedName)

    seedName =
        GAG2SeedDropCleanSeedName(
            seedName
        )

    if seedName == "" then
        return
    end

    local key =
        seedName:lower()

    if seen[key] == true then
        return
    end

    seen[key] =
        true

    values[#values + 1] =
        seedName
end

function GAG2SeedDropReadSeedNameFromTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local mainCategory =
        GAG2SeedDropClean(
            tool:GetAttribute("MainCategory")
        )

    local seedTool =
        GAG2SeedDropClean(
            tool:GetAttribute("SeedTool")
        )

    if mainCategory:lower() ~= "seed" then
        return ""
    end

    if seedTool ~= "" then
        return seedTool
    end

    return GAG2SeedDropClean(
        tool.Name
    )
end

function GAG2SeedDropGetAllSeedValues()

    local values =
        {}

    local seen =
        {}

    -- Main source: all known shop seed names.
    if type(GAG2ShopGetItemNames) == "function" then

        local shopSeeds =
            GAG2ShopGetItemNames(
                "Seeds"
            )

        if type(shopSeeds) == "table" then

            for _, seedName in ipairs(shopSeeds) do

                GAG2SeedDropAddSeedValue(
                    values,
                    seen,
                    seedName
                )
            end
        end
    end

    -- Backup source: Seed Planting list, if available.
    if type(GAG2SeedPlantGetSeedValues) == "function" then

        local plantSeeds =
            GAG2SeedPlantGetSeedValues()

        if type(plantSeeds) == "table" then

            for _, seedName in ipairs(plantSeeds) do

                GAG2SeedDropAddSeedValue(
                    values,
                    seen,
                    seedName
                )
            end
        end
    end

    -- Include current saved selection.
    if GAG2_AUTO_DROP_SEED_STATE then

        GAG2SeedDropAddSeedValue(
            values,
            seen,
            GAG2_AUTO_DROP_SEED_STATE.Seed
        )
    end

    -- Include currently owned real seed tools too.
    local function scan(container)

        if typeof(container) ~= "Instance" then
            return
        end

        for _, child in ipairs(container:GetChildren()) do

            local seedName =
                GAG2SeedDropReadSeedNameFromTool(
                    child
                )

            if seedName ~= "" then

                GAG2SeedDropAddSeedValue(
                    values,
                    seen,
                    seedName
                )
            end
        end
    end

    scan(
        LOCAL_PLAYER.Character
    )

    scan(
        LOCAL_PLAYER:FindFirstChildOfClass("Backpack")
    )

    -- Confirmed manual-drop seed tools / fallback values.
    GAG2SeedDropAddSeedValue(values, seen, "Rainbow")
    GAG2SeedDropAddSeedValue(values, seen, "Gold")
    GAG2SeedDropAddSeedValue(values, seen, "Carrot")

    table.sort(
        values,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return values
end

function GAG2SeedDropRefreshDropdown()

    local controls =
        GAG2_AUTO_DROP_SEED_CONTROLS

    local dropdown =
        controls
        and controls.Seed

    if not dropdown then
        return
    end

    local values =
        GAG2SeedDropGetAllSeedValues()

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)

    GAG2SeedDropSetStatus(
        "Loaded "
        .. tostring(#values)
        .. " known seed type(s)."
    )
end

function GAG2SeedDropEquipTool(seedName)

    local character =
        GAG2SeedDropGetCharacter()

    local tool =
        GAG2SeedDropFindTool(seedName)

    if not tool then

        return false,
            "missing seed tool: " .. tostring(seedName)
    end

    if tool.Parent == character then

        return true,
            tool
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then

        return false,
            "missing humanoid"
    end

    humanoid:EquipTool(
        tool
    )

    task.wait(
        0.22
    )

    if tool.Parent ~= character then

        return false,
            "equip failed: " .. tostring(tool.Name)
    end

    return true,
        tool
end

function GAG2SeedDropGetPosition(burstIndex)

    burstIndex =
        math.max(
            1,
            math.floor(
                tonumber(burstIndex)
                or 1
            )
        )

    local character =
        GAG2SeedDropGetCharacter()

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then

        return Vector3.zero
    end

    local row =
        math.floor((burstIndex - 1) / 5)

    local column =
        (burstIndex - 1) % 5

    local sideOffset =
        (column - 2) * 0.65

    local forwardOffset =
        row * 0.65

    local target =
        root.Position
        + (root.CFrame.LookVector * (5 + forwardOffset))
        + (root.CFrame.RightVector * sideOffset)

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances =
        {
            character,
        }

    rayParams.IgnoreWater =
        true

    local result =
        workspace:Raycast(
            target + Vector3.new(0, 12, 0),
            Vector3.new(0, -80, 0),
            rayParams
        )

    if result
    and typeof(result.Position) == "Vector3" then

        return result.Position
            + Vector3.new(0, 0.65, 0)
    end

    return target
end

function GAG2SeedDropFire(packet, label)

    local remote =
        GAG2SeedDropGetRemote()

    if not remote then

        return false,
            "SharedModules.Packet.RemoteEvent missing"
    end

    local ok, err =
        pcall(function()

            remote:FireServer(
                packet
            )
        end)

    if ok ~= true then

        return false,
            tostring(err)
    end

    return true,
        tostring(label or "fired")
end

function GAG2SeedDropSetSeed(value)

    value =
        GAG2SeedDropCleanSeedName(
            value
        )

    if value == "" then

        value =
            "Rainbow"
    end

    GAG2_AUTO_DROP_SEED_STATE.Seed =
        value

    GAG2SeedDropSetStatus(
        "Seed set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2SeedDropSetAmount(value)

    local amount =
        math.floor(
            tonumber(value)
            or 1
        )

    GAG2_AUTO_DROP_SEED_STATE.Amount =
        math.max(
            1,
            amount
        )

    GAG2SeedDropSetStatus(
        "Amount set: "
        .. tostring(GAG2_AUTO_DROP_SEED_STATE.Amount)
    )

    MarkConfigDirty()
end

function GAG2SeedDropSetDelay(value)

    local delaySeconds =
        tonumber(value)
        or 0.35

    GAG2_AUTO_DROP_SEED_STATE.Delay =
        math.clamp(
            delaySeconds,
            0,
            10
        )

    GAG2SeedDropSetStatus(
        "Delay set: "
        .. tostring(GAG2_AUTO_DROP_SEED_STATE.Delay)
        .. "s"
    )

    MarkConfigDirty()
end

function GAG2SeedDropSetBurst(value)

    local burst =
        math.floor(
            tonumber(value)
            or 1
        )

    GAG2_AUTO_DROP_SEED_STATE.Burst =
        math.clamp(
            burst,
            1,
            250
        )

    GAG2SeedDropSetStatus(
        "Burst set: "
        .. tostring(GAG2_AUTO_DROP_SEED_STATE.Burst)
    )

    MarkConfigDirty()
end

function GAG2SeedDropOnce(seedName, burstCount)

    local state =
        GAG2_AUTO_DROP_SEED_STATE

seedName =
    GAG2SeedDropCleanSeedName(
        seedName
        or state.Seed
        or "Rainbow"
    )

if seedName == "" then

    seedName =
        "Rainbow"
end

    burstCount =
        math.clamp(
            math.floor(
                tonumber(burstCount)
                or 1
            ),
            1,
            250
        )

local slotIndex =
    state.SeedSlots
    and state.SeedSlots[seedName]

    local equipped, toolOrReason =
        GAG2SeedDropEquipTool(
            seedName
        )

    if equipped ~= true then

        state.LastError =
            tostring(toolOrReason)

        GAG2SeedDropSetStatus(
            state.LastError
        )

        return 0,
            state.LastError
    end

    local selectPacket =
        GAG2SeedDropBuildSelectPacket(
            seedName
        )

local statePacket =
    nil

if slotIndex then

    statePacket =
        GAG2SeedDropBuildStatePacket(
            seedName,
            slotIndex
        )
end

    local okSelect, selectReason =
        GAG2SeedDropFire(
            selectPacket,
            "select"
        )

    if okSelect ~= true then

        state.LastError =
            tostring(selectReason)

        GAG2SeedDropSetStatus(
            state.LastError
        )

        return 0,
            state.LastError
    end

    task.wait(
        0.06
    )

if statePacket then

    local okState, stateReason =
        GAG2SeedDropFire(
            statePacket,
            "state"
        )

    if okState ~= true then

        state.LastError =
            tostring(stateReason)

        GAG2SeedDropSetStatus(
            state.LastError
        )

        return 0,
            state.LastError
    end
end

task.wait(
    0.04
)

    local fired =
        0

    for burstIndex = 1, burstCount do

        local dropPosition =
            GAG2SeedDropGetPosition(
                burstIndex
            )

        local realDropPacket =
            GAG2SeedDropBuildRealDropPacket(
                dropPosition
            )

        local okDrop, dropReason =
            GAG2SeedDropFire(
                realDropPacket,
                "real_drop"
            )

        if okDrop ~= true then

            state.LastError =
                tostring(dropReason)

            GAG2SeedDropSetStatus(
                state.LastError
            )

            break
        end

        fired = fired + 1

        if type(GAG2DropPickupMarkSelfDrop) == "function" then

            GAG2DropPickupMarkSelfDrop(
                "auto drop seed"
            )
        end

        state.LastSeed =
            seedName

        state.LastPosition =
            dropPosition

        if burstIndex % 10 == 0 then

            task.wait()
        end
    end

    state.LastError =
        ""

    GAG2SeedDropSetStatus(
        "Fired "
        .. tostring(fired)
        .. " drop packet(s) for "
        .. tostring(seedName)
        .. "."
    )

    return fired,
        "ok"
end

function GAG2SeedDropStartLoop()

    local state =
        GAG2_AUTO_DROP_SEED_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        state.Dropped =
            0

        GAG2SeedDropSetStatus(
            "Starting..."
        )

        while state.Enabled == true do

            local targetAmount =
                math.max(
                    1,
                    math.floor(
                        tonumber(state.Amount)
                        or 1
                    )
                )

            if state.Dropped >= targetAmount then

                GAG2SeedDropSetStatus(
                    "Target reached. Toggle stays ON. Waiting for picked-up seed cycle..."
                )

                while state.Enabled == true
                and GAG2SeedDropFindTool(state.Seed) ~= nil do

                    task.wait(
                        0.25
                    )
                end

                if state.Enabled ~= true then
                    break
                end

                GAG2SeedDropSetStatus(
                    "Seed left inventory. Waiting for it to return..."
                )

                while state.Enabled == true
                and GAG2SeedDropFindTool(state.Seed) == nil do

                    task.wait(
                        0.25
                    )
                end

                if state.Enabled ~= true then
                    break
                end

                state.Dropped =
                    0

                GAG2SeedDropSetStatus(
                    "Seed returned. Dropping again..."
                )

                task.wait(
                    0.08
                )

            else

                local remaining =
                    targetAmount - state.Dropped

                local burst =
                    math.min(
                        remaining,
                        math.clamp(
                            math.floor(
                                tonumber(state.Burst)
                                or 1
                            ),
                            1,
                            250
                        )
                    )

                local fired, reason =
                    GAG2SeedDropOnce(
                        state.Seed,
                        burst
                    )

                fired =
                    tonumber(fired)
                    or 0

                if fired <= 0 then

                    GAG2SeedDropSetStatus(
                        "Waiting: "
                        .. tostring(reason)
                    )

                    task.wait(
                        0.75
                    )

                else

                    state.Dropped = state.Dropped + fired

                    GAG2SeedDropSetStatus(
                        "Dropped "
                        .. tostring(state.Dropped)
                        .. "/"
                        .. tostring(targetAmount)
                        .. ". Toggle remains ON."
                    )

                    local delaySeconds =
                        tonumber(state.Delay)
                        or 0.35

                    if delaySeconds > 0 then

                        task.wait(
                            delaySeconds
                        )

                    else

                        task.wait()
                    end
                end
            end
        end

        state.Running =
            false

        GAG2SeedDropSetStatus(
            "Stopped."
        )
    end)
end

function GAG2SeedDropSetEnabled(value)

    local state =
        GAG2_AUTO_DROP_SEED_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        if ConfigState.Loading ~= true then

            GAG2SeedDropStartLoop()
        end

    else

        GAG2SeedDropSetStatus(
            "Stopping..."
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreSeedDropState()

    task.defer(function()

        local state =
            GAG2_AUTO_DROP_SEED_STATE

        if Options.HolyGAG2SeedDropSeed then

            GAG2SeedDropSetSeed(
                Options.HolyGAG2SeedDropSeed.Value
            )
        end

        if Options.HolyGAG2SeedDropAmount then

            GAG2SeedDropSetAmount(
                Options.HolyGAG2SeedDropAmount.Value
            )
        end

        if Options.HolyGAG2SeedDropDelay then

            GAG2SeedDropSetDelay(
                Options.HolyGAG2SeedDropDelay.Value
            )
        end

        if Options.HolyGAG2SeedDropBurst then

            GAG2SeedDropSetBurst(
                Options.HolyGAG2SeedDropBurst.Value
            )
        end

        if Toggles.HolyGAG2AutoDropSeed then

            state.Enabled =
                Toggles.HolyGAG2AutoDropSeed.Value == true
        end

        GAG2SeedDropSetStatus(
            "Ready."
        )

        if state.Enabled == true then

            GAG2SeedDropStartLoop()
        end
    end)
end

--==================================================
-- [4.591] EXPERIMENT AUTO PICKUP DROPS
-- Prompt-only pickup for workspace.DroppedItems.
-- No packet replay. No remotes. No console spam.
--==================================================

GAG2_DROP_PICKUP_MODES =
    GAG2_DROP_PICKUP_MODES
    or {
        "All",
        "Seeds Only",
        "Pets Only",
        "Custom Contains",
    }

GAG2_DROP_PICKUP_STATE =
    GAG2_DROP_PICKUP_STATE
    or {
        Enabled = true,
        Running = false,

        Radius = 80,
        Delay = 0.15,
        Mode = "All",
        CustomText = "",

        TeleportPickup = true,
        ReturnAfterTeleportPickup = true,
        TeleportScanRadius = 999999,
        TeleportYOffset = 4.75,

        IgnoreOwnDropSeconds = 1.75,
        SelfDropIgnoreUntil = 0,
        LastSelfDropReason = "",

        Found = 0,
        Picked = 0,
        LastPicked = "",
        LastStatus = "Ready.",
        LastError = "",

        Recent = {},
    }

function GAG2DropPickupClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2DropPickupSetStatus(text)

    local state =
        GAG2_DROP_PICKUP_STATE

    state.LastStatus =
        tostring(text or "Ready.")

    if Options.HolyGAG2DropPickupStatus then

        Options.HolyGAG2DropPickupStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Auto Pickup Drops</b></font>'
            .. '\nState: '
            .. (
                state.Enabled == true
                and "ON"
                or "OFF"
            )
            .. ' | Running: '
            .. tostring(state.Running == true)
            .. '\nRadius: '
            .. tostring(state.Radius or 80)
            .. ' | Delay: '
            .. tostring(state.Delay or 0.15)
            .. 's'
            .. '\nMode: '
            .. tostring(state.Mode or "All")
            .. ' | TP: '
            .. (
                state.TeleportPickup == true
                and "ON"
                or "OFF"
            )
            .. ' | Picked: '
            .. tostring(state.Picked or 0)
            .. ' | Found: '
            .. tostring(state.Found or 0)
            .. '\nLast: '
            .. tostring(state.LastPicked ~= "" and state.LastPicked or state.LastStatus)
        )
    end
end

function GAG2DropPickupGetRoot()

    return workspace:FindFirstChild(
        "DroppedItems"
    )
end

function GAG2DropPickupGetCharacterRoot()

    if type(SniperGetCharacterRoot) == "function" then

        local character, root =
            SniperGetCharacterRoot()

        if character
        and root then

            return character,
                root
        end
    end

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if character
    and root
    and root:IsA("BasePart") then

        return character,
            root
    end

    return nil,
        nil
end

function GAG2DropPickupGetPosition(instance)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    if instance:IsA("BasePart") then

        return instance.Position
    end

    if instance:IsA("Model") then

        local ok, cframe =
            pcall(function()

                return instance:GetBoundingBox()
            end)

        if ok == true
        and typeof(cframe) == "CFrame" then

            return cframe.Position
        end
    end

    local scanned =
        0

    for _, descendant in ipairs(instance:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 160 then
            break
        end

        if descendant:IsA("BasePart") then

            return descendant.Position
        end
    end

    return nil
end

function GAG2DropPickupPivotTo(targetCFrame)

    if typeof(targetCFrame) ~= "CFrame" then
        return false, "bad cframe"
    end

    local character, rootPart =
        GAG2DropPickupGetCharacterRoot()

    if not character
    or not rootPart then

        return false,
            "missing character"
    end

    local oldCFrame =
        rootPart.CFrame

    local ok, err =
        pcall(function()

            character:PivotTo(
                targetCFrame
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                rootPart.CFrame =
                    targetCFrame
            end)
    end

    if ok ~= true then
        return false, tostring(err)
    end

    if type(SniperStopCharacterMotion) == "function" then

        SniperStopCharacterMotion(
            rootPart
        )

    else

        pcall(function()

            rootPart.AssemblyLinearVelocity =
                Vector3.zero

            rootPart.AssemblyAngularVelocity =
                Vector3.zero
        end)
    end

    return true,
        oldCFrame
end

function GAG2DropPickupBuildTeleportCFrame(itemPosition)

    if typeof(itemPosition) ~= "Vector3" then
        return nil
    end

    local state =
        GAG2_DROP_PICKUP_STATE

    local yOffset =
        math.clamp(
            tonumber(state.TeleportYOffset)
            or 4.75,
            2.5,
            12
        )

    local targetPosition =
        itemPosition
        + Vector3.new(
            0,
            yOffset,
            0
        )

    return CFrame.new(
        targetPosition,
        itemPosition
    )
end

function GAG2DropPickupTeleportClose(itemPosition)

    local targetCFrame =
        GAG2DropPickupBuildTeleportCFrame(
            itemPosition
        )

    if typeof(targetCFrame) ~= "CFrame" then
        return false, "bad target"
    end

    return GAG2DropPickupPivotTo(
        targetCFrame
    )
end

function GAG2DropPickupReturnFromTeleport(oldCFrame)

    local state =
        GAG2_DROP_PICKUP_STATE

    if state.ReturnAfterTeleportPickup ~= true then
        return false
    end

    if typeof(oldCFrame) ~= "CFrame" then
        return false
    end

    return GAG2DropPickupPivotTo(
        oldCFrame
    )
end

function GAG2DropPickupFindPrompt(item)

    if typeof(item) ~= "Instance" then
        return nil
    end

    if item:IsA("ProximityPrompt")
    and item.Enabled == true then

        return item
    end

    local scanned =
        0

    for _, descendant in ipairs(item:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 220 then
            break
        end

        if descendant:IsA("ProximityPrompt")
        and descendant.Enabled == true then

            return descendant
        end
    end

    return nil
end

function GAG2DropPickupReadDescriptor(item, prompt)

    local parts =
        {}

    local function add(value)

        value =
            GAG2DropPickupClean(value)

        if value ~= "" then

            table.insert(
                parts,
                value
            )
        end
    end

    if typeof(item) == "Instance" then

        add(item.Name)

        local ok, attrs =
            pcall(function()

                return item:GetAttributes()
            end)

        if ok == true
        and type(attrs) == "table" then

            for key, value in pairs(attrs) do

                add(key)
                add(value)
            end
        end
    end

    if typeof(prompt) == "Instance" then

        add(prompt.Name)

        pcall(function()
            add(prompt.ActionText)
            add(prompt.ObjectText)
        end)
    end

    if typeof(item) == "Instance" then

        local scanned =
            0

        for _, descendant in ipairs(item:GetDescendants()) do

            scanned = scanned + 1

            if scanned > 180 then
                break
            end

            add(descendant.Name)

            if descendant:IsA("TextLabel")
            or descendant:IsA("TextButton")
            or descendant:IsA("TextBox") then

                pcall(function()

                    add(descendant.Text)
                end)
            end

            if descendant:IsA("ProximityPrompt") then

                pcall(function()

                    add(descendant.ActionText)
                    add(descendant.ObjectText)
                end)
            end

            local ok, attrs =
                pcall(function()

                    return descendant:GetAttributes()
                end)

            if ok == true
            and type(attrs) == "table" then

                for key, value in pairs(attrs) do

                    add(key)
                    add(value)
                end
            end
        end
    end

    return table.concat(
        parts,
        " "
    )
end

function GAG2DropPickupSeedNameMatches(descriptor)

    descriptor =
        tostring(descriptor or ""):lower()

    if descriptor:find("seed", 1, true)
    or descriptor:find("seeds", 1, true) then

        return true
    end

    if type(GAG2SeedDropGetAllSeedValues) ~= "function" then
        return false
    end

    local values =
        GAG2SeedDropGetAllSeedValues()

    if type(values) ~= "table" then
        return false
    end

    for _, seedName in ipairs(values) do

        seedName =
            GAG2DropPickupClean(seedName)

        local beforePipe =
            seedName:match("^(.-)%s+|%s+")

        if beforePipe
        and GAG2DropPickupClean(beforePipe) ~= "" then

            seedName =
                GAG2DropPickupClean(beforePipe)
        end

        if seedName ~= ""
        and descriptor:find(seedName:lower(), 1, true) then

            return true
        end
    end

    return false
end

function GAG2DropPickupMatchesMode(item, prompt)

    local state =
        GAG2_DROP_PICKUP_STATE

    local mode =
        GAG2DropPickupClean(
            state.Mode
        )

    if mode == ""
    or mode == "All" then

        return true
    end

    local descriptor =
        GAG2DropPickupReadDescriptor(
            item,
            prompt
        )

    local lower =
        descriptor:lower()

    if mode == "Seeds Only" then

        return GAG2DropPickupSeedNameMatches(
            descriptor
        )
    end

    if mode == "Pets Only" then

        return lower:find("pet", 1, true) ~= nil
            or lower:find("pets", 1, true) ~= nil
            or lower:find("animal", 1, true) ~= nil
    end

    if mode == "Custom Contains" then

        local custom =
            GAG2DropPickupClean(
                state.CustomText
            ):lower()

        if custom == "" then
            return false
        end

        return lower:find(
            custom,
            1,
            true
        ) ~= nil
    end

    return true
end

function GAG2DropPickupCleanupRecent()

    local state =
        GAG2_DROP_PICKUP_STATE

    local now =
        os.clock()

    for key, seenAt in pairs(state.Recent) do

        if now - tonumber(seenAt or 0) > 6 then

            state.Recent[key] =
                nil
        end
    end
end

function GAG2DropPickupPromptKey(item, prompt)

    if typeof(prompt) == "Instance" then

        return PathOf(prompt)
    end

    if typeof(item) == "Instance" then

        return PathOf(item)
    end

    return tostring(item)
end

function GAG2DropPickupCanFire(item, prompt, rootPart)

    local state =
        GAG2_DROP_PICKUP_STATE

    if state.Enabled ~= true then
        return false, "disabled"
    end

    if os.clock() < tonumber(state.SelfDropIgnoreUntil or 0) then
        return false, "self drop pause"
    end

    if typeof(item) ~= "Instance"
    or item.Parent == nil then

        return false, "bad item"
    end

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true
    or prompt.Enabled ~= true then

        return false, "bad prompt"
    end

    if typeof(rootPart) ~= "Instance"
    or rootPart:IsA("BasePart") ~= true then

        return false, "missing root"
    end

    if GAG2DropPickupMatchesMode(
        item,
        prompt
    ) ~= true then

        return false, "filtered"
    end

    local key =
        GAG2DropPickupPromptKey(
            item,
            prompt
        )

    local last =
        tonumber(state.Recent[key])
        or 0

    if os.clock() - last < 0.65 then

        return false, "recent"
    end

    local position =
        GAG2DropPickupGetPosition(
            item
        )

    if typeof(position) ~= "Vector3" then

        return false, "no position"
    end

    local pickupRadius =
        math.clamp(
            tonumber(state.Radius)
            or 80,
            5,
            1000
        )

    local distance =
        (rootPart.Position - position).Magnitude

    if distance > pickupRadius then

        if state.TeleportPickup ~= true then

            return false,
                "too far"
        end

        return true,
            key,
            true,
            position
    end

    return true,
        key,
        false,
        position
end


function GAG2DropPickupFirePrompt(item, prompt, key, shouldTeleport, itemPosition)

    local state =
        GAG2_DROP_PICKUP_STATE

    if type(fireproximityprompt) ~= "function" then

        state.LastError =
            "fireproximityprompt unsupported"

        return false,
            state.LastError
    end

    local oldCFrame =
        nil

    local didTeleport =
        false

    if shouldTeleport == true then

        local moved, result =
            GAG2DropPickupTeleportClose(
                itemPosition
            )

        if moved ~= true then

            state.LastError =
                "tp failed: "
                .. tostring(result)

            return false,
                state.LastError
        end

        oldCFrame =
            result

        didTeleport =
            true

        task.wait(
            0.06
        )
    end

    local ok, err =
        pcall(function()

            fireproximityprompt(
                prompt
            )
        end)

    if ok ~= true then

        state.LastError =
            tostring(err)

        if didTeleport == true then

            task.wait(
                0.04
            )

            GAG2DropPickupReturnFromTeleport(
                oldCFrame
            )
        end

        return false,
            state.LastError
    end

    state.Recent[key] =
        os.clock()

    state.Picked =
        tonumber(state.Picked)
        or 0

    state.Picked = state.Picked + 1

    state.LastPicked =
        tostring(item.Name)

    state.LastError =
        ""

    if didTeleport == true then

        task.wait(
            0.05
        )

        GAG2DropPickupReturnFromTeleport(
            oldCFrame
        )
    end

    return true,
        "picked"
end

function GAG2DropPickupScanOnce(reason)

    local state =
        GAG2_DROP_PICKUP_STATE

    GAG2DropPickupCleanupRecent()

    if state.Enabled ~= true
    and reason ~= "manual" then

        GAG2DropPickupSetStatus(
            "Disabled."
        )

        return 0
    end

    if os.clock() < tonumber(state.SelfDropIgnoreUntil or 0) then

        GAG2DropPickupSetStatus(
            "Paused briefly after own drop."
        )

        return 0
    end

    local droppedRoot =
        GAG2DropPickupGetRoot()

    if not droppedRoot then

        state.Found =
            0

        GAG2DropPickupSetStatus(
            "workspace.DroppedItems missing."
        )

        return 0
    end

    local _, rootPart =
        GAG2DropPickupGetCharacterRoot()

    if not rootPart then

        GAG2DropPickupSetStatus(
            "Waiting for character."
        )

        return 0
    end

    local found =
        0

    local fired =
        0

    for _, item in ipairs(droppedRoot:GetChildren()) do

        local prompt =
            GAG2DropPickupFindPrompt(
                item
            )

        if prompt then

            local allowed, key, shouldTeleport, itemPosition =
                GAG2DropPickupCanFire(
                    item,
                    prompt,
                    rootPart
                )

            if allowed == true then

                found = found + 1

                local ok =
                    GAG2DropPickupFirePrompt(
                        item,
                        prompt,
                        key,
                        shouldTeleport,
                        itemPosition
                    )

                if ok == true then

                    fired = fired + 1
                end

                if fired % 10 == 0 then
                    task.wait()
                end
            end
        end
    end

    state.Found =
        found

    if fired > 0 then

        GAG2DropPickupSetStatus(
            "Picked "
            .. tostring(fired)
            .. " drop(s)."
        )

    else

        GAG2DropPickupSetStatus(
            "Watching for drops."
        )
    end

    return fired
end


function GAG2DropPickupStartLoop()

    local state =
        GAG2_DROP_PICKUP_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        GAG2DropPickupSetStatus(
            "Starting..."
        )

        while state.Enabled == true do

            GAG2DropPickupScanOnce(
                "loop"
            )

            local delaySeconds =
                math.clamp(
                    tonumber(state.Delay)
                    or 0.15,
                    0.03,
                    5
                )

            task.wait(
                delaySeconds
            )
        end

        state.Running =
            false

        GAG2DropPickupSetStatus(
            "Stopped."
        )
    end)
end

function GAG2DropPickupSetEnabled(value, skipDirty)

    local state =
        GAG2_DROP_PICKUP_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        if ConfigState.Loading ~= true then

            GAG2DropPickupStartLoop()
        end

    else

        GAG2DropPickupSetStatus(
            "Stopping..."
        )
    end

    if skipDirty ~= true then

        MarkConfigDirty()
    end
end

function GAG2DropPickupSetRadius(value)

    GAG2_DROP_PICKUP_STATE.Radius =
        math.clamp(
            tonumber(value)
            or 80,
            5,
            1000
        )

    GAG2DropPickupSetStatus(
        "Radius set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetDelay(value)

    GAG2_DROP_PICKUP_STATE.Delay =
        math.clamp(
            tonumber(value)
            or 0.15,
            0.03,
            5
        )

    GAG2DropPickupSetStatus(
        "Delay set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetMode(value)

    value =
        GAG2DropPickupClean(value)

    if table.find(
        GAG2_DROP_PICKUP_MODES,
        value
    ) == nil then

        value =
            "All"
    end

    GAG2_DROP_PICKUP_STATE.Mode =
        value

    GAG2DropPickupSetStatus(
        "Mode set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetCustomText(value)

    GAG2_DROP_PICKUP_STATE.CustomText =
        GAG2DropPickupClean(
            value
        )

    GAG2DropPickupSetStatus(
        "Custom filter set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetTeleportPickup(value)

    GAG2_DROP_PICKUP_STATE.TeleportPickup =
        value == true

    GAG2DropPickupSetStatus(
        "TP pickup "
        .. (
            value == true
            and "enabled."
            or "disabled."
        )
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetReturnAfterTeleport(value)

    GAG2_DROP_PICKUP_STATE.ReturnAfterTeleportPickup =
        value == true

    GAG2DropPickupSetStatus(
        "Return after TP "
        .. (
            value == true
            and "enabled."
            or "disabled."
        )
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetTeleportScanRadius(value)

    GAG2_DROP_PICKUP_STATE.TeleportScanRadius =
        math.clamp(
            tonumber(value)
            or 650,
            5,
            3000
        )

    GAG2DropPickupSetStatus(
        "TP scan radius set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetTeleportYOffset(value)

    GAG2_DROP_PICKUP_STATE.TeleportYOffset =
        math.clamp(
            tonumber(value)
            or 4.75,
            2.5,
            12
        )

    GAG2DropPickupSetStatus(
        "TP height set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetIgnoreOwnDropSeconds(value)

    GAG2_DROP_PICKUP_STATE.IgnoreOwnDropSeconds =
        math.clamp(
            tonumber(value)
            or 1.75,
            0,
            10
        )

    GAG2DropPickupSetStatus(
        "Self-drop pause set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupMarkSelfDrop(reason)

    local state =
        GAG2_DROP_PICKUP_STATE

    local seconds =
        math.clamp(
            tonumber(state.IgnoreOwnDropSeconds)
            or 1.75,
            0,
            10
        )

    if seconds <= 0 then
        return
    end

    state.SelfDropIgnoreUntil =
        math.max(
            tonumber(state.SelfDropIgnoreUntil)
            or 0,
            os.clock() + seconds
        )

    state.LastSelfDropReason =
        tostring(reason or "own drop")
end

function GAG2RestoreDropPickupState()

    task.defer(function()

        local state =
            GAG2_DROP_PICKUP_STATE

        if Options.HolyGAG2PickupRadius then

            state.Radius =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupRadius.Value)
                    or state.Radius
                    or 80,
                    5,
                    1000
                )
        end

        if Options.HolyGAG2PickupDelay then

            state.Delay =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupDelay.Value)
                    or state.Delay
                    or 0.15,
                    0.03,
                    5
                )
        end

        if Options.HolyGAG2PickupMode then

            local mode =
                GAG2DropPickupClean(
                    Options.HolyGAG2PickupMode.Value
                )

            if table.find(
                GAG2_DROP_PICKUP_MODES,
                mode
            ) ~= nil then

                state.Mode =
                    mode
            end
        end

        if Options.HolyGAG2PickupCustomText then

            state.CustomText =
                GAG2DropPickupClean(
                    Options.HolyGAG2PickupCustomText.Value
                )
        end

        if Toggles.HolyGAG2PickupTeleport then

            state.TeleportPickup =
                Toggles.HolyGAG2PickupTeleport.Value == true
        end

        if Toggles.HolyGAG2PickupReturnAfterTeleport then

            state.ReturnAfterTeleportPickup =
                Toggles.HolyGAG2PickupReturnAfterTeleport.Value == true
        end

        if Options.HolyGAG2PickupTeleportScanRadius then

            state.TeleportScanRadius =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupTeleportScanRadius.Value)
                    or state.TeleportScanRadius
                    or 650,
                    5,
                    3000
                )
        end

        if Options.HolyGAG2PickupTeleportYOffset then

            state.TeleportYOffset =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupTeleportYOffset.Value)
                    or state.TeleportYOffset
                    or 4.75,
                    2.5,
                    12
                )
        end

        if Options.HolyGAG2PickupIgnoreOwnDropSeconds then

            state.IgnoreOwnDropSeconds =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupIgnoreOwnDropSeconds.Value)
                    or state.IgnoreOwnDropSeconds
                    or 1.75,
                    0,
                    10
                )
        end

        local enabled =
            true

        if Toggles.HolyGAG2AutoPickupDrops then

            enabled =
                Toggles.HolyGAG2AutoPickupDrops.Value == true
        end

        state.Enabled =
            enabled

        GAG2DropPickupSetStatus(
            "Ready."
        )

        if state.Enabled == true then

            GAG2DropPickupStartLoop()
        end
    end)
end


--==================================================
-- [4.595] HOME AUTO HOP UNTIL SERVER VERSION
-- Reads Settings.Frame.Header.VersionLabel.Text, then hops until target version.
--==================================================

GAG2_VERSION_HOP_STATE =
    GAG2_VERSION_HOP_STATE
    or {
        Enabled = false,
        Running = false,

        TargetVersion = "v88",
        CurrentVersion = "unknown",
        HopDelay = 2,

        LastStatus = "Idle.",
        LastError = "",
        LastCheckAt = 0,
        LastHopAt = 0,
    }

function GAG2VersionHopClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2VersionHopNormalizeVersion(value)

    value =
        GAG2VersionHopClean(value)
            :lower()
            :gsub("%s+", "")

    if value == "" then
        return ""
    end

    local number =
        value:match("^v(%d+)$")
        or value:match("^(%d+)$")
        or value:match("v(%d+)")
        or value:match("(%d+)")

    if not number then
        return ""
    end

    return "v" .. tostring(number)
end

function GAG2VersionHopGetLabelExact()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    local settingsGui =
        playerGui
        and playerGui:FindFirstChild("Settings")

    local frame =
        settingsGui
        and settingsGui:FindFirstChild("Frame")

    local header =
        frame
        and frame:FindFirstChild("Header")

    local versionLabel =
        header
        and header:FindFirstChild("VersionLabel")

    if versionLabel
    and (
        versionLabel:IsA("TextLabel")
        or versionLabel:IsA("TextButton")
        or versionLabel:IsA("TextBox")
    ) then

        return versionLabel
    end

    return nil
end

function GAG2VersionHopReadCurrentVersion()

    local label =
        GAG2VersionHopGetLabelExact()

    if label then

        local ok, text =
            pcall(function()

                return label.Text
            end)

        local version =
            ok == true
            and GAG2VersionHopNormalizeVersion(text)
            or ""

        if version ~= "" then

            GAG2_VERSION_HOP_STATE.CurrentVersion =
                version

            return version,
                "exact"
        end
    end

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then

        return "",
            "PlayerGui missing"
    end

    local scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 10000 then
            break
        end

        if descendant.Name == "VersionLabel"
        and (
            descendant:IsA("TextLabel")
            or descendant:IsA("TextButton")
            or descendant:IsA("TextBox")
        ) then

            local ok, text =
                pcall(function()

                    return descendant.Text
                end)

            local version =
                ok == true
                and GAG2VersionHopNormalizeVersion(text)
                or ""

            if version ~= "" then

                GAG2_VERSION_HOP_STATE.CurrentVersion =
                    version

                return version,
                    "VersionLabel scan"
            end
        end
    end

    scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned = scanned + 1

        if scanned > 10000 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, text =
                pcall(function()

                    return descendant.Text
                end)

            local version =
                ok == true
                and GAG2VersionHopNormalizeVersion(text)
                or ""

            if version ~= "" then

                GAG2_VERSION_HOP_STATE.CurrentVersion =
                    version

                return version,
                    "text scan"
            end
        end
    end

    return "",
        "version label not found"
end

function GAG2VersionHopGetTarget()

    local state =
        GAG2_VERSION_HOP_STATE

    local target =
        GAG2VersionHopNormalizeVersion(
            state.TargetVersion
        )

    if target == "" then
        target = "v88"
    end

    state.TargetVersion =
        target

    return target
end

function GAG2VersionHopGetDelay()

    local state =
        GAG2_VERSION_HOP_STATE

    local delaySeconds =
        tonumber(state.HopDelay)
        or 2

    delaySeconds =
        math.clamp(
            delaySeconds,
            1,
            60
        )

    state.HopDelay =
        delaySeconds

    return delaySeconds
end

function GAG2VersionHopBuildHomeText()

    local state =
        GAG2_VERSION_HOP_STATE

    local current =
        GAG2VersionHopNormalizeVersion(
            state.CurrentVersion
        )

    if current == "" then

        local readVersion =
            GAG2VersionHopReadCurrentVersion()

        current =
            GAG2VersionHopNormalizeVersion(
                readVersion
            )
    end

    if current == "" then
        return "Server loading..."
    end

    return "Server "
        .. tostring(current)
end

function GAG2VersionHopBuildHomeHeaderText()

    local text =
        GAG2VersionHopBuildHomeText()

    if text == "" then
        text =
            "Server loading..."
    end

    return text
end

function GAG2VersionHopTrySetHomeDescriptionMethod(text)

    local tab =
        GAG2_HOME_TAB_CONTROL

    if type(tab) ~= "table" then
        return false
    end

    local methodNames = {
        "SetDescription",
        "SetSubtitle",
        "SetSubTitle",
        "SetDesc",
    }

    for _, methodName in ipairs(methodNames) do

        local method =
            tab[methodName]

        if type(method) == "function" then

            local ok =
                pcall(function()

                    method(
                        tab,
                        text
                    )
                end)

            if ok == true then
                return true
            end
        end
    end

    return false
end

function GAG2VersionHopRefreshHomeHeader()

    local text =
        GAG2VersionHopBuildHomeHeaderText()

    if GAG2VersionHopTrySetHomeDescriptionMethod(text) == true then
        return
    end

    local roots =
        {}

    if CoreGui then

        table.insert(
            roots,
            CoreGui
        )
    end

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if playerGui then

        table.insert(
            roots,
            playerGui
        )
    end

    local replacements = {
        ["Main controls."] = true,
        ["Server loading..."] = true,
    }

    for _, root in ipairs(roots) do

        local scanned =
            0

        for _, descendant in ipairs(root:GetDescendants()) do

            scanned = scanned + 1

            if scanned > 25000 then
                break
            end

            if descendant:IsA("TextLabel")
            or descendant:IsA("TextButton")
            or descendant:IsA("TextBox") then

                local ok, currentText =
                    pcall(function()

                        return descendant.Text
                    end)

                currentText =
                    ok == true
                    and tostring(currentText or "")
                    or ""

                local lowerText =
                    currentText:lower()

                if replacements[currentText] == true
                or lowerText:match("^server%s+v%d+$") then

                    pcall(function()

                        descendant.Text =
                            text
                    end)

                    return
                end
            end
        end
    end
end

function GAG2VersionHopStartHeaderLoop()

    local state =
        GAG2_VERSION_HOP_STATE

    if state.HeaderLoopRunning == true then
        return
    end

    state.HeaderLoopRunning =
        true

    task.spawn(function()

        local started =
            os.clock()

        while os.clock() - started < 20 do

            GAG2VersionHopReadCurrentVersion()
            GAG2VersionHopRefreshHomeHeader()

            task.wait(
                1
            )
        end

        state.HeaderLoopRunning =
            false
    end)
end

function GAG2VersionHopRefreshHome()

    if type(RefreshServerInfo) == "function" then

        RefreshServerInfo()
    end

    GAG2VersionHopRefreshHomeHeader()
end

function GAG2VersionHopSetStatus(text)

    local state =
        GAG2_VERSION_HOP_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    GAG2VersionHopRefreshHome()

    print(
        "[HOLY VERSION HOP]",
        state.LastStatus
    )
end

function GAG2VersionHopSetTarget(value)

    local state =
        GAG2_VERSION_HOP_STATE

    local version =
        GAG2VersionHopNormalizeVersion(value)

    if version == "" then
        version = "v88"
    end

    state.TargetVersion =
        version

    GAG2VersionHopSetStatus(
        "Target set to "
        .. tostring(version)
        .. "."
    )

    MarkConfigDirty()
end

function GAG2VersionHopSetDelay(value)

    local state =
        GAG2_VERSION_HOP_STATE

    state.HopDelay =
        math.clamp(
            tonumber(value)
            or 2,
            1,
            60
        )

    GAG2VersionHopSetStatus(
        "Hop delay set to "
        .. tostring(state.HopDelay)
        .. "s."
    )

    MarkConfigDirty()
end

function GAG2VersionHopStop(reason)

    local state =
        GAG2_VERSION_HOP_STATE

    state.Enabled =
        false

    state.Running =
        false

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    GAG2VersionHopSetStatus(
        tostring(reason or "Stopped.")
    )

    MarkConfigDirty()
end

function GAG2VersionHopTurnToggleOff()

    if Toggles.HolyGAG2AutoHopUntilVersion
    and type(Toggles.HolyGAG2AutoHopUntilVersion.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2AutoHopUntilVersion:SetValue(
                false
            )
        end)
    end
end

function GAG2VersionHopQueueHop()

    local state =
        GAG2_VERSION_HOP_STATE

    state.LastHopAt =
        os.clock()

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    if type(HopServerOnce) ~= "function" then

        GAG2VersionHopSetStatus(
            "HopServerOnce missing."
        )

        return false
    end

    GAG2VersionHopSetStatus(
        "Wrong version. Hopping now..."
    )

    return HopServerOnce()
end

function GAG2VersionHopStartLoop()

    local state =
        GAG2_VERSION_HOP_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        task.wait(
            0.75
        )

        while state.Enabled == true do

            local target =
                GAG2VersionHopGetTarget()

            local current =
                ""

            local source =
                ""

            local started =
                os.clock()

            while state.Enabled == true
            and current == ""
            and os.clock() - started < 12 do

                current,
                source =
                    GAG2VersionHopReadCurrentVersion()

                if current == "" then

                    GAG2VersionHopSetStatus(
                        "Waiting for version label..."
                    )

                    task.wait(
                        0.35
                    )
                end
            end

            if state.Enabled ~= true then
                break
            end

            if current == "" then

                GAG2VersionHopSetStatus(
                    "Version missing. Waiting..."
                )

                task.wait(
                    1
                )

                continue
            end

            state.CurrentVersion =
                current

            state.LastCheckAt =
                os.clock()

            if current == target then

                GAG2VersionHopSetStatus(
                    "Found target "
                    .. tostring(target)
                    .. " via "
                    .. tostring(source)
                    .. "."
                )

                state.Enabled =
                    false

                state.Running =
                    false

                GAG2VersionHopTurnToggleOff()

                Notify(
                    "Version Found",
                    "Current server is "
                    .. tostring(current)
                    .. ".",
                    4
                )

                MarkConfigDirty()

                return
            end

            local delaySeconds =
                GAG2VersionHopGetDelay()

            GAG2VersionHopSetStatus(
                "Current "
                .. tostring(current)
                .. " != target "
                .. tostring(target)
                .. ". Hopping in "
                .. tostring(delaySeconds)
                .. "s."
            )

            local waited =
                0

            while state.Enabled == true
            and waited < delaySeconds do

                task.wait(
                    0.1
                )

                waited = waited + 0.1
            end

            if state.Enabled ~= true then
                break
            end

            GAG2VersionHopQueueHop()

            -- Teleport should happen through HopServerOnce.
            -- Stop this local loop so it does not double-hop in the same server.
            break
        end

        state.Running =
            false

        if state.Enabled ~= true then

            GAG2VersionHopRefreshHome()
        end
    end)
end

function GAG2VersionHopSetEnabled(value)

    local state =
        GAG2_VERSION_HOP_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        GAG2VersionHopSetStatus(
            "Checking version..."
        )

        if ConfigState.Loading ~= true then

            GAG2VersionHopStartLoop()
        end

    else

        GAG2VersionHopStop(
            "Stopped."
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreVersionHopState()

    task.defer(function()

        local state =
            GAG2_VERSION_HOP_STATE

        if Options.HolyGAG2VersionHopTarget then

            state.TargetVersion =
                GAG2VersionHopNormalizeVersion(
                    Options.HolyGAG2VersionHopTarget.Value
                )

            if state.TargetVersion == "" then

                state.TargetVersion =
                    "v88"
            end
        end

        if Options.HolyGAG2VersionHopDelay then

            state.HopDelay =
                math.clamp(
                    tonumber(Options.HolyGAG2VersionHopDelay.Value)
                    or 2,
                    1,
                    60
                )
        end

        if Toggles.HolyGAG2AutoHopUntilVersion then

            state.Enabled =
                Toggles.HolyGAG2AutoHopUntilVersion.Value == true
        end

        local current =
            GAG2VersionHopReadCurrentVersion()

        if current ~= "" then

            state.CurrentVersion =
                current
        end

        GAG2VersionHopSetStatus(
            state.Enabled == true
            and "Restored. Checking version..."
            or "Ready."
        )

        GAG2VersionHopStartHeaderLoop()

        if state.Enabled == true then

            GAG2VersionHopStartLoop()
        end
    end)
end

--==================================================
-- [5] WINDOW
--==================================================



local Window =
    Library:CreateWindow({
        Title =
            '<font color="rgb(196,181,253)"><b>HOLY</b></font>',

        Footer =
            "holy",

        ToggleKeybind =
            Enum.KeyCode.LeftAlt,

        Font =
            Enum.Font.Code,

        Center =
            true,

        AutoShow =
            UIState.ShowUIOnLoad == true,

        Size =
            UDim2.fromOffset(780, 540),

        CornerRadius =
            6,

        GlobalSearch =
            true,

        EnableCompacting =
            true,

        EnableSidebarResize =
            true,

        MinSidebarWidth =
            170,
    })

pcall(function()

    Library:SetDPIScale(
        tonumber(UIState.DPIScale)
        or 100
    )
end)

--==================================================
-- [6] TABS
--==================================================

local Tabs = {
    Home =
        Window:AddTab({
            Name = "Home",
            Icon = "home",
            Description = "Server loading...",
        }),

    Server =
        Window:AddTab({
            Name = "Server",
            Icon = "server",
            Description = "Server selection.",
        }),

    Sniper =
        Window:AddTab({
            Name = "Sniper",
            Icon = "crosshair",
            Description = "Wild pet sniper scanner.",
        }),

    Settings =
        Window:AddTab({
            Name = "Settings",
            Icon = "sliders-horizontal",
            Description = "UI settings.",
        }),

    Webhook =
        Window:AddTab({
            Name = "Webhook",
            Icon = "webhook",
            Description = "Webhook alerts and Discord reporting.",
        }),
}

GAG2_HOME_TAB_CONTROL =
    Tabs.Home

if IsHolyGAG2Developer() then

    Tabs.Dev =
        Window:AddTab({
            Name = "Dev",
            Icon = "terminal",
            Description = "Developer tools.",
        })
end

--==================================================
-- [7] GROUPBOXES
--==================================================

local function AddLeftBox(tab, title, icon)

    if tab
    and type(tab.AddLeftCollapsibleGroupbox) == "function" then

        local ok, box =
            pcall(function()

                return tab:AddLeftCollapsibleGroupbox(
                    title,
                    icon,
                    true
                )
            end)

        if ok == true
        and box ~= nil then
            return box
        end

        return tab:AddLeftCollapsibleGroupbox(
            title,
            "settings",
            true
        )
    end

    return tab:AddLeftGroupbox(
        title,
        icon or "settings"
    )
end

local function AddRightBox(tab, title, icon)

    if tab
    and type(tab.AddRightCollapsibleGroupbox) == "function" then

        local ok, box =
            pcall(function()

                return tab:AddRightCollapsibleGroupbox(
                    title,
                    icon,
                    true
                )
            end)

        if ok == true
        and box ~= nil then
            return box
        end

        return tab:AddRightCollapsibleGroupbox(
            title,
            "settings",
            true
        )
    end

    return tab:AddRightGroupbox(
        title,
        icon or "settings"
    )
end

local HomeMainBox =
    AddLeftBox(
        Tabs.Home,
        "Quick Actions",
        "sparkles"
    )

local HomeServerBox =
    AddRightBox(
        Tabs.Home,
        "Live Pets",
        "radar"
    )

local HomeMoonPredictorBox =
    AddRightBox(
        Tabs.Home,
        "Moon Predictor",
        "moon"
    )

local HomeFarmDetailsBox =
    AddRightBox(
        Tabs.Home,
        "Farm Details",
        "sprout"
    )

local ServerMainBox =
    AddLeftBox(
        Tabs.Server,
        "Server Selection",
        "server"
    )

local ServerStatusBox =
    AddRightBox(
        Tabs.Server,
        "Status",
        "activity"
    )



local SniperMainBox =
    AddLeftBox(
        Tabs.Sniper,
        "Wild Pet Sniper",
        "crosshair"
    )

local SniperStatusBox =
    AddRightBox(
        Tabs.Sniper,
        "Sniper Status",
        "radar"
    )

local SettingsUIBox =
    AddLeftBox(
        Tabs.Settings,
        "Interface",
        "sliders-horizontal"
    )

WebhookMainBox =
    AddLeftBox(
        Tabs.Webhook,
        "Webhook Alerts",
        "webhook"
    )

WebhookStatusBox =
    AddRightBox(
        Tabs.Webhook,
        "Webhook Status",
        "activity"
    )

local DevToolsBox =
    nil

local DevInfoBox =
    nil

if Tabs.Dev then

    DevToolsBox =
        AddLeftBox(
            Tabs.Dev,
            "Tools",
            "terminal"
        )

    DevInfoBox =
        AddRightBox(
            Tabs.Dev,
            "Info",
            "info"
        )
end

--==================================================
-- [7.5] NEW TAB PLACEHOLDERS
--==================================================

if WebhookMainBox then

    WebhookMainBox:AddLabel("HolyGAG2WebhookInfo", {
        Text =
            '<font color="rgb(196,181,253)"><b>Webhook</b></font>'
            .. '\nDiscord alert controls will be moved here.',
        DoesWrap = true,
    })
end

if WebhookStatusBox then

    WebhookStatusBox:AddLabel("HolyGAG2WebhookStatus", {
        Text =
            '<font color="rgb(196,181,253)"><b>Status</b></font>'
            .. '\nReady.',
        DoesWrap = true,
    })
end

--==================================================
-- [8] HOME TAB
--==================================================

HomeMainBox:AddButton({
    Text = "Rejoin",
    Tooltip = "Rejoin current server.",
    Func = function()

        RejoinServer()
    end,
}):AddButton({
    Text = "Server Hop",
    Tooltip = "Hop once to another public server.",
    Func = function()

        HopServerOnce()
    end,
})

HomeMainBox:AddButton({
    Text = "Copy Current Code",
    Tooltip = "Copy this server's current placeId:JobId.",
    Func = function()

        GAG2CopyCurrentJoinCode()
    end,
}):AddButton({
    Text = "Copy Raw JobId",
    Tooltip = "Copy only the current server JobId.",
    Func = function()

        if CopyText(game.JobId) == true then

            Notify(
                "Copied",
                "Raw JobId copied.",
                3
            )

        else

            Notify(
                "Clipboard",
                "Clipboard unsupported.",
                4
            )
        end
    end,
})

HomeMainBox:AddDivider()

if type(HomeMainBox.AddInput) == "function" then

    local VersionHopTargetInput =
        HomeMainBox:AddInput(
            "HolyGAG2VersionHopTarget",
            {
                Text = "Target Server Version",
                Default = "v88",
                Placeholder = "v88",
                Numeric = false,
                Finished = true,
                ClearTextOnFocus = false,
                Tooltip = "Accepts 88, v88, or V88. Exact normalized match only.",
            }
        )

    if VersionHopTargetInput
    and type(VersionHopTargetInput.OnChanged) == "function" then

        VersionHopTargetInput:OnChanged(function(value)

            GAG2VersionHopSetTarget(
                value
            )
        end)
    end

    local VersionHopDelayInput =
        HomeMainBox:AddInput(
            "HolyGAG2VersionHopDelay",
            {
                Text = "Hop Delay",
                Default = "2",
                Placeholder = "2",
                Numeric = false,
                Finished = true,
                ClearTextOnFocus = false,
                Tooltip = "Seconds to wait before hopping when current version does not match target. Min 1.",
            }
        )

    if VersionHopDelayInput
    and type(VersionHopDelayInput.OnChanged) == "function" then

        VersionHopDelayInput:OnChanged(function(value)

            GAG2VersionHopSetDelay(
                value
            )
        end)
    end
end

HomeMainBox:AddToggle("HolyGAG2AutoHopUntilVersion", {
    Text = "Auto Hop Until Server Version",
    Default = false,
    Tooltip = "Reads the current server version from Settings and hops until it matches the target.",
    Callback = function(value)

        GAG2VersionHopSetEnabled(
            value == true
        )
    end,
})

GAG2_MANUAL_JOIN_HUD_TOGGLE =
    HomeMainBox:AddToggle("HolyGAG2ManualJoinHud", {
        Text = "Pop Out Join HUD",
        Default = false,
        Tooltip = "Show a small draggable server join HUD.",
        Callback = function(value)

            GAG2SetManualJoinHudEnabled(
                value == true
            )
        end,
    })

HomeLivePetsList =
    HomeServerBox:AddPetMarketList(
        "HolyGAG2HomeLivePets",
        {
            Rows = 8,
            RowHeight = 38,
            EmptyText = "No active pets.",
            Summary =
                '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
                .. '\nLoading...',

            Callback = function(rowIndex, rowData)

                GAG2HomeManualBuyPetIndex(
                    rowIndex
                )
            end,
        }
    )

GAG2_MOON_PREDICTOR_LABEL =
    HomeMoonPredictorBox:AddLabel("HolyGAG2MoonPredictor", {
        Text =
            '<font color="rgb(226,232,240)"><b>Current:</b></font> '
            .. '<font color="rgb(148,163,184)">Loading...</font>'
            .. '\n<font color="rgb(148,163,184)">Upcoming rare moons:</font>'
            .. '\n<font color="rgb(148,163,184)">Loading moon data...</font>',
        DoesWrap = true,
    })

task.defer(function()

    for _ = 1, 8 do

        if type(GAG2MoonPredictorRefresh) == "function" then

            GAG2MoonPredictorRefresh()
        end

        task.wait(
            0.25
        )
    end
end)

if type(HomeFarmDetailsBox.AddUIPassthrough) == "function" then

    GAG2_FARM_DETAILS_PANEL =
        HomeFarmDetailsBox:AddUIPassthrough(
            "HolyGAG2FarmDetailsPanel",
            {
                Instance =
                    GAG2FarmDetailsCreatePanel(),

                Height =
                    tonumber(GAG2_FARM_DETAILS_STATE.TopPanelHeight)
                    or tonumber(GAG2_FARM_DETAILS_STATE.PanelHeight)
                    or 246,

                Visible =
                    true,
            }
        )

else

    GAG2_FARM_DETAILS_LABEL =
        HomeFarmDetailsBox:AddLabel("HolyGAG2FarmDetails", {
            Text =
                '<font color="rgb(196,181,253)"><b>Farm:</b></font> '
                .. '<font color="rgb(148,163,184)">Loading...</font>'
                .. '\n<font color="rgb(148,163,184)">Loading farm details...</font>',
            DoesWrap = true,
        })
end

task.defer(function()

    for _ = 1, 8 do

        if type(GAG2FarmDetailsRefresh) == "function" then

            GAG2FarmDetailsRefresh(
                true
            )
        end

        task.wait(
            0.35
        )
    end
end)

if IsGAG2World() ~= true then

    HomeServerBox:AddLabel({
        Text =
            '<font color="rgb(248,113,113)"><b>Unknown Place Warning</b></font>'
            .. '\nKnown GAG2 PlaceIds: '
            .. GAG2KnownPlaceIdsText()
            .. '\nCurrent PlaceId: '
            .. tostring(game.PlaceId),
        DoesWrap = true,
    })
end

--==================================================
-- [8.1] SERVER TAB
--==================================================

local ServerSelectionDropdown =
    ServerMainBox:AddDropdown(
        "HolyGAG2ServerSelectionMode",
        {
            Text = "Server Selection Mode",
            Values = GAG2_SERVER_SELECTION_MODES,
            Default = GAG2_SERVER_SELECTION_STATE.Mode or "Most Empty",
            Multi = false,
            Searchable = false,
            Tooltip = "Controls every HopServerOnce call: manual hop, version hop, and sniper auto-hop.",
        }
    )

if ServerSelectionDropdown
and type(ServerSelectionDropdown.OnChanged) == "function" then

    ServerSelectionDropdown:OnChanged(function(value)

        GAG2ServerSelectionSetMode(
            value
        )
    end)
end

ServerMainBox:AddButton({
    Text = "Server Hop",
    Tooltip = "Hop once using the selected server selection mode.",
    Func = function()

        HopServerOnce()
    end,
}):AddButton({
    Text = "Stop Hop",
    Tooltip = "Stop current server hop retry loop.",
    Func = function()

        GAG2CancelServerHop(
            "Server hop stopped."
        )

        GAG2ServerSelectionSetStatus(
            "Stopped."
        )
    end,
})

ServerStatusBox:AddLabel("HolyGAG2ServerSelectionStatus", {
    Text = GAG2ServerSelectionBuildStatus(),
    DoesWrap = true,
})

GAG2_WILD_PET_NETWORK_HUD_TOGGLE =
    ServerMainBox:AddToggle(
        "HolyGAG2WildPetNetworkHud",
        {
            Text = "Live Wild Pet HUD",
            Default = false,
            Tooltip = "Show the global scout network HUD. Click a server row to exact join it.",
            Callback = function(value)

                GAG2WildPetNetworkSetEnabled(
                    value == true
                )
            end,
        }
    )

GAG2_WILD_PET_NETWORK_CONTRIBUTE_TOGGLE =
    ServerMainBox:AddToggle(
        "HolyGAG2WildPetNetworkContribute",
        {
            Text = "Contribute Current Server",
            Default = true,
            Tooltip = "Upload this server's live WildPetRef data so everyone using the HUD can see it.",
            Callback = function(value)

                GAG2WildPetNetworkContributorSetEnabled(
                    value == true
                )
            end,
        }
    )

ServerMainBox:AddButton({
    Text = "Refresh Wild Pet HUD",
    Tooltip = "Immediately refresh live wild pet server reports.",
    Func = function()

        if GAG2_WILD_PET_NETWORK_STATE.Enabled ~= true then

            Notify(
                "Live Wild Pets",
                "Enable Live Wild Pet HUD first.",
                4
            )

            return
        end

        GAG2WildPetNetworkRefresh(
            "manual button"
        )
    end,
})

ServerMainBox:AddButton({
    Text = "Report Current Server",
    Tooltip = "Immediately upload this server's current wild pet data.",
    Func = function()

        if GAG2_WILD_PET_NETWORK_CONTRIBUTE_STATE.Enabled ~= true then

            Notify(
                "Live Wild Pets",
                "Enable Contribute Current Server first.",
                4
            )

            return
        end

        GAG2WildPetNetworkReportCurrentServer(
            "manual button"
        )
    end,
})

ServerStatusBox:AddLabel(
    "HolyGAG2WildPetNetworkStatus",
    {
        Text =
            GAG2WildPetNetworkBuildStatusText(),

        DoesWrap =
            true,
    }
)

ServerStatusBox:AddLabel(
    "HolyGAG2WildPetNetworkContributorStatus",
    {
        Text =
            GAG2WildPetNetworkContributorBuildStatusText(),

        DoesWrap =
            true,
    }
)

--==================================================
-- [9.5] SNIPER TAB
--==================================================

SniperMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Wild Pet Sniper</b></font>',
    DoesWrap = true,
    Size = 13,
})

SniperMainBox:AddDivider()

SniperTargetDropdown =
    SniperMainBox:AddDropdown(
        "HolyGAG2SniperTargetsList",
        {
            Text = "Target Pets",
            Values = SniperGetDropdownPetNames(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Select pets to look for.",
        }
    )

SniperMainBox:AddDropdown(
    "HolyGAG2SniperSizeClass",
    {
        Text = "Size Class",
        Values = SniperSizeClassValues(),
        Default = SniperSizeClassText(),
        Multi = false,
        Searchable = false,
        AllowNull = false,
        MaxVisibleDropdownItems = 3,
        Tooltip = "Only buy pets matching this size class.",
    }
):OnChanged(function(value)

    SniperSetSizeClass(
        value
    )

    SniperScan(
        false
    )
end)

SniperMainBox:AddButton({
    Text = "Refresh List",
    Tooltip = "Refresh available pet names.",
    Func = function()

        SniperRefreshTargetDropdown()
        SniperRefreshPriorityDropdowns()

        SetSniperStatus(
            "List refreshed."
        )
    end,
})

SniperMainBox:AddDivider()

SniperMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Buy Priority</b></font>',
    DoesWrap = true,
    Size = 13,
})

for priorityIndex = 1, 5 do

    SniperPriorityDropdowns[priorityIndex] =
        SniperMainBox:AddDropdown(
            "HolyGAG2SniperPriority"
                .. tostring(priorityIndex),
            {
                Text =
                    "Priority "
                    .. tostring(priorityIndex),
                Values =
                    SniperGetPriorityDropdownValues(),
                Default =
                    "None",
                Multi =
                    false,
                Searchable =
                    true,
                AllowNull =
                    false,
                MaxVisibleDropdownItems =
                    10,
                Tooltip =
                    "Higher priority pets are bought first.",
            }
        )

    if SniperPriorityDropdowns[priorityIndex]
    and type(SniperPriorityDropdowns[priorityIndex].OnChanged) == "function" then

        SniperPriorityDropdowns[priorityIndex]:OnChanged(function(value)

            if SniperPriorityRefreshing == true then
                return
            end

            SniperSetPriorityPet(
                priorityIndex,
                value
            )

            SniperScan(
                false
            )
        end)
    end
end

SniperMainBox:AddButton({
    Text = "Clear Priority",
    Tooltip = "Reset all priority slots.",
    Func = function()

        for priorityIndex = 1, 5 do

            SniperSetPriorityPet(
                priorityIndex,
                ""
            )

            local dropdown =
                SniperPriorityDropdowns[priorityIndex]

            if dropdown
            and type(dropdown.SetValue) == "function" then

                pcall(function()

                    dropdown:SetValue(
                        "None"
                    )
                end)
            end
        end

        SniperScan(
            false
        )
    end,
})

SniperMainBox:AddDivider()

GAG2_SNIPER_TOGGLE_CONTROL =
    SniperMainBox:AddToggle("HolyGAG2SniperEnabled", {
        Text = "Activate Sniper",
        Default = false,
        Tooltip = "Start looking for selected pets. Hotkey: F.",
        Callback = function(value)

            if GAG2_SNIPER_STOPPING == true then
                return
            end

            SniperSetEnabled(
                value == true
            )

            MarkConfigDirty()
        end,
    })

if GAG2_SNIPER_TOGGLE_CONTROL
and type(GAG2_SNIPER_TOGGLE_CONTROL.AddKeyPicker) == "function" then

    GAG2_SNIPER_KEYBIND_CONTROL =
        GAG2_SNIPER_TOGGLE_CONTROL:AddKeyPicker(
            "HolyGAG2SniperHotkey",
            {
                Text = "Sniper Key",
                Default = "F",
                Mode = "Toggle",
                SyncToggleState = true,
            }
        )
end

GAG2_PANIC_HUD_TOGGLE_CONTROL =
    SniperMainBox:AddToggle("HolyGAG2SniperPanicHud", {
        Text = "STOP HUD",
        Default = true,
        Tooltip = "Shows the draggable STOP button HUD. Turn OFF to hide it.",
        Callback = function(value)

            GAG2SetPanicHudEnabled(
                value == true
            )
        end,
    })

local SniperMovementModeDropdown =
    SniperMainBox:AddDropdown(
        "HolyGAG2SniperMovementMode",
        {
            Text = "Movement Mode",
            Values = {
                "Teleport",
                "Walk",
            },
            Default = SniperGetMovementMode(),
            Multi = false,
            Searchable = false,
            AllowNull = false,
            MaxVisibleDropdownItems = 2,
            Tooltip = "Teleport is fastest. Walk is smoother and less ugly.",
        }
    )

if SniperMovementModeDropdown
and type(SniperMovementModeDropdown.OnChanged) == "function" then

    SniperMovementModeDropdown:OnChanged(function(value)

        SniperState.MovementMode =
            CleanText(value) == "Walk"
            and "Walk"
            or "Teleport"

        SetSniperStatus(
            "Movement mode: "
            .. tostring(SniperState.MovementMode)
        )

        MarkConfigDirty()
    end)
end

local SniperBuyModeDropdown =
    SniperMainBox:AddDropdown(
        "HolyGAG2SniperBuyMode",
        {
            Text = "Buy Mode",
            Values = {
                "Instant",
                "Hold",
            },
            Default = SniperGetBuyMode(),
            Multi = false,
            Searchable = false,
            AllowNull = false,
            MaxVisibleDropdownItems = 2,
            Tooltip = "Instant uses packet buy. Hold uses the real BuyPrompt hold.",
        }
    )

if SniperBuyModeDropdown
and type(SniperBuyModeDropdown.OnChanged) == "function" then

    SniperBuyModeDropdown:OnChanged(function(value)

        SniperState.BuyMode =
            CleanText(value) == "Hold"
            and "Hold"
            or "Instant"

        SetSniperStatus(
            "Buy mode: "
            .. tostring(SniperState.BuyMode)
        )

        MarkConfigDirty()
    end)
end

SniperMainBox:AddToggle("HolyGAG2SniperFollowPet", {
    Text = "Follow Pet",
    Default = false,
    Tooltip = "Walks toward the pet while holding BuyPrompt. Does not teleport-spam.",
    Callback = function(value)

        SniperState.FollowPet =
            value == true

        SetSniperStatus(
            SniperState.FollowPet == true
            and "Follow pet enabled."
            or "Follow pet disabled."
        )

        MarkConfigDirty()
    end,
})

SniperMainBox:AddToggle("HolyGAG2SniperReturnAfterTame", {
    Text = "Return After Buy",
    Default = false,
    Tooltip = "Returns to your old position after the buy is sent.",
    Callback = function(value)

        SniperState.ReturnAfterTame =
            value == true

        SetSniperStatus(
            SniperState.ReturnAfterTame == true
            and "Return after buy enabled."
            or "Return after buy disabled."
        )

        MarkConfigDirty()
    end,
})

SniperReturnModeDropdown =
    SniperMainBox:AddDropdown(
        "HolyGAG2SniperReturnMode",
        {
            Text = "Return Mode",
            Values = {
                "Walk",
                "Teleport",
            },
            Default = SniperGetReturnMovementMode(),
            Multi = false,
            Searchable = false,
            AllowNull = false,
            MaxVisibleDropdownItems = 2,
            Tooltip = "How Return After Buy moves back to the saved position.",
        }
    )

if SniperReturnModeDropdown
and type(SniperReturnModeDropdown.OnChanged) == "function" then

    SniperReturnModeDropdown:OnChanged(function(value)

        SniperState.ReturnMovementMode =
            CleanText(value) == "Teleport"
            and "Teleport"
            or "Walk"

        SetSniperStatus(
            "Return mode: "
            .. tostring(SniperState.ReturnMovementMode)
        )

        MarkConfigDirty()
    end)
end


SniperMainBox:AddToggle("HolyGAG2SniperAutoHop", {
    Text = "Auto Hop",
    Default = false,
    Tooltip = "When enabled, sniper waits Hop Delay seconds with no match, then hops.",
    Callback = function(value)

        SniperState.AutoHop =
            value == true

        SniperState.InstantFirstHop =
            false

        SniperState.FirstHopUsed =
            true

        SniperState.LastHopAt =
            os.clock()

        SetSniperStatus(
            SniperState.AutoHop == true
            and (
                "Auto hop enabled. First hop in "
                .. tostring(SniperState.HopDelay)
                .. "s."
            )
            or "Auto hop disabled."
        )

        MarkConfigDirty()
    end,
})


SniperMainBox:AddInput("HolyGAG2SniperHopDelay", {
    Text = "Hop Delay",
    Default = tostring(SniperState.HopDelay),
    Numeric = true,
    Finished = true,
    ClearTextOnFocus = false,
    Placeholder = "20",
    Tooltip = "Minimum seconds between hop attempts.",
    Callback = function(value)

        SniperState.HopDelay =
            math.clamp(
                tonumber(value)
                or 20,
                5,
                120
            )

        SetSniperStatus(
            "Hop delay: "
            .. tostring(SniperState.HopDelay)
            .. "s"
        )

        MarkConfigDirty()
    end,
})

SniperMainBox:AddDivider()

SniperMainBox:AddButton({
    Text = "Scan Now",
    Tooltip = "Check once.",
    Func = function()

        SniperScan(
            false
        )
    end,
}):AddButton({
    Text = "Copy Results",
    Tooltip = "Copy last result.",
    Func = function()

        if CopyText(SniperState.LastMatchText) == true then

            Notify(
                "Sniper",
                "Results copied.",
                3
            )

        else

            Notify(
                "Clipboard",
                "Clipboard unsupported.",
                4
            )
        end
    end,
})

SniperStatusBox:AddLabel("HolyGAG2SniperStatus", {
    Text =
        "Ready.",
    DoesWrap = true,
})

SniperStatusBox:AddLabel("HolyGAG2SniperMatches", {
    Text =
        '<font color="rgb(196,181,253)"><b>Selected Targets</b></font>'
        .. '\nNone'
        .. '\n\n'
        .. '<font color="rgb(196,181,253)"><b>Size Class</b></font>'
        .. '\nAny Size'
        .. '\n\n'
        .. '<font color="rgb(196,181,253)"><b>Result</b></font>'
        .. '\nNo scan yet.',
    DoesWrap = true,
})

SniperRefreshTargetDropdown()

task.delay(1, function()

    SniperRefreshTargetDropdown()
end)

task.delay(3, function()

    SniperRefreshTargetDropdown()
end)

SetSniperStatus(
    "Ready."
)

RefreshSniperLabels()

--==================================================
-- [10] SETTINGS TAB
--==================================================

SettingsUIBox:AddToggle(
    "HolyGAG2AutoCloseUI",
    {
        Text = "Auto Close UI",
        Default = UIState.ShowUIOnLoad ~= true,
        Tooltip = "When enabled, the UI starts closed on next execution. Press LeftAlt to open it.",
    }
):OnChanged(function(value)

    UIState.ShowUIOnLoad =
        value ~= true

    SaveUISettingsNow()
    MarkConfigDirty()
end)

SettingsUIBox:AddDropdown(
    "HolyGAG2DPI",
    {
        Text = "UI Scale",
        Values = {
            "30%",
            "40%",
            "50%",
            "60%",
            "70%",
            "80%",
            "90%",
            "100%",
            "110%",
        },
        Default =
            FormatDPIScale(
                UIState.DPIScale
            ),
        Multi = false,
        Searchable = false,
        MaxVisibleDropdownItems = 9,
        Tooltip = "Changes the size of the interface.",
    }
):OnChanged(function(value)

    local scale =
        ParseDPIScale(value)

    UIState.DPIScale =
        scale

    if Library
    and type(Library.SetDPIScale) == "function" then

        pcall(function()

            Library:SetDPIScale(
                scale
            )
        end)
    end

    SaveUISettingsNow()
    MarkConfigDirty()
end)

SettingsUIBox:AddDivider()

SettingsUIBox:AddToggle(
    "HolyGAG2AutoSkipLoading",
    {
        Text = "Auto Skip Loading",
        Default = true,
        Tooltip = "Uses a monitored loading hold. HOLY never fakes loading attributes, hides the loading screen, or forces the camera.",
    }
):OnChanged(function(value)

    if ConfigState.Loading == true then
        return
    end

    if type(GAG2SetAutoSkipLoadingEnabled) == "function" then

        GAG2SetAutoSkipLoadingEnabled(
            value == true
        )
    end
end)

SettingsUIBox:AddToggle(
    "HolyGAG2AutoTpMiddleFarm",
    {
        Text = "Auto Middle Farm",
        Default = false,
        Tooltip = "Moves to your farm middle once. Does not keep pulling you back after you move.",
    }
):OnChanged(function(value)

    if ConfigState.Loading == true then
        return
    end

    if type(GAG2SetAutoTpMiddleFarmEnabled) == "function" then

        GAG2SetAutoTpMiddleFarmEnabled(
            value == true
        )
    end
end)

SettingsUIBox:AddDropdown(
    "HolyGAG2AutoMiddleFarmMode",
    {
        Text = "Middle Farm Mode",
        Values = {
            "Teleport",
            "Walk",
        },
        Default =
            GAG2MiddleFarmGetMovementMode(),
        Multi = false,
        Searchable = false,
        MaxVisibleDropdownItems = 2,
        Tooltip = "How Auto Middle Farm moves to the saved farm middle.",
    }
):OnChanged(function(value)

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovementMode =
        CleanText(value) == "Walk"
        and "Walk"
        or "Teleport"

    if GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovementMode == "Walk"
    and Toggles.HolyGAG2AutoTpMiddleFarm
    and Toggles.HolyGAG2AutoTpMiddleFarm.Value == true then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.MovedOnce =
            false

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.MiddleReady =
            false

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastMiddleReadyAt =
            0

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastSniperMiddleStartAt =
            0

        if type(GAG2StartAutoTpMiddleFarm) == "function" then

            GAG2StartAutoTpMiddleFarm(
                "mode changed"
            )
        end
    end

    MarkConfigDirty()
end)

SettingsUIBox:AddDivider()

SettingsUIBox:AddToggle("HolyGAG2HideOtherGardens", {
    Text = "Hide Other Gardens",
    Default = false,
    Tooltip = "Locally hides other players gardens only.",
    Callback = function(value)

        GAG2PerformanceSetHideOtherGardensEnabled(
            value == true
        )
    end,
})

SettingsUIBox:AddToggle("HolyGAG2HideOwnGarden", {
    Text = "Hide Own Garden",
    Default = false,
    Tooltip = "Visual-hide only. Keeps your own garden in workspace so fruits can still be collected.",
    Callback = function(value)

        GAG2PerformanceSetHideOwnGardenEnabled(
            value == true
        )
    end,
})

SettingsUIBox:AddToggle("HolyGAG2HideMapClutter", {
    Text = "Hide Map Clutter",
    Default = false,
    Tooltip = "Locally removes workspace.Map.Middle, workspace.Map.Stands, and workspace.NPCS.",
    Callback = function(value)

        GAG2PerformanceSetHideMapClutterEnabled(
            value == true
        )
    end,
})

SettingsUIBox:AddToggle("HolyGAG2AntiAfk", {
    Text = "Anti AFK",
    Default = true,
    Tooltip = "Default ON. Prevents GAG2 custom 30min inactivity hop with quiet input pulses. No remotes, no console output.",
    Callback = function(value)

        GAG2AntiAfkSetEnabled(
            value == true
        )
    end,
})

SettingsUIBox:AddButton({
    Text = "Restore Gardens",
    Tooltip = "Restores gardens hidden by Hide Other Gardens.",
    Func = function()

        GAG2_PERFORMANCE_STATE.HideOtherGardens =
            false

        GAG2_PERFORMANCE_STATE.HideOwnGarden =
            false

        GAG2_PERFORMANCE_STATE.HideMapClutter =
            false

        if Toggles.HolyGAG2HideOtherGardens
        and type(Toggles.HolyGAG2HideOtherGardens.SetValue) == "function" then

            pcall(function()

                Toggles.HolyGAG2HideOtherGardens:SetValue(
                    false
                )
            end)
        end

        if Toggles.HolyGAG2HideOwnGarden
        and type(Toggles.HolyGAG2HideOwnGarden.SetValue) == "function" then

            pcall(function()

                Toggles.HolyGAG2HideOwnGarden:SetValue(
                    false
                )
            end)
        end

        if Toggles.HolyGAG2HideMapClutter
        and type(Toggles.HolyGAG2HideMapClutter.SetValue) == "function" then

            pcall(function()

                Toggles.HolyGAG2HideMapClutter:SetValue(
                    false
                )
            end)
        end

        GAG2PerformanceRestoreHiddenGardens(
            "manual restore"
        )
    end,
})

SettingsUIBox:AddDivider()

SettingsUIBox:AddButton({
    Text = "Unload UI",
    Risky = true,
    DoubleClick = true,
    Tooltip = "Unload HOLY UI.",
    Func = function()

        Library:Unload()
    end,
})

--==================================================
-- [11] DEV TAB
--==================================================

if DevToolsBox
and DevInfoBox then

    DevToolsBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Developer Tools</b></font>'
            .. '\nResearch tools only.',
        DoesWrap = true,
        Size = 13,
    })

    DevToolsBox:AddButton({
        Text = "Remote Spy",
        Tooltip = "Open Utopia Remote Spy.",
        Func = function()

            LoadDevTool(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
            )
        end,
    })

    DevToolsBox:AddButton({
        Text = "Cobalt Spy",
        Tooltip = "Open Cobalt Remote Spy. Better for incoming/outgoing network traffic research.",
        Func = function()

            LoadDevTool(
                "https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau",
                "Cobalt Spy"
            )
        end,
    })

    DevToolsBox:AddButton({
        Text = "Dex Explorer",
        Tooltip = "Open Dex Explorer.",
        Func = function()

            LoadDevTool(
                "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua",
                "Dex Explorer"
            )
        end,
    })

    DevInfoBox:AddLabel({
        Text =
            '<font color="rgb(148,163,184)"><b>Dev Info</b></font>'
            .. '\nUserId: '
            .. tostring(LOCAL_PLAYER.UserId)
            .. '\nPlaceId: '
            .. tostring(game.PlaceId)
            .. '\nJobId: '
            .. tostring(game.JobId),
        DoesWrap = true,
    })
end

--==================================================
-- [11.5] AUTOSAVE
--==================================================

ThemeManager:SetLibrary(
    Library
)

SaveManager:SetLibrary(
    Library
)

ThemeManager:SetFolder(
    "HolyGAG2"
)

SaveManager:SetFolder(
    "HolyGAG2"
)

SaveManager:IgnoreThemeSettings()

if type(SaveManager.SetIgnoreIndexes) == "function" then

    SaveManager:SetIgnoreIndexes({
        "HolyGAG2AutoCloseUI",
        "HolyGAG2DPI",
        "HolyGAG2ManualJoinTarget",

        -- Runtime/default-on helper.
        -- Auto Skip is intentionally ignored so it always defaults ON.
        "HolyGAG2AutoSkipLoading",
    })
end

pcall(function()

    ThemeManager:ApplyTheme(
        "Dark"
    )
end)

pcall(function()

    SaveManager:Load(
        ConfigState.AutosaveName
    )
end)

GAG2StartLoadingGuiCleaner()

local GAG2_EXACT_JOIN_PENDING_ON_LOAD =
    GAG2HandlePendingExactJoinOnLoad()

if GAG2_EXACT_JOIN_PENDING_ON_LOAD ~= true then

    RestoreSniperAutosaveState()
    GAG2RestoreShopAutosaveState()
end

ConfigState.Loading =
    false

if Toggles.HolyGAG2AutoSkipLoading
and type(Toggles.HolyGAG2AutoSkipLoading.SetValue) == "function" then

    pcall(function()

        Toggles.HolyGAG2AutoSkipLoading:SetValue(
            true
        )
    end)
end

if GAG2_EXACT_JOIN_PENDING_ON_LOAD ~= true then

    GAG2RestoreAntiAfkState()
    GAG2RestoreAutoTpMiddleFarmState()
    GAG2RestorePerformanceState()
    GAG2RestoreSeedPlantingState()
    GAG2RestoreAutoCollectFruitState()
    GAG2RestoreAutoSellState()
    GAG2RestoreMailboxState()
    GAG2RestoreSeedDropState()
    GAG2RestoreDropPickupState()
    GAG2RestoreSeedCollectState()
    GAG2RestoreServerSelectionState()
    GAG2RestoreWildPetNetworkState()
    GAG2RestoreWildPetNetworkContributorState()
    GAG2RestoreVersionHopState()
end

task.spawn(function()

    while true do

        task.wait(1)

        if ConfigState.Dirty == true then

            ConfigState.Dirty =
                false

            pcall(function()

                SaveManager:Save(
                    ConfigState.AutosaveName
                )
            end)
        end
    end
end)

--==================================================
-- [12] FINISH
--==================================================

pcall(function()

    TeleportService.TeleportInitFailed:Connect(function(
        player,
        teleportResult,
        errorMessage,
        placeId,
        teleportOptions
    )

        if player ~= LOCAL_PLAYER then
            return
        end

        local resultName =
            teleportResult
            and teleportResult.Name
            or "Unknown"

        local failedServerInstanceId =
            ""

        pcall(function()

            if teleportOptions then

                failedServerInstanceId =
                    CleanText(
                        teleportOptions.ServerInstanceId
                    )
            end
        end)

        warn(
            "[HOLY TELEPORT]",
            "TeleportInitFailed",
            "| result:",
            tostring(resultName),
            "| error:",
            tostring(errorMessage),
            "| place:",
            tostring(placeId),
            "| failed server:",
            tostring(failedServerInstanceId)
        )

        local exactTarget =
            GAG2ReadExactJoinTarget()

        if exactTarget then

            local targetPlaceId =
                tonumber(
                    exactTarget.PlaceId
                )

            local targetJobId =
                CleanText(
                    exactTarget.JobId
                )

            local failedPlaceId =
                tonumber(placeId)

            local samePlace =
                targetPlaceId ~= nil
                and failedPlaceId ~= nil
                and targetPlaceId == failedPlaceId

            local sameServer =
                failedServerInstanceId ~= ""
                and targetJobId ~= ""
                and failedServerInstanceId == targetJobId

            if failedServerInstanceId ~= ""
            and sameServer ~= true then

                warn(
                    "[HOLY EXACT JOIN]",
                    "Ignoring stale exact target.",
                    "| failed server:",
                    tostring(failedServerInstanceId),
                    "| saved target:",
                    tostring(targetJobId)
                )

                GAG2ClearExactJoinTarget(
                    "stale target mismatch"
                )

                GAG2_EXACT_JOIN_STATE.Retrying =
                    false

                if GAG2_SERVER_HOP_RETRYING == true then

                    GAG2_SERVER_HOP_RETRYING =
                        false

                    task.delay(1, function()

                        HopServerOnce()
                    end)
                end

                return
            end

            local terminalFailure =
                resultName == "Unauthorized"
                or resultName == "GameFull"
                or resultName == "GameEnded"
                or resultName == "Flooded"
                or tostring(errorMessage):lower():find(
                    "private instance",
                    1,
                    true
                ) ~= nil
                or tostring(errorMessage):lower():find(
                    "full",
                    1,
                    true
                ) ~= nil

            if terminalFailure == true then

                warn(
                    "[HOLY EXACT JOIN]",
                    "Terminal exact join failure.",
                    "| target:",
                    tostring(targetPlaceId)
                    .. ":"
                    .. tostring(targetJobId),
                    "| result:",
                    tostring(resultName),
                    "| error:",
                    tostring(errorMessage)
                )

                GAG2ClearExactJoinTarget(
                    "terminal TeleportInitFailed: "
                    .. tostring(resultName)
                )

                GAG2_EXACT_JOIN_STATE.Retrying =
                    false

                SetStatus(
                    "Exact join failed: "
                    .. tostring(resultName)
                )

                if type(GAG2SetManualJoinStatus) == "function" then

                    GAG2SetManualJoinStatus(
                        "Exact join failed: "
                        .. tostring(resultName)
                    )
                end

                if type(GAG2WildPetNetworkSetStatus) == "function" then

                    GAG2WildPetNetworkSetStatus(
                        "Join failed: "
                        .. tostring(resultName)
                    )
                end

                if type(GAG2WildPetNetworkRefresh) == "function" then

                    task.delay(0.75, function()

                        GAG2WildPetNetworkRefresh(
                            "join failed"
                        )
                    end)
                end

                return
            end

            if samePlace == true
            and (
                sameServer == true
                or failedServerInstanceId == ""
            ) then

                GAG2RetryExactJoinTarget(
                    exactTarget,
                    "TeleportInitFailed: "
                    .. tostring(resultName)
                )

                return
            end

            warn(
                "[HOLY EXACT JOIN]",
                "Exact target did not match failed teleport. Clearing.",
                "| target:",
                tostring(targetPlaceId)
                .. ":"
                .. tostring(targetJobId),
                "| failed place:",
                tostring(placeId),
                "| failed server:",
                tostring(failedServerInstanceId)
            )

            GAG2ClearExactJoinTarget(
                "failed teleport mismatch"
            )

            GAG2_EXACT_JOIN_STATE.Retrying =
                false

            return
        end

        if GAG2_SERVER_HOP_RETRYING ~= true then
            return
        end

        GAG2_SERVER_HOP_RETRYING =
            false

        task.delay(1, function()

            HopServerOnce()
        end)
    end)
end)

GAG2StartLoadingGuiCleaner()

GAG2ShopStart()
RefreshServerInfo()
RefreshHomeActivePets()
StartHomeActivePetsLoop()
StartGAG2SniperHotkey()
SetStatus("Ready")

Library:OnUnload(function()

    if type(GAG2AntiAfkSetEnabled) == "function" then

        GAG2AntiAfkSetEnabled(
            false,
            true
        )
    end

    if type(GAG2PerformanceRestoreHiddenGardens) == "function" then

        GAG2PerformanceRestoreHiddenGardens(
            "ui unload"
        )
    end

    print(
        "[HOLY]",
        "Unloaded."
    )
end)

Notify(
    "HOLY",
    "Script loaded. Toggle with LeftAlt.",
    4
)

print(
    "[HOLY]",
    "Script loaded."
)
