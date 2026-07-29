# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.4.2-alpha`  
**Stack:** Zig · GLFW + OpenGL 3.3 · GLES path

## Auto-fetch free meshes (WSL / Linux / macOS)

```bash
chmod +x tools/fetch_cc0_assets.sh
./tools/fetch_cc0_assets.sh
```

Pulls Kenney city/car/nature packs, Poly Haven sample models, and Khronos loader tests into `assets/cc0/`. See [`tools/fetch_cc0_assets.md`](tools/fetch_cc0_assets.md).

## Headless playtest

```bash
zig build run-headless
```

## GPU (Linux / WSL)

```bash
sudo apt install -y libglfw3-dev libgl1-mesa-dev
zig build -Dgpu=true -Doptimize=ReleaseFast
./zig-out/bin/empire
```

## Docs

- [`docs/RESOURCE_SYSTEM.md`](docs/RESOURCE_SYSTEM.md)
- [`docs/MESH_SKINS.md`](docs/MESH_SKINS.md)
- [`assets/catalog.json`](assets/catalog.json)
