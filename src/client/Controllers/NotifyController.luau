-- Reacts to server notifications (level ups, etc.) with banners and sounds.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local Sfx = require(script.Parent.Parent.Sfx)
local WorldFx = require(script.Parent.Parent.Effects.World)
local ScreenFx = require(script.Parent.Parent.Effects.Screen)

local NotifyController = {}

NotifyController.playSound = Sfx.play

function NotifyController.init()
	Net.event("Notify").OnClientEvent:Connect(function(payload)
		if typeof(payload) ~= "table" then
			return
		end
		if payload.kind == "Dev" then
			for _, line in string.split(payload.text, "\n") do
				Hud.toast(line, Theme.Colors.Ink)
			end
		elseif payload.kind == "Gift" then
			Hud.banner("🎁 You got a gift!", `{payload.from} sent you {payload.item}`, Theme.Colors.Gold)
		elseif payload.kind == "GiftSent" then
			Hud.toast(`🎁 Gift sent: {payload.item}`, Theme.Colors.DarkGreen)
		elseif payload.kind == "Quest" then
			NotifyController.playSound("Purchase")
			Hud.toast(`✅ Quest complete: {payload.text}  (+{payload.reward})`, Theme.Colors.DarkGreen)
		elseif payload.kind == "Offline" then
			local hours = payload.seconds // 3600
			local minutes = (payload.seconds % 3600) // 60
			local away = if hours > 0 then `{hours}h {minutes}m` else `{minutes}m`
			task.delay(1, function()
				Hud.banner("Welcome back! 🐸", `You trained offline for {away}: +{Format.abbreviate(payload.hops)} Hops`, Theme.Colors.Gold)
			end)
		elseif payload.kind == "LevelUp" then
			NotifyController.playSound("LevelUp")
			WorldFx.sparkleAround(game:GetService("Players").LocalPlayer.Character)
			if payload.maxed then
				Hud.banner(`LEVEL {payload.level}!`, "MAX LEVEL – time to Rebirth!", Theme.Colors.Gold)
				ScreenFx.confetti(50)
			else
				-- A toast, not a banner: level ups often land with the zone banner.
				Hud.toast(`LEVEL {payload.level}!  +Hops boost`, Theme.Colors.Blue)
			end
		end
	end)
end

return NotifyController
