const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");

pub const HintId = enum {
    move,
    job,
    empire,
    vehicle,
    save,
    done,
};

pub const Hints = struct {
    current: HintId = .move,
    visible: bool = true,
};

pub fn text(id: HintId) []const u8 {
    return switch (id) {
        .move => "TIP: WASD walk toward cyan job poles",
        .job => "TIP: Near a pole press E to work the job",
        .empire => "TIP: Esc opens Empire (rackets crew cars)",
        .vehicle => "TIP: Near car press E to enter/exit",
        .save => "TIP: F5 save  F9 load  autosave on quit",
        .done => "",
    };
}

pub fn advance(h: *Hints) void {
    h.current = switch (h.current) {
        .move => .job,
        .job => .empire,
        .empire => .vehicle,
        .vehicle => .save,
        .save => .done,
        .done => .done,
    };
    if (h.current == .done) h.visible = false;
}

pub fn draw(gfx: backend.Backend, h: Hints) void {
    if (!h.visible or h.current == .done) return;
    gfx.drawText(text(h.current), 10, 520, backend.Color.rgb(180, 220, 255));
    gfx.drawText("[H] next  [X] dismiss", 10, 538, backend.Color.rgb(120, 140, 160));
}

pub fn handle(h: *Hints, raw: input.RawKeys, edge_h: *input.ButtonEdge, edge_x: *input.ButtonEdge) void {
    if (!h.visible) return;
    if (edge_h.pressed(raw.h)) advance(h);
    if (edge_x.pressed(raw.x)) {
        h.visible = false;
        h.current = .done;
    }
}
