-- "~ Pack ~": the Starter Pack card (rainbow, contents, struck-out price).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)

local new = Theme.new

local PackSection = {}

function PackSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Pack", order)

	local pack = Monetization.StarterPack
	local card = new("Frame", {
		Name = "StarterPack",
		Size = UDim2.fromOffset(878, 303), -- reference starter card
		LayoutOrder = order + 1,
		Parent = list,
	}, { Theme.corner(3), Theme.stroke(4, Color3.fromRGB(8, 8, 10)) })
	Gradient.apply(card, "Rainbow")
	Studs.apply(card, 24)
	new("Frame", { -- gold inner rim inside the black edge
		Size = UDim2.new(1, -12, 1, -12),
		Position = UDim2.fromOffset(6, 6),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = card,
	}, { Theme.corner(1), Theme.stroke(6, Color3.fromRGB(255, 205, 70)) })

	Icon.new("starter", {
		Size = UDim2.fromOffset(240, 240),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(172, 152),
		Rotation = -6,
		Parent = card,
	})
	local title = Theme.label({
		Size = UDim2.fromOffset(520, 70),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(590, 55),
		Text = "Starter Pack",
		TextColor3 = Color3.fromRGB(255, 240, 170),
		Parent = card,
	})
	Theme.textStroke(4).Parent = title

	local contents = new("Frame", {
		Size = UDim2.new(0, 520, 0, 105),
		Position = UDim2.fromOffset(337, 98),
		BackgroundTransparency = 1,
		Parent = card,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 30),
		}),
	})
	for _, item in {
		{ "bolt", `x{Format.abbreviate(pack.hops)}` },
		{ "trophy", `x{Format.abbreviate(pack.wins)}` },
		{ "rebirth", `+{pack.rebirths}` },
	} do
		local tile = new("Frame", {
			Size = UDim2.fromOffset(105, 105),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.6,
			Parent = contents,
		}, { Theme.corner(10), Theme.stroke(2, Color3.new(1, 1, 1)) })
		Icon.new(item[1], { Size = UDim2.fromScale(0.8, 0.6), Position = UDim2.fromScale(0.1, 0.02), Parent = tile })
		Theme.label({ Size = UDim2.fromScale(1, 0.4), Position = UDim2.fromScale(0, 0.58), Text = item[2], Parent = tile })
	end

	local oldPrice = Theme.label({
		Size = UDim2.fromOffset(120, 48),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -240, 1, -20),
		Text = `\u{E002} {pack.originalPrice}`,
		TextColor3 = Color3.fromRGB(230, 50, 50),
		Font = Enum.Font.BuilderSansBold,
		Parent = card,
	})
	Theme.textStroke().Parent = oldPrice
	new("Frame", { -- strike-through line
		Size = UDim2.new(1, 0, 0, 4),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Rotation = -8,
		BackgroundColor3 = Color3.fromRGB(230, 50, 50),
		Parent = oldPrice,
	})

	local buy = Window.button({
		Size = UDim2.fromOffset(183, 70),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -33, 1, -23),
		Text = `\u{E002} {Purchases.price("product", "StarterPack")}`,
		Font = Enum.Font.BuilderSansBold,
	}, "Green", function()
		Purchases.product("StarterPack")
	end)
	buy.Parent = card

	-- One-time offer: show it as owned once bought.
	return function(data)
		local bought = data.oneTime and data.oneTime.StarterPack
		Theme.setText(buy, if bought then "OWNED" else `\u{E002} {Purchases.price("product", "StarterPack")}`)
		buy.Active = not bought
		Window.recolor(buy, if bought then "Grey" else "Green")
	end
end

return PackSection
