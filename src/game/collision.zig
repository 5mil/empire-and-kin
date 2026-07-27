//! Simple AABB collision against known building footprints + world bounds.
const std = @import("std");

pub const WORLD_MIN_X: f32 = -14.0;
pub const WORLD_MAX_X: f32 = 55.0;
pub const WORLD_MIN_Y: f32 = 6.0;
pub const WORLD_MAX_Y: f32 = 34.0;

pub const Box = struct {
    min_x: f32,
    max_x: f32,
    min_z: f32,
    max_z: f32,
};

/// Matches engine/scene.zig footprints (x,z = player x,y).
const buildings = [_]Box{
    // North row Little Italy
    .{ .min_x = 0.9, .max_x = 6.1, .min_z = 26.4, .max_z = 30.6 },
    .{ .min_x = 9.0, .max_x = 14.0, .min_z = 27.2, .max_z = 31.2 },
    .{ .min_x = 16.9, .max_x = 22.1, .min_z = 26.2, .max_z = 30.4 },
    .{ .min_x = 24.75, .max_x = 29.25, .min_z = 26.9, .max_z = 30.7 },
    // South row
    .{ .min_x = 1.0, .max_x = 6.0, .min_z = 9.5, .max_z = 13.5 },
    .{ .min_x = 9.0, .max_x = 14.0, .min_z = 8.8, .max_z = 12.8 },
    .{ .min_x = 16.9, .max_x = 22.1, .min_z = 9.5, .max_z = 13.5 },
    .{ .min_x = 24.75, .max_x = 29.25, .min_z = 9.3, .max_z = 13.1 },
    // Safehouse body
    .{ .min_x = 7.75, .max_x = 12.25, .min_z = 16.0, .max_z = 20.0 },
    // Hell's Kitchen row
    .{ .min_x = 38.0, .max_x = 44.0, .min_z = 26.0, .max_z = 30.5 },
    .{ .min_x = 46.0, .max_x = 52.0, .min_z = 26.0, .max_z = 30.5 },
    .{ .min_x = 38.0, .max_x = 44.0, .min_z = 9.5, .max_z = 13.5 },
    .{ .min_x = 46.0, .max_x = 52.0, .min_z = 9.5, .max_z = 13.5 },
};

pub fn pointInBox(x: f32, z: f32, b: Box, margin: f32) bool {
    return x >= b.min_x - margin and x <= b.max_x + margin and z >= b.min_z - margin and z <= b.max_z + margin;
}

pub fn hitsBuilding(x: f32, z: f32, radius: f32) bool {
    for (buildings) |b| {
        if (pointInBox(x, z, b, radius)) return true;
    }
    return false;
}

pub fn resolveMove(ox: f32, oz: f32, dx: f32, dz: f32, radius: f32) struct { x: f32, z: f32 } {
    var nx = ox + dx;
    var nz = oz + dz;
    if (hitsBuilding(nx, nz, radius)) {
        if (!hitsBuilding(ox + dx, oz, radius)) {
            nz = oz;
            nx = ox + dx;
        } else if (!hitsBuilding(ox, oz + dz, radius)) {
            nx = ox;
            nz = oz + dz;
        } else {
            nx = ox;
            nz = oz;
        }
    }
    nx = std.math.clamp(nx, WORLD_MIN_X, WORLD_MAX_X);
    nz = std.math.clamp(nz, WORLD_MIN_Y, WORLD_MAX_Y);
    return .{ .x = nx, .z = nz };
}

pub fn clampToWorld(x: f32, z: f32) struct { x: f32, z: f32 } {
    return .{
        .x = std.math.clamp(x, WORLD_MIN_X, WORLD_MAX_X),
        .z = std.math.clamp(z, WORLD_MIN_Y, WORLD_MAX_Y),
    };
}
