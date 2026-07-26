const city = @import("city.zig");
const economy = @import("economy.zig");
const player = @import("player.zig");

pub const DOCK_X: f32 = 28.0;
pub const DOCK_Z: f32 = 14.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - DOCK_X;
    const dz = p.y - DOCK_Z;
    return dx * dx + dz * dz < 20.0;
}

pub fn collect(eco: *economy.Economy, d: city.District) u32 {
    if (d.control < 40) return 0;
    const pay: u32 = 100 + @as(u32, d.control);
    eco.treasury += pay;
    return pay;
}
