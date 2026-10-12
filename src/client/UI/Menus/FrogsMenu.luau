-- Frog Shop: buy, equip, or prompt Robux for every frog.
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Window = require(script.Parent.Window)

local new = Theme.new
local C = Theme.Colors

local FrogsMenu = {}

function FrogsMenu.build(body: Frame)
	local scroll = Window.grid(body, 190)
	return function(data)
		Window.clearCards(scroll)
		for i, frog in Frogs.List do
			local c = Window.card(scroll, i, frog.color)
			new("Frame", {
				Size = UDim2.fromOffset(56, 56),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 10),
				BackgroundColor3 = frog.color,
				Parent = c,
			}, { Theme.corner(28), Theme.stroke(3) })
			Theme.label({
				Size = UDim2.new(1, -10, 0, 26),
				Position = UDim2.fromOffset(5, 70),
				Text = frog.name,
				TextColor3 = C.Ink,
				Parent = c,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 22),
				Position = UDim2.fromOffset(5, 98),
				Text = `+{Format.abbreviate(frog.perBounce)} Hops / pad`,
				TextColor3 = C.DarkGreen,
				Parent = c,
			})

			local owned = data.frogs[frog.id]
			local text, color, action
			if data.equippedFrog == frog.id then
				text, color = "Equipped", C.Grey
			elseif owned then
				text, color = "Equip", C.Blue
				action = function()
					Window.report(Net.func("EquipFrog"):InvokeServer(frog.id))
				end
			elseif frog.robuxOnly then
				text, color = "Robux", C.Purple
				action = function()
					local id = Monetization.Products.PhoenixFrog
					if id ~= 0 then
						MarketplaceService:PromptProductPurchase(Players.LocalPlayer, id)
					else
						Window.report(false, "Not on sale yet")
					end
				end
			else
				local affordable = data.wins >= frog.price
				text = `🏆 {Format.abbreviate(frog.price)}`
				color = if affordable then C.Green else C.Red
				action = function()
					Window.report(Net.func("BuyFrog"):InvokeServer(frog.id))
				end
			end
			local b = Theme.button({
				Size = UDim2.new(1, -20, 0, 44),
				Position = UDim2.new(0, 10, 1, -54),
				Text = text,
				Color = color,
			}, function()
				if action then
					action()
				end
			end)
			b.Parent = c
		end
	end
end

return FrogsMenu
