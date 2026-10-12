-- A little painted view of a world for its Worlds card (until real
-- screenshots are uploaded): sky in the world's lighting colours, a checker
-- plaza in its theme, a river with lily pads, and a few trees.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared").Config.Worlds)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)

local new = Theme.new

local Scene = {}

local WATER = Color3.fromRGB(80, 190, 255)

function Scene.build(card: GuiObject, world: Worlds.World)
	local theme = Worlds.theme(world)
	local sky = new("Frame", {
		Name = "Scene",
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		Parent = card,
	}, { Theme.corner(10) })
	Gradient.apply(sky, { theme.lighting.atmosphere:Lerp(Color3.new(1, 1, 1), 0.35), theme.lighting.atmosphere })

	-- Plaza: two rows of checker tiles across the lower half.
	local ground = new("Frame", {
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = theme.plaza,
		Parent = sky,
	})
	local columns = 12
	for row = 0, 2 do
		for col = 0, columns - 1 do
			if (row + col) % 2 == 0 then
				new("Frame", {
					Size = UDim2.fromScale(1 / columns, 1 / 3),
					Position = UDim2.fromScale(col / columns, row / 3),
					BackgroundColor3 = theme.plazaAlt,
					Parent = ground,
				})
			end
		end
	end
	-- River with lily pads running across the plaza.
	local river = new("Frame", {
		Size = UDim2.new(1.2, 0, 0.16, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.74),
		Rotation = -6,
		BackgroundColor3 = WATER,
		Parent = sky,
	}, { Theme.stroke(3, WATER:Lerp(Color3.new(0, 0, 0), 0.35)) })
	Gradient.apply(river, { WATER:Lerp(Color3.new(1, 1, 1), 0.3), WATER })
	for i = 1, 6 do
		new("Frame", {
			Size = UDim2.fromScale(0.07, 0.55),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.08 + i * 0.13, 0.5),
			BackgroundColor3 = theme.pad,
			Parent = river,
		}, { new("UICorner", { CornerRadius = UDim.new(0.5, 0) }), Theme.stroke(2, theme.pad:Lerp(Color3.new(0, 0, 0), 0.4)) })
	end
	-- Blocky trees along the back edge.
	for i, x in { 0.08, 0.3, 0.62, 0.9 } do
		local h = 0.18 + (i % 2) * 0.05
		new("Frame", {
			Size = UDim2.fromScale(0.025, h),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(x, 0.56),
			BackgroundColor3 = Color3.fromRGB(120, 80, 50),
			Parent = sky,
		})
		new("Frame", {
			Size = UDim2.fromScale(0.09, h * 0.75),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(x, 0.56 - h + 0.04),
			BackgroundColor3 = theme.pad:Lerp(Color3.new(1, 1, 1), 0.15),
			Parent = sky,
		}, { Theme.corner(4), Theme.stroke(2, theme.pad:Lerp(Color3.new(0, 0, 0), 0.45)) })
	end
	return sky
end

return Scene
