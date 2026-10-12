-- Pop-up windows: Frog Shop, Pets, Rebirth, Codes. One open at a time.
-- Each window rebuilds its contents from State whenever data changes.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Frogs = require(Shared.Config.Frogs)
local Pets = require(Shared.Config.Pets)
local Game = require(Shared.Config.Game)
local Monetization = require(Shared.Config.Monetization)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)

local Theme = require(script.Parent.Theme)
local Hud = require(script.Parent.Hud)
local State = require(script.Parent.Parent.State)

local new = Theme.new
local C = Theme.Colors

local Menus = {}

local current: { name: string, frame: Frame, refresh: (any) -> () }? = nil

local function report(ok: boolean, message: string)
	Hud.toast(message, if ok then C.DarkGreen else C.Red)
end

local function window(title: string, color: Color3): (Frame, Frame)
	local frame = new("Frame", {
		Name = title,
		Size = UDim2.fromScale(0.62, 0.66),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = C.Panel,
		Parent = Hud.screen(),
	}, {
		Theme.corner(20),
		Theme.stroke(4),
		new("UISizeConstraint", { MaxSize = Vector2.new(760, 520), MinSize = Vector2.new(320, 300) }),
	})

	local header = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = color,
		Parent = frame,
	}, { Theme.corner(20), Theme.stroke(4) })
	Theme.label({
		Size = UDim2.new(1, -80, 1, -12),
		Position = UDim2.fromOffset(16, 6),
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	local close = Theme.button({
		Size = UDim2.fromOffset(46, 46),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Text = "X",
		Color = C.Red,
	}, function()
		Menus.close()
	end)
	close.Parent = header

	local body = new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, -24, 1, -72),
		Position = UDim2.fromOffset(12, 64),
		BackgroundTransparency = 1,
		Parent = frame,
	})
	Theme.pop(frame)
	return frame, body
end

local function grid(parent: Instance, cellHeight: number): ScrollingFrame
	local scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 8,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Parent = parent,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(150, cellHeight),
			CellPadding = UDim2.fromOffset(10, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }),
	})
	return scroll
end

local function card(parent: Instance, order: number, accent: Color3): Frame
	return new("Frame", {
		BackgroundColor3 = C.White,
		LayoutOrder = order,
		Parent = parent,
	}, { Theme.corner(14), Theme.stroke(3, accent) })
end

local function clearCards(scroll: ScrollingFrame)
	for _, child in scroll:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function buildFrogs(body: Frame)
	local scroll = grid(body, 190)
	return function(data)
		clearCards(scroll)
		for i, frog in Frogs.List do
			local c = card(scroll, i, frog.color)
			new("Frame", {
				Size = UDim2.fromOffset(56, 56),
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 10),
				BackgroundColor3 = frog.color,
				Parent = c,
			}, { Theme.corner(28), Theme.stroke(3) })
			Theme.label({
				Size = UDim2.new(1, -10, 0, 26),
				Position = UDim2.fromOffset(5, 70),
				Text = frog.name,
				TextColor3 = C.Ink,
				Parent = c,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 22),
				Position = UDim2.fromOffset(5, 98),
				Text = `+{Format.abbreviate(frog.perBounce)} Hops / pad`,
				TextColor3 = C.DarkGreen,
				Parent = c,
			})

			local owned = data.frogs[frog.id]
			local text, color, action
			if data.equippedFrog == frog.id then
				text, color = "Equipped", C.Grey
			elseif owned then
				text, color = "Equip", C.Blue
				action = function()
					report(Net.func("EquipFrog"):InvokeServer(frog.id))
				end
			elseif frog.robuxOnly then
				text, color = "Robux", C.Purple
				action = function()
					local id = Monetization.Products.PhoenixFrog
					if id ~= 0 then
						MarketplaceService:PromptProductPurchase(Players.LocalPlayer, id)
					else
						report(false, "Not on sale yet")
					end
				end
			else
				local affordable = data.wins >= frog.price
				text = `🏆 {Format.abbreviate(frog.price)}`
				color = if affordable then C.Green else C.Red
				action = function()
					report(Net.func("BuyFrog"):InvokeServer(frog.id))
				end
			end
			local b = Theme.button({
				Size = UDim2.new(1, -20, 0, 44),
				Position = UDim2.new(0, 10, 1, -54),
				Text = text,
				Color = color,
			}, function()
				if action then
					action()
				end
			end)
			b.Parent = c
		end
	end
end

local function buildPets(body: Frame)
	local summary = Theme.label({
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		TextColor3 = C.Ink,
		Parent = body,
	})
	local holder = new("Frame", {
		Size = UDim2.new(1, 0, 1, -38),
		Position = UDim2.fromOffset(0, 38),
		BackgroundTransparency = 1,
		Parent = body,
	})
	local scroll = grid(holder, 150)
	return function(data)
		clearCards(scroll)
		local entries = {}
		local equipped = 0
		for uid, pet in data.pets do
			local def = Pets.ById[pet.id]
			if def then
				table.insert(entries, { uid = uid, pet = pet, def = def })
				if pet.equipped then
					equipped += 1
				end
			end
		end
		-- Equipped first, then strongest.
		table.sort(entries, function(a, b)
			if a.pet.equipped ~= b.pet.equipped then
				return a.pet.equipped
			end
			return a.def.multiplier > b.def.multiplier
		end)

		local petBonus = 1
		for _, entry in entries do
			if entry.pet.equipped then
				petBonus += entry.def.multiplier - 1
			end
		end
		summary.Text = `Equipped {equipped}/{data.maxEquippedPets}  •  Pet bonus {Format.multiplier(petBonus)}  •  {#entries}/{Game.MaxPetInventory} pets`

		if #entries == 0 then
			local c = card(scroll, 1, C.Grey)
			Theme.label({
				Size = UDim2.new(1, -10, 1, -10),
				Position = UDim2.fromOffset(5, 5),
				Text = "Hatch eggs near spawn to get pets!",
				TextColor3 = C.Ink,
				Parent = c,
			})
			return
		end

		for i, entry in entries do
			local rarityColor = Pets.RarityColors[entry.def.rarity]
			local c = card(scroll, i, rarityColor)
			Theme.label({
				Size = UDim2.new(1, -10, 0, 28),
				Position = UDim2.fromOffset(5, 8),
				Text = entry.def.name,
				TextColor3 = C.Ink,
				Parent = c,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 22),
				Position = UDim2.fromOffset(5, 38),
				Text = entry.def.rarity,
				TextColor3 = rarityColor,
				Parent = c,
			})
			Theme.label({
				Size = UDim2.new(1, -10, 0, 24),
				Position = UDim2.fromOffset(5, 62),
				Text = `{Format.multiplier(entry.def.multiplier)} Hops`,
				TextColor3 = C.DarkGreen,
				Parent = c,
			})
			local isEquipped = entry.pet.equipped
			local b = Theme.button({
				Size = UDim2.new(1, -20, 0, 40),
				Position = UDim2.new(0, 10, 1, -50),
				Text = if isEquipped then "Unequip" else "Equip",
				Color = if isEquipped then C.Red else C.Blue,
			}, function()
				local remote = if isEquipped then "UnequipPet" else "EquipPet"
				local ok, message = Net.func(remote):InvokeServer(entry.uid)
				if not ok then
					report(ok, message)
				end
			end)
			b.Parent = c
		end
	end
end

local function buildRebirth(body: Frame)
	Theme.label({
		Size = UDim2.new(1, 0, 0, 60),
		Text = "Rebirth resets your Hops and Wins.\nYou keep your frogs and pets!",
		TextColor3 = C.Ink,
		Parent = body,
	})
	local reward = Theme.label({
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromOffset(0, 70),
		Text = "",
		TextColor3 = C.Purple,
		Parent = body,
	})
	local barBack = new("Frame", {
		Size = UDim2.new(0.9, 0, 0, 36),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 124),
		BackgroundColor3 = C.Grey,
		Parent = body,
	}, { Theme.corner(18), Theme.stroke(3) })
	local barFill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = C.Purple,
		Parent = barBack,
	}, { Theme.corner(18) })
	local barText = Theme.label({
		Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.fromOffset(0, 4),
		Text = "",
		ZIndex = 2,
		Parent = barBack,
	})
	local button = Theme.button({
		Size = UDim2.fromOffset(240, 70),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 180),
		Text = "REBIRTH",
		Color = C.Purple,
	}, function()
		report(Net.func("Rebirth"):InvokeServer())
	end)
	button.Parent = body

	return function(data)
		local nextBonus = 1 + (data.rebirths + 1) * Game.RebirthHopsBonus
		reward.Text = `Next rebirth: Hops {Format.multiplier(nextBonus)} forever`
		local progress = math.clamp(data.hops / data.rebirthCost, 0, 1)
		barFill.Size = UDim2.fromScale(progress, 1)
		barText.Text = `{Format.abbreviate(data.hops)} / {Format.abbreviate(data.rebirthCost)} Hops`
		button.BackgroundColor3 = if progress >= 1 then C.Purple else C.Grey
	end
end

local function buildCodes(body: Frame)
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
		report(Net.func("RedeemCode"):InvokeServer(box.Text))
		box.Text = ""
	end)
	button.Parent = body
	return function() end
end

local BUILDERS = {
	Frogs = { title = "🐸 Frog Shop", color = C.Green, build = buildFrogs },
	Pets = { title = "🐾 Pets", color = C.Blue, build = buildPets },
	Rebirth = { title = "🔁 Rebirth", color = C.Purple, build = buildRebirth },
	Codes = { title = "🎁 Codes", color = C.Gold, build = buildCodes },
}

function Menus.close()
	if current then
		current.frame:Destroy()
		current = nil
	end
end

function Menus.open(name: string)
	local wasOpen = current and current.name == name
	Menus.close()
	if wasOpen then
		return -- clicking the same menu button again toggles it closed
	end
	local spec = BUILDERS[name]
	if not spec then
		return
	end
	local frame, body = window(spec.title, spec.color)
	local refresh = spec.build(body)
	current = { name = name, frame = frame, refresh = refresh }
	if State.data then
		refresh(State.data)
	end
end

function Menus.init()
	State.observe(function(data)
		if current then
			current.refresh(data)
		end
	end)
end

return Menus
