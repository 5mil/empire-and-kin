//! Simple looping traffic along the main avenue — Phase 4 mesh cars + wheel spin.
const backend = @import("../engine/backend.zig");

pub const Car = struct {
    x: f32,
    z: f32,
    speed: f32,
    color: backend.Color,
    wheel_spin: f32 = 0,
};

pub const Traffic = struct {
    cars: [4]Car = .{
        .{ .x = 4, .z = 20.5, .speed = 6.0, .color = .{ .r = 40, .g = 50, .b = 90, .a = 255 } },
        .{ .x = 22, .z = 19.5, .speed = -5.0, .color = .{ .r = 100, .g = 40, .b = 35, .a = 255 } },
        .{ .x = 12, .z = 20.8, .speed = 4.5, .color = .{ .r = 50, .g = 60, .b = 55, .a = 255 } },
        .{ .x = 28, .z = 19.2, .speed = -7.0, .color = .{ .r = 30, .g = 30, .b = 35, .a = 255 } },
    },

    pub fn tick(self: *Traffic, dt: f64) void {
        const dt32: f32 = @floatCast(dt);
        const radius: f32 = 0.32;
        for (&self.cars) |*c| {
            c.x += c.speed * dt32;
            c.wheel_spin += (@abs(c.speed) / radius) * dt32;
            if (c.speed > 0 and c.x > 34) c.x = -2;
            if (c.speed < 0 and c.x < -2) c.x = 34;
        }
    }

    pub fn draw(self: Traffic, gfx: backend.Backend) void {
        for (self.cars) |c| {
            // Face travel direction on the avenue (along +X / -X).
            const yaw: f32 = if (c.speed >= 0) 0.0 else 3.14159265;
            if (gfx.drawVehicle(.{ .x = c.x, .y = 0.0, .z = c.z }, yaw, c.wheel_spin, 0.0, 100, c.color)) continue;
            gfx.drawBox(.{ .x = c.x, .y = 0.45, .z = c.z }, 1.8, 0.9, 3.0, c.color);
            gfx.drawBox(.{ .x = c.x, .y = 0.95, .z = c.z - 0.2 }, 1.5, 0.4, 1.2, backend.Color.rgb(25, 35, 50));
        }
    }
};
