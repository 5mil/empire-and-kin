//! Locked-in material bank for street/scenery surface identity.
//! Procedural RGBA tiles live in the binary (no external GTA assets — those are copyrighted).
//! Designed so real CC0 TGA/PNG (Poly Haven asphalt/brick) can replace slots later without API change.
//! Expanded for GTA4-like road/sidewalk readability: cracks, oil, slab joints, brick courses, cobble.

const std = @import("std");

pub const MaterialId = enum(u8) {
    asphalt,
    wet_asphalt,
    sidewalk,
    cobble,
    brick,
    brick_dark,
    concrete,
    stucco,
    metal,
    foliage,
    water,
    roof_tar,
    dirt_alley,
    painted_line,
    glass,
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
    .{ .id = .asphalt, .name = "asphalt", .albedo = .{ 0.11, 0.11, 0.12 }, .noise = 0.10, .gloss = 0.06, .tint_r = 30, .tint_g = 30, .tint_b = 32 },
    .{ .id = .wet_asphalt, .name = "wet_asphalt", .albedo = .{ 0.08, 0.08, 0.09 }, .noise = 0.06, .gloss = 0.28, .tint_r = 22, .tint_g = 24, .tint_b = 28 },
    .{ .id = .sidewalk, .name = "sidewalk", .albedo = .{ 0.40, 0.39, 0.36 }, .noise = 0.07, .gloss = 0.02, .tint_r = 108, .tint_g = 105, .tint_b = 98 },
    .{ .id = .cobble, .name = "cobble", .albedo = .{ 0.32, 0.30, 0.28 }, .noise = 0.14, .gloss = 0.04, .tint_r = 82, .tint_g = 78, .tint_b = 72 },
    .{ .id = .brick, .name = "brick", .albedo = .{ 0.38, 0.22, 0.18 }, .noise = 0.12, .gloss = 0.03, .tint_r = 98, .tint_g = 58, .tint_b = 48 },
    .{ .id = .brick_dark, .name = "brick_dark", .albedo = .{ 0.22, 0.14, 0.12 }, .noise = 0.11, .gloss = 0.03, .tint_r = 58, .tint_g = 38, .tint_b = 34 },
    .{ .id = .concrete, .name = "concrete", .albedo = .{ 0.34, 0.35, 0.36 }, .noise = 0.08, .gloss = 0.04, .tint_r = 88, .tint_g = 90, .tint_b = 93 },
    .{ .id = .stucco, .name = "stucco", .albedo = .{ 0.55, 0.50, 0.42 }, .noise = 0.09, .gloss = 0.02, .tint_r = 140, .tint_g = 128, .tint_b = 108 },
    .{ .id = .metal, .name = "metal", .albedo = .{ 0.28, 0.30, 0.33 }, .noise = 0.04, .gloss = 0.38, .tint_r = 72, .tint_g = 76, .tint_b = 84 },
    .{ .id = .foliage, .name = "foliage", .albedo = .{ 0.14, 0.34, 0.12 }, .noise = 0.16, .gloss = 0.08, .tint_r = 38, .tint_g = 88, .tint_b = 42 },
    .{ .id = .water, .name = "water", .albedo = .{ 0.10, 0.20, 0.34 }, .noise = 0.18, .gloss = 0.55, .tint_r = 28, .tint_g = 52, .tint_b = 88 },
    .{ .id = .roof_tar, .name = "roof_tar", .albedo = .{ 0.09, 0.09, 0.10 }, .noise = 0.05, .gloss = 0.12, .tint_r = 26, .tint_g = 26, .tint_b = 28 },
    .{ .id = .dirt_alley, .name = "dirt_alley", .albedo = .{ 0.28, 0.24, 0.18 }, .noise = 0.15, .gloss = 0.01, .tint_r = 72, .tint_g = 62, .tint_b = 48 },
    .{ .id = .painted_line, .name = "painted_line", .albedo = .{ 0.72, 0.68, 0.28 }, .noise = 0.04, .gloss = 0.08, .tint_r = 185, .tint_g = 170, .tint_b = 55 },
    .{ .id = .glass, .name = "glass", .albedo = .{ 0.55, 0.62, 0.72 }, .noise = 0.02, .gloss = 0.65, .tint_r = 140, .tint_g = 160, .tint_b = 185 },
};

pub fn get(id: MaterialId) Material {
    const i: usize = @intFromEnum(id);
    if (i < materials.len) return materials[i];
    return materials[0];
}

/// 64×64 procedural tile locked in binary — deterministic pattern per material.
pub const TILE = 64;
pub const TilePixels = [TILE * TILE * 4]u8;

pub fn generateTile(id: MaterialId, out: *TilePixels) void {
    const m = get(id);
    var y: usize = 0;
    while (y < TILE) : (y += 1) {
        var x: usize = 0;
        while (x < TILE) : (x += 1) {
            const n = hashNoise(x, y, @intFromEnum(id));
            const n2 = hashNoise(x * 3, y * 2, @intFromEnum(id) +% 17);
            const v = n * m.noise + n2 * m.noise * 0.45;
            var rr = clamp01(m.albedo[0] + v);
            var gg = clamp01(m.albedo[1] + v * 0.92);
            var bb = clamp01(m.albedo[2] + v * 0.82);

            switch (id) {
                .brick, .brick_dark => {
                    // Running bond courses + mortar
                    const course: usize = y / 8;
                    const mortar_h = (y % 8 == 0);
                    const mortar_v = (x % 16 == ((course % 2) * 8));
                    if (mortar_h or mortar_v) {
                        rr = 0.52;
                        gg = 0.50;
                        bb = 0.46;
                    } else {
                        // Subtle per-brick tone
                        const bx = x / 16;
                        const by = course;
                        const bn = hashNoise(bx, by, 91);
                        rr = clamp01(rr + bn * 0.04);
                        gg = clamp01(gg + bn * 0.03);
                    }
                },
                .sidewalk => {
                    // Slab grid
                    if (x % 16 == 0 or y % 16 == 0) {
                        rr *= 0.72;
                        gg *= 0.72;
                        bb *= 0.72;
                    }
                    // Wear near edges
                    if (x % 16 == 1 or y % 16 == 1) {
                        rr *= 0.92;
                        gg *= 0.92;
                        bb *= 0.92;
                    }
                },
                .cobble => {
                    // Rounded stone cells
                    const cx = @as(i32, @intCast(x % 10)) - 5;
                    const cy = @as(i32, @intCast(y % 10)) - 5;
                    const d2 = cx * cx + cy * cy;
                    if (d2 > 18) {
                        rr *= 0.55;
                        gg *= 0.55;
                        bb *= 0.55;
                    } else if (d2 > 12) {
                        rr *= 0.85;
                        gg *= 0.85;
                        bb *= 0.85;
                    }
                },
                .asphalt, .wet_asphalt => {
                    // Cracks + oil mottling
                    if ((x + y * 3) % 29 == 0 or (x * 2 + y) % 37 == 0) {
                        rr *= 0.55;
                        gg *= 0.55;
                        bb *= 0.55;
                    }
                    // Aggregate speckles
                    if ((hashNoise(x, y, 44) > 0.38)) {
                        rr = clamp01(rr + 0.04);
                        gg = clamp01(gg + 0.04);
                        bb = clamp01(bb + 0.03);
                    }
                    if (id == .wet_asphalt and (x + y) % 11 < 2) {
                        rr = clamp01(rr * 0.7 + 0.05);
                        gg = clamp01(gg * 0.7 + 0.06);
                        bb = clamp01(bb * 0.75 + 0.08);
                    }
                },
                .concrete => {
                    if ((x % 32 == 0) or (y % 32 == 0)) {
                        rr *= 0.8;
                        gg *= 0.8;
                        bb *= 0.8;
                    }
                },
                .dirt_alley => {
                    if (hashNoise(x, y, 7) > 0.3) {
                        rr = clamp01(rr + 0.05);
                        gg = clamp01(gg + 0.03);
                    }
                },
                .painted_line => {
                    // Slight edge fade
                    if (x < 4 or x > TILE - 5) {
                        rr *= 0.6;
                        gg *= 0.6;
                        bb *= 0.6;
                    }
                },
                else => {},
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
