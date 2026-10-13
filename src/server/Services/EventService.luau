-- Seasonal events (Config/Events): which one is running, its currency in
-- player data, and the event egg stand that only shows while it runs.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = require(Shared.Config.Events)
local Worlds = require(Shared.Config.Worlds)

local Stats = require(script.Parent.Parent.Stats)
local DataService = require(script.Parent.DataService)

local EventService = {}

local CHECK_SECONDS = 15
-- Where event decorations go in the Lily Valley lobby (local positions, on
-- the open grass either side of the path; layout in Config/Lobby).
local PROP_SPOTS = {
	Vector3.new(-104, 0, 16), Vector3.new(-104, 0, -16), Vector3.new(-84, 0, 24), Vector3.new(-84, 0, -24),
	Vector3.new(-62, 0, 18), Vector3.new(-62, 0, -18), Vector3.new(-44, 0, 28), Vector3.new(-44, 0, -26),
	Vector3.new(-34, 0, 12), Vector3.new(-34, 0, -12), Vector3.new(-152, 0, 56),
}

function EventService.active(): Events.Event?
	return Events.active(os.time(), ReplicatedStorage:GetAttribute(Events.OverrideAttribute))
end

-- Starts the player on the current event (old event currency is dropped).
local function sync(data: any, event: Events.Event?)
	if event and data.event.id ~= event.id then
		data.event = { id = event.id, currency = 0 }
	end
end

-- Currency a river hop to `zoneIndex` will earn right now (0 = no event).
function EventService.launchReward(player: Player, data: any, zoneIndex: number): number
	if not EventService.active() then
		return 0
	end
	return Stats.eventCurrency(player, data, zoneIndex)
end

function EventService.award(data: any, amount: number)
	local event = EventService.active()
	if event and amount > 0 then
		sync(data, event)
		data.event.currency += amount
	end
end

-- Pays `cost` event currency for an egg of `eventId`. Returns ok, message.
function EventService.spend(data: any, eventId: string, cost: number): (boolean, string?)
	local event = EventService.active()
	if not event or event.id ~= eventId then
		return false, "This event isn't running right now"
	end
	sync(data, event)
	if data.event.currency < cost then
		return false, `Not enough {event.currency}`
	end
	data.event.currency -= cost
	return true, nil
end

-- Shows or hides every event egg stand (hidden stands keep their place so
-- the client's sign lookups still find them).
local function showStands(event: Events.Event?)
	local root = workspace:FindFirstChild("World")
	local hub = root and root:FindFirstChild(Worlds.Default)
	if not hub then
		return
	end
	for _, def in Events.List do
		local stand = hub:FindFirstChild("EggStand_" .. def.egg.id)
		if stand then
			local visible = event ~= nil and event.id == def.id
			for _, part in stand:GetDescendants() do
				if part:IsA("BasePart") then
					part.Transparency = if visible then 0 else 1
				elseif part:IsA("ProximityPrompt") then
					part.Enabled = visible
				end
			end
			stand.Transparency = if visible then 0 else 1
			stand.CanCollide = visible
		end
	end
end

-- Simple pumpkins (placeholder until Phase 6 models), tinted by the event.
local function buildProps(hub: Instance, event: Events.Event)
	local folder = Instance.new("Folder")
	folder.Name = "EventProps"
	local offset = Worlds.offset(Worlds.ById[Worlds.Default])
	for i, spot in PROP_SPOTS do
		local size = 2.5 + (i % 3) * 0.8
		local body = Instance.new("Part")
		body.Name = "Pumpkin"
		body.Anchored = true
		body.CanCollide = false
		body.Size = Vector3.new(size * 1.25, size, size * 1.25)
		body.Color = event.color
		body.Material = Enum.Material.SmoothPlastic
		body.CFrame = CFrame.new(spot + offset + Vector3.new(0, 0.5 + size / 2, 0)) * CFrame.Angles(0, i, 0)
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = body
		local stem = Instance.new("Part")
		stem.Name = "Stem"
		stem.Anchored = true
		stem.CanCollide = false
		stem.Size = Vector3.new(0.4, size * 0.35, 0.4)
		stem.Color = Color3.fromRGB(70, 120, 40)
		stem.CFrame = body.CFrame * CFrame.new(0, size / 2 + size * 0.12, 0)
		stem.Parent = body
		local glow = Instance.new("PointLight")
		glow.Color = event.color
		glow.Range = 10
		glow.Brightness = 1.5
		glow.Parent = body
		body.Parent = folder
	end
	folder.Parent = hub
end

local function showProps(event: Events.Event?)
	local root = workspace:FindFirstChild("World")
	local hub = root and root:FindFirstChild(Worlds.Default)
	if not hub then
		return
	end
	local old = hub:FindFirstChild("EventProps")
	if old then
		old:Destroy()
	end
	if event then
		buildProps(hub, event)
	end
end

function EventService.start()
	DataService.Loaded:Connect(function(player, data)
		sync(data, EventService.active())
		DataService.changed(player)
	end)
	task.spawn(function()
		local shown: string? = "?"
		while true do
			local event = EventService.active()
			local id = if event then event.id else nil
			if id ~= shown then
				shown = id
				showStands(event)
				showProps(event)
			end
			task.wait(CHECK_SECONDS)
		end
	end)
end

return EventService
