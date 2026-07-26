//! Simple AABB collision against known building footprints + world bounds.
const std = @import("std");

pub const WORLD_MIN_X: f32 = -8.0;
pub const WORLD_MAX_X: f32 = 40.0;
pub const WORLD_MIN_Y: f32 = 4.0;
pub const WORLD_MAX_Y: f32 = 36.0;

pub const Box = struct {
    min_x: f32,
    max_x: f32,
    min_z: f32,
    max_z: f32,
};

/// Matches the simplified street block in engine/scene.zig (x,z = player x,y).
const buildings = [_]Box{
    .{ .min_x = 1.5, .max_x = 6.5, .min_z = 26.0, .max_z = 30.0 },
    .{ .min_x = 9.5, .max_x = 14.5, .min_z = 27.0, .max_z = 31.0 },
    .{ .min_x = 17.5, .max_x = 22.5, .min_z = 26.0, .max_z = 30.0 },
    .{ .min_x = 1.5, .max_x = 6.5, .min_z = 10.0, .max_z = 14.0 },
    .{ .min_x = 9.5, .max_x = 14.5, .min_z = 9.0, .max_z = 13.0 },
    .{ .min_x = 17.5, .max_x = 22.5, .min_z = 10.0, .max_z = 14.0 },
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

/// Try move from (ox,oz) by (dx,dz). Slides on single-axis if blocked.
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
