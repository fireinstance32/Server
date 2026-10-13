-- Top-centre AUTO HOP button: "ONLY ◎ 23" until owned, then an ON/OFF toggle.
-- It shares its slot with the tutorial bar, so it shows once the tutorial
-- is done (reference: AUTO THROW and the tutorial never show together).

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Components.Icon)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local TopBar = {}

function TopBar.init(gui: ScreenGui, setAutoHop: (boolean) -> ())
	local enabled = false

	local button = new("TextButton", {
		Name = "AutoHop",
		Size = UDim2.fromOffset(250, 72),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 100),
		Text = "",
		AutoButtonColor = true,
		Parent = gui,
	}, { Theme.corner(12), Theme.stroke(4) })
	Gradient.apply(button, "Red")
	Studs.apply(button, 22)
	Icon.new("crown", {
		Size = UDim2.fromOffset(78, 78),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 2),
		ZIndex = 2,
		Parent = button,
	})
	Theme.label({
		Size = UDim2.new(0.9, 0, 0.55, 0),
		Position = UDim2.fromScale(0.05, 0.06),
		Text = "AUTO LIFT",
		ZIndex = 3,
		Parent = button,
	})
	local status = Theme.label({
		Size = UDim2.new(0.9, 0, 0.36, 0),
		Position = UDim2.fromScale(0.05, 0.6),
		Text = "",
		TextColor3 = C.Gold,
		ZIndex = 3,
		Parent = button,
	})
	Theme.textStroke().Parent = status

	local function refresh()
		if not Purchases.owns("AutoHop") then
			status.Text = `ONLY \u{E002} {Purchases.price("pass", "AutoHop")}`
			Gradient.apply(button, "Red")
		else
			status.Text = if enabled then "ON" else "OFF"
			Gradient.apply(button, if enabled then "Green" else "Grey")
		end
	end

	button.Activated:Connect(function()
		if not Purchases.owns("AutoHop") then
			Purchases.pass("AutoHop")
			return
		end
		enabled = not enabled
		setAutoHop(enabled)
		refresh()
	end)

	State.observe(function(data)
		button.Visible = data.quest == nil
		refresh()
	end)
end

return TopBar
