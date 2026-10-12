-- Pets tab bottom bar: Auto Delete rarity toggles, Delete Unequipped
-- (press twice to confirm), and Equip Best.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Parent.Components.Gradient)
local Window = require(script.Parent.Parent.Parent.Window)

local new = Theme.new

local Toolbar = {}

local AUTO_DELETE = { "Common", "Uncommon", "Rare", "Epic" }

function Toolbar.build(content: Frame, getData: () -> any)
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		Parent = content,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	Theme.label({ Size = UDim2.fromOffset(96, 40), Text = "Auto Delete:", LayoutOrder = 0, Parent = bar })
	local chips = {}
	for i, rarity in AUTO_DELETE do
		local chip = Window.button({
			Size = UDim2.fromOffset(86, 40),
			Text = rarity,
			LayoutOrder = i,
		}, "Grey", function()
			local data = getData()
			local on = data and data.autoDelete and data.autoDelete[rarity]
			Window.report(Net.func("SetAutoDelete"):InvokeServer(rarity, not on))
		end)
		chip.Parent = bar
		chips[rarity] = chip
	end

	local armed = false
	local deleteButton
	deleteButton = Window.button({
		Size = UDim2.fromOffset(150, 44),
		Text = "Delete Unequipped",
		LayoutOrder = 10,
	}, "Red", function()
		if not armed then
			armed = true
			deleteButton.Text = "Tap again!"
			task.delay(2.5, function()
				armed = false
				deleteButton.Text = "Delete Unequipped"
			end)
			return
		end
		armed = false
		deleteButton.Text = "Delete Unequipped"
		local data = getData()
		local uids = {}
		for uid, pet in (data and data.pets or {}) do
			if not pet.equipped and not pet.locked then
				table.insert(uids, uid)
			end
		end
		Window.report(Net.func("DeletePets"):InvokeServer(uids))
	end)
	deleteButton.Parent = bar

	local equipBest = Window.button({
		Size = UDim2.fromOffset(140, 44),
		Text = "Equip Best",
		LayoutOrder = 11,
	}, "Green", function()
		Window.report(Net.func("EquipBestPets"):InvokeServer())
	end)
	equipBest.Parent = bar

	return function(data)
		for rarity, chip in chips do
			Gradient.apply(chip, if data.autoDelete and data.autoDelete[rarity] then "Red" else "Grey")
		end
	end
end

return Toolbar
