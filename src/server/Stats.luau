-- Every boost in the game, in one list. To add a boost (pond, level, potion,
-- friend, trail…), add ONE entry to MODIFIERS. Its numbers belong in
-- Shared.Config; the combining maths lives in Shared.Util.Multipliers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Frogs = require(Shared.Config.Frogs)
local Pets = require(Shared.Config.Pets)
local Levels = require(Shared.Config.Levels)
local Ponds = require(Shared.Config.Ponds)
local Trails = require(Shared.Config.Trails)
local Potions = require(Shared.Config.Potions)
local Multipliers = require(Shared.Util.Multipliers)

local Passes = require(script.Parent.Passes)

export type StatName = "hops" | "wins" | "luck"

-- Optional situation info, e.g. { mode = "Train", pond = "Lotus" } or
-- { mode = "Launch", zone = 3 }. Modifiers that don't care ignore it.
export type Context = { [string]: any }

type Modifier = {
	id: string,
	label: string, -- shown to players in the multiplier breakdown
	stat: StatName,
	kind: Multipliers.Kind,
	-- Return the part's value, or nil when it doesn't apply.
	value: (player: Player, data: any, context: Context) -> number?,
}

local Stats = {}

-- Sum of equipped pets' bonuses (added to the multiplier, e.g. +2).
function Stats.petBonus(data: any): number
	local total = 0
	for _, pet in data.pets do
		if pet.equipped then
			local def = Pets.ById[pet.id]
			if def then
				total += def.bonus
			end
		end
	end
	return total
end

local function passFactor(passName: string, factor: number)
	return function(player: Player): number?
		return if Passes.owns(player, passName) then factor else nil
	end
end

local MODIFIERS: { Modifier } = {
	-- Rebirths and pets ADD to the multiplier (reference: x2 at 1 rebirth,
	-- a "+2" pet takes x7 to x9).
	{
		id = "rebirth",
		label = "Rebirths",
		stat = "hops",
		kind = "add",
		value = function(_, data)
			return data.rebirths * Game.RebirthHopsBonus
		end,
	},
	{
		id = "pets",
		label = "Pets",
		stat = "hops",
		kind = "add",
		value = function(_, data)
			return Stats.petBonus(data)
		end,
	},
	{
		id = "level",
		label = "Level",
		stat = "hops",
		kind = "add",
		value = function(_, data)
			return Levels.hopsBonus(data.level)
		end,
	},
	{
		id = "pond",
		label = "Pond",
		stat = "hops",
		kind = "mult",
		value = function(_, _, context)
			local pond = context.pond and Ponds.ById[context.pond]
			return if pond then pond.multiplier else nil
		end,
	},
	{
		id = "trail",
		label = "Trail",
		stat = "hops",
		kind = "add",
		value = function(_, data)
			local trail = data.equippedTrail and Trails.ById[data.equippedTrail]
			return if trail then trail.bonus else nil
		end,
	},
	{ id = "doubleHops", label = "2x Hops", stat = "hops", kind = "mult", value = passFactor("DoubleHops", 2) },
	{ id = "doubleWins", label = "2x Wins", stat = "wins", kind = "mult", value = passFactor("DoubleWins", 2) },
}

-- One modifier per potion (x2 while its timer is running).
for _, potion in Potions.List do
	table.insert(MODIFIERS, {
		id = "potion" .. potion.id,
		label = potion.name,
		stat = potion.stat,
		kind = "mult",
		value = function(_, data)
			local expiry = data.activePotions and data.activePotions[potion.id]
			return if expiry and expiry > os.time() then potion.factor else nil
		end,
	})
end

function Stats.breakdown(player: Player, data: any, stat: StatName, context: Context?): Multipliers.Breakdown
	local ctx = context or {}
	local parts: { Multipliers.Part } = {}
	for _, modifier in MODIFIERS do
		if modifier.stat == stat then
			local value = modifier.value(player, data, ctx)
			if value ~= nil then
				table.insert(parts, {
					id = modifier.id,
					label = modifier.label,
					kind = modifier.kind,
					value = value,
				})
			end
		end
	end
	return Multipliers.breakdown(parts)
end

function Stats.multiplier(player: Player, data: any, stat: StatName, context: Context?): number
	return Stats.breakdown(player, data, stat, context).total
end

function Stats.hopsMultiplier(player: Player, data: any, context: Context?): number
	return Stats.multiplier(player, data, "hops", context)
end

function Stats.winsMultiplier(player: Player, data: any, context: Context?): number
	return Stats.multiplier(player, data, "wins", context)
end

function Stats.luck(player: Player, data: any, context: Context?): number
	return Stats.multiplier(player, data, "luck", context)
end

-- Everything the client shows about boosts, in one table.
function Stats.snapshot(player: Player, data: any)
	return {
		hops = Stats.breakdown(player, data, "hops"),
		wins = Stats.breakdown(player, data, "wins"),
		luck = Stats.breakdown(player, data, "luck"),
	}
end

function Stats.perBounce(data: any): number
	local frog = Frogs.ById[data.equippedFrog] or Frogs.ById[Frogs.Default]
	return frog.perBounce
end

function Stats.maxPetInventory(player: Player): number
	return Game.MaxPetInventory + (if Passes.owns(player, "PetStorage") then 100 else 0)
end

function Stats.maxEquippedPets(player: Player): number
	return Game.MaxEquippedPets + (if Passes.owns(player, "ExtraPetSlots") then 2 else 0)
end

return Stats
