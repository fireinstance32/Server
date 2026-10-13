-- One lift rep, a clean and press: squat and pull the rock to the shoulder
-- (charge), drive up out of the squat and press it overhead with the free
-- arm flexed and the chest proud (peak), then lower it. Procedural (see
-- Pose) so it needs no animation asset; Effects/Lift adds the effects.

local Pose = require(script.Parent.Pose)
local LiftFx = require(script.Parent.Parent.Effects.Lift)

local LiftAnimation = {}

-- Plays one rep over `duration` seconds and yields until the rock is at the
-- top (the moment to show the +Strength pop). The way down finishes on its
-- own. `color`/`perBounce` are the held rock's, for the effects.
function LiftAnimation.play(character: Model?, duration: number, color: Color3, perBounce: number)
	local dip, drive = duration * 0.2, duration * 0.28
	if not character or not Pose.to(character, { squat = 0.8, shoulder = 35, elbow = 115, arch = -8, flex = 0 }, dip) then
		task.wait(dip + drive)
		return
	end
	local power = LiftFx.power(perBounce)
	LiftFx.charge(character, color, power)
	task.wait(dip)
	Pose.to(character, { squat = 0, shoulder = 172, elbow = 0, arch = 12, flex = 1 }, drive, Enum.EasingStyle.Back)
	-- Back easing overshoots, so the rock "arrives" a little before the end.
	task.wait(drive * 0.7)
	LiftFx.peak(character, color, power)
	task.delay(duration * 0.14, function()
		Pose.relax(character, duration * 0.32)
	end)
end

return LiftAnimation
