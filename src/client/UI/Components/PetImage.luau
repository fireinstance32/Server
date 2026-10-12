-- Picture of a pet or frog: from the uploaded sheets (Config/UiImages pets /
-- frogs + their atlases), or a live 3D ModelView until they're uploaded.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local UiImages = require(Shared.Config.UiImages)
local PetIconAtlas = require(Shared.Config.PetIconAtlas)
local FrogIconAtlas = require(Shared.Config.FrogIconAtlas)
local Pets = require(Shared.Config.Pets)
local Frogs = require(Shared.Config.Frogs)
local Models = require(Shared.Util.Models)

local Theme = require(script.Parent.Parent.Theme)
local ModelView = require(script.Parent.ModelView)

local PetImage = {}

local SHEETS = {
	pet = { image = "pets", atlas = PetIconAtlas },
	frog = { image = "frogs", atlas = FrogIconAtlas },
}

function PetImage.new(kind: "pet" | "frog", id: string, props: { [string]: any }?): GuiObject
	local sheet = SHEETS[kind]
	local content = UiImages.content(sheet.image)
	local index = sheet.atlas.Icons[id]
	local view: GuiObject
	if content and index then
		local cell = sheet.atlas.Cell
		view = Theme.new("ImageLabel", {
			Name = "PetImage",
			BackgroundTransparency = 1,
			Image = content,
			ImageRectOffset = Vector2.new((index % sheet.atlas.Columns) * cell, (index // sheet.atlas.Columns) * cell),
			ImageRectSize = Vector2.new(cell, cell),
			ScaleType = Enum.ScaleType.Fit,
		})
	elseif kind == "pet" and Pets.ById[id] then
		view = ModelView.new(Models.pet(Pets.ById[id]), nil, "-Z")
		local tag = view:FindFirstChildWhichIsA("BillboardGui", true)
		if tag then
			tag:Destroy()
		end
	else
		local frog = Frogs.ById[id] or Frogs.ById[Frogs.Default]
		view = ModelView.new(Models.frog(frog.color, 2, frog.id), nil, "+X")
	end
	for key, value in props or {} do
		(view :: any)[key] = value
	end
	return view
end

return PetImage
