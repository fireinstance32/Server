"""Scatters white "+1"s (thin dark outline, grey 3D depth, slanted) over an image.

    python3 tools/textures/icon_plus_ones.py <in.png> <font.ttf> <out.png>

font: Luckiest Guy TTF (Google Fonts, Apache 2.0).
Style follows simulator thumbnails: huge +1s in the bottom corners, small ones
swarming round the character, a couple overlapping it. Positions and sizes are
fractions of the image.
"""

import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SRC, FONT, OUT = sys.argv[1:4]
INK = (34, 34, 44, 255)
DEPTH = (150, 156, 172, 255)
TEXT = "+1"


def plus_one(size, rotate):
    """White "+1": soft shadow, grey extrusion, thin outline, slanted then rotated."""
    font = ImageFont.truetype(FONT, size)
    stroke = max(2, round(size * 0.06))
    depth = max(2, round(size * 0.07))
    box = ImageDraw.Draw(Image.new("L", (1, 1))).textbbox((0, 0), TEXT, font=font, stroke_width=stroke)
    pad = stroke + depth * 2
    w, h = box[2] - box[0] + pad * 2, box[3] - box[1] + pad * 2
    ox, oy = pad - box[0], pad - box[1]

    def mask(dx, dy, outlined):
        m = Image.new("L", (w, h), 0)
        sw = stroke if outlined else 0
        ImageDraw.Draw(m).text((ox + dx, oy + dy), TEXT, font=font, fill=255, stroke_width=sw, stroke_fill=255)
        return m

    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    shadow = mask(depth * 0.6, depth * 1.6, True).point(lambda v: v * 120 // 255)
    layer.paste((0, 0, 0, 255), (0, 0), shadow.filter(ImageFilter.GaussianBlur(depth * 0.8)))
    for d in range(depth, 0, -1):  # outlined extrusion stacked downwards
        layer.paste(INK, (0, 0), mask(d * 0.3, d, True))
    for d in range(depth, 0, -1):
        layer.paste(DEPTH, (0, 0), mask(d * 0.3, d, False))
    layer.paste(INK, (0, 0), mask(0, 0, True))
    layer.paste((255, 255, 255, 255), (0, 0), mask(0, 0, False))
    # Italic slant, then the tilt.
    shear = 0.18
    layer = layer.transform((w + round(h * shear), h), Image.AFFINE, (1, shear, -h * shear, 0, 1, 0), Image.BICUBIC)
    return layer.rotate(rotate, resample=Image.BICUBIC, expand=True)


base = Image.open(SRC).convert("RGBA")
W, H = base.size
# (size, x, y, rotation) as fractions of the image.
for size, x, y, rot in (
    # Huge ones in the bottom corners.
    (0.22, 0.15, 0.84, 20),
    (0.20, 0.86, 0.80, 14),
    # Mid-size round the sides.
    (0.11, 0.12, 0.33, 16),
    (0.10, 0.88, 0.30, 10),
    (0.09, 0.10, 0.58, 22),
    # Small ones swarming the chef, two on top of him.
    (0.075, 0.27, 0.17, 14),
    (0.07, 0.71, 0.13, -18),
    (0.08, 0.27, 0.43, 18),
    (0.07, 0.73, 0.33, 12),
    (0.08, 0.75, 0.52, 20),
    (0.065, 0.36, 0.53, 8),
):
    layer = plus_one(round(size * W), rot)
    base.alpha_composite(layer, (round(x * W - layer.width / 2), round(y * H - layer.height / 2)))
base.convert("RGB").save(OUT)
print("Wrote", OUT)
