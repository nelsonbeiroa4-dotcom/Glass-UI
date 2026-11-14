# Glass UI

A Roblox Luau interface library with a dark glassmorphism visual style. Compact navigation, translucent panels, restrained accents and a consistent control API.

Glass UI has its own implementation and does not require Potassium or Obsidian.

## Quick start

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nelsonbeiroa4-dotcom/Glass-UI/main/dist/GlassUI.lua"
))()

local Window = Library:CreateWindow({
    Title = "My Script",
    Size = UDim2.fromOffset(760, 550),
})

local Main = Window:AddTab("Main", "house")
local Group = Main:AddLeftGroupbox("General")

Group:AddToggle("Enabled", {
    Text = "Enable feature",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})

Group:AddButton("Notify", function()
    Library:Notify("Glass UI is ready.", 3)
end)

## Included in 0.1.0

- Window, tabs, left/right groupboxes and nested tabboxes
- Buttons, toggles, checkboxes, inputs and sliders
- Single and multi-select dropdowns
- Color pickers and key pickers
- Labels, dividers and dependency boxes
- Image, viewport, video and UI passthrough controls
- Notifications, dialogs, loading panels and watermarks
- Integrated SaveManager and ThemeManager
- Five built-in color palettes and runtime theme updates
- Optional executor capability detection
- Explicit cleanup through Library:Unload()

## Repository layout

- src/GlassUI.lua — readable source
- dist/GlassUI.lua — single-file loadstring distribution
- examples/CompleteExample.txt — full usage example
- docs/API.md — API guide
- docs/Compatibility.md — executor capability and fallback notes
- CHANGELOG.md — release notes

## Compatibility

The GUI itself uses Roblox services. Executor-only APIs are optional. Filesystem persistence requires file APIs; without those, SaveManager stores settings in session memory and supports JSON import/export.

Compatibility is best-effort. No single UI library can guarantee that every executor exposes the same functions or permits identical GUI parenting.

## Performance and visual design

The core does not run a permanent RenderStepped loop. It uses event-driven input, short tweens and on-demand theme updates. Translucency, gradients and outlines provide the glass effect without a continuous screen blur.

## Current status

This is the first public implementation baseline. The API is independent and intended to grow through tested additions. It does not claim complete one-to-one parity with every internal Obsidian feature yet. The compatibility guide lists the current boundaries.
