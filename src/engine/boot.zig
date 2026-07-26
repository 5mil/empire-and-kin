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
    const title_c = backend.Color.rgb(255, 210, 120);
    const white = backend.Color.rgb(230, 230, 220);
    const dim = backend.Color.rgb(150, 150, 145);
    const accent = backend.Color.rgb(120, 200, 160);

    gfx.clear(backend.Color.rgb(12, 14, 22));

    switch (boot.phase) {
        .title => {
            gfx.drawText("EMPIRE & KIN", 40, 48, title_c);
            gfx.drawText("NYC mob life  -  real-time alpha", 40, 78, dim);
            gfx.drawText("[1]  New Game", 40, 130, white);
            if (boot.has_save) {
                gfx.drawText("[2]  Continue", 40, 158, accent);
            } else {
                gfx.drawText("[2]  Continue (no save)", 40, 158, dim);
            }
            gfx.drawText("WASD move  E job/car  Esc empire", 40, 220, dim);
        },
        .era_select => {
            gfx.drawText("CHOOSE YOUR ERA", 40, 48, title_c);
            if (boot.selected_era == .nyc_1930s) {
                gfx.drawText("> 1930s New York   [1]", 40, 110, accent);
            } else {
                gfx.drawText("  1930s New York   [1]", 40, 110, white);
            }
            gfx.drawText("Prohibition rackets, old families", 60, 132, dim);
            if (boot.selected_era == .nyc_1980s) {
                gfx.drawText("> 1980s New York   [2]", 40, 180, accent);
            } else {
                gfx.drawText("  1980s New York   [2]", 40, 180, white);
            }
            gfx.drawText("Neon heat, new crews, cocaine era", 60, 202, dim);
            gfx.drawText("[Enter] Start", 40, 260, white);
        },
        .playing => {},
    }
    if (boot.message.len > 0) {
        gfx.drawText(boot.message, 40, 320, accent);
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
