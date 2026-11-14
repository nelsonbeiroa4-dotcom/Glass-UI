# Changelog

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
