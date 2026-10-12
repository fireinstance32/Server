-- One pet card: name, rarity, +bonus, Equip/Unequip, 🔒 lock and 🗑 delete.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Parent.Window)
local PetImage = require(script.Parent.Parent.Parent.Parent.Components.PetImage)

local PetCard = {}

local function iconButton(parent: Frame, text: string, x: number, color: string, onClick: () -> ())
	local button = Window.button({
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, x, 0, 4),
		Text = text,
	}, color, onClick)
	button.Parent = parent
	return button
end

function PetCard.build(grid: ScrollingFrame, order: number, uid: string, pet: any)
	local def = Pets.ById[pet.id]
	local rarityColor = Pets.RarityColors[def.rarity]
	local card = Window.card(grid, order, if pet.equipped then Color3.fromRGB(120, 255, 120) else rarityColor)

	Theme.label({ Size = UDim2.new(1, -74, 0, 24), Position = UDim2.fromOffset(6, 8), Text = def.name, Parent = card })
	PetImage.new("pet", pet.id, {
		Size = UDim2.fromOffset(64, 64),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 34),
		Parent = card,
	})
	local rarity = Theme.label({
		Size = UDim2.new(1, -10, 0, 20),
		Position = UDim2.fromOffset(5, 100),
		Text = def.rarity,
		TextColor3 = rarityColor,
		Parent = card,
	})
	Theme.textStroke().Parent = rarity
	local bonus = Theme.label({
		Size = UDim2.new(1, -10, 0, 24),
		Position = UDim2.fromOffset(5, 120),
		Text = `+{def.bonus}`,
		TextColor3 = Color3.fromRGB(140, 235, 80),
		Parent = card,
	})
	Theme.textStroke().Parent = bonus

	iconButton(card, if pet.locked then "🔒" else "🔓", -68, if pet.locked then "Yellow" else "Grey", function()
		Window.report(Net.func("LockPet"):InvokeServer(uid, not pet.locked))
	end)
	if not pet.locked then
		iconButton(card, "🗑", -34, "Red", function()
			Window.report(Net.func("DeletePets"):InvokeServer({ uid }))
		end)
	end

	local equipButton = Window.button({
		Size = UDim2.new(1, -16, 0, 40),
		Position = UDim2.new(0, 8, 1, -48),
		Text = if pet.equipped then "Unequip" else "Equip",
	}, if pet.equipped then "Red" else "Blue", function()
		local ok, message = Net.func(if pet.equipped then "UnequipPet" else "EquipPet"):InvokeServer(uid)
		if not ok then
			Window.report(ok, message)
		end
	end)
	equipButton.Parent = card
end

return PetCard
