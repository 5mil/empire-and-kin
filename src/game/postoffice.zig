const player = @import("player.zig");
const economy = @import("economy.zig");

pub const PO_X: f32 = 23.0;
pub const PO_Z: f32 = 25.0;

pub fn near(p: player.Player) bool {
    const dx = p.x - PO_X;
    const dz = p.y - PO_Z;
    return dx * dx + dz * dz < 9.0;
}

pub fn checkMail(eco: *economy.Economy, seed: u32) []const u8 {
    _ = eco;
    return if (seed % 3 == 0) "Letter: meet at the docks" else "No mail";
}
