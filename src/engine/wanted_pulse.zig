const backend = @import("backend.zig");

pub fn draw(gfx: backend.Backend, wanted: u8, prev: u8) void {
    if (wanted > prev) {
        gfx.drawText("WANTED UP", 560, 180, backend.Color.rgb(255, 60, 40));
    }
}
