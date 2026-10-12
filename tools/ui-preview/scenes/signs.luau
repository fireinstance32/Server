-- World signs laid out flat: egg titles + odds panels.
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Pets = require("@shared/Config/Pets")
local Sign = require("@client/Controllers/EggSigns/Sign")
local folder = Instance.new("Folder")
folder.Parent = game:GetService("Players").LocalPlayer.PlayerGui
for _, id in { "Common", "Rare", "Rainbow", "Swamp" } do
	local sign = Sign.build(Pets.EggsById[id], Instance.new("Part"), folder)
	sign.refresh(State.data)
end
-- Pond and frog podium signs too.
local Ponds = require("@shared/Config/Ponds")
local Frogs = require("@shared/Config/Frogs")
local PondSigns = require("@client/Controllers/PondSigns")
local FrogPodiums = require("@client/Controllers/FrogPodiums")
local folder2 = Instance.new("Folder")
folder2.Parent = game:GetService("Players").LocalPlayer.PlayerGui
for _, pond in { Ponds.List[1], Ponds.List[2], Ponds.List[5] } do
	PondSigns.buildSign(Instance.new("Part"), pond, folder2)()
end
for _, id in { "Tree", "Dart", "Phoenix", "ShootingStar" } do
	FrogPodiums.buildSign(Instance.new("Part"), Frogs.ById[id], Instance.new("ProximityPrompt"), folder2)(State.data)
end
FLATTEN_BILLBOARDS()
