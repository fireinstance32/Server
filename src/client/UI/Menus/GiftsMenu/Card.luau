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

-- Card colours sampled from the reference (top → bottom), by row.
local TIERS = {
	Blue = { Color3.fromRGB(86, 181, 244), Color3.fromRGB(49, 128, 233) },
	Purple = { Color3.fromRGB(205, 138, 255), Color3.fromRGB(160, 93, 236) },
	Orange = { Color3.fromRGB(255, 214, 70), Color3.fromRGB(252, 160, 35) },
	Rainbow = {
		Color3.fromRGB(165, 20, 255),
		Color3.fromRGB(60, 60, 247),
		Color3.fromRGB(14, 175, 200),
		Color3.fromRGB(190, 235, 30),
		Color3.fromRGB(250, 145, 9),
		Color3.fromRGB(235, 40, 30),
	},
}
local GREEN = { Color3.fromRGB(165, 250, 42), Color3.fromRGB(98, 214, 18) }
local RED = { Color3.fromRGB(243, 41, 37), Color3.fromRGB(172, 6, 5) }

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
	Gradient.apply(card, TIERS[tier])
	Studs.apply(card, 24)
	local scale = new("UIScale", { Parent = card })

	if tier == "Orange" or tier == "Rainbow" then
		Rays.new({
			Size = UDim2.fromOffset(190, 190),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 93),
			Parent = card,
		}, Color3.fromRGB(255, 250, 225), 12, false)
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
