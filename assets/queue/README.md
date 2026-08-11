# Premium generate queue (Asset Continuum T4)

Runtime writes `*.job.json` here when a recipe has no local mesh.

**Do not block the game on these.** Process on a GPU machine:

```bash
./tools/asset_ensure.sh --process-queue
```

Completed jobs leave meshes under `assets/generated/`. Next engine boot upgrades automatically.
