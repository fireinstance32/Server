-- Scales a whole ScreenGui with the screen. Every layout is drawn for
-- a 1920×1056 game view (a maximised Roblox window on a 1080p screen, where
-- the reference screenshots were taken); on a smaller window or a phone the UI shrinks evenly instead of
-- spilling off the edges (and grows a little on big monitors).

local Workspace = game:GetService("Workspace")

local Theme = require(script.Parent.Parent.Theme)

local ScreenScale = {}

local DESIGN = Vector2.new(1920, 1056)
local MIN, MAX = 0.4, 1.25

-- Pure: the scale for a viewport size (unit-test friendly).
function ScreenScale.forViewport(size: Vector2): number
	local fit = math.min(size.X / DESIGN.X, size.Y / DESIGN.Y)
	return math.clamp(fit, MIN, MAX)
end

function ScreenScale.attach(gui: ScreenGui): UIScale
	local scale = Theme.new("UIScale", { Name = "ScreenScale", Parent = gui })
	local function update()
		local camera = Workspace.CurrentCamera
		if camera then
			scale.Scale = ScreenScale.forViewport(camera.ViewportSize)
		end
	end
	update()
	local connection: RBXScriptConnection? = nil
	local function watch()
		if connection then
			connection:Disconnect()
		end
		local camera = Workspace.CurrentCamera
		if camera then
			connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
		end
		update()
	end
	watch()
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watch)
	return scale
end

return ScreenScale
