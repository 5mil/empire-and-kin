//! Procedural humanoid — still boxes, but readable as a person (Sims-ish silhouette).
const backend = @import("backend.zig");

pub fn drawBoss(gfx: backend.Backend, x: f32, z: f32) void {
    // Contact shadow
    gfx.drawBox(.{ .x = x, .y = 0.03, .z = z }, 0.85, 0.05, 0.7, backend.Color.rgb(15, 15, 18));

    const skin = backend.Color.rgb(210, 170, 140);
    const suit = backend.Color.rgb(35, 40, 55);
    const pants = backend.Color.rgb(28, 30, 40);
    const hair = backend.Color.rgb(25, 22, 20);
    const shoe = backend.Color.rgb(20, 18, 16);

    // Legs
    gfx.drawBox(.{ .x = x - 0.14, .y = 0.45, .z = z }, 0.22, 0.9, 0.28, pants);
    gfx.drawBox(.{ .x = x + 0.14, .y = 0.45, .z = z }, 0.22, 0.9, 0.28, pants);
    // Shoes
    gfx.drawBox(.{ .x = x - 0.14, .y = 0.08, .z = z + 0.05 }, 0.24, 0.14, 0.35, shoe);
    gfx.drawBox(.{ .x = x + 0.14, .y = 0.08, .z = z + 0.05 }, 0.24, 0.14, 0.35, shoe);
    // Torso
    gfx.drawBox(.{ .x = x, .y = 1.25, .z = z }, 0.55, 0.85, 0.35, suit);
    // Arms
    gfx.drawBox(.{ .x = x - 0.38, .y = 1.2, .z = z }, 0.16, 0.7, 0.18, suit);
    gfx.drawBox(.{ .x = x + 0.38, .y = 1.2, .z = z }, 0.16, 0.7, 0.18, suit);
    // Hands
    gfx.drawBox(.{ .x = x - 0.38, .y = 0.78, .z = z }, 0.14, 0.14, 0.14, skin);
    gfx.drawBox(.{ .x = x + 0.38, .y = 0.78, .z = z }, 0.14, 0.14, 0.14, skin);
    // Neck + head
    gfx.drawBox(.{ .x = x, .y = 1.75, .z = z }, 0.18, 0.18, 0.18, skin);
    gfx.drawBox(.{ .x = x, .y = 2.05, .z = z }, 0.42, 0.48, 0.4, skin);
    // Hair plate
    gfx.drawBox(.{ .x = x, .y = 2.32, .z = z }, 0.44, 0.14, 0.42, hair);
    // Plumbob-ish diamond above head (aspiration cue)
    gfx.drawBox(.{ .x = x, .y = 2.7, .z = z }, 0.22, 0.22, 0.22, backend.Color.rgb(80, 220, 120));
}

pub fn drawPed(gfx: backend.Backend, x: f32, z: f32, suit: backend.Color) void {
    gfx.drawBox(.{ .x = x, .y = 0.03, .z = z }, 0.7, 0.04, 0.55, backend.Color.rgb(15, 15, 18));
    const skin = backend.Color.rgb(200, 165, 135);
    gfx.drawBox(.{ .x = x - 0.12, .y = 0.4, .z = z }, 0.18, 0.8, 0.22, backend.Color.rgb(40, 40, 50));
    gfx.drawBox(.{ .x = x + 0.12, .y = 0.4, .z = z }, 0.18, 0.8, 0.22, backend.Color.rgb(40, 40, 50));
    gfx.drawBox(.{ .x = x, .y = 1.15, .z = z }, 0.48, 0.75, 0.3, suit);
    gfx.drawBox(.{ .x = x, .y = 1.85, .z = z }, 0.36, 0.4, 0.34, skin);
}
