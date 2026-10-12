-- Layout pieces shared by every menu: section headers, scrolling lists and
-- grids, cards, the dark inset panel, and the studded gradient button.

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)

local new = Theme.new

local Layout = {}

Layout.PanelColor = Color3.fromRGB(52, 53, 58)
Layout.CardColor = Color3.fromRGB(64, 65, 76)
Layout.InsetColor = Color3.fromRGB(40, 42, 48) -- the darker panel inside a window
Layout.Edge = Color3.fromRGB(12, 12, 16)

-- Small section header: "~ Pack ~".
function Layout.header(parent: Instance, text: string, order: number): TextLabel
	return Theme.label({
		Size = UDim2.new(1, 0, 0, 52), -- reference: 36 px capitals
		Text = `~ {text} ~`,
		LayoutOrder = order,
		Parent = parent,
	})
end

local function scroller(parent: Instance): ScrollingFrame
	return new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 7,
		ScrollBarImageColor3 = Color3.fromRGB(230, 190, 70),
		ScrollBarImageTransparency = 0.15,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = parent,
	})
end

-- Vertical scrolling list (sections, rows).
function Layout.list(parent: Instance, padding: number?): ScrollingFrame
	local list = scroller(parent)
	new("UIListLayout", {
		Padding = UDim.new(0, padding or 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = list,
	})
	new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 12), Parent = list })
	return list
end

-- Scrolling grid of fixed-size cards.
function Layout.grid(parent: Instance, cellWidth: number, cellHeight: number, gap: number?): ScrollingFrame
	local grid = scroller(parent)
	new("UIGridLayout", {
		CellSize = UDim2.fromOffset(cellWidth, cellHeight),
		CellPadding = UDim2.fromOffset(gap or 12, gap or 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		Parent = grid,
	})
	return grid
end

function Layout.card(parent: Instance, order: number, accent: Color3?): Frame
	return new("Frame", {
		BackgroundColor3 = Layout.CardColor,
		LayoutOrder = order,
		Parent = parent,
	}, { Theme.corner(12), Theme.stroke(3, accent or Layout.Edge) })
end

-- The dark rounded panel menus put their grid in ("My Stones" reference).
-- Returns the panel; put content in it (it has 10 px padding).
function Layout.inset(parent: Instance, props: { [string]: any }?): Frame
	local panel = new("Frame", {
		Name = "Inset",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Layout.InsetColor,
		BackgroundTransparency = 0.06,
		Parent = parent,
	}, {
		Theme.corner(18),
		Theme.stroke(4, Layout.Edge),
		new("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
	})
	for key, value in props or {} do
		(panel :: any)[key] = value
	end
	return panel
end

-- Studded gradient button (reference "ON" / "LOCKED" / price buttons):
-- preset gradient, darker edge in the same hue, stud texture, glossy top.
function Layout.button(props: { [string]: any }, color: string, onClick: () -> ()): TextButton
	local button = Theme.button(props, onClick)
	Layout.recolor(button, color)
	Studs.apply(button, 20)
	new("Frame", {
		Name = "Shine",
		Size = UDim2.new(1, -8, 0.42, 0),
		Position = UDim2.fromOffset(4, 3),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.82,
		ZIndex = 1,
		Parent = button,
	}, { Theme.corner(10) })
	return button
end

-- Studded button showing an icon then a value ("🏆 10K" with the vector
-- trophy). The value label is named "Value" (change it with .Text).
function Layout.priceButton(props: { [string]: any }, color: string, icon: string, text: string, onClick: () -> ()): TextButton
	props.Text = ""
	local button = Layout.button(props, color, onClick)
	-- Icon + value as one centred group. Its width is estimated from the text
	-- (Fredoka One averages ~0.56 em per character) so it never depends on
	-- AutomaticSize text measuring.
	local height = if props.Size and props.Size.Y.Offset > 0 then props.Size.Y.Offset else 46
	local textSize = math.floor(height * 0.6)
	local iconSize = math.floor(height * 0.78)
	local textWidth = math.ceil(utf8.len(text) * textSize * 0.56)
	local group = new("Frame", {
		Name = "Price",
		Size = UDim2.new(0, iconSize + 4 + textWidth, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = button,
	})
	Icon.new(icon, {
		Size = UDim2.fromOffset(iconSize, iconSize),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		ZIndex = 4,
		Parent = group,
	})
	local value = Theme.label({
		Name = "Value",
		Size = UDim2.new(0, textWidth, 0.8, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		TextScaled = false,
		TextSize = textSize,
		Text = text,
		ZIndex = 4,
		Parent = group,
	})
	value:FindFirstChildOfClass("UIStroke").Thickness = 3
	return button
end

-- Changes a Layout.button's colour (gradient + matching edge).
function Layout.recolor(button: GuiObject, color: string)
	Gradient.apply(button, color)
	local stroke = button:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = Gradient.Edges[color] or Layout.Edge
	end
end

function Layout.clear(container: Instance)
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

return Layout
