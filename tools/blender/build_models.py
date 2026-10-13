"""Builds the cube-style Frog, Pet and Egg models for +1 Frog Hop.

Run (any machine with Blender's Python module, or `blender -b -P`):
    python tools/blender/build_models.py <out_dir> [--preview <png>]

Writes Pets/Pet.fbx, Eggs/Egg.fbx and Legacy/Frog.fbx (the frog is from
before the Rock Pivot; nothing uses it now). Each model is several meshes whose
object names are the contract with src/shared/Util/Models (the game
recolours them per frog/pet):
    Frog: Body, Belly, Foot (tinted from the frog colour), Eye, Pupil, Mouth
    Pet:  Body, Ear, Foot (tinted from the pet colour), Eye, Shine
    Egg:  Shell (egg colour), Spots (lighter)
Facing: the frog looks along +X, the pet along Blender +Y (Roblox -Z),
matching the part-built placeholders.
"""

import math
import os
import sys

import bpy


def clear():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name, rgb):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.diffuse_color = (*rgb, 1)
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*rgb, 1)
    bsdf.inputs["Roughness"].default_value = 0.55
    return mat


def srgb(r, g, b):
    # Roblox colours are sRGB 0-255; Blender materials are linear.
    def lin(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    return (lin(r), lin(g), lin(b))


def deselect():
    # transform_apply and modifier ops act on every selected object.
    bpy.ops.object.select_all(action="DESELECT")


def box(name, size, location, mat, bevel=0.0, parent=None):
    deselect()
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 3
        mod.limit_method = "NONE"
        bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.ops.object.shade_smooth()
    obj.data.materials.append(mat)
    if parent:
        obj.parent = parent
    return obj


def join(objects, name):
    """Merge same-role pieces (e.g. both eyes) into one mesh named `name`."""
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    if len(objects) > 1:
        bpy.ops.object.join()
    merged = bpy.context.active_object
    merged.name = name
    merged.data.name = name
    return merged


def frog(color, offset=(0, 0, 0), tag=""):
    ox, oy, oz = offset
    body_mat = material(f"FrogBody{tag}", color)
    belly_mat = material(f"FrogBelly{tag}", tuple(c + (1 - c) * 0.6 for c in color))
    foot_mat = material(f"FrogFoot{tag}", tuple(c * 0.75 for c in color))
    white = material("White", srgb(250, 250, 250))
    black = material("Black", srgb(20, 20, 25))
    mouth = material("Mouth", srgb(60, 25, 30))

    parts = [box("Body", (2.0, 2.0, 1.5), (ox, oy, oz), body_mat, bevel=0.35)]
    parts.append(box("Belly", (0.12, 1.3, 0.75), (ox + 1.0, oy, oz - 0.25), belly_mat, bevel=0.05))
    eyes, pupils, feet = [], [], []
    for side in (-1, 1):
        eyes.append(box("Eye", (0.7, 0.7, 0.7), (ox + 0.45, oy + side * 0.5, oz + 0.95), white, bevel=0.15))
        pupils.append(box("Pupil", (0.12, 0.34, 0.38), (ox + 0.82, oy + side * 0.5, oz + 0.95), black, bevel=0.04))
        for fx in (-0.6, 0.6):
            feet.append(box("Foot", (0.65, 0.5, 0.25), (ox + fx, oy + side * 0.75, oz - 0.75), foot_mat, bevel=0.08))
    parts.append(box("Mouth", (0.06, 0.9, 0.08), (ox + 1.0, oy, oz + 0.25), mouth))
    return [
        join([parts[0]], "Body"),
        join([parts[1]], "Belly"),
        join(eyes, "Eye"),
        join(pupils, "Pupil"),
        join(feet, "Foot"),
        join([parts[2]], "Mouth"),
    ]


def pet(color, offset=(0, 0, 0), tag=""):
    ox, oy, oz = offset
    body_mat = material(f"PetBody{tag}", color)
    dark = material(f"PetDark{tag}", tuple(c * 0.7 for c in color))
    white = material("White", srgb(250, 250, 250))
    black = material("Black", srgb(20, 20, 25))

    body = box("Body", (1.6, 1.6, 1.6), (ox, oy, oz), body_mat, bevel=0.3)
    ears, eyes, shines, feet = [], [], [], []
    for side in (-1, 1):
        ears.append(box("Ear", (0.36, 0.22, 0.5), (ox + side * 0.48, oy, oz + 0.98), dark, bevel=0.06))
        eyes.append(box("Eye", (0.32, 0.1, 0.38), (ox + side * 0.36, oy + 0.8, oz + 0.15), black, bevel=0.04))
        shines.append(box("Shine", (0.1, 0.04, 0.1), (ox + side * 0.36 + 0.06, oy + 0.85, oz + 0.25), white))
        for fy in (-0.45, 0.45):
            feet.append(box("Foot", (0.4, 0.4, 0.22), (ox + side * 0.45, oy + fy, oz - 0.88), dark, bevel=0.06))
    return [join([body], "Body"), join(ears, "Ear"), join(eyes, "Eye"), join(shines, "Shine"), join(feet, "Foot")]


def egg(color, offset=(0, 0, 0), tag=""):
    ox, oy, oz = offset
    shell_mat = material(f"EggShell{tag}", color)
    spot_mat = material(f"EggSpots{tag}", tuple(c + (1 - c) * 0.55 for c in color))
    deselect()
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=14, radius=1, location=(ox, oy, oz))
    shell = bpy.context.active_object
    shell.scale = (0.78, 0.78, 1.0)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Narrower top, rounder bottom.
    for v in shell.data.vertices:
        if v.co.z > 0:
            f = 1 - 0.18 * v.co.z
            v.co.x *= f
            v.co.y *= f
    bpy.ops.object.shade_smooth()
    shell.data.materials.append(shell_mat)
    spots = []
    for i, (lat, lon, r) in enumerate([(0.3, 0.2, 0.22), (-0.2, 1.4, 0.18), (0.55, 2.6, 0.15), (-0.45, 3.7, 0.2), (0.1, 4.9, 0.17)]):
        x = math.cos(lat) * math.cos(lon) * 0.76
        y = math.cos(lat) * math.sin(lon) * 0.76
        z = math.sin(lat) * 0.98
        deselect()
        bpy.ops.mesh.primitive_uv_sphere_add(segments=10, ring_count=6, radius=r, location=(ox + x, oy + y, oz + z))
        spot = bpy.context.active_object
        spot.scale = (1, 1, 0.45)
        spot.rotation_euler = (0, math.pi / 2 - lat, lon)
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        spot.data.materials.append(spot_mat)
        spots.append(spot)
    return [join([shell], "Shell"), join(spots, "Spots")]


def export(objects, path):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=path,
        use_selection=True,
        apply_unit_scale=True,
        axis_forward="-Z",
        axis_up="Y",
        mesh_smooth_type="FACE",
        bake_space_transform=True,
    )
    tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in objects)
    print(f"Exported {path} ({tris} triangles)")


def preview(path):
    clear()
    lineup = [
        (frog, srgb(120, 200, 90), (0, -9, 0)),
        (frog, srgb(40, 120, 255), (0, -6, 0)),
        (frog, srgb(255, 200, 40), (0, -3, 0)),
        (frog, srgb(170, 110, 230), (0, 0, 0)),
        (pet, srgb(220, 170, 120), (0, 3, -0.15)),
        (pet, srgb(240, 140, 60), (0, 5.5, -0.15)),
        (pet, srgb(120, 230, 255), (0, 8, -0.15)),
        (egg, srgb(245, 245, 245), (0, 10.8, 0.05)),
        (egg, srgb(255, 120, 200), (0, 13.3, 0.05)),
    ]
    for i, (build, color, offset) in enumerate(lineup):
        objects = build(color, offset, tag=str(i))
        if build is pet:
            # Pets face Blender +Y in the game; turn them toward the camera here.
            pivot = bpy.data.objects.new(f"Pivot{i}", None)
            pivot.location = offset
            bpy.context.scene.collection.objects.link(pivot)
            bpy.context.view_layer.update()
            for obj in objects:
                obj.parent = pivot
                obj.matrix_parent_inverse = pivot.matrix_world.inverted()
            pivot.rotation_euler = (0, 0, -math.pi / 2)
    scene = bpy.context.scene
    bpy.ops.mesh.primitive_plane_add(size=80, location=(0, 2, -0.9))
    bpy.context.active_object.data.materials.append(material("Ground", srgb(150, 215, 120)))
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.location = (25, 2.2, 7.5)
    cam.rotation_euler = (math.radians(74), 0, math.radians(90))
    cam.data.lens = 32
    scene.camera = cam
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 3.5
    sun.rotation_euler = (math.radians(40), math.radians(10), math.radians(60))
    scene.collection.objects.link(sun)
    world = bpy.data.worlds.new("Sky")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (*srgb(150, 210, 255), 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.9
    scene.world = world
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 48
    scene.render.resolution_x, scene.render.resolution_y = 1280, 560
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print(f"Rendered {path}")


def main():
    args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
    out = args[0]
    for folder, name, build, color in [
        ("Legacy", "Frog", frog, srgb(120, 200, 90)),
        ("Pets", "Pet", pet, srgb(220, 170, 120)),
        ("Eggs", "Egg", egg, srgb(245, 245, 245)),
    ]:
        clear()
        os.makedirs(f"{out}/{folder}", exist_ok=True)
        export(build(color), f"{out}/{folder}/{name}.fbx")
    if "--preview" in args:
        preview(args[args.index("--preview") + 1])


main()
