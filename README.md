# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.4.1-alpha`  
**Stack:** Zig · GLFW + OpenGL 3.3 · GLES path

**Resources:** `ResourceManager` caches up to 256 GLB meshes from `assets/cc0/**` (characters, buildings, vehicles, props). CC0 catalog in [`assets/catalog.json`](assets/catalog.json).

```bash
./tools/fetch_cc0_assets.sh
# Download Kenney All-in-1 / Quaternius / Poly Haven → assets/cc0/
```

- [`docs/RESOURCE_SYSTEM.md`](docs/RESOURCE_SYSTEM.md)  
- [`docs/MESH_SKINS.md`](docs/MESH_SKINS.md)  
- [`docs/FIDELITY_PIPELINE.md`](docs/FIDELITY_PIPELINE.md)  

## Windows GPU build

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```
