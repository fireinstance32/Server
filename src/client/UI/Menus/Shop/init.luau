-- Shop window (reference: Stone Skipping shop video): Pack, Limited Offer,
-- Gamepasses, Boosts, Wins Pack and Codes in one list that fills the whole
-- window and scrolls under the title. Pieces are in Cards.

local Theme = require(script.Parent.Parent.Theme)
local PackSection = require(script.PackSection)
local LimitedSection = require(script.LimitedSection)
local PassSection = require(script.PassSection)
local BoostSection = require(script.BoostSection)
local WinsSection = require(script.WinsSection)
local CodesSection = require(script.CodesSection)

local new = Theme.new

local ShopMenu = {}

function ShopMenu.build(body: Frame)
	local list = new("ScrollingFrame", {
		Name = "List",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(230, 230, 236),
		ScrollBarImageTransparency = 0.4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = body,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		-- Reference: "~ Pack ~" is centred 101 px below the window's top edge.
		new("UIPadding", { PaddingTop = UDim.new(0, 73), PaddingBottom = UDim.new(0, 14) }),
	})
	local refreshPack = PackSection.build(list, 0)
	LimitedSection.build(list, 10, body)
	local refreshPasses = PassSection.build(list, 20, body)
	BoostSection.build(list, 40, body)
	local refreshWins = WinsSection.build(list, 50)
	CodesSection.build(list, 60)
	return function(data)
		refreshPack(data)
		refreshPasses()
		refreshWins(data)
	end
end

return ShopMenu
