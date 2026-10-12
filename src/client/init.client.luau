-- Client entry point for +1 Frog Hop.

local UI = script.UI
local Controllers = script.Controllers

local Hud = require(UI.Hud)
local Menus = require(UI.Menus)
local HopController = require(Controllers.HopController)
local PetFollowController = require(Controllers.PetFollowController)
local PromptController = require(Controllers.PromptController)
local NotifyController = require(Controllers.NotifyController)

Hud.init({
	onHop = function()
		task.spawn(HopController.hop)
	end,
	openMenu = Menus.open,
	setAutoHop = HopController.setAutoHop,
})
Menus.init()
HopController.init()
PromptController.init()
NotifyController.init()
task.spawn(PetFollowController.init)
