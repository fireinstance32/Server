// Builds every pet with the game's own code (src/shared/Util/Models/Pet)
// under ../blender/preview/roblox_stub.luau and prints the parts as JSON for render_pets.py.
// Lives here because @luau-rs/luau is installed here.
//   node dump-pets.mjs > pets.json
import { Lua } from '@luau-rs/luau';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const sharedRoot = path.resolve(here, '../../src/shared');
const stub = path.resolve(here, '../blender/preview/roblox_stub.luau');

function loadShared(rel) {
  const file = path.join(sharedRoot, rel + '.luau');
  const source = fs.existsSync(file)
    ? fs.readFileSync(file, 'utf8')
    : fs.readFileSync(path.join(sharedRoot, rel, 'init.luau'), 'utf8');
  return source.replace(/require\(script((?:\.Parent)*)((?:\.\w+)+)\)/g, (_, parents, names) => {
    let base = rel;
    for (let i = 0; i < parents.length / '.Parent'.length; i++) base = path.posix.dirname(base);
    const tail = names.slice(1).replaceAll('.', '/');
    return `require("@shared/${base === '.' ? '' : base + '/'}${tail}")`;
  });
}

const lua = await Lua.create({
  sandbox: false,
  resolveModule: (spec) => spec.startsWith('@shared/') ? { name: spec, source: loadShared(spec.slice(8)) } : null,
});
const out = [];
lua.globals.set('emit', lua.createFunction((s) => { out.push(s); }));
const driver = fs.readFileSync(stub, 'utf8') + `
local Pets = require("@shared/Config/Pets")
local PetLooks = require("@shared/Config/PetLooks")
local Pet = require("@shared/Util/Models/Pet")
local PetFaces = require("@shared/Config/PetFaces")
-- Preview as if every image were uploaded (decal Name = texture file name).
for name in PetFaces.Images do
	PetFaces.Images[name] = 1
end
for _, def in Pets.List do
	PARTS = {}
	Pet.build(def.color, 1, PetLooks.ByPet[def.id], def.rarity)
	local rows = {}
	for _, p in PARTS do
		local c = p.CFrame
		local decals = {}
		for _, child in p:GetChildren() do
			if child.ClassName == "Decal" then
				table.insert(decals, string.format('{"name":"%s","face":"%s","color":[%f,%f,%f],"z":%d}',
					child.Name, tostring(child.Face), child.Color3.R, child.Color3.G, child.Color3.B, child.ZIndex))
			end
		end
		table.insert(rows, string.format('{"name":"%s","shape":"%s","size":[%f,%f,%f],"pos":[%f,%f,%f],"rot":[%s],"color":[%f,%f,%f],"alpha":%f,"decals":[%s]}',
			p.Name or "", tostring(p.Shape), p.Size.X, p.Size.Y, p.Size.Z, c.p[1], c.p[2], c.p[3],
			table.concat(c.r, ","), p.Color.R, p.Color.G, p.Color.B, p.Transparency, table.concat(decals, ",")))
	end
	emit(string.format('{"id":"%s","name":"%s","look":"%s","parts":[%s]}', def.id, def.name, PetLooks.ByPet[def.id] or "bear", table.concat(rows, ",")))
end
`;
lua.execute(driver, { name: 'dump' });
console.log('[' + out.join(',\n') + ']');
