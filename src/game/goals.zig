//! Session goals with progressive tiers.
const city = @import("city.zig");
const economy = @import("economy.zig");

pub const Goal = struct {
    tier: u8 = 1,
    control_target: u8 = 60,
    treasury_target: u32 = 5000,
    complete: bool = false,
    just_completed: bool = false,
};

pub fn progressControl(g: Goal, d: city.District) u8 {
    return @min(100, @as(u8, @intCast(@as(u32, d.control) * 100 / @max(g.control_target, 1))));
}

pub fn progressCash(g: Goal, eco: economy.Economy) u8 {
    if (eco.treasury >= g.treasury_target) return 100;
    return @intCast(@min(100, eco.treasury * 100 / @max(g.treasury_target, 1)));
}

/// Returns true only on the frame the tier is completed.
pub fn check(g: *Goal, d: city.District, eco: economy.Economy) bool {
    g.just_completed = false;
    if (d.control >= g.control_target and eco.treasury >= g.treasury_target) {
        g.just_completed = true;
        g.complete = true;
        // Advance tier
        if (g.tier < 3) {
            g.tier += 1;
            g.control_target = @min(95, g.control_target + 15);
            g.treasury_target += 3000;
            g.complete = false;
        }
        return true;
    }
    return false;
}
