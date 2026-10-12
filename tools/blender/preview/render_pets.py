"""Renders part-built pets (JSON from tools/luau-check/dump-pets.mjs) as a
grid, so Roblox part models can be reviewed without Studio.

    python tools/blender/preview/render_pets.py pets.json out.png [cols] [id,id,...]
    python tools/blender/preview/render_pets.py pets.json --icons <dir>   (one PNG per model)
"""

import json
import math
import sys

import os

import bpy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
data = json.load(open(args[0]))
ICON_DIR = args[2] if args[1] == "--icons" else None
out = args[1]
cols = int(args[2]) if len(args) > 2 and not ICON_DIR else 11
if len(args) > 3 and not ICON_DIR:  # optional comma-separated pet ids for a close-up
    wanted = args[3].split(",")
    data = [p for p in data if p["id"] in wanted]

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

from partmodels import M, Vector, build_model, material  # noqa: E402

SPACING = 2.2


def lights():
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 3
    sun.rotation_euler = (math.radians(-50), math.radians(20), math.radians(160))
    scene.collection.objects.link(sun)
    world = bpy.data.worlds.new("Sky")
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.55, 0.75, 0.9, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 1.0
    scene.world = world
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"


if ICON_DIR:
    # One transparent 3/4-view render per model, for the UI image sheets.
    os.makedirs(ICON_DIR, exist_ok=True)
    lights()
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 2.3
    yaw, pitch = math.radians(28), math.radians(16)
    cam.location = (20 * math.sin(yaw), 20 * math.cos(yaw), 20 * math.sin(pitch) + 0.05)
    cam.rotation_euler = (math.radians(90) - pitch, 0, math.radians(180) - yaw)
    scene.camera = cam
    scene.cycles.samples = 24
    scene.render.film_transparent = True
    scene.view_settings.view_transform = "Standard"
    scene.render.resolution_x = scene.render.resolution_y = 256
    for pet in data:
        for obj in [o for o in scene.objects if o.type == "MESH"]:
            bpy.data.objects.remove(obj, do_unlink=True)
        build_model(pet, (0, 0, 0), False)
        scene.render.filepath = os.path.join(ICON_DIR, f"{pet.get('kind', 'pet')}_{pet['id']}.png")
        bpy.ops.render.render(write_still=True)
        print("icon", pet["id"])
    sys.exit(0)

for index, pet in enumerate(data):
    col, row = index % cols, index // cols
    # Roblox coords; the camera looks along +Z, so columns run toward -X to read left to right.
    build_model(pet, (-col * SPACING, 0, -row * SPACING * 1.25), True)

rows = math.ceil(len(data) / cols)
width = (cols - 1) * SPACING
height = (rows - 1) * SPACING * 1.25
cx, cz = -width / 2, -height / 2
cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
scene.collection.objects.link(cam)
cam.data.type = "ORTHO"
cam.data.ortho_scale = max(width, height * 1600 / 1100) + 2.4
# Pets face Roblox -Z = Blender +Y; look from +Y, a little above and to the side.
yaw = math.radians(20)
cam.location = (cx + 30 * math.sin(yaw), 30 * math.cos(yaw), cz + 8)
cam.rotation_euler = (math.radians(76), 0, math.radians(180) - yaw)
scene.camera = cam
lights()
scene.cycles.samples = 32
scene.render.resolution_x, scene.render.resolution_y = 1600, 1100
scene.render.filepath = out
bpy.ops.render.render(write_still=True)
print("Rendered", out)
