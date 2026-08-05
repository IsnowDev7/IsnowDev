--[[
	Isnow UI Library v4
	Premium Roblox UI — liquid toggle, section anim, tab fade,
	clean notify, key system, tags, background image support
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats")

local Library = {
	Flags = {},
	Windows = {},
	Theme = {
		Background = Color3.fromRGB(16, 16, 20),
		Secondary  = Color3.fromRGB(22, 22, 28),
		Tertiary   = Color3.fromRGB(32, 32, 40),
		Accent     = Color3.fromRGB(88, 130, 255),
		Text       = Color3.fromRGB(240, 240, 245),
		TextDark   = Color3.fromRGB(140, 140, 155),
		Stroke     = Color3.fromRGB(48, 48, 60),
		Success    = Color3.fromRGB(48, 190, 85),
		Error      = Color3.fromRGB(240, 70, 60),
		Warning    = Color3.fromRGB(245, 160, 20),
		ToggleOn   = Color3.fromRGB(48, 190, 85),
		ToggleOff  = Color3.fromRGB(70, 70, 78),
	},
}

local function Protect(gui)
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = CoreGui
	elseif gethui then
		gui.Parent = gethui()
	else
		gui.Parent = CoreGui
	end
end

local function Tween(obj, props, dur, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(dur or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function Create(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			i[k] = v
		end
	end
	if props and props.Parent then
		i.Parent = props.Parent
	end
	return i
end

local function Corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = inst
	return c
end

local function Stroke(inst, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or Library.Theme.Stroke
	s.Thickness = thick or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function Pad(inst, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.Parent = inst
	return p
end

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, start, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			start = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - start
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
end

local function ResolveImage(src)
	if not src or src == "" then
		return "rbxassetid://0"
	end
	src = tostring(src)
	if src:match("^%d+$") then
		return "rbxassetid://" .. src
	end
	if src:match("^rbxassetid://") or src:match("^rbxthumb://") or src:match("^rbxasset://") then
		return src
	end
	if src:match("^https?://") then
		return src
	end
	return src
end

function Library:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "Isnow UI"
	local subtitle = opts.Subtitle or ""
	local size = opts.Size or UDim2.new(0, 580, 0, 440)
	local sidebarWidth = opts.SidebarWidth or 168
	local minSize = opts.MinSize or Vector2.new(400, 300)
	local iconId = ResolveImage(opts.Icon or "rbxassetid://7733960981")
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	local acrylic = opts.Acrylic ~= false
	local transparency = opts.Transparency or 0
	local footerText = opts.Footer or "Isnow UI"
	local bgImage = opts.Background -- rbxasset / http / number

	local ScreenGui = Create("ScreenGui", {
		Name = "IsnowUI_" .. HttpService:GenerateGUID(false):sub(1, 8),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	Protect(ScreenGui)

	local Dim = Create("Frame", {
		Name = "Dim",
		Parent = ScreenGui,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 80,
	})

	local Main = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = Library.Theme.Background,
		BackgroundTransparency = math.clamp(0.04 + transparency, 0, 0.55),
		BorderSizePixel = 0,
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		ClipsDescendants = true,
		ZIndex = 2,
	})
	Corner(Main, 14)
	Stroke(Main, Color3.fromRGB(255, 255, 255), 1, acrylic and 0.88 or 0.55)

	-- Optional background image
	if bgImage and bgImage ~= "" then
		Create("ImageLabel", {
			Name = "BGImage",
			Parent = Main,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Image = ResolveImage(bgImage),
			ImageTransparency = 0.55,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 1,
		})
	end

	Create("ImageLabel", {
		Name = "Shadow",
		Parent = Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -20, 0, -20),
		Size = UDim2.new(1, 40, 1, 40),
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = 0,
	})

	-- TOP BAR
	local TopBar = Create("Frame", {
		Name = "TopBar",
		Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.25 or 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		ZIndex = 10,
	})
	Corner(TopBar, 14)
	Create("Frame", {
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.25 or 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, -16),
		ZIndex = 10,
	})

	Create("ImageLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(0, 14, 0.5, -11),
		Image = iconId,
		ImageColor3 = Library.Theme.Accent,
		ZIndex = 11,
	})

	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -190, 0, 18),
		Position = UDim2.new(0, 44, 0, 8),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Library.Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})
	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -190, 0, 14),
		Position = UDim2.new(0, 44, 0, 26),
		Font = Enum.Font.Gotham,
		Text = subtitle,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	local TagBar = Create("Frame", {
		Name = "TagBar",
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 220, 0, 20),
		Position = UDim2.new(1, -220, 0, 5),
		ZIndex = 12,
	})
	Create("UIListLayout", {
		Parent = TagBar,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 5),
	})

	-- Close × (no frame)
	local CloseBtn = Create("TextButton", {
		Name = "Close",
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -38, 0.5, -14),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 20,
		AutoButtonColor = false,
		ZIndex = 13,
	})
	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, { TextColor3 = Library.Theme.Error }, 0.12)
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, { TextColor3 = Library.Theme.TextDark }, 0.12)
	end)

	-- Minimize − (no frame)
	local MinBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -66, 0.5, -14),
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 20,
		AutoButtonColor = false,
		ZIndex = 13,
	})
	MinBtn.MouseEnter:Connect(function()
		Tween(MinBtn, { TextColor3 = Library.Theme.Accent }, 0.12)
	end)
	MinBtn.MouseLeave:Connect(function()
		Tween(MinBtn, { TextColor3 = Library.Theme.TextDark }, 0.12)
	end)

	-- Floating restore capsule
	local Capsule = Create("TextButton", {
		Name = "RestoreCapsule",
		Parent = ScreenGui,
		BackgroundColor3 = Library.Theme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 150, 0, 36),
		Position = UDim2.new(0.5, -75, 0, 18),
		Text = "",
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 60,
	})
	Corner(Capsule, 18)
	Stroke(Capsule, Library.Theme.Accent, 1, 0.35)
	Create("ImageLabel", {
		Parent = Capsule,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 12, 0.5, -8),
		Image = iconId,
		ImageColor3 = Library.Theme.Accent,
		ZIndex = 61,
	})
	Create("TextLabel", {
		Parent = Capsule,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -36, 1, 0),
		Position = UDim2.new(0, 32, 0, 0),
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = Library.Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 61,
	})
	MakeDraggable(Capsule, Capsule)

	-- SIDEBAR
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.2 or 0,
		BorderSizePixel = 0,
		Size = UDim2.new(0, sidebarWidth, 1, -48 - 28),
		Position = UDim2.new(0, 0, 0, 48),
		ZIndex = 5,
	})
	Create("Frame", {
		Parent = Sidebar,
		BackgroundColor3 = Library.Theme.Stroke,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		ZIndex = 6,
	})

	local TabList = Create("ScrollingFrame", {
		Name = "TabList",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -6),
		Position = UDim2.new(0, 0, 0, 4),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Library.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 6,
	})
	Pad(TabList, 4, 6, 8, 8)
	Create("UIListLayout", {
		Parent = TabList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
	})

	local Content = Create("Frame", {
		Name = "Content",
		Parent = Main,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -sidebarWidth, 1, -48 - 28),
		Position = UDim2.new(0, sidebarWidth, 0, 48),
		ClipsDescendants = true,
		ZIndex = 5,
	})
	local Pages = Create("Folder", { Name = "Pages", Parent = Content })

	-- FOOTER
	local Footer = Create("Frame", {
		Name = "Footer",
		Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.25 or 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 1, -28),
		ZIndex = 10,
	})
	local FooterLabel = Create("TextLabel", {
		Parent = Footer,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Font = Enum.Font.Gotham,
		Text = footerText,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	-- Resize grip (+)
	local Grip = Create("TextButton", {
		Name = "ResizeGrip",
		Parent = Main,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(1, -20, 1, -20),
		Text = "+",
		Font = Enum.Font.GothamBold,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 14,
		ZIndex = 50,
		AutoButtonColor = false,
	})
	local resizing, rStart, rSize
	Grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			rStart = input.Position
			rSize = Main.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - rStart
			Main.Size = UDim2.new(
				0, math.max(minSize.X, rSize.X + d.X),
				0, math.max(minSize.Y, rSize.Y + d.Y)
			)
		end
	end)

	MakeDraggable(Main, TopBar)

	local Window = {
		ScreenGui = ScreenGui,
		Main = Main,
		Tabs = {},
		CurrentTab = nil,
		Visible = true,
		SidebarWidth = sidebarWidth,
		Tags = {},
	}

	function Window:SetSidebarWidth(w)
		sidebarWidth = w
		Window.SidebarWidth = w
		Tween(Sidebar, { Size = UDim2.new(0, w, 1, -48 - 28) }, 0.25)
		Tween(Content, {
			Size = UDim2.new(1, -w, 1, -48 - 28),
			Position = UDim2.new(0, w, 0, 48),
		}, 0.25)
	end

	-- Close with fade
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(Main, { BackgroundTransparency = 1 }, 0.2)
		for _, c in ipairs(Main:GetDescendants()) do
			if c:IsA("GuiObject") and c.BackgroundTransparency < 1 then
				Tween(c, { BackgroundTransparency = 1 }, 0.18)
			end
			if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
				Tween(c, { TextTransparency = 1 }, 0.18)
			end
			if c:IsA("ImageLabel") or c:IsA("ImageButton") then
				Tween(c, { ImageTransparency = 1 }, 0.18)
			end
		end
		task.delay(0.22, function()
			ScreenGui:Destroy()
		end)
	end)

	-- Minimize with proper fade out / fade in
	local function MinimizeWindow()
		Tween(Main, { BackgroundTransparency = 1 }, 0.2)
		for _, c in ipairs(Main:GetDescendants()) do
			if c:IsA("GuiObject") and c.BackgroundTransparency < 1 then
				Tween(c, { BackgroundTransparency = 1 }, 0.18)
			end
			if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
				Tween(c, { TextTransparency = 1 }, 0.18)
			end
			if c:IsA("ImageLabel") or c:IsA("ImageButton") then
				Tween(c, { ImageTransparency = 1 }, 0.18)
			end
		end
		task.delay(0.22, function()
			Main.Visible = false
			Capsule.Visible = true
			Capsule.BackgroundTransparency = 1
			Capsule.Size = UDim2.new(0, 0, 0, 36)
			Tween(Capsule, {
				BackgroundTransparency = 0.1,
				Size = UDim2.new(0, 150, 0, 36),
			}, 0.25, Enum.EasingStyle.Back)
		end)
	end

	local function RestoreWindow()
		Capsule.Visible = false
		Main.Visible = true
		Main.BackgroundTransparency = 1
		-- restore children
		for _, c in ipairs(Main:GetDescendants()) do
			if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
				c.TextTransparency = 1
				Tween(c, { TextTransparency = 0 }, 0.22)
			end
			if c:IsA("ImageLabel") or c:IsA("ImageButton") then
				local target = c.Name == "Shadow" and 0.45 or (c.Name == "BGImage" and 0.55 or 0)
				c.ImageTransparency = 1
				Tween(c, { ImageTransparency = target }, 0.22)
			end
		end
		Tween(Main, {
			BackgroundTransparency = math.clamp(0.04 + transparency, 0, 0.55),
		}, 0.25)
	end

	MinBtn.MouseButton1Click:Connect(MinimizeWindow)
	Capsule.MouseButton1Click:Connect(RestoreWindow)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then
			return
		end
		if input.KeyCode == toggleKey then
			if Main.Visible then
				MinimizeWindow()
			else
				RestoreWindow()
			end
		end
	end)

	-- ========== TAG ==========
	function Window:AddTag(cfg)
		cfg = cfg or {}
		local tTitle = cfg.Title or cfg.Name or "Tag"
		local tColor = cfg.Color or Library.Theme.Accent
		if typeof(tColor) == "string" then
			local map = {
				Blue = Color3.fromRGB(88, 130, 255),
				Green = Color3.fromRGB(48, 190, 85),
				Red = Color3.fromRGB(240, 70, 60),
				Orange = Color3.fromRGB(245, 160, 20),
				Purple = Color3.fromRGB(160, 100, 255),
				Pink = Color3.fromRGB(255, 100, 160),
				White = Color3.fromRGB(230, 230, 240),
			}
			tColor = map[tColor] or Library.Theme.Accent
		end
		local rainbow = cfg.Rainbow or false

		local Tag = Create("Frame", {
			Parent = TagBar,
			BackgroundColor3 = tColor,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 13,
		})
		Corner(Tag, 9)
		Pad(Tag, 0, 0, 8, 8)
		Tag.BackgroundTransparency = 0.12

		local TLabel = Create("TextLabel", {
			Parent = Tag,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.GothamMedium,
			Text = tTitle,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 10,
			ZIndex = 14,
		})

		local rainConn
		if rainbow then
			local h = 0
			rainConn = RunService.RenderStepped:Connect(function(dt)
				h = (h + dt * 0.4) % 1
				Tag.BackgroundColor3 = Color3.fromHSV(h, 0.7, 1)
			end)
		end

		local api = {
			Frame = Tag,
			SetTitle = function(_, v)
				TLabel.Text = tostring(v)
			end,
			SetColor = function(_, c)
				if rainConn then
					rainConn:Disconnect()
					rainConn = nil
				end
				if typeof(c) == "string" then
					local map = {
						Blue = Color3.fromRGB(88, 130, 255),
						Green = Color3.fromRGB(48, 190, 85),
						Red = Color3.fromRGB(240, 70, 60),
						Orange = Color3.fromRGB(245, 160, 20),
						Purple = Color3.fromRGB(160, 100, 255),
					}
					c = map[c] or Library.Theme.Accent
				end
				Tag.BackgroundColor3 = c
			end,
			SetRainbow = function(_, on)
				if on and not rainConn then
					local h = 0
					rainConn = RunService.RenderStepped:Connect(function(dt)
						h = (h + dt * 0.4) % 1
						Tag.BackgroundColor3 = Color3.fromHSV(h, 0.7, 1)
					end)
				elseif not on and rainConn then
					rainConn:Disconnect()
					rainConn = nil
				end
			end,
			Destroy = function()
				if rainConn then
					rainConn:Disconnect()
				end
				Tag:Destroy()
			end,
		}
		table.insert(Window.Tags, api)
		return api
	end

	-- ========== NOTIFY (clean, premium) ==========
	local notifyStack = {}

	function Window:Notify(title, content, duration, nType)
		duration = duration or 3
		nType = nType or "Info"

		local col = Library.Theme.Accent
		if nType == "Success" then
			col = Library.Theme.Success
		elseif nType == "Error" then
			col = Library.Theme.Error
		elseif nType == "Warning" then
			col = Library.Theme.Warning
		end

		local N = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Color3.fromRGB(20, 20, 26),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 270, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(1, 20, 1, -20),
			ZIndex = 95,
			ClipsDescendants = true,
		})
		Corner(N, 10)
		Stroke(N, col, 1.5, 0.35)
		Pad(N, 12, 12, 14, 14)

		-- left accent bar
		Create("Frame", {
			Parent = N,
			BackgroundColor3 = col,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 96,
		})

		Create("TextLabel", {
			Parent = N,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 16),
			Position = UDim2.new(0, 8, 0, 0),
			Font = Enum.Font.GothamBold,
			Text = tostring(title or "Notify"),
			TextColor3 = Library.Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 96,
		})
		Create("TextLabel", {
			Parent = N,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 0),
			Position = UDim2.new(0, 8, 0, 18),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = tostring(content or ""),
			TextColor3 = Library.Theme.TextDark,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 96,
		})

		-- progress line
		local bar = Create("Frame", {
			Parent = N,
			BackgroundColor3 = col,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			ZIndex = 97,
		})

		table.insert(notifyStack, N)
		local idx = #notifyStack
		local yOff = 20
		for i = 1, idx - 1 do
			if notifyStack[i] and notifyStack[i].Parent then
				yOff = yOff + (notifyStack[i].AbsoluteSize.Y + 10)
			end
		end

		N.Position = UDim2.new(1, 20, 1, -yOff - 70)
		Tween(N, { Position = UDim2.new(1, -290, 1, -yOff - 70) }, 0.35, Enum.EasingStyle.Back)
		Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

		task.delay(duration, function()
			if not N.Parent then
				return
			end
			Tween(N, { Position = UDim2.new(1, 20, N.Position.Y.Scale, N.Position.Y.Offset) }, 0.22)
			task.delay(0.25, function()
				N:Destroy()
				for i, v in ipairs(notifyStack) do
					if v == N then
						table.remove(notifyStack, i)
						break
					end
				end
			end)
		end)
	end

	-- ========== DIALOG ==========
	function Window:Dialog(cfg)
		cfg = cfg or {}
		local dTitle = cfg.Title or "Confirm"
		local dText = cfg.Text or cfg.Content or ""
		local dInput = cfg.Input
		local buttons = cfg.Buttons
			or {
				{ Text = "OK", Color = Library.Theme.Success, Callback = function() end },
				{ Text = "Cancel", Color = Library.Theme.Error, Callback = function() end },
			}

		Dim.Visible = true
		Dim.BackgroundTransparency = 1
		Tween(Dim, { BackgroundTransparency = 0.45 }, 0.2)

		local D = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Color3.fromRGB(22, 22, 28),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 300, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(0.5, -150, 0.5, -60),
			ZIndex = 85,
		})
		Corner(D, 12)
		Stroke(D, Library.Theme.Stroke, 1, 0.3)
		Pad(D, 16, 16, 16, 16)

		D.BackgroundTransparency = 1
		Tween(D, { BackgroundTransparency = 0 }, 0.2)

		Create("TextLabel", {
			Parent = D,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = dTitle,
			TextColor3 = Library.Theme.Text,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 86,
		})
		Create("TextLabel", {
			Parent = D,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 26),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = dText,
			TextColor3 = Library.Theme.TextDark,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 86,
		})

		local inputBox
		local yOff = 54
		if dInput then
			inputBox = Create("TextBox", {
				Parent = D,
				BackgroundColor3 = Library.Theme.Background,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 32),
				Position = UDim2.new(0, 0, 0, yOff),
				Font = Enum.Font.Gotham,
				Text = dInput.Default or "",
				PlaceholderText = dInput.Placeholder or "...",
				PlaceholderColor3 = Library.Theme.TextDark,
				TextColor3 = Library.Theme.Text,
				TextSize = 12,
				ClearTextOnFocus = false,
				ZIndex = 86,
			})
			Corner(inputBox, 7)
			Pad(inputBox, 0, 0, 10, 10)
			Stroke(inputBox, Library.Theme.Stroke, 1, 0.4)
			yOff = yOff + 42
		end

		local BtnRow = Create("Frame", {
			Parent = D,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			Position = UDim2.new(0, 0, 0, yOff),
			ZIndex = 86,
		})
		Create("UIListLayout", {
			Parent = BtnRow,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
		})

		local function CloseDialog()
			Tween(Dim, { BackgroundTransparency = 1 }, 0.15)
			Tween(D, { BackgroundTransparency = 1 }, 0.15)
			task.delay(0.18, function()
				Dim.Visible = false
				D:Destroy()
			end)
		end

		for _, b in ipairs(buttons) do
			local B = Create("TextButton", {
				Parent = BtnRow,
				BackgroundColor3 = b.Color or Library.Theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 78, 0, 30),
				Text = b.Text or "OK",
				Font = Enum.Font.GothamMedium,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 12,
				AutoButtonColor = false,
				ZIndex = 87,
			})
			Corner(B, 7)
			B.MouseEnter:Connect(function()
				Tween(B, { BackgroundTransparency = 0.15 }, 0.1)
			end)
			B.MouseLeave:Connect(function()
				Tween(B, { BackgroundTransparency = 0 }, 0.1)
			end)
			B.MouseButton1Click:Connect(function()
				local val = inputBox and inputBox.Text or nil
				CloseDialog()
				if b.Callback then
					b.Callback(val)
				end
			end)
		end
	end

	-- ========== INTRO LOADER ==========
	function Window:IntroLoader(cfg)
		cfg = cfg or {}
		local duration = cfg.Duration or 2.2
		local loadText = cfg.Text or "Loading..."
		local logo = ResolveImage(cfg.Logo or iconId)

		Main.Visible = false
		Sidebar.Position = UDim2.new(0, -sidebarWidth, 0, 48)

		local Intro = Create("Frame", {
			Name = "Intro",
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Background,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 300, 0, 150),
			Position = UDim2.new(0.5, -150, 0.5, -75),
			ZIndex = 100,
		})
		Corner(Intro, 14)
		Stroke(Intro, Library.Theme.Stroke, 1, 0.3)

		Create("ImageLabel", {
			Parent = Intro,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 38, 0, 38),
			Position = UDim2.new(0.5, -19, 0, 18),
			Image = logo,
			ImageColor3 = Library.Theme.Accent,
			ZIndex = 101,
		})
		Create("TextLabel", {
			Parent = Intro,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 18),
			Position = UDim2.new(0, 10, 0, 64),
			Font = Enum.Font.GothamMedium,
			Text = loadText,
			TextColor3 = Library.Theme.Text,
			TextSize = 13,
			ZIndex = 101,
		})

		local Track = Create("Frame", {
			Parent = Intro,
			BackgroundColor3 = Library.Theme.Tertiary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -40, 0, 5),
			Position = UDim2.new(0, 20, 0, 100),
			ZIndex = 101,
		})
		Corner(Track, 3)
		local Fill = Create("Frame", {
			Parent = Track,
			BackgroundColor3 = Library.Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = 102,
		})
		Corner(Fill, 3)
		local Pct = Create("TextLabel", {
			Parent = Intro,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, 0, 0, 114),
			Font = Enum.Font.Gotham,
			Text = "0%",
			TextColor3 = Library.Theme.TextDark,
			TextSize = 11,
			ZIndex = 101,
		})

		Intro.BackgroundTransparency = 1
		Tween(Intro, { BackgroundTransparency = 0 }, 0.28)

		local start = tick()
		local conn
		conn = RunService.RenderStepped:Connect(function()
			local p = math.clamp((tick() - start) / duration, 0, 1)
			Fill.Size = UDim2.new(p, 0, 1, 0)
			Pct.Text = math.floor(p * 100) .. "%"
			if p >= 1 then
				conn:Disconnect()
				Tween(Intro, { BackgroundTransparency = 1 }, 0.28)
				task.delay(0.3, function()
					Intro:Destroy()
					Main.Visible = true
					Main.BackgroundTransparency = 1
					Tween(Main, {
						BackgroundTransparency = math.clamp(0.04 + transparency, 0, 0.55),
					}, 0.3)
					Sidebar.Position = UDim2.new(0, -sidebarWidth, 0, 48)
					Tween(Sidebar, { Position = UDim2.new(0, 0, 0, 48) }, 0.4, Enum.EasingStyle.Quart)
				end)
			end
		end)
	end

	-- ========== KEY SYSTEM ==========
	function Window:KeySystem(cfg)
		cfg = cfg or {}
		local keys = cfg.Keys or { "TEST-KEY-123" }
		local sources = cfg.Sources or { "Discord", "Linkvertise", "Work.ink", "Direct" }
		local onSuccess = cfg.OnSuccess or function() end
		local titleText = cfg.Title or "Key System"
		local note = cfg.Note or "Enter your key to continue"

		Main.Visible = false

		local KS = Create("Frame", {
			Name = "KeySystem",
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Background,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 340, 0, 250),
			Position = UDim2.new(0.5, -170, 0.5, -125),
			ZIndex = 100,
		})
		Corner(KS, 14)
		Stroke(KS, Library.Theme.Stroke, 1, 0.3)
		Pad(KS, 18, 18, 18, 18)

		Create("TextLabel", {
			Parent = KS,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Font = Enum.Font.GothamBold,
			Text = titleText,
			TextColor3 = Library.Theme.Text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 101,
		})
		Create("TextLabel", {
			Parent = KS,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, 26),
			Font = Enum.Font.Gotham,
			Text = note,
			TextColor3 = Library.Theme.TextDark,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 101,
		})

		-- Source dropdown
		local sourceVal = sources[1]
		local srcOpen = false
		local SrcFrame = Create("Frame", {
			Parent = KS,
			BackgroundColor3 = Library.Theme.Tertiary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 34),
			Position = UDim2.new(0, 0, 0, 52),
			ZIndex = 102,
			ClipsDescendants = true,
		})
		Corner(SrcFrame, 8)

		local SrcBtn = Create("TextButton", {
			Parent = SrcFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
			Text = "",
			ZIndex = 103,
		})
		local SrcLabel = Create("TextLabel", {
			Parent = SrcBtn,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			Font = Enum.Font.Gotham,
			Text = "Source: " .. sourceVal,
			TextColor3 = Library.Theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 104,
		})
		local SrcArrow = Create("TextLabel", {
			Parent = SrcBtn,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 20, 1, 0),
			Position = UDim2.new(1, -24, 0, 0),
			Font = Enum.Font.GothamBold,
			Text = "↓",
			TextColor3 = Library.Theme.TextDark,
			TextSize = 12,
			ZIndex = 104,
		})

		local SrcList = Create("Frame", {
			Parent = SrcFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, #sources * 28),
			Position = UDim2.new(0, 0, 0, 34),
			ZIndex = 103,
		})
		Create("UIListLayout", {
			Parent = SrcList,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0),
		})

		for _, s in ipairs(sources) do
			local opt = Create("TextButton", {
				Parent = SrcList,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				Text = "  " .. s,
				Font = Enum.Font.Gotham,
				TextColor3 = Library.Theme.TextDark,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				ZIndex = 104,
			})
			opt.MouseEnter:Connect(function()
				opt.TextColor3 = Library.Theme.Text
			end)
			opt.MouseLeave:Connect(function()
				opt.TextColor3 = Library.Theme.TextDark
			end)
			opt.MouseButton1Click:Connect(function()
				sourceVal = s
				SrcLabel.Text = "Source: " .. s
				srcOpen = false
				Tween(SrcFrame, { Size = UDim2.new(1, 0, 0, 34) }, 0.18)
				SrcArrow.Text = "↓"
			end)
		end

		SrcBtn.MouseButton1Click:Connect(function()
			srcOpen = not srcOpen
			local h = srcOpen and (34 + #sources * 28) or 34
			Tween(SrcFrame, { Size = UDim2.new(1, 0, 0, h) }, 0.2)
			SrcArrow.Text = srcOpen and "↑" or "↓"
		end)

		-- Key input
		local KeyBox = Create("TextBox", {
			Parent = KS,
			BackgroundColor3 = Library.Theme.Tertiary,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 34),
			Position = UDim2.new(0, 0, 0, 96),
			Font = Enum.Font.Gotham,
			Text = "",
			PlaceholderText = "Enter key...",
			PlaceholderColor3 = Library.Theme.TextDark,
			TextColor3 = Library.Theme.Text,
			TextSize = 13,
			ClearTextOnFocus = false,
			ZIndex = 101,
		})
		Corner(KeyBox, 8)
		Pad(KeyBox, 0, 0, 12, 12)

		local Status = Create("TextLabel", {
			Parent = KS,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Position = UDim2.new(0, 0, 0, 138),
			Font = Enum.Font.Gotham,
			Text = "",
			TextColor3 = Library.Theme.Error,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 101,
		})

		local Submit = Create("TextButton", {
			Parent = KS,
			BackgroundColor3 = Library.Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 36),
			Position = UDim2.new(0, 0, 0, 162),
			Text = "Submit",
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 101,
		})
		Corner(Submit, 8)

		Submit.MouseEnter:Connect(function()
			Tween(Submit, { BackgroundTransparency = 0.12 }, 0.1)
		end)
		Submit.MouseLeave:Connect(function()
			Tween(Submit, { BackgroundTransparency = 0 }, 0.1)
		end)

		local function tryKey()
			local input = KeyBox.Text:gsub("%s+", "")
			local ok = false
			for _, k in ipairs(keys) do
				if input == k then
					ok = true
					break
				end
			end
			if ok then
				Status.TextColor3 = Library.Theme.Success
				Status.Text = "Key accepted"
				Tween(KS, { BackgroundTransparency = 1 }, 0.25)
				task.delay(0.3, function()
					KS:Destroy()
					Main.Visible = true
					Main.BackgroundTransparency = 1
					Tween(Main, {
						BackgroundTransparency = math.clamp(0.04 + transparency, 0, 0.55),
					}, 0.3)
					onSuccess(sourceVal)
				end)
			else
				Status.TextColor3 = Library.Theme.Error
				Status.Text = "Invalid key"
				Tween(KeyBox, { BackgroundColor3 = Library.Theme.Error }, 0.1)
				task.delay(0.35, function()
					Tween(KeyBox, { BackgroundColor3 = Library.Theme.Tertiary }, 0.2)
				end)
			end
		end

		Submit.MouseButton1Click:Connect(tryKey)
		KeyBox.FocusLost:Connect(function(enter)
			if enter then
				tryKey()
			end
		end)
	end

	-- ========== STATS WIDGET ==========
	function Window:CreateStatsWidget(cfg)
		cfg = cfg or {}
		local pos = cfg.Position or UDim2.new(0, 14, 0, 14)

		local W = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 110, 0, 44),
			Position = pos,
			ZIndex = 70,
		})
		Corner(W, 10)
		Stroke(W, Library.Theme.Stroke, 1, 0.4)
		MakeDraggable(W, W)

		local fpsLbl = Create("TextLabel", {
			Parent = W,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 18),
			Position = UDim2.new(0, 8, 0, 4),
			Font = Enum.Font.GothamMedium,
			Text = "FPS  --",
			TextColor3 = Library.Theme.Text,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 71,
		})
		local msLbl = Create("TextLabel", {
			Parent = W,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 16),
			Position = UDim2.new(0, 8, 0, 22),
			Font = Enum.Font.Gotham,
			Text = "MS   --",
			TextColor3 = Library.Theme.TextDark,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 71,
		})

		local frames, last = 0, tick()
		RunService.RenderStepped:Connect(function()
			frames = frames + 1
			if tick() - last >= 1 then
				fpsLbl.Text = "FPS  " .. frames
				local ping = 0
				pcall(function()
					ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
				end)
				msLbl.Text = "MS   " .. ping
				frames = 0
				last = tick()
			end
		end)

		return W
	end

	-- ========== TABS ==========
	function Window:CreateTab(name, icon)
		local tabIcon = ResolveImage(icon or "")

		local TabBtn = Create("TextButton", {
			Parent = TabList,
			BackgroundColor3 = Library.Theme.Tertiary,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 34),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 7,
		})
		Corner(TabBtn, 8)

		if tabIcon ~= "rbxassetid://0" and tabIcon ~= "" then
			Create("ImageLabel", {
				Parent = TabBtn,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 10, 0.5, -8),
				Image = tabIcon,
				ImageColor3 = Library.Theme.TextDark,
				ZIndex = 8,
			})
		end

		local TabLabel = Create("TextLabel", {
			Parent = TabBtn,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -36, 1, 0),
			Position = UDim2.new(0, tabIcon ~= "rbxassetid://0" and tabIcon ~= "" and 32 or 12, 0, 0),
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = Library.Theme.TextDark,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8,
		})

		local Page = Create("ScrollingFrame", {
			Name = name,
			Parent = Pages,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Library.Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 6,
		})
		Pad(Page, 10, 12, 12, 12)
		Create("UIListLayout", {
			Parent = Page,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		})

		local Tab = {
			Name = name,
			Button = TabBtn,
			Page = Page,
			Sections = {},
		}

		local function Select()
			if Window.CurrentTab == Tab then
				return
			end

			-- fade out old
			if Window.CurrentTab then
				local old = Window.CurrentTab
				old.Button.BackgroundTransparency = 1
				old.Label.TextColor3 = Library.Theme.TextDark
				if old.Icon then
					old.Icon.ImageColor3 = Library.Theme.TextDark
				end
				Tween(old.Page, { GroupTransparency = 1 }, 0.15)
				task.delay(0.15, function()
					old.Page.Visible = false
					old.Page.GroupTransparency = 0
				end)
			end

			Window.CurrentTab = Tab
			TabBtn.BackgroundTransparency = 0.35
			TabLabel.TextColor3 = Library.Theme.Text
			Page.Visible = true
			Page.GroupTransparency = 1
			Tween(Page, { GroupTransparency = 0 }, 0.22)
		end

		Tab.Label = TabLabel
		Tab.Select = Select

		TabBtn.MouseButton1Click:Connect(Select)
		TabBtn.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then
				Tween(TabBtn, { BackgroundTransparency = 0.6 }, 0.12)
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then
				Tween(TabBtn, { BackgroundTransparency = 1 }, 0.12)
			end
		end)

		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then
			Select()
		end

		-- ========== SECTION ==========
		function Tab:CreateSection(sectionName)
			local open = true

			local Wrap = Create("Frame", {
				Parent = Page,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 7,
			})

			-- Header (name outside + arrow)
			local Header = Create("TextButton", {
				Parent = Wrap,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 22),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 8,
			})

			local Arrow = Create("TextLabel", {
				Parent = Header,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 16, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Font = Enum.Font.GothamBold,
				Text = "↓",
				TextColor3 = Library.Theme.TextDark,
				TextSize = 12,
				ZIndex = 9,
			})

			Create("TextLabel", {
				Parent = Header,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -22, 1, 0),
				Position = UDim2.new(0, 18, 0, 0),
				Font = Enum.Font.GothamBold,
				Text = sectionName or "Section",
				TextColor3 = Library.Theme.TextDark,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 9,
			})

			-- Card body
			local Card = Create("Frame", {
				Parent = Wrap,
				BackgroundColor3 = Library.Theme.Secondary,
				BackgroundTransparency = acrylic and 0.15 or 0,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 24),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 8,
				ClipsDescendants = true,
			})
			Corner(Card, 10)
			Stroke(Card, Color3.fromRGB(255, 255, 255), 1, 0.9)

			local Body = Create("Frame", {
				Parent = Card,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 9,
			})
			Pad(Body, 8, 10, 10, 10)
			Create("UIListLayout", {
				Parent = Body,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6),
			})

			Header.MouseButton1Click:Connect(function()
				open = not open
				if open then
					Arrow.Text = "↓"
					Card.Visible = true
					Card.Size = UDim2.new(1, 0, 0, 0)
					-- animate open
					local target = Body.AbsoluteSize.Y + 18
					Tween(Card, { Size = UDim2.new(1, 0, 0, target) }, 0.25, Enum.EasingStyle.Quart)
					task.delay(0.26, function()
						if open then
							Card.AutomaticSize = Enum.AutomaticSize.Y
							Card.Size = UDim2.new(1, 0, 0, 0)
						end
					end)
				else
					Arrow.Text = "↑"
					Card.AutomaticSize = Enum.AutomaticSize.None
					local h = Card.AbsoluteSize.Y
					Card.Size = UDim2.new(1, 0, 0, h)
					Tween(Card, { Size = UDim2.new(1, 0, 0, 0) }, 0.22, Enum.EasingStyle.Quart)
					task.delay(0.23, function()
						if not open then
							Card.Visible = false
						end
					end)
				end
			end)

			local Section = { Frame = Wrap, Card = Card, Body = Body }

			-- ========== LIQUID GLASS TOGGLE ==========
			function Section:CreateToggle(o)
				o = o or {}
				local text = o.Name or o.Text or "Toggle"
				local default = o.Default or false
				local flag = o.Flag
				local cb = o.Callback or function() end
				local state = default
				if flag then
					Library.Flags[flag] = state
				end

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 34),
					ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -58, 1, 0),
					Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				-- Track
				local Track = Create("Frame", {
					Parent = Holder,
					BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 48, 0, 28),
					Position = UDim2.new(1, -52, 0.5, -14),
					ZIndex = 11,
				})
				Corner(Track, 14)
				Stroke(Track, Color3.fromRGB(255, 255, 255), 1, 0.85)

				-- Morph blob
				local Blob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 0.75,
					BorderSizePixel = 0,
					Size = state and UDim2.new(0, 28, 0, 28) or UDim2.new(0, 28, 0, 28),
					Position = state and UDim2.new(1, -28, 0, 0) or UDim2.new(0, 0, 0, 0),
					ZIndex = 12,
				})
				Corner(Blob, 14)

				-- Knob (liquid glass)
				local Knob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 0.05,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 24, 0, 24),
					Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
					ZIndex = 13,
				})
				Corner(Knob, 12)
				Stroke(Knob, Color3.fromRGB(255, 255, 255), 1, 0.6)

				local function Set(v, fire)
					state = v
					if flag then
						Library.Flags[flag] = state
					end

					local targetCol = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff
					Tween(Track, { BackgroundColor3 = targetCol }, 0.28)

					-- morph expand
					Tween(Blob, {
						Size = UDim2.new(0, 40, 0, 28),
						Position = state and UDim2.new(1, -40, 0, 0) or UDim2.new(0, 0, 0, 0),
						BackgroundTransparency = 0.55,
					}, 0.12)
					task.delay(0.12, function()
						Tween(Blob, {
							Size = UDim2.new(0, 28, 0, 28),
							Position = state and UDim2.new(1, -28, 0, 0) or UDim2.new(0, 0, 0, 0),
							BackgroundTransparency = 0.75,
						}, 0.18, Enum.EasingStyle.Back)
					end)

					Tween(Knob, {
						Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
					}, 0.26, Enum.EasingStyle.Quart)

					if fire ~= false then
						cb(state)
					end
				end

				-- drag knob
				local dragging
				Knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								dragging = false
								local mid = Track.AbsolutePosition.X + Track.AbsoluteSize.X / 2
								Set(UserInputService:GetMouseLocation().X > mid)
							end
						end)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging
						and (input.UserInputType == Enum.UserInputType.MouseMovement
							or input.UserInputType == Enum.UserInputType.Touch) then
						local rel = math.clamp(
							input.Position.X - Track.AbsolutePosition.X - 12,
							2,
							Track.AbsoluteSize.X - 26
						)
						Knob.Position = UDim2.new(0, rel, 0.5, -12)
					end
				end)

				local Click = Create("TextButton", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					ZIndex = 14,
				})
				Click.MouseButton1Click:Connect(function()
					Set(not state)
				end)

				return { Set = Set, Get = function() return state end, Frame = Holder }
			end

			-- ========== BUTTON ==========
			function Section:CreateButton(o)
				o = o or {}
				local text = o.Name or o.Text or "Button"
				local cb = o.Callback or function() end

				local Btn = Create("TextButton", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
					Text = "",
					AutoButtonColor = false,
					ZIndex = 10,
				})
				Corner(Btn, 8)
				Stroke(Btn, Color3.fromRGB(255, 255, 255), 1, 0.88)

				local BtnLabel = Create("TextLabel", {
					Parent = Btn,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -14, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				-- hold follow
				local holding
				Btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						holding = true
						Tween(Btn, {
							BackgroundColor3 = Library.Theme.Accent,
							Size = UDim2.new(1, -4, 0, 32),
						}, 0.1)
					end
				end)
				Btn.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						holding = false
						Tween(Btn, {
							BackgroundColor3 = Library.Theme.Tertiary,
							Size = UDim2.new(1, 0, 0, 34),
						}, 0.15)
					end
				end)
				Btn.MouseEnter:Connect(function()
					if not holding then
						Tween(Btn, { BackgroundColor3 = Color3.fromRGB(42, 42, 52) }, 0.12)
					end
				end)
				Btn.MouseLeave:Connect(function()
					if not holding then
						Tween(Btn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.12)
					end
				end)
				Btn.MouseButton1Click:Connect(cb)

				return Btn
			end

			-- ========== SLIDER (rewritten) ==========
			function Section:CreateSlider(o)
				o = o or {}
				local text = o.Name or o.Text or "Slider"
				local min = o.Min or 0
				local max = o.Max or 100
				local default = o.Default or min
				local flag = o.Flag
				local cb = o.Callback or function() end
				local decimals = o.Decimals or 0
				local value = default
				if flag then
					Library.Flags[flag] = value
				end

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 44),
					ZIndex = 10,
				})

				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -52, 0, 16),
					Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				local ValLbl = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 48, 0, 16),
					Position = UDim2.new(1, -50, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = tostring(value),
					TextColor3 = Library.Theme.Accent,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 11,
				})

				local Track = Create("Frame", {
					Parent = Holder,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0, 28),
					ZIndex = 11,
				})
				Corner(Track, 3)

				local Fill = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Library.Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new(math.clamp((value - min) / math.max(max - min, 1), 0, 1), 0, 1, 0),
					ZIndex = 12,
				})
				Corner(Fill, 3)

				local Knob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(
						math.clamp((value - min) / math.max(max - min, 1), 0, 1),
						-8,
						0.5,
						-8
					),
					ZIndex = 13,
				})
				Corner(Knob, 8)
				Stroke(Knob, Library.Theme.Accent, 2, 0.2)

				local function format(v)
					if decimals > 0 then
						return string.format("%." .. decimals .. "f", v)
					end
					return tostring(math.floor(v + 0.5))
				end

				local function Set(v, fire)
					value = math.clamp(v, min, max)
					if decimals == 0 then
						value = math.floor(value + 0.5)
					else
						local m = 10 ^ decimals
						value = math.floor(value * m + 0.5) / m
					end
					if flag then
						Library.Flags[flag] = value
					end
					local p = (value - min) / math.max(max - min, 1)
					Tween(Fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.08)
					Tween(Knob, { Position = UDim2.new(p, -8, 0.5, -8) }, 0.08)
					ValLbl.Text = format(value)
					if fire ~= false then
						cb(value)
					end
				end

				local sliding
				local function updateFromInput(input)
					local rel = math.clamp(
						(input.Position.X - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1),
						0,
						1
					)
					Set(min + rel * (max - min))
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						sliding = true
						updateFromInput(input)
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								sliding = false
							end
						end)
					end
				end)
				Knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						sliding = true
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								sliding = false
							end
						end)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if sliding
						and (input.UserInputType == Enum.UserInputType.MouseMovement
							or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(input)
					end
				end)

				return { Set = Set, Get = function() return value end, Frame = Holder }
			end

			-- ========== PROGRESS BAR ==========
			function Section:CreateProgressBar(o)
				o = o or {}
				local text = o.Name or o.Text or "Progress"
				local default = o.Default or 0

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 38),
					ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -42, 0, 14),
					Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})
				local Pct = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 38, 0, 14),
					Position = UDim2.new(1, -40, 0, 0),
					Font = Enum.Font.Gotham,
					Text = "0%",
					TextColor3 = Library.Theme.TextDark,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 11,
				})
				local Track = Create("Frame", {
					Parent = Holder,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0, 22),
					ZIndex = 11,
				})
				Corner(Track, 3)
				local Fill = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Library.Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
					ZIndex = 12,
				})
				Corner(Fill, 3)

				local function Set(v)
					v = math.clamp(v, 0, 100)
					Tween(Fill, { Size = UDim2.new(v / 100, 0, 1, 0) }, 0.15)
					Pct.Text = math.floor(v) .. "%"
				end
				Set(default)

				return { Set = Set, Frame = Holder }
			end

			-- ========== DROPDOWN / MULTI ==========
			function Section:CreateDropdown(o)
				o = o or {}
				local text = o.Name or o.Text or "Dropdown"
				local list = o.Options or o.List or {}
				local multi = o.Multi or false
				local default = o.Default
				local flag = o.Flag
				local cb = o.Callback or function() end

				local selected
				if multi then
					selected = {}
					if type(default) == "table" then
						for _, v in ipairs(default) do
							selected[v] = true
						end
					end
				else
					selected = default or list[1]
				end
				if flag then
					Library.Flags[flag] = multi and (function()
						local t = {}
						for k, v in pairs(selected) do
							if v then
								table.insert(t, k)
							end
						end
						return t
					end)() or selected
				end

				local open = false
				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
					ClipsDescendants = true,
					ZIndex = 10,
				})
				Corner(Holder, 8)
				Stroke(Holder, Color3.fromRGB(255, 255, 255), 1, 0.9)

				local ValLbl = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -36, 0, 34),
					Position = UDim2.new(0, 10, 0, 0),
					Font = Enum.Font.Gotham,
					Text = text .. ": " .. (multi and "..." or tostring(selected or "")),
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 11,
				})
				local Arrow = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 20, 0, 34),
					Position = UDim2.new(1, -26, 0, 0),
					Font = Enum.Font.GothamBold,
					Text = "↓",
					TextColor3 = Library.Theme.TextDark,
					TextSize = 12,
					ZIndex = 11,
				})

				local OptList = Create("Frame", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -8, 0, 0),
					Position = UDim2.new(0, 4, 0, 36),
					ZIndex = 12,
				})
				Create("UIListLayout", {
					Parent = OptList,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2),
				})

				local function UpdateVal()
					if multi then
						local t = {}
						for k, v in pairs(selected) do
							if v then
								table.insert(t, k)
							end
						end
						ValLbl.Text = text .. ": " .. (#t > 0 and table.concat(t, ", ") or "None")
						if flag then
							Library.Flags[flag] = t
						end
					else
						ValLbl.Text = text .. ": " .. tostring(selected or "")
						if flag then
							Library.Flags[flag] = selected
						end
					end
				end

				local function Build()
					for _, c in ipairs(OptList:GetChildren()) do
						if c:IsA("TextButton") then
							c:Destroy()
						end
					end
					for _, opt in ipairs(list) do
						local isSel = multi and selected[opt] or (selected == opt)
						local OB = Create("TextButton", {
							Parent = OptList,
							BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Background,
							BackgroundTransparency = isSel and 0.2 or 0.5,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 26),
							Text = "",
							AutoButtonColor = false,
							ZIndex = 13,
						})
						Corner(OB, 5)
						Create("TextLabel", {
							Parent = OB,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -10, 1, 0),
							Position = UDim2.new(0, 8, 0, 0),
							Font = Enum.Font.Gotham,
							Text = tostring(opt),
							TextColor3 = isSel and Color3.new(1, 1, 1) or Library.Theme.Text,
							TextSize = 11,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 14,
						})
						OB.MouseButton1Click:Connect(function()
							if multi then
								selected[opt] = not selected[opt]
								UpdateVal()
								local vals = {}
								for k, v in pairs(selected) do
									if v then
										table.insert(vals, k)
									end
								end
								cb(vals)
								Build()
							else
								selected = opt
								UpdateVal()
								cb(opt)
								open = false
								Tween(Holder, { Size = UDim2.new(1, 0, 0, 34) }, 0.2)
								Arrow.Text = "↓"
							end
						end)
					end
				end
				Build()
				UpdateVal()

				local Head = Create("TextButton", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 34),
					Text = "",
					ZIndex = 15,
				})
				Head.MouseButton1Click:Connect(function()
					open = not open
					local h = open and (34 + #list * 28 + 10) or 34
					Tween(Holder, { Size = UDim2.new(1, 0, 0, h) }, 0.22, Enum.EasingStyle.Quart)
					Arrow.Text = open and "↑" or "↓"
					if open then
						Build()
					end
				end)

				return {
					Set = function(v)
						if multi then
							selected = {}
							if type(v) == "table" then
								for _, x in ipairs(v) do
									selected[x] = true
								end
							end
						else
							selected = v
						end
						UpdateVal()
						Build()
					end,
					Get = function()
						if multi then
							local t = {}
							for k, v in pairs(selected) do
								if v then
									table.insert(t, k)
								end
							end
							return t
						end
						return selected
					end,
					Refresh = function(nl)
						list = nl or list
						Build()
					end,
					Frame = Holder,
				}
			end

			function Section:CreateMultiDropdown(o)
				o = o or {}
				o.Multi = true
				return Section:CreateDropdown(o)
			end

			-- ========== INPUT ==========
			function Section:CreateInput(o)
				o = o or {}
				local text = o.Name or o.Text or "Input"
				local placeholder = o.Placeholder or "..."
				local default = o.Default or ""
				local flag = o.Flag
				local cb = o.Callback or function() end

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 52),
					ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14),
					Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})
				local Box = Create("TextBox", {
					Parent = Holder,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32),
					Position = UDim2.new(0, 0, 0, 18),
					Font = Enum.Font.Gotham,
					Text = default,
					PlaceholderText = placeholder,
					PlaceholderColor3 = Library.Theme.TextDark,
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					ClearTextOnFocus = false,
					ZIndex = 11,
				})
				Corner(Box, 7)
				Pad(Box, 0, 0, 10, 10)
				Stroke(Box, Color3.fromRGB(255, 255, 255), 1, 0.9)

				Box.FocusLost:Connect(function()
					if flag then
						Library.Flags[flag] = Box.Text
					end
					cb(Box.Text)
				end)

				return {
					Set = function(v)
						Box.Text = tostring(v)
					end,
					Get = function()
						return Box.Text
					end,
					Frame = Holder,
				}
			end

			-- ========== PARAGRAPH ==========
			function Section:CreateParagraph(o)
				o = o or {}
				local title = o.Title or o.Name or ""
				local content = o.Content or o.Text or ""

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BackgroundTransparency = 0.4,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 10,
				})
				Corner(Holder, 8)
				Pad(Holder, 8, 8, 10, 10)

				if title ~= "" then
					Create("TextLabel", {
						Parent = Holder,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 16),
						Font = Enum.Font.GothamBold,
						Text = title,
						TextColor3 = Library.Theme.Text,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 11,
					})
				end
				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, title ~= "" and 18 or 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Font = Enum.Font.Gotham,
					Text = content,
					TextColor3 = Library.Theme.TextDark,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					ZIndex = 11,
				})

				return Holder
			end

			-- ========== LABEL ==========
			function Section:CreateLabel(o)
				o = o or {}
				local text = o.Text or o.Name or "Label"
				local col = o.Color or Library.Theme.TextDark

				local L = Create("TextLabel", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Font = Enum.Font.Gotham,
					Text = text,
					TextColor3 = col,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})
				return {
					Set = function(v)
						L.Text = tostring(v)
					end,
					SetColor = function(c)
						L.TextColor3 = c
					end,
					Frame = L,
				}
			end

			-- ========== IMAGE ==========
			function Section:CreateImage(o)
				o = o or {}
				local src = ResolveImage(o.Image or o.Src or "")
				local h = o.Height or 80

				local Img = Create("ImageLabel", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, h),
					Image = src,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 10,
				})
				Corner(Img, 8)
				return Img
			end

			-- ========== CUSTOM FRAME ==========
			function Section:CreateFrame(o)
				o = o or {}
				local h = o.Height or 60
				local F = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = o.Color or Library.Theme.Tertiary,
					BackgroundTransparency = o.Transparency or 0,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, h),
					ZIndex = 10,
				})
				Corner(F, o.Corner or 8)
				return F
			end

			table.insert(Tab.Sections, Section)
			return Section
		end

		return Tab
	end

	function Window:Destroy()
		ScreenGui:Destroy()
	end
	function Window:SetFooter(t)
		FooterLabel.Text = tostring(t)
	end

	table.insert(Library.Windows, Window)
	return Window
end

return Library
