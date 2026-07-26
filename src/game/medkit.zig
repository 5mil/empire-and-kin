const player = @import("player.zig");
const inventory = @import("inventory.zig");

pub fn use(inv: *inventory.Inventory, p: *player.Player) bool {
    if (!inv.useFirst(.medkit)) return false;
    player.heal(p, 40);
    return true;
}
