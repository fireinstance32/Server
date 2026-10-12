-- The always-on HUD with a mid-game player.
local Hud = require("@client/UI/Hud")
local sample = require("@preview/sample")
Hud.init({
	onHop = function() end,
	openMenu = function() end,
	setAutoHop = function() end,
})
Hud.setHopMode("Launch")
SEND_DATA(sample())
