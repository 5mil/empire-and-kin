//! Phase 7 — sidewalk wanderers (16). Stay off the avenue lanes.
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
    /// 0 north sidewalk, 1 south sidewalk
    walk: u8 = 0,
};

pub const MAX_PEDS = 16;

pub const StreetPeds = struct {
    list: [MAX_PEDS]Ped = undefined,
    count: u8 = 0,
    time_s: f32 = 0,

    pub fn init(self: *StreetPeds) void {
        const seeds = [_]Ped{
            .{ .x = 6, .z = 17.2, .vx = 1.2, .vz = 0, .hue = 0, .walk = 0 },
            .{ .x = 20, .z = 22.6, .vx = -0.9, .vz = 0, .hue = 1, .walk = 1 },
            .{ .x = 14, .z = 17.0, .vx = 0.8, .vz = 0, .hue = 2, .walk = 0 },
            .{ .x = 9, .z = 22.8, .vx = -0.7, .vz = 0, .hue = 3, .walk = 1 },
            .{ .x = 18, .z = 17.4, .vx = 1.0, .vz = 0, .hue = 4, .walk = 0 },
            .{ .x = 11, .z = 22.4, .vx = -1.1, .vz = 0, .hue = 5, .walk = 1 },
            .{ .x = 25, .z = 17.1, .vx = -0.6, .vz = 0, .hue = 6, .walk = 0 },
            .{ .x = 4, .z = 22.9, .vx = 0.7, .vz = 0, .hue = 7, .walk = 1 },
            .{ .x = 2, .z = 17.3, .vx = 1.05, .vz = 0, .hue = 8, .walk = 0 },
            .{ .x = 28, .z = 22.5, .vx = -0.85, .vz = 0, .hue = 9, .walk = 1 },
            .{ .x = 16, .z = 16.8, .vx = -0.95, .vz = 0, .hue = 10, .walk = 0 },
            .{ .x = 7, .z = 23.0, .vx = 0.6, .vz = 0, .hue = 11, .walk = 1 },
            .{ .x = 22, .z = 17.6, .vx = 0.5, .vz = 0, .hue = 12, .walk = 0 },
            .{ .x = 13, .z = 22.2, .vx = -0.55, .vz = 0, .hue = 13, .walk = 1 },
            .{ .x = 30, .z = 17.2, .vx = -1.15, .vz = 0, .hue = 14, .walk = 0 },
            .{ .x = 1, .z = 22.7, .vx = 0.95, .vz = 0, .hue = 15, .walk = 1 },
        };
        self.count = 16;
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
            // pin to sidewalk band
            const target_z: f32 = if (p.walk == 0) 17.2 else 22.6;
            p.z += (target_z - p.z) * 0.08;
            if (p.x < 0) {
                p.x = 0;
                p.vx = @abs(p.vx);
            }
            if (p.x > 32) {
                p.x = 32;
                p.vx = -@abs(p.vx);
            }
            p.yaw = anim.yawFromVelocity(p.vx, 0, p.yaw);
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
            const moving = (p.vx * p.vx) > 0.01;
            sim_actor.drawPedVariant(gfx, p.x, p.z, col, p.hue, self.time_s, moving, p.yaw);
        }
    }
};
