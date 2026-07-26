const crew = @import("crew.zig");
const city = @import("city.zig");
const empire = @import("empire.zig");

pub fn press(c: *crew.Crew, d: *city.District, e: *empire.Empire) bool {
    var i: u8 = 0;
    var any = false;
    while (i < c.count) : (i += 1) {
        if (c.members[i].alive and c.members[i].role == .enforcer) {
            c.members[i].fatigue = @min(100, c.members[i].fatigue + 12);
            any = true;
        }
    }
    if (!any) return false;
    city.increaseControl(d, 5);
    e.reputation = @min(100, e.reputation + 2);
    d.heat = @min(100, d.heat + 4);
    return true;
}
