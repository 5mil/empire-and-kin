const player = @import("player.zig");
const economy = @import("economy.zig");
const crew = @import("crew.zig");

pub const ARC_X: f32 = 19.0;
pub const ARC_Z: f32 = 13.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - ARC_X;
    const dz = p.y - ARC_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn play(eco: *economy.Economy, c: *crew.Crew) bool {
    if (eco.treasury < 10) return false;
    eco.treasury -= 10;
    c.morale = @min(100, c.morale + 1);
    return true;
}
