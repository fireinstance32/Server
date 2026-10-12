-- Potion inventory and timers. Counts live in data.potions, expiry times
-- (os.time) in data.activePotions; Stats reads them. A light loop tells the
-- client when a potion runs out so the multiplier display updates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Potions = require(Shared.Config.Potions)

local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Parent.Remotes)

local PotionService = {}

-- Adds potions to the inventory (rewards, codes, products). No replication.
function PotionService.give(data: any, potionId: string, amount: number)
	if Potions.ById[potionId] then
		data.potions[potionId] = (data.potions[potionId] or 0) + amount
	end
end

local function use(player: Player, potionId: unknown): (boolean, string)
	local data = DataService.get(player)
	local potion = typeof(potionId) == "string" and Potions.ById[potionId]
	if not data or not potion then
		return false, "Invalid potion"
	end
	if (data.potions[potion.id] or 0) <= 0 then
		return false, `You have no {potion.name}`
	end
	data.potions[potion.id] -= 1
	data.activePotions[potion.id] = Potions.extend(data.activePotions[potion.id], os.time(), potion.duration)
	DataService.changed(player)
	return true, `{potion.name} active! x{potion.factor}`
end

function PotionService.start()
	Remotes.handle("UsePotion", use)

	-- Clear expired potions so the client's multiplier drops when they end.
	task.spawn(function()
		while true do
			task.wait(5)
			local now = os.time()
			for _, player in Players:GetPlayers() do
				local data = DataService.get(player)
				if data then
					local expired = false
					for id, expiry in data.activePotions do
						if expiry <= now then
							data.activePotions[id] = nil
							expired = true
						end
					end
					if expired then
						DataService.changed(player)
					end
				end
			end
		end
	end)
end

return PotionService
