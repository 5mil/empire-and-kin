const economy = @import("economy.zig");
const city = @import("city.zig");
const empire = @import("empire.zig");

pub fn collect(eco: *economy.Economy, d: *city.District, e: empire.Empire) u32 {
    const base: u32 = 80 + @as(u32, d.control);
    const mod: u32 = if (e.racket_count > 0) e.rackets[0].level * 20 else 0;
    const pay = base + mod;
    eco.treasury += pay;
    d.heat = @min(100, d.heat + 3);
    return pay;
}
