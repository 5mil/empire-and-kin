const backend = @import("backend.zig");

pub fn draw(gfx: backend.Backend, active: bool) void {
    if (!active) return;
    gfx.drawText("+", 630, 350, backend.Color.rgb(255, 220, 100));
}
