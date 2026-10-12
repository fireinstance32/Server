-- Codes: text box + redeem.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local Theme = require(script.Parent.Parent.Theme)
local Window = require(script.Parent.Window)

local new = Theme.new
local C = Theme.Colors

local CodesMenu = {}

function CodesMenu.build(body: Frame)
	Theme.label({
		Size = UDim2.new(1, 0, 0, 40),
		Text = "Enter a code for free rewards!",
		TextColor3 = C.Ink,
		Parent = body,
	})
	local box = new("TextBox", {
		Size = UDim2.new(0.8, 0, 0, 56),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 60),
		BackgroundColor3 = C.White,
		Font = Theme.Font,
		PlaceholderText = "Type code here",
		Text = "",
		TextScaled = true,
		TextColor3 = C.Ink,
		ClearTextOnFocus = false,
		Parent = body,
	}, { Theme.corner(12), Theme.stroke(3), new("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
	local button = Theme.button({
		Size = UDim2.fromOffset(220, 64),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 134),
		Text = "Redeem",
		Color = C.Gold,
	}, function()
		Window.report(Net.func("RedeemCode"):InvokeServer(box.Text))
		box.Text = ""
	end)
	button.Parent = body
	return function() end
end

return CodesMenu
