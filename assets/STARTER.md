# Maximum starter GLBs in GitHub

Do **not** commit Kenney/Poly Haven packs. GitHub hard-blocks files over **100 MB**, warns over **50 MB**, and this repo should stay under **~20 MB of binaries** so clones stay fast.

## The maximum set that belongs in git

| Slot | File | Cap | Why |
|------|------|-----|-----|
| Loader smoke | `assets/cc0/props/khronos_Box.glb` | ~2 KB | Proves ResourceManager |
| Building | 1 Kenney commercial/suburban GLB | **≤ 400 KB** | One real facade |
| Vehicle | 1 Kenney car-kit sedan GLB | **≤ 400 KB** | One real car |
| Prop | 1 Kenney nature/furniture GLB (tree or crate) | **≤ 200 KB** | Sidewalk dressing |
| Character | *none unless Quaternius dropped in locally* | — | itch, not CDN |

**Hard budget:** 4 files, **&lt; 1.5 MB combined**. That is the most we should ever commit.

Anything else lives in `assets/.cache/` from:

```bash
./tools/fetch_cc0_assets.sh --starter
```

`--starter` downloads Kenney zips to cache, then copies only the smallest GLBs until **15 MB** of extracted files (still local, still gitignored).

## Gitignore

`assets/.cache/` and bulk `assets/cc0/**/*.glb` except the four named starters if you add them by hand.
