-- Small "◎ 41" Robux price tag pinned to a button's bottom-right corner.

local Theme = require(script.Parent.Parent.Theme)

local RobuxChip = {}

local ROBUX_GREEN = Color3.fromRGB(90, 230, 90)

function RobuxChip.attach(parent: GuiObject, price: number, prefix: string?): TextLabel
	local label = Theme.label({
		Name = "RobuxChip",
		Size = UDim2.new(0.55, 0, 0.32, 0),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -4, 1, -2),
		Text = `{prefix or ""}\u{E002} {price}`,
		TextColor3 = ROBUX_GREEN,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = (parent.ZIndex or 1) + 2,
		Font = Enum.Font.BuilderSansBold,
		Parent = parent,
	})
	Theme.textStroke().Parent = label
	return label
end

return RobuxChip
