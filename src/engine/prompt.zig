const backend = @import("backend.zig");

pub fn draw(gfx: backend.Backend, line: []const u8) void {
    if (line.len == 0) return;
    gfx.drawText("------------------------------", 400, 668, backend.Color.rgb(60, 60, 70));
    gfx.drawText(line, 400, 680, backend.Color.rgb(255, 240, 180));
    gfx.drawText("------------------------------", 400, 692, backend.Color.rgb(60, 60, 70));
}
