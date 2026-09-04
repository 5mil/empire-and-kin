# Phase 7 — Traffic + street life

**Status:** shipped `0.7.0-alpha` on `BETA`.

## Counts

| Layer | Was | Now |
|-------|-----|-----|
| Traffic cars | 4 on one lane | **12** — 8 on the avenue (two directions), 4 on a cross street |
| Peds | 8 wandering the lot | **16** pinned to north/south sidewalks |

Cars wrap when they leave the block (recycle, no spawn spike).
Peds reverse at block ends instead of drifting into the roadway.

## Playtest

```bash
git checkout BETA && git pull
# same Windows cross as Phase 6
```

1. Stand on the sidewalk — peds walk past, not through the car lane.
2. Look down the avenue — two streams of cars, opposite directions.
3. Cross street near x≈14 — extra cars moving along Z.
4. Frame rate still playable on ReleaseFast.

## Next (Phase 8)

Lighting / LODs / atmosphere (`docs/REAL_GAME_ROADMAP.md`).
