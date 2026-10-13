-- The HUD Starter Pack picture, put together from parts (reference: a pile of
-- the pack's rewards behind its pet): Strength potion, bolt and rebirth icons
-- fanned out at the back, the Rainbow Unicat in front, a slow golden
-- sunburst behind and an idle bob. Icons are only placed and scaled (pack
-- licence: no edits, no tinting).

local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Parent.Theme)
local Icon = require(script.Parent.Parent.Components.Icon)
local PetImage = require(script.Parent.Parent.Components.PetImage)
local Rays = require(script.Parent.Parent.Components.Rays)

local StarterPackIcon = {}

-- Back row: icon, centre (scale of the holder), size, tilt, bob phase.
local BACK = {
	{ name = "potion_hops", at = Vector2.new(0.27, 0.3), size = 0.56, tilt = -16, phase = 0 },
	{ name = "bolt", at = Vector2.new(0.52, 0.2), size = 0.58, tilt = 10, phase = 2.1 },
	{ name = "rebirth", at = Vector2.new(0.76, 0.32), size = 0.5, tilt = 14, phase = 4.2 },
}
local PET = "StarterUnicat"

-- Fills `parent` (a square button) and starts the idle animation, which
-- stops when the picture is destroyed.
function StarterPackIcon.new(parent: GuiObject): Frame
	local holder = Theme.new("Frame", {
		Name = "StarterPackIcon",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	Rays.new({
		Size = UDim2.fromScale(1.15, 1.15),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 1,
		Parent = holder,
	}, Color3.fromRGB(255, 220, 90), 6, true, 0.45)

	local moving: { { item: GuiObject, at: Vector2, tilt: number, phase: number, lift: number } } = {}
	for i, spec in BACK do
		local item = Icon.new(spec.name, {
			Size = UDim2.fromScale(spec.size, spec.size),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(spec.at.X, spec.at.Y),
			Rotation = spec.tilt,
			ZIndex = 1 + i,
			Parent = holder,
		})
		table.insert(moving, { item = item, at = spec.at, tilt = spec.tilt, phase = spec.phase, lift = 0.025 })
	end
	local pet = PetImage.new("pet", PET, {
		Size = UDim2.fromScale(0.95, 0.95),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.6),
		ZIndex = 6,
		Parent = holder,
	})
	table.insert(moving, { item = pet, at = Vector2.new(0.5, 0.6), tilt = 0, phase = 1, lift = 0.035 })

	local clock = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not holder.Parent then
			connection:Disconnect()
			return
		end
		clock += dt
		for _, m in moving do
			local wave = math.sin(clock * 2.2 + m.phase)
			m.item.Position = UDim2.fromScale(m.at.X, m.at.Y - wave * m.lift)
			m.item.Rotation = m.tilt + wave * 3
		end
	end)
	return holder
end

return StarterPackIcon
