-- Inventory › Titles (reference "My Titles"): "3 / 27 Titles", the worn
-- title, and a grid of cards with a rarity border, bonus line, progress bar
-- and lock. Click an unlocked card to wear it, click the worn one to remove it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Titles = require(Shared.Config.Titles)
local Pets = require(Shared.Config.Pets)
local Format = require(Shared.Util.Format)
local Signature = require(Shared.Util.Signature)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Theme)
local Gradient = require(script.Parent.Parent.Parent.Components.Gradient)
local Icon = require(script.Parent.Parent.Parent.Components.Icon)
local Window = require(script.Parent.Parent.Window)

local new = Theme.new

local TitlesTab = {}

local function key(data): string
	local progress = {}
	for _, t in Titles.List do
		progress[t.id] = (Titles.progress(t, data))
	end
	return Signature.of(data.titles, data.equippedTitle, progress)
end

local function progressBar(parent: Instance, current: number, target: number, color: Color3)
	local bar = new("Frame", {
		Name = "Progress",
		Size = UDim2.new(1, -20, 0, 20),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -10),
		BackgroundColor3 = Color3.fromRGB(24, 24, 30),
		Parent = parent,
	}, { Theme.corner(10), Theme.stroke(2) })
	local fill = new("Frame", {
		Size = UDim2.fromScale(math.clamp(current / target, 0, 1), 1),
		BackgroundColor3 = color,
		Visible = current > 0,
		Parent = bar,
	}, { Theme.corner(10) })
	Gradient.apply(fill, { color:Lerp(Color3.new(1, 1, 1), 0.35), color })
	Theme.label({
		Size = UDim2.fromScale(1, 1.1),
		Position = UDim2.fromScale(0, -0.05),
		Text = `{Format.abbreviate(current)} / {Format.abbreviate(target)}`,
		ZIndex = 3,
		Parent = bar,
	})
end

local function card(grid: Instance, order: number, t: Titles.Title, data: any)
	local unlocked = data.titles and data.titles[t.id] == true
	local worn = data.equippedTitle == t.id
	local rarity = Pets.RarityColors[t.rarity] or Color3.new(1, 1, 1)

	local button = new("TextButton", {
		Name = t.id,
		Text = "",
		AutoButtonColor = unlocked,
		BackgroundColor3 = Window.CardColor,
		LayoutOrder = order,
		Parent = grid,
	}, { Theme.corner(14) })
	Gradient.apply(button, if unlocked then { Color3.fromRGB(78, 80, 96), Color3.fromRGB(46, 47, 58) } else "Grey")
	local border = Theme.stroke(4, if unlocked then rarity else rarity:Lerp(Color3.new(0, 0, 0), 0.45))
	border.Parent = button

	local name = Theme.label({
		Size = UDim2.new(1, -16, 0, 34),
		Position = UDim2.fromOffset(8, 8),
		Text = t.name,
		TextColor3 = if unlocked then rarity else rarity:Lerp(Color3.fromRGB(150, 150, 150), 0.5),
		Parent = button,
	})
	Theme.textStroke(3).Parent = name
	Theme.label({
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.fromOffset(8, 42),
		Text = t.rarity,
		TextColor3 = Color3.fromRGB(200, 200, 210),
		Parent = button,
	})

	-- Bonus line: icon + "+4 Hops" / "x1.2 Wins".
	local bonus = new("Frame", {
		Size = UDim2.new(1, -16, 0, 30),
		Position = UDim2.fromOffset(8, 64),
		BackgroundTransparency = 1,
		Parent = button,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),
	})
	Icon.new(if t.stat == "hops" then "bolt" else "trophy", { Size = UDim2.fromOffset(28, 28), LayoutOrder = 1, Parent = bonus })
	local bonusText = Theme.label({
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = Titles.bonusText(t),
		TextColor3 = Color3.fromRGB(120, 245, 90),
		LayoutOrder = 2,
		Parent = bonus,
	})
	Theme.textStroke(3).Parent = bonusText

	Theme.label({
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.fromOffset(8, 98),
		Text = Titles.describe(t),
		TextColor3 = Color3.fromRGB(225, 225, 235),
		Parent = button,
	})

	if unlocked then
		local _, target = Titles.progress(t, data)
		progressBar(button, target, target, Color3.fromRGB(80, 210, 70))
	else
		local current, target = Titles.progress(t, data)
		progressBar(button, current, target, Color3.fromRGB(70, 160, 255))
		Icon.new("lock", {
			Size = UDim2.fromOffset(40, 40),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -8, 0, 8),
			Rotation = 12,
			ZIndex = 4,
			Parent = button,
		})
	end
	if worn then
		Icon.new("check", {
			Size = UDim2.fromOffset(40, 40),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -8, 0, 8),
			ZIndex = 4,
			Parent = button,
		})
	end

	if unlocked then
		local scale = new("UIScale", { Parent = button })
		Theme.hover(button, scale)
		button.Activated:Connect(function()
			Window.report(Net.func("EquipTitle"):InvokeServer(if worn then "" else t.id))
		end)
	end
end

function TitlesTab.build(content: Frame)
	local header = new("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent = content,
	})
	local count = Theme.label({
		Size = UDim2.new(0.45, -120, 1, 0),
		Position = UDim2.fromOffset(120, 0),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	local wearing = Theme.label({
		Size = UDim2.fromScale(0.55, 0.8),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 1, -48),
		Position = UDim2.fromOffset(0, 48),
		BackgroundColor3 = Color3.fromRGB(28, 29, 36),
		BackgroundTransparency = 0.1,
		Parent = content,
	}, { Theme.corner(16), Theme.stroke(4, Color3.fromRGB(12, 12, 16)) })
	local grid = Window.grid(holder, 200, 160)
	grid.Size = UDim2.new(1, -16, 1, -16)
	grid.Position = UDim2.fromOffset(8, 8)

	return Signature.guard(key, function(data)
		local owned = 0
		for _ in data.titles or {} do
			owned += 1
		end
		count.Text = `{owned} / {#Titles.List} Titles`
		local worn = Titles.ById[data.equippedTitle or ""]
		wearing.Text = if worn then `Wearing: {worn.name}` else "No title equipped"
		wearing.TextColor3 = if worn then Pets.RarityColors[worn.rarity] or Theme.Colors.White else Color3.fromRGB(200, 200, 210)

		Window.clear(grid)
		-- Unlocked first (rarest first), then locked by closest to done.
		local order = table.clone(Titles.List)
		table.sort(order, function(a, b)
			local ua, ub = data.titles and data.titles[a.id] or false, data.titles and data.titles[b.id] or false
			if ua ~= ub then
				return ua
			end
			local ra, rb = Pets.RarityOrder[a.rarity] or 0, Pets.RarityOrder[b.rarity] or 0
			if ua then
				return if ra ~= rb then ra > rb else a.name < b.name
			end
			local ca, ta = Titles.progress(a, data)
			local cb, tb = Titles.progress(b, data)
			local pa, pb = ca / ta, cb / tb
			return if pa ~= pb then pa > pb else ra < rb
		end)
		for i, t in order do
			card(grid, i, t, data)
		end
	end)
end

return TitlesTab
