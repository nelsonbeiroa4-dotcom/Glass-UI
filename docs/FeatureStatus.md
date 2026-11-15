# Feature status

## Base

Glass UI v0.3.1 uses the upstream Obsidian Library source as its core rather than the previous hand-built GUI. It inherits the upstream architecture for:

- Window creation, resizing, dragging, visibility, compactable/resizable sidebar and snapping.
- Tabs, key tabs, tabboxes, groupboxes, nested groupboxes and pop-out groupboxes.
- Search, dependencies and visibility state.
- Buttons, toggles, checkboxes, labels, dividers, inputs, sliders, dropdowns, color pickers and key pickers.
- Notifications, dialogs, tooltips, loading panels, keybind menus and cursor handling.
- Optional ThemeManager and SaveManager modules in `addons/`.

## Glass UI changes

- Deep violet palette with light lavender text and purple accents.
- Translucent surfaces and controls.
- Dark gradients on the main window and groupbox cards.
- Accent outline, softened strokes and larger corner radius.
- Larger default window, adjusted sidebar and more generous groupbox spacing.
- Executor identity recognition and global blur fallback for unrecognized environments.

## Boundaries

- The global blur fallback affects the full 3D scene, not only the area behind the window.
- Clipped live backdrop blur is not available through Roblox's standard ScreenGui API.
- Executor detection relies on reported identity or environment markers; all listed builds are not individually runtime-tested.
- Filesystem persistence depends on the executor's file APIs.
