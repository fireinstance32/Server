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
local DistanceMeter = require(script.DistanceMeter)
local PotionTimers = require(script.PotionTimers)
local TopRight = require(script.TopRight)
local QuestBar = require(script.QuestBar)
local TipTicker = require(script.TipTicker)
local EventBanner = require(script.EventBanner)

local Hud = {}

local gui: ScreenGui
local hopButton: TextButton

Hud.toast = Popups.toast
Hud.floatText = Popups.floatText
Hud.banner = Popups.banner
Hud.distance = DistanceMeter

-- mode: "Train" (with the pond), "Launch", or nil. Training is automatic,
-- so the button only shows at the dock, or on a locked pond to explain or
-- sell it.
function Hud.setHopMode(mode: string?, pond: any?, locked: boolean?)
	AutoRebirth.setVisible(mode == "Train")
	hopButton.Visible = mode == "Launch" or (mode == "Train" and locked == true)
	if mode == "Launch" then
		hopButton.Text = "HOP! 🐸"
		Gradient.apply(hopButton, "Blue")
	elseif mode == "Train" and locked and pond then
		hopButton.Text = if pond.pass
			then `UNLOCK \u{E002}{Purchases.price("pass", pond.pass)}`
			else `🔒 {pond.rebirths} REBIRTHS`
		Gradient.apply(hopButton, if pond.pass then "Green" else "Grey")
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
	DistanceMeter.init(gui)
	PotionTimers.init(gui)
	TopRight.init(gui, callbacks.openMenu)
	EventBanner.init(gui)
	QuestBar.init(gui)
	TipTicker.init(gui)
	Popups.init(gui)

	Purchases.onNotForSale(function(text)
		Popups.toast(text, Theme.Colors.Ink)
	end)
end

return Hud
