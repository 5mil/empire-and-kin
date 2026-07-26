const crew = @import("crew.zig");
const economy = @import("economy.zig");

pub fn tip(eco: *economy.Economy, c: *crew.Crew, amount: u32) bool {
    if (eco.treasury < amount) return false;
    eco.treasury -= amount;
    c.morale = @min(100, c.morale + 8);
    c.cash += amount / 2;
    return true;
}
