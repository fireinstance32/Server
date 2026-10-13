-- Building blocks of the Shop (Stone Skipping shop video, measured 1:1 at the
-- 1920×1056 design view): studded gradient cards with a black edge and a
-- light rim, fixed-size outlined text, the purple gift button, the green
-- Robux price button and the struck-out "was" price. Every position and
-- size is in pixels of the card's OUTER box (black edge included), as
-- measured from the video.

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local GiftPicker = require(script.Parent.GiftPicker)

local new = Theme.new

local Cards = {}

Cards.Ink = Color3.fromRGB(8, 8, 10)
Cards.Robux = "\u{E002} " -- Roblox's Robux glyph (in every font) and its gap

-- Card fills sampled from the video: top-left, middle-left, bottom-left
-- (vertical) or left → right (`horizontal`).
Cards.Colors = {
	Blue = { Color3.fromRGB(186, 232, 250), Color3.fromRGB(124, 190, 237), Color3.fromRGB(83, 159, 229) },
	Purple = { Color3.fromRGB(224, 194, 248), Color3.fromRGB(182, 133, 236), Color3.fromRGB(159, 93, 233) },
	Red = { Color3.fromRGB(247, 188, 171), Color3.fromRGB(232, 121, 115), Color3.fromRGB(222, 81, 83) },
	Orange = { Color3.fromRGB(249, 223, 165), Color3.fromRGB(238, 178, 107), Color3.fromRGB(237, 158, 87) },
	Cyan = { Color3.fromRGB(194, 252, 240), Color3.fromRGB(128, 228, 207), Color3.fromRGB(97, 221, 192) },
	Green = { Color3.fromRGB(195, 254, 124), Color3.fromRGB(129, 214, 101), Color3.fromRGB(83, 175, 104) },
	Lime = { Color3.fromRGB(223, 255, 130), Color3.fromRGB(172, 255, 104), Color3.fromRGB(107, 229, 111) },
	Pink = { Color3.fromRGB(249, 213, 232), Color3.fromRGB(237, 157, 194), Color3.fromRGB(233, 122, 174) },
	Gold = { Color3.fromRGB(251, 239, 160), Color3.fromRGB(247, 211, 110), Color3.fromRGB(247, 188, 80) },
	Wins = { Color3.fromRGB(249, 227, 110), Color3.fromRGB(245, 193, 74), Color3.fromRGB(243, 166, 60) },
	Crimson = { Color3.fromRGB(214, 30, 86), Color3.fromRGB(198, 18, 72), Color3.fromRGB(170, 12, 65) },
	Ocean = { -- Boost Bundle and Codes, left → right
		Color3.fromRGB(65, 255, 158),
		Color3.fromRGB(34, 182, 193),
		Color3.fromRGB(32, 136, 216),
		Color3.fromRGB(55, 104, 248),
	},
	Rose = { Color3.fromRGB(242, 122, 152), Color3.fromRGB(223, 62, 100) }, -- Skill Boost, left → right
	Lemon = { Color3.fromRGB(249, 236, 90), Color3.fromRGB(247, 187, 55) }, -- Win Boost, left → right
} :: { [string]: { Color3 } }

export type CardSpec = {
	name: string,
	size: Vector2, -- outer size
	position: Vector2?, -- outer top-left inside `parent` (rows); omit in lists
	order: number?,
	colors: string | { Color3 }, -- Cards.Colors name, Gradient preset or colours
	horizontal: boolean?,
	edge: number?, -- black edge (default 7)
	rim: Color3?, -- solid rim colour (Pack cards: gold); default a soft white rim
}

-- Black-edged card: a black box with the studded gradient fill inset by the
-- edge, then a 6 px rim. Children go on the returned (outer) frame.
function Cards.card(parent: Instance, spec: CardSpec): Frame
	local edge = spec.edge or 7
	local card = new("Frame", {
		Name = spec.name,
		Size = UDim2.fromOffset(spec.size.X, spec.size.Y),
		Position = if spec.position then UDim2.fromOffset(spec.position.X, spec.position.Y) else nil,
		BackgroundColor3 = Cards.Ink,
		LayoutOrder = spec.order or 0,
		Parent = parent,
	}, { Theme.corner(4) })
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.new(1, -2 * edge, 1, -2 * edge),
		Position = UDim2.fromOffset(edge, edge),
		ZIndex = 1,
		Parent = card,
	}, { Theme.corner(2) })
	local colors = spec.colors
	local gradient = Gradient.apply(fill, if typeof(colors) == "string" and Cards.Colors[colors] then Cards.Colors[colors] else colors)
	if spec.horizontal then
		gradient.Rotation = 0
	end
	Studs.apply(fill, 24)
	new("Frame", { -- rim: a stroke drawn just inside the black edge
		Name = "Rim",
		Size = UDim2.new(1, -2 * (edge + 6), 1, -2 * (edge + 6)),
		Position = UDim2.fromOffset(edge + 6, edge + 6),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = card,
	}, {
		new("UIStroke", {
			Thickness = 6,
			Color = spec.rim or Color3.new(1, 1, 1),
			Transparency = if spec.rim then 0 else 0.6,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
	return card
end

export type TextSpec = {
	text: string,
	size: number, -- font size (Montserrat Black capitals ≈ 0.7 × size)
	at: Vector2, -- anchor point position
	anchor: Vector2?, -- default centre
	width: number?, -- box width (default 600)
	color: Color3?,
	stroke: number?, -- outline thickness (default size / 14)
	align: Enum.TextXAlignment?,
	zIndex: number?,
	name: string?,
}

-- Fixed-size text with a black outline, placed by its anchor point.
function Cards.text(parent: Instance, spec: TextSpec): TextLabel
	local label = Theme.label({
		Name = spec.name or "Text",
		Size = UDim2.fromOffset(spec.width or 600, math.ceil(spec.size * 1.2)),
		AnchorPoint = spec.anchor or Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(spec.at.X, spec.at.Y),
		Text = spec.text,
		TextScaled = false,
		TextSize = spec.size,
		TextColor3 = spec.color or Color3.new(1, 1, 1),
		TextXAlignment = spec.align or Enum.TextXAlignment.Center,
		ZIndex = spec.zIndex or 4,
		Parent = parent,
	})
	local stroke = label:FindFirstChildOfClass("UIStroke") or Theme.textStroke()
	stroke.Thickness = spec.stroke or math.max(math.floor(spec.size / 14 + 0.5), 2)
	stroke.Color = Cards.Ink
	stroke.Parent = label
	return label
end

-- Square-cornered button with a black edge, studs and a darker lip along
-- the bottom (reference price / gift buttons). `at`/`size` = outer box.
local function button(parent: Instance, at: Vector2, size: Vector2, colors: { Color3 }, onClick: () -> ()): TextButton
	local b = Theme.button({
		Name = "Button",
		Size = UDim2.fromOffset(size.X - 6, size.Y - 6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(at.X + size.X / 2, at.Y + size.Y / 2),
		Text = "",
		ZIndex = 5,
		Parent = parent,
	}, onClick)
	b:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 4)
	local stroke = b:FindFirstChildOfClass("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Cards.Ink
	Gradient.apply(b, colors)
	Studs.apply(b, 20)
	new("Frame", {
		Name = "Lip",
		Size = UDim2.new(1, 0, 0, 5),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = b,
	})
	return b
end

local BUY = { Color3.fromRGB(174, 255, 63), Color3.fromRGB(78, 235, 9) }
local GIFT = { Color3.fromRGB(193, 76, 241), Color3.fromRGB(116, 11, 195) }
local OWNED = { Color3.fromRGB(150, 150, 160), Color3.fromRGB(96, 96, 108) }

-- Green "⏣ 63" button. Change its text with Cards.setPrice.
function Cards.buy(parent: Instance, at: Vector2, size: Vector2, text: string, onClick: () -> ()): TextButton
	local b = button(parent, at, size, BUY, onClick)
	local label = b:FindFirstChild("Label") :: TextLabel
	label.TextScaled = false
	label.TextSize = math.floor(size.Y * 0.64)
	label.ZIndex = 7
	label.Text = text
	local stroke = label:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Thickness = 3
		stroke.Color = Cards.Ink
	end
	return b
end

-- Price / OWNED state of a Cards.buy button.
function Cards.setPrice(b: GuiObject, text: string, owned: boolean)
	Theme.setText(b, text)
	Gradient.apply(b, if owned then OWNED else BUY)
	if b:IsA("GuiButton") then
		b.Active = not owned
	end
end

-- Purple gift button: opens the friend picker for `item`.
function Cards.gift(parent: Instance, at: Vector2, size: Vector2, item: string, giftOver: GuiObject): TextButton
	local b = button(parent, at, size, GIFT, function()
		GiftPicker.open(giftOver, item)
	end)
	local side = math.min(size.X, size.Y) * 0.68
	Icon.new("gifts", {
		Size = UDim2.fromOffset(side, side),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 7,
		Parent = b,
	})
	return b
end

-- Red struck-out "⏣ 199", centred on `at`.
function Cards.struck(parent: Instance, at: Vector2, price: number, size: number?): TextLabel
	local label = Cards.text(parent, {
		text = `{Cards.Robux}{price}`,
		size = size or 42,
		at = at,
		width = 160,
		color = Color3.fromRGB(232, 40, 52),
		stroke = 3,
		name = "WasPrice",
	})
	new("Frame", {
		Name = "Strike",
		Size = UDim2.new(0.82, 0, 0, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Rotation = -14,
		BackgroundColor3 = Color3.fromRGB(150, 12, 20),
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = label,
	})
	return label
end

-- An icon by name (Config/IconAtlas) centred on `at`.
function Cards.icon(parent: Instance, name: string, at: Vector2, side: number, rotation: number?, zIndex: number?): GuiObject
	return Icon.new(name, {
		Size = UDim2.fromOffset(side, side),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(at.X, at.Y),
		Rotation = rotation or 0,
		ZIndex = zIndex or 3,
		Parent = parent,
	})
end

-- "~ Gamepasses ~": white, 36 px capitals, in a 59 px row.
function Cards.header(list: Instance, text: string, order: number): TextLabel
	local row = new("Frame", {
		Name = `{text}Header`,
		Size = UDim2.new(1, 0, 0, 59),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = list,
	})
	return Cards.text(row, { text = `~ {text} ~`, size = 52, at = Vector2.new(455, 29), width = 900, stroke = 4 })
end

-- Transparent row holding cards side by side (positions inside it).
function Cards.row(list: Instance, height: number, order: number): Frame
	return new("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = order,
		Parent = list,
	})
end

return Cards
