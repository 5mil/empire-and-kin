//! Lookout: pay crew fatigue to lower alert briefly.
const crew = @import("crew.zig");
const living = @import("living.zig");

pub const Lookout = struct {
    active_timer: f64 = 0,
};

pub fn isActive(l: Lookout) bool {
    return l.active_timer > 0;
}

pub fn tick(l: *Lookout, dt: f64) void {
    if (l.active_timer > 0) {
        l.active_timer -= dt;
        if (l.active_timer < 0) l.active_timer = 0;
    }
}

/// Activate for 20s; costs fatigue on lookout role members.
pub fn post(l: *Lookout, c: *crew.Crew) bool {
    if (l.active_timer > 0) return false;
    var i: u8 = 0;
    var found = false;
    while (i < c.count) : (i += 1) {
        if (c.members[i].role == .lookout and c.members[i].alive) {
            c.members[i].fatigue = @min(100, c.members[i].fatigue + 15);
            found = true;
        }
    }
    if (!found) return false;
    l.active_timer = 20.0;
    return true;
}

pub fn suppressAlert(l: Lookout, police: *living.PoliceState) void {
    if (!isActive(l)) return;
    if (police.alert_level > 0) police.alert_level -= 1;
}
