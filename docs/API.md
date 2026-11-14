# Glass UI API

Glass UI is a Roblox Luau interface library with a dark glassmorphism visual system. It is intentionally independent of Potassium and Obsidian.

## Loading

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/OWNER/REPOSITORY/main/dist/GlassUI.lua"
))()

## Window

local Window = Library:CreateWindow({
    Title = "My interface",
    Footer = "Build 0.1.0",
    Size = UDim2.fromOffset(760, 550),
    Position = UDim2.fromScale(0.5, 0.5),
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
    CloseButtonDestroys = false,
})

Window:AddTab(name, icon, description)
Window:AddKeyTab(name, icon, description)
Window:Toggle(boolean?)
Window:SetTitle(text)
Window:SetFooter(text)
Window:SetBackgroundImage(asset)

Tabs:
- AddLeftGroupbox(name, icon?, visible?, collapsed?, disableCollapsing?)
- AddRightGroupbox(name, icon?, visible?, collapsed?, disableCollapsing?)
- AddGroupbox({ Name, Side, IconName, Visible, Collapsed, DisableCollapsing })
- AddLeftTabbox(name) / AddRightTabbox(name)
- SetVisible(boolean), Show(), Hide()

## Controls

Indexed options are available through Library.Options[index] or Library.Toggles[index]. Most options expose SetValue, OnChanged, SetVisible, SetDisabled and Destroy.

### Toggle and checkbox

group:AddToggle("Enabled", {
    Text = "Enable feature",
    Default = false,
    Callback = function(value) end,
    Changed = function(value) end,
})
group:AddCheckbox("Enabled", { Text = "Enable feature", Default = false })

Toggles support addons:
- toggle:AddColorPicker(index, info)
- toggle:AddKeyPicker(index, info)

### Button

group:AddButton("Run", function() end)
group:AddButton({ Text = "Run", Callback = function() end })

### Input

group:AddInput("Name", {
    Text = "Player name",
    Default = "",
    Placeholder = "Type here",
    Numeric = false,
    Finished = true,
    ClearTextOnFocus = false,
    Callback = function(value) end,
    VerifyValue = function(value) return true end,
})

### Slider

group:AddSlider("Amount", {
    Text = "Amount",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Prefix = "",
    Suffix = "%",
    Callback = function(value) end,
})

### Dropdown

group:AddDropdown("Mode", {
    Text = "Mode",
    Values = { "One", "Two", "Three" },
    Default = "One",
    Multi = false,
    DisabledValues = {},
    Callback = function(value) end,
})

For multi dropdowns, the callback receives an array. Runtime helpers include SetValues, AddValues, SetDisabledValues and AddDisabledValues.

### Color picker

group:AddColorPicker("Tint", {
    Title = "Tint",
    Default = Color3.fromRGB(191, 91, 255),
    Transparency = 0,
    Callback = function(color, transparency) end,
})

Methods: SetValue(Color3), SetValueRGB(Color3, transparency), SetTransparency(number).

### Key picker

group:AddKeyPicker("ToggleKey", {
    Text = "Toggle key",
    Default = "G",
    Mode = "Toggle", -- Always, Toggle or Hold
    Callback = function(active) end,
})

Click the key field and press a key to rebind it.

### Labels, layout and media

- AddLabel(textOrInfo, wrap?)
- AddDivider(text?)
- AddImage(index, { Image, Height, Transparency, Color, ScaleType })
- AddViewport(index, { Object, Clone, Height })
- AddVideo(index, { Video, Playing, Looped, Volume, Height })
- AddUIPassthrough(index, { Instance, Height })
- AddDependencyBox() / AddDependencyGroupbox(), followed by SetupDependencies({ { option, expectedValue } })

The caller must supply valid Roblox assets and Instances for media controls, and must respect Roblox content permissions.

## Notifications, dialogs and loading

Library:Notify({ Title, Description, Time })
Library:Notify("Message", 4)

local dialog = Window:AddDialog("Confirm", {
    Title = "Confirm action",
    Description = "Continue?",
    ConfirmText = "Continue",
    Callback = function() end,
    CancelText = "Cancel",
    OutsideClickDismiss = true,
})
dialog:Dismiss()

local loading = Library:CreateLoading({
    Title = "Working",
    Description = "Please wait",
    TotalSteps = 5,
})
loading:SetStep(2, 5)
loading:SetMessage("Almost done")
loading:Destroy()

## Watermark and floating UI

local watermark = Library:CreateWatermark({
    Text = "My script",
    Visible = true,
})
watermark:SetText("Updated")
watermark:SetVisible(false)
watermark:SetPosition(UDim2.fromOffset(20, 20))

Library:AddDraggableLabel("My script")
Library:AddDraggableButton("Action", function() end)
Library:AddTooltip("Tooltip text", nil, someGuiObject)

## Themes

Library:SetTheme({ AccentColor = Color3.fromRGB(255, 80, 220) })
Library:SetAccentColor(Color3.fromRGB(255, 80, 220))
Library:SetFont(Enum.Font.Gotham)

Library.ThemeManager:ApplyTheme("Violet")
Library.ThemeManager:ApplyToTab(settingsTab)
Library.ThemeManager:SaveCustomTheme("My theme")
Library.ThemeManager:SetDefaultTheme("Violet")
Library.ThemeManager:LoadDefault()

Built-in themes: Violet, Rose, Ocean, Midnight and Mint. Theme colors may be represented as Color3 values or hexadecimal strings in JSON.

## Configurations

local SaveManager = Library.SaveManager
SaveManager:SetFolder("MyScript/Configs")
SaveManager:Save("Legit")
SaveManager:Load("Legit")
SaveManager:Delete("Legit")
SaveManager:RefreshConfigList()
local json = SaveManager:ExportJSON("Legit")
SaveManager:ImportJSON(json)
SaveManager:SaveAutoloadConfig("Legit")
SaveManager:LoadAutoloadConfig()
SaveManager:SetIgnoreIndexes({ "TemporaryOption" })
SaveManager:BuildConfigSection(settingsTab)

When executor file APIs are missing, SaveManager falls back to session memory. Those in-memory settings do not survive a script unload or game restart. JSON import/export remains available.

## Lifecycle

Library:OnUnload(function() end)
Library:Toggle()
Library:Unload()

Unload disconnects shared input connections, destroys the ScreenGui and clears internal registries.

## Release boundary

This is the initial public implementation baseline, not a claim of one-to-one parity with every internal Obsidian behavior. Only the methods listed in this guide should be considered part of the current supported API. Further features should be added through tested releases.
