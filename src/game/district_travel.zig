const player = @import("player.zig");
const city = @import("city.zig");

pub const Gate = struct {
    x: f32,
    z: f32,
    target: city.DistrictType,
    label: []const u8,
    spawn_x: f32,
    spawn_z: f32,
};

pub const gates = [_]Gate{
    .{ .x = 30.0, .z = 20.0, .target = .hells_kitchen, .label = "Hell's Kitchen", .spawn_x = 42.0, .spawn_z = 20.0 },
    .{ .x = -1.0, .z = 20.0, .target = .lower_east_side, .label = "Lower East Side", .spawn_x = -10.0, .spawn_z = 20.0 },
    .{ .x = 42.0, .z = 20.0, .target = .little_italy, .label = "Little Italy", .spawn_x = 28.0, .spawn_z = 20.0 },
    .{ .x = -10.0, .z = 20.0, .target = .little_italy, .label = "Little Italy", .spawn_x = 1.0, .spawn_z = 20.0 },
};

pub fn nearGate(p: player.Player) ?Gate {
    for (gates) |g| {
        const dx = p.x - g.x;
        const dz = p.y - g.z;
        if (dx * dx + dz * dz < 12.0) return g;
    }
    return null;
}

pub fn travel(p: *player.Player, g: Gate) void {
    p.x = g.spawn_x;
    p.y = g.spawn_z;
    p.current_district = g.target;
}
