# ZincUI

**ZincUI 0.2.1** is a standalone, client-side Roblox Luau UI library with a classic Windows XP-inspired desktop-window layout. You can build your own app-style interface with tabs, sections, settings, and notifications. No Obsidian, Linoria, or third-party UI library is required.

**Features:** one draggable window; blue title bar with minimize and close; left navigation; classic square and beveled controls; bottom status bar; notifications; touch and mouse input; automatic scaling; configurable themes; flags and JSON import/export; connection cleanup on destroy.

## Get started (Roblox Studio)

1. Download [ZincUI.lua](ZincUI.lua).
2. In `ReplicatedStorage`, create a **ModuleScript** named `ZincUI` and paste the contents of that file.
3. Create a **LocalScript** in `StarterPlayer > StarterPlayerScripts` and paste the example below.

```lua
local Zinc = require(game:GetService("ReplicatedStorage"):WaitForChild("ZincUI"))

local Window = Zinc:CreateWindow({
    Title = "My XP App",
    Subtitle = "ZincUI 0.2.1",
    Theme = "XP",
    ToggleKey = Enum.KeyCode.RightControl,
})

local Main = Window:CreateTab("Main")
local Settings = Main:CreateSection("General settings")

Settings:AddToggle({
    Name = "Feature enabled",
    Flag = "feature_enabled",
    Default = false,
    Callback = function(enabled)
        Window:SetStatus(enabled and "Feature enabled" or "Feature disabled")
    end,
})

Settings:AddButton({
    Name = "Notification test",
    ButtonText = "Show",
    Callback = function()
        Window:Notify({
            Title = "ZincUI",
            Content = "This is a notification.",
            Duration = 3,
        })
    end,
})
```

For a complete demonstration, see [examples/Example.client.lua](examples/Example.client.lua).

## Script executor usage (optional)

In client environments that support both `loadstring` and `game:HttpGet`, the same library can be loaded directly:

```lua
local Zinc = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/KoSmoXD/ZincUI/main/ZincUI.lua"
))()

local Window = Zinc:CreateWindow({Title = "My script", Theme = "XP"})
local Tab = Window:CreateTab("Home")
local Section = Tab:CreateSection("Actions")
Section:AddButton({Name = "Test", Callback = function() print("Clicked!") end})
```

This direct-loading method is **not** the normal Roblox Studio LocalScript installation. For your own Roblox experience, prefer the ModuleScript approach.

## API

```lua
-- Library
Zinc:CreateWindow({Title, Subtitle?, Theme?, Size?, Parent?, DisplayOrder?, AutoScale?, ToggleKey?})

-- Window
Window:CreateTab("Home")
Window:CreateTab({Name = "Home"})
Window:SetTheme("XP")       -- XP, Dark, Midnight, or a custom Color3 table
Window:SetAccent(Color3.fromRGB(49, 106, 197))
Window:SetStatus("Ready")
Window:Notify({Title = "Info", Content = "Message", Duration = 3})
Window:Toggle()             -- show/hide
Window:Toggle(true)         -- show
Window:Minimize()
Window:GetFlag("some_flag")
Window:SetFlag("some_flag", value)
local json = Window:ExportConfig()
local ok, reason = Window:ImportConfig(json)
Window:Destroy()

-- Navigation
local tab = Window:CreateTab("Main")
tab:Select()
local section = tab:CreateSection("Player")

-- Controls
section:AddLabel("Static text")
section:AddButton({Name = "Action", ButtonText = "Run", Callback = function() end})
section:AddToggle({Name = "Enabled", Flag = "enabled", Default = false, Callback = function(value) end})
section:AddSlider({Name = "Speed", Flag = "speed", Min = 0, Max = 100, Increment = 1, Default = 16, Callback = function(value) end})
section:AddDropdown({Name = "Theme", Flag = "theme", Options = {"XP","Dark","Midnight"}, Default = "XP", Callback = function(value) end})
section:AddTextbox({Name = "Name", Flag = "name", Default = "", Placeholder = "enter name", Callback = function(value) end})
section:AddKeybind({Name = "Hotkey", Flag = "hotkey", Default = Enum.KeyCode.F, Callback = function(key) end, OnChanged = function(key) end})
section:AddColorPicker({Name = "Color", Flag = "color", Default = Color3.fromRGB(255,255,255), Callback = function(color) end})
```

Control return values provide `Get()` and `Set(value, silent?)`. Dropdowns also provide `Refresh(options, keepSelection?)`. Labels expose `Set(text)`. Assign unique `Flag` values to controls you want included in JSON export and import. Color3 values serialize to RGB arrays; keybinds serialize by enum name. Importing JSON calls callbacks by default; set `silent=true` to suppress these when appropriate.

**Notes:** The close button invokes `Window:Destroy()`. Right Control toggles window visibility unless you override `ToggleKey` or set it to `false`. `AutoScale` adjusts the window size relative to the viewport. UI construction must run on the client; it cannot be used to create ServerScriptService GUIs directly.

## Themes

`XP` is the default. `Dark` and `Midnight` are included; they retain the same single-window layout. Supply a custom table of `Color3` fields to override the theme:

```lua
Window:SetTheme({
    Accent = Color3.fromRGB(25, 112, 194),
    TitleStart = Color3.fromRGB(10, 36, 106),
    TitleEnd = Color3.fromRGB(67, 145, 232),
})
```

Unspecified custom colors inherit from XP. The themes are visual settings only; they do not modify gameplay features.

## Compatibility and limitations

- Intended for client-side Roblox Luau using `PlayerGui`. The optional `gethui()` path is used only if it exists.
- No key system, anti-DEX functionality, or automatic game modifications.
- Rendering, input behavior, and touch interaction require testing in Roblox; a Lua syntax check alone cannot validate the live client.
- The Windows XP appearance is a stylistic recreation, not a Microsoft UI asset bundle.
- To use the library inside **Zinc Hub**, see [KoSmoXD/thinkinghub](https://github.com/KoSmoXD/thinkinghub). The hub's adapter is separate from this standalone library.

## License

[MIT](LICENSE) — you can use and modify ZincUI in your own projects under the license terms.
