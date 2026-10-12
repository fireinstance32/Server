-- Puts each player's equipped frog in their right hand (the reference
-- game's held stone). Built on the server so every player sees it. Hidden
-- while the frog is out hopping, then shown again.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Game = require(Shared.Config.Game)
local Models = require(Shared.Util.Models)

local DataService = require(script.Parent.DataService)

local HeldFrogService = {}

local MODEL_NAME = "HeldFrog"
local HELD_SCALE = 1.1
local currentFrog: { [Player]: string } = {}

local function hand(character: Model): BasePart?
	return (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")) :: BasePart?
end

local function setVisible(model: Model, visible: boolean)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = if visible then 0 else 1
		end
	end
end

local function attach(player: Player, frogId: string)
	local character = player.Character
	local grip = character and hand(character)
	if not character or not grip then
		return
	end
	local old = character:FindFirstChild(MODEL_NAME)
	if old then
		old:Destroy()
	end

	local def = Frogs.ById[frogId] or Frogs.ById[Frogs.Default]
	local model = Models.frog(def.color, HELD_SCALE)
	model.Name = MODEL_NAME
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.Massless = true
			part.CanCollide = false
		end
	end
	local body = model.PrimaryPart :: BasePart
	-- Sit in the palm, facing forward (PivotTo moves every part together).
	model:PivotTo(grip.CFrame * CFrame.new(0, -grip.Size.Y / 2 - 0.3, -0.2) * CFrame.Angles(0, math.rad(90), 0))
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = grip
	weld.Part1 = body
	weld.Parent = body
	model.Parent = character
	currentFrog[player] = def.id
end

-- Hides the held frog from `delay` seconds from now for `duration` seconds
-- (it has left the hand and is hopping down the river).
function HeldFrogService.hideDuring(player: Player, delay: number, duration: number)
	task.delay(delay, function()
		local model = player.Character and player.Character:FindFirstChild(MODEL_NAME)
		if not model then
			return
		end
		setVisible(model :: Model, false)
		task.delay(duration, function()
			if model.Parent then
				setVisible(model :: Model, true)
			end
		end)
	end)
end

-- Seconds the toss takes before the frog leaves the hand.
HeldFrogService.ReleaseDelay = Game.TossWindup

function HeldFrogService.start()
	local function onCharacter(player: Player)
		local data = DataService.get(player)
		-- The character's hand can arrive a moment after the model.
		task.defer(function()
			attach(player, data and data.equippedFrog or Frogs.Default)
		end)
	end
	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function()
			onCharacter(player)
		end)
		if player.Character then
			onCharacter(player)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		currentFrog[player] = nil
	end)

	DataService.Changed:Connect(function(player, data)
		if currentFrog[player] ~= data.equippedFrog then
			attach(player, data.equippedFrog)
		end
	end)
end

return HeldFrogService
