-- Transient HUD overlays: toasts, landing banner, distance meter, training
-- mode (Auto Rebirth), multiplier breakdown.
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Hud = require("@client/UI/Hud")
Hud.init({ onHop = function() end, openMenu = function() end, setAutoHop = function() end })
Hud.setHopMode("Train", { id = "Lotus" }, false)
Hud.toast("Unlocked Tree Frog!", Color3.fromRGB(40, 120, 40))
Hud.toast("Not enough Wins", Color3.fromRGB(240, 80, 80))
Hud.banner("ZONE 5: Firefly Glade", "350 m  •  +1.2K Wins  •  NEW BEST!", Color3.fromRGB(240, 220, 90))
Hud.distance.show(320)
Hud.distance.set(350, true)
Hud.floatText("+1.5K", Color3.fromRGB(90, 200, 70))
local button = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Multiplier", true)
if button then
	button.Activated:Fire()
end
local _ = State
