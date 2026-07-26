pub const Point = struct { x: f32, z: f32 };

pub const route_a = [_]Point{
    .{ .x = 16, .z = 22 },
    .{ .x = 12, .z = 20 },
    .{ .x = 8, .z = 28 },
};

pub fn nextIndex(cur: u8) u8 {
    return (cur + 1) % 3;
}
