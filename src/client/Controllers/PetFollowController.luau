-- Moves every player's pet models (Workspace.Pets.<UserId>) behind their owner.
-- Runs locally on each client, so pets look smooth without server physics.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PetFollowController = {}

local SPACING = 3.2
local BEHIND = 5
local SMOOTHING = 10

function PetFollowController.init()
	local petsFolder = Workspace:WaitForChild("Pets")

	RunService.RenderStepped:Connect(function(dt)
		local t = os.clock()
		local alpha = math.min(dt * SMOOTHING, 1)
		for _, folder in petsFolder:GetChildren() do
			local owner = Players:GetPlayerByUserId(tonumber(folder.Name) or 0)
			local character = owner and owner.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root then
				local models = folder:GetChildren()
				local count = #models
				for _, model in models do
					if model:IsA("Model") and model.PrimaryPart then
						local slot = model:GetAttribute("Slot") or 1
						local side = (slot - (count + 1) / 2) * SPACING
						local bob = math.sin(t * 3 + slot) * 0.4
						local target = root.CFrame * CFrame.new(side, bob - 1, BEHIND)
						model:PivotTo(model:GetPivot():Lerp(target, alpha))
					end
				end
			end
		end
	end)
end

return PetFollowController
