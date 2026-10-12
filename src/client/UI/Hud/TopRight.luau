-- Small top-right buttons (reference calendar icon): Worlds, Daily Rewards
-- with a "!" badge when today's reward is ready (opens on join if so, unless
-- another menu is already up), and Settings.

local Theme = require(script.Parent.Parent.Theme)
local IconTile = require(script.Parent.Parent.Components.IconTile)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local TopRight = {}

-- `autoOpen` opens a menu only if none is open (never toggles one shut).
function TopRight.init(gui: ScreenGui, openMenu: (string) -> (), autoOpen: ((string) -> ())?)
	local row = new("Frame", {
		Name = "TopRight",
		Size = UDim2.fromOffset(300, 80),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 8),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local worlds = IconTile.create({
		icon = "globe",
		caption = "Worlds",
		color = "Green",
		order = 0,
		onClick = function()
			openMenu("Worlds")
		end,
	})
	worlds.Size = UDim2.fromOffset(76, 76)
	worlds.Parent = row
	local daily, badge = IconTile.create({
		icon = "daily",
		caption = "Daily",
		color = "Blue",
		order = 1,
		onClick = function()
			openMenu("Daily")
		end,
	})
	daily.Size = UDim2.fromOffset(76, 76)
	daily.Parent = row
	local settings = IconTile.create({
		icon = "settings",
		caption = "Settings",
		color = "Grey",
		order = 2,
		onClick = function()
			openMenu("Settings")
		end,
	})
	settings.Size = UDim2.fromOffset(76, 76)
	settings.Parent = row

	local openedOnJoin = false
	State.observe(function(data)
		local ready = data.daily and data.daily.canClaim
		badge.set(if ready then "!" else "")
		if ready and not openedOnJoin then
			openedOnJoin = true
			task.delay(2, function()
				if autoOpen then
					autoOpen("Daily")
				end
			end)
		end
	end)
end

return TopRight
