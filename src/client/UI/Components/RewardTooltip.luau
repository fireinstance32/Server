-- White hover card for a reward (reference Daily Rewards): name, rarity or
-- kind in colour, ⚡ bonus and a short note. Shows beside the hovered card.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Frogs = require(Shared.Config.Frogs)
local Potions = require(Shared.Config.Potions)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.Theme)
local Icon = require(script.Parent.Icon)

local new = Theme.new

local RewardTooltip = {}

local INK = Color3.fromRGB(46, 46, 54)
local PURPLE = Color3.fromRGB(150, 60, 230)

type Info = { title: string, sub: string, subColor: Color3, bonus: string?, note: string? }

local function info(reward: { kind: string, id: string?, amount: number?, label: string }): Info
	if reward.kind == "pet" and reward.id and Pets.ById[reward.id] then
		local pet = Pets.ById[reward.id]
		return { title = pet.name, sub = pet.rarity, subColor = Pets.RarityColors[pet.rarity], bonus = `+{pet.bonus}` }
	elseif reward.kind == "frog" and reward.id and Frogs.ById[reward.id] then
		local frog = Frogs.ById[reward.id]
		return {
			title = frog.name,
			sub = if frog.rewardOnly then "Limited" else "Frog",
			subColor = PURPLE,
			bonus = `+{Format.abbreviate(frog.perBounce)} per hop`,
			note = if frog.rewardOnly then "Only from Day 7!" else nil,
		}
	elseif reward.kind == "potion" and reward.id and Potions.ById[reward.id] then
		local potion = Potions.ById[reward.id]
		return {
			title = reward.label,
			sub = "Boost",
			subColor = Color3.fromRGB(40, 170, 60),
			note = `x{potion.factor} {string.upper(potion.stat)} for {potion.duration // 60} min`,
		}
	end
	return { title = reward.label, sub = "Reward", subColor = Color3.fromRGB(240, 150, 10) }
end

local function line(parent: Instance, order: number, text: string, color: Color3, height: number)
	return Theme.label({
		Size = UDim2.new(1, 0, 0, height),
		Text = text,
		TextColor3 = color,
		TextWrapped = true,
		LayoutOrder = order,
		ZIndex = 21,
		Parent = parent,
	})
end

local function build(card: GuiObject, reward): Frame
	local data = info(reward)
	local tip = new("Frame", {
		Name = "Tooltip",
		Size = UDim2.fromOffset(250, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(1, 14, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(250, 250, 250),
		Visible = false,
		ZIndex = 20,
		Parent = card,
	}, {
		Theme.corner(12),
		Theme.stroke(3),
		new("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		new("UIListLayout", {
			Padding = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	line(tip, 1, data.title, INK, 28)
	line(tip, 2, data.sub, data.subColor, 32)
	if data.bonus then
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = 3, Parent = tip })
		Icon.new("bolt", { Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(18, 1), ZIndex = 21, Parent = row })
		local label = line(row, 0, data.bonus, INK, 30)
		label.Size = UDim2.new(1, -60, 0, 30)
		label.Position = UDim2.fromOffset(56, 3)
		label.TextXAlignment = Enum.TextXAlignment.Left
	end
	if data.note then
		line(tip, 4, data.note, PURPLE, 48)
	end
	return tip
end

-- Shows the tooltip while the pointer is over `card`.
function RewardTooltip.attach(card: GuiObject, reward)
	local tip = build(card, reward)
	local baseZ = card.ZIndex
	card.MouseEnter:Connect(function()
		tip.Visible = true
		card.ZIndex = baseZ + 10 -- draw over the neighbouring cards
	end)
	card.MouseLeave:Connect(function()
		tip.Visible = false
		card.ZIndex = baseZ
	end)
end

return RewardTooltip
