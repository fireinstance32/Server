"""Builds the gym decor (reference: themed decor round each gym's pool): a
torii gate, pink voxel cherry trees, candles, stone and paper lanterns, lily
pads, a lotus, grass tufts, a jack-o'-lantern and bamboo. Low-poly and
faceted, like the rest of the scenery.

Headless (exports everything + an optional preview render):
    blender -b -P tools/blender/build_decor.py -- assets/models/Decor [--preview <png>]
Live Blender (Blender MCP): exec this file with a `__name__` other than
"__main__" and call `showcase()`.

Output:
    assets/models/Decor/Decor.fbx          every model under an empty named
                                           after it (import once in Studio,
                                           into ReplicatedStorage.Assets.Decor)
    assets/models/Decor/Shapes/<Name>.fbx  one file per model

Same conventions as build_nature.py (whose helpers this reuses): meshes are
"<Name>_<Role>", a hidden Root is the pivot. Body and Glow take the colour
the game passes (lantern paper, flower petals, flames); every other role is
FIXED. Built in studs standing on z=0; the game rescales each model to the
width it wants (WorldBuilder/PondRow/Decor, WorldBuilder/Props).
"""

import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import build_rocks as R  # noqa: E402
import build_nature as N  # noqa: E402

DECOR = {
    "Lacquer": (220, 52, 40),
    "Ink": (44, 38, 44),
    "Blossom": (255, 168, 208),
    "BlossomLight": (255, 205, 228),
    "Wax": (246, 236, 214),
    "Wick": (60, 50, 45),
    "StoneLight": (176, 174, 168),
    "Pad": (64, 168, 72),
    "PadLight": (110, 200, 96),
    "LotusPink": (255, 150, 196),
    "LotusWhite": (255, 228, 240),
    "Cane": (126, 196, 84),
    "CaneDark": (92, 150, 62),
}
R.FIXED.update({role: R.srgb(*rgb) for role, rgb in DECOR.items()})
R.ROUGH.update({"Lacquer": 0.35, "Wax": 0.5})

shape = R.shape
V = Vector
tube, ribbon, blob, cone, box = N.tube, N.ribbon, N.blob, N.cone, N.box


def disc(bm, radius, thick, at, sides=14, notch=0.0):
    """A flat round pad, optionally with a wedge cut out (lily pads)."""
    start = notch / 2
    span = math.tau - notch
    pts = [V((math.cos(start + span * k / sides), math.sin(start + span * k / sides), 0)) * radius for k in range(sides + 1)]
    if notch:
        pts.append(V((0, 0, 0)))
    else:
        pts.pop()
    tmp = bmesh.new()
    top = [tmp.verts.new(V(at) + p + V((0, 0, thick))) for p in pts]
    bot = [tmp.verts.new(V(at) + p) for p in pts]
    n = len(pts)
    tmp.faces.new(top)
    tmp.faces.new(list(reversed(bot)))
    for k in range(n):
        k2 = (k + 1) % n
        tmp.faces.new((bot[k], bot[k2], top[k2], top[k]))
    R.merge(bm, tmp)
    tmp.free()


def petal_ring(bm, at, count, length, width, lift, spin=0.0):
    """A ring of pointed petals tilted up by `lift` (0 flat .. 1 upright)."""
    for k in range(count):
        a = spin + k / count * math.tau
        d = V((math.cos(a), math.sin(a), 0))
        side = V((-d.y, d.x, 0))
        rows = []
        for s in range(5):
            u = s / 4
            c = V(at) + d * (u * length * (1 - lift * 0.5)) + V((0, 0, u * length * lift))
            w = width * math.sin(math.pi * min(u * 1.15, 1.0)) + 0.02
            rows.append((c + side * w, c, c - side * w))
        ribbon(bm, rows, thick=0.06)


# --- gates and lanterns ---


@shape("ToriiGate")
def d_torii(p, rng):
    span = 4.8
    for sx in (-1, 1):
        x = sx * span
        R.cylinder(p["Lacquer"], 0.45, 0.4, 8.2, V((x, 0, 0)), segments=12)
        R.cylinder(p["Ink"], 0.6, 0.55, 0.7, V((x, 0, 0)), segments=12)
    # The tie beam (nuki) and its centre strut.
    box(p["Lacquer"], (11.6, 0.5, 0.55), (0, 0, 6.4), bevel=0.06)
    box(p["Lacquer"], (0.5, 0.42, 1.4), (0, 0, 7.3), bevel=0.05)
    # The top beams (shimaki + kasagi), the black one curving up at the ends.
    box(p["Lacquer"], (12.6, 0.8, 0.7), (0, 0, 8.25), bevel=0.06)
    segs = 9
    for i in range(segs):
        u0, u1 = i / segs, (i + 1) / segs
        x0, x1 = -7.2 + 14.4 * u0, -7.2 + 14.4 * u1
        lift = lambda x: 0.55 * (abs(x) / 7.2) ** 2.4  # noqa: E731
        mid = (x0 + x1) / 2
        box(p["Ink"], (x1 - x0 + 0.04, 1.05, 0.5), (mid, 0, 8.85 + lift(mid)), bevel=0.04, turn=0)


@shape("StoneLantern")
def d_stone_lantern(p, rng):
    stone, light = p["StoneLight"], p["Stone"]
    cone(stone, 1.0, 0.85, 0.35, (0, 0, 0), sides=6)
    cone(stone, 0.85, 0.7, 0.25, (0, 0, 0.35), sides=6)
    R.cylinder(stone, 0.32, 0.28, 1.6, V((0, 0, 0.6)), segments=8)
    cone(light, 0.75, 0.75, 0.25, (0, 0, 2.2), sides=6)
    # The fire box: stone corners round a glowing core.
    for k in range(6):
        a = k / 6 * math.tau
        box(stone, (0.18, 0.18, 0.95), (math.cos(a) * 0.55, math.sin(a) * 0.55, 2.92), bevel=0.03)
    R.ellipsoid(p["Glow"], V((0, 0, 2.92)), (0.45, 0.45, 0.42), subdiv=1)
    cone(stone, 1.25, 0.15, 0.85, (0, 0, 3.4), sides=6)
    R.ellipsoid(light, V((0, 0, 4.35)), (0.22, 0.22, 0.25), subdiv=1)


@shape("PaperLantern")
def d_paper_lantern(p, rng):
    R.cylinder(p["BarkDark"], 0.12, 0.1, 3.4, V((0, 0, 0)), segments=6)
    box(p["BarkDark"], (1.0, 0.16, 0.16), (0.42, 0, 3.35), bevel=0.03)
    hang = V((0.82, 0, 2.0))
    R.ellipsoid(p["Body"], hang, (0.5, 0.5, 0.68), subdiv=2)
    for z in (-0.38, 0.0, 0.38):
        r = 0.5 * math.sqrt(max(0.0, 1 - (z / 0.7) ** 2)) + 0.02
        R.cylinder(p["Ink"], r, r, 0.05, hang + V((0, 0, z - 0.025)), segments=14, caps=False)
    R.cylinder(p["Ink"], 0.25, 0.25, 0.14, hang + V((0, 0, 0.62)), segments=10)
    R.cylinder(p["Ink"], 0.25, 0.25, 0.14, hang + V((0, 0, -0.76)), segments=10)
    R.cylinder(p["BarkDark"], 0.03, 0.03, 0.75, hang + V((0, 0, 0.7)), segments=4)
    R.ellipsoid(p["Glow"], hang + V((0, 0, -0.8)), (0.12, 0.12, 0.08), subdiv=1)


# --- candles ---


def candle(p, at, height, radius):
    at = V(at)
    R.cylinder(p["Wax"], radius, radius * 0.96, height, at, segments=10)
    # A drip down the side.
    R.ellipsoid(p["Wax"], at + V((radius * 0.95, 0, height * 0.75)), (0.06, 0.06, height * 0.18), subdiv=1)
    R.cylinder(p["Wick"], 0.03, 0.03, 0.14, at + V((0, 0, height)), segments=4)
    R.ellipsoid(p["Glow"], at + V((0, 0, height + 0.3)), (0.1, 0.1, 0.22), subdiv=1)


@shape("Candle")
def d_candle(p, rng):
    cone(p["Stone"], 0.45, 0.4, 0.12, (0, 0, 0), sides=10)
    candle(p, (0, 0, 0.12), 1.3, 0.22)


@shape("CandleTrio")
def d_candle_trio(p, rng):
    cone(p["Stone"], 0.95, 0.88, 0.12, (0, 0, 0), sides=12)
    for (x, y, h) in ((0, 0.2, 1.6), (-0.45, -0.25, 1.05), (0.48, -0.2, 0.75)):
        candle(p, (x, y, 0.12), h, 0.2)


# --- water plants ---


@shape("LilyPad")
def d_lily_pad(p, rng):
    disc(p["Pad"], 1.0, 0.08, (0, 0, 0), notch=0.5)
    for k in range(5):
        a = 0.25 + k / 5 * (math.tau - 0.5) + 0.3
        box(p["PadLight"], (0.75, 0.05, 0.02), (math.cos(a) * 0.4, math.sin(a) * 0.4, 0.09), bevel=0, turn=a)
    disc(p["Pad"], 0.55, 0.06, (1.15, 0.6, 0), notch=0.6, sides=10)


@shape("LilyPadFlower")
def d_lily_flower(p, rng):
    disc(p["Pad"], 1.0, 0.08, (0, 0, 0), notch=0.5)
    petal_ring(p["Body"], (0.1, 0, 0.08), 8, 0.55, 0.16, 0.35)
    petal_ring(p["Body"], (0.1, 0, 0.1), 6, 0.4, 0.13, 0.7, spin=0.4)
    R.ellipsoid(p["Pollen"], V((0.1, 0, 0.2)), (0.12, 0.12, 0.08), subdiv=1)


@shape("Lotus")
def d_lotus(p, rng):
    disc(p["Pad"], 1.1, 0.08, (0, 0, 0), notch=0.4)
    at = (0.15, 0.1, 0.08)
    petal_ring(p["LotusWhite"], at, 8, 0.75, 0.2, 0.3)
    petal_ring(p["LotusPink"], at, 8, 0.65, 0.18, 0.65, spin=0.4)
    petal_ring(p["LotusPink"], at, 5, 0.45, 0.15, 0.9, spin=0.1)
    R.ellipsoid(p["Pollen"], V(at) + V((0, 0, 0.18)), (0.14, 0.14, 0.08), subdiv=1)


# --- plants ---


@shape("GrassTuft")
def d_grass(p, rng):
    for k in range(9):
        a = k / 9 * math.tau + rng.uniform(-0.3, 0.3)
        d = V((math.cos(a), math.sin(a), 0))
        side = V((-d.y, d.x, 0))
        h = rng.uniform(0.9, 1.5)
        rows = []
        for s in range(5):
            u = s / 4
            c = d * (0.12 + u * u * 0.6) + V((0, 0, u * h))
            w = 0.1 * (1 - u) + 0.01
            rows.append((c + side * w, c, c - side * w))
        ribbon(p["Leaf" if k % 2 else "LeafLight"], rows, thick=0.04)


@shape("Bamboo")
def d_bamboo(p, rng):
    for k, (x, y, h) in enumerate(((0, 0, 7.0), (0.7, 0.4, 5.6), (-0.6, 0.5, 6.3), (0.2, -0.7, 4.8))):
        base = V((x, y, 0))
        lean = V((rng.uniform(-0.25, 0.25), rng.uniform(-0.25, 0.25), 0))
        nodes = int(h / 1.2)
        for i in range(nodes):
            a = base + lean * (i / nodes) + V((0, 0, i * h / nodes))
            b = base + lean * ((i + 1) / nodes) + V((0, 0, (i + 1) * h / nodes))
            tube(p["Cane"], [a, b], [0.17, 0.16], sides=7)
            tube(p["CaneDark"], [b - V((0, 0, 0.06)), b + V((0, 0, 0.06))], [0.2, 0.2], sides=7)
        top = base + lean + V((0, 0, h))
        for j in range(4):
            a = rng.uniform(0, math.tau)
            d = V((math.cos(a), math.sin(a), 0))
            side = V((-d.y, d.x, 0))
            at = top - V((0, 0, rng.uniform(0, 2.2)))
            rows = []
            for s in range(5):
                u = s / 4
                c = at + d * (u * 1.5) + V((0, 0, -u * u * 0.5))
                w = 0.22 * math.sin(math.pi * min(u * 1.1, 1.0)) + 0.02
                rows.append((c + side * w, c, c - side * w))
            ribbon(p["Leaf" if j % 2 else "LeafLight"], rows, thick=0.04)


def cherry(p, rng, height, width, tiers):
    """A pink voxel tree (reference): square trunk and stacked blossom cubes."""
    box(p["Bark"], (0.9, 0.9, height), (0, 0, height / 2), bevel=0.08)
    box(p["BarkDark"], (1.3, 1.3, 0.4), (0, 0, 0.2), bevel=0.08)
    # Two branches out of the trunk under the canopy.
    for sx in (-1, 1):
        box(p["Bark"], (1.6, 0.5, 0.5), (sx * 0.8, 0, height - 0.6), bevel=0.05, turn=0)
    z = height - 0.4
    w = width
    for t in range(tiers):
        h = w * 0.62
        box(p["Blossom"], (w, w * 0.92, h), (0, 0, z + h / 2), bevel=0.2, turn=rng.uniform(-0.15, 0.15))
        for k in range(4):
            a = rng.uniform(0, math.tau)
            s = w * rng.uniform(0.26, 0.36)
            at = V((math.cos(a) * w * 0.5, math.sin(a) * w * 0.5, z + rng.uniform(0.2, 0.9) * h))
            box(p["BlossomLight" if k % 2 else "Blossom"], (s, s, s), at, bevel=0.1, turn=rng.uniform(0, 1))
        z += h * 0.82
        w *= 0.66
    box(p["BlossomLight"], (w * 1.1, w * 1.1, w * 0.8), (0, 0, z + w * 0.4), bevel=0.12)
    # Fallen petals round the foot.
    for k in range(6):
        a = rng.uniform(0, math.tau)
        r = rng.uniform(0.9, width * 0.45)
        box(p["BlossomLight"], (0.3, 0.3, 0.05), (math.cos(a) * r, math.sin(a) * r, 0.03), bevel=0, turn=a)


@shape("CherryTree")
def d_cherry(p, rng):
    cherry(p, rng, 4.2, 5.2, 2)


@shape("CherryTreeSmall")
def d_cherry_small(p, rng):
    cherry(p, rng, 3.0, 3.8, 2)


@shape("JackOLantern", smooth=("Pumpkin",))
def d_jack(p, rng):
    lobes = 8
    for k in range(lobes):
        a = k / lobes * math.tau
        R.ellipsoid(p["Pumpkin"], V((math.cos(a) * 0.55, math.sin(a) * 0.55, 1.0)), (0.75, 0.75, 0.95), rot_matrix=Matrix.Rotation(a, 4, "Z") @ Matrix.Diagonal((0.65, 1.0, 1.0, 1)), subdiv=2)
    tube(p["Vine"], [(0, 0, 1.75), (0.05, 0, 2.2), (0.3, 0.1, 2.55)], [0.2, 0.15, 0.1], sides=6)
    # The carved face (glowing) on the -Y side.
    y = -1.02
    for sx in (-1, 1):
        box(p["Glow"], (0.34, 0.14, 0.18), (sx * 0.38, y, 1.3), bevel=0)
        box(p["Glow"], (0.18, 0.14, 0.14), (sx * 0.38, y, 1.44), bevel=0)
    box(p["Glow"], (0.14, 0.14, 0.14), (0, y - 0.02, 1.05), bevel=0)
    for i in range(5):
        x = -0.48 + i * 0.24
        box(p["Glow"], (0.22, 0.14, 0.14 if i % 2 else 0.24), (x, y + 0.1 * (x / 0.48) ** 2, 0.72 + 0.08 * (x / 0.48) ** 2), bevel=0)


# Sample colour per model (for the passed-in colour roles) for previews.
SAMPLES = {
    "ToriiGate": R.srgb(255, 255, 255),
    "CherryTree": R.srgb(255, 255, 255),
    "CherryTreeSmall": R.srgb(255, 255, 255),
    "StoneLantern": R.srgb(255, 170, 60),
    "PaperLantern": R.srgb(230, 60, 50),
    "Candle": R.srgb(255, 170, 60),
    "CandleTrio": R.srgb(255, 170, 60),
    "LilyPad": R.srgb(255, 255, 255),
    "LilyPadFlower": R.srgb(255, 120, 170),
    "Lotus": R.srgb(255, 255, 255),
    "GrassTuft": R.srgb(255, 255, 255),
    "JackOLantern": R.srgb(255, 170, 60),
    "Bamboo": R.srgb(255, 255, 255),
}


def lineup(collection, per_row=5, spacing=11.0):
    empties = []
    names = list(SAMPLES)
    rows = math.ceil(len(names) / per_row)
    for i, name in enumerate(names):
        empty = R.build(name, SAMPLES[name], collection)
        size = max(max(c.dimensions) for c in empty.children if c.type == "MESH")
        k = min(1.0, 8.0 / size) if size > 3 else 2.5
        empty.scale = (k, k, k)
        lo = min((empty.matrix_world @ c.matrix_local @ V(b)).z for c in empty.children if c.type == "MESH" for b in c.bound_box)
        col, row = i % per_row, i // per_row
        empty.location = ((col - (per_row - 1) / 2) * spacing, (row - (rows - 1) / 2) * spacing, -lo * k)
        empties.append(empty)
    return empties


def stage(scene, path=None):
    R.stage(scene, None)
    scene.camera.location = (0, -52, 36)
    scene.camera.data.lens = 26
    scene.camera.rotation_euler = (math.radians(58), 0, 0)
    for obj in scene.objects:
        if obj.name == "Ground":
            obj.scale = (1.6, 1.6, 1)
    if path:
        try:
            scene.render.engine = "BLENDER_EEVEE_NEXT"
        except TypeError:
            scene.render.engine = "BLENDER_EEVEE"
        scene.render.filepath = os.path.abspath(path)
        bpy.ops.render.render(write_still=True)
        print(f"Rendered {path}")


def showcase():
    old = bpy.data.scenes.get("Decor")
    if old:
        for obj in list(old.objects):
            bpy.data.objects.remove(obj)
        bpy.data.scenes.remove(old)
    scene = bpy.data.scenes.new("Decor")
    bpy.context.window.scene = scene
    lineup(scene.collection)
    stage(scene)
    return scene


def main():
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
    out = args[0]
    os.makedirs(f"{out}/Shapes", exist_ok=True)
    for name in SAMPLES:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        R.build(name, SAMPLES[name], bpy.context.scene.collection)
        R.export(f"{out}/Shapes/{name}.fbx")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    for i, name in enumerate(SAMPLES):
        R.build(name, SAMPLES[name], scene.collection).location = (i * 20, 0, 0)
    R.export(f"{out}/Decor.fbx")
    if "--preview" in args:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        scene = bpy.context.scene
        lineup(scene.collection)
        stage(scene, args[args.index("--preview") + 1])


if __name__ == "__main__":
    main()
