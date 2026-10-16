-- ZincUI Lua 5.4 API smoke tests.
-- Run from repository root: lua5.4 tests/api_smoke.lua
-- Roblox GUI primitives and input are mocked. Rendering must be checked in Roblox.
local function signal()
    local s = {handlers = {}}
    function s:Connect(fn)
        local c = {Connected = true}
        function c:Disconnect() self.Connected = false end
        self.handlers[#self.handlers + 1] = {fn = fn, conn = c}
        return c
    end
    function s:Fire(...)
        for _, h in ipairs(self.handlers) do
            if h.conn.Connected then h.fn(...) end
        end
    end
    return s
end

local function vector(x, y)
    return setmetatable({X = x, Y = y}, {
        __sub = function(a, b) return vector(a.X - b.X, a.Y - b.Y) end,
    })
end
Vector2 = {new = vector}
local function color(r, g, b)
    return {R = r / 255, G = g / 255, B = b / 255, __type = "Color3"}
end
Color3 = {fromRGB = color, new = function(r, g, b) return color(r * 255, g * 255, b * 255) end}
local function dimension(sx, ox, sy, oy)
    return {X = {Scale = sx, Offset = ox}, Y = {Scale = sy, Offset = oy}, __type = "UDim2"}
end
UDim2 = {
    new = dimension,
    fromOffset = function(x, y) return dimension(0, x, 0, y) end,
    fromScale = function(x, y) return dimension(x, 0, y, 0) end,
}
UDim = {new = function(scale, offset) return {Scale = scale, Offset = offset} end}
ColorSequence = {new = function(a, b) return {a, b} end}
typeof = function(v)
    if type(v) == "table" and v.__type then return v.__type end
    return type(v)
end
math.round = function(n) return math.floor(n + .5) end
math.clamp = function(n, a, b) return math.max(a, math.min(b, n)) end
warn = function(...) print("WARN", ...) end
task = {delay = function(_seconds, _fn) end}

Enum = setmetatable({}, {__index = function(self, name)
    local category = {}
    setmetatable(category, {__index = function(cat, value)
        local entry = {Name = value, EnumType = category, __type = "EnumItem"}
        rawset(cat, value, entry)
        return entry
    end})
    rawset(self, name, category)
    return category
end})

local objects = {}
local function newNode(class)
    local n = {
        ClassName = class, Name = class, ZIndex = 1, Children = {},
        AbsoluteSize = vector(300, 150), AbsolutePosition = vector(0, 0),
        InputBegan = signal(), InputEnded = signal(), Activated = signal(),
        MouseEnter = signal(), MouseLeave = signal(), Destroyed = false,
    }
    function n:IsA(needed) return self.ClassName == needed end
    function n:GetChildren() return self.Children end
    function n:GetPropertyChangedSignal(_key)
        self.propertySignals = self.propertySignals or {}
        local key = _key
        self.propertySignals[key] = self.propertySignals[key] or signal()
        return self.propertySignals[key]
    end
    function n:Destroy()
        self.Destroyed = true
        self.Parent = nil
    end
    objects[#objects + 1] = n
    return setmetatable(n, {__newindex = function(t, k, v)
        rawset(t, k, v)
        if k == "Parent" and v and v.Children then
            v.Children[#v.Children + 1] = t
        end
    end})
end
Instance = {new = newNode}

local gui = newNode("PlayerGui")
local player = {PlayerGui = gui}
function player:WaitForChild(name)
    assert(name == "PlayerGui")
    return gui
end
local players = {LocalPlayer = player}
local input = {InputBegan = signal(), InputChanged = signal(), InputEnded = signal()}
function input:GetFocusedTextBox() return nil end
local encoded, serial = {}, 0
local http = {}
function http:GenerateGUID() serial = serial + 1; return tostring(serial) end
function http:JSONEncode(data)
    serial = serial + 1
    encoded[serial] = data
    return tostring(serial)
end
function http:JSONDecode(value) return assert(encoded[tonumber(value)], "unknown JSON") end
local services = {Players = players, UserInputService = input, HttpService = http}
game = {GetService = function(_self, name) return assert(services[name], name) end}
workspace = newNode("Workspace")
workspace.CurrentCamera = newNode("Camera")
workspace.CurrentCamera.ViewportSize = vector(1600, 900)

local Zinc = assert(loadfile("ZincUI.lua"))()
assert(Zinc.Version == "0.2.1", "incorrect ZincUI version")
assert(Zinc.Themes.XP and Zinc.Themes.Dark and Zinc.Themes.Midnight)
local window = Zinc:CreateWindow({Title = "Test", Theme = "XP"})
assert(window._theme.Background.R == 236 / 255, "XP palette incorrectly overridden")
assert(window._statusLabel.Text == "Ready", "XP status bar missing")
assert(window._main and window._main.Parent == window._gui and window._gui.Parent == gui, "window not mounted to PlayerGui")
local home = window:CreateTab("Home")
local section = home:CreateSection("Test controls")
local seen = {}
local label = section:AddLabel("Test")
label:Set("Ready for tests")
local toggle = section:AddToggle({
    Name = "Enabled", Flag = "enabled", Default = false,
    Callback = function(value) seen.enabled = value end,
})
local slider = section:AddSlider({
    Name = "Value", Flag = "amount", Min = 0, Max = 100, Increment = 5, Default = 20,
    Callback = function(value) seen.amount = value end,
})
local dropdown = section:AddDropdown({
    Name = "Choice", Flag = "choice", Options = {"XP", "Dark"}, Default = "XP",
    Callback = function(value) seen.choice = value end,
})
local textbox = section:AddTextbox({
    Name = "Text", Flag = "text", Default = "old",
    Callback = function(value) seen.text = value end,
})
local keybind = section:AddKeybind({
    Name = "Key", Flag = "key", Default = Enum.KeyCode.F,
})
local picker = section:AddColorPicker({
    Name = "Tint", Flag = "tint", Default = Color3.fromRGB(255, 0, 0),
})
local clicks = 0
local button = section:AddButton({
    Name = "Action", ButtonText = "Run",
    Callback = function() clicks = clicks + 1 end,
})
assert(toggle:Get() == false and slider:Get() == 20 and dropdown:Get() == "XP")
button.Press()
assert(clicks == 1, "button action not called")
toggle:Set(true)
slider:Set(43)
dropdown:Set("Dark")
textbox:Set("hello")
keybind:Set(Enum.KeyCode.RightControl)
picker:Set(Color3.fromRGB(0, 128, 255))
assert(seen.enabled == true and seen.amount == 45 and seen.choice == "Dark" and seen.text == "hello")
assert(window:GetFlag("amount") == 45)
assert(window:GetFlag("key") == Enum.KeyCode.RightControl)
window:SetStatus("Working")
assert(window._statusLabel.Text == "Working")
window:SetTheme("Midnight")
window:SetTheme("XP")
window:SetAccent(Color3.fromRGB(0, 110, 210))
window:Notify({Title = "Test", Content = "Mock notification", Duration = 1})

local exported = window:ExportConfig()
toggle:Set(false)
slider:Set(0)
textbox:Set("replaced")
local restored, reason = window:ImportConfig(exported)
assert(restored, tostring(reason))
assert(toggle:Get() == true and slider:Get() == 45 and textbox:Get() == "hello")
assert(keybind:Get() == Enum.KeyCode.RightControl and picker:Get().G == 128 / 255)
dropdown:Refresh({"XP", "Dark", "Midnight"}, true)
assert(dropdown:Get() == "Dark")
window:Minimize(true)
assert(window._minimized and not window._sidebar.Visible)
window:Minimize(false)
assert(not window._minimized and window._sidebar.Visible)
window:Toggle(false)
assert(window._main.Visible == false)
window:Toggle(true)
assert(window._main.Visible == true)
window:Destroy()
window:Destroy()
assert(window._gui.Destroyed, "window GUI must be destroyed")
assert(#Zinc._windows == 0, "window registry leaked")
for _, hook in ipairs(input.InputBegan.handlers) do
    assert(not hook.conn.Connected, "input connection leaked")
end
print("PASS: ZincUI client API, XP theme, flags, callbacks, config roundtrip and teardown")
