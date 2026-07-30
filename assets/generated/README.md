# Generated assets (TRELLIS.2 and bake output)

Place **image-to-3D** and other offline-generated game assets here.

## Layout

```
assets/generated/
  vehicles/
  buildings/
  props/
  characters/
  environment/
```

Each asset folder should contain at least:

- `*.glb` — textured mesh
- `meta.json` — source image, tool, seed, notes

## Pipeline

See **`docs/ART_GENERATION_PIPELINE.md`**.

Quick path:

```bash
python tools/run_trellis_image_to_3d.py \
  --image path/to/legal_concept.png \
  --out assets/generated/props/my_prop \
  --name my_prop
```

`ResourceManager` scans this tree for `.glb` (same as `assets/cc0/`).

## Rules

- Input images must be owned, CC0, or public domain.
- Log shipped files in `assets/CREDITS.md`.
- Large binaries may be git-ignored; keep `meta.json` in repo.
