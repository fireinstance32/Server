-- Shared helpers and palette for the world generator.

local Parts = {}

Parts.GroundTop = 0.5 -- Y of the plaza and river bank surfaces
Parts.Colors = {
	Grass = Color3.fromRGB(110, 200, 90),
	Wood = Color3.fromRGB(160, 110, 65),
	Pad = Color3.fromRGB(70, 175, 70),
}

function Parts.block(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance, material: Enum.Material?): Part
	assert(parent, `Parts.block("{name}") needs a parent`)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function Parts.sign(parent: BasePart, title: string, subtitle: string?, color: Color3?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Sign"
	gui.Size = UDim2.fromOffset(320, if subtitle then 110 else 70)
	gui.StudsOffsetWorldSpace = Vector3.new(0, parent.Size.Y / 2 + 4, 0)
	gui.MaxDistance = 250
	gui.LightInfluence = 0

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = gui

	local function label(text: string, height: number, textColor: Color3)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, 0, 0, height)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.FredokaOne
		l.Text = text
		l.TextScaled = true
		l.TextColor3 = textColor
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 3
		stroke.Color = Color3.fromRGB(30, 40, 30)
		stroke.Parent = l
		l.Parent = gui
	end

	label(title, 64, color or Color3.new(1, 1, 1))
	if subtitle then
		label(subtitle, 40, Color3.fromRGB(255, 240, 150))
	end
	gui.Parent = parent
end

return Parts
