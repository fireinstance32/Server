-- "Gift to…" pop-up over the shop: lists the other players in the server;
-- picking one starts the gift purchase of `item` for them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local Purchases = require(script.Parent.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local GiftPicker = {}

function GiftPicker.open(over: GuiObject, item: string)
	local existing = over:FindFirstChild("GiftPicker")
	if existing then
		existing:Destroy()
	end
	local info = Monetization.Passes[item] or Monetization.Products[item]
	local backdrop = new("TextButton", {
		Name = "GiftPicker",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 20,
		Parent = over,
	}, { Theme.corner(16) })
	local panel = Window.inset(backdrop, {
		Size = UDim2.new(0.7, 0, 0.8, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 21,
	})
	Theme.pop(panel)
	Icon.new("gifts", { Size = UDim2.fromOffset(70, 70), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(6, 0), Rotation = -12, ZIndex = 23, Parent = panel })
	Theme.label({
		Size = UDim2.new(1, -100, 0, 40),
		Position = UDim2.fromOffset(50, 0),
		Text = `Gift {info and info.label or item} to:`,
		ZIndex = 22,
		Parent = panel,
	})
	local close = new("ImageButton", {
		Size = UDim2.fromOffset(52, 52),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 23,
		Parent = panel,
	})
	Icon.new("close", { Size = UDim2.fromScale(1, 1), ZIndex = 23, Parent = close })
	close.Activated:Connect(function()
		backdrop:Destroy()
	end)
	backdrop.Activated:Connect(function()
		backdrop:Destroy()
	end)

	local list = Window.list(panel, 8)
	list.Size = UDim2.new(1, 0, 1, -48)
	list.Position = UDim2.fromOffset(0, 48)
	list.ZIndex = 22
	local any = false
	for _, player in Players:GetPlayers() do
		if player ~= Players.LocalPlayer then
			any = true
			local button = Window.button({
				Size = UDim2.new(1, -8, 0, 56),
				Text = player.DisplayName,
				ZIndex = 22,
			}, "Pink", function()
				backdrop:Destroy()
				Purchases.gift(item, player.UserId)
			end)
			button.Parent = list
		end
	end
	if not any then
		Theme.label({
			Size = UDim2.new(1, -8, 0, 40),
			Text = "No other players in this server yet",
			ZIndex = 22,
			Parent = list,
		})
	end
end

return GiftPicker
