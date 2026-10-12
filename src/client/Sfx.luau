-- Plays named UI / game sounds from Config/Sounds, and the background music
-- (muted by the "music" setting). Silently does nothing until an asset id is
-- filled in, so code can call sounds before audio exists (Phase 6.4).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Sounds = require(ReplicatedStorage:WaitForChild("Shared").Config.Sounds)

local Settings = require(script.Parent.Settings)
local State = require(script.Parent.State)

local Sfx = {}

function Sfx.play(name: string, volume: number?)
	local id = Sounds[name]
	if not id or id == "" or not Settings.get("sfx") then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = (volume or 0.6) * Settings.level("sfx")
	SoundService:PlayLocalSound(sound)
	task.delay(5, function()
		sound:Destroy()
	end)
end

-- Music Sounds and their full volume; each follows the "music" slider.
local music: { [Sound]: number } = {}

local function applyMusic()
	local level = Settings.level("music")
	for sound, volume in music do
		sound.Volume = volume * level
	end
end

-- Any music Sound (a future zone track too) registers here so the slider
-- sets its volume.
function Sfx.registerMusic(sound: Sound, volume: number)
	music[sound] = volume
	sound.Destroying:Connect(function()
		music[sound] = nil
	end)
	applyMusic()
end

-- Starts the looping Config/Sounds.Music track (no-op while it's unset).
function Sfx.startMusic()
	local id = Sounds.Music
	if not id or id == "" then
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "Music"
	sound.SoundId = id
	sound.Looped = true
	sound.Parent = SoundService
	Sfx.registerMusic(sound, 0.35)
	sound:Play()
end

State.observe(applyMusic)

-- Re-apply music volume now (a slider being dragged).
Sfx.refreshMusic = applyMusic

return Sfx
