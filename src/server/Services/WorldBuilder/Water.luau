-- The water look (reference): an opaque, bright blue surface with light
-- lines (caustics) drifting over it, which also takes the shadows. Used by
-- the lane, the gym pools and the waterfalls. The caustics are a Texture
-- tagged "WaterCaustics" that the client scrolls (Controllers/WaterCaustics);
-- until the image is uploaded (Config/UiImages.Ids.caustics) it's plain.
-- The lane keeps invisible terrain water underneath so you can still swim.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiImages = require(ReplicatedStorage:WaitForChild("Shared").Config.UiImages)

local Parts = require(script.Parent.Parts)
local Style = require(script.Parent.Style)

local Water = {}

Water.Color = Color3.fromRGB(22, 150, 232)
Water.Tag = "WaterCaustics"

-- A water surface `size` (x, z) with its top at `top` (a CFrame on the
-- surface), `color` or the standard blue. Visual only: no collisions.
function Water.surface(name: string, size: Vector2, top: CFrame, parent: Instance, color: Color3?, studsPerTile: number?): Part
	local part = Parts.block(name, Vector3.new(size.X, 1, size.Y), top * CFrame.new(0, -0.5, 0), color or Water.Color, parent)
	Style.quiet(part)
	part.CastShadow = false
	local image = UiImages.content("caustics")
	if image then
		local texture = Instance.new("Texture")
		texture.Name = "Caustics"
		texture.Texture = image
		texture.Face = Enum.NormalId.Top
		texture.StudsPerTileU = studsPerTile or 22
		texture.StudsPerTileV = studsPerTile or 22
		texture.Transparency = 0.35
		texture:AddTag(Water.Tag)
		texture.Parent = part
	end
	return part
end

return Water
