# main.zig size policy

**Rule:** entry files pushed via GitHub Contents API should stay under ~8 KB.

| File | Role | Target size |
|------|------|-------------|
| `src/main.zig` | Bootstrap only | < 1 KB |
| `src/engine/session.zig` | Session entry | < 1 KB |
| `src/engine/session_run.zig` | Full play loop | large — push via `push_files` or git |
| `src/engine/gfx/renderer.zig` | GPU draw | large — prefer surgical patches |

Phase 5 handbrake lives in `session_run.zig` (`raw.shift` → `action.drive`).
Phase 5 body lean lives in `renderer.drawVehicle(…, pitch, roll, …)`.
