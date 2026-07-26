const std = @import("std");
const backend = @import("backend.zig");
const era = @import("../game/era.zig");
const input = @import("input.zig");

pub const BootPhase = enum {
    title,
    era_select,
    playing,
};

pub const BootState = struct {
    phase: BootPhase = .title,
    selected_era: era.Era = .nyc_1930s,
    has_save: bool = false,
    load_on_start: bool = false,
    message: []const u8 = "",
};

pub fn draw(gfx: backend.Backend, boot: BootState) void {
    const title_c = backend.Color.rgb(255, 215, 120);
    const white = backend.Color.rgb(235, 235, 225);
    const dim = backend.Color.rgb(150, 150, 145);
    const accent = backend.Color.rgb(100, 210, 160);
    const muted = backend.Color.rgb(100, 110, 130);

    gfx.clear(backend.Color.rgb(10, 12, 20));

    // Decorative bars via text
    gfx.drawText("================================", 40, 28, muted);

    switch (boot.phase) {
        .title => {
            gfx.drawText("EMPIRE & KIN", 40, 55, title_c);
            gfx.drawText("Little Italy  |  real-time alpha", 40, 85, dim);
            gfx.drawText("================================", 40, 105, muted);
            gfx.drawText("[1]  New Game", 40, 145, white);
            if (boot.has_save) {
                gfx.drawText("[2]  Continue last save", 40, 175, accent);
            } else {
                gfx.drawText("[2]  Continue (no save yet)", 40, 175, dim);
            }
            gfx.drawText("--------------------------------", 40, 215, muted);
            gfx.drawText("WASD walk     E job / car / club", 40, 240, dim);
            gfx.drawText("Esc empire    F5 save   F9 load", 40, 260, dim);
            gfx.drawText("Goal: control the block & stack cash", 40, 300, backend.Color.rgb(180, 200, 220));
        },
        .era_select => {
            gfx.drawText("CHOOSE YOUR ERA", 40, 55, title_c);
            gfx.drawText("================================", 40, 80, muted);
            if (boot.selected_era == .nyc_1930s) {
                gfx.drawText("> 1930s New York    [1]", 40, 120, accent);
            } else {
                gfx.drawText("  1930s New York    [1]", 40, 120, white);
            }
            gfx.drawText("  Rackets, families, Prohibition fade", 50, 145, dim);
            if (boot.selected_era == .nyc_1980s) {
                gfx.drawText("> 1980s New York    [2]", 40, 190, accent);
            } else {
                gfx.drawText("  1980s New York    [2]", 40, 190, white);
            }
            gfx.drawText("  Neon, new crews, harder heat", 50, 215, dim);
            gfx.drawText("[Enter]  Hit the street", 40, 280, white);
        },
        .playing => {},
    }
    if (boot.message.len > 0) {
        gfx.drawText(boot.message, 40, 340, accent);
    }
}

pub fn handle(
    boot: *BootState,
    raw: input.RawKeys,
    edge_1: *input.ButtonEdge,
    edge_2: *input.ButtonEdge,
    edge_enter: *input.ButtonEdge,
) void {
    switch (boot.phase) {
        .title => {
            if (edge_1.pressed(raw.key_1)) {
                boot.phase = .era_select;
                boot.message = "Pick an era";
            }
            if (edge_2.pressed(raw.key_2)) {
                if (boot.has_save) {
                    boot.load_on_start = true;
                    boot.phase = .playing;
                    boot.message = "Loading save...";
                } else {
                    boot.message = "No save - start New Game";
                }
            }
        },
        .era_select => {
            if (edge_1.pressed(raw.key_1)) boot.selected_era = .nyc_1930s;
            if (edge_2.pressed(raw.key_2)) boot.selected_era = .nyc_1980s;
            if (edge_enter.pressed(raw.enter)) {
                boot.phase = .playing;
                boot.message = era.name(boot.selected_era);
            }
        },
        .playing => {},
    }
}
