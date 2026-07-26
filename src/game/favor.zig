//! Soft currency for alderman / dirty-cop favors.
pub const Favor = struct {
    points: u8 = 0,
};

pub fn gain(f: *Favor, n: u8) void {
    f.points = @min(100, f.points + n);
}

pub fn spend(f: *Favor, n: u8) bool {
    if (f.points < n) return false;
    f.points -= n;
    return true;
}
