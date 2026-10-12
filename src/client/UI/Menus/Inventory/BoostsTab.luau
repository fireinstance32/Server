-- Inventory › Boosts: potion counts, time left, and Use.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Potions = require(Shared.Config.Potions)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)

local BoostsTab = {}

local function clock(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

function BoostsTab.build(content: Frame)
	local list = Window.list(content)
	return function(data)
		Window.clear(list)
		for i, potion in Potions.List do
			local row = Window.card(list, i)
			row.Size = UDim2.new(1, -10, 0, 80)
			Theme.label({ Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(8, 8), Text = potion.icon, Parent = row })
			Theme.label({
				Size = UDim2.new(1, -300, 0, 34),
				Position = UDim2.fromOffset(80, 6),
				Text = `{potion.name}  x{(data.potions or {})[potion.id] or 0}`,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})
			local left = (data.potionTimers or {})[potion.id] or 0
			local status = Theme.label({
				Size = UDim2.new(1, -300, 0, 28),
				Position = UDim2.fromOffset(80, 44),
				Text = if left > 0 then `Active: x{potion.factor} for {clock(left)}` else `x{potion.factor} {potion.stat} for {potion.duration // 60} min`,
				TextColor3 = if left > 0 then Color3.fromRGB(120, 255, 120) else Theme.Colors.Grey,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})
			Theme.textStroke().Parent = status
			local use = Window.button({
				Size = UDim2.fromOffset(150, 52),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Text = "Use",
			}, if ((data.potions or {})[potion.id] or 0) > 0 then "Green" else "Grey", function()
				Window.report(Net.func("UsePotion"):InvokeServer(potion.id))
			end)
			use.Parent = row
		end
	end
end

return BoostsTab
