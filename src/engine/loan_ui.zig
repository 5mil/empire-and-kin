const std = @import("std");
const backend = @import("backend.zig");
const loan = @import("../game/loan.zig");

pub fn draw(gfx: backend.Backend, l: loan.Loan) void {
    if (l.due == 0) return;
    var buf: [40]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Debt ${d} d{d}", .{ l.due, l.days_left }) catch "Debt";
    gfx.drawText(line, 1080, 170, backend.Color.rgb(230, 120, 90));
}
