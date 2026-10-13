-- "~ Pack ~" (reference shop video): the rainbow Starter Pack and the
-- crimson Galaxy Pack. Each card: a pile of its rewards on the left, the
-- title, four reward tiles, the struck-out price and the buy button.
-- Contents come from Config/Monetization.Bundles.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local PetImage = require(script.Parent.Parent.Parent.Components.PetImage)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Cards = require(script.Parent.Cards)

local new = Theme.new

local PackSection = {}

local SIZE = Vector2.new(886, 308) -- outer, black edge included
local POTION_ICON = { Hops = "potion_hops", Wins = "potion_wins", Luck = "potion_luck" }

local PACKS = {
	{
		id = "StarterPack",
		title = "Starter Pack",
		colors = "Rainbow",
		rim = Color3.fromRGB(248, 220, 110),
		ink = Color3.fromRGB(255, 240, 170),
		-- Reward pile: icons behind, the hero in front (centre, side, rotation).
		pile = { { "potion_hops", 108, 103, 110, -14 }, { "bolt", 178, 88, 110, 8 }, { "rebirth", 243, 113, 100, 0 }, { "frog", 190, 190, 170, 0 } },
	},
	{
		id = "GalaxyPack",
		title = "Galaxy Pack",
		colors = { Color3.fromRGB(140, 8, 55), Color3.fromRGB(95, 4, 42), Color3.fromRGB(150, 10, 58), Color3.fromRGB(196, 16, 70) },
		horizontal = true,
		rim = Color3.fromRGB(224, 61, 107),
		ink = Color3.fromRGB(255, 218, 232),
		pile = { { "potion_wins", 100, 95, 90, -16 }, { "potion_hops", 140, 80, 90, 10 }, { "rebirth", 225, 95, 95, 0 }, { "pet:GalaxyCat", 185, 190, 190, 0 } },
	},
}

-- One square tile: icon (or several potions / a pet) and its amount.
type Tile = { icons: { string }, text: string }

local function tiles(bundle: Monetization.Bundle): { Tile }
	local list: { Tile } = {}
	local potions: Tile? = nil
	for _, reward in bundle.rewards do
		if reward.kind == "potion" then
			if potions then
				table.insert(potions.icons, POTION_ICON[reward.id])
				continue
			end
			potions = { icons = { POTION_ICON[reward.id] }, text = `x{reward.amount}` }
			table.insert(list, potions :: Tile)
		elseif reward.kind == "pet" then
			table.insert(list, { icons = { `pet:{reward.id}` }, text = `x{reward.amount}` })
		elseif reward.kind == "rebirths" then
			table.insert(list, { icons = { "rebirth" }, text = `+{reward.amount}` })
		else
			table.insert(list, { icons = { if reward.kind == "wins" then "trophy" else "bolt" }, text = `x{Format.abbreviate(reward.amount)}` })
		end
	end
	return list
end

-- An icon name, or "pet:<id>" for a pet picture.
local function picture(parent: Instance, name: string, at: Vector2, side: number, rotation: number, zIndex: number)
	local petId = string.match(name, "^pet:(.+)$")
	if petId then
		PetImage.new("pet", petId, {
			Size = UDim2.fromOffset(side, side),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(at.X, at.Y),
			ZIndex = zIndex,
			Parent = parent,
		})
	else
		Cards.icon(parent, name, at, side, rotation, zIndex)
	end
end

local function tile(card: Frame, x: number, item: Tile)
	local box = new("Frame", {
		Name = "Tile",
		Size = UDim2.fromOffset(97, 99),
		Position = UDim2.fromOffset(x + 3, 101),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.62,
		ZIndex = 3,
		Parent = card,
	}, { Theme.corner(14), Theme.stroke(3, Color3.new(1, 1, 1)) })
	local count = #item.icons
	for i, name in item.icons do
		local spread = i - (count + 1) / 2
		picture(box, name, Vector2.new(48 + spread * 22, 38 + math.abs(spread) * 4), if count > 1 then 58 else 72, spread * 14, 4 + count - math.floor(math.abs(spread)))
	end
	Cards.text(box, { text = item.text, size = 32, at = Vector2.new(48, 76), width = 120, stroke = 3, zIndex = 8 })
end

local function card(row: Frame, pack: any, y: number): TextButton
	local bundle = Monetization.Bundles[pack.id]
	local frame = Cards.card(row, {
		name = pack.id,
		size = SIZE,
		position = Vector2.new(12, y),
		colors = pack.colors,
		horizontal = pack.horizontal,
		edge = 5,
		rim = pack.rim,
	})
	for i, item in pack.pile do
		picture(frame, item[1], Vector2.new(item[2], item[3]), item[4], item[5], 3 + i)
	end
	Cards.text(frame, { text = pack.title, size = 72, at = Vector2.new(605, 58), color = pack.ink, stroke = 5 })
	for i, item in tiles(bundle) do
		if i <= 4 then
			tile(frame, ({ 340, 476, 611, 748 })[i], item)
		end
	end
	if bundle.was then
		Cards.struck(frame, Vector2.new(583, 245), bundle.was)
	end
	return Cards.buy(frame, Vector2.new(668, 210), Vector2.new(182, 72), `{Cards.Robux}{Purchases.price("product", pack.id)}`, function()
		Purchases.product(pack.id)
	end)
end

function PackSection.build(list: ScrollingFrame, order: number)
	Cards.header(list, "Pack", order)
	local row = Cards.row(list, SIZE.Y * 2 + 20, order + 1)
	local buttons = {}
	for i, pack in PACKS do
		buttons[pack.id] = card(row, pack, (i - 1) * (SIZE.Y + 20))
	end

	-- One-time offers show OWNED once bought.
	return function(data)
		for id, button in buttons do
			local bought = Monetization.Bundles[id].oneTime and data.oneTime and data.oneTime[id]
			Cards.setPrice(button, if bought then "OWNED" else `{Cards.Robux}{Purchases.price("product", id)}`, bought == true)
		end
	end
end

return PackSection
