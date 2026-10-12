-- Rainbow line in a dark box at the very top that only shows while the
-- Roblox escape menu is open (reference: "You'll still train offline even
-- if you log out") — a last reminder before someone leaves.

local GuiService = game:GetService("GuiService")

local Theme = require(script.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Components.Gradient)

local TipTicker = {}

local MESSAGE = "You'll still train offline even if you log out!"

function TipTicker.init(gui: ScreenGui)
	local box = Theme.new("Frame", {
		Name = "TipTicker",
		Size = UDim2.fromOffset(800, 54),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(18, 18, 24),
		BackgroundTransparency = 0.3,
		Visible = GuiService.MenuIsOpen,
		Parent = gui,
	}, { Theme.corner(8), Theme.stroke(2, Color3.fromRGB(70, 70, 80)) })
	local label = Theme.label({
		Size = UDim2.new(1, -30, 0.74, 0),
		Position = UDim2.new(0, 15, 0.13, 0),
		Text = MESSAGE,
		TextColor3 = Color3.new(1, 1, 1),
		Parent = box,
	})
	local gradient = Gradient.apply(label, "Rainbow")
	label.BackgroundTransparency = 1

	GuiService.MenuOpened:Connect(function()
		box.Visible = true
	end)
	GuiService.MenuClosed:Connect(function()
		box.Visible = false
	end)
	-- Slide the rainbow across the text while it's showing.
	task.spawn(function()
		local step = 0
		while box.Parent do
			if box.Visible then
				step += 1
				gradient.Offset = Vector2.new(math.sin(step / 10) * 0.3, 0)
			end
			task.wait(0.1)
		end
	end)
end

return TipTicker
