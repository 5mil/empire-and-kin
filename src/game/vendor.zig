const economy = @import("economy.zig");
const inventory = @import("inventory.zig");
const player = @import("player.zig");

pub const VENDOR_X: f32 = 14.0;
pub const VENDOR_Z: f32 = 25.0;
pub const MEDKIT_PRICE: u32 = 200;

pub fn near(p: player.Player) bool {
    const dx = p.x - VENDOR_X;
    const dz = p.y - VENDOR_Z;
    return dx * dx + dz * dz < 12.0;
}

pub fn buyMedkit(eco: *economy.Economy, inv: *inventory.Inventory) bool {
    if (eco.treasury < MEDKIT_PRICE) return false;
    if (!inv.add(.medkit)) return false;
    eco.treasury -= MEDKIT_PRICE;
    return true;
}
