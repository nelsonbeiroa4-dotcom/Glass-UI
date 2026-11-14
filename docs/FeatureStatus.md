# Feature status — 0.2.0

This file is the source of truth for what the current public distribution actually includes. An API name in an old script or in the Obsidian reference does not imply that Glass UI implements the same behavior.

## Implemented

- Single-window creation, header dragging and lower-right resizing
- Sidebar tabs, key-tab alias, two-column groupboxes and collapsible groupbox content
- Nested tabboxes
- Simple case-insensitive control search
- Buttons, toggles, checkboxes, text inputs, sliders and single/multi dropdowns
- Hex/hue color picker, key picker, labels and dividers
- Dependency boxes with value matching
- Image, viewport, video and UI passthrough holders
- Notifications, dialogs, loading panel and draggable watermark
- Draggable floating button and basic hover tooltip
- SaveManager: JSON save/load/delete, config listing, import/export, autoload and ignored indexes
- ThemeManager: built-in palettes, custom theme save/load/delete and default theme selection
- Optional executor capability detection and cleanup on unload

## Simplified implementations

- Search is substring-based. It is not Obsidian's fuzzy/global search engine.
- The color picker has hex editing and hue selection; it does not yet have a full saturation/value plane or alpha bar.
- Key pickers support one key and basic Always, Toggle and Hold modes. Modifier combinations, blacklists, whitelists, Press mode and the full keybind menu are not included.
- Notifications support title, description and duration. Persistent cards, progress steps, icons, audio and advanced positioning are not included.
- Loading is a compact progress card. It does not reproduce Obsidian's multi-page loader/sidebar.
- Dependency boxes support direct expected-value checks. Complex dependency graphs and every edge case from Obsidian are not reproduced.
- Theme controls cover the principal colors and presets. Font-face, background image, transparency and contrast tooling are not yet integrated into the theme editor.
- The UI uses translucent surfaces and gradients to simulate glass. There is no per-window blur.

## Not implemented yet

- Context menus and detached/pop-out groupboxes
- Full sidebar resize, compact-threshold logic and window snapping
- Advanced animation settings and swipe transitions
- Search result ranking, fuzzy matching and global-search preferences
- Keybind menu, modifier combinations and advanced key restrictions
- Full notification feature set
- Full ThemeManager editor and full parity with Obsidian's SaveManager parsers for every widget type

## Compatibility boundary

Roblox GUI services are the primary implementation target. Executor-only filesystem, clipboard, gethui and protected-GUI functions are optional. Persistent file storage is unavailable in environments that do not expose the relevant functions; in those cases configs remain in memory until the script/session ends, and JSON import/export can be used to move them manually.
