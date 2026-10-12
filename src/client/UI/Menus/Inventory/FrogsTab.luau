-- Inventory › Frogs ("My Stones" reference): "5 / 12 Frogs" and a tile per
-- frog with its picture (greyed until owned), ⚡ per pad, and Buy / Equip.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Format = require(Shared.Util.Format)
local Signature = require(Shared.Util.Signature)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)
local PetImage = require(script.Parent.Parent.Parent.Components.PetImage)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)

local new = Theme.new

local FrogsTab = {}

-- Only what the cards show: owned/equipped, and which prices are affordable.
local function key(data): string
	local affordable = {}
	for _, frog in Frogs.List do
		affordable[frog.id] = data.wins >= frog.price
	end
	return Signature.of(data.equippedFrog, data.frogs, affordable)
end

function FrogsTab.build(content: Frame)
	local count = Theme.label({
		Size = UDim2.new(1, -120, 0, 34),
		Position = UDim2.fromOffset(120, 0),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content,
	})
	local panel = Window.inset(content, { Size = UDim2.new(1, 0, 1, -42), Position = UDim2.fromOffset(0, 42) })
	local grid = Window.grid(panel, 150, 196)
	return Signature.guard(key, function(data)
		local owned = 0
		for _ in data.frogs do
			owned += 1
		end
		count.Text = `{owned} / {#Frogs.List} Frogs`
		Window.clear(grid)
		for i, frog in Frogs.List do
			local equipped = data.equippedFrog == frog.id
			local mine = data.frogs[frog.id] == true
			local card = new("Frame", { Name = frog.id, LayoutOrder = i, Parent = grid }, {
				Theme.corner(14),
				Theme.stroke(if equipped then 4 else 3, if equipped then Color3.fromRGB(140, 222, 255) else Color3.fromRGB(150, 152, 162)),
			})
			Gradient.apply(card, if equipped
				then { Color3.fromRGB(112, 150, 178), Color3.fromRGB(62, 86, 108) }
				else { Color3.fromRGB(116, 117, 126), Color3.fromRGB(70, 71, 80) })
			local picture = PetImage.new("frog", frog.id, {
				Size = UDim2.fromOffset(78, 78),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 4),
				ZIndex = 2,
				Parent = card,
			})
			if not mine and (picture:IsA("ImageLabel") or picture:IsA("ViewportFrame")) then
				(picture :: any).ImageColor3 = Color3.fromRGB(90, 90, 100)
			end
			Theme.label({ Size = UDim2.new(1, -10, 0, 26), Position = UDim2.fromOffset(5, 82), Text = frog.name, ZIndex = 3, Parent = card })
			local bonus = new("Frame", { Size = UDim2.new(1, -10, 0, 24), Position = UDim2.fromOffset(5, 108), BackgroundTransparency = 1, Parent = card })
			Icon.new("bolt", { Size = UDim2.fromOffset(24, 24), ZIndex = 3, Parent = bonus })
			local perPad = Theme.label({
				Size = UDim2.new(1, -26, 1, 0),
				Position = UDim2.fromOffset(26, 0),
				Text = `+{Format.abbreviate(frog.perBounce)} / pad`,
				TextColor3 = Color3.fromRGB(150, 255, 110),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
				Parent = bonus,
			})
			Theme.textStroke(3).Parent = perPad
			if equipped then
				Icon.new("check", { Size = UDim2.fromOffset(36, 36), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -8, 0, 8), ZIndex = 5, Parent = card })
			end

			local size = UDim2.new(1, -16, 0, 46)
			local position = UDim2.new(0, 8, 1, -54)
			local button
			if equipped then
				button = Window.button({ Size = size, Position = position, Text = "Equipped" }, "Grey", function() end)
			elseif mine then
				button = Window.button({ Size = size, Position = position, Text = "Equip" }, "Blue", function()
					Window.report(Net.func("EquipFrog"):InvokeServer(frog.id))
				end)
			elseif frog.rewardOnly then
				button = Window.button({ Size = size, Position = position, Text = frog.rewardOnly, TextScaled = true }, "Grey", function() end)
			elseif frog.robuxOnly then
				button = Window.button({ Size = size, Position = position, Text = `\u{E002} {Purchases.price("product", "PhoenixFrog")}` }, "Green", function()
					Purchases.product("PhoenixFrog")
				end)
			else
				local color = if data.wins >= frog.price then "Green" else "Red"
				button = Window.priceButton({ Size = size, Position = position }, color, "trophy", Format.abbreviate(frog.price), function()
					Window.report(Net.func("BuyFrog"):InvokeServer(frog.id))
				end)
			end
			button.Parent = card
		end
	end)
end

return FrogsTab
