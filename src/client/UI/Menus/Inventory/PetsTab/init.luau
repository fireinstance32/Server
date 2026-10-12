-- Inventory › Pets: storage and equipped counts, index progress, pet cards
-- (PetCard), and the toolbar (auto delete, delete unequipped, equip best).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)
local PetCard = require(script.PetCard)
local Toolbar = require(script.Toolbar)

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
	local header = Theme.label({
		Size = UDim2.new(1, 0, 0, 36),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content,
	})
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 1, -100),
		Position = UDim2.fromOffset(0, 42),
		BackgroundColor3 = Color3.fromRGB(30, 30, 36),
		Parent = content,
	}, { Theme.corner(12), Theme.stroke(3) })
	local grid = Window.grid(holder, 150, 150)
	local empty = Theme.label({
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.fromOffset(10, 20),
		Text = "Hatch an egg to collect your first pet!",
		Visible = false,
		Parent = holder,
	})

	local lastData = nil
	local refreshToolbar = Toolbar.build(content, function()
		return lastData
	end)

	return function(data)
		lastData = data
		Window.clear(grid)
		local entries = sortedPets(data)
		local equipped, bonus = 0, 0
		for _, entry in entries do
			if entry.pet.equipped then
				equipped += 1
				bonus += entry.def.bonus
			end
		end
		local found = 0
		for _ in data.discovered or {} do
			found += 1
		end
		header.Text = `🎒 {#entries} / {data.maxPetInventory}    Equipped {equipped} / {data.maxEquippedPets} (+{Format.abbreviate(bonus)})    Index {found} / {#Pets.List}`
		empty.Visible = #entries == 0
		for i, entry in entries do
			PetCard.build(grid, i, entry.uid, entry.pet)
		end
		refreshToolbar(data)
	end
end

return PetsTab
