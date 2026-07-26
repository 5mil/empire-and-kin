const backend = @import("backend.zig");

pub fn draw(gfx: backend.Backend) void {
    gfx.drawText("WASD move  E act  R context  Esc empire  F5 save", 280, 8, backend.Color.rgb(110, 120, 140));
}
