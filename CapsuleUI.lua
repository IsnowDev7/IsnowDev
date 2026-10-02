-- CapsuleUI.lua
-- A restrained Roblox UI library inspired by compact game dashboards.
-- Fixed-size window, scroll-first sections, dynamic-island style launcher,
-- soft open/close blur, Lucide icon support, and external-image adapters.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local CapsuleUI = {}
CapsuleUI.__index = CapsuleUI
CapsuleUI._lastWindow = nil

local REMOTE_LUCIDE_URL = "https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/LucideIcons.luau"

-- Common icons are embedded so the core UI still works before/without remote loading.
-- These IDs are from Nebula-Softworks/Nebula-Icon-Library's Lucide mapping.
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

local THEME = {
    Backdrop = Color3.fromRGB(7, 8, 10),
    Window = Color3.fromRGB(22, 23, 26),
    Surface = Color3.fromRGB(29, 30, 34),
    Surface2 = Color3.fromRGB(36, 37, 41),
    Surface3 = Color3.fromRGB(43, 44, 49),
    Border = Color3.fromRGB(54, 55, 61),
    Text = Color3.fromRGB(242, 242, 245),
    Muted = Color3.fromRGB(154, 156, 165),
    Faint = Color3.fromRGB(105, 107, 116),
    Accent = Color3.fromRGB(238, 238, 241),
    AccentText = Color3.fromRGB(20, 21, 24),
    Danger = Color3.fromRGB(214, 92, 92),
}

local function copyTable(source)
    local out = {}
    for k, v in pairs(source or {}) do
        out[k] = v
    end
    return out
end

local function mergeTheme(overrides)
    local out = copyTable(THEME)
    for k, v in pairs(overrides or {}) do
        out[k] = v
    end
    return out
end

local function tween(instance, duration, properties, style, direction)
    local info = TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local object = TweenService:Create(instance, info, properties)
    object:Play()
    return object
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
            warn("[CapsuleUI] callback error: " .. tostring(err))
        end
    end)
end

local function create(className, properties, children)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
        Parent = parent,
    })
end

local function padding(parent, top, right, bottom, left)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        Parent = parent,
    })
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function getGlobal(name)
    local environments = {}

    local okGenv, genv = pcall(function()
        return getgenv and getgenv() or nil
    end)
    if okGenv and type(genv) == "table" then
        table.insert(environments, genv)
    end

    if type(_G) == "table" then
        table.insert(environments, _G)
    end

    for _, env in ipairs(environments) do
        local ok, value = pcall(function()
            return rawget(env, name)
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

local function simpleHash(value)
    local hash = 5381
    for i = 1, #value do
        hash = (hash * 33 + string.byte(value, i)) % 2147483647
    end
    return tostring(hash)
end

local function looksLikeImageUri(value)
    if type(value) ~= "string" then
        return false
    end
    return value:match("^rbxassetid://")
        or value:match("^rbxasset://")
        or value:match("^rbxthumb://")
        or value:match("^rbxgameasset://")
        or value:match("^https?://")
        or value:match("^rbxtemp://")
end

local function normalizeAsset(value)
    if type(value) == "number" then
        return "rbxassetid://" .. tostring(value)
    end
    if type(value) ~= "string" then
        return ""
    end
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end
    return value
end

local function getGuiParent()
    local gethuiFn = getGlobal("gethui")
    if type(gethuiFn) == "function" then
        local ok, result = pcall(gethuiFn)
        if ok and result then
            return result
        end
    end

    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    return game:GetService("CoreGui")
end

local function tryLoadRemoteLucide()
    local loadstringFn = getGlobal("loadstring") or loadstring
    if type(loadstringFn) ~= "function" then
        return nil
    end

    local source
    local okHttp = pcall(function()
        source = game:HttpGet(REMOTE_LUCIDE_URL)
    end)
    if not okHttp or type(source) ~= "string" or #source < 10 then
        return nil
    end

    local okCompile, chunk = pcall(loadstringFn, source)
    if not okCompile or type(chunk) ~= "function" then
        return nil
    end

    local okRun, result = pcall(chunk)
    if okRun and type(result) == "table" then
        return result
    end

    return nil
end

local function applyLucideAsset(image, asset)
    if type(asset) == "number" then
        image.Image = "rbxassetid://" .. tostring(asset)
        return true
    end

    if type(asset) == "string" then
        image.Image = normalizeAsset(asset)
        return true
    end

    if type(asset) ~= "table" then
        return false
    end

    local url = asset.Url or asset.URL or asset.Image or asset.Texture
    local id = asset.Id or asset.ID or asset.AssetId
    if url then
        image.Image = normalizeAsset(url)
    elseif id then
        image.Image = "rbxassetid://" .. tostring(id)
    else
        return false
    end

    if typeof(asset.ImageRectOffset) == "Vector2" then
        image.ImageRectOffset = asset.ImageRectOffset
    end
    if typeof(asset.ImageRectSize) == "Vector2" then
        image.ImageRectSize = asset.ImageRectSize
    end

    return true
end

local function makeText(parent, text, size, color, font, align)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text or "",
        TextSize = size or 14,
        TextColor3 = color or Color3.new(1, 1, 1),
        Font = font or Enum.Font.Gotham,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = parent,
    })
end

local function hookPressScale(button, scaleObject, glowObject)
    local pressed = false

    local function down(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        pressed = true
        tween(scaleObject, 0.11, { Scale = 1.055 }, Enum.EasingStyle.Quad)
        if glowObject then
            tween(glowObject, 0.11, { BackgroundTransparency = 0.66 }, Enum.EasingStyle.Quad)
        end
    end

    local function up(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if not pressed then
            return
        end
        pressed = false
        tween(scaleObject, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
        if glowObject then
            tween(glowObject, 0.24, { BackgroundTransparency = 0.82 }, Enum.EasingStyle.Quint)
        end
    end

    button.InputBegan:Connect(down)
    button.InputEnded:Connect(up)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Blank = {}
Blank.__index = Blank

function Window:_resolveExternalImage(url)
    if type(url) ~= "string" or not url:match("^https?://") then
        return normalizeAsset(url)
    end

    local getcustomassetFn = getGlobal("getcustomasset") or getGlobal("getsynasset")
    local writefileFn = getGlobal("writefile")
    local isfileFn = getGlobal("isfile")
    local makefolderFn = getGlobal("makefolder")
    local isfolderFn = getGlobal("isfolder")

    if type(getcustomassetFn) ~= "function" or type(writefileFn) ~= "function" then
        -- Native Roblox only accepts web image URLs from approved domains.
        -- Returning the URL still lets approved Roblox URLs work.
        return url
    end

    local cleanUrl = url:match("^[^%?#]+") or url
    local extension = cleanUrl:match("%.([%a%d]+)$")
    extension = extension and extension:lower() or "png"
    if extension ~= "png" and extension ~= "jpg" and extension ~= "jpeg" and extension ~= "webp" then
        extension = "png"
    end

    local rootFolder = "CapsuleUI"
    local assetFolder = rootFolder .. "/assets"
    local folderReady = false

    if type(makefolderFn) == "function" then
        pcall(function()
            if type(isfolderFn) == "function" then
                if not isfolderFn(rootFolder) then
                    makefolderFn(rootFolder)
                end
                if not isfolderFn(assetFolder) then
                    makefolderFn(assetFolder)
                end
                folderReady = isfolderFn(assetFolder)
            else
                makefolderFn(rootFolder)
                makefolderFn(assetFolder)
                folderReady = true
            end
        end)
    end

    local filename = simpleHash(url) .. "." .. extension
    local path = folderReady and (assetFolder .. "/" .. filename) or ("CapsuleUI_" .. filename)
    local exists = false
    if type(isfileFn) == "function" then
        pcall(function()
            exists = isfileFn(path)
        end)
    end

    if not exists then
        local body
        local requestFn = getRequestFunction()

        if type(requestFn) == "function" then
            local okRequest, response = pcall(requestFn, {
                Url = url,
                Method = "GET",
            })
            if okRequest and type(response) == "table" then
                body = response.Body or response.body
            end
        end

        if type(body) ~= "string" then
            pcall(function()
                body = game:HttpGet(url)
            end)
        end

        if type(body) ~= "string" or #body == 0 then
            warn("[CapsuleUI] Could not fetch image: " .. url)
            return url
        end

        local okWrite, writeErr = pcall(writefileFn, path, body)
        if not okWrite then
            warn("[CapsuleUI] Could not cache image: " .. tostring(writeErr))
            return url
        end
    end

    local okAsset, customAsset = pcall(getcustomassetFn, path)
    if okAsset and type(customAsset) == "string" then
        return customAsset
    end

    return url
end

function Window:_getLucide(name, size)
    name = tostring(name or ""):lower():gsub("_", "-")
    if name == "" then
        return nil
    end

    local provider = self.Options.IconProvider
    if type(provider) == "function" then
        local ok, result = pcall(provider, name, size or 24)
        if ok and result ~= nil then
            return result
        end
    end

    local module = self.LucideModule
    if type(module) == "table" then
        if module[name] ~= nil then
            return module[name]
        end

        if type(module.GetAsset) == "function" then
            local ok, result = pcall(module.GetAsset, name, size or 24)
            if ok and result ~= nil then
                return result
            end
        end
    end

    if COMMON_LUCIDE[name] then
        return COMMON_LUCIDE[name]
    end

    if self.Options.AutoLoadLucide ~= false then
        if self._remoteLucide == nil and not self._triedRemoteLucide then
            self._triedRemoteLucide = true
            self._remoteLucide = tryLoadRemoteLucide()
        end
        if type(self._remoteLucide) == "table" then
            return self._remoteLucide[name]
        end
    end

    return nil
end

function Window:_setImage(image, source, options)
    options = options or {}
    if not image or not image:IsA("ImageLabel") and not image:IsA("ImageButton") then
        return
    end

    if source == nil or source == "" then
        image.Image = ""
        image.Visible = false
        return
    end

    image.Visible = true

    local spec = source
    local lucideName
    if type(spec) == "string" then
        if spec:match("^lucide:") then
            lucideName = spec:sub(8)
        elseif not looksLikeImageUri(spec) and not spec:match("^%d+$") then
            lucideName = spec
        end
    end

    if lucideName then
        local asset = self:_getLucide(lucideName, options.Size or 24)
        if asset and applyLucideAsset(image, asset) then
            image.ImageColor3 = options.Color or self.Theme.Text
            return
        end
    end

    if type(spec) == "table" then
        if applyLucideAsset(image, spec) then
            if options.Color then
                image.ImageColor3 = options.Color
            end
            return
        end
    end

    local resolved = normalizeAsset(spec)
    if type(resolved) == "string" and resolved:match("^https?://") then
        resolved = self:_resolveExternalImage(resolved)
    end

    local ok, err = pcall(function()
        image.Image = resolved
        if options.Color then
            image.ImageColor3 = options.Color
        end
    end)
    if not ok then
        warn("[CapsuleUI] Invalid image source: " .. tostring(err))
    end
end

function Window:_makeIcon(parent, spec, size, color)
    local image = create("ImageLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(size or 20, size or 20),
        ImageColor3 = color or self.Theme.Text,
        ScaleType = Enum.ScaleType.Fit,
        Parent = parent,
    })
    self:_setImage(image, spec, {
        Size = size or 20,
        Color = color or self.Theme.Text,
    })
    return image
end

function Window:_buildCapsule()
    local theme = self.Theme

    local holder = create("Frame", {
        Name = "CapsuleHolder",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 18),
        Size = UDim2.fromOffset(240, 58),
        BackgroundTransparency = 1,
        ZIndex = 60,
        Parent = self.Gui,
    })

    local glow = create("Frame", {
        Name = "BodyGlow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(226, 50),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        ZIndex = 60,
        Parent = holder,
    })
    corner(glow, 25)

    local capsule = create("TextButton", {
        Name = "Capsule",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(218, 44),
        BackgroundColor3 = Color3.fromRGB(14, 14, 15),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 61,
        Parent = holder,
    })
    corner(capsule, 22)

    local capsuleScale = create("UIScale", {
        Scale = 1,
        Parent = capsule,
    })

    local iconBox = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(29, 29, 31),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(28, 28),
        ZIndex = 62,
        Parent = capsule,
    })
    corner(iconBox, 9)

    local icon = self:_makeIcon(iconBox, self.Options.CapsuleIcon or self.Options.Icon or "image", 17, theme.Text)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.ZIndex = 63

    local title = makeText(
        capsule,
        self.Options.CapsuleTitle or self.Options.Title or "Capsule",
        13,
        theme.Text,
        Enum.Font.GothamMedium
    )
    title.Position = UDim2.fromOffset(47, 0)
    title.Size = UDim2.new(1, -58, 1, 0)
    title.ZIndex = 63

    hookPressScale(capsule, capsuleScale, glow)

    capsule.MouseEnter:Connect(function()
        tween(glow, 0.18, { BackgroundTransparency = 0.75 })
        tween(capsule, 0.18, { BackgroundColor3 = Color3.fromRGB(18, 18, 20) })
    end)
    capsule.MouseLeave:Connect(function()
        tween(glow, 0.18, { BackgroundTransparency = 0.82 })
        tween(capsule, 0.18, { BackgroundColor3 = Color3.fromRGB(14, 14, 15) })
    end)

    capsule.Activated:Connect(function()
        self:Toggle()
    end)

    self.Capsule = capsule
    self.CapsuleTitle = title
    self.CapsuleIcon = icon
    self.CapsuleGlow = glow
end

function Window:_buildWindow()
    local theme = self.Theme
    local width = self.Options.Width or 640
    local height = self.Options.Height or 400

    local scrim = create("Frame", {
        Name = "Scrim",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Backdrop,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Active = false,
        ZIndex = 20,
        Parent = self.Gui,
    })

    local group = create("CanvasGroup", {
        Name = "WindowGroup",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 30,
        Parent = self.Gui,
    })

    local groupScale = create("UIScale", {
        Scale = 1,
        Parent = group,
    })

    local shadow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 18, 1, 18),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.52,
        BorderSizePixel = 0,
        ZIndex = 30,
        Parent = group,
    })
    corner(shadow, 22)

    local main = create("Frame", {
        Name = "MainWindow",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Window,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 31,
        Parent = group,
    })
    corner(main, 18)
    stroke(main, theme.Border, 0.55, 1)

    local rail = create("Frame", {
        Name = "TabRail",
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.new(0, 48, 1, -20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 33,
        Parent = main,
    })

    local profileShell = create("Frame", {
        Name = "Profile",
        Size = UDim2.fromOffset(42, 42),
        Position = UDim2.fromOffset(3, 2),
        BackgroundColor3 = theme.Surface2,
        BorderSizePixel = 0,
        ZIndex = 34,
        Parent = rail,
    })
    corner(profileShell, 21)
    stroke(profileShell, theme.Border, 0.45, 1)

    local avatar = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(38, 38),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 35,
        Parent = profileShell,
    })
    corner(avatar, 19)

    if LocalPlayer then
        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size150x150
                )
            end)
            if ok and avatar.Parent then
                avatar.Image = image
            end
        end)
    end

    local separator = create("Frame", {
        Position = UDim2.fromOffset(8, 55),
        Size = UDim2.fromOffset(32, 1),
        BackgroundColor3 = theme.Border,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 34,
        Parent = rail,
    })

    local tabButtons = create("Frame", {
        Name = "TabButtons",
        Position = UDim2.fromOffset(3, 66),
        Size = UDim2.new(0, 42, 1, -69),
        BackgroundTransparency = 1,
        ZIndex = 34,
        Parent = rail,
    })
    local tabLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 9),
        Parent = tabButtons,
    })

    local header = create("Frame", {
        Name = "Header",
        Position = UDim2.fromOffset(68, 10),
        Size = UDim2.new(1, -78, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 33,
        Parent = main,
    })

    local title = makeText(
        header,
        self.Options.Title or "Dashboard",
        16,
        theme.Text,
        Enum.Font.GothamMedium
    )
    title.Position = UDim2.fromOffset(2, 0)
    title.Size = UDim2.new(1, -52, 1, 0)
    title.ZIndex = 34

    local close = create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = theme.Surface2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 35,
        Parent = header,
    })
    corner(close, 17)
    stroke(close, theme.Border, 0.45, 1)

    local closeIcon = self:_makeIcon(close, "circle-x", 18, theme.Muted)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Position = UDim2.fromScale(0.5, 0.5)
    closeIcon.ZIndex = 36

    close.MouseEnter:Connect(function()
        tween(close, 0.16, { BackgroundColor3 = theme.Surface3 })
        tween(closeIcon, 0.16, { ImageColor3 = theme.Text })
    end)
    close.MouseLeave:Connect(function()
        tween(close, 0.16, { BackgroundColor3 = theme.Surface2 })
        tween(closeIcon, 0.16, { ImageColor3 = theme.Muted })
    end)
    close.Activated:Connect(function()
        self:Close()
    end)

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(68, 56),
        Size = UDim2.new(1, -78, 1, -66),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 33,
        Parent = main,
    })

    local blur = create("BlurEffect", {
        Name = "CapsuleUIBlur_" .. HttpService:GenerateGUID(false),
        Size = 0,
        Enabled = false,
        Parent = Lighting,
    })

    self.Scrim = scrim
    self.Group = group
    self.GroupScale = groupScale
    self.Main = main
    self.Rail = rail
    self.TabButtons = tabButtons
    self.Content = content
    self.WindowTitle = title
    self.CloseButton = close
    self.Blur = blur

    -- Smooth drag from the header, supports mouse and touch.
    local dragging = false
    local dragStart
    local startPosition
    local activeInput

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = group.Position
            activeInput = input
        end
    end)

    header.InputEnded:Connect(function(input)
        if input == activeInput then
            dragging = false
            activeInput = nil
        end
    end)

    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        group.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end))

    local function updateResponsiveScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local viewport = camera.ViewportSize
        local availableWidth = math.max(viewport.X - 24, 1)
        local availableHeight = math.max(viewport.Y - 96, 1)
        local scale = math.max(0.58, math.min(1, availableWidth / width, availableHeight / height))
        self._responsiveScale = scale
        if not self._transitioning then
            groupScale.Scale = scale
        end
    end

    updateResponsiveScale()
    if workspace.CurrentCamera then
        table.insert(self._connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))
    end
end

function Window:_buildNotifications()
    local holder = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.fromOffset(320, 360),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = self.Gui,
    })

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = holder,
    })

    self.NotificationHolder = holder
end

function Window:_newPage(tab)
    local page = create("ScrollingFrame", {
        Name = tab.Name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Faint,
        ScrollBarImageTransparency = 0.45,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        ZIndex = 34,
        Parent = self.Content,
    })
    padding(page, 2, 6, 6, 2)

    create("UIGridLayout", {
        CellSize = UDim2.new(0.5, -7, 0, self.Options.SectionHeight or 252),
        CellPadding = UDim2.fromOffset(10, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        FillDirectionMaxCells = 2,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    return page
end

function Window:_makeTabButton(tab, index)
    local theme = self.Theme
    local button = create("TextButton", {
        Name = tab.Name .. "Tab",
        Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = theme.Surface2,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = index,
        ZIndex = 35,
        Parent = self.TabButtons,
    })
    corner(button, 20)

    local icon = self:_makeIcon(button, tab.Icon or "house", 19, theme.Muted)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.ZIndex = 36

    local tooltip = create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(1, 9, 0.5, 0),
        Size = UDim2.fromOffset(0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(14, 14, 16),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = tab.Name,
        TextSize = 12,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        ZIndex = 90,
        Parent = button,
    })
    padding(tooltip, 0, 10, 0, 10)
    corner(tooltip, 8)

    button.MouseEnter:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.15, { BackgroundTransparency = 0.45 })
        end
        tooltip.Visible = true
    end)
    button.MouseLeave:Connect(function()
        if self.SelectedTab ~= tab then
            tween(button, 0.15, { BackgroundTransparency = 1 })
        end
        tooltip.Visible = false
    end)
    button.Activated:Connect(function()
        self:SelectTab(tab)
    end)

    tab.Button = button
    tab.ButtonIcon = icon
end

function Window:SelectTab(tab)
    if not tab or self.SelectedTab == tab then
        return
    end

    local previous = self.SelectedTab
    self.SelectedTab = tab

    if previous then
        previous.Page.Visible = false
        tween(previous.Button, 0.16, { BackgroundTransparency = 1 })
        tween(previous.ButtonIcon, 0.16, { ImageColor3 = self.Theme.Muted })
    end

    tab.Page.Visible = true
    tween(tab.Button, 0.16, {
        BackgroundTransparency = 0,
        BackgroundColor3 = self.Theme.Surface3,
    })
    tween(tab.ButtonIcon, 0.16, { ImageColor3 = self.Theme.Text })
end

function Window:CreateTab(options)
    options = options or {}
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Name = options.Name or options.Title or ("Tab " .. tostring(#self.Tabs + 1))
    tab.Icon = options.Icon or "house"
    tab.Sections = {}
    tab.Page = self:_newPage(tab)

    table.insert(self.Tabs, tab)
    self:_makeTabButton(tab, #self.Tabs)

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

local function createSectionBody(section, parent)
    local body = create("ScrollingFrame", {
        Name = "Body",
        Position = UDim2.fromOffset(10, 40),
        Size = UDim2.new(1, -20, 1, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = section.Window.Theme.Faint,
        ScrollBarImageTransparency = 0.55,
        ZIndex = 37,
        Parent = parent,
    })

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 7),
        Parent = body,
    })

    return body
end

function Tab:CreateSection(options)
    options = options or {}
    local window = self.Window
    local theme = window.Theme

    local root = create("Frame", {
        Name = (options.Title or "Section") .. "Section",
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = #self.Sections + 1,
        ZIndex = 35,
        Parent = self.Page,
    })
    corner(root, 14)
    stroke(root, theme.Border, 0.48, 1)

    local title = makeText(
        root,
        options.Title or "Section",
        13,
        theme.Text,
        Enum.Font.GothamMedium
    )
    title.Position = UDim2.fromOffset(12, 4)
    title.Size = UDim2.new(1, -24, 0, 34)
    title.ZIndex = 37

    local section = setmetatable({
        Window = window,
        Tab = self,
        Root = root,
        TitleLabel = title,
        Items = {},
    }, Section)

    section.Body = createSectionBody(section, root)
    table.insert(self.Sections, section)

    return section
end

function Tab:CreateBlank(options)
    options = options or {}
    local window = self.Window
    local theme = window.Theme
    local hasTitle = options.Title ~= nil and options.Title ~= ""

    local root = create("Frame", {
        Name = (options.Title or "Blank") .. "Blank",
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = #self.Sections + 1,
        ZIndex = 35,
        Parent = self.Page,
    })
    corner(root, 14)
    stroke(root, theme.Border, 0.48, 1)

    local backgroundImage
    if options.Image then
        backgroundImage = create("ImageLabel", {
            Name = "Image",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ImageTransparency = options.ImageTransparency or 0,
            ScaleType = options.ScaleType or Enum.ScaleType.Crop,
            ZIndex = 35,
            Parent = root,
        })
        window:_setImage(backgroundImage, options.Image)
    end

    local yOffset = 10
    if hasTitle then
        local title = makeText(root, options.Title, 13, theme.Text, Enum.Font.GothamMedium)
        title.Position = UDim2.fromOffset(12, 4)
        title.Size = UDim2.new(1, -24, 0, 34)
        title.ZIndex = 38
        yOffset = 40
    end

    local container = create("ScrollingFrame", {
        Name = "Container",
        Position = UDim2.fromOffset(10, yOffset),
        Size = UDim2.new(1, -20, 1, -(yOffset + 10)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Faint,
        ScrollBarImageTransparency = 0.55,
        ZIndex = 37,
        Parent = root,
    })

    local blank = setmetatable({
        Window = window,
        Tab = self,
        Root = root,
        Container = container,
        Image = backgroundImage,
    }, Blank)

    table.insert(self.Sections, blank)

    if type(options.Builder) == "function" then
        safeCall(options.Builder, container, blank)
    end

    return blank
end

function Blank:Add(instance)
    assert(typeof(instance) == "Instance", "Blank:Add expects a Roblox Instance")
    instance.Parent = self.Container
    return instance
end

function Blank:SetImage(source)
    if not self.Image then
        self.Image = create("ImageLabel", {
            Name = "Image",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 35,
            Parent = self.Root,
        })
        self.Image.Parent = self.Root
    end
    self.Window:_setImage(self.Image, source)
end

local function createFeatureShell(section, name, height)
    local frame = create("Frame", {
        Name = name,
        Size = UDim2.new(1, -2, 0, height),
        BackgroundColor3 = section.Window.Theme.Surface2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 38,
        Parent = section.Body,
    })
    corner(frame, 10)
    return frame
end

function Section:CreateToggle(options)
    options = options or {}
    local theme = self.Window.Theme
    local state = options.Default == true

    local root = createFeatureShell(self, options.Title or "Toggle", options.Description and 58 or 48)
    root.Active = true

    local title = makeText(root, options.Title or "Toggle", 12, theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(11, 5)
    title.Size = UDim2.new(1, -62, 0, options.Description and 24 or 38)
    title.ZIndex = 39

    if options.Description then
        local description = makeText(root, options.Description, 10, theme.Muted, Enum.Font.Gotham)
        description.Position = UDim2.fromOffset(11, 27)
        description.Size = UDim2.new(1, -62, 0, 22)
        description.ZIndex = 39
    end

    local track = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(36, 20),
        BackgroundColor3 = theme.Surface3,
        BorderSizePixel = 0,
        ZIndex = 39,
        Parent = root,
    })
    corner(track, 10)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = theme.Muted,
        BorderSizePixel = 0,
        ZIndex = 40,
        Parent = track,
    })
    corner(knob, 7)

    local click = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 41,
        Parent = root,
    })

    local control = {}

    local function render(animated)
        local duration = animated and 0.16 or 0
        if state then
            tween(track, duration, { BackgroundColor3 = theme.Accent })
            tween(knob, duration, {
                Position = UDim2.new(1, -10, 0.5, 0),
                BackgroundColor3 = theme.AccentText,
            })
        else
            tween(track, duration, { BackgroundColor3 = theme.Surface3 })
            tween(knob, duration, {
                Position = UDim2.new(0, 10, 0.5, 0),
                BackgroundColor3 = theme.Muted,
            })
        end
    end

    function control:Set(value, fire)
        state = value == true
        render(true)
        if fire ~= false then
            safeCall(options.Callback, state)
        end
    end

    function control:Get()
        return state
    end

    click.Activated:Connect(function()
        control:Set(not state, true)
    end)

    render(false)
    table.insert(self.Items, control)
    return control
end

local function createDropdown(section, options, multi)
    options = options or {}
    local theme = section.Window.Theme
    local values = copyTable(options.Values or options.Options or {})
    local open = false
    local selected
    local selectedSet = {}

    if multi then
        if type(options.Default) == "table" then
            for _, value in ipairs(options.Default) do
                selectedSet[tostring(value)] = true
            end
        end
    else
        selected = options.Default
        if selected == nil and options.AllowEmpty ~= true then
            selected = values[1]
        end
    end

    local root = createFeatureShell(section, options.Title or (multi and "Multi Dropdown" or "Dropdown"), 48)

    local title = makeText(root, options.Title or (multi and "Multi Dropdown" or "Dropdown"), 11, theme.Muted, Enum.Font.Gotham)
    title.Position = UDim2.fromOffset(11, 4)
    title.Size = UDim2.new(0.45, -6, 0, 40)
    title.ZIndex = 39

    local selectedLabel = makeText(root, "", 11, theme.Text, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
    selectedLabel.Position = UDim2.new(0.43, 0, 0, 4)
    selectedLabel.Size = UDim2.new(0.57, -40, 0, 40)
    selectedLabel.ZIndex = 39

    local arrow = section.Window:_makeIcon(root, "chevron-down", 16, theme.Muted)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -11, 0, 24)
    arrow.ZIndex = 40

    local headerButton = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 41,
        Parent = root,
    })

    local listFrame = create("Frame", {
        Position = UDim2.fromOffset(7, 48),
        Size = UDim2.new(1, -14, 0, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 42,
        Parent = root,
    })
    corner(listFrame, 8)

    local list = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Faint,
        ScrollBarImageTransparency = 0.5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 43,
        Parent = listFrame,
    })
    padding(list, 5, 5, 5, 5)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = list,
    })

    local optionRows = {}
    local control = {}

    local function summary()
        if multi then
            local picked = {}
            for _, value in ipairs(values) do
                if selectedSet[tostring(value)] then
                    table.insert(picked, tostring(value))
                end
            end
            if #picked == 0 then
                return options.Placeholder or "None"
            elseif #picked <= 2 then
                return table.concat(picked, ", ")
            else
                return tostring(#picked) .. " selected"
            end
        end
        return selected ~= nil and tostring(selected) or (options.Placeholder or "Select")
    end

    local function refreshRows()
        selectedLabel.Text = summary()
        for _, data in ipairs(optionRows) do
            local isSelected
            if multi then
                isSelected = selectedSet[tostring(data.Value)] == true
            else
                isSelected = tostring(selected) == tostring(data.Value)
            end
            tween(data.Row, 0.12, {
                BackgroundTransparency = isSelected and 0.15 or 1,
                BackgroundColor3 = theme.Surface3,
            })
            tween(data.Label, 0.12, {
                TextColor3 = isSelected and theme.Text or theme.Muted,
            })
        end
    end

    local function setOpen(value)
        open = value == true
        local listHeight = math.min(#values * 32 + 10, 138)
        local targetHeight = open and (48 + listHeight + 6) or 48
        tween(root, 0.18, { Size = UDim2.new(1, -2, 0, targetHeight) })
        tween(listFrame, 0.18, { Size = UDim2.new(1, -14, 0, open and listHeight or 0) })
        tween(arrow, 0.18, { Rotation = open and 180 or 0 })
    end

    local function rebuildRows()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        table.clear(optionRows)

        for index, value in ipairs(values) do
            local row = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = theme.Surface3,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                LayoutOrder = index,
                ZIndex = 44,
                Parent = list,
            })
            corner(row, 7)

            local label = makeText(row, tostring(value), 11, theme.Muted, Enum.Font.Gotham)
            label.Position = UDim2.fromOffset(8, 0)
            label.Size = UDim2.new(1, -16, 1, 0)
            label.ZIndex = 45

            row.MouseEnter:Connect(function()
                if row.BackgroundTransparency > 0.2 then
                    tween(row, 0.12, { BackgroundTransparency = 0.55 })
                end
            end)
            row.MouseLeave:Connect(refreshRows)

            row.Activated:Connect(function()
                if multi then
                    local key = tostring(value)
                    selectedSet[key] = not selectedSet[key]
                    refreshRows()
                    safeCall(options.Callback, control:Get())
                else
                    selected = value
                    refreshRows()
                    setOpen(false)
                    safeCall(options.Callback, selected)
                end
            end)

            table.insert(optionRows, {
                Row = row,
                Label = label,
                Value = value,
            })
        end

        refreshRows()
    end

    function control:Get()
        if multi then
            local result = {}
            for _, value in ipairs(values) do
                if selectedSet[tostring(value)] then
                    table.insert(result, value)
                end
            end
            return result
        end
        return selected
    end

    function control:Set(value, fire)
        if multi then
            table.clear(selectedSet)
            if type(value) == "table" then
                for _, item in ipairs(value) do
                    selectedSet[tostring(item)] = true
                end
            end
        else
            selected = value
        end
        refreshRows()
        if fire ~= false then
            safeCall(options.Callback, control:Get())
        end
    end

    function control:SetValues(newValues)
        values = copyTable(newValues or {})
        rebuildRows()
        if open then
            setOpen(true)
        end
    end

    function control:Open()
        setOpen(true)
    end

    function control:Close()
        setOpen(false)
    end

    headerButton.Activated:Connect(function()
        setOpen(not open)
    end)

    rebuildRows()
    return control
end

function Section:CreateDropdown(options)
    local control = createDropdown(self, options, false)
    table.insert(self.Items, control)
    return control
end

function Section:CreateMultiDropdown(options)
    local control = createDropdown(self, options, true)
    table.insert(self.Items, control)
    return control
end

function Section:CreateParagraph(options)
    options = options or {}
    local window = self.Window
    local theme = window.Theme
    local height = options.Height or (options.Image and 88 or 76)
    local root = createFeatureShell(self, options.Title or "Paragraph", height)

    local x = 11
    local image
    if options.Image then
        image = create("ImageLabel", {
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(48, 48),
            BackgroundColor3 = theme.Surface3,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            ScaleType = options.ScaleType or Enum.ScaleType.Crop,
            ZIndex = 39,
            Parent = root,
        })
        corner(image, options.ImageCornerRadius or 9)
        window:_setImage(image, options.Image)
        x = 69
    end

    local title = makeText(root, options.Title or "Paragraph", 12, theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(x, 7)
    title.Size = UDim2.new(1, -(x + 10), 0, 22)
    title.ZIndex = 39

    local body = create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, 29),
        Size = UDim2.new(1, -(x + 10), 1, -36),
        Text = options.Content or options.Text or "",
        TextSize = 10,
        TextColor3 = theme.Muted,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = options.RichText == true,
        ZIndex = 39,
        Parent = root,
    })

    local custom = create("Frame", {
        Name = "Custom",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 40,
        Parent = root,
    })

    local control = {
        Root = root,
        Container = custom,
        Image = image,
    }

    function control:SetText(text)
        body.Text = tostring(text or "")
    end

    function control:SetTitle(text)
        title.Text = tostring(text or "")
    end

    function control:SetImage(source)
        if not image then
            image = create("ImageLabel", {
                Position = UDim2.fromOffset(10, 10),
                Size = UDim2.fromOffset(48, 48),
                BackgroundColor3 = theme.Surface3,
                BorderSizePixel = 0,
                ScaleType = Enum.ScaleType.Crop,
                ZIndex = 39,
                Parent = root,
            })
            corner(image, 9)
            control.Image = image
        end
        window:_setImage(image, source)
    end

    function control:Add(instance)
        assert(typeof(instance) == "Instance", "Paragraph:Add expects a Roblox Instance")
        instance.Parent = custom
        return instance
    end

    if type(options.Builder) == "function" then
        safeCall(options.Builder, custom, control)
    end

    table.insert(self.Items, control)
    return control
end

function Section:CreateSlider(options)
    options = options or {}
    local theme = self.Window.Theme
    local minimum = tonumber(options.Min) or 0
    local maximum = tonumber(options.Max) or 100
    local step = tonumber(options.Step) or 1
    local value = tonumber(options.Default) or minimum

    if maximum <= minimum then
        maximum = minimum + 1
    end
    if step <= 0 then
        step = 1
    end

    local root = createFeatureShell(self, options.Title or "Slider", 66)

    local title = makeText(root, options.Title or "Slider", 12, theme.Text, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(11, 4)
    title.Size = UDim2.new(1, -80, 0, 28)
    title.ZIndex = 39

    local valueLabel = makeText(root, "", 11, theme.Muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
    valueLabel.Position = UDim2.new(1, -70, 0, 4)
    valueLabel.Size = UDim2.fromOffset(59, 28)
    valueLabel.ZIndex = 39

    local rail = create("Frame", {
        Position = UDim2.fromOffset(11, 43),
        Size = UDim2.new(1, -22, 0, 5),
        BackgroundColor3 = theme.Surface3,
        BorderSizePixel = 0,
        ZIndex = 39,
        Parent = root,
    })
    corner(rail, 3)

    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 40,
        Parent = rail,
    })
    corner(fill, 3)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 41,
        Parent = rail,
    })
    corner(knob, 6)

    local hitbox = create("TextButton", {
        Position = UDim2.new(0, -4, 0, -8),
        Size = UDim2.new(1, 8, 1, 16),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 42,
        Parent = rail,
    })

    local control = {}
    local dragging = false

    local function roundToStep(raw)
        local stepped = math.floor(((raw - minimum) / step) + 0.5) * step + minimum
        local decimalPlaces = 0
        local stepString = tostring(step)
        local decimals = stepString:match("%.(%d+)")
        if decimals then
            decimalPlaces = #decimals
        end
        local factor = 10 ^ decimalPlaces
        return math.floor(stepped * factor + 0.5) / factor
    end

    local function render(animated)
        value = math.clamp(value, minimum, maximum)
        local alpha = (value - minimum) / (maximum - minimum)
        valueLabel.Text = (options.Prefix or "") .. tostring(value) .. (options.Suffix or "")
        local duration = animated and 0.08 or 0
        tween(fill, duration, { Size = UDim2.fromScale(alpha, 1) }, Enum.EasingStyle.Linear)
        tween(knob, duration, { Position = UDim2.fromScale(alpha, 0.5) }, Enum.EasingStyle.Linear)
    end

    local function setFromX(x, fire)
        local alpha = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
        local raw = minimum + (maximum - minimum) * alpha
        local nextValue = roundToStep(raw)
        if nextValue == value then
            return
        end
        value = nextValue
        render(false)
        if fire ~= false then
            safeCall(options.Callback, value)
        end
    end

    function control:Set(nextValue, fire)
        value = roundToStep(tonumber(nextValue) or minimum)
        value = math.clamp(value, minimum, maximum)
        render(true)
        if fire ~= false then
            safeCall(options.Callback, value)
        end
    end

    function control:Get()
        return value
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X, true)
        end
    end)

    hitbox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(self.Window._connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X, true)
        end
    end))

    value = roundToStep(value)
    render(false)
    table.insert(self.Items, control)
    return control
end

-- Friendly aliases.
Section.Toggle = Section.CreateToggle
Section.Dropdown = Section.CreateDropdown
Section.MultiDropdown = Section.CreateMultiDropdown
Section.Paragraph = Section.CreateParagraph
Section.Slider = Section.CreateSlider
Tab.Section = Tab.CreateSection
Tab.Blank = Tab.CreateBlank

function Window:Notify(options)
    if type(options) == "string" then
        options = { Content = options }
    end
    options = options or {}

    local theme = self.Theme
    local duration = math.max(tonumber(options.Duration) or 3, 0.6)

    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, options.Height or 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.NotificationHolder,
    })

    local card = create("CanvasGroup", {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 101,
        Parent = holder,
    })
    corner(card, 12)
    stroke(card, theme.Border, 0.5, 1)
    padding(card, 9, 12, 9, 12)

    local title = makeText(card, options.Title or "Notification", 12, theme.Text, Enum.Font.GothamMedium)
    title.Size = UDim2.new(1, 0, 0, 22)
    title.ZIndex = 102

    local content = create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 23),
        Size = UDim2.new(1, 0, 1, -23),
        Text = options.Content or options.Text or "",
        TextSize = 10,
        TextColor3 = theme.Muted,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 102,
        Parent = card,
    })

    tween(card, 0.2, {
        Position = UDim2.fromOffset(0, 0),
        GroupTransparency = 0,
    })

    task.delay(duration, function()
        if not card.Parent then
            return
        end
        local outTween = tween(card, 0.22, {
            Position = UDim2.fromOffset(14, 0),
            GroupTransparency = 1,
        })
        outTween.Completed:Connect(function()
            if holder then
                holder:Destroy()
            end
        end)
    end)

    return card
end

function Window:Open()
    if self.Destroyed or self.Opened or self._transitioning then
        return
    end
    self._transitioning = true
    self.Opened = true

    self.Blur.Enabled = true
    self.Scrim.Visible = true
    self.Group.Visible = true
    self.Scrim.BackgroundTransparency = 1
    local baseScale = self._responsiveScale or 1
    self.Group.GroupTransparency = 1
    self.GroupScale.Scale = baseScale * 0.975

    tween(self.Scrim, 0.24, { BackgroundTransparency = 0.74 })
    tween(self.Blur, 0.28, { Size = self.Options.BlurSize or 12 })
    tween(self.GroupScale, 0.26, { Scale = baseScale }, Enum.EasingStyle.Back)
    local fade = tween(self.Group, 0.22, { GroupTransparency = 0 })
    fade.Completed:Connect(function()
        self._transitioning = false
    end)
end

function Window:Close()
    if self.Destroyed or not self.Opened or self._transitioning then
        return
    end
    self._transitioning = true
    self.Opened = false

    local baseScale = self._responsiveScale or 1
    tween(self.Scrim, 0.2, { BackgroundTransparency = 1 })
    tween(self.Blur, 0.22, { Size = 0 })
    tween(self.GroupScale, 0.2, { Scale = baseScale * 0.985 })
    local fade = tween(self.Group, 0.18, { GroupTransparency = 1 })
    fade.Completed:Connect(function()
        if self.Destroyed then
            return
        end
        self.Group.Visible = false
        self.Scrim.Visible = false
        self.Blur.Enabled = false
        self._transitioning = false
    end)
end

function Window:Toggle()
    if self.Opened then
        self:Close()
    else
        self:Open()
    end
end

function Window:SetTitle(text)
    self.WindowTitle.Text = tostring(text or "")
end

function Window:SetCapsuleTitle(text)
    self.CapsuleTitle.Text = tostring(text or "")
end

function Window:SetCapsuleIcon(source)
    self:_setImage(self.CapsuleIcon, source, {
        Size = 17,
        Color = self.Theme.Text,
    })
end

function Window:Destroy()
    if self.Destroyed then
        return
    end
    self.Destroyed = true

    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(self._connections)

    if self.Blur then
        self.Blur:Destroy()
    end
    if self.Gui then
        self.Gui:Destroy()
    end
end

function CapsuleUI:CreateWindow(options)
    options = options or {}

    local gui = create("ScreenGui", {
        Name = options.Name or ("CapsuleUI_" .. HttpService:GenerateGUID(false)),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = options.DisplayOrder or 50,
        Parent = options.Parent or getGuiParent(),
    })

    local window = setmetatable({
        Options = options,
        Theme = mergeTheme(options.Theme),
        Gui = gui,
        Tabs = {},
        SelectedTab = nil,
        Opened = false,
        Destroyed = false,
        _transitioning = false,
        _connections = {},
        _remoteLucide = nil,
        _triedRemoteLucide = false,
        LucideModule = options.LucideModule,
    }, Window)

    window:_buildCapsule()
    window:_buildWindow()
    window:_buildNotifications()

    CapsuleUI._lastWindow = window

    if options.OpenOnStart ~= false then
        task.defer(function()
            if not window.Destroyed then
                window:Open()
            end
        end)
    end

    return window
end

function CapsuleUI:Notify(options)
    if self._lastWindow then
        return self._lastWindow:Notify(options)
    end
    warn("[CapsuleUI] Create a window before calling CapsuleUI:Notify().")
end

return CapsuleUI
