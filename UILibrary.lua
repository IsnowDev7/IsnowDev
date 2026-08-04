--[[
	UI Library v2
	TopBar X, Sidebar width, Tabs, Collapsible Sections (name outside),
	Dropdown / MultiDropdown (▾ ▴), Toggle liquid glass + drag,
	Button liquid glass + hold-follow finger,
	Input, Paragraph, Label, Image, CustomFrame, Tag capsule,
	Acrylic, Transparency, Footer, Dialog, Notification,
	Floating restore capsule, FPS/MS draggable widget,
	Tab fade, Resizable (+)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local Library = {
	Flags = {},
	Windows = {},
	Theme = {
		Background = Color3.fromRGB(16, 16, 20),
		Secondary = Color3.fromRGB(24, 24, 30),
		Tertiary = Color3.fromRGB(34, 34, 42),
		Accent = Color3.fromRGB(100, 140, 255),
		Text = Color3.fromRGB(245, 245, 250),
		TextDark = Color3.fromRGB(145, 145, 160),
		Stroke = Color3.fromRGB(55, 55, 68),
		Success = Color3.fromRGB(70, 200, 120),
		Error = Color3.fromRGB(230, 70, 70),
		Warning = Color3.fromRGB(230, 180, 60),
		Glass = Color3.fromRGB(255, 255, 255),
		GlassTrans = 0.82,
		ToggleOff = Color3.fromRGB(50, 50, 60),
		ToggleOn = Color3.fromRGB(100, 140, 255),
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
	local t = TweenService:Create(obj, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Create(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then i[k] = v end
	end
	if props and props.Parent then i.Parent = props.Parent end
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

local function Gradient(inst, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1 or Library.Theme.Accent),
		ColorSequenceKeypoint.new(1, c2 or Color3.fromRGB(160, 100, 255)),
	})
	g.Rotation = rot or 45
	g.Parent = inst
	return g
end

local function ApplyGlass(inst, extraTrans)
	inst.BackgroundColor3 = Library.Theme.Glass
	inst.BackgroundTransparency = extraTrans or Library.Theme.GlassTrans
	Stroke(inst, Color3.fromRGB(255, 255, 255), 1.2, 0.55)
end

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, start, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			start = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - start
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

function Library:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "UI Library"
	local subtitle = opts.Subtitle or ""
	local size = opts.Size or UDim2.new(0, 580, 0, 440)
	local sidebarWidth = opts.SidebarWidth or 168
	local minSize = opts.MinSize or Vector2.new(400, 300)
	local iconId = opts.Icon or "rbxassetid://7733960981"
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	local acrylic = opts.Acrylic ~= false
	local transparency = opts.Transparency or 0
	local footerText = opts.Footer or "UI Library"

	local ScreenGui = Create("ScreenGui", {
		Name = "UILib_" .. HttpService:GenerateGUID(false):sub(1, 8),
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
		BackgroundTransparency = transparency,
		BorderSizePixel = 0,
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		ClipsDescendants = true,
		ZIndex = 2,
	})
	Corner(Main, 12)
	if acrylic then
		ApplyGlass(Main, 0.12 + transparency * 0.4)
		Main.BackgroundColor3 = Library.Theme.Background
		Main.BackgroundTransparency = math.clamp(0.08 + transparency, 0, 0.55)
	else
		Stroke(Main, Library.Theme.Stroke, 1)
	end

	Create("ImageLabel", {
		Name = "Shadow",
		Parent = Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -18, 0, -18),
		Size = UDim2.new(1, 36, 1, 36),
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5,
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
		Size = UDim2.new(1, 0, 0, 46),
		ZIndex = 10,
	})
	Corner(TopBar, 12)
	Create("Frame", {
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.25 or 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, -14),
		ZIndex = 10,
	})

	Create("ImageLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 24, 0, 24),
		Position = UDim2.new(0, 14, 0.5, -12),
		Image = iconId,
		ImageColor3 = Library.Theme.Accent,
		ZIndex = 11,
	})

	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -200, 0, 20),
		Position = UDim2.new(0, 46, 0, 6),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Library.Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -200, 0, 14),
		Position = UDim2.new(0, 46, 0, 26),
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
		Size = UDim2.new(0, 220, 0, 22),
		Position = UDim2.new(1, -220, 0, 4),
		ZIndex = 12,
	})
	Create("UIListLayout", {
		Parent = TagBar,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local CloseBtn = Create("TextButton", {
		Name = "Close",
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Tertiary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -38, 0.5, -14),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 13,
	})
	Corner(CloseBtn, 7)
	local CloseX = Create("TextLabel", {
		Parent = CloseBtn,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = Library.Theme.TextDark,
		TextSize = 18,
		ZIndex = 14,
	})
	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, { BackgroundColor3 = Library.Theme.Error }, 0.12)
		Tween(CloseX, { TextColor3 = Color3.new(1, 1, 1) }, 0.12)
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.12)
		Tween(CloseX, { TextColor3 = Library.Theme.TextDark }, 0.12)
	end)

	local MinBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Tertiary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -72, 0.5, -14),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 13,
	})
	Corner(MinBtn, 7)
	local MinIcon = Create("TextLabel", {
		Parent = MinBtn,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "−",
		TextColor3 = Library.Theme.TextDark,
		TextSize = 18,
		ZIndex = 14,
	})
	MinBtn.MouseEnter:Connect(function()
		Tween(MinBtn, { BackgroundColor3 = Library.Theme.Accent }, 0.12)
		Tween(MinIcon, { TextColor3 = Color3.new(1, 1, 1) }, 0.12)
	end)
	MinBtn.MouseLeave:Connect(function()
		Tween(MinBtn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.12)
		Tween(MinIcon, { TextColor3 = Library.Theme.TextDark }, 0.12)
	end)

	-- Floating restore capsule
	local Capsule = Create("TextButton", {
		Name = "RestoreCapsule",
		Parent = ScreenGui,
		BackgroundColor3 = Library.Theme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 148, 0, 38),
		Position = UDim2.new(0.5, -74, 0, 16),
		Text = "",
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 60,
	})
	Corner(Capsule, 19)
	if acrylic then ApplyGlass(Capsule, 0.35) end
	Stroke(Capsule, Library.Theme.Accent, 1.2, 0.25)
	Create("ImageLabel", {
		Parent = Capsule,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(0, 12, 0.5, -9),
		Image = iconId,
		ImageColor3 = Library.Theme.Accent,
		ZIndex = 61,
	})
	Create("TextLabel", {
		Parent = Capsule,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 34, 0, 0),
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = Library.Theme.Text,
		TextSize = 13,
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
		Size = UDim2.new(0, sidebarWidth, 1, -46 - 28),
		Position = UDim2.new(0, 0, 0, 46),
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
		Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.new(0, 0, 0, 6),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Library.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 6,
	})
	Pad(TabList, 4, 8, 8, 8)
	Create("UIListLayout", {
		Parent = TabList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})

	local Content = Create("Frame", {
		Name = "Content",
		Parent = Main,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -sidebarWidth, 1, -46 - 28),
		Position = UDim2.new(0, sidebarWidth, 0, 46),
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
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Font = Enum.Font.Gotham,
		Text = footerText,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	-- Resize +
	local Grip = Create("TextButton", {
		Name = "ResizeGrip",
		Parent = Main,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(1, -20, 1, -20),
		Text = "+",
		Font = Enum.Font.GothamBold,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 16,
		ZIndex = 50,
		AutoButtonColor = false,
	})
	local resizing, rStart, rSize
	Grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			rStart = input.Position
			rSize = Main.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then resizing = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - rStart
			Main.Size = UDim2.new(0, math.max(minSize.X, rSize.X + d.X), 0, math.max(minSize.Y, rSize.Y + d.Y))
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
		Tween(Sidebar, { Size = UDim2.new(0, w, 1, -46 - 28) }, 0.25)
		Tween(Content, {
			Size = UDim2.new(1, -w, 1, -46 - 28),
			Position = UDim2.new(0, w, 0, 46),
		}, 0.25)
	end

	CloseBtn.MouseButton1Click:Connect(function()
		Tween(Main, { BackgroundTransparency = 1 }, 0.22)
		task.delay(0.25, function() ScreenGui:Destroy() end)
	end)

	MinBtn.MouseButton1Click:Connect(function()
		Tween(Main, { BackgroundTransparency = 1 }, 0.18)
		task.delay(0.18, function()
			Main.Visible = false
			Capsule.Visible = true
			Capsule.BackgroundTransparency = 1
			Tween(Capsule, { BackgroundTransparency = acrylic and 0.35 or 0 }, 0.22)
		end)
	end)
	Capsule.MouseButton1Click:Connect(function()
		Capsule.Visible = false
		Main.Visible = true
		Main.BackgroundTransparency = 1
		Tween(Main, { BackgroundTransparency = transparency }, 0.22)
	end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then
			Window.Visible = not Window.Visible
			if Window.Visible then
				Main.Visible = true
				Capsule.Visible = false
				Main.BackgroundTransparency = 1
				Tween(Main, { BackgroundTransparency = transparency }, 0.22)
			else
				Tween(Main, { BackgroundTransparency = 1 }, 0.18)
				task.delay(0.18, function() Main.Visible = false end)
			end
		end
	end)

	-- TAG
	function Window:AddTag(cfg)
		cfg = cfg or {}
		local tTitle = cfg.Title or cfg.Name or "Tag"
		local tColor = cfg.Color or Library.Theme.Accent
		local rainbow = cfg.Rainbow or false
		local gradient = cfg.Gradient

		local Tag = Create("Frame", {
			Parent = TagBar,
			BackgroundColor3 = tColor,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 13,
		})
		Corner(Tag, 10)
		Pad(Tag, 0, 0, 8, 8)
		if acrylic then
			Tag.BackgroundTransparency = 0.2
			Stroke(Tag, Color3.new(1, 1, 1), 1, 0.55)
		end

		local TLabel = Create("TextLabel", {
			Parent = Tag,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.GothamMedium,
			Text = tTitle,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 11,
			ZIndex = 14,
		})

		local gradObj
		if gradient and type(gradient) == "table" then
			gradObj = Gradient(Tag, gradient[1], gradient[2], 0)
		end

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
			SetTitle = function(_, v) TLabel.Text = tostring(v) end,
			SetColor = function(_, c)
				if rainConn then rainConn:Disconnect() rainbow = false end
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
			SetGradient = function(_, c1, c2)
				if gradObj then gradObj:Destroy() end
				gradObj = Gradient(Tag, c1, c2, 0)
			end,
			Destroy = function()
				if rainConn then rainConn:Disconnect() end
				Tag:Destroy()
			end,
		}
		table.insert(Window.Tags, api)
		return api
	end

	-- NOTIFY
	function Window:Notify(title, content, duration, nType)
		duration = duration or 3.5
		nType = nType or "Info"
		local col = Library.Theme.Accent
		if nType == "Success" then col = Library.Theme.Success
		elseif nType == "Error" then col = Library.Theme.Error
		elseif nType == "Warning" then col = Library.Theme.Warning end

		local N = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 300, 0, 72),
			Position = UDim2.new(1, 30, 1, -100),
			ZIndex = 90,
		})
		Corner(N, 10)
		if acrylic then ApplyGlass(N, 0.3) end
		Stroke(N, col, 1.5, 0.15)

		Create("TextLabel", {
			Parent = N,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 12, 0, 8),
			Font = Enum.Font.GothamBold,
			Text = title or "Notification",
			TextColor3 = Library.Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 91,
		})
		Create("TextLabel", {
			Parent = N,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 32),
			Position = UDim2.new(0, 12, 0, 32),
			Font = Enum.Font.Gotham,
			Text = content or "",
			TextColor3 = Library.Theme.TextDark,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 91,
		})
		local bar = Create("Frame", {
			Parent = N,
			BackgroundColor3 = col,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 3),
			Position = UDim2.new(0, 0, 1, -3),
			ZIndex = 92,
		})
		Corner(bar, 2)

		Tween(N, { Position = UDim2.new(1, -320, 1, -100) }, 0.35, Enum.EasingStyle.Back)
		Tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)
		task.delay(duration, function()
			Tween(N, { Position = UDim2.new(1, 30, 1, -100) }, 0.25)
			task.delay(0.3, function() N:Destroy() end)
		end)
	end

	-- DIALOG
	function Window:Dialog(cfg)
		cfg = cfg or {}
		local dTitle = cfg.Title or "Dialog"
		local dText = cfg.Text or cfg.Content or ""
		local dInput = cfg.Input
		local buttons = cfg.Buttons or {
			{ Text = "Confirm", Color = Library.Theme.Success, Callback = function() end },
			{ Text = "Cancel", Color = Library.Theme.Error, Callback = function() end },
		}

		Dim.Visible = true
		Dim.BackgroundTransparency = 1
		Tween(Dim, { BackgroundTransparency = 0.45 }, 0.2)

		local D = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 340, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(0.5, -170, 0.5, -90),
			ZIndex = 85,
		})
		Corner(D, 12)
		if acrylic then ApplyGlass(D, 0.18) end
		Stroke(D, Library.Theme.Accent, 1.2, 0.25)
		Pad(D, 16, 16, 16, 16)

		Create("TextLabel", {
			Parent = D,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Font = Enum.Font.GothamBold,
			Text = dTitle,
			TextColor3 = Library.Theme.Text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 86,
		})

		Create("TextLabel", {
			Parent = D,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			Text = dText,
			TextColor3 = Library.Theme.TextDark,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 86,
		})

		local inputBox
		local yOff = 60
		if dInput then
			inputBox = Create("TextBox", {
				Parent = D,
				BackgroundColor3 = Library.Theme.Background,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 32),
				Position = UDim2.new(0, 0, 0, yOff),
				Font = Enum.Font.Gotham,
				Text = dInput.Default or "",
				PlaceholderText = dInput.Placeholder or "Type here...",
				PlaceholderColor3 = Library.Theme.TextDark,
				TextColor3 = Library.Theme.Text,
				TextSize = 13,
				ClearTextOnFocus = false,
				ZIndex = 86,
			})
			Corner(inputBox, 6)
			Pad(inputBox, 0, 0, 10, 10)
			yOff = yOff + 42
		end

		local BtnRow = Create("Frame", {
			Parent = D,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 34),
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
			Tween(Dim, { BackgroundTransparency = 1 }, 0.2)
			Tween(D, { BackgroundTransparency = 1 }, 0.2)
			task.delay(0.22, function()
				Dim.Visible = false
				D:Destroy()
			end)
		end

		for _, b in ipairs(buttons) do
			local B = Create("TextButton", {
				Parent = BtnRow,
				BackgroundColor3 = b.Color or Library.Theme.Accent,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 90, 0, 32),
				Text = b.Text or "OK",
				Font = Enum.Font.GothamMedium,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 13,
				AutoButtonColor = false,
				ZIndex = 87,
			})
			Corner(B, 7)
			B.MouseButton1Click:Connect(function()
				local val = inputBox and inputBox.Text or nil
				CloseDialog()
				if b.Callback then b.Callback(val) end
			end)
		end

		D.BackgroundTransparency = 1
		Tween(D, { BackgroundTransparency = acrylic and 0.12 or 0 }, 0.25, Enum.EasingStyle.Back)
	end

	-- FPS / MS widget
	function Window:CreateStatsWidget(cfg)
		cfg = cfg or {}
		local pos = cfg.Position or UDim2.new(0, 20, 0, 20)

		local W = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 132, 0, 56),
			Position = pos,
			ZIndex = 55,
		})
		Corner(W, 10)
		if acrylic then ApplyGlass(W, 0.35) end
		Stroke(W, Library.Theme.Stroke, 1, 0.4)
		MakeDraggable(W, W)

		Create("ImageLabel", {
			Parent = W,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 10, 0, 8),
			Image = "rbxassetid://7733993211",
			ImageColor3 = Library.Theme.Accent,
			ZIndex = 56,
		})
		local fpsLbl = Create("TextLabel", {
			Parent = W,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 0, 18),
			Position = UDim2.new(0, 30, 0, 6),
			Font = Enum.Font.GothamMedium,
			Text = "FPS: --",
			TextColor3 = Library.Theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 56,
		})
		Create("ImageLabel", {
			Parent = W,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 10, 0, 30),
			Image = "rbxassetid://7733916120",
			ImageColor3 = Library.Theme.Success,
			ZIndex = 56,
		})
		local msLbl = Create("TextLabel", {
			Parent = W,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 0, 18),
			Position = UDim2.new(0, 30, 0, 28),
			Font = Enum.Font.GothamMedium,
			Text = "MS: --",
			TextColor3 = Library.Theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 56,
		})

		local frames, last = 0, tick()
		RunService.RenderStepped:Connect(function()
			frames = frames + 1
			local now = tick()
			if now - last >= 1 then
				fpsLbl.Text = "FPS: " .. math.floor(frames / (now - last))
				frames = 0
				last = now
				local ping = 0
				pcall(function()
					ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
				end)
				msLbl.Text = "MS: " .. ping
			end
		end)
		return W
	end

	-- TAB
	function Window:CreateTab(name, icon)
		icon = icon or "rbxassetid://7733960981"

		local TabBtn = Create("TextButton", {
			Name = name,
			Parent = TabList,
			BackgroundColor3 = Library.Theme.Tertiary,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 38),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 7,
		})
		Corner(TabBtn, 8)

		local TabIcon = Create("ImageLabel", {
			Parent = TabBtn,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 10, 0.5, -9),
			Image = icon,
			ImageColor3 = Library.Theme.TextDark,
			ZIndex = 8,
		})
		local TabText = Create("TextLabel", {
			Parent = TabBtn,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -42, 1, 0),
			Position = UDim2.new(0, 36, 0, 0),
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = Library.Theme.TextDark,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8,
		})
		local Ind = Create("Frame", {
			Parent = TabBtn,
			BackgroundColor3 = Library.Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 0, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ZIndex = 9,
		})
		Corner(Ind, 2)

		local Page = Create("ScrollingFrame", {
			Name = name,
			Parent = Pages,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Library.Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 6,
		})
		Pad(Page, 12, 14, 14, 14)
		Create("UIListLayout", {
			Parent = Page,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		})

		local Tab = { Name = name, Button = TabBtn, Page = Page, Sections = {} }

		local function Select()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, { BackgroundTransparency = 1 }, 0.15)
				local ic = t.Button:FindFirstChildOfClass("ImageLabel")
				if ic then Tween(ic, { ImageColor3 = Library.Theme.TextDark }, 0.15) end
				local tx = t.Button:FindFirstChildOfClass("TextLabel")
				if tx then Tween(tx, { TextColor3 = Library.Theme.TextDark }, 0.15) end
				local ind = t.Button:FindFirstChild("Frame")
				if ind then Tween(ind, { Size = UDim2.new(0, 3, 0, 0) }, 0.15) end
			end
			Page.Visible = true
			Page.BackgroundTransparency = 1
			Tween(TabBtn, { BackgroundTransparency = 0 }, 0.2)
			Tween(TabIcon, { ImageColor3 = Library.Theme.Accent }, 0.2)
			Tween(TabText, { TextColor3 = Library.Theme.Text }, 0.2)
			Tween(Ind, { Size = UDim2.new(0, 3, 0, 22) }, 0.2)
			Window.CurrentTab = Tab
		end

		TabBtn.MouseButton1Click:Connect(Select)
		TabBtn.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then Tween(TabBtn, { BackgroundTransparency = 0.55 }, 0.12) end
		end)
		TabBtn.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then Tween(TabBtn, { BackgroundTransparency = 1 }, 0.12) end
		end)

		if not Window.CurrentTab then Select() end
		table.insert(Window.Tabs, Tab)

		-- SECTION (name outside + collapse)
		function Tab:CreateSection(sectionName)
			local Wrap = Create("Frame", {
				Name = sectionName,
				Parent = Page,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 7,
			})
			Create("UIListLayout", {
				Parent = Wrap,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6),
			})

			local Header = Create("TextButton", {
				Parent = Wrap,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 22),
				Text = "",
				ZIndex = 8,
			})
			Create("TextLabel", {
				Parent = Header,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -28, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = sectionName,
				TextColor3 = Library.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 9,
			})
			local Arrow = Create("TextLabel", {
				Parent = Header,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 22, 1, 0),
				Position = UDim2.new(1, -22, 0, 0),
				Font = Enum.Font.GothamBold,
				Text = "▾",
				TextColor3 = Library.Theme.TextDark,
				TextSize = 14,
				ZIndex = 9,
			})

			local Card = Create("Frame", {
				Name = "Card",
				Parent = Wrap,
				BackgroundColor3 = Library.Theme.Secondary,
				BackgroundTransparency = acrylic and 0.15 or 0,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 8,
			})
			Corner(Card, 10)
			Stroke(Card, Library.Theme.Stroke, 1, acrylic and 0.4 or 0)
			Pad(Card, 8, 10, 10, 10)

			local Body = Create("Frame", {
				Name = "Body",
				Parent = Card,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 9,
			})
			Create("UIListLayout", {
				Parent = Body,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6),
			})

			local open = true
			Header.MouseButton1Click:Connect(function()
				open = not open
				Card.Visible = open
				Arrow.Text = open and "▾" or "▸"
			end)

			local Section = { Frame = Wrap, Card = Card, Body = Body }

			-- BUTTON liquid + hold follow
			function Section:CreateButton(o)
				o = o or {}
				local text = o.Name or o.Text or "Button"
				local cb = o.Callback or function() end

				local Btn = Create("TextButton", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 36),
					Text = "",
					AutoButtonColor = false,
					ZIndex = 10,
				})
				Corner(Btn, 8)
				if acrylic then ApplyGlass(Btn, 0.55) end
				Stroke(Btn, Color3.fromRGB(255, 255, 255), 1, 0.65)

				Create("TextLabel", {
					Parent = Btn,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -16, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				local following, fConn
				Btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						following = true
						Tween(Btn, { BackgroundTransparency = 0.25 }, 0.08)
						fConn = RunService.RenderStepped:Connect(function()
							if not following then return end
							local m = UserInputService:GetMouseLocation()
							local abs = Btn.AbsolutePosition
							local sz = Btn.AbsoluteSize
							local dx = math.clamp((m.X - (abs.X + sz.X / 2)) / 40, -1, 1) * 5
							local dy = math.clamp((m.Y - (abs.Y + sz.Y / 2)) / 40, -1, 1) * 4
							Btn.Position = UDim2.new(0, dx, 0, dy)
						end)
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								following = false
								if fConn then fConn:Disconnect() end
								Tween(Btn, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = acrylic and 0.55 or 0 }, 0.22, Enum.EasingStyle.Back)
							end
						end)
					end
				end)
				Btn.MouseEnter:Connect(function()
					Tween(Btn, { BackgroundColor3 = Library.Theme.Accent }, 0.15)
				end)
				Btn.MouseLeave:Connect(function()
					Tween(Btn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.15)
				end)
				Btn.MouseButton1Click:Connect(cb)
				return Btn
			end

			-- TOGGLE liquid glass + drag knob
			function Section:CreateToggle(o)
				o = o or {}
				local text = o.Name or o.Text or "Toggle"
				local default = o.Default or false
				local flag = o.Flag
				local cb = o.Callback or function() end
				local state = default
				if flag then Library.Flags[flag] = state end

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 38),
					ZIndex = 10,
				})
				Corner(Holder, 8)
				if acrylic then ApplyGlass(Holder, 0.6) end
				Stroke(Holder, Color3.fromRGB(255, 255, 255), 1, 0.7)

				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -64, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				local Track = Create("Frame", {
					Parent = Holder,
					BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BackgroundTransparency = 0.2,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 44, 0, 24),
					Position = UDim2.new(1, -56, 0.5, -12),
					ZIndex = 11,
				})
				Corner(Track, 12)
				Stroke(Track, Color3.fromRGB(255, 255, 255), 1, 0.5)

				local Knob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.12,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 18, 0, 18),
					Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
					ZIndex = 12,
				})
				Corner(Knob, 9)
				Stroke(Knob, Color3.fromRGB(255, 255, 255), 1.2, 0.35)

				local function Set(v, fire)
					state = v
					if flag then Library.Flags[flag] = state end
					Tween(Track, { BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff }, 0.18)
					Tween(Knob, {
						Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
					}, 0.18, Enum.EasingStyle.Back)
					if fire ~= false then cb(state) end
				end

				local dragging
				Knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local rel = math.clamp(input.Position.X - Track.AbsolutePosition.X - 9, 3, Track.AbsoluteSize.X - 21)
						Knob.Position = UDim2.new(0, rel, 0.5, -9)
					end
				end)

				local Click = Create("TextButton", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -60, 1, 0),
					Text = "",
					ZIndex = 13,
				})
				Click.MouseButton1Click:Connect(function() Set(not state) end)

				return { Set = Set, Get = function() return state end, Frame = Holder }
			end

			-- INPUT
			function Section:CreateInput(o)
				o = o or {}
				local text = o.Name or o.Text or "Input"
				local ph = o.Placeholder or "..."
				local def = o.Default or ""
				local flag = o.Flag
				local cb = o.Callback or function() end
				if flag then Library.Flags[flag] = def end

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 60),
					ZIndex = 10,
				})
				Corner(Holder, 8)
				if acrylic then ApplyGlass(Holder, 0.6) end
				Stroke(Holder, Color3.fromRGB(255, 255, 255), 1, 0.7)

				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -16, 0, 20),
					Position = UDim2.new(0, 10, 0, 4),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				local Box = Create("TextBox", {
					Parent = Holder,
					BackgroundColor3 = Library.Theme.Background,
					BackgroundTransparency = 0.25,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -20, 0, 28),
					Position = UDim2.new(0, 10, 0, 26),
					Font = Enum.Font.Gotham,
					Text = def,
					PlaceholderText = ph,
					PlaceholderColor3 = Library.Theme.TextDark,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					ClearTextOnFocus = false,
					ZIndex = 11,
				})
				Corner(Box, 6)
				Pad(Box, 0, 0, 8, 8)

				Box.FocusLost:Connect(function()
					if flag then Library.Flags[flag] = Box.Text end
					cb(Box.Text)
				end)

				return {
					Set = function(v) Box.Text = tostring(v) if flag then Library.Flags[flag] = Box.Text end end,
					Get = function() return Box.Text end,
					Frame = Holder,
				}
			end

			-- PARAGRAPH
			function Section:CreateParagraph(o)
				o = o or {}
				local t = o.Title or "Paragraph"
				local c = o.Content or o.Text or ""

				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 10,
				})
				Corner(Holder, 8)
				if acrylic then ApplyGlass(Holder, 0.65) end
				Stroke(Holder, Color3.fromRGB(255, 255, 255), 1, 0.7)
				Pad(Holder, 8, 10, 10, 10)

				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Font = Enum.Font.GothamBold,
					Text = t,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})
				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 22),
					AutomaticSize = Enum.AutomaticSize.Y,
					Font = Enum.Font.Gotham,
					Text = c,
					TextColor3 = Library.Theme.TextDark,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					ZIndex = 11,
				})
				return Holder
			end

			-- LABEL
			function Section:CreateLabel(o)
				o = o or {}
				local text = o.Text or o.Name or "Label"
				local col = o.Color or Library.Theme.TextDark
				local L = Create("TextLabel", {
					Parent = Body,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Font = Enum.Font.Gotham,
					Text = text,
					TextColor3 = col,
					TextSize = o.Size or 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})
				return {
					Set = function(_, v) L.Text = tostring(v) end,
					SetColor = function(_, c) L.TextColor3 = c end,
					Frame = L,
				}
			end

			-- IMAGE
			function Section:CreateImage(o)
				o = o or {}
				local id = o.Image or o.Id or "rbxassetid://0"
				local h = o.Height or 120
				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, h + 8),
					ZIndex = 10,
				})
				Corner(Holder, 8)
				if acrylic then ApplyGlass(Holder, 0.6) end
				local Img = Create("ImageLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -12, 0, h),
					Position = UDim2.new(0, 6, 0, 4),
					Image = id,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 11,
				})
				Corner(Img, 6)
				return { Frame = Holder, Image = Img, Set = function(_, id2) Img.Image = id2 end }
			end

			-- CUSTOM FRAME
			function Section:CreateFrame(o)
				o = o or {}
				local h = o.Height or 80
				local F = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = o.Color or Library.Theme.Tertiary,
					BackgroundTransparency = o.Transparency or (acrylic and 0.5 or 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, h),
					ZIndex = 10,
				})
				Corner(F, o.Corner or 8)
				if o.Stroke ~= false then Stroke(F, o.StrokeColor or Library.Theme.Stroke, 1) end
				return F
			end

			-- DROPDOWN
			function Section:CreateDropdown(o)
				o = o or {}
				local text = o.Name or o.Text or "Dropdown"
				local list = o.Options or {}
				local multi = o.Multi or false
				local default = o.Default
				local flag = o.Flag
				local cb = o.Callback or function() end

				local selected
				if multi then
					selected = {}
					if type(default) == "table" then
						for _, v in ipairs(default) do selected[v] = true end
					elseif default then selected[default] = true end
				else
					selected = default or list[1] or ""
				end
				if flag then Library.Flags[flag] = multi and selected or selected end

				local open = false
				local Holder = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 38),
					ClipsDescendants = true,
					ZIndex = 10,
				})
				Corner(Holder, 8)
				if acrylic then ApplyGlass(Holder, 0.55) end
				Stroke(Holder, Color3.fromRGB(255, 255, 255), 1, 0.65)

				Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -50, 0, 38),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				local Val = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 100, 0, 38),
					Position = UDim2.new(1, -130, 0, 0),
					Font = Enum.Font.Gotham,
					Text = multi and "None" or tostring(selected),
					TextColor3 = Library.Theme.TextDark,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 11,
				})

				local Arrow = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 22, 0, 38),
					Position = UDim2.new(1, -28, 0, 0),
					Font = Enum.Font.GothamBold,
					Text = "▾",
					TextColor3 = Library.Theme.TextDark,
					TextSize = 14,
					ZIndex = 11,
				})

				local OptList = Create("Frame", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -10, 0, 0),
					Position = UDim2.new(0, 5, 0, 40),
					ZIndex = 12,
				})
				Create("UIListLayout", {
					Parent = OptList,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3),
				})

				local function UpdateVal()
					if multi then
						local t = {}
						for k, v in pairs(selected) do if v then table.insert(t, k) end end
						Val.Text = #t > 0 and table.concat(t, ", ") or "None"
						if flag then Library.Flags[flag] = selected end
					else
						Val.Text = tostring(selected)
						if flag then Library.Flags[flag] = selected end
					end
				end

				local function Build()
					for _, c in ipairs(OptList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(list) do
						local isSel = multi and selected[opt] or (selected == opt)
						local OB = Create("TextButton", {
							Parent = OptList,
							BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Background,
							BackgroundTransparency = isSel and 0.1 or 0.35,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 28),
							Text = "",
							AutoButtonColor = false,
							ZIndex = 13,
						})
						Corner(OB, 6)
						Create("TextLabel", {
							Parent = OB,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 8, 0, 0),
							Font = Enum.Font.Gotham,
							Text = tostring(opt),
							TextColor3 = isSel and Color3.new(1, 1, 1) or Library.Theme.Text,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 14,
						})
						OB.MouseButton1Click:Connect(function()
							if multi then
								selected[opt] = not selected[opt]
								UpdateVal()
								local vals = {}
								for k, v in pairs(selected) do if v then table.insert(vals, k) end end
								cb(vals)
								Build()
							else
								selected = opt
								UpdateVal()
								cb(opt)
								open = false
								Tween(Holder, { Size = UDim2.new(1, 0, 0, 38) }, 0.2)
								Arrow.Text = "▾"
							end
						end)
					end
				end
				Build()
				UpdateVal()

				local Head = Create("TextButton", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 38),
					Text = "",
					ZIndex = 15,
				})
				Head.MouseButton1Click:Connect(function()
					open = not open
					local h = open and (38 + #list * 31 + 10) or 38
					Tween(Holder, { Size = UDim2.new(1, 0, 0, h) }, 0.22)
					Arrow.Text = open and "▴" or "▾"
					if open then Build() end
				end)

				return {
					Set = function(v)
						if multi then
							selected = {}
							if type(v) == "table" then for _, x in ipairs(v) do selected[x] = true end end
						else selected = v end
						UpdateVal()
						Build()
					end,
					Get = function()
						if multi then
							local t = {}
							for k, v in pairs(selected) do if v then table.insert(t, k) end end
							return t
						end
						return selected
					end,
					Refresh = function(nl) list = nl or list Build() end,
					Frame = Holder,
				}
			end

			function Section:CreateMultiDropdown(o)
				o = o or {}
				o.Multi = true
				return Section:CreateDropdown(o)
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
