---
tags: [lift-a-sword, design, pets]
---
# Pets

**Roster approved (2026-10-14).** 16 eggs: eggs 1–12 hold 5 pets each and eggs 13–16 hold 6, so 84 pets in all. Back to [[Lift a Sword]].

**Style:** a chunky rounded cube on tiny nub feet, after your reference pets (2026-10-14). Only the parts that make each animal are added: thick rounded ears with inner ears, horns, wings, smooth tails, halos. Fur markings (socks, bellies, stripes, spots) are painted into the texture, and a thin dark outline goes round the whole pet. The face is painted per pet onto the front, not modelled.

**Size:** every pet has the same body size (you asked for this on 2026-10-14). Animals differ only by their add-ons, and Studio scales all pets by one shared factor.

**Faces:** every pet gets its own face PNG, all the same size but not looking the same. The eyes are the same size and spot on every pet (you approved them). Variety comes from:
- the expression (one of the 12 below), the iris colour and pupils;
- the muzzle shape: round, puffy rodent cheeks, a fox's white cheeks, an owl's heart-shaped face disc, or a long deer snout;
- the nose (glossy dog/cat/deer/button nose, pig snout, beak) and buck teeth.

| Face | Look |
|---|---|
| Cute | big round eyes with sparkles, little open smile, blush (the current one) |
| Happy | closed ^ ^ eyes, open smile |
| Sparkle | shiny coloured eyes, small smile |
| Brave | half-lidded confident eyes, smirk |
| Dots | small bean eyes, "w" mouth |
| Sleepy | droopy closed eyes, a "z" |
| Cool | sunglasses, smirk |
| Grumpy | flat brows, frown |
| Wink | one eye closed, tongue out |
| Star | star-shaped pupils (cosmic pets) |
| Flame | fiery pupils, fang grin (lava and dragon pets) |
| Glow | blank glowing eyes, no mouth (ghost, robot, void) |

Rarity in each egg is Common, Uncommon, Rare, Epic, Legendary. Eggs 13–16 add a sixth, **Mythic**.

| # | Egg | Pets (Common → Legendary / Mythic) |
|---|---|---|
| 1 | WoodenEgg | Squirrel (Cute), Hedgehog (Dots), Fox (Happy), Owl (Sleepy), Deer (Sparkle) |
| 2 | StoneEgg | Mole (Dots), Rock Turtle (Sleepy), Badger (Grumpy), Golem Pup (Brave), Moss Bear (Cute) |
| 3 | BronzeEgg | Beaver (Happy), Clockwork Mouse (Wink), Gear Bug (Dots), Steam Pig (Cool), Bronze Bull (Brave) |
| 4 | IronEgg | Raccoon (Wink), Armadillo (Dots), Knight Dog (Brave), Iron Rhino (Grumpy), Ember Wolf (Flame) |
| 5 | SteelEgg | Penguin (Cute), Shield Crab (Grumpy), Robo Cat (Glow), Steel Ram (Brave), Mech Lion (Cool) |
| 6 | GoldenEgg | Hamster (Happy), Gold Pig (Cool), Peacock (Sparkle), King Frog (Wink), Royal Lion (Brave) |
| 7 | IceEgg | Snow Bunny (Cute), Seal (Happy), Polar Bear (Sleepy), Frost Fox (Sparkle), Yeti (Grumpy) |
| 8 | EmeraldEgg | Frog (Wink), Gecko (Dots), Jade Turtle (Sleepy), Leaf Dragon (Brave), Emerald Stag (Sparkle) |
| 9 | LavaEgg | Fire Salamander (Flame), Ash Bat (Grumpy), Magma Slime (Happy), Lava Hound (Flame), Phoenix (Sparkle) |
| 10 | CrystalEgg | Crystal Bunny (Cute), Gem Beetle (Dots), Amethyst Owl (Sparkle), Prism Fox (Wink), Crystal Unicorn (Star) |
| 11 | KatanaEgg | Panda (Sleepy), Red Panda (Happy), Ninja Cat (Brave), Tanuki (Wink), Kitsune (Sparkle) |
| 12 | ThunderEgg | Storm Sheep (Dots), Spark Mouse (Happy), Thunder Hawk (Brave), Volt Wolf (Cool), Storm Griffin (Star) |
| 13 | DragonEgg | Baby Wyrm (Cute), Drake Pup (Happy), Bat-Dragon (Flame), Wyvern (Brave), Hydra (Grumpy), **Elder Dragon** (Flame) |
| 14 | GalaxyEgg | Space Cat (Star), Alien Blob (Glow), Moon Bunny (Sleepy), Comet Fox (Sparkle), Nebula Whale (Star), **Galaxy Dragon** (Star) |
| 15 | ExcaliburEgg | Angel Pig (Cute), Holy Lamb (Happy), Pegasus (Sparkle), Knight Lion (Brave), Seraph Owl (Glow), **Excalibur Dragon** (Star) |
| 16 | VoidEgg | Imp (Wink), Skull Pup (Happy), Shadow Cat (Glow), Hellhound (Flame), Lich Owl (Glow), **Demon Lord** (Flame) |

## Built
- ✅ Egg 1 Wooden (2026-10-14, v3 quality pass, approved): ![[LS Pets Wooden Egg.png]]
- ✅ Egg 2 Stone (2026-10-14): Mole (pink nose, whiskers, digging claws), RockTurtle (stone shell with six-sided plates and moss), Badger (face stripe, eye mask), GolemPup (stone body, floppy stone ears, moss, glowing crystals), MossBear (moss blanket, sprouts and a toadstool). ![[LS Pets Stone Egg.png]]
- Model names are CamelCase (`RockTurtle`, `GolemPup`, `MossBear`); the names with spaces above are for the UI.
- Builder: `C:\LiftASword\tools\blender\build_pets.py`. Shapes are in `pets/shapes.py`, one roster file per egg is `pets/eggNN_*.py`, the faces come from `pets/faces.py`, and fur markings from `pets/marks.py`. Moving parts (tails, wings) are their own meshes so they can be animated later.

## Open
- (none) Egg 16 is the Void egg of the new zone 16.
