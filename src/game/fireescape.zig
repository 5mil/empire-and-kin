const player = @import("player.zig");

/// Climbing shifts player slightly (escape route).
pub fn climb(p: *player.Player) void {
    p.y += 2.0;
    if (p.y > 30) p.y = 30;
}
