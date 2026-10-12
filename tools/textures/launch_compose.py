"""Adds titles and vector icons to the Blender launch renders.

    python3 tools/textures/launch_compose.py <raw_dir> <icon_dir> <font.ttf> <out_dir>

raw_dir:  icon_raw.png, thumb1_raw.png, thumb2_raw.png (tools/blender/launch_art.py)
icon_dir: icon_*.png vector icons (tools/ui-preview/svg2png.mjs of assets/vectors/icons)
font:     Fredoka One TTF (the game's UI font)
Writes game_icon.png (512) and thumbnail_1.png / thumbnail_2.png (1920×1080).
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAW, ICONS, FONT, OUT = sys.argv[1:5]
os.makedirs(OUT, exist_ok=True)
INK = (26, 24, 36, 255)


def gradient(size, top, bottom):
    w, h = size
    grad = Image.new("RGBA", (1, h))
    for y in range(h):
        t = y / max(h - 1, 1)
        grad.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,))
    return grad.resize((w, h))


def title(text, size, top, bottom, stroke, rotate=0.0):
    """Big outlined gradient text with a drop shadow, as an RGBA image."""
    font = ImageFont.truetype(FONT, size)
    box = ImageDraw.Draw(Image.new("L", (1, 1))).textbbox((0, 0), text, font=font, stroke_width=stroke)
    w, h = box[2] - box[0] + stroke * 4, box[3] - box[1] + stroke * 4
    origin = (stroke * 2 - box[0], stroke * 2 - box[1])
    layer = Image.new("RGBA", (w, h + stroke), (0, 0, 0, 0))
    # Shadow, then the outline, then the gradient fill clipped to the glyphs.
    shadow = Image.new("L", layer.size, 0)
    ImageDraw.Draw(shadow).text((origin[0], origin[1] + stroke * 0.8), text, font=font, fill=150, stroke_width=stroke, stroke_fill=150)
    layer.paste((0, 0, 0, 255), (0, 0), shadow.filter(ImageFilter.GaussianBlur(stroke * 0.4)))
    outline = Image.new("L", layer.size, 0)
    ImageDraw.Draw(outline).text(origin, text, font=font, fill=255, stroke_width=stroke, stroke_fill=255)
    layer.paste(INK, (0, 0), outline)
    glyphs = Image.new("L", layer.size, 0)
    ImageDraw.Draw(glyphs).text(origin, text, font=font, fill=255)
    layer.paste(gradient(layer.size, top, bottom), (0, 0), glyphs)
    # Gloss on the upper half of the letters.
    gloss = Image.new("L", layer.size, 0)
    gloss.paste(glyphs.crop((0, 0, w, origin[1] + size // 3)), (0, 0))
    shine = Image.new("RGBA", layer.size, (255, 255, 255, 0))
    shine.putalpha(gloss.point(lambda v: v * 70 // 255))
    layer.alpha_composite(shine)
    if rotate:
        layer = layer.rotate(rotate, resample=Image.BICUBIC, expand=True)
    return layer


def icon(name, size, rotate=0.0):
    img = Image.open(os.path.join(ICONS, f"icon_{name}.png")).convert("RGBA")
    box = img.split()[3].getbbox()
    img = img.crop(box)
    k = size / max(img.size)
    img = img.resize((round(img.width * k), round(img.height * k)), Image.LANCZOS)
    return img.rotate(rotate, resample=Image.BICUBIC, expand=True) if rotate else img


def put(base, layer, cx, cy):
    base.alpha_composite(layer, (round(cx - layer.width / 2), round(cy - layer.height / 2)))


def vignette(img, strength=0.35):
    w, h = img.size
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).ellipse((-w * 0.15, -h * 0.2, w * 1.15, h * 1.2), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(min(w, h) * 0.12))
    dark = Image.new("RGBA", (w, h), (10, 20, 40, round(255 * strength)))
    dark.putalpha(Image.eval(mask, lambda v: round((255 - v) * strength)))
    img.alpha_composite(dark)


YELLOW = ((255, 246, 120), (255, 170, 0))
WHITE = ((255, 255, 255), (214, 232, 255))
GREEN = ((170, 255, 120), (40, 190, 50))

# Game icon: the crowned frog, a huge "+1" and a bolt.
base = Image.open(os.path.join(RAW, "icon_raw.png")).convert("RGBA").resize((512, 512), Image.LANCZOS)
vignette(base, 0.3)
put(base, title("+1", 210, *YELLOW, 16, rotate=10), 150, 130)
put(base, icon("bolt", 150, -14), 418, 120)
base.convert("RGB").save(os.path.join(OUT, "game_icon.png"))

# Thumbnail 1: the river hop.
base = Image.open(os.path.join(RAW, "thumb1_raw.png")).convert("RGBA")
vignette(base)
put(base, title("HOP FARTHER!", 190, *YELLOW, 18, rotate=3), 960, 190)
put(base, title("+1 Frog Hop", 92, *GREEN, 12, rotate=3), 960, 360)
for name, size, x, y, rot in (("bolt", 220, 230, 640, 16), ("trophy", 230, 1690, 600, -12), ("star", 120, 1500, 860, 14), ("star", 90, 420, 900, -10)):
    put(base, icon(name, size, rot), x, y)
base.convert("RGB").save(os.path.join(OUT, "thumbnail_1.png"))

# Thumbnail 2: the pet line-up.
base = Image.open(os.path.join(RAW, "thumb2_raw.png")).convert("RGBA")
vignette(base, 0.25)
put(base, title("HATCH CUTE PETS!", 150, *WHITE, 16, rotate=-2), 960, 140)
for name, size, x, y, rot in (("egg", 210, 200, 860, -14), ("egg", 170, 1730, 880, 12), ("star", 110, 380, 700, 18), ("star", 100, 1560, 720, -16)):
    put(base, icon(name, size, rot), x, y)
base.convert("RGB").save(os.path.join(OUT, "thumbnail_2.png"))
print("Wrote game_icon.png, thumbnail_1.png, thumbnail_2.png to", OUT)
