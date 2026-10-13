"""Builds the scenery for the throw lane and the hub cliffs: palms, round,
voxel and autumn trees, snowy pines, bushes, cacti, mushrooms, boulders, ice
spikes, crystal clusters, lollipops, gumdrops, pumpkins, reeds and flowers.
Low-poly and faceted, like the reference's scenery.

Headless (exports everything + an optional preview render):
    blender -b -P tools/blender/build_nature.py -- assets/models/Nature [--preview <png>]
Live Blender (Blender MCP): exec this file with a `__name__` other than
"__main__" and call `showcase()`.

Output:
    assets/models/Nature/Nature.fbx          every model under an empty named
                                             after it (import once in Studio,
                                             into ReplicatedStorage.Assets.Nature)
    assets/models/Nature/Shapes/<Name>.fbx   one file per model

Same conventions as build_rocks.py (whose helpers this reuses): meshes are
"<Name>_<Role>", a hidden Root is the pivot, and the game colours roles in
src/shared/Util/Models/Assets.luau. Body / Shade / Gem take the colour the
game passes (autumn leaves, mushroom caps, crystals, lollipops, petals);
every other role is FIXED. Built in studs standing on z=0; the game rescales
each model to the width it wants (WorldBuilder/Props).
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

NATURE = {
    "Leaf": (85, 180, 70),
    "LeafLight": (135, 212, 85),
    "Bark": (130, 88, 58),
    "BarkDark": (100, 68, 44),
    "Coconut": (100, 70, 45),
    "Needle": (60, 150, 95),
    "Snow": (245, 250, 255),
    "Cactus": (95, 170, 85),
    "Petal": (255, 120, 170),
    "Dots": (255, 252, 245),
    "Gills": (235, 215, 190),
    "Ice": (190, 230, 255),
    "CandyA": (255, 110, 150),
    "CandyB": (130, 220, 120),
    "CandyC": (255, 210, 80),
    "Pumpkin": (245, 140, 35),
    "Vine": (95, 120, 50),
    "Pollen": (255, 210, 60),
    "Berry": (220, 40, 60),
}
R.FIXED.update({role: R.srgb(*rgb) for role, rgb in NATURE.items()})
R.ROUGH.update({"Ice": 0.1, "Snow": 0.9})

shape = R.shape
V = Vector


# --- building blocks ---


def tube(bm, pts, radii, sides=8, profile=None, caps=True):
    """A tube along the polyline `pts` (radius per point). `profile(k)` scales
    ring vertex k (ribs, flutes). Parallel-transported so it doesn't twist."""
    tmp = bmesh.new()
    pts = [V(p) for p in pts]
    n = len(pts)
    rings = []
    x_prev = None
    for i, p in enumerate(pts):
        t = (pts[min(i + 1, n - 1)] - pts[max(i - 1, 0)]).normalized()
        ref = x_prev if x_prev is not None else (V((1, 0, 0)) if abs(t.x) < 0.9 else V((0, 1, 0)))
        x = (ref - t * ref.dot(t)).normalized()
        y = t.cross(x)
        x_prev = x
        ring = []
        for k in range(sides):
            a = k / sides * math.tau
            r = radii[i] * (profile(k) if profile else 1.0)
            ring.append(tmp.verts.new(p + (x * math.cos(a) + y * math.sin(a)) * r))
        rings.append(ring)
    for i in range(n - 1):
        for k in range(sides):
            k2 = (k + 1) % sides
            tmp.faces.new((rings[i][k], rings[i][k2], rings[i + 1][k2], rings[i + 1][k]))
    if caps:
        tmp.faces.new(list(reversed(rings[0])))
        tmp.faces.new(rings[-1])
    R.merge(bm, tmp)
    tmp.free()


def ribbon(bm, rows, thick=0.08):
    """A thin closed leaf/blade: `rows` are (left, mid, right) points along
    it; the underside sits `thick` below."""
    tmp = bmesh.new()
    down = V((0, 0, -thick))
    top = [[tmp.verts.new(V(p)) for p in row] for row in rows]
    bot = [[tmp.verts.new(V(p) + down) for p in row] for row in rows]
    for i in range(len(rows) - 1):
        for j in range(2):
            tmp.faces.new((top[i][j], top[i][j + 1], top[i + 1][j + 1], top[i + 1][j]))
            tmp.faces.new((bot[i][j], bot[i + 1][j], bot[i + 1][j + 1], bot[i][j + 1]))
        for j in (0, 2):
            tmp.faces.new((top[i][j], top[i + 1][j], bot[i + 1][j], bot[i][j]))
    for i in (0, len(rows) - 1):
        for j in range(2):
            tmp.faces.new((top[i][j], top[i][j + 1], bot[i][j + 1], bot[i][j]))
    R.merge(bm, tmp)
    tmp.free()


def blob(bm, rng, at, scale, rough=0.2, subdiv=2):
    """Faceted low-poly clump (foliage, snow mounds): a noisy icosphere."""
    tmp = bmesh.new()
    bmesh.ops.create_icosphere(tmp, subdivisions=subdiv, radius=1.0)
    off = V((rng.uniform(-50, 50), rng.uniform(-50, 50), rng.uniform(-50, 50)))
    for v in tmp.verts:
        nrm = v.co.normalized()
        v.co = nrm * (1 + rough * R.fbm(nrm * 1.7 + off, 2))
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ Matrix.Diagonal((*scale, 1)), verts=tmp.verts)
    R.merge(bm, tmp)
    tmp.free()


def cone(bm, r1, r2, h, at, sides=8, jag=0.0, spin=0.0):
    """Upright cone/frustum; `jag` alternates the base radius (pine skirts)."""
    tmp = bmesh.new()
    base = [tmp.verts.new(V(at) + V((math.cos(spin + k / sides * math.tau), math.sin(spin + k / sides * math.tau), 0)) * r1 * (1 + (jag if k % 2 else -jag))) for k in range(sides)]
    if r2 > 0:
        top = [tmp.verts.new(V(at) + V((math.cos(spin + k / sides * math.tau) * r2, math.sin(spin + k / sides * math.tau) * r2, h))) for k in range(sides)]
        for k in range(sides):
            k2 = (k + 1) % sides
            tmp.faces.new((base[k], base[k2], top[k2], top[k]))
        tmp.faces.new(top)
    else:
        tip = tmp.verts.new(V(at) + V((0, 0, h)))
        for k in range(sides):
            tmp.faces.new((base[k], base[(k + 1) % sides], tip))
    tmp.faces.new(list(reversed(base)))
    R.merge(bm, tmp)
    tmp.free()


def box(bm, size, at, bevel=0.12, turn=0.0):
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.transform(tmp, matrix=Matrix.Diagonal((*size, 1)), verts=tmp.verts)
    if bevel:
        bmesh.ops.bevel(tmp, geom=list(tmp.edges), offset=bevel, offset_type="OFFSET", segments=1, profile=0.5, affect="EDGES", clamp_overlap=True)
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ Matrix.Rotation(turn, 4, "Z"), verts=tmp.verts)
    R.merge(bm, tmp)
    tmp.free()


def trunk(p, rng, height, r0, r1, lean=(0, 0), role="Bark", sides=7):
    """A slightly crooked tapering trunk with a flared root. Returns its top."""
    pts, radii = [], []
    steps = 5
    for i in range(steps + 1):
        t = i / steps
        wob = V((rng.uniform(-0.08, 0.08), rng.uniform(-0.08, 0.08), 0)) * height * 0.1 if 0 < i < steps else V()
        pts.append(V((lean[0] * t * t * height, lean[1] * t * t * height, t * height)) + wob)
        radii.append((r0 + (r1 - r0) * t) * (1.35 if i == 0 else 1.0))
    tube(p[role], pts, radii, sides=sides)
    return pts[-1]


# --- trees ---


def palm(p, rng, height, bend):
    top = V((bend * height, 0, height))
    rings = 9
    for i in range(rings):
        t0, t1 = i / rings, (i + 1) / rings
        a = V((bend * t0 * t0 * height, 0, t0 * height))
        b = V((bend * t1 * t1 * height, 0, t1 * height))
        r = 0.62 - 0.22 * t0
        # Each ring flares at its base: the stacked-bark look of a palm.
        tube(p["Bark" if i % 2 else "BarkDark"], [a, a.lerp(b, 0.25), b], [r * 1.16, r, r * 0.94], sides=7)
    fronds = 8
    for k in range(fronds):
        a = k / fronds * math.tau + rng.uniform(-0.15, 0.15)
        d = V((math.cos(a), math.sin(a), 0))
        side = V((-d.y, d.x, 0))
        length = rng.uniform(5.2, 6.4)
        rise = rng.uniform(0.6, 1.3)
        rows = []
        segs = 8
        for s in range(segs + 1):
            u = s / segs
            centre = top + d * (u * length) + V((0, 0, rise * math.sin(u * math.pi * 0.8) - 2.6 * u * u))
            w = 1.25 * math.sin(math.pi * min(u * 1.1, 1.0)) ** 0.7 * (1.0 if s % 2 == 0 else 0.7) + 0.03
            sag = V((0, 0, -0.25 * w))
            rows.append((centre + side * w + sag, centre, centre - side * w + sag))
        ribbon(p["Leaf" if k % 2 else "LeafLight"], rows, thick=0.07)
    for k in range(3):
        a = k / 3 * math.tau + 0.4
        R.ellipsoid(p["Coconut"], top + V((math.cos(a) * 0.55, math.sin(a) * 0.55, -0.45)), (0.42, 0.42, 0.46), subdiv=1)
    blob(p["LeafLight"], rng, top + V((0, 0, 0.1)), (0.7, 0.7, 0.45), rough=0.1, subdiv=1)


@shape("PalmTree")
def n_palm(p, rng):
    palm(p, rng, 12.0, 0.18)


@shape("PalmTreeBent")
def n_palm_bent(p, rng):
    palm(p, rng, 11.0, 0.42)


def leafy(p, rng, top, size, roles=("Leaf", "LeafLight")):
    """A round canopy: one big faceted clump and a ring of smaller ones."""
    blob(p[roles[0]], rng, top, (size, size, size * 0.85))
    for k in range(4):
        a = k / 4 * math.tau + rng.uniform(-0.3, 0.3)
        at = top + V((math.cos(a) * size * 0.75, math.sin(a) * size * 0.75, rng.uniform(-0.45, 0.1) * size))
        s = size * rng.uniform(0.5, 0.65)
        blob(p[roles[k % 2]], rng, at, (s, s, s * 0.85))
    s = size * 0.55
    blob(p[roles[1]], rng, top + V((0, 0, size * 0.6)), (s, s, s * 0.8))


@shape("RoundTree")
def n_round(p, rng):
    top = trunk(p, rng, 5.5, 0.55, 0.32, lean=(0.05, 0.02))
    for k in range(2):
        a = k * math.pi + 0.6
        base = V((0, 0, 3.4 + k * 0.6))
        tube(p["Bark"], [base, base + V((math.cos(a) * 1.4, math.sin(a) * 1.4, 1.3))], [0.22, 0.12], sides=5)
    leafy(p, rng, top + V((0, 0, 1.6)), 2.6)


@shape("RoundTreeTall")
def n_round_tall(p, rng):
    top = trunk(p, rng, 7.5, 0.5, 0.28, lean=(-0.04, 0.03))
    leafy(p, rng, top + V((0, 0, 1.2)), 2.2)
    leafy(p, rng, top + V((0, 0, 3.6)), 1.6)


def voxel(p, rng, height, tiers):
    box(p["Bark"], (1.3, 1.3, height), (0, 0, height / 2), bevel=0.1)
    box(p["BarkDark"], (1.7, 1.7, 0.5), (0, 0, 0.25), bevel=0.1)
    z = height
    w = 4.6
    for t in range(tiers):
        h = w * 0.72
        box(p["Leaf"], (w, w, h), (0, 0, z + h / 2), bevel=0.22, turn=rng.uniform(-0.12, 0.12))
        # Lighter cubes poking out of the sides and top.
        for k in range(3):
            a = rng.uniform(0, math.tau)
            s = w * rng.uniform(0.28, 0.38)
            at = V((math.cos(a) * w * 0.48, math.sin(a) * w * 0.48, z + rng.uniform(0.25, 0.85) * h))
            box(p["LeafLight"], (s, s, s), at, bevel=0.12, turn=rng.uniform(0, 1))
        z += h * 0.85
        w *= 0.68
    box(p["LeafLight"], (w * 1.1, w * 1.1, w * 0.8), (0, 0, z + w * 0.4), bevel=0.15)


@shape("VoxelTree")
def n_voxel(p, rng):
    voxel(p, rng, 3.4, 2)


@shape("VoxelTreeTall")
def n_voxel_tall(p, rng):
    voxel(p, rng, 5.0, 3)


@shape("Bush")
def n_bush(p, rng):
    for k in range(4):
        a = k / 4 * math.tau + rng.uniform(-0.3, 0.3)
        s = rng.uniform(0.9, 1.25)
        r = 0.0 if k == 0 else 1.0
        blob(p["Leaf" if k % 2 == 0 else "LeafLight"], rng, V((math.cos(a) * r, math.sin(a) * r, s * 0.65)), (s * 1.15, s * 1.15, s * 0.85))
    for k in range(5):
        a = rng.uniform(0, math.tau)
        R.ellipsoid(p["Berry"], V((math.cos(a) * 1.3, math.sin(a) * 1.3, rng.uniform(0.7, 1.4))), (0.16, 0.16, 0.16), subdiv=1)


@shape("AutumnTree")
def n_autumn(p, rng):
    top = trunk(p, rng, 5.0, 0.5, 0.3, lean=(0.06, -0.03), role="BarkDark")
    leafy(p, rng, top + V((0, 0, 1.4)), 2.5, roles=("Body", "Shade"))


@shape("AutumnTreeTall")
def n_autumn_tall(p, rng):
    top = trunk(p, rng, 6.5, 0.45, 0.25, lean=(-0.05, 0.02), role="BarkDark")
    # A taller, egg-shaped crown.
    for k, (z, s) in enumerate(((0.8, 2.2), (2.8, 1.9), (4.6, 1.3))):
        blob(p["Body" if k % 2 == 0 else "Shade"], rng, top + V((0, 0, z)), (s, s, s * 1.05))


def pine(p, rng, tiers, w0):
    box(p["Bark"], (0.7, 0.7, 1.6), (0, 0, 0.8), bevel=0.08)
    z, w = 1.2, w0
    for t in range(tiers):
        h = w * 1.35
        spin = rng.uniform(0, 1)
        cone(p["Needle"], w, 0.0, h, (0, 0, z), sides=10, jag=0.12, spin=spin)
        # Snow on the upper part of each tier, with a jagged lower edge.
        cut = 0.55
        cone(p["Snow"], w * cut * 1.15, 0.0, h * cut + 0.2, (0, 0, z + h * (1 - cut) - 0.02), sides=10, jag=0.18, spin=spin + 0.31)
        z += h * 0.55
        w *= 0.74


@shape("SnowPine")
def n_pine(p, rng):
    pine(p, rng, 3, 2.6)


@shape("SnowPineTall")
def n_pine_tall(p, rng):
    pine(p, rng, 4, 2.6)


def cactus_body(p, pts, r):
    ribs = lambda k: 1.0 if k % 2 == 0 else 0.84  # noqa: E731
    radii = [r] * len(pts)
    # Round the top off.
    tip = V(pts[-1])
    d = (V(pts[-1]) - V(pts[-2])).normalized()
    pts = list(pts) + [tip + d * r * 0.45, tip + d * r * 0.8]
    radii += [r * 0.78, r * 0.35]
    tube(p["Cactus"], pts, radii, sides=16, profile=ribs)


def cactus(p, rng, height, arms):
    r = 0.75
    cactus_body(p, [(0, 0, 0), (0, 0, height * 0.5), (0, 0, height)], r)
    for k in range(arms):
        side = 1 if k == 0 else -1
        y0 = height * rng.uniform(0.32, 0.52)
        reach = rng.uniform(1.3, 1.8)
        up = rng.uniform(1.6, 2.6)
        pts = [(0, 0, y0), (side * reach * 0.6, 0, y0 + 0.1), (side * reach, 0, y0 + 0.6), (side * reach, 0, y0 + up)]
        cactus_body(p, pts, r * 0.62)
    if rng.random() < 0.8:
        for k in range(5):
            a = k / 5 * math.tau
            R.ellipsoid(p["Petal"], V((math.cos(a) * 0.32, math.sin(a) * 0.32, height + r * 0.75)), (0.28, 0.28, 0.12), subdiv=1)
        R.ellipsoid(p["Pollen"], V((0, 0, height + r * 0.8)), (0.18, 0.18, 0.12), subdiv=1)


@shape("Cactus")
def n_cactus(p, rng):
    cactus(p, rng, 4.2, 1)


@shape("CactusTall")
def n_cactus_tall(p, rng):
    cactus(p, rng, 6.0, 2)


def mushroom(p, rng, at, height, cap):
    at = V(at)
    lean = V((rng.uniform(-0.2, 0.2), rng.uniform(-0.2, 0.2), 0))
    top = at + V((0, 0, height)) + lean
    tube(p["Stem"], [at, at + V((0, 0, height * 0.5)) + lean * 0.3, top], [height * 0.2, height * 0.16, height * 0.17], sides=10)
    # Cap: a squashed dome over a flat gill disc.
    dome = bmesh.new()
    bmesh.ops.create_uvsphere(dome, u_segments=14, v_segments=8, radius=1.0)
    bmesh.ops.delete(dome, geom=[v for v in dome.verts if v.co.z < -0.05], context="VERTS")
    for v in dome.verts:
        v.co.z = max(v.co.z, 0.0)
    bmesh.ops.contextual_create(dome, geom=[e for e in dome.edges if e.is_boundary])
    bmesh.ops.transform(dome, matrix=Matrix.Translation(top - V((0, 0, cap * 0.08))) @ Matrix.Diagonal((cap, cap, cap * 0.62, 1)), verts=dome.verts)
    R.merge(p["Body"], dome)
    dome.free()
    R.cylinder(p["Gills"], cap * 0.93, cap * 0.3, cap * 0.16, top - V((0, 0, cap * 0.2)), segments=14)
    for k in range(6):
        a = k / 6 * math.tau + rng.uniform(-0.2, 0.2)
        e = rng.uniform(0.35, 0.75)
        nrm = V((math.cos(a) * math.sin(e * 1.3), math.sin(a) * math.sin(e * 1.3), math.cos(e * 1.3)))
        spot = top - V((0, 0, cap * 0.08)) + V((nrm.x * cap, nrm.y * cap, nrm.z * cap * 0.62))
        R.ellipsoid(p["Dots"], spot, (cap * 0.13, cap * 0.13, cap * 0.05), rot_matrix=R.aim(nrm), subdiv=1)
    R.ellipsoid(p["Dots"], top + V((0, 0, cap * 0.54)), (cap * 0.16, cap * 0.16, cap * 0.05), subdiv=1)


@shape("Mushroom")
def n_mushroom(p, rng):
    mushroom(p, rng, (0, 0, 0), 2.2, 1.7)


@shape("MushroomPair")
def n_mushroom_pair(p, rng):
    mushroom(p, rng, (0, 0, 0), 2.6, 1.9)
    mushroom(p, rng, (1.9, 0.6, 0), 1.3, 0.9)


def boulder(p, rng, at, s):
    stone = p["Stone"]
    tmp = bmesh.new()
    R.rock(tmp, rng, subdiv=2, rough=0.12, cuts=7, cut=0.22, at=at, scale=(s * 1.25, s, s * 0.8))
    moss = lambda co, nrm: R.smoothstep(0.35, 0.75, nrm.z)  # noqa: E731
    R.coat(p["Leaf"], tmp, moss, lift=0.06, sink=0.06)
    R.merge(stone, tmp)
    tmp.free()


@shape("Boulder")
def n_boulder(p, rng):
    boulder(p, rng, (0, 0, 0.9), 1.4)


@shape("BoulderPair")
def n_boulder_pair(p, rng):
    boulder(p, rng, (0, 0, 1.0), 1.5)
    boulder(p, rng, (2.0, 0.8, 0.6), 0.8)


@shape("IceSpikes", smooth=())
def n_ice(p, rng):
    blob(p["Snow"], rng, V((0, 0, 0.1)), (2.0, 1.8, 0.55), rough=0.15)
    for k in range(6):
        a = k / 6 * math.tau + rng.uniform(-0.3, 0.3)
        r = 0.0 if k == 0 else rng.uniform(0.7, 1.3)
        h = 3.6 if k == 0 else rng.uniform(1.4, 2.6)
        d = R.rand_dir(rng, up=3.0)
        R.crystal(p["Ice"], rng.uniform(0.35, 0.5), h, V((math.cos(a) * r, math.sin(a) * r, 0.2)), d, spin=rng.uniform(0, 1), sides=5, chamfer=0.05)


@shape("CrystalCluster", smooth=())
def n_crystals(p, rng):
    R.rock(p["Stone"], rng, subdiv=2, rough=0.1, cuts=6, cut=0.3, at=(0, 0, 0.35), scale=(1.6, 1.4, 0.6))
    for k in range(7):
        a = k / 7 * math.tau + rng.uniform(-0.3, 0.3)
        r = 0.0 if k == 0 else rng.uniform(0.5, 1.1)
        h = 3.8 if k == 0 else rng.uniform(1.2, 2.6)
        d = V((math.cos(a) * r * 0.5, math.sin(a) * r * 0.5, 1.0))
        R.crystal(p["Gem"], rng.uniform(0.32, 0.5), h, V((math.cos(a) * r, math.sin(a) * r, 0.4)), d, spin=rng.uniform(0, 1), sides=6, chamfer=0.06)


# --- sweets & harvest ---


@shape("Lollipop", smooth=("Stick",))
def n_lollipop(p, rng):
    R.cylinder(p["Stick"], 0.16, 0.16, 5.0, (0, 0, 0), segments=10)
    centre = V((0, 0, 6.2))
    face = V((0, 1, 0))
    # Pinwheel swirl: alternating wedges, then a rim and a centre button.
    wedges = 10
    for k in range(wedges):
        a0, a1 = k / wedges * math.tau, (k + 1) / wedges * math.tau
        tmp = bmesh.new()
        pts = [V((0, 0, 0))] + [V((math.cos(a0 + (a1 - a0) * s / 3), 0, math.sin(a0 + (a1 - a0) * s / 3))) * 1.55 for s in range(4)]
        front = [tmp.verts.new(centre + q + face * -0.2) for q in pts]
        back = [tmp.verts.new(centre + q + face * 0.2) for q in pts]
        tmp.faces.new(front)
        tmp.faces.new(list(reversed(back)))
        for i in range(len(pts)):
            j = (i + 1) % len(pts)
            tmp.faces.new((front[i], back[i], back[j], front[j]))
        R.merge(p["Body" if k % 2 == 0 else "Frosting"], tmp)
        tmp.free()
    R.torus(p["Body"], 1.6, 0.25, at=centre, direction=face, seg=24, ring=8)
    R.cylinder(p["Frosting"], 0.35, 0.35, 0.5, centre - face * 0.25, face, segments=12)


@shape("Gumdrops", smooth=("CandyA", "CandyB", "CandyC"))
def n_gumdrops(p, rng):
    for k, (role, at, s) in enumerate((("CandyA", (0, 0), 1.2), ("CandyB", (1.5, 0.6), 0.9), ("CandyC", (0.4, 1.5), 0.75), ("CandyA", (-1.2, 1.0), 0.6))):
        dome = bmesh.new()
        bmesh.ops.create_uvsphere(dome, u_segments=12, v_segments=8, radius=1.0)
        bmesh.ops.delete(dome, geom=[v for v in dome.verts if v.co.z < -0.3], context="VERTS")
        for v in dome.verts:
            v.co.z = max(v.co.z, -0.3)
        bmesh.ops.contextual_create(dome, geom=[e for e in dome.edges if e.is_boundary])
        bmesh.ops.transform(dome, matrix=Matrix.Translation((at[0], at[1], s * 0.3)) @ Matrix.Diagonal((s, s, s * 1.15, 1)), verts=dome.verts)
        R.merge(p[role], dome)
        dome.free()
        # Sugar crystals.
        for _ in range(6):
            d = R.rand_dir(rng, up=1.2)
            R.ellipsoid(p["Dots"], V((at[0], at[1], s * 0.3)) + V((d.x * s, d.y * s, d.z * s * 1.15)), (0.08, 0.08, 0.08), subdiv=1)


@shape("Pumpkin", smooth=("Pumpkin",))
def n_pumpkin(p, rng):
    lobes = 8
    for k in range(lobes):
        a = k / lobes * math.tau
        R.ellipsoid(p["Pumpkin"], V((math.cos(a) * 0.55, math.sin(a) * 0.55, 1.0)), (0.75, 0.75, 0.95), rot_matrix=Matrix.Rotation(a, 4, "Z") @ Matrix.Diagonal((0.65, 1.0, 1.0, 1)), subdiv=2)
    tube(p["Vine"], [(0, 0, 1.75), (0.05, 0, 2.2), (0.3, 0.1, 2.55)], [0.2, 0.15, 0.1], sides=6)
    rows = []
    for s in range(6):
        u = s / 5
        c = V((0.3 + u * 1.4, 0.2, 1.85 + 0.25 * math.sin(u * math.pi)))
        w = 0.55 * math.sin(math.pi * u) + 0.03
        rows.append((c + V((0, w, 0)), c, c - V((0, w, 0))))
    ribbon(p["Leaf"], rows, thick=0.05)


@shape("Reeds")
def n_reeds(p, rng):
    for k in range(5):
        a = k / 5 * math.tau + rng.uniform(-0.3, 0.3)
        r = 0.0 if k == 0 else rng.uniform(0.3, 0.7)
        base = V((math.cos(a) * r, math.sin(a) * r, 0))
        h = rng.uniform(3.2, 4.6)
        lean = V((rng.uniform(-0.3, 0.3), rng.uniform(-0.3, 0.3), 0))
        top = base + V((0, 0, h)) + lean
        tube(p["Leaf"], [base, base + V((0, 0, h * 0.5)) + lean * 0.3, top], [0.07, 0.06, 0.05], sides=5)
        if k < 4:
            tube(p["BarkDark"], [top - V((0, 0, 0.9)), top - V((0, 0, 0.45)), top], [0.17, 0.19, 0.15], sides=6)
            tube(p["Leaf"], [top, top + V((0, 0, 0.35))], [0.04, 0.02], sides=4)
    for k in range(4):
        a = rng.uniform(0, math.tau)
        d = V((math.cos(a), math.sin(a), 0))
        side = V((-d.y, d.x, 0))
        rows = []
        for s in range(6):
            u = s / 5
            c = d * (u * 1.4) + V((0, 0, u * 2.4 - u * u * 0.9))
            w = 0.16 * (1 - u) + 0.02
            rows.append((c + side * w, c, c - side * w))
        ribbon(p["LeafLight"], rows, thick=0.04)


@shape("Flowers")
def n_flowers(p, rng):
    for k, (x, y, h) in enumerate(((0, 0, 1.6), (0.8, 0.5, 1.2), (-0.6, 0.7, 1.0))):
        base = V((x, y, 0))
        top = base + V((rng.uniform(-0.1, 0.1), rng.uniform(-0.1, 0.1), h))
        tube(p["Leaf"], [base, top], [0.06, 0.05], sides=5)
        for j in range(5):
            a = j / 5 * math.tau + k
            R.ellipsoid(p["Body"], top + V((math.cos(a) * 0.32, math.sin(a) * 0.32, 0)), (0.3, 0.3, 0.09), rot_matrix=Matrix.Rotation(a, 4, "Z") @ Matrix.Diagonal((1.0, 0.65, 1.0, 1)), subdiv=1)
        R.ellipsoid(p["Pollen"], top + V((0, 0, 0.06)), (0.16, 0.16, 0.1), subdiv=1)
        c = base + V((0, 0, 0.35))
        rows = [(c + V((0, 0.02, 0)), c, c - V((0, 0.02, 0))), (c + V((0.35, 0.15, 0.15)), c + V((0.35, 0, 0.12)), c + V((0.35, -0.15, 0.15))), (c + V((0.7, 0.01, 0.35)), c + V((0.7, 0, 0.35)), c + V((0.7, -0.01, 0.35)))]
        ribbon(p["LeafLight"], rows, thick=0.03)


# Sample colour per model (for the passed-in colour roles) for previews.
SAMPLES = {
    "PalmTree": R.srgb(255, 255, 255),
    "PalmTreeBent": R.srgb(255, 255, 255),
    "RoundTree": R.srgb(255, 255, 255),
    "RoundTreeTall": R.srgb(255, 255, 255),
    "VoxelTree": R.srgb(255, 255, 255),
    "VoxelTreeTall": R.srgb(255, 255, 255),
    "Bush": R.srgb(255, 255, 255),
    "AutumnTree": R.srgb(240, 140, 40),
    "AutumnTreeTall": R.srgb(225, 80, 45),
    "SnowPine": R.srgb(255, 255, 255),
    "SnowPineTall": R.srgb(255, 255, 255),
    "Cactus": R.srgb(255, 255, 255),
    "CactusTall": R.srgb(255, 255, 255),
    "Mushroom": R.srgb(220, 60, 60),
    "MushroomPair": R.srgb(170, 90, 220),
    "Boulder": R.srgb(255, 255, 255),
    "BoulderPair": R.srgb(255, 255, 255),
    "IceSpikes": R.srgb(255, 255, 255),
    "CrystalCluster": R.srgb(170, 120, 255),
    "Lollipop": R.srgb(255, 90, 160),
    "Gumdrops": R.srgb(255, 255, 255),
    "Pumpkin": R.srgb(255, 255, 255),
    "Reeds": R.srgb(255, 255, 255),
    "Flowers": R.srgb(255, 90, 120),
}


def lineup(collection, per_row=8, spacing=13.0):
    empties = []
    names = list(SAMPLES)
    rows = math.ceil(len(names) / per_row)
    for i, name in enumerate(names):
        empty = R.build(name, SAMPLES[name], collection)
        size = max(max(c.dimensions) for c in empty.children if c.type == "MESH")
        k = min(1.0, 8.0 / size)
        empty.scale = (k, k, k)
        lo = min((empty.matrix_world @ c.matrix_local @ V(b)).z for c in empty.children if c.type == "MESH" for b in c.bound_box)
        col, row = i % per_row, i // per_row
        empty.location = ((col - (per_row - 1) / 2) * spacing, (row - (rows - 1) / 2) * spacing, -lo)
        empties.append(empty)
    return empties


def stage(scene, path=None):
    R.stage(scene, None)
    scene.camera.location = (0, -78, 52)
    scene.camera.data.lens = 26
    scene.camera.rotation_euler = (math.radians(58), 0, 0)
    for obj in scene.objects:
        if obj.name == "Ground":
            obj.scale = (2.2, 2.2, 1)
    if path:
        try:
            scene.render.engine = "BLENDER_EEVEE_NEXT"
        except TypeError:
            scene.render.engine = "BLENDER_EEVEE"
        scene.render.filepath = os.path.abspath(path)
        bpy.ops.render.render(write_still=True)
        print(f"Rendered {path}")


def showcase():
    old = bpy.data.scenes.get("Nature")
    if old:
        for obj in list(old.objects):
            bpy.data.objects.remove(obj)
        bpy.data.scenes.remove(old)
    scene = bpy.data.scenes.new("Nature")
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
    R.export(f"{out}/Nature.fbx")
    if "--preview" in args:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        scene = bpy.context.scene
        lineup(scene.collection)
        stage(scene, args[args.index("--preview") + 1])


if __name__ == "__main__":
    main()
