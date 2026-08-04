-- MANUS UI ULTIMATE - THE KITCHEN SINK EXAMPLE
-- This script demonstrates every single feature and component of the library.

local cloneref = cloneref or function(obj) return obj end
local Manus = require(game:GetService("ReplicatedStorage"):WaitForChild("ManusUILib_Ultimate"))

-- [ INITIALIZATION ]
local Window = Manus:CreateWindow({
    Name = "Manus Ultimate Hub",
    Logo = "rbxassetid://6031070977",
    Size = UDim2.new(0, 750, 0, 500)
})

-- [ TABS ]
local HomeTab = Window:CreateTab("Home", Manus.Assets.Icons.Home)
local ComponentsTab = Window:CreateTab("Components", Manus.Assets.Icons.Layout)
local VisualsTab = Window:CreateTab("Visuals", Manus.Assets.Icons.Image)
local AdvancedTab = Window:CreateTab("Advanced", Manus.Assets.Icons.Zap)
local SettingsTab = Window:CreateTab("Settings", Manus.Assets.Icons.Settings)

-- [ HOME TAB ]
local WelcomeSection = HomeTab:CreateSection("Welcome to Ultimate")
WelcomeSection:CreateSkeleton(60) -- Loading placeholder
task.delay(1.5, function()
    WelcomeSection:CreateButton("Quick Start", "Get started with Manus Ultimate", function()
        Manus:Notify({Title = "Success", Text = "You are now using the most advanced UI system.", Type = "Success"})
    end)
end)

WelcomeSection:CreateParagraph("Manus Ultimate is a <b>high-performance</b>, <b>feature-rich</b> UI framework designed for professional Roblox development. It supports everything from basic buttons to complex data visualization.", {})

local StatsSection = HomeTab:CreateSection("Real-time Analytics")
StatsSection:CreateGraph("Network Traffic", {10, 25, 15, 40, 30, 60, 45, 80})
StatsSection:CreatePieChart("Resource Allocation", {40, 30, 20, 10})

-- [ COMPONENTS TAB ]
local InputSection = ComponentsTab:CreateSection("Input Elements")
InputSection:CreateToggle("Auto-Execute", "Automatically run scripts", true, function(s) print("Auto-Exec:", s) end)
InputSection:CreateCheckbox("Silent Mode", "Disable all sound effects", false, function(s) print("Silent:", s) end)
InputSection:CreateSlider("Field of View", 30, 120, 70, function(v) workspace.CurrentCamera.FieldOfView = v end)
InputSection:CreateRangeSlider("Level Range", 1, 100, 20, 80, function(l, h) print("Range:", l, h) end)

local SelectionSection = ComponentsTab:CreateSection("Selection & Lists")
SelectionSection:CreateDropdown("Select Region", {"North America", "Europe", "Asia", "South America", "Australia"}, function(r) print("Region:", r) end)
SelectionSection:CreateMultiDropdown("Select Mods", {"Fly", "Noclip", "God Mode", "Speed", "Jump"}, {"Speed"}, function(m) print("Mods:", table.concat(m, ", ")) end)
SelectionSection:CreateKeybindList("Controls", {
    ["Open Menu"] = Enum.KeyCode.RightControl,
    ["Fly"] = Enum.KeyCode.F,
    ["Noclip"] = Enum.KeyCode.N
})

-- [ VISUALS TAB ]
local MediaSection = VisualsTab:CreateSection("Media & Colors")
MediaSection:CreateColorPicker("Accent Color", Manus.CurrentTheme.Accent, function(c)
    print("New Color:", c)
end)
MediaSection:CreateVideo("Tutorial Video", "rbxassetid://5608327215")

local DisplaySection = VisualsTab:CreateSection("Custom Displays")
local grid = DisplaySection:CreateGrid("Feature Grid", 3)
for i = 1, 6 do
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Manus.CurrentTheme.Tertiary
    Instance.new("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = card
    Instance.new("TextLabel", {
        Text = "Card " .. i,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Manus.CurrentTheme.Text,
        Parent = card
    })
    grid:AddElement(card)
end

-- [ ADVANCED TAB ]
local UtilitySection = AdvancedTab:CreateSection("Utility Systems")
UtilitySection:CreateButton("Trigger Modal", "Show a complex dialog", function()
    local modal = Window:CreateModal({
        Title = "Dangerous Action",
        Text = "Are you sure you want to delete all local data? This action cannot be undone.",
        Buttons = {
            {Text = "Cancel", Type = "Secondary"},
            {Text = "Delete", Type = "Primary"}
        }
    })
    modal:Connect(function(choice)
        Manus:Notify("You chose: " .. choice)
    end)
end)

UtilitySection:CreateButton("Show Toast", nil, function()
    Manus:Toast("Settings applied successfully!")
end)

local LogicSection = AdvancedTab:CreateSection("Logic & Persistence")
LogicSection:CreateDatePicker("Schedule Event", function(d) print("Date selected:", d) end)
LogicSection:CreateButton("Save Current Config", nil, function()
    Window.Config.LastUsed = os.date()
    Manus:SaveConfig("UltimateHub", Window.Config)
end)

-- [ SETTINGS TAB ]
local AppearanceSection = SettingsTab:CreateSection("Appearance")
AppearanceSection:CreateDropdown("Select Theme", {"Default", "Midnight", "Custom"}, function(t)
    if t == "Custom" then
        Manus.CurrentTheme = Manus:GenerateTheme(Color3.fromRGB(255, 100, 0))
    else
        Manus.CurrentTheme = Manus.Themes[t]
    end
    Manus:Notify("Theme updated to " .. t)
end)

AppearanceSection:CreateSlider("UI Transparency", 0, 100, 0, function(v)
    Window:SetTransparency(v / 100)
end)

local LangSection = SettingsTab:CreateSection("Localization")
LangSection:CreateDropdown("Select Language", {"EN", "ES", "FR", "DE", "ZH", "JA"}, function(l)
    Manus:SetLanguage(l)
end)

-- [ GLOBAL KEYBINDS ]
Manus:RegisterKeybind(Enum.KeyCode.P, function()
    Manus:Notify("Global Hotkey P Pressed!")
end)

Manus:Notify({
    Title = "Ready",
    Text = "Manus Ultimate is fully loaded and ready.",
    Type = "Success"
})
