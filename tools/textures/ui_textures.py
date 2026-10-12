"""Draws the tiling "stud" texture the reference games put on every panel
(the brick bumps). One stud per tile, like the reference: a rounded square,
a little lighter than the panel, with a soft dark L-shaped shadow on its
left and bottom edges. Black/white on transparent, so it works over any
panel colour.

    python3 tools/textures/ui_textures.py
"""

import os

from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(HERE, "../../assets/textures/ui"))
SS = 4
S = 64 * SS


def studs():
    side = 34 * SS  # stud size in a 64 tile (reference: ~55% of the pitch)
    r = 5 * SS  # corner radius
    x0 = (S - side) // 2
    box = [x0, x0, x0 + side, x0 + side]
    face = Image.new("L", (S, S), 0)
    ImageDraw.Draw(face).rounded_rectangle(box, r, fill=255)
    # Shadow = the stud shifted down-left, minus the stud itself.
    off = 3 * SS
    shadow = Image.new("L", (S, S), 0)
    ImageDraw.Draw(shadow).rounded_rectangle([box[0] - off, box[1] + off, box[2] - off, box[3] + off], r, fill=255)
    shadow = Image.composite(Image.new("L", (S, S), 0), shadow, face).filter(ImageFilter.GaussianBlur(1.5 * SS))
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    black = Image.new("RGBA", (S, S), (0, 0, 0, 255))
    black.putalpha(shadow.point(lambda a: int(a * 0.42)))
    white = Image.new("RGBA", (S, S), (255, 255, 255, 255))
    white.putalpha(face.point(lambda a: int(a * 0.16)))
    img = Image.alpha_composite(img, black)
    img = Image.alpha_composite(img, white)
    img.resize((64, 64), Image.LANCZOS).save(os.path.join(OUT, "studs.png"))


os.makedirs(OUT, exist_ok=True)
studs()
print("Wrote studs.png")
