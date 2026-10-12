-- Robux purchases. Receipts are idempotent (each PurchaseId is granted once
-- and remembered in the player's data); product effects live in Handlers,
-- gifts in Gifting, limited stock in Stock. Unset (0) ids are ignored.

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Passes = require(script.Parent.Parent.Passes)
local DataService = require(script.Parent.DataService)
local Handlers = require(script.Handlers)
local Gifting = require(script.Gifting)
local Stock = require(script.Stock)

local MonetizationService = {}

local RECEIPT_MEMORY = 50

-- productId -> function(player, data) -> granted
local byId: { [number]: (Player, any) -> boolean } = {}

local function rememberReceipt(data: any, purchaseId: string)
	data.receipts[purchaseId] = true
	table.insert(data.receiptOrder, purchaseId)
	while #data.receiptOrder > RECEIPT_MEMORY do
		data.receipts[table.remove(data.receiptOrder, 1)] = nil
	end
end

local function processReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local data = player and DataService.get(player)
	if not player or not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if data.receipts[receipt.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- already granted earlier
	end
	local handler = byId[receipt.ProductId]
	if not handler then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok, granted = pcall(handler, player, data)
	if not ok or not granted then
		if not ok then
			warn("[Monetization] handler error:", granted)
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	rememberReceipt(data, receipt.PurchaseId)
	data.stats.robuxSpent += receipt.CurrencySpent or 0 -- Top Robux Spent board
	DataService.changed(player)
	DataService.saveNow(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Studio testing: run a product's effect without buying it.
function MonetizationService.simulate(player: Player, productName: string): boolean
	local data = DataService.get(player)
	local handler = Handlers[productName]
	if not data or not handler then
		return false
	end
	local granted = handler(player, data)
	if granted then
		DataService.changed(player)
	end
	return granted
end

function MonetizationService.start()
	for name, item in Monetization.Products do
		local handler = Handlers[name]
		if handler and item.id ~= 0 then
			byId[item.id] = handler
		end
	end
	for item, giftId in Monetization.GiftIds do
		if giftId ~= 0 then
			byId[giftId] = function(buyer)
				return Gifting.grantGift(buyer, item)
			end
		end
	end

	Stock.start()
	Gifting.start()
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		local name = Passes.nameForId(passId)
		if purchased and name then
			Passes.grant(player, name)
			local data = DataService.get(player)
			if data then
				data.stats.robuxSpent += Monetization.Passes[name].price
			end
			DataService.changed(player)
		end
	end)
end

return MonetizationService
