-- Square menu tile: big icon on top, caption at the bottom, badge slot.
-- Icons are emoji placeholders until Phase 5 art.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Badge = require(script.Parent.Badge)

local IconTile = {}

function IconTile.create(props: {
	icon: string,
	caption: string,
	color: string,
	order: number,
	onClick: () -> (),
}): (TextButton, Badge.Badge)
	local tile = Theme.new("TextButton", {
		Name = props.caption,
		Text = "",
		AutoButtonColor = true,
		LayoutOrder = props.order,
	}, { Theme.corner(12), Theme.stroke(3) })
	Gradient.apply(tile, props.color)

	Theme.label({
		Size = UDim2.fromScale(0.8, 0.58),
		Position = UDim2.fromScale(0.1, 0.06),
		Text = props.icon,
		Parent = tile,
	})
	Theme.label({
		Size = UDim2.fromScale(0.94, 0.3),
		Position = UDim2.fromScale(0.03, 0.66),
		Text = props.caption,
		Parent = tile,
	})

	local scale = Theme.new("UIScale", { Parent = tile })
	tile.Activated:Connect(function()
		scale.Scale = 0.9
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		props.onClick()
	end)

	return tile, Badge.attach(tile)
end

return IconTile
