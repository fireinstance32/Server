-- Inventory › Pets: "🎒 n / 50", "Equipped n / 3", pet cards, Equip Best.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local PetsTab = {}

local function sortedPets(data)
	local entries = {}
	for uid, pet in data.pets do
		local def = Pets.ById[pet.id]
		if def then
			table.insert(entries, { uid = uid, pet = pet, def = def })
		end
	end
	table.sort(entries, function(a, b)
		if a.pet.equipped ~= b.pet.equipped then
			return a.pet.equipped
		end
		return a.def.bonus > b.def.bonus
	end)
	return entries
end

function PetsTab.build(content: Frame)
	local storage = Theme.label({
		Size = UDim2.new(0.4, 0, 0, 40),
		Text = "🎒 0 / 50",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content,
	})
	local equippedLabel = Theme.label({
		Size = UDim2.new(0.5, 0, 0, 40),
		Position = UDim2.fromScale(0.5, 0),
		Text = "Equipped: 0 / 3",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = content,
	})

	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 1, -116),
		Position = UDim2.fromOffset(0, 48),
		BackgroundColor3 = Color3.fromRGB(30, 30, 36),
		Parent = content,
	}, { Theme.corner(12), Theme.stroke(3) })
	local grid = Window.grid(holder, 130, 150)

	local equipBest = Window.button({
		Size = UDim2.fromOffset(190, 52),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, -8),
		Text = "Equip Best",
	}, "Green", function()
		Window.report(Net.func("EquipBestPets"):InvokeServer())
	end)
	equipBest.Parent = content
	local hint = Theme.label({
		Size = UDim2.new(1, -210, 0, 32),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -18),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content,
	})

	return function(data)
		Window.clear(grid)
		local entries = sortedPets(data)
		local equipped, bonus = 0, 0
		for _, entry in entries do
			if entry.pet.equipped then
				equipped += 1
				bonus += entry.def.bonus
			end
		end
		storage.Text = `🎒 {#entries} / {data.maxPetInventory or 50}`
		equippedLabel.Text = `Equipped: {equipped} / {data.maxEquippedPets}`
		hint.Text = if #entries == 0
			then "Hatch an egg to collect your first pet!"
			else `Pet bonus +{Format.abbreviate(bonus)}`

		for i, entry in entries do
			local rarityColor = Pets.RarityColors[entry.def.rarity]
			local card = Window.card(grid, i, if entry.pet.equipped then Color3.fromRGB(120, 255, 120) else rarityColor)
			Theme.label({ Size = UDim2.new(1, -10, 0, 26), Position = UDim2.fromOffset(5, 8), Text = entry.def.name, Parent = card })
			Theme.label({
				Size = UDim2.new(1, -10, 0, 20),
				Position = UDim2.fromOffset(5, 36),
				Text = entry.def.rarity,
				TextColor3 = rarityColor,
				Parent = card,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 22),
				Position = UDim2.fromOffset(5, 58),
				Text = `+{entry.def.bonus} Multiplier`,
				TextColor3 = Color3.fromRGB(140, 235, 80),
				Parent = card,
			})
			local isEquipped = entry.pet.equipped
			local button = Window.button({
				Size = UDim2.new(1, -16, 0, 40),
				Position = UDim2.new(0, 8, 1, -48),
				Text = if isEquipped then "Unequip" else "Equip",
			}, if isEquipped then "Red" else "Blue", function()
				local ok, message = Net.func(if isEquipped then "UnequipPet" else "EquipPet"):InvokeServer(entry.uid)
				if not ok then
					Window.report(ok, message)
				end
			end)
			button.Parent = card
		end
	end
end

return PetsTab
