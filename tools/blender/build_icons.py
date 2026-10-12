"""Renders the UI icon set (glossy toy-style 3D icons, like the reference
games) and packs them into one sheet, so the game needs a single upload.

    python tools/blender/build_icons.py <out_dir>

Writes <out_dir>/icon_<name>.png (raw renders) and, via pack_icons.py,
assets/textures/ui/icons.png + src/shared/Config/IconAtlas.luau.
"""

import math
import os
import sys

import bpy  # first: it puts bmesh/mathutils on the path
import bmesh
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "../.."))
PET_TEXTURES = os.path.join(REPO, "assets/textures/pets")
RES = 360


def srgb(r, g, b):
    def lin(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    return (lin(r), lin(g), lin(b))


def clear():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def deselect():
    bpy.ops.object.select_all(action="DESELECT")


_mats = {}


def mat(rgb, rough=0.32, metal=0.0, emit=0.0, alpha=1.0):
    key = (rgb, rough, metal, emit, alpha)
    if key in _mats:
        return _mats[key]
    m = bpy.data.materials.new(str(key))
    b = m.node_tree.nodes.get("Principled BSDF")
    col = srgb(*rgb)
    b.inputs["Base Color"].default_value = (*col, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    for name in ("Coat Weight", "Clearcoat"):
        if name in b.inputs:
            b.inputs[name].default_value = 0.4
    if emit > 0:
        b.inputs["Emission Color"].default_value = (*col, 1)
        b.inputs["Emission Strength"].default_value = emit
    if alpha < 1:
        b.inputs["Alpha"].default_value = alpha
    _mats[key] = m
    return m


def finish(obj, m, bevel=0.0, smooth=True, rot=(0, 0, 0)):
    obj.rotation_euler = tuple(math.radians(a) for a in rot)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 4
        mod.limit_method = "NONE"
        deselect()
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if smooth:
        deselect()
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.shade_smooth()
    obj.data.materials.append(m)
    return obj


def apply_scale(obj, scale):
    obj.scale = scale
    deselect()
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)


def cube(size, loc, m, bevel=0.08, rot=(0, 0, 0)):
    deselect()
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    apply_scale(obj, size)
    return finish(obj, m, bevel, smooth=bevel > 0, rot=rot)


def cyl(r, depth, loc, m, rot=(0, 0, 0), bevel=0.03, verts=40, r2=None):
    deselect()
    if r2 is None:
        bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=depth, location=loc)
    else:
        bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r, radius2=r2, depth=depth, location=loc)
    return finish(bpy.context.active_object, m, bevel, rot=rot)


def sphere(r, loc, m, scale=(1, 1, 1), rot=(0, 0, 0)):
    deselect()
    bpy.ops.mesh.primitive_uv_sphere_add(segments=40, ring_count=24, radius=r, location=loc)
    obj = bpy.context.active_object
    apply_scale(obj, scale)
    return finish(obj, m, rot=rot)


def arc(R, r, start, end, loc, m, rot=(90, 0, 0)):
    """Part of a torus in its local XY plane, from `start` to `end` degrees."""
    deselect()
    bpy.ops.mesh.primitive_torus_add(major_radius=R, minor_radius=r, major_segments=64, minor_segments=16, location=loc)
    obj = bpy.context.active_object
    if end - start >= 360:
        return finish(obj, m, rot=rot)
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    drop = []
    for v in bm.verts:
        a = math.degrees(math.atan2(v.co.y, v.co.x)) % 360
        lo, hi = start % 360, end % 360
        inside = lo <= a <= hi if lo <= hi else (a >= lo or a <= hi)
        if not inside:
            drop.append(v)
    bmesh.ops.delete(bm, geom=drop, context="VERTS")
    bm.to_mesh(obj.data)
    bm.free()
    return finish(obj, m, rot=rot)


def prism(points, depth, loc, m, rot=(0, 0, 0), bevel=0.04):
    """Extrude a 2D outline (x, z) along Y."""
    mesh = bpy.data.meshes.new("Prism")
    bm = bmesh.new()
    verts = [bm.verts.new((x, -depth / 2, z)) for x, z in points]
    face = bm.faces.new(verts)
    ext = bmesh.ops.extrude_face_region(bm, geom=[face])
    moved = [e for e in ext["geom"] if isinstance(e, bmesh.types.BMVert)]
    bmesh.ops.translate(bm, verts=moved, vec=(0, depth, 0))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new("Prism", mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.location = loc
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 3
        mod.limit_method = "ANGLE"
        deselect()
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.rotation_euler = tuple(math.radians(a) for a in rot)
    obj.data.materials.append(m)
    return obj


def star_points(outer, inner, n=5, phase=90):
    pts = []
    for i in range(n * 2):
        a = math.radians(phase + i * 180 / n)
        r = outer if i % 2 == 0 else inner
        pts.append((math.cos(a) * r, math.sin(a) * r))
    return pts


def decal(image, size, loc):
    """A textured square facing the camera (-Y)."""
    deselect()
    bpy.ops.mesh.primitive_plane_add(size=size, location=loc, rotation=(math.radians(90), 0, 0))
    plane = bpy.context.active_object
    m = bpy.data.materials.new(f"Decal_{image}")
    nodes, links = m.node_tree.nodes, m.node_tree.links
    b = nodes.get("Principled BSDF")
    b.inputs["Roughness"].default_value = 0.4
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(os.path.join(PET_TEXTURES, f"{image}.png"), check_existing=True)
    links.new(tex.outputs["Color"], b.inputs["Base Color"])
    links.new(tex.outputs["Alpha"], b.inputs["Alpha"])
    plane.data.materials.append(m)
    return plane


def text(body, size, loc, m, depth=0.05):
    curve = bpy.data.curves.new("Text", "FONT")
    curve.body = body
    curve.size = size
    curve.extrude = depth
    curve.align_x = "CENTER"
    curve.align_y = "CENTER"
    obj = bpy.data.objects.new("Text", curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.location = loc
    obj.rotation_euler = (math.radians(90), 0, 0)
    obj.data.materials.append(m)
    return obj


# ---------------------------------------------------------------- icons
PINK, BLUE, GOLD, WHITE, DARK = (240, 60, 130), (60, 150, 255), (255, 200, 40), (250, 250, 250), (40, 35, 45)


def icon_shop():
    body = cube((1.6, 1.1, 1.0), (0, 0, -0.2), mat(PINK), 0.1)
    for v in body.data.vertices:  # flare the top
        if v.co.z > 0:
            v.co.x *= 1.15
            v.co.y *= 1.15
    for x in (-0.45, 0, 0.45):
        cube((0.16, 0.05, 0.5), (x, -0.6, -0.2), mat((200, 30, 90)), 0.03)
    arc(0.65, 0.09, 0, 180, (0, 0, 0.3), mat(BLUE))


def arrow_arc(color, start, end, R=0.75):
    arc(R, 0.17, start, end, (0, 0, 0), mat(color))
    a = math.radians(end)
    tip = (math.cos(a) * R, 0, math.sin(a) * R)
    cyl(0.32, 0.45, tip, mat(color), rot=(0, -end, 0), r2=0.0, bevel=0.02)


def icon_rebirth():
    arrow_arc(BLUE, 20, 150)
    arrow_arc(PINK, 200, 330)


def icon_pets():
    cube((1.4, 1.4, 1.4), (0, 0, 0), mat((245, 150, 70)), 0.18)
    decal("face_cat", 1.38, (0, -0.71, 0))
    for side in (-1, 1):
        cube((0.4, 0.15, 0.4), (side * 0.42, 0, 0.72), mat((210, 110, 40)), 0.05, rot=(0, 45, 0))


def icon_trails():
    sphere(0.45, (0.45, 0, 0.4), mat((255, 120, 220), emit=0.6))
    tail = cyl(0.45, 1.8, (-0.35, 0, -0.25), mat((170, 90, 255), emit=0.4), rot=(0, -122, 0), r2=0.02, bevel=0)
    for x, z, s in ((-0.7, 0.45, 0.22), (0.1, -0.7, 0.18), (-1.0, -0.4, 0.15)):
        prism(star_points(s, s * 0.45), 0.08, (x, -0.1, z), mat(GOLD, emit=0.3))


def icon_inventory():
    brown = (165, 100, 55)
    cube((1.2, 0.75, 1.4), (0, 0, 0), mat(brown), 0.18)
    cube((0.85, 0.25, 0.6), (0, -0.45, -0.25), mat((195, 130, 75)), 0.1)
    cube((1.22, 0.8, 0.45), (0, 0, 0.55), mat((140, 80, 40)), 0.12)
    for x in (-0.3, 0.3):
        cube((0.12, 0.05, 0.75), (x, -0.42, 0.25), mat((100, 55, 25)), 0.02)
        cube((0.16, 0.06, 0.12), (x, -0.45, 0.0), mat(GOLD, metal=0.8), 0.02)
    arc(0.25, 0.06, 0, 180, (0, 0, 0.75), mat((100, 55, 25)))


def icon_gifts():
    cube((1.25, 1.25, 1.1), (0, 0, -0.1), mat(BLUE), 0.08)
    cube((0.28, 1.3, 1.15), (0, 0, -0.1), mat(GOLD), 0.03)
    cube((1.3, 0.28, 1.15), (0, 0, -0.1), mat(GOLD), 0.03)
    cube((1.35, 1.35, 0.3), (0, 0, 0.5), mat((40, 120, 230)), 0.06)
    for side in (-1, 1):
        arc(0.25, 0.08, 0, 360, (side * 0.25, 0, 0.82), mat(GOLD), rot=(90, side * 30, 0))
    sphere(0.12, (0, -0.05, 0.75), mat(GOLD))


def icon_daily():
    cube((1.4, 0.3, 1.4), (0, 0, 0), mat(WHITE), 0.1)
    cube((1.42, 0.32, 0.38), (0, 0, 0.53), mat((235, 70, 70)), 0.08)
    for x in (-0.4, 0.4):
        cyl(0.07, 0.4, (x, 0, 0.78), mat((170, 170, 180), metal=0.7))
    text("17", 0.7, (0, -0.17, -0.12), mat(DARK))


BOLT = [(0.15, 1.0), (-0.55, -0.05), (-0.05, -0.05), (-0.25, -1.0), (0.55, 0.15), (0.05, 0.15), (0.3, 1.0)]


def icon_bolt():
    prism(BOLT, 0.35, (0, 0, 0), mat((255, 205, 40)), bevel=0.06)


def icon_trophy():
    gold = mat(GOLD, rough=0.22, metal=0.85)
    cyl(0.6, 0.8, (0, 0, 0.35), gold, r2=0.35, rot=(180, 0, 0), bevel=0.04)
    for side in (-1, 1):
        arc(0.28, 0.07, 0, 360, (side * 0.65, 0, 0.4), gold)
    cyl(0.1, 0.35, (0, 0, -0.2), gold)
    cube((0.8, 0.5, 0.25), (0, 0, -0.45), mat((150, 90, 40)), 0.06)
    prism(star_points(0.18, 0.08), 0.05, (0, -0.52, 0.4), mat(WHITE), rot=(0, 0, 0), bevel=0.01)


def frog(color):
    cube((1.4, 1.3, 1.0), (0, 0, -0.1), mat(color), 0.22)
    belly = tuple(int(c + (255 - c) * 0.6) for c in color)
    cube((1.0, 0.1, 0.5), (0, -0.66, -0.25), mat(belly), 0.04)
    for side in (-1, 1):
        cube((0.5, 0.5, 0.5), (side * 0.38, -0.2, 0.55), mat(WHITE), 0.12)
        cube((0.24, 0.08, 0.28), (side * 0.38, -0.47, 0.55), mat(DARK), 0.04)
        sphere(0.05, (side * 0.38 - 0.05, -0.52, 0.63), mat(WHITE))
        cube((0.45, 0.4, 0.2), (side * 0.48, -0.35, -0.6), mat(tuple(int(c * 0.75) for c in color)), 0.05)
    cube((0.6, 0.05, 0.06), (0, -0.66, 0.05), mat((70, 25, 30)), 0)


def icon_frog():
    frog((110, 205, 80))


def icon_starter():
    cube((1.3, 1.3, 1.3), (0, 0, 0), mat(WHITE), 0.18)
    decal("face_unicorn", 1.28, (0, -0.66, 0))
    cyl(0.12, 0.6, (0, -0.3, 0.9), mat(GOLD, metal=0.6), r2=0.0, rot=(-15, 0, 0))
    for i, c in enumerate(((255, 110, 190), (170, 120, 255), (110, 210, 255))):
        cube((0.25, 0.3, 0.35), (-0.1 + i * 0.05, 0.1 + i * 0.25, 0.68 - i * 0.05), mat(c), 0.05)
    for side in (-1, 1):
        cube((0.7, 0.12, 0.45), (side * 0.85, 0.2, 0.25), mat((255, 230, 120)), 0.06, rot=(0, -side * 25, 0))


def potion(color):
    sphere(0.6, (0, 0, -0.25), mat(color, rough=0.15))
    cyl(0.2, 0.45, (0, 0, 0.45), mat(tuple(int(c + (255 - c) * 0.4) for c in color), rough=0.15))
    cyl(0.24, 0.22, (0, 0, 0.75), mat((160, 105, 60)))
    sphere(0.14, (-0.22, -0.45, -0.05), mat(WHITE, emit=0.6), scale=(1, 0.4, 1.4))


def icon_potion_hops():
    potion((90, 220, 90))


def icon_potion_wins():
    potion((255, 190, 40))


def icon_potion_luck():
    potion((170, 100, 255))


def icon_egg():
    egg = sphere(0.75, (0, 0, 0), mat((150, 210, 255)), scale=(0.8, 0.8, 1.0))
    for v in egg.data.vertices:
        if v.co.z > 0:
            f = 1 - 0.18 * v.co.z / 0.75
            v.co.x *= f
            v.co.y *= f
    for x, z, r in ((-0.25, 0.25, 0.14), (0.3, -0.1, 0.12), (-0.05, -0.45, 0.1), (0.15, 0.5, 0.08)):
        sphere(r, (x, -0.55, z), mat(WHITE), scale=(1, 0.4, 1))


def icon_lock():
    cube((1.1, 0.55, 0.85), (0, 0, -0.3), mat(GOLD, rough=0.25, metal=0.8), 0.1)
    arc(0.38, 0.1, 0, 180, (0, 0, 0.1), mat((190, 190, 200), metal=0.9, rough=0.25))
    cyl(0.1, 0.1, (0, -0.28, -0.2), mat(DARK), rot=(90, 0, 0))
    cube((0.08, 0.1, 0.25), (0, -0.28, -0.38), mat(DARK), 0)


def icon_plus():
    a, b = 0.24, 0.72
    prism([(-a, b), (a, b), (a, a), (b, a), (b, -a), (a, -a), (a, -b), (-a, -b), (-a, -a), (-b, -a), (-b, a), (-a, a)], 0.4, (0, 0, 0), mat((90, 210, 80)), bevel=0.08)


def icon_close():
    cube((1.4, 0.35, 1.4), (0, 0, 0), mat((235, 50, 70)), 0.2)
    a, b = 0.13, 0.42
    cross = [(-a, b - a), (0, a + 0.0), (a, b - a), (b, b - a), (a + 0.0, 0), (b, a - b), (a, a - b), (0, -a), (-a, a - b), (-b, a - b), (-a, 0), (-b, b - a)]
    cross = [(x * 1.25, z * 1.25) for x, z in [(-b, b), (-b + a * 1.4, b), (0, a * 1.4), (b - a * 1.4, b), (b, b), (b, b - a * 1.4), (a * 1.4, 0), (b, -b + a * 1.4), (b, -b), (b - a * 1.4, -b), (0, -a * 1.4), (-b + a * 1.4, -b), (-b, -b), (-b, -b + a * 1.4), (-a * 1.4, 0), (-b, b - a * 1.4)]]
    prism(cross, 0.12, (0, -0.2, 0), mat(WHITE), bevel=0.03)


def icon_star():
    prism(star_points(1.0, 0.45), 0.35, (0, 0, 0), mat(GOLD), bevel=0.08)


def icon_settings():
    grey = mat((170, 175, 190), metal=0.6, rough=0.3)
    cyl(0.7, 0.35, (0, 0, 0), grey, rot=(90, 0, 0))
    for i in range(8):
        a = i * 45
        cube((0.32, 0.35, 0.3), (math.cos(math.radians(a)) * 0.8, 0, math.sin(math.radians(a)) * 0.8), grey, 0.04, rot=(0, -a, 0))
    cyl(0.25, 0.4, (0, -0.02, 0), mat(DARK), rot=(90, 0, 0))


def icon_pumpkin():
    orange = mat((255, 130, 30))
    for i in range(6):
        a = math.radians(i * 60)
        sphere(0.5, (math.cos(a) * 0.32, math.sin(a) * 0.32, -0.1), orange, scale=(0.8, 0.8, 1.0))
    sphere(0.55, (0, 0, -0.05), orange)
    cyl(0.1, 0.4, (0, 0, 0.6), mat((80, 140, 40)), rot=(0, 15, 0))


def icon_candy_corn():
    cyl(0.75, 0.55, (0, 0, -0.5), mat((255, 210, 50)), r2=0.55, bevel=0.06)
    cyl(0.55, 0.55, (0, 0, 0.02), mat((255, 140, 40)), r2=0.32, bevel=0.06)
    cyl(0.32, 0.5, (0, 0, 0.5), mat(WHITE), r2=0.04, bevel=0.06)


def icon_crown():
    gold = mat(GOLD, rough=0.22, metal=0.85)
    cyl(0.75, 0.45, (0, 0, -0.3), gold)
    for i in range(5):
        a = math.radians(i * 72 - 90)
        cyl(0.2, 0.55, (math.cos(a) * 0.62, math.sin(a) * 0.62, 0.15), gold, r2=0.0)
        sphere(0.08, (math.cos(a) * 0.62, math.sin(a) * 0.62, 0.45), mat((240, 50, 80)))
    sphere(0.14, (0, -0.76, -0.3), mat((60, 160, 255)))


def icon_portal():
    arc(0.75, 0.2, 0, 360, (0, 0, 0), mat((150, 80, 230)))
    cyl(0.62, 0.05, (0, 0.05, 0), mat((90, 230, 255), emit=1.2), rot=(90, 0, 0), bevel=0)


def icon_book():
    cube((1.2, 0.35, 1.45), (0, 0.04, 0), mat((220, 60, 60)), 0.08)
    cube((1.05, 0.3, 1.32), (0.1, -0.02, 0), mat((250, 245, 230)), 0.02)
    cube((1.0, 0.1, 1.42), (-0.05, -0.15, 0), mat((235, 75, 75)), 0.04)
    prism(star_points(0.25, 0.11), 0.04, (-0.05, -0.22, 0.05), mat(GOLD))


def icon_ticket():
    cube((1.5, 0.25, 0.9), (0, 0, 0), mat((255, 150, 50)), 0.1)
    for x in (-0.75, 0.75):
        cyl(0.18, 0.3, (x, 0, 0), mat((255, 255, 255), alpha=0.0), rot=(90, 0, 0))
    prism(star_points(0.3, 0.13), 0.05, (0, -0.15, 0), mat(WHITE))


def icon_globe():
    sphere(0.85, (0, 0, 0), mat((70, 160, 255)))
    for x, z, s in ((-0.3, 0.3, 0.32), (0.35, -0.15, 0.28), (0.0, -0.55, 0.22)):
        sphere(s, (x, -0.72 + abs(x) * 0.25, z), mat((100, 210, 90)), scale=(1, 0.35, 0.8))


def icon_music():
    ink = mat((150, 80, 230))
    for x, z in ((-0.45, -0.55), (0.45, -0.35)):
        sphere(0.32, (x, 0, z), ink, scale=(1.2, 0.8, 0.9), rot=(0, -20, 0))
        cube((0.12, 0.12, 1.3), (x + 0.3, 0, z + 0.62), ink, 0.03)
    cube((1.0, 0.16, 0.3), (0.3, 0, 0.98), ink, 0.05, rot=(0, -12, 0))


def icon_speaker():
    grey = mat((70, 75, 95))
    cube((0.5, 0.6, 0.7), (-0.55, 0, 0), grey, 0.08)
    cyl(0.75, 0.6, (-0.05, 0, 0), grey, rot=(0, 90, 0), r2=0.3)
    for r in (0.55, 0.85):
        arc(r, 0.07, -50, 50, (0.15, 0, 0), mat((90, 210, 255)))


ICONS = {name[5:]: fn for name, fn in list(globals().items()) if name.startswith("icon_")}


# ---------------------------------------------------------------- render
def fit_and_light():
    meshes = [o for o in bpy.context.scene.objects if o.type in ("MESH", "FONT")]
    bpy.context.view_layer.update()
    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    for o in meshes:
        for c in o.bound_box:
            w = o.matrix_world @ Vector(c)
            lo = Vector(map(min, lo, w))
            hi = Vector(map(max, hi, w))
    centre = (lo + hi) / 2
    k = 2.0 / max(hi - lo)
    t = Matrix.Scale(k, 4) @ Matrix.Translation(-centre)
    for o in meshes:
        if o.parent is None:
            o.matrix_world = t @ o.matrix_world

    scene = bpy.context.scene
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.location = (1.6, -6.0, 2.0)
    direction = Vector((0, 0, 0)) - cam.location
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 58
    scene.camera = cam
    for loc, energy, size in (((-3, -4, 5), 900, 4), ((4, -2, 1), 300, 3), ((0, 4, 3), 500, 2)):
        light = bpy.data.objects.new("Light", bpy.data.lights.new("Light", "AREA"))
        light.data.energy = energy
        light.data.size = size
        light.location = loc
        light.rotation_euler = (Vector((0, 0, 0)) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
        scene.collection.objects.link(light)
    world = bpy.data.worlds.new("W")
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.9, 0.95, 1, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.7
    scene.world = world
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 32
    scene.render.film_transparent = True
    scene.render.resolution_x = scene.render.resolution_y = RES
    scene.view_settings.view_transform = "Standard"


def main():
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
    out = args[0]
    only = args[1].split(",") if len(args) > 1 else None
    os.makedirs(out, exist_ok=True)
    for name, build in ICONS.items():
        if only and name not in only:
            continue
        clear()
        _mats.clear()
        build()
        fit_and_light()
        bpy.context.scene.render.filepath = os.path.join(out, f"icon_{name}.png")
        bpy.ops.render.render(write_still=True)
        print("icon", name)


main()
