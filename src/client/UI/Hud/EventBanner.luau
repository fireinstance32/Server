-- Seasonal event pill under the top-right buttons: "🎃 Halloween · 3d 4h ·
-- 120 Candy Corn". Hidden when no event runs. Phase 5 restyles it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Events = require(ReplicatedStorage:WaitForChild("Shared").Config.Events)

local Theme = require(script.Parent.Parent.Theme)
local State = require(script.Parent.Parent.Parent.State)

local new = Theme.new

local EventBanner = {}

function EventBanner.init(gui: ScreenGui)
	local pill = new("Frame", {
		Name = "EventBanner",
		Size = UDim2.fromOffset(300, 54),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 96),
		BackgroundColor3 = Theme.Colors.Ink,
		BackgroundTransparency = 0.15,
		Visible = false,
		Parent = gui,
	}, { Theme.corner(14), Theme.stroke(3) })
	local title = Theme.label({
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(8, 2),
		Text = "",
		Parent = pill,
	})
	Theme.textStroke().Parent = title
	local detail = Theme.label({
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.fromOffset(8, 30),
		Text = "",
		TextColor3 = Theme.Colors.Gold,
		Parent = pill,
	})
	Theme.textStroke().Parent = detail

	local function refresh()
		local now = Workspace:GetServerTimeNow()
		local event = Events.active(now, ReplicatedStorage:GetAttribute(Events.OverrideAttribute))
		pill.Visible = event ~= nil
		if not event then
			return
		end
		pill.BackgroundColor3 = event.color:Lerp(Color3.new(0, 0, 0), 0.45)
		title.Text = `{event.icon} {event.name} event · {Events.timeLeftText(event, now)} left`
		local data = State.data
		local amount = if data and data.event and data.event.id == event.id then data.event.currency else 0
		detail.Text = `{amount} {event.currency} · hop the river to earn more`
	end

	State.observe(refresh)
	task.spawn(function()
		while true do
			refresh()
			task.wait(30)
		end
	end)
end

return EventBanner
