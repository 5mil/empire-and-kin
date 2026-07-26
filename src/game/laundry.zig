const player = @import("player.zig");
const economy = @import("economy.zig");
const city = @import("city.zig");

pub const LAU_X: f32 = 5.0;
pub const LAU_Z: f32 = 25.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - LAU_X;
    const dz = p.y - LAU_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn wash(eco: *economy.Economy, d: *city.District) bool {
    if (eco.treasury < 30) return false;
    eco.treasury -= 30;
    if (d.heat > 5) d.heat -= 5 else d.heat = 0;
    return true;
}
