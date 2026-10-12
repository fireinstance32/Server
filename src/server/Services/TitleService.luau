-- Titles (Config/Titles): unlocks them as players reach milestones, equips
-- one, and shows it above the player's head. The boost is in Stats.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Titles = require(Shared.Config.Titles)
local Pets = require(Shared.Config.Pets)
local Net = require(Shared.Net)

local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Parent.Remotes)

local TitleService = {}

local shown: { [Player]: string } = {} -- title id on each player's head

-- Name tag above the head in the title's rarity colour ("" removes it).
local function showTag(player: Player, titleId: string)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then
		return
	end
	local old = head:FindFirstChild("TitleTag")
	if old then
		old:Destroy()
	end
	local t = Titles.ById[titleId]
	if not t then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "TitleTag"
	gui.Size = UDim2.fromOffset(220, 34)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.MaxDistance = 90
	gui.AlwaysOnTop = false
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = t.name
	label.TextColor3 = Pets.RarityColors[t.rarity] or Color3.new(1, 1, 1)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = Color3.fromRGB(26, 24, 36)
	stroke.Parent = label
	label.Parent = gui
	gui.Parent = head
end

local function refreshTag(player: Player, data: any)
	local id = data.equippedTitle or ""
	if shown[player] ~= id then
		shown[player] = id
		showTag(player, id)
	end
end

-- Grants every title the player has newly qualified for.
local function check(player: Player, data: any)
	local earned = Titles.newlyEarned(data)
	if #earned == 0 then
		refreshTag(player, data)
		return
	end
	for _, id in earned do
		data.titles[id] = true
		Net.event("Notify"):FireClient(player, { kind = "Title", id = id })
	end
	DataService.changed(player) -- fires Changed again; nothing new then, so it stops
end

-- EquipTitle remote: (titleId | "") -> "" unequips.
local function equip(player: Player, titleId: unknown): (boolean, string)
	local data = DataService.get(player)
	if not data or typeof(titleId) ~= "string" then
		return false, "Invalid title"
	end
	if titleId == "" then
		data.equippedTitle = ""
	elseif data.titles[titleId] and Titles.ById[titleId] then
		data.equippedTitle = titleId
	else
		return false, "Title is locked"
	end
	DataService.changed(player)
	return true, if titleId == "" then "Title removed" else `{Titles.ById[titleId].name} equipped!`
end

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Head", 10)
		shown[player] = nil
		local data = DataService.get(player)
		if data then
			refreshTag(player, data)
		end
	end)
end

function TitleService.start()
	Remotes.handle("EquipTitle", equip)
	DataService.Changed:Connect(check)
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		shown[player] = nil
	end)
end

return TitleService
