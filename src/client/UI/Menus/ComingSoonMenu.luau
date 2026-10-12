-- Placeholder window for menus whose systems come in later phases.

local Theme = require(script.Parent.Parent.Theme)

local ComingSoonMenu = {}

function ComingSoonMenu.build(body: Frame, phase: string)
	Theme.label({
		Size = UDim2.fromScale(1, 0.25),
		Position = UDim2.fromScale(0, 0.3),
		Text = "Coming soon!",
		Parent = body,
	})
	Theme.label({
		Size = UDim2.fromScale(1, 0.12),
		Position = UDim2.fromScale(0, 0.58),
		Text = phase,
		TextColor3 = Theme.Colors.Grey,
		Parent = body,
	})
	return function() end
end

return ComingSoonMenu
