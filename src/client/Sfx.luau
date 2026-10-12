-- Plays named UI / game sounds from Config/Sounds. Silently does nothing
-- until an asset id is filled in, so code can call sounds before audio
-- exists (Phase 6.4).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Sounds = require(ReplicatedStorage:WaitForChild("Shared").Config.Sounds)

local Sfx = {}

function Sfx.play(name: string, volume: number?)
	local id = Sounds[name]
	if not id or id == "" then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.6
	SoundService:PlayLocalSound(sound)
	task.delay(5, function()
		sound:Destroy()
	end)
end

return Sfx
