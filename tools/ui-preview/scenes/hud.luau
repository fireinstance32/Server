-- The always-on HUD with a mid-game player.
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample()) -- before init, so loops see data on their first pass
local Hud = require("@client/UI/Hud")
Hud.init({
	onHop = function() end,
	openMenu = function() end,
	setAutoHop = function() end,
})
Hud.setHopMode("Launch")
local _ = State
