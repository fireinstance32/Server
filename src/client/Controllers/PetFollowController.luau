-- Moves every player's pet models (Workspace.Pets.<UserId>) behind their owner.
-- Runs locally on each client, so pets look smooth without server physics.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Settings = require(script.Parent.Parent.Settings)

local PetFollowController = {}

-- Things with an Enabled switch that should go dark with a hidden pet
-- (lights too, or a hidden pet still glows).
local TOGGLED = { "BillboardGui", "ParticleEmitter", "Light", "Trail", "Beam" }

local function isToggled(item: Instance): boolean
	for _, class in TOGGLED do
		if item:IsA(class) then
			return true
		end
	end
	return false
end

-- Shows/hides a pet model for this client only. Switched-off items remember
-- whether they were on ("LocalEnabled") so showing restores them as built.
local function setLocalVisible(model: Model, visible: boolean)
	if (model:GetAttribute("LocalHidden") == true) == not visible then
		return
	end
	model:SetAttribute("LocalHidden", not visible)
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") or item:IsA("Decal") then
			item.LocalTransparencyModifier = if visible then 0 else 1
		elseif isToggled(item) then
			local toggle = item :: any
			if visible then
				local was = item:GetAttribute("LocalEnabled")
				if was ~= nil then
					toggle.Enabled = was
					item:SetAttribute("LocalEnabled", nil)
				end
			else
				item:SetAttribute("LocalEnabled", toggle.Enabled)
				toggle.Enabled = false
			end
		end
	end
end

local SPACING = 3.2
local BEHIND = 5
local SMOOTHING = 10

function PetFollowController.init()
	local petsFolder = Workspace:WaitForChild("Pets")

	RunService.RenderStepped:Connect(function(dt)
		local t = os.clock()
		local alpha = math.min(dt * SMOOTHING, 1)
		local showOthers = Settings.get("otherPets")
		for _, folder in petsFolder:GetChildren() do
			local owner = Players:GetPlayerByUserId(tonumber(folder.Name) or 0)
			local visible = showOthers or owner == Players.LocalPlayer
			for _, model in folder:GetChildren() do
				if model:IsA("Model") then
					setLocalVisible(model, visible)
				end
			end
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
