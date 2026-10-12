// Rasterises every SVG in a folder with Chromium (exact gradients/strokes).
//   node tools/ui-preview/svg2png.mjs <svg_dir> <out_dir> [size=512] [prefix=icon_]
import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';

const [dir, out, sizeArg, prefixArg] = process.argv.slice(2);
const size = Number(sizeArg ?? 512);
const prefix = prefixArg ?? 'icon_';
fs.mkdirSync(out, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: size, height: size } });
const files = fs.readdirSync(dir).filter((f) => f.endsWith('.svg')).sort();
for (const file of files) {
  const svg = fs.readFileSync(path.join(dir, file), 'utf8')
    .replace(/width="[\d.]+" height="[\d.]+"/, `width="${size}" height="${size}"`);
  await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
  await page.locator('svg').screenshot({ path: path.join(out, prefix + file.replace(/\.svg$/, '.png')), omitBackground: true });
}
await browser.close();
console.log(`Rendered ${files.length} SVGs to ${out}`);
