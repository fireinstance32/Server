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
Window.Width = 914 -- reference window size at 1920×1080 (ScreenScale handles other screens)
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
			IgnoreGuiInset = false,
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

local function titleLabel(frame: Frame, text: string)
	-- Reference title: white, thick black outline, and a solid black copy
	-- shifted down underneath (the "extruded" look).
	local shadow = Theme.label({
		Name = "TitleShadow",
		Size = UDim2.new(0.76, 0, 0, 100),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, -10),
		Text = text,
		TextColor3 = TITLE_INK,
		ZIndex = 5,
		Parent = frame,
	})
	Theme.new("UIStroke", { Thickness = 7, Color = TITLE_INK, Parent = shadow })
	local title = Theme.label({
		Name = "Title",
		Size = UDim2.new(0.76, 0, 0, 100),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, -16),
		Text = text,
		ZIndex = 6,
		Parent = frame,
	})
	local stroke = title:FindFirstChildOfClass("UIStroke") :: UIStroke
	stroke.Thickness = 7
	stroke.Color = TITLE_INK
end

local function closeButton(frame: Frame, onClose: () -> ())
	CloseButton.new({ Size = UDim2.fromOffset(96, 96), Position = UDim2.new(1, -2, 0, 1), ZIndex = 7, Parent = frame }, onClose)
end

-- `height` / `width` in pixels at 1920×1080 (default: the reference 914×618).
-- `tabs`: the Inventory tab column hangs off the left edge (the window stays
-- centred, like the reference).
function Window.create(title: string, icon: string, onClose: () -> (), height: number?, _tabs: boolean?, width: number?): (Frame, Frame)
	local frame = new("Frame", {
		Name = title,
		Size = UDim2.fromOffset(width or Window.Width, height or Window.Height),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.51),
		BackgroundColor3 = Window.PanelColor,
		BackgroundTransparency = 0.3, -- reference: the blurred world shows through
		Active = true, -- clicks on the panel don't fall through to the world/HUD
		Parent = menuScreen(),
	}, {
		Theme.corner(10),
		Theme.stroke(3, Color3.fromRGB(8, 8, 10)),
	})

	titleLabel(frame, title)
	if icon ~= "" then -- "" = no corner icon (Worlds reference)
		Icon.new(icon, {
			Name = "CornerIcon",
			Size = UDim2.fromOffset(170, 170),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(60, 6),
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
		Position = UDim2.fromScale(0.5, 0.51),
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
