-- One egg's world sign (reference): always-on name + price, and an odds
-- panel (pet pictures with this player's chances, E / R / T keys) that the
-- controller shows when the player walks up to the egg.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Events = require(Shared.Config.Events)
local Format = require(Shared.Util.Format)
local Hatch = require(Shared.Util.Hatch)

local Theme = require(script.Parent.Parent.Parent.UI.Theme)
local Gradient = require(script.Parent.Parent.Parent.UI.Components.Gradient)
local Icon = require(script.Parent.Parent.Parent.UI.Components.Icon)
local PetImage = require(script.Parent.Parent.Parent.UI.Components.PetImage)
local Purchases = require(script.Parent.Parent.Parent.Purchases)

local new = Theme.new

local Sign = {}

export type Sign = { title: BillboardGui, odds: BillboardGui, refresh: (data: any) -> () }

local function isLucky(petId: string): boolean
	local def = Pets.ById[petId]
	return def ~= nil and Pets.RarityOrder[def.rarity] >= Pets.LuckMinRarity
end

local function priceLine(egg: Pets.Egg): (string, string?)
	if egg.product then
		return `\u{E002} {Purchases.price("product", egg.product)}`, nil
	elseif egg.event then
		local event = Events.ById[egg.event]
		return `{egg.price} {event.currency}`, if event.id == "Halloween2026" then "candy_corn" else "star"
	end
	return `{Format.abbreviate(egg.price)} Wins`, "trophy"
end

local function keyButton(parent: Instance, key: string, label: string, color: string, order: number)
	local tile = new("Frame", { Size = UDim2.fromOffset(62, 62), LayoutOrder = order, Parent = parent }, {
		Theme.corner(10),
		Theme.stroke(3),
	})
	Gradient.apply(tile, color)
	Theme.label({ Size = UDim2.fromScale(0.9, 0.6), Position = UDim2.fromScale(0.05, 0.02), Text = key, Parent = tile })
	Theme.label({ Size = UDim2.fromScale(0.96, 0.32), Position = UDim2.fromScale(0.02, 0.64), Text = label, Parent = tile })
end

function Sign.build(egg: Pets.Egg, anchor: BasePart, container: Instance): Sign
	-- Name + price, always visible from afar.
	local title = new("BillboardGui", {
		Name = egg.id .. "Title",
		Adornee = anchor,
		Size = UDim2.fromOffset(240, 80),
		StudsOffsetWorldSpace = Vector3.new(0, 10, 0),
		MaxDistance = 120,
		LightInfluence = 0,
		Parent = container,
	})
	local nameLabel = Theme.label({ Size = UDim2.new(1, 0, 0, 42), Text = string.upper(egg.name), Parent = title })
	nameLabel.TextColor3 = egg.color:Lerp(Color3.new(1, 1, 1), 0.35)
	local text, iconName = priceLine(egg)
	local price = Theme.label({
		Size = UDim2.new(1, -30, 0, 32),
		Position = UDim2.fromOffset(30, 44),
		Text = text,
		TextColor3 = Theme.Colors.Gold,
		Parent = title,
	})
	Theme.textStroke().Parent = price
	if iconName then
		Icon.new(iconName, { Size = UDim2.fromOffset(34, 34), Position = UDim2.new(0.5, -86, 0, 43), Parent = title })
	end

	-- Odds panel, shown up close.
	local width = #egg.pets * 84 + 24
	local odds = new("BillboardGui", {
		Name = egg.id .. "Odds",
		Adornee = anchor,
		Size = UDim2.fromOffset(math.max(width, 240), 230),
		StudsOffsetWorldSpace = Vector3.new(0, 16, 0),
		MaxDistance = 40,
		LightInfluence = 0,
		Enabled = false,
		Parent = container,
	})
	local panel = new("Frame", {
		Size = UDim2.new(1, 0, 0, 150),
		BackgroundColor3 = Color3.fromRGB(40, 41, 58),
		BackgroundTransparency = 0.2,
		Parent = odds,
	}, { Theme.corner(14), Theme.stroke(4) })
	Theme.label({ Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, -18), Text = egg.name, Parent = panel })
	local row = new("Frame", {
		Size = UDim2.new(1, -16, 0, 110),
		Position = UDim2.fromOffset(8, 28),
		BackgroundTransparency = 1,
		Parent = panel,
	}, { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6) }) })
	local chanceLabels = {}
	for i, entry in egg.pets do
		local def = Pets.ById[entry.pet]
		local cell = new("Frame", { Size = UDim2.fromOffset(78, 110), BackgroundTransparency = 1, LayoutOrder = i, Parent = row })
		new("Frame", {
			Size = UDim2.fromOffset(74, 74),
			Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = Pets.RarityColors[def.rarity],
			BackgroundTransparency = 0.55,
			Parent = cell,
		}, { Theme.corner(10), Theme.stroke(2, Pets.RarityColors[def.rarity]) })
		PetImage.new("pet", entry.pet, { Size = UDim2.fromOffset(70, 70), Position = UDim2.fromOffset(4, 4), Parent = cell })
		chanceLabels[entry.pet] = Theme.label({ Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 80), Text = "", Parent = cell })
	end
	local keys = new("Frame", {
		Size = UDim2.new(1, 0, 0, 66),
		Position = UDim2.fromOffset(0, 160),
		BackgroundTransparency = 1,
		Parent = odds,
	}, { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 8) }) })
	if egg.product then
		keyButton(keys, "E", "Buy", "Green", 1)
	else
		keyButton(keys, "E", "Hatch", "Green", 1)
		keyButton(keys, "R", "Multi", "Pink", 2)
		keyButton(keys, "T", "Auto", "Purple", 3)
	end

	return {
		title = title,
		odds = odds,
		refresh = function(data)
			local luck = if data.multipliers and data.multipliers.luck then data.multipliers.luck.total else 1
			local chances = Hatch.chances(egg.pets, Hatch.weights(egg.pets, luck, isLucky))
			for petId, label in chanceLabels do
				label.Text = Hatch.percentText(chances[petId])
			end
		end,
	}
end

return Sign
