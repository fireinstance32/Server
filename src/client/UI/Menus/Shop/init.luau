-- Shop window (reference): Starter Pack, Gamepasses, Hops Packs and Codes in
-- one scrolling list. Giftable items carry a gift button (GiftPicker).

local Window = require(script.Parent.Window)
local PackSection = require(script.PackSection)
local PassSection = require(script.PassSection)
local HopsSection = require(script.HopsSection)
local CodesSection = require(script.CodesSection)

local ShopMenu = {}

function ShopMenu.build(body: Frame)
	local list = Window.list(body)
	local refreshPack = PackSection.build(list, 0)
	local refreshPasses = PassSection.build(list, 10, body)
	HopsSection.build(list, 40, body)
	CodesSection.build(list, 50)
	return function(data)
		refreshPack(data)
		refreshPasses()
	end
end

return ShopMenu
