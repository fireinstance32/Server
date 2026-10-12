-- Inventory › Frogs: every frog with Buy / Equip. (Phase 2.1 moves buying
-- to podiums in the world; this tab then only equips.)

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
	local grid = Window.grid(content, 150, 190)
	return Signature.guard(key, function(data)
		Window.clear(grid)
		for i, frog in Frogs.List do
			local card = Window.card(grid, i, frog.color)
			PetImage.new("frog", frog.id, {
				Size = UDim2.fromOffset(70, 70),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 2),
				Parent = card,
			})
			Theme.label({ Size = UDim2.new(1, -10, 0, 26), Position = UDim2.fromOffset(5, 70), Text = frog.name, Parent = card })
			Theme.label({
				Size = UDim2.new(1, -10, 0, 22),
				Position = UDim2.fromOffset(5, 98),
				Text = `+{Format.abbreviate(frog.perBounce)} Hops / pad`,
				TextColor3 = Color3.fromRGB(140, 235, 80),
				Parent = card,
			})

			local text, color, action
			if data.equippedFrog == frog.id then
				text, color = "Equipped", "Grey"
			elseif data.frogs[frog.id] then
				text, color = "Equip", "Blue"
				action = function()
					Window.report(Net.func("EquipFrog"):InvokeServer(frog.id))
				end
			elseif frog.rewardOnly then
				text, color = frog.rewardOnly, "Grey"
			elseif frog.robuxOnly then
				text, color = `\u{E002} {Purchases.price("product", "PhoenixFrog")}`, "Purple"
				action = function()
					Purchases.product("PhoenixFrog")
				end
			else
				text = `🏆 {Format.abbreviate(frog.price)}`
				color = if data.wins >= frog.price then "Green" else "Red"
				action = function()
					Window.report(Net.func("BuyFrog"):InvokeServer(frog.id))
				end
			end
			local button = Window.button({
				Size = UDim2.new(1, -20, 0, 44),
				Position = UDim2.new(0, 10, 1, -54),
				Text = text,
			}, color, function()
				if action then
					action()
				end
			end)
			button.Parent = card
		end
	end)
end

return FrogsTab
