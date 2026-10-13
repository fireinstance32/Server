"""Builds the world props for +1 Lift Rock For Pets: gym equipment, the
lifting platform, rock podiums, portal arches and a trophy.

Headless (exports everything + an optional preview render):
    blender -b -P tools/blender/build_props.py -- assets/models/Props [--preview <png>]
Live Blender (Blender MCP): exec this file with a `__name__` other than
"__main__" and call `showcase()`.

Output:
    assets/models/Props/Props.fbx          every prop under an empty named
                                           after it (import once in Studio)
    assets/models/Props/Shapes/<Prop>.fbx  one file per prop

Same conventions as build_rocks.py (whose helpers this reuses): meshes are
"<Prop>_<Role>", a hidden Root is the pivot, and the game colours roles in
src/shared/Util/Models/Assets.luau. Body / Glow / Shade take the colour the
game passes (the gym's or the world's colour); Wood, Rubber, Steel, Iron,
Chalk, Stone and Gold are FIXED. Props are built in studs, standing on z=0;
build() centres them, and the game rescales them to the width it wants.
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

R.FIXED.update(
    {
        "Wood": R.srgb(176, 124, 78),
        "Rubber": R.srgb(42, 42, 48),
        "Steel": R.srgb(188, 194, 204),
        "Iron": R.srgb(70, 72, 82),
        "Chalk": R.srgb(246, 246, 240),
    }
)

shape = R.shape
SHAPES = R.SHAPES


def box(bm, size, at, bevel=0.08, rot=None):
    """A bevelled box: `size` (x, y, z) centred at `at`."""
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.transform(tmp, matrix=Matrix.Diagonal((*size, 1)), verts=tmp.verts)
    if bevel:
        bmesh.ops.bevel(tmp, geom=list(tmp.edges), offset=bevel, offset_type="OFFSET", segments=2, profile=0.5, affect="EDGES", clamp_overlap=True)
    m = Matrix.Translation(at) @ (rot or Matrix())
    bmesh.ops.transform(tmp, matrix=m, verts=tmp.verts)
    R.merge(bm, tmp)
    tmp.free()


def prism(bm, sides, radius, height, at, direction=(0, 0, 1), bevel=0.04, spin=0.0):
    """A bevelled n-sided prism (hex dumbbell heads, octagon pedestals)."""
    tmp = bmesh.new()
    bmesh.ops.create_cone(tmp, cap_ends=True, segments=sides, radius1=radius, radius2=radius, depth=height, matrix=Matrix.Rotation(spin, 4, "Z"))
    if bevel:
        bmesh.ops.bevel(tmp, geom=list(tmp.edges), offset=bevel, offset_type="OFFSET", segments=2, profile=0.5, affect="EDGES", clamp_overlap=True)
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ R.aim(direction), verts=tmp.verts)
    R.merge(bm, tmp)
    tmp.free()


def plate(p, role, radius, thickness, at, direction=(1, 0, 0), hole=0.12):
    """A bumper plate lying along `direction`: a thin web, a fat rounded rim,
    a raised ring on each face and a steel hub."""
    d = Vector(direction).normalized()
    at = Vector(at)
    R.cylinder(p[role], radius * 0.9, radius * 0.9, thickness * 0.55, at - d * thickness * 0.275, d, segments=32)
    R.torus(p[role], radius - thickness * 0.45, thickness * 0.45, at=at, direction=d, seg=32, ring=8)
    for side in (-1, 1):
        R.torus(p[role], radius * 0.55, thickness * 0.1, at=at + d * side * thickness * 0.27, direction=d, seg=32, ring=4)
    R.cylinder(p["Steel"], hole * 2.2, hole * 2.2, thickness * 1.15, at - d * thickness * 0.575, d, segments=24)


# --- gym ---


@shape("Dumbbell", smooth=("Steel",))
def p_dumbbell(p, rng):
    """Hex dumbbell lying on the floor: iron heads, knurled steel grip, coloured bands."""
    for side in (-1, 1):
        prism(p["Iron"], 6, 0.55, 0.62, (side * 0.75, 0, 0.55), direction=(1, 0, 0), bevel=0.05, spin=math.pi / 6)
        R.cylinder(p["Body"], 0.38, 0.38, 0.08, (side * 0.75 + side * 0.31, 0, 0.55), (side, 0, 0), segments=24)
    R.cylinder(p["Steel"], 0.13, 0.13, 1.0, (-0.5, 0, 0.55), (1, 0, 0), segments=20)
    # Knurling: thin rings along the grip.
    for k in range(7):
        x = -0.33 + k * 0.11
        R.torus(p["Steel"], 0.13, 0.018, at=(x, 0, 0.55), direction=(1, 0, 0), seg=20, ring=6)


@shape("Kettlebell", smooth=("Body", "Iron"))
def p_kettlebell(p, rng):
    """Competition kettlebell: coloured bell, iron handle, flat base."""
    body = p["Body"]
    R.ellipsoid(body, (0, 0, 0.75), (0.75, 0.75, 0.72), subdiv=4)
    bmesh.ops.delete(body, geom=[v for v in body.verts if v.co.z < 0.12], context="VERTS")
    bmesh.ops.contextual_create(body, geom=[e for e in body.edges if e.is_boundary])
    for v in body.verts:
        v.co.z = max(v.co.z, 0.12)
    # Handle: half a torus standing up + two posts.
    tmp = bmesh.new()
    R.torus(tmp, 0.42, 0.09, at=(0, 0, 0), direction=(0, 1, 0), seg=32, ring=12)
    bmesh.ops.delete(tmp, geom=[v for v in tmp.verts if v.co.z < -0.02], context="VERTS")
    bmesh.ops.transform(tmp, matrix=Matrix.Translation((0, 0, 1.55)), verts=tmp.verts)
    R.merge(p["Iron"], tmp)
    tmp.free()
    for side in (-1, 1):
        R.cylinder(p["Iron"], 0.1, 0.1, 0.42, (side * 0.42, 0, 1.15), segments=12)


@shape("Bench", smooth=("Body",))
def p_bench(p, rng):
    """Flat weight bench: padded top, steel frame, rubber feet."""
    box(p["Body"], (3.2, 0.95, 0.32), (0, 0, 1.25), bevel=0.12)
    box(p["Steel"], (2.9, 0.5, 0.12), (0, 0, 1.03), bevel=0.03)
    for x in (-1.25, 1.25):
        box(p["Steel"], (0.16, 0.16, 1.0), (x, 0, 0.55), bevel=0.03)
        box(p["Steel"], (0.16, 1.1, 0.16), (x, 0, 0.1), bevel=0.03)
        for y in (-0.5, 0.5):
            box(p["Rubber"], (0.24, 0.2, 0.08), (x, y, 0.04), bevel=0.02)


@shape("BarbellRack", smooth=("Steel",))
def p_barbell_rack(p, rng):
    """Squat rack: two uprights with J-hooks holding a loaded barbell."""
    for x in (-1.6, 1.6):
        box(p["Iron"], (0.3, 0.3, 3.4), (x, 0, 1.7), bevel=0.04)
        box(p["Iron"], (0.4, 1.6, 0.18), (x, 0, 0.09), bevel=0.04)
        for k in range(9):
            R.cylinder(p["Rubber"], 0.045, 0.045, 0.32, (x, -0.16, 0.6 + k * 0.3), (0, 1, 0), segments=8)
        box(p["Steel"], (0.32, 0.36, 0.1), (x, -0.3, 2.35), bevel=0.02)
        box(p["Steel"], (0.32, 0.1, 0.22), (x, -0.45, 2.45), bevel=0.02)
    bar_z = 2.55
    R.cylinder(p["Steel"], 0.06, 0.06, 5.6, (-2.8, -0.3, bar_z), (1, 0, 0), segments=16)
    for side in (-1, 1):
        R.cylinder(p["Steel"], 0.1, 0.1, 0.12, (side * 1.95, -0.3, bar_z), (side, 0, 0), segments=16)
        plate(p, "Body", 0.85, 0.2, (side * 2.25, -0.3, bar_z), (side, 0, 0))
        plate(p, "Shade", 0.6, 0.16, (side * 2.47, -0.3, bar_z), (side, 0, 0))
        R.cylinder(p["Iron"], 0.12, 0.12, 0.1, (side * 2.6, -0.3, bar_z), (side, 0, 0), segments=16)


@shape("PlateTree", smooth=("Steel",))
def p_plate_tree(p, rng):
    """Plate tree: a steel post with pegs and stacked coloured bumper plates."""
    box(p["Iron"], (1.4, 1.4, 0.16), (0, 0, 0.08), bevel=0.04)
    R.cylinder(p["Steel"], 0.12, 0.12, 2.6, (0, 0, 0.1), segments=16)
    for k, (z, d, r, role) in enumerate([(0.75, 1, 0.75, "Body"), (0.75, -1, 0.75, "Body"), (1.65, 1, 0.55, "Shade"), (1.65, -1, 0.55, "Shade")]):
        R.cylinder(p["Steel"], 0.05, 0.05, 0.55, (0, 0, z), (0, d, 0), segments=10)
        for n in range(2 if role == "Body" else 3):
            plate(p, role, r, 0.13, (0, d * (0.22 + n * 0.14), z), (0, d, 0), hole=0.06)


@shape("LiftPlatform", smooth=())
def p_lift_platform(p, rng):
    """Olympic lifting platform: wood centre, rubber sides, coloured frame, chalk dust."""
    w, l, h = 10.0, 8.0, 0.5
    box(p["Wood"], (4.2, l - 0.6, h), (0, 0, h / 2), bevel=0.04)
    for side in (-1, 1):
        box(p["Rubber"], (2.6, l - 0.6, h * 0.96), (side * 3.4, 0, h * 0.48), bevel=0.04)
    # Frame in the gym's colour.
    box(p["Body"], (w, 0.3, h + 0.08), (0, l / 2 - 0.15, (h + 0.08) / 2), bevel=0.05)
    box(p["Body"], (w, 0.3, h + 0.08), (0, -l / 2 + 0.15, (h + 0.08) / 2), bevel=0.05)
    box(p["Body"], (0.3, l, h + 0.08), (w / 2 - 0.15, 0, (h + 0.08) / 2), bevel=0.05)
    box(p["Body"], (0.3, l, h + 0.08), (-w / 2 + 0.15, 0, (h + 0.08) / 2), bevel=0.05)
    # Wood plank seams.
    for k in range(1, 6):
        y = -l / 2 + 0.3 + k * (l - 0.6) / 6
        box(p["Shade"], (4.2, 0.04, 0.02), (0, y, h + 0.005), bevel=0)
    # Chalk dust where the hands and feet go.
    for _ in range(9):
        a, d = rng.uniform(0, math.tau), rng.uniform(0, 1.6)
        s = rng.uniform(0.25, 0.6)
        R.ellipsoid(p["Chalk"], (math.cos(a) * d * 0.7, math.sin(a) * d, h + 0.01), (s, s * rng.uniform(0.5, 1), 0.02), Matrix.Rotation(rng.uniform(0, 3), 4, "Z"), subdiv=2)


@shape("WeightPile", smooth=())
def p_weight_pile(p, rng):
    """A heap of loose plates and dumbbells (corner decor)."""
    for k in range(5):
        r = rng.uniform(0.5, 0.85)
        role = "Body" if k % 2 == 0 else "Shade"
        tilt = (rng.uniform(-0.25, 0.25), rng.uniform(-0.25, 0.25), 1)
        plate(p, role, r, 0.16, (rng.uniform(-0.7, 0.7), rng.uniform(-0.7, 0.7), 0.1 + k * 0.17), tilt, hole=0.08)
    for k in range(2):
        a = rng.uniform(0, math.tau)
        at = Vector((math.cos(a) * 1.3, math.sin(a) * 1.3, 0.3))
        d = Vector((math.cos(a + 1.4), math.sin(a + 1.4), 0))
        for side in (-1, 1):
            prism(p["Iron"], 6, 0.3, 0.34, at + d * side * 0.42, direction=d, bevel=0.03)
        R.cylinder(p["Steel"], 0.07, 0.07, 0.56, at - d * 0.28, d, segments=12)


# --- world ---


@shape("Podium", smooth=("Glow",))
def p_podium(p, rng):
    """Rock podium: stepped octagonal stone pedestal, gold trim, glowing ring
    in the podium's colour, and a top plate the rock floats over."""
    stone = p["Stone"]
    prism(stone, 8, 4.3, 0.7, (0, 0, 0.35), bevel=0.12, spin=math.pi / 8)
    prism(stone, 8, 3.7, 1.7, (0, 0, 1.55), bevel=0.12, spin=math.pi / 8)
    prism(stone, 8, 4.0, 0.5, (0, 0, 2.65), bevel=0.1, spin=math.pi / 8)
    prism(p["Body"], 8, 3.6, 0.12, (0, 0, 2.96), bevel=0.04, spin=math.pi / 8)
    R.torus(p["Gold"], 4.05, 0.09, at=(0, 0, 2.65), seg=64, ring=10)
    R.torus(p["Gold"], 4.35, 0.08, at=(0, 0, 0.7), seg=64, ring=10)
    R.torus(p["Glow"], 3.72, 0.1, at=(0, 0, 1.55), seg=64, ring=10)
    for k in range(8):
        a = (k + 0.5) / 8 * math.tau
        R.ellipsoid(p["Gold"], (math.cos(a) * 3.82, math.sin(a) * 3.82, 2.15), (0.16, 0.16, 0.16), subdiv=2)


def stone_block(bm, rng, size, at, rot):
    """A chiselled stone block: a bevelled box with its corners knocked about."""
    tmp = bmesh.new()
    bmesh.ops.create_cube(tmp, size=1.0)
    bmesh.ops.subdivide_edges(tmp, edges=list(tmp.edges), cuts=2, use_grid_fill=True)
    for v in tmp.verts:
        v.co += Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-1, 1))) * 0.035
    bmesh.ops.transform(tmp, matrix=Matrix.Diagonal((*size, 1)), verts=tmp.verts)
    bmesh.ops.bevel(tmp, geom=[e for e in tmp.edges if e.calc_face_angle(0) > 0.6], offset=min(size) * 0.12, offset_type="OFFSET", segments=2, profile=0.6, affect="EDGES", clamp_overlap=True)
    bmesh.ops.transform(tmp, matrix=Matrix.Translation(at) @ rot, verts=tmp.verts)
    R.merge(bm, tmp)
    tmp.free()


@shape("PortalArch", smooth=("Glow",))
def p_portal_arch(p, rng):
    """Chunky stone arch for the world portals: stacked chiselled pillars, a
    round arch of wedge blocks, a keystone with a glowing rune in the world's
    colour. Opening ~13 x 18 studs."""
    stone, glow = p["Stone"], p["Glow"]
    # Pillars: plinth, five blocks (alternately turned), capital.
    for side in (-1, 1):
        x = side * 8.4
        stone_block(stone, rng, (4.2, 4.2, 1.4), (x, 0, 0.7), Matrix())
        z = 1.4
        for k in range(5):
            h = rng.uniform(2.6, 3.0)
            stone_block(stone, rng, (3.3, 3.3, h), (x, 0, z + h / 2), Matrix.Rotation(rng.uniform(-0.06, 0.06) + (0.04 if k % 2 else 0), 4, "Z"))
            z += h
        stone_block(stone, rng, (4.0, 4.0, 1.0), (x, 0, z + 0.5), Matrix())
        top = z + 1.0
    # Arch: wedge blocks around a half circle springing from the capitals.
    radius, n = 8.4, 9
    for k in range(n):
        a = math.pi * (k + 0.5) / n
        at = Vector((math.cos(a) * radius, 0, top + math.sin(a) * radius * 0.62))
        tangent = Vector((-math.sin(a), 0, math.cos(a) * 0.62)).normalized()
        spin = math.atan2(tangent.z, tangent.x)
        size = (2.6, 3.2, 2.3) if k != n // 2 else (2.4, 3.8, 3.2)
        role = stone if k != n // 2 else p["Shade"]
        stone_block(role, rng, size, at, Matrix.Rotation(-spin, 4, "Y"))
    # Rune on both faces of the keystone: a diamond in a ring, two side sparks.
    for face in (-1, 1):
        key = Vector((0, face * 1.95, top + radius * 0.62))
        out = Vector((0, face * 0.2, 0))
        R.hull(glow, [key + Vector(v) for v in ((0, 0, 1.0), (0, 0, -1.0), (0.65, 0, 0), (-0.65, 0, 0))] + [key + out])
        R.torus(glow, 1.2, 0.09, at=key, direction=(0, 1, 0), seg=40, ring=8)
        for side in (-1, 1):
            R.hull(glow, [key + Vector(v) for v in ((side * 1.6, 0, 0.3), (side * 1.6, 0, -0.3), (side * 1.9, 0, 0), (side * 1.3, 0, 0))] + [key + Vector((side * 1.6, 0, 0)) + out * 0.5])


@shape("Trophy", smooth=("Gold",))
def p_trophy(p, rng):
    """Gold trophy cup on a stone base (leaderboards, Wins)."""
    box(p["Stone"], (1.6, 1.6, 0.6), (0, 0, 0.3), bevel=0.08)
    box(p["Body"], (1.3, 1.3, 0.12), (0, 0, 0.66), bevel=0.03)
    gold = p["Gold"]
    R.cylinder(gold, 0.45, 0.3, 0.2, (0, 0, 0.72), segments=32)
    R.cylinder(gold, 0.12, 0.12, 0.7, (0, 0, 0.9), segments=20)
    R.ellipsoid(gold, (0, 0, 1.6), (0.3, 0.3, 0.1), subdiv=3)
    cup = bmesh.new()
    bmesh.ops.create_uvsphere(cup, u_segments=40, v_segments=20, radius=1.0)
    bmesh.ops.delete(cup, geom=[v for v in cup.verts if v.co.z > 0.35], context="VERTS")
    bmesh.ops.transform(cup, matrix=Matrix.Translation((0, 0, 2.3)) @ Matrix.Diagonal((0.85, 0.85, 0.8, 1)), verts=cup.verts)
    cup.normal_update()
    bmesh.ops.solidify(cup, geom=list(cup.faces), thickness=0.06)
    R.merge(gold, cup)
    cup.free()
    R.torus(gold, 0.79, 0.05, at=(0, 0, 2.58), seg=48, ring=8)
    for side in (-1, 1):
        tmp = bmesh.new()
        R.torus(tmp, 0.32, 0.06, at=(0, 0, 0), direction=(0, 1, 0), seg=28, ring=8)
        bmesh.ops.delete(tmp, geom=[v for v in tmp.verts if v.co.x * side < -0.05], context="VERTS")
        bmesh.ops.transform(tmp, matrix=Matrix.Translation((side * 0.78, 0, 2.15)), verts=tmp.verts)
        R.merge(gold, tmp)
        tmp.free()
    R.hull(p["Glow"], [Vector((0, -0.62, 2.0)) + Vector(v) * 0.22 for v in ((0, 0, 1), (0, 0, -1), (0.8, 0, 0.25), (-0.8, 0, 0.25), (0.5, 0, -0.8), (-0.5, 0, -0.8), (0, -0.2, 0))])


SAMPLES = {
    "LiftPlatform": R.srgb(230, 120, 70),
    "Dumbbell": R.srgb(230, 60, 60),
    "Kettlebell": R.srgb(60, 140, 230),
    "Bench": R.srgb(230, 60, 60),
    "BarbellRack": R.srgb(60, 180, 90),
    "PlateTree": R.srgb(240, 190, 40),
    "WeightPile": R.srgb(60, 140, 230),
    "Podium": R.srgb(120, 200, 255),
    "PortalArch": R.srgb(255, 140, 40),
    "Trophy": R.srgb(170, 70, 220),
}


def lineup(collection, per_row=5, spacing=6.0):
    empties = []
    names = list(SAMPLES)
    rows = math.ceil(len(names) / per_row)
    for i, name in enumerate(names):
        empty = R.build(name, SAMPLES[name], collection)
        # Each prop's own size: big ones shrink to fit the grid.
        size = max(max(c.dimensions) for c in empty.children if c.type == "MESH")
        k = min(1.0, 5.5 / size)
        empty.scale = (k, k, k)
        col, row = i % per_row, i // per_row
        empty.location = ((col - (per_row - 1) / 2) * spacing, (row - (rows - 1) / 2) * spacing, 3)
        empties.append(empty)
    return empties


def stage(scene, path=None):
    R.stage(scene, None)
    scene.camera.location = (0, -30, 15)
    scene.camera.data.lens = 30
    scene.camera.rotation_euler = (math.radians(66), 0, 0)
    if path:
        try:
            scene.render.engine = "BLENDER_EEVEE_NEXT"
        except TypeError:
            scene.render.engine = "BLENDER_EEVEE"
        scene.render.filepath = os.path.abspath(path)
        bpy.ops.render.render(write_still=True)
        print(f"Rendered {path}")


def showcase():
    old = bpy.data.scenes.get("Props")
    if old:
        for obj in list(old.objects):
            bpy.data.objects.remove(obj)
        bpy.data.scenes.remove(old)
    scene = bpy.data.scenes.new("Props")
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
    # The combined file keeps every prop at its real size (no lineup scaling).
    for i, name in enumerate(SAMPLES):
        R.build(name, SAMPLES[name], scene.collection).location = (i * 30, 0, 0)
    R.export(f"{out}/Props.fbx")
    if "--preview" in args:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        scene = bpy.context.scene
        lineup(scene.collection)
        stage(scene, args[args.index("--preview") + 1])


if __name__ == "__main__":
    main()
