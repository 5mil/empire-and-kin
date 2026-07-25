const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");

/// A7 — dismissible onboarding hints

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
        .move => "TIP: WASD to walk. Head toward a job marker.",
        .job => "TIP: Enter the marker radius and press E to start a job.",
        .empire => "TIP: Esc opens Empire (rackets, crew, properties, cars).",
        .vehicle => "TIP: Vehicles panel → Enter deploys. World E enters/exits.",
        .save => "TIP: F5 quick-save · F9 quick-load · auto-save on quit.",
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
    gfx.drawText(text(h.current), 10, 370, backend.Color.rgb(180, 220, 255));
    gfx.drawText("[H] next tip  [X] dismiss tips", 10, 388, backend.Color.rgb(120, 140, 160));
}

pub fn handle(h: *Hints, raw: input.RawKeys, edge_h: *input.ButtonEdge, edge_x: *input.ButtonEdge) void {
    if (!h.visible) return;
    if (edge_h.pressed(raw.h)) advance(h);
    if (edge_x.pressed(raw.x)) {
        h.visible = false;
        h.current = .done;
    }
}
