-- Settings (reference): one dark row per Config/Settings entry with the
-- label on the left and a volume slider or a studded ON / OFF button.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Settings = require(Shared.Config.Settings)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Slider = require(script.Parent.Parent.Components.Slider)
local ClientSettings = require(script.Parent.Parent.Parent.Settings)
local Sfx = require(script.Parent.Parent.Parent.Sfx)
local Window = require(script.Parent.Window)

local new = Theme.new

local SettingsMenu = {}

local function row(list: Instance, order: number, label: string): Frame
	local frame = new("Frame", {
		Size = UDim2.new(1, -6, 0, 76),
		BackgroundColor3 = Color3.fromRGB(34, 35, 42),
		BackgroundTransparency = 0.25,
		LayoutOrder = order,
		Parent = list,
	}, { Theme.corner(8), Theme.stroke(3, Color3.fromRGB(12, 12, 16)) })
	Theme.label({
		Size = UDim2.new(0.5, -20, 0, 42),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 20, 0.5, 0),
		Text = label,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	return frame
end

function SettingsMenu.build(body: Frame)
	local list = Window.list(body, 12)
	local updates: { () -> () } = {}
	for i, setting in Settings.List do
		local frame = row(list, i, setting.label)
		if setting.kind == "slider" then
			local slider = Slider.new({
				Size = UDim2.new(0.44, 0, 0, 60),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -18, 0.5, 0),
				Parent = frame,
			}, function(value)
				ClientSettings.preview(setting.id, value)
				Sfx.refreshMusic()
			end, function(value)
				Window.report(Net.func("SetSetting"):InvokeServer(setting.id, value))
				ClientSettings.settle(setting.id)
			end)
			table.insert(updates, function()
				slider.set(ClientSettings.level(setting.id) * 100)
			end)
		else
			local button = Window.button({
				Size = UDim2.fromOffset(180, 56),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -22, 0.5, 0),
				Text = "ON",
			}, "Green", function()
				Window.report(Net.func("SetSetting"):InvokeServer(setting.id, not ClientSettings.get(setting.id)))
			end)
			button.Parent = frame
			table.insert(updates, function()
				local on = ClientSettings.get(setting.id)
				Theme.setText(button, if on then "ON" else "OFF")
				Window.recolor(button, if on then "Green" else "Red")
			end)
		end
	end
	return function()
		for _, update in updates do
			update()
		end
	end
end

return SettingsMenu
