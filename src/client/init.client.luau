-- Client entry point for +1 Frog Hop.

local UI = script.UI
local Controllers = script.Controllers

local Hud = require(UI.Hud)
local Menus = require(UI.Menus)
local Sfx = require(script.Sfx)
local HopController = require(Controllers.HopController)
local PetFollowController = require(Controllers.PetFollowController)
local PromptController = require(Controllers.PromptController)
local NotifyController = require(Controllers.NotifyController)
local PondSigns = require(Controllers.PondSigns)
local PortalSigns = require(Controllers.PortalSigns)
local FrogPodiums = require(Controllers.FrogPodiums)
local EggController = require(Controllers.EggController)
local EggSigns = require(Controllers.EggSigns)
local QuestGuide = require(Controllers.QuestGuide)
local WorldLighting = require(Controllers.WorldLighting)
local RockAura = require(script.Effects.RockAura)

Hud.init({
	onHop = HopController.press,
	openMenu = Menus.open,
	autoOpenMenu = function(name)
		if not Menus.isOpen() then
			Menus.show(name)
		end
	end,
	setAutoHop = HopController.setAutoHop,
})
Menus.init()
HopController.init()
PromptController.init()
NotifyController.init()
task.spawn(PondSigns.init)
task.spawn(PortalSigns.init)
task.spawn(FrogPodiums.init)
EggController.init()
task.spawn(EggSigns.init)
QuestGuide.init()
WorldLighting.init()
RockAura.init()
task.spawn(PetFollowController.init)
Sfx.startMusic()
