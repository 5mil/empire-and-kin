const player = @import("player.zig");
const city = @import("city.zig");

pub const Gate = struct {
    x: f32,
    z: f32,
    target: city.DistrictType,
    label: []const u8,
};

pub const gates = [_]Gate{
    .{ .x = 30.0, .z = 20.0, .target = .hells_kitchen, .label = "Hell's Kitchen" },
    .{ .x = -1.0, .z = 20.0, .target = .lower_east_side, .label = "Lower East Side" },
};

pub fn nearGate(p: player.Player) ?Gate {
    for (gates) |g| {
        const dx = p.x - g.x;
        const dz = p.y - g.z;
        if (dx * dx + dz * dz < 9.0) return g;
    }
    return null;
}
