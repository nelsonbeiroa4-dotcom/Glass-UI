# API

Glass UI v0.3.0 uses the real [Obsidian UI Library](https://github.com/deividcomsono/Obsidian) as its base. The public API follows Obsidian, not the previous experimental Glass UI implementation.

For exact option fields and current methods, consult:
- [Obsidian documentation](https://docs.mspaint.cc/obsidian)
- [Official Example.lua](https://github.com/deividcomsono/Obsidian/blob/main/Example.lua)
- [Library.d.luau type declarations](https://github.com/deividcomsono/Obsidian/blob/main/Library.d.luau)

## Basic structure

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/nelsonbeiroa4-dotcom/Glass-UI/main/dist/GlassUI.lua"
))()

local Window = Library:CreateWindow({
    Title = "My Script",
    Size = UDim2.fromOffset(960, 620),
    Center = true,
    AutoShow = true,
})

local Tab = Window:AddTab("Main", "house")
local Group = Tab:AddLeftGroupbox("General")

Group:AddButton({
    Text = "Click me",
    Func = function()
        Library:Notify("Button clicked.", 3)
    end,
})

Group:AddToggle("MyToggle", {
    Text = "Enable feature",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})
```

## Add-ons

`addons/ThemeManager.lua` and `addons/SaveManager.lua` are separate modules. Load them separately, then call `:SetLibrary(Library)` before using their APIs.

## Compatibility

The Glass-specific executor detector is exposed through `Library.Compatibility`: `ExecutorName`, `ExecutorVersion`, `IsSupported`, `DetectionMethod`, `SupportedExecutors` and `BlurMode`.
