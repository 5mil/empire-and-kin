const player = @import("player.zig");

pub fn nameAt(p: player.Player) []const u8 {
    if (p.x < 6) return "The Alley";
    if (p.x > 24 and p.y < 16) return "Waterfront Edge";
    if (p.y > 26) return "North Side";
    if (p.y < 14) return "South Blocks";
    return "Mulberry Strip";
}
