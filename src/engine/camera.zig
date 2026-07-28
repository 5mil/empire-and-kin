//! Third-person camera — elevated 3/4 angle (life-sim readable).
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

    pub fn update(self: *FollowCam, p: player.Player, driving: bool, dt: f64) backend.Camera {
        // Higher + farther back than FPS-ish alpha — reads like a neighborhood dollhouse.
        const height: f32 = if (driving) 20.0 else 17.5;
        const back: f32 = if (driving) 22.0 else 18.0;
        const side: f32 = 4.5; // slight offset so buildings aren't dead-center occluding
        const desired_x = p.x + side;
        const desired_y = height;
        const desired_z = p.y - back;
        const desired_tx = p.x;
        const desired_ty: f32 = if (driving) 1.2 else 0.8;
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
            .fov_deg = if (driving) 50 else 46,
        };
    }
};
