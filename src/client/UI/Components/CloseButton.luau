-- Red close button from the reference menus: a rounded red square with a
-- black edge and a big white × (no studs, like the reference). Grows on hover, clicks with Sfx.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Sfx = require(script.Parent.Parent.Parent.Sfx)

local CloseButton = {}

-- Sampled from the reference: near-flat red face, dark red edge and glyph outline.
local FACE = { Color3.fromRGB(255, 3, 62), Color3.fromRGB(255, 22, 46) }
local EDGE = Color3.fromRGB(125, 15, 28)

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
	}, { Theme.corner(16), Theme.stroke(4, EDGE) })
	Gradient.apply(button, FACE)
	local glyph = Theme.label({
		Size = UDim2.fromScale(0.95, 0.95),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "\u{D7}", -- multiplication sign, like the reference glyph
		ZIndex = props.ZIndex + 1,
		Parent = button,
	})
	local stroke = glyph:FindFirstChildOfClass("UIStroke") or Theme.textStroke()
	stroke.Color = EDGE
	stroke.Parent = glyph
	local scale = Theme.new("UIScale", { Parent = button })
	Theme.hover(button, scale)
	button.Activated:Connect(function()
		Sfx.play("Click")
		onClose()
	end)
	return button
end

return CloseButton
