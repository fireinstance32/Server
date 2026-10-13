-- "~ Codes ~" (reference): blurb, a dark blue text box and a green Redeem
-- button on the ocean-gradient card.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)
local Cards = require(script.Parent.Cards)

local new = Theme.new

local CodesSection = {}

function CodesSection.build(list: ScrollingFrame, order: number)
	Cards.header(list, "Codes", order)
	local card = Cards.card(list, { name = "Codes", size = Vector2.new(894, 306), order = order + 1, colors = "Ocean", horizontal = true, edge = 8 })
	for i, line in { "Redeem codes for Free Items,", "Boosts & More!" } do
		Cards.text(card, { text = line, size = 42, at = Vector2.new(447, 58 + (i - 1) * 49), width = 860, stroke = 4 })
	end

	local box = new("TextBox", {
		Name = "CodeBox",
		Size = UDim2.fromOffset(540, 87),
		Position = UDim2.fromOffset(47, 158),
		BackgroundColor3 = Color3.fromRGB(29, 79, 147),
		PlaceholderText = "Enter Code Here...",
		PlaceholderColor3 = Color3.fromRGB(170, 190, 220),
		Text = "",
		TextSize = 34,
		TextScaled = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.new(1, 1, 1),
		ClearTextOnFocus = false,
		ZIndex = 4,
		Parent = card,
	}, {
		Theme.corner(10),
		Theme.stroke(3, Color3.fromRGB(7, 23, 57)),
		new("UIPadding", { PaddingLeft = UDim.new(0, 28) }),
	})
	new("Frame", { -- darker lip under the box
		Size = UDim2.new(1, 0, 0, 8),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(7, 23, 57),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = box,
	}, { Theme.corner(10) })

	local redeem = Cards.buy(card, Vector2.new(597, 158), Vector2.new(255, 87), "Redeem", function()
		local ok, message = Net.func("RedeemCode"):InvokeServer(box.Text)
		Window.report(ok, message)
		if ok then
			box.Text = ""
		end
	end)
	local label = redeem:FindFirstChild("Label") :: TextLabel
	label.TextSize = 48
end

return CodesSection
