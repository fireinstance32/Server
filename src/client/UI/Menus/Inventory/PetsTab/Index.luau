-- Pet Index: every pet in the game as a tile. Hatched pets show their
-- picture, name and rarity strip; the rest are dark silhouettes with "???".

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pets = require(ReplicatedStorage:WaitForChild("Shared").Config.Pets)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Parent.Components.Gradient)
local PetImage = require(script.Parent.Parent.Parent.Parent.Components.PetImage)
local Window = require(script.Parent.Parent.Parent.Window)

local new = Theme.new

local Index = {}

function Index.build(holder: Frame): ScrollingFrame
	return Window.grid(holder, 104, 132, 10)
end

function Index.fill(grid: ScrollingFrame, data: any)
	Window.clear(grid)
	for i, def in Pets.List do
		local found = data.discovered and data.discovered[def.id]
		local color = Pets.RarityColors[def.rarity]
		local tile = new("Frame", { Name = def.id, LayoutOrder = i, Parent = grid }, {
			Theme.corner(12),
			Theme.stroke(3, if found then color else Color3.fromRGB(70, 70, 80)),
		})
		Gradient.apply(tile, if found
			then { Color3.fromRGB(116, 117, 126), Color3.fromRGB(78, 79, 88) }
			else { Color3.fromRGB(58, 58, 66), Color3.fromRGB(36, 36, 42) })
		local picture = PetImage.new("pet", def.id, {
			Size = UDim2.fromOffset(80, 80),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 8),
			Parent = tile,
		})
		if not found and (picture:IsA("ImageLabel") or picture:IsA("ViewportFrame")) then
			(picture :: any).ImageColor3 = Color3.new(0, 0, 0)
		end
		local name = Theme.label({
			Size = UDim2.new(1, -8, 0, 34),
			Position = UDim2.new(0, 4, 1, -40),
			Text = if found then def.name else "???",
			TextColor3 = if found then Theme.Colors.White else Color3.fromRGB(150, 150, 160),
			TextWrapped = true,
			Parent = tile,
		})
		if not found then
			Theme.textStroke(2).Parent = name
		end
	end
end

return Index
