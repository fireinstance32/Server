-- Small top-right buttons (reference calendar icon): Daily Rewards with a
-- "!" badge when today's reward is ready (opens on join if so), and Settings.

local Theme = require(script.Parent.Parent.Theme)
local IconTile = require(script.Parent.Parent.Components.IconTile)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local TopRight = {}

function TopRight.init(gui: ScreenGui, openMenu: (string) -> ())
	local row = new("Frame", {
		Name = "TopRight",
		Size = UDim2.fromOffset(200, 80),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 8),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
		}),
	})
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
				openMenu("Daily")
			end)
		end
	end)
end

return TopRight
