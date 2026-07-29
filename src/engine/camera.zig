//! Third-person camera with zoom + optional orbit offset.
const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");

pub const FollowCam = struct {
    pos_x: f32 = 10,
    pos_y: f32 = 18,
    pos_z: f32 = 2,
    target_x: f32 = 10,
    target_y: f32 = 1,
    target_z: f32 = 20,
    zoom: f32 = 1.0, // 0.6 close … 1.8 far
    orbit: f32 = 0, // radians yaw offset

    pub fn adjustZoom(self: *FollowCam, delta: f32) void {
        self.zoom = std.math.clamp(self.zoom + delta, 0.55, 2.2);
    }

    pub fn adjustOrbit(self: *FollowCam, delta: f32) void {
        self.orbit += delta;
    }

    pub fn update(self: *FollowCam, p: player.Player, driving: bool, dt: f64) backend.Camera {
        const base_height: f32 = if (driving) 20.0 else 17.5;
        const base_back: f32 = if (driving) 22.0 else 18.0;
        const height = base_height * self.zoom;
        const back = base_back * self.zoom;
        const side: f32 = 4.5;

        const cos_o = @cos(self.orbit);
        const sin_o = @sin(self.orbit);
        // Orbit around player: offset in XZ
        const off_x = side * cos_o + back * sin_o;
        const off_z = -back * cos_o + side * sin_o;

        const desired_x = p.x + off_x;
        const desired_y = height;
        const desired_z = p.y + off_z;
        const desired_tx = p.x;
        const desired_ty: f32 = if (driving) 1.2 else 0.9;
        const desired_tz = p.y;

        const t = 1.0 - @exp(-6.0 * @as(f32, @floatCast(dt)));
        self.pos_x += (desired_x - self.pos_x) * t;
        self.pos_y += (desired_y - self.pos_y) * t;
        self.pos_z += (desired_z - self.pos_z) * t;
        self.target_x += (desired_tx - self.target_x) * t;
        self.target_y += (desired_ty - self.target_y) * t;
        self.target_z += (desired_tz - self.target_z) * t;

        return .{
            .position = .{ .x = self.pos_x, .y = self.pos_y, .z = self.pos_z },
            .target = .{ .x = self.target_x, .y = self.target_y, .z = self.target_z },
            .up = .{ .x = 0, .y = 1, .z = 0 },
            .fov_deg = if (driving) 52 else 48,
        };
    }
};
