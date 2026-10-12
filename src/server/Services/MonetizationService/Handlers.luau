-- What each developer product does, by product name (Config/Monetization).
-- Each handler gets (player, data) and returns true once granted. Used for
-- normal purchases, gifts (run on the recipient) and Studio simulation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Pets = require(Shared.Config.Pets)
local Trails = require(Shared.Config.Trails)
local Potions = require(Shared.Config.Potions)
local Net = require(Shared.Net)

local ProgressionService = require(script.Parent.Parent.ProgressionService)
local PetService = require(script.Parent.Parent.PetService)
local TrailService = require(script.Parent.Parent.TrailService)
local Stock = require(script.Parent.Stock)

local Handlers: { [string]: (Player, any) -> boolean } = {}

for name, amount in Monetization.HopsPacks do
	Handlers[name] = function(_, data)
		data.hops += amount
		return true
	end
end

Handlers.StarterPack = function(_, data)
	local pack = Monetization.StarterPack
	data.hops += pack.hops
	data.wins += pack.wins
	data.rebirths += pack.rebirths
	data.oneTime.StarterPack = true
	return true
end

Handlers.SkipRebirth = function(_, data)
	return (ProgressionService.applyRebirth(data, true))
end

Handlers.PotionPack = function(_, data)
	for _, potion in Potions.List do
		data.potions[potion.id] = (data.potions[potion.id] or 0) + Monetization.PotionPackEach
	end
	return true
end

Handlers.PhoenixFrog = function(_, data)
	Stock.claim("PhoenixFrog")
	data.frogs.Phoenix = true
	data.equippedFrog = "Phoenix"
	return true
end

-- Robux eggs: hatch one and show the reveal on the recipient's screen.
for _, egg in Pets.Eggs do
	if egg.product then
		Handlers[egg.product] = function(player, data)
			local results = PetService.grantHatch(player, data, egg, 1)
			task.defer(function()
				PetService.refreshModels(player)
				Net.event("Notify"):FireClient(player, { kind = "Hatch", egg = egg.id, results = results })
			end)
			return true
		end
	end
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
