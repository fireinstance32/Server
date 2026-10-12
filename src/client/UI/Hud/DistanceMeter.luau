-- Live "123 m" meter shown at the top while the frog travels, with the
-- player's best distance underneath; flashes NEW BEST when beaten.

local Theme = require(script.Parent.Parent.Theme)

local new = Theme.new
local C = Theme.Colors

local DistanceMeter = {}

local frame: Frame
local value: TextLabel
local best: TextLabel

function DistanceMeter.init(gui: ScreenGui)
	frame = new("Frame", {
		Name = "DistanceMeter",
		Size = UDim2.fromOffset(300, 90),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 86),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
	value = Theme.label({ Size = UDim2.new(1, 0, 0, 60), Text = "0 m", Parent = frame })
	best = Theme.label({
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.fromOffset(0, 60),
		Text = "",
		TextColor3 = C.Gold,
		Parent = frame,
	})
	Theme.textStroke().Parent = best
end

function DistanceMeter.show(bestMeters: number)
	frame.Visible = true
	value.Text = "0 m"
	value.TextColor3 = C.White
	best.Text = `Best: {bestMeters} m`
end

function DistanceMeter.set(meters: number, beatBest: boolean)
	value.Text = `{meters} m`
	if beatBest then
		value.TextColor3 = C.Gold
		best.Text = "NEW BEST!"
	end
end

function DistanceMeter.hide()
	frame.Visible = false
end

return DistanceMeter
