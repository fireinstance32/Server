-- The picture for a reward { kind, id?, amount? } (daily rewards, gifts,
-- quests, packs): potion bottles, trophy, bolt, or the pet / frog itself.

local Icon = require(script.Parent.Icon)
local PetImage = require(script.Parent.PetImage)

local RewardIcon = {}

local KIND_ICONS = { wins = "trophy", hops = "bolt", trail = "trails", rebirth = "rebirth", egg = "egg" }

function RewardIcon.new(reward: { kind: string, id: string? }, props: { [string]: any }?): GuiObject
	if (reward.kind == "pet" or reward.kind == "frog") and reward.id then
		return PetImage.new(reward.kind, reward.id, props)
	end
	if reward.kind == "potion" and reward.id then
		return Icon.new(`potion_{string.lower(reward.id)}`, props)
	end
	return Icon.new(KIND_ICONS[reward.kind] or "gifts", props)
end

return RewardIcon
