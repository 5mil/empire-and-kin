# Main loop wiring for 0.5.1 features

If `main.zig` was not fully auto-merged, add:

```zig
const character_map = @import("game/character_map.zig");
const world_map = @import("engine/world_map.zig");
const character_ui = @import("engine/character_ui.zig");

var cm = character_map.createDefault();
var wmap: world_map.WorldMap = .{};
var char_ui: character_ui.CharUI = .{};
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

if (raw.bracket_l) follow.adjustZoom(0.02);
if (raw.bracket_r) follow.adjustZoom(-0.02);
if (!wmap.open) {
    if (raw.q) follow.adjustOrbit(0.03);
    if (raw.e and !edge_interact...) follow.adjustOrbit(-0.03); // careful with E interact
}

// When wmap.open or char_ui.open, skip player move (or force paused)
if (wmap.open or char_ui.open) {
    // draw scene + overlays only
}

world_map.draw(gfx, wmap, boss, &jobs);
character_ui.draw(gfx, char_ui, cm);
```

Orbit on Q/E conflicts with interact E — prefer map zoom Q/E only while map open; camera orbit on `[`/`]` zoom only if needed.
