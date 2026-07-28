-- ============================================================
-- GAG2 PREMIUM MAILBOX - SERVICES & INITIALIZATION
-- ============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local LP = LocalPlayer

-- LOAD NETWORKING
local Networking
pcall(function()
    Networking = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Networking"))
end)

-- ============================================================
-- THEME - BLUE UI
-- ============================================================

local SOPHIA_MAIL_THEME = {
    Back = Color3.fromRGB(15, 25, 45),
    Header = Color3.fromRGB(30, 60, 120),
    Card = Color3.fromRGB(40, 80, 150),
    Field = Color3.fromRGB(50, 100, 180),
    Hover = Color3.fromRGB(60, 120, 200),
    Border = Color3.fromRGB(100, 150, 220),
    Text = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(200, 220, 255),
    Muted = Color3.fromRGB(150, 170, 200),
    White = Color3.fromRGB(255, 252, 253),
    Black = Color3.fromRGB(8, 2, 4),
    Green = Color3.fromRGB(82, 217, 143),
    Yellow = Color3.fromRGB(235, 188, 92),
    Red = Color3.fromRGB(255, 82, 98),
    Accent = Color3.fromRGB(100, 200, 255),
    AccentBright = Color3.fromRGB(150, 220, 255),
}

local UI_SETTINGS_FOLDER = "GAG2Premium"

-- ============================================================
-- [3.10] MAIL DELIVERY HUD
--==================================================

if type(SOPHIA_MAIL_RUNTIME) == "table" then
    if type(SOPHIA_MAIL_RUNTIME.StopInboxWorker) == "function" then
        pcall(function()
            SOPHIA_MAIL_RUNTIME.StopInboxWorker()
        end)
    end

    if type(SOPHIA_MAIL_RUNTIME.DeliveryState) == "table" then
        SOPHIA_MAIL_RUNTIME.DeliveryState.Stop = true
    end

    if typeof(SOPHIA_MAIL_RUNTIME.Gui) == "Instance" then
        pcall(function()
            SOPHIA_MAIL_RUNTIME.Gui:Destroy()
        end)
    elseif type(SOPHIA_MAIL_RUNTIME.Stop) == "function" then
        pcall(function()
            SOPHIA_MAIL_RUNTIME.Stop("reload")
        end)
    end

    if typeof(SOPHIA_MAIL_RUNTIME.KeyGateGui) == "Instance" then
        pcall(function()
            SOPHIA_MAIL_RUNTIME.KeyGateGui:Destroy()
        end)
    end
end

local SOPHIA_MAIL_DAILY_LIMIT = 50
local SOPHIA_MAIL_BATCH_LIMIT = 20
local SOPHIA_MAIL_COOLDOWN = 10.05
local SOPHIA_MAIL_INBOX_CAPACITY = 100

local SOPHIA_MAIL_ACCOUNT_USER_ID =
    math.max(
        0,
        math.floor(
            tonumber(
                LocalPlayer.UserId
            )
            or 0
        )
    )

local SOPHIA_MAIL_LEGACY_SETTINGS_FILE =
    UI_SETTINGS_FOLDER
    .. "/SophiaPremiumMailSettings.json"

local SOPHIA_MAIL_LEGACY_HISTORY_FILE =
    UI_SETTINGS_FOLDER
    .. "/SophiaPremiumMailHistory.json"

local SOPHIA_MAIL_MIGRATION_FILE =
    UI_SETTINGS_FOLDER
    .. "/SophiaPremiumMailMigration.json"

local SOPHIA_MAIL_SETTINGS_FILE =
    UI_SETTINGS_FOLDER
    .. "/GAG2Premium_"
    .. tostring(
        SOPHIA_MAIL_ACCOUNT_USER_ID
    )
    .. "_Settings.json"

local SOPHIA_MAIL_HISTORY_FILE =
    UI_SETTINGS_FOLDER
    .. "/GAG2Premium_"
    .. tostring(
        SOPHIA_MAIL_ACCOUNT_USER_ID
    )
    .. "_History.json"

local SOPHIA_MAIL_HISTORY_LIMIT =
    200

local GAG2PremiumTweenService =
    game:GetService("TweenService")

local function GAG2PremiumAccountFileExists(
    filePath
)
    if type(filePath) ~= "string"
        or filePath == ""
        or type(isfile) ~= "function"
    then
        return false
    end

    local success,
        exists =
        pcall(
            isfile,
            filePath
        )

    return success == true
        and exists == true
end

local function GAG2PremiumReadJsonFile(
    filePath
)
    if not GAG2PremiumAccountFileExists(
        filePath
    ) then
        return nil,
            nil
    end

    local readOk,
        raw =
        pcall(
            readfile,
            filePath
        )

    if readOk ~= true
        or type(raw) ~= "string"
        or raw == ""
    then
        return nil,
            nil
    end

    local decodeOk,
        decoded =
        pcall(function()
            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
        or type(decoded) ~= "table"
    then
        return nil,
            raw
    end

    return decoded,
        raw
end

local function GAG2PremiumWriteJsonFile(
    filePath,
    data
)
    if SophiaCanUseFiles() ~= true
        or type(filePath) ~= "string"
        or type(data) ~= "table"
    then
        return false
    end

    SophiaEnsureFolder()

    local encodeOk,
        encoded =
        pcall(function()
            return HttpService:JSONEncode(
                data
            )
        end)

    if encodeOk ~= true
        or type(encoded) ~= "string"
    then
        return false
    end

    local writeOk =
        pcall(
            writefile,
            filePath,
            encoded
        )

    return writeOk == true
end

local function GAG2PremiumCopyLegacyFile(
    legacyPath,
    accountPath
)
    if GAG2PremiumAccountFileExists(
        accountPath
    ) then
        return true
    end

    local decoded,
        raw =
        GAG2PremiumReadJsonFile(
            legacyPath
        )

    if type(decoded) ~= "table"
        or type(raw) ~= "string"
        or raw == ""
    then
        return false
    end

    local writeOk =
        pcall(
            writefile,
            accountPath,
            raw
        )

    return writeOk == true
end

local function GAG2PremiumPrepareAccountFiles()
    if SophiaCanUseFiles() ~= true
        or SOPHIA_MAIL_ACCOUNT_USER_ID <= 0
    then
        return false
    end

    SophiaEnsureFolder()

    local migration =
        GAG2PremiumReadJsonFile(
            SOPHIA_MAIL_MIGRATION_FILE
        )

    if type(migration) ~= "table" then
        migration = {
            Version = 1,
        }
    end

    local migrationOwner =
        math.floor(
            tonumber(
                migration.OwnerUserId
            )
            or 0
        )

    if migrationOwner <= 0 then
        migrationOwner =
            SOPHIA_MAIL_ACCOUNT_USER_ID

        migration.OwnerUserId =
            SOPHIA_MAIL_ACCOUNT_USER_ID

        migration.OwnerName =
            tostring(
                LocalPlayer.Name
            )

        migration.ClaimedAt =
            os.time()

        if not GAG2PremiumWriteJsonFile(
            SOPHIA_MAIL_MIGRATION_FILE,
            migration
        ) then
            return false
        end
    end

    if migrationOwner
        ~= SOPHIA_MAIL_ACCOUNT_USER_ID
    then
        return true
    end

    local settingsReady =
        GAG2PremiumAccountFileExists(
            SOPHIA_MAIL_SETTINGS_FILE
        )

    if not settingsReady then
        settingsReady =
            GAG2PremiumCopyLegacyFile(
                SOPHIA_MAIL_LEGACY_SETTINGS_FILE,
                SOPHIA_MAIL_SETTINGS_FILE
            )
    end

    local historyReady =
        GAG2PremiumAccountFileExists(
            SOPHIA_MAIL_HISTORY_FILE
        )

    if not historyReady then
        historyReady =
            GAG2PremiumCopyLegacyFile(
                SOPHIA_MAIL_LEGACY_HISTORY_FILE,
                SOPHIA_MAIL_HISTORY_FILE
            )
    end

    migration.Version =
        1

    migration.OwnerUserId =
        SOPHIA_MAIL_ACCOUNT_USER_ID

    migration.OwnerName =
        tostring(
            LocalPlayer.Name
        )

    migration.SettingsMigrated =
        settingsReady == true

    migration.HistoryMigrated =
        historyReady == true

    migration.LastCheckedAt =
        os.time()

    GAG2PremiumWriteJsonFile(
        SOPHIA_MAIL_MIGRATION_FILE,
        migration
    )

    return true
end

SOPHIA_MAIL_STATE = {
    HudEnabled = false,
    StartMinimized = false,
    HudScale = "90%",
    HudPosition = nil,

    AutoClaim = false,
    InboxInterval = "2 seconds",

    ValueStrategy = "Send at least",
    ExtraLimitMode = "5%",
    ExtraLimitCustom = "5%",

    FilterFruits = {},
    FilterMutations = {},

    SavedRecipients = {},
    RecentRecipients = {},

    FleetAccounts = {},
    FleetGroups = {
        "Ungrouped",
    },

    TrackerDay = os.date("!%Y-%m-%d"),
    TrackerUsed = 0,
}

SOPHIA_MAIL_RUNTIME = {
    Gui = nil,
    KeyGateGui = nil,
    Window = nil,
    DeliveryState = nil,

    Status = "Closed",
    LastError = "",

    InboxCount = 0,
    InboxKnown = false,
    InboxClaimed = 0,
    InboxStatus = "Auto Claim is off",
    InboxLastError = "",

    InboxClaiming = false,
    InboxWorkerRunning = false,
    InboxWorkerToken = 0,

    SetMinimized = nil,
    ApplyScale = nil,
    UpdateQuota = nil,

    SyncingToggle = false,
    SyncingInboxToggle = false,
    DestroyPending = false,

    StopInboxWorker = nil,
    Stop = nil,

    RefreshHistory = nil,
    HistoryFilter = "All",
    HistorySearch = "",
    ExpandedHistory = {},
}

SOPHIA_MAIL_HISTORY = {
    Version = 2,

    UserId =
        SOPHIA_MAIL_ACCOUNT_USER_ID,

    Username =
        tostring(
            LocalPlayer.Name
        ),

    Records = {},
}

function GAG2PremiumHistoryNormalizeIcon(value)
    if type(value) == "number" then
        if value <= 0 then
            return ""
        end

        return "rbxassetid://"
            .. tostring(
                math.floor(value)
            )
    end

    if type(value) ~= "string" then
        return ""
    end

    local result =
        value:gsub("^%s+", "")
            :gsub("%s+$", "")

    if result == "" then
        return ""
    end

    if result:match("^%d+$") then
        return "rbxassetid://"
            .. result
    end

    return result
end

function GAG2PremiumHistorySave()
    if SophiaCanUseFiles() ~= true then
        return false
    end

    SophiaEnsureFolder()

    local encodeOk, encoded =
        pcall(function()
            return HttpService:JSONEncode(
                SOPHIA_MAIL_HISTORY
            )
        end)

    if encodeOk ~= true
        or type(encoded) ~= "string"
    then
        return false
    end

    return pcall(function()
        writefile(
            SOPHIA_MAIL_HISTORY_FILE,
            encoded
        )
    end)
end

function GAG2PremiumHistoryLoad()
    SOPHIA_MAIL_HISTORY = {
        Version = 2,

        UserId =
            SOPHIA_MAIL_ACCOUNT_USER_ID,

        Username =
            tostring(
                LocalPlayer.Name
            ),

        Records = {},
    }

    if SophiaCanUseFiles() ~= true then
        return false
    end

    local exists = false

    pcall(function()
        exists =
            isfile(
                SOPHIA_MAIL_HISTORY_FILE
            )
    end)

    if exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(
                SOPHIA_MAIL_HISTORY_FILE
            )
        end)

    if readOk ~= true
        or type(raw) ~= "string"
        or raw == ""
    then
        return false
    end

    local decodeOk, decoded =
        pcall(function()
            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
        or type(decoded) ~= "table"
        or type(decoded.Records) ~= "table"
    then
        return false
    end

    local storedUserId =
        math.floor(
            tonumber(
                decoded.UserId
            )
            or 0
        )

    if storedUserId > 0
        and storedUserId
            ~= SOPHIA_MAIL_ACCOUNT_USER_ID
    then
        return false
    end

    SOPHIA_MAIL_HISTORY.Version =
        2

    SOPHIA_MAIL_HISTORY.UserId =
        SOPHIA_MAIL_ACCOUNT_USER_ID

    SOPHIA_MAIL_HISTORY.Username =
        tostring(
            LocalPlayer.Name
        )

    for _, record in ipairs(
        decoded.Records
    ) do
        if type(record) == "table" then
            table.insert(
                SOPHIA_MAIL_HISTORY.Records,
                record
            )

            if #SOPHIA_MAIL_HISTORY.Records
                >= SOPHIA_MAIL_HISTORY_LIMIT
            then
                break
            end
        end
    end

    return true
end

function GAG2PremiumHistoryAdd(record)
    if type(record) ~= "table" then
        return false
    end

    record.Id =
        tostring(
            record.Id
                or (
                    tostring(os.time())
                    .. "-"
                    .. tostring(
                        math.floor(
                            os.clock() * 1000
                        )
                    )
                    .. "-"
                    .. tostring(
                        math.random(
                            1000,
                            9999
                        )
                    )
                )
        )

    record.Timestamp =
        math.floor(
            tonumber(record.Timestamp)
                or os.time()
        )

    record.Items =
        type(record.Items) == "table"
            and record.Items
            or {}

    record.AccountUserId =
        SOPHIA_MAIL_ACCOUNT_USER_ID

    record.AccountUsername =
        tostring(
            LocalPlayer.Name
        )

    SOPHIA_MAIL_HISTORY.Version =
        2

    SOPHIA_MAIL_HISTORY.UserId =
        SOPHIA_MAIL_ACCOUNT_USER_ID

    SOPHIA_MAIL_HISTORY.Username =
        tostring(
            LocalPlayer.Name
        )

    table.insert(
        SOPHIA_MAIL_HISTORY.Records,
        1,
        record
    )

    while #SOPHIA_MAIL_HISTORY.Records
        > SOPHIA_MAIL_HISTORY_LIMIT
    do
        table.remove(
            SOPHIA_MAIL_HISTORY.Records
        )
    end

    GAG2PremiumHistorySave()

    if type(
        SOPHIA_MAIL_RUNTIME.RefreshHistory
    ) == "function" then
        pcall(
            SOPHIA_MAIL_RUNTIME.RefreshHistory
        )
    end

    return true
end

function GAG2PremiumHistoryClear()
    SOPHIA_MAIL_HISTORY.Records =
        {}

    SOPHIA_MAIL_RUNTIME.ExpandedHistory =
        {}

    GAG2PremiumHistorySave()

    if type(
        SOPHIA_MAIL_RUNTIME.RefreshHistory
    ) == "function" then
        pcall(
            SOPHIA_MAIL_RUNTIME.RefreshHistory
        )
    end

    return true
end

function GAG2PremiumHistoryRecordClaim(mail)
    if type(mail) ~= "table"
        or type(mail.Data) ~= "table"
    then
        return false
    end

    local data =
        mail.Data

    local items = {}
    local itemCount = 0
    local knownValue = 0

    for itemKey, itemData in pairs(
        type(data.Items) == "table"
            and data.Items
            or {}
    ) do
        local item =
            type(itemData) == "table"
                and itemData
                or {}

        local count =
            math.max(
                1,
                math.floor(
                    tonumber(
                        item.Count
                            or item.Amount
                            or item.Quantity
                            or (
                                type(itemData) == "number"
                                    and itemData
                                    or 1
                            )
                    )
                    or 1
                )
            )

        local name =
            tostring(
                item.ItemName
                    or item.DisplayName
                    or item.Name
                    or item.FruitName
                    or itemKey
                    or "Unknown item"
            )

        local details =
            tostring(
                item.Mutation
                    or item.Variant
                    or item.Category
                    or item.ItemType
                    or "Mail item"
            )

        local icon =
            GAG2PremiumHistoryNormalizeIcon(
                item.IMG
                    or item.Icon
                    or item.Image
                    or item.ImageId
                    or item.TextureId
            )

        local value =
            math.max(
                0,
                tonumber(
                    item.Value
                        or item.SellValue
                        or item.Price
                )
                or 0
            )

        itemCount +=
            count

        knownValue +=
            value * count

        table.insert(
            items,
            {
                Name = name,
                Details = details,
                Icon = icon,
                Count = count,
                Sent = count,
                Value = value * count,
            }
        )
    end

    local senderId =
        tonumber(
            data.SenderUserId
                or data.FromUserId
                or data.SenderId
                or data.UserId
        )
        or 0

    local senderName =
        tostring(
            data.SenderName
                or data.FromName
                or data.Username
                or (
                    senderId > 0
                        and (
                            "User "
                            .. tostring(senderId)
                        )
                        or "Unknown sender"
                )
        )

    return GAG2PremiumHistoryAdd({
        Direction = "Received",
        Mode = "Inbox",
        Status = "Received",

        OtherUserId = senderId,
        OtherName = senderName,

        AttemptedMails = 1,
        AcceptedMails = 1,

        PlannedItems = itemCount,
        SentItems = itemCount,

        TargetValue = knownValue,
        AcceptedValue = knownValue,

        Items = items,

        Timestamp =
            tonumber(data.SentAt)
                or os.time(),
    })
end

SOPHIA_MAIL_UI = {
    HudToggle = nil,
    StartMinimizedToggle = nil,
    ScaleDropdown = nil,
    UsedInput = nil,

    InboxToggle = nil,
    InboxIntervalDropdown = nil,

    InboxCountLabel = nil,
    InboxClaimedLabel = nil,
    InboxStatusLabel = nil,

    UsageLabel = nil,
}

function GAG2PremiumToday()
    return os.date("!%Y-%m-%d")
end

function GAG2PremiumNormalizeScale(value)
    local cleanedValue =
        tostring(
            value or "90%"
        ):gsub(
            "%%",
            ""
        )

    local scale =
        tonumber(cleanedValue)
        or 90

    scale =
        math.clamp(
            math.floor(
                scale + 0.5
            ),
            80,
            110
        )

    return tostring(scale) .. "%",
        scale / 100
end

function GAG2PremiumNormalizeInboxInterval(value)
    local seconds =
        tonumber(
            tostring(
                value or "2 seconds"
            ):match("%d+")
        )
        or 2

    local allowed = {
        [1] = true,
        [2] = true,
        [5] = true,
        [10] = true,
    }

    seconds =
        math.floor(
            seconds
        )

    if allowed[seconds] ~= true then
        seconds =
            2
    end

    local formatted =
        tostring(seconds)
        .. (
            seconds == 1
                and " second"
                or " seconds"
        )

    return formatted,
        seconds
end

function GAG2PremiumNormalizeValueStrategy(
    value
)
    value =
        tostring(
            value
            or "Send at least"
        )

    local allowed = {
        ["Send at least"] = true,
        ["Closest amount"] = true,
        ["Don't go over"] = true,
    }

    if allowed[value] ~= true then
        value =
            "Send at least"
    end

    return value
end

function GAG2PremiumNormalizeExtraLimitMode(
    value
)
    value =
        tostring(
            value
            or "5%"
        )

    local allowed = {
        ["No limit"] = true,
        ["1%"] = true,
        ["5%"] = true,
        ["10%"] = true,
        ["Custom"] = true,
    }

    if allowed[value] ~= true then
        value =
            "5%"
    end

    return value
end

function GAG2PremiumNormalizeExtraLimitCustom(
    value
)
    value =
        tostring(
            value
            or "5%"
        )
            :gsub(
                "[%c]+",
                ""
            )
            :gsub(
                "^%s+",
                ""
            )
            :gsub(
                "%s+$",
                ""
            )

    if value == "" then
        value =
            "5%"
    end

    if #value > 24 then
        value =
            value:sub(
                1,
                24
            )
    end

    return value
end

function GAG2PremiumFilterKey(
    value
)
    return tostring(
        value or ""
    )
        :gsub(
            "[%c]+",
            ""
        )
        :gsub(
            "^%s+",
            ""
        )
        :gsub(
            "%s+$",
            ""
        )
        :lower()
end

function GAG2PremiumNormalizeFilterSelection(
    value
)
    local output = {}
    local seen = {}

    if type(value) ~= "table" then
        return output
    end

    for key, stored in pairs(
        value
    ) do
        local candidate

        if type(key) == "number" then
            candidate =
                stored
        elseif stored == true then
            candidate =
                key
        elseif type(stored) == "string" then
            candidate =
                stored
        end

        if candidate ~= nil then
            local display =
                tostring(
                    candidate
                )
                    :gsub(
                        "[%c]+",
                        ""
                    )
                    :gsub(
                        "^%s+",
                        ""
                    )
                    :gsub(
                        "%s+$",
                        ""
                    )

            local normalized =
                GAG2PremiumFilterKey(
                    display
                )

            if normalized ~= ""
                and not seen[normalized]
            then
                seen[normalized] =
                    true

                table.insert(
                    output,
                    display:sub(
                        1,
                        80
                    )
                )

                if #output >= 250 then
                    break
                end
            end
        end
    end

    table.sort(
        output,
        function(left, right)
            return tostring(
                left
            ):lower()
                < tostring(
                    right
                ):lower()
        end
    )

    return output
end

function GAG2PremiumFilterSelectionMap(
    value
)
    local output = {}

    for _, display in ipairs(
        GAG2PremiumNormalizeFilterSelection(
            value
        )
    ) do
        local key =
            GAG2PremiumFilterKey(
                display
            )

        if key ~= "" then
            output[key] =
                display
        end
    end

    return output
end

function GAG2PremiumRecipientText(
    value,
    maximumLength
)
    local result =
        tostring(
            value or ""
        )
            :gsub(
                "[%c]+",
                ""
            )
            :gsub(
                "^%s+",
                ""
            )
            :gsub(
                "%s+$",
                ""
            )

    maximumLength =
        math.max(
            1,
            math.floor(
                tonumber(
                    maximumLength
                )
                or 40
            )
        )

    return result:sub(
        1,
        maximumLength
    )
end

function GAG2PremiumNormalizeRecipientRecords(
    value,
    maximum,
    saved
)
    local output = {}
    local seen = {}

    maximum =
        math.clamp(
            math.floor(
                tonumber(maximum)
                    or 25
            ),
            1,
            50
        )

    if type(value) ~= "table" then
        return output
    end

    for _, record in pairs(
        value
    ) do
        if type(record) == "table" then
            local userId =
                math.floor(
                    tonumber(
                        record.UserId
                            or record.Id
                    )
                    or 0
                )

            local username =
                GAG2PremiumRecipientText(
                    record.Name
                        or record.Username,
                    32
                )

            if userId > 0
                and userId
                    ~= SOPHIA_MAIL_ACCOUNT_USER_ID
                and username ~= ""
                and not seen[userId]
            then
                seen[userId] =
                    true

                local lastUsedAt =
                    math.max(
                        0,
                        math.floor(
                            tonumber(
                                record.LastUsedAt
                            )
                            or 0
                        )
                    )

                local addedAt =
                    math.max(
                        0,
                        math.floor(
                            tonumber(
                                record.AddedAt
                            )
                            or lastUsedAt
                        )
                    )

                table.insert(
                    output,
                    {
                        UserId =
                            userId,

                        Name =
                            username,

                        Label =
                            saved == true
                            and GAG2PremiumRecipientText(
                                record.Label
                                    or username,
                                36
                            )
                            or nil,

                        Favorite =
                            saved == true
                            and record.Favorite == true
                            or false,

                        LastUsedAt =
                            lastUsedAt,

                        AddedAt =
                            addedAt,
                    }
                )

                if #output >= maximum then
                    break
                end
            end
        end
    end

    table.sort(
        output,
        function(left, right)
            if saved == true
                and left.Favorite
                    ~= right.Favorite
            then
                return left.Favorite == true
            end

            if left.LastUsedAt
                ~= right.LastUsedAt
            then
                return left.LastUsedAt
                    > right.LastUsedAt
            end

            return tostring(
                left.Label
                    or left.Name
            ):lower()
                < tostring(
                    right.Label
                        or right.Name
                ):lower()
        end
    )

    return output
end

function GAG2PremiumNormalizeFleetGroupName(
    value
)
    local groupName =
        GAG2PremiumRecipientText(
            value,
            24
        )

    if groupName == ""
        or groupName:lower() == "all"
    then
        return "Ungrouped"
    end

    return groupName
end

function GAG2PremiumNormalizeFleetGroups(
    value
)
    local output = {
        "Ungrouped",
    }

    local seen = {
        ungrouped = true,
    }

    if type(value) ~= "table" then
        return output
    end

    for _, rawGroup in pairs(
        value
    ) do
        local groupName =
            GAG2PremiumNormalizeFleetGroupName(
                rawGroup
            )

        local key =
            groupName:lower()

        if not seen[key]
            and #output < 20
        then
            seen[key] =
                true

            table.insert(
                output,
                groupName
            )
        end
    end

    return output
end

function GAG2PremiumNormalizeFleetAccounts(
    value
)
    local output = {}
    local seen = {}
    local sequence = 0

    if type(value) ~= "table" then
        return output
    end

    for _, record in pairs(
        value
    ) do
        if type(record) == "table" then
            sequence +=
                1

            local userId =
                math.floor(
                    tonumber(
                        record.UserId
                            or record.Id
                    )
                    or 0
                )

            local username =
                GAG2PremiumRecipientText(
                    record.Name
                        or record.Username,
                    32
                )

            if userId > 0
                and userId
                    ~= SOPHIA_MAIL_ACCOUNT_USER_ID
                and username ~= ""
                and not seen[userId]
            then
                seen[userId] =
                    true

                local addedAt =
                    math.max(
                        0,
                        math.floor(
                            tonumber(
                                record.AddedAt
                            )
                            or os.time()
                        )
                    )

                table.insert(
                    output,
                    {
                        UserId =
                            userId,

                        Name =
                            username,

                        Label =
                            GAG2PremiumRecipientText(
                                record.Label
                                    or username,
                                36
                            ),

                        Group =
                            GAG2PremiumNormalizeFleetGroupName(
                                record.Group
                            ),

                        Enabled =
                            record.Enabled
                                ~= false,

                        Priority =
                            math.max(
                                1,
                                math.floor(
                                    tonumber(
                                        record.Priority
                                    )
                                    or sequence
                                )
                            ),

                        AddedAt =
                            addedAt,
                    }
                )

                if #output >= 100 then
                    break
                end
            end
        end
    end

    table.sort(
        output,
        function(left, right)
            if left.Priority
                ~= right.Priority
            then
                return left.Priority
                    < right.Priority
            end

            if left.AddedAt
                ~= right.AddedAt
            then
                return left.AddedAt
                    < right.AddedAt
            end

            return left.Name:lower()
                < right.Name:lower()
        end
    )

    for index, record in ipairs(
        output
    ) do
        record.Priority =
            index
    end

    return output
end

function GAG2PremiumResolveRecipient(
    value
)
    local raw =
        GAG2PremiumRecipientText(
            value,
            80
        ):gsub(
            "^@",
            ""
        )

    if raw == "" then
        return nil,
            nil,
            "Enter a username or User ID."
    end

    local userId
    local username

    local numeric =
        tonumber(raw)

    if numeric then
        numeric =
            math.floor(
                numeric
            )

        local ok,
            result =
            pcall(
                Players.GetNameFromUserIdAsync,
                Players,
                numeric
            )

        if ok
            and type(result) == "string"
        then
            userId =
                numeric

            username =
                result
        end
    else
        local ok,
            result =
            pcall(
                Players.GetUserIdFromNameAsync,
                Players,
                raw
            )

        if ok then
            userId =
                math.floor(
                    tonumber(result)
                        or 0
                )

            local nameOk,
                currentName =
                pcall(
                    Players.GetNameFromUserIdAsync,
                    Players,
                    userId
                )

            username =
                nameOk
                and currentName
                or raw
        end
    end

    if not userId
        or userId <= 0
        or type(username) ~= "string"
        or username == ""
    then
        return nil,
            nil,
            "Recipient not found."
    end

    if userId
        == SOPHIA_MAIL_ACCOUNT_USER_ID
    then
        return nil,
            nil,
            "You cannot save your own account."
    end

    return userId,
        username,
        nil
end

function GAG2PremiumTouchRecipient(
    userId,
    username
)
    userId =
        math.floor(
            tonumber(userId)
                or 0
        )

    username =
        GAG2PremiumRecipientText(
            username,
            32
        )

    if userId <= 0
        or userId
            == SOPHIA_MAIL_ACCOUNT_USER_ID
        or username == ""
    then
        return false
    end

    local usedAt =
        os.time()

    local saved =
        GAG2PremiumNormalizeRecipientRecords(
            SOPHIA_MAIL_STATE.SavedRecipients,
            25,
            true
        )

    for _, record in ipairs(
        saved
    ) do
        if record.UserId == userId then
            record.Name =
                username

            record.LastUsedAt =
                usedAt

            break
        end
    end

    local recent = {
        {
            UserId =
                userId,

            Name =
                username,

            LastUsedAt =
                usedAt,

            AddedAt =
                usedAt,
        },
    }

    for _, record in ipairs(
        GAG2PremiumNormalizeRecipientRecords(
            SOPHIA_MAIL_STATE.RecentRecipients,
            8,
            false
        )
    ) do
        if record.UserId ~= userId then
            table.insert(
                recent,
                record
            )
        end
    end

    SOPHIA_MAIL_STATE.SavedRecipients =
        GAG2PremiumNormalizeRecipientRecords(
            saved,
            25,
            true
        )

    SOPHIA_MAIL_STATE.RecentRecipients =
        GAG2PremiumNormalizeRecipientRecords(
            recent,
            8,
            false
        )

    GAG2PremiumSaveSettings()

    return true
end

function GAG2PremiumSetHudScale(value)
    local formattedScale =
        GAG2PremiumNormalizeScale(value)

    SOPHIA_MAIL_STATE.HudScale =
        formattedScale

    if type(SOPHIA_MAIL_RUNTIME.ApplyScale) == "function" then

        pcall(
            SOPHIA_MAIL_RUNTIME.ApplyScale
        )
    end

    GAG2PremiumSaveSettings()

    return formattedScale
end

function GAG2PremiumCheckDay()
    local today =
        GAG2PremiumToday()

    if tostring(SOPHIA_MAIL_STATE.TrackerDay or "") ~= today then
        SOPHIA_MAIL_STATE.TrackerDay =
            today

        SOPHIA_MAIL_STATE.TrackerUsed =
            0

        return true
    end

    SOPHIA_MAIL_STATE.TrackerUsed =
        math.clamp(
            math.floor(
                tonumber(SOPHIA_MAIL_STATE.TrackerUsed)
                    or 0
            ),
            0,
            SOPHIA_MAIL_DAILY_LIMIT
        )

    return false
end

function GAG2PremiumSaveSettings()
    GAG2PremiumCheckDay()

    if SophiaCanUseFiles() ~= true then
        return false
    end

    SophiaEnsureFolder()

    local position =
        type(SOPHIA_MAIL_STATE.HudPosition) == "table"
            and {
                XScale =
                    tonumber(
                        SOPHIA_MAIL_STATE.HudPosition.XScale
                    ) or 0.5,

                XOffset =
                    tonumber(
                        SOPHIA_MAIL_STATE.HudPosition.XOffset
                    ) or 0,

                YScale =
                    tonumber(
                        SOPHIA_MAIL_STATE.HudPosition.YScale
                    ) or 0.5,

                YOffset =
                    tonumber(
                        SOPHIA_MAIL_STATE.HudPosition.YOffset
                    ) or 0,
            }
            or nil

    local payload = {
        Version =
            2,

        UserId =
            SOPHIA_MAIL_ACCOUNT_USER_ID,

        Username =
            tostring(
                LocalPlayer.Name
            ),

        HudEnabled =
            SOPHIA_MAIL_STATE.HudEnabled == true,

        StartMinimized =
            SOPHIA_MAIL_STATE.StartMinimized == true,

        HudScale =
            GAG2PremiumNormalizeScale(
                SOPHIA_MAIL_STATE.HudScale
                or "100%"
            ),

        AutoClaim =
            SOPHIA_MAIL_STATE.AutoClaim == true,

        InboxInterval =
            GAG2PremiumNormalizeInboxInterval(
                SOPHIA_MAIL_STATE.InboxInterval
                or "2 seconds"
            ),

        ValueStrategy =
            GAG2PremiumNormalizeValueStrategy(
                SOPHIA_MAIL_STATE.ValueStrategy
            ),

        ExtraLimitMode =
            GAG2PremiumNormalizeExtraLimitMode(
                SOPHIA_MAIL_STATE.ExtraLimitMode
            ),

        ExtraLimitCustom =
            GAG2PremiumNormalizeExtraLimitCustom(
                SOPHIA_MAIL_STATE.ExtraLimitCustom
            ),

        FilterFruits =
            GAG2PremiumNormalizeFilterSelection(
                SOPHIA_MAIL_STATE.FilterFruits
            ),

        FilterMutations =
            GAG2PremiumNormalizeFilterSelection(
                SOPHIA_MAIL_STATE.FilterMutations
            ),

        SavedRecipients =
            GAG2PremiumNormalizeRecipientRecords(
                SOPHIA_MAIL_STATE.SavedRecipients,
                25,
                true
            ),

        RecentRecipients =
            GAG2PremiumNormalizeRecipientRecords(
                SOPHIA_MAIL_STATE.RecentRecipients,
                8,
                false
            ),

        FleetAccounts =
            GAG2PremiumNormalizeFleetAccounts(
                SOPHIA_MAIL_STATE.FleetAccounts
            ),

        FleetGroups =
            GAG2PremiumNormalizeFleetGroups(
                SOPHIA_MAIL_STATE.FleetGroups
            ),

        HudPosition =
            position,

        TrackerDay =
            tostring(SOPHIA_MAIL_STATE.TrackerDay),

        TrackerUsed =
            math.clamp(
                math.floor(
                    tonumber(SOPHIA_MAIL_STATE.TrackerUsed)
                        or 0
                ),
                0,
                SOPHIA_MAIL_DAILY_LIMIT
            ),
    }

    local encodeOk, encoded =
        pcall(function()
            return HttpService:JSONEncode(payload)
        end)

    if encodeOk ~= true
        or type(encoded) ~= "string"
    then
        return false
    end

    return pcall(function()
        writefile(
            SOPHIA_MAIL_SETTINGS_FILE,
            encoded
        )
    end)
end

function GAG2PremiumLoadSettings()
    if SophiaCanUseFiles() ~= true then
        GAG2PremiumCheckDay()

        return false
    end

    local exists =
        false

    pcall(function()
        exists =
            isfile(SOPHIA_MAIL_SETTINGS_FILE)
    end)

    if exists ~= true then
        GAG2PremiumCheckDay()

        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(
                SOPHIA_MAIL_SETTINGS_FILE
            )
        end)

    if readOk ~= true
        or type(raw) ~= "string"
        or raw == ""
    then
        GAG2PremiumCheckDay()

        return false
    end

    local decodeOk, data =
        pcall(function()
            return HttpService:JSONDecode(raw)
        end)

    if decodeOk ~= true
        or type(data) ~= "table"
    then
        GAG2PremiumCheckDay()

        return false
    end

    local storedUserId =
        math.floor(
            tonumber(
                data.UserId
            )
            or 0
        )

    if storedUserId > 0
        and storedUserId
            ~= SOPHIA_MAIL_ACCOUNT_USER_ID
    then
        GAG2PremiumCheckDay()

        return false
    end

    SOPHIA_MAIL_STATE.HudEnabled =
        data.HudEnabled == true

    SOPHIA_MAIL_STATE.StartMinimized =
        data.StartMinimized == true

    SOPHIA_MAIL_STATE.HudScale =
        GAG2PremiumNormalizeScale(
            data.HudScale
            or SOPHIA_MAIL_STATE.HudScale
            or "100%"
        )

    SOPHIA_MAIL_STATE.AutoClaim =
        data.AutoClaim == true

    SOPHIA_MAIL_STATE.InboxInterval =
        GAG2PremiumNormalizeInboxInterval(
            data.InboxInterval
            or SOPHIA_MAIL_STATE.InboxInterval
            or "2 seconds"
        )

    SOPHIA_MAIL_STATE.ValueStrategy =
        GAG2PremiumNormalizeValueStrategy(
            data.ValueStrategy
            or SOPHIA_MAIL_STATE.ValueStrategy
        )

    SOPHIA_MAIL_STATE.ExtraLimitMode =
        GAG2PremiumNormalizeExtraLimitMode(
            data.ExtraLimitMode
            or SOPHIA_MAIL_STATE.ExtraLimitMode
        )

    SOPHIA_MAIL_STATE.ExtraLimitCustom =
        GAG2PremiumNormalizeExtraLimitCustom(
            data.ExtraLimitCustom
            or SOPHIA_MAIL_STATE.ExtraLimitCustom
        )

    SOPHIA_MAIL_STATE.FilterFruits =
        GAG2PremiumNormalizeFilterSelection(
            data.FilterFruits
            or SOPHIA_MAIL_STATE.FilterFruits
            or {}
        )

    SOPHIA_MAIL_STATE.FilterMutations =
        GAG2PremiumNormalizeFilterSelection(
            data.FilterMutations
            or SOPHIA_MAIL_STATE.FilterMutations
            or {}
        )

    SOPHIA_MAIL_STATE.SavedRecipients =
        GAG2PremiumNormalizeRecipientRecords(
            data.SavedRecipients
                or SOPHIA_MAIL_STATE.SavedRecipients
                or {},
            25,
            true
        )

    SOPHIA_MAIL_STATE.RecentRecipients =
        GAG2PremiumNormalizeRecipientRecords(
            data.RecentRecipients
                or SOPHIA_MAIL_STATE.RecentRecipients
                or {},
            8,
            false
        )

    SOPHIA_MAIL_STATE.FleetAccounts =
        GAG2PremiumNormalizeFleetAccounts(
            data.FleetAccounts
                or SOPHIA_MAIL_STATE.FleetAccounts
                or {}
        )

    SOPHIA_MAIL_STATE.FleetGroups =
        GAG2PremiumNormalizeFleetGroups(
            data.FleetGroups
                or SOPHIA_MAIL_STATE.FleetGroups
                or {
                    "Ungrouped",
                }
        )

    SOPHIA_MAIL_STATE.TrackerDay =
        tostring(
            data.TrackerDay
                or GAG2PremiumToday()
        )

    SOPHIA_MAIL_STATE.TrackerUsed =
        math.clamp(
            math.floor(
                tonumber(data.TrackerUsed)
                    or 0
            ),
            0,
            SOPHIA_MAIL_DAILY_LIMIT
        )

    if type(data.HudPosition) == "table" then
        SOPHIA_MAIL_STATE.HudPosition = {
            XScale =
                tonumber(data.HudPosition.XScale)
                    or 0.5,

            XOffset =
                tonumber(data.HudPosition.XOffset)
                    or 0,

            YScale =
                tonumber(data.HudPosition.YScale)
                    or 0.5,

            YOffset =
                tonumber(data.HudPosition.YOffset)
                    or 0,
        }
    end

    if GAG2PremiumCheckDay() == true then
        GAG2PremiumSaveSettings()
    end

    return true
end

function GAG2PremiumReadPosition()
    local saved =
        SOPHIA_MAIL_STATE.HudPosition

    if type(saved) ~= "table" then
        return UDim2.fromScale(
            0.5,
            0.5
        )
    end

    return UDim2.new(
        tonumber(saved.XScale) or 0.5,
        tonumber(saved.XOffset) or 0,
        tonumber(saved.YScale) or 0.5,
        tonumber(saved.YOffset) or 0
    )
end

function GAG2PremiumStorePosition(position)
    if typeof(position) ~= "UDim2" then
        return false
    end

    SOPHIA_MAIL_STATE.HudPosition = {
        XScale =
            position.X.Scale,

        XOffset =
            position.X.Offset,

        YScale =
            position.Y.Scale,

        YOffset =
            position.Y.Offset,
    }

    GAG2PremiumSaveSettings()

    return true
end

function GAG2PremiumRefreshControlUI()
    GAG2PremiumCheckDay()

    SophiaSniperSetLabel(
        SOPHIA_MAIL_UI.UsageLabel,
        "Tracked today: "
            .. tostring(
                SOPHIA_MAIL_STATE.TrackerUsed
            )
            .. " / "
            .. tostring(
                SOPHIA_MAIL_DAILY_LIMIT
            )
    )

    local inboxText

    if SOPHIA_MAIL_RUNTIME.InboxKnown == true then
        inboxText =
            "Inbox: "
            .. tostring(
                SOPHIA_MAIL_RUNTIME.InboxCount
            )
            .. " / "
            .. tostring(
                SOPHIA_MAIL_INBOX_CAPACITY
            )
    else
        inboxText =
            "Inbox: Checking..."
    end

    SophiaSniperSetLabel(
        SOPHIA_MAIL_UI.InboxCountLabel,
        inboxText
    )

    SophiaSniperSetLabel(
        SOPHIA_MAIL_UI.InboxClaimedLabel,
        "Claimed this session: "
            .. tostring(
                SOPHIA_MAIL_RUNTIME.InboxClaimed
            )
    )

    SophiaSniperSetLabel(
        SOPHIA_MAIL_UI.InboxStatusLabel,
        tostring(
            SOPHIA_MAIL_RUNTIME.InboxStatus
            or "Waiting for mail"
        )
    )

    return true
end

function GAG2PremiumSetTrackedUsed(value)
    GAG2PremiumCheckDay()

    SOPHIA_MAIL_STATE.TrackerUsed =
        math.clamp(
            math.floor(
                tonumber(value)
                    or 0
            ),
            0,
            SOPHIA_MAIL_DAILY_LIMIT
        )

    if type(SOPHIA_MAIL_RUNTIME.UpdateQuota) == "function" then
        pcall(
            SOPHIA_MAIL_RUNTIME.UpdateQuota
        )
    end

    GAG2PremiumSaveSettings()
    GAG2PremiumRefreshControlUI()

    return SOPHIA_MAIL_STATE.TrackerUsed
end

function GAG2PremiumGetInboxPackets()
    local sharedModules =
        ReplicatedStorage:FindFirstChild(
            "SharedModules"
        )

    local networkingModule =
        sharedModules
        and sharedModules:FindFirstChild(
            "Networking"
        )

    if not networkingModule
        or not networkingModule:IsA("ModuleScript")
    then
        return nil,
            nil,
            "SharedModules.Networking was not found"
    end

    local requireOk, networking =
        pcall(
            require,
            networkingModule
        )

    if requireOk ~= true
        or type(networking) ~= "table"
        or type(networking.Mailbox) ~= "table"
    then
        return nil,
            nil,
            "Networking.Mailbox could not be loaded"
    end

    local listPacket =
        networking.Mailbox.List

    local claimPacket =
        networking.Mailbox.Claim

    if type(listPacket) ~= "table"
        or type(listPacket.Fire) ~= "function"
    then
        return nil,
            nil,
            "Mailbox.List is unavailable"
    end

    if type(claimPacket) ~= "table"
        or type(claimPacket.Fire) ~= "function"
    then
        return nil,
            nil,
            "Mailbox.Claim is unavailable"
    end

    return listPacket,
        claimPacket,
        nil
end

function GAG2PremiumListInbox(listPacket)
    if type(listPacket) ~= "table"
        or type(listPacket.Fire) ~= "function"
    then
        return nil,
            "Mailbox.List is unavailable"
    end

    local callOk, inbox =
        pcall(function()
            return listPacket:Fire()
        end)

    if callOk ~= true then
        return nil,
            tostring(inbox)
    end

    if type(inbox) ~= "table" then
        return nil,
            "Mailbox.List returned invalid data"
    end

    return inbox,
        nil
end

function GAG2PremiumCountInbox(inbox)
    local count =
        0

    for _ in pairs(
        type(inbox) == "table"
            and inbox
            or {}
    ) do
        count +=
            1
    end

    return count
end

function GAG2PremiumApplyInbox(inbox)
    SOPHIA_MAIL_RUNTIME.InboxCount =
        GAG2PremiumCountInbox(
            inbox
        )

    SOPHIA_MAIL_RUNTIME.InboxKnown =
        true

    GAG2PremiumRefreshControlUI()

    return SOPHIA_MAIL_RUNTIME.InboxCount
end

function GAG2PremiumCollectClaimableMails(inbox)
    local claimable =
        {}

    for mailId, mailData in pairs(
        type(inbox) == "table"
            and inbox
            or {}
    ) do
        if type(mailId) == "string"
        and type(mailData) == "table"
        and type(mailData.Items) == "table"
        and next(mailData.Items) ~= nil
        then
            table.insert(
                claimable,
                {
                    Id =
                        mailId,

                    SentAt =
                        tonumber(
                            mailData.SentAt
                        ) or 0,

                    Data =
                        mailData,
                }
            )
        end
    end

    table.sort(
        claimable,
        function(first, second)
            if first.SentAt == second.SentAt then
                return first.Id < second.Id
            end

            return first.SentAt < second.SentAt
        end
    )

    return claimable
end

function GAG2PremiumCleanInboxMessage(value)
    local message =
        tostring(
            value or ""
        ):gsub(
            "[%c]+",
            " "
        )

    if message == "" then
        message =
            "The server rejected the claim"
    end

    if #message > 110 then
        message =
            message:sub(
                1,
                107
            )
            .. "..."
    end

    return message
end

function GAG2PremiumSyncInboxToggle(value)
    local toggle =
        type(Toggles) == "table"
        and Toggles.GAG2PremiumAutoClaim
        or nil

    if type(toggle) ~= "table"
        or type(toggle.SetValue) ~= "function"
        or toggle.Value == (value == true)
    then
        return false
    end

    SOPHIA_MAIL_RUNTIME.SyncingInboxToggle =
        true

    pcall(function()
        toggle:SetValue(
            value == true
        )
    end)

    SOPHIA_MAIL_RUNTIME.SyncingInboxToggle =
        false

    return true
end

function GAG2PremiumStopInboxWorker()
    SOPHIA_MAIL_RUNTIME.InboxWorkerToken =
        (
            tonumber(
                SOPHIA_MAIL_RUNTIME.InboxWorkerToken
            )
            or 0
        )
        + 1

    SOPHIA_MAIL_RUNTIME.InboxWorkerRunning =
        false

    return true
end

SOPHIA_MAIL_RUNTIME.StopInboxWorker =
    GAG2PremiumStopInboxWorker

function GAG2PremiumRefreshInboxCount()
    if SOPHIA_MAIL_RUNTIME.InboxClaiming == true then
        return false,
            "Mail is currently being claimed"
    end

    SOPHIA_MAIL_RUNTIME.InboxStatus =
        "Checking inbox..."

    GAG2PremiumRefreshControlUI()

    local listPacket, _, packetError =
        GAG2PremiumGetInboxPackets()

    if not listPacket then
        SOPHIA_MAIL_RUNTIME.InboxKnown =
            false

        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Could not check inbox"

        SOPHIA_MAIL_RUNTIME.InboxLastError =
            tostring(
                packetError
            )

        GAG2PremiumRefreshControlUI()

        return false,
            packetError
    end

    local inbox, listError =
        GAG2PremiumListInbox(
            listPacket
        )

    if not inbox then
        SOPHIA_MAIL_RUNTIME.InboxKnown =
            false

        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Could not check inbox"

        SOPHIA_MAIL_RUNTIME.InboxLastError =
            tostring(
                listError
            )

        GAG2PremiumRefreshControlUI()

        return false,
            listError
    end

    GAG2PremiumApplyInbox(
        inbox
    )

    if SOPHIA_MAIL_STATE.AutoClaim == true then
        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Watching for new mail..."
    elseif SOPHIA_MAIL_RUNTIME.InboxCount == 0 then
        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Inbox is empty"
    else
        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Auto Claim is off"
    end

    GAG2PremiumRefreshControlUI()

    return true,
        inbox
end

function GAG2PremiumClaimInbox(manual)
    if SOPHIA_MAIL_RUNTIME.InboxClaiming == true then
        if manual == true then
            SophiaNotify(
                "SOPHIA Mail",
                "Mail is already being claimed.",
                3
            )
        end

        return false,
            "Mail is already being claimed",
            0
    end

    SOPHIA_MAIL_RUNTIME.InboxClaiming =
        true

    SOPHIA_MAIL_RUNTIME.InboxStatus =
        "Checking inbox..."

    SOPHIA_MAIL_RUNTIME.InboxLastError =
        ""

    GAG2PremiumRefreshControlUI()

    local executionOk,
        successful,
        resultMessage,
        claimedCount =
        xpcall(
            function()
                local listPacket,
                    claimPacket,
                    packetError =
                    GAG2PremiumGetInboxPackets()

                if not listPacket
                    or not claimPacket
                then
                    return false,
                        packetError,
                        0
                end

                local inbox, listError =
                    GAG2PremiumListInbox(
                        listPacket
                    )

                if not inbox then
                    return false,
                        listError,
                        0
                end

                GAG2PremiumApplyInbox(
                    inbox
                )

                local claimable =
                    GAG2PremiumCollectClaimableMails(
                        inbox
                    )

                if #claimable == 0 then
                    if SOPHIA_MAIL_RUNTIME.InboxCount == 0 then
                        return true,
                            SOPHIA_MAIL_STATE.AutoClaim == true
                                and "Watching for new mail..."
                                or "Inbox is empty",
                            0
                    end

                    return true,
                        "No item gifts to claim",
                        0
                end

                local claimed =
                    0

                for index, mail in ipairs(
                    claimable
                ) do
                    if manual ~= true
                    and SOPHIA_MAIL_STATE.AutoClaim ~= true
                    then
                        break
                    end

                    SOPHIA_MAIL_RUNTIME.InboxStatus =
                        "Claiming "
                        .. tostring(index)
                        .. " of "
                        .. tostring(
                            #claimable
                        )
                        .. "..."

                    GAG2PremiumRefreshControlUI()

                    local callOk,
                        accepted,
                        claimMessage =
                        pcall(function()
                            return claimPacket:Fire(
                                mail.Id
                            )
                        end)

                    if callOk ~= true then
                        return false,
                            tostring(accepted),
                            claimed
                    end

                    if accepted ~= true then
                        return false,
                            tostring(
                                claimMessage
                                or accepted
                            ),
                            claimed
                    end

                    claimed +=
                        1

                    SOPHIA_MAIL_RUNTIME.InboxClaimed +=
                        1

                    GAG2PremiumHistoryRecordClaim(
                        mail
                    )

                    SOPHIA_MAIL_RUNTIME.InboxCount =
                        math.max(
                            0,
                            SOPHIA_MAIL_RUNTIME.InboxCount
                                - 1
                        )

                    GAG2PremiumRefreshControlUI()
                end

                local finalInbox,
                    finalListError =
                    GAG2PremiumListInbox(
                        listPacket
                    )

                if not finalInbox then
                    return false,
                        "Inbox refresh failed: "
                            .. tostring(
                                finalListError
                            ),
                        claimed
                end

                GAG2PremiumApplyInbox(
                    finalInbox
                )

                if SOPHIA_MAIL_STATE.AutoClaim == true then
                    return true,
                        "Watching for new mail...",
                        claimed
                end

                if manual == true
                and claimed > 0
                then
                    return true,
                        "All item mail claimed",
                        claimed
                end

                return true,
                    "Auto Claim is off",
                    claimed
            end,
            function(message)
                return tostring(message)
                    .. "\n"
                    .. debug.traceback()
            end
        )

    SOPHIA_MAIL_RUNTIME.InboxClaiming =
        false

    if executionOk ~= true then
        resultMessage =
            tostring(
                successful
            )

        successful =
            false

        claimedCount =
            0
    end

    claimedCount =
        math.max(
            0,
            math.floor(
                tonumber(
                    claimedCount
                )
                or 0
            )
        )

    if successful == true then
        SOPHIA_MAIL_RUNTIME.InboxStatus =
            tostring(
                resultMessage
                or "Inbox checked"
            )

        if manual == true then
            SophiaNotify(
                "SOPHIA Mail",
                claimedCount > 0
                    and (
                        "Claimed "
                        .. tostring(claimedCount)
                        .. (
                            claimedCount == 1
                                and " mail."
                                or " mails."
                        )
                    )
                    or tostring(
                        resultMessage
                        or "No item mail to claim."
                    ),
                4
            )
        end
    else
        local cleanMessage =
            GAG2PremiumCleanInboxMessage(
                resultMessage
            )

        SOPHIA_MAIL_RUNTIME.InboxLastError =
            cleanMessage

        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Stopped: "
            .. cleanMessage

        if SOPHIA_MAIL_STATE.AutoClaim == true then
            SOPHIA_MAIL_STATE.AutoClaim =
                false

            GAG2PremiumStopInboxWorker()

            GAG2PremiumSyncInboxToggle(
                false
            )

            GAG2PremiumSaveSettings()
        end

        SophiaNotify(
            "SOPHIA Mail",
            "Auto Claim stopped: "
                .. cleanMessage,
            5
        )
    end

    GAG2PremiumRefreshControlUI()

    return successful == true,
        resultMessage,
        claimedCount
end

function GAG2PremiumStartInboxWorker()
    if SOPHIA_MAIL_STATE.AutoClaim ~= true then
        return false
    end

    if SOPHIA_MAIL_RUNTIME.InboxWorkerRunning == true then
        return true
    end

    SOPHIA_MAIL_RUNTIME.InboxWorkerToken =
        (
            tonumber(
                SOPHIA_MAIL_RUNTIME.InboxWorkerToken
            )
            or 0
        )
        + 1

    local token =
        SOPHIA_MAIL_RUNTIME.InboxWorkerToken

    SOPHIA_MAIL_RUNTIME.InboxWorkerRunning =
        true

    SOPHIA_MAIL_RUNTIME.InboxStatus =
        "Watching for new mail..."

    GAG2PremiumRefreshControlUI()

    task.spawn(function()
        while SOPHIA_MAIL_STATE.AutoClaim == true
        and SOPHIA_MAIL_RUNTIME.InboxWorkerToken == token
        do
            GAG2PremiumClaimInbox(
                false
            )

            if SOPHIA_MAIL_STATE.AutoClaim ~= true
            or SOPHIA_MAIL_RUNTIME.InboxWorkerToken ~= token
            then
                break
            end

            local _, interval =
                GAG2PremiumNormalizeInboxInterval(
                    SOPHIA_MAIL_STATE.InboxInterval
                )

            local deadline =
                os.clock()
                + interval

            while SOPHIA_MAIL_STATE.AutoClaim == true
            and SOPHIA_MAIL_RUNTIME.InboxWorkerToken == token
            and os.clock() < deadline
            do
                task.wait(
                    math.min(
                        0.1,
                        math.max(
                            0,
                            deadline - os.clock()
                        )
                    )
                )
            end
        end

        if SOPHIA_MAIL_RUNTIME.InboxWorkerToken == token then
            SOPHIA_MAIL_RUNTIME.InboxWorkerRunning =
                false
        end
    end)

    return true
end

function GAG2PremiumSetAutoClaim(value)
    local enabled =
        value == true

    SOPHIA_MAIL_STATE.AutoClaim =
        enabled

    SOPHIA_MAIL_RUNTIME.InboxLastError =
        ""

    if enabled == true then
        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Watching for new mail..."

        GAG2PremiumStartInboxWorker()
    else
        GAG2PremiumStopInboxWorker()

        SOPHIA_MAIL_RUNTIME.InboxStatus =
            "Auto Claim is off"
    end

    GAG2PremiumSaveSettings()
    GAG2PremiumRefreshControlUI()

    return enabled
end

GAG2PremiumPrepareAccountFiles()
GAG2PremiumLoadSettings()
GAG2PremiumHistoryLoad()

function GAG2PremiumCreateHud()
    if typeof(SOPHIA_MAIL_RUNTIME.Gui) == "Instance"
        and SOPHIA_MAIL_RUNTIME.Gui.Parent ~= nil
    then
        return true
    end

    local player =
        LocalPlayer

    local playerGui =
        player:WaitForChild("PlayerGui")

    local oldGui =
        playerGui:FindFirstChild("GAG2PremiumV7")

    if oldGui then
        oldGui:Destroy()
    end

    GAG2PremiumCheckDay()

    local DAILY_LIMIT =
        SOPHIA_MAIL_DAILY_LIMIT

    local BATCH_LIMIT =
        SOPHIA_MAIL_BATCH_LIMIT

    local COOLDOWN =
        SOPHIA_MAIL_COOLDOWN

    local tracker = {
        Used =
            SOPHIA_MAIL_STATE.TrackerUsed,
    }

    local TweenService =
        GAG2PremiumTweenService

    local color =
        SOPHIA_MAIL_THEME

    local function create(
        className,
        properties,
        parent
    )
        local object =
            Instance.new(className)

        if object:IsA(
            "GuiObject"
        ) then
            object.BorderSizePixel =
                0
        end

        for property, value in pairs(
            properties or {}
        ) do
            object[property] =
                value
        end

        object.Parent =
            parent

        return object
    end

    local function round(
        object,
        radius
    )
        return create(
            "UICorner",
            {
                CornerRadius =
                    UDim.new(
                        0,
                        radius or 12
                    ),
            },
            object
        )
    end

    local function outline(
        object,
        chosenColor
    )
        return create(
            "UIStroke",
            {
                Color =
                    chosenColor
                        or color.Border,

                Thickness =
                    1.15,

                Transparency =
                    0.18,

                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,

                LineJoinMode =
                    Enum.LineJoinMode.Round,
            },
            object
        )
    end

    local function text(
        parent,
        value,
        size,
        position,
        textSize,
        chosenColor,
        alignment,
        font
    )
        local requestedTextSize =
            math.floor(
                (
                    tonumber(textSize)
                    or 13
                )
                + 0.5
            )

        local minimumTextSize =
            (
                font == Enum.Font.GothamBold
                or font == Enum.Font.GothamSemibold
            )
                and 12
                or 11

        return create(
            "TextLabel",
            {
                BackgroundTransparency =
                    1,

                Text =
                    value or "",

                Size =
                    size,

                Position =
                    position,

                TextSize =
                    math.max(
                        requestedTextSize,
                        minimumTextSize
                    ),

                TextColor3 =
                    chosenColor
                        or color.Text,

                TextXAlignment =
                    alignment
                        or Enum.TextXAlignment.Left,

                TextYAlignment =
                    Enum.TextYAlignment.Center,

                TextTruncate =
                    Enum.TextTruncate.AtEnd,

                TextStrokeTransparency =
                    1,

                Font =
                    font
                        or Enum.Font.GothamMedium,
            },
            parent
        )
    end

    local function button(
        parent,
        value,
        size,
        position,
        bright
    )
        local object =
            create(
                "TextButton",
                {
                    AutoButtonColor =
                        false,

                    BackgroundColor3 =
                        bright
                            and color.Accent
                            or color.Field,

                    TextColor3 =
                        color.Text,

                    Text =
                        value,

                    Size =
                        size,

                    Position =
                        position,

                    TextSize =
                        13,

                    TextStrokeTransparency =
                        1,

                    Font =
                        Enum.Font.GothamSemibold,
                },
                parent
            )

        round(
            object,
            12
        )

        outline(
            object,
            bright
                    and color.AccentBright
                or color.Border
        )

        return object
    end

    local function box(
        parent,
        placeholder,
        size,
        position
    )
        local object =
            create(
                "TextBox",
                {
                    BackgroundColor3 =
                        color.Field,

                    TextColor3 =
                        color.Text,

                    PlaceholderColor3 =
                        color.Muted,

                    PlaceholderText =
                        placeholder,

                    Text =
                        "",

                    ClearTextOnFocus =
                        false,

                    Size =
                        size,

                    Position =
                        position,

                    TextSize =
                        13,

                    TextStrokeTransparency =
                        1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    Font =
                        Enum.Font.GothamMedium,
                },
                parent
            )

        round(
            object,
            12
        )

        outline(object)

        create(
            "UIPadding",
            {
                PaddingLeft =
                    UDim.new(0, 12),

                PaddingRight =
                    UDim.new(0, 10),
            },
            object
        )

        return object
    end

    local function card(
        parent,
        size,
        position
    )
        local object =
            create(
                "Frame",
                {
                    BackgroundColor3 =
                        color.Card,

                    Size =
                        size,

                    Position =
                        position,
                },
                parent
            )

        round(
            object,
            16
        )

        outline(
            object,
            color.Border
        )

        return object
    end

    local gui =
        create(
            "ScreenGui",
            {
                Name =
                    "GAG2PremiumV7",

                ResetOnSpawn =
                    false,

                IgnoreGuiInset =
                    true,

                DisplayOrder =
                    999999,

                ZIndexBehavior =
                    Enum.ZIndexBehavior.Sibling,
            },
            playerGui
        )

    SOPHIA_MAIL_RUNTIME.Gui =
        gui

    local window =
        create(
            "Frame",
            {
                AnchorPoint =
                    Vector2.new(0.5, 0.5),

                Position =
                    GAG2PremiumReadPosition(),

                Size =
                    UDim2.fromOffset(
                        920,
                        700
                    ),

                BackgroundColor3 =
                    color.Back,

                Active =
                    true,

                InputSink =
                    Enum.InputSink.All,

                Selectable =
                    false,

                ClipsDescendants =
                    true,
            },
            gui
        )

    SOPHIA_MAIL_RUNTIME.Window =
        window

    round(
        window,
        20
    )

    outline(window)

    create(
        "UIGradient",
        {
            Color =
                ColorSequence.new({
                    ColorSequenceKeypoint.new(
                        0,
                        Color3.fromRGB(
                            34,
                            12,
                            18
                        )
                    ),
                    ColorSequenceKeypoint.new(
                        1,
                        color.Back
                    ),
                }),

            Rotation =
                115,
        },
        window
    )

    local windowScale =
        create(
            "UIScale",
            {
                Scale =
                    1,
            },
            window
        )

    local responsiveScale =
        1

    local function applyHudScale()
        local _,
            selectedScale =
            GAG2PremiumNormalizeScale(
                SOPHIA_MAIL_STATE.HudScale
                or "100%"
            )

        windowScale.Scale =
            responsiveScale
            * selectedScale

        return true
    end

    SOPHIA_MAIL_RUNTIME.ApplyScale =
        applyHudScale

    local function resize()
        local camera =
            workspace.CurrentCamera

        local viewport =
            camera
                and camera.ViewportSize
                or Vector2.new(
                    1920,
                    1080
                )

        responsiveScale =
            math.clamp(
                math.min(
                    viewport.X / 980,
                    viewport.Y / 770
                ),
                0.62,
                1
            )

        applyHudScale()
    end

    resize()

    if workspace.CurrentCamera then
        workspace.CurrentCamera
            :GetPropertyChangedSignal(
                "ViewportSize"
            )
            :Connect(resize)
    end

    local header =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Header,

                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        64
                    ),
            },
            window
        )

    create(
        "UIGradient",
        {
            Color =
                ColorSequence.new({
                    ColorSequenceKeypoint.new(
                        0,
                        Color3.fromRGB(
                            190,
                            32,
                            58
                        )
                    ),
                    ColorSequenceKeypoint.new(
                        1,
                        color.Header
                    ),
                }),

            Rotation =
                0,
        },
        header
    )

    local logo =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Accent,

                Size =
                    UDim2.fromOffset(
                        40,
                        40
                    ),

                Position =
                    UDim2.fromOffset(
                        16,
                        12
                    ),
            },
            header
        )

    round(
        logo,
        12
    )

    text(
        logo,
        "S",
        UDim2.fromScale(1, 1),
        UDim2.fromOffset(0, 0),
        19,
        color.White,
        Enum.TextXAlignment.Center,
        Enum.Font.GothamBold
    )

    local title =
        text(
            header,
            "SOPHIA Mail",
            UDim2.fromOffset(
                190,
                25
            ),
            UDim2.fromOffset(
                69,
                8
            ),
            21,
            color.Text,
            nil,
            Enum.Font.GothamBold
        )

    local subtitle =
        text(
            header,
            "Send fruits by value",
            UDim2.fromOffset(
                240,
                20
            ),
            UDim2.fromOffset(
                69,
                34
            ),
            13,
            color.Secondary,
            nil,
            Enum.Font.GothamMedium
        )

    local quotaFrame =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Card,

                Size =
                    UDim2.fromOffset(
                        150,
                        38
                    ),

                Position =
                    UDim2.new(
                        1,
                        -360,
                        0,
                        13
                    ),
            },
            header
        )

    round(
        quotaFrame,
        12
    )

    outline(quotaFrame)

    local quotaText =
        text(
            quotaFrame,
            "0 / 50 sends today",
            UDim2.fromScale(1, 1),
            UDim2.fromOffset(0, 0),
            11,
            color.Text,
            Enum.TextXAlignment.Center,
            Enum.Font.GothamSemibold
        )

    local statusFrame =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Card,

                Size =
                    UDim2.fromOffset(
                        108,
                        38
                    ),

                Position =
                    UDim2.new(
                        1,
                        -200,
                        0,
                        13
                    ),
            },
            header
        )

    round(
        statusFrame,
        12
    )

    outline(statusFrame)

    local statusDot =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Yellow,

                Size =
                    UDim2.fromOffset(
                        7,
                        7
                    ),

                Position =
                    UDim2.fromOffset(
                        12,
                        16
                    ),
            },
            statusFrame
        )

    round(
        statusDot,
        7
    )

    local statusText =
        text(
            statusFrame,
            "Loading",
            UDim2.fromOffset(
                78,
                28
            ),
            UDim2.fromOffset(
                26,
                5
            ),
            11,
            color.Text,
            nil,
            Enum.Font.GothamSemibold
        )

    local minimizeButton =
        button(
            header,
            "-",
            UDim2.fromOffset(
                40,
                40
            ),
            UDim2.new(
                1,
                -88,
                0,
                12
            ),
            false
        )

    local closeButton =
        button(
            header,
            "X",
            UDim2.fromOffset(
                40,
                40
            ),
            UDim2.new(
                1,
                -44,
                0,
                12
            ),
            false
        )

    minimizeButton.TextSize =
        21

    closeButton.TextSize =
        16

    local footerBar =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Header,

                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        34
                    ),

                Position =
                    UDim2.new(
                        0,
                        0,
                        1,
                        -34
                    ),

                ZIndex =
                    3,
            },
            window
        )

    create(
        "Frame",
        {
            BackgroundColor3 =
                color.Accent,

            BackgroundTransparency =
                0.45,

            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    1
                ),
        },
        footerBar
    )

    text(
        footerBar,
        "Need support?",
        UDim2.fromOffset(
            96,
            34
        ),
        UDim2.fromOffset(
            14,
            0
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamMedium
    )

    local footerDiscordLink =
        create(
            "TextButton",
            {
                AutoButtonColor =
                    false,

                BackgroundTransparency =
                    1,

                Text =
                    "Join the Discord",

                Size =
                    UDim2.fromOffset(
                        130,
                        34
                    ),

                Position =
                    UDim2.fromOffset(
                        112,
                        0
                    ),

                TextSize =
                    12,

                TextColor3 =
                    color.AccentBright,

                Font =
                    Enum.Font.GothamBold,

                TextStrokeTransparency =
                    1,

                ZIndex =
                    4,
            },
            footerBar
        )

    footerDiscordLink.MouseEnter:Connect(function()
        TweenService:Create(
            footerDiscordLink,
            TweenInfo.new(0.08),
            {
                TextColor3 =
                    color.White,
            }
        ):Play()
    end)

    footerDiscordLink.MouseLeave:Connect(function()
        TweenService:Create(
            footerDiscordLink,
            TweenInfo.new(0.08),
            {
                TextColor3 =
                    color.AccentBright,
            }
        ):Play()
    end)

    footerDiscordLink.MouseButton1Click:Connect(
        GAG2PremiumOpenDiscordLink
    )

    local content =
        create(
            "Frame",
            {
                BackgroundTransparency =
                    1,

                Size =
                    UDim2.fromOffset(
                        896,
                        514
                    ),

                Position =
                    UDim2.fromOffset(
                        12,
                        144
                    ),
            },
            window
        )

    local routeCard =
        card(
            content,
            UDim2.fromOffset(
                430,
                212
            ),
            UDim2.fromOffset(
                0,
                0
            )
        )

    local routeCount =
        text(
            routeCard,
            "RECIPIENTS · 0 ADDED",
            UDim2.fromOffset(
                218,
                20
            ),
            UDim2.fromOffset(
                14,
                9
            ),
            11,
            color.Secondary,
            nil,
            Enum.Font.GothamBold
        )

    local clearButton =
        button(
            routeCard,
            "Clear",
            UDim2.fromOffset(
                62,
                29
            ),
            UDim2.new(
                1,
                -76,
                0,
                4
            ),
            false
        )

    clearButton.TextSize =
        12

    clearButton.TextColor3 =
        color.Muted

    clearButton.Visible =
        false

    local recipientBox =
        box(
            routeCard,
            "Username or User ID",
            UDim2.fromOffset(
                205,
                40
            ),
            UDim2.fromOffset(
                14,
                35
            )
        )

    local valueBox =
        box(
            routeCard,
            "$100M",
            UDim2.fromOffset(
                94,
                40
            ),
            UDim2.fromOffset(
                226,
                35
            )
        )

    local addButton =
        button(
            routeCard,
            "+ Add",
            UDim2.fromOffset(
                88,
                40
            ),
            UDim2.fromOffset(
                328,
                35
            ),
            true
        )

    local routeList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency =
                    1,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        0,
                        123
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        82
                    ),

                CanvasSize =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                ScrollBarThickness =
                    3,

                ScrollBarImageColor3 =
                    color.Border,
            },
            routeCard
        )

    local routeLayout =
        create(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        5
                    ),
            },
            routeList
        )

    local ruleCard =
        card(
            content,
            UDim2.fromOffset(
                454,
                212
            ),
            UDim2.fromOffset(
                442,
                0
            )
        )

    text(
        ruleCard,
        "SEND OPTIONS",
        UDim2.fromOffset(
            160,
            20
        ),
        UDim2.fromOffset(
            14,
            9
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local inventoryText =
        text(
            ruleCard,
            "Not calculated",
            UDim2.fromOffset(
                220,
                20
            ),
            UDim2.new(
                1,
                -234,
                0,
                9
            ),
            10,
            color.Muted,
            Enum.TextXAlignment.Right
        )

    local strategyButton =
        button(
            ruleCard,
            "Send at least",
            UDim2.fromOffset(
                208,
                40
            ),
            UDim2.fromOffset(
                14,
                38
            ),
            false
        )

    local favoriteButton =
        button(
            ruleCard,
            "Skip favorites: ON",
            UDim2.fromOffset(
                210,
                40
            ),
            UDim2.fromOffset(
                230,
                38
            ),
            false
        )

    local fruitsButton =
        button(
            ruleCard,
            "Fruits: All",
            UDim2.fromOffset(
                208,
                40
            ),
            UDim2.fromOffset(
                14,
                87
            ),
            false
        )

    fruitsButton.Active =
        true

    fruitsButton.AutoButtonColor =
        true

    fruitsButton.TextSize =
        12

    local calculateButton =
        button(
            ruleCard,
            "Refresh preview",
            UDim2.fromOffset(
                210,
                40
            ),
            UDim2.fromOffset(
                230,
                87
            ),
            true
        )

    local ruleInfo =
        text(
            ruleCard,
            "Add as many people as you want. Each send can hold up to 20 fruits.",
            UDim2.new(
                1,
                -28,
                0,
                52
            ),
            UDim2.fromOffset(
                14,
                145
            ),
            10,
            color.Muted
        )

    ruleInfo.TextWrapped =
        true

    local previewCard =
        card(
            content,
            UDim2.fromOffset(
                594,
                324
            ),
            UDim2.fromOffset(
                0,
                224
            )
        )

    text(
        previewCard,
        "PREVIEW",
        UDim2.fromOffset(
            180,
            20
        ),
        UDim2.fromOffset(
            14,
            9
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local previewCount =
        text(
            previewCard,
            "No route",
            UDim2.fromOffset(
                220,
                20
            ),
            UDim2.new(
                1,
                -234,
                0,
                9
            ),
            10,
            color.Muted,
            Enum.TextXAlignment.Right
        )

    local previewList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency =
                    1,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        1,
                        -42
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        35
                    ),

                CanvasSize =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                ScrollBarThickness =
                    3,

                ScrollBarImageColor3 =
                    color.Border,
            },
            previewCard
        )

    local previewLayout =
        create(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        6
                    ),
            },
            previewList
        )

    local summaryCard =
        card(
            content,
            UDim2.fromOffset(
                290,
                324
            ),
            UDim2.fromOffset(
                606,
                224
            )
        )

    text(
        summaryCard,
        "SUMMARY",
        UDim2.fromOffset(
            160,
            22
        ),
        UDim2.fromOffset(
            14,
            9
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamBold
    )

    text(
        summaryCard,
        "People",
        UDim2.fromOffset(
            150,
            20
        ),
        UDim2.fromOffset(
            14,
            38
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamMedium
    )

    local summaryPeopleValue =
        text(
            summaryCard,
            "0",
            UDim2.fromOffset(
                96,
                20
            ),
            UDim2.new(
                1,
                -110,
                0,
                38
            ),
            12,
            color.Text,
            Enum.TextXAlignment.Right,
            Enum.Font.GothamSemibold
        )

    text(
        summaryCard,
        "Sends",
        UDim2.fromOffset(
            150,
            20
        ),
        UDim2.fromOffset(
            14,
            63
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamMedium
    )

    local summarySendsValue =
        text(
            summaryCard,
            "0",
            UDim2.fromOffset(
                96,
                20
            ),
            UDim2.new(
                1,
                -110,
                0,
                63
            ),
            12,
            color.Text,
            Enum.TextXAlignment.Right,
            Enum.Font.GothamSemibold
        )

    text(
        summaryCard,
        "Fruits",
        UDim2.fromOffset(
            150,
            20
        ),
        UDim2.fromOffset(
            14,
            88
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamMedium
    )

    local summaryFruitsValue =
        text(
            summaryCard,
            "0",
            UDim2.fromOffset(
                96,
                20
            ),
            UDim2.new(
                1,
                -110,
                0,
                88
            ),
            12,
            color.Text,
            Enum.TextXAlignment.Right,
            Enum.Font.GothamSemibold
        )

    create(
        "Frame",
        {
            BackgroundColor3 =
                color.Border,

            BackgroundTransparency =
                0.25,

            Size =
                UDim2.new(
                    1,
                    -28,
                    0,
                    1
                ),

            Position =
                UDim2.fromOffset(
                    14,
                    116
                ),
        },
        summaryCard
    )

    text(
        summaryCard,
        "Total value",
        UDim2.fromOffset(
            150,
            24
        ),
        UDim2.fromOffset(
            14,
            125
        ),
        13,
        color.Text,
        nil,
        Enum.Font.GothamSemibold
    )

    local summaryTotalValue =
        text(
            summaryCard,
            "$0",
            UDim2.fromOffset(
                130,
                28
            ),
            UDim2.new(
                1,
                -144,
                0,
                122
            ),
            17,
            color.Accent,
            Enum.TextXAlignment.Right,
            Enum.Font.GothamBold
        )

    text(
        summaryCard,
        "Estimated time",
        UDim2.fromOffset(
            150,
            22
        ),
        UDim2.fromOffset(
            14,
            155
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamMedium
    )

    local summaryTimeValue =
        text(
            summaryCard,
            "Immediate",
            UDim2.fromOffset(
                130,
                22
            ),
            UDim2.new(
                1,
                -144,
                0,
                155
            ),
            12,
            color.Text,
            Enum.TextXAlignment.Right,
            Enum.Font.GothamSemibold
        )

    local summaryMessageBox =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Field,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        0,
                        43
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        185
                    ),
            },
            summaryCard
        )

    round(
        summaryMessageBox,
        11
    )

    outline(
        summaryMessageBox,
        color.Border
    )

    local messageText =
        text(
            summaryMessageBox,
            "Add a recipient and target.",
            UDim2.new(
                1,
                -20,
                1,
                0
            ),
            UDim2.fromOffset(
                10,
                0
            ),
            11,
            color.Secondary,
            Enum.TextXAlignment.Center,
            Enum.Font.GothamMedium
        )

    messageText.TextWrapped =
        true

    local progressTrack =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Hover,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        0,
                        6
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        237
                    ),
            },
            summaryCard
        )

    round(
        progressTrack,
        3
    )

    local progressFill =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Accent,

                Size =
                    UDim2.fromScale(
                        0,
                        1
                    ),
            },
            progressTrack
        )

    round(
        progressFill,
        3
    )

    local sendButton =
        button(
            summaryCard,
            "Review and send",
            UDim2.new(
                1,
                -28,
                0,
                58
            ),
            UDim2.fromOffset(
                14,
                252
            ),
            true
        )

    sendButton.TextSize =
        14

    local overlay =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    Color3.new(
                        0,
                        0,
                        0
                    ),

                BackgroundTransparency =
                    0.2,

                Active =
                    true,

                InputSink =
                    Enum.InputSink.All,

                Selectable =
                    false,

                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                Visible =
                    false,

                ZIndex =
                    50,
            },
            window
        )

    local state = {
        Recipients = {},
        Inventory = {},
        Plan = {},

        Strategy =
            GAG2PremiumNormalizeValueStrategy(
                SOPHIA_MAIL_STATE.ValueStrategy
            ),

        ExtraLimitMode =
            GAG2PremiumNormalizeExtraLimitMode(
                SOPHIA_MAIL_STATE.ExtraLimitMode
            ),

        ExtraLimitCustom =
            GAG2PremiumNormalizeExtraLimitCustom(
                SOPHIA_MAIL_STATE.ExtraLimitCustom
            ),

        Protect = true,

        Editing = nil,
        Busy = false,
        Running = false,
        Stop = false,

        LastAccepted = nil,

        Safety = {},

        Filters = {
            Fruits =
                GAG2PremiumFilterSelectionMap(
                    SOPHIA_MAIL_STATE.FilterFruits
                ),

            Mutations =
                GAG2PremiumFilterSelectionMap(
                    SOPHIA_MAIL_STATE.FilterMutations
                ),
        },

        SavedRecipients = {
            Records =
                GAG2PremiumNormalizeRecipientRecords(
                    SOPHIA_MAIL_STATE.SavedRecipients,
                    25,
                    true
                ),

            Recent =
                GAG2PremiumNormalizeRecipientRecords(
                    SOPHIA_MAIL_STATE.RecentRecipients,
                    8,
                    false
                ),

            ValueButton =
                nil,

            ItemButton =
                nil,
        },

        Fleet = {
            Accounts =
                GAG2PremiumNormalizeFleetAccounts(
                    SOPHIA_MAIL_STATE.FleetAccounts
                ),

            Groups =
                GAG2PremiumNormalizeFleetGroups(
                    SOPHIA_MAIL_STATE.FleetGroups
                ),

            ActiveGroup =
                "All",

            Search =
                "",

            EditUserId =
                nil,

            EditOriginalName =
                "",

            ImportBusy =
                false,

            ImportDraft =
                {},

            LoadedGroup =
                nil,
        },

        ValueSession =
            nil,

        ExactSession =
            nil,

        Minimized =
            SOPHIA_MAIL_STATE.StartMinimized == true,
    }

    SOPHIA_MAIL_RUNTIME.DeliveryState =
        state

    state.RecipientChangesLocked =
        function()
            if state.Running
                or state.Busy
            then
                return true
            end

            if type(
                state.ValueSession
            ) == "table"
                and state.ValueSession.Status
                    ~= "Complete"
            then
                return true
            end

            if type(
                state.ExactSession
            ) == "table"
                and state.ExactSession.Status
                    ~= "Complete"
            then
                return true
            end

            return false
        end

    state.SavedRecipients.ValueButton =
        button(
            routeCard,
            "★ Saved 0",
            UDim2.fromOffset(
                104,
                29
            ),
            UDim2.fromOffset(
                242,
                4
            ),
            false
        )

    state.SavedRecipients.ValueButton.TextSize =
        13

    state.SavedRecipients.ValueButton.TextColor3 =
        color.Text

    state.SavedRecipients.UpdateButtons =
        function()
            local count =
                #GAG2PremiumNormalizeRecipientRecords(
                    SOPHIA_MAIL_STATE.SavedRecipients,
                    25,
                    true
                )

            local caption =
                "★ Saved "
                .. tostring(
                    count
                )

            if typeof(
                state.SavedRecipients.ValueButton
            ) == "Instance" then
                state.SavedRecipients.ValueButton.Text =
                    caption

                state.SavedRecipients.ValueButton.TextColor3 =
                    color.Text

                state.SavedRecipients.ValueButton.BackgroundColor3 =
                    count > 0
                        and color.Hover
                        or color.Field

                local savedStroke =
                    state.SavedRecipients.ValueButton:FindFirstChildOfClass(
                        "UIStroke"
                    )

                if savedStroke then
                    savedStroke.Color =
                        count > 0
                            and color.Accent
                            or color.Border

                    savedStroke.Transparency =
                        count > 0
                            and 0.05
                            or 0.18

                    savedStroke.Thickness =
                        count > 0
                            and 1.35
                            or 1.15
                end
            end

            if typeof(
                state.SavedRecipients.ItemButton
            ) == "Instance" then
                state.SavedRecipients.ItemButton.Text =
                    caption

                state.SavedRecipients.ItemButton.TextColor3 =
                    color.Text

                state.SavedRecipients.ItemButton.BackgroundColor3 =
                    count > 0
                        and color.Hover
                        or color.Field

                local savedStroke =
                    state.SavedRecipients.ItemButton:FindFirstChildOfClass(
                        "UIStroke"
                    )

                if savedStroke then
                    savedStroke.Color =
                        count > 0
                            and color.Accent
                            or color.Border

                    savedStroke.Transparency =
                        count > 0
                            and 0.05
                            or 0.18

                    savedStroke.Thickness =
                        count > 0
                            and 1.35
                            or 1.15
                end
            end
        end

    state.SavedRecipients.UpdateButtons()

    local function setStatus(
        value,
        dotColor
    )
        statusText.Text =
            value

        statusDot.BackgroundColor3 =
            dotColor
                or color.Green

        SOPHIA_MAIL_RUNTIME.Status =
            tostring(
                value or "Ready"
            )

        GAG2PremiumRefreshControlUI()
    end

    local function updateQuota()
        GAG2PremiumCheckDay()

        tracker.Used =
            math.clamp(
                math.floor(
                    tonumber(
                        SOPHIA_MAIL_STATE.TrackerUsed
                    )
                        or tracker.Used
                        or 0
                ),
                0,
                DAILY_LIMIT
            )

        SOPHIA_MAIL_STATE.TrackerUsed =
            tracker.Used

        quotaText.Text =
            state.Minimized
                    and string.format(
                        "%d/%d",
                        tracker.Used,
                        DAILY_LIMIT
                    )
                or string.format(
                    "%d / %d used here",
                    tracker.Used,
                    DAILY_LIMIT
                )

        GAG2PremiumRefreshControlUI()
    end

    SOPHIA_MAIL_RUNTIME.UpdateQuota =
        updateQuota

    local function reportError(
        where,
        err
    )
        local result =
            tostring(where)
            .. ": "
            .. tostring(err)

        SOPHIA_MAIL_RUNTIME.LastError =
            result

        warn(
            "[GAG 2 Premiumer] "
                .. result
        )

        setStatus(
            "Error",
            color.Red
        )

        messageText.Text =
            "Something went wrong. The error was copied."

        messageText.TextColor3 =
            color.Red

        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(result)
            end
        end)
    end

    local function protectedCall(
        where,
        callback
    )
        local ok, err =
            xpcall(
                callback,
                function(value)
                    local trace =
                        ""

                    pcall(function()
                        trace =
                            debug.traceback()
                    end)

                    return tostring(value)
                        .. (
                            trace ~= ""
                                and "\n" .. trace
                                or ""
                        )
                end
            )

        if not ok then
            reportError(
                where,
                err
            )
        end

        return ok
    end

    local function formatValue(value)
        value =
            math.max(
                0,
                tonumber(value)
                    or 0
            )

        if type(SophiaVisualFormatTotalFruitValue) == "function" then
            local ok, result =
                pcall(
                    SophiaVisualFormatTotalFruitValue,
                    value
                )

            if ok
                and type(result) == "string"
            then
                return result
            end
        end

        if value >= 1e15 then
            return "$"
                .. string.format(
                    "%.2fQa",
                    value / 1e15
                )
        elseif value >= 1e12 then
            return "$"
                .. string.format(
                    "%.2fT",
                    value / 1e12
                )
        elseif value >= 1e9 then
            return "$"
                .. string.format(
                    "%.2fB",
                    value / 1e9
                )
        elseif value >= 1e6 then
            return "$"
                .. string.format(
                    "%.2fM",
                    value / 1e6
                )
        elseif value >= 1e3 then
            return "$"
                .. string.format(
                    "%.1fK",
                    value / 1e3
                )
        end

        return "$"
            .. tostring(
                math.floor(value + 0.5)
            )
    end

    local function parseValue(value)
        local raw =
            tostring(value or "")
                :lower()
                :gsub("[$,%s]", "")

        local number =
            tonumber(
                raw:match("[%d%.]+")
            )

        if not number then
            return nil
        end

        if raw:find(
            "qa",
            1,
            true
        ) then
            number *= 1e15
        elseif raw:find(
            "t",
            1,
            true
        ) then
            number *= 1e12
        elseif raw:find(
            "b",
            1,
            true
        ) then
            number *= 1e9
        elseif raw:find(
            "m",
            1,
            true
        ) then
            number *= 1e6
        elseif raw:find(
            "k",
            1,
            true
        ) then
            number *= 1e3
        end

        number =
            math.floor(
                number + 0.5
            )

        return number > 0
                and number
            or nil
    end

    local function getRoots()
        local roots = {}

        if player.Character then
            table.insert(
                roots,
                player.Character
            )
        end

        local backpack =
            player:FindFirstChildOfClass(
                "Backpack"
            )

        if backpack then
            table.insert(
                roots,
                backpack
            )
        end

        return roots
    end

    local valueData

    local function simpleKey(value)
        return tostring(value or "")
            :lower()
            :gsub("[%s%p_]", "")
    end

    local function loadValueData()
        if valueData then
            return valueData
        end

        valueData = {
            Calculator = nil,
            Prices = {},
            Mutations = {},
        }

        local shared =
            ReplicatedStorage:FindFirstChild(
                "SharedModules"
            )

        if not shared then
            return valueData
        end

        local calculatorModule =
            shared:FindFirstChild(
                "FruitValueCalc"
            )

        if calculatorModule
            and calculatorModule:IsA("ModuleScript")
        then
            local ok, result =
                pcall(
                    require,
                    calculatorModule
                )

            if ok then
                if type(result) == "function" then
                    valueData.Calculator =
                        result
                elseif type(result) == "table" then
                    valueData.Calculator =
                        result.Calculate
                        or result.GetValue
                        or result.GetFruitValue
                        or result.Value
                end
            end
        end

        local priceModule =
            shared:FindFirstChild(
                "SellValueData"
            )

        if priceModule
            and priceModule:IsA("ModuleScript")
        then
            local ok, result =
                pcall(
                    require,
                    priceModule
                )

            if ok
                and type(result) == "table"
            then
                for fruitName, price in pairs(result) do
                    if tonumber(price) then
                        valueData.Prices[
                            simpleKey(fruitName)
                        ] =
                            tonumber(price)
                    end
                end
            end
        end

        local mutationFolder =
            shared:FindFirstChild(
                "MutationData"
            )

        if mutationFolder then
            for _, module in ipairs(
                mutationFolder:GetChildren()
            ) do
                if module:IsA("ModuleScript") then
                    local ok, result =
                        pcall(
                            require,
                            module
                        )

                    if ok
                        and type(result) == "table"
                    then
                        local multiplier =
                            tonumber(
                                result.PriceMultiplier
                                or result.SellMultiplier
                                or result.ValueMultiplier
                                or result.Multiplier
                                or result.Boost
                            )

                        if multiplier
                            and multiplier > 0
                        then
                            valueData.Mutations[
                                simpleKey(module.Name)
                            ] =
                                multiplier
                        end
                    end
                end
            end
        end

        return valueData
    end

    local function fallbackFruitValue(item)
        local name =
            tostring(
                item:GetAttribute("FruitName")
                or item:GetAttribute("Fruit")
                or item:GetAttribute("ItemName")
                or item.Name
            )

        name =
            name
                :gsub("%s*%b[]", "")
                :gsub("%s*%b()", "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        local mutation =
            tostring(
                item:GetAttribute("Mutation")
                or item:GetAttribute("Mutations")
                or item:GetAttribute("Variant")
                or ""
            )

        if mutation == "" then
            for bracket in tostring(item.Name):gmatch(
                "%[([^%]]+)%]"
            ) do
                if not bracket
                    :lower()
                    :find("kg", 1, true)
                then
                    mutation =
                        bracket

                    break
                end
            end
        end

        local size =
            tonumber(
                item:GetAttribute("SizeMultiplier")
                or item:GetAttribute("SizeMulti")
                or item:GetAttribute("ScaleMultiplier")
                or item:GetAttribute("ScaleMulti")
                or item:GetAttribute("Scale")
                or item:GetAttribute("Weight")
                or item:GetAttribute("WeightKg")
            )

        size =
            size
            or tonumber(
                tostring(item.Name):match(
                    "([%d%.]+)%s*[Kk][Gg]"
                )
            )
            or 1

        size =
            math.max(
                0.01,
                size
            )

        local data =
            loadValueData()

        local calculated

        if type(data.Calculator) == "function" then
            local attempts = {
                {
                    name,
                    size,
                    item,
                    item,
                    item,
                },

                {
                    name,
                    size,
                    item,
                },

                {
                    name,
                    size,
                },

                {
                    item,
                },
            }

            for _, arguments in ipairs(attempts) do
                local ok, result =
                    pcall(
                        data.Calculator,
                        table.unpack(arguments)
                    )

                if ok
                    and tonumber(result)
                    and tonumber(result) > 0
                then
                    calculated =
                        tonumber(result)

                    break
                end
            end
        end

        if not calculated then
            calculated =
                (
                    data.Prices[
                        simpleKey(name)
                    ] or 0
                )
                * size ^ 2.5
        end

        local multiplier =
            1

        for part in mutation:gmatch(
            "[^,%|/;]+"
        ) do
            multiplier *=
                data.Mutations[
                    simpleKey(part)
                ] or 1
        end

        calculated *=
            multiplier

        return calculated > 0
                and math.floor(
                    calculated + 0.5
                )
                or nil,
            name,
            mutation
    end

    local function valuePreviewFruitIcon(
        item,
        info
    )
        local candidates = {}

        if type(info) == "table" then
            table.insert(
                candidates,
                info.IMG
            )

            table.insert(
                candidates,
                info.Icon
            )

            table.insert(
                candidates,
                info.Image
            )

            table.insert(
                candidates,
                info.ImageId
            )

            table.insert(
                candidates,
                info.FruitImage
            )

            table.insert(
                candidates,
                info.FruitIcon
            )

            table.insert(
                candidates,
                info.TextureId
            )
        end

        if typeof(item) == "Instance" then
            table.insert(
                candidates,
                item:GetAttribute("IMG")
            )

            table.insert(
                candidates,
                item:GetAttribute("Icon")
            )

            table.insert(
                candidates,
                item:GetAttribute("Image")
            )

            table.insert(
                candidates,
                item:GetAttribute("ImageId")
            )

            table.insert(
                candidates,
                item:GetAttribute("FruitImage")
            )

            table.insert(
                candidates,
                item:GetAttribute("FruitIcon")
            )

            table.insert(
                candidates,
                item:GetAttribute("TextureId")
            )

            if item:IsA("Tool") then
                table.insert(
                    candidates,
                    item.TextureId
                )
            end
        end

        for _, candidate in ipairs(
            candidates
        ) do
            local icon =
                GAG2PremiumHistoryNormalizeIcon(
                    candidate
                )

            if icon ~= "" then
                return icon
            end
        end

        if typeof(item) == "Instance" then
            for _, descendant in ipairs(
                item:GetDescendants()
            ) do
                local rawIcon

                if descendant:IsA("ImageLabel")
                    or descendant:IsA("ImageButton")
                then
                    rawIcon =
                        descendant.Image
                elseif descendant:IsA("Decal")
                    or descendant:IsA("Texture")
                then
                    rawIcon =
                        descendant.Texture
                end

                local icon =
                    GAG2PremiumHistoryNormalizeIcon(
                        rawIcon
                    )

                if icon ~= "" then
                    return icon
                end
            end
        end

        return ""
    end

    local function readFruit(item)
        if not (
            item:IsA("Tool")
            or item:IsA("Configuration")
        ) then
            return nil
        end

        if item:GetAttribute("HarvestedFruit") ~= true then
            return nil
        end

        local id =
            tostring(
                item:GetAttribute("Id")
                or item:GetAttribute("FruitId")
                or ""
            )

        if id == "" then
            return nil
        end

        local info
        local value
        local fallbackName
        local fallbackMutation

        if type(SophiaFruitAutomationReadToolInfo) == "function" then
            local ok, result =
                pcall(
                    SophiaFruitAutomationReadToolInfo,
                    item
                )

            if ok
                and type(result) == "table"
            then
                info =
                    result
            end
        end

        if info
            and type(SophiaFruitAutomationCalculateInfoValue) == "function"
        then
            local ok, result =
                pcall(
                    SophiaFruitAutomationCalculateInfoValue,
                    info
                )

            if ok then
                value =
                    tonumber(
                        result
                        or info.ValueNumber
                        or info.Value
                    )
            end
        end

        if not value
            and item:IsA("Tool")
            and type(SophiaVisualReadFruitTool) == "function"
        then
            local ok, result =
                pcall(
                    SophiaVisualReadFruitTool,
                    item,
                    0
                )

            if ok
                and type(result) == "table"
            then
                value =
                    tonumber(result.Value)

                info =
                    info or result
            end
        end

        value =
            value
            or tonumber(
                item:GetAttribute("Value")
                or item:GetAttribute("SellValue")
                or item:GetAttribute("Price")
            )

        if not value
            or value <= 0
        then
            value,
            fallbackName,
            fallbackMutation =
                fallbackFruitValue(item)
        end

        if not value
            or value <= 0
        then
            return nil
        end

        local name =
            tostring(
                (
                    info
                    and (
                        info.FruitName
                        or info.Name
                        or info.DisplayName
                    )
                )
                or item:GetAttribute("FruitName")
                or item:GetAttribute("ItemName")
                or fallbackName
                or item.Name
            )

        local mutation =
            tostring(
                (
                    info
                    and (
                        info.Mutation
                        or info.RawMutation
                    )
                )
                or item:GetAttribute("Mutation")
                or item:GetAttribute("Variant")
                or fallbackMutation
                or "Normal"
            )

        local favorite =
            item:GetAttribute("IsFavorite") == true
            or item:GetAttribute("Favorite") == true
            or item:GetAttribute("Favorited") == true
            or (
                info
                and (
                    info.IsFavorite == true
                    or info.Favorite == true
                )
            )

        return {
            Id =
                id,

            Item =
                item,

            Name =
                name,

            Mutation =
                mutation ~= ""
                    and mutation
                    or "Normal",

            Icon =
                valuePreviewFruitIcon(
                    item,
                    info
                ),

            Value =
                math.floor(
                    value + 0.5
                ),

            Favorite =
                favorite == true,
        }
    end

    local function scanInventory()
        local fruits = {}
        local seen = {}
        local unvalued = 0

        for _, root in ipairs(getRoots()) do
            for _, item in ipairs(
                root:GetChildren()
            ) do
                if (
                    item:IsA("Tool")
                    or item:IsA("Configuration")
                )
                    and item:GetAttribute("HarvestedFruit") == true
                then
                    local id =
                        tostring(
                            item:GetAttribute("Id")
                            or item:GetAttribute("FruitId")
                            or ""
                        )

                    if id ~= ""
                        and not seen[id]
                    then
                        seen[id] =
                            true

                        local fruit =
                            readFruit(item)

                        if fruit then
                            table.insert(
                                fruits,
                                fruit
                            )
                        else
                            unvalued +=
                                1
                        end
                    end
                end
            end
        end

        state.Inventory =
            fruits

        return fruits,
            unvalued
    end

    state.Filters.Matches =
        function(fruit)
            if type(fruit) ~= "table" then
                return false
            end

            local selectedFruits =
                state.Filters.Fruits

            if type(selectedFruits) == "table"
                and next(
                    selectedFruits
                ) ~= nil
            then
                local fruitKey =
                    GAG2PremiumFilterKey(
                        fruit.Name
                    )

                if selectedFruits[
                    fruitKey
                ] == nil then
                    return false
                end
            end

            local selectedMutations =
                state.Filters.Mutations

            if type(selectedMutations) == "table"
                and next(
                    selectedMutations
                ) ~= nil
            then
                local mutationText =
                    tostring(
                        fruit.Mutation
                        or "Normal"
                    )

                if GAG2PremiumFilterKey(
                    mutationText
                ) == "" then
                    mutationText =
                        "Normal"
                end

                local matched =
                    false

                for part in mutationText:gmatch(
                    "[^,%|/;]+"
                ) do
                    local mutationKey =
                        GAG2PremiumFilterKey(
                            part
                        )

                    if mutationKey ~= ""
                        and selectedMutations[
                            mutationKey
                        ] ~= nil
                    then
                        matched =
                            true

                        break
                    end
                end

                if not matched
                    and GAG2PremiumFilterKey(
                        mutationText
                    ) == "normal"
                    and selectedMutations.normal
                then
                    matched =
                        true
                end

                if not matched then
                    return false
                end
            end

            return true
        end

    state.Filters.UpdateButton =
        function()
            local fruitCount = 0
            local mutationCount = 0

            for _ in pairs(
                state.Filters.Fruits
                or {}
            ) do
                fruitCount +=
                    1
            end

            for _ in pairs(
                state.Filters.Mutations
                or {}
            ) do
                mutationCount +=
                    1
            end

            if fruitCount <= 0
                and mutationCount <= 0
            then
                fruitsButton.Text =
                    "Filters: All"
            elseif fruitCount > 0
                and mutationCount <= 0
            then
                fruitsButton.Text =
                    "Filters: "
                    .. tostring(
                        fruitCount
                    )
                    .. (
                        fruitCount == 1
                            and " fruit"
                            or " fruits"
                    )
            elseif fruitCount <= 0
                and mutationCount > 0
            then
                fruitsButton.Text =
                    "Filters: "
                    .. tostring(
                        mutationCount
                    )
                    .. (
                        mutationCount == 1
                            and " mutation"
                            or " mutations"
                    )
            else
                fruitsButton.Text =
                    "Filters: "
                    .. tostring(
                        fruitCount
                    )
                    .. " fruits · "
                    .. tostring(
                        mutationCount
                    )
                    .. " mutations"
            end
        end

    state.Filters.UpdateButton()

    local function clearRows(
        container,
        layout
    )
        for _, child in ipairs(
            container:GetChildren()
        ) do
            if child ~= layout
                and not child:IsA(
                    "UIPadding"
                )
            then
                child:Destroy()
            end
        end
    end

    local avatarCache = {}

    local function addAvatar(
        parent,
        userId,
        size,
        position
    )
        local avatar =
            create(
                "ImageLabel",
                {
                    BackgroundColor3 =
                        color.Hover,

                    BorderSizePixel =
                        0,

                    Image =
                        avatarCache[userId]
                            or "",

                    Size =
                        size,

                    Position =
                        position,

                    ScaleType =
                        Enum.ScaleType.Crop,
                },
                parent
            )

        round(
            avatar,
            999
        )

        if avatar.Image == "" then
            task.spawn(function()
                local ok, image =
                    pcall(
                        Players.GetUserThumbnailAsync,
                        Players,
                        userId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )

                if ok
                    and type(image) == "string"
                then
                    avatarCache[userId] =
                        image

                    if avatar.Parent then
                        avatar.Image =
                            image
                    end
                end
            end)
        end

        return avatar
    end

    local rebuildPlan
    local showFruitPreview

    local function formatSignedMailValue(
        value
    )
        value =
            tonumber(value)
            or 0

        local prefix =
            value > 0
                and "+"
                or value < 0
                    and "-"
                    or ""

        return prefix
            .. formatValue(
                math.abs(value)
            )
    end

    local function formatSignedMailPercent(
        value
    )
        value =
            tonumber(value)
            or 0

        local prefix =
            value > 0
                and "+"
                or value < 0
                    and "-"
                    or ""

        return prefix
            .. string.format(
                "%.1f%%",
                math.abs(value)
            )
    end

    local function extraLimitCaption()
        local mode =
            GAG2PremiumNormalizeExtraLimitMode(
                state.ExtraLimitMode
            )

        if mode == "No limit" then
            return "No limit"
        end

        local value =
            mode == "Custom"
            and GAG2PremiumNormalizeExtraLimitCustom(
                state.ExtraLimitCustom
            )
            or mode

        if value:sub(1, 1) == "+" then
            return value
        end

        return "+"
            .. value
    end

    local function getMaximumExtra(
        target
    )
        target =
            math.max(
                0,
                tonumber(target)
                or 0
            )

        local mode =
            GAG2PremiumNormalizeExtraLimitMode(
                state.ExtraLimitMode
            )

        if mode == "No limit" then
            return math.huge
        end

        if mode == "1%"
            or mode == "5%"
            or mode == "10%"
        then
            local percentage =
                tonumber(
                    mode:match(
                        "[%d%.]+"
                    )
                )
                or 5

            return target
                * percentage
                / 100
        end

        local custom =
            GAG2PremiumNormalizeExtraLimitCustom(
                state.ExtraLimitCustom
            )

        if custom:find(
            "%",
            1,
            true
        ) then
            local percentage =
                tonumber(
                    custom
                        :gsub(
                            "%%",
                            ""
                        )
                        :gsub(
                            "%s+",
                            ""
                        )
                )

            if percentage
                and percentage >= 0
            then
                return target
                    * percentage
                    / 100
            end
        else
            local fixedValue =
                parseValue(
                    custom
                )

            if fixedValue
                and fixedValue >= 0
            then
                return fixedValue
            end
        end

        return target
            * 0.05
    end

    local function updateStrategyButton()
        if state.Strategy
            == "Send at least"
        then
            strategyButton.Text =
                "Send at least · "
                .. (
                    state.ExtraLimitMode
                        == "No limit"
                        and "No limit"
                        or (
                            "Max "
                            .. extraLimitCaption()
                        )
                )
        else
            strategyButton.Text =
                state.Strategy
        end
    end

    updateStrategyButton()


    local function renderRecipients()
        clearRows(
            routeList,
            routeLayout
        )

        routeCount.Text =
            "RECIPIENTS · "
            .. tostring(
                #state.Recipients
            )
            .. " ADDED"

        clearButton.Visible =
            #state.Recipients > 0
            and not state.RecipientChangesLocked()

        if #state.Recipients == 0 then
            local empty =
                create(
                    "Frame",
                    {
                        BackgroundColor3 =
                            color.Field,

                        Size =
                            UDim2.new(
                                1,
                                -2,
                                0,
                                52
                            ),
                    },
                    routeList
                )

            round(
                empty,
                10
            )

            text(
                empty,
                "No recipients yet",
                UDim2.new(
                    1,
                    -20,
                    0,
                    20
                ),
                UDim2.fromOffset(
                    10,
                    6
                ),
                11,
                color.Text,
                nil,
                Enum.Font.GothamSemibold
            )

            text(
                empty,
                "Enter a username and amount above.",
                UDim2.new(
                    1,
                    -20,
                    0,
                    18
                ),
                UDim2.fromOffset(
                    10,
                    27
                ),
                9,
                color.Muted
            )

            return
        end

        for index, recipient in ipairs(
            state.Recipients
        ) do
            local row =
                create(
                    "Frame",
                    {
                        BackgroundColor3 =
                            color.Field,

                        Size =
                            UDim2.new(
                                1,
                                -2,
                                0,
                                58
                            ),

                        LayoutOrder =
                            index,
                    },
                    routeList
                )

            round(
                row,
                10
            )

            addAvatar(
                row,
                recipient.UserId,
                UDim2.fromOffset(
                    38,
                    38
                ),
                UDim2.fromOffset(
                    9,
                    10
                )
            )

            text(
                row,
                "@"
                    .. recipient.Name,
                UDim2.new(
                    1,
                    -218,
                    0,
                    19
                ),
                UDim2.fromOffset(
                    56,
                    8
                ),
                10,
                color.Text,
                nil,
                Enum.Font.GothamSemibold
            )

            text(
                row,
                formatValue(
                    recipient.Target
                )
                    .. " to send",
                UDim2.new(
                    1,
                    -218,
                    0,
                    17
                ),
                UDim2.fromOffset(
                    56,
                    31
                ),
                12,
                color.Secondary
            )

            local up =
                button(
                    row,
                    "^",
                    UDim2.fromOffset(
                        25,
                        29
                    ),
                    UDim2.new(
                        1,
                        -152,
                        0,
                        15
                    ),
                    false
                )

            local down =
                button(
                    row,
                    "v",
                    UDim2.fromOffset(
                        25,
                        29
                    ),
                    UDim2.new(
                        1,
                        -123,
                        0,
                        15
                    ),
                    false
                )

            local edit =
                button(
                    row,
                    "Edit",
                    UDim2.fromOffset(
                        38,
                        29
                    ),
                    UDim2.new(
                        1,
                        -94,
                        0,
                        15
                    ),
                    false
                )

            local remove =
                button(
                    row,
                    "X",
                    UDim2.fromOffset(
                        29,
                        29
                    ),
                    UDim2.new(
                        1,
                        -39,
                        0,
                        15
                    ),
                    false
                )

            up.TextSize =
                11

            down.TextSize =
                11

            edit.TextSize =
                12

            remove.TextSize =
                10

            up.MouseButton1Click:Connect(function()
                if state.RecipientChangesLocked()
                    or index <= 1
                then
                    return
                end

                state.Recipients[index],
                state.Recipients[index - 1] =
                    state.Recipients[index - 1],
                    state.Recipients[index]

                renderRecipients()
                task.spawn(rebuildPlan)
            end)

            down.MouseButton1Click:Connect(function()
                if state.RecipientChangesLocked()
                    or index >= #state.Recipients
                then
                    return
                end

                state.Recipients[index],
                state.Recipients[index + 1] =
                    state.Recipients[index + 1],
                    state.Recipients[index]

                renderRecipients()
                task.spawn(rebuildPlan)
            end)

            edit.MouseButton1Click:Connect(function()
                if state.RecipientChangesLocked() then
                    return
                end

                state.Editing =
                    index

                recipientBox.Text =
                    recipient.Name

                valueBox.Text =
                    formatValue(
                        recipient.Target
                    )

                addButton.Text =
                    "Save"
            end)

            remove.MouseButton1Click:Connect(function()
                if state.RecipientChangesLocked() then
                    return
                end

                table.remove(
                    state.Recipients,
                    index
                )

                state.Editing =
                    nil

                addButton.Text =
                    "+ Add"

                renderRecipients()
                task.spawn(rebuildPlan)
            end)
        end
    end

    local function allocate(
        available,
        target
    )
        local sorted =
            table.clone(
                available
            )

        table.sort(
            sorted,
            function(a, b)
                return a.Value
                    > b.Value
            end
        )

        local chosen = {}
        local used = {}
        local total = 0

        local allocation = {
            GuardBlocked = false,
            UnsafeValue = nil,
            UnsafeExtra = nil,
            MaxExtra = nil,
            MaxAllowed = nil,
        }

        for _, fruit in ipairs(
            sorted
        ) do
            if total + fruit.Value
                <= target
            then
                table.insert(
                    chosen,
                    fruit
                )

                used[fruit.Id] =
                    true

                total +=
                    fruit.Value
            end
        end

        if state.Strategy
            == "Send at least"
            and total < target
        then
            local maximumExtra =
                getMaximumExtra(
                    target
                )

            local maximumAllowed =
                maximumExtra == math.huge
                    and math.huge
                    or target
                        + maximumExtra

            allocation.MaxExtra =
                maximumExtra

            allocation.MaxAllowed =
                maximumAllowed

            local bestSafe
            local bestSafeExtra

            local bestUnsafe
            local bestUnsafeExtra

            for _, fruit in ipairs(
                sorted
            ) do
                if not used[fruit.Id] then
                    local candidateValue =
                        total
                        + fruit.Value

                    if candidateValue
                        >= target
                    then
                        local candidateExtra =
                            candidateValue
                            - target

                        if candidateExtra
                            <= maximumExtra
                        then
                            if not bestSafe
                                or candidateExtra
                                    < bestSafeExtra
                            then
                                bestSafe =
                                    fruit

                                bestSafeExtra =
                                    candidateExtra
                            end
                        elseif not bestUnsafe
                            or candidateExtra
                                < bestUnsafeExtra
                        then
                            bestUnsafe =
                                fruit

                            bestUnsafeExtra =
                                candidateExtra
                        end
                    end
                end
            end

            if bestSafe then
                table.insert(
                    chosen,
                    bestSafe
                )

                used[bestSafe.Id] =
                    true

                total +=
                    bestSafe.Value
            elseif bestUnsafe then
                allocation.GuardBlocked =
                    true

                allocation.UnsafeValue =
                    total
                    + bestUnsafe.Value

                allocation.UnsafeExtra =
                    allocation.UnsafeValue
                    - target
            end
        elseif state.Strategy
            == "Closest amount"
            and total < target
        then
            local best
            local difference

            for _, fruit in ipairs(
                sorted
            ) do
                if not used[fruit.Id] then
                    local current =
                        math.abs(
                            target
                            - total
                            - fruit.Value
                        )

                    if not best
                        or current
                            < difference
                    then
                        best =
                            fruit

                        difference =
                            current
                    end
                end
            end

            if best then
                local below =
                    math.abs(
                        target
                        - total
                    )

                local above =
                    math.abs(
                        target
                        - total
                        - best.Value
                    )

                if above < below then
                    table.insert(
                        chosen,
                        best
                    )

                    used[best.Id] =
                        true

                    total +=
                        best.Value
                end
            end
        end

        return chosen,
            total,
            allocation
    end

    rebuildPlan =
        function()
            if state.Busy
                or state.Running
            then
                return
            end

            state.Busy =
                true

            setStatus(
                "Checking",
                color.Yellow
            )

            messageText.TextColor3 =
                color.Muted

            local inventory, unvalued =
                scanInventory()

            local eligible = {}
            local protected = 0
            local filtered = 0

            for _, fruit in ipairs(
                inventory
            ) do
                if not state.Filters.Matches(
                    fruit
                )
                then
                    filtered +=
                        1
                elseif state.Protect
                    and fruit.Favorite
                then
                    protected +=
                        1
                else
                    table.insert(
                        eligible,
                        fruit
                    )
                end
            end

            local available =
                table.clone(eligible)

            local plan = {}
            local totalFruits = 0
            local totalValue = 0
            local totalMails = 0
            local incomplete = 0
            local overpayBlocked = 0

            for routeIndex, recipient in ipairs(
                state.Recipients
            ) do
                local planTarget =
                    tonumber(
                        recipient.Target
                    )
                    or 0

                local valueSession =
                    state.ValueSession

                if type(valueSession) == "table"
                    and type(
                        valueSession.RemainingTargets
                    ) == "table"
                    and valueSession.Status ~= "Complete"
                then
                    local remainingTarget =
                        valueSession.RemainingTargets[
                            recipient.UserId
                        ]

                    if remainingTarget ~= nil then
                        planTarget =
                            math.max(
                                0,
                                tonumber(
                                    remainingTarget
                                )
                                or 0
                            )
                    end
                end

                local chosen,
                    chosenValue,
                    allocation =
                    allocate(
                        available,
                        planTarget
                    )

                allocation =
                    type(allocation) == "table"
                    and allocation
                    or {
                        GuardBlocked = false,
                    }

                local selected = {}

                for _, fruit in ipairs(
                    chosen
                ) do
                    selected[fruit.Id] =
                        true
                end

                local remaining = {}

                for _, fruit in ipairs(
                    available
                ) do
                    if not selected[fruit.Id] then
                        table.insert(
                            remaining,
                            fruit
                        )
                    end
                end

                available =
                    remaining

                local complete =
                    planTarget <= 0
                    or (
                        allocation.GuardBlocked ~= true
                        and (
                            (
                                state.Strategy == "Send at least"
                                and chosenValue >= planTarget
                            )
                            or (
                                state.Strategy ~= "Send at least"
                                and #chosen > 0
                            )
                        )
                    )

                if planTarget > 0
                    and allocation.GuardBlocked == true
                then
                    overpayBlocked +=
                        1
                end

                if not complete then
                    incomplete +=
                        1
                end

                local entry = {
                    Index =
                        routeIndex,

                    Recipient =
                        recipient,

                    Target =
                        planTarget,

                    Fruits =
                        chosen,

                    Value =
                        chosenValue,

                    Extra =
                        chosenValue
                        - planTarget,

                    ExtraPercent =
                        planTarget > 0
                        and (
                            (
                                chosenValue
                                - planTarget
                            )
                            / planTarget
                            * 100
                        )
                        or 0,

                    Mails =
                        math.ceil(
                            #chosen / BATCH_LIMIT
                        ),

                    Complete =
                        complete,

                    GuardBlocked =
                        planTarget > 0
                        and allocation.GuardBlocked == true,

                    UnsafeValue =
                        allocation.UnsafeValue,

                    UnsafeExtra =
                        allocation.UnsafeExtra,

                    MaxExtra =
                        allocation.MaxExtra,

                    MaxAllowed =
                        allocation.MaxAllowed,
                }

                table.insert(
                    plan,
                    entry
                )

                totalFruits +=
                    #chosen

                totalValue +=
                    chosenValue

                totalMails +=
                    entry.Mails
            end

            state.Plan =
                plan

            clearRows(
                previewList,
                previewLayout
            )

            if #plan == 0 then
                local empty =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Field,

                            Size =
                                UDim2.new(
                                    1,
                                    -2,
                                    0,
                                    268
                                ),
                        },
                        previewList
                    )

                round(
                    empty,
                    13
                )

                outline(
                    empty,
                    Color3.fromRGB(
                        40,
                        51,
                        68
                    )
                )

                local emptyIcon =
                    create(
                        "Frame",
                        {
                            AnchorPoint =
                                Vector2.new(
                                    0.5,
                                    0
                                ),

                            BackgroundTransparency =
                                1,

                            Size =
                                UDim2.fromOffset(
                                    54,
                                    46
                                ),

                            Position =
                                UDim2.new(
                                    0.5,
                                    0,
                                    0,
                                    55
                                ),
                        },
                        empty
                    )

                local emptyIconBody =
                    create(
                        "Frame",
                        {
                            BackgroundTransparency =
                                1,

                            Size =
                                UDim2.fromOffset(
                                    48,
                                    38
                                ),

                            Position =
                                UDim2.fromOffset(
                                    3,
                                    4
                                ),
                        },
                        emptyIcon
                    )

                round(
                    emptyIconBody,
                    8
                )

                local emptyIconStroke =
                    outline(
                        emptyIconBody,
                        color.Secondary
                    )

                emptyIconStroke.Thickness =
                    2

                emptyIconStroke.Transparency =
                    0.1

                local emptyIconTray =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Secondary,

                            Size =
                                UDim2.fromOffset(
                                    22,
                                    3
                                ),

                            Position =
                                UDim2.fromOffset(
                                    16,
                                    29
                                ),
                        },
                        emptyIcon
                    )

                round(
                    emptyIconTray,
                    3
                )

                text(
                    empty,
                    "Nothing to preview yet",
                    UDim2.new(
                        1,
                        -30,
                        0,
                        28
                    ),
                    UDim2.fromOffset(
                        15,
                        124
                    ),
                    16,
                    color.Text,
                    Enum.TextXAlignment.Center,
                    Enum.Font.GothamBold
                )

                text(
                    empty,
                    "Add someone and choose how much to send.",
                    UDim2.new(
                        1,
                        -30,
                        0,
                        24
                    ),
                    UDim2.fromOffset(
                        15,
                        160
                    ),
                    12,
                    color.Secondary,
                    Enum.TextXAlignment.Center,
                    Enum.Font.GothamMedium
                )
            else
                for _, entry in ipairs(plan) do
                    local row =
                        create(
                            "Frame",
                            {
                                BackgroundColor3 =
                                    color.Field,

                                Size =
                                    UDim2.new(
                                        1,
                                        -2,
                                        0,
                                        118
                                    ),

                                LayoutOrder =
                                    entry.Index,
                            },
                            previewList
                        )

                    round(
                        row,
                        11
                    )

                    outline(
                        row,
                        color.Border
                    )

                    addAvatar(
                        row,
                        entry.Recipient.UserId,
                        UDim2.fromOffset(
                            32,
                            32
                        ),
                        UDim2.fromOffset(
                            12,
                            8
                        )
                    )

                    text(
                        row,
                        "@"
                            .. entry.Recipient.Name,
                        UDim2.new(
                            1,
                            -180,
                            0,
                            24
                        ),
                        UDim2.fromOffset(
                            54,
                            7
                        ),
                        11,
                        color.Text,
                        nil,
                        Enum.Font.GothamSemibold
                    )

                    text(
                        row,
                        entry.GuardBlocked
                                and "Cannot reach safely"
                            or entry.Complete
                                    and "Ready"
                                or "Needs value",
                        UDim2.fromOffset(
                            150,
                            24
                        ),
                        UDim2.new(
                            1,
                            -162,
                            0,
                            7
                        ),
                        9,
                        entry.GuardBlocked
                                and color.Red
                            or entry.Complete
                                    and color.Green
                                or color.Yellow,
                        Enum.TextXAlignment.Right,
                        Enum.Font.GothamBold
                    )

                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Border,

                            BackgroundTransparency =
                                0.25,

                            Size =
                                UDim2.new(
                                    1,
                                    -24,
                                    0,
                                    1
                                ),

                            Position =
                                UDim2.fromOffset(
                                    12,
                                    39
                                ),
                        },
                        row
                    )

                    local function addPreviewStat(
                        titleValue,
                        valueText,
                        x,
                        valueColor
                    )
                        text(
                            row,
                            titleValue,
                            UDim2.fromOffset(
                                104,
                                15
                            ),
                            UDim2.fromOffset(
                                x,
                                43
                            ),
                            10,
                            color.Secondary,
                            nil,
                            Enum.Font.GothamBold
                        )

                        text(
                            row,
                            valueText,
                            UDim2.fromOffset(
                                104,
                                20
                            ),
                            UDim2.fromOffset(
                                x,
                                58
                            ),
                            10,
                            valueColor
                                or color.Text,
                            nil,
                            Enum.Font.GothamSemibold
                        )
                    end

                    addPreviewStat(
                        "TARGET",
                        formatValue(
                            entry.Target
                            or entry.Recipient.Target
                        ),
                        12,
                        color.Text
                    )

                    addPreviewStat(
                        "SENDING",
                        formatValue(
                            entry.Value
                        ),
                        120,
                        color.Text
                    )

                    addPreviewStat(
                        "EXTRA "
                            .. formatSignedMailPercent(
                                entry.ExtraPercent
                            ),
                        formatSignedMailValue(
                            entry.Extra
                        ),
                        228,
                        entry.Extra >= 0
                                and color.Green
                            or color.Yellow
                    )

                    addPreviewStat(
                        "FRUITS",
                        tostring(
                            #entry.Fruits
                        ),
                        336,
                        color.Text
                    )

                    addPreviewStat(
                        "MAIL USES",
                        tostring(
                            entry.Mails
                        ),
                        444,
                        color.Text
                    )

                    local viewButton =
                        button(
                            row,
                            #entry.Fruits > 0
                                    and "View Selected Fruits"
                                or "No Fruits Selected",
                            UDim2.new(
                                1,
                                -24,
                                0,
                                25
                            ),
                            UDim2.fromOffset(
                                12,
                                84
                            ),
                            false
                        )

                    viewButton.TextSize =
                        12

                    viewButton.TextColor3 =
                        #entry.Fruits > 0
                                and color.Accent
                            or color.Muted

                    viewButton.Active =
                        #entry.Fruits > 0

                    local viewStroke =
                        viewButton:FindFirstChildOfClass(
                            "UIStroke"
                        )

                    if viewStroke
                        and #entry.Fruits > 0
                    then
                        viewStroke.Color =
                            Color3.fromRGB(
                                67,
                                135,
                                235
                            )
                    end

                    viewButton.MouseButton1Click:Connect(function()
                        if not viewButton.Active then
                            return
                        end

                        if type(showFruitPreview)
                            == "function"
                        then
                            showFruitPreview(
                                entry
                            )
                        end
                    end)
                end
            end

            local seconds =
                totalMails <= 1
                    and 0
                or (
                    totalMails - 1
                ) * COOLDOWN

            inventoryText.Text =
                string.format(
                    "%d available · %d favorites · %d filtered",
                    #eligible,
                    protected,
                    filtered
                )

            inventoryText.TextSize =
                8

            previewCount.Text =
                string.format(
                    "%d fruits - %d sends",
                    totalFruits,
                    totalMails
                )

            summaryPeopleValue.Text =
                tostring(
                    #state.Recipients
                )

            summarySendsValue.Text =
                tostring(
                    totalMails
                )

            summaryFruitsValue.Text =
                tostring(
                    totalFruits
                )

            summaryTotalValue.Text =
                formatValue(
                    totalValue
                )

            summaryTimeValue.Text =
                seconds > 0
                        and "~"
                            .. tostring(
                                math.ceil(seconds)
                            )
                            .. "s"
                    or "Immediate"

            local remainingUses =
                math.max(
                    0,
                    DAILY_LIMIT
                    - tracker.Used
                )

            local valueSession =
                state.ValueSession

            local valueSessionStatus =
                type(valueSession) == "table"
                and tostring(
                    valueSession.Status
                    or ""
                )
                or ""

            local reviewingUncertain =
                valueSessionStatus
                == "Uncertain"

            local resumingDelivery =
                valueSessionStatus
                == "Paused"

            local canSend =
                reviewingUncertain
                or resumingDelivery
                or (
                    #plan > 0
                    and totalMails > 0
                    and incomplete == 0
                    and overpayBlocked == 0
                    and totalMails <= remainingUses
                )

            sendButton.Active =
                canSend

            sendButton.AutoButtonColor =
                canSend

            sendButton.BackgroundColor3 =
                canSend
                        and color.Accent
                    or color.Hover

            sendButton.TextColor3 =
                canSend
                        and color.Text
                    or color.Muted

            sendButton.Text =
                reviewingUncertain
                        and "Review uncertain mail"
                    or resumingDelivery
                            and "Resume remaining delivery"
                        or "Review and send"

            if reviewingUncertain then
                messageText.Text =
                    "A mail was accepted, but item removal could not be confirmed."

                messageText.TextColor3 =
                    color.Red
            elseif resumingDelivery
                and totalMails <= 0
            then
                messageText.Text =
                    "No remaining batches. Press Resume to finish the session."

                messageText.TextColor3 =
                    color.Green
            elseif #inventory == 0
                and unvalued > 0
            then
                messageText.Text =
                    "Fruit values aren't ready. Load SOPHIA, then refresh the preview."

                messageText.TextColor3 =
                    color.Red
            elseif #state.Recipients == 0 then
                messageText.Text =
                    "Add a recipient and target."
            elseif overpayBlocked > 0 then
                messageText.Text =
                    tostring(
                        overpayBlocked
                    )
                    .. (
                        overpayBlocked == 1
                            and " target cannot be reached within the maximum extra value."
                            or " targets cannot be reached within the maximum extra value."
                    )

                messageText.TextColor3 =
                    color.Red
            elseif incomplete > 0 then
                messageText.Text =
                    tostring(
                        incomplete
                    )
                    .. " target(s) cannot be completed."
            elseif totalMails > remainingUses then
                messageText.Text =
                    "This needs more sends than you have left today."
            else
                messageText.Text =
                    "Everything is ready. Review it before sending."
            end

            state.Busy =
                false

            if reviewingUncertain then
                setStatus(
                    "Confirmation uncertain",
                    color.Red
                )
            elseif resumingDelivery then
                setStatus(
                    "Paused",
                    color.Yellow
                )
            else
                setStatus(
                    "Ready",
                    color.Green
                )
            end
        end

    local function closeModal()
        overlay.Visible =
            false

        for _, child in ipairs(
            overlay:GetChildren()
        ) do
            child:Destroy()
        end
    end

    local function showModal(
        titleValue,
        bodyValue,
        confirmValue,
        callback,
        warning
    )
        closeModal()

        overlay.Visible =
            true

        local modal =
            create(
                "Frame",
                {
                    AnchorPoint =
                        Vector2.new(
                            0.5,
                            0.5
                        ),

                    Position =
                        UDim2.fromScale(
                            0.5,
                            0.5
                        ),

                    Size =
                        UDim2.fromOffset(
                            430,
                            270
                        ),

                    BackgroundColor3 =
                        color.Card,

                    ZIndex =
                        51,
                },
                overlay
            )

        round(
            modal,
            18
        )

        outline(
            modal,
            warning
                    and color.Accent
                or color.Border
        )

        local heading =
            text(
                modal,
                titleValue,
                UDim2.new(
                    1,
                    -36,
                    0,
                    28
                ),
                UDim2.fromOffset(
                    18,
                    17
                ),
                18,
                color.Text,
                nil,
                Enum.Font.GothamBold
            )

        heading.ZIndex =
            52

        local body =
            text(
                modal,
                bodyValue,
                UDim2.new(
                    1,
                    -36,
                    0,
                    135
                ),
                UDim2.fromOffset(
                    18,
                    57
                ),
                11,
                color.Muted
            )

        body.TextWrapped =
            true

        body.TextYAlignment =
            Enum.TextYAlignment.Top

        body.ZIndex =
            52

        local cancel =
            button(
                modal,
                callback
                        and "Cancel"
                    or "Close",
                UDim2.fromOffset(
                    callback
                            and 112
                        or 394,
                    46
                ),
                UDim2.fromOffset(
                    18,
                    207
                ),
                false
            )

        cancel.ZIndex =
            53

        cancel.MouseButton1Click:Connect(
            closeModal
        )

        if callback then
            local confirm =
                button(
                    modal,
                    confirmValue,
                    UDim2.fromOffset(
                        266,
                        46
                    ),
                    UDim2.fromOffset(
                        146,
                        207
                    ),
                    true
                )

            confirm.ZIndex =
                53

            confirm.MouseButton1Click:Connect(function()
                closeModal()
                callback()
            end)
        end
    end

    state.SavedRecipients.Commit =
        function(
            records,
            recent
        )
            SOPHIA_MAIL_STATE.SavedRecipients =
                GAG2PremiumNormalizeRecipientRecords(
                    records,
                    25,
                    true
                )

            SOPHIA_MAIL_STATE.RecentRecipients =
                GAG2PremiumNormalizeRecipientRecords(
                    recent,
                    8,
                    false
                )

            state.SavedRecipients.Records =
                SOPHIA_MAIL_STATE.SavedRecipients

            state.SavedRecipients.Recent =
                SOPHIA_MAIL_STATE.RecentRecipients

            GAG2PremiumSaveSettings()
            state.SavedRecipients.UpdateButtons()
        end

    state.SavedRecipients.Show =
        function(
            targetBox
        )
            if state.RecipientChangesLocked() then
                SophiaNotify(
                    "SOPHIA Mail",
                    "Finish or safely end the paused delivery before changing recipients.",
                    4
                )

                return
            end

            if typeof(targetBox) ~= "Instance"
                or not targetBox:IsA(
                    "TextBox"
                )
            then
                targetBox =
                    recipientBox
            end

            local draft = {
                Records =
                    GAG2PremiumNormalizeRecipientRecords(
                        SOPHIA_MAIL_STATE.SavedRecipients,
                        25,
                        true
                    ),

                Recent =
                    GAG2PremiumNormalizeRecipientRecords(
                        SOPHIA_MAIL_STATE.RecentRecipients,
                        8,
                        false
                    ),

                Search = "",
                EditUserId = nil,
                EditOriginalName = "",
                Favorite = false,
            }

            closeModal()

            overlay.Visible =
                true

            local modal =
                create(
                    "Frame",
                    {
                        AnchorPoint =
                            Vector2.new(
                                0.5,
                                0.5
                            ),

                        Position =
                            UDim2.fromScale(
                                0.5,
                                0.5
                            ),

                        Size =
                            UDim2.fromOffset(
                                660,
                                548
                            ),

                        BackgroundColor3 =
                            color.Card,

                        ZIndex =
                            51,
                    },
                    overlay
                )

            round(
                modal,
                18
            )

            outline(
                modal,
                color.Border
            )

            local heading =
                text(
                    modal,
                    "Saved Recipients",
                    UDim2.new(
                        1,
                        -90,
                        0,
                        28
                    ),
                    UDim2.fromOffset(
                        18,
                        15
                    ),
                    18,
                    color.Text,
                    nil,
                    Enum.Font.GothamBold
                )

            heading.ZIndex =
                52

            local subtitle =
                text(
                    modal,
                    "Contacts use verified UserIds, so username changes will not break them.",
                    UDim2.new(
                        1,
                        -90,
                        0,
                        20
                    ),
                    UDim2.fromOffset(
                        18,
                        46
                    ),
                    9,
                    color.Muted
                )

            subtitle.ZIndex =
                52

            local closeButton =
                button(
                    modal,
                    "X",
                    UDim2.fromOffset(
                        38,
                        34
                    ),
                    UDim2.new(
                        1,
                        -56,
                        0,
                        14
                    ),
                    false
                )

            closeButton.ZIndex =
                53

            closeButton.MouseButton1Click:Connect(
                closeModal
            )

            local searchBox =
                box(
                    modal,
                    "Search labels, usernames, or User IDs",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        40
                    ),
                    UDim2.fromOffset(
                        18,
                        78
                    )
                )

            searchBox.ZIndex =
                53

            local contactStatus =
                text(
                    modal,
                    "",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        18
                    ),
                    UDim2.fromOffset(
                        18,
                        119
                    ),
                    9,
                    color.Muted,
                    Enum.TextXAlignment.Right,
                    Enum.Font.GothamMedium
                )

            contactStatus.ZIndex =
                52

            local contactList =
                create(
                    "ScrollingFrame",
                    {
                        BackgroundColor3 =
                            color.Field,

                        BorderSizePixel =
                            0,

                        Size =
                            UDim2.new(
                                1,
                                -36,
                                0,
                                294
                            ),

                        Position =
                            UDim2.fromOffset(
                                18,
                                139
                            ),

                        CanvasSize =
                            UDim2.fromOffset(
                                0,
                                0
                            ),

                        AutomaticCanvasSize =
                            Enum.AutomaticSize.Y,

                        ScrollingDirection =
                            Enum.ScrollingDirection.Y,

                        ScrollBarThickness =
                            3,

                        ScrollBarImageColor3 =
                            color.Border,

                        ClipsDescendants =
                            true,

                        ZIndex =
                            52,
                    },
                    modal
                )

            round(
                contactList,
                11
            )

            outline(
                contactList,
                color.Border
            )

            local contactLayout =
                create(
                    "UIListLayout",
                    {
                        Padding =
                            UDim.new(
                                0,
                                5
                            ),

                        SortOrder =
                            Enum.SortOrder.LayoutOrder,
                    },
                    contactList
                )

            create(
                "UIPadding",
                {
                    PaddingTop =
                        UDim.new(
                            0,
                            6
                        ),

                    PaddingBottom =
                        UDim.new(
                            0,
                            6
                        ),

                    PaddingLeft =
                        UDim.new(
                            0,
                            6
                        ),

                    PaddingRight =
                        UDim.new(
                            0,
                            6
                        ),
                },
                contactList
            )

            local labelBox =
                box(
                    modal,
                    "Label, e.g. Storage Alt",
                    UDim2.fromOffset(
                        176,
                        40
                    ),
                    UDim2.fromOffset(
                        18,
                        445
                    )
                )

            local usernameBox =
                box(
                    modal,
                    "Username or User ID",
                    UDim2.fromOffset(
                        240,
                        40
                    ),
                    UDim2.fromOffset(
                        202,
                        445
                    )
                )

            local favoriteDraftButton =
                button(
                    modal,
                    "☆ Favorite",
                    UDim2.fromOffset(
                        92,
                        40
                    ),
                    UDim2.fromOffset(
                        450,
                        445
                    ),
                    false
                )

            local saveContactButton =
                button(
                    modal,
                    "Save",
                    UDim2.fromOffset(
                        92,
                        40
                    ),
                    UDim2.fromOffset(
                        550,
                        445
                    ),
                    true
                )

            labelBox.ZIndex =
                53

            usernameBox.ZIndex =
                53

            favoriteDraftButton.ZIndex =
                53

            saveContactButton.ZIndex =
                53

            local managerStatus =
                text(
                    modal,
                    "Enter a label and Roblox username to save a new contact.",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        34
                    ),
                    UDim2.fromOffset(
                        18,
                        496
                    ),
                    9,
                    color.Muted,
                    Enum.TextXAlignment.Left,
                    Enum.Font.GothamMedium
                )

            managerStatus.TextWrapped =
                true

            managerStatus.ZIndex =
                52

            local currentInput =
                GAG2PremiumRecipientText(
                    targetBox.Text,
                    80
                )

            if currentInput ~= "" then
                usernameBox.Text =
                    currentInput
            end

            draft.UpdateFavorite =
                function()
                    favoriteDraftButton.Text =
                        draft.Favorite
                                and "★ Favorite"
                            or "☆ Favorite"

                    favoriteDraftButton.BackgroundColor3 =
                        draft.Favorite
                                and color.Accent
                            or color.Field
                end

            draft.ResetEditor =
                function()
                    draft.EditUserId =
                        nil

                    draft.EditOriginalName =
                        ""

                    draft.Favorite =
                        false

                    labelBox.Text =
                        ""

                    usernameBox.Text =
                        ""

                    saveContactButton.Text =
                        "Save"

                    draft.UpdateFavorite()
                end

            draft.Matches =
                function(
                    record
                )
                    local query =
                        GAG2PremiumFilterKey(
                            draft.Search
                        )

                    if query == "" then
                        return true
                    end

                    local searchable =
                        GAG2PremiumFilterKey(
                            tostring(
                                record.Label
                                    or ""
                            )
                            .. " "
                            .. tostring(
                                record.Name
                                    or ""
                            )
                            .. " "
                            .. tostring(
                                record.UserId
                                    or ""
                            )
                        )

                    return searchable:find(
                        query,
                        1,
                        true
                    ) ~= nil
                end

            draft.Render =
                function()
                    clearRows(
                        contactList,
                        contactLayout
                    )

                    draft.Records =
                        GAG2PremiumNormalizeRecipientRecords(
                            draft.Records,
                            25,
                            true
                        )

                    draft.Recent =
                        GAG2PremiumNormalizeRecipientRecords(
                            draft.Recent,
                            8,
                            false
                        )

                    local savedMap = {}
                    local visibleSaved = 0
                    local visibleRecent = 0
                    local layoutOrder = 0

                    for _, record in ipairs(
                        draft.Records
                    ) do
                        savedMap[
                            record.UserId
                        ] =
                            true
                    end

                    draft.AddSection =
                        function(
                            caption
                        )
                            layoutOrder +=
                                1

                            local section =
                                text(
                                    contactList,
                                    caption,
                                    UDim2.new(
                                        1,
                                        -4,
                                        0,
                                        24
                                    ),
                                    UDim2.fromOffset(
                                        0,
                                        0
                                    ),
                                    9,
                                    color.Muted,
                                    Enum.TextXAlignment.Left,
                                    Enum.Font.GothamBold
                                )

                            section.LayoutOrder =
                                layoutOrder

                            section.ZIndex =
                                53

                            create(
                                "UIPadding",
                                {
                                    PaddingLeft =
                                        UDim.new(
                                            0,
                                            6
                                        ),
                                },
                                section
                            )
                        end

                    draft.AddRow =
                        function(
                            record,
                            recent
                        )
                            layoutOrder +=
                                1

                            local row =
                                create(
                                    "Frame",
                                    {
                                        BackgroundColor3 =
                                            color.Card,

                                        Size =
                                            UDim2.new(
                                                1,
                                                -4,
                                                0,
                                                62
                                            ),

                                        LayoutOrder =
                                            layoutOrder,

                                        ZIndex =
                                            53,
                                    },
                                    contactList
                                )

                            round(
                                row,
                                10
                            )

                            outline(
                                row,
                                record.Favorite
                                        and color.Accent
                                    or color.Border
                            )

                            local avatar =
                                addAvatar(
                                    row,
                                    record.UserId,
                                    UDim2.fromOffset(
                                        38,
                                        38
                                    ),
                                    UDim2.fromOffset(
                                        10,
                                        12
                                    )
                                )

                            avatar.ZIndex =
                                54

                            local favoriteButton =
                                button(
                                    row,
                                    record.Favorite
                                            and "★"
                                            or "☆",
                                    UDim2.fromOffset(
                                        32,
                                        32
                                    ),
                                    UDim2.fromOffset(
                                        55,
                                        15
                                    ),
                                    record.Favorite == true
                                )

                            favoriteButton.ZIndex =
                                54

                            favoriteButton.Visible =
                                not recent

                            local displayLabel =
                                text(
                                    row,
                                    recent
                                            and (
                                                "@"
                                                .. record.Name
                                            )
                                            or tostring(
                                                record.Label
                                                    or record.Name
                                            ),
                                    UDim2.new(
                                        1,
                                        -310,
                                        0,
                                        21
                                    ),
                                    UDim2.fromOffset(
                                        96,
                                        8
                                    ),
                                    10,
                                    color.Text,
                                    Enum.TextXAlignment.Left,
                                    Enum.Font.GothamSemibold
                                )

                            displayLabel.ZIndex =
                                54

                            local identity =
                                text(
                                    row,
                                    recent
                                        and (
                                            "Recently used · "
                                            .. tostring(
                                                record.UserId
                                            )
                                        )
                                        or (
                                            "@"
                                            .. record.Name
                                            .. " · "
                                            .. tostring(
                                                record.UserId
                                            )
                                        ),
                                    UDim2.new(
                                        1,
                                        -310,
                                        0,
                                        18
                                    ),
                                    UDim2.fromOffset(
                                        96,
                                        33
                                    ),
                                    8,
                                    color.Muted
                                )

                            identity.ZIndex =
                                54

                            local useButton =
                                button(
                                    row,
                                    "Use",
                                    UDim2.fromOffset(
                                        60,
                                        34
                                    ),
                                    UDim2.new(
                                        1,
                                        -184,
                                        0,
                                        14
                                    ),
                                    true
                                )

                            local manageButton =
                                button(
                                    row,
                                    recent
                                        and "Save"
                                        or "Edit",
                                    UDim2.fromOffset(
                                        54,
                                        34
                                    ),
                                    UDim2.new(
                                        1,
                                        -116,
                                        0,
                                        14
                                    ),
                                    false
                                )

                            local deleteButton =
                                button(
                                    row,
                                    "X",
                                    UDim2.fromOffset(
                                        42,
                                        34
                                    ),
                                    UDim2.new(
                                        1,
                                        -54,
                                        0,
                                        14
                                    ),
                                    false
                                )

                            useButton.ZIndex =
                                54

                            manageButton.ZIndex =
                                54

                            deleteButton.ZIndex =
                                54

                            useButton.TextSize =
                                9

                            manageButton.TextSize =
                                8

                            deleteButton.TextSize =
                                10

                            deleteButton.Visible =
                                not recent

                            useButton.MouseButton1Click:Connect(function()
                                if state.RecipientChangesLocked() then
                                    return
                                end

                                useButton.Text =
                                    "Checking"

                                local userId,
                                    username,
                                    resolveError =
                                    GAG2PremiumResolveRecipient(
                                        tostring(
                                            record.UserId
                                        )
                                    )

                                if not userId then
                                    managerStatus.Text =
                                        tostring(
                                            resolveError
                                                or "Recipient could not be verified."
                                        )

                                    managerStatus.TextColor3 =
                                        color.Red

                                    useButton.Text =
                                        "Use"

                                    return
                                end

                                targetBox.Text =
                                    username

                                GAG2PremiumTouchRecipient(
                                    userId,
                                    username
                                )

                                closeModal()
                            end)

                            favoriteButton.MouseButton1Click:Connect(function()
                                if recent
                                    or state.RecipientChangesLocked()
                                then
                                    return
                                end

                                for _, savedRecord in ipairs(
                                    draft.Records
                                ) do
                                    if savedRecord.UserId
                                        == record.UserId
                                    then
                                        savedRecord.Favorite =
                                            not savedRecord.Favorite

                                        break
                                    end
                                end

                                state.SavedRecipients.Commit(
                                    draft.Records,
                                    draft.Recent
                                )

                                draft.Render()
                            end)

                            manageButton.MouseButton1Click:Connect(function()
                                draft.EditUserId =
                                    recent
                                    and nil
                                    or record.UserId

                                draft.EditOriginalName =
                                    recent
                                    and ""
                                    or record.Name

                                draft.Favorite =
                                    recent
                                    and false
                                    or record.Favorite == true

                                labelBox.Text =
                                    recent
                                    and record.Name
                                    or tostring(
                                        record.Label
                                            or record.Name
                                    )

                                usernameBox.Text =
                                    record.Name

                                saveContactButton.Text =
                                    recent
                                        and "Save"
                                        or "Update"

                                draft.UpdateFavorite()

                                managerStatus.Text =
                                    recent
                                        and "Choose a label, then save this recent recipient."
                                        or "Edit the label, username, or favorite status."

                                managerStatus.TextColor3 =
                                    color.Muted
                            end)

                            deleteButton.MouseButton1Click:Connect(function()
                                if recent
                                    or state.RecipientChangesLocked()
                                then
                                    return
                                end

                                for index,
                                    savedRecord in ipairs(
                                    draft.Records
                                ) do
                                    if savedRecord.UserId
                                        == record.UserId
                                    then
                                        table.remove(
                                            draft.Records,
                                            index
                                        )

                                        break
                                    end
                                end

                                if draft.EditUserId
                                    == record.UserId
                                then
                                    draft.ResetEditor()
                                end

                                state.SavedRecipients.Commit(
                                    draft.Records,
                                    draft.Recent
                                )

                                draft.Render()
                            end)
                        end

                    draft.AddSection(
                        "SAVED RECIPIENTS"
                    )

                    for _, record in ipairs(
                        draft.Records
                    ) do
                        if draft.Matches(
                            record
                        ) then
                            visibleSaved +=
                                1

                            draft.AddRow(
                                record,
                                false
                            )
                        end
                    end

                    draft.AddSection(
                        "RECENT"
                    )

                    for _, record in ipairs(
                        draft.Recent
                    ) do
                        if not savedMap[
                            record.UserId
                        ]
                            and draft.Matches(
                                record
                            )
                        then
                            visibleRecent +=
                                1

                            draft.AddRow(
                                record,
                                true
                            )
                        end
                    end

                    if visibleSaved <= 0
                        and visibleRecent <= 0
                    then
                        layoutOrder +=
                            1

                        local empty =
                            text(
                                contactList,
                                "No matching saved or recent recipients.",
                                UDim2.new(
                                    1,
                                    -4,
                                    0,
                                    80
                                ),
                                UDim2.fromOffset(
                                    0,
                                    0
                                ),
                                10,
                                color.Muted,
                                Enum.TextXAlignment.Center,
                                Enum.Font.GothamMedium
                            )

                        empty.LayoutOrder =
                            layoutOrder

                        empty.ZIndex =
                            53
                    end

                    contactStatus.Text =
                        tostring(
                            #draft.Records
                        )
                        .. " / 25 saved · "
                        .. tostring(
                            visibleRecent
                        )
                        .. " recent shown"
                end

            searchBox:GetPropertyChangedSignal(
                "Text"
            ):Connect(function()
                draft.Search =
                    searchBox.Text

                draft.Render()
            end)

            favoriteDraftButton.MouseButton1Click:Connect(function()
                draft.Favorite =
                    not draft.Favorite

                draft.UpdateFavorite()
            end)

            saveContactButton.MouseButton1Click:Connect(function()
                if state.RecipientChangesLocked() then
                    return
                end

                local raw =
                    GAG2PremiumRecipientText(
                        usernameBox.Text,
                        80
                    )

                local resolveInput =
                    raw

                if draft.EditUserId
                    and GAG2PremiumFilterKey(
                        raw
                    ) == GAG2PremiumFilterKey(
                        draft.EditOriginalName
                    )
                then
                    resolveInput =
                        tostring(
                            draft.EditUserId
                        )
                end

                saveContactButton.Text =
                    "Checking"

                local userId,
                    username,
                    resolveError =
                    GAG2PremiumResolveRecipient(
                        resolveInput
                    )

                if not userId then
                    managerStatus.Text =
                        tostring(
                            resolveError
                                or "Recipient could not be verified."
                        )

                    managerStatus.TextColor3 =
                        color.Red

                    saveContactButton.Text =
                        draft.EditUserId
                            and "Update"
                            or "Save"

                    return
                end

                local duplicateIndex
                local editingIndex

                for index, record in ipairs(
                    draft.Records
                ) do
                    if record.UserId == userId then
                        duplicateIndex =
                            index
                    end

                    if draft.EditUserId
                        and record.UserId
                            == draft.EditUserId
                    then
                        editingIndex =
                            index
                    end
                end

                if duplicateIndex
                    and duplicateIndex
                        ~= editingIndex
                then
                    managerStatus.Text =
                        "That UserId is already saved."

                    managerStatus.TextColor3 =
                        color.Yellow

                    saveContactButton.Text =
                        draft.EditUserId
                            and "Update"
                            or "Save"

                    return
                end

                if not editingIndex
                    and #draft.Records >= 25
                then
                    managerStatus.Text =
                        "The saved-recipient limit is 25."

                    managerStatus.TextColor3 =
                        color.Red

                    saveContactButton.Text =
                        "Save"

                    return
                end

                local label =
                    GAG2PremiumRecipientText(
                        labelBox.Text,
                        36
                    )

                if label == "" then
                    label =
                        username
                end

                local previous =
                    editingIndex
                    and draft.Records[
                        editingIndex
                    ]
                    or nil

                local record = {
                    UserId =
                        userId,

                    Name =
                        username,

                    Label =
                        label,

                    Favorite =
                        draft.Favorite == true,

                    LastUsedAt =
                        previous
                        and previous.LastUsedAt
                        or 0,

                    AddedAt =
                        previous
                        and previous.AddedAt
                        or os.time(),
                }

                if editingIndex then
                    draft.Records[
                        editingIndex
                    ] =
                        record
                else
                    table.insert(
                        draft.Records,
                        record
                    )
                end

                state.SavedRecipients.Commit(
                    draft.Records,
                    draft.Recent
                )

                draft.Records =
                    GAG2PremiumNormalizeRecipientRecords(
                        SOPHIA_MAIL_STATE.SavedRecipients,
                        25,
                        true
                    )

                draft.ResetEditor()

                managerStatus.Text =
                    "@"
                    .. username
                    .. " was saved."

                managerStatus.TextColor3 =
                    color.Green

                draft.Render()
            end)

            draft.UpdateFavorite()
            draft.Render()
        end

    state.SavedRecipients.ValueButton.MouseButton1Click:Connect(function()
        state.SavedRecipients.Show(
            recipientBox
        )
    end)

    state.Filters.Show =
        function()
            if state.Running
                or state.Busy
            then
                return
            end

            if type(
                state.ValueSession
            ) == "table"
                and state.ValueSession.Status
                    ~= "Complete"
            then
                messageText.Text =
                    "Finish or safely end the paused delivery before changing filters."

                messageText.TextColor3 =
                    color.Yellow

                return
            end

            local inventory =
                scanInventory()

            local draft = {
                Tab = "Fruits",
                Search = "",

                Fruits =
                    GAG2PremiumFilterSelectionMap(
                        state.Filters.Fruits
                    ),

                Mutations =
                    GAG2PremiumFilterSelectionMap(
                        state.Filters.Mutations
                    ),

                FruitOptionsMap = {},
                MutationOptionsMap = {},

                FruitIcons = {},
                FruitOwned = {},
                MutationOwned = {},
            }

            draft.AddOption =
                function(
                    target,
                    value
                )
                    local display =
                        tostring(
                            value or ""
                        )
                            :gsub(
                                "[%c]+",
                                ""
                            )
                            :gsub(
                                "^%s+",
                                ""
                            )
                            :gsub(
                                "%s+$",
                                ""
                            )

                    local key =
                        GAG2PremiumFilterKey(
                            display
                        )

                    if key ~= "" then
                        target[key] =
                            display
                    end
                end

            for _, fruit in ipairs(
                inventory
            ) do
                local fruitKey =
                    GAG2PremiumFilterKey(
                        fruit.Name
                    )

                if fruitKey ~= "" then
                    draft.FruitOwned[
                        fruitKey
                    ] =
                        (
                            tonumber(
                                draft.FruitOwned[
                                    fruitKey
                                ]
                            )
                            or 0
                        )
                        + 1
                end

                local mutationText =
                    tostring(
                        fruit.Mutation
                        or "Normal"
                    )

                local foundMutation =
                    false

                for part in mutationText:gmatch(
                    "[^,%|/;]+"
                ) do
                    local mutationKey =
                        GAG2PremiumFilterKey(
                            part
                        )

                    if mutationKey ~= "" then
                        foundMutation =
                            true

                        draft.MutationOwned[
                            mutationKey
                        ] =
                            (
                                tonumber(
                                    draft.MutationOwned[
                                        mutationKey
                                    ]
                                )
                                or 0
                            )
                            + 1
                    end
                end

                if not foundMutation then
                    draft.MutationOwned.normal =
                        (
                            tonumber(
                                draft.MutationOwned.normal
                            )
                            or 0
                        )
                        + 1
                end
            end

            local seedData

            if type(
                SophiaShopRequireModule
            ) == "function" then
                local ok,
                    result =
                    pcall(
                        SophiaShopRequireModule,
                        "SharedModules.SeedData"
                    )

                if ok
                    and type(result) == "table"
                then
                    seedData =
                        result
                end
            end

            if type(seedData) == "table" then
                for _, row in pairs(
                    seedData
                ) do
                    if type(row) == "table"
                        and row.MutationSeed
                            ~= true
                    then
                        local fruitName =
                            tostring(
                                row.FruitName
                                or row.SeedName
                                or row.CropName
                                or row.Name
                                or ""
                            )
                                :gsub(
                                    "[%c]+",
                                    ""
                                )
                                :gsub(
                                    "^%s+",
                                    ""
                                )
                                :gsub(
                                    "%s+$",
                                    ""
                                )

                        local fruitKey =
                            GAG2PremiumFilterKey(
                                fruitName
                            )

                        if fruitKey ~= "" then
                            draft.AddOption(
                                draft.FruitOptionsMap,
                                fruitName
                            )

                            local icon =
                                valuePreviewFruitIcon(
                                    nil,
                                    row
                                )

                            if icon ~= "" then
                                draft.FruitIcons[
                                    fruitKey
                                ] =
                                    icon
                            end
                        end
                    end
                end
            end

            if type(
                SophiaSellGetFruitDropdownValues
            ) == "function" then
                local ok,
                    fruitValues =
                    pcall(
                        SophiaSellGetFruitDropdownValues
                    )

                if ok
                    and type(fruitValues)
                        == "table"
                then
                    for _, fruitName in ipairs(
                        fruitValues
                    ) do
                        if GAG2PremiumFilterKey(
                            fruitName
                        ) ~= "all"
                        then
                            draft.AddOption(
                                draft.FruitOptionsMap,
                                fruitName
                            )
                        end
                    end
                end
            end

            if type(
                SophiaFarmBuildMutationNameCache
            ) == "function" then
                local ok,
                    mutationCache =
                    pcall(
                        SophiaFarmBuildMutationNameCache,
                        true
                    )

                if ok
                    and type(mutationCache)
                        == "table"
                    and type(
                        mutationCache.Values
                    ) == "table"
                then
                    for _, mutationName in ipairs(
                        mutationCache.Values
                    ) do
                        draft.AddOption(
                            draft.MutationOptionsMap,
                            mutationName
                        )
                    end
                end
            end

            draft.AddOption(
                draft.MutationOptionsMap,
                "Normal"
            )

            for _, display in pairs(
                draft.Fruits
            ) do
                draft.AddOption(
                    draft.FruitOptionsMap,
                    display
                )
            end

            for _, display in pairs(
                draft.Mutations
            ) do
                draft.AddOption(
                    draft.MutationOptionsMap,
                    display
                )
            end

            draft.FruitOptions = {}
            draft.MutationOptions = {}

            for _, display in pairs(
                draft.FruitOptionsMap
            ) do
                table.insert(
                    draft.FruitOptions,
                    display
                )
            end

            for _, display in pairs(
                draft.MutationOptionsMap
            ) do
                table.insert(
                    draft.MutationOptions,
                    display
                )
            end

            table.sort(
                draft.FruitOptions,
                function(left, right)
                    return tostring(
                        left
                    ):lower()
                        < tostring(
                            right
                        ):lower()
                end
            )

            table.sort(
                draft.MutationOptions,
                function(left, right)
                    return tostring(
                        left
                    ):lower()
                        < tostring(
                            right
                        ):lower()
                end
            )

            closeModal()

            overlay.Visible =
                true

            local modal =
                create(
                    "Frame",
                    {
                        AnchorPoint =
                            Vector2.new(
                                0.5,
                                0.5
                            ),

                        Position =
                            UDim2.fromScale(
                                0.5,
                                0.5
                            ),

                        Size =
                            UDim2.fromOffset(
                                620,
                                530
                            ),

                        BackgroundColor3 =
                            color.Card,

                        ZIndex =
                            51,
                    },
                    overlay
                )

            round(
                modal,
                18
            )

            outline(
                modal,
                color.Border
            )

            local heading =
                text(
                    modal,
                    "Fruit & Mutation Filters",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        28
                    ),
                    UDim2.fromOffset(
                        18,
                        15
                    ),
                    18,
                    color.Text,
                    nil,
                    Enum.Font.GothamBold
                )

            heading.ZIndex =
                52

            local subtitle =
                text(
                    modal,
                    "All in-game options are shown. Owned counts come from your current inventory.",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        20
                    ),
                    UDim2.fromOffset(
                        18,
                        46
                    ),
                    9,
                    color.Muted
                )

            subtitle.ZIndex =
                52

            local searchBox =
                box(
                    modal,
                    "Search fruits or mutations",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        42
                    ),
                    UDim2.fromOffset(
                        18,
                        75
                    )
                )

            searchBox.ZIndex =
                53

            local fruitTab =
                button(
                    modal,
                    "Fruits",
                    UDim2.fromOffset(
                        280,
                        38
                    ),
                    UDim2.fromOffset(
                        18,
                        128
                    ),
                    true
                )

            local mutationTab =
                button(
                    modal,
                    "Mutations",
                    UDim2.fromOffset(
                        280,
                        38
                    ),
                    UDim2.fromOffset(
                        322,
                        128
                    ),
                    false
                )

            fruitTab.ZIndex =
                53

            mutationTab.ZIndex =
                53

            local selectAllButton =
                button(
                    modal,
                    "Select visible",
                    UDim2.fromOffset(
                        138,
                        36
                    ),
                    UDim2.fromOffset(
                        18,
                        177
                    ),
                    false
                )

            local clearSelectionButton =
                button(
                    modal,
                    "Clear selection",
                    UDim2.fromOffset(
                        138,
                        36
                    ),
                    UDim2.fromOffset(
                        166,
                        177
                    ),
                    false
                )

            selectAllButton.ZIndex =
                53

            clearSelectionButton.ZIndex =
                53

            local selectionStatus =
                text(
                    modal,
                    "All selected",
                    UDim2.fromOffset(
                        280,
                        36
                    ),
                    UDim2.fromOffset(
                        322,
                        177
                    ),
                    9,
                    color.Muted,
                    Enum.TextXAlignment.Right,
                    Enum.Font.GothamMedium
                )

            selectionStatus.ZIndex =
                52

            local optionList =
                create(
                    "ScrollingFrame",
                    {
                        BackgroundColor3 =
                            color.Field,

                        BorderSizePixel =
                            0,

                        Size =
                            UDim2.new(
                                1,
                                -36,
                                0,
                                224
                            ),

                        Position =
                            UDim2.fromOffset(
                                18,
                                222
                            ),

                        CanvasSize =
                            UDim2.fromOffset(
                                0,
                                0
                            ),

                        AutomaticCanvasSize =
                            Enum.AutomaticSize.Y,

                        ScrollingDirection =
                            Enum.ScrollingDirection.Y,

                        ScrollBarThickness =
                            3,

                        ScrollBarImageColor3 =
                            color.Border,

                        ClipsDescendants =
                            true,

                        ZIndex =
                            52,
                    },
                    modal
                )

            round(
                optionList,
                11
            )

            outline(
                optionList,
                color.Border
            )

            local optionLayout =
                create(
                    "UIListLayout",
                    {
                        Padding =
                            UDim.new(
                                0,
                                5
                            ),

                        SortOrder =
                            Enum.SortOrder.LayoutOrder,
                    },
                    optionList
                )

            local optionPadding =
                create(
                    "UIPadding",
                    {
                        PaddingTop =
                            UDim.new(
                                0,
                                6
                            ),

                        PaddingBottom =
                            UDim.new(
                                0,
                                6
                            ),

                        PaddingLeft =
                            UDim.new(
                                0,
                                6
                            ),

                        PaddingRight =
                            UDim.new(
                                0,
                                6
                            ),
                    },
                    optionList
                )

            draft.RefreshTabs =
                function()
                    fruitTab.BackgroundColor3 =
                        draft.Tab == "Fruits"
                                and color.Accent
                            or color.Field

                    mutationTab.BackgroundColor3 =
                        draft.Tab == "Mutations"
                                and color.Accent
                            or color.Field

                    fruitTab.TextColor3 =
                        draft.Tab == "Fruits"
                                and color.Text
                            or color.Secondary

                    mutationTab.TextColor3 =
                        draft.Tab == "Mutations"
                                and color.Text
                            or color.Secondary
                end

            draft.Render =
                function()
                    clearRows(
                        optionList,
                        optionLayout
                    )

                    local options =
                        draft.Tab == "Fruits"
                        and draft.FruitOptions
                        or draft.MutationOptions

                    local selected =
                        draft.Tab == "Fruits"
                        and draft.Fruits
                        or draft.Mutations

                    local query =
                        GAG2PremiumFilterKey(
                            draft.Search
                        )

                    local visibleCount = 0
                    local selectedCount = 0

                    for _ in pairs(
                        selected
                    ) do
                        selectedCount +=
                            1
                    end

                    for optionIndex, display in ipairs(
                        options
                    ) do
                        local optionKey =
                            GAG2PremiumFilterKey(
                                display
                            )

                        if query == ""
                            or optionKey:find(
                                query,
                                1,
                                true
                            )
                        then
                            visibleCount +=
                                1

                            local isSelected =
                                selected[
                                    optionKey
                                ] ~= nil

                            local ownedMap =
                                draft.Tab == "Fruits"
                                and draft.FruitOwned
                                or draft.MutationOwned

                            local owned =
                                tonumber(
                                    ownedMap[
                                        optionKey
                                    ]
                                )
                                or 0

                            local icon =
                                draft.Tab == "Fruits"
                                and tostring(
                                    draft.FruitIcons[
                                        optionKey
                                    ]
                                    or ""
                                )
                                or ""

                            local optionButton =
                                button(
                                    optionList,
                                    isSelected
                                        and "✓"
                                        or "",
                                    UDim2.new(
                                        1,
                                        -4,
                                        0,
                                        42
                                    ),
                                    UDim2.fromOffset(
                                        0,
                                        0
                                    ),
                                    isSelected
                                )

                            optionButton.LayoutOrder =
                                optionIndex

                            optionButton.ZIndex =
                                53

                            optionButton.TextSize =
                                14

                            optionButton.TextXAlignment =
                                Enum.TextXAlignment.Left

                            create(
                                "UIPadding",
                                {
                                    PaddingLeft =
                                        UDim.new(
                                            0,
                                            12
                                        ),

                                    PaddingRight =
                                        UDim.new(
                                            0,
                                            12
                                        ),
                                },
                                optionButton
                            )

                            local nameOffset =
                                34

                            if icon ~= "" then
                                create(
                                    "ImageLabel",
                                    {
                                        BackgroundTransparency =
                                            1,

                                        Image =
                                            icon,

                                        Size =
                                            UDim2.fromOffset(
                                                26,
                                                26
                                            ),

                                        Position =
                                            UDim2.fromOffset(
                                                34,
                                                8
                                            ),

                                        ScaleType =
                                            Enum.ScaleType.Fit,

                                        ZIndex =
                                            54,
                                    },
                                    optionButton
                                )

                                nameOffset =
                                    68
                            end

                            local optionName =
                                text(
                                    optionButton,
                                    display,
                                    UDim2.new(
                                        1,
                                        -nameOffset
                                            - 126,
                                        1,
                                        0
                                    ),
                                    UDim2.fromOffset(
                                        nameOffset,
                                        0
                                    ),
                                    10,
                                    color.Text,
                                    Enum.TextXAlignment.Left,
                                    Enum.Font.GothamSemibold
                                )

                            optionName.ZIndex =
                                54

                            local ownedText =
                                text(
                                    optionButton,
                                    "Owned: "
                                        .. tostring(
                                            owned
                                        ),
                                    UDim2.fromOffset(
                                        104,
                                        42
                                    ),
                                    UDim2.new(
                                        1,
                                        -116,
                                        0,
                                        0
                                    ),
                                    9,
                                    owned > 0
                                        and color.Green
                                        or color.Muted,
                                    Enum.TextXAlignment.Right,
                                    Enum.Font.GothamMedium
                                )

                            ownedText.ZIndex =
                                54

                            optionButton.MouseButton1Click:Connect(function()
                                if selected[
                                    optionKey
                                ] ~= nil
                                then
                                    selected[
                                        optionKey
                                    ] =
                                        nil
                                else
                                    selected[
                                        optionKey
                                    ] =
                                        display
                                end

                                draft.Render()
                            end)
                        end
                    end

                    selectionStatus.Text =
                        selectedCount <= 0
                                and "All allowed · "
                                    .. tostring(
                                        visibleCount
                                    )
                                    .. " shown"
                            or tostring(
                                selectedCount
                            )
                                .. " selected · "
                                .. tostring(
                                    visibleCount
                                )
                                .. " shown"

                    if visibleCount <= 0 then
                        local empty =
                            text(
                                optionList,
                                "No matching options.",
                                UDim2.new(
                                    1,
                                    -4,
                                    0,
                                    90
                                ),
                                UDim2.fromOffset(
                                    0,
                                    0
                                ),
                                10,
                                color.Muted,
                                Enum.TextXAlignment.Center,
                                Enum.Font.GothamMedium
                            )

                        empty.LayoutOrder =
                            1

                        empty.ZIndex =
                            53
                    end
                end

            fruitTab.MouseButton1Click:Connect(function()
                draft.Tab =
                    "Fruits"

                draft.RefreshTabs()
                draft.Render()
            end)

            mutationTab.MouseButton1Click:Connect(function()
                draft.Tab =
                    "Mutations"

                draft.RefreshTabs()
                draft.Render()
            end)

            searchBox:GetPropertyChangedSignal(
                "Text"
            ):Connect(function()
                draft.Search =
                    searchBox.Text

                draft.Render()
            end)

            selectAllButton.MouseButton1Click:Connect(function()
                local options =
                    draft.Tab == "Fruits"
                    and draft.FruitOptions
                    or draft.MutationOptions

                local selected =
                    draft.Tab == "Fruits"
                    and draft.Fruits
                    or draft.Mutations

                local query =
                    GAG2PremiumFilterKey(
                        draft.Search
                    )

                for _, display in ipairs(
                    options
                ) do
                    local optionKey =
                        GAG2PremiumFilterKey(
                            display
                        )

                    if query == ""
                        or optionKey:find(
                            query,
                            1,
                            true
                        )
                    then
                        selected[
                            optionKey
                        ] =
                            display
                    end
                end

                draft.Render()
            end)

            clearSelectionButton.MouseButton1Click:Connect(function()
                if draft.Tab == "Fruits" then
                    draft.Fruits = {}
                else
                    draft.Mutations = {}
                end

                draft.Render()
            end)

            local cancelButton =
                button(
                    modal,
                    "Cancel",
                    UDim2.fromOffset(
                        180,
                        46
                    ),
                    UDim2.fromOffset(
                        18,
                        466
                    ),
                    false
                )

            local applyButton =
                button(
                    modal,
                    "Apply filters",
                    UDim2.fromOffset(
                        386,
                        46
                    ),
                    UDim2.fromOffset(
                        216,
                        466
                    ),
                    true
                )

            cancelButton.ZIndex =
                53

            applyButton.ZIndex =
                53

            cancelButton.MouseButton1Click:Connect(
                closeModal
            )

            applyButton.MouseButton1Click:Connect(function()
                state.Filters.Fruits =
                    GAG2PremiumFilterSelectionMap(
                        draft.Fruits
                    )

                state.Filters.Mutations =
                    GAG2PremiumFilterSelectionMap(
                        draft.Mutations
                    )

                SOPHIA_MAIL_STATE.FilterFruits =
                    GAG2PremiumNormalizeFilterSelection(
                        state.Filters.Fruits
                    )

                SOPHIA_MAIL_STATE.FilterMutations =
                    GAG2PremiumNormalizeFilterSelection(
                        state.Filters.Mutations
                    )

                GAG2PremiumSaveSettings()

                state.Filters.UpdateButton()
                closeModal()

                task.spawn(function()
                    protectedCall(
                        "Mail filters",
                        rebuildPlan
                    )
                end)
            end)

            draft.RefreshTabs()
            draft.Render()
        end

    local function showStrategySettings()
        if state.Running
            or state.Busy
        then
            return
        end

        closeModal()

        overlay.Visible =
            true

        local modal =
            create(
                "Frame",
                {
                    AnchorPoint =
                        Vector2.new(
                            0.5,
                            0.5
                        ),

                    Position =
                        UDim2.fromScale(
                            0.5,
                            0.5
                        ),

                    Size =
                        UDim2.fromOffset(
                            610,
                            405
                        ),

                    BackgroundColor3 =
                        color.Card,

                    ZIndex =
                        51,
                },
                overlay
            )

        round(
            modal,
            18
        )

        outline(
            modal,
            color.Border
        )

        local heading =
            text(
                modal,
                "Value Strategy",
                UDim2.new(
                    1,
                    -36,
                    0,
                    28
                ),
                UDim2.fromOffset(
                    18,
                    16
                ),
                18,
                color.Text,
                nil,
                Enum.Font.GothamBold
            )

        heading.ZIndex =
            52

        local subtitle =
            text(
                modal,
                "Choose how SOPHIA selects fruits and how much extra value is allowed.",
                UDim2.new(
                    1,
                    -36,
                    0,
                    20
                ),
                UDim2.fromOffset(
                    18,
                    47
                ),
                10,
                color.Muted
            )

        subtitle.ZIndex =
            52

        local draftStrategy =
            GAG2PremiumNormalizeValueStrategy(
                state.Strategy
            )

        local draftLimit =
            GAG2PremiumNormalizeExtraLimitMode(
                state.ExtraLimitMode
            )

        local draftCustom =
            GAG2PremiumNormalizeExtraLimitCustom(
                state.ExtraLimitCustom
            )

        local strategyChoices = {
            "Send at least",
            "Closest amount",
            "Don't go over",
        }

        local limitChoices = {
            "No limit",
            "1%",
            "5%",
            "10%",
            "Custom",
        }

        local strategyButtons = {}
        local limitButtons = {}

        text(
            modal,
            "STRATEGY",
            UDim2.fromOffset(
                200,
                18
            ),
            UDim2.fromOffset(
                18,
                82
            ),
            9,
            color.Muted,
            nil,
            Enum.Font.GothamBold
        ).ZIndex =
            52

        for index, choice in ipairs(
            strategyChoices
        ) do
            local choiceButton =
                button(
                    modal,
                    choice,
                    UDim2.fromOffset(
                        184,
                        40
                    ),
                    UDim2.fromOffset(
                        18
                        + (
                            index - 1
                        ) * 196,
                        105
                    ),
                    false
                )

            choiceButton.ZIndex =
                53

            choiceButton.TextSize =
                10

            strategyButtons[choice] =
                choiceButton
        end

        text(
            modal,
            "MAXIMUM EXTRA VALUE",
            UDim2.fromOffset(
                260,
                18
            ),
            UDim2.fromOffset(
                18,
                166
            ),
            9,
            color.Muted,
            nil,
            Enum.Font.GothamBold
        ).ZIndex =
            52

        for index, choice in ipairs(
            limitChoices
        ) do
            local choiceButton =
                button(
                    modal,
                    choice,
                    UDim2.fromOffset(
                        106,
                        38
                    ),
                    UDim2.fromOffset(
                        18
                        + (
                            index - 1
                        ) * 116,
                        190
                    ),
                    false
                )

            choiceButton.ZIndex =
                53

            choiceButton.TextSize =
                9

            limitButtons[choice] =
                choiceButton
        end

        local customBox =
            create(
                "TextBox",
                {
                    BackgroundColor3 =
                        color.Field,

                    Size =
                        UDim2.new(
                            1,
                            -36,
                            0,
                            43
                        ),

                    Position =
                        UDim2.fromOffset(
                            18,
                            248
                        ),

                    Text =
                        draftCustom,

                    PlaceholderText =
                        "Example: 2.5% or $5M",

                    TextColor3 =
                        color.Text,

                    PlaceholderColor3 =
                        color.Muted,

                    Font =
                        Enum.Font.GothamMedium,

                    TextSize =
                        11,

                    ClearTextOnFocus =
                        false,

                    ZIndex =
                        53,
                },
                modal
            )

        round(
            customBox,
            10
        )

        outline(
            customBox,
            color.Border
        )

        local customHint =
            text(
                modal,
                "Custom accepts a percentage such as 2.5% or a fixed value such as $5M.",
                UDim2.new(
                    1,
                    -36,
                    0,
                    18
                ),
                UDim2.fromOffset(
                    18,
                    296
                ),
                9,
                color.Muted
            )

        customHint.ZIndex =
            52

        local function refreshChoices()
            for choice, choiceButton in pairs(
                strategyButtons
            ) do
                local selected =
                    choice == draftStrategy

                choiceButton.BackgroundColor3 =
                    selected
                            and color.Accent
                        or color.Field

                choiceButton.TextColor3 =
                    selected
                            and color.Text
                        or color.Secondary
            end

            for choice, choiceButton in pairs(
                limitButtons
            ) do
                local selected =
                    choice == draftLimit

                choiceButton.BackgroundColor3 =
                    selected
                            and color.Accent
                        or color.Field

                choiceButton.TextColor3 =
                    selected
                            and color.Text
                        or color.Secondary
            end

            customBox.Visible =
                draftLimit == "Custom"

            customHint.Visible =
                draftLimit == "Custom"
        end

        for choice, choiceButton in pairs(
            strategyButtons
        ) do
            choiceButton.MouseButton1Click:Connect(function()
                draftStrategy =
                    choice

                refreshChoices()
            end)
        end

        for choice, choiceButton in pairs(
            limitButtons
        ) do
            choiceButton.MouseButton1Click:Connect(function()
                draftLimit =
                    choice

                refreshChoices()
            end)
        end

        refreshChoices()

        local cancel =
            button(
                modal,
                "Cancel",
                UDim2.fromOffset(
                    175,
                    46
                ),
                UDim2.fromOffset(
                    18,
                    339
                ),
                false
            )

        cancel.ZIndex =
            53

        cancel.MouseButton1Click:Connect(
            closeModal
        )

        local save =
            button(
                modal,
                "Save settings",
                UDim2.fromOffset(
                    381,
                    46
                ),
                UDim2.fromOffset(
                    211,
                    339
                ),
                true
            )

        save.ZIndex =
            53

        save.MouseButton1Click:Connect(function()
            if draftLimit == "Custom" then
                local custom =
                    GAG2PremiumNormalizeExtraLimitCustom(
                        customBox.Text
                    )

                local valid =
                    false

            if custom:find(
                "%",
                1,
                true
            ) then
                    local percentage =
                        tonumber(
                            custom
                                :gsub(
                                    "%%",
                                    ""
                                )
                                :gsub(
                                    "%s+",
                                    ""
                                )
                        )

                    valid =
                        percentage ~= nil
                        and percentage >= 0
                else
                    local fixed =
                        parseValue(
                            custom
                        )

                    valid =
                        fixed ~= nil
                        and fixed >= 0
                end

                if not valid then
                    customHint.Text =
                        "Enter a valid percentage like 2.5% or value like $5M."

                    customHint.TextColor3 =
                        color.Red

                    return
                end

                draftCustom =
                    custom
            end

            state.Strategy =
                GAG2PremiumNormalizeValueStrategy(
                    draftStrategy
                )

            state.ExtraLimitMode =
                GAG2PremiumNormalizeExtraLimitMode(
                    draftLimit
                )

            state.ExtraLimitCustom =
                GAG2PremiumNormalizeExtraLimitCustom(
                    draftCustom
                )

            SOPHIA_MAIL_STATE.ValueStrategy =
                state.Strategy

            SOPHIA_MAIL_STATE.ExtraLimitMode =
                state.ExtraLimitMode

            SOPHIA_MAIL_STATE.ExtraLimitCustom =
                state.ExtraLimitCustom

            GAG2PremiumSaveSettings()

            updateStrategyButton()
            closeModal()

            task.spawn(function()
                protectedCall(
                    "Strategy settings",
                    rebuildPlan
                )
            end)
        end)
    end

    showFruitPreview =
        function(entry)
            if type(entry) ~= "table" then
                return
            end

            closeModal()

            overlay.Visible =
                true

            local modal =
                create(
                    "Frame",
                    {
                        AnchorPoint =
                            Vector2.new(
                                0.5,
                                0.5
                            ),

                        Position =
                            UDim2.fromScale(
                                0.5,
                                0.5
                            ),

                        Size =
                            UDim2.fromOffset(
                                650,
                                540
                            ),

                        BackgroundColor3 =
                            color.Card,

                        ZIndex =
                            51,
                    },
                    overlay
                )

            round(
                modal,
                18
            )

            outline(
                modal,
                color.Border
            )

            local heading =
                text(
                    modal,
                    "Selected Fruits",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        26
                    ),
                    UDim2.fromOffset(
                        18,
                        13
                    ),
                    17,
                    color.Text,
                    nil,
                    Enum.Font.GothamBold
                )

            heading.ZIndex =
                52

            local subtitleLabel =
                text(
                    modal,
                    "@"
                        .. tostring(
                            entry.Recipient
                            and entry.Recipient.Name
                            or "Unknown"
                        )
                        .. "  ·  "
                        .. tostring(
                            #(
                                entry.Fruits
                                or {}
                            )
                        )
                        .. " fruits  ·  "
                        .. tostring(
                            entry.Mails
                            or 0
                        )
                        .. (
                            tonumber(
                                entry.Mails
                            ) == 1
                                and " mail"
                                or " mails"
                        ),
                    UDim2.new(
                        1,
                        -36,
                        0,
                        20
                    ),
                    UDim2.fromOffset(
                        18,
                        40
                    ),
                    9,
                    color.Muted
                )

            subtitleLabel.ZIndex =
                52

            local summaryStrip =
                create(
                    "Frame",
                    {
                        BackgroundColor3 =
                            color.Field,

                        Size =
                            UDim2.new(
                                1,
                                -36,
                                0,
                                70
                            ),

                        Position =
                            UDim2.fromOffset(
                                18,
                                69
                            ),

                        ZIndex =
                            52,
                    },
                    modal
                )

            round(
                summaryStrip,
                11
            )

            outline(
                summaryStrip,
                color.Border
            )

            local function addModalStat(
                titleValue,
                valueText,
                x,
                width,
                valueColor
            )
                local titleLabel =
                    text(
                        summaryStrip,
                        titleValue,
                        UDim2.fromOffset(
                            width,
                            18
                        ),
                        UDim2.fromOffset(
                            x,
                            11
                        ),
                        9,
                        color.Muted,
                        Enum.TextXAlignment.Center,
                        Enum.Font.GothamBold
                    )

                titleLabel.ZIndex =
                    53

                local valueLabel =
                    text(
                        summaryStrip,
                        valueText,
                        UDim2.fromOffset(
                            width,
                            25
                        ),
                        UDim2.fromOffset(
                            x,
                            32
                        ),
                        13,
                        valueColor
                            or color.Text,
                        Enum.TextXAlignment.Center,
                        Enum.Font.GothamBold
                    )

                valueLabel.ZIndex =
                    53
            end

            addModalStat(
                "TARGET",
                formatValue(
                    entry.Target
                    or (
                        entry.Recipient
                        and entry.Recipient.Target
                    )
                    or 0
                ),
                8,
                186,
                color.Text
            )

            addModalStat(
                "SENDING",
                formatValue(
                    entry.Value
                    or 0
                ),
                204,
                186,
                color.Text
            )

            addModalStat(
                "EXTRA "
                    .. formatSignedMailPercent(
                        entry.ExtraPercent
                        or 0
                    ),
                formatSignedMailValue(
                    entry.Extra
                    or 0
                ),
                400,
                186,
                (
                    tonumber(
                        entry.Extra
                    )
                    or 0
                ) >= 0
                        and color.Green
                    or color.Yellow
            )

            local fruitList =
                create(
                    "ScrollingFrame",
                    {
                        BackgroundTransparency =
                            1,

                        BorderSizePixel =
                            0,

                        Size =
                            UDim2.new(
                                1,
                                -36,
                                0,
                                326
                            ),

                        Position =
                            UDim2.fromOffset(
                                18,
                                151
                            ),

                        CanvasSize =
                            UDim2.fromOffset(
                                0,
                                0
                            ),

                        AutomaticCanvasSize =
                            Enum.AutomaticSize.Y,

                        ScrollingDirection =
                            Enum.ScrollingDirection.Y,

                        ScrollBarThickness =
                            3,

                        ScrollBarImageColor3 =
                            color.Border,

                        ClipsDescendants =
                            true,

                        ZIndex =
                            52,
                    },
                    modal
                )

            create(
                "UIListLayout",
                {
                    Padding =
                        UDim.new(
                            0,
                            6
                        ),

                    SortOrder =
                        Enum.SortOrder.LayoutOrder,
                },
                fruitList
            )

            local fruits =
                type(entry.Fruits) == "table"
                and entry.Fruits
                or {}

            local layoutOrder =
                0

            if #fruits == 0 then
                local emptyLabel =
                    text(
                        fruitList,
                        "No fruits were selected for this recipient.",
                        UDim2.new(
                            1,
                            -4,
                            0,
                            120
                        ),
                        UDim2.fromOffset(
                            0,
                            0
                        ),
                        11,
                        color.Muted,
                        Enum.TextXAlignment.Center,
                        Enum.Font.GothamMedium
                    )

                emptyLabel.LayoutOrder =
                    1

                emptyLabel.ZIndex =
                    53
            else
                for firstIndex = 1,
                    #fruits,
                    BATCH_LIMIT
                do
                    local lastIndex =
                        math.min(
                            firstIndex
                                + BATCH_LIMIT
                                - 1,
                            #fruits
                        )

                    local batchNumber =
                        math.floor(
                            (
                                firstIndex - 1
                            )
                            / BATCH_LIMIT
                        )
                        + 1

                    local batchValue =
                        0

                    for fruitIndex = firstIndex,
                        lastIndex
                    do
                        batchValue +=
                            tonumber(
                                fruits[
                                    fruitIndex
                                ].Value
                            )
                            or 0
                    end

                    layoutOrder +=
                        1

                    local batchHeader =
                        create(
                            "Frame",
                            {
                                BackgroundColor3 =
                                    color.Hover,

                                Size =
                                    UDim2.new(
                                        1,
                                        -4,
                                        0,
                                        31
                                    ),

                                LayoutOrder =
                                    layoutOrder,

                                ZIndex =
                                    52,
                            },
                            fruitList
                        )

                    round(
                        batchHeader,
                        9
                    )

                    local batchLabel =
                        text(
                            batchHeader,
                            "MAIL "
                                .. tostring(
                                    batchNumber
                                )
                                .. "  ·  "
                                .. tostring(
                                    lastIndex
                                    - firstIndex
                                    + 1
                                )
                                .. "/"
                                .. tostring(
                                    BATCH_LIMIT
                                )
                                .. " FRUITS  ·  "
                                .. formatValue(
                                    batchValue
                                ),
                            UDim2.new(
                                1,
                                -24,
                                1,
                                0
                            ),
                            UDim2.fromOffset(
                                12,
                                0
                            ),
                            9,
                            color.Secondary,
                            nil,
                            Enum.Font.GothamBold
                        )

                    batchLabel.ZIndex =
                        53

                    for fruitIndex = firstIndex,
                        lastIndex
                    do
                        local fruit =
                            fruits[
                                fruitIndex
                            ]

                        layoutOrder +=
                            1

                        local fruitRow =
                            create(
                                "Frame",
                                {
                                    BackgroundColor3 =
                                        color.Field,

                                    Size =
                                        UDim2.new(
                                            1,
                                            -4,
                                            0,
                                            54
                                        ),

                                    LayoutOrder =
                                        layoutOrder,

                                    ZIndex =
                                        52,
                                },
                                fruitList
                            )

                        round(
                            fruitRow,
                            10
                        )

                        outline(
                            fruitRow,
                            color.Border
                        )

                        local iconHolder =
                            create(
                                "Frame",
                                {
                                    BackgroundColor3 =
                                        color.Hover,

                                    Size =
                                        UDim2.fromOffset(
                                            40,
                                            40
                                        ),

                                    Position =
                                        UDim2.fromOffset(
                                            8,
                                            7
                                        ),

                                    ZIndex =
                                        53,
                                },
                                fruitRow
                            )

                        round(
                            iconHolder,
                            9
                        )

                        local fruitIcon =
                            create(
                                "ImageLabel",
                                {
                                    BackgroundTransparency =
                                        1,

                                    Image =
                                        tostring(
                                            fruit.Icon
                                            or ""
                                        ),

                                    Size =
                                        UDim2.new(
                                            1,
                                            -6,
                                            1,
                                            -6
                                        ),

                                    Position =
                                        UDim2.fromOffset(
                                            3,
                                            3
                                        ),

                                    ScaleType =
                                        Enum.ScaleType.Fit,

                                    ZIndex =
                                        54,
                                },
                                iconHolder
                            )

                        round(
                            fruitIcon,
                            7
                        )

                        local fruitName =
                            text(
                                fruitRow,
                                tostring(
                                    fruit.Name
                                    or "Unknown fruit"
                                ),
                                UDim2.new(
                                    1,
                                    -230,
                                    0,
                                    21
                                ),
                                UDim2.fromOffset(
                                    58,
                                    6
                                ),
                                10,
                                color.Text,
                                nil,
                                Enum.Font.GothamSemibold
                            )

                        fruitName.ZIndex =
                            53

                        local details =
                            tostring(
                                fruit.Mutation
                                or "Normal"
                            )

                        if fruit.Favorite == true then
                            details ..=
                                "  ·  Favorite"
                        end

                        details ..=
                            "  ·  Fruit "
                            .. tostring(
                                fruitIndex
                            )

                        local detailLabel =
                            text(
                                fruitRow,
                                details,
                                UDim2.new(
                                    1,
                                    -230,
                                    0,
                                    18
                                ),
                                UDim2.fromOffset(
                                    58,
                                    29
                                ),
                                8,
                                fruit.Favorite == true
                                        and color.Yellow
                                    or color.Muted
                            )

                        detailLabel.ZIndex =
                            53

                        local valueLabel =
                            text(
                                fruitRow,
                                formatValue(
                                    fruit.Value
                                    or 0
                                ),
                                UDim2.fromOffset(
                                    150,
                                    54
                                ),
                                UDim2.new(
                                    1,
                                    -164,
                                    0,
                                    0
                                ),
                                11,
                                color.Text,
                                Enum.TextXAlignment.Right,
                                Enum.Font.GothamBold
                            )

                        valueLabel.ZIndex =
                            53
                    end
                end
            end

            local closeButton =
                button(
                    modal,
                    "Close",
                    UDim2.new(
                        1,
                        -36,
                        0,
                        38
                    ),
                    UDim2.fromOffset(
                        18,
                        489
                    ),
                    false
                )

            closeButton.ZIndex =
                53

            closeButton.MouseButton1Click:Connect(
                closeModal
            )
        end

    local function getSendPacket()
        local sharedModules =
            ReplicatedStorage:FindFirstChild(
                "SharedModules"
            )

        local networkingModule =
            sharedModules
            and sharedModules:FindFirstChild(
                "Networking"
            )

        if not networkingModule
            or not networkingModule:IsA("ModuleScript")
        then
            return nil,
                "SharedModules.Networking was not found"
        end

        local ok, networking =
            pcall(
                require,
                networkingModule
            )

        if not ok
            or type(networking) ~= "table"
        then
            return nil,
                "Networking require failed: "
                    .. tostring(networking)
        end

        local packet =
            type(networking.Mailbox) == "table"
            and networking.Mailbox.SendBatch
            or nil

        if type(packet) ~= "table"
            or type(packet.Fire) ~= "function"
        then
            return nil,
                "Networking.Mailbox.SendBatch is unavailable"
        end

        return packet
    end

    state.Safety.CurrentFruitMap =
        function()
            local fruits = {}

            for _, root in ipairs(
                getRoots()
            ) do
                for _, item in ipairs(
                    root:GetChildren()
                ) do
                    local id =
                        tostring(
                            item:GetAttribute("Id")
                            or item:GetAttribute("FruitId")
                            or ""
                        )

                    if id ~= "" then
                        fruits[id] =
                            item
                    end
                end
            end

            return fruits
        end

    state.Safety.ItemIsFavorite =
        function(
            item,
            fallback
        )
            if typeof(item) == "Instance" then
                return item:GetAttribute(
                    "IsFavorite"
                ) == true
                    or item:GetAttribute(
                        "Favorite"
                    ) == true
                    or item:GetAttribute(
                        "Favorited"
                    ) == true
            end

            return fallback == true
        end

    state.Safety.ValidateValueBatch =
        function(batch)
            GAG2PremiumCheckDay()
            updateQuota()

            if tracker.Used >= DAILY_LIMIT then
                return false,
                    "No daily sends remain.",
                    "DAILY"
            end

            local owned =
                state.Safety.CurrentFruitMap()

            for _, fruit in ipairs(
                batch
            ) do
                local item =
                    owned[
                        tostring(
                            fruit.Id
                        )
                    ]

                if typeof(item) ~= "Instance" then
                    return false,
                        tostring(
                            fruit.Name
                            or "A selected fruit"
                        )
                        .. " is no longer in your inventory.",
                        "INVENTORY"
                end

                if state.Protect
                    and state.Safety.ItemIsFavorite(
                        item,
                        fruit.Favorite
                    )
                then
                    return false,
                        tostring(
                            fruit.Name
                            or "A selected fruit"
                        )
                        .. " became favorited.",
                        "FAVORITE"
                end
            end

            return true
        end

    state.Safety.WaitForValueRemoval =
        function(
            batch,
            timeout
        )
            local deadline =
                os.clock()
                + (
                    tonumber(timeout)
                    or 8
                )

            repeat
                local owned =
                    state.Safety.CurrentFruitMap()

                local remaining =
                    0

                for _, fruit in ipairs(
                    batch
                ) do
                    if owned[
                        tostring(
                            fruit.Id
                        )
                    ] then
                        remaining +=
                            1
                    end
                end

                if remaining == 0 then
                    return true
                end

                task.wait(
                    0.15
                )
            until os.clock() >= deadline

            return false
        end

    state.Safety.WaitForCooldown =
        function()
            while state.LastAccepted do
                local remaining =
                    COOLDOWN
                    - (
                        workspace:GetServerTimeNow()
                        - state.LastAccepted
                    )

                if remaining <= 0 then
                    return not state.Stop
                end

                if state.Stop then
                    return false
                end

                setStatus(
                    string.format(
                        "%.1fs",
                        remaining
                    ),
                    color.Yellow
                )

                task.wait(
                    math.min(
                        0.1,
                        remaining
                    )
                )
            end

            return not state.Stop
        end

    state.Safety.RecordAcceptedMail =
        function(started)
            state.LastAccepted =
                started

            tracker.Used =
                math.min(
                    DAILY_LIMIT,
                    tracker.Used + 1
                )

            SOPHIA_MAIL_STATE.TrackerDay =
                GAG2PremiumToday()

            SOPHIA_MAIL_STATE.TrackerUsed =
                tracker.Used

            updateQuota()
            GAG2PremiumSaveSettings()
        end

    state.Safety.SendValueBatch =
        function(
            packet,
            recipient,
            batch
        )
            local payload = {}

            for _, fruit in ipairs(
                batch
            ) do
                table.insert(
                    payload,
                    {
                        ItemKey =
                            fruit.Id,

                        Count =
                            1,

                        Category =
                            "HarvestedFruits",
                    }
                )
            end

            while not state.Stop do
                local valid,
                    validationMessage,
                    validationType =
                    state.Safety.ValidateValueBatch(
                        batch
                    )

                if not valid then
                    return false,
                        validationMessage,
                        validationType,
                        false
                end

                if not state.Safety.WaitForCooldown() then
                    return false,
                        "Stopped",
                        "STOPPED",
                        false
                end

                valid,
                validationMessage,
                validationType =
                    state.Safety.ValidateValueBatch(
                        batch
                    )

                if not valid then
                    return false,
                        validationMessage,
                        validationType,
                        false
                end

                local started =
                    workspace:GetServerTimeNow()

                setStatus(
                    "Sending",
                    color.Yellow
                )

                local ok,
                    first,
                    second =
                    pcall(function()
                        return packet:Fire(
                            recipient.UserId,
                            payload,
                            ""
                        )
                    end)

                if not ok then
                    return false,
                        tostring(
                            first
                        ),
                        "ERROR",
                        false
                end

                local message =
                    tostring(
                        second or ""
                    )

                if first == true then
                    state.Safety.RecordAcceptedMail(
                        started
                    )

                    local confirmed =
                        state.Safety.WaitForValueRemoval(
                            batch,
                            8
                        )

                    if not confirmed then
                        return false,
                            "The server accepted this mail, but inventory removal could not be confirmed.",
                            "UNCERTAIN",
                            true
                    end

                    return true,
                        message,
                        "CONFIRMED",
                        true
                end

                local lower =
                    message:lower()

                local seconds =
                    tonumber(
                        lower:match(
                            "wait%s+(%d+)%s*s"
                        )
                    )

                if seconds then
                    task.wait(
                        seconds + 0.25
                    )
                elseif lower:find(
                    "daily gift limit",
                    1,
                    true
                ) then
                    tracker.Used =
                        DAILY_LIMIT

                    SOPHIA_MAIL_STATE.TrackerDay =
                        GAG2PremiumToday()

                    SOPHIA_MAIL_STATE.TrackerUsed =
                        DAILY_LIMIT

                    updateQuota()
                    GAG2PremiumSaveSettings()

                    return false,
                        message,
                        "DAILY",
                        false
                else
                    return false,
                        message ~= ""
                                and message
                            or tostring(
                                first
                            ),
                        "REJECTED",
                        false
                end
            end

            return false,
                "Stopped",
                "STOPPED",
                false
        end

    state.Safety.AddFruitHistoryBatch =
        function(
            historyRecord,
            historyItemMap,
            batch
        )
            for _, fruit in ipairs(
                batch
            ) do
                local source =
                    fruit.Item

                local icon = ""

                if typeof(source) == "Instance" then
                    icon =
                        GAG2PremiumHistoryNormalizeIcon(
                            source:GetAttribute("IMG")
                                or source:GetAttribute("Icon")
                                or source:GetAttribute("Image")
                                or source:GetAttribute("TextureId")
                                or (
                                    source:IsA("Tool")
                                    and source.TextureId
                                    or ""
                                )
                        )
                end

                local itemKey =
                    tostring(
                        fruit.Name
                        or "Unknown fruit"
                    )
                    .. "|"
                    .. tostring(
                        fruit.Mutation
                        or "Normal"
                    )
                    .. "|"
                    .. icon

                local historyItem =
                    historyItemMap[
                        itemKey
                    ]

                if not historyItem then
                    historyItem = {
                        Name =
                            tostring(
                                fruit.Name
                                or "Unknown fruit"
                            ),

                        Details =
                            tostring(
                                fruit.Mutation
                                or "Normal"
                            ),

                        Icon = icon,
                        Count = 0,
                        Sent = 0,
                        Value = 0,
                    }

                    historyItemMap[
                        itemKey
                    ] =
                        historyItem

                    table.insert(
                        historyRecord.Items,
                        historyItem
                    )
                end

                historyItem.Count +=
                    1

                historyItem.Sent +=
                    1

                historyItem.Value +=
                    tonumber(
                        fruit.Value
                    )
                    or 0
            end
        end

    state.Safety.RunValueDelivery =
        function(totalMails)
            protectedCall(
                "Delivery",
                function()
                    local packet,
                        packetError =
                        getSendPacket()

                    if not packet then
                        reportError(
                            "Networking",
                            packetError
                        )

                        if type(
                            state.ValueSession
                        ) == "table" then
                            state.ValueSession.Status =
                                "Paused"
                        end

                        return
                    end

                    local session =
                        state.ValueSession

                    if type(session) ~= "table" then
                        return
                    end

                    session.Status =
                        "Running"

                    state.Running =
                        true

                    state.Stop =
                        false

                    progressFill.Size =
                        UDim2.fromScale(
                            0,
                            1
                        )

                    renderRecipients()

                    local completedMails = 0
                    local fruitsSent = 0
                    local valueSent = 0
                    local completedRecipients = 0

                    local failure
                    local failureType

                    for routeIndex, entry in ipairs(
                        state.Plan
                    ) do
                        if state.Stop then
                            break
                        end

                        local recipientFinished =
                            true

                        local historyRecord = {
                            Direction = "Sent",
                            Mode = "By Value",
                            Status = "Failed",

                            OtherUserId =
                                entry.Recipient.UserId,

                            OtherName =
                                entry.Recipient.Name,

                            AttemptedMails =
                                entry.Mails,

                            AcceptedMails = 0,

                            PlannedItems =
                                #entry.Fruits,

                            SentItems = 0,

                            TargetValue =
                                entry.Target
                                or entry.Value,

                            AcceptedValue = 0,

                            Items = {},
                        }

                        local historyItemMap = {}

                        for firstIndex = 1,
                            #entry.Fruits,
                            BATCH_LIMIT
                        do
                            if state.Stop then
                                recipientFinished =
                                    false

                                break
                            end

                            local batch = {}
                            local batchValue = 0

                            for fruitIndex = firstIndex,
                                math.min(
                                    firstIndex
                                        + BATCH_LIMIT
                                        - 1,
                                    #entry.Fruits
                                )
                            do
                                local fruit =
                                    entry.Fruits[
                                        fruitIndex
                                    ]

                                table.insert(
                                    batch,
                                    fruit
                                )

                                batchValue +=
                                    tonumber(
                                        fruit.Value
                                    )
                                    or 0
                            end

                            sendButton.Text =
                                string.format(
                                    "@%s · mail %d/%d",
                                    entry.Recipient.Name,
                                    completedMails + 1,
                                    totalMails
                                )

                            setStatus(
                                string.format(
                                    "%d/%d",
                                    routeIndex,
                                    #state.Plan
                                ),
                                color.Yellow
                            )

                            local confirmed,
                                response,
                                responseType,
                                acceptedByServer =
                                state.Safety.SendValueBatch(
                                    packet,
                                    entry.Recipient,
                                    batch
                                )

                            if acceptedByServer then
                                completedMails +=
                                    1

                                fruitsSent +=
                                    #batch

                                valueSent +=
                                    batchValue

                                session.AcceptedMails =
                                    (
                                        tonumber(
                                            session.AcceptedMails
                                        )
                                        or 0
                                    )
                                    + 1

                                session.AcceptedItems =
                                    (
                                        tonumber(
                                            session.AcceptedItems
                                        )
                                        or 0
                                    )
                                    + #batch

                                session.AcceptedValue =
                                    (
                                        tonumber(
                                            session.AcceptedValue
                                        )
                                        or 0
                                    )
                                    + batchValue

                                local userId =
                                    entry.Recipient.UserId

                                local oldRemaining =
                                    tonumber(
                                        session.RemainingTargets[
                                            userId
                                        ]
                                    )
                                    or tonumber(
                                        entry.Target
                                    )
                                    or 0

                                session.RemainingTargets[
                                    userId
                                ] =
                                    math.max(
                                        0,
                                        oldRemaining
                                        - batchValue
                                    )

                                historyRecord.AcceptedMails +=
                                    1

                                historyRecord.SentItems +=
                                    #batch

                                historyRecord.AcceptedValue +=
                                    batchValue

                                state.Safety.AddFruitHistoryBatch(
                                    historyRecord,
                                    historyItemMap,
                                    batch
                                )

                                progressFill.Size =
                                    UDim2.fromScale(
                                        completedMails
                                            / math.max(
                                                totalMails,
                                                1
                                            ),
                                        1
                                    )

                                messageText.Text =
                                    string.format(
                                        "Accepted %d fruits worth %s.",
                                        fruitsSent,
                                        formatValue(
                                            valueSent
                                        )
                                    )
                            end

                            if not confirmed then
                                recipientFinished =
                                    false

                                failure =
                                    tostring(
                                        response
                                        or "Delivery paused"
                                    )

                                failureType =
                                    tostring(
                                        responseType
                                        or "PAUSED"
                                    )

                                if failureType
                                    == "UNCERTAIN"
                                then
                                    session.UncertainBatch = {
                                        Recipient =
                                            entry.Recipient,

                                        Fruits =
                                            batch,

                                        Value =
                                            batchValue,

                                        Accepted =
                                            acceptedByServer == true,
                                    }
                                end

                                break
                            end
                        end

                        if failureType == "UNCERTAIN" then
                            historyRecord.Status =
                                "Uncertain"
                        elseif recipientFinished then
                            historyRecord.Status =
                                "Sent"
                        elseif historyRecord.AcceptedMails > 0
                            or state.Stop
                        then
                            historyRecord.Status =
                                "Partial"
                        else
                            historyRecord.Status =
                                "Failed"
                        end

                        historyRecord.Error =
                            failure
                            or (
                                state.Stop
                                and "Stopped by user"
                                or ""
                            )

                        if historyRecord.AttemptedMails > 0 then
                            GAG2PremiumHistoryAdd(
                                historyRecord
                            )
                        end

                        if recipientFinished then
                            completedRecipients +=
                                1
                        else
                            break
                        end
                    end

                    local stopped =
                        state.Stop
                        and not failure

                    local complete =
                        completedMails == totalMails
                        and not failure
                        and not stopped

                    if complete then
                        session.Status =
                            "Complete"

                        state.ValueSession =
                            nil
                    elseif failureType == "UNCERTAIN" then
                        session.Status =
                            "Uncertain"
                    else
                        session.Status =
                            "Paused"
                    end

                    state.Running =
                        false

                    state.Stop =
                        false

                    renderRecipients()

                    setStatus(
                        complete
                                and "Complete"
                            or failureType == "UNCERTAIN"
                                    and "Confirmation uncertain"
                                or "Paused",
                        complete
                                and color.Green
                            or failureType == "UNCERTAIN"
                                    and color.Red
                                or color.Yellow
                    )

                    sendButton.Text =
                        complete
                                and "Review and send"
                            or failureType == "UNCERTAIN"
                                    and "Review uncertain mail"
                                or "Resume remaining delivery"

                    showModal(
                        complete
                                and "Delivery complete"
                            or failureType == "UNCERTAIN"
                                    and "Confirmation uncertain"
                                or failureType == "DAILY"
                                        and "Daily limit reached"
                                    or "Delivery paused",
                        (
                            failure
                            and failure
                                .. "\n\n"
                            or ""
                        )
                        .. string.format(
                            "People completed: %d\nFruits accepted: %d\nValue accepted: %s\nSends accepted: %d",
                            completedRecipients,
                            fruitsSent,
                            formatValue(
                                valueSent
                            ),
                            completedMails
                        ),
                        nil,
                        nil,
                        not complete
                    )

                    task.spawn(
                        rebuildPlan
                    )
                end
            )
        end

    state.Safety.RequestValueDelivery =
        function()
            if state.Running then
                state.Stop =
                    true

                sendButton.Text =
                    "Stopping after current mail..."

                return
            end

            local session =
                state.ValueSession

            if type(session) == "table"
                and session.Status == "Uncertain"
            then
                showModal(
                    "Confirmation uncertain",
                    "The server accepted the previous mail, but SOPHIA could not confirm that its items disappeared.\n\nThat batch was removed from the remaining target and will never be resent automatically.",
                    "Continue safely",
                    function()
                        session.Status =
                            "Paused"

                        session.UncertainBatch =
                            nil

                        sendButton.Text =
                            "Resume remaining delivery"

                        task.spawn(
                            rebuildPlan
                        )
                    end,
                    true
                )

                return
            end

            local resuming =
                type(session) == "table"
                and session.Status == "Paused"

            if resuming then
                rebuildPlan()
            end

            if state.Busy
                or #state.Plan == 0
            then
                return
            end

            local mails = 0
            local fruits = 0
            local value = 0
            local incomplete = false
            local overpayBlocked = false

            for _, entry in ipairs(
                state.Plan
            ) do
                mails +=
                    entry.Mails

                fruits +=
                    #entry.Fruits

                value +=
                    entry.Value

                incomplete =
                    incomplete
                    or not entry.Complete

                overpayBlocked =
                    overpayBlocked
                    or entry.GuardBlocked == true
            end

            if resuming
                and mails <= 0
            then
                state.ValueSession =
                    nil

                messageText.Text =
                    "The remaining delivery is complete."

                messageText.TextColor3 =
                    color.Green

                sendButton.Text =
                    "Review and send"

                task.spawn(
                    rebuildPlan
                )

                return
            end

            if overpayBlocked then
                messageText.Text =
                    "Cannot reach one or more remaining targets within the maximum extra value."

                messageText.TextColor3 =
                    color.Red

                return
            end

            if incomplete
                or mails <= 0
            then
                messageText.Text =
                    "The remaining delivery cannot currently be completed safely."

                messageText.TextColor3 =
                    color.Red

                return
            end

            if mails
                > DAILY_LIMIT - tracker.Used
            then
                messageText.Text =
                    "This needs more sends than you have left today."

                messageText.TextColor3 =
                    color.Red

                return
            end

            local seconds =
                mails <= 1
                and 0
                or (
                    mails - 1
                ) * COOLDOWN

            local maximumExtraText =
                state.Strategy == "Send at least"
                        and extraLimitCaption()
                    or "Not used"

            showModal(
                resuming
                        and "Resume remaining delivery"
                    or "Review before sending",
                string.format(
                    "Strategy: %s\nMaximum extra: %s\nPeople: %d\nFruits remaining: %d\nRemaining value: %s\nSends remaining: %d\nTime: about %ds",
                    state.Strategy,
                    maximumExtraText,
                    #state.Plan,
                    fruits,
                    formatValue(
                        value
                    ),
                    mails,
                    math.ceil(
                        seconds
                    )
                ),
                resuming
                        and "Resume"
                    or "Send now",
                function()
                    if not resuming then
                        local remainingTargets = {}

                        for _, recipient in ipairs(
                            state.Recipients
                        ) do
                            remainingTargets[
                                recipient.UserId
                            ] =
                                tonumber(
                                    recipient.Target
                                )
                                or 0
                        end

                        state.ValueSession = {
                            Status = "Ready",

                            RemainingTargets =
                                remainingTargets,

                            AcceptedMails = 0,
                            AcceptedItems = 0,
                            AcceptedValue = 0,

                            UncertainBatch =
                                nil,
                        }
                    end

                    task.spawn(
                        state.Safety.RunValueDelivery,
                        mails
                    )
                end,
                true
            )
        end

    addButton.MouseButton1Click:Connect(function()
        protectedCall(
            "Add recipient",
            function()
                if state.RecipientChangesLocked() then
                    return
                end

                local raw =
                    recipientBox.Text
                        :gsub("^%s+", "")
                        :gsub("%s+$", "")

                local target =
                    parseValue(
                        valueBox.Text
                    )

                if raw == "" then
                    recipientBox.PlaceholderText =
                        "Enter a recipient"

                    return
                end

                if not target then
                    valueBox.Text =
                        ""

                    valueBox.PlaceholderText =
                        "Invalid value"

                    return
                end

                addButton.Text =
                    "Checking..."

                local userId
                local username

                local numeric =
                    tonumber(raw)

                if numeric then
                    local ok, result =
                        pcall(
                            Players.GetNameFromUserIdAsync,
                            Players,
                            math.floor(numeric)
                        )

                    if ok then
                        userId =
                            math.floor(numeric)

                        username =
                            result
                    end
                else
                    local ok, result =
                        pcall(
                            Players.GetUserIdFromNameAsync,
                            Players,
                            raw
                        )

                    if ok then
                        userId =
                            result

                        local nameOk, name =
                            pcall(
                                Players.GetNameFromUserIdAsync,
                                Players,
                                userId
                            )

                        username =
                            nameOk
                                and name
                                or raw
                    end
                end

                if not userId
                    or not username
                    or userId == player.UserId
                then
                    recipientBox.Text =
                        ""

                    recipientBox.PlaceholderText =
                        "Recipient not found"

                    addButton.Text =
                        "+ Add"

                    return
                end

                for index, recipient in ipairs(
                    state.Recipients
                ) do
                    if index ~= state.Editing
                        and recipient.UserId == userId
                    then
                        recipientBox.Text =
                            ""

                        recipientBox.PlaceholderText =
                            "Already added"

                        addButton.Text =
                            "+ Add"

                        return
                    end
                end

                local record = {
                    UserId =
                        userId,

                    Name =
                        username,

                    Target =
                        target,
                }

                if state.Editing
                    and state.Recipients[state.Editing]
                then
                    state.Recipients[state.Editing] =
                        record
                else
                    table.insert(
                        state.Recipients,
                        record
                    )
                end

                GAG2PremiumTouchRecipient(
                    userId,
                    username
                )

                state.Editing =
                    nil

                recipientBox.Text =
                    ""

                valueBox.Text =
                    ""

                addButton.Text =
                    "+ Add"

                renderRecipients()
                rebuildPlan()
            end
        )
    end)

    calculateButton.MouseButton1Click:Connect(function()
        protectedCall(
            "Refresh preview",
            rebuildPlan
        )
    end)

    strategyButton.MouseButton1Click:Connect(function()
        if state.Running
            or state.Busy
        then
            return
        end

        showStrategySettings()
    end)

    fruitsButton.MouseButton1Click:Connect(function()
        protectedCall(
            "Fruit filters",
            state.Filters.Show
        )
    end)


    favoriteButton.MouseButton1Click:Connect(function()
        if state.Running
            or state.Busy
        then
            return
        end

        state.Protect =
            not state.Protect

        favoriteButton.Text =
            "Skip favorites: "
            .. (
                state.Protect
                    and "ON"
                    or "OFF"
            )

        task.spawn(function()
            protectedCall(
                "Favorite filter",
                rebuildPlan
            )
        end)
    end)

    clearButton.MouseButton1Click:Connect(function()
        if state.RecipientChangesLocked()
            or #state.Recipients == 0
        then
            return
        end

        showModal(
            "Clear everyone?",
            "This removes every person from the list. Your fruits will not be changed.",
            "Clear all",
            function()
                state.Recipients = {}

                state.Editing =
                    nil

                recipientBox.Text =
                    ""

                valueBox.Text =
                    ""

                addButton.Text =
                    "+ Add"

                renderRecipients()
                task.spawn(rebuildPlan)
            end,
            false
        )
    end)

    sendButton.MouseButton1Click:Connect(function()
        protectedCall(
            "Send button",
            state.Safety.RequestValueDelivery
        )
    end)

    local fullSize =
        window.Size

    local function applyMinimized()
        local expanded =
            not state.Minimized

        if type(state.PageFrames) == "table" then
            for pageName, pageFrame in pairs(
                state.PageFrames
            ) do
                if typeof(pageFrame) == "Instance" then
                    pageFrame.Visible =
                        expanded
                        and pageName
                            == (
                                state.ActiveTab
                                or "Send"
                            )
                end
            end
        else
            content.Visible =
                expanded
        end

        if typeof(state.TabBar) == "Instance" then
            state.TabBar.Visible =
                expanded
        end

        if typeof(state.SendModeBar) == "Instance" then
            state.SendModeBar.Visible =
                expanded
                and (
                    state.ActiveTab
                    or "Send"
                ) == "Send"
        end

        if typeof(footerBar) == "Instance" then
            footerBar.Visible =
                expanded
        end

        overlay.Visible =
            false

        if state.Minimized then
            header.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    46
                )

            logo.Size =
                UDim2.fromOffset(
                    28,
                    28
                )

            logo.Position =
                UDim2.fromOffset(
                    9,
                    9
                )

            title.Position =
                UDim2.fromOffset(
                    47,
                    4
                )

            title.Size =
                UDim2.fromOffset(
                    82,
                    38
                )

            title.TextSize =
                13

            subtitle.Visible =
                false

            quotaFrame.Size =
                UDim2.fromOffset(
                    52,
                    28
                )

            quotaFrame.Position =
                UDim2.fromOffset(
                    132,
                    9
                )

            quotaText.TextSize =
                8

            statusFrame.Size =
                UDim2.fromOffset(
                    68,
                    28
                )

            statusFrame.Position =
                UDim2.fromOffset(
                    189,
                    9
                )

            statusDot.Size =
                UDim2.fromOffset(
                    6,
                    6
                )

            statusDot.Position =
                UDim2.fromOffset(
                    8,
                    11
                )

            statusText.Size =
                UDim2.fromOffset(
                    48,
                    24
                )

            statusText.Position =
                UDim2.fromOffset(
                    18,
                    2
                )

            statusText.TextSize =
                8

            minimizeButton.Size =
                UDim2.fromOffset(
                    28,
                    28
                )

            minimizeButton.Position =
                UDim2.fromOffset(
                    262,
                    9
                )

            minimizeButton.Text =
                "+"

            closeButton.Size =
                UDim2.fromOffset(
                    28,
                    28
                )

            closeButton.Position =
                UDim2.fromOffset(
                    295,
                    9
                )

            TweenService:Create(
                window,
                TweenInfo.new(0.12),
                {
                    Size =
                        UDim2.fromOffset(
                            332,
                            46
                        ),
                }
            ):Play()
        else
            header.Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    64
                )

            logo.Size =
                UDim2.fromOffset(
                    40,
                    40
                )

            logo.Position =
                UDim2.fromOffset(
                    16,
                    12
                )

            title.Position =
                UDim2.fromOffset(
                    69,
                    9
                )

            title.Size =
                UDim2.fromOffset(
                    170,
                    23
                )

            title.TextSize =
                19

            subtitle.Visible =
                true

            quotaFrame.Size =
                UDim2.fromOffset(
                    150,
                    38
                )

            quotaFrame.Position =
                UDim2.new(
                    1,
                    -360,
                    0,
                    13
                )

            quotaText.TextSize =
                11

            statusFrame.Size =
                UDim2.fromOffset(
                    108,
                    38
                )

            statusFrame.Position =
                UDim2.new(
                    1,
                    -200,
                    0,
                    13
                )

            statusDot.Size =
                UDim2.fromOffset(
                    7,
                    7
                )

            statusDot.Position =
                UDim2.fromOffset(
                    12,
                    16
                )

            statusText.Size =
                UDim2.fromOffset(
                    78,
                    28
                )

            statusText.Position =
                UDim2.fromOffset(
                    26,
                    5
                )

            statusText.TextSize =
                11

            minimizeButton.Size =
                UDim2.fromOffset(
                    40,
                    40
                )

            minimizeButton.Position =
                UDim2.new(
                    1,
                    -88,
                    0,
                    12
                )

            minimizeButton.Text =
                "-"

            closeButton.Size =
                UDim2.fromOffset(
                    40,
                    40
                )

            closeButton.Position =
                UDim2.new(
                    1,
                    -44,
                    0,
                    12
                )

            TweenService:Create(
                window,
                TweenInfo.new(0.12),
                {
                    Size =
                        fullSize,
                }
            ):Play()
        end

        updateQuota()
    end

    SOPHIA_MAIL_RUNTIME.SetMinimized =
        function(value)
            state.Minimized =
                value == true

            applyMinimized()

            return true
        end

    minimizeButton.MouseButton1Click:Connect(function()
        state.Minimized =
            not state.Minimized

        applyMinimized()
    end)

    closeButton.MouseButton1Click:Connect(function()
        if state.Running then
            state.Stop =
                true

            return
        end

        GAG2PremiumSetEnabled(false)
    end)

    do
        local dragging =
            false

        local startInput
        local startPosition

        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging =
                    true

                startInput =
                    input.Position

                startPosition =
                    window.Position
            end
        end)

        header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            then
                dragging =
                    false

                GAG2PremiumStorePosition(
                    window.Position
                )
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging
                and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                )
            then
                local delta =
                    input.Position
                    - startInput

                window.Position =
                    UDim2.new(
                        startPosition.X.Scale,
                        startPosition.X.Offset
                            + delta.X,
                        startPosition.Y.Scale,
                        startPosition.Y.Offset
                            + delta.Y
                    )
            end
        end)
    end

    ------------------------------------------------------------------------
    -- PICK ITEMS MODE
    ------------------------------------------------------------------------

    state.MailMode =
        "Value"

    state.ExactRecipients =
        {}

    state.ExactSelectedUserId =
        nil

    state.ExactCategories = {
        Fruits =
            true,
    }

    state.ExactSearch =
        ""

    state.ExactProtect =
        true

    state.ExactView =
        "Owned"

    state.ExactRecords =
        {}

    state.ExactRecordMap =
        {}

    state.ExactQueues =
        {}

    state.ActiveTab =
        "Send"

    local tabBar =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Header,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        38
                    ),

                Position =
                    UDim2.fromOffset(
                        0,
                        64
                    ),
            },
            window
        )

    create(
        "Frame",
        {
            BackgroundColor3 =
                color.Border,

            BorderSizePixel =
                0,

            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    1
                ),

            Position =
                UDim2.new(
                    0,
                    0,
                    1,
                    -1
                ),
        },
        tabBar
    )

    local tabButtons =
        {}

    local tabLines =
        {}

    local function addMainTab(
        tabName,
        label,
        x
    )
        local tabButton =
            create(
                "TextButton",
                {
                    AutoButtonColor =
                        false,

                    BackgroundTransparency =
                        1,

                    Text =
                        label,

                    TextColor3 =
                        color.Muted,

                    TextSize =
                        13,

                    TextStrokeTransparency =
                        1,

                    Font =
                        Enum.Font.GothamSemibold,

                    Size =
                        UDim2.fromOffset(
                            90,
                            37
                        ),

                    Position =
                        UDim2.fromOffset(
                            x,
                            0
                        ),
                },
                tabBar
            )

        local selectedLine =
            create(
                "Frame",
                {
                    BackgroundColor3 =
                        color.Accent,

                    BorderSizePixel =
                        0,

                    Size =
                        UDim2.fromOffset(
                            58,
                            3
                        ),

                    Position =
                        UDim2.new(
                            0.5,
                            -29,
                            1,
                            -3
                        ),

                    Visible =
                        false,
                },
                tabButton
            )

        round(
            selectedLine,
            3
        )

        tabButtons[tabName] =
            tabButton

        tabLines[tabName] =
            selectedLine
    end

    addMainTab(
        "Send",
        "Send",
        14
    )

    addMainTab(
        "Fleet",
        "Fleet",
        104
    )

    addMainTab(
        "Inbox",
        "Inbox",
        194
    )

    addMainTab(
        "History",
        "History",
        284
    )

    addMainTab(
        "Settings",
        "Settings",
        374
    )

    local sendModeBar =
        create(
            "Frame",
            {
                BackgroundTransparency =
                    1,

                Size =
                    UDim2.fromOffset(
                        896,
                        30
                    ),

                Position =
                    UDim2.fromOffset(
                        12,
                        106
                    ),
            },
            window
        )

    text(
        sendModeBar,
        "SEND MODE",
        UDim2.fromOffset(
            82,
            28
        ),
        UDim2.fromOffset(
            2,
            1
        ),
        9,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local modeSwitcher =
        create(
            "Frame",
            {
                BackgroundTransparency =
                    1,

                Size =
                    UDim2.fromOffset(
                        216,
                        28
                    ),

                Position =
                    UDim2.fromOffset(
                        88,
                        1
                    ),
            },
            sendModeBar
        )

    local valueModeButton =
        button(
            modeSwitcher,
            "By Value",
            UDim2.fromOffset(
                104,
                28
            ),
            UDim2.fromOffset(
                0,
                0
            ),
            true
        )

    local itemModeButton =
        button(
            modeSwitcher,
            "Pick Items",
            UDim2.fromOffset(
                104,
                28
            ),
            UDim2.fromOffset(
                112,
                0
            ),
            false
        )

    valueModeButton.TextSize =
        12

    itemModeButton.TextSize =
        12

    state.Fleet.Build =
        function()

    ------------------------------------------------------------------------
    -- FLEET MANAGER
    ------------------------------------------------------------------------

    local fleetPage =
        create(
            "Frame",
            {
                BackgroundTransparency =
                    1,

                Size =
                    UDim2.fromOffset(
                        896,
                        580
                    ),

                Position =
                    UDim2.fromOffset(
                        12,
                        110
                    ),

                Visible =
                    false,
            },
            window
        )

    local fleetGroupCard =
        card(
            fleetPage,
            UDim2.fromOffset(
                244,
                580
            ),
            UDim2.fromOffset(
                0,
                0
            )
        )

    local fleetAccountCard =
        card(
            fleetPage,
            UDim2.fromOffset(
                640,
                580
            ),
            UDim2.fromOffset(
                256,
                0
            )
        )

    text(
        fleetGroupCard,
        "ALT FLEET",
        UDim2.fromOffset(
            130,
            20
        ),
        UDim2.fromOffset(
            18,
            14
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamBold
    )

    local fleetStats =
        text(
            fleetGroupCard,
            "0 / 0 ENABLED",
            UDim2.fromOffset(
                190,
                20
            ),
            UDim2.fromOffset(
                18,
                42
            ),
            11,
            color.Muted
        )

    local fleetGroupBox =
        box(
            fleetGroupCard,
            "New group",
            UDim2.fromOffset(
                146,
                38
            ),
            UDim2.fromOffset(
                18,
                78
            )
        )

    local fleetGroupAdd =
        button(
            fleetGroupCard,
            "+",
            UDim2.fromOffset(
                56,
                38
            ),
            UDim2.fromOffset(
                170,
                78
            ),
            true
        )

    fleetGroupAdd.TextSize =
        17

    local fleetGroupList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency =
                    1,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.fromOffset(
                        208,
                        196
                    ),

                Position =
                    UDim2.fromOffset(
                        18,
                        126
                    ),

                CanvasSize =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                ScrollBarThickness =
                    3,

                ScrollBarImageColor3 =
                    color.Border,
            },
            fleetGroupCard
        )

    local fleetGroupLayout =
        create(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        5
                    ),

                SortOrder =
                    Enum.SortOrder.LayoutOrder,
            },
            fleetGroupList
        )

    local fleetDeleteGroup =
        button(
            fleetGroupCard,
            "Delete selected group",
            UDim2.fromOffset(
                208,
                38
            ),
            UDim2.fromOffset(
                18,
                332
            ),
            false
        )

    fleetDeleteGroup.TextSize =
        11

    text(
        fleetGroupCard,
        "BUILD ROUTE",
        UDim2.fromOffset(
            160,
            20
        ),
        UDim2.fromOffset(
            18,
            390
        ),
        11,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local fleetTargetBox =
        box(
            fleetGroupCard,
            "Target each, e.g. $2B",
            UDim2.fromOffset(
                208,
                40
            ),
            UDim2.fromOffset(
                18,
                418
            )
        )

    local fleetLoadValue =
        button(
            fleetGroupCard,
            "Load · Target Each",
            UDim2.fromOffset(
                208,
                38
            ),
            UDim2.fromOffset(
                18,
                468
            ),
            true
        )

    local fleetLoadItems =
        button(
            fleetGroupCard,
            "Load · Pick Items",
            UDim2.fromOffset(
                208,
                38
            ),
            UDim2.fromOffset(
                18,
                516
            ),
            false
        )

    fleetLoadValue.TextSize =
        11

    fleetLoadItems.TextSize =
        11

    text(
        fleetAccountCard,
        "ACCOUNTS",
        UDim2.fromOffset(
            150,
            20
        ),
        UDim2.fromOffset(
            16,
            14
        ),
        12,
        color.Secondary,
        nil,
        Enum.Font.GothamBold
    )

    local fleetCount =
        text(
            fleetAccountCard,
            "0 shown",
            UDim2.fromOffset(
                220,
                20
            ),
            UDim2.new(
                1,
                -236,
                0,
                14
            ),
            11,
            color.Muted,
            Enum.TextXAlignment.Right
        )

    local fleetSearchBox =
        box(
            fleetAccountCard,
            "Search accounts...",
            UDim2.fromOffset(
                442,
                38
            ),
            UDim2.fromOffset(
                16,
                42
            )
        )

    local fleetImportButton =
        button(
            fleetAccountCard,
            "Bulk Import",
            UDim2.fromOffset(
                150,
                38
            ),
            UDim2.fromOffset(
                474,
                42
            ),
            false
        )

    local fleetUsernameBox =
        box(
            fleetAccountCard,
            "Username or User ID",
            UDim2.fromOffset(
                248,
                38
            ),
            UDim2.fromOffset(
                16,
                88
            )
        )

    local fleetLabelBox =
        box(
            fleetAccountCard,
            "Label",
            UDim2.fromOffset(
                190,
                38
            ),
            UDim2.fromOffset(
                272,
                88
            )
        )

    local fleetSaveAccount =
        button(
            fleetAccountCard,
            "+ Add",
            UDim2.fromOffset(
                154,
                38
            ),
            UDim2.fromOffset(
                470,
                88
            ),
            true
        )

    local fleetAccountList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency =
                    1,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.new(
                        1,
                        -32,
                        0,
                        400
                    ),

                Position =
                    UDim2.fromOffset(
                        16,
                        136
                    ),

                CanvasSize =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                ScrollBarThickness =
                    3,

                ScrollBarImageColor3 =
                    color.Border,
            },
            fleetAccountCard
        )

    local fleetAccountLayout =
        create(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        6
                    ),

                SortOrder =
                    Enum.SortOrder.LayoutOrder,
            },
            fleetAccountList
        )

    local fleetStatus =
        text(
            fleetAccountCard,
            "Create a group or import your alt accounts.",
            UDim2.new(
                1,
                -32,
                0,
                28
            ),
            UDim2.fromOffset(
                16,
                542
            ),
            11,
            color.Muted
        )

    local refreshFleetPage

    local function fleetGroupExists(
        groupName
    )
        for _, existing in ipairs(
            state.Fleet.Groups
        ) do
            if existing:lower()
                == tostring(
                    groupName
                ):lower()
            then
                return true,
                    existing
            end
        end

        return false,
            nil
    end

    local function fleetFindAccount(
        userId
    )
        for index, record in ipairs(
            state.Fleet.Accounts
        ) do
            if record.UserId == userId then
                return record,
                    index
            end
        end

        return nil,
            nil
    end

    local function fleetSelectedGroup()
        if state.Fleet.ActiveGroup == "All" then
            return "Ungrouped"
        end

        return GAG2PremiumNormalizeFleetGroupName(
            state.Fleet.ActiveGroup
        )
    end

    state.Fleet.Commit =
        function()
            state.Fleet.Accounts =
                GAG2PremiumNormalizeFleetAccounts(
                    state.Fleet.Accounts
                )

            state.Fleet.Groups =
                GAG2PremiumNormalizeFleetGroups(
                    state.Fleet.Groups
                )

            for _, account in ipairs(
                state.Fleet.Accounts
            ) do
                local exists =
                    fleetGroupExists(
                        account.Group
                    )

                if not exists then
                    if #state.Fleet.Groups < 20 then
                        table.insert(
                            state.Fleet.Groups,
                            account.Group
                        )
                    else
                        account.Group =
                            "Ungrouped"
                    end
                end
            end

            state.Fleet.Groups =
                GAG2PremiumNormalizeFleetGroups(
                    state.Fleet.Groups
                )

            if state.Fleet.ActiveGroup ~= "All" then
                local exists,
                    correctedName =
                    fleetGroupExists(
                        state.Fleet.ActiveGroup
                    )

                state.Fleet.ActiveGroup =
                    exists
                    and correctedName
                    or "All"
            end

            SOPHIA_MAIL_STATE.FleetAccounts =
                GAG2PremiumNormalizeFleetAccounts(
                    state.Fleet.Accounts
                )

            SOPHIA_MAIL_STATE.FleetGroups =
                GAG2PremiumNormalizeFleetGroups(
                    state.Fleet.Groups
                )

            GAG2PremiumSaveSettings()

            if type(refreshFleetPage)
                == "function"
            then
                refreshFleetPage()
            end
        end

    state.Fleet.EnabledAccounts =
        function()
            local output = {}

            for _, record in ipairs(
                state.Fleet.Accounts
            ) do
                local correctGroup =
                    state.Fleet.ActiveGroup == "All"
                    or record.Group
                        == state.Fleet.ActiveGroup

                if correctGroup
                    and record.Enabled == true
                then
                    table.insert(
                        output,
                        record
                    )
                end
            end

            return output
        end

    local function fleetLastResult(
        userId
    )
        for _, historyRecord in ipairs(
            SOPHIA_MAIL_HISTORY.Records
            or {}
        ) do
            if tostring(
                historyRecord.Direction
            ) == "Sent"
                and tonumber(
                    historyRecord.OtherUserId
                ) == userId
            then
                local status =
                    tostring(
                        historyRecord.Status
                        or "Unknown"
                    )

                local timestamp =
                    tonumber(
                        historyRecord.Timestamp
                    )
                    or 0

                local formatted =
                    timestamp > 0
                    and os.date(
                        "%d %b · %H:%M",
                        timestamp
                    )
                    or "Unknown time"

                return status
                    .. " · "
                    .. formatted,
                    status
            end
        end

        return "Never sent to",
            "None"
    end

    local function fleetMoveAccount(
        userId,
        direction,
        visibleAccounts
    )
        if state.RecipientChangesLocked() then
            return
        end

        local visibleIndex

        for index, record in ipairs(
            visibleAccounts
        ) do
            if record.UserId == userId then
                visibleIndex =
                    index

                break
            end
        end

        local other =
            visibleIndex
            and visibleAccounts[
                visibleIndex + direction
            ]
            or nil

        local current =
            fleetFindAccount(
                userId
            )

        if not current
            or not other
        then
            return
        end

        current.Priority,
            other.Priority =
            other.Priority,
            current.Priority

        state.Fleet.Commit()
    end

    refreshFleetPage =
        function()
            clearRows(
                fleetGroupList,
                fleetGroupLayout
            )

            clearRows(
                fleetAccountList,
                fleetAccountLayout
            )

            local total =
                #state.Fleet.Accounts

            local enabled = 0

            for _, record in ipairs(
                state.Fleet.Accounts
            ) do
                if record.Enabled then
                    enabled +=
                        1
                end
            end

            fleetStats.Text =
                tostring(enabled)
                .. " / "
                .. tostring(total)
                .. " ENABLED"

            local groupsToRender = {
                "All",
            }

            for _, groupName in ipairs(
                state.Fleet.Groups
            ) do
                table.insert(
                    groupsToRender,
                    groupName
                )
            end

            for order, groupName in ipairs(
                groupsToRender
            ) do
                local groupTotal = 0
                local groupEnabled = 0

                for _, account in ipairs(
                    state.Fleet.Accounts
                ) do
                    if groupName == "All"
                        or account.Group
                            == groupName
                    then
                        groupTotal +=
                            1

                        if account.Enabled then
                            groupEnabled +=
                                1
                        end
                    end
                end

                local selected =
                    state.Fleet.ActiveGroup
                    == groupName

                local groupButton =
                    button(
                        fleetGroupList,
                        (
                            groupName == "All"
                            and "All Accounts"
                            or groupName
                        )
                            .. "  ·  "
                            .. tostring(
                                groupEnabled
                            )
                            .. "/"
                            .. tostring(
                                groupTotal
                            ),
                        UDim2.new(
                            1,
                            -4,
                            0,
                            40
                        ),
                        UDim2.fromOffset(
                            0,
                            0
                        ),
                        selected
                    )

                groupButton.LayoutOrder =
                    order

                groupButton.TextSize =
                    11

                groupButton.TextXAlignment =
                    Enum.TextXAlignment.Left

                create(
                    "UIPadding",
                    {
                        PaddingLeft =
                            UDim.new(
                                0,
                                12
                            ),

                        PaddingRight =
                            UDim.new(
                                0,
                                8
                            ),
                    },
                    groupButton
                )

                groupButton.MouseButton1Click:Connect(function()
                    state.Fleet.ActiveGroup =
                        groupName

                    state.Fleet.EditUserId =
                        nil

                    state.Fleet.EditOriginalName =
                        ""

                    fleetUsernameBox.Text =
                        ""

                    fleetLabelBox.Text =
                        ""

                    fleetSaveAccount.Text =
                        "+ Add"

                    refreshFleetPage()
                end)
            end

            fleetDeleteGroup.Visible =
                state.Fleet.ActiveGroup ~= "All"
                and state.Fleet.ActiveGroup
                    ~= "Ungrouped"

            local routeName =
                state.Fleet.ActiveGroup == "All"
                and "All"
                or state.Fleet.ActiveGroup

            fleetLoadValue.Text =
                "Load "
                .. routeName
                .. " · Target Each"

            fleetLoadItems.Text =
                "Load "
                .. routeName
                .. " · Pick Items"

            local query =
                GAG2PremiumFilterKey(
                    state.Fleet.Search
                )

            local visibleAccounts = {}

            for _, record in ipairs(
                state.Fleet.Accounts
            ) do
                local correctGroup =
                    state.Fleet.ActiveGroup == "All"
                    or record.Group
                        == state.Fleet.ActiveGroup

                local searchable =
                    GAG2PremiumFilterKey(
                        record.Label
                            .. " "
                            .. record.Name
                            .. " "
                            .. tostring(
                                record.UserId
                            )
                            .. " "
                            .. record.Group
                    )

                if correctGroup
                    and (
                        query == ""
                        or searchable:find(
                            query,
                            1,
                            true
                        )
                    )
                then
                    table.insert(
                        visibleAccounts,
                        record
                    )
                end
            end

            fleetCount.Text =
                tostring(
                    #visibleAccounts
                )
                .. " shown · "
                .. tostring(total)
                .. " total"

            if #visibleAccounts == 0 then
                local empty =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Field,

                            Size =
                                UDim2.new(
                                    1,
                                    -4,
                                    0,
                                    80
                                ),
                        },
                        fleetAccountList
                    )

                round(
                    empty,
                    12
                )

                text(
                    empty,
                    total == 0
                        and "No Fleet accounts yet"
                        or "No matching accounts",
                    UDim2.new(
                        1,
                        -24,
                        0,
                        26
                    ),
                    UDim2.fromOffset(
                        12,
                        12
                    ),
                    13,
                    color.Text,
                    nil,
                    Enum.Font.GothamSemibold
                )

                text(
                    empty,
                    total == 0
                        and "Add one above or use Bulk Import."
                        or "Try another group or search.",
                    UDim2.new(
                        1,
                        -24,
                        0,
                        22
                    ),
                    UDim2.fromOffset(
                        12,
                        42
                    ),
                    11,
                    color.Muted
                )
            end

            for index, record in ipairs(
                visibleAccounts
            ) do
                local lastResult,
                    lastStatus =
                    fleetLastResult(
                        record.UserId
                    )

                local warning =
                    lastStatus ~= "None"
                    and lastStatus ~= "Sent"

                local row =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                record.Enabled
                                and color.Field
                                or color.Card,

                            Size =
                                UDim2.new(
                                    1,
                                    -4,
                                    0,
                                    66
                                ),

                            LayoutOrder =
                                index,
                        },
                        fleetAccountList
                    )

                round(
                    row,
                    11
                )

                outline(
                    row,
                    warning
                        and color.Yellow
                        or color.Border
                )

                local toggle =
                    button(
                        row,
                        record.Enabled
                            and "✓"
                            or "○",
                        UDim2.fromOffset(
                            34,
                            34
                        ),
                        UDim2.fromOffset(
                            8,
                            16
                        ),
                        record.Enabled
                    )

                toggle.TextSize =
                    15

                addAvatar(
                    row,
                    record.UserId,
                    UDim2.fromOffset(
                        38,
                        38
                    ),
                    UDim2.fromOffset(
                        50,
                        14
                    )
                )

                text(
                    row,
                    tostring(
                        record.Label
                        or record.Name
                    ),
                    UDim2.new(
                        1,
                        -274,
                        0,
                        20
                    ),
                    UDim2.fromOffset(
                        96,
                        7
                    ),
                    12,
                    record.Enabled
                        and color.Text
                        or color.Muted,
                    nil,
                    Enum.Font.GothamSemibold
                )

                text(
                    row,
                    "@"
                        .. record.Name
                        .. " · "
                        .. tostring(
                            record.UserId
                        ),
                    UDim2.new(
                        1,
                        -274,
                        0,
                        17
                    ),
                    UDim2.fromOffset(
                        96,
                        27
                    ),
                    10,
                    color.Muted
                )

                text(
                    row,
                    record.Group
                        .. " · "
                        .. lastResult,
                    UDim2.new(
                        1,
                        -274,
                        0,
                        16
                    ),
                    UDim2.fromOffset(
                        96,
                        44
                    ),
                    9,
                    warning
                        and color.Yellow
                        or color.Secondary
                )

                local upButton =
                    button(
                        row,
                        "^",
                        UDim2.fromOffset(
                            28,
                            32
                        ),
                        UDim2.new(
                            1,
                            -166,
                            0,
                            17
                        ),
                        false
                    )

                local downButton =
                    button(
                        row,
                        "v",
                        UDim2.fromOffset(
                            28,
                            32
                        ),
                        UDim2.new(
                            1,
                            -134,
                            0,
                            17
                        ),
                        false
                    )

                local editButton =
                    button(
                        row,
                        "Edit",
                        UDim2.fromOffset(
                            56,
                            32
                        ),
                        UDim2.new(
                            1,
                            -102,
                            0,
                            17
                        ),
                        false
                    )

                local deleteButton =
                    button(
                        row,
                        "X",
                        UDim2.fromOffset(
                            30,
                            32
                        ),
                        UDim2.new(
                            1,
                            -40,
                            0,
                            17
                        ),
                        false
                    )

                upButton.TextSize =
                    11

                downButton.TextSize =
                    11

                editButton.TextSize =
                    10

                deleteButton.TextSize =
                    11

                toggle.MouseButton1Click:Connect(function()
                    if state.RecipientChangesLocked() then
                        return
                    end

                    local account =
                        fleetFindAccount(
                            record.UserId
                        )

                    if account then
                        account.Enabled =
                            not account.Enabled

                        state.Fleet.Commit()
                    end
                end)

                upButton.MouseButton1Click:Connect(function()
                    fleetMoveAccount(
                        record.UserId,
                        -1,
                        visibleAccounts
                    )
                end)

                downButton.MouseButton1Click:Connect(function()
                    fleetMoveAccount(
                        record.UserId,
                        1,
                        visibleAccounts
                    )
                end)

                editButton.MouseButton1Click:Connect(function()
                    if state.RecipientChangesLocked() then
                        return
                    end

                    state.Fleet.EditUserId =
                        record.UserId

                    state.Fleet.EditOriginalName =
                        record.Name

                    state.Fleet.ActiveGroup =
                        record.Group

                    fleetUsernameBox.Text =
                        record.Name

                    fleetLabelBox.Text =
                        record.Label

                    fleetSaveAccount.Text =
                        "Update"

                    fleetStatus.Text =
                        "Editing @"
                        .. record.Name
                        .. " in "
                        .. record.Group
                        .. "."

                    fleetStatus.TextColor3 =
                        color.Muted

                    refreshFleetPage()
                end)

                deleteButton.MouseButton1Click:Connect(function()
                    if state.RecipientChangesLocked() then
                        return
                    end

                    showModal(
                        "Remove Fleet account?",
                        "@"
                            .. record.Name
                            .. " will be removed from Fleet. Existing delivery history will remain.",
                        "Remove account",
                        function()
                            local _,
                                accountIndex =
                                fleetFindAccount(
                                    record.UserId
                                )

                            if accountIndex then
                                table.remove(
                                    state.Fleet.Accounts,
                                    accountIndex
                                )
                            end

                            if state.Fleet.EditUserId
                                == record.UserId
                            then
                                state.Fleet.EditUserId =
                                    nil

                                state.Fleet.EditOriginalName =
                                    ""

                                fleetUsernameBox.Text =
                                    ""

                                fleetLabelBox.Text =
                                    ""

                                fleetSaveAccount.Text =
                                    "+ Add"
                            end

                            state.Fleet.Commit()
                        end,
                        false
                    )
                end)
            end
        end

    state.Fleet.Refresh =
        refreshFleetPage

    fleetSearchBox:GetPropertyChangedSignal(
        "Text"
    ):Connect(function()
        state.Fleet.Search =
            fleetSearchBox.Text

        refreshFleetPage()
    end)

    fleetGroupAdd.MouseButton1Click:Connect(function()
        if state.RecipientChangesLocked() then
            return
        end

        local groupName =
            GAG2PremiumRecipientText(
                fleetGroupBox.Text,
                24
            )

        if groupName == ""
            or groupName:lower() == "all"
        then
            fleetGroupBox.Text =
                ""

            fleetGroupBox.PlaceholderText =
                "Invalid group name"

            return
        end

        local exists,
            correctedName =
            fleetGroupExists(
                groupName
            )

        if exists then
            state.Fleet.ActiveGroup =
                correctedName

            fleetGroupBox.Text =
                ""

            refreshFleetPage()

            return
        end

        if #state.Fleet.Groups >= 20 then
            fleetStatus.Text =
                "The Fleet group limit is 20."

            fleetStatus.TextColor3 =
                color.Red

            return
        end

        table.insert(
            state.Fleet.Groups,
            groupName
        )

        state.Fleet.ActiveGroup =
            groupName

        fleetGroupBox.Text =
            ""

        state.Fleet.Commit()

        fleetStatus.Text =
            groupName
            .. " was created."

        fleetStatus.TextColor3 =
            color.Green
    end)

    fleetDeleteGroup.MouseButton1Click:Connect(function()
        if state.RecipientChangesLocked()
            or state.Fleet.ActiveGroup == "All"
            or state.Fleet.ActiveGroup
                == "Ungrouped"
        then
            return
        end

        local deletingGroup =
            state.Fleet.ActiveGroup

        showModal(
            "Delete "
                .. deletingGroup
                .. "?",
            "Accounts in this group will be moved to Ungrouped. No account or delivery history will be deleted.",
            "Delete group",
            function()
                for _, account in ipairs(
                    state.Fleet.Accounts
                ) do
                    if account.Group
                        == deletingGroup
                    then
                        account.Group =
                            "Ungrouped"
                    end
                end

                for index, groupName in ipairs(
                    state.Fleet.Groups
                ) do
                    if groupName == deletingGroup then
                        table.remove(
                            state.Fleet.Groups,
                            index
                        )

                        break
                    end
                end

                state.Fleet.ActiveGroup =
                    "Ungrouped"

                state.Fleet.Commit()
            end,
            false
        )
    end)

    fleetSaveAccount.MouseButton1Click:Connect(function()
        if state.RecipientChangesLocked() then
            return
        end

        local raw =
            GAG2PremiumRecipientText(
                fleetUsernameBox.Text,
                80
            )

        if raw == "" then
            fleetUsernameBox.PlaceholderText =
                "Enter a username"

            return
        end

        local resolveInput =
            raw

        if state.Fleet.EditUserId
            and GAG2PremiumFilterKey(
                raw
            ) == GAG2PremiumFilterKey(
                state.Fleet.EditOriginalName
            )
        then
            resolveInput =
                tostring(
                    state.Fleet.EditUserId
                )
        end

        fleetSaveAccount.Text =
            "Checking..."

        local userId,
            username,
            resolveError =
            GAG2PremiumResolveRecipient(
                resolveInput
            )

        if not userId then
            fleetStatus.Text =
                tostring(
                    resolveError
                    or "Account could not be verified."
                )

            fleetStatus.TextColor3 =
                color.Red

            fleetSaveAccount.Text =
                state.Fleet.EditUserId
                and "Update"
                or "+ Add"

            return
        end

        local existing,
            existingIndex =
            fleetFindAccount(
                userId
            )

        if existing
            and userId
                ~= state.Fleet.EditUserId
        then
            fleetStatus.Text =
                "@"
                .. username
                .. " is already in Fleet."

            fleetStatus.TextColor3 =
                color.Yellow

            fleetSaveAccount.Text =
                state.Fleet.EditUserId
                and "Update"
                or "+ Add"

            return
        end

        if not state.Fleet.EditUserId
            and #state.Fleet.Accounts >= 100
        then
            fleetStatus.Text =
                "The Fleet account limit is 100."

            fleetStatus.TextColor3 =
                color.Red

            fleetSaveAccount.Text =
                "+ Add"

            return
        end

        local previous,
            previousIndex =
            state.Fleet.EditUserId
            and fleetFindAccount(
                state.Fleet.EditUserId
            )
            or nil

        local label =
            GAG2PremiumRecipientText(
                fleetLabelBox.Text,
                36
            )

        if label == "" then
            label =
                username
        end

        local chosenGroup

        if state.Fleet.ActiveGroup ~= "All" then
            chosenGroup =
                state.Fleet.ActiveGroup
        elseif previous then
            chosenGroup =
                previous.Group
        else
            chosenGroup =
                "Ungrouped"
        end

        local newRecord = {
            UserId =
                userId,

            Name =
                username,

            Label =
                label,

            Group =
                chosenGroup,

            Enabled =
                previous
                and previous.Enabled
                    ~= false
                or true,

            Priority =
                previous
                and previous.Priority
                or (
                    #state.Fleet.Accounts
                    + 1
                ),

            AddedAt =
                previous
                and previous.AddedAt
                or os.time(),
        }

        if previousIndex then
            state.Fleet.Accounts[
                previousIndex
            ] =
                newRecord
        elseif existingIndex then
            state.Fleet.Accounts[
                existingIndex
            ] =
                newRecord
        else
            table.insert(
                state.Fleet.Accounts,
                newRecord
            )
        end

        state.Fleet.EditUserId =
            nil

        state.Fleet.EditOriginalName =
            ""

        fleetUsernameBox.Text =
            ""

        fleetLabelBox.Text =
            ""

        fleetSaveAccount.Text =
            "+ Add"

        state.Fleet.Commit()

        fleetStatus.Text =
            "@"
            .. username
            .. " was saved to "
            .. chosenGroup
            .. "."

        fleetStatus.TextColor3 =
            color.Green
    end)

    state.Fleet.ShowImport =
        function()
            if state.RecipientChangesLocked()
                or state.Fleet.ImportBusy
            then
                return
            end

            closeModal()

            overlay.Visible =
                true

            local importGroup =
                fleetSelectedGroup()

            local importDraft = {}

            local modal =
                create(
                    "Frame",
                    {
                        AnchorPoint =
                            Vector2.new(
                                0.5,
                                0.5
                            ),

                        Position =
                            UDim2.fromScale(
                                0.5,
                                0.5
                            ),

                        Size =
                            UDim2.fromOffset(
                                720,
                                500
                            ),

                        BackgroundColor3 =
                            color.Card,

                        ZIndex =
                            51,
                    },
                    overlay
                )

            round(
                modal,
                18
            )

            outline(
                modal,
                color.Border
            )

            local importTitle =
                text(
                    modal,
                    "Bulk Import · "
                        .. importGroup,
                    UDim2.new(
                        1,
                        -86,
                        0,
                        28
                    ),
                    UDim2.fromOffset(
                        20,
                        16
                    ),
                    18,
                    color.Text,
                    nil,
                    Enum.Font.GothamBold
                )

            importTitle.ZIndex =
                52

            local closeImport =
                button(
                    modal,
                    "X",
                    UDim2.fromOffset(
                        40,
                        40
                    ),
                    UDim2.new(
                        1,
                        -58,
                        0,
                        12
                    ),
                    false
                )

            closeImport.ZIndex =
                53

            local importBox =
                box(
                    modal,
                    "One username or User ID per line",
                    UDim2.new(
                        1,
                        -40,
                        0,
                        250
                    ),
                    UDim2.fromOffset(
                        20,
                        68
                    )
                )

            importBox.MultiLine =
                true

            importBox.TextWrapped =
                true

            importBox.TextYAlignment =
                Enum.TextYAlignment.Top

            importBox.ZIndex =
                52

            local importStatus =
                text(
                    modal,
                    "Paste your accounts, then press Validate. Nothing is added until you confirm.",
                    UDim2.new(
                        1,
                        -40,
                        0,
                        82
                    ),
                    UDim2.fromOffset(
                        20,
                        330
                    ),
                    11,
                    color.Muted
                )

            importStatus.TextWrapped =
                true

            importStatus.TextYAlignment =
                Enum.TextYAlignment.Top

            importStatus.ZIndex =
                52

            local validateButton =
                button(
                    modal,
                    "Validate Accounts",
                    UDim2.fromOffset(
                        206,
                        46
                    ),
                    UDim2.fromOffset(
                        20,
                        434
                    ),
                    false
                )

            local addVerifiedButton =
                button(
                    modal,
                    "Add Verified",
                    UDim2.fromOffset(
                        454,
                        46
                    ),
                    UDim2.fromOffset(
                        246,
                        434
                    ),
                    true
                )

            validateButton.ZIndex =
                53

            addVerifiedButton.ZIndex =
                53

            addVerifiedButton.Text =
                "Add Verified · 0"

            closeImport.MouseButton1Click:Connect(function()
                if state.Fleet.ImportBusy then
                    importStatus.Text =
                        "Validation is still running."

                    importStatus.TextColor3 =
                        color.Yellow

                    return
                end

                closeModal()
            end)

            validateButton.MouseButton1Click:Connect(function()
                if state.Fleet.ImportBusy then
                    return
                end

                local tokens = {}
                local rawSeen = {}

                for token in tostring(
                    importBox.Text
                ):gmatch(
                    "[@%w_]+"
                ) do
                    token =
                        token:gsub(
                            "^@",
                            ""
                        )

                    local key =
                        GAG2PremiumFilterKey(
                            token
                        )

                    if key ~= ""
                        and not rawSeen[key]
                    then
                        rawSeen[key] =
                            true

                        table.insert(
                            tokens,
                            token
                        )
                    end

                    if #tokens >= 150 then
                        break
                    end
                end

                if #tokens == 0 then
                    importStatus.Text =
                        "No usernames or User IDs were found."

                    importStatus.TextColor3 =
                        color.Red

                    return
                end

                state.Fleet.ImportBusy =
                    true

                importDraft =
                    {}

                validateButton.Text =
                    "Validating 0/"
                    .. tostring(
                        #tokens
                    )

                addVerifiedButton.Text =
                    "Add Verified · 0"

                local existingMap = {}

                for _, account in ipairs(
                    state.Fleet.Accounts
                ) do
                    existingMap[
                        account.UserId
                    ] =
                        true
                end

                task.spawn(function()
                    local invalid = 0
                    local duplicates = 0
                    local resultSeen = {}

                    for index, token in ipairs(
                        tokens
                    ) do
                        if importStatus.Parent == nil then
                            state.Fleet.ImportBusy =
                                false

                            return
                        end

                        validateButton.Text =
                            "Validating "
                            .. tostring(index)
                            .. "/"
                            .. tostring(
                                #tokens
                            )

                        importStatus.Text =
                            "Checking "
                            .. tostring(token)
                            .. "..."

                        local userId,
                            username =
                            GAG2PremiumResolveRecipient(
                                token
                            )

                        if not userId then
                            invalid +=
                                1
                        elseif existingMap[userId]
                            or resultSeen[userId]
                        then
                            duplicates +=
                                1
                        else
                            resultSeen[userId] =
                                true

                            table.insert(
                                importDraft,
                                {
                                    UserId =
                                        userId,

                                    Name =
                                        username,

                                    Label =
                                        username,

                                    Group =
                                        importGroup,

                                    Enabled =
                                        true,

                                    Priority =
                                        #state.Fleet.Accounts
                                        + #importDraft
                                        + 1,

                                    AddedAt =
                                        os.time(),
                                }
                            )
                        end
                    end

                    state.Fleet.ImportBusy =
                        false

                    local capacity =
                        math.max(
                            0,
                            100
                            - #state.Fleet.Accounts
                        )

                    if #importDraft > capacity then
                        while #importDraft
                            > capacity
                        do
                            table.remove(
                                importDraft
                            )
                        end
                    end

                    validateButton.Text =
                        "Validate Again"

                    addVerifiedButton.Text =
                        "Add Verified · "
                        .. tostring(
                            #importDraft
                        )

                    importStatus.Text =
                        tostring(
                            #importDraft
                        )
                        .. " verified\n"
                        .. tostring(invalid)
                        .. " invalid\n"
                        .. tostring(duplicates)
                        .. " duplicate or already saved"

                    if capacity <= 0 then
                        importStatus.Text ..=
                            "\nFleet is already at its 100-account limit."
                    end

                    importStatus.TextColor3 =
                        #importDraft > 0
                        and color.Green
                        or color.Yellow
                end)
            end)

            addVerifiedButton.MouseButton1Click:Connect(function()
                if state.Fleet.ImportBusy
                    or #importDraft == 0
                then
                    return
                end

                local added = 0

                for _, account in ipairs(
                    importDraft
                ) do
                    if #state.Fleet.Accounts >= 100 then
                        break
                    end

                    local existing =
                        fleetFindAccount(
                            account.UserId
                        )

                    if not existing then
                        table.insert(
                            state.Fleet.Accounts,
                            account
                        )

                        added +=
                            1
                    end
                end

                closeModal()

                state.Fleet.Commit()

                fleetStatus.Text =
                    tostring(added)
                    .. " accounts were added to "
                    .. importGroup
                    .. "."

                fleetStatus.TextColor3 =
                    added > 0
                    and color.Green
                    or color.Yellow
            end)
        end

    fleetImportButton.MouseButton1Click:Connect(function()
        state.Fleet.ShowImport()
    end)

    fleetLoadValue.MouseButton1Click:Connect(function()
        if state.RecipientChangesLocked() then
            fleetStatus.Text =
                "Finish or safely end the current delivery first."

            fleetStatus.TextColor3 =
                color.Yellow

            return
        end

        local target =
            parseValue(
                fleetTargetBox.Text
            )

        if not target then
            fleetTargetBox.Text =
                ""

            fleetTargetBox.PlaceholderText =
                "Enter a valid target"

            return
        end

        local accounts =
            state.Fleet.EnabledAccounts()

        if #accounts == 0 then
            fleetStatus.Text =
                "This group has no enabled accounts."

            fleetStatus.TextColor3 =
                color.Red

            return
        end

        local snapshots = {}

        for _, account in ipairs(
            accounts
        ) do
            table.insert(
                snapshots,
                {
                    UserId =
                        account.UserId,

                    Name =
                        account.Name,

                    Target =
                        target,
                }
            )
        end

        state.Recipients =
            snapshots

        state.Editing =
            nil

        state.Fleet.LoadedGroup =
            state.Fleet.ActiveGroup

        recipientBox.Text =
            ""

        valueBox.Text =
            ""

        addButton.Text =
            "+ Add"

        renderRecipients()

        if type(
            state.ApplyMailMode
        ) == "function" then
            state.ApplyMailMode(
                "Value"
            )
        else
            task.spawn(
                rebuildPlan
            )
        end

        if type(
            state.ShowMainPage
        ) == "function" then
            state.ShowMainPage(
                "Send"
            )
        end

        messageText.Text =
            tostring(
                #snapshots
            )
            .. " Fleet accounts loaded at "
            .. formatValue(
                target
            )
            .. " each."

        messageText.TextColor3 =
            color.Secondary
    end)

    fleetLoadItems.MouseButton1Click:Connect(function()
        if type(
            state.Fleet.LoadIntoItems
        ) == "function" then
            state.Fleet.LoadIntoItems()
        end
    end)

    state.Fleet.Page =
        fleetPage

    state.Fleet.StatusLabel =
        fleetStatus

    state.Fleet.Commit()
        end

    state.Fleet.Build()

    state.Fleet.Build =
        nil

    local inboxPage =
        create(
            "Frame",
            {
                BackgroundTransparency =
                    1,

                Size =
                    UDim2.fromOffset(
                        896,
                        580
                    ),

                Position =
                    UDim2.fromOffset(
                        12,
                        110
                    ),

                Visible =
                    false,
            },
            window
        )

    local inboxCard =
        card(
            inboxPage,
            UDim2.fromOffset(
                896,
                580
            ),
            UDim2.fromOffset(
                0,
                0
            )
        )

    text(
        inboxCard,
        "INBOX",
        UDim2.fromOffset(
            160,
            20
        ),
        UDim2.fromOffset(
            18,
            15
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local inboxCountLabel =
        text(
            inboxCard,
            "0 / 100 mail",
            UDim2.fromOffset(
                340,
                42
            ),
            UDim2.fromOffset(
                18,
                42
            ),
            27,
            color.Text,
            nil,
            Enum.Font.GothamBold
        )

    local inboxStatusLabel =
        text(
            inboxCard,
            "Checking inbox...",
            UDim2.fromOffset(
                600,
                24
            ),
            UDim2.fromOffset(
                18,
                84
            ),
            11,
            color.Muted
        )

    local inboxAutoButton =
        button(
            inboxCard,
            "Auto Claim: OFF",
            UDim2.fromOffset(
                270,
                46
            ),
            UDim2.fromOffset(
                18,
                126
            ),
            false
        )

    local inboxRefreshButton =
        button(
            inboxCard,
            "Refresh Inbox",
            UDim2.fromOffset(
                270,
                46
            ),
            UDim2.fromOffset(
                306,
                126
            ),
            false
        )

    local inboxClaimButton =
        button(
            inboxCard,
            "Claim All Now",
            UDim2.fromOffset(
                270,
                46
            ),
            UDim2.fromOffset(
                594,
                126
            ),
            true
        )

    text(
        inboxCard,
        "Mail is claimed one at a time automatically. Rapid claims do not need the 10-second sending cooldown.",
        UDim2.new(
            1,
            -36,
            0,
            48
        ),
        UDim2.fromOffset(
            18,
            192
        ),
        11,
        color.Muted
    )

    local inboxClaimedLabel =
        text(
            inboxCard,
            "Claimed this session: 0",
            UDim2.fromOffset(
                400,
                24
            ),
            UDim2.fromOffset(
                18,
                248
            ),
            12,
            color.Text,
            nil,
            Enum.Font.GothamSemibold
        )

    local inboxInfo =
        card(
            inboxCard,
            UDim2.new(
                1,
                -36,
                0,
                220
            ),
            UDim2.fromOffset(
                18,
                300
            )
        )

    text(
        inboxInfo,
        "HOW AUTO CLAIM WORKS",
        UDim2.fromOffset(
            240,
            20
        ),
        UDim2.fromOffset(
            16,
            14
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    text(
        inboxInfo,
        "When enabled, SOPHIA checks your mailbox using your selected interval and claims every item gift it finds.",
        UDim2.new(
            1,
            -32,
            0,
            70
        ),
        UDim2.fromOffset(
            16,
            44
        ),
        12,
        color.Text
    )

    text(
        inboxInfo,
        "Inbox capacity: 100 mail",
        UDim2.fromOffset(
            300,
            24
        ),
        UDim2.fromOffset(
            16,
            130
        ),
        11,
        color.Muted
    )

    text(
        inboxInfo,
        "Current check interval: "
            .. tostring(
                SOPHIA_MAIL_STATE.InboxInterval
                or "2 seconds"
            ),
        UDim2.fromOffset(
            400,
            24
        ),
        UDim2.fromOffset(
            16,
            158
        ),
        11,
        color.Muted
    )

    local historyPage =
        create(
            "Frame",
            {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(896, 580),
                Position = UDim2.fromOffset(12, 110),
                Visible = false,
            },
            window
        )

    local historyCard =
        card(
            historyPage,
            UDim2.fromOffset(896, 580),
            UDim2.fromOffset(0, 0)
        )

    text(
        historyCard,
        "HISTORY",
        UDim2.fromOffset(160, 20),
        UDim2.fromOffset(18, 13),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local historyStatLabels = {}

    local function createHistoryStat(
        title,
        position
    )
        local statCard =
            create(
                "Frame",
                {
                    BackgroundColor3 = color.Field,
                    Size = UDim2.fromOffset(211, 60),
                    Position = position,
                },
                historyCard
            )

        round(statCard, 11)
        outline(statCard, color.Border)

        text(
            statCard,
            title,
            UDim2.new(1, -20, 0, 16),
            UDim2.fromOffset(10, 8),
            9,
            color.Muted,
            nil,
            Enum.Font.GothamBold
        )

        local valueLabel =
            text(
                statCard,
                "0",
                UDim2.new(1, -20, 0, 25),
                UDim2.fromOffset(10, 27),
                16,
                color.Text,
                nil,
                Enum.Font.GothamBold
            )

        historyStatLabels[title] =
            valueLabel
    end

    createHistoryStat(
        "DELIVERIES",
        UDim2.fromOffset(14, 38)
    )

    createHistoryStat(
        "ACCEPTED MAIL",
        UDim2.fromOffset(233, 38)
    )

    createHistoryStat(
        "ITEMS MOVED",
        UDim2.fromOffset(452, 38)
    )

    createHistoryStat(
        "KNOWN VALUE",
        UDim2.fromOffset(671, 38)
    )

    local historySearch =
        box(
            historyCard,
            "Search people or items",
            UDim2.fromOffset(354, 38),
            UDim2.fromOffset(14, 110)
        )

    historySearch.TextSize =
        10

    local historyFilterButtons = {}

    local function createHistoryFilter(
        filterName,
        width,
        x
    )
        local filterButton =
            button(
                historyCard,
                filterName,
                UDim2.fromOffset(width, 38),
                UDim2.fromOffset(x, 110),
                false
            )

        filterButton.TextSize =
            10

        historyFilterButtons[filterName] =
            filterButton

        return filterButton
    end

    createHistoryFilter(
        "All",
        62,
        378
    )

    createHistoryFilter(
        "Sent",
        70,
        446
    )

    createHistoryFilter(
        "Received",
        88,
        522
    )

    createHistoryFilter(
        "Partial",
        78,
        616
    )

    local historyClearButton =
        button(
            historyCard,
            "Clear history",
            UDim2.fromOffset(124, 38),
            UDim2.fromOffset(758, 110),
            false
        )

    historyClearButton.TextSize =
        10

    local historyList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,

                Size = UDim2.fromOffset(868, 404),
                Position = UDim2.fromOffset(14, 162),

                CanvasSize = UDim2.fromOffset(0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,

                ScrollBarThickness = 3,
                ScrollBarImageColor3 = color.Border,

                ScrollingDirection = Enum.ScrollingDirection.Y,
            },
            historyCard
        )

    local historyLayout =
        create(
            "UIListLayout",
            {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            },
            historyList
        )

    local function historyStatusColor(status)
        if status == "Sent" then
            return color.Accent
        elseif status == "Received" then
            return color.Green
        elseif status == "Partial"
            or status == "Stopped"
        then
            return color.Yellow
        end

        return color.Red
    end

    local function historyFormatTime(timestamp)
        local ok, result =
            pcall(
                os.date,
                "%d %b %Y  ·  %H:%M",
                math.floor(
                    tonumber(timestamp)
                        or os.time()
                )
            )

        return ok
                and result
            or "Unknown time"
    end

    local function historyMatchesSearch(
        record,
        query
    )
        if query == "" then
            return true
        end

        local searchable =
            tostring(
                record.OtherName
                    or ""
            )
            .. " "
            .. tostring(
                record.Mode
                    or ""
            )
            .. " "
            .. tostring(
                record.Status
                    or ""
            )

        for _, item in ipairs(
            type(record.Items) == "table"
                and record.Items
                or {}
        ) do
            searchable ..=
                " "
                .. tostring(
                    item.Name
                        or ""
                )
                .. " "
                .. tostring(
                    item.Details
                        or ""
                )
        end

        return searchable
            :lower()
            :find(
                query,
                1,
                true
            ) ~= nil
    end

    local function refreshHistoryFilters()
        for filterName, filterButton in pairs(
            historyFilterButtons
        ) do
            local selected =
                SOPHIA_MAIL_RUNTIME.HistoryFilter
                    == filterName

            filterButton.BackgroundColor3 =
                selected
                    and color.Accent
                    or color.Field

            filterButton.TextColor3 =
                selected
                    and color.White
                    or color.Secondary

            local stroke =
                filterButton:FindFirstChildOfClass(
                    "UIStroke"
                )

            if stroke then
                stroke.Color =
                    selected
                        and Color3.fromRGB(
                            83,
                            148,
                            247
                        )
                        or color.Border
            end
        end
    end

    local function refreshHistoryPage()
        for _, child in ipairs(
            historyList:GetChildren()
        ) do
            if child ~= historyLayout then
                child:Destroy()
            end
        end

        local records =
            type(SOPHIA_MAIL_HISTORY) == "table"
            and type(SOPHIA_MAIL_HISTORY.Records) == "table"
            and SOPHIA_MAIL_HISTORY.Records
            or {}

        local deliveries = 0
        local acceptedMails = 0
        local movedItems = 0
        local knownValue = 0

        for _, record in ipairs(records) do
            deliveries +=
                1

            acceptedMails +=
                tonumber(
                    record.AcceptedMails
                )
                or 0

            movedItems +=
                tonumber(
                    record.SentItems
                )
                or 0

            knownValue +=
                tonumber(
                    record.AcceptedValue
                )
                or 0
        end

        historyStatLabels[
            "DELIVERIES"
        ].Text =
            tostring(deliveries)

        historyStatLabels[
            "ACCEPTED MAIL"
        ].Text =
            tostring(acceptedMails)

        historyStatLabels[
            "ITEMS MOVED"
        ].Text =
            tostring(movedItems)

        historyStatLabels[
            "KNOWN VALUE"
        ].Text =
            formatValue(knownValue)

        refreshHistoryFilters()

        local query =
            tostring(
                SOPHIA_MAIL_RUNTIME.HistorySearch
                    or ""
            )
                :lower()
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        local selectedFilter =
            tostring(
                SOPHIA_MAIL_RUNTIME.HistoryFilter
                    or "All"
            )

        local visibleRecords = {}

        for _, record in ipairs(records) do
            local status =
                tostring(
                    record.Status
                        or "Failed"
                )

            local direction =
                tostring(
                    record.Direction
                        or "Sent"
                )

            local filterMatches =
                selectedFilter == "All"
                or (
                    selectedFilter == "Sent"
                    and status == "Sent"
                )
                or (
                    selectedFilter == "Received"
                    and (
                        status == "Received"
                        or direction == "Received"
                    )
                )
                or (
                    selectedFilter == "Partial"
                    and (
                        status == "Partial"
                        or status == "Stopped"
                    )
                )

            if filterMatches
                and historyMatchesSearch(
                    record,
                    query
                )
            then
                table.insert(
                    visibleRecords,
                    record
                )
            end
        end

        if #visibleRecords == 0 then
            local empty =
                create(
                    "Frame",
                    {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(
                            1,
                            -2,
                            0,
                            330
                        ),
                        LayoutOrder = 1,
                    },
                    historyList
                )

            text(
                empty,
                #records == 0
                    and "No delivery history yet"
                    or "No matching deliveries",
                UDim2.new(1, -30, 0, 30),
                UDim2.fromOffset(15, 116),
                16,
                color.Text,
                Enum.TextXAlignment.Center,
                Enum.Font.GothamSemibold
            )

            text(
                empty,
                #records == 0
                    and "Accepted sends and claimed mail will appear here."
                    or "Try another search or filter.",
                UDim2.new(1, -30, 0, 24),
                UDim2.fromOffset(15, 151),
                10,
                color.Muted,
                Enum.TextXAlignment.Center
            )

            return
        end

        for recordIndex, record in ipairs(
            visibleRecords
        ) do
            local recordId =
                tostring(
                    record.Id
                        or recordIndex
                )

            local expanded =
                SOPHIA_MAIL_RUNTIME.ExpandedHistory[
                    recordId
                ] == true

            local items =
                type(record.Items) == "table"
                    and record.Items
                    or {}

            local itemAreaHeight =
                expanded
                    and (
                        math.max(
                            1,
                            #items
                        ) * 48
                        + 14
                    )
                    or 0

            local recordHeight =
                74 + itemAreaHeight

            local status =
                tostring(
                    record.Status
                        or "Failed"
                )

            local direction =
                tostring(
                    record.Direction
                        or "Sent"
                )

            local statusColor =
                historyStatusColor(
                    status
                )

            local recordCard =
                create(
                    "Frame",
                    {
                        BackgroundColor3 = color.Field,
                        Size = UDim2.new(
                            1,
                            -2,
                            0,
                            recordHeight
                        ),
                        LayoutOrder = recordIndex,
                    },
                    historyList
                )

            round(recordCard, 12)
            outline(recordCard, color.Border)

            local accentLine =
                create(
                    "Frame",
                    {
                        BackgroundColor3 = statusColor,
                        Size = UDim2.fromOffset(
                            4,
                            recordHeight
                        ),
                        Position = UDim2.fromOffset(
                            0,
                            0
                        ),
                    },
                    recordCard
                )

            round(accentLine, 4)

            local userId =
                tonumber(
                    record.OtherUserId
                )
                or 0

            if userId > 0 then
                addAvatar(
                    recordCard,
                    userId,
                    UDim2.fromOffset(42, 42),
                    UDim2.fromOffset(14, 14)
                )
            else
                local avatarPlaceholder =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 = color.Hover,
                            Size = UDim2.fromOffset(42, 42),
                            Position = UDim2.fromOffset(14, 14),
                        },
                        recordCard
                    )

                round(avatarPlaceholder, 999)
            end

            local otherName =
                tostring(
                    record.OtherName
                        or "Unknown user"
                )

            local title =
                direction == "Received"
                    and (
                        "From @"
                        .. otherName
                    )
                    or (
                        "To @"
                        .. otherName
                    )

            text(
                recordCard,
                title,
                UDim2.new(1, -340, 0, 22),
                UDim2.fromOffset(66, 11),
                12,
                color.Text,
                nil,
                Enum.Font.GothamBold
            )

            local acceptedMails =
                tonumber(
                    record.AcceptedMails
                )
                or 0

            local attemptedMails =
                tonumber(
                    record.AttemptedMails
                )
                or acceptedMails

            local sentItems =
                tonumber(
                    record.SentItems
                )
                or 0

            local plannedItems =
                tonumber(
                    record.PlannedItems
                )
                or sentItems

            local summary =
                historyFormatTime(
                    record.Timestamp
                )
                .. "  ·  "
                .. tostring(
                    record.Mode
                        or "Mail"
                )
                .. "  ·  "
                .. tostring(acceptedMails)
                .. "/"
                .. tostring(attemptedMails)
                .. " mail  ·  "
                .. tostring(sentItems)
                .. "/"
                .. tostring(plannedItems)
                .. " items"

            text(
                recordCard,
                summary,
                UDim2.new(1, -250, 0, 20),
                UDim2.fromOffset(66, 36),
                9,
                color.Muted
            )

            local value =
                tonumber(
                    record.AcceptedValue
                )
                or 0

            if value > 0 then
                text(
                    recordCard,
                    formatValue(value),
                    UDim2.fromOffset(120, 20),
                    UDim2.new(
                        1,
                        -250,
                        0,
                        13
                    ),
                    11,
                    color.Text,
                    Enum.TextXAlignment.Right,
                    Enum.Font.GothamSemibold
                )
            end

            text(
                recordCard,
                status,
                UDim2.fromOffset(92, 22),
                UDim2.new(
                    1,
                    -122,
                    0,
                    12
                ),
                10,
                statusColor,
                Enum.TextXAlignment.Center,
                Enum.Font.GothamBold
            )

            text(
                recordCard,
                expanded
                    and "−"
                    or "+",
                UDim2.fromOffset(24, 24),
                UDim2.new(
                    1,
                    -34,
                    0,
                    23
                ),
                15,
                color.Muted,
                Enum.TextXAlignment.Center,
                Enum.Font.GothamBold
            )

            local expandButton =
                create(
                    "TextButton",
                    {
                        BackgroundTransparency = 1,
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(
                            1,
                            0,
                            0,
                            72
                        ),
                    },
                    recordCard
                )

            expandButton.MouseButton1Click:Connect(function()
                SOPHIA_MAIL_RUNTIME.ExpandedHistory[
                    recordId
                ] =
                    not expanded

                refreshHistoryPage()
            end)

            if expanded then
                create(
                    "Frame",
                    {
                        BackgroundColor3 = color.Border,
                        BackgroundTransparency = 0.2,
                        Size = UDim2.new(
                            1,
                            -28,
                            0,
                            1
                        ),
                        Position = UDim2.fromOffset(
                            14,
                            72
                        ),
                    },
                    recordCard
                )

                if #items == 0 then
                    text(
                        recordCard,
                        "No item details were provided by this mail.",
                        UDim2.new(1, -32, 0, 46),
                        UDim2.fromOffset(16, 82),
                        10,
                        color.Muted,
                        Enum.TextXAlignment.Center
                    )
                else
                    for itemIndex, item in ipairs(
                        items
                    ) do
                        local itemY =
                            80
                            + (
                                itemIndex - 1
                            ) * 48

                        local itemRow =
                            create(
                                "Frame",
                                {
                                    BackgroundColor3 = color.Hover,
                                    Size = UDim2.new(
                                        1,
                                        -28,
                                        0,
                                        40
                                    ),
                                    Position = UDim2.fromOffset(
                                        14,
                                        itemY
                                    ),
                                },
                                recordCard
                            )

                        round(itemRow, 9)

                        create(
                            "ImageLabel",
                            {
                                BackgroundTransparency = 1,
                                Image = GAG2PremiumHistoryNormalizeIcon(
                                    item.Icon
                                ),
                                Size = UDim2.fromOffset(30, 30),
                                Position = UDim2.fromOffset(7, 5),
                                ScaleType = Enum.ScaleType.Fit,
                            },
                            itemRow
                        )

                        text(
                            itemRow,
                            tostring(
                                item.Name
                                    or "Unknown item"
                            ),
                            UDim2.new(1, -280, 0, 18),
                            UDim2.fromOffset(46, 3),
                            10,
                            color.Text,
                            nil,
                            Enum.Font.GothamSemibold
                        )

                        local count =
                            math.max(
                                0,
                                math.floor(
                                    tonumber(
                                        item.Count
                                    )
                                    or 0
                                )
                            )

                        local sent =
                            math.max(
                                0,
                                math.floor(
                                    tonumber(
                                        item.Sent
                                    )
                                    or count
                                )
                            )

                        local details =
                            tostring(
                                item.Details
                                    or "Item"
                            )
                            .. "  ·  x"
                            .. tostring(count)

                        local itemValue =
                            tonumber(
                                item.Value
                            )
                            or 0

                        if itemValue > 0 then
                            details ..=
                                "  ·  "
                                .. formatValue(
                                    itemValue
                                )
                        end

                        text(
                            itemRow,
                            details,
                            UDim2.new(1, -280, 0, 16),
                            UDim2.fromOffset(46, 21),
                            8,
                            color.Muted
                        )

                        local itemStatus
                        local itemStatusColor

                        if direction == "Received" then
                            itemStatus =
                                "Received x"
                                .. tostring(sent)

                            itemStatusColor =
                                color.Green
                        elseif sent >= count then
                            itemStatus =
                                "Sent x"
                                .. tostring(sent)

                            itemStatusColor =
                                color.Green
                        elseif sent > 0 then
                            itemStatus =
                                tostring(sent)
                                .. "/"
                                .. tostring(count)
                                .. " sent"

                            itemStatusColor =
                                color.Yellow
                        else
                            itemStatus =
                                "Not sent"

                            itemStatusColor =
                                color.Red
                        end

                        text(
                            itemRow,
                            itemStatus,
                            UDim2.fromOffset(150, 40),
                            UDim2.new(
                                1,
                                -162,
                                0,
                                0
                            ),
                            9,
                            itemStatusColor,
                            Enum.TextXAlignment.Right,
                            Enum.Font.GothamBold
                        )
                    end
                end
            end
        end
    end

    SOPHIA_MAIL_RUNTIME.RefreshHistory =
        refreshHistoryPage

    for filterName, filterButton in pairs(
        historyFilterButtons
    ) do
        filterButton.MouseButton1Click:Connect(function()
            SOPHIA_MAIL_RUNTIME.HistoryFilter =
                filterName

            refreshHistoryPage()
        end)
    end

    historySearch:GetPropertyChangedSignal(
        "Text"
    ):Connect(function()
        SOPHIA_MAIL_RUNTIME.HistorySearch =
            historySearch.Text

        refreshHistoryPage()
    end)

    historyClearButton.MouseButton1Click:Connect(function()
        if #SOPHIA_MAIL_HISTORY.Records == 0 then
            return
        end

        showModal(
            "Clear delivery history?",
            "This removes all locally saved mail history. This cannot be undone.",
            "Clear history",
            function()
                GAG2PremiumHistoryClear()
            end,
            true
        )
    end)

    refreshHistoryPage()

    local settingsPage =
        create(
            "Frame",
            {
                BackgroundTransparency =
                    1,

                Size =
                    UDim2.fromOffset(
                        896,
                        580
                    ),

                Position =
                    UDim2.fromOffset(
                        12,
                        110
                    ),

                Visible =
                    false,
            },
            window
        )

    local settingsCard =
        card(
            settingsPage,
            UDim2.fromOffset(
                896,
                580
            ),
            UDim2.fromOffset(
                0,
                0
            )
        )

    text(
        settingsCard,
        "SETTINGS",
        UDim2.fromOffset(
            160,
            20
        ),
        UDim2.fromOffset(
            18,
            15
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    text(
        settingsCard,
        "HUD",
        UDim2.fromOffset(
            120,
            24
        ),
        UDim2.fromOffset(
            18,
            54
        ),
        14,
        color.Text,
        nil,
        Enum.Font.GothamSemibold
    )

    local settingsScaleButton =
        button(
            settingsCard,
            "HUD Scale: "
                .. tostring(
                    SOPHIA_MAIL_STATE.HudScale
                    or "100%"
                ),
            UDim2.fromOffset(
                270,
                46
            ),
            UDim2.fromOffset(
                18,
                92
            ),
            false
        )

    local settingsMinimizedButton =
        button(
            settingsCard,
            "Start Minimized: "
                .. (
                    SOPHIA_MAIL_STATE.StartMinimized
                        and "ON"
                        or "OFF"
                ),
            UDim2.fromOffset(
                270,
                46
            ),
            UDim2.fromOffset(
                306,
                92
            ),
            false
        )

    local settingsResetButton =
        button(
            settingsCard,
            "Reset HUD Position",
            UDim2.fromOffset(
                270,
                46
            ),
            UDim2.fromOffset(
                594,
                92
            ),
            false
        )

    text(
        settingsCard,
        "Click HUD Scale to cycle between 80%, 90%, 100%, and 110%. Text stays readable at every size.",
        UDim2.new(
            1,
            -36,
            0,
            30
        ),
        UDim2.fromOffset(
            18,
            158
        ),
        11,
        color.Muted
    )

    local settingsInfo =
        card(
            settingsCard,
            UDim2.new(
                1,
                -36,
                0,
                250
            ),
            UDim2.fromOffset(
                18,
                214
            )
        )

    text(
        settingsInfo,
        "MAIL LIMITS",
        UDim2.fromOffset(
            180,
            20
        ),
        UDim2.fromOffset(
            16,
            14
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    text(
        settingsInfo,
        "20 items per send",
        UDim2.fromOffset(
            300,
            26
        ),
        UDim2.fromOffset(
            16,
            50
        ),
        12,
        color.Text
    )

    text(
        settingsInfo,
        "10.05 seconds between accepted sends",
        UDim2.fromOffset(
            400,
            26
        ),
        UDim2.fromOffset(
            16,
            84
        ),
        12,
        color.Text
    )

    text(
        settingsInfo,
        "50 accepted sends per day",
        UDim2.fromOffset(
            300,
            26
        ),
        UDim2.fromOffset(
            16,
            118
        ),
        12,
        color.Text
    )

    text(
        settingsInfo,
        "The daily counter is locally tracked because the game does not expose the sender's daily usage.",
        UDim2.new(
            1,
            -32,
            0,
            48
        ),
        UDim2.fromOffset(
            16,
            166
        ),
        11,
        color.Muted
    )

    local function refreshInboxPage()
        local count =
            math.max(
                0,
                math.floor(
                    tonumber(
                        SOPHIA_MAIL_RUNTIME.InboxCount
                    )
                    or 0
                )
            )

        inboxCountLabel.Text =
            tostring(count)
            .. " / "
            .. tostring(
                SOPHIA_MAIL_INBOX_CAPACITY
            )
            .. " mail"

        inboxStatusLabel.Text =
            tostring(
                SOPHIA_MAIL_RUNTIME.InboxStatus
                or "Inbox ready"
            )

        inboxClaimedLabel.Text =
            "Claimed this session: "
            .. tostring(
                SOPHIA_MAIL_RUNTIME.InboxClaimed
                or 0
            )

        local autoClaim =
            SOPHIA_MAIL_STATE.AutoClaim == true

        inboxAutoButton.Text =
            "Auto Claim: "
            .. (
                autoClaim
                    and "ON"
                    or "OFF"
            )

        inboxAutoButton.BackgroundColor3 =
            autoClaim
                and color.Accent
                or color.Field
    end

    local function showMainPage(
        tabName
    )
        if state.Running
            and tabName ~= state.ActiveTab
        then
            return
        end

        local validTabs = {
            Send = true,
            Fleet = true,
            Inbox = true,
            History = true,
            Settings = true,
        }

        if validTabs[tabName] ~= true then
            tabName =
                "Send"
        end

        state.ActiveTab =
            tabName

        local expanded =
            not state.Minimized

        content.Visible =
            expanded
            and tabName == "Send"

        sendModeBar.Visible =
            expanded
            and tabName == "Send"

        state.Fleet.Page.Visible =
            expanded
            and tabName == "Fleet"

        inboxPage.Visible =
            expanded
            and tabName == "Inbox"

        historyPage.Visible =
            expanded
            and tabName == "History"

        settingsPage.Visible =
            expanded
            and tabName == "Settings"

        for currentName, currentButton in pairs(
            tabButtons
        ) do
            local selected =
                currentName == tabName

            currentButton.TextColor3 =
                selected
                    and color.Accent
                    or color.Muted

            currentButton.Font =
                selected
                    and Enum.Font.GothamBold
                    or Enum.Font.GothamSemibold

            tabLines[currentName].Visible =
                selected
        end

        if tabName == "Send" then
            subtitle.Text =
                state.MailMode == "Items"
                    and "Pick exact items"
                    or "Send fruits by value"
        elseif tabName == "Fleet" then
            subtitle.Text =
                "Manage alt accounts"

            if type(
                state.Fleet.Refresh
            ) == "function" then
                state.Fleet.Refresh()
            end
        elseif tabName == "Inbox" then
            subtitle.Text =
                "Claim incoming mail"

            refreshInboxPage()

            task.spawn(function()
                GAG2PremiumRefreshInboxCount()

                if inboxPage.Parent ~= nil then
                    refreshInboxPage()
                end
            end)
        elseif tabName == "History" then
            subtitle.Text =
                "Recent deliveries"

            refreshHistoryPage()
        else
            subtitle.Text =
                "Mail preferences"
        end
    end

    state.ShowMainPage =
        showMainPage

    state.TabBar =
        tabBar

    state.SendModeBar =
        sendModeBar

    state.PageFrames = {
        Send =
            content,

        Fleet =
            state.Fleet.Page,

        Inbox =
            inboxPage,

        History =
            historyPage,

        Settings =
            settingsPage,
    }

    for tabName, tabButton in pairs(
        tabButtons
    ) do
        local selectedTab =
            tabName

        tabButton.MouseButton1Click:Connect(function()
            showMainPage(
                selectedTab
            )
        end)
    end

    inboxAutoButton.MouseButton1Click:Connect(function()
        GAG2PremiumSetAutoClaim(
            SOPHIA_MAIL_STATE.AutoClaim
                ~= true
        )

        refreshInboxPage()
    end)

    inboxRefreshButton.MouseButton1Click:Connect(function()
        inboxStatusLabel.Text =
            "Checking inbox..."

        task.spawn(function()
            GAG2PremiumRefreshInboxCount()

            if inboxPage.Parent ~= nil then
                refreshInboxPage()
            end
        end)
    end)

    inboxClaimButton.MouseButton1Click:Connect(function()
        inboxStatusLabel.Text =
            "Claiming mail..."

        task.spawn(function()
            GAG2PremiumClaimInbox(
                true
            )

            if inboxPage.Parent ~= nil then
                refreshInboxPage()
            end
        end)
    end)

    settingsScaleButton.MouseButton1Click:Connect(function()
        local choices = {
            "80%",
            "90%",
            "100%",
            "110%",
        }

        local current =
            GAG2PremiumNormalizeScale(
                SOPHIA_MAIL_STATE.HudScale
                or "100%"
            )

        local nextIndex =
            1

        for index, choice in ipairs(
            choices
        ) do
            if choice == current then
                nextIndex =
                    index % #choices
                    + 1

                break
            end
        end

        local newScale =
            GAG2PremiumSetHudScale(
                choices[nextIndex]
            )

        settingsScaleButton.Text =
            "HUD Scale: "
            .. tostring(newScale)
    end)

    settingsMinimizedButton.MouseButton1Click:Connect(function()
        SOPHIA_MAIL_STATE.StartMinimized =
            SOPHIA_MAIL_STATE.StartMinimized
                ~= true

        settingsMinimizedButton.Text =
            "Start Minimized: "
            .. (
                SOPHIA_MAIL_STATE.StartMinimized
                    and "ON"
                    or "OFF"
            )

        GAG2PremiumSaveSettings()
    end)

    settingsResetButton.MouseButton1Click:Connect(function()
        GAG2PremiumResetPosition()

        SophiaNotify(
            "SOPHIA Mail",
            "HUD position reset.",
            3
        )
    end)

    refreshInboxPage()

    showMainPage(
        "Send"
    )

    local itemPanel =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Back,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                Position =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                Active =
                    true,

                Visible =
                    false,

                ZIndex =
                    10,
            },
            content
        )

    local itemRecipientCard =
        card(
            itemPanel,
            UDim2.fromOffset(
                430,
                212
            ),
            UDim2.fromOffset(
                0,
                0
            )
        )

    local itemRecipientCount =
        text(
            itemRecipientCard,
            "RECIPIENTS · 0 ADDED",
            UDim2.fromOffset(
                218,
                20
            ),
            UDim2.fromOffset(
                14,
                9
            ),
            11,
            color.Secondary,
            nil,
            Enum.Font.GothamBold
        )

    state.ExactClearButton =
        button(
            itemRecipientCard,
            "Clear",
            UDim2.fromOffset(
                62,
                29
            ),
            UDim2.new(
                1,
                -76,
                0,
                4
            ),
            false
        )

    state.ExactClearButton.TextSize =
        12

    state.ExactClearButton.TextColor3 =
        color.Muted

    state.ExactClearButton.Visible =
        false

    state.SavedRecipients.ItemButton =
        button(
            itemRecipientCard,
            "★ Saved 0",
            UDim2.fromOffset(
                104,
                29
            ),
            UDim2.fromOffset(
                242,
                4
            ),
            false
        )

    state.SavedRecipients.ItemButton.TextSize =
        13

    state.SavedRecipients.ItemButton.TextColor3 =
        color.Text

    state.SavedRecipients.UpdateButtons()

    local itemRecipientBox =
        box(
            itemRecipientCard,
            "Username or User ID",
            UDim2.fromOffset(
                306,
                40
            ),
            UDim2.fromOffset(
                14,
                35
            )
        )

    local itemRecipientAdd =
        button(
            itemRecipientCard,
            "+ Add",
            UDim2.fromOffset(
                88,
                40
            ),
            UDim2.fromOffset(
                328,
                35
            ),
            true
        )

    state.SavedRecipients.ItemButton.MouseButton1Click:Connect(function()
        state.SavedRecipients.Show(
            itemRecipientBox
        )
    end)

    local itemRecipientList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency =
                    1,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        0,
                        123
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        82
                    ),

                CanvasSize =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                ScrollBarThickness =
                    3,

                ScrollBarImageColor3 =
                    color.Border,
            },
            itemRecipientCard
        )

    local itemRecipientLayout =
        create(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        5
                    ),
            },
            itemRecipientList
        )

    local itemOptionsCard =
        card(
            itemPanel,
            UDim2.fromOffset(
                454,
                212
            ),
            UDim2.fromOffset(
                442,
                0
            )
        )

    text(
        itemOptionsCard,
        "CHOOSE ITEMS",
        UDim2.fromOffset(
            160,
            20
        ),
        UDim2.fromOffset(
            14,
            9
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local itemInventoryCount =
        text(
            itemOptionsCard,
            "Not scanned",
            UDim2.fromOffset(
                220,
                20
            ),
            UDim2.new(
                1,
                -234,
                0,
                9
            ),
            12,
            color.Secondary,
            Enum.TextXAlignment.Right
        )

    local itemCategoryNames = {
        "Fruits",
        "Seeds",
        "Gear",
        "Props",
        "Pets",
        "Eggs",
    }

    local itemCategoryButtons =
        {}

    for index, categoryName in ipairs(
        itemCategoryNames
    ) do
        local categoryButton =
            button(
                itemOptionsCard,
                categoryName,
                UDim2.fromOffset(
                    66,
                    30
                ),
                UDim2.fromOffset(
                    14 + (
                        index - 1
                    ) * 71,
                    36
                ),
                state.ExactCategories[
                    categoryName
                ] == true
            )

        categoryButton.TextSize =
            9

        itemCategoryButtons[categoryName] =
            categoryButton
    end

    local itemSearchBox =
        box(
            itemOptionsCard,
            "Search owned items",
            UDim2.fromOffset(
                292,
                38
            ),
            UDim2.fromOffset(
                14,
                75
            )
        )

    local itemRefreshButton =
        button(
            itemOptionsCard,
            "Refresh",
            UDim2.fromOffset(
                126,
                38
            ),
            UDim2.fromOffset(
                314,
                75
            ),
            true
        )

    local itemProtectButton =
        button(
            itemOptionsCard,
            "Skip favorites: ON",
            UDim2.fromOffset(
                208,
                40
            ),
            UDim2.fromOffset(
                14,
                122
            ),
            false
        )

    local itemQueueButton =
        button(
            itemOptionsCard,
            "Show selected",
            UDim2.fromOffset(
                210,
                40
            ),
            UDim2.fromOffset(
                230,
                122
            ),
            false
        )

    local itemOptionsInfo =
        text(
            itemOptionsCard,
            "Only owned items are shown. Stacked eggs use their live inventory count.",
            UDim2.new(
                1,
                -28,
                0,
                28
            ),
            UDim2.fromOffset(
                14,
                171
            ),
            9,
            color.Muted
        )

    itemOptionsInfo.TextWrapped =
        true

    local itemBrowseCard =
        card(
            itemPanel,
            UDim2.fromOffset(
                594,
                324
            ),
            UDim2.fromOffset(
                0,
                224
            )
        )

    local itemBrowseTitle =
        text(
            itemBrowseCard,
            "OWNED ITEMS",
            UDim2.fromOffset(
                180,
                20
            ),
            UDim2.fromOffset(
                14,
                9
            ),
            10,
            color.Muted,
            nil,
            Enum.Font.GothamBold
        )

    local itemBrowseCount =
        text(
            itemBrowseCard,
            "0 items",
            UDim2.fromOffset(
                220,
                20
            ),
            UDim2.new(
                1,
                -234,
                0,
                9
            ),
            12,
            color.Secondary,
            Enum.TextXAlignment.Right
        )

    local itemBrowseList =
        create(
            "ScrollingFrame",
            {
                BackgroundTransparency =
                    1,

                BorderSizePixel =
                    0,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        1,
                        -42
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        35
                    ),

                CanvasSize =
                    UDim2.fromOffset(
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                ScrollBarThickness =
                    3,

                ScrollBarImageColor3 =
                    color.Border,
            },
            itemBrowseCard
        )

    local itemBrowseLayout =
        create(
            "UIListLayout",
            {
                Padding =
                    UDim.new(
                        0,
                        6
                    ),
            },
            itemBrowseList
        )

    local itemSummaryCard =
        card(
            itemPanel,
            UDim2.fromOffset(
                290,
                324
            ),
            UDim2.fromOffset(
                606,
                224
            )
        )

    text(
        itemSummaryCard,
        "SUMMARY",
        UDim2.fromOffset(
            160,
            20
        ),
        UDim2.fromOffset(
            14,
            9
        ),
        10,
        color.Muted,
        nil,
        Enum.Font.GothamBold
    )

    local itemSummaryText =
        text(
            itemSummaryCard,
            "People: 0\nItems: 0\nSends: 0\nKnown sendable: 0\nTime: Ready",
            UDim2.new(
                1,
                -28,
                0,
                125
            ),
            UDim2.fromOffset(
                14,
                39
            ),
            11,
            color.Text
        )

    itemSummaryText.TextYAlignment =
        Enum.TextYAlignment.Top

    local itemMessageText =
        text(
            itemSummaryCard,
            "Add a recipient, choose them, then add items.",
            UDim2.new(
                1,
                -28,
                0,
                57
            ),
            UDim2.fromOffset(
                14,
                171
            ),
            10,
            color.Muted
        )

    itemMessageText.TextWrapped =
        true

    itemMessageText.TextYAlignment =
        Enum.TextYAlignment.Top

    local itemProgressTrack =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Hover,

                Size =
                    UDim2.new(
                        1,
                        -28,
                        0,
                        6
                    ),

                Position =
                    UDim2.fromOffset(
                        14,
                        237
                    ),
            },
            itemSummaryCard
        )

    round(
        itemProgressTrack,
        3
    )

    local itemProgressFill =
        create(
            "Frame",
            {
                BackgroundColor3 =
                    color.Accent,

                Size =
                    UDim2.fromScale(
                        0,
                        1
                    ),
            },
            itemProgressTrack
        )

    round(
        itemProgressFill,
        3
    )

    local itemSendButton =
        button(
            itemSummaryCard,
            "Review and send",
            UDim2.new(
                1,
                -28,
                0,
                58
            ),
            UDim2.fromOffset(
                14,
                252
            ),
            true
        )

    local function setSelectedButton(
        targetButton,
        selected
    )
        targetButton.BackgroundColor3 =
            selected
                and color.Accent
                or color.Field

        local stroke =
            targetButton:FindFirstChildOfClass(
                "UIStroke"
            )

        if stroke then
            stroke.Color =
                selected
                    and Color3.fromRGB(
                        83,
                        148,
                        247
                    )
                    or color.Border
        end
    end

    local function cleanItemKey(value)
        return tostring(
            value or ""
        )
            :lower()
            :gsub(
                "[%s%p_]",
                ""
            )
    end

    local function cleanItemName(value)
        local result =
            tostring(
                value or ""
            )

        result =
            result:gsub(
                "%s*%[%s*[xX]%d+%s*%]%s*$",
                ""
            )

        result =
            result:gsub(
                "%s+[xX]%d+%s*$",
                ""
            )

        result =
            result:gsub(
                "^%s+",
                ""
            )

        result =
            result:gsub(
                "%s+$",
                ""
            )

        return result
    end

    local function firstText(...)
        for index = 1, select("#", ...) do
            local value =
                select(
                    index,
                    ...
                )

            if type(value) == "string" then
                local cleaned =
                    cleanItemName(
                        value
                    )

                if cleaned ~= "" then
                    return cleaned
                end
            end
        end

        return ""
    end

    local function walkCatalog(
        value,
        callback,
        depth,
        seen
    )
        if type(value) ~= "table" then
            return
        end

        depth =
            depth or 0

        if depth > 6 then
            return
        end

        seen =
            seen or {}

        if seen[value] then
            return
        end

        seen[value] =
            true

        callback(value)

        for _, child in pairs(value) do
            if type(child) == "table" then
                walkCatalog(
                    child,
                    callback,
                    depth + 1,
                    seen
                )
            end
        end
    end

    local imageAssetId =
        nil

    do
        local sharedModules =
            ReplicatedStorage:FindFirstChild(
                "SharedModules"
            )

        local imageModule =
            sharedModules
            and sharedModules:FindFirstChild(
                "ImageAssetId"
            )

        if imageModule
            and imageModule:IsA(
                "ModuleScript"
            )
        then
            local ok,
                result =
                pcall(
                    require,
                    imageModule
                )

            if ok
                and type(result) == "table"
            then
                imageAssetId =
                    result
            end
        end
    end

    local function coerceOwnedImage(
        value
    )
        if typeof(value) == "Instance" then
            if value:IsA(
                "StringValue"
            ) or value:IsA(
                "NumberValue"
            ) or value:IsA(
                "IntValue"
            ) then
                value =
                    value.Value
            elseif value:IsA(
                "ImageLabel"
            ) or value:IsA(
                "ImageButton"
            ) then
                value =
                    value.Image
            elseif value:IsA(
                "Decal"
            ) or value:IsA(
                "Texture"
            ) then
                value =
                    value.Texture
            elseif value:IsA(
                "Tool"
            ) then
                value =
                    value.TextureId
            else
                return ""
            end
        end

        if type(value) == "number" then
            if value <= 0 then
                return ""
            end

            return "rbxassetid://"
                .. tostring(
                    math.floor(value)
                )
        end

        if type(value) ~= "string" then
            return ""
        end

        local result =
            value:gsub(
                "^%s+",
                ""
            ):gsub(
                "%s+$",
                ""
            )

        if result == "" then
            return ""
        end

        if result:match(
            "^%d+$"
        ) then
            return "rbxassetid://"
                .. result
        end

        return result
    end

    local function normalizeOwnedImage(
        value
    )
        local direct =
            coerceOwnedImage(
                value
            )

        local resolver =
            type(imageAssetId) == "table"
            and imageAssetId.ResolveForDisplay
            or nil

        if type(resolver) == "function" then
            local candidates = {
                value,
            }

            if direct ~= "" then
                table.insert(
                    candidates,
                    direct
                )
            end

            for _, candidate in ipairs(
                candidates
            ) do
                local ok,
                    result =
                    pcall(
                        resolver,
                        candidate
                    )

                if not ok then
                    ok,
                    result =
                        pcall(
                            resolver,
                            imageAssetId,
                            candidate
                        )
                end

                if ok then
                    local resolved =
                        coerceOwnedImage(
                            result
                        )

                    if resolved ~= "" then
                        return resolved
                    end
                end
            end
        end

        return direct
    end

    local ownedImageFields = {
        "IMG",
        "Icon",
        "Image",
        "ImageId",
        "ImageID",
        "IconId",
        "IconID",
        "DisplayImage",
        "DisplayIcon",
        "ShopImage",
        "Thumbnail",
        "ThumbnailId",
        "ThumbnailImage",
        "Texture",
        "TextureId",
        "TextureID",
        "FruitImage",
        "FruitIcon",
        "SeedImage",
        "SeedIcon",
        "SeedPackImage",
        "SeedPackIcon",
        "PackImage",
        "EggImage",
        "EggIcon",
        "PetImage",
        "PetIcon",
        "PropImage",
        "PropIcon",
        "CrateImage",
        "CrateIcon",
    }

    local function readOwnedIconCandidate(
        value,
        seen
    )
        local valueType =
            typeof(value)

        if valueType == "Instance" then
            local direct =
                normalizeOwnedImage(
                    value
                )

            if direct ~= "" then
                return direct
            end

            for _, descendant in ipairs(
                value:GetDescendants()
            ) do
                local descendantName =
                    cleanItemKey(
                        descendant.Name
                    )

                local looksLikeImage =
                    descendantName:find(
                        "image",
                        1,
                        true
                    ) ~= nil
                    or descendantName:find(
                        "icon",
                        1,
                        true
                    ) ~= nil
                    or descendantName:find(
                        "texture",
                        1,
                        true
                    ) ~= nil

                if looksLikeImage then
                    local resolved =
                        normalizeOwnedImage(
                            descendant
                        )

                    if resolved ~= "" then
                        return resolved
                    end
                end
            end

            return ""
        end

        if valueType ~= "table" then
            return normalizeOwnedImage(
                value
            )
        end

        seen =
            seen or {}

        if seen[value] then
            return ""
        end

        seen[value] =
            true

        for _, fieldName in ipairs(
            ownedImageFields
        ) do
            local fieldValue =
                value[fieldName]

            if fieldValue ~= nil then
                local resolved =
                    readOwnedIconCandidate(
                        fieldValue,
                        seen
                    )

                if resolved ~= "" then
                    return resolved
                end
            end
        end

        return ""
    end

    local function firstOwnedIcon(...)
        for index = 1, select(
            "#",
            ...
        ) do
            local resolved =
                readOwnedIconCandidate(
                    select(
                        index,
                        ...
                    )
                )

            if resolved ~= "" then
                return resolved
            end
        end

        return ""
    end

    local function loadOwnedCatalogs()
        local catalogs = {
            Seeds = {},
            SeedPacks = {},
            Eggs = {},
            Gear = {},
            Props = {},
            Crates = {},
            Pets = {},
        }

        local sharedModules =
            ReplicatedStorage:FindFirstChild(
                "SharedModules"
            )

        if not sharedModules then
            return catalogs
        end

        local function loadModule(
            moduleName,
            callback
        )
            local module =
                sharedModules:FindFirstChild(
                    moduleName
                )

            if not module
                or not module:IsA(
                    "ModuleScript"
                )
            then
                return
            end

            local ok,
                result =
                pcall(
                    require,
                    module
                )

            if not ok
                or type(result) ~= "table"
            then
                return
            end

            walkCatalog(
                result,
                callback
            )
        end

        loadModule(
            "SeedData",
            function(row)
                local name =
                    firstText(
                        row.SeedName,
                        row.ItemName,
                        row.DisplayName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.Seeds[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        loadModule(
            "SeedPackData",
            function(row)
                local name =
                    firstText(
                        row.SeedPackName,
                        row.PackName,
                        row.ItemName,
                        row.DisplayName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.SeedPacks[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        loadModule(
            "EggData",
            function(row)
                local name =
                    firstText(
                        row.EggName,
                        row.ItemName,
                        row.DisplayName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.Eggs[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        loadModule(
            "GearShopData",
            function(row)
                local name =
                    firstText(
                        row.ItemName,
                        row.DisplayName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.Gear[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        loadModule(
            "PropData",
            function(row)
                local name =
                    firstText(
                        row.PropName,
                        row.ItemName,
                        row.DisplayName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.Props[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        loadModule(
            "CrateData",
            function(row)
                local name =
                    firstText(
                        row.CrateName,
                        row.ItemName,
                        row.DisplayName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.Crates[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        loadModule(
            "PetData",
            function(row)
                local name =
                    firstText(
                        row.DisplayName,
                        row.PetName,
                        row.ItemName,
                        row.Name
                    )

                if name ~= "" then
                    catalogs.Pets[
                        cleanItemKey(name)
                    ] =
                        row
                end
            end
        )

        if type(
            SophiaSniperGetPetData
        ) == "function" then
            local ok,
                petData =
                pcall(
                    SophiaSniperGetPetData
                )

            if ok
                and type(petData) == "table"
            then
                for key, row in pairs(
                    petData
                ) do
                    if type(row) == "table" then
                        local name =
                            firstText(
                                row.DisplayName,
                                row.PetName,
                                row.ItemName,
                                row.Name,
                                type(key) == "string"
                                    and key
                                    or nil
                            )

                        if name ~= "" then
                            catalogs.Pets[
                                cleanItemKey(name)
                            ] =
                                row
                        end
                    end
                end
            end
        end

        local crateFolder =
            sharedModules:FindFirstChild(
                "CrateData"
            )

        if crateFolder
            and not crateFolder:IsA(
                "ModuleScript"
            )
        then
            for _, child in ipairs(
                crateFolder:GetChildren()
            ) do
                if child:IsA(
                    "ModuleScript"
                ) then
                    local crateRow = {
                        CrateName =
                            child.Name,
                    }

                    local ok,
                        result =
                        pcall(
                            require,
                            child
                        )

                    if ok
                        and type(result) == "table"
                    then
                        crateRow =
                            result
                    end

                    catalogs.Crates[
                        cleanItemKey(
                            child.Name
                        )
                    ] =
                        crateRow
                end
            end
        end

        return catalogs
    end

    local function resolveOwnedRecordIcon(
        record,
        catalogs
    )
        if type(record) ~= "table" then
            return ""
        end

        local nameKey =
            cleanItemKey(
                record.Name
            )

        local icon =
            ""

        if record.Group == "Fruits" then
            local seedData =
                catalogs.Seeds[
                    nameKey
                ]

            icon =
                firstOwnedIcon(
                    seedData
                        and seedData.FruitImage,
                    seedData
                        and seedData.FruitIcon,
                    seedData
                )
        elseif record.Group == "Seeds" then
            if record.Category == "SeedPacks" then
                icon =
                    firstOwnedIcon(
                        catalogs.SeedPacks[
                            nameKey
                        ]
                    )
            else
                local seedData =
                    catalogs.Seeds[
                        nameKey
                    ]

                icon =
                    firstOwnedIcon(
                        seedData
                            and seedData.SeedImage,
                        seedData
                            and seedData.SeedIcon,
                        seedData
                    )
            end
        elseif record.Group == "Gear" then
            icon =
                firstOwnedIcon(
                    record.Category == "SeedPacks"
                        and catalogs.SeedPacks[
                            nameKey
                        ]
                        or catalogs.Gear[
                            nameKey
                        ]
                )
        elseif record.Group == "Props" then
            icon =
                firstOwnedIcon(
                    catalogs.Props[
                        nameKey
                    ],
                    catalogs.Crates[
                        nameKey
                    ]
                )
        elseif record.Group == "Eggs" then
            icon =
                firstOwnedIcon(
                    catalogs.Eggs[
                        nameKey
                    ]
                )
        elseif record.Group == "Pets" then
            icon =
                firstOwnedIcon(
                    catalogs.Pets[
                        nameKey
                    ]
                )
        end

        if icon ~= "" then
            return icon
        end

        local instance =
            record.Instance

        if typeof(instance) == "Instance" then
            icon =
                firstOwnedIcon(
                    instance:GetAttribute(
                        "IMG"
                    ),
                    instance:GetAttribute(
                        "Image"
                    ),
                    instance:GetAttribute(
                        "Icon"
                    ),
                    instance:GetAttribute(
                        "TextureId"
                    ),
                    instance
                )
        end

        return icon
    end

    local function readOwnedCount(
        item,
        unique
    )
        if unique then
            return 1
        end

        local count =
            tonumber(
                item:GetAttribute(
                    "Count"
                )
                or item:GetAttribute(
                    "Amount"
                )
                or item:GetAttribute(
                    "Quantity"
                )
                or item:GetAttribute(
                    "Stack"
                )
                or item:GetAttribute(
                    "Uses"
                )
            )
            or 1

        return math.max(
            1,
            math.floor(
                count
            )
        )
    end

    local function readOwnedFavorite(item)
        return item:GetAttribute(
            "IsFavorite"
        ) == true
            or item:GetAttribute(
                "Favorite"
            ) == true
            or item:GetAttribute(
                "Favorited"
            ) == true
    end

    local function classifyOwnedItem(
        item,
        catalogs
    )
        if not (
            item:IsA("Tool")
            or item:IsA("Configuration")
        ) then
            return nil
        end

        local attributes =
            item:GetAttributes()

        local mainCategory =
            firstText(
                attributes.MainCategory,
                attributes.Category
            )

        local itemType =
            firstText(
                attributes.ItemType,
                attributes.Type
            )

        local mainKey =
            cleanItemKey(
                mainCategory
            )

        local typeKey =
            cleanItemKey(
                itemType
            )

        if attributes.HarvestedFruit == true then
            local itemKey =
                firstText(
                    attributes.Id,
                    attributes.FruitId,
                    attributes.FruitID,
                    attributes.UUID,
                    attributes.Guid
                )

            if itemKey == "" then
                return nil
            end

            local name =
                firstText(
                    attributes.FruitName,
                    attributes.Fruit,
                    attributes.ItemName,
                    item.Name
                )

            local mutation =
                firstText(
                    attributes.Mutation,
                    attributes.Variant,
                    attributes.Mutations
                )

            if mutation == "" then
                mutation =
                    "Normal"
            end

            return {
                Group =
                    "Fruits",

                Category =
                    "HarvestedFruits",

                ItemKey =
                    itemKey,

                Name =
                    name,

                Details =
                    mutation,

                Unique =
                    true,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    1,

                Instance =
                    item,
            }
        end

        local petId =
            firstText(
                attributes.PetId,
                attributes.PetID
            )

        local petName =
            firstText(
                attributes.Pet,
                attributes.PetName
            )

        if petId ~= ""
            and petName ~= ""
        then
            local petDetails = {}

            local size =
                firstText(
                    attributes.Size,
                    attributes.PetSize,
                    attributes.SizeName
                )

            local variant =
                firstText(
                    attributes.Variant,
                    attributes.PetType,
                    attributes.TypeName
                )

            if size ~= ""
                and size ~= "Normal"
            then
                table.insert(
                    petDetails,
                    size
                )
            end

            if variant ~= ""
                and variant ~= "Normal"
            then
                table.insert(
                    petDetails,
                    variant
                )
            end

            return {
                Group =
                    "Pets",

                Category =
                    "Pets",

                ItemKey =
                    petId,

                Name =
                    petName,

                Details =
                    #petDetails > 0
                        and table.concat(
                            petDetails,
                            " · "
                        )
                        or "Normal",

                Unique =
                    true,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    1,

                Instance =
                    item,
            }
        end

        local name =
            firstText(
                attributes.Egg,
                attributes.PropName,
                attributes.SeedPackName,
                attributes.SeedName,
                attributes.Seed,
                attributes.GearName,
                attributes.ItemName,
                item.Name
            )

        if name == "" then
            return nil
        end

        local nameKey =
            cleanItemKey(
                name
            )

        local eggName =
            firstText(
                attributes.Egg,
                name
            )

        local eggKey =
            cleanItemKey(
                eggName
            )

        local isEgg =
            mainKey == "egg"
            or mainKey == "eggs"
            or attributes.Egg ~= nil
            or catalogs.Eggs[eggKey] ~= nil

        if isEgg then
            return {
                Group =
                    "Eggs",

                Category =
                    "Eggs",

                ItemKey =
                    eggName,

                Name =
                    eggName,

                Details =
                    "Egg",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if mainKey:find(
            "seedpack",
            1,
            true
        )
            or typeKey:find(
                "seedpack",
                1,
                true
            )
            or catalogs.SeedPacks[nameKey] ~= nil
        then
            return {
                Group =
                    "Gear",

                Category =
                    "SeedPacks",

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Seed Pack",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if mainKey == "seed"
            or mainKey == "seeds"
            or catalogs.Seeds[nameKey] ~= nil
        then
            return {
                Group =
                    "Seeds",

                Category =
                    "Seeds",

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Seed",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if mainKey:find(
            "prop",
            1,
            true
        )
            or catalogs.Props[nameKey] ~= nil
        then
            return {
                Group =
                    "Props",

                Category =
                    "Props",

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Prop",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if catalogs.Crates[nameKey] ~= nil
            or mainKey:find(
                "crate",
                1,
                true
            )
        then
            return {
                Group =
                    "Props",

                Category =
                    nil,

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Crate · needs a mail test",

                Unique =
                    false,

                Supported =
                    false,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        local gearData =
            catalogs.Gear[nameKey]

        local gearType =
            firstText(
                attributes.ItemType,
                gearData
                    and gearData.ItemType,
                name
            )

        local gearKey =
            cleanItemKey(
                gearType
            )

        if gearKey:find(
            "wateringcan",
            1,
            true
        ) then
            return {
                Group =
                    "Gear",

                Category =
                    "WateringCans",

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Watering Can",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if gearKey:find(
            "trowel",
            1,
            true
        ) then
            return {
                Group =
                    "Gear",

                Category =
                    "Trowels",

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Trowel",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if gearKey:find(
            "sprinkler",
            1,
            true
        ) then
            return {
                Group =
                    "Gear",

                Category =
                    "Sprinklers",

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Sprinkler",

                Unique =
                    false,

                Supported =
                    true,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        if gearData ~= nil
            or mainKey:find(
                "gear",
                1,
                true
            )
        then
            return {
                Group =
                    "Gear",

                Category =
                    nil,

                ItemKey =
                    name,

                Name =
                    name,

                Details =
                    "Gear · needs a mail test",

                Unique =
                    false,

                Supported =
                    false,

                Favorite =
                    readOwnedFavorite(
                        item
                    ),

                Count =
                    readOwnedCount(
                        item,
                        false
                    ),

                Instance =
                    item,
            }
        end

        return nil
    end

    local function scanExactItems()
        local catalogs =
            loadOwnedCatalogs()

        local grouped = {}
        local seenInstances = {}

        local roots = {
            player.Character,
            player:FindFirstChildOfClass(
                "Backpack"
            ),
        }

        for _, root in ipairs(roots) do
            if typeof(root) == "Instance" then
                for _, item in ipairs(
                    root:GetChildren()
                ) do
                    if not seenInstances[item] then
                        seenInstances[item] =
                            true

                        local record =
                            classifyOwnedItem(
                                item,
                                catalogs
                            )

                        if record then
                            record.Icon =
                                resolveOwnedRecordIcon(
                                    record,
                                    catalogs
                                )
                        end

                        if record
                            and not (
                                state.ExactProtect
                                and record.Favorite
                            )
                        then
                            local recordKey =
                                table.concat(
                                    {
                                        record.Group,
                                        record.Category
                                            or "Unknown",
                                        cleanItemKey(
                                            record.Name
                                        ),
                                        cleanItemKey(
                                            record.Details
                                        ),
                                    },
                                    "|"
                                )

                            local group =
                                grouped[recordKey]

                            if not group then
                                group = {
                                    Key =
                                        recordKey,

                                    Group =
                                        record.Group,

                                    Category =
                                        record.Category,

                                    ItemKey =
                                        record.ItemKey,

                                    Name =
                                        record.Name,

                                    Details =
                                        record.Details,

                                    Icon =
                                        record.Icon,

                                    Unique =
                                        record.Unique,

                                    Supported =
                                        record.Supported,

                                    Count =
                                        0,

                                    Sources =
                                        {},
                                }

                                grouped[recordKey] =
                                    group
                            end

                            if (
                                type(group.Icon) ~= "string"
                                or group.Icon == ""
                            )
                                and type(record.Icon) == "string"
                                and record.Icon ~= ""
                            then
                                group.Icon =
                                    record.Icon
                            end

                            group.Count +=
                                record.Count

                            table.insert(
                                group.Sources,
                                {
                                    ItemKey =
                                        record.ItemKey,

                                    Count =
                                        record.Count,

                                    Instance =
                                        record.Instance,
                                }
                            )
                        end
                    end
                end
            end
        end

        local records = {}
        local recordMap = {}

        for key, record in pairs(
            grouped
        ) do
            recordMap[key] =
                record

            table.insert(
                records,
                record
            )
        end

        table.sort(
            records,
            function(left, right)
                if left.Group ~= right.Group then
                    return left.Group < right.Group
                end

                if left.Name ~= right.Name then
                    return left.Name:lower()
                        < right.Name:lower()
                end

                return tostring(
                    left.Details
                ):lower()
                    < tostring(
                        right.Details
                    ):lower()
            end
        )

        state.ExactRecords =
            records

        state.ExactRecordMap =
            recordMap

        return records
    end

    local function selectedExactRecipient()
        for _, recipient in ipairs(
            state.ExactRecipients
        ) do
            if recipient.UserId
                == state.ExactSelectedUserId
            then
                return recipient
            end
        end

        return nil
    end

    local function exactQueueFor(userId)
        local queue =
            state.ExactQueues[userId]

        if type(queue) ~= "table" then
            queue = {}

            state.ExactQueues[userId] =
                queue
        end

        return queue
    end

    local function totalQueuedForKey(
        recordKey
    )
        local total = 0

        for _, queue in pairs(
            state.ExactQueues
        ) do
            local entry =
                queue[recordKey]

            if type(entry) == "table" then
                total +=
                    tonumber(
                        entry.Count
                    )
                    or 0
            end
        end

        return total
    end

    local renderExactRecipients
    local renderExactItems
    local updateExactSummary
    local refreshExactItems

    renderExactRecipients =
        function()
            clearRows(
                itemRecipientList,
                itemRecipientLayout
            )

            itemRecipientCount.Text =
                "RECIPIENTS · "
                .. tostring(
                    #state.ExactRecipients
                )
                .. " ADDED"

            state.ExactClearButton.Visible =
                #state.ExactRecipients > 0
                and not state.RecipientChangesLocked()

            if #state.ExactRecipients == 0 then
                local empty =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Field,

                            Size =
                                UDim2.new(
                                    1,
                                    -2,
                                    0,
                                    52
                                ),
                        },
                        itemRecipientList
                    )

                round(
                    empty,
                    10
                )

                text(
                    empty,
                    "No recipients yet",
                    UDim2.new(
                        1,
                        -20,
                        0,
                        20
                    ),
                    UDim2.fromOffset(
                        10,
                        6
                    ),
                    11,
                    color.Text,
                    nil,
                    Enum.Font.GothamSemibold
                )

                text(
                    empty,
                    "Enter a username or User ID above.",
                    UDim2.new(
                        1,
                        -20,
                        0,
                        18
                    ),
                    UDim2.fromOffset(
                        10,
                        27
                    ),
                    9,
                    color.Muted
                )

                return
            end

            for index, recipient in ipairs(
                state.ExactRecipients
            ) do
                local selected =
                    recipient.UserId
                    == state.ExactSelectedUserId

                local row =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                selected
                                    and color.Hover
                                    or color.Field,

                            Size =
                                UDim2.new(
                                    1,
                                    -2,
                                    0,
                                    58
                                ),

                            LayoutOrder =
                                index,
                        },
                        itemRecipientList
                    )

                round(
                    row,
                    10
                )

                local rowStroke =
                    outline(
                        row,
                        selected
                            and color.Accent
                            or color.Border
                    )

                rowStroke.Thickness =
                    selected
                        and 2
                        or 1

                addAvatar(
                    row,
                    recipient.UserId,
                    UDim2.fromOffset(
                        38,
                        38
                    ),
                    UDim2.fromOffset(
                        9,
                        10
                    )
                )

                text(
                    row,
                    "@"
                        .. recipient.Name,
                    UDim2.new(
                        1,
                        -205,
                        0,
                        19
                    ),
                    UDim2.fromOffset(
                        56,
                        8
                    ),
                    10,
                    color.Text,
                    nil,
                    Enum.Font.GothamSemibold
                )

                local queued = 0

                for _, entry in pairs(
                    exactQueueFor(
                        recipient.UserId
                    )
                ) do
                    queued +=
                        tonumber(
                            entry.Count
                        )
                        or 0
                end

                text(
                    row,
                    selected
                            and tostring(
                                queued
                            )
                                .. " selected · currently choosing"
                        or tostring(
                            queued
                        )
                            .. " selected",
                    UDim2.new(
                        1,
                        -205,
                        0,
                        17
                    ),
                    UDim2.fromOffset(
                        56,
                        31
                    ),
                    12,
                    selected
                            and color.Accent
                        or color.Secondary
                )

                local useButton =
                    button(
                        row,
                        selected
                                and "Using"
                            or "Choose",
                        UDim2.fromOffset(
                            58,
                            29
                        ),
                        UDim2.new(
                            1,
                            -104,
                            0,
                            15
                        ),
                        selected
                    )

                local removeButton =
                    button(
                        row,
                        "X",
                        UDim2.fromOffset(
                            29,
                            29
                        ),
                        UDim2.new(
                            1,
                            -39,
                            0,
                            15
                        ),
                        false
                    )

                useButton.TextSize =
                    12

                removeButton.TextSize =
                    10

                useButton.MouseButton1Click:Connect(function()
                    if state.RecipientChangesLocked() then
                        return
                    end

                    state.ExactSelectedUserId =
                        recipient.UserId

                    renderExactRecipients()
                    renderExactItems()
                    updateExactSummary()
                end)

                removeButton.MouseButton1Click:Connect(function()
                    if state.RecipientChangesLocked() then
                        return
                    end

                    state.ExactQueues[
                        recipient.UserId
                    ] =
                        nil

                    table.remove(
                        state.ExactRecipients,
                        index
                    )

                    if state.ExactSelectedUserId
                        == recipient.UserId
                    then
                        local nextRecipient =
                            state.ExactRecipients[
                                math.min(
                                    index,
                                    #state.ExactRecipients
                                )
                            ]

                        state.ExactSelectedUserId =
                            nextRecipient
                                and nextRecipient.UserId
                                or nil
                    end

                    renderExactRecipients()
                    renderExactItems()
                    updateExactSummary()
                end)
            end
        end

    updateExactSummary =
        function()
            local people = 0
            local items = 0
            local sendable = 0
            local sends = 0

            for _, recipient in ipairs(
                state.ExactRecipients
            ) do
                local queue =
                    exactQueueFor(
                        recipient.UserId
                    )

                local recipientEntries = 0
                local hasItems = false

                for _, entry in pairs(
                    queue
                ) do
                    local count =
                        tonumber(
                            entry.Count
                        )
                        or 0

                    if count > 0 then
                        hasItems =
                            true

                        items +=
                            count

                        if entry.Supported then
                            sendable +=
                                count

                            recipientEntries +=
                                entry.Unique
                                    and count
                                    or 1
                        end
                    end
                end

                if hasItems then
                    people +=
                        1
                end

                if recipientEntries > 0 then
                    sends +=
                        math.ceil(
                            recipientEntries
                            / BATCH_LIMIT
                        )
                end
            end

            local seconds =
                sends <= 1
                    and 0
                    or (
                        sends - 1
                    ) * COOLDOWN

            itemSummaryText.Text =
                string.format(
                    "People: %d\nItems: %d\nSends: %d\nKnown sendable: %d\nTime: %s",
                    people,
                    items,
                    sends,
                    sendable,
                    seconds <= 0
                            and "Immediate"
                        or "about "
                            .. tostring(
                                math.ceil(
                                    seconds
                                )
                            )
                            .. "s"
                )

            if not selectedExactRecipient() then
                itemMessageText.Text =
                    "Choose a recipient before adding items."
            elseif items <= 0 then
                itemMessageText.Text =
                    "Choose an owned item and enter an amount."
            elseif items ~= sendable then
                itemMessageText.Text =
                    "Some selected items still need a confirmed mail category."
            else
                itemMessageText.Text =
                    tostring(
                        items
                    )
                    .. " items are ready for review."
            end

            local exactSession =
                state.ExactSession

            local exactStatus =
                type(exactSession) == "table"
                and tostring(
                    exactSession.Status
                    or ""
                )
                or ""

            local reviewingUncertain =
                exactStatus == "Uncertain"

            local resumingDelivery =
                exactStatus == "Paused"

            itemSendButton.Active =
                state.Running
                or reviewingUncertain
                or resumingDelivery
                or (
                    sendable > 0
                    and items == sendable
                )

            itemSendButton.AutoButtonColor =
                itemSendButton.Active

            itemSendButton.BackgroundColor3 =
                itemSendButton.Active
                    and color.Accent
                    or color.Hover

            itemSendButton.Text =
                state.Running
                        and "Stop after current mail"
                    or reviewingUncertain
                            and "Review uncertain mail"
                        or resumingDelivery
                                and "Resume remaining delivery"
                            or "Review and send"

            return people,
                items,
                sends,
                sendable
        end

    renderExactItems =
        function()
            clearRows(
                itemBrowseList,
                itemBrowseLayout
            )

            if state.ExactView == "Selected" then
                itemBrowseTitle.Text =
                    "SELECTED ITEMS"

                itemQueueButton.Text =
                    "Show owned"

                local rows = {}

                for _, recipient in ipairs(
                    state.ExactRecipients
                ) do
                    for recordKey, entry in pairs(
                        exactQueueFor(
                            recipient.UserId
                        )
                    ) do
                        if (
                            tonumber(
                                entry.Count
                            )
                            or 0
                        ) > 0 then
                            table.insert(
                                rows,
                                {
                                    Recipient =
                                        recipient,

                                    RecordKey =
                                        recordKey,

                                    Entry =
                                        entry,
                                }
                            )
                        end
                    end
                end

                table.sort(
                    rows,
                    function(left, right)
                        if left.Recipient.Name
                            ~= right.Recipient.Name
                        then
                            return left.Recipient.Name:lower()
                                < right.Recipient.Name:lower()
                        end

                        return left.Entry.Name:lower()
                            < right.Entry.Name:lower()
                    end
                )

                itemBrowseCount.Text =
                    tostring(
                        #rows
                    )
                    .. (
                        #rows == 1
                            and " selection"
                            or " selections"
                    )

                if #rows == 0 then
                    local empty =
                        create(
                            "Frame",
                            {
                                BackgroundColor3 =
                                    color.Field,

                                Size =
                                    UDim2.new(
                                        1,
                                        -2,
                                        0,
                                        70
                                    ),
                            },
                            itemBrowseList
                        )

                    round(
                        empty,
                        10
                    )

                    text(
                        empty,
                        "Nothing selected yet",
                        UDim2.new(
                            1,
                            -24,
                            0,
                            22
                        ),
                        UDim2.fromOffset(
                            12,
                            12
                        ),
                        11,
                        color.Text,
                        nil,
                        Enum.Font.GothamSemibold
                    )

                    text(
                        empty,
                        "Switch back to owned items and add something.",
                        UDim2.new(
                            1,
                            -24,
                            0,
                            18
                        ),
                        UDim2.fromOffset(
                            12,
                            38
                        ),
                        9,
                        color.Muted
                    )

                    return
                end

                for index, rowData in ipairs(
                    rows
                ) do
                    local entry =
                        rowData.Entry

                    local row =
                        create(
                            "Frame",
                            {
                                BackgroundColor3 =
                                    color.Field,

                                Size =
                                    UDim2.new(
                                        1,
                                        -2,
                                        0,
                                        58
                                    ),

                                LayoutOrder =
                                    index,
                            },
                            itemBrowseList
                        )

                    round(
                        row,
                        10
                    )

                    local selectedIcon =
                        create(
                            "Frame",
                            {
                                BackgroundColor3 =
                                    color.Hover,

                                Size =
                                    UDim2.fromOffset(
                                        38,
                                        38
                                    ),

                                Position =
                                    UDim2.fromOffset(
                                        9,
                                        10
                                    ),
                            },
                            row
                        )

                    round(
                        selectedIcon,
                        10
                    )

                    local selectedIconImage =
                        create(
                            "ImageLabel",
                            {
                                BackgroundTransparency =
                                    1,

                                Image =
                                    tostring(
                                        entry.Icon
                                        or ""
                                    ),

                                Size =
                                    UDim2.new(
                                        1,
                                        -6,
                                        1,
                                        -6
                                    ),

                                Position =
                                    UDim2.fromOffset(
                                        3,
                                        3
                                    ),

                                ScaleType =
                                    Enum.ScaleType.Fit,
                            },
                            selectedIcon
                        )

                    round(
                        selectedIconImage,
                        8
                    )

                    text(
                        row,
                        entry.Name,
                        UDim2.new(
                            1,
                            -214,
                            0,
                            20
                        ),
                        UDim2.fromOffset(
                            56,
                            8
                        ),
                        10,
                        color.Text,
                        nil,
                        Enum.Font.GothamSemibold
                    )

                    text(
                        row,
                        "@"
                            .. rowData.Recipient.Name
                            .. " · "
                            .. entry.Details
                            .. " · x"
                            .. tostring(
                                entry.Count
                            ),
                        UDim2.new(
                            1,
                            -214,
                            0,
                            18
                        ),
                        UDim2.fromOffset(
                            56,
                            31
                        ),
                        9,
                        entry.Supported
                                and color.Muted
                            or color.Red
                    )

                    local removeButton =
                        button(
                            row,
                            "Remove",
                            UDim2.fromOffset(
                                88,
                                34
                            ),
                            UDim2.new(
                                1,
                                -100,
                                0,
                                12
                            ),
                            false
                        )

                    removeButton.TextSize =
                        9

                    removeButton.MouseButton1Click:Connect(function()
                        exactQueueFor(
                            rowData.Recipient.UserId
                        )[
                            rowData.RecordKey
                        ] =
                            nil

                        renderExactRecipients()
                        renderExactItems()
                        updateExactSummary()
                    end)
                end

                return
            end

            itemBrowseTitle.Text =
                "OWNED ITEMS"

            itemQueueButton.Text =
                "Show selected"

            local search =
                tostring(
                    state.ExactSearch
                    or ""
                ):lower()

            local selectedCategories =
                type(
                    state.ExactCategories
                ) == "table"
                    and state.ExactCategories
                    or {}

            local hasSelectedCategory =
                next(
                    selectedCategories
                ) ~= nil

            local visibleRecords = {}

            for _, record in ipairs(
                state.ExactRecords
            ) do
                local matchesCategory =
                    selectedCategories[
                        record.Group
                    ] == true

                local matchesSearch =
                    search == ""
                    or record.Name:lower():find(
                        search,
                        1,
                        true
                    ) ~= nil
                    or tostring(
                        record.Details
                    ):lower():find(
                        search,
                        1,
                        true
                    ) ~= nil

                if matchesCategory
                    and matchesSearch
                then
                    table.insert(
                        visibleRecords,
                        record
                    )
                end
            end

            itemBrowseCount.Text =
                tostring(
                    #visibleRecords
                )
                .. (
                    #visibleRecords == 1
                        and " item type"
                        or " item types"
                )

            if #visibleRecords == 0 then
                local empty =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Field,

                            Size =
                                UDim2.new(
                                    1,
                                    -2,
                                    0,
                                    70
                                ),
                        },
                        itemBrowseList
                    )

                round(
                    empty,
                    10
                )

                text(
                    empty,
                    hasSelectedCategory
                            and "Nothing found"
                        or "Select a category",
                    UDim2.new(
                        1,
                        -24,
                        0,
                        22
                    ),
                    UDim2.fromOffset(
                        12,
                        12
                    ),
                    11,
                    color.Text,
                    nil,
                    Enum.Font.GothamSemibold
                )

                text(
                    empty,
                    hasSelectedCategory
                            and "Try another category, search, or refresh."
                        or "Choose one or more categories above.",
                    UDim2.new(
                        1,
                        -24,
                        0,
                        18
                    ),
                    UDim2.fromOffset(
                        12,
                        38
                    ),
                    9,
                    color.Muted
                )

                return
            end

            for index, record in ipairs(
                visibleRecords
            ) do
                local queued =
                    totalQueuedForKey(
                        record.Key
                    )

                local available =
                    math.max(
                        0,
                        record.Count
                            - queued
                    )

                local row =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Field,

                            Size =
                                UDim2.new(
                                    1,
                                    -2,
                                    0,
                                    58
                                ),

                            LayoutOrder =
                                index,
                        },
                        itemBrowseList
                    )

                round(
                    row,
                    10
                )

                local icon =
                    create(
                        "Frame",
                        {
                            BackgroundColor3 =
                                color.Hover,

                            Size =
                                UDim2.fromOffset(
                                    38,
                                    38
                                ),

                            Position =
                                UDim2.fromOffset(
                                    9,
                                    10
                                ),
                        },
                        row
                    )

                round(
                    icon,
                    10
                )

                local iconImage =
                    create(
                        "ImageLabel",
                        {
                            BackgroundTransparency =
                                1,

                            Image =
                                tostring(
                                    record.Icon
                                    or ""
                                ),

                            Size =
                                UDim2.new(
                                    1,
                                    -6,
                                    1,
                                    -6
                                ),

                            Position =
                                UDim2.fromOffset(
                                    3,
                                    3
                                ),

                            ScaleType =
                                Enum.ScaleType.Fit,
                        },
                        icon
                    )

                round(
                    iconImage,
                    8
                )

                text(
                    row,
                    record.Name,
                    UDim2.new(
                        1,
                        -250,
                        0,
                        20
                    ),
                    UDim2.fromOffset(
                        56,
                        8
                    ),
                    10,
                    color.Text,
                    nil,
                    Enum.Font.GothamSemibold
                )

                local details =
                    record.Details
                    .. " · "
                    .. tostring(
                        available
                    )
                    .. " available"

                if not record.Supported then
                    details =
                        details
                        .. " · not ready"
                elseif queued > 0 then
                    details =
                        details
                        .. " · "
                        .. tostring(
                            queued
                        )
                        .. " selected"
                end

                text(
                    row,
                    details,
                    UDim2.new(
                        1,
                        -250,
                        0,
                        18
                    ),
                    UDim2.fromOffset(
                        56,
                        31
                    ),
                    12,
                    record.Supported
                            and color.Secondary
                        or color.Red
                )

                local amountBox =
                    box(
                        row,
                        "1",
                        UDim2.fromOffset(
                            66,
                            34
                        ),
                        UDim2.new(
                            1,
                            -172,
                            0,
                            12
                        )
                    )

                amountBox.TextXAlignment =
                    Enum.TextXAlignment.Center

                local addItemButton =
                    button(
                        row,
                        record.Supported
                                and "+ Add"
                            or "Not ready",
                        UDim2.fromOffset(
                            88,
                            34
                        ),
                        UDim2.new(
                            1,
                            -100,
                            0,
                            12
                        ),
                        record.Supported
                    )

                addItemButton.TextSize =
                    12

                addItemButton.Active =
                    record.Supported
                    and available > 0

                if not addItemButton.Active then
                    addItemButton.BackgroundColor3 =
                        color.Hover
                end

                addItemButton.MouseButton1Click:Connect(function()
                    if state.Running
                        or not addItemButton.Active
                    then
                        return
                    end

                    local recipient =
                        selectedExactRecipient()

                    if not recipient then
                        itemMessageText.Text =
                            "Choose a recipient first."

                        return
                    end

                    local rawAmount =
                        tostring(
                            amountBox.Text
                        ):lower():gsub(
                            "%s+",
                            ""
                        )

                    local wanted

                    if rawAmount == "all" then
                        wanted =
                            available
                    else
                        wanted =
                            math.floor(
                                tonumber(
                                    rawAmount
                                )
                                or 1
                            )
                    end

                    wanted =
                        math.clamp(
                            wanted,
                            1,
                            available
                        )

                    local queue =
                        exactQueueFor(
                            recipient.UserId
                        )

                    local entry =
                        queue[
                            record.Key
                        ]

                    if not entry then
                        entry = {
                            Key =
                                record.Key,

                            Name =
                                record.Name,

                            Details =
                                record.Details,

                            Icon =
                                record.Icon,

                            Group =
                                record.Group,

                            Category =
                                record.Category,

                            ItemKey =
                                record.ItemKey,

                            Unique =
                                record.Unique,

                            Supported =
                                record.Supported,

                            Count =
                                0,
                        }

                        queue[
                            record.Key
                        ] =
                            entry
                    end

                    entry.Count +=
                        wanted

                    amountBox.Text =
                        ""

                    renderExactRecipients()
                    renderExactItems()
                    updateExactSummary()
                end)
            end
        end

    refreshExactItems =
        function()
            local records =
                scanExactItems()

            local total = 0
            local protectedCount = 0

            for _, record in ipairs(
                records
            ) do
                total +=
                    record.Count
            end

            if state.ExactProtect then
                protectedCount =
                    1
            end

            itemInventoryCount.Text =
                tostring(
                    total
                )
                .. " owned"
                .. (
                    protectedCount > 0
                        and " · favorites skipped"
                        or ""
                )

            renderExactItems()
            renderExactRecipients()
            updateExactSummary()
        end

    local function addExactRecipient()
        if state.RecipientChangesLocked() then
            return
        end

        local raw =
            tostring(
                itemRecipientBox.Text
            )
                :gsub(
                    "^%s+",
                    ""
                )
                :gsub(
                    "%s+$",
                    ""
                )

        if raw == "" then
            itemRecipientBox.PlaceholderText =
                "Enter a recipient"

            return
        end

        itemRecipientAdd.Text =
            "Checking..."

        local userId
        local username
        local numeric =
            tonumber(
                raw
            )

        if numeric then
            local ok,
                result =
                pcall(
                    Players.GetNameFromUserIdAsync,
                    Players,
                    math.floor(
                        numeric
                    )
                )

            if ok then
                userId =
                    math.floor(
                        numeric
                    )

                username =
                    result
            end
        else
            local ok,
                result =
                pcall(
                    Players.GetUserIdFromNameAsync,
                    Players,
                    raw
                )

            if ok then
                userId =
                    result

                local nameOk,
                    name =
                    pcall(
                        Players.GetNameFromUserIdAsync,
                        Players,
                        userId
                    )

                username =
                    nameOk
                        and name
                        or raw
            end
        end

        if not userId
            or not username
            or userId == player.UserId
        then
            itemRecipientBox.Text =
                ""

            itemRecipientBox.PlaceholderText =
                "Recipient not found"

            itemRecipientAdd.Text =
                "+ Add"

            return
        end

        for _, recipient in ipairs(
            state.ExactRecipients
        ) do
            if recipient.UserId
                == userId
            then
                state.ExactSelectedUserId =
                    userId

                GAG2PremiumTouchRecipient(
                    userId,
                    username
                )

                itemRecipientBox.Text =
                    ""

                itemRecipientAdd.Text =
                    "+ Add"

                renderExactRecipients()
                renderExactItems()
                updateExactSummary()

                return
            end
        end

        table.insert(
            state.ExactRecipients,
            {
                UserId =
                    userId,

                Name =
                    username,
            }
        )

        state.ExactSelectedUserId =
            userId

        GAG2PremiumTouchRecipient(
            userId,
            username
        )

        itemRecipientBox.Text =
            ""

        itemRecipientBox.PlaceholderText =
            "Username or User ID"

        itemRecipientAdd.Text =
            "+ Add"

        renderExactRecipients()
        renderExactItems()
        updateExactSummary()
    end

    state.ExactClearButton.MouseButton1Click:Connect(function()
        if state.RecipientChangesLocked()
            or #state.ExactRecipients == 0
        then
            return
        end

        showModal(
            "Clear everyone?",
            "This removes every Pick Items recipient and every item selected for them. Your inventory will not be changed.",
            "Clear all",
            function()
                if state.RecipientChangesLocked() then
                    return
                end

                state.ExactRecipients = {}

                state.ExactQueues = {}

                state.ExactSelectedUserId =
                    nil

                itemRecipientBox.Text =
                    ""

                itemRecipientBox.PlaceholderText =
                    "Username or User ID"

                itemRecipientAdd.Text =
                    "+ Add"

                renderExactRecipients()
                renderExactItems()
                updateExactSummary()
            end,
            false
        )
    end)

    local function buildExactRoutes()
        scanExactItems()

        local usedUnique = {}
        local usedStacked = {}
        local routes = {}
        local totalItems = 0
        local totalMails = 0
        local missing = 0

        for _, recipient in ipairs(
            state.ExactRecipients
        ) do
            local payloads = {}
            local payloadHistoryKeys = {}

            local historyItems = {}
            local historyItemMap = {}

            local function addHistoryItem(
                recordKey,
                record,
                count
            )
                count =
                    math.max(
                        0,
                        math.floor(
                            tonumber(count)
                                or 0
                        )
                    )

                if count <= 0 then
                    return
                end

                local key =
                    tostring(recordKey)

                local historyItem =
                    historyItemMap[key]

                if not historyItem then
                    historyItem = {
                        Key = key,

                        Name =
                            tostring(
                                record.Name
                                    or "Unknown item"
                            ),

                        Details =
                            tostring(
                                record.Details
                                    or record.Group
                                    or "Item"
                            ),

                        Icon =
                            tostring(
                                record.Icon
                                    or ""
                            ),

                        Count = 0,
                        Sent = 0,
                        Value = 0,
                    }

                    historyItemMap[key] =
                        historyItem

                    table.insert(
                        historyItems,
                        historyItem
                    )
                end

                historyItem.Count +=
                    count
            end

            local recipientItems = 0
            local queue =
                exactQueueFor(
                    recipient.UserId
                )

            for recordKey, queued in pairs(
                queue
            ) do
                local wanted =
                    math.max(
                        0,
                        math.floor(
                            tonumber(
                                queued.Count
                            )
                            or 0
                        )
                    )

                if wanted > 0 then
                    local record =
                        state.ExactRecordMap[
                            recordKey
                        ]

                    if not record
                        or not record.Supported
                        or not record.Category
                    then
                        missing +=
                            wanted
                    elseif record.Unique then
                        local added = 0

                        for _, source in ipairs(
                            record.Sources
                        ) do
                            if added >= wanted then
                                break
                            end

                            if not usedUnique[
                                source.ItemKey
                            ] then
                                usedUnique[
                                    source.ItemKey
                                ] =
                                    true

                                table.insert(
                                    payloads,
                                    {
                                        ItemKey =
                                            source.ItemKey,

                                        Count =
                                            1,

                                        Category =
                                            record.Category,
                                    }
                                )

                                payloadHistoryKeys[
                                    #payloads
                                ] =
                                    tostring(
                                        recordKey
                                    )

                                addHistoryItem(
                                    recordKey,
                                    record,
                                    1
                                )

                                added +=
                                    1
                            end
                        end

                        recipientItems +=
                            added

                        totalItems +=
                            added

                        if added < wanted then
                            missing +=
                                wanted - added
                        end
                    else
                        local alreadyUsed =
                            usedStacked[
                                recordKey
                            ]
                            or 0

                        local available =
                            math.max(
                                0,
                                record.Count
                                    - alreadyUsed
                            )

                        local added =
                            math.min(
                                wanted,
                                available
                            )

                        if added > 0 then
                            usedStacked[
                                recordKey
                            ] =
                                alreadyUsed
                                + added

                            table.insert(
                                payloads,
                                {
                                    ItemKey =
                                        record.ItemKey,

                                    Count =
                                        added,

                                    Category =
                                        record.Category,
                                }
                            )

                            payloadHistoryKeys[
                                #payloads
                            ] =
                                tostring(
                                    recordKey
                                )

                            addHistoryItem(
                                recordKey,
                                record,
                                added
                            )

                            recipientItems +=
                                added

                            totalItems +=
                                added
                        end

                        if added < wanted then
                            missing +=
                                wanted - added
                        end
                    end
                end
            end

            if #payloads > 0 then
                local mails =
                    math.ceil(
                        #payloads
                        / BATCH_LIMIT
                    )

                totalMails +=
                    mails

                table.insert(
                    routes,
                    {
                        Recipient =
                            recipient,

                        Payloads =
                            payloads,

                        Items =
                            recipientItems,

                        Mails =
                            mails,

                        HistoryItems =
                            historyItems,

                        PayloadHistoryKeys =
                            payloadHistoryKeys,
                    }
                )
            end
        end

        return routes,
            totalItems,
            totalMails,
            missing
    end

    state.Safety.ExactRequirements =
        function(batchHistory)
            local requirements = {}

            for _, entry in ipairs(
                batchHistory
            ) do
                local key =
                    tostring(
                        entry.Key
                        or ""
                    )

                if key ~= "" then
                    requirements[key] =
                        (
                            requirements[key]
                            or 0
                        )
                        + math.max(
                            0,
                            math.floor(
                                tonumber(
                                    entry.Count
                                )
                                or 0
                            )
                        )
                end
            end

            return requirements
        end

    state.Safety.ValidateExactBatch =
        function(batchHistory)
            GAG2PremiumCheckDay()
            updateQuota()

            if tracker.Used >= DAILY_LIMIT then
                return false,
                    "No daily sends remain.",
                    "DAILY"
            end

            scanExactItems()

            local requirements =
                state.Safety.ExactRequirements(
                    batchHistory
                )

            local snapshot = {}

            for recordKey, required in pairs(
                requirements
            ) do
                local record =
                    state.ExactRecordMap[
                        recordKey
                    ]

                local available =
                    record
                    and tonumber(
                        record.Count
                    )
                    or 0

                snapshot[recordKey] =
                    available

                if not record
                    or not record.Supported
                    or not record.Category
                    or available < required
                then
                    return false,
                        "Selected items changed, disappeared, or became protected.",
                        "INVENTORY"
                end
            end

            return true,
                snapshot,
                "READY"
        end

    state.Safety.WaitForExactRemoval =
        function(
            batchHistory,
            beforeSnapshot,
            timeout
        )
            local requirements =
                state.Safety.ExactRequirements(
                    batchHistory
                )

            local deadline =
                os.clock()
                + (
                    tonumber(timeout)
                    or 8
                )

            repeat
                scanExactItems()

                local complete =
                    true

                for recordKey, required in pairs(
                    requirements
                ) do
                    local record =
                        state.ExactRecordMap[
                            recordKey
                        ]

                    local current =
                        record
                        and tonumber(
                            record.Count
                        )
                        or 0

                    local before =
                        tonumber(
                            beforeSnapshot[
                                recordKey
                            ]
                        )
                        or 0

                    if current
                        > math.max(
                            0,
                            before - required
                        )
                    then
                        complete =
                            false

                        break
                    end
                end

                if complete then
                    return true
                end

                task.wait(
                    0.15
                )
            until os.clock() >= deadline

            return false
        end

    state.Safety.ConsumeExactQueue =
        function(
            recipientUserId,
            batchHistory
        )
            local queue =
                exactQueueFor(
                    recipientUserId
                )

            for recordKey, amount in pairs(
                state.Safety.ExactRequirements(
                    batchHistory
                )
            ) do
                local queued =
                    queue[
                        recordKey
                    ]

                if type(queued) == "table" then
                    queued.Count =
                        math.max(
                            0,
                            (
                                tonumber(
                                    queued.Count
                                )
                                or 0
                            )
                            - amount
                        )

                    if queued.Count <= 0 then
                        queue[
                            recordKey
                        ] =
                            nil
                    end
                end
            end
        end

    state.Safety.SendExactPayload =
        function(
            packet,
            recipient,
            payload,
            batchHistory
        )
            while not state.Stop do
                local valid,
                    snapshot,
                    validationType =
                    state.Safety.ValidateExactBatch(
                        batchHistory
                    )

                if not valid then
                    return false,
                        tostring(
                            snapshot
                        ),
                        validationType,
                        false
                end

                if not state.Safety.WaitForCooldown() then
                    return false,
                        "Stopped",
                        "STOPPED",
                        false
                end

                valid,
                snapshot,
                validationType =
                    state.Safety.ValidateExactBatch(
                        batchHistory
                    )

                if not valid then
                    return false,
                        tostring(
                            snapshot
                        ),
                        validationType,
                        false
                end

                local started =
                    workspace:GetServerTimeNow()

                setStatus(
                    "Sending",
                    color.Yellow
                )

                local ok,
                    first,
                    second =
                    pcall(function()
                        return packet:Fire(
                            recipient.UserId,
                            payload,
                            ""
                        )
                    end)

                if not ok then
                    return false,
                        tostring(
                            first
                        ),
                        "ERROR",
                        false
                end

                local message =
                    tostring(
                        second or ""
                    )

                if first == true then
                    state.Safety.RecordAcceptedMail(
                        started
                    )

                    state.Safety.ConsumeExactQueue(
                        recipient.UserId,
                        batchHistory
                    )

                    local confirmed =
                        state.Safety.WaitForExactRemoval(
                            batchHistory,
                            snapshot,
                            8
                        )

                    if not confirmed then
                        return false,
                            "The server accepted this mail, but inventory removal could not be confirmed.",
                            "UNCERTAIN",
                            true
                    end

                    return true,
                        message,
                        "CONFIRMED",
                        true
                end

                local lower =
                    message:lower()

                local seconds =
                    tonumber(
                        lower:match(
                            "wait%s+(%d+)%s*s"
                        )
                    )

                if seconds then
                    task.wait(
                        seconds + 0.25
                    )
                elseif lower:find(
                    "daily gift limit",
                    1,
                    true
                ) then
                    tracker.Used =
                        DAILY_LIMIT

                    SOPHIA_MAIL_STATE.TrackerDay =
                        GAG2PremiumToday()

                    SOPHIA_MAIL_STATE.TrackerUsed =
                        DAILY_LIMIT

                    updateQuota()
                    GAG2PremiumSaveSettings()

                    return false,
                        message,
                        "DAILY",
                        false
                else
                    return false,
                        message ~= ""
                                and message
                            or tostring(
                                first
                            ),
                        "REJECTED",
                        false
                end
            end

            return false,
                "Stopped",
                "STOPPED",
                false
        end

    state.Safety.RunExactDelivery =
        function(
            routes,
            totalItems,
            totalMails
        )
            protectedCall(
                "Item delivery",
                function()
                    local packet,
                        packetError =
                        getSendPacket()

                    if not packet then
                        itemMessageText.Text =
                            tostring(
                                packetError
                            )

                        if type(
                            state.ExactSession
                        ) == "table" then
                            state.ExactSession.Status =
                                "Paused"
                        end

                        return
                    end

                    local session =
                        state.ExactSession

                    if type(session) ~= "table" then
                        return
                    end

                    session.Status =
                        "Running"

                    state.Running =
                        true

                    state.Stop =
                        false

                    itemProgressFill.Size =
                        UDim2.fromScale(
                            0,
                            1
                        )

                    local completedMails = 0
                    local completedItems = 0
                    local completedPeople = 0
                    local failure
                    local failureType

                    renderExactRecipients()
                    updateExactSummary()

                    for _, route in ipairs(
                        routes
                    ) do
                        local recipientComplete =
                            true

                        local historyRecord = {
                            Direction = "Sent",
                            Mode = "Pick Items",
                            Status = "Failed",

                            OtherUserId =
                                route.Recipient.UserId,

                            OtherName =
                                route.Recipient.Name,

                            AttemptedMails =
                                route.Mails,

                            AcceptedMails = 0,

                            PlannedItems =
                                route.Items,

                            SentItems = 0,

                            TargetValue = 0,
                            AcceptedValue = 0,

                            Items = {},
                        }

                        local historyItemMap = {}

                        for _, historyItem in ipairs(
                            route.HistoryItems
                            or {}
                        ) do
                            local copy = {
                                Key =
                                    tostring(
                                        historyItem.Key
                                        or ""
                                    ),

                                Name =
                                    tostring(
                                        historyItem.Name
                                        or "Unknown item"
                                    ),

                                Details =
                                    tostring(
                                        historyItem.Details
                                        or "Item"
                                    ),

                                Icon =
                                    tostring(
                                        historyItem.Icon
                                        or ""
                                    ),

                                Count =
                                    tonumber(
                                        historyItem.Count
                                    )
                                    or 0,

                                Sent = 0,
                                Value = 0,
                            }

                            table.insert(
                                historyRecord.Items,
                                copy
                            )

                            historyItemMap[
                                copy.Key
                            ] =
                                copy
                        end

                        for firstIndex = 1,
                            #route.Payloads,
                            BATCH_LIMIT
                        do
                            if state.Stop then
                                recipientComplete =
                                    false

                                break
                            end

                            local payload = {}
                            local batchHistory = {}
                            local batchItems = 0

                            for payloadIndex = firstIndex,
                                math.min(
                                    firstIndex
                                        + BATCH_LIMIT
                                        - 1,
                                    #route.Payloads
                                )
                            do
                                local entry =
                                    route.Payloads[
                                        payloadIndex
                                    ]

                                table.insert(
                                    payload,
                                    entry
                                )

                                local historyEntry = {
                                    Key =
                                        tostring(
                                            route.PayloadHistoryKeys[
                                                payloadIndex
                                            ]
                                            or ""
                                        ),

                                    Count =
                                        tonumber(
                                            entry.Count
                                        )
                                        or 1,
                                }

                                table.insert(
                                    batchHistory,
                                    historyEntry
                                )

                                batchItems +=
                                    historyEntry.Count
                            end

                            itemSendButton.Text =
                                string.format(
                                    "@%s · %d/%d",
                                    route.Recipient.Name,
                                    completedMails + 1,
                                    totalMails
                                )

                            local confirmed,
                                response,
                                responseType,
                                acceptedByServer =
                                state.Safety.SendExactPayload(
                                    packet,
                                    route.Recipient,
                                    payload,
                                    batchHistory
                                )

                            if acceptedByServer then
                                completedMails +=
                                    1

                                completedItems +=
                                    batchItems

                                session.AcceptedMails =
                                    (
                                        tonumber(
                                            session.AcceptedMails
                                        )
                                        or 0
                                    )
                                    + 1

                                session.AcceptedItems =
                                    (
                                        tonumber(
                                            session.AcceptedItems
                                        )
                                        or 0
                                    )
                                    + batchItems

                                historyRecord.AcceptedMails +=
                                    1

                                historyRecord.SentItems +=
                                    batchItems

                                for _, acceptedItem in ipairs(
                                    batchHistory
                                ) do
                                    local historyItem =
                                        historyItemMap[
                                            acceptedItem.Key
                                        ]

                                    if historyItem then
                                        historyItem.Sent +=
                                            acceptedItem.Count
                                    end
                                end

                                itemProgressFill.Size =
                                    UDim2.fromScale(
                                        completedMails
                                            / math.max(
                                                totalMails,
                                                1
                                            ),
                                        1
                                    )

                                itemMessageText.Text =
                                    string.format(
                                        "Accepted %d of %d items.",
                                        completedItems,
                                        totalItems
                                    )
                            end

                            if not confirmed then
                                recipientComplete =
                                    false

                                failure =
                                    tostring(
                                        response
                                        or "Delivery paused"
                                    )

                                failureType =
                                    tostring(
                                        responseType
                                        or "PAUSED"
                                    )

                                if failureType
                                    == "UNCERTAIN"
                                then
                                    session.UncertainBatch = {
                                        Recipient =
                                            route.Recipient,

                                        Payload =
                                            payload,

                                        History =
                                            batchHistory,

                                        Accepted =
                                            acceptedByServer == true,
                                    }
                                end

                                break
                            end
                        end

                        if failureType == "UNCERTAIN" then
                            historyRecord.Status =
                                "Uncertain"
                        elseif recipientComplete then
                            historyRecord.Status =
                                "Sent"
                        elseif historyRecord.AcceptedMails > 0
                            or state.Stop
                        then
                            historyRecord.Status =
                                "Partial"
                        else
                            historyRecord.Status =
                                "Failed"
                        end

                        historyRecord.Error =
                            failure
                            or (
                                state.Stop
                                and "Stopped by user"
                                or ""
                            )

                        GAG2PremiumHistoryAdd(
                            historyRecord
                        )

                        if recipientComplete then
                            completedPeople +=
                                1
                        else
                            break
                        end
                    end

                    local stopped =
                        state.Stop
                        and not failure

                    local complete =
                        completedMails == totalMails
                        and not failure
                        and not stopped

                    if complete then
                        session.Status =
                            "Complete"

                        state.ExactSession =
                            nil
                    elseif failureType == "UNCERTAIN" then
                        session.Status =
                            "Uncertain"
                    else
                        session.Status =
                            "Paused"
                    end

                    state.Running =
                        false

                    state.Stop =
                        false

                    setStatus(
                        complete
                                and "Complete"
                            or failureType == "UNCERTAIN"
                                    and "Confirmation uncertain"
                                or "Paused",
                        complete
                                and color.Green
                            or failureType == "UNCERTAIN"
                                    and color.Red
                                or color.Yellow
                    )

                    showModal(
                        complete
                                and "Delivery complete"
                            or failureType == "UNCERTAIN"
                                    and "Confirmation uncertain"
                                or failureType == "DAILY"
                                        and "Daily limit reached"
                                    or "Delivery paused",
                        (
                            failure
                            and failure
                                .. "\n\n"
                            or ""
                        )
                        .. string.format(
                            "People completed: %d\nItems accepted: %d\nSends accepted: %d",
                            completedPeople,
                            completedItems,
                            completedMails
                        ),
                        nil,
                        nil,
                        not complete
                    )

                    task.wait(
                        0.35
                    )

                    refreshExactItems()

                    if type(
                        state.ExactSession
                    ) == "table" then
                        if state.ExactSession.Status
                            == "Uncertain"
                        then
                            itemSendButton.Text =
                                "Review uncertain mail"

                            itemSendButton.Active =
                                true

                            itemSendButton.BackgroundColor3 =
                                color.Accent
                        elseif state.ExactSession.Status
                            == "Paused"
                        then
                            itemSendButton.Text =
                                "Resume remaining delivery"
                        end
                    else
                        itemSendButton.Text =
                            "Review and send"
                    end
                end
            )
        end

    state.Safety.RequestExactDelivery =
        function()
            if state.Running then
                state.Stop =
                    true

                itemSendButton.Text =
                    "Stopping after current mail..."

                return
            end

            local session =
                state.ExactSession

            if type(session) == "table"
                and session.Status == "Uncertain"
            then
                showModal(
                    "Confirmation uncertain",
                    "The server accepted the previous mail, but SOPHIA could not confirm that its items disappeared.\n\nThat batch was removed from the queue and will never be resent automatically.",
                    "Continue safely",
                    function()
                        session.Status =
                            "Paused"

                        session.UncertainBatch =
                            nil

                        refreshExactItems()

                        itemSendButton.Text =
                            "Resume remaining delivery"
                    end,
                    true
                )

                return
            end

            local resuming =
                type(session) == "table"
                and session.Status == "Paused"

            local routes,
                totalItems,
                totalMails,
                missing =
                buildExactRoutes()

            if missing > 0 then
                itemMessageText.Text =
                    tostring(
                        missing
                    )
                    .. " remaining items are unavailable, protected, or still need a mail test."

                refreshExactItems()

                return
            end

            if #routes == 0
                or totalItems <= 0
                or totalMails <= 0
            then
                if resuming then
                    state.ExactSession =
                        nil

                    itemMessageText.Text =
                        "The remaining delivery is complete."

                    itemMessageText.TextColor3 =
                        color.Green

                    itemSendButton.Text =
                        "Review and send"

                    refreshExactItems()
                else
                    itemMessageText.Text =
                        "Select at least one supported item."
                end

                return
            end

            local remaining =
                DAILY_LIMIT
                - tracker.Used

            if totalMails > remaining then
                itemMessageText.Text =
                    "This needs "
                    .. tostring(
                        totalMails
                    )
                    .. " sends, but only "
                    .. tostring(
                        remaining
                    )
                    .. " remain today."

                return
            end

            local seconds =
                totalMails <= 1
                and 0
                or (
                    totalMails - 1
                ) * COOLDOWN

            showModal(
                resuming
                        and "Resume remaining delivery"
                    or "Review before sending",
                string.format(
                    "People: %d\nItems remaining: %d\nSends remaining: %d\nTime: about %ds",
                    #routes,
                    totalItems,
                    totalMails,
                    math.ceil(
                        seconds
                    )
                ),
                resuming
                        and "Resume"
                    or "Send now",
                function()
                    if not resuming then
                        state.ExactSession = {
                            Status = "Ready",
                            AcceptedMails = 0,
                            AcceptedItems = 0,
                            UncertainBatch = nil,
                        }
                    end

                    task.spawn(
                        state.Safety.RunExactDelivery,
                        routes,
                        totalItems,
                        totalMails
                    )
                end,
                true
            )
        end

    local function applyMailMode(
        selectedMode
    )
        if state.Running then
            return
        end

        state.MailMode =
            selectedMode == "Items"
                and "Items"
                or "Value"

        local itemMode =
            state.MailMode == "Items"

        itemPanel.Visible =
            itemMode

        setSelectedButton(
            valueModeButton,
            not itemMode
        )

        setSelectedButton(
            itemModeButton,
            itemMode
        )

        if state.ActiveTab == "Send" then
            subtitle.Text =
                itemMode
                    and "Pick exact items"
                    or "Send fruits by value"
        end

        if itemMode then
            state.ExactView =
                "Owned"

            refreshExactItems()
        else
            task.spawn(function()
                protectedCall(
                    "Value mode refresh",
                    rebuildPlan
                )
            end)
        end
    end

    state.ApplyMailMode =
        applyMailMode

    state.Fleet.LoadIntoItems =
        function()
            if state.RecipientChangesLocked() then
                state.Fleet.StatusLabel.Text =
                    "Finish or safely end the current delivery first."

                state.Fleet.StatusLabel.TextColor3 =
                    color.Yellow

                return
            end

            local accounts =
                state.Fleet.EnabledAccounts()

            if #accounts == 0 then
                state.Fleet.StatusLabel.Text =
                    "This group has no enabled accounts."

                state.Fleet.StatusLabel.TextColor3 =
                    color.Red

                return
            end

            local snapshots = {}

            for _, account in ipairs(
                accounts
            ) do
                table.insert(
                    snapshots,
                    {
                        UserId =
                            account.UserId,

                        Name =
                            account.Name,
                    }
                )
            end

            state.ExactRecipients =
                snapshots

            state.ExactQueues =
                {}

            state.ExactSelectedUserId =
                snapshots[1]
                and snapshots[1].UserId
                or nil

            state.Fleet.LoadedGroup =
                state.Fleet.ActiveGroup

            itemRecipientBox.Text =
                ""

            itemRecipientBox.PlaceholderText =
                "Username or User ID"

            itemRecipientAdd.Text =
                "+ Add"

            applyMailMode(
                "Items"
            )

            if type(
                state.ShowMainPage
            ) == "function" then
                state.ShowMainPage(
                    "Send"
                )
            end

            itemMessageText.Text =
                tostring(
                    #snapshots
                )
                .. " Fleet accounts loaded. Choose items for each recipient."

            itemMessageText.TextColor3 =
                color.Secondary

            refreshExactItems()
        end

    valueModeButton.MouseButton1Click:Connect(function()
        applyMailMode(
            "Value"
        )
    end)

    itemModeButton.MouseButton1Click:Connect(function()
        applyMailMode(
            "Items"
        )
    end)

    itemRecipientAdd.MouseButton1Click:Connect(function()
        protectedCall(
            "Add item recipient",
            addExactRecipient
        )
    end)

    itemRecipientBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            protectedCall(
                "Add item recipient",
                addExactRecipient
            )
        end
    end)

    for categoryName, categoryButton in pairs(
        itemCategoryButtons
    ) do
        categoryButton.MouseButton1Click:Connect(function()
            if state.Running then
                return
            end

            state.ExactCategories =
                type(
                    state.ExactCategories
                ) == "table"
                    and state.ExactCategories
                    or {}

            if state.ExactCategories[
                categoryName
            ] == true then
                state.ExactCategories[
                    categoryName
                ] =
                    nil
            else
                state.ExactCategories[
                    categoryName
                ] =
                    true
            end

            state.ExactView =
                "Owned"

            for otherName, otherButton in pairs(
                itemCategoryButtons
            ) do
                setSelectedButton(
                    otherButton,
                    state.ExactCategories[
                        otherName
                    ] == true
                )
            end

            renderExactItems()
        end)
    end

    itemSearchBox:GetPropertyChangedSignal(
        "Text"
    ):Connect(function()
        state.ExactSearch =
            itemSearchBox.Text

        if state.ExactView == "Owned" then
            renderExactItems()
        end
    end)

    itemRefreshButton.MouseButton1Click:Connect(function()
        protectedCall(
            "Refresh owned items",
            refreshExactItems
        )
    end)

    itemProtectButton.MouseButton1Click:Connect(function()
        if state.Running then
            return
        end

        state.ExactProtect =
            not state.ExactProtect

        itemProtectButton.Text =
            "Skip favorites: "
            .. (
                state.ExactProtect
                    and "ON"
                    or "OFF"
            )

        refreshExactItems()
    end)

    itemQueueButton.MouseButton1Click:Connect(function()
        state.ExactView =
            state.ExactView == "Owned"
                and "Selected"
                or "Owned"

        renderExactItems()
    end)

    itemSendButton.MouseButton1Click:Connect(function()
        protectedCall(
            "Exact item send",
            state.Safety.RequestExactDelivery
        )
    end)

    applyMailMode(
        "Value"
    )

    showMainPage(
        state.ActiveTab
    )

    updateQuota()
    renderRecipients()

    setStatus(
        "Ready",
        color.Green
    )

    messageText.Text =
        "HUD loaded. Add a recipient or refresh the preview."

    print(
        "[GAG 2 Premiumer] V7 HUD loaded successfully"
    )

    if state.Minimized == true then
        applyMinimized()
    end

    task.spawn(function()
        protectedCall(
            "Initial inventory scan",
            rebuildPlan
        )
    end)

    return true
end

function GAG2PremiumDestroyHud(reason)
    local deliveryState =
        SOPHIA_MAIL_RUNTIME.DeliveryState

    if type(deliveryState) == "table"
        and deliveryState.Running == true
    then
        deliveryState.Stop =
            true

        if SOPHIA_MAIL_RUNTIME.DestroyPending ~= true then
            SOPHIA_MAIL_RUNTIME.DestroyPending =
                true

            task.spawn(function()
                local deadline =
                    os.clock() + 15

                while type(SOPHIA_MAIL_RUNTIME.DeliveryState) == "table"
                    and SOPHIA_MAIL_RUNTIME.DeliveryState.Running == true
                    and os.clock() < deadline
                do
                    task.wait(0.1)
                end

                SOPHIA_MAIL_RUNTIME.DestroyPending =
                    false

                GAG2PremiumDestroyHud(reason)
            end)
        end

        return false
    end

    local gui =
        SOPHIA_MAIL_RUNTIME.Gui

    if typeof(gui) == "Instance" then
        pcall(function()
            gui:Destroy()
        end)
    end

    SOPHIA_MAIL_RUNTIME.Gui =
        nil

    SOPHIA_MAIL_RUNTIME.Window =
        nil

    SOPHIA_MAIL_RUNTIME.DeliveryState =
        nil

    SOPHIA_MAIL_RUNTIME.SetMinimized =
        nil

    SOPHIA_MAIL_RUNTIME.ApplyScale =
        nil

    SOPHIA_MAIL_RUNTIME.UpdateQuota =
        nil

    SOPHIA_MAIL_RUNTIME.Status =
        "Closed"

    GAG2PremiumRefreshControlUI()

    return true
end

function GAG2PremiumSyncToggle(value)
    local toggle =
        type(Toggles) == "table"
        and Toggles.GAG2PremiumHud
        or nil

    if type(toggle) ~= "table"
        or type(toggle.SetValue) ~= "function"
        or toggle.Value == (value == true)
    then
        return false
    end

    SOPHIA_MAIL_RUNTIME.SyncingToggle =
        true

    pcall(function()
        toggle:SetValue(
            value == true
        )
    end)

    SOPHIA_MAIL_RUNTIME.SyncingToggle =
        false

    return true
end

function GAG2PremiumSetEnabled(
    value,
    fromToggle
)
    local enabled =
        value == true

    SOPHIA_MAIL_STATE.HudEnabled =
        enabled

    if enabled == true then
        local ok, result =
            xpcall(
                GAG2PremiumCreateHud,
                function(message)
                    return tostring(message)
                        .. "\n"
                        .. debug.traceback()
                end
            )

        if ok ~= true
            or result ~= true
        then
            SOPHIA_MAIL_STATE.HudEnabled =
                false

            SOPHIA_MAIL_RUNTIME.Status =
                "Error"

            SOPHIA_MAIL_RUNTIME.LastError =
                tostring(result)

            warn(
                "[GAG 2 Premiumer]",
                tostring(result)
            )

            SophiaNotify(
                "SOPHIA Mail",
                "The Mail HUD could not open. The error was printed to the console.",
                6
            )

            enabled =
                false
        end
    else
        GAG2PremiumDestroyHud("disabled")
    end

    GAG2PremiumSaveSettings()
    GAG2PremiumRefreshControlUI()

    if fromToggle ~= true then
        GAG2PremiumSyncToggle(enabled)
    end

    return enabled
end

function GAG2PremiumOpenHud()
    if SOPHIA_MAIL_STATE.HudEnabled ~= true then
        return GAG2PremiumSetEnabled(true)
    end

    if typeof(SOPHIA_MAIL_RUNTIME.Gui) ~= "Instance" then
        GAG2PremiumCreateHud()
    end

    if type(SOPHIA_MAIL_RUNTIME.SetMinimized) == "function" then
        SOPHIA_MAIL_RUNTIME.SetMinimized(false)
    end

    return true
end

function GAG2PremiumResetPosition()
    SOPHIA_MAIL_STATE.HudPosition =
        nil

    local window =
        SOPHIA_MAIL_RUNTIME.Window

    if typeof(window) == "Instance" then
        window.Position =
            UDim2.fromScale(
                0.5,
                0.5
            )
    end

    GAG2PremiumSaveSettings()

    return true
end

SOPHIA_MAIL_RUNTIME.Stop =
    function(reason)
        GAG2PremiumStopInboxWorker()

        SOPHIA_MAIL_STATE.HudEnabled =
            false

        return GAG2PremiumDestroyHud(
            reason or "stop"
        )
    end

GAG2PremiumShowKeyGate()
