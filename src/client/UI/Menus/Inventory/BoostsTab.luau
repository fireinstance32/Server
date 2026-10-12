-- Inventory › Boosts: potion counts, time left, and Use.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Potions = require(Shared.Config.Potions)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Window = require(script.Parent.Parent.Window)

local BoostsTab = {}

local function clock(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

-- Rows are built once; refresh only updates text and colours in place (the
-- timers change on every snapshot).
function BoostsTab.build(content: Frame)
	local list = Window.list(content)
	local rows = {}
	for i, potion in Potions.List do
		local row = Window.card(list, i)
		row.Size = UDim2.new(1, -10, 0, 80)
		Theme.label({ Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(8, 8), Text = potion.icon, Parent = row })
		local title = Theme.label({
			Size = UDim2.new(1, -300, 0, 34),
			Position = UDim2.fromOffset(80, 6),
			Text = potion.name,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		local status = Theme.label({
			Size = UDim2.new(1, -300, 0, 28),
			Position = UDim2.fromOffset(80, 44),
			Text = "",
			TextColor3 = Theme.Colors.Grey,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		Theme.textStroke().Parent = status
		local use = Window.button({
			Size = UDim2.fromOffset(150, 52),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Text = "Use",
		}, "Grey", function()
			Window.report(Net.func("UsePotion"):InvokeServer(potion.id))
		end)
		use.Parent = row
		rows[potion.id] = { title = title, status = status, use = use }
	end

	return function(data)
		for _, potion in Potions.List do
			local row = rows[potion.id]
			local count = (data.potions or {})[potion.id] or 0
			local left = (data.potionTimers or {})[potion.id] or 0
			row.title.Text = `{potion.name}  x{count}`
			row.status.Text = if left > 0 then `Active: x{potion.factor} for {clock(left)}` else `x{potion.factor} {potion.stat} for {potion.duration // 60} min`
			row.status.TextColor3 = if left > 0 then Color3.fromRGB(120, 255, 120) else Theme.Colors.Grey
			Gradient.apply(row.use, if count > 0 then "Green" else "Grey")
		end
	end
end

return BoostsTab
