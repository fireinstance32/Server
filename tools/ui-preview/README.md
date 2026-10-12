# UI preview

Runs the game's real UI code (src/client/UI) offline under a Roblox
stand-in (`stub.luau`), then lays out and draws the GUI tree in headless
Chromium (`page.js`) and saves a screenshot. Lets UI work be checked without
Studio.

```
cd tools/ui-preview && npm install
node run.mjs hud          # → out/hud.png
node run.mjs <scene>      # scenes/<scene>.luau
```

- Scenes build UI and send sample player data (`lib/sample.luau`).
- Images: ids in `Config/UiImages.luau` / `Config/PetFaces.luau` are drawn
  from `assets/textures/...` PNGs, uploaded or not.
- Not covered: 3D (ViewportFrames show a soft glow), animations (tweens jump
  to their end), BillboardGuis.
