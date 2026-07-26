const crew = @import("crew.zig");
const economy = @import("economy.zig");

pub fn dinner(eco: *economy.Economy, c: *crew.Crew) bool {
    if (eco.treasury < 200) return false;
    eco.treasury -= 200;
    c.morale = @min(100, c.morale + 15);
    var i: u8 = 0;
    while (i < c.count) : (i += 1) {
        if (c.members[i].fatigue > 10) c.members[i].fatigue -= 10;
    }
    return true;
}
