-- Left-side 2×3 grid of menu tiles with badges (reference layout).

local Theme = require(script.Parent.Parent.Theme)
local IconTile = require(script.Parent.Parent.Components.IconTile)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local IconGrid = {}

local TILES = {
	{ caption = "Shop", icon = "🛒", color = "Pink", menu = "Shop" },
	{ caption = "Rebirth", icon = "🔁", color = "Purple", menu = "Rebirth" },
	{ caption = "Pets", icon = "🐾", color = "Blue", menu = "Pets" },
	{ caption = "Trails", icon = "✨", color = "Purple", menu = "Trails" },
	{ caption = "Inventory", icon = "🎒", color = "Yellow", menu = "Inventory" },
	{ caption = "Gifts", icon = "🎁", color = "Green", menu = "Gifts" },
}

function IconGrid.init(gui: ScreenGui, openMenu: (string) -> ())
	local grid = new("Frame", {
		Name = "IconGrid",
		Size = UDim2.fromOffset(200, 300),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 20, 0.5, -30),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(94, 94),
			CellPadding = UDim2.fromOffset(10, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local badges = {}
	for i, tile in TILES do
		local button, badge = IconTile.create({
			icon = tile.icon,
			caption = tile.caption,
			color = tile.color,
			order = i,
			onClick = function()
				openMenu(tile.menu)
			end,
		})
		button.Parent = grid
		badges[tile.caption] = badge
	end

	-- Rebirth tile shows progress toward MAX LEVEL, or "!" when ready.
	State.observe(function(data)
		local ratio = math.clamp(data.level / data.levelCap, 0, 1)
		badges.Rebirth.set(if ratio >= 1 then "!" else `{math.floor(ratio * 100)}%`)
	end)
end

return IconGrid
