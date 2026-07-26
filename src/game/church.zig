const player = @import("player.zig");
const city = @import("city.zig");

pub const CHURCH_X: f32 = 26.0;
pub const CHURCH_Z: f32 = 22.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - CHURCH_X;
    const dz = p.y - CHURCH_Z;
    return dx * dx + dz * dz < 16.0;
}

pub fn confess(d: *city.District, p: *player.Player) void {
    if (d.heat > 10) d.heat -= 10 else d.heat = 0;
    if (p.wanted_level > 0 and p.wanted_level <= 2) p.wanted_level = 0;
}
