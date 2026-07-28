//! Procedural humanoid — maximum box fidelity toward Sims readability.
//! Not skinned meshes / CAS; shared on PC GL and Android GLES.
const backend = @import("backend.zig");

fn shadow(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    gfx.drawBox(.{ .x = x, .y = 0.025, .z = z }, w, 0.04, d, backend.Color.rgb(12, 12, 14));
}

/// Stacked green diamond (plumbob cue) above selected Sim.
pub fn drawPlumbob(gfx: backend.Backend, x: f32, z: f32, y_base: f32) void {
    const g = backend.Color.rgb(70, 230, 120);
    const g2 = backend.Color.rgb(40, 180, 90);
    gfx.drawBox(.{ .x = x, .y = y_base, .z = z }, 0.28, 0.14, 0.28, g);
    gfx.drawBox(.{ .x = x, .y = y_base + 0.18, .z = z }, 0.18, 0.14, 0.18, g2);
    gfx.drawBox(.{ .x = x, .y = y_base + 0.34, .z = z }, 0.1, 0.1, 0.1, g);
}

pub fn drawBoss(gfx: backend.Backend, x: f32, z: f32) void {
    shadow(gfx, x, z, 0.95, 0.8);

    const skin = backend.Color.rgb(218, 178, 148);
    const suit = backend.Color.rgb(32, 38, 55);
    const shirt = backend.Color.rgb(240, 240, 245);
    const pants = backend.Color.rgb(24, 26, 36);
    const hair = backend.Color.rgb(28, 24, 22);
    const shoe = backend.Color.rgb(18, 16, 14);
    const belt = backend.Color.rgb(50, 40, 30);

    // Legs (thigh + calf)
    gfx.drawBox(.{ .x = x - 0.15, .y = 0.55, .z = z }, 0.2, 0.7, 0.26, pants);
    gfx.drawBox(.{ .x = x + 0.15, .y = 0.55, .z = z }, 0.2, 0.7, 0.26, pants);
    gfx.drawBox(.{ .x = x - 0.15, .y = 0.22, .z = z + 0.02 }, 0.18, 0.35, 0.24, pants);
    gfx.drawBox(.{ .x = x + 0.15, .y = 0.22, .z = z + 0.02 }, 0.18, 0.35, 0.24, pants);
    // Shoes
    gfx.drawBox(.{ .x = x - 0.15, .y = 0.07, .z = z + 0.08 }, 0.22, 0.12, 0.38, shoe);
    gfx.drawBox(.{ .x = x + 0.15, .y = 0.07, .z = z + 0.08 }, 0.22, 0.12, 0.38, shoe);
    // Hips / belt
    gfx.drawBox(.{ .x = x, .y = 0.95, .z = z }, 0.52, 0.18, 0.32, belt);
    // Torso + collar shirt peek
    gfx.drawBox(.{ .x = x, .y = 1.4, .z = z }, 0.58, 0.75, 0.36, suit);
    gfx.drawBox(.{ .x = x, .y = 1.55, .z = z + 0.12 }, 0.28, 0.2, 0.08, shirt);
    // Shoulders
    gfx.drawBox(.{ .x = x - 0.42, .y = 1.65, .z = z }, 0.22, 0.22, 0.28, suit);
    gfx.drawBox(.{ .x = x + 0.42, .y = 1.65, .z = z }, 0.22, 0.22, 0.28, suit);
    // Upper / lower arms
    gfx.drawBox(.{ .x = x - 0.48, .y = 1.35, .z = z }, 0.15, 0.4, 0.16, suit);
    gfx.drawBox(.{ .x = x + 0.48, .y = 1.35, .z = z }, 0.15, 0.4, 0.16, suit);
    gfx.drawBox(.{ .x = x - 0.5, .y = 1.05, .z = z }, 0.14, 0.32, 0.14, suit);
    gfx.drawBox(.{ .x = x + 0.5, .y = 1.05, .z = z }, 0.14, 0.32, 0.14, suit);
    // Hands
    gfx.drawBox(.{ .x = x - 0.5, .y = 0.82, .z = z }, 0.13, 0.12, 0.13, skin);
    gfx.drawBox(.{ .x = x + 0.5, .y = 0.82, .z = z }, 0.13, 0.12, 0.13, skin);
    // Neck + head
    gfx.drawBox(.{ .x = x, .y = 1.88, .z = z }, 0.16, 0.16, 0.16, skin);
    gfx.drawBox(.{ .x = x, .y = 2.18, .z = z }, 0.4, 0.46, 0.38, skin);
    // Ears
    gfx.drawBox(.{ .x = x - 0.24, .y = 2.18, .z = z }, 0.08, 0.12, 0.1, skin);
    gfx.drawBox(.{ .x = x + 0.24, .y = 2.18, .z = z }, 0.08, 0.12, 0.1, skin);
    // Hair + sideburns
    gfx.drawBox(.{ .x = x, .y = 2.42, .z = z }, 0.42, 0.12, 0.4, hair);
    gfx.drawBox(.{ .x = x, .y = 2.28, .z = z - 0.12 }, 0.4, 0.2, 0.12, hair);
    // Eyes (dark dots)
    gfx.drawBox(.{ .x = x - 0.1, .y = 2.22, .z = z + 0.18 }, 0.06, 0.05, 0.04, backend.Color.rgb(20, 20, 25));
    gfx.drawBox(.{ .x = x + 0.1, .y = 2.22, .z = z + 0.18 }, 0.06, 0.05, 0.04, backend.Color.rgb(20, 20, 25));

    drawPlumbob(gfx, x, z, 2.72);
}

/// Street ped with skin/suit variation index 0..3.
pub fn drawPed(gfx: backend.Backend, x: f32, z: f32, suit: backend.Color) void {
    drawPedVariant(gfx, x, z, suit, 0);
}

pub fn drawPedVariant(gfx: backend.Backend, x: f32, z: f32, suit: backend.Color, variant: u8) void {
    shadow(gfx, x, z, 0.75, 0.6);
    const skins = [_]backend.Color{
        backend.Color.rgb(210, 170, 140),
        backend.Color.rgb(180, 130, 100),
        backend.Color.rgb(230, 195, 165),
        backend.Color.rgb(140, 100, 75),
    };
    const skin = skins[variant % 4];
    const pants = backend.Color.rgb(45, 45, 55);
    const shoe = backend.Color.rgb(25, 22, 20);
    const hair = backend.Color.rgb(30, 25, 22);

    gfx.drawBox(.{ .x = x - 0.12, .y = 0.45, .z = z }, 0.17, 0.75, 0.22, pants);
    gfx.drawBox(.{ .x = x + 0.12, .y = 0.45, .z = z }, 0.17, 0.75, 0.22, pants);
    gfx.drawBox(.{ .x = x - 0.12, .y = 0.08, .z = z + 0.05 }, 0.18, 0.12, 0.3, shoe);
    gfx.drawBox(.{ .x = x + 0.12, .y = 0.08, .z = z + 0.05 }, 0.18, 0.12, 0.3, shoe);
    gfx.drawBox(.{ .x = x, .y = 1.2, .z = z }, 0.48, 0.7, 0.3, suit);
    gfx.drawBox(.{ .x = x - 0.32, .y = 1.15, .z = z }, 0.12, 0.55, 0.14, suit);
    gfx.drawBox(.{ .x = x + 0.32, .y = 1.15, .z = z }, 0.12, 0.55, 0.14, suit);
    gfx.drawBox(.{ .x = x, .y = 1.7, .z = z }, 0.14, 0.12, 0.14, skin);
    gfx.drawBox(.{ .x = x, .y = 1.95, .z = z }, 0.34, 0.38, 0.32, skin);
    gfx.drawBox(.{ .x = x, .y = 2.16, .z = z }, 0.36, 0.1, 0.34, hair);
}
