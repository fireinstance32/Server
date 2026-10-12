-- Numbers that roll up to their new value (HUD Hops/Wins), like the
-- reference games. Returns a setter; the label shows format(value).

local RunService = game:GetService("RunService")

local CountUp = {}

local DURATION = 0.35

function CountUp.bind(label: TextLabel, format: (number) -> string): (number) -> ()
	local shown: number? = nil
	local target = 0
	local from = 0
	local started = 0
	local connection: RBXScriptConnection? = nil
	return function(value: number)
		if shown == nil or value < (shown :: number) then
			-- First value, or a drop (rebirth/purchase): jump straight there.
			shown, target = value, value
			label.Text = format(value)
			return
		end
		from, target, started = shown :: number, value, os.clock()
		if connection then
			return
		end
		connection = RunService.RenderStepped:Connect(function()
			local t = math.min((os.clock() - started) / DURATION, 1)
			local eased = 1 - (1 - t) ^ 3
			shown = from + (target - from) * eased
			label.Text = format(math.floor(shown :: number))
			if t >= 1 then
				shown = target
				label.Text = format(target)
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end
		end)
	end
end

return CountUp
