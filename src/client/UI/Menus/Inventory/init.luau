-- Inventory window with big tabs down the left, outside the panel (reference
-- "My Stones" layout): Frogs, Pets, Trails, Boosts, Titles. The window title
-- and corner icon follow the tab ("My Pets").

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Window = require(script.Parent.Window)
local Icon = require(script.Parent.Parent.Components.Icon)
local Sfx = require(script.Parent.Parent.Parent.Sfx)
local FrogsTab = require(script.FrogsTab)
local PetsTab = require(script.PetsTab)
local TrailsMenu = require(script.Parent.TrailsMenu)
local BoostsTab = require(script.BoostsTab)
local TitlesTab = require(script.TitlesTab)

local new = Theme.new

local InventoryMenu = {}

local TABS = {
	{ id = "Frogs", label = "Rocks", icon = "gem", build = FrogsTab.build },
	{ id = "Pets", icon = "pets", build = PetsTab.build },
	{ id = "Trails", icon = "trails", build = TrailsMenu.build },
	{ id = "Boosts", icon = "boost", build = BoostsTab.build },
	{ id = "Titles", icon = "title", build = TitlesTab.build },
}

local IDLE = { Color3.fromRGB(82, 81, 88), Color3.fromRGB(58, 57, 64) }
local SELECTED = { Color3.fromRGB(78, 128, 148), Color3.fromRGB(50, 90, 108) }
local SELECTED_EDGE = Color3.fromRGB(120, 205, 235)
local EDGE = Color3.fromRGB(12, 12, 16)

local function tabButton(column: Frame, tab, order: number): (TextButton, GuiObject)
	local button = new("TextButton", {
		Name = tab.id,
		Size = UDim2.new(1, 0, 0, 90),
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
		Parent = column,
	}, { Theme.corner(8), Theme.stroke(3, EDGE) })
	local icon = Icon.new(tab.icon, {
		Size = UDim2.fromOffset(110, 80),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -14),
		ZIndex = 2,
		Parent = button,
	})
	Theme.label({
		Size = UDim2.new(0.92, 0, 0, 48),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -2),
		Text = tab.label or tab.id,
		ZIndex = 3,
		Parent = button,
	})
	local scale = new("UIScale", { Parent = button })
	Theme.hover(button, scale)
	return button, icon
end

function InventoryMenu.build(body: Frame, startTab: string?)
	local frame = body.Parent :: Frame
	local column = new("Frame", {
		Name = "Tabs",
		Size = UDim2.new(0, Window.TabWidth - 10, 1, -26),
		Position = UDim2.new(0, -Window.TabWidth, 0, 26),
		BackgroundTransparency = 1,
		Parent = frame,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 32), -- reference: 245×90 tabs, 32px apart
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local current: { id: string, refresh: (any) -> () }? = nil
	local buttons = {}
	local icons = {}
	local lastData = nil

	local function select(id: string, animate: boolean)
		Window.clear(body)
		for _, tab in TABS do
			local on = tab.id == id
			if on then
				current = { id = id, refresh = tab.build(body) }
				Window.setTitle(frame, `My {tab.label or tab.id}`, if animate then tab.icon else nil)
			end
			Gradient.apply(buttons[tab.id], if on then SELECTED else IDLE)
			buttons[tab.id]:FindFirstChildOfClass("UIStroke").Color = if on then SELECTED_EDGE else EDGE
			if on and animate then
				local scale = icons[tab.id]:FindFirstChildOfClass("UIScale") or new("UIScale", { Parent = icons[tab.id] })
				scale.Scale = 0.7
				TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			end
		end
		if current and lastData then
			current.refresh(lastData)
		end
	end

	for i, tab in TABS do
		local button, icon = tabButton(column, tab, i)
		buttons[tab.id] = button
		icons[tab.id] = icon
		button.Activated:Connect(function()
			if not current or current.id ~= tab.id then
				Sfx.play("Tab")
				select(tab.id, true)
			end
		end)
	end
	local first = startTab or "Frogs"
	for _, tab in TABS do
		if tab.id == first then
			Window.setTitle(frame, `My {tab.label or tab.id}`, tab.icon)
		end
	end
	select(first, false)

	return function(data)
		lastData = data
		if current then
			current.refresh(data)
		end
	end
end

return InventoryMenu
