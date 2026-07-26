const player = @import("player.zig");

pub const Smokescreen = struct {
    charges: u8 = 1,
};

pub fn use(s: *Smokescreen, p: *player.Player) bool {
    if (s.charges == 0) return false;
    if (p.wanted_level == 0) return false;
    s.charges -= 1;
    p.wanted_level -= 1;
    return true;
}

pub fn refill(s: *Smokescreen) void {
    s.charges = @min(3, s.charges + 1);
}
