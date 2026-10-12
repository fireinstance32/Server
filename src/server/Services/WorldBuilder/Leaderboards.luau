-- Leaderboard boards in each hub. LeaderboardService fills the rows
-- (Row1..RowN TextLabels in each board's SurfaceGui).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Leaderboards = require(ReplicatedStorage:WaitForChild("Shared").Config.Leaderboards)

local Parts = require(script.Parent.Parts)

local Builder = {}

local WIDTH, HEIGHT = 24, 30

local MEDALS = { Color3.fromRGB(255, 210, 60), Color3.fromRGB(215, 222, 235), Color3.fromRGB(230, 150, 90) }
local INK = Color3.fromRGB(26, 24, 36)

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function outline(parent: Instance, thickness: number, color: Color3)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

local function text(parent: Instance, name: string, value: string, color: Color3)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = UDim2.new(1, -24, 0.8, 0)
	l.Position = UDim2.new(0, 12, 0.1, 0)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.FredokaOne
	l.TextScaled = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextColor3 = color
	l.Text = value
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = INK
	stroke.Parent = l
	l.Parent = parent
	return l
end

-- Board face in the UI style: dark panel, coloured title banner, striped
-- rows with medal colours for the top three. LeaderboardService finds the
-- RowN labels by name anywhere in the gui.
local function surface(board: Part, def): SurfaceGui
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(480, 600)
	gui.LightInfluence = 0

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(1, -16, 1, -16)
	panel.Position = UDim2.fromOffset(8, 8)
	panel.BackgroundColor3 = Color3.fromRGB(42, 43, 52)
	corner(panel, 18)
	outline(panel, 6, INK)
	panel.Parent = gui

	local banner = Instance.new("Frame")
	banner.Size = UDim2.new(1, -24, 0, 76)
	banner.Position = UDim2.fromOffset(12, 12)
	banner.BackgroundColor3 = Color3.new(1, 1, 1)
	corner(banner, 14)
	outline(banner, 4, INK)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(def.color:Lerp(Color3.new(1, 1, 1), 0.25), def.color:Lerp(Color3.new(0, 0, 0), 0.25))
	gradient.Rotation = 90
	gradient.Parent = banner
	banner.Parent = panel
	local title = text(banner, "Title", def.title, Color3.new(1, 1, 1))
	title.TextXAlignment = Enum.TextXAlignment.Center

	local rowHeight = (600 - 16 - 112) / Leaderboards.Rows
	for i = 1, Leaderboards.Rows do
		local stripe = Instance.new("Frame")
		stripe.Name = `Stripe{i}`
		stripe.Size = UDim2.new(1, -24, 0, rowHeight - 6)
		stripe.Position = UDim2.fromOffset(12, 100 + (i - 1) * rowHeight)
		stripe.BackgroundColor3 = if i % 2 == 1 then Color3.fromRGB(56, 57, 68) else Color3.fromRGB(48, 49, 59)
		corner(stripe, 10)
		stripe.Parent = panel
		text(stripe, `Row{i}`, if i == 1 then "Loading..." else "", MEDALS[i] or Color3.new(1, 1, 1))
	end
	gui.Parent = board
	return gui
end

function Builder.build(world: Model)
	local folder = Instance.new("Folder")
	folder.Name = "Leaderboards"
	for i, def in Leaderboards.List do
		local base = Leaderboards.position(i)
		local model = Instance.new("Model")
		model.Name = def.id
		for _, side in { -1, 1 } do
			Parts.block("Post", Vector3.new(2, HEIGHT + 4, 2), CFrame.new(base + Vector3.new(side * (WIDTH / 2 + 1), (HEIGHT + 4) / 2, 0)), Parts.Colors.Wood, model)
		end
		-- Front face looks toward +Z (the plaza).
		local board = Parts.block(
			"Board",
			Vector3.new(WIDTH, HEIGHT, 1),
			CFrame.lookAt(base + Vector3.new(0, HEIGHT / 2 + 3, 0), base + Vector3.new(0, HEIGHT / 2 + 3, 10)),
			Color3.fromRGB(30, 30, 38),
			model
		)
		surface(board, def)
		model.Parent = folder
	end
	folder.Parent = world
end

return Builder
