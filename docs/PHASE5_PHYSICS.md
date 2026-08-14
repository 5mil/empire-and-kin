# Phase 5 — Driving physics (raycast vehicle)

**Status:** **shipped in 0.6.0-alpha**. Pure Zig — no PhysX / Bullet.  
Compile blockers fixed: `renderer.drawVehicle` pitch/roll orient, `main` handbrake via `raw.shift`.

## Honest scope

| Claim | Reality |
|-------|---------|
| Full 3D suspension mesh collision | **No** — rays vs flat ground `y=0`; body pitch/roll are visual |
| Pacejka tire model | **Simplified** grip clamp + lateral damping |
| Separate surface materials under each wheel | **Partial** — asphalt default; dirt hooks later |
| Multi-body deformation | **No** — health still darkens tint |

## What shipped

| Piece | Role |
|-------|------|
| `vehicle_phys.zig` | Integrate: throttle/brake, steer, lateral grip, handbrake oversteer, spring-damper pitch/roll |
| `PhysTuning` per `VehicleType` | Mass, power, brake, grip, spring, yaw inertia, arcade assist |
| `action.Vehicle` | `vx/vz`, `yaw_rate`, `body_y`, `pitch`, `roll`, `vy` |
| `action.drive` | Calls `vehicle_phys.integrate` |
| `Backend.drawVehicle` | Extra `pitch`, `roll` for mesh lean |
| Handbrake | **Shift** while driving → rear grip drop, controllable slide |
| Wall hit | Velocity bounce + health damage (not teleport) |

## Controls (in vehicle)

| Input | Effect |
|-------|--------|
| W / S (or stick Y) | Throttle / reverse-brake |
| A / D (or stick X) | Steer |
| Shift | Handbrake (slide) |
| E | Exit |

## Playtest

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

1. Enter sedan (E near Black Sedan).
2. Accelerate — note weight; brake — nose dips.
3. Turn at speed — body rolls.
4. Hold **Shift** + steer mid-turn — rear steps out.
5. Hit a building — speed bleeds, health ticks down, no teleport.
6. Try truck vs motorcycle — different power / grip / lean.

## Exit criteria

- [x] Acceleration / braking differ by vehicle type  
- [x] Body rolls on turn; nose dives on brake (mesh tilt)  
- [x] Handbrake induces controllable slide  
- [x] Hit wall → speed loss + bounce, not teleport  
- [ ] Surface grip asphalt vs dirt_alley — next polish  
- [ ] Per-wheel GLB compression animation — optional  

## Next

**Phase 6 — Vehicle telemetry HUD** (speed, RPM, gear, slip, damage dials).
