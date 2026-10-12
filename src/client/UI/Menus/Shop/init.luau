-- Shop window: Pack, Passes, Hops, Gift and Codes sections in one list.

local Window = require(script.Parent.Window)
local PackSection = require(script.PackSection)
local PassSection = require(script.PassSection)
local HopsSection = require(script.HopsSection)
local CodesSection = require(script.CodesSection)
local GiftSection = require(script.GiftSection)

local ShopMenu = {}

function ShopMenu.build(body: Frame)
	local list = Window.list(body)
	local refreshPack = PackSection.build(list, 0)
	local refreshPasses = PassSection.build(list, 10)
	HopsSection.build(list, 30)
	local refreshGifts = GiftSection.build(list, 40)
	CodesSection.build(list, 50)
	return function(data)
		refreshPack(data)
		refreshPasses()
		refreshGifts()
	end
end

return ShopMenu
