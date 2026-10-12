-- DataStore reads and writes with session locking (Shared.Util.SessionLock):
-- a server claims a profile on load, refreshes the claim on every save and
-- lets go when the player leaves. Another server waits instead of loading a
-- copy, which stops rejoin item duplication.

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Security = require(Shared.Config.Security)
local SessionLock = require(Shared.Util.SessionLock)

local Store = {}

local store: DataStore? = nil
local JOB = if game.JobId ~= "" then game.JobId else "studio"

local function retry<T>(attempts: number, fn: () -> T): (boolean, T | string)
	local lastError = ""
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastError = tostring(result)
		task.wait(attempt)
	end
	return false, lastError
end

local function keyFor(player: Player): string
	return "player_" .. player.UserId
end

function Store.init()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Game.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn(`[DataService] DataStores unavailable ({result}). Progress will not save.`)
		if RunService:IsStudio() then
			warn("[DataService] Enable Game Settings > Security > Enable Studio Access to API Services.")
		end
	end
end

function Store.available(): boolean
	return store ~= nil
end

-- Claims and reads a profile.
-- Returns "ok", profile (nil = new player) | "locked" | "error", message.
function Store.load(player: Player): (string, any)
	if not store then
		return "error", "no DataStore"
	end
	for attempt = 1, Security.SessionWaitAttempts do
		local blocked, profile = false, nil
		local ok, err = retry(3, function()
			return (store :: DataStore):UpdateAsync(keyFor(player), function(record)
				local saved, session = SessionLock.unwrap(record)
				if SessionLock.heldByOther(session, JOB, os.time(), Security.SessionLockSeconds) then
					blocked = true
					return nil -- leave it alone; the other server is still saving
				end
				blocked = false
				profile = saved
				return SessionLock.wrap(saved, { job = JOB, at = os.time() })
			end)
		end)
		if not ok then
			return "error", err
		end
		if not blocked then
			return "ok", profile
		end
		if attempt < Security.SessionWaitAttempts then
			task.wait(Security.SessionWaitSeconds)
		end
	end
	return "locked", nil
end

-- Writes a profile. `release` lets go of the session (player leaving).
function Store.save(player: Player, profile: any, release: boolean)
	if not store then
		return
	end
	local stolen = false
	local ok, err = retry(3, function()
		return (store :: DataStore):UpdateAsync(keyFor(player), function(record)
			local _, session = SessionLock.unwrap(record)
			if not SessionLock.canSave(session, JOB) then
				stolen = true
				return nil
			end
			return SessionLock.wrap(profile, if release then nil else { job = JOB, at = os.time() })
		end)
	end)
	if not ok then
		warn(`[DataService] Failed to save {player.Name}: {err}`)
	elseif stolen then
		warn(`[DataService] {player.Name}'s data is owned by another server; not saving here`)
	end
end

return Store
