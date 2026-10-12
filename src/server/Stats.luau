-- Derived numbers (multipliers, limits). Pure functions of profile + passes so
-- every service computes rewards the same way.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Frogs = require(Shared.Config.Frogs)
local Pets = require(Shared.Config.Pets)

local Passes = require(script.Parent.Passes)

local Stats = {}

function Stats.petMultiplier(data: any): number
	local total = 1
	for _, pet in data.pets do
		if pet.equipped then
			local def = Pets.ById[pet.id]
			if def then
				total += def.multiplier - 1
			end
		end
	end
	return total
end

function Stats.hopsMultiplier(player: Player, data: any): number
	local rebirth = 1 + data.rebirths * Game.RebirthHopsBonus
	local pass = if Passes.owns(player, "DoubleHops") then 2 else 1
	return rebirth * Stats.petMultiplier(data) * pass
end

function Stats.winsMultiplier(player: Player, _data: any): number
	return if Passes.owns(player, "DoubleWins") then 2 else 1
end

function Stats.perBounce(data: any): number
	local frog = Frogs.ById[data.equippedFrog] or Frogs.ById[Frogs.Default]
	return frog.perBounce
end

function Stats.maxEquippedPets(player: Player): number
	return Game.MaxEquippedPets + (if Passes.owns(player, "ExtraPetSlots") then 2 else 0)
end

return Stats
