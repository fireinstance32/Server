-- "~ Pack ~": the Starter Pack card (rainbow, contents, struck-out price).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local PackSection = {}

function PackSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Pack", order)

	local pack = Monetization.StarterPack
	local card = new("Frame", {
		Name = "StarterPack",
		Size = UDim2.new(1, -10, 0, 210),
		LayoutOrder = order + 1,
		Parent = list,
	}, { Theme.corner(14), Theme.stroke(4, Color3.fromRGB(255, 220, 90)) })
	Gradient.apply(card, "Rainbow")

	Theme.label({ Size = UDim2.fromOffset(150, 150), Position = UDim2.fromOffset(20, 30), Text = "🐸🎉", Parent = card })
	Theme.label({
		Size = UDim2.new(1, -220, 0, 60),
		Position = UDim2.fromOffset(200, 10),
		Text = "Starter Pack",
		TextColor3 = Color3.fromRGB(255, 245, 170),
		Parent = card,
	}).TextXAlignment = Enum.TextXAlignment.Left

	local contents = new("Frame", {
		Size = UDim2.new(1, -220, 0, 70),
		Position = UDim2.fromOffset(200, 74),
		BackgroundTransparency = 1,
		Parent = card,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
		}),
	})
	for _, item in {
		{ "🐸", `x{Format.abbreviate(pack.hops)}` },
		{ "🏆", `x{Format.abbreviate(pack.wins)}` },
		{ "🔁", `+{pack.rebirths}` },
	} do
		local tile = new("Frame", {
			Size = UDim2.fromOffset(80, 70),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.6,
			Parent = contents,
		}, { Theme.corner(10), Theme.stroke(2, Color3.new(1, 1, 1)) })
		Theme.label({ Size = UDim2.fromScale(1, 0.55), Text = item[1], Parent = tile })
		Theme.label({ Size = UDim2.fromScale(1, 0.4), Position = UDim2.fromScale(0, 0.58), Text = item[2], Parent = tile })
	end

	local oldPrice = Theme.label({
		Size = UDim2.fromOffset(100, 40),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -200, 1, -14),
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
		Size = UDim2.fromOffset(170, 56),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -12),
		Text = `\u{E002} {Purchases.price("product", "StarterPack")}`,
	}, "Green", function()
		Purchases.product("StarterPack")
	end)
	buy.Font = Enum.Font.BuilderSansBold
	buy.Parent = card

	-- One-time offer: show it as owned once bought.
	return function(data)
		local bought = data.oneTime and data.oneTime.StarterPack
		buy.Text = if bought then "OWNED" else `\u{E002} {Purchases.price("product", "StarterPack")}`
		buy.Active = not bought
		Gradient.apply(buy, if bought then "Grey" else "Green")
	end
end

return PackSection
