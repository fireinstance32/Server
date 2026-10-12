-- Reacts to server notifications (level ups, etc.) with banners and sounds.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Sounds = require(Shared.Config.Sounds)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)

local NotifyController = {}

-- Plays a named sound from Config/Sounds. Silently does nothing until an
-- asset id is filled in, so code can call sounds before audio exists.
function NotifyController.playSound(name: string)
	local id = Sounds[name]
	if not id or id == "" then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.6
	SoundService:PlayLocalSound(sound)
	task.delay(5, function()
		sound:Destroy()
	end)
end

function NotifyController.init()
	Net.event("Notify").OnClientEvent:Connect(function(payload)
		if typeof(payload) ~= "table" then
			return
		end
		if payload.kind == "Dev" then
			for _, line in string.split(payload.text, "\n") do
				Hud.toast(line, Theme.Colors.Ink)
			end
		elseif payload.kind == "LevelUp" then
			NotifyController.playSound("LevelUp")
			if payload.maxed then
				Hud.banner(`LEVEL {payload.level}!`, "MAX LEVEL – time to Rebirth!", Theme.Colors.Gold)
			else
				-- A toast, not a banner: level ups often land with the zone banner.
				Hud.toast(`LEVEL {payload.level}!  +Hops boost`, Theme.Colors.Blue)
			end
		end
	end)
end

return NotifyController
