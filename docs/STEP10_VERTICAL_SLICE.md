# Step 10 — Expanded Vertical Slice

## Goal

One **demo-ready loop** with **save/load on disk**.

```
Boot → (optional load) → free-roam → job → empire pause → vehicle
     → wanted/police → F5 save → F9 load → exit writes disk save
```

## Slice beats

| Beat | What happens |
|------|----------------|
| 1. Boot | Era 1930s, starter crew/rackets/properties/fleet |
| 2. Load | If `empire_save.txt` exists, restore state |
| 3. Walk | Move toward job marker |
| 4. Job | E → Speakeasy Delivery → cash + heat |
| 5. Empire | Esc → Rackets/Crew/Properties/Vehicles |
| 6. Drive | Enter sedan, drive |
| 7. Heat | Wanted stars + police banner |
| 8. Save | F5 / F9 quick save-load |
| 9. Exit | Auto write `empire_save.txt` |

## Disk format

File: `empire_save.txt` (key=value, human-readable)

## Controls

WASD move · E job/vehicle · Esc menu · **F5** save · **F9** load
