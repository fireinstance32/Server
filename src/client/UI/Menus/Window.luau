-- Shared building blocks for every menu: the window frame, card grids,
-- cards, and the success/error toast.

local Theme = require(script.Parent.Parent.Theme)
local Hud = require(script.Parent.Parent.Hud)

local new = Theme.new
local C = Theme.Colors

local Window = {}

function Window.report(ok: boolean, message: string)
	Hud.toast(message, if ok then C.DarkGreen else C.Red)
end

function Window.create(title: string, color: Color3, onClose: () -> ()): (Frame, Frame)
	local frame = new("Frame", {
		Name = title,
		Size = UDim2.fromScale(0.62, 0.66),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = C.Panel,
		Parent = Hud.screen(),
	}, {
		Theme.corner(20),
		Theme.stroke(4),
		new("UISizeConstraint", { MaxSize = Vector2.new(760, 520), MinSize = Vector2.new(320, 300) }),
	})

	local header = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = color,
		Parent = frame,
	}, { Theme.corner(20), Theme.stroke(4) })
	Theme.label({
		Size = UDim2.new(1, -80, 1, -12),
		Position = UDim2.fromOffset(16, 6),
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	local close = Theme.button({
		Size = UDim2.fromOffset(46, 46),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Text = "X",
		Color = C.Red,
	}, function()
		onClose()
	end)
	close.Parent = header

	local body = new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, -24, 1, -72),
		Position = UDim2.fromOffset(12, 64),
		BackgroundTransparency = 1,
		Parent = frame,
	})
	Theme.pop(frame)
	return frame, body
end

function Window.grid(parent: Instance, cellHeight: number): ScrollingFrame
	local scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 8,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = parent,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(150, cellHeight),
			CellPadding = UDim2.fromOffset(10, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
	})
	return scroll
end

function Window.card(parent: Instance, order: number, accent: Color3): Frame
	return new("Frame", {
		BackgroundColor3 = C.White,
		LayoutOrder = order,
		Parent = parent,
	}, { Theme.corner(14), Theme.stroke(3, accent) })
end

function Window.clearCards(scroll: ScrollingFrame)
	for _, child in scroll:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

return Window
