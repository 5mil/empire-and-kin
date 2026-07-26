const time = @import("time.zig");

pub const DayWatch = struct {
    last_day: u32 = 1,
};

/// Returns true when a new game-day starts.
pub fn crossed(w: *DayWatch, clock: time.Clock) bool {
    if (clock.day != w.last_day) {
        w.last_day = clock.day;
        return true;
    }
    return false;
}
