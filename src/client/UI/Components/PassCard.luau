-- Right-side pass card: "+2x HOPS / ONLY ◎ 5", or "OWNED" once bought.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Studs = require(script.Parent.Studs)
local Icon = require(script.Parent.Icon)

local PassCard = {}

export type PassCard = { button: TextButton, setOwned: (owned: boolean) -> () }

function PassCard.create(props: {
	title: string,
	icon: string?, -- icon name, drawn over the card's top edge
	price: number,
	color: string,
	order: number,
	onClick: () -> (),
}): PassCard
	local button = Theme.new("TextButton", {
		Name = props.title,
		Size = UDim2.new(1, 0, 0, 70),
		Text = "",
		AutoButtonColor = true,
		LayoutOrder = props.order,
	}, { Theme.corner(12), Theme.stroke(3) })
	Gradient.apply(button, props.color)
	Studs.apply(button, 22, 0.5)
	if props.icon then
		Icon.new(props.icon, {
			Size = UDim2.fromOffset(62, 62),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, -2),
			Rotation = -8,
			ZIndex = 2,
			Parent = button,
		})
	end

	Theme.label({
		Size = UDim2.new(0.9, 0, 0.55, 0),
		Position = UDim2.fromScale(0.05, 0.05),
		Text = props.title,
		ZIndex = 3,
		Parent = button,
	})
	local priceLabel = Theme.label({
		Size = UDim2.new(0.9, 0, 0.35, 0),
		Position = UDim2.fromScale(0.05, 0.6),
		Text = `ONLY \u{E002} {props.price}`,
		TextColor3 = Theme.Colors.Gold,
		ZIndex = 3,
		Parent = button,
	})
	Theme.textStroke().Parent = priceLabel

	button.Activated:Connect(props.onClick)

	return {
		button = button,
		setOwned = function(owned: boolean)
			priceLabel.Text = if owned then "OWNED" else `ONLY \u{E002} {props.price}`
		end,
	}
end

return PassCard
