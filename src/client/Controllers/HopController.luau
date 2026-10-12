-- Drives the HOP button: picks Train/Launch from where the player stands,
-- asks the server for a result, then hands it to HopAnimation. Runs Auto Hop.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)

local Hud = require(script.Parent.Parent.UI.Hud)
local Theme = require(script.Parent.Parent.UI.Theme)
local HopAnimation = require(script.Parent.HopAnimation)

local HopController = {}

local player = Players.LocalPlayer
local busy = false

local function rootPart(): BasePart?
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function flatDistance(a: Vector3, b: Vector3): number
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function currentMode(): string?
	local root = rootPart()
	if not root then
		return nil
	end
	if flatDistance(root.Position, Game.LaunchDock) <= Game.UseRadius then
		return "Launch"
	elseif flatDistance(root.Position, Game.TrainingPond) <= Game.UseRadius then
		return "Train"
	end
	return nil
end

function HopController.hop()
	if busy then
		return
	end
	local mode = currentMode()
	if not mode then
		Hud.toast("Walk to the Training Pond or the River Dock!", Theme.Colors.Red)
		return
	end
	busy = true
	-- pcall so a server error or animation error can never leave the button stuck.
	local ok, err = pcall(function()
		local result = Net.func("Hop"):InvokeServer(mode)
		if result and result.ok then
			if result.mode == "Train" then
				HopAnimation.playTraining(result)
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

-- Auto Hop pass: keep hopping while standing at a hop spot.
local autoHop = false
function HopController.setAutoHop(enabled: boolean)
	autoHop = enabled
end

function HopController.init()
	-- Show/hide the HOP button as the player walks between hop spots.
	local lastMode: string? = "unset"
	RunService.Heartbeat:Connect(function()
		local mode = currentMode()
		if mode ~= lastMode then
			lastMode = mode
			Hud.setHopMode(mode)
		end
		if autoHop and mode and not busy then
			task.spawn(HopController.hop)
		end
	end)
end

return HopController
