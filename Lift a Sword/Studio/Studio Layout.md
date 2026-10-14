---
tags: [lift-a-sword, studio]
---
# Studio Layout

What's where in the Lift a Sword place. Back to [[Lift a Sword]].

- **Place:** "############", placeId 85963287767565 (owner FireInstance33). Studio MCP id `0dcafac6-1b19-460f-8750-6700ea1cafe6`. Don't touch "Untitled Experience" (the ripped Lift an Egg copy) or "+1 Tongue Escape".
- I can't see Studio's screen (screen capture comes back black), so I check positions with code and ask you for screenshots.

## Workspace.Map
- `Zones.Zone_01 … Zone_15`, each with:
  - `Sword`: a clone of the master, attribute `SwordName`, blade width along world X, 3 studs of bare blade above the slot.
  - `PedestalModel`: 3.9 studs per unit, pivot at (−300, 4.4, zoneZ).
  - `Sign`: the imported sign model (attribute `SignName`) at (−280, 4, zoneZ+6), yaw 160°, facing spawn. The "💪 N recommended" SurfaceGui is on its invisible `SignFace` part.
  - `Pedestal`: the old invisible cylinder that only holds 2 BillboardGuis.
- `EggStairs`: 4 steps × 4 slots.
  - `Stands.EggStand_1…16`: 2.3 studs per unit, facing +X down the stairs, glowing `Accent` ring coloured per egg. Each stand holds its egg model.
  - `Egg_1…16`: invisible hitboxes with `Price`, `EggName` and the price billboard. Use them for the hatch prompt. Slot 16 is the visible "coming soon" placeholder.
- `World2Portal`: placeholder pad 90 × 60 at (−300, 2, −1720). The real portal replaces it.
- `SpawnFeatures`: empty (the spin wheel and daily rewards became UI).

## Elsewhere
- `ReplicatedStorage.Swords`: the 15 master swords, upright, pivot on the guard.
- `ServerStorage.NatureLibrary`: the nature pack clone source.
- `ServerStorage.OldPlaceholders`: everything replaced, kept just in case (`ZoneSigns`, `EggStands`, the spin wheel and daily-reward placeholders).
- `ServerStorage.PlaceholderSwords`: the old block swords.
