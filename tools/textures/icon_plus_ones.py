"""Scatters small white "+1"s (black outline, like simulator thumbnails) over an image.

    python3 tools/textures/icon_plus_ones.py <in.png> <font.ttf> <out.png>

font: Luckiest Guy TTF (Google Fonts, Apache 2.0).
Positions are tuned for docs/Art/Launch/game_icon.png (512x512).
"""

import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SRC, FONT, OUT = sys.argv[1:4]
INK = (20, 20, 24, 255)


def plus_one(size, rotate):
    """White "+1" with a thick dark outline and a soft drop shadow."""
    font = ImageFont.truetype(FONT, size)
    stroke = max(3, round(size * 0.13))
    box = ImageDraw.Draw(Image.new("L", (1, 1))).textbbox((0, 0), "+1", font=font, stroke_width=stroke)
    pad = stroke * 2
    w, h = box[2] - box[0] + pad * 2, box[3] - box[1] + pad * 2
    origin = (pad - box[0], pad - box[1])
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    shadow = Image.new("L", layer.size, 0)
    ImageDraw.Draw(shadow).text((origin[0] + stroke * 0.3, origin[1] + stroke * 0.7), "+1", font=font, fill=110, stroke_width=stroke, stroke_fill=110)
    layer.paste((0, 0, 0, 255), (0, 0), shadow.filter(ImageFilter.GaussianBlur(stroke * 0.5)))
    outline = Image.new("L", layer.size, 0)
    ImageDraw.Draw(outline).text(origin, "+1", font=font, fill=255, stroke_width=stroke, stroke_fill=255)
    layer.paste(INK, (0, 0), outline)
    glyphs = Image.new("L", layer.size, 0)
    ImageDraw.Draw(glyphs).text(origin, "+1", font=font, fill=255)
    layer.paste((255, 255, 255, 255), (0, 0), glyphs)
    return layer.rotate(rotate, resample=Image.BICUBIC, expand=True)


base = Image.open(SRC).convert("RGBA")
# (size, x, y, rotation) — kept clear of the big +1, the bolt and the frog.
for size, x, y, rot in (
    (62, 445, 262, -12),
    (54, 330, 205, 10),
    (58, 70, 300, 14),
    (50, 92, 455, -10),
    (60, 430, 445, 12),
    (44, 300, 42, -8),
):
    layer = plus_one(size, rot)
    base.alpha_composite(layer, (round(x - layer.width / 2), round(y - layer.height / 2)))
base.convert("RGB").save(OUT)
print("Wrote", OUT)
