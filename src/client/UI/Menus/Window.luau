-- Shared building blocks for every menu, in the reference style: dark
-- translucent panel, big title on the top edge, corner icon, red X button.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Hud = require(script.Parent.Parent.Hud)

local new = Theme.new
local C = Theme.Colors

local Window = {}

Window.PanelColor = Color3.fromRGB(45, 45, 52)
Window.CardColor = Color3.fromRGB(62, 62, 72)

function Window.report(ok: boolean, message: string)
	Hud.toast(message, if ok then C.DarkGreen else C.Red)
end

function Window.create(title: string, icon: string, onClose: () -> ()): (Frame, Frame)
	local frame = new("Frame", {
		Name = title,
		Size = UDim2.fromScale(0.58, 0.68),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		BackgroundColor3 = Window.PanelColor,
		BackgroundTransparency = 0.08,
		Parent = Hud.screen(),
	}, {
		Theme.corner(16),
		Theme.stroke(5, Color3.fromRGB(15, 15, 18)),
		new("UISizeConstraint", { MaxSize = Vector2.new(900, 640), MinSize = Vector2.new(520, 380) }),
	})

	-- Title sits across the top edge.
	Theme.label({
		Name = "Title",
		Size = UDim2.new(0.6, 0, 0, 74),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 0),
		Text = title,
		ZIndex = 3,
		Parent = frame,
	})
	-- Big icon overlapping the top-left corner.
	Theme.label({
		Name = "Icon",
		Size = UDim2.fromOffset(110, 110),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(20, 0),
		Text = icon,
		Rotation = -10,
		ZIndex = 3,
		Parent = frame,
	})
	-- Red X overlapping the top-right corner.
	local close = new("TextButton", {
		Name = "Close",
		Size = UDim2.fromOffset(70, 70),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0, 0),
		Font = Theme.Font,
		Text = "✕",
		TextScaled = true,
		TextColor3 = C.White,
		ZIndex = 4,
		Parent = frame,
	}, { Theme.corner(14), Theme.stroke(4), Theme.textStroke() })
	Gradient.apply(close, "Red")
	close.Activated:Connect(onClose)

	local body = new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, -40, 1, -70),
		Position = UDim2.fromOffset(20, 50),
		BackgroundTransparency = 1,
		Parent = frame,
	})
	Theme.pop(frame)
	return frame, body
end

-- Small section header: "~ Pack ~".
function Window.header(parent: Instance, text: string, order: number): TextLabel
	return Theme.label({
		Size = UDim2.new(1, 0, 0, 40),
		Text = `~ {text} ~`,
		LayoutOrder = order,
		Parent = parent,
	})
end

-- Vertical scrolling list (sections, rows).
function Window.list(parent: Instance, padding: number?): ScrollingFrame
	return new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 8,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = parent,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, padding or 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingRight = UDim.new(0, 10) }),
	})
end

-- Scrolling grid of fixed-size cards.
function Window.grid(parent: Instance, cellWidth: number, cellHeight: number): ScrollingFrame
	return new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 8,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = parent,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(cellWidth, cellHeight),
			CellPadding = UDim2.fromOffset(10, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		new("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
		}),
	})
end

function Window.card(parent: Instance, order: number, accent: Color3?): Frame
	return new("Frame", {
		BackgroundColor3 = Window.CardColor,
		LayoutOrder = order,
		Parent = parent,
	}, { Theme.corner(12), Theme.stroke(3, accent or Color3.fromRGB(20, 20, 24)) })
end

-- Gradient button used inside menus.
function Window.button(props: { [string]: any }, color: string, onClick: () -> ()): TextButton
	local button = Theme.button(props, onClick)
	Gradient.apply(button, color)
	return button
end

function Window.clear(container: Instance)
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

return Window
