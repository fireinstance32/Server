-- A ViewportFrame showing a 3D model (pets, frogs, eggs) facing the viewer.

local Theme = require(script.Parent.Parent.Theme)

local ModelView = {}

-- `facing` = the model's front direction (pets "-Z", frogs "+X").
function ModelView.new(model: Model, props: { [string]: any }?, facing: string?): ViewportFrame
	local frame = Theme.new("ViewportFrame", {
		Name = "ModelView",
		BackgroundTransparency = 1,
		Ambient = Color3.fromRGB(200, 200, 200),
		LightColor = Color3.new(1, 1, 1),
		LightDirection = Vector3.new(-1, -1, -1),
	})
	for key, value in props or {} do
		(frame :: any)[key] = value
	end
	local camera = Theme.new("Camera", { Parent = frame })
	frame.CurrentCamera = camera
	model:PivotTo(CFrame.new())
	model.Parent = frame
	local size = model:GetExtentsSize()
	local distance = math.max(size.X, size.Y, size.Z) * 1.8
	-- Look at the model's front from slightly above and to the side.
	local front = if facing == "+X" then Vector3.new(1, 0, 0) else Vector3.new(0, 0, -1)
	local side = Vector3.new(front.Z, 0, -front.X)
	local eye = (front + side * 0.45 + Vector3.new(0, 0.35, 0)).Unit * distance
	camera.CFrame = CFrame.lookAt(eye, Vector3.zero)
	return frame
end

return ModelView
