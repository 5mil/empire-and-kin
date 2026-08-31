# Godot 4 editor app (phone)

## Get the project on the device

1. On the phone browser / Git client, open  
   https://github.com/5mil/empire-and-kin  
2. Download **ZIP** of `main` (or clone with a Git app).
3. Unzip. You need the **`godot/`** folder (the one that contains `project.godot`).

## Open in the editor

1. Launch **Godot 4** on the phone.
2. **Import** → browse to `godot/project.godot`.
3. Open the project.
4. Open `scenes/main.tscn` if it is not the main scene already.
5. Press **Play** (▶).

## Touch controls (this branch)

On a touchscreen the overlay appears automatically:

| Control | Action |
|---------|--------|
| **Left side drag** | Move |
| **Right side drag** | Look |
| **E** button | Interact / enter·exit car |
| **SPRINT** | Hold to run |

Desktop keyboard/mouse still works when not on a touch device.

## Expectations

- Phone editor is fine for **smoke-testing** the slice.
- Heavy peds/lights may hitch on low-end devices — lower counts in `street_life.gd` if needed.
- Full production play still means **Android export from a PC** later.

## Branch

Use **`main`** (Godot path). Zig prototype remains on **`BETA`**.
