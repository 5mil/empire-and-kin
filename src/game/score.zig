const city = @import("city.zig");
const economy = @import("economy.zig");
const empire = @import("empire.zig");

pub fn compute(eco: economy.Economy, d: city.District, e: empire.Empire) u32 {
    return eco.treasury / 10 + @as(u32, d.control) * 20 + e.influence * 5;
}
