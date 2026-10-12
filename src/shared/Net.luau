--!strict
-- Single source of truth for remotes. The server creates them; the client waits.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FUNCTIONS = {
	"Hop", -- (mode: "Train" | "Launch") -> result
	"BuyFrog", -- (frogId) -> ok, message
	"EquipFrog", -- (frogId) -> ok, message
	"HatchEgg", -- (eggId) -> ok, petId | message
	"EquipPet", -- (uid) -> ok, message
	"UnequipPet", -- (uid) -> ok, message
	"Rebirth", -- () -> ok, message
	"RedeemCode", -- (code) -> ok, message
}

local EVENTS = {
	"DataChanged", -- server -> client: full profile snapshot
	"Notify", -- server -> client: (text)
}

local Net = {}

local folder: Folder
if RunService:IsServer() then
	local existing = ReplicatedStorage:FindFirstChild("Remotes")
	if existing then
		existing:Destroy()
	end
	folder = Instance.new("Folder")
	folder.Name = "Remotes"
	for _, name in FUNCTIONS do
		local remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = folder
	end
	for _, name in EVENTS do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
else
	folder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
end

function Net.func(name: string): RemoteFunction
	return folder:WaitForChild(name) :: RemoteFunction
end

function Net.event(name: string): RemoteEvent
	return folder:WaitForChild(name) :: RemoteEvent
end

return Net
