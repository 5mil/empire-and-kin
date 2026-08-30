# main.zig size policy

**Rule:** entry files pushed via GitHub Contents API should stay under ~8 KB.

| File | Role | Target size |
|------|------|-------------|
| `src/main.zig` | Bootstrap only | < 1 KB |
| `src/engine/session.zig` | Session entry | < 1 KB |
| `src/engine/session_run.zig` | Full play loop | large — assemble from parts or git push |
| `src/engine/session_run_part0/1/2.zig.txt` | Split of full loop | ~7 KB each |
| `src/engine/gfx/renderer.zig` | GPU draw | large — surgical patches |

## Assemble full game loop

```bash
chmod +x tools/assemble_session.sh
./tools/assemble_session.sh
# or:
cat src/engine/session_run_part0.zig.txt \
    src/engine/session_run_part1.zig.txt \
    src/engine/session_run_part2.zig.txt \
    > src/engine/session_run.zig
```

Checks: `pub fn run`, `while (!gfx.shouldClose())`, `raw.shift` + `action.drive` (handbrake).

Phase 5 handbrake: `session_run` → `action.drive(..., raw.shift, dt)`.
Phase 5 body lean: `renderer.drawVehicle(..., pitch, roll, ...)`.
