"""Renders part-built pets (JSON from tools/luau-check/dump-pets.mjs) as a
grid, so Roblox part models can be reviewed without Studio.

    python tools/blender/preview/render_pets.py pets.json out.png [cols] [id,id,...]
"""

import json
import math
import sys

import bpy
from mathutils import Matrix, Vector

import os

args = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else sys.argv[1:]
TEXTURES = os.path.join(os.path.dirname(__file__), "../../../assets/textures/pets")
data = json.load(open(args[0]))
out = args[1]
cols = int(args[2]) if len(args) > 2 else 11
if len(args) > 3:  # optional comma-separated pet ids for a close-up
    wanted = args[3].split(",")
    data = [p for p in data if p["id"] in wanted]

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

# Roblox (x, y up, z) -> Blender (x, -z, y).
M = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))
SPACING = 2.2
materials = {}


def material(rgb, alpha):
    key = (round(rgb[0], 3), round(rgb[1], 3), round(rgb[2], 3), round(alpha, 2))
    if key in materials:
        return materials[key]
    mat = bpy.data.materials.new(str(key))
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*lin, 1)
    bsdf.inputs["Roughness"].default_value = 0.6
    bsdf.inputs["Alpha"].default_value = 1 - alpha
    materials[key] = mat
    return mat


# Decal faces in a part's own Roblox axes: normal, image-right, image-up.
FACES = {
    "Front": ((0, 0, -1), (-1, 0, 0), (0, 1, 0)),
    "Back": ((0, 0, 1), (1, 0, 0), (0, 1, 0)),
    "Right": ((1, 0, 0), (0, 0, -1), (0, 1, 0)),
    "Left": ((-1, 0, 0), (0, 0, 1), (0, 1, 0)),
    "Top": ((0, 1, 0), (1, 0, 0), (0, 0, -1)),
    "Bottom": ((0, -1, 0), (1, 0, 0), (0, 0, 1)),
}
decal_materials = {}


def decal_material(name, tint):
    key = (name, tuple(round(c, 3) for c in tint))
    if key in decal_materials:
        return decal_materials[key]
    mat = bpy.data.materials.new(f"Decal_{name}")
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    bsdf.inputs["Roughness"].default_value = 0.6
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(os.path.join(TEXTURES, f"{name}.png"), check_existing=True)
    mix = nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in tint]
    mix.inputs["B"].default_value = (*lin, 1)
    links.new(tex.outputs["Color"], mix.inputs["A"])
    links.new(mix.outputs["Result"], bsdf.inputs["Base Color"])
    links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    decal_materials[key] = mat
    return mat


def add_decal(obj, size, decal):
    normal, right, up = (Vector(v) for v in FACES[decal["face"]])
    half = Vector(size) / 2
    centre = Vector((normal.x * half.x, normal.y * half.y, normal.z * half.z)) * (1 + 0.004 * decal["z"] / max(half))
    wr = abs(right.dot(Vector(size))) / 2
    hu = abs(up.dot(Vector(size))) / 2
    corners = [centre - right * wr - up * hu, centre + right * wr - up * hu, centre + right * wr + up * hu, centre - right * wr + up * hu]
    corners = [c + normal * 0.003 * decal["z"] for c in corners]
    mesh = bpy.data.meshes.new("Decal")
    mesh.from_pydata([tuple(c) for c in corners], [], [(0, 1, 2, 3)])
    uv = mesh.uv_layers.new()
    for loop, coord in zip(uv.data, [(0, 0), (1, 0), (1, 1), (0, 1)]):
        loop.uv = coord
    plane = bpy.data.objects.new("Decal", mesh)
    scene.collection.objects.link(plane)
    plane.data.materials.append(decal_material(decal["name"], decal["color"]))
    plane.parent = obj  # same Roblox-local axes as the part


for index, pet in enumerate(data):
    col, row = index % cols, index // cols
    # Roblox coords; the camera looks along +Z, so columns run toward -X to read left to right.
    origin = (-col * SPACING, 0, -row * SPACING * 1.25)
    for part in pet["parts"]:
        sx, sy, sz = part["size"]
        shape = part["shape"]
        if shape == "Ball":
            d = min(sx, sy, sz)
            bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=d / 2)
        elif shape == "Cylinder":
            bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=min(sy, sz) / 2, depth=sx)
            obj = bpy.context.active_object
            obj.rotation_euler = (0, math.pi / 2, 0)  # Roblox cylinders run along X
            bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
        else:
            bpy.ops.mesh.primitive_cube_add(size=1)
            obj = bpy.context.active_object
            obj.scale = (sx, sy, sz)
            bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        obj = bpy.context.active_object
        r = part["rot"]
        R = Matrix(((r[0], r[1], r[2]), (r[3], r[4], r[5]), (r[6], r[7], r[8])))
        rot = M @ R
        p = part["pos"]
        pos = M @ Vector((p[0] + origin[0], p[1] + origin[2], p[2] + origin[1]))
        # Vertices are in the part's own Roblox axes: world = M · (R·v + p).
        mw = rot.to_4x4()
        mw.translation = pos
        obj.matrix_world = mw
        obj.data.materials.append(material(part["color"], part["alpha"]))
        for decal in part.get("decals", []):
            add_decal(obj, (sx, sy, sz), decal)
        if shape != "Block":
            bpy.ops.object.shade_smooth()
    label = bpy.data.curves.new(f"Label{index}", "FONT")
    label.body = f"{pet['name']}\n({pet['look']})"
    label.align_x = "CENTER"
    label.size = 0.2
    text = bpy.data.objects.new(f"Label{index}", label)
    text.location = M @ Vector((origin[0], origin[2] - 0.85, -0.6))
    text.rotation_euler = (math.radians(90), 0, math.radians(180))
    text.data.materials.append(material((0.1, 0.12, 0.1), 0))
    scene.collection.objects.link(text)

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
scene.cycles.samples = 32
scene.render.resolution_x, scene.render.resolution_y = 1600, 1100
scene.render.filepath = out
bpy.ops.render.render(write_still=True)
print("Rendered", out)
