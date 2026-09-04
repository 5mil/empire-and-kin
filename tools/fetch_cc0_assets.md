# Fetch public CC0 GLBs (BETA)

Git does **not** store the packs (too large). Run this on the machine that builds the game:

```bash
cd ~/empire-and-kin
git checkout BETA && git pull
chmod +x tools/fetch_cc0_assets.sh
./tools/fetch_cc0_assets.sh
```

## Automated (no login)

| Pack | Dest |
|------|------|
| Kenney City Roads / Commercial / Suburban / Industrial | buildings + environment |
| Kenney Modular Buildings | buildings |
| Kenney Car Kit + Train Kit | vehicles |
| Kenney Nature / Furniture / Food | props |
| Poly Haven models (24, urban-scored) | props |
| Khronos Box / Cube / Triangle | props (loader smoke) |

```bash
./tools/fetch_cc0_assets.sh --kenney-only
./tools/fetch_cc0_assets.sh --polyhaven-only --poly-limit 40
```

## Manual (characters)

Quaternius + Kenney character packs are itch-only. Drop `.glb` into `assets/cc0/characters/`.

`model_registry` scans those folders at GPU init and swaps boxes for meshes when files exist.
