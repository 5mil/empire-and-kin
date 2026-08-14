# Phase 3 — Real people (skinned mesh path)

**Status:** code path complete. Visual quality depends on character GLBs under `assets/cc0/characters`.

## Honest scope

| Claim | Reality |
|-------|---------|
| Full Sims 4 / SL avatars | **No** — no CAS, no cloth, no high-res face maps |
| What we ship | Character **GLB** when present; **walk bob** + facing; CharacterMap tint/scale; **8** street peds; procedural multi-box **fallback** |
| Animation clips | Not yet — bind-pose mesh + procedural bob. Clip sampling is next engineering step |

## What shipped

| Piece | Role |
|-------|------|
| `model_registry` | Up to 16 character variants; boss prefers first character |
| `Backend.drawCharacter` | pos + yaw + scale + tint → mesh or false |
| `sim_actor.drawBossMapped` | Mesh first (suit tint, height×bulk scale, bob); else multi-box limbs |
| `sim_actor.drawPedVariant` | Mesh variants hashed by position; walk bob + yaw |
| `peds.StreetPeds` | 8 walkers, velocity facing, mesh/procedural |
| `anim.meshBobY` / `yawFromVelocity` | Shared walk helpers |

## Assets

```bash
# Drop any CC0 character GLB (Quaternius recommended):
#   assets/cc0/characters/*.glb
# Khronos samples also tag as character (CesiumMan, RiggedSimple):
./tools/fetch_cc0_assets.sh --samples-only
```

Manual: Quaternius Universal Base Characters (CC0) → extract GLBs into `assets/cc0/characters/`.

## Playtest

```bash
git pull
zig build -Dgpu=true -Doptimize=ReleaseFast
zig build run -Dgpu=true
```

Console:
```
[models] cache=N chars=… variants=K …
```

- `variants ≥ 1` → boss and peds use mesh + bob when walking  
- `variants = 0` → multi-box humanoids (still animated limbs)  
- Character map **C** still drives suit tint / height when mesh is used  

## Exit criteria

- [x] drawCharacter on GL + GLES + Null  
- [x] Boss prefers character mesh; CharacterMap scale/tint apply  
- [x] Walk bob when moving; idle when stopped  
- [x] ≥8 peds with mesh or procedural walk  
- [ ] Full glTF animation clip playback — **next**  
- [ ] GPU skinning palette — later  

## Next

**Phase 4 — Real cars** (Kenney car kit meshes + wheel spin).
