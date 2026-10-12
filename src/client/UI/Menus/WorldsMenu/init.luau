-- Worlds (reference): a wide card per world with a picture of it, its name,
-- what it needs to unlock, and a studded status button: YOU ARE HERE,
-- TELEPORT, UNLOCK (enough Hops) or LOCKED.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)
local Signature = require(Shared.Util.Signature)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Icon = require(script.Parent.Parent.Components.Icon)
local Window = require(script.Parent.Window)
local Scene = require(script.Scene)

local new = Theme.new

local WorldsMenu = {}

local function currentWorld(): string?
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return nil
	end
	local world = Worlds.toLocal(root.Position)
	return world and world.id
end

local function key(data): string
	local affordable = {}
	for _, world in Worlds.List do
		affordable[world.id] = data.hops >= world.gateHops
	end
	return Signature.of(data.worldsUnlocked, affordable, currentWorld())
end

local function card(list: Instance, world: Worlds.World, data: any, here: boolean)
	local unlocked = Worlds.isUnlocked(world, data.worldsUnlocked)
	local frame = new("Frame", {
		Name = world.id,
		Size = UDim2.new(1, -8, 0, 230),
		BackgroundColor3 = Color3.new(0, 0, 0),
		LayoutOrder = world.index,
		Parent = list,
	}, {
		Theme.corner(12),
		Theme.stroke(if here then 5 else 4, if here then Color3.fromRGB(110, 200, 255) else Color3.fromRGB(12, 12, 16)),
	})
	local scene = Scene.build(frame, world)
	if not unlocked then
		-- Dim locked worlds so the bright ones read as "open".
		new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.45,
			ZIndex = 2,
			Parent = scene,
		})
	end
	local name = Theme.label({
		Size = UDim2.new(0.6, 0, 0, 58),
		Position = UDim2.fromOffset(22, 14),
		Text = `World {world.index}`,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
		Parent = frame,
	})
	name:FindFirstChildOfClass("UIStroke").Thickness = 4
	Theme.label({
		Size = UDim2.new(0.6, 0, 0, 30),
		Position = UDim2.fromOffset(24, 70),
		Text = world.name,
		ZIndex = 4,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	if not unlocked then
		local need = new("Frame", {
			Size = UDim2.new(0.5, 0, 0, 36),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 22, 1, -18),
			BackgroundTransparency = 1,
			ZIndex = 4,
			Parent = frame,
		})
		local text = Theme.label({
			Size = UDim2.new(1, -42, 1, 0),
			Position = UDim2.fromOffset(42, 0),
			Text = `NEEDS {Format.abbreviate(world.gateHops)} HOPS`,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4,
			Parent = need,
		})
		text:FindFirstChildOfClass("UIStroke").Thickness = 3
		Icon.new("bolt", { Size = UDim2.fromOffset(36, 36), ZIndex = 4, Parent = need })
	end

	local text, color
	if here then
		text, color = "YOU ARE HERE", "Blue"
	elseif unlocked then
		text, color = "TELEPORT", "Green"
	elseif data.hops >= world.gateHops then
		text, color = "UNLOCK", "Yellow"
	else
		text, color = "LOCKED", "Red"
	end
	local button = Window.button({
		Size = UDim2.fromOffset(260, 62),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -22, 1, -18),
		Text = text,
		ZIndex = 4,
	}, color, function()
		if here then
			return
		end
		Window.report(Net.func("TravelWorld"):InvokeServer(world.id))
	end)
	button.Parent = frame
	if not unlocked then
		Icon.new("lock", {
			Size = UDim2.fromOffset(56, 56),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -24, 0, 20),
			Rotation = 12,
			ZIndex = 5,
			Parent = frame,
		})
	end
end

function WorldsMenu.build(body: Frame)
	local list = Window.list(body, 16)
	return Signature.guard(key, function(data)
		Window.clear(list)
		local here = currentWorld() or "Lily"
		for _, world in Worlds.List do
			card(list, world, data, world.id == here)
		end
	end)
end

return WorldsMenu
