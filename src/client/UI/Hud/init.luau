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
local ScreenScale = require(script.Parent.Components.ScreenScale)
local Purchases = require(script.Parent.Parent.Purchases)
local Popups = require(script.Popups)
local RewardPopup = require(script.RewardPopup)
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
local Layout = require(script.Parent.Menus.Window.Layout)

local Hud = {}

local gui: ScreenGui
local hopButton: TextButton

Hud.toast = Popups.toast
Hud.floatText = Popups.floatText
Hud.banner = Popups.banner
Hud.reward = RewardPopup.show
Hud.distance = DistanceMeter

-- mode: "Train" (with the pond), "Launch", or nil. Training is automatic,
-- so the button only shows at the dock, or on a locked pond to explain or
-- sell it.
function Hud.setHopMode(mode: string?, pond: any?, locked: boolean?)
	AutoRebirth.setVisible(mode == "Train")
	hopButton.Visible = mode == "Launch" or (mode == "Train" and locked == true)
	if mode == "Launch" then
		Theme.setText(hopButton, "HOP")
		Layout.recolor(hopButton, "Green")
	elseif mode == "Train" and locked and pond then
		Theme.setText(
			hopButton,
			if pond.pass then `UNLOCK \u{E002}{Purchases.price("pass", pond.pass)}` else `🔒 {pond.rebirths} REBIRTHS`
		)
		Layout.recolor(hopButton, if pond.pass then "Green" else "Grey")
	end
end

function Hud.screen(): ScreenGui
	return gui
end

-- While a menu is open the whole HUD is hidden (reference: only the window
-- over the blurred world); toasts live in their own ScreenGui and stay.
function Hud.setMenuOpen(open: boolean)
	Popups.setMenuOpen(open)
	gui.Enabled = not open
end

function Hud.init(callbacks: {
	onHop: () -> (),
	openMenu: (string) -> (), -- toggles
	autoOpenMenu: ((string) -> ())?, -- opens only if no menu is open
	setAutoHop: (boolean) -> (),
})
	gui = Theme.new("ScreenGui", {
		Name = "FrogHopHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})
	ScreenScale.attach(gui)

	-- Bottom-centre stack, reference proportions at 1080p: stat row (44) ·
	-- level bar (88) · packs (80), ~97 px off the bottom edge.
	local bottom = Theme.new("Frame", {
		Name = "BottomBar",
		Size = UDim2.fromOffset(870, 236),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -97),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	StatRow.init(bottom)
	LevelBar.init(bottom, 56, 88)
	PackRow.init(bottom, 156, 80)
	AutoRebirth.init(bottom)

	-- Green "THROW"-style button on the Hop Zone (reference).
	hopButton = Layout.button({
		Name = "HopButton",
		Size = UDim2.fromOffset(250, 92),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -340),
		Text = "HOP",
		Visible = false,
	}, "Green", callbacks.onHop)
	hopButton.Parent = gui

	BottomLeft.init(gui)
	IconGrid.init(gui, callbacks.openMenu)
	PassColumn.init(gui, callbacks.openMenu)
	TopBar.init(gui, callbacks.setAutoHop)
	DistanceMeter.init(gui)
	PotionTimers.init(gui)
	TopRight.init(gui, callbacks.openMenu, callbacks.autoOpenMenu)
	EventBanner.init(gui)
	QuestBar.init(gui)
	TipTicker.init(gui)
	-- Toasts and banners draw above menu windows (DisplayOrder 10).
	local popups = Theme.new("ScreenGui", {
		Name = "FrogHopPopups",
		ResetOnSpawn = false,
		DisplayOrder = 20,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})
	ScreenScale.attach(popups)
	Theme.useFont(popups, Theme.MenuFont) -- toasts + reward pop-ups (reference)
	Popups.init(popups)
	RewardPopup.init(popups)

	Purchases.onNotForSale(function(text)
		Popups.toast(text, Theme.Colors.Ink)
	end)
end

return Hud
