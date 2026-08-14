//! Ambient pedestrians — mesh when available, procedural humanoid otherwise.
const std = @import("std");
const backend = @import("../engine/backend.zig");
const sim_actor = @import("../engine/sim_actor.zig");
const anim = @import("../engine/anim.zig");

pub const Ped = struct {
    x: f32,
    z: f32,
    vx: f32,
    vz: f32,
    hue: u8,
    yaw: f32 = 0,
};

pub const MAX_PEDS = 8;

pub const StreetPeds = struct {
    list: [MAX_PEDS]Ped = undefined,
    count: u8 = 0,
    time_s: f32 = 0,

    pub fn init(self: *StreetPeds) void {
        const seeds = [_]Ped{
            .{ .x = 6, .z = 18, .vx = 1.2, .vz = 0, .hue = 0 },
            .{ .x = 20, .z = 22, .vx = -0.9, .vz = 0.2, .hue = 1 },
            .{ .x = 14, .z = 16, .vx = 0.3, .vz = 1.0, .hue = 2 },
            .{ .x = 9, .z = 24, .vx = -0.5, .vz = -0.7, .hue = 3 },
            .{ .x = 18, .z = 19, .vx = 0.8, .vz = -0.4, .hue = 4 },
            .{ .x = 11, .z = 21, .vx = -1.1, .vz = 0.1, .hue = 5 },
            .{ .x = 25, .z = 14, .vx = -0.6, .vz = 0.5, .hue = 6 },
            .{ .x = 4, .z = 26, .vx = 0.7, .vz = -0.3, .hue = 7 },
        };
        self.count = 8;
        var i: u8 = 0;
        while (i < self.count) : (i += 1) self.list[i] = seeds[i];
        self.time_s = 0;
    }

    pub fn tick(self: *StreetPeds, dt: f64) void {
        const dt32: f32 = @floatCast(dt);
        self.time_s += dt32;
        var i: u8 = 0;
        while (i < self.count) : (i += 1) {
            var p = &self.list[i];
            p.x += p.vx * dt32;
            p.z += p.vz * dt32;
            if (p.x < 2 or p.x > 28) p.vx = -p.vx;
            if (p.z < 10 or p.z > 30) p.vz = -p.vz;
            p.yaw = anim.yawFromVelocity(p.vx, p.vz, p.yaw);
        }
    }

    pub fn draw(self: StreetPeds, gfx: backend.Backend) void {
        var i: u8 = 0;
        while (i < self.count) : (i += 1) {
            const p = self.list[i];
            const col = switch (p.hue % 8) {
                0 => backend.Color.rgb(160, 120, 100),
                1 => backend.Color.rgb(80, 90, 130),
                2 => backend.Color.rgb(120, 100, 80),
                3 => backend.Color.rgb(90, 110, 90),
                4 => backend.Color.rgb(140, 90, 100),
                5 => backend.Color.rgb(100, 100, 110),
                6 => backend.Color.rgb(70, 85, 120),
                else => backend.Color.rgb(110, 95, 75),
            };
            const moving = (p.vx * p.vx + p.vz * p.vz) > 0.01;
            sim_actor.drawPedVariant(gfx, p.x, p.z, col, p.hue, self.time_s, moving, p.yaw);
        }
    }
};
