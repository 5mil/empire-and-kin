//! Lightweight ambient pedestrians for street life.
const std = @import("std");
const backend = @import("../engine/backend.zig");

pub const Ped = struct {
    x: f32,
    z: f32,
    vx: f32,
    vz: f32,
    hue: u8,
};

pub const MAX_PEDS = 8;

pub const StreetPeds = struct {
    list: [MAX_PEDS]Ped = undefined,
    count: u8 = 0,

    pub fn init(self: *StreetPeds) void {
        const seeds = [_]Ped{
            .{ .x = 6, .z = 18, .vx = 1.2, .vz = 0, .hue = 0 },
            .{ .x = 20, .z = 22, .vx = -0.9, .vz = 0.2, .hue = 1 },
            .{ .x = 14, .z = 16, .vx = 0.3, .vz = 1.0, .hue = 2 },
            .{ .x = 9, .z = 24, .vx = -0.5, .vz = -0.7, .hue = 3 },
            .{ .x = 18, .z = 19, .vx = 0.8, .vz = -0.4, .hue = 4 },
            .{ .x = 11, .z = 21, .vx = -1.1, .vz = 0.1, .hue = 5 },
        };
        self.count = 6;
        var i: u8 = 0;
        while (i < self.count) : (i += 1) self.list[i] = seeds[i];
    }

    pub fn tick(self: *StreetPeds, dt: f64) void {
        const dt32: f32 = @floatCast(dt);
        var i: u8 = 0;
        while (i < self.count) : (i += 1) {
            var p = &self.list[i];
            p.x += p.vx * dt32;
            p.z += p.vz * dt32;
            if (p.x < 2 or p.x > 28) p.vx = -p.vx;
            if (p.z < 10 or p.z > 30) p.vz = -p.vz;
        }
    }

    pub fn draw(self: StreetPeds, gfx: backend.Backend) void {
        var i: u8 = 0;
        while (i < self.count) : (i += 1) {
            const p = self.list[i];
            const col = switch (p.hue % 6) {
                0 => backend.Color.rgb(160, 120, 100),
                1 => backend.Color.rgb(80, 90, 130),
                2 => backend.Color.rgb(120, 100, 80),
                3 => backend.Color.rgb(90, 110, 90),
                4 => backend.Color.rgb(140, 90, 100),
                else => backend.Color.rgb(100, 100, 110),
            };
            gfx.drawBox(.{ .x = p.x, .y = 0.7, .z = p.z }, 0.45, 1.3, 0.4, col);
            gfx.drawBox(.{ .x = p.x, .y = 1.5, .z = p.z }, 0.35, 0.35, 0.35, backend.Color.rgb(210, 170, 140));
        }
    }
};
