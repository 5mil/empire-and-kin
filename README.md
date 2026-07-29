# Empire & Kin

**NYC mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.5.0-alpha`

**Open world:** Multi-avenue grid (~−20…90 X, −10…70 Z), 40+ buildings, denser street dressing, more job poles.

## Build (WSL / Linux GPU)

```bash
git pull
sudo apt install -y libglfw3-dev libgl1-mesa-dev
zig build -Dgpu=true -Doptimize=ReleaseFast
./zig-out/bin/empire
```

## Windows cross from WSL

```bash
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Assets

```bash
./tools/fetch_cc0_assets.sh
```

## Docs

- [`docs/RESOURCE_SYSTEM.md`](docs/RESOURCE_SYSTEM.md)
- [`docs/MESH_SKINS.md`](docs/MESH_SKINS.md)
