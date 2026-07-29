# Auto-fetch CC0 assets

```bash
chmod +x tools/fetch_cc0_assets.sh
./tools/fetch_cc0_assets.sh
```

## What is automated

| Source | Method |
|--------|--------|
| Kenney City Roads / Commercial / Suburban / Industrial | Direct ZIP from `kenney.nl/media/...` |
| Kenney Car Kit | Same |
| Kenney Nature Kit | Same |
| Poly Haven models (default 8) | Public API → glTF package |
| Khronos Box / Duck / CesiumMan / RiggedSimple | GitHub raw GLB |

## Options

```bash
./tools/fetch_cc0_assets.sh --kenney-only
./tools/fetch_cc0_assets.sh --polyhaven-only --poly-limit 20
./tools/fetch_cc0_assets.sh --no-samples
```

## Still manual (itch)

- Kenney All-in-1 (huge)
- Quaternius Universal Base Characters
- Kenney Character Assets (rigged skins)

## Notes

- Kenney CDN hashes change when packs update; if a download 404s, open the asset page on kenney.nl and update the URL in the script.
- Requires: `curl`, `unzip`, `python3` (for Poly Haven).
- Binaries stay local under `assets/cc0/` and `assets/.cache/` — not committed to git.
