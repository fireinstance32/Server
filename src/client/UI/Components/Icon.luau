-- An icon from the UI icon sheets (Config/UiImages + Config/IconAtlas), or its
-- emoji until its sheet is uploaded. Returns an ImageLabel or a TextLabel;
-- size/position it like any GuiObject.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UiImages = require(Shared.Config.UiImages)
local IconAtlas = require(Shared.Config.IconAtlas)

local Theme = require(script.Parent.Parent.Theme)

local Icon = {}

function Icon.has(name: string): boolean
	return IconAtlas.Icons[name] ~= nil
end

function Icon.new(name: string, props: { [string]: any }?): GuiObject
	local index = IconAtlas.Icons[name]
	local sheet = index and UiImages.content(IconAtlas.Sheets[index // IconAtlas.PerSheet + 1])
	local icon: GuiObject
	if sheet and index then
		local cell = IconAtlas.Cell
		index %= IconAtlas.PerSheet
		icon = Theme.new("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Image = sheet,
			ImageRectOffset = Vector2.new((index % IconAtlas.Columns) * cell, (index // IconAtlas.Columns) * cell),
			ImageRectSize = Vector2.new(cell, cell),
			ScaleType = Enum.ScaleType.Fit,
		})
	else
		icon = Theme.new("TextLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Text = UiImages.Fallback[name] or "?",
			TextScaled = true,
			Font = Theme.Font,
			TextColor3 = Color3.new(1, 1, 1),
		})
	end
	for key, value in props or {} do
		(icon :: any)[key] = value
	end
	return icon
end

return Icon
