# Phase 4 — Real cars (meshes + wheels)

**Status:** code path complete. Visual quality depends on vehicle GLBs under `assets/cc0/vehicles` (Kenney Car Kit).

## Honest scope

| Claim | Reality |
|-------|---------|
| Separate body + wheel GLBs with animation | **Partial** — body GLB when present; **procedural box wheels** always (spin + front steer) |
| Full damage deformation | **No** — health darkens tint only |
| Physics body roll / suspension | Phase 5 |

## What shipped

| Piece | Role |
|-------|------|
| `model_registry` | Up to 16 vehicle variants; `vehicle_gpu_at` hash by position |
| `Backend.drawVehicle(pos, yaw, wheel_spin, steer, health, color)` | Mesh body + 4 wheels or false |
| `vehicle_def.zig` | Wheel layouts / body scales per `VehicleType` |
| `action.Vehicle` | `yaw`, `wheel_spin`, `steer`; drive updates spin + steer + damage on wall |
| `scene` parked + player car | Prefer mesh |
| `traffic` | Mesh cars with spinning wheels |
| Procedural fallback | Box body + cabin + wheels never blank |

## Assets

```bash
./tools/fetch_cc0_assets.sh --kenney-only
# or drop Kenney Car Kit GLBs into:
#   assets/cc0/vehicles/*.glb
```

## Playtest

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

Console:
```
[models] … veh=N veh_var=K …
```

- `veh_var ≥ 1` → parked, traffic, and player car use mesh body + spinning wheels  
- `veh_var = 0` → procedural boxes (still spin/steer when driving)  
- Enter vehicle, drive: wheels rotate; steer input yaws front wheels  

## Exit criteria

- [x] drawVehicle on GL + GLES + Null  
- [x] Vehicle variant pool + ResourceManager category  
- [x] Wheels rotate while moving; front wheels steer  
- [x] Parked cars on streets prefer mesh  
- [x] Player / traffic cars prefer mesh; exit leaves vehicle in world  
- [x] Health darkens tint  
- [ ] Distinct mesh per VehicleType (sedan/truck/taxi/moto) — improves as more Kenney GLBs land  
- [ ] Separate wheel GLB assets — optional later  

## Next

**Phase 5 — Driving physics** (raycast suspension, grip curve, body lean).
