//! Third-person camera with exponential smoothing.
const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");

pub const FollowCam = struct {
    pos_x: f32 = 10,
    pos_y: f32 = 11,
    pos_z: f32 = 5,
    target_x: f32 = 10,
    target_y: f32 = 1,
    target_z: f32 = 20,

    pub fn update(self: *FollowCam, p: player.Player, driving: bool, dt: f64) backend.Camera {
        const height: f32 = if (driving) 13.0 else 11.0;
        const back: f32 = if (driving) 18.0 else 15.0;
        const desired_x = p.x;
        const desired_y = height;
        const desired_z = p.y - back;
        const desired_tx = p.x;
        const desired_ty: f32 = if (driving) 1.5 else 1.0;
        const desired_tz = p.y;

        const t = 1.0 - @exp(-8.0 * @as(f32, @floatCast(dt)));
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
            .fov_deg = if (driving) 58 else 52,
        };
    }
};
