-- Drives the HOP button: works out where the player stands (a pond's stand
-- pad → Train, the river dock → Launch), asks the server for a result, then
-- hands it to HopAnimation. Also runs auto-train (free) and Auto Hop (pass).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Ponds = require(Shared.Config.Ponds)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local Purchases = require(script.Parent.Parent.Purchases)
local PondAccess = require(script.Parent.Parent.PondAccess)
local HopAnimation = require(script.Parent.HopAnimation)

local HopController = {}

local player = Players.LocalPlayer
local busy = false
local autoTrain = false -- free toggle shown while on a pond pad
local autoHop = false -- Auto Hop pass: repeats river launches

local function rootPart(): BasePart?
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- Returns "Train" (+ pond), "Launch", or nil.
local function currentSpot(): (string?, Ponds.Pond?)
	local root = rootPart()
	if not root then
		return nil, nil
	end
	local pond = Ponds.at(root.Position)
	if pond then
		return "Train", pond
	end
	local dock = Game.LaunchDock
	if Vector3.new(root.Position.X - dock.X, 0, root.Position.Z - dock.Z).Magnitude <= Game.UseRadius then
		return "Launch", nil
	end
	return nil, nil
end

function HopController.hop()
	if busy then
		return
	end
	local mode, pond = currentSpot()
	if not mode then
		Hud.toast("Stand on a pond's pad or the River Dock!", Theme.Colors.Red)
		return
	end
	if pond and not PondAccess.isUnlocked(pond) then
		if pond.pass then
			Purchases.pass(pond.pass)
		else
			Hud.toast(`{pond.name}: {PondAccess.lockReason(pond)}`, Theme.Colors.Red)
		end
		return
	end
	busy = true
	local started = os.clock()
	-- pcall so a server error or animation error can never leave the button stuck.
	local ok, err = pcall(function()
		local result = Net.func("Hop"):InvokeServer(mode)
		if result and result.ok then
			if result.mode == "Train" then
				HopAnimation.playTraining(result)
				-- Wait out the server cooldown so auto-train doesn't spam requests.
				local remaining = started + Game.TrainingCooldown + 0.05 - os.clock()
				if remaining > 0 then
					task.wait(remaining)
				end
			else
				HopAnimation.playLaunch(result)
			end
		elseif result and result.message ~= "busy" then
			Hud.toast(result.message, Theme.Colors.Red)
		end
	end)
	if not ok then
		warn("[HopController]", err)
	end
	busy = false
end

function HopController.setAutoTrain(enabled: boolean)
	autoTrain = enabled
end

function HopController.setAutoHop(enabled: boolean)
	autoHop = enabled
end

function HopController.init()
	local lastMode, lastPond, lastLocked = "unset", nil, nil
	RunService.Heartbeat:Connect(function()
		local mode, pond = currentSpot()
		local locked = pond ~= nil and not PondAccess.isUnlocked(pond)
		if mode ~= lastMode or pond ~= lastPond or locked ~= lastLocked then
			lastMode, lastPond, lastLocked = mode, pond, locked
			Hud.setHopMode(mode, pond, locked)
		end
		if busy then
			return
		end
		local wantsAuto = (mode == "Train" and autoTrain and not locked) or (mode == "Launch" and autoHop)
		if wantsAuto then
			task.spawn(HopController.hop)
		end
	end)
end

return HopController
