-- A sign over every world portal, drawn for this player: "WORLD 2", the
-- world's name, and OPEN / UNLOCK (enough Hops) / ⚡ 1M HOPS + padlock.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.UI.Theme)
local Icon = require(script.Parent.Parent.UI.Components.Icon)
local State = require(script.Parent.Parent.State)

local new = Theme.new

local PortalSigns = {}

local function buildSign(gate: BasePart, target: Worlds.World, container: Instance): (any) -> ()
	local gui = new("BillboardGui", {
		Name = target.id .. "PortalSign",
		Adornee = gate,
		Size = UDim2.fromOffset(300, 150),
		StudsOffset = Vector3.new(0, 12, 0),
		MaxDistance = 200,
		LightInfluence = 0,
		Parent = container,
	})
	local world = Theme.label({ Size = UDim2.new(1, 0, 0, 52), Text = `WORLD {target.index}`, Parent = gui })
	world:FindFirstChildOfClass("UIStroke").Thickness = 4
	local name = Theme.label({
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.fromOffset(0, 50),
		Text = target.name,
		TextColor3 = target.color:Lerp(Color3.new(1, 1, 1), 0.35),
		Parent = gui,
	})
	Theme.textStroke(3).Parent = name
	-- Status pill: dark, with an icon on the left.
	local pill = new("Frame", {
		Size = UDim2.new(0.86, 0, 0, 50),
		Position = UDim2.new(0.07, 0, 0, 92),
		BackgroundColor3 = Color3.fromRGB(30, 31, 38),
		BackgroundTransparency = 0.1,
		Parent = gui,
	}, { Theme.corner(25), Theme.stroke(3) })
	local iconHolder = new("Frame", {
		Size = UDim2.fromOffset(56, 56),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = pill,
	})
	local status = Theme.label({
		Size = UDim2.new(1, -56, 0.78, 0),
		Position = UDim2.new(0, 48, 0.11, 0),
		Text = "",
		Parent = pill,
	})
	Theme.textStroke(3).Parent = status

	local shown = ""
	return function(data)
		local unlocked = Worlds.isUnlocked(target, data.worldsUnlocked)
		local ready = not unlocked and data.hops >= target.gateHops
		local state = if unlocked then "open" elseif ready then "ready" else "locked"
		if state == shown then
			return
		end
		shown = state
		for _, child in iconHolder:GetChildren() do
			child:Destroy()
		end
		Icon.new(if unlocked then "portal" elseif ready then "star" else "lock", { Size = UDim2.fromScale(1, 1), Parent = iconHolder })
		status.Text = if unlocked then "OPEN" elseif ready then "UNLOCK!" else `{Format.abbreviate(target.gateHops)} HOPS`
		status.TextColor3 = if unlocked then Color3.fromRGB(110, 245, 110) elseif ready then Color3.fromRGB(255, 220, 70) else Color3.fromRGB(255, 92, 92)
	end
end

PortalSigns.buildSign = buildSign -- (UI preview)

function PortalSigns.init()
	local root = Workspace:WaitForChild("World")
	local container = new("Folder", { Name = "PortalSigns", Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local refreshers = {}
	for _, hub in Worlds.List do
		local portals = root:WaitForChild(hub.id):WaitForChild("Portals")
		for _, target in Worlds.List do
			if target ~= hub then
				local gate = portals:WaitForChild(target.id):WaitForChild("Gate") :: BasePart
				table.insert(refreshers, buildSign(gate, target, container))
			end
		end
	end
	State.observe(function(data)
		for _, refresh in refreshers do
			refresh(data)
		end
	end)
end

return PortalSigns
