-- Square menu tile (reference HUD): dark glassy tile, big 3D icon poking out
-- of the top, caption across the bottom, badge slot in the corner.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Badge = require(script.Parent.Badge)
local Icon = require(script.Parent.Icon)
local Sfx = require(script.Parent.Parent.Parent.Sfx)

local IconTile = {}

function IconTile.create(props: {
	icon: string, -- icon name (Config/IconAtlas)
	caption: string,
	color: string?, -- Gradient preset; defaults to the dark tile
	order: number,
	onClick: () -> (),
}): (TextButton, Badge.Badge)
	local tile = Theme.new("TextButton", {
		Name = props.caption,
		Text = "",
		AutoButtonColor = true,
		LayoutOrder = props.order,
	}, { Theme.corner(14), Theme.stroke(3) })
	Gradient.apply(tile, props.color or "Tile")
	tile.BackgroundTransparency = if props.color then 0 else 0.15

	Icon.new(props.icon, {
		Size = UDim2.fromScale(0.92, 0.82),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, -0.1),
		ZIndex = 2,
		Parent = tile,
	})
	Theme.label({
		Size = UDim2.fromScale(1.04, 0.3),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.97),
		Text = props.caption,
		ZIndex = 3,
		Parent = tile,
	})

	local scale = Theme.new("UIScale", { Parent = tile })
	Theme.hover(tile, scale)
	tile.Activated:Connect(function()
		Sfx.play("Click")
		scale.Scale = 0.9
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		props.onClick()
	end)

	return tile, Badge.attach(tile)
end

return IconTile
