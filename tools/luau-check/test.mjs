// Runs tests/*.spec.luau against pure modules in src/shared (no Roblox APIs).
// In specs: require("@shared/Util/Format") loads src/shared/Util/Format.luau,
// and require("@test") gives test/equal/near helpers.
import { Lua } from '@luau-rs/luau';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const sharedRoot = path.resolve(here, '../../src/shared');
const testsDir = path.join(here, 'tests');

const HARNESS = `
local t = { passed = 0, failed = 0 }
function t.test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		t.passed += 1
	else
		t.failed += 1
		print("  FAIL " .. name .. ": " .. tostring(err))
	end
end
function t.equal(actual, expected)
	if actual ~= expected then
		error(string.format("expected %s, got %s", tostring(expected), tostring(actual)), 2)
	end
end
function t.near(actual, expected, eps)
	if math.abs(actual - expected) > (eps or 1e-9) then
		error(string.format("expected ~%s, got %s", tostring(expected), tostring(actual)), 2)
	end
end
return t
`;

let failed = 0;
let passed = 0;
for (const file of fs.readdirSync(testsDir).filter((f) => f.endsWith('.spec.luau'))) {
  const lua = await Lua.create({
    sandbox: false,
    resolveModule: (specifier) => {
      if (specifier === '@test') return { name: '@test', source: HARNESS };
      if (specifier.startsWith('@shared/')) {
        const rel = specifier.slice('@shared/'.length);
        const source = fs.readFileSync(path.join(sharedRoot, rel + '.luau'), 'utf8');
        return { name: specifier, source };
      }
      return null;
    },
  });
  const output = [];
  lua.globals.set('print', lua.createFunction((...args) => { output.push(args.join('\t')); }));
  const spec = fs.readFileSync(path.join(testsDir, file), 'utf8');
  const source = spec + '\nlocal __t = require("@test")\nreturn __t.passed, __t.failed\n';
  try {
    const [p, f] = lua.execute(source, { name: file });
    passed += p;
    failed += f;
    console.log(`${f ? 'FAIL' : 'ok  '} ${file} (${p} passed, ${f} failed)`);
  } catch (err) {
    failed += 1;
    console.log(`FAIL ${file}: ${err.message}`);
  }
  for (const line of output) console.log(line);
}
console.log(`${passed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
