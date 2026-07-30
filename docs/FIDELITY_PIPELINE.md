# Path to Sims-like fidelity (free / open only)

**Goal:** raise art, animation, and tooling quality using **CC0, public domain, and open-source tools only**.  
**Not claimed:** pixel-for-pixel Sims 4 parity (EA art + animation + CAS).  
**Claimed:** a legal, practical pipeline that can approach life-sim readability on PC + Android GLES.

## Stack (all free)

| Layer | Resource | License | Use |
|-------|----------|---------|-----|
| **City / buildings** | [Kenney City Kit](https://kenney.nl/assets) | CC0 | glTF blocks for Little Italy / Hell’s Kitchen |
| **Props / nature** | [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) | CC0 | trees, barrels, street dressing |
| **Characters (base)** | [Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) | CC0 | game-ready humanoids, glTF |
| **Animations** | [Quaternius Universal Animation Library](https://quaternius.com/) + [KayKit Character Animations](https://kaylousberg.itch.io/kaykit-character-animations) | CC0 | walk / idle / interact |
| **Auto-rig** | [Mesh2Motion](https://mesh2motion.org/) (open source) | CC0 tool | rig + pack GLB animations |
| **Textures / HDRI** | [Poly Haven](https://polyhaven.com/) | CC0 | brick, asphalt, sky |
| **Image → 3D** | **TRELLIS.2** (Microsoft) | MIT | Custom props / vehicles / facades from legal images |
| **PBR materials** | Material Maker + CHORD | MIT / open | Procedural and estimated PBR sets |
| **glTF samples** | [Khronos glTF-Sample-Assets](https://github.com/KhronosGroup/glTF-Sample-Assets) | varies | pipeline tests |
| **Historical photo ref** | [LOC FSA/OWI](https://www.loc.gov/), [NYPL Digital](https://digitalcollections.nypl.org/) | PD / check item | 1930s NYC mood boards |
| **Engine format** | glTF 2.0 / GLB | open standard | single format for PC + Android |

## Phases

### Phase 0 — now
- Procedural multi-part character + walk bob
- Asset **manifest** + **fetch script** + credits layout
- Documented free tooling only
- TRELLIS.2 offline pipeline documented (`docs/ART_GENERATION_PIPELINE.md`)

### Phase 1 — import pipeline
1. Run `tools/fetch_cc0_assets.sh` (or manual Kenney/Quaternius download)
2. Place GLB under `assets/cc0/` (git-ignored large binaries optional)
3. Generate custom pieces with TRELLIS → `assets/generated/`
4. GLB mesh loader → GPU buffers (Zig) — exists
5. Replace one building + prop with GLB

### Phase 2 — animation
1. Prefer Quaternius/KayKit CC0 clips already in GLB
2. Or Mesh2Motion: import base mesh → export animated GLB
3. Playback: sample node transforms per frame

### Phase 3 — materials
1. Poly Haven / Material Maker albedo as 2D textures
2. Textured lit shader (extend existing fog/rim path)
3. PD LOC stills only as **reference** or heavily processed unique textures

### Phase 4 — Android parity
- Same GLB + texture assets in APK assets
- GLES shader path already shared; loaders pure Zig/C

## Tools workflow (no paid DCC required)

```
Blender (free) ──export GLB──► assets/cc0/ or assets/generated/
TRELLIS.2 (MIT) ──image→GLB──► assets/generated/
Mesh2Motion ──animate──► character.glb
Kenney / Quaternius ──download──► assets/cc0/
Poly Haven / Material Maker ──albedo PNG──► assets/cc0/textures/
Empire Zig loader ──draw──► PC GL 3.3 + Android GLES 3.0
```

## What we will not use

- Sims / EA ripped assets  
- Paid exclusive marketplace packs without clear redistribution rights  
- Unverified “free” scrapes of modern NYC photography for 1980s era  
- Copyrighted game screenshots as TRELLIS input  

## Success metrics (testable)

1. One Kenney building draws in-engine  
2. One TRELLIS-generated prop draws from `assets/generated/`  
3. One Quaternius/KayKit walk cycle on boss  
4. One Poly Haven / procedural texture on ground  
5. Same assets load on Android GLES path  
