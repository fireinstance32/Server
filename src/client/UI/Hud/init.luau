-- Always-on screen. Builds the ScreenGui and its parts; each part lives in
-- its own module in this folder. Other code talks to the HUD only via the
-- functions below.

local Players = game:GetService("Players")

local Theme = require(script.Parent.Theme)
local Popups = require(script.Popups)
local StatsPanel = require(script.StatsPanel)
local LevelBar = require(script.LevelBar)
local SideMenu = require(script.SideMenu)

local Hud = {}

local gui: ScreenGui
local hopButton: TextButton

Hud.toast = Popups.toast
Hud.floatText = Popups.floatText
Hud.banner = Popups.banner

function Hud.setHopButton(text: string, color: Color3)
	hopButton.Text = text
	hopButton.BackgroundColor3 = color
end

function Hud.screen(): ScreenGui
	return gui
end

function Hud.init(callbacks: {
	onHop: () -> (),
	openMenu: (string) -> (),
	teleport: (string) -> (),
})
	gui = Theme.new("ScreenGui", {
		Name = "FrogHopHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	StatsPanel.init(gui)
	SideMenu.init(gui, callbacks.openMenu, callbacks.teleport)
	LevelBar.init(gui)

	hopButton = Theme.button({
		Size = UDim2.fromOffset(260, 90),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Text = "HOP!",
		Color = Theme.Colors.Green,
	}, callbacks.onHop)
	hopButton.Parent = gui

	Popups.init(gui)
end

return Hud
