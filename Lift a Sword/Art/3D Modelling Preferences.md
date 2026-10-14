---
tags: [lift-a-sword, art, preferences]
---
# 3D Modelling Preferences

What I've learned about how you like models, from your feedback while building Lift a Sword (and the Frog Hop pets). I read this before modelling anything. **Add to it whenever you react to a model**: if you say "too blocky", "way bigger", "love it", the rule goes here with the date.

Back to [[Lift a Sword]] · how the tools work: [[Model Pipeline]] · what's built: [[Model Status]]

## The look
- **Smooth, rounded, chunky, with a low-poly feel.** Not realistic, not blocky. When the first swords came out boxy you said they "look blocky", and when I pushed them towards detailed realism you said that "won't fit the game", so keep them "kind of how they were, just smoothed and not so blocky", "still the low poly kind of vibe" (2026-10-13). Bevelled edges, soft corners, clean silhouettes.
- **Roblox simulator style.** Bright, saturated, toy-like, readable from far away. Think front-page simulator thumbnails, not a realistic RPG.
- **Glow accents work.** Neon parts (gems, veins, rings, runes, keyholes, halos) make tiers feel special. Each themed set gets its own glow colour.
- **Mixed sizes for scattered details.** Splinters, shards, stars and +1s look best as "little ones and then bigger ones" rather than a uniform field (pedestal collars 2026-10-13, the +1 overlay).
- **Make it physically believable.** Ropes and wraps go all the way around ("the rope needs to wrap around?", Stone Sword), nothing floats, legs and supports look structural, and attachments touch what they attach to.

## Quality bar
- "High quality" / "way higher quality" means **more real detail**, not more noise: separate pieces like planks with grooves, rivets, hex studs, trim lines, real faceted gems in gold bezels, handles, hinges, a platform or base with runes, little extras like coin piles. Compare [[#Group chest v1 → v2]].
- Every model should have a **hero detail** that reads at a glance: a crest, a gem, a glowing core.
- Keep each mesh under Roblox's **20k-triangle limit** (split a role, or simplify tiny repeated pieces like rivets).

## Size
- **You like things big.** "Yes even bigger" (map), "make the chest way bigger" (2026-10-14). Landmarks and interactables should dominate their spot.
- **Except the map's width.** After I widened the zones you asked to change them back to how wide they were but keep the length. So scale up objects, not the playable layout, unless asked.

## Textures vs flat colour
| Category | What you chose |
|---|---|
| Swords, pedestals, eggs, egg stand, signs | **Baked PBR textures** (wood grain, stone, metal, galaxy…). You called the textured Galaxy Sword "fantastic". |
| Landmarks (World 2 portal, group chest) | **Flat colours, no textures** (2026-10-14). |
| Reference stud textures | Ignore them ("don't worry about the stud texture"). |

Default for something new: **ask which way you want it.** If you're busy, use textures for zone-themed tier items and flat glossy colour for big landmarks.

## References
- You send reference images to **look at, not copy**: "not that I want you to make them like this but just to look at" (eggs), "a portal like this but fitting our game".
- Take the **shape language** from the reference and re-theme it to swords: crossed swords, shields, gold and steel, gems.
- When you say "replicate" or "literally the same" (UI, 2026-10-12), you mean a near-exact copy. For models you haven't said that so far.

## Fit in the game
- **Sword in the stone:** the sword must look like it's IN the pedestal, but you have to see the handle **and** some bare blade ("the handle isn't here", "you can't really see the blade even a little"). Rule: 3 studs of bare blade between the slot and the guard.
- Swords are turned so the blade's flat face looks at the player.
- Everything I build must be **visible in Studio in edit mode**, not only when you press Play (2026-10-13).
- Lids, doors and anything that animates are built as separate parts.

## How you like to work
- **Show a preview render before exporting**, and a **before/after** when I improve something ("make them better, and then a before and after picture").
- **Trial one first** for a big batch change ("do the first pedestal and I'll see if it's worth it"), then roll it out to all 15.
- **Small feedback means a small change.** "Maybe make it less", then "tone it up a little": adjust in steps, don't redo it.
- **Use my judgement:** "do what you think is best". Make the call, show it, and note it here.
- **You import the FBX files yourself** (the Studio 3D importer). I then scale, colour, place and anchor them through the Studio MCP and tell you exactly which files to import.

## Rejected (don't repeat)
- **Chibi pets** (round bodies, big eyes, blush) for Lift a Sword: "we don't want pets like that" (2026-10-13). For Frog Hop: "I need it to look like an actual roblox pet, I'll send references". **Pets are on hold; ask for references and a style before starting.**
- **Blocky, boxy shapes** (first swords).
- **Over-detailed realism** that doesn't fit the simulator style.
- **Props nobody asked for:** spin wheel, daily rewards, fountain and loot chests were modelled and dropped. The spin wheel and daily rewards are UI. Confirm the list before building props.

## Approved examples
![[LS Swords Before After.jpg]]
*Swords: the blocky first pass (before) vs smooth and textured (after). This is the style.*

![[LS Pedestals.jpg]]
*Themed pedestals with the blade slot.*

![[LS Eggs.jpg]]

### Group chest v1 → v2
v1 was a small, simple chest. v2 (2026-10-14), after "way bigger and way higher quality", added planks over a dark core, a riveted frame, hex-stud posts, gem knobs, ring handles, hinges, a padlock with a glowing keyhole, a planked lid with shield emblems and a top gem, and a rune platform with coin piles. Flat colours.
![[LS Group Chest.jpg]]
