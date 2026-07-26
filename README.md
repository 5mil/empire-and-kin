# Empire & Kin

**New York City mob life** — 1930s / 1980s · real-time free-roam + empire.

**Version:** `0.1.4-alpha`  
**Stack:** Zig 0.16 · GLFW + OpenGL 3.3

## Agency map (Little Italy)

| Spot | Key | Effect |
|------|-----|--------|
| Cyan poles | E | Jobs (stay in radius) |
| Green club | E / R | Heal / bribe $500 |
| Brown fence ~(24,16) | E | Cool heat / clear star |
| Stash crate ~(4,26) | E | Bank $250 off books |
| White Doc ~(20,26) | E | Full heal $300 |
| Purple numbers ~(6,12) | E | Bet $100 |
| Esc menu | 1–5 / R / F | Orders, collect, upgrade |

## Build (Windows from WSL)

```bash
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

## Docs

[`docs/HANDOVER.md`](docs/HANDOVER.md)
