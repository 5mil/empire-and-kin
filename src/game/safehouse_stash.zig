const stash = @import("stash.zig");
const economy = @import("economy.zig");
const scene = @import("../engine/scene.zig");
const player = @import("player.zig");

pub fn nearSafeStash(p: player.Player) bool {
    return scene.nearSafehouse(p);
}

/// At safehouse, withdraw any amount up to full stash.
pub fn withdrawAll(s: *stash.Stash, eco: *economy.Economy) u32 {
    const amt = s.amount;
    if (amt == 0) return 0;
    s.amount = 0;
    eco.treasury += amt;
    return amt;
}
