-- Full-screen egg hatch sequence (reference recording): blur the world,
-- hide the HUD, show the egg(s) → "Click to hatch" → wobble → reveal cards
-- (name, chance, NEW!, +bonus) → "Click to continue". With `auto` it
-- advances by itself (auto-hatch). Functional first pass; Phase 5.4 polishes.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared.Config.Pets)
local Models = require(Shared.Util.Models)
local Hatch = require(Shared.Util.Hatch)

local Theme = require(script.Parent.Theme)
local Hud = require(script.Parent.Hud)

local new = Theme.new
local C = Theme.Colors

local HatchScreen = {}

local CELL = Vector2.new(240, 300)

local function viewport(parent: GuiObject, model: Model): (ViewportFrame, Model)
	local frame = new("ViewportFrame", {
		Size = UDim2.new(1, 0, 0, 200),
		BackgroundTransparency = 1,
		Ambient = Color3.fromRGB(200, 200, 200),
		LightColor = Color3.new(1, 1, 1),
		Parent = parent,
	})
	local camera = new("Camera", { Parent = frame })
	frame.CurrentCamera = camera
	model:PivotTo(CFrame.new())
	model.Parent = frame
	local size = model:GetExtentsSize()
	local distance = math.max(size.X, size.Y, size.Z) * 1.9
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, -distance), Vector3.zero)
	return frame, model
end

-- Waits for a click on `button`, or `autoDelay` seconds when auto is on.
local function waitForClick(button: TextButton, auto: boolean, autoDelay: number)
	if auto then
		task.wait(autoDelay)
		return
	end
	button.Activated:Wait()
end

-- Plays the whole sequence; yields until the player dismisses it.
function HatchScreen.play(eggId: string, results: { any }, auto: boolean?)
	local egg = Pets.EggsById[eggId]
	local isAuto = auto == true
	local hud = Hud.screen()
	hud.Enabled = false
	local blur = new("BlurEffect", { Size = 18, Parent = Lighting })

	local gui = new("ScreenGui", {
		Name = "HatchScreen",
		DisplayOrder = 20,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})
	local clickCatcher = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		Text = "",
		AutoButtonColor = false,
		Parent = gui,
	})
	local row = new("Frame", {
		Size = UDim2.fromScale(0.9, 0.6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.fromOffset(CELL.X, CELL.Y),
			CellPadding = UDim2.fromOffset(16, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})
	local hint = Theme.label({
		Size = UDim2.new(0.6, 0, 0, 44),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.82),
		Text = if #results > 1 then `🖱 Click to hatch {#results}` else "🖱 Click to hatch",
		Parent = gui,
	})

	-- Stage 1: eggs.
	local cells, eggModels = {}, {}
	for i in results do
		local cell = new("Frame", { BackgroundTransparency = 1, LayoutOrder = i, Parent = row })
		local _, model = viewport(cell, Models.egg(if egg then egg.color else C.White, 4))
		cells[i] = cell
		eggModels[i] = model
	end
	waitForClick(clickCatcher, isAuto, 0.4)

	-- Wobble, faster and faster, then crack open.
	hint.Text = ""
	local start = os.clock()
	local wobble = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		for _, model in eggModels do
			model:PivotTo(CFrame.Angles(0, 0, math.sin(t * (12 + t * 30)) * 0.35))
		end
	end)
	task.wait(0.7)
	wobble:Disconnect()

	-- Stage 2: reveal cards.
	for i, result in results do
		local def = Pets.ById[result.pet]
		local cell = cells[i]
		for _, child in cell:GetChildren() do
			child:Destroy()
		end
		if def then
			local nameLabel = Theme.label({
				Size = UDim2.new(1, 0, 0, 34),
				Text = def.name,
				TextColor3 = Pets.RarityColors[def.rarity],
				Parent = cell,
			})
			Theme.textStroke().Parent = nameLabel
			local chanceRow = Theme.label({
				Size = UDim2.new(1, 0, 0, 22),
				Position = UDim2.fromOffset(0, 34),
				Text = Hatch.percentText(result.chance or 0) .. (if result.isNew then "   NEW!" else ""),
				TextColor3 = if result.isNew then Color3.fromRGB(120, 255, 120) else C.White,
				Parent = cell,
			})
			Theme.textStroke().Parent = chanceRow
			local view = viewport(cell, Models.pet(def.name, def.color, 3))
			view.Position = UDim2.fromOffset(0, 58)
			view.Size = UDim2.new(1, 0, 0, 190)
			local bonus = Theme.label({
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.fromOffset(0, 252),
				Text = `⚡ +{def.bonus}`,
				TextColor3 = Color3.fromRGB(140, 235, 80),
				Parent = cell,
			})
			Theme.textStroke().Parent = bonus
			Theme.pop(cell)
		end
	end
	hint.Text = "🖱 Click to continue"
	waitForClick(clickCatcher, isAuto, 1.2)

	gui:Destroy()
	blur:Destroy()
	hud.Enabled = true
end

return HatchScreen
