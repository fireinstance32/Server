-- Trails: every trail with a colour swatch, +bonus and Buy / Equip /
-- Equipped (Robux trails prompt their product). Also used as the
-- Inventory › Trails tab.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Trails = require(Shared.Config.Trails)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Window)

local new = Theme.new

local TrailsMenu = {}

function TrailsMenu.build(body: Frame)
	local grid = Window.grid(body, 170, 190)
	return function(data)
		Window.clear(grid)
		for i, trail in Trails.List do
			local card = Window.card(grid, i, trail.colors[1])
			local swatch = new("Frame", {
				Size = UDim2.new(1, -24, 0, 34),
				Position = UDim2.fromOffset(12, 12),
				Parent = card,
			}, { Theme.corner(10), Theme.stroke(2) })
			Gradient.apply(swatch, trail.colors)
			swatch:FindFirstChildOfClass("UIGradient").Rotation = 0
			Theme.label({ Size = UDim2.new(1, -10, 0, 26), Position = UDim2.fromOffset(5, 52), Text = trail.name, Parent = card })
			local bonus = Theme.label({
				Size = UDim2.new(1, -10, 0, 24),
				Position = UDim2.fromOffset(5, 80),
				Text = `⚡ +{trail.bonus}`,
				TextColor3 = Color3.fromRGB(140, 235, 80),
				Parent = card,
			})
			Theme.textStroke().Parent = bonus

			local owned = data.trails and data.trails[trail.id]
			local equipped = data.equippedTrail == trail.id
			local text, color, action
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
				text, color = `\u{E002} {Purchases.price("product", trail.product)}`, "Purple"
				action = function()
					Purchases.product(trail.product :: string)
				end
			else
				text = `🏆 {Format.abbreviate(trail.price)}`
				color = if data.wins >= trail.price then "Green" else "Red"
				action = function()
					Window.report(Net.func("BuyTrail"):InvokeServer(trail.id))
				end
			end
			local button = Window.button({
				Size = UDim2.new(1, -20, 0, 44),
				Position = UDim2.new(0, 10, 1, -54),
				Text = text,
			}, color, action)
			button.Parent = card
		end
	end
end

return TrailsMenu
