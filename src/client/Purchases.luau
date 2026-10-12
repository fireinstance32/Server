-- Prompts Robux purchases by config name and answers "does the player own
-- this pass?" from the latest snapshot. Unset ids show "Not on sale yet".

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local State = require(script.Parent.State)

local Purchases = {}

local notOnSale: ((string) -> ())? = nil

-- The HUD registers a toast function here so this module needn't require it.
function Purchases.onNotForSale(fn: (string) -> ())
	notOnSale = fn
end

local function unavailable(label: string)
	if notOnSale then
		notOnSale(`{label}: not on sale yet`)
	end
end

function Purchases.owns(passName: string): boolean
	local data = State.data
	return data ~= nil and data.passes ~= nil and data.passes[passName] == true
end

function Purchases.pass(passName: string)
	local item = Monetization.Passes[passName]
	if not item or item.id == 0 then
		unavailable(item and item.label or passName)
		return
	end
	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, item.id)
end

function Purchases.product(productName: string)
	local item = Monetization.Products[productName]
	if not item or item.id == 0 then
		unavailable(item and item.label or productName)
		return
	end
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, item.id)
end

function Purchases.price(kind: "pass" | "product", name: string): number
	local list = if kind == "pass" then Monetization.Passes else Monetization.Products
	local item = list[name]
	return if item then item.price else 0
end

return Purchases
