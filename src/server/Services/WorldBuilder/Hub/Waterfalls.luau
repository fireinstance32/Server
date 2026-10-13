-- Two waterfalls down the lobby's back wall (reference: a waterfall between
-- the leaderboards): a stream over each tier and a small pool on the floor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lobby = require(ReplicatedStorage:WaitForChild("Shared").Config.Lobby)

local Parts = require(script.Parent.Parent.Parts)
local Style = require(script.Parent.Parent.Style)
local Terraces = require(script.Parent.Parent.Terraces)

local Waterfalls = {}

local WIDTH = 6
local WATER = Color3.fromRGB(120, 210, 245)
local FOAM = Color3.fromRGB(235, 250, 255)
local STONE = Color3.fromRGB(170, 165, 185)

local function water(name: string, size: Vector3, cframe: CFrame, parent: Instance)
	local part = Parts.block(name, size, cframe, WATER, parent, Enum.Material.Glass)
	part.Transparency = 0.25
	Style.quiet(part)
end

function Waterfalls.build(map: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Waterfalls"
	local t1, t2 = Terraces.Tiers[1], Terraces.Tiers[2]
	local face1 = Lobby.BackX -- first tier's face
	local face2 = Lobby.BackX - t1.depth -- second tier's face
	for _, z in Lobby.Waterfalls do
		local model = Instance.new("Model")
		model.Name = "Waterfall"
		-- Stream on top of the second tier, the fall down its face, across
		-- the ledge, and down the first tier's face.
		water("Stream", Vector3.new(12, 0.3, WIDTH), CFrame.new(face2 - 6, t2.top + 0.1, z), model)
		water("Fall", Vector3.new(0.6, t2.top - t1.top + 0.2, WIDTH), CFrame.new(face2 + 0.3, (t1.top + t2.top) / 2, z), model)
		water("Ledge", Vector3.new(t1.depth, 0.3, WIDTH), CFrame.new((face1 + face2) / 2, t1.top + 0.1, z), model)
		water("Fall", Vector3.new(0.6, t1.top - Lobby.FloorY, WIDTH), CFrame.new(face1 + 0.3, (Lobby.FloorY + t1.top) / 2, z), model)
		-- Pool at the foot with a stone rim and foam where it lands.
		local rim = Parts.block("PoolRim", Vector3.new(7, 1, WIDTH + 2), CFrame.new(face1 + 3.5, Lobby.FloorY + 0.5, z), STONE, model)
		rim.CanCollide = false
		water("Pool", Vector3.new(6, 0.2, WIDTH), CFrame.new(face1 + 3, Lobby.FloorY + 1.05, z), model)
		local foam = Parts.block("Foam", Vector3.new(1.4, 0.5, WIDTH), CFrame.new(face1 + 0.9, Lobby.FloorY + 1.1, z), FOAM, model, Enum.Material.Neon)
		foam.Transparency = 0.3
		Style.quiet(foam)
		model.Parent = folder
	end
	folder.Parent = map
end

return Waterfalls
