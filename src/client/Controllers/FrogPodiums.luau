-- Per-player frog podium signs and prompt text: "+N Hops", price or
-- UNLOCKED / EQUIPPED, and Buy / Equip on the prompt. Pressing a podium's
-- prompt is handled by PromptController (FrogId attribute).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.UI.Theme)
local Purchases = require(script.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local FrogPodiums = {}

local function buildSign(anchor: BasePart, frog, prompt: ProximityPrompt, container: Instance)
	local gui = new("BillboardGui", {
		Name = frog.id .. "Sign",
		Adornee = anchor,
		Size = UDim2.fromOffset(200, 96),
		MaxDistance = 120,
		LightInfluence = 0,
		Parent = container,
	})
	local status = Theme.label({ Size = UDim2.new(1, 0, 0, 28), Text = "", Parent = gui })
	Theme.textStroke().Parent = status
	Theme.label({
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.fromOffset(0, 28),
		Text = `+{Format.abbreviate(frog.perBounce)} Hops`,
		Parent = gui,
	})
	local price = Theme.label({
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 66),
		Text = "",
		TextColor3 = C.Gold,
		Font = Enum.Font.BuilderSansBold,
		Parent = gui,
	})
	Theme.textStroke().Parent = price

	return function(data)
		local owned = data.frogs[frog.id] == true
		local equipped = data.equippedFrog == frog.id
		if equipped then
			status.Text, status.TextColor3 = "EQUIPPED", C.Blue
			prompt.ActionText, prompt.Enabled = "Equipped", false
		elseif owned then
			status.Text, status.TextColor3 = "UNLOCKED", Color3.fromRGB(90, 230, 90)
			prompt.ActionText, prompt.Enabled = "Equip", true
		else
			status.Text, status.TextColor3 = "LOCKED", C.Red
			prompt.ActionText, prompt.Enabled = "Buy", frog.rewardOnly == nil
		end
		if owned then
			price.Text = ""
		elseif frog.rewardOnly then
			price.Text = `🎁 {frog.rewardOnly}`
		elseif frog.robuxOnly then
			local left, limit = Purchases.stock("PhoenixFrog")
			price.Text = `ONLY \u{E002} {Purchases.price("product", "PhoenixFrog")}`
				.. (if left then `  •  STOCK {left}/{limit}` else "")
		else
			price.Text = `🏆 {Format.abbreviate(frog.price)} Wins`
		end
	end
end

function FrogPodiums.init()
	local folder = Workspace:WaitForChild("World"):WaitForChild("FrogPodiums")
	local container = new("Folder", { Name = "FrogPodiumSigns", Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local refreshers = {}
	for _, frog in Frogs.List do
		local model = folder:WaitForChild(frog.id)
		local anchor = model:WaitForChild("SignAnchor") :: BasePart
		local prompt = model:WaitForChild("Pedestal"):WaitForChild("ProximityPrompt") :: ProximityPrompt
		table.insert(refreshers, buildSign(anchor, frog, prompt, container))
	end
	State.observe(function(data)
		for _, refresh in refreshers do
			refresh(data)
		end
	end)
end

return FrogPodiums
