# Glass UI

Glass UI is a Roblox Luau interface library with a dark glassmorphism style. It uses translucent surfaces, restrained gradients and a compact two-column layout.

The library has its own implementation and does not require Potassium or Obsidian.

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

## Features in 0.2.3

- Draggable, resizable window with a compactable sidebar
- Tabs, key tabs, left/right groupboxes and nested tabboxes
- In-window text search
- Buttons, toggles, checkboxes, inputs, sliders and dropdowns
- Color pickers and key pickers
- Labels, dividers and dependency boxes
- Image, viewport, video and UI passthrough controls
- Notifications, dialogs, loading panels and watermarks
- SaveManager with config list, import/export, subfolders and autoload
- ThemeManager with built-in and custom palettes
- Optional executor capability detection and PlayerGui fallback
- Explicit cleanup through Library:Unload()

## Repository layout

- src/GlassUI.lua — readable source
- dist/GlassUI.lua — single-file loadstring distribution
- examples/CompleteExample.txt — full usage example
- docs/API.md — API reference
- docs/Compatibility.md — executor capability and fallback notes
- docs/FeatureStatus.md — implemented features and current boundaries
- CHANGELOG.md — release notes

## Compatibility

The GUI itself uses Roblox services. Executor-only APIs are optional. Filesystem persistence requires file APIs; without those, SaveManager stores settings in session memory and supports JSON import/export.

Compatibility is best-effort. Executors can expose different functions, restrict GUI parenting, or change HttpGet behavior. No library can guarantee identical behavior in every executor.

## Performance and visual design

The core does not run a permanent RenderStepped loop. It uses shared input listeners, short tweens and on-demand theme updates. Translucency, gradients and outlines provide a frosted-glass appearance. The library does not apply a global Lighting blur.

## Status

Glass UI is under active development. The API is independent and intended to grow through tested additions. This release is a functional baseline, not a promise of full one-to-one parity with every internal Obsidian feature. The compatibility and feature-status documents describe the current limits.
