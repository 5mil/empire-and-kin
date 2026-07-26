const crew = @import("crew.zig");
const economy = @import("economy.zig");

pub fn weekly(c: *crew.Crew, eco: *economy.Economy) void {
    const per: u32 = 50;
    const total = per * c.count;
    if (eco.treasury >= total) {
        eco.treasury -= total;
        c.morale = @min(100, c.morale + 4);
    } else {
        if (c.morale > 20) c.morale -= 20 else c.morale = 0;
    }
}
