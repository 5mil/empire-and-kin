//! Procedural animation helpers (pre-GLB). Shared PC + Android.
//! Later replaced/supplemented by Quaternius/KayKit clips from assets/cc0/animations.

const std = @import("std");

/// Walk phase 0..1 from wall-clock or movement speed.
pub fn walkPhase(time_s: f32, speed: f32) f32 {
    const rate = 2.2 + speed * 1.5;
    const p = time_s * rate;
    return p - @floor(p);
}

/// Limb swing in radians-ish (small offsets for box proxies).
pub fn legSwing(phase: f32, side: f32) f32 {
    const ang = @sin(phase * std.math.tau + side * std.math.pi);
    return ang * 0.12;
}

pub fn armSwing(phase: f32, side: f32) f32 {
    const ang = @sin(phase * std.math.tau + side * std.math.pi + std.math.pi);
    return ang * 0.1;
}

pub fn bobY(phase: f32, moving: bool) f32 {
    if (!moving) return 0;
    return @abs(@sin(phase * std.math.tau * 2.0)) * 0.04;
}
