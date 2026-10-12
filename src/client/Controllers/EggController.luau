-- Egg hatching from the client side (reference E / R / T keys near an egg):
--   E  hatch one (the egg's ProximityPrompt)
--   R  multi-hatch: 3 or 8 with the +3 / +8 Eggs passes (else offers the pass)
--   T  toggle auto-hatch (free) while standing at an egg
-- Robux eggs prompt the product; their reveal arrives via Notify "Hatch".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local HatchScreen = require(script.Parent.Parent.UI.HatchScreen)
local Purchases = require(script.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.State)

local EggController = {}

local NEAR_DISTANCE = 12
local busy = false
local autoEgg: string? = nil

local function nearestEgg(): Pets.Egg?
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return nil
	end
	for _, egg in Pets.Eggs do
		local flat = Vector3.new(root.Position.X - egg.position.X, 0, root.Position.Z - egg.position.Z)
		if flat.Magnitude <= NEAR_DISTANCE then
			return egg
		end
	end
	return nil
end

local function multiCount(): number
	local best = 1
	for _, option in Pets.MultiHatch do
		if Purchases.owns(option.pass) and option.count > best then
			best = option.count
		end
	end
	return best
end

function EggController.hatch(eggId: string, count: number, auto: boolean?): boolean
	local egg = Pets.EggsById[eggId]
	if busy or not egg then
		return false
	end
	if egg.product then
		Purchases.product(egg.product)
		return false
	end
	busy = true
	local called, ok, result = pcall(function()
		return Net.func("HatchEgg"):InvokeServer(eggId, count)
	end)
	if called and ok then
		HatchScreen.play(eggId, result, auto)
	elseif called then
		Hud.toast(result, Theme.Colors.Red)
	else
		warn("[EggController]", ok)
	end
	busy = false
	return called and ok == true
end

local function multiHatch()
	local egg = nearestEgg()
	if not egg then
		return
	end
	local count = multiCount()
	if count == 1 then
		Purchases.pass(Pets.MultiHatch[1].pass)
		return
	end
	task.spawn(EggController.hatch, egg.id, count)
end

local function toggleAuto()
	if autoEgg then
		autoEgg = nil
		Hud.toast("Auto hatch OFF", Theme.Colors.Ink)
		return
	end
	local egg = nearestEgg()
	if not egg or egg.product then
		return
	end
	autoEgg = egg.id
	Hud.toast(`Auto hatch ON: {egg.name} (T to stop)`, Theme.Colors.DarkGreen)
	task.spawn(function()
		while autoEgg == egg.id do
			local here = nearestEgg()
			local data = State.data
			if not here or here.id ~= egg.id or not data or data.wins < egg.price then
				autoEgg = nil
				Hud.toast("Auto hatch stopped", Theme.Colors.Ink)
				break
			end
			local count = math.min(multiCount(), math.floor(data.wins / math.max(egg.price, 1)))
			count = if count >= 8 then 8 elseif count >= 3 then 3 else 1
			if not EggController.hatch(egg.id, count, true) then
				autoEgg = nil
				break
			end
			task.wait(0.2)
		end
	end)
end

function EggController.init()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.R then
			multiHatch()
		elseif input.KeyCode == Enum.KeyCode.T then
			toggleAuto()
		end
	end)
	Net.event("Notify").OnClientEvent:Connect(function(payload)
		if typeof(payload) == "table" and payload.kind == "Hatch" then
			HatchScreen.play(payload.egg, payload.results, false)
		end
	end)
end

return EggController
