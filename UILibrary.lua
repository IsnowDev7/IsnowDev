--[[
	UI Library
	Features: TopBar close (X), Sidebar (width support), Tabs, Sections,
	Dropdown, MultiDropdown, Toggle, Button, Input, Paragraph,
	Resizable window, Icon support, Smooth animations
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
	Flags = {},
	Connections = {},
	Windows = {},
	Theme = {
		Background = Color3.fromRGB(18, 18, 22),
		Secondary = Color3.fromRGB(28, 28, 34),
		Tertiary = Color3.fromRGB(38, 38, 46),
		Accent = Color3.fromRGB(100, 140, 255),
		Text = Color3.fromRGB(240, 240, 245),
		TextDark = Color3.fromRGB(140, 140, 155),
		Stroke = Color3.fromRGB(50, 50, 60),
		Success = Color3.fromRGB(80, 200, 120),
		Error = Color3.fromRGB(220, 80, 80),
		ToggleOff = Color3.fromRGB(55, 55, 65),
		ToggleOn = Color3.fromRGB(100, 140, 255),
	},
}

local function ProtectGui(gui)
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = CoreGui
	elseif gethui then
		gui.Parent = gethui()
	else
		gui.Parent = CoreGui
	end
end

local function Tween(obj, props, duration, style, dir)
	duration = duration or 0.2
	style = style or Enum.EasingStyle.Quad
	dir = dir or Enum.EasingDirection.Out
	local t = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
	t:Play()
	return t
end

local function Create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			inst[k] = v
		end
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function Round(inst, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = inst
	return c
end

local function Stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Library.Theme.Stroke
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function Padding(inst, t, b, l, r)
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
	local dragging, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function MakeResizable(frame, minSize)
	minSize = minSize or Vector2.new(420, 320)
	local grip = Create("Frame", {
		Name = "ResizeGrip",
		Parent = frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -16, 1, -16),
		ZIndex = 50,
	})

	local icon = Create("ImageLabel", {
		Parent = grip,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(404, 284),
		ImageRectSize = Vector2.new(36, 36),
		ImageColor3 = Library.Theme.TextDark,
		ZIndex = 51,
	})

	local resizing = false
	local startPos, startSize

	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startPos = input.Position
			startSize = frame.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startPos
			local newX = math.max(minSize.X, startSize.X + delta.X)
			local newY = math.max(minSize.Y, startSize.Y + delta.Y)
			frame.Size = UDim2.new(0, newX, 0, newY)
		end
	end)
end

function Library:CreateWindow(options)
	options = options or {}
	local title = options.Title or "UI Library"
	local subtitle = options.Subtitle or ""
	local size = options.Size or UDim2.new(0, 560, 0, 420)
	local sidebarWidth = options.SidebarWidth or 160
	local minSize = options.MinSize or Vector2.new(420, 320)
	local iconId = options.Icon or "rbxassetid://7733960981"
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

	local ScreenGui = Create("ScreenGui", {
		Name = "UILib_" .. HttpService:GenerateGUID(false),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	ProtectGui(ScreenGui)

	local Main = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		BackgroundColor3 = Library.Theme.Background,
		BorderSizePixel = 0,
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		ClipsDescendants = true,
	})
	Round(Main, 10)
	Stroke(Main, Library.Theme.Stroke, 1)

	-- Shadow
	local Shadow = Create("ImageLabel", {
		Name = "Shadow",
		Parent = Main,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -15, 0, -15),
		Size = UDim2.new(1, 30, 1, 30),
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 0.55,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = 0,
	})

	-- TopBar
	local TopBar = Create("Frame", {
		Name = "TopBar",
		Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 42),
		ZIndex = 10,
	})
	Round(TopBar, 10)

	local TopBarCover = Create("Frame", {
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		ZIndex = 10,
	})

	local TitleIcon = Create("ImageLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(0, 12, 0.5, -11),
		Image = iconId,
		ImageColor3 = Library.Theme.Accent,
		ZIndex = 11,
	})

	local TitleLabel = Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 0, 20),
		Position = UDim2.new(0, 42, 0, 4),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Library.Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	local SubtitleLabel = Create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 0, 14),
		Position = UDim2.new(0, 42, 0, 22),
		Font = Enum.Font.Gotham,
		Text = subtitle,
		TextColor3 = Library.Theme.TextDark,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	})

	-- Close Button (X)
	local CloseBtn = Create("TextButton", {
		Name = "Close",
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Tertiary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -36, 0.5, -14),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 12,
	})
	Round(CloseBtn, 6)

	local CloseX = Create("TextLabel", {
		Parent = CloseBtn,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = Library.Theme.TextDark,
		TextSize = 18,
		ZIndex = 13,
	})

	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, { BackgroundColor3 = Library.Theme.Error }, 0.15)
		Tween(CloseX, { TextColor3 = Color3.new(1, 1, 1) }, 0.15)
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.15)
		Tween(CloseX, { TextColor3 = Library.Theme.TextDark }, 0.15)
	end)

	-- Minimize Button
	local MinBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = TopBar,
		BackgroundColor3 = Library.Theme.Tertiary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -70, 0.5, -14),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 12,
	})
	Round(MinBtn, 6)

	local MinIcon = Create("TextLabel", {
		Parent = MinBtn,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "−",
		TextColor3 = Library.Theme.TextDark,
		TextSize = 18,
		ZIndex = 13,
	})

	MinBtn.MouseEnter:Connect(function()
		Tween(MinBtn, { BackgroundColor3 = Library.Theme.Accent }, 0.15)
		Tween(MinIcon, { TextColor3 = Color3.new(1, 1, 1) }, 0.15)
	end)
	MinBtn.MouseLeave:Connect(function()
		Tween(MinBtn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.15)
		Tween(MinIcon, { TextColor3 = Library.Theme.TextDark }, 0.15)
	end)

	-- Sidebar
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = Main,
		BackgroundColor3 = Library.Theme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, sidebarWidth, 1, -42),
		Position = UDim2.new(0, 0, 0, 42),
		ZIndex = 5,
	})

	local SidebarLine = Create("Frame", {
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
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.new(0, 0, 0, 8),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Library.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 6,
	})
	Padding(TabList, 4, 8, 8, 8)

	local TabListLayout = Create("UIListLayout", {
		Parent = TabList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	})

	-- Content Area
	local Content = Create("Frame", {
		Name = "Content",
		Parent = Main,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -sidebarWidth, 1, -42),
		Position = UDim2.new(0, sidebarWidth, 0, 42),
		ClipsDescendants = true,
		ZIndex = 5,
	})

	local Pages = Create("Folder", {
		Name = "Pages",
		Parent = Content,
	})

	MakeDraggable(Main, TopBar)
	MakeResizable(Main, minSize)

	local Window = {
		ScreenGui = ScreenGui,
		Main = Main,
		Tabs = {},
		CurrentTab = nil,
		Visible = true,
		SidebarWidth = sidebarWidth,
	}

	local function SetSidebarWidth(width)
		sidebarWidth = width
		Window.SidebarWidth = width
		Tween(Sidebar, { Size = UDim2.new(0, width, 1, -42) }, 0.25)
		Tween(Content, {
			Size = UDim2.new(1, -width, 1, -42),
			Position = UDim2.new(0, width, 0, 42),
		}, 0.25)
	end
	Window.SetSidebarWidth = SetSidebarWidth

	-- Close
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(Main, { Size = UDim2.new(0, Main.AbsoluteSize.X, 0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.3, function()
			ScreenGui:Destroy()
		end)
	end)

	-- Minimize
	local minimized = false
	local savedSize
	MinBtn.MouseButton1Click:Connect(function()
		if not minimized then
			savedSize = Main.Size
			Tween(Main, { Size = UDim2.new(0, Main.AbsoluteSize.X, 0, 42) }, 0.25)
			Sidebar.Visible = false
			Content.Visible = false
			minimized = true
		else
			Tween(Main, { Size = savedSize }, 0.25)
			Sidebar.Visible = true
			Content.Visible = true
			minimized = false
		end
	end)

	-- Toggle visibility
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then
			Window.Visible = not Window.Visible
			Main.Visible = Window.Visible
		end
	end)

	function Window:CreateTab(name, icon)
		icon = icon or "rbxassetid://7733960981"

		local TabBtn = Create("TextButton", {
			Name = name,
			Parent = TabList,
			BackgroundColor3 = Library.Theme.Tertiary,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 36),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 7,
		})
		Round(TabBtn, 6)

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
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 36, 0, 0),
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = Library.Theme.TextDark,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 8,
		})

		local Indicator = Create("Frame", {
			Parent = TabBtn,
			BackgroundColor3 = Library.Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 0, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ZIndex = 9,
		})
		Round(Indicator, 2)

		local Page = Create("ScrollingFrame", {
			Name = name,
			Parent = Pages,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Library.Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 6,
		})
		Padding(Page, 12, 12, 14, 14)

		local PageLayout = Create("UIListLayout", {
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
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, { BackgroundTransparency = 1 }, 0.15)
				Tween(t.Button:FindFirstChildOfClass("ImageLabel"), { ImageColor3 = Library.Theme.TextDark }, 0.15)
				local txt = t.Button:FindFirstChildOfClass("TextLabel")
				if txt then Tween(txt, { TextColor3 = Library.Theme.TextDark }, 0.15) end
				local ind = t.Button:FindFirstChild("Frame")
				if ind and ind.Name ~= "UICorner" then
					Tween(ind, { Size = UDim2.new(0, 3, 0, 0) }, 0.15)
				end
			end

			Page.Visible = true
			Tween(TabBtn, { BackgroundTransparency = 0 }, 0.2)
			Tween(TabIcon, { ImageColor3 = Library.Theme.Accent }, 0.2)
			Tween(TabText, { TextColor3 = Library.Theme.Text }, 0.2)
			Tween(Indicator, { Size = UDim2.new(0, 3, 0, 20) }, 0.2)
			Window.CurrentTab = Tab
		end

		TabBtn.MouseButton1Click:Connect(Select)
		TabBtn.MouseEnter:Connect(function()
			if Window.CurrentTab ~= Tab then
				Tween(TabBtn, { BackgroundTransparency = 0.5 }, 0.15)
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if Window.CurrentTab ~= Tab then
				Tween(TabBtn, { BackgroundTransparency = 1 }, 0.15)
			end
		end)

		if not Window.CurrentTab then
			Select()
		end

		table.insert(Window.Tabs, Tab)

		-- Section
		function Tab:CreateSection(sectionName)
			local SectionFrame = Create("Frame", {
				Name = sectionName,
				Parent = Page,
				BackgroundColor3 = Library.Theme.Secondary,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 7,
			})
			Round(SectionFrame, 8)
			Stroke(SectionFrame, Library.Theme.Stroke, 1)

			local SectionHeader = Create("TextLabel", {
				Parent = SectionFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -20, 0, 28),
				Position = UDim2.new(0, 12, 0, 6),
				Font = Enum.Font.GothamBold,
				Text = sectionName,
				TextColor3 = Library.Theme.Text,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 8,
			})

			local SectionContent = Create("Frame", {
				Name = "Content",
				Parent = SectionFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 34),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 8,
			})
			Padding(SectionContent, 0, 10, 10, 10)

			local SectionLayout = Create("UIListLayout", {
				Parent = SectionContent,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6),
			})

			local Section = { Frame = SectionFrame, Content = SectionContent }

			local function AddElement(height)
				-- auto size handled by AutomaticSize
			end

			-- Button
			function Section:CreateButton(opts)
				opts = opts or {}
				local text = opts.Name or "Button"
				local callback = opts.Callback or function() end

				local Btn = Create("TextButton", {
					Parent = SectionContent,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
					Text = "",
					AutoButtonColor = false,
					ZIndex = 9,
				})
				Round(Btn, 6)
				Stroke(Btn, Library.Theme.Stroke, 1)

				local BtnText = Create("TextLabel", {
					Parent = Btn,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -16, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})

				Btn.MouseEnter:Connect(function()
					Tween(Btn, { BackgroundColor3 = Library.Theme.Accent }, 0.15)
				end)
				Btn.MouseLeave:Connect(function()
					Tween(Btn, { BackgroundColor3 = Library.Theme.Tertiary }, 0.15)
				end)
				Btn.MouseButton1Click:Connect(function()
					Tween(Btn, { BackgroundColor3 = Color3.fromRGB(70, 100, 200) }, 0.08)
					task.delay(0.08, function()
						Tween(Btn, { BackgroundColor3 = Library.Theme.Accent }, 0.1)
					end)
					callback()
				end)

				return Btn
			end

			-- Toggle
			function Section:CreateToggle(opts)
				opts = opts or {}
				local text = opts.Name or "Toggle"
				local default = opts.Default or false
				local flag = opts.Flag
				local callback = opts.Callback or function() end

				local state = default
				if flag then Library.Flags[flag] = state end

				local Holder = Create("Frame", {
					Parent = SectionContent,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 36),
					ZIndex = 9,
				})
				Round(Holder, 6)
				Stroke(Holder, Library.Theme.Stroke, 1)

				local Label = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -60, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})

				local Track = Create("Frame", {
					Parent = Holder,
					BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 40, 0, 22),
					Position = UDim2.new(1, -50, 0.5, -11),
					ZIndex = 10,
				})
				Round(Track, 11)

				local Knob = Create("Frame", {
					Parent = Track,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 16, 0, 16),
					Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
					ZIndex = 11,
				})
				Round(Knob, 8)

				local function Set(val, fire)
					state = val
					if flag then Library.Flags[flag] = state end
					Tween(Track, { BackgroundColor3 = state and Library.Theme.ToggleOn or Library.Theme.ToggleOff }, 0.18)
					Tween(Knob, {
						Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
					}, 0.18)
					if fire ~= false then
						callback(state)
					end
				end

				local Click = Create("TextButton", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					ZIndex = 12,
				})
				Click.MouseButton1Click:Connect(function()
					Set(not state)
				end)

				return {
					Set = Set,
					Get = function() return state end,
					Frame = Holder,
				}
			end

			-- Input
			function Section:CreateInput(opts)
				opts = opts or {}
				local text = opts.Name or "Input"
				local placeholder = opts.Placeholder or "..."
				local default = opts.Default or ""
				local flag = opts.Flag
				local callback = opts.Callback or function() end

				if flag then Library.Flags[flag] = default end

				local Holder = Create("Frame", {
					Parent = SectionContent,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 58),
					ZIndex = 9,
				})
				Round(Holder, 6)
				Stroke(Holder, Library.Theme.Stroke, 1)

				local Label = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -16, 0, 20),
					Position = UDim2.new(0, 10, 0, 4),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})

				local Box = Create("TextBox", {
					Parent = Holder,
					BackgroundColor3 = Library.Theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -20, 0, 26),
					Position = UDim2.new(0, 10, 0, 26),
					Font = Enum.Font.Gotham,
					Text = default,
					PlaceholderText = placeholder,
					PlaceholderColor3 = Library.Theme.TextDark,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
					ZIndex = 10,
				})
				Round(Box, 5)
				Padding(Box, 0, 0, 8, 8)

				Box.Focused:Connect(function()
					Tween(Box, { BackgroundColor3 = Library.Theme.Secondary }, 0.15)
				end)
				Box.FocusLost:Connect(function()
					Tween(Box, { BackgroundColor3 = Library.Theme.Background }, 0.15)
					if flag then Library.Flags[flag] = Box.Text end
					callback(Box.Text)
				end)

				return {
					Set = function(v)
						Box.Text = tostring(v)
						if flag then Library.Flags[flag] = Box.Text end
					end,
					Get = function() return Box.Text end,
					Frame = Holder,
				}
			end

			-- Paragraph
			function Section:CreateParagraph(opts)
				opts = opts or {}
				local title = opts.Title or "Paragraph"
				local content = opts.Content or ""

				local Holder = Create("Frame", {
					Parent = SectionContent,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 9,
				})
				Round(Holder, 6)
				Stroke(Holder, Library.Theme.Stroke, 1)
				Padding(Holder, 8, 10, 10, 10)

				local TitleLbl = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Font = Enum.Font.GothamBold,
					Text = title,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})

				local Body = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 22),
					Font = Enum.Font.Gotham,
					Text = content,
					TextColor3 = Library.Theme.TextDark,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 10,
				})

				return Holder
			end

			-- Dropdown
			function Section:CreateDropdown(opts)
				opts = opts or {}
				local text = opts.Name or "Dropdown"
				local list = opts.Options or {}
				local default = opts.Default
				local multi = opts.Multi or false
				local flag = opts.Flag
				local callback = opts.Callback or function() end

				local selected = multi and {} or (default or (list[1] or ""))
				if multi and default then
					if type(default) == "table" then
						for _, v in ipairs(default) do selected[v] = true end
					else
						selected[default] = true
					end
				end
				if flag then Library.Flags[flag] = multi and selected or selected end

				local open = false
				local Holder = Create("Frame", {
					Parent = SectionContent,
					BackgroundColor3 = Library.Theme.Tertiary,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 36),
					ClipsDescendants = true,
					ZIndex = 9,
				})
				Round(Holder, 6)
				Stroke(Holder, Library.Theme.Stroke, 1)

				local Label = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -40, 0, 36),
					Position = UDim2.new(0, 10, 0, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 10,
				})

				local ValueLbl = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 120, 0, 36),
					Position = UDim2.new(1, -150, 0, 0),
					Font = Enum.Font.Gotham,
					Text = multi and "None" or tostring(selected),
					TextColor3 = Library.Theme.TextDark,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 10,
				})

				local Arrow = Create("TextLabel", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 20, 0, 36),
					Position = UDim2.new(1, -28, 0, 0),
					Font = Enum.Font.GothamBold,
					Text = "▾",
					TextColor3 = Library.Theme.TextDark,
					TextSize = 14,
					ZIndex = 10,
				})

				local OptionList = Create("Frame", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -8, 0, 0),
					Position = UDim2.new(0, 4, 0, 38),
					ZIndex = 11,
				})
				local OptLayout = Create("UIListLayout", {
					Parent = OptionList,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3),
				})

				local function UpdateValueText()
					if multi then
						local t = {}
						for k, v in pairs(selected) do
							if v then table.insert(t, k) end
						end
						ValueLbl.Text = #t > 0 and table.concat(t, ", ") or "None"
						if flag then Library.Flags[flag] = selected end
					else
						ValueLbl.Text = tostring(selected)
						if flag then Library.Flags[flag] = selected end
					end
				end

				local function BuildOptions()
					for _, c in ipairs(OptionList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(list) do
						local isSel = multi and selected[opt] or (selected == opt)
						local OptBtn = Create("TextButton", {
							Parent = OptionList,
							BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Background,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 28),
							Text = "",
							AutoButtonColor = false,
							ZIndex = 12,
						})
						Round(OptBtn, 5)

						local OptText = Create("TextLabel", {
							Parent = OptBtn,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 8, 0, 0),
							Font = Enum.Font.Gotham,
							Text = tostring(opt),
							TextColor3 = isSel and Color3.new(1, 1, 1) or Library.Theme.Text,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = 13,
						})

						OptBtn.MouseButton1Click:Connect(function()
							if multi then
								selected[opt] = not selected[opt]
								Tween(OptBtn, {
									BackgroundColor3 = selected[opt] and Library.Theme.Accent or Library.Theme.Background,
								}, 0.12)
								Tween(OptText, {
									TextColor3 = selected[opt] and Color3.new(1, 1, 1) or Library.Theme.Text,
								}, 0.12)
								UpdateValueText()
								local vals = {}
								for k, v in pairs(selected) do
									if v then table.insert(vals, k) end
								end
								callback(vals)
							else
								selected = opt
								UpdateValueText()
								callback(opt)
								-- close
								open = false
								Tween(Holder, { Size = UDim2.new(1, 0, 0, 36) }, 0.2)
								Tween(Arrow, { Rotation = 0 }, 0.2)
								BuildOptions()
							end
						end)
					end
				end

				BuildOptions()

				local HeaderClick = Create("TextButton", {
					Parent = Holder,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 36),
					Text = "",
					ZIndex = 14,
				})
				HeaderClick.MouseButton1Click:Connect(function()
					open = not open
					local targetH = open and (36 + (#list * 31) + 8) or 36
					Tween(Holder, { Size = UDim2.new(1, 0, 0, targetH) }, 0.22)
					Tween(Arrow, { Rotation = open and 180 or 0 }, 0.22)
					if open then BuildOptions() end
				end)

				UpdateValueText()

				return {
					Set = function(val)
						if multi then
							selected = {}
							if type(val) == "table" then
								for _, v in ipairs(val) do selected[v] = true end
							end
						else
							selected = val
						end
						UpdateValueText()
						BuildOptions()
					end,
					Get = function()
						if multi then
							local t = {}
							for k, v in pairs(selected) do if v then table.insert(t, k) end end
							return t
						end
						return selected
					end,
					Refresh = function(newList)
						list = newList or list
						BuildOptions()
					end,
					Frame = Holder,
				}
			end

			-- MultiDropdown alias
			function Section:CreateMultiDropdown(opts)
				opts = opts or {}
				opts.Multi = true
				return Section:CreateDropdown(opts)
			end

			table.insert(Tab.Sections, Section)
			return Section
		end

		return Tab
	end

	function Window:Notify(title, content, duration)
		duration = duration or 3
		local Notif = Create("Frame", {
			Parent = ScreenGui,
			BackgroundColor3 = Library.Theme.Secondary,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 280, 0, 70),
			Position = UDim2.new(1, 20, 1, -90),
			ZIndex = 100,
		})
		Round(Notif, 8)
		Stroke(Notif, Library.Theme.Accent, 1)

		local NTitle = Create("TextLabel", {
			Parent = Notif,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 22),
			Position = UDim2.new(0, 12, 0, 8),
			Font = Enum.Font.GothamBold,
			Text = title or "Notification",
			TextColor3 = Library.Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 101,
		})

		local NBody = Create("TextLabel", {
			Parent = Notif,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 12, 0, 30),
			Font = Enum.Font.Gotham,
			Text = content or "",
			TextColor3 = Library.Theme.TextDark,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 101,
		})

		Tween(Notif, { Position = UDim2.new(1, -300, 1, -90) }, 0.3, Enum.EasingStyle.Back)
		task.delay(duration, function()
			Tween(Notif, { Position = UDim2.new(1, 20, 1, -90) }, 0.25)
			task.delay(0.3, function()
				Notif:Destroy()
			end)
		end)
	end

	function Window:Destroy()
		ScreenGui:Destroy()
	end

	table.insert(Library.Windows, Window)
	return Window
end

return Library
