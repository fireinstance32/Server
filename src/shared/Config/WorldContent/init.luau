-- Content for every world after Lily Valley, one file per world. Frogs, Pets
-- and Zones read these lists, so adding a world is: an entry in Worlds.luau
-- plus a file here.
--
-- Each file returns:
--   world  world id (Config/Worlds)
--   frogs  { id, name, price (Wins), perBounce, color }    sold on that hub's podiums
--   pets   { id, name, rarity, bonus, color }
--   eggs   { id, name, price, color, position (local), pets = { {pet, weight} } }
--   zones  9 lane zones { name, bank colour, material (unused), props, icon } at World 1's
--          distances; Wins = World 1 zone Wins x the world's rewardScale

return {
	require(script.Swamp),
	require(script.Candy),
	require(script.Space),
	require(script.Lava),
}
