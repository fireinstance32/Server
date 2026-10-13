-- One portal per other world in each lobby, in a row by the -Z wall facing
-- in (Config/Lobby). Each has a
-- ProximityPrompt with a "TravelTo" attribute; the client asks the server to
-- travel (WorldService checks and unlocks the gate). Its sign is drawn per
-- player by Controllers/PortalSigns.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Worlds = require(Shared.Config.Worlds)
local Lobby = require(Shared.Config.Lobby)

local Parts = require(script.Parent.Parts)

local Portals = {}

local POST_X = 5 -- posts at ±POST_X
local HEIGHT = 14

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
	return Lobby.portal(slot)
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
				Parts.block("Post", Vector3.new(2, HEIGHT, 2), CFrame.new(base + Vector3.new(-POST_X, HEIGHT / 2, 0)), Parts.Colors.Wood, frame),
				Parts.block("Post", Vector3.new(2, HEIGHT, 2), CFrame.new(base + Vector3.new(POST_X, HEIGHT / 2, 0)), Parts.Colors.Wood, frame),
				Parts.block("Top", Vector3.new(POST_X * 2 + 2, 2, 2), CFrame.new(base + Vector3.new(0, HEIGHT + 1, 0)), Parts.Colors.Wood, frame),
			}
			-- The stone arch (glowing rune in the target world's colour) once
			-- imported; the wooden posts stay as its invisible collision.
			if Parts.prop("PortalArch", target.color, POST_X * 2 + 2, CFrame.new(base), frame) then
				for _, post in posts do
					post.Transparency = 1
				end
			end
			local gate = Parts.block(
				"Gate",
				Vector3.new(POST_X * 2 - 2, HEIGHT - 2, 1),
				CFrame.new(base + Vector3.new(0, HEIGHT / 2, 0)),
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
