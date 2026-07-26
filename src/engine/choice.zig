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
        eco.treasury += c.pay;
        district.heat = @min(100, district.heat + 3);
        if (the_crew.morale > 4) the_crew.morale -= 4;
        c.active = false;
        return "Kept the full take.";
    }
    if (edge_2.pressed(raw.key_2)) {
        const share = c.pay * 40 / 100;
        const keep = c.pay - share;
        eco.treasury += keep;
        the_crew.cash += share;
        the_crew.morale = @min(100, the_crew.morale + 8);
        var i: u8 = 0;
        while (i < the_crew.count) : (i += 1) {
            the_crew.members[i].loyalty = @min(100, the_crew.members[i].loyalty + 3);
        }
        if (district.heat > 6) district.heat -= 6 else district.heat = 0;
        district.control = @min(100, district.control + 2);
        c.active = false;
        return "Tithed crew. Loyalty up.";
    }
    return null;
}

pub fn draw(gfx: backend.Backend, c: Choice) void {
    if (!c.active) return;
    var buf: [64]u8 = undefined;
    gfx.drawText("====================", 380, 250, backend.Color.rgb(100, 110, 130));
    gfx.drawText("  JOB PAYOUT", 400, 275, backend.Color.rgb(255, 220, 120));
    const line = std.fmt.bufPrint(&buf, "  Take: ${d}", .{c.pay}) catch "";
    gfx.drawText(line, 400, 300, backend.Color.rgb(230, 230, 220));
    gfx.drawText("[1] Keep it all   (+heat)", 400, 340, backend.Color.rgb(255, 180, 100));
    gfx.drawText("[2] Tithe 40% crew (-heat)", 400, 365, backend.Color.rgb(120, 220, 160));
    gfx.drawText("====================", 380, 400, backend.Color.rgb(100, 110, 130));
}
