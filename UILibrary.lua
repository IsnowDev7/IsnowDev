--[[
	Isnow UI Library v3
	iOS liquid-glass toggle, real section arrows, invisible X/-,
	Slider, ProgressBar, Intro Loader, KeySystem,
	Acrylic, Tags, Dialog, Notify, Stats, Image (rbx + http)
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
		Background = Color3.fromRGB(18, 18, 22),
		Secondary = Color3.fromRGB(26, 26, 32),
		Tertiary = Color3.fromRGB(36, 36, 44),
		Accent = Color3.fromRGB(100, 140, 255),
		Text = Color3.fromRGB(245, 245, 250),
		TextDark = Color3.fromRGB(150, 150, 165),
		Stroke = Color3.fromRGB(55, 55, 68),
		Success = Color3.fromRGB(52, 199, 89),
		Error = Color3.fromRGB(255, 69, 58),
		Warning = Color3.fromRGB(255, 159, 10),
		ToggleOn = Color3.fromRGB(52, 199, 89),
		ToggleOff = Color3.fromRGB(72, 72, 74),
	},
}

local function Protect(gui)
	if syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = CoreGui
	elseif gethui then gui.Parent = gethui()
	else gui.Parent = CoreGui end
end

local function Tween(obj, props, dur, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function Create(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do if k ~= "Parent" then i[k] = v end end
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

-- Resolve image: rbxassetid / http / https / plain number
local function ResolveImage(src)
	if not src or src == "" then return "rbxassetid://0" end
	src = tostring(src)
	if src:match("^%d+$") then return "rbxassetid://" .. src end
	if src:match("^rbxassetid://") or src:match("^rbxthumb://") or src:match("^rbxasset://") then return src end
	if src:match("^https?://") then return src end
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

	local ScreenGui = Create("ScreenGui", {
		Name = "IsnowUI_" .. HttpService:GenerateGUID(false):sub(1, 8),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	Protect(ScreenGui)

	local Dim = Create("Frame", {
		Name = "Dim", Parent = ScreenGui,
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 80,
	})

	local Main = Create("Frame", {
		Name = "Main", Parent = ScreenGui,
		BackgroundColor3 = Library.Theme.Background,
		BackgroundTransparency = math.clamp(0.05 + transparency, 0, 0.6),
		BorderSizePixel = 0, Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		ClipsDescendants = true, ZIndex = 2,
	})
	Corner(Main, 12)
	Stroke(Main, Color3.fromRGB(255, 255, 255), 1, acrylic and 0.85 or 0.5)

	Create("ImageLabel", {
		Name = "Shadow", Parent = Main, BackgroundTransparency = 1,
		Position = UDim2.new(0, -18, 0, -18), Size = UDim2.new(1, 36, 1, 36),
		Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.5, ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0,
	})

	-- TOP BAR
	local TopBar = Create("Frame", {
		Name = "TopBar", Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.3 or 0,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 46), ZIndex = 10,
	})
	Corner(TopBar, 12)
	Create("Frame", {
		Parent = TopBar, BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.3 or 0, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), ZIndex = 10,
	})

	Create("ImageLabel", {
		Parent = TopBar, BackgroundTransparency = 1,
		Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 14, 0.5, -11),
		Image = iconId, ImageColor3 = Library.Theme.Accent, ZIndex = 11,
	})

	Create("TextLabel", {
		Parent = TopBar, BackgroundTransparency = 1,
		Size = UDim2.new(1, -180, 0, 20), Position = UDim2.new(0, 44, 0, 6),
		Font = Enum.Font.GothamBold, Text = title, TextColor3 = Library.Theme.Text,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
	})
	Create("TextLabel", {
		Parent = TopBar, BackgroundTransparency = 1,
		Size = UDim2.new(1, -180, 0, 14), Position = UDim2.new(0, 44, 0, 26),
		Font = Enum.Font.Gotham, Text = subtitle, TextColor3 = Library.Theme.TextDark,
		TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
	})

	local TagBar = Create("Frame", {
		Name = "TagBar", Parent = TopBar, BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(1, -200, 0, 4), ZIndex = 12,
	})
	Create("UIListLayout", {
		Parent = TagBar, FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 5),
	})

	-- Close X — NO frame, invisible bg
	local CloseBtn = Create("TextButton", {
		Name = "Close", Parent = TopBar, BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -36, 0.5, -14),
		Text = "×", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.TextDark,
		TextSize = 20, AutoButtonColor = false, ZIndex = 13,
	})
	CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, { TextColor3 = Library.Theme.Error }, 0.12) end)
	CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, { TextColor3 = Library.Theme.TextDark }, 0.12) end)

	-- Minimize − — NO frame
	local MinBtn = Create("TextButton", {
		Name = "Minimize", Parent = TopBar, BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -64, 0.5, -14),
		Text = "−", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.TextDark,
		TextSize = 20, AutoButtonColor = false, ZIndex = 13,
	})
	MinBtn.MouseEnter:Connect(function() Tween(MinBtn, { TextColor3 = Library.Theme.Accent }, 0.12) end)
	MinBtn.MouseLeave:Connect(function() Tween(MinBtn, { TextColor3 = Library.Theme.TextDark }, 0.12) end)

	-- Floating capsule restore
	local Capsule = Create("TextButton", {
		Name = "RestoreCapsule", Parent = ScreenGui,
		BackgroundColor3 = Library.Theme.Secondary, BorderSizePixel = 0,
		Size = UDim2.new(0, 148, 0, 36), Position = UDim2.new(0.5, -74, 0, 16),
		Text = "", Visible = false, AutoButtonColor = false, ZIndex = 60,
	})
	Corner(Capsule, 18)
	Stroke(Capsule, Library.Theme.Accent, 1, 0.4)
	Create("ImageLabel", {
		Parent = Capsule, BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 12, 0.5, -8),
		Image = iconId, ImageColor3 = Library.Theme.Accent, ZIndex = 61,
	})
	Create("TextLabel", {
		Parent = Capsule, BackgroundTransparency = 1,
		Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 32, 0, 0),
		Font = Enum.Font.GothamMedium, Text = title, TextColor3 = Library.Theme.Text,
		TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 61,
	})
	MakeDraggable(Capsule, Capsule)

	-- SIDEBAR
	local Sidebar = Create("Frame", {
		Name = "Sidebar", Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.25 or 0,
		BorderSizePixel = 0,
		Size = UDim2.new(0, sidebarWidth, 1, -46 - 26),
		Position = UDim2.new(0, 0, 0, 46), ZIndex = 5,
	})
	Create("Frame", {
		Parent = Sidebar, BackgroundColor3 = Library.Theme.Stroke, BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), ZIndex = 6,
	})

	local TabList = Create("ScrollingFrame", {
		Name = "TabList", Parent = Sidebar, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -6), Position = UDim2.new(0, 0, 0, 4),
		ScrollBarThickness = 3, ScrollBarImageColor3 = Library.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6,
	})
	Pad(TabList, 4, 6, 8, 8)
	Create("UIListLayout", { Parent = TabList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })

	local Content = Create("Frame", {
		Name = "Content", Parent = Main, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -sidebarWidth, 1, -46 - 26),
		Position = UDim2.new(0, sidebarWidth, 0, 46), ClipsDescendants = true, ZIndex = 5,
	})
	local Pages = Create("Folder", { Name = "Pages", Parent = Content })

	-- FOOTER
	local Footer = Create("Frame", {
		Name = "Footer", Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BackgroundTransparency = acrylic and 0.3 or 0,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.new(0, 0, 1, -26), ZIndex = 10,
	})
	local FooterLabel = Create("TextLabel", {
		Parent = Footer, BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 10, 0, 0),
		Font = Enum.Font.Gotham, Text = footerText, TextColor3 = Library.Theme.TextDark,
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
	})

	-- Resize +
	local Grip = Create("TextButton", {
		Name = "ResizeGrip", Parent = Main, BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -18, 1, -18),
		Text = "+", Font = Enum.Font.GothamBold, TextColor3 = Library.Theme.TextDark,
		TextSize = 14, ZIndex = 50, AutoButtonColor = false,
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
		ScreenGui = ScreenGui, Main = Main, Tabs = {}, CurrentTab = nil,
		Visible = true, SidebarWidth = sidebarWidth, Tags = {},
	}

	function Window:SetSidebarWidth(w)
		sidebarWidth = w
		Window.SidebarWidth = w
		Tween(Sidebar, { Size = UDim2.new(0, w, 1, -46 - 26) }, 0.25)
		Tween(Content, { Size = UDim2.new(1, -w, 1, -46 - 26), Position = UDim2.new(0, w, 0, 46) }, 0.25)
	end

	CloseBtn.MouseButton1Click:Connect(function()
		Tween(Main, { BackgroundTransparency = 1 }, 0.2)
		task.delay(0.22, function() ScreenGui:Destroy() end)
	end)

	MinBtn.MouseButton1Click:Connect(function()
		Tween(Main, { BackgroundTransparency = 1 }, 0.18)
		task.delay(0.18, function()
			Main.Visible = false
			Capsule.Visible = true
			Capsule.BackgroundTransparency = 1
			Tween(Capsule, { BackgroundTransparency = 0.15 }, 0.2)
		end)
	end)
	Capsule.MouseButton1Click:Connect(function()
		Capsule.Visible = false
		Main.Visible = true
		Main.BackgroundTransparency = 1
		Tween(Main, { BackgroundTransparency = math.clamp(0.05 + transparency, 0, 0.6) }, 0.2)
	end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then
			Window.Visible = not Window.Visible
			if Window.Visible then
				Main.Visible = true
				Capsule.Visible = false
				Main.BackgroundTransparency = 1
				Tween(Main, { BackgroundTransparency = math.clamp(0.05 + transparency, 0, 0.6) }, 0.2)
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

		local Tag = Create("Frame", {
			Parent = TagBar, BackgroundColor3 = tColor, BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 13,
		})
		Corner(Tag, 9)
		Pad(Tag, 0, 0, 7, 7)
		Tag.BackgroundTransparency = 0.15

		local TLabel = Create("TextLabel", {
			Parent = Tag, BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
			Font = Enum.Font.GothamMedium, Text = tTitle, TextColor3 = Color3.new(1, 1, 1),
			TextSize = 10, ZIndex = 14,
		})

		local rainConn
		if rainbow then
			local h = 0
			rainConn = RunService.RenderStepped:Connect(function(dt)
				h = (h + dt * 0.35) % 1
				Tag.BackgroundColor3 = Color3.fromHSV(h, 0.65, 1)
			end)
		end

		return {
			Frame = Tag,
			SetTitle = function(_, v) TLabel.Text = tostring(v) end,
			SetColor = function(_, c)
				if rainConn then rainConn:Disconnect() end
				Tag.BackgroundColor3 = c
			end,
			SetRainbow = function(_, on)
				if on and not rainConn then
					local h = 0
					rainConn = RunService.RenderStepped:Connect(function(dt)
						h = (h + dt * 0.35) % 1
						Tag.BackgroundColor3 = Color3.fromHSV(h, 0.65, 1)
					end)
				elseif not on and rainConn then
					rainConn:Disconnect()
					rainConn = nil
				end
			end,
			Destroy = function()
				if rainConn then rainConn:Disconnect() end
				Tag:Destroy()
			end,
		}
	end

	-- NOTIFY
	function Window:Notify(title, content, duration, nType)
		duration = duration or 3
		nType = nType or "Info"
		local col = Library.Theme.Accent
		if nType == "Success" then col = Library.Theme.Success
		elseif nType == "Error" then col = Library.Theme.Error
		elseif nType == "Warning" then col = Library.Theme.Warning end

		local N = Create("Frame", {
			Parent = ScreenGui, BackgroundColor3 = Library.Theme.Secondary, BorderSizePixel = 0,
			Size = UDim2.new(0, 280, 0, 64), Position = UDim2.new(1, 24, 1, -90), ZIndex = 90,
		})
		Corner(N, 10)
		Stroke(N, col, 1.5, 0.2)

		Create("TextLabel", {
			Parent = N, BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 8),
			Font = Enum.Font.GothamBold, Text = title or "Notify", TextColor3 = Library.Theme.Text,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 91,
		})
		Create("TextLabel", {
			Parent = N, BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 10, 0, 28),
			Font = Enum.Font.Gotham, Text = content or "", TextColor3 = Library.Theme.TextDark,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 91,
		})
		local bar = Create("Frame", {
			Parent = N, BackgroundColor3 = col, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), ZIndex = 92,
		})

		Tween(N, { Position = UDim2.new(1, -300, 1, -90) }, 0.3, Enum.EasingStyle.Back)
		Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)
		task.delay(duration, function()
			Tween(N, { Position = UDim2.new(1, 24, 1, -90) }, 0.22)
			task.delay(0.25, function() N:Destroy() end)
		end)
	end

	-- DIALOG (clean, not AI-looking)
	function Window:Dialog(cfg)
		cfg = cfg or {}
		local dTitle = cfg.Title or "Confirm"
		local dText = cfg.Text or cfg.Content or ""
		local dInput = cfg.Input
		local buttons = cfg.Buttons or {
			{ Text = "OK", Color = Library.Theme.Success, Callback = function() end },
			{ Text = "Cancel", Color = Library.Theme.Error, Callback = function() end },
		}

		Dim.Visible = true
		Dim.BackgroundTransparency = 1
		Tween(Dim, { BackgroundTransparency = 0.5 }, 0.18)

		local D = Create("Frame", {
			Parent = ScreenGui, BackgroundColor3 = Library.Theme.Secondary, BorderSizePixel = 0,
			Size = UDim2.new(0, 320, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(0.5, -160, 0.5, -70), ZIndex = 85,
		})
		Corner(D, 10)
		Stroke(D, Library.Theme.Stroke, 1)
		Pad(D, 14, 14, 14, 14)

		Create("TextLabel", {
			Parent = D, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
			Font = Enum.Font.GothamBold, Text = dTitle, TextColor3 = Library.Theme.Text,
			TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 86,
		})
		Create("TextLabel", {
			Parent = D, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 28),
			AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham,
			Text = dText, TextColor3 = Library.Theme.TextDark, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 86,
		})

		local inputBox
		local yOff = 56
		if dInput then
			inputBox = Create("TextBox", {
				Parent = D, BackgroundColor3 = Library.Theme.Background, BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, yOff),
				Font = Enum.Font.Gotham, Text = dInput.Default or "",
				PlaceholderText = dInput.Placeholder or "...",
				PlaceholderColor3 = Library.Theme.TextDark, TextColor3 = Library.Theme.Text,
				TextSize = 12, ClearTextOnFocus = false, ZIndex = 86,
			})
			Corner(inputBox, 6)
			Pad(inputBox, 0, 0, 8, 8)
			yOff = yOff + 40
		end

		local BtnRow = Create("Frame", {
			Parent = D, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, yOff), ZIndex = 86,
		})
		Create("UIListLayout", {
			Parent = BtnRow, FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8),
		})

		local function CloseDialog()
			Tween(Dim, { BackgroundTransparency = 1 }, 0.15)
			Tween(D, { BackgroundTransparency = 1 }, 0.15)
			task.delay(0.18, function() Dim.Visible = false D:Destroy() end)
		end

		for _, b in ipairs(buttons) do
			local B = Create("TextButton", {
				Parent = BtnRow, BackgroundColor3 = b.Color or Library.Theme.Accent,
				BorderSizePixel = 0, Size = UDim2.new(0, 80, 0, 28),
				Text = b.Text or "OK", Font = Enum.Font.GothamMedium,
				TextColor3 = Color3.new(1, 1, 1), TextSize = 12,
				AutoButtonColor = false, ZIndex = 87,
			})
			Corner(B, 6)
			B.MouseButton1Click:Connect(function()
				local val = inputBox and inputBox.Text or nil
				CloseDialog()
				if b.Callback then b.Callback(val) end
			end)
		end
	end

	-- INTRO LOADER
	function Window:IntroLoader(cfg)
		cfg = cfg or {}
		local duration = cfg.Duration or 2.5
		local loadText = cfg.Text or "Loading..."
		local logo = ResolveImage(cfg.Logo or iconId)

		Main.Visible = false
		Sidebar.Position = UDim2.new(0, -sidebarWidth, 0, 46)

		local Intro = Create("Frame", {
			Name = "Intro", Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Background, BorderSizePixel = 0,
			Size = UDim2.new(0, 320, 0, 160),
			Position = UDim2.new(0.5, -160, 0.5, -80), ZIndex = 100,
		})
		Corner(Intro, 12)
		Stroke(Intro, Library.Theme.Stroke, 1)

		Create("ImageLabel", {
			Parent = Intro, BackgroundTransparency = 1,
			Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0.5, -20, 0, 20),
			Image = logo, ImageColor3 = Library.Theme.Accent, ZIndex = 101,
		})
		Create("TextLabel", {
			Parent = Intro, BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 70),
			Font = Enum.Font.GothamMedium, Text = loadText, TextColor3 = Library.Theme.Text,
			TextSize = 13, ZIndex = 101,
		})

		local Track = Create("Frame", {
			Parent = Intro, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
			Size = UDim2.new(1, -40, 0, 6), Position = UDim2.new(0, 20, 0, 110), ZIndex = 101,
		})
		Corner(Track, 3)
		local Fill = Create("Frame", {
			Parent = Track, BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0), ZIndex = 102,
		})
		Corner(Fill, 3)
		local Pct = Create("TextLabel", {
			Parent = Intro, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 124),
			Font = Enum.Font.Gotham, Text = "0%", TextColor3 = Library.Theme.TextDark,
			TextSize = 11, ZIndex = 101,
		})

		Intro.BackgroundTransparency = 1
		Tween(Intro, { BackgroundTransparency = 0 }, 0.3)

		local start = tick()
		local conn
		conn = RunService.RenderStepped:Connect(function()
			local p = math.clamp((tick() - start) / duration, 0, 1)
			Fill.Size = UDim2.new(p, 0, 1, 0)
			Pct.Text = math.floor(p * 100) .. "%"
			if p >= 1 then
				conn:Disconnect()
				Tween(Intro, { BackgroundTransparency = 1 }, 0.3)
				task.delay(0.3, function()
					Intro:Destroy()
					Main.Visible = true
					Main.BackgroundTransparency = 1
					Tween(Main, { BackgroundTransparency = math.clamp(0.05 + transparency, 0, 0.6) }, 0.3)
					-- sidebar swipe in
					Sidebar.Position = UDim2.new(0, -sidebarWidth, 0, 46)
					Tween(Sidebar, { Position = UDim2.new(0, 0, 0, 46) }, 0.35, Enum.EasingStyle.Quart)
				end)
			end
		end)
	end

	-- KEY SYSTEM (standalone UI before window shows)
	function Window:KeySystem(cfg)
		cfg = cfg or {}
		local keys = cfg.Keys or { "TEST-KEY-123" }
		local sources = cfg.Sources or { "Discord", "Linkvertise", "Work.ink", "Direct" }
		local onSuccess = cfg.OnSuccess or function() end
		local titleText = cfg.Title or "Key System"
		local note = cfg.Note or "Enter your key to continue"

		Main.Visible = false

		local KS = Create("Frame", {
			Name = "KeySystem", Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Background, BorderSizePixel = 0,
			Size = UDim2.new(0, 340, 0, 220),
			Position = UDim2.new(0.5, -170, 0.5, -110), ZIndex = 100,
		})
		Corner(KS, 12)
		Stroke(KS, Library.Theme.Stroke, 1)
		Pad(KS, 16, 16, 16, 16)

		Create("TextLabel", {
			Parent = KS, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
			Font = Enum.Font.GothamBold, Text = titleText, TextColor3 = Library.Theme.Text,
			TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
		})
		Create("TextLabel", {
			Parent = KS, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 26),
			Font = Enum.Font.Gotham, Text = note, TextColor3 = Library.Theme.TextDark,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
		})

		-- Source dropdown
		local sourceVal = sources[1]
		local SrcBtn = Create("TextButton", {
			Parent = KS, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 52),
			Text = "  Source: " .. sourceVal .. "  ▾", Font = Enum.Font.Gotham,
			TextColor3 = Library.Theme.Text, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 101,
		})
		Corner(SrcBtn, 6)

		local SrcList = Create("Frame", {
			Parent = KS, BackgroundColor3 = Library.Theme.Secondary, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 84),
			ClipsDescendants = true, ZIndex = 105, Visible = false,
		})
		Corner(SrcList, 6)
		local srcOpen = false
		for i, s in ipairs(sources) do
			local sb = Create("TextButton", {
				Parent = SrcList, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, (i - 1) * 26),
				Text = "  " .. s, Font = Enum.Font.Gotham, TextColor3 = Library.Theme.Text,
				TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false, ZIndex = 106,
			})
			sb.MouseButton1Click:Connect(function()
				sourceVal = s
				SrcBtn.Text = "  Source: " .. s .. "  ▾"
				srcOpen = false
				SrcList.Visible = false
				SrcList.Size = UDim2.new(1, 0, 0, 0)
			end)
		end
		SrcBtn.MouseButton1Click:Connect(function()
			srcOpen = not srcOpen
			SrcList.Visible = srcOpen
			SrcList.Size = srcOpen and UDim2.new(1, 0, 0, #sources * 26) or UDim2.new(1, 0, 0, 0)
		end)

		local KeyBox = Create("TextBox", {
			Parent = KS, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, 92),
			Font = Enum.Font.Gotham, Text = "", PlaceholderText = "Enter key...",
			PlaceholderColor3 = Library.Theme.TextDark, TextColor3 = Library.Theme.Text,
			TextSize = 13, ClearTextOnFocus = false, ZIndex = 101,
		})
		Corner(KeyBox, 6)
		Pad(KeyBox, 0, 0, 10, 10)

		local Submit = Create("TextButton", {
			Parent = KS, BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, 136),
			Text = "Submit", Font = Enum.Font.GothamMedium, TextColor3 = Color3.new(1, 1, 1),
			TextSize = 13, AutoButtonColor = false, ZIndex = 101,
		})
		Corner(Submit, 6)

		local Status = Create("TextLabel", {
			Parent = KS, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 176),
			Font = Enum.Font.Gotham, Text = "", TextColor3 = Library.Theme.Error,
			TextSize = 11, ZIndex = 101,
		})

		Submit.MouseButton1Click:Connect(function()
			local entered = KeyBox.Text
			local ok = false
			for _, k in ipairs(keys) do
				if entered == k then ok = true break end
			end
			if ok then
				Status.TextColor3 = Library.Theme.Success
				Status.Text = "Key accepted"
				task.delay(0.4, function()
					KS:Destroy()
					Main.Visible = true
					onSuccess(sourceVal)
				end)
			else
				Status.TextColor3 = Library.Theme.Error
				Status.Text = "Invalid key"
				Tween(KeyBox, { BackgroundColor3 = Library.Theme.Error }, 0.1)
				task.delay(0.3, function()
					Tween(KeyBox, { BackgroundColor3 = Library.Theme.Tertiary }, 0.2)
				end)
			end
		end)

		return KS
	end

	-- STATS WIDGET
	function Window:CreateStatsWidget(cfg)
		cfg = cfg or {}
		local W = Create("Frame", {
			Parent = ScreenGui, BackgroundColor3 = Library.Theme.Secondary, BorderSizePixel = 0,
			Size = UDim2.new(0, 120, 0, 50),
			Position = cfg.Position or UDim2.new(0, 14, 0, 14), ZIndex = 55,
		})
		Corner(W, 8)
		Stroke(W, Library.Theme.Stroke, 1, 0.5)
		MakeDraggable(W, W)

		local fpsLbl = Create("TextLabel", {
			Parent = W, BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 18), Position = UDim2.new(0, 8, 0, 6),
			Font = Enum.Font.GothamMedium, Text = "FPS: --", TextColor3 = Library.Theme.Text,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 56,
		})
		local msLbl = Create("TextLabel", {
			Parent = W, BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 18), Position = UDim2.new(0, 8, 0, 26),
			Font = Enum.Font.GothamMedium, Text = "MS: --", TextColor3 = Library.Theme.Text,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 56,
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
		icon = ResolveImage(icon or "rbxassetid://7733960981")

		local TabBtn = Create("TextButton", {
			Name = name, Parent = TabList,
			BackgroundColor3 = Library.Theme.Tertiary, BackgroundTransparency = 1,
			BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 34),
			Text = "", AutoButtonColor = false, ZIndex = 7,
		})
		Corner(TabBtn, 7)

		local TabIcon = Create("ImageLabel", {
			Parent = TabBtn, BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 8, 0.5, -8),
			Image = icon, ImageColor3 = Library.Theme.TextDark, ZIndex = 8,
		})
		local TabText = Create("TextLabel", {
			Parent = TabBtn, BackgroundTransparency = 1,
			Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 30, 0, 0),
			Font = Enum.Font.GothamMedium, Text = name, TextColor3 = Library.Theme.TextDark,
			TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
		})
		local Ind = Create("Frame", {
			Parent = TabBtn, BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0,
			Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), ZIndex = 9,
		})
		Corner(Ind, 1)

		local Page = Create("ScrollingFrame", {
			Name = name, Parent = Pages, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3,
			ScrollBarImageColor3 = Library.Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false, ZIndex = 6,
		})
		Pad(Page, 10, 12, 12, 12)
		Create("UIListLayout", { Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })

		local Tab = { Name = name, Button = TabBtn, Page = Page, Sections = {} }

		local function Select()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, { BackgroundTransparency = 1 }, 0.12)
				local ic = t.Button:FindFirstChildOfClass("ImageLabel")
				if ic then Tween(ic, { ImageColor3 = Library.Theme.TextDark }, 0.12) end
				local tx = t.Button:FindFirstChildOfClass("TextLabel")
				if tx then Tween(tx, { TextColor3 = Library.Theme.TextDark }, 0.12) end
				local ind = t.Button:FindFirstChild("Frame")
				if ind then Tween(ind, { Size = UDim2.new(0, 2, 0, 0) }, 0.12) end
			end
			Page.Visible = true
			Tween(TabBtn, { BackgroundTransparency = 0 }, 0.15)
			Tween(TabIcon, { ImageColor3 = Library.Theme.Accent }, 0.15)
			Tween(TabText, { TextColor3 = Library.Theme.Text }, 0.15)
			Tween(Ind, { Size = UDim2.new(0, 2, 0, 18) }, 0.15)
			Window.CurrentTab = Tab
		end

		TabBtn.MouseButton1Click:Connect(Select)
		if not Window.CurrentTab then Select() end
		table.insert(Window.Tabs, Tab)

		-- SECTION with real ↑ ↓ arrows + expand animation
		function Tab:CreateSection(sectionName)
			local Wrap = Create("Frame", {
				Name = sectionName, Parent = Page, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 7,
			})
			Create("UIListLayout", { Parent = Wrap, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })

			local Header = Create("TextButton", {
				Parent = Wrap, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20), Text = "", ZIndex = 8,
			})
			Create("TextLabel", {
				Parent = Header, BackgroundTransparency = 1,
				Size = UDim2.new(1, -24, 1, 0),
				Font = Enum.Font.GothamBold, Text = sectionName, TextColor3 = Library.Theme.Text,
				TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
			})
			local Arrow = Create("TextLabel", {
				Parent = Header, BackgroundTransparency = 1,
				Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0),
				Font = Enum.Font.GothamBold, Text = "↓", TextColor3 = Library.Theme.TextDark,
				TextSize = 12, ZIndex = 9,
			})

			local Card = Create("Frame", {
				Name = "Card", Parent = Wrap,
				BackgroundColor3 = Library.Theme.Secondary,
				BackgroundTransparency = acrylic and 0.2 or 0,
				BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 8,
			})
			Corner(Card, 8)
			Stroke(Card, Library.Theme.Stroke, 1, 0.5)
			Pad(Card, 6, 8, 8, 8)

			local Body = Create("Frame", {
				Name = "Body", Parent = Card, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 9,
			})
			Create("UIListLayout", { Parent = Body, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })

			local open = true
			Header.MouseButton1Click:Connect(function()
				open = not open
				if open then
					Card.Visible = true
					Arrow.Text = "↓"
					-- fade children in
					for _, c in ipairs(Body:GetChildren()) do
						if c:IsA("GuiObject") then
							c.BackgroundTransparency = 1
							Tween(c, { BackgroundTransparency = c:GetAttribute("OrigTrans") or 0 }, 0.2)
						end
					end
				else
					Arrow.Text = "↑"
					Card.Visible = false
				end
			end)

			local Section = { Frame = Wrap, Card = Card, Body = Body }

			-- ========== iOS LIQUID GLASS TOGGLE ==========
			function Section:CreateToggle(o)
				o = o or {}
				local text = o.Name or o.Text or "Toggle"
				local default = o.Default or false
				local flag = o.Flag
				local cb = o.Callback or function() end
				local state = default
				if flag then Library.Flags[flag] = state end

				local Holder = Create("Frame", {
					Parent = Body, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32), ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, -56, 1, 0), Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Library.Theme.Text,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})

				-- Track (pill)
				local Track = Create("Frame", {
					Parent = Holder,
					BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 46, 0, 26),
					Position = UDim2.new(1, -50, 0.5, -13), ZIndex = 11,
				})
				Corner(Track, 13)

				-- Liquid blob overlay (morph effect)
				local Blob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 26, 0, 26),
					Position = state and UDim2.new(1, -26, 0, 0) or UDim2.new(0, 0, 0, 0),
					ZIndex = 12,
				})
				Corner(Blob, 13)
				Blob.BackgroundTransparency = 0.3

				-- White knob
				local Knob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 22, 0, 22),
					Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
					ZIndex = 13,
				})
				Corner(Knob, 11)

				local function Set(v, fire)
					state = v
					if flag then Library.Flags[flag] = state end

					-- liquid morph: expand blob then settle
					local targetCol = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff
					Tween(Track, { BackgroundColor3 = targetCol }, 0.25)
					Tween(Blob, {
						BackgroundColor3 = targetCol,
						Size = UDim2.new(0, 36, 0, 26),
						Position = state and UDim2.new(1, -36, 0, 0) or UDim2.new(0, 0, 0, 0),
					}, 0.12)
					task.delay(0.12, function()
						Tween(Blob, {
							Size = UDim2.new(0, 26, 0, 26),
							Position = state and UDim2.new(1, -26, 0, 0) or UDim2.new(0, 0, 0, 0),
							BackgroundTransparency = 0.35,
						}, 0.15, Enum.EasingStyle.Back)
					end)
					Tween(Knob, {
						Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
					}, 0.22, Enum.EasingStyle.Quart)

					if fire ~= false then cb(state) end
				end

				-- drag support
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
						local rel = math.clamp(input.Position.X - Track.AbsolutePosition.X - 11, 2, Track.AbsoluteSize.X - 24)
						Knob.Position = UDim2.new(0, rel, 0.5, -11)
					end
				end)

				local Click = Create("TextButton", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 14,
				})
				Click.MouseButton1Click:Connect(function() Set(not state) end)

				return { Set = Set, Get = function() return state end, Frame = Holder }
			end

			-- BUTTON
			function Section:CreateButton(o)
				o = o or {}
				local text = o.Name or o.Text or "Button"
				local cb = o.Callback or function() end

				local Btn = Create("TextButton", {
					Parent = Body, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32), Text = "", AutoButtonColor = false, ZIndex = 10,
				})
				Corner(Btn, 7)
				Stroke(Btn, Color3.fromRGB(255, 255, 255), 1, 0.85)

				Create("TextLabel", {
					Parent = Btn, BackgroundTransparency = 1,
					Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 8, 0, 0),
					Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Library.Theme.Text,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})

				Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Library.Theme.Accent }, 0.12) end)
				Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.12) end)
				Btn.MouseButton1Click:Connect(cb)
				return Btn
			end

			-- SLIDER
			function Section:CreateSlider(o)
				o = o or {}
				local text = o.Name or o.Text or "Slider"
				local min = o.Min or 0
				local max = o.Max or 100
				local default = o.Default or min
				local flag = o.Flag
				local cb = o.Callback or function() end
				local value = default
				if flag then Library.Flags[flag] = value end

				local Holder = Create("Frame", {
					Parent = Body, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 42), ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, -50, 0, 16), Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Library.Theme.Text,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})
				local ValLbl = Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(0, 48, 0, 16), Position = UDim2.new(1, -50, 0, 0),
					Font = Enum.Font.Gotham, Text = tostring(value), TextColor3 = Library.Theme.TextDark,
					TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11,
				})

				local Track = Create("Frame", {
					Parent = Holder, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 26), ZIndex = 11,
				})
				Corner(Track, 3)
				local Fill = Create("Frame", {
					Parent = Track, BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0,
					Size = UDim2.new((value - min) / (max - min), 0, 1, 0), ZIndex = 12,
				})
				Corner(Fill, 3)
				local Knob = Create("Frame", {
					Parent = Track, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
					Size = UDim2.new(0, 14, 0, 14),
					Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7), ZIndex = 13,
				})
				Corner(Knob, 7)

				local function Set(v, fire)
					value = math.clamp(math.floor(v + 0.5), min, max)
					if flag then Library.Flags[flag] = value end
					local p = (value - min) / (max - min)
					Fill.Size = UDim2.new(p, 0, 1, 0)
					Knob.Position = UDim2.new(p, -7, 0.5, -7)
					ValLbl.Text = tostring(value)
					if fire ~= false then cb(value) end
				end

				local sliding
				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						sliding = true
						local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
						Set(min + rel * (max - min))
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then sliding = false end
						end)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
						Set(min + rel * (max - min))
					end
				end)

				return { Set = Set, Get = function() return value end, Frame = Holder }
			end

			-- PROGRESS BAR
			function Section:CreateProgressBar(o)
				o = o or {}
				local text = o.Name or o.Text or "Progress"
				local default = o.Default or 0

				local Holder = Create("Frame", {
					Parent = Body, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 36), ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, -40, 0, 14), Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Library.Theme.Text,
					TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})
				local Pct = Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(0, 36, 0, 14), Position = UDim2.new(1, -38, 0, 0),
					Font = Enum.Font.Gotham, Text = "0%", TextColor3 = Library.Theme.TextDark,
					TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11,
				})
				local Track = Create("Frame", {
					Parent = Holder, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 22), ZIndex = 11,
				})
				Corner(Track, 3)
				local Fill = Create("Frame", {
					Parent = Track, BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0), ZIndex = 12,
				})
				Corner(Fill, 3)

				local function Set(v, animated)
					v = math.clamp(v, 0, 100)
					Pct.Text = math.floor(v) .. "%"
					if animated ~= false then
						Tween(Fill, { Size = UDim2.new(v / 100, 0, 1, 0) }, 0.3)
					else
						Fill.Size = UDim2.new(v / 100, 0, 1, 0)
					end
				end
				Set(default, false)
				return { Set = Set, Frame = Holder }
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
					Parent = Body, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 52), ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 2, 0, 0),
					Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Library.Theme.Text,
					TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})
				local Box = Create("TextBox", {
					Parent = Holder, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 18),
					Font = Enum.Font.Gotham, Text = def, PlaceholderText = ph,
					PlaceholderColor3 = Library.Theme.TextDark, TextColor3 = Library.Theme.Text,
					TextSize = 12, ClearTextOnFocus = false, ZIndex = 11,
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

			-- PARAGRAPH / LABEL / IMAGE / FRAME / DROPDOWN (compact)
			function Section:CreateParagraph(o)
				o = o or {}
				local Holder = Create("Frame", {
					Parent = Body, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 10,
				})
				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14),
					Font = Enum.Font.GothamBold, Text = o.Title or "Info", TextColor3 = Library.Theme.Text,
					TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})
				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 16),
					AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham,
					Text = o.Content or o.Text or "", TextColor3 = Library.Theme.TextDark,
					TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true, ZIndex = 11,
				})
				return Holder
			end

			function Section:CreateLabel(o)
				o = o or {}
				local L = Create("TextLabel", {
					Parent = Body, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
					Font = Enum.Font.Gotham, Text = o.Text or o.Name or "Label",
					TextColor3 = o.Color or Library.Theme.TextDark, TextSize = o.Size or 11,
					TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
				})
				return { Set = function(_, v) L.Text = tostring(v) end, SetColor = function(_, c) L.TextColor3 = c end, Frame = L }
			end

			function Section:CreateImage(o)
				o = o or {}
				local id = ResolveImage(o.Image or o.Id or "rbxassetid://0")
				local h = o.Height or 100
				local Holder = Create("Frame", {
					Parent = Body, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, h + 4), ZIndex = 10,
				})
				Corner(Holder, 6)
				local Img = Create("ImageLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, -8, 0, h), Position = UDim2.new(0, 4, 0, 2),
					Image = id, ScaleType = Enum.ScaleType.Fit, ZIndex = 11,
				})
				Corner(Img, 4)
				return { Frame = Holder, Image = Img, Set = function(_, id2) Img.Image = ResolveImage(id2) end }
			end

			function Section:CreateFrame(o)
				o = o or {}
				local F = Create("Frame", {
					Parent = Body,
					BackgroundColor3 = o.Color or Library.Theme.Tertiary,
					BackgroundTransparency = o.Transparency or 0.3,
					BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, o.Height or 60), ZIndex = 10,
				})
				Corner(F, o.Corner or 6)
				return F
			end

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
					if type(default) == "table" then for _, v in ipairs(default) do selected[v] = true end
					elseif default then selected[default] = true end
				else
					selected = default or list[1] or ""
				end
				if flag then Library.Flags[flag] = multi and selected or selected end

				local open = false
				local Holder = Create("Frame", {
					Parent = Body, BackgroundColor3 = Library.Theme.Tertiary, BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32), ClipsDescendants = true, ZIndex = 10,
				})
				Corner(Holder, 7)

				Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, -40, 0, 32), Position = UDim2.new(0, 8, 0, 0),
					Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Library.Theme.Text,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
				})
				local Val = Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(0, 80, 0, 32), Position = UDim2.new(1, -110, 0, 0),
					Font = Enum.Font.Gotham, Text = multi and "None" or tostring(selected),
					TextColor3 = Library.Theme.TextDark, TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 11,
				})
				local Arrow = Create("TextLabel", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(0, 20, 0, 32), Position = UDim2.new(1, -24, 0, 0),
					Font = Enum.Font.GothamBold, Text = "↓", TextColor3 = Library.Theme.TextDark,
					TextSize = 11, ZIndex = 11,
				})

				local OptList = Create("Frame", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, -8, 0, 0), Position = UDim2.new(0, 4, 0, 34), ZIndex = 12,
				})
				Create("UIListLayout", { Parent = OptList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

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
					for _, c in ipairs(OptList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
					for _, opt in ipairs(list) do
						local isSel = multi and selected[opt] or (selected == opt)
						local OB = Create("TextButton", {
							Parent = OptList,
							BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Background,
							BackgroundTransparency = isSel and 0.15 or 0.4,
							BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 24),
							Text = "", AutoButtonColor = false, ZIndex = 13,
						})
						Corner(OB, 4)
						Create("TextLabel", {
							Parent = OB, BackgroundTransparency = 1,
							Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 6, 0, 0),
							Font = Enum.Font.Gotham, Text = tostring(opt),
							TextColor3 = isSel and Color3.new(1, 1, 1) or Library.Theme.Text,
							TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
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
								Tween(Holder, { Size = UDim2.new(1, 0, 0, 32) }, 0.18)
								Arrow.Text = "↓"
							end
						end)
					end
				end
				Build()
				UpdateVal()

				local Head = Create("TextButton", {
					Parent = Holder, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32), Text = "", ZIndex = 15,
				})
				Head.MouseButton1Click:Connect(function()
					open = not open
					local h = open and (32 + #list * 26 + 8) or 32
					Tween(Holder, { Size = UDim2.new(1, 0, 0, h) }, 0.2)
					Arrow.Text = open and "↑" or "↓"
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

	function Window:Destroy() ScreenGui:Destroy() end
	function Window:SetFooter(t) FooterLabel.Text = tostring(t) end

	table.insert(Library.Windows, Window)
	return Window
end

return Library
