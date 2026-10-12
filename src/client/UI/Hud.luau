-- Always-on screen: stats, the big HOP button, side menu, toasts and popups.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Format = require(ReplicatedStorage:WaitForChild("Shared").Util.Format)
local Theme = require(script.Parent.Theme)
local State = require(script.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local Hud = {}

local gui: ScreenGui
local hopButton: TextButton
local toastHolder: Frame
local statLabels: { [string]: TextLabel } = {}

local function statRow(order: number, icon: string, color: Color3): (TextLabel, Frame)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = color,
		LayoutOrder = order,
	}, { Theme.corner(12), Theme.stroke(3) })
	Theme.label({
		Size = UDim2.fromOffset(40, 36),
		Position = UDim2.fromOffset(6, 4),
		Text = icon,
		Parent = row,
	})
	local value = Theme.label({
		Size = UDim2.new(1, -56, 0, 34),
		Position = UDim2.fromOffset(50, 5),
		Text = "0",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	return value, row
end

function Hud.setHopButton(text: string, color: Color3)
	hopButton.Text = text
	hopButton.BackgroundColor3 = color
end

function Hud.toast(text: string, color: Color3?)
	local toast = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = color or C.Ink,
		BackgroundTransparency = 0.1,
		Font = Theme.Font,
		Text = text,
		TextColor3 = C.White,
		TextScaled = true,
		Parent = toastHolder,
	}, { Theme.corner(10), new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }) })
	Theme.pop(toast)
	task.delay(2.5, function()
		TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		task.wait(0.3)
		toast:Destroy()
	end)
end

-- "+25" style text that floats up from near the HOP button.
function Hud.floatText(text: string, color: Color3?)
	local label = Theme.label({
		Size = UDim2.fromOffset(220, 50),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5 + (math.random() - 0.5) * 0.2, 0, 0.72, 0),
		Text = text,
		TextColor3 = color or C.Gold,
		Parent = gui,
	})
	Theme.textStroke().Parent = label
	TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = label.Position - UDim2.fromScale(0, 0.18),
		TextTransparency = 1,
	}):Play()
	task.delay(1, function()
		label:Destroy()
	end)
end

-- Big centre-screen announcement, e.g. "ZONE 4!" after a launch.
function Hud.banner(title: string, subtitle: string?, color: Color3?)
	local frame = new("Frame", {
		Size = UDim2.fromScale(0.6, 0.18),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.3),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UISizeConstraint", { MaxSize = Vector2.new(600, 160) }),
	})
	Theme.label({ Size = UDim2.fromScale(1, 0.62), Text = title, TextColor3 = color or C.Gold, Parent = frame })
	if subtitle then
		Theme.label({
			Size = UDim2.fromScale(1, 0.38),
			Position = UDim2.fromScale(0, 0.62),
			Text = subtitle,
			Parent = frame,
		})
	end
	for _, child in frame:GetChildren() do
		if child:IsA("TextLabel") and not child:FindFirstChildOfClass("UIStroke") then
			Theme.textStroke().Parent = child
		end
	end
	Theme.pop(frame)
	task.delay(2.2, function()
		frame:Destroy()
	end)
end

function Hud.init(callbacks: {
	onHop: () -> (),
	openMenu: (string) -> (),
	teleport: (string) -> (),
})
	local player = Players.LocalPlayer
	gui = new("ScreenGui", {
		Name = "FrogHopHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})

	-- Stats (top-left)
	local stats = new("Frame", {
		Size = UDim2.fromOffset(230, 200),
		Position = UDim2.fromOffset(12, 12),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local rows = {
		{ "Hops", "🐸", C.Green },
		{ "Wins", "🏆", C.Gold },
		{ "Rebirths", "🔁", C.Purple },
	}
	for i, row in rows do
		local value, frame = statRow(i, row[2], row[3])
		frame.Parent = stats
		statLabels[row[1]] = value
	end
	statLabels.Multiplier = Theme.label({
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 10,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = stats,
	})

	-- Side menu (left-middle)
	local menu = new("Frame", {
		Size = UDim2.fromOffset(110, 330),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.58, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local entries = {
		{ "🐸 Frogs", C.Green, function() callbacks.openMenu("Frogs") end },
		{ "🐾 Pets", C.Blue, function() callbacks.openMenu("Pets") end },
		{ "🔁 Rebirth", C.Purple, function() callbacks.openMenu("Rebirth") end },
		{ "🎁 Codes", C.Gold, function() callbacks.openMenu("Codes") end },
		{ "💪 Train", C.DarkGreen, function() callbacks.teleport("Train") end },
		{ "🌊 River", C.Blue, function() callbacks.teleport("River") end },
	}
	for i, entry in entries do
		local b = Theme.button({
			Size = UDim2.new(1, 0, 0, 46),
			Text = entry[1],
			Color = entry[2],
			LayoutOrder = i,
		}, entry[3])
		b.Parent = menu
	end

	-- HOP button (bottom-centre)
	hopButton = Theme.button({
		Size = UDim2.fromOffset(260, 90),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Text = "HOP!",
		Color = C.Green,
	}, callbacks.onHop)
	hopButton.Parent = gui

	toastHolder = new("Frame", {
		Size = UDim2.fromOffset(420, 200),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIListLayout", {
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	})

	State.observe(function(data)
		statLabels.Hops.Text = Format.abbreviate(data.hops)
		statLabels.Wins.Text = Format.abbreviate(data.wins)
		statLabels.Rebirths.Text = Format.abbreviate(data.rebirths)
		local hopsMult = Format.multiplier(data.hopsMultiplier)
		local winsMult = Format.multiplier(data.winsMultiplier)
		statLabels.Multiplier.Text = `Hops {hopsMult}  •  Wins {winsMult}`
	end)
end

function Hud.screen(): ScreenGui
	return gui
end

return Hud
