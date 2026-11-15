# Changelog

## 0.3.3

- Increased the translucency of theme-backed surfaces to match the glass treatment used in Lonely Spy.
- Added `Library.Compatibility.DisableGlobalBlur` so scripts with a local glass-blur implementation can disable the whole-scene fallback.

## 0.3.2

- Window, border and groupbox gradients now derive from the active scheme.
- ThemeManager palette changes recolor the glass gradients instead of leaving purple hard-coded gradients behind.
- Supports per-script startup palettes such as Lonely's original sage-green and Fantasy theme.

## 0.3.1

- Fixed the example's groupbox construction to match the actual Obsidian API.
- Added compatibility overloads so AddLeftGroupbox/AddRightGroupbox accept both Obsidian's string signature and an Info table.
- Enabled label text wrapping in the complete example to prevent narrow layouts from clipping descriptions.
- Increased the transparency of theme-colored surfaces so the glass effect is visible without sacrificing the dark palette.

## 0.3.0

- Rebased the library on the upstream Obsidian implementation instead of the incomplete custom UI.
- Restored Obsidian's actual window, tabs, groupboxes, tabboxes, controls, notifications, dialogs, keybind menus, search and interactions.
- Added a purple glassmorphism palette, translucent theme surfaces, dark gradients, neon accent border, rounded corners and more generous layout spacing.
- Changed default window size to 960×620 and adjusted sidebar width/tab spacing.
- Added ThemeManager and SaveManager modules based on the upstream add-ons.
- Added executor detection and a global blur fallback for unrecognized environments; cleanup runs when hidden or unloaded.
- Included the upstream MIT license as LICENSE-OBSIDIAN.

# Glass UI

## 0.2.8

- Fixed an extra `end` in `ThemeManager:ApplyThemeData()` that caused `Expected <eof>, got 'end'` during Luau parsing.
- Kept `src/GlassUI.lua` and `dist/GlassUI.lua` identical.

# Changelog

## 0.2.7

- Fixed the final Luau pcall argument-count diagnostic: string.gsub returns two values, so hex-color loading now calls Color3.fromHex inside a protected closure.
- Kept src and dist synchronized.

## 0.2.6

- Converted the remaining multi-argument pcall calls in autoload and theme JSON loading to closures.
- Rechecked the distribution for pcall calls with more than two arguments.

## 0.2.5

- Fixed Luau dynamic-table diagnostics for Library, Compat and Colors.
- Initialized executor detection before constructing the Compatibility table.
- Rewrote multi-argument JSON and file-write pcall calls as closures to avoid analyzer argument-count warnings.
- Kept src/GlassUI.lua and dist/GlassUI.lua synchronized.

## 0.2.4

- Added explicit executor identification using identifyexecutor/getexecutorname plus selected environment markers.
- Added a documented allowlist of recognized executor names and compatibility status fields.
- Added a global Lighting blur fallback for unrecognized environments while the GUI is visible; it is removed on close or unload.
- Added BlurEnabled and BlurSize CreateWindow options and functional Window:SetBlurEnabled/SetBlurSize methods.

## 0.2.3

- Removed the global Lighting BlurEffect introduced in 0.2.2.
- Kept the glass appearance local to the library window using tinted translucency and gradients.
- Documented the Roblox limitation around per-window live backdrop blur.

## 0.2.2

- Added a real Lighting BlurEffect behind the UI while the window is visible.
- Blur strength animates on open/close and the effect is removed on unload.
- Increased the opacity of glass surfaces so the interface stays readable over bright scenes.


## 0.2.1

- Fixed child layout inside input, slider and dropdown controls.
- Fixed labels and buttons added to nested tab pages.
- Added drag behavior to floating text and image buttons.
- Made autoload configuration respect the current subfolder.
- Made dependency visibility survive an empty or active search query.
- Added the direct Library:SetBackgroundImage helper and refined floating UI APIs.


## 0.2.1

- Fixed vertical layout for controls containing more than one child.
- Fixed controls added inside nested tab pages.
- Added drag support for floating text and image buttons.
- Made autoload files respect the selected configuration subfolder.

## 0.2.0

- Added an in-window control search field.
- Added window resizing and sidebar compact mode.
- Improved configuration browsing, deletion and autoload controls.
- Added custom-theme selection, deletion and default-theme persistence.
- Improved live theme repainting for already-created controls.
- Added floating buttons and basic hover tooltips.
- Fixed default subfolder handling and corrected the Violet theme outline color.
- Expanded API, compatibility and feature-status documentation.

## 0.1.0

- Initialized the Glass UI repository.
- Added a single-file distribution and readable source.
- Added window, tabs, groupboxes and nested tabboxes.
- Added the main interactive controls and media holders.
- Added notifications, dialogs, loading panel and watermark.
- Added integrated SaveManager and ThemeManager.
- Added optional executor capability detection and a PlayerGui fallback.
