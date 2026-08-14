//! Humanoid actors — prefer character GLB (Phase 3), fall back to multi-box procedural.
const std = @import("std");
const backend = @import("backend.zig");
const anim = @import("anim.zig");
const character_map = @import("../game/character_map.zig");

fn shadow(gfx: backend.Backend, x: f32, z: f32, w: f32, d: f32) void {
    gfx.drawBox(.{ .x = x, .y = 0.025, .z = z }, w, 0.04, d, backend.Color.rgb(12, 12, 14));
}

pub fn drawPlumbob(gfx: backend.Backend, x: f32, z: f32, y_base: f32) void {
    const g = backend.Color.rgb(70, 230, 120);
    const g2 = backend.Color.rgb(40, 180, 90);
    gfx.drawBox(.{ .x = x, .y = y_base, .z = z }, 0.28, 0.14, 0.28, g);
    gfx.drawBox(.{ .x = x, .y = y_base + 0.18, .z = z }, 0.18, 0.14, 0.18, g2);
    gfx.drawBox(.{ .x = x, .y = y_base + 0.34, .z = z }, 0.1, 0.1, 0.1, g);
}

fn rot(yaw: f32, lx: f32, lz: f32) struct { x: f32, z: f32 } {
    const c = @cos(yaw);
    const s = @sin(yaw);
    return .{ .x = lx * c - lz * s, .z = lx * s + lz * c };
}

pub fn drawBossMapped(
    gfx: backend.Backend,
    x: f32,
    z: f32,
    facing_yaw: f32,
    time_s: f32,
    moving: bool,
    cm: character_map.CharacterMap,
) void {
    const hs = cm.height_scale;
    const bs = cm.bulk_scale;
    const scale = hs * @max(bs, 0.85);
    const phase = anim.walkPhase(time_s, if (moving) 1.0 else 0.15);
    const bob = anim.meshBobY(phase, moving, scale);

    shadow(gfx, x, z, 0.95 * bs, 0.8 * bs);

    const su = cm.suitRgb();
    const suit = backend.Color.rgb(su[0], su[1], su[2]);

    // Phase 3: character GLB when present (tinted by suit, scaled by height/bulk).
    if (gfx.drawCharacter(.{ .x = x, .y = bob, .z = z }, facing_yaw, scale, suit)) {
        drawPlumbob(gfx, x, z, 2.55 * scale + bob);
        return;
    }

    // Procedural multi-box humanoid (always available).
    const bob_box = anim.bobY(phase, moving) * hs;
    const ll = anim.legSwing(phase, -1.0);
    const rl = anim.legSwing(phase, 1.0);
    const la = anim.armSwing(phase, -1.0);
    const ra = anim.armSwing(phase, 1.0);

    const sk = cm.skinRgb();
    const hr = cm.hairRgb();
    const skin = backend.Color.rgb(sk[0], sk[1], sk[2]);
    const shirt = backend.Color.rgb(240, 240, 245);
    const pants = backend.Color.rgb(24, 26, 36);
    const hair = backend.Color.rgb(hr[0], hr[1], hr[2]);
    const shoe = backend.Color.rgb(18, 16, 14);
    const belt = backend.Color.rgb(50, 40, 30);

    const parts = [_]struct { lx: f32, ly: f32, lz: f32, w: f32, h: f32, d: f32, col: backend.Color }{
        .{ .lx = -0.15 * bs, .ly = 0.55 * hs + bob_box, .lz = ll, .w = 0.2 * bs, .h = 0.7 * hs, .d = 0.26 * bs, .col = pants },
        .{ .lx = 0.15 * bs, .ly = 0.55 * hs + bob_box, .lz = rl, .w = 0.2 * bs, .h = 0.7 * hs, .d = 0.26 * bs, .col = pants },
        .{ .lx = -0.15 * bs, .ly = 0.22 * hs + bob_box, .lz = 0.02 + ll, .w = 0.18 * bs, .h = 0.35 * hs, .d = 0.24 * bs, .col = pants },
        .{ .lx = 0.15 * bs, .ly = 0.22 * hs + bob_box, .lz = 0.02 + rl, .w = 0.18 * bs, .h = 0.35 * hs, .d = 0.24 * bs, .col = pants },
        .{ .lx = -0.15 * bs, .ly = 0.07 * hs + bob_box, .lz = 0.08 + ll, .w = 0.22 * bs, .h = 0.12 * hs, .d = 0.38 * bs, .col = shoe },
        .{ .lx = 0.15 * bs, .ly = 0.07 * hs + bob_box, .lz = 0.08 + rl, .w = 0.22 * bs, .h = 0.12 * hs, .d = 0.38 * bs, .col = shoe },
        .{ .lx = 0, .ly = 0.95 * hs + bob_box, .lz = 0, .w = 0.52 * bs, .h = 0.18 * hs, .d = 0.32 * bs, .col = belt },
        .{ .lx = 0, .ly = 1.4 * hs + bob_box, .lz = 0, .w = 0.58 * bs, .h = 0.75 * hs, .d = 0.36 * bs, .col = suit },
        .{ .lx = 0, .ly = 1.55 * hs + bob_box, .lz = 0.12, .w = 0.28 * bs, .h = 0.2 * hs, .d = 0.08 * bs, .col = shirt },
        .{ .lx = -0.42 * bs, .ly = 1.65 * hs + bob_box, .lz = 0, .w = 0.22 * bs, .h = 0.22 * hs, .d = 0.28 * bs, .col = suit },
        .{ .lx = 0.42 * bs, .ly = 1.65 * hs + bob_box, .lz = 0, .w = 0.22 * bs, .h = 0.22 * hs, .d = 0.28 * bs, .col = suit },
        .{ .lx = -0.48 * bs, .ly = 1.35 * hs + bob_box, .lz = la, .w = 0.15 * bs, .h = 0.4 * hs, .d = 0.16 * bs, .col = suit },
        .{ .lx = 0.48 * bs, .ly = 1.35 * hs + bob_box, .lz = ra, .w = 0.15 * bs, .h = 0.4 * hs, .d = 0.16 * bs, .col = suit },
        .{ .lx = -0.5 * bs, .ly = 1.05 * hs + bob_box, .lz = la, .w = 0.14 * bs, .h = 0.32 * hs, .d = 0.14 * bs, .col = suit },
        .{ .lx = 0.5 * bs, .ly = 1.05 * hs + bob_box, .lz = ra, .w = 0.14 * bs, .h = 0.32 * hs, .d = 0.14 * bs, .col = suit },
        .{ .lx = -0.5 * bs, .ly = 0.82 * hs + bob_box, .lz = la, .w = 0.13 * bs, .h = 0.12 * hs, .d = 0.13 * bs, .col = skin },
        .{ .lx = 0.5 * bs, .ly = 0.82 * hs + bob_box, .lz = ra, .w = 0.13 * bs, .h = 0.12 * hs, .d = 0.13 * bs, .col = skin },
        .{ .lx = 0, .ly = 1.88 * hs + bob_box, .lz = 0, .w = 0.16 * bs, .h = 0.16 * hs, .d = 0.16 * bs, .col = skin },
        .{ .lx = 0, .ly = 2.18 * hs + bob_box, .lz = 0, .w = 0.4 * bs, .h = 0.46 * hs, .d = 0.38 * bs, .col = skin },
        .{ .lx = 0, .ly = 2.42 * hs + bob_box, .lz = 0, .w = 0.42 * bs, .h = 0.12 * hs, .d = 0.4 * bs, .col = hair },
        .{ .lx = 0, .ly = 2.28 * hs + bob_box, .lz = -0.12, .w = 0.4 * bs, .h = 0.2 * hs, .d = 0.12 * bs, .col = hair },
    };

    for (parts) |p| {
        const r = rot(facing_yaw, p.lx, p.lz);
        gfx.drawBox(.{ .x = x + r.x, .y = p.ly, .z = z + r.z }, p.w, p.h, p.d, p.col);
    }

    const eye_l = rot(facing_yaw, -0.1, 0.18);
    const eye_r = rot(facing_yaw, 0.1, 0.18);
    gfx.drawBox(.{ .x = x + eye_l.x, .y = 2.22 * hs + bob_box, .z = z + eye_l.z }, 0.06, 0.05, 0.04, backend.Color.rgb(20, 20, 25));
    gfx.drawBox(.{ .x = x + eye_r.x, .y = 2.22 * hs + bob_box, .z = z + eye_r.z }, 0.06, 0.05, 0.04, backend.Color.rgb(20, 20, 25));

    drawPlumbob(gfx, x, z, 2.72 * hs + bob_box);
}

pub fn drawBoss(gfx: backend.Backend, x: f32, z: f32, time_s: f32, moving: bool) void {
    drawBossMapped(gfx, x, z, 0, time_s, moving, character_map.createDefault());
}

pub fn drawBossStatic(gfx: backend.Backend, x: f32, z: f32) void {
    drawBoss(gfx, x, z, 0, false);
}

pub fn drawPed(gfx: backend.Backend, x: f32, z: f32, suit: backend.Color) void {
    drawPedVariant(gfx, x, z, suit, 0, 0, false, 0);
}

pub fn drawPedVariant(
    gfx: backend.Backend,
    x: f32,
    z: f32,
    suit: backend.Color,
    variant: u8,
    time_s: f32,
    moving: bool,
    facing_yaw: f32,
) void {
    shadow(gfx, x, z, 0.75, 0.6);
    const phase = anim.walkPhase(time_s + @as(f32, @floatFromInt(variant)) * 0.37, if (moving) 1.0 else 0.2);
    const bob = anim.meshBobY(phase, moving, 1.0);

    // Prefer character mesh variant (hashed by position inside registry).
    if (gfx.drawCharacter(.{ .x = x, .y = bob, .z = z }, facing_yaw, 0.95, suit)) {
        return;
    }

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
    const bob_box = anim.bobY(phase, moving);
    const ll = anim.legSwing(phase, -1.0);
    const rl = anim.legSwing(phase, 1.0);
    gfx.drawBox(.{ .x = x - 0.12, .y = 0.45 + bob_box, .z = z + ll }, 0.17, 0.75, 0.22, pants);
    gfx.drawBox(.{ .x = x + 0.12, .y = 0.45 + bob_box, .z = z + rl }, 0.17, 0.75, 0.22, pants);
    gfx.drawBox(.{ .x = x - 0.12, .y = 0.08 + bob_box, .z = z + 0.05 + ll }, 0.18, 0.12, 0.3, shoe);
    gfx.drawBox(.{ .x = x + 0.12, .y = 0.08 + bob_box, .z = z + 0.05 + rl }, 0.18, 0.12, 0.3, shoe);
    gfx.drawBox(.{ .x = x, .y = 1.2 + bob_box, .z = z }, 0.48, 0.7, 0.3, suit);
    gfx.drawBox(.{ .x = x - 0.32, .y = 1.15 + bob_box, .z = z }, 0.12, 0.55, 0.14, suit);
    gfx.drawBox(.{ .x = x + 0.32, .y = 1.15 + bob_box, .z = z }, 0.12, 0.55, 0.14, suit);
    gfx.drawBox(.{ .x = x, .y = 1.7 + bob_box, .z = z }, 0.14, 0.12, 0.14, skin);
    gfx.drawBox(.{ .x = x, .y = 1.95 + bob_box, .z = z }, 0.34, 0.38, 0.32, skin);
    gfx.drawBox(.{ .x = x, .y = 2.16 + bob_box, .z = z }, 0.36, 0.1, 0.34, hair);
}
