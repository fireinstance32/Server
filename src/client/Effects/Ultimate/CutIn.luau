-- Anime cut-in (reference trailer): the frog's black silhouette over a
-- burst of speed lines in the frog's colour, with "ULTIMATE THROW!".

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Theme = require(script.Parent.Parent.Parent.UI.Theme)
local PetImage = require(script.Parent.Parent.Parent.UI.Components.PetImage)

local new = Theme.new

local CutIn = {}

local LINES = 36
local DURATION = 0.95

function CutIn.play(frogId: string, color: Color3): ScreenGui
	local gui = new("ScreenGui", {
		Name = "UltimateCutIn",
		DisplayOrder = 40,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})
	local backdrop = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color:Lerp(Color3.new(1, 0.1, 0.1), 0.35),
		Parent = gui,
	})
	-- Speed lines: long thin bars through the centre, faded in the middle.
	local lines = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = backdrop,
	})
	for i = 1, LINES do
		local bar = new("Frame", {
			Size = UDim2.new(2.4, 0, 0, if i % 3 == 0 then 18 else 8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = (i / LINES) * 180 + (i % 2) * 3,
			BackgroundColor3 = if i % 2 == 0 then Color3.new(0, 0, 0) else color:Lerp(Color3.new(0, 0, 0), 0.4),
			Parent = lines,
		})
		new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.38, 0.2),
				NumberSequenceKeypoint.new(0.47, 1),
				NumberSequenceKeypoint.new(0.53, 1),
				NumberSequenceKeypoint.new(0.62, 0.2),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Parent = bar,
		})
	end
	-- The frog as a black silhouette, sliding in.
	local silhouette = PetImage.new("frog", frogId, {
		Size = UDim2.fromScale(0.38, 0.62),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.42, 0.52),
		Parent = backdrop,
	})
	if silhouette:IsA("ImageLabel") then
		silhouette.ImageColor3 = Color3.new(0, 0, 0)
	elseif silhouette:IsA("ViewportFrame") then
		silhouette.ImageColor3 = Color3.new(0, 0, 0)
		silhouette.Ambient = Color3.new(0, 0, 0)
		silhouette.LightColor = Color3.new(0, 0, 0)
	end
	local title = Theme.label({
		Size = UDim2.fromScale(0.5, 0.16),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(0.96, 0.92),
		Rotation = -6,
		Text = "ULTIMATE THROW!",
		Parent = backdrop,
	})
	Theme.textStroke(5).Parent = title

	-- Animate: slide the silhouette, punch the title, fade out.
	silhouette.Position = UDim2.fromScale(0.2, 0.52)
	TweenService:Create(silhouette, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.42, 0.52),
	}):Play()
	Theme.pop(title)
	-- Fade, then destroy once the fade is done (Debris is the backstop).
	task.delay(DURATION - 0.25, function()
		local fade = TweenService:Create(backdrop, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
		fade.Completed:Connect(function()
			gui:Destroy()
		end)
		fade:Play()
	end)
	Debris:AddItem(gui, DURATION + 0.2)
	return gui
end

return CutIn
