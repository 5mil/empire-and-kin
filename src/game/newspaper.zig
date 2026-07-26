const player = @import("player.zig");
const economy = @import("economy.zig");
const news = @import("news.zig");

pub const STAND_X: f32 = 18.0;
pub const STAND_Z: f32 = 24.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - STAND_X;
    const dz = p.y - STAND_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn buyPaper(eco: *economy.Economy, seed: u32) ?[]const u8 {
    if (eco.treasury < 5) return null;
    eco.treasury -= 5;
    return news.lineForSeed(seed);
}
