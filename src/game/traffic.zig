//! Phase 7 — looping traffic on two avenue lanes + a cross street.
const backend = @import("../engine/backend.zig");

pub const Car = struct {
    x: f32,
    z: f32,
    speed: f32,
    /// 0 = avenue along X, 1 = street along Z
    axis: u8 = 0,
    color: backend.Color,
    wheel_spin: f32 = 0,
};

pub const MAX_CARS = 12;

pub const Traffic = struct {
    cars: [MAX_CARS]Car = .{
        .{ .x = 4, .z = 20.6, .speed = 6.0, .axis = 0, .color = .{ .r = 40, .g = 50, .b = 90, .a = 255 } },
        .{ .x = 22, .z = 19.4, .speed = -5.2, .axis = 0, .color = .{ .r = 100, .g = 40, .b = 35, .a = 255 } },
        .{ .x = 12, .z = 20.8, .speed = 4.8, .axis = 0, .color = .{ .r = 50, .g = 60, .b = 55, .a = 255 } },
        .{ .x = 28, .z = 19.2, .speed = -7.0, .axis = 0, .color = .{ .r = 30, .g = 30, .b = 35, .a = 255 } },
        .{ .x = 8, .z = 20.5, .speed = 5.5, .axis = 0, .color = .{ .r = 70, .g = 55, .b = 30, .a = 255 } },
        .{ .x = 16, .z = 19.3, .speed = -4.6, .axis = 0, .color = .{ .r = 25, .g = 45, .b = 70, .a = 255 } },
        .{ .x = 31, .z = 20.7, .speed = 6.8, .axis = 0, .color = .{ .r = 90, .g = 90, .b = 40, .a = 255 } },
        .{ .x = 1, .z = 19.1, .speed = -5.8, .axis = 0, .color = .{ .r = 55, .g = 35, .b = 55, .a = 255 } },
        .{ .x = 14.6, .z = 8, .speed = 5.0, .axis = 1, .color = .{ .r = 35, .g = 70, .b = 50, .a = 255 } },
        .{ .x = 13.4, .z = 26, .speed = -4.4, .axis = 1, .color = .{ .r = 80, .g = 30, .b = 25, .a = 255 } },
        .{ .x = 14.8, .z = 2, .speed = 6.2, .axis = 1, .color = .{ .r = 40, .g = 40, .b = 48, .a = 255 } },
        .{ .x = 13.2, .z = 32, .speed = -5.5, .axis = 1, .color = .{ .r = 20, .g = 55, .b = 75, .a = 255 } },
    },

    pub fn tick(self: *Traffic, dt: f64) void {
        const dt32: f32 = @floatCast(dt);
        const radius: f32 = 0.32;
        for (&self.cars) |*c| {
            if (c.axis == 0) {
                c.x += c.speed * dt32;
                if (c.speed > 0 and c.x > 36) c.x = -4;
                if (c.speed < 0 and c.x < -4) c.x = 36;
            } else {
                c.z += c.speed * dt32;
                if (c.speed > 0 and c.z > 36) c.z = -2;
                if (c.speed < 0 and c.z < -2) c.z = 36;
            }
            c.wheel_spin += (@abs(c.speed) / radius) * dt32;
        }
    }

    pub fn draw(self: Traffic, gfx: backend.Backend) void {
        for (self.cars) |c| {
            const yaw: f32 = if (c.axis == 0)
                (if (c.speed >= 0) 0.0 else 3.14159265)
            else
                (if (c.speed >= 0) 1.5707963 else -1.5707963);
            if (gfx.drawVehicle(.{ .x = c.x, .y = 0.0, .z = c.z }, yaw, 0.0, 0.0, c.wheel_spin, 0.0, 100, c.color)) continue;
            gfx.drawBox(.{ .x = c.x, .y = 0.45, .z = c.z }, 1.8, 0.9, 3.0, c.color);
            gfx.drawBox(.{ .x = c.x, .y = 0.95, .z = c.z - 0.2 }, 1.5, 0.4, 1.2, backend.Color.rgb(25, 35, 50));
        }
    }
};
