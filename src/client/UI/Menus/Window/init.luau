-- Every menu window, in the reference style: dark translucent panel with a
-- heavy outline, big title across the top edge, corner icon, red X, blurred
-- world behind. Windows live on their own ScreenGui above the HUD and pop in
-- and out. Layout pieces (lists, grids, cards, buttons) are in Layout.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Hud = require(script.Parent.Parent.Hud)
local Icon = require(script.Parent.Parent.Components.Icon)
local CloseButton = require(script.Parent.Parent.Components.CloseButton)
local Layout = require(script.Layout)
local ScreenScale = require(script.Parent.Parent.Components.ScreenScale)
local Sfx = require(script.Parent.Parent.Parent.Sfx)

local new = Theme.new
local C = Theme.Colors

local Window = {}

Window.PanelColor = Layout.PanelColor
Window.CardColor = Layout.CardColor
Window.InsetColor = Layout.InsetColor
Window.TabWidth = 245 -- side tab column (Inventory) hangs off the panel's left edge
Window.Width = 914 -- reference window size at the 1920×1056 view (ScreenScale handles other screens)
Window.Height = 618

Window.header = Layout.header
Window.list = Layout.list
Window.grid = Layout.grid
Window.card = Layout.card
Window.inset = Layout.inset
Window.button = Layout.button
Window.priceButton = Layout.priceButton
Window.clear = Layout.clear
Window.recolor = Layout.recolor

local screen: ScreenGui? = nil
local blurs: { [Frame]: BlurEffect } = {} -- each window's own blur

-- Menus draw above the HUD (bottom bar, quest bar) but under toasts.
local function menuScreen(): ScreenGui
	if not screen or not screen.Parent then
		screen = new("ScreenGui", {
			Name = "FrogHopMenus",
			ResetOnSpawn = false,
			IgnoreGuiInset = true, -- reference windows are centred on the whole view
			DisplayOrder = 10,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		})
		ScreenScale.attach(screen :: ScreenGui)
		Theme.useFont(screen :: ScreenGui, Theme.MenuFont)
	end
	return screen :: ScreenGui
end

function Window.report(ok: boolean, message: string)
	Hud.toast(message, if ok then C.DarkGreen else C.Red)
end

local TITLE_INK = Color3.fromRGB(8, 8, 10)

-- Reference title: white with a 3 px black outline and a solid black copy
-- 8 px lower (the "extruded" look). `size` = font size (Playtime Rewards:
-- 61, i.e. 43 px capitals).
local function titleLabel(frame: Frame, text: string, size: number, y: number)
	for _, spec in { { "TitleShadow", TITLE_INK, 8, 5 }, { "Title", Color3.new(1, 1, 1), 0, 6 } } do
		local label = Theme.label({
			Name = spec[1],
			Size = UDim2.new(1, 0, 0, size * 1.3),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, y + spec[3]),
			Text = text,
			TextColor3 = spec[2],
			TextScaled = false,
			TextSize = size,
			ZIndex = spec[4],
			Parent = frame,
		})
		local stroke = label:FindFirstChildOfClass("UIStroke") or Theme.new("UIStroke", { Parent = label })
		stroke.Thickness = 3
		stroke.Color = TITLE_INK
	end
end

local function closeButton(frame: Frame, onClose: () -> ())
	CloseButton.new({ Size = UDim2.fromOffset(96, 96), Position = UDim2.new(1, -2, 0, 1), ZIndex = 7, Parent = frame }, onClose)
end

-- Size and layout of one window, in pixels at the 1920×1056 design view (ScreenScale
-- shrinks it on smaller screens). Every number is measured from the
-- reference screenshots.
export type Options = {
	width: number?, -- panel size inside its 5 px black edge (default 914×618)
	height: number?,
	x: number?, -- centre offset from the screen centre (My Pets sits right of its tabs)
	y: number?, -- centre offset from the middle of the view (reference windows: 0)
	corner: number?, -- corner radius (default 30; Rebirth and Shop are near-square: 3)
	edge: number?, -- black edge thickness (default 5; Rebirth and Shop: 3)
	titleSize: number?, -- title font size (default 61 = Playtime Rewards)
	titleY: number?, -- title cap centre above the panel top (default -18)
	iconSize: number?, -- corner icon (default 160 at (17, -11), upright)
	iconX: number?,
	iconY: number?,
	iconRotation: number?,
	tabs: boolean?,
}

function Window.create(title: string, icon: string, onClose: () -> (), options: Options?): (Frame, Frame)
	local o: Options = options or {}
	local target = UDim2.new(0.5, o.x or 0, 0.5, o.y or 0)
	local frame = new("Frame", {
		Name = title,
		Size = UDim2.fromOffset(o.width or Window.Width, o.height or Window.Height),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = target,
		BackgroundColor3 = Window.PanelColor,
		BackgroundTransparency = 0.3, -- reference: the blurred world shows through
		Active = true, -- clicks on the panel don't fall through to the world/HUD
		Parent = menuScreen(),
	}, {
		Theme.corner(o.corner or 30),
		Theme.stroke(o.edge or 5, Color3.fromRGB(8, 8, 10)),
	})

	titleLabel(frame, title, o.titleSize or 61, o.titleY or -18)
	if icon ~= "" then -- "" = no corner icon (Worlds reference)
		local size = o.iconSize or 160
		Icon.new(icon, {
			Name = "CornerIcon",
			Size = UDim2.fromOffset(size, size),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(o.iconX or 17, o.iconY or -11),
			Rotation = o.iconRotation or 0,
			ZIndex = 6,
			Parent = frame,
		})
	end
	closeButton(frame, onClose)

	local body = new("Frame", {
		Name = "Body",
		Size = UDim2.new(1, -28, 1, -68),
		Position = UDim2.fromOffset(14, 56),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	-- Blur the world behind the window while it's open.
	local blur = new("BlurEffect", { Name = "MenuBlur", Size = 0, Parent = Lighting })
	TweenService:Create(blur, TweenInfo.new(0.25), { Size = 16 }):Play()
	blurs[frame] = blur
	frame.Destroying:Connect(function()
		blurs[frame] = nil
		blur:Destroy()
	end)

	-- Pop in: grow from small with an overshoot while sliding up a little.
	local scale = new("UIScale", { Scale = 0.55, Parent = frame })
	TweenService:Create(scale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	frame.Position += UDim2.fromOffset(0, 40)
	TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = target,
	}):Play()
	Sfx.play("Open")
	return frame, body
end

-- Shrinks the window away, then destroys it.
function Window.dismiss(frame: Frame)
	local scale = frame:FindFirstChildOfClass("UIScale")
	-- Dead to clicks while it shrinks (its X must not close the next window).
	frame.Interactable = false
	local blur = blurs[frame]
	if blur then
		TweenService:Create(blur, TweenInfo.new(0.12), { Size = 0 }):Play()
	end
	if not scale then
		frame:Destroy()
		return
	end
	local tween = TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.7 })
	tween.Completed:Connect(function()
		frame:Destroy()
	end)
	tween:Play()
end

-- Changes the big title (and optionally the corner icon), e.g. per tab.
function Window.setTitle(frame: Instance, title: string, icon: string?)
	for _, name in { "Title", "TitleShadow" } do
		local label = frame:FindFirstChild(name)
		if label and label:IsA("TextLabel") then
			label.Text = title
		end
	end
	local corner = frame:FindFirstChild("CornerIcon")
	if icon and corner and corner:IsA("GuiObject") then
		local fresh = Icon.new(icon, {
			Name = "CornerIcon",
			Size = corner.Size,
			AnchorPoint = corner.AnchorPoint,
			Position = corner.Position,
			Rotation = corner.Rotation,
			ZIndex = corner.ZIndex,
		})
		corner:Destroy()
		fresh.Parent = frame
		Theme.pop(fresh)
	end
end

return Window
