-- Handles world ProximityPrompts built by WorldBuilder (egg stands, frog shop).

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Menus = require(script.Parent.Parent.UI.Menus)
local Theme = require(script.Parent.Parent.UI.Theme)

local PromptController = {}

local hatching = false

local function hatch(eggId: string)
	if hatching then
		return
	end
	hatching = true
	local called, ok, result = pcall(function()
		return Net.func("HatchEgg"):InvokeServer(eggId)
	end)
	if not called then
		warn("[PromptController]", ok)
	elseif ok then
		local def = Pets.ById[result]
		Hud.banner(
			`You hatched a {def.name}!`,
			`{def.rarity}  •  {Format.multiplier(def.multiplier)} Hops`,
			Pets.RarityColors[def.rarity]
		)
	else
		Hud.toast(result, Theme.Colors.Red)
	end
	hatching = false
end

function PromptController.init()
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		local eggId = prompt:GetAttribute("EggId")
		local menu = prompt:GetAttribute("OpenMenu")
		if typeof(eggId) == "string" then
			hatch(eggId)
		elseif typeof(menu) == "string" then
			Menus.open(menu)
		end
	end)
end

return PromptController
