-- Playtime gifts. Session start and claimed gifts are player attributes
-- ("SessionStart", "GiftsClaimed"), so the client can show countdowns
-- without extra remotes. They reset every session by design.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Gifts = require(Shared.Config.Gifts)

local Rewards = require(script.Parent.Parent.Rewards)
local DataService = require(script.Parent.DataService)
local PetService = require(script.Parent.PetService)
local Remotes = require(script.Parent.Parent.Remotes)

local GiftService = {}

local function claim(player: Player, index: unknown): (boolean, string)
	local data = DataService.get(player)
	if not data or typeof(index) ~= "number" then
		return false, "Invalid gift"
	end
	local gift = Gifts.List[index]
	if not gift then
		return false, "Invalid gift"
	end
	local claimed = Gifts.parseClaimed(player:GetAttribute("GiftsClaimed"))
	if claimed[index] then
		return false, "Already claimed"
	end
	local elapsed = os.time() - (player:GetAttribute("SessionStart") or os.time())
	if not Gifts.isReady(index, elapsed) then
		return false, "Not ready yet"
	end
	claimed[index] = true
	local list = {}
	for i in claimed do
		table.insert(list, tostring(i))
	end
	player:SetAttribute("GiftsClaimed", table.concat(list, ","))
	Rewards.grant(data, gift.reward)
	DataService.changed(player)
	PetService.refreshModels(player)
	return true, `Gift: {gift.label}!`
end

function GiftService.start()
	Remotes.handle("ClaimGift", claim)
	local function onPlayer(player: Player)
		player:SetAttribute("SessionStart", os.time())
		player:SetAttribute("GiftsClaimed", "")
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return GiftService
