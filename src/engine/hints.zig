const backend = @import("backend.zig");
const input = @import("input.zig");

pub const Hints = struct {
    index: u8 = 0,
    dismissed: bool = false,
};

const tips = [_][]const u8{
    "WASD walk. Head toward blue job poles.",
    "Enter marker radius and press E to start a job.",
    "Stay near the marker until the job finishes.",
    "Keep vs tithe after jobs — tithe boosts control.",
    "Esc opens empire. R collect, F upgrade rackets.",
    "Safehouse: E heal, R bribe, F empty stash.",
    "Fence cools heat. Doc heals. Laundry softens heat.",
    "Corner (15,20): recruit muscle for $600.",
    "F5 save / F9 load. H tips / X dismiss.",
    "Wanted high? Church confess or taxi home.",
};

pub fn handle(h: *Hints, raw: input.RawKeys, edge_h: *input.ButtonEdge, edge_x: *input.ButtonEdge) void {
    if (edge_h.pressed(raw.h)) {
        h.dismissed = false;
        h.index = (h.index + 1) % tips.len;
    }
    if (edge_x.pressed(raw.x)) h.dismissed = true;
}

pub fn draw(gfx: backend.Backend, h: Hints) void {
    if (h.dismissed) return;
    gfx.drawText(tips[h.index], 10, 560, backend.Color.rgb(200, 210, 180));
    gfx.drawText("[H] next tip  [X] dismiss", 10, 576, backend.Color.rgb(120, 130, 120));
}
