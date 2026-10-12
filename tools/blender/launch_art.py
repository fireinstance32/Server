"""Game icon and thumbnails for the store page (docs/Design/Launch Kit),
rendered from the game's own part-built frogs and pets.

    cd tools/luau-check && node dump-pets.mjs --frogs > models.json
    python tools/blender/launch_art.py models.json <out_dir>

Writes icon_raw.png (1024²) and thumb1_raw.png / thumb2_raw.png (1920×1080);
tools/textures/launch_text.py adds the titles.
"""

import json
import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "preview"))
import partmodels  # noqa: E402
from partmodels import M, build_model  # noqa: E402

args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
MODELS = {(m["kind"], m["id"]): m for m in json.load(open(args[0]))}
OUT = args[1]
os.makedirs(OUT, exist_ok=True)


def lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def mat(name, rgb, rough=0.5, metal=0.0, emit=0.0):
    m = bpy.data.materials.new(name)
    b = m.node_tree.nodes.get("Principled BSDF")
    col = tuple(lin(c) for c in rgb)
    b.inputs["Base Color"].default_value = (*col, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*col, 1)
        b.inputs["Emission Strength"].default_value = emit
    return m


def roblox(x, y, z):
    """Roblox coords -> Blender coords."""
    return M @ Vector((x, y, z))


def turn_y(deg):
    a = math.radians(deg)
    return Matrix(((math.cos(a), 0, math.sin(a)), (0, 1, 0), (-math.sin(a), 0, math.cos(a))))


def reset(sky_top, sky_bottom):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    partmodels.materials.clear()
    partmodels.decal_materials.clear()
    scene = bpy.context.scene
    world = bpy.data.worlds.new("Sky")
    nodes, links = world.node_tree.nodes, world.node_tree.links
    bg = nodes["Background"]
    grad = nodes.new("ShaderNodeTexGradient")
    coord = nodes.new("ShaderNodeTexCoord")
    sep = nodes.new("ShaderNodeSeparateXYZ")
    ramp = nodes.new("ShaderNodeValToRGB")
    links.new(coord.outputs["Window"], sep.inputs[0])
    links.new(sep.outputs["Y"], ramp.inputs["Fac"])
    ramp.color_ramp.elements[0].color = (*[lin(c) for c in sky_bottom], 1)
    ramp.color_ramp.elements[1].color = (*[lin(c) for c in sky_top], 1)
    links.new(ramp.outputs["Color"], bg.inputs["Color"])
    bg.inputs["Strength"].default_value = 1.0
    del grad
    scene.world = world
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 3.2
    sun.data.angle = math.radians(8)
    sun.rotation_euler = (math.radians(50), math.radians(-15), math.radians(-35))
    scene.collection.objects.link(sun)
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 48
    scene.view_settings.view_transform = "Standard"
    return scene


def water(size, z=-0.55):
    bpy.ops.mesh.primitive_plane_add(size=size, location=(0, 0, z))
    bpy.context.active_object.data.materials.append(mat("Water", (70, 180, 255), rough=0.08))


def bank(x0, x1, side, width=30, z=-0.45):
    # Grass strip along the river (Roblox z = side), as a thin box.
    cx = (x0 + x1) / 2
    bpy.ops.mesh.primitive_cube_add(size=1, location=roblox(cx, z - 0.5, side * (2.6 + width / 2)))
    obj = bpy.context.active_object
    obj.scale = (x1 - x0, width, 1)
    obj.data.materials.append(mat("Grass", (110, 205, 90), rough=0.8))


def lily_pad(x, z, r=0.9):
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=r, depth=0.08, location=roblox(x, -0.5, z))
    pad = bpy.context.active_object
    pad.data.materials.append(mat("Pad", (80, 185, 70), rough=0.6))
    # Notch: a dark wedge
    bpy.ops.mesh.primitive_cube_add(size=1, location=roblox(x + r * 0.55, -0.45, z))
    notch = bpy.context.active_object
    notch.scale = (r * 0.9, 0.02, 0.12)
    notch.data.materials.append(mat("Notch", (60, 140, 55)))


def ripple(x, z, r):
    bpy.ops.mesh.primitive_torus_add(major_radius=r, minor_radius=0.04, location=roblox(x, -0.52, z))
    bpy.context.active_object.data.materials.append(mat("Ripple", (225, 245, 255), emit=0.4))


def sparkle(x, y, z, s, color=(255, 230, 90)):
    bpy.ops.mesh.primitive_ico_sphere_add(radius=s, subdivisions=1, location=roblox(x, y, z))
    bpy.context.active_object.data.materials.append(mat("Spark", color, emit=3))


def camera(location, target, lens, w, h, out):
    scene = bpy.context.scene
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.location = location
    cam.rotation_euler = (Vector(target) - Vector(location)).to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = lens
    scene.camera = cam
    scene.render.resolution_x, scene.render.resolution_y = w, h
    scene.render.filepath = out
    bpy.ops.render.render(write_still=True)
    print("Rendered", out)


# ---- Icon: crowned frog mid-hop over a splashing pad --------------------------
reset((95, 185, 255), (190, 235, 255))
water(80)
lily_pad(0, 0, 1.3)
ripple(0, 0, 1.6)
ripple(0, 0, 2.3)
build_model(MODELS[("frog", "Royal")], (0.0, 1.35, 0.0), turn=turn_y(-25))
for x, y, z, s in ((-1.3, 2.3, -0.4, 0.09), (1.2, 2.6, -0.6, 0.07), (-0.9, 0.9, -0.9, 0.06), (1.4, 1.0, -0.3, 0.08)):
    sparkle(x, y, z, s)
camera(roblox(0.9, 2.0, -5.6), roblox(0, 1.25, 0), 42, 1024, 1024, os.path.join(OUT, "icon_raw.png"))

# ---- Thumbnail 1: hopping down the river with pets ------------------------------
reset((80, 170, 255), (200, 235, 255))
water(300)
bank(-20, 120, 1)
bank(-20, 120, -1)
for i in range(18):
    lily_pad(i * 3.0, 0)
hero = MODELS[("frog", "Golden")]
for k, (x, y) in enumerate(((6.0, 2.6), (3.0, 1.0))):
    build_model(hero if k == 0 else MODELS[("frog", "Tree")], (x, y, 0), turn=turn_y(-90 + 20))
for x in (5.0, 2.0):
    ripple(x - 1.0, 0, 1.2)
pets = ["PebblePup", "ReedFox", "CloverBun", "PondPanda"]
for i, pid in enumerate(pets):
    build_model(MODELS[("pet", pid)], (-1.5 + i * 2.2, -0.35, -4.2), turn=turn_y(-30))
for x, y in ((7.2, 3.2), (6.6, 3.6), (5.4, 3.0), (7.6, 2.4)):
    sparkle(x, y, 0.2, 0.08)
camera(roblox(1.5, 3.6, -11.5), roblox(5.0, 1.0, 0), 30, 1920, 1080, os.path.join(OUT, "thumb1_raw.png"))

# ---- Thumbnail 2: pet collection --------------------------------------------------
reset((255, 190, 230), (255, 235, 245))
bpy.ops.mesh.primitive_plane_add(size=80, location=(0, 0, -0.5))
bpy.context.active_object.data.materials.append(mat("Plaza", (126, 214, 104), rough=0.8))
lineup = ["SwampDragon", "CandyUnicorn", "GalaxyCat", "PrismDragon", "NebulaDragon", "InfernoDragon", "SpookyDragon"]
for i, pid in enumerate(lineup):
    x = (i - 3) * 1.6
    zback = abs(i - 3) * 0.6
    build_model(MODELS[("pet", pid)], (x, 0.0, zback), turn=turn_y(x * 6))
for i in range(14):
    sparkle(-5.5 + i * 0.85, 1.4 + (i % 3) * 0.5, 1.2, 0.06, (255, 255, 255))
camera(roblox(0, 1.6, -9.0), roblox(0, 0.25, 0.6), 34, 1920, 1080, os.path.join(OUT, "thumb2_raw.png"))
