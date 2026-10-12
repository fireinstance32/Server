-- Game pass ownership cache. Kept dependency-free so Stats and DataService can
-- use it without circular requires.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization = require(ReplicatedStorage:WaitForChild("Shared").Config.Monetization)

local Passes = {}

local owned: { [Player]: { [string]: boolean } } = {}

function Passes.owns(player: Player, passName: string): boolean
	local cache = owned[player]
	if not cache then
		cache = {}
		owned[player] = cache
	end
	if cache[passName] ~= nil then
		return cache[passName]
	end

	local id = Monetization.Passes[passName]
	if not id or id == 0 then
		cache[passName] = false
		return false
	end

	local ok, result = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
	local hasPass = ok and result == true
	-- Only cache successful lookups so a transient failure is retried later.
	if ok then
		cache[passName] = hasPass
	end
	return hasPass
end

-- Called after an in-game purchase so the benefit applies immediately.
function Passes.grant(player: Player, passName: string)
	owned[player] = owned[player] or {}
	owned[player][passName] = true
end

function Passes.nameForId(id: number): string?
	for name, passId in Monetization.Passes do
		if passId == id and passId ~= 0 then
			return name
		end
	end
	return nil
end

Players.PlayerRemoving:Connect(function(player)
	owned[player] = nil
end)

return Passes
