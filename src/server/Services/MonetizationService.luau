-- Developer product receipts and in-game game pass purchases.
-- All IDs live in Shared.Config.Monetization; unset (0) IDs are ignored.

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)

local Passes = require(script.Parent.Parent.Passes)
local DataService = require(script.Parent.DataService)
local ProgressionService = require(script.Parent.ProgressionService)
local PetService = require(script.Parent.PetService)
local Net = require(Shared.Net)
local Pets = require(Shared.Config.Pets)

local MonetizationService = {}

-- productId -> function(player, data). Return true once the reward is granted.
local handlers: { [number]: (Player, any) -> boolean } = {}

local function register(id: number, handler: (Player, any) -> boolean)
	if id ~= 0 then
		handlers[id] = handler
	end
end

local function processReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	local data = player and DataService.get(player)
	local handler = handlers[receipt.ProductId]
	if not player or not data or not handler then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok, granted = pcall(handler, player, data)
	if not ok or not granted then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	DataService.changed(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationService.start()
	local products = Monetization.Products

	for name, amount in Monetization.HopsPacks do
		register(products[name].id, function(_, data)
			data.hops += amount
			return true
		end)
	end

	register(products.StarterPack.id, function(_, data)
		local pack = Monetization.StarterPack
		data.hops += pack.hops
		data.wins += pack.wins
		data.rebirths += pack.rebirths
		return true
	end)

	register(products.SkipRebirth.id, function(_, data)
		return (ProgressionService.applyRebirth(data, true))
	end)

	-- Robux eggs: hatch one and show the reveal on the buyer's screen.
	for _, egg in Pets.Eggs do
		local product = egg.product and products[egg.product]
		if product then
			register(product.id, function(player, data)
				local results = PetService.grantHatch(player, data, egg, 1)
				task.defer(function()
					PetService.refreshModels(player)
					Net.event("Notify"):FireClient(player, { kind = "Hatch", egg = egg.id, results = results })
				end)
				return true
			end)
		end
	end

	register(products.PhoenixFrog.id, function(_, data)
		data.frogs.Phoenix = true
		data.equippedFrog = "Phoenix"
		return true
	end)

	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		local name = Passes.nameForId(passId)
		if purchased and name then
			Passes.grant(player, name)
			DataService.changed(player)
		end
	end)
end

return MonetizationService
