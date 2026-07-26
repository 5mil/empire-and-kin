//! Short-session goals so the player has a direction.
const std = @import("std");
const city = @import("city.zig");
const economy = @import("economy.zig");

pub const Goal = struct {
    control_target: u8 = 60,
    treasury_target: u32 = 5000,
    complete: bool = false,
};

pub fn progressControl(g: Goal, d: city.District) u8 {
    return @min(100, @as(u8, @intCast(@as(u32, d.control) * 100 / g.control_target)));
}

pub fn progressCash(g: Goal, eco: economy.Economy) u8 {
    if (eco.treasury >= g.treasury_target) return 100;
    return @intCast(@min(100, eco.treasury * 100 / g.treasury_target));
}

pub fn check(g: *Goal, d: city.District, eco: economy.Economy) bool {
    if (g.complete) return true;
    if (d.control >= g.control_target and eco.treasury >= g.treasury_target) {
        g.complete = true;
        return true;
    }
    return false;
}
