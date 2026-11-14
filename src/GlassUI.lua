-- Glass UI | Roblox Luau interface toolkit
-- A single-file library with an optional capability layer for executor APIs.
-- Version: 0.1.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function global(name)
    local ok, value = pcall(function()
        if getfenv then return getfenv()[name] end
        return _G[name]
    end)
    return ok and value or nil
end

local Compat = {
    gethui = global("gethui"),
    protectgui = global("protectgui") or (global("syn") and global("syn").protect_gui),
    writefile = global("writefile"), readfile = global("readfile"),
    isfile = global("isfile"), makefolder = global("makefolder"),
    isfolder = global("isfolder"), listfiles = global("listfiles"),
    delfile = global("delfile"), setclipboard = global("setclipboard"),
}

local Colors = {
    BackgroundColor = Color3.fromRGB(7, 10, 28),
    SurfaceColor = Color3.fromRGB(19, 24, 55),
    PanelColor = Color3.fromRGB(28, 35, 76),
    AccentColor = Color3.fromRGB(191, 91, 255),
    AccentSecondary = Color3.fromRGB(65, 112, 255),
    OutlineColor = Color3.fromRGB(173, 170, 255),
    FontColor = Color3.fromRGB(247, 246, 255),
    MutedColor = Color3.fromRGB(164, 169, 202),
    DangerColor = Color3.fromRGB(255, 104, 137),
    SuccessColor = Color3.fromRGB(91, 224, 174),
}

local Library = {
    Name = "Glass UI", Version = "0.1.0", LocalPlayer = LocalPlayer,
    Compatibility = Compat, Theme = Colors, Options = {}, Toggles = {},
    Buttons = {}, Labels = {}, Tabs = {}, Notifications = {},
    Connections = {}, UnloadCallbacks = {}, ThemeBindings = {},
    ConfigStore = {}, Unloaded = false, IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
    ToggleKeybind = Enum.KeyCode.RightControl, NotifySide = "Right",
}

local function safe(callback, ...)
    if type(callback) ~= "function" then return end
    local args = table.pack(...)
    local ok, err = pcall(function() callback(table.unpack(args, 1, args.n)) end)
    if not ok then warn("[Glass UI] " .. tostring(err)) end
end

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Library.Connections, connection)
    return connection
end

local function create(class, props, parent)
    local object = Instance.new(class)
    for key, value in pairs(props or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(object, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, object)
end

local function outline(object, transparency)
    return create("UIStroke", {
        Color = Colors.OutlineColor, Transparency = transparency or 0.72, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, object)
end

local function applyThemeBinding(object, property, key)
    if Colors[key] then
        object[property] = Colors[key]
        table.insert(Library.ThemeBindings, { Object = object, Property = property, Key = key })
    end
end

local function glass(parent, size, radius)
    local frame = create("Frame", {
        BackgroundColor3 = Colors.SurfaceColor, BackgroundTransparency = 0.18,
        BorderSizePixel = 0, Size = size or UDim2.fromScale(1, 1),
    }, parent)
    round(frame, radius or 12)
    local edge = outline(frame, 0.72)
    create("UIGradient", {
        Rotation = 35,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.52, Colors.SurfaceColor),
            ColorSequenceKeypoint.new(1, Colors.AccentSecondary),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.91),
            NumberSequenceKeypoint.new(0.5, 0.98),
            NumberSequenceKeypoint.new(1, 0.94),
        }),
    }, frame)
    applyThemeBinding(frame, "BackgroundColor3", "SurfaceColor")
    applyThemeBinding(edge, "Color", "OutlineColor")
    return frame
end

local function tween(object, duration, properties)
    local result = TweenService:Create(object, TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    result:Play()
    return result
end

local function text(parent, value, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1, BorderSizePixel = 0, Text = tostring(value or ""),
        TextColor3 = color or Colors.FontColor, TextSize = size or 13,
        Font = font or Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, RichText = true,
        Size = UDim2.new(1, 0, 0, 18),
    }, parent)
end

local function vertical(parent, gap)
    return create("UIListLayout", {
        Padding = UDim.new(0, gap or 7), SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
    }, parent)
end

local function horizontal(parent, gap)
    return create("UIListLayout", {
        Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, parent)
end

local function parentGui(screen)
    local target = PlayerGui
    if type(Compat.gethui) == "function" then
        local ok, result = pcall(Compat.gethui)
        if ok and result then target = result end
    else
        local ok, result = pcall(function() return CoreGui end)
        if ok and result then target = result end
    end
    if type(Compat.protectgui) == "function" then pcall(Compat.protectgui, screen) end
    local ok = pcall(function() screen.Parent = target end)
    if not ok or not screen.Parent then screen.Parent = PlayerGui end
end

function Library:SetTheme(theme)
    local previous = {}
    for key, value in pairs(Colors) do previous[key] = value end
    for key, value in pairs(theme or {}) do
        if Colors[key] and typeof(value) == "Color3" then Colors[key] = value end
    end
    if Library.ScreenGui then
        for _, object in ipairs(Library.ScreenGui:GetDescendants()) do
            for key, oldColor in pairs(previous) do
                local newColor = Colors[key]
                if newColor and oldColor ~= newColor then
                    for _, property in ipairs({ "BackgroundColor3", "TextColor3", "ImageColor3", "Color" }) do
                        pcall(function()
                            if object[property] == oldColor then object[property] = newColor end
                        end)
                    end
                end
            end
        end
    end
    for index = #Library.ThemeBindings, 1, -1 do
        local binding = Library.ThemeBindings[index]
        if binding.Object and binding.Object.Parent then
            pcall(function() binding.Object[binding.Property] = Colors[binding.Key] end)
        else
            table.remove(Library.ThemeBindings, index)
        end
    end
end

function Library:SetAccentColor(color, secondary)
    assert(typeof(color) == "Color3", "Color3 expected")
    Library:SetTheme({ AccentColor = color, AccentSecondary = secondary or Colors.AccentSecondary })
end

function Library:SetFont(font)
    if typeof(font) ~= "EnumItem" then return end
    for _, item in ipairs(Library.ScreenGui and Library.ScreenGui:GetDescendants() or {}) do
        if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then item.Font = font end
    end
end

function Library:OnUnload(callback)
    if type(callback) == "function" then table.insert(Library.UnloadCallbacks, callback) end
end

local Group = {}
Group.__index = Group

local function holder(group, height)
    return create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 34),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, group.Container)
end

local function makeOption(group, index, kind, default, info)
    assert(type(index) == "string" and index ~= "", "Provide a stable option index")
    info = info or {}
    local option = {
        Index = index, Type = kind, Value = default, Default = default,
        Callback = info.Callback, Changed = info.Changed, Parent = group,
        Visible = true, Disabled = false, Connections = {},
    }
    if kind == "Toggle" or kind == "Checkbox" then Library.Toggles[index] = option else Library.Options[index] = option end
    function option:SetValue(value, silent)
        if self.Disabled then return end
        self.Value = value
        if self.Refresh then self:Refresh() end
        if not silent then safe(self.Callback, value); safe(self.Changed, value) end
        Library:UpdateDependencies()
    end
    function option:OnChanged(callback) self.Changed = callback; return self end
    function option:SetVisible(value) self.Visible = value == true; if self.Holder then self.Holder.Visible = self.Visible end; return self end
    function option:SetDisabled(value) self.Disabled = value == true; return self end
    function option:Destroy()
        for _, connection in ipairs(self.Connections) do connection:Disconnect() end
        if self.Holder then self.Holder:Destroy() end
        Library.Options[index] = nil; Library.Toggles[index] = nil
        Library:UpdateDependencies()
    end
    return option
end

function Group:Resize()
    if self.Container and self.Layout then self.Container.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y + 10) end
end

function Group:AddLabel(info, wrap)
    if type(info) ~= "table" then info = { Text = info, DoesWrap = wrap } end
    local box = holder(self, info.DoesWrap and 36 or 20)
    local label = text(box, info.Text or "", info.Size or 13, Colors.MutedColor)
    label.TextWrapped = info.DoesWrap == true
    label.Size = UDim2.new(1, 0, 0, info.DoesWrap and 36 or 20)
    local item = { Type = "Label", TextLabel = label, Holder = box, Parent = self }
    function item:SetText(value) label.Text = tostring(value) end
    function item:SetVisible(value) box.Visible = value == true; self.Parent:Resize() end
    function item:AddColorPicker(index, data) return self.Parent:AddColorPicker(index, data, box) end
    function item:AddKeyPicker(index, data) return self.Parent:AddKeyPicker(index, data, box) end
    self:Resize()
    return item
end

function Group:AddDivider(value)
    local title = type(value) == "table" and value.Text or value
    local box = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) }, self.Container)
    if title then
        local label = text(box, title, 11, Colors.MutedColor, Enum.Font.GothamMedium)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Size = UDim2.fromScale(1, 1)
    else
        create("Frame", { BackgroundColor3 = Colors.OutlineColor, BackgroundTransparency = 0.65, BorderSizePixel = 0, Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1) }, box)
    end
    self:Resize()
    return { Holder = box, SetVisible = function(_, v) box.Visible = v == true end, Destroy = function() box:Destroy() end }
end

function Group:AddButton(first, second)
    local info = type(first) == "table" and first or { Text = first, Callback = second }
    local box = holder(self, 36)
    local button = create("TextButton", {
        AutoButtonColor = false, Text = info.Text or "Button", TextColor3 = Colors.FontColor,
        TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundColor3 = Colors.PanelColor,
        BackgroundTransparency = 0.08, Size = UDim2.new(1, 0, 0, 34),
    }, box)
    round(button, 8); outline(button, 0.7)
    button.MouseEnter:Connect(function() tween(button, 0.12, { BackgroundColor3 = Colors.AccentColor }) end)
    button.MouseLeave:Connect(function() tween(button, 0.12, { BackgroundColor3 = Colors.PanelColor }) end)
    button.MouseButton1Click:Connect(function() safe(info.Callback or info.Func) end)
    local item = { Type = "Button", Base = button, Holder = box, Parent = self }
    function item:SetText(value) button.Text = tostring(value) end
    function item:SetVisible(value) box.Visible = value == true end
    function item:Destroy() box:Destroy() end
    self:Resize()
    return item
end

function Group:AddToggle(index, info)
    info = info or {}
    local box = holder(self, 30)
    local row = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28) }, box)
    local label = text(row, info.Text or index, 13, Colors.FontColor, Enum.Font.GothamMedium)
    label.Size = UDim2.new(1, -52, 1, 0)
    label.AutomaticSize = Enum.AutomaticSize.None
    local switch = create("TextButton", { AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(38, 21), BackgroundColor3 = Colors.PanelColor }, row)
    round(switch, 20)
    local knob = create("Frame", { BackgroundColor3 = Colors.MutedColor, Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(15, 15) }, switch)
    round(knob, 20)
    local option = makeOption(self, index, "Toggle", info.Default == true, info)
    option.Holder = box
    option.Refresh = function(item)
        local active = item.Value == true
        tween(switch, 0.12, { BackgroundColor3 = active and Colors.AccentColor or Colors.PanelColor })
        tween(knob, 0.12, { Position = active and UDim2.new(1, -18, 0, 3) or UDim2.fromOffset(3, 3) })
    end
    switch.MouseButton1Click:Connect(function() option:SetValue(not option.Value) end)
    function option:AddColorPicker(pickerIndex, pickerInfo) return self.Parent:AddColorPicker(pickerIndex, pickerInfo, box) end
    function option:AddKeyPicker(pickerIndex, pickerInfo) return self.Parent:AddKeyPicker(pickerIndex, pickerInfo, box) end
    option:Refresh(); self:Resize()
    return option
end

function Group:AddCheckbox(index, info)
    local option = self:AddToggle(index, info)
    option.Type = "Checkbox"
    Library.Toggles[index] = option
    return option
end

function Group:AddInput(index, info)
    info = info or {}
    local box = holder(self, 54)
    local label = text(box, info.Text or index, 12, Colors.MutedColor)
    local input = create("TextBox", {
        Text = tostring(info.Default or ""), PlaceholderText = info.Placeholder or "Enter a value",
        ClearTextOnFocus = info.ClearTextOnFocus ~= false, TextColor3 = Colors.FontColor,
        PlaceholderColor3 = Colors.MutedColor, TextSize = 13, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = Colors.PanelColor,
        BackgroundTransparency = 0.08, Size = UDim2.new(1, 0, 0, 31),
    }, box)
    round(input, 7); outline(input, 0.75)
    local option = makeOption(self, index, "Input", tostring(info.Default or ""), info)
    option.Holder = box; option.TextBox = input
    local function commit()
        local value = input.Text
        if info.Numeric then value = tonumber(value) or option.Value end
        if info.VerifyValue then
            local ok, accepted = pcall(info.VerifyValue, value)
            if not ok or not accepted then input.Text = tostring(option.Value); return end
        end
        option:SetValue(value)
    end
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if info.Numeric then
            local cleaned = input.Text:gsub("[^%d%.%-]", "")
            if cleaned ~= input.Text then input.Text = cleaned end
        end
        if not info.Finished then option.Value = input.Text; safe(option.Callback, option.Value) end
    end)
    input.FocusLost:Connect(function() if info.Finished then commit() end end)
    function option:Refresh() input.Text = tostring(self.Value) end
    self:Resize()
    return option
end

function Group:AddSlider(index, info)
    info = info or {}
    local minValue, maxValue = tonumber(info.Min) or 0, tonumber(info.Max) or 100
    if maxValue <= minValue then maxValue = minValue + 1 end
    local rounding = tonumber(info.Rounding) or 0
    local box = holder(self, 54)
    local labelRow = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18) }, box)
    local label = text(labelRow, info.Text or index, 12, Colors.FontColor)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.AutomaticSize = Enum.AutomaticSize.None
    local valueText = text(labelRow, "", 11, Colors.MutedColor)
    valueText.Size = UDim2.new(0, 70, 1, 0); valueText.Position = UDim2.new(1, -70, 0, 0)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    local rail = create("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = Colors.PanelColor, Size = UDim2.new(1, 0, 0, 7) }, box)
    round(rail, 8)
    local fill = create("Frame", { BackgroundColor3 = Colors.AccentColor, Size = UDim2.new(0, 0, 1, 0) }, rail); round(fill, 8)
    local knob = create("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12) }, rail); round(knob, 10)
    local option = makeOption(self, index, "Slider", math.clamp(tonumber(info.Default) or minValue, minValue, maxValue), info)
    option.Holder = box; option.Min = minValue; option.Max = maxValue
    option.Refresh = function(item)
        local percent = math.clamp((item.Value - minValue) / (maxValue - minValue), 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0); knob.Position = UDim2.new(percent, 0, 0.5, 0)
        valueText.Text = tostring(info.Prefix or "") .. tostring(item.Value) .. tostring(info.Suffix or "")
    end
    local dragging = false
    local function update(x)
        local percent = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
        local value = minValue + (maxValue - minValue) * percent
        local factor = 10 ^ rounding
        option:SetValue(math.floor(value * factor + 0.5) / factor)
    end
    rail.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input.Position.X) end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    option:Refresh(); self:Resize()
    return option
end

function Group:AddDropdown(index, info)
    info = info or {}
    local box = holder(self, 58)
    text(box, info.Text or index, 12, Colors.MutedColor)
    local button = create("TextButton", {
        AutoButtonColor = false, Text = "Select...", TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Colors.FontColor, TextSize = 12, Font = Enum.Font.Gotham,
        BackgroundColor3 = Colors.PanelColor, BackgroundTransparency = 0.08,
        Size = UDim2.new(1, 0, 0, 32),
    }, box)
    round(button, 7); outline(button, 0.75)
    local popup = create("Frame", { BackgroundColor3 = Colors.BackgroundColor, Size = UDim2.new(1, 0, 0, 0), Visible = false, ClipsDescendants = true, ZIndex = 30 }, box)
    round(popup, 7); outline(popup, 0.5)
    local list = create("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ZIndex = 31 }, popup)
    vertical(list, 2)
    local option = makeOption(self, index, "Dropdown", info.Default, info)
    option.Holder = box; option.Values = info.Values or {}; option.Multi = info.Multi == true
    option.DisabledValues = info.DisabledValues or {}
    local function refresh()
        if option.Multi then button.Text = type(option.Value) == "table" and table.concat(option.Value, ", ") or "Select..."
        else button.Text = option.Value ~= nil and tostring(option.Value) or "Select..." end
        for _, child in ipairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, value in ipairs(option.Values) do
            local chosen = option.Multi and type(option.Value) == "table" and table.find(option.Value, value) or option.Value == value
            local disabled = table.find(option.DisabledValues, value) ~= nil
            local row = create("TextButton", {
                AutoButtonColor = false, Text = tostring(value), TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = disabled and Colors.MutedColor or (chosen and Colors.AccentColor or Colors.FontColor),
                TextSize = 12, Font = Enum.Font.Gotham, BackgroundTransparency = chosen and 0.1 or 1,
                BackgroundColor3 = Colors.PanelColor, Size = UDim2.new(1, 0, 0, 27), ZIndex = 32,
            }, list)
            row.MouseButton1Click:Connect(function()
                if disabled then return end
                if option.Multi then
                    local nextValue = {}
                    for _, old in ipairs(option.Value or {}) do table.insert(nextValue, old) end
                    local at = table.find(nextValue, value)
                    if at then table.remove(nextValue, at) else table.insert(nextValue, value) end
                    option:SetValue(nextValue)
                else
                    option:SetValue(value); popup.Visible = false
                end
                refresh()
            end)
        end
    end
    option.Refresh = refresh
    function option:SetValues(values) self.Values = values or {}; refresh() end
    function option:AddValues(values) for _, value in ipairs(values or {}) do table.insert(self.Values, value) end; refresh() end
    function option:SetDisabledValues(values) self.DisabledValues = values or {}; refresh() end
    function option:AddDisabledValues(values) for _, value in ipairs(values or {}) do table.insert(self.DisabledValues, value) end; refresh() end
    button.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
        popup.Position = UDim2.new(0, 0, 0, 36)
        popup.Size = UDim2.new(1, 0, 0, popup.Visible and math.min(150, #option.Values * 29 + 8) or 0)
    end)
    refresh(); self:Resize()
    return option
end

function Group:AddColorPicker(index, info, attachParent)
    info = info or {}
    local parent = attachParent or self.Container
    local row = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28) }, parent)
    local label = text(row, info.Title or info.Text or index, 12, Colors.MutedColor)
    label.Size = UDim2.new(1, -45, 1, 0)
    label.AutomaticSize = Enum.AutomaticSize.None
    local initial = typeof(info.Default) == "Color3" and info.Default or Colors.AccentColor
    local swatch = create("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = initial, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(36, 21) }, row)
    round(swatch, 6); outline(swatch, 0.35)
    local panel = create("Frame", { BackgroundColor3 = Colors.BackgroundColor, Size = UDim2.new(1, 0, 0, 65), Visible = false }, parent)
    round(panel, 7); outline(panel, 0.5)
    local hex = create("TextBox", { Text = "#" .. initial:ToHex(), ClearTextOnFocus = false, TextColor3 = Colors.FontColor, TextSize = 12, Font = Enum.Font.Code, BackgroundColor3 = Colors.PanelColor, Size = UDim2.new(1, -12, 0, 25), Position = UDim2.fromOffset(6, 6) }, panel)
    round(hex, 5)
    local hue = create("TextButton", { AutoButtonColor = false, Text = "", Size = UDim2.new(1, -12, 0, 14), Position = UDim2.fromOffset(6, 39) }, panel)
    round(hue, 5)
    create("UIGradient", { Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }) }, hue)
    local option = makeOption(self, index, "ColorPicker", initial, info)
    option.Holder = row; option.Transparency = tonumber(info.Transparency) or 0
    local h, s, v = initial:ToHSV()
    local function update()
        option.Value = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = option.Value
        hex.Text = "#" .. option.Value:ToHex()
        safe(option.Callback, option.Value, option.Transparency)
        safe(option.Changed, option.Value, option.Transparency)
    end
    function option:SetValue(color)
        assert(typeof(color) == "Color3", "Color3 expected")
        self.Value = color; h, s, v = color:ToHSV(); swatch.BackgroundColor3 = color; hex.Text = "#" .. color:ToHex()
        safe(self.Callback, color, self.Transparency); safe(self.Changed, color, self.Transparency)
    end
    function option:SetValueRGB(color, transparency) self.Transparency = transparency or self.Transparency; self:SetValue(color) end
    function option:SetTransparency(amount) self.Transparency = math.clamp(tonumber(amount) or 0, 0, 1); safe(self.Callback, self.Value, self.Transparency) end
    hex.FocusLost:Connect(function()
        local value = hex.Text:gsub("#", "")
        if #value == 6 then
            local ok, color = pcall(Color3.fromHex, value)
            if ok then option:SetValue(color) else hex.Text = "#" .. option.Value:ToHex() end
        end
    end)
    hue.MouseButton1Click:Connect(function()
        h = math.clamp((UserInputService:GetMouseLocation().X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 1)
        update()
    end)
    swatch.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)
    self:Resize()
    return option
end

function Group:AddKeyPicker(index, info, attachParent)
    info = info or {}
    local parent = attachParent or self.Container
    local row = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 27) }, parent)
    local label = text(row, info.Text or index, 12, Colors.MutedColor)
    label.Size = UDim2.new(1, -88, 1, 0)
    label.AutomaticSize = Enum.AutomaticSize.None
    local button = create("TextButton", { AutoButtonColor = false, Text = tostring(info.Default or "None"), TextColor3 = Colors.FontColor, TextSize = 11, Font = Enum.Font.GothamMedium, BackgroundColor3 = Colors.PanelColor, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(82, 22) }, row)
    round(button, 5)
    local option = makeOption(self, index, "KeyPicker", info.Default or "None", info)
    option.Holder = row; option.Mode = info.Mode or "Toggle"; option.Toggled = false
    function option:SetValue(value, mode) self.Value = value or "None"; if mode then self.Mode = mode end; button.Text = tostring(self.Value); safe(self.Changed, self.Value) end
    option.Refresh = function(self) button.Text = tostring(self.Value) end
    button.MouseButton1Click:Connect(function() Library.ActiveKeyCapture = option; button.Text = "Press key..." end)
    self:Resize()
    return option
end

function Group:AddImage(index, info)
    info = info or {}
    local box = holder(self, tonumber(info.Height) or 120)
    local image = create("ImageLabel", { BackgroundTransparency = 1, Image = tostring(info.Image or ""), ImageTransparency = tonumber(info.Transparency) or 0, ScaleType = info.ScaleType or Enum.ScaleType.Fit, Size = UDim2.new(1, 0, 0, tonumber(info.Height) or 120) }, box)
    return { Type = "Image", Holder = box, Image = image, SetVisible = function(_, v) box.Visible = v == true end, SetImage = function(_, v) image.Image = tostring(v) end }
end

function Group:AddViewport(index, info)
    info = info or {}
    local box = holder(self, tonumber(info.Height) or 160)
    local view = create("ViewportFrame", { BackgroundColor3 = Colors.PanelColor, BackgroundTransparency = 0.3, Size = UDim2.new(1, 0, 0, tonumber(info.Height) or 160) }, box)
    round(view, 8)
    local camera = Instance.new("Camera"); camera.Parent = view; view.CurrentCamera = camera
    if info.Object then
        local object = info.Clone == false and info.Object or info.Object:Clone()
        object.Parent = view
        if object:IsA("Model") then
            local cf, size = object:GetBoundingBox()
            camera.CFrame = cf * CFrame.new(0, 0, math.max(size.X, size.Y, size.Z) * 1.8)
        elseif object:IsA("BasePart") then camera.CFrame = object.CFrame * CFrame.new(0, 0, object.Size.Magnitude * 1.5) end
    end
    return { Type = "Viewport", Holder = box, Viewport = view, Camera = camera, SetVisible = function(_, v) box.Visible = v == true end, SetInteractive = function(_, v) view.Active = v == true end }
end

function Group:AddVideo(index, info)
    info = info or {}
    local box = holder(self, tonumber(info.Height) or 150)
    local video = create("VideoFrame", { Video = tostring(info.Video or ""), Looped = info.Looped == true, Volume = tonumber(info.Volume) or 1, Size = UDim2.new(1, 0, 0, tonumber(info.Height) or 150) }, box)
    return { Type = "Video", Holder = box, VideoFrame = video, Play = function() video:Play() end, Pause = function() video:Pause() end, SetVisible = function(_, v) box.Visible = v == true end }
end

function Group:AddUIPassthrough(index, info)
    info = info or {}
    local box = holder(self, tonumber(info.Height) or 24)
    if info.Instance then info.Instance.Parent = box end
    return { Type = "UIPassthrough", Holder = box, Instance = info.Instance, SetVisible = function(_, v) box.Visible = v == true end }
end

function Group:AddDependencyBox()
    local box = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Visible = false, AutomaticSize = Enum.AutomaticSize.Y }, self.Container)
    local layout = vertical(box, 6)
    local dependency = setmetatable({ Type = "DependencyBox", Holder = box, Container = box, Layout = layout, Parent = self, Dependencies = {}, DependencyBoxes = {} }, Group)
    function dependency:SetupDependencies(values) self.Dependencies = values or {}; Library:UpdateDependencies() end
    function dependency:Resize() self.Parent:Resize() end
    table.insert(self.DependencyBoxes or {}, dependency)
    return dependency
end
Group.AddDependencyGroupbox = Group.AddDependencyBox

function Group:Destroy()
    if self.Holder then self.Holder:Destroy() end
end

local Tab = {}
Tab.__index = Tab
function Tab:AddGroupbox(info)
    if type(info) ~= "table" then info = { Name = tostring(info or "Groupbox") } end
    local side = (info.Side == "Right" or info.Side == 2) and 2 or 1
    local card = glass(self.Columns[side], UDim2.new(1, 0, 0, 50), 11)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.Size = UDim2.new(1, 0, 0, 50)
    local title = text(card, info.Name or "Groupbox", 13, Colors.FontColor, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(10, 5); title.Size = UDim2.new(1, -20, 0, 20)
    local content = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 30), Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, card)
    local group = setmetatable({
        Type = "Groupbox", Name = info.Name or "Groupbox", Holder = card, Container = content,
        Layout = vertical(content, 7), Tab = self, Elements = {}, DependencyBoxes = {},
        Visible = info.Visible ~= false, Collapsed = info.Collapsed == true,
    }, Group)
    content.Visible = not group.Collapsed
    if info.DisableCollapsing ~= true then
        title.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then group.Collapsed = not group.Collapsed; content.Visible = not group.Collapsed end
        end)
    end
    table.insert(self.Groupboxes, group)
    self:Resize()
    return group
end
function Tab:AddLeftGroupbox(name, icon, visible, collapsed, disable)
    return self:AddGroupbox({ Side = "Left", Name = name, IconName = icon, Visible = visible, Collapsed = collapsed, DisableCollapsing = disable })
end
function Tab:AddRightGroupbox(name, icon, visible, collapsed, disable)
    return self:AddGroupbox({ Side = "Right", Name = name, IconName = icon, Visible = visible, Collapsed = collapsed, DisableCollapsing = disable })
end
function Tab:Resize() for _, group in ipairs(self.Groupboxes) do group:Resize() end end
function Tab:SetVisible(value)
    self.Button.Visible = value == true
    if not value and self.Window.ActiveTab == self then self.Window:SelectTab(self.Window.Tabs[1]) end
end
function Tab:Show() self.Window:SelectTab(self) end
function Tab:Hide() self:SetVisible(false) end
function Tab:AddTabbox(info)
    local group = self:AddGroupbox({ Side = type(info) == "table" and info.Side or "Left", Name = type(info) == "table" and info.Name or info or "Tabbox" })
    local bar = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25) }, group.Container)
    horizontal(bar, 4)
    local pages = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, group.Container)
    local tabbox = { Tabs = {}, ActiveTab = nil, Parent = group }
    function tabbox:AddTab(name)
        local button = create("TextButton", { AutoButtonColor = false, Text = tostring(name), TextColor3 = Colors.MutedColor, TextSize = 11, Font = Enum.Font.GothamSemibold, BackgroundColor3 = Colors.PanelColor, Size = UDim2.fromOffset(76, 24) }, bar)
        round(button, 5)
        local page = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false }, pages)
        local sub = setmetatable({ Type = "SubTab", Name = name, Holder = page, Container = page, Layout = vertical(page, 7), Parent = group, Elements = {}, DependencyBoxes = {} }, Group)
        function sub:Show()
            for _, other in ipairs(tabbox.Tabs) do other.Holder.Visible = false end
            page.Visible = true; tabbox.ActiveTab = sub
        end
        button.MouseButton1Click:Connect(function() sub:Show() end)
        table.insert(tabbox.Tabs, sub)
        if #tabbox.Tabs == 1 then sub:Show() end
        return sub
    end
    function tabbox:Destroy() group:Destroy() end
    return tabbox
end
function Tab:AddLeftTabbox(name) return self:AddTabbox({ Side = "Left", Name = name }) end
function Tab:AddRightTabbox(name) return self:AddTabbox({ Side = "Right", Name = name }) end

local Window = {}
Window.__index = Window
function Window:SelectTab(tab)
    if not tab then return end
    for _, other in ipairs(self.Tabs) do
        other.Page.Visible = other == tab
        other.Button.BackgroundTransparency = other == tab and 0.1 or 1
        other.Button.TextColor3 = other == tab and Colors.FontColor or Colors.MutedColor
        other.Indicator.Visible = other == tab
    end
    self.ActiveTab = tab
end
function Window:AddTab(name, icon, description)
    local button = create("TextButton", {
        AutoButtonColor = false, Text = tostring(name), TextColor3 = Colors.MutedColor, TextSize = 12,
        Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Colors.PanelColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34),
    }, self.Sidebar)
    round(button, 7)
    local indicator = create("Frame", { BackgroundColor3 = Colors.AccentColor, Position = UDim2.fromOffset(0, 7), Size = UDim2.new(0, 3, 1, -14), Visible = false }, button)
    round(indicator, 3)
    local page = create("ScrollingFrame", {
        BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.AccentSecondary, Visible = false,
    }, self.PageHost)
    local columns = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, page)
    local left = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, columns)
    local right = create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0.5, 6, 0, 0), Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, columns)
    vertical(left, 10); vertical(right, 10)
    local tab = setmetatable({ Name = name, Icon = icon, Description = description, Button = button, Indicator = indicator, Page = page, Columns = { left, right }, Groupboxes = {}, Window = self }, Tab)
    button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    table.insert(self.Tabs, tab); table.insert(Library.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end
function Window:AddKeyTab(name, icon, description) return self:AddTab(name, icon, description) end
function Window:Toggle(value)
    self.Main.Visible = value == nil and not self.Main.Visible or value == true
    return self.Main.Visible
end
function Window:SetTitle(value) self.TitleLabel.Text = tostring(value) end
function Window:SetFooter(value) self.FooterLabel.Text = tostring(value) end
function Window:SetBackgroundImage(asset) self.BackgroundImage.Image = tostring(asset); self.BackgroundImage.Visible = asset ~= nil and tostring(asset) ~= "" end
function Window:RefreshTheme()
    self.Main.BackgroundColor3 = Colors.BackgroundColor
    self.TitleLabel.TextColor3 = Colors.FontColor
    self.FooterLabel.TextColor3 = Colors.MutedColor
end

function Window:AddDialog(index, info)
    info = info or {}
    local overlay = create("TextButton", { AutoButtonColor = false, Text = "", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.42, Size = UDim2.fromScale(1, 1), ZIndex = 90 }, self.Main)
    local card = glass(overlay, UDim2.fromOffset(340, 0), 13)
    card.AutomaticSize = Enum.AutomaticSize.Y; card.AnchorPoint = Vector2.new(0.5, 0.5); card.Position = UDim2.fromScale(0.5, 0.5); card.ZIndex = 91
    vertical(card, 9)
    local title = text(card, info.Title or "Dialog", 16, Colors.FontColor, Enum.Font.GothamBold); title.ZIndex = 92
    local desc = text(card, info.Description or "", 12, Colors.MutedColor); desc.TextWrapped = true; desc.ZIndex = 92
    local actions = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 33), ZIndex = 92 }, card); horizontal(actions, 8)
    local dialog = { Destroyed = false, Overlay = overlay, Frame = card }
    function dialog:Dismiss() if not self.Destroyed then self.Destroyed = true; overlay:Destroy() end end
    function dialog:AddButton(label, callback)
        local button = create("TextButton", { AutoButtonColor = false, Text = label, TextColor3 = Colors.FontColor, TextSize = 12, Font = Enum.Font.GothamSemibold, BackgroundColor3 = Colors.PanelColor, Size = UDim2.fromOffset(95, 31) }, actions)
        round(button, 6)
        button.MouseButton1Click:Connect(function() safe(callback, dialog); if info.AutoDismiss ~= false then dialog:Dismiss() end end)
        return button
    end
    if info.FooterButtons then
        for label, data in pairs(info.FooterButtons) do dialog:AddButton(data.Title or label, data.Callback) end
    else
        dialog:AddButton(info.ConfirmText or "OK", info.Callback)
        if info.CancelText then dialog:AddButton(info.CancelText, info.OnCancel) end
    end
    overlay.MouseButton1Click:Connect(function() if info.OutsideClickDismiss ~= false then dialog:Dismiss() end end)
    return dialog
end

function Library:CreateWindow(info)
    assert(not Library.Unloaded, "Library has been unloaded")
    info = info or {}
    if Library.Window then warn("[Glass UI] Window already exists"); return Library.Window end
    local screen = create("ScreenGui", { Name = "GlassUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100 }, nil)
    parentGui(screen); Library.ScreenGui = screen
    local main = glass(screen, info.Size or UDim2.fromOffset(760, 550), 16)
    main.BackgroundColor3 = Colors.BackgroundColor; main.BackgroundTransparency = 0.12
    main.AnchorPoint = Vector2.new(0.5, 0.5); main.Position = info.Position or UDim2.fromScale(0.5, 0.5)
    main.ClipsDescendants = true
    local header = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52) }, main)
    local title = text(header, info.Title or "Glass UI", 17, Colors.FontColor, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(17, 0); title.Size = UDim2.new(1, -75, 1, 0); title.AutomaticSize = Enum.AutomaticSize.None
    local close = create("TextButton", { AutoButtonColor = false, Text = "×", TextColor3 = Colors.MutedColor, TextSize = 23, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(30, 30) }, header)
    local separator = create("Frame", { BackgroundColor3 = Colors.OutlineColor, BackgroundTransparency = 0.72, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 0, 1) }, main)
    local sidebar = create("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(12, 66), Size = UDim2.new(0, 155, 1, -100), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2 }, main)
    vertical(sidebar, 4)
    local pageHost = create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(180, 66), Size = UDim2.new(1, -192, 1, -100) }, main)
    local footer = text(main, info.Footer or "Glass UI  •  0.1.0", 10, Colors.MutedColor)
    footer.Position = UDim2.new(0, 17, 1, -23); footer.Size = UDim2.new(1, -34, 0, 14); footer.AutomaticSize = Enum.AutomaticSize.None
    local window = setmetatable({ Main = main, Sidebar = sidebar, PageHost = pageHost, TitleLabel = title, FooterLabel = footer, Tabs = {}, ActiveTab = nil, BackgroundImage = create("ImageLabel", { BackgroundTransparency = 1, ImageTransparency = 0.8, Size = UDim2.fromScale(1, 1), Visible = false }, main) }, Window)
    Library.Window = window
    close.MouseButton1Click:Connect(function() if info.CloseButtonDestroys then Library:Unload() else main.Visible = false end end)
    local dragging, start, origin = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; start = input.Position; origin = main.Position end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - start
            main.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    main.Visible = info.AutoShow ~= false
    Library.ToggleKeybind = info.ToggleKeybind or Library.ToggleKeybind
    return window
end

function Library:UpdateDependencies()
    local function check(dependencies)
        for _, dependency in ipairs(dependencies or {}) do
            local option, expected = dependency[1], dependency[2]
            if not option then return false end
            if type(option.Value) == "table" then
                if not table.find(option.Value, expected) then return false end
            elseif option.Value ~= expected then return false end
        end
        return true
    end
    local function visit(group)
        for _, box in ipairs(group.DependencyBoxes or {}) do
            box.Holder.Visible = check(box.Dependencies)
            visit(box)
        end
    end
    for _, tab in ipairs(Library.Tabs) do for _, group in ipairs(tab.Groupboxes) do visit(group) end end
end

function Library:Notify(info, duration)
    if type(info) ~= "table" then info = { Description = tostring(info), Time = duration or 4 } end
    if not Library.ScreenGui then return nil end
    local stack = Library.ScreenGui:FindFirstChild("NotificationStack")
    if not stack then
        stack = create("Frame", { Name = "NotificationStack", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 200 }, Library.ScreenGui)
        vertical(stack, 8)
    end
    local card = glass(stack, UDim2.new(1, 0, 0, 0), 10)
    card.AutomaticSize = Enum.AutomaticSize.Y; card.BackgroundTransparency = 0.06; card.ZIndex = 201
    local title = text(card, info.Title or "Glass UI", 13, Colors.FontColor, Enum.Font.GothamBold); title.Position = UDim2.fromOffset(10, 7); title.ZIndex = 202
    local desc = text(card, info.Description or "", 12, Colors.MutedColor); desc.Position = UDim2.fromOffset(10, 27); desc.Size = UDim2.new(1, -20, 0, 0); desc.AutomaticSize = Enum.AutomaticSize.Y; desc.TextWrapped = true; desc.ZIndex = 202
    local toast = { Frame = card, Destroyed = false }
    function toast:ChangeTitle(value) title.Text = tostring(value) end
    function toast:ChangeDescription(value) desc.Text = tostring(value) end
    function toast:Destroy() if not self.Destroyed then self.Destroyed = true; card:Destroy() end end
    table.insert(Library.Notifications, toast)
    local lifetime = tonumber(info.Time) or 4
    if lifetime > 0 then task.delay(lifetime, function() toast:Destroy() end) end
    return toast
end

function Library:CreateWatermark(info)
    info = type(info) == "table" and info or { Text = info }
    if not Library.ScreenGui then return nil end
    local frame = glass(Library.ScreenGui, info.Size or UDim2.fromOffset(220, 36), 8)
    frame.Position = info.Position or UDim2.fromOffset(14, 14)
    frame.Visible = info.Visible == true; frame.ZIndex = 150
    local label = text(frame, info.Text or "Glass UI", 12, Colors.FontColor, Enum.Font.GothamSemibold)
    label.Position = UDim2.fromOffset(10, 0); label.Size = UDim2.new(1, -20, 1, 0); label.AutomaticSize = Enum.AutomaticSize.None; label.ZIndex = 151
    local drag, start, origin = false, nil, nil
    frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; start = input.Position; origin = frame.Position end end)
    connect(UserInputService.InputChanged, function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - start
            frame.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
        end
    end)
    connect(UserInputService.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    local watermark = { Frame = frame, Label = frame }
    function watermark:SetText(value) label.Text = tostring(value) end
    function watermark:SetVisible(value) frame.Visible = value == true end
    function watermark:SetPosition(value) frame.Position = value end
    function watermark:Destroy() frame:Destroy() end
    if not Library.DefaultWatermark then Library.DefaultWatermark = watermark end
    return watermark
end
function Library:AddDraggableLabel(value)
    local watermark = Library:CreateWatermark({ Text = value, Visible = true })
    Library.DefaultWatermark = watermark
    return watermark
end


function Library:SetNotifySide(side)
    Library.NotifySide = side == "Left" and "Left" or "Right"
end
function Library:SetWatermark(value)
    if Library.DefaultWatermark then Library.DefaultWatermark:SetText(value) end
end
function Library:SetWatermarkVisibility(value)
    if Library.DefaultWatermark then Library.DefaultWatermark:SetVisible(value) end
end
function Library:AddDraggableButton(value, callback)
    if not Library.ScreenGui then return nil end
    local button = create("TextButton", {
        AutoButtonColor = false, Text = tostring(value or "Button"),
        TextColor3 = Colors.FontColor, TextSize = 12, Font = Enum.Font.GothamSemibold,
        BackgroundColor3 = Colors.SurfaceColor, BackgroundTransparency = 0.08,
        Position = UDim2.fromOffset(16, 60), Size = UDim2.fromOffset(120, 32),
    }, Library.ScreenGui)
    round(button, 8); outline(button, 0.72)
    button.MouseButton1Click:Connect(function() safe(callback) end)
    return {
        Button = button,
        SetText = function(_, textValue) button.Text = tostring(textValue) end,
        SetVisible = function(_, visible) button.Visible = visible == true end,
        Destroy = function() button:Destroy() end,
    }
end
function Library:AddTooltip(info, disabledInfo, target)
    if not target or not Library.ScreenGui then return nil end
    local tooltip = glass(Library.ScreenGui, UDim2.fromOffset(220, 36), 7)
    tooltip.Visible = false
    tooltip.ZIndex = 400
    local label = text(tooltip, info or "", 11, Colors.FontColor)
    label.Position = UDim2.fromOffset(8, 0)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.AutomaticSize = Enum.AutomaticSize.None
    label.ZIndex = 401
    local enter = target.MouseEnter:Connect(function()
        label.Text = target.Active == false and (disabledInfo or info or "") or (info or "")
        tooltip.Position = UDim2.fromOffset(target.AbsolutePosition.X + target.AbsoluteSize.X + 6, target.AbsolutePosition.Y)
        tooltip.Visible = true
    end)
    local leave = target.MouseLeave:Connect(function() tooltip.Visible = false end)
    local item = { Frame = tooltip }
    function item:Destroy() enter:Disconnect(); leave:Disconnect(); tooltip:Destroy() end
    return item
end

function Library:CreateLoading(info)
    info = info or {}
    if not Library.ScreenGui then return nil end
    local overlay = create("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.42, Size = UDim2.fromScale(1, 1), ZIndex = 250 }, Library.ScreenGui)
    local card = glass(overlay, UDim2.fromOffset(info.Width or 350, 140), 12)
    card.AnchorPoint = Vector2.new(0.5, 0.5); card.Position = UDim2.fromScale(0.5, 0.5); card.ZIndex = 251
    local title = text(card, info.Title or "Loading...", 15, Colors.FontColor, Enum.Font.GothamBold); title.Position = UDim2.fromOffset(15, 14); title.ZIndex = 252
    local desc = text(card, info.Description or "", 12, Colors.MutedColor); desc.Position = UDim2.fromOffset(15, 40); desc.ZIndex = 252
    local bar = create("Frame", { BackgroundColor3 = Colors.PanelColor, Position = UDim2.fromOffset(15, 78), Size = UDim2.new(1, -30, 0, 8), ZIndex = 252 }, card); round(bar, 8)
    local fill = create("Frame", { BackgroundColor3 = Colors.AccentColor, Size = UDim2.new(0, 0, 1, 0), ZIndex = 253 }, bar); round(fill, 8)
    local loading = { CurrentStep = 0, TotalSteps = info.TotalSteps or 100 }
    function loading:SetProgress(value) tween(fill, 0.14, { Size = UDim2.new(math.clamp(value / 100, 0, 1), 0, 1, 0) }) end
    function loading:SetStep(step, total) self.CurrentStep = step; self.TotalSteps = total or self.TotalSteps; self:SetProgress(step / math.max(self.TotalSteps, 1) * 100) end
    function loading:SetMessage(value) desc.Text = tostring(value) end
    function loading:SetTitle(value) title.Text = tostring(value) end
    function loading:Destroy() overlay:Destroy() end
    return loading
end

-- One shared input listener handles the window hotkey and key-picker capture.
connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if Library.ActiveKeyCapture then
        local option = Library.ActiveKeyCapture
        local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name
        option:SetValue(key); Library.ActiveKeyCapture = nil; return
    end
    if Library.Window and input.KeyCode == Library.ToggleKeybind then Library.Window:Toggle() end
    for _, option in pairs(Library.Options) do
        if option.Type == "KeyPicker" and option.Value ~= "None" then
            local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name
            if key == tostring(option.Value) then
                option.Toggled = option.Mode == "Always" and true or not option.Toggled
                safe(option.Callback, option.Toggled)
            end
        end
    end
end)
connect(UserInputService.InputEnded, function(input)
    local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name
    for _, option in pairs(Library.Options) do
        if option.Type == "KeyPicker" and option.Mode == "Hold" and key == tostring(option.Value) then option.Toggled = false; safe(option.Callback, false) end
    end
end)

-- SaveManager stores indexed control values as JSON. Filesystem APIs are optional.
local SaveManager = { Library = Library, Folder = "GlassUI/Configs", SubFolder = "", Ignore = {}, Memory = {}, AutoloadConfig = nil }
local function safeName(name) return tostring(name or ""):gsub("[^%w%-%_ ]", "_"):gsub("^%s+", ""):gsub("%s+$", "") end
local function canWrite() return type(Compat.writefile) == "function" and type(Compat.readfile) == "function" end
function SaveManager:SetLibrary(value) self.Library = value or Library end
function SaveManager:SetFolder(value) assert(type(value) == "string" and value ~= "", "Invalid folder"); self.Folder = value end
function SaveManager:SetSubFolder(value) self.SubFolder = value or "" end
function SaveManager:GetPath(name) return self.Folder .. (self.SubFolder and self.SubFolder ~= "" and "/" .. self.SubFolder or "") .. "/" .. safeName(name) .. ".json" end
function SaveManager:CheckFolderTree()
    if type(Compat.makefolder) ~= "function" then return false end
    local path = ""
    for segment in string.gmatch(self.Folder .. (self.SubFolder and self.SubFolder ~= "" and "/" .. self.SubFolder or ""), "[^/]+") do
        path = path == "" and segment or path .. "/" .. segment
        local exists = false
        if type(Compat.isfolder) == "function" then local ok, value = pcall(Compat.isfolder, path); exists = ok and value end
        if not exists then pcall(Compat.makefolder, path) end
    end
    return true
end
function SaveManager:SetIgnoreIndexes(values) for _, value in ipairs(values or {}) do self.Ignore[value] = true end end
function SaveManager:IgnoreThemeSettings() self:SetIgnoreIndexes({ "ThemeManager_ThemeList", "ThemeManager_CustomThemeName" }) end
function SaveManager:SaveJSON(name)
    local data = { version = 1, name = name or "", objects = {} }
    for index, option in pairs(Library.Options) do
        if not self.Ignore[index] and option.Save ~= false then
            local value = option.Value
            if typeof(value) == "Color3" then value = { type = "Color3", value = value:ToHex() } end
            table.insert(data.objects, { idx = index, type = option.Type, value = value, mode = option.Mode, toggled = option.Toggled, transparency = option.Transparency })
        end
    end
    for index, option in pairs(Library.Toggles) do
        if not self.Ignore[index] and option.Save ~= false then table.insert(data.objects, { idx = index, type = option.Type, value = option.Value }) end
    end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then return "", false, tostring(encoded) end
    return encoded, true
end
function SaveManager:LoadJSON(content)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, content)
    if not ok or type(data) ~= "table" or type(data.objects) ~= "table" then return false, "Invalid JSON configuration" end
    for _, item in ipairs(data.objects) do
        local option = Library.Options[item.idx] or Library.Toggles[item.idx]
        if option and not self.Ignore[item.idx] then
            local value = item.value
            if type(value) == "table" and value.type == "Color3" then
                value = Color3.fromHex(value.value)
                if option.SetValueRGB then option:SetValueRGB(value, item.transparency) else option:SetValue(value) end
            else option:SetValue(value) end
            if item.mode then option.Mode = item.mode end
            if item.toggled ~= nil then option.Toggled = item.toggled end
        end
    end
    return true
end
function SaveManager:Save(name)
    name = safeName(name)
    if name == "" or name:lower() == "autoload" then return false, "Invalid config name" end
    local content, ok, err = self:SaveJSON(name)
    if not ok then return false, err end
    if canWrite() then self:CheckFolderTree(); local wrote, writeErr = pcall(Compat.writefile, self:GetPath(name), content); if not wrote then return false, tostring(writeErr) end
    else self.Memory[name] = content; Library.ConfigStore[name] = content end
    return true
end
function SaveManager:Load(name)
    name = safeName(name)
    local content
    if canWrite() then local ok, value = pcall(Compat.readfile, self:GetPath(name)); if ok then content = value end
    else content = self.Memory[name] or Library.ConfigStore[name] end
    if not content then return false, "Config not found" end
    return self:LoadJSON(content)
end
function SaveManager:Delete(name)
    name = safeName(name)
    if canWrite() and type(Compat.delfile) == "function" then local ok, err = pcall(Compat.delfile, self:GetPath(name)); if not ok then return false, tostring(err) end
    else self.Memory[name] = nil; Library.ConfigStore[name] = nil end
    return true
end
function SaveManager:RefreshConfigList()
    local names = {}
    if canWrite() and type(Compat.listfiles) == "function" then
        local ok, files = pcall(Compat.listfiles, self.Folder)
        if ok and type(files) == "table" then for _, path in ipairs(files) do local name = tostring(path):match("([^/\\]+)%.json$"); if name then table.insert(names, name) end end end
    else for name in pairs(self.Memory) do table.insert(names, name) end end
    table.sort(names); return names
end
function SaveManager:ExportJSON(name)
    local content, ok, err = self:SaveJSON(name)
    if not ok then return nil, err end
    if type(Compat.setclipboard) == "function" then pcall(Compat.setclipboard, content) end
    return content
end
function SaveManager:ImportJSON(content) return self:LoadJSON(content) end
function SaveManager:SaveAutoloadConfig(name)
    self.AutoloadConfig = safeName(name)
    if canWrite() then self:CheckFolderTree(); pcall(Compat.writefile, self.Folder .. "/autoload.txt", self.AutoloadConfig) end
    return true
end
function SaveManager:GetAutoloadConfig()
    if canWrite() and type(Compat.isfile) == "function" then
        local path = self.Folder .. "/autoload.txt"
        local ok, exists = pcall(Compat.isfile, path)
        if ok and exists then local readOk, value = pcall(Compat.readfile, path); if readOk then self.AutoloadConfig = value end end
    end
    return self.AutoloadConfig or "none", self.AutoloadConfig ~= nil
end
function SaveManager:LoadAutoloadConfig()
    local name, exists = self:GetAutoloadConfig()
    if not exists then return false, "No autoload config" end
    return self:Load(name)
end
function SaveManager:BuildConfigSection(tab)
    local group = tab:AddRightGroupbox("Configuration")
    local name = group:AddInput("GlassUI_ConfigName", { Text = "Config name", Placeholder = "my-settings" })
    group:AddButton("Save config", function() local ok, err = self:Save(name.Value); Library:Notify({ Title = ok and "Config saved" or "Save failed", Description = ok and name.Value or tostring(err) }) end)
    group:AddButton("Load config", function() local ok, err = self:Load(name.Value); Library:Notify({ Title = ok and "Config loaded" or "Load failed", Description = ok and name.Value or tostring(err) }) end)
    group:AddButton("Set autoload", function() self:SaveAutoloadConfig(name.Value); Library:Notify("Autoload config set to " .. tostring(name.Value)) end)
    group:AddButton("Export JSON", function() local json, err = self:ExportJSON(name.Value); Library:Notify(json and "JSON exported" or tostring(err)) end)
    return group
end

-- ThemeManager keeps appearance presets separate from saved script configuration.
local ThemeManager = {
    Library = Library, DefaultThemeName = "Violet", CurrentTheme = "Violet",
    BuiltInThemes = {
        Violet = { BackgroundColor = "#070A1C", SurfaceColor = "#131837", PanelColor = "#1C234C", AccentColor = "#BF5BFF", AccentSecondary = "#4170FF", OutlineColor = "#ADAAFF", FontColor = "#F7F6FF", MutedColor = "#A4A9CA" },
        Rose = { BackgroundColor = "#18081C", SurfaceColor = "#33163A", PanelColor = "#4C2051", AccentColor = "#FF5BBE", AccentSecondary = "#8658FF", OutlineColor = "#FFAAE0", FontColor = "#FFF5FC", MutedColor = "#D2A6CA" },
        Ocean = { BackgroundColor = "#05121D", SurfaceColor = "#0D2B3C", PanelColor = "#164051", AccentColor = "#36D6DC", AccentSecondary = "#4782FF", OutlineColor = "#82E4EB", FontColor = "#EEFCFF", MutedColor = "#93BECD" },
        Midnight = { BackgroundColor = "#080912", SurfaceColor = "#16192B", PanelColor = "#232943", AccentColor = "#8190FF", AccentSecondary = "#5368D6", OutlineColor = "#8F98CC", FontColor = "#F5F7FF", MutedColor = "#A1A6C3" },
        Mint = { BackgroundColor = "#071516", SurfaceColor = "#112B2B", PanelColor = "#1B3E3B", AccentColor = "#53E2B0", AccentSecondary = "#28B1C4", OutlineColor = "#84E8CA", FontColor = "#EFFFF9", MutedColor = "#98C5B5" },
    },
    CustomThemes = {},
}
function ThemeManager:SetLibrary(value) self.Library = value or Library end
function ThemeManager:ApplyThemeData(data)
    if type(data) ~= "table" then return false, "Invalid theme data" end
    local colors = {}
    for key, value in pairs(data) do
        if Colors[key] then
            if typeof(value) == "Color3" then colors[key] = value
            elseif type(value) == "string" then local ok, color = pcall(Color3.fromHex, value:gsub("#", "")); if ok then colors[key] = color end end
        end
    end
    Library:SetTheme(colors)
    return true
end
function ThemeManager:ApplyTheme(name)
    local data = self.BuiltInThemes[name] or self.CustomThemes[name]
    if not data and canWrite() then
        local ok, content = pcall(Compat.readfile, self.Library.SaveManager.Folder .. "/Themes/" .. safeName(name) .. ".json")
        if ok then local decoded, value = pcall(HttpService.JSONDecode, HttpService, content); if decoded then data = value end end
    end
    if not data then return false, "Theme not found" end
    self.CurrentTheme = name
    return self:ApplyThemeData(data)
end
function ThemeManager:BuildThemeData()
    local data = {}
    for key, color in pairs(Colors) do data[key] = "#" .. color:ToHex() end
    return data
end
function ThemeManager:SaveCustomTheme(name)
    name = safeName(name)
    if name == "" or name:lower() == "default" then return false, "Invalid theme name" end
    local data = self:BuildThemeData()
    self.CustomThemes[name] = data
    if canWrite() then
        self.Library.SaveManager:CheckFolderTree()
        local path = self.Library.SaveManager.Folder .. "/Themes"
        if type(Compat.makefolder) == "function" and type(Compat.isfolder) == "function" then local ok, exists = pcall(Compat.isfolder, path); if not ok or not exists then pcall(Compat.makefolder, path) end end
        local encoded = HttpService:JSONEncode(data)
        local ok, err = pcall(Compat.writefile, path .. "/" .. name .. ".json", encoded)
        if not ok then return false, tostring(err) end
    end
    return true
end
function ThemeManager:GetCustomTheme(name)
    if self.CustomThemes[name] then return self.CustomThemes[name] end
    if canWrite() then
        local path = self.Library.SaveManager.Folder .. "/Themes/" .. safeName(name) .. ".json"
        local ok, content = pcall(Compat.readfile, path)
        if ok then
            local decoded, data = pcall(HttpService.JSONDecode, HttpService, content)
            if decoded and type(data) == "table" then self.CustomThemes[name] = data; return data end
        end
    end
    return nil
end
function ThemeManager:ReloadCustomThemes()
    local names = {}
    for name in pairs(self.CustomThemes) do table.insert(names, name) end
    if canWrite() and type(Compat.listfiles) == "function" then
        local ok, files = pcall(Compat.listfiles, self.Library.SaveManager.Folder .. "/Themes")
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = tostring(path):match("([^/\\]+)%.json$")
                if name and not table.find(names, name) then table.insert(names, name) end
            end
        end
    end
    table.sort(names)
    return names
end
function ThemeManager:Delete(name)
    self.CustomThemes[name] = nil
    if type(Compat.delfile) == "function" then pcall(Compat.delfile, self.Library.SaveManager.Folder .. "/Themes/" .. safeName(name) .. ".json") end
    return true
end
function ThemeManager:SetDefaultTheme(name)
    if not self.BuiltInThemes[name] and not self.CustomThemes[name] then return false, "Theme not found" end
    self.DefaultThemeName = name; return true
end
function ThemeManager:SaveDefault(name) return self:SetDefaultTheme(name) end
function ThemeManager:LoadDefault() return self:ApplyTheme(self.DefaultThemeName or "Violet") end
function ThemeManager:ThemeUpdate() return self:ApplyThemeData(self:BuildThemeData()) end
function ThemeManager:CreateThemeManager(group)
    local names = {}
    for name in pairs(self.BuiltInThemes) do table.insert(names, name) end
    table.sort(names)
    group:AddDropdown("ThemeManager_ThemeList", { Text = "Preset", Values = names, Default = self.CurrentTheme, Callback = function(value) self:ApplyTheme(value) end })
    group:AddInput("ThemeManager_CustomThemeName", { Text = "Custom theme", Placeholder = "My theme" })
    group:AddButton("Save current theme", function()
        local input = Library.Options.ThemeManager_CustomThemeName
        local ok, err = self:SaveCustomTheme(input and input.Value or "")
        Library:Notify(ok and "Theme saved" or tostring(err))
    end)
    for _, key in ipairs({ "AccentColor", "AccentSecondary", "BackgroundColor", "SurfaceColor", "PanelColor", "OutlineColor", "FontColor" }) do
        group:AddLabel(key):AddColorPicker("Theme_" .. key, { Title = key, Default = Colors[key], Callback = function(value) Library:SetTheme({ [key] = value }) end })
    end
    return group
end
function ThemeManager:ApplyToTab(tab)
    return self:CreateThemeManager(tab:AddLeftGroupbox("Appearance"))
end
function ThemeManager:ApplyToGroupbox(group) return self:CreateThemeManager(group) end

Library.SaveManager = SaveManager
Library.ThemeManager = ThemeManager
Library.CreateSaveManager = function() return SaveManager end
Library.CreateThemeManager = function() return ThemeManager end
Library.Toggle = function(_, value) if Library.Window then return Library.Window:Toggle(value) end end

function Library:Unload()
    if Library.Unloaded then return end
    Library.Unloaded = true
    for _, callback in ipairs(Library.UnloadCallbacks) do safe(callback) end
    for _, toast in ipairs(Library.Notifications) do if toast.Destroy then toast:Destroy() end end
    for _, connection in ipairs(Library.Connections) do if connection.Connected then connection:Disconnect() end end
    if Library.ScreenGui then Library.ScreenGui:Destroy() end
    table.clear(Library.Connections); table.clear(Library.ThemeBindings)
    table.clear(Library.Options); table.clear(Library.Toggles); table.clear(Library.Tabs)
    Library.ScreenGui = nil; Library.Window = nil
end

ThemeManager:LoadDefault()
return Library
