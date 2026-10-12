-- One small pet tile (reference "My Pets" grid): picture, ⚡+bonus along the
-- bottom, green check when equipped, padlock when locked. Clicking selects
-- it for the details panel.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Parent.Components.Gradient)
local Icon = require(script.Parent.Parent.Parent.Parent.Components.Icon)
local PetImage = require(script.Parent.Parent.Parent.Parent.Components.PetImage)

local new = Theme.new

local PetTile = {}

PetTile.Size = 104

local IDLE_EDGE = Color3.fromRGB(150, 152, 162)
local SELECTED_EDGE = Color3.fromRGB(140, 222, 255)

-- Bolt icon + "+4" in green, centred along the bottom of `parent`.
function PetTile.bonusRow(parent: Instance, bonus: number, height: number, z: number?): Frame
	local row = new("Frame", {
		Name = "Bonus",
		Size = UDim2.new(1, 0, 0, height),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -2),
		BackgroundTransparency = 1,
		ZIndex = z or 3,
		Parent = parent,
	})
	Icon.new("bolt", {
		Size = UDim2.fromOffset(height, height),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.42, 0, 0.5, 0),
		ZIndex = z or 3,
		Parent = row,
	})
	local text = Theme.label({
		Size = UDim2.new(0.58, 0, 0.9, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.42, 2, 0.5, 0),
		Text = `+{Format.abbreviate(bonus)}`,
		TextColor3 = Color3.fromRGB(110, 245, 80),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = z or 3,
		Parent = row,
	})
	Theme.textStroke(3).Parent = text
	return row
end

function PetTile.build(grid: Instance, order: number, pet: any, selected: boolean, onSelect: () -> ()): TextButton
	local def = Pets.ById[pet.id]
	local tile = new("TextButton", {
		Name = pet.id,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
		Parent = grid,
	}, { Theme.corner(12), Theme.stroke(if selected then 4 else 3, if selected then SELECTED_EDGE else IDLE_EDGE) })
	Gradient.apply(tile, if selected
		then { Color3.fromRGB(112, 150, 178), Color3.fromRGB(62, 86, 108) }
		else { Color3.fromRGB(116, 117, 126), Color3.fromRGB(78, 79, 88) })

	-- Thin rarity strip at the top so rarities read at a glance.
	new("Frame", {
		Size = UDim2.new(1, -16, 0, 5),
		Position = UDim2.fromOffset(8, 5),
		BackgroundColor3 = Pets.RarityColors[def.rarity],
		Parent = tile,
	}, { Theme.corner(3) })
	PetImage.new("pet", pet.id, {
		Size = UDim2.fromScale(0.74, 0.62),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.08),
		ZIndex = 2,
		Parent = tile,
	})
	PetTile.bonusRow(tile, def.bonus, 26)
	if pet.equipped then
		Icon.new("check", {
			Size = UDim2.fromOffset(34, 34),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -8, 0, 8),
			ZIndex = 4,
			Parent = tile,
		})
	end
	if pet.locked then
		Icon.new("lock", {
			Size = UDim2.fromOffset(28, 28),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(10, 12),
			Rotation = -12,
			ZIndex = 4,
			Parent = tile,
		})
	end

	local scale = new("UIScale", { Parent = tile })
	Theme.hover(tile, scale)
	tile.Activated:Connect(onSelect)
	return tile
end

return PetTile
