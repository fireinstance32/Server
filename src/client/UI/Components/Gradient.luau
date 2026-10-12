-- Vertical gradient fills used on buttons and cards (the reference games'
-- glossy look). Presets keep colours consistent everywhere. Colours are
-- sampled from the Stone Skipping screenshots (docs/Research/References).

local Gradient = {}

Gradient.Presets = {
	Yellow = { Color3.fromRGB(254, 235, 34), Color3.fromRGB(255, 184, 8) },
	Red = { Color3.fromRGB(255, 40, 75), Color3.fromRGB(232, 14, 42) },
	Green = { Color3.fromRGB(113, 243, 35), Color3.fromRGB(63, 216, 19) },
	Blue = { Color3.fromRGB(50, 200, 252), Color3.fromRGB(30, 140, 246), Color3.fromRGB(20, 95, 242) }, -- cyan top → royal blue (Rebirth bar)
	Purple = { Color3.fromRGB(207, 162, 255), Color3.fromRGB(150, 86, 220) },
	Orange = { Color3.fromRGB(255, 180, 40), Color3.fromRGB(232, 140, 0) }, -- Daily DAY tabs
	Pink = { Color3.fromRGB(255, 120, 200), Color3.fromRGB(220, 40, 140) },
	Lime = { Color3.fromRGB(204, 238, 80), Color3.fromRGB(168, 222, 18), Color3.fromRGB(102, 154, 6) }, -- HUD +2x pass card
	Gold = { Color3.fromRGB(246, 210, 86), Color3.fromRGB(236, 178, 42), Color3.fromRGB(192, 124, 16) }, -- HUD 2x Wins pass card
	Grey = { Color3.fromRGB(110, 110, 120), Color3.fromRGB(60, 60, 70) },
	Tile = { Color3.fromRGB(70, 69, 76), Color3.fromRGB(40, 42, 48) }, -- HUD menu tiles (reference: neutral grey)
	Silver = { Color3.fromRGB(226, 228, 232), Color3.fromRGB(182, 190, 199) },
	Rainbow = { -- sampled across the reference Starter Pack card, left → right
		Color3.fromRGB(250, 105, 90),
		Color3.fromRGB(250, 170, 65),
		Color3.fromRGB(252, 216, 72),
		Color3.fromRGB(156, 222, 98),
		Color3.fromRGB(90, 210, 170),
		Color3.fromRGB(76, 185, 252),
		Color3.fromRGB(112, 136, 250),
		Color3.fromRGB(214, 104, 205),
		Color3.fromRGB(238, 100, 140),
	},
}

-- Outline colour that goes with each preset on studded buttons (reference:
-- a green button has a dark green edge, not a black one).
Gradient.Edges = {
	Yellow = Color3.fromRGB(150, 90, 0),
	Red = Color3.fromRGB(120, 16, 28),
	Green = Color3.fromRGB(22, 100, 20),
	Blue = Color3.fromRGB(14, 66, 150),
	Purple = Color3.fromRGB(76, 24, 140),
	Orange = Color3.fromRGB(130, 64, 0),
	Pink = Color3.fromRGB(130, 14, 80),
	Lime = Color3.fromRGB(60, 96, 4),
	Gold = Color3.fromRGB(130, 76, 4),
	Grey = Color3.fromRGB(26, 26, 32),
	Tile = Color3.fromRGB(16, 16, 22),
	Silver = Color3.fromRGB(110, 114, 126),
	Rainbow = Color3.fromRGB(40, 20, 60),
} :: { [string]: Color3 }

-- Applies a gradient. `colors` is a preset name or a list of Color3.
-- Rainbow runs left→right; everything else top→bottom.
-- Re-applying the preset already on the object is a no-op (menus refresh
-- their button colours on every data snapshot).
function Gradient.apply(guiObject: GuiObject, colors: string | { Color3 }): UIGradient
	local existing = guiObject:FindFirstChildOfClass("UIGradient")
	if existing and typeof(colors) == "string" and existing:GetAttribute("Preset") == colors then
		return existing
	end
	local list = if typeof(colors) == "string" then Gradient.Presets[colors] else colors
	local keypoints = {}
	for i, color in list do
		table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / math.max(#list - 1, 1), color))
	end
	if existing then
		existing:Destroy()
	end
	guiObject.BackgroundColor3 = Color3.new(1, 1, 1)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(keypoints)
	gradient.Rotation = if colors == "Rainbow" then 0 else 90
	if typeof(colors) == "string" then
		gradient:SetAttribute("Preset", colors)
	end
	gradient.Parent = guiObject
	return gradient
end

return Gradient
