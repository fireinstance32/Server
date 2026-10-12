---
tags: [planning]
---
# Roadmap

Build order for +1 Frog Hop. Each phase builds on the one before it, so finish a phase before starting the next. Reference for every item: [[Stone Skipping UI Breakdown]].

**Naming:** Skill → **Hops**, Stone → **Frog**, Throw → **Hop**, Throw Zone → **Hop Zone**, Relic → **Legend Frog**.

---

## Phase 0 – Foundation ✅ (2026-10-12)
- [x] Rojo project (port 34873), toolchain, offline Luau checks
- [x] Data saving, leaderstats, server-authoritative remotes
- [x] Greybox loop: train → launch → zones → Wins
- [x] First pass at frog shop, eggs/pets, rebirth, codes
- [x] Obsidian vault

---

## Phase 1 – Core loop parity
*Goal: the moment-to-moment loop feels like Stone Skipping.*
- [ ] **Hop Zone** strip at the river start; the HOP button appears only while you stand on it
- [ ] **Hold-and-toss**: the character holds the equipped frog (tool) and plays a wind-up/throw animation, then the frog hops down the river
- [ ] **Distance meter** ("123 m") counting up during the hop, with the camera following the frog
- [ ] **Training ponds row**: ponds gated by rebirths (0→1x, 2→4x, 4→10x, 6→20x), with LOCKED/UNLOCKED signs
- [ ] **Training pad + AUTO toggle**: stand on a pad, "+1 Hops" pops per bounce, auto-repeat (free for training)
- [ ] **Level system**: Hops → XP → Level; Level adds to the multiplier; the **level cap rises with each rebirth** ("MAX LEVEL")
- [ ] **HUD rework to the reference layout**: Hops + xMultiplier above the Level bar (bottom centre); Rebirths/Wins/Friend Boost (bottom-left)
- [ ] River **biome sections** with floating names (Lily Shallows → Reed Bend → …)

## Phase 2 – Collection
*Goal: always something to unlock.*
- [ ] **Frog podiums** in the world: each frog on a pedestal with LOCKED/UNLOCKED, "+N Hops" and price; walk up to buy/equip
- [ ] **Egg row**: Common / Uncommon / Rare (Wins) + one Robux egg; price signs floating above
- [ ] **Hatch animation**: egg shake → crack → reveal card with rarity colour
- [ ] **Pets UI** rework: inventory grid, equip best, delete, multiplier totals
- [ ] **Trails**: cosmetic + small boost; Trails menu
- [ ] **Inventory** menu (frogs, pets, trails, potions)

## Phase 3 – Retention
*Goal: reasons to come back tomorrow.*
- [ ] **Tutorial quest bar** ("GET 2 WINS (1/2)" → buy a frog → hatch an egg → rebirth)
- [ ] **Potions**: Hops, Wins, Luck (timed, stackable) + active-potion timers on the HUD
- [ ] **Daily Rewards**: 7-day calendar (potions on days 1–6, a pet on day 2, limited Legend Frog on day 7)
- [ ] **Offline training**: earn Hops while logged out (capped hours) + "welcome back" pop-up
- [ ] **Friend Boost**: +X% per friend in the server, with an invite button
- [ ] **Gifts**: playtime gifts (claim every N minutes)
- [ ] **Notification dots** on side-menu buttons (rebirth ready, gift ready…)
- [ ] **Tip ticker** marquee at the top

## Phase 4 – Monetization
*Goal: the full shop, wired and tested in Studio.*
- [ ] **Shop UI** with tabs: Passes / Products / Gift
- [ ] Passes: **Auto Hop**, **2x Hops**, **2x Wins**, Extra Pet Slots, +Pet Inventory
- [ ] Right-side pass buttons (Starter Pack, 2x Hops, 2x Wins)
- [ ] **+10K / +100K / +1M Hops** packs under the Level bar
- [ ] **Robux ponds** valid in all worlds (3x / 15x / 50x)
- [ ] **Legend Frog** + **limited premium pet** with a **global stock counter** ("STOCK 157/1000")
- [ ] Robux eggs (x1 / x3 / x8 hatch), Skip Rebirth, Offline x2
- [ ] **[GIFT]** version of every product (buy for another player)
- [ ] Starter Pack (one-time bundle)

## Phase 5 – Spectacle
*Goal: moments worth clipping for TikTok and YouTube Shorts.*
- [ ] Real frog / pet / egg meshes (replacing the part-built placeholders)
- [ ] Splash particles per pad, confetti on new zone, landing burst
- [ ] **Legend Frog ultimate hop**: anime cut-in, beam, explosion, aura
- [ ] Sounds: hop, splash, purchase, hatch, level up; music
- [ ] World art pass: hub layout, props, river banks, lighting

## Phase 6 – Worlds
*Goal: long-term progression.*
- [ ] World framework: per-world config (frogs, eggs, ponds, zones, river biomes)
- [ ] **Portals** gated by distance ("WORLD 2 – HOP 100M") + teleport between unlocked worlds
- [ ] World 2 (Swamp), World 3 (Candy), World 4 (Space), World 5 (Lava)

## Phase 7 – Live ops & launch
*Goal: ship it and keep it fresh.*
- [ ] Leaderboards: Best Distance, Top Time Played, Top Robux Spent
- [ ] **Seasonal event framework**: countdown banner, event props, event egg (first one: Halloween)
- [ ] Analytics events (funnel: join → first hop → first frog → first rebirth)
- [ ] Anti-exploit pass (remote rate limits, sanity checks)
- [ ] Mobile/console UI pass
- [ ] Icon, thumbnails, trailer, publish

---

## Next up
Phase 1, starting with the **Hop Zone + hold-and-toss + distance meter**: the core feel everything else hangs on.

See also: [[Balancing]], [[Monetization]], [[Core Loop]].
