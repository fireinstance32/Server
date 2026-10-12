-- Settings: one row per Config/Settings entry with an ON/OFF button.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Settings = require(Shared.Config.Settings)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Icon = require(script.Parent.Parent.Components.Icon)
local ClientSettings = require(script.Parent.Parent.Parent.Settings)
local Window = require(script.Parent.Window)

local SettingsMenu = {}

function SettingsMenu.build(body: Frame)
	local list = Window.list(body, 10)
	local buttons = {}
	for i, setting in Settings.List do
		local row = Window.card(list, i)
		row.Size = UDim2.new(1, -10, 0, 70)
		Icon.new(setting.icon, { Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(8, 6), Parent = row })
		Theme.label({
			Size = UDim2.new(1, -260, 0, 40),
			Position = UDim2.fromOffset(78, 15),
			Text = setting.label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		local button = Window.button({
			Size = UDim2.fromOffset(150, 52),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Text = "ON",
		}, "Green", function()
			Window.report(Net.func("SetSetting"):InvokeServer(setting.id, not ClientSettings.get(setting.id)))
		end)
		button.Parent = row
		buttons[setting.id] = button
	end
	return function()
		for id, button in buttons do
			local on = ClientSettings.get(id)
			Theme.setText(button, if on then "ON" else "OFF")
			Gradient.apply(button, if on then "Green" else "Red")
		end
	end
end

return SettingsMenu
