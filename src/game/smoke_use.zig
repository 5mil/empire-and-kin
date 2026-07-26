const inventory = @import("inventory.zig");
const player = @import("player.zig");

pub fn tryUse(inv: *inventory.Inventory, p: *player.Player) bool {
    if (!inv.useFirst(.smokescreen)) return false;
    if (p.wanted_level > 0) p.wanted_level -= 1;
    return true;
}
