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
| listfiles / delfile | Enables config browsing and deletion. |
| setclipboard | Best-effort clipboard export. |
| isfile / isfolder / makefolder | Used for file and folder checks. |

No library can guarantee compatibility with every executor. Executors may omit functions, rename APIs, restrict GUI parenting, or change HttpGet behavior.

## Persistence fallback

When filesystem functions are missing, SaveManager retains configuration JSON in session memory. ExportJSON and ImportJSON remain usable. In-memory configs disappear when the script or session ends.

## Local backdrop blur

Roblox does not provide a CSS-style backdrop-filter for an individual ScreenGui or GuiObject. BlurEffect is parented to Lighting and therefore blurs the whole 3D scene, not only the pixels behind one window. Glass UI deliberately does not create a BlurEffect, because doing so would blur the entire game. Its glass appearance is built from translucent surfaces, tint, gradients and outlines. A true clipped live-scene blur would require a separate rendering/capture pipeline that the standard GUI API does not expose.

## Performance

- No permanent RenderStepped loop is used by the core UI.
- Dragging, resizing and key handling use shared input listeners.
- Notifications clean themselves up after their timeout.
- Theme bindings update on demand.
- Library:Unload disconnects shared listeners and destroys the GUI.
- Frosted glass is simulated with translucency, gradients and outlines. Roblox does not expose a per-window backdrop-filter equivalent for ScreenGui.

See FeatureStatus.md for the current implementation boundary.
