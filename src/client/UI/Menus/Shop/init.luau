-- Shop window: Pack, Passes, Hops and Codes sections in one scrolling list.

local Window = require(script.Parent.Window)
local PackSection = require(script.PackSection)
local PassSection = require(script.PassSection)
local HopsSection = require(script.HopsSection)
local CodesSection = require(script.CodesSection)

local ShopMenu = {}

function ShopMenu.build(body: Frame)
	local list = Window.list(body)
	PackSection.build(list, 0)
	local refreshPasses = PassSection.build(list, 10)
	HopsSection.build(list, 30)
	CodesSection.build(list, 40)
	return function()
		refreshPasses()
	end
end

return ShopMenu
