"""Draws the tiling "stud" texture the reference games put on every panel
(the brick bumps). Measured pixel by pixel from the Stone Skipping
screenshots: one stud per 24 px tile, a 13×14 px rounded square the same
colour as the panel, bevelled — 2 px darker edges on the left and bottom,
2 px lighter edges on the top (brighter towards the right) and right, lit
from the top-right — plus a faint 1 px shadow under it. Black/white on
transparent, so it works over any panel colour. Used at full strength.

    python3 tools/textures/ui_textures.py
"""

import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(HERE, "../../assets/textures/ui"))
PITCH = 24  # reference pixels per tile
SIZE = 64  # texture pixels per tile
SS = 8  # supersamples per texture pixel (each axis)

# Stud box in reference pixels (x0, y0, x1, y1) and corner radius.
X0, Y0, X1, Y1, R = 5.5, 4.5, 18.5, 18.5, 2.0

# Edge alphas measured against the panel colour (luminance deltas / range).
DARK_LEFT = (0.16, 0.08)  # outermost px, next px
DARK_BOTTOM = (0.18, 0.13)
LIGHT_RIGHT = (0.22, 0.14)
LIGHT_TOP = (0.06, 0.22)  # left end → right end of the top edge
FACE = 0.02
UNDER = 0.06  # 1 px shadow under the stud


def inside(x, y):
    if not (X0 <= x < X1 and Y0 <= y < Y1):
        return False
    cx = min(max(x, X0 + R), X1 - R)
    cy = min(max(y, Y0 + R), Y1 - R)
    return (x - cx) ** 2 + (y - cy) ** 2 <= R * R


def shade(x, y):
    """(black alpha, white alpha) at reference point (x, y)."""
    if not inside(x, y):
        if X0 + 1 <= x < X1 and Y1 <= y < Y1 + 1:
            return UNDER, 0.0
        return 0.0, 0.0
    dl, dr, dt, db = x - X0, X1 - x, y - Y0, Y1 - y
    dark = 0.0
    if dl < 2:
        dark = max(dark, DARK_LEFT[0] if dl < 1 else DARK_LEFT[1])
    if db < 2:
        dark = max(dark, DARK_BOTTOM[0] if db < 1 else DARK_BOTTOM[1])
    if dark:
        return dark, 0.0
    if dr < 2:
        return 0.0, LIGHT_RIGHT[0] if dr < 1 else LIGHT_RIGHT[1]
    if dt < 2:
        t = (x - X0) / (X1 - X0)
        light = LIGHT_TOP[0] + (LIGHT_TOP[1] - LIGHT_TOP[0]) * t
        return 0.0, light if dt < 1 else light * 0.6
    return 0.0, FACE


def studs():
    img = Image.new("RGBA", (SIZE, SIZE))
    px = img.load()
    scale = PITCH / SIZE
    for ty in range(SIZE):
        for tx in range(SIZE):
            # Premultiplied average of the supersamples (black and white).
            a_sum = c_sum = 0.0
            for sy in range(SS):
                for sx in range(SS):
                    d, w = shade((tx + (sx + 0.5) / SS) * scale, (ty + (sy + 0.5) / SS) * scale)
                    a_sum += d + w
                    c_sum += w  # white contributes colour, black none
            n = SS * SS
            alpha = a_sum / n
            colour = int(round(255 * c_sum / a_sum)) if a_sum else 0
            px[tx, ty] = (colour, colour, colour, int(round(255 * alpha)))
    img.save(os.path.join(OUT, "studs.png"))


os.makedirs(OUT, exist_ok=True)
studs()
print("Wrote studs.png")
