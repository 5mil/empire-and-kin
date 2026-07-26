const player = @import("player.zig");
const economy = @import("economy.zig");
const city = @import("city.zig");

pub const BARB_X: f32 = 17.5;
pub const BARB_Z: f32 = 27.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - BARB_X;
    const dz = p.y - BARB_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn cut(eco: *economy.Economy, d: *city.District) bool {
    if (eco.treasury < 20) return false;
    eco.treasury -= 20;
    d.control = @min(100, d.control + 1);
    return true;
}
