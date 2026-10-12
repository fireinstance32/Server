-- Hatch screen reveal: node run.mjs hatch (3 pets) or hatch:1
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Hud = require("@client/UI/Hud")
Hud.init({ onHop = function() end, openMenu = function() end, setAutoHop = function() end })
local HatchScreen = require("@client/UI/HatchScreen")
WAIT_BUDGET = 2 -- egg stage + wobble pass; parks on the reveal
local results = {
	{ pet = "PebblePup", chance = 40, isNew = true },
	{ pet = "CloverBun", chance = 30 },
	{ pet = "MossTurtle", chance = 10, isNew = true },
}
if SCENE_ARG == "1" then
	results = { results[1] }
end
task.spawn(HatchScreen.play, "Common", results, true)
local _ = State
