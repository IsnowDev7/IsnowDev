-- CapsuleUI.lua
-- Screenshot-first Roblox UI library.
-- The open state is a transparent full-screen HUD made of separate dark cards,
-- not a centered dashboard window. Cards stay fixed-size and scroll internally.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local CapsuleUI = {}
CapsuleUI.__index = CapsuleUI
CapsuleUI._activeWindow = nil

local DEFAULT_THEME = {
    Card = Color3.fromRGB(29, 30, 32),
    CardAlt = Color3.fromRGB(34, 35, 38),
    Control = Color3.fromRGB(55, 56, 60),
    ControlHover = Color3.fromRGB(63, 64, 68),
    ControlActive = Color3.fromRGB(72, 73, 78),
    Text = Color3.fromRGB(240, 240, 242),
    Muted = Color3.fromRGB(156, 157, 162),
    Faint = Color3.fromRGB(112, 113, 118),
    Backdrop = Color3.fromRGB(18, 20, 23),
    Capsule = Color3.fromRGB(11, 12, 14),
    CapsuleGlow = Color3.fromRGB(116, 119, 128),
    Stroke = Color3.fromRGB(72, 73, 78),
}

-- Embedded fallbacks for common Lucide icons. A custom Lucide ModuleScript/table
-- can be passed in CreateWindow({ Lucide = ... }) for a larger icon set.
local COMMON_LUCIDE = {
    ["house"] = 127889862453151,
    ["image"] = 97933683823480,
    ["bell"] = 111725241873349,
    ["check"] = 83827110621355,
    ["chevron-down"] = 95086910949405,
    ["chevron-left"] = 83856486110301,
    ["chevron-right"] = 126507964682213,
    ["circle-user"] = 73363870264217,
    ["circle-x"] = 136096054247483,
    ["message-square"] = 101115671378532,
    ["monitor"] = 73331152826648,
    ["minus"] = 120931250449806,
}

local SLOT_LAYOUT = {
    LeftTop = {
        Position = UDim2.fromOffset(23, 58),
        Size = UDim2.fromOffset(218, 100),
    },
    LeftBottom = {
        Position = UDim2.fromOffset(23, 166),
        Size = UDim2.fromOffset(218, 78),
    },
    Main = {
        Position = UDim2.fromOffset(250, 58),
        Size = UDim2.fromOffset(210, 184),
    },
    Wide = {
        Position = UDim2.fromOffset(23, 254),
        Size = UDim2.fromOffset(437, 184),
    },
}

local function copyTable(source)
    local result = {}
    for key, value in pairs(source or {}) do
        result[key] = value
    end
    return result
end

local function mergeTheme(overrides)
    local theme = copyTable(DEFAULT_THEME)
    for key, value in pairs(overrides or {}) do
        theme[key] = value
    end
    return theme
end

local function create(className, props)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    return object
end

local function addCorner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent,
    })
end

local function addStroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function addPadding(parent, left, top, right, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function tween(object, duration, goal, style, direction)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.18,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        goal
    )
    animation:Play()
    return animation
end

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not ok then
            warn("[CapsuleUI] Callback error: " .. tostring(err))
        end
    end)
end

local function getGlobal(name)
    local environments = {}

    local okGenv, genv = pcall(function()
        if getgenv then
            return getgenv()
        end
        return nil
    end)

    if okGenv and type(genv) == "table" then
        table.insert(environments, genv)
    end

    if type(_G) == "table" then
        table.insert(environments, _G)
    end

    for _, environment in ipairs(environments) do
        local ok, value = pcall(function()
            return rawget(environment, name)
        end)
        if ok and value ~= nil then
            return value
        end
    end

    return nil
end

local function getRequestFunction()
    local direct = getGlobal("request") or getGlobal("http_request")
    if type(direct) == "function" then
        return direct
    end

    local synObject = getGlobal("syn")
    if type(synObject) == "table" and type(synObject.request) == "function" then
        return synObject.request
    end

    return nil
end

local function getGuiParent()
    local gethui = getGlobal("gethui")
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    return game:GetService("CoreGui")
end

local function simpleHash(text)
    local hash = 5381
    for index = 1, #text do
        hash = (hash * 33 + string.byte(text, index)) % 2147483647
    end
    return tostring(hash)
end

local function normalizeAsset(source)
    if type(source) == "number" then
        return "rbxassetid://" .. tostring(source)
    end

    if type(source) ~= "string" then
        return ""
    end

    if source:match("^%d+$") then
        return "rbxassetid://" .. source
    end

    return source
end

local function fileExtensionFromUrl(url)
    local clean = url:match("^[^?]+") or url
    local extension = clean:match("%.([%w]+)$")
    extension = extension and extension:lower() or "png"

    if extension == "jpg" or extension == "jpeg" or extension == "png" or extension == "webp" then
        return extension
    end

    return "png"
end

local function resolveExternalImage(url)
    local request = getRequestFunction()
    local writefile = getGlobal("writefile")
    local isfile = getGlobal("isfile")
    local makefolder = getGlobal("makefolder")
    local isfolder = getGlobal("isfolder")
    local getcustomasset = getGlobal("getcustomasset") or getGlobal("getsynasset")

    if type(request) ~= "function"
        or type(writefile) ~= "function"
        or type(getcustomasset) ~= "function" then
        return url
    end

    local folder = "CapsuleUI_Images"
    local extension = fileExtensionFromUrl(url)
    local filePath = folder .. "/" .. simpleHash(url) .. "." .. extension

    local folderExists = false
    if type(isfolder) == "function" then
        local ok, result = pcall(isfolder, folder)
        folderExists = ok and result == true
    end

    if not folderExists and type(makefolder) == "function" then
        pcall(makefolder, folder)
    end

    local cached = false
    if type(isfile) == "function" then
        local ok, result = pcall(isfile, filePath)
        cached = ok and result == true
    end

    if not cached then
        local ok, response = pcall(request, {
            Url = url,
            Method = "GET",
        })

        if not ok or type(response) ~= "table" then
            return url
        end

        local statusCode = response.StatusCode or response.Status or 0
        local body = response.Body or response.body
        if tonumber(statusCode) and tonumber(statusCode) >= 400 then
            return url
        end
        if type(body) ~= "string" or #body == 0 then
            return url
        end

        local writeOk = pcall(writefile, filePath, body)
        if not writeOk then
            return url
        end
    end

    local ok, asset = pcall(getcustomasset, filePath)
    if ok and asset then
        return asset
    end

    return url
end

local function resolveImage(source)
    local normalized = normalizeAsset(source)
    if normalized == "" then
        return ""
    end

    if normalized:match("^https?://") then
        return resolveExternalImage(normalized)
    end

    return normalized
end

local function normalizeLucideTable(source)
    if source == nil then
        return nil
    end

    if typeof(source) == "Instance" and source:IsA("ModuleScript") then
        local ok, result = pcall(require, source)
        if ok then
            return result
        end
        return nil
    end

    if type(source) == "table" then
        return source
    end

    return nil
end

local function lookupLucide(customIcons, name)
    if type(name) == "number" then
        return resolveImage(name)
    end

    if type(name) ~= "string" or name == "" then
        return ""
    end

    if name:match("^https?://")
        or name:match("^rbxasset")
        or name:match("^rbxthumb")
        or name:match("^%d+$") then
        return resolveImage(name)
    end

    local lowered = string.lower(name)

    if type(customIcons) == "table" then
        local candidate = customIcons[lowered]
            or customIcons[name]
            or (type(customIcons.icons) == "table" and (customIcons.icons[lowered] or customIcons.icons[name]))

        if candidate ~= nil then
            if type(candidate) == "table" then
                candidate = candidate.Image or candidate.image or candidate.Id or candidate.id or candidate.Asset or candidate.asset
            end
            if type(candidate) == "number" or type(candidate) == "string" then
                return resolveImage(candidate)
            end
        end

        local getter = customIcons.getIcon or customIcons.GetIcon or customIcons.get or customIcons.Get
        if type(getter) == "function" then
            local ok, result = pcall(getter, customIcons, lowered)
            if not ok then
                ok, result = pcall(getter, lowered)
            end
            if ok and result then
                if type(result) == "table" then
                    result = result.Image or result.image or result.Id or result.id or result.Asset or result.asset
                end
                if type(result) == "number" or type(result) == "string" then
                    return resolveImage(result)
                end
            end
        end
    end

    local fallback = COMMON_LUCIDE[lowered]
    if fallback then
        return "rbxassetid://" .. tostring(fallback)
    end

    return ""
end

local function setIcon(imageLabel, customIcons, icon)
    local asset = lookupLucide(customIcons, icon)
    imageLabel.Image = asset
    imageLabel.Visible = asset ~= ""
    return asset
end

local function getPlayerHeadshot()
    if not LocalPlayer then
        return ""
    end

    local ok, content = pcall(function()
        local image = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        return image
    end)

    if ok then
        return content
    end

    return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
end

local function getLocalClockText()
    local ok, text = pcall(function()
        return DateTime.now():FormatLocalTime("HH:mm", "en-us")
    end)

    if ok and type(text) == "string" then
        return text
    end

    return os.date("%H:%M")
end

local function makeImage(parent, size, position, image, zIndex)
    local label = create("ImageLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = size,
        Position = position,
        Image = image or "",
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = zIndex or 1,
        Parent = parent,
    })
    return label
end

local function bindHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = hoverColor })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = normalColor })
    end)
end

local function makeControlBase(section, height)
    local row = create("Frame", {
        Name = "Control",
        BackgroundColor3 = section.Window.Theme.Control,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height),
        Parent = section.ControlHost,
    })
    addCorner(row, 10)
    return row
end

local function updateSectionCanvas(section)
    local padding = 20
    section.Content.CanvasSize = UDim2.fromOffset(0, section.Layout.AbsoluteContentSize.Y + padding)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Blank = {}
Blank.__index = Blank

local Paragraph = {}
Paragraph.__index = Paragraph

function CapsuleUI:CreateWindow(config)
    config = config or {}

    if CapsuleUI._activeWindow and config.AllowMultiple ~= true then
        pcall(function()
            CapsuleUI._activeWindow:Destroy()
        end)
    end

    local self = setmetatable({}, Window)
    self.Config = config
    self.Theme = mergeTheme(config.Theme)
    self.Lucide = normalizeLucideTable(config.Lucide or config.LucideModule)
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsOpen = false
    self.Destroyed = false
    self._clockConnection = nil
    self._connections = {}

    local screenGui = create("ScreenGui", {
        Name = config.Name or "CapsuleUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = config.DisplayOrder or 999999,
        Parent = getGuiParent(),
    })
    self.ScreenGui = screenGui

    local blur = create("BlurEffect", {
        Name = "CapsuleUI_Blur",
        Size = 0,
        Enabled = true,
        Parent = Lighting,
    })
    self.Blur = blur

    local contentGroup = create("CanvasGroup", {
        Name = "OpenContent",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        GroupTransparency = 1,
        Visible = false,
        Parent = screenGui,
    })
    self.ContentGroup = contentGroup

    local backdrop = create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = self.Theme.Backdrop,
        BackgroundTransparency = config.BackdropTransparency or 0.76,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
        Parent = contentGroup,
    })
    self.Backdrop = backdrop

    local pageLayer = create("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        Parent = contentGroup,
    })
    self.PageLayer = pageLayer

    local username = LocalPlayer and LocalPlayer.Name or "Player"
    local welcome = create("TextLabel", {
        Name = "Welcome",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(24, 20),
        Size = UDim2.fromOffset(520, 32),
        Font = Enum.Font.Gotham,
        Text = config.WelcomeText or ("Welcome, " .. username .. "."),
        TextColor3 = self.Theme.Text,
        TextSize = config.WelcomeTextSize or 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 5,
        Parent = contentGroup,
    })
    self.Welcome = welcome

    -- Profile circle: separate from the tab dock exactly like the reference.
    local profileButton = create("TextButton", {
        Name = "ProfileCircle",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -10),
        Size = UDim2.fromOffset(47, 47),
        BackgroundColor3 = self.Theme.CardAlt,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 10,
        ClipsDescendants = true,
        Parent = contentGroup,
    })
    addCorner(profileButton, 24)
    addStroke(profileButton, self.Theme.Stroke, 0.62, 1)

    local profileRing = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.new(1, -10, 1, -10),
        ZIndex = 11,
        Parent = profileButton,
    })
    addCorner(profileRing, 20)

    local profileImage = makeImage(
        profileRing,
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        config.ProfileImage and resolveImage(config.ProfileImage) or getPlayerHeadshot(),
        11
    )
    profileImage.ScaleType = Enum.ScaleType.Crop
    addCorner(profileImage, 20)
    self.ProfileButton = profileButton
    self.ProfileImage = profileImage

    local dock = create("Frame", {
        Name = "TabDock",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 70, 1, -10),
        Size = UDim2.fromOffset(136, 47),
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = contentGroup,
    })
    addCorner(dock, 24)
    addStroke(dock, self.Theme.Stroke, 0.72, 1)
    self.TabDock = dock

    local tabScroll = create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 5),
        Size = UDim2.new(1, -16, 1, -10),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 0,
        ZIndex = 11,
        Parent = dock,
    })
    local tabLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = tabScroll,
    })
    self.TabScroll = tabScroll
    self.TabLayout = tabLayout

    -- Requested X circle at the top-right.
    local closeButton = create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 20,
        Parent = contentGroup,
    })
    addCorner(closeButton, 20)
    addStroke(closeButton, self.Theme.Stroke, 0.72, 1)
    bindHover(closeButton, self.Theme.Card, self.Theme.CardAlt)

    local closeIcon = makeImage(
        closeButton,
        UDim2.fromOffset(19, 19),
        UDim2.fromScale(0.5, 0.5),
        "",
        21
    )
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    setIcon(closeIcon, self.Lucide, config.CloseIcon or "circle-x")

    if closeIcon.Image == "" then
        local fallbackX = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Font = Enum.Font.GothamMedium,
            Text = "X",
            TextColor3 = self.Theme.Text,
            TextSize = 15,
            ZIndex = 21,
            Parent = closeButton,
        })
        closeIcon.Visible = false
        self.CloseFallback = fallbackX
    end

    closeButton.Activated:Connect(function()
        self:Close()
    end)
    self.CloseButton = closeButton

    -- Bottom-right time/status pill from the reference image.
    if config.ShowClock ~= false then
        local status = create("Frame", {
            Name = "StatusPill",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -14, 1, -10),
            Size = UDim2.fromOffset(105, 47),
            BackgroundColor3 = self.Theme.Card,
            BorderSizePixel = 0,
            ZIndex = 10,
            Parent = contentGroup,
        })
        addCorner(status, 24)
        addStroke(status, self.Theme.Stroke, 0.72, 1)

        local clockLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -51, 1, 0),
            Font = Enum.Font.Gotham,
            Text = getLocalClockText(),
            TextColor3 = self.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = status,
        })

        local statusCircle = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.fromOffset(37, 37),
            BackgroundColor3 = self.Theme.Control,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = status,
        })
        addCorner(statusCircle, 19)

        local statusIcon = makeImage(
            statusCircle,
            UDim2.fromOffset(20, 20),
            UDim2.fromScale(0.5, 0.5),
            "",
            12
        )
        statusIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        setIcon(statusIcon, self.Lucide, config.StatusIcon or "image")

        self.StatusPill = status
        self.ClockLabel = clockLabel
        self._clockConnection = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if not self._lastClockUpdate or now - self._lastClockUpdate >= 15 then
                self._lastClockUpdate = now
                clockLabel.Text = getLocalClockText()
            end
        end)
    end

    -- Notification layer is outside the open-content group so notices can still
    -- appear while the main HUD is closed.
    local notificationHolder = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -68),
        Size = UDim2.fromOffset(310, 360),
        BackgroundTransparency = 1,
        ZIndex = 200,
        Parent = screenGui,
    })
    local notificationLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        Parent = notificationHolder,
    })
    self.NotificationHolder = notificationHolder
    self.NotificationLayout = notificationLayout

    self:_createCapsule()

    profileButton.Activated:Connect(function()
        if self.Tabs[1] then
            self:SelectTab(self.Tabs[1])
        end
    end)

    CapsuleUI._activeWindow = self

    if config.Opened == true then
        task.defer(function()
            self:Open()
        end)
    end

    return self
end

function Window:_createCapsule()
    local config = self.Config
    local theme = self.Theme

    local capsuleRoot = create("Frame", {
        Name = "CapsuleRoot",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, config.CapsuleY or 14),
        Size = UDim2.fromOffset(config.CapsuleWidth or 210, config.CapsuleHeight or 44),
        BackgroundTransparency = 1,
        ZIndex = 500,
        Parent = self.ScreenGui,
    })
    self.CapsuleRoot = capsuleRoot

    local scale = create("UIScale", {
        Scale = 1,
        Parent = capsuleRoot,
    })
    self.CapsuleScale = scale

    -- Two filled rounded rectangles behind the body make a soft body aura.
    -- This deliberately avoids a glowing UIStroke around the capsule edge.
    local glowOuter = create("Frame", {
        Name = "GlowOuter",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 18, 1, 14),
        BackgroundColor3 = theme.CapsuleGlow,
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
        ZIndex = 498,
        Parent = capsuleRoot,
    })
    addCorner(glowOuter, 32)

    local glowInner = create("Frame", {
        Name = "GlowInner",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 10, 1, 8),
        BackgroundColor3 = theme.CapsuleGlow,
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        ZIndex = 499,
        Parent = capsuleRoot,
    })
    addCorner(glowInner, 28)

    local body = create("TextButton", {
        Name = "Capsule",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Capsule,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 500,
        Parent = capsuleRoot,
    })
    addCorner(body, math.floor((config.CapsuleHeight or 44) / 2))

    local icon = makeImage(
        body,
        UDim2.fromOffset(24, 24),
        UDim2.fromOffset(13, 10),
        "",
        501
    )
    icon.ImageColor3 = theme.Text
    local capsuleIcon = config.CapsuleIcon or config.Icon or "image"
    setIcon(icon, self.Lucide, capsuleIcon)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(47, 0),
        Size = UDim2.new(1, -59, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = config.CapsuleTitle or config.Title or "Capsule",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 501,
        Parent = body,
    })

    self.CapsuleBody = body
    self.CapsuleIcon = icon
    self.CapsuleTitle = title
    self.CapsuleGlowInner = glowInner
    self.CapsuleGlowOuter = glowOuter

    local function pressIn()
        tween(scale, 0.12, { Scale = 1.055 }, Enum.EasingStyle.Back)
        tween(glowInner, 0.12, { BackgroundTransparency = 0.72 })
        tween(glowOuter, 0.12, { BackgroundTransparency = 0.84 })
    end

    local function pressOut()
        tween(scale, 0.16, { Scale = 1 }, Enum.EasingStyle.Back)
        tween(glowInner, 0.20, { BackgroundTransparency = 0.92 })
        tween(glowOuter, 0.20, { BackgroundTransparency = 0.96 })
    end

    body.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            pressIn()
        end
    end)

    body.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            pressOut()
        end
    end)

    body.MouseLeave:Connect(pressOut)

    body.Activated:Connect(function()
        pressOut()
        self:Toggle()
    end)
end

function Window:Open()
    if self.Destroyed or self.IsOpen then
        return
    end

    self.IsOpen = true
    self.ContentGroup.Visible = true
    self.ContentGroup.GroupTransparency = 1
    self.Blur.Size = 0

    tween(self.ContentGroup, self.Config.FadeDuration or 0.22, { GroupTransparency = 0 })
    tween(self.Blur, self.Config.FadeDuration or 0.22, { Size = self.Config.BlurSize or 12 })
end

function Window:Close()
    if self.Destroyed or not self.IsOpen then
        return
    end

    self.IsOpen = false
    local duration = self.Config.FadeDuration or 0.20

    tween(self.ContentGroup, duration, { GroupTransparency = 1 })
    tween(self.Blur, duration, { Size = 0 })

    task.delay(duration, function()
        if not self.IsOpen and self.ContentGroup then
            self.ContentGroup.Visible = false
        end
    end)
end

function Window:Toggle()
    if self.IsOpen then
        self:Close()
    else
        self:Open()
    end
end

function Window:CreateTab(config)
    config = config or {}

    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Config = config
    tab.Name = config.Name or ("Tab " .. tostring(#self.Tabs + 1))
    tab.Icon = config.Icon or "image"
    tab.Sections = {}
    tab._autoSectionIndex = 0

    local page = create("Frame", {
        Name = tab.Name,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 3,
        Parent = self.PageLayer,
    })
    tab.Page = page

    local button = create("TextButton", {
        Name = "TabButton_" .. tab.Name,
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = self.Theme.CardAlt,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = self.TabScroll,
    })
    addCorner(button, 17)
    tab.Button = button

    local icon = makeImage(
        button,
        UDim2.fromOffset(20, 20),
        UDim2.fromScale(0.5, 0.5),
        "",
        13
    )
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.ImageColor3 = self.Theme.Text
    setIcon(icon, self.Lucide, tab.Icon)
    tab.IconLabel = icon

    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            tween(button, 0.12, { BackgroundColor3 = self.Theme.Control })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            tween(button, 0.12, { BackgroundColor3 = self.Theme.CardAlt })
        end
    end)

    button.Activated:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    self:_resizeTabDock()

    if #self.Tabs == 1 or config.Selected == true then
        self:SelectTab(tab)
    end

    return tab
end

function Window:_resizeTabDock()
    local count = math.max(1, #self.Tabs)
    local desired = 16 + count * 34 + math.max(0, count - 1) * 8
    local width = math.clamp(desired, 54, self.Config.MaxDockWidth or 230)
    tween(self.TabDock, 0.14, { Size = UDim2.fromOffset(width, 47) })
end

function Window:SelectTab(tab)
    if self.ActiveTab == tab then
        return
    end

    for _, candidate in ipairs(self.Tabs) do
        local active = candidate == tab
        candidate.Page.Visible = active
        tween(candidate.Button, 0.14, {
            BackgroundColor3 = active and self.Theme.ControlActive or self.Theme.CardAlt,
        })
    end

    self.ActiveTab = tab
    safeCall(tab.Config.Callback, tab)
end

function Window:Notify(config)
    if type(config) == "string" then
        config = { Content = config }
    end
    config = config or {}

    local duration = tonumber(config.Duration) or 3

    local group = create("CanvasGroup", {
        Name = "Notification",
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Size = UDim2.fromOffset(292, 70),
        Parent = self.NotificationHolder,
    })

    local card = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 16, 0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        Parent = group,
    })
    addCorner(card, 14)
    addStroke(card, self.Theme.Stroke, 0.76, 1)

    local iconHolder = create("Frame", {
        Position = UDim2.fromOffset(10, 14),
        Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = self.Theme.Control,
        BorderSizePixel = 0,
        Parent = card,
    })
    addCorner(iconHolder, 20)

    local icon = makeImage(
        iconHolder,
        UDim2.fromOffset(20, 20),
        UDim2.fromScale(0.5, 0.5),
        "",
        2
    )
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    setIcon(icon, self.Lucide, config.Icon or "bell")

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(60, 10),
        Size = UDim2.new(1, -72, 0, 23),
        Font = Enum.Font.GothamMedium,
        Text = config.Title or "Notification",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    local content = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(60, 31),
        Size = UDim2.new(1, -72, 0, 29),
        Font = Enum.Font.Gotham,
        Text = config.Content or config.Description or "",
        TextColor3 = self.Theme.Muted,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    tween(group, 0.18, { GroupTransparency = 0 })
    tween(card, 0.20, { Position = UDim2.new(1, 0, 0, 0) })

    task.delay(duration, function()
        if not group.Parent then
            return
        end
        tween(group, 0.18, { GroupTransparency = 1 })
        tween(card, 0.18, { Position = UDim2.new(1, 18, 0, 0) })
        task.delay(0.19, function()
            if group then
                group:Destroy()
            end
        end)
    end)

    return group
end

function Window:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true
    self.IsOpen = false

    if self._clockConnection then
        self._clockConnection:Disconnect()
        self._clockConnection = nil
    end

    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    if self.Blur then
        self.Blur:Destroy()
    end

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    if CapsuleUI._activeWindow == self then
        CapsuleUI._activeWindow = nil
    end
end

function Tab:_resolvePlacement(config)
    local slot = config.Slot and SLOT_LAYOUT[config.Slot] or nil

    if slot then
        return config.Position or slot.Position, config.Size or slot.Size
    end

    if config.Position or config.Size then
        return config.Position or UDim2.fromOffset(23, 58), config.Size or UDim2.fromOffset(218, 184)
    end

    self._autoSectionIndex = self._autoSectionIndex + 1
    local index = self._autoSectionIndex - 1
    local column = index % 3
    local row = math.floor(index / 3)

    return UDim2.fromOffset(23 + column * 227, 58 + row * 193), UDim2.fromOffset(218, 184)
end

function Tab:CreateSection(config)
    config = config or {}

    local section = setmetatable({}, Section)
    section.Tab = self
    section.Window = self.Window
    section.Config = config
    section.Controls = {}

    local position, size = self:_resolvePlacement(config)

    local card = create("Frame", {
        Name = config.Name or config.Title or "Section",
        Position = position,
        Size = size,
        BackgroundColor3 = config.BackgroundColor3 or self.Window.Theme.Card,
        BackgroundTransparency = config.BackgroundTransparency or 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 5,
        Parent = self.Page,
    })
    addCorner(card, config.CornerRadius or 14)
    if config.Stroke ~= false then
        addStroke(card, self.Window.Theme.Stroke, config.StrokeTransparency or 0.82, 1)
    end
    section.Frame = card

    local hasTitle = type(config.Title) == "string" and config.Title ~= ""
    local headerHeight = hasTitle and 39 or 0

    if hasTitle then
        local title = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(13, 8),
            Size = UDim2.new(1, -26, 0, 24),
            Font = Enum.Font.GothamMedium,
            Text = config.Title,
            TextColor3 = self.Window.Theme.Text,
            TextSize = config.TitleSize or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 6,
            Parent = card,
        })
        section.TitleLabel = title
    end

    local content = create("ScrollingFrame", {
        Name = "Content",
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 1, -headerHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = config.ScrollBarThickness or 2,
        ScrollBarImageColor3 = self.Window.Theme.Faint,
        ScrollBarImageTransparency = 0.55,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ZIndex = 6,
        Parent = card,
    })
    addPadding(content, 12, hasTitle and 0 or 12, 12, 12)
    section.Content = content

    local host = create("Frame", {
        Name = "ControlHost",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = content,
    })
    section.ControlHost = host

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, config.ControlSpacing or 7),
        Parent = host,
    })
    section.Layout = layout

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateSectionCanvas(section)
    end)

    table.insert(self.Sections, section)
    return section
end

function Tab:CreateBlank(config)
    config = config or {}

    local blank = setmetatable({}, Blank)
    blank.Tab = self
    blank.Window = self.Window
    blank.Config = config

    local position, size = self:_resolvePlacement(config)

    local card = create("Frame", {
        Name = config.Name or "Blank",
        Position = position,
        Size = size,
        BackgroundColor3 = config.BackgroundColor3 or self.Window.Theme.Card,
        BackgroundTransparency = config.BackgroundTransparency or 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 5,
        Parent = self.Page,
    })
    addCorner(card, config.CornerRadius or 14)
    if config.Stroke ~= false then
        addStroke(card, self.Window.Theme.Stroke, config.StrokeTransparency or 0.82, 1)
    end
    blank.Frame = card

    local container = create("ScrollingFrame", {
        Name = "Container",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(config.Padding or 0, config.Padding or 0),
        Size = UDim2.new(1, -(config.Padding or 0) * 2, 1, -(config.Padding or 0) * 2),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.XY,
        ScrollingDirection = Enum.ScrollingDirection.XY,
        ScrollBarThickness = config.ScrollBarThickness or 2,
        ScrollBarImageColor3 = self.Window.Theme.Faint,
        ScrollBarImageTransparency = 0.58,
        ZIndex = 6,
        Parent = card,
    })
    blank.Container = container

    if type(config.Builder) == "function" then
        task.defer(function()
            safeCall(config.Builder, container, blank)
        end)
    end

    if config.Image then
        blank:SetImage(config.Image, config.ImageProperties)
    end

    table.insert(self.Sections, blank)
    return blank
end

function Blank:Add(instance)
    assert(typeof(instance) == "Instance", "Blank:Add expects a Roblox Instance")
    instance.Parent = self.Container
    return instance
end

function Blank:SetImage(source, props)
    props = props or {}
    local image = create("ImageLabel", {
        Name = props.Name or "Image",
        BackgroundTransparency = props.BackgroundTransparency or 1,
        BackgroundColor3 = props.BackgroundColor3 or self.Window.Theme.Control,
        BorderSizePixel = 0,
        Position = props.Position or UDim2.fromOffset(0, 0),
        Size = props.Size or UDim2.new(1, 0, 1, 0),
        Image = resolveImage(source),
        ScaleType = props.ScaleType or Enum.ScaleType.Fit,
        ImageColor3 = props.ImageColor3 or Color3.new(1, 1, 1),
        ImageTransparency = props.ImageTransparency or 0,
        ZIndex = props.ZIndex or 7,
        Parent = self.Container,
    })

    if props.CornerRadius then
        addCorner(image, props.CornerRadius)
    end

    return image
end

function Section:Add(instance)
    assert(typeof(instance) == "Instance", "Section:Add expects a Roblox Instance")
    instance.Parent = self.ControlHost
    table.insert(self.Controls, instance)
    return instance
end

function Section:CreateButton(config)
    config = config or {}
    local row = makeControlBase(self, config.Height or 36)
    row.Name = config.Title or "Button"

    local button = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = config.Title or "Button",
        Font = Enum.Font.GothamMedium,
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = row,
    })

    bindHover(row, self.Window.Theme.Control, self.Window.Theme.ControlHover)
    button.Activated:Connect(function()
        safeCall(config.Callback)
    end)

    table.insert(self.Controls, row)
    return button
end

function Section:CreateToggle(config)
    config = config or {}
    local value = config.Default == true
    local row = makeControlBase(self, config.Height or 42)
    row.Name = config.Title or "Toggle"

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -64, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Title or "Toggle",
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    local switch = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(36, 20),
        BackgroundColor3 = value and self.Window.Theme.ControlActive or self.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Parent = row,
    })
    addCorner(switch, 10)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = value and UDim2.new(1, -10, 0.5, 0) or UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0,
        Parent = switch,
    })
    addCorner(knob, 7)

    local hitbox = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })

    local api = {}
    function api:Set(newValue, silent)
        value = newValue == true
        tween(switch, 0.14, {
            BackgroundColor3 = value and self.Window.Theme.ControlActive or self.Window.Theme.CardAlt,
        })
        tween(knob, 0.14, {
            Position = value and UDim2.new(1, -10, 0.5, 0) or UDim2.fromOffset(10, 10),
        })
        if not silent then
            safeCall(config.Callback, value)
        end
    end
    function api:Get()
        return value
    end

    hitbox.Activated:Connect(function()
        api:Set(not value)
    end)

    table.insert(self.Controls, row)
    return api
end

local function createDropdown(section, config, multi)
    config = config or {}
    local values = config.Values or config.Options or {}
    local open = false
    local selected

    if multi then
        selected = {}
        for _, value in ipairs(config.Default or {}) do
            selected[value] = true
        end
    else
        selected = config.Default or values[1]
    end

    local collapsedHeight = config.Height or 42
    local row = makeControlBase(section, collapsedHeight)
    row.Name = config.Title or (multi and "MultiDropdown" or "Dropdown")
    row.ClipsDescendants = true

    local header = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, collapsedHeight),
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0.46, -12, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Title or (multi and "Multi dropdown" or "Dropdown"),
        TextColor3 = section.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = header,
    })

    local selectedLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0.48, -6, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = section.Window.Theme.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = header,
    })

    local chevron = makeImage(
        header,
        UDim2.fromOffset(16, 16),
        UDim2.new(1, -22, 0.5, 0),
        "",
        2
    )
    chevron.AnchorPoint = Vector2.new(0.5, 0.5)
    setIcon(chevron, section.Window.Lucide, "chevron-down")

    local optionHost = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, collapsedHeight),
        Size = UDim2.new(1, -16, 0, 0),
        Parent = row,
    })
    local optionLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = optionHost,
    })

    local optionButtons = {}

    local function selectionText()
        if not multi then
            return selected == nil and "None" or tostring(selected)
        end

        local list = {}
        for _, value in ipairs(values) do
            if selected[value] then
                table.insert(list, tostring(value))
            end
        end
        if #list == 0 then
            return "None"
        end
        return table.concat(list, ", ")
    end

    local function refreshOptionVisuals()
        selectedLabel.Text = selectionText()
        for value, button in pairs(optionButtons) do
            local active
            if multi then
                active = selected[value] == true
            else
                active = selected == value
            end
            tween(button, 0.10, {
                BackgroundColor3 = active and section.Window.Theme.ControlActive or section.Window.Theme.CardAlt,
            })
        end
    end

    local function setOpen(state)
        open = state == true
        local optionCount = math.min(#values, config.MaxVisibleOptions or 5)
        local expanded = collapsedHeight + 7 + optionCount * 33 + math.max(0, optionCount - 1) * 5 + 8
        local targetHeight = open and expanded or collapsedHeight
        tween(row, 0.16, { Size = UDim2.new(1, 0, 0, targetHeight) })
        optionHost.Size = UDim2.new(1, -16, 0, open and (targetHeight - collapsedHeight - 8) or 0)
        tween(chevron, 0.14, { Rotation = open and 180 or 0 })
    end

    for _, value in ipairs(values) do
        local option = create("TextButton", {
            BackgroundColor3 = section.Window.Theme.CardAlt,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 33),
            Font = Enum.Font.Gotham,
            Text = tostring(value),
            TextColor3 = section.Window.Theme.Text,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = optionHost,
        })
        addCorner(option, 8)
        optionButtons[value] = option

        option.Activated:Connect(function()
            if multi then
                selected[value] = not selected[value]
                refreshOptionVisuals()
                local current = {}
                for _, candidate in ipairs(values) do
                    if selected[candidate] then
                        table.insert(current, candidate)
                    end
                end
                safeCall(config.Callback, current)
            else
                selected = value
                refreshOptionVisuals()
                setOpen(false)
                safeCall(config.Callback, value)
            end
        end)
    end

    header.Activated:Connect(function()
        setOpen(not open)
    end)

    local api = {}
    function api:Set(value, silent)
        if multi then
            selected = {}
            if type(value) == "table" then
                for _, item in ipairs(value) do
                    selected[item] = true
                end
            end
            refreshOptionVisuals()
            if not silent then
                local current = {}
                for _, candidate in ipairs(values) do
                    if selected[candidate] then
                        table.insert(current, candidate)
                    end
                end
                safeCall(config.Callback, current)
            end
        else
            selected = value
            refreshOptionVisuals()
            if not silent then
                safeCall(config.Callback, value)
            end
        end
    end
    function api:Get()
        if multi then
            local current = {}
            for _, candidate in ipairs(values) do
                if selected[candidate] then
                    table.insert(current, candidate)
                end
            end
            return current
        end
        return selected
    end
    function api:Open()
        setOpen(true)
    end
    function api:Close()
        setOpen(false)
    end

    refreshOptionVisuals()
    table.insert(section.Controls, row)
    return api
end

function Section:CreateDropdown(config)
    return createDropdown(self, config, false)
end

function Section:CreateMultiDropdown(config)
    return createDropdown(self, config, true)
end

Section.CreateMultidropdown = Section.CreateMultiDropdown

function Section:CreateSlider(config)
    config = config or {}

    local minimum = tonumber(config.Min) or 0
    local maximum = tonumber(config.Max) or 100
    if maximum <= minimum then
        maximum = minimum + 1
    end

    local increment = tonumber(config.Increment) or 1
    local value = math.clamp(tonumber(config.Default) or minimum, minimum, maximum)
    local dragging = false

    local row = makeControlBase(self, config.Height or 58)
    row.Name = config.Title or "Slider"

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 5),
        Size = UDim2.new(1, -64, 0, 22),
        Font = Enum.Font.Gotham,
        Text = config.Title or "Slider",
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 5),
        Size = UDim2.fromOffset(52, 22),
        Font = Enum.Font.Gotham,
        Text = tostring(value),
        TextColor3 = self.Window.Theme.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local bar = create("Frame", {
        Position = UDim2.new(0, 12, 1, -17),
        Size = UDim2.new(1, -24, 0, 6),
        BackgroundColor3 = self.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Parent = row,
    })
    addCorner(bar, 3)

    local fill = create("Frame", {
        Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0,
        Parent = bar,
    })
    addCorner(fill, 3)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - minimum) / (maximum - minimum), 0, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0,
        Parent = bar,
    })
    addCorner(knob, 6)

    local hitbox = create("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 1, -27),
        Size = UDim2.new(1, -16, 0, 26),
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })

    local api = {}

    local function setValue(newValue, silent)
        local stepped = math.floor(((newValue - minimum) / increment) + 0.5) * increment + minimum
        stepped = math.clamp(stepped, minimum, maximum)
        value = stepped

        local alpha = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = config.Format and tostring(config.Format(value)) or tostring(value)

        if not silent then
            safeCall(config.Callback, value)
        end
    end

    local function updateFromInput(input)
        local absolutePosition = bar.AbsolutePosition.X
        local absoluteSize = bar.AbsoluteSize.X
        if absoluteSize <= 0 then
            return
        end
        local alpha = math.clamp((input.Position.X - absolutePosition) / absoluteSize, 0, 1)
        setValue(minimum + (maximum - minimum) * alpha)
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            updateFromInput(input)
        end
    end)

    function api:Set(newValue, silent)
        setValue(tonumber(newValue) or minimum, silent)
    end
    function api:Get()
        return value
    end

    setValue(value, true)
    table.insert(self.Controls, row)
    return api
end

function Section:CreateParagraph(config)
    config = config or {}

    local paragraph = setmetatable({}, Paragraph)
    paragraph.Section = self
    paragraph.Window = self.Window
    paragraph.Config = config

    local row = create("Frame", {
        Name = config.Title or "Paragraph",
        BackgroundColor3 = config.Plain and self.Window.Theme.Card or self.Window.Theme.Control,
        BackgroundTransparency = config.Plain and 1 or 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.ControlHost,
    })
    if not config.Plain then
        addCorner(row, 10)
    end
    paragraph.Frame = row

    local inner = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = row,
    })
    paragraph.Inner = inner

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = inner,
    })

    if config.Title and config.Title ~= "" then
        local title = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamMedium,
            Text = config.Title,
            TextColor3 = self.Window.Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 1,
            Parent = inner,
        })
        paragraph.TitleLabel = title
    end

    local contentText = config.Content or config.Description or config.Text
    if contentText and tostring(contentText) ~= "" then
        local body = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = tostring(contentText),
            TextColor3 = self.Window.Theme.Muted,
            TextSize = config.TextSize or 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = 2,
            Parent = inner,
        })
        paragraph.BodyLabel = body
    end

    if config.Image then
        paragraph:SetImage(config.Image, config.ImageProperties)
    end

    if type(config.Builder) == "function" then
        local host = paragraph:_ensureInstanceHost(config.InstanceHeight)
        task.defer(function()
            safeCall(config.Builder, host, paragraph)
        end)
    end

    -- Bottom breathing space while preserving AutomaticSize.
    create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 5),
        LayoutOrder = 9999,
        Parent = inner,
    })

    table.insert(self.Controls, row)
    return paragraph
end

function Paragraph:_ensureInstanceHost(height)
    if self.InstanceHost then
        return self.InstanceHost
    end

    local host = create("Frame", {
        Name = "InstanceHost",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, tonumber(height) or 60),
        LayoutOrder = 50,
        ClipsDescendants = false,
        Parent = self.Inner,
    })
    self.InstanceHost = host
    return host
end

function Paragraph:SetImage(source, props)
    props = props or {}
    local height = tonumber(props.Height or props.ImageHeight or self.Config.ImageHeight) or 110

    local image = create("ImageLabel", {
        Name = props.Name or "ParagraphImage",
        BackgroundColor3 = props.BackgroundColor3 or self.Window.Theme.CardAlt,
        BackgroundTransparency = props.BackgroundTransparency or 0,
        BorderSizePixel = 0,
        Size = props.Size or UDim2.new(1, 0, 0, height),
        Image = resolveImage(source),
        ImageColor3 = props.ImageColor3 or Color3.new(1, 1, 1),
        ImageTransparency = props.ImageTransparency or 0,
        ScaleType = props.ScaleType or Enum.ScaleType.Fit,
        LayoutOrder = props.LayoutOrder or 20,
        Parent = self.Inner,
    })
    addCorner(image, props.CornerRadius or 8)
    self.Image = image
    return image
end

function Paragraph:Add(instance, height)
    assert(typeof(instance) == "Instance", "Paragraph:Add expects a Roblox Instance")
    local resolvedHeight = tonumber(height)

    if not resolvedHeight then
        local size = instance.Size
        if typeof(size) == "UDim2" and size.Y.Scale == 0 and size.Y.Offset > 0 then
            resolvedHeight = size.Y.Offset
        else
            resolvedHeight = 60
        end
    end

    local host = self:_ensureInstanceHost(resolvedHeight)
    if host.Size.Y.Offset < resolvedHeight then
        host.Size = UDim2.new(1, 0, 0, resolvedHeight)
    end
    instance.Parent = host
    return instance
end


-- -----------------------------------------------------------------------------
-- 2026-10 refinement pass
-- This block intentionally overrides a few earlier methods while keeping the
-- same public API. It adds inset-safe positioning, quiet tab transitions,
-- refined controls, input/config support, and optional teleport auto-execute.
-- -----------------------------------------------------------------------------

local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local function getTopInsetY()
    local ok, topLeft = pcall(function()
        local inset = GuiService:GetGuiInset()
        return inset
    end)
    if ok and typeof(topLeft) == "Vector2" then
        return topLeft.Y
    end

    local ok2, a = pcall(function()
        local first = select(1, GuiService:GetGuiInset())
        return first
    end)
    if ok2 and typeof(a) == "Vector2" then
        return a.Y
    end
    return 0
end

local function sanitizeFileName(value)
    value = tostring(value or "CapsuleUI")
    value = value:gsub("[^%w%-%_%.]", "_")
    if value == "" then
        value = "CapsuleUI"
    end
    return value
end

local function getFileFunction(name)
    local value = getGlobal(name)
    if type(value) == "function" then
        return value
    end
    return nil
end

local function getQueueOnTeleport()
    local direct = getGlobal("queue_on_teleport") or getGlobal("queueonteleport")
    if type(direct) == "function" then
        return direct
    end

    local synObject = getGlobal("syn")
    if type(synObject) == "table" and type(synObject.queue_on_teleport) == "function" then
        return synObject.queue_on_teleport
    end

    local fluxus = getGlobal("fluxus")
    if type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
        return fluxus.queue_on_teleport
    end

    return nil
end

local function cloneSimple(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for key, item in pairs(value) do
        result[key] = cloneSimple(item)
    end
    return result
end

local function readJsonFile(path)
    local readfile = getFileFunction("readfile")
    local isfile = getFileFunction("isfile")
    if not readfile then
        return nil
    end

    if isfile then
        local okExists, exists = pcall(isfile, path)
        if not okExists or not exists then
            return nil
        end
    end

    local ok, raw = pcall(readfile, path)
    if not ok or type(raw) ~= "string" or raw == "" then
        return nil
    end

    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if decodedOk and type(decoded) == "table" then
        return decoded
    end
    return nil
end

local function ensureFolder(folder)
    local makefolder = getFileFunction("makefolder")
    local isfolder = getFileFunction("isfolder")
    if not makefolder then
        return false
    end

    if isfolder then
        local ok, exists = pcall(isfolder, folder)
        if ok and exists then
            return true
        end
    end

    local ok = pcall(makefolder, folder)
    return ok
end

function Window:_configFilePath(name)
    local folder = self.Config.ConfigFolder or "CapsuleUI_Configs"
    local configName = sanitizeFileName(name or self.Config.ConfigName or self.Config.Name or "CapsuleUI")
    return folder, folder .. "/" .. configName .. ".json"
end

function Window:_loadConfigCache(name)
    local _, path = self:_configFilePath(name)
    local data = readJsonFile(path)
    if type(data) == "table" then
        self._loadedConfig = data.Flags or data.flags or data
        if type(self._loadedConfig) ~= "table" then
            self._loadedConfig = {}
        end
        return true
    end
    self._loadedConfig = self._loadedConfig or {}
    return false
end

function Window:_saved(flag, fallback)
    if flag and self._loadedConfig and self._loadedConfig[flag] ~= nil then
        return cloneSimple(self._loadedConfig[flag])
    end
    return fallback
end

function Window:_scheduleConfigSave()
    if self.Config.AutoSave == false then
        return
    end
    self._saveNonce = (self._saveNonce or 0) + 1
    local nonce = self._saveNonce
    task.delay(0.18, function()
        if self.Destroyed or nonce ~= self._saveNonce then
            return
        end
        self:SaveConfig()
    end)
end

function Window:_setFlag(flag, value, skipSave)
    if not flag or flag == "" then
        return
    end
    self.Flags[flag] = cloneSimple(value)
    self._loadedConfig[flag] = cloneSimple(value)
    if not skipSave then
        self:_scheduleConfigSave()
    end
end

function Window:_registerFlag(flag, setter, getter)
    if not flag or flag == "" then
        return
    end
    self._flagRegistry[flag] = {
        Set = setter,
        Get = getter,
    }
end

function Window:GetFlag(flag, fallback)
    local value = self.Flags[flag]
    if value == nil then
        return fallback
    end
    return cloneSimple(value)
end

function Window:SetFlag(flag, value)
    local registration = self._flagRegistry[flag]
    if registration and type(registration.Set) == "function" then
        registration.Set(cloneSimple(value), false, false)
    else
        self:_setFlag(flag, value)
    end
end

function Window:SaveConfig(name)
    local writefile = getFileFunction("writefile")
    if not writefile then
        return false, "writefile is unavailable"
    end

    local folder, path = self:_configFilePath(name)
    ensureFolder(folder)

    local values = {}
    for flag, registration in pairs(self._flagRegistry) do
        if type(registration.Get) == "function" then
            local ok, value = pcall(registration.Get)
            if ok then
                values[flag] = cloneSimple(value)
            end
        end
    end
    for flag, value in pairs(self.Flags) do
        if values[flag] == nil then
            values[flag] = cloneSimple(value)
        end
    end

    local payload = {
        Version = 2,
        SavedAt = os.time(),
        Flags = values,
    }

    local okEncode, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not okEncode then
        return false, encoded
    end

    local okWrite, err = pcall(writefile, path, encoded)
    if okWrite then
        self._loadedConfig = cloneSimple(values)
        self.Flags = cloneSimple(values)
        return true
    end
    return false, err
end

function Window:LoadConfig(name)
    local old = self._loadedConfig
    self._loadedConfig = {}
    local loaded = self:_loadConfigCache(name)
    if not loaded then
        self._loadedConfig = old or {}
        return false
    end

    for flag, value in pairs(self._loadedConfig) do
        self.Flags[flag] = cloneSimple(value)
        local registration = self._flagRegistry[flag]
        if registration and type(registration.Set) == "function" then
            pcall(registration.Set, cloneSimple(value), true, true)
        end
    end
    return true
end

function Window:DeleteConfig(name)
    local delfile = getFileFunction("delfile")
    local isfile = getFileFunction("isfile")
    if not delfile then
        return false
    end
    local _, path = self:_configFilePath(name)
    if isfile then
        local ok, exists = pcall(isfile, path)
        if ok and not exists then
            return true
        end
    end
    return pcall(delfile, path)
end

function Window:ListConfigs()
    local listfiles = getFileFunction("listfiles")
    if not listfiles then
        return {}
    end
    local folder = self.Config.ConfigFolder or "CapsuleUI_Configs"
    ensureFolder(folder)
    local ok, files = pcall(listfiles, folder)
    if not ok or type(files) ~= "table" then
        return {}
    end
    local result = {}
    for _, path in ipairs(files) do
        local name = tostring(path):match("([^/\\]+)%.json$")
        if name then
            table.insert(result, name)
        end
    end
    table.sort(result)
    return result
end

function Window:_getAutoExecuteSource()
    local config = self.Config
    local source

    if type(config.AutoExecute) == "string" then
        source = config.AutoExecute
    end
    source = source or config.AutoExecuteSource or config.AutoExecuteCode or config.QueueCode

    if not source and type(config.AutoExecuteURL) == "string" and config.AutoExecuteURL ~= "" then
        source = "loadstring(game:HttpGet(" .. string.format("%q", config.AutoExecuteURL) .. "))()"
    end

    local folder = config.AutoExecuteFolder or "CapsuleUI_AutoExecute"
    local path = folder .. "/" .. sanitizeFileName(config.Name or "CapsuleUI") .. ".lua"
    local readfile = getFileFunction("readfile")
    local isfile = getFileFunction("isfile")

    if not source and readfile then
        local canRead = true
        if isfile then
            local okExists, exists = pcall(isfile, path)
            canRead = okExists and exists
        end
        if canRead then
            local okRead, previous = pcall(readfile, path)
            if okRead and type(previous) == "string" and previous ~= "" then
                source = previous
            end
        end
    end

    if source and source ~= "" then
        local writefile = getFileFunction("writefile")
        if writefile then
            ensureFolder(folder)
            pcall(writefile, path, source)
        end
    end

    return source
end

function Window:QueueAutoExecute()
    if self.Config.AutoExecute ~= true and type(self.Config.AutoExecute) ~= "string" then
        return false, "AutoExecute is disabled"
    end

    local queue = getQueueOnTeleport()
    if not queue then
        return false, "queue_on_teleport is unavailable"
    end

    local source = self:_getAutoExecuteSource()
    if not source then
        return false, "No AutoExecuteSource/AutoExecuteURL was provided or saved"
    end

    local ok, err = pcall(queue, source)
    self.AutoExecuteQueued = ok
    return ok, err
end

-- Updated window creation: keep the same screenshot layout, but move the upper
-- interface under Roblox's own top controls instead of drawing underneath them.
function CapsuleUI:CreateWindow(config)
    config = config or {}

    if CapsuleUI._activeWindow and config.AllowMultiple ~= true then
        pcall(function()
            CapsuleUI._activeWindow:Destroy()
        end)
    end

    local self = setmetatable({}, Window)
    self.Config = config
    self.Theme = mergeTheme(config.Theme)
    self.Lucide = normalizeLucideTable(config.Lucide or config.LucideModule)
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsOpen = false
    self.Destroyed = false
    self._clockConnection = nil
    self._connections = {}
    self._flagRegistry = {}
    self._loadedConfig = {}
    self.Flags = {}
    self._tabTransitionToken = 0

    if config.AutoLoad ~= false then
        self:_loadConfigCache()
        self.Flags = cloneSimple(self._loadedConfig)
    end

    local screenGui = create("ScreenGui", {
        Name = config.Name or "CapsuleUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = config.DisplayOrder or 999999,
        Parent = getGuiParent(),
    })
    self.ScreenGui = screenGui

    local blur = create("BlurEffect", {
        Name = "CapsuleUI_Blur",
        Size = 0,
        Enabled = true,
        Parent = Lighting,
    })
    self.Blur = blur

    local automaticOffset = math.max(52, getTopInsetY() + 8)
    local interfaceOffset = tonumber(config.InterfaceOffsetY) or automaticOffset
    self.InterfaceOffsetY = interfaceOffset

    local contentGroup = create("CanvasGroup", {
        Name = "OpenContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, interfaceOffset),
        Size = UDim2.new(1, 0, 1, -interfaceOffset),
        GroupTransparency = 1,
        Visible = false,
        Parent = screenGui,
    })
    self.ContentGroup = contentGroup

    local backdrop = create("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = self.Theme.Backdrop,
        BackgroundTransparency = config.BackdropTransparency or 0.78,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
        Parent = contentGroup,
    })
    self.Backdrop = backdrop

    local persistentLayer = create("Frame", {
        Name = "Persistent",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = contentGroup,
    })
    self.PersistentLayer = persistentLayer

    local pageLayer = create("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 4,
        Parent = contentGroup,
    })
    self.PageLayer = pageLayer

    local username = LocalPlayer and LocalPlayer.Name or "Player"
    local welcome = create("TextLabel", {
        Name = "Welcome",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(24, 5),
        Size = UDim2.fromOffset(520, 32),
        Font = Enum.Font.Gotham,
        Text = config.WelcomeText or ("Welcome, " .. username .. "."),
        TextColor3 = self.Theme.Text,
        TextSize = config.WelcomeTextSize or 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 7,
        Parent = contentGroup,
    })
    self.Welcome = welcome

    local profileButton = create("TextButton", {
        Name = "ProfileCircle",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -10),
        Size = UDim2.fromOffset(47, 47),
        BackgroundColor3 = self.Theme.CardAlt,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 20,
        ClipsDescendants = true,
        Parent = contentGroup,
    })
    addCorner(profileButton, 24)
    addStroke(profileButton, self.Theme.Stroke, 0.76, 1)

    local profileRing = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.new(1, -10, 1, -10),
        ZIndex = 21,
        Parent = profileButton,
    })
    addCorner(profileRing, 20)

    local profileImage = makeImage(
        profileRing,
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        config.ProfileImage and resolveImage(config.ProfileImage) or getPlayerHeadshot(),
        21
    )
    profileImage.ScaleType = Enum.ScaleType.Crop
    addCorner(profileImage, 20)
    self.ProfileButton = profileButton
    self.ProfileImage = profileImage

    local dock = create("Frame", {
        Name = "TabDock",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 70, 1, -10),
        Size = UDim2.fromOffset(136, 47),
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = contentGroup,
    })
    addCorner(dock, 24)
    addStroke(dock, self.Theme.Stroke, 0.82, 1)
    self.TabDock = dock

    local tabScroll = create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 5),
        Size = UDim2.new(1, -16, 1, -10),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 0,
        ZIndex = 21,
        Parent = dock,
    })
    local tabLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = tabScroll,
    })
    self.TabScroll = tabScroll
    self.TabLayout = tabLayout

    local closeButton = create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 5),
        Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 30,
        Parent = contentGroup,
    })
    addCorner(closeButton, 20)
    addStroke(closeButton, self.Theme.Stroke, 0.82, 1)

    local closeScale = create("UIScale", { Scale = 1, Parent = closeButton })
    local closeIcon = makeImage(closeButton, UDim2.fromOffset(19, 19), UDim2.fromScale(0.5, 0.5), "", 31)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    setIcon(closeIcon, self.Lucide, config.CloseIcon or "circle-x")
    if closeIcon.Image == "" then
        closeIcon.Visible = false
        create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Font = Enum.Font.GothamMedium,
            Text = "X",
            TextColor3 = self.Theme.Text,
            TextSize = 15,
            ZIndex = 31,
            Parent = closeButton,
        })
    end
    closeButton.MouseEnter:Connect(function()
        tween(closeScale, 0.12, { Scale = 1.04 })
        tween(closeButton, 0.12, { BackgroundColor3 = self.Theme.CardAlt })
    end)
    closeButton.MouseLeave:Connect(function()
        tween(closeScale, 0.12, { Scale = 1 })
        tween(closeButton, 0.12, { BackgroundColor3 = self.Theme.Card })
    end)
    closeButton.Activated:Connect(function()
        self:Close()
    end)
    self.CloseButton = closeButton

    if config.ShowClock ~= false then
        local status = create("Frame", {
            Name = "StatusPill",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -14, 1, -10),
            Size = UDim2.fromOffset(105, 47),
            BackgroundColor3 = self.Theme.Card,
            BorderSizePixel = 0,
            ZIndex = 20,
            Parent = contentGroup,
        })
        addCorner(status, 24)
        addStroke(status, self.Theme.Stroke, 0.82, 1)

        local clockLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -51, 1, 0),
            Font = Enum.Font.Gotham,
            Text = getLocalClockText(),
            TextColor3 = self.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 21,
            Parent = status,
        })

        local statusCircle = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.fromOffset(37, 37),
            BackgroundColor3 = self.Theme.Control,
            BorderSizePixel = 0,
            ZIndex = 21,
            Parent = status,
        })
        addCorner(statusCircle, 19)

        local statusIcon = makeImage(statusCircle, UDim2.fromOffset(20, 20), UDim2.fromScale(0.5, 0.5), "", 22)
        statusIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        setIcon(statusIcon, self.Lucide, config.StatusIcon or "image")

        self.StatusPill = status
        self.ClockLabel = clockLabel
        self._clockConnection = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if not self._lastClockUpdate or now - self._lastClockUpdate >= 15 then
                self._lastClockUpdate = now
                clockLabel.Text = getLocalClockText()
            end
        end)
    end

    local notificationHolder = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -68),
        Size = UDim2.fromOffset(310, 360),
        BackgroundTransparency = 1,
        ZIndex = 300,
        Parent = screenGui,
    })
    local notificationLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        Parent = notificationHolder,
    })
    self.NotificationHolder = notificationHolder
    self.NotificationLayout = notificationLayout

    self:_createCapsule()

    profileButton.Activated:Connect(function()
        if self.Tabs[1] then
            self:SelectTab(self.Tabs[1])
        end
    end)

    if config.AutoExecute == true or type(config.AutoExecute) == "string" then
        task.defer(function()
            self:QueueAutoExecute()
        end)
        if LocalPlayer and LocalPlayer.OnTeleport then
            local connection = LocalPlayer.OnTeleport:Connect(function()
                self:QueueAutoExecute()
            end)
            table.insert(self._connections, connection)
        end
    end

    CapsuleUI._activeWindow = self

    if config.Opened == true then
        task.defer(function()
            self:Open()
        end)
    end

    return self
end

-- Capsule: no UIStroke and no outline-style glow. The feedback is a tiny scale
-- beat plus a body-color lift. It also disappears while the interface is open.
function Window:_createCapsule()
    local config = self.Config
    local theme = self.Theme

    local capsuleRoot = create("CanvasGroup", {
        Name = "CapsuleRoot",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, config.CapsuleY or 14),
        Size = UDim2.fromOffset(config.CapsuleWidth or 210, config.CapsuleHeight or 44),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        ZIndex = 500,
        Parent = self.ScreenGui,
    })
    self.CapsuleRoot = capsuleRoot

    local scale = create("UIScale", { Scale = 1, Parent = capsuleRoot })
    self.CapsuleScale = scale

    local body = create("TextButton", {
        Name = "Capsule",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Capsule,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 500,
        Parent = capsuleRoot,
    })
    addCorner(body, math.floor((config.CapsuleHeight or 44) / 2))

    local icon = makeImage(body, UDim2.fromOffset(24, 24), UDim2.fromOffset(13, 10), "", 501)
    icon.ImageColor3 = theme.Text
    setIcon(icon, self.Lucide, config.CapsuleIcon or config.Icon or "image")

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(47, 0),
        Size = UDim2.new(1, -59, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = config.CapsuleTitle or config.Title or "Capsule",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 501,
        Parent = body,
    })

    self.CapsuleBody = body
    self.CapsuleIcon = icon
    self.CapsuleTitle = title

    local pressed = false
    local function pressIn()
        pressed = true
        tween(scale, 0.10, { Scale = 1.035 }, Enum.EasingStyle.Quint)
        tween(body, 0.10, { BackgroundColor3 = theme.CardAlt })
    end
    local function pressOut()
        if not pressed then
            return
        end
        pressed = false
        tween(scale, 0.16, { Scale = 1 }, Enum.EasingStyle.Back)
        tween(body, 0.16, { BackgroundColor3 = theme.Capsule })
    end

    body.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressIn()
        end
    end)
    body.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressOut()
        end
    end)
    body.MouseLeave:Connect(pressOut)
    body.Activated:Connect(function()
        pressOut()
        self:Toggle()
    end)
end

function Window:_hideCapsuleForOpen()
    if self.Config.HideCapsuleWhenOpen == false or not self.CapsuleRoot then
        return
    end
    local duration = math.min(self.Config.FadeDuration or 0.20, 0.16)
    tween(self.CapsuleRoot, duration, { GroupTransparency = 1 })
    task.delay(duration, function()
        if self.IsOpen and self.CapsuleRoot then
            self.CapsuleRoot.Visible = false
        end
    end)
end

function Window:_showCapsuleForClose()
    if self.Config.HideCapsuleWhenOpen == false or not self.CapsuleRoot then
        return
    end
    self.CapsuleRoot.Visible = true
    self.CapsuleRoot.GroupTransparency = 1
    tween(self.CapsuleRoot, 0.16, { GroupTransparency = 0 })
end

function Window:Open()
    if self.Destroyed or self.IsOpen then
        return
    end
    self.IsOpen = true
    self.ContentGroup.Visible = true
    self.ContentGroup.GroupTransparency = 1
    self.Blur.Size = 0

    self:_hideCapsuleForOpen()
    tween(self.ContentGroup, self.Config.FadeDuration or 0.22, { GroupTransparency = 0 })
    tween(self.Blur, self.Config.FadeDuration or 0.22, { Size = self.Config.BlurSize or 12 })
end

function Window:Close()
    if self.Destroyed or not self.IsOpen then
        return
    end
    self.IsOpen = false
    local duration = self.Config.FadeDuration or 0.20

    tween(self.ContentGroup, duration, { GroupTransparency = 1 })
    tween(self.Blur, duration, { Size = 0 })
    self:_showCapsuleForClose()

    task.delay(duration, function()
        if not self.IsOpen and self.ContentGroup then
            self.ContentGroup.Visible = false
        end
    end)
end

function Window:CreateTab(config)
    config = config or {}

    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Config = config
    tab.Name = config.Name or ("Tab " .. tostring(#self.Tabs + 1))
    tab.Icon = config.Icon or "image"
    tab.Sections = {}
    tab._autoSectionIndex = 0

    local page = create("CanvasGroup", {
        Name = tab.Name,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 4,
        Parent = self.PageLayer,
    })
    local pageScale = create("UIScale", { Scale = 1, Parent = page })
    tab.Page = page
    tab.PageScale = pageScale

    local button = create("TextButton", {
        Name = "TabButton_" .. tab.Name,
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = self.Theme.CardAlt,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 22,
        Parent = self.TabScroll,
    })
    addCorner(button, 17)
    local buttonScale = create("UIScale", { Scale = 1, Parent = button })
    tab.Button = button
    tab.ButtonScale = buttonScale

    local icon = makeImage(button, UDim2.fromOffset(20, 20), UDim2.fromScale(0.5, 0.5), "", 23)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.ImageColor3 = self.Theme.Text
    setIcon(icon, self.Lucide, tab.Icon)
    tab.IconLabel = icon

    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            tween(buttonScale, 0.12, { Scale = 1.025 })
            tween(button, 0.12, { BackgroundColor3 = self.Theme.Control })
        end
    end)
    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            tween(buttonScale, 0.12, { Scale = 1 })
            tween(button, 0.12, { BackgroundColor3 = self.Theme.CardAlt })
        end
    end)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(buttonScale, 0.08, { Scale = 0.94 })
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(buttonScale, 0.13, { Scale = self.ActiveTab == tab and 1.045 or 1 })
        end
    end)
    button.Activated:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    self:_resizeTabDock()

    local savedTab = self._loadedConfig and self._loadedConfig.__ActiveTab
    if (#self.Tabs == 1 and not savedTab) or config.Selected == true or savedTab == tab.Name then
        self:SelectTab(tab, true)
    end

    return tab
end

function Window:_setTabButtonVisual(tab, active)
    tween(tab.Button, 0.15, {
        BackgroundColor3 = active and self.Theme.ControlActive or self.Theme.CardAlt,
    })
    tween(tab.ButtonScale, 0.15, {
        Scale = active and 1.045 or 1,
    }, Enum.EasingStyle.Quint)
    if tab.IconLabel then
        tween(tab.IconLabel, 0.15, {
            ImageTransparency = active and 0 or 0.14,
        })
    end
end

function Window:SelectTab(tab, instant)
    if self.ActiveTab == tab then
        return
    end

    self._tabTransitionToken = self._tabTransitionToken + 1
    local token = self._tabTransitionToken
    local previous = self.ActiveTab
    self.ActiveTab = tab

    for _, candidate in ipairs(self.Tabs) do
        self:_setTabButtonVisual(candidate, candidate == tab)
    end

    self:_setFlag("__ActiveTab", tab.Name)

    if instant or not previous then
        if previous then
            previous.Page.Visible = false
            previous.Page.GroupTransparency = 1
        end
        tab.Page.Visible = true
        tab.Page.GroupTransparency = 0
        tab.PageScale.Scale = 1
        safeCall(tab.Config.Callback, tab)
        return
    end

    local outDuration = tonumber(self.Config.TabFadeOutDuration) or 0.10
    local inDuration = tonumber(self.Config.TabFadeInDuration) or 0.17

    if previous and previous.Page then
        previous.Page.Visible = true
        tween(previous.Page, outDuration, { GroupTransparency = 1 }, Enum.EasingStyle.Quint)
        tween(previous.PageScale, outDuration, { Scale = 0.992 }, Enum.EasingStyle.Quint)
    end

    tab.Page.Visible = true
    tab.Page.GroupTransparency = 1
    tab.PageScale.Scale = 0.992

    task.delay(outDuration, function()
        if token ~= self._tabTransitionToken or self.Destroyed then
            return
        end
        if previous and previous.Page then
            previous.Page.Visible = false
            previous.PageScale.Scale = 1
        end
        tween(tab.Page, inDuration, { GroupTransparency = 0 }, Enum.EasingStyle.Quint)
        tween(tab.PageScale, inDuration, { Scale = 1 }, Enum.EasingStyle.Quint)
        safeCall(tab.Config.Callback, tab)
    end)
end

-- Pinned sections/blanks are useful for identity/game cards that are part of the
-- shell rather than a tab feature. They remain visible while tabs switch.
function Tab:CreateSection(config)
    config = config or {}

    local section = setmetatable({}, Section)
    section.Tab = self
    section.Window = self.Window
    section.Config = config
    section.Controls = {}

    local position, size = self:_resolvePlacement(config)
    local parent = config.Pinned == true and self.Window.PersistentLayer or self.Page

    local card = create("Frame", {
        Name = config.Name or config.Title or "Section",
        Position = position,
        Size = size,
        BackgroundColor3 = config.BackgroundColor3 or self.Window.Theme.Card,
        BackgroundTransparency = config.BackgroundTransparency or 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = config.Pinned == true and 6 or 5,
        Parent = parent,
    })
    addCorner(card, config.CornerRadius or 14)
    if config.Stroke ~= false then
        addStroke(card, self.Window.Theme.Stroke, config.StrokeTransparency or 0.86, 1)
    end
    section.Frame = card

    local hasTitle = type(config.Title) == "string" and config.Title ~= ""
    local headerHeight = hasTitle and 39 or 0

    if hasTitle then
        local title = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(13, 8),
            Size = UDim2.new(1, -26, 0, 24),
            Font = Enum.Font.GothamMedium,
            Text = config.Title,
            TextColor3 = self.Window.Theme.Text,
            TextSize = config.TitleSize or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
            Parent = card,
        })
        section.TitleLabel = title
    end

    local content = create("ScrollingFrame", {
        Name = "Content",
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 1, -headerHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = config.ScrollBarThickness or 2,
        ScrollBarImageColor3 = self.Window.Theme.Faint,
        ScrollBarImageTransparency = 0.62,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        ZIndex = 7,
        Parent = card,
    })
    addPadding(content, 12, hasTitle and 0 or 12, 12, 12)
    section.Content = content

    local host = create("Frame", {
        Name = "ControlHost",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = content,
    })
    section.ControlHost = host

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, config.ControlSpacing or 7),
        Parent = host,
    })
    section.Layout = layout
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateSectionCanvas(section)
    end)

    table.insert(self.Sections, section)
    return section
end

function Tab:CreateBlank(config)
    config = config or {}

    local blank = setmetatable({}, Blank)
    blank.Tab = self
    blank.Window = self.Window
    blank.Config = config

    local position, size = self:_resolvePlacement(config)
    local parent = config.Pinned == true and self.Window.PersistentLayer or self.Page

    local card = create("Frame", {
        Name = config.Name or "Blank",
        Position = position,
        Size = size,
        BackgroundColor3 = config.BackgroundColor3 or self.Window.Theme.Card,
        BackgroundTransparency = config.BackgroundTransparency or 0,
        BorderSizePixel = 0,
        ClipsDescendants = config.ClipsDescendants == true,
        ZIndex = config.Pinned == true and 6 or 5,
        Parent = parent,
    })
    addCorner(card, config.CornerRadius or 14)
    if config.Stroke ~= false then
        addStroke(card, self.Window.Theme.Stroke, config.StrokeTransparency or 0.86, 1)
    end
    blank.Frame = card

    local host = create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(config.Padding or 0, config.Padding or 0),
        Size = UDim2.new(1, -(config.Padding or 0) * 2, 1, -(config.Padding or 0) * 2),
        Parent = card,
    })
    blank.Container = host

    if config.Image then
        blank:SetImage(config.Image, config.ImageProperties)
    end
    if type(config.Builder) == "function" then
        task.defer(function()
            safeCall(config.Builder, host, blank)
        end)
    end

    table.insert(self.Sections, blank)
    return blank
end

-- Slightly quieter component base. No border/glow is added here.
makeControlBase = function(section, height)
    local row = create("Frame", {
        Name = "Control",
        BackgroundColor3 = section.Window.Theme.Control,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height),
        Parent = section.ControlHost,
    })
    addCorner(row, 9)
    return row
end

function Section:CreateToggle(config)
    config = config or {}
    local flag = config.Flag
    local value = self.Window:_saved(flag, config.Default == true) == true

    local row = makeControlBase(self, config.Height or 43)
    row.Name = config.Title or "Toggle"

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -64, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Title or "Toggle",
        TextColor3 = self.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    local switch = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(34, 20),
        BackgroundColor3 = value and self.Window.Theme.ControlActive or self.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Parent = row,
    })
    addCorner(switch, 10)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = value and UDim2.new(1, -10, 0.5, 0) or UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(13, 13),
        BackgroundColor3 = value and self.Window.Theme.Text or self.Window.Theme.Muted,
        BorderSizePixel = 0,
        Parent = switch,
    })
    addCorner(knob, 7)

    local hitbox = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })

    local api = {}
    local function apply(newValue, silent, skipSave)
        value = newValue == true
        tween(switch, 0.14, { BackgroundColor3 = value and self.Window.Theme.ControlActive or self.Window.Theme.CardAlt })
        tween(knob, 0.14, {
            Position = value and UDim2.new(1, -10, 0.5, 0) or UDim2.fromOffset(10, 10),
            BackgroundColor3 = value and self.Window.Theme.Text or self.Window.Theme.Muted,
        })
        self.Window:_setFlag(flag, value, skipSave)
        if not silent then
            safeCall(config.Callback, value)
        end
    end
    function api:Set(newValue, silent, skipSave)
        apply(newValue, silent, skipSave)
    end
    function api:Get()
        return value
    end

    hitbox.Activated:Connect(function()
        apply(not value, false, false)
    end)

    self.Window:_registerFlag(flag, function(v, silent, skipSave)
        apply(v, silent, skipSave)
    end, function()
        return value
    end)
    self.Window:_setFlag(flag, value, true)

    table.insert(self.Controls, row)
    return api
end

local function refinedDropdown(section, config, multi)
    config = config or {}
    local values = config.Values or config.Options or {}
    local flag = config.Flag
    local open = false
    local saved = section.Window:_saved(flag, config.Default)
    local selected

    if multi then
        selected = {}
        local defaults = type(saved) == "table" and saved or {}
        for _, value in ipairs(defaults) do
            selected[value] = true
        end
    else
        selected = saved ~= nil and saved or values[1]
    end

    local collapsedHeight = config.Height or 44
    local optionHeight = config.OptionHeight or 32
    local row = makeControlBase(section, collapsedHeight)
    row.Name = config.Title or (multi and "MultiDropdown" or "Dropdown")
    row.ClipsDescendants = true

    local header = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, collapsedHeight),
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0.44, -12, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Title or (multi and "Multi dropdown" or "Dropdown"),
        TextColor3 = section.Window.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = header,
    })

    local valuePill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.new(0.50, 0, 0, 28),
        BackgroundColor3 = section.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Parent = header,
    })
    addCorner(valuePill, 8)

    local selectedLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -31, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = section.Window.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = valuePill,
    })

    local chevron = makeImage(valuePill, UDim2.fromOffset(14, 14), UDim2.new(1, -17, 0.5, 0), "", 2)
    chevron.AnchorPoint = Vector2.new(0.5, 0.5)
    chevron.ImageTransparency = 0.12
    setIcon(chevron, section.Window.Lucide, "chevron-down")

    local divider = create("Frame", {
        BackgroundColor3 = section.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(9, collapsedHeight),
        Size = UDim2.new(1, -18, 0, 1),
        BackgroundTransparency = 0.35,
        Parent = row,
    })

    local optionHost = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, collapsedHeight + 7),
        Size = UDim2.new(1, -16, 0, 0),
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = section.Window.Theme.Faint,
        ScrollBarImageTransparency = 0.55,
        Parent = row,
    })
    local optionLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = optionHost,
    })

    local optionButtons = {}
    local optionIndicators = {}

    local function currentList()
        local result = {}
        if multi then
            for _, candidate in ipairs(values) do
                if selected[candidate] then
                    table.insert(result, candidate)
                end
            end
        elseif selected ~= nil then
            table.insert(result, selected)
        end
        return result
    end

    local function selectionText()
        if not multi then
            return selected == nil and "None" or tostring(selected)
        end
        local list = currentList()
        if #list == 0 then
            return "None"
        elseif #list == 1 then
            return tostring(list[1])
        elseif #list == 2 then
            return tostring(list[1]) .. ", " .. tostring(list[2])
        end
        return tostring(list[1]) .. " +" .. tostring(#list - 1)
    end

    local function refreshOptionVisuals()
        selectedLabel.Text = selectionText()
        for value, button in pairs(optionButtons) do
            local active = multi and selected[value] == true or selected == value
            tween(button, 0.10, {
                BackgroundColor3 = active and section.Window.Theme.ControlActive or section.Window.Theme.CardAlt,
            })
            local indicator = optionIndicators[value]
            if indicator then
                tween(indicator, 0.10, {
                    BackgroundColor3 = active and section.Window.Theme.Text or section.Window.Theme.Control,
                    BackgroundTransparency = active and 0.05 or 0.25,
                })
            end
        end
    end

    local function pushFlag(skipSave)
        local value = multi and currentList() or selected
        section.Window:_setFlag(flag, value, skipSave)
    end

    local function setOpen(state)
        open = state == true
        local visibleCount = math.min(#values, config.MaxVisibleOptions or 5)
        local optionsHeight = visibleCount > 0 and (visibleCount * optionHeight + math.max(0, visibleCount - 1) * 5) or 0
        local expanded = collapsedHeight + 14 + optionsHeight + 8
        local targetHeight = open and expanded or collapsedHeight
        optionHost.CanvasSize = UDim2.fromOffset(0, #values * optionHeight + math.max(0, #values - 1) * 5)
        optionHost.Size = UDim2.new(1, -16, 0, open and optionsHeight or 0)
        tween(row, 0.18, { Size = UDim2.new(1, 0, 0, targetHeight) }, Enum.EasingStyle.Quint)
        tween(chevron, 0.16, { Rotation = open and 180 or 0 })
        divider.Visible = open
    end

    for _, value in ipairs(values) do
        local option = create("TextButton", {
            BackgroundColor3 = section.Window.Theme.CardAlt,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -2, 0, optionHeight),
            Text = "",
            AutoButtonColor = false,
            Parent = optionHost,
        })
        addCorner(option, 8)

        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -42, 1, 0),
            Font = Enum.Font.Gotham,
            Text = tostring(value),
            TextColor3 = section.Window.Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = option,
        })

        local indicator = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -9, 0.5, 0),
            Size = UDim2.fromOffset(multi and 14 or 9, multi and 14 or 9),
            BackgroundColor3 = section.Window.Theme.Control,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Parent = option,
        })
        addCorner(indicator, multi and 4 or 5)

        optionButtons[value] = option
        optionIndicators[value] = indicator

        option.MouseEnter:Connect(function()
            local active = multi and selected[value] == true or selected == value
            if not active then
                tween(option, 0.10, { BackgroundColor3 = section.Window.Theme.Control })
            end
        end)
        option.MouseLeave:Connect(function()
            refreshOptionVisuals()
        end)
        option.Activated:Connect(function()
            if multi then
                selected[value] = not selected[value]
                refreshOptionVisuals()
                pushFlag(false)
                safeCall(config.Callback, currentList())
            else
                selected = value
                refreshOptionVisuals()
                pushFlag(false)
                setOpen(false)
                safeCall(config.Callback, value)
            end
        end)
    end

    header.Activated:Connect(function()
        setOpen(not open)
    end)

    local api = {}
    local function apply(value, silent, skipSave)
        if multi then
            selected = {}
            if type(value) == "table" then
                for _, item in ipairs(value) do
                    selected[item] = true
                end
            end
            refreshOptionVisuals()
            pushFlag(skipSave)
            if not silent then
                safeCall(config.Callback, currentList())
            end
        else
            selected = value
            refreshOptionVisuals()
            pushFlag(skipSave)
            if not silent then
                safeCall(config.Callback, value)
            end
        end
    end
    function api:Set(value, silent, skipSave)
        apply(value, silent, skipSave)
    end
    function api:Get()
        return multi and currentList() or selected
    end
    function api:Open()
        setOpen(true)
    end
    function api:Close()
        setOpen(false)
    end

    section.Window:_registerFlag(flag, function(v, silent, skipSave)
        apply(v, silent, skipSave)
    end, function()
        return multi and currentList() or selected
    end)
    pushFlag(true)
    refreshOptionVisuals()
    divider.Visible = false
    table.insert(section.Controls, row)
    return api
end

function Section:CreateDropdown(config)
    return refinedDropdown(self, config, false)
end

function Section:CreateMultiDropdown(config)
    return refinedDropdown(self, config, true)
end
Section.CreateMultidropdown = Section.CreateMultiDropdown

function Section:CreateSlider(config)
    config = config or {}

    local minimum = tonumber(config.Min) or 0
    local maximum = tonumber(config.Max) or 100
    if maximum <= minimum then
        maximum = minimum + 1
    end
    local increment = tonumber(config.Increment) or 1
    if increment <= 0 then
        increment = 1
    end

    local flag = config.Flag
    local savedValue = self.Window:_saved(flag, config.Default ~= nil and config.Default or minimum)
    local value = math.clamp(tonumber(savedValue) or minimum, minimum, maximum)
    local dragging = false

    local checkboxFlag = config.CheckboxFlag
    local checkboxState = self.Window:_saved(checkboxFlag, config.CheckboxDefault == true) == true

    local row = makeControlBase(self, config.Height or 58)
    row.Name = config.Title or "Slider"

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 4),
        Size = UDim2.new(1, -20, 0, 19),
        Font = Enum.Font.Gotham,
        Text = config.Title or "Slider",
        TextColor3 = self.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    local boxSize = 28
    local box = create("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -8, 1, -7),
        Size = UDim2.fromOffset(boxSize, boxSize),
        BackgroundColor3 = checkboxState and self.Window.Theme.ControlActive or self.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    addCorner(box, 7)

    local rail = create("Frame", {
        Position = UDim2.fromOffset(10, 27),
        Size = UDim2.new(1, -(boxSize + 28), 0, 24),
        BackgroundColor3 = self.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = row,
    })
    addCorner(rail, 7)

    local fill = create("Frame", {
        Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1),
        BackgroundColor3 = Color3.fromRGB(118, 119, 122),
        BorderSizePixel = 0,
        Parent = rail,
    })
    addCorner(fill, 7)

    local valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        Size = UDim2.fromOffset(50, 24),
        Font = Enum.Font.Gotham,
        Text = tostring(value),
        TextColor3 = self.Window.Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = rail,
    })

    local marker = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - minimum) / (maximum - minimum), 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 14),
        BackgroundColor3 = self.Window.Theme.Text,
        BorderSizePixel = 0,
        Parent = rail,
    })
    addCorner(marker, 2)

    local hitbox = create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        AutoButtonColor = false,
        Parent = rail,
    })

    local api = {}

    local function steppedValue(newValue)
        local steps = math.floor(((newValue - minimum) / increment) + 0.5)
        return math.clamp(minimum + steps * increment, minimum, maximum)
    end

    local function displayValue(v)
        if type(config.Format) == "function" then
            local ok, formatted = pcall(config.Format, v)
            if ok then
                return tostring(formatted)
            end
        end
        return tostring(v)
    end

    local function setValue(newValue, silent, skipSave)
        value = steppedValue(tonumber(newValue) or minimum)
        local alpha = (value - minimum) / (maximum - minimum)
        tween(fill, 0.06, { Size = UDim2.fromScale(alpha, 1) }, Enum.EasingStyle.Linear)
        tween(marker, 0.06, { Position = UDim2.new(alpha, 0, 0.5, 0) }, Enum.EasingStyle.Linear)
        valueLabel.Text = displayValue(value)
        self.Window:_setFlag(flag, value, skipSave)
        if not silent then
            safeCall(config.Callback, value)
        end
    end

    local function setCheckbox(state, silent, skipSave)
        checkboxState = state == true
        tween(box, 0.13, {
            BackgroundColor3 = checkboxState and self.Window.Theme.ControlActive or self.Window.Theme.CardAlt,
        })
        self.Window:_setFlag(checkboxFlag, checkboxState, skipSave)
        if not silent then
            safeCall(config.CheckboxCallback, checkboxState)
        end
    end

    local function updateFromPosition(x)
        local left = rail.AbsolutePosition.X
        local width = rail.AbsoluteSize.X
        if width <= 0 then
            return
        end
        local alpha = math.clamp((x - left) / width, 0, 1)
        setValue(minimum + (maximum - minimum) * alpha, false, false)
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromPosition(input.Position.X)
            tween(marker, 0.08, { Size = UDim2.fromOffset(4, 18) })
        end
    end)
    hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            tween(marker, 0.10, { Size = UDim2.fromOffset(3, 14) })
        end
    end)

    local connection = UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateFromPosition(input.Position.X)
        end
    end)
    table.insert(self.Window._connections, connection)

    box.Activated:Connect(function()
        setCheckbox(not checkboxState, false, false)
    end)

    function api:Set(newValue, silent, skipSave)
        setValue(newValue, silent, skipSave)
    end
    function api:Get()
        return value
    end
    function api:SetEnabled(state, silent, skipSave)
        setCheckbox(state, silent, skipSave)
    end
    function api:GetEnabled()
        return checkboxState
    end

    self.Window:_registerFlag(flag, function(v, silent, skipSave)
        setValue(v, silent, skipSave)
    end, function()
        return value
    end)
    self.Window:_registerFlag(checkboxFlag, function(v, silent, skipSave)
        setCheckbox(v, silent, skipSave)
    end, function()
        return checkboxState
    end)
    self.Window:_setFlag(flag, value, true)
    self.Window:_setFlag(checkboxFlag, checkboxState, true)
    setValue(value, true, true)

    table.insert(self.Controls, row)
    return api
end

function Section:CreateInput(config)
    config = config or {}
    local flag = config.Flag
    local default = config.Default or config.Value or ""
    local value = tostring(self.Window:_saved(flag, default) or "")

    local row = makeControlBase(self, config.Height or 58)
    row.Name = config.Title or "Input"

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 3),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        Text = config.Title or "Input",
        TextColor3 = self.Window.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    local inputHolder = create("Frame", {
        Position = UDim2.fromOffset(9, 27),
        Size = UDim2.new(1, -18, 0, 24),
        BackgroundColor3 = self.Window.Theme.CardAlt,
        BorderSizePixel = 0,
        Parent = row,
    })
    addCorner(inputHolder, 7)

    local box = create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        Text = value,
        PlaceholderText = config.Placeholder or config.PlaceholderText or "Type here...",
        PlaceholderColor3 = self.Window.Theme.Faint,
        TextColor3 = self.Window.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = inputHolder,
    })

    local api = {}
    local function normalize(text)
        text = tostring(text or "")
        if config.MaxLength and #text > tonumber(config.MaxLength) then
            text = string.sub(text, 1, tonumber(config.MaxLength))
        end
        if config.Numeric == true then
            local number = tonumber(text)
            if number == nil and text ~= "" then
                return value
            end
            if number ~= nil then
                if config.Min ~= nil then
                    number = math.max(number, tonumber(config.Min) or number)
                end
                if config.Max ~= nil then
                    number = math.min(number, tonumber(config.Max) or number)
                end
                text = tostring(number)
            end
        end
        return text
    end

    local function apply(text, silent, skipSave)
        value = normalize(text)
        box.Text = value
        self.Window:_setFlag(flag, value, skipSave)
        if not silent then
            safeCall(config.Callback, config.Numeric == true and tonumber(value) or value)
        end
    end

    box.FocusLost:Connect(function(enterPressed)
        apply(box.Text, false, false)
        safeCall(config.FocusLost, config.Numeric == true and tonumber(value) or value, enterPressed)
    end)

    if config.Continuous == true then
        local connection = box:GetPropertyChangedSignal("Text"):Connect(function()
            value = normalize(box.Text)
            if value ~= box.Text then
                box.Text = value
                box.CursorPosition = #value + 1
            end
            self.Window:_setFlag(flag, value, false)
            safeCall(config.Changed, config.Numeric == true and tonumber(value) or value)
        end)
        table.insert(self.Window._connections, connection)
    end

    function api:Set(text, silent, skipSave)
        apply(text, silent, skipSave)
    end
    function api:Get()
        return config.Numeric == true and tonumber(value) or value
    end
    function api:Focus()
        box:CaptureFocus()
    end

    self.Window:_registerFlag(flag, function(v, silent, skipSave)
        apply(v, silent, skipSave)
    end, function()
        return value
    end)
    self.Window:_setFlag(flag, value, true)

    table.insert(self.Controls, row)
    return api
end

Section.CreateTextbox = Section.CreateInput
Section.CreateTextBox = Section.CreateInput

-- Preserve cleanup for the extra teleport/config/input connections created by
-- this refinement block.
local _previousDestroy = Window.Destroy
function Window:Destroy()
    if self.Destroyed then
        return
    end
    if self.Config.AutoSave ~= false then
        pcall(function()
            self:SaveConfig()
        end)
    end
    _previousDestroy(self)
end

-- Convenience aliases.
CapsuleUI.new = function(config)
    return CapsuleUI:CreateWindow(config)
end

CapsuleUI.ResolveImage = resolveImage
CapsuleUI.ResolveIcon = function(icon, lucide)
    return lookupLucide(normalizeLucideTable(lucide), icon)
end

return CapsuleUI
