-- Transient messages: toasts (top), floating "+N" numbers, centre banners.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)

local new = Theme.new
local C = Theme.Colors

local Popups = {}

local gui: ScreenGui
local toastHolder: Frame

-- Toasts are bright text with a heavy outline across the top of the screen
-- (reference: "Scallop Shell equipped."). Callers pass a theme colour; dark
-- ones are swapped for a bright version so the text reads.
local BRIGHT: { [Color3]: Color3 } = {
	[C.DarkGreen] = Color3.fromRGB(110, 245, 110),
	[C.Green] = Color3.fromRGB(110, 245, 110),
	[C.Red] = Color3.fromRGB(255, 92, 92),
	[C.Ink] = C.White,
	[C.Blue] = Color3.fromRGB(120, 205, 255),
	[C.Purple] = Color3.fromRGB(215, 150, 255),
	[C.Gold] = Color3.fromRGB(255, 220, 70),
}
local MAX_TOASTS = 3
local toastCount = 0

function Popups.toast(text: string, color: Color3?)
	local tint = BRIGHT[color or C.Ink] or (color or C.White):Lerp(C.White, 0.25)
	local toasts = {}
	for _, child in toastHolder:GetChildren() do
		if child:IsA("TextLabel") then
			table.insert(toasts, child)
		end
	end
	table.sort(toasts, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	for i = 1, #toasts - MAX_TOASTS + 1 do
		toasts[i]:Destroy()
	end

	toastCount += 1
	local label = Theme.label({
		Name = "Toast",
		Size = UDim2.new(1, 0, 0, 38),
		Text = text,
		TextColor3 = tint,
		LayoutOrder = toastCount,
		Parent = toastHolder,
	})
	local stroke = Theme.textStroke(3.5)
	stroke.Parent = label
	Theme.pop(label)
	task.delay(2.4, function()
		local fade = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(label, fade, { TextTransparency = 1 }):Play()
		TweenService:Create(stroke, fade, { Transparency = 1 }):Play()
		task.wait(0.35)
		label:Destroy()
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

-- With a menu open the top HUD is hidden, so toasts move to the top edge
-- (above the window title, like the reference); otherwise they sit under the
-- quest bar and tips.
function Popups.setMenuOpen(open: boolean)
	if toastHolder then
		toastHolder.Position = UDim2.new(0.5, 0, 0, if open then 4 else 300)
	end
end

function Popups.init(screen: ScreenGui)
	gui = screen
	toastHolder = new("Frame", {
		Name = "Toasts",
		Size = UDim2.fromOffset(900, 130),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 300), -- under the quest bar and tips (see Popups.setMenuOpen)
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 2),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
end

return Popups
