const std = @import("std");
const backend = @import("backend.zig");
const input = @import("input.zig");

pub const HintId = enum {
    move,
    job,
    choice,
    safehouse,
    empire,
    fence,
    numbers,
    goal,
    done,
};

pub const Hints = struct {
    current: HintId = .move,
    visible: bool = true,
};

pub fn text(id: HintId) []const u8 {
    return switch (id) {
        .move => "TIP: WASD toward cyan poles; stay near while working",
        .job => "TIP: After job [1] keep cash or [2] tithe crew",
        .choice => "TIP: Green club [E] heal  [R] bribe $500",
        .safehouse => "TIP: Esc empire  R collect  F upgrade racket $800",
        .empire => "TIP: Brown fence cools heat; stash hides cash",
        .fence => "TIP: Doc heals full $300; purple box is numbers",
        .numbers => "TIP: Goal tiers raise control + treasury targets",
        .goal => "TIP: Heat cools when you lay low; watch the feed",
        .done => "",
    };
}

pub fn advance(h: *Hints) void {
    h.current = switch (h.current) {
        .move => .job,
        .job => .choice,
        .choice => .safehouse,
        .safehouse => .empire,
        .empire => .fence,
        .fence => .numbers,
        .numbers => .goal,
        .goal => .done,
        .done => .done,
    };
    if (h.current == .done) h.visible = false;
}

pub fn draw(gfx: backend.Backend, h: Hints) void {
    if (!h.visible or h.current == .done) return;
    gfx.drawText(text(h.current), 10, 540, backend.Color.rgb(180, 220, 255));
    gfx.drawText("[H] next  [X] dismiss", 10, 558, backend.Color.rgb(120, 140, 160));
}

pub fn handle(h: *Hints, raw: input.RawKeys, edge_h: *input.ButtonEdge, edge_x: *input.ButtonEdge) void {
    if (!h.visible) return;
    if (edge_h.pressed(raw.h)) advance(h);
    if (edge_x.pressed(raw.x)) {
        h.visible = false;
        h.current = .done;
    }
}
