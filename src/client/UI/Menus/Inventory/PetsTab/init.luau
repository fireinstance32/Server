-- Inventory › Pets (reference "My Pets"): details of the selected pet on the
-- left with the INDEX button under it; storage counts, a grid of small tiles
-- (PetTile) and the toolbar on the right. INDEX swaps the grid for the Pet
-- Index (Index).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)
local Signature = require(Shared.Util.Signature)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)
local PetTile = require(script.PetTile)
local Details = require(script.Details)
local Toolbar = require(script.Toolbar)
local Index = require(script.Index)

local new = Theme.new

local PetsTab = {}

local SORTS = { "Best", "Rarity", "Name" }
local LEFT = 250 -- details column width

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
		if a.def.bonus ~= b.def.bonus then
			return a.def.bonus > b.def.bonus
		end
		return a.uid < b.uid
	end)
	return entries
end

function PetsTab.build(content: Frame)
	local lastData = nil
	local sortMode = 1
	local selected: string? = nil
	local render: (any) -> ()

	-- Left: details + INDEX.
	local _, showDetails = Details.build(content, { Size = UDim2.new(0, LEFT, 1, -66) })
	local indexButton = Window.button({
		Size = UDim2.fromOffset(LEFT, 56),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Text = "INDEX",
	}, "Blue", function()
		-- set below, once the grid exists
	end)
	indexButton.Parent = content

	-- Right: header, grid / index, toolbar.
	local right = new("Frame", {
		Size = UDim2.new(1, -LEFT - 16, 1, 0),
		Position = UDim2.fromOffset(LEFT + 16, 0),
		BackgroundTransparency = 1,
		Parent = content,
	})
	local storage = Theme.label({
		Size = UDim2.new(0.5, 0, 0, 34),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = right,
	})
	local equippedLabel = Theme.label({
		Size = UDim2.new(0.5, 0, 0, 30),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = right,
	})
	local holder = Window.inset(right, { Size = UDim2.new(1, 0, 1, -106), Position = UDim2.fromOffset(0, 40) })
	local grid = Window.grid(holder, PetTile.Size, PetTile.Size, 10)
	local index = Index.build(holder)
	index.Visible = false
	local empty = Theme.label({
		Size = UDim2.new(1, -20, 0, 40),
		Position = UDim2.fromOffset(10, 20),
		Text = "No pets yet – hatch an egg!",
		Visible = false,
		Parent = holder,
	})
	local _, refreshToolbar = Toolbar.build(right, function()
		return lastData
	end, function()
		sortMode = sortMode % #SORTS + 1
		if lastData then
			render(lastData)
		end
		return SORTS[sortMode]
	end)

	indexButton.Activated:Connect(function()
		index.Visible = not index.Visible
		grid.Visible = not index.Visible
		if lastData then
			render(lastData)
		end
	end)

	-- Tiles and the index only rebuild when what they show changes (the
	-- server pushes a snapshot every few hundred ms while training).
	local renderGrid = Signature.guard(function(data)
		return Signature.of(SORTS[sortMode], selected, data.pets)
	end, function(data)
		Window.clear(grid)
		local entries = sortedPets(data, SORTS[sortMode])
		if not (selected and data.pets[selected]) then
			selected = if entries[1] then entries[1].uid else nil
		end
		for i, entry in entries do
			PetTile.build(grid, i, entry.pet, entry.uid == selected, function()
				selected = entry.uid
				render(data)
			end)
		end
		showDetails(if selected then { uid = selected, pet = data.pets[selected] } else nil)
	end)
	local renderIndex = Signature.guard(function(data)
		return Signature.of(data.discovered)
	end, function(data)
		Index.fill(index, data)
	end)

	render = function(data)
		lastData = data
		if index.Visible then
			renderIndex(data)
		end
		renderGrid(data)
		local count, equipped, bonus = 0, 0, 0
		for _, pet in data.pets do
			local def = Pets.ById[pet.id]
			if def then
				count += 1
				if pet.equipped then
					equipped += 1
					bonus += def.bonus
				end
			end
		end
		local found = 0
		for _ in data.discovered or {} do
			found += 1
		end
		storage.Text = `{count} / {data.maxPetInventory} Pets`
		equippedLabel.Text = `Equipped {equipped} / {data.maxEquippedPets}  (+{Format.abbreviate(bonus)})`
		Theme.setText(indexButton, if index.Visible then "MY PETS" else `INDEX  {found} / {#Pets.List}`)
		empty.Visible = count == 0 and not index.Visible
		refreshToolbar(data)
	end
	return render
end

return PetsTab
