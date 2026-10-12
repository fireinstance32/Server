-- "Click to …" hint low on the screen: mouse icon + text, centred together
-- (reference hatch screen). Returns a setter; "" hides it.

local Theme = require(script.Parent.Parent.Theme)
local Icon = require(script.Parent.Icon)

local new = Theme.new

local ClickHint = {}

function ClickHint.new(parent: Instance): (text: string) -> ()
	local row = new("Frame", {
		Name = "ClickHint",
		Size = UDim2.new(0.6, 0, 0, 48),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.82),
		BackgroundTransparency = 1,
		Parent = parent,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	Icon.new("mouse", { Size = UDim2.fromOffset(44, 44), LayoutOrder = 0, Parent = row })
	local label = Theme.label({ Size = UDim2.fromOffset(0, 44), LayoutOrder = 1, Parent = row })
	return function(text: string)
		row.Visible = text ~= ""
		label.Text = text
		label.Size = UDim2.fromOffset(#text * 19, 44) -- ~19 px per character at this size
	end
end

return ClickHint
