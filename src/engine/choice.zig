//! Modal choice after finishing a job.
const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");
const economy = @import("../game/economy.zig");
const crew = @import("../game/crew.zig");
const city = @import("../game/city.zig");

pub const Choice = struct {
    active: bool = false,
    pay: u32 = 0,
};

pub fn open(c: *Choice, pay: u32) void {
    c.active = true;
    c.pay = pay;
}

/// Returns true if a choice was resolved this frame.
/// 1 = keep all, 2 = tithe 40% to crew (loyalty+).
pub fn handle(
    c: *Choice,
    raw: input.RawKeys,
    edge_1: *input.ButtonEdge,
    edge_2: *input.ButtonEdge,
    eco: *economy.Economy,
    the_crew: *crew.Crew,
    district: *city.District,
) ?[]const u8 {
    if (!c.active) return null;
    if (edge_1.pressed(raw.key_1)) {
        // Already paid into treasury by mission; keep means no change, slight heat
        district.heat = @min(100, district.heat + 2);
        c.active = false;
        return "Kept the take. Crew notices.";
    }
    if (edge_2.pressed(raw.key_2)) {
        const share = c.pay * 40 / 100;
        if (eco.treasury >= share) eco.treasury -= share;
        the_crew.cash += share;
        the_crew.morale = @min(100, the_crew.morale + 8);
        var i: u8 = 0;
        while (i < the_crew.count) : (i += 1) {
            the_crew.members[i].loyalty = @min(100, the_crew.members[i].loyalty + 3);
        }
        if (district.heat > 5) district.heat -= 5;
        c.active = false;
        return "Tithed crew. Loyalty up, heat down.";
    }
    return null;
}

pub fn draw(gfx: backend.Backend, c: Choice) void {
    if (!c.active) return;
    var buf: [64]u8 = undefined;
    gfx.drawText("=== JOB PAYOUT ===", 400, 280, backend.Color.rgb(255, 220, 120));
    const line = std.fmt.bufPrint(&buf, "Take: ${d}", .{c.pay}) catch "";
    gfx.drawText(line, 400, 305, backend.Color.rgb(230, 230, 220));
    gfx.drawText("[1] Keep it all  (+heat)", 400, 340, backend.Color.rgb(255, 180, 100));
    gfx.drawText("[2] Tithe 40% to crew  (-heat +loy)", 400, 365, backend.Color.rgb(120, 220, 160));
}
