-- Rebirth window: Before → After multiplier, warning, level progress,
-- Rebirth and Skip Rebirth (Robux) buttons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Game = require(Shared.Config.Game)
local Format = require(Shared.Util.Format)
local Signature = require(Shared.Util.Signature)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local Window = require(script.Parent.Window)
local Studs = require(script.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Components.Icon)

local new = Theme.new

local RebirthMenu = {}

-- Pixel layout measured from the reference (1920×1080, 914×618 window; body
-- is 886 wide).
local function multiplierCard(parent: Frame, x: number): TextLabel
	local card = new("Frame", {
		Size = UDim2.fromOffset(371, 117),
		Position = UDim2.fromOffset(x, 122),
		Parent = parent,
	}, { Theme.corner(8), Theme.stroke(3) })
	Gradient.apply(card, "Yellow")
	Studs.apply(card, 22)
	Icon.new("bolt", {
		Size = UDim2.fromOffset(112, 128),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 22, 0.5, 0),
		Rotation = 8,
		Parent = card,
	})
	return Theme.label({
		Size = UDim2.fromOffset(200, 96),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 252, 0.5, 0),
		Text = "x1\nSTRENGTH",
		Parent = card,
	})
end

function RebirthMenu.build(body: Frame)
	for _, spec in { { "Before", 203 }, { "After", 693 } } do
		Theme.label({
			Size = UDim2.fromOffset(300, 58),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromOffset(spec[2], 20),
			Text = spec[1],
			Parent = body,
		})
	end
	local before = multiplierCard(body, 20)
	local after = multiplierCard(body, 508)
	Icon.new("arrow_right", {
		Size = UDim2.fromOffset(80, 80),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(450, 180),
		Parent = body,
	})

	local warning = Theme.label({
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.fromOffset(0, 274),
		Text = "Resets your LEVEL and STRENGTH!",
		TextColor3 = Color3.fromRGB(255, 40, 40),
		Parent = body,
	})
	Theme.textStroke().Parent = warning

	local bar = new("Frame", {
		Size = UDim2.fromOffset(732, 90),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 335),
		ClipsDescendants = true,
		Parent = body,
	}, { Theme.corner(8), Theme.stroke(3) })
	Gradient.apply(bar, "Silver")
	Studs.apply(bar, 22)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), Parent = bar }, { Theme.corner(8) })
	Gradient.apply(fill, "Blue")
	Studs.apply(fill, 22)
	local barText = Theme.label({
		Size = UDim2.new(1, -40, 0.66, 0),
		Position = UDim2.new(0, 20, 0.17, 0),
		Text = "Level 1 / Level 20",
		ZIndex = 2,
		Parent = bar,
	})

	local rebirthButton = Window.button({
		Size = UDim2.fromOffset(238, 88),
		Position = UDim2.fromOffset(178, 457),
		Text = "Rebirth",
	}, "Green", function()
		Window.report(Net.func("Rebirth"):InvokeServer())
	end)
	rebirthButton.Parent = body

	local skip = Window.button({
		Size = UDim2.fromOffset(240, 88),
		Position = UDim2.fromOffset(496, 457),
		Text = `Skip Rebirth \u{E002}{Purchases.price("product", "SkipRebirth")}`,
	}, "Purple", function()
		Purchases.product("SkipRebirth")
	end)
	skip.Parent = body

	-- Only re-tween the bar when level or rebirths actually change.
	return Signature.guard(function(data)
		return Signature.of(data.rebirths, data.level, data.levelCap)
	end, function(data)
		local now = 1 + data.rebirths * Game.RebirthHopsBonus
		local nextValue = 1 + (data.rebirths + 1) * Game.RebirthHopsBonus
		before.Text = `{Format.multiplier(now)}\nSTRENGTH`
		after.Text = `{Format.multiplier(nextValue)}\nSTRENGTH`
		local ratio = math.clamp(data.level / data.levelCap, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(ratio, 1) }):Play()
		barText.Text = `Level {data.level} / Level {data.levelCap}`
		Window.recolor(rebirthButton, if ratio >= 1 then "Green" else "Grey")
	end)
end

return RebirthMenu
