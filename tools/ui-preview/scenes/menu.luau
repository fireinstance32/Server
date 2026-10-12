-- One menu open over the HUD: node run.mjs menu:Shop (Rebirth, Pets, Inventory, Trails, Daily, Gifts, Frogs).
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Hud = require("@client/UI/Hud")
local Menus = require("@client/UI/Menus")
Hud.init({ onHop = function() end, openMenu = Menus.open, setAutoHop = function() end })
Menus.init()
Menus.open(SCENE_ARG ~= "" and SCENE_ARG or "Shop")
local _ = State
