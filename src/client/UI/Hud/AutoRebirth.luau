-- AUTO REBIRTH toggle. Only shown while training (reference behaviour).
-- When owned and switched on, rebirths automatically at MAX LEVEL; the server
-- still validates every rebirth.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)
local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)
local Studs = require(script.Parent.Parent.Components.Studs)
local Icon = require(script.Parent.Parent.Components.Icon)
local Purchases = require(script.Parent.Parent.Parent.Purchases)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local AutoRebirth = {}

local button: TextButton
local enabled = false
local requesting = false

function AutoRebirth.setVisible(visible: boolean)
	if button then
		button.Visible = visible
	end
end

function AutoRebirth.init(parent: Frame)
	button = new("TextButton", {
		Name = "AutoRebirth",
		Size = UDim2.fromOffset(230, 64),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 0, -14),
		Text = "",
		AutoButtonColor = true,
		Visible = false,
		Parent = parent,
	}, { Theme.corner(12), Theme.stroke(3) })
	Gradient.apply(button, "Purple")
	Studs.apply(button, 22, 0.45)
	Icon.new("rebirth", { Size = UDim2.fromOffset(64, 64), Position = UDim2.fromOffset(-14, -10), Rotation = -10, ZIndex = 2, Parent = button })
	Theme.label({
		Size = UDim2.new(1, -60, 0.55, 0),
		Position = UDim2.new(0, 52, 0.05, 0),
		Text = "AUTO REBIRTH",
		ZIndex = 3,
		Parent = button,
	})
	local label = Theme.label({
		Size = UDim2.new(1, -60, 0.38, 0),
		Position = UDim2.new(0, 52, 0.58, 0),
		Text = "",
		TextColor3 = Theme.Colors.Gold,
		ZIndex = 3,
		Parent = button,
	})
	Theme.textStroke().Parent = label

	local function refresh()
		if not Purchases.owns("AutoRebirth") then
			label.Text = `ONLY \u{E002} {Purchases.price("pass", "AutoRebirth")}`
		else
			label.Text = if enabled then "ON" else "OFF"
		end
		Gradient.apply(button, if enabled then "Green" else "Purple")
	end

	button.Activated:Connect(function()
		if not Purchases.owns("AutoRebirth") then
			Purchases.pass("AutoRebirth")
			return
		end
		enabled = not enabled
		refresh()
	end)

	State.observe(function(data)
		refresh()
		if enabled and not requesting and Purchases.owns("AutoRebirth") and data.level >= data.levelCap then
			requesting = true
			task.spawn(function()
				pcall(function()
					Net.func("Rebirth"):InvokeServer()
				end)
				requesting = false
			end)
		end
	end)
end

return AutoRebirth
