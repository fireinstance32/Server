-- Shared helpers and palette for the world generator.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Util.Models.Assets)

local Parts = {}

Parts.GroundTop = 0.5 -- Y of the plaza (hub floor)
Parts.BankTop = 7.5 -- Y of the grass on top of the throw lane's banks
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
	p.CanTouch = false -- nothing uses Touched; saves physics work (8.5)
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- An imported Blender prop (assets/models/Props, see Models/Assets) coloured
-- from `color`, `width` studs across, standing on `cframe` (its bottom centre;
-- the rotation turns it). Purely visual: no collisions. Nil until the props
-- are imported, so callers keep their plain-part look as the fallback.
function Parts.prop(name: string, color: Color3, width: number, cframe: CFrame, parent: Instance): Model?
	local template = Assets.template(name)
	local model = template and Assets.build(template, "Root", color, width)
	if not model then
		return nil
	end
	model:PivotTo(cframe)
	-- Sit its world bounding box on the cframe's point.
	local low, high = Vector3.one * math.huge, -Vector3.one * math.huge
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			local half = part.Size / 2
			local r = part.CFrame
			local extent = Vector3.new(
				math.abs(r.XVector.X) * half.X + math.abs(r.YVector.X) * half.Y + math.abs(r.ZVector.X) * half.Z,
				math.abs(r.XVector.Y) * half.X + math.abs(r.YVector.Y) * half.Y + math.abs(r.ZVector.Y) * half.Z,
				math.abs(r.XVector.Z) * half.X + math.abs(r.YVector.Z) * half.Y + math.abs(r.ZVector.Z) * half.Z
			)
			low = low:Min(r.Position - extent)
			high = high:Max(r.Position + extent)
		end
	end
	local at = cframe.Position
	model:TranslateBy(Vector3.new(at.X - (low.X + high.X) / 2, at.Y - low.Y, at.Z - (low.Z + high.Z) / 2))
	model.Name = name
	model.Parent = parent
	return model
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
