-- Pets: list owned pets, equip/unequip, show the total pet bonus.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Game = require(Shared.Config.Game)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Window = require(script.Parent.Window)

local new = Theme.new
local C = Theme.Colors

local PetsMenu = {}

function PetsMenu.build(body: Frame)
	local summary = Theme.label({
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		TextColor3 = C.Ink,
		Parent = body,
	})
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 1, -38),
		Position = UDim2.fromOffset(0, 38),
		BackgroundTransparency = 1,
		Parent = body,
	})
	local scroll = Window.grid(holder, 150)
	return function(data)
		Window.clearCards(scroll)
		local entries = {}
		local equipped = 0
		for uid, pet in data.pets do
			local def = Pets.ById[pet.id]
			if def then
				table.insert(entries, { uid = uid, pet = pet, def = def })
				if pet.equipped then
					equipped += 1
				end
			end
		end
		-- Equipped first, then strongest.
		table.sort(entries, function(a, b)
			if a.pet.equipped ~= b.pet.equipped then
				return a.pet.equipped
			end
			return a.def.multiplier > b.def.multiplier
		end)

		local petBonus = 1
		for _, entry in entries do
			if entry.pet.equipped then
				petBonus += entry.def.multiplier - 1
			end
		end
		summary.Text = `Equipped {equipped}/{data.maxEquippedPets}  •  Pet bonus {Format.multiplier(petBonus)}  •  {#entries}/{Game.MaxPetInventory} pets`

		if #entries == 0 then
			local c = Window.card(scroll, 1, C.Grey)
			Theme.label({
				Size = UDim2.new(1, -10, 1, -10),
				Position = UDim2.fromOffset(5, 5),
				Text = "Hatch eggs near spawn to get pets!",
				TextColor3 = C.Ink,
				Parent = c,
			})
			return
		end

		for i, entry in entries do
			local rarityColor = Pets.RarityColors[entry.def.rarity]
			local c = Window.card(scroll, i, rarityColor)
			Theme.label({
				Size = UDim2.new(1, -10, 0, 28),
				Position = UDim2.fromOffset(5, 8),
				Text = entry.def.name,
				TextColor3 = C.Ink,
				Parent = c,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 22),
				Position = UDim2.fromOffset(5, 38),
				Text = entry.def.rarity,
				TextColor3 = rarityColor,
				Parent = c,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 24),
				Position = UDim2.fromOffset(5, 62),
				Text = `{Format.multiplier(entry.def.multiplier)} Hops`,
				TextColor3 = C.DarkGreen,
				Parent = c,
			})
			local isEquipped = entry.pet.equipped
			local b = Theme.button({
				Size = UDim2.new(1, -20, 0, 40),
				Position = UDim2.new(0, 10, 1, -50),
				Text = if isEquipped then "Unequip" else "Equip",
				Color = if isEquipped then C.Red else C.Blue,
			}, function()
				local remote = if isEquipped then "UnequipPet" else "EquipPet"
				local ok, message = Net.func(remote):InvokeServer(entry.uid)
				if not ok then
					Window.report(ok, message)
				end
			end)
			b.Parent = c
		end
	end
end

return PetsMenu
