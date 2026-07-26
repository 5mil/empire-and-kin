//! Lightweight framed text panels (bitmap-font friendly).
const backend = @import("backend.zig");

pub fn drawFrame(gfx: backend.Backend, x: i32, y: i32, title: []const u8) void {
    const muted = backend.Color.rgb(90, 100, 120);
    const gold = backend.Color.rgb(255, 210, 120);
    gfx.drawText("+----------------------------+", x, y, muted);
    gfx.drawText(title, x + 4, y + 14, gold);
}

pub fn drawDivider(gfx: backend.Backend, x: i32, y: i32) void {
    gfx.drawText("------------------------------", x, y, backend.Color.rgb(80, 85, 100));
}

pub fn drawBar(gfx: backend.Backend, x: i32, y: i32, value: u8, max: u8, fill: u8, empty: u8) void {
    // Text bar: e.g. [####------]
    var buf: [14]u8 = undefined;
    buf[0] = '[';
    const slots: usize = 10;
    const filled: usize = if (max == 0) 0 else @min(slots, @as(usize, value) * slots / max);
    var i: usize = 0;
    while (i < slots) : (i += 1) {
        buf[1 + i] = if (i < filled) fill else empty;
    }
    buf[11] = ']';
    buf[12] = 0;
    gfx.drawText(buf[0..12], x, y, backend.Color.rgb(180, 200, 220));
}
