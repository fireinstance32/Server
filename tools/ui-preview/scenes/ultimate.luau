-- Ultimate hop cut-in over the HUD.
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Hud = require("@client/UI/Hud")
Hud.init({ onHop = function() end, openMenu = function() end, setAutoHop = function() end })
local Frogs = require("@shared/Config/Frogs")
local CutIn = require("@client/Effects/Ultimate/CutIn")
local id = SCENE_ARG ~= "" and SCENE_ARG or "Phoenix"
CutIn.play(id, Frogs.ById[id].color)
local _ = State
