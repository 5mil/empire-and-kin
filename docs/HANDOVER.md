# Empire & Kin — Handover

**Version:** `0.1.5-alpha`  
**Repo:** https://github.com/5mil/empire-and-kin  
**Zig:** 0.16 · GPU Windows path stable

## This batch (steps ~21–100)

Agency density on one Little Italy block:

| System | Status |
|--------|--------|
| Jobs (4) + choice + radius cancel | Wired |
| Safehouse / bribe / fence / stash | Wired |
| Doc / numbers bank | Wired |
| Loan / tip / lookout | Wired |
| Street events / news / banter / weather | Wired |
| Rival / goals / expanded save | Wired |
| Score / compass / minimap S / HP bar | Wired |
| Ambush / patrol / soundtrack | Modules ready |

## First playtest after pull

```bash
git pull && rm -rf .zig-cache zig-out
export GLFW_WIN=$HOME/glfw-3.4.bin.WIN64
zig build -Dtarget=x86_64-windows-gnu -Dgpu=true \
  -Dglfw_prefix=$GLFW_WIN -Doptimize=ReleaseFast
```

Paste any compile errors — fix pass is next if needed.

See also: `docs/CONTROLS.md`, `docs/ROADMAP.md`.

**End of handover.**
