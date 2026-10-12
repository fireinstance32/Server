-- The embossed brick-stud texture the reference games put on panels and
-- buttons. Laid over a frame's fill, under its text. No-op until
-- Config/UiImages.studs is uploaded.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiImages = require(ReplicatedStorage:WaitForChild("Shared").Config.UiImages)

local Theme = require(script.Parent.Parent.Theme)

local Studs = {}

-- `size` = studs per tile in pixels; `strength` 0..1 (how visible).
function Studs.apply(frame: GuiObject, size: number?, strength: number?): ImageLabel?
	local image = UiImages.content("studs")
	if not image then
		return nil
	end
	local corner = frame:FindFirstChildOfClass("UICorner")
	local tile = size or 26
	return Theme.new("ImageLabel", {
		Name = "Studs",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = image,
		ImageTransparency = 1 - (strength or 0.55),
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(tile, tile),
		ZIndex = 0, -- under the frame's other children
		Parent = frame,
	}, if corner then { Theme.new("UICorner", { CornerRadius = corner.CornerRadius }) } else nil)
end

return Studs
