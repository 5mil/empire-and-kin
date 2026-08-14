//! Procedural animation helpers. Shared PC + Android.
//! Mesh characters use bobY; box proxies use limb swings.
//! Full glTF clip playback is a later upgrade once channels are parsed.

const std = @import("std");

/// Walk phase 0..1 from wall-clock or movement speed.
pub fn walkPhase(time_s: f32, speed: f32) f32 {
    const rate = 2.2 + speed * 1.5;
    const p = time_s * rate;
    return p - @floor(p);
}

/// Limb swing offsets for box proxies.
pub fn legSwing(phase: f32, side: f32) f32 {
    const ang = @sin(phase * std.math.tau + side * std.math.pi);
    return ang * 0.12;
}

pub fn armSwing(phase: f32, side: f32) f32 {
    const ang = @sin(phase * std.math.tau + side * std.math.pi + std.math.pi);
    return ang * 0.1;
}

/// Vertical bob for walking mesh or box root.
pub fn bobY(phase: f32, moving: bool) f32 {
    if (!moving) return 0;
    return @abs(@sin(phase * std.math.tau * 2.0)) * 0.04;
}

/// Stronger bob for larger mesh characters.
pub fn meshBobY(phase: f32, moving: bool, scale: f32) f32 {
    if (!moving) return 0;
    return @abs(@sin(phase * std.math.tau * 2.0)) * 0.05 * @max(scale, 0.5);
}

/// Face direction from planar velocity (fallback to previous yaw).
pub fn yawFromVelocity(vx: f32, vz: f32, fallback: f32) f32 {
    if (vx * vx + vz * vz < 1e-6) return fallback;
    return std.math.atan2(vx, vz);
}
