-- Draws each training pond's sign for this player: requirement pill
-- ("🔁 2" or "◎ 90"), UNLOCKED / LOCKED, and "4x HOPS". Signs are local
-- because lock state is different for every player.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Ponds = require(Shared.Config.Ponds)

local Theme = require(script.Parent.Parent.UI.Theme)
local Purchases = require(script.Parent.Parent.Purchases)
local PondAccess = require(script.Parent.Parent.PondAccess)
local State = require(script.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local PondSigns = {}

local function requirementText(pond: Ponds.Pond): string
	if pond.pass then
		return `ALL WORLDS  \u{E002} {Purchases.price("pass", pond.pass)}`
	end
	return `🔁 {pond.rebirths}`
end

local function buildSign(anchor: BasePart, pond: Ponds.Pond, container: Instance)
	local gui = new("BillboardGui", {
		Name = pond.id .. "Sign",
		Adornee = anchor,
		Size = UDim2.fromOffset(260, 150),
		MaxDistance = 220,
		AlwaysOnTop = false,
		LightInfluence = 0,
		Parent = container,
	})
	local pill = Theme.label({
		Size = UDim2.new(0.8, 0, 0, 40),
		Position = UDim2.fromScale(0.1, 0),
		BackgroundColor3 = Color3.fromRGB(30, 30, 36),
		BackgroundTransparency = 0.1,
		Text = requirementText(pond),
		Font = Enum.Font.BuilderSansBold,
		Parent = gui,
	})
	Theme.corner(20).Parent = pill
	local status = Theme.label({
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.fromOffset(0, 46),
		Text = "",
		Parent = gui,
	})
	Theme.textStroke().Parent = status
	Theme.label({
		Size = UDim2.new(1, 0, 0, 56),
		Position = UDim2.fromOffset(0, 84),
		Text = `{pond.multiplier}x HOPS`,
		Parent = gui,
	})

	return function()
		local unlocked = PondAccess.isUnlocked(pond)
		status.Text = if unlocked then "UNLOCKED" else "LOCKED"
		status.TextColor3 = if unlocked then Color3.fromRGB(90, 230, 90) else C.Red
	end
end

function PondSigns.init()
	local world = Workspace:WaitForChild("World")
	local pondsFolder = world:WaitForChild("Ponds")
	local container = new("Folder", {
		Name = "PondSigns",
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	local refreshers = {}
	for _, pond in Ponds.List do
		local model = pondsFolder:WaitForChild(pond.id)
		local anchor = model:WaitForChild("SignAnchor") :: BasePart
		table.insert(refreshers, buildSign(anchor, pond, container))
	end
	State.observe(function()
		for _, refresh in refreshers do
			refresh()
		end
	end)
end

return PondSigns
