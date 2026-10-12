-- Transient messages: toasts (top), floating "+N" numbers, centre banners.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)

local new = Theme.new
local C = Theme.Colors

local Popups = {}

local gui: ScreenGui
local toastHolder: Frame

function Popups.toast(text: string, color: Color3?)
	local toast = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = color or C.Ink,
		BackgroundTransparency = 0.1,
		Font = Theme.Font,
		Text = text,
		TextColor3 = C.White,
		TextScaled = true,
		Parent = toastHolder,
	}, { Theme.corner(10), new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }) })
	Theme.pop(toast)
	task.delay(2.5, function()
		TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
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
		Position = UDim2.fromScale(0.5, 0.3),
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
		Position = UDim2.new(0.5, 0, 0, 285), -- below Auto Hop, quest bar and distance meter
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
