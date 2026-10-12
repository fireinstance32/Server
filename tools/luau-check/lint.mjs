// Lints every .luau file with Roblox globals declared. Roblox *types* are not
// loaded (the full definition file is too large for the WASM analyzer), so
// 'Unknown type' noise is filtered out.
import { Analysis } from '@luau-rs/luau/analysis';
import fs from 'node:fs'; import path from 'node:path';
const root = process.argv[2];
const G = ['game','workspace','script','Enum','Instance','Vector3','Vector2','CFrame','Color3','UDim','UDim2','TweenInfo','Random','Ray','RaycastParams','NumberSequence','ColorSequence','ColorSequenceKeypoint','NumberSequenceKeypoint','Faces','Axes','PathWaypoint','CatalogSearchParams','OverlapParams','SharedTable','buffer','utf8','NumberRange','task','warn','tick','time','typeof','plugin','shared','DateTime','Rect','BrickColor','PhysicalProperties','Region3','Font'];
const a = await Analysis.create({ mode: 'nonstrict', lint: true, globals: G });
const files = [];
(function walk(d){ for (const e of fs.readdirSync(d,{withFileTypes:true})) { const p=path.join(d,e.name); if (e.isDirectory()) walk(p); else if (/\.luau$/.test(e.name)) files.push(p);} })(root);
for (const f of files) a.setModule(f, fs.readFileSync(f,'utf8'), 'module');
let n=0;
for (const f of files) {
  const r = a.check(f);
  for (const d of r.diagnostics) { if (/Unknown type|Unknown require|not found/.test(d.message)) continue; n++; console.log(`${f}:${d.location.begin.line+1}:${d.location.begin.column+1} [${d.kind}/${d.severity}] ${d.message.split('\n')[0]}`); }
}
console.log(`${n} diagnostics`);
process.exit(n ? 1 : 0);
