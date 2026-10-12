-- Inventory › Boosts (reference "My Boosts"): one tile per potion with its
-- count, a timer while active, and a white info card for the selected one
-- (name, effect, duration, Use). Built once; refresh updates in place
-- because timers change on every snapshot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Potions = require(Shared.Config.Potions)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local BoostsTab = {}

local ICONS = { hops = "potion_hops", wins = "potion_wins", luck = "potion_luck" }
local STAT_NAMES = { hops = "Hops", wins = "Wins", luck = "Luck" }
local INK = Color3.fromRGB(40, 42, 54)

local function clock(seconds: number): string
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function infoCard(parent: Instance)
	local card = new("Frame", {
		Name = "Info",
		Size = UDim2.new(0, 300, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundColor3 = Color3.fromRGB(250, 250, 252),
		Parent = parent,
	}, {
		Theme.corner(16),
		Theme.stroke(4, Color3.fromRGB(12, 12, 16)),
		new("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}),
	})
	Gradient.apply(card, "Silver")
	local function line(y: number, h: number, color: Color3): TextLabel
		return Theme.label({
			Size = UDim2.new(1, 0, 0, h),
			Position = UDim2.fromOffset(0, y),
			Text = "",
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = card,
		})
	end
	local icon = new("Frame", {
		Size = UDim2.fromOffset(150, 150),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -6),
		BackgroundTransparency = 1,
		Parent = card,
	})
	local parts = {
		card = card,
		icon = icon,
		title = line(0, 38, INK),
		effect = line(42, 30, Color3.fromRGB(40, 170, 40)),
		duration = line(74, 26, Color3.fromRGB(110, 112, 128)),
		about = line(0, 46, INK),
		hint = line(0, 22, Color3.fromRGB(120, 122, 138)),
	}
	parts.about.Position = UDim2.new(0, 0, 1, -138)
	parts.hint.Position = UDim2.new(0, 0, 1, -86)
	local use = Window.button({
		Size = UDim2.new(1, 0, 0, 54),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Text = "USE",
	}, "Green", function() end)
	use.Parent = card
	parts.use = use
	return parts
end

function BoostsTab.build(content: Frame)
	local panel = Window.inset(content, { Size = UDim2.new(1, -316, 1, 0) })
	local grid = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = panel }, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(124, 124),
			CellPadding = UDim2.fromOffset(12, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local info = infoCard(content)
	local selected = Potions.List[1].id
	local lastData = nil
	local tiles = {}
	local refresh: (any) -> ()

	local function showInfo(data)
		local potion = Potions.ById[selected]
		local count = (data.potions or {})[potion.id] or 0
		local left = (data.potionTimers or {})[potion.id] or 0
		info.title.Text = potion.name
		info.effect.Text = `{potion.factor}x {STAT_NAMES[potion.stat]}`
		info.duration.Text = if left > 0 then `Active: {clock(left)} left` else `{potion.duration // 60} minutes`
		info.about.Text = `Doubles every {STAT_NAMES[potion.stat]} you earn while it lasts.`
		info.hint.Text = "Click to use • Duration stacks"
		Theme.setText(info.use, if count > 0 then `USE  (x{count})` else "NONE LEFT")
		Window.recolor(info.use, if count > 0 then "Green" else "Grey")
		if info.icon:GetAttribute("Potion") ~= potion.id then
			info.icon:SetAttribute("Potion", potion.id)
			Window.clear(info.icon)
			Theme.pop(Icon.new(ICONS[potion.stat], { Size = UDim2.fromScale(1, 1), Parent = info.icon }))
		end
	end

	info.use.Activated:Connect(function()
		Window.report(Net.func("UsePotion"):InvokeServer(selected))
	end)

	for i, potion in Potions.List do
		local tile = new("TextButton", { Name = potion.id, Text = "", AutoButtonColor = false, LayoutOrder = i, Parent = grid }, {
			Theme.corner(14),
			Theme.stroke(3, Color3.fromRGB(150, 152, 162)),
		})
		Gradient.apply(tile, { Color3.fromRGB(116, 117, 126), Color3.fromRGB(70, 71, 80) })
		Icon.new(ICONS[potion.stat], {
			Size = UDim2.fromScale(0.78, 0.78),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.48),
			ZIndex = 2,
			Parent = tile,
		})
		local count = Theme.label({
			Size = UDim2.new(0.6, 0, 0, 34),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -6, 1, -2),
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3,
			Parent = tile,
		})
		local timer = Theme.label({
			Size = UDim2.new(1, -8, 0, 26),
			Position = UDim2.fromOffset(4, 4),
			Text = "",
			TextColor3 = Color3.fromRGB(120, 255, 120),
			ZIndex = 3,
			Parent = tile,
		})
		Theme.textStroke(3).Parent = timer
		local scale = new("UIScale", { Parent = tile })
		Theme.hover(tile, scale)
		tile.Activated:Connect(function()
			selected = potion.id
			if lastData then
				refresh(lastData)
			end
		end)
		tiles[potion.id] = { tile = tile, count = count, timer = timer }
	end

	refresh = function(data)
		lastData = data
		for id, parts in tiles do
			local n = (data.potions or {})[id] or 0
			local left = (data.potionTimers or {})[id] or 0
			parts.count.Text = `x{n}`
			parts.timer.Text = if left > 0 then clock(left) else ""
			parts.tile:FindFirstChildOfClass("UIStroke").Color = if id == selected
				then Color3.fromRGB(140, 222, 255)
				else Color3.fromRGB(150, 152, 162)
			parts.tile:FindFirstChildOfClass("UIStroke").Thickness = if id == selected then 4 else 3
		end
		showInfo(data)
	end
	return refresh
end

return BoostsTab
