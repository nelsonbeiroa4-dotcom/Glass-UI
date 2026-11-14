# Compatibility notes

Glass UI is designed to run without Potassium and uses Roblox GUI primitives for its core interface.

## Standard Roblox layer

The window, tabs, groupboxes, buttons, toggles, inputs, sliders, dropdowns, color pickers, key pickers, notifications, dialogs and watermark use Roblox services and Instances.

## Optional executor features

| Capability | Behavior |
| --- | --- |
| gethui | Used when available; otherwise the library tries CoreGui and falls back to PlayerGui. |
| protectgui / syn.protect_gui | Called only when exposed. |
| writefile / readfile | Enables durable JSON configs and custom themes. |
| listfiles / delfile | Enables config listing and deletion. |
| setclipboard | Best-effort clipboard export. |
| isfile / isfolder / makefolder | Used for safe folder and file checks. |

No library can guarantee compatibility with every executor. Executors may omit functions, rename APIs, restrict GUI parenting, or change HttpGet behavior.

## Persistence fallback

When filesystem functions are missing, SaveManager retains configuration JSON in session memory. ExportJSON and ImportJSON remain usable. In-memory configs disappear when the script or session ends.

## Performance

- No permanent RenderStepped loop is used by the core UI.
- Dragging and key handling use shared input listeners.
- Notifications clean themselves up after their timeout.
- Theme bindings update on demand.
- Library:Unload disconnects shared listeners and destroys the GUI.
- Frosted glass is simulated with translucency, gradients and outlines. Roblox does not expose a per-window backdrop-filter equivalent for ScreenGui.

## Known limitations in 0.1.0

- The initial color picker supports hex entry and hue selection; it is not yet a full saturation/value editor.
- Video playback depends on a valid Roblox Video asset and platform support.
- The current window has a fixed initial size and does not yet include the full Obsidian resize/snap/sidebar-compaction system.
- Search, context-menu parity, advanced keybind modifiers, full keyboard-menu features and animated loading-step sidebars are not part of this baseline.
- Custom-theme file discovery is currently limited; built-in presets and themes created in the current session are available directly.
