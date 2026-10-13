-- What each developer product does, by product name (Config/Monetization).
-- Each handler gets (player, data) and returns true once granted. Used for
-- normal purchases, gifts (run on the recipient) and Studio simulation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Pets = require(Shared.Config.Pets)
local Trails = require(Shared.Config.Trails)
local Net = require(Shared.Net)

local ProgressionService = require(script.Parent.Parent.ProgressionService)
local PetService = require(script.Parent.Parent.PetService)
local TrailService = require(script.Parent.Parent.TrailService)
local Stock = require(script.Parent.Stock)
local Rewards = require(script.Parent.Parent.Parent.Rewards)

local Handlers: { [string]: (Player, any) -> boolean } = {}

for name, amount in Monetization.HopsPacks do
	Handlers[name] = function(_, data)
		data.hops += amount
		return true
	end
end

-- Bundles (Starter Pack, Boost Bundle, Wins packs...): grant every reward.
-- A one-time offer bought twice anyway (two clients) still grants: it was paid.
for name, bundle in Monetization.Bundles do
	Handlers[name] = function(_, data)
		for _, reward in bundle.rewards do
			Rewards.grant(data, reward)
		end
		if bundle.oneTime then
			data.oneTime[name] = true
		end
		return true
	end
end

Handlers.SkipRebirth = function(_, data)
	return (ProgressionService.applyRebirth(data, true))
end

Handlers.PhoenixFrog = function(_, data)
	Stock.claim("PhoenixFrog")
	data.frogs.Phoenix = true
	data.equippedFrog = "Phoenix"
	return true
end

-- Robux eggs: hatch `count` and show the reveal on the recipient's screen.
local function eggHandler(egg: Pets.Egg, count: number)
	return function(player: Player, data: any): boolean
		local results = PetService.grantHatch(player, data, egg, count)
		task.defer(function()
			PetService.refreshModels(player)
			Net.event("Notify"):FireClient(player, { kind = "Hatch", egg = egg.id, results = results })
		end)
		return true
	end
end
for _, egg in Pets.Eggs do
	if egg.product then
		Handlers[egg.product] = eggHandler(egg, 1)
	end
end
for name, bundle in Monetization.EggBundles do
	Handlers[name] = eggHandler(Pets.EggsById[bundle.egg], bundle.count)
end

for _, trail in Trails.List do
	if trail.product then
		Handlers[trail.product] = function(_, data)
			TrailService.grant(data, trail.id)
			return true
		end
	end
end

return Handlers
