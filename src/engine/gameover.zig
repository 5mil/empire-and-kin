const backend = @import("backend.zig");

pub fn draw(gfx: backend.Backend, down: bool) void {
    if (!down) return;
    gfx.drawText("YOU'RE DOWN", 520, 300, backend.Color.rgb(255, 80, 60));
    gfx.drawText("[E] Hospital $400", 500, 330, backend.Color.rgb(220, 200, 180));
}
