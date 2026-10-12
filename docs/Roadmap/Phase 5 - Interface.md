---
tags: [planning, phase5]
---
# Phase 5 – Interface
*Goal: every screen looks and feels like the references. All systems exist by now (Phases 1–4), so the UI is built once against final data.* Back to [[Roadmap]]. References: [[HUD References]], [[Stone Skipping UI Breakdown]].

> **How we work (decided 2026-10-12):** you design each screen in Figma (file "Frog Hop UI") and send me the frame link. I read it once (1 of the 20 monthly Figma calls) and write the Luau UI code that rebuilds it in the game — you never touch code. Order: Design System → HUD → Menus → Hatch → World UI.

## 5.1 Design system
- [ ] Final fonts, colour tokens, stroke weights, corner radii
- [ ] Image assets: studded "brick" panel texture, button art, Robux chip, icons for every menu and stat (replace emoji)
- [ ] Component library: tile, pass card, pack button, badge, window, tabs, list rows, progress bar

## 5.2 HUD to reference
- [ ] Rebuild the HUD from the references measurement by measurement: sizes, spacing, positions, text styles
- [ ] Tile grid, pass cards, Auto Hop, Level bar + stat row + packs, bottom-left counters, quest bar
- [ ] Badges (! / % / NEW! / timers) driven by real systems

## 5.3 Menus pass
- [ ] Shop (sections, pack cards with contents tiles), Rebirth (Before → After), My Pets (tabs, list + details panel, Auto Delete, Sort, Index), Inventory, Daily Rewards, Gifts, Trails, Settings

## 5.4 Reward & hatch animations
- [ ] Egg hatch: blur, click to crack, reveal card (NEW!, chance %), multi-hatch layout
- [ ] Level up, rebirth, purchase, daily claim celebrations

## 5.5 World UI
- [ ] Billboards: egg odds panel (E / R / T), pond and podium signs, zone names, portal gates, limited-stock counters, leaderboards

## 5.6 Feedback & juice
- [ ] Button squish/hover, number count-ups, floating "+N", toasts, sound hooks on every interaction

## 5.7 Mobile & console layouts
- [ ] Phone layout (scaled tiles, thumb-reach HOP button), tablet, gamepad navigation

## 5.8 Playtest 🧪
- [ ] I write the test plan ("Phase 5 Playtest"), you run it in Studio (see [[Testing Guide]]), we fix what you find
- **Done when:** every check in the playtest note passes.
