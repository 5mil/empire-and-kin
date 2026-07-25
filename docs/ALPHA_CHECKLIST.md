# Alpha Checklist (A9)

## Must pass

- [x] Boot title → New Game → era select → play
- [x] Continue path when `empire_save.txt` exists
- [x] Three world jobs (bootleg / protection / smuggle)
- [x] Job complete pays cash and raises heat
- [x] Empire pause: rackets, crew, properties, vehicles
- [x] Vehicle enter / exit / drive
- [x] Wanted stars + police / chase feedback
- [x] Live events (raid, informant, etc.) on timer
- [x] Rival pressure chips district control
- [x] Street combat can spawn at high heat
- [x] F5 / F9 + quit write disk save
- [x] Onboarding tips (H / X)
- [x] Headless NullBackend demo runs without panic

## Known alpha limits

- No real GPU window (NullBackend / console)
- Save does not yet persist full racket/property arrays (position, cash, heat, wanted, time)
- Combat is stub resolution
- Art is placeholders (PD sources listed in ART_SOURCES.md)

## How to run

```bash
zig build run
```
