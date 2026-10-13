"""Builds the rock models for +1 Lift Rock For Pets.

Headless (exports everything + an optional preview render):
    blender -b -P tools/blender/build_rocks.py -- assets/models/Rocks [--preview <png>]
Live Blender (e.g. through the Blender MCP): exec this file with a
`__name__` other than "__main__" and call `showcase()`; it builds every shape
in its own "Rocks" scene and leaves the user's other scenes alone.

Output:
    assets/models/Rocks/Rocks.fbx           every shape, each under an empty
                                            named after its template (import
                                            once in Studio)
    assets/models/Rocks/Shapes/<Shape>.fbx  the same shapes one per file

Mesh names are "<Shape>_<Role>". The role is the contract with
src/shared/Util/Models/Assets.luau, which colours each part from the rock's
colour (see ROLE_TINTS below; FIXED roles keep one colour on every rock):
    Root      tiny hidden cube at the centre: the pivot everything welds to
    Body      the rock's colour          Shade    darker
    Crust     much darker (lava plates)  Crystal  lighter + shiny
    Glow      lighter, Neon              Spots    much lighter
    Band      lighter stripes            Cap      the rock's colour (mushrooms)
    Jelly     the rock's colour, see-through
    Moss      the rock's colour (moss on a grey Stone)
    Ore       the rock's colour, metallic (ore veins/nuggets in a grey Stone)
    Gem       the rock's colour, glassy (gem crystals)
    Stone / Stem / Frosting / Sprinkles / Cherry / Stick / Shine / Gold: FIXED
Which rock uses which shape (and which wear the Crown) is
src/shared/Config/RockLooks.luau. Every shape is about 2 units across and
centred on its Root; the game rescales it to the rock's size.
"""

import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector
from mathutils import noise as mnoise
from mathutils.bvhtree import BVHTree


def srgb(r, g, b):
    # Roblox colours are sRGB 0-255; Blender materials are linear.
    def lin(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    return (lin(r), lin(g), lin(b))


def mix(a, b, t):
    return tuple(x + (y - x) * t for x, y in zip(a, b))


WHITE, BLACK = (1, 1, 1), (0, 0, 0)

# role -> (colour from the rock colour, roughness, emission). Mirrors Assets.luau.
ROLE_TINTS = {
    "Body": (lambda c: c, 0.8),
    "Shade": (lambda c: mix(c, BLACK, 0.35), 0.85),
    "Crust": (lambda c: mix(c, BLACK, 0.78), 0.9),
    "Crystal": (lambda c: mix(c, WHITE, 0.3), 0.08),
    # Dark rocks' glow lightens more, or it would stay dark (as in Assets.luau).
    "Glow": (lambda c: mix(c, WHITE, 0.55 if 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2] < 0.07 else 0.15), 0.5),
    "Spots": (lambda c: mix(c, WHITE, 0.55), 0.8),
    "Band": (lambda c: mix(c, WHITE, 0.45), 0.6),
    "Cap": (lambda c: c, 0.6),
    "Jelly": (lambda c: c, 0.15),
    "Moss": (lambda c: c, 0.95),
    "Ore": (lambda c: c, 0.35),
    "Gem": (lambda c: c, 0.05),
}
FIXED = {
    "Root": srgb(128, 128, 128),
    "Stone": srgb(125, 120, 115),
    "Stem": srgb(240, 230, 210),
    "Frosting": srgb(255, 235, 245),
    "Sprinkles": srgb(255, 90, 170),
    "Cherry": srgb(220, 20, 50),
    "Stick": srgb(200, 160, 110),
    "Shine": srgb(255, 255, 255),
    "Gold": srgb(255, 195, 45),
}

# Fixed roles that aren't plain matte (props add Steel, Iron, Rubber...).
ROUGH = {"Gold": 0.2, "Steel": 0.25, "Iron": 0.45, "Rubber": 0.9, "Wood": 0.7}
METAL = {"Gold": 1.0, "Steel": 1.0, "Iron": 0.6}


def material(role, rgb):
    name = f"Rock{role}" if role in FIXED else f"Rock{role}_{'%.3f%.3f%.3f' % rgb}"
    mat = bpy.data.materials.get(name)
    if mat:
        return mat
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    if role in FIXED:
        tint, rough = FIXED[role], ROUGH.get(role, 0.6)
        metal = METAL.get(role, 0.0)
    else:
        fn, rough = ROLE_TINTS[role]
        tint, metal = fn(rgb), 0.0
    mat.diffuse_color = (*tint, 1)
    bsdf.inputs["Base Color"].default_value = (*tint, 1)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if role == "Glow":
        bsdf.inputs["Emission Color"].default_value = (*tint, 1)
        bsdf.inputs["Emission Strength"].default_value = 0.6
    if role == "Jelly":
        bsdf.inputs["Transmission Weight"].default_value = 0.5
    if role == "Ore":
        bsdf.inputs["Metallic"].default_value = 0.7
    if role == "Gem":
        bsdf.inputs["Transmission Weight"].default_value = 0.6
        bsdf.inputs["Coat Weight"].default_value = 1.0
    return mat


# --- maths helpers ---


def rand_dir(rng, up=0.0):
    """Random unit vector; `up` > 0 biases it upward."""
    while True:
        v = Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-1, 1)))
        if 0.05 < v.length <= 1:
            v.normalize()
            v.z += up
            return v.normalized()


def fbm(p, octaves=4):
    total, amp, freq = 0.0, 1.0, 1.0
    for _ in range(octaves):
        total += amp * mnoise.noise(p * freq)
        amp *= 0.5
        freq *= 2.0
    return total / 1.875


def place(at=(0, 0, 0), rot=(0, 0, 0), scale=(1, 1, 1)):
    return (
        Matrix.Translation(at)
        @ Matrix.Rotation(rot[2], 4, "Z")
        @ Matrix.Rotation(rot[1], 4, "Y")
        @ Matrix.Rotation(rot[0], 4, "X")
        @ Matrix.Diagonal((*scale, 1))
    )


def aim(direction, spin=0.0):
    """Rotation matrix taking +Z to `direction`, turned `spin` about it."""
    q = Vector((0, 0, 1)).rotation_difference(Vector(direction).normalized())
    return q.to_matrix().to_4x4() @ Matrix.Rotation(spin, 4, "Z")


def merge(dst, src):
    """Append bmesh `src` into bmesh `dst`."""
    me = bpy.data.meshes.new("_merge")
    src.to_mesh(me)
    dst.from_mesh(me)
    bpy.data.meshes.remove(me)


# --- building blocks ---


def rock(bm, rng, subdiv=5, rough=0.13, freq=1.4, cuts=8, cut=0.15, craters=0, crater_size=0.35, at=(0, 0, 0), rot=(0, 0, 0), scale=(1, 1, 1)):
    """A rock into `bm`: a noisy sphere with `cuts` flat chiselled faces and
    `craters` bowl craters. Returns its verts (after placing)."""
    verts = bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=1.0)["verts"]
    off = Vector((rng.uniform(-90, 90), rng.uniform(-90, 90), rng.uniform(-90, 90)))
    for v in verts:
        n = v.co.normalized()
        v.co = n * (1 + rough * fbm(n * freq + off))
    for _ in range(craters):
        d = rand_dir(rng)
        size = crater_size * rng.uniform(0.6, 1.2)
        depth = 0.1 * size / crater_size
        for v in verts:
            t = v.co.normalized().angle(d) / size
            if t < 1:
                v.co *= 1 - depth * (1 - t * t)
            elif t < 1.45:
                v.co *= 1 + depth * 0.35 * math.sin((t - 1) / 0.45 * math.pi)
    for _ in range(cuts):
        n = rand_dir(rng)
        top = max(v.co.dot(n) for v in verts)
        d = top - cut * rng.uniform(0.5, 1.3)
        for v in verts:
            h = v.co.dot(n)
            if h > d:
                v.co -= n * (h - d)
    bmesh.ops.transform(bm, matrix=place(at, rot, scale), verts=verts)
    return verts


def blobs(bm, balls, resolution=0.07, rough=0.0, rng=None):
    """Metaball blob (smooth melted balls) into `bm`. balls: [(at, radius, (sx,sy,sz))]."""
    mb = bpy.data.metaballs.new("_blob")
    mb.resolution = mb.render_resolution = resolution
    for at, r, s in balls:
        el = mb.elements.new(type="ELLIPSOID")
        el.co = at
        el.radius = r
        el.size_x, el.size_y, el.size_z = s
    # Metaballs sharing a base name fuse; give each blob its own.
    obj = bpy.data.objects.new(f"_blob{random.random():.9f}".replace(".", ""), mb)
    bpy.context.scene.collection.objects.link(obj)
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(obj.evaluated_get(dg))
    bpy.data.objects.remove(obj)
    bpy.data.metaballs.remove(mb)
    tmp = bmesh.new()
    tmp.from_mesh(me)
    bpy.data.meshes.remove(me)
    if rough and rng:
        off = Vector((rng.uniform(-90, 90), 0, rng.uniform(-90, 90)))
        bmesh.ops.recalc_face_normals(tmp, faces=tmp.faces)
        tmp.normal_update()
        for v in tmp.verts:
            v.co += v.normal * rough * fbm(v.co * 2.2 + off, 3)
    merge(bm, tmp)
    tmp.free()


def crystal(bm, radius, height, at, direction, spin=0.0, sides=6, chamfer=0.07):
    """A faceted crystal (prism + point), base at `at`, growing along `direction`."""
    tmp = bmesh.new()
    bmesh.ops.create_cone(tmp, cap_ends=True, segments=sides, radius1=radius, radius2=radius * 0.9, depth=height, matrix=Matrix.Translation((0, 0, height / 2)))
    bmesh.ops.create_cone(tmp, cap_ends=False, segments=sides, radius1=radius * 0.9, radius2=0, depth=radius * 1.5, matrix=Matrix.Translation((0, 0, height + radius * 0.75)))
    bmesh.ops.remove_doubles(tmp, verts=tmp.verts, dist=1e-4)
    # Drop the cap between prism and point so it's one closed solid.
    inner = [f for f in tmp.faces if abs(f.calc_center_median().z - height) < 1e-3 and len(f.verts) == sides]
    bmesh.ops.delete(tmp, geom=inner, context="FACES_ONLY")
    bmesh.ops.remove_doubles(tmp, verts=tmp.verts, dist=1e-4)
    if chamfer:
        bmesh.ops.bevel(tmp, geom=list(tmp.edges), offset=radius * chamfer, offset_type="OFFSET", segments=1, profile=0.5, affect="EDGES", clamp_overlap=True)
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ aim(direction, spin), verts=tmp.verts)
    merge(bm, tmp)
    tmp.free()


def ellipsoid(bm, at, scale, rot_matrix=None, subdiv=3):
    tmp = bmesh.new()
    bmesh.ops.create_icosphere(tmp, subdivisions=subdiv, radius=1.0)
    m = Matrix.Translation(at) @ (rot_matrix or Matrix()) @ Matrix.Diagonal((*scale, 1))
    bmesh.ops.transform(tmp, matrix=m, verts=tmp.verts)
    merge(bm, tmp)
    tmp.free()


def cylinder(bm, r1, r2, depth, at, direction=(0, 0, 1), segments=16, caps=True):
    tmp = bmesh.new()
    bmesh.ops.create_cone(tmp, cap_ends=caps, segments=segments, radius1=r1, radius2=r2, depth=depth, matrix=Matrix.Translation((0, 0, depth / 2)))
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ aim(direction), verts=tmp.verts)
    merge(bm, tmp)
    tmp.free()


def torus(bm, major, minor, at=(0, 0, 0), direction=(0, 0, 1), seg=48, ring=12, squash=1.0):
    tmp = bmesh.new()
    grid = []
    for i in range(seg):
        a = i / seg * math.tau
        row = []
        for j in range(ring):
            b = j / ring * math.tau
            r = major + minor * math.cos(b)
            row.append(tmp.verts.new((r * math.cos(a), r * math.sin(a), minor * math.sin(b) * squash)))
        grid.append(row)
    for i in range(seg):
        for j in range(ring):
            tmp.faces.new((grid[i][j], grid[(i + 1) % seg][j], grid[(i + 1) % seg][(j + 1) % ring], grid[i][(j + 1) % ring]))
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ aim(direction), verts=tmp.verts)
    merge(bm, tmp)
    tmp.free()


def hull(bm, points):
    tmp = bmesh.new()
    verts = [tmp.verts.new(p) for p in points]
    out = bmesh.ops.convex_hull(tmp, input=verts)
    bmesh.ops.delete(tmp, geom=out["geom_interior"] + out["geom_unused"], context="VERTS")
    merge(bm, tmp)
    tmp.free()


def smoothstep(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)


def coat(dst, src, field, lift=0.03, sink=0.03):
    """A copy of `src`'s surface lifted `lift` above it where field(co, normal)
    is 1 and tucked `sink` under it (hidden) where it is 0. A smooth field
    gives clean curved edges: moss, frosting, ooze, inlays, lava plates."""
    tmp = src.copy()
    tmp.normal_update()
    moves = [(v, v.normal.copy(), max(0.0, min(1.0, field(v.co, v.normal)))) for v in tmp.verts]
    for v, n, f in moves:
        v.co += n * (f * (lift + sink) - sink)
    merge(dst, tmp)
    tmp.free()


def band(n, offset, width, soft=0.35):
    """Field for a stripe around the rock: 1 within `width` of the plane."""
    n = Vector(n).normalized()
    return lambda co, _nrm: smoothstep(width, width * soft, abs(co.dot(n) - offset))


class Surface:
    """Ray-casts onto a finished bmesh to stick decorations on it."""

    def __init__(self, bm):
        self.tree = BVHTree.FromBMesh(bm)

    def hit(self, direction, centre=(0, 0, 0)):
        d = Vector(direction).normalized()
        origin = Vector(centre) + d * 5
        loc, normal, _, _ = self.tree.ray_cast(origin, -d)
        return (loc, normal) if loc else (Vector(centre) + d, d)


# --- shapes: fn(parts, rng); parts[role] is that role's bmesh ---

SHAPES = {}
SMOOTH = {}  # shape -> roles shaded fully smooth (others get hard edges)


def shape(name, smooth=()):
    def register(fn):
        SHAPES[name] = fn
        SMOOTH[name] = set(smooth)
        return fn

    return register


@shape("Rock")
def s_rock(p, rng):
    """Chiselled rock: deep flat facets, darker underside."""
    rock(p["Body"], rng, rough=0.08, cuts=16, cut=0.28, scale=(1.1, 0.95, 0.85))
    rock(p["Shade"], rng, subdiv=4, rough=0.08, cuts=8, cut=0.2, at=(-0.1, 0.15, -0.36), scale=(0.95, 0.85, 0.5))


@shape("RockPebble", smooth=("Body", "Band", "Spots"))
def s_pebble(p, rng):
    """A real beach pebble: lopsided and water-worn (soft facets rounded
    off, one end fatter, a flatter belly), speckled, with a pale quartz vein."""
    body = p["Body"]
    verts = rock(body, rng, subdiv=5, rough=0.05, freq=0.9, cuts=7, cut=0.16)
    # Wear the chiselled facets smooth.
    for _ in range(14):
        bmesh.ops.smooth_vert(body, verts=verts, factor=0.6, use_axis_x=True, use_axis_y=True, use_axis_z=True)
    for v in verts:
        x, y, z = v.co
        # Egg taper along X, flat belly, slight twist.
        taper = 1.0 + 0.22 * x
        bend = 0.12 * (1 - y * y)
        v.co = Vector((x * 1.3, y * 0.92 * taper + 0.1 * x * x, (z * 0.66 if z > 0 else z * 0.4) * taper + bend * x))
    coat(p["Band"], body, band((0.55, 0.25, 1), 0.04, 0.075, soft=0.6), lift=0.006, sink=0.02)
    # Speckles: little flat flecks pressed into the surface.
    surf = Surface(body)
    for _ in range(34):
        loc, n = surf.hit(rand_dir(rng, up=0.4))
        s = rng.uniform(0.025, 0.055)
        ellipsoid(p["Spots"], loc - n * 0.004, (s, s * rng.uniform(0.6, 1), 0.012), aim(n, rng.uniform(0, 3)), subdiv=2)


@shape("RockRiver", smooth=("Body", "Band"))
def s_river(p, rng):
    """Polished river stone with pale mineral bands."""
    body = p["Body"]
    rock(body, rng, rough=0.04, freq=0.9, cuts=0, scale=(1.3, 1.0, 0.62))
    coat(p["Band"], body, band((0.35, 0.1, 1), 0.12, 0.07), lift=0.006, sink=0.02)
    coat(p["Band"], body, band((-0.2, 0.3, 1), -0.2, 0.04), lift=0.006, sink=0.02)


@shape("RockMossy", smooth=("Moss",))
def s_mossy(p, rng):
    """Grey stone with a thick patchy moss cap and tufts."""
    stone = p["Stone"]
    rock(stone, rng, cuts=7, scale=(1.1, 1.0, 0.85))
    off = Vector((rng.uniform(-50, 50), 7, 3))
    coat(p["Moss"], stone, lambda co, n: smoothstep(0.22, 0.32, n.z + 0.45 * fbm(co * 2.5 + off, 3)), lift=0.05, sink=0.03)
    surf = Surface(stone)
    for _ in range(16):
        loc, n = surf.hit(rand_dir(rng, up=1.6))
        if n.z > 0.45:
            ellipsoid(p["Moss"], loc + n * 0.05, (0.12, 0.12, 0.08), aim(n), subdiv=2)


@shape("RockBoulder")
def s_boulder(p, rng):
    """Huge craggy boulder with darker slabs pushed out of it."""
    body = p["Body"]
    rock(body, rng, rough=0.18, freq=1.1, cuts=18, cut=0.24, scale=(1.15, 1.0, 0.95))
    surf = Surface(body)
    for _ in range(6):
        loc, n = surf.hit(rand_dir(rng, up=0.2))
        s = rng.uniform(0.35, 0.5)
        rock(p["Shade"], rng, subdiv=4, rough=0.1, cuts=7, cut=0.25, at=tuple(loc - n * s * 0.55), scale=(s, s * 0.85, s * 0.6), rot=(rng.uniform(0, 3), rng.uniform(0, 3), rng.uniform(0, 3)))


@shape("RockNugget", smooth=("Body",))
def s_nugget(p, rng):
    """Bubbly melted nugget."""
    balls = [((0, 0, 0), 1.15, (1.1, 1, 0.75))]
    for _ in range(22):
        d = rand_dir(rng)
        balls.append((tuple(d * Vector((0.72, 0.64, 0.45))), rng.uniform(0.3, 0.48), (1, 1, 1)))
    blobs(p["Body"], balls, resolution=0.06, rough=0.035, rng=rng)


@shape("RockLava", smooth=("Glow",))
def s_lava(p, rng):
    """Lava rock: dark crust plates over glowing magma showing through the seams."""
    glow = p["Glow"]
    rock(glow, rng, subdiv=5, rough=0.1, cuts=6, scale=(1.1, 1.0, 0.92))
    seeds = [rand_dir(rng) for _ in range(14)]
    off = Vector((rng.uniform(-50, 50), 4, 9))

    def plates(co, _n):
        d = co.normalized()
        dots = sorted((d.dot(sd) for sd in seeds), reverse=True)
        gap = 0.022 + 0.008 * mnoise.noise(co * 3 + off)
        return smoothstep(gap, gap * 1.6, dots[0] - dots[1])

    coat(p["Crust"], glow, plates, lift=0.06, sink=0.03)


@shape("RockMeteor")
def s_meteor(p, rng):
    """Cratered space rock studded with glowing crystal shards."""
    body = p["Body"]
    rock(body, rng, rough=0.1, cuts=3, craters=6, scale=(1.05, 1.0, 0.95))
    surf = Surface(body)
    for _ in range(9):
        loc, n = surf.hit(rand_dir(rng))
        r = rng.uniform(0.09, 0.15)
        crystal(p["Glow"], r, r * rng.uniform(1.5, 2.6), loc - n * 0.06, n, spin=rng.uniform(0, 1))


@shape("RockMoon", smooth=("Body",))
def s_moon(p, rng):
    """Round, pale moon rock covered in craters."""
    body = p["Body"]
    rock(body, rng, rough=0.05, cuts=0, craters=11, crater_size=0.32, scale=(1.0, 1.0, 0.95))


@shape("RockCandy", smooth=("Stick",))
def s_candy(p, rng):
    """Rock candy: a spindle of sugar cubes on a wooden stick."""
    cylinder(p["Stick"], 0.07, 0.07, 1.9, (0, 0, -0.95), segments=16)
    for _ in range(150):
        z = rng.uniform(-0.6, 0.95)
        spread = 0.55 * math.sqrt(max(0.0, 1 - ((z - 0.18) / 0.82) ** 2)) * rng.uniform(0.55, 1.0) + 0.08
        a = rng.uniform(0, math.tau)
        at = Vector((math.cos(a) * spread, math.sin(a) * spread, z))
        s = rng.uniform(0.14, 0.26)
        tmp = bmesh.new()
        bmesh.ops.create_cube(tmp, size=s)
        bmesh.ops.bevel(tmp, geom=list(tmp.edges), offset=s * 0.08, offset_type="OFFSET", segments=1, affect="EDGES")
        bmesh.ops.transform(tmp, matrix=place(tuple(at), (rng.uniform(0, 3), rng.uniform(0, 3), rng.uniform(0, 3))), verts=tmp.verts)
        merge(p["Crystal"], tmp)
        tmp.free()


@shape("RockGummy", smooth=("Jelly", "Shine"))
def s_gummy(p, rng):
    """A chunky see-through gummy bear, sitting. (A metaball's surface sits
    at about 0.6 of its radius, hence the big radii.)"""
    jelly = p["Jelly"]
    blobs(
        jelly,
        [
            ((0, 0, -0.3), 1.1, (1.0, 0.85, 1.05)),  # belly
            ((0, 0, 0.55), 0.88, (1.05, 0.9, 0.9)),  # head
            ((0.36, 0.0, 1.0), 0.32, (1, 0.7, 1)),  # ears
            ((-0.36, 0.0, 1.0), 0.32, (1, 0.7, 1)),
            ((0, -0.42, 0.45), 0.34, (1, 1, 0.8)),  # snout
            ((0.58, -0.15, -0.1), 0.38, (1, 1, 1.5)),  # arms
            ((-0.58, -0.15, -0.1), 0.38, (1, 1, 1.5)),
            ((0.35, -0.4, -0.75), 0.44, (1, 1.5, 0.8)),  # legs
            ((-0.35, -0.4, -0.75), 0.44, (1, 1.5, 0.8)),
        ],
        resolution=0.045,
    )
    surf = Surface(jelly)
    for d, size in (((-0.45, -0.6, 0.9), (0.09, 0.05, 0.02)), ((-0.35, -1, -0.15), (0.05, 0.12, 0.02))):
        loc, n = surf.hit(d, centre=(0, 0, 0.1))
        ellipsoid(p["Shine"], loc, size, aim(n, 0.6))


@shape("RockFrosted", smooth=("Frosting", "Cherry", "Body"))
def s_frosted(p, rng):
    """Cupcake rock: a cake-coloured rock under frosting, sprinkles and a cherry."""
    body = p["Body"]
    rock(body, rng, rough=0.06, cuts=2, scale=(1.1, 1.1, 0.72))
    off = Vector((3, rng.uniform(-50, 50), 1))

    # Wavy edge for drips: frosting reaches lower where the noise says so.
    def frosting(co, n):
        wave = 0.35 * mnoise.noise(Vector((math.atan2(co.y, co.x) * 1.6, 0, 0)) + off)
        return smoothstep(0.08, 0.16, co.z / 0.72 + 0.1 + wave)

    coat(p["Frosting"], body, frosting, lift=0.09, sink=0.03)
    top = Surface(body).hit((0, 0, 1))[0]
    blobs(p["Frosting"], [((top.x, top.y, top.z + 0.12), 0.5, (1, 1, 0.45)), ((top.x, top.y, top.z + 0.32), 0.35, (1, 1, 0.5)), ((top.x, top.y, top.z + 0.5), 0.2, (1, 1, 0.6))], resolution=0.05)
    ellipsoid(p["Cherry"], (top.x, top.y, top.z + 0.72), (0.16, 0.16, 0.15))
    cylinder(p["Stick"], 0.015, 0.012, 0.25, (top.x, top.y, top.z + 0.84), direction=(0.3, 0, 1), segments=8)
    surf = Surface(p["Frosting"])
    for _ in range(40):
        loc, n = surf.hit(rand_dir(rng, up=1.4))
        if n.z < 0.25:
            continue
        cylinder(p["Sprinkles"], 0.022, 0.022, 0.12, loc - n * 0.005, direction=n.cross(rand_dir(rng)), segments=6)


@shape("RockMushroom", smooth=("Cap", "Stem", "Spots"))
def s_mushroom(p, rng):
    """Mossy-grey stone sprouting spotted mushrooms."""
    stone = p["Stone"]
    rock(stone, rng, cuts=7, scale=(1.1, 1.0, 0.75))
    surf = Surface(stone)
    for k, (d, size) in enumerate([((0.2, 0.1, 1), 0.55), ((-0.75, 0.3, 0.8), 0.38), ((0.7, -0.5, 0.7), 0.3), ((-0.1, -0.8, 0.6), 0.22)]):
        loc, n = surf.hit(d)
        up = (n + Vector((0, 0, 1.5))).normalized()
        stem_h = size * 1.1
        cylinder(p["Stem"], size * 0.28, size * 0.22, stem_h, loc - n * 0.05, direction=up, segments=16)
        cap_at = loc + up * (stem_h - 0.02)
        cap = bmesh.new()
        bmesh.ops.create_uvsphere(cap, u_segments=24, v_segments=12, radius=1.0)
        bmesh.ops.delete(cap, geom=[v for v in cap.verts if v.co.z < -0.05], context="VERTS")
        bmesh.ops.transform(cap, matrix=Matrix.Translation(cap_at) @ aim(up) @ Matrix.Diagonal((size, size, size * 0.6, 1)), verts=cap.verts)
        merge(p["Cap"], cap)
        cap.free()
        for _ in range(6):
            a, h = rng.uniform(0, math.tau), rng.uniform(0.25, 0.85)
            local = Vector((math.cos(a) * math.sqrt(1 - h * h), math.sin(a) * math.sqrt(1 - h * h), h))
            world = cap_at + (aim(up) @ Matrix.Diagonal((size, size, size * 0.6, 1)) @ local)
            n2 = (aim(up).to_3x3() @ Vector((local.x, local.y, local.z / 0.6))).normalized()
            ellipsoid(p["Spots"], world, (size * 0.13, size * 0.13, size * 0.03), aim(n2), subdiv=2)


@shape("RockToxic", smooth=("Glow",))
def s_toxic(p, rng):
    """Dark rock oozing glowing goo that drips down its sides."""
    body = p["Shade"]
    rock(body, rng, cuts=8, scale=(1.1, 1.0, 0.85))
    off = Vector((rng.uniform(-50, 50), 1, 2))
    coat(p["Glow"], body, lambda co, n: smoothstep(0.45, 0.55, n.z + 0.4 * fbm(co * 2 + off, 3)), lift=0.05, sink=0.03)
    surf = Surface(body)
    for k in range(8):
        a = k / 8 * math.tau + rng.uniform(-0.25, 0.25)
        loc, n = surf.hit((math.cos(a), math.sin(a), 0.35))
        length = rng.uniform(0.25, 0.5)
        top = loc + Vector((0, 0, 0.12))
        drip = [((top.x, top.y, top.z - length * t / 4), 0.17 - 0.03 * t, (1, 1, 1.2)) for t in range(4)]
        drip.append(((loc.x + n.x * 0.04, loc.y + n.y * 0.04, loc.z - length - 0.05), 0.2, (1, 1, 1.15)))
        blobs(p["Glow"], drip, resolution=0.03)


@shape("RockRune")
def s_rune(p, rng):
    """Dark chiselled stone carved with glowing rune lines."""
    body = p["Body"]
    rock(body, rng, rough=0.08, cuts=12, cut=0.12, scale=(1.05, 1.0, 1.0))
    fields = [band((0.1, 0.0, 1), 0.15, 0.05, soft=0.6)]
    for _ in range(7):
        n, sector, o = rand_dir(rng), rand_dir(rng), rng.uniform(-0.25, 0.25)
        line = band(n, o, 0.045, soft=0.6)
        fields.append(lambda co, nrm, line=line, sector=sector: line(co, nrm) * smoothstep(0.35, 0.45, co.normalized().dot(sector)))
    coat(p["Glow"], body, lambda co, n: max(f(co, n) for f in fields), lift=0.025, sink=0.03)


@shape("RockRoyal", smooth=("Body", "Gold"))
def s_royal(p, rng):
    """Polished royal stone, egg-round, inlaid with gold bands and studs."""
    body = p["Body"]
    rock(body, rng, rough=0.02, freq=0.8, cuts=0, scale=(1.0, 0.9, 1.05))
    bands = [band((0, 0, 1), 0.0, 0.09, soft=0.55), band((1, 0, 0.15), 0.0, 0.065, soft=0.55), band((0, 1, 0.15), 0.0, 0.065, soft=0.55)]
    coat(p["Gold"], body, lambda co, n: max(f(co, n) for f in bands), lift=0.04, sink=0.02)
    surf = Surface(body)
    for k in range(8):
        a = k / 8 * math.tau + math.tau / 16
        for z in (0.45, -0.45):
            loc, n = surf.hit((math.cos(a), math.sin(a), z))
            ellipsoid(p["Gold"], loc, (0.07, 0.07, 0.04), aim(n), subdiv=2)


@shape("RockComet", smooth=("Glow",))
def s_comet(p, rng):
    """Icy rock streaking a long glowing tail behind it."""
    body = p["Body"]
    rock(body, rng, rough=0.12, cuts=6, craters=3, scale=(0.9, 0.85, 0.8))
    rock(p["Spots"], rng, subdiv=4, rough=0.05, cuts=3, at=(0.15, 0, 0.35), scale=(0.6, 0.6, 0.35))
    # Tail: streaks of overlapping stretched blobs, thinning as they trail off.
    for k in range(6):
        a = k / 6 * math.tau + rng.uniform(-0.3, 0.3)
        side = Vector((0, math.cos(a), math.sin(a))) * (0.3 if k else 0.0)
        length = rng.uniform(1.0, 1.4) if k else 1.9
        width = rng.uniform(0.42, 0.5) if k else 0.7
        balls = []
        for t in range(14):
            f = t / 13
            at = Vector((-0.4 - f * length, 0, 0)) + side * (1 + f * 0.8)
            balls.append((tuple(at), width * (1 - f * 0.7), (1.3, 1, 1)))
        blobs(p["Glow"], balls, resolution=0.06)


@shape("RockGalaxy", smooth=("Body", "Glow"))
def s_galaxy(p, rng):
    """Deep-space orb wrapped in a glowing ring and stars."""
    rock(p["Body"], rng, rough=0.04, cuts=0, scale=(1.0, 1.0, 1.0))
    torus(p["Glow"], 1.35, 0.06, direction=(0.35, -0.3, 1), squash=0.6)
    torus(p["Glow"], 1.6, 0.03, direction=(0.35, -0.3, 1), squash=0.6)
    for _ in range(12):
        d = rand_dir(rng)
        at = d * rng.uniform(1.0, 1.06)
        s = rng.uniform(0.07, 0.13)
        star = bmesh.new()
        for axis in ((1, 0, 0), (0, 1, 0), (0, 0, 1)):
            pts = [Vector(axis) * s * 1.8, -Vector(axis) * s * 1.8]
            other = [Vector(a) * s * 0.35 for a in ((1, 0, 0), (0, 1, 0), (0, 0, 1)) if a != axis]
            pts += other + [-o for o in other]
            hull(star, pts)
        bmesh.ops.transform(star, matrix=Matrix.Translation(at) @ aim(d, rng.uniform(0, 1)), verts=star.verts)
        merge(p["Spots"], star)
        star.free()


@shape("RockPhoenix", smooth=("Glow",))
def s_phoenix(p, rng):
    """Ember-orange rock with a fan of flame feathers rising off its back."""
    body = p["Body"]
    rock(body, rng, cuts=8, scale=(1.05, 0.95, 0.85))
    for k in range(9):
        t = (k - 4) / 4
        a = t * 1.1
        d = Vector((math.sin(a), 0.45, math.cos(a))).normalized()
        length = 0.95 - abs(t) * 0.35
        at = Vector((t * 0.25, 0.35, 0.3)) + d * length * 0.55
        ellipsoid(p["Glow"], at, (0.09, 0.03, length * 0.55), aim(d), subdiv=3)
    surf = Surface(body)
    for _ in range(8):
        loc, n = surf.hit(rand_dir(rng))
        crystal(p["Glow"], 0.05, 0.08, loc - n * 0.04, n, chamfer=0)


# --- ores (the Stone Valley ladder: Coal .. Diamond) ---


def ore_stone(p, rng, scale=(1.1, 1.0, 0.85)):
    stone = p["Stone"]
    rock(stone, rng, rough=0.09, cuts=12, cut=0.2, scale=scale)
    return stone


def nuggets(p, surf, rng, count, size):
    for _ in range(count):
        loc, n = surf.hit(rand_dir(rng, up=0.3))
        s = size * rng.uniform(0.7, 1.3)
        rock(p["Ore"], rng, subdiv=3, rough=0.15, cuts=4, cut=0.25, at=tuple(loc + n * s * 0.1), scale=(s, s * 0.9, s * 0.7), rot=(rng.uniform(0, 3), rng.uniform(0, 3), rng.uniform(0, 3)))


def gems(p, surf, rng, pockets, per, length):
    """Gem crystals in clusters ("pockets") growing out of the stone."""
    for _ in range(pockets):
        loc, n = surf.hit(rand_dir(rng, up=0.8))
        for k in range(per):
            d = (n + rand_dir(rng) * 0.45).normalized()
            r = length * rng.uniform(0.18, 0.26) * (1.25 if k == 0 else 1)
            h = length * rng.uniform(0.55, 1.0) * (1.3 if k == 0 else 1)
            crystal(p["Gem"], r, h, loc - n * 0.08 + rand_dir(rng) * 0.06, d, spin=rng.uniform(0, 1), chamfer=0.05)


@shape("RockOre", smooth=("Ore",))
def s_ore(p, rng):
    """Grey stone flecked with ore: blotchy patches + small nuggets (Coal, Copper, Iron)."""
    stone = ore_stone(p, rng)
    off = Vector((rng.uniform(-50, 50), 9, 1))
    coat(p["Ore"], stone, lambda co, n: smoothstep(0.32, 0.42, mnoise.noise(co * 3.2 + off)), lift=0.035, sink=0.03)
    nuggets(p, Surface(stone), rng, 9, 0.13)


@shape("RockOreRich", smooth=("Ore",))
def s_ore_rich(p, rng):
    """Stone cracked open by thick shining veins with fat nuggets (Silver, Gold)."""
    stone = ore_stone(p, rng, scale=(1.15, 1.0, 0.9))
    off = Vector((rng.uniform(-50, 50), 3, 8))

    def veins(co, _n):
        # Ridged noise: thin wandering lines where the noise crosses zero.
        return max(smoothstep(0.1, 0.03, abs(mnoise.noise(co * 1.6 + off))), smoothstep(0.3, 0.4, mnoise.noise(co * 2.6 - off)))

    coat(p["Ore"], stone, veins, lift=0.05, sink=0.03)
    nuggets(p, Surface(stone), rng, 7, 0.22)


@shape("RockGemOre", smooth=())
def s_gem_ore(p, rng):
    """Stone with gem crystal clusters bursting out of it (Emerald, Ruby)."""
    stone = ore_stone(p, rng)
    gems(p, Surface(stone), rng, 5, 5, 0.8)


@shape("RockGemCluster", smooth=("Glow",))
def s_gem_cluster(p, rng):
    """A crown of big gem crystals on a stone base, glowing at the heart (Diamond)."""
    stone = p["Stone"]
    rock(stone, rng, rough=0.08, cuts=10, cut=0.2, at=(0, 0, -0.45), scale=(1.15, 1.05, 0.55))
    crystal(p["Gem"], 0.32, 1.0, (0, 0, -0.3), (0.05, 0.02, 1), spin=0.3, chamfer=0.05)
    for k in range(9):
        a = k / 9 * math.tau + rng.uniform(-0.2, 0.2)
        tilt = rng.uniform(0.35, 0.75)
        d = Vector((math.cos(a) * tilt, math.sin(a) * tilt, 1))
        base = Vector((math.cos(a) * 0.3, math.sin(a) * 0.3, -0.3))
        r = rng.uniform(0.14, 0.22)
        crystal(p["Gem"], r, rng.uniform(0.45, 0.8), base, d, spin=rng.uniform(0, 1), chamfer=0.05)
    ellipsoid(p["Glow"], (0, 0, -0.12), (0.35, 0.35, 0.18))


@shape("Crown")
def s_crown(p, rng):
    """Gold crown the King rocks wear (placed on top by Models.rock)."""
    gold = p["Gold"]
    cylinder(gold, 0.8, 0.85, 0.32, (0, 0, -0.16), segments=40, caps=False)
    bands = [f for f in gold.faces]
    gold.normal_update()
    bmesh.ops.solidify(gold, geom=bands, thickness=0.07)
    torus(gold, 0.84, 0.05, at=(0, 0, -0.16), seg=40, ring=10)
    torus(gold, 0.86, 0.045, at=(0, 0, 0.15), seg=40, ring=10)
    for k in range(6):
        a = k / 6 * math.tau
        at = Vector((math.cos(a) * 0.84, math.sin(a) * 0.84, 0.15))
        cylinder(gold, 0.2, 0.0, 0.5, at, direction=(math.cos(a) * 0.15, math.sin(a) * 0.15, 1), segments=4)
        ellipsoid(gold, at + Vector((math.cos(a) * 0.075, math.sin(a) * 0.075, 0.52)), (0.07, 0.07, 0.07), subdiv=2)
        g = at + Vector((math.cos(a) * 0.1, math.sin(a) * 0.1, -0.15))
        crystal(p["Crystal"], 0.08, 0.04, g, (math.cos(a), math.sin(a), 0), chamfer=0.15)


# --- finishing ---


def harden(bm, degrees=24):
    """Hard edges where faces meet sharply, smooth elsewhere (bakes the split
    into the mesh so it survives export)."""
    sharp = [e for e in bm.edges if e.is_manifold and e.calc_face_angle(0) > math.radians(degrees)]
    if sharp:
        bmesh.ops.split_edges(bm, edges=sharp)
    for f in bm.faces:
        f.smooth = True


class Parts(dict):
    def __missing__(self, role):
        bm = bmesh.new()
        self[role] = bm
        return bm


def build(name, rgb, collection, seed=None):
    """Build shape `name` coloured `rgb` into `collection`, parented to an
    empty named `name`. Returns the empty."""
    rng = random.Random(seed if seed is not None else name)
    mnoise.seed_set(rng.randrange(1 << 30))
    parts = Parts()
    SHAPES[name](parts, rng)
    # Centre the whole thing on the origin (its bounding box).
    lo = Vector((math.inf,) * 3)
    hi = Vector((-math.inf,) * 3)
    for bm in parts.values():
        for v in bm.verts:
            lo = Vector(map(min, lo, v.co))
            hi = Vector(map(max, hi, v.co))
    shift = Matrix.Translation(-(lo + hi) / 2)
    root = bmesh.new()
    bmesh.ops.create_cube(root, size=0.04)
    parts["Root"] = root
    empty = bpy.data.objects.new(name, None)
    collection.objects.link(empty)
    for role, bm in parts.items():
        if role != "Root":
            bmesh.ops.transform(bm, matrix=shift, verts=bm.verts)
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        if role in SMOOTH[name]:
            for f in bm.faces:
                f.smooth = True
        elif role in ("Crystal", "Gold", "Gem"):
            for f in bm.faces:
                f.smooth = False
        else:
            harden(bm)
        me = bpy.data.meshes.new(f"{name}_{role}")
        bm.to_mesh(me)
        bm.free()
        me.materials.append(material(role, rgb))
        obj = bpy.data.objects.new(f"{name}_{role}", me)
        collection.objects.link(obj)
        obj.parent = empty
    return empty


# A sample colour per shape (the rock that uses it) for previews.
SAMPLES = {
    "RockPebble": srgb(150, 150, 155),
    "RockMossy": srgb(105, 140, 85),
    "Rock": srgb(170, 110, 70),
    "RockRiver": srgb(95, 130, 150),
    "RockToxic": srgb(120, 220, 60),
    "RockBoulder": srgb(115, 105, 95),
    "RockNugget": srgb(255, 200, 40),
    "RockRune": srgb(55, 45, 75),
    "RockRoyal": srgb(170, 70, 220),
    "RockMeteor": srgb(120, 200, 255),
    "RockPhoenix": srgb(255, 90, 30),
    "RockMushroom": srgb(220, 70, 70),
    "RockGummy": srgb(255, 120, 150),
    "RockCandy": srgb(255, 80, 200),
    "RockFrosted": srgb(250, 200, 160),
    "RockLava": srgb(230, 70, 30),
    "RockMoon": srgb(230, 230, 240),
    "RockComet": srgb(110, 200, 255),
    "RockGalaxy": srgb(60, 40, 160),
    "RockOre": srgb(215, 120, 65),
    "RockOreRich": srgb(255, 200, 50),
    "RockGemOre": srgb(40, 210, 110),
    "RockGemCluster": srgb(120, 230, 255),
    "Crown": srgb(255, 230, 90),
}


def lineup(collection, per_row=8, spacing=3.2):
    """Every shape in a grid, sitting on z=0. Returns the empties."""
    empties = []
    names = list(SAMPLES)
    rows = math.ceil(len(names) / per_row)
    for i, name in enumerate(names):
        empty = build(name, SAMPLES[name], collection)
        col, row = i % per_row, i // per_row
        empty.location = ((col - (per_row - 1) / 2) * spacing, (row - (rows - 1) / 2) * spacing * 1.1, 1.1)
        empties.append(empty)
    return empties


def stage(scene, path=None):
    """Ground, sun, sky and a camera looking at the lineup."""
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=1, y_segments=1, size=30)
    me = bpy.data.meshes.new("Ground")
    bm.to_mesh(me)
    bm.free()
    me.materials.append(material("Moss", srgb(150, 215, 120)))
    ground = bpy.data.objects.new("Ground", me)
    scene.collection.objects.link(ground)
    cam = bpy.data.objects.new("RockCam", bpy.data.cameras.new("RockCam"))
    scene.collection.objects.link(cam)
    cam.location = (0, -27, 19)
    cam.rotation_euler = (math.radians(55), 0, 0)
    cam.data.lens = 38
    scene.camera = cam
    sun = bpy.data.objects.new("RockSun", bpy.data.lights.new("RockSun", "SUN"))
    sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(45), math.radians(15), math.radians(25))
    scene.collection.objects.link(sun)
    world = bpy.data.worlds.new("RockSky")
    world.use_nodes = True
    bg = next(n for n in world.node_tree.nodes if n.type == "BACKGROUND")
    bg.inputs["Color"].default_value = (*srgb(150, 210, 255), 1)
    bg.inputs["Strength"].default_value = 1.0
    scene.world = world
    scene.render.resolution_x, scene.render.resolution_y = 1600, 1000
    if path:
        try:
            scene.render.engine = "BLENDER_EEVEE_NEXT"
        except TypeError:
            scene.render.engine = "BLENDER_EEVEE"
        scene.render.filepath = os.path.abspath(path)
        bpy.ops.render.render(write_still=True)
        print(f"Rendered {path}")


def showcase():
    """Live Blender: (re)build every shape in its own 'Rocks' scene."""
    old = bpy.data.scenes.get("Rocks")
    if old:
        for obj in list(old.objects):
            bpy.data.objects.remove(obj)
        bpy.data.scenes.remove(old)
    scene = bpy.data.scenes.new("Rocks")
    bpy.context.window.scene = scene
    lineup(scene.collection)
    stage(scene)
    return scene


def export(path):
    """Export everything in the (rocks-only) current scene."""
    bpy.ops.export_scene.fbx(
        filepath=path,
        object_types={"EMPTY", "MESH"},
        apply_unit_scale=True,
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        bake_space_transform=True,
    )
    tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in bpy.context.scene.objects if o.type == "MESH")
    print(f"Exported {path} ({tris} triangles)")


def main():
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
    out = args[0]
    os.makedirs(f"{out}/Shapes", exist_ok=True)
    for name in SAMPLES:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        build(name, SAMPLES[name], bpy.context.scene.collection)
        export(f"{out}/Shapes/{name}.fbx")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    lineup(scene.collection)
    export(f"{out}/Rocks.fbx")
    if "--preview" in args:
        stage(scene, args[args.index("--preview") + 1])


if __name__ == "__main__":
    main()
