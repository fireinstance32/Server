-- Pet Index: every pet in the game; ones you've hatched show their picture
-- and name, the rest are black silhouettes with "???".

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pets = require(ReplicatedStorage:WaitForChild("Shared").Config.Pets)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local PetImage = require(script.Parent.Parent.Parent.Parent.Components.PetImage)
local Window = require(script.Parent.Parent.Parent.Window)

local Index = {}

function Index.build(holder: Frame): ScrollingFrame
	return Window.grid(holder, 110, 140)
end

function Index.fill(grid: ScrollingFrame, data: any)
	Window.clear(grid)
	for i, def in Pets.List do
		local found = data.discovered and data.discovered[def.id]
		local card = Window.card(grid, i, if found then Pets.RarityColors[def.rarity] else nil)
		local picture = PetImage.new("pet", def.id, {
			Size = UDim2.fromOffset(84, 84),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 6),
			Parent = card,
		})
		if not found and picture:IsA("ImageLabel") then
			picture.ImageColor3 = Color3.new(0, 0, 0)
		elseif not found and picture:IsA("ViewportFrame") then
			picture.ImageColor3 = Color3.new(0, 0, 0)
		end
		Theme.label({
			Size = UDim2.new(1, -8, 0, 36),
			Position = UDim2.new(0, 4, 1, -42),
			Text = if found then def.name else "???",
			TextWrapped = true,
			Parent = card,
		})
	end
end

return Index
