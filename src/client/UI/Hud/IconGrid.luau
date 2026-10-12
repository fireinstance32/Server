-- Left-side 2×3 grid of menu tiles with badges (reference layout).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gifts = require(ReplicatedStorage:WaitForChild("Shared").Config.Gifts)
local Theme = require(script.Parent.Parent.Theme)
local IconTile = require(script.Parent.Parent.Components.IconTile)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local IconGrid = {}

local TILES = {
	{ caption = "Shop", icon = "shop", menu = "Shop" },
	{ caption = "Rebirth", icon = "rebirth", menu = "Rebirth" },
	{ caption = "Pets", icon = "pet", menu = "Pets" },
	{ caption = "Trails", icon = "trails", menu = "Trails" },
	{ caption = "Inventory", icon = "inventory", menu = "Inventory" },
	{ caption = "Gifts", icon = "gifts", menu = "Gifts" },
}

function IconGrid.init(gui: ScreenGui, openMenu: (string) -> ())
	local grid = new("Frame", {
		Name = "IconGrid",
		Size = UDim2.fromOffset(196, 310),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 110, 0.54, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(90, 90),
			CellPadding = UDim2.fromOffset(8, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local badges = {}
	for i, tile in TILES do
		local button, badge = IconTile.create({
			icon = tile.icon,
			caption = tile.caption,
			order = i,
			onClick = function()
				openMenu(tile.menu)
			end,
		})
		button.Parent = grid
		badges[tile.caption] = badge
	end

	-- Gifts tile: countdown to the next playtime gift, "!" when one is ready.
	task.spawn(function()
		local player = game:GetService("Players").LocalPlayer
		while grid.Parent do
			local start = player:GetAttribute("SessionStart")
			local elapsed = if typeof(start) == "number" then workspace:GetServerTimeNow() - start else 0
			local left = Gifts.nextIn(math.floor(elapsed), Gifts.parseClaimed(player:GetAttribute("GiftsClaimed")))
			badges.Gifts.set(if left == nil then "" elseif left <= 0 then "!" else string.format("%02d:%02d", left // 60, left % 60))
			task.wait(1)
		end
	end)

	-- Rebirth tile shows progress toward MAX LEVEL, or "!" when ready.
	State.observe(function(data)
		local ratio = math.clamp(data.level / data.levelCap, 0, 1)
		badges.Rebirth.set(if ratio >= 1 then "!" else `{math.floor(ratio * 100)}%`)
	end)
end

return IconGrid
