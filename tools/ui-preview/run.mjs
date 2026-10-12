// UI preview: runs a scene (scenes/<name>.luau) that builds the game's real
// UI under stub.luau, then lays out + draws the GUI tree in Chromium and
// saves a screenshot.
//
//   node run.mjs <scene> [out.png]      e.g. node run.mjs hud out/hud.png
//
// Images: rbxassetid ids listed in src/shared/Config/UiImages.luau (and
// PetFaces.luau) are drawn from the matching local PNGs.
import { Lua } from '@luau-rs/luau';
import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '../..');
const roots = { shared: path.join(repo, 'src/shared'), client: path.join(repo, 'src/client') };

const scene = process.argv[2] || 'hud';
const out = path.resolve(process.argv[3] || path.join(here, 'out', `${scene}.png`));

function readModule(root, rel) {
  const file = path.join(roots[root], rel + '.luau');
  if (fs.existsSync(file)) return fs.readFileSync(file, 'utf8');
  return fs.readFileSync(path.join(roots[root], rel, 'init.luau'), 'utf8');
}

// Rewrites Roblox-style requires into "@root/path" strings.
function rewrite(root, rel, source) {
  return source
    .replace(/require\(script((?:\.Parent)*)((?:\.\w+)+)\)/g, (_, parents, names) => {
      let base = rel;
      for (let i = 0; i < parents.length / '.Parent'.length; i++) base = path.posix.dirname(base);
      const tail = names.slice(1).replaceAll('.', '/');
      return `require("@${root}/${base === '.' ? '' : base + '/'}${tail}")`;
    })
    .replace(/require\(Shared((?:\.\w+)+)\)/g, (_, names) => `require("@shared/${names.slice(1).replaceAll('.', '/')}")`)
    .replace(/require\(ReplicatedStorage:WaitForChild\("Shared"\)((?:\.\w+)+)\)/g, (_, names) => `require("@shared/${names.slice(1).replaceAll('.', '/')}")`);
}

// Modules are compiled by a Lua-side require (the package caps resolveModule
// at 32 modules; the client UI needs more).
function sourceFor(spec) {
  if (spec.startsWith('@preview/')) return fs.readFileSync(path.join(here, 'lib', spec.slice(9) + '.luau'), 'utf8');
  const m = spec.match(/^@(shared|client)\/(.*)$/);
  if (!m) throw new Error(`can't resolve ${spec}`);
  return rewrite(m[1], m[2], readModule(m[1], m[2]));
}
// Bundle every module the scene needs into one chunk (the package caps
// resolveModule at 32 modules and has no loadstring).
function bundle(entrySource) {
  const seen = new Map();
  const queue = [...entrySource.matchAll(/require\("(@[^"]+)"\)/g)].map((m) => m[1]);
  while (queue.length) {
    const spec = queue.shift();
    if (seen.has(spec)) continue;
    const src = sourceFor(spec).replace(/^export type /gm, 'type ');
    seen.set(spec, src);
    for (const m of src.matchAll(/require\("(@[^"]+)"\)/g)) queue.push(m[1]);
  }
  let out = 'local __modules, __cache = {}, {}\n';
  for (const [spec, src] of seen) {
    out += `__modules[${JSON.stringify(spec)}] = function()\n${src}\nend\n`;
  }
  out += `function require(spec)
	if type(spec) ~= "string" then error("preview require expects a path string, got " .. typeof(spec), 2) end
	local hit = __cache[spec]
	if hit ~= nil then return hit end
	local fn = __modules[spec]
	if not fn then error("module not bundled: " .. spec, 2) end
	local result = fn()
	__cache[spec] = result
	return result
end
`;
  return out;
}
const lua = await Lua.create({ sandbox: false });
const logs = [];
lua.globals.set('print', lua.createFunction((...a) => { logs.push(a.join('\t')); }));
let tree = null;
lua.globals.set('emit', lua.createFunction((s) => { tree = s; }));

const stub = fs.readFileSync(path.join(here, 'stub.luau'), 'utf8');
const sceneSource = fs.readFileSync(path.join(here, 'scenes', `${scene}.luau`), 'utf8');
try {
  lua.execute(stub + '\n' + bundle(sceneSource) + '\n' + sceneSource + '\nemit(DUMP_GUI())\n', { name: scene });
} catch (err) {
  console.error(err.message);
  for (const l of logs) console.error(l);
  process.exit(1);
}
for (const l of logs) console.log(l);

// Image ids -> local files, from the configs that name them.
const assets = {};
function mapIds(configRel, fileFor) {
  const file = path.join(roots.shared, configRel);
  if (!fs.existsSync(file)) return;
  for (const m of fs.readFileSync(file, 'utf8').matchAll(/(\w+)\s*=\s*(\d{3,})/g)) {
    const local = fileFor(m[1]);
    if (local && fs.existsSync(local)) assets[m[2]] = pathToFileURL(local).href;
  }
}
mapIds('Config/UiImages.luau', (name) => path.join(repo, 'assets/textures/ui', `${name}.png`));
mapIds('Config/PetFaces.luau', (name) => path.join(repo, 'assets/textures/pets', `${name}.png`));
// Preview-only: draw not-yet-uploaded UI images from their local files.
for (const f of fs.existsSync(path.join(repo, 'assets/textures/ui')) ? fs.readdirSync(path.join(repo, 'assets/textures/ui')) : []) {
  assets[`local:${f.replace(/\.png$/, '')}`] = pathToFileURL(path.join(repo, 'assets/textures/ui', f)).href;
}

const font = pathToFileURL(path.join(here, 'node_modules/@fontsource/fredoka-one/files/fredoka-one-latin-400-normal.woff2')).href;
const background = pathToFileURL(path.join(here, 'background.png')).href;
const html = `<!doctype html><html><head><meta charset="utf-8"><style>
@font-face { font-family: "Fredoka One"; src: url("${font}") format("woff2"); }
html, body { margin: 0; width: 1920px; height: 1080px; overflow: hidden; }
body { background: url("${background}") center/cover, linear-gradient(#8fd3ff, #c9f0ff 55%, #7ccf62 55%, #5fb94a); }
div, span { box-sizing: border-box; }
</style></head><body><div id="root"></div>
<script>window.ASSETS = ${JSON.stringify(assets)};</script>
<script>${fs.readFileSync(path.join(here, 'page.js'), 'utf8')}</script>
</body></html>`;

fs.mkdirSync(path.dirname(out), { recursive: true });
const htmlPath = out.replace(/\.png$/, '.html');
fs.writeFileSync(htmlPath, html);
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
page.on('console', (msg) => console.log('[page]', msg.text()));
page.on('pageerror', (err) => console.log('[page error]', err.message));
await page.goto(pathToFileURL(htmlPath).href);
await page.evaluate(async (t) => { await document.fonts.load('40px "Fredoka One"'); window.renderTree(JSON.parse(t)); }, tree);
await page.waitForTimeout(150);
await page.screenshot({ path: out });
await browser.close();
console.log(`Saved ${out}`);
