-- One menu open over the HUD: node run.mjs menu:Shop (Rebirth, Pets, Inventory, Trails, Daily, Gifts, Frogs).
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Hud = require("@client/UI/Hud")
local Menus = require("@client/UI/Menus")
Hud.init({ onHop = function() end, openMenu = Menus.open, setAutoHop = function() end })
Menus.init()
-- "Shop@700" scrolls the menu's list down 700 px.
local name, scroll = string.match(SCENE_ARG, "^(%w+)@?(%d*)$")
if name == "Gifts" then
	-- The moment of the reference screenshot: 22 minutes in, first 5 claimed.
	local player = game:GetService("Players").LocalPlayer
	player:SetAttribute("SessionStart", os.time() - (22 * 60 + 1))
	player:SetAttribute("GiftsClaimed", "1,2,3,4,5")
end
Menus.open(if name and name ~= "" then name else "Shop")
if scroll and scroll ~= "" then
	for _, item in game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants() do
		if item.ClassName == "ScrollingFrame" then
			item.CanvasPosition = Vector2.new(0, tonumber(scroll))
		end
	end
end
local _ = State
