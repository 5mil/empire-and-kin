const economy = @import("economy.zig");
const player = @import("player.zig");
const city = @import("city.zig");

pub const BAR_X: f32 = 16.0;
pub const BAR_Z: f32 = 21.5;

pub fn near(p: player.Player) bool {
    const dx = p.x - BAR_X;
    const dz = p.y - BAR_Z;
    return dx * dx + dz * dz < 12.0;
}

/// $50 for a drink: +5 HP, slight heat drop.
pub fn drink(eco: *economy.Economy, p: *player.Player, d: *city.District) bool {
    if (eco.treasury < 50) return false;
    eco.treasury -= 50;
    if (p.health < 100) p.health = @min(100, p.health + 5);
    if (d.heat > 2) d.heat -= 2;
    return true;
}

/// $150 for a tip that boosts control slightly.
pub fn buyTip(eco: *economy.Economy, d: *city.District) bool {
    if (eco.treasury < 150) return false;
    eco.treasury -= 150;
    d.control = @min(100, d.control + 3);
    return true;
}
