"""Draws the tiling "stud" texture the reference games put on every panel
(the embossed brick bumps). One stud per tile: a light top-left rim and a
dark bottom-right rim on transparent, so it works over any panel colour.

    python3 tools/textures/ui_textures.py
"""

import os

from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(HERE, "../../assets/textures/ui"))
SS = 4
S = 64 * SS


def studs():
    light = Image.new("L", (S, S), 0)
    dark = Image.new("L", (S, S), 0)
    r = 19 * SS
    c = S // 2
    w = 4 * SS
    ImageDraw.Draw(light).arc([c - r, c - r, c + r, c + r], 135, 315, fill=255, width=w)
    ImageDraw.Draw(dark).arc([c - r, c - r, c + r, c + r], 315, 135, fill=255, width=w)
    light = light.filter(ImageFilter.GaussianBlur(SS))
    dark = dark.filter(ImageFilter.GaussianBlur(SS))
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    white = Image.new("RGBA", (S, S), (255, 255, 255, 255))
    white.putalpha(light.point(lambda a: int(a * 0.85)))
    black = Image.new("RGBA", (S, S), (0, 0, 0, 255))
    black.putalpha(dark.point(lambda a: int(a * 0.5)))
    img = Image.alpha_composite(img, black)
    img = Image.alpha_composite(img, white)
    img.resize((64, 64), Image.LANCZOS).save(os.path.join(OUT, "studs.png"))


os.makedirs(OUT, exist_ok=True)
studs()
print("Wrote studs.png")
