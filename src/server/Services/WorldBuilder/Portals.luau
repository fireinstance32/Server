-- One portal per other world in each hub, near spawn. Each has a
-- ProximityPrompt with a "TravelTo" attribute; the client asks the server to
-- travel (WorldService checks and unlocks the gate). Its sign is drawn per
-- player by Controllers/PortalSigns.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)

local Parts = require(script.Parent.Parts)

local Portals = {}

local ROW_X = -150
local ROW_Z = 30
local SPACING = 26

-- Local position of the portal to `target` inside `config`'s hub.
function Portals.position(config: Worlds.World, target: Worlds.World): Vector3
	local slot = 0
	for _, world in Worlds.List do
		if world ~= config then
			slot += 1
			if world == target then
				break
			end
		end
	end
	return Vector3.new(ROW_X - (slot - 1) * SPACING, Parts.GroundTop, ROW_Z)
end

function Portals.build(world: Model, config: Worlds.World)
	local folder = Instance.new("Folder")
	folder.Name = "Portals"
	for _, target in Worlds.List do
		if target ~= config then
			local base = Portals.position(config, target)
			local frame = Instance.new("Model")
			frame.Name = target.id
			local posts = {
				Parts.block("Post", Vector3.new(3, 18, 3), CFrame.new(base + Vector3.new(-8, 9, 0)), Parts.Colors.Wood, frame),
				Parts.block("Post", Vector3.new(3, 18, 3), CFrame.new(base + Vector3.new(8, 9, 0)), Parts.Colors.Wood, frame),
				Parts.block("Top", Vector3.new(19, 3, 3), CFrame.new(base + Vector3.new(0, 19.5, 0)), Parts.Colors.Wood, frame),
			}
			-- The stone arch (glowing rune in the target world's colour) once
			-- imported; the wooden posts stay as its invisible collision.
			if Parts.prop("PortalArch", target.color, 21, CFrame.new(base), frame) then
				for _, post in posts do
					post.Transparency = 1
				end
			end
			local gate = Parts.block(
				"Gate",
				Vector3.new(13, 16, 1),
				CFrame.new(base + Vector3.new(0, 9, 0)),
				target.color,
				frame,
				Enum.Material.Neon
			)
			gate.Transparency = 0.25
			gate.CanCollide = false
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Travel"
			prompt.ObjectText = target.name
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = 12
			prompt.RequiresLineOfSight = false
			prompt:SetAttribute("TravelTo", target.id)
			prompt.Parent = gate
			frame.Parent = folder
		end
	end
	folder.Parent = world
end

return Portals
