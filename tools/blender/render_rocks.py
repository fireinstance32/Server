"""Renders every rock's picture (Rocks tab, Daily rewards, tooltips) from the
same Blender models the game uses, then packs them into the rock sheet.

    blender -b -P tools/blender/render_rocks.py -- <render_dir>
    python tools/textures/pack_icons.py <render_dir> rock_ frogs FrogIconAtlas 128 8

Reads each rock's id, colour and ultimate flag from src/shared/Config/Frogs.luau
and WorldContent/*.luau, and its shape/crown from Config/RockLooks.luau, so
the pictures stay in step with the config. (The sheet keeps its old name,
frogs.png, like the rest of the code.)
"""

import glob
import math
import os
import re
import sys

import bpy
from mathutils import Vector

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "../.."))
sys.path.insert(0, HERE)
rocks_mod = {"__name__": "build_rocks"}
exec(open(os.path.join(HERE, "build_rocks.py")).read(), rocks_mod)
build, srgb = rocks_mod["build"], rocks_mod["srgb"]

RES = 256
CONFIG = os.path.join(REPO, "src/shared/Config")


def read_rocks():
    """[(id, (r, g, b), ultimate)] from Frogs.luau + WorldContent/*.luau."""
    rocks = []
    paths = [os.path.join(CONFIG, "Frogs.luau")] + sorted(glob.glob(os.path.join(CONFIG, "WorldContent/*.luau")))
    for path in paths:
        text = open(path).read()
        # Only the rock lists: Frogs.luau's table, or each world's `frogs = {`.
        # Frogs.luau's list ends at a top-level "}"; world lists are one rock a line.
        blocks = re.findall(r"local Frogs: \{ Frog \} = \{(.*?)\n\}", text, re.S) + re.findall(r"\bfrogs = \{(.*?)\n\t+\}", text, re.S)
        for block in blocks:
            entries = re.split(r'(?=\bid = ")', block)
            for entry in entries:
                m = re.search(r'\bid = "(\w+)"', entry)
                c = re.search(r"color = (?:Color3\.fromRGB|rgb)\((\d+), (\d+), (\d+)\)", entry)
                if m and c:
                    rocks.append((m.group(1), tuple(int(x) for x in c.groups()), "ultimate = true" in entry))
    return rocks


def read_looks():
    text = open(os.path.join(CONFIG, "RockLooks.luau")).read()
    by_rock = dict(re.findall(r'^\t(\w+) = "(Rock\w*)",', text, re.M))
    crowned = set(re.findall(r"^\t(\w+) = true,", text, re.M))
    return by_rock, crowned


def setup(scene):
    scene.render.resolution_x = scene.render.resolution_y = RES
    scene.render.film_transparent = True
    try:
        scene.render.engine = "BLENDER_EEVEE_NEXT"
    except TypeError:
        scene.render.engine = "BLENDER_EEVEE"
    scene.view_settings.view_transform = "Standard"
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.data.type = "ORTHO"
    cam.location = Vector((4.5, -7.5, 4.2))
    cam.rotation_euler = (Vector((0, 0, 0)) - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    key = bpy.data.objects.new("Key", bpy.data.lights.new("Key", "SUN"))
    key.data.energy = 3.2
    key.rotation_euler = (math.radians(40), math.radians(-25), math.radians(20))
    scene.collection.objects.link(key)
    world = bpy.data.worlds.new("Sky")
    world.use_nodes = True
    bg = next(n for n in world.node_tree.nodes if n.type == "BACKGROUND")
    bg.inputs["Color"].default_value = (*srgb(200, 215, 235), 1)
    bg.inputs["Strength"].default_value = 1.1
    scene.world = world
    return cam


def frame(cam, objects):
    lo = Vector((math.inf,) * 3)
    hi = Vector((-math.inf,) * 3)
    for obj in objects:
        if obj.type != "MESH":
            continue
        for corner in obj.bound_box:
            p = obj.matrix_world @ Vector(corner)
            lo = Vector(map(min, lo, p))
            hi = Vector(map(max, hi, p))
    centre = (lo + hi) / 2
    direction = Vector((4.5, -7.5, 4.2)).normalized()
    cam.location = centre + direction * 10
    cam.data.ortho_scale = (hi - lo).length * 0.92


def main():
    args = sys.argv[sys.argv.index("--") + 1 :]
    out = os.path.abspath(args[0])
    os.makedirs(out, exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    cam = setup(scene)
    by_rock, crowned = read_looks()
    for rock_id, rgb, _ultimate in read_rocks():
        shape = by_rock.get(rock_id, "Rock")
        coll = bpy.data.collections.new(rock_id)
        scene.collection.children.link(coll)
        color = srgb(*rgb)
        rock = build(shape, color, coll, seed=shape)
        bpy.context.view_layer.update()
        parts = list(rock.children)
        if rock_id in crowned:
            crown = build("Crown", color, coll, seed="Crown")
            top = max((c.matrix_world @ Vector(v)).z for c in parts for v in c.bound_box)
            crown.scale = (0.6, 0.6, 0.6)
            crown.location = (0, 0, top + 0.18)
            bpy.context.view_layer.update()
            parts += list(crown.children)
        frame(cam, parts)
        scene.render.filepath = os.path.join(out, f"rock_{rock_id}.png")
        bpy.ops.render.render(write_still=True)
        print(f"Rendered rock_{rock_id}.png ({shape})")
        for obj in list(coll.objects):
            bpy.data.objects.remove(obj)
        bpy.data.collections.remove(coll)


main()
