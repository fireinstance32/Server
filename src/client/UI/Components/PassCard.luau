-- Right-side pass card: "+2x HOPS / ONLY ◎ 5", or "OWNED" once bought.
-- Reference look: big icon behind the title, edge in the card's own darker
-- hue, orange "ONLY" with a green price.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Studs = require(script.Parent.Studs)
local Icon = require(script.Parent.Icon)

local PassCard = {}

export type PassCard = { button: TextButton, setOwned: (owned: boolean) -> () }

local function priceText(price: number): string
	return `<font color="#F19B0B">ONLY</font>  <font color="#FFD83A">\u{E002}</font> <font color="#8CEB2A">{price}</font>`
end

function PassCard.create(props: {
	title: string,
	icon: string?, -- icon name, drawn big behind the title
	price: number,
	color: string,
	order: number,
	onClick: () -> (),
}): PassCard
	local button = Theme.new("TextButton", {
		Name = props.title,
		Size = UDim2.new(1, 0, 0, 84),
		Text = "",
		AutoButtonColor = true,
		LayoutOrder = props.order,
	}, { Theme.corner(10), Theme.stroke(3, Gradient.Edges[props.color]) })
	Gradient.apply(button, props.color)
	Studs.apply(button, 22, 0.5)
	if props.icon then
		Icon.new(props.icon, {
			Size = UDim2.fromOffset(86, 86),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.3),
			ZIndex = 2,
			Parent = button,
		})
	end

	Theme.label({
		Size = UDim2.new(0.92, 0, 0.5, 0),
		Position = UDim2.fromScale(0.04, 0.1),
		Text = props.title,
		ZIndex = 3,
		Parent = button,
	})
	local priceLabel = Theme.label({
		Size = UDim2.new(0.86, 0, 0.32, 0),
		Position = UDim2.fromScale(0.07, 0.62),
		Text = priceText(props.price),
		RichText = true,
		ZIndex = 3,
		Parent = button,
	})

	button.Activated:Connect(props.onClick)

	return {
		button = button,
		setOwned = function(owned: boolean)
			priceLabel.Text = if owned then "OWNED" else priceText(props.price)
		end,
	}
end

return PassCard
