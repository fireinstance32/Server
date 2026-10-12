-- A stand-in for the Roblox client API, just enough to run the game's UI
-- code offline. Instances are plain tables; the GUI tree they build is
-- dumped to JSON (DUMP_GUI) and laid out + drawn by render.mjs.
-- Loops (`while true do task.wait() end`) stop at their first wait.

local EVENTS = {
	Activated = true, MouseButton1Click = true, MouseButton1Down = true, MouseButton1Up = true,
	MouseEnter = true, MouseLeave = true, Changed = true, ChildAdded = true, ChildRemoved = true,
	Event = true, OnClientEvent = true, OnClientInvoke = true, InputBegan = true, InputEnded = true,
	InputChanged = true, Heartbeat = true, RenderStepped = true, Stepped = true, Triggered = true,
	PromptTriggered = true, PromptShown = true, PromptHidden = true, PlayerAdded = true,
	PlayerRemoving = true, CharacterAdded = true, CharacterRemoving = true, Touched = true,
	Completed = true, FocusLost = true, Focused = true, DescendantAdded = true, Died = true,
	PromptGamePassPurchaseFinished = true, PromptProductPurchaseFinished = true,
	PromptPurchaseFinished = true, AncestryChanged = true, Destroying = true,
}

-- Signals ---------------------------------------------------------------
local Signal = {}
Signal.__index = Signal
local function newSignal()
	return setmetatable({ handlers = {} }, Signal)
end
function Signal:Connect(fn)
	table.insert(self.handlers, fn)
	local signal = self
	return {
		Connected = true,
		Disconnect = function()
			local i = table.find(signal.handlers, fn)
			if i then
				table.remove(signal.handlers, i)
			end
		end,
	}
end
Signal.Once = Signal.Connect
function Signal:Wait()
	if coroutine.isyieldable() then
		coroutine.yield()
	end
	return nil
end
function Signal:Fire(...)
	for _, fn in table.clone(self.handlers) do
		task.spawn(fn, ...)
	end
end

-- Datatypes ---------------------------------------------------------------
local function typed(name, fields, mt)
	fields.__type = name
	return setmetatable(fields, mt)
end

local UDimMT = {}
UDimMT.__add = function(a, b) return UDim.new(a.Scale + b.Scale, a.Offset + b.Offset) end
UDim = { new = function(s, o) return typed("UDim", { Scale = s or 0, Offset = o or 0 }, UDimMT) end }

local UDim2MT = {}
UDim2MT.__eq = function(a, b)
	return a.X.Scale == b.X.Scale and a.X.Offset == b.X.Offset and a.Y.Scale == b.Y.Scale and a.Y.Offset == b.Y.Offset
end
UDim2MT.__index = function(self, k)
	if k == "Width" then return self.X elseif k == "Height" then return self.Y end
	return nil
end
UDim2MT.__add = function(a, b)
	return UDim2.new(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset)
end
UDim2MT.__sub = function(a, b)
	return UDim2.new(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset)
end
UDim2 = {
	new = function(xs, xo, ys, yo)
		if type(xs) == "table" then
			return typed("UDim2", { X = xs, Y = xo }, UDim2MT)
		end
		return typed("UDim2", { X = UDim.new(xs, xo), Y = UDim.new(ys, yo) }, UDim2MT)
	end,
	fromScale = function(x, y) return UDim2.new(x or 0, 0, y or 0, 0) end,
	fromOffset = function(x, y) return UDim2.new(0, x or 0, 0, y or 0) end,
}
function UDim2MT.__index_lerp(a, b, t)
	return UDim2.new(
		a.X.Scale + (b.X.Scale - a.X.Scale) * t, a.X.Offset + (b.X.Offset - a.X.Offset) * t,
		a.Y.Scale + (b.Y.Scale - a.Y.Scale) * t, a.Y.Offset + (b.Y.Offset - a.Y.Offset) * t)
end

local V2 = {}
V2.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
V2.__index = function(self, k)
	if k == "Magnitude" then return math.sqrt(self.X ^ 2 + self.Y ^ 2) end
	return nil
end
V2.__add = function(a, b) return Vector2.new(a.X + b.X, a.Y + b.Y) end
V2.__sub = function(a, b) return Vector2.new(a.X - b.X, a.Y - b.Y) end
V2.__mul = function(a, b)
	if type(a) == "number" then a, b = b, a end
	if type(b) == "number" then return Vector2.new(a.X * b, a.Y * b) end
	return Vector2.new(a.X * b.X, a.Y * b.Y)
end
V2.__div = function(a, b) return Vector2.new(a.X / b, a.Y / b) end
Vector2 = { new = function(x, y) return typed("Vector2", { X = x or 0, Y = y or 0 }, V2) end }
Vector2.zero = Vector2.new(0, 0)
Vector2.one = Vector2.new(1, 1)

local V3 = {}
V3.__index = function(self, k)
	if k == "Magnitude" then return math.sqrt(self.X ^ 2 + self.Y ^ 2 + self.Z ^ 2) end
	if k == "Unit" then local m = math.max(self.Magnitude, 1e-9) return Vector3.new(self.X / m, self.Y / m, self.Z / m) end
	return nil
end
V3.__add = function(a, b) return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V3.__sub = function(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
V3.__unm = function(a) return Vector3.new(-a.X, -a.Y, -a.Z) end
V3.__mul = function(a, b)
	if type(a) == "number" then a, b = b, a end
	if type(b) == "number" then return Vector3.new(a.X * b, a.Y * b, a.Z * b) end
	return Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V3.__div = function(a, b) return Vector3.new(a.X / b, a.Y / b, a.Z / b) end
Vector3 = { new = function(x, y, z) return typed("Vector3", { X = x or 0, Y = y or 0, Z = z or 0 }, V3) end }
Vector3.zero = Vector3.new()
Vector3.one = Vector3.new(1, 1, 1)
Vector3.yAxis = Vector3.new(0, 1, 0)

local CF = {}
CF.__index = function(self, k)
	if k == "Position" or k == "p" then return self._p end
	if k == "LookVector" then return Vector3.new(0, 0, -1) end
	if k == "Rotation" then return CFrame.new() end
	if k == "X" then return self._p.X elseif k == "Y" then return self._p.Y elseif k == "Z" then return self._p.Z end
	return CF[k]
end
CF.__mul = function(a, b)
	if getmetatable(b) == V3 then return a._p + b end
	return CFrame.new(a._p + b._p)
end
CF.__add = function(a, b) return CFrame.new(a._p + b) end
function CF:Lerp(b) return b end
function CF:Inverse() return CFrame.new(-self._p) end
function CF:ToWorldSpace(b) return self * b end
function CF:PointToWorldSpace(v) return self._p + v end
CFrame = {
	new = function(x, y, z)
		if type(x) == "table" then return typed("CFrame", { _p = x }, CF) end
		return typed("CFrame", { _p = Vector3.new(x or 0, y or 0, z or 0) }, CF)
	end,
	Angles = function() return CFrame.new() end,
	fromEulerAnglesXYZ = function() return CFrame.new() end,
	lookAt = function(p) return CFrame.new(p) end,
}
CFrame.identity = CFrame.new()

local ColMT = {}
ColMT.__index = ColMT
ColMT.__eq = function(a, b) return a.R == b.R and a.G == b.G and a.B == b.B end
function ColMT:Lerp(o, t)
	return Color3.new(self.R + (o.R - self.R) * t, self.G + (o.G - self.G) * t, self.B + (o.B - self.B) * t)
end
function ColMT:ToHSV()
	local r, g, b = self.R, self.G, self.B
	local mx, mn = math.max(r, g, b), math.min(r, g, b)
	local h, s, v = 0, 0, mx
	local d = mx - mn
	if mx > 0 then s = d / mx end
	if d > 0 then
		if mx == r then h = ((g - b) / d) % 6 elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
		h /= 6
	end
	return h, s, v
end
function ColMT:ToHex()
	return string.format("%02x%02x%02x", self.R * 255, self.G * 255, self.B * 255)
end
Color3 = {
	new = function(r, g, b) return typed("Color3", { R = r or 0, G = g or 0, B = b or 0 }, ColMT) end,
	fromRGB = function(r, g, b) return Color3.new((r or 0) / 255, (g or 0) / 255, (b or 0) / 255) end,
	fromHSV = function(h, s, v)
		local i = math.floor(h * 6)
		local f = h * 6 - i
		local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
		local m = i % 6
		if m == 0 then return Color3.new(v, t, p) elseif m == 1 then return Color3.new(q, v, p)
		elseif m == 2 then return Color3.new(p, v, t) elseif m == 3 then return Color3.new(p, q, v)
		elseif m == 4 then return Color3.new(t, p, v) end
		return Color3.new(v, p, q)
	end,
	fromHex = function(hex)
		hex = string.gsub(hex, "#", "")
		return Color3.fromRGB(tonumber(string.sub(hex, 1, 2), 16), tonumber(string.sub(hex, 3, 4), 16), tonumber(string.sub(hex, 5, 6), 16))
	end,
}

ColorSequenceKeypoint = { new = function(t, c) return { Time = t, Value = c } end }
ColorSequence = {
	new = function(a, b)
		if type(a) == "table" and a.__type == "Color3" then
			return typed("ColorSequence", { Keypoints = { ColorSequenceKeypoint.new(0, a), ColorSequenceKeypoint.new(1, b or a) } }, {})
		end
		return typed("ColorSequence", { Keypoints = a }, {})
	end,
}
NumberSequenceKeypoint = { new = function(t, v) return { Time = t, Value = v } end }
NumberSequence = {
	new = function(a, b)
		if type(a) == "number" then
			return typed("NumberSequence", { Keypoints = { NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(1, b or a) } }, {})
		end
		return typed("NumberSequence", { Keypoints = a }, {})
	end,
}
NumberRange = { new = function(a, b) return { Min = a, Max = b or a } end }
TweenInfo = { new = function(t) return { Time = t or 1 } end }
Rect = { new = function(a, b, c, d) return typed("Rect", { Min = Vector2.new(a, b), Max = Vector2.new(c, d) }, {}) end }
Font = { new = function(family) return { Family = family } end, fromEnum = function(e) return e end }
BrickColor = { new = function(n) return { Name = n, Color = Color3.new(0.5, 0.5, 0.5) } end }
PhysicalProperties = { new = function() return {} end }
DateTime = { now = function() return { UnixTimestamp = os.time(), UnixTimestampMillis = os.time() * 1000 } end }

local EnumItemMT = { __tostring = function(self) return `Enum.{self.EnumType}.{self.Name}` end }
Enum = setmetatable({}, { __index = function(_, kind)
	local items = setmetatable({}, { __index = function(t, name)
		local item = typed("EnumItem", { EnumType = kind, Name = name, Value = 0 }, EnumItemMT)
		rawset(t, name, item)
		return item
	end })
	rawset(Enum, kind, items)
	return items
end })

function typeof(v)
	if type(v) == "table" then
		if rawget(v, "__type") then return v.__type end
		if rawget(v, "ClassName") then return "Instance" end
	end
	return type(v)
end

-- task ------------------------------------------------------------------
task = {}
function task.spawn(fn, ...)
	if type(fn) == "thread" then
		coroutine.resume(fn, ...)
		return fn
	end
	local co = coroutine.create(fn)
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		print(`[preview] error in spawned thread: {err}`)
	end
	return co
end
task.defer = task.spawn
-- Scenes can let each thread pass WAIT_BUDGET waits instantly (to step
-- through a sequence like the hatch screen); after that, waits park the
-- thread for good so endless loops stop.
WAIT_BUDGET = 0
local waits = setmetatable({}, { __mode = "k" })
function task.wait(t)
	if coroutine.isyieldable() then
		local co = coroutine.running()
		waits[co] = (waits[co] or 0) + 1
		if waits[co] > WAIT_BUDGET then
			coroutine.yield()
		end
	end
	return t or 0
end
function task.delay() end
function task.cancel() end
wait = task.wait
spawn = task.spawn
delay = task.delay
function warn(...) print("[warn]", ...) end
function tick() return os.clock() end
function time() return os.clock() end

-- Instances ---------------------------------------------------------------
local DEFAULTS = {
	GuiObject = function(i)
		i.Size = UDim2.fromOffset(100, 100)
		i.Position = UDim2.new()
		i.AnchorPoint = Vector2.new()
		i.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
		i.BackgroundTransparency = 0
		i.BorderSizePixel = 1
		i.Visible = true
		i.ZIndex = 1
		i.LayoutOrder = 0
		i.Rotation = 0
		i.ClipsDescendants = false
	end,
	Text = function(i)
		i.BackgroundColor3 = Color3.new(1, 1, 1)
		i.Text = if i.ClassName == "TextButton" then "Button" else "Label"
		i.TextColor3 = Color3.fromRGB(27, 42, 53)
		i.TextSize = 14
		i.TextScaled = false
		i.TextWrapped = false
		i.TextTransparency = 0
		i.TextStrokeTransparency = 1
		i.TextStrokeColor3 = Color3.new()
		i.TextXAlignment = Enum.TextXAlignment.Center
		i.TextYAlignment = Enum.TextYAlignment.Center
		i.Font = Enum.Font.Legacy
		i.RichText = false
		i.LineHeight = 1
	end,
	Image = function(i)
		i.BackgroundColor3 = Color3.new(1, 1, 1)
		i.Image = ""
		i.ImageColor3 = Color3.new(1, 1, 1)
		i.ImageTransparency = 0
		i.ScaleType = Enum.ScaleType.Stretch
	end,
}
local GUI_OBJECTS = { Frame = true, TextLabel = true, TextButton = true, TextBox = true, ImageLabel = true, ImageButton = true, ScrollingFrame = true, ViewportFrame = true, CanvasGroup = true, VideoFrame = true }
local BASES = {
	GuiObject = GUI_OBJECTS,
	GuiButton = { TextButton = true, ImageButton = true },
	GuiBase2d = GUI_OBJECTS,
	LayerCollector = { ScreenGui = true, BillboardGui = true, SurfaceGui = true },
	BasePart = { Part = true, MeshPart = true, WedgePart = true, SpawnLocation = true },
	ValueBase = { IntValue = true, StringValue = true, NumberValue = true, BoolValue = true, ObjectValue = true },
	UIGridStyleLayout = { UIListLayout = true, UIGridLayout = true },
}

local Inst = {}
local allInstances = {}

local function isA(obj, class)
	if obj.ClassName == class or class == "Instance" then return true end
	local set = BASES[class]
	return set ~= nil and set[obj.ClassName] == true
end

local InstMT = {}
InstMT.__index = function(self, key)
	if key == "Parent" then return rawget(self, "_parent") end
	local method = Inst[key]
	if method then return method end
	if EVENTS[key] then
		local s = newSignal()
		rawset(self, key, s)
		return s
	end
	local child = rawget(self, "_byName")[key]
	if child then return child end
	return nil
end
InstMT.__newindex = function(self, key, value)
	if key == "Parent" then
		local old = rawget(self, "_parent")
		if old then
			local list = rawget(old, "_children")
			local i = table.find(list, self)
			if i then table.remove(list, i) end
			if rawget(old, "_byName")[rawget(self, "Name")] == self then
				rawget(old, "_byName")[rawget(self, "Name")] = nil
			end
		end
		rawset(self, "_parent", value)
		if value then
			table.insert(rawget(value, "_children"), self)
			rawget(value, "_byName")[rawget(self, "Name")] = self
			value.ChildAdded:Fire(self)
			-- DescendantAdded on every ancestor, for self and its subtree.
			local ancestor = value
			while ancestor do
				local signal = rawget(ancestor, "DescendantAdded")
				if signal then
					signal:Fire(self)
					for _, d in self:GetDescendants() do
						signal:Fire(d)
					end
				end
				ancestor = rawget(ancestor, "_parent")
			end
		end
		return
	end
	if key == "Name" then
		local parent = rawget(self, "_parent")
		if parent then
			rawget(parent, "_byName")[rawget(self, "Name")] = nil
			rawget(parent, "_byName")[value] = self
		end
	end
	rawset(self, key, value)
end
InstMT.__tostring = function(self) return rawget(self, "Name") end

function Inst:GetChildren() return table.clone(rawget(self, "_children")) end
function Inst:GetDescendants()
	local out = {}
	local function walk(o)
		for _, c in rawget(o, "_children") do
			table.insert(out, c)
			walk(c)
		end
	end
	walk(self)
	return out
end
function Inst:FindFirstChild(name, recursive)
	for _, c in rawget(self, "_children") do
		if rawget(c, "Name") == name then return c end
	end
	if recursive then
		for _, c in rawget(self, "_children") do
			local found = c:FindFirstChild(name, true)
			if found then return found end
		end
	end
	return nil
end
function Inst:FindFirstChildOfClass(class)
	for _, c in rawget(self, "_children") do
		if c.ClassName == class then return c end
	end
	return nil
end
function Inst:FindFirstChildWhichIsA(class)
	for _, c in rawget(self, "_children") do
		if isA(c, class) then return c end
	end
	return nil
end
function Inst:FindFirstAncestorOfClass(class)
	local p = rawget(self, "_parent")
	while p do
		if p.ClassName == class then return p end
		p = rawget(p, "_parent")
	end
	return nil
end
function Inst:FindFirstAncestorWhichIsA(class)
	local p = rawget(self, "_parent")
	while p do
		if isA(p, class) then return p end
		p = rawget(p, "_parent")
	end
	return nil
end
function Inst:WaitForChild(name)
	local found = self:FindFirstChild(name)
	if found then return found end
	local auto = Instance.new("Folder")
	auto.Name = name
	auto.Parent = self
	return auto
end
function Inst:IsA(class) return isA(self, class) end
function Inst:IsDescendantOf(other)
	local p = rawget(self, "_parent")
	while p do
		if p == other then return true end
		p = rawget(p, "_parent")
	end
	return false
end
function Inst:Destroy()
	self.Parent = nil
	rawset(self, "_destroyed", true)
end
Inst.Remove = Inst.Destroy
function Inst:ClearAllChildren()
	for _, c in self:GetChildren() do c:Destroy() end
end
function Inst:Clone()
	local copy = Instance.new(self.ClassName)
	for k, v in self do
		if type(k) == "string" and string.sub(k, 1, 1) ~= "_" and k ~= "ClassName" and getmetatable(v) ~= Signal then
			rawset(copy, k, v)
		end
	end
	for _, c in rawget(self, "_children") do
		c:Clone().Parent = copy
	end
	return copy
end
function Inst:GetAttribute(name) return rawget(self, "_attributes")[name] end
function Inst:SetAttribute(name, value) rawget(self, "_attributes")[name] = value end
function Inst:GetAttributes() return table.clone(rawget(self, "_attributes")) end
function Inst:GetAttributeChangedSignal() return newSignal() end
function Inst:GetPropertyChangedSignal() return newSignal() end
function Inst:GetFullName() return rawget(self, "Name") end
function Inst:Fire(...) -- BindableEvent
	self.Event:Fire(...)
end
function Inst:FireServer() end
function Inst:InvokeServer() return nil end
function Inst:Play() end
function Inst:Stop() end
function Inst:Pause() end
function Inst:Resume() end
function Inst:Emit() end
function Inst:Clear() end
function Inst:PivotTo(cf) rawset(self, "_pivot", cf) end
function Inst:GetPivot() return rawget(self, "_pivot") or CFrame.new() end
function Inst:GetExtentsSize() return Vector3.new(4, 4, 4) end
function Inst:ScaleTo() end
function Inst:GetScale() return 1 end
function Inst:TranslateBy() end
function Inst:SetPrimaryPartCFrame() end
function Inst:CaptureFocus() end
function Inst:ReleaseFocus() end
function Inst:LoadAnimation() return Instance.new("AnimationTrack") end

Instance = {
	new = function(class, parent)
		local obj = setmetatable({ _children = {}, _byName = {}, _attributes = {} }, InstMT)
		rawset(obj, "ClassName", class)
		rawset(obj, "Name", class)
		if GUI_OBJECTS[class] then DEFAULTS.GuiObject(obj) end
		if class == "TextLabel" or class == "TextButton" or class == "TextBox" then DEFAULTS.Text(obj) end
		if class == "ImageLabel" or class == "ImageButton" then DEFAULTS.Image(obj) end
		if class == "ScreenGui" then
			rawset(obj, "Enabled", true)
			rawset(obj, "DisplayOrder", 0)
			rawset(obj, "IgnoreGuiInset", false)
		elseif class == "UIStroke" then
			rawset(obj, "Thickness", 1)
			rawset(obj, "Color", Color3.new())
			rawset(obj, "Transparency", 0)
			rawset(obj, "Enabled", true)
			rawset(obj, "ApplyStrokeMode", Enum.ApplyStrokeMode.Contextual)
		elseif class == "UIGradient" then
			rawset(obj, "Color", ColorSequence.new(Color3.new(1, 1, 1)))
			rawset(obj, "Transparency", NumberSequence.new(0))
			rawset(obj, "Rotation", 0)
			rawset(obj, "Enabled", true)
		elseif class == "UIScale" then
			rawset(obj, "Scale", 1)
		elseif BASES.BasePart[class] then
			rawset(obj, "CFrame", CFrame.new())
			rawset(obj, "Size", Vector3.new(4, 1, 2))
			rawset(obj, "Color", Color3.new(0.6, 0.6, 0.6))
			rawset(obj, "Transparency", 0)
		elseif class == "Humanoid" then
			rawset(obj, "Health", 100)
		end
		table.insert(allInstances, obj)
		if parent then obj.Parent = parent end
		return obj
	end,
}

-- Services ------------------------------------------------------------------
local services = {}
game = Instance.new("DataModel")
rawset(game, "Name", "Game")
rawset(game, "JobId", "")
rawset(game, "PlaceId", 0)
rawset(game, "GameId", 0)
function Inst:GetService(name)
	if not services[name] then
		local s = Instance.new(name)
		rawset(s, "Name", name)
		s.Parent = game
		services[name] = s
	end
	return services[name]
end
workspace = game:GetService("Workspace")
local camera = Instance.new("Camera")
rawset(camera, "ViewportSize", Vector2.new(1920, 1056))
rawset(camera, "CFrame", CFrame.new())
rawset(workspace, "CurrentCamera", camera)
function Inst:GetServerTimeNow() return os.time() end

local Players = game:GetService("Players")
local player = Instance.new("Player")
rawset(player, "Name", "FrogFan")
rawset(player, "DisplayName", "FrogFan")
rawset(player, "UserId", 1)
player.Parent = Players
local playerGui = Instance.new("PlayerGui")
rawset(playerGui, "Name", "PlayerGui")
playerGui.Parent = player
rawset(Players, "LocalPlayer", player)
function Inst:GetPlayers() return { player } end
function Inst:GetPlayerByUserId() return player end
function Inst:GetUserThumbnailAsync() return "" end
function Inst:GetNameFromUserIdAsync() return "Player" end
function Inst:IsFriendsWith() return false end
function Inst:GetFriendsOnline() return {} end

local RunService = game:GetService("RunService")
function Inst:IsServer() return false end
function Inst:IsClient() return true end
function Inst:IsStudio() return true end
function Inst:IsRunning() return true end
function Inst:BindToRenderStep() end
function Inst:UnbindFromRenderStep() end

local GuiService = game:GetService("GuiService")
rawset(GuiService, "MenuIsOpen", false) -- Roblox escape menu
rawset(GuiService, "MenuOpened", newSignal())
rawset(GuiService, "MenuClosed", newSignal())

local UIS = game:GetService("UserInputService")
rawset(UIS, "TouchEnabled", false)
rawset(UIS, "KeyboardEnabled", true)
rawset(UIS, "MouseEnabled", true)
rawset(UIS, "GamepadEnabled", false)
function Inst:GetMouseLocation() return Vector2.new(960, 540) end
function Inst:IsKeyDown() return false end

-- TweenService:Create(...):Play() jumps straight to the goal.
function Inst:Create(target, _info, goals)
	return {
		Play = function()
			for k, v in goals do target[k] = v end
		end,
		Cancel = function() end,
		Pause = function() end,
		Completed = newSignal(),
		Destroy = function() end,
	}
end

-- MarketplaceService / SocialService / others
function Inst:UserOwnsGamePassAsync() return false end
function Inst:GetProductInfo() return { PriceInRobux = 0, Name = "" } end
function Inst:PromptGamePassPurchase() end
function Inst:PromptProductPurchase() end
function Inst:PromptGameInvite() end
function Inst:CanSendGameInviteAsync() return false end
function Inst:PlayLocalSound() end
function Inst:AddItem() end
function Inst:GetTextSize() return Vector2.new(100, 20) end

-- Dump ------------------------------------------------------------------------
local function esc(s)
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, '"', '\\"')
	s = string.gsub(s, "\n", "\\n")
	s = string.gsub(s, "\r", "")
	s = string.gsub(s, "\t", " ")
	return s
end

local function value(v)
	local t = typeof(v)
	if t == "number" then
		if v ~= v or v == math.huge or v == -math.huge then return "0" end
		return string.format("%.4f", v)
	elseif t == "boolean" then return tostring(v)
	elseif t == "string" then return '"' .. esc(v) .. '"'
	elseif t == "UDim2" then return string.format('{"t":"UDim2","v":[%.4f,%.2f,%.4f,%.2f]}', v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
	elseif t == "UDim" then return string.format('{"t":"UDim","v":[%.4f,%.2f]}', v.Scale, v.Offset)
	elseif t == "Vector2" then return string.format('{"t":"Vector2","v":[%.4f,%.4f]}', v.X, v.Y)
	elseif t == "Color3" then return string.format('{"t":"Color3","v":[%.4f,%.4f,%.4f]}', v.R, v.G, v.B)
	elseif t == "EnumItem" then return '"' .. v.Name .. '"'
	elseif t == "Rect" then return string.format('{"t":"Rect","v":[%.2f,%.2f,%.2f,%.2f]}', v.Min.X, v.Min.Y, v.Max.X, v.Max.Y)
	elseif t == "ColorSequence" then
		local parts = {}
		for _, k in v.Keypoints do
			table.insert(parts, string.format("[%.4f,%.4f,%.4f,%.4f]", k.Time, k.Value.R, k.Value.G, k.Value.B))
		end
		return '{"t":"ColorSequence","v":[' .. table.concat(parts, ",") .. "]}"
	elseif t == "NumberSequence" then
		local parts = {}
		for _, k in v.Keypoints do
			table.insert(parts, string.format("[%.4f,%.4f]", k.Time, k.Value))
		end
		return '{"t":"NumberSequence","v":[' .. table.concat(parts, ",") .. "]}"
	end
	return nil
end

local function dump(obj)
	local props = {}
	for k, v in obj do
		if type(k) == "string" and string.sub(k, 1, 1) ~= "_" and k ~= "ClassName" and k ~= "Name" then
			local s = value(v)
			if s then table.insert(props, '"' .. k .. '":' .. s) end
		end
	end
	local kids = {}
	for _, c in rawget(obj, "_children") do
		table.insert(kids, dump(c))
	end
	return string.format('{"c":"%s","n":"%s","p":{%s},"k":[%s]}', obj.ClassName, esc(rawget(obj, "Name")), table.concat(props, ","), table.concat(kids, ","))
end

function DUMP_GUI()
	return dump(playerGui)
end

-- Lays every BillboardGui out flat on a ScreenGui so world signs can be
-- previewed (they normally float over parts).
function FLATTEN_BILLBOARDS()
	local screen = Instance.new("ScreenGui")
	screen.Name = "Billboards"
	local x, y, rowHeight = 40, 40, 0
	for _, gui in playerGui:GetDescendants() do
		if gui.ClassName == "BillboardGui" then
			local size = gui.Size
			local w, h = size.X.Offset, size.Y.Offset
			if x + w > 1880 then
				x, y, rowHeight = 40, y + rowHeight + 40, 0
			end
			rawset(gui, "ClassName", "Frame")
			gui.BackgroundTransparency = 1
			gui.Position = UDim2.fromOffset(x, y)
			gui.Visible = true
			gui.Parent = screen
			x += w + 40
			rowHeight = math.max(rowHeight, h)
		end
	end
	screen.Parent = playerGui
end

-- Sends a snapshot to the client the way the server does.
function SEND_DATA(snapshot)
	local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
	remotes:WaitForChild("DataChanged").OnClientEvent:Fire(snapshot)
end

script = Instance.new("ModuleScript")
_G.__UI_PREVIEW = true
