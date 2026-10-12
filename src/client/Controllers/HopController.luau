-- Drives the HOP button: picks Train/Launch from where the player stands,
-- asks the server for a result, then hands it to HopAnimation. Also teleports.

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

function HopController.teleport(destination: string)
	local root = rootPart()
	if not root or busy then
		return
	end
	local target = if destination == "Train"
		then Game.TrainingPond + Vector3.new(0, 4, -Game.TrainingPondRadius + 6)
		else Game.LaunchDock + Vector3.new(0, 4, 0)
	local lookAt = if destination == "Train" then Game.TrainingPond else Game.padPosition(3)
	root.CFrame = CFrame.lookAt(target, Vector3.new(lookAt.X, target.Y, lookAt.Z))
end

function HopController.init()
	-- Keep the HOP button label in sync with where the player is standing.
	local lastMode: string? = "unset"
	RunService.Heartbeat:Connect(function()
		local mode = currentMode()
		if mode == lastMode then
			return
		end
		lastMode = mode
		if mode == "Launch" then
			Hud.setHopButton("LAUNCH! 🐸", Theme.Colors.Blue)
		elseif mode == "Train" then
			Hud.setHopButton("TRAIN 💪", Theme.Colors.Green)
		else
			Hud.setHopButton("HOP!", Theme.Colors.Grey)
		end
	end)
end

return HopController
