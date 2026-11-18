# Glass UI

Glass UI is a glassmorphism-themed fork of [Obsidian UI Library](https://github.com/deividcomsono/Obsidian), preserving its real window, tab, groupbox, tabbox, control, notification, popup and interaction systems.

The visual core remains based on the previously working Obsidian-compatible build; Lonely applies its optional frosted-glass styling through a protected GUI descendant layer.

## Quick start

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nelsonbeiroa4-dotcom/Glass-UI/main/dist/GlassUI.lua"
))()

local Window = Library:CreateWindow({
    Title = "My Script",
    Footer = "Glass UI • RightControl to hide/show",
    Size = UDim2.fromOffset(960, 620),
    Center = true,
    AutoShow = true,
    Resizable = true,
})

local Main = Window:AddTab("Home", "house")
local General = Main:AddLeftGroupbox("General")

General:AddButton({
    Text = "Test notification",
    Func = function()
        Library:Notify("Glass UI is working.", 3)
    end,
})

General:AddToggle("Enabled", {
    Text = "Enable feature",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})
```

## Optional add-ons

ThemeManager and SaveManager remain separate modules, as in upstream Obsidian:

```lua
local Root = "https://raw.githubusercontent.com/nelsonbeiroa4-dotcom/Glass-UI/main/"

local Library = loadstring(game:HttpGet(Root .. "dist/GlassUI.lua"))()
local ThemeManager = loadstring(game:HttpGet(Root .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Root .. "addons/SaveManager.lua"))()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("GlassUI")
SaveManager:SetFolder("GlassUI")
```

Then apply them to a Settings tab:
```lua
local Settings = Window:AddTab("Settings", "settings")
ThemeManager:ApplyToTab(Settings)
SaveManager:BuildConfigSection(Settings)
```

## Included

- Obsidian's real window, tabs, key tabs, groupboxes, tabboxes and pop-outs.
- Search, dependencies, buttons, toggles, checkboxes, inputs, sliders, dropdowns, color pickers and key pickers.
- Notifications, dialogs, keybind menus, loading panels, tooltips and cursor support.
- Optional ThemeManager and SaveManager modules.
- Glass UI palette, translucent surfaces, gradients, rounded panels and accent outlines.
- Executor recognition for Xeno, Solara, Wave, Delta, Swift, Potassium, Synapse Z, SirHurt, Real, Cosmic, Volt, Velocity, Madium, Volcano, KRNL, Fluxus, Electron, Codex, Arceus X, Vega X, Ronix, Hydrogen, MacSploit, Opiumware, Appleware, Synapse X, Trigon and Script-Ware.

## Blur behavior

Recognized executor names do not receive a global blur. Unknown or unrecognized environments receive a `Lighting.BlurEffect` while the window is visible; it is removed when the window is hidden or unloaded.

This fallback blurs the entire 3D scene, not just the area behind the panel. Roblox's standard ScreenGui API does not expose a clipped live backdrop blur for one rectangular GUI. The normal glass look is therefore created with tinted transparency, gradients and borders.

Executor recognition uses `identifyexecutor()` or `getexecutorname()`, with a few environment markers as fallback. Recognition does not imply every build has been runtime-tested.

## Repository layout

- `src/GlassUI.lua` — readable source
- `dist/GlassUI.lua` — single-file distribution
- `addons/ThemeManager.lua` — Obsidian ThemeManager with Glass default palette
- `addons/SaveManager.lua` — Obsidian SaveManager
- `examples/CompleteExample.txt` — full example
- `docs/API.md` — API and usage notes
- `docs/Compatibility.md` — executor and blur behavior
- `docs/FeatureStatus.md` — feature coverage
- `LICENSE-OBSIDIAN` — upstream MIT license

## Credits

The core is based on [deividcomsono/Obsidian](https://github.com/deividcomsono/Obsidian) and retains its MIT licensing terms. This repository's changes focus on the Glass UI visual theme, window defaults and compatibility fallback.
