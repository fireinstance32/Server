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
FLATTEN_BILLBOARDS()
