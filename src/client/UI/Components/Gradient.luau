-- Vertical gradient fills used on buttons and cards (the reference games'
-- glossy look). Presets keep colours consistent everywhere.

local Gradient = {}

Gradient.Presets = {
	Yellow = { Color3.fromRGB(255, 230, 90), Color3.fromRGB(245, 180, 30) },
	Red = { Color3.fromRGB(255, 110, 100), Color3.fromRGB(215, 50, 60) },
	Green = { Color3.fromRGB(140, 235, 80), Color3.fromRGB(60, 175, 40) },
	Blue = { Color3.fromRGB(110, 200, 255), Color3.fromRGB(40, 130, 230) },
	Purple = { Color3.fromRGB(200, 130, 255), Color3.fromRGB(130, 60, 220) },
	Pink = { Color3.fromRGB(255, 120, 200), Color3.fromRGB(220, 40, 140) },
	Grey = { Color3.fromRGB(110, 110, 120), Color3.fromRGB(60, 60, 70) },
	Rainbow = {
		Color3.fromRGB(255, 70, 70),
		Color3.fromRGB(255, 200, 40),
		Color3.fromRGB(80, 220, 90),
		Color3.fromRGB(70, 160, 255),
		Color3.fromRGB(190, 90, 255),
	},
}

-- Applies a gradient. `colors` is a preset name or a list of Color3.
-- Rainbow runs left→right; everything else top→bottom.
function Gradient.apply(guiObject: GuiObject, colors: string | { Color3 }): UIGradient
	local list = if typeof(colors) == "string" then Gradient.Presets[colors] else colors
	local keypoints = {}
	for i, color in list do
		table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / math.max(#list - 1, 1), color))
	end
	local existing = guiObject:FindFirstChildOfClass("UIGradient")
	if existing then
		existing:Destroy()
	end
	guiObject.BackgroundColor3 = Color3.new(1, 1, 1)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(keypoints)
	gradient.Rotation = if colors == "Rainbow" then 0 else 90
	gradient.Parent = guiObject
	return gradient
end

return Gradient
