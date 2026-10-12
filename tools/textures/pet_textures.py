"""Draws the pet face and pattern decals (transparent PNGs, 512x512).

    python3 tools/textures/pet_textures.py assets/textures/pets

Faces (face_<look>.png) go on the pet's front. Patterns (spots, stripes,
patch, patches) are white so the game can tint them with Decal.Color3.
eye.png goes on the frog-style eye cubes. Upload them to Roblox and put
the ids in src/shared/Config/PetFaces.luau.
"""

import math
import os
import random
import sys

from PIL import Image, ImageDraw, ImageFilter

OUT = 512
SS = 4  # draw at 4x, then shrink for smooth edges
S = OUT * SS

NAVY = (24, 28, 52, 255)
IRIS = (70, 82, 150, 255)
WHITE = (255, 255, 255, 255)
CREAM = (252, 238, 214, 255)
PINK = (255, 135, 160, 255)
BLUSH = (255, 120, 150, 110)
DARK = (45, 30, 30, 255)
TONGUE = (255, 110, 140, 255)


def u(v):
    """Face units (0-1000) to pixels."""
    return v * S / 1000


class Face:
    def __init__(self):
        self.img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

    def layer(self, draw_fn, blur=0):
        layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        draw_fn(ImageDraw.Draw(layer))
        if blur:
            layer = layer.filter(ImageFilter.GaussianBlur(u(blur)))
        self.img = Image.alpha_composite(self.img, layer)

    def ellipse(self, cx, cy, rx, ry, fill, blur=0):
        self.layer(lambda d: d.ellipse([u(cx - rx), u(cy - ry), u(cx + rx), u(cy + ry)], fill=fill), blur)

    def polygon(self, points, fill, blur=0):
        self.layer(lambda d: d.polygon([(u(x), u(y)) for x, y in points], fill=fill), blur)

    def arc(self, cx, cy, rx, ry, start, end, width, fill=DARK):
        self.layer(lambda d: d.arc([u(cx - rx), u(cy - ry), u(cx + rx), u(cy + ry)], start, end, fill=fill, width=int(u(width))))

    def line(self, points, width, fill=DARK):
        self.layer(lambda d: d.line([(u(x), u(y)) for x, y in points], fill=fill, width=int(u(width)), joint="curve"))

    def rounded(self, x0, y0, x1, y1, r, fill):
        self.layer(lambda d: d.rounded_rectangle([u(x0), u(y0), u(x1), u(y1)], radius=u(r), fill=fill))

    def save(self, path):
        self.img.resize((OUT, OUT), Image.LANCZOS).save(path)


# ---- building blocks -------------------------------------------------------

def eye(f, cx, cy, r=95, lashes=False):
    """Big glossy cartoon eye: dark oval, lighter iris glow, two highlights."""
    f.ellipse(cx, cy, r * 0.92, r * 1.08, NAVY)
    f.ellipse(cx, cy + r * 0.38, r * 0.62, r * 0.5, IRIS, blur=r * 0.12)
    f.ellipse(cx - r * 0.3, cy - r * 0.38, r * 0.36, r * 0.36, WHITE)
    f.ellipse(cx + r * 0.32, cy + r * 0.36, r * 0.15, r * 0.15, WHITE)
    if lashes:
        # Three lashes on the outer-top edge, pointing outward.
        angles = (-20, -42, -64) if cx > 500 else (200, 222, 244)
        for deg in angles:
            a = math.radians(deg)
            x0, y0 = cx + math.cos(a) * r * 0.9, cy + math.sin(a) * r * 1.05
            f.line([(x0, y0), (x0 + math.cos(a) * 50, y0 + math.sin(a) * 50)], 13, NAVY)


def eyes(f, y=420, spread=185, r=112, lashes=False):
    eye(f, 500 - spread, y, r, lashes)
    eye(f, 500 + spread, y, r, lashes)


def blush(f, y=575, spread=270):
    f.ellipse(500 - spread, y, 62, 34, BLUSH, blur=8)
    f.ellipse(500 + spread, y, 62, 34, BLUSH, blur=8)


def muzzle(f, cy=640, rx=190, ry=140, fill=CREAM):
    f.ellipse(cx=500, cy=cy, rx=rx, ry=ry, fill=fill)


def nose(f, cy=575, w=90, h=62, fill=DARK):
    f.rounded(500 - w / 2, cy - h / 2, 500 + w / 2, cy + h / 2, h * 0.45, fill)
    f.polygon([(500 - w * 0.42, cy), (500 + w * 0.42, cy), (500, cy + h * 0.75)], fill)
    f.ellipse(500 - w * 0.18, cy - h * 0.18, w * 0.16, h * 0.12, (255, 255, 255, 170))


def mouth_w(f, cy=620, size=66, width=14):
    """The cute 'ω' mouth under the nose."""
    f.arc(500 - size / 2, cy, size / 2, size * 0.45, 0, 180, width)
    f.arc(500 + size / 2, cy, size / 2, size * 0.45, 0, 180, width)


def smile(f, cy=600, rx=180, ry=90, width=14):
    f.arc(500, cy - ry, rx, ry, 20, 160, width)


def tongue(f, cy=690):
    f.rounded(462, cy - 40, 538, cy + 38, 36, TONGUE)
    f.line([(500, cy - 25), (500, cy + 15)], 6, (220, 80, 110, 255))


def whiskers(f, y=625, inner=340, outer=170):
    for dy in (-35, 0, 35):
        f.line([(inner, y + dy * 0.3), (outer, y + dy)], 9, (60, 45, 45, 220))
        f.line([(1000 - inner, y + dy * 0.3), (1000 - outer, y + dy)], 9, (60, 45, 45, 220))


def teeth(f, cy=665, w=70, h=60):
    f.rounded(500 - w / 2, cy - h / 2, 500 + w / 2, cy + h / 2, 10, WHITE)
    f.line([(500, cy - h / 2), (500, cy + h / 2)], 5, (200, 200, 200, 255))


def fangs(f, cy=640):
    for x in (465, 535):
        f.polygon([(x - 16, cy), (x + 16, cy), (x, cy + 38)], WHITE)


def nostrils(f, cy=560, gap=45):
    f.ellipse(500 - gap, cy, 13, 9, DARK)
    f.ellipse(500 + gap, cy, 13, 9, DARK)


# ---- faces per look --------------------------------------------------------

def face_dog(f):
    muzzle(f, 650, 200, 150)
    eyes(f)
    nose(f, 590, 110, 72)
    mouth_w(f, 640, 60)
    tongue(f, 705)
    blush(f, 600, 300)


def face_cat(f):
    f.ellipse(440, 650, 105, 82, CREAM)
    f.ellipse(560, 650, 105, 82, CREAM)
    eyes(f)
    nose(f, 595, 60, 40, PINK)
    mouth_w(f, 625, 48)
    whiskers(f)
    blush(f)


def face_fox(f):
    f.ellipse(290, 700, 240, 170, WHITE)
    f.ellipse(710, 700, 240, 170, WHITE)
    f.ellipse(500, 790, 270, 190, WHITE)
    eyes(f)
    nose(f, 640, 80, 54)
    mouth_w(f, 680, 50)


def face_bear(f):
    muzzle(f, 640, 170, 125)
    eyes(f)
    nose(f, 590, 100, 66)
    mouth_w(f, 640, 55)
    blush(f)


def face_mouse(f):
    eyes(f, 420)
    f.ellipse(500, 580, 62, 50, PINK)
    f.ellipse(482, 565, 16, 11, (255, 255, 255, 170))
    mouth_w(f, 625, 46)
    teeth(f, 680, 48, 40)
    whiskers(f, 600, 380, 200)
    blush(f)


def face_bunny(f):
    eyes(f)
    f.polygon([(460, 570), (540, 570), (500, 610)], PINK)
    mouth_w(f, 610, 50)
    teeth(f, 670, 64, 58)
    whiskers(f, 610, 380, 230)
    blush(f)


def face_owl(f):
    for x in (330, 670):
        f.ellipse(x, 430, 165, 165, CREAM)
    eyes(f, 430, 170, 105)
    f.polygon([(500, 520), (560, 590), (500, 680), (440, 590)], (255, 175, 40, 255))
    f.polygon([(500, 520), (560, 590), (500, 600), (440, 590)], (255, 205, 90, 255))


def face_bat(f):
    eyes(f)
    nose(f, 580, 60, 40)
    mouth_w(f, 610, 50)
    fangs(f, 628)
    blush(f)


def face_frog(f):
    smile(f, 640, 230, 110, 16)
    nostrils(f, 470, 55)
    blush(f, 560, 320)


def face_axolotl(f):
    eyes(f, 450, 210, 72)
    smile(f, 640, 190, 90, 14)
    blush(f, 580, 330)


def face_slime(f):
    eyes(f, 420)
    f.layer(lambda d: d.chord([u(400), u(520), u(600), u(700)], 0, 180, fill=DARK))
    f.ellipse(500, 650, 50, 28, TONGUE)
    blush(f, 560, 290)
    f.ellipse(200, 180, 70, 40, (255, 255, 255, 120), blur=10)


def face_ghost(f):
    eyes(f, 420)
    f.ellipse(500, 640, 48, 62, DARK)
    blush(f, 560, 290)


def face_dragon(f):
    muzzle(f, 680, 210, 140, (255, 248, 230, 140))
    eyes(f, 410)
    nostrils(f, 620, 55)
    smile(f, 720, 150, 70, 13)
    fangs(f, 712)


def face_unicorn(f):
    muzzle(f, 690, 220, 150, (255, 225, 235, 255))
    eyes(f, 420, lashes=True)
    nostrils(f, 660, 60)
    smile(f, 760, 90, 40, 11)
    blush(f, 585, 300)


def face_otter(f):
    f.ellipse(445, 650, 110, 90, CREAM)
    f.ellipse(555, 650, 110, 90, CREAM)
    eyes(f, 430, 175, 85)
    nose(f, 595, 80, 54)
    mouth_w(f, 640, 50)
    whiskers(f, 650, 380, 200)


def face_lamb(f):
    f.ellipse(500, 560, 300, 320, (175, 140, 130, 255))
    eyes(f, 480, 140, 82)
    f.polygon([(465, 610), (535, 610), (500, 645)], PINK)
    mouth_w(f, 650, 44)
    blush(f, 610, 240)


def face_mole(f):
    eye(f, 360, 420, 62)
    eye(f, 640, 420, 62)
    for i in range(8):
        a = i * math.pi / 4
        f.ellipse(500 + math.cos(a) * 55, 575 + math.sin(a) * 55, 42, 42, PINK)
    f.ellipse(500, 575, 60, 60, (255, 160, 180, 255))
    mouth_w(f, 655, 44)
    teeth(f, 700, 46, 36)


def face_moth(f):
    f.ellipse(500, 760, 300, 170, CREAM)
    eyes(f, 430, 175, 105)
    mouth_w(f, 640, 44)
    blush(f, 590, 300)


def face_turtle(f):
    eyes(f, 430)
    smile(f, 640, 150, 75, 13)
    blush(f)


def face_lizard(f):
    eyes(f, 420, 190, 88)
    nostrils(f, 560, 50)
    smile(f, 670, 220, 100, 14)


def face_panda(f):
    face_bear(f)


def eye_single(f):
    eye(f, 500, 520, 300)


# ---- patterns (white, tinted in game) ---------------------------------------

def spots(f):
    rng = random.Random(7)
    for cx, cy, r in [(250, 260, 150), (720, 330, 110), (420, 720, 170), (820, 800, 90)]:
        pts = []
        for i in range(14):
            a = i / 14 * math.tau
            rr = r * rng.uniform(0.82, 1.12)
            pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr))
        f.polygon(pts, WHITE, blur=3)


def stripes(f):
    for y, side in [(200, 1), (500, -1), (800, 1)]:
        x0 = 0 if side > 0 else 1000
        pts = [(x0, y - 85), (x0 + side * 260, y - 45), (x0 + side * 430, y - 5), (x0 + side * 460, y + 8), (x0 + side * 260, y + 50), (x0, y + 85)]
        f.polygon(pts, WHITE, blur=2)


def patch(f):
    pts = []
    for i in range(16):
        a = i / 16 * math.tau
        r = 175 + 25 * math.sin(a * 3)
        pts.append((330 + math.cos(a) * r, 430 + math.sin(a) * r * 1.05))
    f.polygon(pts, WHITE, blur=3)


def patches(f):
    for side in (-1, 1):
        cx, cy = 500 + side * 170, 450
        pts = []
        for i in range(20):
            a = i / 20 * math.tau
            r = 140 * (1 + 0.25 * max(0, math.sin(a + side * 0.8)))
            pts.append((cx + math.cos(a) * r * 0.95, cy + math.sin(a) * r * 1.2))
        f.polygon(pts, WHITE, blur=3)


TEXTURES = {
    **{name: fn for name, fn in globals().items() if name.startswith("face_")},
    "eye": eye_single,
    "spots": spots,
    "stripes": stripes,
    "patch": patch,
    "patches": patches,
}


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for name, draw in TEXTURES.items():
        f = Face()
        draw(f)
        f.save(os.path.join(out, f"{name}.png"))
    print(f"Wrote {len(TEXTURES)} textures to {out}")


if __name__ == "__main__":
    main()
