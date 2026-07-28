# Path to Sims-like fidelity (free / open only)

**Goal:** raise art, animation, and tooling quality using **CC0, public domain, and open-source tools only**.  
**Not claimed:** pixel-for-pixel Sims 4 parity (EA art + animation + CAS).  
**Claimed:** a legal, practical pipeline that can approach life-sim readability on PC + Android GLES.

## Stack (all free)

| Layer | Resource | License | Use |
|-------|----------|---------|-----|
| **City / buildings** | [Kenney City Kit](https://kenney.nl/assets) (Commercial, Roads, Industrial, Suburban, Modular Buildings) | CC0 | glTF blocks for Little Italy / Hell’s Kitchen |
| **Props / nature** | [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) | CC0 | trees, barrels, street dressing |
| **Characters (base)** | [Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) | CC0 | game-ready humanoids, glTF |
| **Animations** | [Quaternius Universal Animation Library](https://quaternius.com/) + [KayKit Character Animations](https://kaylousberg.itch.io/kaykit-character-animations) | CC0 | walk / idle / interact |
| **Auto-rig** | [Mesh2Motion](https://mesh2motion.org/) (open source) | CC0 tool | rig + pack GLB animations |
| **Textures / HDRI** | [Poly Haven](https://polyhaven.com/) | CC0 | brick, asphalt, sky |
| **glTF samples** | [Khronos glTF-Sample-Assets](https://github.com/KhronosGroup/glTF-Sample-Assets) | varies (many CC0/CC-BY) | pipeline tests |
| **3D registry** | [Open Source 3D Assets](https://opensource3dassets.com/) | CC0 focus | browse GLB packs |
| **Historical photo ref** | [LOC FSA/OWI](https://www.loc.gov/), [NYPL Digital](https://digitalcollections.nypl.org/) | PD / check item | 1930s NYC mood boards, not 1980s scrapes |
| **Engine format** | glTF 2.0 / GLB | open standard | single format for PC + Android |

## Phases

### Phase 0 — now (`0.3.2`)
- Procedural multi-part Sims + **walk bob** (no external mesh yet)
- Asset **manifest** + **fetch script** + credits layout
- Documented free tooling only

### Phase 1 — import pipeline
1. Run `tools/fetch_cc0_assets.sh` (or manual Kenney/Quaternius download)
2. Place GLB under `assets/cc0/` (git-ignored large binaries optional)
3. Implement minimal GLB mesh loader → GPU buffers (Zig)
4. Replace one building + boss proxy with GLB

### Phase 2 — animation
1. Prefer Quaternius/KayKit CC0 clips already in GLB
2. Or Mesh2Motion: import base mesh → export animated GLB
3. Playback: sample node transforms per frame (no Mixamo required)

### Phase 3 — materials
1. Poly Haven albedo (brick, concrete, asphalt) as 2D textures
2. Simple textured lit shader (extend existing fog/rim path)
3. PD LOC stills only as **reference** or heavily processed unique textures — do not ship unlicensed modern photos

### Phase 4 — Android parity
- Same GLB + texture assets in `jniLibs` / APK assets
- GLES shader path already shared; loaders must be pure Zig/C (no desktop-only deps)

## Tools workflow (no paid DCC required)

```
Blender (free) ──export GLB──► assets/cc0/
Mesh2Motion (free, browser/FOSS) ──animate──► character.glb
Kenney / Quaternius ──download──► assets/cc0/
Poly Haven ──albedo PNG──► assets/cc0/textures/
Empire Zig loader ──draw──► PC GL 3.3 + Android GLES 3.0
```

## What we will not use

- Sims / EA ripped assets  
- Paid exclusive marketplace packs without clear redistribution rights  
- Unverified “free” scrapes of modern NYC photography for 1980s era  

## Success metrics (testable)

1. One Kenney building draws in-engine  
2. One Quaternius/KayKit walk cycle on boss  
3. One Poly Haven texture on ground  
4. Same assets load on Android GLES path  
