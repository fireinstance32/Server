-- One Playtime Rewards card, built to the reference pixels (201×189 inside
-- a 4 px black edge): reward name on top, the picture (on rays for the
-- orange and rainbow tiers), and a studded bar — green "Claim" or a red
-- 00:00:00 countdown. Claimed cards go dark with a big tick; cards ready
-- to claim gently pulse.

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local Rays = require(script.Parent.Parent.Parent.Components.Rays)
local RewardIcon = require(script.Parent.Parent.Parent.Components.RewardIcon)

local new = Theme.new

local Card = {}

Card.Size = Vector2.new(201, 189)

local INK = Color3.fromRGB(8, 8, 10)

-- Card colours sampled down the reference cards (top → bottom), by row.
-- Saturated: the reference only lightens near the top.
local TIERS = {
	Blue = { Color3.fromRGB(56, 178, 252), Color3.fromRGB(36, 118, 234) },
	Purple = { Color3.fromRGB(202, 132, 255), Color3.fromRGB(136, 70, 226) },
	Orange = { Color3.fromRGB(255, 205, 40), Color3.fromRGB(245, 142, 12) },
}

-- Rainbow card: bands at the reference's heights (violet top → red bottom).
local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 6, 245)),
	ColorSequenceKeypoint.new(0.07, Color3.fromRGB(176, 8, 245)),
	ColorSequenceKeypoint.new(0.24, Color3.fromRGB(86, 30, 255)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(38, 136, 230)),
	ColorSequenceKeypoint.new(0.58, Color3.fromRGB(86, 230, 88)),
	ColorSequenceKeypoint.new(0.72, Color3.fromRGB(244, 224, 6)),
	ColorSequenceKeypoint.new(0.86, Color3.fromRGB(250, 130, 16)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 36, 36)),
})
local GREEN = { Color3.fromRGB(160, 246, 30), Color3.fromRGB(192, 252, 26), Color3.fromRGB(110, 222, 15) } -- yellow-green shine in the middle
local RED = { Color3.fromRGB(244, 34, 28), Color3.fromRGB(170, 4, 4) }

export type Card = { set: (state: "claimed" | "ready" | "waiting", secondsLeft: number) -> () }

local function clock(seconds: number): string
	seconds = math.max(math.floor(seconds), 0)
	return string.format("%02d:%02d:%02d", seconds // 3600, seconds // 60 % 60, seconds % 60)
end

function Card.new(parent: Instance, position: UDim2, tier: string, gift, onClaim: () -> ()): Card
	local card = new("Frame", {
		Name = gift.label,
		Size = UDim2.fromOffset(Card.Size.X, Card.Size.Y),
		Position = position,
		ClipsDescendants = true,
		Parent = parent,
	}, { Theme.corner(20), Theme.stroke(4, INK) })
	if tier == "Rainbow" then
		Gradient.apply(card, { Color3.new(1, 1, 1), Color3.new(1, 1, 1) }).Color = RAINBOW
	else
		Gradient.apply(card, TIERS[tier])
	end
	Studs.apply(card, 24)
	local scale = new("UIScale", { Parent = card })

	if tier == "Orange" or tier == "Rainbow" then
		Rays.new({
			Size = UDim2.fromOffset(190, 190),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 93),
			Parent = card,
		}, Color3.fromRGB(255, 236, 120), 12, false, 0.45)
	end
	RewardIcon.new(gift.reward, {
		Size = UDim2.fromOffset(110, 110),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 93),
		ZIndex = 2,
		Parent = card,
	})
	local header = Theme.label({
		Size = UDim2.new(1, -10, 0, 30),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 26),
		Text = string.upper(gift.label),
		ZIndex = 3,
		Parent = card,
	})
	new("UITextSizeConstraint", { MaxTextSize = 21, Parent = header })
	local headerStroke = header:FindFirstChildOfClass("UIStroke")
	if headerStroke then
		headerStroke.Thickness = 2.5 -- reference card text has a thinner edge
	end

	local bar = new("TextButton", {
		Name = "Bar",
		Size = UDim2.fromOffset(169, 36),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 141),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = card,
	}, { Theme.corner(4), Theme.stroke(2, INK) })
	Studs.apply(bar, 15)
	local barText = Theme.label({
		Size = UDim2.new(1, -12, 1, -6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Text = "",
		ZIndex = 4,
		Parent = bar,
	})
	new("UITextSizeConstraint", { MaxTextSize = 21, Parent = barText })
	bar.Activated:Connect(onClaim)

	local shade = new("Frame", {
		Name = "Claimed",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.43, -- reference: claimed cards at ~43% brightness
		Visible = false,
		ZIndex = 8,
		Parent = card,
	}, { Theme.corner(20) })
	Icon.new("check", {
		Size = UDim2.fromOffset(135, 135),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 94),
		ZIndex = 9,
		Parent = shade,
	})

	local pulse = TweenService:Create(
		scale,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Scale = 1.035 }
	)
	local state = nil
	return {
		set = function(newState, secondsLeft)
			if newState ~= state then
				state = newState
				shade.Visible = newState == "claimed"
				bar.Visible = newState ~= "claimed"
				Gradient.apply(bar, if newState == "ready" then GREEN else RED)
				if newState == "ready" then
					pulse:Play()
				else
					pulse:Cancel()
					scale.Scale = 1
				end
			end
			barText.Text = if newState == "ready" then "Claim" else clock(secondsLeft)
		end,
	}
end

return Card
