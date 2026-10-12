-- Left-side button column that opens menus and teleports.

local Theme = require(script.Parent.Parent.Theme)

local new = Theme.new
local C = Theme.Colors

local SideMenu = {}

function SideMenu.init(gui: ScreenGui, openMenu: (string) -> (), teleport: (string) -> ())
	local column = new("Frame", {
		Size = UDim2.fromOffset(110, 330),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.58, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local entries = {
		{ "🐸 Frogs", C.Green, function() openMenu("Frogs") end },
		{ "🐾 Pets", C.Blue, function() openMenu("Pets") end },
		{ "🔁 Rebirth", C.Purple, function() openMenu("Rebirth") end },
		{ "🎁 Codes", C.Gold, function() openMenu("Codes") end },
		{ "💪 Train", C.DarkGreen, function() teleport("Train") end },
		{ "🌊 River", C.Blue, function() teleport("River") end },
	}
	for i, entry in entries do
		local button = Theme.button({
			Size = UDim2.new(1, 0, 0, 46),
			Text = entry[1],
			Color = entry[2],
			LayoutOrder = i,
		}, entry[3])
		button.Parent = column
	end
end

return SideMenu
