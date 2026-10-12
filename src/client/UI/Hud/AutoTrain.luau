-- Free AUTO TRAIN toggle, shown while standing on a pond's pad (the
-- reference game's AUTO button on its training pads).

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)

local new = Theme.new

local AutoTrain = {}

local button: TextButton

function AutoTrain.setVisible(visible: boolean)
	if button then
		button.Visible = visible
	end
end

function AutoTrain.init(parent: Frame, onToggle: (boolean) -> ())
	local enabled = false
	button = new("TextButton", {
		Name = "AutoTrain",
		Size = UDim2.fromOffset(200, 56),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 0, -12),
		Text = "",
		AutoButtonColor = true,
		Visible = false,
		Parent = parent,
	}, { Theme.corner(12), Theme.stroke(3) })
	Gradient.apply(button, "Grey")
	local label = Theme.label({
		Size = UDim2.fromScale(0.9, 0.7),
		Position = UDim2.fromScale(0.05, 0.15),
		Text = "AUTO TRAIN: OFF",
		Parent = button,
	})
	button.Activated:Connect(function()
		enabled = not enabled
		label.Text = if enabled then "AUTO TRAIN: ON" else "AUTO TRAIN: OFF"
		Gradient.apply(button, if enabled then "Green" else "Grey")
		onToggle(enabled)
	end)
end

return AutoTrain
