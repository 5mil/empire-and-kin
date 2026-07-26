const empire = @import("empire.zig");

pub fn withRep(base: u32, emp: empire.Empire) u32 {
    if (emp.reputation <= 0) return base;
    const bonus = @as(u32, @intCast(@min(25, emp.reputation))) * base / 100;
    return base + bonus;
}
