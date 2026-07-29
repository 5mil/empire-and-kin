# Main loop wiring for 0.5.2 features

Ensure `main.zig` includes:

```zig
const character_map = @import("game/character_map.zig");
const world_map = @import("engine/world_map.zig");
const character_ui = @import("engine/character_ui.zig");
const camera = @import("engine/camera.zig");

var cm = character_map.createDefault();
// Optional era-aware:
// cm = if (era == .nyc_1930s) character_map.create1930s() else character_map.create1980s();
var wmap: world_map.WorldMap = .{};
var char_ui: character_ui.CharUI = .{};
var follow: camera.FollowCam = .{};
var edge_m: input.ButtonEdge = .{};
var edge_c: input.ButtonEdge = .{};
```

Each frame (after poll raw):

```zig
scene.boss_yaw = boss.facing_yaw;
scene.boss_cm = cm;
boss.speed = 5.5 * cm.moveSpeedMul();

world_map.handle(&wmap, raw, &edge_m);
character_ui.handle(&char_ui, raw, &edge_c);

if (raw.bracket_l) follow.adjustZoom(0.025);
if (raw.bracket_r) follow.adjustZoom(-0.025);
if (!wmap.open) {
    if (raw.q) follow.adjustOrbit(0.035);
    // Avoid fighting E-interact: only orbit on held key when not edge-interact
}

const cam = follow.update(boss, in_vehicle, dt);
// pass cam into scene.drawMinimalScene(..., cam, ...)

// When map or character sheet open, freeze movement
const ui_blocking = wmap.open or char_ui.open;

if (!ui_blocking) {
    // normal move / interact / jobs
}

// After scene draw:
world_map.draw(gfx, wmap, boss, jobs_slice);
character_ui.draw(gfx, char_ui, cm);
```

Orbit on Q/E conflicts with interact E — prefer map zoom Q/E only while map open; camera orbit on Q/E only when map closed and prefer brackets for zoom.
