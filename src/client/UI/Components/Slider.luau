-- 0–100 slider (reference Settings): dark track, green fill, and a studded
-- green knob showing the value. Drag the knob or click the track.
-- onChange fires while dragging; onCommit once on release.

local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Gradient)
local Studs = require(script.Parent.Studs)

local new = Theme.new

local Slider = {}

export type Slider = { frame: Frame, set: (number) -> () }

local KNOB = 58

function Slider.new(props: { [string]: any }, onChange: (number) -> (), onCommit: (number) -> ()): Slider
	local frame = new("Frame", { Name = "Slider", BackgroundTransparency = 1 })
	for key, value in props do
		(frame :: any)[key] = value
	end
	local track = new("TextButton", {
		Name = "Track",
		Size = UDim2.new(1, -KNOB / 2, 0, 20),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(24, 25, 30),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	}, { Theme.corner(4), Theme.stroke(3, Color3.fromRGB(12, 12, 16)) })
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(70, 220, 40),
		Parent = track,
	}, { Theme.corner(4) })
	Gradient.apply(fill, { Color3.fromRGB(120, 255, 80), Color3.fromRGB(30, 190, 20) })

	local knob = new("TextButton", {
		Name = "Knob",
		Size = UDim2.fromOffset(KNOB * 0.82, KNOB),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = track,
	}, { Theme.corner(6), Theme.stroke(3, Color3.fromRGB(20, 96, 18)) })
	Gradient.apply(knob, "Green")
	Studs.apply(knob, 14, 0.35)
	local value = Theme.label({
		Size = UDim2.new(1, -4, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "100",
		ZIndex = 4,
		Parent = knob,
	})
	value:FindFirstChildOfClass("UIStroke").Thickness = 2

	local current = 100
	local function set(v: number)
		current = math.clamp(math.floor(v + 0.5), 0, 100)
		fill.Size = UDim2.fromScale(current / 100, 1)
		fill.Visible = current > 0
		knob.Position = UDim2.fromScale(current / 100, 0.5)
		value.Text = tostring(current)
	end

	local dragging = false
	local function fromX(x: number)
		local width = math.max(track.AbsoluteSize.X, 1)
		set((x - track.AbsolutePosition.X) / width * 100)
		onChange(current)
	end
	local function begin(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromX(input.Position.X)
		end
	end
	track.InputBegan:Connect(begin)
	knob.InputBegan:Connect(begin)
	local moved = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	local ended = UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			onCommit(current)
		end
	end)
	frame.Destroying:Connect(function()
		moved:Disconnect()
		ended:Disconnect()
	end)

	return {
		frame = frame,
		set = function(v: number)
			if not dragging then
				set(v)
			end
		end,
	}
end

return Slider
