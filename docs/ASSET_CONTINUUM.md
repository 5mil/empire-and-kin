# Asset Continuum — never blank, upgrade toward premium

**Problem:** Open-world games die when a mesh is missing (pink checkerboards, empty lots, crash).
**Empire & Kin rule:** Every visual request **always draws something**, then **upgrades** when better data appears.

This is the project’s unique asset policy: a **fidelity ladder** with semantic **recipes** and an offline **premium generate queue**.

---

## The ladder (resolve order)

```
T0  Procedural (in binary)     texture_bank tiles, box/prim geometry, tint
T1  Runtime cache              ResourceManager already-loaded GPU meshes
T2  Local disk                 assets/cc0/** + assets/generated/**
T3  Catalog fetch              tools/fetch_cc0_assets.sh (Kenney, Quaternius, Poly Haven)
T4  Premium generate queue     recipe → TRELLIS.2 / Material Maker job → assets/generated/
```

| Tier | When it runs | Latency | Quality |
|------|----------------|---------|---------|
| T0 | Always | 0 | “readable city” |
| T1 | After first load | 0 | Kit / generated mesh |
| T2 | Boot scan | ms | Same, from disk |
| T3 | Dev / CI / first install | minutes | Bulk CC0 volume |
| T4 | Offline GPU machine | minutes–hours | Custom period pieces |

**Runtime never blocks on network or AI.** T3/T4 happen outside the frame loop.

---

## Unique piece: Recipe cards

Assets are not only file paths. They are **recipes** — stable semantic IDs the game asks for:

```json
{
  "id": "bld.tenement.brick.mid.01",
  "kind": "building",
  "era": "nyc_1930s",
  "footprint": { "w": 5.0, "h": 7.0, "d": 4.0 },
  "style": ["brick", "fire_escape", "water_tower_optional"],
  "fallback": {
    "material": "brick",
    "prim": "box_building"
  },
  "prefer": [
    "assets/cc0/buildings/kenney_city_building_*.glb",
    "assets/generated/buildings/tenement_brick_mid_01/*.glb"
  ],
  "generate": {
    "tool": "trellis2",
    "prompt": "1930s NYC brick tenement building, orthographic front three-quarter, plain background, game-ready prop",
    "res": 512,
    "out": "assets/generated/buildings/tenement_brick_mid_01"
  }
}
```

Cityscape / vehicles / props reference **recipe ids**, not fragile absolute paths.

Resolve path for a recipe:

1. If any `prefer` path is in ResourceManager → draw mesh (T1/T2)
2. Else glob `prefer` on disk → load → draw (T2)
3. Else draw `fallback.prim` + `fallback.material` from texture_bank (T0)
4. Else enqueue `generate` into `assets/queue/` if not already queued (T4 job for later)

After a T4 job finishes, the next boot finds the GLB under `prefer` and **silently upgrades**.

---

## Premium generation (T4)

“Premium” here means **custom, period-locked, TRELLIS/Material-Maker output** — not paid storefront assets.

### Queue format (`assets/queue/<recipe_id>.job.json`)

```json
{
  "recipe_id": "bld.tenement.brick.mid.01",
  "status": "pending",
  "created_utc": "2026-08-11T18:00:00Z",
  "tool": "trellis2",
  "prompt": "...",
  "out": "assets/generated/buildings/tenement_brick_mid_01",
  "res": 512
}
```

Worker (dev machine):

```bash
./tools/asset_ensure.sh --process-queue
# for each pending job:
#   python tools/run_trellis_image_to_3d.py ...
#   write meta.json + mark job status=done
```

Concept images can be:
- PD historical refs (LOC/NYPL) processed to clean orthographic plates
- FLUX generations from the recipe prompt (legal self-host)
- Hand sketches

---

## Always-available guarantees

| Visual | Guaranteed by |
|--------|----------------|
| Streets / sidewalks | T0 texture_bank + Phase 1 GL sample |
| Building masses | T0 box building **or** T1/T2 GLB via `drawBuilding` |
| Safehouse | Same continuum |
| Cars / props | T0 colored prims → Kenney → TRELLIS |
| Characters | T0 procedural humanoid → Quaternius |

Pink void is a **bug**, not a valid state.

---

## Debug: tier telemetry

Optional overlay / log line per frame budget:

```
[continuum] drawn=128 mesh=12 prim=116 queue_pending=3
```

Or per object in debug mode: tint outline by tier (green = mesh, yellow = prim, cyan = just upgraded).

---

## Engine modules

| File | Role |
|------|------|
| `src/engine/gfx/asset_resolve.zig` | Recipe resolve → mesh id or procedural fallback |
| `assets/recipes/*.json` | Semantic cards |
| `assets/queue/` | Pending T4 jobs |
| `tools/asset_ensure.sh` | Fetch T3 + process T4 queue |
| `tools/run_trellis_image_to_3d.py` | Premium mesh worker |

`model_registry` / `ResourceManager` remain the T1/T2 cache. Continuum sits **above** them.

---

## Why this is unique for this project

1. **Binary-complete T0** — ships playable with zero downloads  
2. **Recipes** — art direction language shared by code, fetch, and AI  
3. **Upgrade without redesign** — same footprint, better mesh next boot  
4. **Legal by construction** — T4 only from owned/PD/open prompts  
5. **No runtime AI tax** — phone/PC frames never wait on TRELLIS  

---

## Adoption steps

1. Keep Phase 1–2 drawing as today (T0 + opportunistic T1/T2)  
2. Add recipe files for the densest cityscape rows  
3. Point cityscape at recipe ids  
4. Run `asset_ensure.sh` on a GPU box overnight for empty `prefer` slots  
5. Ship builds that improve as `assets/generated` fills  

See also: `docs/ART_GENERATION_PIPELINE.md`, `docs/PHASE2_MESH_CITY.md`, `assets/catalog.json`.
