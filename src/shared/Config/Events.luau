-- Seasonal events. While one is active, river hops also earn its currency
-- (Stats.eventCurrency) and its egg stand opens in Lily Valley. Currency
-- resets when the next event starts; pets hatched from event eggs are kept.
-- Times are UTC Unix seconds. Studio: `/event <id|none|auto>`.

export type Event = {
	id: string,
	name: string,
	icon: string,
	currency: string,
	color: Color3,
	startsAt: number,
	endsAt: number,
	pets: { any }, -- Config/Pets entries, added to Pets.List
	egg: any, -- Config/Pets egg (price is in event currency)
}

local rgb = Color3.fromRGB

local Events = {}

Events.List = {
	{
		id = "Halloween2026",
		name = "Halloween",
		icon = "🎃",
		currency = "Candy Corn",
		color = rgb(255, 140, 30),
		startsAt = 1792800000, -- 2026-10-24 00:00 UTC
		endsAt = 1793664000, -- 2026-11-03 00:00 UTC
		pets = {
			{ id = "CandyBat", name = "Candy Bat", rarity = "Uncommon", bonus = 20, color = rgb(80, 60, 90) },
			{ id = "PumpkinCat", name = "Pumpkin Cat", rarity = "Rare", bonus = 50, color = rgb(255, 140, 30) },
			{ id = "GhostFrog", name = "Ghost Frog", rarity = "Epic", bonus = 150, color = rgb(235, 240, 255) },
			{ id = "SpookyDragon", name = "Spooky Dragon", rarity = "Legendary", bonus = 500, color = rgb(120, 40, 160) },
		},
		egg = {
			id = "Pumpkin",
			name = "Pumpkin Egg",
			price = 25, -- Candy Corn
			color = rgb(255, 130, 20),
			position = Vector3.new(-95, 0, -50),
			pets = {
				{ pet = "CandyBat", weight = 55 },
				{ pet = "PumpkinCat", weight = 30 },
				{ pet = "GhostFrog", weight = 13 },
				{ pet = "SpookyDragon", weight = 2 },
			},
		},
	},
} :: { Event }

Events.ById = {} :: { [string]: Event }
for _, event in Events.List do
	Events.ById[event.id] = event
	event.egg.event = event.id
end

-- Event currency per river hop = zone number reached x this (Stats.eventCurrency).
Events.CurrencyPerZone = 1

-- ReplicatedStorage attribute set by `/event` in Studio: an event id, "none", or nil.
Events.OverrideAttribute = "EventOverride"

-- The running event at `now`, honouring the Studio override.
function Events.active(now: number, override: string?): Event?
	if override == "none" then
		return nil
	elseif override and Events.ById[override] then
		return Events.ById[override]
	end
	for _, event in Events.List do
		if now >= event.startsAt and now < event.endsAt then
			return event
		end
	end
	return nil
end

-- "3d 4h", "5h 12m", "8m" until the event ends (overrides run "forever").
function Events.timeLeftText(event: Event, now: number): string
	local left = math.max(event.endsAt - now, 0)
	local days, hours, minutes = left // 86400, (left % 86400) // 3600, (left % 3600) // 60
	if days > 0 then
		return `{days}d {hours}h`
	elseif hours > 0 then
		return `{hours}h {minutes}m`
	end
	return `{minutes}m`
end

return Events
