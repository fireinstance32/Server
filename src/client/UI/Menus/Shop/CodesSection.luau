-- "~ Codes ~": text box + Redeem, at the bottom of the Shop.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local CodesSection = {}

function CodesSection.build(list: ScrollingFrame, order: number)
	Window.header(list, "Codes", order)
	local row = Window.card(list, order + 1)
	row.Size = UDim2.new(1, -10, 0, 80)

	local box = new("TextBox", {
		Size = UDim2.new(1, -220, 0, 56),
		Position = UDim2.fromOffset(12, 12),
		BackgroundColor3 = Color3.fromRGB(30, 30, 36),
		Font = Theme.Font,
		PlaceholderText = "Enter code...",
		PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		Text = "",
		TextScaled = true,
		TextColor3 = Theme.Colors.White,
		ClearTextOnFocus = false,
		Parent = row,
	}, { Theme.corner(10), Theme.stroke(3), new("UIPadding", { PaddingLeft = UDim.new(0, 12) }) })

	local redeem = Window.button({
		Size = UDim2.fromOffset(180, 56),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Text = "Redeem",
	}, "Yellow", function()
		local ok, message = Net.func("RedeemCode"):InvokeServer(box.Text)
		Window.report(ok, message)
		if ok then
			box.Text = ""
		end
	end)
	redeem.Parent = row
end

return CodesSection
