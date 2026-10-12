-- The bevelled brick-stud texture the reference games put on panels and
-- buttons (tools/textures/ui_textures.py, measured from the screenshots).
-- Laid over a frame's fill, under its text, at full strength. No-op until
-- Config/UiImages.studs is uploaded.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiImages = require(ReplicatedStorage:WaitForChild("Shared").Config.UiImages)

local Theme = require(script.Parent.Parent.Theme)

local Studs = {}

-- `size` = stud pitch in pixels (reference: 24 on cards, ~22 on HUD bars,
-- ~15 on small claim bars).
function Studs.apply(frame: GuiObject, size: number?): ImageLabel?
	local image = UiImages.content("studs")
	if not image then
		return nil
	end
	local corner = frame:FindFirstChildOfClass("UICorner")
	local tile = size or 24
	return Theme.new("ImageLabel", {
		Name = "Studs",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = image,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(tile, tile),
		ZIndex = 0, -- under the frame's other children
		Parent = frame,
	}, if corner then { Theme.new("UICorner", { CornerRadius = corner.CornerRadius }) } else nil)
end

return Studs
