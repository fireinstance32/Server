-- Always-on screen (PC layout, from docs/Research/HUD References). Builds the
-- ScreenGui; each region lives in its own module in this folder. Other code
-- talks to the HUD only through the functions below.
--
--   top-centre    TopBar (Auto Hop, quest slot)       Popups (toasts)
--   left-middle   IconGrid (Shop, Rebirth, Pets, Trails, Inventory, Gifts)
--   right-middle  PassColumn (Starter Pack, pass cards)
--   bottom-centre StatRow · LevelBar · PackRow, HOP button above
--   bottom-left   BottomLeft (Rebirths, Wins, Friend Boost)

local Players = game:GetService("Players")

local Theme = require(script.Parent.Theme)
local Gradient = require(script.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Purchases)
local Popups = require(script.Popups)
local StatRow = require(script.StatRow)
local LevelBar = require(script.LevelBar)
local PackRow = require(script.PackRow)
local BottomLeft = require(script.BottomLeft)
local IconGrid = require(script.IconGrid)
local PassColumn = require(script.PassColumn)
local TopBar = require(script.TopBar)
local AutoRebirth = require(script.AutoRebirth)

local Hud = {}

local gui: ScreenGui
local hopButton: TextButton

Hud.toast = Popups.toast
Hud.floatText = Popups.floatText
Hud.banner = Popups.banner

-- mode: "Train", "Launch" or nil (not at a hop spot → button hidden).
function Hud.setHopMode(mode: string?)
	hopButton.Visible = mode ~= nil
	AutoRebirth.setVisible(mode == "Train")
	if mode == "Launch" then
		hopButton.Text = "HOP! 🐸"
		Gradient.apply(hopButton, "Blue")
	elseif mode == "Train" then
		hopButton.Text = "TRAIN 💪"
		Gradient.apply(hopButton, "Green")
	end
end

function Hud.screen(): ScreenGui
	return gui
end

function Hud.init(callbacks: {
	onHop: () -> (),
	openMenu: (string) -> (),
	setAutoHop: (boolean) -> (),
})
	gui = Theme.new("ScreenGui", {
		Name = "FrogHopHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Bottom-centre stack: stat row (40) · level bar (60) · packs (72).
	local bottom = Theme.new("Frame", {
		Name = "BottomBar",
		Size = UDim2.fromOffset(760, 184),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	StatRow.init(bottom)
	LevelBar.init(bottom, 44, 60)
	PackRow.init(bottom, 112, 72)
	AutoRebirth.init(bottom)

	hopButton = Theme.button({
		Name = "HopButton",
		Size = UDim2.fromOffset(260, 84),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -216),
		Text = "HOP!",
		Visible = false,
	}, callbacks.onHop)
	hopButton.Parent = gui

	BottomLeft.init(gui)
	IconGrid.init(gui, callbacks.openMenu)
	PassColumn.init(gui, callbacks.openMenu)
	TopBar.init(gui, callbacks.setAutoHop)
	Popups.init(gui)

	Purchases.onNotForSale(function(text)
		Popups.toast(text, Theme.Colors.Ink)
	end)
end

return Hud
