-- One lift rep: presses the held rock (right hand) up over the head and
-- back down. Procedural (moves the shoulder joint) like TossAnimation, so it
-- needs no animation asset; a real animation replaces it in stage 4 of the
-- Rock Pivot. Local-only: other players see the rock, not the arm.

local Shoulder = require(script.Parent.Shoulder)

local LiftAnimation = {}

-- Plays one rep over `duration` seconds and yields until the rock is at the
-- top (the moment to show the +Strength pop). The way down finishes on its own.
function LiftAnimation.play(character: Model?, duration: number)
	if not character then
		task.wait(duration / 2)
		return
	end
	local up = duration * 0.45
	if not Shoulder.tween(character, 165, up, Enum.EasingStyle.Back) then
		task.wait(duration / 2)
		return
	end
	task.wait(up)
	Shoulder.tween(character, 0, duration - up, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

return LiftAnimation
