-- My Pets › Index view.
local State = require("@client/State")
local sample = require("@preview/sample")
SEND_DATA(sample())
local Hud = require("@client/UI/Hud")
local Menus = require("@client/UI/Menus")
Hud.init({ onHop = function() end, openMenu = Menus.open, setAutoHop = function() end })
Menus.init()
Menus.open("Pets")
for _, item in game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants() do
	if item.ClassName == "TextButton" and item.Text == "INDEX" then
		item.Activated:Fire()
	end
end
local _ = State
