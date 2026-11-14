# Compatibility notes

Glass UI is designed to run without Potassium and uses Roblox GUI primitives for its core interface.

## Standard Roblox layer

The window, tabs, groupboxes, buttons, toggles, inputs, sliders, dropdowns, color pickers, key pickers, notifications, dialogs and watermark use Roblox services and Instances.

## Recognized executors

Glass UI detects the executor using identifyexecutor() or its getexecutorname() alias. If neither is available, it checks selected executor-specific environment markers.

The name allowlist currently recognizes: Xeno, Solara, Wave, Delta, Swift, Potassium, Synapse Z, SirHurt, Real, Cosmic, Volt, Velocity, Madium, Volcano, KRNL, Fluxus, Electron, Codex, Arceus X, Vega X, Ronix, Hydrogen, MacSploit, Opiumware and Appleware. Legacy names Synapse X, Trigon and Script-Ware are also recognized for older environments.

This is name detection, not a guarantee that every version has been tested or that every executor capability is present. Detected values are available as Library.Compatibility.ExecutorName, ExecutorVersion, IsSupported and DetectionMethod. A new or renamed executor may be reported as Unknown until added.

## Optional executor features

| Capability | Behavior |
| --- | --- |
| gethui | Used when available; otherwise the library tries CoreGui and falls back to PlayerGui. |
| protectgui / syn.protect_gui | Called only when exposed. |
| writefile / readfile | Enables durable JSON configs and custom themes. |
| listfiles / delfile | Enables config browsing and deletion. |
| setclipboard | Best-effort clipboard export. |
| isfile / isfolder / makefolder | Used for file and folder checks. |

No library can guarantee identical behavior with every executor. A recognized name does not guarantee that a particular build exposes every optional function. Executors may omit APIs, rename functions, restrict GUI parenting, or change HttpGet behavior.

## Persistence fallback

When filesystem functions are missing, SaveManager retains configuration JSON in session memory. ExportJSON and ImportJSON remain usable. In-memory configs disappear when the script or session ends.

## Blur behavior

Roblox does not provide a CSS-style backdrop-filter for an individual ScreenGui or GuiObject. A BlurEffect is parented to Lighting and blurs the whole 3D scene.

- Recognized executors: no global BlurEffect is created. Glass UI keeps its translucent tint, gradients and outlines.
- Unknown or unrecognized environments: a BlurEffect is created when the window opens and removed when it closes or Library:Unload() runs. This is a whole-game blur, not a local window blur.
- Set BlurEnabled = false in CreateWindow options (or call Window:SetBlurEnabled(false)) to opt out. BlurSize defaults to 18 and can be changed with Window:SetBlurSize(number).

A truly clipped live-scene blur would require a separate rendering/capture pipeline that the standard GUI API does not expose.

## Performance

- No permanent RenderStepped loop is used by the core UI.
- Dragging, resizing and key handling use shared input listeners.
- Notifications clean themselves up after their timeout.
- Theme bindings update on demand.
- Library:Unload disconnects shared listeners and destroys the GUI.
- Frosted glass is simulated with translucency, gradients and outlines. Roblox does not expose a per-window backdrop-filter equivalent for ScreenGui.

See FeatureStatus.md for the current implementation boundary.
