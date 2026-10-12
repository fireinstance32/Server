-- Visual language for every screen: bright, chunky, readable at phone size.

local TweenService = game:GetService("TweenService")

local Sfx = require(script.Parent.Parent.Sfx)

local Theme = {}

Theme.Font = Enum.Font.FredokaOne
Theme.Colors = {
	Green = Color3.fromRGB(90, 200, 70),
	DarkGreen = Color3.fromRGB(40, 120, 40),
	Gold = Color3.fromRGB(255, 200, 40),
	Blue = Color3.fromRGB(70, 160, 255),
	Purple = Color3.fromRGB(170, 90, 255),
	Red = Color3.fromRGB(240, 80, 80),
	Panel = Color3.fromRGB(255, 250, 235),
	Ink = Color3.fromRGB(35, 45, 35),
	Outline = Color3.fromRGB(26, 24, 36), -- text/panel outlines (reference: near-black)
	White = Color3.new(1, 1, 1),
	Grey = Color3.fromRGB(160, 160, 160),
}

-- new("Frame", { Size = ... }, { children }) : terse instance construction.
function Theme.new(className: string, props: { [string]: any }?, children: { Instance }?): any
	local inst = Instance.new(className)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	local parent = nil
	for key, value in props or {} do
		if key == "Parent" then
			parent = value
		else
			(inst :: any)[key] = value
		end
	end
	for _, child in children or {} do
		child.Parent = inst
	end
	inst.Parent = parent
	return inst
end

function Theme.corner(radius: number?): UICorner
	return Theme.new("UICorner", { CornerRadius = UDim.new(0, radius or 14) })
end

function Theme.stroke(thickness: number?, color: Color3?): UIStroke
	return Theme.new("UIStroke", {
		Thickness = thickness or 3,
		Color = color or Theme.Colors.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Theme.textStroke(thickness: number?): UIStroke
	return Theme.new("UIStroke", { Thickness = thickness or 3, Color = Theme.Colors.Outline })
end

function Theme.label(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = Theme.Font,
		TextColor3 = Theme.Colors.White,
		TextScaled = true,
	}
	for k, v in props do
		defaults[k] = v
	end
	local label = Theme.new("TextLabel", defaults)
	if props.TextColor3 == nil or props.TextColor3 == Theme.Colors.White then
		Theme.textStroke().Parent = label
	end
	return label
end

-- Chunky button with a squish animation on press.
function Theme.button(props: { [string]: any }, onClick: () -> ()): TextButton
	local color = props.Color or Theme.Colors.Green
	props.Color = nil
	local defaults = {
		BackgroundColor3 = color,
		Font = Theme.Font,
		TextColor3 = Theme.Colors.White,
		TextScaled = true,
		AutoButtonColor = true,
	}
	for k, v in props do
		defaults[k] = v
	end
	local button = Theme.new("TextButton", defaults, {
		Theme.corner(),
		Theme.stroke(3),
		Theme.new("UIPadding", {
			PaddingTop = UDim.new(0.12, 0),
			PaddingBottom = UDim.new(0.12, 0),
			PaddingLeft = UDim.new(0.06, 0),
			PaddingRight = UDim.new(0.06, 0),
		}),
	})
	local scale = Theme.new("UIScale", { Parent = button })
	Theme.textStroke().Parent = button

	Theme.hover(button, scale)
	button.Activated:Connect(function()
		scale.Scale = 0.9
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1,
		}):Play()
		Sfx.play("Click")
		onClick()
	end)
	return button
end

-- Grows a button a little while the mouse is over it.
function Theme.hover(button: GuiButton, scale: UIScale)
	local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	button.MouseEnter:Connect(function()
		TweenService:Create(scale, info, { Scale = 1.06 }):Play()
		Sfx.play("Hover", 0.3)
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	end)
end

function Theme.pop(guiObject: GuiObject)
	local scale = guiObject:FindFirstChildOfClass("UIScale") or Theme.new("UIScale", { Parent = guiObject })
	scale.Scale = 0.6
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
end

return Theme
