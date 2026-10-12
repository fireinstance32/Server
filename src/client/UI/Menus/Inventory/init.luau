-- Inventory window with tabs down the left (reference "My Pets" layout):
-- Frogs, Pets, Trails, Boosts, Titles. Pets/Inventory buttons open different tabs.

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Window = require(script.Parent.Window)
local Icon = require(script.Parent.Parent.Components.Icon)
local FrogsTab = require(script.FrogsTab)
local PetsTab = require(script.PetsTab)
local TrailsMenu = require(script.Parent.TrailsMenu)
local BoostsTab = require(script.BoostsTab)
local TitlesTab = require(script.TitlesTab)

local new = Theme.new

local InventoryMenu = {}

local TABS = {
	{ id = "Frogs", icon = "frog", build = FrogsTab.build },
	{ id = "Pets", icon = "pets", build = PetsTab.build },
	{ id = "Trails", icon = "trails", build = TrailsMenu.build },
	{ id = "Boosts", icon = "boost", build = BoostsTab.build },
	{ id = "Titles", icon = "title", build = TitlesTab.build },
}

function InventoryMenu.build(body: Frame, startTab: string?)
	local tabColumn = new("Frame", {
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundTransparency = 1,
		Parent = body,
	}, { new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local content = new("Frame", {
		Size = UDim2.new(1, -170, 1, 0),
		Position = UDim2.fromOffset(170, 0),
		BackgroundTransparency = 1,
		Parent = body,
	})

	local current: { id: string, refresh: (any) -> () }? = nil
	local buttons = {}
	local lastData = nil

	local function select(id: string)
		Window.clear(content)
		for _, tab in TABS do
			if tab.id == id then
				current = { id = id, refresh = tab.build(content) }
			end
			Gradient.apply(buttons[tab.id], if tab.id == id then "Blue" else "Tile")
		end
		if current and lastData then
			current.refresh(lastData)
		end
	end

	for i, tab in TABS do
		local button = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 74),
			Text = "",
			LayoutOrder = i,
			Parent = tabColumn,
		}, { Theme.corner(12), Theme.stroke(3) })
		Icon.new(tab.icon, { Size = UDim2.fromScale(0.62, 0.7), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, -0.08), Parent = button })
		Theme.label({ Size = UDim2.fromScale(0.9, 0.36), Position = UDim2.fromScale(0.05, 0.6), Text = tab.id, Parent = button })
		buttons[tab.id] = button
		button.Activated:Connect(function()
			select(tab.id)
		end)
	end
	select(startTab or "Frogs")

	return function(data)
		lastData = data
		if current then
			current.refresh(data)
		end
	end
end

return InventoryMenu
