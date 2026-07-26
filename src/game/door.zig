const player = @import("player.zig");

pub const Kind = enum { social_club, speakeasy, warehouse };

pub const Door = struct {
    x: f32,
    z: f32,
    kind: Kind,
    label: []const u8,
};

pub const doors = [_]Door{
    .{ .x = 10.0, .z = 20.5, .kind = .social_club, .label = "Social Club" },
    .{ .x = 16.0, .z = 22.0, .kind = .speakeasy, .label = "Speakeasy" },
};

pub fn near(p: player.Player) ?Door {
    for (doors) |d| {
        const dx = p.x - d.x;
        const dz = p.y - d.z;
        if (dx * dx + dz * dz < 6.25) return d;
    }
    return null;
}
