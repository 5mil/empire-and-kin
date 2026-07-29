# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.4.0-alpha`  
**Stack:** Zig · GLFW + OpenGL 3.3 (PC) · GLES 3.0 path (Android)

**Mesh/skins:** GLB loader + JOINTS/WEIGHTS + CPU skinning (bind pose). Drop CC0 GLB under `assets/cc0/` — see [`docs/MESH_SKINS.md`](docs/MESH_SKINS.md).

Not Sims 4 / Second Life product parity — open pipeline toward comparable *technical* mesh readiness.

## Windows build

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## CC0 character mesh

```bash
./tools/fetch_cc0_assets.sh
# Download Quaternius character → assets/cc0/characters/character.glb
```

## Docs

- [`docs/MESH_SKINS.md`](docs/MESH_SKINS.md)  
- [`docs/FIDELITY_PIPELINE.md`](docs/FIDELITY_PIPELINE.md)  
- [`docs/VISUAL.md`](docs/VISUAL.md)  
