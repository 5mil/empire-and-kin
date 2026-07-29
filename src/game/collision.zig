//! AABB collision against cityscape footprints + expanded world bounds.
const std = @import("std");
const cityscape = @import("../engine/cityscape.zig");

// Match expanded open world (scene/cityscape)
pub const WORLD_MIN_X: f32 = -22.0;
pub const WORLD_MAX_X: f32 = 95.0;
pub const WORLD_MIN_Y: f32 = -8.0;
pub const WORLD_MAX_Y: f32 = 72.0;

pub const Box = struct {
    min_x: f32,
    max_x: f32,
    min_z: f32,
    max_z: f32,
};

pub fn pointInBox(x: f32, z: f32, b: Box, margin: f32) bool {
    return x >= b.min_x - margin and x <= b.max_x + margin and z >= b.min_z - margin and z <= b.max_z + margin;
}

fn buildingBox(b: cityscape.BuildingSpec) Box {
    const hx = b.w * 0.5;
    const hz = b.d * 0.5;
    return .{
        .min_x = b.x - hx,
        .max_x = b.x + hx,
        .min_z = b.z - hz,
        .max_z = b.z + hz,
    };
}

pub fn hitsBuilding(x: f32, z: f32, radius: f32) bool {
    // Safehouse solid body
    const sh = Box{ .min_x = 7.75, .max_x = 12.25, .min_z = 16.0, .max_z = 20.0 };
    if (pointInBox(x, z, sh, radius)) return true;
    for (cityscape.BUILDINGS) |b| {
        if (pointInBox(x, z, buildingBox(b), radius)) return true;
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
