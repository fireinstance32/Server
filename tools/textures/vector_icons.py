"""Draws the UI icon set as SVG (the editable source) in the reference style:
thick dark outline with a chunky bottom edge, top-lit gradient fill, glossy
highlights.

    python3 tools/textures/vector_icons.py          -> assets/vectors/icons/*.svg
    node tools/ui-preview/svg2png.mjs assets/vectors/icons <out> 512
    python3 tools/textures/pack_icons.py <out> icon_ icons IconAtlas 170 6 flat

Every icon lives in a 256 box. An icon is a list of parts drawn in order; all
parts share one outline (drawn first, under everything) so touching parts read
as one sticker, and each part also gets a thin inner line in the same ink.
"""

import colorsys
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(HERE, "../../assets/vectors/icons"))

OUTLINE = 18  # outer outline width (half of it shows outside the shape)
DEPTH = 9  # how far the outline drops below the shape (chunky bottom edge)
INNER = 5  # inner line between parts


# -- colour helpers ----------------------------------------------------------

def rgb(hexstr):
    h = hexstr.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


def hexc(c):
    return "#" + "".join(f"{max(0, min(255, round(v * 255))):02x}" for v in c)


def mix(a, b, t):
    a, b = rgb(a), rgb(b)
    return hexc(tuple(x + (y - x) * t for x, y in zip(a, b)))


def light(c, t):
    return mix(c, "#ffffff", t)


def dark(c, t):
    return mix(c, "#000000", t)


def ink_of(c):
    # Outline colour: the main colour, much darker and a little more saturated.
    r, g, b = rgb(c)
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return hexc(colorsys.hls_to_rgb(h, l * 0.22, min(1, s * 1.1 + 0.1)))


# -- shapes -------------------------------------------------------------------

def attrs(d):
    return " ".join(f'{k.replace("_", "-")}="{v}"' for k, v in d.items())


def circle(cx, cy, r):
    return ("circle", {"cx": cx, "cy": cy, "r": r})


def ellipse(cx, cy, rx, ry, rot=0):
    a = {"cx": cx, "cy": cy, "rx": rx, "ry": ry}
    if rot:
        a["transform"] = f"rotate({rot} {cx} {cy})"
    return ("ellipse", a)


def rect(x, y, w, h, r=0, rot=0):
    a = {"x": x, "y": y, "width": w, "height": h, "rx": r}
    if rot:
        a["transform"] = f"rotate({rot} {x + w / 2} {y + h / 2})"
    return ("rect", a)


def path(d, rule="nonzero"):
    return ("path", {"d": d, "fill_rule": rule})


def poly(points):
    return ("polygon", {"points": " ".join(f"{x:.1f},{y:.1f}" for x, y in points)})


def star_points(cx, cy, r, inner=0.5, n=5, rot=-90):
    pts = []
    for i in range(n * 2):
        rr = r if i % 2 == 0 else r * inner
        a = math.radians(rot + i * 180 / n)
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return pts


def rounded_star(cx, cy, r, inner=0.5, n=5, round_=0.18):
    """Star with soft tips (quadratic corners), as a path."""
    pts = star_points(cx, cy, r, inner, n)
    d = []
    m = len(pts)
    for i in range(m):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % m]
        a = (p1[0] + (p0[0] - p1[0]) * round_, p1[1] + (p0[1] - p1[1]) * round_)
        b = (p1[0] + (p2[0] - p1[0]) * round_, p1[1] + (p2[1] - p1[1]) * round_)
        d.append(f"{'M' if i == 0 else 'L'}{a[0]:.1f},{a[1]:.1f} Q{p1[0]:.1f},{p1[1]:.1f} {b[0]:.1f},{b[1]:.1f}")
    return path(" ".join(d) + " Z")


def cross_points(cx, cy, w, length, rot=0):
    base = [(w, length), (w, w), (length, w), (length, -w), (w, -w), (w, -length),
            (-w, -length), (-w, -w), (-length, -w), (-length, w), (-w, w), (-w, length)]
    a = math.radians(rot)
    return [(cx + x * math.cos(a) - y * math.sin(a), cy + x * math.sin(a) + y * math.cos(a)) for x, y in base]


def gear_path(cx, cy, r_out, r_in, teeth, tooth=0.5):
    d = []
    step = 2 * math.pi / teeth
    for i in range(teeth):
        a0 = i * step - math.pi / 2
        t = step * tooth / 2
        for a, r in ((a0 - t * 1.25, r_in), (a0 - t * 0.8, r_out), (a0 + t * 0.8, r_out), (a0 + t * 1.25, r_in)):
            d.append(f"{'M' if not d else 'L'}{cx + r * math.cos(a):.1f},{cy + r * math.sin(a):.1f}")
    return path(" ".join(d) + " Z")


# -- parts --------------------------------------------------------------------

def part(shape, color, top=None, bottom=None, gloss=None, line=True, flat=False):
    """A filled part. top/bottom override the gradient ends."""
    return {"kind": "fill", "shape": shape, "color": color, "top": top, "bottom": bottom,
            "gloss": gloss or [], "line": line, "flat": flat}


def stroke(d, color, width, top=None, bottom=None, cap="round"):
    """A thick stroked line (handles, arcs, check marks)."""
    return {"kind": "stroke", "shape": path(d), "color": color, "width": width,
            "top": top, "bottom": bottom, "cap": cap, "gloss": [], "line": True}


def gloss(shape, opacity=0.75):
    return {"kind": "gloss", "shape": shape, "opacity": opacity}


def detail(shape, color, opacity=1.0):
    """Flat detail drawn on top, no outline (spots, slots, faces)."""
    return {"kind": "detail", "shape": shape, "color": color, "opacity": opacity}


def line_detail(d, color, width, opacity=1.0):
    return {"kind": "line", "shape": path(d), "color": color, "width": width, "opacity": opacity}


# -- the icons ----------------------------------------------------------------

ICONS = {}


def icon(name, ink=None):
    def wrap(fn):
        ICONS[name] = (fn, ink)
        return fn
    return wrap


@icon("bolt", ink="#4a1d00")
def _bolt():
    shape = path("M150,14 L58,146 L118,146 L94,242 L202,100 L140,100 L184,14 Z")
    return [part(shape, "#ffb300", top="#fff176", bottom="#ff7a00",
                 gloss=[gloss(path("M150,30 L84,132 L102,132 L160,36 Z"), 0.7)])]


@icon("check", ink="#0b3d12")
def _check():
    return [
        part(circle(128, 128, 104), "#2fcf45", top="#7cf07a", bottom="#14a32c",
             gloss=[gloss(ellipse(98, 70, 46, 22, -25), 0.45)]),
        stroke("M76,132 L112,168 L182,90", "#ffffff", 34, top="#ffffff", bottom="#e3f6e6"),
    ]


@icon("close", ink="#4d0612")
def _close():
    return [
        part(rect(24, 24, 208, 208, 50), "#ff2b4a", top="#ff6a7d", bottom="#d4102c",
             gloss=[gloss(rect(46, 38, 164, 40, 20), 0.28)]),
        part(poly(cross_points(128, 132, 24, 78, 45)), "#ffffff", top="#ffffff", bottom="#ffe1e5"),
    ]


@icon("plus", ink="#0b3d12")
def _plus():
    return [part(poly(cross_points(128, 128, 36, 104)), "#34d14a", top="#86f383", bottom="#16a22c",
                 gloss=[gloss(rect(104, 36, 30, 60, 15), 0.55)])]


@icon("info", ink="#08285a")
def _info():
    return [
        part(circle(128, 128, 104), "#2b8cff", top="#73c2ff", bottom="#1662d6",
             gloss=[gloss(ellipse(98, 70, 46, 22, -25), 0.45)]),
        part(circle(128, 74, 20), "#ffffff", top="#ffffff", bottom="#e1edff"),
        part(rect(108, 106, 40, 96, 18), "#ffffff", top="#ffffff", bottom="#e1edff"),
    ]


@icon("star", ink="#5a3200")
def _star():
    return [part(rounded_star(128, 136, 118, 0.48), "#ffc400", top="#fff170", bottom="#ff9500",
                 gloss=[gloss(path("M128,44 L110,104 L70,108 L114,96 Z"), 0.75),
                        gloss(ellipse(104, 116, 16, 9, -30), 0.5)])]


@icon("pets", ink="#06265a")
def _pets():
    c, top, bot = "#2f8cff", "#7fd0ff", "#1559d6"
    g = lambda x, y, rx, ry: gloss(ellipse(x, y, rx, ry, -25), 0.7)
    return [
        part(circle(56, 116, 28), c, top=top, bottom=bot, gloss=[g(48, 106, 8, 12)]),
        part(ellipse(98, 64, 30, 36, -10), c, top=top, bottom=bot, gloss=[g(90, 52, 9, 14)]),
        part(ellipse(158, 64, 30, 36, 10), c, top=top, bottom=bot, gloss=[g(150, 52, 9, 14)]),
        part(circle(200, 116, 28), c, top=top, bottom=bot, gloss=[g(192, 106, 8, 12)]),
        part(path("M128,120 C164,120 206,168 204,200 C202,232 168,236 128,224 C88,236 54,232 52,200 "
                  "C50,168 92,120 128,120 Z"), c, top=top, bottom=bot,
             gloss=[g(98, 158, 18, 12)]),
    ]


@icon("egg", ink="#25303f")
def _egg():
    shape = path("M128,14 C72,14 40,116 40,160 C40,214 80,242 128,242 C176,242 216,214 216,160 "
                 "C216,116 184,14 128,14 Z")
    return [part(shape, "#eef3fa", top="#ffffff", bottom="#b9c9de",
                 gloss=[gloss(ellipse(94, 84, 15, 30, 20), 0.95)])]


@icon("frog", ink="#0d3a0e")
def _frog():
    g, top, bot = "#52d63c", "#9cf26b", "#24a12a"
    return [
        part(circle(76, 86, 44), g, top=top, bottom=bot),
        part(circle(180, 86, 44), g, top=top, bottom=bot),
        part(path("M128,84 C200,84 240,128 240,168 C240,214 190,236 128,236 C66,236 16,214 16,168 "
                  "C16,128 56,84 128,84 Z"), g, top=top, bottom=bot,
             gloss=[gloss(ellipse(66, 140, 22, 11, -20), 0.5)]),
        part(circle(76, 86, 27), "#ffffff", top="#ffffff", bottom="#dfe7ef"),
        part(circle(180, 86, 27), "#ffffff", top="#ffffff", bottom="#dfe7ef"),
        detail(circle(82, 92, 14), "#111318"),
        detail(circle(174, 92, 14), "#111318"),
        detail(circle(86, 87, 5), "#ffffff"),
        detail(circle(178, 87, 5), "#ffffff"),
        line_detail("M84,170 Q128,204 172,170", "#0d3a0e", 10),
        detail(ellipse(54, 168, 18, 11), "#ff8fb1", 0.85),
        detail(ellipse(202, 168, 18, 11), "#ff8fb1", 0.85),
    ]


@icon("crown", ink="#5a2e00")
def _crown():
    gold, top, bot = "#ffc21a", "#fff07a", "#f08a00"
    return [
        part(path("M34,200 L26,84 L86,128 L128,48 L170,128 L230,84 L222,200 Z"), gold, top=top, bottom=bot,
             gloss=[gloss(path("M44,108 L52,180 L64,180 L58,120 Z"), 0.55)]),
        part(rect(30, 178, 196, 48, 14), gold, top="#ffd84a", bottom="#e07800"),
        part(circle(26, 80, 16), "#ff3b5c", top="#ff8a9e", bottom="#d1102e"),
        part(circle(128, 44, 18), "#3aa8ff", top="#9ad8ff", bottom="#1662d6"),
        part(circle(230, 80, 16), "#ff3b5c", top="#ff8a9e", bottom="#d1102e"),
        part(rounded_star(128, 202, 18, 0.5), "#ffffff", top="#ffffff", bottom="#ffeaa0"),
        detail(circle(72, 202, 9), "#ff3b5c"),
        detail(circle(184, 202, 9), "#3aa8ff"),
    ]


@icon("trophy", ink="#5a2e00")
def _trophy():
    gold, top, bot = "#ffc21a", "#fff07a", "#f08a00"
    return [
        stroke("M70,64 C24,64 24,128 82,138", gold, 22, top=top, bottom=bot),
        stroke("M186,64 C232,64 232,128 174,138", gold, 22, top=top, bottom=bot),
        part(rect(108, 150, 40, 48, 8), gold, top="#ffd84a", bottom="#d97000"),
        part(path("M58,28 L198,28 L198,82 C198,128 166,160 128,160 C90,160 58,128 58,82 Z"), gold,
             top=top, bottom=bot, gloss=[gloss(path("M76,42 L94,42 L94,96 C94,116 100,128 106,136 "
                                                    "C86,128 76,110 76,92 Z"), 0.6)]),
        part(rect(70, 192, 116, 46, 12), "#c46a2a", top="#e8904a", bottom="#8a4216"),
        detail(rect(96, 206, 64, 16, 6), "#ffd84a"),
        part(rounded_star(128, 88, 30, 0.5), "#ffffff", top="#ffffff", bottom="#fff0b0"),
    ]


@icon("lock", ink="#4a2c00")
def _lock():
    return [
        stroke("M78,124 L78,92 C78,60 100,38 128,38 C156,38 178,60 178,92 L178,124", "#b8c4d4", 28,
               top="#eef3fa", bottom="#7c8aa0", cap="butt"),
        part(rect(40, 112, 176, 128, 30), "#ffc21a", top="#fff07a", bottom="#e07800",
             gloss=[gloss(rect(58, 126, 140, 22, 11), 0.45)]),
        detail(circle(128, 166, 18), "#5a3200"),
        detail(path("M120,170 L136,170 L142,208 L114,208 Z"), "#5a3200"),
    ]


@icon("settings", ink="#0e2846")
def _settings():
    return [
        part(gear_path(128, 128, 116, 88, 8, 0.55), "#8ec2f0", top="#e4f3ff", bottom="#3f7fc4",
             gloss=[gloss(ellipse(84, 66, 26, 12, -35), 0.6)]),
        part(circle(128, 128, 56), "#5f9ad8", top="#a9d2f6", bottom="#2e64a8"),
        part(circle(128, 128, 38), "#16b4ff", top="#8ff0ff", bottom="#0a72e0",
             gloss=[gloss(ellipse(116, 112, 14, 9, -30), 0.85)]),
    ]


@icon("gifts", ink="#0b2a5a")
def _gifts():
    blue, top, bot = "#2e95ff", "#7ccbff", "#165fd6"
    return [
        stroke("M128,84 C98,30 50,40 66,72 C76,92 108,88 128,84", "#ffd21a", 20, top="#fff07a", bottom="#f09a00"),
        stroke("M128,84 C158,30 206,40 190,72 C180,92 148,88 128,84", "#ffd21a", 20, top="#fff07a", bottom="#f09a00"),
        part(rect(44, 118, 168, 118, 16), blue, top="#4fb0ff", bottom=bot),
        part(rect(28, 84, 200, 50, 14), blue, top=top, bottom="#2a86f0",
             gloss=[gloss(rect(44, 92, 120, 14, 7), 0.45)]),
        part(rect(110, 84, 36, 152, 6), "#ffd21a", top="#fff07a", bottom="#f09a00", line=False),
    ]


@icon("daily", ink="#4a0d12")
def _daily():
    cells = []
    for i in range(6):
        x, y = 56 + (i % 3) * 52, 130 + (i // 3) * 48
        color = "#2fcf45" if i == 4 else "#c9d5e4"
        cells.append(detail(rect(x, y, 40, 36, 9), color))
    return [
        part(rect(28, 50, 200, 186, 30), "#ffffff", top="#ffffff", bottom="#cfdbe9"),
        part(path("M28,108 L28,80 C28,63 41,50 58,50 L198,50 C215,50 228,63 228,80 L228,108 Z"),
             "#ff3b4f", top="#ff8592", bottom="#d6142c", gloss=[gloss(rect(46, 60, 120, 12, 6), 0.4)]),
        *cells,
        line_detail("M118,196 L126,204 L140,188", "#ffffff", 7),
        part(rect(70, 22, 24, 54, 12), "#c9d5e4", top="#ffffff", bottom="#8d9db3"),
        part(rect(162, 22, 24, 54, 12), "#c9d5e4", top="#ffffff", bottom="#8d9db3"),
    ]


@icon("globe", ink="#06304d")
def _globe():
    return [
        part(circle(128, 128, 108), "#2bb0ff", top="#8fe0ff", bottom="#106fd0"),
        detail(path("M64,62 C92,46 120,56 116,80 C112,100 86,96 82,116 C78,140 52,140 38,124 "
                    "C34,98 46,74 64,62 Z"), "#4fd64a"),
        detail(path("M150,40 C186,48 214,80 220,116 C200,124 182,108 170,118 C156,130 172,150 160,168 "
                    "C146,186 126,170 128,148 C130,126 144,122 140,100 C136,80 126,52 150,40 Z"), "#4fd64a"),
        detail(path("M84,180 C104,170 124,184 118,204 C114,220 96,228 80,222 C66,210 70,188 84,180 Z"), "#4fd64a"),
        gloss(ellipse(86, 70, 34, 16, -35), 0.55),
    ]


@icon("inventory", ink="#4a1f06")
def _inventory():
    tan, top, bot = "#f08a3c", "#ffc27a", "#c25a1a"
    return [
        stroke("M96,64 L96,48 C96,30 108,22 128,22 C148,22 160,30 160,48 L160,64", "#8a4a1e", 16,
               top="#c27a42", bottom="#6a3410"),
        part(rect(44, 56, 168, 182, 44), tan, top=top, bottom=bot,
             gloss=[gloss(rect(62, 70, 22, 70, 11), 0.45)]),
        part(path("M44,120 C44,84 84,70 128,70 C172,70 212,84 212,120 L212,132 L44,132 Z"), tan,
             top="#ffb062", bottom="#d86c22"),
        part(rect(76, 150, 104, 72, 18), tan, top="#e07a32", bottom="#b24e14"),
        part(rect(114, 116, 28, 30, 7), "#ffd21a", top="#fff07a", bottom="#e09000"),
    ]


@icon("book", ink="#3e0a2a")
def _book():
    return [
        part(rect(44, 30, 172, 206, 18), "#ffffff", top="#ffffff", bottom="#d9e1ec"),
        part(path("M40,30 L196,30 C204,30 210,36 210,44 L210,206 C210,214 204,220 196,220 L40,220 Z"),
             "#e8326e", top="#ff7aa6", bottom="#b8104c",
             gloss=[gloss(rect(70, 46, 112, 14, 7), 0.4)]),
        part(rect(28, 22, 34, 216, 14), "#b8104c", top="#e8326e", bottom="#7c0830"),
        part(rounded_star(134, 126, 52, 0.5), "#ffc21a", top="#fff07a", bottom="#f08a00"),
    ]


@icon("music", ink="#2a0a52")
def _music():
    p, top, bot = "#9b5cff", "#d2a6ff", "#6a2ee0"
    return [
        part(path("M86,64 L210,32 L210,72 L86,104 Z"), p, top=top, bottom=bot),
        part(rect(86, 64, 22, 140, 6), p, top=top, bottom=bot),
        part(rect(188, 32, 22, 140, 6), p, top=top, bottom=bot),
        part(ellipse(72, 204, 40, 30, -20), p, top=top, bottom=bot,
             gloss=[gloss(ellipse(60, 194, 14, 7, -20), 0.6)]),
        part(ellipse(174, 172, 40, 30, -20), p, top=top, bottom=bot,
             gloss=[gloss(ellipse(162, 162, 14, 7, -20), 0.6)]),
    ]


@icon("speaker", ink="#152434")
def _speaker():
    return [
        part(path("M28,96 L76,96 L134,44 L134,212 L76,160 L28,160 Z"), "#9aa8ba", top="#eef3fa", bottom="#5a6a80",
             gloss=[gloss(rect(42, 106, 26, 12, 6), 0.6)]),
        stroke("M164,92 C182,110 182,146 164,164", "#2ecbff", 18, top="#a6f0ff", bottom="#0e8fe0"),
        stroke("M192,64 C230,100 230,156 192,192", "#2ecbff", 18, top="#a6f0ff", bottom="#0e8fe0"),
    ]


@icon("portal", ink="#2a0a52")
def _portal():
    return [
        part(path("M128,18 A110,110 0 1 1 127.9,18 Z M128,66 A62,62 0 1 0 128.1,66 Z", "evenodd"),
             "#a24cff", top="#dca8ff", bottom="#6a1ed6",
             gloss=[gloss(ellipse(72, 70, 30, 12, -40), 0.55)]),
        part(circle(128, 128, 62), "#2be0ff", top="#e6ffff", bottom="#2a7dff", line=False),
        line_detail("M128,128 C150,110 168,136 150,156 C128,178 92,160 94,126 C96,92 140,76 168,98",
                    "#ffffff", 9, 0.85),
    ]


def potion(color, top, bot):
    return [
        part(rect(98, 50, 60, 60, 10), "#d8f0ff", top="#ffffff", bottom="#9ec4e0"),
        part(circle(128, 160, 82), color, top=top, bottom=bot,
             gloss=[gloss(ellipse(92, 128, 16, 26, 30), 0.85), gloss(circle(170, 196, 7), 0.6)]),
        detail(path("M54,150 C90,166 166,140 202,152 C202,148 200,140 198,134 C160,124 92,150 58,136 Z"),
               light(color, 0.35), 0.8),
        part(rect(88, 22, 80, 40, 12), "#c4733a", top="#eaa66a", bottom="#8a4416"),
    ]


@icon("potion_hops", ink="#0b3d12")
def _potion_hops():
    return potion("#36d24a", "#a6f58c", "#159a2a")


@icon("potion_luck", ink="#3e0a52")
def _potion_luck():
    return potion("#c45cff", "#efb6ff", "#8a22d6")


@icon("potion_wins", ink="#5a3200")
def _potion_wins():
    return potion("#ffc21a", "#fff07a", "#f08a00")


@icon("boost", ink="#06305a")
def _boost():
    return [
        part(rect(104, 26, 48, 38, 10), "#ffc21a", top="#fff07a", bottom="#e07800"),
        part(rect(110, 56, 36, 30, 6), "#bfe8ff", top="#ffffff", bottom="#8cc8ec"),
        part(rounded_star(128, 156, 100, 0.55, round_=0.22), "#22c8ff", top="#a8f0ff", bottom="#0a7ce0",
             gloss=[gloss(ellipse(92, 132, 12, 22, 30), 0.8), gloss(circle(160, 196, 6), 0.6)]),
    ]


@icon("pumpkin", ink="#4a1a00")
def _pumpkin():
    o, top, bot = "#ff8a1a", "#ffc06a", "#d4560a"
    return [
        stroke("M128,62 C126,42 134,28 150,22", "#3c9a2a", 18, top="#7ad65a", bottom="#256a18"),
        part(ellipse(80, 148, 58, 84), o, top=top, bottom=bot),
        part(ellipse(176, 148, 58, 84), o, top=top, bottom=bot),
        part(ellipse(128, 148, 56, 90), o, top=top, bottom=bot,
             gloss=[gloss(ellipse(108, 98, 12, 26, 10), 0.55)]),
    ]


@icon("candy_corn", ink="#4a1f00")
def _candy_corn():
    return [
        part(path("M58,170 L198,170 L212,214 C214,226 206,236 194,236 L62,236 C50,236 42,226 44,214 Z"),
             "#ffd21a", top="#fff07a", bottom="#f0a000"),
        part(path("M84,92 L172,92 L198,170 L58,170 Z"), "#ff8a1a", top="#ffb35a", bottom="#e0620a"),
        part(path("M128,20 C140,20 146,30 150,40 L172,92 L84,92 L106,40 C110,30 116,20 128,20 Z"),
             "#ffffff", top="#ffffff", bottom="#e8ecf2", gloss=[gloss(path("M112,46 L120,46 L104,86 L96,86 Z"), 0.9)]),
    ]


@icon("rebirth", ink="#06305a")
def _rebirth():
    return [
        stroke("M50,124 C50,74 92,40 140,44 C164,46 184,56 198,72", "#2ecbff", 30, top="#a6f0ff", bottom="#0e8fe0", cap="butt"),
        part(poly([(218, 40), (226, 110), (160, 90)]), "#2ecbff", top="#a6f0ff", bottom="#0e8fe0", line=False),
        stroke("M206,132 C206,182 164,216 116,212 C92,210 72,200 58,184", "#ff4fa0", 30, top="#ffa6cf", bottom="#d61c6e", cap="butt"),
        part(poly([(38, 216), (30, 146), (96, 166)]), "#ff4fa0", top="#ffa6cf", bottom="#d61c6e", line=False),
    ]


@icon("shop", ink="#4a0a2e")
def _shop():
    pink, top, bot = "#ff4fa0", "#ffa6cf", "#d61c6e"
    return [
        stroke("M76,104 L76,82 C76,48 100,28 128,28 C156,28 180,48 180,82 L180,104", "#ffd21a", 18,
               top="#fff07a", bottom="#e08a00"),
        part(path("M28,100 L228,100 L206,226 C204,234 198,238 190,238 L66,238 C58,238 52,234 50,226 Z"),
             pink, top=top, bottom=bot, gloss=[gloss(rect(48, 112, 160, 14, 7), 0.45)]),
        detail(rect(76, 144, 22, 70, 11), dark(pink, 0.3)),
        detail(rect(117, 144, 22, 70, 11), dark(pink, 0.3)),
        detail(rect(158, 144, 22, 70, 11), dark(pink, 0.3)),
        part(rect(20, 92, 216, 34, 12), pink, top="#ff8cc2", bottom="#e02c7c"),
    ]


@icon("starter", ink="#4a1606")
def _starter():
    return [
        part(rect(28, 112, 200, 124, 20), "#d8572a", top="#f2894e", bottom="#a8360f"),
        part(path("M28,120 L28,100 C28,58 72,30 128,30 C184,30 228,58 228,100 L228,120 Z"), "#e8693a",
             top="#ffa36e", bottom="#c0461a", gloss=[gloss(ellipse(84, 62, 34, 12, -15), 0.45)]),
        part(rect(28, 104, 200, 26, 6), "#ffc21a", top="#fff07a", bottom="#e07800"),
        part(rect(100, 100, 56, 64, 14), "#ffc21a", top="#fff07a", bottom="#e07800"),
        part(rounded_star(128, 130, 18, 0.5), "#ffffff", top="#ffffff", bottom="#fff0b0", line=False),
    ]


@icon("ticket", ink="#4a2200")
def _ticket():
    shape = path("M40,60 L216,60 C224,60 232,68 232,76 L232,104 C218,104 208,116 208,128 C208,140 218,152 232,152 "
                 "L232,180 C232,188 224,196 216,196 L40,196 C32,196 24,188 24,180 L24,152 C38,152 48,140 48,128 "
                 "C48,116 38,104 24,104 L24,76 C24,68 32,60 40,60 Z")
    return [
        part(shape, "#ffb21a", top="#ffe27a", bottom="#f07800", gloss=[gloss(rect(48, 72, 140, 12, 6), 0.45)]),
        line_detail("M176,76 L176,180", "#b85a00", 6, 0.6),
        part(rounded_star(114, 128, 40, 0.5), "#ffffff", top="#ffffff", bottom="#ffe9b0"),
    ]


@icon("trails", ink="#3e0a3a")
def _trails():
    return [
        part(path("M34,232 C70,170 110,110 156,60 L216,124 C160,166 96,204 34,232 Z"), "#ff9ad6",
             top="#ffe6f5", bottom="#e05cb8"),
        part(circle(186, 92, 44), "#ff6ac1", top="#ffd1ec", bottom="#d63aa6",
             gloss=[gloss(ellipse(172, 76, 14, 9, -30), 0.85)]),
        part(rounded_star(70, 92, 24, 0.45), "#ffd21a", top="#fff07a", bottom="#f09a00"),
        part(rounded_star(150, 200, 18, 0.45), "#ffd21a", top="#fff07a", bottom="#f09a00"),
        part(rounded_star(40, 162, 14, 0.45), "#ffd21a", top="#fff07a", bottom="#f09a00"),
    ]


@icon("trash", ink="#4d0612")
def _trash():
    red, top, bot = "#ff3b4f", "#ff8592", "#c8102a"
    return [
        stroke("M100,46 L100,36 C100,28 106,24 114,24 L142,24 C150,24 156,28 156,36 L156,46", "#c8d2de", 14,
               top="#ffffff", bottom="#8d9db3"),
        part(path("M48,72 L208,72 L192,224 C191,233 184,238 176,238 L80,238 C72,238 65,233 64,224 Z"), red,
             top=top, bottom=bot),
        detail(rect(86, 102, 18, 112, 9), dark(red, 0.3)),
        detail(rect(119, 102, 18, 112, 9), dark(red, 0.3)),
        detail(rect(152, 102, 18, 112, 9), dark(red, 0.3)),
        part(rect(30, 44, 196, 38, 14), red, top="#ffa0aa", bottom="#e02a40",
             gloss=[gloss(rect(46, 51, 120, 10, 5), 0.5)]),
    ]


@icon("sort", ink="#0e2846")
def _sort():
    return [
        part(poly([(70, 24), (126, 92), (92, 92), (92, 232), (48, 232), (48, 92), (14, 92)]), "#2e95ff",
             top="#8fd2ff", bottom="#1662d6"),
        part(poly([(186, 232), (242, 164), (208, 164), (208, 24), (164, 24), (164, 164), (130, 164)]), "#ffb21a",
             top="#ffe27a", bottom="#f07800"),
    ]


@icon("title", ink="#4d0612")
def _title():
    red, top, bot = "#ff3448", "#ff8a96", "#c20f28"
    return [
        part(path("M10,150 L52,138 L60,206 L34,192 L14,214 Z"), "#b80d22", top="#e8384c", bottom="#7c0616"),
        part(path("M246,150 L204,138 L196,206 L222,192 L242,214 Z"), "#b80d22", top="#e8384c", bottom="#7c0616"),
        part(path("M36,126 C90,100 166,100 220,126 L208,190 C158,170 98,170 48,190 Z"), red, top=top, bottom=bot,
             gloss=[gloss(path("M54,132 C96,116 160,116 202,132 L200,142 C158,128 98,128 56,142 Z"), 0.5)]),
        part(rounded_star(128, 92, 66, 0.5), "#ffc21a", top="#fff07a", bottom="#f08a00",
             gloss=[gloss(ellipse(112, 74, 10, 6, -30), 0.8)]),
        part(rounded_star(66, 82, 18, 0.5), "#ffc21a", top="#fff07a", bottom="#f08a00"),
        part(rounded_star(190, 82, 18, 0.5), "#ffc21a", top="#fff07a", bottom="#f08a00"),
    ]


# -- rendering ----------------------------------------------------------------

def el(shape, extra):
    tag, a = shape
    return f"<{tag} {attrs({**a, **extra})}/>"


def render(name, parts, ink):
    defs, under, over = [], [], []
    main = next(p["color"] for p in parts if p["kind"] in ("fill", "stroke"))
    ink = ink or ink_of(main)
    for i, p in enumerate(parts):
        kind = p["kind"]
        if kind in ("fill", "stroke"):
            top = p["top"] or light(p["color"], 0.35)
            bottom = p["bottom"] or dark(p["color"], 0.2)
            gid = f"g{i}"
            defs.append(f'<linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1" gradientUnits="objectBoundingBox">'
                        f'<stop offset="0" stop-color="{top}"/><stop offset="0.55" stop-color="{p["color"]}"/>'
                        f'<stop offset="1" stop-color="{bottom}"/></linearGradient>')
            if kind == "fill":
                outline = {"fill": ink, "stroke": ink, "stroke_width": OUTLINE, "stroke_linejoin": "round"}
                under.append(f'<g transform="translate(0 {DEPTH})">{el(p["shape"], outline)}</g>')
                under.append(el(p["shape"], outline))
                fill = {"fill": f"url(#{gid})"}
                if p["line"]:
                    fill.update({"stroke": ink, "stroke_width": INNER, "stroke_linejoin": "round"})
                over.append(el(p["shape"], fill))
            else:
                w, cap = p["width"], p["cap"]
                outline = {"fill": "none", "stroke": ink, "stroke_width": w + OUTLINE, "stroke_linecap": cap,
                           "stroke_linejoin": "round"}
                under.append(f'<g transform="translate(0 {DEPTH})">{el(p["shape"], outline)}</g>')
                under.append(el(p["shape"], outline))
                over.append(el(p["shape"], {"fill": "none", "stroke": ink, "stroke_width": w + INNER * 2,
                                            "stroke_linecap": cap, "stroke_linejoin": "round"}))
                over.append(el(p["shape"], {"fill": "none", "stroke": f"url(#{gid})", "stroke_width": w,
                                            "stroke_linecap": cap, "stroke_linejoin": "round"}))
            for g in p["gloss"]:
                over.append(el(g["shape"], {"fill": "#ffffff", "opacity": g["opacity"]}))
        elif kind == "gloss":
            over.append(el(p["shape"], {"fill": "#ffffff", "opacity": p["opacity"]}))
        elif kind == "detail":
            over.append(el(p["shape"], {"fill": p["color"], "opacity": p["opacity"]}))
        elif kind == "line":
            over.append(el(p["shape"], {"fill": "none", "stroke": p["color"], "stroke_width": p["width"],
                                        "stroke_linecap": "round", "stroke_linejoin": "round",
                                        "opacity": p["opacity"]}))
    pad = OUTLINE
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{-pad} {-pad} {256 + pad * 2} {256 + pad * 2}" '
            f'width="{256 + pad * 2}" height="{256 + pad * 2}">\n<defs>{"".join(defs)}</defs>\n'
            + "\n".join(under) + "\n" + "\n".join(over) + "\n</svg>\n")


def main():
    os.makedirs(OUT, exist_ok=True)
    for old in os.listdir(OUT):
        if old.endswith(".svg"):
            os.remove(os.path.join(OUT, old))
    for name, (fn, ink) in sorted(ICONS.items()):
        with open(os.path.join(OUT, f"{name}.svg"), "w") as f:
            f.write(render(name, fn(), ink))
    print(f"Wrote {len(ICONS)} icons to {os.path.relpath(OUT)}")


main()
