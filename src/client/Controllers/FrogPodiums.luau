-- Per-player frog podium signs and prompt text: "+N Hops", price or
-- UNLOCKED / EQUIPPED, and Buy / Equip on the prompt. Pressing a podium's
-- prompt is handled by PromptController (FrogId attribute).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)

local Theme = require(script.Parent.Parent.UI.Theme)
local Icon = require(script.Parent.Parent.UI.Components.Icon)
local Purchases = require(script.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local FrogPodiums = {}

-- Reference podium sign: LOCKED / UNLOCKED, frog name, ⚡ +N Hops, 🏆 price.
local function buildSign(anchor: BasePart, frog, prompt: ProximityPrompt, container: Instance)
	local gui = new("BillboardGui", {
		Name = frog.id .. "Sign",
		Adornee = anchor,
		Size = UDim2.fromOffset(230, 128),
		MaxDistance = 120,
		LightInfluence = 0,
		Parent = container,
	})
	local status = Theme.label({ Size = UDim2.new(1, 0, 0, 24), Text = "", Parent = gui })
	Theme.textStroke().Parent = status
	Theme.label({ Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 24), Text = frog.name, Parent = gui })
	Icon.new("bolt", { Size = UDim2.fromOffset(38, 38), Position = UDim2.new(0, 14, 0, 50), Parent = gui })
	Theme.label({
		Size = UDim2.new(1, -60, 0, 38),
		Position = UDim2.fromOffset(50, 50),
		Text = `+{Format.abbreviate(frog.perBounce)} Strength`,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = gui,
	})
	local priceIcon = Icon.new("trophy", { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0, 22, 0, 92), Parent = gui })
	local price = Theme.label({
		Size = UDim2.new(1, -66, 0, 30),
		Position = UDim2.fromOffset(56, 92),
		Text = "",
		TextColor3 = C.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
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
		priceIcon.Visible = not owned and not frog.rewardOnly and not frog.robuxOnly
		if owned then
			price.Text = ""
		elseif frog.rewardOnly then
			price.Text = frog.rewardOnly
		elseif frog.robuxOnly then
			local left, limit = Purchases.stock("PhoenixFrog")
			price.Text = `\u{E002} {Purchases.price("product", "PhoenixFrog")}` .. (if left then `  {left}/{limit} left` else "")
		else
			price.Text = `{Format.abbreviate(frog.price)} Wins`
		end
	end
end

FrogPodiums.buildSign = buildSign -- (UI preview)

function FrogPodiums.init()
	local root = Workspace:WaitForChild("World")
	local container = new("Folder", { Name = "FrogPodiumSigns", Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local refreshers = {}
	for _, world in Worlds.List do
		local folder = root:WaitForChild(world.id):WaitForChild("FrogPodiums")
		for _, frog in Frogs.forWorld(world.id) do
			local model = folder:WaitForChild(frog.id)
			local anchor = model:WaitForChild("SignAnchor") :: BasePart
			local prompt = model:WaitForChild("Pedestal"):WaitForChild("ProximityPrompt") :: ProximityPrompt
			table.insert(refreshers, buildSign(anchor, frog, prompt, container))
		end
	end
	State.observe(function(data)
		for _, refresh in refreshers do
			refresh(data)
		end
	end)
end

return FrogPodiums
