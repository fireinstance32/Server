-- Red close button from the reference menus: a rounded red square with a
-- dark red edge, studs and a big white ×. Grows on hover, clicks with Sfx.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Studs = require(script.Parent.Studs)
local Sfx = require(script.Parent.Parent.Parent.Sfx)

local CloseButton = {}

function CloseButton.new(props: { Size: UDim2, Position: UDim2, ZIndex: number, Parent: Instance }, onClose: () -> ()): TextButton
	local button = Theme.new("TextButton", {
		Name = "Close",
		Size = props.Size,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		Text = "",
		AutoButtonColor = false,
		ZIndex = props.ZIndex,
		Parent = props.Parent,
	}, { Theme.corner(14), Theme.stroke(4) })
	Gradient.apply(button, "Red")
	Studs.apply(button, 20, 0.5)
	Theme.label({
		Size = UDim2.fromScale(0.72, 0.72),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "X",
		ZIndex = props.ZIndex + 1,
		Parent = button,
	})
	local scale = Theme.new("UIScale", { Parent = button })
	Theme.hover(button, scale)
	button.Activated:Connect(function()
		Sfx.play("Click")
		onClose()
	end)
	return button
end

return CloseButton
