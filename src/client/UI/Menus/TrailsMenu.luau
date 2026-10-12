-- Trails (reference trail shop): one coloured, studded card per trail with a
-- streak in the trail's colours, ⚡ "+N Hops Boost", and Buy / Equip /
-- Unequip (Robux trails prompt their product). Also the Inventory › Trails tab.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Trails = require(Shared.Config.Trails)
local Format = require(Shared.Util.Format)
local Signature = require(Shared.Util.Signature)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Icon = require(script.Parent.Parent.Components.Icon)
local Studs = require(script.Parent.Parent.Components.Studs)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Window)

local new = Theme.new

local TrailsMenu = {}

-- Only what the cards show: owned/equipped, and which prices are affordable.
local function key(data): string
	local affordable = {}
	for _, trail in Trails.List do
		affordable[trail.id] = data.wins >= trail.price
	end
	return Signature.of(data.equippedTrail, data.trails, affordable)
end

-- Diagonal streak in the trail's colours with a couple of sparkles.
local function streak(card: Frame, colors: { Color3 })
	local bar = new("Frame", {
		Size = UDim2.new(0.86, 0, 0, 30),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 82),
		Rotation = -14,
		ZIndex = 2,
		Parent = card,
	}, { Theme.corner(15), Theme.stroke(3, Color3.fromRGB(255, 255, 255)) })
	local gradient = Gradient.apply(bar, colors)
	gradient.Rotation = 0
	-- Fade the tail end like a real trail.
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(0.4, 0.1),
		NumberSequenceKeypoint.new(1, 0),
	})
	for i, spot in { { 0.18, 48, 22 }, { 0.84, 104, 18 } } do
		Icon.new("star", {
			Size = UDim2.fromOffset(spot[3], spot[3]),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(spot[1], 0, 0, spot[2]),
			Rotation = i * 17,
			ZIndex = 3,
			Parent = card,
		})
	end
end

local function bonusLine(card: Frame, bonus: number)
	local row = new("Frame", {
		Size = UDim2.new(1, -16, 0, 30),
		Position = UDim2.fromOffset(8, 118),
		BackgroundTransparency = 1,
		ZIndex = 3,
		Parent = card,
	})
	Icon.new("bolt", { Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(0, 1), ZIndex = 3, Parent = row })
	local text = Theme.label({
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.fromOffset(30, 0),
		Text = `+{bonus} Hops Boost`,
		TextColor3 = Color3.fromRGB(150, 255, 110),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = row,
	})
	Theme.textStroke(3).Parent = text
end

function TrailsMenu.build(body: Frame)
	local panel = Window.inset(body)
	local grid = Window.grid(panel, 190, 218)
	return Signature.guard(key, function(data)
		Window.clear(grid)
		for i, trail in Trails.List do
			local base = trail.colors[1]
			local equipped = data.equippedTrail == trail.id
			local card = new("Frame", { Name = trail.id, LayoutOrder = i, Parent = grid }, {
				Theme.corner(14),
				Theme.stroke(if equipped then 4 else 3, if equipped then Color3.fromRGB(140, 222, 255) else Color3.fromRGB(12, 12, 16)),
			})
			Gradient.apply(card, { base:Lerp(Color3.new(1, 1, 1), 0.12), base:Lerp(Color3.new(0, 0, 0), 0.45) })
			Studs.apply(card, 24, 0.3)
			Theme.label({ Size = UDim2.new(1, -16, 0, 32), Position = UDim2.fromOffset(8, 8), Text = trail.name, ZIndex = 3, Parent = card })
			streak(card, trail.colors)
			bonusLine(card, trail.bonus)

			local owned = data.trails and data.trails[trail.id]
			local text, color, action
			local priceIcon: string? = nil
			if equipped then
				text, color = "Unequip", "Grey"
				action = function()
					Window.report(Net.func("EquipTrail"):InvokeServer(""))
				end
			elseif owned then
				text, color = "Equip", "Blue"
				action = function()
					Window.report(Net.func("EquipTrail"):InvokeServer(trail.id))
				end
			elseif trail.product then
				text, color = `\u{E002} {Purchases.price("product", trail.product)}`, "Green"
				action = function()
					Purchases.product(trail.product :: string)
				end
			else
				text, priceIcon = Format.abbreviate(trail.price), "trophy"
				color = if data.wins >= trail.price then "Green" else "Red"
				action = function()
					Window.report(Net.func("BuyTrail"):InvokeServer(trail.id))
				end
			end
			local props = { Size = UDim2.new(1, -20, 0, 46), Position = UDim2.new(0, 10, 1, -56), ZIndex = 3 }
			local button
			if priceIcon then
				button = Window.priceButton(props, color, priceIcon, text, action)
			else
				props.Text = text
				button = Window.button(props, color, action)
			end
			button.Parent = card
			if equipped then
				Icon.new("check", {
					Size = UDim2.fromOffset(40, 40),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(1, -8, 0, 8),
					ZIndex = 5,
					Parent = card,
				})
			end
		end
	end)
end

return TrailsMenu
