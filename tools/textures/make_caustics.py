"""Tileable water caustics (reference: bright blue water with wobbly light
lines). White lines on a transparent background; the game lays it over the
water parts as a scrolling Texture (Config/UiImages.Ids.caustics).

    python tools/textures/make_caustics.py [out.png]

Lines are the borders of a jittered Voronoi diagram (distance to the nearest
cell edge, F2 - F1), warped a little so they wobble, on a wrapping grid so
the image tiles seamlessly.
"""

import sys

import numpy as np
from PIL import Image

SIZE = 512
CELLS = 6  # cells per side
SEED = 7


def caustics(size: int, cells: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    points = (np.stack(np.meshgrid(np.arange(cells), np.arange(cells), indexing="ij"), -1) + rng.uniform(0.15, 0.85, (cells, cells, 2))) / cells
    points = points.reshape(-1, 2)

    v = np.linspace(0, 1, size, endpoint=False)
    y, x = np.meshgrid(v, v, indexing="ij")
    # Wobble: a gentle periodic warp (whole periods so it still tiles).
    wx = x + 0.018 * np.sin(2 * np.pi * (3 * y + 0.2)) + 0.01 * np.sin(2 * np.pi * (7 * y + 2 * x))
    wy = y + 0.018 * np.sin(2 * np.pi * (3 * x + 0.6)) + 0.01 * np.sin(2 * np.pi * (5 * x + 3 * y))

    f1 = np.full((size, size), 9.0)
    f2 = np.full((size, size), 9.0)
    for px, py in points:
        dx = np.abs(wx - px)
        dy = np.abs(wy - py)
        dx = np.minimum(dx, 1 - dx)  # wrap
        dy = np.minimum(dy, 1 - dy)
        d = np.sqrt(dx * dx + dy * dy)
        f2 = np.where(d < f1, f1, np.minimum(f2, d))
        f1 = np.minimum(f1, d)
    edge = (f2 - f1) * cells  # 0 on a cell border
    line = np.clip(1 - edge / 0.09, 0, 1) ** 1.6
    glow = np.clip(1 - edge / 0.3, 0, 1) ** 3 * 0.25
    return np.clip(line + glow, 0, 1)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "assets/textures/water/caustics.png"
    alpha = caustics(SIZE, CELLS, SEED)
    rgba = np.zeros((SIZE, SIZE, 4), np.uint8)
    rgba[..., :3] = 255
    rgba[..., 3] = (alpha * 255).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(out)
    print("wrote", out)


if __name__ == "__main__":
    main()
