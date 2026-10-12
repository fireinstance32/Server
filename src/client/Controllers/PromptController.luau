-- Handles world ProximityPrompts built by WorldBuilder (egg stands, frog podiums).

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Menus = require(script.Parent.Parent.UI.Menus)
local Theme = require(script.Parent.Parent.UI.Theme)
local Purchases = require(script.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.State)
local EggController = require(script.Parent.EggController)

local PromptController = {}

-- Frog podium: equip if owned, otherwise buy (Wins, or Robux for robuxOnly).
local function frogPodium(frogId: string)
	local frog = Frogs.ById[frogId]
	local data = State.data
	if not frog or not data then
		return
	end
	local remote
	if data.frogs[frogId] then
		remote = "EquipFrog"
	elseif frog.robuxOnly then
		Purchases.product("PhoenixFrog")
		return
	else
		remote = "BuyFrog"
	end
	local ok, message = Net.func(remote):InvokeServer(frogId)
	Hud.toast(message, if ok then Theme.Colors.DarkGreen else Theme.Colors.Red)
end

function PromptController.init()
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		local eggId = prompt:GetAttribute("EggId")
		local frogId = prompt:GetAttribute("FrogId")
		local menu = prompt:GetAttribute("OpenMenu")
		local travelTo = prompt:GetAttribute("TravelTo")
		if typeof(eggId) == "string" then
			task.spawn(EggController.hatch, eggId, 1)
		elseif typeof(frogId) == "string" then
			frogPodium(frogId)
		elseif typeof(travelTo) == "string" then
			local ok, message = Net.func("TravelWorld"):InvokeServer(travelTo)
			Hud.toast(message, if ok then Theme.Colors.DarkGreen else Theme.Colors.Red)
		elseif typeof(menu) == "string" then
			Menus.open(menu)
		end
	end)
end

return PromptController
