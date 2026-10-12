-- Sign over each egg: name, price, and every pet with this player's odds
-- (luck changes them), plus the E / R / T key hints.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)
local Hatch = require(Shared.Util.Hatch)

local Theme = require(script.Parent.Parent.UI.Theme)
local Purchases = require(script.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.State)

local new = Theme.new

local EggSigns = {}

local function isLucky(petId: string): boolean
	local def = Pets.ById[petId]
	return def ~= nil and Pets.RarityOrder[def.rarity] >= Pets.LuckMinRarity
end

local function buildSign(egg: Pets.Egg, anchor: BasePart, container: Instance)
	local gui = new("BillboardGui", {
		Name = egg.id .. "Sign",
		Adornee = anchor,
		Size = UDim2.fromOffset(260, 60 + #egg.pets * 24 + 30),
		StudsOffsetWorldSpace = Vector3.new(0, 9, 0),
		MaxDistance = 90,
		LightInfluence = 0,
		Parent = container,
	}, { new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
	Theme.label({ Size = UDim2.new(1, 0, 0, 32), Text = egg.name, LayoutOrder = 1, Parent = gui })
	local price = Theme.label({
		Size = UDim2.new(1, 0, 0, 26),
		Text = if egg.product
			then `\u{E002} {Purchases.price("product", egg.product)}`
			else `🏆 {Format.abbreviate(egg.price)} Wins`,
		TextColor3 = Theme.Colors.Gold,
		Font = Enum.Font.BuilderSansBold,
		LayoutOrder = 2,
		Parent = gui,
	})
	Theme.textStroke().Parent = price
	local rows = {}
	for i, entry in egg.pets do
		local def = Pets.ById[entry.pet]
		local row = Theme.label({
			Size = UDim2.new(1, 0, 0, 24),
			Text = "",
			TextColor3 = Pets.RarityColors[def.rarity],
			LayoutOrder = 2 + i,
			Parent = gui,
		})
		Theme.textStroke().Parent = row
		rows[entry.pet] = { label = row, def = def }
	end
	Theme.label({
		Size = UDim2.new(1, 0, 0, 26),
		Text = if egg.product then "E Buy" else "E Hatch · R Multi · T Auto",
		LayoutOrder = 99,
		Parent = gui,
	})

	return function(data)
		local luck = if data.multipliers and data.multipliers.luck then data.multipliers.luck.total else 1
		local chances = Hatch.chances(egg.pets, Hatch.weights(egg.pets, luck, isLucky))
		for petId, row in rows do
			row.label.Text = `{row.def.name}  +{row.def.bonus}  {Hatch.percentText(chances[petId])}`
		end
	end
end

function EggSigns.init()
	local root = Workspace:WaitForChild("World")
	local container = new("Folder", { Name = "EggSigns", Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local refreshers = {}
	for _, world in Worlds.List do
		local hub = root:WaitForChild(world.id)
		for _, egg in Pets.eggsForWorld(world.id) do
			local stand = hub:WaitForChild("EggStand_" .. egg.id) :: BasePart
			table.insert(refreshers, buildSign(egg, stand, container))
		end
	end
	State.observe(function(data)
		for _, refresh in refreshers do
			refresh(data)
		end
	end)
end

return EggSigns
