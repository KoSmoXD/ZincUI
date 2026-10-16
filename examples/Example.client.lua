-- ZincUI 0.2.1 demo. Place ZincUI as a ModuleScript in ReplicatedStorage.
-- Run this as a LocalScript in StarterPlayerScripts (client-only).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Zinc = require(ReplicatedStorage:WaitForChild("ZincUI"))

local Window = Zinc:CreateWindow({
    Title = "ZincUI XP Demo",
    Subtitle = "Independent example project",
    Theme = "XP",
    Size = UDim2.fromOffset(748, 510),
    ToggleKey = Enum.KeyCode.RightControl,
})

local Home = Window:CreateTab("Home")
local Settings = Home:CreateSection("General")

Settings:AddLabel("ZincUI can be used independently of Zinc Hub.")

Settings:AddToggle({
    Name = "Notifications enabled",
    Flag = "notifications",
    Default = true,
    Callback = function(value)
        Window:SetStatus(value and "Notifications enabled" or "Notifications disabled")
    end,
})

Settings:AddSlider({
    Name = "Volume",
    Flag = "volume",
    Min = 0,
    Max = 100,
    Increment = 5,
    Default = 50,
    Callback = function(value)
        Window:SetStatus("Volume: " .. tostring(value))
    end,
})

Settings:AddDropdown({
    Name = "Window theme",
    Flag = "theme",
    Options = {"XP", "Dark", "Midnight"},
    Default = "XP",
    Callback = function(value)
        if value then Window:SetTheme(value) end
    end,
})

Settings:AddButton({
    Name = "Notification preview",
    ButtonText = "Show",
    Callback = function()
        if Window:GetFlag("notifications") then
            Window:Notify({Title = "ZincUI", Content = "Hello from the XP window!", Duration = 3})
        end
    end,
})

local Personalize = Window:CreateTab("Personalize")
local Appearance = Personalize:CreateSection("Appearance")

Appearance:AddTextbox({
    Name = "Display name",
    Flag = "display_name",
    Default = "Player",
    Placeholder = "Enter a display name",
    Callback = function(value)
        Window:SetStatus("Name: " .. value)
    end,
})

Appearance:AddColorPicker({
    Name = "Accent color",
    Flag = "accent_color",
    Default = Color3.fromRGB(49, 106, 197),
    Callback = function(color)
        Window:SetAccent(color)
    end,
})

Appearance:AddKeybind({
    Name = "Notification shortcut",
    Flag = "notification_key",
    Default = Enum.KeyCode.F,
    Callback = function()
        Window:Notify({Title = "Shortcut", Content = "Keybind activated.", Duration = 2})
    end,
})

local Config = Window:CreateTab("Config")
local Tools = Config:CreateSection("Configuration")
local saved = nil

Tools:AddButton({
    Name = "Save current values in memory",
    ButtonText = "Save",
    Callback = function()
        saved = Window:ExportConfig()
        Window:SetStatus("Configuration exported to memory")
    end,
})

Tools:AddButton({
    Name = "Restore saved values",
    ButtonText = "Restore",
    Callback = function()
        if not saved then
            Window:SetStatus("No saved configuration yet")
            return
        end
        local ok, err = Window:ImportConfig(saved)
        Window:SetStatus(ok and "Configuration restored" or ("Error: " .. tostring(err)))
    end,
})

Window:SetStatus("Ready")
