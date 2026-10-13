-- Drifts the light lines on every water surface (WorldBuilder/Water tags
-- their Textures "WaterCaustics"), so the water looks alive.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local WaterCaustics = {}

local TAG = "WaterCaustics"
local SPEED = Vector2.new(1.6, 0.9) -- studs per second

function WaterCaustics.init()
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local offset = SPEED * elapsed
		for _, texture in CollectionService:GetTagged(TAG) do
			local t = texture :: Texture
			t.OffsetStudsU = offset.X % t.StudsPerTileU
			t.OffsetStudsV = offset.Y % t.StudsPerTileV
		end
	end)
end

return WaterCaustics
