-- "~ Gift ~": pick a player in the server, then gift any giftable pass or
-- product ([GIFT] products in Config/Monetization).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local GiftSection = {}

local function others(): { Player }
	local list = {}
	for _, player in Players:GetPlayers() do
		if player ~= Players.LocalPlayer then
			table.insert(list, player)
		end
	end
	return list
end

function GiftSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Gift", order)

	local pickerRow = Window.card(list, order + 1)
	pickerRow.Size = UDim2.new(1, -10, 0, 64)
	local targetIndex = 1
	local picker
	local function currentTarget(): Player?
		local players = others()
		if #players == 0 then
			return nil
		end
		targetIndex = (targetIndex - 1) % #players + 1
		return players[targetIndex]
	end
	local function refreshPicker()
		local target = currentTarget()
		picker.Text = if target then `🎁 To: {target.DisplayName}  ▶` else "No other players here"
	end
	picker = Window.button({
		Size = UDim2.new(1, -20, 0, 48),
		Position = UDim2.fromOffset(10, 8),
		Text = "",
	}, "Pink", function()
		targetIndex += 1
		refreshPicker()
	end)
	picker.Parent = pickerRow
	refreshPicker()

	local items = {}
	for name in Monetization.GiftIds do
		table.insert(items, name)
	end
	table.sort(items)
	local grid = new("Frame", {
		Size = UDim2.new(1, -10, 0, math.ceil(#items / 3) * 62),
		BackgroundTransparency = 1,
		LayoutOrder = order + 2,
		Parent = list,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.new(1 / 3, -8, 0, 54),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.Name,
		}),
	})
	for _, name in items do
		local item = Monetization.Passes[name] or Monetization.Products[name]
		local button = Window.button({
			Name = name,
			Text = `{item.label}  \u{E002}{item.price}`,
		}, "Purple", function()
			local target = currentTarget()
			if target then
				Purchases.gift(name, target.UserId)
			end
		end)
		button.Font = Enum.Font.BuilderSansBold
		button.Parent = grid
	end

	return refreshPicker
end

return GiftSection
