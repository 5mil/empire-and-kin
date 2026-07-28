# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.3.2-alpha`  
**Stack:** Zig · GLFW + OpenGL 3.3 (PC) · GLES 3.0 path (Android)

Life-sim readability + **free CC0 art/animation pipeline** (Kenney, Quaternius, Poly Haven, Mesh2Motion).  
Not EA Sims 4 parity — see [`docs/VISUAL.md`](docs/VISUAL.md) and [`docs/FIDELITY_PIPELINE.md`](docs/FIDELITY_PIPELINE.md).

- [`docs/HANDOVER.md`](docs/HANDOVER.md)  
- [`docs/ART_SOURCES.md`](docs/ART_SOURCES.md)  
- [`assets/manifest.json`](assets/manifest.json) — approved free packs  
- [`tools/fetch_cc0_assets.sh`](tools/fetch_cc0_assets.sh) — prepare download dirs  

## Windows build (WSL)

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Free assets

```bash
chmod +x tools/fetch_cc0_assets.sh
./tools/fetch_cc0_assets.sh
# then download Kenney / Quaternius / Poly Haven into assets/cc0/
```

## Android

```bash
zig build run-android
zig build android-lib -Doptimize=ReleaseFast
```
