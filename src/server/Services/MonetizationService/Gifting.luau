-- Gifting ("[GIFT]" products): the buyer picks a player in the server, the
-- server remembers who it's for, then the buyer purchases the gift product.
-- On receipt the item is granted to the recipient: products run their
-- normal handler, passes are stored as gifted passes in the recipient's
-- data. Offline recipients get it on their next join (pending gifts store).

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared.Config.Monetization)
local Net = require(Shared.Net)

local Passes = require(script.Parent.Parent.Parent.Passes)
local DataService = require(script.Parent.Parent.DataService)
local Handlers = require(script.Parent.Handlers)

local Gifting = {}

local PENDING_TTL = 120 -- seconds a gift target stays remembered
local pending: { [Player]: { target: number, item: string, at: number } } = {}
local pendingStore: DataStore? = nil

-- Applies a gifted item to a loaded recipient. Returns true if granted.
local function applyTo(recipient: Player, data: any, item: string): boolean
	if Monetization.Passes[item] then
		data.giftedPasses[item] = true
		Passes.grant(recipient, item)
		return true
	end
	local handler = Handlers[item]
	return handler ~= nil and handler(recipient, data)
end

-- RequestGift remote: (targetUserId, item) -> ok, message
local function request(buyer: Player, targetUserId: unknown, item: unknown): (boolean, string)
	if typeof(targetUserId) ~= "number" or typeof(item) ~= "string" then
		return false, "Invalid gift"
	end
	local giftId = Monetization.GiftIds[item]
	if not giftId then
		return false, "That item can't be gifted"
	end
	if giftId == 0 then
		return false, "Gift not on sale yet"
	end
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target or target == buyer then
		return false, "Pick another player in this server"
	end
	pending[buyer] = { target = targetUserId, item = item, at = os.clock() }
	return true, "OK"
end

-- Receipt handler for a gift product. Called by MonetizationService.
function Gifting.grantGift(buyer: Player, item: string): boolean
	local entry = pending[buyer]
	if not entry or entry.item ~= item or os.clock() - entry.at > PENDING_TTL then
		return false
	end
	pending[buyer] = nil
	local recipient = Players:GetPlayerByUserId(entry.target)
	local data = recipient and DataService.get(recipient)
	if recipient and data then
		if not applyTo(recipient, data, item) then
			return false
		end
		DataService.changed(recipient)
		Net.event("Notify"):FireClient(recipient, { kind = "Gift", from = buyer.DisplayName, item = item })
	elseif pendingStore then
		local ok = pcall(function()
			(pendingStore :: DataStore):UpdateAsync(tostring(entry.target), function(list)
				list = list or {}
				table.insert(list, item)
				return list
			end)
		end)
		if not ok then
			return false
		end
	else
		return false
	end
	Net.event("Notify"):FireClient(buyer, { kind = "GiftSent", item = item })
	return true
end

local function onLoaded(player: Player, data: any)
	for name in data.giftedPasses do
		Passes.grant(player, name)
	end
	if not pendingStore then
		return
	end
	local ok, list = pcall(function()
		return (pendingStore :: DataStore):GetAsync(tostring(player.UserId))
	end)
	if not ok or not list or #list == 0 then
		return
	end
	for _, item in list do
		applyTo(player, data, item)
		Net.event("Notify"):FireClient(player, { kind = "Gift", from = "a friend", item = item })
	end
	pcall(function()
		(pendingStore :: DataStore):RemoveAsync(tostring(player.UserId))
	end)
	DataService.changed(player)
end

function Gifting.start()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("FrogHop_PendingGifts_v1")
	end)
	pendingStore = if ok then result else nil
	Net.func("RequestGift").OnServerInvoke = request
	DataService.Loaded:Connect(onLoaded)
	Players.PlayerRemoving:Connect(function(player)
		pending[player] = nil
	end)
end

return Gifting
