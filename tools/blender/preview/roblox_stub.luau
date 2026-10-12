-- Just enough of the Roblox API to run part-building code offline and
-- record every part (used by dump_pets.mjs for Blender previews).

local V = {}
V.__index = V
local function vec(x, y, z)
	return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V)
end
V.__add = function(a, b) return vec(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V.__sub = function(a, b) return vec(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
V.__unm = function(a) return vec(-a.X, -a.Y, -a.Z) end
V.__mul = function(a, b)
	if type(a) == "number" then a, b = b, a end
	if type(b) == "number" then return vec(a.X * b, a.Y * b, a.Z * b) end
	return vec(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V.__div = function(a, b) return vec(a.X / b, a.Y / b, a.Z / b) end
Vector3 = { new = vec, one = vec(1, 1, 1), zero = vec(0, 0, 0) }

local C = {}
C.__index = function(self, key)
	if key == "Position" then
		return vec(self.p[1], self.p[2], self.p[3])
	elseif key == "Rotation" then
		return setmetatable({ p = { 0, 0, 0 }, r = self.r }, C)
	end
	return nil
end
local I = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }
local function mm(a, b)
	local r = {}
	for i = 0, 2 do
		for j = 0, 2 do
			local s = 0
			for k = 0, 2 do
				s += a[i * 3 + k + 1] * b[k * 3 + j + 1]
			end
			r[i * 3 + j + 1] = s
		end
	end
	return r
end
local function cf(p, r)
	return setmetatable({ p = p, r = r or I }, C)
end
C.__mul = function(a, b)
	if getmetatable(b) == V then
		local r = a.r
		return vec(
			a.p[1] + r[1] * b.X + r[2] * b.Y + r[3] * b.Z,
			a.p[2] + r[4] * b.X + r[5] * b.Y + r[6] * b.Z,
			a.p[3] + r[7] * b.X + r[8] * b.Y + r[9] * b.Z
		)
	end
	local r = a.r
	local bp = b.p
	return cf({
		a.p[1] + r[1] * bp[1] + r[2] * bp[2] + r[3] * bp[3],
		a.p[2] + r[4] * bp[1] + r[5] * bp[2] + r[6] * bp[3],
		a.p[3] + r[7] * bp[1] + r[8] * bp[2] + r[9] * bp[3],
	}, mm(a.r, b.r))
end
local function rx(t) local c, s = math.cos(t), math.sin(t) return { 1, 0, 0, 0, c, -s, 0, s, c } end
local function ry(t) local c, s = math.cos(t), math.sin(t) return { c, 0, s, 0, 1, 0, -s, 0, c } end
local function rz(t) local c, s = math.cos(t), math.sin(t) return { c, -s, 0, s, c, 0, 0, 0, 1 } end
CFrame = {
	identity = cf({ 0, 0, 0 }),
	new = function(x, y, z)
		if type(x) == "table" then
			return cf({ x.X, x.Y, x.Z })
		end
		return cf({ x or 0, y or 0, z or 0 })
	end,
	Angles = function(a, b, c)
		return cf({ 0, 0, 0 }, mm(mm(rx(a), ry(b)), rz(c)))
	end,
}

local Col = {}
Col.__index = Col
local function col(r, g, b)
	return setmetatable({ R = r, G = g, B = b }, Col)
end
function Col:Lerp(o, t)
	return col(self.R + (o.R - self.R) * t, self.G + (o.G - self.G) * t, self.B + (o.B - self.B) * t)
end
Color3 = { new = col, fromRGB = function(r, g, b) return col(r / 255, g / 255, b / 255) end }

Enum = setmetatable({}, { __index = function(_, kind)
	return setmetatable({}, { __index = function(_, item) return item end })
end })
local function noop() return {} end
NumberRange = { new = noop }
NumberSequence = { new = noop }
ColorSequence = { new = noop }
ColorSequenceKeypoint = { new = noop }
UDim2 = { fromOffset = noop, fromScale = noop, new = noop }
Vector2 = { new = noop }

-- Instances: plain tables; Parts are recorded.
PARTS = {}
local Inst = {}
Inst.__index = function(self, key)
	local method = Inst[key]
	if method then return method end
	return rawget(self, "_children")[key]
end
function Inst:GetChildren()
	local list = {}
	for _, child in self._list do table.insert(list, child) end
	return list
end
function Inst:IsA(class) return self.ClassName == class or (class == "BasePart" and self.ClassName == "Part") end
function Inst:FindFirstChildOfClass(class)
	for _, child in self._list do if child.ClassName == class then return child end end
	return nil
end
Inst.__newindex = function(self, key, value)
	if key == "Parent" and value then
		value._children[self.Name or self.ClassName] = self
		table.insert(value._list, self)
	end
	rawset(self, key, value)
end
Instance = {
	new = function(class)
		local obj = setmetatable({ ClassName = class, _children = {}, _list = {} }, Inst)
		if class == "Decal" then
			rawset(obj, "Color3", col(1, 1, 1))
			rawset(obj, "ZIndex", 1)
		end
		if class == "Part" then
			rawset(obj, "CFrame", CFrame.identity)
			rawset(obj, "Size", vec(4, 1, 2))
			rawset(obj, "Transparency", 0)
			rawset(obj, "Shape", "Block")
			table.insert(PARTS, obj)
		end
		return obj
	end,
}
