-- Small panel listing where the Hops multiplier comes from. Toggled by
-- clicking the multiplier text; data comes from snapshot.multipliers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)
local Gradient = require(script.Parent.Parent.Components.Gradient)

local new = Theme.new
local C = Theme.Colors

local MultiplierInfo = {}

local function partText(part): string
	if part.kind == "add" then
		return `{part.label}: +{math.floor(part.value * 100 + 0.5)}%`
	end
	return `{part.label}: {Format.multiplier(part.value)}`
end

function MultiplierInfo.init(parent: Frame, toggle: TextButton)
	local panel = new("Frame", {
		Name = "MultiplierInfo",
		Size = UDim2.fromOffset(260, 40),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 0, -8),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0.05,
		Visible = false,
		Parent = parent,
	}, {
		Theme.corner(12),
		Theme.stroke(3),
		new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		new("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
	})

	Gradient.apply(panel, "Tile")

	local function render(data)
		for _, child in panel:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		local breakdown = data.multipliers and data.multipliers.hops
		local lines = { `Strength {Format.multiplier(data.hopsMultiplier)}` }
		if breakdown then
			for _, part in breakdown.parts do
				table.insert(lines, partText(part))
			end
			if #breakdown.parts == 0 then
				table.insert(lines, "No boosts yet – rebirth, level up or hatch pets!")
			end
		end
		for i, line in lines do
			Theme.label({
				Size = UDim2.new(1, 0, 0, if i == 1 then 28 else 22),
				Text = line,
				TextColor3 = if i == 1 then C.Gold else C.White,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = i,
				Parent = panel,
			})
		end
	end

	toggle.Activated:Connect(function()
		panel.Visible = not panel.Visible
		if panel.Visible and State.data then
			render(State.data)
		end
	end)
	State.observe(function(data)
		if panel.Visible then
			render(data)
		end
	end)
end

return MultiplierInfo
