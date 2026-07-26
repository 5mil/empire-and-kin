const backend = @import("../engine/backend.zig");
const patrol = @import("patrol.zig");

pub const CopCar = struct {
    wp: u8 = 0,
    x: f32 = 5,
    z: f32 = 20,
    t: f32 = 0,

    pub fn tick(self: *CopCar, dt: f64) void {
        const target = patrol.route[self.wp % patrol.route.len];
        const dx = target.x - self.x;
        const dz = target.z - self.z;
        const dist = @sqrt(dx * dx + dz * dz);
        if (dist < 0.5) {
            self.wp = patrol.next(self.wp);
            return;
        }
        const sp: f32 = 3.5 * @as(f32, @floatCast(dt));
        self.x += dx / dist * sp;
        self.z += dz / dist * sp;
    }

    pub fn draw(self: CopCar, gfx: backend.Backend) void {
        gfx.drawBox(.{ .x = self.x, .y = 0.5, .z = self.z }, 1.9, 1.0, 3.2, backend.Color.rgb(30, 40, 90));
        gfx.drawBox(.{ .x = self.x, .y = 1.1, .z = self.z }, 0.6, 0.25, 0.6, backend.Color.rgb(200, 40, 40));
    }
};
