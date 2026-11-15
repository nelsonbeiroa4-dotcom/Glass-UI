# Compatibility

Glass UI v0.3.0 is built on the upstream Obsidian UI Library and preserves its GUI parenting helpers, including `gethui`, `protectgui`, `syn.protect_gui` and `cloneref` where available, with upstream fallbacks.

## Executor recognition

Names recognized when returned by `identifyexecutor()` or `getexecutorname()`:

Xeno, Solara, Wave, Delta, Swift, Potassium, Synapse Z, SirHurt, Real, Cosmic, Volt, Velocity, Madium, Volcano, KRNL, Fluxus, Electron, Codex, Arceus X, Vega X, Ronix, Hydrogen, MacSploit, Opiumware, Appleware, Synapse X, Trigon and Script-Ware.

A few environment markers are also checked when identity functions are unavailable. Recognition does not mean every release has been runtime-tested.

## Blur behavior

Recognized executors do not receive an extra global blur. Unknown or unrecognized environments receive `Lighting.BlurEffect` while the window is visible. The effect is destroyed when the window is hidden or `Library:Unload()` is called.

The fallback blurs the entire 3D scene. Roblox's standard `ScreenGui` API does not expose a live backdrop blur clipped to the window rectangle. The glass appearance therefore uses tinted transparent surfaces, gradients and accent outlines.

## Notes

- `Library.Compatibility` exposes the detected name, version, recognition state, detection method and blur mode.
- SaveManager filesystem persistence depends on executor filesystem APIs.
- Not every listed executor build has been tested in a live Roblox session.
