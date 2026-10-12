// Compiles every .luau file to catch syntax errors without Roblox Studio.
import { Lua } from '@luau-rs/luau';
import fs from 'node:fs'; import path from 'node:path';
const lua = await Lua.create({ sandbox: true });
const files = [];
(function walk(d){ for (const e of fs.readdirSync(d,{withFileTypes:true})) { const p=path.join(d,e.name); if (e.isDirectory()) walk(p); else if (/\.luau?$/.test(e.name)) files.push(p);} })(process.argv[2]);
let bad = 0;
for (const f of files) { try { lua.compile(fs.readFileSync(f,'utf8'), { chunkName: f }); } catch (e) { bad++; console.log('FAIL', f, '\n  ', e.message); } }
console.log(`${files.length - bad}/${files.length} files compile`);
process.exit(bad ? 1 : 0);
