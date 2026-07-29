# Real-game visual + driving roadmap

**Version target:** `0.6 → 1.0`  
**Policy:** CC0 / public-domain assets only. No Rockstar, EA, or scraped modern photos.

---

## 0. Honest end-state (read this first)

| Claim | Reality |
|-------|---------|
| “GTA 4 graphic parity” | **Not achievable** on this stack, team size, or legal asset set. GTA 4 used RAGE, sparse virtual texturing, years of hand-authored Liberty City, Euphoria, and a large art department. |
| What we *will* reach | A **mid-2000s open-world crime-game feel**: textured streets, mesh buildings, skinned animated people, multi-mesh cars with wheel motion, raycast driving physics, vehicle instruments (telemetry), traffic, and dense enough props that the city no longer reads as GTA 1 boxes. |
| Closest public reference | GTA San Andreas / early IV *readability*, not IV pixel-for-pixel. Stylized free assets (Kenney / Quaternius / Poly Haven), not photoreal. |

If the goal is literally GTA 4, the correct path is a different engine, a different license strategy, and a multi-year art team. This roadmap stays inside Empire & Kin’s Zig + GL 3.3 / GLES + CC0 constraints and still produces a **real game**.

---

## Current baseline (what “GTA 1” actually is today)

| System | State |
|--------|--------|
| City | Box buildings + procedural material colors + avenue geometry |
| Surfaces | Procedural 64² tiles + shader fBm grain (no GL texture sample yet) |
| Player | Multi-box procedural humanoid + character map tints |
| NPCs | Same procedural ped boxes |
| Cars | Colored boxes; arcade drive (`speed`, `max_speed`, face dir) |
| Physics | Collision resolve only — no suspension, grip curve, or body |
| Telemetry | None (no speedo / RPM / gear / damage dial) |
| Mesh pipeline | GLB loader + CPU skin bind-pose **exists**; anim clips / GPU skin / textures not wired |
| Assets | `tools/fetch_cc0_assets.sh` + `ResourceManager` ready |

Everything below builds on that substrate.

---

## Non-negotiables (every phase)

1. **CC0 / PD only** — Kenney, Quaternius, KayKit, Poly Haven, Khronos samples. Catalog in `assets/catalog.json`.
2. **Backend stays** — game logic never imports GL; `engine.Backend` vtable only.
3. **Android path** — same GLB + texture assets, GLES shaders; no desktop-only deps in loaders.
4. **Measurable exits** — a phase is done when the listed playtest criteria pass on GPU build.
5. **No scope creep into RAGE** — no virtual texturing, no full city streaming rewrite until meshes + physics work.

---

## Phase map (concrete)

```
0.5.x  material identity + maps + character sheet     ← done
─────────────────────────────────────────────────────
1.0    textured surfaces (real GL sample)
2.0    mesh city (Kenney buildings on footprints)
3.0    real people (skinned + animated)
4.0    real cars (meshes + wheels)
5.0    driving physics (raycast vehicle)
6.0    vehicle telemetry HUD
7.0    traffic + street life density
8.0    lighting / LODs / atmosphere polish
─────────────────────────────────────────────────────
1.0 release = “real game” visual + drive feel
```

---

## Phase 1 — Textured surfaces (leave flat color behind)

**Goal:** Streets and facades sample real albedo, not only procedural tint.

### Work
| Item | File / action |
|------|----------------|
| PNG loader (stb-style or pure Zig) | `src/engine/gfx/image.zig` |
| Upload `texture_bank` tiles → GL textures | `texture_bank` + `renderer` / `gl_backend` |
| Optional Poly Haven albedo swap | `assets/cc0/textures/asphalt_*.png` etc. after `fetch_cc0_assets.sh` |
| UVs on ground plane + building sides | `mesh.zig` / ground draw path |
| Shader: sample albedo × grain | `shaders.zig` (`sampler2D uAlbedo`) |

### Exit criteria
- [ ] Ground shows asphalt grain that **tiles** under the player at walking scale  
- [ ] At least one building face uses brick albedo  
- [ ] GLES path still clears and draws (no desktop-only image dep)  
- [ ] Headless / NullBackend still boots  

**Estimate:** 1 focused sprint.

---

## Phase 2 — Mesh city (Kenney on cityscape footprints)

**Goal:** Replace a critical mass of box buildings with GLB city kit pieces.

### Work
| Item | File / action |
|------|----------------|
| Run fetch | `./tools/fetch_cc0_assets.sh --kenney-only` |
| Placement table | `src/engine/cityscape.zig` → each `BuildingSpec` may hold `mesh_id` or category key |
| Draw path | `scene.zig` / `renderer.drawMesh` at building transform |
| Fallback | If no GLB, keep box + material color (never blank world) |
| Props | Lamps, dumpsters, hydrants → Kenney prop GLBs where available |

### Exit criteria
- [ ] ≥ 12 buildings drawn as GLB in one district  
- [ ] Safehouse is a distinct mesh or marked kit piece  
- [ ] Frame stays playable (≥ 30 fps on mid laptop at default zoom)  
- [ ] ResourceManager cache does not exceed budget without eviction policy  

**Estimate:** 1–2 sprints.

---

## Phase 3 — Real people (skinned + animated)

**Goal:** Boss and peds are skinned meshes with walk/idle, not box people.

### Work
| Item | File / action |
|------|----------------|
| Quaternius / KayKit GLB | `assets/cc0/characters/` via fetch or manual itch drop |
| Animation channel sample | `src/engine/gfx/anim_clip.zig` — read glTF animations → joint matrices/frame |
| CPU skin per frame → later GPU palette | extend `skin.zig`; optional `shaders` bone UBO |
| Character map → mesh slots | suit/hair as tint or swap materials; scale from `height_scale` / `bulk_scale` |
| Ped variants | 4–8 palette / mesh variants from one base |
| `sim_actor` path | Prefer mesh; fall back to procedural if load fails |

### Exit criteria
- [ ] Boss walks with skinned legs/arms in free-roam  
- [ ] Idle when stopped  
- [ ] ≥ 8 peds on street using mesh + simple path or wander  
- [ ] Character map **C** still shows; colors/scale still apply  

**Estimate:** 2 sprints (anim graph is the hard part).

---

## Phase 4 — Real cars (meshes + wheels)

**Goal:** Vehicles look like cars, not stretched boxes.

### Work
| Item | File / action |
|------|----------------|
| Kenney Car Kit GLBs | `assets/cc0/vehicles/` |
| Vehicle def | `src/game/vehicle_def.zig` — mesh id, wheel local offsets, wheel radius |
| Draw | Body mesh + 4 wheel meshes; wheel spin from `omega = speed / radius` |
| Steering visual | Front wheels yaw with input  
| Damage tint | Darken / swap material as `health` drops |
| Garage / fleet UI | Already has panels — bind to real mesh previews later |

### Exit criteria
- [ ] Enter sedan/truck/taxi/motorcycle → each has distinct mesh  
- [ ] Wheels rotate while moving; front wheels steer  
- [ ] Parked cars on streets are mesh, not boxes  
- [ ] Exit vehicle leaves mesh in world  

**Estimate:** 1 sprint after Phase 2 assets exist.

---

## Phase 5 — Driving physics (the “real game” feel)

**Goal:** Cars have weight, grip, and body motion — not instant arcade slide.

### Model (keep pure Zig, no PhysX)

**Raycast vehicle** (standard indie approach, same family as many GTA-likes):

```
per wheel:
  ray down from suspension mount
  spring + damper force along up
  lateral friction (grip curve vs slip angle)
  longitudinal force (accel / brake)
body:
  integrate linear + angular velocity
  apply gravity, drag, downforce-ish term
  collision: existing resolve + bounce impulse
```

### Work
| Item | File / action |
|------|----------------|
| Core sim | `src/game/vehicle_phys.zig` — `Chassis`, `Wheel`, integrate at fixed dt |
| Input map | Throttle / brake / steer / handbrake → forces |
| Surface grip | Asphalt vs dirt_alley from material under ray (query cityscape) |
| Arcade assist | Optional “assist” curve so 1930s era cars stay drivable |
| Replace `action.drive` | Call phys integrate; sync `Vehicle.x/y`, yaw, speed |
| Camera | Existing `FollowCam` — lower FOV slightly at high speed |

### Exit criteria
- [ ] Acceleration and braking feel different by vehicle type  
- [ ] Body rolls on turn; nose dives on brake (visible mesh tilt)  
- [ ] Handbrake induces controllable slide  
- [ ] Hit wall → speed loss + optional bounce, not teleport  
- [ ] Motorcycle more tippy / higher max speed than truck  

**Estimate:** 2 sprints (tuning is most of the time).

---

## Phase 6 — Vehicle telemetry (instruments)

**Goal:** While driving, the player sees real feedback — not just a number in a corner.

### Work
| Item | File / action |
|------|----------------|
| Telemetry state | `src/game/telemetry.zig` — speed mph/kph, RPM, gear, slip, damage, heat |
| Derive | RPM from wheel omega × gear ratio table; gear auto or sequential |
| HUD | `src/engine/vehicle_hud.zig` — speedo arc, RPM bar, gear letter, damage pips, wanted stars when chasing |
| Audio hooks (later) | Engine pitch from RPM (placeholder print / optional SDL later) |
| Era flavor | 1930s analog dials vs 1980s digital strip (same data, different draw) |

### Exit criteria
- [ ] Driving shows speed + RPM + gear updating every frame  
- [ ] Redline flash near max RPM  
- [ ] Damage section reacts to wall hits  
- [ ] HUD hidden on foot; appears on enter  

**Estimate:** 1 sprint (mostly UI + wiring).

---

## Phase 7 — Traffic + street life

**Goal:** The city feels inhabited.

### Work
| Item | File / action |
|------|----------------|
| Traffic sim | `src/game/traffic.zig` — spline or lane graph along avenues; simple follow + stop |
| Spawn budget | Cap active cars / peds; recycle off-camera |
| Ped AI | Wander sidewalks, cross at crosswalks, flee on gunfire / high wanted |
| Ambient | Parked mesh density already in cityscape; add moving traffic |
| Heat interaction | Cops prefer road network; chase uses vehicle phys |

### Exit criteria
- [ ] ≥ 12 moving cars on avenues without tanking FPS  
- [ ] Peds use sidewalks; crosswalks matter  
- [ ] Player can cause traffic pile-up that clears over time  

**Estimate:** 2 sprints.

---

## Phase 8 — Lighting, LODs, atmosphere

**Goal:** Night, distance, and density hold up.

### Work
| Item | File / action |
|------|----------------|
| Day/night already exists | Strengthen lamp contribution; simple blob shadows already present |
| LOD | Distance switch: full mesh → low mesh → box impostor |
| Fog / horizon | Already in lit shader — tune per era |
| Texture mips | Generate or load mip chain for asphalt/brick |
| Optional shadow map | One cascade directional if budget allows |
| Streaming hint | Unload LRU in ResourceManager when > 256 |

### Exit criteria
- [ ] Far blocks do not all draw full mesh  
- [ ] Night lamps actually light nearby facades (even if crude)  
- [ ] No obvious pop when approaching a district  

**Estimate:** 1–2 sprints.

---

## Dependency order (do not skip)

```
Phase 1 (textures)
    ↓
Phase 2 (mesh buildings) ──┐
    ↓                      │
Phase 3 (people)           ├── assets from fetch script
    ↓                      │
Phase 4 (car meshes) ──────┘
    ↓
Phase 5 (physics)  ← needs car mesh transforms + wheel offsets
    ↓
Phase 6 (telemetry) ← needs phys state (RPM, speed, slip)
    ↓
Phase 7 (traffic) ← needs phys + meshes
    ↓
Phase 8 (polish)
```

---

## Explicitly out of scope (forever or until a rewrite)

- Rockstar / GTA mesh or texture rips  
- Full Euphoria-style procedural body physics  
- Photoreal faces / hair cards / cloth sim  
- City-scale streaming equal to Liberty City  
- Online multiplayer telemetry backend  
- Paid marketplace exclusives without redistribution rights  

---

## Success definition for “looks like a real game”

When a new player boots the GPU build and:

1. Sees **textured asphalt and brick**, not flat gray.  
2. Sees **mesh buildings** in at least one full avenue.  
3. Sees a **skinned boss** walk and idle.  
4. Enters a **mesh car**, watches **wheels spin**, feels **weight on turns**.  
5. Reads **speed / RPM / gear** on a driving HUD.  
6. Shares the road with **other cars and walking peds**.  

…then the “GTA 1 boxes” complaint is closed. That is the **1.0 visual + drive bar**.

---

## Immediate next step (start Phase 1)

1. `git pull`  
2. Implement `image.zig` + GL texture upload from `texture_bank.generateTile`  
3. Sample albedo in `lit_frag`  
4. Optional: run `./tools/fetch_cc0_assets.sh` on a machine with network for Poly Haven asphalt/brick  

After Phase 1 ships, Phase 2 (Kenney buildings on footprints) is the largest visible jump.
