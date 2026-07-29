//! Locked-in material bank for street/scenery surface identity.
//! Procedural RGBA tiles live in the binary (no external GTA assets — those are copyrighted).
//! Designed so real CC0 TGA/PNG can replace slots later without API change.

const std = @import("std");

pub const MaterialId = enum(u8) {
    asphalt,
    sidewalk,
    brick,
    concrete,
    stucco,
    metal,
    foliage,
    water,
    roof_tar,
    count,
};

pub const Material = struct {
    id: MaterialId,
    name: []const u8,
    /// Base albedo 0-1
    albedo: [3]f32,
    /// Variation amplitude for fragment noise
    noise: f32,
    /// Specular-ish lift in lit shader path via tint
    gloss: f32,
    /// Tint applied when drawing boxes of this material
    tint_r: u8,
    tint_g: u8,
    tint_b: u8,
};

pub const materials = [_]Material{
    .{ .id = .asphalt, .name = "asphalt", .albedo = .{ 0.12, 0.12, 0.13 }, .noise = 0.08, .gloss = 0.05, .tint_r = 32, .tint_g = 32, .tint_b = 34 },
    .{ .id = .sidewalk, .name = "sidewalk", .albedo = .{ 0.42, 0.41, 0.38 }, .noise = 0.06, .gloss = 0.02, .tint_r = 110, .tint_g = 108, .tint_b = 100 },
    .{ .id = .brick, .name = "brick", .albedo = .{ 0.38, 0.22, 0.18 }, .noise = 0.12, .gloss = 0.03, .tint_r = 98, .tint_g = 58, .tint_b = 48 },
    .{ .id = .concrete, .name = "concrete", .albedo = .{ 0.35, 0.36, 0.37 }, .noise = 0.07, .gloss = 0.04, .tint_r = 90, .tint_g = 92, .tint_b = 95 },
    .{ .id = .stucco, .name = "stucco", .albedo = .{ 0.55, 0.50, 0.42 }, .noise = 0.09, .gloss = 0.02, .tint_r = 140, .tint_g = 128, .tint_b = 108 },
    .{ .id = .metal, .name = "metal", .albedo = .{ 0.28, 0.30, 0.33 }, .noise = 0.04, .gloss = 0.35, .tint_r = 72, .tint_g = 76, .tint_b = 84 },
    .{ .id = .foliage, .name = "foliage", .albedo = .{ 0.15, 0.35, 0.12 }, .noise = 0.15, .gloss = 0.08, .tint_r = 40, .tint_g = 90, .tint_b = 45 },
    .{ .id = .water, .name = "water", .albedo = .{ 0.12, 0.22, 0.35 }, .noise = 0.18, .gloss = 0.5, .tint_r = 30, .tint_g = 55, .tint_b = 90 },
    .{ .id = .roof_tar, .name = "roof_tar", .albedo = .{ 0.10, 0.10, 0.11 }, .noise = 0.05, .gloss = 0.1, .tint_r = 28, .tint_g = 28, .tint_b = 30 },
};

pub fn get(id: MaterialId) Material {
    const i: usize = @intFromEnum(id);
    if (i < materials.len) return materials[i];
    return materials[0];
}

/// 64x64 procedural tile locked in binary — deterministic pattern per material.
pub const TILE = 64;
pub const TilePixels = [TILE * TILE * 4]u8;

pub fn generateTile(id: MaterialId, out: *TilePixels) void {
    const m = get(id);
    var y: usize = 0;
    while (y < TILE) : (y += 1) {
        var x: usize = 0;
        while (x < TILE) : (x += 1) {
            const n = hashNoise(x, y, @intFromEnum(id));
            const v = n * m.noise;
            const r = clamp01(m.albedo[0] + v);
            const g = clamp01(m.albedo[1] + v * 0.9);
            const b = clamp01(m.albedo[2] + v * 0.8);
            // Brick mortar lines
            var rr = r;
            var gg = g;
            var bb = b;
            if (id == .brick) {
                const mortar = (y % 8 == 0) or (x % 16 == ((y / 8) % 2) * 8);
                if (mortar) {
                    rr = 0.55;
                    gg = 0.52;
                    bb = 0.48;
                }
            }
            // Sidewalk slab joints
            if (id == .sidewalk and (x % 16 == 0 or y % 16 == 0)) {
                rr *= 0.75;
                gg *= 0.75;
                bb *= 0.75;
            }
            // Asphalt cracks
            if (id == .asphalt and ((x + y * 3) % 31 == 0)) {
                rr *= 0.6;
                gg *= 0.6;
                bb *= 0.6;
            }
            const i = (y * TILE + x) * 4;
            out[i + 0] = @intFromFloat(rr * 255.0);
            out[i + 1] = @intFromFloat(gg * 255.0);
            out[i + 2] = @intFromFloat(bb * 255.0);
            out[i + 3] = 255;
        }
    }
}

fn hashNoise(x: usize, y: usize, seed: u8) f32 {
    var h: u32 = @as(u32, seed) *% 374761393 + @as(u32, @intCast(x)) *% 668265263 + @as(u32, @intCast(y)) *% 2147483647;
    h = (h ^ (h >> 13)) *% 1274126177;
    h ^= h >> 16;
    return @as(f32, @floatFromInt(h & 0xFFFF)) / 65535.0 - 0.5;
}

fn clamp01(v: f32) f32 {
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
}

pub fn colorOf(id: MaterialId) @import("../backend.zig").Color {
    const m = get(id);
    return @import("../backend.zig").Color.rgb(m.tint_r, m.tint_g, m.tint_b);
}
