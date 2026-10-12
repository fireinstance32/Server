-- Sunburst behind a featured item (pet details, hatch, rewards): thin bars
-- through the centre that fade out toward their ends, slowly spinning.
-- Built from frames, so it needs no image upload.

local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Parent.Theme)

local new = Theme.new

local Rays = {}

-- `color` tints the rays; `count` bars make 2×count rays. Returns the holder.
function Rays.new(props: { [string]: any }, color: Color3?, count: number?, spin: boolean?): Frame
	local holder = new("Frame", {
		Name = "Rays",
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	})
	for key, value in props do
		(holder :: any)[key] = value
	end
	local spinner = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = holder,
	})
	local n = count or 8
	for i = 1, n do
		local bar = new("Frame", {
			Size = UDim2.fromScale(1.2, 0.11),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = (i - 1) * 180 / n,
			BackgroundColor3 = color or Color3.fromRGB(255, 236, 150),
			ZIndex = holder.ZIndex,
			Parent = spinner,
		})
		new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.22, 0.6),
				NumberSequenceKeypoint.new(0.5, 0.1),
				NumberSequenceKeypoint.new(0.78, 0.6),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = bar,
		})
	end
	-- Soft glow in the middle.
	new("Frame", {
		Size = UDim2.fromScale(0.55, 0.55),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = color or Color3.fromRGB(255, 236, 150),
		BackgroundTransparency = 0.45,
		ZIndex = holder.ZIndex,
		Parent = holder,
	}, { new("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
	if spin ~= false then
		local connection = RunService.RenderStepped:Connect(function(dt)
			spinner.Rotation = (spinner.Rotation + dt * 12) % 360
		end)
		holder.Destroying:Connect(function()
			connection:Disconnect()
		end)
	end
	return holder
end

return Rays
