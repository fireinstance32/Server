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

local function multiplierCard(parent: Frame, x: number): TextLabel
	local card = new("Frame", {
		Size = UDim2.new(0.42, 0, 0, 100),
		Position = UDim2.new(x, 0, 0, 50),
		Parent = parent,
	}, { Theme.corner(12), Theme.stroke(3) })
	Gradient.apply(card, "Yellow")
	Studs.apply(card, 22, 0.5)
	Icon.new("bolt", { Size = UDim2.fromOffset(100, 100), Position = UDim2.fromOffset(6, 0), Rotation = -8, Parent = card })
	return Theme.label({
		Size = UDim2.new(1, -110, 0.8, 0),
		Position = UDim2.new(0, 100, 0.1, 0),
		Text = "x1\nHOPS",
		Parent = card,
	})
end

function RebirthMenu.build(body: Frame)
	Theme.label({ Size = UDim2.new(0.42, 0, 0, 44), Text = "Before", Parent = body })
	Theme.label({ Size = UDim2.new(0.42, 0, 0, 44), Position = UDim2.fromScale(0.58, 0), Text = "After", Parent = body })
	local before = multiplierCard(body, 0)
	local after = multiplierCard(body, 0.58)
	Theme.label({ Size = UDim2.new(0.1, 0, 0, 60), Position = UDim2.new(0.45, 0, 0, 70), Text = "➜", Parent = body })

	local warning = Theme.label({
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 165),
		Text = "Resets your LEVEL, HOPS and WINS!",
		TextColor3 = Color3.fromRGB(255, 60, 60),
		Parent = body,
	})
	Theme.textStroke().Parent = warning

	local bar = new("Frame", {
		Size = UDim2.new(0.9, 0, 0, 56),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 215),
		ClipsDescendants = true,
		Parent = body,
	}, { Theme.corner(12), Theme.stroke(4) })
	Gradient.apply(bar, "Silver")
	Studs.apply(bar, 22, 0.7)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), Parent = bar }, { Theme.corner(12) })
	Gradient.apply(fill, "Blue")
	Studs.apply(fill, 22, 0.6)
	local barText = Theme.label({
		Size = UDim2.new(1, 0, 0.7, 0),
		Position = UDim2.fromScale(0, 0.15),
		Text = "Level 1 / Level 20",
		ZIndex = 2,
		Parent = bar,
	})

	local rebirthButton = Window.button({
		Size = UDim2.fromOffset(220, 70),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0.5, -15, 0, 290),
		Text = "Rebirth",
	}, "Green", function()
		Window.report(Net.func("Rebirth"):InvokeServer())
	end)
	rebirthButton.Parent = body

	local skip = Window.button({
		Size = UDim2.fromOffset(220, 70),
		Position = UDim2.new(0.5, 15, 0, 290),
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
		before.Text = `{Format.multiplier(now)}\nHOPS`
		after.Text = `{Format.multiplier(nextValue)}\nHOPS`
		local ratio = math.clamp(data.level / data.levelCap, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(ratio, 1) }):Play()
		barText.Text = `Level {data.level} / Level {data.levelCap}`
		Gradient.apply(rebirthButton, if ratio >= 1 then "Green" else "Grey")
	end)
end

return RebirthMenu
