--!strict
-- Training ponds. Players stand on a pond's pad to train; the pond's
-- multiplier boosts Hops earned there. Rebirth ponds unlock with rebirths;
-- Robux ponds unlock with a game pass and work in every world (reference:
-- 0→1x, 2→4x, 4→10x, 6→20x; Robux 3x / 15x / 50x).
--
-- Layout: one row along +X at RowZ (the lobby's +Z side). Positions are
-- computed in functions (not at load) so the pure parts of this module stay
-- unit-testable offline.

export type Pond = {
	index: number,
	id: string,
	name: string,
	multiplier: number,
	rebirths: number?, -- rebirths needed (rebirth ponds)
	pass: string?, -- game pass name in Config/Monetization (Robux ponds)
	color: Color3,
}

local Ponds = {}

Ponds.List = {
	{ index = 1, id = "Starter", name = "Starter Gym", multiplier = 1, rebirths = 0, color = Color3.fromRGB(80, 170, 230) },
	{ index = 2, id = "Lotus", name = "Iron Gym", multiplier = 4, rebirths = 2, color = Color3.fromRGB(90, 200, 170) },
	{ index = 3, id = "Crystal", name = "Crystal Gym", multiplier = 10, rebirths = 4, color = Color3.fromRGB(170, 120, 255) },
	{ index = 4, id = "Royal", name = "Royal Gym", multiplier = 20, rebirths = 6, color = Color3.fromRGB(90, 110, 240) },
	{ index = 5, id = "Golden", name = "Golden Gym", multiplier = 3, pass = "PondGolden", color = Color3.fromRGB(255, 200, 40) },
	{ index = 6, id = "Rainbow", name = "Rainbow Gym", multiplier = 15, pass = "PondRainbow", color = Color3.fromRGB(255, 90, 170) },
	{ index = 7, id = "Cosmic", name = "Cosmic Gym", multiplier = 50, pass = "PondCosmic", color = Color3.fromRGB(40, 220, 140) },
} :: { Pond }

Ponds.ById = {} :: { [string]: Pond }
for _, pond in Ponds.List do
	Ponds.ById[pond.id] = pond
end

-- Layout (studs). Gyms are WidthX × LengthZ in a row along the lobby's +Z
-- wall (Config/Lobby), long side toward the wall: a Rim-wide raised border,
-- the stand pad at the front end and a pool behind it (Util/GymGrid).
Ponds.RowStartX = -160
Ponds.Spacing = 20
Ponds.RowZ = 63
Ponds.WidthX = 16
Ponds.LengthZ = 34
Ponds.SurfaceY = 0.5
Ponds.Rim = 2 -- border width
Ponds.StandSize = 8 -- the square stand pad
Ponds.StandRadius = 4.5 -- how close to the stand pad's centre counts as "on the pad"

function Ponds.isUnlocked(pond: Pond, rebirths: number, ownsPass: (string) -> boolean): boolean
	if pond.pass then
		return ownsPass(pond.pass)
	end
	return rebirths >= (pond.rebirths or 0)
end

-- Short lock reason for signs and errors, or nil when unlocked.
function Ponds.lockReason(pond: Pond, rebirths: number, ownsPass: (string) -> boolean): string?
	if Ponds.isUnlocked(pond, rebirths, ownsPass) then
		return nil
	end
	if pond.pass then
		return "Robux gym"
	end
	return `Needs {pond.rebirths} rebirths`
end

function Ponds.center(pond: Pond): Vector3
	return Vector3.new(Ponds.RowStartX + (pond.index - 1) * Ponds.Spacing, Ponds.SurfaceY, Ponds.RowZ)
end

-- The square pad at the gym's front (-Z) end, just inside the rim, where
-- the player stands.
function Ponds.standPosition(pond: Pond): Vector3
	return Ponds.center(pond) - Vector3.new(0, 0, Ponds.LengthZ / 2 - Ponds.Rim - Ponds.StandSize / 2)
end

-- The pond whose stand pad is at `position`, if any.
function Ponds.at(position: Vector3): Pond?
	for _, pond in Ponds.List do
		local stand = Ponds.standPosition(pond)
		local flat = Vector3.new(position.X - stand.X, 0, position.Z - stand.Z)
		if flat.Magnitude <= Ponds.StandRadius then
			return pond
		end
	end
	return nil
end

return Ponds
