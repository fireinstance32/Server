-- Client entry point for +1 Frog Hop.

local UI = script.UI
local Controllers = script.Controllers

local Hud = require(UI.Hud)
local Menus = require(UI.Menus)
local HopController = require(Controllers.HopController)
local PetFollowController = require(Controllers.PetFollowController)
local PromptController = require(Controllers.PromptController)
local NotifyController = require(Controllers.NotifyController)
local PondSigns = require(Controllers.PondSigns)
local FrogPodiums = require(Controllers.FrogPodiums)
local EggController = require(Controllers.EggController)
local EggSigns = require(Controllers.EggSigns)
local QuestGuide = require(Controllers.QuestGuide)
local WorldLighting = require(Controllers.WorldLighting)

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
task.spawn(PondSigns.init)
task.spawn(FrogPodiums.init)
EggController.init()
task.spawn(EggSigns.init)
QuestGuide.init()
WorldLighting.init()
task.spawn(PetFollowController.init)
