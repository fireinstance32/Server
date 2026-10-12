-- Leaderboard boards in each hub. LeaderboardService fills the rows
-- (Row1..RowN TextLabels in each board's SurfaceGui).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Leaderboards = require(ReplicatedStorage:WaitForChild("Shared").Config.Leaderboards)

local Parts = require(script.Parent.Parts)

local Builder = {}

local WIDTH, HEIGHT = 24, 30

local function surface(board: Part, def): SurfaceGui
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(480, 600)
	gui.LightInfluence = 0
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = gui

	local function row(name: string, order: number, height: number, text: string, color: Color3)
		local l = Instance.new("TextLabel")
		l.Name = name
		l.LayoutOrder = order
		l.Size = UDim2.new(1, 0, 0, height)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.FredokaOne
		l.TextScaled = true
		l.TextColor3 = color
		l.Text = text
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(20, 30, 20)
		stroke.Parent = l
		l.Parent = gui
	end

	row("Title", 0, 80, def.title, def.color)
	for i = 1, Leaderboards.Rows do
		row(`Row{i}`, i, 50, if i == 1 then "Loading..." else "", Color3.new(1, 1, 1))
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
			Color3.fromRGB(40, 60, 45),
			model
		)
		surface(board, def)
		model.Parent = folder
	end
	folder.Parent = world
end

return Builder
