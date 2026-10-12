-- Inventory › Pets: storage and equipped counts, index progress, pet cards
-- (PetCard) with a sort button, the Index view (Index), and the toolbar
-- (auto delete, delete unequipped, equip best).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)
local PetCard = require(script.PetCard)
local Toolbar = require(script.Toolbar)
local Index = require(script.Index)

local new = Theme.new

local PetsTab = {}

local SORTS = { "Best", "Rarity", "Name" }

local function sortedPets(data, mode: string)
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
		if mode == "Rarity" and a.def.rarity ~= b.def.rarity then
			return Pets.RarityOrder[a.def.rarity] > Pets.RarityOrder[b.def.rarity]
		elseif mode == "Name" and a.def.name ~= b.def.name then
			return a.def.name < b.def.name
		end
		return a.def.bonus > b.def.bonus
	end)
	return entries
end

function PetsTab.build(content: Frame)
	local header = Theme.label({
		Size = UDim2.new(1, -250, 0, 36),
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
	local grid = Window.grid(holder, 150, 200)
	local empty = Theme.label({
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.fromOffset(10, 20),
		Text = "Hatch an egg to collect your first pet!",
		Visible = false,
		Parent = holder,
	})

	local index = Index.build(holder)
	index.Visible = false

	local lastData = nil
	local sortMode = 1
	local render: (any) -> ()
	local sortButton = Window.button({
		Size = UDim2.fromOffset(120, 38),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -126, 0, 0),
		Text = "Sort: Best",
	}, "Yellow", function()
		sortMode = sortMode % #SORTS + 1
		if lastData then
			render(lastData)
		end
	end)
	sortButton.Parent = content
	local indexButton = Window.button({
		Size = UDim2.fromOffset(118, 38),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Text = "INDEX",
	}, "Blue", function()
		index.Visible = not index.Visible
		grid.Visible = not index.Visible
		if lastData then
			render(lastData)
		end
	end)
	indexButton.Parent = content
	local refreshToolbar = Toolbar.build(content, function()
		return lastData
	end)

	render = function(data)
		lastData = data
		sortButton.Text = `Sort: {SORTS[sortMode]}`
		indexButton.Text = if index.Visible then "MY PETS" else "INDEX"
		if index.Visible then
			Index.fill(index, data)
		end
		Window.clear(grid)
		local entries = sortedPets(data, SORTS[sortMode])
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
		header.Text = `{#entries} / {data.maxPetInventory}   Equipped {equipped} / {data.maxEquippedPets} (+{Format.abbreviate(bonus)})   Index {found} / {#Pets.List}`
		empty.Visible = #entries == 0 and not index.Visible
		for i, entry in entries do
			PetCard.build(grid, i, entry.uid, entry.pet)
		end
		refreshToolbar(data)
	end
	return render
end

return PetsTab
