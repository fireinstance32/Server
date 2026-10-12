-- My Pets toolbar (reference): Auto Delete (opens rarity toggles above the
-- bar), Delete Unequipped (press twice), Equip Best, and Sort.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local Icon = require(script.Parent.Parent.Parent.Parent.Components.Icon)
local Window = require(script.Parent.Parent.Parent.Window)

local new = Theme.new

local Toolbar = {}

local AUTO_DELETE = { "Common", "Uncommon", "Rare", "Epic" }

-- Square studded button with an icon and a small caption under it.
local function iconButton(parent: Instance, order: number, icon: string, caption: string, color: string, onClick: () -> ()): TextButton
	local button = Window.button({
		Size = UDim2.fromOffset(64, 52),
		Text = "",
		LayoutOrder = order,
	}, color, onClick)
	button.Parent = parent
	Icon.new(icon, {
		Size = UDim2.fromScale(0.62, 0.72),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.02),
		ZIndex = 4,
		Parent = button,
	})
	Theme.label({
		Name = "Caption",
		Size = UDim2.new(1.2, 0, 0, 18),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 4),
		Text = caption,
		ZIndex = 5,
		Parent = button,
	})
	return button
end

-- `onSort` cycles the sort mode and returns its new name.
function Toolbar.build(parent: Instance, getData: () -> any, onSort: () -> string): (Frame, (any) -> ())
	local bar = new("Frame", {
		Name = "Toolbar",
		Size = UDim2.new(1, 0, 0, 56),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- Auto Delete pop-over: one toggle per rarity, above the toolbar.
	local popover = Window.inset(parent, {
		Name = "AutoDelete",
		Size = UDim2.fromOffset(420, 92),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -64),
		ZIndex = 6,
		Visible = false,
	})
	Theme.label({ Size = UDim2.new(1, 0, 0, 24), Text = "Auto Delete new pets:", ZIndex = 7, Parent = popover })
	local chipRow = new("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.fromOffset(0, 28),
		BackgroundTransparency = 1,
		ZIndex = 7,
		Parent = popover,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local chips = {}
	for i, rarity in AUTO_DELETE do
		local chip = Window.button({
			Size = UDim2.fromOffset(92, 42),
			Text = rarity,
			LayoutOrder = i,
			ZIndex = 7,
		}, "Grey", function()
			local data = getData()
			local on = data and data.autoDelete and data.autoDelete[rarity]
			Window.report(Net.func("SetAutoDelete"):InvokeServer(rarity, not on))
		end)
		chip.Parent = chipRow
		chips[rarity] = chip
	end

	local autoButton = iconButton(bar, 1, "trash", "Auto", "Grey", function()
		popover.Visible = not popover.Visible
	end)

	-- First press arms, second confirms. `presses` counts arming presses so a
	-- stale timeout from an earlier one can't disarm a later one.
	local armed = false
	local presses = 0
	local deleteButton: TextButton
	local function setArmed(on: boolean)
		armed = on
		local caption = deleteButton:FindFirstChild("Caption") :: TextLabel?
		if not caption then
			return -- the tab was closed meanwhile
		end
		caption.Text = if on then "Sure?" else "Delete"
		Window.recolor(deleteButton, if on then "Yellow" else "Red")
	end
	deleteButton = iconButton(bar, 2, "trash", "Delete", "Red", function()
		if not armed then
			setArmed(true)
			presses += 1
			local press = presses
			task.delay(2.5, function()
				if armed and press == presses then
					setArmed(false)
				end
			end)
			return
		end
		setArmed(false)
		local data = getData()
		local uids = {}
		for uid, pet in (data and data.pets or {}) do
			if not pet.equipped and not pet.locked then
				table.insert(uids, uid)
			end
		end
		Window.report(Net.func("DeletePets"):InvokeServer(uids))
	end)

	local equipBest = Window.button({
		Size = UDim2.fromOffset(150, 52),
		Text = "Equip Best",
		LayoutOrder = 3,
	}, "Green", function()
		Window.report(Net.func("EquipBestPets"):InvokeServer())
	end)
	equipBest.Parent = bar

	local sortButton: TextButton
	sortButton = iconButton(bar, 4, "sort", "Best", "Blue", function()
		(sortButton:FindFirstChild("Caption") :: TextLabel).Text = onSort()
	end)

	return bar, function(data)
		local any = false
		for rarity, chip in chips do
			local on = data.autoDelete and data.autoDelete[rarity] == true
			any = any or on
			Window.recolor(chip, if on then "Red" else "Grey")
		end
		Window.recolor(autoButton, if any then "Yellow" else "Grey")
	end
end

return Toolbar
