-- "You got…!" celebration (reference reward pop-ups): the reward's picture
-- on spinning rays, its name, a pop-in and a fade after a moment. Used for
-- daily rewards, gifts and quest rewards.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Rays = require(script.Parent.Parent.Components.Rays)
local RewardIcon = require(script.Parent.Parent.Components.RewardIcon)
local Sfx = require(script.Parent.Parent.Parent.Sfx)
local ScreenFx = require(script.Parent.Parent.Parent.Effects.Screen)

local new = Theme.new

local RewardPopup = {}

local gui: ScreenGui? = nil

function RewardPopup.init(screen: ScreenGui)
	gui = screen
end

-- `reward` is { kind, id?, amount? }; `label` is what it says under it.
function RewardPopup.show(reward: { kind: string, id: string? }, label: string)
	if not gui then
		return
	end
	local holder = new("Frame", {
		Name = "RewardPopup",
		Size = UDim2.fromOffset(420, 420),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = gui,
	})
	local scale = new("UIScale", { Scale = 0.3, Parent = holder })
	Rays.new({ Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = holder }, Color3.fromRGB(255, 230, 120), 10)
	RewardIcon.new(reward, {
		Size = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		ZIndex = 11,
		Parent = holder,
	})
	local top = Theme.label({
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.fromScale(0, 0.02),
		Text = "YOU GOT",
		TextColor3 = Color3.fromRGB(255, 225, 70),
		ZIndex = 12,
		Parent = holder,
	})
	Theme.textStroke(4).Parent = top
	local name = Theme.label({
		Size = UDim2.new(1.2, 0, 0, 56),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.78),
		Text = label,
		ZIndex = 12,
		Parent = holder,
	})
	name:FindFirstChildOfClass("UIStroke").Thickness = 4

	Sfx.play("Claim")
	ScreenFx.confetti(35)
	TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(2.2, function()
		local out = TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 })
		out.Completed:Connect(function()
			holder:Destroy()
		end)
		out:Play()
	end)
end

return RewardPopup
