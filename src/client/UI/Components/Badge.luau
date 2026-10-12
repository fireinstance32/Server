-- Corner badge on a tile: "!", "2%", "NEW!", "02:29". Hidden when text is "".

local Theme = require(script.Parent.Parent.Theme)

local Badge = {}

export type Badge = { set: (text: string) -> (), label: TextLabel }

function Badge.attach(parent: GuiObject, color: Color3?, rotation: number?): Badge
	local label = Theme.label({
		Name = "Badge",
		Size = UDim2.new(0.55, 0, 0.3, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.85, 0, 0.05, 0),
		BackgroundColor3 = color or Theme.Colors.Red,
		BackgroundTransparency = 0,
		Rotation = rotation or 0,
		Text = "",
		Visible = false,
		ZIndex = (parent.ZIndex or 1) + 3,
		Parent = parent,
	})
	Theme.corner(8).Parent = label
	Theme.stroke(2).Parent = label

	return {
		label = label,
		set = function(text: string)
			label.Text = text
			label.Visible = text ~= ""
		end,
	}
end

return Badge
