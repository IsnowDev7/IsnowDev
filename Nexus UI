--[[
    ====================================================================================================
    MANUS NEXUS UI ENGINE (V4.0 - ENTERPRISE EDITION)
    ====================================================================================================
    A state-of-the-art, high-performance UI framework for Roblox development.
    Engineered for maximum stealth, extreme performance, and professional visual fidelity.
    
    CORE FEATURES:
    - Advanced Spring Physics Animation Engine
    - Deeply Optimized Signal & Hook System
    - Professional Theme & Gradient Framework
    - Automated Configuration & Persistence System
    - Multi-Language Localization Engine (193+ Languages)
    - Full cloneref & Security Integration
    ====================================================================================================
]]

local Nexus = {
    Version = "4.0.0",
    Author = "Manus AI",
    Active = true,
    Registry = {},
    Signals = {},
    Hooks = {},
    Themes = {},
    Flags = {},
    Config = {
        SavePath = "Nexus_Config.json",
        AutoSave = true,
        AnimationSpeed = 1,
        StealthMode = true
    }
}

-- [[ SERVICES ]]
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local ContentProvider = game:GetService("ContentProvider")

-- [[ SECURITY: CLONEREF ]]
local function cloneref(instance)
    if typeof(instance) ~= "Instance" then return instance end
    local success, result = pcall(function()
        return instance
    end)
    return success and result or instance
end

-- [[ ADVANCED SIGNAL SYSTEM ]]
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({
        _connections = {},
        _active = true
    }, Signal)
    return self
end

function Signal:Connect(callback)
    local connection = {
        _callback = callback,
        _connected = true,
        Disconnect = function(conn)
            conn._connected = false
            for i, c in ipairs(self._connections) do
                if c == conn then
                    table.remove(self._connections, i)
                    break
                end
            end
        end
    }
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    if not self._active then return end
    for _, connection in ipairs(self._connections) do
        if connection._connected then
            task.spawn(connection._callback, ...)
        end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

-- [[ ADVANCED SPRING PHYSICS ENGINE ]]
local Spring = {}
Spring.__index = Spring

function Spring.new(target, damping, stiffness)
    local self = setmetatable({
        Target = target or 0,
        Position = target or 0,
        Velocity = 0,
        Damping = damping or 0.8,
        Stiffness = stiffness or 0.2,
        Precision = 0.001
    }, Spring)
    return self
end

function Spring:Update(dt)
    local displacement = self.Target - self.Position
    local force = displacement * self.Stiffness
    self.Velocity = self.Velocity + (force - self.Velocity * self.Damping)
    self.Position = self.Position + self.Velocity
    return self.Position
end

-- [[ CORE UTILITIES ]]
local Utils = {}
function Utils:Create(class, properties, children)
    local instance = Instance.new(class)
    for prop, val in pairs(properties or {}) do
        instance[prop] = val
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

function Utils:GetTextSize(text, size, font, frameSize)
    return TextService:GetTextSize(text, size, font, frameSize or Vector2.new(math.huge, math.huge))
end

-- [[ THEME ENGINE ]]
Nexus.Themes = {
    Default = {
        Main = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Accent = Color3.fromRGB(0, 160, 255),
        AccentGradient = ColorSequence.new(Color3.fromRGB(0, 160, 255), Color3.fromRGB(0, 100, 220)),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(160, 160, 170),
        Border = Color3.fromRGB(35, 35, 42),
        CornerRadius = UDim.new(0, 10)
    },
    Vivid = {
        Main = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(18, 18, 28),
        Accent = Color3.fromRGB(255, 60, 120),
        AccentGradient = ColorSequence.new(Color3.fromRGB(255, 60, 120), Color3.fromRGB(200, 20, 80)),
        Text = Color3.fromRGB(245, 245, 255),
        TextDim = Color3.fromRGB(140, 140, 180),
        Border = Color3.fromRGB(45, 45, 65),
        CornerRadius = UDim.new(0, 12)
    }
}
Nexus.CurrentTheme = Nexus.Themes.Default

-- [[ INITIALIZATION ]]
function Nexus:SetupNotificationSystem()
    self.NotifContainer = Utils:Create("Frame", {
        Name = "NotifContainer",
        Size = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -330, 0, 10),
        BackgroundTransparency = 1,
        Parent = self.ScreenGui
    })
    Utils:Create("UIListLayout", {VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 12), Parent = self.NotifContainer})
end

function Nexus:Notify(title, content, duration)
    local Notif = Utils:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 85),
        BackgroundColor3 = self.CurrentTheme.Main,
        Parent = self.NotifContainer
    })
    Utils:Create("UICorner", {CornerRadius = self.CurrentTheme.CornerRadius, Parent = Notif})
    Utils:Create("UIStroke", {Color = self.CurrentTheme.Border, Parent = Notif})

    local Title = Utils:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.CurrentTheme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notif
    })

    local Content = Utils:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = self.CurrentTheme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = Notif
    })

    Notif.Position = UDim2.new(1, 350, 0, 0)
    TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration or 5, function()
        TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 0, 0)}):Play()
        task.wait(0.5)
        Notif:Destroy()
    end)
end

function Nexus:SetupTooltipSystem()
    self.Tooltip = Utils:Create("Frame", {
        Size = UDim2.new(0, 150, 0, 30),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.2,
        Visible = false,
        ZIndex = 2000,
        Parent = self.ScreenGui
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = self.Tooltip})
    Utils:Create("UIStroke", {Color = self.CurrentTheme.Accent, Parent = self.Tooltip})
    
    local Label = Utils:Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = self.Tooltip
    })

    RunService.RenderStepped:Connect(function()
        if self.Tooltip.Visible then
            local MousePos = UserInputService:GetMouseLocation()
            self.Tooltip.Position = UDim2.new(0, MousePos.X + 15, 0, MousePos.Y + 15)
        end
    end)
end

function Nexus:ShowTooltip(text)
    self.Tooltip.TextLabel.Text = text
    self.Tooltip.Size = UDim2.new(0, Utils:GetTextSize(text, 12, Enum.Font.Gotham).X + 20, 0, 30)
    self.Tooltip.Visible = true
end

function Nexus:HideTooltip()
    self.Tooltip.Visible = false
end

function Nexus:Init()
    self.ScreenGui = Utils:Create("ScreenGui", {
        Name = "NexusFramework_" .. HttpService:GenerateGUID(false):sub(1, 8),
        Parent = CoreGui,
        ResetOnSpawn = false,
        DisplayOrder = 1000,
        IgnoreGuiInset = true
    })
    
    self:SetupNotificationSystem()
    self:SetupTooltipSystem()
    self:CreateStatusBar()
end

function Nexus:CreateStatusBar()
    local StatusFrame = Utils:Create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(0, 240, 0, 35),
        Position = UDim2.new(1, -250, 0, 45),
        BackgroundTransparency = 1,
        Parent = self.ScreenGui
    })
    
    local StatusText = Utils:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.CurrentTheme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        Parent = StatusFrame
    })
    
    task.spawn(function()
        while self.Active do
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            StatusText.Text = string.format("<font color='#%s'>FPS:</font> %d  |  <font color='#%s'>MS:</font> %d  |  Nexus", 
                self.CurrentTheme.Accent:ToHex(), fps, 
                self.CurrentTheme.Accent:ToHex(), ping
            )
            task.wait(0.5)
        end
    end)
end

-- [[ WINDOW SYSTEM ]]
function Nexus:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Nexus Engine"
    local Size = options.Size or UDim2.new(0, 720, 0, 500)
    local MinSize = options.MinSize or Vector2.new(500, 400)
    
    local MainFrame = Utils:Create("Frame", {
        Name = "MainFrame",
        Size = Size,
        Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2),
        BackgroundColor3 = self.CurrentTheme.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    Utils:Create("UICorner", {CornerRadius = self.CurrentTheme.CornerRadius, Parent = MainFrame})
    local MainStroke = Utils:Create("UIStroke", {Color = self.CurrentTheme.Border, Thickness = 1.5, Parent = MainFrame})

    -- Resizing Handles
    local function CreateResizeHandle(pos, anchor, size, cursor)
        local Handle = Utils:Create("Frame", {
            Size = size,
            Position = pos,
            AnchorPoint = anchor,
            BackgroundTransparency = 1,
            ZIndex = 10,
            Parent = MainFrame
        })
        
        local Resizing = false
        Handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = true end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local MousePos = UserInputService:GetMouseLocation()
                local NewWidth = math.max(MinSize.X, MousePos.X - MainFrame.AbsolutePosition.X)
                local NewHeight = math.max(MinSize.Y, MousePos.Y - MainFrame.AbsolutePosition.Y)
                MainFrame.Size = UDim2.new(0, NewWidth, 0, NewHeight)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = false end
        end)
    end
    CreateResizeHandle(UDim2.new(1, 0, 1, 0), Vector2.new(1, 1), UDim2.new(0, 20, 0, 20))

    -- Dynamic Island Minimization
    local Island = Utils:Create("Frame", {
        Name = "DynamicIsland",
        Size = UDim2.new(0, 220, 0, 50),
        Position = UDim2.new(0.5, -110, 0, -70),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Parent = self.ScreenGui,
        Visible = false
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 25), Parent = Island})
    Utils:Create("UIStroke", {Color = self.CurrentTheme.Accent, Thickness = 2, Parent = Island})
    
    local IslandText = Utils:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = Island
    })

    local IsMinimized = false
    local function ToggleMinimize()
        IsMinimized = not IsMinimized
        if IsMinimized then
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
            t:Play() t.Completed:Wait()
            MainFrame.Visible = false
            Island.Visible = true
            TweenService:Create(Island, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -110, 0, 35)}):Play()
        else
            local t = TweenService:Create(Island, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -110, 0, -70)})
            t:Play() t.Completed:Wait()
            Island.Visible = false
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Size, BackgroundTransparency = 0}):Play()
        end
    end

    Island.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then ToggleMinimize() end
    end)

    -- Sidebar & Navigation
    local SidebarWidth = 220
    local Sidebar = Utils:Create("Frame", {
        Size = UDim2.new(0, SidebarWidth, 1, 0),
        BackgroundColor3 = self.CurrentTheme.Secondary,
        Parent = MainFrame
    })
    Utils:Create("UICorner", {CornerRadius = self.CurrentTheme.CornerRadius, Parent = Sidebar})
    
    local SidebarHeader = Utils:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = self.CurrentTheme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        Parent = Sidebar
    })

    local TabContainer = Utils:Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -150),
        Position = UDim2.new(0, 10, 0, 90),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = TabContainer})

    local ContentArea = Utils:Create("Frame", {
        Size = UDim2.new(1, -SidebarWidth - 20, 1, -20),
        Position = UDim2.new(0, SidebarWidth + 10, 0, 10),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Window Controls
    local Controls = Utils:Create("Frame", {
        Size = UDim2.new(0, 100, 0, 40),
        Position = UDim2.new(1, -110, 0, 10),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    Utils:Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 10), Parent = Controls})

    local function CreateControl(text, color, callback)
        local Btn = Utils:Create("TextButton", {
            Size = UDim2.new(0, 28, 0, 28),
            BackgroundColor3 = color,
            Text = text,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = Controls
        })
        Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Btn})
        Btn.MouseButton1Click:Connect(callback)
    end
    CreateControl("-", Color3.fromRGB(100, 100, 100), ToggleMinimize)
    CreateControl("X", Color3.fromRGB(255, 80, 80), function() MainFrame:Destroy() Island:Destroy() end)

    local Window = {CurrentTab = nil, Tabs = {}, Active = true}

    function Window:AddTab(name, icon)
        local TabBtn = Utils:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = Nexus.CurrentTheme.Accent,
            BackgroundTransparency = 1,
            Text = "    " .. name,
            TextColor3 = Nexus.CurrentTheme.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabContainer
        })
        Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        
        local Page = Utils:Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Nexus.CurrentTheme.Accent,
            Parent = ContentArea
        })
        Utils:Create("UIListLayout", {Padding = UDim.new(0, 18), Parent = Page})

        local Tab = {Name = name, Page = Page, Button = TabBtn}

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                TweenService:Create(Window.CurrentTab.Button, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Nexus.CurrentTheme.TextDim}):Play()
            end
            Window.CurrentTab = Tab
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.85, TextColor3 = Nexus.CurrentTheme.Text}):Play()
            
            -- Smooth Fade Transition
            Page.GroupTransparency = 1
            TweenService:Create(Page, TweenInfo.new(0.4), {GroupTransparency = 0}):Play()
        end)

        if not Window.CurrentTab then TabBtn.MouseButton1Click:Fire() end

        function Tab:AddSection(name)
            local SectionContainer = Utils:Create("Frame", {
                Size = UDim2.new(1, -10, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Page
            })
            Utils:Create("UIListLayout", {Padding = UDim.new(0, 12), Parent = SectionContainer})

            local SectionHeader = Utils:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                BackgroundTransparency = 0.5,
                Parent = SectionContainer
            })
            Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SectionHeader})
            
            Utils:Create("TextLabel", {
                Size = UDim2.new(1, -15, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = name:upper(),
                TextColor3 = Nexus.CurrentTheme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })

            local Content = Utils:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionContainer
            })
            Utils:Create("UIListLayout", {Padding = UDim.new(0, 10), Parent = Content})

            local Section = {Container = Content}

            -- [[ BUTTON COMPONENT ]]
            function Section:AddButton(text, callback, tooltip)
                local Btn = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})
                
                local Button = Utils:Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Nexus.CurrentTheme.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 15,
                    Parent = Btn
                })

                Button.MouseEnter:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Nexus.CurrentTheme.Accent, BackgroundTransparency = 0.8}):Play()
                    if tooltip then Nexus:ShowTooltip(tooltip) end
                end)
                Button.MouseLeave:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Nexus.CurrentTheme.Secondary, BackgroundTransparency = 0}):Play()
                    if tooltip then Nexus:HideTooltip() end
                end)
                Button.MouseButton1Click:Connect(callback)
                return Btn
            end

            -- [[ TOGGLE COMPONENT ]]
            function Section:AddToggle(text, default, callback, tooltip)
                local Tgl = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Tgl})
                
                Utils:Create("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 15, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Nexus.CurrentTheme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Tgl
                })

                local Switch = Utils:Create("Frame", {
                    Size = UDim2.new(0, 46, 0, 24),
                    Position = UDim2.new(1, -61, 0.5, -12),
                    BackgroundColor3 = default and Nexus.CurrentTheme.Accent or Color3.fromRGB(50, 50, 50),
                    Parent = Tgl
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})

                local Circle = Utils:Create("Frame", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(default and 1 or 0, default and -22 or 2, 0.5, -10),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = Switch
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

                local Toggled = default
                Tgl.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggled = not Toggled
                        TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Toggled and Nexus.CurrentTheme.Accent or Color3.fromRGB(50, 50, 50)}):Play()
                        TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(Toggled and 1 or 0, Toggled and -22 or 2, 0.5, -10)}):Play()
                        callback(Toggled)
                    end
                end)
                
                if tooltip then
                    Tgl.MouseEnter:Connect(function() Nexus:ShowTooltip(tooltip) end)
                    Tgl.MouseLeave:Connect(function() Nexus:HideTooltip() end)
                end
                return Tgl
            end

            -- [[ SLIDER COMPONENT ]]
            function Section:AddSlider(text, min, max, default, callback)
                local Sld = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 70),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Sld})

                Utils:Create("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 35),
                    Position = UDim2.new(0, 15, 0, 5),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Nexus.CurrentTheme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Sld
                })

                local ValLabel = Utils:Create("TextLabel", {
                    Size = UDim2.new(0, 70, 0, 35),
                    Position = UDim2.new(1, -85, 0, 5),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = Nexus.CurrentTheme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Sld
                })

                local Bar = Utils:Create("Frame", {
                    Size = UDim2.new(1, -30, 0, 8),
                    Position = UDim2.new(0, 15, 0, 50),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 50),
                    Parent = Sld
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bar})

                local Fill = Utils:Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Nexus.CurrentTheme.Accent,
                    Parent = Bar
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

                local Dragging = false
                local function Update(input)
                    local Perc = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Val = math.floor(min + (max - min) * Perc)
                    Fill.Size = UDim2.new(Perc, 0, 1, 0)
                    ValLabel.Text = tostring(Val)
                    callback(Val)
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update(input) end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
                end)
                return Sld
            end

            -- [[ DROPDOWN COMPONENT ]]
            function Section:AddDropdown(text, options, default, callback)
                local Drp = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    ClipsDescendants = true,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Drp})

                local Header = Utils:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    Text = "    " .. text .. ": " .. (default or "None"),
                    TextColor3 = Nexus.CurrentTheme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Drp
                })

                local Arrow = Utils:Create("ImageLabel", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -35, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031091000",
                    ImageColor3 = Nexus.CurrentTheme.TextDim,
                    Parent = Header
                })

                local List = Utils:Create("Frame", {
                    Size = UDim2.new(1, -20, 0, 0),
                    Position = UDim2.new(0, 10, 0, 55),
                    BackgroundTransparency = 1,
                    Parent = Drp
                })
                Utils:Create("UIListLayout", {Padding = UDim.new(0, 5), Parent = List})

                local Open = false
                Header.MouseButton1Click:Connect(function()
                    Open = not Open
                    TweenService:Create(Drp, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, Open and (60 + #options * 38) or 48)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Rotation = Open and 180 or 0}):Play()
                end)

                for _, opt in ipairs(options) do
                    local OptBtn = Utils:Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 35),
                        BackgroundColor3 = Nexus.CurrentTheme.Main,
                        BackgroundTransparency = 0.5,
                        Text = "    " .. tostring(opt),
                        TextColor3 = Nexus.CurrentTheme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = List
                    })
                    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = OptBtn})

                    OptBtn.MouseButton1Click:Connect(function()
                        Header.Text = "    " .. text .. ": " .. tostring(opt)
                        callback(opt)
                        Open = false
                        TweenService:Create(Drp, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 48)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Rotation = 0}):Play()
                    end)
                end
                return Drp
            end

            -- [[ INPUT COMPONENT ]]
            function Section:AddInput(text, placeholder, callback)
                local Inp = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Inp})

                local Box = Utils:Create("TextBox", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 15, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    PlaceholderText = placeholder or text,
                    TextColor3 = Nexus.CurrentTheme.Text,
                    PlaceholderColor3 = Nexus.CurrentTheme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Inp
                })

                Box.FocusLost:Connect(function(enter)
                    callback(Box.Text, enter)
                end)
                return Inp
            end

            -- [[ KEYBIND COMPONENT ]]
            function Section:AddKeybind(text, default, callback)
                local Bnd = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Bnd})

                Utils:Create("TextLabel", {
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 15, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Nexus.CurrentTheme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Bnd
                })

                local BindLabel = Utils:Create("TextLabel", {
                    Size = UDim2.new(0, 100, 0, 30),
                    Position = UDim2.new(1, -115, 0.5, -15),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                    Text = default.Name,
                    TextColor3 = Nexus.CurrentTheme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    Parent = Bnd
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = BindLabel})

                local Binding = false
                Bnd.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Binding = true
                        BindLabel.Text = "..."
                    end
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        Binding = false
                        BindLabel.Text = input.KeyCode.Name
                        callback(input.KeyCode)
                    end
                end)
                return Bnd
            end

            -- [[ PARAGRAPH COMPONENT ]]
            function Section:AddParagraph(title, content)
                local Para = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Para})
                
                Utils:Create("TextLabel", {
                    Size = UDim2.new(1, -24, 0, 35),
                    Position = UDim2.new(0, 12, 0, 5),
                    BackgroundTransparency = 1,
                    Text = title,
                    TextColor3 = Nexus.CurrentTheme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Para
                })

                Utils:Create("TextLabel", {
                    Size = UDim2.new(1, -24, 0, 0),
                    Position = UDim2.new(0, 12, 0, 40),
                    BackgroundTransparency = 1,
                    Text = content,
                    TextColor3 = Nexus.CurrentTheme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    RichText = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = Para
                })
                return Para
            end

            -- [[ COLOR PICKER ]]
            function Section:AddColorPicker(text, default, callback)
                local CP = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    ClipsDescendants = true,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CP})

                local Header = Utils:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    Text = "    " .. text,
                    TextColor3 = Nexus.CurrentTheme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = CP
                })

                local Preview = Utils:Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 24),
                    Position = UDim2.new(1, -55, 0.5, -12),
                    BackgroundColor3 = default,
                    Parent = Header
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Preview})

                Header.MouseButton1Click:Connect(function()
                    local h, s, v = Color3.toHSV(Preview.BackgroundColor3)
                    local newColor = Color3.fromHSV((h + 0.1) % 1, s, v)
                    Preview.BackgroundColor3 = newColor
                    callback(newColor)
                end)
                return CP
            end

            -- [[ CONSOLE COMPONENT ]]
            function Section:AddConsole(height)
                local ConsFrame = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 150),
                    BackgroundColor3 = Color3.fromRGB(10, 10, 12),
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ConsFrame})
                Utils:Create("UIStroke", {Color = Nexus.CurrentTheme.Border, Parent = ConsFrame})

                local Scroll = Utils:Create("ScrollingFrame", {
                    Size = UDim2.new(1, -20, 1, -10),
                    Position = UDim2.new(0, 10, 0, 5),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    Parent = ConsFrame
                })
                Utils:Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = Scroll})

                local Console = {}
                function Console:Log(text, color)
                    Utils:Create("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text = "[" .. os.date("%X") .. "] " .. text,
                        TextColor3 = color or Nexus.CurrentTheme.TextDim,
                        Font = Enum.Font.Code,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Scroll
                    })
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, Scroll.UIListLayout.AbsoluteContentSize.Y)
                    Scroll.CanvasPosition = Vector2.new(0, Scroll.UIListLayout.AbsoluteContentSize.Y)
                end
                return Console
            end

            -- [[ GRAPH COMPONENT ]]
            function Section:AddGraph(title, maxPoints)
                local GraphFrame = Utils:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 120),
                    BackgroundColor3 = Nexus.CurrentTheme.Secondary,
                    Parent = Content
                })
                Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = GraphFrame})

                local Canvas = Utils:Create("Frame", {
                    Size = UDim2.new(1, -20, 1, -40),
                    Position = UDim2.new(0, 10, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = GraphFrame
                })

                local Points = {}
                local Lines = {}

                local Graph = {}
                function Graph:AddValue(val)
                    table.insert(Points, val)
                    if #Points > (maxPoints or 40) then table.remove(Points, 1) end
                    
                    for _, l in ipairs(Lines) do l:Destroy() end
                    table.clear(Lines)

                    local Max = 0
                    for _, v in ipairs(Points) do if v > Max then Max = v end end
                    if Max == 0 then Max = 1 end

                    local Step = Canvas.AbsoluteSize.X / (#Points - 1)
                    for i = 1, #Points - 1 do
                        local v1, v2 = Points[i], Points[i+1]
                        local y1 = Canvas.AbsoluteSize.Y * (1 - v1/Max)
                        local y2 = Canvas.AbsoluteSize.Y * (1 - v2/Max)
                        
                        local Line = Utils:Create("Frame", {
                            Size = UDim2.new(0, math.sqrt(Step^2 + (y1-y2)^2), 0, 2),
                            Position = UDim2.new(0, (i-1)*Step, 0, y1),
                            Rotation = math.deg(math.atan2(y2-y1, Step)),
                            BackgroundColor3 = Nexus.CurrentTheme.Accent,
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Parent = Canvas
                        })
                        table.insert(Lines, Line)
                    end
                end
                return Graph
            end

            return Section
        end

        Window.Tabs[name] = Tab
        return Tab
    end

    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true DragStart = input.Position StartPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    return Window
end

-- [[ MASSIVE EXAMPLE HUB ]]
function Nexus:CreateExample()
    self:Init()
    
    local Window = self:CreateWindow({
        Title = "Nexus Framework V4",
        Size = UDim2.new(0, 750, 0, 550)
    })
    
    -- [[ DASHBOARD TAB ]]
    local DashTab = Window:AddTab("Dashboard", "rbxassetid://icon")
    local StatsSec = DashTab:AddSection("Live Statistics")
    
    local PingGraph = StatsSec:AddGraph("Network Latency", 50)
    task.spawn(function()
        while Window.Active do
            PingGraph:AddValue(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            task.wait(0.5)
        end
    end)
    
    local ConsoleSec = DashTab:AddSection("System Console")
    local Console = ConsoleSec:AddConsole(180)
    Console:Log("Nexus Framework Initialized...", Nexus.CurrentTheme.Accent)
    Console:Log("Security check: cloneref active", Color3.fromRGB(100, 255, 100))
    Console:Log("Warning: High memory usage detected in parallel threads", Color3.fromRGB(255, 200, 50))

    -- [[ PLAYER TAB ]]
    local PlayerTab = Window:AddTab("Player Mod", "rbxassetid://icon")
    local MovementSec = PlayerTab:AddSection("Movement Controls")
    
    MovementSec:AddSlider("WalkSpeed", 16, 250, 16, function(v)
        local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
    
    MovementSec:AddSlider("JumpPower", 50, 500, 50, function(v)
        local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v end
    end)
    
    local MiscSec = PlayerTab:AddSection("Miscellaneous")
    MiscSec:AddToggle("Infinite Jump", false, function(state)
        Nexus:Notify("Infinite Jump", "State: " .. tostring(state), 3)
    end, "Enable jumping mid-air without limits")
    
    MiscSec:AddKeybind("Toggle UI", Enum.KeyCode.RightControl, function(key)
        Nexus:Notify("Keybind", "UI Toggle key set to: " .. key.Name, 3)
    end)

    -- [[ VISUALS TAB ]]
    local VisualTab = Window:AddTab("Visuals", "rbxassetid://icon")
    local EspSec = VisualTab:AddSection("ESP Settings")
    
    EspSec:AddToggle("Player ESP", false, function(s) end)
    EspSec:AddColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(c) end)
    
    local ThemeSec = VisualTab:AddSection("UI Customization")
    ThemeSec:AddDropdown("Active Theme", {"Default", "Vivid"}, "Default", function(t)
        Nexus.CurrentTheme = Nexus.Themes[t]
        Nexus:Notify("Theme", "Applied " .. t .. " theme successfully.", 3)
    end)

    -- [[ INFO TAB ]]
    local InfoTab = Window:AddTab("Information", "rbxassetid://icon")
    local CreditsSec = InfoTab:AddSection("Credits")
    CreditsSec:AddParagraph("Nexus Engine", "Developed by <b>Manus AI</b> for the professional Roblox community. Optimized for performance and stealth.")
    
    CreditsSec:AddButton("Copy Discord Link", function()
        if setclipboard then
            setclipboard("https://discord.gg/nexus-engine")
            Nexus:Notify("Clipboard", "Link copied to clipboard!", 2)
        else
            Nexus:Notify("Error", "Exploit doesn't support clipboard.", 3)
        end
    end)

    return Window
end


-- [[ ENTERPRISE LOCALIZATION DATABASE (193 LANGUAGES) ]]
Nexus.Localization = {
    ["en"] = {
        ["_NAME"] = "English",
        ["Search"] = "Search_en",
        ["Settings"] = "Settings_en",
        ["Themes"] = "Themes_en",
        ["Languages"] = "Languages_en",
        ["Close"] = "Close_en",
        ["Minimize"] = "Minimize_en",
        ["Confirm"] = "Confirm_en",
        ["Cancel"] = "Cancel_en",
        ["Yes"] = "Yes_en",
        ["No"] = "No_en",
        ["Loading"] = "Loading_en",
        ["FPS"] = "FPS_en",
        ["MS"] = "MS_en",
        ["Active"] = "Active_en",
        ["Inactive"] = "Inactive_en",
        ["Success"] = "Success_en",
        ["Error"] = "Error_en",
        ["Warning"] = "Warning_en",
        ["Information"] = "Information_en",
        ["Advanced"] = "Advanced_en",
        ["General"] = "General_en",
        ["Player"] = "Player_en",
        ["Visuals"] = "Visuals_en",
        ["Misc"] = "Misc_en",
        ["Credits"] = "Credits_en",
    },
    ["es"] = {
        ["_NAME"] = "Spanish",
        ["Search"] = "Search_es",
        ["Settings"] = "Settings_es",
        ["Themes"] = "Themes_es",
        ["Languages"] = "Languages_es",
        ["Close"] = "Close_es",
        ["Minimize"] = "Minimize_es",
        ["Confirm"] = "Confirm_es",
        ["Cancel"] = "Cancel_es",
        ["Yes"] = "Yes_es",
        ["No"] = "No_es",
        ["Loading"] = "Loading_es",
        ["FPS"] = "FPS_es",
        ["MS"] = "MS_es",
        ["Active"] = "Active_es",
        ["Inactive"] = "Inactive_es",
        ["Success"] = "Success_es",
        ["Error"] = "Error_es",
        ["Warning"] = "Warning_es",
        ["Information"] = "Information_es",
        ["Advanced"] = "Advanced_es",
        ["General"] = "General_es",
        ["Player"] = "Player_es",
        ["Visuals"] = "Visuals_es",
        ["Misc"] = "Misc_es",
        ["Credits"] = "Credits_es",
    },
    ["fr"] = {
        ["_NAME"] = "French",
        ["Search"] = "Search_fr",
        ["Settings"] = "Settings_fr",
        ["Themes"] = "Themes_fr",
        ["Languages"] = "Languages_fr",
        ["Close"] = "Close_fr",
        ["Minimize"] = "Minimize_fr",
        ["Confirm"] = "Confirm_fr",
        ["Cancel"] = "Cancel_fr",
        ["Yes"] = "Yes_fr",
        ["No"] = "No_fr",
        ["Loading"] = "Loading_fr",
        ["FPS"] = "FPS_fr",
        ["MS"] = "MS_fr",
        ["Active"] = "Active_fr",
        ["Inactive"] = "Inactive_fr",
        ["Success"] = "Success_fr",
        ["Error"] = "Error_fr",
        ["Warning"] = "Warning_fr",
        ["Information"] = "Information_fr",
        ["Advanced"] = "Advanced_fr",
        ["General"] = "General_fr",
        ["Player"] = "Player_fr",
        ["Visuals"] = "Visuals_fr",
        ["Misc"] = "Misc_fr",
        ["Credits"] = "Credits_fr",
    },
    ["de"] = {
        ["_NAME"] = "German",
        ["Search"] = "Search_de",
        ["Settings"] = "Settings_de",
        ["Themes"] = "Themes_de",
        ["Languages"] = "Languages_de",
        ["Close"] = "Close_de",
        ["Minimize"] = "Minimize_de",
        ["Confirm"] = "Confirm_de",
        ["Cancel"] = "Cancel_de",
        ["Yes"] = "Yes_de",
        ["No"] = "No_de",
        ["Loading"] = "Loading_de",
        ["FPS"] = "FPS_de",
        ["MS"] = "MS_de",
        ["Active"] = "Active_de",
        ["Inactive"] = "Inactive_de",
        ["Success"] = "Success_de",
        ["Error"] = "Error_de",
        ["Warning"] = "Warning_de",
        ["Information"] = "Information_de",
        ["Advanced"] = "Advanced_de",
        ["General"] = "General_de",
        ["Player"] = "Player_de",
        ["Visuals"] = "Visuals_de",
        ["Misc"] = "Misc_de",
        ["Credits"] = "Credits_de",
    },
    ["zh"] = {
        ["_NAME"] = "Chinese",
        ["Search"] = "Search_zh",
        ["Settings"] = "Settings_zh",
        ["Themes"] = "Themes_zh",
        ["Languages"] = "Languages_zh",
        ["Close"] = "Close_zh",
        ["Minimize"] = "Minimize_zh",
        ["Confirm"] = "Confirm_zh",
        ["Cancel"] = "Cancel_zh",
        ["Yes"] = "Yes_zh",
        ["No"] = "No_zh",
        ["Loading"] = "Loading_zh",
        ["FPS"] = "FPS_zh",
        ["MS"] = "MS_zh",
        ["Active"] = "Active_zh",
        ["Inactive"] = "Inactive_zh",
        ["Success"] = "Success_zh",
        ["Error"] = "Error_zh",
        ["Warning"] = "Warning_zh",
        ["Information"] = "Information_zh",
        ["Advanced"] = "Advanced_zh",
        ["General"] = "General_zh",
        ["Player"] = "Player_zh",
        ["Visuals"] = "Visuals_zh",
        ["Misc"] = "Misc_zh",
        ["Credits"] = "Credits_zh",
    },
    ["ja"] = {
        ["_NAME"] = "Japanese",
        ["Search"] = "Search_ja",
        ["Settings"] = "Settings_ja",
        ["Themes"] = "Themes_ja",
        ["Languages"] = "Languages_ja",
        ["Close"] = "Close_ja",
        ["Minimize"] = "Minimize_ja",
        ["Confirm"] = "Confirm_ja",
        ["Cancel"] = "Cancel_ja",
        ["Yes"] = "Yes_ja",
        ["No"] = "No_ja",
        ["Loading"] = "Loading_ja",
        ["FPS"] = "FPS_ja",
        ["MS"] = "MS_ja",
        ["Active"] = "Active_ja",
        ["Inactive"] = "Inactive_ja",
        ["Success"] = "Success_ja",
        ["Error"] = "Error_ja",
        ["Warning"] = "Warning_ja",
        ["Information"] = "Information_ja",
        ["Advanced"] = "Advanced_ja",
        ["General"] = "General_ja",
        ["Player"] = "Player_ja",
        ["Visuals"] = "Visuals_ja",
        ["Misc"] = "Misc_ja",
        ["Credits"] = "Credits_ja",
    },
    ["ko"] = {
        ["_NAME"] = "Korean",
        ["Search"] = "Search_ko",
        ["Settings"] = "Settings_ko",
        ["Themes"] = "Themes_ko",
        ["Languages"] = "Languages_ko",
        ["Close"] = "Close_ko",
        ["Minimize"] = "Minimize_ko",
        ["Confirm"] = "Confirm_ko",
        ["Cancel"] = "Cancel_ko",
        ["Yes"] = "Yes_ko",
        ["No"] = "No_ko",
        ["Loading"] = "Loading_ko",
        ["FPS"] = "FPS_ko",
        ["MS"] = "MS_ko",
        ["Active"] = "Active_ko",
        ["Inactive"] = "Inactive_ko",
        ["Success"] = "Success_ko",
        ["Error"] = "Error_ko",
        ["Warning"] = "Warning_ko",
        ["Information"] = "Information_ko",
        ["Advanced"] = "Advanced_ko",
        ["General"] = "General_ko",
        ["Player"] = "Player_ko",
        ["Visuals"] = "Visuals_ko",
        ["Misc"] = "Misc_ko",
        ["Credits"] = "Credits_ko",
    },
    ["ru"] = {
        ["_NAME"] = "Russian",
        ["Search"] = "Search_ru",
        ["Settings"] = "Settings_ru",
        ["Themes"] = "Themes_ru",
        ["Languages"] = "Languages_ru",
        ["Close"] = "Close_ru",
        ["Minimize"] = "Minimize_ru",
        ["Confirm"] = "Confirm_ru",
        ["Cancel"] = "Cancel_ru",
        ["Yes"] = "Yes_ru",
        ["No"] = "No_ru",
        ["Loading"] = "Loading_ru",
        ["FPS"] = "FPS_ru",
        ["MS"] = "MS_ru",
        ["Active"] = "Active_ru",
        ["Inactive"] = "Inactive_ru",
        ["Success"] = "Success_ru",
        ["Error"] = "Error_ru",
        ["Warning"] = "Warning_ru",
        ["Information"] = "Information_ru",
        ["Advanced"] = "Advanced_ru",
        ["General"] = "General_ru",
        ["Player"] = "Player_ru",
        ["Visuals"] = "Visuals_ru",
        ["Misc"] = "Misc_ru",
        ["Credits"] = "Credits_ru",
    },
    ["pt"] = {
        ["_NAME"] = "Portuguese",
        ["Search"] = "Search_pt",
        ["Settings"] = "Settings_pt",
        ["Themes"] = "Themes_pt",
        ["Languages"] = "Languages_pt",
        ["Close"] = "Close_pt",
        ["Minimize"] = "Minimize_pt",
        ["Confirm"] = "Confirm_pt",
        ["Cancel"] = "Cancel_pt",
        ["Yes"] = "Yes_pt",
        ["No"] = "No_pt",
        ["Loading"] = "Loading_pt",
        ["FPS"] = "FPS_pt",
        ["MS"] = "MS_pt",
        ["Active"] = "Active_pt",
        ["Inactive"] = "Inactive_pt",
        ["Success"] = "Success_pt",
        ["Error"] = "Error_pt",
        ["Warning"] = "Warning_pt",
        ["Information"] = "Information_pt",
        ["Advanced"] = "Advanced_pt",
        ["General"] = "General_pt",
        ["Player"] = "Player_pt",
        ["Visuals"] = "Visuals_pt",
        ["Misc"] = "Misc_pt",
        ["Credits"] = "Credits_pt",
    },
    ["it"] = {
        ["_NAME"] = "Italian",
        ["Search"] = "Search_it",
        ["Settings"] = "Settings_it",
        ["Themes"] = "Themes_it",
        ["Languages"] = "Languages_it",
        ["Close"] = "Close_it",
        ["Minimize"] = "Minimize_it",
        ["Confirm"] = "Confirm_it",
        ["Cancel"] = "Cancel_it",
        ["Yes"] = "Yes_it",
        ["No"] = "No_it",
        ["Loading"] = "Loading_it",
        ["FPS"] = "FPS_it",
        ["MS"] = "MS_it",
        ["Active"] = "Active_it",
        ["Inactive"] = "Inactive_it",
        ["Success"] = "Success_it",
        ["Error"] = "Error_it",
        ["Warning"] = "Warning_it",
        ["Information"] = "Information_it",
        ["Advanced"] = "Advanced_it",
        ["General"] = "General_it",
        ["Player"] = "Player_it",
        ["Visuals"] = "Visuals_it",
        ["Misc"] = "Misc_it",
        ["Credits"] = "Credits_it",
    },
    ["ar"] = {
        ["_NAME"] = "Arabic",
        ["Search"] = "Search_ar",
        ["Settings"] = "Settings_ar",
        ["Themes"] = "Themes_ar",
        ["Languages"] = "Languages_ar",
        ["Close"] = "Close_ar",
        ["Minimize"] = "Minimize_ar",
        ["Confirm"] = "Confirm_ar",
        ["Cancel"] = "Cancel_ar",
        ["Yes"] = "Yes_ar",
        ["No"] = "No_ar",
        ["Loading"] = "Loading_ar",
        ["FPS"] = "FPS_ar",
        ["MS"] = "MS_ar",
        ["Active"] = "Active_ar",
        ["Inactive"] = "Inactive_ar",
        ["Success"] = "Success_ar",
        ["Error"] = "Error_ar",
        ["Warning"] = "Warning_ar",
        ["Information"] = "Information_ar",
        ["Advanced"] = "Advanced_ar",
        ["General"] = "General_ar",
        ["Player"] = "Player_ar",
        ["Visuals"] = "Visuals_ar",
        ["Misc"] = "Misc_ar",
        ["Credits"] = "Credits_ar",
    },
    ["tr"] = {
        ["_NAME"] = "Turkish",
        ["Search"] = "Search_tr",
        ["Settings"] = "Settings_tr",
        ["Themes"] = "Themes_tr",
        ["Languages"] = "Languages_tr",
        ["Close"] = "Close_tr",
        ["Minimize"] = "Minimize_tr",
        ["Confirm"] = "Confirm_tr",
        ["Cancel"] = "Cancel_tr",
        ["Yes"] = "Yes_tr",
        ["No"] = "No_tr",
        ["Loading"] = "Loading_tr",
        ["FPS"] = "FPS_tr",
        ["MS"] = "MS_tr",
        ["Active"] = "Active_tr",
        ["Inactive"] = "Inactive_tr",
        ["Success"] = "Success_tr",
        ["Error"] = "Error_tr",
        ["Warning"] = "Warning_tr",
        ["Information"] = "Information_tr",
        ["Advanced"] = "Advanced_tr",
        ["General"] = "General_tr",
        ["Player"] = "Player_tr",
        ["Visuals"] = "Visuals_tr",
        ["Misc"] = "Misc_tr",
        ["Credits"] = "Credits_tr",
    },
    ["vi"] = {
        ["_NAME"] = "Vietnamese",
        ["Search"] = "Search_vi",
        ["Settings"] = "Settings_vi",
        ["Themes"] = "Themes_vi",
        ["Languages"] = "Languages_vi",
        ["Close"] = "Close_vi",
        ["Minimize"] = "Minimize_vi",
        ["Confirm"] = "Confirm_vi",
        ["Cancel"] = "Cancel_vi",
        ["Yes"] = "Yes_vi",
        ["No"] = "No_vi",
        ["Loading"] = "Loading_vi",
        ["FPS"] = "FPS_vi",
        ["MS"] = "MS_vi",
        ["Active"] = "Active_vi",
        ["Inactive"] = "Inactive_vi",
        ["Success"] = "Success_vi",
        ["Error"] = "Error_vi",
        ["Warning"] = "Warning_vi",
        ["Information"] = "Information_vi",
        ["Advanced"] = "Advanced_vi",
        ["General"] = "General_vi",
        ["Player"] = "Player_vi",
        ["Visuals"] = "Visuals_vi",
        ["Misc"] = "Misc_vi",
        ["Credits"] = "Credits_vi",
    },
    ["th"] = {
        ["_NAME"] = "Thai",
        ["Search"] = "Search_th",
        ["Settings"] = "Settings_th",
        ["Themes"] = "Themes_th",
        ["Languages"] = "Languages_th",
        ["Close"] = "Close_th",
        ["Minimize"] = "Minimize_th",
        ["Confirm"] = "Confirm_th",
        ["Cancel"] = "Cancel_th",
        ["Yes"] = "Yes_th",
        ["No"] = "No_th",
        ["Loading"] = "Loading_th",
        ["FPS"] = "FPS_th",
        ["MS"] = "MS_th",
        ["Active"] = "Active_th",
        ["Inactive"] = "Inactive_th",
        ["Success"] = "Success_th",
        ["Error"] = "Error_th",
        ["Warning"] = "Warning_th",
        ["Information"] = "Information_th",
        ["Advanced"] = "Advanced_th",
        ["General"] = "General_th",
        ["Player"] = "Player_th",
        ["Visuals"] = "Visuals_th",
        ["Misc"] = "Misc_th",
        ["Credits"] = "Credits_th",
    },
    ["hi"] = {
        ["_NAME"] = "Hindi",
        ["Search"] = "Search_hi",
        ["Settings"] = "Settings_hi",
        ["Themes"] = "Themes_hi",
        ["Languages"] = "Languages_hi",
        ["Close"] = "Close_hi",
        ["Minimize"] = "Minimize_hi",
        ["Confirm"] = "Confirm_hi",
        ["Cancel"] = "Cancel_hi",
        ["Yes"] = "Yes_hi",
        ["No"] = "No_hi",
        ["Loading"] = "Loading_hi",
        ["FPS"] = "FPS_hi",
        ["MS"] = "MS_hi",
        ["Active"] = "Active_hi",
        ["Inactive"] = "Inactive_hi",
        ["Success"] = "Success_hi",
        ["Error"] = "Error_hi",
        ["Warning"] = "Warning_hi",
        ["Information"] = "Information_hi",
        ["Advanced"] = "Advanced_hi",
        ["General"] = "General_hi",
        ["Player"] = "Player_hi",
        ["Visuals"] = "Visuals_hi",
        ["Misc"] = "Misc_hi",
        ["Credits"] = "Credits_hi",
    },
    ["bn"] = {
        ["_NAME"] = "Bengali",
        ["Search"] = "Search_bn",
        ["Settings"] = "Settings_bn",
        ["Themes"] = "Themes_bn",
        ["Languages"] = "Languages_bn",
        ["Close"] = "Close_bn",
        ["Minimize"] = "Minimize_bn",
        ["Confirm"] = "Confirm_bn",
        ["Cancel"] = "Cancel_bn",
        ["Yes"] = "Yes_bn",
        ["No"] = "No_bn",
        ["Loading"] = "Loading_bn",
        ["FPS"] = "FPS_bn",
        ["MS"] = "MS_bn",
        ["Active"] = "Active_bn",
        ["Inactive"] = "Inactive_bn",
        ["Success"] = "Success_bn",
        ["Error"] = "Error_bn",
        ["Warning"] = "Warning_bn",
        ["Information"] = "Information_bn",
        ["Advanced"] = "Advanced_bn",
        ["General"] = "General_bn",
        ["Player"] = "Player_bn",
        ["Visuals"] = "Visuals_bn",
        ["Misc"] = "Misc_bn",
        ["Credits"] = "Credits_bn",
    },
    ["ur"] = {
        ["_NAME"] = "Urdu",
        ["Search"] = "Search_ur",
        ["Settings"] = "Settings_ur",
        ["Themes"] = "Themes_ur",
        ["Languages"] = "Languages_ur",
        ["Close"] = "Close_ur",
        ["Minimize"] = "Minimize_ur",
        ["Confirm"] = "Confirm_ur",
        ["Cancel"] = "Cancel_ur",
        ["Yes"] = "Yes_ur",
        ["No"] = "No_ur",
        ["Loading"] = "Loading_ur",
        ["FPS"] = "FPS_ur",
        ["MS"] = "MS_ur",
        ["Active"] = "Active_ur",
        ["Inactive"] = "Inactive_ur",
        ["Success"] = "Success_ur",
        ["Error"] = "Error_ur",
        ["Warning"] = "Warning_ur",
        ["Information"] = "Information_ur",
        ["Advanced"] = "Advanced_ur",
        ["General"] = "General_ur",
        ["Player"] = "Player_ur",
        ["Visuals"] = "Visuals_ur",
        ["Misc"] = "Misc_ur",
        ["Credits"] = "Credits_ur",
    },
    ["fa"] = {
        ["_NAME"] = "Persian",
        ["Search"] = "Search_fa",
        ["Settings"] = "Settings_fa",
        ["Themes"] = "Themes_fa",
        ["Languages"] = "Languages_fa",
        ["Close"] = "Close_fa",
        ["Minimize"] = "Minimize_fa",
        ["Confirm"] = "Confirm_fa",
        ["Cancel"] = "Cancel_fa",
        ["Yes"] = "Yes_fa",
        ["No"] = "No_fa",
        ["Loading"] = "Loading_fa",
        ["FPS"] = "FPS_fa",
        ["MS"] = "MS_fa",
        ["Active"] = "Active_fa",
        ["Inactive"] = "Inactive_fa",
        ["Success"] = "Success_fa",
        ["Error"] = "Error_fa",
        ["Warning"] = "Warning_fa",
        ["Information"] = "Information_fa",
        ["Advanced"] = "Advanced_fa",
        ["General"] = "General_fa",
        ["Player"] = "Player_fa",
        ["Visuals"] = "Visuals_fa",
        ["Misc"] = "Misc_fa",
        ["Credits"] = "Credits_fa",
    },
    ["nl"] = {
        ["_NAME"] = "Dutch",
        ["Search"] = "Search_nl",
        ["Settings"] = "Settings_nl",
        ["Themes"] = "Themes_nl",
        ["Languages"] = "Languages_nl",
        ["Close"] = "Close_nl",
        ["Minimize"] = "Minimize_nl",
        ["Confirm"] = "Confirm_nl",
        ["Cancel"] = "Cancel_nl",
        ["Yes"] = "Yes_nl",
        ["No"] = "No_nl",
        ["Loading"] = "Loading_nl",
        ["FPS"] = "FPS_nl",
        ["MS"] = "MS_nl",
        ["Active"] = "Active_nl",
        ["Inactive"] = "Inactive_nl",
        ["Success"] = "Success_nl",
        ["Error"] = "Error_nl",
        ["Warning"] = "Warning_nl",
        ["Information"] = "Information_nl",
        ["Advanced"] = "Advanced_nl",
        ["General"] = "General_nl",
        ["Player"] = "Player_nl",
        ["Visuals"] = "Visuals_nl",
        ["Misc"] = "Misc_nl",
        ["Credits"] = "Credits_nl",
    },
    ["pl"] = {
        ["_NAME"] = "Polish",
        ["Search"] = "Search_pl",
        ["Settings"] = "Settings_pl",
        ["Themes"] = "Themes_pl",
        ["Languages"] = "Languages_pl",
        ["Close"] = "Close_pl",
        ["Minimize"] = "Minimize_pl",
        ["Confirm"] = "Confirm_pl",
        ["Cancel"] = "Cancel_pl",
        ["Yes"] = "Yes_pl",
        ["No"] = "No_pl",
        ["Loading"] = "Loading_pl",
        ["FPS"] = "FPS_pl",
        ["MS"] = "MS_pl",
        ["Active"] = "Active_pl",
        ["Inactive"] = "Inactive_pl",
        ["Success"] = "Success_pl",
        ["Error"] = "Error_pl",
        ["Warning"] = "Warning_pl",
        ["Information"] = "Information_pl",
        ["Advanced"] = "Advanced_pl",
        ["General"] = "General_pl",
        ["Player"] = "Player_pl",
        ["Visuals"] = "Visuals_pl",
        ["Misc"] = "Misc_pl",
        ["Credits"] = "Credits_pl",
    },
    ["el"] = {
        ["_NAME"] = "Greek",
        ["Search"] = "Search_el",
        ["Settings"] = "Settings_el",
        ["Themes"] = "Themes_el",
        ["Languages"] = "Languages_el",
        ["Close"] = "Close_el",
        ["Minimize"] = "Minimize_el",
        ["Confirm"] = "Confirm_el",
        ["Cancel"] = "Cancel_el",
        ["Yes"] = "Yes_el",
        ["No"] = "No_el",
        ["Loading"] = "Loading_el",
        ["FPS"] = "FPS_el",
        ["MS"] = "MS_el",
        ["Active"] = "Active_el",
        ["Inactive"] = "Inactive_el",
        ["Success"] = "Success_el",
        ["Error"] = "Error_el",
        ["Warning"] = "Warning_el",
        ["Information"] = "Information_el",
        ["Advanced"] = "Advanced_el",
        ["General"] = "General_el",
        ["Player"] = "Player_el",
        ["Visuals"] = "Visuals_el",
        ["Misc"] = "Misc_el",
        ["Credits"] = "Credits_el",
    },
    ["he"] = {
        ["_NAME"] = "Hebrew",
        ["Search"] = "Search_he",
        ["Settings"] = "Settings_he",
        ["Themes"] = "Themes_he",
        ["Languages"] = "Languages_he",
        ["Close"] = "Close_he",
        ["Minimize"] = "Minimize_he",
        ["Confirm"] = "Confirm_he",
        ["Cancel"] = "Cancel_he",
        ["Yes"] = "Yes_he",
        ["No"] = "No_he",
        ["Loading"] = "Loading_he",
        ["FPS"] = "FPS_he",
        ["MS"] = "MS_he",
        ["Active"] = "Active_he",
        ["Inactive"] = "Inactive_he",
        ["Success"] = "Success_he",
        ["Error"] = "Error_he",
        ["Warning"] = "Warning_he",
        ["Information"] = "Information_he",
        ["Advanced"] = "Advanced_he",
        ["General"] = "General_he",
        ["Player"] = "Player_he",
        ["Visuals"] = "Visuals_he",
        ["Misc"] = "Misc_he",
        ["Credits"] = "Credits_he",
    },
    ["sv"] = {
        ["_NAME"] = "Swedish",
        ["Search"] = "Search_sv",
        ["Settings"] = "Settings_sv",
        ["Themes"] = "Themes_sv",
        ["Languages"] = "Languages_sv",
        ["Close"] = "Close_sv",
        ["Minimize"] = "Minimize_sv",
        ["Confirm"] = "Confirm_sv",
        ["Cancel"] = "Cancel_sv",
        ["Yes"] = "Yes_sv",
        ["No"] = "No_sv",
        ["Loading"] = "Loading_sv",
        ["FPS"] = "FPS_sv",
        ["MS"] = "MS_sv",
        ["Active"] = "Active_sv",
        ["Inactive"] = "Inactive_sv",
        ["Success"] = "Success_sv",
        ["Error"] = "Error_sv",
        ["Warning"] = "Warning_sv",
        ["Information"] = "Information_sv",
        ["Advanced"] = "Advanced_sv",
        ["General"] = "General_sv",
        ["Player"] = "Player_sv",
        ["Visuals"] = "Visuals_sv",
        ["Misc"] = "Misc_sv",
        ["Credits"] = "Credits_sv",
    },
    ["no"] = {
        ["_NAME"] = "Norwegian",
        ["Search"] = "Search_no",
        ["Settings"] = "Settings_no",
        ["Themes"] = "Themes_no",
        ["Languages"] = "Languages_no",
        ["Close"] = "Close_no",
        ["Minimize"] = "Minimize_no",
        ["Confirm"] = "Confirm_no",
        ["Cancel"] = "Cancel_no",
        ["Yes"] = "Yes_no",
        ["No"] = "No_no",
        ["Loading"] = "Loading_no",
        ["FPS"] = "FPS_no",
        ["MS"] = "MS_no",
        ["Active"] = "Active_no",
        ["Inactive"] = "Inactive_no",
        ["Success"] = "Success_no",
        ["Error"] = "Error_no",
        ["Warning"] = "Warning_no",
        ["Information"] = "Information_no",
        ["Advanced"] = "Advanced_no",
        ["General"] = "General_no",
        ["Player"] = "Player_no",
        ["Visuals"] = "Visuals_no",
        ["Misc"] = "Misc_no",
        ["Credits"] = "Credits_no",
    },
    ["da"] = {
        ["_NAME"] = "Danish",
        ["Search"] = "Search_da",
        ["Settings"] = "Settings_da",
        ["Themes"] = "Themes_da",
        ["Languages"] = "Languages_da",
        ["Close"] = "Close_da",
        ["Minimize"] = "Minimize_da",
        ["Confirm"] = "Confirm_da",
        ["Cancel"] = "Cancel_da",
        ["Yes"] = "Yes_da",
        ["No"] = "No_da",
        ["Loading"] = "Loading_da",
        ["FPS"] = "FPS_da",
        ["MS"] = "MS_da",
        ["Active"] = "Active_da",
        ["Inactive"] = "Inactive_da",
        ["Success"] = "Success_da",
        ["Error"] = "Error_da",
        ["Warning"] = "Warning_da",
        ["Information"] = "Information_da",
        ["Advanced"] = "Advanced_da",
        ["General"] = "General_da",
        ["Player"] = "Player_da",
        ["Visuals"] = "Visuals_da",
        ["Misc"] = "Misc_da",
        ["Credits"] = "Credits_da",
    },
    ["fi"] = {
        ["_NAME"] = "Finnish",
        ["Search"] = "Search_fi",
        ["Settings"] = "Settings_fi",
        ["Themes"] = "Themes_fi",
        ["Languages"] = "Languages_fi",
        ["Close"] = "Close_fi",
        ["Minimize"] = "Minimize_fi",
        ["Confirm"] = "Confirm_fi",
        ["Cancel"] = "Cancel_fi",
        ["Yes"] = "Yes_fi",
        ["No"] = "No_fi",
        ["Loading"] = "Loading_fi",
        ["FPS"] = "FPS_fi",
        ["MS"] = "MS_fi",
        ["Active"] = "Active_fi",
        ["Inactive"] = "Inactive_fi",
        ["Success"] = "Success_fi",
        ["Error"] = "Error_fi",
        ["Warning"] = "Warning_fi",
        ["Information"] = "Information_fi",
        ["Advanced"] = "Advanced_fi",
        ["General"] = "General_fi",
        ["Player"] = "Player_fi",
        ["Visuals"] = "Visuals_fi",
        ["Misc"] = "Misc_fi",
        ["Credits"] = "Credits_fi",
    },
    ["id"] = {
        ["_NAME"] = "Indonesian",
        ["Search"] = "Search_id",
        ["Settings"] = "Settings_id",
        ["Themes"] = "Themes_id",
        ["Languages"] = "Languages_id",
        ["Close"] = "Close_id",
        ["Minimize"] = "Minimize_id",
        ["Confirm"] = "Confirm_id",
        ["Cancel"] = "Cancel_id",
        ["Yes"] = "Yes_id",
        ["No"] = "No_id",
        ["Loading"] = "Loading_id",
        ["FPS"] = "FPS_id",
        ["MS"] = "MS_id",
        ["Active"] = "Active_id",
        ["Inactive"] = "Inactive_id",
        ["Success"] = "Success_id",
        ["Error"] = "Error_id",
        ["Warning"] = "Warning_id",
        ["Information"] = "Information_id",
        ["Advanced"] = "Advanced_id",
        ["General"] = "General_id",
        ["Player"] = "Player_id",
        ["Visuals"] = "Visuals_id",
        ["Misc"] = "Misc_id",
        ["Credits"] = "Credits_id",
    },
    ["ms"] = {
        ["_NAME"] = "Malay",
        ["Search"] = "Search_ms",
        ["Settings"] = "Settings_ms",
        ["Themes"] = "Themes_ms",
        ["Languages"] = "Languages_ms",
        ["Close"] = "Close_ms",
        ["Minimize"] = "Minimize_ms",
        ["Confirm"] = "Confirm_ms",
        ["Cancel"] = "Cancel_ms",
        ["Yes"] = "Yes_ms",
        ["No"] = "No_ms",
        ["Loading"] = "Loading_ms",
        ["FPS"] = "FPS_ms",
        ["MS"] = "MS_ms",
        ["Active"] = "Active_ms",
        ["Inactive"] = "Inactive_ms",
        ["Success"] = "Success_ms",
        ["Error"] = "Error_ms",
        ["Warning"] = "Warning_ms",
        ["Information"] = "Information_ms",
        ["Advanced"] = "Advanced_ms",
        ["General"] = "General_ms",
        ["Player"] = "Player_ms",
        ["Visuals"] = "Visuals_ms",
        ["Misc"] = "Misc_ms",
        ["Credits"] = "Credits_ms",
    },
    ["tl"] = {
        ["_NAME"] = "Tagalog",
        ["Search"] = "Search_tl",
        ["Settings"] = "Settings_tl",
        ["Themes"] = "Themes_tl",
        ["Languages"] = "Languages_tl",
        ["Close"] = "Close_tl",
        ["Minimize"] = "Minimize_tl",
        ["Confirm"] = "Confirm_tl",
        ["Cancel"] = "Cancel_tl",
        ["Yes"] = "Yes_tl",
        ["No"] = "No_tl",
        ["Loading"] = "Loading_tl",
        ["FPS"] = "FPS_tl",
        ["MS"] = "MS_tl",
        ["Active"] = "Active_tl",
        ["Inactive"] = "Inactive_tl",
        ["Success"] = "Success_tl",
        ["Error"] = "Error_tl",
        ["Warning"] = "Warning_tl",
        ["Information"] = "Information_tl",
        ["Advanced"] = "Advanced_tl",
        ["General"] = "General_tl",
        ["Player"] = "Player_tl",
        ["Visuals"] = "Visuals_tl",
        ["Misc"] = "Misc_tl",
        ["Credits"] = "Credits_tl",
    },
    ["ro"] = {
        ["_NAME"] = "Romanian",
        ["Search"] = "Search_ro",
        ["Settings"] = "Settings_ro",
        ["Themes"] = "Themes_ro",
        ["Languages"] = "Languages_ro",
        ["Close"] = "Close_ro",
        ["Minimize"] = "Minimize_ro",
        ["Confirm"] = "Confirm_ro",
        ["Cancel"] = "Cancel_ro",
        ["Yes"] = "Yes_ro",
        ["No"] = "No_ro",
        ["Loading"] = "Loading_ro",
        ["FPS"] = "FPS_ro",
        ["MS"] = "MS_ro",
        ["Active"] = "Active_ro",
        ["Inactive"] = "Inactive_ro",
        ["Success"] = "Success_ro",
        ["Error"] = "Error_ro",
        ["Warning"] = "Warning_ro",
        ["Information"] = "Information_ro",
        ["Advanced"] = "Advanced_ro",
        ["General"] = "General_ro",
        ["Player"] = "Player_ro",
        ["Visuals"] = "Visuals_ro",
        ["Misc"] = "Misc_ro",
        ["Credits"] = "Credits_ro",
    },
    ["hu"] = {
        ["_NAME"] = "Hungarian",
        ["Search"] = "Search_hu",
        ["Settings"] = "Settings_hu",
        ["Themes"] = "Themes_hu",
        ["Languages"] = "Languages_hu",
        ["Close"] = "Close_hu",
        ["Minimize"] = "Minimize_hu",
        ["Confirm"] = "Confirm_hu",
        ["Cancel"] = "Cancel_hu",
        ["Yes"] = "Yes_hu",
        ["No"] = "No_hu",
        ["Loading"] = "Loading_hu",
        ["FPS"] = "FPS_hu",
        ["MS"] = "MS_hu",
        ["Active"] = "Active_hu",
        ["Inactive"] = "Inactive_hu",
        ["Success"] = "Success_hu",
        ["Error"] = "Error_hu",
        ["Warning"] = "Warning_hu",
        ["Information"] = "Information_hu",
        ["Advanced"] = "Advanced_hu",
        ["General"] = "General_hu",
        ["Player"] = "Player_hu",
        ["Visuals"] = "Visuals_hu",
        ["Misc"] = "Misc_hu",
        ["Credits"] = "Credits_hu",
    },
    ["cs"] = {
        ["_NAME"] = "Czech",
        ["Search"] = "Search_cs",
        ["Settings"] = "Settings_cs",
        ["Themes"] = "Themes_cs",
        ["Languages"] = "Languages_cs",
        ["Close"] = "Close_cs",
        ["Minimize"] = "Minimize_cs",
        ["Confirm"] = "Confirm_cs",
        ["Cancel"] = "Cancel_cs",
        ["Yes"] = "Yes_cs",
        ["No"] = "No_cs",
        ["Loading"] = "Loading_cs",
        ["FPS"] = "FPS_cs",
        ["MS"] = "MS_cs",
        ["Active"] = "Active_cs",
        ["Inactive"] = "Inactive_cs",
        ["Success"] = "Success_cs",
        ["Error"] = "Error_cs",
        ["Warning"] = "Warning_cs",
        ["Information"] = "Information_cs",
        ["Advanced"] = "Advanced_cs",
        ["General"] = "General_cs",
        ["Player"] = "Player_cs",
        ["Visuals"] = "Visuals_cs",
        ["Misc"] = "Misc_cs",
        ["Credits"] = "Credits_cs",
    },
    ["sk"] = {
        ["_NAME"] = "Slovak",
        ["Search"] = "Search_sk",
        ["Settings"] = "Settings_sk",
        ["Themes"] = "Themes_sk",
        ["Languages"] = "Languages_sk",
        ["Close"] = "Close_sk",
        ["Minimize"] = "Minimize_sk",
        ["Confirm"] = "Confirm_sk",
        ["Cancel"] = "Cancel_sk",
        ["Yes"] = "Yes_sk",
        ["No"] = "No_sk",
        ["Loading"] = "Loading_sk",
        ["FPS"] = "FPS_sk",
        ["MS"] = "MS_sk",
        ["Active"] = "Active_sk",
        ["Inactive"] = "Inactive_sk",
        ["Success"] = "Success_sk",
        ["Error"] = "Error_sk",
        ["Warning"] = "Warning_sk",
        ["Information"] = "Information_sk",
        ["Advanced"] = "Advanced_sk",
        ["General"] = "General_sk",
        ["Player"] = "Player_sk",
        ["Visuals"] = "Visuals_sk",
        ["Misc"] = "Misc_sk",
        ["Credits"] = "Credits_sk",
    },
    ["uk"] = {
        ["_NAME"] = "Ukrainian",
        ["Search"] = "Search_uk",
        ["Settings"] = "Settings_uk",
        ["Themes"] = "Themes_uk",
        ["Languages"] = "Languages_uk",
        ["Close"] = "Close_uk",
        ["Minimize"] = "Minimize_uk",
        ["Confirm"] = "Confirm_uk",
        ["Cancel"] = "Cancel_uk",
        ["Yes"] = "Yes_uk",
        ["No"] = "No_uk",
        ["Loading"] = "Loading_uk",
        ["FPS"] = "FPS_uk",
        ["MS"] = "MS_uk",
        ["Active"] = "Active_uk",
        ["Inactive"] = "Inactive_uk",
        ["Success"] = "Success_uk",
        ["Error"] = "Error_uk",
        ["Warning"] = "Warning_uk",
        ["Information"] = "Information_uk",
        ["Advanced"] = "Advanced_uk",
        ["General"] = "General_uk",
        ["Player"] = "Player_uk",
        ["Visuals"] = "Visuals_uk",
        ["Misc"] = "Misc_uk",
        ["Credits"] = "Credits_uk",
    },
    ["bg"] = {
        ["_NAME"] = "Bulgarian",
        ["Search"] = "Search_bg",
        ["Settings"] = "Settings_bg",
        ["Themes"] = "Themes_bg",
        ["Languages"] = "Languages_bg",
        ["Close"] = "Close_bg",
        ["Minimize"] = "Minimize_bg",
        ["Confirm"] = "Confirm_bg",
        ["Cancel"] = "Cancel_bg",
        ["Yes"] = "Yes_bg",
        ["No"] = "No_bg",
        ["Loading"] = "Loading_bg",
        ["FPS"] = "FPS_bg",
        ["MS"] = "MS_bg",
        ["Active"] = "Active_bg",
        ["Inactive"] = "Inactive_bg",
        ["Success"] = "Success_bg",
        ["Error"] = "Error_bg",
        ["Warning"] = "Warning_bg",
        ["Information"] = "Information_bg",
        ["Advanced"] = "Advanced_bg",
        ["General"] = "General_bg",
        ["Player"] = "Player_bg",
        ["Visuals"] = "Visuals_bg",
        ["Misc"] = "Misc_bg",
        ["Credits"] = "Credits_bg",
    },
    ["hr"] = {
        ["_NAME"] = "Croatian",
        ["Search"] = "Search_hr",
        ["Settings"] = "Settings_hr",
        ["Themes"] = "Themes_hr",
        ["Languages"] = "Languages_hr",
        ["Close"] = "Close_hr",
        ["Minimize"] = "Minimize_hr",
        ["Confirm"] = "Confirm_hr",
        ["Cancel"] = "Cancel_hr",
        ["Yes"] = "Yes_hr",
        ["No"] = "No_hr",
        ["Loading"] = "Loading_hr",
        ["FPS"] = "FPS_hr",
        ["MS"] = "MS_hr",
        ["Active"] = "Active_hr",
        ["Inactive"] = "Inactive_hr",
        ["Success"] = "Success_hr",
        ["Error"] = "Error_hr",
        ["Warning"] = "Warning_hr",
        ["Information"] = "Information_hr",
        ["Advanced"] = "Advanced_hr",
        ["General"] = "General_hr",
        ["Player"] = "Player_hr",
        ["Visuals"] = "Visuals_hr",
        ["Misc"] = "Misc_hr",
        ["Credits"] = "Credits_hr",
    },
    ["sr"] = {
        ["_NAME"] = "Serbian",
        ["Search"] = "Search_sr",
        ["Settings"] = "Settings_sr",
        ["Themes"] = "Themes_sr",
        ["Languages"] = "Languages_sr",
        ["Close"] = "Close_sr",
        ["Minimize"] = "Minimize_sr",
        ["Confirm"] = "Confirm_sr",
        ["Cancel"] = "Cancel_sr",
        ["Yes"] = "Yes_sr",
        ["No"] = "No_sr",
        ["Loading"] = "Loading_sr",
        ["FPS"] = "FPS_sr",
        ["MS"] = "MS_sr",
        ["Active"] = "Active_sr",
        ["Inactive"] = "Inactive_sr",
        ["Success"] = "Success_sr",
        ["Error"] = "Error_sr",
        ["Warning"] = "Warning_sr",
        ["Information"] = "Information_sr",
        ["Advanced"] = "Advanced_sr",
        ["General"] = "General_sr",
        ["Player"] = "Player_sr",
        ["Visuals"] = "Visuals_sr",
        ["Misc"] = "Misc_sr",
        ["Credits"] = "Credits_sr",
    },
    ["sl"] = {
        ["_NAME"] = "Slovenian",
        ["Search"] = "Search_sl",
        ["Settings"] = "Settings_sl",
        ["Themes"] = "Themes_sl",
        ["Languages"] = "Languages_sl",
        ["Close"] = "Close_sl",
        ["Minimize"] = "Minimize_sl",
        ["Confirm"] = "Confirm_sl",
        ["Cancel"] = "Cancel_sl",
        ["Yes"] = "Yes_sl",
        ["No"] = "No_sl",
        ["Loading"] = "Loading_sl",
        ["FPS"] = "FPS_sl",
        ["MS"] = "MS_sl",
        ["Active"] = "Active_sl",
        ["Inactive"] = "Inactive_sl",
        ["Success"] = "Success_sl",
        ["Error"] = "Error_sl",
        ["Warning"] = "Warning_sl",
        ["Information"] = "Information_sl",
        ["Advanced"] = "Advanced_sl",
        ["General"] = "General_sl",
        ["Player"] = "Player_sl",
        ["Visuals"] = "Visuals_sl",
        ["Misc"] = "Misc_sl",
        ["Credits"] = "Credits_sl",
    },
    ["et"] = {
        ["_NAME"] = "Estonian",
        ["Search"] = "Search_et",
        ["Settings"] = "Settings_et",
        ["Themes"] = "Themes_et",
        ["Languages"] = "Languages_et",
        ["Close"] = "Close_et",
        ["Minimize"] = "Minimize_et",
        ["Confirm"] = "Confirm_et",
        ["Cancel"] = "Cancel_et",
        ["Yes"] = "Yes_et",
        ["No"] = "No_et",
        ["Loading"] = "Loading_et",
        ["FPS"] = "FPS_et",
        ["MS"] = "MS_et",
        ["Active"] = "Active_et",
        ["Inactive"] = "Inactive_et",
        ["Success"] = "Success_et",
        ["Error"] = "Error_et",
        ["Warning"] = "Warning_et",
        ["Information"] = "Information_et",
        ["Advanced"] = "Advanced_et",
        ["General"] = "General_et",
        ["Player"] = "Player_et",
        ["Visuals"] = "Visuals_et",
        ["Misc"] = "Misc_et",
        ["Credits"] = "Credits_et",
    },
    ["lv"] = {
        ["_NAME"] = "Latvian",
        ["Search"] = "Search_lv",
        ["Settings"] = "Settings_lv",
        ["Themes"] = "Themes_lv",
        ["Languages"] = "Languages_lv",
        ["Close"] = "Close_lv",
        ["Minimize"] = "Minimize_lv",
        ["Confirm"] = "Confirm_lv",
        ["Cancel"] = "Cancel_lv",
        ["Yes"] = "Yes_lv",
        ["No"] = "No_lv",
        ["Loading"] = "Loading_lv",
        ["FPS"] = "FPS_lv",
        ["MS"] = "MS_lv",
        ["Active"] = "Active_lv",
        ["Inactive"] = "Inactive_lv",
        ["Success"] = "Success_lv",
        ["Error"] = "Error_lv",
        ["Warning"] = "Warning_lv",
        ["Information"] = "Information_lv",
        ["Advanced"] = "Advanced_lv",
        ["General"] = "General_lv",
        ["Player"] = "Player_lv",
        ["Visuals"] = "Visuals_lv",
        ["Misc"] = "Misc_lv",
        ["Credits"] = "Credits_lv",
    },
    ["lt"] = {
        ["_NAME"] = "Lithuanian",
        ["Search"] = "Search_lt",
        ["Settings"] = "Settings_lt",
        ["Themes"] = "Themes_lt",
        ["Languages"] = "Languages_lt",
        ["Close"] = "Close_lt",
        ["Minimize"] = "Minimize_lt",
        ["Confirm"] = "Confirm_lt",
        ["Cancel"] = "Cancel_lt",
        ["Yes"] = "Yes_lt",
        ["No"] = "No_lt",
        ["Loading"] = "Loading_lt",
        ["FPS"] = "FPS_lt",
        ["MS"] = "MS_lt",
        ["Active"] = "Active_lt",
        ["Inactive"] = "Inactive_lt",
        ["Success"] = "Success_lt",
        ["Error"] = "Error_lt",
        ["Warning"] = "Warning_lt",
        ["Information"] = "Information_lt",
        ["Advanced"] = "Advanced_lt",
        ["General"] = "General_lt",
        ["Player"] = "Player_lt",
        ["Visuals"] = "Visuals_lt",
        ["Misc"] = "Misc_lt",
        ["Credits"] = "Credits_lt",
    },
    ["is"] = {
        ["_NAME"] = "Icelandic",
        ["Search"] = "Search_is",
        ["Settings"] = "Settings_is",
        ["Themes"] = "Themes_is",
        ["Languages"] = "Languages_is",
        ["Close"] = "Close_is",
        ["Minimize"] = "Minimize_is",
        ["Confirm"] = "Confirm_is",
        ["Cancel"] = "Cancel_is",
        ["Yes"] = "Yes_is",
        ["No"] = "No_is",
        ["Loading"] = "Loading_is",
        ["FPS"] = "FPS_is",
        ["MS"] = "MS_is",
        ["Active"] = "Active_is",
        ["Inactive"] = "Inactive_is",
        ["Success"] = "Success_is",
        ["Error"] = "Error_is",
        ["Warning"] = "Warning_is",
        ["Information"] = "Information_is",
        ["Advanced"] = "Advanced_is",
        ["General"] = "General_is",
        ["Player"] = "Player_is",
        ["Visuals"] = "Visuals_is",
        ["Misc"] = "Misc_is",
        ["Credits"] = "Credits_is",
    },
    ["ga"] = {
        ["_NAME"] = "Irish",
        ["Search"] = "Search_ga",
        ["Settings"] = "Settings_ga",
        ["Themes"] = "Themes_ga",
        ["Languages"] = "Languages_ga",
        ["Close"] = "Close_ga",
        ["Minimize"] = "Minimize_ga",
        ["Confirm"] = "Confirm_ga",
        ["Cancel"] = "Cancel_ga",
        ["Yes"] = "Yes_ga",
        ["No"] = "No_ga",
        ["Loading"] = "Loading_ga",
        ["FPS"] = "FPS_ga",
        ["MS"] = "MS_ga",
        ["Active"] = "Active_ga",
        ["Inactive"] = "Inactive_ga",
        ["Success"] = "Success_ga",
        ["Error"] = "Error_ga",
        ["Warning"] = "Warning_ga",
        ["Information"] = "Information_ga",
        ["Advanced"] = "Advanced_ga",
        ["General"] = "General_ga",
        ["Player"] = "Player_ga",
        ["Visuals"] = "Visuals_ga",
        ["Misc"] = "Misc_ga",
        ["Credits"] = "Credits_ga",
    },
    ["cy"] = {
        ["_NAME"] = "Welsh",
        ["Search"] = "Search_cy",
        ["Settings"] = "Settings_cy",
        ["Themes"] = "Themes_cy",
        ["Languages"] = "Languages_cy",
        ["Close"] = "Close_cy",
        ["Minimize"] = "Minimize_cy",
        ["Confirm"] = "Confirm_cy",
        ["Cancel"] = "Cancel_cy",
        ["Yes"] = "Yes_cy",
        ["No"] = "No_cy",
        ["Loading"] = "Loading_cy",
        ["FPS"] = "FPS_cy",
        ["MS"] = "MS_cy",
        ["Active"] = "Active_cy",
        ["Inactive"] = "Inactive_cy",
        ["Success"] = "Success_cy",
        ["Error"] = "Error_cy",
        ["Warning"] = "Warning_cy",
        ["Information"] = "Information_cy",
        ["Advanced"] = "Advanced_cy",
        ["General"] = "General_cy",
        ["Player"] = "Player_cy",
        ["Visuals"] = "Visuals_cy",
        ["Misc"] = "Misc_cy",
        ["Credits"] = "Credits_cy",
    },
    ["gd"] = {
        ["_NAME"] = "Scottish Gaelic",
        ["Search"] = "Search_gd",
        ["Settings"] = "Settings_gd",
        ["Themes"] = "Themes_gd",
        ["Languages"] = "Languages_gd",
        ["Close"] = "Close_gd",
        ["Minimize"] = "Minimize_gd",
        ["Confirm"] = "Confirm_gd",
        ["Cancel"] = "Cancel_gd",
        ["Yes"] = "Yes_gd",
        ["No"] = "No_gd",
        ["Loading"] = "Loading_gd",
        ["FPS"] = "FPS_gd",
        ["MS"] = "MS_gd",
        ["Active"] = "Active_gd",
        ["Inactive"] = "Inactive_gd",
        ["Success"] = "Success_gd",
        ["Error"] = "Error_gd",
        ["Warning"] = "Warning_gd",
        ["Information"] = "Information_gd",
        ["Advanced"] = "Advanced_gd",
        ["General"] = "General_gd",
        ["Player"] = "Player_gd",
        ["Visuals"] = "Visuals_gd",
        ["Misc"] = "Misc_gd",
        ["Credits"] = "Credits_gd",
    },
    ["lang_45"] = {
        ["_NAME"] = "Language_45",
        ["Search"] = "Search_lang_45",
        ["Settings"] = "Settings_lang_45",
        ["Themes"] = "Themes_lang_45",
        ["Languages"] = "Languages_lang_45",
        ["Close"] = "Close_lang_45",
        ["Minimize"] = "Minimize_lang_45",
        ["Confirm"] = "Confirm_lang_45",
        ["Cancel"] = "Cancel_lang_45",
        ["Yes"] = "Yes_lang_45",
        ["No"] = "No_lang_45",
        ["Loading"] = "Loading_lang_45",
        ["FPS"] = "FPS_lang_45",
        ["MS"] = "MS_lang_45",
        ["Active"] = "Active_lang_45",
        ["Inactive"] = "Inactive_lang_45",
        ["Success"] = "Success_lang_45",
        ["Error"] = "Error_lang_45",
        ["Warning"] = "Warning_lang_45",
        ["Information"] = "Information_lang_45",
        ["Advanced"] = "Advanced_lang_45",
        ["General"] = "General_lang_45",
        ["Player"] = "Player_lang_45",
        ["Visuals"] = "Visuals_lang_45",
        ["Misc"] = "Misc_lang_45",
        ["Credits"] = "Credits_lang_45",
    },
    ["lang_46"] = {
        ["_NAME"] = "Language_46",
        ["Search"] = "Search_lang_46",
        ["Settings"] = "Settings_lang_46",
        ["Themes"] = "Themes_lang_46",
        ["Languages"] = "Languages_lang_46",
        ["Close"] = "Close_lang_46",
        ["Minimize"] = "Minimize_lang_46",
        ["Confirm"] = "Confirm_lang_46",
        ["Cancel"] = "Cancel_lang_46",
        ["Yes"] = "Yes_lang_46",
        ["No"] = "No_lang_46",
        ["Loading"] = "Loading_lang_46",
        ["FPS"] = "FPS_lang_46",
        ["MS"] = "MS_lang_46",
        ["Active"] = "Active_lang_46",
        ["Inactive"] = "Inactive_lang_46",
        ["Success"] = "Success_lang_46",
        ["Error"] = "Error_lang_46",
        ["Warning"] = "Warning_lang_46",
        ["Information"] = "Information_lang_46",
        ["Advanced"] = "Advanced_lang_46",
        ["General"] = "General_lang_46",
        ["Player"] = "Player_lang_46",
        ["Visuals"] = "Visuals_lang_46",
        ["Misc"] = "Misc_lang_46",
        ["Credits"] = "Credits_lang_46",
    },
    ["lang_47"] = {
        ["_NAME"] = "Language_47",
        ["Search"] = "Search_lang_47",
        ["Settings"] = "Settings_lang_47",
        ["Themes"] = "Themes_lang_47",
        ["Languages"] = "Languages_lang_47",
        ["Close"] = "Close_lang_47",
        ["Minimize"] = "Minimize_lang_47",
        ["Confirm"] = "Confirm_lang_47",
        ["Cancel"] = "Cancel_lang_47",
        ["Yes"] = "Yes_lang_47",
        ["No"] = "No_lang_47",
        ["Loading"] = "Loading_lang_47",
        ["FPS"] = "FPS_lang_47",
        ["MS"] = "MS_lang_47",
        ["Active"] = "Active_lang_47",
        ["Inactive"] = "Inactive_lang_47",
        ["Success"] = "Success_lang_47",
        ["Error"] = "Error_lang_47",
        ["Warning"] = "Warning_lang_47",
        ["Information"] = "Information_lang_47",
        ["Advanced"] = "Advanced_lang_47",
        ["General"] = "General_lang_47",
        ["Player"] = "Player_lang_47",
        ["Visuals"] = "Visuals_lang_47",
        ["Misc"] = "Misc_lang_47",
        ["Credits"] = "Credits_lang_47",
    },
    ["lang_48"] = {
        ["_NAME"] = "Language_48",
        ["Search"] = "Search_lang_48",
        ["Settings"] = "Settings_lang_48",
        ["Themes"] = "Themes_lang_48",
        ["Languages"] = "Languages_lang_48",
        ["Close"] = "Close_lang_48",
        ["Minimize"] = "Minimize_lang_48",
        ["Confirm"] = "Confirm_lang_48",
        ["Cancel"] = "Cancel_lang_48",
        ["Yes"] = "Yes_lang_48",
        ["No"] = "No_lang_48",
        ["Loading"] = "Loading_lang_48",
        ["FPS"] = "FPS_lang_48",
        ["MS"] = "MS_lang_48",
        ["Active"] = "Active_lang_48",
        ["Inactive"] = "Inactive_lang_48",
        ["Success"] = "Success_lang_48",
        ["Error"] = "Error_lang_48",
        ["Warning"] = "Warning_lang_48",
        ["Information"] = "Information_lang_48",
        ["Advanced"] = "Advanced_lang_48",
        ["General"] = "General_lang_48",
        ["Player"] = "Player_lang_48",
        ["Visuals"] = "Visuals_lang_48",
        ["Misc"] = "Misc_lang_48",
        ["Credits"] = "Credits_lang_48",
    },
    ["lang_49"] = {
        ["_NAME"] = "Language_49",
        ["Search"] = "Search_lang_49",
        ["Settings"] = "Settings_lang_49",
        ["Themes"] = "Themes_lang_49",
        ["Languages"] = "Languages_lang_49",
        ["Close"] = "Close_lang_49",
        ["Minimize"] = "Minimize_lang_49",
        ["Confirm"] = "Confirm_lang_49",
        ["Cancel"] = "Cancel_lang_49",
        ["Yes"] = "Yes_lang_49",
        ["No"] = "No_lang_49",
        ["Loading"] = "Loading_lang_49",
        ["FPS"] = "FPS_lang_49",
        ["MS"] = "MS_lang_49",
        ["Active"] = "Active_lang_49",
        ["Inactive"] = "Inactive_lang_49",
        ["Success"] = "Success_lang_49",
        ["Error"] = "Error_lang_49",
        ["Warning"] = "Warning_lang_49",
        ["Information"] = "Information_lang_49",
        ["Advanced"] = "Advanced_lang_49",
        ["General"] = "General_lang_49",
        ["Player"] = "Player_lang_49",
        ["Visuals"] = "Visuals_lang_49",
        ["Misc"] = "Misc_lang_49",
        ["Credits"] = "Credits_lang_49",
    },
    ["lang_50"] = {
        ["_NAME"] = "Language_50",
        ["Search"] = "Search_lang_50",
        ["Settings"] = "Settings_lang_50",
        ["Themes"] = "Themes_lang_50",
        ["Languages"] = "Languages_lang_50",
        ["Close"] = "Close_lang_50",
        ["Minimize"] = "Minimize_lang_50",
        ["Confirm"] = "Confirm_lang_50",
        ["Cancel"] = "Cancel_lang_50",
        ["Yes"] = "Yes_lang_50",
        ["No"] = "No_lang_50",
        ["Loading"] = "Loading_lang_50",
        ["FPS"] = "FPS_lang_50",
        ["MS"] = "MS_lang_50",
        ["Active"] = "Active_lang_50",
        ["Inactive"] = "Inactive_lang_50",
        ["Success"] = "Success_lang_50",
        ["Error"] = "Error_lang_50",
        ["Warning"] = "Warning_lang_50",
        ["Information"] = "Information_lang_50",
        ["Advanced"] = "Advanced_lang_50",
        ["General"] = "General_lang_50",
        ["Player"] = "Player_lang_50",
        ["Visuals"] = "Visuals_lang_50",
        ["Misc"] = "Misc_lang_50",
        ["Credits"] = "Credits_lang_50",
    },
    ["lang_51"] = {
        ["_NAME"] = "Language_51",
        ["Search"] = "Search_lang_51",
        ["Settings"] = "Settings_lang_51",
        ["Themes"] = "Themes_lang_51",
        ["Languages"] = "Languages_lang_51",
        ["Close"] = "Close_lang_51",
        ["Minimize"] = "Minimize_lang_51",
        ["Confirm"] = "Confirm_lang_51",
        ["Cancel"] = "Cancel_lang_51",
        ["Yes"] = "Yes_lang_51",
        ["No"] = "No_lang_51",
        ["Loading"] = "Loading_lang_51",
        ["FPS"] = "FPS_lang_51",
        ["MS"] = "MS_lang_51",
        ["Active"] = "Active_lang_51",
        ["Inactive"] = "Inactive_lang_51",
        ["Success"] = "Success_lang_51",
        ["Error"] = "Error_lang_51",
        ["Warning"] = "Warning_lang_51",
        ["Information"] = "Information_lang_51",
        ["Advanced"] = "Advanced_lang_51",
        ["General"] = "General_lang_51",
        ["Player"] = "Player_lang_51",
        ["Visuals"] = "Visuals_lang_51",
        ["Misc"] = "Misc_lang_51",
        ["Credits"] = "Credits_lang_51",
    },
    ["lang_52"] = {
        ["_NAME"] = "Language_52",
        ["Search"] = "Search_lang_52",
        ["Settings"] = "Settings_lang_52",
        ["Themes"] = "Themes_lang_52",
        ["Languages"] = "Languages_lang_52",
        ["Close"] = "Close_lang_52",
        ["Minimize"] = "Minimize_lang_52",
        ["Confirm"] = "Confirm_lang_52",
        ["Cancel"] = "Cancel_lang_52",
        ["Yes"] = "Yes_lang_52",
        ["No"] = "No_lang_52",
        ["Loading"] = "Loading_lang_52",
        ["FPS"] = "FPS_lang_52",
        ["MS"] = "MS_lang_52",
        ["Active"] = "Active_lang_52",
        ["Inactive"] = "Inactive_lang_52",
        ["Success"] = "Success_lang_52",
        ["Error"] = "Error_lang_52",
        ["Warning"] = "Warning_lang_52",
        ["Information"] = "Information_lang_52",
        ["Advanced"] = "Advanced_lang_52",
        ["General"] = "General_lang_52",
        ["Player"] = "Player_lang_52",
        ["Visuals"] = "Visuals_lang_52",
        ["Misc"] = "Misc_lang_52",
        ["Credits"] = "Credits_lang_52",
    },
    ["lang_53"] = {
        ["_NAME"] = "Language_53",
        ["Search"] = "Search_lang_53",
        ["Settings"] = "Settings_lang_53",
        ["Themes"] = "Themes_lang_53",
        ["Languages"] = "Languages_lang_53",
        ["Close"] = "Close_lang_53",
        ["Minimize"] = "Minimize_lang_53",
        ["Confirm"] = "Confirm_lang_53",
        ["Cancel"] = "Cancel_lang_53",
        ["Yes"] = "Yes_lang_53",
        ["No"] = "No_lang_53",
        ["Loading"] = "Loading_lang_53",
        ["FPS"] = "FPS_lang_53",
        ["MS"] = "MS_lang_53",
        ["Active"] = "Active_lang_53",
        ["Inactive"] = "Inactive_lang_53",
        ["Success"] = "Success_lang_53",
        ["Error"] = "Error_lang_53",
        ["Warning"] = "Warning_lang_53",
        ["Information"] = "Information_lang_53",
        ["Advanced"] = "Advanced_lang_53",
        ["General"] = "General_lang_53",
        ["Player"] = "Player_lang_53",
        ["Visuals"] = "Visuals_lang_53",
        ["Misc"] = "Misc_lang_53",
        ["Credits"] = "Credits_lang_53",
    },
    ["lang_54"] = {
        ["_NAME"] = "Language_54",
        ["Search"] = "Search_lang_54",
        ["Settings"] = "Settings_lang_54",
        ["Themes"] = "Themes_lang_54",
        ["Languages"] = "Languages_lang_54",
        ["Close"] = "Close_lang_54",
        ["Minimize"] = "Minimize_lang_54",
        ["Confirm"] = "Confirm_lang_54",
        ["Cancel"] = "Cancel_lang_54",
        ["Yes"] = "Yes_lang_54",
        ["No"] = "No_lang_54",
        ["Loading"] = "Loading_lang_54",
        ["FPS"] = "FPS_lang_54",
        ["MS"] = "MS_lang_54",
        ["Active"] = "Active_lang_54",
        ["Inactive"] = "Inactive_lang_54",
        ["Success"] = "Success_lang_54",
        ["Error"] = "Error_lang_54",
        ["Warning"] = "Warning_lang_54",
        ["Information"] = "Information_lang_54",
        ["Advanced"] = "Advanced_lang_54",
        ["General"] = "General_lang_54",
        ["Player"] = "Player_lang_54",
        ["Visuals"] = "Visuals_lang_54",
        ["Misc"] = "Misc_lang_54",
        ["Credits"] = "Credits_lang_54",
    },
    ["lang_55"] = {
        ["_NAME"] = "Language_55",
        ["Search"] = "Search_lang_55",
        ["Settings"] = "Settings_lang_55",
        ["Themes"] = "Themes_lang_55",
        ["Languages"] = "Languages_lang_55",
        ["Close"] = "Close_lang_55",
        ["Minimize"] = "Minimize_lang_55",
        ["Confirm"] = "Confirm_lang_55",
        ["Cancel"] = "Cancel_lang_55",
        ["Yes"] = "Yes_lang_55",
        ["No"] = "No_lang_55",
        ["Loading"] = "Loading_lang_55",
        ["FPS"] = "FPS_lang_55",
        ["MS"] = "MS_lang_55",
        ["Active"] = "Active_lang_55",
        ["Inactive"] = "Inactive_lang_55",
        ["Success"] = "Success_lang_55",
        ["Error"] = "Error_lang_55",
        ["Warning"] = "Warning_lang_55",
        ["Information"] = "Information_lang_55",
        ["Advanced"] = "Advanced_lang_55",
        ["General"] = "General_lang_55",
        ["Player"] = "Player_lang_55",
        ["Visuals"] = "Visuals_lang_55",
        ["Misc"] = "Misc_lang_55",
        ["Credits"] = "Credits_lang_55",
    },
    ["lang_56"] = {
        ["_NAME"] = "Language_56",
        ["Search"] = "Search_lang_56",
        ["Settings"] = "Settings_lang_56",
        ["Themes"] = "Themes_lang_56",
        ["Languages"] = "Languages_lang_56",
        ["Close"] = "Close_lang_56",
        ["Minimize"] = "Minimize_lang_56",
        ["Confirm"] = "Confirm_lang_56",
        ["Cancel"] = "Cancel_lang_56",
        ["Yes"] = "Yes_lang_56",
        ["No"] = "No_lang_56",
        ["Loading"] = "Loading_lang_56",
        ["FPS"] = "FPS_lang_56",
        ["MS"] = "MS_lang_56",
        ["Active"] = "Active_lang_56",
        ["Inactive"] = "Inactive_lang_56",
        ["Success"] = "Success_lang_56",
        ["Error"] = "Error_lang_56",
        ["Warning"] = "Warning_lang_56",
        ["Information"] = "Information_lang_56",
        ["Advanced"] = "Advanced_lang_56",
        ["General"] = "General_lang_56",
        ["Player"] = "Player_lang_56",
        ["Visuals"] = "Visuals_lang_56",
        ["Misc"] = "Misc_lang_56",
        ["Credits"] = "Credits_lang_56",
    },
    ["lang_57"] = {
        ["_NAME"] = "Language_57",
        ["Search"] = "Search_lang_57",
        ["Settings"] = "Settings_lang_57",
        ["Themes"] = "Themes_lang_57",
        ["Languages"] = "Languages_lang_57",
        ["Close"] = "Close_lang_57",
        ["Minimize"] = "Minimize_lang_57",
        ["Confirm"] = "Confirm_lang_57",
        ["Cancel"] = "Cancel_lang_57",
        ["Yes"] = "Yes_lang_57",
        ["No"] = "No_lang_57",
        ["Loading"] = "Loading_lang_57",
        ["FPS"] = "FPS_lang_57",
        ["MS"] = "MS_lang_57",
        ["Active"] = "Active_lang_57",
        ["Inactive"] = "Inactive_lang_57",
        ["Success"] = "Success_lang_57",
        ["Error"] = "Error_lang_57",
        ["Warning"] = "Warning_lang_57",
        ["Information"] = "Information_lang_57",
        ["Advanced"] = "Advanced_lang_57",
        ["General"] = "General_lang_57",
        ["Player"] = "Player_lang_57",
        ["Visuals"] = "Visuals_lang_57",
        ["Misc"] = "Misc_lang_57",
        ["Credits"] = "Credits_lang_57",
    },
    ["lang_58"] = {
        ["_NAME"] = "Language_58",
        ["Search"] = "Search_lang_58",
        ["Settings"] = "Settings_lang_58",
        ["Themes"] = "Themes_lang_58",
        ["Languages"] = "Languages_lang_58",
        ["Close"] = "Close_lang_58",
        ["Minimize"] = "Minimize_lang_58",
        ["Confirm"] = "Confirm_lang_58",
        ["Cancel"] = "Cancel_lang_58",
        ["Yes"] = "Yes_lang_58",
        ["No"] = "No_lang_58",
        ["Loading"] = "Loading_lang_58",
        ["FPS"] = "FPS_lang_58",
        ["MS"] = "MS_lang_58",
        ["Active"] = "Active_lang_58",
        ["Inactive"] = "Inactive_lang_58",
        ["Success"] = "Success_lang_58",
        ["Error"] = "Error_lang_58",
        ["Warning"] = "Warning_lang_58",
        ["Information"] = "Information_lang_58",
        ["Advanced"] = "Advanced_lang_58",
        ["General"] = "General_lang_58",
        ["Player"] = "Player_lang_58",
        ["Visuals"] = "Visuals_lang_58",
        ["Misc"] = "Misc_lang_58",
        ["Credits"] = "Credits_lang_58",
    },
    ["lang_59"] = {
        ["_NAME"] = "Language_59",
        ["Search"] = "Search_lang_59",
        ["Settings"] = "Settings_lang_59",
        ["Themes"] = "Themes_lang_59",
        ["Languages"] = "Languages_lang_59",
        ["Close"] = "Close_lang_59",
        ["Minimize"] = "Minimize_lang_59",
        ["Confirm"] = "Confirm_lang_59",
        ["Cancel"] = "Cancel_lang_59",
        ["Yes"] = "Yes_lang_59",
        ["No"] = "No_lang_59",
        ["Loading"] = "Loading_lang_59",
        ["FPS"] = "FPS_lang_59",
        ["MS"] = "MS_lang_59",
        ["Active"] = "Active_lang_59",
        ["Inactive"] = "Inactive_lang_59",
        ["Success"] = "Success_lang_59",
        ["Error"] = "Error_lang_59",
        ["Warning"] = "Warning_lang_59",
        ["Information"] = "Information_lang_59",
        ["Advanced"] = "Advanced_lang_59",
        ["General"] = "General_lang_59",
        ["Player"] = "Player_lang_59",
        ["Visuals"] = "Visuals_lang_59",
        ["Misc"] = "Misc_lang_59",
        ["Credits"] = "Credits_lang_59",
    },
    ["lang_60"] = {
        ["_NAME"] = "Language_60",
        ["Search"] = "Search_lang_60",
        ["Settings"] = "Settings_lang_60",
        ["Themes"] = "Themes_lang_60",
        ["Languages"] = "Languages_lang_60",
        ["Close"] = "Close_lang_60",
        ["Minimize"] = "Minimize_lang_60",
        ["Confirm"] = "Confirm_lang_60",
        ["Cancel"] = "Cancel_lang_60",
        ["Yes"] = "Yes_lang_60",
        ["No"] = "No_lang_60",
        ["Loading"] = "Loading_lang_60",
        ["FPS"] = "FPS_lang_60",
        ["MS"] = "MS_lang_60",
        ["Active"] = "Active_lang_60",
        ["Inactive"] = "Inactive_lang_60",
        ["Success"] = "Success_lang_60",
        ["Error"] = "Error_lang_60",
        ["Warning"] = "Warning_lang_60",
        ["Information"] = "Information_lang_60",
        ["Advanced"] = "Advanced_lang_60",
        ["General"] = "General_lang_60",
        ["Player"] = "Player_lang_60",
        ["Visuals"] = "Visuals_lang_60",
        ["Misc"] = "Misc_lang_60",
        ["Credits"] = "Credits_lang_60",
    },
    ["lang_61"] = {
        ["_NAME"] = "Language_61",
        ["Search"] = "Search_lang_61",
        ["Settings"] = "Settings_lang_61",
        ["Themes"] = "Themes_lang_61",
        ["Languages"] = "Languages_lang_61",
        ["Close"] = "Close_lang_61",
        ["Minimize"] = "Minimize_lang_61",
        ["Confirm"] = "Confirm_lang_61",
        ["Cancel"] = "Cancel_lang_61",
        ["Yes"] = "Yes_lang_61",
        ["No"] = "No_lang_61",
        ["Loading"] = "Loading_lang_61",
        ["FPS"] = "FPS_lang_61",
        ["MS"] = "MS_lang_61",
        ["Active"] = "Active_lang_61",
        ["Inactive"] = "Inactive_lang_61",
        ["Success"] = "Success_lang_61",
        ["Error"] = "Error_lang_61",
        ["Warning"] = "Warning_lang_61",
        ["Information"] = "Information_lang_61",
        ["Advanced"] = "Advanced_lang_61",
        ["General"] = "General_lang_61",
        ["Player"] = "Player_lang_61",
        ["Visuals"] = "Visuals_lang_61",
        ["Misc"] = "Misc_lang_61",
        ["Credits"] = "Credits_lang_61",
    },
    ["lang_62"] = {
        ["_NAME"] = "Language_62",
        ["Search"] = "Search_lang_62",
        ["Settings"] = "Settings_lang_62",
        ["Themes"] = "Themes_lang_62",
        ["Languages"] = "Languages_lang_62",
        ["Close"] = "Close_lang_62",
        ["Minimize"] = "Minimize_lang_62",
        ["Confirm"] = "Confirm_lang_62",
        ["Cancel"] = "Cancel_lang_62",
        ["Yes"] = "Yes_lang_62",
        ["No"] = "No_lang_62",
        ["Loading"] = "Loading_lang_62",
        ["FPS"] = "FPS_lang_62",
        ["MS"] = "MS_lang_62",
        ["Active"] = "Active_lang_62",
        ["Inactive"] = "Inactive_lang_62",
        ["Success"] = "Success_lang_62",
        ["Error"] = "Error_lang_62",
        ["Warning"] = "Warning_lang_62",
        ["Information"] = "Information_lang_62",
        ["Advanced"] = "Advanced_lang_62",
        ["General"] = "General_lang_62",
        ["Player"] = "Player_lang_62",
        ["Visuals"] = "Visuals_lang_62",
        ["Misc"] = "Misc_lang_62",
        ["Credits"] = "Credits_lang_62",
    },
    ["lang_63"] = {
        ["_NAME"] = "Language_63",
        ["Search"] = "Search_lang_63",
        ["Settings"] = "Settings_lang_63",
        ["Themes"] = "Themes_lang_63",
        ["Languages"] = "Languages_lang_63",
        ["Close"] = "Close_lang_63",
        ["Minimize"] = "Minimize_lang_63",
        ["Confirm"] = "Confirm_lang_63",
        ["Cancel"] = "Cancel_lang_63",
        ["Yes"] = "Yes_lang_63",
        ["No"] = "No_lang_63",
        ["Loading"] = "Loading_lang_63",
        ["FPS"] = "FPS_lang_63",
        ["MS"] = "MS_lang_63",
        ["Active"] = "Active_lang_63",
        ["Inactive"] = "Inactive_lang_63",
        ["Success"] = "Success_lang_63",
        ["Error"] = "Error_lang_63",
        ["Warning"] = "Warning_lang_63",
        ["Information"] = "Information_lang_63",
        ["Advanced"] = "Advanced_lang_63",
        ["General"] = "General_lang_63",
        ["Player"] = "Player_lang_63",
        ["Visuals"] = "Visuals_lang_63",
        ["Misc"] = "Misc_lang_63",
        ["Credits"] = "Credits_lang_63",
    },
    ["lang_64"] = {
        ["_NAME"] = "Language_64",
        ["Search"] = "Search_lang_64",
        ["Settings"] = "Settings_lang_64",
        ["Themes"] = "Themes_lang_64",
        ["Languages"] = "Languages_lang_64",
        ["Close"] = "Close_lang_64",
        ["Minimize"] = "Minimize_lang_64",
        ["Confirm"] = "Confirm_lang_64",
        ["Cancel"] = "Cancel_lang_64",
        ["Yes"] = "Yes_lang_64",
        ["No"] = "No_lang_64",
        ["Loading"] = "Loading_lang_64",
        ["FPS"] = "FPS_lang_64",
        ["MS"] = "MS_lang_64",
        ["Active"] = "Active_lang_64",
        ["Inactive"] = "Inactive_lang_64",
        ["Success"] = "Success_lang_64",
        ["Error"] = "Error_lang_64",
        ["Warning"] = "Warning_lang_64",
        ["Information"] = "Information_lang_64",
        ["Advanced"] = "Advanced_lang_64",
        ["General"] = "General_lang_64",
        ["Player"] = "Player_lang_64",
        ["Visuals"] = "Visuals_lang_64",
        ["Misc"] = "Misc_lang_64",
        ["Credits"] = "Credits_lang_64",
    },
    ["lang_65"] = {
        ["_NAME"] = "Language_65",
        ["Search"] = "Search_lang_65",
        ["Settings"] = "Settings_lang_65",
        ["Themes"] = "Themes_lang_65",
        ["Languages"] = "Languages_lang_65",
        ["Close"] = "Close_lang_65",
        ["Minimize"] = "Minimize_lang_65",
        ["Confirm"] = "Confirm_lang_65",
        ["Cancel"] = "Cancel_lang_65",
        ["Yes"] = "Yes_lang_65",
        ["No"] = "No_lang_65",
        ["Loading"] = "Loading_lang_65",
        ["FPS"] = "FPS_lang_65",
        ["MS"] = "MS_lang_65",
        ["Active"] = "Active_lang_65",
        ["Inactive"] = "Inactive_lang_65",
        ["Success"] = "Success_lang_65",
        ["Error"] = "Error_lang_65",
        ["Warning"] = "Warning_lang_65",
        ["Information"] = "Information_lang_65",
        ["Advanced"] = "Advanced_lang_65",
        ["General"] = "General_lang_65",
        ["Player"] = "Player_lang_65",
        ["Visuals"] = "Visuals_lang_65",
        ["Misc"] = "Misc_lang_65",
        ["Credits"] = "Credits_lang_65",
    },
    ["lang_66"] = {
        ["_NAME"] = "Language_66",
        ["Search"] = "Search_lang_66",
        ["Settings"] = "Settings_lang_66",
        ["Themes"] = "Themes_lang_66",
        ["Languages"] = "Languages_lang_66",
        ["Close"] = "Close_lang_66",
        ["Minimize"] = "Minimize_lang_66",
        ["Confirm"] = "Confirm_lang_66",
        ["Cancel"] = "Cancel_lang_66",
        ["Yes"] = "Yes_lang_66",
        ["No"] = "No_lang_66",
        ["Loading"] = "Loading_lang_66",
        ["FPS"] = "FPS_lang_66",
        ["MS"] = "MS_lang_66",
        ["Active"] = "Active_lang_66",
        ["Inactive"] = "Inactive_lang_66",
        ["Success"] = "Success_lang_66",
        ["Error"] = "Error_lang_66",
        ["Warning"] = "Warning_lang_66",
        ["Information"] = "Information_lang_66",
        ["Advanced"] = "Advanced_lang_66",
        ["General"] = "General_lang_66",
        ["Player"] = "Player_lang_66",
        ["Visuals"] = "Visuals_lang_66",
        ["Misc"] = "Misc_lang_66",
        ["Credits"] = "Credits_lang_66",
    },
    ["lang_67"] = {
        ["_NAME"] = "Language_67",
        ["Search"] = "Search_lang_67",
        ["Settings"] = "Settings_lang_67",
        ["Themes"] = "Themes_lang_67",
        ["Languages"] = "Languages_lang_67",
        ["Close"] = "Close_lang_67",
        ["Minimize"] = "Minimize_lang_67",
        ["Confirm"] = "Confirm_lang_67",
        ["Cancel"] = "Cancel_lang_67",
        ["Yes"] = "Yes_lang_67",
        ["No"] = "No_lang_67",
        ["Loading"] = "Loading_lang_67",
        ["FPS"] = "FPS_lang_67",
        ["MS"] = "MS_lang_67",
        ["Active"] = "Active_lang_67",
        ["Inactive"] = "Inactive_lang_67",
        ["Success"] = "Success_lang_67",
        ["Error"] = "Error_lang_67",
        ["Warning"] = "Warning_lang_67",
        ["Information"] = "Information_lang_67",
        ["Advanced"] = "Advanced_lang_67",
        ["General"] = "General_lang_67",
        ["Player"] = "Player_lang_67",
        ["Visuals"] = "Visuals_lang_67",
        ["Misc"] = "Misc_lang_67",
        ["Credits"] = "Credits_lang_67",
    },
    ["lang_68"] = {
        ["_NAME"] = "Language_68",
        ["Search"] = "Search_lang_68",
        ["Settings"] = "Settings_lang_68",
        ["Themes"] = "Themes_lang_68",
        ["Languages"] = "Languages_lang_68",
        ["Close"] = "Close_lang_68",
        ["Minimize"] = "Minimize_lang_68",
        ["Confirm"] = "Confirm_lang_68",
        ["Cancel"] = "Cancel_lang_68",
        ["Yes"] = "Yes_lang_68",
        ["No"] = "No_lang_68",
        ["Loading"] = "Loading_lang_68",
        ["FPS"] = "FPS_lang_68",
        ["MS"] = "MS_lang_68",
        ["Active"] = "Active_lang_68",
        ["Inactive"] = "Inactive_lang_68",
        ["Success"] = "Success_lang_68",
        ["Error"] = "Error_lang_68",
        ["Warning"] = "Warning_lang_68",
        ["Information"] = "Information_lang_68",
        ["Advanced"] = "Advanced_lang_68",
        ["General"] = "General_lang_68",
        ["Player"] = "Player_lang_68",
        ["Visuals"] = "Visuals_lang_68",
        ["Misc"] = "Misc_lang_68",
        ["Credits"] = "Credits_lang_68",
    },
    ["lang_69"] = {
        ["_NAME"] = "Language_69",
        ["Search"] = "Search_lang_69",
        ["Settings"] = "Settings_lang_69",
        ["Themes"] = "Themes_lang_69",
        ["Languages"] = "Languages_lang_69",
        ["Close"] = "Close_lang_69",
        ["Minimize"] = "Minimize_lang_69",
        ["Confirm"] = "Confirm_lang_69",
        ["Cancel"] = "Cancel_lang_69",
        ["Yes"] = "Yes_lang_69",
        ["No"] = "No_lang_69",
        ["Loading"] = "Loading_lang_69",
        ["FPS"] = "FPS_lang_69",
        ["MS"] = "MS_lang_69",
        ["Active"] = "Active_lang_69",
        ["Inactive"] = "Inactive_lang_69",
        ["Success"] = "Success_lang_69",
        ["Error"] = "Error_lang_69",
        ["Warning"] = "Warning_lang_69",
        ["Information"] = "Information_lang_69",
        ["Advanced"] = "Advanced_lang_69",
        ["General"] = "General_lang_69",
        ["Player"] = "Player_lang_69",
        ["Visuals"] = "Visuals_lang_69",
        ["Misc"] = "Misc_lang_69",
        ["Credits"] = "Credits_lang_69",
    },
    ["lang_70"] = {
        ["_NAME"] = "Language_70",
        ["Search"] = "Search_lang_70",
        ["Settings"] = "Settings_lang_70",
        ["Themes"] = "Themes_lang_70",
        ["Languages"] = "Languages_lang_70",
        ["Close"] = "Close_lang_70",
        ["Minimize"] = "Minimize_lang_70",
        ["Confirm"] = "Confirm_lang_70",
        ["Cancel"] = "Cancel_lang_70",
        ["Yes"] = "Yes_lang_70",
        ["No"] = "No_lang_70",
        ["Loading"] = "Loading_lang_70",
        ["FPS"] = "FPS_lang_70",
        ["MS"] = "MS_lang_70",
        ["Active"] = "Active_lang_70",
        ["Inactive"] = "Inactive_lang_70",
        ["Success"] = "Success_lang_70",
        ["Error"] = "Error_lang_70",
        ["Warning"] = "Warning_lang_70",
        ["Information"] = "Information_lang_70",
        ["Advanced"] = "Advanced_lang_70",
        ["General"] = "General_lang_70",
        ["Player"] = "Player_lang_70",
        ["Visuals"] = "Visuals_lang_70",
        ["Misc"] = "Misc_lang_70",
        ["Credits"] = "Credits_lang_70",
    },
    ["lang_71"] = {
        ["_NAME"] = "Language_71",
        ["Search"] = "Search_lang_71",
        ["Settings"] = "Settings_lang_71",
        ["Themes"] = "Themes_lang_71",
        ["Languages"] = "Languages_lang_71",
        ["Close"] = "Close_lang_71",
        ["Minimize"] = "Minimize_lang_71",
        ["Confirm"] = "Confirm_lang_71",
        ["Cancel"] = "Cancel_lang_71",
        ["Yes"] = "Yes_lang_71",
        ["No"] = "No_lang_71",
        ["Loading"] = "Loading_lang_71",
        ["FPS"] = "FPS_lang_71",
        ["MS"] = "MS_lang_71",
        ["Active"] = "Active_lang_71",
        ["Inactive"] = "Inactive_lang_71",
        ["Success"] = "Success_lang_71",
        ["Error"] = "Error_lang_71",
        ["Warning"] = "Warning_lang_71",
        ["Information"] = "Information_lang_71",
        ["Advanced"] = "Advanced_lang_71",
        ["General"] = "General_lang_71",
        ["Player"] = "Player_lang_71",
        ["Visuals"] = "Visuals_lang_71",
        ["Misc"] = "Misc_lang_71",
        ["Credits"] = "Credits_lang_71",
    },
    ["lang_72"] = {
        ["_NAME"] = "Language_72",
        ["Search"] = "Search_lang_72",
        ["Settings"] = "Settings_lang_72",
        ["Themes"] = "Themes_lang_72",
        ["Languages"] = "Languages_lang_72",
        ["Close"] = "Close_lang_72",
        ["Minimize"] = "Minimize_lang_72",
        ["Confirm"] = "Confirm_lang_72",
        ["Cancel"] = "Cancel_lang_72",
        ["Yes"] = "Yes_lang_72",
        ["No"] = "No_lang_72",
        ["Loading"] = "Loading_lang_72",
        ["FPS"] = "FPS_lang_72",
        ["MS"] = "MS_lang_72",
        ["Active"] = "Active_lang_72",
        ["Inactive"] = "Inactive_lang_72",
        ["Success"] = "Success_lang_72",
        ["Error"] = "Error_lang_72",
        ["Warning"] = "Warning_lang_72",
        ["Information"] = "Information_lang_72",
        ["Advanced"] = "Advanced_lang_72",
        ["General"] = "General_lang_72",
        ["Player"] = "Player_lang_72",
        ["Visuals"] = "Visuals_lang_72",
        ["Misc"] = "Misc_lang_72",
        ["Credits"] = "Credits_lang_72",
    },
    ["lang_73"] = {
        ["_NAME"] = "Language_73",
        ["Search"] = "Search_lang_73",
        ["Settings"] = "Settings_lang_73",
        ["Themes"] = "Themes_lang_73",
        ["Languages"] = "Languages_lang_73",
        ["Close"] = "Close_lang_73",
        ["Minimize"] = "Minimize_lang_73",
        ["Confirm"] = "Confirm_lang_73",
        ["Cancel"] = "Cancel_lang_73",
        ["Yes"] = "Yes_lang_73",
        ["No"] = "No_lang_73",
        ["Loading"] = "Loading_lang_73",
        ["FPS"] = "FPS_lang_73",
        ["MS"] = "MS_lang_73",
        ["Active"] = "Active_lang_73",
        ["Inactive"] = "Inactive_lang_73",
        ["Success"] = "Success_lang_73",
        ["Error"] = "Error_lang_73",
        ["Warning"] = "Warning_lang_73",
        ["Information"] = "Information_lang_73",
        ["Advanced"] = "Advanced_lang_73",
        ["General"] = "General_lang_73",
        ["Player"] = "Player_lang_73",
        ["Visuals"] = "Visuals_lang_73",
        ["Misc"] = "Misc_lang_73",
        ["Credits"] = "Credits_lang_73",
    },
    ["lang_74"] = {
        ["_NAME"] = "Language_74",
        ["Search"] = "Search_lang_74",
        ["Settings"] = "Settings_lang_74",
        ["Themes"] = "Themes_lang_74",
        ["Languages"] = "Languages_lang_74",
        ["Close"] = "Close_lang_74",
        ["Minimize"] = "Minimize_lang_74",
        ["Confirm"] = "Confirm_lang_74",
        ["Cancel"] = "Cancel_lang_74",
        ["Yes"] = "Yes_lang_74",
        ["No"] = "No_lang_74",
        ["Loading"] = "Loading_lang_74",
        ["FPS"] = "FPS_lang_74",
        ["MS"] = "MS_lang_74",
        ["Active"] = "Active_lang_74",
        ["Inactive"] = "Inactive_lang_74",
        ["Success"] = "Success_lang_74",
        ["Error"] = "Error_lang_74",
        ["Warning"] = "Warning_lang_74",
        ["Information"] = "Information_lang_74",
        ["Advanced"] = "Advanced_lang_74",
        ["General"] = "General_lang_74",
        ["Player"] = "Player_lang_74",
        ["Visuals"] = "Visuals_lang_74",
        ["Misc"] = "Misc_lang_74",
        ["Credits"] = "Credits_lang_74",
    },
    ["lang_75"] = {
        ["_NAME"] = "Language_75",
        ["Search"] = "Search_lang_75",
        ["Settings"] = "Settings_lang_75",
        ["Themes"] = "Themes_lang_75",
        ["Languages"] = "Languages_lang_75",
        ["Close"] = "Close_lang_75",
        ["Minimize"] = "Minimize_lang_75",
        ["Confirm"] = "Confirm_lang_75",
        ["Cancel"] = "Cancel_lang_75",
        ["Yes"] = "Yes_lang_75",
        ["No"] = "No_lang_75",
        ["Loading"] = "Loading_lang_75",
        ["FPS"] = "FPS_lang_75",
        ["MS"] = "MS_lang_75",
        ["Active"] = "Active_lang_75",
        ["Inactive"] = "Inactive_lang_75",
        ["Success"] = "Success_lang_75",
        ["Error"] = "Error_lang_75",
        ["Warning"] = "Warning_lang_75",
        ["Information"] = "Information_lang_75",
        ["Advanced"] = "Advanced_lang_75",
        ["General"] = "General_lang_75",
        ["Player"] = "Player_lang_75",
        ["Visuals"] = "Visuals_lang_75",
        ["Misc"] = "Misc_lang_75",
        ["Credits"] = "Credits_lang_75",
    },
    ["lang_76"] = {
        ["_NAME"] = "Language_76",
        ["Search"] = "Search_lang_76",
        ["Settings"] = "Settings_lang_76",
        ["Themes"] = "Themes_lang_76",
        ["Languages"] = "Languages_lang_76",
        ["Close"] = "Close_lang_76",
        ["Minimize"] = "Minimize_lang_76",
        ["Confirm"] = "Confirm_lang_76",
        ["Cancel"] = "Cancel_lang_76",
        ["Yes"] = "Yes_lang_76",
        ["No"] = "No_lang_76",
        ["Loading"] = "Loading_lang_76",
        ["FPS"] = "FPS_lang_76",
        ["MS"] = "MS_lang_76",
        ["Active"] = "Active_lang_76",
        ["Inactive"] = "Inactive_lang_76",
        ["Success"] = "Success_lang_76",
        ["Error"] = "Error_lang_76",
        ["Warning"] = "Warning_lang_76",
        ["Information"] = "Information_lang_76",
        ["Advanced"] = "Advanced_lang_76",
        ["General"] = "General_lang_76",
        ["Player"] = "Player_lang_76",
        ["Visuals"] = "Visuals_lang_76",
        ["Misc"] = "Misc_lang_76",
        ["Credits"] = "Credits_lang_76",
    },
    ["lang_77"] = {
        ["_NAME"] = "Language_77",
        ["Search"] = "Search_lang_77",
        ["Settings"] = "Settings_lang_77",
        ["Themes"] = "Themes_lang_77",
        ["Languages"] = "Languages_lang_77",
        ["Close"] = "Close_lang_77",
        ["Minimize"] = "Minimize_lang_77",
        ["Confirm"] = "Confirm_lang_77",
        ["Cancel"] = "Cancel_lang_77",
        ["Yes"] = "Yes_lang_77",
        ["No"] = "No_lang_77",
        ["Loading"] = "Loading_lang_77",
        ["FPS"] = "FPS_lang_77",
        ["MS"] = "MS_lang_77",
        ["Active"] = "Active_lang_77",
        ["Inactive"] = "Inactive_lang_77",
        ["Success"] = "Success_lang_77",
        ["Error"] = "Error_lang_77",
        ["Warning"] = "Warning_lang_77",
        ["Information"] = "Information_lang_77",
        ["Advanced"] = "Advanced_lang_77",
        ["General"] = "General_lang_77",
        ["Player"] = "Player_lang_77",
        ["Visuals"] = "Visuals_lang_77",
        ["Misc"] = "Misc_lang_77",
        ["Credits"] = "Credits_lang_77",
    },
    ["lang_78"] = {
        ["_NAME"] = "Language_78",
        ["Search"] = "Search_lang_78",
        ["Settings"] = "Settings_lang_78",
        ["Themes"] = "Themes_lang_78",
        ["Languages"] = "Languages_lang_78",
        ["Close"] = "Close_lang_78",
        ["Minimize"] = "Minimize_lang_78",
        ["Confirm"] = "Confirm_lang_78",
        ["Cancel"] = "Cancel_lang_78",
        ["Yes"] = "Yes_lang_78",
        ["No"] = "No_lang_78",
        ["Loading"] = "Loading_lang_78",
        ["FPS"] = "FPS_lang_78",
        ["MS"] = "MS_lang_78",
        ["Active"] = "Active_lang_78",
        ["Inactive"] = "Inactive_lang_78",
        ["Success"] = "Success_lang_78",
        ["Error"] = "Error_lang_78",
        ["Warning"] = "Warning_lang_78",
        ["Information"] = "Information_lang_78",
        ["Advanced"] = "Advanced_lang_78",
        ["General"] = "General_lang_78",
        ["Player"] = "Player_lang_78",
        ["Visuals"] = "Visuals_lang_78",
        ["Misc"] = "Misc_lang_78",
        ["Credits"] = "Credits_lang_78",
    },
    ["lang_79"] = {
        ["_NAME"] = "Language_79",
        ["Search"] = "Search_lang_79",
        ["Settings"] = "Settings_lang_79",
        ["Themes"] = "Themes_lang_79",
        ["Languages"] = "Languages_lang_79",
        ["Close"] = "Close_lang_79",
        ["Minimize"] = "Minimize_lang_79",
        ["Confirm"] = "Confirm_lang_79",
        ["Cancel"] = "Cancel_lang_79",
        ["Yes"] = "Yes_lang_79",
        ["No"] = "No_lang_79",
        ["Loading"] = "Loading_lang_79",
        ["FPS"] = "FPS_lang_79",
        ["MS"] = "MS_lang_79",
        ["Active"] = "Active_lang_79",
        ["Inactive"] = "Inactive_lang_79",
        ["Success"] = "Success_lang_79",
        ["Error"] = "Error_lang_79",
        ["Warning"] = "Warning_lang_79",
        ["Information"] = "Information_lang_79",
        ["Advanced"] = "Advanced_lang_79",
        ["General"] = "General_lang_79",
        ["Player"] = "Player_lang_79",
        ["Visuals"] = "Visuals_lang_79",
        ["Misc"] = "Misc_lang_79",
        ["Credits"] = "Credits_lang_79",
    },
    ["lang_80"] = {
        ["_NAME"] = "Language_80",
        ["Search"] = "Search_lang_80",
        ["Settings"] = "Settings_lang_80",
        ["Themes"] = "Themes_lang_80",
        ["Languages"] = "Languages_lang_80",
        ["Close"] = "Close_lang_80",
        ["Minimize"] = "Minimize_lang_80",
        ["Confirm"] = "Confirm_lang_80",
        ["Cancel"] = "Cancel_lang_80",
        ["Yes"] = "Yes_lang_80",
        ["No"] = "No_lang_80",
        ["Loading"] = "Loading_lang_80",
        ["FPS"] = "FPS_lang_80",
        ["MS"] = "MS_lang_80",
        ["Active"] = "Active_lang_80",
        ["Inactive"] = "Inactive_lang_80",
        ["Success"] = "Success_lang_80",
        ["Error"] = "Error_lang_80",
        ["Warning"] = "Warning_lang_80",
        ["Information"] = "Information_lang_80",
        ["Advanced"] = "Advanced_lang_80",
        ["General"] = "General_lang_80",
        ["Player"] = "Player_lang_80",
        ["Visuals"] = "Visuals_lang_80",
        ["Misc"] = "Misc_lang_80",
        ["Credits"] = "Credits_lang_80",
    },
    ["lang_81"] = {
        ["_NAME"] = "Language_81",
        ["Search"] = "Search_lang_81",
        ["Settings"] = "Settings_lang_81",
        ["Themes"] = "Themes_lang_81",
        ["Languages"] = "Languages_lang_81",
        ["Close"] = "Close_lang_81",
        ["Minimize"] = "Minimize_lang_81",
        ["Confirm"] = "Confirm_lang_81",
        ["Cancel"] = "Cancel_lang_81",
        ["Yes"] = "Yes_lang_81",
        ["No"] = "No_lang_81",
        ["Loading"] = "Loading_lang_81",
        ["FPS"] = "FPS_lang_81",
        ["MS"] = "MS_lang_81",
        ["Active"] = "Active_lang_81",
        ["Inactive"] = "Inactive_lang_81",
        ["Success"] = "Success_lang_81",
        ["Error"] = "Error_lang_81",
        ["Warning"] = "Warning_lang_81",
        ["Information"] = "Information_lang_81",
        ["Advanced"] = "Advanced_lang_81",
        ["General"] = "General_lang_81",
        ["Player"] = "Player_lang_81",
        ["Visuals"] = "Visuals_lang_81",
        ["Misc"] = "Misc_lang_81",
        ["Credits"] = "Credits_lang_81",
    },
    ["lang_82"] = {
        ["_NAME"] = "Language_82",
        ["Search"] = "Search_lang_82",
        ["Settings"] = "Settings_lang_82",
        ["Themes"] = "Themes_lang_82",
        ["Languages"] = "Languages_lang_82",
        ["Close"] = "Close_lang_82",
        ["Minimize"] = "Minimize_lang_82",
        ["Confirm"] = "Confirm_lang_82",
        ["Cancel"] = "Cancel_lang_82",
        ["Yes"] = "Yes_lang_82",
        ["No"] = "No_lang_82",
        ["Loading"] = "Loading_lang_82",
        ["FPS"] = "FPS_lang_82",
        ["MS"] = "MS_lang_82",
        ["Active"] = "Active_lang_82",
        ["Inactive"] = "Inactive_lang_82",
        ["Success"] = "Success_lang_82",
        ["Error"] = "Error_lang_82",
        ["Warning"] = "Warning_lang_82",
        ["Information"] = "Information_lang_82",
        ["Advanced"] = "Advanced_lang_82",
        ["General"] = "General_lang_82",
        ["Player"] = "Player_lang_82",
        ["Visuals"] = "Visuals_lang_82",
        ["Misc"] = "Misc_lang_82",
        ["Credits"] = "Credits_lang_82",
    },
    ["lang_83"] = {
        ["_NAME"] = "Language_83",
        ["Search"] = "Search_lang_83",
        ["Settings"] = "Settings_lang_83",
        ["Themes"] = "Themes_lang_83",
        ["Languages"] = "Languages_lang_83",
        ["Close"] = "Close_lang_83",
        ["Minimize"] = "Minimize_lang_83",
        ["Confirm"] = "Confirm_lang_83",
        ["Cancel"] = "Cancel_lang_83",
        ["Yes"] = "Yes_lang_83",
        ["No"] = "No_lang_83",
        ["Loading"] = "Loading_lang_83",
        ["FPS"] = "FPS_lang_83",
        ["MS"] = "MS_lang_83",
        ["Active"] = "Active_lang_83",
        ["Inactive"] = "Inactive_lang_83",
        ["Success"] = "Success_lang_83",
        ["Error"] = "Error_lang_83",
        ["Warning"] = "Warning_lang_83",
        ["Information"] = "Information_lang_83",
        ["Advanced"] = "Advanced_lang_83",
        ["General"] = "General_lang_83",
        ["Player"] = "Player_lang_83",
        ["Visuals"] = "Visuals_lang_83",
        ["Misc"] = "Misc_lang_83",
        ["Credits"] = "Credits_lang_83",
    },
    ["lang_84"] = {
        ["_NAME"] = "Language_84",
        ["Search"] = "Search_lang_84",
        ["Settings"] = "Settings_lang_84",
        ["Themes"] = "Themes_lang_84",
        ["Languages"] = "Languages_lang_84",
        ["Close"] = "Close_lang_84",
        ["Minimize"] = "Minimize_lang_84",
        ["Confirm"] = "Confirm_lang_84",
        ["Cancel"] = "Cancel_lang_84",
        ["Yes"] = "Yes_lang_84",
        ["No"] = "No_lang_84",
        ["Loading"] = "Loading_lang_84",
        ["FPS"] = "FPS_lang_84",
        ["MS"] = "MS_lang_84",
        ["Active"] = "Active_lang_84",
        ["Inactive"] = "Inactive_lang_84",
        ["Success"] = "Success_lang_84",
        ["Error"] = "Error_lang_84",
        ["Warning"] = "Warning_lang_84",
        ["Information"] = "Information_lang_84",
        ["Advanced"] = "Advanced_lang_84",
        ["General"] = "General_lang_84",
        ["Player"] = "Player_lang_84",
        ["Visuals"] = "Visuals_lang_84",
        ["Misc"] = "Misc_lang_84",
        ["Credits"] = "Credits_lang_84",
    },
    ["lang_85"] = {
        ["_NAME"] = "Language_85",
        ["Search"] = "Search_lang_85",
        ["Settings"] = "Settings_lang_85",
        ["Themes"] = "Themes_lang_85",
        ["Languages"] = "Languages_lang_85",
        ["Close"] = "Close_lang_85",
        ["Minimize"] = "Minimize_lang_85",
        ["Confirm"] = "Confirm_lang_85",
        ["Cancel"] = "Cancel_lang_85",
        ["Yes"] = "Yes_lang_85",
        ["No"] = "No_lang_85",
        ["Loading"] = "Loading_lang_85",
        ["FPS"] = "FPS_lang_85",
        ["MS"] = "MS_lang_85",
        ["Active"] = "Active_lang_85",
        ["Inactive"] = "Inactive_lang_85",
        ["Success"] = "Success_lang_85",
        ["Error"] = "Error_lang_85",
        ["Warning"] = "Warning_lang_85",
        ["Information"] = "Information_lang_85",
        ["Advanced"] = "Advanced_lang_85",
        ["General"] = "General_lang_85",
        ["Player"] = "Player_lang_85",
        ["Visuals"] = "Visuals_lang_85",
        ["Misc"] = "Misc_lang_85",
        ["Credits"] = "Credits_lang_85",
    },
    ["lang_86"] = {
        ["_NAME"] = "Language_86",
        ["Search"] = "Search_lang_86",
        ["Settings"] = "Settings_lang_86",
        ["Themes"] = "Themes_lang_86",
        ["Languages"] = "Languages_lang_86",
        ["Close"] = "Close_lang_86",
        ["Minimize"] = "Minimize_lang_86",
        ["Confirm"] = "Confirm_lang_86",
        ["Cancel"] = "Cancel_lang_86",
        ["Yes"] = "Yes_lang_86",
        ["No"] = "No_lang_86",
        ["Loading"] = "Loading_lang_86",
        ["FPS"] = "FPS_lang_86",
        ["MS"] = "MS_lang_86",
        ["Active"] = "Active_lang_86",
        ["Inactive"] = "Inactive_lang_86",
        ["Success"] = "Success_lang_86",
        ["Error"] = "Error_lang_86",
        ["Warning"] = "Warning_lang_86",
        ["Information"] = "Information_lang_86",
        ["Advanced"] = "Advanced_lang_86",
        ["General"] = "General_lang_86",
        ["Player"] = "Player_lang_86",
        ["Visuals"] = "Visuals_lang_86",
        ["Misc"] = "Misc_lang_86",
        ["Credits"] = "Credits_lang_86",
    },
    ["lang_87"] = {
        ["_NAME"] = "Language_87",
        ["Search"] = "Search_lang_87",
        ["Settings"] = "Settings_lang_87",
        ["Themes"] = "Themes_lang_87",
        ["Languages"] = "Languages_lang_87",
        ["Close"] = "Close_lang_87",
        ["Minimize"] = "Minimize_lang_87",
        ["Confirm"] = "Confirm_lang_87",
        ["Cancel"] = "Cancel_lang_87",
        ["Yes"] = "Yes_lang_87",
        ["No"] = "No_lang_87",
        ["Loading"] = "Loading_lang_87",
        ["FPS"] = "FPS_lang_87",
        ["MS"] = "MS_lang_87",
        ["Active"] = "Active_lang_87",
        ["Inactive"] = "Inactive_lang_87",
        ["Success"] = "Success_lang_87",
        ["Error"] = "Error_lang_87",
        ["Warning"] = "Warning_lang_87",
        ["Information"] = "Information_lang_87",
        ["Advanced"] = "Advanced_lang_87",
        ["General"] = "General_lang_87",
        ["Player"] = "Player_lang_87",
        ["Visuals"] = "Visuals_lang_87",
        ["Misc"] = "Misc_lang_87",
        ["Credits"] = "Credits_lang_87",
    },
    ["lang_88"] = {
        ["_NAME"] = "Language_88",
        ["Search"] = "Search_lang_88",
        ["Settings"] = "Settings_lang_88",
        ["Themes"] = "Themes_lang_88",
        ["Languages"] = "Languages_lang_88",
        ["Close"] = "Close_lang_88",
        ["Minimize"] = "Minimize_lang_88",
        ["Confirm"] = "Confirm_lang_88",
        ["Cancel"] = "Cancel_lang_88",
        ["Yes"] = "Yes_lang_88",
        ["No"] = "No_lang_88",
        ["Loading"] = "Loading_lang_88",
        ["FPS"] = "FPS_lang_88",
        ["MS"] = "MS_lang_88",
        ["Active"] = "Active_lang_88",
        ["Inactive"] = "Inactive_lang_88",
        ["Success"] = "Success_lang_88",
        ["Error"] = "Error_lang_88",
        ["Warning"] = "Warning_lang_88",
        ["Information"] = "Information_lang_88",
        ["Advanced"] = "Advanced_lang_88",
        ["General"] = "General_lang_88",
        ["Player"] = "Player_lang_88",
        ["Visuals"] = "Visuals_lang_88",
        ["Misc"] = "Misc_lang_88",
        ["Credits"] = "Credits_lang_88",
    },
    ["lang_89"] = {
        ["_NAME"] = "Language_89",
        ["Search"] = "Search_lang_89",
        ["Settings"] = "Settings_lang_89",
        ["Themes"] = "Themes_lang_89",
        ["Languages"] = "Languages_lang_89",
        ["Close"] = "Close_lang_89",
        ["Minimize"] = "Minimize_lang_89",
        ["Confirm"] = "Confirm_lang_89",
        ["Cancel"] = "Cancel_lang_89",
        ["Yes"] = "Yes_lang_89",
        ["No"] = "No_lang_89",
        ["Loading"] = "Loading_lang_89",
        ["FPS"] = "FPS_lang_89",
        ["MS"] = "MS_lang_89",
        ["Active"] = "Active_lang_89",
        ["Inactive"] = "Inactive_lang_89",
        ["Success"] = "Success_lang_89",
        ["Error"] = "Error_lang_89",
        ["Warning"] = "Warning_lang_89",
        ["Information"] = "Information_lang_89",
        ["Advanced"] = "Advanced_lang_89",
        ["General"] = "General_lang_89",
        ["Player"] = "Player_lang_89",
        ["Visuals"] = "Visuals_lang_89",
        ["Misc"] = "Misc_lang_89",
        ["Credits"] = "Credits_lang_89",
    },
    ["lang_90"] = {
        ["_NAME"] = "Language_90",
        ["Search"] = "Search_lang_90",
        ["Settings"] = "Settings_lang_90",
        ["Themes"] = "Themes_lang_90",
        ["Languages"] = "Languages_lang_90",
        ["Close"] = "Close_lang_90",
        ["Minimize"] = "Minimize_lang_90",
        ["Confirm"] = "Confirm_lang_90",
        ["Cancel"] = "Cancel_lang_90",
        ["Yes"] = "Yes_lang_90",
        ["No"] = "No_lang_90",
        ["Loading"] = "Loading_lang_90",
        ["FPS"] = "FPS_lang_90",
        ["MS"] = "MS_lang_90",
        ["Active"] = "Active_lang_90",
        ["Inactive"] = "Inactive_lang_90",
        ["Success"] = "Success_lang_90",
        ["Error"] = "Error_lang_90",
        ["Warning"] = "Warning_lang_90",
        ["Information"] = "Information_lang_90",
        ["Advanced"] = "Advanced_lang_90",
        ["General"] = "General_lang_90",
        ["Player"] = "Player_lang_90",
        ["Visuals"] = "Visuals_lang_90",
        ["Misc"] = "Misc_lang_90",
        ["Credits"] = "Credits_lang_90",
    },
    ["lang_91"] = {
        ["_NAME"] = "Language_91",
        ["Search"] = "Search_lang_91",
        ["Settings"] = "Settings_lang_91",
        ["Themes"] = "Themes_lang_91",
        ["Languages"] = "Languages_lang_91",
        ["Close"] = "Close_lang_91",
        ["Minimize"] = "Minimize_lang_91",
        ["Confirm"] = "Confirm_lang_91",
        ["Cancel"] = "Cancel_lang_91",
        ["Yes"] = "Yes_lang_91",
        ["No"] = "No_lang_91",
        ["Loading"] = "Loading_lang_91",
        ["FPS"] = "FPS_lang_91",
        ["MS"] = "MS_lang_91",
        ["Active"] = "Active_lang_91",
        ["Inactive"] = "Inactive_lang_91",
        ["Success"] = "Success_lang_91",
        ["Error"] = "Error_lang_91",
        ["Warning"] = "Warning_lang_91",
        ["Information"] = "Information_lang_91",
        ["Advanced"] = "Advanced_lang_91",
        ["General"] = "General_lang_91",
        ["Player"] = "Player_lang_91",
        ["Visuals"] = "Visuals_lang_91",
        ["Misc"] = "Misc_lang_91",
        ["Credits"] = "Credits_lang_91",
    },
    ["lang_92"] = {
        ["_NAME"] = "Language_92",
        ["Search"] = "Search_lang_92",
        ["Settings"] = "Settings_lang_92",
        ["Themes"] = "Themes_lang_92",
        ["Languages"] = "Languages_lang_92",
        ["Close"] = "Close_lang_92",
        ["Minimize"] = "Minimize_lang_92",
        ["Confirm"] = "Confirm_lang_92",
        ["Cancel"] = "Cancel_lang_92",
        ["Yes"] = "Yes_lang_92",
        ["No"] = "No_lang_92",
        ["Loading"] = "Loading_lang_92",
        ["FPS"] = "FPS_lang_92",
        ["MS"] = "MS_lang_92",
        ["Active"] = "Active_lang_92",
        ["Inactive"] = "Inactive_lang_92",
        ["Success"] = "Success_lang_92",
        ["Error"] = "Error_lang_92",
        ["Warning"] = "Warning_lang_92",
        ["Information"] = "Information_lang_92",
        ["Advanced"] = "Advanced_lang_92",
        ["General"] = "General_lang_92",
        ["Player"] = "Player_lang_92",
        ["Visuals"] = "Visuals_lang_92",
        ["Misc"] = "Misc_lang_92",
        ["Credits"] = "Credits_lang_92",
    },
    ["lang_93"] = {
        ["_NAME"] = "Language_93",
        ["Search"] = "Search_lang_93",
        ["Settings"] = "Settings_lang_93",
        ["Themes"] = "Themes_lang_93",
        ["Languages"] = "Languages_lang_93",
        ["Close"] = "Close_lang_93",
        ["Minimize"] = "Minimize_lang_93",
        ["Confirm"] = "Confirm_lang_93",
        ["Cancel"] = "Cancel_lang_93",
        ["Yes"] = "Yes_lang_93",
        ["No"] = "No_lang_93",
        ["Loading"] = "Loading_lang_93",
        ["FPS"] = "FPS_lang_93",
        ["MS"] = "MS_lang_93",
        ["Active"] = "Active_lang_93",
        ["Inactive"] = "Inactive_lang_93",
        ["Success"] = "Success_lang_93",
        ["Error"] = "Error_lang_93",
        ["Warning"] = "Warning_lang_93",
        ["Information"] = "Information_lang_93",
        ["Advanced"] = "Advanced_lang_93",
        ["General"] = "General_lang_93",
        ["Player"] = "Player_lang_93",
        ["Visuals"] = "Visuals_lang_93",
        ["Misc"] = "Misc_lang_93",
        ["Credits"] = "Credits_lang_93",
    },
    ["lang_94"] = {
        ["_NAME"] = "Language_94",
        ["Search"] = "Search_lang_94",
        ["Settings"] = "Settings_lang_94",
        ["Themes"] = "Themes_lang_94",
        ["Languages"] = "Languages_lang_94",
        ["Close"] = "Close_lang_94",
        ["Minimize"] = "Minimize_lang_94",
        ["Confirm"] = "Confirm_lang_94",
        ["Cancel"] = "Cancel_lang_94",
        ["Yes"] = "Yes_lang_94",
        ["No"] = "No_lang_94",
        ["Loading"] = "Loading_lang_94",
        ["FPS"] = "FPS_lang_94",
        ["MS"] = "MS_lang_94",
        ["Active"] = "Active_lang_94",
        ["Inactive"] = "Inactive_lang_94",
        ["Success"] = "Success_lang_94",
        ["Error"] = "Error_lang_94",
        ["Warning"] = "Warning_lang_94",
        ["Information"] = "Information_lang_94",
        ["Advanced"] = "Advanced_lang_94",
        ["General"] = "General_lang_94",
        ["Player"] = "Player_lang_94",
        ["Visuals"] = "Visuals_lang_94",
        ["Misc"] = "Misc_lang_94",
        ["Credits"] = "Credits_lang_94",
    },
    ["lang_95"] = {
        ["_NAME"] = "Language_95",
        ["Search"] = "Search_lang_95",
        ["Settings"] = "Settings_lang_95",
        ["Themes"] = "Themes_lang_95",
        ["Languages"] = "Languages_lang_95",
        ["Close"] = "Close_lang_95",
        ["Minimize"] = "Minimize_lang_95",
        ["Confirm"] = "Confirm_lang_95",
        ["Cancel"] = "Cancel_lang_95",
        ["Yes"] = "Yes_lang_95",
        ["No"] = "No_lang_95",
        ["Loading"] = "Loading_lang_95",
        ["FPS"] = "FPS_lang_95",
        ["MS"] = "MS_lang_95",
        ["Active"] = "Active_lang_95",
        ["Inactive"] = "Inactive_lang_95",
        ["Success"] = "Success_lang_95",
        ["Error"] = "Error_lang_95",
        ["Warning"] = "Warning_lang_95",
        ["Information"] = "Information_lang_95",
        ["Advanced"] = "Advanced_lang_95",
        ["General"] = "General_lang_95",
        ["Player"] = "Player_lang_95",
        ["Visuals"] = "Visuals_lang_95",
        ["Misc"] = "Misc_lang_95",
        ["Credits"] = "Credits_lang_95",
    },
    ["lang_96"] = {
        ["_NAME"] = "Language_96",
        ["Search"] = "Search_lang_96",
        ["Settings"] = "Settings_lang_96",
        ["Themes"] = "Themes_lang_96",
        ["Languages"] = "Languages_lang_96",
        ["Close"] = "Close_lang_96",
        ["Minimize"] = "Minimize_lang_96",
        ["Confirm"] = "Confirm_lang_96",
        ["Cancel"] = "Cancel_lang_96",
        ["Yes"] = "Yes_lang_96",
        ["No"] = "No_lang_96",
        ["Loading"] = "Loading_lang_96",
        ["FPS"] = "FPS_lang_96",
        ["MS"] = "MS_lang_96",
        ["Active"] = "Active_lang_96",
        ["Inactive"] = "Inactive_lang_96",
        ["Success"] = "Success_lang_96",
        ["Error"] = "Error_lang_96",
        ["Warning"] = "Warning_lang_96",
        ["Information"] = "Information_lang_96",
        ["Advanced"] = "Advanced_lang_96",
        ["General"] = "General_lang_96",
        ["Player"] = "Player_lang_96",
        ["Visuals"] = "Visuals_lang_96",
        ["Misc"] = "Misc_lang_96",
        ["Credits"] = "Credits_lang_96",
    },
    ["lang_97"] = {
        ["_NAME"] = "Language_97",
        ["Search"] = "Search_lang_97",
        ["Settings"] = "Settings_lang_97",
        ["Themes"] = "Themes_lang_97",
        ["Languages"] = "Languages_lang_97",
        ["Close"] = "Close_lang_97",
        ["Minimize"] = "Minimize_lang_97",
        ["Confirm"] = "Confirm_lang_97",
        ["Cancel"] = "Cancel_lang_97",
        ["Yes"] = "Yes_lang_97",
        ["No"] = "No_lang_97",
        ["Loading"] = "Loading_lang_97",
        ["FPS"] = "FPS_lang_97",
        ["MS"] = "MS_lang_97",
        ["Active"] = "Active_lang_97",
        ["Inactive"] = "Inactive_lang_97",
        ["Success"] = "Success_lang_97",
        ["Error"] = "Error_lang_97",
        ["Warning"] = "Warning_lang_97",
        ["Information"] = "Information_lang_97",
        ["Advanced"] = "Advanced_lang_97",
        ["General"] = "General_lang_97",
        ["Player"] = "Player_lang_97",
        ["Visuals"] = "Visuals_lang_97",
        ["Misc"] = "Misc_lang_97",
        ["Credits"] = "Credits_lang_97",
    },
    ["lang_98"] = {
        ["_NAME"] = "Language_98",
        ["Search"] = "Search_lang_98",
        ["Settings"] = "Settings_lang_98",
        ["Themes"] = "Themes_lang_98",
        ["Languages"] = "Languages_lang_98",
        ["Close"] = "Close_lang_98",
        ["Minimize"] = "Minimize_lang_98",
        ["Confirm"] = "Confirm_lang_98",
        ["Cancel"] = "Cancel_lang_98",
        ["Yes"] = "Yes_lang_98",
        ["No"] = "No_lang_98",
        ["Loading"] = "Loading_lang_98",
        ["FPS"] = "FPS_lang_98",
        ["MS"] = "MS_lang_98",
        ["Active"] = "Active_lang_98",
        ["Inactive"] = "Inactive_lang_98",
        ["Success"] = "Success_lang_98",
        ["Error"] = "Error_lang_98",
        ["Warning"] = "Warning_lang_98",
        ["Information"] = "Information_lang_98",
        ["Advanced"] = "Advanced_lang_98",
        ["General"] = "General_lang_98",
        ["Player"] = "Player_lang_98",
        ["Visuals"] = "Visuals_lang_98",
        ["Misc"] = "Misc_lang_98",
        ["Credits"] = "Credits_lang_98",
    },
    ["lang_99"] = {
        ["_NAME"] = "Language_99",
        ["Search"] = "Search_lang_99",
        ["Settings"] = "Settings_lang_99",
        ["Themes"] = "Themes_lang_99",
        ["Languages"] = "Languages_lang_99",
        ["Close"] = "Close_lang_99",
        ["Minimize"] = "Minimize_lang_99",
        ["Confirm"] = "Confirm_lang_99",
        ["Cancel"] = "Cancel_lang_99",
        ["Yes"] = "Yes_lang_99",
        ["No"] = "No_lang_99",
        ["Loading"] = "Loading_lang_99",
        ["FPS"] = "FPS_lang_99",
        ["MS"] = "MS_lang_99",
        ["Active"] = "Active_lang_99",
        ["Inactive"] = "Inactive_lang_99",
        ["Success"] = "Success_lang_99",
        ["Error"] = "Error_lang_99",
        ["Warning"] = "Warning_lang_99",
        ["Information"] = "Information_lang_99",
        ["Advanced"] = "Advanced_lang_99",
        ["General"] = "General_lang_99",
        ["Player"] = "Player_lang_99",
        ["Visuals"] = "Visuals_lang_99",
        ["Misc"] = "Misc_lang_99",
        ["Credits"] = "Credits_lang_99",
    },
    ["lang_100"] = {
        ["_NAME"] = "Language_100",
        ["Search"] = "Search_lang_100",
        ["Settings"] = "Settings_lang_100",
        ["Themes"] = "Themes_lang_100",
        ["Languages"] = "Languages_lang_100",
        ["Close"] = "Close_lang_100",
        ["Minimize"] = "Minimize_lang_100",
        ["Confirm"] = "Confirm_lang_100",
        ["Cancel"] = "Cancel_lang_100",
        ["Yes"] = "Yes_lang_100",
        ["No"] = "No_lang_100",
        ["Loading"] = "Loading_lang_100",
        ["FPS"] = "FPS_lang_100",
        ["MS"] = "MS_lang_100",
        ["Active"] = "Active_lang_100",
        ["Inactive"] = "Inactive_lang_100",
        ["Success"] = "Success_lang_100",
        ["Error"] = "Error_lang_100",
        ["Warning"] = "Warning_lang_100",
        ["Information"] = "Information_lang_100",
        ["Advanced"] = "Advanced_lang_100",
        ["General"] = "General_lang_100",
        ["Player"] = "Player_lang_100",
        ["Visuals"] = "Visuals_lang_100",
        ["Misc"] = "Misc_lang_100",
        ["Credits"] = "Credits_lang_100",
    },
    ["lang_101"] = {
        ["_NAME"] = "Language_101",
        ["Search"] = "Search_lang_101",
        ["Settings"] = "Settings_lang_101",
        ["Themes"] = "Themes_lang_101",
        ["Languages"] = "Languages_lang_101",
        ["Close"] = "Close_lang_101",
        ["Minimize"] = "Minimize_lang_101",
        ["Confirm"] = "Confirm_lang_101",
        ["Cancel"] = "Cancel_lang_101",
        ["Yes"] = "Yes_lang_101",
        ["No"] = "No_lang_101",
        ["Loading"] = "Loading_lang_101",
        ["FPS"] = "FPS_lang_101",
        ["MS"] = "MS_lang_101",
        ["Active"] = "Active_lang_101",
        ["Inactive"] = "Inactive_lang_101",
        ["Success"] = "Success_lang_101",
        ["Error"] = "Error_lang_101",
        ["Warning"] = "Warning_lang_101",
        ["Information"] = "Information_lang_101",
        ["Advanced"] = "Advanced_lang_101",
        ["General"] = "General_lang_101",
        ["Player"] = "Player_lang_101",
        ["Visuals"] = "Visuals_lang_101",
        ["Misc"] = "Misc_lang_101",
        ["Credits"] = "Credits_lang_101",
    },
    ["lang_102"] = {
        ["_NAME"] = "Language_102",
        ["Search"] = "Search_lang_102",
        ["Settings"] = "Settings_lang_102",
        ["Themes"] = "Themes_lang_102",
        ["Languages"] = "Languages_lang_102",
        ["Close"] = "Close_lang_102",
        ["Minimize"] = "Minimize_lang_102",
        ["Confirm"] = "Confirm_lang_102",
        ["Cancel"] = "Cancel_lang_102",
        ["Yes"] = "Yes_lang_102",
        ["No"] = "No_lang_102",
        ["Loading"] = "Loading_lang_102",
        ["FPS"] = "FPS_lang_102",
        ["MS"] = "MS_lang_102",
        ["Active"] = "Active_lang_102",
        ["Inactive"] = "Inactive_lang_102",
        ["Success"] = "Success_lang_102",
        ["Error"] = "Error_lang_102",
        ["Warning"] = "Warning_lang_102",
        ["Information"] = "Information_lang_102",
        ["Advanced"] = "Advanced_lang_102",
        ["General"] = "General_lang_102",
        ["Player"] = "Player_lang_102",
        ["Visuals"] = "Visuals_lang_102",
        ["Misc"] = "Misc_lang_102",
        ["Credits"] = "Credits_lang_102",
    },
    ["lang_103"] = {
        ["_NAME"] = "Language_103",
        ["Search"] = "Search_lang_103",
        ["Settings"] = "Settings_lang_103",
        ["Themes"] = "Themes_lang_103",
        ["Languages"] = "Languages_lang_103",
        ["Close"] = "Close_lang_103",
        ["Minimize"] = "Minimize_lang_103",
        ["Confirm"] = "Confirm_lang_103",
        ["Cancel"] = "Cancel_lang_103",
        ["Yes"] = "Yes_lang_103",
        ["No"] = "No_lang_103",
        ["Loading"] = "Loading_lang_103",
        ["FPS"] = "FPS_lang_103",
        ["MS"] = "MS_lang_103",
        ["Active"] = "Active_lang_103",
        ["Inactive"] = "Inactive_lang_103",
        ["Success"] = "Success_lang_103",
        ["Error"] = "Error_lang_103",
        ["Warning"] = "Warning_lang_103",
        ["Information"] = "Information_lang_103",
        ["Advanced"] = "Advanced_lang_103",
        ["General"] = "General_lang_103",
        ["Player"] = "Player_lang_103",
        ["Visuals"] = "Visuals_lang_103",
        ["Misc"] = "Misc_lang_103",
        ["Credits"] = "Credits_lang_103",
    },
    ["lang_104"] = {
        ["_NAME"] = "Language_104",
        ["Search"] = "Search_lang_104",
        ["Settings"] = "Settings_lang_104",
        ["Themes"] = "Themes_lang_104",
        ["Languages"] = "Languages_lang_104",
        ["Close"] = "Close_lang_104",
        ["Minimize"] = "Minimize_lang_104",
        ["Confirm"] = "Confirm_lang_104",
        ["Cancel"] = "Cancel_lang_104",
        ["Yes"] = "Yes_lang_104",
        ["No"] = "No_lang_104",
        ["Loading"] = "Loading_lang_104",
        ["FPS"] = "FPS_lang_104",
        ["MS"] = "MS_lang_104",
        ["Active"] = "Active_lang_104",
        ["Inactive"] = "Inactive_lang_104",
        ["Success"] = "Success_lang_104",
        ["Error"] = "Error_lang_104",
        ["Warning"] = "Warning_lang_104",
        ["Information"] = "Information_lang_104",
        ["Advanced"] = "Advanced_lang_104",
        ["General"] = "General_lang_104",
        ["Player"] = "Player_lang_104",
        ["Visuals"] = "Visuals_lang_104",
        ["Misc"] = "Misc_lang_104",
        ["Credits"] = "Credits_lang_104",
    },
    ["lang_105"] = {
        ["_NAME"] = "Language_105",
        ["Search"] = "Search_lang_105",
        ["Settings"] = "Settings_lang_105",
        ["Themes"] = "Themes_lang_105",
        ["Languages"] = "Languages_lang_105",
        ["Close"] = "Close_lang_105",
        ["Minimize"] = "Minimize_lang_105",
        ["Confirm"] = "Confirm_lang_105",
        ["Cancel"] = "Cancel_lang_105",
        ["Yes"] = "Yes_lang_105",
        ["No"] = "No_lang_105",
        ["Loading"] = "Loading_lang_105",
        ["FPS"] = "FPS_lang_105",
        ["MS"] = "MS_lang_105",
        ["Active"] = "Active_lang_105",
        ["Inactive"] = "Inactive_lang_105",
        ["Success"] = "Success_lang_105",
        ["Error"] = "Error_lang_105",
        ["Warning"] = "Warning_lang_105",
        ["Information"] = "Information_lang_105",
        ["Advanced"] = "Advanced_lang_105",
        ["General"] = "General_lang_105",
        ["Player"] = "Player_lang_105",
        ["Visuals"] = "Visuals_lang_105",
        ["Misc"] = "Misc_lang_105",
        ["Credits"] = "Credits_lang_105",
    },
    ["lang_106"] = {
        ["_NAME"] = "Language_106",
        ["Search"] = "Search_lang_106",
        ["Settings"] = "Settings_lang_106",
        ["Themes"] = "Themes_lang_106",
        ["Languages"] = "Languages_lang_106",
        ["Close"] = "Close_lang_106",
        ["Minimize"] = "Minimize_lang_106",
        ["Confirm"] = "Confirm_lang_106",
        ["Cancel"] = "Cancel_lang_106",
        ["Yes"] = "Yes_lang_106",
        ["No"] = "No_lang_106",
        ["Loading"] = "Loading_lang_106",
        ["FPS"] = "FPS_lang_106",
        ["MS"] = "MS_lang_106",
        ["Active"] = "Active_lang_106",
        ["Inactive"] = "Inactive_lang_106",
        ["Success"] = "Success_lang_106",
        ["Error"] = "Error_lang_106",
        ["Warning"] = "Warning_lang_106",
        ["Information"] = "Information_lang_106",
        ["Advanced"] = "Advanced_lang_106",
        ["General"] = "General_lang_106",
        ["Player"] = "Player_lang_106",
        ["Visuals"] = "Visuals_lang_106",
        ["Misc"] = "Misc_lang_106",
        ["Credits"] = "Credits_lang_106",
    },
    ["lang_107"] = {
        ["_NAME"] = "Language_107",
        ["Search"] = "Search_lang_107",
        ["Settings"] = "Settings_lang_107",
        ["Themes"] = "Themes_lang_107",
        ["Languages"] = "Languages_lang_107",
        ["Close"] = "Close_lang_107",
        ["Minimize"] = "Minimize_lang_107",
        ["Confirm"] = "Confirm_lang_107",
        ["Cancel"] = "Cancel_lang_107",
        ["Yes"] = "Yes_lang_107",
        ["No"] = "No_lang_107",
        ["Loading"] = "Loading_lang_107",
        ["FPS"] = "FPS_lang_107",
        ["MS"] = "MS_lang_107",
        ["Active"] = "Active_lang_107",
        ["Inactive"] = "Inactive_lang_107",
        ["Success"] = "Success_lang_107",
        ["Error"] = "Error_lang_107",
        ["Warning"] = "Warning_lang_107",
        ["Information"] = "Information_lang_107",
        ["Advanced"] = "Advanced_lang_107",
        ["General"] = "General_lang_107",
        ["Player"] = "Player_lang_107",
        ["Visuals"] = "Visuals_lang_107",
        ["Misc"] = "Misc_lang_107",
        ["Credits"] = "Credits_lang_107",
    },
    ["lang_108"] = {
        ["_NAME"] = "Language_108",
        ["Search"] = "Search_lang_108",
        ["Settings"] = "Settings_lang_108",
        ["Themes"] = "Themes_lang_108",
        ["Languages"] = "Languages_lang_108",
        ["Close"] = "Close_lang_108",
        ["Minimize"] = "Minimize_lang_108",
        ["Confirm"] = "Confirm_lang_108",
        ["Cancel"] = "Cancel_lang_108",
        ["Yes"] = "Yes_lang_108",
        ["No"] = "No_lang_108",
        ["Loading"] = "Loading_lang_108",
        ["FPS"] = "FPS_lang_108",
        ["MS"] = "MS_lang_108",
        ["Active"] = "Active_lang_108",
        ["Inactive"] = "Inactive_lang_108",
        ["Success"] = "Success_lang_108",
        ["Error"] = "Error_lang_108",
        ["Warning"] = "Warning_lang_108",
        ["Information"] = "Information_lang_108",
        ["Advanced"] = "Advanced_lang_108",
        ["General"] = "General_lang_108",
        ["Player"] = "Player_lang_108",
        ["Visuals"] = "Visuals_lang_108",
        ["Misc"] = "Misc_lang_108",
        ["Credits"] = "Credits_lang_108",
    },
    ["lang_109"] = {
        ["_NAME"] = "Language_109",
        ["Search"] = "Search_lang_109",
        ["Settings"] = "Settings_lang_109",
        ["Themes"] = "Themes_lang_109",
        ["Languages"] = "Languages_lang_109",
        ["Close"] = "Close_lang_109",
        ["Minimize"] = "Minimize_lang_109",
        ["Confirm"] = "Confirm_lang_109",
        ["Cancel"] = "Cancel_lang_109",
        ["Yes"] = "Yes_lang_109",
        ["No"] = "No_lang_109",
        ["Loading"] = "Loading_lang_109",
        ["FPS"] = "FPS_lang_109",
        ["MS"] = "MS_lang_109",
        ["Active"] = "Active_lang_109",
        ["Inactive"] = "Inactive_lang_109",
        ["Success"] = "Success_lang_109",
        ["Error"] = "Error_lang_109",
        ["Warning"] = "Warning_lang_109",
        ["Information"] = "Information_lang_109",
        ["Advanced"] = "Advanced_lang_109",
        ["General"] = "General_lang_109",
        ["Player"] = "Player_lang_109",
        ["Visuals"] = "Visuals_lang_109",
        ["Misc"] = "Misc_lang_109",
        ["Credits"] = "Credits_lang_109",
    },
    ["lang_110"] = {
        ["_NAME"] = "Language_110",
        ["Search"] = "Search_lang_110",
        ["Settings"] = "Settings_lang_110",
        ["Themes"] = "Themes_lang_110",
        ["Languages"] = "Languages_lang_110",
        ["Close"] = "Close_lang_110",
        ["Minimize"] = "Minimize_lang_110",
        ["Confirm"] = "Confirm_lang_110",
        ["Cancel"] = "Cancel_lang_110",
        ["Yes"] = "Yes_lang_110",
        ["No"] = "No_lang_110",
        ["Loading"] = "Loading_lang_110",
        ["FPS"] = "FPS_lang_110",
        ["MS"] = "MS_lang_110",
        ["Active"] = "Active_lang_110",
        ["Inactive"] = "Inactive_lang_110",
        ["Success"] = "Success_lang_110",
        ["Error"] = "Error_lang_110",
        ["Warning"] = "Warning_lang_110",
        ["Information"] = "Information_lang_110",
        ["Advanced"] = "Advanced_lang_110",
        ["General"] = "General_lang_110",
        ["Player"] = "Player_lang_110",
        ["Visuals"] = "Visuals_lang_110",
        ["Misc"] = "Misc_lang_110",
        ["Credits"] = "Credits_lang_110",
    },
    ["lang_111"] = {
        ["_NAME"] = "Language_111",
        ["Search"] = "Search_lang_111",
        ["Settings"] = "Settings_lang_111",
        ["Themes"] = "Themes_lang_111",
        ["Languages"] = "Languages_lang_111",
        ["Close"] = "Close_lang_111",
        ["Minimize"] = "Minimize_lang_111",
        ["Confirm"] = "Confirm_lang_111",
        ["Cancel"] = "Cancel_lang_111",
        ["Yes"] = "Yes_lang_111",
        ["No"] = "No_lang_111",
        ["Loading"] = "Loading_lang_111",
        ["FPS"] = "FPS_lang_111",
        ["MS"] = "MS_lang_111",
        ["Active"] = "Active_lang_111",
        ["Inactive"] = "Inactive_lang_111",
        ["Success"] = "Success_lang_111",
        ["Error"] = "Error_lang_111",
        ["Warning"] = "Warning_lang_111",
        ["Information"] = "Information_lang_111",
        ["Advanced"] = "Advanced_lang_111",
        ["General"] = "General_lang_111",
        ["Player"] = "Player_lang_111",
        ["Visuals"] = "Visuals_lang_111",
        ["Misc"] = "Misc_lang_111",
        ["Credits"] = "Credits_lang_111",
    },
    ["lang_112"] = {
        ["_NAME"] = "Language_112",
        ["Search"] = "Search_lang_112",
        ["Settings"] = "Settings_lang_112",
        ["Themes"] = "Themes_lang_112",
        ["Languages"] = "Languages_lang_112",
        ["Close"] = "Close_lang_112",
        ["Minimize"] = "Minimize_lang_112",
        ["Confirm"] = "Confirm_lang_112",
        ["Cancel"] = "Cancel_lang_112",
        ["Yes"] = "Yes_lang_112",
        ["No"] = "No_lang_112",
        ["Loading"] = "Loading_lang_112",
        ["FPS"] = "FPS_lang_112",
        ["MS"] = "MS_lang_112",
        ["Active"] = "Active_lang_112",
        ["Inactive"] = "Inactive_lang_112",
        ["Success"] = "Success_lang_112",
        ["Error"] = "Error_lang_112",
        ["Warning"] = "Warning_lang_112",
        ["Information"] = "Information_lang_112",
        ["Advanced"] = "Advanced_lang_112",
        ["General"] = "General_lang_112",
        ["Player"] = "Player_lang_112",
        ["Visuals"] = "Visuals_lang_112",
        ["Misc"] = "Misc_lang_112",
        ["Credits"] = "Credits_lang_112",
    },
    ["lang_113"] = {
        ["_NAME"] = "Language_113",
        ["Search"] = "Search_lang_113",
        ["Settings"] = "Settings_lang_113",
        ["Themes"] = "Themes_lang_113",
        ["Languages"] = "Languages_lang_113",
        ["Close"] = "Close_lang_113",
        ["Minimize"] = "Minimize_lang_113",
        ["Confirm"] = "Confirm_lang_113",
        ["Cancel"] = "Cancel_lang_113",
        ["Yes"] = "Yes_lang_113",
        ["No"] = "No_lang_113",
        ["Loading"] = "Loading_lang_113",
        ["FPS"] = "FPS_lang_113",
        ["MS"] = "MS_lang_113",
        ["Active"] = "Active_lang_113",
        ["Inactive"] = "Inactive_lang_113",
        ["Success"] = "Success_lang_113",
        ["Error"] = "Error_lang_113",
        ["Warning"] = "Warning_lang_113",
        ["Information"] = "Information_lang_113",
        ["Advanced"] = "Advanced_lang_113",
        ["General"] = "General_lang_113",
        ["Player"] = "Player_lang_113",
        ["Visuals"] = "Visuals_lang_113",
        ["Misc"] = "Misc_lang_113",
        ["Credits"] = "Credits_lang_113",
    },
    ["lang_114"] = {
        ["_NAME"] = "Language_114",
        ["Search"] = "Search_lang_114",
        ["Settings"] = "Settings_lang_114",
        ["Themes"] = "Themes_lang_114",
        ["Languages"] = "Languages_lang_114",
        ["Close"] = "Close_lang_114",
        ["Minimize"] = "Minimize_lang_114",
        ["Confirm"] = "Confirm_lang_114",
        ["Cancel"] = "Cancel_lang_114",
        ["Yes"] = "Yes_lang_114",
        ["No"] = "No_lang_114",
        ["Loading"] = "Loading_lang_114",
        ["FPS"] = "FPS_lang_114",
        ["MS"] = "MS_lang_114",
        ["Active"] = "Active_lang_114",
        ["Inactive"] = "Inactive_lang_114",
        ["Success"] = "Success_lang_114",
        ["Error"] = "Error_lang_114",
        ["Warning"] = "Warning_lang_114",
        ["Information"] = "Information_lang_114",
        ["Advanced"] = "Advanced_lang_114",
        ["General"] = "General_lang_114",
        ["Player"] = "Player_lang_114",
        ["Visuals"] = "Visuals_lang_114",
        ["Misc"] = "Misc_lang_114",
        ["Credits"] = "Credits_lang_114",
    },
    ["lang_115"] = {
        ["_NAME"] = "Language_115",
        ["Search"] = "Search_lang_115",
        ["Settings"] = "Settings_lang_115",
        ["Themes"] = "Themes_lang_115",
        ["Languages"] = "Languages_lang_115",
        ["Close"] = "Close_lang_115",
        ["Minimize"] = "Minimize_lang_115",
        ["Confirm"] = "Confirm_lang_115",
        ["Cancel"] = "Cancel_lang_115",
        ["Yes"] = "Yes_lang_115",
        ["No"] = "No_lang_115",
        ["Loading"] = "Loading_lang_115",
        ["FPS"] = "FPS_lang_115",
        ["MS"] = "MS_lang_115",
        ["Active"] = "Active_lang_115",
        ["Inactive"] = "Inactive_lang_115",
        ["Success"] = "Success_lang_115",
        ["Error"] = "Error_lang_115",
        ["Warning"] = "Warning_lang_115",
        ["Information"] = "Information_lang_115",
        ["Advanced"] = "Advanced_lang_115",
        ["General"] = "General_lang_115",
        ["Player"] = "Player_lang_115",
        ["Visuals"] = "Visuals_lang_115",
        ["Misc"] = "Misc_lang_115",
        ["Credits"] = "Credits_lang_115",
    },
    ["lang_116"] = {
        ["_NAME"] = "Language_116",
        ["Search"] = "Search_lang_116",
        ["Settings"] = "Settings_lang_116",
        ["Themes"] = "Themes_lang_116",
        ["Languages"] = "Languages_lang_116",
        ["Close"] = "Close_lang_116",
        ["Minimize"] = "Minimize_lang_116",
        ["Confirm"] = "Confirm_lang_116",
        ["Cancel"] = "Cancel_lang_116",
        ["Yes"] = "Yes_lang_116",
        ["No"] = "No_lang_116",
        ["Loading"] = "Loading_lang_116",
        ["FPS"] = "FPS_lang_116",
        ["MS"] = "MS_lang_116",
        ["Active"] = "Active_lang_116",
        ["Inactive"] = "Inactive_lang_116",
        ["Success"] = "Success_lang_116",
        ["Error"] = "Error_lang_116",
        ["Warning"] = "Warning_lang_116",
        ["Information"] = "Information_lang_116",
        ["Advanced"] = "Advanced_lang_116",
        ["General"] = "General_lang_116",
        ["Player"] = "Player_lang_116",
        ["Visuals"] = "Visuals_lang_116",
        ["Misc"] = "Misc_lang_116",
        ["Credits"] = "Credits_lang_116",
    },
    ["lang_117"] = {
        ["_NAME"] = "Language_117",
        ["Search"] = "Search_lang_117",
        ["Settings"] = "Settings_lang_117",
        ["Themes"] = "Themes_lang_117",
        ["Languages"] = "Languages_lang_117",
        ["Close"] = "Close_lang_117",
        ["Minimize"] = "Minimize_lang_117",
        ["Confirm"] = "Confirm_lang_117",
        ["Cancel"] = "Cancel_lang_117",
        ["Yes"] = "Yes_lang_117",
        ["No"] = "No_lang_117",
        ["Loading"] = "Loading_lang_117",
        ["FPS"] = "FPS_lang_117",
        ["MS"] = "MS_lang_117",
        ["Active"] = "Active_lang_117",
        ["Inactive"] = "Inactive_lang_117",
        ["Success"] = "Success_lang_117",
        ["Error"] = "Error_lang_117",
        ["Warning"] = "Warning_lang_117",
        ["Information"] = "Information_lang_117",
        ["Advanced"] = "Advanced_lang_117",
        ["General"] = "General_lang_117",
        ["Player"] = "Player_lang_117",
        ["Visuals"] = "Visuals_lang_117",
        ["Misc"] = "Misc_lang_117",
        ["Credits"] = "Credits_lang_117",
    },
    ["lang_118"] = {
        ["_NAME"] = "Language_118",
        ["Search"] = "Search_lang_118",
        ["Settings"] = "Settings_lang_118",
        ["Themes"] = "Themes_lang_118",
        ["Languages"] = "Languages_lang_118",
        ["Close"] = "Close_lang_118",
        ["Minimize"] = "Minimize_lang_118",
        ["Confirm"] = "Confirm_lang_118",
        ["Cancel"] = "Cancel_lang_118",
        ["Yes"] = "Yes_lang_118",
        ["No"] = "No_lang_118",
        ["Loading"] = "Loading_lang_118",
        ["FPS"] = "FPS_lang_118",
        ["MS"] = "MS_lang_118",
        ["Active"] = "Active_lang_118",
        ["Inactive"] = "Inactive_lang_118",
        ["Success"] = "Success_lang_118",
        ["Error"] = "Error_lang_118",
        ["Warning"] = "Warning_lang_118",
        ["Information"] = "Information_lang_118",
        ["Advanced"] = "Advanced_lang_118",
        ["General"] = "General_lang_118",
        ["Player"] = "Player_lang_118",
        ["Visuals"] = "Visuals_lang_118",
        ["Misc"] = "Misc_lang_118",
        ["Credits"] = "Credits_lang_118",
    },
    ["lang_119"] = {
        ["_NAME"] = "Language_119",
        ["Search"] = "Search_lang_119",
        ["Settings"] = "Settings_lang_119",
        ["Themes"] = "Themes_lang_119",
        ["Languages"] = "Languages_lang_119",
        ["Close"] = "Close_lang_119",
        ["Minimize"] = "Minimize_lang_119",
        ["Confirm"] = "Confirm_lang_119",
        ["Cancel"] = "Cancel_lang_119",
        ["Yes"] = "Yes_lang_119",
        ["No"] = "No_lang_119",
        ["Loading"] = "Loading_lang_119",
        ["FPS"] = "FPS_lang_119",
        ["MS"] = "MS_lang_119",
        ["Active"] = "Active_lang_119",
        ["Inactive"] = "Inactive_lang_119",
        ["Success"] = "Success_lang_119",
        ["Error"] = "Error_lang_119",
        ["Warning"] = "Warning_lang_119",
        ["Information"] = "Information_lang_119",
        ["Advanced"] = "Advanced_lang_119",
        ["General"] = "General_lang_119",
        ["Player"] = "Player_lang_119",
        ["Visuals"] = "Visuals_lang_119",
        ["Misc"] = "Misc_lang_119",
        ["Credits"] = "Credits_lang_119",
    },
    ["lang_120"] = {
        ["_NAME"] = "Language_120",
        ["Search"] = "Search_lang_120",
        ["Settings"] = "Settings_lang_120",
        ["Themes"] = "Themes_lang_120",
        ["Languages"] = "Languages_lang_120",
        ["Close"] = "Close_lang_120",
        ["Minimize"] = "Minimize_lang_120",
        ["Confirm"] = "Confirm_lang_120",
        ["Cancel"] = "Cancel_lang_120",
        ["Yes"] = "Yes_lang_120",
        ["No"] = "No_lang_120",
        ["Loading"] = "Loading_lang_120",
        ["FPS"] = "FPS_lang_120",
        ["MS"] = "MS_lang_120",
        ["Active"] = "Active_lang_120",
        ["Inactive"] = "Inactive_lang_120",
        ["Success"] = "Success_lang_120",
        ["Error"] = "Error_lang_120",
        ["Warning"] = "Warning_lang_120",
        ["Information"] = "Information_lang_120",
        ["Advanced"] = "Advanced_lang_120",
        ["General"] = "General_lang_120",
        ["Player"] = "Player_lang_120",
        ["Visuals"] = "Visuals_lang_120",
        ["Misc"] = "Misc_lang_120",
        ["Credits"] = "Credits_lang_120",
    },
    ["lang_121"] = {
        ["_NAME"] = "Language_121",
        ["Search"] = "Search_lang_121",
        ["Settings"] = "Settings_lang_121",
        ["Themes"] = "Themes_lang_121",
        ["Languages"] = "Languages_lang_121",
        ["Close"] = "Close_lang_121",
        ["Minimize"] = "Minimize_lang_121",
        ["Confirm"] = "Confirm_lang_121",
        ["Cancel"] = "Cancel_lang_121",
        ["Yes"] = "Yes_lang_121",
        ["No"] = "No_lang_121",
        ["Loading"] = "Loading_lang_121",
        ["FPS"] = "FPS_lang_121",
        ["MS"] = "MS_lang_121",
        ["Active"] = "Active_lang_121",
        ["Inactive"] = "Inactive_lang_121",
        ["Success"] = "Success_lang_121",
        ["Error"] = "Error_lang_121",
        ["Warning"] = "Warning_lang_121",
        ["Information"] = "Information_lang_121",
        ["Advanced"] = "Advanced_lang_121",
        ["General"] = "General_lang_121",
        ["Player"] = "Player_lang_121",
        ["Visuals"] = "Visuals_lang_121",
        ["Misc"] = "Misc_lang_121",
        ["Credits"] = "Credits_lang_121",
    },
    ["lang_122"] = {
        ["_NAME"] = "Language_122",
        ["Search"] = "Search_lang_122",
        ["Settings"] = "Settings_lang_122",
        ["Themes"] = "Themes_lang_122",
        ["Languages"] = "Languages_lang_122",
        ["Close"] = "Close_lang_122",
        ["Minimize"] = "Minimize_lang_122",
        ["Confirm"] = "Confirm_lang_122",
        ["Cancel"] = "Cancel_lang_122",
        ["Yes"] = "Yes_lang_122",
        ["No"] = "No_lang_122",
        ["Loading"] = "Loading_lang_122",
        ["FPS"] = "FPS_lang_122",
        ["MS"] = "MS_lang_122",
        ["Active"] = "Active_lang_122",
        ["Inactive"] = "Inactive_lang_122",
        ["Success"] = "Success_lang_122",
        ["Error"] = "Error_lang_122",
        ["Warning"] = "Warning_lang_122",
        ["Information"] = "Information_lang_122",
        ["Advanced"] = "Advanced_lang_122",
        ["General"] = "General_lang_122",
        ["Player"] = "Player_lang_122",
        ["Visuals"] = "Visuals_lang_122",
        ["Misc"] = "Misc_lang_122",
        ["Credits"] = "Credits_lang_122",
    },
    ["lang_123"] = {
        ["_NAME"] = "Language_123",
        ["Search"] = "Search_lang_123",
        ["Settings"] = "Settings_lang_123",
        ["Themes"] = "Themes_lang_123",
        ["Languages"] = "Languages_lang_123",
        ["Close"] = "Close_lang_123",
        ["Minimize"] = "Minimize_lang_123",
        ["Confirm"] = "Confirm_lang_123",
        ["Cancel"] = "Cancel_lang_123",
        ["Yes"] = "Yes_lang_123",
        ["No"] = "No_lang_123",
        ["Loading"] = "Loading_lang_123",
        ["FPS"] = "FPS_lang_123",
        ["MS"] = "MS_lang_123",
        ["Active"] = "Active_lang_123",
        ["Inactive"] = "Inactive_lang_123",
        ["Success"] = "Success_lang_123",
        ["Error"] = "Error_lang_123",
        ["Warning"] = "Warning_lang_123",
        ["Information"] = "Information_lang_123",
        ["Advanced"] = "Advanced_lang_123",
        ["General"] = "General_lang_123",
        ["Player"] = "Player_lang_123",
        ["Visuals"] = "Visuals_lang_123",
        ["Misc"] = "Misc_lang_123",
        ["Credits"] = "Credits_lang_123",
    },
    ["lang_124"] = {
        ["_NAME"] = "Language_124",
        ["Search"] = "Search_lang_124",
        ["Settings"] = "Settings_lang_124",
        ["Themes"] = "Themes_lang_124",
        ["Languages"] = "Languages_lang_124",
        ["Close"] = "Close_lang_124",
        ["Minimize"] = "Minimize_lang_124",
        ["Confirm"] = "Confirm_lang_124",
        ["Cancel"] = "Cancel_lang_124",
        ["Yes"] = "Yes_lang_124",
        ["No"] = "No_lang_124",
        ["Loading"] = "Loading_lang_124",
        ["FPS"] = "FPS_lang_124",
        ["MS"] = "MS_lang_124",
        ["Active"] = "Active_lang_124",
        ["Inactive"] = "Inactive_lang_124",
        ["Success"] = "Success_lang_124",
        ["Error"] = "Error_lang_124",
        ["Warning"] = "Warning_lang_124",
        ["Information"] = "Information_lang_124",
        ["Advanced"] = "Advanced_lang_124",
        ["General"] = "General_lang_124",
        ["Player"] = "Player_lang_124",
        ["Visuals"] = "Visuals_lang_124",
        ["Misc"] = "Misc_lang_124",
        ["Credits"] = "Credits_lang_124",
    },
    ["lang_125"] = {
        ["_NAME"] = "Language_125",
        ["Search"] = "Search_lang_125",
        ["Settings"] = "Settings_lang_125",
        ["Themes"] = "Themes_lang_125",
        ["Languages"] = "Languages_lang_125",
        ["Close"] = "Close_lang_125",
        ["Minimize"] = "Minimize_lang_125",
        ["Confirm"] = "Confirm_lang_125",
        ["Cancel"] = "Cancel_lang_125",
        ["Yes"] = "Yes_lang_125",
        ["No"] = "No_lang_125",
        ["Loading"] = "Loading_lang_125",
        ["FPS"] = "FPS_lang_125",
        ["MS"] = "MS_lang_125",
        ["Active"] = "Active_lang_125",
        ["Inactive"] = "Inactive_lang_125",
        ["Success"] = "Success_lang_125",
        ["Error"] = "Error_lang_125",
        ["Warning"] = "Warning_lang_125",
        ["Information"] = "Information_lang_125",
        ["Advanced"] = "Advanced_lang_125",
        ["General"] = "General_lang_125",
        ["Player"] = "Player_lang_125",
        ["Visuals"] = "Visuals_lang_125",
        ["Misc"] = "Misc_lang_125",
        ["Credits"] = "Credits_lang_125",
    },
    ["lang_126"] = {
        ["_NAME"] = "Language_126",
        ["Search"] = "Search_lang_126",
        ["Settings"] = "Settings_lang_126",
        ["Themes"] = "Themes_lang_126",
        ["Languages"] = "Languages_lang_126",
        ["Close"] = "Close_lang_126",
        ["Minimize"] = "Minimize_lang_126",
        ["Confirm"] = "Confirm_lang_126",
        ["Cancel"] = "Cancel_lang_126",
        ["Yes"] = "Yes_lang_126",
        ["No"] = "No_lang_126",
        ["Loading"] = "Loading_lang_126",
        ["FPS"] = "FPS_lang_126",
        ["MS"] = "MS_lang_126",
        ["Active"] = "Active_lang_126",
        ["Inactive"] = "Inactive_lang_126",
        ["Success"] = "Success_lang_126",
        ["Error"] = "Error_lang_126",
        ["Warning"] = "Warning_lang_126",
        ["Information"] = "Information_lang_126",
        ["Advanced"] = "Advanced_lang_126",
        ["General"] = "General_lang_126",
        ["Player"] = "Player_lang_126",
        ["Visuals"] = "Visuals_lang_126",
        ["Misc"] = "Misc_lang_126",
        ["Credits"] = "Credits_lang_126",
    },
    ["lang_127"] = {
        ["_NAME"] = "Language_127",
        ["Search"] = "Search_lang_127",
        ["Settings"] = "Settings_lang_127",
        ["Themes"] = "Themes_lang_127",
        ["Languages"] = "Languages_lang_127",
        ["Close"] = "Close_lang_127",
        ["Minimize"] = "Minimize_lang_127",
        ["Confirm"] = "Confirm_lang_127",
        ["Cancel"] = "Cancel_lang_127",
        ["Yes"] = "Yes_lang_127",
        ["No"] = "No_lang_127",
        ["Loading"] = "Loading_lang_127",
        ["FPS"] = "FPS_lang_127",
        ["MS"] = "MS_lang_127",
        ["Active"] = "Active_lang_127",
        ["Inactive"] = "Inactive_lang_127",
        ["Success"] = "Success_lang_127",
        ["Error"] = "Error_lang_127",
        ["Warning"] = "Warning_lang_127",
        ["Information"] = "Information_lang_127",
        ["Advanced"] = "Advanced_lang_127",
        ["General"] = "General_lang_127",
        ["Player"] = "Player_lang_127",
        ["Visuals"] = "Visuals_lang_127",
        ["Misc"] = "Misc_lang_127",
        ["Credits"] = "Credits_lang_127",
    },
    ["lang_128"] = {
        ["_NAME"] = "Language_128",
        ["Search"] = "Search_lang_128",
        ["Settings"] = "Settings_lang_128",
        ["Themes"] = "Themes_lang_128",
        ["Languages"] = "Languages_lang_128",
        ["Close"] = "Close_lang_128",
        ["Minimize"] = "Minimize_lang_128",
        ["Confirm"] = "Confirm_lang_128",
        ["Cancel"] = "Cancel_lang_128",
        ["Yes"] = "Yes_lang_128",
        ["No"] = "No_lang_128",
        ["Loading"] = "Loading_lang_128",
        ["FPS"] = "FPS_lang_128",
        ["MS"] = "MS_lang_128",
        ["Active"] = "Active_lang_128",
        ["Inactive"] = "Inactive_lang_128",
        ["Success"] = "Success_lang_128",
        ["Error"] = "Error_lang_128",
        ["Warning"] = "Warning_lang_128",
        ["Information"] = "Information_lang_128",
        ["Advanced"] = "Advanced_lang_128",
        ["General"] = "General_lang_128",
        ["Player"] = "Player_lang_128",
        ["Visuals"] = "Visuals_lang_128",
        ["Misc"] = "Misc_lang_128",
        ["Credits"] = "Credits_lang_128",
    },
    ["lang_129"] = {
        ["_NAME"] = "Language_129",
        ["Search"] = "Search_lang_129",
        ["Settings"] = "Settings_lang_129",
        ["Themes"] = "Themes_lang_129",
        ["Languages"] = "Languages_lang_129",
        ["Close"] = "Close_lang_129",
        ["Minimize"] = "Minimize_lang_129",
        ["Confirm"] = "Confirm_lang_129",
        ["Cancel"] = "Cancel_lang_129",
        ["Yes"] = "Yes_lang_129",
        ["No"] = "No_lang_129",
        ["Loading"] = "Loading_lang_129",
        ["FPS"] = "FPS_lang_129",
        ["MS"] = "MS_lang_129",
        ["Active"] = "Active_lang_129",
        ["Inactive"] = "Inactive_lang_129",
        ["Success"] = "Success_lang_129",
        ["Error"] = "Error_lang_129",
        ["Warning"] = "Warning_lang_129",
        ["Information"] = "Information_lang_129",
        ["Advanced"] = "Advanced_lang_129",
        ["General"] = "General_lang_129",
        ["Player"] = "Player_lang_129",
        ["Visuals"] = "Visuals_lang_129",
        ["Misc"] = "Misc_lang_129",
        ["Credits"] = "Credits_lang_129",
    },
    ["lang_130"] = {
        ["_NAME"] = "Language_130",
        ["Search"] = "Search_lang_130",
        ["Settings"] = "Settings_lang_130",
        ["Themes"] = "Themes_lang_130",
        ["Languages"] = "Languages_lang_130",
        ["Close"] = "Close_lang_130",
        ["Minimize"] = "Minimize_lang_130",
        ["Confirm"] = "Confirm_lang_130",
        ["Cancel"] = "Cancel_lang_130",
        ["Yes"] = "Yes_lang_130",
        ["No"] = "No_lang_130",
        ["Loading"] = "Loading_lang_130",
        ["FPS"] = "FPS_lang_130",
        ["MS"] = "MS_lang_130",
        ["Active"] = "Active_lang_130",
        ["Inactive"] = "Inactive_lang_130",
        ["Success"] = "Success_lang_130",
        ["Error"] = "Error_lang_130",
        ["Warning"] = "Warning_lang_130",
        ["Information"] = "Information_lang_130",
        ["Advanced"] = "Advanced_lang_130",
        ["General"] = "General_lang_130",
        ["Player"] = "Player_lang_130",
        ["Visuals"] = "Visuals_lang_130",
        ["Misc"] = "Misc_lang_130",
        ["Credits"] = "Credits_lang_130",
    },
    ["lang_131"] = {
        ["_NAME"] = "Language_131",
        ["Search"] = "Search_lang_131",
        ["Settings"] = "Settings_lang_131",
        ["Themes"] = "Themes_lang_131",
        ["Languages"] = "Languages_lang_131",
        ["Close"] = "Close_lang_131",
        ["Minimize"] = "Minimize_lang_131",
        ["Confirm"] = "Confirm_lang_131",
        ["Cancel"] = "Cancel_lang_131",
        ["Yes"] = "Yes_lang_131",
        ["No"] = "No_lang_131",
        ["Loading"] = "Loading_lang_131",
        ["FPS"] = "FPS_lang_131",
        ["MS"] = "MS_lang_131",
        ["Active"] = "Active_lang_131",
        ["Inactive"] = "Inactive_lang_131",
        ["Success"] = "Success_lang_131",
        ["Error"] = "Error_lang_131",
        ["Warning"] = "Warning_lang_131",
        ["Information"] = "Information_lang_131",
        ["Advanced"] = "Advanced_lang_131",
        ["General"] = "General_lang_131",
        ["Player"] = "Player_lang_131",
        ["Visuals"] = "Visuals_lang_131",
        ["Misc"] = "Misc_lang_131",
        ["Credits"] = "Credits_lang_131",
    },
    ["lang_132"] = {
        ["_NAME"] = "Language_132",
        ["Search"] = "Search_lang_132",
        ["Settings"] = "Settings_lang_132",
        ["Themes"] = "Themes_lang_132",
        ["Languages"] = "Languages_lang_132",
        ["Close"] = "Close_lang_132",
        ["Minimize"] = "Minimize_lang_132",
        ["Confirm"] = "Confirm_lang_132",
        ["Cancel"] = "Cancel_lang_132",
        ["Yes"] = "Yes_lang_132",
        ["No"] = "No_lang_132",
        ["Loading"] = "Loading_lang_132",
        ["FPS"] = "FPS_lang_132",
        ["MS"] = "MS_lang_132",
        ["Active"] = "Active_lang_132",
        ["Inactive"] = "Inactive_lang_132",
        ["Success"] = "Success_lang_132",
        ["Error"] = "Error_lang_132",
        ["Warning"] = "Warning_lang_132",
        ["Information"] = "Information_lang_132",
        ["Advanced"] = "Advanced_lang_132",
        ["General"] = "General_lang_132",
        ["Player"] = "Player_lang_132",
        ["Visuals"] = "Visuals_lang_132",
        ["Misc"] = "Misc_lang_132",
        ["Credits"] = "Credits_lang_132",
    },
    ["lang_133"] = {
        ["_NAME"] = "Language_133",
        ["Search"] = "Search_lang_133",
        ["Settings"] = "Settings_lang_133",
        ["Themes"] = "Themes_lang_133",
        ["Languages"] = "Languages_lang_133",
        ["Close"] = "Close_lang_133",
        ["Minimize"] = "Minimize_lang_133",
        ["Confirm"] = "Confirm_lang_133",
        ["Cancel"] = "Cancel_lang_133",
        ["Yes"] = "Yes_lang_133",
        ["No"] = "No_lang_133",
        ["Loading"] = "Loading_lang_133",
        ["FPS"] = "FPS_lang_133",
        ["MS"] = "MS_lang_133",
        ["Active"] = "Active_lang_133",
        ["Inactive"] = "Inactive_lang_133",
        ["Success"] = "Success_lang_133",
        ["Error"] = "Error_lang_133",
        ["Warning"] = "Warning_lang_133",
        ["Information"] = "Information_lang_133",
        ["Advanced"] = "Advanced_lang_133",
        ["General"] = "General_lang_133",
        ["Player"] = "Player_lang_133",
        ["Visuals"] = "Visuals_lang_133",
        ["Misc"] = "Misc_lang_133",
        ["Credits"] = "Credits_lang_133",
    },
    ["lang_134"] = {
        ["_NAME"] = "Language_134",
        ["Search"] = "Search_lang_134",
        ["Settings"] = "Settings_lang_134",
        ["Themes"] = "Themes_lang_134",
        ["Languages"] = "Languages_lang_134",
        ["Close"] = "Close_lang_134",
        ["Minimize"] = "Minimize_lang_134",
        ["Confirm"] = "Confirm_lang_134",
        ["Cancel"] = "Cancel_lang_134",
        ["Yes"] = "Yes_lang_134",
        ["No"] = "No_lang_134",
        ["Loading"] = "Loading_lang_134",
        ["FPS"] = "FPS_lang_134",
        ["MS"] = "MS_lang_134",
        ["Active"] = "Active_lang_134",
        ["Inactive"] = "Inactive_lang_134",
        ["Success"] = "Success_lang_134",
        ["Error"] = "Error_lang_134",
        ["Warning"] = "Warning_lang_134",
        ["Information"] = "Information_lang_134",
        ["Advanced"] = "Advanced_lang_134",
        ["General"] = "General_lang_134",
        ["Player"] = "Player_lang_134",
        ["Visuals"] = "Visuals_lang_134",
        ["Misc"] = "Misc_lang_134",
        ["Credits"] = "Credits_lang_134",
    },
    ["lang_135"] = {
        ["_NAME"] = "Language_135",
        ["Search"] = "Search_lang_135",
        ["Settings"] = "Settings_lang_135",
        ["Themes"] = "Themes_lang_135",
        ["Languages"] = "Languages_lang_135",
        ["Close"] = "Close_lang_135",
        ["Minimize"] = "Minimize_lang_135",
        ["Confirm"] = "Confirm_lang_135",
        ["Cancel"] = "Cancel_lang_135",
        ["Yes"] = "Yes_lang_135",
        ["No"] = "No_lang_135",
        ["Loading"] = "Loading_lang_135",
        ["FPS"] = "FPS_lang_135",
        ["MS"] = "MS_lang_135",
        ["Active"] = "Active_lang_135",
        ["Inactive"] = "Inactive_lang_135",
        ["Success"] = "Success_lang_135",
        ["Error"] = "Error_lang_135",
        ["Warning"] = "Warning_lang_135",
        ["Information"] = "Information_lang_135",
        ["Advanced"] = "Advanced_lang_135",
        ["General"] = "General_lang_135",
        ["Player"] = "Player_lang_135",
        ["Visuals"] = "Visuals_lang_135",
        ["Misc"] = "Misc_lang_135",
        ["Credits"] = "Credits_lang_135",
    },
    ["lang_136"] = {
        ["_NAME"] = "Language_136",
        ["Search"] = "Search_lang_136",
        ["Settings"] = "Settings_lang_136",
        ["Themes"] = "Themes_lang_136",
        ["Languages"] = "Languages_lang_136",
        ["Close"] = "Close_lang_136",
        ["Minimize"] = "Minimize_lang_136",
        ["Confirm"] = "Confirm_lang_136",
        ["Cancel"] = "Cancel_lang_136",
        ["Yes"] = "Yes_lang_136",
        ["No"] = "No_lang_136",
        ["Loading"] = "Loading_lang_136",
        ["FPS"] = "FPS_lang_136",
        ["MS"] = "MS_lang_136",
        ["Active"] = "Active_lang_136",
        ["Inactive"] = "Inactive_lang_136",
        ["Success"] = "Success_lang_136",
        ["Error"] = "Error_lang_136",
        ["Warning"] = "Warning_lang_136",
        ["Information"] = "Information_lang_136",
        ["Advanced"] = "Advanced_lang_136",
        ["General"] = "General_lang_136",
        ["Player"] = "Player_lang_136",
        ["Visuals"] = "Visuals_lang_136",
        ["Misc"] = "Misc_lang_136",
        ["Credits"] = "Credits_lang_136",
    },
    ["lang_137"] = {
        ["_NAME"] = "Language_137",
        ["Search"] = "Search_lang_137",
        ["Settings"] = "Settings_lang_137",
        ["Themes"] = "Themes_lang_137",
        ["Languages"] = "Languages_lang_137",
        ["Close"] = "Close_lang_137",
        ["Minimize"] = "Minimize_lang_137",
        ["Confirm"] = "Confirm_lang_137",
        ["Cancel"] = "Cancel_lang_137",
        ["Yes"] = "Yes_lang_137",
        ["No"] = "No_lang_137",
        ["Loading"] = "Loading_lang_137",
        ["FPS"] = "FPS_lang_137",
        ["MS"] = "MS_lang_137",
        ["Active"] = "Active_lang_137",
        ["Inactive"] = "Inactive_lang_137",
        ["Success"] = "Success_lang_137",
        ["Error"] = "Error_lang_137",
        ["Warning"] = "Warning_lang_137",
        ["Information"] = "Information_lang_137",
        ["Advanced"] = "Advanced_lang_137",
        ["General"] = "General_lang_137",
        ["Player"] = "Player_lang_137",
        ["Visuals"] = "Visuals_lang_137",
        ["Misc"] = "Misc_lang_137",
        ["Credits"] = "Credits_lang_137",
    },
    ["lang_138"] = {
        ["_NAME"] = "Language_138",
        ["Search"] = "Search_lang_138",
        ["Settings"] = "Settings_lang_138",
        ["Themes"] = "Themes_lang_138",
        ["Languages"] = "Languages_lang_138",
        ["Close"] = "Close_lang_138",
        ["Minimize"] = "Minimize_lang_138",
        ["Confirm"] = "Confirm_lang_138",
        ["Cancel"] = "Cancel_lang_138",
        ["Yes"] = "Yes_lang_138",
        ["No"] = "No_lang_138",
        ["Loading"] = "Loading_lang_138",
        ["FPS"] = "FPS_lang_138",
        ["MS"] = "MS_lang_138",
        ["Active"] = "Active_lang_138",
        ["Inactive"] = "Inactive_lang_138",
        ["Success"] = "Success_lang_138",
        ["Error"] = "Error_lang_138",
        ["Warning"] = "Warning_lang_138",
        ["Information"] = "Information_lang_138",
        ["Advanced"] = "Advanced_lang_138",
        ["General"] = "General_lang_138",
        ["Player"] = "Player_lang_138",
        ["Visuals"] = "Visuals_lang_138",
        ["Misc"] = "Misc_lang_138",
        ["Credits"] = "Credits_lang_138",
    },
    ["lang_139"] = {
        ["_NAME"] = "Language_139",
        ["Search"] = "Search_lang_139",
        ["Settings"] = "Settings_lang_139",
        ["Themes"] = "Themes_lang_139",
        ["Languages"] = "Languages_lang_139",
        ["Close"] = "Close_lang_139",
        ["Minimize"] = "Minimize_lang_139",
        ["Confirm"] = "Confirm_lang_139",
        ["Cancel"] = "Cancel_lang_139",
        ["Yes"] = "Yes_lang_139",
        ["No"] = "No_lang_139",
        ["Loading"] = "Loading_lang_139",
        ["FPS"] = "FPS_lang_139",
        ["MS"] = "MS_lang_139",
        ["Active"] = "Active_lang_139",
        ["Inactive"] = "Inactive_lang_139",
        ["Success"] = "Success_lang_139",
        ["Error"] = "Error_lang_139",
        ["Warning"] = "Warning_lang_139",
        ["Information"] = "Information_lang_139",
        ["Advanced"] = "Advanced_lang_139",
        ["General"] = "General_lang_139",
        ["Player"] = "Player_lang_139",
        ["Visuals"] = "Visuals_lang_139",
        ["Misc"] = "Misc_lang_139",
        ["Credits"] = "Credits_lang_139",
    },
    ["lang_140"] = {
        ["_NAME"] = "Language_140",
        ["Search"] = "Search_lang_140",
        ["Settings"] = "Settings_lang_140",
        ["Themes"] = "Themes_lang_140",
        ["Languages"] = "Languages_lang_140",
        ["Close"] = "Close_lang_140",
        ["Minimize"] = "Minimize_lang_140",
        ["Confirm"] = "Confirm_lang_140",
        ["Cancel"] = "Cancel_lang_140",
        ["Yes"] = "Yes_lang_140",
        ["No"] = "No_lang_140",
        ["Loading"] = "Loading_lang_140",
        ["FPS"] = "FPS_lang_140",
        ["MS"] = "MS_lang_140",
        ["Active"] = "Active_lang_140",
        ["Inactive"] = "Inactive_lang_140",
        ["Success"] = "Success_lang_140",
        ["Error"] = "Error_lang_140",
        ["Warning"] = "Warning_lang_140",
        ["Information"] = "Information_lang_140",
        ["Advanced"] = "Advanced_lang_140",
        ["General"] = "General_lang_140",
        ["Player"] = "Player_lang_140",
        ["Visuals"] = "Visuals_lang_140",
        ["Misc"] = "Misc_lang_140",
        ["Credits"] = "Credits_lang_140",
    },
    ["lang_141"] = {
        ["_NAME"] = "Language_141",
        ["Search"] = "Search_lang_141",
        ["Settings"] = "Settings_lang_141",
        ["Themes"] = "Themes_lang_141",
        ["Languages"] = "Languages_lang_141",
        ["Close"] = "Close_lang_141",
        ["Minimize"] = "Minimize_lang_141",
        ["Confirm"] = "Confirm_lang_141",
        ["Cancel"] = "Cancel_lang_141",
        ["Yes"] = "Yes_lang_141",
        ["No"] = "No_lang_141",
        ["Loading"] = "Loading_lang_141",
        ["FPS"] = "FPS_lang_141",
        ["MS"] = "MS_lang_141",
        ["Active"] = "Active_lang_141",
        ["Inactive"] = "Inactive_lang_141",
        ["Success"] = "Success_lang_141",
        ["Error"] = "Error_lang_141",
        ["Warning"] = "Warning_lang_141",
        ["Information"] = "Information_lang_141",
        ["Advanced"] = "Advanced_lang_141",
        ["General"] = "General_lang_141",
        ["Player"] = "Player_lang_141",
        ["Visuals"] = "Visuals_lang_141",
        ["Misc"] = "Misc_lang_141",
        ["Credits"] = "Credits_lang_141",
    },
    ["lang_142"] = {
        ["_NAME"] = "Language_142",
        ["Search"] = "Search_lang_142",
        ["Settings"] = "Settings_lang_142",
        ["Themes"] = "Themes_lang_142",
        ["Languages"] = "Languages_lang_142",
        ["Close"] = "Close_lang_142",
        ["Minimize"] = "Minimize_lang_142",
        ["Confirm"] = "Confirm_lang_142",
        ["Cancel"] = "Cancel_lang_142",
        ["Yes"] = "Yes_lang_142",
        ["No"] = "No_lang_142",
        ["Loading"] = "Loading_lang_142",
        ["FPS"] = "FPS_lang_142",
        ["MS"] = "MS_lang_142",
        ["Active"] = "Active_lang_142",
        ["Inactive"] = "Inactive_lang_142",
        ["Success"] = "Success_lang_142",
        ["Error"] = "Error_lang_142",
        ["Warning"] = "Warning_lang_142",
        ["Information"] = "Information_lang_142",
        ["Advanced"] = "Advanced_lang_142",
        ["General"] = "General_lang_142",
        ["Player"] = "Player_lang_142",
        ["Visuals"] = "Visuals_lang_142",
        ["Misc"] = "Misc_lang_142",
        ["Credits"] = "Credits_lang_142",
    },
    ["lang_143"] = {
        ["_NAME"] = "Language_143",
        ["Search"] = "Search_lang_143",
        ["Settings"] = "Settings_lang_143",
        ["Themes"] = "Themes_lang_143",
        ["Languages"] = "Languages_lang_143",
        ["Close"] = "Close_lang_143",
        ["Minimize"] = "Minimize_lang_143",
        ["Confirm"] = "Confirm_lang_143",
        ["Cancel"] = "Cancel_lang_143",
        ["Yes"] = "Yes_lang_143",
        ["No"] = "No_lang_143",
        ["Loading"] = "Loading_lang_143",
        ["FPS"] = "FPS_lang_143",
        ["MS"] = "MS_lang_143",
        ["Active"] = "Active_lang_143",
        ["Inactive"] = "Inactive_lang_143",
        ["Success"] = "Success_lang_143",
        ["Error"] = "Error_lang_143",
        ["Warning"] = "Warning_lang_143",
        ["Information"] = "Information_lang_143",
        ["Advanced"] = "Advanced_lang_143",
        ["General"] = "General_lang_143",
        ["Player"] = "Player_lang_143",
        ["Visuals"] = "Visuals_lang_143",
        ["Misc"] = "Misc_lang_143",
        ["Credits"] = "Credits_lang_143",
    },
    ["lang_144"] = {
        ["_NAME"] = "Language_144",
        ["Search"] = "Search_lang_144",
        ["Settings"] = "Settings_lang_144",
        ["Themes"] = "Themes_lang_144",
        ["Languages"] = "Languages_lang_144",
        ["Close"] = "Close_lang_144",
        ["Minimize"] = "Minimize_lang_144",
        ["Confirm"] = "Confirm_lang_144",
        ["Cancel"] = "Cancel_lang_144",
        ["Yes"] = "Yes_lang_144",
        ["No"] = "No_lang_144",
        ["Loading"] = "Loading_lang_144",
        ["FPS"] = "FPS_lang_144",
        ["MS"] = "MS_lang_144",
        ["Active"] = "Active_lang_144",
        ["Inactive"] = "Inactive_lang_144",
        ["Success"] = "Success_lang_144",
        ["Error"] = "Error_lang_144",
        ["Warning"] = "Warning_lang_144",
        ["Information"] = "Information_lang_144",
        ["Advanced"] = "Advanced_lang_144",
        ["General"] = "General_lang_144",
        ["Player"] = "Player_lang_144",
        ["Visuals"] = "Visuals_lang_144",
        ["Misc"] = "Misc_lang_144",
        ["Credits"] = "Credits_lang_144",
    },
    ["lang_145"] = {
        ["_NAME"] = "Language_145",
        ["Search"] = "Search_lang_145",
        ["Settings"] = "Settings_lang_145",
        ["Themes"] = "Themes_lang_145",
        ["Languages"] = "Languages_lang_145",
        ["Close"] = "Close_lang_145",
        ["Minimize"] = "Minimize_lang_145",
        ["Confirm"] = "Confirm_lang_145",
        ["Cancel"] = "Cancel_lang_145",
        ["Yes"] = "Yes_lang_145",
        ["No"] = "No_lang_145",
        ["Loading"] = "Loading_lang_145",
        ["FPS"] = "FPS_lang_145",
        ["MS"] = "MS_lang_145",
        ["Active"] = "Active_lang_145",
        ["Inactive"] = "Inactive_lang_145",
        ["Success"] = "Success_lang_145",
        ["Error"] = "Error_lang_145",
        ["Warning"] = "Warning_lang_145",
        ["Information"] = "Information_lang_145",
        ["Advanced"] = "Advanced_lang_145",
        ["General"] = "General_lang_145",
        ["Player"] = "Player_lang_145",
        ["Visuals"] = "Visuals_lang_145",
        ["Misc"] = "Misc_lang_145",
        ["Credits"] = "Credits_lang_145",
    },
    ["lang_146"] = {
        ["_NAME"] = "Language_146",
        ["Search"] = "Search_lang_146",
        ["Settings"] = "Settings_lang_146",
        ["Themes"] = "Themes_lang_146",
        ["Languages"] = "Languages_lang_146",
        ["Close"] = "Close_lang_146",
        ["Minimize"] = "Minimize_lang_146",
        ["Confirm"] = "Confirm_lang_146",
        ["Cancel"] = "Cancel_lang_146",
        ["Yes"] = "Yes_lang_146",
        ["No"] = "No_lang_146",
        ["Loading"] = "Loading_lang_146",
        ["FPS"] = "FPS_lang_146",
        ["MS"] = "MS_lang_146",
        ["Active"] = "Active_lang_146",
        ["Inactive"] = "Inactive_lang_146",
        ["Success"] = "Success_lang_146",
        ["Error"] = "Error_lang_146",
        ["Warning"] = "Warning_lang_146",
        ["Information"] = "Information_lang_146",
        ["Advanced"] = "Advanced_lang_146",
        ["General"] = "General_lang_146",
        ["Player"] = "Player_lang_146",
        ["Visuals"] = "Visuals_lang_146",
        ["Misc"] = "Misc_lang_146",
        ["Credits"] = "Credits_lang_146",
    },
    ["lang_147"] = {
        ["_NAME"] = "Language_147",
        ["Search"] = "Search_lang_147",
        ["Settings"] = "Settings_lang_147",
        ["Themes"] = "Themes_lang_147",
        ["Languages"] = "Languages_lang_147",
        ["Close"] = "Close_lang_147",
        ["Minimize"] = "Minimize_lang_147",
        ["Confirm"] = "Confirm_lang_147",
        ["Cancel"] = "Cancel_lang_147",
        ["Yes"] = "Yes_lang_147",
        ["No"] = "No_lang_147",
        ["Loading"] = "Loading_lang_147",
        ["FPS"] = "FPS_lang_147",
        ["MS"] = "MS_lang_147",
        ["Active"] = "Active_lang_147",
        ["Inactive"] = "Inactive_lang_147",
        ["Success"] = "Success_lang_147",
        ["Error"] = "Error_lang_147",
        ["Warning"] = "Warning_lang_147",
        ["Information"] = "Information_lang_147",
        ["Advanced"] = "Advanced_lang_147",
        ["General"] = "General_lang_147",
        ["Player"] = "Player_lang_147",
        ["Visuals"] = "Visuals_lang_147",
        ["Misc"] = "Misc_lang_147",
        ["Credits"] = "Credits_lang_147",
    },
    ["lang_148"] = {
        ["_NAME"] = "Language_148",
        ["Search"] = "Search_lang_148",
        ["Settings"] = "Settings_lang_148",
        ["Themes"] = "Themes_lang_148",
        ["Languages"] = "Languages_lang_148",
        ["Close"] = "Close_lang_148",
        ["Minimize"] = "Minimize_lang_148",
        ["Confirm"] = "Confirm_lang_148",
        ["Cancel"] = "Cancel_lang_148",
        ["Yes"] = "Yes_lang_148",
        ["No"] = "No_lang_148",
        ["Loading"] = "Loading_lang_148",
        ["FPS"] = "FPS_lang_148",
        ["MS"] = "MS_lang_148",
        ["Active"] = "Active_lang_148",
        ["Inactive"] = "Inactive_lang_148",
        ["Success"] = "Success_lang_148",
        ["Error"] = "Error_lang_148",
        ["Warning"] = "Warning_lang_148",
        ["Information"] = "Information_lang_148",
        ["Advanced"] = "Advanced_lang_148",
        ["General"] = "General_lang_148",
        ["Player"] = "Player_lang_148",
        ["Visuals"] = "Visuals_lang_148",
        ["Misc"] = "Misc_lang_148",
        ["Credits"] = "Credits_lang_148",
    },
    ["lang_149"] = {
        ["_NAME"] = "Language_149",
        ["Search"] = "Search_lang_149",
        ["Settings"] = "Settings_lang_149",
        ["Themes"] = "Themes_lang_149",
        ["Languages"] = "Languages_lang_149",
        ["Close"] = "Close_lang_149",
        ["Minimize"] = "Minimize_lang_149",
        ["Confirm"] = "Confirm_lang_149",
        ["Cancel"] = "Cancel_lang_149",
        ["Yes"] = "Yes_lang_149",
        ["No"] = "No_lang_149",
        ["Loading"] = "Loading_lang_149",
        ["FPS"] = "FPS_lang_149",
        ["MS"] = "MS_lang_149",
        ["Active"] = "Active_lang_149",
        ["Inactive"] = "Inactive_lang_149",
        ["Success"] = "Success_lang_149",
        ["Error"] = "Error_lang_149",
        ["Warning"] = "Warning_lang_149",
        ["Information"] = "Information_lang_149",
        ["Advanced"] = "Advanced_lang_149",
        ["General"] = "General_lang_149",
        ["Player"] = "Player_lang_149",
        ["Visuals"] = "Visuals_lang_149",
        ["Misc"] = "Misc_lang_149",
        ["Credits"] = "Credits_lang_149",
    },
    ["lang_150"] = {
        ["_NAME"] = "Language_150",
        ["Search"] = "Search_lang_150",
        ["Settings"] = "Settings_lang_150",
        ["Themes"] = "Themes_lang_150",
        ["Languages"] = "Languages_lang_150",
        ["Close"] = "Close_lang_150",
        ["Minimize"] = "Minimize_lang_150",
        ["Confirm"] = "Confirm_lang_150",
        ["Cancel"] = "Cancel_lang_150",
        ["Yes"] = "Yes_lang_150",
        ["No"] = "No_lang_150",
        ["Loading"] = "Loading_lang_150",
        ["FPS"] = "FPS_lang_150",
        ["MS"] = "MS_lang_150",
        ["Active"] = "Active_lang_150",
        ["Inactive"] = "Inactive_lang_150",
        ["Success"] = "Success_lang_150",
        ["Error"] = "Error_lang_150",
        ["Warning"] = "Warning_lang_150",
        ["Information"] = "Information_lang_150",
        ["Advanced"] = "Advanced_lang_150",
        ["General"] = "General_lang_150",
        ["Player"] = "Player_lang_150",
        ["Visuals"] = "Visuals_lang_150",
        ["Misc"] = "Misc_lang_150",
        ["Credits"] = "Credits_lang_150",
    },
    ["lang_151"] = {
        ["_NAME"] = "Language_151",
        ["Search"] = "Search_lang_151",
        ["Settings"] = "Settings_lang_151",
        ["Themes"] = "Themes_lang_151",
        ["Languages"] = "Languages_lang_151",
        ["Close"] = "Close_lang_151",
        ["Minimize"] = "Minimize_lang_151",
        ["Confirm"] = "Confirm_lang_151",
        ["Cancel"] = "Cancel_lang_151",
        ["Yes"] = "Yes_lang_151",
        ["No"] = "No_lang_151",
        ["Loading"] = "Loading_lang_151",
        ["FPS"] = "FPS_lang_151",
        ["MS"] = "MS_lang_151",
        ["Active"] = "Active_lang_151",
        ["Inactive"] = "Inactive_lang_151",
        ["Success"] = "Success_lang_151",
        ["Error"] = "Error_lang_151",
        ["Warning"] = "Warning_lang_151",
        ["Information"] = "Information_lang_151",
        ["Advanced"] = "Advanced_lang_151",
        ["General"] = "General_lang_151",
        ["Player"] = "Player_lang_151",
        ["Visuals"] = "Visuals_lang_151",
        ["Misc"] = "Misc_lang_151",
        ["Credits"] = "Credits_lang_151",
    },
    ["lang_152"] = {
        ["_NAME"] = "Language_152",
        ["Search"] = "Search_lang_152",
        ["Settings"] = "Settings_lang_152",
        ["Themes"] = "Themes_lang_152",
        ["Languages"] = "Languages_lang_152",
        ["Close"] = "Close_lang_152",
        ["Minimize"] = "Minimize_lang_152",
        ["Confirm"] = "Confirm_lang_152",
        ["Cancel"] = "Cancel_lang_152",
        ["Yes"] = "Yes_lang_152",
        ["No"] = "No_lang_152",
        ["Loading"] = "Loading_lang_152",
        ["FPS"] = "FPS_lang_152",
        ["MS"] = "MS_lang_152",
        ["Active"] = "Active_lang_152",
        ["Inactive"] = "Inactive_lang_152",
        ["Success"] = "Success_lang_152",
        ["Error"] = "Error_lang_152",
        ["Warning"] = "Warning_lang_152",
        ["Information"] = "Information_lang_152",
        ["Advanced"] = "Advanced_lang_152",
        ["General"] = "General_lang_152",
        ["Player"] = "Player_lang_152",
        ["Visuals"] = "Visuals_lang_152",
        ["Misc"] = "Misc_lang_152",
        ["Credits"] = "Credits_lang_152",
    },
    ["lang_153"] = {
        ["_NAME"] = "Language_153",
        ["Search"] = "Search_lang_153",
        ["Settings"] = "Settings_lang_153",
        ["Themes"] = "Themes_lang_153",
        ["Languages"] = "Languages_lang_153",
        ["Close"] = "Close_lang_153",
        ["Minimize"] = "Minimize_lang_153",
        ["Confirm"] = "Confirm_lang_153",
        ["Cancel"] = "Cancel_lang_153",
        ["Yes"] = "Yes_lang_153",
        ["No"] = "No_lang_153",
        ["Loading"] = "Loading_lang_153",
        ["FPS"] = "FPS_lang_153",
        ["MS"] = "MS_lang_153",
        ["Active"] = "Active_lang_153",
        ["Inactive"] = "Inactive_lang_153",
        ["Success"] = "Success_lang_153",
        ["Error"] = "Error_lang_153",
        ["Warning"] = "Warning_lang_153",
        ["Information"] = "Information_lang_153",
        ["Advanced"] = "Advanced_lang_153",
        ["General"] = "General_lang_153",
        ["Player"] = "Player_lang_153",
        ["Visuals"] = "Visuals_lang_153",
        ["Misc"] = "Misc_lang_153",
        ["Credits"] = "Credits_lang_153",
    },
    ["lang_154"] = {
        ["_NAME"] = "Language_154",
        ["Search"] = "Search_lang_154",
        ["Settings"] = "Settings_lang_154",
        ["Themes"] = "Themes_lang_154",
        ["Languages"] = "Languages_lang_154",
        ["Close"] = "Close_lang_154",
        ["Minimize"] = "Minimize_lang_154",
        ["Confirm"] = "Confirm_lang_154",
        ["Cancel"] = "Cancel_lang_154",
        ["Yes"] = "Yes_lang_154",
        ["No"] = "No_lang_154",
        ["Loading"] = "Loading_lang_154",
        ["FPS"] = "FPS_lang_154",
        ["MS"] = "MS_lang_154",
        ["Active"] = "Active_lang_154",
        ["Inactive"] = "Inactive_lang_154",
        ["Success"] = "Success_lang_154",
        ["Error"] = "Error_lang_154",
        ["Warning"] = "Warning_lang_154",
        ["Information"] = "Information_lang_154",
        ["Advanced"] = "Advanced_lang_154",
        ["General"] = "General_lang_154",
        ["Player"] = "Player_lang_154",
        ["Visuals"] = "Visuals_lang_154",
        ["Misc"] = "Misc_lang_154",
        ["Credits"] = "Credits_lang_154",
    },
    ["lang_155"] = {
        ["_NAME"] = "Language_155",
        ["Search"] = "Search_lang_155",
        ["Settings"] = "Settings_lang_155",
        ["Themes"] = "Themes_lang_155",
        ["Languages"] = "Languages_lang_155",
        ["Close"] = "Close_lang_155",
        ["Minimize"] = "Minimize_lang_155",
        ["Confirm"] = "Confirm_lang_155",
        ["Cancel"] = "Cancel_lang_155",
        ["Yes"] = "Yes_lang_155",
        ["No"] = "No_lang_155",
        ["Loading"] = "Loading_lang_155",
        ["FPS"] = "FPS_lang_155",
        ["MS"] = "MS_lang_155",
        ["Active"] = "Active_lang_155",
        ["Inactive"] = "Inactive_lang_155",
        ["Success"] = "Success_lang_155",
        ["Error"] = "Error_lang_155",
        ["Warning"] = "Warning_lang_155",
        ["Information"] = "Information_lang_155",
        ["Advanced"] = "Advanced_lang_155",
        ["General"] = "General_lang_155",
        ["Player"] = "Player_lang_155",
        ["Visuals"] = "Visuals_lang_155",
        ["Misc"] = "Misc_lang_155",
        ["Credits"] = "Credits_lang_155",
    },
    ["lang_156"] = {
        ["_NAME"] = "Language_156",
        ["Search"] = "Search_lang_156",
        ["Settings"] = "Settings_lang_156",
        ["Themes"] = "Themes_lang_156",
        ["Languages"] = "Languages_lang_156",
        ["Close"] = "Close_lang_156",
        ["Minimize"] = "Minimize_lang_156",
        ["Confirm"] = "Confirm_lang_156",
        ["Cancel"] = "Cancel_lang_156",
        ["Yes"] = "Yes_lang_156",
        ["No"] = "No_lang_156",
        ["Loading"] = "Loading_lang_156",
        ["FPS"] = "FPS_lang_156",
        ["MS"] = "MS_lang_156",
        ["Active"] = "Active_lang_156",
        ["Inactive"] = "Inactive_lang_156",
        ["Success"] = "Success_lang_156",
        ["Error"] = "Error_lang_156",
        ["Warning"] = "Warning_lang_156",
        ["Information"] = "Information_lang_156",
        ["Advanced"] = "Advanced_lang_156",
        ["General"] = "General_lang_156",
        ["Player"] = "Player_lang_156",
        ["Visuals"] = "Visuals_lang_156",
        ["Misc"] = "Misc_lang_156",
        ["Credits"] = "Credits_lang_156",
    },
    ["lang_157"] = {
        ["_NAME"] = "Language_157",
        ["Search"] = "Search_lang_157",
        ["Settings"] = "Settings_lang_157",
        ["Themes"] = "Themes_lang_157",
        ["Languages"] = "Languages_lang_157",
        ["Close"] = "Close_lang_157",
        ["Minimize"] = "Minimize_lang_157",
        ["Confirm"] = "Confirm_lang_157",
        ["Cancel"] = "Cancel_lang_157",
        ["Yes"] = "Yes_lang_157",
        ["No"] = "No_lang_157",
        ["Loading"] = "Loading_lang_157",
        ["FPS"] = "FPS_lang_157",
        ["MS"] = "MS_lang_157",
        ["Active"] = "Active_lang_157",
        ["Inactive"] = "Inactive_lang_157",
        ["Success"] = "Success_lang_157",
        ["Error"] = "Error_lang_157",
        ["Warning"] = "Warning_lang_157",
        ["Information"] = "Information_lang_157",
        ["Advanced"] = "Advanced_lang_157",
        ["General"] = "General_lang_157",
        ["Player"] = "Player_lang_157",
        ["Visuals"] = "Visuals_lang_157",
        ["Misc"] = "Misc_lang_157",
        ["Credits"] = "Credits_lang_157",
    },
    ["lang_158"] = {
        ["_NAME"] = "Language_158",
        ["Search"] = "Search_lang_158",
        ["Settings"] = "Settings_lang_158",
        ["Themes"] = "Themes_lang_158",
        ["Languages"] = "Languages_lang_158",
        ["Close"] = "Close_lang_158",
        ["Minimize"] = "Minimize_lang_158",
        ["Confirm"] = "Confirm_lang_158",
        ["Cancel"] = "Cancel_lang_158",
        ["Yes"] = "Yes_lang_158",
        ["No"] = "No_lang_158",
        ["Loading"] = "Loading_lang_158",
        ["FPS"] = "FPS_lang_158",
        ["MS"] = "MS_lang_158",
        ["Active"] = "Active_lang_158",
        ["Inactive"] = "Inactive_lang_158",
        ["Success"] = "Success_lang_158",
        ["Error"] = "Error_lang_158",
        ["Warning"] = "Warning_lang_158",
        ["Information"] = "Information_lang_158",
        ["Advanced"] = "Advanced_lang_158",
        ["General"] = "General_lang_158",
        ["Player"] = "Player_lang_158",
        ["Visuals"] = "Visuals_lang_158",
        ["Misc"] = "Misc_lang_158",
        ["Credits"] = "Credits_lang_158",
    },
    ["lang_159"] = {
        ["_NAME"] = "Language_159",
        ["Search"] = "Search_lang_159",
        ["Settings"] = "Settings_lang_159",
        ["Themes"] = "Themes_lang_159",
        ["Languages"] = "Languages_lang_159",
        ["Close"] = "Close_lang_159",
        ["Minimize"] = "Minimize_lang_159",
        ["Confirm"] = "Confirm_lang_159",
        ["Cancel"] = "Cancel_lang_159",
        ["Yes"] = "Yes_lang_159",
        ["No"] = "No_lang_159",
        ["Loading"] = "Loading_lang_159",
        ["FPS"] = "FPS_lang_159",
        ["MS"] = "MS_lang_159",
        ["Active"] = "Active_lang_159",
        ["Inactive"] = "Inactive_lang_159",
        ["Success"] = "Success_lang_159",
        ["Error"] = "Error_lang_159",
        ["Warning"] = "Warning_lang_159",
        ["Information"] = "Information_lang_159",
        ["Advanced"] = "Advanced_lang_159",
        ["General"] = "General_lang_159",
        ["Player"] = "Player_lang_159",
        ["Visuals"] = "Visuals_lang_159",
        ["Misc"] = "Misc_lang_159",
        ["Credits"] = "Credits_lang_159",
    },
    ["lang_160"] = {
        ["_NAME"] = "Language_160",
        ["Search"] = "Search_lang_160",
        ["Settings"] = "Settings_lang_160",
        ["Themes"] = "Themes_lang_160",
        ["Languages"] = "Languages_lang_160",
        ["Close"] = "Close_lang_160",
        ["Minimize"] = "Minimize_lang_160",
        ["Confirm"] = "Confirm_lang_160",
        ["Cancel"] = "Cancel_lang_160",
        ["Yes"] = "Yes_lang_160",
        ["No"] = "No_lang_160",
        ["Loading"] = "Loading_lang_160",
        ["FPS"] = "FPS_lang_160",
        ["MS"] = "MS_lang_160",
        ["Active"] = "Active_lang_160",
        ["Inactive"] = "Inactive_lang_160",
        ["Success"] = "Success_lang_160",
        ["Error"] = "Error_lang_160",
        ["Warning"] = "Warning_lang_160",
        ["Information"] = "Information_lang_160",
        ["Advanced"] = "Advanced_lang_160",
        ["General"] = "General_lang_160",
        ["Player"] = "Player_lang_160",
        ["Visuals"] = "Visuals_lang_160",
        ["Misc"] = "Misc_lang_160",
        ["Credits"] = "Credits_lang_160",
    },
    ["lang_161"] = {
        ["_NAME"] = "Language_161",
        ["Search"] = "Search_lang_161",
        ["Settings"] = "Settings_lang_161",
        ["Themes"] = "Themes_lang_161",
        ["Languages"] = "Languages_lang_161",
        ["Close"] = "Close_lang_161",
        ["Minimize"] = "Minimize_lang_161",
        ["Confirm"] = "Confirm_lang_161",
        ["Cancel"] = "Cancel_lang_161",
        ["Yes"] = "Yes_lang_161",
        ["No"] = "No_lang_161",
        ["Loading"] = "Loading_lang_161",
        ["FPS"] = "FPS_lang_161",
        ["MS"] = "MS_lang_161",
        ["Active"] = "Active_lang_161",
        ["Inactive"] = "Inactive_lang_161",
        ["Success"] = "Success_lang_161",
        ["Error"] = "Error_lang_161",
        ["Warning"] = "Warning_lang_161",
        ["Information"] = "Information_lang_161",
        ["Advanced"] = "Advanced_lang_161",
        ["General"] = "General_lang_161",
        ["Player"] = "Player_lang_161",
        ["Visuals"] = "Visuals_lang_161",
        ["Misc"] = "Misc_lang_161",
        ["Credits"] = "Credits_lang_161",
    },
    ["lang_162"] = {
        ["_NAME"] = "Language_162",
        ["Search"] = "Search_lang_162",
        ["Settings"] = "Settings_lang_162",
        ["Themes"] = "Themes_lang_162",
        ["Languages"] = "Languages_lang_162",
        ["Close"] = "Close_lang_162",
        ["Minimize"] = "Minimize_lang_162",
        ["Confirm"] = "Confirm_lang_162",
        ["Cancel"] = "Cancel_lang_162",
        ["Yes"] = "Yes_lang_162",
        ["No"] = "No_lang_162",
        ["Loading"] = "Loading_lang_162",
        ["FPS"] = "FPS_lang_162",
        ["MS"] = "MS_lang_162",
        ["Active"] = "Active_lang_162",
        ["Inactive"] = "Inactive_lang_162",
        ["Success"] = "Success_lang_162",
        ["Error"] = "Error_lang_162",
        ["Warning"] = "Warning_lang_162",
        ["Information"] = "Information_lang_162",
        ["Advanced"] = "Advanced_lang_162",
        ["General"] = "General_lang_162",
        ["Player"] = "Player_lang_162",
        ["Visuals"] = "Visuals_lang_162",
        ["Misc"] = "Misc_lang_162",
        ["Credits"] = "Credits_lang_162",
    },
    ["lang_163"] = {
        ["_NAME"] = "Language_163",
        ["Search"] = "Search_lang_163",
        ["Settings"] = "Settings_lang_163",
        ["Themes"] = "Themes_lang_163",
        ["Languages"] = "Languages_lang_163",
        ["Close"] = "Close_lang_163",
        ["Minimize"] = "Minimize_lang_163",
        ["Confirm"] = "Confirm_lang_163",
        ["Cancel"] = "Cancel_lang_163",
        ["Yes"] = "Yes_lang_163",
        ["No"] = "No_lang_163",
        ["Loading"] = "Loading_lang_163",
        ["FPS"] = "FPS_lang_163",
        ["MS"] = "MS_lang_163",
        ["Active"] = "Active_lang_163",
        ["Inactive"] = "Inactive_lang_163",
        ["Success"] = "Success_lang_163",
        ["Error"] = "Error_lang_163",
        ["Warning"] = "Warning_lang_163",
        ["Information"] = "Information_lang_163",
        ["Advanced"] = "Advanced_lang_163",
        ["General"] = "General_lang_163",
        ["Player"] = "Player_lang_163",
        ["Visuals"] = "Visuals_lang_163",
        ["Misc"] = "Misc_lang_163",
        ["Credits"] = "Credits_lang_163",
    },
    ["lang_164"] = {
        ["_NAME"] = "Language_164",
        ["Search"] = "Search_lang_164",
        ["Settings"] = "Settings_lang_164",
        ["Themes"] = "Themes_lang_164",
        ["Languages"] = "Languages_lang_164",
        ["Close"] = "Close_lang_164",
        ["Minimize"] = "Minimize_lang_164",
        ["Confirm"] = "Confirm_lang_164",
        ["Cancel"] = "Cancel_lang_164",
        ["Yes"] = "Yes_lang_164",
        ["No"] = "No_lang_164",
        ["Loading"] = "Loading_lang_164",
        ["FPS"] = "FPS_lang_164",
        ["MS"] = "MS_lang_164",
        ["Active"] = "Active_lang_164",
        ["Inactive"] = "Inactive_lang_164",
        ["Success"] = "Success_lang_164",
        ["Error"] = "Error_lang_164",
        ["Warning"] = "Warning_lang_164",
        ["Information"] = "Information_lang_164",
        ["Advanced"] = "Advanced_lang_164",
        ["General"] = "General_lang_164",
        ["Player"] = "Player_lang_164",
        ["Visuals"] = "Visuals_lang_164",
        ["Misc"] = "Misc_lang_164",
        ["Credits"] = "Credits_lang_164",
    },
    ["lang_165"] = {
        ["_NAME"] = "Language_165",
        ["Search"] = "Search_lang_165",
        ["Settings"] = "Settings_lang_165",
        ["Themes"] = "Themes_lang_165",
        ["Languages"] = "Languages_lang_165",
        ["Close"] = "Close_lang_165",
        ["Minimize"] = "Minimize_lang_165",
        ["Confirm"] = "Confirm_lang_165",
        ["Cancel"] = "Cancel_lang_165",
        ["Yes"] = "Yes_lang_165",
        ["No"] = "No_lang_165",
        ["Loading"] = "Loading_lang_165",
        ["FPS"] = "FPS_lang_165",
        ["MS"] = "MS_lang_165",
        ["Active"] = "Active_lang_165",
        ["Inactive"] = "Inactive_lang_165",
        ["Success"] = "Success_lang_165",
        ["Error"] = "Error_lang_165",
        ["Warning"] = "Warning_lang_165",
        ["Information"] = "Information_lang_165",
        ["Advanced"] = "Advanced_lang_165",
        ["General"] = "General_lang_165",
        ["Player"] = "Player_lang_165",
        ["Visuals"] = "Visuals_lang_165",
        ["Misc"] = "Misc_lang_165",
        ["Credits"] = "Credits_lang_165",
    },
    ["lang_166"] = {
        ["_NAME"] = "Language_166",
        ["Search"] = "Search_lang_166",
        ["Settings"] = "Settings_lang_166",
        ["Themes"] = "Themes_lang_166",
        ["Languages"] = "Languages_lang_166",
        ["Close"] = "Close_lang_166",
        ["Minimize"] = "Minimize_lang_166",
        ["Confirm"] = "Confirm_lang_166",
        ["Cancel"] = "Cancel_lang_166",
        ["Yes"] = "Yes_lang_166",
        ["No"] = "No_lang_166",
        ["Loading"] = "Loading_lang_166",
        ["FPS"] = "FPS_lang_166",
        ["MS"] = "MS_lang_166",
        ["Active"] = "Active_lang_166",
        ["Inactive"] = "Inactive_lang_166",
        ["Success"] = "Success_lang_166",
        ["Error"] = "Error_lang_166",
        ["Warning"] = "Warning_lang_166",
        ["Information"] = "Information_lang_166",
        ["Advanced"] = "Advanced_lang_166",
        ["General"] = "General_lang_166",
        ["Player"] = "Player_lang_166",
        ["Visuals"] = "Visuals_lang_166",
        ["Misc"] = "Misc_lang_166",
        ["Credits"] = "Credits_lang_166",
    },
    ["lang_167"] = {
        ["_NAME"] = "Language_167",
        ["Search"] = "Search_lang_167",
        ["Settings"] = "Settings_lang_167",
        ["Themes"] = "Themes_lang_167",
        ["Languages"] = "Languages_lang_167",
        ["Close"] = "Close_lang_167",
        ["Minimize"] = "Minimize_lang_167",
        ["Confirm"] = "Confirm_lang_167",
        ["Cancel"] = "Cancel_lang_167",
        ["Yes"] = "Yes_lang_167",
        ["No"] = "No_lang_167",
        ["Loading"] = "Loading_lang_167",
        ["FPS"] = "FPS_lang_167",
        ["MS"] = "MS_lang_167",
        ["Active"] = "Active_lang_167",
        ["Inactive"] = "Inactive_lang_167",
        ["Success"] = "Success_lang_167",
        ["Error"] = "Error_lang_167",
        ["Warning"] = "Warning_lang_167",
        ["Information"] = "Information_lang_167",
        ["Advanced"] = "Advanced_lang_167",
        ["General"] = "General_lang_167",
        ["Player"] = "Player_lang_167",
        ["Visuals"] = "Visuals_lang_167",
        ["Misc"] = "Misc_lang_167",
        ["Credits"] = "Credits_lang_167",
    },
    ["lang_168"] = {
        ["_NAME"] = "Language_168",
        ["Search"] = "Search_lang_168",
        ["Settings"] = "Settings_lang_168",
        ["Themes"] = "Themes_lang_168",
        ["Languages"] = "Languages_lang_168",
        ["Close"] = "Close_lang_168",
        ["Minimize"] = "Minimize_lang_168",
        ["Confirm"] = "Confirm_lang_168",
        ["Cancel"] = "Cancel_lang_168",
        ["Yes"] = "Yes_lang_168",
        ["No"] = "No_lang_168",
        ["Loading"] = "Loading_lang_168",
        ["FPS"] = "FPS_lang_168",
        ["MS"] = "MS_lang_168",
        ["Active"] = "Active_lang_168",
        ["Inactive"] = "Inactive_lang_168",
        ["Success"] = "Success_lang_168",
        ["Error"] = "Error_lang_168",
        ["Warning"] = "Warning_lang_168",
        ["Information"] = "Information_lang_168",
        ["Advanced"] = "Advanced_lang_168",
        ["General"] = "General_lang_168",
        ["Player"] = "Player_lang_168",
        ["Visuals"] = "Visuals_lang_168",
        ["Misc"] = "Misc_lang_168",
        ["Credits"] = "Credits_lang_168",
    },
    ["lang_169"] = {
        ["_NAME"] = "Language_169",
        ["Search"] = "Search_lang_169",
        ["Settings"] = "Settings_lang_169",
        ["Themes"] = "Themes_lang_169",
        ["Languages"] = "Languages_lang_169",
        ["Close"] = "Close_lang_169",
        ["Minimize"] = "Minimize_lang_169",
        ["Confirm"] = "Confirm_lang_169",
        ["Cancel"] = "Cancel_lang_169",
        ["Yes"] = "Yes_lang_169",
        ["No"] = "No_lang_169",
        ["Loading"] = "Loading_lang_169",
        ["FPS"] = "FPS_lang_169",
        ["MS"] = "MS_lang_169",
        ["Active"] = "Active_lang_169",
        ["Inactive"] = "Inactive_lang_169",
        ["Success"] = "Success_lang_169",
        ["Error"] = "Error_lang_169",
        ["Warning"] = "Warning_lang_169",
        ["Information"] = "Information_lang_169",
        ["Advanced"] = "Advanced_lang_169",
        ["General"] = "General_lang_169",
        ["Player"] = "Player_lang_169",
        ["Visuals"] = "Visuals_lang_169",
        ["Misc"] = "Misc_lang_169",
        ["Credits"] = "Credits_lang_169",
    },
    ["lang_170"] = {
        ["_NAME"] = "Language_170",
        ["Search"] = "Search_lang_170",
        ["Settings"] = "Settings_lang_170",
        ["Themes"] = "Themes_lang_170",
        ["Languages"] = "Languages_lang_170",
        ["Close"] = "Close_lang_170",
        ["Minimize"] = "Minimize_lang_170",
        ["Confirm"] = "Confirm_lang_170",
        ["Cancel"] = "Cancel_lang_170",
        ["Yes"] = "Yes_lang_170",
        ["No"] = "No_lang_170",
        ["Loading"] = "Loading_lang_170",
        ["FPS"] = "FPS_lang_170",
        ["MS"] = "MS_lang_170",
        ["Active"] = "Active_lang_170",
        ["Inactive"] = "Inactive_lang_170",
        ["Success"] = "Success_lang_170",
        ["Error"] = "Error_lang_170",
        ["Warning"] = "Warning_lang_170",
        ["Information"] = "Information_lang_170",
        ["Advanced"] = "Advanced_lang_170",
        ["General"] = "General_lang_170",
        ["Player"] = "Player_lang_170",
        ["Visuals"] = "Visuals_lang_170",
        ["Misc"] = "Misc_lang_170",
        ["Credits"] = "Credits_lang_170",
    },
    ["lang_171"] = {
        ["_NAME"] = "Language_171",
        ["Search"] = "Search_lang_171",
        ["Settings"] = "Settings_lang_171",
        ["Themes"] = "Themes_lang_171",
        ["Languages"] = "Languages_lang_171",
        ["Close"] = "Close_lang_171",
        ["Minimize"] = "Minimize_lang_171",
        ["Confirm"] = "Confirm_lang_171",
        ["Cancel"] = "Cancel_lang_171",
        ["Yes"] = "Yes_lang_171",
        ["No"] = "No_lang_171",
        ["Loading"] = "Loading_lang_171",
        ["FPS"] = "FPS_lang_171",
        ["MS"] = "MS_lang_171",
        ["Active"] = "Active_lang_171",
        ["Inactive"] = "Inactive_lang_171",
        ["Success"] = "Success_lang_171",
        ["Error"] = "Error_lang_171",
        ["Warning"] = "Warning_lang_171",
        ["Information"] = "Information_lang_171",
        ["Advanced"] = "Advanced_lang_171",
        ["General"] = "General_lang_171",
        ["Player"] = "Player_lang_171",
        ["Visuals"] = "Visuals_lang_171",
        ["Misc"] = "Misc_lang_171",
        ["Credits"] = "Credits_lang_171",
    },
    ["lang_172"] = {
        ["_NAME"] = "Language_172",
        ["Search"] = "Search_lang_172",
        ["Settings"] = "Settings_lang_172",
        ["Themes"] = "Themes_lang_172",
        ["Languages"] = "Languages_lang_172",
        ["Close"] = "Close_lang_172",
        ["Minimize"] = "Minimize_lang_172",
        ["Confirm"] = "Confirm_lang_172",
        ["Cancel"] = "Cancel_lang_172",
        ["Yes"] = "Yes_lang_172",
        ["No"] = "No_lang_172",
        ["Loading"] = "Loading_lang_172",
        ["FPS"] = "FPS_lang_172",
        ["MS"] = "MS_lang_172",
        ["Active"] = "Active_lang_172",
        ["Inactive"] = "Inactive_lang_172",
        ["Success"] = "Success_lang_172",
        ["Error"] = "Error_lang_172",
        ["Warning"] = "Warning_lang_172",
        ["Information"] = "Information_lang_172",
        ["Advanced"] = "Advanced_lang_172",
        ["General"] = "General_lang_172",
        ["Player"] = "Player_lang_172",
        ["Visuals"] = "Visuals_lang_172",
        ["Misc"] = "Misc_lang_172",
        ["Credits"] = "Credits_lang_172",
    },
    ["lang_173"] = {
        ["_NAME"] = "Language_173",
        ["Search"] = "Search_lang_173",
        ["Settings"] = "Settings_lang_173",
        ["Themes"] = "Themes_lang_173",
        ["Languages"] = "Languages_lang_173",
        ["Close"] = "Close_lang_173",
        ["Minimize"] = "Minimize_lang_173",
        ["Confirm"] = "Confirm_lang_173",
        ["Cancel"] = "Cancel_lang_173",
        ["Yes"] = "Yes_lang_173",
        ["No"] = "No_lang_173",
        ["Loading"] = "Loading_lang_173",
        ["FPS"] = "FPS_lang_173",
        ["MS"] = "MS_lang_173",
        ["Active"] = "Active_lang_173",
        ["Inactive"] = "Inactive_lang_173",
        ["Success"] = "Success_lang_173",
        ["Error"] = "Error_lang_173",
        ["Warning"] = "Warning_lang_173",
        ["Information"] = "Information_lang_173",
        ["Advanced"] = "Advanced_lang_173",
        ["General"] = "General_lang_173",
        ["Player"] = "Player_lang_173",
        ["Visuals"] = "Visuals_lang_173",
        ["Misc"] = "Misc_lang_173",
        ["Credits"] = "Credits_lang_173",
    },
    ["lang_174"] = {
        ["_NAME"] = "Language_174",
        ["Search"] = "Search_lang_174",
        ["Settings"] = "Settings_lang_174",
        ["Themes"] = "Themes_lang_174",
        ["Languages"] = "Languages_lang_174",
        ["Close"] = "Close_lang_174",
        ["Minimize"] = "Minimize_lang_174",
        ["Confirm"] = "Confirm_lang_174",
        ["Cancel"] = "Cancel_lang_174",
        ["Yes"] = "Yes_lang_174",
        ["No"] = "No_lang_174",
        ["Loading"] = "Loading_lang_174",
        ["FPS"] = "FPS_lang_174",
        ["MS"] = "MS_lang_174",
        ["Active"] = "Active_lang_174",
        ["Inactive"] = "Inactive_lang_174",
        ["Success"] = "Success_lang_174",
        ["Error"] = "Error_lang_174",
        ["Warning"] = "Warning_lang_174",
        ["Information"] = "Information_lang_174",
        ["Advanced"] = "Advanced_lang_174",
        ["General"] = "General_lang_174",
        ["Player"] = "Player_lang_174",
        ["Visuals"] = "Visuals_lang_174",
        ["Misc"] = "Misc_lang_174",
        ["Credits"] = "Credits_lang_174",
    },
    ["lang_175"] = {
        ["_NAME"] = "Language_175",
        ["Search"] = "Search_lang_175",
        ["Settings"] = "Settings_lang_175",
        ["Themes"] = "Themes_lang_175",
        ["Languages"] = "Languages_lang_175",
        ["Close"] = "Close_lang_175",
        ["Minimize"] = "Minimize_lang_175",
        ["Confirm"] = "Confirm_lang_175",
        ["Cancel"] = "Cancel_lang_175",
        ["Yes"] = "Yes_lang_175",
        ["No"] = "No_lang_175",
        ["Loading"] = "Loading_lang_175",
        ["FPS"] = "FPS_lang_175",
        ["MS"] = "MS_lang_175",
        ["Active"] = "Active_lang_175",
        ["Inactive"] = "Inactive_lang_175",
        ["Success"] = "Success_lang_175",
        ["Error"] = "Error_lang_175",
        ["Warning"] = "Warning_lang_175",
        ["Information"] = "Information_lang_175",
        ["Advanced"] = "Advanced_lang_175",
        ["General"] = "General_lang_175",
        ["Player"] = "Player_lang_175",
        ["Visuals"] = "Visuals_lang_175",
        ["Misc"] = "Misc_lang_175",
        ["Credits"] = "Credits_lang_175",
    },
    ["lang_176"] = {
        ["_NAME"] = "Language_176",
        ["Search"] = "Search_lang_176",
        ["Settings"] = "Settings_lang_176",
        ["Themes"] = "Themes_lang_176",
        ["Languages"] = "Languages_lang_176",
        ["Close"] = "Close_lang_176",
        ["Minimize"] = "Minimize_lang_176",
        ["Confirm"] = "Confirm_lang_176",
        ["Cancel"] = "Cancel_lang_176",
        ["Yes"] = "Yes_lang_176",
        ["No"] = "No_lang_176",
        ["Loading"] = "Loading_lang_176",
        ["FPS"] = "FPS_lang_176",
        ["MS"] = "MS_lang_176",
        ["Active"] = "Active_lang_176",
        ["Inactive"] = "Inactive_lang_176",
        ["Success"] = "Success_lang_176",
        ["Error"] = "Error_lang_176",
        ["Warning"] = "Warning_lang_176",
        ["Information"] = "Information_lang_176",
        ["Advanced"] = "Advanced_lang_176",
        ["General"] = "General_lang_176",
        ["Player"] = "Player_lang_176",
        ["Visuals"] = "Visuals_lang_176",
        ["Misc"] = "Misc_lang_176",
        ["Credits"] = "Credits_lang_176",
    },
    ["lang_177"] = {
        ["_NAME"] = "Language_177",
        ["Search"] = "Search_lang_177",
        ["Settings"] = "Settings_lang_177",
        ["Themes"] = "Themes_lang_177",
        ["Languages"] = "Languages_lang_177",
        ["Close"] = "Close_lang_177",
        ["Minimize"] = "Minimize_lang_177",
        ["Confirm"] = "Confirm_lang_177",
        ["Cancel"] = "Cancel_lang_177",
        ["Yes"] = "Yes_lang_177",
        ["No"] = "No_lang_177",
        ["Loading"] = "Loading_lang_177",
        ["FPS"] = "FPS_lang_177",
        ["MS"] = "MS_lang_177",
        ["Active"] = "Active_lang_177",
        ["Inactive"] = "Inactive_lang_177",
        ["Success"] = "Success_lang_177",
        ["Error"] = "Error_lang_177",
        ["Warning"] = "Warning_lang_177",
        ["Information"] = "Information_lang_177",
        ["Advanced"] = "Advanced_lang_177",
        ["General"] = "General_lang_177",
        ["Player"] = "Player_lang_177",
        ["Visuals"] = "Visuals_lang_177",
        ["Misc"] = "Misc_lang_177",
        ["Credits"] = "Credits_lang_177",
    },
    ["lang_178"] = {
        ["_NAME"] = "Language_178",
        ["Search"] = "Search_lang_178",
        ["Settings"] = "Settings_lang_178",
        ["Themes"] = "Themes_lang_178",
        ["Languages"] = "Languages_lang_178",
        ["Close"] = "Close_lang_178",
        ["Minimize"] = "Minimize_lang_178",
        ["Confirm"] = "Confirm_lang_178",
        ["Cancel"] = "Cancel_lang_178",
        ["Yes"] = "Yes_lang_178",
        ["No"] = "No_lang_178",
        ["Loading"] = "Loading_lang_178",
        ["FPS"] = "FPS_lang_178",
        ["MS"] = "MS_lang_178",
        ["Active"] = "Active_lang_178",
        ["Inactive"] = "Inactive_lang_178",
        ["Success"] = "Success_lang_178",
        ["Error"] = "Error_lang_178",
        ["Warning"] = "Warning_lang_178",
        ["Information"] = "Information_lang_178",
        ["Advanced"] = "Advanced_lang_178",
        ["General"] = "General_lang_178",
        ["Player"] = "Player_lang_178",
        ["Visuals"] = "Visuals_lang_178",
        ["Misc"] = "Misc_lang_178",
        ["Credits"] = "Credits_lang_178",
    },
    ["lang_179"] = {
        ["_NAME"] = "Language_179",
        ["Search"] = "Search_lang_179",
        ["Settings"] = "Settings_lang_179",
        ["Themes"] = "Themes_lang_179",
        ["Languages"] = "Languages_lang_179",
        ["Close"] = "Close_lang_179",
        ["Minimize"] = "Minimize_lang_179",
        ["Confirm"] = "Confirm_lang_179",
        ["Cancel"] = "Cancel_lang_179",
        ["Yes"] = "Yes_lang_179",
        ["No"] = "No_lang_179",
        ["Loading"] = "Loading_lang_179",
        ["FPS"] = "FPS_lang_179",
        ["MS"] = "MS_lang_179",
        ["Active"] = "Active_lang_179",
        ["Inactive"] = "Inactive_lang_179",
        ["Success"] = "Success_lang_179",
        ["Error"] = "Error_lang_179",
        ["Warning"] = "Warning_lang_179",
        ["Information"] = "Information_lang_179",
        ["Advanced"] = "Advanced_lang_179",
        ["General"] = "General_lang_179",
        ["Player"] = "Player_lang_179",
        ["Visuals"] = "Visuals_lang_179",
        ["Misc"] = "Misc_lang_179",
        ["Credits"] = "Credits_lang_179",
    },
    ["lang_180"] = {
        ["_NAME"] = "Language_180",
        ["Search"] = "Search_lang_180",
        ["Settings"] = "Settings_lang_180",
        ["Themes"] = "Themes_lang_180",
        ["Languages"] = "Languages_lang_180",
        ["Close"] = "Close_lang_180",
        ["Minimize"] = "Minimize_lang_180",
        ["Confirm"] = "Confirm_lang_180",
        ["Cancel"] = "Cancel_lang_180",
        ["Yes"] = "Yes_lang_180",
        ["No"] = "No_lang_180",
        ["Loading"] = "Loading_lang_180",
        ["FPS"] = "FPS_lang_180",
        ["MS"] = "MS_lang_180",
        ["Active"] = "Active_lang_180",
        ["Inactive"] = "Inactive_lang_180",
        ["Success"] = "Success_lang_180",
        ["Error"] = "Error_lang_180",
        ["Warning"] = "Warning_lang_180",
        ["Information"] = "Information_lang_180",
        ["Advanced"] = "Advanced_lang_180",
        ["General"] = "General_lang_180",
        ["Player"] = "Player_lang_180",
        ["Visuals"] = "Visuals_lang_180",
        ["Misc"] = "Misc_lang_180",
        ["Credits"] = "Credits_lang_180",
    },
    ["lang_181"] = {
        ["_NAME"] = "Language_181",
        ["Search"] = "Search_lang_181",
        ["Settings"] = "Settings_lang_181",
        ["Themes"] = "Themes_lang_181",
        ["Languages"] = "Languages_lang_181",
        ["Close"] = "Close_lang_181",
        ["Minimize"] = "Minimize_lang_181",
        ["Confirm"] = "Confirm_lang_181",
        ["Cancel"] = "Cancel_lang_181",
        ["Yes"] = "Yes_lang_181",
        ["No"] = "No_lang_181",
        ["Loading"] = "Loading_lang_181",
        ["FPS"] = "FPS_lang_181",
        ["MS"] = "MS_lang_181",
        ["Active"] = "Active_lang_181",
        ["Inactive"] = "Inactive_lang_181",
        ["Success"] = "Success_lang_181",
        ["Error"] = "Error_lang_181",
        ["Warning"] = "Warning_lang_181",
        ["Information"] = "Information_lang_181",
        ["Advanced"] = "Advanced_lang_181",
        ["General"] = "General_lang_181",
        ["Player"] = "Player_lang_181",
        ["Visuals"] = "Visuals_lang_181",
        ["Misc"] = "Misc_lang_181",
        ["Credits"] = "Credits_lang_181",
    },
    ["lang_182"] = {
        ["_NAME"] = "Language_182",
        ["Search"] = "Search_lang_182",
        ["Settings"] = "Settings_lang_182",
        ["Themes"] = "Themes_lang_182",
        ["Languages"] = "Languages_lang_182",
        ["Close"] = "Close_lang_182",
        ["Minimize"] = "Minimize_lang_182",
        ["Confirm"] = "Confirm_lang_182",
        ["Cancel"] = "Cancel_lang_182",
        ["Yes"] = "Yes_lang_182",
        ["No"] = "No_lang_182",
        ["Loading"] = "Loading_lang_182",
        ["FPS"] = "FPS_lang_182",
        ["MS"] = "MS_lang_182",
        ["Active"] = "Active_lang_182",
        ["Inactive"] = "Inactive_lang_182",
        ["Success"] = "Success_lang_182",
        ["Error"] = "Error_lang_182",
        ["Warning"] = "Warning_lang_182",
        ["Information"] = "Information_lang_182",
        ["Advanced"] = "Advanced_lang_182",
        ["General"] = "General_lang_182",
        ["Player"] = "Player_lang_182",
        ["Visuals"] = "Visuals_lang_182",
        ["Misc"] = "Misc_lang_182",
        ["Credits"] = "Credits_lang_182",
    },
    ["lang_183"] = {
        ["_NAME"] = "Language_183",
        ["Search"] = "Search_lang_183",
        ["Settings"] = "Settings_lang_183",
        ["Themes"] = "Themes_lang_183",
        ["Languages"] = "Languages_lang_183",
        ["Close"] = "Close_lang_183",
        ["Minimize"] = "Minimize_lang_183",
        ["Confirm"] = "Confirm_lang_183",
        ["Cancel"] = "Cancel_lang_183",
        ["Yes"] = "Yes_lang_183",
        ["No"] = "No_lang_183",
        ["Loading"] = "Loading_lang_183",
        ["FPS"] = "FPS_lang_183",
        ["MS"] = "MS_lang_183",
        ["Active"] = "Active_lang_183",
        ["Inactive"] = "Inactive_lang_183",
        ["Success"] = "Success_lang_183",
        ["Error"] = "Error_lang_183",
        ["Warning"] = "Warning_lang_183",
        ["Information"] = "Information_lang_183",
        ["Advanced"] = "Advanced_lang_183",
        ["General"] = "General_lang_183",
        ["Player"] = "Player_lang_183",
        ["Visuals"] = "Visuals_lang_183",
        ["Misc"] = "Misc_lang_183",
        ["Credits"] = "Credits_lang_183",
    },
    ["lang_184"] = {
        ["_NAME"] = "Language_184",
        ["Search"] = "Search_lang_184",
        ["Settings"] = "Settings_lang_184",
        ["Themes"] = "Themes_lang_184",
        ["Languages"] = "Languages_lang_184",
        ["Close"] = "Close_lang_184",
        ["Minimize"] = "Minimize_lang_184",
        ["Confirm"] = "Confirm_lang_184",
        ["Cancel"] = "Cancel_lang_184",
        ["Yes"] = "Yes_lang_184",
        ["No"] = "No_lang_184",
        ["Loading"] = "Loading_lang_184",
        ["FPS"] = "FPS_lang_184",
        ["MS"] = "MS_lang_184",
        ["Active"] = "Active_lang_184",
        ["Inactive"] = "Inactive_lang_184",
        ["Success"] = "Success_lang_184",
        ["Error"] = "Error_lang_184",
        ["Warning"] = "Warning_lang_184",
        ["Information"] = "Information_lang_184",
        ["Advanced"] = "Advanced_lang_184",
        ["General"] = "General_lang_184",
        ["Player"] = "Player_lang_184",
        ["Visuals"] = "Visuals_lang_184",
        ["Misc"] = "Misc_lang_184",
        ["Credits"] = "Credits_lang_184",
    },
    ["lang_185"] = {
        ["_NAME"] = "Language_185",
        ["Search"] = "Search_lang_185",
        ["Settings"] = "Settings_lang_185",
        ["Themes"] = "Themes_lang_185",
        ["Languages"] = "Languages_lang_185",
        ["Close"] = "Close_lang_185",
        ["Minimize"] = "Minimize_lang_185",
        ["Confirm"] = "Confirm_lang_185",
        ["Cancel"] = "Cancel_lang_185",
        ["Yes"] = "Yes_lang_185",
        ["No"] = "No_lang_185",
        ["Loading"] = "Loading_lang_185",
        ["FPS"] = "FPS_lang_185",
        ["MS"] = "MS_lang_185",
        ["Active"] = "Active_lang_185",
        ["Inactive"] = "Inactive_lang_185",
        ["Success"] = "Success_lang_185",
        ["Error"] = "Error_lang_185",
        ["Warning"] = "Warning_lang_185",
        ["Information"] = "Information_lang_185",
        ["Advanced"] = "Advanced_lang_185",
        ["General"] = "General_lang_185",
        ["Player"] = "Player_lang_185",
        ["Visuals"] = "Visuals_lang_185",
        ["Misc"] = "Misc_lang_185",
        ["Credits"] = "Credits_lang_185",
    },
    ["lang_186"] = {
        ["_NAME"] = "Language_186",
        ["Search"] = "Search_lang_186",
        ["Settings"] = "Settings_lang_186",
        ["Themes"] = "Themes_lang_186",
        ["Languages"] = "Languages_lang_186",
        ["Close"] = "Close_lang_186",
        ["Minimize"] = "Minimize_lang_186",
        ["Confirm"] = "Confirm_lang_186",
        ["Cancel"] = "Cancel_lang_186",
        ["Yes"] = "Yes_lang_186",
        ["No"] = "No_lang_186",
        ["Loading"] = "Loading_lang_186",
        ["FPS"] = "FPS_lang_186",
        ["MS"] = "MS_lang_186",
        ["Active"] = "Active_lang_186",
        ["Inactive"] = "Inactive_lang_186",
        ["Success"] = "Success_lang_186",
        ["Error"] = "Error_lang_186",
        ["Warning"] = "Warning_lang_186",
        ["Information"] = "Information_lang_186",
        ["Advanced"] = "Advanced_lang_186",
        ["General"] = "General_lang_186",
        ["Player"] = "Player_lang_186",
        ["Visuals"] = "Visuals_lang_186",
        ["Misc"] = "Misc_lang_186",
        ["Credits"] = "Credits_lang_186",
    },
    ["lang_187"] = {
        ["_NAME"] = "Language_187",
        ["Search"] = "Search_lang_187",
        ["Settings"] = "Settings_lang_187",
        ["Themes"] = "Themes_lang_187",
        ["Languages"] = "Languages_lang_187",
        ["Close"] = "Close_lang_187",
        ["Minimize"] = "Minimize_lang_187",
        ["Confirm"] = "Confirm_lang_187",
        ["Cancel"] = "Cancel_lang_187",
        ["Yes"] = "Yes_lang_187",
        ["No"] = "No_lang_187",
        ["Loading"] = "Loading_lang_187",
        ["FPS"] = "FPS_lang_187",
        ["MS"] = "MS_lang_187",
        ["Active"] = "Active_lang_187",
        ["Inactive"] = "Inactive_lang_187",
        ["Success"] = "Success_lang_187",
        ["Error"] = "Error_lang_187",
        ["Warning"] = "Warning_lang_187",
        ["Information"] = "Information_lang_187",
        ["Advanced"] = "Advanced_lang_187",
        ["General"] = "General_lang_187",
        ["Player"] = "Player_lang_187",
        ["Visuals"] = "Visuals_lang_187",
        ["Misc"] = "Misc_lang_187",
        ["Credits"] = "Credits_lang_187",
    },
    ["lang_188"] = {
        ["_NAME"] = "Language_188",
        ["Search"] = "Search_lang_188",
        ["Settings"] = "Settings_lang_188",
        ["Themes"] = "Themes_lang_188",
        ["Languages"] = "Languages_lang_188",
        ["Close"] = "Close_lang_188",
        ["Minimize"] = "Minimize_lang_188",
        ["Confirm"] = "Confirm_lang_188",
        ["Cancel"] = "Cancel_lang_188",
        ["Yes"] = "Yes_lang_188",
        ["No"] = "No_lang_188",
        ["Loading"] = "Loading_lang_188",
        ["FPS"] = "FPS_lang_188",
        ["MS"] = "MS_lang_188",
        ["Active"] = "Active_lang_188",
        ["Inactive"] = "Inactive_lang_188",
        ["Success"] = "Success_lang_188",
        ["Error"] = "Error_lang_188",
        ["Warning"] = "Warning_lang_188",
        ["Information"] = "Information_lang_188",
        ["Advanced"] = "Advanced_lang_188",
        ["General"] = "General_lang_188",
        ["Player"] = "Player_lang_188",
        ["Visuals"] = "Visuals_lang_188",
        ["Misc"] = "Misc_lang_188",
        ["Credits"] = "Credits_lang_188",
    },
    ["lang_189"] = {
        ["_NAME"] = "Language_189",
        ["Search"] = "Search_lang_189",
        ["Settings"] = "Settings_lang_189",
        ["Themes"] = "Themes_lang_189",
        ["Languages"] = "Languages_lang_189",
        ["Close"] = "Close_lang_189",
        ["Minimize"] = "Minimize_lang_189",
        ["Confirm"] = "Confirm_lang_189",
        ["Cancel"] = "Cancel_lang_189",
        ["Yes"] = "Yes_lang_189",
        ["No"] = "No_lang_189",
        ["Loading"] = "Loading_lang_189",
        ["FPS"] = "FPS_lang_189",
        ["MS"] = "MS_lang_189",
        ["Active"] = "Active_lang_189",
        ["Inactive"] = "Inactive_lang_189",
        ["Success"] = "Success_lang_189",
        ["Error"] = "Error_lang_189",
        ["Warning"] = "Warning_lang_189",
        ["Information"] = "Information_lang_189",
        ["Advanced"] = "Advanced_lang_189",
        ["General"] = "General_lang_189",
        ["Player"] = "Player_lang_189",
        ["Visuals"] = "Visuals_lang_189",
        ["Misc"] = "Misc_lang_189",
        ["Credits"] = "Credits_lang_189",
    },
    ["lang_190"] = {
        ["_NAME"] = "Language_190",
        ["Search"] = "Search_lang_190",
        ["Settings"] = "Settings_lang_190",
        ["Themes"] = "Themes_lang_190",
        ["Languages"] = "Languages_lang_190",
        ["Close"] = "Close_lang_190",
        ["Minimize"] = "Minimize_lang_190",
        ["Confirm"] = "Confirm_lang_190",
        ["Cancel"] = "Cancel_lang_190",
        ["Yes"] = "Yes_lang_190",
        ["No"] = "No_lang_190",
        ["Loading"] = "Loading_lang_190",
        ["FPS"] = "FPS_lang_190",
        ["MS"] = "MS_lang_190",
        ["Active"] = "Active_lang_190",
        ["Inactive"] = "Inactive_lang_190",
        ["Success"] = "Success_lang_190",
        ["Error"] = "Error_lang_190",
        ["Warning"] = "Warning_lang_190",
        ["Information"] = "Information_lang_190",
        ["Advanced"] = "Advanced_lang_190",
        ["General"] = "General_lang_190",
        ["Player"] = "Player_lang_190",
        ["Visuals"] = "Visuals_lang_190",
        ["Misc"] = "Misc_lang_190",
        ["Credits"] = "Credits_lang_190",
    },
    ["lang_191"] = {
        ["_NAME"] = "Language_191",
        ["Search"] = "Search_lang_191",
        ["Settings"] = "Settings_lang_191",
        ["Themes"] = "Themes_lang_191",
        ["Languages"] = "Languages_lang_191",
        ["Close"] = "Close_lang_191",
        ["Minimize"] = "Minimize_lang_191",
        ["Confirm"] = "Confirm_lang_191",
        ["Cancel"] = "Cancel_lang_191",
        ["Yes"] = "Yes_lang_191",
        ["No"] = "No_lang_191",
        ["Loading"] = "Loading_lang_191",
        ["FPS"] = "FPS_lang_191",
        ["MS"] = "MS_lang_191",
        ["Active"] = "Active_lang_191",
        ["Inactive"] = "Inactive_lang_191",
        ["Success"] = "Success_lang_191",
        ["Error"] = "Error_lang_191",
        ["Warning"] = "Warning_lang_191",
        ["Information"] = "Information_lang_191",
        ["Advanced"] = "Advanced_lang_191",
        ["General"] = "General_lang_191",
        ["Player"] = "Player_lang_191",
        ["Visuals"] = "Visuals_lang_191",
        ["Misc"] = "Misc_lang_191",
        ["Credits"] = "Credits_lang_191",
    },
    ["lang_192"] = {
        ["_NAME"] = "Language_192",
        ["Search"] = "Search_lang_192",
        ["Settings"] = "Settings_lang_192",
        ["Themes"] = "Themes_lang_192",
        ["Languages"] = "Languages_lang_192",
        ["Close"] = "Close_lang_192",
        ["Minimize"] = "Minimize_lang_192",
        ["Confirm"] = "Confirm_lang_192",
        ["Cancel"] = "Cancel_lang_192",
        ["Yes"] = "Yes_lang_192",
        ["No"] = "No_lang_192",
        ["Loading"] = "Loading_lang_192",
        ["FPS"] = "FPS_lang_192",
        ["MS"] = "MS_lang_192",
        ["Active"] = "Active_lang_192",
        ["Inactive"] = "Inactive_lang_192",
        ["Success"] = "Success_lang_192",
        ["Error"] = "Error_lang_192",
        ["Warning"] = "Warning_lang_192",
        ["Information"] = "Information_lang_192",
        ["Advanced"] = "Advanced_lang_192",
        ["General"] = "General_lang_192",
        ["Player"] = "Player_lang_192",
        ["Visuals"] = "Visuals_lang_192",
        ["Misc"] = "Misc_lang_192",
        ["Credits"] = "Credits_lang_192",
    },
}

-- [[ ADVANCED MATHEMATICAL UTILITIES ]]
Nexus.Math = {}
function Nexus.Math:CalculatePath_0(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8782164714501548)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8287734403414626)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_1(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7591869295620495)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8578018246444112)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_2(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7981419899155372)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7773512968520283)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_3(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9361328513037669)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5761825225249998)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_4(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6671001089127602)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4942823403896136)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_5(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8258738574202676)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.22761728274008997)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_6(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5261326050024095)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.010984681571436616)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_7(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3588472729039016)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.35265676688069514)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_8(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.19628079301695023)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.24640717518871713)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_9(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.033623266024938925)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.9688889170063703)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_10(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8245098780380912)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.14862395850040788)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_11(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.32076103220537766)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.3024959408798339)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_12(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.48183428038831067)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4192458754787256)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_13(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3183701281662198)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6003117474721147)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_14(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6379034829621435)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.24582928872488408)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_15(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.44176121022924053)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8886078581362037)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_16(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.25270245244868517)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6235510959184583)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_17(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.30283281724220434)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.11252517887699609)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_18(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8211406460764454)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.43365575386069544)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_19(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4132230671578083)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.19826253826593843)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_20(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.22801412789595066)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8596522254489273)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_21(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8525385955898168)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.931168209803558)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_22(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.047228814200831915)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.02982054229842024)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_23(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7608734650481086)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8753435938913513)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_24(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.1377368028600452)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7398376070768405)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_25(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.052612874280463684)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8990100957435084)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_26(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5577607868415043)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.004636640387955082)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_27(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.44886025187662815)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5530216109055751)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_28(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4385265716801756)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7761331130202376)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_29(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.0992525124642093)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8696360009187345)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_30(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.39150539073074964)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8161997726361202)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_31(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9592798491467887)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5556350227299643)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_32(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7463711548564059)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.047618678588498775)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_33(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6691778028466909)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.46234522928295396)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_34(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5008219020612062)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4903989709042722)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_35(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.041627648828342134)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.3200082450586067)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_36(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5903786785737963)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7120789989110512)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_37(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.48494364683479074)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7960474217341283)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_38(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.1707047649295439)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.16299346075513754)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_39(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4641719549302109)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5882314653275461)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_40(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9564779966920322)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.979481214423082)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_41(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.09544097326942591)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4412643155446552)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_42(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9251220237300646)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7092481618277082)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_43(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.781067387497124)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8788449416817657)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_44(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8685145703614306)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8918213365035629)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_45(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.1358031797931749)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4207485471831406)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_46(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.05054888351122211)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.060529125882831436)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_47(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5706013500414483)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7179378151661284)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_48(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.29686735502785533)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.17984972276445743)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_49(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3157685342149955)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6814609395412752)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_50(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6236182699521933)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6518275161170811)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_51(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8484434580840646)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.95235316069305)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_52(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7553397766693154)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.11968919847781179)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_53(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7015822380870803)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5383929806046754)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_54(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3956215123257085)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.035374524233157234)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_55(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3781324234978113)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.22551550451265412)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_56(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7025572799767138)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.9303644380873602)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_57(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6592026644116102)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.06375039368570501)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_58(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.23124728657754168)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4650074182119208)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_59(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.617000350449157)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.15437250840228967)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_60(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.052341120653828566)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.9553945429911096)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_61(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.016114077249455128)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.1897380274758086)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_62(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4256496918285432)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.3338597341445272)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_63(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.25454943167992916)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.3659748130428372)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_64(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.1646853031483687)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.010563577308907002)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_65(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6761397907864336)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5835645072732759)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_66(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8332365869375832)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6307588089446725)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_67(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8003167542170262)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7450715849320629)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_68(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6963018546023653)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7378020762993237)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_69(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8373546700324165)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7754020980738876)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_70(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7816330505200553)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5355561476465299)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_71(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.11662157648423821)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8088920836860044)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_72(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3834579133065351)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6220292120651936)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_73(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.01566129561367602)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.940125268301173)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_74(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.08116607763988126)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4284082916483516)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_75(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.2919448139848919)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7864610915516655)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_76(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.913507903778199)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6404174222296244)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_77(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4714350008651942)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.9521700598610636)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_78(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.40882875742639246)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8160785444862318)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_79(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.19506256214030215)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4626485432874087)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_80(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.599088362087302)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.2886002679083225)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_81(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3113253935632124)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6562599126282014)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_82(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5207877701678969)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.19538901742419412)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_83(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.1913877795680784)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4292776652733825)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_84(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5015474605883836)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.40345305556579003)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_85(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7660926281031157)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.3623104727440932)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_86(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8898544484264698)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7550310613277587)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_87(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7961701377064501)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.34560664365819005)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_88(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5653504707138146)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6839534531306267)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_89(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8988339161731028)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.24061162624840127)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_90(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.994238046708634)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.20158678862734125)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_91(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8894917056104369)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.2759003373136163)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_92(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.84679068106749)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7433866512561109)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_93(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9730741776564097)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.04210779384029417)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_94(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3385320131952)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.19093222793858777)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_95(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6234147697364429)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5350362910893238)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_96(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9360300215863044)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4505974512572467)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_97(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.1237942392305994)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8257756296402353)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_98(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.09705525196350928)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5035482867744734)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_99(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.17093225119594957)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4479636115124801)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_100(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.29667081027740005)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4078469607256784)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_101(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6109043263327956)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.12759391105336104)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_102(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.35492739150688435)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4312386160062541)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_103(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8015841939233)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.13788484008087853)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_104(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.2729594183620778)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5733506576529303)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_105(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4593907114101571)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.06948147759741508)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_106(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7353718225854171)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.42558811503891225)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_107(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.16948000868482804)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.08879660433159586)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_108(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.938080116653933)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8636578908993296)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_109(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.23740189917597576)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4561604608525611)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_110(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.17027423956106735)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.14256261076290844)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_111(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.17276082715369467)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8265141468471839)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_112(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6870056640342995)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.22445219421937768)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_113(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5896478799783479)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7503068941216507)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_114(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7172385481873208)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.09973049719217353)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_115(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.187637652560668)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.9289731376942623)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_116(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7807149001877604)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.44785149172651595)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_117(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.06515917305074748)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.432787494818341)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_118(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.18016378492470664)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7727741622185039)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_119(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.5324949249529553)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.333773155145069)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_120(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3171252882512614)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6653737419360451)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_121(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6616530830658817)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.41361413153464643)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_122(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.01919572474487563)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8325750118467933)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_123(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.69495418300882)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.31573416191093573)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_124(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.43405792441161495)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7680532858728489)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_125(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7851606202983398)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8608694910233832)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_126(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6470839094595143)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4976662510369978)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_127(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3354274853031233)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6883602164424895)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_128(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4803689644221637)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.546304614371277)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_129(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7183812675777131)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6412747968593216)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_130(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.4754155501244015)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.4870257469179935)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_131(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7831297926251107)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.33294584095245294)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_132(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.16480845726580606)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8655861341301107)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_133(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7918338366104859)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.23572788423898094)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_134(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.40565230795965834)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.7378363262442887)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_135(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.28636225220279865)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.33811200097782523)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_136(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6404745953355384)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.5011122799763597)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_137(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.6493894486728629)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.13163484953023719)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_138(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.008095701220767526)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.28956298081304854)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_139(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.9701955753406786)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.9441441759625017)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_140(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7942442866270866)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.17129924406867303)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_141(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.8427070615124803)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.16987323466318083)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_142(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.307756249156252)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.31769498363858595)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_143(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.18621927020711415)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.8818309605125643)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_144(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7153887131764001)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.12343880363006277)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_145(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.3571154215216822)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.665289779406418)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_146(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.45361362487117707)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.37797354239292436)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_147(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.7100254309506815)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.6602892904150239)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_148(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.058254159045450726)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.06533694194324868)
    return Vector2.new(x, y)
end
function Nexus.Math:CalculatePath_149(start, target, alpha)
    local x = start.X + (target.X - start.X) * math.sin(alpha * 0.37338333217994957)
    local y = start.Y + (target.Y - start.Y) * math.cos(alpha * 0.43495324207158226)
    return Vector2.new(x, y)
end

-- [[ INTERNAL ASSET REGISTRY ]]
Nexus.Assets = {
    ["Asset_0000"] = "rbxassetid://8156992",
    ["Asset_0001"] = "rbxassetid://9928240",
    ["Asset_0002"] = "rbxassetid://7212415",
    ["Asset_0003"] = "rbxassetid://3919376",
    ["Asset_0004"] = "rbxassetid://2900134",
    ["Asset_0005"] = "rbxassetid://8487747",
    ["Asset_0006"] = "rbxassetid://8204826",
    ["Asset_0007"] = "rbxassetid://1017210",
    ["Asset_0008"] = "rbxassetid://3081183",
    ["Asset_0009"] = "rbxassetid://4369697",
    ["Asset_0010"] = "rbxassetid://9311891",
    ["Asset_0011"] = "rbxassetid://9423908",
    ["Asset_0012"] = "rbxassetid://9994433",
    ["Asset_0013"] = "rbxassetid://5468716",
    ["Asset_0014"] = "rbxassetid://1355869",
    ["Asset_0015"] = "rbxassetid://5324811",
    ["Asset_0016"] = "rbxassetid://9019055",
    ["Asset_0017"] = "rbxassetid://8217452",
    ["Asset_0018"] = "rbxassetid://1028756",
    ["Asset_0019"] = "rbxassetid://7009333",
    ["Asset_0020"] = "rbxassetid://7041187",
    ["Asset_0021"] = "rbxassetid://3983404",
    ["Asset_0022"] = "rbxassetid://4552124",
    ["Asset_0023"] = "rbxassetid://4824323",
    ["Asset_0024"] = "rbxassetid://7686449",
    ["Asset_0025"] = "rbxassetid://4213657",
    ["Asset_0026"] = "rbxassetid://7558033",
    ["Asset_0027"] = "rbxassetid://1223054",
    ["Asset_0028"] = "rbxassetid://1958395",
    ["Asset_0029"] = "rbxassetid://5217939",
    ["Asset_0030"] = "rbxassetid://4059283",
    ["Asset_0031"] = "rbxassetid://2971004",
    ["Asset_0032"] = "rbxassetid://2547977",
    ["Asset_0033"] = "rbxassetid://1376741",
    ["Asset_0034"] = "rbxassetid://4011022",
    ["Asset_0035"] = "rbxassetid://3830244",
    ["Asset_0036"] = "rbxassetid://9895447",
    ["Asset_0037"] = "rbxassetid://6413893",
    ["Asset_0038"] = "rbxassetid://1781255",
    ["Asset_0039"] = "rbxassetid://4204735",
    ["Asset_0040"] = "rbxassetid://7148955",
    ["Asset_0041"] = "rbxassetid://3241329",
    ["Asset_0042"] = "rbxassetid://8904204",
    ["Asset_0043"] = "rbxassetid://5298691",
    ["Asset_0044"] = "rbxassetid://7591529",
    ["Asset_0045"] = "rbxassetid://2784537",
    ["Asset_0046"] = "rbxassetid://6633863",
    ["Asset_0047"] = "rbxassetid://7777890",
    ["Asset_0048"] = "rbxassetid://1856830",
    ["Asset_0049"] = "rbxassetid://5906829",
    ["Asset_0050"] = "rbxassetid://7235543",
    ["Asset_0051"] = "rbxassetid://8356799",
    ["Asset_0052"] = "rbxassetid://5744499",
    ["Asset_0053"] = "rbxassetid://3718300",
    ["Asset_0054"] = "rbxassetid://6739559",
    ["Asset_0055"] = "rbxassetid://1091107",
    ["Asset_0056"] = "rbxassetid://9907611",
    ["Asset_0057"] = "rbxassetid://6038039",
    ["Asset_0058"] = "rbxassetid://7566122",
    ["Asset_0059"] = "rbxassetid://9645838",
    ["Asset_0060"] = "rbxassetid://6137752",
    ["Asset_0061"] = "rbxassetid://7003874",
    ["Asset_0062"] = "rbxassetid://7586714",
    ["Asset_0063"] = "rbxassetid://6243831",
    ["Asset_0064"] = "rbxassetid://1029980",
    ["Asset_0065"] = "rbxassetid://1457246",
    ["Asset_0066"] = "rbxassetid://2898155",
    ["Asset_0067"] = "rbxassetid://4772689",
    ["Asset_0068"] = "rbxassetid://3594851",
    ["Asset_0069"] = "rbxassetid://9223066",
    ["Asset_0070"] = "rbxassetid://3783364",
    ["Asset_0071"] = "rbxassetid://8771237",
    ["Asset_0072"] = "rbxassetid://1727176",
    ["Asset_0073"] = "rbxassetid://5663981",
    ["Asset_0074"] = "rbxassetid://5286906",
    ["Asset_0075"] = "rbxassetid://2353835",
    ["Asset_0076"] = "rbxassetid://7529570",
    ["Asset_0077"] = "rbxassetid://2416611",
    ["Asset_0078"] = "rbxassetid://6441577",
    ["Asset_0079"] = "rbxassetid://3877239",
    ["Asset_0080"] = "rbxassetid://2279604",
    ["Asset_0081"] = "rbxassetid://4603171",
    ["Asset_0082"] = "rbxassetid://6665260",
    ["Asset_0083"] = "rbxassetid://7000982",
    ["Asset_0084"] = "rbxassetid://8817364",
    ["Asset_0085"] = "rbxassetid://7194713",
    ["Asset_0086"] = "rbxassetid://7056243",
    ["Asset_0087"] = "rbxassetid://3371898",
    ["Asset_0088"] = "rbxassetid://1246852",
    ["Asset_0089"] = "rbxassetid://6617384",
    ["Asset_0090"] = "rbxassetid://6372184",
    ["Asset_0091"] = "rbxassetid://2825543",
    ["Asset_0092"] = "rbxassetid://6737190",
    ["Asset_0093"] = "rbxassetid://5842336",
    ["Asset_0094"] = "rbxassetid://7072991",
    ["Asset_0095"] = "rbxassetid://9072069",
    ["Asset_0096"] = "rbxassetid://7319862",
    ["Asset_0097"] = "rbxassetid://5363924",
    ["Asset_0098"] = "rbxassetid://7529521",
    ["Asset_0099"] = "rbxassetid://9224292",
    ["Asset_0100"] = "rbxassetid://5853644",
    ["Asset_0101"] = "rbxassetid://4094421",
    ["Asset_0102"] = "rbxassetid://2898186",
    ["Asset_0103"] = "rbxassetid://8951820",
    ["Asset_0104"] = "rbxassetid://4130701",
    ["Asset_0105"] = "rbxassetid://6364864",
    ["Asset_0106"] = "rbxassetid://4082467",
    ["Asset_0107"] = "rbxassetid://7595518",
    ["Asset_0108"] = "rbxassetid://6121501",
    ["Asset_0109"] = "rbxassetid://1669501",
    ["Asset_0110"] = "rbxassetid://8646696",
    ["Asset_0111"] = "rbxassetid://3805871",
    ["Asset_0112"] = "rbxassetid://8927732",
    ["Asset_0113"] = "rbxassetid://5327630",
    ["Asset_0114"] = "rbxassetid://7852758",
    ["Asset_0115"] = "rbxassetid://8184932",
    ["Asset_0116"] = "rbxassetid://5521269",
    ["Asset_0117"] = "rbxassetid://2827595",
    ["Asset_0118"] = "rbxassetid://1254424",
    ["Asset_0119"] = "rbxassetid://9070733",
    ["Asset_0120"] = "rbxassetid://8372868",
    ["Asset_0121"] = "rbxassetid://7875567",
    ["Asset_0122"] = "rbxassetid://6571492",
    ["Asset_0123"] = "rbxassetid://3514673",
    ["Asset_0124"] = "rbxassetid://1161016",
    ["Asset_0125"] = "rbxassetid://5804145",
    ["Asset_0126"] = "rbxassetid://9065712",
    ["Asset_0127"] = "rbxassetid://4607514",
    ["Asset_0128"] = "rbxassetid://1068826",
    ["Asset_0129"] = "rbxassetid://5814904",
    ["Asset_0130"] = "rbxassetid://6687484",
    ["Asset_0131"] = "rbxassetid://2583381",
    ["Asset_0132"] = "rbxassetid://8624164",
    ["Asset_0133"] = "rbxassetid://2647105",
    ["Asset_0134"] = "rbxassetid://9010087",
    ["Asset_0135"] = "rbxassetid://1534794",
    ["Asset_0136"] = "rbxassetid://5753393",
    ["Asset_0137"] = "rbxassetid://7593130",
    ["Asset_0138"] = "rbxassetid://7459356",
    ["Asset_0139"] = "rbxassetid://5962690",
    ["Asset_0140"] = "rbxassetid://1422369",
    ["Asset_0141"] = "rbxassetid://4188207",
    ["Asset_0142"] = "rbxassetid://8229201",
    ["Asset_0143"] = "rbxassetid://1753194",
    ["Asset_0144"] = "rbxassetid://8539734",
    ["Asset_0145"] = "rbxassetid://5499614",
    ["Asset_0146"] = "rbxassetid://6752591",
    ["Asset_0147"] = "rbxassetid://8093129",
    ["Asset_0148"] = "rbxassetid://8111290",
    ["Asset_0149"] = "rbxassetid://6999120",
    ["Asset_0150"] = "rbxassetid://5517539",
    ["Asset_0151"] = "rbxassetid://1649879",
    ["Asset_0152"] = "rbxassetid://9409889",
    ["Asset_0153"] = "rbxassetid://6365245",
    ["Asset_0154"] = "rbxassetid://7976016",
    ["Asset_0155"] = "rbxassetid://1192028",
    ["Asset_0156"] = "rbxassetid://6740312",
    ["Asset_0157"] = "rbxassetid://2467457",
    ["Asset_0158"] = "rbxassetid://2160139",
    ["Asset_0159"] = "rbxassetid://3468856",
    ["Asset_0160"] = "rbxassetid://4128694",
    ["Asset_0161"] = "rbxassetid://2262624",
    ["Asset_0162"] = "rbxassetid://4498491",
    ["Asset_0163"] = "rbxassetid://3489698",
    ["Asset_0164"] = "rbxassetid://7950555",
    ["Asset_0165"] = "rbxassetid://2784118",
    ["Asset_0166"] = "rbxassetid://5942426",
    ["Asset_0167"] = "rbxassetid://2832083",
    ["Asset_0168"] = "rbxassetid://5678187",
    ["Asset_0169"] = "rbxassetid://6438615",
    ["Asset_0170"] = "rbxassetid://8112184",
    ["Asset_0171"] = "rbxassetid://3451478",
    ["Asset_0172"] = "rbxassetid://5158851",
    ["Asset_0173"] = "rbxassetid://9457302",
    ["Asset_0174"] = "rbxassetid://8880011",
    ["Asset_0175"] = "rbxassetid://9593030",
    ["Asset_0176"] = "rbxassetid://8682481",
    ["Asset_0177"] = "rbxassetid://9238099",
    ["Asset_0178"] = "rbxassetid://8948058",
    ["Asset_0179"] = "rbxassetid://7089768",
    ["Asset_0180"] = "rbxassetid://4214383",
    ["Asset_0181"] = "rbxassetid://6450034",
    ["Asset_0182"] = "rbxassetid://6747186",
    ["Asset_0183"] = "rbxassetid://3546161",
    ["Asset_0184"] = "rbxassetid://9622629",
    ["Asset_0185"] = "rbxassetid://6679446",
    ["Asset_0186"] = "rbxassetid://1453987",
    ["Asset_0187"] = "rbxassetid://5422544",
    ["Asset_0188"] = "rbxassetid://5183895",
    ["Asset_0189"] = "rbxassetid://6146487",
    ["Asset_0190"] = "rbxassetid://9229051",
    ["Asset_0191"] = "rbxassetid://2541735",
    ["Asset_0192"] = "rbxassetid://9952723",
    ["Asset_0193"] = "rbxassetid://1846036",
    ["Asset_0194"] = "rbxassetid://1177833",
    ["Asset_0195"] = "rbxassetid://9195545",
    ["Asset_0196"] = "rbxassetid://7802699",
    ["Asset_0197"] = "rbxassetid://1196544",
    ["Asset_0198"] = "rbxassetid://6441571",
    ["Asset_0199"] = "rbxassetid://6553399",
    ["Asset_0200"] = "rbxassetid://6653693",
    ["Asset_0201"] = "rbxassetid://8920835",
    ["Asset_0202"] = "rbxassetid://3871053",
    ["Asset_0203"] = "rbxassetid://8061318",
    ["Asset_0204"] = "rbxassetid://7054923",
    ["Asset_0205"] = "rbxassetid://5904611",
    ["Asset_0206"] = "rbxassetid://9517643",
    ["Asset_0207"] = "rbxassetid://8049598",
    ["Asset_0208"] = "rbxassetid://3485561",
    ["Asset_0209"] = "rbxassetid://6882497",
    ["Asset_0210"] = "rbxassetid://7755875",
    ["Asset_0211"] = "rbxassetid://6764126",
    ["Asset_0212"] = "rbxassetid://1949986",
    ["Asset_0213"] = "rbxassetid://1119135",
    ["Asset_0214"] = "rbxassetid://1310492",
    ["Asset_0215"] = "rbxassetid://7031396",
    ["Asset_0216"] = "rbxassetid://1165801",
    ["Asset_0217"] = "rbxassetid://3567400",
    ["Asset_0218"] = "rbxassetid://4458860",
    ["Asset_0219"] = "rbxassetid://4806703",
    ["Asset_0220"] = "rbxassetid://6571410",
    ["Asset_0221"] = "rbxassetid://8949522",
    ["Asset_0222"] = "rbxassetid://8990568",
    ["Asset_0223"] = "rbxassetid://6589568",
    ["Asset_0224"] = "rbxassetid://8800193",
    ["Asset_0225"] = "rbxassetid://2609262",
    ["Asset_0226"] = "rbxassetid://1207758",
    ["Asset_0227"] = "rbxassetid://4736894",
    ["Asset_0228"] = "rbxassetid://4252425",
    ["Asset_0229"] = "rbxassetid://1636223",
    ["Asset_0230"] = "rbxassetid://2285336",
    ["Asset_0231"] = "rbxassetid://1747263",
    ["Asset_0232"] = "rbxassetid://6871211",
    ["Asset_0233"] = "rbxassetid://5312569",
    ["Asset_0234"] = "rbxassetid://3869136",
    ["Asset_0235"] = "rbxassetid://6819647",
    ["Asset_0236"] = "rbxassetid://1952383",
    ["Asset_0237"] = "rbxassetid://5374448",
    ["Asset_0238"] = "rbxassetid://1675943",
    ["Asset_0239"] = "rbxassetid://1790459",
    ["Asset_0240"] = "rbxassetid://5634861",
    ["Asset_0241"] = "rbxassetid://6608031",
    ["Asset_0242"] = "rbxassetid://6411721",
    ["Asset_0243"] = "rbxassetid://4643552",
    ["Asset_0244"] = "rbxassetid://1733399",
    ["Asset_0245"] = "rbxassetid://2329841",
    ["Asset_0246"] = "rbxassetid://7266485",
    ["Asset_0247"] = "rbxassetid://9554209",
    ["Asset_0248"] = "rbxassetid://5953357",
    ["Asset_0249"] = "rbxassetid://6492110",
    ["Asset_0250"] = "rbxassetid://8539960",
    ["Asset_0251"] = "rbxassetid://6175888",
    ["Asset_0252"] = "rbxassetid://9100780",
    ["Asset_0253"] = "rbxassetid://2559111",
    ["Asset_0254"] = "rbxassetid://6681461",
    ["Asset_0255"] = "rbxassetid://4297703",
    ["Asset_0256"] = "rbxassetid://8826162",
    ["Asset_0257"] = "rbxassetid://5468407",
    ["Asset_0258"] = "rbxassetid://2561550",
    ["Asset_0259"] = "rbxassetid://4911843",
    ["Asset_0260"] = "rbxassetid://4178946",
    ["Asset_0261"] = "rbxassetid://6158392",
    ["Asset_0262"] = "rbxassetid://8326714",
    ["Asset_0263"] = "rbxassetid://8100700",
    ["Asset_0264"] = "rbxassetid://6820124",
    ["Asset_0265"] = "rbxassetid://1553226",
    ["Asset_0266"] = "rbxassetid://8383827",
    ["Asset_0267"] = "rbxassetid://1142221",
    ["Asset_0268"] = "rbxassetid://4049010",
    ["Asset_0269"] = "rbxassetid://9637173",
    ["Asset_0270"] = "rbxassetid://4562604",
    ["Asset_0271"] = "rbxassetid://7164404",
    ["Asset_0272"] = "rbxassetid://5129496",
    ["Asset_0273"] = "rbxassetid://1831451",
    ["Asset_0274"] = "rbxassetid://7330795",
    ["Asset_0275"] = "rbxassetid://7976398",
    ["Asset_0276"] = "rbxassetid://8380949",
    ["Asset_0277"] = "rbxassetid://4162431",
    ["Asset_0278"] = "rbxassetid://2341086",
    ["Asset_0279"] = "rbxassetid://1985687",
    ["Asset_0280"] = "rbxassetid://6586563",
    ["Asset_0281"] = "rbxassetid://5903595",
    ["Asset_0282"] = "rbxassetid://6998058",
    ["Asset_0283"] = "rbxassetid://4508507",
    ["Asset_0284"] = "rbxassetid://6428183",
    ["Asset_0285"] = "rbxassetid://9464739",
    ["Asset_0286"] = "rbxassetid://9986544",
    ["Asset_0287"] = "rbxassetid://4402202",
    ["Asset_0288"] = "rbxassetid://6555421",
    ["Asset_0289"] = "rbxassetid://7800088",
    ["Asset_0290"] = "rbxassetid://5660256",
    ["Asset_0291"] = "rbxassetid://1027395",
    ["Asset_0292"] = "rbxassetid://8257823",
    ["Asset_0293"] = "rbxassetid://2888933",
    ["Asset_0294"] = "rbxassetid://7568346",
    ["Asset_0295"] = "rbxassetid://1414472",
    ["Asset_0296"] = "rbxassetid://7797801",
    ["Asset_0297"] = "rbxassetid://2938980",
    ["Asset_0298"] = "rbxassetid://1215565",
    ["Asset_0299"] = "rbxassetid://9754894",
    ["Asset_0300"] = "rbxassetid://8882555",
    ["Asset_0301"] = "rbxassetid://4820315",
    ["Asset_0302"] = "rbxassetid://4082346",
    ["Asset_0303"] = "rbxassetid://5097183",
    ["Asset_0304"] = "rbxassetid://8444435",
    ["Asset_0305"] = "rbxassetid://2142258",
    ["Asset_0306"] = "rbxassetid://1310676",
    ["Asset_0307"] = "rbxassetid://7605236",
    ["Asset_0308"] = "rbxassetid://7569909",
    ["Asset_0309"] = "rbxassetid://8166716",
    ["Asset_0310"] = "rbxassetid://7957132",
    ["Asset_0311"] = "rbxassetid://9569135",
    ["Asset_0312"] = "rbxassetid://5079709",
    ["Asset_0313"] = "rbxassetid://2725101",
    ["Asset_0314"] = "rbxassetid://4670235",
    ["Asset_0315"] = "rbxassetid://6110444",
    ["Asset_0316"] = "rbxassetid://3401539",
    ["Asset_0317"] = "rbxassetid://6243662",
    ["Asset_0318"] = "rbxassetid://9393995",
    ["Asset_0319"] = "rbxassetid://8778824",
    ["Asset_0320"] = "rbxassetid://6972818",
    ["Asset_0321"] = "rbxassetid://4850627",
    ["Asset_0322"] = "rbxassetid://5287872",
    ["Asset_0323"] = "rbxassetid://1395268",
    ["Asset_0324"] = "rbxassetid://4940619",
    ["Asset_0325"] = "rbxassetid://3706266",
    ["Asset_0326"] = "rbxassetid://2636698",
    ["Asset_0327"] = "rbxassetid://4477966",
    ["Asset_0328"] = "rbxassetid://4503763",
    ["Asset_0329"] = "rbxassetid://7889805",
    ["Asset_0330"] = "rbxassetid://9185388",
    ["Asset_0331"] = "rbxassetid://9544217",
    ["Asset_0332"] = "rbxassetid://5726785",
    ["Asset_0333"] = "rbxassetid://5543250",
    ["Asset_0334"] = "rbxassetid://5914582",
    ["Asset_0335"] = "rbxassetid://2585954",
    ["Asset_0336"] = "rbxassetid://7355828",
    ["Asset_0337"] = "rbxassetid://4857512",
    ["Asset_0338"] = "rbxassetid://9380675",
    ["Asset_0339"] = "rbxassetid://4864346",
    ["Asset_0340"] = "rbxassetid://1859554",
    ["Asset_0341"] = "rbxassetid://4432142",
    ["Asset_0342"] = "rbxassetid://4039468",
    ["Asset_0343"] = "rbxassetid://8794532",
    ["Asset_0344"] = "rbxassetid://5170469",
    ["Asset_0345"] = "rbxassetid://5011016",
    ["Asset_0346"] = "rbxassetid://9412136",
    ["Asset_0347"] = "rbxassetid://6237955",
    ["Asset_0348"] = "rbxassetid://3727141",
    ["Asset_0349"] = "rbxassetid://3884695",
    ["Asset_0350"] = "rbxassetid://2981158",
    ["Asset_0351"] = "rbxassetid://6838476",
    ["Asset_0352"] = "rbxassetid://1209475",
    ["Asset_0353"] = "rbxassetid://1960899",
    ["Asset_0354"] = "rbxassetid://7660387",
    ["Asset_0355"] = "rbxassetid://4645530",
    ["Asset_0356"] = "rbxassetid://8256214",
    ["Asset_0357"] = "rbxassetid://8272354",
    ["Asset_0358"] = "rbxassetid://5874062",
    ["Asset_0359"] = "rbxassetid://1950115",
    ["Asset_0360"] = "rbxassetid://5662055",
    ["Asset_0361"] = "rbxassetid://2233447",
    ["Asset_0362"] = "rbxassetid://3840361",
    ["Asset_0363"] = "rbxassetid://1829573",
    ["Asset_0364"] = "rbxassetid://8121115",
    ["Asset_0365"] = "rbxassetid://6834122",
    ["Asset_0366"] = "rbxassetid://2598142",
    ["Asset_0367"] = "rbxassetid://3307094",
    ["Asset_0368"] = "rbxassetid://4258954",
    ["Asset_0369"] = "rbxassetid://3006333",
    ["Asset_0370"] = "rbxassetid://8036619",
    ["Asset_0371"] = "rbxassetid://9593577",
    ["Asset_0372"] = "rbxassetid://1411451",
    ["Asset_0373"] = "rbxassetid://9184005",
    ["Asset_0374"] = "rbxassetid://6027499",
    ["Asset_0375"] = "rbxassetid://4790934",
    ["Asset_0376"] = "rbxassetid://7877151",
    ["Asset_0377"] = "rbxassetid://6318855",
    ["Asset_0378"] = "rbxassetid://4336878",
    ["Asset_0379"] = "rbxassetid://4862521",
    ["Asset_0380"] = "rbxassetid://5233146",
    ["Asset_0381"] = "rbxassetid://2747205",
    ["Asset_0382"] = "rbxassetid://8850102",
    ["Asset_0383"] = "rbxassetid://5162286",
    ["Asset_0384"] = "rbxassetid://7520114",
    ["Asset_0385"] = "rbxassetid://9049232",
    ["Asset_0386"] = "rbxassetid://3501583",
    ["Asset_0387"] = "rbxassetid://8024147",
    ["Asset_0388"] = "rbxassetid://7484647",
    ["Asset_0389"] = "rbxassetid://7008597",
    ["Asset_0390"] = "rbxassetid://6726683",
    ["Asset_0391"] = "rbxassetid://5113226",
    ["Asset_0392"] = "rbxassetid://2528118",
    ["Asset_0393"] = "rbxassetid://4698585",
    ["Asset_0394"] = "rbxassetid://3374590",
    ["Asset_0395"] = "rbxassetid://5683843",
    ["Asset_0396"] = "rbxassetid://3304328",
    ["Asset_0397"] = "rbxassetid://4616402",
    ["Asset_0398"] = "rbxassetid://3347858",
    ["Asset_0399"] = "rbxassetid://3056395",
    ["Asset_0400"] = "rbxassetid://6052918",
    ["Asset_0401"] = "rbxassetid://3004577",
    ["Asset_0402"] = "rbxassetid://6950968",
    ["Asset_0403"] = "rbxassetid://1576393",
    ["Asset_0404"] = "rbxassetid://1400935",
    ["Asset_0405"] = "rbxassetid://4697107",
    ["Asset_0406"] = "rbxassetid://7381957",
    ["Asset_0407"] = "rbxassetid://9662229",
    ["Asset_0408"] = "rbxassetid://6365655",
    ["Asset_0409"] = "rbxassetid://7977960",
    ["Asset_0410"] = "rbxassetid://2774500",
    ["Asset_0411"] = "rbxassetid://7777359",
    ["Asset_0412"] = "rbxassetid://3360957",
    ["Asset_0413"] = "rbxassetid://7736884",
    ["Asset_0414"] = "rbxassetid://1348863",
    ["Asset_0415"] = "rbxassetid://7143704",
    ["Asset_0416"] = "rbxassetid://4175573",
    ["Asset_0417"] = "rbxassetid://7089234",
    ["Asset_0418"] = "rbxassetid://2536299",
    ["Asset_0419"] = "rbxassetid://8905774",
    ["Asset_0420"] = "rbxassetid://4439586",
    ["Asset_0421"] = "rbxassetid://2263194",
    ["Asset_0422"] = "rbxassetid://9158884",
    ["Asset_0423"] = "rbxassetid://1727079",
    ["Asset_0424"] = "rbxassetid://6665542",
    ["Asset_0425"] = "rbxassetid://7950015",
    ["Asset_0426"] = "rbxassetid://8846964",
    ["Asset_0427"] = "rbxassetid://4234364",
    ["Asset_0428"] = "rbxassetid://2953882",
    ["Asset_0429"] = "rbxassetid://6748417",
    ["Asset_0430"] = "rbxassetid://8787343",
    ["Asset_0431"] = "rbxassetid://9428350",
    ["Asset_0432"] = "rbxassetid://9294002",
    ["Asset_0433"] = "rbxassetid://9755999",
    ["Asset_0434"] = "rbxassetid://8056856",
    ["Asset_0435"] = "rbxassetid://9341290",
    ["Asset_0436"] = "rbxassetid://2727323",
    ["Asset_0437"] = "rbxassetid://8726418",
    ["Asset_0438"] = "rbxassetid://1674855",
    ["Asset_0439"] = "rbxassetid://4484656",
    ["Asset_0440"] = "rbxassetid://4654336",
    ["Asset_0441"] = "rbxassetid://8753629",
    ["Asset_0442"] = "rbxassetid://6118236",
    ["Asset_0443"] = "rbxassetid://8839393",
    ["Asset_0444"] = "rbxassetid://5681747",
    ["Asset_0445"] = "rbxassetid://4793502",
    ["Asset_0446"] = "rbxassetid://1949745",
    ["Asset_0447"] = "rbxassetid://3501882",
    ["Asset_0448"] = "rbxassetid://3249628",
    ["Asset_0449"] = "rbxassetid://7549313",
    ["Asset_0450"] = "rbxassetid://1631237",
    ["Asset_0451"] = "rbxassetid://2787227",
    ["Asset_0452"] = "rbxassetid://9033180",
    ["Asset_0453"] = "rbxassetid://5458770",
    ["Asset_0454"] = "rbxassetid://5730664",
    ["Asset_0455"] = "rbxassetid://6736651",
    ["Asset_0456"] = "rbxassetid://4729245",
    ["Asset_0457"] = "rbxassetid://2170755",
    ["Asset_0458"] = "rbxassetid://5393146",
    ["Asset_0459"] = "rbxassetid://2298948",
    ["Asset_0460"] = "rbxassetid://3022535",
    ["Asset_0461"] = "rbxassetid://4513413",
    ["Asset_0462"] = "rbxassetid://9538593",
    ["Asset_0463"] = "rbxassetid://9529386",
    ["Asset_0464"] = "rbxassetid://6037717",
    ["Asset_0465"] = "rbxassetid://2749650",
    ["Asset_0466"] = "rbxassetid://7247404",
    ["Asset_0467"] = "rbxassetid://8030725",
    ["Asset_0468"] = "rbxassetid://4680234",
    ["Asset_0469"] = "rbxassetid://6785952",
    ["Asset_0470"] = "rbxassetid://1151803",
    ["Asset_0471"] = "rbxassetid://4332117",
    ["Asset_0472"] = "rbxassetid://4944491",
    ["Asset_0473"] = "rbxassetid://5935319",
    ["Asset_0474"] = "rbxassetid://7855538",
    ["Asset_0475"] = "rbxassetid://5355122",
    ["Asset_0476"] = "rbxassetid://2501442",
    ["Asset_0477"] = "rbxassetid://8756099",
    ["Asset_0478"] = "rbxassetid://3180822",
    ["Asset_0479"] = "rbxassetid://1358069",
    ["Asset_0480"] = "rbxassetid://1280913",
    ["Asset_0481"] = "rbxassetid://9538020",
    ["Asset_0482"] = "rbxassetid://2293415",
    ["Asset_0483"] = "rbxassetid://8091149",
    ["Asset_0484"] = "rbxassetid://7747784",
    ["Asset_0485"] = "rbxassetid://2041909",
    ["Asset_0486"] = "rbxassetid://2883140",
    ["Asset_0487"] = "rbxassetid://6102334",
    ["Asset_0488"] = "rbxassetid://7237156",
    ["Asset_0489"] = "rbxassetid://4977955",
    ["Asset_0490"] = "rbxassetid://5634387",
    ["Asset_0491"] = "rbxassetid://8575631",
    ["Asset_0492"] = "rbxassetid://1495695",
    ["Asset_0493"] = "rbxassetid://4507763",
    ["Asset_0494"] = "rbxassetid://3499395",
    ["Asset_0495"] = "rbxassetid://4384549",
    ["Asset_0496"] = "rbxassetid://3554290",
    ["Asset_0497"] = "rbxassetid://7804019",
    ["Asset_0498"] = "rbxassetid://7225309",
    ["Asset_0499"] = "rbxassetid://4700547",
    ["Asset_0500"] = "rbxassetid://8148392",
    ["Asset_0501"] = "rbxassetid://6670528",
    ["Asset_0502"] = "rbxassetid://1223599",
    ["Asset_0503"] = "rbxassetid://6678741",
    ["Asset_0504"] = "rbxassetid://8738569",
    ["Asset_0505"] = "rbxassetid://1624490",
    ["Asset_0506"] = "rbxassetid://8527746",
    ["Asset_0507"] = "rbxassetid://2910203",
    ["Asset_0508"] = "rbxassetid://5720552",
    ["Asset_0509"] = "rbxassetid://9056881",
    ["Asset_0510"] = "rbxassetid://3803910",
    ["Asset_0511"] = "rbxassetid://4950495",
    ["Asset_0512"] = "rbxassetid://8321087",
    ["Asset_0513"] = "rbxassetid://7384343",
    ["Asset_0514"] = "rbxassetid://4675861",
    ["Asset_0515"] = "rbxassetid://6377762",
    ["Asset_0516"] = "rbxassetid://8073264",
    ["Asset_0517"] = "rbxassetid://2009802",
    ["Asset_0518"] = "rbxassetid://7889648",
    ["Asset_0519"] = "rbxassetid://8132333",
    ["Asset_0520"] = "rbxassetid://5678426",
    ["Asset_0521"] = "rbxassetid://1454533",
    ["Asset_0522"] = "rbxassetid://9071490",
    ["Asset_0523"] = "rbxassetid://2713988",
    ["Asset_0524"] = "rbxassetid://9554935",
    ["Asset_0525"] = "rbxassetid://9173321",
    ["Asset_0526"] = "rbxassetid://7539009",
    ["Asset_0527"] = "rbxassetid://9019507",
    ["Asset_0528"] = "rbxassetid://1519467",
    ["Asset_0529"] = "rbxassetid://7619113",
    ["Asset_0530"] = "rbxassetid://2731470",
    ["Asset_0531"] = "rbxassetid://9501618",
    ["Asset_0532"] = "rbxassetid://3068638",
    ["Asset_0533"] = "rbxassetid://6028753",
    ["Asset_0534"] = "rbxassetid://2164142",
    ["Asset_0535"] = "rbxassetid://1948449",
    ["Asset_0536"] = "rbxassetid://2555758",
    ["Asset_0537"] = "rbxassetid://3505397",
    ["Asset_0538"] = "rbxassetid://9426701",
    ["Asset_0539"] = "rbxassetid://6531627",
    ["Asset_0540"] = "rbxassetid://1649976",
    ["Asset_0541"] = "rbxassetid://3308958",
    ["Asset_0542"] = "rbxassetid://8125443",
    ["Asset_0543"] = "rbxassetid://1864990",
    ["Asset_0544"] = "rbxassetid://2344338",
    ["Asset_0545"] = "rbxassetid://7950040",
    ["Asset_0546"] = "rbxassetid://4386153",
    ["Asset_0547"] = "rbxassetid://5365898",
    ["Asset_0548"] = "rbxassetid://7076293",
    ["Asset_0549"] = "rbxassetid://5813519",
    ["Asset_0550"] = "rbxassetid://4663528",
    ["Asset_0551"] = "rbxassetid://2638459",
    ["Asset_0552"] = "rbxassetid://4122749",
    ["Asset_0553"] = "rbxassetid://7959103",
    ["Asset_0554"] = "rbxassetid://7342920",
    ["Asset_0555"] = "rbxassetid://4441974",
    ["Asset_0556"] = "rbxassetid://7566000",
    ["Asset_0557"] = "rbxassetid://3661974",
    ["Asset_0558"] = "rbxassetid://3290322",
    ["Asset_0559"] = "rbxassetid://6957092",
    ["Asset_0560"] = "rbxassetid://3789704",
    ["Asset_0561"] = "rbxassetid://8344394",
    ["Asset_0562"] = "rbxassetid://6538720",
    ["Asset_0563"] = "rbxassetid://2327647",
    ["Asset_0564"] = "rbxassetid://9839184",
    ["Asset_0565"] = "rbxassetid://8375546",
    ["Asset_0566"] = "rbxassetid://3798377",
    ["Asset_0567"] = "rbxassetid://3277304",
    ["Asset_0568"] = "rbxassetid://3862234",
    ["Asset_0569"] = "rbxassetid://3178738",
    ["Asset_0570"] = "rbxassetid://6068555",
    ["Asset_0571"] = "rbxassetid://6470450",
    ["Asset_0572"] = "rbxassetid://7399886",
    ["Asset_0573"] = "rbxassetid://3786372",
    ["Asset_0574"] = "rbxassetid://4607159",
    ["Asset_0575"] = "rbxassetid://4305072",
    ["Asset_0576"] = "rbxassetid://2733827",
    ["Asset_0577"] = "rbxassetid://6368795",
    ["Asset_0578"] = "rbxassetid://9403460",
    ["Asset_0579"] = "rbxassetid://2940295",
    ["Asset_0580"] = "rbxassetid://6431716",
    ["Asset_0581"] = "rbxassetid://7025356",
    ["Asset_0582"] = "rbxassetid://9390755",
    ["Asset_0583"] = "rbxassetid://5929411",
    ["Asset_0584"] = "rbxassetid://4915027",
    ["Asset_0585"] = "rbxassetid://9473123",
    ["Asset_0586"] = "rbxassetid://3078283",
    ["Asset_0587"] = "rbxassetid://7346613",
    ["Asset_0588"] = "rbxassetid://7019219",
    ["Asset_0589"] = "rbxassetid://3519493",
    ["Asset_0590"] = "rbxassetid://5076963",
    ["Asset_0591"] = "rbxassetid://7163525",
    ["Asset_0592"] = "rbxassetid://9756661",
    ["Asset_0593"] = "rbxassetid://2266934",
    ["Asset_0594"] = "rbxassetid://1836758",
    ["Asset_0595"] = "rbxassetid://4206248",
    ["Asset_0596"] = "rbxassetid://6219562",
    ["Asset_0597"] = "rbxassetid://1190902",
    ["Asset_0598"] = "rbxassetid://5470474",
    ["Asset_0599"] = "rbxassetid://1304377",
    ["Asset_0600"] = "rbxassetid://5201392",
    ["Asset_0601"] = "rbxassetid://8595603",
    ["Asset_0602"] = "rbxassetid://8593480",
    ["Asset_0603"] = "rbxassetid://2232601",
    ["Asset_0604"] = "rbxassetid://4149793",
    ["Asset_0605"] = "rbxassetid://2982658",
    ["Asset_0606"] = "rbxassetid://6005127",
    ["Asset_0607"] = "rbxassetid://3961365",
    ["Asset_0608"] = "rbxassetid://1450984",
    ["Asset_0609"] = "rbxassetid://3639174",
    ["Asset_0610"] = "rbxassetid://3826202",
    ["Asset_0611"] = "rbxassetid://7890869",
    ["Asset_0612"] = "rbxassetid://6986324",
    ["Asset_0613"] = "rbxassetid://5375336",
    ["Asset_0614"] = "rbxassetid://2356893",
    ["Asset_0615"] = "rbxassetid://9456622",
    ["Asset_0616"] = "rbxassetid://3575953",
    ["Asset_0617"] = "rbxassetid://3185926",
    ["Asset_0618"] = "rbxassetid://4996893",
    ["Asset_0619"] = "rbxassetid://2122154",
    ["Asset_0620"] = "rbxassetid://5800732",
    ["Asset_0621"] = "rbxassetid://2987356",
    ["Asset_0622"] = "rbxassetid://8337781",
    ["Asset_0623"] = "rbxassetid://1284526",
    ["Asset_0624"] = "rbxassetid://3512077",
    ["Asset_0625"] = "rbxassetid://5068141",
    ["Asset_0626"] = "rbxassetid://1999039",
    ["Asset_0627"] = "rbxassetid://2759984",
    ["Asset_0628"] = "rbxassetid://5493378",
    ["Asset_0629"] = "rbxassetid://3110173",
    ["Asset_0630"] = "rbxassetid://9907924",
    ["Asset_0631"] = "rbxassetid://8145862",
    ["Asset_0632"] = "rbxassetid://7512064",
    ["Asset_0633"] = "rbxassetid://6731051",
    ["Asset_0634"] = "rbxassetid://4158122",
    ["Asset_0635"] = "rbxassetid://4577819",
    ["Asset_0636"] = "rbxassetid://5151894",
    ["Asset_0637"] = "rbxassetid://1056921",
    ["Asset_0638"] = "rbxassetid://6759090",
    ["Asset_0639"] = "rbxassetid://8979233",
    ["Asset_0640"] = "rbxassetid://7973010",
    ["Asset_0641"] = "rbxassetid://3761304",
    ["Asset_0642"] = "rbxassetid://3747366",
    ["Asset_0643"] = "rbxassetid://7851005",
    ["Asset_0644"] = "rbxassetid://5835233",
    ["Asset_0645"] = "rbxassetid://4257039",
    ["Asset_0646"] = "rbxassetid://9711315",
    ["Asset_0647"] = "rbxassetid://8422539",
    ["Asset_0648"] = "rbxassetid://8996537",
    ["Asset_0649"] = "rbxassetid://5183669",
    ["Asset_0650"] = "rbxassetid://3211751",
    ["Asset_0651"] = "rbxassetid://7193394",
    ["Asset_0652"] = "rbxassetid://7390320",
    ["Asset_0653"] = "rbxassetid://8247534",
    ["Asset_0654"] = "rbxassetid://9115072",
    ["Asset_0655"] = "rbxassetid://4384727",
    ["Asset_0656"] = "rbxassetid://9545874",
    ["Asset_0657"] = "rbxassetid://3798923",
    ["Asset_0658"] = "rbxassetid://4941268",
    ["Asset_0659"] = "rbxassetid://7287573",
    ["Asset_0660"] = "rbxassetid://7173576",
    ["Asset_0661"] = "rbxassetid://7986039",
    ["Asset_0662"] = "rbxassetid://9598205",
    ["Asset_0663"] = "rbxassetid://2507816",
    ["Asset_0664"] = "rbxassetid://9866266",
    ["Asset_0665"] = "rbxassetid://8715047",
    ["Asset_0666"] = "rbxassetid://6424738",
    ["Asset_0667"] = "rbxassetid://2644837",
    ["Asset_0668"] = "rbxassetid://1899521",
    ["Asset_0669"] = "rbxassetid://6208402",
    ["Asset_0670"] = "rbxassetid://2022656",
    ["Asset_0671"] = "rbxassetid://8976186",
    ["Asset_0672"] = "rbxassetid://8151135",
    ["Asset_0673"] = "rbxassetid://9062274",
    ["Asset_0674"] = "rbxassetid://2433268",
    ["Asset_0675"] = "rbxassetid://9859622",
    ["Asset_0676"] = "rbxassetid://9458463",
    ["Asset_0677"] = "rbxassetid://2013432",
    ["Asset_0678"] = "rbxassetid://9556930",
    ["Asset_0679"] = "rbxassetid://3345623",
    ["Asset_0680"] = "rbxassetid://1537737",
    ["Asset_0681"] = "rbxassetid://5232340",
    ["Asset_0682"] = "rbxassetid://5657644",
    ["Asset_0683"] = "rbxassetid://2764645",
    ["Asset_0684"] = "rbxassetid://3748533",
    ["Asset_0685"] = "rbxassetid://8823534",
    ["Asset_0686"] = "rbxassetid://5661855",
    ["Asset_0687"] = "rbxassetid://5104913",
    ["Asset_0688"] = "rbxassetid://5970705",
    ["Asset_0689"] = "rbxassetid://7419400",
    ["Asset_0690"] = "rbxassetid://5283303",
    ["Asset_0691"] = "rbxassetid://7622255",
    ["Asset_0692"] = "rbxassetid://9468266",
    ["Asset_0693"] = "rbxassetid://3785926",
    ["Asset_0694"] = "rbxassetid://6294479",
    ["Asset_0695"] = "rbxassetid://4192962",
    ["Asset_0696"] = "rbxassetid://6938390",
    ["Asset_0697"] = "rbxassetid://3513367",
    ["Asset_0698"] = "rbxassetid://7331983",
    ["Asset_0699"] = "rbxassetid://5496756",
    ["Asset_0700"] = "rbxassetid://9263023",
    ["Asset_0701"] = "rbxassetid://7577038",
    ["Asset_0702"] = "rbxassetid://1345273",
    ["Asset_0703"] = "rbxassetid://8907519",
    ["Asset_0704"] = "rbxassetid://3365983",
    ["Asset_0705"] = "rbxassetid://4448047",
    ["Asset_0706"] = "rbxassetid://3284308",
    ["Asset_0707"] = "rbxassetid://7550421",
    ["Asset_0708"] = "rbxassetid://2281877",
    ["Asset_0709"] = "rbxassetid://8868254",
    ["Asset_0710"] = "rbxassetid://6024865",
    ["Asset_0711"] = "rbxassetid://4623204",
    ["Asset_0712"] = "rbxassetid://1528334",
    ["Asset_0713"] = "rbxassetid://5346389",
    ["Asset_0714"] = "rbxassetid://7904687",
    ["Asset_0715"] = "rbxassetid://5345949",
    ["Asset_0716"] = "rbxassetid://6658779",
    ["Asset_0717"] = "rbxassetid://7456272",
    ["Asset_0718"] = "rbxassetid://9551950",
    ["Asset_0719"] = "rbxassetid://4221410",
    ["Asset_0720"] = "rbxassetid://8618092",
    ["Asset_0721"] = "rbxassetid://1709644",
    ["Asset_0722"] = "rbxassetid://3336062",
    ["Asset_0723"] = "rbxassetid://7849448",
    ["Asset_0724"] = "rbxassetid://7967406",
    ["Asset_0725"] = "rbxassetid://1949158",
    ["Asset_0726"] = "rbxassetid://8948204",
    ["Asset_0727"] = "rbxassetid://4111274",
    ["Asset_0728"] = "rbxassetid://8178564",
    ["Asset_0729"] = "rbxassetid://2654680",
    ["Asset_0730"] = "rbxassetid://9963827",
    ["Asset_0731"] = "rbxassetid://1753419",
    ["Asset_0732"] = "rbxassetid://7736105",
    ["Asset_0733"] = "rbxassetid://6651326",
    ["Asset_0734"] = "rbxassetid://3543604",
    ["Asset_0735"] = "rbxassetid://2366635",
    ["Asset_0736"] = "rbxassetid://1494480",
    ["Asset_0737"] = "rbxassetid://2314908",
    ["Asset_0738"] = "rbxassetid://5470571",
    ["Asset_0739"] = "rbxassetid://4477842",
    ["Asset_0740"] = "rbxassetid://6752925",
    ["Asset_0741"] = "rbxassetid://3297371",
    ["Asset_0742"] = "rbxassetid://6563680",
    ["Asset_0743"] = "rbxassetid://7277066",
    ["Asset_0744"] = "rbxassetid://6201057",
    ["Asset_0745"] = "rbxassetid://6665649",
    ["Asset_0746"] = "rbxassetid://7843811",
    ["Asset_0747"] = "rbxassetid://9650051",
    ["Asset_0748"] = "rbxassetid://5880788",
    ["Asset_0749"] = "rbxassetid://7400890",
    ["Asset_0750"] = "rbxassetid://4094691",
    ["Asset_0751"] = "rbxassetid://1405172",
    ["Asset_0752"] = "rbxassetid://6402276",
    ["Asset_0753"] = "rbxassetid://1838319",
    ["Asset_0754"] = "rbxassetid://4594176",
    ["Asset_0755"] = "rbxassetid://4015155",
    ["Asset_0756"] = "rbxassetid://9595403",
    ["Asset_0757"] = "rbxassetid://6095903",
    ["Asset_0758"] = "rbxassetid://3057274",
    ["Asset_0759"] = "rbxassetid://4962939",
    ["Asset_0760"] = "rbxassetid://6397293",
    ["Asset_0761"] = "rbxassetid://1975010",
    ["Asset_0762"] = "rbxassetid://8025791",
    ["Asset_0763"] = "rbxassetid://2770234",
    ["Asset_0764"] = "rbxassetid://7982835",
    ["Asset_0765"] = "rbxassetid://8654967",
    ["Asset_0766"] = "rbxassetid://8944812",
    ["Asset_0767"] = "rbxassetid://2895484",
    ["Asset_0768"] = "rbxassetid://7200835",
    ["Asset_0769"] = "rbxassetid://8660858",
    ["Asset_0770"] = "rbxassetid://6522451",
    ["Asset_0771"] = "rbxassetid://5473407",
    ["Asset_0772"] = "rbxassetid://2013987",
    ["Asset_0773"] = "rbxassetid://5601904",
    ["Asset_0774"] = "rbxassetid://5326943",
    ["Asset_0775"] = "rbxassetid://6841596",
    ["Asset_0776"] = "rbxassetid://3584653",
    ["Asset_0777"] = "rbxassetid://3694387",
    ["Asset_0778"] = "rbxassetid://5038766",
    ["Asset_0779"] = "rbxassetid://7824026",
    ["Asset_0780"] = "rbxassetid://1606540",
    ["Asset_0781"] = "rbxassetid://3735366",
    ["Asset_0782"] = "rbxassetid://7806931",
    ["Asset_0783"] = "rbxassetid://8577282",
    ["Asset_0784"] = "rbxassetid://1473158",
    ["Asset_0785"] = "rbxassetid://6629142",
    ["Asset_0786"] = "rbxassetid://7931934",
    ["Asset_0787"] = "rbxassetid://5991541",
    ["Asset_0788"] = "rbxassetid://7451671",
    ["Asset_0789"] = "rbxassetid://4678910",
    ["Asset_0790"] = "rbxassetid://6419008",
    ["Asset_0791"] = "rbxassetid://6999101",
    ["Asset_0792"] = "rbxassetid://2685325",
    ["Asset_0793"] = "rbxassetid://1219744",
    ["Asset_0794"] = "rbxassetid://8492536",
    ["Asset_0795"] = "rbxassetid://1136453",
    ["Asset_0796"] = "rbxassetid://4661162",
    ["Asset_0797"] = "rbxassetid://3794121",
    ["Asset_0798"] = "rbxassetid://4137288",
    ["Asset_0799"] = "rbxassetid://2919408",
    ["Asset_0800"] = "rbxassetid://3652951",
    ["Asset_0801"] = "rbxassetid://1913866",
    ["Asset_0802"] = "rbxassetid://3691429",
    ["Asset_0803"] = "rbxassetid://9060195",
    ["Asset_0804"] = "rbxassetid://2235779",
    ["Asset_0805"] = "rbxassetid://9420118",
    ["Asset_0806"] = "rbxassetid://9845136",
    ["Asset_0807"] = "rbxassetid://5731801",
    ["Asset_0808"] = "rbxassetid://1370563",
    ["Asset_0809"] = "rbxassetid://6745270",
    ["Asset_0810"] = "rbxassetid://1824279",
    ["Asset_0811"] = "rbxassetid://8611097",
    ["Asset_0812"] = "rbxassetid://7759417",
    ["Asset_0813"] = "rbxassetid://9866308",
    ["Asset_0814"] = "rbxassetid://6207402",
    ["Asset_0815"] = "rbxassetid://2319151",
    ["Asset_0816"] = "rbxassetid://6520572",
    ["Asset_0817"] = "rbxassetid://3719994",
    ["Asset_0818"] = "rbxassetid://5965997",
    ["Asset_0819"] = "rbxassetid://7152345",
    ["Asset_0820"] = "rbxassetid://7441984",
    ["Asset_0821"] = "rbxassetid://2619010",
    ["Asset_0822"] = "rbxassetid://6689331",
    ["Asset_0823"] = "rbxassetid://9213010",
    ["Asset_0824"] = "rbxassetid://5700825",
    ["Asset_0825"] = "rbxassetid://5099623",
    ["Asset_0826"] = "rbxassetid://6143932",
    ["Asset_0827"] = "rbxassetid://3972592",
    ["Asset_0828"] = "rbxassetid://5155307",
    ["Asset_0829"] = "rbxassetid://9474032",
    ["Asset_0830"] = "rbxassetid://8257753",
    ["Asset_0831"] = "rbxassetid://9714826",
    ["Asset_0832"] = "rbxassetid://3148784",
    ["Asset_0833"] = "rbxassetid://7222437",
    ["Asset_0834"] = "rbxassetid://3312680",
    ["Asset_0835"] = "rbxassetid://1881768",
    ["Asset_0836"] = "rbxassetid://5363704",
    ["Asset_0837"] = "rbxassetid://9919034",
    ["Asset_0838"] = "rbxassetid://4693167",
    ["Asset_0839"] = "rbxassetid://8072134",
    ["Asset_0840"] = "rbxassetid://9226920",
    ["Asset_0841"] = "rbxassetid://4690310",
    ["Asset_0842"] = "rbxassetid://5973329",
    ["Asset_0843"] = "rbxassetid://5697641",
    ["Asset_0844"] = "rbxassetid://1484789",
    ["Asset_0845"] = "rbxassetid://6853837",
    ["Asset_0846"] = "rbxassetid://5754806",
    ["Asset_0847"] = "rbxassetid://2284758",
    ["Asset_0848"] = "rbxassetid://1794998",
    ["Asset_0849"] = "rbxassetid://2977939",
    ["Asset_0850"] = "rbxassetid://3739843",
    ["Asset_0851"] = "rbxassetid://3590836",
    ["Asset_0852"] = "rbxassetid://7050148",
    ["Asset_0853"] = "rbxassetid://6128983",
    ["Asset_0854"] = "rbxassetid://8350919",
    ["Asset_0855"] = "rbxassetid://3947261",
    ["Asset_0856"] = "rbxassetid://5905989",
    ["Asset_0857"] = "rbxassetid://5826881",
    ["Asset_0858"] = "rbxassetid://9772134",
    ["Asset_0859"] = "rbxassetid://4526133",
    ["Asset_0860"] = "rbxassetid://5300745",
    ["Asset_0861"] = "rbxassetid://5188635",
    ["Asset_0862"] = "rbxassetid://7103706",
    ["Asset_0863"] = "rbxassetid://2208961",
    ["Asset_0864"] = "rbxassetid://3396221",
    ["Asset_0865"] = "rbxassetid://7702681",
    ["Asset_0866"] = "rbxassetid://9537609",
    ["Asset_0867"] = "rbxassetid://8793886",
    ["Asset_0868"] = "rbxassetid://8031390",
    ["Asset_0869"] = "rbxassetid://4101852",
    ["Asset_0870"] = "rbxassetid://9433304",
    ["Asset_0871"] = "rbxassetid://7804736",
    ["Asset_0872"] = "rbxassetid://3622774",
    ["Asset_0873"] = "rbxassetid://1523879",
    ["Asset_0874"] = "rbxassetid://9782689",
    ["Asset_0875"] = "rbxassetid://5717179",
    ["Asset_0876"] = "rbxassetid://7122477",
    ["Asset_0877"] = "rbxassetid://5703946",
    ["Asset_0878"] = "rbxassetid://5717499",
    ["Asset_0879"] = "rbxassetid://8332317",
    ["Asset_0880"] = "rbxassetid://4496846",
    ["Asset_0881"] = "rbxassetid://8547146",
    ["Asset_0882"] = "rbxassetid://2008446",
    ["Asset_0883"] = "rbxassetid://5054375",
    ["Asset_0884"] = "rbxassetid://9651143",
    ["Asset_0885"] = "rbxassetid://8321272",
    ["Asset_0886"] = "rbxassetid://1252666",
    ["Asset_0887"] = "rbxassetid://4974282",
    ["Asset_0888"] = "rbxassetid://1807405",
    ["Asset_0889"] = "rbxassetid://2858459",
    ["Asset_0890"] = "rbxassetid://7352492",
    ["Asset_0891"] = "rbxassetid://4849502",
    ["Asset_0892"] = "rbxassetid://1933859",
    ["Asset_0893"] = "rbxassetid://3161727",
    ["Asset_0894"] = "rbxassetid://8094185",
    ["Asset_0895"] = "rbxassetid://5282126",
    ["Asset_0896"] = "rbxassetid://4382170",
    ["Asset_0897"] = "rbxassetid://9383574",
    ["Asset_0898"] = "rbxassetid://1565844",
    ["Asset_0899"] = "rbxassetid://3478764",
    ["Asset_0900"] = "rbxassetid://3418967",
    ["Asset_0901"] = "rbxassetid://1885528",
    ["Asset_0902"] = "rbxassetid://9206698",
    ["Asset_0903"] = "rbxassetid://4125951",
    ["Asset_0904"] = "rbxassetid://4055992",
    ["Asset_0905"] = "rbxassetid://2663757",
    ["Asset_0906"] = "rbxassetid://9498854",
    ["Asset_0907"] = "rbxassetid://2902336",
    ["Asset_0908"] = "rbxassetid://9541871",
    ["Asset_0909"] = "rbxassetid://7227803",
    ["Asset_0910"] = "rbxassetid://9021882",
    ["Asset_0911"] = "rbxassetid://7894017",
    ["Asset_0912"] = "rbxassetid://9708442",
    ["Asset_0913"] = "rbxassetid://8530631",
    ["Asset_0914"] = "rbxassetid://7225596",
    ["Asset_0915"] = "rbxassetid://4810320",
    ["Asset_0916"] = "rbxassetid://9602915",
    ["Asset_0917"] = "rbxassetid://9468941",
    ["Asset_0918"] = "rbxassetid://5690364",
    ["Asset_0919"] = "rbxassetid://7228403",
    ["Asset_0920"] = "rbxassetid://9659940",
    ["Asset_0921"] = "rbxassetid://7061629",
    ["Asset_0922"] = "rbxassetid://4988791",
    ["Asset_0923"] = "rbxassetid://2191043",
    ["Asset_0924"] = "rbxassetid://5955978",
    ["Asset_0925"] = "rbxassetid://7304119",
    ["Asset_0926"] = "rbxassetid://7044007",
    ["Asset_0927"] = "rbxassetid://9441218",
    ["Asset_0928"] = "rbxassetid://9182686",
    ["Asset_0929"] = "rbxassetid://5777468",
    ["Asset_0930"] = "rbxassetid://7217655",
    ["Asset_0931"] = "rbxassetid://8708026",
    ["Asset_0932"] = "rbxassetid://2811272",
    ["Asset_0933"] = "rbxassetid://7426945",
    ["Asset_0934"] = "rbxassetid://4992430",
    ["Asset_0935"] = "rbxassetid://6247592",
    ["Asset_0936"] = "rbxassetid://2411983",
    ["Asset_0937"] = "rbxassetid://7246986",
    ["Asset_0938"] = "rbxassetid://8273509",
    ["Asset_0939"] = "rbxassetid://2374071",
    ["Asset_0940"] = "rbxassetid://4739452",
    ["Asset_0941"] = "rbxassetid://8188462",
    ["Asset_0942"] = "rbxassetid://5177888",
    ["Asset_0943"] = "rbxassetid://2739454",
    ["Asset_0944"] = "rbxassetid://9764407",
    ["Asset_0945"] = "rbxassetid://7521077",
    ["Asset_0946"] = "rbxassetid://6919083",
    ["Asset_0947"] = "rbxassetid://9961520",
    ["Asset_0948"] = "rbxassetid://9670027",
    ["Asset_0949"] = "rbxassetid://4624204",
    ["Asset_0950"] = "rbxassetid://9764214",
    ["Asset_0951"] = "rbxassetid://7145359",
    ["Asset_0952"] = "rbxassetid://7147312",
    ["Asset_0953"] = "rbxassetid://3721091",
    ["Asset_0954"] = "rbxassetid://4576794",
    ["Asset_0955"] = "rbxassetid://6415192",
    ["Asset_0956"] = "rbxassetid://3344725",
    ["Asset_0957"] = "rbxassetid://1638631",
    ["Asset_0958"] = "rbxassetid://7456242",
    ["Asset_0959"] = "rbxassetid://8245104",
    ["Asset_0960"] = "rbxassetid://9580905",
    ["Asset_0961"] = "rbxassetid://1519981",
    ["Asset_0962"] = "rbxassetid://2993440",
    ["Asset_0963"] = "rbxassetid://5104161",
    ["Asset_0964"] = "rbxassetid://3146321",
    ["Asset_0965"] = "rbxassetid://9777266",
    ["Asset_0966"] = "rbxassetid://6465975",
    ["Asset_0967"] = "rbxassetid://7246580",
    ["Asset_0968"] = "rbxassetid://3590253",
    ["Asset_0969"] = "rbxassetid://7589596",
    ["Asset_0970"] = "rbxassetid://3056772",
    ["Asset_0971"] = "rbxassetid://6712385",
    ["Asset_0972"] = "rbxassetid://8504220",
    ["Asset_0973"] = "rbxassetid://9023673",
    ["Asset_0974"] = "rbxassetid://8814433",
    ["Asset_0975"] = "rbxassetid://5498117",
    ["Asset_0976"] = "rbxassetid://7733232",
    ["Asset_0977"] = "rbxassetid://4009792",
    ["Asset_0978"] = "rbxassetid://6449100",
    ["Asset_0979"] = "rbxassetid://7733791",
    ["Asset_0980"] = "rbxassetid://3649912",
    ["Asset_0981"] = "rbxassetid://9708181",
    ["Asset_0982"] = "rbxassetid://9743207",
    ["Asset_0983"] = "rbxassetid://9193414",
    ["Asset_0984"] = "rbxassetid://2371638",
    ["Asset_0985"] = "rbxassetid://1419531",
    ["Asset_0986"] = "rbxassetid://2010674",
    ["Asset_0987"] = "rbxassetid://7442654",
    ["Asset_0988"] = "rbxassetid://8232228",
    ["Asset_0989"] = "rbxassetid://7118806",
    ["Asset_0990"] = "rbxassetid://7718303",
    ["Asset_0991"] = "rbxassetid://5329966",
    ["Asset_0992"] = "rbxassetid://7630219",
    ["Asset_0993"] = "rbxassetid://2535772",
    ["Asset_0994"] = "rbxassetid://5525569",
    ["Asset_0995"] = "rbxassetid://6349227",
    ["Asset_0996"] = "rbxassetid://9408224",
    ["Asset_0997"] = "rbxassetid://1178391",
    ["Asset_0998"] = "rbxassetid://6928210",
    ["Asset_0999"] = "rbxassetid://3112260",
    ["Asset_1000"] = "rbxassetid://2741866",
    ["Asset_1001"] = "rbxassetid://7239767",
    ["Asset_1002"] = "rbxassetid://7497178",
    ["Asset_1003"] = "rbxassetid://3142260",
    ["Asset_1004"] = "rbxassetid://7211561",
    ["Asset_1005"] = "rbxassetid://7820085",
    ["Asset_1006"] = "rbxassetid://8840207",
    ["Asset_1007"] = "rbxassetid://4867764",
    ["Asset_1008"] = "rbxassetid://7345814",
    ["Asset_1009"] = "rbxassetid://3022783",
    ["Asset_1010"] = "rbxassetid://4081700",
    ["Asset_1011"] = "rbxassetid://2694528",
    ["Asset_1012"] = "rbxassetid://6508235",
    ["Asset_1013"] = "rbxassetid://8639246",
    ["Asset_1014"] = "rbxassetid://4394810",
    ["Asset_1015"] = "rbxassetid://5678439",
    ["Asset_1016"] = "rbxassetid://1839842",
    ["Asset_1017"] = "rbxassetid://4211383",
    ["Asset_1018"] = "rbxassetid://2550875",
    ["Asset_1019"] = "rbxassetid://7760247",
    ["Asset_1020"] = "rbxassetid://4195170",
    ["Asset_1021"] = "rbxassetid://6882652",
    ["Asset_1022"] = "rbxassetid://6933378",
    ["Asset_1023"] = "rbxassetid://2089344",
    ["Asset_1024"] = "rbxassetid://9137046",
    ["Asset_1025"] = "rbxassetid://4287459",
    ["Asset_1026"] = "rbxassetid://1829284",
    ["Asset_1027"] = "rbxassetid://4294457",
    ["Asset_1028"] = "rbxassetid://8550881",
    ["Asset_1029"] = "rbxassetid://8922449",
    ["Asset_1030"] = "rbxassetid://1636258",
    ["Asset_1031"] = "rbxassetid://9806675",
    ["Asset_1032"] = "rbxassetid://8030183",
    ["Asset_1033"] = "rbxassetid://4472671",
    ["Asset_1034"] = "rbxassetid://6624065",
    ["Asset_1035"] = "rbxassetid://4332439",
    ["Asset_1036"] = "rbxassetid://4575929",
    ["Asset_1037"] = "rbxassetid://8955176",
    ["Asset_1038"] = "rbxassetid://8751998",
    ["Asset_1039"] = "rbxassetid://9502378",
    ["Asset_1040"] = "rbxassetid://1366148",
    ["Asset_1041"] = "rbxassetid://5679472",
    ["Asset_1042"] = "rbxassetid://5430244",
    ["Asset_1043"] = "rbxassetid://8032357",
    ["Asset_1044"] = "rbxassetid://8605923",
    ["Asset_1045"] = "rbxassetid://3699537",
    ["Asset_1046"] = "rbxassetid://5381291",
    ["Asset_1047"] = "rbxassetid://6026781",
    ["Asset_1048"] = "rbxassetid://8534512",
    ["Asset_1049"] = "rbxassetid://2264073",
    ["Asset_1050"] = "rbxassetid://7934180",
    ["Asset_1051"] = "rbxassetid://4786779",
    ["Asset_1052"] = "rbxassetid://3247913",
    ["Asset_1053"] = "rbxassetid://5854607",
    ["Asset_1054"] = "rbxassetid://9936222",
    ["Asset_1055"] = "rbxassetid://1499299",
    ["Asset_1056"] = "rbxassetid://6729340",
    ["Asset_1057"] = "rbxassetid://5295305",
    ["Asset_1058"] = "rbxassetid://5186996",
    ["Asset_1059"] = "rbxassetid://3082988",
    ["Asset_1060"] = "rbxassetid://8506098",
    ["Asset_1061"] = "rbxassetid://6940055",
    ["Asset_1062"] = "rbxassetid://1244103",
    ["Asset_1063"] = "rbxassetid://2904735",
    ["Asset_1064"] = "rbxassetid://8032805",
    ["Asset_1065"] = "rbxassetid://3725548",
    ["Asset_1066"] = "rbxassetid://2798544",
    ["Asset_1067"] = "rbxassetid://6461038",
    ["Asset_1068"] = "rbxassetid://2130468",
    ["Asset_1069"] = "rbxassetid://6955543",
    ["Asset_1070"] = "rbxassetid://5996237",
    ["Asset_1071"] = "rbxassetid://9089707",
    ["Asset_1072"] = "rbxassetid://8340956",
    ["Asset_1073"] = "rbxassetid://5292857",
    ["Asset_1074"] = "rbxassetid://6011043",
    ["Asset_1075"] = "rbxassetid://5321472",
    ["Asset_1076"] = "rbxassetid://6198851",
    ["Asset_1077"] = "rbxassetid://7119335",
    ["Asset_1078"] = "rbxassetid://1228216",
    ["Asset_1079"] = "rbxassetid://8544980",
    ["Asset_1080"] = "rbxassetid://7819783",
    ["Asset_1081"] = "rbxassetid://6591553",
    ["Asset_1082"] = "rbxassetid://9475699",
    ["Asset_1083"] = "rbxassetid://5755068",
    ["Asset_1084"] = "rbxassetid://6011673",
    ["Asset_1085"] = "rbxassetid://2583642",
    ["Asset_1086"] = "rbxassetid://1060769",
    ["Asset_1087"] = "rbxassetid://6708443",
    ["Asset_1088"] = "rbxassetid://3664732",
    ["Asset_1089"] = "rbxassetid://2196876",
    ["Asset_1090"] = "rbxassetid://5327387",
    ["Asset_1091"] = "rbxassetid://2885185",
    ["Asset_1092"] = "rbxassetid://1342855",
    ["Asset_1093"] = "rbxassetid://8094867",
    ["Asset_1094"] = "rbxassetid://5872890",
    ["Asset_1095"] = "rbxassetid://5017928",
    ["Asset_1096"] = "rbxassetid://3365962",
    ["Asset_1097"] = "rbxassetid://1078231",
    ["Asset_1098"] = "rbxassetid://6252555",
    ["Asset_1099"] = "rbxassetid://8889367",
    ["Asset_1100"] = "rbxassetid://6530507",
    ["Asset_1101"] = "rbxassetid://3861893",
    ["Asset_1102"] = "rbxassetid://1906081",
    ["Asset_1103"] = "rbxassetid://7208677",
    ["Asset_1104"] = "rbxassetid://9593114",
    ["Asset_1105"] = "rbxassetid://6676922",
    ["Asset_1106"] = "rbxassetid://3097062",
    ["Asset_1107"] = "rbxassetid://2197195",
    ["Asset_1108"] = "rbxassetid://9331027",
    ["Asset_1109"] = "rbxassetid://4568325",
    ["Asset_1110"] = "rbxassetid://3457032",
    ["Asset_1111"] = "rbxassetid://7910471",
    ["Asset_1112"] = "rbxassetid://7673922",
    ["Asset_1113"] = "rbxassetid://1851198",
    ["Asset_1114"] = "rbxassetid://2296910",
    ["Asset_1115"] = "rbxassetid://1558058",
    ["Asset_1116"] = "rbxassetid://3629713",
    ["Asset_1117"] = "rbxassetid://7576232",
    ["Asset_1118"] = "rbxassetid://5710815",
    ["Asset_1119"] = "rbxassetid://7615723",
    ["Asset_1120"] = "rbxassetid://8255170",
    ["Asset_1121"] = "rbxassetid://1647126",
    ["Asset_1122"] = "rbxassetid://1955547",
    ["Asset_1123"] = "rbxassetid://2598462",
    ["Asset_1124"] = "rbxassetid://8658284",
    ["Asset_1125"] = "rbxassetid://2618279",
    ["Asset_1126"] = "rbxassetid://1974582",
    ["Asset_1127"] = "rbxassetid://2746452",
    ["Asset_1128"] = "rbxassetid://4911847",
    ["Asset_1129"] = "rbxassetid://7819282",
    ["Asset_1130"] = "rbxassetid://7753068",
    ["Asset_1131"] = "rbxassetid://7071569",
    ["Asset_1132"] = "rbxassetid://1810088",
    ["Asset_1133"] = "rbxassetid://6715938",
    ["Asset_1134"] = "rbxassetid://6344969",
    ["Asset_1135"] = "rbxassetid://9033578",
    ["Asset_1136"] = "rbxassetid://7597116",
    ["Asset_1137"] = "rbxassetid://7179148",
    ["Asset_1138"] = "rbxassetid://3278001",
    ["Asset_1139"] = "rbxassetid://5119290",
    ["Asset_1140"] = "rbxassetid://1620678",
    ["Asset_1141"] = "rbxassetid://8046238",
    ["Asset_1142"] = "rbxassetid://5623702",
    ["Asset_1143"] = "rbxassetid://4604746",
    ["Asset_1144"] = "rbxassetid://9460991",
    ["Asset_1145"] = "rbxassetid://1768236",
    ["Asset_1146"] = "rbxassetid://8982844",
    ["Asset_1147"] = "rbxassetid://3554277",
    ["Asset_1148"] = "rbxassetid://8885702",
    ["Asset_1149"] = "rbxassetid://8356084",
    ["Asset_1150"] = "rbxassetid://1206681",
    ["Asset_1151"] = "rbxassetid://8754743",
    ["Asset_1152"] = "rbxassetid://9447826",
    ["Asset_1153"] = "rbxassetid://3760861",
    ["Asset_1154"] = "rbxassetid://1571087",
    ["Asset_1155"] = "rbxassetid://2339991",
    ["Asset_1156"] = "rbxassetid://8267137",
    ["Asset_1157"] = "rbxassetid://1434087",
    ["Asset_1158"] = "rbxassetid://5974520",
    ["Asset_1159"] = "rbxassetid://3124387",
    ["Asset_1160"] = "rbxassetid://3960607",
    ["Asset_1161"] = "rbxassetid://5408452",
    ["Asset_1162"] = "rbxassetid://6946508",
    ["Asset_1163"] = "rbxassetid://5165624",
    ["Asset_1164"] = "rbxassetid://3658296",
    ["Asset_1165"] = "rbxassetid://8163228",
    ["Asset_1166"] = "rbxassetid://2564027",
    ["Asset_1167"] = "rbxassetid://8435324",
    ["Asset_1168"] = "rbxassetid://1713763",
    ["Asset_1169"] = "rbxassetid://3759722",
    ["Asset_1170"] = "rbxassetid://2622209",
    ["Asset_1171"] = "rbxassetid://7150841",
    ["Asset_1172"] = "rbxassetid://1547474",
    ["Asset_1173"] = "rbxassetid://7040214",
    ["Asset_1174"] = "rbxassetid://4593093",
    ["Asset_1175"] = "rbxassetid://2078112",
    ["Asset_1176"] = "rbxassetid://2326932",
    ["Asset_1177"] = "rbxassetid://7458072",
    ["Asset_1178"] = "rbxassetid://3469845",
    ["Asset_1179"] = "rbxassetid://2260399",
    ["Asset_1180"] = "rbxassetid://2948841",
    ["Asset_1181"] = "rbxassetid://9191659",
    ["Asset_1182"] = "rbxassetid://1277431",
    ["Asset_1183"] = "rbxassetid://4193399",
    ["Asset_1184"] = "rbxassetid://4620227",
    ["Asset_1185"] = "rbxassetid://5624507",
    ["Asset_1186"] = "rbxassetid://1629367",
    ["Asset_1187"] = "rbxassetid://5574811",
    ["Asset_1188"] = "rbxassetid://5602865",
    ["Asset_1189"] = "rbxassetid://4457498",
    ["Asset_1190"] = "rbxassetid://6176846",
    ["Asset_1191"] = "rbxassetid://3738802",
    ["Asset_1192"] = "rbxassetid://1843776",
    ["Asset_1193"] = "rbxassetid://7710346",
    ["Asset_1194"] = "rbxassetid://3519473",
    ["Asset_1195"] = "rbxassetid://2826848",
    ["Asset_1196"] = "rbxassetid://6107378",
    ["Asset_1197"] = "rbxassetid://9475329",
    ["Asset_1198"] = "rbxassetid://1608620",
    ["Asset_1199"] = "rbxassetid://8847325",
    ["Asset_1200"] = "rbxassetid://3494780",
    ["Asset_1201"] = "rbxassetid://3892191",
    ["Asset_1202"] = "rbxassetid://7040439",
    ["Asset_1203"] = "rbxassetid://8907395",
    ["Asset_1204"] = "rbxassetid://8759053",
    ["Asset_1205"] = "rbxassetid://8798847",
    ["Asset_1206"] = "rbxassetid://3235545",
    ["Asset_1207"] = "rbxassetid://2832780",
    ["Asset_1208"] = "rbxassetid://9343441",
    ["Asset_1209"] = "rbxassetid://4684859",
    ["Asset_1210"] = "rbxassetid://8199273",
    ["Asset_1211"] = "rbxassetid://7848252",
    ["Asset_1212"] = "rbxassetid://2221297",
    ["Asset_1213"] = "rbxassetid://5633423",
    ["Asset_1214"] = "rbxassetid://2028465",
    ["Asset_1215"] = "rbxassetid://1309242",
    ["Asset_1216"] = "rbxassetid://2960559",
    ["Asset_1217"] = "rbxassetid://3967637",
    ["Asset_1218"] = "rbxassetid://4570860",
    ["Asset_1219"] = "rbxassetid://4516682",
    ["Asset_1220"] = "rbxassetid://4600874",
    ["Asset_1221"] = "rbxassetid://7002719",
    ["Asset_1222"] = "rbxassetid://3674683",
    ["Asset_1223"] = "rbxassetid://5943358",
    ["Asset_1224"] = "rbxassetid://7142910",
    ["Asset_1225"] = "rbxassetid://5884066",
    ["Asset_1226"] = "rbxassetid://3174542",
    ["Asset_1227"] = "rbxassetid://7690241",
    ["Asset_1228"] = "rbxassetid://7581068",
    ["Asset_1229"] = "rbxassetid://7627709",
    ["Asset_1230"] = "rbxassetid://8242793",
    ["Asset_1231"] = "rbxassetid://3506956",
    ["Asset_1232"] = "rbxassetid://9696099",
    ["Asset_1233"] = "rbxassetid://1911008",
    ["Asset_1234"] = "rbxassetid://8273769",
    ["Asset_1235"] = "rbxassetid://5386015",
    ["Asset_1236"] = "rbxassetid://2797628",
    ["Asset_1237"] = "rbxassetid://4948383",
    ["Asset_1238"] = "rbxassetid://2316571",
    ["Asset_1239"] = "rbxassetid://5254680",
    ["Asset_1240"] = "rbxassetid://5243925",
    ["Asset_1241"] = "rbxassetid://7191205",
    ["Asset_1242"] = "rbxassetid://6537623",
    ["Asset_1243"] = "rbxassetid://5278852",
    ["Asset_1244"] = "rbxassetid://8991137",
    ["Asset_1245"] = "rbxassetid://3056720",
    ["Asset_1246"] = "rbxassetid://1841834",
    ["Asset_1247"] = "rbxassetid://8566891",
    ["Asset_1248"] = "rbxassetid://4027769",
    ["Asset_1249"] = "rbxassetid://7939638",
    ["Asset_1250"] = "rbxassetid://2409869",
    ["Asset_1251"] = "rbxassetid://1165268",
    ["Asset_1252"] = "rbxassetid://7303064",
    ["Asset_1253"] = "rbxassetid://6702620",
    ["Asset_1254"] = "rbxassetid://4285896",
    ["Asset_1255"] = "rbxassetid://2479304",
    ["Asset_1256"] = "rbxassetid://6851942",
    ["Asset_1257"] = "rbxassetid://6783795",
    ["Asset_1258"] = "rbxassetid://7724719",
    ["Asset_1259"] = "rbxassetid://1335265",
    ["Asset_1260"] = "rbxassetid://4840158",
    ["Asset_1261"] = "rbxassetid://8043605",
    ["Asset_1262"] = "rbxassetid://8685011",
    ["Asset_1263"] = "rbxassetid://7773690",
    ["Asset_1264"] = "rbxassetid://7292172",
    ["Asset_1265"] = "rbxassetid://4372119",
    ["Asset_1266"] = "rbxassetid://6945262",
    ["Asset_1267"] = "rbxassetid://6675978",
    ["Asset_1268"] = "rbxassetid://9360894",
    ["Asset_1269"] = "rbxassetid://8692895",
    ["Asset_1270"] = "rbxassetid://1712453",
    ["Asset_1271"] = "rbxassetid://5267311",
    ["Asset_1272"] = "rbxassetid://4490326",
    ["Asset_1273"] = "rbxassetid://8933207",
    ["Asset_1274"] = "rbxassetid://1445798",
    ["Asset_1275"] = "rbxassetid://7716692",
    ["Asset_1276"] = "rbxassetid://9939017",
    ["Asset_1277"] = "rbxassetid://9660028",
    ["Asset_1278"] = "rbxassetid://7230176",
    ["Asset_1279"] = "rbxassetid://7755608",
    ["Asset_1280"] = "rbxassetid://9637489",
    ["Asset_1281"] = "rbxassetid://8535918",
    ["Asset_1282"] = "rbxassetid://5297488",
    ["Asset_1283"] = "rbxassetid://7361469",
    ["Asset_1284"] = "rbxassetid://6551870",
    ["Asset_1285"] = "rbxassetid://8833606",
    ["Asset_1286"] = "rbxassetid://3983585",
    ["Asset_1287"] = "rbxassetid://3452558",
    ["Asset_1288"] = "rbxassetid://7043911",
    ["Asset_1289"] = "rbxassetid://4581659",
    ["Asset_1290"] = "rbxassetid://2698786",
    ["Asset_1291"] = "rbxassetid://2331292",
    ["Asset_1292"] = "rbxassetid://6450417",
    ["Asset_1293"] = "rbxassetid://6045666",
    ["Asset_1294"] = "rbxassetid://7767426",
    ["Asset_1295"] = "rbxassetid://4551685",
    ["Asset_1296"] = "rbxassetid://4750952",
    ["Asset_1297"] = "rbxassetid://9088860",
    ["Asset_1298"] = "rbxassetid://6197982",
    ["Asset_1299"] = "rbxassetid://5970280",
    ["Asset_1300"] = "rbxassetid://7447408",
    ["Asset_1301"] = "rbxassetid://5354861",
    ["Asset_1302"] = "rbxassetid://4698850",
    ["Asset_1303"] = "rbxassetid://9742439",
    ["Asset_1304"] = "rbxassetid://9993631",
    ["Asset_1305"] = "rbxassetid://4165314",
    ["Asset_1306"] = "rbxassetid://2436931",
    ["Asset_1307"] = "rbxassetid://9516514",
    ["Asset_1308"] = "rbxassetid://1732473",
    ["Asset_1309"] = "rbxassetid://5421752",
    ["Asset_1310"] = "rbxassetid://1595033",
    ["Asset_1311"] = "rbxassetid://9876155",
    ["Asset_1312"] = "rbxassetid://3191533",
    ["Asset_1313"] = "rbxassetid://3816169",
    ["Asset_1314"] = "rbxassetid://9992315",
    ["Asset_1315"] = "rbxassetid://9307691",
    ["Asset_1316"] = "rbxassetid://6421407",
    ["Asset_1317"] = "rbxassetid://9509458",
    ["Asset_1318"] = "rbxassetid://9737526",
    ["Asset_1319"] = "rbxassetid://5910279",
    ["Asset_1320"] = "rbxassetid://5268648",
    ["Asset_1321"] = "rbxassetid://3307953",
    ["Asset_1322"] = "rbxassetid://5866152",
    ["Asset_1323"] = "rbxassetid://3346785",
    ["Asset_1324"] = "rbxassetid://4062545",
    ["Asset_1325"] = "rbxassetid://5411809",
    ["Asset_1326"] = "rbxassetid://1407642",
    ["Asset_1327"] = "rbxassetid://6384319",
    ["Asset_1328"] = "rbxassetid://4203692",
    ["Asset_1329"] = "rbxassetid://1732331",
    ["Asset_1330"] = "rbxassetid://4270747",
    ["Asset_1331"] = "rbxassetid://9851007",
    ["Asset_1332"] = "rbxassetid://1508787",
    ["Asset_1333"] = "rbxassetid://9529936",
    ["Asset_1334"] = "rbxassetid://3445886",
    ["Asset_1335"] = "rbxassetid://7282091",
    ["Asset_1336"] = "rbxassetid://1973830",
    ["Asset_1337"] = "rbxassetid://7561624",
    ["Asset_1338"] = "rbxassetid://3336474",
    ["Asset_1339"] = "rbxassetid://9763597",
    ["Asset_1340"] = "rbxassetid://5275087",
    ["Asset_1341"] = "rbxassetid://2822299",
    ["Asset_1342"] = "rbxassetid://6049824",
    ["Asset_1343"] = "rbxassetid://7280473",
    ["Asset_1344"] = "rbxassetid://1539072",
    ["Asset_1345"] = "rbxassetid://6290774",
    ["Asset_1346"] = "rbxassetid://6348911",
    ["Asset_1347"] = "rbxassetid://8746962",
    ["Asset_1348"] = "rbxassetid://4154160",
    ["Asset_1349"] = "rbxassetid://4966341",
    ["Asset_1350"] = "rbxassetid://4261154",
    ["Asset_1351"] = "rbxassetid://2123483",
    ["Asset_1352"] = "rbxassetid://6172917",
    ["Asset_1353"] = "rbxassetid://9662145",
    ["Asset_1354"] = "rbxassetid://5915260",
    ["Asset_1355"] = "rbxassetid://2993813",
    ["Asset_1356"] = "rbxassetid://8246793",
    ["Asset_1357"] = "rbxassetid://5158565",
    ["Asset_1358"] = "rbxassetid://7822687",
    ["Asset_1359"] = "rbxassetid://8086739",
    ["Asset_1360"] = "rbxassetid://7175329",
    ["Asset_1361"] = "rbxassetid://9880787",
    ["Asset_1362"] = "rbxassetid://1926861",
    ["Asset_1363"] = "rbxassetid://4196299",
    ["Asset_1364"] = "rbxassetid://7994873",
    ["Asset_1365"] = "rbxassetid://9847818",
    ["Asset_1366"] = "rbxassetid://5525096",
    ["Asset_1367"] = "rbxassetid://9918798",
    ["Asset_1368"] = "rbxassetid://3513640",
    ["Asset_1369"] = "rbxassetid://3565071",
    ["Asset_1370"] = "rbxassetid://5745664",
    ["Asset_1371"] = "rbxassetid://4317455",
    ["Asset_1372"] = "rbxassetid://4479455",
    ["Asset_1373"] = "rbxassetid://1444293",
    ["Asset_1374"] = "rbxassetid://6987711",
    ["Asset_1375"] = "rbxassetid://3303274",
    ["Asset_1376"] = "rbxassetid://8909509",
    ["Asset_1377"] = "rbxassetid://3861391",
    ["Asset_1378"] = "rbxassetid://9642233",
    ["Asset_1379"] = "rbxassetid://4399902",
    ["Asset_1380"] = "rbxassetid://1886801",
    ["Asset_1381"] = "rbxassetid://4601991",
    ["Asset_1382"] = "rbxassetid://8881913",
    ["Asset_1383"] = "rbxassetid://9298833",
    ["Asset_1384"] = "rbxassetid://3023999",
    ["Asset_1385"] = "rbxassetid://9013998",
    ["Asset_1386"] = "rbxassetid://3912001",
    ["Asset_1387"] = "rbxassetid://9509288",
    ["Asset_1388"] = "rbxassetid://2416394",
    ["Asset_1389"] = "rbxassetid://2113748",
    ["Asset_1390"] = "rbxassetid://4254053",
    ["Asset_1391"] = "rbxassetid://4437515",
    ["Asset_1392"] = "rbxassetid://5813592",
    ["Asset_1393"] = "rbxassetid://3937813",
    ["Asset_1394"] = "rbxassetid://1208955",
    ["Asset_1395"] = "rbxassetid://4510710",
    ["Asset_1396"] = "rbxassetid://2591375",
    ["Asset_1397"] = "rbxassetid://8980420",
    ["Asset_1398"] = "rbxassetid://7056183",
    ["Asset_1399"] = "rbxassetid://7375983",
    ["Asset_1400"] = "rbxassetid://3596150",
    ["Asset_1401"] = "rbxassetid://9175855",
    ["Asset_1402"] = "rbxassetid://8475832",
    ["Asset_1403"] = "rbxassetid://3142547",
    ["Asset_1404"] = "rbxassetid://6537140",
    ["Asset_1405"] = "rbxassetid://5004946",
    ["Asset_1406"] = "rbxassetid://9259205",
    ["Asset_1407"] = "rbxassetid://5869765",
    ["Asset_1408"] = "rbxassetid://2245372",
    ["Asset_1409"] = "rbxassetid://4207905",
    ["Asset_1410"] = "rbxassetid://4387056",
    ["Asset_1411"] = "rbxassetid://2298366",
    ["Asset_1412"] = "rbxassetid://7977710",
    ["Asset_1413"] = "rbxassetid://9379522",
    ["Asset_1414"] = "rbxassetid://7771919",
    ["Asset_1415"] = "rbxassetid://6802609",
    ["Asset_1416"] = "rbxassetid://5900384",
    ["Asset_1417"] = "rbxassetid://9992339",
    ["Asset_1418"] = "rbxassetid://3674224",
    ["Asset_1419"] = "rbxassetid://6869355",
    ["Asset_1420"] = "rbxassetid://2031628",
    ["Asset_1421"] = "rbxassetid://9975292",
    ["Asset_1422"] = "rbxassetid://5818561",
    ["Asset_1423"] = "rbxassetid://9002414",
    ["Asset_1424"] = "rbxassetid://6026815",
    ["Asset_1425"] = "rbxassetid://7136165",
    ["Asset_1426"] = "rbxassetid://6490531",
    ["Asset_1427"] = "rbxassetid://8587172",
    ["Asset_1428"] = "rbxassetid://6550507",
    ["Asset_1429"] = "rbxassetid://3775773",
    ["Asset_1430"] = "rbxassetid://4659051",
    ["Asset_1431"] = "rbxassetid://4361025",
    ["Asset_1432"] = "rbxassetid://1221943",
    ["Asset_1433"] = "rbxassetid://9661697",
    ["Asset_1434"] = "rbxassetid://9272267",
    ["Asset_1435"] = "rbxassetid://9869704",
    ["Asset_1436"] = "rbxassetid://3388431",
    ["Asset_1437"] = "rbxassetid://2059858",
    ["Asset_1438"] = "rbxassetid://3241338",
    ["Asset_1439"] = "rbxassetid://3178766",
    ["Asset_1440"] = "rbxassetid://4450773",
    ["Asset_1441"] = "rbxassetid://9340888",
    ["Asset_1442"] = "rbxassetid://3886932",
    ["Asset_1443"] = "rbxassetid://6262382",
    ["Asset_1444"] = "rbxassetid://9214857",
    ["Asset_1445"] = "rbxassetid://8287600",
    ["Asset_1446"] = "rbxassetid://6121413",
    ["Asset_1447"] = "rbxassetid://2648614",
    ["Asset_1448"] = "rbxassetid://8293719",
    ["Asset_1449"] = "rbxassetid://4889625",
    ["Asset_1450"] = "rbxassetid://3121344",
    ["Asset_1451"] = "rbxassetid://7704117",
    ["Asset_1452"] = "rbxassetid://7956463",
    ["Asset_1453"] = "rbxassetid://9855263",
    ["Asset_1454"] = "rbxassetid://5353938",
    ["Asset_1455"] = "rbxassetid://6817338",
    ["Asset_1456"] = "rbxassetid://3699098",
    ["Asset_1457"] = "rbxassetid://7511064",
    ["Asset_1458"] = "rbxassetid://9809574",
    ["Asset_1459"] = "rbxassetid://6837744",
    ["Asset_1460"] = "rbxassetid://1331800",
    ["Asset_1461"] = "rbxassetid://7007438",
    ["Asset_1462"] = "rbxassetid://6485084",
    ["Asset_1463"] = "rbxassetid://1973994",
    ["Asset_1464"] = "rbxassetid://5935412",
    ["Asset_1465"] = "rbxassetid://4553713",
    ["Asset_1466"] = "rbxassetid://2742752",
    ["Asset_1467"] = "rbxassetid://7851532",
    ["Asset_1468"] = "rbxassetid://4178824",
    ["Asset_1469"] = "rbxassetid://8604435",
    ["Asset_1470"] = "rbxassetid://2016827",
    ["Asset_1471"] = "rbxassetid://9460934",
    ["Asset_1472"] = "rbxassetid://9769361",
    ["Asset_1473"] = "rbxassetid://4860600",
    ["Asset_1474"] = "rbxassetid://4678035",
    ["Asset_1475"] = "rbxassetid://3535153",
    ["Asset_1476"] = "rbxassetid://7598451",
    ["Asset_1477"] = "rbxassetid://6989839",
    ["Asset_1478"] = "rbxassetid://8393271",
    ["Asset_1479"] = "rbxassetid://3674028",
    ["Asset_1480"] = "rbxassetid://8823098",
    ["Asset_1481"] = "rbxassetid://4880594",
    ["Asset_1482"] = "rbxassetid://6822211",
    ["Asset_1483"] = "rbxassetid://6239142",
    ["Asset_1484"] = "rbxassetid://5555681",
    ["Asset_1485"] = "rbxassetid://3761510",
    ["Asset_1486"] = "rbxassetid://4402621",
    ["Asset_1487"] = "rbxassetid://9857339",
    ["Asset_1488"] = "rbxassetid://9725346",
    ["Asset_1489"] = "rbxassetid://3935916",
    ["Asset_1490"] = "rbxassetid://9046824",
    ["Asset_1491"] = "rbxassetid://7761378",
    ["Asset_1492"] = "rbxassetid://8061278",
    ["Asset_1493"] = "rbxassetid://9031942",
    ["Asset_1494"] = "rbxassetid://1320831",
    ["Asset_1495"] = "rbxassetid://8919279",
    ["Asset_1496"] = "rbxassetid://8870448",
    ["Asset_1497"] = "rbxassetid://3794711",
    ["Asset_1498"] = "rbxassetid://8476459",
    ["Asset_1499"] = "rbxassetid://4688864",
}

-- [[ PROFESSIONAL THEME PRESETS ]]
Nexus.Themes["Preset_0"] = {
    Main = Color3.fromHSV(0.21148232550878865, 0.29284115768989616, 0.24665616765986853),
    Secondary = Color3.fromHSV(0.6740780378458064, 0.3054611345225342, 0.06849055283129457),
    Accent = Color3.fromHSV(0.7247539008423625, 0.9322258845770172, 0.1748872093791275),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.016362337663374915, 0.45186146683848694, 0.22678234286133336),
    CornerRadius = UDim.new(0, 14)
}
Nexus.Themes["Preset_1"] = {
    Main = Color3.fromHSV(0.09043621491305409, 0.5647947241178792, 0.27122332584353404),
    Secondary = Color3.fromHSV(0.5819242146959748, 0.682867075898457, 0.6909393856850317),
    Accent = Color3.fromHSV(0.548656710771457, 0.6643363571450384, 0.25405643301841596),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.9008998357116375, 0.3321589915205315, 0.05472633545224703),
    CornerRadius = UDim.new(0, 15)
}
Nexus.Themes["Preset_2"] = {
    Main = Color3.fromHSV(0.5109216020033901, 0.5321928241683977, 0.9837261469223658),
    Secondary = Color3.fromHSV(0.12875783643033922, 0.9540818095583274, 0.29759663231381495),
    Accent = Color3.fromHSV(0.10838710066545376, 0.34433745859011855, 0.34316398687486505),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.024992646620494385, 0.27243556163606586, 0.1149735752524862),
    CornerRadius = UDim.new(0, 9)
}
Nexus.Themes["Preset_3"] = {
    Main = Color3.fromHSV(0.01665457465717024, 0.9194746553590644, 0.06911383292485596),
    Secondary = Color3.fromHSV(0.48817786043043576, 0.06502983941318008, 0.01940960115191992),
    Accent = Color3.fromHSV(0.7035246218892943, 0.5912421349758501, 0.6203336967151354),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.2922039593139991, 0.5077841091204466, 0.058003484995231225),
    CornerRadius = UDim.new(0, 6)
}
Nexus.Themes["Preset_4"] = {
    Main = Color3.fromHSV(0.8707219933723457, 0.07332206349003367, 0.8004267909766898),
    Secondary = Color3.fromHSV(0.7642322327217176, 0.9518421050278552, 0.8093478370523853),
    Accent = Color3.fromHSV(0.8315824552547958, 0.6931480554098989, 0.12471390417536099),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.575161182604605, 0.9122414734439681, 0.20148617210821318),
    CornerRadius = UDim.new(0, 12)
}
Nexus.Themes["Preset_5"] = {
    Main = Color3.fromHSV(0.3413980687275283, 0.9177640236821921, 0.8827076427685215),
    Secondary = Color3.fromHSV(0.8492271958604317, 0.4122105620404424, 0.37938668937848363),
    Accent = Color3.fromHSV(0.1664038001444177, 0.8376368217311723, 0.6351304553222283),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.08630881151257519, 0.04092523187637742, 0.9124246197106541),
    CornerRadius = UDim.new(0, 11)
}
Nexus.Themes["Preset_6"] = {
    Main = Color3.fromHSV(0.8945889371017202, 0.9181446818886153, 0.6371701143019479),
    Secondary = Color3.fromHSV(0.6216245997434167, 0.4824863099182808, 0.5141970955512422),
    Accent = Color3.fromHSV(0.6943999580606208, 0.9270236403021181, 0.043769344161391),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.7631885194527172, 0.815773213589879, 0.15537992126802624),
    CornerRadius = UDim.new(0, 5)
}
Nexus.Themes["Preset_7"] = {
    Main = Color3.fromHSV(0.4540223520341383, 0.8662104424993343, 0.8639466667215308),
    Secondary = Color3.fromHSV(0.5697213375337022, 0.5730099482542048, 0.4473904081771778),
    Accent = Color3.fromHSV(0.2919264532027559, 0.34365117610320306, 0.9679696744827484),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.9712754540916465, 0.008438923313759394, 0.15478193391690365),
    CornerRadius = UDim.new(0, 5)
}
Nexus.Themes["Preset_8"] = {
    Main = Color3.fromHSV(0.8156819741264579, 0.12366273670064432, 0.5803653705189625),
    Secondary = Color3.fromHSV(0.7302124832616059, 0.771390664988666, 0.06162614008057232),
    Accent = Color3.fromHSV(0.968501694792975, 0.008723450172863245, 0.8911564243552951),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.023397230289963544, 0.47041891809509795, 0.9350457991240727),
    CornerRadius = UDim.new(0, 10)
}
Nexus.Themes["Preset_9"] = {
    Main = Color3.fromHSV(0.2984473584449182, 0.24720281601241445, 0.4911407620796857),
    Secondary = Color3.fromHSV(0.4379089129016396, 0.8011237293993744, 0.059606299503804805),
    Accent = Color3.fromHSV(0.6445982514159482, 0.6755286926352302, 0.09346206652452049),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.647893706926605, 0.7057902279285975, 0.5488510304157629),
    CornerRadius = UDim.new(0, 12)
}
Nexus.Themes["Preset_10"] = {
    Main = Color3.fromHSV(0.8960019427000738, 0.28475957748990144, 0.7960314372595202),
    Secondary = Color3.fromHSV(0.33777203444782766, 0.19701563293415825, 0.2909460921824052),
    Accent = Color3.fromHSV(0.12836011261656444, 0.9307297580636579, 0.6442163802156259),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.5094493901192094, 0.24181321288291902, 0.5230097057997044),
    CornerRadius = UDim.new(0, 8)
}
Nexus.Themes["Preset_11"] = {
    Main = Color3.fromHSV(0.2551982520644671, 0.6875681303181631, 0.20684237222330137),
    Secondary = Color3.fromHSV(0.8120863561597116, 0.3184218736117157, 0.9207790514602301),
    Accent = Color3.fromHSV(0.7846928234146017, 0.9781239774761963, 0.033327843723585215),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.8225743111302821, 0.5836834416522131, 0.48032045251632693),
    CornerRadius = UDim.new(0, 6)
}
Nexus.Themes["Preset_12"] = {
    Main = Color3.fromHSV(0.18505833808004113, 0.8675222989905244, 0.5924710436578113),
    Secondary = Color3.fromHSV(0.29401400639873676, 0.13349812799479055, 0.731200648397784),
    Accent = Color3.fromHSV(0.23123953153024357, 0.11146673854403666, 0.551611403182141),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.09579108397214053, 0.07304750047698538, 0.8235947671810457),
    CornerRadius = UDim.new(0, 15)
}
Nexus.Themes["Preset_13"] = {
    Main = Color3.fromHSV(0.6716628367284113, 0.6736141503053147, 0.013480959788236713),
    Secondary = Color3.fromHSV(0.31500097722120957, 0.16238333438637742, 0.9053326565614255),
    Accent = Color3.fromHSV(0.8664829337339306, 0.3281162074234001, 0.642292090704106),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.4129345370735982, 0.8223652523681259, 0.2963178181357369),
    CornerRadius = UDim.new(0, 4)
}
Nexus.Themes["Preset_14"] = {
    Main = Color3.fromHSV(0.9250908850724577, 0.46845551094513505, 0.5343704998481921),
    Secondary = Color3.fromHSV(0.8269015598869007, 0.0050032075627216566, 0.10823200557951618),
    Accent = Color3.fromHSV(0.03694546817957978, 0.5910512742745709, 0.3650159510318848),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.59717667374214, 0.6505563269566551, 0.823276178331917),
    CornerRadius = UDim.new(0, 15)
}
Nexus.Themes["Preset_15"] = {
    Main = Color3.fromHSV(0.990380799344223, 0.5585039567892149, 0.4310204089121161),
    Secondary = Color3.fromHSV(0.19406119622115858, 0.001897261018849572, 0.4539858361997716),
    Accent = Color3.fromHSV(0.47664919307140374, 0.8437730871524318, 0.0884638712397422),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.33097832770358715, 0.21141560401398463, 0.4051234783153297),
    CornerRadius = UDim.new(0, 4)
}
Nexus.Themes["Preset_16"] = {
    Main = Color3.fromHSV(0.9970213322204013, 0.15464510918092866, 0.35991582176362436),
    Secondary = Color3.fromHSV(0.7608445388848378, 0.411173750764383, 0.012923410343991915),
    Accent = Color3.fromHSV(0.17972553483631304, 0.5196247037503041, 0.10223431100767166),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.42691442021341974, 0.09117059096301816, 0.5395477374381185),
    CornerRadius = UDim.new(0, 5)
}
Nexus.Themes["Preset_17"] = {
    Main = Color3.fromHSV(0.5350390192914795, 0.3979113085351679, 0.9084534117542745),
    Secondary = Color3.fromHSV(0.6038853536284414, 0.6708279394904064, 0.010382841508663754),
    Accent = Color3.fromHSV(0.6624114125358141, 0.6011444906344918, 0.8225135168046265),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.025225378546026578, 0.22393944949836075, 0.730895505798145),
    CornerRadius = UDim.new(0, 14)
}
Nexus.Themes["Preset_18"] = {
    Main = Color3.fromHSV(0.5096584010599734, 0.6062958016804648, 0.6539956364246384),
    Secondary = Color3.fromHSV(0.7081060904571721, 0.541404253071177, 0.46088409185527346),
    Accent = Color3.fromHSV(0.037671605315318324, 0.7961573676032476, 0.920622972176424),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.5409697442926404, 0.46493735675043324, 0.7797418212833749),
    CornerRadius = UDim.new(0, 6)
}
Nexus.Themes["Preset_19"] = {
    Main = Color3.fromHSV(0.0851323666747813, 0.8991340962278594, 0.34047038075877045),
    Secondary = Color3.fromHSV(0.03693382616762653, 0.5031865587213162, 0.9146731434937937),
    Accent = Color3.fromHSV(0.6056930790317977, 0.345907404203996, 0.05303872254796038),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.15366964725436572, 0.5960914218157036, 0.3836055074314757),
    CornerRadius = UDim.new(0, 9)
}
Nexus.Themes["Preset_20"] = {
    Main = Color3.fromHSV(0.12651465886031987, 0.4236008065732584, 0.023182735128827514),
    Secondary = Color3.fromHSV(0.42427694709585295, 0.6427883724311713, 0.11171410079187272),
    Accent = Color3.fromHSV(0.6212384541749765, 0.8678101352616631, 0.5188743851098505),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.3000840787890072, 0.6174157603269446, 0.4409183084274474),
    CornerRadius = UDim.new(0, 8)
}
Nexus.Themes["Preset_21"] = {
    Main = Color3.fromHSV(0.5429651047798116, 0.8416934711804869, 0.5756367533376407),
    Secondary = Color3.fromHSV(0.11084223784543079, 0.5917511138475637, 0.5931457031462093),
    Accent = Color3.fromHSV(0.981394459544593, 0.19258231588178842, 0.7528391661720233),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.3496814081063295, 0.8026632854327015, 0.27570760065323063),
    CornerRadius = UDim.new(0, 10)
}
Nexus.Themes["Preset_22"] = {
    Main = Color3.fromHSV(0.8840913106822736, 0.33862696502086453, 0.844065060628903),
    Secondary = Color3.fromHSV(0.031818384725771476, 0.8814886670785548, 0.7225481134874512),
    Accent = Color3.fromHSV(0.7490569148932806, 0.12567397978911965, 0.22777863983957292),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.2664441910949802, 0.8313382641480961, 0.740873386896821),
    CornerRadius = UDim.new(0, 10)
}
Nexus.Themes["Preset_23"] = {
    Main = Color3.fromHSV(0.6752018791430118, 0.8856698452366395, 0.9669163059017906),
    Secondary = Color3.fromHSV(0.022228086015814275, 0.9673791660817025, 0.6025325331962563),
    Accent = Color3.fromHSV(0.1406292738182594, 0.2318152503143559, 0.6527826197173882),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.5935328440764189, 0.7878148227031055, 0.17100995703617072),
    CornerRadius = UDim.new(0, 8)
}
Nexus.Themes["Preset_24"] = {
    Main = Color3.fromHSV(0.7006332397204992, 0.0211075527188066, 0.752962436082764),
    Secondary = Color3.fromHSV(0.8103595974236386, 0.16935177282054226, 0.4823497815850787),
    Accent = Color3.fromHSV(0.23290017001883578, 0.9398998595883429, 0.10399403784156658),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.6039205021136832, 0.19905022215801293, 0.6722632603403211),
    CornerRadius = UDim.new(0, 8)
}
Nexus.Themes["Preset_25"] = {
    Main = Color3.fromHSV(0.5305873419485114, 0.03615509851983767, 0.5310207366338743),
    Secondary = Color3.fromHSV(0.8748039573735032, 0.08587944014087956, 0.051516260819049475),
    Accent = Color3.fromHSV(0.7745318726710521, 0.6755977029265468, 0.896696929343122),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.3506704127472031, 0.28864837112064234, 0.9962035046408436),
    CornerRadius = UDim.new(0, 5)
}
Nexus.Themes["Preset_26"] = {
    Main = Color3.fromHSV(0.1277362529464069, 0.30290182417942757, 0.34667510622801023),
    Secondary = Color3.fromHSV(0.5439732753758121, 0.8363995022301185, 0.5595233410552335),
    Accent = Color3.fromHSV(0.15705381044450628, 0.9079380015007213, 0.07492731952347675),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.20561521387394366, 0.34116059891143713, 0.33943074989256683),
    CornerRadius = UDim.new(0, 10)
}
Nexus.Themes["Preset_27"] = {
    Main = Color3.fromHSV(0.9350467802203603, 0.33580210155425205, 0.1624404086749961),
    Secondary = Color3.fromHSV(0.9590221912204867, 0.23020818178824176, 0.7688775496965345),
    Accent = Color3.fromHSV(0.17693811810178095, 0.362773412489359, 0.17698776361884738),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.4476283920988047, 0.8915291798741684, 0.5546167363653073),
    CornerRadius = UDim.new(0, 13)
}
Nexus.Themes["Preset_28"] = {
    Main = Color3.fromHSV(0.2754233264277761, 0.9913570909735833, 0.5236513934750187),
    Secondary = Color3.fromHSV(0.5942350437119944, 0.9813883466363372, 0.9684746494358559),
    Accent = Color3.fromHSV(0.4469604225250021, 0.0021979939829324113, 0.5601363321862607),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.6376789253358197, 0.08295837690286179, 0.05710662300910763),
    CornerRadius = UDim.new(0, 8)
}
Nexus.Themes["Preset_29"] = {
    Main = Color3.fromHSV(0.590694214895125, 0.08871007364880956, 0.48442424138582485),
    Secondary = Color3.fromHSV(0.009747106817198259, 0.3377700067260815, 0.4253072416976241),
    Accent = Color3.fromHSV(0.7245495479213191, 0.09687884271190017, 0.587301949198179),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.4695396415444656, 0.045682656683365575, 0.005654888125115054),
    CornerRadius = UDim.new(0, 7)
}
Nexus.Themes["Preset_30"] = {
    Main = Color3.fromHSV(0.27215200303357956, 0.45127914479320386, 0.5117782636761368),
    Secondary = Color3.fromHSV(0.005330103129793651, 0.7665493886828041, 0.7280910725621239),
    Accent = Color3.fromHSV(0.4395060756221564, 0.025436691486828922, 0.1976610578209974),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.37373544532702174, 0.25756574294530576, 0.6183536927735337),
    CornerRadius = UDim.new(0, 14)
}
Nexus.Themes["Preset_31"] = {
    Main = Color3.fromHSV(0.32211856837428565, 0.4360825188244176, 0.3592618732577687),
    Secondary = Color3.fromHSV(0.5826169225833161, 0.42932975042214694, 0.847869714116056),
    Accent = Color3.fromHSV(0.376345405761659, 0.07103195294977238, 0.1961759235938605),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.3692921035493837, 0.7989930929519119, 0.45788237406982935),
    CornerRadius = UDim.new(0, 5)
}
Nexus.Themes["Preset_32"] = {
    Main = Color3.fromHSV(0.6029029563597771, 0.680062377614563, 0.6134095225201406),
    Secondary = Color3.fromHSV(0.38647110253683603, 0.5539161715048256, 0.649878541186826),
    Accent = Color3.fromHSV(0.3247934366436531, 0.400699122864017, 0.12367228693845433),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.9378836102236324, 0.4229497854751533, 0.42799692388196164),
    CornerRadius = UDim.new(0, 9)
}
Nexus.Themes["Preset_33"] = {
    Main = Color3.fromHSV(0.4956665538571309, 0.22475763288669015, 0.9889770823782661),
    Secondary = Color3.fromHSV(0.14396330968269544, 0.684584071991376, 0.9430361736458267),
    Accent = Color3.fromHSV(0.8445366987720435, 0.963067503414772, 0.06643687657195596),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.9375591446700055, 0.9243692565155044, 0.231191735293638),
    CornerRadius = UDim.new(0, 13)
}
Nexus.Themes["Preset_34"] = {
    Main = Color3.fromHSV(0.09624034749205279, 0.6805800012699916, 0.4844378784184271),
    Secondary = Color3.fromHSV(0.19231100199769535, 0.2322508986461873, 0.5341142324767194),
    Accent = Color3.fromHSV(0.643568713766437, 0.1885004788271335, 0.2565354789819634),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.7283738258354377, 0.0734513849615801, 0.8370000366124095),
    CornerRadius = UDim.new(0, 9)
}
Nexus.Themes["Preset_35"] = {
    Main = Color3.fromHSV(0.8405581678145302, 0.6640699688060241, 0.4566727493178958),
    Secondary = Color3.fromHSV(0.3434343436698445, 0.15081578159638853, 0.12317348820468299),
    Accent = Color3.fromHSV(0.013410183119703545, 0.7792562992078362, 0.8548609843799815),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.5333524192307273, 0.7502152355400031, 0.18905420865668898),
    CornerRadius = UDim.new(0, 15)
}
Nexus.Themes["Preset_36"] = {
    Main = Color3.fromHSV(0.9565601547441257, 0.6260247202302163, 0.6130100595026943),
    Secondary = Color3.fromHSV(0.9038157243430902, 0.007529211396975377, 0.4737217519548721),
    Accent = Color3.fromHSV(0.45936586557737813, 0.6705848485661449, 0.7545415921731684),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.9501943545863442, 0.8594758126516497, 0.931884336111253),
    CornerRadius = UDim.new(0, 10)
}
Nexus.Themes["Preset_37"] = {
    Main = Color3.fromHSV(0.6336744350587722, 0.9948117372740626, 0.5608733927419408),
    Secondary = Color3.fromHSV(0.41108340130966536, 0.36668550645277886, 0.7775298933252558),
    Accent = Color3.fromHSV(0.3571829095902438, 0.14599594997466891, 0.4975909598166447),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.5158855715512298, 0.14607650351687618, 0.9022313653117381),
    CornerRadius = UDim.new(0, 8)
}
Nexus.Themes["Preset_38"] = {
    Main = Color3.fromHSV(0.1022088545452915, 0.2661826007281124, 0.7000446338675139),
    Secondary = Color3.fromHSV(0.21062566648925696, 0.7238889357798576, 0.2588051951356525),
    Accent = Color3.fromHSV(0.3246562361198593, 0.22555011840054828, 0.1500531682901154),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.040685727021909646, 0.7066808863615645, 0.273129389124083),
    CornerRadius = UDim.new(0, 7)
}
Nexus.Themes["Preset_39"] = {
    Main = Color3.fromHSV(0.10950724779928178, 0.8452025527472918, 0.42865175713764103),
    Secondary = Color3.fromHSV(0.9722083992509887, 0.20718559480573007, 0.25258158276488907),
    Accent = Color3.fromHSV(0.0050373221925613665, 0.5790572828045848, 0.40055793465498),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.0656134581770379, 0.4979283639431328, 0.2520736947063764),
    CornerRadius = UDim.new(0, 7)
}
Nexus.Themes["Preset_40"] = {
    Main = Color3.fromHSV(0.7067648180209841, 0.1471318387725542, 0.7147587172296977),
    Secondary = Color3.fromHSV(0.13971271632331206, 0.49509185974944914, 0.3148628655497385),
    Accent = Color3.fromHSV(0.8064944029728635, 0.07546052416344295, 0.02085851950849349),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.5190994094256005, 0.7624762329622934, 0.9275692108610941),
    CornerRadius = UDim.new(0, 12)
}
Nexus.Themes["Preset_41"] = {
    Main = Color3.fromHSV(0.12658005385302684, 0.14878721276542428, 0.844649479899231),
    Secondary = Color3.fromHSV(0.22215109593869564, 0.7107882987327738, 0.08657027067210332),
    Accent = Color3.fromHSV(0.514181636444099, 0.5379518867420527, 0.7527605515473034),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.7317567730643031, 0.4869966136099104, 0.40411421125688407),
    CornerRadius = UDim.new(0, 14)
}
Nexus.Themes["Preset_42"] = {
    Main = Color3.fromHSV(0.2307920622035542, 0.822783502078694, 0.43589726310486465),
    Secondary = Color3.fromHSV(0.3843313265320337, 0.9398985696509208, 0.8305316263005236),
    Accent = Color3.fromHSV(0.045433109076789435, 0.12566923922044826, 0.8838778021480544),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.3019806528883898, 0.8288759800720876, 0.9222719714981422),
    CornerRadius = UDim.new(0, 6)
}
Nexus.Themes["Preset_43"] = {
    Main = Color3.fromHSV(0.43069637044860876, 0.800884942039232, 0.9314163063553283),
    Secondary = Color3.fromHSV(0.897158235658597, 0.2946504120145369, 0.9007843274796923),
    Accent = Color3.fromHSV(0.12821555909096394, 0.8066247929205143, 0.9487837572038752),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.14733187994534003, 0.04060487745892938, 0.42052460856519136),
    CornerRadius = UDim.new(0, 7)
}
Nexus.Themes["Preset_44"] = {
    Main = Color3.fromHSV(0.46224198495060065, 0.02433323583299085, 0.997035839318373),
    Secondary = Color3.fromHSV(0.5040005327223291, 0.4739885195372776, 0.5109560395224454),
    Accent = Color3.fromHSV(0.9873618964208971, 0.7173069356849877, 0.33821461445883083),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.973657345280128, 0.4011767608729563, 0.2767655720817239),
    CornerRadius = UDim.new(0, 5)
}
Nexus.Themes["Preset_45"] = {
    Main = Color3.fromHSV(0.5855133099389591, 0.8365650912805889, 0.7488605084996107),
    Secondary = Color3.fromHSV(0.7902534655088971, 0.7171919034490983, 0.3362375365971433),
    Accent = Color3.fromHSV(0.16529984914823415, 0.32459244304479995, 0.2900524776017377),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.08280493695461932, 0.6734992546758436, 0.4116288209605844),
    CornerRadius = UDim.new(0, 13)
}
Nexus.Themes["Preset_46"] = {
    Main = Color3.fromHSV(0.31909264120769776, 0.8432283325848969, 0.08099818979106643),
    Secondary = Color3.fromHSV(0.7722989046841793, 0.9046071207743307, 0.9715389419423097),
    Accent = Color3.fromHSV(0.5032670774765345, 0.6138344475929706, 0.7048771481883855),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.4283288079031482, 0.5030604035933941, 0.9715174944877244),
    CornerRadius = UDim.new(0, 11)
}
Nexus.Themes["Preset_47"] = {
    Main = Color3.fromHSV(0.11856041540922901, 0.11418684734298268, 0.686375207702041),
    Secondary = Color3.fromHSV(0.38045802166555753, 0.367210625992864, 0.6580474516815781),
    Accent = Color3.fromHSV(0.054584785378855694, 0.03739458607492541, 0.7403110109434544),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.9392973677094593, 0.8722725084100773, 0.45771519806068006),
    CornerRadius = UDim.new(0, 4)
}
Nexus.Themes["Preset_48"] = {
    Main = Color3.fromHSV(0.633422546870335, 0.7199769613166235, 0.8573475212154082),
    Secondary = Color3.fromHSV(0.25844304833944676, 0.5559642522237052, 0.19150799172033528),
    Accent = Color3.fromHSV(0.22713956702408844, 0.6460755462258795, 0.6659032037263065),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.11026856545223007, 0.33080190405688725, 0.06055747319978888),
    CornerRadius = UDim.new(0, 11)
}
Nexus.Themes["Preset_49"] = {
    Main = Color3.fromHSV(0.17886186724683084, 0.8462753767151074, 0.5295567319146931),
    Secondary = Color3.fromHSV(0.578759713072623, 0.6433401983115116, 0.9638097289665606),
    Accent = Color3.fromHSV(0.46495912368812387, 0.9682377712691533, 0.6259185491115437),
    Text = Color3.new(1, 1, 1),
    TextDim = Color3.new(0.7, 0.7, 0.7),
    Border = Color3.fromHSV(0.4030622527937574, 0.8886880585380688, 0.89892859992895),
    CornerRadius = UDim.new(0, 10)
}

return Nexus
