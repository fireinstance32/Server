-- Transient messages: toasts (top), floating "+N" numbers, centre banners.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)

local new = Theme.new
local C = Theme.Colors

local Popups = {}

local gui: ScreenGui
local toastHolder: Frame

-- The gradient sits on the pill frame and the text in a child label, so the
-- gradient doesn't tint the text.
function Popups.toast(text: string, color: Color3?)
	local base = color or C.Ink
	local border = Theme.stroke(3)
	local toast = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = base,
		Parent = toastHolder,
	}, { Theme.corner(22), border })
	Gradient.apply(toast, { base:Lerp(Color3.new(1, 1, 1), 0.2), base:Lerp(Color3.new(0, 0, 0), 0.15) })
	local label = Theme.label({
		Name = "Label",
		Size = UDim2.fromScale(1, 1),
		Text = text,
		ZIndex = 2,
		Parent = toast,
	})
	local textStroke = label:FindFirstChildOfClass("UIStroke") :: UIStroke
	textStroke.Thickness = 2.5
	new("UIPadding", { PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = label })
	Theme.pop(toast)
	task.delay(2.5, function()
		local fade = TweenInfo.new(0.3)
		TweenService:Create(toast, fade, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, fade, { TextTransparency = 1 }):Play()
		TweenService:Create(border, fade, { Transparency = 1 }):Play()
		TweenService:Create(textStroke, fade, { Transparency = 1 }):Play()
		task.wait(0.3)
		toast:Destroy()
	end)
end

-- "+25" style text that floats up from near the HOP button.
function Popups.floatText(text: string, color: Color3?)
	local label = Theme.label({
		Size = UDim2.fromOffset(220, 50),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5 + (math.random() - 0.5) * 0.2, 0, 0.72, 0),
		Text = text,
		TextColor3 = color or C.Gold,
		Parent = gui,
	})
	Theme.textStroke().Parent = label
	TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = label.Position - UDim2.fromScale(0, 0.18),
		TextTransparency = 1,
	}):Play()
	task.delay(1, function()
		label:Destroy()
	end)
end

-- Big centre-screen announcement, e.g. "ZONE 4!" after a launch.
function Popups.banner(title: string, subtitle: string?, color: Color3?)
	local frame = new("Frame", {
		Size = UDim2.fromScale(0.6, 0.18),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UISizeConstraint", { MaxSize = Vector2.new(600, 160) }),
	})
	Theme.label({ Size = UDim2.fromScale(1, 0.62), Text = title, TextColor3 = color or C.Gold, Parent = frame })
	if subtitle then
		Theme.label({
			Size = UDim2.fromScale(1, 0.38),
			Position = UDim2.fromScale(0, 0.62),
			Text = subtitle,
			Parent = frame,
		})
	end
	for _, child in frame:GetChildren() do
		if child:IsA("TextLabel") and not child:FindFirstChildOfClass("UIStroke") then
			Theme.textStroke().Parent = child
		end
	end
	Theme.pop(frame)
	task.delay(2.2, function()
		frame:Destroy()
	end)
end

function Popups.init(screen: ScreenGui)
	gui = screen
	toastHolder = new("Frame", {
		Size = UDim2.fromOffset(420, 200),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 366), -- below Auto Hop, quest bar, tips and distance meter
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	})
end

return Popups
