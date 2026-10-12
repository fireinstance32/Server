-- Left panel of My Pets (reference): the selected pet's name, a big picture
-- on spinning rays, rarity, ⚡ bonus, EQUIP / UNEQUIP, lock and delete.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local Icon = require(script.Parent.Parent.Parent.Parent.Components.Icon)
local PetImage = require(script.Parent.Parent.Parent.Parent.Components.PetImage)
local Rays = require(script.Parent.Parent.Parent.Parent.Components.Rays)
local Window = require(script.Parent.Parent.Parent.Window)
local PetTile = require(script.Parent.PetTile)

local new = Theme.new

local Details = {}

export type Selection = { uid: string, pet: any }?

-- Returns the panel and show(selection) to fill it (nil = nothing to show).
function Details.build(parent: Instance, props: { [string]: any }): (Frame, (Selection) -> ())
	local panel = Window.inset(parent, props)
	local name = Theme.label({
		Size = UDim2.new(1, 0, 0, 36),
		Text = "",
		ZIndex = 3,
		Parent = panel,
	})
	local stage = new("Frame", {
		Size = UDim2.new(1, 0, 0.44, 0),
		Position = UDim2.fromOffset(0, 38),
		BackgroundTransparency = 1,
		Parent = panel,
	})
	local rays = Rays.new({ Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Parent = stage })
	local picture: GuiObject? = nil
	local rarity = Theme.label({
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0.44, 42),
		Text = "",
		Parent = panel,
	})
	Theme.textStroke(3).Parent = rarity
	local bonusHolder = new("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0.44, 72),
		BackgroundTransparency = 1,
		Parent = panel,
	})
	local empty = Theme.label({
		Size = UDim2.new(1, -10, 0, 60),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.4),
		Text = "Hatch an egg to get your first pet!",
		TextWrapped = true,
		Visible = false,
		Parent = panel,
	})

	local current: Selection = nil
	local equip = Window.button({
		Size = UDim2.new(1, 0, 0, 50),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -54),
		Text = "EQUIP",
	}, "Green", function()
		local sel = current
		if sel then
			local ok, message = Net.func(if sel.pet.equipped then "UnequipPet" else "EquipPet"):InvokeServer(sel.uid)
			if not ok then
				Window.report(ok, message)
			end
		end
	end)
	equip.Parent = panel

	local lock = Window.button({
		Size = UDim2.new(0.5, -4, 0, 46),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Text = "",
	}, "Grey", function()
		local sel = current
		if sel then
			Window.report(Net.func("LockPet"):InvokeServer(sel.uid, not sel.pet.locked))
		end
	end)
	lock.Parent = panel
	Icon.new("lock", { Size = UDim2.fromScale(0.8, 0.8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 4, Parent = lock })
	local delete = Window.button({
		Size = UDim2.new(0.5, -4, 0, 46),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Text = "",
	}, "Red", function()
		local sel = current
		if sel and not sel.pet.locked then
			Window.report(Net.func("DeletePets"):InvokeServer({ sel.uid }))
		end
	end)
	delete.Parent = panel
	Icon.new("trash", { Size = UDim2.fromScale(0.8, 0.8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 4, Parent = delete })

	local shownId: string? = nil
	local function show(selection: Selection)
		current = selection
		local def = selection and Pets.ById[selection.pet.id]
		for _, item in { name, stage, rarity, bonusHolder, equip, lock, delete } do
			item.Visible = def ~= nil
		end
		empty.Visible = def == nil
		if not selection or not def then
			return
		end
		local color = Pets.RarityColors[def.rarity]
		name.Text = def.name
		rarity.Text = def.rarity
		rarity.TextColor3 = color
		for _, bar in rays:GetDescendants() do
			if bar:IsA("Frame") and bar.BackgroundTransparency < 1 then
				bar.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.45)
			end
		end
		if shownId ~= selection.uid then
			shownId = selection.uid
			if picture then
				picture:Destroy()
			end
			picture = PetImage.new("pet", def.id, {
				Size = UDim2.fromScale(0.86, 0.86),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 3,
				Parent = stage,
			})
			Theme.pop(picture :: GuiObject)
		end
		Window.clear(bonusHolder)
		PetTile.bonusRow(bonusHolder, def.bonus, 32)
		Theme.setText(equip, if selection.pet.equipped then "UNEQUIP" else "EQUIP")
		Window.recolor(equip, if selection.pet.equipped then "Red" else "Green")
		Window.recolor(lock, if selection.pet.locked then "Yellow" else "Grey")
		Window.recolor(delete, if selection.pet.locked then "Grey" else "Red")
	end
	return panel, show
end

return Details
