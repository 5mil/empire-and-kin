pub const Waypoint = struct { x: f32, z: f32 };

pub const route = [_]Waypoint{
    .{ .x = 5, .z = 20 },
    .{ .x = 12, .z = 15 },
    .{ .x = 20, .z = 20 },
    .{ .x = 12, .z = 26 },
};

pub fn next(i: u8) u8 {
    return (i + 1) % @as(u8, @intCast(route.len));
}
