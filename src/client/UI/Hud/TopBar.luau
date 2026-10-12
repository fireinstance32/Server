-- Top-centre AUTO HOP button: "ONLY ◎ 23" until owned, then an ON/OFF toggle.
-- Also reserves the quest bar slot under it (filled by Phase 3.1).

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local TopBar = {}

function TopBar.init(gui: ScreenGui, setAutoHop: (boolean) -> ())
	local enabled = false

	local button = new("TextButton", {
		Name = "AutoHop",
		Size = UDim2.fromOffset(250, 70),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Text = "",
		AutoButtonColor = true,
		Parent = gui,
	}, { Theme.corner(12), Theme.stroke(4) })
	Gradient.apply(button, "Red")
	Theme.label({
		Size = UDim2.new(0.9, 0, 0.55, 0),
		Position = UDim2.fromScale(0.05, 0.04),
		Text = "AUTO HOP",
		Parent = button,
	})
	local status = Theme.label({
		Size = UDim2.new(0.9, 0, 0.36, 0),
		Position = UDim2.fromScale(0.05, 0.6),
		Text = "",
		TextColor3 = C.Gold,
		Font = Enum.Font.BuilderSansBold,
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

	-- Reserved for the tutorial quest bar (Phase 3.1).
	new("Frame", {
		Name = "QuestSlot",
		Size = UDim2.fromOffset(600, 70),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 86),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	State.observe(refresh)
end

return TopBar
