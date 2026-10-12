---
tags: [design, launch]
---
# Launch Kit

Back to [[Phase 8 - Live Ops]]. Everything needed to publish +1 Frog Hop.

## Store page
**Title:** `+1 Frog Hop` (with an update tag later, e.g. `[🎃 HALLOWEEN] +1 Frog Hop`)

**Description:**
> Every hop makes your frog stronger! 🐸
> Hop across lily pads to gain +Hops, launch your frog down the river and see how far it goes. The further you hop, the more Wins you earn!
>
> 🐸 Unlock 25+ frogs
> 🥚 Hatch pets that boost your hops
> 🌍 Travel through 5 worlds: Lily Valley, Mushroom Swamp, Candy Falls, Cosmic Cove and Lava Springs
> 🔁 Rebirth for permanent boosts
> 🏆 Top the leaderboards for the longest hop
> 🎁 Daily rewards, free gifts and codes
>
> 👍 Like and ⭐ favourite for more updates and codes!

**Genre:** Simulator · **Max players:** 12 (more players = more Friend Boost and busier boards)

## Assets (to do, after the [[Art Pipeline]] models)
- [ ] Icon 512×512: big smiling frog mid-hop, "+1" in yellow, bright green/blue background (no small text)
- [ ] 3–5 thumbnails 1920×1080: river hop with zone banner, egg hatch, 5 worlds, giant frog, leaderboard
- [ ] Trailer 15–30 s: press HOP → numbers fly → long river hop → new world portal
- Render frog shots in Blender (Cycles) from the Phase 6 models; final layout in Figma

## Publish checklist
- [ ] Create every pass/product and paste ids ([[Monetization Setup]])
- [ ] Game Settings → Security: API Services on (DataStores), Third-party sales off
- [ ] Test commands: `Config/Dev.luau` → `AllowedUserIds` lists only you (they always work in Studio)
- [ ] Maturity questionnaire, privacy (public), devices: Computer, Phone, Tablet (console after 5.7)
- [ ] Set server size and turn on "Allow Private Servers" (free or cheap — helps recording creators)
- [ ] Play the live game once on PC + phone before announcing
- [ ] Post first code (e.g. `LAUNCH`) in `Config/Codes.luau`

## After launch
- Watch the Onboarding funnel daily; fix the biggest drop first
- Events: next one goes in `Config/Events.luau` (dates, currency, pets, egg)
